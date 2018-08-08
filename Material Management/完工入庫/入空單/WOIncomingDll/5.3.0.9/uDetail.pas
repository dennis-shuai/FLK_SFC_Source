unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, RzButton, RzRadChk;

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
    chkPush: TRzCheckBox;
    Labwoqty: TLabel;
    Label4: TLabel;
    EditORG: TEdit;
    procedure FormShow(Sender: TObject);
    procedure sbtnMaterialClick(Sender: TObject);
    procedure editMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnClearClick(Sender: TObject);
    procedure cmbStockChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtWoKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsType, gsGroupWo, gsLabelField, gsLocateField: string;
    slLocateId, slStockId: TStringList;
    gbFromWM: Boolean;
    sCnt: Integer;
    G_FCID,G_FCCODE,G_FCTYPE:string;
    procedure ClearData;
    function CheckLot(var PartID: string; bChange: Boolean; var bContinue: Boolean): Boolean;
    function CheckPallet(var PartID: string; bChange: Boolean): Boolean;
    function CheckWo: Boolean;
    Function Getfctype(sFCid:string):string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uCommData, uLogin;

Function TfDetail.Getfctype(sFCid:string):string;
var strDate:string;
begin
  with sproc do
    begin
      try
        Close;
        DataRequest('SAJET.SJ_GET_FACTORY_TYPE');
        FetchParams;
        Params.ParamByName('TFCID').AsString := sFCid;
        Execute;
        IF Params.ParamByName('TRES').AsString='OK' THEN
        begin
           G_FCCODE:=Params.ParamByName('TFCCODE').AsString;
           G_FCTYPE:=Params.ParamByName('TFCTYPE').AsString;
           result:='OK';
        end
        else
        begin
          Showmessage(Params.ParamByName('TRES').AsString);
          result:=Params.ParamByName('TRES').AsString;
        end;
      finally
        close;
      end;
    end;
end;

