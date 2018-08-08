unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  MConnect, SConnect, FileCtrl, ObjBrkr, Menus,DateUtils,comobj,Variants,
  DBGrid1;

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
    Label2: TLabel;
    labCnt: TLabel;
    labcost: TLabel;
    SaveDialog2: TSaveDialog;
    editWO: TEdit;
    sbtnpart: TSpeedButton;
    qryDetail: TClientDataSet;
    DBGrid11: TDBGrid1;
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
    procedure showPick;
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);
    Function DownloadSampleFile : String;
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform, uData, uDetail;

procedure TfMain.showPick;
begin
  //
  with qrydata do
  begin
   close;
   params.Clear;
   commandtext:= ' select a.work_order,b.part_no,a.version,a.request_qty,a.issue_qty,a.ab_issue_qty,a.ab_return_qty,a.request_qty-ab_issue_qty-issue_qty+ab_return_qty open_qty,b.qty Store_qty '
                +' from sajet.g_wo_pick_list a,sajet.v_warehouse_wk b '
                +' where a.part_id=b.part_id ' ;
   if trim(editWO.Text)<>'' then
     commandtext:=commandtext+' and a.work_order = '+''''+ trim(editWO.Text)+'''';
   memo1.Text:=commandtext;
   open;
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
  if trim(editWO.Text)='' then exit;
  t1:=time;
  showPick;
  labcnt.Caption:='Records: '+inttostr(dbgrid11.DataSource.DataSet.recordcount)+' ';
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
    Params.ParamByName('dll_name').AsString := 'PMCPICKDLL.DLL';
    memo1.Text:=commandtext;
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString+'  ';
    LabTitle2.Caption := LabTitle1.Caption;  
  end;

 { if UpdateUserID <> '0' then
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

   if qrydata.RecordCount>1 then
   begin
     for i:=1 to qrydata.RecordCount do
       MsExcel.ActiveSheet.Rows[4].Insert;
   end;
   MsExcel.ActiveSheet.range['A2']:='Work Order: '+trim(editWO.Text);
   row:=1;
   qrydata.First;
 
   while not qrydata.Eof do
   begin
     MsExcel.ActiveSheet.range['A'+inttostr(3+row)]:=inttostr(row);
     MsExcel.ActiveSheet.range['B'+inttostr(3+row)]:=qrydata.FieldByName('work_order').asstring;
     MsExcel.ActiveSheet.range['C'+inttostr(3+row)]:=qrydata.FieldByName('part_no').asstring;
     MsExcel.ActiveSheet.range['D'+inttostr(3+row)]:=qrydata.FieldByName('version').asstring;
     MsExcel.ActiveSheet.range['E'+inttostr(3+row)]:=qrydata.FieldByName('request_qty').asstring;
     MsExcel.ActiveSheet.range['F'+inttostr(3+row)]:=qrydata.FieldByName('issue_qty').asstring;
     MsExcel.ActiveSheet.range['G'+inttostr(3+row)]:=qrydata.FieldByName('ab_issue_qty').asstring;
     MsExcel.ActiveSheet.range['H'+inttostr(3+row)]:=qrydata.FieldByName('ab_return_qty').asstring;
     MsExcel.ActiveSheet.range['I'+inttostr(3+row)]:=qrydata.FieldByName('open_qty').asstring;
     MsExcel.ActiveSheet.range['J'+inttostr(3+row)]:=qrydata.FieldByName('store_qty').asstring;
     inc(row);
     qrydata.Next;
   end;
end;

Function TfMain.DownloadSampleFile : String;
begin
    Result:=ExtractFilePath(Application.ExeName) + ExtractFileName('PMCPick.xlt')
end;

procedure TfMain.sbtnpartClick(Sender: TObject);
begin
  fData:=Tfdata.Create(self);
  fData.DataSource1.DataSet:=qrytemp;

  with qrytemp do
  begin
    close;
    params.Clear;
    commandtext:=' select a.work_order,b.part_no model_name,decode(wo_status,''0'',''Initial'',''1'',''Prepare'',''2'',''Release'',''3'',''WIP'',''4'',''Hold'',''5'',''Cancel'',''6'',''Complete'',''9'',''Complete-NoCharge'') wo_status '
                +'         ,a.target_qty,a.input_qty,a.output_qty '
                +' from sajet.g_wo_base a, sajet.sys_part b '
                +' where a.model_id=b.part_id '
                +'     and work_order like '+''''+trim(editwo.text)+'%'+'''';
    open;
  end;
  if fData.ShowModal=mrok then
  begin
    editWO.Text:=qrytemp.fieldbyname('work_order').AsString;
    sbtnQueryClick(self);
  end;   
end;

procedure TfMain.DBGrid1DblClick(Sender: TObject);
var sPart,sWO,sLocate:string;
begin
//
  if not qrydata.Active then exit;
  if qrydata.IsEmpty then exit;
  sPart:=qrydata.fieldbyname('part_no').AsString;
  sWO:=qrydata.fieldbyname('work_order').AsString;
  //sLocate:=qrydata.fieldbyname('locate_name').AsString;

  fDetail:=TfDetail.Create(self);
  fDetail.DataSource1.DataSet:=QryDetail;

  with qrydetail do
  begin
    close;
    params.Clear;
    commandtext:=' select a.work_order,b.part_no,a.material_no,a.qty,c.emp_name commit_user,a.update_time,d.emp_name confirm_user '
                +' from sajet.g_pick_list a,sajet.sys_part b,sajet.sys_emp c,sajet.sys_emp d '
                +' where  a.part_id=b.part_id '
                +'     and a.update_userid=c.emp_id(+) '
                +'     and a.CONFIRM_USERID =d.emp_id(+) '
                +'     and a.work_order='+''''+sWO+''''
                +'     and b.part_no='+''''+sPart+'''';
    open;
    memo1.Text:=commandtext;
  end;
  if not qrydetail.isempty then
    fDetail.ShowModal ;
  qrydetail.Close;
end;

end.

