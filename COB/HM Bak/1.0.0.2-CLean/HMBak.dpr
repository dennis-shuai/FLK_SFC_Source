program HMBak;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  uLogin in 'uLogin.pas' {Login};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TLogin, Login);
  Application.Run;
end.
