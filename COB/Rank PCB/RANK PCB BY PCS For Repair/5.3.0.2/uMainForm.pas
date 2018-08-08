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
    editCarrier: TEdit;
    editCustomer: TEdit;
    DBGrid1: TDBGrid;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    labInputQty: TLabel;
    ImageAll: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label1: TLabel;
    Label5: TLabel;
    editWO: TEdit;
    Label6: TLabel;
    cmbProcess: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure editCarrierKeyPress(Sender: TObject; var Key: Char);
    procedure editCustomerKeyPress(Sender: TObject; var Key: Char);
    procedure Label4DblClick(Sender: TObject);
    procedure editWOKeyPress(Sender: TObject; var Key: Char);
    procedure cmbProcessSelect(Sender: TObject);
  private
    //m_SNDefectLevel: String;
    procedure clearData;


    function CheckCustomerRule: string;      //潰脤Customer趼睫寞寀,菴珨鎢,酗僅脹
    function CheckCustomerValue: string;    //潰脤Customer趼睫岆瘁婓0~Z眳潔

    function GetTerminalName(sTerminalID:string):string;

    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
    procedure RemoveCarrier(sCarrier:string);


    function GetPartID(partno :String) :String;
    procedure ShowData(sCarrier :String);
  public
    UpdateUserID,sPartID : String;
    sPdline,sProcess,sTerminal,sNextProcess:string;
    Authoritys,AuthorityRole,FunctionName : String;
    //Language : TLanguage;
    procedure SetStatusbyAuthority;
    //Function LoadApServer : Boolean;
  end;

var
  fMainForm: TfMainForm;
  gWO,gCarrierNO:string;
  iCarrierSNCount,iSNCount:Integer;
  iTerminal:string;

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

procedure TfMainForm.RemoveCarrier(sCarrier:string);
begin
if editCarrier.Text ='' then exit;
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

function TfMainForm.GetPartID(partno :String) :String;
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

procedure TfMainForm.ShowData(sCarrier :String);
begin

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

    end;
end;

procedure TfMainForm.FormShow(Sender: TObject);
Var DestRect,SurcRect : TRect; Bmp : TBitmap;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;

  Bmp.Free;

  //LoadApServer;
  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;

  LabTerminal.Caption := LabTerminal.Caption + '    ' + GetTerminalName(iTerminal);

end;

procedure TfMainForm.clearData;
begin
end;
 

Procedure TfMainForm.SetStatusbyAuthority;
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

 {
Function TfMainForm.LoadApServer : Boolean;
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
 }
procedure TfMainForm.editCarrierKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
    if Key <> #13 then exit;
    if Length(editCarrier.Text) =0 then exit;

    
    if  iCarrierSNCOunt = 0 then
    begin
        ShowMsg('ERROR','Carrier 數量沒有設置','');
        editCarrier.SetFocus;
        editCarrier.Text :='';
        exit ;
    end;

    Sproc.Close;
    Sproc.DataRequest('SAJET.CCM_CHK_REPAIR_RANKPCS_Carrier');
    Sproc.FetchParams;
    Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal;
    Sproc.Params.ParamByName('TREV').AsString :=editCarrier.Text;
    Sproc.Params.ParamByName('TPROCESS').AsString :=sNextProcess;
    Sproc.Params.ParamByName('TWO').AsString :=editWO.Text;
    Sproc.execute;

    iResult:=  Sproc.Params.paramByName('TRES').AsString ;

    if  iResult <> 'OK' then
    begin
        ShowMsg('ERROR',iResult,'');
        editCarrier.SetFocus;
        editCarrier.Text :='';
        exit ;
    end;

    iSNCount := Sproc.Params.paramByName('TCARRIERCOUNT').AsInteger;

    Label1.Caption := IntToStr(iSNCount)+'/'+IntToStr(iCarrierSNCount);
    ShowData(editCarrier.text);
     if iSNCOUnt = ICarrierSNCOunt then begin
        ShowMsg('','OK','');
        editCarrier.SetFocus;
        editCarrier.Text :='';
        editCarrier.Enabled :=true;
        exit;
    end;
    //ShowData(editCarrier.Text);
    ShowMsg('','OK','');
    editCustomer.ReadOnly :=false;
    editCustomer.SetFocus;
    editCustomer.Clear;
    editCarrier.Enabled:=false;

