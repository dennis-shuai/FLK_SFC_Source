unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  MConnect, SConnect, {FileCtrl,} ObjBrkr, Menus,DateUtils,comobj,Variants,
  ComCtrls;

type
  TfMain = class(TForm)
    Panel1: TPanel;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    Label1: TLabel;
    Label10: TLabel;
    labCnt: TLabel;
    labcost: TLabel;
    qryReel: TClientDataSet;
    Imageall: TImage;
    Label2: TLabel;
    Editsn: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Edittoolingtype: TEdit;
    Edittoolingname: TEdit;
    Label5: TLabel;
    Editmaxusedcount: TEdit;
    Label6: TLabel;
    Edittoolingno: TEdit;
    Label7: TLabel;
    Editusedcount: TEdit;
    Label8: TLabel;
    Edittoolingstatus: TEdit;
    Label11: TLabel;
    Editmachineno: TEdit;
    Label12: TLabel;
    Editassetno: TEdit;
    Label13: TLabel;
    Editkeeper: TEdit;
    Label14: TLabel;
    Editmonitordept: TEdit;
    Label15: TLabel;
    Editlastrevisetime: TEdit;
    Label9: TLabel;
    Editusedstatus: TEdit;
    Panel2: TPanel;
    Label16: TLabel;
    Editlocate: TEdit;
    PCTravelCard: TPageControl;
    Material: TTabSheet;
    StringGridmaterial: TStringGrid;
    Sn_Status: TTabSheet;
    StringGridsnstatus: TStringGrid;
    Matain: TTabSheet;
    StringGridmatain: TStringGrid;
    Revise: TTabSheet;
    StringGridrevise: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure EditsnKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MaterialShow(Sender: TObject);
    procedure Sn_StatusShow(Sender: TObject);
    procedure MatainShow(Sender: TObject);
    procedure ReviseShow(Sender: TObject);
    procedure EditmachinenoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditassetnoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    icol,irow:integer;
    Gtoolingsnid:string;
    procedure cleardata;
    function gettoolingsnid(tooling_sn:string):String;
    procedure Querytooling(toolingsnid:string) ;
    procedure Querymaterial(toolingsnid:string) ;
    procedure QuerySNstatus(toolingsnid:string) ;
    procedure Queryhtmaterial(toolingsnid:string) ;
    procedure Queryhtsnstatus(toolingsnid:string) ;
    procedure Querymatain(toolingsnid:string) ;
    procedure Queryrevise(toolingsnid:string) ;

  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform;

procedure tfmain.QueryREVISE(toolingsnid:string) ;
var irow: integer;
begin
    with qrytemp do
    begin
        close;
        params.CreateParam(ftstring,'tooling_sn_id',ptinput);
        commandtext:=' select decode(a.status,''Y'',''Y-正常'',''M'',''M-保養'',''R'',''R-維修'',''C'',''C-校正評估'',''S'',''S-報廢'') as status, '
                    +'B.emp_name as repairer,A.repair_time,a.repair_memo   '
                    +' from sajet.g_tooling_sn_repair a,sajet.sys_emp B '
                    +' where A.tooling_sn_id=:tooling_sn_id '
                    +' and a.status=''C'' '
                    +' and a.repair_userid=B.emp_id  '
                    +' order by A.repair_time asc  ';
        params.ParamByName('tooling_sn_id').AsString :=toolingsnid;
        open;

        irow:=1;
        while not eof do
        begin
          stringgridrevise.Cells[0,irow]:=inttostr(irow);
          stringgridrevise.Cells[1,irow]:= fieldbyname('repair_time').AsString ;
          stringgridrevise.Cells[2,irow]:=fieldbyname('repairer').AsString ;
          inc(irow);
          next;
       end;
       if irow>5 then
          stringgridrevise.RowCount:=irow;
    end;
end;

