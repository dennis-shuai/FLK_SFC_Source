unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uDetail,
  jpeg, ExtCtrls, SConnect, IniFiles;

type
  TfDllReprintLabel = class(TForm)
    Imagemain: TImage;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
  end;

var
  fDllReprintLabel: TfDllReprintLabel;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllReprintLabel.FormShow(Sender: TObject);
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
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    QryTemp1.RemoteServer := G_sockConnection;
    QryTemp1.ProviderName := 'DspQryFTemp';
    Show;
  end;
end;

procedure TfDllReprintLabel.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  fDetail.Close;
  fDetail.free;
end;

end.
