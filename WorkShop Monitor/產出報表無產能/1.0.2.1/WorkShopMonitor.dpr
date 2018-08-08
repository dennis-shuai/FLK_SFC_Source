program WorkShopMonitor;

uses
  Forms,
  MainForm in 'MainForm.pas' {uMainForm},
  uMyClassHelpers in 'uMyClassHelpers.pas',
  uCumDetail in 'uCumDetail.pas' {uCum},
  uLine in 'uLine.pas' {formLine};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TuMainForm, uMainForm);
  Application.CreateForm(TformLine, formLine);
  //Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TformLine, formLine);
  Application.Run;
end.
