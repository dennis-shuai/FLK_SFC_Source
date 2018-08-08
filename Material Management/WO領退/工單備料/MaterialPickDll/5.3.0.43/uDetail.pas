unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, ComCtrls, ImgList, ListView1;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
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
    QryTemp1: TClientDataSet;
    edtWo: TEdit;
    Label8: TLabel;
    QryGroup: TClientDataSet;
    DataSource3: TDataSource;
    edtMaterial: TEdit;
    Label2: TLabel;
    DBGrid1: TDBGrid;
    ImageList1: TImageList;
    Label3: TLabel;
    lablQty: TLabel;
    Label4: TLabel;
    lablPdline: TLabel;
    DBGrid2: TDBGrid;
    Image3: TImage;
    sbtnDelete: TSpeedButton;
    Label5: TLabel;
    Label6: TLabel;
    Bevel1: TBevel;
    Image1: TImage;
    sbtnConfirm: TSpeedButton;
    SProc: TClientDataSet;
    Label9: TLabel;
    combType: TComboBox;
    sbtnCheck: TSpeedButton;
    combDisplay: TComboBox;
    sedtQty: TSpinEdit;
    Label11: TLabel;
    Image2: TImage;
    SpeedButton1: TSpeedButton;
    edtWM: TEdit;
    sbtnWM: TSpeedButton;
    sbtnWoformWM: TSpeedButton;
    LvList: TListView1;
    chkPush: TCheckBox;
    lablPush: TLabel;
    QryWM: TClientDataSet;
    procedure FormShow(Sender: TObject);
    procedure edtWoKeyPress(Sender: TObject; var Key: Char);
    procedure edtMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure LvListCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure sbtnDeleteClick(Sender: TObject);
    procedure sbtnConfirmClick(Sender: TObject);
    procedure combDisplayChange(Sender: TObject);
    procedure combTypeChange(Sender: TObject);
    procedure sbtnCheckClick(Sender: TObject);
    procedure sbtnWoformWMClick(Sender: TObject);
    procedure sbtnWMClick(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsPdlineId, gsGroupWo, gsOverField, gsParam: String;
    giSequence, gsFlag, gslpartno, gsLocateField: string;
    giRow, giLocate, giPick, PartQty: Integer;
    gbGroup: Boolean;
    function CheckPickList(ShowFlag: Boolean): Boolean;
    procedure ShowMaterial(bRefresh: Boolean);
    function ShowWOPickList: Boolean;
    function CheckMaterial: Boolean;
    function CheckRequest: Boolean;
    procedure ShowGroup;
    function CheckGroup: Boolean;
    procedure ClearData;
    procedure UpdateWM(sPartID, gsGroupWo: string; iWMQty: Real);
    function ShowWo(bKeyPress: Boolean): Boolean;
    function checkFIFO(MaterailNo:string;VAR NOCHECK:STRING):string;
    function SendMsg:boolean;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, DllInit, uCommData, uLogin;

function TfDetail.SendMsg:boolean;
begin
  with qrytemp do
  begin
    close;
    commandtext:='select param_value from sajet.sys_base where upper(param_name)=''SHOW_FIFO'' ';
    open;
    Result:=(fieldbyname('Param_value').AsString='Y');
  end;
end;

function TfDetail.checkFIFO(MaterailNo:string;VAR NOCHECK:STRING):string;
begin
  with sproc do
  begin
    try
       try
        Close;
        DataRequest('SAJET.SJ_CHECK_FIFO');
        FetchParams;
        Params.ParamByName('MATERIALNO').AsString := MaterailNo;
        Params.ParamByName('EMPID').AsString := UpdateUserID;
        Execute;
        RESULT:=PARAMS.PARAMBYNAME('TRES').AsString;
        NOCHECK:=PARAMS.PARAMBYNAME('NoCheck').AsString;
       except
        RESULT:='SAJET.SJ_CHECK_FIFO ERROR!-CALL DBA';
       end;
    finally
        close;
    end;
  end;
end;


function TfDetail.CheckMaterial: Boolean;
var iQty: Integer; iWmQty, iTemp: Real;
  sPartId, sType, sDateCode, OverRequest, sPartNo, sVersion, sStock, sLocate, sItemID: string;
begin
  Result := True;
  QryTemp.Close;
  QryTemp.Params.Clear;
  QryTemp.Params.CreateParam(ftString, 'material_no', ptInput);
  QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
  QryTemp.CommandText := 'select reel_no, material_no, part_no, b.VERSION, b.' + gsOverField + ', option7, b.part_type '
    + 'from sajet.g_material a, sajet.sys_part b '
    + 'where (reel_no = :reel_no or material_no = :material_no) and rownum = 1 '
    + 'and a.part_id = b.part_id ';
  QryTemp.Params.ParamByName('material_no').AsString := edtMaterial.Text;
  QryTemp.Params.ParamByName('reel_no').AsString := edtMaterial.Text;
  QryTemp.Open;
  if QryTemp.IsEmpty then
  begin
    MessageDlg('ID No: ' + edtMaterial.Text + ' not found.', mtError, [mbOK], 0);
    Result := False;
    Exit;
  end
  else if QryTemp.FieldByName('part_type').AsString <> combType.Text then
  begin
    MessageDlg('ID No: ' + edtMaterial.Text + ' Type (' + QryTemp.FieldByName('part_type').AsString + ')Different.', mtError, [mbOK], 0);
    Result := False;
    Exit;
  end
  else
  begin
    OverRequest := UpperCase(QryTemp.FieldByName(gsOverField).AsString);
    sPartNo := QryTemp.FieldByName('part_no').AsString;
    gslpartno := sPartNo;
    sItemID := QryTemp.FieldByName('option7').AsString;
    sVersion := QryTemp.FieldByName('version').AsString;
    if QryTemp.FieldByName('material_no').AsString = edtMaterial.Text then
      sType := 'Material'
    else
      sType := 'Reel';
  end;
  QryTemp.Close;
  QryTemp.Params.Clear;
  QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
  QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
  QryTemp.CommandText := 'select reel_no, reel_qty, material_no, material_qty, status, '
    + 'a.part_id, a.datecode, d.warehouse_name, e.locate_name '
    + 'from sajet.g_material a, sajet.g_wo_pick_list c, sajet.sys_warehouse d, sajet.sys_locate e '
    + 'where ' + sType + '_No = :reel_no '
    + 'and a.locate_id = e.locate_id(+) and a.warehouse_id = d.warehouse_id(+) '
    + 'and a.part_id = c.part_id and c.work_order = :work_order';
  QryTemp.Params.ParamByName('reel_no').AsString := edtMaterial.Text;
  QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
  QryTemp.Open;
  if QryTemp.IsEmpty then
  begin
    MessageDlg('Cann''t use this Part - ' + sPartNo + '.', mtError, [mbOK], 0);
    Result := False;
    Exit;
  end;
  if QryTemp.FieldByName('warehouse_name').AsString = '' then
  begin
    MessageDlg('ID No: ' + edtMaterial.Text + ' not InStock.', mtError, [mbOK], 0);
    Result := False;
    Exit;
  end;
  if (sType = 'Material') and (QryTemp.FieldByName('reel_qty').AsInteger <> 0) then
  begin
    iQty := 0;
    while not QryTemp.Eof do
    begin
      iQty := iQty + QryTemp.FieldByName('reel_qty').AsInteger;
      QryTemp.Next;
    end;
    QryTemp.First;
    sType := 'Material1';
  end
  else if QryTemp.FieldByName('reel_qty').AsInteger <> 0 then
    iQty := QryTemp.FieldByName('reel_qty').AsInteger
  else
    iQty := QryTemp.FieldByName('material_qty').AsInteger;
  sDateCode := QryTemp.FieldByName('DateCode').AsString;
  sStock := QryTemp.FieldByName('warehouse_name').AsString;
  sLocate := QryTemp.FieldByName('locate_name').AsString;
  if QryTemp.FieldByName('Status').AsString <> '1' then
  begin
    MessageDlg('ID No: ' + edtMaterial.Text + ' not InStock.', mtError, [mbOK], 0);
    Result := False;
  end
  else
  begin
    sPartId := QryTemp.FieldByName('part_id').AsString;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.Params.CreateParam(ftString, 'part_type', ptInput);
    QryTemp.CommandText := 'select max(sequence) seq, sum(pick_qty) qty from sajet.g_wo_pick_info a '
      + 'where work_order = :work_order and sequence like :part_type and work_flag <> ''N''';
    QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
    QryTemp.Params.ParamByName('part_type').AsString := combType.Text + '%';
    QryTemp.Open;
    if QryTemp.FieldByName('seq').AsString = '' then
    begin
      giPick := 0;
      giSequence := combType.Text + '_0001';
    end
    else
    begin
      giPick := QryTemp.FieldByName('qty').AsInteger;
      giSequence := combType.Text + '_' + FormatFloat('0000', StrToInt(Copy(QryTemp.FieldByName('seq').AsString, Length(combType.Text) + 2, Length(QryTemp.FieldByName('seq').AsString))) + 1);
    end;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.CommandText := 'select issue_qty, request_qty from sajet.g_wo_pick_list a '
      + 'where part_id = :part_id and work_order = :work_order ';
    QryTemp.Params.ParamByName('part_id').AsString := sPartId;
    QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
    QryTemp.Open;
    // 單位用量
    iWmQty := QryTemp.FieldByName('request_qty').AsInteger / StrToInt(lablQty.Caption);
    if OverRequest = 'NO' then
    begin
      if sedtQty.Text = lablQty.Caption then
      begin
        if QryTemp.FieldByName('request_qty').AsInteger < QryTemp.FieldByName('issue_qty').AsInteger + iQty then
        begin
          MessageDlg('Part: ' + sPartNo + ' - Over Request. ' + #13#13
            + 'Issue: ' + QryTemp.FieldByName('issue_qty').AsString + ' + ' + IntToStr(iQty) + ', Request: ' + QryTemp.FieldByName('request_qty').AsString, mtError, [mbOK], 0);
          Result := False;
          Exit;
        end;
      end
      else
      begin
        iTemp := (giPick + sedtQty.Value) * iWmQty;
        iWmQty := StrToInt(FloatToStrF(iTemp, ffFixed, 25, 0));
        if iTemp <> iWmQty then
          iWmQty := iWmQty + 1;
        if QryTemp.FieldByName('issue_qty').AsInteger + iQty > iWmQty then
        begin
          MessageDlg('Part: ' + sPartNo + ' - Over Request. ' + #13#13
            + 'Issue: ' + QryTemp.FieldByName('issue_qty').AsString + ' + ' + IntToStr(iQty) + ', Request: ' + FloatToStr(iWmQty), mtError, [mbOK], 0);
          Result := False;
          Exit;
        end
        else if QryTemp.FieldByName('request_qty').AsInteger < QryTemp.FieldByName('issue_qty').AsInteger + iQty then
        begin
          MessageDlg('Part: ' + sPartNo + ' - Over Request. ' + #13#13
            + 'Issue: ' + QryTemp.FieldByName('issue_qty').AsString + ' + ' + IntToStr(iQty) + ', Request: ' + QryTemp.FieldByName('request_qty').AsString, mtError, [mbOK], 0);
          Result := False;
          Exit;
        end;
      end;
      iWmQty := 0;
    end
    else if OverRequest = 'TPS-NO' then
    begin
      iWmQty := QryTemp.FieldByName('issue_qty').AsInteger + iQty - QryTemp.FieldByName('request_qty').AsInteger;
      if iWmQty > 0 then
      begin
        MessageDlg('Part: ' + sPartNo + ' - Over Request Qty.', mtError, [mbOK], 0);
        Result := False;
        Exit;
      end;
      iWmQty := 0;
    end
    else
    begin
      iWmQty := QryTemp.FieldByName('issue_qty').AsInteger + iQty - QryTemp.FieldByName('request_qty').AsInteger;
    end;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.Params.CreateParam(ftString, 'update_userid', ptInput);
    QryTemp.Params.CreateParam(ftInteger, 'sequence', ptInput);
    QryTemp.Params.CreateParam(ftString, 'material_no', ptInput);
    QryTemp.CommandText := 'insert into sajet.g_pick_list '
      + '(work_order, update_userid, material_no, part_id, qty, datecode, sequence, MFGER_NAME, MFGER_PART_NO, version) ';
    if sType = 'Material' then
      QryTemp.CommandText := QryTemp.CommandText
        + 'select :work_order, :update_userid, material_no, part_id, material_qty, datecode, :sequence, MFGER_NAME, MFGER_PART_NO, version '
    else
      QryTemp.CommandText := QryTemp.CommandText
        + 'select :work_order, :update_userid, reel_no, part_id, reel_qty, datecode, :sequence, MFGER_NAME, MFGER_PART_NO, version ';
    QryTemp.CommandText := QryTemp.CommandText + 'from sajet.g_material ';
    if (sType = 'Material') or (sType = 'Material1') then
      QryTemp.CommandText := QryTemp.CommandText + 'where material_no = :material_no'
    else
      QryTemp.CommandText := QryTemp.CommandText + 'where reel_no = :material_no ';
    QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
    QryTemp.Params.ParamByName('update_userid').AsString := UpdateUserid;
    QryTemp.Params.ParamByName('sequence').AsString := giSequence;
    QryTemp.Params.ParamByName('material_no').AsString := edtMaterial.Text;
    QryTemp.Execute;
    QryTemp.Close;
    with sproc do
    begin
      try
        Close;
        DataRequest('SAJET.MES_ERP_WIP_ISSUE');
        FetchParams;
        Params.ParamByName('TWO').AsString := edtWo.Text;
        Params.ParamByName('TPART').AsString := combType.Text;
        Params.ParamByName('TITEMID').AsString := sItemID;
        Params.ParamByName('TREV').AsString := sVersion;
        Params.ParamByName('TQTY').AsInteger := iQty;
        Params.ParamByName('TSUBINV').AsString := sStock;
        Params.ParamByName('TLOCATOR').AsString := sLocate;
        Params.ParamByName('TSEQ').AsString := giSequence;
        Params.ParamByName('TSTATUS').AsString := 'N';
        Params.ParamByName('TPUSH').AsString := 'N';
        Params.ParamByName('TEMPID').AsString := UpdateUserID;
        Execute;
      finally
        close;
      end;
    end;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftInteger, 'ISSUE_QTY', ptInput);
    QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.CommandText := 'update sajet.g_wo_pick_list '
      + 'set ISSUE_QTY = ISSUE_QTY + :ISSUE_QTY '
      + 'where part_id = :part_id and work_order = :work_order ';
    QryTemp.Params.ParamByName('ISSUE_QTY').AsInteger := iQty;
    QryTemp.Params.ParamByName('part_id').AsString := sPartID;
    QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
    QryTemp.Execute;
    QryTemp.Close;
    if iWmQty > 0 then
      UpdateWM(sPartID, gsGroupWo, iWmQty);
    if (sedtQty.Enabled) or ((sedtQty.Value = 0) and (QryMaterial.IsEmpty)) then
    begin
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
      QryTemp.Params.CreateParam(ftString, 'pick_qty', ptInput);
      QryTemp.Params.CreateParam(ftString, 'sequence', ptInput);
      QryTemp.CommandText := 'insert into sajet.g_wo_pick_info '
        + '(work_order, pick_qty, sequence) '
        + 'values (:work_order, :pick_qty, :sequence)';
      QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
      QryTemp.Params.ParamByName('pick_qty').AsString := sedtQty.Text;
      QryTemp.Params.ParamByName('sequence').AsString := giSequence;
      QryTemp.Execute;
      sedtQty.Enabled := False;
      sbtnCheck.Enabled := True;
    end;
    Qrytemp.Close;
    qrytemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
    QryTemp.Params.CreateParam(ftString, 'userid', ptInput);
    if sType = 'Reel' then
      Qrytemp.CommandText:=' update sajet.g_material '
                          +' set type=''O''  '
                          +'    ,update_userid= :userid '
                          +'    ,update_time=sysDate '
                          +' where reel_no=:reel_no '
    else
      Qrytemp.CommandText:=' update sajet.g_material '
                          +' set type=''O''  '
                          +'    ,update_userid= :userid '
                          +'    ,update_time=sysdate '
                          +' where material_no=:reel_no ';
    QryTemp.Params.ParamByName('reel_no').AsString := edtMaterial.Text;
    QryTemp.Params.ParamByName('userid').AsString := UpdateUserid;
    QryTemp.Execute;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
    if sType = 'Reel' then
      QryTemp.CommandText := 'insert into sajet.g_ht_material '
        + 'select * from sajet.g_material where reel_no = :reel_no  '
    else
      QryTemp.CommandText := 'insert into sajet.g_ht_material '
        + 'select * from sajet.g_material where material_no = :reel_no  ';
    QryTemp.Params.ParamByName('reel_no').AsString := edtMaterial.Text;
    QryTemp.Execute;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
    if sType = 'Reel' then
      QryTemp.CommandText := 'delete from sajet.g_material '
        + 'where reel_no = :reel_no '
    else
      QryTemp.CommandText := 'delete from sajet.g_material '
        + 'where material_no = :reel_no ';
    QryTemp.Params.ParamByName('reel_no').AsString := edtMaterial.Text;
    QryTemp.Execute;
    QryTemp.Close;
    PartQty := iQty;
  end;
