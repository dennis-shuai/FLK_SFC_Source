unit uTravelCard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, GradPanel, Grids, DBGrids, DB,
  DBClient, Buttons, comobj,  ComCtrls, Clrgrid;

type
  TfTravelCard = class(TForm)
    GradPanel1: TGradPanel;
    Label1: TLabel;
    GradPanel5: TGradPanel;
    Bevel4: TBevel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label18: TLabel;
    editSN: TEdit;
    LabWO: TLabel;
    LabMasterWO: TLabel;
    LabPN: TLabel;
    LabVersion: TLabel;
    LabRoute: TLabel;
    LabLine: TLabel;
    GradPanel8: TGradPanel;
    GradPanel7: TGradPanel;
    Label7: TLabel;
    Bevel3: TBevel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label17: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    editCustomer: TEdit;
    editWarranty: TEdit;
    editShipto: TEdit;
    editVehicle: TEdit;
    editContainer: TEdit;
    editShiptime: TEdit;
    GradPanel6: TGradPanel;
    Label6: TLabel;
    Bevel5: TBevel;
    Label22: TLabel;
    Label23: TLabel;
    editCarton: TEdit;
    editPallet: TEdit;
    Label2: TLabel;
    editCSN: TEdit;
    Label3: TLabel;
    editKPSN: TEdit;
    Label4: TLabel;
    LabSpec: TLabel;
    Label5: TLabel;
    Label16: TLabel;
    LabWOType: TLabel;
    LabRemark: TLabel;
    Label24: TLabel;
    lablNextProcess: TLabel;
    Label25: TLabel;
    editBox: TEdit;
    tpTravel: TPageControl;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel6: TBevel;
    Label26: TLabel;
    lablStatus: TLabel;
    procedure editSNKeyPress(Sender: TObject; var Key: Char);
    procedure editCSNKeyPress(Sender: TObject; var Key: Char);
    procedure editKPSNKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure GridKPDblClick(Sender: TObject);
    procedure GridKPSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure GridTravelDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormDestroy(Sender: TObject);
    procedure tpTravelChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    gsKeyPartSN, UpdateUserID, gsSN, gRPID: string;
    gsRow: Integer;
    gbChangeKP, gbFirst, gbGroup: Boolean;
    gsGrid: TStrings;
    procedure ClearData;
    procedure ShowSNData;
    procedure DspWOData;
    procedure DspReportSQL;
    procedure DspReportData;
    procedure DspShipData;
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
    function DownloadSampleFile: string;
    procedure ChkAuthority(PrgName: string);
    procedure AutoSizeCol(Grid: TStringGrid; Column: integer);
    function GetRPID: string;
    function getSN: string;
  end;

var
  fTravelCard: TfTravelCard;

implementation

uses uDetail, UDataSN;

{$R *.dfm}

procedure TfTravelCard.ChkAuthority(PrgName: string);
begin
  with fDetail.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EMP_ID', ptInput);
    Params.CreateParam(ftString, 'PRG', ptInput);
    Params.CreateParam(ftString, 'FUN', ptInput);
    CommandText := 'Select AUTHORITYS ' +
      'From SAJET.SYS_EMP_PRIVILEGE ' +
      'Where EMP_ID = :EMP_ID and ' +
      'PROGRAM = :PRG and ' +
      'FUNCTION = :FUN ';
    Params.ParamByName('EMP_ID').AsString := UpdateUserID;
    Params.ParamByName('PRG').AsString := PrgName;
    Params.ParamByName('FUN').AsString := 'Change Key Part SN';
    Open;
    gbChangeKP := (not fDetail.QryTemp.IsEmpty);
    Close;
  end;
  if not gbChangeKP then
    with fDetail.QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      Params.CreateParam(ftString, 'FUN', ptInput);
      CommandText := 'Select AUTHORITYS ' +
        'From SAJET.SYS_ROLE_PRIVILEGE A, ' +
        'SAJET.SYS_ROLE_EMP B ' +
        'Where A.ROLE_ID = B.ROLE_ID and ' +
        'EMP_ID = :EMP_ID and ' +
        'PROGRAM = :PRG and ' +
        'FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := PrgName;
      Params.ParamByName('FUN').AsString := 'Change Key Part SN';
      Open;
      gbChangeKP := (not fDetail.QryTemp.IsEmpty);
      Close;
    end;
end;

