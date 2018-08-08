unit uCMInput;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles,Comobj;

type
  TfCMInput = class(TForm)
    ImageAll: TImage;
    sbtnClose: TSpeedButton;
    Image2: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SimpleObjectBroker1: TSimpleObjectBroker;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SocketConnection1: TSocketConnection;
    dsData: TDataSource;
    SaveDialog: TSaveDialog;
    QryTemp1: TClientDataSet;
    Label3: TLabel;
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    editCustomer: TEdit;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    Label2: TLabel;
    editKP: TEdit;
    procedure FormShow(Sender: TObject);
    procedure editCustomerKeyPress(Sender: TObject; var Key: Char);
    procedure editKPKeyPress(Sender: TObject; var Key: Char);
  private
    function CheckWO(sWO:string):string;
    function GetTerminalName(sTerminalID:string):string;
    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
  public
    UpdateUserID ,sEMP_NO,sPDlineID,sStageID,sProcessID: String;
    iTerminal,gWO:string;
end;

var
  fCMInput: TfCMInput;


implementation

{$R *.dfm}


function TfCMInput.CheckWO(sWO:string):string;
begin
try
  Result := 'Check WO Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.Sj_Chk_Wo_Input');
      FetchParams;
      Params.ParamByName('TREV').AsString := sWO;
      Execute;
      Result := Params.ParamByName('TRES').AsString;
    finally
      Close;
    end;
  end;
except on e:Exception do
  begin
    Result := 'CheckWO error : ' + e.Message;
  end;
end;
end;

function TfCMInput.GetTerminalName(sTerminalID:string):string;
var sPdline,sProcess,sTerminal:string;
begin
try
  with Qrytemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'TerminalID',ptInput);
      CommandText :='select a.pdline_name,b.process_name,c.terminal_name,c.terminal_id  ' +
                    '  from sajet.sys_pdline a,sajet.sys_process b,sajet.sys_terminal c '+
                    'where c.terminal_id = :TerminalID  '+
                    '  and a.pdline_id=c.pdline_id '+
                    '  and b.process_id=c.process_id';

      Params.ParamByName('TerminalID').AsString :=sTerminalID;
      Open;
      if RecordCount > 0 then
      begin
         sPdline := Fieldbyname('pdline_name').AsString  ;
         sProcess:= Fieldbyname('process_name').AsString  ;
         sTerminal:= Fieldbyname('terminal_name').AsString  ;
         Result := sPdline + ' \ ' + sProcess + ' \ ' + sTerminal ;
      end   
      else
         Result :='No Terminal information!';
   end;
Except   on e:Exception do
   Result := 'Get Terminal : ' + e.Message;

end;
end;

procedure TfCMInput.ShowMSG(sShowHead,sShowResult,sNextMsg:string);
var sShowData:string;
begin
  if sShowResult = 'OK' then
  begin
    msgPanel.Color := clGreen;
  end
  else
  begin
    msgPanel.Color := clRed;
  end;
  sShowData := sShowHead + ' ' +  sShowResult;
  if sNextMsg <> '' then
  begin
    sShowData := sShowData + '  =>  ' + sNextMsg;
  end;
  msgPanel.Caption := sShowData;
end;


procedure TfCMInput.FormShow(Sender: TObject);
Var DestRect,SurcRect : TRect; Bmp : TBitmap;PrintFile:string;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;

  Bmp.Free;

  editCUstomer.Enabled :=True;
  editCustomer.SetFocus;
  editKP.Enabled :=false;


  labTerminal.Caption :='TERMINAL:  '+ GetTerminalName(iTerminal);

end;

procedure TfCMInput.editCustomerKeyPress(Sender: TObject; var Key: Char);
var iResult,sSN,SWO:string;
begin

    if  Key <>#13 then exit;
    if  editCustomer.Text ='' then exit;

    with QryTemp do
    begin
        Close;
        Params.CreateParam(ftString,'SN',ptInput);
        CommandText :=' Select work_order,Model_id,Serial_number from sajet.g_sn_status '+
                      ' where serial_number=:SN or customer_sn=:sn ';
        Params.ParamByName('SN').AsString := editCustomer.Text;
        Open;

        if IsEmpty then
        begin
            msgPanel.Caption :='NO SN';
            msgPanel.Font.Color :=clBlack;
            msgPanel.Color :=clRed;
            editCustomer.Clear;
            editCUstomer.Setfocus;
            exit;
        end;
        gWO:= FieldByName('work_order').AsString;
        sSN :=  FieldByName('Serial_number').AsString;
    end;

    Sproc.Close;
    Sproc.DataRequest('SAJET.SJ_CKRT_ROUTE');
    Sproc.FetchParams;
    Sproc.Params.ParamByName('TSN').AsString := sSN;
    Sproc.Params.ParamByName('TERMINALID').AsString :=iTerminal ;
    Sproc.Execute;
    iResult := SProc.Params.ParamByName('TRES').AsString;
    if  iResult <> 'OK' then
    begin
        msgPanel.Caption :=iResult;
        msgPanel.Font.Color :=clBlack;
        msgPanel.Color :=clRed;
        editCustomer.Clear;
        editCUstomer.Setfocus;
        exit;
    end;

    msgPanel.Caption :='OK,請掃描重要部件條碼';
    msgPanel.Font.Color :=clBlack;
    msgPanel.Color :=clGreen;
    editCustomer.Enabled :=False;
    editKP.Enabled :=True;
    editKP.Clear;
    editKP.Setfocus;

end;

procedure TfCMInput.editKPKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin

   if  Key <>#13 then exit;
   if  editKP.Text ='' then exit;


   Sproc.Close;
   Sproc.DataRequest('SAJET.CCM_INPUT_CHK_KPSN_FINISHED');
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TKPSN').AsString := editKP.Text;
   Sproc.Params.ParamByName('TWO').AsString := gWO;
   Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal ;
   Sproc.Execute;


   iResult := Sproc.Params.ParamByName('TRES').AsString;
   
   if iResult <> 'OK' then begin

        msgPanel.Caption :=iResult;
        msgPanel.Font.Color :=clBlack;
        msgPanel.Color :=clRed;
        editKP.Clear;
        editKP.Setfocus;
        exit;
   end;


   Sproc.Close;
   Sproc.DataRequest('SAJET.CCM_ASSY_SN_KPSN_GO');
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TSN').AsString := editCustomer.Text;
   Sproc.Params.ParamByName('TKPSN').AsString := editKP.Text;
   Sproc.Params.ParamByName('TWO').AsString := gWO;
   Sproc.Params.ParamByName('TEMPID').AsString := UpdateUserID;
   Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal ;
   Sproc.Execute;

   iResult := Sproc.Params.ParamByName('TRES').AsString;

   if iResult <> 'OK' then begin

          msgPanel.Caption :=iResult;
          msgPanel.Font.Color :=clBlack;
          msgPanel.Color :=clRed;
          editCustomer.Clear;
          editCUstomer.Setfocus;
          exit;
   end;

   msgPanel.Caption :='OK';
   msgPanel.Font.Color :=clBlack;
   msgPanel.Color :=clGreen;
   editKP.Clear;
   editKP.Enabled :=false;
   editCustomer.Enabled :=True;
   editCustomer.Clear;
   editCustomer.Setfocus;

end;

end.