end;

procedure TfDetail.UpdateWM(sPartID, gsGroupWo: string; iWMQty: Real);
begin
  QryTemp.Close;
  QryTemp.Params.Clear;
  QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
  QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
  QryTemp.CommandText := 'select rowid from sajet.g_material_wm '
    + 'where part_id = :part_id and work_order = :work_order';
  QryTemp.Params.ParamByName('part_id').AsString := sPartID;
  QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
  QryTemp.Open;
  if QryTemp.IsEmpty then
  begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.Params.CreateParam(ftInteger, 'qty', ptInput);
    QryTemp.Params.CreateParam(ftString, 'update_userid', ptInput);
    QryTemp.Params.CreateParam(ftString, 'group_wo', ptInput);
    QryTemp.CommandText := 'insert into sajet.g_material_wm ';
    QryTemp.CommandText := QryTemp.CommandText + '(work_order, part_id, qty, update_userid, group_wo) '
      + 'values(:work_order, :part_id, :qty, :update_userid, :group_wo)';
    QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
    QryTemp.Params.ParamByName('part_id').AsString := sPartId;
    QryTemp.Params.ParamByName('qty').AsFloat := iWMQty;
    QryTemp.Params.ParamByName('update_userid').AsString := UpdateUserid;
    if gsGroupWo = '' then
      QryTemp.Params.ParamByName('group_wo').AsString := 'N/A'
    else
      QryTemp.Params.ParamByName('group_wo').AsString := gsGroupWo;
  end
  else
  begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftInteger, 'qty', ptInput);
    QryTemp.Params.CreateParam(ftString, 'update_userid', ptInput);
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.CommandText := 'update sajet.g_material_wm '
      + 'set qty = :qty, update_userid = :update_userid, update_time = sysdate '
      + 'where part_id = :part_id and work_order = :work_order ';
    QryTemp.Params.ParamByName('qty').AsFloat := iWMQty;
    QryTemp.Params.ParamByName('update_userid').AsString := UpdateUserid;
    QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
    QryTemp.Params.ParamByName('part_id').AsString := sPartId;
  end;
  QryTemp.Execute;
  QryTemp.Close;