procedure tfmain.Querymatain(toolingsnid:string) ;
var irow: integer;
begin
    with qrytemp do
    begin
        close;
        params.CreateParam(ftstring,'tooling_sn_id',ptinput);
        commandtext:=' select a.used_count,b.defect_code||''-''||b.defect_desc as defect,c.emp_name as defect_user,a.defect_time,  '
                    +' decode(a.status,''Y'',''Y-正常'',''M'',''M-保養'',''R'',''R-維修'',''C'',''C-校正評估'',''S'',''S-報廢'') as status, '
                    +' d.reason_code||''-''||d.reason_desc as reason,e.emp_name as repairer,a.repair_time,a.repair_memo   '
                    +' from sajet.g_tooling_sn_repair a,sajet.sys_defect b,sajet.sys_emp c,sajet.sys_reason d,sajet.sys_emp e  '
                    +' where A.tooling_sn_id=:tooling_sn_id '
                    +' and a.defect_id=b.defect_id  '
                    +' and a.defect_userid=c.emp_id  '
                    +' and a.reason_id=d.reason_id(+)  '
                    +' and a.repair_userid=e.emp_id(+)  '
                    +' order by A.repair_time asc  ';
        params.ParamByName('tooling_sn_id').AsString :=toolingsnid;
        open;

        irow:=1;
        while not eof do
        begin
           stringgridmatain.Cells[0,irow]:=inttostr(irow);
          stringgridmatain.Cells[1,irow]:= fieldbyname('used_count').AsString ;
          stringgridmatain.Cells[2,irow]:=fieldbyname('status').AsString ;
          stringgridmatain.Cells[3,irow]:= fieldbyname('defect').AsString ;
          stringgridmatain.Cells[4,irow]:=fieldbyname('defect_user').AsString ;
          stringgridmatain.Cells[5,irow]:=fieldbyname('defect_time').AsString ;
          stringgridmatain.Cells[6,irow]:= fieldbyname('reason').AsString ;
          stringgridmatain.Cells[7,irow]:=fieldbyname('repairer').AsString ;
          stringgridmatain.Cells[8,irow]:= fieldbyname('repair_time').AsString ;
          stringgridmatain.Cells[9,irow]:=fieldbyname('repair_memo').AsString ;
          inc(irow);
          next;
       end;
        if irow>5 then
          stringgridmatain.RowCount:=irow;
    end;
end;

procedure tfmain.Queryhtsnstatus(toolingsnid:string) ;
var irow: integer;
begin
    with qrytemp do
    begin
        close;
        params.CreateParam(ftstring,'tooling_sn_id',ptinput);
        commandtext:='select a.used_count,decode(a.status,''Y'',''Y-正常'',''M'',''M-保養'',''R'',''R-維修'',''C'',''C-校正評估'',''S'',''S-報廢'') as status,  '
                    +' b.emp_name,A.update_time from '
                    +' sajet.g_ht_tooling_sn_status a,sajet.sys_emp b  '
                    +' where a.tooling_sn_id=:tooling_sn_id '
                    +' and a.update_userid=b.emp_id  '
                    +' order by A.update_time asc' ;
        params.ParamByName('tooling_sn_id').AsString :=toolingsnid;
        open;

        irow:=1;
        while not eof do
        begin
            stringgridSNSTATUS.Cells[0,irow]:=inttostr(irow);
            stringgridsnstatus.Cells[1,irow]:= fieldbyname('used_count').AsString ;
            stringgridsnstatus.Cells[2,irow]:=fieldbyname('status').AsString ;
            stringgridsnstatus.Cells[3,irow]:= fieldbyname('emp_name').AsString ;
            stringgridsnstatus.Cells[4,irow]:=fieldbyname('update_time').AsString ;
            inc(irow);
            next;
        end;
        if irow>5 then
           stringgridSNSTATUS.RowCount:=irow;
    end;
end;

