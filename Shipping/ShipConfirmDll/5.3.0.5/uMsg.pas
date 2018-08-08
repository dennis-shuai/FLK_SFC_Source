unit uMsg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons;

type
  TfMsg = class(TForm)
    PanType: TPanel;
    Panel1: TPanel;
    Image3: TImage;
    Image1: TImage;
    sbtnOK: TSpeedButton;
    sbtnCancel: TSpeedButton;
    GroupBox1: TGroupBox;
    LabMsg: TLabel;
    procedure sbtnOKClick(Sender: TObject);
    procedure sbtnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fMsg: TfMsg;

implementation

{$R *.dfm}

procedure TfMsg.sbtnOKClick(Sender: TObject);
begin
  ModalResult:=mrOK;
end;

procedure TfMsg.sbtnCancelClick(Sender: TObject);
begin
  ModalResult:=mrCancel;
end;

end.
