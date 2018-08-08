unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, Mask, RzButton, RzRadChk, ComCtrls;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    Image3: TImage;
    LabTitle2: TLabel;
    sbtnCommit: TSpeedButton;
    LabTitle1: TLabel;
    QryMaterial: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    QryDetail: TClientDataSet;
    DataSource2: TDataSource;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    Label2: TLabel;
    lablType: TLabel;
    Bevel2: TBevel;
    sedtQty: TSpinEdit;
    Label6: TLabel;
    Label12: TLabel;
    editPart: TEdit;
    lablLocate: TLabel;
    cmbLocate: TComboBox;
    Image1: TImage;
    sbtnClear: TSpeedButton;
    lablMsg: TLabel;
    Label4: TLabel;
    edtDateCode: TEdit;
    edtRT: TMaskEdit;
    combAlias: TComboBox;
    Label5: TLabel;
    combVersion: TComboBox;
    sgData: TStringGrid;
    Image2: TImage;
    sbtnok: TSpeedButton;
    PopupMenu1: TPopupMenu;
    Delete1: TMenuItem;
    Memo1: TMemo;
    cmbStock: TComboBox;
    lablLabel: TLabel;
    lablDesc: TLabel;
    Label3: TLabel;
    chkPush: TRzCheckBox;
    Label8: TLabel;
    edtMPN: TEdit;
    DateTimePicker1: TDateTimePicker;
    edtFifo: TEdit;
    Label9: TLabel;
    cmbFactory: TComboBox;
    Label11: TLabel;
    dtp1: TDateTimePicker;
    procedure FormShow(Sender: TObject);
    procedure edtRTKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnCommitClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure editPartKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnClearClick(Sender: TObject);
    procedure edtDateCodeKeyPress(Sender: TObject; var Key: Char);
    procedure combAliasChange(Sender: TObject);
    procedure combVersionChange(Sender: TObject);
    procedure sbtnokClick(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure sgDataSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure cmbStockChange(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtMPNKeyPress(Sender: TObject; var Key: Char);
    procedure DateTimePicker1Change(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
  private
    { Private declarations }
    Function GetFIFOCode(dDate:TDateTime):string;
  public
    { Public declarations }
    UpdateUserID, gsLabelField, gsLocateField, gsOrgID,G_FCCODE, G_FCTYPE: string;
    FcID, UserFcID: string;
    sCnt,FieldsRow: Integer;
    slLocateId, slStockId, slAlias: TStringList;
    function CheckPart(bChange: Boolean): Boolean;
    Function GetFCTYPE(sFCID:string):string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uCommData, uLogin;

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
  sgData.Cells[1,0] :='Part No';
  sgData.Cells[2,0] :='Version';
  sgData.Cells[3,0] :='Date Code';
  sgData.Cells[4,0] :='Qty';
  sgData.Cells[5,0] :='Warehouse';
  sgData.Cells[6,0] :='Locator';
  sgData.Cells[12,0] :='MFGER P/N';
  sgData.ColWidths[7]:=-1;
  sgData.ColWidths[8]:=-1;
  sgData.ColWidths[9]:=-1;
  sgData.ColWidths[10]:=-1;
  sgData.ColWidths[11]:=-1;

  sCnt:=0;
  edtRT.SetFocus;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'MISCRECEIVEDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Label Type'' ';
    Open;
    gsLabelField := FieldByName('param_name').AsString;
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where Param_Name = ''Material Caps Lock'' ';
    Open;
    if not QryTemp.IsEmpty then
    begin
      edtRT.CharCase := ecUpperCase;
      editPart.CharCase := ecUpperCase;
      edtDateCode.CharCase := ecUpperCase;
      edtMPN.CharCase := ecUpperCase;
    end;
    {
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''ORG ID'' ';
    Open;
    gsOrgID := FieldByName('param_value').AsString;
    }
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Locate'' ';
    Open;
    gsLocateField := FieldByName('param_name').AsString;
    Close;
    Close;
    Params.Clear;
    CommandText := 'select alias_name, alias_code from sajet.sys_alias '
      + 'order by alias_name ';
    Open;
    slAlias := TStringList.Create;
    while not Eof do
    begin
      combAlias.Items.Add(FieldByName('alias_name').AsString);
      slAlias.Add(FieldByName('alias_code').AsString);
      Next;
    end;
    Close;
    Params.Clear;
    CommandText := 'select warehouse_id, warehouse_name '
      + 'from sajet.sys_warehouse where enabled = ''Y'' order by warehouse_name';
    Open;
    //cmbStock.Items.Add('    ');
    //slStockId.Add('    ');
    while not Eof do
    begin
      cmbStock.Items.Add(FieldByName('warehouse_name').AsString);
      slStockId.Add(FieldByName('warehouse_id').AsString);
      Next;
    end;
    Close;
  end;
  DateTimePicker1.DateTime:=now();
  dtp1.DateTime := now();
  edtFifo.Text:=GetFIFOCode(now());


  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EMP_ID', ptInput);
    CommandText := 'Select NVL(FACTORY_ID,0) FACTORY_ID ' +
      'From SAJET.SYS_EMP ' +
      'Where EMP_ID = :EMP_ID ';
    Params.ParamByName('EMP_ID').AsString := UpdateUserID;
    Open;
    if RecordCount = 0 then
    begin
      Close;
      MessageDlg('Account Error !!', mtError, [mbOK], 0);
      Exit;
    end;
    UserFcID := Fieldbyname('FACTORY_ID').AsString;
    FcID := UserFcID;
    Close;
  end;

  cmbFactory.Items.Clear;
  with QryTemp do
  begin
    Close;
    CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
      'From SAJET.SYS_FACTORY ' +
      'Where ENABLED = ''Y'' ';
    Open;
    while not Eof do
    begin
      cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString);
      if Fieldbyname('FACTORY_ID').AsString = UserFcID then
      begin
        cmbFactory.ItemIndex := cmbFactory.Items.Count - 1;
      end;
      Next;
    end;
    Close;
  end;
  { change by key 2008/05/05
  　一個user 可以作業多個org 的工令。
  禁用如下語句
   }
  cmbFactory.Enabled := (UserFcID = '0');

  if UserFcID = '0' then
    cmbFactory.ItemIndex := 0;

  cmbFactoryChange(Self);

end;

procedure TfDetail.edtRTKeyPress(Sender: TObject; var Key: Char);
Var i,j : Integer;
begin
  lablMsg.Caption := '';
  memo1.Clear;
  for i:=1 to sgData.RowCount-1  do
    for j:=0 to 11 do
    sgData.Cells[j,i]:='';
  sgData.RowCount:=2;
  sCnt:=0;
  if Ord(Key) = vk_Return then
  begin
    combAlias.SelectAll;
    combAlias.SetFocus;
  end;
end;

procedure TfDetail.sbtnCommitClick(Sender: TObject);
var sMaterial, sPrintData, sLabelType,spart_id,sITEM_id,slStockId,slLocateId: string;
   i,j :Integer;
begin

  if MessageDlg('The ORG IS '''+gsOrgID+''',Are you sure ?',
        mtConfirmation, [mbYes, mbNo], 0) = mrNo then
  begin
     exit;
  end;

  G_FCCODE:='';
  G_FCTYPE:='';
  if Getfctype(FCID)<>'OK' then
  begin
     exit;
  end;

  for i:=1 to sgData.RowCount-1  do
  begin
    sLabelType:=sgData.Cells[7,i];
    spart_id:=sgData.Cells[8,i];
    sITEM_id:=sgData.Cells[9,i];
    slStockId:=sgData.Cells[10,i];
    slLocateId:=sgData.Cells[11,i];
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select sajet.to_label(''' + sLabelType + ''', '''') SNID from dual';
    Open;
    sMaterial := FieldByName('SNID').AsString;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PART_ID', ptInput);
    Params.CreateParam(ftString, 'material_no', ptInput);
    Params.CreateParam(ftInteger, 'material_qty', ptInput);
    Params.CreateParam(ftString, 'update_userid', ptInput);
    Params.CreateParam(ftString, 'locate', ptInput);
    Params.CreateParam(ftString, 'warehouse_id', ptInput);
    Params.CreateParam(ftString, 'DATECODE', ptInput);
    Params.CreateParam(ftString, 'version', ptInput);
    Params.CreateParam(ftString, 'Source', ptInput);
    Params.CreateParam(ftString, 'MFGERPN', ptInput);
    Params.CreateParam(ftString, 'FIFO', ptInput);
    Params.CreateParam(ftString, 'FACTORY_ID', ptInput);
    Params.CreateParam(ftString, 'FACTORY_TYPE', ptInput);
    CommandText := 'insert into sajet.g_material '
      + '(part_id, material_no, material_qty, update_userid, status, locate_id, warehouse_id, DATECODE, version,Remark,MFGER_PART_NO,FIFOCode,FACTORY_ID,FACTORY_TYPE) '
      + 'values (:part_id, :material_no, :material_qty, :update_userid, ''1'', :locate, :warehouse_id, :DATECODE, :version,:Source,:MFGERPN,:FIFO,:FACTORY_ID,:FACTORY_TYPE)';
    Params.ParamByName('PART_ID').AsString := spart_id;
    Params.ParamByName('material_no').AsString := sMaterial;
    Params.ParamByName('material_qty').AsInteger := StrToInt(sgData.Cells[4,i]);
    Params.ParamByName('update_userid').AsString := UpdateUserID;
    Params.ParamByName('locate').AsString := slLocateId;
    Params.ParamByName('warehouse_id').AsString := slStockId;
    Params.ParamByName('DATECODE').AsString := sgData.Cells[3,i];
    Params.ParamByName('version').AsString :=sgData.Cells[2,i];
    Params.ParamByName('Source').AsString :=edtRT.Text;
    Params.ParamByName('MFGERPN').AsString :=sgData.Cells[12,i];
    Params.ParamByName('FIFO').AsString :=edtFIFO.Text;
    Params.ParamByName('FACTORY_ID').AsString :=FCID;
    Params.ParamByName('FACTORY_TYPE').AsString :=G_FCTYPE;
    Execute;
    with sproc do
    begin
      try
        Close;
        DataRequest('SAJET.MES_ERP_MISC');
        FetchParams;
        Params.ParamByName('TSOURCE').AsString := edtRT.Text;
        Params.ParamByName('talias').AsString := slAlias[combAlias.ItemIndex];
        Params.ParamByName('TPARTNO').AsString := sgData.Cells[1,i];
        Params.ParamByName('TITEMID').AsString := sITEM_id;
        Params.ParamByName('TVERSION').AsString := sgData.Cells[2,i];
        Params.ParamByName('TSUBINV').AsString := sgData.Cells[5,i];
        Params.ParamByName('TLOCATOR').AsString := sgData.Cells[6,i];
        Params.ParamByName('TQTY').AsString := sgData.Cells[4,i];
        Params.ParamByName('TTRXNTYPE').AsString := 'A3';
        Params.ParamByName('TORGID').AsString := gsOrgID;
        if chkPush.Checked then
          Params.ParamByName('TPUSH').AsString := 'Y'
        else
          Params.ParamByName('TPUSH').AsString := 'N';
        Params.ParamByName('TEMPID').AsString := UpdateUserID;
        Execute;
      finally
        close;
      end;
    end;
  end;
  sPrintData := G_getPrintData(6, 17, G_sockConnection, 'DspQryData', lablType.Caption + '*&*' + sMaterial, 1, 'DEFAULT');
  if assigned(G_onTransDataToApplication) then
    G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
  else
    showmessage('Not Defined Call Back Function for Code Soft');
  lablMsg.Caption := 'ID No: ' + sMaterial + ' Incoming OK.';
  Memo1.Lines.Add(lablMsg.Caption);
  end;
  editPart.Text := '';
  edtDateCode.Text := '';
  edtMPN.Text:='';
  for i:=1 to sgData.RowCount-1  do
    for j:=0 to 11 do
    sgData.Cells[j,i]:='';
  sgData.RowCount:=2;
  sCnt:=0;
  edtRT.Enabled:=True;
  combAlias.Enabled:=True;
  sbtnCommit.Enabled:=False;
  sedtQty.Value := 0;
  cmbStock.ItemIndex := -1;
  cmbLocate.Items.Clear;
  combVersion.Items.Clear;
  edtRT.text:='';
  edtMPN.Text:='';
  combAlias.ItemIndex := -1;
  QryDetail.Close;
  edtRT.SelectAll;
  edtRT.SetFocus;
end;

procedure TfDetail.FormDestroy(Sender: TObject);
begin
  slLocateId.Free;
  slStockId.Free;
  slAlias.Free;
end;

procedure TfDetail.editPartKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
    CheckPart(True);
  end;
end;

function TfDetail.CheckPart(bChange: Boolean): Boolean;
var sLocate,strlocateid: string;
begin
  Result := False;
  QryDetail.Close;
  QryDetail.Params.Clear;
  QryDetail.Params.CreateParam(ftString, 'part_no', ptInput);
  QryDetail.CommandText := 'select part_no, part_id, option7, ' + gsLabelField + ', ' + gsLocateField
    + ' from sajet.sys_part a '
    + ' where part_no = :part_no and rownum = 1';
  QryDetail.Params.ParamByName('part_no').AsString := editPart.Text;
  QryDetail.Open;
  if QryDetail.IsEmpty then
  begin
    MessageDlg('Part No: ' + editPart.Text + ' not found!', mtError, [mbOK], 0);
    editPart.SelectAll;
    editPart.SetFocus;
    QryDetail.Close;
    Exit;
  end;
  sedtQty.SelectAll;
  sedtQty.SetFocus;
  if bChange then begin
    { 預設loate 取sys_table 中的值
    if QryDetail.FieldByName(gsLocateField).AsString <> '' then
      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'locate_id', ptInput);
        CommandText := 'select locate_name, warehouse_name, b.warehouse_id, locate_id '
          + 'from sajet.sys_locate b, sajet.sys_warehouse c '
          + 'where b.locate_id = :locate_id and b.warehouse_id = c.warehouse_id(+) and rownum = 1 ';
        Params.ParamByName('locate_id').AsString := QryDetail.FieldByName(gsLocateField).AsString;
        Open;
        cmbStock.ItemIndex := cmbStock.Items.IndexOf(QryTemp.FieldByName('Warehouse_name').AsString);
        sLocate := QryTemp.FieldByName('locate_name').AsString;
        if cmbStock.ItemIndex <> -1 then
        begin
          cmbStockChange(Self);
          cmbLocate.ItemIndex := cmbLocate.Items.IndexOf(sLocate);
        end;
      end;
      }
   //預設Loate 取sys_part_factory table 中的值　 change by key 2008/07/23
      with QryTemp do
      begin
        close;
        Params.Clear;
        Params.CreateParam(ftString, 'part_id', ptInput);
        Params.CreateParam(ftString, 'factory_id', ptInput);
        CommandText := 'select locate_id '
          + 'from sajet.sys_part_factory  '
          + 'where part_id = :part_id and factory_id = :factory_id and rownum=1 ';
        Params.ParamByName('part_id').AsString := QryDetail.FieldByName('part_id').AsString;
        Params.ParamByName('factory_id').AsString :=FcID;
        Open;
        if not isempty then
        begin
            strlocateid:= QryTemp.FieldByName('locate_id').AsString;

            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'locate_id', ptInput);
            CommandText := 'select locate_name, warehouse_name, b.warehouse_id, locate_id '
               + 'from sajet.sys_locate b, sajet.sys_warehouse c '
               + 'where b.locate_id = :locate_id and b.warehouse_id = c.warehouse_id(+) and rownum = 1 ';
            Params.ParamByName('locate_id').AsString := strlocateid;
            Open;
            cmbStock.ItemIndex := cmbStock.Items.IndexOf(QryTemp.FieldByName('Warehouse_name').AsString);
            sLocate := QryTemp.FieldByName('locate_name').AsString;
            if cmbStock.ItemIndex <> -1 then
            begin
                cmbStockChange(Self);
                cmbLocate.ItemIndex := cmbLocate.Items.IndexOf(sLocate);
            end;
        end
        else
        begin
          cmbStockChange(Self);
          cmbStock.ItemIndex := -1;
        end;
      end;



    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'part_id', ptInput);
      CommandText := 'select version from sajet.sys_bom_info '
        + 'where part_id = :part_id and version <> ''N/A'' order by version';
      Params.ParamByName('part_id').AsString := QryDetail.FieldByName('part_id').AsString;
      Open;
      combVersion.Items.Clear;
      while not Eof do
      begin
        if combVersion.Items.IndexOf(FieldByName('version').AsString) = -1 then
          combVersion.Items.Add(FieldByName('version').AsString);
        Next;
      end;
      if combVersion.Items.Count = 1 then
        combVersion.ItemIndex := 0
      else if combVersion.Items.Count > 1 then
        combVersion.SetFocus;
      if combVersion.Items.Count <> 0 then
        combVersion.Color := $0080FFFF;
      Close;
    end;
  end;
  Result := True;
