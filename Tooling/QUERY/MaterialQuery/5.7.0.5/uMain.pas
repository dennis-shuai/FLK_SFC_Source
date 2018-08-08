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
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryData: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    labCnt: TLabel;
    labcost: TLabel;
    SaveDialog2: TSaveDialog;
    qryReel: TClientDataSet;
    Image2: TImage;
    sbtnQuery: TSpeedButton;
    Image1: TImage;
    SBTNExport: TSpeedButton;
    CMBBOXTYPE: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    CMBBOXSTATUS: TComboBox;
    StringGrid1: TStringGrid;
    lblstatus: TLabel;
    Label2: TLabel;
    cmbboxwh: TComboBox;
    cmbboxlocate: TComboBox;
    cmbboxmachineused: TComboBox;
    Label3: TLabel;
    Label6: TLabel;
    Cmbboxmonitordept: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure LabTitle1Click(Sender: TObject);
    procedure SBTNExportClick(Sender: TObject);
    procedure cmbboxwhChange(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    icol,irow:integer;
    Griviseday:integer;
    procedure cleardata;
    procedure gettoolingtype;
    procedure getwarehouse;
    procedure getlocate;
    procedure querytoolingmaterial;
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);
    Function  DownloadSampleFile : String;
    procedure getmonitordept;
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform;

procedure tfmain.getwarehouse;
begin
   with  qrytemp do
   begin
       close;
       commandtext:=' SELECT warehouse_NAME from SAJET.SYS_warehouse WHERE ENABLED=''Y'' order by warehouse_name asc ';
       open;
       IF ISEMPTY THEN EXIT;
       cmbboxwh.Clear ;
       first;
       WHILE NOT EOF DO
         BEGIN
            cmbboxwh.Items.Add(fieldbyname('warehouse_NAME').AsString );
            next;
         END;
   end;
end;

procedure tfmain.getlocate;
begin
   cmbboxlocate.Clear ;
   with  qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'warehouse_name',ptinput);
       commandtext:='  SELECT a.locate_name FROM SAJET.SYS_LOCATE A,SAJET.SYS_WAREHOUSE B '
                   +' WHERE A.WAREHOUSE_ID=b.warehouse_id '
                   +' and b.warehouse_name=:warehouse_name'
                   +' and a.enabled=''Y'' order by locate_name asc ';
       params.ParamByName('warehouse_name').AsString:=cmbboxwh.Text ;
       open;
       IF ISEMPTY THEN EXIT;
       first;
       WHILE NOT EOF DO
         BEGIN
            cmbboxlocate.Items.Add(fieldbyname('locate_name').AsString );
            next;
         END;
   end;
end;

procedure TfMain.CLEARDATA;
var i,j:integer;
BEGIN
   Griviseday:=365;
   irow:=5;
   icol:=11;
   stringgrid1.FixedRows:=1;
   stringgrid1.FixedCols:=0;
   stringgrid1.ColCount :=icol;
   stringgrid1.Rowcount :=irow;
   for i:=0 to irow  do
     for j:=0 to icol do
       stringgrid1.Cells[icol,irow]:='';
   stringgrid1.Cells[0,0]:='項次';
   stringgrid1.Cells[1,0]:='類別代碼' ;
   stringgrid1.Cells[2,0]:='類別名稱' ;
   stringgrid1.Cells[3,0]:='設備條碼' ;
   stringgrid1.Cells[4,0]:='設備狀態';
   //stringgrid1.Cells[5,0]:='上次校驗時間' ;
  // stringgrid1.Cells[6,0]:='下次校驗時間';
   stringgrid1.Cells[5,0]:='保管人';
   stringgrid1.Cells[6,0]:='Locate';
   stringgrid1.Cells[7,0]:='監管單位';
   stringgrid1.Cells[8,0]:='設備規格';
   stringgrid1.Cells[9,0]:='機身編碼';
   stringgrid1.Cells[10,0]:='資產編號';

   stringgrid1.ColWidths[0]:=30;
   stringgrid1.ColWidths[1]:=70;
   stringgrid1.ColWidths[2]:=90;
   stringgrid1.ColWidths[3]:=130;
   stringgrid1.ColWidths[4]:=150;
   //stringgrid1.ColWidths[5]:=80;
   //stringgrid1.ColWidths[6]:=80;
   stringgrid1.ColWidths[5]:=70;
   stringgrid1.ColWidths[6]:=90;
   stringgrid1.ColWidths[7]:=150;
   stringgrid1.ColWidths[8]:=250;
    stringgrid1.ColWidths[9]:=90;
   stringgrid1.ColWidths[10]:=90;

   lblstatus.Caption :='';
END;