end;

procedure TfMainForm.editCustomerKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
    iqty:integer;
begin
  if Key <> #13 then exit;

  iResult :=CheckCustomerValue;
  if iResult <> 'OK' then begin
        ShowMsg('錯誤','客戶條碼規則錯誤','');
        editCustomer.Setfocus;
        editCustomer.SelectAll;
        exit;
  end;

  sproc.Close;
  sproc.DataRequest('SAJET.CCM_COB_Repair_RankPCS_Carrier');
  sproc.FetchParams;
  sproc.Params.ParamByName('TWO').AsString := editWO.Text;
  sproc.Params.ParamByName('TCARRIER').AsString := editCarrier.Text;
  sproc.Params.ParamByName('TSN').AsString :=editCustomer.Text;
  sproc.Params.ParamByName('TTERMINALID').AsString :=iterminal;
  sproc.Params.ParamByName('TEMPID').AsString :=UpdateUserID;
  sproc.Params.ParamByName('TPROCESS').AsString :=sNextProcess;
  sproc.Execute;

  iResult := sproc.Params.parambyname('TRES').AsString;

  if iResult <> 'OK' then begin
        ShowMsg('錯誤',iResult,'');
        editCustomer.Setfocus;
        editCustomer.SelectAll;
        exit;
  end;
  ShowData(editCarrier.Text);
  iSNCOunt := iSNCOunt+1;
  Label1.Caption :=  InttoStr(iSNCOunt)+'/' +  InttoStr(iCarrierSNCOunt) ;
  editCustomer.SetFocus;
  editCustomer.Text :='';
  ShowMsg('OK',iResult,'');
  if iSNCount>=iCarrierSNCOunt then   begin
    //   RemoveCarrier(editCarrier.Text);
    editCarrier.Clear;
    editCarrier.Enabled :=true;
    editCarrier.SetFocus;
    editCustomer.Clear;
    Label1.Caption :='0/0';
  end;


end;

function TfMainForm.CheckCustomerRule: string;
begin
  try
    Result := 'Check CustomerID Rule Error';
    with SProc do
    begin
      try
        Close;
        DataRequest('SAJET.SJ_CHK_KP_RULE');
        FetchParams;
        Params.ParamByName('ITEM_PART_ID').AsString := sPartID;
        Params.ParamByName('ITEM_PART_SN').AsString := trim(editCustomer.Text);
        Execute;
        Result := Params.ParamByName('TRES').AsString;
      finally
        Close;
      end;
    end;
  except on e:Exception do
  begin
    Result := '客戶條碼規則錯誤 : ' + e.Message;
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

procedure TfMainForm.Label4DblClick(Sender: TObject);
begin
    //RemoveCarrier(editCarrier.Text);
    editCarrier.Clear;
    editCarrier.Enabled :=true;
    editCarrier.SetFocus;
    editCustomer.Clear;
    Label1.Caption :='0/0';
end;

