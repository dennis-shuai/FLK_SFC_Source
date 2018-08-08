program SFIS;

uses
  Forms,
  Windows,
  Controls,
  dialogs,
  ULogin in 'ULogin.pas' {FrmLogin},
  GCommon in 'GCommon.pas';

{$R *.res}
 var hand:Thandle;

begin
  Application.Initialize;

  Hand:=CreateMutex(nil,False,'FoxLinkV1.0');

  if GetlastError=ERROR_ALREADY_EXISTS then
  Begin
        //ShowMessage('Please Attention,System had been Running !!');
        ShowMessage('提示：系統已打開 !!');
        application.Terminate;
  end else Begin
        FrmLogin:=TFrmLogin.Create(nil);
        If FrmLogin.ShowModal=MrOK then
        begin
            FrmLogin.Free;
            Application.Title := 'FoxLink Communication Bureau';
            Application.Run;
        end Else Begin
            FrmLogin.Free;
            Application.Terminate;
        end;
  End;
  ReleaseMutex(hand);
  CloseHandle(Hand);


end.
