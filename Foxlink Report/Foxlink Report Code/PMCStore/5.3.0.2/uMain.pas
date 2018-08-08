unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  MConnect, SConnect, FileCtrl, ObjBrkr, Menus,DateUtils,comobj,Variants;

type
  TfMain = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    Image2: TImage;
    Image3: TImage;
    ImgDelete: TImage;
    LabTitle2: TLabel;
    sbtnQuery: TSpeedButton;
    sbtnexport: TSpeedButton;
    sbtnPrint: TSpeedButton;
    LabTitle1: TLabel;
    QryData: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    Memo1: TMemo;
    DBGrid1: TDBGrid;
    Label2: TLabel;
    labCnt: TLabel;
    labcost: TLabel;
    SaveDialog2: TSaveDialog;
    editPart: TEdit;
    sbtnpart: TSpeedButton;
    qryReel: TClientDataSet;
    procedure sbtnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnexportClick(Sender: TObject);
    procedure sbtnpartClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    procedure SetStatusbyAuthority;
    procedure showstore;
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);
    Function DownloadSampleFile : String;
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform, uData, uReel;

procedure TfMain.showstore;
var i:integer;
begin
  //
  with qrydata do
  begin
   close;
   params.Clear;
   commandtext:=' select b.part_no,b.spec1,b.version,b.uom,sum(nvl(a.reel_qty,a.material_qty)) qty ,c.warehouse_name,d.locate_name '
               +' from sajet.g_material a,sajet.sys_part b,sajet.sys_warehouse c,sajet.sys_locate d '
               +' where a.status = ''1'' '
               +'       and a.part_id=b.part_id '
               +'       and a.warehouse_id=c.warehouse_id(+) '
               +'       and a.locate_id= d.locate_id(+) ';
   if trim(editPart.Text)<>'' then
     commandtext:=commandtext+' and b.part_no='+''''+trim(editPart.Text)+'''';
   commandtext:=commandtext +' group by b.part_no,b.spec1,b.version,b.uom,c.warehouse_name,d.locate_name '
                            +' order by b.part_no,c.warehouse_name,d.locate_name ';
   memo1.Text:=commandtext;
   open;
   for i:=0 to dbgrid1.Columns.Count-1 do
     if uppercase(dbgrid1.Columns[i].Title.Caption)='SPEC1' then
        dbgrid1.Columns[i].Width:=250
     else if uppercase(dbgrid1.Columns[i].Title.Caption)='QTY' then
        dbgrid1.Columns[i].Width:=50
     else dbgrid1.Columns[i].Width:=120;
  end;
end;

procedure TfMain.SetStatusbyAuthority;
var iPrivilege: integer;
begin
  {iPrivilege := 0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Material Management';
      Params.ParamByName('FUN').AsString := 'RT Maintain';
      Execute;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;       }

end;

procedure TfMain.sbtnQueryClick(Sender: TObject);
var 
  T1:tDate;
