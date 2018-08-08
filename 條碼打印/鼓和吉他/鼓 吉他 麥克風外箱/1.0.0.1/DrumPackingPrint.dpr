program DrumPackingPrint;

uses
  Forms,
  Login in 'Login.pas' {ifLogin},
  umain in 'umain.pas' {fMain},
  uLogin in 'uLogin.pas' {fLogin},
  uReprintPallet in 'uReprintPallet.pas' {fReprint};

{$R *.res}

begin
  Application.Initialize;
  //Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TifLogin, ifLogin);
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TfLogin, fLogin);
  Application.CreateForm(TfReprint, fReprint);
  Application.Run;
end.
