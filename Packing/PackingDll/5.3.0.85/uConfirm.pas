unit uConfirm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfConfirm = class(TForm)
    Button1: TButton;
    Panel1: TPanel;
    LabMsg: TLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fConfirm: TfConfirm;

implementation

{$R *.dfm}

procedure TfConfirm.FormShow(Sender: TObject);
begin
  messageBeep(48);
end;

end.
