program BCLabelPrint;

uses
  Forms,
  uUnit1 in 'uUnit1.pas' {PrintForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TPrintForm, PrintForm);
  Application.Run;
end.