end;

procedure TfDetail.sbtnClearClick(Sender: TObject);
begin
  editPart.Text := '';
  sedtQty.Value := 0;
  cmbStock.ItemIndex := -1;
  cmbLocate.Items.Clear;
  lablMsg.Caption := '';
  edtMPN.Text:='';
  memo1.Clear;
  if edtRT.Enabled=true then
  begin
    edtRT.Text := '';
    combAlias.ItemIndex := -1;
    edtRT.SetFocus;
  end else
  begin
    editPart.SetFocus;
  end;

end;

procedure TfDetail.edtDateCodeKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
    edtMPN.SelectAll;
    edtMPN.SetFocus;
  end;
end;

procedure TfDetail.combAliasChange(Sender: TObject);
begin
  editPart.SelectAll;
  editPart.SetFocus;
end;

procedure TfDetail.combVersionChange(Sender: TObject);
begin
  sedtQty.SelectAll;
  sedtQty.SetFocus;
end;

procedure TfDetail.sbtnokClick(Sender: TObject);
Var sType: string;
    fQty: Integer;
begin
  if edtRT.Text = '' then
  begin
    MessageDlg('Please input Source!', mtError, [mbOK], 0);
    edtRT.SelectAll;
    edtRT.SetFocus;
    Exit;
  end;
  if combVersion.Items.Count <> 0 then
  begin
    if combVersion.ItemIndex = -1 then
    begin
      MessageDlg('Please select Version!', mtError, [mbOK], 0);
      combVersion.SelectAll;
      combVersion.SetFocus;
      Exit;
    end;
  end;
  if Length(Trim(edtRT.Text)) <> 10 then
  begin
    MessageDlg('Source must has 10 characters!', mtError, [mbOK], 0);
    edtRT.SelectAll;
    edtRT.SetFocus;
    Exit;
  end;
  if combAlias.Text = '' then
  begin
    MessageDlg('Please input Alias!', mtError, [mbOK], 0);
    combAlias.SelectAll;
    combAlias.SetFocus;
    Exit;
  end;
  try
    fQty := StrToInt(sedtQty.Text);
  except
    MessageDlg('Invalid Qty.', mtError, [mbOK], 0);
    sedtQty.SelectAll;
    sedtQty.SetFocus;
    Exit;
  end;
  if editPart.Text = '' then
  begin
    MessageDlg('Please input Part No!', mtError, [mbOK], 0);
    editPart.SelectAll;
    editPart.SetFocus;
    Exit;
  end;
  if not CheckPart(False) then Exit;
  if sedtQty.Value <= 0 then
  begin
    MessageDlg('QTY Cannot be smaller than 0!', mtError, [mbOK], 0);
    sedtQty.SelectAll;
    sedtQty.SetFocus;
    Exit;
  end;
  //if (cmbStock.Text = '') or ((cmbLocate.Items.Count > 0) and (cmbLocate.ItemIndex = -1)) then
  IF  cmbLocate.ItemIndex = -1 then
  begin
    MessageDlg('Please select Locator!', mtWarning, [mbOK], 0);
    Exit;
  end;
  if QryDetail.FieldByName(gsLabelField).AsString = '' then
    sType := 'QTY ID'
  else
    sType := QryDetail.FieldByName(gsLabelField).AsString;

  if sCnt=0 then
    sgData.RowCount:=2
  else
    sgData.RowCount:=sgData.RowCount+1;

  sgData.Cells[0, sCnt+1]:=IntToStr(sCnt+1);
  sgData.Cells[1, sCnt+1]:=editPart.Text;
  sgData.Cells[2, sCnt+1]:=combVersion.Text;
  sgData.Cells[3, sCnt+1]:=edtDateCode.Text;
  sgData.Cells[4, sCnt+1]:=sedtQty.Text;
  sgData.Cells[5, sCnt+1]:=cmbStock.Text;
  sgData.Cells[6, sCnt+1]:=cmbLocate.Text;
  sgData.Cells[7, sCnt+1]:=sType;
  sgData.Cells[8, sCnt+1]:=QryDetail.FieldByName('part_id').AsString;
  sgData.Cells[9, sCnt+1]:=QryDetail.FieldByName('option7').AsString;
  sgData.Cells[10, sCnt+1]:=slStockId[cmbStock.ItemIndex];

  //if cmbLocate.Text <> '' then
    sgData.Cells[11, sCnt+1]:=slLocateId[cmbLocate.ItemIndex] ;
  //else
    //sgData.Cells[11, sCnt+1]:='';
  //sgData.Cells[12, sCnt+1]:=edtMPN.Text;

  sgData.row:=sgData.rowcount-1;
  Inc(sCnt);
  edtRT.Enabled:=False;
  combAlias.Enabled:=False;
  sbtnCommit.Enabled:=True;
  editPart.Text := '';
  edtDateCode.Text := '';
  edtMPN.Text:='';
  sedtQty.Value := 0;
  cmbStock.ItemIndex := -1;
  cmbLocate.Items.Clear;
  combVersion.Items.Clear;
  editPart.SelectAll;
  editPart.SetFocus;

  if cmbfactory.Enabled = true then
     cmbfactory.Enabled :=false;
