unit uReprintLabel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls,
  Db, DBClient, MConnect, SConnect, IniFiles, ObjBrkr, ImgList, Menus, unitHeadSajet, unitConvert,
  unitTreeView, CheckLst, Clrgrid;

type
  TfReprintLabel = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    Image1: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    Label4: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label14: TLabel;
    editSN: TEdit;
    DataSource1: TDataSource;
    cmbType: TComboBox;
    ImageList1: TImageList;
    Label3: TLabel;
    Image3: TImage;
    Image4: TImage;
    Label5: TLabel;
    sbtnReprint: TSpeedButton;
    imgInitial: TImage;
    sbtnInitial: TSpeedButton;
    lablLabel: TLabel;
    lablDesc: TLabel;
    cstrGridData: TColorStringGrid;
    Label2: TLabel;
    lablQueryQty: TLabel;
    lvSelectedPallet: TListView;
    Label6: TLabel;
    lablSelectRowCount: TLabel;
    PopupMenu1: TPopupMenu;
    DeleteSN1: TMenuItem;
    DeleteCarton1: TMenuItem;
    DeletePallet1: TMenuItem;
    DeleteAll1: TMenuItem;
    GroupBox1: TGroupBox;
    rbtnPalletLab: TRadioButton;
    rbtnCartonLab: TRadioButton;
    rbtnBoxLab: TRadioButton;
    rbtnSNLab: TRadioButton;
    procedure editSNKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure sbtnExecuteClick(Sender: TObject);
    procedure cmbTypeChange(Sender: TObject);
    procedure sbtnInitialClick(Sender: TObject);
    procedure rbtnPalletLabClick(Sender: TObject);
    procedure rbtnCartonLabClick(Sender: TObject);
    procedure rbtnSNLabClick(Sender: TObject);
    procedure cstrGridDataGetCellColor(Sender: TObject; ARow,
      ACol: Integer; AState: TGridDrawState; ABrush: TBrush; AFont: TFont);
    procedure cstrGridDataSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure cstrGridDataDblClick(Sender: TObject);
    procedure DeleteSN1Click(Sender: TObject);
    procedure rbtnBoxLabClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID: string;
    FCID, gsPartNo, gsWO,gsLabelFile: string;
    bFindSN: Boolean;
    Authoritys, AuthorityRole: string;
    G_iColumn, G_iCol, G_iRow: Integer;
    procedure showSNData;
    procedure DspData;
    procedure SetStatusbyAuthority;
    function GetCfgData: Boolean;
    function GetTerminalID: Boolean;
  end;

var
  fReprintLabel: TfReprintLabel;
function SendData(iType, PrintLabQty: integer; tsParam, tsData: TStrings; PComPort, PBaudRate: string; G_sockConnection: TSocketConnection): Boolean; stdcall; external 'PackingPrintdll.DLL';
function PrintInitial(iType: integer; PcomPort, PBaudRate, sPartNo, sWO,sLabelFile: string): Boolean; stdcall; external 'PackingPrintdll.DLL';
function G_getPrintData(f_iVersion, f_iType: integer; f_SocketConnection: TSocketConnection; f_sProvideName, f_sKeyWord: string; f_iQty: integer; f_sRuleName: string; var g_tsParam, g_tsData: tstrings): string; stdcall; external 'GetPrintDataDll.DLL';
implementation

{$R *.DFM}

uses Dllinit, uDllform;

var
  TerminalID: string;
  PrintBoxLabel, PrintCSNLabel, PrintCartonLabel, PrintPalletLabel: Boolean;
  PrintBoxMethod, PrintCSNMethod, PrintCartonMethod, PrintPalletMethod: string;
  PrintBoxLabQty, PrintCSNLabQty, PrintCartonLabQty, PrintPalletLabQty: Integer;
  PackingBase: string;
  CodesoftVersion: Byte;
  mPalletComPort, mCartonComPort, mCSNComPort, mBoxComPort: string;
  mPalletBaudRate, mCartonBaudRate, mCSNBaudRate, mBoxBaudRate: string;