procedure TfDetail.FormShow(Sender: TObject);
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
  sgData.Cells[0,0] :='No';
  sgData.Cells[1,0] :='Work Order';
  sgData.Cells[3,0] :='Time';
  sCnt:=0;
  with QryTemp do begin
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
    Params.ParamByName('dll_name').AsString := 'WOINCOMINGDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
    Label9.Caption := gsType;
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
    sgData.Cells[2,0] :=Label9.Caption ;
    {if gsType <> 'Goods' then
    begin
      sTable:='select WORK_ORDER,QC_LOTNO,UPDATE_TIME FROM SAJET.G_SEMIFINISHED_INCOMING';
      //sgData.Cells[2,0] :='QC Lot No';
    end else
    begin
      sTable:='select WORK_ORDER,PALLET_NO,UPDATE_TIME FROM SAJET.G_GOODS_INCOMING';
      //sgData.Cells[2,0] :='Pallet No';
    end; }
    {Close;
    Params.Clear;
    CommandText := sTable +' where UPDATE_USERID='''+UpdateUserID
      + ''' AND UPDATE_TIME > TO_DATE(TO_CHAR(SYSDATE,''YYYYMMDD''),''YYYYMMDD'') order by UPDATE_TIME ';
    Open;
    {if gsType <> 'Goods' then
    begin
      while not Eof do
      begin
        if sCnt=0 then
          sgData.RowCount:=2
        else
          sgData.RowCount:=sgData.RowCount+1;
        sgData.Cells[0, sCnt+1]:=IntToStr(sCnt+1);
        sgData.Cells[1, sCnt+1]:=FieldByName('WORK_ORDER').AsString;
        sgData.Cells[2, sCnt+1]:=FieldByName('QC_LOTNO').AsString;
        sgData.Cells[3, sCnt+1]:=FieldByName('UPDATE_TIME').AsString;
        sgData.row:=sgData.rowcount-1;
        Inc(sCnt);
        Next;
      end;
    end else
    begin
      while not Eof do
      begin
        if sCnt=0 then
          sgData.RowCount:=2
        else
          sgData.RowCount:=sgData.RowCount+1;
        sgData.Cells[0, sCnt+1]:=IntToStr(sCnt+1);
        sgData.Cells[1, sCnt+1]:=FieldByName('WORK_ORDER').AsString;
        sgData.Cells[2, sCnt+1]:=FieldByName('PALLET_NO').AsString;
        sgData.Cells[3, sCnt+1]:=FieldByName('UPDATE_TIME').AsString;
        sgData.row:=sgData.rowcount-1;
        Inc(sCnt);
        Next;
      end;
    end;}

    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then begin
      editMaterial.CharCase := ecUpperCase;
      editPart.CharCase := ecUpperCase;
      edtWo.CharCase := ecUpperCase;
    end;
    close;
  end;
  edtWo.SetFocus;
end;

procedure TfDetail.sbtnMaterialClick(Sender: TObject);
  procedure InsertMaterial(sType, sPartId: string);
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      {if gsType <> 'Goods' then
      begin
        if sType <> '' then begin
          CommandText := 'select sajet.to_label(''' + sType + ''','''') SNID from dual';
          Open;
          sMaterial := FieldByName('SNID').AsString;
        end else
          sMaterial := editMaterial.Text;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'QC_LOTNO', ptInput);
        Params.CreateParam(ftString, 'update_userid', ptInput);
        Params.CreateParam(ftString, 'wo', ptInput);
        CommandText := 'insert into sajet.G_Semifinished_INCOMING '
          + '(QC_LOTNO, update_userid,work_order) '
          + 'values (:QC_LOTNO, :update_userid,:wo) ';
        Params.ParamByName('QC_LOTNO').AsString := editMaterial.Text;
        Params.ParamByName('update_userid').AsString := UpdateUserID;
        Params.ParamByName('wo').AsString := edtWo.text;
        Execute;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'PART_ID', ptInput);
        Params.CreateParam(ftString, 'material_no', ptInput);
        Params.CreateParam(ftString, 'material_qty', ptInput);
        Params.CreateParam(ftString, 'update_userid', ptInput);
        Params.CreateParam(ftString, 'warehouse_id', ptInput);
        Params.CreateParam(ftString, 'locate_id', ptInput);
        CommandText := 'insert into sajet.g_material '
          + '(part_id, material_no, material_qty, update_userid, warehouse_id, locate_id, update_time, status) '
          + 'values (:part_id, :material_no, :material_qty, :update_userid, :warehouse_id, :locate_id, sysdate, ''1'')';
        Params.ParamByName('PART_ID').AsString := sPartId;
        Params.ParamByName('material_no').AsString := sMaterial;
        Params.ParamByName('material_qty').AsString := sedtQty.Text;
        Params.ParamByName('update_userid').AsString := UpdateUserID;
        Params.ParamByName('warehouse_id').AsString := slStockId[cmbStock.ItemIndex];
        if cmbLocate.ItemIndex <> -1 then
          Params.ParamByName('locate_id').AsString := slLocateId[cmbLocate.ItemIndex]
        else
          Params.ParamByName('locate_id').AsString := '';
        Execute;
        Close;
        if sType <> '' then begin
          sPrintData := G_getPrintData(6, 17, G_sockConnection, 'DspQryData', lablType.Caption + '*&*' + sMaterial, 1, 'DEFAULT');
          if assigned(G_onTransDataToApplication) then
            G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
          else
            showmessage('Not Defined Call Back Function for Code Soft');
        end;   
      end else begin
        Params.CreateParam(ftString, 'pallet_no', ptInput);
        Params.CreateParam(ftString, 'update_userid', ptInput);
        Params.CreateParam(ftString, 'wo', ptInput);
        CommandText := 'insert into sajet.g_goods_incoming '
          + '(pallet_no, update_userid,work_order) '
          + 'values (:pallet_no, :update_userid,:wo) ';
        Params.ParamByName('pallet_no').AsString := editMaterial.Text;
        Params.ParamByName('update_userid').AsString := UpdateUserID;
        Params.ParamByName('wo').AsString := edtWo.text;
        Execute;
        Close;
        sMaterial := editMaterial.Text;
        Params.Clear;
        Params.CreateParam(ftString, 'update_userid', ptInput);
        Params.CreateParam(ftString, 'warehouse_id', ptInput);
        Params.CreateParam(ftString, 'locate_id', ptInput);
        Params.CreateParam(ftString, 'pallet_no', ptInput);
        CommandText := 'insert into sajet.g_material '
          + '(part_id, material_no, material_qty, update_userid, warehouse_id, locate_id, update_time, status) '
          + 'select model_id, carton_no, count(*), :update_userid, :warehouse_id, :locate_id, sysdate, 1 '
          + 'from sajet.g_sn_status '
          + 'where pallet_no = :pallet_no '
          + 'group by model_id, carton_no ';
        Params.ParamByName('update_userid').AsString := UpdateUserID;
        Params.ParamByName('warehouse_id').AsString := slStockId[cmbStock.ItemIndex];
        if cmbLocate.ItemIndex <> -1 then
          Params.ParamByName('locate_id').AsString := slLocateId[cmbLocate.ItemIndex]
        else
          Params.ParamByName('locate_id').AsString := '';
        Params.ParamByName('pallet_no').AsString := sMaterial;
        Execute;
        Close;
      end; }
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
          if chkPush.Checked then
            Params.ParamByName('TPUSH').AsString := 'Y'
          else
            Params.ParamByName('TPUSH').AsString := 'N';
          Params.ParamByName('TPALLET').AsString := 'N/A';
          Params.ParamByName('TEMPID').AsString := UpdateUserID;
          Execute;
        finally
          close;
        end;
      end;
      if sCnt=0 then
        sgData.RowCount:=2
      else
        sgData.RowCount:=sgData.RowCount+1;
      sgData.Cells[0, sCnt+1]:=IntToStr(sCnt+1);
      sgData.Cells[1, sCnt+1]:=edtWo.Text;
      //sgData.Cells[2, sCnt+1]:=sedtQty.Text;
      sgData.Cells[3, sCnt+1]:=FormatDateTime('YYYY-M-DD HH:NN:SS',NOW);
      sgData.row:=sgData.rowcount-1;
      Inc(sCnt);
      //lablMsg.Caption := gsType + ': ' + sMaterial + ' incoming OK.';
      //MessageDlg(lablMsg.Caption, mtInformation, [mbOK], 0);
      editMaterial.Text := '';
      editPart.Text := '';
      sedtQty.Text := '0';
      cmbStock.ItemIndex := -1;
      cmbLocate.Items.Clear;
      edtWo.Text := '';
      labwoqty.Caption:='';
      edtWo.SetFocus;
    end;
  end;