end;

function TfDetail.CheckPickList(ShowFlag: Boolean): Boolean;
var i, partnopos: Integer; sTemp, sType: string;
begin
  Result := True;
  sTemp := combType.Text;
  partnopos := -1;
  LvList.Items.Clear;
  if ShowFlag then
    combType.Items.Clear;
  with QryDetail do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    if (sTemp <> 'ALL') and (sTemp <> '') then
      Params.CreateParam(ftString, 'part_type', ptInput);
    if gsParam <> 'Confirm' then  
      CommandText := 'Select a.*, b.part_no, b.part_TYPE, b.' + gsOverField + ', c.qty, warehouse_name, locate_name '
        + ' From SAJET.G_Wo_Pick_List a, sajet.sys_part b, sajet.v_warehouse_wk c, sajet.sys_locate d, sajet.sys_warehouse e '
        + ' Where work_order = :work_order and a.part_id = b.part_id and a.part_id = c.part_id(+) '
        + ' and b.' + gsLocateField + ' = d.locate_id(+) and d.warehouse_id = e.warehouse_id(+) '
    else
      CommandText := 'Select Ab_Issue_Qty, Ab_Return_Qty, request_qty, sum(qty) issue_qty, b.part_no, b.part_TYPE, b.' + gsOverField + ', warehouse_name, locate_name '
        + ' From sajet.g_wo_pick_list c, SAJET.G_Pick_List a, sajet.sys_part b, sajet.sys_locate d, sajet.sys_warehouse e '
        + ' Where c.work_order = :work_order and c.work_order = a.work_order '
        + ' and c.part_id = b.part_id and c.part_id = a.part_id '
        + ' and a.sequence = ''' + giSequence + ''' '
        + ' and b.' + gsLocateField + ' = d.locate_id(+) and d.warehouse_id = e.warehouse_id(+) ';
    if (sTemp <> 'ALL') and (sTemp <> '') then
      CommandText := CommandText + 'and b.part_type = :part_type ';
    case combDisplay.ItemIndex of
      1: CommandText := CommandText + 'and request_qty > issue_qty ';
      2: CommandText := CommandText + 'and request_qty <= issue_qty ';
    end;
    if gsParam = 'Confirm' then
      CommandText := CommandText + 'group by Ab_Issue_Qty, Ab_Return_Qty, request_qty, b.part_no, b.part_type, b.' + gsOverField + ', warehouse_name, locate_name ';
    CommandText := CommandText + 'order by part_no ';
    Params.ParamByName('work_order').AsString := edtWo.Text;
    if (sTemp <> 'ALL') and (sTemp <> '') then
      Params.ParamByName('part_type').AsString := sTemp;
    Open;
    if IsEmpty then
    begin
      if ShowFlag then
        MessageDlg('Pick List not Found.', mtWarning, [mbOK], 0);
      Result := False;
    end
    else
    begin
      i := 0;
      if (ShowFlag) and (gsParam <> 'Confirm') then
        combType.Items.Add('ALL');
      while not Eof do
      begin
        with LvList.Items.Add do
        begin
          Caption := Fieldbyname('Part_No').AsString;
          if Caption = gslpartno then
            partnopos := i;
          Subitems.Add('');
          Subitems.Add(Fieldbyname('Request_Qty').AsString);
          Subitems.Add(Fieldbyname('Issue_Qty').AsString);
          Subitems.Add(IntToStr(Fieldbyname('Request_Qty').AsInteger - Fieldbyname('Issue_Qty').AsInteger));
          Subitems.Add('0');
          if gsParam <> 'Confirm' then
            Subitems.Add(Fieldbyname('qty').AsString)
          else
            Subitems.Add('');
          Subitems.Add(Fieldbyname('Ab_Issue_Qty').AsString);
          Subitems.Add(Fieldbyname('Ab_Return_Qty').AsString);
          Subitems.Add(Fieldbyname('Warehouse_Name').AsString + '-' + Fieldbyname('Locate_Name').AsString);
          if Fieldbyname(gsOverField).AsString = 'YES' then
            sType := 'PY'
          else if Fieldbyname(gsOverField).AsString = 'NO' then
            sType := 'PN'
          else if Fieldbyname(gsOverField).AsString = 'TPS-YES' then
            sType := 'TY'
          else if Fieldbyname(gsOverField).AsString = 'TPS-NO' then
            sType := 'TN'
          else
            sType := 'NO';
          Subitems.Add(sType);
          if gsParam <> 'Confirm' then
            if Fieldbyname('Request_Qty').AsInteger <= Fieldbyname('Issue_Qty').AsInteger then
              LvList.Items.Item[i].ImageIndex := 0
            else
              LvList.Items.Item[i].ImageIndex := -1;
          Inc(i);
        end;
        if ShowFlag then
          if FieldByName('Part_Type').AsString <> '' then
            if combType.Items.IndexOf(FieldByName('Part_Type').AsString) = -1 then
              combType.Items.Add(FieldByName('Part_Type').AsString);
        Next;
      end;
      combType.ItemIndex := combType.Items.IndexOf(sTemp);
      if combType.ItemIndex = -1 then
        combType.ItemIndex := 0;
      if (gslpartno <> '') and (partnopos <> -1) then
      begin
        LvList.Scroll(1, partnopos * 15);
      end;
    end;
  end;
end;

procedure TfDetail.ShowMaterial(bRefresh: Boolean);
var i: Integer;
begin
  with QryMaterial do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    Params.CreateParam(ftString, 'part_type', ptInput);
    Params.CreateParam(ftString, 'sequence', ptInput);
    CommandText := 'Select part_no, material_no, qty '
      + 'from SAJET.G_Pick_List a, sajet.sys_part b '
      + 'Where work_order = :work_order and a.part_id = b.part_id '
      + 'and group_wo is null and b.part_type = :part_type '
      + 'and sequence = :sequence order by part_no, material_no ';
    Params.ParamByName('work_order').AsString := edtWo.Text;
    Params.ParamByName('part_type').AsString := combType.Text;
    Params.ParamByName('sequence').AsString := giSequence;
    Open;
    sbtnCheck.Enabled := not QryMaterial.IsEmpty;
    Label6.Caption := 'Pick- ' + IntToStr(QryMaterial.RecordCount) + ' (ID No)';
    if bRefresh then begin
      while not Eof do
      begin
        for i := 0 to LvList.Items.Count - 1 do
        begin
          if FieldByName('part_no').AsString = LvList.Items.Item[i].Caption then
          begin
            LvList.Items.Item[i].SubItems.Strings[4] := IntToStr(StrToInt(LvList.Items.Item[i].SubItems.Strings[4]) + FieldByName('Qty').AsInteger);
            LvList.Items.Item[i].SubItems.Strings[2] := IntToStr(StrToInt(LvList.Items.Item[i].SubItems.Strings[2]) - FieldByName('Qty').AsInteger);
            LvList.Items.Item[i].SubItems.Strings[3] := IntToStr(StrToInt(LvList.Items.Item[i].SubItems.Strings[1]) - StrToInt(LvList.Items.Item[i].SubItems.Strings[2]));
            break;
          end;
        end;
        Next;
      end;
      First;
    end;
  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var i: Integer;
begin
{  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;}
  LvList.Column[0].Width := LvList.Width - 20;
  for i := 1 to LvList.Columns.Count - 1 do
    LvList.Column[0].Width := LvList.Column[0].Width - LvList.Column[i].Width;
  sbtnConfirm.Visible := (gsParam = 'Confirm');
//  LabTitle1.Caption := 'Provide - ' + gsParam;
//  LabTitle2.Caption := LabTitle1.Caption;
  if sbtnConfirm.Visible then
  begin
    gsFlag := 'Y';
    lablPush.Visible := True;
    chkPush.Visible := True;
    combDisplay.Enabled := False;
    LvList.SmallImages := nil;
  end
  else
  begin
    gsFlag := 'N';
    sbtnWoformWM.Visible := True;
  end;
  sbtnCheck.Visible := not sbtnConfirm.Visible;
  edtMaterial.Visible := sbtnCheck.Visible;
  edtMaterial.Visible := sbtnCheck.Visible;
  Label8.Visible := sbtnCheck.Visible;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
    if gsParam <> '' then
      CommandText := CommandText + ' and fun_param = ''' + gsParam + ''' ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'MATERIALPICKDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Over Request'' ';
    Open;
    gsOverField := FieldByName('param_name').AsString;
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Locate'' ';
    Open;
    gsLocateField := FieldByName('param_name').AsString;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then
    begin
      edtWo.CharCase := ecUpperCase;
      edtMaterial.CharCase := ecUpperCase;
      edtWM.CharCase := ecUpperCase;
    end;
    Close;
  end;
  edtWO.SetFocus;
end;

procedure TfDetail.edtWoKeyPress(Sender: TObject; var Key: Char);
var ShowFlag: Boolean; iIndex: Integer;
begin
  giRow := -1;
  giLocate := 0;
  combType.Items.Clear;
  QryGroup.Close;
  PartQty := 0;
  gslpartno := '';
  LvList.Items.Clear;
  if Ord(Key) = vk_Return then
  begin
    if edtWo.Text <> '' then
      if ShowWo(True) then
        if gsParam <> 'Confirm' then
        begin
          ShowFlag := True;
          if combDisplay.ItemIndex <> 0 then
          begin
            iIndex := combDisplay.ItemIndex;
            combDisplay.ItemIndex := 0;
            CheckPickList(True);
            ShowFlag := False;
            combDisplay.ItemIndex := iIndex;
          end;
          if CheckPickList(ShowFlag) then
          begin
            ShowMaterial(True);
            ShowGroup;
            edtMaterial.Enabled := True;
            combType.SetFocus;
          end;
        end else
        begin
          sbtnConfirm.Enabled := True;
          edtWo.SelectAll;
          edtWo.SetFocus;
       end;
  end;
end;

function TfDetail.ShowWo(bKeyPress: Boolean): Boolean;
var sType: String;
begin
  Result := False;
  if bKeyPress then
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'work_order', ptInput);
      CommandText := 'Select target_qty, default_pdline_id, pdline_name, wo_status ' +
        'from SAJET.G_wo_base a, sajet.sys_pdline b ' +
        'Where work_order = :work_order and a.default_pdline_id = b.pdline_id ';
      Params.ParamByName('work_order').AsString := edtWo.Text;
      Open;
    end;
    if QryTemp.IsEmpty then
    begin
      MessageDlg('Work Order not found.', mtError, [mbOK], 0);
      edtWo.SelectAll;
      edtWo.SetFocus;
      Exit;
    end
    else if QryTemp.FieldByName('wo_status').AsString = '9' then
    begin
      MessageDlg('Work Order: ' + edtWo.Text + ' is complete no charge, cann''t use this function.', mtError, [mbOK], 0);
      edtWo.SelectAll;
      edtWo.SetFocus;
      Exit;
    end
    else
    begin
      lablQty.Caption := QryTemp.FieldByName('target_qty').AsString;
      lablPdline.Caption := QryTemp.FieldByName('pdline_name').AsString;
      gsPdlineId := QryTemp.FieldByName('default_pdline_id').AsString;
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
      QryTemp.CommandText := 'select from_wo from sajet.g_wo_group '
        + 'where from_wo = :work_order and rownum = 1';
      QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
      QryTemp.Open;
      if not QryTemp.IsEmpty then
      begin
        MessageDlg('Work Order: ' + edtWo.Text + ' have been Group, cann''t use this function.', mtError, [mbOK], 0);
        edtWo.SelectAll;
        edtWo.SetFocus;
        Exit;
      end;
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
      QryTemp.Params.CreateParam(ftString, 'part_type', ptInput);
      QryTemp.CommandText := 'select * from sajet.g_wo_pick_info '
        + 'where work_order = :work_order '
        + 'and sequence like :part_type '
        + 'and work_flag = ''' + gsFlag + ''' and rownum = 1';
      QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
      if combType.Text = '' then
        QryTemp.Params.ParamByName('part_type').AsString := 'ALL%'
      else
        QryTemp.Params.ParamByName('part_type').AsString := combType.Text + '%';
      QryTemp.Open;
      if gsParam <> 'Confirm' then
      begin
        if (combType.Text = 'ALL') or (combType.Text = '') then
        begin
          sedtQty.Enabled := False;
          sedtQty.Text := lablQty.Caption;
        end else begin
          sedtQty.MinValue := 0;
          sedtQty.Enabled := True;
          if not QryTemp.IsEmpty then
          begin
            giSequence := QryTemp.FieldByName('sequence').AsString;
            sedtQty.MaxValue := QryTemp.FieldByName('pick_qty').AsInteger;
            sedtQty.Value := sedtQty.MaxValue;
            sedtQty.Enabled := False;
          end;
          QryTemp.Close;
          QryTemp.Params.Clear;
          QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
          QryTemp.Params.CreateParam(ftString, 'part_type', ptInput);
          QryTemp.CommandText := 'select max(sequence) sequence, sum(pick_qty) pick_qty from sajet.g_wo_pick_info '
            + 'where work_order = :work_order and sequence like :part_type and work_flag <> ''N''';
          QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
          QryTemp.Params.ParamByName('part_type').AsString := combType.Text + '%';
          QryTemp.Open;
          if sedtQty.Enabled then
          begin
            if QryTemp.IsEmpty then
              sedtQty.MaxValue := StrToInt(lablQty.Caption)
            else
              sedtQty.MaxValue := StrToInt(lablQty.Caption) - QryTemp.FieldByName('pick_qty').AsInteger;
            sedtQty.Value := sedtQty.MaxValue;
            if QryTemp.FieldByName('sequence').AsString = '' then
              giSequence := ''
            else
              giSequence := combType.Text + '_' + FormatFloat('0000', StrToInt(Copy(QryTemp.FieldByName('sequence').AsString, Length(combType.Text) + 2, Length(QryTemp.FieldByName('sequence').AsString))) + 1);