function TfTravelCard.GetRPID: string;
begin
  with fDetail.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select RP_ID from sajet.sys_report_name '
      + 'where upper(DLL_FILENAME) = ''REPORTTRAVELDLL.DLL'' and rownum = 1';
    Open;
    Result := FieldByName('RP_ID').AsString;
    Close;
  end;
end;

procedure TfTravelCard.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var i, j, k: integer;
begin
  // SN , WO, PACKING, Shipping
  MsExcel.Worksheets['Data'].select;
  MsExcel.Worksheets['Data'].Range['A1'].Value := 'Serial Number';
  MsExcel.Worksheets['Data'].Range['B1'].Value := 'Work Order';
  MsExcel.Worksheets['Data'].Range['C1'].Value := 'Master Work Order';
  MsExcel.Worksheets['Data'].Range['D1'].Value := 'Part No';
  MsExcel.Worksheets['Data'].Range['E1'].Value := 'Version';
  MsExcel.Worksheets['Data'].Range['F1'].Value := 'Route Name';
  MsExcel.Worksheets['Data'].Range['G1'].Value := 'Production Line';
  MsExcel.Worksheets['Data'].Range['H1'].Value := 'Box No';
  MsExcel.Worksheets['Data'].Range['I1'].Value := 'Carton No';
  MsExcel.Worksheets['Data'].Range['J1'].Value := 'Pallet No';
  MsExcel.Worksheets['Data'].Range['K1'].Value := 'Customer';
  MsExcel.Worksheets['Data'].Range['L1'].Value := 'Warranty';
  MsExcel.Worksheets['Data'].Range['M1'].Value := 'Ship To';
  MsExcel.Worksheets['Data'].Range['N1'].Value := 'Vehicle';
  MsExcel.Worksheets['Data'].Range['O1'].Value := 'Container';
  MsExcel.Worksheets['Data'].Range['P1'].Value := 'Shipping Time';
  MsExcel.Worksheets['Data'].Range['Q1'].Value := 'Customer SN';
  MsExcel.Worksheets['Data'].Range['R1'].Value := 'Next Process';
  MsExcel.Worksheets['Data'].Range['S1'].Value := 'Status';
  MsExcel.Worksheets['Data'].Range['T1'].Value := 'Spec';

  MsExcel.Worksheets['Data'].Range['A2'].Value := editSN.Text;
  MsExcel.Worksheets['Data'].Range['B2'].Value := LabWO.Caption;
  MsExcel.Worksheets['Data'].Range['C2'].Value := LabMasterWO.Caption;
  MsExcel.Worksheets['Data'].Range['D2'].Value := LabPN.Caption;
  MsExcel.Worksheets['Data'].Range['E2'].Value := LabVersion.Caption;
  MsExcel.Worksheets['Data'].Range['F2'].Value := LabRoute.Caption;
  MsExcel.Worksheets['Data'].Range['G2'].Value := LabLine.Caption;
  MsExcel.Worksheets['Data'].Range['H2'].Value := editBox.Text;
  MsExcel.Worksheets['Data'].Range['I2'].Value := editCarton.Text;
  MsExcel.Worksheets['Data'].Range['J2'].Value := editPallet.Text;
  MsExcel.Worksheets['Data'].Range['K2'].Value := editCustomer.Text;
  MsExcel.Worksheets['Data'].Range['L2'].Value := editWarranty.Text;
  MsExcel.Worksheets['Data'].Range['M2'].Value := editShipto.Text;
  MsExcel.Worksheets['Data'].Range['N2'].Value := editVehicle.Text;
  MsExcel.Worksheets['Data'].Range['O2'].Value := editContainer.Text;
  MsExcel.Worksheets['Data'].Range['P2'].Value := editShiptime.Text;
  MsExcel.Worksheets['Data'].Range['Q2'].Value := editCSN.Text;
  MsExcel.Worksheets['Data'].Range['R2'].Value := lablNextProcess.Caption;
  MsExcel.Worksheets['Data'].Range['S2'].Value := lablStatus.Caption;
  MsExcel.Worksheets['Data'].Range['T2'].Value := LabSpec.Caption;

  // Travel
  for k := 0 to gsGrid.Count - 1 do
  begin
    try
      MsExcel.Worksheets[TStringGrid(StrToInt(gsGrid[k])).Parent.Hint].select;
    except
      MsExcel.WorkSheets[MsExcel.WorkSheets.Count].Select;
      MsExcel.Sheets.Add;
      MsExcel.WorkSheets[MsExcel.WorkSheets.Count - 1].Cells.NumberFormatLocal := '@';
      MsExcel.WorkSheets[MsExcel.WorkSheets.Count - 1].Name := TStringGrid(StrToInt(gsGrid[k])).Parent.Hint;
    end;
    with TStringGrid(StrToInt(gsGrid[k])) do
      for i := 0 to RowCount - 1 do
        for j := 0 to ColCount - 1 do
          MsExcel.Worksheets[TStringGrid(StrToInt(gsGrid[k])).Parent.Hint].Range[Chr(j + 65) + IntToStr(i + 1)].Value := Cells[J, I];
  end;
  MsExcel.Run('WIP');