procedure TfMain.gettoolingtype;
begin
      with QryTemp do
        begin
          Close;
          commandtext:='select distinct tooling_type from  sajet.sys_tooling where tooling_type is not null' ;
          open;

          if recordcount<>0 then
            begin
                first;
                cmbboxtype.Clear ; 
                while not eof do
                   begin
                       cmbboxtype.Items.Add(fieldbyname('tooling_type').AsString );
                       next; 
                   end;
            end;
        end;

end;

procedure TfMain.getmonitordept;
begin
      with QryTemp do
        begin
          Close;
          commandtext:='select dept_name from SAJET.sys_dept where enabled=''Y'' order by dept_name asc ' ;
          open;

          if recordcount<>0 then
            begin
                first;
                Cmbboxmonitordept.Clear ;
                while not eof do
                   begin
                       Cmbboxmonitordept.Items.Add(fieldbyname('dept_name').AsString );
                       next; 
                   end;
            end;
        end;

end;


procedure TfMain.querytoolingmaterial;
var i,j:integer;
var strsql:string;
begin
   for i:=1 to stringgrid1.RowCount  do
     for j:=0 to stringgrid1.ColCount  do
       stringgrid1.Cells[j,i]:='';
   strsql:=' select a.tooling_type,a.tooling_name,b.tooling_sn, '
          +' decode(d.machine_used,''Y'',''Y-使用中'',''N'',''N-非使用'') as used, '
          +' decode(c.status,''Y'',''Y-正常'',''M'',''M-保養'',''R'',''R-維修'',''C'',''C-校正評估'',''S'',''S-報廢'') as status,  '
         // +' to_char(d.revise_time,''YYYY/MM/DD'') AS REVISE_TIME, '
         // +' to_char(d.revise_time+:reviseday,''YYYY/MM/DD'')  as next_revise_time ,'
          +' e.emp_name,f.warehouse_name||''-''||g.locate_name as locate , '
          +' d.machine_memo, '
          +' h.dept_name||''(''||h.dept_desc||'')'' as monitor_dept, '
          +' d.machine_no,d.asset_no '
          +' from sajet.sys_tooling a,sajet.sys_tooling_sn b,sajet.g_tooling_sn_status c ,sajet.g_tooling_material d, '
          +' sajet.sys_emp e,sajet.sys_warehouse f,sajet.sys_locate g,sajet.sys_dept h  '
          +' where a.tooling_id=b.tooling_id  '
          +' and b.tooling_sn_id=c.tooling_sn_id '
          +' and b.tooling_sn_id=d.tooling_sn_id  '
          +' and d.keeper_userid=e.emp_id  '
          +' and d.warehouse_id=f.warehouse_id   '
          +' and d.locate_id=g.locate_id  '
          +' and d.monitor_dept=h.dept_id ';

   if trim(cmbboxtype.Text)<>'' then
      strsql:=strsql+' and a.tooling_type='+''''+trim(cmbboxtype.Text)+'''';
   if trim(cmbboxwh.Text)<>'' then
      strsql:=strsql+' and f.warehouse_name='+''''+trim(cmbboxwh.Text)+'''';
   if trim(cmbboxlocate.Text)<>'' then
      strsql:=strsql+' and g.locate_name='+''''+trim(cmbboxlocate.Text)+'''';
   if trim(cmbboxmachineused.Text)<>'' then
      strsql:=strsql+' and d.machine_used='+''''+uppercase(copy(trim(cmbboxmachineused.Text),0,1))+'''';
   if trim(cmbboxstatus.Text)<>'' then
      strsql:=strsql+' and c.status='+''''+uppercase(copy(trim(cmbboxstatus.Text),0,1)+'''');
   if trim(cmbboxmonitordept.text)<>'' then
      strsql:=strsql+' and h.dept_name='+''''+trim(cmbboxmonitordept.Text)+'''';


   strsql:=strsql+' order by tooling_sn   ';

   with Qrydata do
       begin
          close;
          //params.CreateParam(ftdate,'reviseday',ptinput);
          commandtext:=strsql;
         // params.ParamByName('reviseday').AsInteger :=Griviseday;
          open;

      first;
      irow:=1;
      while not eof do
       begin
          stringgrid1.Cells[0,irow]:=inttostr(irow);
          stringgrid1.Cells[1,irow]:= fieldbyname('tooling_type').AsString ;
          stringgrid1.Cells[2,irow]:=fieldbyname('tooling_name').AsString ;
          stringgrid1.Cells[3,irow]:= fieldbyname('tooling_sn').AsString ;
          stringgrid1.Cells[4,irow]:=fieldbyname('used').AsString+'/'+fieldbyname('status').AsString ;
         // stringgrid1.Cells[5,irow]:= fieldbyname('REVISE_TIME').AsString ;
        //  stringgrid1.Cells[6,irow]:=fieldbyname('next_revise_time').AsString ;
          stringgrid1.Cells[5,irow]:=fieldbyname('emp_name').AsString ;
          stringgrid1.Cells[6,irow]:= fieldbyname('locate').AsString ;
          stringgrid1.Cells[7,irow]:= fieldbyname('monitor_dept').AsString ;
          stringgrid1.Cells[8,irow]:= fieldbyname('machine_memo').AsString ;
          stringgrid1.Cells[9,irow]:= fieldbyname('machine_no').AsString ;
          stringgrid1.Cells[10,irow]:= fieldbyname('asset_no').AsString ;
          inc(irow);
          next;                     
       end;
       if irow<=5 then
          irow:=5;
       stringgrid1.FixedCols :=0;
       stringgrid1.FixedRows :=1;
       stringgrid1.ColCount :=icol;
       stringgrid1.Rowcount :=irow;

       lblstatus.Caption :=inttostr(recordcount) ;
      end;

