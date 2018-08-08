unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryMaterial: TClientDataSet;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    edtRT: TEdit;
    lablType: TLabel;
    Image1: TImage;
    sbtnReel: TSpeedButton;
    lablMsg: TLabel;
    sgData: TStringGrid;
    EditStatus: TEdit;
    Label2: TLabel;
    EditDC: TEdit;
    lablLocate: TLabel;
    cmbStock: TComboBox;
    cmbLocate: TComboBox;
    LabQTY: TLabel;
    lablLabel: TLabel;
    lablDesc: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Image2: TImage;
    SpeedButton1: TSpeedButton;
    lbl1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure edtRTKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnReelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbStockChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
    Function GetMinFIFOCode(FIFOList:tstrings):string;
  public
    { Public declarations }
    UpdateUserID, gsType, gsLabelField: string;
    sCnt: Integer;
    slLocateId, slStockId: TStringList;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin;

Function TfDetail.GetMinFIFOCode(FIFOList:tstrings):string;
var i:integer;
    sMin :string;
begin
   sMin:= FIFOList[1];
   for i:=1 to FIFOList.Count -1  do
   begin
     if FIFOList[i]< sMin then
        sMin:=FIFOList[i];
   end;
   Result:=sMin;
end;

procedure TfDetail.FormShow(Sender: TObject);
var PIni: TIniFile;
begin
  slLocateId := TStringList.Create;
  slStockId := TStringList.Create;
  PIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Material.Ini');
  PIni.Free;
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  sgData.Cells[0, 0] := 'No';
  sgData.Cells[1, 0] := 'Material No';
  sgData.Cells[2, 0] := 'Qty';
  sgData.Cells[3, 0] := 'Part No';
  sgData.Cells[4, 0] := 'Date Code';
  sgData.Cells[5, 0] := 'Warehouse';
  sgData.Cells[6, 0] := 'Locator';
  sgData.Cells[7, 0] := 'FIFO Code';
  sgData.Cells[8, 0] := 'Factory id';
  sgData.Cells[9, 0] := 'Factory Type';
  sCnt := 0;
  edtRT.SetFocus;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'GOODSMERGEDLL.DLL';
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
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then
    begin
      edtRT.CharCase := ecUpperCase;
      EditDC.CharCase := ecUpperCase;
    end;
    Close;
    Params.Clear;
    CommandText := 'select warehouse_id, warehouse_name '
      + 'from sajet.sys_warehouse where enabled = ''Y'' order by warehouse_name';
    Open;
    while not Eof do
    begin
      cmbStock.Items.Add(FieldByName('warehouse_name').AsString);
      slStockId.Add(FieldByName('warehouse_id').AsString);
      Next;
    end;
    Close;
  end;
end;

