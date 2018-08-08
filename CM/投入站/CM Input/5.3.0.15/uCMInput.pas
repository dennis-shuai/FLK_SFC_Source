unit uCMInput;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles;

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
    Label2: TLabel;
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    editWO: TEdit;
    editCarrier: TEdit;
    editCustomer: TEdit;
    DBGrid1: TDBGrid;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    labSNCount: TLabel;
    labWO: TLabel;
    labCarrier: TLabel;
    Label1: TLabel;
    labPartNo: TLabel;
    Label7: TLabel;
    labTargetQty: TLabel;
    Label8: TLabel;
    labInputQty: TLabel;
    labPWO: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    edtModelType: TEdit;
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure editDataKeyPress(Sender: TObject; var Key: Char);
    procedure Cancel1Click(Sender: TObject);
    procedure ClearAll1Click(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure editWOKeyPress(Sender: TObject; var Key: Char);
    procedure editCarrierKeyPress(Sender: TObject; var Key: Char);
    procedure editCustomerKeyPress(Sender: TObject; var Key: Char);
    procedure labWODblClick(Sender: TObject);
    procedure labCarrierDblClick(Sender: TObject);
    procedure edtModelTypeKeyPress(Sender: TObject; var Key: Char);
  private
    //m_SNDefectLevel: String;
    procedure clearData;
    procedure getWHINNo;
    procedure getWHINDetail(WHINno :String);
    function GetWHID(WHCODE :string) :string;

    function CheckWO(sWO:string):string;
    function CheckCarrier(sCarrier:string;var iCarrierCount:Integer):string;
    function CheckCustomer(sTerminal,sEmp,sWO,sCarrier,sCustomer:string):string;
    function CheckCustomerRule: string;      //���Customer�ַ�����,��һ��,���ȵ�
    function CheckCustomerValue: string;    //���Customer�ַ��Ƿ���0~Z֮��

    function GetTerminalName(sTerminalID:string):string;

    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
    procedure RemoveCarrier(sCarrier:string);


    function GetPartID(partno :String) :String;
    procedure ShowData(sWO,sCarrier :String);
  public
    UpdateUserID : String;
    Authoritys,AuthorityRole,FunctionName : String;
    //Language : TLanguage;
    procedure SetStatusbyAuthority;
    Function LoadApServer : Boolean;
  end;

var
  fCMInput: TfCMInput;
  flag:Boolean;
  emess:string;
  gWO,gCarrierNO:string;
  iCarrierSNCount,iSNCount:Integer;
  iTerminal:string;

implementation

uses uformLotMemo;


{$R *.dfm}



function TfCMInput.GetWHID(WHCODE :string) :string;
begin
   with Qrytemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'WHCODE',ptInput);
      CommandText :='select WH_ID from sajet.sys_wh_warehouse where WH_CODE = :WHCODE  AND ROWNUM=1 ';
      Params.ParamByName('WHCODE').AsString :=WHCODE;
      Open;
      if RecordCount > 0 then
         Result := Fieldbyname('WH_ID').AsString
      else
         Result :='';
   end;
end;

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
      DataRequest('SAJET.Sj_Chk_Carrier');
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
      Params.ParamByName('TVERSION').AsString := edtModelType.Text;
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

procedure TfCMInput.RemoveCarrier(sCarrier:string);

begin
try
  with Qrytemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString,'Carrier',ptInput);
    CommandText :='update SAJET.g_sn_status set box_no = ''N/A'' WHERE box_no= :Carrier ' ;
    Params.ParamByName('Carrier').AsString := sCarrier;
    Execute;
  end;
except on e:Exception do
  begin
    MessageDlg('Remove carrier err: '+e.Message,mtError,[mbOK],0);
  end;

end;
end;

function TfCMInput.GetPartID(partno :String) :String;
begin
    with Qrytemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'PARTNO',ptInput);
        CommandText :='SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO= :PARTNO AND ENABLED=''Y'' AND ROWNUM=1 ' ;
        Params.ParamByName('PARTNO').AsString := partno;
        Open;
        if Recordcount = 0 then
            Result :=''
        else
            Result := FieldbyName('PART_ID').AsString;
    end;
end;

