program DeviceDefectInfoInput;

uses
  Forms,
  MainForm in 'MainForm.pas' {uMainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TuMainForm, uMainForm);
  Application.Run;
end.
