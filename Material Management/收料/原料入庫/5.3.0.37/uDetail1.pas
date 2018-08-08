unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, Db, DBClient,
  SConnect, Menus, Spin, ComCtrls;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    ImageLocate: TImage;
    LabTitle2: TLabel;
    sbtnLocate: TSpeedButton;
    LabTitle1: TLabel;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    QryDetail: TClientDataSet;
    DataSource2: TDataSource;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    edtRT: TEdit;
    lablLocate: TLabel;
    Label8: TLabel;
    QryReel: TClientDataSet;
    DataSource3: TDataSource;
    StringGrid1: TStringGrid;
    edtMaterial: TEdit;
    sbtnConfirm: TSpeedButton;
    Image1: TImage;
    Image2: TImage;
    SpeedButton1: TSpeedButton;
    cmbStock: TComboBox;
    cmbLocate: TComboBox;
    LvList: TListView;
    Label2: TLabel;
    combStock: TComboBox;
    combLocate: TComboBox;
    Label3: TLabel;
    combPart: TComboBox;
    sbtnRT: TSpeedButton;
    ClientDataSet1: TClientDataSet;
    Image3: TImage;
    SpeedButton2: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure edtRTKeyPress(Sender: TObject; var Key: Char);
    procedure edtMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure sbtnLocateClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sbtnConfirmClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure cmbStockChange(Sender: TObject);
    procedure LvListCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure combPartChange(Sender: TObject);
    procedure combStockChange(Sender: TObject);
    procedure sbtnRTClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsRTID, gsLocateField: string;
    giRow: Integer;
    glMaterial, slLocateId, slStockId, slPartLocate, slPartLocateId, slPartStock: TStringList;
    slNoLocate: TStringList;
    function CheckRT: Boolean;
    procedure CheckMaterial;
    procedure ClearData(bClearAll: Boolean);
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uCommData;

