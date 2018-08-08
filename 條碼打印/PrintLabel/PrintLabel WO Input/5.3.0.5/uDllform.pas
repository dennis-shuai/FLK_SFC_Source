unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uPrintLabel,
  jpeg, SConnect, ExtCtrls, IniFiles;

type
  TfDllPacking = class(TForm)
    Imagemain: TImage;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsType: string;
  end;

var
  fDllPacking: TfDllPacking;
  G_sockConnection: TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllPacking.FormShow(Sender: TObject);
var pIni: TIniFile; sImage: string;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('PrintLabel', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    ImageMain.Picture.LoadFromFile(sImage);
  fPrintLabel := TfPrintLabel.Create(Self);
  with fPrintLabel do
  begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    ImageAll.Picture := Imagemain.Picture;
    UpdateUserID := Self.UpdateUserID;
    gsType := Self.gsType;
    QryData.RemoteServer := G_sockConnection;
    QryData.ProviderName := 'DspQryData';
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    SProc.RemoteServer := G_sockConnection;
    SProc.ProviderName := 'DspStoreproc';
    Show;
  end;
end;

end.

