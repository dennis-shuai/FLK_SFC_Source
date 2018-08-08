unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, DBGrid1, RzButton, RzRadChk;

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
    editWo: TEdit;
    sedtQty: TSpinEdit;
    Label2: TLabel;
    lablType: TLabel;
    QryReel: TClientDataSet;
    Label9: TLabel;
    editMaterial: TEdit;
    Label12: TLabel;
    editPart: TEdit;
    sbtnFailSN: TSpeedButton;
    Label3: TLabel;
    lablQty: TLabel;
    Image1: TImage;
    sbtnClear: TSpeedButton;
    lablLocate: TLabel;
    cmbStock: TComboBox;
    cmbLocate: TComboBox;
    Label4: TLabel;
    edtDateCode: TEdit;
    Label5: TLabel;
    lablMQty: TLabel;
    lablMsg: TLabel;
    Image2: TImage;
    sbtnComplete: TSpeedButton;
    DBGrid11: TDBGrid1;
    DataSource1: TDataSource;
    DBGrid13: TDBGrid1;
    QryAbnormal: TClientDataSet;
    DataSource2: TDataSource;
    SProc: TClientDataSet;
    Label6: TLabel;
    edtVersion: TEdit;
    edtItem: TEdit;
    chkPush: TRzCheckBox;
    Label8: TLabel;
    Label11: TLabel;
    edtRT: TEdit;
    Label13: TLabel;
    edtFPN: TEdit;
    Memo1: TMemo;
    edtFIFO: TEdit;
    Label14: TLabel;
    Qrytemp1: TClientDataSet;
    Label15: TLabel;
    EditORG: TEdit;
    procedure FormShow(Sender: TObject);
    procedure editWoKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnMaterialClick(Sender: TObject);
    procedure sbtnFailSNClick(Sender: TObject);
    procedure editWoChange(Sender: TObject);
    procedure editMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnClearClick(Sender: TObject);
    procedure editPartKeyPress(Sender: TObject; var Key: Char);
    procedure cmbStockChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sbtnCompleteClick(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsGroupWo, gsLabelField, gsLocateField: string;
    slLocateId, slStockId: TStringList;
    gbFromWM, gbRTFlag: Boolean;
    G_FCID,G_FCCODE,G_FCTYPE:string;
    function CheckWo: Boolean;
    function CheckMaterial(var sPartId, sMfger, sMfgerPN: string): Boolean;
    function CheckPart: string;
    function CheckPickList(sPartId: string): Boolean;
    function CheckGroup(sType, sPartId: string; bInput: Boolean): Boolean;
    function updateTable(sPartId, stable, sType, sID: string; sInt: Integer): Boolean;
    procedure ClearData;
    function GetRtID(RTNO:string):string;
    Function GetFCTYPE(sFCID:string):string;
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

function TfDetail.GetRtID(RTNO:string):string;
begin
  with Qrytemp1 do
  begin
    close;
    params.Clear;
    commandtext:=' select rt_id from sajet.g_erp_rtno where rt_no = '+''''+RTNO+'''';
    open;
    Result:=fieldbyname('rt_id').AsString;
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
  gbRTFlag := False;
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
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Label Type'' ';
    Open;
    gsLabelField := FieldByName('param_name').AsString;
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
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where Param_Name = ''Material Caps Lock'' ';
    Open;
    if not QryTemp.IsEmpty then
    begin
      editWo.CharCase := ecUpperCase;
      editMaterial.CharCase := ecUpperCase;
      editPart.CharCase := ecUpperCase;
      edtRT.CharCase := ecUpperCase;
      edtDateCode.CharCase := ecUpperCase;
      edtFPN.CharCase := ecUpperCase;
    end;
  end;
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
    Params.ParamByName('dll_name').AsString := 'MATERIALRETURNDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
    Close;
  end;
  editWo.SetFocus;
end;

procedure TfDetail.editWoKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
    memo1.Clear;
    if CheckWo then
    begin
      {with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'work_order', ptInput);
        Params.CreateParam(ftString, 'work_order1', ptInput);
        CommandText := 'select group_wo '
          + 'from sajet.g_wo_group '
          + 'where work_order = :work_order or group_wo = :work_order1 ';
        Params.ParamByName('work_order').AsString := editWo.Text;
        Params.ParamByName('work_order1').AsString := editWo.Text;
        Open; }
      QryReel.Close;
      QryReel.Params.Clear;
      QryAbnormal.Close;
      QryReel.Params.CreateParam(ftString, 'work_order', ptInput);
      QryReel.CommandText := 'select work_order,from_wo from sajet.g_wo_group '
        + 'where group_wo = (select group_wo from sajet.g_wo_group where work_order = :work_order) '
        + 'and work_order <> ''N/A'' '
        + 'order by work_order';
      QryReel.Params.ParamByName('work_order').AsString := editWo.Text;
      QryReel.Open;
      QryReel.First;
      while not QryReel.Eof do
      begin
        if editWo.Text = QryReel.FieldByName('from_wo').AsString then
        begin
          MessageDlg('Group WO ,Only Return Last WO', mtError, [mbOK], 0);
          editWo.SelectAll;
          editWo.SetFocus;
          exit;
        end;
        QryReel.next;
      end;

      QryAbnormal.Close;
      QryAbnormal.Params.Clear;
      QryAbnormal.Params.CreateParam(ftString, 'work_order', ptInput);
      QryAbnormal.CommandText := 'select a.*, part_no, option3 '
        + 'from sajet.g_material_wm a , sajet.sys_part b '
        + 'where a.part_id = b.part_id and work_order=:work_order '
        + 'order by part_no ';
      QryAbnormal.Params.ParamByName('work_order').AsString := editWo.Text;
      QryAbnormal.Open;
      //end;
      editMaterial.Enabled := True;
      //editPart.Enabled := True;
      sedtQty.Enabled := True;
      editMaterial.SetFocus;
    end;
  end;