end;

procedure TfTravelCard.ClearData;
var I, j: Integer;
begin
  for i := 0 to gsGrid.Count - 1 do
    with TStringGrid(StrToInt(gsGrid[i])) do
    begin
      for j := 1 to RowCount - 1 do
        Rows[j].Clear;
      RowCount := 2;
      ColCount := 2;
    end;
end;

procedure TfTravelCard.DspWOData;
begin
  with fDetail.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SN', ptInput);
    CommandText := 'Select A.WORK_ORDER,' +
      'A.MASTER_WO,' +
      'A.PO_NO,' +
      'f.work_flag, f.current_status,';
    if editBox.Visible then
      CommandText := CommandText + 'F.BOX_NO,';
    CommandText := CommandText + 'F.CARTON_NO,' +
      'F.PALLET_NO,' +
      'F.CUSTOMER_SN,' +
      'B.PART_NO,' +
      'B.Spec1,' +
      'F.VERSION,' +
      'C.ROUTE_NAME,' +
      'D.PDLINE_NAME, ' +
      'A.WO_TYPE, ' +
      'A.REMARK, ' +
      'nvl(G.Process_Name, E.Process_Name) Process_Name ' +
      'From SAJET.G_WO_BASE A,' +
      'SAJET.SYS_PART B,' +
      'SAJET.SYS_ROUTE C,' +
      'SAJET.SYS_PDLINE D,' +
      'SAJET.G_SN_STATUS F, ' +
      'SAJET.SYS_PROCESS E, ' +
      'SAJET.SYS_PROCESS G ' +
      'Where A.MODEL_ID=B.PART_ID(+) ' +
      'and F.ROUTE_ID=C.ROUTE_ID(+) ' +
      'and A.WORK_ORDER=F.WORK_ORDER ' +
      'and F.SERIAL_NUMBER = :SN ' +
      'and F.WIP_PROCESS = E.PROCESS_ID(+) ' +
      'and F.NEXT_PROCESS = G.PROCESS_ID(+) ' +
      'and F.PDLINE_ID=D.PDLINE_ID(+) ';
    Params.ParamByName('SN').AsString := editSN.Text; //(editSN.Text);
    Open;
    if RecordCount > 0 then
    begin
      LabWO.Caption := Fieldbyname('WORK_ORDER').AsString;
      LabMasterWO.Caption := Fieldbyname('MASTER_WO').AsString;
      LabPN.Caption := Fieldbyname('PART_NO').AsString;
      LabSpec.Caption := Fieldbyname('Spec1').AsString;
      LabVersion.Caption := Fieldbyname('VERSION').AsString;
      LabRoute.Caption := Fieldbyname('ROUTE_NAME').AsString;
      LabLine.Caption := Fieldbyname('PDLINE_NAME').AsString;
      LabWOType.Caption := Fieldbyname('WO_TYPE').AsString;
      LabRemark.Caption := Fieldbyname('REMARK').AsString;
      lablNextProcess.Caption := Fieldbyname('Process_Name').AsString;
      if Fieldbyname('work_flag').AsString = '1' then
      begin
        lablStatus.Caption := 'Scrap';
        lablStatus.Transparent := False;
        lablStatus.Color := clYellow;
        lablStatus.Font.Color := clRed;
      end
      else if Fieldbyname('current_status').AsString = '1' then
      begin
        lablStatus.Caption := 'Fail';
        lablStatus.Transparent := True;
        lablStatus.Font.Color := clRed;
      end
      else
      begin
        lablStatus.Font.Color := clBlue;
        lablStatus.Transparent := True;
        lablStatus.Caption := 'Good';
      end;
      if editBox.Visible then
        editBox.Text := Fieldbyname('Box_NO').AsString;
      editCarton.Text := Fieldbyname('CARTON_NO').AsString;
      editPallet.Text := Fieldbyname('PALLET_NO').AsString;

      editCSN.Text := FieldByName('Customer_SN').AsString;
    end;
    Close;
  end;
