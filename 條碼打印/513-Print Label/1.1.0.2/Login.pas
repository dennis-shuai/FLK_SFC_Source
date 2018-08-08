unit Login;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, DBClient, MConnect, SConnect, ObjBrkr,IniFiles;

type
  TifLogin = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    edtUser: TEdit;
    edtPwd: TEdit;
    Button1: TButton;
    Button2: TButton;
    SimpleObjectBroker1: TSimpleObjectBroker;
    SocketConnection1: TSocketConnection;
    Qrytemp: TClientDataSet;
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure edtPwdKeyPress(Sender: TObject; var Key: Char);
    procedure edtUserKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    IsStart:boolean;
    C_LINEID,C_STAGEID,C_PROCESSID,C_TERMINALID,sEMPID:string;
    Function LoadApServer : Boolean;
  end;


var
  ifLogin: TifLogin;

implementation

{$R *.dfm}
uses Main;

Function TifLogin.LoadApServer : Boolean;
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



procedure TifLogin.FormShow(Sender: TObject);
begin
     LoadApServer ;
end;

procedure TifLogin.Button2Click(Sender: TObject);
begin
    Application.Terminate;
end;

procedure TifLogin.Button1Click(Sender: TObject);
var sData ,sSendData: string;
   // fMain :TFmain;
begin

    with Qrytemp   do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftstring,'user_no',ptInput);
        CommandText :='SELECT SAJET.PASSWORD.decrypt(PASSWD) myPwd,EMP_ID FROM SAJET.SYS_EMP WHERE EMP_NO =:user_no';
        Params.ParamByName('user_no').AsString :=edtUser.Text;
        Open;

        if IsEmpty then begin
           MessageDlg('Login Fail,User No error ',mtError,[mbOK],0);
           exit;
        end;

        if edtPwd.Text  <>  trim( FieldByName('myPwd').AsString) then
        begin
            MessageDlg('Login Fail,Pwd  error :'+edtPwd.Text ,mtError,[mbOK],0);
            exit;
        end;
        sEMPID := FieldByname('EMP_ID').AsString;
    end;
    ifLogin.Hide;
    fMain.ShowModal;

end;

procedure TifLogin.edtPwdKeyPress(Sender: TObject; var Key: Char);
begin
    if Key =#13 then begin
     Button1.Click; 
  end;
end;

procedure TifLogin.edtUserKeyPress(Sender: TObject; var Key: Char);
begin
   if Key <> #13 then exit;
   edtPwd.SetFocus;
end;

end.
