unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, Mask, RzButton, RzRadChk;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    Image3: TImage;
    LabTitle2: TLabel;
    sbtnMaterial: TSpeedButton;
    LabTitle1: TLabel;
    QryTemp: TClientDataSet;
    QryDetail: TClientDataSet;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    QryReel: TClientDataSet;
    Label9: TLabel;
    editMaterial: TEdit;
    Label12: TLabel;
    Image1: TImage;
    sbtnClear: TSpeedButton;
    Label6: TLabel;
    cmbStock: TComboBox;
    cmbLocate: TComboBox;
    Label4: TLabel;
    lablLocate: TLabel;
    lablPart: TLabel;
    lablDateCode: TLabel;
    lablQty: TLabel;
    Label3: TLabel;
    lablMsg: TLabel;
    SProc: TClientDataSet;
    Label5: TLabel;
    lablStock: TLabel;
    combVersion: TComboBox;
    Label8: TLabel;
    edtSource: TMaskEdit;
    chkPush: TRzCheckBox;
    sgData: TStringGrid;
    Image2: TImage;
    sbtnCommit: TSpeedButton;
    PopupMenu1: TPopupMenu;
    Delete1: TMenuItem;
    QryHT: TClientDataSet;
    sbtnDelete: TSpeedButton;
    Image4: TImage;
    QryData: TClientDataSet;
    procedure FormShow(Sender: TObject);
    procedure sbtnMaterialClick(Sender: TObject);
    procedure sbtnClearClick(Sender: TObject);
    procedure cmbStockChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure editMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure edtSourceChange(Sender: TObject);
    procedure editMaterialChange(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sbtnCommitClick(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure sgDataSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure edtSourceKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnDeleteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsType: string;
    slLocateId, slStockId, slData: TStringList;
    giRow: Integer;
    function CheckMaterial: Boolean;
    procedure ClearData;
    procedure ShowMsg(sMsg: string);
    Function GetSource(Source:string):string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uCommData, uLogin;

function TfDetail.GetSource(Source:string):string;
var sCnt:integer;
var i: integer;
begin
  Result:='OK';
  with qrytemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'Source', ptInput);
    commandtext:=' select distinct source,type'
                +' from sajet.g_transfer_detail '
                +' where source=:Source ';
    Params.ParamByName('Source').AsString := Source;
    open;
    if Not ISEmpty then
      if fieldbyname('type').AsString='T' then
        Result:='Source Has Confirm';
    if isempty then
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'material_no', ptInput);
      commandtext:=' select distinct source,type'
                +' from sajet.g_transfer_detail '
                +' where material_no=:material_no and Type=''O'' ';
      Params.ParamByName('MATERIAL_NO').AsString := Source;
      open;
      if not isempty then
      begin
         Source:=fieldbyname('source').AsString ;
         edtsource.Text:=source;
      end;
      if isempty then
      begin
         close;
         params.Clear;
         Params.CreateParam(ftString, 'reel_no', ptInput);
         commandtext:=' select distinct source,type'
                +' from sajet.g_transfer_detail '
                +' where reel_no=:reel_no and Type=''O'' ';
         Params.ParamByName('reel_NO').AsString := Source;
         open;
         if isempty then
             Result:='Not find the Source or Material'
         else
         begin
             Source:=fieldbyname('source').AsString;
             edtsource.Text:=source;
         end;
      end;
    end;

  end;

  if Result<>'OK' then exit;

  with Qrytemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'Source', ptInput);
    commandtext:='select nvl(a.reel_no,a.material_no) material_no,b.part_no,c.warehouse_name from_wh,d.locate_name from_loc,e.warehouse_name to_wh,f.locate_name to_loc,nvl(a.reeL_qty,a.material_qty) qty,a.version,a.DATECODE '
                +'   ,b.option7,a.to_warehouse,a.to_locate,a.fifocode,g.factory_code '
                +' from sajet.g_transfer_detail a,sajet.sys_part b,sajet.sys_warehouse c,sajet.sys_locate d  '
                +'            ,sajet.sys_warehouse e,sajet.sys_locate f, sajet.sys_factory g  '
                +' where a.FROM_WAREHOUSE=c.WAREHOUSE_ID(+) and a.FROM_LOCATE=d.locate_id(+)  '
                +'    and a.to_warehouse=e.warehouse_id(+) and a.to_locate=f.locate_id(+)  '
                +'    and a.part_id=b.Part_id  '
                +'    and a.factory_id=g.factory_id(+) '
                +'    and a.source=:source ';
    Params.ParamByName('Source').AsString := Source;
    open;

    IF qrytemp.IsEmpty then
    begin
        if sbtnCommit.Enabled =true then sbtncommit.Enabled :=false ;
        result:='No Record Of The Source'  ;
        EXIT;
    end;

    // if not qrytemp.IsEmpty then
        // if sbtncommit.Enabled =false then sbtncommit.Enabled :=true;

    while not eof do
    begin
      if sgData.Cells[0, 1] = '' then
      begin
        sgData.RowCount := 2;
        sCnt := 0;
      end
      else
      begin
        sCnt := sgData.RowCount - 1;
        sgData.RowCount := sgData.RowCount + 1;
      end;
      sgData.Cells[0, sCnt + 1] := IntToStr(sCnt + 1);
      sgData.Cells[1, sCnt + 1] := fieldbyname('material_no').AsString;
      sgData.Cells[2, sCnt + 1] := fieldbyname('Part_no').asstring;//lablPart.Caption;
      sgData.Cells[3, sCnt + 1] := fieldbyname('Version').asstring;//combVersion.Text;
      sgData.Cells[4, sCnt + 1] := fieldbyname('DateCode').asstring;//lablDateCode.Caption;
      sgData.Cells[5, sCnt + 1] := Fieldbyname('Qty').asstring;//lablQty.Caption;
      sgData.Cells[6, sCnt + 1] := fieldbyname('from_wh').AsString;//lablStock.Caption;
      sgData.Cells[7, sCnt + 1] := Fieldbyname('from_loc').asstring;//lablLocate.Caption;
      sgData.Cells[8, sCnt + 1] := Fieldbyname('to_wh').asstring;
      sgData.Cells[9, sCnt + 1] := Fieldbyname('to_loc').asstring;
      sgData.Cells[10, sCnt + 1] := FieldByName('part_no').AsString;
      sgData.Cells[11, sCnt + 1] := FieldByName('option7').AsString;
      sgData.Cells[12, sCnt + 1] := Fieldbyname('to_warehouse').asstring;
      sgData.Cells[13, sCnt + 1] := Fieldbyname('to_locate').asstring;
      sgData.Cells[14, sCnt + 1] := Fieldbyname('fifocode').asstring;
      sgData.Cells[15, sCnt + 1] := Fieldbyname('factory_code').asstring;
      next;
    end;
    
  end;

  for i := 1 to sgData.RowCount - 1 do
  begin
       if trim(sgData.Cells[15, i])='' then
       BEGIN
       result:=sgData.Cells[1, i]+' ORG IS NULL'  ;
       EXIT;
       END;
  end;



