unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Spin, Db,
  DBClient, MConnect, ObjBrkr, IniFiles, SConnect, Series, TeEngine,
  TeeProcs, Chart, GradPanel, Menus, Variants, comobj, ImgList, DBGrid1;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageTitle: TImage;
    Label4: TLabel;
    Label3: TLabel;
    Image9: TImage;
    Label8: TLabel;
    Label6: TLabel;
    Label9: TLabel;
    Label7: TLabel;
    sbtnWo: TSpeedButton;
    Label10: TLabel;
    sbtnPart: TSpeedButton;
    Image3: TImage;
    sbtnQuery: TSpeedButton;
    sbtnStyle1: TSpeedButton;
    sbtnStyle2: TSpeedButton;
    PageControl1: TPageControl;
    TabData: TTabSheet;
    GradPanel14: TGradPanel;
    Image7: TImage;
    sbtnSave: TSpeedButton;
    Image8: TImage;
    sbtnPrint: TSpeedButton;
    LabReportName1: TLabel;
    GradPanel13: TGradPanel;
    Label18: TLabel;
    Label19: TLabel;
    GPRecords: TGradPanel;
    GPRate: TGradPanel;
    TabGlyph: TTabSheet;
    Chart1: TChart;
    Series1: TBarSeries;
    Series2: TLineSeries;
    GradPanel11: TGradPanel;
    Label2: TLabel;
    Label1: TLabel;
    Label5: TLabel;
    Label17: TLabel;
    cmbMain: TComboBox;
    cmbSecond: TComboBox;
    cmbChart: TComboBox;
    cmbChtStyle: TComboBox;
    StrGrid: TStringGrid;
    cmbFactory: TComboBox;
    combLine: TComboBox;
    DTStart: TDateTimePicker;
    cmbWSStart: TComboBox;
    editWO: TEdit;
    DTEnd: TDateTimePicker;
    cmbWSEnd: TComboBox;
    editPart: TEdit;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    QryTemp2: TClientDataSet;
    DataSource1: TDataSource;
    PopupMenu1: TPopupMenu;
    SaveImage1: TMenuItem;
    Copy1: TMenuItem;
    PopupMenu2: TPopupMenu;
    CurrentRecordDetailData1: TMenuItem;
    SaveDialog1: TSaveDialog;
    LabReportName: TLabel;
    ImgLst: TImageList;
    DBGrid1: TDBGrid1;
    Image1: TImage;
    SpeedButton1: TSpeedButton;
    Label11: TLabel;
    edtLower: TEdit;
    Label13: TLabel;
    edtUpper: TEdit;
    lablModel: TLabel;
    editModel: TEdit;
    sbtnModel: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure sbtnStyle1Click(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cmbMainChange(Sender: TObject);
    procedure cmbChartChange(Sender: TObject);
    procedure cmbChtStyleChange(Sender: TObject);
    procedure Chart1ClickSeries(Sender: TCustomChart; Series: TChartSeries;
      ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure sbtnQueryClick(Sender: TObject);
    procedure SaveImage1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure CurrentRecordDetailData1Click(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure sbtnStyle2Click(Sender: TObject);
    procedure sbtnPrintClick(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
    procedure sbtnWoClick(Sender: TObject);
    procedure sbtnPartClick(Sender: TObject);
    procedure cmbSecondChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure sbtnModelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    RpID, gsPath, UpdateUserID, gsSpec: string;
    gbBox: Boolean; giTimeBase: Integer;
    SocketConnection1: TSocketConnection;
    procedure GetReportParams;
    function DownloadSampleFile: string;
    function AddCondition(sField: string; sList: TStringList): string;
    function SelectField(Str, StrFunction: string): string;
    procedure GetReportName;
    procedure GetPdLineData;
    procedure GetProcessData;
    procedure GetSpecField;
    procedure GetPartData;
    function SelectDate: string;
    function SelectWorkDate: string;
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
    procedure GetFactoryData;
    procedure RefreshData(bRefreshYR: Boolean);
  end;

var
  fDetail: TfDetail;
  FcID: string;
  ChkDate, ChkLine, ChkProcess, ChkWO, ChkPart, ChkModel: Boolean;
  DateStyle: string;
  ChartMain, ChartSecond: string;
  slFactoryID, StrLstPdLine, StrLstProcess, StrLstPart, StrLstSort, StrLstProcessName: TStringList;
  sQueryCon: string;

implementation

{$R *.DFM}
uses uData,uDataDetail, uCommData, uProcess;

procedure TfDetail.GetFactoryData;
var UserFcID: string;
begin
  slFactoryID := TStringList.Create;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EMP_ID', ptInput);
    CommandText := 'Select NVL(FACTORY_ID,0) FACTORY_ID ' +
      'From SAJET.SYS_EMP ' +
      'Where EMP_ID = :EMP_ID '
      + 'and Rownum = 1 ';
    Params.ParamByName('EMP_ID').AsString := UpdateUserID;
    Open;
    if RecordCount = 0 then
    begin
      Close;
      MessageDlg('Account Error !!', mtError, [mbOK], 0);
      Exit;
    end;
    UserFcID := Fieldbyname('FACTORY_ID').AsString;
    Close;
  end;
  cmbFactory.Items.Clear;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
      'From SAJET.SYS_FACTORY ' +
      'Where ENABLED = ''Y'' ';
    Open;
    while not Eof do
    begin
      cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString);
      slFactoryID.Add(Fieldbyname('FACTORY_ID').AsString);
      if Fieldbyname('FACTORY_ID').AsString = UserFcID then
        cmbFactory.ItemIndex := cmbFactory.Items.Count - 1;
      Next;
    end;
    Close;
  end;
  cmbFactory.Enabled := (UserFcID = '0');
  if UserFcID = '0' then
    cmbFactory.ItemIndex := 0;
  cmbFactoryChange(self);
end;

procedure TfDetail.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var i, j: integer;
begin
  MsExcel.Worksheets['Report'].select;
  MsExcel.Worksheets['Report'].Range['A5'].Value := sQueryCon;

  MsExcel.Worksheets['Data'].select;
  for i := 0 to DBGrid1.Columns.Count - 1 do
    MsExcel.Worksheets['Data'].Range[Chr(i + 65) + '1'].Value := DBGrid1.Columns[i].Title.Caption;

  QryData.First;
  for i := 0 to QryData.RecordCount - 1 do
  begin
    for j := 0 to QryData.FieldCount - 1 do
      MsExcel.Worksheets['Data'].Range[Chr(j + 65) + IntToStr(i + 2)].Value := QryData.Fields.Fields[J].AsString;
    QryData.Next;
  end;
  MsExcel.Run('YIELD');
end;

procedure TfDetail.GetReportName;
begin
  LabReportName.Caption := '';
  LabReportName1.Caption := '';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RP_ID', ptInput);
    CommandText := 'Select RP_NAME ' +
      'From SAJET.SYS_REPORT_NAME ' +
      'Where RP_ID = :RP_ID ';
    Params.ParamByName('RP_ID').AsString := RpID;
    Open;
    if RecordCount > 0 then
    begin
      LabReportName.Caption := Fieldbyname('RP_NAME').AsString;
      LabReportName1.Caption := Fieldbyname('RP_NAME').AsString;
    end;
    Close;
  end;
end;

procedure TfDetail.GetReportParams;
begin
  chkDate := False;
  ChkLine := False;
  ChkProcess := False;
  ChkWO := False;
  ChkPart := False;
  ChkModel := False;
  StrLstPdLine.Clear;
  StrLstProcess.Clear;
  StrLstProcessName.Clear;
  StrLstPart.Clear;
  StrLstSort.Clear;
  cmbMain.Items.Clear;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RP_ID', ptInput);
    CommandText := 'Select PARAM_TYPE,PARAM_NAME,PARAM_VALUE ' +
      'From SAJET.SYS_REPORT_PARAM ' +
      'Where RP_ID = :RP_ID ' +
      'Order By PARAM_TYPE,PARAM_VALUE ';
    Params.ParamByName('RP_ID').AsString := RpID;
    Open;
    while not eof do
    begin
      if Fieldbyname('PARAM_TYPE').AsString = 'Query Condition' then
      begin
        if Fieldbyname('PARAM_NAME').AsString = 'FACTORY_ID' then
          FcID := Fieldbyname('PARAM_VALUE').AsString;
      end;
      if Fieldbyname('PARAM_TYPE').AsString = 'Date Style' then
        DateStyle := Fieldbyname('PARAM_VALUE').AsString;
      if Fieldbyname('PARAM_TYPE').AsString = 'Display Information' then
      begin
        if Fieldbyname('PARAM_NAME').AsString = 'Date' then
          ChkDate := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Production Line' then
          ChkLine := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Process Name' then
          ChkProcess := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Work Order' then
          ChkWO := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Part No' then
          ChkPart := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Model Name' then
          ChkModel := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_VALUE').AsString = 'Y' then
          cmbMain.Items.Add(Fieldbyname('PARAM_NAME').AsString);
      end;
      if Fieldbyname('PARAM_TYPE').AsString = 'Chart Set' then
      begin
        if Fieldbyname('PARAM_NAME').AsString = 'Main' then
          ChartMain := Fieldbyname('PARAM_VALUE').AsString;
        if Fieldbyname('PARAM_NAME').AsString = 'Second' then
          ChartSecond := Fieldbyname('PARAM_VALUE').AsString;
      end;
      if Fieldbyname('PARAM_TYPE').AsString = 'Sort Condition' then
        StrLstSort.Add(Fieldbyname('PARAM_NAME').AsString);
      Next;
    end;
    Close;
    cmbSecond.Items.Clear;
    cmbSecond.Items := cmbMain.Items;
    cmbSecond.Items.Delete(cmbSecond.Items.IndexOf(ChartMain));
    cmbSecond.Items.Insert(0, 'N/A');
//    GetPdLineData;
    GetProcessData;
//    GetPartData;
  end;
end;

function TfDetail.SelectDate: string;
begin
  Result := ' (OUT_PROCESS_TIME between to_date(''' + FormatDateTime('yyyymmdd', DTStart.Date) + cmbWSStart.Text + ''',''yyyymmddhh24'') ';
  if cmbWSEnd.ItemIndex = cmbWSEnd.Items.Count - 1 then
    Result := Result + ' and to_date(''' + FormatDateTime('yyyymmdd', DTEnd.Date + 1) + ''',''yyyymmdd'')) '
  else
    Result := Result + ' and to_date(''' + FormatDateTime('yyyymmdd', DTEnd.Date) + cmbWSEnd.Text + ''',''yyyymmddhh24'')) ';
end;

function TfDetail.SelectWorkDate: string;
var sStartDate, sEndDate: string;
begin
  sStartDate := FormatDateTime('YYYYMMDD', DTStart.Date);
  sEndDate := FormatDateTime('YYYYMMDD', DTEnd.Date);

  if sStartDate = sEndDate then
  begin
    Result := ' and ((WORK_DATE = ''' + sStartDate + ''' and WORK_TIME >= ''' + cmbWSStart.Text + ''') '
      + '  and (WORK_DATE = ''' + sStartDate + ''' and WORK_TIME <= ''' + IntToStr(StrToInt(cmbWSEnd.Text) * giTimeBase - 1) + ''')) ';
  end
  else
  begin
    Result := ' and ((WORK_DATE = ''' + sStartDate + ''' and WORK_TIME >= ''' + cmbWSStart.Text + ''') '
      + '   or (WORK_DATE > ''' + sStartDate + ''' and WORK_DATE < ''' + sEndDate + ''') '
      + '   or (WORK_DATE = ''' + sEndDate + ''' and WORK_TIME < ''' + IntToStr(StrToInt(cmbWSEnd.Text) * giTimeBase) + ''')) ';
  end;
end;

procedure TfDetail.GetPdLineData;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RPID', ptInput);
    CommandText := 'Select A.PDLINE_ID,A.PDLINE_NAME ' +
      'From SAJET.SYS_PDLINE A, ' +
      'SAJET.SYS_REPORT_PARAM B ' +
      'Where B.RP_ID = :RPID and ' +
      'B.PARAM_TYPE = ''Query Condition'' and ' +
      'B.PARAM_NAME = ''PDLINE_ID'' and ' +
      'B.PARAM_VALUE = A.PDLINE_ID ' +
      'Order By A.PDLINE_NAME ';
    Params.ParamByName('RPID').AsString := RpID;
    Open;
    StrLstPdLine.Clear;
    while not eof do
    begin
      StrLstPDLine.Add(Fieldbyname('PDLINE_ID').AsString);
      Next;
    end;
    Close;
  end;
end;

procedure TfDetail.GetProcessData;
begin
  if FileExists(gsPath + fDetail.RpID + 'ID.Txt') then
  begin
    StrLstProcess.LoadFromFile(gsPath + fDetail.RpID + 'ID.Txt');
    StrLstProcessName.LoadFromFile(gsPath + fDetail.RpID + 'Name.Txt');
  end;
end;

procedure TfDetail.GetPartData;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RPID', ptInput);
    CommandText := 'Select A.PART_ID,A.PART_NO ' +
      'From SAJET.SYS_PART A, ' +
      'SAJET.SYS_REPORT_PARAM B ' +
      'Where B.RP_ID = :RPID and ' +
      'B.PARAM_TYPE = ''Query Condition'' and ' +
      'B.PARAM_NAME = ''PART_ID'' and ' +
      'B.PARAM_VALUE = A.PART_ID ' +
      'Order By A.PART_NO ';
    Params.ParamByName('RPID').AsString := RpID;
    Open;
    StrLstPart.Clear;
    while not eof do
    begin
      StrLstPart.Add(Fieldbyname('PART_ID').AsString);
      Next;
    end;
    Close;
  end;
end;

function TfDetail.AddCondition(sField: string; sList: TStringList): string;
var i: Integer;
begin
  Result := '';
  if sList.Count <> 0 then
  begin
    Result := ' AND ( ';
    for i := 0 to sList.Count - 1 do
    begin
      if i = 0 then
        Result := Result + sField + '= ''' + sList.Strings[i] + ''' '
      else
        Result := Result + 'OR ' + sField + '= ''' + sList.Strings[i] + ''' ';
    end;
    Result := Result + ') ';
  end;
end;

function TfDetail.DownloadSampleFile: string;
begin
  Result := '';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RP_ID', ptInput);
    CommandText := 'Select SAMPLE_NAME,SAMPLE_FILE ' +
      'From SAJET.SYS_REPORT_NAME ' +
      'Where RP_ID = :RP_ID ';
    Params.ParamByName('RP_ID').AsString := RpID;
    Open;
    if not Eof then
    begin
      TBlobField(Fieldbyname('SAMPLE_FILE')).SaveToFile('C:\' + Fieldbyname('SAMPLE_NAME').AsString);
      Result := 'C:\' + Fieldbyname('SAMPLE_NAME').AsString;
    end;
    Close;
  end;
end;

procedure TfDetail.GetSpecField;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select Param_Value ' +
      'From SAJET.SYS_BASE ' +
      'Where Param_Name = ''Part Spec'' ';
    Open;
    gsSpec := '';
    if not IsEmpty then
      gsSpec := FieldByName('Param_Value').AsString;
    Close;
  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
  DTStart.DateTime := now;
  DTEnd.DateTime := now;
  GetReportName;
  GetReportParams;
  GetFactoryData;
  GetSpecField;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select * from all_tab_columns '
      + 'where owner=''SAJET'' and table_name = ''G_SN_STATUS'' and column_name =''BOX_NO''';
    Open;
    gbBox := not IsEmpty;
    Close;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''TIME_SECTION'' and rownum = 1';
    Open;
    giTimeBase := 60 div FieldByName('param_value').AsInteger;
    Close;
  end;
  cmbChart.ItemIndex := 1;
  cmbChtStyle.ItemIndex := 0;
  cmbWSStart.ItemIndex := 0;
  cmbWSEnd.ItemIndex := cmbWSEnd.Items.Count - 1;
  cmbMain.ItemIndex := cmbMain.Items.IndexOf(ChartMain);
  cmbSecond.ItemIndex := cmbSecond.Items.IndexOf(ChartSecond);
  if cmbSecond.ItemIndex < 0 then
    cmbSecond.ItemIndex := 0;
  PageControl1.ActivePage := TabData;
end;

procedure TfDetail.sbtnStyle1Click(Sender: TObject);
begin
  PageControl1.ActivePage := TabData;
end;

procedure TfDetail.sbtnPrintClick(Sender: TObject);
var
  My_FileName: string;
  MsExcel, MsExcelWorkBook: Variant;
begin
  if not QryData.Active then Exit;
  if QryData.IsEmpty then Exit;

  My_FileName := DownLoadSampleFile;

  if not FileExists(My_FileName) then
  begin
    showmessage('Error!-The Excel File ' + My_FileName + ' can''t be found.');
    exit;
  end;

  try
    MsExcel := CreateOleObject('Excel.Application');
    MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);
    MsExcel.Worksheets['Data'].select;
    SaveExcel(MsExcel, MsExcelWorkBook);
    WindowState := wsMinimized;
    MsExcel.Visible := TRUE;
    MsExcel.Worksheets['Report'].select;
    MsExcel.WorkSheets['Report'].PrintPreview;
    WindowState := wsMaximized;
  except
    ShowMessage('Could not start Microsoft Excel.');
  end;
  MsExcelWorkBook.Close(False);
  MsExcel.Application.Quit;
  MsExcel := Null;

  try
    if FileExists(My_FileName) then Deletefile(My_FileName);
  except end;
end;

procedure TfDetail.sbtnSaveClick(Sender: TObject);
var
  sFileName, My_FileName: string;
  MsExcel, MsExcelWorkBook: Variant;
  i: Integer;
begin
  if not QryData.Active then Exit;
  if QryData.IsEmpty then Exit;
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'xls';
  SaveDialog1.Filter := 'All Files(*.xls)|*.xls';

  My_FileName := DownLoadSampleFile;

  if not FileExists(My_FileName) then
  begin
    showmessage('Error!-The Excel File ' + My_FileName + ' can''t be found.');
    exit;
  end;

  if SaveDialog1.Execute then
  begin
    try
      sFileName := SaveDialog1.FileName;
      MsExcel := CreateOleObject('Excel.Application');
      MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);

      with QryTemp do
      begin
        Close;
        Params.Clear;
        CommandText := 'Select C.PROCESS_NAME,B.SEQ,B.STEP ' +
          'From SAJET.SYS_ROUTE A, ' +
          'SAJET.SYS_ROUTE_DETAIL B, ' +
          'SAJET.SYS_PROCESS C ' +
          'Where A.ROUTE_NAME = ''QUERYBASE'' and ' +
          'A.ROUTE_ID = B.ROUTE_ID and ' +
          'B.NEXT_PROCESS_ID = C.PROCESS_ID ' +
          'Order By B.SEQ,B.STEP ';
        Open;
        MsExcel.Worksheets['Group_Sort'].select;
        i := 0;
        while not QryTemp.Eof do
        begin
          Inc(i);
          MsExcel.Worksheets['Group_Sort'].Cells[i, 1] := Fieldbyname('PROCESS_NAME').AsString;
          Next;
        end;
        MsExcel.Worksheets['Data'].select;
        SaveExcel(MsExcel, MsExcelWorkBook);
        MsExcelWorkBook.SaveAs(sFileName);
        showmessage('Save Excel OK!!');
      end;
    except
      ShowMessage('Could not start Microsoft Excel.');
    end;
    QryTemp.Close;
    MsExcel.Application.Quit;
    MsExcel := Null;
  end;
  try
    if FileExists(My_FileName) then Deletefile(My_FileName);
  except end;
end;

procedure TfDetail.FormCreate(Sender: TObject);
begin
  StrLstPdLine := TStringList.Create;
  StrLstProcess := TStringList.Create;
  StrLstProcessName := TStringList.Create;
  StrLstPart := TStringList.Create;
  StrLstSort := TStringList.Create;
  gsPath := ExtractFilePath(Application.ExeName);
end;

procedure TfDetail.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StrLstPdLine.Free;
  StrLstProcess.Free;
  StrLstProcessName.Free;
  StrLstPart.Free;
  StrLstSort.Free;
  slFactoryID.Free;
  Action := caFree;
end;

function TfDetail.SelectField(Str, StrFunction: string): string;
begin
  Result := '';
  if Str = 'Production Line' then Result := 'PDLINE_NAME';
  if Str = 'Part No' then Result := 'PART_NO';
  if Str = 'Model Name' then Result := 'F.MODEL_NAME';
  if Str = 'Process Name' then Result := 'PROCESS_NAME';
  if Str = 'Work Order' then Result := 'A.WORK_ORDER';
  if Str = 'Date' then
  begin
    Result := 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY/MM/DD'')';
    if DateStyle = 'Date' then
      Result := 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY/MM/DD'')';
    if DateStyle = 'Week' then
      Result := 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY-WW'')';
    if DateStyle = 'Month' then
      Result := 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY/MM'')';
    if DateStyle = 'Year' then
      Result := 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY'')';
    if StrFunction = 'Field' then
      Result := Result + ' "Work Date" ';
  end;

