program HPStation_SFCS;

uses
  Forms,
  Windows,
  Dialogs,
  uMain in 'uMain.pas' {fMain},
  Login in 'Login.pas' {fLogin};

{$R *.res}
var hand:Thandle;

begin
   Application.Initialize;
   Hand:=CreateMutex(nil,False,'HPStation_SFCS');
   if GetlastError=ERROR_ALREADY_EXISTS then
   Begin
        //ShowMessage('Please Attention,System had been Running !!');
      ShowMessage('SFCS程式已經開?!!');
      Application.Terminate;
   end else Begin
     //Application.CreateForm(TfMain, fMain);
     Application.CreateForm(TfLogin, fLogin);
     Application.Run;
   end;
end.