begin
  if trim(editpart.Text)='' then exit;
  t1:=time;
  showstore ;
  labcnt.Caption:='Records: '+inttostr(dbgrid1.DataSource.DataSet.recordcount)+' ';
  labcost.Caption:='  The search cost you '+IntToStr(MilliSecondsBetween(Time,T1))+' MilliSeconds.';
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
 {
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
    if gsParam <> '' then
      CommandText := CommandText + 'and fun_param = ''' + gsParam + ''' ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'QUERYSTOREDLL.DLL';
    memo1.Text:=commandtext;
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString+'  ';
    LabTitle2.Caption := LabTitle1.Caption;  
  end;

  if UpdateUserID <> '0' then
    SetStatusbyAuthority; }
  //ShowData;
end;

procedure TfMain.sbtnexportClick(Sender: TObject);
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
   if uppercase(gsParam)='STORE' then
     MsExcel.Worksheets['Store'].select
   else MsExcel.Worksheets['Unstore'].select;

   if qrydata.RecordCount>1 then
   begin
     for i:=1 to qrydata.RecordCount do
       MsExcel.ActiveSheet.Rows[4].Insert;
   end;
   row:=1;
   qrydata.First;
   while not qrydata.Eof do
   begin
     MsExcel.ActiveSheet.range['A'+inttostr(3+row)]:=inttostr(row);
     if uppercase(gsParam)='STORE' then
     begin
        MsExcel.ActiveSheet.range['B'+inttostr(3+row)]:=qrydata.FieldByName('part_no').asstring;
        MsExcel.ActiveSheet.range['C'+inttostr(3+row)]:=qrydata.FieldByName('spec1').asstring;
        MsExcel.ActiveSheet.range['D'+inttostr(3+row)]:=qrydata.FieldByName('version').asstring;
        MsExcel.ActiveSheet.range['E'+inttostr(3+row)]:=qrydata.FieldByName('uom').asstring;
        MsExcel.ActiveSheet.range['F'+inttostr(3+row)]:=qrydata.FieldByName('qty').asstring;
        MsExcel.ActiveSheet.range['G'+inttostr(3+row)]:=qrydata.FieldByName('warehouse_name').asstring;
        MsExcel.ActiveSheet.range['H'+inttostr(3+row)]:=qrydata.FieldByName('locate_name').asstring;
     end
     else begin
        MsExcel.ActiveSheet.range['B'+inttostr(3+row)]:=qrydata.FieldByName('rt_no').asstring;
        MsExcel.ActiveSheet.range['C'+inttostr(3+row)]:=qrydata.FieldByName('receive_time').asstring;
        MsExcel.ActiveSheet.range['D'+inttostr(3+row)]:=qrydata.FieldByName('part_no').asstring;
        MsExcel.ActiveSheet.range['E'+inttostr(3+row)]:=qrydata.FieldByName('spec1').asstring;
        MsExcel.ActiveSheet.range['F'+inttostr(3+row)]:=qrydata.FieldByName('warehouse_name').asstring;
        MsExcel.ActiveSheet.range['G'+inttostr(3+row)]:=qrydata.FieldByName('locate_name').asstring;
        MsExcel.ActiveSheet.range['H'+inttostr(3+row)]:=qrydata.FieldByName('qty').asstring;
     end;
     inc(row);
     qrydata.Next;
   end;
   if uppercase(gsParam)='STORE' then
     MsExcel.ActiveSheet.range['F'+inttostr(3+row)]:='=SUM(F4:F'+inttostr(3+row-1)+')'
   else  MsExcel.ActiveSheet.range['H'+inttostr(3+row)]:='=SUM(H4:H'+inttostr(3+row-1)+')';
end;

Function TfMain.DownloadSampleFile : String;
begin
    Result:=ExtractFilePath(Application.ExeName) + ExtractFileName('PMCStroe.xlt')
end;

procedure TfMain.sbtnpartClick(Sender: TObject);
begin
  fData:=Tfdata.Create(self);
  fData.DataSource1.DataSet:=qrytemp;

  with qrytemp do
  begin
    close;
    params.Clear;
    commandtext:=' select a.part_no,a.spec1,warehouse_name,locate_name '
                +' from sajet.sys_part a,sajet.sys_locate b,sajet.sys_warehouse c '
                +' where a.option2=b.locate_id(+) and b.warehouse_id=c.warehouse_id(+) '
                +'    and part_no like '+''''+trim(editPart.Text)+'%'+'''';
    open;
  end;
  if fData.ShowModal=mrok then
  begin
    editpart.Text:=qrytemp.fieldbyname('part_no').AsString;
  end;

end;

procedure TfMain.DBGrid1DblClick(Sender: TObject);
var sPart,sWarehouse,sLocate:string;
begin
//
  if not qrydata.Active then exit;
  if qrydata.IsEmpty then exit;
  sPart:=qrydata.fieldbyname('part_no').AsString;
  sWarehouse:=qrydata.fieldbyname('warehouse_name').AsString;
  sLocate:=qrydata.fieldbyname('locate_name').AsString;

  fDetail:=TfDetail.Create(self);
  fDetail.DataSource1.DataSet:=qryreel;

  with qryreel do
  begin
    close;
    params.Clear;
    commandtext:=' select b.part_no,a.material_no,a.material_qty,a.datecode,a.reel_no,a.reel_qty,d.warehouse_name,c.locate_name,a.release_qty,e.emp_no,a.update_time '
                +' from sajet.g_material a,sajet.sys_part b,sajet.sys_locate c,sajet.sys_warehouse d,sajet.sys_emp e '
                +' where a.part_id = b.part_id '
                +'     and a.locate_id = c.locate_id(+) '
                +'     and c.warehouse_id = d.warehouse_id(+) '
                +'     and a.update_userid=e.emp_id(+) '
                +'     and a.status =''1'' '
                +'     and b.part_no = '+''''+sPart+''''
                +'     and d.warehouse_name= '+''''+sWarehouse+'''';
    if sLocate='' then
      commandtext:=commandtext+' and c.locate_name is null '
    else
      commandtext:=commandtext+'     and c.locate_name= '+''''+sLocate+'''';
    open;
    memo1.Text:=commandtext;
  end;

  fDetail.ShowModal ;

end;

end.

