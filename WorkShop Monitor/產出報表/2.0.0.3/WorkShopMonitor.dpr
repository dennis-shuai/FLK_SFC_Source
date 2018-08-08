program WorkShopMonitor;

uses
  Forms,
  MainForm in 'MainForm.pas' {uMainForm},
  uMyClassHelpers in 'uMyClassHelpers.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TuMainForm, uMainForm);
  Application.Run;
end.