procedure TfCMInput.ShowData(sWO,sCarrier :String);
var iqty : Integer;
begin
    iqty := 0 ;
    With QryData do
    begin
       Close;
       Params.Clear;
       //Params.CreateParam(ftString,'WO',ptInput);
       Params.CreateParam(ftString,'CarrierNO',ptInput);
       CommandText := 'SELECT A.WORK_ORDER,A.BOX_NO,A.serial_number,a.Customer_SN,A.in_process_time '+
                      '  FROM SAJET.g_sn_status A '+
                      //' WHERE A.WORK_ORDER = :WO '+        //modify by phoenix 2013-5-9
                      ' WHERE A.Box_NO= :CarrierNO '+
                      '   AND A.WORK_FLAG= ''0'' '+          //add by phoenix 2013-05-09
                      '   AND A.CUSTOMER_SN <> ''N/A'' '+    //add by phoenix 2013-05-09
                      ' ORDER BY A.serial_number ';
     //Params.ParamByName('WO').AsString := sWO;
     Params.ParamByName('CarrierNO').AsString := sCarrier;
     Open;
     iSNCount := RecordCount ;
     labSNCount.Caption := IntToStr(iSNCount) + ' / ' + IntToStr(iCarrierSNCount);
    end;
end;

procedure TfCMInput.FormShow(Sender: TObject);
Var DestRect,SurcRect : TRect; Bmp : TBitmap;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;

  Bmp.Free;

  LoadApServer;
  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;

  editWO.SetFocus;
  editWO.Text := '';
  LabTerminal.Caption := LabTerminal.Caption + '    ' + GetTerminalName(iTerminal);
  labWO.Caption := '';
  labCarrier.Caption := '';
  labSNCount.Caption := '';
  iCarrierSNCount := 0;
end;

procedure TfCMInput.clearData;
begin
end;

procedure TfCMInput.getWHINDetail(WHINno :String);
var sSQL : String;
begin
 sSQL := ' SELECT DISTINCT B.PART_NO  '+
         ' FROM SAJET.G_WH_WHIN_LIST A,'+
         '      SAJET.SYS_PART B '+
         ' WHERE A.ITEM_PART_ID=B.PART_ID '+
         ' AND A.STATUS =''0'' '+
         ' AND A.WHIN_LIST_NO = :WHINNO '+
         ' ORDER BY B.PART_NO ';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString,'WHINNO',ptInput);
    CommandText := sSQL;
    Params.ParamByName('WHINNO').AsString := trim(WHINno);
    Open;
    Close;
  end;
end;

procedure TfCMInput.getWHINNo;
var sSRtNo:string;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText :=  ' SELECT DISTINCT A.ORDER_NO  '+
                    ' FROM SAJET.G_WH_LIST A  '+
                    ' WHERE A.LIST_TYPE=''WHIN'' '+
                    ' AND A.STATUS <=''1'' '+
                    ' ORDER BY A.ORDER_NO ' ;
    Open;
    while not Eof do
    begin
      Next;
    end;
    Close;
  end;
end;

Procedure TfCMInput.SetStatusbyAuthority;
begin
  // Read Only,Allow To Change,Full Control
  Authoritys := '';
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'EMP_ID', ptInput);
    Params.CreateParam(ftString	,'PRG', ptInput);
    Params.CreateParam(ftString	,'FUN', ptInput);
    CommandText := 'Select AUTHORITYS '+
                   'From  SAJET.SYS_EMP_PRIVILEGE '+
                   'Where EMP_ID = :EMP_ID and '+
                         'PROGRAM = :PRG and '+
                         'FUNCTION = :FUN ';
    Params.ParamByName('EMP_ID').AsString := UpdateUserID;
    Params.ParamByName('PRG').AsString := 'PNWareHouse';
    Params.ParamByName('FUN').AsString := FunctionName;
    Open;
    If RecordCount > 0 Then
      Authoritys := Fieldbyname('AUTHORITYS').AsString;
    Close;
  end;

  //sbtnSave.Enabled := ((Authoritys = 'Allow To Execute') or (Authoritys = 'Full Control'));
  //sbtnFinish.Enabled := (Authoritys = 'Full Control');
  
  if Authoritys = '' then
  begin
    AuthorityRole := '';
    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'EMP_ID', ptInput);
      Params.CreateParam(ftString	,'PRG', ptInput);
      Params.CreateParam(ftString	,'FUN', ptInput);
      CommandText := 'Select AUTHORITYS '+
                     //'From LOT.SYS_ROLE_PRIVILEGE A, '+
                     'From SAJET.SYS_ROLE_PRIVILEGE A, '+
                          'SAJET.SYS_ROLE_EMP B '+
                     'Where A.ROLE_ID = B.ROLE_ID and '+
                           'EMP_ID = :EMP_ID and '+
                           'PROGRAM = :PRG and '+
                           'FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'PNWareHouse';//'Quality Control';
      Params.ParamByName('FUN').AsString := FunctionName;//'Execution';
      Open;
      If RecordCount > 0 Then
        AuthorityRole := Fieldbyname('AUTHORITYS').AsString;
      Close;
    end;
    //sbtnSave.Enabled := ((AuthorityRole = 'Allow To Execute') or (AuthorityRole = 'Full Control'));
    //sbtnFinish.Enabled := (AuthorityRole = 'Full Control');
  end;


