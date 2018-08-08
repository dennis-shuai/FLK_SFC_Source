program CM;

uses
  Forms,
  uformMain in 'uformMain.pas' {formMain},
  uMDIChild in 'uMDIChild.pas' {formMDI};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TformMain, formMain);
  Application.Run;
end.
