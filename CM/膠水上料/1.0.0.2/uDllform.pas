unit uDllform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, SConnect;

type
  TfDllForm = class(TForm)
    Imagemain: TImage;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
  end;

var
  fDllForm: TfDllForm;
  G_sockConnection : TSocketConnection;

implementation

uses Unit1;

{$R *.DFM}

procedure TfDllForm.FormShow(Sender: TObject);
begin
  Form1 := TForm1.Create(Self);
  With Form1 do
  begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    ImageAll.Picture := Imagemain.Picture;
    UpdateUserID := Self.UpdateUserID;
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    //ClientDataSet2.RemoteServer := G_sockConnection;
    //ClientDataSet2.ProviderName := 'DspQryTemp1';
    //QryTemp2.RemoteServer := G_sockConnection;
   // QryTemp2.ProviderName := 'DspQryTemp1';
    //Qry2.RemoteServer := G_sockConnection;
    //Qry2.ProviderName := 'DspQryTemp1';
    //Qry3.RemoteServer := G_sockConnection;
    //Qry3.ProviderName := 'DspQryTemp1';
    SProc.RemoteServer := G_sockConnection;
    SProc.ProviderName := 'DspStoreproc';
    Show;
  end;
end;

end.
