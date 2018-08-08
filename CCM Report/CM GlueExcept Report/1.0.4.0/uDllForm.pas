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
    QryDetail.RemoteServer := G_sockConnection;
    QryDetail.ProviderName := 'DspQryData';
    QrySum.RemoteServer := G_sockConnection;
    QrySum.ProviderName := 'DspQryTemp1';
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
