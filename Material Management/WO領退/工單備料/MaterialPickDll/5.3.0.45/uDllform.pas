unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uDetail, //uIQCNewLot,//uQuality,
  jpeg, ExtCtrls, SConnect, IniFiles;

type
  TfDllForm = class(TForm)
    Imagemain: TImage;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsType: string;
    procedure LoadImage;
  end;

var
  fDllForm: TfDllForm;
  G_sockConnection: TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllForm.FormShow(Sender: TObject);
begin
  LoadImage;
  fDetail := TfDetail.Create(Self);
  with fDetail do
  begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    ImageAll.Picture := Imagemain.Picture;
    UpdateUserID := Self.UpdateUserID;
    gsParam := Self.gsType;
    QryMaterial.RemoteServer := G_sockConnection;
    QryMaterial.ProviderName := 'DspQryData';
    QryGroup.RemoteServer := G_sockConnection;
    QryGroup.ProviderName := 'DspQryFTemp';
    QryDetail.RemoteServer := G_sockConnection;
    QryDetail.ProviderName := 'DspQryData';
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    QryTemp1.RemoteServer := G_sockConnection;
    QryTemp1.ProviderName := 'DspQryFTemp'; 
    QryWM.RemoteServer := G_sockConnection;
    QryWM.ProviderName := 'DspQryFTemp';
    SProc.RemoteServer := G_sockConnection;
    Show;
  end;
end;

procedure TfDllForm.LoadImage;
var pIni: TIniFile; sImage: string;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('IQC', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
end;

end.

