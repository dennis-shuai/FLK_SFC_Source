unit Udata;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, StdCtrls;

type
  TFData = class(TForm)
    Panelalias: TPanel;
    label1: TLabel;
    Editalias: TEdit;
    Sgalias: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure SgaliasDblClick(Sender: TObject);
    procedure QueryMFGER;
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
Procedure tfdata.Querymfger;
var i,j:integer;
begin
    for i:=1 to sgalias.RowCount-1  do
      for j:=0 to sgalias.ColCount do
        sgalias.Cells[j,i]:='';
      sgalias.RowCount:=2;


       With fDetail.qrytemp do
       begin
           close;
           CommandText := ' select mfger_name,mfger_part_no from sajet.sys_part_mfger  '
                         +' where part_id='''+fdetail.QryDetail.FieldByName('Part_ID').AsString+'''  '
                         +' and enabled=''Y'' order by mfger_name,mfger_part_no ';
           Open;

           if not isempty then
           begin
              sgalias.rowCount :=recordcount+1;
              for i:=1 to recordcount do
              begin
                  sgalias.Cells[0,i]:=fieldbyname('mfger_name').AsString ;
                  sgalias.Cells[1,i]:=fieldbyname('mfger_part_no').AsString ;
                  next;
              end;
           end;
       end;
end;

procedure TFData.FormShow(Sender: TObject);
Var i,j:integer;
begin
   if   MaintainType='MFGER'  then
   begin
      if editalias.Visible = true then
          editalias.Visible := false;
      sgalias.ColCount :=2;
      sgalias.ColWidths[0]:=200;
      sgalias.ColWidths[1]:=250;
      sgalias.Cells[0,0]:='Mfger Name';
      sgalias.Cells[1,0]:='Mfger Part_no';

      Querymfger;
      
   end;
end;

procedure TFData.SgaliasDblClick(Sender: TObject);
var irow,icol:integer;
begin
    irow:=sgalias.Row ;
    icol:=sgalias.Col;
    
    if MaintainType='MFGER'  then
    begin
       fdetail.Edtname.Text :=sgalias.Cells[0,irow] ;
       fdetail.edtPN.Text :=sgalias.Cells[1,irow];
    end;

    ModalResult := mrOK;
end;

end.
