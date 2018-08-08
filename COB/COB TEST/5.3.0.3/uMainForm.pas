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
    procedure FormShow(Sender: TObject);
    procedure editDefectKeyPress(Sender: TObject; var Key: Char);
    procedure editSNKeyPress(Sender: TObject; var Key: Char);
  private
    //m_SNDefectLevel: String;
    
    function GetTerminalName(sTerminalID:string):string;
    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);

    function GetPartID(partno :String) :String;
    procedure ShowData(sCarrier :String);
  public
    UpdateUserID,sPartID : String;
    sPdline,sProcess,sTerminal:string;
    Authoritys,AuthorityRole,FunctionName : String;
    sDefectID,sDefectCode:String;
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
var iniFile:TIniFile;
begin
   iniFile :=TIniFile.Create('SAJET.ini');
   iTerminal :=iniFile.ReadString('COB','Terminal','N/A' );
   iniFile.Free;
   LabTerminal.Caption := 'Terminal:'+ GetTerminalName(iTerminal);
   editSN.SetFocus;
   msgPanel.Caption := '請掃描不良代碼';
   msgpanel.Color :=clGreen;

end;

procedure TfMainForm.editDefectKeyPress(Sender: TObject; var Key: Char);
var iResult,sSN:string;
begin
    if Key <> #13 then exit;
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
var iResult:String;
begin
   if Key <> #13 then exit;
   if length(editsn.Text)=0 then exit;

   if editDefect.Text='' then begin
       Sproc.Close;
       Sproc.DataRequest('SAJET.CCM_SN_TEST') ;
       Sproc.FetchParams;
       Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal;
       Sproc.Params.ParamByName('TDEFECT').AsString :='N/A';
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
         // editSN.Enabled :=false;
       end else begin
          msgPanel.Caption :=iResult;
          msgPanel.Color :=clRed;
          editSN.Text :='';
          editSN.SetFocus
       end;

   end else begin
       Sproc.Close;
       Sproc.DataRequest('SAJET.CCM_COB_WB_VI_NOGO') ;
       Sproc.FetchParams;
       Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal;
       Sproc.Params.ParamByName('TDEFECT').AsString :=editDefect.Text;
       Sproc.Params.ParamByName('TSN').AsString :=editSN.Text;
       Sproc.Params.ParamByName('TEMPID').AsString :=UpdateUserID;
       Sproc.Execute;
       iResult := Sproc.Params.parambyname('TRES').AsString;

       if iResult ='OK' then begin
          msgPanel.Caption :='OK';
          msgPanel.Color :=clGreen;
          editSN.SetFocus;
          editDefect.Text :='';
          editSN.Text :='';
          //editSN.Enabled :=false;
       end else begin
          msgPanel.Caption :=iResult;
          msgPanel.Color :=clRed;
          editSN.Text :='';
          editSN.SetFocus
       end;
   end;

end;

end.