end;


Function TfCMInput.LoadApServer : Boolean;
Var F : TextFile;
    S : String;
begin
  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  If not FileExists(GetCurrentDir+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,GetCurrentDir+'\ApServer.cfg');
  Reset(F);
  While True do
  begin
    Readln(F, S);
    If S <> '' Then
    begin
      SimpleObjectBroker1.Servers.Add;
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
    end Else
      Break;
  end;
  CloseFile(F);
  Result := True;
end;

procedure TfCMInput.Image2Click(Sender: TObject);
begin
   Close;
end;

procedure TfCMInput.editDataKeyPress(Sender: TObject; var Key: Char);
var sWHINNO,sPARTNO,stype,sWHID : String;
    iMaxQty,iQty,iallQty :Integer;
begin
    if key =#13 then
    begin

       with QryTemp do
       begin
       try
        //insert
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WHINNO',ptInput);
        Params.CreateParam(ftString,'REELNO',ptInput);
        Params.CreateParam(ftString,'EMPID',ptInput);
        Params.CreateParam(ftString,'WHID',ptInput);
        CommandText := 'INSERT INTO SAJET.G_REEL_WH_IN_TEMP  '+
                       ' (ORDER_NO,PART_ID,REEL_NO,REEL_QTY,WH_ID,PALLET_NO,CARTON_NO,EMP_ID) '+
                       ' SELECT :WHINNO,MODEL_ID,SERIAL_NUMBER,1,:WHID,PALLET_NO,CARTON_NO,:EMPID '+
                       ' FROM SAJET.G_SN_STATUS '+
                       ' WHERE  ';
        if stype = 'Pallet' then
           CommandText := CommandText +' PALLET_NO = :REELNO ';
        if stype = 'Carton' then
           CommandText := CommandText +' CARTON_NO = :REELNO ';
        if stype = 'SN' then
           CommandText := CommandText +' SERIAL_NUMBER = :REELNO ';

        Params.ParamByName('WHINNO').AsString := sWHINNO;
        Params.ParamByName('EMPID').AsString := UpdateUserID;
        Params.ParamByName('WHID').AsString := sWHID;
        Execute;
      Except
       Exit;
     end;
     end;
       ShowData(sWHINNO,sPartNO);
    end;
end;


procedure TfCMInput.Cancel1Click(Sender: TObject);
var sReelNO : string;
begin
   with QryTemp do
       begin
       try
        //insert
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'REELNO',ptInput);
        CommandText := 'DELETE FROM  SAJET.G_REEL_WH_IN_TEMP  '+
                       ' WHERE REEL_NO = :REELNO ';
        Params.ParamByName('REELNO').AsString := sReelNO;
        Execute;
      Except
       Exit;
     end;
   end;
end;

procedure TfCMInput.ClearAll1Click(Sender: TObject);
var sPartID :string;
begin
   with QryTemp do
       begin
       try
        //insert
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'RETURNNO',ptInput);
        Params.CreateParam(ftString,'PARTID',ptInput);
        CommandText := 'DELETE FROM  SAJET.G_REEL_WH_IN_TEMP  '+
                       ' WHERE ORDER_NO = :RETURNNO '+
                       ' AND PART_ID = :PARTID ';
        Params.ParamByName('PARTID').AsString :=sPartID;
        Execute;
      Except
       Exit;
     end;
   end;
end;

procedure TfCMInput.sbtnSaveClick(Sender: TObject);
var smemo : string;
begin

   formLotMemo := TformLotMemo.Create(self);
   with formLotMemo do
   begin
     try
       if showmodal<>mrOK then exit;
            //smemo :=editLotMemo.Text;
     finally
       free;
     end;
   end;
   with SProc do
   begin
      try
        Close;
        DataRequest('SAJET.sj_WHIN_SAVE');
        FetchParams;
        Params.ParamByName('TEMPID').AsString := UpdateUserID;
        Execute;
        if Params.ParamByName('TRES').AsString <>'OK' then
        begin
          //MessageDlg(Language.TranslationTextDef(Params.ParamByName('TRES').AsString),mtError,[mbOK],0);
          exit;
        end;
      finally
        Close;
      end;
    end;
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
      //�ӹ��������Ϻ�,Ŀ����,Ͷ������ֵ  add by phoenix    2013-05-09
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
      end
      else
      begin
        ShowMSG('Work Order input : ',iResult,'�п�J�ҥ�!');
        edtModelType.Enabled := True;
        edtModelType.SetFocus;
        edtModelType.Text := '';
        editCarrier.Text := '';
        editCustomer.Text := '';
        gWO := Trim(editWO.Text);
        gCarrierNO := '';
        labWO.Caption := gWO;
        labCarrier.Caption := '';
        //ShowData(gWO,gCarrierNO);
        editWO.Enabled := False;
      end;
    end
    else
    begin
      ShowMSG('Work Order input : ',iResult,'Please input Work order again!');
      editWO.SelectAll;
      editWO.SetFocus;
    end;
  end;