procedure tfmain.Queryhtmaterial(toolingsnid:string) ;
var irow: integer;
begin
    with qrytemp do
    begin
        close;
        params.CreateParam(ftstring,'tooling_sn_id',ptinput);
        commandtext:='select decode(a.machine_used,''Y'',''Y-使用中'',''N'',''N-非使用'')||''/''||decode(machine_type,''FI'',''FI-First入庫'',''I'',''I-入庫'',''O'',''O-出庫'',''TS'',''TS-轉倉'',''TL'',''TL-換線'') as machine_status,  '
                    +'  a.revise_time,d.emp_name as keeper,'
                    +' b.warehouse_name||''-''||c.locate_name as locate,e.emp_name as update_user,a.update_time,a.machine_memo  '
                    +' from sajet.g_ht_tooling_material a,sajet.sys_warehouse b,sajet.sys_locate c,sajet.sys_emp d,sajet.sys_emp e '
                    +' where tooling_sn_id=:tooling_sn_id '
                    +' and a.warehouse_id=b.warehouse_id  '
                    +' and a.locate_id=c.LOCATE_ID  '
                    +' and a.keeper_userid=d.emp_id '
                    +' and a.update_userid=e.emp_id  '
                    +' order by update_time asc  ' ;
        params.ParamByName('tooling_sn_id').AsString :=toolingsnid;
        open;

        irow:=1;
        while not eof do
        begin
          stringgridmaterial.Cells[0,irow]:=inttostr(irow);
          stringgridmaterial.Cells[1,irow]:= fieldbyname('machine_status').AsString ;
          stringgridmaterial.Cells[2,irow]:=fieldbyname('revise_time').AsString ;
          stringgridmaterial.Cells[3,irow]:= fieldbyname('keeper').AsString ;
          stringgridmaterial.Cells[4,irow]:=fieldbyname('locate').AsString;
          stringgridmaterial.Cells[5,irow]:= fieldbyname('update_user').AsString ;
          stringgridmaterial.Cells[6,irow]:=fieldbyname('update_time').AsString ;
          stringgridmaterial.Cells[7,irow]:=fieldbyname('machine_memo').AsString ;
          inc(irow);
          next;
       end;
       if irow>5 then
          stringgridmaterial.RowCount:=irow;
    end;
end;

procedure tfmain.Querysnstatus(toolingsnid:string) ;
begin
    with qrytemp do
    begin
        close;
        params.CreateParam(ftstring,'tooling_sn_id',ptinput);
        commandtext:=' SELECT USED_COUNT,decode(status,''Y'',''Y-正常'',''M'',''M-保養'',''R'',''R-維修'',''C'',''C-校正評估'',''S'',''S-報廢'') as status '
                    +' from SAJET.G_TOOLING_SN_STATUS '
                    +' WHERE TOOLING_SN_ID=:tooling_sn_id AND ROWNUM=1';
        params.ParamByName('tooling_sn_id').AsString :=toolingsnid;
        open;
        if not isempty then
        begin
            editusedcount.Text :=fieldbyname('used_count').AsString ;
            edittoolingstatus.Text :=fieldbyname('status').AsString ;
        end;
    end;
end;

procedure tfmain.Querytooling(toolingsnid:string) ;
begin
    with qrytemp do
    begin
        close;
        params.CreateParam(ftstring,'tooling_sn_id',ptinput);
        commandtext:=' select a.tooling_no,a.tooling_name,a.tooling_type,a.LIMIT_USED_COUNT '
                    +' from sajet.sys_tooling a,sajet.sys_tooling_sn b  '
                    +' where a.tooling_id=b.tooling_id  '
                    +' and B.tooling_SN_ID=:tooling_sn_id AND ROWNUM=1 ';
        params.ParamByName('tooling_sn_id').AsString :=toolingsnid;
        open;
        if not isempty then
        begin
            edittoolingtype.Text :=fieldbyname('tooling_type').AsString ;
            edittoolingname.Text :=fieldbyname('tooling_name').AsString ;
            edittoolingno.Text :=fieldbyname('tooling_no').AsString ;
            editmaxusedcount.Text :=fieldbyname('LIMIT_USED_COUNT').AsString ;
        end;
    end;
end;