end;

procedure TfDetail.FormShow(Sender: TObject);
begin
  slLocateId := TStringList.Create;
  slStockId := TStringList.Create;
  slData := TStringList.Create;
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  sgData.Cells[0, 0] := 'No';
  sgData.Cells[1, 0] := 'Material No/Reel No';
  sgData.Cells[2, 0] := 'Part No';
  sgData.Cells[3, 0] := 'Version';
  sgData.Cells[4, 0] := 'Date Code';
  sgData.Cells[5, 0] := 'Qty';
  sgData.Cells[6, 0] := 'From WH';
  sgData.Cells[7, 0] := 'From Locator';
  sgData.Cells[8, 0] := 'To WH';
  sgData.Cells[9, 0] := 'To Locator';
  sgData.Cells[10, 0] := 'Part No';
  sgData.Cells[11, 0] := 'ITEM No';
  sgData.Cells[12, 0] := 'To WH_ID';
  sgData.Cells[13, 0] := 'To Locator_ID';
  sgData.Cells[14, 0] := 'Fifocde';
  sgData.Cells[15, 0] := 'ORG';
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
    Params.ParamByName('dll_name').AsString := uppercase('MaterialTransferConfirmDll.dll');
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
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
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then
    begin
      edtSource.CharCase := ecUpperCase;
      editMaterial.CharCase := ecUpperCase;
    end;
    Close;
  end;
  edtSource.SetFocus;