procedure TfReprintLabel.SetStatusbyAuthority;
var iPrivilege: integer;
begin
  iPrivilege := 0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Packing';
      Params.ParamByName('FUN').AsString := 'Reprint';
      Execute;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;
  sbtnReprint.Enabled := (iPrivilege >= 1);
end;

procedure TfReprintLabel.editSNKeyPress(Sender: TObject; var Key: Char);
var iRow: integer;
begin
  if Key = #13 then
  begin
    lablQueryQty.Caption := '0';
    lablSelectRowCount.Caption := '0';
    for iRow := 1 to cStrGridData.RowCount - 1 do
      cStrGridData.Rows[iRow].Clear;
    cStrGridData.RowCount := 2;
    lvSelectedPallet.Clear;
    bFindSN := False;
    if editSN.Text = '' then Exit;
    showSNData;
  end;
end;

procedure TfReprintLabel.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  cstrGridData.Cells[0, 0] := 'Work Order';
  cstrGridData.Cells[1, 0] := 'Pallet No';
  cstrGridData.Cells[2, 0] := 'Carton No';
  cstrGridData.Cells[3, 0] := 'Box No';
  cstrGridData.Cells[4, 0] := 'Customer SN';
  cstrGridData.Cells[5, 0] := 'Serial Number';

  sbtnReprint.Enabled := false;

  cmbType.ItemIndex := 0;

  if not GetTerminalID then
  begin
    sbtnReprint.Enabled := False;
    exit;
  end;
  if not GetCfgData then
  begin
    sbtnReprint.Enabled := False;
    exit;
  end;

  if UpdateUserID <> '0' then
    SetStatusbyAuthority;

  rbtnSNLab.Checked := True;
  rbtnSNLab.OnClick(self);
  editSN.SetFocus;
end;

procedure TfReprintLabel.showSNData;
begin
  DspData;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    CommandText := 'Select b.PART_NO ,B.LABEL_FILE '
      + 'From SAJET.G_WO_BASE a,SAJET.SYS_PART b '
      + 'Where a.WORK_ORDER = :WORK_ORDER '
      + 'and a.MODEL_ID = b.PART_ID ';
    Params.ParamByName('WORK_ORDER').AsString := cstrGridData.Cells[0, 1];
    Open;
    gsPartNo := FieldByName('PART_NO').asstring;
    gsLabelFile := FieldByName('LABEL_FILE').asstring;
    Close;
  end;
end;

procedure TfReprintLabel.DspData;
var sPalletNo, sCartonNo, sBoxNo: string; iRow: integer;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DATA', ptInput);
    CommandText := 'Select Work_Order, Pallet_No, Carton_No, Box_No, Customer_SN, Serial_Number '
                    +' From SAJET.G_SN_STATUS  ';
    case cmbType.ItemIndex of
      0: CommandText := CommandText + 'Where Work_Order = :DATA ';
      1: CommandText := CommandText + 'Where Pallet_No = :DATA ';
      2: CommandText := CommandText + 'WHERE Carton_No = :DATA ';
      3: CommandText := CommandText + 'Where Box_No = :DATA ';
      4: CommandText := CommandText + 'Where Customer_SN = :DATA ';
      5: CommandText := CommandText + 'Where Serial_Number = :DATA ';
    end;
    CommandText := CommandText + 'Order By Pallet_No, Carton_No, Box_No, Customer_SN, Serial_Number ';
    Params.ParamByName('DATA').AsString := Trim(editSN.Text);
    Open;

    if recordcount = 0 then
    begin
      showmessage('No Such Data Exist');
      editSN.SelectAll;
      editSN.SetFocus;
      exit;
    end;

    first;

    sPalletNo := '';
    sCartonNo := '';
    sBoxNo := '';

    iRow := 0;

    while not eof do
    begin
      inc(iRow);
      if sPalletNo <> FieldbyName('PALLET_NO').AsString then
        cStrGridData.Cells[10, iRow] := '0';
      if sCartonNo <> FieldbyName('CARTON_NO').AsString then
        cStrGridData.Cells[11, iRow] := '0';
      if sBoxNo <> FieldbyName('Box_No').AsString then
        cStrGridData.Cells[12, iRow] := '0';
      cStrGridData.Cells[0, iRow] := FieldByName('Work_order').AsString;
      cStrGridData.Cells[1, iRow] := FieldByName('PALLET_NO').AsString;
      cStrGridData.Cells[2, iRow] := FieldByName('CARTON_NO').AsString;
      cStrGridData.Cells[3, iRow] := FieldByName('Box_No').AsString;
      cStrGridData.Cells[4, iRow] := FieldByName('Customer_SN').AsString;
      cStrGridData.Cells[5, iRow] := FieldByName('Serial_Number').AsString;
      sPalletNo := FieldByName('PALLET_NO').AsString;
      sCartonNO := FieldByName('CARTON_NO').AsString;
      sBoxNO := FieldByName('Box_No').AsString;
      next;
    end;
    if iRow > 0 then
      cStrGridData.RowCount := iRow + 1
    else
      cStrGridData.RowCount := 2;
    lablQueryQty.Caption := IntToStr(iRow);
  end;
