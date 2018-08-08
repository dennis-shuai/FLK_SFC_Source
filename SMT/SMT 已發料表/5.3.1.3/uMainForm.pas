unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang,DateUtils,excel2000,ComObj,Math;

type
  TfMainForm = class(TForm)
    sbtnClose: TSpeedButton;
    Image2: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SimpleObjectBroker1: TSimpleObjectBroker;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SocketConnection1: TSocketConnection;
    dsData: TDataSource;
    SaveDialog: TSaveDialog;
    QryDetail: TClientDataSet;
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    ImageAll: TImage;
    lbl1: TLabel;
    dtpStart: TDateTimePicker;
    cmbStart: TComboBox;
    lbl2: TLabel;
    dtpEnd: TDateTimePicker;
    cmbEnd: TComboBox;
    edtWo: TEdit;
    lbl4: TLabel;
    img1: TImage;
    btnQuery: TSpeedButton;
    imgSample: TImage;
    btnPrint: TSpeedButton;
    dbgrd1: TDBGrid;
    dlgSave1: TSaveDialog;
    lblVersion: TLabel;
    img2: TImage;
    btnPreview: TSpeedButton;
    img3: TImage;
    Image1: TImage;
    Image3: TImage;
    btnExport: TSpeedButton;
    img4: TImage;
    lblMsg: TLabel;
    cmbMachine: TComboBox;
    lbl3: TLabel;
    lblLine: TLabel;
    cmbLine: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure GetVersion(S: string);
    procedure edtWoChange(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure Release_Excel;
    function  init_Excel():Boolean;
    procedure PrintExcel(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure cmbLineSelect(Sender: TObject);
  public
    UpdateUserID,sModel: String;
    MsExcel,MsExcelWorkBook:Variant;

  end;

var
  fMainForm: TfMainForm;


implementation




{$R *.dfm}

uses uDataDetail;

procedure TfMainForm.FormShow(Sender: TObject);
var i :integer;
begin
//------

    cmbMachine.Style := csDropDownList;
    dtpStart.Date :=  Now;
    dtpEnd.Date :=  tomorrow;
    GetVersion(ExtractFileDir(Application.ExeName) + '\SMTISSUEREPORTDll.Dll');

end;

procedure TfMainForm.btnQueryClick(Sender: TObject);
var starttime,endtime:string;
begin
    starttime := FormatDateTime('YYYYMMDD',dtpStart.date)+cmbStart.Text ;
    endtime := FormatDateTime('YYYYMMDD',dtpEnd.date)+cmbEnd.Text;
    if edtWo.Text ='' then Exit;
    if cmbLine.Text ='' then Exit;
    if cmbMachine.Text ='' then Exit;

    QryData.Close;
    QryData.Params.Clear;
    QryData.Params.CreateParam(ftString,'StartTime',ptInput);
    QryData. Params.CreateParam(ftString,'EndTime',ptInput);
    QryData. Params.CreateParam(ftString,'WO',ptInput);
    QryData. Params.CreateParam(ftString,'Pdline',ptInput);
    if cmbMachine.Text <> 'Command Material' then
        QryData. Params.CreateParam(ftString,'Machine',ptInput);
    QryData.CommandText := ' SELECT BB.PART_NO,BB.SPEC2,CC.MATERIAL_NO,CC.QTY,CC.UPDATE_TIME,DD.TARGET_QTY,TO_CHAR(SYSDATE,''YYYY/MM/DD'') IDATE  '+
         ' FROM ( SELECT A.WORK_ORDER,B.ITEM_PART_ID PART_ID,c.Machine_code '+
         ' FROM SMT.G_WO_MSL A ,SMT.G_WO_MSL_DETAIL B ,SAJET.SYS_MACHINE C,SAJET.SYS_PDLINE D '+
         ' WHERE   A.WO_SEQUENCE= B.WO_SEQUENCE  AND A.WORK_ORDER=:WO AND a.machine_id =c.machine_id and a.pdline_id =d.pdline_id    ';
    if cmbMachine.Text <> 'Command Material' then
        QryData.CommandText :=  QryData.CommandText  + ' and c.machine_code =:machine AND C.MACHINE_LOC=D.PDLINE_NAME ';    { AND C.MACHINE_LOC=D.PDLINE_NAME }
     QryData.CommandText :=  QryData.CommandText  + 'and d.pdline_name = :pdline '+
         ' UNION    '+
         ' SELECT   A.WORK_ORDER,C.SUB_PART_ID PART_ID,D.Machine_code  '+
         ' FROM SMT.G_WO_MSL A ,SMT.G_WO_MSL_DETAIL B,smt.g_wo_msl_sub C ,SAJET.SYS_MACHINE D,SAJET.SYS_PDLINE E '+
         ' WHERE  A.WO_SEQUENCE= B.WO_SEQUENCE AND  B.WO_SEQUENCE=C.WO_SEQUENCE  AND a.machine_id =d.machine_id and '+
         ' a.pdline_id =e.pdline_id   ';
     if cmbMachine.Text <> 'Command Material' then
        QryData.CommandText :=  QryData.CommandText  + ' and d.machine_code = :machine  AND D.MACHINE_LOC=E.PDLINE_NAME ';   { AND D.MACHINE_LOC=E.PDLINE_NAME }
     QryData.CommandText :=  QryData.CommandText  + 'and e.pdline_name = :pdline '+
         ' AND B.ITEM_PART_ID = C.ITEM_PART_ID AND  A.WORK_ORDER=:WO )AA,   '+
         ' SAJET.SYS_PART BB,SAJET.G_PICK_LIST CC ,SAJET.G_WO_BASE DD ,(    '+
         ' select part_id ,count(*) qty from '+
         ' (select  part_id, machine_code  from  '+
         ' (select c.sub_part_id part_id,d.machine_code from smt.g_wo_msl a, smt.g_wo_msl_detail b,smt.g_wo_msl_sub c,sajet.sys_machine d,sajet.sys_pdline e '+
         ' where a.wo_sequence=b.wo_sequence and b.wo_sequence=c.wo_sequence and a.machine_id=d.machine_id and a.pdline_id =e.pdline_id '+
         ' and b.item_part_id =c.item_part_id and a.work_order=:wo and e.pdline_name=:pdline '+
         ' union           '+
         ' select b.item_part_id part_id,c.machine_code from smt.g_wo_msl a, smt.g_wo_msl_detail b, sajet.sys_machine c,sajet.sys_pdline d   '+
         ' where a.wo_sequence=b.wo_sequence   and a.machine_id=c.machine_id and d.pdline_name=:pdline and a.pdline_id =d.pdline_id  '+
         ' and a.work_order=:wo) group by part_id,machine_code ) group by part_id ) ee '+
         ' WHERE AA.WORK_ORDER=CC.WORK_ORDER AND AA.PART_ID=BB.PART_ID  AND BB.PART_ID=CC.PART_ID   '+
         ' AND CC.UPDATE_TIME >= to_date(:startTIme,''yyyymmddhh24'') AND  '+
         ' CC.update_time <=TO_DATE(:EndTime,''yyyymmddhh24'')'+
         ' AND CC.WORK_ORDER=DD.WORK_ORDER  and ee.part_id =cc.part_id  ';
   if cmbMachine.Text = 'Command Material' then
        QryData.CommandText :=  QryData.CommandText  + ' and ee.qty>=2 '
    else
        QryData.CommandText :=  QryData.CommandText  + ' and ee.qty =1';

    QryData.CommandText :=  QryData.CommandText  + ' ORDER BY BB.PART_NO,CC.material_No,CC.QTY DESC ';

    QryData.Params.ParamByName('StartTime').AsString := starttime;
    QryData.Params.ParamByName('EndTime').AsString := endtime;
    QryData.Params.ParamByName('WO').AsString := edtWo.Text;
    QryData.Params.ParamByName('pdline').AsString := cmbLine.Text;
    if cmbMachine.Text <> 'Command Material' then
       QryData.Params.ParamByName('Machine').AsString := cmbMachine.Text;
    QryData.Open;

    lblMsg.Caption := IntToStr(QryData.RecordCount)+'比數據';

end;
procedure TfMainForm.PrintExcel(Sender: TObject);
var sPartNO,sMaterial,sQty:string;
    i,j:Integer;
begin
   try
      Application.ProcessMessages;
      MsExcel.Cells[1,2].Value := cmbLine.Text;
      MsExcel.Cells[1,4].Value := sModel;
      MsExcel.Cells[1,6].Value := edtwo.text;
      MsExcel.Cells[1,8].Value := QryData.FieldByName('Target_QTY').AsString;
      MsExcel.Cells[1,10].Value := cmbMachine.Text;
      MsExcel.Cells[1,12].Value := QryData.FieldByName('iDate').AsString;
      QryData.First;
      j:= Ceil( QryData.RecordCount/24);
      for  i:=0 to QryData.RecordCount-1  do
      begin
            sPartNO := QryData.FieldByName('PART_NO').AsString ;
            sMaterial :=  QryData.FieldByName('Material_no').AsString;
            sQty :=  QryData.FieldByName('QTY').AsString;
            MsExcel.Cells[i+3,1].Value := (i mod 24) +1;
            MsExcel.Cells[i+3,3].Value := sPartNO;
            MsExcel.Cells[i+3,4].Value := sMaterial;
            MsExcel.Cells[i+3,6].Value := sQty;
            MsExcel.Cells[i+3,8].Value := QryData.fieldbyname('Spec2').AsString;
            MsExcel.Rows[i+3].RowHeight :=19.5;
            lblMsg.Caption := '正在處理第'+IntToStr(Ceil((i+1)/24))+'/'+IntTosTr(j)+'頁';
            QryData.Next;
      end;

      MsExcel.ActiveSheet.Range['A3:M'+IntToStr(I+2)].HorizontalAlignment :=3;
      MsExcel.ActiveSheet.Range['A3:M'+IntToStr(I+2)].VerticalAlignment :=2;
      MsExcel.ActiveSheet.Range['A3:M'+IntToStr(I+2)].Borders[1].Weight := 2;
      MsExcel.ActiveSheet.Range['A3:M'+IntToStr(I+2)].Borders[2].Weight := 2;
      MsExcel.ActiveSheet.Range['A3:M'+IntToStr(I+2)].Borders[3].Weight := 2;
      MsExcel.ActiveSheet.Range['A3:M'+IntToStr(I+2)].Borders[4].Weight := 2;
      {
      MsExcel.ActiveSheet.Range['A1:N'+IntToStr(I+2)].Borders[7].Weight := xlThick;
      MsExcel.ActiveSheet.Range['A1:N'+IntToStr(I+2)].Borders[8].Weight := xlThick;
      MsExcel.ActiveSheet.Range['A1:N'+IntToStr(I+2)].Borders[9].Weight := xlThick;
      MsExcel.ActiveSheet.Range['A1:N'+IntToStr(I+2)].Borders[10].Weight := xlThick; }



      if Sender = btnPreview then begin
          MsExcel.Visible :=True;
          MsExcel.ActiveSheet.PrintPreview ;

      end
      else if  Sender = btnPrint then
          MsExcel.Worksheets[1].PrintOut
      else
      if dlgSave1.Execute then begin
          if FileExists(dlgSave1.FileName) then
             DeleteFile(dlgSave1.FileName);
          MsExcel.ActiveSheet.SaveAs(dlgSave1.FileName);
      end ;

      MessageDlg('succeed',mtinformation,[mbok],0);
   finally
        //Release_Excel;
   end;
end;

procedure TfMainForm.btnPrintClick(Sender: TObject);
begin

    if not QryData.Active then  Exit ;
    if QryData.IsEmpty then  Exit ;
    if not init_Excel then exit;
    PrintExcel(Sender);
    Release_Excel;

end;

procedure TfMainForm.GetVersion(S: string);
  function HexToInt(HexNum: string): LongInt;
  begin
    Result := StrToInt('$' + HexNum);
  end;
var VersinInfo: Pchar; //版本資訊
  VersinInfoSize: DWord; //版本資訊size (win32 使用)
  pv_info: PVSFixedFileInfo; //版本格式
  Mversion, Sversion: string; //版本No
begin
  VersinInfoSize := GetFileVersionInfoSize(pchar(S), VersinInfoSize);
  VersinInfo := AllocMem(VersinInfoSize);
  try
    GetFileVersionInfo(pchar(S), 0, VersinInfoSize, Pointer(VersinInfo));
    VerQueryValue(pointer(VersinInfo), '\', pointer(pv_info), VersinInfoSize);
    Mversion := inttohex(pv_info.dwProductVersionMS, 0);
    Mversion := copy('00000000', 1, 8 - length(Mversion)) + Mversion;
    Sversion := inttohex(pv_info.dwProductVersionLS, 0);
    Sversion := copy('00000000', 1, 8 - length(Sversion)) + Sversion;
    lblVersion.Caption := 'Version: ' +
      FloatToStr(hextoint(copy(MVersion, 1, 4))) + '.' +
      FloatToStr(hextoint(copy(MVersion, 5, 4))) + '.' +
      FloatToStr(hextoint(copy(SVersion, 1, 4))) + '.' +
      FloatToStr(hextoint(copy(SVersion, 5, 4)));
  finally
    FreeMem(VersinInfo, VersinInfoSize);
  end;
end;


procedure TfMainForm.edtWoChange(Sender: TObject);
begin
   //
   with QryTemp do begin

       Close;
       Params.Clear;
       Params.CreateParam(ftString,'wo',ptInput);
       CommandText :='select min(update_time-1/24) min_time , max(update_time+1/24) max_time from sajet.g_pick_list where work_order=:wo';
       Params.ParamByName('wo').AsString :=edtWo.Text;
       Open;
       if   IsEmpty then  Exit;

       dtpStart.Date := fieldbyName('min_time').AsDateTime;
       cmbStart.Text :=  FormatDateTime('HH',(fieldbyName('min_time').AsDateTime));
       dtpEnd.Date := fieldbyName('max_time').AsDateTime;
       cmbEnd.Text :=  FormatDateTime('HH',(fieldbyName('max_time').AsDateTime));
        
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'wo',ptInput);
       CommandText :=' select c.model_name from sajet.g_wo_base a,sajet.sys_part b,sajet.sys_model c '+
                     ' where a.Model_id=b.part_id and b.model_id=c.model_id and a.work_order=:wo';
       Params.ParamByName('wo').AsString :=edtWo.Text;
       Open;
       if not IsEmpty then
          sModel:= fieldbyName('model_name').AsString;

       Close;
       Params.Clear;
       Params.CreateParam(ftString,'wo',ptInput);
       CommandText :=' select distinct a.pdline_name from sajet.sys_pdline a,smt.g_wo_msl b '+
                     ' where a.pdline_id=b.pdline_id and b.work_order=:Wo  order by a.pdline_Name';
       Params.ParamByName('wo').AsString :=edtWo.Text;
       Open;
       
       if   IsEmpty then  Exit;

       cmbLine.Items.Clear;
       First;
       while not Eof do begin
          cmbLine.Items.Add(fieldbyname('Pdline_Name').AsString);
          Next;
       end;


   end;


end;

procedure TfMainForm.btnPreviewClick(Sender: TObject);
begin
    if not QryData.Active then  Exit ;
    if QryData.IsEmpty then  Exit ;
    if not init_Excel then exit;
    PrintExcel(Sender);
    Release_Excel;

end;

function TfMainForm.init_Excel():Boolean;
var mPath:String;
begin
  Result := True;
  mPath := ExtractFilePath(ParamStr(0))+'\';
  try
    MsExcel := CreateOleObject('Excel.Application');
    MsExcelWorkBook := MsExcel.WorkBooks.Open(mPath+'SMT Issue List.xlt');
    MsExcel.Visible :=false;
    MsExcel.displayAlerts:=false;
    MsExcel.Worksheets[1].Activate;
  except
    MessageDlg('Could not start Microsoft Excel.',mtWarning,[mbOK],0);
    //MsExcelWorkBook.close(False);
    MsExcelWorkBook := Unassigned;
    MsExcel.Application.Quit;
    MsExcel:=Null;
    Result := False;
  end;
end;

procedure TfMainForm.Release_Excel;
begin
   try
      MsExcelWorkBook := Unassigned;
      MsExcel.Application.Quit;
      MsExcel:=Null;
   except

   end;
end;


procedure TfMainForm.btnExportClick(Sender: TObject);
begin
    if not QryData.Active then  Exit ;
    if QryData.IsEmpty then  Exit ;
    if not init_Excel then exit;
    PrintExcel(Sender);
    Release_Excel;
end;

procedure TfMainForm.cmbLineSelect(Sender: TObject);
begin
    with QryTemp do
    begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'wo',ptInput);
       Params.CreateParam(ftString,'Pdline',ptInput);
       CommandText :=' select distinct a.machine_code from sajet.sys_machine a,smt.g_wo_msl b,sajet.sys_pdline c '+
                     ' where a.machine_id=b.machine_id and b.work_order=:Wo and a.Machine_LOC = c.pdline_name and c.pdline_Name =:pdline ';
       Params.ParamByName('wo').AsString :=edtWo.Text;
       Params.ParamByName('pdline').AsString :=cmbLine.Text;
       Open;
       if   IsEmpty then  Exit;

       cmbMachine.Items.Clear;
       cmbMachine.Items.Add('Command Material');
       First;
       while not Eof do begin
          cmbMachine.Items.Add(fieldbyname('machine_code').AsString);
          Next;
       end;
    end;
end;

end.
