unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db,
  DBClient, MConnect, ObjBrkr, SConnect,GradPanel, Variants, comobj, Menus,
  Series, TeEngine, StatChar, TeeProcs, Chart;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    SpeedButton5: TSpeedButton;
    Image2: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    QryTemp2: TClientDataSet;
    PageControl1: TPageControl;
    TabData: TTabSheet;
    GradPanel14: TGradPanel;
    Image7: TImage;
    sbtnSave: TSpeedButton;
    Image8: TImage;
    sbtnPrint: TSpeedButton;
    ImageTitle: TImage;
    Label3: TLabel;
    Label4: TLabel;
    SaveDialog1: TSaveDialog;
    strgridData: TStringGrid;
    Image3: TImage;
    sbtnQuery: TSpeedButton;
    ListModel: TListBox;
    LabModel: TLabel;
    LblProcess: TLabel;
    ListProcess: TListBox;
    DateTimePickerstart: TDateTimePicker;
    DateTimePickerend: TDateTimePicker;
    Label5: TLabel;
    Label7: TLabel;
    Lblrecordcount: TLabel;
    combStartHour: TComboBox;
    CombstartMinute: TComboBox;
    Combendhour: TComboBox;
    Combendminute: TComboBox;
    cmbFactory: TComboBox;
    Chart1: TChart;
    BarSeries1: THistogramSeries;
    LineSeries1: TFastLineSeries;
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnQueryClick(Sender: TObject);
    procedure LabModelClick(Sender: TObject);
    procedure LblProcessClick(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    function AddCondition(sField: string; sList: TListBox): string;  
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
    procedure ShowLineSeries;
    procedure ShowAllData(sTitle,sFieldName,sFieldID:string;ListField:TListBox);
  end;

var
  fDetail: TfDetail;
  icol,irow:integer;
  FcID :string;
implementation

uses uCommData, uSelect;
{$R *.DFM}

procedure TfDetail.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var i, j,iStartRow,iDiv,iMod: integer;
    vRange1:Variant;
begin
   istartrow:=2 ;
   for i := 0 to strgridData.RowCount  do
      BEGIN
          for j := 0 to strgridData.ColCount  do
            MsExcel.Worksheets['Sheet1'].Cells[i+iStartRow,j+1].value := strgridData.Cells[j,i];
      END ;
end;



function TfDetail.AddCondition(sField: string; sList: TListBox): string;
var i: Integer;
begin
  Result := '';
  if sList.Count <> 0 then
  begin
    Result := ' AND ( ';
    for i := 0 to sList.Items.Count - 1 do
    begin
      if i = 0 then
        Result := Result + sField + '= ''' + sList.Items.Strings[i] + ''' '
      else
        Result := Result + 'OR ' + sField + '= ''' + sList.Items.Strings[i] + ''' ';
    end;
    Result := Result + ') ';
  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var sYear:string;
    i:integer;
begin  //GetReportName;
  with strgridData do
  begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=10;
           ColCount  :=9;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=80;
           cells[0,0]:='機種名稱';
           colwidths[1]:=70;
           cells[1,0]:='維修日期';
           colwidths[2]:=70;
           CELLS[2,0]:='測試站別';
           colwidths[3]:=30;
           CELLS[3,0]:='數量';
           colwidths[4]:=110;
           CELLS[4,0]:='不良描述';
           colwidths[5]:=50;
           CELLS[5,0]:='不良位置';
           colwidths[6]:=170;
           CELLS[6,0]:='責任歸屬';
           colwidths[7]:=110;
           CELLS[7,0]:='原因分析';
           colwidths[8]:=70;
           CELLS[8,0]:='維修人員';
  end;
    lblrecordcount.Caption :='';
    DateTimePickerstart.Date:=now;
    DateTimePickerend.Date :=now+1 ;

  cmbFactory.Items.Clear;
  with QryTemp do
  begin
    Close;
    CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
      'From SAJET.SYS_FACTORY ' +
      'Where ENABLED = ''Y'' ';
    Open;
    while not Eof do
    begin
      cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString);
      Next;
      cmbfactory.ItemIndex:=0;
    end;
    cmbFactoryChange(Self);

    Close;
  end;
end;

procedure TfDetail.sbtnSaveClick(Sender: TObject);
var
  sFileName, My_FileName: string;
  MsExcel, MsExcelWorkBook: Variant;
  i: Integer;
begin
  if (not QryData.Active) or (QryData.IsEmpty) then Exit;
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'xls';
  SaveDialog1.Filter := 'All Files(*.xls)|*.xls';

  My_FileName := ExtractFilePath(Application.ExeName)+'RepairResultReport.xlt';

  if not FileExists(My_FileName) then
  begin
    showmessage('Error!-The Excel File ' + My_FileName + ' can''t be found.');
    exit;
  end;

  if Sender = sbtnSave then
  begin
    if SaveDialog1.Execute then
      sFileName := SaveDialog1.FileName
    else
      exit;  
  end;

  try
    MsExcel := CreateOleObject('Excel.Application');
    MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);

    MsExcel.Worksheets['Sheet1'].select;
    SaveExcel(MsExcel, MsExcelWorkBook);
    if Sender = sbtnSave then
    begin
      MsExcelWorkBook.SaveAs(sFileName);
      showmessage('Save Excel OK!!');
    end;
    if Sender = sbtnPrint then
    begin
      WindowState := wsMinimized;
      MsExcel.Visible := TRUE;
      MsExcel.WorkSheets['Sheet1'].PrintPreview;
      WindowState := wsMaximized;
    end;
  except
    ShowMessage('Could not start Microsoft Excel.');
  end;
  MsExcelWorkBook.close(False);
  MsExcel.Application.Quit;
  MsExcel := Null;

end;

procedure TfDetail.FormClose(Sender: TObject; var Action: TCloseAction);
begin  
  Action := caFree;
end;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
var sStartDate,sEndDate: string;
    sstarttime,sendtime:string;
    i:integer;
begin
   if listmodel.Count=0 then
     begin
         for i:= 1 to strgridData.ROWCount do
              strgridData.ROWs[i].Clear;
         lblrecordcount.Caption :='Total:0' ;
         showmessage('please select one or more model!');
         exit;
     end;
   sStartDate:='';
   sEndDate:=''  ;
   sStartDate:=FormatDateTime('YYYYMMDD',datetimepickerstart.Date);
   sEndDate:=FormatDateTime('YYYYMMDD',datetimepickerEND.Date);

   sstarttime:=trim(sstartdate)+trim(combstarthour.Text)+trim(combstartminute.Text);
   sendtime:=trim(senddate)+trim(combendhour.Text)+trim(combendminute.Text);

  for i:= 1 to strgridData.ROWCount do
    strgridData.ROWs[i].Clear;

  with QryData do
  begin
    Close;
    Commandtext:='  SELECT MODEL_NAME, REPAIR_TIME,TEST_PROCESS,COUNT(*) QTY ,DEFECT,LOCATION,DUTY,REASON,REPAIR_NAME FROM  '
                +' (select E.MODEL_NAME ,F.REASON_CODE||''-''||F.REASON_DESC REASON  '
                +' ,to_char(A.repair_time,''YYYY/MM/DD'') REPAIR_TIME,G.EMP_NAME REPAIR_NAME ,H.DUTY_CODE||''-''||H.DUTY_DESC DUTY,B.LOCATION ,  '
                +' J.PROCESS_NAME TEST_PROCESS,K.DEFECT_CODE||''-''||K.DEFECT_DESC  DEFECT   '
                +' from sajet.g_sn_repair A,sajet.g_sn_repair_location B,sajet.g_sn_defect C, sajet.sys_part D,SAJET.SYS_MODEL E,   '
                +' SAJET.SYS_REASON F,SAJET.SYS_EMP G,SAJET.SYS_DUTY H, SAJET.SYS_PROCESS J,SAJET.SYS_DEFECT K ,SAJET.G_WO_BASE L     '
                +' where A.RECID=C.RECID   '
                +' AND A.RECID=B.RECID(+)  '
                +' AND A.MODEL_ID=D.PART_ID AND D.MODEL_ID=E.MODEL_ID   '
                +' AND A.REASON_ID=F.REASON_ID AND A.REPAIR_EMP_ID=G.EMP_ID   '
                +' AND A.DUTY_ID=H.DUTY_ID AND C.PROCESS_ID=J.PROCESS_ID   '
                +' AND C.DEFECT_ID=K.DEFECT_ID   '
                +' AND to_char(A.repair_time,''YYYYMMDDHH24MI'') BETWEEN :starttime AND :endtime  '
                +' AND A.WORK_ORDER=L.WORK_ORDER '
                +' AND L.FACTORY_ID='''+FCID+''' '
               // +' AND A.REMARK IS NULL ' 略除retry  資料    此語句改成(by key 2009/01/08
                +' AND NVL(A.REMARK,''N/A'')<>''RETRY''   '
                + AddCondition( 'E.MODEL_NAME',ListModel)
                + AddCondition('J.PROCESS_NAME',ListProcess)
                +' )   '
                +' GROUP BY MODEL_NAME, REPAIR_TIME,TEST_PROCESS,DEFECT,LOCATION,DUTY,REASON,REPAIR_NAME ';
    params.ParamByName('starttime').AsString :=sstarttime;
    params.ParamByName('endtime').AsString :=sendtime;

    Open;
    if IsEmpty then
    begin
      lblrecordcount.Caption :='TOTAL:0';
      Showmessage('No Data');
      exit;
    end;

   strgridData.RowCount:=10;
   irow:=0;
   icol:=0;

   while not eof do
    begin
        IROW:=IROW+1;
        strgridData.Cells[0,irow]:=fieldbyname('MODEL_NAME').asstring ;
        Strgriddata.Cells[1,irow]:=fieldbyname('REPAIR_TIME').AsString   ;
        Strgriddata.Cells[2,irow]:=fieldbyname('TEST_PROCESS').AsString   ;
        Strgriddata.Cells[3,irow]:=fieldbyname('qty').AsString ;
        Strgriddata.Cells[4,irow]:=fieldbyname('DEFECT').AsString;
        Strgriddata.Cells[5,irow]:= fieldbyname('LOCATION').AsString ;
        Strgriddata.Cells[6,irow]:= fieldbyname('duty').AsString ;
        Strgriddata.Cells[7,irow]:= fieldbyname('REASON').AsString ;
        Strgriddata.Cells[8,irow]:= fieldbyname('repair_name').AsString;
        next;
        Strgriddata.RowCount:=IROW+1;
        lblrecordcount.Caption :='TOTAL:'+ inttostr(irow);
    END;
    ShowLineSeries ;
  end;
end;

procedure TFdetail.ShowLineSeries;
var sStartDate,sEndDate: string;
    sstarttime,sendtime:string;
    strsql:string;
begin
   BarSeries1.Clear ;
   sStartDate:='';
   sEndDate:=''  ;
   sStartDate:=FormatDateTime('YYYYMMDD',datetimepickerstart.Date);
   sEndDate:=FormatDateTime('YYYYMMDD',datetimepickerEND.Date);

   sstarttime:=trim(sstartdate)+trim(combstarthour.Text)+trim(combstartminute.Text);
   sendtime:=trim(senddate)+trim(combendhour.Text)+trim(combendminute.Text);

  with QryData do
  begin
    Close;
    Commandtext:='SELECT DISTINCT count( REASON_CODE ) AS REASON_QTY,REASON_CODE FROM (  '
                +'  SELECT MODEL_NAME, REPAIR_TIME,TEST_PROCESS,COUNT(*) QTY ,DEFECT,LOCATION,DUTY,REASON,REPAIR_NAME,REASON_CODE FROM  '
                +' (select E.MODEL_NAME ,F.REASON_CODE||''-''||F.REASON_DESC REASON  '
                +' ,to_char(A.repair_time,''YYYY/MM/DD'') REPAIR_TIME,G.EMP_NAME REPAIR_NAME ,H.DUTY_CODE||''-''||H.DUTY_DESC DUTY,B.LOCATION ,  '
                +' J.PROCESS_NAME TEST_PROCESS,K.DEFECT_CODE||''-''||K.DEFECT_DESC  DEFECT  , F.REASON_CODE    '
                +' from sajet.g_sn_repair A,sajet.g_sn_repair_location B,sajet.g_sn_defect C, sajet.sys_part D,SAJET.SYS_MODEL E,   '
                +' SAJET.SYS_REASON F,SAJET.SYS_EMP G,SAJET.SYS_DUTY H, SAJET.SYS_PROCESS J,SAJET.SYS_DEFECT K ,SAJET.G_WO_BASE L     '
                +' where A.RECID=C.RECID   '
                +' AND A.RECID=B.RECID(+)  '
                +' AND A.MODEL_ID=D.PART_ID AND D.MODEL_ID=E.MODEL_ID   '
                +' AND A.REASON_ID=F.REASON_ID AND A.REPAIR_EMP_ID=G.EMP_ID   '
                +' AND A.DUTY_ID=H.DUTY_ID AND C.PROCESS_ID=J.PROCESS_ID   '
                +' AND C.DEFECT_ID=K.DEFECT_ID   '
                +' AND to_char(A.repair_time,''YYYYMMDDHH24MI'') BETWEEN :starttime AND :endtime  '
                +' AND A.WORK_ORDER=L.WORK_ORDER '
                +' AND L.FACTORY_ID='''+FCID+''' '
               // +' AND A.REMARK IS NULL ' 略除retry  資料    此語句改成(by key 2009/01/08
                +' AND NVL(A.REMARK,''N/A'')<>''RETRY''   '
                + AddCondition( 'E.MODEL_NAME',ListModel)
                + AddCondition('J.PROCESS_NAME',ListProcess)
                +' )   '
                +' GROUP BY MODEL_NAME, REPAIR_TIME,TEST_PROCESS,DEFECT,LOCATION,DUTY,REASON,REPAIR_NAME,REASON_CODE ) '
                +'   GROUP BY REASON_CODE ORDER BY REASON_QTY DESC ';
    params.ParamByName('starttime').AsString :=sstarttime;
    params.ParamByName('endtime').AsString :=sendtime;

    Open;
    if IsEmpty then
    begin
      Close ;
      Showmessage('No Data');
      exit;
    end;

    while not eof do
    begin
      BarSeries1.Add(FieldByName('REASON_QTY').AsInteger,FieldByName('REASON_CODE').AsString);
      next;
    END;
    Close ;
  end;
end;

procedure TfDetail.ShowAllData(sTitle,sFieldName,sFieldID:string;ListField:TListBox);
Var I,iIndex : Integer;
   tsFieldName,tsFieldID:TStringList;
begin
  //fSelect:=TfSelect.create(Self);
  with TfSelect.create(Self) do
  begin
    try
      listbAvail.Clear;
      listbSel.Clear;
      tsFieldName := TStringList.Create;
      tsFieldID := TStringList.Create;

      lablTitle.Caption := sTitle+' List ';
      if ListField.Items.Count <> 0 then begin
        for I := 0 to ListField.Items.Count - 1 do
        begin
           if listbSel.Items.IndexOf(ListField.Items[i])<0 Then
             listbSel.Items.AddObject(ListField.Items[I],
           ListField.Items.Objects[I]);
        end;
      end;

      While not fDetail.qryTemp.Eof do
      begin
        if  listbSel.Items.Indexof(fDetail.qryTemp.Fields[0].AsString)=-1 then
          listbAvail.Items.Add(fDetail.qryTemp.Fields[0].AsString);
        tsFieldName.Add(fDetail.qryTemp.Fields[0].AsString);
        fDetail.qryTemp.Next;
      end;
      if ShowModal = mrOK then
      begin
        ListField.Clear;
        if listbSel.Items.Count <> 0 then
        begin
          for I := 0 to listbSel.Items.Count - 1 do
          begin
            if ListField.Items.IndexOf(listbSel.Items[i])<0 Then
            begin
                ListField.Items.AddObject(listbSel.Items[I],listbSel.Items.Objects[I]);
                iIndex := tsFieldName.Indexof(listbSel.Items[I]);
            end;
          end;
        end;
      end;
    finally
      fDetail.qryTemp.Close;
      tsFieldName.free;
      tsFieldID.free;
      free;
    end;
  end;
end;

procedure TfDetail.LabModelClick(Sender: TObject);
begin
  with fDetail.qryTemp do
  begin
    close;
    Params.Clear;
    CommandText := 'Select model_name from sajet.sys_model order by Model_Name';
    Open;
  end;

  ShowAllData('Model','','',ListModel);
end;

procedure TfDetail.LblProcessClick(Sender: TObject);
begin
  with fDetail.qryTemp do
  begin
    close;
    Params.Clear;
    CommandText := 'select process_name from sajet.sys_process where enabled=''Y'' ORDER BY PROCESS_NAME ';
    Open;
  end;

  ShowAllData('Process','','',ListProcess);
end;

procedure TfDetail.cmbFactoryChange(Sender: TObject);
begin
  FcID := '';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'FACTORYCODE', ptInput);
    CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
      'From SAJET.SYS_FACTORY ' +
      'Where FACTORY_CODE = :FACTORYCODE ';
    Params.ParamByName('FACTORYCODE').AsString := Copy(cmbFactory.Text, 1, POS(' ', cmbFactory.Text) - 1);
    Open;
    if RecordCount > 0 then
      FcID := Fieldbyname('FACTORY_ID').AsString;
    Close;
  end;
end;

end.

