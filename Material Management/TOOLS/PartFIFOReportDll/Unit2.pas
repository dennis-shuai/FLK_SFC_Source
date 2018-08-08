unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Grids, DBGrids, StdCtrls, ExtCtrls, Buttons, DBClient;

type
  TForm2 = class(TForm)
    ds1: TDataSource;
    pnl1: TPanel;
    dbgrd1: TDBGrid;
    lbl1: TLabel;
    edt1: TEdit;
    procedure FormShow(Sender: TObject);
    procedure edt1KeyPress(Sender: TObject; var Key: Char);
    procedure dbgrd1CellClick(Column: TColumn);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Unit1;

{$R *.dfm}

procedure TForm2.FormShow(Sender: TObject);
begin
    edt1.Clear;
    edt1.SetFocus;
end;

procedure TForm2.edt1KeyPress(Sender: TObject; var Key: Char);
var WO:String;
begin
   if  Key=#13 then
   begin
      WO := edt1.Text;
      ds1.DataSet := Form1.QryTemp;
      with Form1 do
      begin
         QryTemp.Close;
         QryTemp.Params.Clear;
         QryTemp.Params.CreateParam(ftString,'WORK_ORDER',ptInput) ;
         QryTemp.CommandText := ' select  distinct Pallet_NO   from   sajet.g_SN_Status  '
                       +'  where Work_order = :WORK_ORDER and Pallet_NO <>''N/A''   union    '
                       +'  ( select distinct QC_Type  as Pallet_NO  from  sajet.G_QC_Lot  '
                       +'  where WorK_order = :WORK_ORDER and Length(QC_Type)>=8  )   ';
         QryTemp.Params.ParamByName('WORK_ORDER').AsString := WO;
         QryTemp.Open;

      end;
   end;
end;

procedure TForm2.dbgrd1CellClick(Column: TColumn);
//var Pallet_NO : string;
begin
    Form1.edt1.Text  := dbgrd1.SelectedField.AsString;
    ModalResult := mrOK;
end;

end.
