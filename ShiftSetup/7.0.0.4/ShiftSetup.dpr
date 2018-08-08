program ShiftSetup;

uses
  Forms,
  uProject in 'uProject.pas' {formProject},
  uMain in 'uMain.pas' {formMain},
  uDM in 'uDM.pas' {dmProject: TDataModule},
  uChange in 'uChange.pas' {formChangeShift};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TformProject, formProject);
  Application.CreateForm(TdmProject, dmProject);
  Application.CreateForm(TformMain, formMain);
  Application.CreateForm(TformChangeShift, formChangeShift);
  Application.Run;
end.
