unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, RzButton, RzRadChk, ComCtrls, ListView1, ImgList,Variants;

type
  TDBGrid = class(DBGrids.TDBGrid)
   public
      function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
   end;
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
    SProc: TClientDataSet;
    edtWo: TEdit;
    DBGrid2: TDBGrid;
    sbtnRT: TSpeedButton;
    Label12: TLabel;
    edtMaterial: TEdit;
    lablMsg: TLabel;
    chkPush: TRzCheckBox;
    Label2: TLabel;
    combDisplay: TComboBox;
    DBGrid1: TDBGrid;
    lablQty: TLabel;
    Label3: TLabel;
    Label11: TLabel;
    LabPICK: TLabel;
    Label4: TLabel;
    EditORG: TEdit;
    procedure FormShow(Sender: TObject);
    procedure edtWoKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnRTClick(Sender: TObject);
    procedure edtMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure DataSource2DataChange(Sender: TObject; Field: TField);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure DBGrid2TitleClick(Column: TColumn);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsOverField, gsOrgID: string;
    G_FCID,G_FCCODE,G_FCTYPE:string;
    procedure showData(sPart: string);
    function CheckWO(wo:string):boolean;
    function checkFIFO(MaterailNo:string;VAR NOCHECK:STRING):string;
    function SendMsg:boolean;
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


function TfDetail.CheckWO(wo:string):boolean;
begin
  result:=false;
  with qrytemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    commandtext:=' select work_order from sajet.g_wo_group where from_wo=:work_order ';
    Params.ParamByName('work_order').AsString :=wo;
    open;
    if isEmpty then
    begin
       result:=true;
    end;
  end;
end;

procedure TfDetail.ShowData(sPart: string);
var iTarget: Integer;
    C_STATUS,TRES1 : String;
begin
  TRES1:='';
  G_FCID:='';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    CommandText := 'Select target_qty, default_pdline_id, pdline_name,a.wo_status,a.factory_id ' +
      'from SAJET.G_wo_base a, sajet.sys_pdline b ' +
      'Where work_order = :work_order and a.default_pdline_id = b.pdline_id ';
    Params.ParamByName('work_order').AsString := edtWo.Text;
    Open;
    if IsEmpty then
    begin
      MessageDlg('Work Order not found.', mtError, [mbOK], 0);
      edtWo.SelectAll;
      edtWo.SetFocus;
      Exit;
    end;
    iTarget := FieldByName('target_qty').AsInteger;
    lablQty.Caption:=FieldByName('target_qty').AsString;
    C_STATUS:=FieldByName('wo_status').AsString;
    G_FCID:= FieldByName('factory_id').AsString;

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

    if trim(editorg.Text)='' then
    begin
        MessageDlg('ORG IS NULL', mtError, [mbOK], 0);
        Exit;
     end;

    IF C_STATUS = '0' THEN
      TRES1 := 'WO INIT'
    ELSE IF C_STATUS = '5' THEN
      TRES1 := 'WO CANCEL'