end;

procedure TfReprintLabel.sbtnExecuteClick(Sender: TObject);
var i: integer; node: TTreeNode; sPrintData, sNo: string;
  g_tsParam, g_tsData, g_tsNo: TStrings;
begin
  try
    g_tsNo := TStringList.Create;
    try
      if (rbtnSNLab.Checked and (PrintCSNMethod = 'CodeSoft')) or
        (rbtnBoxLab.Checked and (PrintBoxMethod = 'CodeSoft')) or
        (rbtnCartonLab.Checked and (PrintCartonMethod = 'CodeSoft')) or
        (rbtnPalletLab.Checked and  (PrintPalletMethod = 'CodeSoft')) then
        if not Assigned(G_onTransDataToApplication) then
        raise Exception.create('Not Assigned Call Back Function for CodeSoft');

      if lvSelectedPallet.Items.Count = 0 then exit;

      //Print Pallet
      if rbtnPalletLab.Checked then
      begin
        for i := 0 to lvSelectedPallet.Items.Count - 1 do
          if lvSelectedPallet.Items[I].Caption <> 'N/A' then
          begin
            if g_tsNo.IndexOf(lvSelectedPallet.Items[I].Caption) = -1 then
            begin
              g_tsNo.Add(lvSelectedPallet.Items[I].Caption);
            end;
          end;
        if g_tsNo.Count = 0 then
            MessageDlg('Invalid Pallet No : N/A ', mtWarning, [mbOK], 0);
        for i := 0 to g_tsNo.Count - 1 do
        begin
          sNo := g_tsNo.Strings[i];
          if sNo = 'N/A' then
          begin
            MessageDlg('Invalid Pallet No : N/A ', mtWarning, [mbOK], 0);
            Break;
          end;
          
          with QryTemp do
              begin
                Close;
                Params.Clear;
                Params.CreateParam(ftString, 'PALLET_NO',ptInput);
                CommandText := 'Select CLOSE_FLAG FROM SAJET.G_PACK_PALLET WHERE PALLET_NO=:PALLET_NO';
                Open;
                Params.ParamByName('PALLET_NO').AsString := sNo;

                if FieldbyName('CLOSE_FLAG').AsString<> 'Y' then
                begin
                  showmessage('Pallet_NO Unfinished,Please Close Pallet');
                  editSN.SelectAll;
                  editSN.SetFocus;
                  exit;
                end;
              end;
          if PrintPalletMethod = 'CodeSoft' then begin
            sPrintData := G_getPrintData(CodesoftVersion, 1, G_sockConnection, 'DspQryData', sNo, PrintCSNLabQty, '', g_tsParam, g_tsData);
            G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
          end else if PrintPalletMethod = 'DLL' then begin
            sPrintData := G_getPrintData(-1, 1, G_sockConnection, 'DspQryData', sNo, PrintCSNLabQty, '', g_tsParam, g_tsData);
            if not SendData(1, PrintPalletLabQty, g_tsParam, g_tsData, mPalletComPort, mPalletBaudRate, G_sockConnection) then exit; //PrintPalletdll.DLL
          end;
        end;
      end else if (rbtnCartonLab.Checked) then // Print Carton
      begin
        for i := 0 to lvSelectedPallet.Items.Count - 1 do
          if lvSelectedPallet.Items[I].subitems[0] <> 'N/A' then
          begin
            if g_tsNo.IndexOf(lvSelectedPallet.Items[I].subitems[0]) = -1 then
            begin
              g_tsNo.Add(lvSelectedPallet.Items[I].subitems[0]);
            end;
          end;
        if g_tsNo.Count = 0 then
            MessageDlg('Invalid Carton No : N/A ', mtWarning, [mbOK], 0);
        for i := 0 to g_tsNo.Count - 1 do
        begin
          sNo := g_tsNo.Strings[i];
          if sNo = 'N/A' then
          begin
            MessageDlg('Invalid Carton No : N/A ', mtWarning, [mbOK], 0);
            Continue;
          end;
          if PrintCartonMethod = 'CodeSoft' then begin
            sPrintData := G_getPrintData(CodesoftVersion, 2, G_sockConnection, 'DspQryData', sNo, PrintCartonLabQty, '', g_tsParam, g_tsData);
            G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
          end else if PrintCartonMethod = 'DLL' then begin
            sPrintData := G_getPrintData(-1, 2, G_sockConnection, 'DspQryData', sNo, PrintCartonLabQty, '', g_tsParam, g_tsData);
            if not SendData(2, PrintCartonLabQty, g_tsParam, g_tsData, mCartonComPort, mCartonBaudRate, G_sockConnection) then exit; //PrintCartondll.DLL
          end;
        end;
      end else if (rbtnBoxLab.Checked) then // Print Box
      begin
        for i := 0 to lvSelectedPallet.Items.Count - 1 do
          if lvSelectedPallet.Items[I].subitems[1] <> 'N/A' then
          begin
            if g_tsNo.IndexOf(lvSelectedPallet.Items[I].subitems[1]) = -1 then
            begin
              g_tsNo.Add(lvSelectedPallet.Items[I].subitems[1]);
            end;
          end;
        if g_tsNo.Count = 0 then
            MessageDlg('Invalid Box No : N/A ', mtWarning, [mbOK], 0);
        for i := 0 to g_tsNo.Count - 1 do
        begin
          sNo := g_tsNo.Strings[i];
          if sNo = 'N/A' then
          begin
            MessageDlg('Invalid Box No : N/A ', mtWarning, [mbOK], 0);
            Continue;
          end;
          if PrintCartonMethod = 'CodeSoft' then begin
            sPrintData := G_getPrintData(CodesoftVersion, 16, G_sockConnection, 'DspQryData', sNo, PrintCartonLabQty, '', g_tsParam, g_tsData);
            G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
          end else if PrintCartonMethod = 'DLL' then begin
            sPrintData := G_getPrintData(-1, 16, G_sockConnection, 'DspQryData', sNo, PrintCartonLabQty, '', g_tsParam, g_tsData);
            if not SendData(4, PrintCartonLabQty, g_tsParam, g_tsData, mCartonComPort, mCartonBaudRate, G_sockConnection) then exit; //PrintCartondll.DLL
          end;
        end;
      end else if rbtnSNLab.Checked then //Print SN
      begin
        for i := 0 to lvSelectedPallet.Items.Count - 1 do
        begin
          sNo := lvSelectedPallet.Items[i].SubItems[3];
          if sNo = 'N/A' then
          begin
            MessageDlg('Invalid Serial Number : N/A ', mtWarning, [mbOK], 0);
            continue;
          end;
          if PrintCSNMethod = 'CodeSoft' then begin
            sPrintData := G_getPrintData(CodesoftVersion, 3, G_sockConnection, 'DspQryData', sNo, PrintCSNLabQty, '', g_tsParam, g_tsData);
            G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
          end else if PrintCSNMethod = 'DLL' then begin
            sPrintData := G_getPrintData(-1, 3, G_sockConnection, 'DspQryData', sNo, PrintCSNLabQty, '', g_tsParam, g_tsData);
            if not SendData(3, PrintCSNLabQty, g_tsParam, g_tsData, mCSNComPort, mCSNBaudRate, G_sockConnection) then exit; //PrintCSNdll.DLL
          end;
        end;
      end;
    except
      on E: Exception do ShowMessage(E.message);
    end;
  finally
    g_tsNo.Free;
  end;
