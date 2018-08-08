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
    PopupMenu1: TPopupMenu;
    Append1: TMenuItem;
    Modify1: TMenuItem;
    Delete1: TMenuItem;
    ModifyLog1: TMenuItem;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    cmbWarehouse: TComboBox;
    cmbLocate: TComboBox;
    cmbWarehouseID: TComboBox;
    cmbLocateID: TComboBox;
    Memo1: TMemo;
    DBGrid1: TDBGrid;
    Label2: TLabel;
    labCnt: TLabel;
    labcost: TLabel;
    SaveDialog2: TSaveDialog;
    procedure sbtnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmbWarehouseChange(Sender: TObject);
    procedure cmbLocateChange(Sender: TObject);
    procedure sbtnexportClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    procedure SetStatusbyAuthority;
    procedure AddWareHouse;
    procedure showstore;
    procedure showUnstore;
    function GetField(sFields:string):string;
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);
    Function DownloadSampleFile : String;
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform;

function TfMain.GetField(sFields:string):string;
begin
  result:='';
  with qrytemp do
  begin
    close;
    params.Clear;
    commandtext:=' select PARAM_VALUE '
                +' from sajet.sys_base '
                +' where  PARAM_NAME= '+sFields;
    open;
    if not isempty then
     result:= fieldbyname('param_value').AsString;
  end;
end;

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
   if trim(cmbwarehouse.Text)<>'' then
   begin
     commandtext:=commandtext+' and a.warehouse_id = '+cmbwarehouseID.Text;
   end;
   if trim(cmbLocate.Text)<>'' then
   begin
     commandtext:= commandtext+' and a.locate_id = '+cmbLocateID.text;
   end;
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

procedure TfMain.showUnstore;
var i:integer;
begin
//
  with qrydata do
  begin
    close;
    params.Clear;
    commandtext:=' select b.rt_no,b.receive_time,c.part_no,c.spec1,d.warehouse_name,e.locate_name,sum(nvl(reel_qty,material_qty)) qty  '
                +' from sajet.g_material a,sajet.g_erp_rtno b,sajet.sys_part c, sajet.sys_warehouse d,sajet.sys_locate e '
                +' where a.status=''0'' '
                +'   and a.rt_id=b.rt_id '
                +'   and a.part_id =c.part_id(+) '
                +'   and c.option2=e.locate_id(+) '
                +'   and e.warehouse_id=d.warehouse_id(+) ';
   if trim(cmbwarehouse.Text)<>'' then
   begin
     commandtext:=commandtext+' and d.warehouse_id = '+cmbwarehouseID.Text;
   end;
   if trim(cmbLocate.Text)<>'' then
   begin
     commandtext:= commandtext+' and e.locate_id = '+cmbLocateID.text;
   end;

   commandtext:=commandtext+' group by b.rt_no, b.receive_time,c.part_no,c.spec1,d.warehouse_name,e.locate_name '
                           +' order by b.rt_no,b.receive_time,c.part_no,c.spec1,d.warehouse_name,e.locate_name ';
   open;
   for i:=0 to dbgrid1.Columns.Count-1 do
     if uppercase(dbgrid1.Columns[i].Title.Caption)='SPEC1' then
        dbgrid1.Columns[i].Width:=250
     else if uppercase(dbgrid1.Columns[i].Title.Caption)='QTY' then
        dbgrid1.Columns[i].Width:=50
     else dbgrid1.Columns[i].Width:=120;
  end;
end;

procedure TfMain.AddWareHouse;
begin
  cmbWarehouse.Clear;
  cmbWarehouseID.Clear;
  cmbWarehouse.Items.Add('');
  cmbWarehouseID.Items.Add('');
  with qrytemp do
  begin
    close;
    params.clear;
    commandtext:='select * from sajet.sys_warehouse where ENABLED=''Y'' ';
    open;
    if not isempty then
    begin
      while not eof do
      begin
        cmbWarehouse.Items.add(fieldbyname('WAREHOUSE_NAME').asstring);
        cmbWarehouseID.Items.add(fieldbyname('WAREHOUSE_ID').asstring);
        next;
      end;
      cmbWareHouse.ItemIndex:=0;
      cmbWareHouseID.ItemIndex:=0;
    end;
  end;
  cmbWarehouseChange(self);
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
  t1:=time;
  if uppercase(gsParam)='STORE' then
      showstore
  else showUnstore;
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
    SetStatusbyAuthority;
  AddWareHouse;
  //ShowData;
end;

procedure TfMain.cmbWarehouseChange(Sender: TObject);
begin
  cmbWareHouseId.ItemIndex:=cmbWareHouse.ItemIndex;
  cmbLocate.Items.Clear;
  cmbLocateID.Items.Clear;
  cmbLocate.Items.Add('');
  cmbLocateID.Items.Add('');
  with qrytemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'iWareHouse', ptInput);
    commandtext:=' select * from sajet.sys_locate where warehouse_id=:iWareHouse ';
    Params.ParamByName('iWareHouse').AsString := cmbWareHouseId.Text;
    open;
    if not isempty then
    begin
      while not eof do
      begin
        cmbLocate.Items.Add(fieldbyname('locate_name').AsString);
        cmbLocateID.Items.Add(fieldbyname('locate_id').AsString);
        next;
      end;
    end;
  end;
end;

procedure TfMain.cmbLocateChange(Sender: TObject);
begin
  cmbLocateId.ItemIndex:=cmbLocate.ItemIndex;
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
  if uppercase(gsParam)='STORE' then
    Result:=ExtractFilePath(Application.ExeName) + ExtractFileName('MaterialStroe.xlt')
  else  Result:=ExtractFilePath(Application.ExeName) + ExtractFileName('MaterialUnstroe.xlt');
end;

end.

