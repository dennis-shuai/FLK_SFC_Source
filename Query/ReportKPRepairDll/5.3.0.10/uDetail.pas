unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, Db, DBClient, Variants,
  MConnect, SConnect, FileCtrl, ObjBrkr, Menus, Clrgrid, ComObj, ComCtrls,
  GradPanel, Series, TeEngine, TeeProcs, Chart, ImgList, DBGrid1;

type
  TfDetail = class(TForm)
    SpeedButton5: TSpeedButton;
    Image2: TImage;
    Panel1: TPanel;
    ImageTitle: TImage;
    Label4: TLabel;
    Label3: TLabel;
    sbtnStyle1: TSpeedButton;
    sbtnStyle2: TSpeedButton;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label10: TLabel;
    Image9: TImage;
    PageControl1: TPageControl;
    TabData: TTabSheet;
    GradPanel13: TGradPanel;
    Label18: TLabel;
    Label19: TLabel;
    GPRecords: TGradPanel;
    GPQty: TGradPanel;
    GradPanel14: TGradPanel;
    Image7: TImage;
    sbtnSave: TSpeedButton;
    Image8: TImage;
    sbtnPrint: TSpeedButton;
    LabReportName1: TLabel;
    TabGlyph: TTabSheet;
    Chart1: TChart;
    LabReportName: TLabel;
    lstDesc: TListBox;
    lstDesc2: TListBox;
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
    StrPlato: TStringGrid;
    StrGrid: TStringGrid;
    DTStart: TDateTimePicker;
    DTEnd: TDateTimePicker;
    editPart: TEdit;
    cmbFactory: TComboBox;
    cmbWSStart: TComboBox;
    cmbWSEnd: TComboBox;
    combLine: TComboBox;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    QryTemp2: TClientDataSet;
    DataSource1: TDataSource;
    PopupMenu1: TPopupMenu;
    SaveImage1: TMenuItem;
    Copy1: TMenuItem;
    SaveDialog1: TSaveDialog;
    sbtnPart: TSpeedButton;
    Image3: TImage;
    sbtnQuery: TSpeedButton;
    ImgLst: TImageList;
    DBGrid1: TDBGrid1;
    lablTop: TLabel;
    cmbTop: TComboBox;
    Image1: TImage;
    SpeedButton1: TSpeedButton;
    lablModel: TLabel;
    editModel: TEdit;
    sbtnModel: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure sbtnStyle1Click(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbMainChange(Sender: TObject);
    procedure cmbChartChange(Sender: TObject);
    procedure cmbChtStyleChange(Sender: TObject);
    procedure Chart1ClickSeries(Sender: TCustomChart; Series: TChartSeries;
      ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure sbtnQueryClick(Sender: TObject);
    procedure SaveImage1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure sbtnStyle2Click(Sender: TObject);
    procedure sbtnPrintClick(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
    procedure sbtnPartClick(Sender: TObject);
    procedure cmbSecondChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure sbtnModelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    RpID, gsPath: string;
    gbChange, gbTitle, gbBox: Boolean;
    UpdateUserID, gsSpec: string;
    SocketConnection1: TSocketConnection;
    procedure GetReportParams;
    function DownloadSampleFile: string;
    function AddCondition(sField: string; sList: TStringList): string;
    function SelectField(Str, StrFunction: string): string;
    procedure GetReportName;
    procedure GetPdLineData;
    procedure GetProcessData;
    procedure GetPartData;
    procedure GetSpecField;
    function SelectDate: string;
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
    procedure GetFactoryData;
    procedure RefreshData(bRefreshYR: Boolean);
  end;

var
  fDetail: TfDetail;
  FcID: string;
  ChkDate, ChkLine, ChkWO, ChkPart, ChkModel, ChkProcess, ChkDefect, ChkReason, ChkDuty, ChkLocation: Boolean;
  DateStyle: string;
  ChartMain, ChartSecond: string;
  slFactoryID, StrLstPdLine, StrLstPart, StrLstSort, StrLstProcess, StrLstProcessName: TStringList;
  sQueryCon: string;

implementation

{$R *.DFM}

uses uData, uDataDetail, uCommData, uProcess;

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
  MsExcel.Run('WIP');
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
  ChkDate := False;
  ChkLine := False;
  ChkWO := False;
  ChkPart := False;
  ChkModel := False;
  ChkProcess := False;
  ChkDefect := False;
  ChkReason := False;
  ChkDuty := False;
  ChkLocation := False;
  StrLstProcess.Clear;
  StrLstProcessName.Clear;
  StrLstPdLine.Clear;
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
      if Fieldbyname('PARAM_TYPE').AsString = 'Date Style' then
        DateStyle := Fieldbyname('PARAM_VALUE').AsString;
      if Fieldbyname('PARAM_TYPE').AsString = 'Display Information' then
      begin
        if Fieldbyname('PARAM_NAME').AsString = 'Date' then
          ChkDate := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Production Line' then
          ChkLine := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Work Order' then
          ChkWO := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Part No' then
          ChkPart := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Model Name' then
          ChkModel := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Defect Process' then
          ChkProcess := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Defect Info.' then
          ChkDefect := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Reason Info.' then
          ChkReason := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Duty' then
          ChkDuty := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Location' then
          ChkLocation := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
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
    GetPdLineData;
    GetPartData;
  end;
end;

function TfDetail.SelectDate: string;
begin
  Result := ' (A.REC_TIME between to_date(''' + FormatDateTime('yyyymmdd', DTStart.Date) + cmbWSStart.Text + ''',''yyyymmddhh24'') ';
  if cmbWSEnd.ItemIndex = cmbWSEnd.Items.Count - 1 then
    Result := Result + ' and to_date(''' + FormatDateTime('yyyymmdd', DTEnd.Date + 1) + ''',''yyyymmdd'')) '
  else
    Result := Result + ' and to_date(''' + FormatDateTime('yyyymmdd', DTEnd.Date) + cmbWSEnd.Text + ''',''yyyymmddhh24'')) ';
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
  if FileExists(gsPath + fDetail.RpID + 'ID.Txt') then begin
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
var slPort: TStringList;
begin
  DTStart.DateTime := now;
  DTEnd.DateTime := now;
  DTStart.DateTime := Now;
  DTEnd.DateTime := Now;
  GetReportName;
  GetReportParams;
  GetFactoryData;
  GetSpecField;
  with qryTemp do begin
    Close;
    Params.Clear;
    CommandText := 'select * from all_tab_columns '
      + 'where owner=''SAJET'' and table_name = ''G_SN_STATUS'' and column_name =''BOX_NO''';
    Open;
    gbBox := not IsEmpty;
    Close;
    Params.Clear;
    CommandText := 'select sql_value from sajet.sys_sql '
      + 'where sql_name = ''Report Defect Top N'' and rownum = 1';
    Open;
    cmbTop.Items.Clear;
    slPort := TStringList.Create;
    if IsEmpty then
      slPort.CommaText := '5,10,15,20,ALL'
    else
      slPort.CommaText := FieldByName('sql_value').AsString;
    cmbTop.Items.AddStrings(slPort);
    cmbTop.ItemIndex := 0;
    slPort.Free;
    Close;
  end;
  cmbChart.ItemIndex := 0;
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
  gbChange := True;
  gsPath := ExtractFilePath(Application.ExeName);
end;

procedure TfDetail.FormDestroy(Sender: TObject);
begin
  StrLstPdLine.Free;
  StrLstProcess.Free;
  StrLstProcessName.Free;
  StrLstPart.Free;
  StrLstSort.Free;
  slFactoryID.Free;
end;

function TfDetail.SelectField(Str, StrFunction: string): string;
var sDesc: string;
begin
  sDesc := '';
  if strFunction = 'Field' then
    sDesc := ' sDesc'
  else if strFunction = 'Field2' then
    sDesc := ' sDesc2';
  if Str = 'Date' then
  begin
    Result := 'TO_CHAR(a.REC_TIME,''YYYY/MM/DD'')';
    if DateStyle = 'Date' then
      Result := 'TO_CHAR(a.REC_TIME,''YYYY/MM/DD'')';
    if DateStyle = 'Week' then
      Result := 'TO_CHAR(a.REC_TIME,''YYYY-WW'')';
    if DateStyle = 'Month' then
      Result := 'TO_CHAR(a.REC_TIME,''YYYY/MM'')';
    if DateStyle = 'Year' then
      Result := 'TO_CHAR(a.REC_TIME,''YYYY'')';
  end;

  if Str = 'Production Line' then Result := 'PDLINE_NAME';
  if Str = 'Part No' then Result := 'PART_NO';
  if Str = 'Work Order' then Result := 'A.WORK_ORDER';
  if Str = 'Defect Process' then Result := 'PROCESS_NAME';
  if Str = 'Defect Info.' then Result := 'DEFECT_DESC' + sDesc + ',DEFECT_CODE'; ////
  if Str = 'Reason Info.' then Result := 'REASON_DESC' + sDesc + ',NVL(Reason_Code,''N/A'')'; /////
  if Str = 'Duty' then Result := 'NVL(Duty_Code,''N/A'')';
  if Str = 'Location' then Result := 'NVL(b.Location,''N/A'')';
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
var sField, sField2, sTemp, sTemp1: string;
  i, j: Integer; sMain, sSecond: TStringList;
  procedure DecodeQty(sTemp: string; var sPass, sFail: integer);
  begin
    sPass := StrToIntDef(Copy(sTemp, 1, Pos(#13, sTemp) - 1), 0);
    sFail := StrToIntDef(Copy(sTemp, Pos(#13, sTemp) + 1, Length(sTemp)), 0);
  end;
  function SelectField(Str: String): String;
  begin
    if Str = 'Defect Info.' then Result := 'Defect Code'
    else if Str = 'Reason Info.' then Result := 'Reason Code'
    else if Str = 'Duty' then Result := 'Duty Code'
    else Result := Str;
  end;
begin
  if cmbMain.Text = cmbSecond.Text then
    cmbSecond.Itemindex := 0;
  if cmbMain.Text = '' then Exit;
  sField := SelectField(cmbMain.Text);
  sField2 := SelectField(cmbSecond.Text);
  sMain := TStringList.Create;
  sSecond := TStringList.Create;
  sMain.Sorted := True;
  sSecond.Sorted := True;
  with StrPlato do
  begin
    for i := 0 to RowCount - 1 do
      Rows[i].Clear;
    RowCount := 1;
    ColCount := 2;
  end;
  with StrGrid do
  begin
    for i := 0 to RowCount - 1 do
      Rows[i].Clear;
    RowCount := 1;
    ColCount := 4;
  end;
  with QryData do
  begin
    First;
    while not Eof do
    begin
      if bRefreshYR then begin
        GPRecords.Caption := IntToStr(StrToInt(GPRecords.Caption) + 1);
        GPQty.Caption := IntToStr(StrToInt(GPQty.Caption) + FieldByName('QTY').AsInteger);
      end;  
      if (sField = 'Defect Process') and (StrLstSort.IndexOf('Process Code') > -1) then
        sTemp := FieldByName('Process Code').AsString + #13 + FieldByName(sField).AsString
      else
        sTemp := FieldByName(sField).AsString;
      if sMain.IndexOf(sTemp) = -1 then
        sMain.Add(sTemp);
      if not ((cmbSecond.Text = 'N/A') or (cmbSecond.Text = '')) then
      begin
        if (sField2 = 'Defect Process') and (StrLstSort.IndexOf('Process Code') > -1) then
          sTemp := FieldByName('Process Code').AsString + #13 + FieldByName(sField2).AsString
        else
          sTemp := FieldByName(sField2).AsString;
        if sSecond.IndexOf(sTemp) = -1 then
          sSecond.Add(sTemp);
      end;
      Next;
    end;
  end;
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
    StrPlato.Cells[0, i] := sMain[i];
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
  StrPlato.RowCount := sMain.Count;
  // 將資料符合之找出填入一 二維陣列
  with QryData do
  begin
    First;
    while not Eof do
    begin
      i := sMain.Indexof(FieldByName(sField).AsString);
      StrPlato.Cells[1, i] := IntToStr(StrToIntDef(StrPlato.Cells[1, i], 0) + Fieldbyname('QTY').AsInteger);
      if ((cmbSecond.Text = 'N/A') or (cmbSecond.Text = '')) then
        StrGrid.Cells[1, i] := IntToStr(StrToIntDef(StrGrid.Cells[1, i], 0) + Fieldbyname('QTY').AsInteger)
      else
      begin
        j := sSecond.Indexof(FieldByName(sField2).AsString);
        StrGrid.Cells[j + 1, i + 1] := IntToStr(StrToIntDef(StrGrid.Cells[j + 1, i + 1], 0) + Fieldbyname('QTY').AsInteger);
      end;
      Next;
    end;
    First;
  end;
  for i := 0 to StrPlato.RowCount - 1 do
    for j := i + 1 to StrPlato.RowCount - 1 do
      if StrToIntDef(StrPlato.Cells[1, i],0) < StrToIntDef(StrPlato.Cells[1, j],0) then
      begin
        sTemp := StrPlato.Cells[0, i];
        sTemp1 := StrPlato.Cells[1, i];
        StrPlato.Cells[0, i] := StrPlato.Cells[0, j];
        StrPlato.Cells[1, i] := StrPlato.Cells[1, j];
        StrPlato.Cells[0, j] := sTemp;
        StrPlato.Cells[1, j] := sTemp1;
      end;
  sMain.Free;
  sSecond.Free;
  cmbChartChange(Self);
end;

procedure TfDetail.cmbChartChange(Sender: TObject);
var i, J, mTotal, mC, iTop: Integer;
  function NewSeries: TChartSeries;
  begin
    if cmbChart.Text = 'Bar' then Result := TBarSeries.Create(Chart1)
    else if cmbChart.Text = 'Line' then Result := TLineSeries.Create(Chart1)
    else Result := TPieSeries.Create(Chart1); //If cmbChart.Text = 'Pie' Then
  end;
begin
  cmbSecond.Enabled := True;
  lablTop.Visible := False;
  if cmbChart.Text = 'Pareto' then
  begin
    lablTop.Visible := True;
    cmbSecond.Enabled := False;
    for i := (Chart1.SeriesList.Count - 1) downto 0 do
      Chart1.Series[i].Free;

    mTotal := 0;
    if StrToIntDef(cmbTop.Text, -1) = -1 then
      iTop := StrPlato.RowCount
    else
      iTop := StrtoInt(cmbTop.Text);
    if StrPlato.RowCount - 1 < iTop then
      iTop := StrPlato.RowCount;

    for i := 0 to StrPlato.RowCount - 1 do
      mTotal := mTotal + StrToIntDef(StrPlato.Cells[1, i], 0);

    Chart1.AddSeries(TBarSeries.Create(Chart1));
    Chart1.Series[0].Title := 'Defect Qty';
    Chart1.Series[0].VertAxis := aRightAxis;
    Chart1.AddSeries(TLineSeries.Create(Chart1));
    Chart1.Series[1].VertAxis := aRightAxis;
    Chart1.Series[1].Title := 'Accumulation';
    mC := 0;
    for i := 0 to iTop - 1 do begin
      mC := mC + StrToIntDef(StrPlato.Cells[1, i], 0);
      if StrPlato.ColCount = 3 then begin
        Chart1.Series[0].Add((StrToIntDef(StrPlato.Cells[1, i], 0) / mTotal) * 100, StrPlato.Cells[0, i] + '-' + StrPlato.Cells[2, i]);
        Chart1.Series[1].Add((mC / mTotal) * 100, StrPlato.Cells[0, i] + '-' + StrPlato.Cells[2, i]);
      end else begin
        Chart1.Series[0].Add((StrToIntDef(StrPlato.Cells[1, i], 0) / mTotal) * 100, StrPlato.Cells[0, i]);
        Chart1.Series[1].Add((mC / mTotal) * 100, StrPlato.Cells[0, i]);
      end;
    end;
    if mC <> mTotal then
    begin
      Chart1.Series[0].Add(((mTotal-mC) / mTotal) * 100, 'Other');
      Chart1.Series[1].Add(100, 'Other');
    end;
  end
  else
  begin
    for i := (Chart1.SeriesList.Count - 1) downto 0 do
      Chart1.Series[i].Free;

    if cmbSecond.Text = 'N/A' then
    begin
      Chart1.AddSeries(NewSeries);
      for i := 0 to StrGrid.RowCount - 1 do
      begin
        if lstDesc.Items.Count <> 0 then
          Chart1.Series[0].Add(StrToIntDef(StrGrid.Cells[1, i], 0), StrGrid.Cells[0, i] + '-' + lstDesc.Items[i])
        else
          Chart1.Series[0].Add(StrToIntDef(StrGrid.Cells[1, i], 0), StrGrid.Cells[0, i]);
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
          if lstDesc.Items.Count <> 0 then
            Chart1.Series[j - 1].Add(StrToIntDef(StrGrid.Cells[j, i], 0), StrGrid.Cells[0, i] + '-' + lstDesc.Items[i - 1])
          else
            Chart1.Series[j - 1].Add(StrToIntDef(StrGrid.Cells[j, i], 0), StrGrid.Cells[0, i]);
        end;
      end;
      if Chart1.SeriesCount = 1 then
        Chart1.Series[0].Title := StrGrid.Cells[1, 0];
    end;
  end;
  Chart1.View3D := True;
  cmbTop.Visible := lablTop.Visible;
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
  function SelectField1(Str, StrFunction: string): string;
  begin
    Result := 'PART_NO';
    if Str = 'Date' then
    begin
      if DateStyle = 'Date' then
        Result := 'TO_CHAR(a.REC_TIME,''YYYY/MM/DD'')';
      if DateStyle = 'Week' then
        Result := 'TO_CHAR(a.REC_TIME,''YYYY-WW'')';
      if DateStyle = 'Month' then
        Result := 'TO_CHAR(a.REC_TIME,''YYYY/MM'')';
      if DateStyle = 'Year' then
        Result := 'TO_CHAR(a.REC_TIME,''YYYY'')';
    end;

    if Str = 'Production Line' then Result := 'PDLINE_NAME';
    if Str = 'Part No' then Result := 'PART_NO';
    if Str = 'Work Order' then Result := 'A.WORK_ORDER';
    if Str = 'Defect Process' then Result := 'PROCESS_NAME';
    if Str = 'Defect Info.' then
    begin
      if StrFunction = 'Where' then
        Result := 'DEFECT_CODE'
      else
        Result := 'DEFECT_CODE "Defect Code",DEFECT_DESC';
    end;
    if Str = 'Reason Info.' then
    begin
      if StrFunction = 'Where' then
        Result := 'Reason_Code'
      else
        Result := 'Reason_Code "Reason Code", REASON_DESC';
    end;
    if Str = 'Duty' then Result := 'Duty_Code';
    if Str = 'Location' then Result := 'b.Location';
  end;

  function GetClickData: string;
  begin
    if cmbChart.Text = 'Pareto' then
    begin
      if (StrGridTemp.ColCount = 3) then
        Result := ' and ' + SelectField1(cmbMain.Text, 'Where') + ' = ''' + StrGridTemp.Cells[0, ValueIndex] + ''' '
      else
        Result := ' and ' + SelectField1(cmbMain.Text, 'Where') + ' = ''' + Series.XLabel[ValueIndex] + ''' ';
    end
    else
    begin
      if cmbSecond.Text = 'N/A' then
        Result := ' and ' + SelectField1(cmbMain.Text, 'Where') + ' = ''' + StrGrid.Cells[0, ValueIndex] + ''' ' //'''+ Series.XLabel[ValueIndex]+''' '
      else
        Result := ' and ' + SelectField1(cmbMain.Text, 'Where') + ' = ''' + StrGridTemp.Cells[0, ValueIndex + 1] + ''' ';
    end;
  end;
begin
  StrGridTemp := StrGrid;
  if cmbChart.Text = 'Pareto' then
    StrGridTemp := StrPlato;

  if ValueIndex < 0 then Exit;
  if StrGridTemp.Cells[1, 0] = '' then Exit;

  sField := '';
  sGroupby := '';
  sDot := '';
   //ChkLine, ChkProcess, ChkTerminal, ChkWO, ChkPart
  if chkDate then
  begin
    if sField <> '' then sDot := ',';
    if DateStyle = 'Date' then
    begin
      sField := sField + sDot + 'TO_CHAR(a.REC_TIME,''YYYY/MM/DD'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(a.REC_TIME,''YYYY/MM/DD'')';
    end;
    if DateStyle = 'Week' then
    begin
      sField := sField + sDot + 'TO_CHAR(A.REC_TIME,''YYYY-WW'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(a.REC_TIME,''YYYY-WW'')';
    end;
    if DateStyle = 'Month' then
    begin
      sField := sField + sDot + 'TO_CHAR(a.REC_TIME,''YYYY/MM'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(a.REC_TIME,''YYYY/MM'')';
    end;
    if DateStyle = 'Year' then
    begin
      sField := sField + sDot + 'TO_CHAR(a.REC_TIME,''YYYY'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(a.REC_TIME.,''YYYY'')';
    end;
  end;

  if chkLine then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'C.PdLine_Name "Production Line" ';
    sGroupby := sGroupby + sDot + 'C.PdLine_Name';
  end;

  if ChkWO then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'A.Work_Order "Work Order"';
    sGroupby := sGroupby + sDot + 'A.Work_Order';
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
    sField := sField + sDot + 'J.Model_Name "Model Name"';
    sGroupby := sGroupby + sDot + 'J.Model_Name';
  end;

  if ChkProcess then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'D.Process_Name "Defect Process"';
    sGroupby := sGroupby + sDot + 'D.Process_Name';
  end;

  if ChkDefect then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'F.Defect_Code "Defect Code",F.Defect_Desc "Defect Desc"';
    sGroupby := sGroupby + sDot + 'F.Defect_Code,F.Defect_Desc';
  end;

  if ChkReason then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'NVL(G.Reason_Code,''N/A'') "Reason Code",G.Reason_Desc "Reason Desc"';
    sGroupby := sGroupby + sDot + 'G.Reason_Code,G.Reason_Desc';
  end;

  if ChkDuty then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'NVL(H.Duty_Code,''N/A'') "Duty Code"';
    sGroupby := sGroupby + sDot + 'H.Duty_Code';
  end;

  if ChkLocation then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'NVL(B.Location,''N/A'') "Location"';
    sGroupby := sGroupby + sDot + 'B.Location';
  end;

  if sField = '' then Exit;

  if cmbMain.Text = '' then Exit;
  if cmbSecond.Text = cmbMain.Text then cmbSecond.ItemIndex := 0;
  sSQL := 'Select ' + sField + ', count(A.PART_SN) QTY ' +
    'From SAJET.G_KP_DEFECT_H A ' +
    ' ,SAJET.G_KP_DEFECT_D I ' +
    ' ,SAJET.G_KP_REPAIR B ' +
    ' ,SAJET.SYS_PDLINE C ' +
    ' ,SAJET.SYS_DEFECT F ' +
    ' ,SAJET.SYS_REASON G ' +
    ' ,SAJET.SYS_DUTY H ';
  if ChkProcess then
    sSQL := sSQL + ' ,SAJET.SYS_PROCESS D ';
  if (ChkPart) or (Trim(editPart.Text) <> '') or (ChkModel) or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_PART E ';
  if (ChkModel) or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_MODEL J ';
  sSQL := sSQL +
    'Where ' + SelectDate + GetClickData + '  and C.FACTORY_ID = ' + FcID +
    '  and A.PDLINE_ID = C.PDLINE_ID ';
  if ChkProcess then
    sSQL := sSQL + '  and A.PROCESS_ID = D.PROCESS_ID ';
  if (ChkPart) or (Trim(editPart.Text) <> '') or (ChkModel) or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and A.PART_ID = E.PART_ID ';
  if (ChkModel) or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and E.MODEL_ID = J.MODEL_ID(+) ';
  if Trim(editPart.Text) <> '' then
    if Pos('%', editPart.Text) <> 0 then
      sSQL := sSQL + ' and E.PART_NO Like ''' + Trim(editPart.Text) + ''' '
    else
      sSQL := sSQL + ' and E.PART_NO = ''' + Trim(editPart.Text) + ''' ';
  if Trim(editModel.Text) <> '' then
    if Pos('%', editModel.Text) <> 0 then
      sSQL := sSQL + ' and J.MODEL_NAME Like ''' + Trim(editModel.Text) + ''' '
    else
      sSQL := sSQL + ' and J.MODEL_NAME = ''' + Trim(editModel.Text) + ''' ';
  if Trim(combLine.Text) <> '' then sSQL := sSQL + ' and C.PDLINE_NAME = ''' + Trim(combLine.Text) + ''' ';
  sSQL := sSQL + ' and a.recid = i.recid and i.DEFECT_ID = F.DEFECT_ID ' +
    ' and A.RECID = B.RECID(+) ' +
    ' and B.REASON_ID = G.REASON_ID(+) ' +
    ' and B.DUTY_ID = H.DUTY_ID(+) '
    + AddCondition('A.PROCESS_ID', StrLstProcess)
    + AddCondition('A.PDLINE_ID', StrLstPdLine)
    + ' Group By ' + sGroupby;
  with TfData.Create(Self) do
  begin
    sQueryType := 'KPRepair';
    sSelectDate := SelectDate;
    if cmbChart.Text = 'Pareto' then
      GradPanel1.Caption := cmbMain.Text + ' : ' + Series.XLabel[ValueIndex]
    else
    begin
      if cmbSecond.Text = 'N/A' then
        GradPanel1.Caption := cmbMain.Text + ' : ' + Series.XLabel[ValueIndex]
      else
        GradPanel1.Caption := cmbMain.Text + ' : ' + StrGridTemp.Cells[0, ValueIndex + 1];
    end;
    bRecDate := chkDate;
    bLine := chkLine;
    bWO := chkWO;
    bPart := chkPart;
    bModel := chkModel;
    bDefectProcess := ChkProcess;
    bDefect := ChkDefect;
    bReason := ChkReason;
    bDuty := ChkDuty;
    bLocation := ChkLocation;
    DStyle := DateStyle;
    QryTemp2.RemoteServer := QryTemp.RemoteServer;
    QryTemp2.Close;
    QryTemp2.Params.Clear;
    QryTemp2.CommandText := sSQL;
    QryTemp2.Open;
    Showmodal;
    Free;
  end;
end;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
var sSQL, sField, sGroupby, sDot: string; i: Integer;
  col: Integer;
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
      end else if (StrLstSort.Strings[I] = 'Production Line') and chkLine then
      begin
        if Result = '' then
          Result := '"Production Line"'
        else
          Result := Result + ',"Production Line"';
      end else if (StrLstSort.Strings[I] = 'Work Order') and chkWO then
      begin
        if Result = '' then
          Result := '"Work Order"'
        else
          Result := Result + ',"Work Order"';
      end else if (StrLstSort.Strings[I] = 'Defect Info.') and chkDefect then
      begin
        if Result = '' then
          Result := '"Defect Code"'
        else
          Result := Result + ',"Defect Code"';
      end else if (StrLstSort.Strings[I] = 'Reason Info.') and ChkReason then
      begin
        if Result = '' then
          Result := '"Reason Code"'
        else
          Result := Result + ',"Reason Code"';
      end else if (StrLstSort.Strings[I] = 'Part No') and chkPart then
      begin
        if Result = '' then
          Result := '"Part No"'
        else
          Result := Result + ',"Part No"';
      end else if (StrLstSort.Strings[I] = 'Model Name') and chkModel then
      begin
        if Result = '' then
          Result := '"Model Name"'
        else
          Result := Result + ',"Model Name"';
      end else if (StrLstSort.Strings[I] = 'Duty') and ChkDuty then
      begin
        if Result = '' then
          Result := '"Duty Code"'
        else
          Result := Result + ',"Duty Code"';
      end else if (StrLstSort.Strings[I] = 'Location') and ChkLocation then
      begin
        if Result = '' then
          Result := '"Location"'
        else
          Result := Result + ',"Location"';
      end else if (StrLstSort.Strings[I] = 'Defect Process') and chkProcess then
      begin
        if Result = '' then
          Result := '"Defect Process"'
        else
          Result := Result + ',"Defect Process"';
      end else if (StrLstSort.Strings[I] = 'Process Code') and chkProcess then
      begin
        if Result = '' then
          Result := '"Process Code"'
        else
          Result := Result + ',"Process Code"';
      end else if (StrLstSort.Strings[I] = 'QTY') then
      begin
        if Result = '' then
          Result := 'QTY desc'
        else
          Result := Result + ',QTY desc';
      end;
    end;
  end;
begin
  DBGrid1.Visible := False;
  sField := '';
  sGroupby := '';
  sdot := '';
  if chkDate then
  begin
    if sField <> '' then sDot := ',';
    if DateStyle = 'Date' then
    begin
      sField := sField + sDot + 'TO_CHAR(a.REC_TIME,''YYYY/MM/DD'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(a.REC_TIME,''YYYY/MM/DD'')';
    end;
    if DateStyle = 'Week' then
    begin
      sField := sField + sDot + 'TO_CHAR(a.REC_TIME,''YYYY-WW'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(a.REC_TIME,''YYYY-WW'')';
    end;
    if DateStyle = 'Month' then
    begin
      sField := sField + sDot + 'TO_CHAR(a.REC_TIME,''YYYY/MM'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(a.REC_TIME,''YYYY/MM'')';
    end;
    if DateStyle = 'Year' then
    begin
      sField := sField + sDot + 'TO_CHAR(a.REC_TIME,''YYYY'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(a.REC_TIME,''YYYY'')';
    end;
  end;

  if chkLine then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'C.PdLine_Name "Production Line" ';
    sGroupby := sGroupby + sDot + 'C.PdLine_Name';
  end;

  if ChkWO then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'A.Work_Order "Work Order"';
    sGroupby := sGroupby + sDot + 'A.Work_Order';
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
    sField := sField + sDot + 'J.Model_Name "Model Name"';
    sGroupby := sGroupby + sDot + 'J.Model_Name';
  end;

  if ChkProcess then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'D.Process_Name "Defect Process"';
    sGroupby := sGroupby + sDot + 'D.Process_Name';

     //若有依Process Code排序,則需找出Process Code
    if StrLstSort.IndexOf('Process Code') > -1 then
    begin
      sField := sField + ',D.Process_Code "Process Code"';
      sGroupby := sGroupby + ',D.Process_Code';
    end;
  end;

  if ChkDefect then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'F.Defect_Code "Defect Code",F.Defect_Desc "Defect Desc"';
    sGroupby := sGroupby + sDot + 'F.Defect_Code,F.Defect_Desc';
  end;

  if ChkReason then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'NVL(G.Reason_Code,''N/A'') "Reason Code",G.Reason_Desc "Reason Desc"';
    sGroupby := sGroupby + sDot + 'G.Reason_Code,G.Reason_Desc';
  end;

  if ChkDuty then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'NVL(H.Duty_Code,''N/A'') "Duty Code"';
    sGroupby := sGroupby + sDot + 'H.Duty_Code';
  end;

  if ChkLocation then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'NVL(B.Location,''N/A'') "Location"';
    sGroupby := sGroupby + sDot + 'B.Location';
  end;

  if sField = '' then Exit;

  sSQL := 'Select ' + sField + ',count(part_sn) QTY ' +
    'From SAJET.G_KP_DEFECT_H A ' +
    ' ,SAJET.G_KP_DEFECT_D I ' +
    ' ,SAJET.G_KP_REPAIR B ' +
    ' ,SAJET.SYS_PDLINE C ' +
    ' ,SAJET.SYS_DEFECT F ' +
    ' ,SAJET.SYS_REASON G ' +
    ' ,SAJET.SYS_DUTY H ';
  if ChkProcess then
    sSQL := sSQL + ' ,SAJET.SYS_PROCESS D ';
  if ChkPart or (Trim(editPart.Text) <> '') or ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_PART E ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_Model J ';
  sSQL := sSQL + 'Where ' + SelectDate +
    '  and C.FACTORY_ID = ' + FcID +
    '  and A.PDLINE_ID = C.PDLINE_ID ';
  if ChkProcess then
    sSQL := sSQL + '  and A.PROCESS_ID = D.PROCESS_ID ';
  if ChkPart or (Trim(editPart.Text) <> '') or ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and A.PART_ID = E.PART_ID ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and E.Model_Id = J.Model_Id(+) ';
  if Trim(editPart.Text) <> '' then
    if Pos('%', editPart.Text) <> 0 then
      sSQL := sSQL + ' and E.PART_NO Like ''' + Trim(editPart.Text) + ''' '
    else
      sSQL := sSQL + ' and E.PART_NO = ''' + Trim(editPart.Text) + ''' ';
  if Trim(editModel.Text) <> '' then
    if Pos('%', editModel.Text) <> 0 then
      sSQL := sSQL + ' and J.MODEL_NAME Like ''' + Trim(editModel.Text) + ''' '
    else
      sSQL := sSQL + ' and J.MODEL_NAME = ''' + Trim(editModel.Text) + ''' ';
  if Trim(combLine.Text) <> '' then sSQL := sSQL + ' and C.PDLINE_NAME = ''' + Trim(combLine.Text) + ''' ';
  sSQL := sSQL + ' and a.recid = i.recid and i.DEFECT_ID = F.DEFECT_ID '
    + ' and A.RECID = B.RECID(+) '
    + ' and B.REASON_ID = G.REASON_ID(+) '
    + ' and B.DUTY_ID = H.DUTY_ID(+) '
    + AddCondition('A.PROCESS_ID', StrLstProcess)
    + AddCondition('A.PDLINE_ID', StrLstPdLine)
    + ' Group By ' + sGroupby;
  if StrLstSort.Count > 0 then
    sSQL := sSQL + ' Order By ' + SortData;

  for i := (Chart1.SeriesList.Count - 1) downto 0 do
    Chart1.Series[i].Free;
  GPRecords.Caption := '0';
  GPQty.Caption := '0';

  with QryData do
  begin
    Close;
    Params.Clear;
    CommandText := sSQL;
    Open;
    if not IsEmpty then
      RefreshData(True);
  end;
  for Col := 0 to DBGrid1.Columns.Count - 1 do
    if DBGrid1.Columns[Col].Width > 130 then
      DBGrid1.Columns[Col].Width := 130;
  sQueryCon := 'DateTime : '
    + FormatDateTime('yyyy/mm/dd', dtStart.Date) + ':' + cmbWSStart.Text + ' ~ '
    + FormatDateTime('yyyy/mm/dd', dtEnd.Date) + ':' + cmbWSEnd.Text;
  if Trim(editModel.Text) <> '' then
    sQueryCon := sQueryCon + '  Model:' + Trim(editModel.Text);
  if Trim(editPart.Text) <> '' then
    sQueryCon := sQueryCon + '  P/N:' + Trim(editPart.Text);
  if Trim(combLine.Text) <> '' then
    sQueryCon := sQueryCon + '  Line:' + Trim(combLine.Text);
  if StrLstProcessName.Count <> 0 then begin
    sQueryCon := sQueryCon + '  Process:' + StrLstProcessName[0];
    for i := 1 to StrLstProcessName.Count - 1 do
      sQueryCon := sQueryCon + ',' + StrLstProcessName[i];
  end;
  DBGrid1.Visible := True;
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

procedure TfDetail.DBGrid1DblClick(Sender: TObject);
var sSQL: string; 
  function GetCondition: string;
  begin
    Result := '';
    if chkDate then
    begin
      if DateStyle = 'Date' then
        Result := Result + ' and TO_CHAR(a.REC_TIME,''YYYY/MM/DD'') = ''' + QryData.Fieldbyname('Date').AsString + ''' ';
      if DateStyle = 'Week' then
        Result := Result + ' and TO_CHAR(a.REC_TIME,''YYYY-WW'') = ''' + QryData.Fieldbyname('Date').AsString + ''' ';
      if DateStyle = 'Month' then
        Result := Result + ' and TO_CHAR(a.REC_TIME,''YYYY/MM'') = ''' + QryData.Fieldbyname('Date').AsString + ''' ';
      if DateStyle = 'Year' then
        Result := Result + ' and TO_CHAR(a.REC_TIME,''YYYY'') = ''' + QryData.Fieldbyname('Date').AsString + ''' ';
    end;

    if chkLine then
      Result := Result + ' and C.PDLINE_NAME = ''' + QryData.Fieldbyname('Production Line').AsString + ''' ';
    if chkWO then
      Result := Result + ' and A.Work_Order = ''' + QryData.Fieldbyname('Work Order').AsString + ''' ';
    if chkPart then
      Result := Result + ' and E.Part_No = ''' + QryData.Fieldbyname('Part No').AsString + ''' ';
    if chkModel then
      if QryData.Fieldbyname('Model Name').AsString = '' then
        Result := Result + ' and K.Model_Name is null '
      else
        Result := Result + ' and K.Model_Name = ''' + QryData.Fieldbyname('Model Name').AsString + ''' ';
    if ChkProcess then
      Result := Result + ' and Process_Name = ''' + QryData.Fieldbyname('Defect Process').AsString + ''' ';
    if ChkDefect then
      Result := Result + ' and Defect_Code = ''' + QryData.Fieldbyname('Defect Code').AsString + ''' ';
    if ChkReason then
      Result := Result + ' and NVL(Reason_Code,''N/A'') = ''' + QryData.Fieldbyname('Reason Code').AsString + ''' ';
    if ChkDuty then
      Result := Result + ' and NVL(Duty_Code,''N/A'') = ''' + QryData.Fieldbyname('Duty Code').AsString + ''' ';
    if ChkLocation then
      Result := Result + ' and NVL(b.Location,''N/A'') = ''' + QryData.Fieldbyname('Location').AsString + ''' ';
  end;
begin
  if not QryData.Active then Exit;
  if QryData.Eof then Exit;
  sSQL := 'Select E.PART_NO "Part No",' +
    'A.PART_SN "Serial Number",' +
    'C.PDLINE_NAME "Production Line",' +
    'D.PROCESS_NAME "Defect Process",' +
    'A.REC_TIME "Process Time",' +
    'I.EMP_NAME "Employee" ' +
    'From SAJET.G_KP_DEFECT_H A ' +
    ' ,SAJET.G_KP_DEFECT_D j ' +
    ' ,SAJET.G_KP_REPAIR B ' +
    ' ,SAJET.SYS_PDLINE C ' +
    ' ,SAJET.SYS_PROCESS D ' +
    ' ,SAJET.SYS_PART E ' +
    ' ,SAJET.SYS_EMP I ';
  if (ChkDefect) then
    sSQL := sSQL + ' ,SAJET.SYS_DEFECT F ';
  if (ChkReason) then
    sSQL := sSQL + ' ,SAJET.SYS_REASON G ';
  if (ChkDuty) then
    sSQL := sSQL + ' ,SAJET.SYS_DUTY H ';
  if (ChkModel) or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_MODEL K ';
  sSQL := sSQL + 'Where ' + SelectDate + GetCondition +
    '  and C.FACTORY_ID = ' + FcID +
    '  and A.RECID = B.RECID(+) ' +
    '  and A.PDLINE_ID = C.PDLINE_ID ' +
    '  and A.PROCESS_ID = D.PROCESS_ID ' +
    '  and A.PART_ID = E.PART_ID ' +
    '  and A.TEST_EMP_ID = I.EMP_ID(+) ' +
    '  and a.recid = j.recid ';
  if (ChkModel) or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' and E.MODEL_ID = K.MODEL_ID(+) ';
  if Trim(editPart.Text) <> '' then
    if Pos('%', editPart.Text) <> 0 then
      sSQL := sSQL + ' and E.PART_NO Like ''' + Trim(editPart.Text) + ''' '
    else
      sSQL := sSQL + ' and E.PART_NO = ''' + Trim(editPart.Text) + ''' ';
  if Trim(editModel.Text) <> '' then
    if Pos('%', editModel.Text) <> 0 then
      sSQL := sSQL + ' and K.Model_Name Like ''' + Trim(editModel.Text) + ''' '
    else
      sSQL := sSQL + ' and K.Model_Name = ''' + Trim(editModel.Text) + ''' ';
  if Trim(combLine.Text) <> '' then sSQL := sSQL + ' and C.PDLINE_NAME = ''' + Trim(combLine.Text) + ''' ';
  if ChkDefect then
    sSQL := sSQL + ' and j.DEFECT_ID = F.DEFECT_ID ';
  if ChkReason then
    sSQL := sSQL + ' and B.REASON_ID = G.REASON_ID(+) ';
  if ChkDuty then
    sSQL := sSQL + ' and B.DUTY_ID = H.DUTY_ID(+) ';
  sSQL := sSQL
    + AddCondition('A.PROCESS_ID', StrLstProcess)
    + AddCondition('A.PDLINE_ID', StrLstPdLine)
    + 'Order by "Serial Number" ';

  with TfDataDetail.Create(Self) do
  begin
    GradPanel1.Caption := 'Detail Data';
    QuryDataDetail.RemoteServer := QryData.RemoteServer;
    QuryDataDetail.Close;
    QuryDataDetail.Params.Clear;
    QuryDataDetail.CommandText := sSQL;
    QuryDataDetail.Open;
    Showmodal;
    Free;
  end;
end;

procedure TfDetail.sbtnStyle2Click(Sender: TObject);
begin
  PageControl1.ActivePage := TabGlyph;
end;

procedure TfDetail.sbtnPrintClick(Sender: TObject);
var
  My_FileName: string;
  MsExcel, MsExcelWorkBook: Variant;
begin
  if not QryData.Active then Exit;
  if QryData.IsEmpty then Exit;

//  My_FileName:= ExtractFilePath(Application.EXEName)+ 'WIP.xlt';
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
//    showmessage('Save Excel OK!!');
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