end;

function TfDetail.CheckMaterial: Boolean;
var sPartId: string;
begin
  Result := False;
  gsType := 'Material';
  if slData.IndexOf(editMaterial.Text) <> -1 then
  begin
    MessageDlg('ID No: ' + editMaterial.Text + ' have Input.', mtWarning, [mbOK], 0);
    sgData.Row := slData.IndexOf(editMaterial.Text) + 1;
    Exit;
  end;
  with QryReel do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'material_no', ptInput);
    CommandText := 'select a.part_id, part_no, material_qty, datecode, '
      + ' locate_name, warehouse_name, option7, a.version,fifocode '
      + ' from sajet.g_material a, sajet.sys_part b, sajet.sys_locate c, sajet.sys_warehouse d '
      + ' where material_no = :material_no and a.part_id = b.part_id '
      + ' and a.locate_id = c.locate_id(+) and a.warehouse_id = d.warehouse_id(+) ';
    Params.ParamByName('material_no').AsString := editMaterial.Text;
    Open;
    if IsEmpty then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'material_no', ptInput);
      CommandText := 'select a.part_id, part_no, reel_qty material_qty, datecode, '
        + ' locate_name, warehouse_name, option7, a.version,fifocode '
        + ' from sajet.g_material a, sajet.sys_part b, sajet.sys_locate c, sajet.sys_warehouse d '
        + ' where reel_no = :material_no and a.part_id = b.part_id '
        + ' and a.locate_id = c.locate_id(+) and a.warehouse_id = d.warehouse_id(+) ';
      Params.ParamByName('material_no').AsString := editMaterial.Text;
      Open;
      if IsEmpty then
      begin
        ShowMsg('ID No: ' + editMaterial.Text + ' not found!');
        Close;
        editMaterial.SelectAll;
        editMaterial.SetFocus;
        Exit;
      end;
      gsType := 'Reel';
    end;
    lablPart.Caption := FieldByName('part_no').AsString;
    sPartID := FieldByName('part_id').AsString;
    lablQty.Caption := FieldByName('material_qty').AsString;
    lablDateCode.Caption := FieldByName('DateCode').AsString;
    lablStock.Caption := FieldByName('warehouse_name').AsString;
    lablLocate.Caption := FieldByName('Locate_name').AsString;
    lablLocate.Left := lablStock.Left + lablStock.Width + 10;
    combVersion.Items.Clear;
    if FieldByName('version').AsString <> '' then begin
      combVersion.Items.Add(FieldByName('version').AsString);
      combVersion.ItemIndex := 0;
    end else
      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'part_id', ptInput);
        CommandText := 'select version from sajet.sys_bom_info '
          + 'where part_id = :part_id order by version';
        Params.ParamByName('part_id').AsString := sPartID;
        Open;
        while not Eof do
        begin
          if combVersion.Items.IndexOf(FieldByName('version').AsString) = -1 then
            combVersion.Items.Add(FieldByName('version').AsString);
          Next;
        end;
        Close;
      end;
    if combVersion.Items.Count = 1 then
      combVersion.ItemIndex := 0;
    Result := True;
  end;
end;

