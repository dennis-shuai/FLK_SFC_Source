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
    DataSource1: TDataSource;
    QryAbnormal: TClientDataSet;
    DataSource2: TDataSource;
    SProc: TClientDataSet;
    Label6: TLabel;
    edtVersion: TEdit;
    edtItem: TEdit;
    Label3: TLabel;
    edtRequest: TEdit;
    edtIssue: TEdit;
    chkPush: TRzCheckBox;
    EditSource: TEdit;
    Qrytemp1: TClientDataSet;
    QryWO: TClientDataSet;
    QryID: TClientDataSet;
    edtFIFO: TEdit;
    Label8: TLabel;
    Label11: TLabel;
    Lblwh: TLabel;
    lbllocate: TLabel;
    Label13: TLabel;
    EditORG: TEdit;
    procedure FormShow(Sender: TObject);
    procedure sbtnMaterialClick(Sender: TObject);
    procedure editMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnClearClick(Sender: TObject);
    procedure cmbStockChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsGroupWo, gsLabelField, gsLocateField,gsLocateid: string;
    slLocateId, slStockId: TStringList;
    gbFromWM,gbRTFlag: Boolean;
    G_FCID,G_FCCODE,G_FCTYPE:string;
    function CheckMaterial(var sPartId: string): Boolean;
    function updateTable(sPartId,stable,sType,sID: string; sInt : Integer): Boolean;
    procedure ClearData;
    FUNCTION GetRTID(RTNO:string):string;
    Function GetWO(sWO:string;var FinalWO:string):boolean;
    function GetQty(IDNo:string):integer;
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

function TfDetail.GetQty(IDNo:string):integer;
var tWO:string;
    IDQty,WoPickQty:Integer;
begin
    result:=0;
    with qryID do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'IDNO', ptInput);
      commandtext:='select * from sajet.g_pick_list where material_no=:IDNO ';
      Params.ParamByName('IDNO').AsString :=IDNO;
      open;
      IDQTY:=fieldbyname('qty').AsInteger;
      tWo:=fieldbyname('work_order').AsString;
      close;
      Params.CreateParam(ftString, 'WO', ptInput);
      commandtext:='select work_order from sajet.g_wo_group where from_wo=:wo';
      Params.ParamByName('WO').AsString :=tWO;
      open;
      if ISempty then begin
        Result:=IDQty;
        exit;
      end else begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'wo', ptInput);
      commandtext:='select * from sajet.g_wo_pick_list where work_order=:wo ';
      Params.ParamByName('wo').AsString :=two;
      open;
      woPickQty:=fieldbyname('to_wo').AsInteger;
      end;
    end;
    
    while true do
    begin
        QryWO.close;
        QryWO.params.clear;
        QryWO.Params.CreateParam(ftString, 'WO', ptInput);
        QryWO.commandtext:='select work_order from sajet.g_wo_group where from_wo=:wo';
        QryWO.Params.ParamByName('WO').AsString :=tWO;
        QryWO.open;
        if not QryWO.isEmpty then
        begin
           tWO:=QryWO.fieldbyname('work_order').AsString;
           qryId.Close;
           qryID.Params.Clear;
           qryId.Params.CreateParam(ftString, 'WO', ptInput);
           qryid.CommandText:=' select * from sajet.g_wo_pick_list where work_order=:wo ';
           qryid.Params.ParamByName('WO').AsString :=tWO;
           qryID.Open;
           if woPickQty>qryID.FieldByName('to_wo').AsInteger then
           begin
             woPickQty:=qryID.FieldByName('to_wo').AsInteger;
           end;
           continue;
        end
        else begin
          break;
        end;
    end;
    if IDqty<woPickQty then
      result:=IDqty
    else result:=woPickqty;
end;


Function TfDetail.GetWO(sWO:string;var FinalWO:string):boolean;
var tWo:string;
begin
   Result:=false;
   tWO:=sWO;
   while true do
   begin
        QryWO.close;
        QryWO.params.clear;
        QryWO.Params.CreateParam(ftString, 'WO', ptInput);
        QryWO.commandtext:='select work_order from sajet.g_wo_group where from_wo=:wo';
        QryWO.Params.ParamByName('WO').AsString :=tWO;
        QryWO.open;
        if not QryWO.isEmpty then
        begin
           tWO:=QryWO.fieldbyname('work_order').AsString;
           continue;
        end
        else begin
          FinalWO:=tWO;
          break;
        end;
   end;
   QryWO.Close;
   Result:=true;
