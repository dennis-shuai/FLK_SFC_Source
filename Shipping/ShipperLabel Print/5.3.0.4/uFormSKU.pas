unit uFormSKU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormSKU = class(TForm)
    Label1: TLabel;
    TBarcode: TEdit;
    LabNotNo: TLabel;
    Label2: TLabel;
    EditWO: TEdit;
    Button1: TButton;
    Label3: TLabel;
    edtLine: TEdit;
    Label4: TLabel;
    edtDate: TEdit;
    Label5: TLabel;
    edtEIPN: TEdit;
    procedure TBarcodeKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure EditWOKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormSKU: TFormSKU;

implementation

{$R *.dfm}

uses uFormPrint;

procedure TFormSKU.TBarcodeKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    if  TBarcode.Text = '' then Exit ;
    Label_WO := Trim(EditWO.Text );
    Lot_No := Trim(TBarcode.Text) ;
    ModalResult := mrOK;
  end;
end;

procedure TFormSKU.FormShow(Sender: TObject);
begin
  Self.Left :=Round((Screen.Width -Self.Width)/2);
  Self.Top :=Round((Screen.Height-Self.Height)/2);
end;

procedure TFormSKU.EditWOKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    TBarcode.SetFocus ;
    TBarcode.SelectAll ;
  end;
end;

procedure TFormSKU.Button1Click(Sender: TObject);
begin
    if TBarcode.Text = '' then Exit ;
    Label_WO := Trim(EditWO.Text );
    Lot_No := Trim(TBarcode.Text) ;
    ModalResult := mrOK;
end;

end.