//    ELSE IF C_STATUS = '6' THEN
//      TRES1 := 'WO COMPLETE'
    ELSE IF C_STATUS = '9' THEN
      TRES1 := 'WO Complete no charge';
    IF TRES1<>'' THEN
    BEGIN
      MessageDlg(TRES1, mtError, [mbOK], 0);
      edtWo.SelectAll;
      edtWo.SetFocus;
      Exit;
    END;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    CommandText := 'select sum(Pick_qty) Pick_qty from sajet.g_wo_pick_info '
                 + 'where work_order = :work_order ';
    Params.ParamByName('work_order').AsString := edtWo.Text;
    Open;
    LabPICK.Caption:=FieldByName('Pick_qty').AsString;
  end;
  with QryDetail do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    { //¤£¬d¸ß®w¦s¡@2008/06/26
    CommandText := 'Select b.part_id,B.PART_NO,b.MATERIAL_TYPE, Upper(b.' + gsOverField + ')  over_request '
      + ' ,C.REQUEST_QTY,NVL(c.ISSUE_QTY,0) ISSUE_QTY ,NVL(C.AB_ISSUE_QTY,0) AB_ISSUE,nvl(f.qty,0)  '
      + ' From sajet.g_WO_pick_list c, sajet.sys_part b,sajet.v_warehouse_wk f '
      + ' Where c.work_order = :work_order and c.part_id = b.part_id '
      + '   and f.part_id(+) = c.part_id '
      + 'order by part_no ';
      }
     CommandText := 'Select b.part_id,B.PART_NO,b.MATERIAL_TYPE, Upper(b.' + gsOverField + ')  over_request '
      + ' ,C.REQUEST_QTY,NVL(c.ISSUE_QTY,0) ISSUE_QTY ,NVL(C.AB_ISSUE_QTY,0) AB_ISSUE,''0'' AS QTY  '
      + ' From sajet.g_WO_pick_list c, sajet.sys_part b '
      + ' Where c.work_order = :work_order and c.part_id = b.part_id '
      + 'order by part_no ';
    Params.ParamByName('work_order').AsString := edtWo.Text;
    Open;
  end;
  if StrToIntDef(LabPICK.Caption,0)< StrToIntDef(lablQty.Caption,0) then
  begin
    edtMaterial.Enabled:=False;
    MessageDlg('Work Order: ' + edtWo.Text + ' Pick Qty < Target Qty'+ #13#13 + 'Can'''+'t Abnormal Pick', mtError, [mbOK], 0);
    edtWo.SelectAll;
    edtWo.SetFocus;
  end else
  begin
    edtMaterial.Enabled:=True;
    edtMaterial.SelectAll;
    edtMaterial.SetFocus;
  end;    
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  edtWo.SetFocus;
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
    Params.ParamByName('dll_name').AsString := 'WOABNORMALPICKDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Over Request'' ';
    Open;
    gsOverField := FieldByName('param_name').AsString;
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
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then begin
      edtWo.CharCase := ecUpperCase;
      edtMaterial.CharCase := ecUpperCase;
    end;
    close;
  end;
end;

procedure TfDetail.edtWoKeyPress(Sender: TObject; var Key: Char);
begin
  lablMsg.Caption := '';
  if Ord(Key) = vk_Return then
  begin
    if CheckWO(trim(edtWo.Text)) then
    begin
      QryDetail.Close;
      QryMaterial.Close;
      ShowData('');
    end
    else begin
      edtWo.SelectAll;
      edtWo.SetFocus;
      showmessage('Can Not Abnormal Pick!-Not The End WO');
    end;
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
      Params.CreateParam(ftString, 'work_order', ptInput);
      CommandText := 'Select a.work_order, Part_No, Target_qty '
        + 'From SAJET.G_WO_Base a, sajet.sys_part b, sajet.g_wo_pick_info c '
        + 'Where a.work_order like :work_order and a.model_id = b.part_id '
        + 'and a.work_order = c.work_order AND A.WO_STATUS<>''9'' '
        + 'group by a.work_order, part_no, target_qty  '
        + 'Order By a.work_order ';
      Params.ParamByName('work_order').AsString := edtWo.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      edtWo.Text := QryTemp.FieldByName('Work_Order').AsString;
      QryTemp.Close;
      Key := #13;
      edtWOKeyPress(Self, Key);
    end;
    free;
  end;
end;

procedure TfDetail.edtMaterialKeyPress(Sender: TObject; var Key: Char);
  procedure UpdateWM(sPartID: string; iWMQty: Real);
  var sRowId: string;
  begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.CommandText := 'select rowid from sajet.g_material_wm '
      + 'where part_id = :part_id and work_order = :work_order and group_wo = ''-1'' ';
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
      QryTemp.Params.ParamByName('group_wo').AsString := '-1';
    end
    else
    begin
      sRowID := QryTemp.FieldByName('rowid').AsString;
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftInteger, 'qty', ptInput);
      QryTemp.Params.CreateParam(ftString, 'update_userid', ptInput);
      QryTemp.Params.CreateParam(ftString, 'sRowid', ptInput);
      QryTemp.CommandText := 'update sajet.g_material_wm '
        + 'set qty = qty+:qty, update_userid = :update_userid, update_time = sysdate '
        + 'where rowid = :sRowid';
      QryTemp.Params.ParamByName('qty').AsFloat := iWMQty;
      QryTemp.Params.ParamByName('update_userid').AsString := UpdateUserid;
      QryTemp.Params.ParamByName('sRowid').AsString := sRowId;
    end;
    QryTemp.Execute;
    QryTemp.Close;
  end;
var iQty, iIssue, iRequest: Integer;
  sPartId, sType, sDateCode, OverRequest, sPartNo, sVersion, sStock, sLocate, sItemID: string;
  sStr,sNoCheck:string;