end;

procedure TfCMInput.editCarrierKeyPress(Sender: TObject; var Key: Char);
var iResult,smatchWO:string;
begin
  if Key = #13 then
  begin
    if gWO = '' then
    begin
      editWO.Enabled := True;;
      editWO.SetFocus;
      editWO.Text := '';
      editCarrier.Text := '';
      Exit;
    end;
    iResult := CheckCarrier(Trim(editCarrier.Text),iCarrierSNCount);

    if iResult = 'OK' then
    begin

      with QryTemp do
      begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString,'CARRIER',ptInput);
          CommandText := 'Select  A.MASTER_WO FROM  SAJET.G_WO_BASE A,SAJET.G_SN_STATUS B '+
                       ' WHERE A.WORK_ORDER = B.WORK_ORDER AND B.BOX_NO =:CARRIER AND ROWNUM=1';
          Params.ParamByName('CARRIER').AsString := Trim(editCarrier.Text);
          Open;
          IF NOT QryTemp.IsEmpty THEN begin

            smatchWO := FieldByName('MASTER_WO').AsString;
            if smatchWO <> '' then
                if editWO.Text <> smatchWO then begin
                     msgPanel.Caption :=' CARRIER ���Ӥǰt�u��('+ smatchWO +')';
                     msgPanel.Color :=clRed ;
                     editCarrier.SelectAll;
                     editCarrier.Text:='';
                     exit;
                  end;

               end;
      end;

      //��״̬�����Carrier�Ĺ���  add by phoenix  2013-05-09
      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'Carrier_NO',ptInput);
        CommandText := 'Select DISTINCT WORK_ORDER FROM  SAJET.G_SN_STATUS '+
                       ' WHERE BOX_NO = :Carrier_NO';
        Params.ParamByName('Carrier_NO').AsString := Trim(editCarrier.Text);
        Open;

        labPWO.Caption := FieldByName('WORK_ORDER').AsString;
      end;

      ShowData(gWO,Trim(editCarrier.Text));
      if iSNCount >= iCarrierSNCount then
      begin
        ShowMSG('Carrier No input : ',iResult,'Please input new carrier!');
        editCarrier.Enabled := True;
        editCarrier.Text := '';
        editCarrier.SetFocus;
        gCarrierNO := '';
        //ShowData(gWO,gCarrierNO);     // modify by phoenix 2013-05-09
        labCarrier.Caption := gCarrierNO;
      end else
      begin
        ShowMSG('Carrier No input : ',iResult,'Please input Customer ID!');
        editCustomer.Enabled := True;
        editCustomer.SetFocus;
        editCustomer.Text := '';
        gCarrierNO := Trim(editCarrier.Text);
        labCarrier.Caption := gCarrierNO;
        msgpanel.Color :=clGreen;
        editCarrier.Enabled := False;
      end;
    end
    else
    begin
      ShowMSG('Carrier No input : ',iResult,'Please input Carrier again!');
      editCarrier.SelectAll;
      editCarrier.SetFocus;
      editCarrier.Text := '';
      gCarrierNO := '';
    end;

  end;
end;

