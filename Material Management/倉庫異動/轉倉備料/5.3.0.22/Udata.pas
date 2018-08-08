unit Udata;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, StdCtrls;

type
  TFData = class(TForm)
    Panelalias: TPanel;
    Label1: TLabel;
    Editalias: TEdit;
    Sgalias: TStringGrid;
    procedure EditaliasKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure SgaliasDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    MaintainType : String;
  end;

var
  FData: TFData;

implementation

uses uDetail;

{$R *.dfm}
procedure TFData.EditaliasKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  var i,j:integer;
begin
   if Ord(Key) = vk_Return then
   begin
      for i:=1 to sgalias.RowCount-1  do
      for j:=0 to sgalias.ColCount do
        sgalias.Cells[j,i]:='';
      sgalias.RowCount:=2;


       With fDetail.qrytemp do
       begin
           close;
           CommandText := 'SELECT warehouse_name from sajet.sys_warehouse  '
                        +' where warehouse_name like :warehouse_name and enabled=''Y''  Order by warehouse_name asc ';
           Params.ParamByName('warehouse_name').AsString := '%' + Trim(editalias.Text) + '%';
           Open;

           if not isempty then
           begin
              sgalias.rowCount :=recordcount+1;
              for i:=1 to recordcount do
              begin
                  sgalias.Cells[0,i]:=fieldbyname('warehouse_name').AsString ;
                  next;
              end;
           end;
       end;
   end;
end;

procedure TFData.FormShow(Sender: TObject);
Var i,j:integer;
begin
   if   MaintainType='STOCK'  then
   begin
      if editalias.Visible = false then
         editalias.Visible := true;
      sgalias.ColCount :=1;
      sgalias.Cells[0,0]:='Stock Name';
   end;
end;

procedure TFData.SgaliasDblClick(Sender: TObject);
var irow,icol:integer;
begin
    irow:=sgalias.Row ;
    icol:=sgalias.Col;
    if   MaintainType='STOCK'  then
    begin
        fdetail.cmbStock.ItemIndex:=-1;
        fdetail.cmbStock.ItemIndex:=fdetail.cmbStock.Items.IndexOf(sgalias.Cells[0,irow]);
        if fdetail.cmbStock.ItemIndex <> -1 then
        begin
            fdetail.cmbStockChange(self);
        end
        else
        begin
           showmessage('The Stock can not use now!');
           fdetail.cmbLocate.Clear;
           exit;
        end;
    end;

    ModalResult := mrOK;
end;

end.
