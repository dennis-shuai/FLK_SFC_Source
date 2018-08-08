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
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    editWO: TEdit;
    editCustomer: TEdit;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    labWO: TLabel;
    Label1: TLabel;
    labPartNo: TLabel;
    Label7: TLabel;
    labTargetQty: TLabel;
    Label8: TLabel;
    labInputQty: TLabel;
    DBGrid1: TDBGrid;
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure editDataKeyPress(Sender: TObject; var Key: Char);
    procedure Cancel1Click(Sender: TObject);
    procedure ClearAll1Click(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure editWOKeyPress(Sender: TObject; var Key: Char);
    procedure editCustomerKeyPress(Sender: TObject; var Key: Char);
    procedure labWODblClick(Sender: TObject);
  private
    //m_SNDefectLevel: String;
    procedure clearData;
    function CheckWO(sWO:string):string;
    function CheckCarrier(sCarrier:string;var iCarrierCount:Integer):string;
    function CheckCustomer(sTerminal,sEmp,sWO,sCarrier,sCustomer:string):string;
    function CheckCustomerRule: string;      //检查Customer字符规则,第一码,长度等
    function CheckCustomerValue: string;    //检查Customer字符是否在0~Z之间

    function GetTerminalName(sTerminalID:string):string;

    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
    procedure RemoveCarrier(sCarrier:string);


    function GetPartID(partno :String) :String;
    procedure ShowData(sWO,sCarrier :String);
  public
    UpdateUserID ,sEMP_NO,sPDlineID,sStageID,sProcessID: String;
    Authoritys,AuthorityRole,FunctionName : String;
    //Language : TLanguage;
    procedure SetStatusbyAuthority;
    Function LoadApServer : Boolean;
    function getEMPNo:string;
    procedure GetPlace;
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
begin

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
  labWO.Caption := '';
  iCarrierSNCount := 0;

  sEMP_NO :=GetEMPNO;
  GetPlace;
  labTerminal.Caption :='TERMINAL:    '+ GetTerminalName(iTerminal);

end;

procedure TfCMInput.clearData;
begin
end;

procedure TfCMInput.GetPlace;
begin
  Sproc.Close;
  Sproc.DataRequest('SAJET.SJ_GET_PLACE');
  SProc.FetchParams;
  Sproc.Params.ParamByName('tterminalid').AsString:=iTerminal;
  Sproc.Execute;

  sPdlineID := Sproc.Params.ParamByName('pline').AsString;
  sStageID := Sproc.Params.ParamByName('pstage').AsString;
  sProcessID := Sproc.Params.ParamByName('pprocess').AsString;


end;

function TfCMInput.getEMPNo:string;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText :=  ' SELECT EMP_NO FROM SAJET.SYS_EMP WHERE EMP_ID ='+UPDATEUSERID  ;
    Open;
    result :=fieldbyname('EMP_NO').AsString;

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
      //从工单带出料号,目标量,投入量等值  add by phoenix    2013-05-09
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
        ShowMSG('Work Order input : ',iResult,'叫块兵絏!');
        editCustomer.Text := '';
        editCustomer.SetFocus;
        gWO := Trim(editWO.Text);
        labWO.Caption := gWO;
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

procedure TfCMInput.editCustomerKeyPress(Sender: TObject; var Key: Char);
var iResult,sMatchWO,wo_LOT,sn_LOT:string;
begin
  if  Key <>#13 then exit;
  if  editCustomer.Text ='' then exit;

   Sproc.Close;
   Sproc.DataRequest('SAJET.CCM_CHK_COB_CSN_INPUT');
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TWO').AsString := editWO.Text ;
   Sproc.Params.ParamByName('TSN').AsString := editCustomer.Text;
   Sproc.Params.ParamByName('TEMPID').AsString := UPDATEUSERID;
   Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal ;
   Sproc.Execute;

   iResult := Sproc.Params.ParamByName('TRES').AsString;
   
   if iResult <> 'OK' then begin
       editCustomer.Text :='';
       editCustomer.Setfocus;
       msgpanel.Caption :=iResult;
       msgPanel.Color :=clRed;
       exit;
   end;

   msgpanel.Caption :=iResult;
   msgPanel.Color :=clGreen;
   editCustomer.Text :='';
   editCustomer.Setfocus;
   Qrytemp.close;
   QryTEmp.Params.Clear;
   QryTEmp.Params.CreateParam(ftString,'WO',ptInput);
   QryTemp.CommandText :='Select Input_QTY from sajet.g_WO_BASE where WORK_ORDER =:WO';
   QryTemp.Params.ParamByName('WO').AsString :=editWO.Text;
   QryTemp.Open;

   labInputQty.Caption :=  QryTEmp.fieldbyname('INPUT_QTY').AsString;
   
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
    Result := 'め兵絏砏玥岿粇 : ' + e.Message;
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

end.
