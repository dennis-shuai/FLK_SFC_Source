program AutoUpload702H;

uses
  Forms,
  uMain in 'uMain.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '702H logFile AutoUpload';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