procedure TfDetail.CheckMaterial;
var iRow: Integer;
begin
  if glMaterial.IndexOf(edtMaterial.Text) <> -1 then
  begin
    StringGrid1.Row := glMaterial.IndexOf(edtMaterial.Text) + 1;
    MessageDlg('ID No Duplicate.', mtWarning, [mbOK], 0);
  end
  else
    with QryReel do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'rt_id', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      CommandText := 'select material_no, material_qty, sum(reel_qty) reel_qty, part_no, status, a.part_id '
        + 'from sajet.g_material a, sajet.sys_part b '
        + 'where rt_id = :rt_id and material_no = :material_no and a.part_id = b.part_id '
        + 'group by material_no, material_qty, part_no, status, a.part_id ';
      Params.ParamByName('rt_id').AsString := gsRTID;
      Params.ParamByName('material_no').AsString := edtMaterial.Text;
      Open;
      if IsEmpty then
      begin
        MessageDlg('ID No. not found.', mtError, [mbOK], 0);
      end
      else
      begin
        if FieldByName('part_no').AsString <> combPart.Text then
        begin
          MessageDlg('Part Not Match.' + #13#13 + 'Material Part: ' + FieldByName('part_no').AsString, mtError, [mbOK], 0);
          Exit;
        end;
        if FieldByName('Reel_Qty').AsInteger <> 0 then
          if FieldByName('Material_Qty').AsInteger <> FieldByName('Reel_Qty').AsInteger then
          begin
            MessageDlg('Reel No not enough.', mtError, [mbOK], 0);
            Exit;
          end;
        if FieldByName('Status').AsString = '1' then
        begin
          MessageDlg('ID No InStock.', mtError, [mbOK], 0);
        end
        else
        begin
          if StringGrid1.Cells[1, 1] = '' then
            iRow := 1
          else
          begin
            iRow := StringGrid1.RowCount;
            StringGrid1.RowCount := StringGrid1.RowCount + 1;
          end;
          StringGrid1.Cells[0, iRow] := IntToStr(iRow);
          StringGrid1.Cells[1, iRow] := FieldByName('Material_No').AsString;
          StringGrid1.Cells[2, iRow] := FieldByName('Part_No').AsString;
          StringGrid1.Cells[3, iRow] := FieldByName('Material_Qty').AsString;
          StringGrid1.Cells[4, iRow] := combStock.Text + '-' + combLocate.Text;
          StringGrid1.Cells[5, iRow] := FieldByName('Part_id').AsString;
          if combStock.ItemIndex <> -1 then
            StringGrid1.Cells[6, iRow] := slStockId[combStock.ItemIndex];
          if combLocate.ItemIndex <> -1 then
            StringGrid1.Cells[7, iRow] := slPartLocateId[combLocate.ItemIndex];
          QryTemp.Close;
          glMaterial.Add(StringGrid1.Cells[1, iRow]);
          iRow := LvList.Items.IndexOf(LvList.FindCaption(0, StringGrid1.Cells[1, iRow], True, True, True));
          LvList.Items.Item[iRow].SubItems[0] := '1';
          LvList.Refresh;
          if StringGrid1.Cells[4, iRow] = '-' then
            slNoLocate.Add(IntToStr(iRow));
        end;
      end;
      Close;
    end;
end;

function TfDetail.CheckRT: Boolean;
begin
  Result := True;
  with QryDetail do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RT_NO', ptInput);
    CommandText := 'Select rt_id, status ' +
      'From SAJET.G_ERP_RTNO C ' +
      'Where C.ENABLED = ''Y'' AND C.RT_NO = :RT_NO';
    Params.ParamByName('RT_NO').AsString := edtRT.Text;
    Open;
    if IsEmpty then
    begin
      MessageDlg('RT Not Found.', mtWarning, [mbOK], 0);
      Result := False;
    end
    else if FieldByName('status').AsString <> '1' then
    begin
      if FieldByName('status').AsString = '0' then
        MessageDlg('Some Material never print.', mtWarning, [mbOK], 0)
      else
        MessageDlg('All Material had InStock.', mtWarning, [mbOK], 0);
      Result := False;
    end
    else
    begin
      gsRTID := FieldByName('RT_ID').AsString;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RT_ID', ptInput);
      CommandText := 'Select part_no, ' + gsLocateField
        + ' From SAJET.G_ERP_RT_ITEM A, SAJET.SYS_PART C '
        + ' Where a.part_id = c.part_id and A.ENABLED = ''Y'' '
        + ' AND A.RT_ID = :RT_ID group by part_no, ' + gsLocateField;
      Params.ParamByName('RT_ID').AsString := gsRTID;
      Open;
      while not Eof do
      begin
        combPart.Items.Add(FieldByName('part_no').AsString);
        slPartLocate.Add(FieldByName(gsLocateField).AsString);
        Next;
      end;
      combPart.ItemIndex := 0;
      combPartChange(Self);
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RT_ID', ptInput);
      CommandText := 'Select material_no ' +
        'From SAJET.G_material ' +
        'Where RT_ID = :RT_ID and locate_id is null group by material_no order by material_no ';
      Params.ParamByName('RT_ID').AsString := gsRTID;
      Open;
      while not Eof do
      begin
        with LvList.Items.Add do
        begin
          Caption := Fieldbyname('Material_No').AsString;
          Subitems.Add('0');
        end;
        Next;
      end;
      Close;
    end;
  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
  slLocateId := TStringList.Create;
  slStockId := TStringList.Create;
  slPartLocate := TStringList.Create;
  slPartLocateId := TStringList.Create;
  slPartStock := TStringList.Create;
  slNoLocate := TStringList.Create;
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  LvList.Column[0].Width := LvList.Width - 3;
  glMaterial := TStringList.Create;
  edtRT.SetFocus;
  StringGrid1.Cells[1, 0] := 'ID No';
  StringGrid1.Cells[2, 0] := 'Part No';
  StringGrid1.Cells[3, 0] := 'Qty';
  StringGrid1.Cells[4, 0] := 'Locate';
  with QryTemp do
  begin
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
      + 'from sajet.sys_warehouse order by warehouse_name';
    Open;
    cmbStock.Items.Add('');
    slStockId.Add('');
    while not Eof do
    begin
      cmbStock.Items.Add(FieldByName('warehouse_name').AsString);
      slStockId.Add(FieldByName('warehouse_id').AsString);
      Next;
    end;
    combStock.Items := cmbStock.Items;
    Close;
  end;
end;

procedure TfDetail.edtRTKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
    ClearData(False);
    if CheckRT then
    begin
      edtMaterial.Enabled := True;
      edtMaterial.SetFocus;
    end
    else
    begin
      edtRT.SelectAll;
      edtRT.SetFocus;
    end;
  end;
end;

procedure TfDetail.edtMaterialKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
    CheckMaterial;
    edtMaterial.SelectAll;
    edtMaterial.SetFocus;
  end;
end;

procedure TfDetail.StringGrid1DblClick(Sender: TObject);
begin
  if StringGrid1.Cells[1, giRow] = '' then Exit;
  edtMaterial.Text := StringGrid1.Cells[1, giRow];
  cmbStock.ItemIndex := slStockId.IndexOf(StringGrid1.Cells[6, giRow]);
  cmbStockChange(Self);
  cmbLocate.ItemIndex := slLocateId.IndexOf(StringGrid1.Cells[7, giRow]);
  cmbLocate.Visible := True;
  cmbStock.Visible := True;
  cmbLocate.Visible := True;
  lablLocate.Visible := True;
  sbtnLocate.Visible := True;
  ImageLocate.Visible := True;
  cmbStock.SetFocus;
  edtMaterial.Enabled := False;
end;

procedure TfDetail.StringGrid1SelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  giRow := ARow;
end;

procedure TfDetail.sbtnLocateClick(Sender: TObject);
begin
  if cmbLocate.Text = '' then Exit;
  if slNoLocate.IndexOf(IntToStr(giRow)) = -1 then slNoLocate.Delete(slNoLocate.IndexOf(IntToStr(giRow)));
  StringGrid1.Cells[4, giRow] := cmbStock.Text + '-' + cmbLocate.Text;
  StringGrid1.Cells[6, giRow] := slStockId[cmbStock.ItemIndex];
  StringGrid1.Cells[7, giRow] := slLocateId[cmbLocate.ItemIndex];
  cmbLocate.Visible := False;
  cmbStock.Visible := False;
  lablLocate.Visible := False;
  sbtnLocate.Visible := False;
  ImageLocate.Visible := False;
  edtMaterial.Enabled := True;
  edtMaterial.SelectAll;
  edtMaterial.SetFocus;
end;

procedure TfDetail.FormDestroy(Sender: TObject);
begin
  slLocateId.Free;
  slStockId.Free;
  glMaterial.Free;
  slPartLocate.Free;
  slPartLocateId.Free;
  slPartStock.Free;
  slNoLocate.Free;
end;

procedure TfDetail.sbtnConfirmClick(Sender: TObject);
var i: Integer;
begin
  if LvList.Items.Count <> StringGrid1.RowCount - 1 then
    MessageDlg('Not Complete!', mtWarning, [mbOK], 0)
  else if slNoLocate.Count <> 0 then
  begin
    MessageDlg('Please Define Locate!', mtWarning, [mbOK], 0);
    for i := 1 to StringGrid1.RowCount - 1 do
      if StringGrid1.Cells[4, i] = '-' then begin
        StringGrid1.Row := i;
        break;
      end;
  end
  else
  begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.Create.CreateParam(ftString, 'RT_ID', ptInput);
    QryTemp.Params.Create.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.CommandText := 'update sajet.g_erp_rt_item '
      + 'set output_qty = output_qty + :output_qty '
      + 'where rt_id = :rt_id and part_id = :part_id';
    with QryDetail do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'locate', ptInput);
      Params.CreateParam(ftString, 'warehouse_id', ptInput);
      Params.CreateParam(ftString, 'update_userid', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      CommandText := 'update sajet.g_material '
        + 'set locate_id = :locate, status = ''1'', warehouse_id = :warehouse_id, '
        + 'update_userid = :update_userid, update_time = sysdate '
        + 'where material_no = :material_no ';
      for i := 1 to StringGrid1.RowCount - 1 do
      begin
        Close;
        Params.ParamByName('locate').AsString := StringGrid1.Cells[7, i];
        Params.ParamByName('warehouse_id').AsString := StringGrid1.Cells[6, i];
        Params.ParamByName('update_userid').AsString := UpdateUserId;
        Params.ParamByName('material_no').AsString := StringGrid1.Cells[1, i];
        Execute;
        QryTemp.Close;
        QryTemp.Params.ParamByName('output_qty').AsString := StringGrid1.Cells[3, i];
        QryTemp.Params.ParamByName('rt_id').AsString := gsRTId;
        QryTemp.Params.ParamByName('part_id').AsString := StringGrid1.Cells[5, i];
        QryTemp.Execute;
        QryTemp.Close;
        with sproc do
        begin
          try
            Close;
            DataRequest('SAJET.MES_ERP_RT');
            FetchParams;
            Params.ParamByName('TRTNO').AsString := edtRT.Text;
            Params.ParamByName('TPART').AsString := StringGrid1.Cells[2, i];
            Params.ParamByName('TQTY').AsString := StringGrid1.Cells[3, i];
            Params.ParamByName('TSUBINV').AsString := Copy(StringGrid1.Cells[4, i], 1, Pos('-', StringGrid1.Cells[4, i]) - 1);
            Params.ParamByName('TLOCATOR').AsString := Copy(StringGrid1.Cells[4, i], Pos('-', StringGrid1.Cells[4, i]) + 1, Length(StringGrid1.Cells[4, i]));
            Execute;
          finally
            close;
          end;
        end;
      end;
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.Create.CreateParam(ftString, 'RT_ID', ptInput);
      QryTemp.CommandText := 'update sajet.g_erp_rtno '
        + 'set status = 2 where rt_id = :rt_id ';
      QryTemp.Params.ParamByName('rt_id').AsString := gsRTId;
      QryTemp.Execute;
      QryTemp.Close;
    end;
    ClearData(True);
  end;
end;

procedure TfDetail.ClearData(bClearAll: Boolean);
begin
  StringGrid1.Rows[1].Clear;
  StringGrid1.RowCount := 2;
  cmbLocate.Visible := False;
  cmbStock.Visible := False;
  lablLocate.Visible := False;
  sbtnLocate.Visible := False;
  ImageLocate.Visible := False;
  LvList.Items.Clear;
  giRow := -1;
  glMaterial.Clear;
  cmbLocate.Visible := False;
  cmbStock.Visible := False;
  lablLocate.Visible := False;
  sbtnLocate.Visible := False;
  ImageLocate.Visible := False;
  edtMaterial.Text := '';
  edtMaterial.Enabled := False;
  combPart.Items.Clear;
  combLocate.Items.Clear;
  combStock.ItemIndex := -1;
  slPartLocate.Clear;
  slPartLocateId.Clear;
  slPartStock.Clear;
  slNoLocate.Clear;
  if bClearAll then
  begin
    edtRt.Text := '';
    edtRT.Enabled := True;
    edtRT.SetFocus;
  end;
end;

procedure TfDetail.SpeedButton1Click(Sender: TObject);
begin
  if MessageDlg('Clear Data?', mtWarning, [mbYes, mbNo], 0) = mrYes then
    ClearData(True);
end;

procedure TfDetail.cmbStockChange(Sender: TObject);
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'warehouse_id', ptInput);
    CommandText := 'select locate_id, locate_name from sajet.sys_locate '
      + 'where warehouse_id = :warehouse_id';
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
    Close;
  end;