procedure TfMainForm.editWOKeyPress(Sender: TObject; var Key: Char);
var iResult,sRoute:string;
begin
  if Key <> #13 then exit;
  if cmbProcess.ItemIndex <0 then begin
      msgpanel.Caption :='請選擇下一站';
      msgpanel.Color :=clRed;
      exit;
  end;
  
  QryTemp.Close;
  QryTemp.Params.Clear;
  QryTemp.Params.CreateParam(ftstring,'SN',ptInput);
  QryTemp.CommandText := 'Select WORK_ORDER FROM SAJET.G_SN_STATUS WHERE CUSTOMER_SN =:SN';
  Qrytemp.Params.ParamByName('SN').AsString :=editWO.Text;
  QryTemp.Open;
  if not QryTEmp.IsEmpty then begin
     editWO.Text :=QryTEmp.fieldbyname('WORK_ORDER').AsString;
  end;

  Sproc.Close;
  Sproc.DataRequest('SAJET.SJ_CHK_WO_INPUT');
  Sproc.FetchParams;
  Sproc.Params.ParamByName('TREV').AsString :=editWO.Text;
  Sproc.Execute;
  iResult := Sproc.Params.parambyname('TRES').asstring ;

  if  iResult<> 'OK' then begin
       editCarrier.Text :='';
       editCustomer.Text :='';
       editCarrier.ReadOnly :=false;
       editCustomer.ReadOnly :=false;
       editWO.SelectAll;
       editWO.SetFocus;
       msgPanel.Caption := iResult;
       msgPanel.Color :=clRed;
       exit;
  end;


  with qrytemp do begin
      Close;
      Params.Clear;
      Params.CreateParam(ftstring,'WO',ptInput);
      CommandText := ' SELECT ROUTE_ID FROM SAJET.G_WO_BASE WHERE WORK_ORDER =:WO ';
      Params.ParamByName('WO').AsString :=editWO.Text;
      Open;
      if IsEmpty then begin
         msgPanel.Caption := '工單沒有設置流程';
         msgPanel.Color :=clRed;
         exit;
      end;
      sRoute := fieldbyName('ROUTE_ID').AsString;

      Close;
      Params.Clear;
      Params.CreateParam(ftstring,'PROCESS',ptInput);
      Params.CreateParam(ftstring,'route',ptInput);
      CommandText := ' SELECT * FROM SAJET.sys_route_detail a ,sajet.sys_process b ' +
                     ' WHERE  a.NEXT_PROCESS_ID =b.PROCESS_ID AND B.PROCESS_NAME =:PROCESS  '+
                     ' AND A.ROUTE_ID = :ROUTE';
      Params.ParamByName('PROCESS').AsString :=sNextProcess;
      Params.ParamByName('ROUTE').AsString :=sRoute;
      Open;
      if IsEmpty then begin
          msgPanel.Caption := '工單中沒有該站,請重新選擇下一站';
          msgPanel.Color :=clRed;
         exit;
      end;


      Close;
      Params.Clear;
      Params.CreateParam(ftstring,'WO',ptInput);
      CommandText := ' SELECT NVL(OPTION4,0) CarrierCount FROM SAJET.SYS_PART WHERE PART_ID =(SELECT MODEL_ID '+
                     ' FROM SAJET.G_WO_BASE WHERE WORK_ORDER=:WO )';
      Params.ParamByName('WO').AsString :=editWO.Text;
      Open;

      iCarrierSNCount := fieldbyName('CarrierCount').AsInteger;

  end;

  editCarrier.Enabled :=true;
  editCarrier.SetFocus;
  editCarrier.SelectAll;
  editCarrier.ReadOnly :=false;
  msgPanel.Caption := 'Please Input SN';
  msgPanel.Color :=clGreen;
  editWO.Enabled :=false;
  

end;

procedure TfMainForm.cmbProcessSelect(Sender: TObject);
begin
  // if cmbProcess.ItemIndex =2 then exit;
   if cmbProcess.ItemIndex <0 then exit;
   if cmbProcess.ItemIndex =0 then
     sNextProcess :='DIE BOND';
   if cmbProcess.ItemIndex =1 then
     sNextProcess :='WB-VI';
   if cmbProcess.ItemIndex =2 then
     sNextProcess :='HODLE MOUNT';
   if cmbProcess.ItemIndex =3 then
     sNextProcess :='COB-CUBIC';
   if cmbProcess.ItemIndex =4 then
     sNextProcess :='HODLE MOUNT2';
   editwo.Enabled :=true;
   editwo.Text :='';
   editwo.SetFocus;

end;

end.
