unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, Grids, DBGrids, ExtCtrls, GradPanel, Variants, comobj,
  Buttons, DBClient, DBGrid1, StdCtrls;

type
  TfData = class(TForm)
    GradPanel1: TGradPanel;
    DataSource1: TDataSource;
    GradPanel2: TGradPanel;
    SaveDialog1: TSaveDialog;
    QryTemp2: TClientDataSet;
    Label18: TLabel;
    GPRecords: TGradPanel;
    Image1: TImage;
    sbtnClose: TSpeedButton;
    sbtnSave: TSpeedButton;
    Image7: TImage;
    DBGrid1: TDBGrid1;
    procedure DBGrid1DblClick(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnCloseClick(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
  private
    { Private declarations }
  public
    { Public declarations }
    bDate, bRecDate, bLine, bProcess, bTerminal, bWO, bModel, bShip, bPart: Boolean;
    bDefect, bReason, bItem, bDuty, bLocation, bShipDate, bDefectProcess: Boolean;
    bCustomer, bWip, bNew: Boolean;
    DStyle, gsColumn, sLotNo, sShipNo, sWo, sLine, sProcess: string;
    sQueryType: string;
    sDetailBase: string;
    sSelectDate: string;
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
  end;

var
  fData: TfData;

implementation

{$R *.DFM}
uses uDataDetail, uDetail, uInspDetail;

procedure TfData.DBGrid1DblClick(Sender: TObject);
var sSQL: string; Col: Integer;
  function GetCondition: string;
  var sField: string;
  begin
    Result := '';
    if bDate then
    begin
      if sQueryType <> 'Inspection' then
      begin
        if DStyle = 'Date' then
          Result := Result + ' and TO_CHAR(OUT_PROCESS_TIME,''YYYY/MM/DD'') = ''' + QryTemp2.Fieldbyname(DateStyle).AsString + ''' '
        else if DStyle = 'Week' then
          Result := Result + ' and TO_CHAR(OUT_PROCESS_TIME,''IYYY-IW'') = ''' + QryTemp2.Fieldbyname(DateStyle).AsString + ''' '
        else if DStyle = 'Month' then
          Result := Result + ' and TO_CHAR(OUT_PROCESS_TIME,''YYYY/MM'') = ''' + QryTemp2.Fieldbyname(DateStyle).AsString + ''' '
        else if DStyle = 'Year' then
          Result := Result + ' and TO_CHAR(OUT_PROCESS_TIME,''YYYY'') = ''' + QryTemp2.Fieldbyname(DateStyle).AsString + ''' '
        else if DStyle = 'Quarter' then
          Result := Result + ' and TO_CHAR(OUT_PROCESS_TIME,''YYYY_Q'') = ''' + QryTemp2.Fieldbyname(DateStyle).AsString + ''' ';
      end else begin
        if DStyle = 'Date' then
          Result := Result + ' and TO_CHAR(START_TIME,''YYYY/MM/DD'') = ''' + QryTemp2.Fieldbyname('Work Date').AsString + ''' '
        else if DStyle = 'Week' then
          Result := Result + ' and TO_CHAR(START_TIME,''IYYY-IW'') = ''' + QryTemp2.Fieldbyname('Work Date').AsString + ''' '
        else if DStyle = 'Month' then
          Result := Result + ' and TO_CHAR(START_TIME,''YYYY/MM'') = ''' + QryTemp2.Fieldbyname('Work Date').AsString + ''' '
        else if DStyle = 'Year' then
          Result := Result + ' and TO_CHAR(START_TIME,''YYYY'') = ''' + QryTemp2.Fieldbyname('Work Date').AsString + ''' '
        else if DStyle = 'Quarter' then
          Result := Result + ' and TO_CHAR(START_TIME,''YYYY_Q'') = ''' + QryTemp2.Fieldbyname('Work Date').AsString + ''' ';
      end;
    end;
    if bShipDate then
    begin
      if bNew then sField := DStyle else sField := 'Date';
      if DStyle = 'Date' then
        Result := Result + ' and TO_CHAR(a.UPDATE_TIME,''YYYY/MM/DD'') = ''' + QryTemp2.Fieldbyname(sField).AsString + ''' '
      else if DStyle = 'Week' then
        Result := Result + ' and TO_CHAR(a.UPDATE_TIME,''IYYY-IW'') = ''' + QryTemp2.Fieldbyname(sField).AsString + ''' '
      else if DStyle = 'Month' then
        Result := Result + ' and TO_CHAR(a.UPDATE_TIME,''YYYY/MM'') = ''' + QryTemp2.Fieldbyname(sField).AsString + ''' '
      else if DStyle = 'Quarter' then
        Result := Result + ' and TO_CHAR(a.UPDATE_TIME,''YYYY_Q'') = ''' + QryTemp2.Fieldbyname(sField).AsString + ''' '
      else if DStyle = 'Year' then
        Result := Result + ' and TO_CHAR(a.UPDATE_TIME,''YYYY'') = ''' + QryTemp2.Fieldbyname(sField).AsString + ''' ';
    end;
    if bRecDate then
    begin
      if DStyle = 'Date' then
        Result := Result + ' and TO_CHAR(REC_TIME,''YYYY/MM/DD'') = ''' + QryTemp2.Fieldbyname(DateStyle).AsString + ''' '
      else if DStyle = 'Week' then
        Result := Result + ' and TO_CHAR(REC_TIME,''IYYY-IW'') = ''' + QryTemp2.Fieldbyname(DateStyle).AsString + ''' '
      else if DStyle = 'Month' then
        Result := Result + ' and TO_CHAR(REC_TIME,''YYYY/MM'') = ''' + QryTemp2.Fieldbyname(DateStyle).AsString + ''' '
      else if DStyle = 'Quarter' then
        Result := Result + ' and TO_CHAR(REC_TIME,''YYYY_Q'') = ''' + QryTemp2.Fieldbyname(DateStyle).AsString + ''' '
      else if DStyle = 'Year' then
        Result := Result + ' and TO_CHAR(REC_TIME,''YYYY'') = ''' + QryTemp2.Fieldbyname(DateStyle).AsString + ''' ';
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
    if bPart then
      Result := Result + ' and E.Part_No = ''' + QryTemp2.Fieldbyname('Part No').AsString + ''' ';
    if bModel then
      if QryTemp2.Fieldbyname('Model Name').AsString <> '' then
        Result := Result + ' and J.Model_Name = ''' + QryTemp2.Fieldbyname('Model Name').AsString + ''' '
      else
        Result := Result + ' and J.Model_Name is null ';
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
  begin
    sSQL := 'Select B.WORK_ORDER "Work Order",' +
      'B.SERIAL_NUMBER "Serial Number",' +
      'B.CUSTOMER_SN "Customer SN",' +
      'Decode(B.CURRENT_STATUS,''1'',''NG'','''') "Status",' + //add 2006/03/16
      'C.PDLINE_NAME "Production Line",' +
      'D.PROCESS_NAME "Process Name",' +
      'B.OUT_PROCESS_TIME "Out Process Time",' +
      'F.EMP_NAME "Employee" ';
    if bPart then
      sSQL := sSQL + ',E.Part_No "Part No" ';
    if bModel then
      sSQL := sSQL + ',J.Model_Name "Model Name" ';
    sSQL := sSQL + 'From SAJET.G_SN_STATUS B,' +
      ' SAJET.G_WO_BASE A, ' +
      ' SAJET.SYS_PDLINE C, ' +
      ' SAJET.SYS_PROCESS D, ' +
      ' SAJET.SYS_EMP F ';
    if bPart or bModel or (Trim(fDetail.editPart.Text) <> '') or (Trim(fDetail.editModel.Text) <> '')then
      sSQL := sSQL + ' ,SAJET.SYS_PART E ';
    if bModel or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ' ,SAJET.SYS_MODEL J ';
    sSQL := sSQL + 'Where A.WORK_ORDER = B.WORK_ORDER ' +
      '  and B.PDLINE_ID = C.PDLINE_ID ' +
      '  and B.WIP_PROCESS = D.PROCESS_ID ' +
      '  and C.FACTORY_ID = ' + FcID +
      '  and A.WO_STATUS < ''5'' ';
    if bPart or bModel or (Trim(fDetail.editPart.Text) <> '') or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + '  and B.MODEL_ID = E.PART_ID ';
    if bModel or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + '  and E.MODEL_ID = J.MODEL_ID(+) ';
    sSQL := sSQL + ' and B.EMP_ID = F.EMP_ID(+) ' +
      GetCondition + sProcess + 'Order by "Serial Number" ';
  end
  else if sQueryType = 'Shipping' then
  begin
    sSQL := 'Select b.SHIPPING_NO "Shipping No"' +
      ',A.Pallet_No "Pallet No"' +
      ',A.Carton_No "Carton No"';
    if fDetail.gbBox then
      sSQL := sSQL + ',A.Box_No "Box No"';
    if bCustomer then
      sSQL := sSQL + ',A.Customer_SN "Customer SN"';
    sSQL := sSQL + ',A.Serial_Number "Serial Number"';
    if bWip then
      sSQL := sSQL + ',WIP_QTY "QTY"';
    sSQL := sSQL + ',A.UPDATE_TIME "Out Process Time"';
    if bPart then
      sSQL := sSQL + ',E.Part_No "Part No"';
    if bModel then
      sSQL := sSQL + ',J.Model_Name "Model Name"';
    sSQL := sSQL + ',F.EMP_NAME "Employee" ' +
      'From SAJET.G_SHIPPING_SN A,' +
      ' SAJET.G_SHIPPING_NO B, ';
    if bPart or bModel or (Trim(fDetail.editPart.Text) <> '') or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ' SAJET.SYS_PART E, ';
    if bModel or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ' SAJET.SYS_MODEL J, ';
    sSQL := sSQL + ' SAJET.SYS_EMP F ' +
      'Where ' + sSelectDate
      + GetCondition +
      ' AND A.SHIPPING_ID = B.SHIPPING_ID ';
    if bPart or bModel or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ' AND A.PART_ID = E.PART_ID ';
    if bModel or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + 'and E.MODEL_ID = J.MODEL_ID(+) ';
    if Trim(sShipNo) <> '' then
      sSQL := sSQL + ' and B.Shipping_No = ''' + Trim(sShipNo) + ''' ';
    if (not bPart) and (Trim(fDetail.editPart.Text) <> '') then
      if Pos('%', fDetail.editPart.Text) <> 0 then
        sSQL := sSQL + ' and E.PART_NO Like ''' + Trim(fDetail.editPart.Text) + ''' '
      else
        sSQL := sSQL + ' and E.PART_NO = ''' + Trim(fDetail.editPart.Text) + ''' ';
    if (not bModel) and (Trim(fDetail.editModel.Text) <> '') then
      if Pos('%', fDetail.editModel.Text) <> 0 then
        sSQL := sSQL + ' and J.Model_Name Like ''' + Trim(fDetail.editModel.Text) + ''' '
      else
        sSQL := sSQL + ' and J.Model_Name = ''' + Trim(fDetail.editModel.Text) + ''' ';
    sSQL := sSQL + ' AND A.UPDATE_USERID = F.EMP_ID(+) ' +
      'Order by "Shipping No", "Pallet No", "Carton No", ';
    if fDetail.gbBox then
      sSQL := sSQL + '"Box No", ';
    sSQL := sSQL + '"Serial Number" ';
  end
  else if sQueryType = 'ProcessOutput' then
  begin
    sSQL := 'Select /*+INDEX(A G_SN_TRAVEL_OUT_PROCESS_IDX) */ A.WORK_ORDER "Work Order"'
      + ',A.SERIAL_NUMBER "Serial Number"'
      + ',A.CUSTOMER_SN "Customer SN"'
      + ',E.Part_No "Part No"'
      + ',C.PDLINE_NAME "Production Line"'
      + ',D.PROCESS_NAME "Process"'
      + ',A.OUT_PROCESS_TIME "Out Process Time"';
    if bModel then
      sSQL := sSQL + ',J.Model_Name "Model Name"';
    sSQL := sSQL + ',F.EMP_NAME "Employee" ' +
      'From SAJET.G_SN_TRAVEL A,' +
      ' SAJET.G_WO_BASE B, ' +
      ' SAJET.SYS_PDLINE C, ' +
      ' SAJET.SYS_PROCESS D, ';
    sSQL := sSQL + ' SAJET.SYS_PART E, ';
    if bModel or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ' SAJET.SYS_MODEL J, ';
    sSQL := sSQL + ' SAJET.SYS_EMP F ' +
      'Where ' + sSelectDate
      + GetCondition + sProcess +
      ' and A.WORK_ORDER = B.WORK_ORDER ' +
      ' and A.PDLINE_ID = C.PDLINE_ID ' +
      ' and A.PROCESS_ID = D.PROCESS_ID ';
    sSQL := sSQL + ' AND A.MODEL_ID = E.PART_ID ';
    if bModel or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ' and E.MODEL_ID = J.MODEL_ID(+) ';
    if (not bWo) and (sWo <> '') then
      if Pos('%', sWo) <> 0 then
        sSQL := sSQL + ' and A.WORK_ORDER Like ''' + Trim(sWo) + ''' '
      else
        sSQL := sSQL + ' and A.WORK_ORDER = ''' + Trim(sWo) + ''' ';
    if (not bPart) and (Trim(fDetail.editPart.Text) <> '') then
      if Pos('%', fDetail.editPart.Text) <> 0 then
        sSQL := sSQL + ' and E.PART_NO Like ''' + Trim(fDetail.editPart.Text) + ''' '
      else
        sSQL := sSQL + ' and E.PART_NO = ''' + Trim(fDetail.editPart.Text) + ''' ';
    if (not bModel) and (Trim(fDetail.editModel.Text) <> '') then
      if Pos('%', fDetail.editModel.Text) <> 0 then
        sSQL := sSQL + ' and J.Model_Name Like ''' + Trim(fDetail.editModel.Text) + ''' '
      else
        sSQL := sSQL + ' and J.Model_Name = ''' + Trim(fDetail.editModel.Text) + ''' ';
    if (not bLine) and (Trim(sLine) <> '') then
      sSQL := sSQL + ' and C.PDLINE_NAME = ''' + Trim(sLine) + ''' ';
    sSQL := sSQL + ' and A.EMP_ID = F.EMP_ID(+) '
      + 'Order by "Serial Number" ';
  end
  else if sQueryType = 'WOOutput' then
  begin
    sSQL := 'Select /*+INDEX(A G_SN_TRAVEL_OUT_PROCESS_IDX) */ A.WORK_ORDER "Work Order",' +
      'A.SERIAL_NUMBER "Serial Number",' +
      'A.CUSTOMER_SN "Customer SN",' +
      'C.PDLINE_NAME "Production Line",' +
      'D.PROCESS_NAME "Process",' +
      'A.OUT_PROCESS_TIME "Out Process Time",';
    if bPart then
      sSQL := sSQL + 'E.Part_No "Part No",';
    if bModel then
      sSQL := sSQL + 'J.Model_Name "Model Name",';
    sSQL := sSQL + 'F.EMP_NAME "Employee" ' +
      'From SAJET.G_SN_TRAVEL A,' +
      ' SAJET.G_WO_BASE B, ' +
      ' SAJET.SYS_PDLINE C, ' +
      ' SAJET.SYS_PROCESS D, ';
    if bPart or bModel or (Trim(fDetail.editPart.Text) <> '') or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ' SAJET.SYS_PART E, ';
    if bModel or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ' SAJET.SYS_MODEL J, ';
    sSQL := sSQL + ' SAJET.SYS_EMP F ' +
      'Where ' + sSelectDate
      + GetCondition +
      ' and A.WORK_ORDER = B.WORK_ORDER ' +
      ' and A.PROCESS_ID = B.END_PROCESS_ID ' +
      ' and A.PDLINE_ID = C.PDLINE_ID ' +
      ' and A.PROCESS_ID = D.PROCESS_ID ';
    if (not bWo) and (sWo <> '') then
      if Pos('%', sWo) <> 0 then
        sSQL := sSQL + ' and A.WORK_ORDER Like ''' + Trim(sWo) + ''' '
      else
        sSQL := sSQL + ' and A.WORK_ORDER = ''' + Trim(sWo) + ''' ';
    if (not bPart) and (Trim(fDetail.editPart.Text) <> '') then
      if Pos('%', fDetail.editPart.Text) <> 0 then
        sSQL := sSQL + ' and E.PART_NO Like ''' + Trim(fDetail.editPart.Text) + ''' '
      else
        sSQL := sSQL + ' and E.PART_NO = ''' + Trim(fDetail.editPart.Text) + ''' ';
    if (not bModel) and (Trim(fDetail.editModel.Text) <> '') then
      if Pos('%', fDetail.editModel.Text) <> 0 then
        sSQL := sSQL + ' and J.Model_Name Like ''' + Trim(fDetail.editModel.Text) + ''' '
      else
        sSQL := sSQL + ' and J.Model_Name = ''' + Trim(fDetail.editModel.Text) + ''' ';
    if (not bLine) and (Trim(sLine) <> '') then
      sSQL := sSQL + ' and C.PDLINE_NAME = ''' + Trim(sLine) + ''' ';
    if bPart or bModel or (Trim(fDetail.editPart.Text) <> '') or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ' AND A.MODEL_ID = E.PART_ID ';
    if bModel or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + 'and E.MODEL_ID = J.MODEL_ID(+) ';
    sSQL := sSQL + ' and A.EMP_ID = F.EMP_ID(+) ' +
      'Order by "Serial Number" '
  end
  else if sQueryType = 'Repair' then
  begin
    sSQL := 'Select A.WORK_ORDER "Work Order",' +
      'A.SERIAL_NUMBER "Serial Number",' +
      'C.PDLINE_NAME "Production Line",' +
      'D.PROCESS_NAME "Process",' +
      'A.REC_TIME "Process Time",';
    if bPart then
      sSQL := sSQL + 'E.Part_No "Part No",';
    if bModel then
      sSQL := sSQL + 'J.Model_Name "Model Name",';
    sSQL := sSQL + 'I.EMP_NAME "Employee", ' +
      'B.REMARK ' +
      'From SAJET.G_SN_DEFECT A,' +
      ' SAJET.G_SN_REPAIR B, ' +
      ' SAJET.SYS_PDLINE C, ' +
      ' SAJET.SYS_PROCESS D, ';
    if bPart or bModel or (Trim(fDetail.editPart.Text) <> '') or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ' SAJET.SYS_PART E, ';
    if bModel or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ' SAJET.SYS_MODEL J, ';
    sSQL := sSQL + ' SAJET.SYS_DEFECT F, ' +
      ' SAJET.SYS_REASON G, ' +
      ' SAJET.SYS_DUTY H, ' +
      ' SAJET.SYS_EMP I ' +
      'Where ' + sSelectDate +
      GetCondition + sProcess +
      ' and A.PDLINE_ID = C.PDLINE_ID ' +
      ' and A.PROCESS_ID = D.PROCESS_ID ';
    if bPart or bModel or (Trim(fDetail.editPart.Text) <> '') or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ' AND A.MODEL_ID = E.PART_ID ';
    if bModel or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + 'and E.MODEL_ID = J.MODEL_ID(+) ';
    if (not bWo) and (sWo <> '') then
      if Pos('%', sWo) <> 0 then
        sSQL := sSQL + ' and A.WORK_ORDER Like ''' + Trim(sWo) + ''' '
      else
        sSQL := sSQL + ' and A.WORK_ORDER = ''' + Trim(sWo) + ''' ';
    if (not bPart) and (Trim(fDetail.editPart.Text) <> '') then
      if Pos('%', fDetail.editPart.Text) <> 0 then
        sSQL := sSQL + ' and E.PART_NO Like ''' + Trim(fDetail.editPart.Text) + ''' '
      else
        sSQL := sSQL + ' and E.PART_NO = ''' + Trim(fDetail.editPart.Text) + ''' ';
    if (not bModel) and (Trim(fDetail.editModel.Text) <> '') then
      if Pos('%', fDetail.editModel.Text) <> 0 then
        sSQL := sSQL + ' and J.Model_Name Like ''' + Trim(fDetail.editModel.Text) + ''' '
      else
        sSQL := sSQL + ' and J.Model_Name = ''' + Trim(fDetail.editModel.Text) + ''' ';
    if (not bLine) and (Trim(sLine) <> '') then
      sSQL := sSQL + ' and C.PDLINE_NAME = ''' + Trim(sLine) + ''' ';
    sSQL := sSQL + ' and A.DEFECT_ID = F.DEFECT_ID ' +
      ' and A.RECID = B.RECID(+) ' +
      ' and B.REASON_ID = G.REASON_ID(+) ' +
      ' and B.DUTY_ID = H.DUTY_ID(+) ' +
      ' and A.TEST_EMP_ID = I.EMP_ID(+) ' +
      'Order by "Serial Number" '
  end
  else if sQueryType = 'KPRepair' then
  begin
    sSQL := 'Select E.PART_NO "Part No",' +
      'A.PART_SN "Serial Number",' +
      'C.PDLINE_NAME "Production Line",' +
      'D.PROCESS_NAME "Defect Process",' +
      'A.REC_TIME "Process Time"';
    if bModel then
      sSQL := sSQL + ',J.Model_Name "Model Name"';
    sSQL := sSQL + ',I.EMP_NAME "Employee" ' +
      'From SAJET.G_KP_DEFECT_H A ' +
      ' ,SAJET.G_KP_DEFECT_D j ' +
      ' ,SAJET.G_KP_REPAIR B ' +
      ' ,SAJET.SYS_PDLINE C ' +
      ' ,SAJET.SYS_PROCESS D ' +
      ' ,SAJET.SYS_DEFECT F ' +
      ' ,SAJET.SYS_REASON G ' +
      ' ,SAJET.SYS_DUTY H ';
    sSQL := sSQL + ', SAJET.SYS_PART E ';
    if (bModel) or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ', SAJET.SYS_MODEL J ';
    sSQL := sSQL + ' ,SAJET.SYS_EMP I ' +
      'Where ' + sSelectDate
      + GetCondition + sProcess +
      '  and A.RECID = B.RECID(+) ' +
      '  and A.PDLINE_ID = C.PDLINE_ID ' +
      '  and A.PROCESS_ID = D.PROCESS_ID ';
    if bPart or bModel or (Trim(fDetail.editPart.Text) <> '') or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ' AND A.PART_ID = E.PART_ID ';
    if bModel or (Trim(fDetail.editModel.Text) <> '')then
      sSQL := sSQL + 'and E.MODEL_ID = J.MODEL_ID(+) ';
    if (not bPart) and (Trim(fDetail.editPart.Text) <> '') then
      if Pos('%', fDetail.editPart.Text) <> 0 then
        sSQL := sSQL + ' and E.PART_NO Like ''' + Trim(fDetail.editPart.Text) + ''' '
      else
        sSQL := sSQL + ' and E.PART_NO = ''' + Trim(fDetail.editPart.Text) + ''' ';
    if (not bModel) and (Trim(fDetail.editModel.Text) <> '') then
      if Pos('%', fDetail.editModel.Text) <> 0 then
        sSQL := sSQL + ' and J.Model_Name Like ''' + Trim(fDetail.editModel.Text) + ''' '
      else
        sSQL := sSQL + ' and J.Model_Name = ''' + Trim(fDetail.editModel.Text) + ''' ';
    if (not bLine) and (Trim(sLine) <> '') then
      sSQL := sSQL + ' and C.PDLINE_NAME = ''' + Trim(sLine) + ''' ';
    sSQL := sSQL + '  and A.TEST_EMP_ID = I.EMP_ID(+) ' +
      '  and a.recid = j.recid ' +
      '  and j.DEFECT_ID = F.DEFECT_ID ' +
      '  and B.REASON_ID = G.REASON_ID(+) ' +
      '  and B.DUTY_ID = H.DUTY_ID(+) ' +
      'Order by "Serial Number" '
  end
  else if sQueryType = 'YieldRate' then
  begin
{    if (gsColumn = 'Pass Qty') or (gsColumn = 'Repass Qty') then begin
      if QryTemp2.FieldByName('Pass Qty').AsInteger + QryTemp2.FieldByName('Repass Qty').AsInteger = 0 then Exit
    end else if (gsColumn = 'Fail Qty') or (gsColumn = 'Refail Qty') then
      if QryTemp2.FieldByName('Fail Qty').AsInteger + QryTemp2.FieldByName('ReFail Qty').AsInteger = 0 then Exit;}
    sSQL := 'Select /*+INDEX(A G_SN_TRAVEL_OUT_PROCESS_IDX) */ A.WORK_ORDER "Work Order",' +
      'A.SERIAL_NUMBER "Serial Number",' +
      'A.CUSTOMER_SN "Customer SN",' +
      'C.PDLINE_NAME "Production Line",' +
      'D.PROCESS_NAME "Process",' +
      'A.OUT_PROCESS_TIME "Out Process Time"';
    if bPart then
      sSQL := sSQL + ',E.Part_No "Part No" ';
    if bModel then
      sSQL := sSQL + ',J.Model_Name "Model Name" ';
    sSQL := sSQL + ',F.EMP_NAME "Employee" ' +
      'From SAJET.G_SN_TRAVEL A,' +
      ' SAJET.G_WO_BASE B, ' +
      ' SAJET.SYS_PDLINE C, ' +
      ' SAJET.SYS_PROCESS D, ';
    if bPart or bModel then
      sSQL := sSQL + ' SAJET.SYS_PART E, ';
    if bModel then
      sSQL := sSQL + ' SAJET.SYS_MODEL J, ';
    sSQL := sSQL + ' SAJET.SYS_EMP F ' +
      'Where ' + sSelectDate
      + GetCondition + sProcess +
      ' and A.WORK_ORDER = B.WORK_ORDER ' +
      ' and A.PDLINE_ID = C.PDLINE_ID ' +
      ' and A.PROCESS_ID = D.PROCESS_ID ';
    if (gsColumn = 'Pass Qty') or (gsColumn = 'Repass Qty') then
      sSQL := sSQL + ' and A.Current_Status = ''0'' '
    else if (gsColumn = 'Fail Qty') or (gsColumn = 'Refail Qty') then
      sSQL := sSQL + ' and A.Current_Status = ''1'' ';
    if bPart or bModel or (Trim(fDetail.editPart.Text) <> '') or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ' AND A.MODEL_ID = E.PART_ID ';
    if bModel or (Trim(fDetail.editModel.Text) <> '') then
      sSQL := sSQL + ' and E.MODEL_ID = J.MODEL_ID(+) ';
    if (not bWo) and (sWo <> '') then
      if Pos('%', sWo) <> 0 then
        sSQL := sSQL + ' and A.WORK_ORDER Like ''' + Trim(sWo) + ''' '
      else
        sSQL := sSQL + ' and A.WORK_ORDER = ''' + Trim(sWo) + ''' ';
    if (not bPart) and (Trim(fDetail.editPart.Text) <> '') then
      if Pos('%', fDetail.editPart.Text) <> 0 then
        sSQL := sSQL + ' and E.PART_NO Like ''' + Trim(fDetail.editPart.Text) + ''' '
      else
        sSQL := sSQL + ' and E.PART_NO = ''' + Trim(fDetail.editPart.Text) + ''' ';
    if (not bModel) and (Trim(fDetail.editModel.Text) <> '') then
      if Pos('%', fDetail.editModel.Text) <> 0 then
        sSQL := sSQL + ' and J.Model_Name Like ''' + Trim(fDetail.editModel.Text) + ''' '
      else
        sSQL := sSQL + ' and J.Model_Name = ''' + Trim(fDetail.editModel.Text) + ''' ';
    if (not bLine) and (Trim(sLine) <> '') then
      sSQL := sSQL + ' and C.PDLINE_NAME = ''' + Trim(sLine) + ''' ';
    sSQL := sSQL + ' and A.EMP_ID = F.EMP_ID(+) ' +
      'Order by "Serial Number" ';
  end else if sQueryType = 'Inspection' then
  begin
    sSQL := 'select F.QC_LotNo "Lot No"'
      + ',F.NG_Cnt "Qc Times" ';
    sSQL := sSQL + ',F.LOT_SIZE "Lot Size" ,F.SAMPLING_SIZE "Sample Qty", F.FAIL_QTY "Fail Qty" ,TRUNC((F.FAIL_QTY /Decode(F.SAMPLING_SIZE,0,1,F.SAMPLING_SIZE))*100,2) "Fail Rate(%)" '
      + ',sajet.Inspection_Result(F.QC_Result) "Insp Result", F.Lot_Memo "Memo" '
      + ' From SAJET.G_Qc_Lot F ';
    if not bShip then begin
      if bPart or (Trim(fDetail.editPart.Text) <> '') or bModel or (Trim(fDetail.editModel.Text) <> '') then
        sSQL := sSQL + ' ,SAJET.SYS_PART E ';
      if bModel or (Trim(fDetail.editModel.Text) <> '') then
        sSQL := sSQL + ' ,SAJET.SYS_MODEL J ';
      if bProcess then
        sSQL := sSQL + ' ,SAJET.SYS_PROCESS D ';
    end;
    if bShip then
      sSQL := sSQL + 'Where F.QC_LOTNO = ''' + QryTemp2.FieldByName('Lot No').AsString + ''' ' +
        ' And F.NG_CNT = ''' + QryTemp2.FieldByName('Qc Times').AsString + ''' '
    else begin
      sSQL := sSQL + 'Where ' + sSelectDate + GetCondition + sProcess;
      if bPart or bModel or (Trim(fDetail.editPart.Text) <> '') or (Trim(fDetail.editModel.Text) <> '') then
        sSQL := sSQL + '  and F.MODEL_ID = E.PART_ID ';
      if bModel or (Trim(fDetail.editModel.Text) <> '') then
        sSQL := sSQL + '  and E.MODEL_ID = J.MODEL_ID(+) ';
      if bProcess then
        sSQL := sSQL + ' and F.Process_Id = D.Process_Id ';
      if Trim(sLotNo) <> '' then
        sSQL := sSQL + ' and F.QC_LOTNO = ''' + Trim(sLotNo) + ''' ';
      if (not bPart) and (Trim(fDetail.editPart.Text) <> '') then
        sSQL := sSQL + ' and E.PART_NO = ''' + Trim(fDetail.editPart.Text) + ''' ';
      if (not bModel) and (Trim(fDetail.editModel.Text) <> '') then
        sSQL := sSQL + ' and J.MODEL_Name = ''' + Trim(fDetail.editModel.Text) + ''' ';
      sSQL := sSQL + ' Order by "Lot No" ';
    end;
  end;
  if sQueryType <> 'Inspection' then
  begin
    with TfDataDetail.Create(Self) do
    begin
      GradPanel1.Caption := 'Detail Data';
      QuryDataDetail.RemoteServer := QryTemp2.RemoteServer;
      QuryDataDetail.Close;
      QuryDataDetail.Params.Clear;
      QuryDataDetail.CommandText := sSQL;
      QuryDataDetail.Open;
      for Col := 0 to DBGrid1.Columns.Count - 1 do
        if DBGrid1.Columns[Col].Width > 130 then
          DBGrid1.Columns[Col].Width := 130;
      if sQueryType = 'YieldRate' then begin
        if (gsColumn = 'Pass Qty') or (gsColumn = 'Repass Qty') then
          GPRecords.Caption := IntToStr(QryTemp2.FieldByName('Pass Qty').AsInteger
            + QryTemp2.FieldByName('RePass Qty').AsInteger)
        else if (gsColumn = 'Fail Qty') or (gsColumn = 'Refail Qty') then
          GPRecords.Caption := IntToStr(QryTemp2.FieldByName('Fail Qty').AsInteger
            + QryTemp2.FieldByName('ReFail Qty').AsInteger)
        else
          GPRecords.Caption := IntToStr(QryTemp2.FieldByName('Pass Qty').AsInteger + QryTemp2.FieldByName('Fail Qty').AsInteger
            + QryTemp2.FieldByName('RePass Qty').AsInteger + QryTemp2.FieldByName('ReFail Qty').AsInteger);
      end else if sQueryType = 'Inspection' then
        GPRecords.Caption := IntToStr(QuryDataDetail.RecordCount)
      else
        GPRecords.Caption := QryTemp2.FieldByName('Qty').AsString;
      Showmodal;
      Free;
    end;
  end else
    with TfInspDetail.Create(Self) do
    begin
      GradPanel1.Caption := 'Detail Data';
      QryLot.RemoteServer := QryTemp2.RemoteServer;
      QuryInspDetail.RemoteServer := QryTemp2.RemoteServer;
      QuryInspDefect.RemoteServer := QryTemp2.RemoteServer;
      QryLot.Close;
      QryLot.Params.Clear;
      QryLot.CommandText := sSQL;
      QryLot.Open;
      GPRecords.Caption := IntToStr(QryLot.RecordCount);
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
    begin
      if DBGrid1.Columns[j].Alignment = taLeftJustify then
        MsExcel.Worksheets['Sheet1'].Cells[i + 2, j + 1].NumberFormatLocal := '@';
      MsExcel.Worksheets['Sheet1'].Cells[i + 2, j + 1] := QryTemp2.Fields.Fields[J].AsString;
    end;
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
  end;
end;

procedure TfData.FormCreate(Sender: TObject);
begin
  sDetailBase := '';
  sSelectDate := '';
end;

procedure TfData.FormShow(Sender: TObject);
var Col: Integer;
begin
  for Col := 0 to DBGrid1.Columns.Count - 1 do
    if DBGrid1.Columns[Col].Width > 130 then
      DBGrid1.Columns[Col].Width := 130;
end;

procedure TfData.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfData.DBGrid1CellClick(Column: TColumn);
begin
  gsColumn := Column.FieldName;
end;

end.

