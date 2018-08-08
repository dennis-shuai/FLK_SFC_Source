program Quality;

uses
  Sharemem,
  Forms,
  uformMain in 'uformMain.pas' {formMain};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TformMain, formMain);
  Application.Run;
end.
