unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uSMTReport, //uIQCNewLot,//uQuality,
  jpeg, ExtCtrls, SConnect;

type
  TfDllQuality = class(TForm)
    Imagemain: TImage;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
  end;

var
  fDllQuality: TfDllQuality;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

procedure TfDllQuality.FormShow(Sender: TObject);
begin
  fSMTReport := TfSMTReport.Create(Self);
  With fSMTReport do
  begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    ImageAll.Picture := Imagemain.Picture;
    UpdateUserID := Self.UpdateUserID;
    QryData.RemoteServer := G_sockConnection;
    QryData.ProviderName := 'DspQryData';
    QryData1.RemoteServer := G_sockConnection;
    QryData1.ProviderName := 'DspQryData';
    QryCOBData.RemoteServer := G_sockConnection;
    QryCOBData.ProviderName := 'DspQryData';
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    QryTemp1.RemoteServer := G_sockConnection;
    QryTemp1.ProviderName := 'DspQryTemp1';
    SProc.RemoteServer := G_sockConnection;
    SProc.ProviderName := 'DspStoreproc';
    Show;
  end;
end;

end.
