unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uDetail,
  jpeg, ExtCtrls, SConnect, IniFiles;

type
  TfDllBCLabel = class(TForm)
    Imagemain: TImage;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelType: String;
  end;

var
  fDllBCLabel: TfDllBCLabel;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllBCLabel.FormShow(Sender: TObject);
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('Barcode Center', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
  fDetail := TfDetail.Create(Self);
  With fDetail do
  begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    ImageAll.Picture := Imagemain.Picture;
    UpdateUserID := Self.UpdateUserID;
    gsLabelType := Self.gsLabelType;
    QryData.RemoteServer := G_sockConnection;
    QryData.ProviderName := 'DspQryData';
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    QryTemp1.RemoteServer := G_sockConnection;
    QryTemp1.ProviderName := 'DspQryFTemp';
    QryGetSeq.RemoteServer := G_sockConnection;
    QryGetSeq.ProviderName := 'DspQryFTemp';
    SProc.RemoteServer := G_sockConnection;
    Show;
  end;
end;

procedure TfDllBCLabel.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  fDetail.Close;
  fDetail.Free;
end;

end.