procedure tfmain.Querymaterial(toolingsnid:string) ;
begin
    with qrytemp do
    begin
        close;
        params.CreateParam(ftstring,'tooling_sn_id',ptinput);
        commandtext:=' select a.machine_no,a.asset_no,d.emp_name as keeper,e.dept_name,a.revise_time,  '
                    +' decode(a.machine_used,''Y'',''Y-使用中'',''N'',''N-非使用'') as used_status,   '
                    +' b.warehouse_name||''-''||c.locate_name as locate '
                    +' from sajet.g_tooling_material a,sajet.sys_warehouse b,sajet.sys_locate c ,sajet.sys_emp d,sajet.sys_dept e  '
                    +' where a.tooling_sn_id=:tooling_sn_id '
                    +' and a.warehouse_id=b.warehouse_id  '
                    +' and a.locate_id=c.locate_id '
                    +' and a.keeper_userid=d.emp_id '
                    +' and a.monitor_dept=e.dept_id '
                    +' and rownum=1 ';
        params.ParamByName('tooling_sn_id').AsString :=toolingsnid;
        open;
        if not isempty then
        begin
           editmachineno.Text :=fieldbyname('machine_no').AsString ;
           editassetno.Text :=fieldbyname('asset_no').AsString ;
           editkeeper.Text :=fieldbyname('keeper').AsString ;
           editmonitordept.Text :=fieldbyname('dept_name').AsString ;
           editlastrevisetime.Text:=fieldbyname('revise_time').AsString ;
           editusedstatus.Text :=fieldbyname('used_status').AsString ;
           editlocate.Text :=fieldbyname('locate').AsString ;
        end;
    end;
end;

function tfmain.gettoolingsnid(tooling_sn:string):String;
var strtoolingsnid:string;
Begin
   with  qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'tooling_sn',ptinput);
       commandtext:=' select TOOLING_SN_ID from sajet.sys_tooling_sn    '
                   +' where  tooling_sn=:tooling_sn and rownum=1 ';
       params.ParamByName('tooling_sn').AsString:=tooling_sn;
       open;
       if isempty then
          result:='XXX'
       else
          result:=fieldbyname('tooling_sn_id').AsString ;
   end;
end;