procedure TfDetail.edtRTKeyPress(Sender: TObject; var Key: Char);
var i: Integer; sLocate: string;
begin
  lablMsg.Caption := '';
  if Ord(Key) = vk_Return then
  begin
    with QryMaterial do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'material_no', ptInput);
      CommandText := 'select distinct A.material_no, NVL(A.material_qty,0) material_qty,a.reel_qty, a.datecode, C.part_no, '
        + 'nvl(b.label_type, c.' + gsLabelField + ') label_type, a.status,d.warehouse_name, e.locate_name,a.FIFOCode,a.type,a.factory_id,a.factory_type '
        + 'from sajet.g_material a, sajet.g_erp_rt_item b, sajet.sys_part c, sajet.sys_warehouse d, sajet.sys_locate e '
        + 'where a.part_id = c.part_id '
        + 'and material_no = :material_no '
        + 'and a.rt_id = b.rt_id(+) '
        + 'and a.part_id = b.part_id(+) '
        + 'and a.locate_id = e.locate_id(+) and e.warehouse_id = d.warehouse_id(+) ';
      Params.ParamByName('material_no').AsString := edtRT.Text;
      Open;
      if IsEmpty then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'material_no', ptInput);
        CommandText := 'select distinct a.reel_no material_no, a.reel_qty material_qty, a.datecode, c.part_no, '
          + '''Reel ID'' label_type, a.status ,d.warehouse_name, e.locate_name,a.FIFOCode,a.type,a.factory_id,a.factory_type '
          + 'from sajet.g_material a, sajet.sys_part c,sajet.sys_warehouse d, sajet.sys_locate e '
          + 'where a.part_id = c.part_id '
          + 'and reel_no = :material_no '
          + 'and a.locate_id = e.locate_id(+) and e.warehouse_id = d.warehouse_id(+) ';
        Params.ParamByName('material_no').AsString := edtRT.Text;
        Open;
        if IsEmpty then
        begin
          MessageDlg('ID No: ' + edtRT.Text + ' not found.', mtError, [mbOK], 0);
          edtRT.SelectAll;
          edtRT.SetFocus;
          Exit;
        end
        else if fieldbyname('type').AsString='O' then
        begin
          MessageDlg('Transfer UnConfirm.', mtError, [mbOK], 0);
          edtRT.SelectAll;
          edtRT.SetFocus;
          Exit;
        end
        else if fieldbyname('type').AsString='P' then
        begin
          MessageDlg('Goods Not Incomming', mtError, [mbOK], 0);
          edtRT.SelectAll;
          edtRT.SetFocus;
          Exit;
        end
        else if fieldbyname('factory_id').AsString='' then
        begin
          MessageDlg('Material ORG IS NULL', mtError, [mbOK], 0);
          edtRT.SelectAll;
          edtRT.SetFocus;
          Exit;
        end;
        gsType := 'Reel ID';
      end
      else if fieldbyname('type').AsString='O' then
      begin
          MessageDlg('Transfer UnConfirm.', mtError, [mbOK], 0);
          edtRT.SelectAll;
          edtRT.SetFocus;
          Exit;
      end
      else if fieldbyname('type').AsString='P' then
      begin
          MessageDlg('Goods Not Incomming', mtError, [mbOK], 0);
          edtRT.SelectAll;
          edtRT.SetFocus;
          Exit;
      end
      else if fieldbyname('factory_id').AsString='' then
      begin
          MessageDlg('Material ORG IS NULL', mtError, [mbOK], 0);
          edtRT.SelectAll;
          edtRT.SetFocus;
          Exit;
      end
      else
      begin
        if FieldByName('label_type').AsString = '' then
          gsType := 'QTY ID'
        else
          gsType := FieldByName('label_type').AsString;
      end;

      if (gsType = 'BOX ID') and (FieldByName('reel_qty').AsString <> '') then
      begin
        MessageDlg('BOX ID has Relase Reel ID, Cann''''t Merge!', mtError, [mbOK], 0);
        edtRT.SelectAll;
        edtRT.SetFocus;
        Exit;
      end;
      for i := 1 to sgData.RowCount - 1 do
      begin
        if sgData.Cells[1, i] = FieldByName('material_no').AsString then
        begin
          MessageDlg(edtRT.Text + ' Dup!', mtError, [mbOK], 0);
          edtRT.SelectAll;
          edtRT.SetFocus;
          exit;
        end;
      end;

      if lablType.Caption = '' then
      begin
        lablType.Caption := gsType;
        sgData.Cells[1, 0] := gsType;
        EditStatus.Text := FieldByName('status').AsString;
        EditDC.Text := FieldByName('datecode').AsString;
        cmbStock.ItemIndex := cmbStock.Items.IndexOf(FieldByName('Warehouse_name').AsString);
        if cmbStock.ItemIndex <> -1 then
        begin
          cmbStockChange(Self);
          cmbLocate.ItemIndex := cmbLocate.Items.IndexOf(FieldByName('locate_name').AsString);
        end;
      end
      else
      begin
        if lablType.Caption <> gsType then
        begin
          MessageDlg('label type [' + gsType + '] [' + lablType.Caption + '] different!', mtError, [mbOK], 0);
          edtRT.SelectAll;
          edtRT.SetFocus;
          Exit;
        end;
        if EditStatus.Text <> FieldByName('status').AsString then
        begin
          MessageDlg('Status different!', mtError, [mbOK], 0);
          edtRT.SelectAll;
          edtRT.SetFocus;
          Exit;
        end;
        if sgData.Cells[3, 1] <> FieldByName('Part_no').AsString then
        begin
          MessageDlg('Part No [' + FieldByName('Part_no').AsString + '] [' + sgData.Cells[3, 1] + '] different!', mtError, [mbOK], 0);
          edtRT.SelectAll;
          edtRT.SetFocus;
          Exit;
        end;
      end;
      if (sgData.Cells[1, 1] <> '') and (sgData.Cells[6, 1] <> FieldByName('locate_name').AsString) then
      begin
        sLocate := FieldByName('warehouse_name').AsString + ' ' + FieldByName('locate_name').AsString;
        if sLocate = '' then sLocate := 'Null';
        MessageDlg('Locater (' + sLocate + ') Different, Cann''''t Merge!', mtError, [mbOK], 0);
        edtRT.SelectAll;
        edtRT.SetFocus;
        Exit;
      end;
      if (sgData.Cells[1, 1] <> '') and (sgData.Cells[8, 1] <> FieldByName('factory_id').AsString) then
      begin
        MessageDlg('Material ORG IS  Different, Cann''''t Merge!', mtError, [mbOK], 0);
        edtRT.SelectAll;
        edtRT.SetFocus;
        Exit;
      end;
      if sCnt = 0 then begin
        sgData.RowCount := 2;
        if FieldByName('warehouse_name').AsString = '' then
        begin
          cmbStock.ItemIndex := -1;
          cmbLocate.ItemIndex := -1;
        end else begin
          cmbStock.ItemIndex := cmbStock.Items.IndexOf(FieldByName('warehouse_name').AsString);
          cmbStockChange(Self);
          cmbLocate.ItemIndex := cmbLocate.Items.IndexOf(FieldByName('locate_name').AsString);
        end;
      end else
        sgData.RowCount := sgData.RowCount + 1;
      LabQTY.Caption := IntToStr(StrToIntDef(LabQTY.Caption, 0) + FieldByName('material_qty').AsInteger);
      sgData.Cells[0, sCnt + 1] := IntToStr(sCnt + 1);
      sgData.Cells[1, sCnt + 1] := FieldByName('material_no').AsString;
      sgData.Cells[2, sCnt + 1] := FieldByName('material_qty').AsString;
      sgData.Cells[3, sCnt + 1] := FieldByName('Part_no').AsString;
      sgData.Cells[4, sCnt + 1] := FieldByName('datecode').AsString;
      sgData.Cells[5, sCnt + 1] := FieldByName('warehouse_name').AsString;
      sgData.Cells[6, sCnt + 1] := FieldByName('locate_name').AsString;
      sgData.Cells[7, sCnt + 1] := FieldByName('FIFOCode').AsString;
      sgData.Cells[8, sCnt + 1] := FieldByName('factory_id').AsString;
      sgData.Cells[9, sCnt + 1] := FieldByName('factory_type').AsString;

      sgData.row := sgData.rowcount - 1;
      inc(sCnt);

      edtRT.SelectAll;
      edtRT.SetFocus;
    end;
  end;
