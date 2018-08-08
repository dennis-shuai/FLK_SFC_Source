unit uCMVI;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles;

type
  TfCMVI = class(TForm)
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
    DBGrid1: TDBGrid;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    labSNCount: TLabel;
    labWO: TLabel;
    Label1: TLabel;
    labPartNo: TLabel;
    labTargetQty: TLabel;
    labInputQty: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    miScrap: TMenuItem;
    Image1: TImage;
    btnClose: TSpeedButton;
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure editWOKeyPress(Sender: TObject; var Key: Char);
    procedure editCustomerKeyPress(Sender: TObject; var Key: Char);
    procedure labWODblClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    //m_SNDefectLevel: String;
    
    function CheckWO(sWO:string):string;
    function CheckCSN:string;

    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);

    function GetTerminalName(sTerminalID:string):string;


    function GetPartID(partno :String) :String;
    procedure ShowData;
  public
    UpdateUserID : String;
    Authoritys,AuthorityRole,FunctionName : String;
    //Language : TLanguage;
    procedure SetStatusbyAuthority;
    Function LoadApServer : Boolean;
  end;

var
  fCMVI: TfCMVI;
  flag:Boolean;
  emess:string;
  //gWO,gTrayNO:string;
  VICount:Integer;
  iTerminal:string;

implementation

{$R *.dfm}


function TfCMVI.CheckWO(sWO:string):string;
  procedure CallProcedure(WO: String);
  begin
    with SProc do
    begin
      try
        SProc.Close;
        SProc.DataRequest('SAJET.Sj_Chk_Wo_Input');
        SProc.FetchParams;
        SProc.Params.ParamByName('TREV').AsString := WO;
        SProc.Execute;
        Result := SProc.Params.ParamByName('TRES').AsString;
      finally
        SProc.Close;
      end;
    end;
  end;

begin
  try
    Result := 'Check WO Error';
    //先检查工单号，如果不正确，再检查CSN
    CallProcedure(trim(editWO.Text));

    //检查工单错误，再检查是否是CSN，如果是CSN则再取得关联WO，并检查
    if Result <> 'OK' then
    begin
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString,'CSN',ptInput);
      QryTemp.CommandText := 'Select work_order from sajet.g_sn_status '
                           + ' where CUSTOMER_SN = :CSN ';
                           //+ '   and RowNum = 1';
      QryTemp.Params.ParamByName('CSN').AsString := Trim(editWO.Text);
      QryTemp.Open;
      if QryTemp.RecordCount > 0 then
      begin
         labWO.Caption := QryTemp.Fieldbyname('work_order').AsString;
         editWO.Text := labWO.Caption;
      end
      else
         labWO.Caption := '';

      if labWO.Caption <> '' then
      begin
        CallProcedure(labWO.Caption);
      end;
    end;

  except on e:Exception do
    begin
      Result := 'Check WO error : ' + e.Message;
    end;
  end;
end;

function TfCMVI.CheckCSN:string;
begin
  try
    Result := 'Check Customer SN Error';
    //检验Customer_SN
    with SProc do
    begin
      try
        Close;
        DataRequest('Sajet.SJ_CM_Customer_Batch');
        FetchParams;
        Params.ParamByName('TWO').AsString := trim(editWO.Text);
        Params.ParamByName('TERMINALID').AsString := iTerminal;
        Params.ParamByName('TREV').AsString := trim(editCustomer.Text);
        Params.ParamByName('TEMP').AsString := UpdateUserID;
        Execute;
        Result := Params.ParamByName('TRES').AsString;
      finally
        Close;
      end;
    end;
  except on e:Exception do
    begin
      Result := 'Check Customer SN Error : ' + e.Message;
    end;
  end;
end;

function TfCMVI.GetTerminalName(sTerminalID:string):string;
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

procedure TfCMVI.ShowMSG(sShowHead,sShowResult,sNextMsg:string);
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

function TfCMVI.GetPartID(partno :String) :String;
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

procedure TfCMVI.ShowData;
begin
  With QryData do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString,'WO',ptInput);
     Params.CreateParam(ftString,'TERMINAL',ptInput);
     CommandText := 'SELECT A.WORK_ORDER,A.BOX_NO,A.serial_number,A.Customer_SN,A.in_process_time '+
                    '  FROM SAJET.g_sn_status A '+
                    ' WHERE A.WORK_ORDER = :WO '+
                    '   AND A.CARTON_NO = :TERMINAL '+
                    '   AND A.WORK_FLAG=''0'' '+     //只显示正常过站的，报废的不显示
                    '   AND A.CURRENT_STATUS = ''0'' '+
                    ' ORDER BY A.in_process_time desc';
     Params.ParamByName('WO').AsString := trim(editWO.Text);
     Params.ParamByName('TERMINAL').AsString := iTerminal;
     Open;
     labSNCount.Caption := IntToStr(RecordCount) + ' / ' + InttoStr(VICount);
     if RecordCount >= VICount then
     begin
       MessageDlg('VICount Over, Please Close first',mtWarning,[mbOK],0);
     end;
     if RecordCount > 0 then
       btnClose.Enabled := True
     else
       btnClose.Enabled := False;
  end;