procedure TfMain.CLEARDATA;
var i,j:integer;
BEGIN
   Gtoolingsnid:='XXX';
   
   edittoolingtype.Clear ;
   edittoolingname.Clear ;
   edittoolingno.Clear ;
   editmaxusedcount.Clear ;
   editmachineno.Clear ;
   editassetno.Clear ;
   editkeeper.Clear ;
   editmonitordept.Clear ;
   editlastrevisetime.Clear ;
   editusedstatus.Clear ;
   editusedcount.Clear ;
   edittoolingstatus.Clear ;
   editlocate.Clear ;


   stringgridmaterial.FixedRows:=1;
   stringgridmaterial.FixedCols :=0;
   for i:=0 to stringgridmaterial.RowCount do
      for j:=0 to stringgridmaterial.ColCount do
        stringgridmaterial.Cells[j,i]:='';
   stringgridmaterial.RowCount:=5;
   stringgridmaterial.ColCount:=8;
   stringgridmaterial.Cells[0,0]:='項次' ;
   stringgridmaterial.Cells[1,0]:='設備狀態';
   stringgridmaterial.Cells[2,0]:='校驗時間' ;
   stringgridmaterial.Cells[3,0]:='保管人';
   stringgridmaterial.Cells[4,0]:='Locate';
   stringgridmaterial.Cells[5,0]:='update_user';
   stringgridmaterial.Cells[6,0]:='update_time' ;
   stringgridmaterial.Cells[7,0]:='Memo';

   stringgridmaterial.ColWidths[0]:=30;
   stringgridmaterial.ColWidths[1]:=100;
   stringgridmaterial.ColWidths[2]:=80;
   stringgridmaterial.ColWidths[3]:=70;
   stringgridmaterial.ColWidths[4]:=70;
   stringgridmaterial.ColWidths[5]:=80;
   stringgridmaterial.ColWidths[6]:=100;
   stringgridmaterial.ColWidths[7]:=150;

   stringgridSNSTATUS.FixedRows:=1;
   stringgridsnstatus.FixedCols :=0;
   for i:=0 to stringgridsnstatus.RowCount do
      for j:=0 to stringgridsnstatus.ColCount do
        stringgridsnstatus.Cells[j,i]:='';
   stringgridsnstatus.RowCount:=5;
   stringgridsnstatus.ColCount:=5;
   stringgridsnstatus.Cells[0,0]:='項次' ;
   stringgridsnstatus.Cells[1,0]:='使用次數';
   stringgridsnstatus.Cells[2,0]:='Tooling_Type' ;
   stringgridsnstatus.Cells[3,0]:='update_user';
   stringgridsnstatus.Cells[4,0]:='update_time' ;

   stringgridsnstatus.ColWidths[0]:=30;
   stringgridsnstatus.ColWidths[1]:=80;
   stringgridsnstatus.ColWidths[2]:=90;
   stringgridsnstatus.ColWidths[3]:=90;
   stringgridsnstatus.ColWidths[4]:=100;

   stringgridmatain.FixedRows:=1;
   stringgridmatain.FixedCols :=0;
   for i:=0 to stringgridmatain.RowCount do
      for j:=0 to stringgridmatain.ColCount do
        stringgridmatain.Cells[j,i]:='';
   stringgridmatain.RowCount:=5;
   stringgridmatain.ColCount:=10;
   stringgridmatain.Cells[0,0]:='項次' ;
   stringgridmatain.Cells[1,0]:='使用次數';
   stringgridmatain.Cells[2,0]:='Tooling_Type' ;
   stringgridmatain.Cells[3,0]:='Defect_desc';
   stringgridmatain.Cells[4,0]:='Defect_user';
   stringgridmatain.Cells[5,0]:='Defect_time';
   stringgridmatain.Cells[6,0]:='Reason_desc';
   stringgridmatain.Cells[7,0]:='Repair' ;
   stringgridmatain.Cells[8,0]:='Repair_time';
   stringgridmatain.Cells[9,0]:='Memo';

   stringgridmatain.ColWidths[0]:=30;
   stringgridmatain.ColWidths[1]:=80;
   stringgridmatain.ColWidths[2]:=90;
   stringgridmatain.ColWidths[3]:=120;
   stringgridmatain.ColWidths[4]:=80;
   stringgridmatain.ColWidths[5]:=100;
   stringgridmatain.ColWidths[6]:=120;
   stringgridmatain.ColWidths[7]:=100;
   stringgridmatain.ColWidths[8]:=80;
   stringgridmatain.ColWidths[9]:=150;

   stringgridrevise.FixedRows:=1;
   stringgridrevise.FixedCols :=0;
   for i:=0 to stringgridrevise.RowCount do
      for j:=0 to stringgridrevise.ColCount do
        stringgridrevise.Cells[j,i]:='';
   stringgridrevise.RowCount:=5;
   stringgridrevise.ColCount:=3;
   stringgridrevise.Cells[0,0]:='項次' ;
   stringgridrevise.Cells[1,0]:='校正時間';
   stringgridrevise.Cells[2,0]:='校驗人' ;

   stringgridrevise.ColWidths[0]:=30;
   stringgridrevise.ColWidths[1]:=100;
   stringgridrevise.ColWidths[2]:=80;

   pctravelcard.ActivePage:=Material;
END;
 