end;

procedure TfDetail.sbtnReelClick(Sender: TObject);
var sPrintData, sStr, sStr1: string; i, J: Integer;
    sFIFO:tstrings;
    sMin:string;
begin
  if (sgData.RowCount = 2) then Exit;
  if (EditDC.Text = '') and (sgData.Cells[4, 1] <> '') then
  begin
    MessageDlg('Please Scan DateCode!', mtError, [mbOK], 0);
    EditDC.SelectAll;
    EditDC.SetFocus;
    Exit;
  end;
  if (cmbLocate.Text = '') and (sgData.Cells[6, 1] <> '') then
  begin
    MessageDlg('Please Choose Locator!', mtError, [mbOK], 0);
    Exit;
  end;
  lablMsg.Caption := 'ID No: ';
  if gsType = 'Reel ID' then
  begin
    sStr := 'REEL_NO';
    sStr1 := 'REEL_QTY';
  end
  else
  begin
    sStr := 'MATERIAL_NO';
    sStr1 := 'MATERIAL_QTY';
  end;
  sFIFO:=sgData.Cols[7];
  sMin:=GetMinFIFOCode(sFIFO);
  with QryTemp do
  begin
    for i := 2 to sgData.RowCount - 1 do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'Reel_no', ptInput);
      Params.CreateParam(ftString, 'userid', ptInput);
      commandtext:=' update sajet.g_material '
                  +'   set type=''M'' '
                  +'    ,update_userid=:userid '
                  +'     ,update_time=sysDate '
                  +'  where ' + sStr + ' = :Reel_no ';
      Params.ParamByName('Reel_no').AsString := sgData.Cells[1, i];
      Params.ParamByName('userid').AsString := UpdateUserID;
      execute;

      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'Reel_no', ptInput);
      CommandText := 'insert into sajet.g_ht_material '
        + 'select * from sajet.g_material '
        + 'where ' + sStr + ' = :Reel_no ';
      Params.ParamByName('Reel_no').AsString := sgData.Cells[1, i];
      Execute;

      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'Reel_no', ptInput);
      CommandText := 'delete from sajet.g_material '
        + 'where ' + sStr + ' = :Reel_no ';
      Params.ParamByName('Reel_no').AsString := sgData.Cells[1, i];
      Execute;
    end;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'tqty', ptInput);
    Params.CreateParam(ftString, 'Reel_no', ptInput);
    Params.CreateParam(ftString, 'datecode', ptInput);
