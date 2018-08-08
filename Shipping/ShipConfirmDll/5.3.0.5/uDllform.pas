unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uDetail,
  jpeg, ExtCtrls, SConnect, IniFiles;

type
  TfDllShipping = class(TForm)
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
  fDllShipping: TfDllShipping;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllShipping.FormShow(Sender: TObject);
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
    QryData.RemoteServer := G_sockConnection;
    QryData.ProviderName := 'DspQryData';
    QryTemp1.RemoteServer := G_SockConnection;
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    QryTemp2.RemoteServer := G_sockConnection;
    QryTemp2.ProviderName := 'DspQryFTemp';
    QryTemp3.RemoteServer := G_sockConnection;
    QryTemp3.ProviderName := 'DspQryFTemp';
    SProc.RemoteServer := G_sockConnection;
    SProc.ProviderName := 'DspStoreproc';
    Show;
  end;
end;

procedure TfDllShipping.LoadImage;
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('IQC', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
end;

end.