end;

FUNCTION TfDetail.GetRTID(RTNO:string):string;
begin
  with Qrytemp1 do
  begin
    close;
    params.clear;
    Params.CreateParam(ftString, 'IRTNO', ptInput);
    commandtext:=' select rt_id '
                +' from sajet.g_erp_rtno '
                +' where rt_no=:iRTNO ';
    Params.ParamByName('IRTNO').AsString :=rtno;
    open;
    result:=fieldbyname('rt_id').asstring;
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
  gbRTFlag:=False;
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
    {CommandText := 'select warehouse_id, warehouse_name '
      + 'from sajet.sys_warehouse where enabled = ''Y'' order by warehouse_name';
      }
    //入庫權限受管控　2008/10/14 by key 
    CommandText := 'select a.warehouse_id, a.warehouse_name '
      + 'from sajet.sys_warehouse a  ,sajet.sys_emp_warehouse b '
      + ' where a.warehouse_id=b.warehouse_id and B.EMP_ID='''+UpdateUserID+''' '
      + ' AND a.enabled = ''Y'' and b.enabled=''Y'' order by a.warehouse_name';
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
    Params.ParamByName('dll_name').AsString := 'WOABNORMALRETURNDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then begin
      editMaterial.CharCase := ecUpperCase;
      editWo.CharCase := ecUpperCase;
      editPart.CharCase := ecUpperCase;
    end;
  end;
  editMaterial.SetFocus;
end;

function TfDetail.CheckMaterial(var sPartId: string): Boolean;
begin
  Result := False;
  with QryDetail do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'material_no', ptInput);
    CommandText := 'select a.work_order, a.part_id, part_no, qty, datecode, sequence, a.version, option7, a.MFGER_PART_NO, a.MFGER_NAME, '
      + gsLabelField + ', ' + gsLocateField + ',' + gsLabelField + ', c.* '
      + ' from sajet.g_pick_list a, sajet.g_wo_pick_list c, sajet.sys_part b '
      + ' where material_no = :material_no and a.part_id = c.part_id '
      + ' and a.work_order=c.work_order and a.part_id = b.part_id ';
    Params.ParamByName('material_no').AsString := editMaterial.Text;
    Open;
    if IsEmpty then
    begin
      MessageDlg('Material No not found!', mtError, [mbOK], 0);
      editMaterial.SelectAll;
      editMaterial.SetFocus;
    end else if RecordCount>1 then
    begin
      MessageDlg('RecordCount>1, Error !', mtError, [mbOK], 0);
      editMaterial.SelectAll;
      editMaterial.SetFocus;
    end
    else begin
      QryReel.Close;
      QryReel.Params.Clear;
      QryReel.Params.CreateParam(ftString, 'MATERIAL_NO', ptInput);
      QryReel.CommandText := 'select nvl(B.RT_NO,''N/A'') RT_NO,NVL(A.REMARK,''N/A'') REMARK,a.UPDATE_TIME,a.type,a.FIFOCode from sajet.G_HT_MATERIAL a,SAJET.G_ERP_RTNO b '
                   + 'where a.MATERIAL_NO = :MATERIAL_NO AND A.RT_ID=B.RT_ID(+) '
                   + 'order by UPDATE_TIME desc,type ';
      QryReel.Params.ParamByName('MATERIAL_NO').AsString := editMaterial.Text;;
      QryReel.Open;
      if (QryReel.IsEmpty) or (QryReel.FieldByName('type').AsString<>'O') then
      begin
        QryReel.Close;
        QryReel.Params.Clear;
        QryReel.Params.CreateParam(ftString, 'MATERIAL_NO', ptInput);
        QryReel.CommandText := 'select nvl(B.RT_NO,''N/A'') RT_NO,NVL(A.REMARK,''N/A'') REMARK,a.UPDATE_TIME,a.type,a.fifoCode from sajet.G_HT_MATERIAL a,SAJET.G_ERP_RTNO b '
                     + 'where a.REEL_NO = :MATERIAL_NO AND A.RT_ID=B.RT_ID(+) '
                     + 'order by UPDATE_TIME desc ';
        QryReel.Params.ParamByName('MATERIAL_NO').AsString := editMaterial.Text;;
        QryReel.Open;
        if (QryReel.IsEmpty) or (QryReel.FieldByName('Type').AsString<>'O') then
        begin
          MessageDlg('Material No not exist!', mtError, [mbOK], 0);
          editMaterial.SelectAll;
          editMaterial.SetFocus;
          exit;
        end;
      end ;

      if QryReel.FieldByName('RT_NO').AsString<>'N/A' Then
      begin
        EditSource.Text:=QryReel.FieldByName('RT_NO').AsString;
        gbRTFlag:=True;
      end
      else if QryReel.FieldByName('REMARK').AsString<>'N/A' Then
      begin
        EditSource.Text:=QryReel.FieldByName('REMARK').AsString;
        gbRTFlag:=False;
      end;
      edtFIFO.Text:=QryReel.fieldbyname('FIFOCode').AsString;
      {else
      begin
        MessageDlg('NO RESOURCE !', mtError, [mbOK], 0);
        editMaterial.SelectAll;
        editMaterial.SetFocus;
        exit;
      end;}

     { QryReel.Close;
      QryReel.Params.Clear;
      QryReel.Params.CreateParam(ftString, 'work_order', ptInput);
      QryReel.Params.CreateParam(ftString, 'group_wo', ptInput);
      QryReel.CommandText := 'select work_order from sajet.g_wo_group a '
                   + 'where work_order = :work_order or group_wo = :group_wo ';
      QryReel.Params.ParamByName('work_order').AsString := QryDetail.FieldByName('work_order').AsString;
      QryReel.Params.ParamByName('group_wo').AsString := QryDetail.FieldByName('work_order').AsString;
      QryReel.Open;
      if NOT QryReel.IsEmpty then
      begin
        MessageDlg('Group WO Can'''+'t   Abnormal Return !', mtError, [mbOK], 0);
        editMaterial.SelectAll;
        editMaterial.SetFocus;
        exit;
      end; }

      QryReel.Close;
      QryReel.Params.Clear;
      QryReel.Params.CreateParam(ftString, 'work_order', ptInput);
      QryReel.CommandText := 'select wo_status,factory_id from sajet.g_wo_base '
        + 'where work_order = :work_order ';
      QryReel.Params.ParamByName('work_order').AsString := QryDetail.FieldByName('work_order').AsString;
      QryReel.Open;
      if QryReel.FieldByName('wo_status').AsString = '9' then
      begin
        MessageDlg('Work Order: ' + QryDetail.FieldByName('work_order').AsString + ' is complete no charge!', mtError, [mbOK], 0);
        editMaterial.SelectAll;
        editMaterial.SetFocus;
        QryReel.Close;
        exit;
      end;

      G_FCID:='';
      G_FCCODE:='';
      G_FCTYPE:='';
      editorg.Clear ;
      G_FCID:=QryReel.FieldByName('factory_id').AsString;
      if Getfctype(G_FCID)<>'OK' then
      begin
          editorg.Clear;
          exit;
      end
      else
         editorg.Text :=G_FCCODE;



      sPartId := QryDetail.FieldByName('part_id').AsString;
      editPart.Text := QryDetail.FieldByName('part_no').AsString;
      edtItem.Text := QryDetail.FieldByName('option7').AsString;
      lablMQty.Caption := QryDetail.FieldByName('qty').AsString;
      edtDateCode.Text := QryDetail.FieldByName('DateCode').AsString;
      edtVersion.Text := QryDetail.FieldByName('version').AsString;
      editWo.Text := QryDetail.FieldByName('work_order').AsString;
      edtRequest.Text := QryDetail.FieldByName('request_qty').AsString;
      edtIssue.Text := QryDetail.FieldByName('issue_qty').AsString;
      Result := True;
      lablType.Caption := QryDetail.FieldByName(gsLabelField).AsString;
      // 預設Loate 取sys_part table 中的值　
     // gsLocateid := QryDetail.FieldByName(gsLocateField).AsString;
      if lablType.Caption = '' then
        lablType.Caption := 'QTY ID';

     // 預設Loate 取sys_part_factory table 中的值,change by key 2008/07/25
      with QryTemp do
      begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'part_id', ptInput);
          Params.CreateParam(ftString, 'factory_id', ptInput);
          CommandText := 'select locate_name, warehouse_name, b.warehouse_id, a.locate_id from sajet.sys_part_factory a, sajet.sys_locate b, sajet.sys_warehouse c '
               + 'where part_id = :part_id and a.locate_id = to_char(b.locate_id) and b.warehouse_id = c.warehouse_id and a.factory_id = :factory_id and rownum = 1';
          Params.ParamByName('part_id').AsString :=sPartId;
          Params.ParamByName('factory_id').AsString :=G_FCID ;
          Open;
          gsLocateid := QryTemp.FieldByName('locate_id').AsString;
          close;
      end;

    end;
  end;
