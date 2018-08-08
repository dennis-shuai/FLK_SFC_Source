unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uRepair,
  jpeg, ExtCtrls, SConnect, IniFiles;

type
  TfDllMain = class(TForm)
    Imagemain: TImage;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
    procedure LoadImage;
  end;

var
  fDllMain: TfDllMain;
  G_sockConnection : TSocketConnection;

implementation

uses uDetail;

{$R *.DFM}

procedure TfDllMain.FormShow(Sender: TObject);
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
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    Show;
  end;
end;

procedure TfDllMain.LoadImage;
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('Repair', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
end;

procedure TfDllMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    if fRepair <> nil then
    begin
      fRepair.free;
      fRepair := nil;
    end;
    if fDetail <> nil then
    begin
      fDetail.free;
      fDetail := nil;
    end;
  except
    on E: Exception do raise Exception.create('(CloseSajetDll)' + E.Message);
  end;
end;

end.
