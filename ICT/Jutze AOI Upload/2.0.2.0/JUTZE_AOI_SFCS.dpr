program JUTZE_AOI_SFCS;

uses
  Forms,
  uMain in 'uMain.pas' {fMain},
  Login in 'Login.pas' {fLogin};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfLogin, fLogin);
 // Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
