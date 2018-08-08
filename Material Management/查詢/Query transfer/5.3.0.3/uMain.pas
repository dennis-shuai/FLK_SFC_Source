unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  MConnect, SConnect, FileCtrl, ObjBrkr, Menus,DateUtils,comobj,Variants,
  ComCtrls;

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
    DTStart: TDateTimePicker;
    DTEnd: TDateTimePicker;
    cmbType: TComboBox;
    Label3: TLabel;
    cmbWarehouse: TComboBox;
    cmblocate: TComboBox;
    cmbDisplay: TComboBox;
    Label4: TLabel;
    procedure sbtnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnexportClick(Sender: TObject);
    procedure sbtnpartClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure cmbTypeChange(Sender: TObject);
    procedure cmbWarehouseChange(Sender: TObject);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    procedure SetStatusbyAuthority;
    procedure showTransfer;
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);
    Function DownloadSampleFile : String;
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform, uData, uReel;

procedure TfMain.DBGrid1TitleClick(Column: TColumn);
var bAesc: Boolean;
begin
  bAesc := True;
  if DBGrid1.DataSource = nil then Exit;
  if DBGrid1.DataSource.DataSet = nil then Exit;
  if not (DBGrid1.DataSource.DataSet is TClientDataSet) then Exit;
  if (DBGrid1.DataSource.DataSet as TClientDataSet).Active then
  begin
    if (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName <> '' then
    begin
      bAesc := True;
      if (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName = Column.FieldName then
        bAesc := False;
       (DBGrid1.DataSource.DataSet as TClientDataSet).deleteIndex((DBGrid1.DataSource.DataSet as TClientDataSet).Indexname);
    end;
    if bAesc then begin
      (DBGrid1.DataSource.DataSet as TClientDataSet).AddIndex(Column.FieldName, Column.FieldName, [], '', '', 0);
      (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName := Column.FieldName;
    end else begin
      (DBGrid1.DataSource.DataSet as TClientDataSet).AddIndex(Column.FieldName + 'D', Column.FieldName, [ixDescending], '',
'', 0);
      (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName := Column.FieldName + 'D';
    end;
    (DBGrid1.DataSource.DataSet as TClientDataSet).IndexDefs.Update;
  end;
end;

procedure TfMain.showTransfer;
var i:integer;
begin
  //
  with qrydata do
  begin
   close;
   params.Clear;

   commandtext:=' select part_no,update_time,type,locator,material_no,material_qty,reel_no,reel_qty,emp_name,source from ( ';
   commandtext:= commandtext
               +' select b1.part_no,to_char(a1.update_time,''YYYY/MM/DD HH24:Mi:SS'') update_time,decode(a1.type,''I'',''INPUT'',''O'',''OUTPUT'',''S'',''SPLIT'',''M'',''MERGE'',''P'',''PRINT'',''C'',''CLEAR'',''UNKNOW'') type '
               +'      ,c1.warehouse_name||''-''||d1.locate_name locator,a1.material_no,a1.material_qty,a1.reel_no,a1.reel_qty,e1.emp_name,a1.remark as source '
               +' from sajet.g_ht_material a1,sajet.sys_part b1,sajet.sys_warehouse c1,sajet.sys_locate d1,sajet.sys_emp e1 '
               +' where a1.part_id=b1.part_id and a1.update_userid=e1.emp_id(+) and a1.warehouse_id=c1.warehouse_id(+) and a1.locate_id=d1.locate_id(+) ';
   if cmbtype.ItemIndex=0 then
   begin
     if trim(editPart.Text)<>'' then
       commandtext:=commandtext+' and b1.part_no='+''''+trim(editPart.Text)+'''';
   end
   else if  cmbType.ItemIndex=1 then
   begin
     if trim(cmbWarehouse.Text)<>'' then
     begin
       if trim(cmbLocate.Text)<>'' then
         commandtext:=commandtext+' and c1.warehouse_name= '+''''+trim(cmbWarehouse.Text)+''''+' and d1.locate_name = '+''''+trim(cmbLocate.Text)+''''
       else
         commandtext:=commandtext+' and c1.warehouse_name= '+''''+trim(cmbWarehouse.Text)+'''';
     end;
   end;

   if cmbDisplay.itemindex=1 then
   begin
     commandtext:=commandtext+' and (a1.type=''I''or a1.type=''O'')';
   end
   else if cmbDisPlay.itemindex=2 then
   begin
     commandtext:=commandtext+' and (a1.type=''I'') '
   end
   else if cmbDisPlay.itemIndex=3 then
   begin
     commandtext:=commandtext+' and (a1.type=''O'') '
   end
   else if cmbDisPlay.itemIndex=4 then
   begin
     commandtext:=commandtext+' and (a1.type=''C'') '
   end;

   commandtext:=commandtext+ 'and ( (to_char(a1.update_time,''YYYYMMDD'') >= '+FormatDateTime('YYYYMMDD',DTStart.Date)+')  and (to_char(a1.update_time,''YYYYMMDD'')<='
                          +FormatDateTime('YYYYMMDD',DtEnd.Date)+') )';
   commandtext:=commandtext
               +' union '
               +' select b2.part_no,to_char(a2.update_time,''YYYY/MM/DD HH24:Mi:SS'') update_time,decode(a2.type,''I'',''INPUT'',''O'',''OUTPUT'',''S'',''SPLIT'',''M'',''MERGE'',''P'',''PRINT'',''C'',''CLEAR'',''UNKNOW'') type '
               +'      ,c2.warehouse_name||''-''||d2.locate_name locator,a2.material_no,a2.material_qty,a2.reel_no,a2.reel_qty,e2.emp_name,a2.remark as source '
               +' from sajet.g_material a2,sajet.sys_part b2,sajet.sys_warehouse c2,sajet.sys_locate d2,sajet.sys_emp e2 '
               +' where a2.part_id=b2.part_id and a2.update_userid=e2.emp_id(+) and a2.warehouse_id=c2.warehouse_id(+) and a2.locate_id=d2.locate_id(+) ';
   if cmbtype.ItemIndex=0 then
   begin
     if trim(editPart.Text)<>'' then
       commandtext:=commandtext+' and b2.part_no='+''''+trim(editPart.Text)+'''';
   end
   else if  cmbType.ItemIndex=1 then
   begin
     if trim(cmbWarehouse.Text)<>'' then
     begin
       if trim(cmbLocate.Text)<>'' then
         commandtext:=commandtext+' and c2.warehouse_name= '+''''+trim(cmbWarehouse.Text)+''''+' and d2.locate_name = '+''''+trim(cmbLocate.Text)+''''
       else
         commandtext:=commandtext+' and c2.warehouse_name= '+''''+trim(cmbWarehouse.Text)+'''';
     end;
   end;

   if cmbDisplay.itemindex=1 then
   begin
     commandtext:=commandtext+' and (a2.type=''I''or a2.type=''O'')';
   end
   else if cmbDisPlay.itemindex=2 then
   begin
     commandtext:=commandtext+' and (a2.type=''I'') '
   end
   else if cmbDisPlay.itemIndex=3 then
   begin
     commandtext:=commandtext+' and (a2.type=''O'') '
   end
   else if cmbDisPlay.itemIndex=4 then
   begin
     commandtext:=commandtext+' and (a2.type=''C'') '
   end;

   commandtext:=commandtext+ 'and to_char(a2.update_time,''YYYYMMDD'') between '+FormatDateTime('YYYYMMDD',DTStart.Date)+'  and '
                          +FormatDateTime('YYYYMMDD',DTEnd.Date);
   commandtext:=commandtext+' )  group by material_no,reel_no,type,part_no,material_qty,reel_qty,update_time,locator,emp_name,source '
                           +' order by material_no,reel_no,update_time  ';
   memo1.Text:=commandtext;
   open;
   for i:=0 to dbgrid1.Columns.Count-1 do
   begin
     dbgrid1.Columns[i].Width:=100;
   end;
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
  t1:=time;
  showTransfer ;
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
    Params.ParamByName('dll_name').AsString := 'QUERYTRANSFERDLL.DLL';
    memo1.Text:=commandtext;
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString+'  ';
    LabTitle2.Caption := LabTitle1.Caption;  
  end;  
  DTstart.DateTime:=now;
  DtEnd.DateTime:=now;

  cmbType.ItemIndex:=0;
  cmbWarehouse.Visible:=false;
  cmbLocate.Visible:=false;
  with qrytemp do
  begin
    close;
    params.Clear;
    commandtext:=' select warehouse_name from sajet.sys_warehouse ';
    open;
    while not eof do
    begin
      cmbWarehouse.Items.Add(fieldbyname('warehouse_name').AsString);
      next;
    end;
  end;
  cmbwarehouse.ItemIndex:=0;
  cmbWarehouseChange(self); 
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
   MsExcel.Worksheets['Transfer'].select;

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
     {if uppercase(gsParam)='STORE' then        part_no,update_time,type,locator,material_no,material_qty,reel_no,reel_qty
     begin }
        MsExcel.ActiveSheet.range['B'+inttostr(3+row)]:=qrydata.FieldByName('part_no').asstring;
        MsExcel.ActiveSheet.range['C'+inttostr(3+row)]:=qrydata.FieldByName('update_time').asstring;
        MsExcel.ActiveSheet.range['D'+inttostr(3+row)]:=qrydata.FieldByName('type').asstring;
        MsExcel.ActiveSheet.range['E'+inttostr(3+row)]:=qrydata.FieldByName('locator').asstring;
        MsExcel.ActiveSheet.range['F'+inttostr(3+row)]:=qrydata.FieldByName('material_no').asstring;
        MsExcel.ActiveSheet.range['G'+inttostr(3+row)]:=qrydata.FieldByName('material_qty').asstring;
        MsExcel.ActiveSheet.range['H'+inttostr(3+row)]:=qrydata.FieldByName('reel_no').asstring;
        MsExcel.ActiveSheet.range['J'+inttostr(3+row)]:=qrydata.FieldByName('reel_qty').asstring;
        MsExcel.ActiveSheet.range['K'+inttostr(3+row)]:=qrydata.FieldByName('emp_name').asstring;
        MsExcel.ActiveSheet.range['L'+inttostr(3+row)]:=qrydata.FieldByName('source').asstring;
    { end
     else begin
        MsExcel.ActiveSheet.range['B'+inttostr(3+row)]:=qrydata.FieldByName('rt_no').asstring;
        MsExcel.ActiveSheet.range['C'+inttostr(3+row)]:=qrydata.FieldByName('receive_time').asstring;
        MsExcel.ActiveSheet.range['D'+inttostr(3+row)]:=qrydata.FieldByName('part_no').asstring;
        MsExcel.ActiveSheet.range['E'+inttostr(3+row)]:=qrydata.FieldByName('spec1').asstring;
        MsExcel.ActiveSheet.range['F'+inttostr(3+row)]:=qrydata.FieldByName('warehouse_name').asstring;
        MsExcel.ActiveSheet.range['G'+inttostr(3+row)]:=qrydata.FieldByName('locate_name').asstring;
        MsExcel.ActiveSheet.range['H'+inttostr(3+row)]:=qrydata.FieldByName('qty').asstring;
     end; }
     inc(row);
     qrydata.Next;
   end;
  { if uppercase(gsParam)='STORE' then
     MsExcel.ActiveSheet.range['F'+inttostr(3+row)]:='=SUM(F4:F'+inttostr(3+row-1)+')'
   else  MsExcel.ActiveSheet.range['H'+inttostr(3+row)]:='=SUM(H4:H'+inttostr(3+row-1)+')'; }
end;

Function TfMain.DownloadSampleFile : String;
begin
    Result:=ExtractFilePath(Application.ExeName) + ExtractFileName('QueryTransfer.xlt')
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
 { if not qrydata.Active then exit;
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
                +'     and c.locate_name= '+''''+sLocate+'''';
    open;
    memo1.Text:=commandtext;
  end;

  fDetail.ShowModal ;  }

end;

procedure TfMain.cmbTypeChange(Sender: TObject);
begin
  if cmbType.ItemIndex=0 then
  begin
    editPart.Visible:=true;
    sbtnPart.Visible:=true;
    cmbWarehouse.Visible:=false;
    cmbLocate.Visible:=false;
  end
  else if cmbType.ItemIndex=1 then
  begin
    editPart.Visible:=false;
    sbtnPart.Visible:=false;
    cmbWarehouse.Visible:=true;
    cmbLocate.Visible:=true;
  end;
end;

procedure TfMain.cmbWarehouseChange(Sender: TObject);
begin
  cmblocate.Clear;
  cmblocate.Items.Add('');
  with qrytemp do
  begin
    close;
    params.Clear;
    commandtext:=' select locate_name from sajet.sys_locate a,sajet.sys_warehouse b '
                +' where a.warehouse_id=b.warehouse_id and b.warehouse_name ='+''''+trim(cmbwarehouse.Text)+'''';
    open;
    while not eof do
    begin
      cmblocate.Items.Add(fieldbyname('locate_name').AsString);
      next;
    end;
    cmbLocate.ItemIndex:=0;
  end;
end;

procedure TfMain.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
    if QryData.recordcount>0 then
    begin
     try
      if QryData.FieldByName('type').AsString='INPUT' then
      begin
        DBGrid1.Canvas.Brush.Color:=$D4FF7F;
        DBGrid1.DefaultDrawColumnCell(rect,datacol,column,state);
      end
      else  if QryData.FieldByName('type').AsString<>'OUTPUT' then
      begin
        DBGrid1.Canvas.Brush.Color:=$DCDCDC;
        DBGrid1.DefaultDrawColumnCell(rect,datacol,column,state);
      end
      else begin
        DBGrid1.Canvas.Brush.Color:=$D7EBFA;
        DBGrid1.DefaultDrawColumnCell(rect,datacol,column,state);
      end;
     except
     end;
    end;
end;

end.