end;

procedure TfReprintLabel.cmbTypeChange(Sender: TObject);
begin
  //editSN.Text := '';
  editSN.SetFocus;
  editSN.SelectAll;
end;

function TfReprintLabel.GetCfgData: Boolean;
begin
  Result := False;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'Select * ' +
      'From SAJET.SYS_MODULE_PARAM ' +
      'Where MODULE_NAME = :MODULE_NAME and ' +
      'FUNCTION_NAME = :FUNCTION_NAME and ' +
      'PARAME_NAME = :TERMINALID ';
    Params.ParamByName('MODULE_NAME').AsString := 'PACKING';
    Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
    Params.ParamByName('TERMINALID').AsString := TerminalID;
    Open;
    if RecordCount <= 0 then
    begin
      Close;
      MessageDlg('Configuration not Exist !!', mtError, [mbCancel], 0);
      Exit;
    end;

    while not Eof do
    begin
        //Customer SN
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Customer SN Label' then
        PrintCSNLabel := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Customer SN Label Method' then
        PrintCSNMethod := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Customer SN Label Qty' then
        PrintCSNLabQty := StrToIntDef(Fieldbyname('PARAME_VALUE').AsString, 1)
      else if Fieldbyname('PARAME_ITEM').AsString = 'Customer SN COM Port' then
        mCSNComPort := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Customer SN BaudRate' then
        mCSNBaudRate := Fieldbyname('PARAME_VALUE').AsString
      //Box
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Box No Label' then
        PrintBoxLabel := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Box No Label Method' then
        PrintBoxMethod := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Box No Label Qty' then
        PrintBoxLabQty := StrToIntDef(Fieldbyname('PARAME_VALUE').AsString, 1)
      else if Fieldbyname('PARAME_ITEM').AsString = 'Box No COM Port' then
        mBoxComPort := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Box No BaudRate' then
        mBoxBaudRate := Fieldbyname('PARAME_VALUE').AsString
        //Carton
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Carton No Label' then
        PrintCartonLabel := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Carton No Label Method' then
        PrintCartonMethod := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Carton No Label Qty' then
        PrintCartonLabQty := StrToIntDef(Fieldbyname('PARAME_VALUE').AsString, 1)
      else if Fieldbyname('PARAME_ITEM').AsString = 'Carton No COM Port' then
        mCartonComPort := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Carton No BaudRate' then
        mCartonBaudRate := Fieldbyname('PARAME_VALUE').AsString
        //Pallet
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Pallet No Label' then
        PrintPalletLabel := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Pallet No Label Method' then
        PrintPalletMethod := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Pallet No Label Qty' then
        PrintPalletLabQty := StrToIntDef(Fieldbyname('PARAME_VALUE').AsString, 1)
      else if Fieldbyname('PARAME_ITEM').AsString = 'Pallet No COM Port' then
        mPalletComPort := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Pallet No BaudRate' then
        mPalletBaudRate := Fieldbyname('PARAME_VALUE').AsString

      else if Fieldbyname('PARAME_ITEM').AsString = 'Packing Base' then
        PackingBase := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'CodeSoft' then
      begin
        if Fieldbyname('PARAME_VALUE').AsString = 'Version 4' then
          CodesoftVersion := 4
        else if Fieldbyname('PARAME_VALUE').AsString = 'Version 5' then
          CodesoftVersion := 5
        else
          CodesoftVersion := 6;
      end;
      Next;
    end;

    Close;
  end;
  Result := True;
