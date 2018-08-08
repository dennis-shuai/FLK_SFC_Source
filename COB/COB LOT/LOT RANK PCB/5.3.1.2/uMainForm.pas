unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles;

type
  TfMainForm = class(TForm)
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
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    editLot: TEdit;
    editCustomer: TEdit;
    DBGrid1: TDBGrid;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    labInputQty: TLabel;
    ImageAll: TImage;
    Label2: TLabel;
    Label3: TLabel;
    LabWoQty: TLabel;
    Label5: TLabel;
    editWO: TEdit;
    LabPartNo: TLabel;
    LabLotQty: TLabel;
    btnClose: TSpeedButton;
    Image5: TImage;
    procedure FormShow(Sender: TObject);
    procedure editLotKeyPress(Sender: TObject; var Key: Char);
    procedure editCustomerKeyPress(Sender: TObject; var Key: Char);
    procedure editWOKeyPress(Sender: TObject; var Key: Char);
    procedure btnCloseClick(Sender: TObject);
  private

    //function CheckCustomerRule: string;      //检查Customer字符规则,第一码,长度等
    function CheckCustomerValue: string;    //检查Customer字符是否在0~Z之间
    function GetTerminalName(sTerminalID:string):string;
    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
    procedure ShowData(sCarrier :String);
  public
    UpdateUserID,sPartID : String;
    sPdline,sProcess,sProcessId,sTerminal,sStartProcess:string;
    gWO,gCarrierNO:string;
    iCarrierSNCount,iSNCount:Integer;
    iTerminal:string;

  end;

var
  fMainForm: TfMainForm;


implementation


{$R *.dfm}

function TfMainForm.GetTerminalName(sTerminalID:string):string;
begin
try
  with Qrytemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'TerminalID',ptInput);
      CommandText :='select a.pdline_name,b.process_name,c.terminal_name,c.terminal_id ,b.Process_id ' +
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
         sProcessId :=Fieldbyname('process_ID').AsString  ;
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


procedure TfMainForm.ShowMSG(sShowHead,sShowResult,sNextMsg:string);
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

procedure TfMainForm.ShowData(sCarrier :String);
begin

    With QryData do
    begin
       Close;
       Params.Clear;
       //Params.CreateParam(ftString,'WO',ptInput);
       Params.CreateParam(ftString,'LotNo',ptInput);
       CommandText := 'SELECT A.WORK_ORDER,A.BOX_NO,A.serial_number,a.Customer_SN,A.in_process_time '+
                      '  FROM SAJET.g_sn_status A '+
                      ' WHERE A.Pallet_No= :LotNo '+
                      '   AND A.WORK_FLAG= ''0'' '+          //add by phoenix 2013-05-09
                      ' ORDER BY A.serial_number ';
     Params.ParamByName('LotNo').AsString := sCarrier;
     Open;

    end;
    LabLotQty.Caption := IntToStr(QryData.recordCount);
end;

procedure TfMainForm.FormShow(Sender: TObject);
Var Bmp : TBitmap;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;

  Bmp.Free;

  LabLotQty.Caption :='';
  editWO.SetFocus;
  LabTerminal.Caption := LabTerminal.Caption + '    ' + GetTerminalName(iTerminal);

end;



procedure TfMainForm.editLotKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
    if Key <> #13 then exit;
    if Length(editLot.Text) =0 then exit;


    Sproc.Close;
    Sproc.DataRequest('SAJET.CCM_CHK_RANKPCB_LOT');
    Sproc.FetchParams;
    Sproc.Params.ParamByName('TREV').AsString :=editLot.Text;
    Sproc.Params.ParamByName('TWO').AsString :=editWO.Text;
    Sproc.execute;

    iResult:=  Sproc.Params.paramByName('TRES').AsString ;

    if  iResult <> 'OK' then
    begin

        ShowMsg('ERROR',iResult,'');
        editLot.SetFocus;
        editLot.Text :='';
        exit ;

    end;

   ShowData(editLot.text);

   editCustomer.ReadOnly :=false;
   editCustomer.SetFocus;
   editCustomer.Clear;
   editLot.Enabled:=false;

end;

