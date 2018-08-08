program PrintReplaceLable;

uses
  Forms,
  uMain in 'uMain.pas' {formMain},
  uConfig in 'uConfig.pas' {formConfig},
  uTest in 'uTest.pas' {formTest};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TformMain, formMain);
  Application.CreateForm(TformConfig, formConfig);
  Application.CreateForm(TformTest, formTest);
  Application.Run;
end.