procedure TfDetail.sbtnMaterialClick(Sender: TObject);
var sCnt: Integer;
begin
  if Length(Trim(edtSource.Text)) <> 10 then
  begin
    MessageDlg('Source must has 10 characters!', mtError, [mbOK], 0);
    edtSource.SelectAll;
    edtSource.SetFocus;
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
  if (cmbStock.Text = '') or ((cmbLocate.Items.Count > 0) and (cmbLocate.ItemIndex = -1)) then
  begin
    MessageDlg('Please select Locate!', mtWarning, [mbOK], 0);
    cmbStock.SelectAll;
    cmbStock.SetFocus;
    Exit;
  end;
  if not QryReel.Active then begin
    MessageDlg('Please Press [Enter] on "ID No".', mtWarning, [mbOK], 0);
    editMaterial.SelectAll;
    editMaterial.SetFocus;
    Exit;
  end;
  if QryReel.IsEmpty then Exit;
  if sgData.Cells[0, 1] = '' then
  begin
    sgData.RowCount := 2;
    sCnt := 0;
  end
  else
  begin
    sCnt := sgData.RowCount - 1;
    sgData.RowCount := sgData.RowCount + 1;
  end;
  sgData.Cells[0, sCnt + 1] := IntToStr(sCnt + 1);
  sgData.Cells[1, sCnt + 1] := editMaterial.Text;
  sgData.Cells[2, sCnt + 1] := lablPart.Caption;
  sgData.Cells[3, sCnt + 1] := combVersion.Text;
  sgData.Cells[4, sCnt + 1] := lablDateCode.Caption;
  sgData.Cells[5, sCnt + 1] := lablQty.Caption;
  sgData.Cells[6, sCnt + 1] := lablStock.Caption;
  sgData.Cells[7, sCnt + 1] := lablLocate.Caption;
  sgData.Cells[8, sCnt + 1] := cmbStock.Text;
  sgData.Cells[9, sCnt + 1] := cmbLocate.Text;
  sgData.Cells[10, sCnt + 1] := QryReel.FieldByName('part_no').AsString;
  sgData.Cells[11, sCnt + 1] := QryReel.FieldByName('option7').AsString;
  sgData.Cells[12, sCnt + 1] := slStockId[cmbStock.ItemIndex];
  sgData.Cells[14, sCnt + 1] := QryReel.FieldByName('fifocode').AsString;
  QryReel.Close;
  if cmbLocate.Text <> '' then
    sgData.Cells[13, sCnt + 1] := slLocateId[cmbLocate.ItemIndex]
  else
    sgData.Cells[13, sCnt + 1] := '';
  slData.Add(editMaterial.Text);
  edtSource.Enabled := False;
  sbtnCommit.Enabled := True;
  lablPart.Caption := '';
  lablDateCode.Caption := '';
  lablQty.Caption := '';
  lablStock.Caption := '';
  lablLocate.Caption := '';
  cmbStock.ItemIndex := -1;
  cmbLocate.Items.Clear;
  combVersion.Items.Clear;
  editMaterial.SelectAll;
  editMaterial.SetFocus;
end;

procedure TfDetail.ShowMsg(sMsg: string);
begin
  MessageDlg(sMsg, mtError, [mbOK], 0);
  lablMsg.Caption := sMsg;
  lablMsg.Font.Color := clRed;
end;

procedure TfDetail.sbtnClearClick(Sender: TObject);
begin
  ClearData;
end;

procedure TfDetail.ClearData;
begin
  editMaterial.Text := '';
  edtSource.Text := '';
  edtSource.Enabled := True;
  lablPart.Caption := '';
  lablQty.Caption := '';
  lablStock.Caption := '';
  combVersion.Items.Clear;
  lablLocate.Caption := '';
  cmbLocate.Items.Clear;
  cmbStock.ItemIndex := -1;
  combVersion.ItemIndex := -1;
  cmbLocate.ItemIndex := -1;
  lablDateCode.Caption := '';
  lablMsg.Caption := '';
  sgData.RowCount := 2;
  sgData.Rows[1].Clear;
  slData.Clear;
  edtSource.SetFocus;
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

procedure TfDetail.editMaterialKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
    CheckMaterial;
    editMaterial.SelectAll;
    editMaterial.SetFocus;
  end;
end;

procedure TfDetail.edtSourceChange(Sender: TObject);
begin
  QryReel.Close;
  editMaterial.Text := '';
  lablPart.Caption := '';
  lablQty.Caption := '';
  lablStock.Caption := '';
  lablLocate.Caption := '';
  cmbLocate.Items.Clear;
  combVersion.Items.Clear;
  cmbStock.ItemIndex := -1;
  combVersion.ItemIndex := -1;
  cmbLocate.ItemIndex := -1;
  lablDateCode.Caption := '';
  lablMsg.Caption := '';
  if sbtncommit.Enabled =true then
     sbtncommit.Enabled :=false;
