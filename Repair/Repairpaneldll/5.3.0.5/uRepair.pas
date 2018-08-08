unit uRepair;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, SConnect, DB;
const
  WM_BASE = $8000;
  WM_Form1Close = WM_BASE + 1;
type
  TInitSajetParamDll = procedure (SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc, Param: string); stdcall;
  TCloseSajetDll = procedure; stdcall;
  TfRepair = class(TForm)
    PanelParent: TPanel;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure Form2Close(var Message: TMessage); message WM_Form1Close; public
  public
    { Public declarations }
    gsSN, m_sDLLName: string;
    m_DLLHandle: THandle;
    gbClose: Boolean;
    m_closeSajetDll: TCloseSajetDll;
    m_initialSajetParamDll: TInitSajetParamDll;
    procedure closeSajetDll;
  end;

var
  fRepair: TfRepair;

implementation

uses uDllForm, uDetail;

{$R *.dfm}

procedure TfRepair.FormShow(Sender: TObject);
  procedure LoadMDISajetDll(f_sDllName, f_sParam: string);
  begin
    try
      f_sDllName := uppercase(f_sDllName);
      m_DLLHandle := LoadLibrary(pchar(ExtractFilePath(Application.exename) + f_sDLLName));
      if m_DLLHandle <= 32 then raise Exception.create('Can Not Find DLL File(' + f_sDllName + ')');
      m_sDLLName := f_sDLLName;

      m_initialSajetParamDll := GetProcAddress(m_DLLHandle, 'InitSajetParamDll');
      if (@m_initialSajetParamDll = nil) then raise Exception.Create('DLL Function Not Match (1)');
      m_closeSajetDll := GetProcAddress(m_DLLHandle, 'CloseSajetDll');
      if (@m_closeSajetDll = nil) then raise Exception.Create('DLL Function Not Match (2)');

      m_initialSajetParamDll(self, PanelParent, Application, fDetail.UpdateUserID, G_sockConnection, '', '', f_sParam);
    except
      on E: Exception do raise Exception.create('(' + ClassName + '.LoadSajetDll)' + E.Message);
    end;
  end;
begin
  gbClose := False;
  LoadMDISajetDll('RepairDll.dll', gsSN);
end;

procedure TfRepair.closeSajetDll;
begin
  try
    m_DLLHandle := LoadLibrary(pchar(ExtractFilePath(Application.exename) + m_sDLLName));
    if m_DLLHandle <= 0 then Exit;
    m_closeSajetDll;
    FreeLibrary(m_DLLHandle);
  except
    on E: Exception do raise Exception.create('(CloseSajetDll)' + E.Message);
  end;
end;

procedure TfRepair.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    closeSajetDll;
end;

procedure TfRepair.Form2Close(var Message: TMessage);
var sNextProcess: String;
begin
  gbClose := True;
//  fDetail.combSerialNumber.Items.Clear;
  fDetail.combSerialNumber.Items.Delete(fDetail.combSerialNumber.ItemIndex);
  fDetail.combSerialNumber.Text := '';
  if fDetail.combSerialNumber.Items.Count = 0 then
  begin
    with fDetail.QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftDateTime, 'Box_no', ptInput);
      CommandText := 'select next_process from sajet.g_sn_status '
        + 'where box_no = :box_no and next_process <> 0';
      Params.ParamByName('Box_no').AsString := fDetail.cmbSN.Text;
      Open;
      sNextProcess := FieldByName('next_process').AsString;
      Close;
      Params.Clear;
      Params.CreateParam(ftDateTime, 'pdline_id', ptInput);
      Params.CreateParam(ftDateTime, 'stage_id', ptInput);
      Params.CreateParam(ftDateTime, 'process_id', ptInput);
      Params.CreateParam(ftDateTime, 'terminal_id', ptInput);
      Params.CreateParam(ftDateTime, 'wip_process', ptInput);
      Params.CreateParam(ftDateTime, 'next_process', ptInput);
      Params.CreateParam(ftDateTime, 'Box_no', ptInput);
      CommandText := 'update sajet.g_sn_status '
        + 'set pdline_id = :pdline_id, stage_id = :stage_id, '
        + 'process_id = :process_id, terminal_id = :terminal_id, '
        + 'wip_process = :wip_process , next_process = :next_process '
        + 'where box_no = :box_no ';
      Params.ParamByName('pdline_id').AsString := fDetail.PDLineId;
      Params.ParamByName('stage_id').AsString := fDetail.StageID;
      Params.ParamByName('process_id').AsString := fDetail.ProcessId;
      Params.ParamByName('terminal_id').AsString := fDetail.TerminalID;
      Params.ParamByName('wip_process').AsString := sNextProcess;
      Params.ParamByName('next_process').AsString := sNextProcess;
      Params.ParamByName('Box_no').AsString := fDetail.cmbSN.Text;
      Execute;
      Close;
    end;
    fDetail.cmbSN.Items.Delete(fDetail.cmbSN.ItemIndex);
    fDetail.cmbSNChange(Self);
  end;  
  Close;
end;

procedure TfRepair.FormDestroy(Sender: TObject);
begin
    closeSajetDll;
end;

procedure TfRepair.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.