end;

function TfReprintLabel.GetTerminalID: Boolean;
begin
  Result := False;

  with TIniFile.Create('SAJET.ini') do
  begin
    TerminalID := ReadString('Packing', 'Terminal', '');
    Free;
  end;

  if TerminalID = '' then
  begin
    MessageDlg('Terminal not be assign !!', mtError, [mbCancel], 0);
    Exit;
  end;

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'Select A.TERMINAL_NAME,B.PROCESS_NAME ' +
      'From SAJET.SYS_TERMINAL A,' +
      'SAJET.SYS_PROCESS B ' +
      'Where A.TERMINAL_ID = :TERMINALID and ' +
      'A.PROCESS_ID = B.PROCESS_ID ';
    Params.ParamByName('TERMINALID').AsString := TerminalID;
    Open;
    if RecordCount <= 0 then
    begin
      Close;
      MessageDlg('Terminal data error !!', mtError, [mbCancel], 0);
      Exit;
    end;
    Close;
  end;
  Result := True;
end;

procedure TfReprintLabel.sbtnInitialClick(Sender: TObject);
var iType: Integer;
begin
  if lvSelectedPallet.Items.Count <> 0 then
  begin
    Showmessage('Initial Now ! Please Wait...');
    if rbtnSNLab.Checked then
      iType := 3
    else if rbtnCartonLab.Checked then
      iType := 2
    else if rbtnPalletLab.Checked then
      iType := 1
    else
      iType := 4;

    if not PrintInitial(iType, mCSNComPort, mCSNBaudRate, gsPartNo, gsWO,gsLabelFile) then
      Showmessage('Initial Fail')
    else
      Showmessage('Initial OK');
  end;
