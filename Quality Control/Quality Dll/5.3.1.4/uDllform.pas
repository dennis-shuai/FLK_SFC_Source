unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uQuality,
  jpeg, ExtCtrls, SConnect, StdCtrls, Buttons, IniFiles;

type
  TfDllQuality = class(TForm)
    Panel1: TPanel;
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
  fDllQuality: TfDllQuality;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllQuality.FormShow(Sender: TObject);
begin
  LoadImage;
  fQuality := TfQuality.Create(self);
  With fQuality do
  begin
    //fQuality.ScaleBy(self.Height,600);

    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    UpdateUserID := Self.UpdateUserID;
    QryData.RemoteServer := G_sockConnection;
    QryData.ProviderName := 'DspQryData';
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    QryTemp2.RemoteServer := G_sockConnection;
    QryTemp2.ProviderName := 'DspQryTemp1';
    SProc.RemoteServer := G_sockConnection;
    SProc.ProviderName := 'DspStoreproc';
    Show;
  end;

end;

procedure TfDllQuality.LoadImage;
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('Quality Control', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
end;

end.
