unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils, ComObj,// shellapi,
  Menus, uLang, IniFiles,Tlhelp32;

type
  TfMainForm = class(TForm)
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    QryTemp1: TClientDataSet;
    msgPanel: TPanel;
    ImageAll: TImage;
    Label5: TLabel;
    EdtSN: TEdit;
    labInputQty: TLabel;
    LabTerminal: TLabel;
    Label1: TLabel;
    edtErrCode: TEdit;
    PrintFile: TLabel;
    btnReprint: TSpeedButton;
    img1: TImage;
    procedure EdtSNKeyPress(Sender: TObject; var Key: Char);
    procedure fromshow(Sender: TObject);
    procedure edtErrCodeKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
    procedure btnReprintClick(Sender: TObject);



    //procedure editReelnoKeyPress(Sender: TObject; var Key: Char);
  private

  public
    UpdateUserID,sPartID,UpdateUserNo : String;
    isStart,IsOpen:boolean;
    sPdline,sProcess,sTerminal,sProcessID:string;
    Authoritys,AuthorityRole,FunctionName : String;
    BarApp,BarDoc,BarVars:variant;
    function GetTerminalName(sTerminalID:string):string;
    function getempNo:string;
    function getsysdate:tdatetime;

  end;

var
  fMainForm: TfMainForm;
  iTerminal:string;

implementation


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

function TfMainForm.getempNo:string;
begin
    Qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Params.CreateParam(ftstring,'EMPID',ptinput);
    qrytemp.CommandText:='SELECT NVL(EMP_NO,''0'') EMPNO FROM SAJET.SYS_EMP   WHERE EMP_ID=:EMPID';
    qrytemp.Params.ParamByName('EMPID').AsString :=UpdateUserID;
    qrytemp.Open;
    Result := qrytemp.fieldbyname('EMPNO').AsString;
end;


function TfMainForm.getsysdate:tdatetime;
begin
    Qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.CommandText:='SELECT sysdate system_time FROM dual';
    qrytemp.Open;
    Result := qrytemp.fieldbyname('system_time').AsDatetime;
end;

procedure TfMainForm.EdtSNKeyPress(Sender: TObject; var Key: Char);
var sRes,sSN:string;
begin
    if key <> #13 then exit;

    if edtsn.Text = '' then exit;

    with sproc do
    begin
         close;
         datarequest('SAJET.SJ_CKRT_SN_PSN');
         fetchparams;
         params.ParamByName('TREV').AsString :=edtSN.Text;
         execute;
    end;

    sRes := Sproc.Params.ParamByName('TRES').AsString;
    if sRes <> 'OK' then
    begin
         msgPanel.Color :=clRed;
         msgPanel.Caption := sRes;
         EdtSN.Clear;
         EdtSN.SetFocus;
         Exit;
    end;
    sSN := Sproc.Params.ParamByName('PSN').AsString;


    with sproc do
    begin
         close;
         datarequest('sajet.SJ_CKRT_ROUTE');
         fetchparams;
         params.ParamByName('TERMINALID').AsString :=iTerminal;
         params.ParamByName('TSN').AsString :=sSN;
         execute;
    end;

    sRes := Sproc.Params.ParamByName('TRES').AsString;
    if sRes <> 'OK' then
    begin
          msgPanel.Color :=clRed;
          msgPanel.Caption := sRes;
          EdtSN.SelectAll;
          EdtSN.SetFocus;
          Exit;

        
    end;

    with sproc do
    begin
        close;
        datarequest('sajet.SJ_GO');
        fetchparams;
        params.ParamByName('TTERMINALID').AsString :=iTerminal;
        params.ParamByName('TSN').AsString :=sSN;
        params.ParamByName('TNOW').AsDateTime :=getsysdate;
        params.ParamByName('TEMP').AsString :=UpdateUserNo;
        execute;
    end;

    if sRes <> 'OK' then
    begin
        msgPanel.Color :=clRed;
        msgPanel.Caption := sRes;
        EdtSN.Clear;
        EdtSN.SetFocus;
        Exit;
    end;

     if (IsStart) and (IsOpen) then
     begin
         BarDoc.Variables.Item('SN').Value :=  edtsn.TEXT;
         Bardoc.PrintLabel(1);
         Bardoc.FormFeed;
         edtsn.SelectAll;
         edtsn.SetFocus;
         edtsn.Clear;
         msgPanel.Caption := '±ø½X¥´¦LOK';
         msgPanel.Color :=cLGREEN;
     end;

end;


