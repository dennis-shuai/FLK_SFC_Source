unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uWOManager,
  jpeg, ExtCtrls, SConnect, IniFiles;

type
  TfDllWOManager = class(TForm)
    Imagemain: TImage;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
    procedure LoadImage(var sImage1, sImage2: string);
  end;

var
  fDllWOManager: TfDllWOManager;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllWOManager.FormShow(Sender: TObject);
var sImage1, sImage2: string;
begin
  LoadImage(sImage1, sImage2);
  fWOManager := TfWOManager.Create(Self);
  With fWOManager do
  begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    ImageAll.Picture := Imagemain.Picture;
    UpdateUserID := Self.UpdateUserID;
    QryData.RemoteServer := G_sockConnection;
    QryData.ProviderName := 'DspQryData';
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    QryTemp2.RemoteServer := G_sockConnection;
    QryTemp2.ProviderName := 'DspQryTemp1';
    QryData1.RemoteServer := G_sockConnection;
    QryData1.ProviderName := 'DspQryData1';
    SProc.RemoteServer := G_sockConnection;
    SProc.ProviderName := 'DspStoreproc';
    Show;
  end;
end;

procedure TfDllWOManager.LoadImage(var sImage1, sImage2: string);
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('W/O Manager', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
end;

end.