//            giSequence := QryTemp.FieldByName('sequence').AsString;
            sedtQty.Enabled := not (sedtQty.Value = 0);
          end;
          giPick := QryTemp.FieldByName('pick_qty').AsInteger;
          if sedtQty.Value = 0 then
            sedtQty.Enabled := False;
        end;    
      end
      else
      begin
        sbtnConfirm.Enabled := True;
        sedtQty.Enabled := False;
        giSequence := QryTemp.FieldByName('sequence').AsString;
        sedtQty.Value := QryTemp.FieldByName('pick_qty').AsInteger;
        if (QryTemp.IsEmpty) and (bKeyPress) then
        begin
          QryTemp.Close;
          QryTemp.Params.Clear;
          QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
          QryTemp.CommandText := 'select sequence from sajet.g_wo_pick_info '
            + 'where work_order = :work_order and work_flag = ''Y'' group by sequence';
          QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
          QryTemp.Open;
          if not QryTemp.IsEmpty then
          begin
            while not QryTemp.Eof do
            begin
              sType := Copy(QryTemp.FieldByName('sequence').AsString, 1, Pos('_', QryTemp.FieldByName('sequence').AsString) - 1);
              if sType <> '' then
                if combType.Items.IndexOf(sType) = -1 then
                  combType.Items.Add(sType);
              QryTemp.Next;
            end;
            QryTemp.Close;
