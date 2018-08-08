program AutoScan;

uses
  Forms,
  uMain in 'uMain.pas' {fMain},
  uSetting in 'uSetting.pas' {fSetting};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