end;

function TfDetail.CheckWo: Boolean;
begin
  G_FCID:='';
  editorg.Text :='';
  Result := True;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    CommandText := 'select work_order, WO_STATUS,factory_id from sajet.g_wo_base '
      + 'where work_order = :work_order ';
    Params.ParamByName('work_order').AsString := editWo.Text;
    Open;
    if IsEmpty then
    begin
      MessageDlg('Work Order: ' + editWo.Text + ' not found!', mtError, [mbOK], 0);
      Result := False;
    end
    else if FieldByName('WO_STATUS').AsString <> '6' then
    begin
      MessageDlg('Work Order: ' + editWo.Text + ' not complete!', mtError, [mbOK], 0);
      Result := False;
    end
    else if FieldByName('WO_STATUS').AsString = '9' then
    begin
      MessageDlg('Work Order: ' + editWo.Text + ' is complete-no charge!', mtError, [mbOK], 0);
      Result := False;
    end
    else if  FieldByName('factory_id').AsString<>'' then
    begin
          G_FCID := FieldByName('factory_id').AsString;
          G_FCCODE:='';
          G_FCTYPE:='';
          editorg.Clear ;
          if Getfctype(G_FCID)<>'OK' then
          begin
             editorg.Clear;
             exit;
          end
          else
             editorg.Text :=G_FCCODE;
    end
    else
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'work_order', ptInput);
      Params.CreateParam(ftString, 'work_order2', ptInput);
      CommandText := 'select b.work_order, wo_status '
        + 'from sajet.g_wo_group a, sajet.g_wo_group c, sajet.g_wo_base b '
        + 'where a.work_order = :work_order and a.group_wo = c.group_wo '
        + 'and c.work_order = b.work_order and wo_status <> ''6'' and b.work_order <> :work_order2';
      Params.ParamByName('work_order').AsString := editWo.Text;
      Params.ParamByName('work_order2').AsString := editWo.Text;
      Open;
      if not IsEmpty then
      begin
        MessageDlg('Work Order: ' + FieldByName('work_order').AsString + ' not complete!', mtError, [mbOK], 0);
        Result := False;
      end;
    end;
    Close;
    editWo.SelectAll;
    editWo.SetFocus;
  end;
end;

function TfDetail.CheckMaterial(var sPartId, sMfger, sMfgerPN: string): Boolean;
begin
  // 來源table錯誤
  Result := False;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'material_no', ptInput);
    CommandText := 'select a.work_order,a.part_id, part_no, qty, datecode, sequence, a.version, option7, a.MFGER_NAME, a.MFGER_PART_NO '
      + 'from sajet.g_pick_list a, sajet.sys_part b '
      + 'where material_no = :material_no and a.part_id = b.part_id ';
    Params.ParamByName('material_no').AsString := editMaterial.Text;
    Open;
    if IsEmpty then
    begin
      MessageDlg('Material No not found!', mtError, [mbOK], 0);
      editMaterial.SelectAll;
      editMaterial.SetFocus;
    end
    else
    begin
      sPartId := FieldByName('part_id').AsString;
      editPart.Text := FieldByName('part_no').AsString;
      edtItem.Text := FieldByName('option7').AsString;
      lablMQty.Caption := FieldByName('qty').AsString;
      edtDateCode.Text := FieldByName('DateCode').AsString;
      edtVersion.Text := FieldByName('version').AsString;
      sMfger := FieldByName('MFGER_NAME').AsString;
      sMfgerPN := FieldByName('MFGER_PART_NO').AsString;
      Result := True;
    end;
  end;
end;

