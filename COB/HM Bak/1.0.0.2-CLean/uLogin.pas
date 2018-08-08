unit uLogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, MConnect, ObjBrkr, DB, DBClient, SConnect;

type
  TLogin = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    QryData: TClientDataSet;
    SocketConnection1: TSocketConnection;
    SimpleObjectBroker1: TSimpleObjectBroker;
    Sproc: TClientDataSet;
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     UpdateUserID:string;
      function LoadApServer: Boolean;

  end;

var
  Login: TLogin;

implementation

uses Unit1;

{$R *.dfm}


function TLogin.LoadApServer: Boolean;
var F: TextFile;
   S: string;
begin
   Result := False;
   SocketConnection1.Connected := False;
   SimpleObjectBroker1.Servers.Clear;
   SocketConnection1.Host:='';
   SocketConnection1.Address:='';
   if  FileExists(GetCurrentDir + '\ApServer.cfg') then
     AssignFile(F, GetCurrentDir + '\ApServer.cfg')
   else
     exit;
   Reset(F);
   while True do
   begin
      Readln(F, S);
      if trim(S) <> '' then
      begin
        SimpleObjectBroker1.Servers.Add;
        SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
        SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
      end else
        Break;
   end;
   CloseFile(F);
   Result := True;
end;

procedure TLogin.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
    if Key <> #13 then exit;
    edit2.SetFocus;
end;

procedure TLogin.Edit2KeyPress(Sender: TObject; var Key: Char);
var uMainForm :TForm1;
begin
    if Key <> #13 then exit;

    QryData.Close;
    QryData.Params.Clear;
    QryData.Params.CreateParam(ftstring,'EMPNO',ptinput);
    QryData.CommandText := 'SELECT TRIM(SAJET.PASSWORD.DECRYPT( PASSWD)) PWD,EMP_ID from SAJET.SYS_EMP where EMP_NO = :EMPNO';
    QryData.Params.ParamByName('EMPNO').AsString :=edit1.Text;
    Qrydata.Open;

    if QryData.IsEmpty then begin
        MessageBox(0,'¨S¦³¸Ó¥Î¤á','¿ù»~',MB_ICONERROR);
        exit;
    end;

    if QryData.FieldByName('PWD').AsString <> edit2.Text then begin
        MessageBox(0,'±K½X¿ù»~','¿ù»~',MB_ICONERROR);
        exit;
    end;

    UpdateUserID :=  QryData.FieldByName('EMP_ID').AsString ;
    Login.Hide;
    uMainForm := TForm1.Create(self);
    uMainForm.ShowModal;




end;

procedure TLogin.FormShow(Sender: TObject);
begin
       LoadApServer;
end;

end.