var sPartID: String;  
begin
  if (cmbStock.Text = '') or ((cmbLocate.Items.Count > 0) and (cmbLocate.ItemIndex = -1)) then begin
    MessageDlg('Please select Locator!', mtWarning, [mbOK], 0);
    Exit;
  end;
  if sedtQty.Value <= 0 then Exit;
  if CheckWo then
      InsertMaterial('', sPartId);
  {if gsType = 'Goods' then begin
    if CheckPallet(sPartID, False) then
      if CheckWo then
        InsertMaterial('', sPartId);
  end else
    if CheckLot(sPartID, False, bContinue) then begin
      if CheckWo then
        InsertMaterial('QTY ID', sPartId);
    end else if (bContinue) and (CheckPallet(sPartID, False)) then begin
      if CheckWo then
        InsertMaterial('', sPartId);
    end;}
end;

function TfDetail.CheckWo: Boolean;
begin
  Result := True;
  with QryTemp do begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    CommandText := 'select target_qty, erp_qty, part_no, wo_status from sajet.g_wo_base a, sajet.sys_part b '
      + 'where work_order = :work_order and a.model_id = b.part_id and rownum = 1';
    Params.ParamByName('work_order').AsString := edtWo.Text;
    Open;
    if IsEmpty then begin
      MessageDlg('Work Order: ' + edtWo.Text + ' not found!', mtError, [mbOK], 0);
      Result := False;
    end else if FieldByName('target_qty').AsInteger < FieldByName('erp_qty').AsInteger + sedtQty.Value then
    begin
      MessageDlg('Work Order: ' + edtWo.Text + ' Incoming Qty (' + FieldByName('erp_qty').AsString + ' + ' + sedtQty.Text + ') > Target Qty (' + FieldByName('target_qty').AsString + ')!', mtError, [mbOK], 0);
      Result := False;
    end else if FieldByName('part_no').AsString <> editPart.Text then
    begin
      MessageDlg('Work Order: ' + edtWo.Text + ' Part (' + FieldByName('part_no').AsString + ') not match.' + #13#13 + 'Goods Part: ' + editPart.Text, mtError, [mbOK], 0);
      Result := False;
    end;

    //add by key 2008/01/18 check wo status
    if not isempty then
    begin
      case FieldByName('wo_status').AsInteger of
        0: begin
             MessageDlg('Work Order: ' + edtWo.Text + ' is Initial Status ', mtError, [mbOK], 0);
             Result := False;
           end;
        1: begin
             MessageDlg('Work Order: ' + edtWo.Text + ' is Prepare Status ', mtError, [mbOK], 0);
             Result := False;
           end;
        2: begin
             //MessageDlg('Work Order: ' + edtWo.Text + ' is Release Status ', mtError, [mbOK], 0);
             //Result := False;
           end;
        3: begin
             //MessageDlg('Work Order: ' + edtWo.Text + ' is WIP Status ', mtError, [mbOK], 0);
            // Result := False;
           end;
        4:  begin
             MessageDlg('Work Order: ' + edtWo.Text + ' is Hold Status ', mtError, [mbOK], 0);
             Result := False;
           end;
        5:  begin
             MessageDlg('Work Order: ' + edtWo.Text + ' is Cancel Status ', mtError, [mbOK], 0);
             Result := False;
           end;
        6:  begin
             //MessageDlg('Work Order: ' + edtWo.Text + ' is Complete Status ', mtError, [mbOK], 0);
             //Result := False;
           end;
        9: begin
             MessageDlg('Work Order: ' + edtWo.Text + ' is Complete No-Charge Status ', mtError, [mbOK], 0);
             Result := False;
           end;
        else
           begin
               MessageDlg('Work Order: ' + edtWo.Text + ' Status is ERROR ', mtError, [mbOK], 0);
              Result := False;
           end;
       end;

    end;
   // end add

    if not Result then begin
      edtWo.SetFocus;
      edtWo.SelectAll;
    end;
    Close;
  end;
end;

procedure TfDetail.editMaterialKeyPress(Sender: TObject; var Key: Char);
var sPart, sLocate: string; bContinue: Boolean;
    sKey: Char;
begin
  sbtnMaterial.Enabled := False;
  lablMsg.Caption := '';
  labwoqty.Caption := '';
  sKey:=#13;
  if Ord(Key) = vk_Return then
  begin
    if gsType = 'Goods' then
      sbtnMaterial.Enabled := CheckPallet(sPart, True)
    else
      sbtnMaterial.Enabled := CheckLot(sPart, True, bContinue);
      if (bContinue) and (not sbtnMaterial.Enabled) then
        sbtnMaterial.Enabled := CheckPallet(sPart, True);
    if sbtnMaterial.Enabled then begin
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
      edtWoKeyPress(self,sKey);
    end;
    editMaterial.SelectAll;
    editMaterial.SetFocus;
  end;
end;

function TfDetail.CheckLot(var PartID: string; bChange: Boolean; var bContinue: Boolean): Boolean;
begin
  Result := False;
  bContinue := False;
  with QryTemp do begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'QC_LOTNO', ptInput);
    CommandText := 'select QC_LOTNO from SAJET.G_Semifinished_INCOMING '
      + 'where QC_LOTNO = :QC_LOTNO and rownum = 1 ';
    Params.ParamByName('QC_LOTNO').AsString := editMaterial.Text;
    Open;
    if not IsEmpty then begin
      MessageDlg('Lot No: ' + editMaterial.Text + ' had In Stocked!', mtError, [mbOK], 0);
      Close;
      Exit;
    end;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'QC_LOTNO', ptInput);
    CommandText := 'select qc_result, part_no, part_id, lot_size, QC_TYPE, work_order '
      + 'from SAJET.G_QC_LOT a, sajet.sys_part b '
      + 'where QC_LOTNO = :QC_LOTNO and a.model_id = b.part_id and rownum = 1 ';
    Params.ParamByName('QC_LOTNO').AsString := editMaterial.Text;
    Open;
    if IsEmpty then begin
