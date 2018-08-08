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
           CommandText := 'SELECT alias_name from sajet.sys_alias  '
                        +' where alias_name like :alias_name and enabled=''Y''  Order by alias_name asc ';
           Params.ParamByName('alias_name').AsString := '%' + Trim(editalias.Text) + '%';
           Open;

           if not isempty then
           begin
              sgalias.rowCount :=recordcount+1;
              for i:=1 to recordcount do
              begin
                  sgalias.Cells[0,i]:=fieldbyname('alias_name').AsString ;
                  next;
              end;
           end;
       end;
   end;
end;

procedure TFData.FormShow(Sender: TObject);
Var i,j:integer;
begin
   if   MaintainType='ALIAS'  then
   begin
      if editalias.Visible = false then
         editalias.Visible := true;
      sgalias.ColCount :=1;
      sgalias.Cells[0,0]:='Alias Name';
   end;
end;

procedure TFData.SgaliasDblClick(Sender: TObject);
var irow,icol:integer;
begin
    irow:=sgalias.Row ;
    icol:=sgalias.Col;
    if   MaintainType='ALIAS'  then
    begin
        fdetail.combAlias.ItemIndex:=-1;
       { fdetail.combAlias.Style :=csdropdown;
        //fdetail.combAlias.Text :=sgalias.Cells[icol,irow] ;
        fdetail.combAlias.Text :=sgalias.Cells[0,irow] ;
        fdetail.combAlias.ItemIndex:=fdetail.combAlias.Items.IndexOf(fdetail.combAlias.Text);
        if fdetail.combAlias.ItemIndex=-1 then
        begin
            showmessage('The Alias can not use now!');
            fdetail.combAlias.Text :='';
            fdetail.combAlias.Style :=csdropdownlist ;
            exit;
        end;
        fdetail.cmbStock.Style  :=csdropdownlist ;
        }
        //�ק��combalias.itemindex ����Ȥ�k
        fdetail.combAlias.ItemIndex:=fdetail.combAlias.Items.IndexOf(sgalias.Cells[0,irow]);
        if fdetail.combAlias.ItemIndex <> -1 then
        begin
            fdetail.combAliasChange(self);
        end
        else
        begin
           showmessage('The Alias can not use now!');
           exit;
        end;
    end;

    ModalResult := mrOK;
end;

end.
