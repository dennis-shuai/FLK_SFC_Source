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
    SpeedButton5: TSpeedButton;
    Image2: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    QryTemp2: TClientDataSet;
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
    TabGlyph: TTabSheet;
    Chart1: TChart;
    LabReportName: TLabel;
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
    StrPlato: TStringGrid;
    ImageTitle: TImage;
    Label3: TLabel;
    Label4: TLabel;
    sbtnStyle1: TSpeedButton;
    DataSource1: TDataSource;
    PopupMenu1: TPopupMenu;
    SaveImage1: TMenuItem;
    Copy1: TMenuItem;
    SaveDialog1: TSaveDialog;
    sbtnStyle2: TSpeedButton;
    Label6: TLabel;
    DTStart: TDateTimePicker;
    Label7: TLabel;
    DTEnd: TDateTimePicker;
    LabReportName1: TLabel;
    Label9: TLabel;
    editShip: TEdit;
    Label10: TLabel;
    editPart: TEdit;
    cmbWSStart: TComboBox;
    cmbWSEnd: TComboBox;
    sbtnWo: TSpeedButton;
    sbtnPart: TSpeedButton;
    ImgLst: TImageList;
    DBGrid1: TDBGrid1;
    Image3: TImage;
    sbtnQuery: TSpeedButton;
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
    procedure sbtnStyle2Click(Sender: TObject);
    procedure sbtnPrintClick(Sender: TObject);
    procedure sbtnWoClick(Sender: TObject);
    procedure sbtnPartClick(Sender: TObject);
    procedure cmbSecondChange(Sender: TObject);
    procedure sbtnModelClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    RpID: string;
    UpdateUserID, gsSpec: string;
    SocketConnection1: TSocketConnection;
    gbBox: Boolean;
    procedure GetReportParams;
    function DownloadSampleFile: string;
    function AddCondition(sField: string; sList: TStringList): string;
    function SelectField(Str, StrFunction: string): string;
    procedure GetReportName;
    procedure GetPartData;
    procedure GetSpecField;
    function SelectDate: string;
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
    procedure RefreshData(bRefreshYR: Boolean);
  end;

var
  fDetail: TfDetail;
  FcId: String;
  ChkDate, ChkPart, ChkShip, ChkModel: Boolean;
  DateStyle: string;
  ChartMain, ChartSecond: string;
  StrLstPart, StrLstSort: TStringList;
  sQueryCon: string;

implementation

{$R *.DFM}

uses uData, uDataDetail, uCommData;

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
  ChkPart := False;
  ChkModel := False;
  ChkShip := False;
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
          ChkDate := (Fieldbyname('PARAM_VALUE').AsString = 'Y')
        else if Fieldbyname('PARAM_NAME').AsString = 'Part No' then
          ChkPart := (Fieldbyname('PARAM_VALUE').AsString = 'Y')
        else if Fieldbyname('PARAM_NAME').AsString = 'Model Name' then
          ChkModel := (Fieldbyname('PARAM_VALUE').AsString = 'Y')
        else if Fieldbyname('PARAM_NAME').AsString = 'Ship No' then
          ChkShip := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
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
    GetPartData;
  end;
end;