//            MessageDlg('Warehouse must check List.', mtError, [mbOK], 0)
          end
          else
          begin
            QryTemp.Close;
            QryTemp.Params.Clear;
            QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
            QryTemp.CommandText := 'select work_flag from sajet.g_wo_pick_info '
              + 'where work_order = :work_order group by work_flag';
            QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
            QryTemp.Open;
            if QryTemp.IsEmpty then
              MessageDlg('Work Order: ' + edtWo.Text + ' Never Pick.', mtError, [mbOK], 0)
            else if (QryTemp.RecordCount = 2) or (QryTemp.FieldByName('work_flag').AsString = 'N') then
              MessageDlg('Warehouse must check List.', mtError, [mbOK], 0)
            else  
              MessageDlg('Work Order: ' + edtWo.Text + ' all Confirmed.', mtError, [mbOK], 0);
            edtWo.SelectAll;
            edtWo.SetFocus;
            sbtnConfirm.Enabled := False;
            Exit;
          end;
        end;
      end;
      QryTemp.Close;
    end;
  end;
  Result := True;
end;

procedure TfDetail.ShowGroup;
begin
  gbGroup := True;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    Params.CreateParam(ftString, 'group_wo', ptInput);
    CommandText := 'select work_order from sajet.g_wo_group a '
      + 'where work_order = :work_order or group_wo = :group_wo ';
    Params.ParamByName('work_order').AsString := edtWo.Text;
    Params.ParamByName('group_wo').AsString := edtWo.Text;
    Open;
    sbtnWM.Visible := True;
    sbtnWM.Enabled := True;
    if not IsEmpty then
    begin
      QryGroup.Close;
      QryGroup.Params.Clear;
      QryGroup.Params.CreateParam(ftString, 'work_order', ptInput);
      if combType.Text <> 'ALL' then
        QryGroup.Params.CreateParam(ftString, 'part_type', ptInput);
      QryGroup.CommandText := 'select group_wo, part_no, qty, a.part_id '
        + 'from sajet.g_pick_list a, sajet.sys_part b '
        + 'where work_order = :work_order and group_wo is not null '
        + 'and a.part_id = b.part_id ';
      if combType.Text <> 'ALL' then
        QryGroup.CommandText := QryGroup.CommandText + 'and b.part_type = :part_type ';
      QryGroup.Params.ParamByName('work_order').AsString := edtWo.Text;
      if combType.Text <> 'ALL' then
        QryGroup.Params.ParamByName('part_type').AsString := combType.Text;
      QryGroup.Open;
      sbtnWM.Visible := False;
    end;
    sbtnDelete.Visible := not sbtnWM.Visible;
    sbtnWM.Enabled := sbtnWM.Visible;
  end;
end;

procedure TfDetail.edtMaterialKeyPress(Sender: TObject; var Key: Char);
var sStr,sNoCheck:string;
begin
  PartQty := 0;
  if Ord(Key) = vk_Return then
  begin
    if combType.Text = 'ALL' then
    begin
      MessageDlg('Please Select Type!', mtError, [mbOK], 0);
      combType.SetFocus;
      Exit;
    end;
    
    sStr:= checkFIFO(TRIM(edtMaterial.Text),sNoCheck);
    if sStr  <>'OK' then
    begin
      MessageDlg(sStr, mtError, [mbOK], 0);
      exit;
    end;
    if (sNoCheck='NG') and SendMsg then
    begin
      MessageDlg('Not Check FIFO!', mtError, [mbOK], 0);
    end;

    if CheckMaterial then
    begin
      ShowWOPickList;
      ShowMaterial(False);
    end;
    edtMaterial.SelectAll;
    edtMaterial.SetFocus;
  end;
end;

procedure TfDetail.StringGrid1SelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  giRow := ARow;
end;

procedure TfDetail.ClearData;
begin
  LvList.Items.Clear;
  giRow := -1;
  giLocate := 0;
  PartQty := 0;
  gslpartno := '';
  edtMaterial.Text := '';
  edtMaterial.Enabled := False;
  edtWo.Text := '';
  edtWo.Enabled := True;
  edtWo.SetFocus;
end;

procedure TfDetail.LvListCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var iQty: Real;
begin
  if gsParam <> 'Confirm' then
  begin
    if sedtQty.Enabled then
      iQty := 0
    else
      iQty := sedtQty.Value;
    iQty := StrtoIntDef(Item.SubItems.Strings[1], 0) * (giPick + iQty) / StrToIntDef(lablQty.Caption, 1);
    if Item.caption = gslpartno then
      LvList.Canvas.brush.Color := clAqua
    else if (Item.SubItems.Strings[9] = 'PN') then
    begin
      if iQty > StrToIntDef(Item.SubItems.Strings[2], 0) then
        LvList.Canvas.brush.Color := clFuchsia
      else if Item.SubItems.Strings[1] <> Item.SubItems.Strings[2] then
        LvList.Canvas.brush.Color := clYellow
    end
    else if iQty > StrToIntDef(Item.SubItems.Strings[2], 0) + StrtoIntDef(Item.SubItems.Strings[4], 0) then
      LvList.Canvas.brush.Color := clred
    else if iQty < StrToIntDef(Item.SubItems.Strings[2], 0) + StrtoIntDef(Item.SubItems.Strings[4], 0) then
      LvList.Canvas.brush.Color := clLime;
  end;
