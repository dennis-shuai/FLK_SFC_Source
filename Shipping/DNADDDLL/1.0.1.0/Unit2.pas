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
    procedure dbgrd1CellClick(Column: TColumn);
    procedure edt1Change(Sender: TObject);
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

procedure TForm2.dbgrd1CellClick(Column: TColumn);
//var Pallet_NO : string;
begin
    Form1.edtWO.Text  := dbgrd1.SelectedField.AsString;
    ModalResult := mrOK;
end;

procedure TForm2.edt1Change(Sender: TObject);
var WO:string;
begin
      WO := trim(edt1.Text);
      ds1.DataSet := Form1.QryTemp;
      with Form1 do
      begin
         QryTemp.Close;
         QryTemp.Params.Clear;
         QryTemp.Params.CreateParam(ftString,'WORK_ORDER',ptInput) ;
         QryTemp.CommandText := ' select distinct WORK_ORDER  from   sajet.G_WO_BASE '
                       +'  where (Work_order like   :WORK_ORDER  and WO_Status=''2'')'
                       +'  or (Work_order like   :WORK_ORDER  and WO_Status=''3'')';
         QryTemp.Params.ParamByName('WORK_ORDER').AsString := '%'+WO+'%';
         QryTemp.Open;

      end;
end;

end.