//      MessageDlg('Lot No: ' + editMaterial.Text + ' not found!', mtError, [mbOK], 0);
      bContinue := True;
      Close;
      Exit;
    end else if FieldByName('qc_result').AsString = '1' then begin
      MessageDlg('Lot No: ' + editMaterial.Text + ' Reject!', mtError, [mbOK], 0);
      Close;
      Exit;
    end else if FieldByName('qc_result').AsString = 'N/A' then begin
        MessageDlg('Lot No: ' + editMaterial.Text + ' never QC!', mtError, [mbOK], 0);
      Close;
      Exit;
    end;
{    end else if FieldByName('QC_TYPE').AsString = '0' then
    begin
      MessageDlg('Lot No: ' + editMaterial.Text + ' Type NG (Goods)!', mtError, [mbOK], 0);
      Close;
      Exit;}
    PartID := FieldByName('part_id').AsString;
    editPart.Text := FieldByName('part_no').AsString;
    sedtQty.Value := FieldByName('lot_size').AsInteger;
    if bChange then
      edtWo.Text := FieldByName('work_order').AsString;
    Close;
  end;
  Result := True;
end;

function TfDetail.CheckPallet(var PartID: string; bChange: Boolean): Boolean;
var sPartNo: String;
begin
  Result := False;
  with QryTemp do begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'pallet_no', ptInput);
    CommandText := 'select pallet_no from sajet.g_goods_incoming '
      + 'where pallet_no = :pallet_no and rownum = 1 ';
    Params.ParamByName('pallet_no').AsString := editMaterial.Text;
    Open;
    if not IsEmpty then begin
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
    if IsEmpty then begin
      MessageDlg('Pallet: ' + editMaterial.Text + ' not found!', mtError, [mbOK], 0);
      Close;
      Exit;
    end else if FieldByName('close_flag').AsString = 'N' then
    begin
      MessageDlg('Pallet: ' + editMaterial.Text + ' Unfinished!', mtError, [mbOK], 0);
      Close;
      Exit;
    end;
    sPartNo := FieldByName('part_no').AsString;
    PartID := FieldByName('part_id').AsString;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'pallet_no', ptInput);
    CommandText := 'select serial_number from sajet.g_sn_status '
      + 'where pallet_no = :pallet_no and out_pdline_time is null and rownum = 1';
    Params.ParamByName('pallet_no').AsString := editMaterial.Text;
    Open;
    if not IsEmpty then begin
      MessageDlg('Serial Number: ' + FieldByName('serial_number').AsString + ' not complete!', mtError, [mbOK], 0);
      Close;
      Exit;
    end else begin
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
      while not Eof do begin
        sedtQty.Value := sedtQty.Value + FieldByName('qty').AsInteger;
        Next;
      end;
      if bChange then
        edtWo.Text := FieldByName('work_order').AsString;
      Close;
    end;
  end;
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
  labwoqty.Caption:='';
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
      chkPush.Checked:=not(chkPush.Checked);
      MessageDlg('Push Title Change OK', mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfDetail.edtWoKeyPress(Sender: TObject; var Key: Char);
var sPart,sLocate: string;
begin
  labwoqty.Caption := '';
  if Ord(Key) = vk_Return then
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'wo', ptInput);
      CommandText := 'select a.target_qty,a.ERP_QTY,a.factory_id,b.part_no,b.part_id from sajet.g_wo_base a,sajet.sys_part b  '
          + 'where work_order=:wo and a.model_id=b.part_id and rownum=1 ';
      Params.ParamByName('wo').AsString := edtWo.text;
      open;
      if RecordCount=1 then
      begin
        labwoqty.Caption:=FieldByName('ERP_QTY').AsString;
        editPart.Text:=FieldByName('part_no').AsString;
        sPart:=FieldByName('part_id').AsString;

        G_FCID:='';
        G_FCCODE:='';
        G_FCTYPE:='';
        editorg.Clear ;
        G_FCID:=fieldbyname('factory_id').AsString;
        if Getfctype(G_FCID)<>'OK' then
        begin
          editorg.Clear;
          exit;
        end
        else
          editorg.Text :=G_FCCODE;


        Close;
        Params.Clear;
        {// 預設Loate 取sys_part table 中的值
        Params.CreateParam(ftString, 'part_id', ptInput);
        CommandText := 'select locate_name, warehouse_name, b.warehouse_id, locate_id from sajet.sys_part a, sajet.sys_locate b, sajet.sys_warehouse c '
            + 'where part_id = :part_id and a.' + gsLocateField + ' = to_char(b.locate_id) and b.warehouse_id = c.warehouse_id and rownum = 1';
        Params.ParamByName('part_id').AsString := sPart;
        }
        //預設Loate 取sys_part_factory table 中的值  change by key 2008/07/25
        Params.CreateParam(ftString, 'part_id', ptInput);
        Params.CreateParam(ftString, 'factory_id', ptInput);
        CommandText := 'select locate_name, warehouse_name, b.warehouse_id, a.locate_id from sajet.sys_part_factory a, sajet.sys_locate b, sajet.sys_warehouse c '
            + 'where part_id = :part_id and a.locate_id = to_char(b.locate_id) and b.warehouse_id = c.warehouse_id and a.factory_id = :factory_id and rownum = 1';
        Params.ParamByName('part_id').AsString := sPart;
        Params.ParamByName('factory_id').AsString :=G_FCID ;
        Open;
        cmbStock.ItemIndex := cmbStock.Items.IndexOf(QryTemp.FieldByName('Warehouse_name').AsString);
        sLocate := QryTemp.FieldByName('locate_name').AsString;
        if cmbStock.ItemIndex <> -1 then
        begin
          cmbStockChange(Self);
          cmbLocate.ItemIndex := cmbLocate.Items.IndexOf(sLocate);
        end;
        if uppercase(gsType)='GOODS' then
          if cmbstock.ItemIndex=-1 then
          begin
             qrytemp.Close;
             qrytemp.Params.Clear;
             qrytemp.CommandText:=' select * from sajet.sys_base where param_name=''ProductWarehouse'' ';
             qrytemp.Open;
             cmbstock.ItemIndex:=cmbstock.Items.IndexOf(qrytemp.fieldbyname('param_value').AsString);
             if cmbstock.ItemIndex<>-1 then
             begin
                cmbStockChange(Self);
             end;
          end;
        sedtQty.SelectAll;
        sedtQty.SetFocus;
      end else
      begin
        MessageDlg('Work Order Error!', mtError, [mbOK], 0);
        edtWo.SelectAll;
        edtWo.SetFocus;
        exit;
      end;
    end;
    sbtnMaterial.Enabled:=True;
  end;
end;

end.

