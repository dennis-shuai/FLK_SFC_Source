unit uDllLocateform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uLocate,
  jpeg, ExtCtrls, SConnect, IniFiles;

type
  TfDllLocateForm = class(TForm)
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
  fDllLocateForm: TfDllLocateForm;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllLocateForm.FormShow(Sender: TObject);
begin
  LoadImage;

  fLocate := TfLocate.Create(Self);
  With fLocate do
  begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    ImageAll.Picture := Imagemain.Picture;
    UpdateUserID := Self.UpdateUserID;
    QryData.RemoteServer := G_sockConnection;
    QryData.ProviderName := 'DspQryData';
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    SProc.RemoteServer := G_sockConnection;
    SProc.ProviderName := 'DspStoreproc';  
    Show;
  end;
end;

procedure TfDllLocateForm.LoadImage;
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('Data Center', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
end;

end.
