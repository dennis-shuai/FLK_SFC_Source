unit uDllEmpform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uEmp,
  jpeg, ExtCtrls, SConnect, IniFiles;

type
  TfDllEmpForm = class(TForm)
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
  fDllEmpForm: TfDllEmpForm;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllEmpForm.FormShow(Sender: TObject);
begin
  LoadImage;
  
  fEmp := TfEmp.Create(Self);
  With fEmp do
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
    UpdateUserID := Self.UpdateUserID;
  end;
end;

procedure TfDllEmpForm.LoadImage;
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('Data Center', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Imagemain.Picture.LoadFromFile(sImage);
end;

end.