end;

procedure TfDetail.cmbMainChange(Sender: TObject);
var sTemp: string;
begin
  sTemp := cmbSecond.Text;
  cmbSecond.Items.Clear;
  cmbSecond.Items := cmbMain.Items;
  cmbSecond.Items.Insert(0, 'N/A');
  cmbSecond.Items.Delete(cmbSecond.Items.IndexOf(cmbMain.Text));
  cmbSecond.ItemIndex := cmbSecond.Items.IndexOf(sTemp);
  if cmbSecond.ItemIndex = -1 then cmbSecond.ItemIndex := 0;
  if QryData.IsEmpty then Exit;
  RefreshData(False);
end;

procedure TfDetail.cmbSecondChange(Sender: TObject);
begin
  if QryData.IsEmpty then Exit;
  RefreshData(False);
end;

procedure TfDetail.RefreshData(bRefreshYR: Boolean);
var sField, sField2, sTemp, sYRField: string;
  i, j, sPass, sFail, iPos: Integer; fRate: Real; sMain, sSecond: TStringList;
  slProcess, slPass, slTotal: TStringList;
  procedure DecodeQty(sTemp: string; var sPass, sFail: integer);
  begin
    sPass := StrToIntDef(Copy(sTemp, 1, Pos(#13, sTemp) - 1), 0);
    sFail := StrToIntDef(Copy(sTemp, Pos(#13, sTemp) + 1, Length(sTemp)), 0);
  end;
begin
  if cmbMain.Text = cmbSecond.Text then
    cmbSecond.Itemindex := 0;
  if cmbMain.Text = '' then Exit;
  sField := SelectField(cmbMain.Text, 'Field');
  sField2 := SelectField(cmbSecond.Text, 'Field');
  sMain := TStringList.Create;
  sSecond := TStringList.Create;
  slProcess := TStringList.Create;
  slPass := TStringList.Create;
  slTotal := TStringList.Create;
  sMain.Sorted := True;
  sSecond.Sorted := True;
  with StrGrid do
  begin
    for i := 0 to RowCount - 1 do
      Rows[i].Clear;
    RowCount := 1;
    ColCount := 4;
  end;
  fRate := 100;
  if StrLstSort.IndexOf('Process Code') = -1 then
    sYRField := 'Process Name'
  else
    sYRField := 'Process Code';
  with QryData do
  begin
    First;
    while not Eof do
    begin
      if bRefreshYR then begin
        GPRecords.Caption := InttoStr(StrToInt(GPRecords.Caption) + 1);
        if cmbMain.Items.IndexOf('Process Name') <> -1 then
        begin
          if FieldByName('Pass Qty').AsInteger + FieldByName('Fail Qty').AsInteger <> 0 then
          begin
            iPos := slProcess.IndexOf(FieldByName('Process Name').AsString);
            if iPos = -1 then
            begin
              slProcess.Add(FieldByName('Process Name').AsString);
              slPass.Add(FieldByName('Pass Qty').AsString);
              slTotal.Add(IntToStr(FieldByName('Fail Qty').AsInteger + FieldByName('Pass Qty').AsInteger));
            end
            else
            begin
              slPass[iPos] := IntToStr(StrToInt(slPass[iPos]) + FieldByName('Pass Qty').AsInteger);
              slTotal[iPos] := IntToStr(StrToInt(slTotal[iPos]) + FieldByName('Fail Qty').AsInteger + FieldByName('Pass Qty').AsInteger);
            end;
          end;
        end
        else
        begin
          fRate := fRate * FieldByName('Pass Rate(%)').AsFloat / 100;
        end;
      end;  
      if (cmbMain.Text = 'Process Name') and (sYRField = 'Process Code') then
        sTemp := FieldByName('Process Code').AsString + #13 + FieldByName(cmbMain.Text).AsString
      else
        sTemp := FieldByName(cmbMain.Text).AsString;
      if sMain.IndexOf(sTemp) = -1 then
        sMain.Add(sTemp);
      if not ((cmbSecond.Text = 'N/A') or (cmbSecond.Text = '')) then
      begin
        if (cmbSecond.Text = 'Process Name') and (sYRField = 'Process Code') then
          sTemp := FieldByName('Process Code').AsString + #13 + FieldByName(cmbSecond.Text).AsString
        else
          sTemp := FieldByName(cmbSecond.Text).AsString;
        if sSecond.IndexOf(sTemp) = -1 then
          sSecond.Add(sTemp);
      end;
      Next;
    end;
  end;
  for i := 0 to slProcess.Count - 1 do
  begin
    fRate := fRate * StrToInt(slPass[i]) / StrToInt(slTotal[i]);
  end;
  slTotal.Free;
  slPass.Free;
  slProcess.Free;
  sMain.Sorted := False;
  sSecond.Sorted := False;
  for i := 0 to sMain.Count - 1 do
  begin
    if Pos(#13, sMain[i]) <> 0 then
      sMain[i] := Copy(sMain[i], Pos(#13, sMain[i]) + 1, Length(sMain[i]));
    if ((cmbSecond.Text = 'N/A') or (cmbSecond.Text = '')) then
      StrGrid.Cells[0, i] := sMain[i]
    else
      StrGrid.Cells[0, i + 1] := sMain[i];
  end;
  if ((cmbSecond.Text = 'N/A') or (cmbSecond.Text = '')) then
    StrGrid.RowCount := sMain.Count
  else
  begin
    for i := 0 to sSecond.Count - 1 do
    begin
      if Pos(#13, sSecond[i]) <> 0 then
        sSecond[i] := Copy(sSecond[i], Pos(#13, sSecond[i]) + 1, Length(sSecond[i]));
      StrGrid.Cells[i + 1, 0] := sSecond[i];
    end;
    StrGrid.ColCount := sSecond.Count + 1;
    StrGrid.RowCount := sMain.Count + 1;
  end;
  // 將資料符合之找出填入一 二維陣列
  with QryData do
  begin
    First;
    while not Eof do
    begin
      i := sMain.Indexof(FieldByName(cmbMain.Text).AsString);
      if ((cmbSecond.Text = 'N/A') or (cmbSecond.Text = '')) then
      begin
        StrGrid.Cells[1, i] := IntToStr(StrToIntDef(StrGrid.Cells[1, i], 0) + Fieldbyname('PASS QTY').AsInteger);
        StrGrid.Cells[2, i] := IntToStr(StrToIntDef(StrGrid.Cells[2, i], 0) + Fieldbyname('FAIL QTY').AsInteger);
      end
      else
      begin
        j := sSecond.Indexof(FieldByName(cmbSecond.Text).AsString);
        DecodeQty(StrGrid.Cells[j + 1, i + 1], sPass, sFail);
        StrGrid.Cells[j + 1, i + 1] := IntToStr(sPass + Fieldbyname('PASS QTY').AsInteger) + #13 + IntToStr(sFail + Fieldbyname('FAIL QTY').AsInteger);
      end;
      Next;
    end;
    if ((cmbSecond.Text = 'N/A') or (cmbSecond.Text = '')) then
    begin
      for i := 0 to StrGrid.RowCount - 1 do
        if StrToIntDef(StrGrid.Cells[1, i], 0) + StrToIntDef(StrGrid.Cells[2, i], 0) <> 0 then
          StrGrid.Cells[1, i] := FloatToStr(StrToIntDef(StrGrid.Cells[1, i], 0) / (StrToIntDef(StrGrid.Cells[1, i], 0) + StrToIntDef(StrGrid.Cells[2, i], 0)) * 100)
    end
    else
    begin
      for i := 1 to StrGrid.RowCount - 1 do
        for j := 1 to STrGrid.ColCount - 1 do
        begin
          DecodeQty(StrGrid.Cells[j, i], sPass, sFail);
          if sPass + sFail <> 0 then
            StrGrid.Cells[j, i] := FloatToStr(sPass / (sPass + sFail) * 100)
          else
            StrGrid.Cells[j, i] := '0';
        end;
    end;
    First;
  end;
  sMain.Free;
  sSecond.Free;
  if bRefreshYR then
    GPRate.Caption := FormatFloat('0.00', fRate) + '%';
  cmbChartChange(Self);
end;

procedure TfDetail.cmbChartChange(Sender: TObject);
var i, j: Integer;
  function NewSeries: TChartSeries;
  begin
    if cmbChart.Text = 'Bar' then Result := TBarSeries.Create(Chart1);
    if cmbChart.Text = 'Line' then Result := TLineSeries.Create(Chart1);
    if cmbChart.Text = 'Pie' then Result := TPieSeries.Create(Chart1);
  end;
begin
  for i := (Chart1.SeriesList.Count - 1) downto 0 do
    Chart1.Series[i].Free;

  Chart1.LeftAxis.Title.Caption := '(%)';

  if cmbSecond.Text = 'N/A' then
  begin
    Chart1.AddSeries(NewSeries);
    for i := 0 to StrGrid.RowCount - 1 do
    begin
      Chart1.Series[0].Add(StrToFloat(StrGrid.Cells[1, i]), StrGrid.Cells[0, i]);
    end;
  end
  else
  begin
    for i := 1 to StrGrid.ColCount - 1 do
    begin
      with Chart1.AddSeries(NewSeries) do
      begin
        Title := StrGrid.Cells[i, 0];
        Marks.Visible := (i = (StrGrid.ColCount - 1));
      end;
    end;
    for i := 1 to StrGrid.RowCount - 1 do
    begin
      for j := 1 to StrGrid.ColCount - 1 do
      begin
        if StrGrid.Cells[j, i] = '' then
          StrGrid.Cells[j, i] := '0';
        Chart1.Series[j - 1].Add(StrToFloatDef(StrGrid.Cells[j, i], 0), StrGrid.Cells[0, i]);
      end;
    end;
  end;
  Chart1.View3D := True;
  cmbChtStyle.Enabled := (cmbChart.Text = 'Bar');
  if cmbChtStyle.Enabled then
    cmbChtStyleChange(Self);
end;

procedure TfDetail.cmbChtStyleChange(Sender: TObject);
begin
  if Chart1.SeriesList.Count <= 0 then Exit;
  if cmbChtStyle.Text = 'None' then
    TBarSeries(Chart1.Series[0]).MultiBar := TMultiBar(mbNone);
  if cmbChtStyle.Text = 'Side' then
    TBarSeries(Chart1.Series[0]).MultiBar := TMultiBar(mbSide);
  if cmbChtStyle.Text = 'Stacked' then
    TBarSeries(Chart1.Series[0]).MultiBar := TMultiBar(mbStacked);
end;

procedure TfDetail.Chart1ClickSeries(Sender: TCustomChart;
  Series: TChartSeries; ValueIndex: Integer; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var sSQL, sField, sGroupby, sDot: string;
  StrGridTemp: TStringGrid;
  function GetClickData: string;
  begin
    if Series.XLabel[ValueIndex] = '' then
      Result := ' and ' + SelectField(cmbMain.Text, 'Groupby') + ' is null '
    else
      Result := ' and ' + SelectField(cmbMain.Text, 'Groupby') + ' = ''' + Series.XLabel[ValueIndex] + ''' '
  end;
begin
  StrGridTemp := StrGrid;
  if ValueIndex < 0 then Exit;
  if StrGridTemp.Cells[1, 0] = '' then Exit;

  sField := '';
  sGroupby := '';
  sDot := '';
  if chkDate then
  begin
    if sField <> '' then sDot := ',';
    if DateStyle = 'Date' then
    begin
      sField := sField + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY/MM/DD'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY/MM/DD'')';
    end;
    if DateStyle = 'Week' then
    begin
      sField := sField + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY-WW'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY-WW'')';
    end;
    if DateStyle = 'Month' then
    begin
      sField := sField + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY/MM'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY/MM'')';
    end;
    if DateStyle = 'Year' then
    begin
      sField := sField + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY'')';
    end;
  end;

  if chkLine then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'C.PdLine_Name "Production Line" ';
    sGroupby := sGroupby + sDot + 'C.PdLine_Name';
  end;

  if ChkProcess then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'D.Process_Name "Process Name"';
    sGroupby := sGroupby + sDot + 'D.Process_Name';
  end;

  if ChkWO then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'B.Work_Order "Work Order",B.TARGET_QTY "Target Qty",B.INPUT_QTY "Input",B.OUTPUT_QTY "Output" ';
    sGroupby := sGroupby + sDot + 'B.Work_Order,B.TARGET_QTY,B.INPUT_QTY,B.OUTPUT_QTY';
  end;

  if ChkPart then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'E.Part_No "Part No"' + gsSpec;
    sGroupby := sGroupby + sDot + 'E.Part_No' + gsSpec;
  end;

  if ChkModel then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'F.Model_Name "Model Name"';
    sGroupby := sGroupby + sDot + 'F.Model_Name';
  end;

  if sField = '' then Exit;

  sSQL := 'Select ' + sField + ',SUM(PASS_QTY) "Pass Qty",SUM(FAIL_QTY) "Fail Qty",SUM(REPASS_QTY) "Repass Qty",SUM(REFAIL_QTY) "Refail Qty", ' +
    'Round(nvl(SUM(PASS_QTY)/decode(SUM(PASS_QTY+FAIL_QTY),''0'',null,SUM(PASS_QTY+FAIL_QTY)),0)*100,2)"Pass Rate(%)"' +
    'From SAJET.G_SN_COUNT A' +
    ' ,SAJET.SYS_PDLINE C ';
  if ChkWo or (Trim(editWO.Text) <> '') then
    sSQL := sSQL + ' , SAJET.G_WO_BASE B';
  if ChkProcess then
    sSQL := sSQL + ' ,SAJET.SYS_PROCESS D ';
  if ChkPart or (Trim(editPart.Text) <> '') or ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_PART E ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_Model F ';
  sSQL := sSQL + 'Where A.PDLINE_ID = C.PDLINE_ID ' +
    '  and C.FACTORY_ID = ' + FcID;
  if ChkWo or (Trim(editWO.Text) <> '') then
    sSQL := sSQL + '  and A.WORK_ORDER = B.WORK_ORDER ';
  if ChkProcess then
    sSQL := sSQL + '  and A.PROCESS_ID = D.PROCESS_ID ';
  if ChkPart or (Trim(editPart.Text) <> '') or ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and A.MODEL_ID = E.PART_ID ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and E.MODEL_ID = F.MODEL_ID(+) ';
  if Trim(editWO.Text) <> '' then
    if Pos('%', editWo.Text) <> 0 then
      sSQL := sSQL + ' and B.WORK_ORDER Like ''' + Trim(editWO.Text) + ''' '
    else
      sSQL := sSQL + ' and B.WORK_ORDER = ''' + Trim(editWO.Text) + ''' ';
  if Trim(editPart.Text) <> '' then
    if Pos('%', editPart.Text) <> 0 then
      sSQL := sSQL + ' and E.PART_NO Like ''' + Trim(editPart.Text) + ''' '
    else
      sSQL := sSQL + ' and E.PART_NO = ''' + Trim(editPart.Text) + ''' ';
  if Trim(editModel.Text) <> '' then
    if Pos('%', editModel.Text) <> 0 then
      sSQL := sSQL + ' and F.MODEL_NAME Like ''' + Trim(editModel.Text) + ''' '
    else
      sSQL := sSQL + ' and F.MODEL_NAME = ''' + Trim(editModel.Text) + ''' ';
  if Trim(combLine.Text) <> '' then
    sSQL := sSQL + ' and C.PDLINE_NAME = ''' + Trim(combLine.Text) + ''' ';
  sSQL := sSQL + AddCondition('A.PDLINE_ID', StrLstPdLine)
    + AddCondition('A.PROCESS_ID', StrLstProcess)
    + GetClickData + SelectWorkDate + ' Group By ' + sGroupby;

  with TfData.Create(Self) do
  begin
    sQueryType := 'YieldRate';
    sSelectDate := SelectDate;
    if cmbSecond.Text = 'N/A' then
      GradPanel1.Caption := cmbMain.Text + ' : ' + StrGridTemp.Cells[0, ValueIndex]
    else
      GradPanel1.Caption := cmbMain.Text + ' : ' + StrGridTemp.Cells[0, ValueIndex + 1];
    bDate := chkDate;
    bLine := chkLine;
    bWO := chkWO;
    bPart := chkPart;
    bModel := chkModel;
    bProcess := chkProcess;
    DStyle := DateStyle;
    QryTemp2.RemoteServer := QryTemp.RemoteServer;
    QryTemp2.Close;
    QryTemp2.Params.Clear;
    QryTemp2.CommandText := sSQL;
    QryTemp2.Open;
    GPRecords.Caption := IntToStr(QryTemp2.RecordCount);
    Showmodal;
    Free;
  end;
end;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
var sSQL, sField, sGroupby, sDot: string; i: Integer;
  function SortData: string;
  var I: Integer;
  begin
    Result := '';
    for I := 0 to StrLstSort.Count - 1 do
    begin
      if (StrLstSort.Strings[I] = 'Date') and chkDate then
      begin
        if Result = '' then
          Result := '"Date"'
        else
          Result := Result + ',"Date"';
      end;

      if (StrLstSort.Strings[I] = 'Production Line') and chkLine then
      begin
        if Result = '' then
          Result := '"Production Line"'
        else
          Result := Result + ',"Production Line"';
      end;

      if (StrLstSort.Strings[I] = 'Process Name') and chkProcess then
      begin
        if Result = '' then
          Result := '"Process Name"'
        else
          Result := Result + ',"Process Name"';
      end;

      if (StrLstSort.Strings[I] = 'Work Order') and chkWO then
      begin
        if Result = '' then
          Result := '"Work Order"'
        else
          Result := Result + ',"Work Order"';
      end;

      if (StrLstSort.Strings[I] = 'Part No') and chkPart then
      begin
        if Result = '' then
          Result := '"Part No"'
        else
          Result := Result + ',"Part No"';
      end;

      if (StrLstSort.Strings[I] = 'Model Name') and chkModel then
      begin
        if Result = '' then
          Result := '"Model Name"'
        else
          Result := Result + ',"Model Name"';
      end;

      if (StrLstSort.Strings[I] = 'Process Code') and chkProcess then
      begin
        if Result = '' then
          Result := '"Process Code"'
        else
          Result := Result + ',"Process Code"';
      end;
    end;
  end;
begin
  if QryData.Indexname <> '' then
    QryData.deleteIndex(QryData.Indexname);
  DBGrid1.Visible := False;
  sField := '';
  sGroupby := '';
  sdot := '';
  if chkDate then
  begin
    if sField <> '' then sDot := ',';
    if DateStyle = 'Date' then
    begin
      sField := sField + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY/MM/DD'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY/MM/DD'')';
    end;
    if DateStyle = 'Week' then
    begin
      sField := sField + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY-WW'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY-WW'')';
    end;
    if DateStyle = 'Month' then
    begin
      sField := sField + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY/MM'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY/MM'')';
    end;
    if DateStyle = 'Year' then
    begin
      sField := sField + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(TO_DATE(WORK_DATE,''YYYYMMDD''),''YYYY'')';
    end;
  end;

  if chkLine then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'C.PdLine_Name "Production Line" ';
    sGroupby := sGroupby + sDot + 'C.PdLine_Name';
  end;

  if ChkProcess then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'D.Process_Name "Process Name"';
    sGroupby := sGroupby + sDot + 'D.Process_Name';

    //若有依Process Code排序,則需找出Process Code
    if StrLstSort.IndexOf('Process Code') > -1 then
    begin
      sField := sField + ',D.Process_Code "Process Code"';
      sGroupby := sGroupby + ',D.Process_Code';
    end;
  end;

  if ChkWO then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'B.Work_Order "Work Order",B.TARGET_QTY "Target Qty",B.INPUT_QTY "Input",B.OUTPUT_QTY "Output" ';
    sGroupby := sGroupby + sDot + 'B.Work_Order,B.TARGET_QTY,B.INPUT_QTY,B.OUTPUT_QTY';
  end;

  if ChkPart then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'E.Part_No "Part No"' + gsSpec;
    sGroupby := sGroupby + sDot + 'E.Part_No' + gsSpec;
  end;

  if ChkModel then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'F.Model_Name "Model Name"' + gsSpec;
    sGroupby := sGroupby + sDot + 'F.Model_Name' + gsSpec;
  end;

  if sField = '' then Exit;

  sSQL := 'Select ' + sField + ',SUM(PASS_QTY) "Pass Qty",SUM(FAIL_QTY) "Fail Qty",SUM(REPASS_QTY) "Repass Qty",SUM(REFAIL_QTY) "Refail Qty", ' +
    'Round(nvl(SUM(PASS_QTY)/decode(SUM(PASS_QTY+FAIL_QTY),''0'',null,SUM(PASS_QTY+FAIL_QTY)),0)*100,2) "Pass Rate(%)" ' +
    'From SAJET.G_SN_COUNT A ' +
    ' ,SAJET.SYS_PDLINE C ';
  if ChkWo or (Trim(editWO.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.G_WO_BASE B ';
  if ChkProcess then
    sSQL := sSQL + ' ,SAJET.SYS_PROCESS D ';
  if ChkPart or (Trim(editPart.Text) <> '') or ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_PART E ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_MODEL F ';
  sSQL := sSQL + 'Where A.PDLINE_ID = C.PDLINE_ID ' +
    '  and C.FACTORY_ID = ' + FcID;
  if ChkWo or (Trim(editWO.Text) <> '') then
    sSQL := sSQL + '  and A.WORK_ORDER = B.WORK_ORDER ';
  if ChkProcess then
    sSQL := sSQL + '  and A.PROCESS_ID = D.PROCESS_ID ';
  if ChkPart or (Trim(editPart.Text) <> '') or ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and A.MODEL_ID = E.PART_ID ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and E.MODEL_ID = F.MODEL_ID(+) ';
  if Trim(editWO.Text) <> '' then
    if Pos('%', editWo.Text) <> 0 then
      sSQL := sSQL + ' and B.WORK_ORDER Like ''' + Trim(editWO.Text) + ''' '
    else
      sSQL := sSQL + ' and B.WORK_ORDER = ''' + Trim(editWO.Text) + ''' ';
  if Trim(editPart.Text) <> '' then
    if Pos('%', editPart.Text) <> 0 then
      sSQL := sSQL + ' and E.PART_NO Like ''' + Trim(editPart.Text) + ''' '
    else
      sSQL := sSQL + ' and E.PART_NO = ''' + Trim(editPart.Text) + ''' ';
  if Trim(editModel.Text) <> '' then
    if Pos('%', editModel.Text) <> 0 then
      sSQL := sSQL + ' and F.MODEL_NAME Like ''' + Trim(editModel.Text) + ''' '
    else
      sSQL := sSQL + ' and F.MODEL_NAME = ''' + Trim(editModel.Text) + ''' ';
  if Trim(combLine.Text) <> '' then sSQL := sSQL + ' and C.PDLINE_NAME = ''' + Trim(combLine.Text) + ''' ';
  sSQL := sSQL
    + AddCondition('A.PDLINE_ID', StrLstPdLine)
    + AddCondition('A.PROCESS_ID', StrLstProcess)
    + SelectWorkDate
    + ' Group By ' + sGroupby;

  if StrLstSort.Count > 0 then
    sSQL := sSQL + ' Order By ' + SortData;

  for i := (Chart1.SeriesList.Count - 1) downto 0 do
    Chart1.Series[i].Free;
  GPRecords.Caption := '0';
  GPRate.Caption := '0';

  with QryData do
  begin
    Close;
    Params.Clear;
    CommandText := sSQL;
    Open;
    if not IsEmpty then
      RefreshData(True);
  end;
  DBGrid1.Visible := True;
  for i := 0 to DBGrid1.Columns.Count - 1 do
    if DBGrid1.Columns[i].Width > 130 then
      DBGrid1.Columns[i].Width := 130;
  sQueryCon := 'DateTime : '
    + FormatDateTime('yyyy/mm/dd', dtStart.Date) + ':' + cmbWSStart.Text + ' ~ '
    + FormatDateTime('yyyy/mm/dd', dtEnd.Date) + ':' + cmbWSEnd.Text;
  if Trim(editWO.Text) <> '' then
    sQueryCon := '  WO:' + Trim(editWO.Text);
  if Trim(editPart.Text) <> '' then
    sQueryCon := sQueryCon + '  P/N:' + Trim(editPart.Text);
  if Trim(editModel.Text) <> '' then
    sQueryCon := sQueryCon + '  Model:' + Trim(editModel.Text);
  if Trim(combLine.Text) <> '' then
    sQueryCon := sQueryCon + '  Line:' + Trim(combLine.Text);
  if StrLstProcessName.Count <> 0 then
  begin
    sQueryCon := sQueryCon + '  Process:' + StrLstProcessName[0];
    for i := 1 to StrLstProcessName.Count - 1 do
      sQueryCon := sQueryCon + ',' + StrLstProcessName[i];
  end;
end;

procedure TfDetail.SaveImage1Click(Sender: TObject);
begin
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'bmp';
  SaveDialog1.Filter := 'All Files(*.bmp)|*.bmp';

  if SaveDialog1.Execute then
  begin
    try
      if FileExists(SaveDialog1.FileName) then
        if MessageDlg('File Exist ' + #13#10 + 'Do you want to save it ??', mtWarning, mbOKCancel, 0) <> mrOK then
          Exit;
      Chart1.SaveToBitmapFile(SaveDialog1.FileName);
      showmessage('Save Image OK!!');
    except
      ShowMessage('Could not Save Image !!');
    end;
  end;
end;

procedure TfDetail.Copy1Click(Sender: TObject);
begin
  Chart1.CopyToClipboardBitmap;
end;

procedure TfDetail.CurrentRecordDetailData1Click(Sender: TObject);
var sSQL: string;
  function GetCondition: string;
  begin
    Result := '';
    if chkDate then
    begin
      if DateStyle = 'Date' then
        Result := Result + ' and TO_CHAR(OUT_PROCESS_TIME,''YYYY/MM/DD'') = ''' + QryData.Fieldbyname('Date').AsString + ''' ';
      if DateStyle = 'Week' then
        Result := Result + ' and TO_CHAR(OUT_PROCESS_TIME,''YYYY-WW'') = ''' + QryData.Fieldbyname('Date').AsString + ''' ';
      if DateStyle = 'Month' then
        Result := Result + ' and TO_CHAR(OUT_PROCESS_TIME,''YYYY/MM'') = ''' + QryData.Fieldbyname('Date').AsString + ''' ';
      if DateStyle = 'Year' then
        Result := Result + ' and TO_CHAR(OUT_PROCESS_TIME,''YYYY'') = ''' + QryData.Fieldbyname('Date').AsString + ''' ';
    end;
    if chkLine then
      Result := Result + ' and C.PDLINE_NAME = ''' + QryData.Fieldbyname('Production Line').AsString + ''' ';
    if chkProcess then
      Result := Result + ' and D.PROCESS_NAME = ''' + QryData.Fieldbyname('Process Name').AsString + ''' ';
    if chkWO then
      Result := Result + ' and A.Work_Order = ''' + QryData.Fieldbyname('Work Order').AsString + ''' ';
    if chkPart then
      Result := Result + ' and E.Part_No = ''' + QryData.Fieldbyname('Part No').AsString + ''' ';
    if chkModel then
      if QryData.Fieldbyname('Model Name').AsString <> '' then
        Result := Result + ' and G.Model_Name = ''' + QryData.Fieldbyname('Model Name').AsString + ''' '
      else
        Result := Result + ' and G.Model_Name is null ';
  end;
begin
  if not QryData.Active then Exit;
  if QryData.Eof then Exit;
  sSQL := 'Select /*+INDEX(A G_SN_TRAVEL_OUT_PROCESS_IDX) */ A.WORK_ORDER "Work Order",' +
    'A.SERIAL_NUMBER "Serial Number",' +
    'A.CUSTOMER_SN "Customer SN",' +
    'Decode(A.CURRENT_STATUS,''1'',''NG'','''') "Status",' + //add 2006/03/16
    'C.PDLINE_NAME "Production Line",' +
    'D.PROCESS_NAME "Process Name",' +
    'A.OUT_PROCESS_TIME "Out Process Time",' +
    'F.EMP_NAME "Employee" ' +
    'From SAJET.G_SN_TRAVEL A,' +
    ' SAJET.SYS_PDLINE C, ' +
    ' SAJET.SYS_PROCESS D, ' +
    ' SAJET.SYS_EMP F ';
  if ChkPart or (Trim(editPart.Text) <> '') or ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_PART E ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_MODEL G ';
  sSQL := sSQL + 'Where ' + SelectDate + GetCondition +
    '  and C.FACTORY_ID = ' + FcID +
    '  and A.PDLINE_ID = C.PDLINE_ID ' +
    '  and A.PROCESS_ID = D.PROCESS_ID ';
  if ChkPart or (Trim(editPart.Text) <> '') or ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and A.MODEL_ID = E.PART_ID ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and E.MODEL_ID = G.MODEL_ID(+) ';
  if Trim(editWO.Text) <> '' then
    if Pos('%', editWo.Text) <> 0 then
      sSQL := sSQL + ' and A.WORK_ORDER Like ''' + Trim(editWO.Text) + ''' '
    else
      sSQL := sSQL + ' and A.WORK_ORDER = ''' + Trim(editWO.Text) + ''' ';
  if Trim(editPart.Text) <> '' then
    if Pos('%', editPart.Text) <> 0 then
      sSQL := sSQL + ' and E.PART_NO Like ''' + Trim(editPart.Text) + ''' '
    else
      sSQL := sSQL + ' and E.PART_NO = ''' + Trim(editPart.Text) + ''' ';
  if Trim(editModel.Text) <> '' then
    if Pos('%', editModel.Text) <> 0 then
      sSQL := sSQL + ' and G.MODEL_NAME Like ''' + Trim(editModel.Text) + ''' '
    else
      sSQL := sSQL + ' and G.MODEL_NAME = ''' + Trim(editModel.Text) + ''' ';
  if Trim(combLine.Text) <> '' then sSQL := sSQL + ' and C.PDLINE_NAME = ''' + Trim(combLine.Text) + ''' ';
  sSQL := sSQL + ' and A.EMP_ID = F.EMP_ID(+) ' +
    'Order by "Serial Number" ';

  with TfDataDetail.Create(Self) do
  begin
    GradPanel1.Caption := 'Detail Data';
    GPRecords.Caption := IntToStr(QryData.FieldByName('Pass Qty').AsInteger + QryData.FieldByName('Fail Qty').AsInteger
      + QryData.FieldByName('RePass Qty').AsInteger + QryData.FieldByName('ReFail Qty').AsInteger);
    QuryDataDetail.RemoteServer := QryData.RemoteServer;
    QuryDataDetail.Close;
    QuryDataDetail.Params.Clear;
    QuryDataDetail.CommandText := sSQL;
    QuryDataDetail.Open;
    Showmodal;
    Free;
  end;
end;

procedure TfDetail.DBGrid1DblClick(Sender: TObject);
begin
  CurrentRecordDetailData1Click(Self);
end;

procedure TfDetail.sbtnStyle2Click(Sender: TObject);
begin
  PageControl1.ActivePage := TabGlyph;
end;

procedure TfDetail.cmbFactoryChange(Sender: TObject);
begin
  FcID := slFactoryId[cmbFactory.ItemIndex];
  with QryTemp do
  begin
    Params.Clear;
    Params.CreateParam(ftString, 'fcid', ptInput);
    CommandText := 'select pdline_name from sajet.sys_pdline '
      + 'where FACTORY_ID = :fcid and enabled = ''Y'' '
      + 'order by pdline_name ';
    Params.ParamByName('fcid').AsString := FcID;
    Open;
    combLine.Items.Clear;
    combLine.Items.Add('');
    while not Eof do
    begin
      if StrLstPdLine.Count <> 0 then
      begin
        if StrLstPdLine.IndexOf(FieldByName('Pdline_Name').AsString) <> -1 then
          combLine.Items.Add(FieldByName('Pdline_Name').AsString);
      end
      else
        combLine.Items.Add(FieldByName('Pdline_Name').AsString);
      Next;
    end;
    Close;
  end;
end;

procedure TfDetail.sbtnWoClick(Sender: TObject);
begin
  with TfCommData.Create(Self) do
  begin
    LabType2.Caption := 'Work Order List';
    LabType1.Caption := LabType2.Caption;
    Label1.Caption := 'Search Work Order';
    with QryTemp do
    begin
      Close;
      Params.Clear;
      if editWo.Text <> '' then
        Params.CreateParam(ftString, 'work_order', ptInput);
      CommandText := 'select work_order "Work Order", target_qty "Target Qty", '
        + 'part_no "Part No", part_type "Part Type", spec1 "Spec1", spec2 "Spec2" '
        + 'from sajet.g_wo_base a, sajet.sys_part b '
        + 'where wo_status > 0 and wo_status < 5 ';
      if editWo.Text <> '' then
        CommandText := CommandText + 'and work_order like :work_order ';
      CommandText := CommandText + 'and a.model_id = b.part_id '
        + 'order by work_order ';
      if editWo.Text <> '' then
        Params.ParamByName('work_order').AsString := editWo.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      editWo.Text := QryTemp.FieldByName('work order').AsString;
      QryTemp.Close;
      editWo.SetFocus;
    end;
    free;
  end;
end;

procedure TfDetail.sbtnPartClick(Sender: TObject);
begin
  with TfCommData.Create(Self) do
  begin
    LabType2.Caption := 'Part No List';
    LabType1.Caption := LabType2.Caption;
    Label1.Caption := 'Search Part No';
    with QryTemp do
    begin
      Close;
      Params.Clear;
      if editPart.Text <> '' then
        Params.CreateParam(ftString, 'part_no', ptInput);
      CommandText := 'select part_no "Part No", part_type "Part Type", spec1 "Spec1", spec2 "Spec2" '
        + 'from sajet.sys_part b ';
      if editPart.Text <> '' then
        CommandText := CommandText + 'where part_no like :part_no ';
      CommandText := CommandText + 'order by part_no ';
      if editPart.Text <> '' then
        Params.ParamByName('part_no').AsString := editPart.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      editPart.Text := QryTemp.FieldByName('part no').AsString;
      QryTemp.Close;
      editPart.SetFocus;
    end;
    free;
  end;
end;

procedure TfDetail.SpeedButton1Click(Sender: TObject);
begin
  with TfProcess.Create(Self) do
  begin
    gsSQL := 'Select STAGE_CODE,STAGE_NAME,PROCESS_CODE,PROCESS_NAME,PROCESS_ID ' +
      'From SAJET.SYS_PROCESS A, ' +
      'SAJET.SYS_STAGE B ' +
      'Where A.STAGE_ID = B.STAGE_ID ' +
      'and A.ENABLED = ''Y'' ' +
      'and B.ENABLED = ''Y'' ' +
      'Order By STAGE_CODE,STAGE_NAME,PROCESS_CODE,PROCESS_NAME ';
    Showmodal;
    Free;
  end;
end;

procedure TfDetail.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  if not qryData.Active then Exit;
  if qryData.IsEmpty then Exit;
  if qryData.FieldByName('Pass Rate(%)').AsFloat < StrToFloatDef(edtLower.Text, 90) then
  begin
    DBGrid1.Canvas.Brush.Color := clRed
  end
  else if qryData.FieldByName('Pass Rate(%)').AsFloat < StrToFloatDef(edtUpper.Text, 95) then
    DBGrid1.Canvas.Brush.Color := clYellow
  else
    DBGrid1.Canvas.Brush.Color := clWhite;
  DBGrid1.Canvas.Font.Color := clBlack;
  DBGrid1.DefaultDrawDataCell(rect, Column.Field, State);
end;

procedure TfDetail.sbtnModelClick(Sender: TObject);
begin
  with TfCommData.Create(Self) do
  begin
    LabType2.Caption := 'Model List';
    LabType1.Caption := LabType2.Caption;
    Label1.Caption := 'Search Model';
    with QryTemp do
    begin
      Close;
      Params.Clear;
      if editModel.Text <> '' then
        Params.CreateParam(ftString, 'model_name', ptInput);
      CommandText := 'select model_name "Model Name", model_type "Model Type", model_desc1 "Description1", model_desc2 "Description2" '
        + 'from sajet.sys_model b ';
      if editModel.Text <> '' then
        CommandText := CommandText + 'where model_name like :model_name ';
      CommandText := CommandText + 'order by model_name ';
      if editModel.Text <> '' then
        Params.ParamByName('model_name').AsString := editModel.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      editModel.Text := QryTemp.FieldByName('Model Name').AsString;
      QryTemp.Close;
      editModel.SetFocus;
    end;
    free;
  end;
end;

end.

