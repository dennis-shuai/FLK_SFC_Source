unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles,Tlhelp32,ComObj;

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
    procedure FormDestroy(Sender: TObject);
  private
    //m_SNDefectLevel: String;
    
    function GetTerminalName(sTerminalID:string):string;
   // procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);

   // function GetPartID(partno :String) :String;
   // procedure ShowData(sCarrier :String);
  public
    UpdateUserID,sPartID ,sPartNo,PrintFile: String;
    isStart,IsOpen:boolean;
    BarApp,BarDoc,BarVars:variant;
    sPdline,sProcess,iTerminal,sTerminal,sSSID,sMAC:string;
   // Authoritys,AuthorityRole,FunctionName : String;
    sDefectID,sDefectCode:String;
    function  GetSysDate:TDatetime;
    function GetEMPNO:string;
  end;

var
  fMainForm: TfMainForm;


implementation

uses uLogin;


{$R *.dfm}


function KillTask(ExeFileName: string): integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOLean;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
        OpenProcess(PROCESS_TERMINATE,
        BOOL(0),
        FProcessEntry32.th32ProcessID),
        0));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);


end;

procedure TfMainForm.FormDestroy(Sender: TObject);
begin
   if IsOpen then Bardoc.Close;
   if IsStart then BarApp.Quit;
   KillTask('lppa.exe');

end;

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


   {

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
}

procedure TfMainForm.FormShow(Sender: TObject);
var iniFile:TIniFile;
begin
   iniFile :=TIniFile.Create('SAJET.ini');
   iTerminal :=iniFile.ReadString('CM','Terminal','N/A' );
   iniFile.Free;
   LabTerminal.Caption := 'Terminal:'+ GetTerminalName(iTerminal);
   editSN.SetFocus;

   isStart :=false;
   IsOpen :=false;
   KillTask('lppa.exe');
   try
      BarApp := CreateOleObject('lppx.Application');
   except
      isStart:=false;
      msgPanel.Caption := '沒有安裝codesoft軟體';
      msgpanel.Color :=clRed;
      Exit;
   end;
   IsStart :=true;

   msgPanel.Caption := '請掃描不良代碼或條碼';
   msgpanel.Color :=clGreen;

end;

procedure TfMainForm.editDefectKeyPress(Sender: TObject; var Key: Char);
begin
    if Key <> #13 then exit;
    editDefect.Text := Trim(editDefect.Text);
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
    
    editSN.SelectAll;
    editSN.SetFocus;
    msgpanel.Caption :='OK,請掃描條碼';
    msgpanel.Color := clGreen;
    exit;
    
end;



procedure TfMainForm.editSNKeyPress(Sender: TObject; var Key: Char);
var iResult,sSN:String;
begin
   if Key <> #13 then exit;

   if length(editsn.Text)=0 then exit;

   if editDefect.Text = '' then
   begin
        with QryTemp do
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString,'SN',ptInput);
          CommandText := 'Select serial_number,B.PART_NO FROM SAJET.G_SN_STATUS A '
                       + ' , SAJET.SYS_PART B WHERE A.MODEL_ID = B.PART_ID AND '
                       + ' (A.SERIAL_NUMBER =:SN OR A.CUSTOMER_SN =:SN)' ;
          Params.ParamByName('SN').AsString := Trim(editSN.Text);
          Open;

          sPartNO:= FieldByName('PART_NO').AsString;
          sSN :=  FieldByName('serial_number').AsString;
        end;

        if QryTemp.IsEmpty then begin
            msgPanel.Caption := 'NO SN';
            msgPanel.Color :=clRed;
            editSN.SelectAll;
            editSN.SetFocus;
            Exit;
        end;

        with QryData do
        begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString,'SN',ptInput);
            CommandText := ' Select A.ITEM_PART_SN ,TO_CHAR( TO_NUMBER(SUBSTR(A.ITEM_PART_SN,7,6),''XXXXXX'')+1,''XXXXXX'' ) SSID '+
                           ' FROM SAJET.G_SN_KEYPARTS A ' +
                           '  WHERE    A.SERIAL_NUMBER =:SN and enabled=''Y'' ' ;
            Params.ParamByName('SN').AsString :=sSN;
            Open;

            sMAC:= FieldByName('ITEM_PART_SN').AsString;
            sSSID:= FieldByName('SSID').AsString;


        end;

        if not QryTemp.IsEmpty then
        begin
           PrintFile :=GetCurrentDir +'\\S_'+sPartNO+'.Lab';
           If not FileExists( PrintFile) then
           begin
                 msgPanel.Caption := 'Label 檔案不存在';
                 msgPanel.Color :=clRed;
                 editSN.SelectAll;
                 editSN.SetFocus;
                 IsOpen :=false;
                 Exit;
           end;

           

           if IsStart then begin
              try
                 BarApp.Visible:=false;
                 BarDoc:=BarApp.ActiveDocument;
                 BarVars:=BarDoc.Variables;
                 BarDoc.Open(PrintFile);
                 IsOpen :=true;
              except
                 msgPanel.Caption := '打開檔案錯誤';
                 msgPanel.Color :=clRed;
                 IsOpen :=false;
                 Exit;
              end;
           end;
           
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

   if iResult ='OK' then
   begin

      if editDefect.Text ='' then
      begin
          if (IsStart) and (IsOpen) then
          begin
              try
                  BarDoc.Variables.Item('SN').Value := UpperCase( Trim(editsn.Text));
                  BarDoc.Variables.Item('MAC').Value := sMac;
                  BarDoc.Variables.Item('SSID').Value := sSSID;
                  Bardoc.PrintLabel(1);
                  Bardoc.FormFeed;

                  msgpanel.Caption :=iResult+'======>>'+'條碼列印完畢';
                  msgPanel.Color :=clGreen;
                  editSN.Text :='';
                  editSN.Setfocus;
              except
                 msgpanel.Caption :='條碼列印錯誤';
                 msgPanel.Color :=clRed;
                 editSN.Text :='';
                 editSN.Setfocus;
                 exit;
              end;
          end;
          msgPanel.Caption :='OK';
          msgPanel.Color :=clGreen;
          editSN.SetFocus;
          editDefect.Text :='';
          editSN.Text :='';
      end;

   end else begin
        if editDefect.Text ='' then
        begin
            if Not QryTemp.IsEmpty then
            begin
               fLogin := TfLogin.Create(Self);
               if fLogin.ShowModal = mrOK then
               begin
                    if (IsStart) and (IsOpen) then
                    begin
                         try
                             BarDoc.Variables.Item('SN').Value :=  UpperCase(trim(editsn.Text));
                             BarDoc.Variables.Item('MAC').Value := sMac;
                             BarDoc.Variables.Item('SSID').Value := sSSID;
                             Bardoc.PrintLabel(1);
                             Bardoc.FormFeed;

                             editSN.Text :='';
                             editSN.Setfocus;
                             msgpanel.Caption :='條碼重新列印完畢';
                             msgPanel.Color :=clYellow;
                             exit;
                         except
                             editSN.Text :='';
                             editSN.Setfocus;
                             msgpanel.Caption :='條碼重新列印錯誤';
                             msgPanel.Color :=clRed;
                           exit;
                          end;
                    end;
               end
               else begin
                   msgPanel.Caption :=iResult+'沒有權限重新列印';
                   msgPanel.Color :=clRed;
                   editSN.Text :='';
                   editSN.SetFocus ;

               end;
            end;
        end;
        msgPanel.Caption :=iResult;
        msgPanel.Color :=clRed;
        editSN.Text :='';
        editSN.SetFocus ;
   end;

end;

end.