function TfDetail.CheckPart: string;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'part_no', ptInput);
    CommandText := 'select part_id from sajet.sys_part '
      + 'where part_no = :part_no ';
    Params.ParamByName('part_no').AsString := editPart.Text;
    Open;
    if IsEmpty then
    begin
      MessageDlg('Part No not found!', mtError, [mbOK], 0);
      editPart.SelectAll;
      editPart.SetFocus;
      Result := '';
    end
    else
    begin
      Result := FieldByName('part_id').AsString;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PART_ID', ptInput);
      CommandText := 'select ' + gsLabelField + ' label_type from sajet.sys_part '
        + ' where part_id = :part_id and rownum = 1';
      Params.ParamByName('PART_ID').AsString := Result;
      Open;
      lablType.Caption := FieldByName('Label_Type').AsString;
      if lablType.Caption = '' then
        lablType.Caption := 'QTY ID';
    end;
  end;
end;

function TfDetail.CheckPickList(sPartId: string): Boolean;
begin
  Result := True;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    Params.CreateParam(ftString, 'part_id', ptInput);
    CommandText := 'select a.part_id from sajet.G_MATERIAL_WM a '
      + 'where work_order = :work_order and a.part_id = :part_id and rownum = 1';
    Params.ParamByName('work_order').AsString := editWo.Text;
    Params.ParamByName('part_id').AsString := sPartId;
    Open;
    if IsEmpty then
    begin
      MessageDlg('Part NG!', mtError, [mbOK], 0);
      editMaterial.SelectAll;
      editMaterial.SetFocus;
      Result := False;
    end;
  end;
end;

function TfDetail.CheckGroup(sType, sPartID: string; bInput: Boolean): Boolean;
var sComm, sLocate: string;
begin
  Result := True;
  gbFromWM := True;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'material_no', ptInput);
    CommandText := 'select b.group_wo, c.qty, a.part_id from sajet.g_wo_group b, sajet.g_material_wm c ';
    if sType = 'Material' then
    begin
      CommandText := CommandText + ',sajet.g_pick_list a '
        + 'where (a.work_order = b.work_order or a.work_order = b.group_wo) and a.material_no = :material_no  ';
      sComm := 'and';
    end
    else
      sComm := 'where';
    CommandText := CommandText + sComm + ' a.part_id = c.part_id and (b.group_wo = c.work_order or b.work_order = c.work_order) '
      + 'and rownum = 1';
    Params.ParamByName('material_no').AsString := editMaterial.Text;
    Open;
    if IsEmpty then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'work_order', ptInput);
      Params.CreateParam(ftString, 'part_id', ptInput);
      CommandText := 'select * from sajet.g_material_wm '
        + 'where work_order = :work_order and part_id = :part_id ';
      Params.ParamByName('work_order').AsString := editWo.Text;
      Params.ParamByName('part_id').AsString := sPartID;
      Open;
      if IsEmpty then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'work_order', ptInput);
        Params.CreateParam(ftString, 'part_id', ptInput);
        CommandText := 'select scrap_qty qty from sajet.g_wo_pick_list '
          + 'where work_order = :work_order and part_id = :part_id '
          + 'and rownum = 1';
        Params.ParamByName('work_order').AsString := editWo.Text;
        Params.ParamByName('part_id').AsString := sPartID;
        Open;
        lablQty.Caption := FieldByName('qty').AsString;
        if FieldByName('qty').AsInteger = 0 then
        begin
          MessageDlg('Material NG! (Over Request)', mtError, [mbOK], 0);
          editPart.Text := '';
          edtDateCode.Text := '';
          editMaterial.SelectAll;
          editMaterial.SetFocus;
          Result := False;
          Exit;
        end;
        gbFromWM := False;
      end
      else
        gsGroupWo := editWo.Text;
    end
    else
      gsGroupWo := FieldByName('Group_Wo').AsString;
    lablQty.Caption := FieldByName('qty').AsString;
    QryTemp.Close;
    QryTemp.Params.Clear;
   { //  預設Loate 取sys_part table 中的值
    QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.CommandText := 'select locate_name, warehouse_name, b.warehouse_id, locate_id from sajet.sys_part a, sajet.sys_locate b, sajet.sys_warehouse c '
      + 'where part_id = :part_id and a.' + gsLocateField + ' = to_char(b.locate_id) and b.warehouse_id = c.warehouse_id and rownum = 1';
    QryTemp.Params.ParamByName('part_id').AsString := sPartID;
    }
    // 預設Loate 取sys_part_factory table 中的值
    QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.Params.CreateParam(ftString, 'factory_id', ptInput);
    QryTemp.CommandText := 'select locate_name, warehouse_name, b.warehouse_id, a.locate_id from sajet.sys_part_factory a, sajet.sys_locate b, sajet.sys_warehouse c '
        + 'where part_id = :part_id and a.locate_id = to_char(b.locate_id) and b.warehouse_id = c.warehouse_id and a.factory_id = :factory_id and rownum = 1';
    QryTemp.Params.ParamByName('part_id').AsString := sPartID;
    QryTemp.Params.ParamByName('factory_id').AsString :=G_FCID ;
    QryTemp.Open;
    if bInput then
    begin
      cmbStock.ItemIndex := cmbStock.Items.IndexOf(QryTemp.FieldByName('Warehouse_name').AsString);
      sLocate := QryTemp.FieldByName('locate_name').AsString;
      if cmbStock.ItemIndex <> -1 then
      begin
        cmbStockChange(Self);
        cmbLocate.ItemIndex := cmbLocate.Items.IndexOf(sLocate);
      end;
    end;
  end;
