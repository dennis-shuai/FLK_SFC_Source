unit Login;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfLogin = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    edtUser: TEdit;
    edtPwd: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    IsStart:boolean;
  end;
  function SajetTransData(f_iCommandNo : integer;f_pData,f_pLen : pointer) : byte; stdcall; external 'SajetConnect.dll';
  function SajetTransStart : boolean; stdcall;external 'SajetConnect.dll';
  function SajetTransClose : boolean; stdcall;external 'SajetConnect.dll';

var
  fLogin: TfLogin;

implementation

{$R *.dfm}
uses uMain;

procedure TfLogin.FormShow(Sender: TObject);
begin
    IsStart:=false;
    if not SajetTransStart then
    begin  MessageDlg('Start Fail',mtInformation,[mbOK],0);
           IsStart :=false;
    end else IsStart:=true;
end;

procedure TfLogin.Button2Click(Sender: TObject);
begin
  if not SajetTransClose then  MessageDlg('Close Fail',mtInformation,[mbOK],0);
  IsStart :=false;
  Application.Terminate;
end;

procedure TfLogin.Button1Click(Sender: TObject);
var sData ,sSendData: string;
    i,iLen : integer;
    fMain :TFmain;
begin
  if not IsStart  then SajetTransStart;
  sSendData :=edtUser.Text+';'+edtPwd.Text;

  iLen:=Length(sSendData);

  if iLen<1000 then SetLength(sData,100)
  else SetLength(sData,iLen);

  for i:=1 to iLen do sData[i]:=sSendData[i];

  SajetTransData(1,@sdata[1],@iLen);
  SetLength(sData,iLen);

  if sData <> 'OK;' then begin
       MessageDlg('Login Fail,User or Password error',mtError,[mbOK],0);
       exit;
  end;

  fMain :=TfMain.Create(self);
  fMain.Show;
  fLogin.Hide;
end;

procedure TfLogin.FormDestroy(Sender: TObject);
begin
   if not SajetTransClose then  MessageDlg('Close Fail',mtInformation,[mbOK],0);
end;

end.
