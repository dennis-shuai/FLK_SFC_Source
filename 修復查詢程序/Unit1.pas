unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, MConnect, ObjBrkr, DB, DBClient, SConnect;

type
  TMainForm = class(TForm)
    SimpleObjectBroker1: TSimpleObjectBroker;
    SocketConnection1: TSocketConnection;
    dsQuery: TClientDataSet;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    MSG: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function LoadApServer : Boolean;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Self.Left := Round((Screen.Width - Self.Width )/2);
  Self.Top := Round ((Screen.Height - Self.Height)/2);

  if not LoadApServer then MessageDlg('Load AP Server Error!!',mtError ,[mbyes],0) ;
end;

function TMainForm.LoadApServer : Boolean;
var
  F : TextFile;
  S : String;
begin
  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  If not FileExists(GetCurrentDir+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,GetCurrentDir+'\ApServer.cfg');
  Reset(F);
  While not Eof(F) do
  begin
    Readln(F, S);
    If (S <> '') and (Length(S) >6)  Then
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

procedure TMainForm.Button1Click(Sender: TObject);
var
  StrSql : string;
begin

  MSG.Font.Color := clBlack ;
  MSG.Caption := 'Running...';
  Application.ProcessMessages ;
  
  with dsQuery do
  begin
    Close ;
    CommandText := 'Select * from sajet.sys_report_name where DLL_FILENAME=''ReportTravelDll.Dll'' ';
    Open ;
    if not IsEmpty then
    begin
      MSG.Font.Color := clRed ;
      MSG.Caption :='Fail';
      MessageDlg('你確定查詢程式需要修復嗎?先去看下再來吧!', mtInformation,[mbOk], 0) ;
      Exit ;
    end;
  end;

   StrSql := 'Insert into sajet.SYS_report_name '+
   '(RP_ID, RP_NAME, RP_TYPE, SAMPLE_NAME, UPDATE_USERID, UPDATE_TIME, EMP_ID, DLL_FILENAME, RP_TYPE_IDX, GROUP_FLAG) '+
   'Values  '+
   '(11000013, ''Travel Card'', ''TravelCard'', ''TravelCard.xlt'', 10000001, TO_DATE(''07/18/2006 10:21:34'',' +
   ' ''MM/DD/YYYY HH24:MI:SS''), 0, ''ReportTravelDll.Dll'', ''9'', ''1'')' ;

   with dsQuery do
   begin
     Close ;
     CommandText := StrSql ;
     Execute ;
   end;

   MSG.Font.Color := clBlue ;
   MSG.Caption :='Successfully';
   MessageDlg('哈哈,查詢程式修復成功,快去看看吧!', mtInformation,[mbOk], 0) ;
   
end;

end.