procedure TfMain.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;

  with QryTemp do
  begin
    Close;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
    if gsParam <> '' then
      CommandText := CommandText + 'and fun_param = ''' + gsParam + ''' ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'ToolingTravelCardDLL.dll';
    Open;
  end;

  editsn.Clear ;
  editsn.SetFocus ;
  editsn.SelectAll ;
  cleardata;
end;

procedure TfMain.EditsnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if (trim(editsn.Text)<>'') and (key=13) then
       begin
           cleardata;
           gtoolingsnid:=gettoolingsnid(trim(editsn.Text));
           if gtoolingsnid='XXX' then
              begin
                 cleardata;
                 exit;
              end;
           Querytooling(gtoolingsnid);
           Querymaterial(Gtoolingsnid);
           Querysnstatus(Gtoolingsnid);

           pctravelcard.ActivePage :=Material;
           MaterialShow(SELF);

           editsn.SetFocus ;
           editsn.SelectAll ;

       end;
end;

procedure TfMain.MaterialShow(Sender: TObject);
begin
    if  (Gtoolingsnid<>'XXX') AND (STRINGGRIDMATERIAL.Cells[0,1]<>'1') THEN
       Queryhtmaterial(gtoolingsnid);
end;

procedure TfMain.Sn_StatusShow(Sender: TObject);
begin
     if  (Gtoolingsnid<>'XXX') AND (stringgridsnstatus.Cells[0,1]<>'1') THEN
         Queryhtsnstatus(gtoolingsnid);
end;

procedure TfMain.MatainShow(Sender: TObject);
begin
   if  (Gtoolingsnid<>'XXX') and (stringgridmatain.Cells[0,1]<>'1') THEN
       Querymatain(gtoolingsnid);
end;

procedure TfMain.ReviseShow(Sender: TObject);
begin
  if  (Gtoolingsnid<>'XXX') and (stringgridrevise.Cells[0,1]<>'1') THEN
    QueryREVISE(gtoolingsnid);
end;

procedure TfMain.EditmachinenoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if key=13 then
   begin
      // cleardata;
       if trim(editmachineno.Text)='' then exit;
       if UPPERCASE(trim(editmachineno.Text))='N/A' THEN EXIT;
       with qrytemp do
       begin
          close;
          params.CreateParam(ftstring,'machine_no',ptinput);
          commandtext:='select a.tooling_sn from  sajet.sys_tooling_sn a,sajet.g_tooling_material b '
                   +' where b.machine_no=:machine_no and a.tooling_sn_id=b.tooling_sn_id and rownum=1 ';
          params.ParamByName('machine_no').AsString :=editmachineno.Text;
          open;

          if not isempty then
          BEGIN
              Editsn.Text :=fieldbyname('TOOLING_SN').AsString ;
              cleardata;
              gtoolingsnid:=gettoolingsnid(trim(editsn.Text));
              if gtoolingsnid='XXX' then
              begin
                   cleardata;
                    exit;
               end;
              Querytooling(gtoolingsnid);
              Querymaterial(Gtoolingsnid);
              Querysnstatus(Gtoolingsnid);

              pctravelcard.ActivePage :=Material;
              MaterialShow(SELF);

              editsn.SetFocus ;
              editsn.SelectAll ;
          END
          ELSE
          begin
             cleardata;
             editsn.Clear ;
          end;

       end;
 end;
end;

procedure TfMain.EditassetnoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if key=13 then
   begin
      // cleardata;
       if trim(editassetno.Text)='' then exit;
       if UPPERCASE(trim(editassetno.Text))='N/A' THEN EXIT;
       with qrytemp do
       begin
          close;
          params.CreateParam(ftstring,'asset_no',ptinput);
          commandtext:='select a.tooling_sn from  sajet.sys_tooling_sn a,sajet.g_tooling_material b '
                   +' where b.asset_no=:asset_no and a.tooling_sn_id=b.tooling_sn_id and rownum=1 ';
          params.ParamByName('asset_no').AsString :=editassetno.Text;
          open;

          if not isempty then
          BEGIN
              Editsn.Text :=fieldbyname('TOOLING_SN').AsString ;
              cleardata;
              gtoolingsnid:=gettoolingsnid(trim(editsn.Text));
              if gtoolingsnid='XXX' then
              begin
                   cleardata;
                    exit;
               end;
              Querytooling(gtoolingsnid);
              Querymaterial(Gtoolingsnid);
              Querysnstatus(Gtoolingsnid);

              pctravelcard.ActivePage :=Material;
              MaterialShow(SELF);

              editsn.SetFocus ;
              editsn.SelectAll ;
          END
          ELSE
          begin
             cleardata;
             editsn.Clear ;
          end;

       end;
   end;
end;

end.




