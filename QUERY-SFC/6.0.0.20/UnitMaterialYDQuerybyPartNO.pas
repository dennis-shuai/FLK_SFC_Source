unit UnitMaterialYDQuerybyPartNO;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, Grids, StdCtrls, ComCtrls;

type
  TFormYDQueryBYPartNO = class(TForm)
    Label1: TLabel;
    Label3: TLabel;
    lblrecordcount: TLabel;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Editpartno: TEdit;
    btnclose: TButton;
    btnquery: TButton;
    StringGridPARTNO: TStringGrid;
    ClientDataSetmaterialydbypartno: TClientDataSet;
    Label5: TLabel;
    Label6: TLabel;
    DateTimePickerSTART: TDateTimePicker;
    DateTimePickerEND: TDateTimePicker;
    CMBBOXSSTART: TComboBox;
    CMBBOXSEND: TComboBox;
    cmbBoxHSTART: TComboBox;
    cmbBoxHend: TComboBox;
    Label4: TLabel;
    cmbtype: TComboBox;
    procedure cleardata;
    procedure gettime;
    procedure getType;
    procedure querybypartno(strsql,strTstart,strtend,STRTYPE: string);
    procedure btncloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnqueryClick(Sender: TObject);
    procedure EditpartnoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormYDQueryBYPartNO: TFormYDQueryBYPartNO;
  icol,irow:integer;
  strTstart,strtend: string;
  strtype:string;

implementation

uses UnitMain;

{$R *.dfm}
procedure TFormYDQueryBYPartNO.cleardata;
 begin
    editpartno.Clear ;
    editpartno.SetFocus ;
    lblrecordcount.Caption :='';

   { datetimepickerstart.Date:=now;
    datetimepickerend.Date :=now;
    cmbboxhstart.ItemIndex:=0;
    cmbboxhend.ItemIndex:=23;
    cmbboxsstart.ItemIndex :=0;
    cmbboxsend.ItemIndex :=60 ;
   } 
    with stringgridpartno do
       begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=10;
           ColCount  :=9;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=130;
           cells[0,0]:='         更新時間';
           colwidths[1]:=30;
           cells[1,0]:='TYPE';
           colwidths[2]:=90;
           CELLS[2,0]:='    PART_NO';
           CELLS[3,0]:='Material_NO';
           CELLS[4,0]:='Material_QTY';
           colwidths[5]:=74;
           CELLS[5,0]:='  Reel_NO';
           CELLS[6,0]:='Reel_QTY';
           CELLS[7,0]:='Warehouse';
           colwidths[8]:=54;
           cells[8,0]:='Locate' ;
      end;
end;

procedure TFormYDQueryBYPartNO.gettime;
begin
   strtstart:='';
   strtend:='';
   strTstart:=FormatDateTime('YYYYMMDD',datetimepickerstart.Date)+cmbboxhstart.Text+cmbboxsstart.text;
   strtend:=FormatDateTime('YYYYMMDD',datetimepickerEND.Date)+cmbboxhend.Text +cmbboxsend.Text ;
   //showmessage(strtstart);
   //showmessage(strtend);
end;

procedure TFormYDQueryBYPartNO.getType;
begin
    strtype:='';
    if cmbtype.Text= 'ALL' then
       strtype:='TYPE LIKE ''%''';
    if cmbtype.text='INPUT' then
       strtype:='TYPE LIKE ''I''';
    IF CMBTYPE.Text ='OUTPUT' THEN
       STRTYPE:='TYPE LIKE ''O''';
    IF CMBTYPE.Text ='INPUT/OUTPUT' THEN
       STRTYPE:='TYPE IN (''I'',''O'') ';
    IF CMBTYPE.Text ='MERGE' THEN
       STRTYPE:='TYPE LIKE ''M''';
    IF CMBTYPE.Text ='SPLIT' THEN
       STRTYPE:='TYPE LIKE ''S''' ;
end;


procedure TFormYDQueryBYPartNO.querybypartno(strsql,strTstart,strtend,strtype: string);
var i:integer;
begin
    with clientdatasetmaterialydbypartno do
        begin
            close;
            commandtext:= '  select A.UPDATE_TIME,A.TYPE,B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY,A.REEL_NO,A.REEL_QTY,C.WAREHOUSE_NAME,D.LOCATE_NAME '
                         +'  from sajet.g_ht_material A,sajet.SYS_PART B,sajet.SYS_WAREHOUSE C,sajet.SYS_LOCATE D where  A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID '
                         +'  AND A.LOCATE_ID=D.LOCATE_ID AND B.PART_NO=:part_no and TO_CHAR(A.UPDATE_TIME,''YYYYMMDDHH24MI'') BETWEEN :starttime AND :endtime and '+ STRTYPE
                         +'  UNION '
                         +'  select A.UPDATE_TIME,A.TYPE,B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY,A.REEL_NO,A.REEL_QTY,C.WAREHOUSE_NAME,'' '' as locate_name '
                         +'  from sajet.g_ht_material A,sajet.SYS_PART B,sajet.SYS_WAREHOUSE C where  A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID '
                         +'  AND B.PART_NO=:part_no  and TO_CHAR(A.UPDATE_TIME,''YYYYMMDDHH24MI'') BETWEEN :starttime AND :endtime and a.locate_id is null AND '+ STRTYPE;
            PARAMS.ParamByName('part_no').AsString :=STRSQL;
            params.ParamByName('starttime').AsString:= strTstart;
            params.parambyname('endtime').asstring:=strtend;
            OPEN;

            lblrecordcount.Caption :=inttostr(recordcount);

            if recordcount=0 then
               begin
                 cleardata  ;
                 exit;
               end;

            stringgridpartno.RowCount :=recordcount+1;
            first;
            for icol:=1 to recordcount do
              begin
                for irow:=1 to fieldcount do
                  begin
                     stringgridpartno.Cells[irow-1,icol]:=fields[irow-1].AsString ;
                  end;
               next ;
             end;
     end;
end;

procedure TFormYDQueryBYPartNO.btncloseClick(Sender: TObject);
begin
   close;
end;

procedure TFormYDQueryBYPartNO.FormShow(Sender: TObject);
begin
    datetimepickerstart.Date:=now;
    datetimepickerend.Date :=now;
    cmbboxhstart.ItemIndex:=0;
    cmbboxhend.ItemIndex:=23;
    cmbboxsstart.ItemIndex :=0;
    cmbboxsend.ItemIndex :=60 ;
    
   clientdatasetmaterialydbypartno.RemoteServer :=formmain.socketconnection1;
   clientdatasetmaterialydbypartno.ProviderName :=formmain.Clientdataset1.ProviderName ;

   cleardata;
end;

procedure TFormYDQueryBYPartNO.btnqueryClick(Sender: TObject);
begin
   editpartno.SetFocus ;
   gettime;
   gettype;
   querybypartno(trim(editpartno.text),strTstart,strtend,strtype) ;
end;

procedure TFormYDQueryBYPartNO.EditpartnoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
    if key =13 then
       begin
          editpartno.SelectAll  ;
          gettime;
          gettype;
          querybypartno(trim(editpartno.text),strTstart,strtend,strtype) ;

       end;
end;

end.