end;

procedure TfDetail.LvListCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if StrtoIntDef(Item.SubItems.Strings[0], 0) = 0 then
    LvList.Canvas.brush.Color := clred;
end;

procedure TfDetail.combPartChange(Sender: TObject);
begin
  if slPartLocate[combPart.ItemIndex] = '' then begin
    combStock.ItemIndex := -1;
    combLocate.Items.Clear;
  end else begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'locate_id', ptInput);
    QryTemp.CommandText := 'select locate_name, warehouse_name, b.warehouse_id, locate_id from sajet.sys_part a, sajet.sys_locate b, sajet.sys_warehouse c '
      + 'where b.locate_id = :locate_id and b.warehouse_id = c.warehouse_id and rownum = 1';
    QryTemp.Params.ParamByName('locate_id').AsString := slPartLocate[combPart.ItemIndex];
    QryTemp.Open;
    combStock.ItemIndex := combStock.Items.IndexOf(QryTemp.FieldByName('warehouse_name').AsString);
    combStockChange(Self);
    combLocate.ItemIndex := slPartLocateId.IndexOf(slPartLocate[combPart.ItemIndex]);
    QryTemp.Close;
  end;
end;

procedure TfDetail.combStockChange(Sender: TObject);
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'warehouse_id', ptInput);
    CommandText := 'select locate_id, locate_name from sajet.sys_locate a '
      + 'where a.warehouse_id = :warehouse_id ';
    Params.ParamByName('warehouse_id').AsString := slStockId[combStock.ItemIndex];
    Open;
    combLocate.Items.Clear;
    slPartLocateId.Clear;
    while not Eof do
    begin
      combLocate.Items.Add(FieldByName('locate_name').AsString);
      slPartLocateId.Add(FieldByName('locate_id').AsString);
      Next;
    end;
    Close;
  end;
