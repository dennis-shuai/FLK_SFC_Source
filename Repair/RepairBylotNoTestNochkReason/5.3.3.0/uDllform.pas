unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uRepair,
  jpeg, ExtCtrls, SConnect, IniFiles;

type
  TfDllRepair = class(TForm)
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
  fDllRepair: TfDllRepair;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllRepair.FormShow(Sender: TObject);
begin
  LoadImage;
  fRepair := TfRepair.Create(Self);
  With fRepair do
  begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    ImageAll.Picture := Imagemain.Picture;
    UpdateUserID := Self.UpdateUserID;
    gsSN := Self.gsSN;
    QryData.RemoteServer := G_sockConnection;
    QryData.ProviderName := 'DspQryData';
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    QryTemp2.RemoteServer := G_sockConnection;
    QryTemp2.ProviderName := 'DspQryTemp1';
    QryReplace.RemoteServer := G_sockConnection;
    QryReplace.ProviderName := 'DspQryFTemp';
    QryRepair.RemoteServer := G_sockConnection;
    QryRepair.ProviderName := 'DspQryData1';
    SProc.RemoteServer := G_sockConnection;
    SProc.ProviderName := 'DspStoreproc';
    Show;
  end;

end;

procedure TfDllRepair.LoadImage;
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('Repair', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
end;

end.
