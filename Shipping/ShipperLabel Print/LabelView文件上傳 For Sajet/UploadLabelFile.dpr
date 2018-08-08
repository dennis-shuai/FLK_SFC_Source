program UploadLabelFile;

uses
  Forms,
  uMainForm in 'uMainForm.pas' {FormMain},
  frmLogin in 'frmLogin.pas' {Login};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'UploadLabelFile';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
