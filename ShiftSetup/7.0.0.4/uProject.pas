unit uProject;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus;

type
  TformProject = class(TForm)
    MainMenu1: TMainMenu;
    ChangeShift1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure ChangeShift1Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure AddAPServer(ServerName : String);
    procedure InitialForm();
    { Public declarations }
  end;

var
  formProject: TformProject;

implementation

uses uDM, uMain, uChange;

{$R *.dfm}

procedure TformProject.AddAPServer(ServerName : String);
begin
  dmProject.SimpleObjectBroker1.Servers.Add;
  dmProject.SimpleObjectBroker1.Servers[dmProject.SimpleObjectBroker1.Servers.Count-1].ComputerName := ServerName;
  dmProject.SimpleObjectBroker1.Servers[dmProject.SimpleObjectBroker1.Servers.Count-1].Enabled := True;
end;

procedure TformProject.InitialForm();
begin
  formMain.InitialForm();
end;

procedure TformProject.FormShow(Sender: TObject);
var
  F : TextFile;
  S : String;
  bOK : Boolean;
begin
  formMain := TformMain.Create(Self);
  formMain.Parent := Self ;
  formMain.Align := alClient ;
  formMain.BorderStyle := bsNone ;
  formMain.Visible := True ;

  dmProject.SocketConnection1.Host:='';
  dmProject.SocketConnection1.Address:='';

  bOK := False;
  if not FileExists(GetCurrentDir + '\ApServer.cfg') then
  begin
    MessageDlg( 'Cann''t find ApServer.cfg !' , mtError , [ mbOK ] , 0 );
    Application.Terminate;
  end else                    
  begin
    AssignFile(F, GetCurrentDir + '\ApServer.cfg');
    Reset(F);
    while True do
    begin
      Readln(F, S);
      if Trim(S) = '' then
        Break;
      AddAPServer(Trim(S));
      bOK := True;
    end;
    CloseFile(F);
    if bOK = True then
      InitialForm()
    else
    begin
      MessageDlg( 'Cann''t find AP Server Address !' , mtError , [ mbOK ] , 0 );
      Application.Terminate;
      Close;
    end;
  end;
end;

procedure TformProject.ChangeShift1Click(Sender: TObject);
begin
  formChangeShift.ShowModal; 
end;

end.
