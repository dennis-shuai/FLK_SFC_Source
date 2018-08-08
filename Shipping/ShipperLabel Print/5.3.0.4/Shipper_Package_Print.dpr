program Shipper_Package_Print;

uses
  Forms,
  uFormPrint in 'uFormPrint.pas' {FormPrint},
  uFormMain in 'uFormMain.pas' {FormMain},
  uFormSKU in 'uFormSKU.pas' {FormSKU},
  uFormWeight in 'uFormWeight.pas' {WeightForm},
  uExceptionInfo in 'uExceptionInfo.pas' {ErrorForm},
  RunOnce in 'RunOnce.pas',
  uAuthority in 'uAuthority.pas',
  uEncrypAndUncrypKey in 'uEncrypAndUncrypKey.pas',
  uMessage in 'uMessage.pas',
  uFrmUpdate in 'uFrmUpdate.pas' {FormUpdate},
  frmLogin in 'frmLogin.pas' {Login},
  uFormLabelData in 'uFormLabelData.pas' {FormLabelData},
  uFormInfo in 'uFormInfo.pas' {FormInfo};

{$R *.res}

begin
  Application.Initialize;
  if not AppHasRun(Application.Handle ) then
  begin
  Application.Title := 'Shipper_Package_Print';
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TWeightForm, WeightForm);
  Application.CreateForm(TFormInfo, FormInfo);
  Application.Run;
  end;
end.