end;

procedure TfDetail.Delete1Click(Sender: TObject);
var i:integer;
begin
  if (sgData.RowCount=2) then
  begin
    sgData.Cells[0,1]:= '';
    sgData.Cells[1,1]:= '';
    sgData.Cells[2,1]:= '';
    sgData.Cells[3,1]:= '';
    sgData.Cells[4,1]:= '';
    sgData.Cells[5,1]:= '';
    sgData.Cells[6,1]:= '';
    sgData.Cells[7,1]:= '';
    sgData.Cells[8,1]:= '';
    sgData.Cells[9,1]:= '';
    sgData.Cells[10,1]:= '';
    sgData.Cells[11,1]:= '';
    sgData.Cells[12,1]:= '';
    sCnt:=0;
    sbtnCommit.Enabled:=False;
  end
  else begin
    for i:=FieldsRow to sgData.RowCount-1 do
    begin
      sgData.Cells[0,i]:= inttostr(i);
      sgData.Cells[1,i]:= sgData.Cells[1,i+1];
      sgData.Cells[2,i]:= sgData.Cells[2,i+1];
      sgData.Cells[3,i]:= sgData.Cells[3,i+1];
      sgData.Cells[4,i]:= sgData.Cells[4,i+1];
      sgData.Cells[5,i]:= sgData.Cells[5,i+1];
      sgData.Cells[6,i]:= sgData.Cells[6,i+1];
      sgData.Cells[7,i]:= sgData.Cells[7,i+1];
      sgData.Cells[8,i]:= sgData.Cells[8,i+1];
      sgData.Cells[9,i]:= sgData.Cells[9,i+1];
      sgData.Cells[10,i]:= sgData.Cells[10,i+1];
      sgData.Cells[11,i]:= sgData.Cells[11,i+1];
      sgData.Cells[12,i]:= sgData.Cells[12,i+1];
    end;
    sgData.RowCount:=sgData.RowCount-1;
    sCnt:=sCnt-1;
  end;

