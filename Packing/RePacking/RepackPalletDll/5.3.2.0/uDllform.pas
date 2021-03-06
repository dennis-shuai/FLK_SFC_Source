unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uRepacking,
  jpeg, ExtCtrls, SConnect, IniFiles;

type
  TfDllRepacking = class(TForm)
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
  fDllRepacking: TfDllRepacking;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllRepacking.FormShow(Sender: TObject);
begin
  LoadImage;
  fRepacking := TfRepacking.Create(Self);
  With fRepacking do
  begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    ImageAll.Picture := Imagemain.Picture;
    UpdateUserID := Self.UpdateUserID;
    QryPalletData.RemoteServer := G_sockConnection;
    QryPalletData.ProviderName := 'DspQryData';
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    QryFIFO.RemoteServer := G_sockConnection;
    QryFIFO.ProviderName := 'DspQryTemp1';
    QryMaterial.RemoteServer := G_sockConnection;
    QryMaterial.ProviderName := 'DspQryTemp1';
    QryFCTYPE.RemoteServer := G_sockConnection;
    QryFCTYPE.ProviderName := 'DspQryTemp1';
    SProc.RemoteServer := G_sockConnection;
    SProc.ProviderName := 'DspStoreproc';
    Show;
  end;
end;

procedure TfDllRepacking.LoadImage;
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('Packing', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
end;

end.
