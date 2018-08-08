unit UnitMaterialYDQuerybyIDNO;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DB, DBClient;

type
  TFormYDQueryByIDNO = class(TForm)
    Label1: TLabel;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Editidno: TEdit;
    btnclose: TButton;
    StringGridIDNO: TStringGrid;
    ClientDataSetmaterialydbyidno: TClientDataSet;
    btnquery: TButton;
    Label3: TLabel;
    lblrecordcount: TLabel;
    Label4: TLabel;
    procedure cleardata;
    procedure querybyidno(strsql: string);
    procedure btncloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnqueryClick(Sender: TObject);
    procedure EditidnoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormYDQueryByIDNO: TFormYDQueryByIDNO;
  irow,icol :integer;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormYDQueryByIDNO.cleardata;
begin
    editidno.Clear ;
    editidno.SetFocus ;
    lblrecordcount.Caption :='';
    with stringgrididno do
       begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=10;
           ColCount  :=10;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=130;
           cells[0,0]:='更新時間';
           colwidths[1]:=30;
           cells[1,0]:='TYPE';
           colwidths[2]:=90;
           CELLS[2,0]:='PART_NO';
           CELLS[3,0]:='Material_NO';
           CELLS[4,0]:='Material_QTY';
           colwidths[5]:=74;
           CELLS[5,0]:='Reel_NO';
           CELLS[6,0]:='Reel_QTY';
           colwidths[7]:=60;
           CELLS[7,0]:='Warehouse';
           colwidths[8]:=40;
           cells[8,0]:='Locate' ;
           cells[9,0]:='User_name' ;


      end;
end;

procedure TFormYDQueryByIDNO.querybyidno(strsql: string);
var i:integer;
begin
    with clientdatasetmaterialydbyidno do
        begin
            close;
            commandtext:= '  select A.UPDATE_TIME,A.TYPE,B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY,A.REEL_NO,A.REEL_QTY,C.WAREHOUSE_NAME,D.LOCATE_NAME,E.EMP_NAME '
                         +'  from sajet.g_ht_material A,sajet.SYS_PART B,sajet.SYS_WAREHOUSE C,sajet.SYS_LOCATE D,SAJET.SYS_EMP E where  A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID '
                         +'  AND A.LOCATE_ID=D.LOCATE_ID AND (A.REEL_NO=:ID_NO OR A.MATERIAL_NO=:ID_NO ) AND A.UPDATE_userid=e.emp_id '
                         +'  UNION '
                         +'  select A.UPDATE_TIME,A.TYPE,B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY,A.REEL_NO,A.REEL_QTY,C.WAREHOUSE_NAME,'' '' as locate_name ,E.EMP_NAME'
                         +'  from sajet.g_ht_material A,sajet.SYS_PART B,sajet.SYS_WAREHOUSE C,SAJET.SYS_EMP E where  A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID '
                         +'  AND (A.REEL_NO=:ID_NO OR A.MATERIAL_NO=:ID_NO ) and a.locate_id is null AND A.UPDATE_userid=e.emp_id ';

            PARAMS.ParamByName('ID_NO').AsString :=STRSQL;
            OPEN;

            lblrecordcount.Caption :=inttostr(recordcount);

            if recordcount=0 then
               begin
                 cleardata  ;
                 exit;
               end;

            stringgrididno.RowCount :=recordcount+1;
            first;
            for icol:=1 to recordcount do
              begin
                for irow:=1 to fieldcount do
                  begin
                     stringgrididno.Cells[irow-1,icol]:=fields[irow-1].AsString ;
                  end;
               next ;
             end;


            //如果WAREHOUSE_NAME 不相同,reel_no 相同,而type 不同,並且type 分別為'I' AND 'O',則認為有做轉倉動作
            FOR icol:=1 to recordcount+1 do
                  for i:=icol+1 to recordcount+1 do
                       if stringgrididno.cells[7,icol]<>stringgrididno.cells[7,i] then
                          if stringgrididno.Cells[5,icol]=stringgrididno.Cells[5,i] then
                             if stringgrididno.Cells[1,icol]<>stringgrididno.Cells[1,i] then
                                begin
                                   if stringgrididno.Cells[1,icol]='I'  then
                                       if stringgrididno.Cells[1,i]='O' THEN
                                          begin
                                              showmessage('此ID NO 有做轉倉!');
                                               exit;
                                          end;
                                   if stringgrididno.Cells[1,icol]='O'  then
                                       if stringgrididno.Cells[1,i]='I' THEN
                                          begin
                                              showmessage('此ID NO 有做轉倉!');
                                              exit;
                                          end;
        end;                    end;
end;

procedure TFormYDQueryByIDNO.btncloseClick(Sender: TObject);
begin
    close;
end;

procedure TFormYDQueryByIDNO.FormShow(Sender: TObject);
begin
   clientdatasetmaterialydbyidno.RemoteServer :=formmain.socketconnection1;
   clientdatasetmaterialydbyidno.ProviderName :=formmain.Clientdataset1.ProviderName ;

    cleardata;
end;

procedure TFormYDQueryByIDNO.btnqueryClick(Sender: TObject);
begin
     editidno.SetFocus ;
     querybyidno(trim(editidno.Text));
end;

procedure TFormYDQueryByIDNO.EditidnoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
    if key=13 then
      begin
           querybyidno(trim(editidno.Text));
           editidno.SelectAll ;
      end;
end;

end.