end;

procedure TfDetail.sbtnRTClick(Sender: TObject);
var Key: Char;
begin
  with TfCommData.Create(Self) do
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'rt_no', ptInput);
      CommandText := 'Select C.RT_NO, B.Vendor_Code, C.Receive_Time '
        + 'From SAJET.G_ERP_RTNO C, SAJET.SYS_VENDOR B '
        + 'Where C.RT_NO like :RT_NO and C.ENABLED = ''Y'' '
        + 'and c.status = 1 and c.vendor_id = b.vendor_id '
        + 'Order By RT_NO ';
      Params.ParamByName('RT_NO').AsString := edtRT.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      edtRT.Text := QryTemp.FieldByName('RT_NO').AsString;
      QryTemp.Close;
      Key := #13;
      edtRTKeyPress(Self, Key);
      edtRT.SetFocus;
      edtRT.SelectAll;
    end;
    free;
  end;
end;

procedure TfDetail.SpeedButton2Click(Sender: TObject);
var i: Integer;
begin
  if combStock.ItemIndex = -1 then Exit;
  if combLocate.ItemIndex = -1 then Exit;
  if combPart.ItemIndex = -1 then Exit;
  for i := 1 to StringGrid1.RowCount - 1 do 
    if StringGrid1.Cells[2, i] = combPart.Text then
    begin
      if StringGrid1.Cells[4, i] = '-' then
        slNoLocate.Delete(slNoLocate.IndexOf(IntToStr(i)));
      StringGrid1.Cells[4, i] := combStock.Text + '-' + combLocate.Text;
      if combStock.ItemIndex <> -1 then
        StringGrid1.Cells[6, i] := slStockId[combStock.ItemIndex];
      if combLocate.ItemIndex <> -1 then
        StringGrid1.Cells[7, i] := slPartLocateId[combLocate.ItemIndex];
    end;
end;

end.

