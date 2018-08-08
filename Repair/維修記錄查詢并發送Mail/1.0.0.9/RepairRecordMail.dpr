program RepairRecordMail;

uses
  Forms,
  uMain in 'uMain.pas' {uMainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TuMainForm, uMainForm);
  Application.Run;
end.
