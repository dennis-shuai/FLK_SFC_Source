unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, SConnect, MConnect, ObjBrkr, DB, DBClient;

type
  TfDllMain = class(TForm)
    Imagemain: TImage;
    SocketConnection1: TSocketConnection;
    SimpleObjectBroker1: TSimpleObjectBroker;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
    function LoadApServer: Boolean;
  end;

var
  fDllMain: TfDllMain;
  G_sockConnection : TSocketConnection;

implementation

uses uManager, uFilter, uCheck;

{$R *.DFM}

Function TfDllMain.LoadApServer : Boolean;
Var F : TextFile;
    S : String;
begin
  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  If not FileExists(GetCurrentDir+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,GetCurrentDir+'\ApServer.cfg');
  Reset(F);
  While True do
  begin
    Readln(F, S);
    If S <> '' Then
    begin
      SimpleObjectBroker1.Servers.Add;
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
    end Else
      Break;
  end;
  CloseFile(F);
  Result := True;
end;

procedure TfDllMain.FormShow(Sender: TObject);
var stPath: String;
begin
  UpdateUserID := Uppercase(ParamStr(0));
  LoadApServer;
  UpdateUserID := ParamStr(1);
  stPath := GetCurrentDir;
  if Copy(stPath,Length(stPath) - 1, 1) <> '\' then
     stPath := stPath + '\';
  fManager := TfManager.Create(Self);
  With fManager do
  begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    ImageAll.Picture := Imagemain.Picture;
    UpdateUserID := Self.UpdateUserID;
    sPath := stPath;
    fFilter.QryData.RemoteServer := SocketConnection1;
    fFilter.QryData.ProviderName := 'DspQryData';
    QryTemp.RemoteServer := SocketConnection1;
    QryTemp.ProviderName := 'DspQryTemp1';
    QryTemp1.RemoteServer := SocketConnection1;
    QryTemp1.ProviderName := 'DspQryTemp1';
    QryTemp2.RemoteServer := SocketConnection1;
    QryTemp2.ProviderName := 'DspQryTemp1';
    Show;
  end;
end;

end.
