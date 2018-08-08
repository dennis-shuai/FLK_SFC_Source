unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Spin;

type
  TForm2 = class(TForm)
    Label3: TLabel;
    seditTime: TSpinEdit;
    Label1: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.BitBtn2Click(Sender: TObject);
begin
  Close;
end;

procedure TForm2.BitBtn1Click(Sender: TObject);
begin
  ModalResult := mrOK;
end;

end.
