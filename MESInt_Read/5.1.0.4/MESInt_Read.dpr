program MESInt_Read;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Transfer},
  VarWIPUnit in 'VarWIPUnit.pas',
  Unit2 in 'Unit2.pas' {Form2};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TTransfer, Transfer);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
