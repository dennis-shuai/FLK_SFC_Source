unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uCMInput,
  jpeg, ExtCtrls, SConnect, uLang, IniFiles;

type
  TfDllform = class(TForm)
    Imagemain: TImage;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
  end;

var
  fDllform: TfDllform;
  G_sockConnection : TSocketConnection;
  G_FunctionName : String;

implementation

{$R *.DFM}

procedure TfDllform.FormShow(Sender: TObject);
var sIniFile : String;
begin
  fCMInput := TfCMInput.Create(Self);
  With fCMInput do
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
    QryTemp1.RemoteServer := G_sockConnection;
    QryTemp1.ProviderName := 'DspQryTemp1';
    SProc.RemoteServer := G_sockConnection;
    SProc.ProviderName := 'DspStoreproc';
    //FunctionName := G_FunctionName;
    //LabTitle1.Caption := FunctionName;
    //LabTitle2.Caption := FunctionName;
    // add by MultiLanguage


    With TIniFile.Create('SAJET.ini') do
    begin
      iTerminal := ReadString('CM','Terminal','') ;
      free;
    end;

    {Language := TLanguage.Create(fCOBInput);
    Language.ModuleName := 'PNWareHouse';
    Language.GetLanguage(QryTemp);
    With TInifile.Create(sIniFile) do
    begin
      sS := ReadString('SYSTEM','LANGUAGE','English');
      Free;
    end;
    Language.TransToLanguage := sS;
    Language.Translation(fCOBInput);
    Language.CurrentLanguage := sS; }
    // add by MultiLanguage end
    Show;
  end;
end;

procedure TfDllform.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   // fCMInput.KillTask('lppa.exe');
end;

end.
