program LabelDocApply;

uses
  Forms,
  uMainForm in 'uMainForm.pas' {LabelDocApplyForm},
  RunOnce in 'RunOnce.pas';

{$R *.res}

begin
  Application.Initialize;
  //if not AppHasRun(Application.Handle ) then
  //begin
  Application.Title := 'LabelDocApply';
  Application.ShowMainForm := False ;
  Application.CreateForm(TLabelDocApplyForm, LabelDocApplyForm);
  Application.Run;
  //end;
end.
