program MailWoReport;

uses
  Forms,
  UnitMailSMSTest in 'UnitMailSMSTest.pas' {formMailSMSTest};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfMailRepairReport, fMailRepairReport);
  Application.Run;
end.
