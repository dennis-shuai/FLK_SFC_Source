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
    editDefect: TEdit;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    Label2: TLabel;
    ImageAll: TImage;
    Label3: TLabel;
    editSN: TEdit;
    lbl1: TLabel;
    edtWO: TEdit;
    lblQty: TLabel;
    lblCount: TLabel;
    procedure FormShow(Sender: TObject);
    procedure editDefectKeyPress(Sender: TObject; var Key: Char);
    procedure editSNKeyPress(Sender: TObject; var Key: Char);
    procedure edtWOKeyPress(Sender: TObject; var Key: Char);
  private
    //m_SNDefectLevel: String;
    
    function GetTerminalName(sTerminalID:string):string;
    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);

    function GetPartID(partno :String) :String;
    procedure ShowData(sCarrier :String);
  public
    UpdateUserID,sPartID : String;
    sPdline,sProcess,sTerminal,sProcessID:string;
    Authoritys,AuthorityRole,FunctionName : String;
    sDefectID,sDefectCode:String;
    iCount:Integer;
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
      CommandText :=' select a.pdline_name,b.process_name,c.terminal_name,c.terminal_id ,c.Process_ID ' +
                    ' from sajet.sys_pdline a,sajet.sys_process b,sajet.sys_terminal c '+
                    ' where c.terminal_id = :TerminalID  '+
                    '  and a.pdline_id=c.pdline_id '+
                    '  and b.process_id=c.process_id';

      Params.ParamByName('TerminalID').AsString :=sTerminalID;
      Open;
      if RecordCount > 0 then
      begin
         sPdline := Fieldbyname('pdline_name').AsString  ;
         sProcess:= Fieldbyname('process_name').AsString  ;
         sProcessID :=  Fieldbyname('process_ID').AsString  ;
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
var iniFile:TIniFile;
begin
   iniFile :=TIniFile.Create('SAJET.ini');
   iTerminal :=iniFile.ReadString('CM','Terminal','N/A' );
   iniFile.Free;
   LabTerminal.Caption := 'Terminal:'+ GetTerminalName(iTerminal);
   edtWO.SetFocus;
   msgPanel.Caption := '請掃描條碼或者工令';
   msgpanel.Color :=clGreen;
   iCount :=0;

end;

procedure TfMainForm.editDefectKeyPress(Sender: TObject; var Key: Char);
var iResult,sSN:string;
begin
    if Key <> #13 then exit;
    if Length(edtWO.Text) =0 then exit;
    if Length(editDefect.Text) =0 then exit;


    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTEmp.Params.CreateParam(ftstring,'Defect',ptInput)  ;
    QryTemp.CommandText :='Select * from sajet.sys_defect where Defect_code=:Defect';
    QryTemp.Params.ParamByName('Defect').AsString :=editDefect.Text;
    QryTemp.Open;

    if QryTemp.IsEmpty then begin
         editDefect.SelectAll;
         editDefect.SetFocus;
         editSN.Enabled :=false;
         msgpanel.Caption :='不良代碼錯誤';
         msgpanel.Color := clRed;
         exit;
    end;
    editSN.ReadOnly :=false;
    editSN.Enabled :=true;
    editSN.SelectAll;
    editSN.SetFocus;
    msgpanel.Caption :='OK,請掃描條碼';
    msgpanel.Color := clGreen;
    exit;
    
end;



