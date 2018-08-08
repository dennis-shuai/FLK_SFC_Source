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
    msgPanel: TPanel;
    ImageAll: TImage;
    Label3: TLabel;
    edtEmpNo: TEdit;
    dbgrd1: TDBGrid;
    lbl1: TLabel;
    cmbDept: TComboBox;
    lbl2: TLabel;
    chk1: TCheckBox;
    btnPrint: TSpeedButton;
    Image5: TImage;
    procedure FormShow(Sender: TObject);
    procedure edtEmpNoKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
  private

  public
    UpdateUserID,PrintFile,sEmpNo,sEmpName,sPWD: String;
    isStart,IsOpen:boolean;
    BarApp,BarDoc,BarVars:variant;
    function  GetSysDate:TDatetime;
    function  GetEMPNO:string;
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



procedure TfMainForm.FormShow(Sender: TObject);
var i:Integer;
begin

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

   with QryTemp do
   begin
        Close;
        Params.Clear;
        CommandText := ' SELECT  DISTINCT B.DEPT_NAME FROM SAJET.SYS_EMP A,SAJET.SYS_DEPT B '+
                       ' WHERE A.ENABLED=''Y'' AND A.DEPT_ID=B.DEPT_ID and b.Dept_Desc like ''%製造%'' '+
                       ' Order by B.Dept_Name ' ;
        Open;
        First;
        for i:=0 to recordCount-1 do begin
          cmbDept.Items.Add(fieldByname('Dept_NAME').AsString);
          Next;
        end;
   end;

end;

procedure TfMainForm.edtEmpNoKeyPress(Sender: TObject; var Key: Char);
var iResult:String;
begin
    if Key <> #13 then exit;

    with QryTemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'EMPNO',ptInput);
        CommandText := 'SELECT EMP_NO,EMP_NAME,SAJET.PASSWORD.DECRYPT(PASSWD) PWD FROM SAJET.SYS_EMP WHERE EMP_NO=:EMPNO AND ENABLED=''Y''' ;
        Params.ParamByName('EMPNO').AsString := Trim(edtEmpNo.Text);
        Open;

    end;

    if QryTemp.IsEmpty then
    begin
        msgPanel.Caption := '工號不存在';
        msgPanel.Color :=clRed;
        edtEmpNo.SelectAll;
        edtEmpNo.SetFocus;
        Exit;
    end;
    sEmpNo := QryTemp.fieldByName('EMP_NO').AsString;
    sEmpName :=  QryTemp.fieldByName('EMP_Name').AsString;

    with QryTemp1 do
    begin
        Close;
        Params.Clear;
        CommandText := 'select dbms_random.string(''A'',8)||dbms_random.string(''X'',6) pwd from dual' ;
        Open;
    end;
    sPWD :=  QryTemp.fieldByName('PWD').AsString;

    with QryTemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'EMPNO',ptInput);
        Params.CreateParam(ftString,'PWD',ptInput);
        CommandText := 'Update SAJET.SYS_EMP SET PASSWD = SAJET.PASSWORD.ENCRYPT(:PWD) WHERE EMP_NO=:EMPNO ' ;
        Params.ParamByName('EMPNO').AsString := Trim(edtEmpNo.Text);
        Params.ParamByName('PWD').AsString := sPWD;
        Execute;
    end;

    PrintFile :=GetCurrentDir +'\\Emp_Info.Lab';
    If not FileExists( PrintFile) then
    begin
         msgPanel.Caption := 'Label 檔案不存在';
         msgPanel.Color :=clRed;
         edtEmpNo.SelectAll;
         edtEmpNo.SetFocus;
         IsOpen :=false;
         Exit;
    end;

    if IsStart and (not IsOpen) then
    begin
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

    if IsStart and IsOpen  then
    begin
         try
              BarDoc.Variables.Item('EMP_NO').Value := sEmpNo;
              BarDoc.Variables.Item('EMP_NAME').Value := sEmpName;
              BarDoc.Variables.Item('PWD').Value := sPWD;
              Bardoc.PrintLabel(1);
              Bardoc.FormFeed;

              msgpanel.Caption :=iResult+'======>>'+'列印完畢';
              msgPanel.Color :=clGreen;
              edtEmpNo.Text :='';
              edtEmpNo.Setfocus;
         except
              msgpanel.Caption :='列印錯誤';
              msgPanel.Color :=clRed;
              edtEmpNo.Text :='';
              edtEmpNo.Setfocus;
              exit;
         end;
    end;


end;

end.