end;

procedure TfDetail.sbtnMaterialClick(Sender: TObject);
  procedure InsertMaterial(sType, sPartId: string);
  var sMaterial, sPrintData,sWO: string;
      iCnt : Integer;
  begin
    if not GetWO(editWo.Text,sWO) then
    begin
       showmessage('Get Group WO Error! ');
       exit;
    end;
    //showmessage(swo);
    with QryTemp do
    begin
//      if StrToInt(lablMQty.Caption) <> sedtQty.Value then
//      begin
        Close;
        Params.Clear;
        CommandText := 'select sajet.to_label(''' + lablType.Caption + ''', ''' + editMaterial.Text + ''') SNID from dual';
        Open;
        sMaterial := FieldByName('SNID').AsString;
        Close;
//      end
//      else
//        sMaterial := editMaterial.Text;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'group_wo', ptInput);
      Params.CreateParam(ftString, 'part_id', ptInput);
      CommandText := 'select rowid,qty,UPDATE_TIME from sajet.g_material_wm ';
      CommandText := CommandText + 'where work_order = :group_wo and part_id = :part_id order by UPDATE_TIME desc ';
      Params.ParamByName('group_wo').AsString := sWO;//editWo.Text;
      Params.ParamByName('part_id').AsString := sPartId;
      open;
      iCnt:=0;
      QryTemp.First;
      if not QryTemp.IsEmpty then
      begin
          while not QryTemp.Eof do
          begin
            if FieldByName('qty').AsInteger<=(sedtQty.Value-iCnt) then
            begin
               updateTable(sPartId,'sajet.g_material_wm','Delete',FieldByName('rowid').AsString,0);
               iCnt:=iCnt+FieldByName('qty').AsInteger;
            end
            else if FieldByName('qty').AsInteger>(sedtQty.Value-iCnt) then
            begin
               updateTable(sPartId,'sajet.g_material_wm','Update',FieldByName('rowid').AsString,sedtQty.Value-iCnt);
               Break;
            end;
            next;
          end;
      end;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'qty', ptInput);
      Params.CreateParam(ftString, 'work_order', ptInput);
      Params.CreateParam(ftString, 'part_id', ptInput);
      Params.CreateParam(ftString, 'qty1', ptInput);
      CommandText := 'update sajet.g_wo_pick_list '
        + 'set issue_qty = issue_qty + :qty, to_wo = 0,AB_RETURN_QTY=AB_RETURN_QTY+:qty1 '
        + 'where work_order = :work_order and part_id = :part_id ';
      Params.ParamByName('qty').AsInteger := -1 * sedtQty.Value;
      Params.ParamByName('work_order').AsString := sWO;
      Params.ParamByName('part_id').AsString := sPartId;
      Params.ParamByName('qty1').AsInteger := sedtQty.Value;
      Execute;
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


      //// error
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
        + '(part_id, datecode, material_no, material_qty, update_userid, warehouse_id, locate_id, update_time, status, MFGER_NAME, MFGER_PART_NO,RT_ID,REMARK, version,FIFOCode,factory_id,factory_type) '
        + 'values (:part_id, :datecode, :material_no, :material_qty, :update_userid, :warehouse_id, :locate_id, sysdate, 1, :MFGER_NAME, :MFGER_PART_NO,:RT_ID,:REMARK, :version,:FIFO,:factory_id,:factory_type)';
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
      Params.ParamByName('MFGER_NAME').AsString := QryDetail.FieldByName('MFGER_NAME').AsString;
      Params.ParamByName('MFGER_PART_NO').AsString := QryDetail.FieldByName('MFGER_PART_NO').AsString;
      if gbRTFlag=True then
      begin
        Params.ParamByName('RT_ID').AsString := GetRTID(EditSource.Text);
        Params.ParamByName('REMARK').AsString := '';
      end else
      begin
        Params.ParamByName('RT_ID').AsString := '';
        Params.ParamByName('REMARK').AsString := EditSource.Text;
      end;
      Params.ParamByName('version').AsString := edtVersion.Text;
      Params.ParamByName('FIFO').AsString := edtFIFO.Text;
      Params.ParamByName('FACTORY_ID').AsString := G_FCID;
      Params.ParamByName('FACTORY_TYPE').AsString := G_FCTYPE;
      Execute;

      Close;
      Params.CreateParam(ftString, 'material_no', ptInput);
      commandtext:=' insert into sajet.g_ht_material '
                  +' select * from sajet.g_material where material_no =:material_no ';
      Params.ParamByName('material_no').AsString := sMaterial;
      Execute;

//      if StrToInt(lablMQty.Caption) <> sedtQty.Value then
//      begin
        sPrintData := G_getPrintData(6, 17, G_sockConnection, 'DspQryData', lablType.Caption + '*&*' + sMaterial, 1, 'DEFAULT');
        if assigned(G_onTransDataToApplication) then
          G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
        else
          showmessage('Not Defined Call Back Function for Code Soft');
        lablMsg.Caption := 'Return OK, New ID: ' + sMaterial + '.';
//      end
//      else
//        lablMsg.Caption := 'Return OK, ID No: ' + sMaterial + '.';
      // Upload Push Title
      with sproc do
      begin
        try                                                               
          Close;
          DataRequest('SAJET.MES_ERP_WIP_RETURN');
          FetchParams;
          Params.ParamByName('TWO').AsString := sWO;
          Params.ParamByName('TPART').AsString := editPart.Text;
          Params.ParamByName('TITEMID').AsString := edtItem.Text;
          Params.ParamByName('TREV').AsString := edtVersion.Text;
          Params.ParamByName('TQTY').AsInteger :=sedtQty.Value;//GetQty(trim(editMaterial.Text)); //sedtQty.Value - QryDetail.FieldByName('To_Wo').AsInteger;
          Params.ParamByName('TSUBINV').AsString := cmbStock.Text;
          Params.ParamByName('TLOCATOR').AsString := cmbLocate.Text;
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
  end;
var sType, sPartId: string;
begin
  if trim(editorg.Text)='' then
  begin
    MessageDlg('ORG IS NULL', mtError, [mbOK], 0);
    Exit;
  end;
  if sedtQty.Value <= 0 then Exit;
  //if (cmbStock.Text = '') or ((cmbLocate.Items.Count > 0) and (cmbLocate.ItemIndex = -1)) then
  if cmbLocate.ItemIndex = -1 then
  begin
    MessageDlg('Please select Locator!', mtWarning, [mbOK], 0);
    Exit;
  end;
  if sedtQty.Value>StrToIntDef(lablMQty.Caption,0) then
  begin
    MessageDlg('Qty Error Max:'+lablMQty.Caption, mtWarning, [mbOK], 0);
    Exit;
  end;
  if editMaterial.Text = '' then Exit;
  if CheckMaterial(sPartId) then
  begin
    InsertMaterial(sType, sPartId);
  end;
  editMaterial.Text := '';
  editPart.Text := '';
  sedtQty.Text := '0';
  edtDateCode.Text := '';
  lablMQty.Caption := '';
  cmbStock.ItemIndex := -1;
  cmbLocate.Items.Clear;
  editMaterial.SetFocus;
  editWo.Text := '';
  EditSource.Text:='';
  edtVersion.Text := '';
  edtRequest.Text := '';
  edtIssue.Text := '';
  editorg.Text :='';
//  QryAbnormal.Close;
//  QryAbnormal.Open;
end;

procedure TfDetail.editMaterialKeyPress(Sender: TObject; var Key: Char);
var sLocate, sPartId: string;
var strsql:string;
begin
  if Ord(Key) = vk_Return then
  begin
    editwo.Text := '';
    editPart.Text := '';
    gsLocateid:='';
    sedtQty.Text := '0';
    edtDateCode.Text := '';
    lablMQty.Caption := '';
    editPart.Enabled := False;
    edtDateCode.Enabled := False;
    QryAbnormal.Close;
    lablMsg.Caption := '';
    EditSource.Text:='';
    editorg.Text:='';
    if CheckMaterial(sPartId) then
    begin
      if gsLocateid <> '' then
      begin
        QryTemp.Close;
        QryTemp.Params.Clear;
        QryTemp.Params.CreateParam(ftString, 'locate_id', ptInput);
        QryTemp.CommandText := 'select locate_name, warehouse_name, b.warehouse_id, locate_id from sajet.sys_locate b, sajet.sys_warehouse c '
          + 'where b.locate_id = :locate_id and b.warehouse_id = c.warehouse_id and rownum = 1';
        QryTemp.Params.ParamByName('locate_id').AsString := gsLocateid;
        QryTemp.Open;
        cmbStock.ItemIndex := cmbStock.Items.IndexOf(QryTemp.FieldByName('Warehouse_name').AsString);
        sLocate := QryTemp.FieldByName('locate_name').AsString;
        if cmbStock.ItemIndex <> -1 then
        begin
          cmbStockChange(Self);
          cmbLocate.ItemIndex := cmbLocate.Items.IndexOf(sLocate);
        end else
        begin
          cmbStock.ItemIndex:=-1;
          cmbLocate.ItemIndex:=-1;
        end;
      end else
      begin
          cmbStock.ItemIndex:=-1;
          cmbLocate.ItemIndex:=-1;
      end;
      //add 顯示發料庫的warehouse_name and locate_name
      // add by key 2008/03/07
      // add start
      if copy(editMaterial.Text,1,1)='R' then
        strsql:=' select b.warehouse_name,c.locate_name from sajet.g_ht_material a, sajet.sys_warehouse b,sajet.sys_locate c '
                +' where a.reel_no=:material_no and a.type=''O''    '
                +' and a.warehouse_id=b.warehouse_id(+) and a.locate_id=c.locate_id(+)  order by a.update_time desc '
      else
         strsql:=' select b.warehouse_name,c.locate_name from sajet.g_ht_material a, sajet.sys_warehouse b,sajet.sys_locate c '
                +' where a.material_no=:material_no and a.type=''O''   '
                +' and a.warehouse_id=b.warehouse_id(+) and a.locate_id=c.locate_id(+)  order by a.update_time desc ';
       with qrytemp do
       begin
           close;
           params.CreateParam(ftstring,'material_no',ptinput);
           commandtext:=strsql;
           params.ParamByName('material_no').AsString :=editmaterial.Text ;
           open;
           if not isempty then
           begin
              FIRST;
              lblwh.Font.Color :=clred;
              lbllocate.Font.Color :=clred;
              lblwh.Caption :=fieldbyname('warehouse_name').AsString ;
              lbllocate.Caption :=fieldbyname('locate_name').AsString ;
           end
           else
           begin
             lblwh.Font.Color:=clblack;
             lbllocate.Font.Color :=clblack;
             lblwh.Caption :='';
             lbllocate.Caption :='';
           end
       end;
      //add end
      
      editPart.Enabled := False;
      edtDateCode.Enabled := False;
      sedtQty.SelectAll;
      sedtQty.SetFocus;
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
  gsLocateid:='';
  sedtQty.Text := '0';
  edtDateCode.Text := '';
  lablMQty.Caption := '';
  editPart.Enabled := False;
  edtDateCode.Enabled := False;
  lablMsg.Caption := '';
  EditSource.Text:='';
  Editorg.Text :='';
  QryAbnormal.Close;
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

function TfDetail.updateTable(sPartId,stable,sType,sID: string;sInt : Integer): Boolean;
begin
  with QryAbnormal do
  begin
    Close;
    Params.Clear;
    if sType='Delete' then
    begin
      Params.CreateParam(ftString, 'PN', ptInput);
      Params.CreateParam(ftString, 'sID', ptInput);
      CommandText := 'delete FROM  '+stable;
      CommandText := CommandText + ' where rowid=:sID and work_order = '''+editWo.text+''' and part_id =:PN ';
      Params.ParamByName('PN').AsString := sPartId;
      Params.ParamByName('sID').AsString := sID;
    end else if sType='Update' then
    begin
      Params.CreateParam(ftInteger, 'sqty', ptInput);
      Params.CreateParam(ftString, 'PN', ptInput);
      Params.CreateParam(ftString, 'sUSER', ptInput);
      Params.CreateParam(ftString, 'sID', ptInput);
      CommandText := 'update '+stable+' set qty=qty -:sqty ,update_time=sysdate,Update_UserID=:sUSER ';
      CommandText := CommandText + ' where rowid=:sID and work_order = '''+editWo.text+''' and part_id = :PN ';
      Params.ParamByName('sqty').AsInteger := sInt;
      Params.ParamByName('PN').AsString := sPartId;
      Params.ParamByName('sUSER').AsString :=UpdateUserID;
      Params.ParamByName('sID').AsString := sID;
    end;
    Execute;
  end;
  Result:=True;
end;

end.

