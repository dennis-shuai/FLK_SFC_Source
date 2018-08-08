program DrumPackingPrint;

uses
  Forms,
  Login in 'Login.pas' {fLogin},
  umain in 'umain.pas' {fMain};

{$R *.res}

begin
  Application.Initialize;
  //Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfLogin, fLogin);
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
