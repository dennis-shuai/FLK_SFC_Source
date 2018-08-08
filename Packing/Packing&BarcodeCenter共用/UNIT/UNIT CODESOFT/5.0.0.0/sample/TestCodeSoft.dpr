program TestCodeSoft;

uses
  Forms,
  unitMain in 'unitMain.pas' {Form1},
  unitCodeSoft in 'unitCodeSoft.pas',
  unitCodeSoftSample in 'unitCodeSoftSample.pas',
  unitCodeSoft6 in 'unitCodeSoft6.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
