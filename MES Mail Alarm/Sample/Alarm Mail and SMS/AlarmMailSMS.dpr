program AlarmMailSMS;

uses
  Forms,
  UnitMailSMSTest in 'UnitMailSMSTest.pas' {formMailSMSTest};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TformMailSMSTest, formMailSMSTest);
  Application.Run;
end.
