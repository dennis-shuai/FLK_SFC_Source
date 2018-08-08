program GetModuleID;

uses
  Forms,
  Main in 'Main.pas' {uMainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TuMainForm, uMainForm);
  Application.Run;
end.
