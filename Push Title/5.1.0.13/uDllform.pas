unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, SConnect, ExtCtrls,uASSY ;

type
  TfDllMain = class(TForm)
    Imagemain: TImage;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
  end;

var
  fDllMain: TfDllMain;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllMain.FormShow(Sender: TObject);
begin
  fASSY := TfASSY.Create(Self);
  With fASSY do
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

end.
