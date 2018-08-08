unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, RzButton, RzRadChk, ComCtrls,IniFiles;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    Image3: TImage;
    LabTitle2: TLabel;
    sbtnMaterial: TSpeedButton;
    LabTitle1: TLabel;
    QryTemp: TClientDataSet;
    Label1: TLabel;
    Label10: TLabel;
    sedtQty: TSpinEdit;
    Label2: TLabel;
    lablType: TLabel;
    Label9: TLabel;
    editMaterial: TEdit;
    Label12: TLabel;
    editPart: TEdit;
    Image1: TImage;
    sbtnClear: TSpeedButton;
    lablLocate: TLabel;
    cmbStock: TComboBox;
    cmbLocate: TComboBox;
    SProc: TClientDataSet;
    edtWo: TEdit;
    Label3: TLabel;
    lablMsg: TLabel;
    sgData: TStringGrid;
    lablLabel: TLabel;
    lablDesc: TLabel;
    chkPush: TRzCheckBox;
    Labwoqty: TLabel;
    DateTimePicker1: TDateTimePicker;
    edtFifo: TEdit;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    PanelShift: TPanel;
    PanelProcessName: TPanel;
    Label5: TLabel;
    Label8: TLabel;
    PanelLine: TPanel;
    PanelTerminal: TPanel;
    procedure FormShow(Sender: TObject);
    procedure sbtnMaterialClick(Sender: TObject);
    procedure editMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnClearClick(Sender: TObject);
    procedure cmbStockChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtWoKeyPress(Sender: TObject; var Key: Char);
    procedure DateTimePicker1Change(Sender: TObject);
  private
    { Private declarations }
    Function GetFIFOCode(dDate:TDateTime):string;
  public
    { Public declarations }
    UpdateUserID,Userno, gsType, gsGroupWo, gsLabelField, gsLocateField: string;
    slLocateId, slStockId: TStringList;
    gbFromWM: Boolean;
    sCnt: Integer;
    G_sTerminalID,G_sProcessID,G_sPDLineID : String;


    procedure ClearData;
    function CheckLot(var PartID, sLotNo: string; bChange: Boolean; var bContinue: Boolean): Boolean;
    function CheckPallet(var PartID: string; bChange: Boolean): Boolean;
    function CheckWo(var sVersion: string): Boolean;
    Function Getsystime: TdateTime;
    Function GetTerminalID : Boolean;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uCommData, uLogin;

Function TfDetail.Getsystime: TdateTime;
begin
  with QryTemp do
  begin
    close;
    Params.Clear;
    CommandText :=' SELECT SYSDATE FROM DUAL  ';
    open;
    Result := FieldByName('SYSDATE').asDateTime ;
  end;
end;

Function TfDetail.GetTerminalID : Boolean;
begin
  Result := False;
  With TIniFile.Create('SAJET.ini') do
  begin
     G_sTerminalID := ReadString('Material Management','Terminal','');
     Free;
  end;
  If G_sTerminalID = '' Then
  begin
     MessageDlg('Terminal not be assign !!',mtError, [mbCancel],0);
     Exit;
  end;
  With QryTemp do
  begin
    try
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'TERMINALID', ptInput);
      CommandText := 'Select A.PROCESS_ID,A.TERMINAL_NAME,B.PROCESS_NAME,C.PDLINE_NAME '+
                     '      ,A.PDLINE_ID '+
                     'From  SAJET.SYS_TERMINAL A,'+
                          ' SAJET.SYS_PROCESS B, '+
                          ' SAJET.SYS_PDLINE C '+
                      'Where   A.TERMINAL_ID = :TERMINALID '
                        +  ' AND A.PROCESS_ID = B.PROCESS_ID '
                        +  ' AND A.PDLINE_ID = C.PDLINE_ID ';
      Params.ParamByName('TERMINALID').AsString := G_sTerminalID ;
      Open;
      If RecordCount <= 0 Then
      begin
        Close;
        MessageDlg('Terminal data error !!',mtError, [mbCancel],0);
        Exit;
      end;
      G_sProcessID := FieldByName('PROCESS_ID').AsString;
      G_sPDLineID := FieldByName('PDLINE_ID').AsString;
      PanelProcessName.Caption := FieldbyName('Process_Name').AsString;
      PanelTerminal.Caption := FieldByName('Terminal_Name').AsString;
      PanelLine.Caption := FieldByName('PDLINE_NAME').AsString;
    finally
      Close;
    end;
  end;
  Result := True;