end;


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
    Params.ParamByName('dll_name').AsString := 'MaterialQueryDLL.DLL';
    Open;
  end;


  gettoolingtype;
  getwarehouse;
  getmonitordept;
  cleardata;
end;



procedure TfMain.sbtnQueryClick(Sender: TObject);
begin
   querytoolingmaterial;
end;

procedure TfMain.LabTitle1Click(Sender: TObject);
begin
   // Griviseday:= strtoint(InputBox('Input Box', '請輸入校正時間', '365'));
end;


procedure TfMain.SBTNExportClick(Sender: TObject);
var
  sFileName,My_FileName : String;
  MsExcel, MsExcelWorkBook : Variant;
begin
  if not QryData.Active Then Exit;
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'xls';
  SaveDialog1.Filter := 'All Files(*.xls)|*.xls';
  My_FileName:= DownLoadSampleFile;
  if not FileExists(My_FileName) then
  begin
    showmessage('Error!-The Excel File '+My_FileName+' can''t be found.');
    exit;
  end;
  if SaveDialog1.Execute then
  begin
    try
         sFileName := SaveDialog1.FileName;

          if FileExists(sFileName) then
          begin
            If MessageDlg('File has exist! Replace or Not ?',mtCustom, mbOKCancel,0) = mrOK Then
              DeleteFile(sFileName)
            else
              exit;
          end;
         MsExcel := CreateOleObject('Excel.Application');
         MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);
         SaveExcel(MsExcel,MsExcelWorkBook);
         MsExcelWorkBook.SaveAs(sFileName);
         showmessage('Save Excel OK!!');
    Except
      ShowMessage('Could not start Microsoft Excel.');
    end;

    MsExcel.Application.Quit;
    MsExcel:=Null;
  end
  else
    MessageDlg('You did not Save Any Data',mtWarning,[mbok],0);
end;

procedure TfMain.SaveExcel(MsExcel,MsExcelWorkBook:Variant);
var i,row:integer;
begin
   row:=1;
   if irow>0 then
   for i:=0 to irow do
   begin
     MsExcel.ActiveSheet.range['A'+inttostr(1+row)]:=stringgrid1.Cells[0,i];
     MsExcel.ActiveSheet.range['B'+inttostr(1+row)]:=stringgrid1.Cells[1,i];
     MsExcel.ActiveSheet.range['C'+inttostr(1+row)]:=stringgrid1.Cells[2,i];
     MsExcel.ActiveSheet.range['D'+inttostr(1+row)]:=stringgrid1.Cells[3,i];
     MsExcel.ActiveSheet.range['E'+inttostr(1+row)]:=stringgrid1.Cells[4,i];
     MsExcel.ActiveSheet.range['F'+inttostr(1+row)]:=stringgrid1.Cells[5,i];
     MsExcel.ActiveSheet.range['G'+inttostr(1+row)]:=stringgrid1.Cells[6,i];
     MsExcel.ActiveSheet.range['H'+inttostr(1+row)]:=stringgrid1.Cells[7,i];
     MsExcel.ActiveSheet.range['I'+inttostr(1+row)]:=stringgrid1.Cells[8,i];
     MsExcel.ActiveSheet.range['J'+inttostr(1+row)]:=stringgrid1.Cells[9,i];
     MsExcel.ActiveSheet.range['K'+inttostr(1+row)]:=stringgrid1.Cells[10,i];
     MsExcel.ActiveSheet.range['L'+inttostr(1+row)]:=stringgrid1.Cells[11,i];
     inc(row);
   end;
end;

Function TfMain.DownloadSampleFile : String;
begin
    Result:=ExtractFilePath(Application.ExeName) + ExtractFileName('MATERIALQUERY.xlt')
end;




procedure TfMain.cmbboxwhChange(Sender: TObject);
begin
    getlocate;
end;

end.