//    Params.CreateParam(ftString, 'Stock', ptInput);
//    Params.CreateParam(ftString, 'Locate', ptInput);
    Params.CreateParam(ftString, 'update_userid', ptInput);
    Params.CreateParam(ftString, 'FIFO', ptInput);
    CommandText := 'update sajet.g_material '
      + 'set ' + sStr1 + ' = :tqty,datecode=:datecode, '
      + ' update_userid=:update_userid '
      +'  ,type=''M''  '
      +'  ,update_time=sysdate '
      +'  ,FIFOCode=:FIFO '
//      + ' WAREHOUSE_ID=:Stock ,LOCATE_ID=:Locate,update_userid=:update_userid '
      + 'where ' + sStr + ' = :Reel_no ';
    Params.ParamByName('tqty').AsString := LabQTY.Caption;
    Params.ParamByName('Reel_no').AsString := sgData.Cells[1, 1];
    Params.ParamByName('datecode').AsString := EditDC.Text;
    Params.ParamByName('update_userid').AsString := UpdateUserID;
    Params.ParamByName('FIFO').AsString := sMin;
{    if cmbLocate.Text <> '' then
      Params.ParamByName('Stock').AsString := slStockId[cmbStock.ItemIndex]
    else
      Params.ParamByName('Stock').AsString := '';
    if cmbLocate.Text <> '' then
      Params.ParamByName('Locate').AsString := slLocateId[cmbLocate.ItemIndex]
    else
      Params.ParamByName('Locate').AsString := '';}
    Execute;
    Close;
    params.Clear;
    Params.CreateParam(ftString, 'Reel_no', ptInput);
    commandtext:=' insert into sajet.g_ht_material '
                +'  select * from sajet.g_material where '+ sStr + ' = :Reel_no ';
    Params.ParamByName('Reel_no').AsString := sgData.Cells[1, 1];
    execute;

    lablMsg.Caption := lablMsg.Caption + sgData.Cells[1, 1] + '(' + LabQTY.Caption + ');';
  end;

  sPrintData := G_getPrintData(6, 19, G_sockConnection, 'DspQryData', gsType + '*&*' + sgData.Cells[1, 1], 1, '');
  if assigned(G_onTransDataToApplication) then
    G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
  else
    showmessage('Not Defined Call Back Function for Code Soft');

  for i := 1 to sgData.RowCount - 1 do
    for J := 0 to 6 do
      sgData.Cells[J, i] := '';
  sCnt := 0;
  LabQTY.Caption := '';
  EditDC.Text := '';
  EditStatus.Text := '';
  cmbStock.ItemIndex := -1;
  cmbLocate.ItemIndex := -1;
  sgData.RowCount := 2;
  lablType.Caption := '';
  edtRT.SelectAll;
  edtRT.SetFocus;
end;

procedure TfDetail.FormDestroy(Sender: TObject);
begin
  slLocateId.Free;
  slStockId.Free;
end;

procedure TfDetail.cmbStockChange(Sender: TObject);
begin
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
    Close;
  end;
end;

procedure TfDetail.SpeedButton1Click(Sender: TObject);
begin
  sCnt := 0;
  sgData.RowCount := 2;
  sgData.Rows[1].Clear;
  LabQTY.Caption := '';
  EditDC.Text := '';
  EditStatus.Text := '';
  cmbStock.ItemIndex := -1;
  cmbLocate.ItemIndex := -1;
  sgData.RowCount := 2;
  lablType.Caption := '';
  edtRT.SelectAll;
  edtRT.SetFocus;
end;

end.

