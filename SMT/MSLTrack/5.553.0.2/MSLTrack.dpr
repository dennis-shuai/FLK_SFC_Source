program MSLTrack;

uses
  Forms,
  uManager in 'uManager.pas' {fManager},
  uDllform in 'uDllform.pas' {fDllMain},
  uFilter in 'uFilter.pas' {fFilter},
  uData in 'uData.pas' {fData},
  uCheck in 'uCheck.pas' {fCheck};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfDllMain, fDllMain);
  Application.CreateForm(TfManager, fManager);
  Application.CreateForm(TfFilter, fFilter);
  Application.CreateForm(TfData, fData);
  Application.CreateForm(TfCheck, fCheck);
  Application.Run;
end.