end;

procedure TfTravelCard.DspShipData;
begin
  with fDetail.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SN', ptInput);
    CommandText := 'Select A.CONTAINER,A.VEHICLE_NO,A.WARRANTY,TO_CHAR(A.UPDATE_TIME,''YYYY/MM/DD HH24:MI'') TIME, ' +
      'B.SHIPPING_NO,B.SHIP_TO ' +
      ',C.CUSTOMER_CODE,C.CUSTOMER_NAME ' +
      'From SAJET.G_SHIPPING_SN A' +
      ',SAJET.G_SHIPPING_NO B ' +
      ',SAJET.SYS_CUSTOMER C ' +
      'Where A.SERIAL_NUMBER = :SN ' +
      'and A.SHIPPING_ID = B.SHIPPING_ID  ' +
      'and B.SHIP_CUST = C.CUSTOMER_ID(+) ';
    Params.ParamByName('SN').AsString := editSN.Text; //Trim(editSN.Text);
    Open;
    if RecordCount > 0 then
    begin
      editCustomer.Text := Fieldbyname('CUSTOMER_CODE').AsString + '-' + Fieldbyname('CUSTOMER_NAME').AsString;
      editWarranty.Text := Fieldbyname('WARRANTY').AsString;
      editShipto.Text := Fieldbyname('SHIP_TO').AsString;
      editVehicle.Text := Fieldbyname('VEHICLE_NO').AsString;
      editContainer.Text := Fieldbyname('CONTAINER').AsString;
      editShiptime.Text := Fieldbyname('TIME').AsString;
    end;
    Close;
  end;
end;

procedure TfTravelCard.ShowSNData;
begin
  ClearData;
  DspWOData; // WO & Packing
  DspShipData; // Shipping
  DspReportData;
end;

procedure TfTravelCard.AutoSizeCol(Grid: TStringGrid; Column: integer);
var i, W, WMax: integer;
begin
  WMax := 0;
  for i := 0 to (Grid.RowCount - 1) do
  begin
    W := Grid.Canvas.TextWidth(Grid.Cells[Column, i]);
    if W > WMax then
      WMax := W;
  end;
  Grid.ColWidths[Column] := WMax + 5;
end;

procedure TfTravelCard.DspReportData;
var i, j, iRow: Integer;
begin
  with fDetail.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'rp_id', ptInput);
    CommandText := 'select * from sajet.sys_report_sql '
      + 'where rp_id = :rp_id order by fun_idx';
    Params.ParamByName('rp_id').AsString := gRPId;
    Open;
    i := 0;
    while not Eof do
    begin
      with fDetail.QryData do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'SN', ptInput);
        CommandText := fDetail.QryTemp.FieldByName('sql_value').AsString;
        Params.ParamByName('SN').AsString := editSN.Text;
        Open;
        for j := 0 to FieldCount - 1 do
          TStringGrid(StrToInt(gsGrid[i])).Cells[j, 0] := Fields[j].FieldName;
        TStringGrid(StrToInt(gsGrid[i])).ColCount := FieldCount;
        iRow := 1;
        while not Eof do
        begin
          for j := 0 to FieldCount - 1 do
            TStringGrid(StrToInt(gsGrid[i])).Cells[j, iRow] := Fields[j].AsString;
          Next;
          Inc(iRow);
        end;
        if iRow = 1 then
          TStringGrid(StrToInt(gsGrid[i])).RowCount := 2
        else
          TStringGrid(StrToInt(gsGrid[i])).RowCount := iRow;
        for iRow := 0 to TStringGrid(StrToInt(gsGrid[i])).ColCount - 1 do
          AutoSizeCol(TStringGrid(StrToInt(gsGrid[i])), iRow);
      end;
      if gbFirst then begin
         Exit;
      end;
      Next;
      Inc(i);
    end;
    Close;
  end;
end;

