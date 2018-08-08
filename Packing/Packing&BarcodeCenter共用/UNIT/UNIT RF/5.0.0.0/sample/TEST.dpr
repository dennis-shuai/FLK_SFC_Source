program TEST;

uses
  Forms,
  unitMain in 'unitMain.pas' {Form1},
  unitRF in 'unitRF.pas',
  unitDriverThread in 'unitDriverThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
