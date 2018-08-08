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
    editPanel: TEdit;
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
    lblQty: TLabel;
    lblInput: TLabel;
    lbl1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure editPanelKeyPress(Sender: TObject; var Key: Char);
    procedure editCustomerKeyPress(Sender: TObject; var Key: Char);
    procedure Label4DblClick(Sender: TObject);
    procedure editWOKeyPress(Sender: TObject; var Key: Char);
  private
    //m_SNDefectLevel: String;
    procedure clearData;

    function CheckCarrier(sCarrier:string;var iCarrierCount:Integer):string;
    function CheckCustomerRule: string;      //检查Customer字符规则,第一码,长度等
    function CheckCustomerValue: string;    //检查Customer字符是否在0~Z之间

    function GetTerminalName(sTerminalID:string):string;

    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
    procedure RemoveCarrier(sCarrier:string);


    function GetPartID(partno :String) :String;
    procedure ShowData(sCarrier :String);
  public
    UpdateUserID,sPartID : String;
    iInput,iTarget :Integer;
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

uses uformLotMemo;


{$R *.dfm}

function TfMainForm.GetTerminalName(sTerminalID:string):string;
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

function TfMainForm.CheckCarrier(sCarrier:string;var iCarrierCount:Integer):string;
begin
try
  Result := 'Check Carrier Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.CCM_COB_CHK_PANEL_INPUT');
      FetchParams;
      Params.ParamByName('TWO').AsString := editWO.Text;
      Params.ParamByName('TPANEL').AsString := editPanel.Text;
      Params.ParamByName('TTERMINALID').AsString := iTerminal;
      Execute;
      iCarrierSNCount := Params.ParamByName('TPANELQTY').AsInteger;
      iSNCount := Params.ParamByName('TREMIANQTY').AsInteger;
      sPartID :=   Params.ParamByName('TMODELID').AsString;
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
if editPanel.Text ='' then exit;
try
  with Qrytemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString,'Carrier',ptInput);
    CommandText :='update SAJET.g_sn_status set box_no = ''N/A'',CARTON_NO=''N/A'' WHERE box_no= :Carrier ' ;
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

  editWO.SetFocus;
  editPanel.ReadOnly :=true;
  editCUstomer.ReadOnly :=true;
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

procedure TfMainForm.editPanelKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
  if Key = #13 then
  begin
      iResult := CheckCarrier(editPanel.Text,iCarrierSNCount);
      Label1.Caption := IntTOStr(iSNCOunt)+'/'+IntToStr(iCarrierSNCount);
      if iResult <>'OK' then begin
          ShowMsg('ERROR',iResult,'');
          editPanel.SetFocus;
          editPanel.Text :='';
          exit;
      end;
      if  ICarrierSNCOunt =0 then  begin
          ShowMsg('ERR->','NO Panel','');
          editPanel.SetFocus;
          editPanel.Text :='';
          exit;
      end;
      msgPanel.Caption := 'OK->Please Input SN';
      msgPanel.Color :=clGreen;
      
      if iSNCOUnt = ICarrierSNCOunt then begin
          ShowMsg('','OK','');
          editPanel.SetFocus;
          editPanel.Text :='';
          exit;
      end;
      editCustomer.SetFocus;
      editCustomer.Clear;
      editPanel.Enabled:=false;
      editCustomer.ReadOnly := false;
  end;
end;

procedure TfMainForm.editCustomerKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
    iqty:integer;