end;

procedure TfCMVI.FormShow(Sender: TObject);
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
  labSNCount.Caption := '';
  //ShowMessage(IntToStr(iTraySNCount));

  btnClose.Enabled := False;
end;

Procedure TfCMVI.SetStatusbyAuthority;
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
    Params.ParamByName('PRG').AsString := 'COB';
    Params.ParamByName('FUN').AsString := 'COB INPUT';
    Open;
    If RecordCount > 0 Then
      Authoritys := Fieldbyname('AUTHORITYS').AsString;
    Close;
  end;

  //sbtnSave.Enabled := ((Authoritys = 'Allow To Execute') or (Authoritys = 'Full Control'));
  miScrap.Enabled := (Authoritys = 'Full Control');
  
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
      Params.ParamByName('PRG').AsString := 'COB';//'Quality Control';
      Params.ParamByName('FUN').AsString := 'COB INPUT';
      Open;
      If RecordCount > 0 Then
        AuthorityRole := Fieldbyname('AUTHORITYS').AsString;
      Close;
    end;
    //sbtnSave.Enabled := ((AuthorityRole = 'Allow To Execute') or (AuthorityRole = 'Full Control'));
    miScrap.Enabled := (AuthorityRole = 'Full Control');
    if miScrap.Enabled then
      miScrap.Tag := 0
    else
      miScrap.Tag := 1;
  end;


end;


Function TfCMVI.LoadApServer : Boolean;
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

procedure TfCMVI.Image2Click(Sender: TObject);
begin
   Close;
end;

procedure TfCMVI.editWOKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
  if Trim(editWO.Text) = '' then
    exit;
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
      //从工单带出料号,目标量,投入量等值
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

      ShowMSG('Work Order input : ',iResult,'Please input Customer SN!');
      editCustomer.Enabled := True;
      editCustomer.SetFocus;
      editCustomer.Text := '';
      labWO.Caption := Trim(editWO.Text);
      editWO.Enabled := False;
    end
    else
    begin
      ShowMSG('Work Order input : ',iResult,'Please input Work order again!');
      editCustomer.Enabled := False;
      editCustomer.Text := '';
      editWO.SelectAll;
      editWO.SetFocus;
    end;
    ShowData;
  end;
end;

procedure TfCMVI.editCustomerKeyPress(Sender: TObject; var Key: Char);
var
  iResult:string;
  CSNCount: integer;
begin
  if Trim(editCustomer.Text) = '' then
    exit; 
  if Key = #13 then
  begin
    if trim(editWO.Text) = '' then
    begin
      editWO.Enabled := True;
      editWO.SetFocus;
      editWO.Text := '';
      Exit;
    end;

    //检查工单.CSN量大于批结量时,不让继续输入Customer号
    if QryData.RecordCount + 1 > VICount then
    begin
      ShowMSG('Customer SN input : ','Error','CM_VI Count Over');
      //btnClose.SetFocus;
      Abort;
    end;

    iResult := CheckCSN;

    if iResult = 'OK' then
    begin
      ShowMSG('Customer SN input : ',iResult,'Please input new Customer SN!');
      ShowData;
      QryData.Locate('Customer_SN',Trim(editCustomer.Text),[]);
      editCustomer.SetFocus;
      editCustomer.Text:='';
    end
    else
    begin
      ShowMSG('Customer SN input : ',iResult,'');
      editCustomer.SetFocus;
      editCustomer.SelectAll;
    end;
  end;
end;

procedure TfCMVI.labWODblClick(Sender: TObject);
begin
  if not editWO.Enabled then
  begin
    editWO.Enabled := True;
    editWO.SelectAll;
    editWO.SetFocus;

    btnClose.Enabled := False;
  end
  else
  begin
    editWO.Enabled := False;
  end;
end;

procedure TfCMVI.btnCloseClick(Sender: TObject);
var
  iResult: String;
begin
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CM_Customer_Close');
      FetchParams;
      Params.ParamByName('TWO').AsString := trim(editWO.Text);
      Params.ParamByName('TEMP').AsString := UpdateUserID;
      Params.ParamByName('TERMINALID').AsString := iTerminal;
      Execute;
      iResult := Params.ParamByName('TRES').AsString;
    finally
      Close;
    end;
  end;
  if Copy(iResult,1,2) <> 'OK' then
    ShowMSG('Close Error : ',iResult,'')
  else
  begin
    ShowMSG('Close Complete ','OK',iResult);
    ShowData;
    btnClose.Enabled  := false;
  end;
  editCustomer.Enabled := True;
  editCustomer.SetFocus;
end;

end.