end;

procedure TfDetail.sbtnMaterialClick(Sender: TObject);
  procedure InsertMaterial(sType, sPartId, sMfger, sMfgerPN: string);
  var sMaterial, sPrintData: string;
    iCnt: Integer;
  begin
    with QryTemp do
    begin
      if lablType.Caption <> '' then
      begin
        Close;
        Params.Clear;
        CommandText := 'select sajet.to_label(''' + lablType.Caption + ''', ''' + editMaterial.Text + ''') SNID from dual';
        Open;
        sMaterial := FieldByName('SNID').AsString;
        Close;
      end
      else
        sMaterial := editMaterial.Text + '-01';
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'qty', ptInput);
      Params.CreateParam(ftString, 'work_order', ptInput);
      Params.CreateParam(ftString, 'part_id', ptInput);
      CommandText := 'update sajet.g_wo_pick_list '
        + 'set scrap_qty = scrap_qty + :qty '
        + 'where work_order = :work_order and part_id = :part_id ';
      if gbFromWM then
        Params.ParamByName('qty').AsInteger := StrToIntDef(lablQty.Caption, 0) - sedtQty.Value
      else
        Params.ParamByName('qty').AsInteger := -1 * sedtQty.Value;
      Params.ParamByName('work_order').AsString := editWo.Text;
      Params.ParamByName('part_id').AsString := sPartId;
      Execute;

      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'group_wo', ptInput);
      Params.CreateParam(ftString, 'part_id', ptInput);
      CommandText := 'select rowid,qty,UPDATE_TIME from sajet.g_material_wm ';
      CommandText := CommandText + 'where work_order = :group_wo and part_id = :part_id order by UPDATE_TIME desc ';
      Params.ParamByName('group_wo').AsString := editWo.Text;
      Params.ParamByName('part_id').AsString := sPartId;
      open;
      iCnt := 0;
      QryTemp.First;
      if not QryTemp.IsEmpty then
      begin
        while not QryTemp.Eof do
        begin
          if FieldByName('qty').AsInteger <= (sedtQty.Value - iCnt) then
          begin
            iCnt := iCnt + FieldByName('qty').AsInteger;
            updateTable(sPartId, 'sajet.g_material_wm', 'Delete', FieldByName('rowid').AsString, 0);
          end
          else if FieldByName('qty').AsInteger > (sedtQty.Value - iCnt) then
          begin
            updateTable(sPartId, 'sajet.g_material_wm', 'Update', FieldByName('rowid').AsString, sedtQty.Value - iCnt);
            Break;
          end;
          next;
        end;
      end;
      {Close;
      Params.Clear;
      Params.CreateParam(ftString, 'group_wo', ptInput);
      Params.CreateParam(ftString, 'part_id', ptInput);
      CommandText := 'delete sajet.g_material_wm ';
      CommandText := CommandText + 'where work_order = :group_wo and part_id = :part_id ';
      Params.ParamByName('group_wo').AsString := gsGroupWo;
      Params.ParamByName('part_id').AsString := sPartId;
      Execute;
      if (gsGroupWo <> editWo.Text) then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'group_wo', ptInput);
        Params.CreateParam(ftString, 'part_id', ptInput);
        CommandText := 'delete sajet.g_material_wm ';
        CommandText := CommandText + 'where group_wo = :group_wo and part_id = :part_id ';
        Params.ParamByName('group_wo').AsString := gsGroupWo;
        Params.ParamByName('part_id').AsString := sPartId;
        Execute;
      end;}
      Close;
      if editMaterial.Text <> '' then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'update_userid', ptInput);
        Params.CreateParam(ftString, 'material_no', ptInput);
        Params.CreateParam(ftInteger, 'qty', ptInput);
        CommandText := 'update sajet.g_pick_list '
          + 'set update_time = sysdate, update_userid = :update_userid,qty=qty-:qty '
          + 'where material_no = :material_no ';
        Params.ParamByName('update_userid').AsString := UpdateUserID;
        Params.ParamByName('material_no').AsString := editMaterial.Text;
        Params.ParamByName('qty').AsInteger := sedtQty.Value;
        Execute;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'material_no', ptInput);
        CommandText := 'insert into sajet.g_ht_pick_list '
          + 'select * from sajet.g_pick_list '
          + 'where material_no = :material_no ';
        Params.ParamByName('material_no').AsString := editMaterial.Text;
        Execute;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'material_no', ptInput);
        CommandText := 'select *  from sajet.g_pick_list '
          + 'where material_no = :material_no and qty=0 ';
        Params.ParamByName('material_no').AsString := editMaterial.Text;
        open;
        if not QryTemp.IsEmpty then
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'material_no', ptInput);
          CommandText := 'delete from sajet.g_pick_list '
            + 'where material_no = :material_no ';
          Params.ParamByName('material_no').AsString := editMaterial.Text;
          Execute;
        end;
      end;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PART_ID', ptInput);
      Params.CreateParam(ftString, 'datecode', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftString, 'material_qty', ptInput);
      Params.CreateParam(ftString, 'update_userid', ptInput);
      Params.CreateParam(ftString, 'warehouse_id', ptInput);
      Params.CreateParam(ftString, 'locate_id', ptInput);
      Params.CreateParam(ftString, 'MFGER_NAME', ptInput);
      Params.CreateParam(ftString, 'MFGER_PART_NO', ptInput);
      Params.CreateParam(ftString, 'RT_ID', ptInput);
      Params.CreateParam(ftString, 'REMARK', ptInput);
      Params.CreateParam(ftString, 'version', ptInput);
      Params.CreateParam(ftString, 'FIFO', ptInput);
      Params.CreateParam(ftString, 'FACTORY_ID', ptInput);
      Params.CreateParam(ftString, 'FACTORY_TYPE', ptInput);
      CommandText := 'insert into sajet.g_material '
        + '(part_id, datecode, material_no, material_qty, update_userid, warehouse_id, locate_id, update_time, status, MFGER_NAME, MFGER_PART_NO,RT_ID,REMARK, version,FIFOCode,FACTORY_ID,FACTORY_TYPE) '
        + 'values (:part_id, :datecode, :material_no, :material_qty, :update_userid, :warehouse_id, :locate_id, sysdate, 1, :MFGER_NAME, :MFGER_PART_NO,:RT_ID,:REMARK, :version,:FIFO,:FACTORY_ID,:FACTORY_TYPE)';
      Params.ParamByName('PART_ID').AsString := sPartId;
      Params.ParamByName('datecode').AsString := edtDateCode.Text;
      Params.ParamByName('material_no').AsString := sMaterial;
      Params.ParamByName('material_qty').AsString := sedtQty.Text;
      Params.ParamByName('update_userid').AsString := UpdateUserID;
      Params.ParamByName('warehouse_id').AsString := slStockId[cmbStock.ItemIndex];
      if cmbLocate.ItemIndex <> -1 then
        Params.ParamByName('locate_id').AsString := slLocateId[cmbLocate.ItemIndex]
      else
        Params.ParamByName('locate_id').AsString := '';
      Params.ParamByName('MFGER_NAME').AsString := sMfger;
      if editPart.Text <> '' then
        Params.ParamByName('MFGER_PART_NO').AsString := edtFPN.Text
      else
        Params.ParamByName('MFGER_PART_NO').AsString := sMfgerPN;
      if gbRTFlag = True then
      begin
        Params.ParamByName('RT_ID').AsString := GetRtID(edtRT.Text);
        Params.ParamByName('REMARK').AsString := '';
      end
      else
      begin
        Params.ParamByName('RT_ID').AsString := '';
        Params.ParamByName('REMARK').AsString := edtRT.Text;
      end;
      Params.ParamByName('fifo').AsString := edtfifo.Text;
      Params.ParamByName('FACTORY_ID').AsString := G_FCID;
      Params.ParamByName('FACTORY_TYPE').AsString := G_FCTYPE;
      Execute;
      Close;
      params.clear;
      Params.CreateParam(ftString, 'material_no', ptInput);
      commandtext:=' insert into sajet.g_ht_material '
                  +' select * from sajet.g_material where material_no=:material_no ';
      Params.ParamByName('material_no').AsString := sMaterial;
      Execute;
      Close;

      sPrintData := G_getPrintData(6, 17, G_sockConnection, 'DspQryData', lablType.Caption + '*&*' + sMaterial, 1, 'DEFAULT');
      if assigned(G_onTransDataToApplication) then
        G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
      else
        showmessage('Not Defined Call Back Function for Code Soft');
      lablMsg.Caption := 'Return OK, New ID: ' + sMaterial + '.';
      // Upload Push Title
      with sproc do
      begin
        try
          Close;
          DataRequest('SAJET.MES_ERP_WIP_RETURN');
          FetchParams;
          Params.ParamByName('TWO').AsString := editWo.Text;
          Params.ParamByName('TPART').AsString := editPart.Text;
          Params.ParamByName('TITEMID').AsString := edtItem.Text;
          Params.ParamByName('TREV').AsString := edtVersion.Text;
          Params.ParamByName('TQTY').AsInteger := sedtQty.Value;
          Params.ParamByName('TSUBINV').AsString := cmbStock.Text;
          Params.ParamByName('TLOCATOR').AsString := cmbLocate.Text;
          if chkPush.Checked then
            Params.ParamByName('TPUSH').AsString := 'Y'
          else
            Params.ParamByName('TPUSH').AsString := 'N';
          Params.ParamByName('TEMPID').AsString := UpdateUserID;
          Execute;
          Memo1.Lines.Insert(0, Params.ParamByName('TRES').AsString);
        finally
          close;
        end;
      end;
    end;
  end;
var sType, sPartId, sMfger, sMfgerPN: string;
begin
  if sedtQty.Value <= 0 then Exit;
  if trim(editorg.Text)='' then
  begin
      MessageDlg('WO '+editwo.Text+' ORG IS ERROR', mtWarning, [mbOK], 0);
      Exit;
  end;
  //if (cmbStock.Text = '') or ((cmbLocate.Items.Count > 0) and (cmbLocate.ItemIndex = -1)) then
  if  cmbLocate.ItemIndex = -1  then
  begin
    MessageDlg('Please select Locator!', mtWarning, [mbOK], 0);
    Exit;
  end;

  if CheckWo then
  begin
    if editMaterial.Text <> '' then
    begin
      if CheckMaterial(sPartId, sMfger, sMfgerPN) then
      begin
        CheckPart;
        if CheckPickList(sPartId) then
          if CheckGroup('Material', sPartID, False) then
          begin
            if sedtQty.Value > StrToIntDef(lablQty.Caption, -1) then
            begin
              MessageDlg('QTY Error!', mtError, [mbOK], 0);
              sedtQty.SetFocus;
              sedtQty.SelectAll;
              Exit;
            end
            else if sedtQty.Value > StrToIntDef(lablMQty.Caption, -1) then
            begin
              MessageDlg('QTY Error!', mtError, [mbOK], 0);
              sedtQty.SetFocus;
              sedtQty.SelectAll;
              Exit;
            end;
            InsertMaterial(sType, sPartId, sMfger, sMfgerPN);
          end;
      end;
    end
    else
    begin
      if editPart.Text <> '' then
      begin
        sPartId := CheckPart;
        if sPartId <> '' then
          if CheckPickList(sPartID) then
            if CheckGroup('Material', sPartId, False) then
            begin
              if sedtQty.Value > StrToIntDef(lablQty.Caption, -1) then
              begin
                MessageDlg('QTY Error!', mtError, [mbOK], 0);
                sedtQty.SetFocus;
                sedtQty.SelectAll;
                Exit;
              end;
              InsertMaterial('', sPartId, '', '');
            end;
      end;
    end;
    editMaterial.Text := '';
    editPart.Text := '';
    sedtQty.Text := '0';
    lablQty.Caption := '';
    edtDateCode.Text := '';
    lablMQty.Caption := '';
    //editPart.Enabled := True;
    edtRT.Text := '';
    edtFPN.Text := '';
    edtVersion.Text := '';
    cmbStock.ItemIndex := -1;
    cmbLocate.Items.Clear;
    edtfifo.Text :='';
    editMaterial.SetFocus;
    QryAbnormal.Close;
    QryAbnormal.Open;
  end;
end;

procedure TfDetail.sbtnFailSNClick(Sender: TObject);
var Key: Char;
begin
  with TfCommData.Create(Self) do
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      if editWo.Text <> '' then
        Params.CreateParam(ftString, 'work_order', ptInput);
      CommandText := 'select work_order "Work Order", target_qty "Target Qty", '
        + 'part_no "Part No", part_type "Part Type", spec1 "Spec1", spec2 "Spec2" '
        + 'from sajet.g_wo_base a, sajet.sys_part b '
        + 'where wo_status = 6 ';
      if editWo.Text <> '' then
        CommandText := CommandText + 'and work_order like :work_order ';
      CommandText := CommandText + 'and a.model_id = b.part_id '
        + 'order by work_order ';
      if editWo.Text <> '' then
        Params.ParamByName('work_order').AsString := editWo.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      editWo.Text := QryTemp.FieldByName('work order').AsString;
      editMaterial.Enabled := True;
      //editPart.Enabled := True;
      sedtQty.Enabled := True;
      editMaterial.SetFocus;
      Key := #13;
      editWoKeyPress(Self, Key);
    end;
    QryTemp.Close;
    free;
  end;
end;

procedure TfDetail.editWoChange(Sender: TObject);
begin
  lablMsg.Caption := '';
  editMaterial.Text := '';
  editPart.Text := '';
  edtFIFO.Text:='';
  sedtQty.Text := '0';
  lablQty.Caption := '';
  editMaterial.Enabled := False;
  editPart.Enabled := False;
  sedtQty.Enabled := False;
end;

procedure TfDetail.editMaterialKeyPress(Sender: TObject; var Key: Char);
var sPartID, sMfger, sMfgerPN: string;
begin
  if Ord(Key) = vk_Return then
  begin
    lablMsg.Caption := '';
    if QryAbnormal.IsEmpty then exit;
    if CheckMaterial(sPartId, sMfger, sMfgerPN) then
      if CheckPickList(sPartID) then
      begin
        if CheckGroup('Material', sPartId, True) then
        begin
          QryTemp.Close;
          QryTemp.Params.Clear;
          QryTemp.Params.CreateParam(ftString, 'MATERIAL_NO', ptInput);
          QryTemp.CommandText := 'select nvl(B.RT_NO,''N/A'') RT_NO,NVL(A.REMARK,''N/A'') REMARK,a.UPDATE_TIME,a.fifoCode from sajet.G_HT_MATERIAL a,SAJET.G_ERP_RTNO b '
            + 'where a.MATERIAL_NO = :MATERIAL_NO AND A.RT_ID=B.RT_ID(+) '
            + 'order by UPDATE_TIME desc ';
          QryTemp.Params.ParamByName('MATERIAL_NO').AsString := editMaterial.Text; ;
          QryTemp.Open;
          if QryTemp.IsEmpty then
          begin
            QryTemp.Close;
            QryTemp.Params.Clear;
            QryTemp.Params.CreateParam(ftString, 'MATERIAL_NO', ptInput);
            QryTemp.CommandText := 'select nvl(B.RT_NO,''N/A'') RT_NO,NVL(A.REMARK,''N/A'') REMARK,a.UPDATE_TIME,a.FIFOCode from sajet.G_HT_MATERIAL a,SAJET.G_ERP_RTNO b '
              + 'where a.REEL_NO = :MATERIAL_NO AND A.RT_ID=B.RT_ID(+) '
              + 'order by UPDATE_TIME desc ';
            QryTemp.Params.ParamByName('MATERIAL_NO').AsString := editMaterial.Text; ;
            QryTemp.Open;
            if QryTemp.IsEmpty then
            begin
              MessageDlg('G_HT_MATERIAL Not Exist !', mtError, [mbOK], 0);
              editMaterial.SelectAll;
              editMaterial.SetFocus;
              exit;
            end;
          end;
          if QryTemp.FieldByName('RT_NO').AsString <> 'N/A' then
          begin
            edtRT.Text := QryTemp.FieldByName('RT_NO').AsString;
            gbRTFlag := True;
          end
          else if QryTemp.FieldByName('REMARK').AsString <> 'N/A' then
          begin
            edtRT.Text := QryTemp.FieldByName('REMARK').AsString;
            gbRTFlag := False;
          end;
          editPart.Enabled := False;
          edtFIFO.Text:=QryTemp.fieldbyname('FIFOCode').asstring;
          sedtQty.SelectAll;
          sedtQty.SetFocus;
        end;
        sbtnMaterial.Enabled := True;
      end;

  end;
end;

procedure TfDetail.sbtnClearClick(Sender: TObject);
begin
  ClearData;
end;

procedure TfDetail.ClearData;
begin
  editWo.Text := '';
  editMaterial.Text := '';
  editPart.Text := '';
  sedtQty.Text := '0';
  lablQty.Caption := '';
  edtDateCode.Text := '';
  lablMQty.Caption := '';
  edtRT.Text := '';
  edtFPN.Text := '';
  edtVersion.Text := '';
  editMaterial.Enabled := False;
  editPart.Enabled := False;
  sedtQty.Enabled := False;
  lablMsg.Caption := '';
  edtfifo.Text :='';
  QryAbnormal.Close;
  QryReel.Close;
end;

procedure TfDetail.editPartKeyPress(Sender: TObject; var Key: Char);
var sPartID, sStr: string;
begin
  // not return material by PartNo
  exit;
  //------------------------------

  if Ord(Key) = vk_Return then
  begin
    sPartID := CheckPart;
    if QryAbnormal.IsEmpty then exit;
    if sPartID <> '' then
    begin
      if CheckPickList(sPartID) then
      begin
        if CheckGroup('Material', sPartID, True) then
          sedtQty.SetFocus
        else
          exit;
      end
      else
        exit;
    end
    else
      exit;
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'pn', ptInput);
      CommandText := 'select part_id,option7, version from sajet.sys_part '
        + 'where part_no=:pn ';
      Params.ParamByName('pn').AsString := editPart.Text;
      Open;
      sPartId := FieldByName('part_id').AsString;
      edtItem.Text := FieldByName('option7').AsString;
      edtVersion.Text := FieldByName('version').AsString;
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
      QryTemp.CommandText := 'select locate_name, warehouse_name, b.warehouse_id, locate_id from sajet.sys_part a, sajet.sys_locate b, sajet.sys_warehouse c '
        + 'where part_id = :part_id and a.' + gsLocateField + ' = to_char(b.locate_id) and b.warehouse_id = c.warehouse_id and rownum = 1';
      QryTemp.Params.ParamByName('part_id').AsString := sPartID;
      QryTemp.Open;
      if not QryTemp.IsEmpty then
      begin
        cmbStock.ItemIndex := cmbStock.Items.IndexOf(QryTemp.FieldByName('Warehouse_name').AsString);
        sStr := QryTemp.FieldByName('locate_name').AsString;
        if cmbStock.ItemIndex <> -1 then
        begin
          cmbStockChange(Self);
          cmbLocate.ItemIndex := cmbLocate.Items.IndexOf(sStr);
        end
        else
        begin
          cmbStock.ItemIndex := -1;
          cmbLocate.ItemIndex := -1;
        end;
      end
      else
      begin
        cmbStock.ItemIndex := -1;
        cmbLocate.ItemIndex := -1;
      end;
    end;
    sbtnMaterial.Enabled := True;
  end;
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

procedure TfDetail.sbtnCompleteClick(Sender: TObject);
begin
  if editWo.Text = '' then Exit;
  if not QryAbnormal.Active then Exit;
  if QryAbnormal.IsEmpty then Exit;
  if messagebox(fDetail.Handle, 'Are You Sure ?', '', mb_OkCancel) = idCancel then exit;
  with QryDetail do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    CommandText := 'select * from sajet.g_material_wm '
      + 'where work_order = :work_order ';
    Params.ParamByName('work_order').AsString := editWo.Text;
    Open;
    while not Eof do
    begin
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'scrap_qty', ptInput);
      QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
      QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
      QryTemp.CommandText := 'update sajet.g_wo_pick_list '
        + 'set scrap_qty = scrap_qty + :scrap_qty '
        + 'where work_order = :work_order and part_id = :part_id ';
      QryTemp.Params.ParamByName('scrap_qty').AsString := FieldByName('qty').AsString;
      QryTemp.Params.ParamByName('work_order').AsString := editWo.Text;
      QryTemp.Params.ParamByName('part_id').AsString := FieldByName('part_id').AsString;
      QryTemp.Execute;
      QryTemp.Close;
      Next;
    end;
    Close;
    Params.Clear;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    CommandText := 'delete from sajet.g_material_wm '
      + 'where work_order = :work_order ';
    Params.ParamByName('work_order').AsString := editWo.Text;
    Execute;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    CommandText := 'insert into sajet.g_ht_pick_list '
      + 'select * from sajet.g_pick_list '
      + 'where work_order = :work_order ';
    Params.ParamByName('work_order').AsString := editWo.Text;
    Execute;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    CommandText := 'delete from sajet.g_pick_list '
      + 'where work_order = :work_order ';
    Params.ParamByName('work_order').AsString := editWo.Text;
    Execute;
    Close;
  end;
  MessageDlg('Work Order: ' + editWo.Text + ' complete OK.', mtInformation, [mbOK], 0);
  sbtnClearClick(Self);
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

function TfDetail.updateTable(sPartId, stable, sType, sID: string; sInt: Integer): Boolean;
begin
  Result := False;
  with QryDetail do
  begin
    Close;
    Params.Clear;
    if sType = 'Delete' then
    begin
      Params.CreateParam(ftString, 'PN', ptInput);
      Params.CreateParam(ftString, 'sID', ptInput);
      CommandText := 'delete FROM  ' + stable;
      CommandText := CommandText + ' where rowid=:sID and work_order = ''' + editWo.text + ''' and part_id =:PN ';
      Params.ParamByName('PN').AsString := sPartId;
      Params.ParamByName('sID').AsString := sID;
    end
    else if sType = 'Update' then
    begin
      Params.CreateParam(ftInteger, 'sqty', ptInput);
      Params.CreateParam(ftString, 'PN', ptInput);
      Params.CreateParam(ftString, 'sUSER', ptInput);
      Params.CreateParam(ftString, 'sID', ptInput);
      CommandText := 'update ' + stable + ' set qty=qty -:sqty ,update_time=sysdate,Update_UserID=:sUSER ';
      CommandText := CommandText + ' where rowid=:sID and work_order = ''' + editWo.text + ''' and part_id = :PN ';
      Params.ParamByName('sqty').AsInteger := sInt;
      Params.ParamByName('PN').AsString := sPartId;
      Params.ParamByName('sUSER').AsString := UpdateUserID;
      Params.ParamByName('sID').AsString := sID;
    end;
    Execute;
  end;
  Result := True;
end;

end.

