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
    UpdateUserID : String;
    procedure LoadImage;
  end;

var
  fDllForm: TfDllForm;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllForm.FormShow(Sender: TObject);
begin
  LoadImage;
  fDetail := TfDetail.Create(Self);
  With fDetail do
  begin                                            
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    ImageAll.Picture := Imagemain.Picture;
    UpdateUserID := Self.UpdateUserID;
    QryMaterial.RemoteServer := G_sockConnection;
    QryMaterial.ProviderName := 'DspQryData';
    QryDetail.RemoteServer := G_sockConnection;
    QryDetail.ProviderName := 'DspQryData';
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    SProc.RemoteServer := G_sockConnection;
    SProc.ProviderName := 'DspStoreproc';
    Show;
  end;
end;

procedure TfDllForm.LoadImage;
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('IQC', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
end;

end.