end;

procedure TfReprintLabel.rbtnPalletLabClick(Sender: TObject);
begin
  sbtnInitial.Visible := False;
  imgInitial.Visible := False;
  if PrintPalletMethod = 'DLL' then
  begin
    sbtnInitial.Visible := True;
    imgInitial.Visible := True;
  end;
  lablDesc.Caption := 'P_ + WO / P_+ Part No / P_+ Default';
end;

procedure TfReprintLabel.rbtnCartonLabClick(Sender: TObject);
begin
  sbtnInitial.Visible := False;
  imgInitial.Visible := False;
  if PrintCartonMethod = 'DLL' then
  begin
    sbtnInitial.Visible := True;
    imgInitial.Visible := True;
  end;
  lablDesc.Caption := 'C_ + WO / C_+ Part No / C_+ Default';
end;

procedure TfReprintLabel.rbtnSNLabClick(Sender: TObject);
begin
  sbtnInitial.Visible := False;
  imgInitial.Visible := False;
  if PrintCSNMethod = 'DLL' then
  begin
    sbtnInitial.Visible := True;
    imgInitial.Visible := True;
  end;
  lablDesc.Caption := 'S_ + WO / S_+ Part No / S_+ Default';
end;

procedure TfReprintLabel.cstrGridDataGetCellColor(Sender: TObject; ARow,
  ACol: Integer; AState: TGridDrawState; ABrush: TBrush; AFont: TFont);
begin
  if (ACol = 1) then
  begin
    if cstrGridData.Cells[10, ARow] = '0' then
    begin
      ABrush.Color := clGreen;
      AFont.Color := clwhite;
    end;
  end;
  if (ACol = 2) then
  begin
    if cstrGridData.Cells[11, ARow] = '0' then
    begin
      ABrush.Color := clSkyBlue;
      AFont.Color := clBlack;
    end;
  end;
  if (ACol = 3) then
  begin
    if cstrGridData.Cells[12, ARow] = '0' then
    begin
      ABrush.Color := clMoneyGreen;
      AFont.Color := clBlack;
    end;
  end;
end;

procedure TfReprintLabel.cstrGridDataSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  G_iRow := ARow;
  G_iCol := ACol;
end;