begin
  if Ord(Key) = vk_Return then
  begin

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
    if (sNoCheck='NGFIFO') and SendMsg then
    begin
      MessageDlg('Unlimit By Fifo!', mtError, [mbOK], 0);
    end;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'material_no', ptInput);
    QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
    QryTemp.CommandText := 'select reel_no, material_no, part_no, b.VERSION, b.' + gsOverField + ', option7,a.status,a.factory_id '
      + ' from sajet.g_material a, sajet.sys_part b '
      + ' where (reel_no = :reel_no or material_no = :material_no) and rownum = 1 '
      + ' and a.part_id = b.part_id ';
    QryTemp.Params.ParamByName('material_no').AsString := edtMaterial.Text;
    QryTemp.Params.ParamByName('reel_no').AsString := edtMaterial.Text;
    QryTemp.Open;
    if QryTemp.IsEmpty then
    begin
      MessageDlg('ID No: ' + edtMaterial.Text + ' not found.', mtError, [mbOK], 0);
      edtMaterial.SelectAll;
      edtMaterial.SetFocus;
      Exit;
    end
    else if QryTemp.fieldbyname('factory_id').AsString<>G_FCID then
    begin
        MessageDlg('ID No: ' + edtMaterial.Text + ' ORG IS NOT '+EDITORG.Text, mtError, [mbOK], 0);
        edtMaterial.SelectAll;
        edtMaterial.SetFocus;
        Exit;
    end
    else if QryTemp.fieldbyname('status').AsString='1' then
    begin
      OverRequest := UpperCase(QryTemp.FieldByName(gsOverField).AsString);
      sPartNo := QryTemp.FieldByName('part_no').AsString;
      sItemID := QryTemp.FieldByName('option7').AsString;
      sVersion := QryTemp.FieldByName('version').AsString;
      if QryTemp.FieldByName('material_no').AsString = edtMaterial.Text then
        sType := 'Material'
      else
        sType := 'Reel';
    end
    else
    begin
      MessageDlg('ID No: ' + edtMaterial.Text + ' not incoming.', mtError, [mbOK], 0);
      edtMaterial.SelectAll;
      edtMaterial.SetFocus;
      Exit;
    end;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.CommandText := 'select reel_no, reel_qty, material_no, material_qty, status, '
      + 'a.part_id, a.datecode, d.warehouse_name, e.locate_name, issue_qty, request_qty '
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
      edtMaterial.SelectAll;
      edtMaterial.SetFocus;
      Exit;
    end;
    if QryTemp.FieldByName('warehouse_name').AsString = '' then
    begin
      MessageDlg('ID No: ' + edtMaterial.Text + ' not InStock.', mtError, [mbOK], 0);
      edtMaterial.SelectAll;
      edtMaterial.SetFocus;
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
    iIssue := QryTemp.FieldByName('issue_qty').AsInteger;
    iRequest := QryTemp.FieldByName('request_qty').AsInteger;
    if QryTemp.FieldByName('Status').AsString <> '1' then
    begin
      MessageDlg('ID No: ' + edtMaterial.Text + ' not InStock.', mtError, [mbOK], 0);
      edtMaterial.SelectAll;
      edtMaterial.SetFocus;
      Exit;
    end
    else
    begin
      sPartId := QryTemp.FieldByName('part_id').AsString;
      {if NOT ((OverRequest = 'YES') or (OverRequest = 'TPS-YES') OR (OverRequest = 'NO CHECK') ) then
      begin
        MessageDlg('Part: ' + sPartNo + ' cann''t abnormal feed!', mtError, [mbOK], 0);
        edtMaterial.SelectAll;
        edtMaterial.SetFocus;
        Exit;
      end; }
      {else if iIssue < iRequest then begin
        MessageDlg('Part: ' + sPartNo + #13#13 + 'Request: ' + IntToStr(iRequest) + #13#13
          + 'Issue: ' + IntToStr(iIssue) + #13#13 + 'Cann''t abnormal feed!', mtError, [mbOK], 0);
        edtMaterial.SelectAll;
        edtMaterial.SetFocus;
        Exit;
      end;}
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
      QryTemp.Params.ParamByName('sequence').AsString := '-1';
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
          Params.ParamByName('TPART').AsString := sPartNo;
          Params.ParamByName('TITEMID').AsString := sItemID;
          Params.ParamByName('TREV').AsString := sVersion;
          Params.ParamByName('TQTY').AsInteger := iQty;
          Params.ParamByName('TSUBINV').AsString := sStock;
          Params.ParamByName('TLOCATOR').AsString := sLocate;
          Params.ParamByName('TSEQ').AsString := '-1';
          Params.ParamByName('TSTATUS').AsString := 'Y';
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
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
      QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
      QryTemp.Params.CreateParam(ftInteger, 'QTY', ptInput);
      QryTemp.Params.CreateParam(ftInteger, 'QTY1', ptInput);
      QryTemp.CommandText := 'update sajet.g_wo_pick_list '
        + 'set AB_ISSUE_QTY=AB_ISSUE_QTY+:QTY   '
        + '    ,issue_qty=issue_qty+:qty1 '
        + 'where part_id = :part_id and work_order = :work_order ';
      QryTemp.Params.ParamByName('part_id').AsString := sPartID;
      QryTemp.Params.ParamByName('work_order').AsString := edtWo.Text;
      QryTemp.Params.ParamByName('QTY').AsInteger := iQty;
      QryTemp.Params.ParamByName('QTY1').AsInteger := iQty;
      QryTemp.Execute;
      QryTemp.Close;
      UpdateWM(sPartID, iQty);

      QryTemp.Close;
      Qrytemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
      QryTemp.Params.CreateParam(ftString, 'userid', ptInput);
      if sType = 'Reel' then
        QryTemp.CommandText:=' update sajet.g_material '
                            +' set type=''O'' '
                            +'     ,update_userid=:userid '
                            +'     ,update_time=sysdate '
                            +' where reel_no=:reel_no '
      else
        QryTemp.CommandText:=' update sajet.g_material '
                            +' set type=''O'' '
                            +'     ,update_userid=:userid '
                            +'     ,update_time=sysdate '
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
      QryDetail.Close;
      QryDetail.Open;
      QryDetail.Locate('part_no', sPartNo, []);
      QryMaterial.Close;
      QryMaterial.Open;
    end;
    edtMaterial.SelectAll;
    edtMaterial.SetFocus;
  end;
end;

procedure TfDetail.DataSource2DataChange(Sender: TObject; Field: TField);
begin
  with QryMaterial do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'work_order', ptInput);
    Params.CreateParam(ftString, 'part_id', ptInput);
    Params.CreateParam(ftString, 'sequence', ptInput);
    CommandText := 'Select part_no, material_no, qty '
      + 'from SAJET.G_Pick_List a, sajet.sys_part b '
      + 'Where work_order = :work_order and a.part_id = b.part_id '
      + 'and a.part_id = :part_id '
      + 'and sequence = :sequence order by part_no, material_no ';
    Params.ParamByName('work_order').AsString := edtWo.Text;
    Params.ParamByName('part_id').AsString := QryDetail.FieldByName('part_id').AsString;
    Params.ParamByName('sequence').AsString := '-1';
    Open;
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


