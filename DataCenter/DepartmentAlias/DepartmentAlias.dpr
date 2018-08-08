program DepartmentAlias;

uses
  Forms,
  Unit1 in 'Unit1.pas' {MainForm},
  uData in 'uData.pas' {fData};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