end;

procedure TfDetail.editMaterialChange(Sender: TObject);
begin
  QryReel.Close;
  lablPart.Caption := '';
  lablQty.Caption := '';
  lablStock.Caption := '';
  lablLocate.Caption := '';
  combVersion.Items.Clear;
  cmbLocate.Items.Clear;
  cmbStock.ItemIndex := -1;
  combVersion.ItemIndex := -1;
  cmbLocate.ItemIndex := -1;
  lablDateCode.Caption := '';
  lablMsg.Caption := '';
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
    end;
  end;
end;

procedure TfDetail.sbtnCommitClick(Sender: TObject);
var i: Integer;
begin
  if sgData.Cells[1, 1] = '' then Exit;
  with qrytemp do
  begin
     close;
      params.Clear;
      Params.CreateParam(ftString, 'Source', ptInput);
      commandtext:=' delete from sajet.g_transfer_detail where source=:source ';
      Params.ParamByName('Source').AsString := edtSource.Text;
      execute;
  end;
  for i := 1 to sgData.RowCount - 1 do
  begin
    with QryHt do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftString, 'userid', ptInput);
      if gsType = 'Material' then
        commandtext:=' update sajet.g_material '
                    +'       set type=''O'' '
                    +'      ,update_userid=:userid '
                    +'      ,update_time=sysDate '
                    +' where material_no=:material_no '
      else
        commandtext:=' update sajet.g_material '
                    +'       set type=''O'' '
                    +'      ,update_userid=:userid '
                    +'      ,update_time=sysDate '
                    +' where reel_no=:material_no ';
      Params.ParamByName('material_no').AsString := sgData.Cells[1, i];
      Params.ParamByName('userid').AsString := UpdateUserID;
      Execute;

      close;
      Params.CreateParam(ftString, 'material_no', ptInput);
      if gsType = 'Material' then
        commandtext:=' insert into sajet.g_ht_material '
                    +'  select * from sajet.g_material where material_no=:material_no '
      else
        commandtext:=' insert into sajet.g_ht_material '
                    +'  select * from sajet.g_material where reel_no=:material_no ';
      Params.ParamByName('material_no').AsString := sgData.Cells[1, i];
      Execute;
    end;

    with Qrytemp do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'source', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftString, 'to_locate', ptInput);
      Params.CreateParam(ftString, 'to_warehouse', ptInput);
      commandtext:=' insert into sajet.g_transfer_detail '
                  +' select :source, RT_ID, PART_ID,DATECODE,MATERIAL_NO,MATERIAL_QTY,REEL_NO,REEL_QTY, STATUS,locate_id, Warehouse_id '
                  +'  ,:TO_LOCATE,:TO_WAREHOUSE,UPDATE_USERID,UPDATE_TIME,REMARK,RELEASE_QTY,VERSION,MFGER_NAME,MFGER_PART_NO,RT_SEQ,TYPE, FIFOCODE '
                  +' from sajet.g_material ';
      if gsType = 'Material' then
        commandtext:=commandtext
                   +' where material_no=:Material_no '
      else
        Commandtext:=commandtext
                   +' where reel_no=:material_no ';
      Params.ParamByName('source').AsString := edtsource.Text;
      Params.ParamByName('material_no').AsString := sgData.Cells[1, i];
      Params.ParamByName('to_locate').AsString := sgData.Cells[13, i];
      Params.ParamByName('to_warehouse').AsString:=sgData.Cells[12, i];
      execute;
    end;

    {with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftInteger, 'locate_id', ptInput);
      Params.CreateParam(ftString, 'warehouse_id', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftString, 'userid', ptInput);
      CommandText := 'update sajet.g_material '
        + 'set  warehouse_id = :warehouse_id, locate_id = :locate_id,UPDATE_USERID=:userid,update_time=sysdate,type=''I'' ';
      if gsType = 'Material' then
        CommandText := CommandText + 'where material_no = :material_no '
      else
         commandtext:= commandtext + 'where reel_no = :material_no ';
      Params.ParamByName('warehouse_id').AsString := sgData.Cells[12, i];
      Params.ParamByName('locate_id').AsString := sgData.Cells[13, i];
      Params.ParamByName('material_no').AsString := sgData.Cells[1, i];
      Params.ParamByName('userid').AsString := UpdateUserID;
      Execute;
      Close;
      // Upload Push Title
      with sproc do
      begin
        try
          Close;
          DataRequest('SAJET.MES_ERP_TRANSFER');
          FetchParams;
          Params.ParamByName('TSOURCE').AsString := edtSource.Text;
          Params.ParamByName('TPARTNO').AsString := sgData.Cells[10, i];
          Params.ParamByName('TITEMID').AsString := sgData.Cells[11, i];
          Params.ParamByName('TVERSION').AsString := sgData.Cells[3, i];
          Params.ParamByName('TFSUBINV').AsString := sgData.Cells[6, i];
          Params.ParamByName('TFLOCATOR').AsString := sgData.Cells[7, i];
          Params.ParamByName('TLSUBINV').AsString := sgData.Cells[8, i];
          Params.ParamByName('TLLOCATOR').AsString := sgData.Cells[9, i];
          Params.ParamByName('TQTY').AsString := sgData.Cells[5, i];
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

    with qryHT do
    begin
       close;
       params.Clear;
       Params.CreateParam(ftString, 'material_no', ptInput);
       if gsType = 'Material' then
         commandtext:=' insert into  sajet.g_ht_material '
                     +'  select * from sajet.g_material where material_no=:material_no '
       else
         commandtext:=' insert into sajet.g_ht_material '
                     +'  select * from sajet.g_material where reel_no=:material_no ';
       Params.ParamByName('material_no').AsString := sgData.Cells[1, i];
       execute;
    end;}
  end;
  ClearData;
