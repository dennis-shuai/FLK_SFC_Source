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
    LabTerminal: TLabel;
    Label2: TLabel;
    ImageAll: TImage;
    cmbReason: TComboBox;
    msgPanel: TPanel;
    Label1: TLabel;
    cmbTerminal: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure editCarrierKeyPress(Sender: TObject; var Key: Char);
    procedure cmbReasonSelect(Sender: TObject);
    procedure cmbTerminalSelect(Sender: TObject);
  private
    //m_SNDefectLevel: String;
    
    function GetTerminalName(sTerminalID:string):string;
    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);

    function GetPartID(partno :String) :String;
    procedure ShowData(sCarrier :String);
  public
    UpdateUserID,sPartID ,sDefect: String;
    sPdline,sProcess,sTerminal:string;
    Authoritys,AuthorityRole,FunctionName : String;
    sDefectID,sDefectCode:String;
    procedure SetStatusbyAuthority;
    function  GetSysDate:TDatetime;
    function GetEMPNO:string;
  end;

var
  fMainForm: TfMainForm;
  gWO,gCarrierNO:string;
  iCarrierSNCount,iSNCount:Integer;
  IsInputSN:boolean;
  iTerminal:string;

implementation


{$R *.dfm}
function  TfMainForm.GetSysDate:TDatetime;
begin
   with Qrytemp do
   begin
      Close;
      Params.Clear;
      commandText := 'select sysdate iDate from dual';
      open;
   end;

   result :=  Qrytemp.fieldbyName('iDate').asdatetime;
end;

function  TfMainForm.GetEMPNO:string;
begin
   with Qrytemp do
   begin
      Close;
      Params.Clear;
      commandText := 'select emp_no from sajet.sys_emp where emp_ID ='+updateuserid;
      open;
   end;

   result :=  Qrytemp.fieldbyName('emp_no').asstring;
end;

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

  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;
  IsInputSN:=false;
  cmbReason.SetFocus;
  LabTerminal.Caption := LabTerminal.Caption + '    ' + GetTerminalName(iTerminal);

  msgPanel.Caption := '請掃描不良代碼或者Carrier';
  msgpanel.Color :=clGreen;

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



procedure TfMainForm.editCarrierKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
    iType:integer;
begin
    if Key <> #13 then exit;
    if Length(editCarrier.Text) =0 then exit;
    if cmbReason.ItemIndex < 0 then begin
       cmbReason.SetFocus;
       msgpanel.Caption :='請選擇原因';
       msgpanel.Color := clRed;
    end;

    Sproc.Close;
    Sproc.DataRequest('SAJET.CCM_CKRT_HM_END');
    Sproc.FetchParams;
    Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal;
    Sproc.Params.ParamByName('TREV').AsString :=editCarrier.Text;
    Sproc.Execute;

    iResult :=     Sproc.Params.ParamByName('TRES').AsString

    IF iResult <>'OK' THEN  BEGIN
        ShowData(editCarrier.Text);
        editCarrier.Text :='';
        editCarrier.setfocus;
        msgpanel.Caption :=iResult;
        msgpanel.Color := clRed;

    END ;

    ShowData(editCarrier.Text);
    editCarrier.Text :='';
    editCarrier.setfocus;
    msgpanel.Caption :=iResult;
    msgpanel.Color := clGreen;



end;



procedure TfMainForm.cmbReasonSelect(Sender: TObject);
begin
   if cmbReason.ItemIndex =0 then
      sDefect :='NHL02';
   if cmbReason.ItemIndex =1 then
      sDefect :='HGD01';
     editCarrier.Text :='';
     editCarrier.SetFocus;
end;

procedure TfMainForm.cmbTerminalSelect(Sender: TObject);
begin
   Iterminal := IntToStr(10012073+cmbTerminal.ItemIndex);
   cmbReason.SetFocus;
end;

end.