procedure TfReprintLabel.cstrGridDataDblClick(Sender: TObject);
var i: integer; bExit: Boolean; sPalletNO, sCartonNo, sBoxNo, sCSN, sSN: string;
begin
  sPalletNO := cstrGridData.Cells[1, G_iRow];
  sCartonNo := cstrGridData.Cells[2, G_iRow];
  sBoxNo := cstrGridData.Cells[3, G_iRow];
  sCSN := cstrGridData.Cells[4, G_iRow];
  sSN := cstrGridData.Cells[5, G_iRow];
  if G_iCol = 0 then //¥þ¿ï
  begin
    lvSelectedPallet.Clear;
    for i := 1 to cstrGridData.RowCount - 1 do
    begin
      with lvSelectedPallet.Items.add do
      begin
        Caption := cstrGridData.Cells[1, i];
        SubItems.Add(cstrGridData.Cells[2, i]);
        SubItems.Add(cstrGridData.Cells[3, i]);
        SubItems.Add(cstrGridData.Cells[4, i]);
        SubItems.Add(cstrGridData.Cells[5, i]);
      end;
    end;
  end else begin
    if cstrGridData.Cells[G_iCol, G_iRow] = 'N/A' then
    begin
      MessageDlg('Cann''t Select ''N/A''!', mtWarning, [mbOK], 0);
      Exit;
    end;
    for i := lvSelectedPallet.Items.Count - 1 downto 0 do
    begin
      if G_iCol = 1 then
      begin
        if lvSelectedPallet.Items[i].Caption = cstrGridData.Cells[G_iCol, G_iRow] then
          lvSelectedPallet.Items[i].Delete;
      end else
        if lvSelectedPallet.Items[i].SubItems[G_iCol - 2] = cstrGridData.Cells[G_iCol, G_iRow] then
          lvSelectedPallet.Items[i].Delete;
    end;      
    for i := 1 to cstrGridData.RowCount - 1 do
    begin
      if cstrGridData.Cells[G_iCol, i] = cstrGridData.Cells[G_iCol, G_iRow] then
      begin
        with lvSelectedPallet.Items.add do
        begin
          Caption := cstrGridData.Cells[1, i];
          SubItems.Add(cstrGridData.Cells[2, i]);
          SubItems.Add(cstrGridData.Cells[3, i]);
          SubItems.Add(cstrGridData.Cells[4, i]);
          SubItems.Add(cstrGridData.Cells[5, i]);
        end;
      end;
    end;
  end;
  lablSelectRowCount.Caption := IntToStr(lvSelectedPallet.Items.Count);
end;

procedure TfReprintLabel.DeleteSN1Click(Sender: TObject);
var iIndex, i: integer;
  iResult: Integer;
  sCarton, sPallet: string;
begin
  if lvSelectedPallet.Items.Count = 0 then exit;
  iIndex := lvSelectedPallet.Selected.Index;
  iResult := ((Sender as TMenuItem).Tag);
  if iResult = 0 then
  begin
    lvSelectedPallet.Items[iIndex].Delete;
  end;
  if iResult = 1 then
  begin
    iIndex := lvSelectedPallet.Selected.Index;
    sCarton := lvSelectedPallet.Items[iIndex].SubItems[0];
    for i := lvSelectedPallet.Items.Count - 1 downto 0 do
    begin
      if lvSelectedPallet.Items[i].Subitems[0] = sCarton then
        lvSelectedPallet.Items[i].Delete;
    end;
  end;
  if iResult = 2 then
  begin
    sPallet := lvSelectedPallet.Items[iIndex].Caption;
    for i := lvSelectedPallet.Items.Count - 1 downto 0 do
    begin
      if lvSelectedPallet.Items[i].Caption = sPallet then
        lvSelectedPallet.Items[i].Delete;
    end;
  end;
  if iResult = 3 then
  begin
    lvSelectedPallet.Items.Clear;
  end;
  lablSelectRowCount.Caption := IntToStr(lvSelectedPallet.Items.Count);
end;

procedure TfReprintLabel.rbtnBoxLabClick(Sender: TObject);
begin
  sbtnInitial.Visible := False;
  imgInitial.Visible := False;
  if PrintBoxMethod = 'DLL' then
  begin
    sbtnInitial.Visible := True;
    imgInitial.Visible := True;
  end;
  lablDesc.Caption := 'B_ + WO / B_+ Part No / B_+ Default';
end;

end.