procedure TfMainForm.editSNKeyPress(Sender: TObject; var Key: Char);
var iResult,sWO:String;
Tartget_qty,Qty:Integer;
begin
   if Key <> #13 then exit;
   if Length(edtWO.Text) =0 then exit;
   if length(editsn.Text)=0 then exit;

   QryTemp.Close;
   QryTemp.Params.Clear;
   QryTEmp.Params.CreateParam(ftstring,'SN',ptInput)  ;
   QryTemp.CommandText :='Select * from sajet.g_sn_status where serial_number =:SN or customer_sn =:SN';
   QryTemp.Params.ParamByName('SN').AsString :=editSN.Text;
   QryTemp.Open;

   if  QryTemp.IsEmpty then
   begin
       msgPanel.Caption :='NO SN';
       msgPanel.Color :=clRed;
       editSN.Text :='';
       editSN.SetFocus;
       exit;
   end
   else begin
       sWO := QryTemp.FieldByName('WORK_ORDER').AsString ;
      if swo<> edtWO.Text then begin
         msgPanel.Caption :='工令為'+sWO;
         msgPanel.Color :=clRed;
         editSN.Text :='';
         editSN.SetFocus;
         exit;
      end;
   end;

   Sproc.Close;
   Sproc.DataRequest('SAJET.CCM_SN_TEST') ;
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal;
   if editDefect.Text ='' then
      Sproc.Params.ParamByName('TDEFECT').AsString :='N/A'
   else
      Sproc.Params.ParamByName('TDEFECT').AsString :=editDefect.Text;
   Sproc.Params.ParamByName('TREV').AsString :=editSN.Text;
   Sproc.Params.ParamByName('TEMP').AsString :=UpdateUserID;
   Sproc.Execute;
   iResult := Sproc.Params.parambyname('TRES').AsString;

   if iResult ='OK' then begin
      msgPanel.Caption :='OK';
      msgPanel.Color :=clGreen;
      editSN.SetFocus;
      editDefect.Text :='';
      editSN.Text :='';
      Inc(iCount);
      lblCount.Caption :='掃描數:'+IntToStr(iCount);
     // editSN.Enabled :=false;
   end else begin
      msgPanel.Caption :=iResult;
      msgPanel.Color :=clRed;
      editSN.Text :='';
      editSN.SetFocus;
   end;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTEmp.Params.CreateParam(ftstring,'WO',ptInput)  ;
    QryTemp.CommandText :='Select * from sajet.G_WO_BASE where WORK_ORDER =:WO';
    QryTemp.Params.ParamByName('WO').AsString :=edtWO.Text;
    QryTemp.Open;

    Tartget_qty :=QryTemp.fieldbyName('target_qty').AsInteger ;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTEmp.Params.CreateParam(ftstring,'WO',ptInput)  ;
    QryTEmp.Params.CreateParam(ftstring,'Process',ptInput)  ;
    QryTemp.CommandText :='Select Sum(Pass_qty+Repair_QTY) qty from sajet.G_SN_COUNT where WORK_ORDER =:WO and Process_id =:process ';
    QryTemp.Params.ParamByName('WO').AsString :=edtWO.Text;
    QryTemp.Params.ParamByName('Process').AsString :=sProcessID ;
    QryTemp.Open;

    Qty :=  QryTemp.fieldbyName('Qty').AsInteger ;

    lblQty.Caption := 'Pass數:'+IntToStr(Qty)+'/'+IntToStr(Tartget_qty);


end;

procedure TfMainForm.edtWOKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
  //
    if Key <> #13 then exit;
    if Length(edtWO.Text) =0 then exit;


    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTEmp.Params.CreateParam(ftstring,'SN',ptInput)  ;
    QryTemp.CommandText :='Select * from sajet.G_SN_STATUS where SERIAL_NUMBER =:SN or customer_sn=:SN';
    QryTemp.Params.ParamByName('SN').AsString :=edtWO.Text;
    QryTemp.Open;

    if not QryTemp.IsEmpty then begin
        edtWO.Text :=QryTemp.fieldbyName('Work_order').AsString;
    end;

    
   Sproc.Close;
   Sproc.DataRequest('SAJET.Sj_Chk_Wo_Input') ;
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TREV').AsString :=edtWO.Text;
   Sproc.Execute;
   iResult := Sproc.Params.parambyname('TRES').AsString;

   if Copy(iResult,1,2)<> 'OK' then
   begin
        msgPanel.Caption :=iResult;
        msgPanel.Color :=clRed;
        editSN.ReadOnly :=true;
        edtWO.Text :='';
        edtWO.SetFocus;
   end  else begin
       msgPanel.Caption :=iResult;
       msgPanel.Color :=clGreen;
       editSN.ReadOnly :=false;
       editSN.Text :='';
       editSN.SetFocus;
   end;



end;

end.