end;

procedure TfDetail.sbtnDeleteClick(Sender: TObject);
var sGroupWo: string;
begin
  if QryGroup.IsEmpty then Exit;
  if MessageDlg('Delete?', mtInformation, [mbYes, mbNo], 0) = mrYes then
  begin
    QryGroup.First;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.CommandText := 'select group_wo from sajet.g_wo_group '
      + 'where work_order = :work_order ';
    QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
    QryTemp.Open;
    sGroupWo := QryTemp.FieldByName('group_wo').AsString;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'qty', ptInput);
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.CommandText := 'update sajet.g_wo_pick_list '
      + 'set issue_qty = issue_qty - :qty '
      + 'where work_order = :work_order and part_id = :part_id and rownum = 1';
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp1.Params.CreateParam(ftString, 'part_id', ptInput);
    QryTemp1.Params.CreateParam(ftString, 'qty', ptInput);
    QryTemp1.Params.CreateParam(ftString, 'update_userid', ptInput);
//    QryTemp1.Params.CreateParam(ftString, 'group_wo', ptInput);
    QryTemp1.CommandText := 'insert into sajet.g_material_wm '
      + '(work_order, part_id, qty, update_userid) '
      + 'values(:work_order, :part_id, :qty, :update_userid)';
    while not QryGroup.Eof do
    begin
      QryTemp.Close;
      QryTemp.Params.ParamByName('qty').AsString := QryGroup.FieldByName('qty').AsString;
      QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
      QryTemp.Params.ParamByName('part_id').AsString := QryGroup.FieldByName('part_id').AsString;
      QryTemp.Execute;
      QryTemp.Close;
      QryTemp1.Close;
      QryTemp1.Params.ParamByName('work_order').AsString := QryGroup.FieldByName('group_wo').AsString;
      QryTemp1.Params.ParamByName('part_id').AsString := QryGroup.FieldByName('part_id').AsString;
      QryTemp1.Params.ParamByName('qty').AsString := QryGroup.FieldByName('qty').AsString;
      QryTemp1.Params.ParamByName('update_userid').AsString := UpdateUserid;
