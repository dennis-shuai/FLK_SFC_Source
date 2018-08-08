unit tuDllForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uTravelCard,
  jpeg, ExtCtrls, SConnect, IniFiles;

type
  TfDllForm = class(TForm)
    Imagemain: TImage;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsSN: String;
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
  
  fTravelCard := TfTravelCard.Create(Self);
  With fTravelCard do
  begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    UpdateUserID := Self.UpdateUserID;    
    TlbReportFile.RemoteServer := G_sockConnection;
    TlbReportFile.ProviderName := 'DspReportFile';
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    QryData.RemoteServer := G_sockConnection;
    gsSN := Self.gsSN;
    Show;
    UpdateUserID := Self.UpdateUserID;
  end;
end;

procedure TfDllForm.LoadImage;
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('Query', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
end;

end.
