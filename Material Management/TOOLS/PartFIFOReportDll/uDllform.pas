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
  FormMain := TFormMain.Create(Self);
  With FormMain do
  begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    ImageAll.Picture := Imagemain.Picture;
    ImageAll2.Picture := Imagemain.Picture;
    UpdateUserID := Self.UpdateUserID;
    QryTemp.RemoteServer := G_sockConnection;
    QryTemp.ProviderName := 'DspQryTemp1';
    Show;
  end;
end;

end.