begin
  if Key <> #13 then exit;
  iResult:=  CheckCustomerRule;
  if iResult <> 'OK' then begin
        ShowMsg('岿粇',iResult,'');
        editCustomer.Setfocus;
        editCustomer.SelectAll;
        exit;
  end;

  iResult :=CheckCustomerValue;
  if iResult <> 'OK' then begin
        ShowMsg('岿粇','め兵絏砏玥岿粇','');
        editCustomer.Setfocus;
        editCustomer.SelectAll;
        exit;
  end;

  sproc.Close;
  sproc.DataRequest('SAJET.CCM_COB_PANEL_SN_INPUT');
  sproc.FetchParams;
  sproc.Params.ParamByName('TWO').AsString := editWO.Text;
  sproc.Params.ParamByName('TPANEL').AsString := editPanel.Text;
  sproc.Params.ParamByName('TSN').AsString :=UpperCase(Trim(editCustomer.Text));
  sproc.Params.ParamByName('TEMPID').AsString :=UpdateUserID;
  sproc.Params.ParamByName('TTERMINALID').AsString :=iterminal;
  sproc.Execute;

  iResult := sproc.Params.parambyname('TRES').AsString;

  if iResult <> 'OK' then begin
        ShowMsg('岿粇',iResult,'');
        editCustomer.Setfocus;
        editCustomer.SelectAll;
        exit;
  end;
  ShowData(editPanel.Text);
  iSNCOunt := iSNCOunt+1;
  Label1.Caption :=  InttoStr(iSNCOunt)+'/' +  InttoStr(iCarrierSNCOunt) ;
  editCustomer.SetFocus;
  editCustomer.Text :='';
  ShowMsg('OK',iResult,'');

  QryTemp.Close;
  QryTemp.Params.Clear;
  QryTEmp.Params.CreateParam(ftString,'WO',ptInput);
  QryTemp.CommandText :='Select Input_qty From sajet.g_WO_BASE WHEREWORK_ORDER=:WO';
  QryTemp.Params.ParamByName('WO').AsString := editWo.Text;
  QryTemp.Open;

  lblInput.caption := QryTemp.FieldbyName('Input_QTY').AsString;

  if iSNCount>=iCarrierSNCOunt then   begin
    RemoveCarrier(editPanel.Text);
    editPanel.Clear;
    editPanel.Enabled :=true;
    editPanel.SetFocus;
    editCustomer.Clear;
    editCustomer.ReadOnly :=true;
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
    Result := 'め兵絏砏玥岿粇 : ' + e.Message;
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
    if ((vChar >= '0') and (vChar <= '9')) or ((vChar >= 'A') and (vChar <= 'Z')) or (vChar >= '-') then
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
    editPanel.Clear;
    editPanel.Enabled :=true;
    editPanel.SetFocus;
    editCustomer.Clear;
    Label1.Caption :='0/0';
end;

procedure TfMainForm.editWOKeyPress(Sender: TObject; var Key: Char);
var rsvStr:string;
begin
    //
    if editWO.Text = '' then exit;
    if Key <> #13 then exit;
    Sproc.Close;
    Sproc.DataRequest('SAJET.SJ_CHK_WO_INPUT');
    Sproc.FetchParams;
    Sproc.Params.ParamByName('TREV').AsString := editWO.Text;
    Sproc.Execute;
    rsvStr := Sproc.Params.parambyname('TRES').AsString ;

    if  rsvStr <>'OK' then begin
         msgPanel.Caption :=rsvStr;
         msgPanel.Color :=clred;
         editWO.SelectAll;
         editWO.SetFocus;
    end else begin
     Qrytemp.Close;
     Qrytemp.Params.Clear;
     Qrytemp.Params.CreateParam(ftstring,'WO',ptinput) ;
     Qrytemp.CommandText :='select Target_QTY,Input_Qty from sajet.g_wo_Base '+
         ' where Work_order =:WO';
     Qrytemp.Params.ParamByName('WO').AsString :=editwo.Text;
     Qrytemp.Open;
     iInput := QryTemp.fieldByname('input_QTY').AsInteger  ;
     iTarget :=  QryTemp.fieldByname('Target_QTY').AsInteger ;
     lblQty.caption := '虫羆计:'+ IntToStr(iTarget);
     lblInput.caption :='щ计:'+IntToStr(iInput);

      msgPanel.Caption :='WO OK->Please Input Panel';
      msgPanel.Color :=clGreen;
      editWO.Enabled :=false;
      editPanel.SetFocus;
      editPanel.SelectAll;
      editPanel.ReadOnly :=false;
    end;

    
end;

end.