function TfDetail.SelectDate: string;
begin
  Result := ' (A.UPDATE_TIME between to_date(''' + FormatDateTime('yyyymmdd', DTStart.Date) + cmbWSStart.Text + ''',''yyyymmddhh24'') ';
  if cmbWSEnd.ItemIndex = cmbWSEnd.Items.Count - 1 then
    Result := Result + ' and to_date(''' + FormatDateTime('yyyymmdd', DTEnd.Date + 1) + ''',''yyyymmdd'')) '
  else
    Result := Result + ' and to_date(''' + FormatDateTime('yyyymmdd', DTEnd.Date) + cmbWSEnd.Text + ''',''yyyymmddhh24'')) ';
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
//      Showmessage(rpID);
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
  StrLstPart := TStringList.Create;
  StrLstSort := TStringList.Create;
end;

procedure TfDetail.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StrLstPart.Free;
  StrLstSort.Free;
  Action := caFree;
end;

function TfDetail.SelectField(Str, StrFunction: string): string;
begin
  Result := 'PART_NO';
  if Str = 'Production Line' then Result := 'PDLINE_NAME';
  if Str = 'Part No' then Result := 'PART_NO';
  if Str = 'Work Order' then Result := 'A.WORK_ORDER';
  if Str = 'Ship No' then Result := 'SHIPPING_NO';
  if Str = 'Date' then
  begin
    if DateStyle = 'Date' then
      Result := 'TO_CHAR(A.UPDATE_TIME,''YYYY/MM/DD'')';
    if DateStyle = 'Week' then
      Result := 'TO_CHAR(A.UPDATE_TIME,''YYYY-WW'')';
    if DateStyle = 'Month' then
      Result := 'TO_CHAR(A.UPDATE_TIME,''YYYY/MM'')';
    if DateStyle = 'Year' then
      Result := 'TO_CHAR(A.UPDATE_TIME,''YYYY'')';
    if StrFunction = 'Field' then
    begin
      Result := Result + '  "Out Process Time" ';
    end;
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
var sField, sField2, sTemp, sTemp1: string;
  i, j: Integer; sMain, sSecond: TStringList;
  procedure DecodeQty(sTemp: string; var sPass, sFail: integer);
  begin
    sPass := StrToIntDef(Copy(sTemp, 1, Pos(#13, sTemp) - 1), 0);
    sFail := StrToIntDef(Copy(sTemp, Pos(#13, sTemp) + 1, Length(sTemp)), 0);
  end;
  function SelectField(Str: string): string;
  begin
    if Str = 'Defect Info.' then
      Result := 'Defect Code'
    else if Str = 'Reason Info.' then
      Result := 'Reason Code'
    else
      Result := Str;
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
      if StrToIntDef(StrPlato.Cells[1, i], 0) < StrToIntDef(StrPlato.Cells[1, j], 0) then
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
var i, J, mTotal, mC: Integer;
  function NewSeries: TChartSeries;
  begin
    if cmbChart.Text = 'Bar' then Result := TBarSeries.Create(Chart1);
    if cmbChart.Text = 'Line' then Result := TLineSeries.Create(Chart1);
    if cmbChart.Text = 'Pie' then Result := TPieSeries.Create(Chart1);
  end;
begin
  if cmbChart.Text = 'Pareto' then
  begin
    for i := (Chart1.SeriesList.Count - 1) downto 0 do
      Chart1.Series[i].Free;

    mTotal := 0;
    for i := 0 to StrPlato.RowCount - 1 do
      mTotal := mTotal + StrToIntDef(StrPlato.Cells[1, i], 0);

    Chart1.AddSeries(TBarSeries.Create(Chart1));
    Chart1.Series[0].Title := 'Qty';
    Chart1.Series[0].VertAxis := aRightAxis;
    for i := 0 to StrPlato.RowCount - 1 do
      Chart1.Series[0].Add((StrToIntDef(StrPlato.Cells[1, i], 0) / mTotal) * 100, StrPlato.Cells[0, i]);

    Chart1.AddSeries(TLineSeries.Create(Chart1));
    Chart1.Series[1].VertAxis := aRightAxis;
    Chart1.Series[1].Title := 'Accumulation';
    mC := 0;
    for i := 0 to StrPlato.RowCount - 1 do
    begin
      mC := mC + StrToIntDef(StrPlato.Cells[1, i], 0);
      Chart1.Series[1].Add((mC / mTotal) * 100, StrPlato.Cells[0, i]);
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
        Chart1.Series[0].Add(StrToIntDef(StrGrid.Cells[1, i], 0), StrGrid.Cells[0, i]);

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
          Chart1.Series[j - 1].Add(StrToIntDef(StrGrid.Cells[j, i], 0), StrGrid.Cells[0, i]);
        end;
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
    Result := ' and ' + SelectField(cmbMain.Text, 'Groupby') + ' = ''' + Series.XLabel[ValueIndex] + ''' '
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

  sField := sField + sDot + 'F.SHIPPING_NO "Ship No", B.Customer_Name "Cust Name"';
  sGroupby := sGroupby + sDot + 'F.SHIPPING_NO, B.Customer_Name';

  if chkDate then
  begin
    if sField <> '' then sDot := ',';
    if DateStyle = 'Date' then
    begin
      sField := sField + sDot + 'TO_CHAR(A.UPDATE_TIME,''YYYY/MM/DD'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(A.UPDATE_TIME,''YYYY/MM/DD'')';
    end;
    if DateStyle = 'Week' then
    begin
      sField := sField + sDot + 'TO_CHAR(A.UPDATE_TIME,''YYYY-WW'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(A.UPDATE_TIME,''YYYY-WW'')';
    end;
    if DateStyle = 'Month' then
    begin
      sField := sField + sDot + 'TO_CHAR(A.UPDATE_TIME,''YYYY/MM'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(A.UPDATE_TIME,''YYYY/MM'')';
    end;
    if DateStyle = 'Year' then
    begin
      sField := sField + sDot + 'TO_CHAR(A.UPDATE_TIME,''YYYY'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(A.UPDATE_TIME,''YYYY'')';
    end;
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
    sField := sField + sDot + 'G.Model_Name "Model Name"';
    sGroupby := sGroupby + sDot + 'G.Model_Name';
  end;

  if sField = '' then Exit;

  sSQL := 'Select ' + sField + ', Sum(WIP_QTY) QTY ' + //',Count(SERIAL_NUMBER) QTY '+
    'From SAJET.G_Shipping_SN A ';
  if ChkPart or (Trim(editPart.Text) <> '') or ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_PART E ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_MODEL G ';
  sSQL := sSQL + ', SAJET.G_SHIPPING_NO F ' +
    ' ,SAJET.SYS_CUSTOMER B ';
  sSQL := sSQL + 'Where ' + SelectDate
    + GetClickData;
  if ChkPart or (Trim(editPart.Text) <> '') or ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and A.PART_ID = E.PART_ID ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and E.MODEL_ID = G.MODEL_ID(+) ';
  sSQL := sSQL + '  and A.SHIPPING_ID = F.SHIPPING_ID ' +
    '  and F.SHIP_CUST = B.CUSTOMER_ID(+) ';
  if Trim(editPart.Text) <> '' then
    if Pos('%', editPart.Text) <> 0 then
      sSQL := sSQL + ' and E.PART_NO Like ''' + Trim(editPart.Text) + ''' '
    else
      sSQL := sSQL + ' and E.PART_NO = ''' + Trim(editPart.Text) + ''' ';
  if Trim(editModel.Text) <> '' then
    if Pos('%', editModel.Text) <> 0 then
      sSQL := sSQL + ' and G.Model_Name Like ''' + Trim(editModel.Text) + ''' '
    else
      sSQL := sSQL + ' and G.Model_Name = ''' + Trim(editModel.Text) + ''' ';
  sSQL := sSQL + ' Group By ' + sGroupby;

  with TfData.Create(Self) do
  begin
    sQueryType := 'Shipping';
    sSelectDate := SelectDate;
    if cmbSecond.Text = 'N/A' then
      GradPanel1.Caption := cmbMain.Text + ' : ' + StrGridTemp.Cells[0, ValueIndex]
    else
      GradPanel1.Caption := cmbMain.Text + ' : ' + StrGridTemp.Cells[0, ValueIndex + 1];
    bShipDate := ChkDate;
    bShip := True;
    bPart := chkPart;
    bModel := chkModel;
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
      if (StrLstSort.Strings[I] = 'Ship No') and chkShip then
      begin
        if Result = '' then
          Result := '"Ship No"'
        else
          Result := Result + ',"Ship No"';
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
      sField := sField + sDot + 'TO_CHAR(a.UPDATE_TIME,''YYYY/MM/DD'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(A.UPDATE_TIME,''YYYY/MM/DD'')';
    end;
    if DateStyle = 'Week' then
    begin
      sField := sField + sDot + 'TO_CHAR(a.UPDATE_TIME,''YYYY-WW'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(A.UPDATE_TIME,''YYYY-WW'')';
    end;
    if DateStyle = 'Month' then
    begin
      sField := sField + sDot + 'TO_CHAR(a.UPDATE_TIME,''YYYY/MM'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(A.UPDATE_TIME,''YYYY/MM'')';
    end;
    if DateStyle = 'Year' then
    begin
      sField := sField + sDot + 'TO_CHAR(a.UPDATE_TIME,''YYYY'') "Date" ';
      sGroupby := sGroupby + sDot + 'TO_CHAR(A.UPDATE_TIME,''YYYY'')';
    end;
  end;

  if ChkShip then
  begin
    if sField <> '' then sDot := ',';
    sField := sField + sDot + 'F.Shipping_No "Ship No", B.Customer_Name "Cust Name"';
    sGroupby := sGroupby + sDot + 'F.Shipping_No, B.Customer_Name';
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
    sField := sField + sDot + 'G.Model_Name "Model Name"';
    sGroupby := sGroupby + sDot + 'G.Model_Name';
  end;

  if sField = '' then Exit;

  sSQL := 'Select ' + sField + ', Sum(WIP_QTY) QTY ';
  sSQL := sSQL + 'From SAJET.G_Shipping_SN A ';
  if ChkPart or (Trim(editPart.Text) <> '') or ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_PART E ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_MODEL G ';
  if ChkShip then
    sSQL := sSQL + ' ,SAJET.G_SHIPPING_NO F '
      + ' ,SAJET.SYS_CUSTOMER B ';
  sSQL := sSQL + 'Where ' + SelectDate;
  if ChkPart or (Trim(editPart.Text) <> '') or ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and A.PART_ID = E.PART_ID ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and E.MODEL_ID = G.MODEL_ID(+) ';
  if ChkShip then
    sSQL := sSQL + '  and A.SHIPPING_ID = F.SHIPPING_ID ' +
      '  and F.SHIP_CUST = B.CUSTOMER_ID(+) ';
  if Trim(editPart.Text) <> '' then
    if Pos('%', editPart.Text) <> 0 then
      sSQL := sSQL + ' and E.PART_NO Like ''' + Trim(editPart.Text) + ''' '
    else
      sSQL := sSQL + ' and E.PART_NO = ''' + Trim(editPart.Text) + ''' ';
  if Trim(editModel.Text) <> '' then
    if Pos('%', editModel.Text) <> 0 then
      sSQL := sSQL + ' and G.Model_Name Like ''' + Trim(editModel.Text) + ''' '
    else
      sSQL := sSQL + ' and G.Model_Name = ''' + Trim(editModel.Text) + ''' ';
  sSQL := sSQL + ' Group By ' + sGroupby;

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

  sQueryCon := 'DateTime : '
    + FormatDateTime('yyyy/mm/dd', dtStart.Date) + ':' + cmbWSStart.Text + ' ~ '
    + FormatDateTime('yyyy/mm/dd', dtEnd.Date) + ':' + cmbWSEnd.Text;
  if Trim(editModel.Text) <> '' then
    sQueryCon := sQueryCon + '  Model:' + Trim(editModel.Text);
  if Trim(editPart.Text) <> '' then
    sQueryCon := sQueryCon + '  P/N:' + Trim(editPart.Text);
  if Trim(editShip.Text) <> '' then
    sQueryCon := sQueryCon + '  Ship No:' + Trim(editShip.Text);
  for i := 0 to DBGrid1.Columns.Count - 1 do
    if DBGrid1.Columns[i].Width > 130 then
      DBGrid1.Columns[i].Width := 130;
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
        Result := Result + ' and TO_CHAR(A.UPDATE_TIME,''YYYY/MM/DD'') = ''' + QryData.Fieldbyname('Date').AsString + ''' ';
      if DateStyle = 'Week' then
        Result := Result + ' and TO_CHAR(A.UPDATE_TIME,''YYYY-WW'') = ''' + QryData.Fieldbyname('Date').AsString + ''' ';
      if DateStyle = 'Month' then
        Result := Result + ' and TO_CHAR(A.UPDATE_TIME,''YYYY/MM'') = ''' + QryData.Fieldbyname('Date').AsString + ''' ';
      if DateStyle = 'Year' then
        Result := Result + ' and TO_CHAR(A.UPDATE_TIME,''YYYY'') = ''' + QryData.Fieldbyname('Date').AsString + ''' ';
    end;
    if chkPart then
      Result := Result + ' and E.Part_No = ''' + QryData.Fieldbyname('Part No').AsString + ''' ';
    if chkModel then
      if QryData.Fieldbyname('Model Name').AsString = '' then
        Result := Result + ' and G.Model_Name is null '
      else
        Result := Result + ' and G.Model_Name = ''' + QryData.Fieldbyname('Model Name').AsString + ''' ';
    if chkShip then
      Result := Result + ' and D.Shipping_no = ''' + QryData.Fieldbyname('Ship No').AsString + ''' ';
  end;
begin
  if not QryData.Active then Exit;
  if QryData.Eof then Exit;
  sSQL := 'Select D.SHIPPING_NO "Shipping No",' +
    'A.Pallet_No "Pallet No",' +
    'A.Carton_No "Carton No",' +
    'A.Box_No "Box No",' +
    'A.Customer_SN "Customer SN",' +
    'A.Serial_Number "Serial Number",' +
    'WIP_QTY "QTY",' +
    'A.UPDATE_TIME "Out Process Time",' +
    'F.EMP_NAME "Employee" ' +
    'From SAJET.G_Shipping_SN A,' +
    ' SAJET.SYS_EMP F ';
  if ChkPart or (Trim(editPart.Text) <> '') or ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_PART E ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' ,SAJET.SYS_MODEL G ';
  sSQL := sSQL + ' ,SAJET.G_SHIPPING_NO D ';
  sSQL := sSQL + 'Where ' + SelectDate
    + GetCondition;
  if ChkPart or (Trim(editPart.Text) <> '') or ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and A.PART_ID = E.PART_ID ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + '  and E.MODEL_ID = G.MODEL_ID(+) ';
  sSQL := sSQL + '  and A.SHIPPING_ID = D.SHIPPING_ID ';
  if Trim(editShip.Text) <> '' then
    sSQL := sSQL + ' and A.Shipping_No = ''' + Trim(editShip.Text) + ''' ';
  if Trim(editPart.Text) <> '' then
    if Pos('%', editPart.Text) <> 0 then
      sSQL := sSQL + ' and E.PART_NO Like ''' + Trim(editPart.Text) + ''' '
    else
      sSQL := sSQL + ' and E.PART_NO = ''' + Trim(editPart.Text) + ''' ';
  if Trim(editModel.Text) <> '' then
    if Pos('%', editModel.Text) <> 0 then
      sSQL := sSQL + ' and G.Model_Name Like ''' + Trim(editModel.Text) + ''' '
    else
      sSQL := sSQL + ' and G.Model_Name = ''' + Trim(editModel.Text) + ''' ';
  sSQL := sSQL + ' and A.update_userID = F.EMP_ID(+) '
    + 'Order by "Shipping No", "Pallet No", "Carton No", "Box No", "Serial Number" ';

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

procedure TfDetail.sbtnWoClick(Sender: TObject);
begin
  with TfCommData.Create(Self) do
  begin
    LabType2.Caption := 'Shipping No List';
    LabType1.Caption := LabType2.Caption;
    Label1.Caption := 'Search Shipping No';
    with QryTemp do
    begin
      Close;
      Params.Clear;
      if editShip.Text <> '' then
        Params.CreateParam(ftString, 'shipping_no', ptInput);
      CommandText := 'select shipping_no "Shipping No", Customer_Name "Customer", '
        + 'ship_to "Ship To" '
        + 'from sajet.g_shipping_No a, sajet.sys_customer b '
        + 'where a.ship_cust = b.customer_id ';
      if editShip.Text <> '' then
        CommandText := CommandText + 'and shipping_no like :shipping_no ';
      CommandText := CommandText + 'order by shipping_no ';
      if editShip.Text <> '' then
        Params.ParamByName('shipping_no').AsString := editShip.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      editShip.Text := QryTemp.FieldByName('Shipping No').AsString;
      QryTemp.Close;
      editShip.SetFocus;
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