end;

procedure TfDetail.sgDataSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  FieldsRow:=ARow;
end;

procedure TfDetail.cmbStockChange(Sender: TObject);
begin
  if Length(Trim(cmbStock.Text))=0 then exit;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'warehouse_id', ptInput);
    CommandText := 'select locate_id, locate_name from sajet.sys_locate '
      + 'where warehouse_id = :warehouse_id and enabled = ''Y'' ';
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

procedure TfDetail.edtMPNKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
    sedtQty.SelectAll;
    sedtQty.SetFocus;
  end;
end;

procedure TfDetail.DateTimePicker1Change(Sender: TObject);
begin
  edtFifo.Text:=GetFIFOCode(DateTimePicker1.DateTime);
end;

procedure TfDetail.cmbFactoryChange(Sender: TObject);
begin
  FcID := '';
  gsOrgID := '';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'FACTORYCODE', ptInput);
    CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
      'From SAJET.SYS_FACTORY ' +
      'Where FACTORY_CODE = :FACTORYCODE ';
    Params.ParamByName('FACTORYCODE').AsString := Copy(cmbFactory.Text, 1, POS(' ', cmbFactory.Text) - 1);
    Open;
    if RecordCount > 0 then
      FcID := Fieldbyname('FACTORY_ID').AsString;
      gsOrgID := Fieldbyname('FACTORY_CODE').AsString;
    Close;
  end;
end;

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

end.

