unit uformMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect, inifiles,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, Menus;

type
  TQCByLot = record
    bWOInput: Boolean;
    bGetSampleRange: Boolean;
    sWorkOrder: string;
    sPartNo: string;
    sSampleType: string;
    ssamplingTypeID: string;
    iLotSize: Integer;
  end;
  TformMain = class(TForm)
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    PMenuDefect: TPopupMenu;
    Delete1: TMenuItem;
    edtSN: TEdit;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    lablMsg: TLabel;
    labID: TLabel;
    lbl1: TLabel;
    Label6: TLabel;
    ImageAll: TImage;
    QryTemp: TClientDataSet;
    lblTerminal: TLabel;
    lblMsg: TLabel;
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
  public
    UpdateUserID: string;
    TerminalID,sEMP_NO: string;
    procedure SetStatusbyAuthority;
    function GetTerminalID: Boolean;
    function getSysdate:TDate;
    function GetEMPNO: string;
  end;

var
  formMain: TformMain;

implementation

{$R *.dfm}

uses uDllform, DllInit;

procedure TformMain.SetStatusbyAuthority;
var iPrivilege: integer;
begin
  // Read Only,Allow To Change,Full Control
  iPrivilege := 0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Quality Control';
      Params.ParamByName('FUN').AsString := 'QC By Lot-Print';
      Execute;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;

end;

procedure TformMain.Image2Click(Sender: TObject);
begin
  Close;
end;

procedure TformMain.FormShow(Sender: TObject);
begin
 { if UpdateUserID <> '0' then
    SetStatusbyAuthority; }
  if not GetTerminalID then
  begin
     MessageDlg('Not Get Terminal',mterror,[mbok],0);
     exit;
  end;
  edtSN.SetFocus;
  sEMP_NO := GetEMPNO;
end;

procedure TformMain.FormCreate(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
end;

function TformMain.GetTerminalID: Boolean;
begin
   with TIniFile.Create('SAJET.ini') do
  begin
    TerminalID := ReadString('Quality Control', 'Terminal', '');
    Free;
  end;
  if TerminalID = '' then
  begin
    MessageBeep(17);
    MessageDlg('Terminal not be assign !!', mtError, [mbCancel], 0);
    Exit;
  end;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'Select A.PROCESS_ID,A.TERMINAL_NAME,B.PROCESS_NAME,C.PDLINE_NAME ,D.STAGE_NAME ' +
      '      ,A.PDLINE_ID ' +
      'From  SAJET.SYS_TERMINAL A,' +
      ' SAJET.SYS_PROCESS B, ' +
      ' SAJET.SYS_STAGE D, ' +
      ' SAJET.SYS_PDLINE C ' +
      'Where   A.TERMINAL_ID = :TERMINALID '
      + ' AND A.PROCESS_ID = B.PROCESS_ID '
      + '   AND A.STAGE_ID = D.STAGE_ID '
      + ' AND A.PDLINE_ID = C.PDLINE_ID ';

    Params.ParamByName('TERMINALID').AsString := TerminalID;
    Open;
    if RecordCount <= 0 then
    begin
      Close;
      MessageBeep(17);
      MessageDlg('Terminal data error !!', mtError, [mbCancel], 0);
      Exit;
    end;
    lblTerminal.Caption := 'Terminal:'+
                    FieldbyName('PDLINE_NAME').AsString+'\'+
                    FieldbyName('Process_Name').AsString +'\'+
                    FieldByName('Terminal_Name').AsString;
    Close;
  end;
  Result := True;
end;

function TformMain.GetSysDate: TDate;
begin

  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select  sysdate iDate from dual';
    Open;
  end;
  Result := QryTemp.fieldbyname('iDate').AsDateTime;
end;

function TformMain.GetEMPNO: string;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select  EMP_NO   from SAJET.sys_emp where EMP_ID ='+updateuserID;
    Open;
  end;
  Result := QryTemp.fieldbyname('EMP_NO').AsString;
end;

procedure TformMain.edtSNKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
  if key <> #13 then exit;
  SPROC.Close;
  Sproc.DataRequest('SAJET.SJ_CSN_TEST');
  SPROC.FetchParams;
  Sproc.Params.ParamByName('TTERMINALID').Asstring :=TerminalID;
  Sproc.Params.ParamByName('TREV').Asstring :=edtSN.Text;
  Sproc.Params.ParamByName('TEMP').Asstring :=sEMP_NO;
  Sproc.Params.ParamByName('TDEFECT').Asstring :='N/A';
  Sproc.Params.ParamByName('TNOW').AsDateTime :=getSysdate;
  SPROC.Execute;

  iResult := Sproc.Params.ParamByName('TRES').Asstring;

  lblMsg.Caption :=iResult;
  lblMsg.Color := clGreen;
  
  if iResult <>'OK' then begin
      lblMsg.Color := clRed;
      //MessageDlg(iResult,mterror,[mbOK],0);
  end;
  edtSN.Text :='';
  EdtSN.SetFocus;

end;

end.

