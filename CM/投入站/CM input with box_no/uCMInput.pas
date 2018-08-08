unit uCMInput;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles,Comobj,TLHELP32;

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
    lbldata: TLabel;
    Label3: TLabel;
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    editWO: TEdit;
    edtBoxNo: TEdit;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    Label1: TLabel;
    labPartNo: TLabel;
    Label7: TLabel;
    labTargetQty: TLabel;
    Label8: TLabel;
    labInputQty: TLabel;
    dbgrd1: TDBGrid;
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure editWOKeyPress(Sender: TObject; var Key: Char);
    procedure edtBoxNoKeyPress(Sender: TObject; var Key: Char);
    procedure labWODblClick(Sender: TObject);
  private
    //m_SNDefectLevel: String;
    function CheckWO(sWO:string):string;
    function CheckCarrier(sCarrier:string;var iCarrierCount:Integer):string;
    function CheckCustomer(sTerminal,sEmp,sWO,sCarrier,sCustomer:string):string;

    function GetTerminalName(sTerminalID:string):string;
  public
    UpdateUserID ,sEMP_NO,sPDlineID,sStageID,sProcessID: String;
    PrintFile,iTerminal:string;
    isStart,IsOpen:boolean;
    BarApp,BarDoc,BarVars:variant;
    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
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

function TfCMInput.CheckCarrier(sCarrier:string;var iCarrierCount:Integer):string;
begin
try
  Result := 'Check Carrier Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.CCM_COB_CHK_PANEL_INPUT');
      FetchParams;
      Params.ParamByName('TREV').AsString := sCarrier;
      Execute;
      iCarrierCount := Params.ParamByName('TCARRIERCOUNT').AsInteger;
      Result := Params.ParamByName('TRES').AsString;
      
    finally
      Close;
    end;
  end;
except on e:Exception do
  begin
    Result := 'Check Carrier error : ' + e.Message;
  end;
end;
end;

function TfCMInput.CheckCustomer(sTerminal,sEmp,sWO,sCarrier,sCustomer:string):string;
begin
  try
  Result := 'Check Panel Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.Sj_Chk_Carrier_Customer2');
      FetchParams;
      Params.ParamByName('TTERMINAL').AsString := sTerminal;
      Params.ParamByName('TEMP').AsString := sEmp;
      Params.ParamByName('TWO').AsString := sWO ;
      Params.ParamByName('TCARRIER').AsString := sCarrier;
      Params.ParamByName('TREV').AsString := sCustomer;
      Execute;
      Result := Params.ParamByName('TRES').AsString;
    finally
      Close;
    end;
  end;
except on e:Exception do
  begin
    Result := 'CheckCustomer error : ' + e.Message;
  end;
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
Var Bmp : TBitmap;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;
  Bmp.Free;

  editWO.SetFocus;
  editWO.Text := '';

  labTerminal.Caption :='TERMINAL:    '+ GetTerminalName(iTerminal);
   

end;

procedure TfCMInput.Image2Click(Sender: TObject);
begin
   Close;
end;


procedure TfCMInput.editWOKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
  if Key = #13 then
  begin
    if iTerminal = '' then
    begin
       MessageDlg('please input Terminal information!',mtError,[mbOK],0);
       Exit;
    end;

    iResult := CheckWO(Trim(editWO.Text));

    if iResult = 'OK' then
    begin

      with QryTemp do
      begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString,'WO',ptInput);
          CommandText := 'Select P.PART_NO,TARGET_QTY,INPUT_QTY FROM  SAJET.G_WO_BASE W'
                       + ' Left outer join SAJET.SYS_PART P ON W.MODEL_ID=P.PART_ID '
                       + ' WHERE W.WORK_ORDER = :WO';
          Params.ParamByName('WO').AsString := Trim(editWO.Text);
          Open;

          labPartNo.Caption := FieldByName('PART_NO').AsString;
          labTargetQty.Caption := FieldByName('TARGET_QTY').AsString;
          labInputQty.Caption := FieldByName('INPUT_QTY').AsString;
      end;

      if QryTemp.FieldByName('INPUT_QTY').AsInteger >= QryTemp.FieldByName('TARGET_QTY').AsInteger then
      begin
         ShowMSG('Work Order input : ','Error','WO InputQty >= TargetQty');
         editWO.SelectAll;
         editWO.SetFocus;
         exit;
      end
      else
      begin

          ShowMSG('Work Order input : ',iResult,'�п�J���X!');
          edtBoxNo.Text := '';
          edtBoxNo.SetFocus;
          editWO.Enabled := False;

      end;
    end
    else
    begin
      ShowMSG('Work Order input : ',iResult,'Please input Work order again!');
      editWO.SelectAll;
      editWO.SetFocus;
      exit;
    end;
  end;
end;

procedure TfCMInput.edtBoxNoKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin

   if key <> #13 then exit;

   if edtBoxNo.Text ='' then exit;

   Sproc.Close;
   Sproc.DataRequest('SAJET.CCM_BOX_INPUT');
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TWO').AsString := editWO.Text ;
   Sproc.Params.ParamByName('TBOXNO').AsString := edtBoxNo.Text;
   Sproc.Params.ParamByName('TEMPID').AsString := UPDATEUSERID;
   Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal ;
   Sproc.Execute;
   iResult := Sproc.Params.ParamByName('TRES').AsString;

   if iResult <> 'OK' then
   begin
      ShowMSG('������~','Error',iResult);
      edtBoxNo.SelectAll;
      edtBoxNo.SetFocus;
      exit;
   end;


    msgPanel.Color := ClGreen;
    edtBoxNo.Clear;
    edtBoxNo.SetFocus;
    QryData.close;
    QryData.Params.Clear;
    QryData.Params.CreateParam(ftString,'WO',ptInput);
    QryData.Params.CreateParam(ftString,'BOXNO',ptInput);
    QryData.CommandText :='SELECT WORK_ORDER,SERIAL_NUMBER,OUT_PROCESS_TIME,CUSTOMER_SN,BOX_NO '+
                          'FROM SAJET.G_SN_STATUS WHERE WORK_ORDER =:WO AND BOX_NO=:BOXNO ';
    QryData.Params.ParamByName('WO').AsString :=editWO.Text;
    QryData.Params.ParamByName('BOXNO').AsString :=edtBoxNo.Text;
    QryData.Open;

    QryTemp.close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'WO',ptInput);
    QryTemp.CommandText :='Select Input_QTY from sajet.G_WO_BASE where WORK_ORDER =:WO';
    QryTemp.Params.ParamByName('WO').AsString :=editWO.Text;
    QryTemp.Open;

    LabInputQty.Caption :=  QryTemp.fieldbyname('INPUT_QTY').AsString;

end;

procedure TfCMInput.labWODblClick(Sender: TObject);
begin

  if not editWO.Enabled then
  begin
      editWO.Enabled := True;
      editWO.SelectAll;
      editWO.SetFocus;
  end
  else
  begin
      editWO.Enabled := False;
  end;

end;

end.
