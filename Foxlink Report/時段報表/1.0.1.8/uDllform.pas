unit uDllForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, SConnect, IniFiles;

type
  TfDllForm = class(TForm)
    Imagemain: TImage;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, RPID : String;
    procedure LoadImage;
  end;

var
  fDllForm: TfDllForm;
  G_sockConnection : TSocketConnection;

implementation

uses uDetail;

{$R *.DFM}

procedure TfDllForm.FormShow(Sender: TObject);
begin
  LoadImage;
  fDetail := TfDetail.Create(Self);
  With fDetail do
  begin
    Parent := Self;
    //Align := alClient;
    BorderStyle := bsNone;
    WindowState := wsMaximized;
    ImageAll.Picture := Imagemain.Picture;
    UpdateUserID := Self.UpdateUserID;
    RPID := Self.RPID;
    QryData.RemoteServer := G_sockConnection;
    QryData.ProviderName := 'DspQryData';
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    QryDefect.RemoteServer := G_sockConnection;
    QryDefect.ProviderName := 'DspQryData';
    QryDate.RemoteServer := G_sockConnection;
    QryDate.ProviderName := 'DspQryData';
    SProc.RemoteServer := G_sockConnection;
    Show;
    UpdateUserID := Self.UpdateUserID;
  end;
end;

procedure TfDllForm.LoadImage;
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create(ExtractFilePath(Application.ExeName)+'BackGround.Ini');
  sImage := pIni.ReadString('FoxReport', 'BackGround', ExtractFilePath(Application.ExeName)+'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
end;

end.