procedure TfCMInput.editCustomerKeyPress(Sender: TObject; var Key: Char);
var iResult,wo_LOT,sn_LOT:string;
begin
  if Key = #13 then
  begin
    if gWO = '' then
    begin
      editWO.Enabled := True;
      editWO.SetFocus;
      editWO.Text := '';
      editCarrier.Enabled := True;
      editCarrier.Text := '';
      Exit;
    end;
    if gCarrierNO = '' then
    begin
      editCarrier.Enabled := True;
      editCarrier.SetFocus;
      editCarrier.Text := '';
      editCustomer.Text := '';
      Exit;
    end;
    //�ˬd���~���X�P�O

    wo_LOT  :=   COpy(editWO.Text,10,2);
    SN_LOT :=     Copy(editCustomer.Text,4,2);
    if wo_LOT <> SN_LOT then begin
         msgpanel.Color :=clRed;
         msgpanel.Caption :='���X�P�u��P�O���P';
         editCustomer.Text :='';
         editCustomer.SetFocus;
         exit;

    end;


    //�ͻ���Ź����飬 add by pheonix 2013-5-9
    if CheckCustomerValue <> 'OK' then
    begin
      ShowMSG('Customer ID input : ','Error','CustomerID between 0~Z');
      editCustomer.SetFocus;
      editCustomer.SelectAll;
      Abort;
    end;

    iResult := CheckCustomerRule;
    if  iResult <> 'OK' then
    begin
      ShowMSG('Customer ID input : ','Error','�Ȥ���X���~');
      editCustomer.SetFocus;
      editCustomer.SelectAll;
      Abort;
    end;

    //��鹤��Ͷ��������Ŀ����ʱ,���ü�������Panel��   add by phoenix  2013-5-6
    if StrtoInt(labInputQty.Caption) >= StrToInt(labTargetQty.Caption) then
    begin
      ShowMSG('Customer ID input : ','Error','�u���J�Ƥj��u���`��!');
      editWO.Enabled := True;
      editWO.SetFocus;
      editWO.SelectAll;
      Abort;
    end;

    iResult := CheckCustomer(iTerminal,UpdateUserID,gWO,gCarrierNO,Trim(editCustomer.Text));
    if iResult = 'OK' then
    begin
      ShowMSG('Customer No input : ',iResult,'Please input new Customer No!');
      editCustomer.SetFocus;
      editCustomer.Text:='';
      ShowData(gWO,gCarrierNO);

      //����ȡ�ù�����Ͷ����  add by phoenix    2013-05-09
      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WO',ptInput);
        CommandText := 'Select INPUT_QTY FROM  SAJET.G_WO_BASE '
                     + ' WHERE WORK_ORDER = :WO';
        Params.ParamByName('WO').AsString := Trim(editWO.Text);
        Open;

        labInputQty.Caption := FieldByName('INPUT_QTY').AsString;
      end;

      if iSNCount  >= iCarrierSNCount then
      begin
        ShowMSG('Customer No input : ',iResult,'Please input new Carrier No!');
        RemoveCarrier(gCarrierNO);
        editCarrier.Enabled := True;
        editCarrier.SetFocus;
        editCarrier.Text := '';
        labCarrier.Caption := '';
        gCarrierNO := '';
        ShowData(gWO,gCarrierNO);
        labSNCount.Caption := '';
      end;
    end
    else
    begin
      ShowMSG('Customer No input : ',iResult,'');
      editCustomer.SetFocus;
      editCustomer.SelectAll;
    end;
  end;
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

procedure TfCMInput.labCarrierDblClick(Sender: TObject);
begin
  if not editCarrier.Enabled then
  begin
    editCarrier.Enabled := True;
    editCarrier.SelectAll;
    editCarrier.SetFocus;
  end else
  begin
    editCarrier.Enabled := False;
  end;
end;

function TfCMInput.CheckCustomerRule: string;
begin
  try
    Result := 'Check CustomerID Rule Error';
    with SProc do
    begin
      try
        Close;
        DataRequest('SAJET.Sj_CM_INPUT_Chk_Rule');
        FetchParams;
        Params.ParamByName('TPART_NO').AsString := labPartNo.Caption;
        Params.ParamByName('TSN').AsString := trim(editCustomer.Text);
        Execute;
        Result := Params.ParamByName('TRES').AsString;
      finally
        Close;
      end;
    end;
  except on e:Exception do
  begin
    Result := '�Ȥ���X�W�h���~ : ' + e.Message;
  end;
end;
end;

function TfCMInput.CheckCustomerValue: string;
var
  i,vLength: integer;
  sValue,vChar: string;
begin
  sValue := trim(editCustomer.Text);
  vLength := length(sValue);
  for i := 1 to vLength do
  begin
    vChar := copy(sValue,i,1);
    if ((vChar >= '0') and (vChar <= '9')) or ((vChar >= 'A') and (vChar <= 'Z')) then
      Result := 'OK'
    else
    begin
      Result := 'Error';
      Exit;
    end;
  end;
end;

procedure TfCMInput.edtModelTypeKeyPress(Sender: TObject; var Key: Char);
begin
    if edtModelType.Text ='' then exit;
    if Key <> #13 then exit;
    ShowMSG('Work Order input : ','OK','�п�JCarrier ���X!');
    editCarrier.Enabled := True;
    editCarrier.SetFocus;
    editCarrier.Text := '';
    editCustomer.Text := '';
    gWO := Trim(editWO.Text);
    gCarrierNO := '';
    labCarrier.Caption := '';
    
end;

end.
