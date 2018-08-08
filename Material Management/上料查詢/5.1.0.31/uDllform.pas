unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, SConnect, ExtCtrls,uSMTQuery,IniFiles ;

type
  TfDllMain = class(TForm)
    Imagemain: TImage;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
    procedure ResizeForm(high,width:integer);
    procedure LoadImage;
  end;

var
  fDllMain: TfDllMain;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllMain.ResizeForm(high,width:integer);
begin
  //fDllMain.Height:=high;
  //fDllMain.Width:=width;
  //fQuerySN.ResizeForm(high,width);
 // showmessage(inttostr(high)+'  '+inttostr(width));
end;

procedure TfDllMain.LoadImage;
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('Query', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
end;

procedure TfDllMain.FormShow(Sender: TObject);
begin
  LoadImage;
  fMaterial:= TfMaterial.Create(Self);
  With fMaterial do
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
    QryData1.RemoteServer:= G_sockConnection;
    QryData1.ProviderName:= 'DspQryData1';
    QryTemp1.RemoteServer := G_sockConnection;
    QryTemp1.ProviderName := 'DspQryData';
    QryFeeder.RemoteServer := G_sockConnection;
    QryFeeder.ProviderName := 'DspQryData';
    Qrymap.RemoteServer := G_sockConnection;
    Qrymap.ProviderName := 'DspQryData';
    Show;
  end;

end;

end.
