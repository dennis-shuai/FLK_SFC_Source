unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, ComCtrls, Spin, Db,
  DBClient, MConnect, ObjBrkr, IniFiles, SConnect, GradPanel, Menus, Variants,
  comobj, Clrgrid, ImgList, DBGrid1, DBGrids;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    Image2: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    QryTemp2: TClientDataSet;
    PageControl1: TPageControl;
    TabData: TTabSheet;
    GradPanel13: TGradPanel;
    Label18: TLabel;
    GPRecords: TGradPanel;
    GradPanel14: TGradPanel;
    Image7: TImage;
    sbtnSave: TSpeedButton;
    Image8: TImage;
    sbtnPrint: TSpeedButton;
    ImageTitle: TImage;
    Label3: TLabel;
    Label4: TLabel;
    DataSource1: TDataSource;
    SaveDialog1: TSaveDialog;
    lablDateFrom: TLabel;
    DTStart: TDateTimePicker;
    lablDateTo: TLabel;
    DTEnd: TDateTimePicker;
    LabReportName1: TLabel;
    Label8: TLabel;
    editLot: TEdit;
    Label10: TLabel;
    editPart: TEdit;
    cmbWSStart: TComboBox;
    cmbWSEnd: TComboBox;
    ImgLst: TImageList;
    DBGrid1: TDBGrid1;
    sbtnPart: TSpeedButton;
    Image1: TImage;
    SpeedButton1: TSpeedButton;
    lablModel: TLabel;
    editModel: TEdit;
    sbtnModel: TSpeedButton;
    Image3: TImage;
    sbtnQuery: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure sbtnStyle1Click(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnQueryClick(Sender: TObject);
    procedure sbtnPrintClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure sbtnPartClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure sbtnModelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    RpID, gsPath, gsSpec: string;
    gbChange, gbTitle: Boolean;
    UpdateUserID: string;
    SocketConnection1: TSocketConnection;
    procedure GetReportParams;
    procedure ShowReport;
    function DownloadSampleFile: string;
    function AddCondition(sField: string; sList: TStringList): string;
    procedure GetReportName;
    procedure GetWOData;
    procedure GetProcessData;
    procedure GetPartTypeData;
    procedure GetSpecField;
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
    procedure GetFactoryData;
  end;

var
  fDetail: TfDetail;
  ChkDate, chkProcess, ChkWO, ChkPart, ChkModel, chkLotNo: Boolean;
  DateStyle: string;
  ChartMain, ChartSecond: string;
  slFactoryID, StrLstWO, StrLstProcess, StrLstSort, StrLstPartType, G_tsDisplayField, StrLstProcessName: TStringList;
  sQueryCon: string;

implementation

{$R *.DFM}

uses uInspDetail, uCommData, uProcess;

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
    for j := 0 to DBGrid1.Columns.Count - 1 do
      MsExcel.Worksheets['Data'].Range[Chr(j + 65) + IntToStr(i + 2)].Value := QryData.Fields.Fields[J].AsString;
    QryData.Next;
  end;
  MsExcel.Run('Inspection');
end;

procedure TfDetail.GetReportName;
begin
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
      LabReportName1.Caption := Fieldbyname('RP_NAME').AsString;
    end;
    Close;
  end;
end;

procedure TfDetail.GetReportParams;
begin
  ChkDate := False;
  ChkProcess := False;
  ChkWO := False;
  ChkPart := False;
  ChkModel := False;
  ChkLotNo := False;
  StrLstWO.Clear;
  StrLstProcess.Clear;
  StrLstProcessName.Clear;
  StrLstSort.Clear;
  StrLstPartType.Clear;
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
        if Fieldbyname('PARAM_NAME').AsString = 'Work Order' then
          ChkWO := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Process' then
          ChkProcess := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Part Type' then
          ChkPart := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Model Name' then
          ChkModel := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Lot No' then
          ChkLotNo := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
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
//    GetWOData;
    GetProcessData;
//    GetPartTypeData;
  end;
end;

procedure TfDetail.GetWOData;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RPID', ptInput);
    CommandText := 'Select A.WORK_ORDER ' +
      'From SAJET.G_WO_BASE A, ' +
      'SAJET.SYS_REPORT_PARAM B ' +
      'Where B.RP_ID = :RPID and ' +
      'B.PARAM_TYPE = ''Query Condition'' and ' +
      'B.PARAM_NAME = ''WORK_ORDER'' and ' +
      'B.PARAM_VALUE = A.WORK_ORDER ' +
      'Order By A.WORK_ORDER ';
    Params.ParamByName('RPID').AsString := RpID;
    Open;
    StrLstWO.Clear;
    while not eof do
    begin
      StrLstWO.Add(Fieldbyname('WORK_ORDER').AsString);
      Next;
    end;
    Close;
  end;
end;

procedure TfDetail.GetProcessData;
begin
  if FileExists(fDetail.gsPath + fDetail.RpID + 'ID.Txt') then begin
    StrLstProcess.LoadFromFile(fDetail.gsPath + fDetail.RpID + 'ID.Txt');
    StrLstProcessName.LoadFromFile(fDetail.gsPath + fDetail.RpID + 'Name.Txt');
  end;
end;

procedure TfDetail.GetPartTypeData;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RPID', ptInput);
    CommandText := 'Select A.PART_NO ' +
      'From SAJET.SYS_PART A, ' +
      'SAJET.SYS_REPORT_PARAM B ' +
      'Where B.RP_ID = :RPID and ' +
      'B.PARAM_TYPE = ''Query Condition'' and ' +
      'B.PARAM_NAME = ''PART_TYPE'' and ' +
      'B.PARAM_VALUE = A.PART_NO ' +
      'Order By A.PART_NO ';
    Params.ParamByName('RPID').AsString := RpID;
    Open;
    StrLstPartType.Clear;
    while not eof do
    begin
      StrLstPartType.Add(Fieldbyname('PART_No').AsString);
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

procedure TfDetail.FormShow(Sender: TObject);
begin
  ShowReport;
end;

procedure TfDetail.ShowReport;
var sYear: string;
begin
  DTStart.DateTime := now;
  DTEnd.DateTime := now;
  QryData.Close;
  DBGrid1.Columns.Clear;
  GPRecords.Caption := '0';
  GetReportName;
  GetReportParams;
  GetFactoryData;
  GetSpecField;
  PageControl1.ActivePage := TabData;
  lablDateFrom.Visible := False;
  DTStart.Visible := lablDateFrom.Visible;
  DTEnd.Visible := lablDateFrom.Visible;
  lablDateTo.Visible := lablDateFrom.Visible;
  cmbWSStart.ItemIndex := 0;
  cmbWSEnd.ItemIndex := cmbWSEnd.Items.Count - 1;
  with qryTemp do
  begin
    try
      close;
      Params.Clear;
      commandText := 'Select to_char(sysdate,''yyyy'') This_Year from dual';
      open;
      sYear := FieldByname('This_Year').AsString;
    finally
      close;
    end;
  end;
  DTStart.DateTime := Now;
  DTEnd.DateTime := Now;
  lablDateFrom.Visible := True;
  DTStart.Visible := lablDateFrom.Visible;
  DTEnd.Visible := lablDateFrom.Visible;
  lablDateTo.Visible := lablDateFrom.Visible;
  G_tsDisplayField.Clear;
  with G_tsDisplayField do
  begin
    Add('WorkDate');
    Add('Insp Date');
    Add('WorkTime');
    Add('Insp Time');
    Add('Work Order');
    Add('Work Order');
    Add('Part Type');
    Add('Part Name');
    Add('Part No');
    Add('Part No');
    Add('Spec1');
    Add('Spec1');
    Add('Model Name');
    Add('Model Name');
    Add('Model Desc');
    Add('Model Desc');
    Add('Process');
    Add('Process');
    Add('Lot No');
    Add('Lot No');
    Add('Sampling Type');
    Add('Sampling Type');
    Add('Lot Size');
    Add('Lot Size');
    Add('Sample Qty');
    Add('Sample Qty');
    Add('Pass Qty');
    Add('Pass Qty');
    Add('Fail Qty');
    Add('Fail Qty');
    Add('Fail Rate(%)');
    Add('Fail Rate(%)');
    Add('QC_RESULT');
    Add('QC Result');
  end;
end;

procedure TfDetail.sbtnStyle1Click(Sender: TObject);
begin
  PageControl1.ActivePage := TabData;
end;

procedure TfDetail.sbtnSaveClick(Sender: TObject);
var
  sFileName, My_FileName: string;
  MsExcel, MsExcelWorkBook: Variant;
begin
  if (not qryData.active) or (qrydata.IsEmpty) then exit;
  try
    try

      My_FileName := DownLoadSampleFile;
      if not FileExists(My_FileName) then
      begin
        MessageDlg('Error!-The Excel File ' + My_FileName + ' can''t be found.', mtWarning, [mbOK], 0);
        exit;
      end;

      MsExcel := CreateOleObject('Excel.Application');
      MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);
      MsExcel.Worksheets['Data'].select;

      if Sender = sbtnSave then
      begin
        SaveDialog1.InitialDir := ExtractFilePath('C:\');
        SaveDialog1.DefaultExt := 'xls';
        SaveDialog1.Filter := 'Excel Files(*.xls)|*.xls';
        if not (SaveDialog1.Execute) then exit;
      end;
      SaveExcel(MsExcel, MsExcelWorkBook);
      if Sender = sbtnSave then
      begin
        sFileName := SaveDialog1.FileName;
        MsExcelWorkBook.SaveAs(sFileName);
        MessageDlg('Save Excel OK!!', mtInformation, [mbOK], 0);
      end
      else
      begin
        MsExcel.Visible := TRUE;
        MsExcel.WorkSheets['Report'].Select;
        MsExcel.WorkSheets['Report'].PrintPreview; //PrintOut;
      end;
    except
      MessageDlg('Could not start Microsoft Excel.', mtWarning, [mbOk], 0);
    end;
  finally
    MsExcelWorkBook.Close(False);
    MsExcel.Application.Quit;
    MsExcel := Null;
    try
      if FileExists(My_FileName) then Deletefile(My_FileName);
    except
    end;
  end;
end;

procedure TfDetail.FormCreate(Sender: TObject);
begin
  StrLstWO := TStringList.Create;
  StrLstProcess := TStringList.Create;
  StrLstProcessName := TStringList.Create;
  StrLstSort := TStringList.Create;
  StrLstPartType := TStringList.Create;
  G_tsDisplayField := TStringList.Create;
  gbChange := True;
  gsPath := ExtractFilePath(Application.ExeName);
end;

procedure TfDetail.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StrLstWO.Free;
  StrLstProcess.Free;
  StrLstProcessName.Free;
  StrLstSort.Free;
  slFactoryID.Free;
  StrLstPartType.Free;
  G_tsDisplayField.Free;
  Action := caFree;
end;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
var sSQL, sField, sGroupby, sDot, sSortData: string;
  i, iIndex, icolumn: Integer;

  function SortData(StrLstSort: TStringList): string;
  var I: Integer;
  begin
    Result := '';
    for I := 0 to StrLstSort.Count - 1 do
    begin
      if (StrLstSort.Strings[I] = 'Date') then
      begin
        if Result = '' then
          Result := '"WorkDate","WorkTime" '
        else
          Result := Result + ',"WorkDate","WorkTime"';
      end;
      if (StrLstSort.Strings[I] = 'Work Order') then
      begin
        if chkWo then
        begin
          if Result = '' then
            Result := '"Work Order"'
          else
            Result := Result + ',"Work Order"';
        end;
      end;
      if (StrLstSort.Strings[I] = 'Part No') then
      begin
        if chkPart then
        begin
          if Result = '' then
            Result := '"Part No"'
          else
            Result := Result + ',"Part No"';
        end;
      end;
      if (StrLstSort.Strings[I] = 'Model Name') then
      begin
        if chkModel then
        begin
          if Result = '' then
            Result := '"Model Name"'
          else
            Result := Result + ',"Model Name"';
        end;
      end;
      if (StrLstSort.Strings[I] = 'Process') then
      begin
        if chkProcess then
        begin
          if Result = '' then
            Result := '"Process"'
          else
            Result := Result + ',"Process"';
        end;
      end;
      if (StrLstSort.Strings[I] = 'Lot No') then
      begin
        if chkLotNo then
        begin
          if Result = '' then
            Result := '"Lot No"'
          else
            Result := Result + ',"Lot No"';
        end;
      end;
    end; //for

  end;
begin
  if QryData.Indexname <> '' then
    QryData.deleteIndex(QryData.Indexname);
  sField := '';
  sGroupby := '';
  sdot := '';
  GPRecords.Caption := '0';
  if chkDate then
  begin
    if sField <> '' then sDot := ',';
    if DateStyle = 'Date' then
    begin
      sField := sField + sDot + 'TO_CHAR(A.END_TIME,''YYYY/MM/DD'') "WorkDate" '
        + sDot + ',TO_CHAR(A.END_TIME,''HH24:MI:SS'') "WorkTime" ';
    end;
  end;

  if sField = '' then Exit;
  sSQL := 'select ' + sField;
  if chkWO then
    sSQL := sSQL + ' ,A.WORK_ORDER "Work Order" ';
  if chkPart then
    sSQL := sSQL + ' ,NVL(B.PART_NO,''N/A'') "Part No" ' + gsSpec;
  if chkModel then
    sSQL := sSQL + ' ,NVL(F.Model_NAme,''N/A'') "Model Name" ';
  if chkProcess then
    sSQL := sSQL + ' ,NVL(C.PROCESS_NAME,A.PROCESS_ID) "Process"  ';
  if chkLotNo then
    sSQL := sSQL + ' ,A.QC_LOTNO "Lot No", NVL(D.Sampling_Type,''N/A'') "Sampling Type" ';
  sSQL := sSQL + '     ,A.LOT_SIZE "Lot Size" ,A.SAMPLING_SIZE "Sample Qty", A.FAIL_QTY "Fail Qty" ,TRUNC((A.FAIL_QTY /Decode(A.SAMPLING_SIZE,0,1,A.SAMPLING_SIZE))*100,2) "Fail Rate(%)" '
    + '        ,DECODE(A.QC_RESULT,''2'',''Waive'',''1'',''Reject'' ,''0'',''Pass'',''N/A'',''Unknown'') QC_RESULT , A.NG_Cnt '
    + '  FROM SAJET.G_QC_LOT A '
    + '      ,SAJET.SYS_PART B '
    + '      ,SAJET.SYS_PROCESS C '
    + '      ,SAJET.SYS_QC_SAMPLING_PLAN D ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ', SAJET.SYS_MODEL F ';
  if (DateStyle = 'Date') then
    sSQL := sSQL + ' WHERE A.END_TIME Between to_date(:Time1,''yymmddhh24'') And to_date(:Time2,''yymmddhh24'') '
      + '   and A.END_TIME IS NOT NULL ';
  if ChkModel or (Trim(editModel.Text) <> '') then
    sSQL := sSQL + ' AND B.MODEL_ID = F.MODEL_ID(+) ';
  if Trim(editLot.Text) <> '' then
    sSQL := sSQL + ' and A.QC_LOTNO = ''' + Trim(editLot.Text) + ''' ';
  if Trim(editPart.Text) <> '' then
    sSQL := sSQL + ' and B.PART_NO = ''' + Trim(editPart.Text) + ''' ';
  if Trim(editModel.Text) <> '' then
    sSQL := sSQL + ' and F.MODEL_Name = ''' + Trim(editModel.Text) + ''' ';
  sSQL := sSQL
    + AddCondition('A.WORK_ORDER', StrLstWO)
    + AddCondition('A.PROCESS_ID', StrLstProcess)
    + AddCondition('B.PART_No', StrLstPartType)
    + ' AND A.MODEL_ID = B.PART_ID '
    + ' AND A.PROCESS_ID = C.PROCESS_ID '
    + ' And A.SAMPLING_PLAN_ID = D.Sampling_ID(+) ';

  if StrLstSort.Count > 0 then
  begin
    sSortData := SortData(StrLstSort);
    if sSortData = '' then
      sSQL := sSQL + ' ORDER BY A.END_TIME '
    else
      sSQL := sSQL + ' Order By ' + sSortData;
  end
  else
    sSQL := sSQL + ' ORDER BY A.END_TIME ';

  with qryData do
  begin
    try
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'time1', ptInput);
      Params.CreateParam(ftString, 'time2', ptInput);
      if (DateStyle = 'Date') then
      begin
        Params.ParamByName('time1').AsString := FormatDateTime('yyyymmdd', DTStart.date) + cmbWSStart.Text;
        if cmbWSEnd.ItemIndex = cmbWSEnd.Items.Count - 1 then
          Params.ParamByName('time2').AsString := FormatDateTime('yyyymmdd00', DTEnd.date + 1)
        else
          Params.ParamByName('time2').AsString := FormatDateTime('yyyymmdd', DTEnd.date) + cmbWSEnd.Text;
      end;
      CommandText := sSQL;
      Open;
      GPRecords.Caption := IntToStr(RecordCount);
    finally
    end;
  end; //with qrydata;


  for I := DBGrid1.Columns.Count - 1 downto 0 do
    DBGrid1.Columns.Delete(i);

  DBGrid1.DataSource := DataSource1;

  icolumn := 0;
  for I := 0 to qryData.fields.Count - 1 do
  begin
    iIndex := G_tsDisplayField.Indexof(qryData.Fields[i].FieldName);
    if (iIndex >= 0) then
    begin
      inc(iColumn);
      DBGrid1.Columns.add;
      DBGrid1.Columns[iColumn - 1].FieldName := qryData.Fields[i].FieldName;
      DBGrid1.Columns[iColumn - 1].Title.Caption := G_tsDisplayField.Strings[iIndex + 1];
      if DBGrid1.Columns[iColumn - 1].Width > 130 then
        DBGrid1.Columns[iColumn - 1].Width := 130;
    end;
  end;
  sQueryCon := 'DateTime : '
    + FormatDateTime('yyyy/mm/dd', dtStart.Date) + ':' + cmbWSStart.Text + ' ~ '
    + FormatDateTime('yyyy/mm/dd', dtEnd.Date) + ':' + cmbWSEnd.Text;
  if Trim(editModel.Text) <> '' then
    sQueryCon := sQueryCon + '   Model:' + Trim(editModel.Text);
  if Trim(editPart.Text) <> '' then
    sQueryCon := sQueryCon + '   P/N:' + Trim(editPart.Text);
  if Trim(editLot.Text) <> '' then
    sQueryCon := sQueryCon + '   Lot No:' + Trim(editLot.Text);
  if StrLstProcessName.Count <> 0 then begin
    sQueryCon := sQueryCon + '   Process:' + StrLstProcessName[0];
    for i := 1 to StrLstProcessName.Count - 1 do
      sQueryCon := sQueryCon + ',' + StrLstProcessName[i];
  end;
  if icolumn = 0 then
    DBGrid1.DataSource := nil;
end;

procedure TfDetail.sbtnPrintClick(Sender: TObject);
var
  My_FileName: string;
  MsExcel, MsExcelWorkBook: Variant;
begin
  if not QryData.Active then Exit;

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
  MsExcel.Application.Quit;
  MsExcel := Null;

  try
    if FileExists(My_FileName) then Deletefile(My_FileName);
  except end;

end;

procedure TfDetail.DBGrid1DblClick(Sender: TObject);
var sSQL: string;
begin
  if not QryData.Active then Exit;
  if QryData.Eof then Exit;
  sSQL := 'Select A.SERIAL_NUMBER "Serial Number"' +
    ',B.Customer_SN "Customer SN"' +
    ',A.QC_LotNo "Lot No"' +
    ',A.WORK_ORDER "Work Order"' +
    ',C.PART_NO "Part No"' + gsSpec +
    ',B.Carton_No "Carton No"' +
    ',B.Pallet_No "Pallet No"' +
    ',Decode(A.QC_Result,''0'',''OK'',''1'',''NG'',''Unknown'') "Insp Result"' +
    ',A.INSP_TIME "Inspection Time"' +
    ',D.EMP_NAME "Employee"' +
    ',A.QC_Cnt ' +
    'From SAJET.G_QC_SN A,' +
    ' SAJET.G_SN_Status B, ' +
    ' SAJET.SYS_PART C, ' +
    ' SAJET.SYS_EMP D ';
  sSQL := sSQL +
    'Where A.QC_LOTNO = ''' + QryData.FieldByName('Lot No').AsString + ''' ' +
    '  And A.QC_CNT = ''' + QryData.FieldByName('NG_Cnt').AsString + ''' ' +
    '  and A.Serial_Number = B.Serial_Number(+) ' +
    '  and A.MODEL_ID = C.PART_ID ';
  sSQL := sSQL + ' and A.INSP_EMP_ID = D.EMP_ID(+) ' +
    'Order by "Serial Number" ';

  with TfInspDetail.Create(Self) do
  begin
    GradPanel1.Caption := 'Detail Data';
    QuryInspDetail.RemoteServer := QryData.RemoteServer;
    QuryInspDefect.RemoteServer := QryData.RemoteServer;
    QuryInspDetail.Close;
    QuryInspDetail.Params.Clear;
    QuryInspDetail.CommandText := sSQL;
    QuryInspDetail.Open;
    DBGrid1.Columns[DBGrid1.Columns.Count - 1].Visible := False;
    Showmodal;
    Free;
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
      'SAJET.SYS_STAGE B, ' +
      'SAJET.SYS_OPERATE_TYPE c ' +
      'Where A.STAGE_ID = B.STAGE_ID ' +
      'and A.ENABLED = ''Y'' ' +
      'and B.ENABLED = ''Y'' ' +
      'and a.OPERATE_ID = c.OPERATE_ID ' +
      'and C.Type_Name = ''QC'' ' +
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