procedure TfTravelCard.DspReportSQL;
var TabSheet1: TTabSheet; sGridData: TStringGrid; i: Integer;
begin
  with fDetail.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'rp_id', ptInput);
    CommandText := 'select * from sajet.sys_report_sql '
      + 'where rp_id = :rp_id order by fun_idx';
    Params.ParamByName('rp_id').AsString := gRPId;
    Open;
    i := 0;
    while not Eof do
    begin
      Inc(i);
      TabSheet1 := TTabSheet.Create(Self);
      TabSheet1.Caption := FieldByName('Fun_Type').AsString;
      TabSheet1.Hint := FieldByName('Fun_Type').AsString;
      TabSheet1.PageControl := tpTravel;
      sGridData := TStringGrid.Create(Self);
      gsGrid.Add(IntToStr(Integer(sGridData)));
      sGridData.Parent := TabSheet1;
      sGridData.Name := 'sGridData' + IntToStr(i);
      sGridData.Align := alClient;
      sGridData.FixedCols := 0;
      sGridData.Hint := FieldByName('Color_Field').AsString + ',' + FieldByName('Color_Value').AsString;
      sGridData.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect];
      sGridData.DefaultRowHeight := 18;
      if FieldByName('Color_Field').AsString <> '' then
        sGridData.OnDrawCell := GridTravelDrawCell;
      Next;
    end;
    Close;
  end;
end;

procedure TfTravelCard.editSNKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    gsSN := '';
    ShowSNData;
    editSN.SetFocus;
    editSN.SelectAll;
  end;
end;

