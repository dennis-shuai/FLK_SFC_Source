unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uformMain,
  jpeg, ExtCtrls, SConnect,IniFiles;

type
  TfDllform = class(TForm)
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
  fDllform: TfDllform;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllform.FormShow(Sender: TObject);
begin
  LoadImage;
  formMain := TformMain.Create(Self);

  With formMain do
  begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    ImageAll.Picture := Imagemain.Picture;
    UpdateUserID := Self.UpdateUserID;
    QryData.RemoteServer := G_sockConnection;
    QryData.ProviderName := 'DspQryData';
    QryData1.RemoteServer := G_sockConnection;
    QryData1.ProviderName := 'DspQryData1';
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    SProc.RemoteServer := G_sockConnection;
    SProc.ProviderName := 'DspStoreproc';
    Show;
  end;
end;
procedure TfDllform.LoadImage;
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create(ExtractFilePath(Application.EXEName)+'\BackGround.Ini');
  sImage := pIni.ReadString('Data Center', 'BackGround', ExtractFilePath(Application.EXEName)+'\Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
end;
end.