//      QryTemp1.Params.ParamByName('group_wo').AsString := sGroupWo;
      QryTemp1.Execute;
      QryTemp1.Close;
      QryGroup.Next;
    end;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.Params.CreateParam(ftString, 'group_wo', ptInput);
    QryTemp.CommandText := 'delete from sajet.g_material_wm '
      + 'where work_order = :work_order and group_wo = :group_wo';
    QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
    QryTemp.Params.ParamByName('group_wo').AsString := sGroupWo;
    QryTemp.Execute;
    // Push Title
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.CommandText := 'insert into sajet.mes_to_erp_wip_issue_return '
      + '(work_order, item_no, revision, qty, transaction_type, status) '
      + 'select work_order, item_no, revision, qty, ''D2'', ''Y'' '
      + 'from sajet.mes_to_erp_wip_issue_return '
      + 'where work_order = :work_order and sequence is null ';
    QryTemp.Params.ParamByName('work_order').AsString := sGroupWo;
    QryTemp.Execute;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.CommandText := 'insert into sajet.mes_to_erp_wip_issue_return '
      + '(work_order, item_no, revision, qty, transaction_type, status) '
      + 'select work_order, item_no, revision, qty, ''D5'', ''Y'' '
      + 'from sajet.mes_to_erp_wip_issue_return '
      + 'where work_order = :work_order and sequence is null ';
    QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
    QryTemp.Execute;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.CommandText := 'delete from sajet.g_pick_list '
      + 'where work_order = :work_order and group_wo is not null ';
    QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
    QryTemp.Execute;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.CommandText := 'update sajet.g_wo_group '
      + 'set work_order = '''' '
      + 'where work_order = :work_order ';
    QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
    QryTemp.Execute;
    QryTemp.Close;
//    ShowWo(False)
    CheckPickList(False);
    QryGroup.Close;
  end;
end;

procedure TfDetail.sbtnConfirmClick(Sender: TObject);
begin
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.MES_ERP_WIP_ISSUE_RETURN');
      FetchParams;
      Params.ParamByName('TWO').AsString := edtWo.Text;
      Params.ParamByName('TSEQ').AsString := giSequence;
      if chkPush.Checked then
        Params.ParamByName('TPUSH').AsString := 'Y'
      else
        Params.ParamByName('TPUSH').AsString := 'N';
      Params.ParamByName('TEMPID').AsString := UpdateUserid;
      Execute;
      MessageDlg('Work Order: ' + edtWo.Text + #13#13 + 'Sequence: ' + giSequence + #13#13 + 'Confirm OK', mtInformation, [mbOK], 0);
//      ShowWo(False);
      CheckPickList(False);
      sbtnConfirm.Enabled := False;
    finally
      close;
    end;
  end;
end;

procedure TfDetail.combDisplayChange(Sender: TObject);
begin
  PartQty := 0;
  CheckPickList(False);
  ShowMaterial(True);
end;

procedure TfDetail.combTypeChange(Sender: TObject);
begin
  PartQty := 0;
  ShowWo(True);
  CheckPickList(False);
  ShowMaterial(True);
end;

procedure TfDetail.sbtnCheckClick(Sender: TObject);
begin
  if not QryMaterial.Active then Exit;
  if QryMaterial.IsEmpty then Exit;
  if combType.Text = 'ALL' then
  begin
    MessageDlg('Please Select Type!', mtError, [mbOK], 0);
    combType.SetFocus;
    Exit;
  end;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    Params.CreateParam(ftString, 'part_type', ptInput);
    CommandText := 'select work_order, sequence from sajet.g_wo_pick_info '
      + 'where work_order = :work_order and sequence like :part_type and work_flag = ''Y'' ';
    Params.ParamByName('work_order').AsString := edtWo.Text;
    Params.ParamByName('part_type').AsString := combType.Text + '%';
    Open;
    if not IsEmpty then
    begin
      MessageDlg('Work Order: ' + edtWo.Text + #13#13
        + 'Sequence: ' + FieldByName('sequence').AsString + #13#13 + ' UnConfirmed.', mtError, [mbOK], 0);
      Close;
      Exit;
    end;
    Close;
    if CheckRequest then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'work_order', ptInput);
      Params.CreateParam(ftString, 'part_type', ptInput);
      CommandText := 'update sajet.g_wo_pick_info '
        + 'set work_flag = ''Y'' '
        + 'where work_order = :work_order and sequence like :part_type and work_flag = ''N'' ';
      Params.ParamByName('work_order').AsString := edtWo.Text;
      Params.ParamByName('part_type').AsString := combType.Text + '%';
      Execute;
      Close;
      MessageDlg('Work Order: ' + edtWo.Text + #13#13 +
        'Sequence: ' + giSequence + #13#13 + ' Check OK.', mtInformation, [mbOK], 0);
      ShowWo(False);
      CheckPickList(False);
    end;
  end;
end;

function TfDetail.CheckRequest: Boolean;
var iMax, iTemp: Integer; sTemp: string;
begin
  Result := False;
  if edtWo.Text = '' then Exit;
  // No TPS Issue數量要大於等於齊套數
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    Params.CreateParam(ftString, 'part_type', ptInput);
    CommandText := 'select sum(pick_qty) qty from sajet.g_wo_pick_info a '
      + 'where work_order = :work_order and sequence like :part_type ';
    Params.ParamByName('work_order').AsString := edtWo.Text;
    Params.ParamByName('part_type').AsString := combType.Text + '%';
    Open;
    iMax := FieldByName('qty').AsInteger;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    Params.CreateParam(ftString, 'part_type', ptInput);
    Params.CreateParam(ftInteger, 'pick_qty', ptInput);
    Params.CreateParam(ftInteger, 'target_qty', ptInput);
    CommandText := 'select a.part_id, request_qty, issue_qty, part_no '
      + 'from sajet.g_wo_pick_list a, sajet.sys_part b '
      + 'where a.work_order = :work_order '
      + 'and a.part_id = b.part_id '
      + 'and b.part_type = :part_type '
      + 'and ((b.' + gsOverField + '=''YES'') or (b.' + gsOverField + '=''NO''))'
      + 'and issue_qty < request_qty * :pick_qty / :target_qty ';
    Params.ParamByName('work_order').AsString := edtWo.Text;
    Params.ParamByName('part_type').AsString := combType.Text;
    Params.ParamByName('pick_qty').AsInteger := iMax;
    Params.ParamByName('target_qty').AsInteger := StrToInt(lablQty.Caption);
    Open;
    if not IsEmpty then
    begin
      while not Eof do
      begin
        iTemp := LvList.Items.IndexOf(LvList.FindCaption(0, FieldByName('part_no').AsString, True, True, True));
        LvList.Items.Item[iTemp].SubItemImages[0] := 1;
        sTemp := sTemp + FieldByName('part_no').AsString + '(' + FieldByName('request_qty').AsString + '-' + FieldByName('issue_qty').AsString + ')' + #13#10;
        Next;
      end;
      MessageDlg('Part: ' + #13#13 + sTemp + #13#10 + ' Under Request.', mtError, [mbOK], 0)
    end
    else
    begin
      Result := True;
    end;
    Close;
  end;
end;

procedure TfDetail.sbtnWoformWMClick(Sender: TObject);
begin
  with TfCommData.Create(Self) do
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'work_order', ptInput);
      Params.CreateParam(ftString, 'mywork', ptInput);
      Params.CreateParam(ftString, 'pdline_id', ptInput);
      CommandText := 'select distinct a.work_order "Work Order", part_no "Part No", sum(qty) '
        + 'from sajet.g_material_wm a, sajet.sys_part b, sajet.g_wo_base c '
        + 'where a.work_order like :work_order '
        + 'and a.part_id = b.part_id and a.work_order <> :mywork '
        + 'and a.work_order = c.work_order and c.DEFAULT_PDLINE_ID = :pdline_id '
        + 'group by a.work_order, part_no '
        + 'order by a.work_order ';
      Params.ParamByName('work_order').AsString := edtWM.Text + '%';
      Params.ParamByName('mywork').AsString := edtWo.Text;
      Params.ParamByName('pdline_id').AsString := gsPdlineId;
      Open;
    end;
    if Showmodal = mrOK then
    begin
      edtWM.Text := QryTemp.FieldByName('work order').AsString;
      QryTemp.Close;
    end;
    free;
  end;
end;

procedure TfDetail.sbtnWMClick(Sender: TObject);
begin
  if CheckGroup then
  begin
    edtWM.Text := '';
    ShowWo(False);
    CheckPickList(False);
  end;
end;

function TfDetail.CheckGroup: Boolean;
var iMaxWo, i: Integer; sWo: string;
begin
  gbGroup := True;
  Result := True;
  with QryTemp do
  begin
    gbGroup := False;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    CommandText := 'select substr(sequence,0,instr(sequence,''_'',1,1)-1) sequence,sum(pick_qty) pick_qty, target_qty '
      + 'from sajet.g_wo_pick_info a, sajet.g_wo_base b '
      + 'where a.work_order = b.work_order '
      + 'and a.work_order = :work_order group by substr(sequence,0,instr(sequence,''_'',1,1)-1),target_qty';
    Params.ParamByName('work_order').AsString := edtWM.Text;
    Open;
    while not eof do
    begin
      if FieldByName('pick_qty').AsInteger <> FieldByName('target_qty').AsInteger then
      begin
        MessageDlg('Work Order: ' + edtWM.Text + ' not Complete. (Non-TPS)', mtError, [mbOK], 0);
        edtWM.SelectAll;
        edtWM.SetFocus;
        Result := False;
        Exit;
      end;
      next;
    end;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    CommandText := 'select pick_qty '
      + 'from sajet.g_wo_pick_info a '
      + 'where a.work_order = :work_order and work_flag <> ''T'' ';
    Params.ParamByName('work_order').AsString := edtWM.Text;
    Open;
    if not IsEmpty then
    begin
      MessageDlg('Work Order: ' + edtWM.Text + ' not Complete. (Confirm)', mtError, [mbOK], 0);
      edtWM.SelectAll;
      edtWM.SetFocus;
      Result := False;
      Exit;
    end;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'group_wo', ptInput);
    Params.CreateParam(ftString, 'work_order', ptInput);
    CommandText := 'select b.work_order, a.part_id, qty, a.work_order '
      + 'from sajet.g_material_wm a, sajet.g_wo_pick_list b '
      + 'where a.work_order = :group_wo and b.work_order = :work_order '
      + 'and a.part_id = b.part_id and a.group_wo <> ''-1'' ';
    Params.ParamByName('group_wo').AsString := edtWM.Text;
    Params.ParamByName('work_order').AsString := edtWo.Text;
    Open;
    if IsEmpty then
    begin
      MessageDlg('No Part to Mapping!', mtError, [mbOK], 0);
      edtWM.SelectAll;
      edtWM.SetFocus;
      Result := False;
      Close;
      Exit;
    end;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''PICK_MAX_QTY''';
    Open;
    if FieldByName('param_value').AsInteger > StrToIntDef(lablQty.Caption, 0) then
    begin
      Close;
      Params.Clear;
      CommandText := 'select param_value from sajet.sys_base '
        + 'where param_name = ''PICK_MAX_WO''';
      Open;
      iMaxWo := FieldByName('param_value').AsInteger;
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
      QryTemp.Params.CreateParam(ftString, 'group_wo', ptInput);
      QryTemp.CommandText := 'select group_wo, work_order '
        + 'from sajet.g_wo_group '
        + 'where work_order = :work_order or group_wo = :group_wo ';
      QryTemp.Params.ParamByName('work_order').AsString := edtWM.Text;
      QryTemp.Params.ParamByName('group_wo').AsString := edtWM.Text;
      QryTemp.Open;
      if QryTemp.IsEmpty then
      begin
        QryTemp.Close;
        QryTemp.Params.Clear;
        QryTemp.Params.CreateParam(ftString, 'group_wo', ptInput);
        QryTemp.Params.CreateParam(ftString, 'pdline_id', ptInput);
        QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
        QryTemp.CommandText := 'insert into sajet.g_wo_group '
          + '(group_wo, pdline_id, work_order) values (:group_wo, :pdline_id, :work_order) ';
        for i := 1 to iMaxWo do
        begin
          QryTemp.Close;
          QryTemp.Params.ParamByName('group_wo').AsString := edtWM.Text;
          QryTemp.Params.ParamByName('pdline_id').AsString := gsPdlineId;
          if i = 1 then
            QryTemp.Params.ParamByName('work_order').AsString := edtWM.Text
          else
            QryTemp.Params.ParamByName('work_order').AsString := '';
          QryTemp.Execute;
          QryTemp.Close;
        end;
        sWo := edtWo.Text;
        gsGroupWo := edtWM.Text;
      end
      else
      begin
        sWo := QryTemp.FieldByName('work_order').AsString;
        gsGroupWo := QryTemp.FieldByName('group_wo').AsString;
        QryTemp.Close;
        QryTemp.Params.Clear;
        QryTemp.Params.CreateParam(ftString, 'group_wo', ptInput);
        QryTemp.CommandText := 'select work_order from sajet.g_wo_group '
          + 'where group_wo = :group_wo and work_order is null and rownum = 1';
        QryTemp.Params.ParamByName('group_wo').AsString := gsGroupWo;
        QryTemp.Open;
        if QryTemp.IsEmpty then
        begin
          MessageDlg('Over Wo Group', mtError, [mbOK], 0);
          QryTemp.Close;
          Result := False;
          Exit;
        end;
      end;
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
      QryTemp.Params.CreateParam(ftString, 'from_wo', ptInput);
      QryTemp.Params.CreateParam(ftString, 'group_wo', ptInput);
      QryTemp.CommandText := 'update sajet.g_wo_group '
        + 'set work_order = :work_order, from_wo = :from_wo '
        + 'where group_wo = :group_wo and work_order is null and rownum = 1';
      QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
      QryTemp.Params.ParamByName('from_wo').AsString := edtWM.Text;
      QryTemp.Params.ParamByName('group_wo').AsString := gsGroupWo;
      QryTemp.Execute;
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'group_wo', ptInput);
      QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
      {QryTemp.CommandText := 'update sajet.g_wo_pick_list '
        + 'set to_wo = to_wo + nvl((select qty from sajet.g_material_wm b '
        + 'where b.work_order = :group_wo and b.group_wo > ''-1'' and sajet.g_wo_pick_list.part_id = b.part_id and rownum = 1), 0) '
        + 'where work_order = :work_order ';   }
      Qrytemp.CommandText:=' update sajet.g_wo_pick_list a '
                       +' set to_wo = to_wo+nvl((select issue_qty-Request_qty qty from sajet.g_wo_pick_list b '
                       +'                        where b.work_order =:group_wo and a.part_id=b.part_id and rownum=1 ),0) '
                       +' where work_order=:work_order '; 
      QryTemp.Params.ParamByName('group_wo').AsString := edtWM.Text;
      QryTemp.Params.ParamByName('work_order').AsString := edtwm.Text;
      QryTemp.Execute;
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'update_userid', ptInput);
      QryTemp.Params.CreateParam(ftString, 'group_wo', ptInput);
      QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
      QryTemp.CommandText := 'insert into sajet.g_pick_list '
        + '(work_order, part_id, qty, update_userid, group_wo) '
        + 'select b.work_order, a.part_id, qty, :update_userid, a.work_order '
        + 'from sajet.g_material_wm a, sajet.g_wo_pick_list b '
        + 'where a.work_order = :group_wo and b.work_order = :work_order '
        + 'and a.part_id = b.part_id  ';
      QryTemp.Params.ParamByName('group_wo').AsString := edtWM.Text;
      QryTemp.Params.ParamByName('update_userid').AsString := UpdateUserid;
      QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
      QryTemp.Execute;  
      // Push Title
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'group_wo', ptInput);
      QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
      QryTemp.Params.CreateParam(ftString, 'userid', ptInput);
      QryTemp.CommandText := 'insert into sajet.mes_to_erp_wip_issue_return '
        + '(work_order, item_no, revision, qty, transaction_type, status,user_id) '
        + 'select a.work_order, c.option7, c.version, qty, ''D5'', ''Y'',:userid '
        + 'from sajet.g_material_wm a, sajet.g_wo_pick_list b, sajet.sys_part c '
        + 'where a.work_order = :group_wo and b.work_order = :work_order '
        + 'and a.part_id = b.part_id and a.part_id = c.part_id ';
      QryTemp.Params.ParamByName('group_wo').AsString := edtWM.Text;
      QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
      QryTemp.Params.ParamByName('userid').AsString :=UpdateUserID;
      QryTemp.Execute;
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'group_wo', ptInput);
      QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
      QryTemp.Params.CreateParam(ftString, 'userid', ptInput);
      QryTemp.CommandText := 'insert into sajet.mes_to_erp_wip_issue_return '
        + '(work_order, item_no, revision, qty, transaction_type, status,user_id) '
        + 'select b.work_order, c.option7, c.version, qty, ''D2'', ''Y'',:userID '
        + 'from sajet.g_material_wm a, sajet.g_wo_pick_list b, sajet.sys_part c '
        + 'where a.work_order = :group_wo and b.work_order = :work_order '
        + 'and a.part_id = b.part_id and a.part_id = c.part_id ';
      QryTemp.Params.ParamByName('group_wo').AsString := edtWM.Text;
      QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
      QryTemp.Params.ParamByName('userid').AsString :=UpdateUserID;
      QryTemp.Execute;

      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'group_wo', ptInput);
      QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
      QryTemp.CommandText := 'delete from sajet.g_material_wm '
        + 'where work_order = :group_wo  and part_id in '
        + '(select part_id from sajet.g_wo_pick_list where work_order = :work_order) ';
      QryTemp.Params.ParamByName('group_wo').AsString := edtWM.Text;
      QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
      QryTemp.Execute;
      QryTemp.Close;

     { QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'wo', ptInput);
      QryTemp.CommandText:=' select a.work_order,a.part_id,a.request_qty,a.issue_qty,nvl(b.qty,0) qty '
                          +' from sajet.g_wo_pick_list a,sajet.g_material_wm b '
                          +' where a.work_order=b.work_order(+)  '
                          +'       and a.part_id=b.part_id(+)  '
                          +'       and a.work_order= :wo ';
      QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
      QryTemp.Open;
      while not eof do
      begin
         if (QryTemp.fieldbyname(issue_qty).AsInteger>(QryTemp.FieldByName('request_qty').AsInteger+QryTemp.FieldByName('qty').AsInteger)) then
         begin
           if QryTemp.FieldByName('qty').AsInteger=0 then
           begin
              qryWM.Close;
              qryWm.Params.Clear;
              qryWM.CommandText:=' insert into sajet.g_material_wm(work_order,part_id,qty,update_userid)'
           end
           else begin
           end;
         end;
         next;
      end;        }         

      QryGroup.Close;
      QryGroup.Params.Clear;
      QryGroup.Params.CreateParam(ftString, 'work_order', ptInput);
      QryGroup.CommandText := 'select group_wo, part_no, qty, a.part_id from sajet.g_pick_list a, sajet.sys_part b '
        + 'where work_order = :work_order and group_wo is not null and a.part_id = b.part_id ';
      QryGroup.Params.ParamByName('work_order').AsString := edtWo.Text;
      QryGroup.Open;
      while not QryGroup.Eof do
      begin
        QryTemp.Close;
        QryTemp.Params.Clear;
        QryTemp.Params.CreateParam(ftInteger, 'qty', ptInput);
        QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
        QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
        QryTemp.CommandText := 'update sajet.g_wo_pick_list '
          + 'set issue_qty = issue_qty + :qty '
          + 'where work_order = :work_order and part_id = :part_id and rownum = 1';
        QryTemp.Params.ParamByName('qty').AsInteger := QryGroup.FieldByName('qty').AsInteger;
        QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
        QryTemp.Params.ParamByName('part_id').AsString := QryGroup.FieldByName('part_id').AsString;
        QryTemp.Execute;
        QryTemp.Close;
        QryTemp.Params.Clear;
        QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
        QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
        QryTemp.CommandText := 'select request_qty, issue_qty from sajet.g_wo_pick_list '
          + 'where work_order = :work_order and part_id = :part_id and rownum = 1';
        QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
        QryTemp.Params.ParamByName('part_id').AsString := QryGroup.FieldByName('part_id').AsString;
        QryTemp.Open;
        if QryTemp.FieldByName('request_qty').AsInteger < QryTemp.FieldByName('issue_qty').AsInteger then
          UpdateWM(QryGroup.FieldByName('part_id').AsString, gsGroupWo, QryTemp.FieldByName('issue_qty').AsInteger - QryTemp.FieldByName('request_qty').AsInteger);
        QryTemp.Close;
        QryGroup.Next;
      end;
      QryGroup.First;
      CheckPickList(False);
    end;
  end;
end;

function TfDetail.ShowWOPickList: Boolean;
var i: Integer;
begin
  Result := True;
  if gslpartno <> '' then
  begin
    for i := 0 to LvList.Items.Count - 1 do
    begin
      if gslpartno = LvList.Items.Item[i].Caption then
      begin
//        LvList.Items.Item[i].SubItems.Strings[2] := IntToStr(StrToIntDef(LvList.Items.Item[i].SubItems.Strings[2], 0) + PartQty);
        LvList.Items.Item[i].SubItems.Strings[4] := IntToStr(StrToIntDef(LvList.Items.Item[i].SubItems.Strings[4], 0) + PartQty);
        LvList.Items.Item[i].SubItems.Strings[5] := IntToStr(StrToIntDef(LvList.Items.Item[i].SubItems.Strings[5], 0) - PartQty);
        LvList.Scroll(1, i * 15);
        break;
      end;
    end;
  end;
  LvList.Refresh;
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

end.

