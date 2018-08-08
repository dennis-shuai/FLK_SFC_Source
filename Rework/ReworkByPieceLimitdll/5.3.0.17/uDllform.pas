unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uReworkbyPiece,
  jpeg, ExtCtrls, SConnect, IniFiles;

type
  TfDllReworkbyPiece = class(TForm)
    Imagemain: TImage;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
    procedure LoadImage;
  end;

var
  fDllReworkbyPiece: TfDllReworkbyPiece;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllReworkbyPiece.FormShow(Sender: TObject);
begin
  LoadImage;
  fReworkbyPiece := TfReworkbyPiece.Create(Self);
  With fReworkbyPiece do
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
    QryTemp1.RemoteServer := G_sockConnection;
    QryTemp1.ProviderName := 'DspQryTemp1';
    SProc.RemoteServer := G_sockConnection;
    SProc.ProviderName := 'DspStoreproc';
    Show;
  end;

end;

procedure TfDllReworkbyPiece.LoadImage;
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('Rework', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
end;

end.