procedure TfMainForm.editCustomerKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
  if Key <> #13 then exit;

  iResult :=CheckCustomerValue;
  if iResult <> 'OK' then begin
        ShowMsg('岿粇','め兵絏砏玥岿粇','');
        editCustomer.Setfocus;
        editCustomer.SelectAll;
        exit;
  end;

  sproc.Close;
  sproc.DataRequest('SAJET.CCM_COB_RANKPCB_LOT');
  sproc.FetchParams;
  sproc.Params.ParamByName('TWO').AsString := editWO.Text;
  sproc.Params.ParamByName('TLOTNO').AsString := editLot.Text;
  sproc.Params.ParamByName('TPROCESSID').AsString := sProcessId;
  sproc.Params.ParamByName('TCSN').AsString :=editCustomer.Text;
  sproc.Params.ParamByName('TTERMINALID').AsString :=iterminal;
  sproc.Params.ParamByName('TEMPID').AsString :=UpdateUserID;
  sproc.Execute;

  iResult := sproc.Params.parambyname('TRES').AsString;

  if iResult <> 'OK' then begin
      ShowMsg('岿粇',iResult,'');
      editCustomer.Setfocus;
      editCustomer.SelectAll;
      exit;
  end;
  ShowData(editLot.Text);

  editCustomer.SetFocus;
  editCustomer.Text :='';
  ShowMsg('OK',iResult,'');

  if sStartProcess =sProcessId then
  begin
      
      With QryData do
      begin
         Close;
         Params.Clear;
         //Params.CreateParam(ftString,'WO',ptInput);
         Params.CreateParam(ftString,'WO',ptInput);
         CommandText := 'SELECT Input_qty,Target_qty from sajet.g_wo_base where Work_order=:WO';
         Params.ParamByName('WO').AsString := editWO.Text;
         Open;
         LabWoQty.Caption := '虫羆计:'+fieldByname('Target_qty').AsString +#13#10+'虫щ计:'+fieldByname('Input_qty').AsString ;
      end;


  end;

end;

function TfMainForm.CheckCustomerValue: string;
var
  i,vLength: integer;
  sValue,vChar: string;
begin
  sValue := trim(editCustomer.Text);
  vLength := length(sValue);
  for i := 1 to vLength do
  begin
    vChar := copy(sValue,i,1);
    if ((vChar >= '0') and (vChar <= '9')) or ((vChar >= 'A') and (vChar <= 'Z')) or (vChar ='-') then
      Result := 'OK'
    else
    begin
      Result := 'Error';
      Exit;
    end;
  end;
end;

procedure TfMainForm.editWOKeyPress(Sender: TObject; var Key: Char);
var iResult :string;

begin
  if Key <> #13 then exit;

  QryTemp.Close;
  QryTemp.Params.Clear;
  QryTemp.Params.CreateParam(ftstring,'SN',ptInput);
  QryTemp.CommandText := 'Select WORK_ORDER,MODEL_ID FROM SAJET.G_SN_STATUS  '+
                         ' WHERE  CUSTOMER_SN=:SN ';
  Qrytemp.Params.ParamByName('SN').AsString :=editWO.Text;
  QryTemp.Open;
  if not QryTEmp.IsEmpty then begin
     editWO.Text :=QryTemp.fieldByName('WORK_ORDER').AsString;
     sPartID :=  QryTemp.fieldByName('MODEL_ID').AsString;
  end;

  Sproc.Close;
  Sproc.DataRequest('SAJET.SJ_CHK_WO_INPUT');
  Sproc.FetchParams;
  Sproc.Params.ParamByName('TREV').AsString :=editWO.Text;
  Sproc.Execute;
  iResult := Sproc.Params.parambyname('TRES').asstring ;

  if  iResult<> 'OK' then begin
       editLot.Text :='';
       editCustomer.Text :='';
       editLot.ReadOnly :=false;
       editCustomer.ReadOnly :=false;
       editWO.SelectAll;
       editWO.SetFocus;
       msgPanel.Caption := iResult;
       msgPanel.Color :=clRed;
       exit;
  end;

  
  QryTemp.Close;
  QryTemp.Params.Clear;
  QryTemp.Params.CreateParam(ftstring,'TWO',ptInput);
  QryTemp.CommandText := 'Select A.WORK_ORDER,A.MODEL_ID,B.PART_NO,A.Start_process_Id FROM SAJET.G_WO_BASE A,SAJET.SYS_PART B '+
                         ' WHERE A.WORK_ORDER =:TWO AND A.MODEL_ID=B.PART_ID ';
  Qrytemp.Params.ParamByName('TWO').AsString :=editWO.Text;
  QryTemp.Open;
  if not QryTEmp.IsEmpty then
  begin
      sStartProcess :=QryTemp.fieldbyname('Start_process_ID').AsString;
      LabPartNo.Caption :=  '腹:'+QryTEmp.fieldbyname('PART_NO').AsString;
  end;



  editLot.SetFocus;
  editLot.SelectAll;
  editLot.ReadOnly :=false;
  msgPanel.Caption := 'Please Input Lot';
  msgPanel.Color :=clGreen;
  editWO.Enabled :=false;
  

end;

procedure TfMainForm.btnCloseClick(Sender: TObject);
begin
   if QryData.RecordCount =0 then Exit;
end;

end.
