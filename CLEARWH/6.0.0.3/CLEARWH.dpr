program CLEARWH;

uses
  Forms,
  UnitMAIN in 'UnitMAIN.pas' {FormMAIN};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMAIN, FormMAIN);
  Application.Run;
end.