procedure TfMainForm.fromshow(Sender: TObject);
var PrintFile:string;
begin
     LabTerminal.Caption := LabTerminal.Caption + '    ' + GetTerminalName(iTerminal);
     Edtsn.SetFocus;

     isStart :=false;
     IsOpen :=false;
     KillTask('lppa.exe');

     try
        BarApp := CreateOleObject('lppx.Application');
      except
        Application.MessageBox('›]¨S¦³¦w¸Ëcodesoft³nÅé','¿ù»~',MB_OK+MB_ICONERROR);
        isStart:=false;
        edtErrCode.Enabled := false;
        EdtSN.Enabled  := False;
        Exit;
     end;
     PrintFile:= GetCurrentDir+'\\R6_CSN.Lab';
     IsStart :=true;

     If not FileExists( PrintFile) then
     begin
         MessageDlg( 'Label ÀÉ®×¤£¦s¦b',mterror,[mbOK],0);
         IsOpen :=false;
         Exit;
     end;
     UpdateUserNo :=  getempNo;

     BarApp.Visible:=false;
     BarDoc:=BarApp.ActiveDocument;
     BarVars:=BarDoc.Variables;
     BarDoc.Open(PrintFile);
     
     IsOpen :=true;

end;

function TfMainForm.GetTerminalName(sTerminalID:string):string;
var sPdline,sProcess,sTerminal:string;
begin
try
  with Qrytemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'TerminalID',ptInput);
      CommandText :='select a.pdline_name,b.process_name,c.terminal_name,c.terminal_id,b.Process_ID ' +
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
         sProcessID := Fieldbyname('process_ID').AsString  ;
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

procedure TfMainForm.edtErrCodeKeyPress(Sender: TObject; var Key: Char);
var sRes:string;
begin
    if Key <>#13 then exit;
    if edtErrCode.Text = '' then exit;
    with sproc do
    begin
       close;
       datarequest('sajet.sj_cksys_defect');
       fetchparams;
       params.ParamByName('TREV').AsString :=edtErrCode.Text;
       execute;
    end;
    sRes :=  sproc.Params.ParamByName('TRES').AsString;
    if  sRes<>'OK' then begin
       edtErrCode.SetFocus;
       edtErrCode.Clear;
       msgPanel.Caption := sRes;
       msgPanel.Color :=clRed;
    end else begin
       edtsn.SetFocus;
       msgPanel.Caption := '¤£¨}¥N½X¿é¤JOK¡A½Ð¿é¤J¥DªO±ø½X';
       msgPanel.Color :=clGreen;
    end;
end;

procedure TfMainForm.FormDestroy(Sender: TObject);
begin

     if IsStart then
     begin
        Bardoc.Close;
        BarApp.Quit;
     end;

end;

procedure TfMainForm.btnReprintClick(Sender: TObject);
var sRes,sSN:string;
begin
  if edtsn.Text = '' then exit;

   with sproc do
   begin
         close;
         datarequest('SAJET.SJ_CKRT_SN_PSN');
         fetchparams;
         params.ParamByName('TREV').AsString :=edtSN.Text;
         execute;
   end;

   sRes := Sproc.Params.ParamByName('TRES').AsString;
   if sRes <> 'OK' then
   begin
         msgPanel.Color :=clRed;
         msgPanel.Caption := sRes;
         EdtSN.Clear;
         EdtSN.SetFocus;
         Exit;
   end;
   sSN := Sproc.Params.ParamByName('PSN').AsString;

   with QryTemp do
   begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'SN',ptInput);
        Params.CreateParam(ftString,'PROCESSID',ptInput);
        CommandText :='SELECT * FROM SAJET.G_SN_TRAVEL WHERE SERIAL_NUMBER =:SN AND PROCESS_ID = :PROCESSID AND WORK_FLAG=0 AND REWORK_NO IS NULL';
        Params.ParamByName('SN').AsString :=sSN;
        Params.ParamByName('PROCESSID').AsString := sProcessID;
        Open;
   end;

   if QryTemp.ISempty  then
   begin
       msgPanel.Color :=clRed;
       msgPanel.Caption := '¨S¦³¥´¦L¹L';
       EdtSN.Clear;
       EdtSN.SetFocus;
       Exit;
   end else begin
       if (IsStart) and (IsOpen) then
       begin
           BarDoc.Variables.Item('SN').Value :=  edtsn.TEXT;
           Bardoc.PrintLabel(1);
           Bardoc.FormFeed;
           edtsn.SelectAll;
           edtsn.SetFocus;
           edtsn.Clear;
           msgPanel.Caption := '±ø½X­«·s¥´¦LOK';
           msgPanel.Color :=cLGREEN;
       end;
   end;

end;

end.











