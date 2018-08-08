program FQC1_SFCS;

uses
  Forms,
  uMain in 'uMain.pas' {fMain},
  Login in 'Login.pas' {fLogin};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfLogin, fLogin);
  Application.Run;
end.
