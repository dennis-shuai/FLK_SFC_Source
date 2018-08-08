unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, SConnect, uLang, IniFiles;

type
  TfDllform = class(TForm)
    Imagemain: TImage;
    procedure FormShow(Sender: TObject);
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

uses uMainForm;

{$R *.DFM}

procedure TfDllform.FormShow(Sender: TObject);
begin
  fMainForm := TfMainForm.Create(Self);
  With fMainForm do
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

    With TIniFile.Create('SAJET.ini') do
    begin
      iTerminal := ReadString('COB','Terminal','') ;
      free;
    end;
    Show;
  end;
end;

end.