function TfTravelCard.DownloadSampleFile: string;
begin
  Result := '';
  if gRpID = '' then
    gRpID := GetRpID;
  with fDetail.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RP_ID', ptInput);
    CommandText := 'Select SAMPLE_NAME,SAMPLE_FILE ' +
      'From SAJET.SYS_REPORT_NAME ' +
      'Where RP_ID = :RP_ID ';
    Params.ParamByName('RP_ID').AsString := gRpID;
    Open;
    if not Eof then
    begin
      TBlobField(Fieldbyname('SAMPLE_FILE')).SaveToFile('C:\' + Fieldbyname('SAMPLE_NAME').AsString);
      Result := 'C:\' + Fieldbyname('SAMPLE_NAME').AsString;
    end;
    Close;
  end;
end;

procedure TfTravelCard.editCSNKeyPress(Sender: TObject; var Key: Char);
  function getSN: string;
  begin
    with fDetail.QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'SELECT SERIAL_NUMBER '
        + '  FROM SAJET.G_SN_STATUS '
        + ' WHERE CUSTOMER_SN = ''' + editCSN.Text + ''' ';
      Open;
      Result := FieldByName('Serial_Number').AsString;
      Close;
    end;
  end;

begin
  if Key = #13 then
  begin
    gsSN := '';
    if Trim(editCSN.Text) <> '' then
    begin
      editSN.Text := getSN;
      editSNKeyPress(Self, Key);
    end;
    editCSN.SetFocus;
    editCSN.SelectAll;
  end;
end;

function TfTravelCard.getSN: string;
begin
  with fDetail.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT SERIAL_NUMBER '
      + '  FROM SAJET.G_SN_KEYPARTS '
      + ' WHERE ITEM_PART_SN = ''' + editKPSN.Text + ''' ';
    Open;
    Result := FieldByName('Serial_Number').AsString;
    Close;
  end;
end;

procedure TfTravelCard.editKPSNKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    gsSN := '';
    if Trim(editKPSN.Text) <> '' then
    begin
      editSN.Text := getSN;
      editSNKeyPress(Self, Key);
    end;
    editKPSN.SetFocus;
    editKPSN.SelectAll;
  end;
end;

procedure TfTravelCard.FormShow(Sender: TObject);
var key: char;
begin
  gsGrid := TStringList.Create;
  ChkAuthority('Report');
  tpTravel.ActivePageIndex := 0;
  gRpID := GetRPID;
  DspReportSQL;

  editsn.Text :=g_sn;
  key:=#13;
  editSNKeyPress(Self, Key);


  editSN.SelectAll;
  editSN.SetFocus;
end;

procedure TfTravelCard.GridKPDblClick(Sender: TObject);
var sKPSN: string; i, sRow: Integer;
begin
{  if gsKeyPartSN <> '' then
  begin
    sKPSN := gsKeyPartSN;
    if InputQuery('Modify Key Part SN ', 'Serial Number: ' + editSN.Text + #10#10 + 'Key Part SN:    ' + sKPSN + #10, sKPSN) then
      if (sKPSN <> '') and (sKPSN <> gsKeyPartSN) then
      begin
        sRow := gsRow;
        QryTemp.Close;
        QryTemp.Params.Clear;
        QryTemp.Params.CreateParam(ftString, 'sItemSN', ptInput);
        QryTemp.CommandText := 'select serial_number from sajet.g_sn_keyparts '
          + 'where item_part_sn = :sItemSN and rownum = 1';
        QryTemp.Params.ParamByName('sItemSN').AsString := sKPSN;
        QryTemp.Open;
        if QryTemp.IsEmpty then
        begin
          QryTemp.Close;
          QryTemp.Params.Clear;
          QryTemp.Params.CreateParam(ftString, 'newitem', ptInput);
          QryTemp.Params.CreateParam(ftString, 'sItemSN', ptInput);
          QryTemp.CommandText := 'update sajet.g_sn_keyparts '
            + 'set item_part_sn = :newitem where item_part_sn = :sItemSN and rownum = 1';
          QryTemp.Params.ParamByName('newitem').AsString := sKPSN;
          QryTemp.Params.ParamByName('sItemSN').AsString := gsKeyPartSN;
          QryTemp.Execute;
          with QryTemp do
          begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'SN', ptInput);
            Params.CreateParam(ftString, 'EMP', ptInput);
            Params.CreateParam(ftString, 'PartID', ptInput);
            Params.CreateParam(ftString, 'OldKPSN', ptInput);
            Params.CreateParam(ftString, 'NewKPSN', ptInput);
            Params.CreateParam(ftString, 'REMARK', ptInput);
            Params.CreateParam(ftString, 'Flag', ptInput);
            CommandText := 'Insert Into SAJET.G_SN_REPAIR_REPLACE_KP '
              + '(serial_number, replace_emp_id, replace_time,item_part_id,old_part_sn,new_part_id,new_part_sn) '
              + 'Values(:SN,:EMP,Sysdate,:PartID,:OldKPSN,:NewPartID,:NewKPSN) ';
            Params.ParamByName('SN').AsString := editSN.Text;
            Params.ParamByName('EMP').AsString := UpdateUserID;
            Params.ParamByName('PartID').AsString := GridKP.Cells[8, sRow];
            Params.ParamByName('OldKPSN').AsString := gsKeyPartSN;
            Params.ParamByName('NewPartID').AsString := GridKP.Cells[8, sRow];
            Params.ParamByName('NewKPSN').AsString := sKPSN;
            Execute;
            Close;
          end;
          QryTemp.Close;
          with GridKP do
          begin
            for i := 1 to RowCount - 1 do
              Rows[i].Clear;
            RowCount := 2;
            ColCount := 8;
          end;
          DspKPData;
          GridKP.Row := sRow;
          GridKP.Col := 2;
        end
        else
          MessageDlg('Key Part SN: ' + sKPSN + ' had used (' + QryTemp.FieldByName('serial_number').AsString + ')!', mtWarning, [mbOK], 0);
        QryTemp.Close;
      end;
  end;  }
end;

procedure TfTravelCard.GridKPSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
{  gsKeyPartSN := '';
  if (GridKP.Cells[2, ARow] <> 'N/A') and (gbChangeKP) then
  begin
    gsRow := ARow;
    gsKeyPartSN := GridKP.Cells[2, ARow];
  end;}
end;

procedure TfTravelCard.GridTravelDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var sValue, sField: string; i, iField: Integer;
begin
  if ARow <> 0 then
  begin
    sValue := TStringGrid(Sender).Hint;
    sField := Copy(sValue, 1, Pos(',', sValue) - 1);
    sValue := Copy(sValue, Pos(',', sValue) + 1, Length(sValue));
    iField := 0;
    for i := 0 to TStringGrid(Sender).ColCount - 1 do
      if UpperCase(TStringGrid(Sender).Cells[i, 0]) = UpperCase(sField) then
      begin
        iField := i;
        break;
      end;
    if TStringGrid(Sender).Cells[iField, ARow] = sValue then
      TStringGrid(Sender).Canvas.Brush.Color := clRed
    else
      TStringGrid(Sender).Canvas.Brush.Color := clWhite;
    TStringGrid(Sender).Canvas.Font.Color := clBlack;
    TStringGrid(Sender).Canvas.FillRect(Rect); //µe©³¦â
    TStringGrid(Sender).Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top + 2, TStringGrid(Sender).Cells[ACol, ARow]);
  end;
end;

procedure TfTravelCard.FormDestroy(Sender: TObject);
begin
  gsGrid.Free;
end;

procedure TfTravelCard.tpTravelChange(Sender: TObject);
begin
  if Pos('SN', gsSN) <> 0 then
  begin
    ShowSNData;
    gsSN := '';
  end;
end;

end.

