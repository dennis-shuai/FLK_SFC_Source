unit uReprintPallet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,DB;

type
  TfReprint = class(TForm)
    lbl1: TLabel;
    edtSN: TEdit;
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    sPallet,sPart:string;
  end;

var
  fReprint: TfReprint;

implementation

uses umain;

{$R *.dfm}

procedure TfReprint.edtSNKeyPress(Sender: TObject; var Key: Char);
begin
   if Key <> #13 then exit;
   with fMain.qrytemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftstring,'SN',ptInput);
      CommandText :='Select a.PALLET_NO,B.PART_NO FROM SAJET.G_SN_STATUS a ,SAJET.SYS_PART B '+
                    ' WHERE a.CUSTOMER_SN =:SN and a.Model_ID=b.PART_ID ';
      Params.ParamByName('SN').AsString := UpperCase(TRIM(edtSN.Text));
      Open;

      if IsEmpty then begin
         MessageDlg( 'NO SN',mterror,[mbOK],0);
         ModalResult := mrNone;
      end else begin
         sPallet := fieldbyName('Pallet_no').AsString;
         sPart := fieldbyName('Part_no').AsString;

         ModalResult := mrOK;
      end;
   end;


end;

end.
