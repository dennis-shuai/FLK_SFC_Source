program ATE;

uses
  Forms,
  unitMain in 'unitMain.pas' {FormMain},
  RunOnce in 'RunOnce.pas',
  uDir in 'uDir.pas' {formDir},
  uDM in 'uDM.pas' {dmProject: TDataModule},
  uRetry in 'uRetry.pas' {fRetry},
  uMessage in 'uMessage.pas' {fMessage};

{$R *.res}

begin
  Application.Initialize;
  if not AppHasRun(Application.Handle ) then
  begin
  Application.Title := 'ATE';
  Application.CreateForm(TdmProject, dmProject);
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TformDir, formDir);
  Application.CreateForm(TfRetry, fRetry);
  Application.CreateForm(TfMessage, fMessage);
  Application.Run;
  end;
end.
