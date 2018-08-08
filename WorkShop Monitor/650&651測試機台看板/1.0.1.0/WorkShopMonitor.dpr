program WorkShopMonitor;

uses
  Forms,
  MainForm in 'MainForm.pas' {uMainForm},
  uLine in 'uLine.pas' {formLine},
  uLineDetail in 'uLineDetail.pas' {LineDetail},
  uMyClassHelpers in 'uMyClassHelpers.pas',
  uCumDetail in 'uCumDetail.pas' {uCum},
  uModelDetail in 'uModelDetail.pas' {ModelDetail};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TuMainForm, uMainForm);
  //Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TformLine, formLine);
  Application.Run;
end.