end;

procedure TfDetail.Delete1Click(Sender: TObject);
var i, j: Integer;
begin
  if (sgData.RowCount = 2) then
  begin
    sgData.Rows[1].Clear;
    sbtnCommit.Enabled := False;
  end
  else
  begin
    for i := giRow to sgData.RowCount - 1 do
      for j := 1 to 14 do
        sgData.Cells[j, i] := sgData.Cells[j, i + 1];
    sgData.RowCount := sgData.RowCount - 1;
  end;
  slData.Delete(giRow - 1);
end;

procedure TfDetail.sgDataSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  giRow := ARow;
end;

procedure TfDetail.edtSourceKeyPress(Sender: TObject; var Key: Char);
VAR sResult :STRING;
begin
  if Ord(Key) = vk_Return then
  begin
    sgData.RowCount := 2;
    sgData.Rows[1].Clear;
    sResult:=GetSource(edtSource.Text);
    if sResult<>'OK' then
    begin
      showmessage(sResult);
      edtsource.Clear ;
      edtsource.SetFocus;
      exit;
    end
    else
    begin
       if sbtncommit.Enabled =false then
           sbtncommit.Enabled :=true;
    end;
  end;
end;

procedure TfDetail.sbtnDeleteClick(Sender: TObject);
var i:integer;
begin
  if Trim(edtsource.Text)=''then
    begin
      if sbtnCommit.Enabled =true then
         sbtncommit.Enabled :=false;
      exit;
    end;
  if MessageDlg('Confirm Source: '+edtSource.Text +' ?' ,
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
     qrytemp.close;
     Qrytemp.Params.Clear;
     Qrytemp.Params.CreateParam(ftString, 'source', ptInput);
     Qrytemp.CommandText:=' select nvl(reel_no,material_no) material_no,to_warehouse,to_locate,remark  from sajet.g_transfer_detail where source=:source ';
     Qrytemp.Params.ParamByName('source').AsString := trim(edtSource.Text);
     Qrytemp.open;
     while not Qrytemp.eof do
     begin
       QryData.Close;
       QryData.Params.Clear;
       Qrydata.Params.CreateParam(ftstring,'Material_no1',ptInput);
       Qrydata.Params.CreateParam(ftstring,'Material_no2',ptInput);
       Qrydata.Params.CreateParam(ftInteger, 'locate_id', ptInput);
       Qrydata.Params.CreateParam(ftString, 'warehouse_id', ptInput);
       Qrydata.Params.CreateParam(ftstring,'User',ptInput);
       Qrydata.Params.CreateParam(ftstring,'Source',ptInput);
       QryData.CommandText:=' UPdate sajet.g_material '
                           +' set type=''I'' '
                           +'    , warehouse_id=:warehouse_id '
                           +'    , Locate_id=:Locate_id '
                           +'    ,update_time=sysdate '
                           +'    ,update_userid=:userid '
                           +'    ,remark = :Source '
                           +' where (material_no=:Material_no1) or (Reel_no=:material_no2) ';
       QryData.Params.ParamByName('material_no1').AsString := QryTemp.fieldbyname('Material_no').AsString;
       QryData.Params.ParamByName('material_no2').AsString := QryTemp.fieldbyname('Material_no').AsString;
       QryData.Params.ParamByName('warehouse_id').AsString := QryTemp.fieldbyname('to_warehouse').AsString;
       QryData.Params.ParamByName('locate_id').AsString := QryTemp.fieldbyname('to_locate').AsString;
       QryData.Params.ParamByName('Userid').AsString :=UpdateUserID ;
       QryData.Params.ParamByName('Source').AsString :=QryTemp.fieldbyname('remark').AsString;
       //QryData.Params.ParamByName('Source').AsString :=trim(edtSource.Text) ;
       QryData.execute;

       QryData.Close;
       QryData.Params.Clear;
       Qrydata.Params.CreateParam(ftstring,'Material_no1',ptInput);
       Qrydata.Params.CreateParam(ftstring,'Material_no2',ptInput);
       QryData.CommandText:=' Insert into sajet.g_ht_material '
                           +' select * from sajet.g_material '
                           +' where (material_no=:Material_no1) or (Reel_no=:material_no2) ';
       QryData.Params.ParamByName('material_no1').AsString := QryTemp.fieldbyname('Material_no').AsString;
       QryData.Params.ParamByName('material_no2').AsString := QryTemp.fieldbyname('Material_no').AsString;
       QryData.execute;
       Qrytemp.next;
     end;

     Qrytemp.Close;
     Qrytemp.Params.Clear;
     Qrytemp.Params.CreateParam(ftstring,'Source',ptInput);
     Qrytemp.CommandText:=' UPdate sajet.g_transfer_detail '
                         +' set type=''T'' '
                         +' where source=:source ';
     Qrytemp.Params.ParamByName('source').AsString := edtSource.Text;
     Qrytemp.Execute;

      // Upload Push Title
      for i := 1 to sgData.RowCount - 1 do
      begin
      with sproc do
      begin
        try
          Close;
          DataRequest('SAJET.MES_ERP_TRANSFER');
          FetchParams;
          Params.ParamByName('TSOURCE').AsString := edtSource.Text;
          Params.ParamByName('TPARTNO').AsString := sgData.Cells[10, i];
          Params.ParamByName('TITEMID').AsString := sgData.Cells[11, i];
          Params.ParamByName('TVERSION').AsString := sgData.Cells[3, i];
          Params.ParamByName('TFSUBINV').AsString := sgData.Cells[6, i];
          Params.ParamByName('TFLOCATOR').AsString := sgData.Cells[7, i];
          Params.ParamByName('TLSUBINV').AsString := sgData.Cells[8, i];
          Params.ParamByName('TLLOCATOR').AsString := sgData.Cells[9, i];
          Params.ParamByName('TQTY').AsString := sgData.Cells[5, i];
          if chkPush.Checked then
            Params.ParamByName('TPUSH').AsString := 'Y'
          else
            Params.ParamByName('TPUSH').AsString := 'N';
          Params.ParamByName('TEMPID').AsString := UpdateUserID;
          Params.ParamByName('TORGID').AsString := sgData.Cells[15, i];
          Execute;
        finally
          close;
        end;
      end;
     end;
     
     ClearData;
     IF sbtncommit.Enabled =true then
        sbtncommit.Enabled :=false;
     MessageDlg('Transfer Confirm OK.', mtInformation, [mbOk], 0);
  end;

end;

end.