end;

Function TfDetail.GetFIFOCode(dDate:TDateTime):string;
var strDate:string;
begin
  sTrDate:=formatDateTime('YYYYMMDD',dDate);
  with sproc do
    begin
      try
        Close;
        DataRequest('SAJET.SJ_GET_fifo');
        FetchParams;
        Params.ParamByName('TDATE').AsString := sTrDate;
        Execute;
        IF Params.ParamByName('TRES').AsString='OK' THEN
          RESULT:=Params.ParamByName('FIFOCODE').AsString
        else
          Showmessage(Params.ParamByName('TRES').AsString);
      finally
        close;
      end;
    end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var sTable: string;
begin
  slLocateId := TStringList.Create;
  slStockId := TStringList.Create;
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  sgData.Cells[0, 0] := 'No';
  sgData.Cells[1, 0] := 'Work Order';
  sgData.Cells[3, 0] := 'Time';
  sCnt := 0;

  if not GetTerminalID then
      begin
         editmaterial.Enabled:=false;
         exit;
      end;
  with Qrytemp do
  begin
    close;
    Params.Clear;
    Params.CreateParam(ftString	,'USERID', ptInput);
    CommandText :=' SELECT EMP_NO FROM SAJET.SYS_EMP '
                 +' WHERE EMP_ID = :USERID AND ROWNUM=1 ';
    Params.ParamByName('USERID').AsString :=UpdateUserID;
    open;
    UserNo := FieldByName('EMP_NO').asString;
    //Get Shift Name
    close;
    Params.Clear;
    Params.CreateParam(ftString	,'PdlineID', ptInput);
    commandText:=' select a.shift_name '+
                 ' from sajet.sys_shift a,sajet.sys_pdline_shift_base b '+
                 ' where b.shift_id=a.shift_id and b.pdline_id=:PdlineID '+
                 '   and b.ACTIVE_FLAG=''Y'' and rownum=1 ';
    Params.ParamByName('PdlineID').AsString:=G_sPDLineID;
    open;
    if RecordCount=1 then
      PanelShift.Caption:=FieldByName('shift_name').AsString
    else
    begin
      editmaterial.Enabled :=false;
      MessageDlg('The Line'+'''s Shift not Define !!',mtError, [mbCancel],0);
      exit;
    end;
    close;
  end;


  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
    if gsType <> '' then
      CommandText := CommandText + 'and fun_param = ''' + gsType + ''' ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'PGIGOODSINCOMINGNOPUSHDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
    if gsType = 'Pallet No' then
      gsType := 'Goods';
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Locate'' ';
    Open;
    gsLocateField := FieldByName('param_name').AsString;
    Close;
  end;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select warehouse_id, warehouse_name '
      + 'from sajet.sys_warehouse where enabled = ''Y'' order by warehouse_name';
    Open;
    //cmbStock.Items.Add('');
    //slStockId.Add('');
    while not Eof do
    begin
      cmbStock.Items.Add(FieldByName('warehouse_name').AsString);
      slStockId.Add(FieldByName('warehouse_id').AsString);
      Next;
    end;
    sgData.Cells[2, 0] := Label9.Caption;
    if gsType <> 'Goods' then
    begin
      sTable := 'select WORK_ORDER,MATERIAL_NO,UPDATE_TIME FROM SAJET.G_SEMIFINISHED_INCOMING';
      //sgData.Cells[2,0] :='QC Lot No';
      lablLabel.Visible := True;
      lablDesc.Visible := True;
    end
    else
    begin
      sTable := 'select WORK_ORDER,MATERIAL_NO,UPDATE_TIME FROM SAJET.G_GOODS_INCOMING';
      //sgData.Cells[2,0] :='Pallet No';
    end;
    Close;
    Params.Clear;
    CommandText := sTable + ' where UPDATE_USERID=''' + UpdateUserID
      + ''' AND UPDATE_TIME > TO_DATE(TO_CHAR(SYSDATE,''YYYYMMDD''),''YYYYMMDD'') order by UPDATE_TIME ';
    Open;
    while not Eof do
    begin
      if sCnt = 0 then
        sgData.RowCount := 2
      else
        sgData.RowCount := sgData.RowCount + 1;
      sgData.Cells[0, sCnt + 1] := IntToStr(sCnt + 1);
      sgData.Cells[1, sCnt + 1] := FieldByName('WORK_ORDER').AsString;
      sgData.Cells[2, sCnt + 1] := FieldByName('MATERIAL_NO').AsString;
      sgData.Cells[3, sCnt + 1] := FieldByName('UPDATE_TIME').AsString;
      sgData.row := sgData.rowcount - 1;
      Inc(sCnt);
      Next;
    end;

    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then
    begin
      editMaterial.CharCase := ecUpperCase;
      editPart.CharCase := ecUpperCase;
      edtWo.CharCase := ecUpperCase;
    end;
    close;
  end;
  DateTimePicker1.DateTime:=now();
  edtFifo.Text:=GetFIFOCode(now());
  editMaterial.SetFocus;
end;

procedure TfDetail.sbtnMaterialClick(Sender: TObject);
  procedure InsertMaterial(sLotNo, sPartId, sVersion: string);
  begin
    with QryTemp do
    begin
      //入庫加入流程管控，過process
      if sLotNo = '' then
        begin
           with sproc do
           begin
              try
                  // KEY_WIP_INCOMING(tterminalid in number,tnow in date,TPALLET in varchar2,TEMPID IN varchar2, tres out varchar2)
                  Close;
                  DataRequest('SAJET.KEY_WIP_INCOMING');
                  FetchParams;
                  Params.ParamByName('TTERMINALID').AsString :=G_sTerminalID ;
                  Params.ParamByName('TPALLET').AsString := editMaterial.Text;
                  Params.ParamByName('tnow').AsDateTime  :=Getsystime;
                  Params.ParamByName('TEMPID').AsString :=UpdateUserID;
                  Execute;
                  IF   UPPerCASE(Params.ParamByName('TRES').AsString)<>'OK' then
                  begin
                    MessageDlg(Params.ParamByName('TRES').AsString, mtError, [mbOK], 0);
                    Close;
                    Exit;
                  end;
              finally
                 close;
              end;
         end;
      END;


      Close;
      Params.Clear;
      if gsType <> 'Goods' then
      begin
        Params.CreateParam(ftString, 'QC_LOTNO', ptInput);
        Params.CreateParam(ftString, 'update_userid', ptInput);
        Params.CreateParam(ftString, 'wo', ptInput);
        Params.CreateParam(ftString, 'material_no', ptInput);
        CommandText := 'insert into sajet.G_Semifinished_INCOMING '
          + '(QC_LOTNO, update_userid,work_order,material_no) '
          + 'values (:QC_LOTNO, :update_userid,:wo,:material_no) ';
        if sLotNo <> '' then
          Params.ParamByName('QC_LOTNO').AsString := sLotNo
        else
          Params.ParamByName('QC_LOTNO').AsString := editMaterial.Text;
        Params.ParamByName('update_userid').AsString := UpdateUserID;
        Params.ParamByName('wo').AsString := edtWo.text;
        Params.ParamByName('material_no').AsString := editMaterial.Text;
        Execute;
      end
      else
      begin
        Params.CreateParam(ftString, 'pallet_no', ptInput);
        Params.CreateParam(ftString, 'update_userid', ptInput);
        Params.CreateParam(ftString, 'wo', ptInput);
        Params.CreateParam(ftString, 'material_no', ptInput);
        CommandText := 'insert into sajet.g_goods_incoming '
          + '(pallet_no, update_userid,work_order,material_no) '
          + 'values (:pallet_no, :update_userid,:wo,:material_no) ';
        if sLotNo <> '' then
          Params.ParamByName('pallet_no').AsString := sLotNo
        else
          Params.ParamByName('pallet_no').AsString := editMaterial.Text;
        Params.ParamByName('update_userid').AsString := UpdateUserID;
        Params.ParamByName('wo').AsString := edtWo.text;
        Params.ParamByName('material_no').AsString := editMaterial.Text;
        Execute;
      end;
      Close;
      if (sLotNo <> '') or (gsType <> 'Goods') then
      begin
        Params.Clear;
        Params.CreateParam(ftString, 'PART_ID', ptInput);
        Params.CreateParam(ftString, 'material_no', ptInput);
        Params.CreateParam(ftString, 'material_qty', ptInput);
        Params.CreateParam(ftString, 'update_userid', ptInput);
        Params.CreateParam(ftString, 'warehouse_id', ptInput);
        Params.CreateParam(ftString, 'locate_id', ptInput);
        Params.CreateParam(ftString, 'version', ptInput);
        Params.CreateParam(ftString, 'FIFO', ptInput);
        CommandText := 'insert into sajet.g_material '
          + '(part_id, material_no, material_qty, update_userid, warehouse_id, locate_id, update_time, status, version,FIFOCOde) '
          + 'values (:part_id, :material_no, :material_qty, :update_userid, :warehouse_id, :locate_id, sysdate, ''1'', :version,:FIFO)';
        Params.ParamByName('PART_ID').AsString := sPartId;
        Params.ParamByName('material_no').AsString := editMaterial.Text;
        Params.ParamByName('material_qty').AsString := sedtQty.Text;
        Params.ParamByName('update_userid').AsString := UpdateUserID;
        Params.ParamByName('warehouse_id').AsString := slStockId[cmbStock.ItemIndex];
        if cmbLocate.ItemIndex <> -1 then
          Params.ParamByName('locate_id').AsString := slLocateId[cmbLocate.ItemIndex]
        else
          Params.ParamByName('locate_id').AsString := '';
        Params.ParamByName('version').AsString := sVersion;
        Params.ParamByName('FIFO').AsString := edtFIFO.Text;;
        Execute;
        Close;
{        if sType <> '' then
        begin
          sPrintData := G_getPrintData(6, 17, G_sockConnection, 'DspQryData', lablType.Caption + '*&*' + sMaterial, 1, 'DEFAULT');
          if assigned(G_onTransDataToApplication) then
            G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
          else
            showmessage('Not Defined Call Back Function for Code Soft');
        end; }
      end
      else
      begin
        Params.Clear;
        Params.CreateParam(ftString, 'update_userid', ptInput);
        Params.CreateParam(ftString, 'warehouse_id', ptInput);
        Params.CreateParam(ftString, 'locate_id', ptInput);
        Params.CreateParam(ftString, 'version', ptInput);
        Params.CreateParam(ftString, 'pallet_no', ptInput);
        Params.CreateParam(ftString, 'FIFO', ptInput);
        CommandText := 'insert into sajet.g_material '
          + '(part_id, material_no, material_qty, update_userid, warehouse_id, locate_id, update_time, status, version,FIFOCOde) '
          + 'select model_id, carton_no, count(*), :update_userid, :warehouse_id, :locate_id, sysdate, 1, :version,:FIFO '
          + 'from sajet.g_sn_status '
          + 'where pallet_no = :pallet_no '
          + 'group by model_id, carton_no ';
        Params.ParamByName('update_userid').AsString := UpdateUserID;
        Params.ParamByName('warehouse_id').AsString := slStockId[cmbStock.ItemIndex];
        if cmbLocate.ItemIndex <> -1 then
          Params.ParamByName('locate_id').AsString := slLocateId[cmbLocate.ItemIndex]
        else
          Params.ParamByName('locate_id').AsString := '';
        Params.ParamByName('version').AsString := sVersion;
        Params.ParamByName('pallet_no').AsString := editMaterial.Text;
        Params.ParamByName('FIFO').AsString := edtFIFO.Text;
        Execute;
        Close;
      end;
      // Upload Push Title
      with sproc do
      begin
        try
          Close;
          DataRequest('SAJET.MES_ERP_WIP_DELIVER');
          FetchParams;
          Params.ParamByName('TTYPE').AsString := gsType;
          Params.ParamByName('TWO').AsString := edtWo.Text;
          Params.ParamByName('TQTY').AsString := sedtQty.Text;
          Params.ParamByName('TSUBINV').AsString := cmbStock.Text;
          Params.ParamByName('TLOCATOR').AsString := cmbLocate.Text;
          {if chkPush.Checked then
            Params.ParamByName('TPUSH').AsString := 'Y'
          else  }
            Params.ParamByName('TPUSH').AsString := 'N';
          Params.ParamByName('TPALLET').AsString := editMaterial.Text;
          Params.ParamByName('TEMPID').AsString := UpdateUserID;
          Execute;
        finally
          close;
        end;
      end;
      if sCnt = 0 then
        sgData.RowCount := 2
      else
        sgData.RowCount := sgData.RowCount + 1;
      sgData.Cells[0, sCnt + 1] := IntToStr(sCnt + 1);
      sgData.Cells[1, sCnt + 1] := edtWo.Text;
      sgData.Cells[2, sCnt + 1] := editMaterial.Text;
      sgData.Cells[3, sCnt + 1] := FormatDateTime('YYYY-M-DD HH:NN:SS', NOW);
      sgData.row := sgData.rowcount - 1;
      Inc(sCnt);
      lablMsg.Caption := gsType + ': ' + editMaterial.Text + ' incoming OK.';
      //MessageDlg(lablMsg.Caption, mtInformation, [mbOK], 0);
      editMaterial.Text := '';
      editPart.Text := '';
      sedtQty.Text := '0';
      cmbStock.ItemIndex := -1;
      cmbLocate.Items.Clear;
      edtWo.Text := '';
      labwoqty.Caption := '';
      editMaterial.SetFocus;
    end;
  end;
var sPartID, sVersion, sLotNo: string; bContinue: Boolean;
begin
  if (cmbStock.Text = '') or ((cmbLocate.Items.Count > 0) and (cmbLocate.ItemIndex = -1)) then
  begin
    MessageDlg('Please select Locator!', mtWarning, [mbOK], 0);
    Exit;
  end;
  if sedtQty.Value <= 0 then Exit;
{  if gsType = 'Goods' then begin
    if CheckPallet(sPartID, False) then
      if CheckWo(sVersion) then
        InsertMaterial('', sPartId, sVersion);
  end else}
  if CheckLot(sPartID, sLotNo, False, bContinue) then
  begin
    if CheckWo(sVersion) then
      InsertMaterial(sLotNo, sPartId, sVersion);
  end
  else if (bContinue) and (CheckPallet(sPartID, False)) then
  begin
    if CheckWo(sVersion) then
      InsertMaterial('', sPartId, sVersion);
  end;
end;

function TfDetail.CheckWo(var sVersion: string): Boolean;
begin
  Result := True;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    CommandText := 'select target_qty, erp_qty, part_no, a.version '
      + 'from sajet.g_wo_base a, sajet.sys_part b '
      + 'where work_order = :work_order and a.model_id = b.part_id and rownum = 1';
    Params.ParamByName('work_order').AsString := edtWo.Text;
    Open;
    if IsEmpty then
    begin
      MessageDlg('Work Order: ' + edtWo.Text + ' not found!', mtError, [mbOK], 0);
      Result := False;
    end
    else if FieldByName('target_qty').AsInteger <> FieldByName('erp_qty').AsInteger then
    begin
      MessageDlg('Work Order: ' + edtWo.Text + ' Incoming Qty (' + FieldByName('erp_qty').AsString + ') <> Target Qty (' + FieldByName('target_qty').AsString + ')!', mtError, [mbOK], 0);
      Result := False;
    end
    else if FieldByName('part_no').AsString <> editPart.Text then
    begin
      MessageDlg('Work Order: ' + edtWo.Text + ' Part (' + FieldByName('part_no').AsString + ') not match.' + #13#13 + 'Goods Part: ' + editPart.Text, mtError, [mbOK], 0);
      Result := False;
    end;
    if not Result then
    begin
      edtWo.SetFocus;
      edtWo.SelectAll;
    end;
    sVersion := FieldByName('version').AsString;
    Close;
  end;
end;

procedure TfDetail.editMaterialKeyPress(Sender: TObject; var Key: Char);
var sPart, sLocate, sLotNo: string; bContinue: Boolean;
  sKey: Char;
begin
  sbtnMaterial.Enabled := False;
  lablMsg.Caption := '';
  labwoqty.Caption := '';
  sKey := #13;
  if Ord(Key) = vk_Return then
  begin
    sbtnMaterial.Enabled := CheckLot(sPart, sLotNo, True, bContinue);
    if (bContinue) and (not sbtnMaterial.Enabled) then
      sbtnMaterial.Enabled := CheckPallet(sPart, True);
    if sbtnMaterial.Enabled then
    begin
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
      QryTemp.CommandText := 'select locate_name, warehouse_name, b.warehouse_id, locate_id from sajet.sys_part a, sajet.sys_locate b, sajet.sys_warehouse c '
        + 'where part_id = :part_id and a.' + gsLocateField + ' = to_char(b.locate_id) and b.warehouse_id = c.warehouse_id and rownum = 1';
      QryTemp.Params.ParamByName('part_id').AsString := sPart;
      QryTemp.Open;
      cmbStock.ItemIndex := cmbStock.Items.IndexOf(QryTemp.FieldByName('Warehouse_name').AsString);
      sLocate := QryTemp.FieldByName('locate_name').AsString;
      if cmbStock.ItemIndex <> -1 then
      begin
        cmbStockChange(Self);
        cmbLocate.ItemIndex := cmbLocate.Items.IndexOf(sLocate);
      end;
      if uppercase(gstype)='GOODS' then
      begin
        if cmbstock.ItemIndex=-1 then
        begin
          qrytemp.Close;
          qrytemp.Params.Clear;
          qrytemp.CommandText:=' select * from sajet.sys_base where param_name=''ProductWarehouse'' ';
          qrytemp.Open;
          cmbstock.ItemIndex:=cmbstock.Items.IndexOf(qrytemp.fieldbyname('param_value').asstring);
          if cmbstock.ItemIndex<>-1 then
            cmbStockChange(Self);
        end;
      end;
      edtWoKeyPress(self, sKey);
    end;
    editMaterial.SelectAll;
    editMaterial.SetFocus;
  end;
end;

function TfDetail.CheckLot(var PartID, sLotNo: string; bChange: Boolean; var bContinue: Boolean): Boolean;
begin
  Result := False;
  bContinue := False;
  if editMaterial.Text = '0' then begin
    bContinue := True;
    Exit;
  end;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MATERIAL_NO', ptInput);
    CommandText := 'select MATERIAL_NO from SAJET.G_GOODS_INCOMING '
      + 'where MATERIAL_NO = :MATERIAL_NO and rownum = 1 ';
    Params.ParamByName('MATERIAL_NO').AsString := editMaterial.Text;
    Open;
    if not IsEmpty then
    begin
      MessageDlg('Lot No: ' + editMaterial.Text + ' had In Stocked!', mtError, [mbOK], 0);
      Close;
      Exit;
    end;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MATERIAL_NO', ptInput);
    CommandText := 'select MATERIAL_NO from SAJET.G_Semifinished_INCOMING '
      + 'where MATERIAL_NO = :MATERIAL_NO and rownum = 1 ';
    Params.ParamByName('MATERIAL_NO').AsString := editMaterial.Text;
    Open;
    if not IsEmpty then
    begin
      MessageDlg('Lot No: ' + editMaterial.Text + ' had In Stocked!', mtError, [mbOK], 0);
      Close;
      Exit;
    end;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'QC_Type', ptInput);
    CommandText := 'select QC_LotNo, qc_result, part_no, part_id, lot_size, work_order '
      + 'from SAJET.G_QC_LOT a, sajet.sys_part b '
      + 'where QC_Type = :QC_Type and a.model_id = b.part_id and rownum = 1 ';
    Params.ParamByName('QC_Type').AsString := editMaterial.Text;
    Open;
    if IsEmpty then
    begin
//      MessageDlg('Lot No: ' + editMaterial.Text + ' not found!', mtError, [mbOK], 0);
      bContinue := True;
      Close;
      Exit;
    end
    else if FieldByName('qc_result').AsString = '1' then
    begin
      MessageDlg('Lot No: ' + editMaterial.Text + ' Reject!', mtError, [mbOK], 0);
      Close;
      Exit;
    end
    else if FieldByName('qc_result').AsString = 'N/A' then
    begin
      MessageDlg('Lot No: ' + editMaterial.Text + ' never QC!', mtError, [mbOK], 0);
      Close;
      Exit;
{    end
    else if FieldByName('QC_TYPE').AsString = '0' then
    begin
      MessageDlg('Lot No: ' + editMaterial.Text + ' Type NG!', mtError, [mbOK], 0);
      Close;
      Exit; }
    end;
    PartID := FieldByName('part_id').AsString;
    editPart.Text := FieldByName('part_no').AsString;
    sedtQty.Value := FieldByName('lot_size').AsInteger;
    sLotNo := FieldByName('qc_lotno').AsString;
    if bChange then
      edtWo.Text := FieldByName('work_order').AsString;
    Close;
  end;
  Result := True;
end;

function TfDetail.CheckPallet(var PartID: string; bChange: Boolean): Boolean;
var sPartNo: string;
begin
  Result := False;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'pallet_no', ptInput);
    CommandText := 'select qc_lotno from sajet.G_Semifinished_INCOMING '
      + 'where qc_lotno = :pallet_no and rownum = 1 ';
    Params.ParamByName('pallet_no').AsString := editMaterial.Text;
    Open;
    if not IsEmpty then
    begin
      MessageDlg('Pallet: ' + editMaterial.Text + ' had In Stocked!', mtError, [mbOK], 0);
      Close;
      Exit;
    end;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'pallet_no', ptInput);
    CommandText := 'select pallet_no from sajet.g_goods_incoming '
      + 'where pallet_no = :pallet_no and rownum = 1 ';
    Params.ParamByName('pallet_no').AsString := editMaterial.Text;
    Open;
    if not IsEmpty then
    begin
      MessageDlg('Pallet: ' + editMaterial.Text + ' had In Stocked!', mtError, [mbOK], 0);
      Close;
      Exit;
    end;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'pallet_no', ptInput);
    CommandText := 'select close_flag, part_no, part_id '
      + 'from sajet.g_pack_pallet a, sajet.sys_part b '
      + 'where pallet_no = :pallet_no and a.model_id = b.part_id and rownum = 1 ';
    Params.ParamByName('pallet_no').AsString := editMaterial.Text;
    Open;
    if IsEmpty then
    begin
      MessageDlg('Pallet: ' + editMaterial.Text + ' not found!', mtError, [mbOK], 0);
      Close;
      Exit;
    end
    else if FieldByName('close_flag').AsString = 'N' then
    begin
      MessageDlg('Pallet: ' + editMaterial.Text + ' Unfinished!', mtError, [mbOK], 0);
      Close;
      Exit;
    end;
    sPartNo := FieldByName('part_no').AsString;
    PartID := FieldByName('part_id').AsString;
     // 因入庫程式加入流程管控，以下程式內容不被受限
     {
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'pallet_no', ptInput);
    CommandText := 'select serial_number from sajet.g_sn_status '
      + 'where pallet_no = :pallet_no and out_pdline_time is null and rownum = 1';
    Params.ParamByName('pallet_no').AsString := editMaterial.Text;
    Open;
    if not IsEmpty then
    begin
      MessageDlg('Serial Number: ' + FieldByName('serial_number').AsString + ' not complete!', mtError, [mbOK], 0);
      Close;
      Exit;
    end
    else
    begin
    }
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'pallet_no', ptInput);
      CommandText := 'select work_order, count(*) qty '
        + 'from sajet.g_sn_status '
        + 'where pallet_no = :pallet_no group by work_order ';
      Params.ParamByName('pallet_no').AsString := editMaterial.Text;
      Open;
      if FieldByName('qty').AsInteger = 0 then
      begin
        MessageDlg('Pallet: ' + editMaterial.Text + ' is Empty!', mtError, [mbOK], 0);
        Close;
        Exit;
      end;
      editPart.Text := sPartNo;
      sedtQty.Value := 0;
      while not Eof do
      begin
        sedtQty.Value := sedtQty.Value + FieldByName('qty').AsInteger;
        Next;
      end;
      if bChange then
        edtWo.Text := FieldByName('work_order').AsString;
      Close;
    end;
 // end;
  Result := True;
end;

procedure TfDetail.sbtnClearClick(Sender: TObject);
begin
  ClearData;
end;

procedure TfDetail.ClearData;
begin
  editMaterial.Text := '';
  editPart.Text := '';
  sedtQty.Text := '0';
  cmbStock.ItemIndex := -1;
  cmbLocate.Items.Clear;
  edtWo.Text := '';
  lablMsg.Caption := '';
  labwoqty.Caption := '';
end;

procedure TfDetail.cmbStockChange(Sender: TObject);
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'warehouse_id', ptInput);
    CommandText := 'select locate_id, locate_name from sajet.sys_locate '
      + 'where warehouse_id = :warehouse_id and enabled = ''Y''';
    Params.ParamByName('warehouse_id').AsString := slStockID[cmbStock.ItemIndex];
    Open;
    cmbLocate.Items.Clear;
    slLocateId.Clear;
    while not Eof do
    begin
      cmbLocate.Items.Add(FieldByName('locate_name').AsString);
      slLocateId.Add(FieldByName('locate_id').AsString);
      Next;
    end;
    if cmbLocate.Items.Count = 1 then
      cmbLocate.ItemIndex := 0;
    Close;
  end;
end;

procedure TfDetail.FormDestroy(Sender: TObject);
begin
  slLocateId.Free;
  slStockId.Free;
end;

procedure TfDetail.chkPushMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  fLogin := TfLogin.Create(Self);
  with fLogin do
  begin
    if ShowModal = mrOK then
    begin
      chkPush.Checked := not (chkPush.Checked);
      MessageDlg('Push Title Change OK', mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfDetail.edtWoKeyPress(Sender: TObject; var Key: Char);
begin
  labwoqty.Caption := '';
  if Ord(Key) = vk_Return then
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'wo', ptInput);
      CommandText := 'select target_qty,ERP_QTY from sajet.g_wo_base '
        + 'where work_order=:wo and rownum=1 ';
      Params.ParamByName('wo').AsString := edtWo.text;
      open;
      if RecordCount = 1 then
      begin
        labwoqty.Caption := FieldByName('ERP_QTY').AsString;
        if FieldByName('target_qty').AsInteger <> FieldByName('erp_qty').AsInteger then
        begin
          MessageDlg('Work Order: ' + edtWo.Text + ' Incoming Qty (' + QryTemp.FieldByName('erp_qty').AsString + ') <> Target Qty (' + FieldByName('target_qty').AsString + ')!', mtError, [mbOK], 0);
          exit;
        end
      end
      else
      begin
        MessageDlg('Work Order Error!', mtError, [mbOK], 0);
        edtWo.SelectAll;
        edtWo.SetFocus;
        exit;
      end;
    end;
  end;
end;

procedure TfDetail.DateTimePicker1Change(Sender: TObject);
begin
  edtFifo.Text:=GetFIFOCode(DateTimePicker1.DateTime);
end;

end.

