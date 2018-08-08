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
    QryCartonData.RemoteServer := G_sockConnection;
    QryCartonData.ProviderName := 'DspQryData';
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    QryFIFO.RemoteServer := G_sockConnection;
    QryFIFO.ProviderName := 'DspQryTemp1';
    QryMaterial.RemoteServer := G_sockConnection;
    QryMaterial.ProviderName := 'DspQryTemp1';
    QryBoxRepack.RemoteServer := G_sockConnection;
    QryBoxRepack.ProviderName := 'DspQryTemp1';
    Qryfctype.RemoteServer := G_sockConnection;
    Qryfctype.ProviderName := 'DspQryTemp1';
    Qrywip.RemoteServer := G_sockConnection;
    Qrywip.ProviderName := 'DspQryTemp1';
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
