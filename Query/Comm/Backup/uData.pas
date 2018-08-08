unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, Grids, DBGrids, ExtCtrls, GradPanel, Variants, comobj,
  Buttons, DBClient;

type
  TfData = class(TForm)
    GradPanel1: TGradPanel;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    GradPanel2: TGradPanel;
    Image7: TImage;
    sbtnSave: TSpeedButton;
    SaveDialog1: TSaveDialog;
    QryTemp2: TClientDataSet;
    procedure DBGrid1DblClick(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    bDate, bRecDate, bLine, bProcess, bTerminal, bWO, bModel, bShip: Boolean;
    bDefect, bReason, bItem, bDuty, bLocation, bShipDate, bDefectProcess: Boolean;
    DStyle: string;
    sQueryType: string;
    sDetailBase: string;
    sSelectDate: string;
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
  end;

var
  fData: TfData;

implementation

{$R *.DFM}
uses uDataDetail; //WIPDetailUnit

procedure TfData.DBGrid1DblClick(Sender: TObject);
var sSQL: string;
  function GetCondition: string;
  begin
    Result := '';
    if bDate then
    begin
      if DStyle = 'Date' then
        Result := Result + ' and TO_CHAR(OUT_PROCESS_TIME,''YYYY/MM/DD'') = ''' + QryTemp2.Fieldbyname('Date').AsString + ''' ';
      if DStyle = 'Week' then
        Result := Result + ' and TO_CHAR(OUT_PROCESS_TIME,''YYYY-WW'') = ''' + QryTemp2.Fieldbyname('Date').AsString + ''' ';
      if DStyle = 'Month' then
        Result := Result + ' and TO_CHAR(OUT_PROCESS_TIME,''YYYY/MM'') = ''' + QryTemp2.Fieldbyname('Date').AsString + ''' ';
      if DStyle = 'Year' then
        Result := Result + ' and TO_CHAR(OUT_PROCESS_TIME,''YYYY'') = ''' + QryTemp2.Fieldbyname('Date').AsString + ''' ';
    end;
    if bShipDate then
    begin
      if DStyle = 'Date' then
        Result := Result + ' and TO_CHAR(a.UPDATE_TIME,''YYYY/MM/DD'') = ''' + QryTemp2.Fieldbyname('Date').AsString + ''' ';
      if DStyle = 'Week' then
        Result := Result + ' and TO_CHAR(a.UPDATE_TIME,''YYYY-WW'') = ''' + QryTemp2.Fieldbyname('Date').AsString + ''' ';
      if DStyle = 'Month' then
        Result := Result + ' and TO_CHAR(a.UPDATE_TIME,''YYYY/MM'') = ''' + QryTemp2.Fieldbyname('Date').AsString + ''' ';
      if DStyle = 'Year' then
        Result := Result + ' and TO_CHAR(a.UPDATE_TIME,''YYYY'') = ''' + QryTemp2.Fieldbyname('Date').AsString + ''' ';
    end;
    if bRecDate then
    begin
      if DStyle = 'Date' then
        Result := Result + ' and TO_CHAR(REC_TIME,''YYYY/MM/DD'') = ''' + QryTemp2.Fieldbyname('Date').AsString + ''' ';
      if DStyle = 'Week' then
        Result := Result + ' and TO_CHAR(REC_TIME,''YYYY-WW'') = ''' + QryTemp2.Fieldbyname('Date').AsString + ''' ';
      if DStyle = 'Month' then
        Result := Result + ' and TO_CHAR(REC_TIME,''YYYY/MM'') = ''' + QryTemp2.Fieldbyname('Date').AsString + ''' ';
      if DStyle = 'Year' then
        Result := Result + ' and TO_CHAR(REC_TIME,''YYYY'') = ''' + QryTemp2.Fieldbyname('Date').AsString + ''' ';
    end;
    if bShip then
      Result := Result + ' and B.SHIPPING_NO = ''' + QryTemp2.Fieldbyname('Ship No').AsString + ''' ';
    if bLine then
      Result := Result + ' and C.PDLINE_NAME = ''' + QryTemp2.Fieldbyname('Production Line').AsString + ''' ';
    if bWO then
      Result := Result + ' and A.Work_Order = ''' + QryTemp2.Fieldbyname('Work Order').AsString + ''' ';
    if bDefectProcess then
      Result := Result + ' and D.PROCESS_NAME = ''' + QryTemp2.Fieldbyname('Defect Process').AsString + ''' ';
    if bProcess then
      Result := Result + ' and D.PROCESS_NAME = ''' + QryTemp2.Fieldbyname('Process Name').AsString + ''' ';
    if bModel then
      Result := Result + ' and E.Part_No = ''' + QryTemp2.Fieldbyname('Part No').AsString + ''' ';
    if bDefect then
      Result := Result + ' and Defect_Code = ''' + QryTemp2.Fieldbyname('Defect Code').AsString + ''' ';
    if bReason then
      Result := Result + ' and NVL(Reason_Code,''N/A'') = ''' + QryTemp2.Fieldbyname('Reason Code').AsString + ''' ';
    if bDuty then
      Result := Result + ' and NVL(Duty_Code,''N/A'') = ''' + QryTemp2.Fieldbyname('Duty Code').AsString + ''' ';
    if bLocation then
      Result := Result + ' and NVL(Location,''N/A'') = ''' + QryTemp2.FieldByName('Location').AsString + ''' ';
  end;
begin
  if not QryTemp2.Active then Exit;
  if QryTemp2.Eof then Exit;

  if sQueryType = 'WIP' then
    sSQL := 'Select A.WORK_ORDER "Work Order",' +
      'A.SERIAL_NUMBER "Serial Number",' +
      'A.CUSTOMER_SN "Customer SN",' +
      'C.PDLINE_NAME "Production Line",' +
      'D.PROCESS_NAME "Process",' +
      'A.OUT_PROCESS_TIME "Out Process Time",' +
      'F.EMP_NAME "Employee" ' +
      'From SAJET.G_SN_STATUS A,' +
      ' SAJET.G_WO_BASE B, ' +
      ' SAJET.SYS_PDLINE C, ' +
      ' SAJET.SYS_PROCESS D, ' +
      ' SAJET.SYS_PART E, ' +
      ' SAJET.SYS_EMP F ' +
      'Where B.WO_STATUS < ''5'' ' +
      '  and A.WORK_FLAG = ''0'' ' +
      '  and A.WORK_ORDER = B.WORK_ORDER and ' +
      'A.PDLINE_ID = C.PDLINE_ID and ' +
      'A.WIP_PROCESS = D.PROCESS_ID and ' +
      'B.MODEL_ID = E.PART_ID and ' +
      'A.EMP_ID = F.EMP_ID(+) ' +
      GetCondition +
      'Order by "Serial Number" '
  else if sQueryType = 'Shipping' then
    sSQL := 'Select b.SHIPPING_NO "Shipping No",' +
      'A.Pallet_No "Pallet No",' +
      'A.Carton_No "Carton No",' +
      'A.Box_No "Box No",' +
      'A.Customer_SN "Customer SN",' +
      'A.Serial_Number "Serial Number",' +
      'WIP_QTY "QTY",' +
      'A.UPDATE_TIME "Out Process Time",' +
      'F.EMP_NAME "Employee" ' +
      'From SAJET.G_SHIPPING_SN A,' +
      ' SAJET.G_SHIPPING_NO B, ' +
      ' SAJET.SYS_PART E, ' +
      ' SAJET.SYS_EMP F ' +
      'Where ' + sSelectDate
      + GetCondition +
      ' AND A.SHIPPING_ID = B.SHIPPING_ID ' +
      ' AND A.PART_ID = E.PART_ID ' +
      ' AND A.UPDATE_USERID = F.EMP_ID(+) ' +
      'Order by "Shipping No", "Pallet No", "Carton No", "Box No", "Serial Number" '
  else if sQueryType = 'ProcessOutput' then
    sSQL := 'Select A.WORK_ORDER "Work Order",' +
      'A.SERIAL_NUMBER "Serial Number",' +
      'A.CUSTOMER_SN "Customer SN",' +
      'C.PDLINE_NAME "Production Line",' +
      'D.PROCESS_NAME "Process",' +
      'A.OUT_PROCESS_TIME "Out Process Time",' +
      'F.EMP_NAME "Employee" ' +
      'From SAJET.G_SN_TRAVEL A,' +
      ' SAJET.G_WO_BASE B, ' +
      ' SAJET.SYS_PDLINE C, ' +
      ' SAJET.SYS_PROCESS D, ' +
      ' SAJET.SYS_PART E, ' +
      ' SAJET.SYS_EMP F ' +
      'Where ' + sSelectDate
      + GetCondition +
      '  and A.WORK_ORDER = B.WORK_ORDER and ' +
      'A.PDLINE_ID = C.PDLINE_ID and ' +
      'A.PROCESS_ID = D.PROCESS_ID and ' +
      'B.MODEL_ID = E.PART_ID and ' +
      'A.EMP_ID = F.EMP_ID(+) ' +
    'Order by "Serial Number" '
  else if sQueryType = 'WOOutput' then
    sSQL := 'Select A.WORK_ORDER "Work Order",' +
      'A.SERIAL_NUMBER "Serial Number",' +
      'A.CUSTOMER_SN "Customer SN",' +
      'C.PDLINE_NAME "Production Line",' +
      'D.PROCESS_NAME "Process",' +
      'A.OUT_PROCESS_TIME "Out Process Time",' +
      'F.EMP_NAME "Employee" ' +
      'From SAJET.G_SN_TRAVEL A,' +
      ' SAJET.G_WO_BASE B, ' +
      ' SAJET.SYS_PDLINE C, ' +
      ' SAJET.SYS_PROCESS D, ' +
      ' SAJET.SYS_PART E, ' +
      ' SAJET.SYS_EMP F ' +
      'Where ' + sSelectDate
      + GetCondition +
      '  and A.WORK_ORDER = B.WORK_ORDER and ' +
      'A.PROCESS_ID = B.END_PROCESS_ID and ' +
      'A.PDLINE_ID = C.PDLINE_ID and ' +
      'A.PROCESS_ID = D.PROCESS_ID and ' +
      'B.MODEL_ID = E.PART_ID and ' +
      'A.EMP_ID = F.EMP_ID(+) ' +
      'Order by "Serial Number" '
  else if sQueryType = 'Repair' then
    sSQL := 'Select A.WORK_ORDER "Work Order",' +
      'A.SERIAL_NUMBER "Serial Number",' +
      'C.PDLINE_NAME "Production Line",' +
      'D.PROCESS_NAME "Process",' +
      'A.REC_TIME "Process Time",' +
      'I.EMP_NAME "Employee", ' +
      'B.REMARK ' +
      'From SAJET.G_SN_DEFECT A,' +
      ' SAJET.G_SN_REPAIR B, ' +
      ' SAJET.SYS_PDLINE C, ' +
      ' SAJET.SYS_PROCESS D, ' +
      ' SAJET.SYS_PART E, ' +
      ' SAJET.SYS_DEFECT F, ' +
      ' SAJET.SYS_REASON G, ' +
      ' SAJET.SYS_DUTY H, ' +
      ' SAJET.SYS_EMP I ' +
      'Where ' + sSelectDate
      + GetCondition +
      '  and A.PDLINE_ID = C.PDLINE_ID and ' +
      'A.PROCESS_ID = D.PROCESS_ID and ' +
      'A.MODEL_ID = E.PART_ID and ' +
      'A.DEFECT_ID = F.DEFECT_ID and ' +
      'A.RECID = B.RECID(+) and ' +
      'B.REASON_ID = G.REASON_ID(+) and ' +
      'B.DUTY_ID = H.DUTY_ID(+) and ' +
      'A.TEST_EMP_ID = I.EMP_ID(+) ' //+
      + 'Order by "Serial Number" '
  else if sQueryType = 'KPRepair' then
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
      ' ,SAJET.SYS_DEFECT F ' +
      ' ,SAJET.SYS_REASON G ' +
      ' ,SAJET.SYS_DUTY H ' +
      ' ,SAJET.SYS_PART E ' +
      ' ,SAJET.SYS_EMP I ' +
      'Where ' + sSelectDate
      + GetCondition +
      '  and A.RECID = B.RECID(+) ' +
      '  and A.PDLINE_ID = C.PDLINE_ID ' +
      '  and A.PROCESS_ID = D.PROCESS_ID ' +
      '  and A.PART_ID = E.PART_ID ' +
      '  and A.TEST_EMP_ID = I.EMP_ID(+) ' +
      '  and a.recid = j.recid ' +
      '  and j.DEFECT_ID = F.DEFECT_ID ' +
      '  and B.REASON_ID = G.REASON_ID(+) ' +
      '  and B.DUTY_ID = H.DUTY_ID(+) ' +
      'Order by "Serial Number" '
  else if sQueryType = 'YieldRate' then
    sSQL := 'Select A.WORK_ORDER "Work Order",' +
      'A.SERIAL_NUMBER "Serial Number",' +
      'A.CUSTOMER_SN "Customer SN",' +
      'C.PDLINE_NAME "Production Line",' +
      'D.PROCESS_NAME "Process",' +
      'A.OUT_PROCESS_TIME "Out Process Time",' +
      'F.EMP_NAME "Employee" ' +
      'From SAJET.G_SN_TRAVEL A,' +
      ' SAJET.G_WO_BASE B, ' +
      ' SAJET.SYS_PDLINE C, ' +
      ' SAJET.SYS_PROCESS D, ' +
      ' SAJET.SYS_PART E, ' +
      ' SAJET.SYS_EMP F ' +
      'Where ' + sSelectDate
      + GetCondition +
      '  and A.WORK_ORDER = B.WORK_ORDER and ' +
      'A.PDLINE_ID = C.PDLINE_ID and ' +
      'A.PROCESS_ID = D.PROCESS_ID and ' +
      'B.MODEL_ID = E.PART_ID and ' +
      'A.EMP_ID = F.EMP_ID(+) ' +
      'Order by "Serial Number" ';

  with TfDataDetail.Create(Self) do
  begin
    GradPanel1.Caption := 'Detail Data';
    QuryDataDetail.RemoteServer := QryTemp2.RemoteServer;
    QuryDataDetail.Close;
    QuryDataDetail.Params.Clear;
    QuryDataDetail.CommandText := sSQL;
    QuryDataDetail.Open;
    Showmodal;
    Free;
  end;
end;

procedure TfData.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var i, j: integer;
begin
  for i := 0 to DBGrid1.Columns.Count - 1 do
    MsExcel.Worksheets['Sheet1'].Cells[1, i + 1] := DBGrid1.Columns[i].Title.Caption;

  QryTemp2.First;
  for i := 0 to QryTemp2.RecordCount - 1 do
  begin
    for j := 0 to QryTemp2.FieldCount - 1 do
      MsExcel.Worksheets['Sheet1'].Cells[i + 2, j + 1] := QryTemp2.Fields.Fields[J].AsString;
    QryTemp2.Next;
  end;
end;

procedure TfData.sbtnSaveClick(Sender: TObject);
var sFileName: string;
  MsExcel, MsExcelWorkBook: Variant;
begin
  if not QryTemp2.Active then Exit;
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'xls';
  SaveDialog1.Filter := 'All Files(*.xls)|*.xls';

  if SaveDialog1.Execute then
  begin
    try
      sFileName := SaveDialog1.FileName;
      MsExcel := CreateOleObject('Excel.Application');
      MsExcelWorkBook := MsExcel.WorkBooks.add;

      MsExcel.Worksheets['Sheet1'].select;
      SaveExcel(MsExcel, MsExcelWorkBook);
      MsExcelWorkBook.SaveAs(sFileName);
      showmessage('Save Excel OK!!');
    except
      ShowMessage('Could not start Microsoft Excel.');
    end;
    MsExcel.Application.Quit;
    MsExcel := Null;
  end
  else
    MessageDlg('You did not Save Any Data', mtWarning, [mbok], 0);
end;

procedure TfData.FormCreate(Sender: TObject);
begin
  sDetailBase := '';
  sSelectDate := '';
end;

end.