function TDBGrid.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  IF not (datasource.DataSet.active) THEN EXIT;
  if WheelDelta > 0 then
    datasource.DataSet.Prior;
  if wheelDelta < 0 then
    DataSource.DataSet.Next;
  Result := True;
end;


procedure TfDetail.DBGrid1TitleClick(Column: TColumn);
var bAesc: Boolean;
begin
  bAesc := True;
  if DBGrid1.DataSource = nil then Exit;
  if DBGrid1.DataSource.DataSet = nil then Exit;
  if not (DBGrid1.DataSource.DataSet is TClientDataSet) then Exit;
  if (DBGrid1.DataSource.DataSet as TClientDataSet).Active then
  begin
    if (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName <> '' then
    begin
      bAesc := True;
      if (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName = Column.FieldName then
        bAesc := False;
       (DBGrid1.DataSource.DataSet as TClientDataSet).deleteIndex((DBGrid1.DataSource.DataSet as TClientDataSet).Indexname);
    end;
    if bAesc then begin
      (DBGrid1.DataSource.DataSet as TClientDataSet).AddIndex(Column.FieldName, Column.FieldName, [], '', '', 0);
      (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName := Column.FieldName;
    end else begin
      (DBGrid1.DataSource.DataSet as TClientDataSet).AddIndex(Column.FieldName + 'D', Column.FieldName, [ixDescending], '', '', 0);
      (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName := Column.FieldName + 'D';
    end;
    (DBGrid1.DataSource.DataSet as TClientDataSet).IndexDefs.Update;
  end;
end;

procedure TfDetail.DBGrid2TitleClick(Column: TColumn);
var bAesc: Boolean;
begin
  bAesc := True;
  if DBGrid1.DataSource = nil then Exit;
  if DBGrid1.DataSource.DataSet = nil then Exit;
  if not (DBGrid1.DataSource.DataSet is TClientDataSet) then Exit;
  if (DBGrid1.DataSource.DataSet as TClientDataSet).Active then
  begin
    if (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName <> '' then
    begin
      bAesc := True;
      if (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName = Column.FieldName then
        bAesc := False;
       (DBGrid1.DataSource.DataSet as TClientDataSet).deleteIndex((DBGrid1.DataSource.DataSet as TClientDataSet).Indexname);
    end;
    if bAesc then begin
      (DBGrid1.DataSource.DataSet as TClientDataSet).AddIndex(Column.FieldName, Column.FieldName, [], '', '', 0);
      (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName := Column.FieldName;
    end else begin
      (DBGrid1.DataSource.DataSet as TClientDataSet).AddIndex(Column.FieldName + 'D', Column.FieldName, [ixDescending], '', '', 0);
      (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName := Column.FieldName + 'D';
    end;
    (DBGrid1.DataSource.DataSet as TClientDataSet).IndexDefs.Update;
  end;
end;

end.

