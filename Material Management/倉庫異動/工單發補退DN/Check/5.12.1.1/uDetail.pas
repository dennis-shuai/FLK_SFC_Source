unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles, ComCtrls, RzButton, RzRadChk;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryMaterial: TClientDataSet;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    QryDetail: TClientDataSet;
    DataSource2: TDataSource;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    edtWipscNO: TEdit;
    sbtnMISC: TSpeedButton;
    EditORG: TEdit;
    Label13: TLabel;
    Image1: TImage;
    sbtncheck: TSpeedButton;
    chkPush: TRzCheckBox;
    GroupBox1: TGroupBox;
    DBGrid1: TDBGrid;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    DataSource1: TDataSource;
    DBGrid2: TDBGrid;
    GroupBox4: TGroupBox;
    PageControl1: TPageControl;
    TabShtWI: TTabSheet;
    Label4: TLabel;
    Label8: TLabel;
    labWIlocate: TLabel;
    edtWIISSUEUSER: TEdit;
    edtWImaterial: TEdit;
    TabShtWIR: TTabSheet;
    Label12: TLabel;
    Label6: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    lablLocate: TLabel;
    Label9: TLabel;
    LablWIRMqty: TLabel;
    lablWIRType: TLabel;
    lablWIRMsg: TLabel;
    Image3: TImage;
    sbtnWIRprint: TSpeedButton;
    Label11: TLabel;
    editWIRPart: TEdit;
    edtWIRVersion: TEdit;
    edtWIRDateCode: TEdit;
    edtWIRFIFO: TEdit;
    DateTimePickerWIR: TDateTimePicker;
    edtWIRRequest: TEdit;
    edtWIRIssue: TEdit;
    cmbWIRStock: TComboBox;
    cmbWIRLocate: TComboBox;
    sedtWIRQty: TSpinEdit;
    edtWIRItem: TEdit;
    EdtWIRpartid: TEdit;
    edtWIRissueuser: TEdit;
    TabShtWR: TTabSheet;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label17: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label23: TLabel;
    editWRMaterial: TEdit;
    editWRWo: TEdit;
    edtWRVersion: TEdit;
    edtWRDateCode: TEdit;
    edtWRFIFO: TEdit;
    cmbWRStock: TComboBox;
    sedtWRQty: TSpinEdit;
    cmbWRLocate: TComboBox;
    lablWRMQty: TLabel;
    lablWRMsg: TLabel;
    EditWRSource: TEdit;
    QryWRReel: TClientDataSet;
    QryWRDetail: TClientDataSet;
    Label24: TLabel;
    edtWRRequest: TEdit;
    edtWRIssue: TEdit;
    lablWRType: TLabel;
    LblWRwh: TLabel;
    lblWRlocate: TLabel;
    Image2: TImage;
    sbtnWRprint: TSpeedButton;
    Label22: TLabel;
    editWRPart: TEdit;
    Label25: TLabel;
    edtWRissueuser: TEdit;
    qryTemp1: TClientDataSet;
    pm1: TPopupMenu;
    Delete1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure edtWipscNOKeyPress(Sender: TObject; var Key: Char);
    procedure DataSource2DataChange(Sender: TObject; Field: TField);
    procedure sbtnWIRprintClick(Sender: TObject);
    procedure sbtnMISCClick(Sender: TObject);
    procedure edtWImaterialKeyPress(Sender: TObject; var Key: Char);
    procedure edtWipscNOChange(Sender: TObject);
    procedure sbtnmfgerClick(Sender: TObject);
    procedure sbtncheckClick(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtWImaterialChange(Sender: TObject);
    procedure editWIRPartKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cmbWIRStockChange(Sender: TObject);
    procedure DateTimePickerWIRChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure editWIRPartChange(Sender: TObject);
    procedure editWRMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure cmbWRStockChange(Sender: TObject);
    procedure sbtnWRprintClick(Sender: TObject);
    procedure editWRMaterialChange(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelField,gsLocateField, gsBoxField, gsReelField,
    gsWO,gsTypeClass,gsIssueType,gsStatus,
    giSequence,gslpartno,gsOverField,gsLocateid: string;
    G_FCID,G_FCCODE,G_FCTYPE:string;
    gbRTFlag: Boolean;
    slWIRLocateId, slWIRStockId,slWRLocateId, slWRStockId: TStringList;
    procedure showData(sLocate: string);
    Function GetFIFOCode(dDate:TDateTime):string;
    Function GetFCTYPE(sFCID:string):string;
    function checkFIFO(MaterailNo:string;VAR NOCHECK:STRING):string;
    function SendMsg:boolean;
    function CheckWIMaterial: Boolean;
    Function GetWIRPart(PART_NO:string):string;
    Function CheckWIRMqty(WO:string;PART_NO:string):string;
    function CheckWRMaterial(var sPartId: string): Boolean;
    FUNCTION GetRTID(RTNO:string):string;
    function CheckWO: Boolean;
    function CheckWipMsterStatus: Boolean;
  end;

  { data list 2012/11/1 by key
    Issue_Type=1   (ISSUE_TYPE_NAME=發料單)        (TYPE_CLASS=I)  (可超發)
    Issue_Type=2   (ISSUE_TYPE_NAME=補料單)        (TYPE_CLASS=I)  (可超發)
    Issue_Type=3   (ISSUE_TYPE_NAME=退料單)         (TYPE_CLASS=R) (不可超退)
    Issue_Type=6   (ISSUE_TYPE_NAME=非生產性補料單) (TYPE_CLASS=I) (可超發)
    Issue_Type=7   (ISSUE_TYPE_NAME=非生產性退料單) (TYPE_CLASS=R) (不可超退)
  }

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin, uCommData, Udata;

function TfDetail.CheckWipMsterStatus: Boolean;
begin
    Result := False;
    if  gsStatus='2' then //had confirm
    begin
       showmessage('The source had confirm!') ;
    end;
    if  gsStatus='1' then //had check
    begin
       showmessage('The source had check!') ;
    end;
    if  gsStatus='0' then //NOT check or confirm
    begin
        Result := True;
    end;
end;

function TfDetail.CheckWO: Boolean;
begin
    Result := False;
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'work_order', ptInput);
      CommandText := 'Select target_qty, wo_status, factory_id ' +
        'from SAJET.G_wo_base ' +
        'Where work_order = :work_order ';
      Params.ParamByName('work_order').AsString := gsWO;
      Open;
    end;
    if QryTemp.IsEmpty then
    begin
      MessageDlg('Work Order not found.', mtError, [mbOK], 0);
      Exit;
    end
    else if QryTemp.FieldByName('wo_status').AsString = '9' then
    begin
      MessageDlg('Work Order: ' + gsWO +' is complete no charge,' +#10#13+ ' cann''t use this function.', mtError, [mbOK], 0);
      Exit;
    end;
    Result := True;
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

function TfDetail.CheckWRMaterial(var sPartId: string): Boolean;
begin
  Result := False;
  with QryWRDetail do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'material_no', ptInput);
    CommandText := 'select a.work_order, a.part_id, part_no, qty, datecode, sequence, a.version, option7, a.MFGER_PART_NO, a.MFGER_NAME, '
      + gsLabelField + ', ' + gsLocateField + ',' + gsLabelField + ', c.* '
      + ' from sajet.g_pick_list a, sajet.g_wo_pick_list c, sajet.sys_part b '
      + ' where material_no = :material_no and a.part_id = c.part_id '
      + ' and a.work_order=c.work_order and a.part_id = b.part_id ';
    Params.ParamByName('material_no').AsString := editWRMaterial.Text;
    Open;
    if IsEmpty then
    begin
      MessageDlg('Material No not found OR WO Error!', mtError, [mbOK], 0);
      editWRMaterial.SelectAll;
      editWRMaterial.SetFocus;
    end else if RecordCount>1 then
    begin
      MessageDlg('RecordCount>1, Error !', mtError, [mbOK], 0);
      editWRMaterial.SelectAll;
      editWRMaterial.SetFocus;
    end
    else begin
      //check 物料工單是否與Documemt number 的工單相同
      if  QryWRDetail.FieldByName('work_order').AsString <>gsWO then
      begin
          MessageDlg('WO Error '+#10#13+QryWRDetail.FieldByName('work_order').AsString + ' <> '+ gsWO , mtError, [mbOK], 0);
          editWRMaterial.SelectAll;
          editWRMaterial.SetFocus;
      end;

      QryWRReel.Close;
      QryWRReel.Params.Clear;
      QryWRReel.Params.CreateParam(ftString, 'MATERIAL_NO', ptInput);
      QryWRReel.CommandText := 'select nvl(B.RT_NO,''N/A'') RT_NO,NVL(A.REMARK,''N/A'') REMARK,a.UPDATE_TIME,a.type,a.FIFOCode from sajet.G_HT_MATERIAL a,SAJET.G_ERP_RTNO b '
                   + 'where a.MATERIAL_NO = :MATERIAL_NO AND A.RT_ID=B.RT_ID(+) '
                   + 'order by UPDATE_TIME desc,type ';
      QryWRReel.Params.ParamByName('MATERIAL_NO').AsString := editWRMaterial.Text;;
      QryWRReel.Open;
      if (QryWRReel.IsEmpty) or (QryWRReel.FieldByName('type').AsString<>'O') then
      begin
        QryWRReel.Close;
        QryWRReel.Params.Clear;
        QryWRReel.Params.CreateParam(ftString, 'MATERIAL_NO', ptInput);
        QryWRReel.CommandText := 'select nvl(B.RT_NO,''N/A'') RT_NO,NVL(A.REMARK,''N/A'') REMARK,a.UPDATE_TIME,a.type,a.fifoCode from sajet.G_HT_MATERIAL a,SAJET.G_ERP_RTNO b '
                     + 'where a.REEL_NO = :MATERIAL_NO AND A.RT_ID=B.RT_ID(+) '
                     + 'order by UPDATE_TIME desc ';
        QryWRReel.Params.ParamByName('MATERIAL_NO').AsString := editWRMaterial.Text;;
        QryWRReel.Open;
        if (QryWRReel.IsEmpty) or (QryWRReel.FieldByName('Type').AsString<>'O') then
        begin
          MessageDlg('Material No not exist!', mtError, [mbOK], 0);
          editWRMaterial.SelectAll;
          editWRMaterial.SetFocus;
          exit;
        end;
      end ;

      if QryWRReel.FieldByName('RT_NO').AsString<>'N/A' Then
      begin
        EditWRSource.Text:=QryWRReel.FieldByName('RT_NO').AsString;
        gbRTFlag:=True;
      end
      else if QryWRReel.FieldByName('REMARK').AsString<>'N/A' Then
      begin
        EditWRSource.Text:=QryWRReel.FieldByName('REMARK').AsString;
        gbRTFlag:=False;
      end;
      edtWRFIFO.Text:=QryWRReel.fieldbyname('FIFOCode').AsString;

      { 
      //check wo status
      QryWRReel.Close;
      QryWRReel.Params.Clear;
      QryWRReel.Params.CreateParam(ftString, 'work_order', ptInput);
      QryWRReel.CommandText := 'select wo_status,factory_id from sajet.g_wo_base '
        + 'where work_order = :work_order ';
      QryWRReel.Params.ParamByName('work_order').AsString := QryWRDetail.FieldByName('work_order').AsString;
      QryWRReel.Open;
      if QryWRReel.FieldByName('wo_status').AsString = '9' then
      begin
        MessageDlg('Work Order: ' + QryWRDetail.FieldByName('work_order').AsString + ' is complete no charge!', mtError, [mbOK], 0);
        editWRMaterial.SelectAll;
        editWRMaterial.SetFocus;
        QryWRReel.Close;
        exit;
      end;
      }

      {
      G_FCID:='';
      G_FCCODE:='';
      G_FCTYPE:='';
      editorg.Clear ;
      G_FCID:=QryWRReel.FieldByName('factory_id').AsString;
      if Getfctype(G_FCID)<>'OK' then
      begin
          editorg.Clear;
          exit;
      end
      else
         editorg.Text :=G_FCCODE;
       }


      sPartId := QryWRDetail.FieldByName('part_id').AsString;
      editWRPart.Text := QryWRDetail.FieldByName('part_no').AsString;
      edtWIRItem.Text := QryWRDetail.FieldByName('option7').AsString;
      lablWRMQty.Caption := QryWRDetail.FieldByName('qty').AsString;
      edtWRDateCode.Text := QryWRDetail.FieldByName('DateCode').AsString;
      edtWRVersion.Text := QryWRDetail.FieldByName('version').AsString;
      editWRWo.Text := QryWRDetail.FieldByName('work_order').AsString;
      edtWRRequest.Text := QryWRDetail.FieldByName('request_qty').AsString;
      edtWRIssue.Text := QryWRDetail.FieldByName('issue_qty').AsString;
      Result := True;
      lablWRType.Caption := QryWRDetail.FieldByName(gsLabelField).AsString;
      // 預設Loate 取sys_part table 中的值　
     // gsLocateid := QryWRDetail.FieldByName(gsLocateField).AsString;
      if lablWRType.Caption = '' then
        lablWRType.Caption := 'QTY ID';

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

Function TfDetail.CheckWIRMqty(WO:string;PART_NO:string):string;
begin
   with qrytemp do
   begin
       //確定料號在wo bom 中
       close;
       params.Clear ;
       params.CreateParam(ftstring,'work_order',ptinput);
       params.CreateParam(ftstring,'part_no',ptinput);
       commandtext:='select (B.REQUEST_QTY-B.ISSUE_QTY)*(-1) AS MAXQTY from sajet.sys_part a,sajet.g_wo_pick_list b '
                   +' where b.work_order=:WORK_ORDER AND A.PART_NO=:PART_NO '
                   +'  AND A.PART_ID=B.PART_ID AND ROWNUM=1 ';
       params.ParamByName('work_order').AsString :=wo;
       params.ParamByName('part_no').AsString :=part_no;
       open;
       if isempty then
       begin
          result:='Part No: '+part_no+' Not Find In The WO: '+WO;
          exit;
       end;
       lablWIRmqty.Caption :=fieldbyname('maxqty').AsString ;
       if sedtWIRqty.Value > fieldbyname('maxqty').AsInteger then
       begin
           result:='Qty Error Max(WO):'+lablWIRMQty.Caption ;
           exit;
       end;

       //確認料號在 document_number 中
       Close;
       Params.Clear;
       Params.CreateParam(ftString, 'part_no', ptInput);
       Params.CreateParam(ftString, 'document_number', ptInput);
       CommandText := 'SELECT A.ROWID, A.rc_wip_ID,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.SEQ_NUMBER, '
          +' A.PART_ID,A.APPLY_QTY,A.PRINT_QTY, '
          +' B.DOCUMENT_NUMBER,B.ISSUE_TYPE,B.ISSUE_TYPE_NAME,A.ORGANIZATION_ID,B.STATUS, '
          +' C.PART_NO,C.OPTION7,C.OPTION1,  '
          +' F.FACTORY_CODE,FACTORY_NAME '
          +' FROM SAJET.G_ERP_rc_wip_DETAIL A,SAJET.G_ERP_rc_wip_MASTER B,SAJET.SYS_PART C,'
          +' SAJET.SYS_FACTORY F  '
          +' WHERE B.DOCUMENT_NUMBER=:DOCUMENT_NUMBER  '
          +' and C.part_no=:part_no '
          +' AND A.rc_wip_ID=B.rc_wip_ID '
          +' AND A.ORGANIZATION_ID=B.ORGANIZATION_ID '
          +' AND A.PART_ID=C.PART_ID '
          +' AND B.ORGANIZATION_ID=F.FACTORY_ID '
          +' AND A.ENABLED=''Y''   '
          +' AND B.ENABLED=''Y''  '
          +' and rownum=1 ';
       Params.ParamByName('part_no').AsString := part_no;
       Params.ParamByName('document_number').AsString := edtwipscno.Text;
       Open;
       if isempty then
       begin
          result:='Part_No: ' + editWIRpart.Text +' Not in Document_Number:'+edtwipscno.Text;
          Exit;
       end;

       result:='OK' ;
   end;
end;

Function TfDetail.GetWIRPart(PART_NO:string):string;
var sLocate: string;
begin
   with qrytemp do
   begin
      close;
      params.Clear ;
      params.CreateParam(ftstring,'part_no',ptinput);
      commandtext:='select * from sajet.sys_part where part_no=:part_no and rownum=1 ';
      params.ParamByName('part_no').AsString:=part_no ;
      open;
      if isempty then
      begin
          result:='Part_no: '+part_no+' Not Find!';
          exit;
      end;
      close;
      params.Clear ;
      params.CreateParam(ftstring,'work_order',ptinput);
      params.CreateParam(ftstring,'part_no',ptinput);
      commandtext:='select b.work_order,a.part_no,a.part_id,b.request_qty,b.issue_qty ,a.version, a.option7,  '
                  + gsLabelField + ','  + gsLocateField  
                  +' from sajet.sys_part a,sajet.g_wo_pick_list b '
                  +' where b.work_order=:work_order and a.part_no=:part_no and a.part_id=b.part_id and rownum=1 ';
      params.ParamByName('work_order').AsString :=gsWO ;
      params.ParamByName('part_no').AsString :=part_no;
      open;
      if isempty then
      begin
          result:='Part_no: '+part_no+' Not Find In The WO: '+gsWO;
          exit;
      end;
      edtWIRrequest.Text :=fieldbyname('request_qty').AsString ;
      edtWIRissue.Text :=fieldbyname('issue_qty').AsString ;
      lablWIRmqty.Caption := inttostr(fieldbyname('request_qty').AsInteger * (-1) - fieldbyname('issue_qty').AsInteger*(-1) ) ;
      edtWIRversion.Text :=fieldbyname('version').AsString ;
      lablWIRType.Caption := FieldByName(gsLabelField).AsString;
      if lablWIRType.Caption = '' then
        lablWIRType.Caption := 'QTY ID';
     //check is not  request_qty >=0
     if fieldbyname('request_qty').AsString >='0' then
      begin
          result:='Part_no: '+part_no+' request_qty >=0 In Table(Sajet.g_wo_pick_list) !';
          exit;
      end;
      result:=fieldbyname('part_no').AsString ;
      edtWIRitem.Text :=fieldbyname('option7').AsString ;
      edtWIRpartid.Text :=fieldbyname('part_id').AsString ;

     // 預設Loate 取sys_part_factory table 中的值　change by key 2008/07/25 
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'part_id', ptInput);
      Params.CreateParam(ftString, 'factory_id', ptInput);
      CommandText := 'select locate_name, warehouse_name, b.warehouse_id, a.locate_id from sajet.sys_part_factory a, sajet.sys_locate b, sajet.sys_warehouse c '
               + 'where part_id = :part_id and a.locate_id = to_char(b.locate_id) and b.warehouse_id = c.warehouse_id and a.factory_id = :factory_id and rownum = 1';
      Params.ParamByName('part_id').AsString :=edtWIRpartid.Text;
      Params.ParamByName('factory_id').AsString :=G_FCID ;
      Open;
      gsLocateid := QryTemp.FieldByName('locate_id').AsString;
      close;

       //確認料號在 document_number 中 
       Close;
       Params.Clear;
       Params.CreateParam(ftString, 'part_no', ptInput);
       Params.CreateParam(ftString, 'document_number', ptInput);
       CommandText := 'SELECT A.ROWID, A.rc_wip_ID,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.SEQ_NUMBER, '
          +' A.PART_ID,A.APPLY_QTY,A.PRINT_QTY, '
          +' B.DOCUMENT_NUMBER,B.ISSUE_TYPE,B.ISSUE_TYPE_NAME,A.ORGANIZATION_ID,B.STATUS, '
          +' C.PART_NO,C.OPTION7,C.OPTION1,  '
          +' F.FACTORY_CODE,FACTORY_NAME '
          +' FROM SAJET.G_ERP_rc_wip_DETAIL A,SAJET.G_ERP_rc_wip_MASTER B,SAJET.SYS_PART C,'
          +' SAJET.SYS_FACTORY F  '
          +' WHERE B.DOCUMENT_NUMBER=:DOCUMENT_NUMBER  '
          +' and C.part_no=:part_no '
          +' AND A.rc_wip_ID=B.rc_wip_ID '
          +' AND A.ORGANIZATION_ID=B.ORGANIZATION_ID '
          +' AND A.PART_ID=C.PART_ID '
          +' AND B.ORGANIZATION_ID=F.FACTORY_ID '
          +' AND A.ENABLED=''Y''   '
          +' AND B.ENABLED=''Y''  '
          +' and rownum=1 ';
       Params.ParamByName('part_no').AsString := part_no;
       Params.ParamByName('document_number').AsString := edtwipscno.Text;
       Open;
       if isempty then
       begin
          //MessageDlg('Part_NO: ' + editpart.Text + #10#13+' Not in Document_Number:'+edtwipscno.Text, mtError, [mbOK], 0);
          result:='Part_No: ' + editWIRpart.Text +' Not in Document_Number:'+edtwipscno.Text;
          Exit;
       end;

      if gsLocateid <> '' then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'locate_id', ptInput);
        CommandText := 'select locate_name, warehouse_name, b.warehouse_id, locate_id from sajet.sys_locate b, sajet.sys_warehouse c '
          + 'where b.locate_id = :locate_id and b.warehouse_id = c.warehouse_id and rownum = 1';
        Params.ParamByName('locate_id').AsString := gsLocateid;
        Open;
        cmbWIRStock.ItemIndex := cmbWIRStock.Items.IndexOf(FieldByName('Warehouse_name').AsString);
        sLocate := FieldByName('locate_name').AsString;
        if cmbWIRStock.ItemIndex <> -1 then
        begin
          cmbWIRStockChange(Self);
          cmbWIRLocate.ItemIndex := cmbWIRLocate.Items.IndexOf(sLocate);
        end else
        begin
          cmbWIRStock.ItemIndex:=-1;
          cmbWIRLocate.ItemIndex:=-1;
        end;
      end else
      begin
          cmbWIRStock.ItemIndex:=-1;
          cmbWIRLocate.ItemIndex:=-1;
      end;
   end;
end;

function TfDetail.CheckWIMaterial: Boolean;
var iQty: Integer; iWmQty, iTemp: Real;
  sPartId, sType, sDateCode, OverRequest, sPartNo, sVersion, sStock, sLocate, sItemID,
  sISSUE_HEADER_ID,sissue_line_id,src_wip_ID,strmsg,
  sISSUE_TYPE,sISSUE_TYPE_NAME,sSEQ_NUMBER, sINVENTORY_ITEM_ID,
  //sSUBINV,sLOCATOR,
  sORG_ID : string;
begin
  Result := True;
  QryTemp.Close;
  QryTemp.Params.Clear;
  QryTemp.Params.CreateParam(ftString, 'material_no', ptInput);
  QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
  QryTemp.CommandText := 'select reel_no, material_no, part_no, b.VERSION, b.' + gsOverField + ', b.option7, b.part_type,a.factory_id '
    + 'from sajet.g_material a, sajet.sys_part b '
    + 'where (reel_no = :reel_no or material_no = :material_no) and rownum = 1 '
    + 'and a.part_id = b.part_id ';
  QryTemp.Params.ParamByName('material_no').AsString := edtWIMaterial.Text;
  QryTemp.Params.ParamByName('reel_no').AsString := edtWIMaterial.Text;
  QryTemp.Open;
  //check Material is not exist
  if QryTemp.IsEmpty then
  begin
      MessageDlg('ID No: ' + edtWIMaterial.Text + ' not found.', mtError, [mbOK], 0);
      Result := False;
      Exit;
  end

  //check Org
  else if QryTemp.FieldByName('factory_id').AsString <> G_FCID then
  begin
      MessageDlg('ID No: ' + edtWIMaterial.Text + ' ORG ID IS NOT '+editorg.Text , mtError, [mbOK], 0);
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
      if QryTemp.FieldByName('material_no').AsString = edtWIMaterial.Text then
        sType := 'Material'
      else
        sType := 'Reel';
  end;
  QryTemp.Close;
  QryTemp.Params.Clear;
  QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
  QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
  QryTemp.CommandText := 'select reel_no, reel_qty, material_no, material_qty, status, '
    + 'a.part_id, a.datecode,c.request_qty, d.warehouse_name, e.locate_name '
    + 'from sajet.g_material a, sajet.g_wo_pick_list c, sajet.sys_warehouse d, sajet.sys_locate e '
    + 'where ' + sType + '_No = :reel_no '
    + 'and a.locate_id = e.locate_id(+) and a.warehouse_id = d.warehouse_id(+) '
    + 'and a.part_id = c.part_id and c.work_order = :work_order';
  QryTemp.Params.ParamByName('reel_no').AsString := edtWIMaterial.Text;
  QryTemp.Params.ParamByName('work_order').AsString := gsWO;
  QryTemp.Open;
  if QryTemp.IsEmpty then
  begin
      MessageDlg('Cann''t use this Part - ' + sPartNo + '.', mtError, [mbOK], 0);
      Result := False;
      Exit;
  end;
  //add by key 2012/10/11
  //check is not Request_Qty < 0
  if QryTemp.FieldByName('request_qty').AsInteger < 0 then
  begin
      MessageDlg('Part_No: ' + sPartNo + ' Request_Qty < 0 In Table(Sajet.g_wo_pick_list) ', mtError, [mbOK], 0);
      Result := False;
      Exit;
  end;
  //check in stock 
  if QryTemp.FieldByName('warehouse_name').AsString = '' then
  begin
      MessageDlg('ID No: ' + edtWIMaterial.Text + ' not InStock.', mtError, [mbOK], 0);
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
      MessageDlg('ID No: ' + edtWIMaterial.Text + ' not InStock.', mtError, [mbOK], 0);
      Result := False;
  end
  else
  begin
    sPartId := QryTemp.FieldByName('part_id').AsString;
    giSequence :=edtwipscno.Text ; //add by key 2012/9/8
    { //不分批發料 limit by key 2012/9/8
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.Params.CreateParam(ftString, 'part_type', ptInput);
    QryTemp.CommandText := 'select max(sequence) seq, sum(pick_qty) qty from sajet.g_wo_pick_info a '
      + 'where work_order = :work_order and sequence like :part_type and work_flag <> ''N''';
    QryTemp.Params.ParamByName('work_order').AsString := gsWO;
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
    }
    {
    //不退超發 by key 2012/9/8
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.CommandText := 'select issue_qty, request_qty from sajet.g_wo_pick_list a '
      + 'where part_id = :part_id and work_order = :work_order ';
    QryTemp.Params.ParamByName('part_id').AsString := sPartId;
    QryTemp.Params.ParamByName('work_order').AsString := gsWO;
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
    }

    //發料單限制WO超發  //add by key 2012/9/14
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.CommandText := 'select issue_qty, request_qty from sajet.g_wo_pick_list a '
      + 'where part_id = :part_id and work_order = :work_order ';
    QryTemp.Params.ParamByName('part_id').AsString := sPartId;
    QryTemp.Params.ParamByName('work_order').AsString := gsWO;
    QryTemp.Open;
    if gsIssueType = '1' then  // 發料單 SFC  限制不可以超發
    begin
        if (OverRequest = 'NO') or (OverRequest = 'TPS-NO') then
        begin
            if QryTemp.FieldByName('issue_qty').AsInteger + iQty - QryTemp.FieldByName('request_qty').AsInteger  > 0 then
            begin
                MessageDlg('Part: ' + sPartNo + ' - Over Request Qty(WO).', mtError, [mbOK], 0);
                Result := False;
                Exit;
            end;
        end;
    end;


    //限制超發   add by key 2012/9/8
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.Params.CreateParam(ftString, 'document_number', ptInput);
    //QryTemp.Params.CreateParam(ftString, 'qty', ptInput);
    QryTemp.CommandText := 'SELECT A.ROWID, A.rc_wip_ID,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.SEQ_NUMBER, '
          +' A.PART_ID,A.APPLY_QTY,A.PRINT_QTY, '
          +' B.DOCUMENT_NUMBER,B.ISSUE_TYPE,B.ISSUE_TYPE_NAME,A.ORGANIZATION_ID,B.STATUS, '
          +' C.PART_NO,C.OPTION7,C.OPTION1,  '
          +' F.FACTORY_CODE,FACTORY_NAME '
          +' FROM SAJET.G_ERP_rc_wip_DETAIL A,SAJET.G_ERP_rc_wip_MASTER B,SAJET.SYS_PART C,'
          +' SAJET.SYS_FACTORY F  '
          +' WHERE B.DOCUMENT_NUMBER=:DOCUMENT_NUMBER  '
          +' and a.part_id=:part_id '
          +' AND A.rc_wip_ID=B.rc_wip_ID '
          +' AND A.ORGANIZATION_ID=B.ORGANIZATION_ID '
          +' AND A.PART_ID=C.PART_ID '
          +' AND B.ORGANIZATION_ID=F.FACTORY_ID '
          +' AND A.ENABLED=''Y''   '
          +' AND B.ENABLED=''Y''  '
          +' and rownum=1 ';
    QryTemp.Params.ParamByName('part_id').AsString := sPartId;
    QryTemp.Params.ParamByName('document_number').AsString := edtwipscno.Text;
    //QryTemp.Params.ParamByName('qty').AsInteger := iQty;
    QryTemp.Open;
    {  //不限不超發 limit by key 2012/9/8 
    if QryTemp.isempty then
    begin
          MessageDlg('Part: ' + sPartNo + ' - Over Request. ', mtError, [mbOK], 0);
          Result := False;
          Exit;
    end;
    }

    //check part_no is not in document_number
    if QryTemp.isempty then
    begin
          MessageDlg('Part_No: ' + sPartNo + #10#13+' Not in document_number:'+edtwipscno.Text, mtError, [mbOK], 0);
          Result := False;
          Exit;
    end;
    src_wip_ID := QryTemp.FieldByName('rc_wip_ID').AsString;
    sissue_line_id := QryTemp.FieldByName('issue_line_id').AsString;
    sISSUE_HEADER_ID := QryTemp.FieldByName('ISSUE_HEADER_ID').AsString;
    sISSUE_TYPE := QryTemp.FieldByName('ISSUE_TYPE').AsString;
    sISSUE_TYPE_NAME := QryTemp.FieldByName('ISSUE_TYPE_NAME').AsString;
    sSEQ_NUMBER := QryTemp.FieldByName('SEQ_NUMBER').AsString;
    sINVENTORY_ITEM_ID := QryTemp.FieldByName('OPTION7').AsString;
    sORG_ID  := QryTemp.FieldByName('FACTORY_CODE').AsString;

    //insert into mes_to_erp_rc_wip   add by key 2012/9/8
    with sproc do
     begin
          try
            Close;
            DataRequest('SAJET.MES_ERP_RC_WIP');
            FetchParams;
            Params.ParamByName('TDOCUMENT_NUMBER').AsString := edtwipscno.Text;
            Params.ParamByName('TWIP_ENTITY_NAME').AsString := gsWO;
            Params.ParamByName('TISSUE_HEADER_ID').AsString := sISSUE_HEADER_ID;
            Params.ParamByName('TISSUE_LINE_ID').AsString := sissue_line_id;
            Params.ParamByName('TISSUE_TYPE').AsString := sISSUE_TYPE;
            Params.ParamByName('TISSUE_TYPE_NAME').AsString := sISSUE_TYPE_NAME;
            Params.ParamByName('TSEQ_NUMBER').AsString := sSEQ_NUMBER;
            Params.ParamByName('TINVENTORY_ITEM_ID').AsString :=sINVENTORY_ITEM_ID;
            Params.ParamByName('TSUBINV').AsString := sStock;
            Params.ParamByName('TLOCATOR').AsString := sLocate;
            Params.ParamByName('TMATERIAL_NO').AsString := edtWIMaterial.Text;
            Params.ParamByName('TQTY').AsInteger := iQty;
            Params.ParamByName('TCREATE_USERID').AsString := UpdateUserID;
            Params.ParamByName('TISSUE_USER').AsString :=edtWIissueuser.Text;
            Params.ParamByName('TORG_ID').AsString := sORG_ID;
            Params.ParamByName('Ttype_class').AsString :=gstypeclass;
            Params.ParamByName('TPUSH').AsString := 'N';
            Params.ParamByName('TTRXNTYPE').AsString := 'D2'; //D2 工單發料
            Params.ParamByName('TRECORD_STATUS').AsString :='';  
            Execute;

            strmsg:=PARAMS.PARAMBYNAME('TRES').AsString;
            if strmsg<>'OK' then
            begin
              MessageDlg('UPDATE SAJET.MES_ERP_RC_WIP ERROR '+#13#13
                      + STRMSG , mtError, [mbOK], 0);
              Result := False;
              Exit;
            end;
          finally
            close;
          end;
     end;
     QryTemp.Close;
     QryTemp.Params.Clear;
     QryTemp.Params.CreateParam(ftString, 'DOCUMENT', ptInput);
     QryTemp.Params.CreateParam(ftString, 'material_no', ptInput);
     QryTemp.CommandText := 'SELECT * FROM SAJET.MES_TO_ERP_RC_WIP WHERE DOCUMENT_NUMBER =:DOCUMENT AND MATERIAL_NO =:material_no ';
     QryTemp.Params.ParamByName('DOCUMENT').AsString := edtwipscNo.Text;
     QryTemp.Params.ParamByName('material_no').AsString := edtWIMaterial.Text;
     QryTemp.Open;

     if QryTemp.ISEMPTY THEN begin
         MessageDlg('INSERT  SAJET.MES_ERP_RC_WIP ERROR '+#13#13
                       , mtError, [mbOK], 0);
         Result := False;
         Exit;

     end;


     //----------------------------------------------------------------------------------------------------------------------------------------
    //insert into sajet.g_pick_list
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
    QryTemp.Params.ParamByName('work_order').AsString := gsWO;
    QryTemp.Params.ParamByName('update_userid').AsString := UpdateUserid;
    QryTemp.Params.ParamByName('sequence').AsString := giSequence;
    QryTemp.Params.ParamByName('material_no').AsString := edtWIMaterial.Text;
    QryTemp.Execute;
    QryTemp.Close;
    { // 更改成 SAJET.MES_ERP_rc_wip by key 2012/9/8
    with sproc do
    begin
      try
        Close;
        DataRequest('SAJET.MES_ERP_WIP_ISSUE');
        FetchParams;
        Params.ParamByName('TWO').AsString := gsWO;
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
    }

    //發料單 update sajet.g_wo_pick_list
    if  gsIssueType='1' then
    begin
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
        QryTemp.Params.ParamByName('work_order').AsString := gsWO;
        QryTemp.Execute;
        QryTemp.Close;
    end;

    //補料單和非生產性補料單 update sajet.g_wo_pick_list
    if  gsIssueType<>'1' then
    begin
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
        QryTemp.Params.ParamByName('work_order').AsString := gsWO;
        QryTemp.Params.ParamByName('QTY').AsInteger := iQty;
        QryTemp.Params.ParamByName('QTY1').AsInteger := iQty;
        QryTemp.Execute;
        QryTemp.Close;
    end;

    { //工單不分連打 limit by key 2012/9/8 
    if iWmQty > 0 then
      UpdateWM(sPartID, gsGroupWo, iWmQty);
    }
    { //不寫 sajet.g_wo_pick_info  資料 limit by key 2012/9/8
    if (sedtQty.Enabled) or ((sedtQty.Value = 0) and (QryMaterial.IsEmpty)) then
    begin
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
      QryTemp.Params.CreateParam(ftString, 'pick_qty', ptInput);
      QryTemp.Params.CreateParam(ftString, 'sequence', ptInput);
      QryTemp.CommandText := 'insert into sajet.g_wo_pick_info '
        + '(work_order, pick_qty, sequence, add_userid, add_time) '
        + 'values (:work_order, :pick_qty, :sequence, '''+UpdateUserid+''', sysdate)';
      QryTemp.Params.ParamByName('work_order').AsString := gsWO;
      QryTemp.Params.ParamByName('pick_qty').AsString := sedtQty.Text;
      QryTemp.Params.ParamByName('sequence').AsString := giSequence;
      QryTemp.Execute;
      sedtQty.Enabled := False;
      sbtnCheck.Enabled := True;
    end;
    }

    //update g_material
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
    QryTemp.Params.ParamByName('reel_no').AsString := edtWIMaterial.Text;
    QryTemp.Params.ParamByName('userid').AsString := UpdateUserid;
    QryTemp.Execute;

    //insert into g_ht_material
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
    if sType = 'Reel' then
      QryTemp.CommandText := 'insert into sajet.g_ht_material '
        + 'select * from sajet.g_material where reel_no = :reel_no  '
    else
      QryTemp.CommandText := 'insert into sajet.g_ht_material '
        + 'select * from sajet.g_material where material_no = :reel_no  ';
    QryTemp.Params.ParamByName('reel_no').AsString := edtWIMaterial.Text;
    QryTemp.Execute;

    //delete g_material 
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
    if sType = 'Reel' then
      QryTemp.CommandText := 'delete from sajet.g_material '
        + 'where reel_no = :reel_no '
    else
      QryTemp.CommandText := 'delete from sajet.g_material '
        + 'where material_no = :reel_no ';
    QryTemp.Params.ParamByName('reel_no').AsString := edtWIMaterial.Text;
    QryTemp.Execute;
    QryTemp.Close;
    //PartQty := iQty;  //limit by key 2012/9/8

    //update g_erp_rc_wip_detail add by key 2012/9/8
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftInteger, 'QTY', ptInput);
    QryTemp.Params.CreateParam(ftString, 'rc_wip_ID', ptInput);
    QryTemp.Params.CreateParam(ftString, 'issue_line_id', ptInput);
    QryTemp.CommandText := 'update SAJET.G_ERP_rc_wip_DETAIL '
      + 'set PRINT_QTY = PRINT_QTY + :QTY '
      + 'where rc_wip_ID = :rc_wip_ID and issue_line_id = :issue_line_id AND rownum=1 ';
    QryTemp.Params.ParamByName('QTY').AsInteger := iQty;
    QryTemp.Params.ParamByName('rc_wip_ID').AsString := src_wip_ID;
    QryTemp.Params.ParamByName('issue_line_id').AsString := sissue_line_id;
    QryTemp.Execute;
    QryTemp.Close;
   //----------------------------------------------------------------------------------------------------------------------------------------

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
        Params.ParamByName('empid').AsString := UpdateUserID;
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

procedure TfDetail.ShowData(sLocate: string);
var sSQL: string;  bPrinted: Boolean;
begin
  //show MES_TO_ERP_RC_WIP
  with QryMaterial do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
    CommandText := ' SELECT A.WIP_ENTITY_NAME,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.ISSUE_TYPE,A.ISSUE_TYPE_NAME,A.SEQ_NUMBER,A.INVENTORY_ITEM_ID, '
                  +' A.SUBINV,A.LOCATOR,A.MATERIAL_NO,A.QTY, A.CREATE_TIME,A.CREATE_USERID,A.ORG_ID, '
                  +' B.PART_NO,C.EMP_NO||''-''||C.EMP_NAME AS CREATE_USER,ISSUE_USER  '
                  +' FROM  SAJET.MES_TO_ERP_rc_wip A,SAJET.SYS_PART B,SAJET.SYS_EMP C '
                  +' WHERE  A.DOCUMENT_NUMBER=:DOCUMENT_NUMBER '
                  +'  AND A.INVENTORY_ITEM_ID = B.OPTION7 '
                  +'  AND A.CREATE_USERID = C.EMP_ID '
                   +'   ORDER BY B.PART_NO ASC,A.MATERIAL_NO ASC ';
                 // +'   ORDER BY A.SEQ_NUMBER,B.PART_NO,A.CREATE_TIME ';
    Params.ParamByName('DOCUMENT_NUMBER').AsString :=edtwipscno.Text;
    Open;
  end;


  //show G_ERP_RC_WIP_MASTER AND G_ERP_RC_WIP_DETAIL 
  sSQL := ' SELECT A.ROWID, A.RC_WIP_ID,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.SEQ_NUMBER,  '
          +' A.PART_ID,A.APPLY_QTY,A.PRINT_QTY,A.SUBINVENTORY,A.LOCATOR,  '
          +' B.DOCUMENT_NUMBER,B.WIP_ENTITY_NAME,B.ISSUE_TYPE,B.ISSUE_TYPE_NAME,A.ORGANIZATION_ID,B.STATUS,B.TYPE_CLASS,  '
          +' C.PART_NO,C.OPTION7,C.OPTION1,    '
          +' E.FACTORY_CODE,E.FACTORY_NAME     '
          +' FROM SAJET.G_ERP_RC_WIP_DETAIL A,SAJET.G_ERP_RC_WIP_MASTER B,SAJET.SYS_PART C,SAJET.SYS_FACTORY E    '
          +' WHERE B.DOCUMENT_NUMBER=:DOCUMENT_NUMBER  '
          +' AND  A.RC_WIP_ID=B.RC_WIP_ID  '
          +' AND A.WIP_ENTITY_NAME = B.WIP_ENTITY_NAME '
          +' AND A.ORGANIZATION_ID=B.ORGANIZATION_ID  '
          +' AND A.PART_ID=C.PART_ID '
          +' AND B.ORGANIZATION_ID=E.FACTORY_ID  '
          +' AND A.ENABLED=''Y''  '
          +' AND B.ENABLED=''Y''  '
          +' ORDER BY C.PART_NO ASC  ';
          //+' ORDER BY A.SEQ_NUMBER  ';
  with QryDetail do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
    CommandText := sSQL;
    Params.ParamByName('DOCUMENT_NUMBER').AsString := edtwipscno.Text;
    Open;
    if IsEmpty then begin
      MessageDlg('WIP No: ' + edtwipscno.Text + ' not found.', mtError, [mbOK], 0);
      edtwipscno.SelectAll;
      edtwipscno.SetFocus;
      Exit;
    end;
    bPrinted := True;
    G_FCID:='';
    G_FCCODE:='';
    G_FCTYPE:='';
    editorg.Clear ;
    G_FCID:=fieldbyname('ORGANIZATION_ID').AsString;
    if Getfctype(G_FCID)<>'OK' then
    begin
        editorg.Clear;
        exit;
    end
    else
       editorg.Text :=G_FCCODE;
    {
    while not Eof do begin
     if FieldByName('APPLY_QTY').AsInteger > FieldByName('PRINT_QTY').AsInteger then
      begin
        bPrinted := False;
        break;
      end;
      Next;
    end;
    }
    //保持原有rowid locate
    if sLocate <> '' then
     // Locate('RowId', sLocate, []);
      Locate('Part_NO', sLocate, []);

    if  FieldByName('status').AsInteger=2 then //had confirm
    begin
       sbtncheck.Enabled :=false;
       edtwipscno.Enabled :=true;
       showmessage('The source had confirm!') ;
       exit;
    end;
    if  FieldByName('status').AsInteger=1 then //had check
    begin
       sbtncheck.Enabled :=false;
       edtwipscno.Enabled :=true;
       showmessage('The source had check!') ;
       exit;
    end;
    if  FieldByName('status').AsInteger=0 then //NOT check or confirm
    begin
       sbtncheck.Enabled :=true;
       edtwipscno.Enabled :=false;
    end;

    gsWO:=fieldbyname('WIP_ENTITY_NAME').AsString;
    gsTypeClass:=fieldbyname('TYPE_CLASS').AsString;
    gsIssueType:=fieldbyname('ISSUE_TYPE').AsString;
    gsStatus:=FieldByName('status').AsString;
  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var PIni: TIniFile;
begin
  slWIRLocateId := TStringList.Create;
  slWIRStockId := TStringList.Create;
  slWRLocateId := TStringList.Create;
  slWRStockId := TStringList.Create;
  sbtncheck.Enabled:=false;
  PIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Material.Ini');
  gsBoxField := PIni.ReadString('Material', 'Material Default Qty Field', 'OPTION5');
  gsReelField := PIni.ReadString('Material', 'Reel Default Qty Field', 'OPTION6');
  PIni.Free;
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  edtwipscno.SetFocus;
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
    Params.ParamByName('dll_name').AsString := 'RCWIPCHECK.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
   { Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Label Type'' ';
    Open;
    gsLabelField := FieldByName('param_name').AsString;
    Close;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Qty Field'' ';
    Open;
    gsBoxField := FieldByName('param_value').AsString;
    Close;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Reel Qty Field'' ';
    Open;
    gsReelField := FieldByName('param_value').AsString;
    }
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Over Request'' ';
    Open;
    gsOverField := FieldByName('param_name').AsString;
    close;
    if not IsEmpty then begin
      edtwipscno.CharCase := ecUpperCase;
      edtWIissueuser.CharCase :=ecuppercase;
      edtWImaterial.CharCase :=ecuppercase;
    end;
  end;
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
    //入庫權限受管控　2008/10/14 by key 
    CommandText := 'select a.warehouse_id, a.warehouse_name '
      + 'from sajet.sys_warehouse a  ,sajet.sys_emp_warehouse b '
      + ' where a.warehouse_id=b.warehouse_id and B.EMP_ID='''+UpdateUserID+''' '
      + ' AND a.enabled = ''Y'' and b.enabled=''Y'' order by a.warehouse_name';
    Open;
    while not Eof do
    begin
      slWIRStockId.Add(FieldByName('warehouse_id').AsString);
      cmbWIRStock.Items.Add(FieldByName('warehouse_name').AsString);
      slWRStockId.Add(FieldByName('warehouse_id').AsString);
      cmbWRStock.Items.Add(FieldByName('warehouse_name').AsString);
      Next;
    end;
    Close;
  end;

  DateTimePickerWIR.DateTime:=now();
  edtWIRFifo.text:=GetFIFOCode(now());
end;

procedure TfDetail.edtWipscNOKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
    ShowData('');
end;

procedure TfDetail.DataSource2DataChange(Sender: TObject; Field: TField);
var iTemp: Integer;
begin
  {
  with QryMaterial do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
    CommandText := ' SELECT A.WIP_ENTITY_NAME,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.ISSUE_TYPE,A.ISSUE_TYPE_NAME,A.SEQ_NUMBER,A.INVENTORY_ITEM_ID, '
                  +' A.SUBINV,A.LOCATOR,A.MATERIAL_NO,A.QTY, A.CREATE_TIME,A.CREATE_USERID,A.ORG_ID, '
                  +' B.PART_NO,C.EMP_NO||''-''||C.EMP_NAME AS CREATE_USER,ISSUE_USER  '
                  +' FROM  SAJET.MES_TO_ERP_rc_wip A,SAJET.SYS_PART B,SAJET.SYS_EMP C '
                  +' WHERE  A.DOCUMENT_NUMBER=:DOCUMENT_NUMBER '
                  +'  AND A.INVENTORY_ITEM_ID = B.OPTION7 '
                  +'  AND A.CREATE_USERID = C.EMP_ID '
                  +'   ORDER BY A.SEQ_NUMBER,B.PART_NO,A.CREATE_TIME ';
    Params.ParamByName('DOCUMENT_NUMBER').AsString :=QryDetail.FieldByName('DOCUMENT_NUMBER').AsString;
    Open;
  end;
  }
end;

{
procedure TfDetail.sbtnMaterialClick(Sender: TObject);
var sMaterial, sPrintData: string; i, iTemp, iMod: Integer; bOver: Boolean;
begin
  if not QryDetail.Active then Exit;
  if QryDetail.IsEmpty then Exit;
  if trim(editorg.Text)='' then
  begin
    MessageDlg('ORG IS NULL', mtError, [mbOK], 0);
    Exit;
  end;

  ShowData(QryDetail.FieldByName('RowId').AsString);
end;
}
procedure TfDetail.sbtnWIRprintClick(Sender: TObject);
  procedure InsertWIRMaterial(sPartId: string);
  var sMaterial, sPrintData: string;
      iCnt : Integer;
      src_wip_ID,sissue_line_id,sISSUE_HEADER_ID,sISSUE_TYPE,sISSUE_TYPE_NAME,
      sSEQ_NUMBER, sINVENTORY_ITEM_ID,sORG_ID,strmsg:string;
  begin
    //限制超發   add by key 2012/9/8 
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.Params.CreateParam(ftString, 'document_number', ptInput);
    QryTemp.CommandText := 'SELECT A.ROWID, A.rc_wip_ID,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.SEQ_NUMBER, '
          +' A.PART_ID,A.APPLY_QTY,A.PRINT_QTY, '
          +' B.DOCUMENT_NUMBER,B.ISSUE_TYPE,B.ISSUE_TYPE_NAME,A.ORGANIZATION_ID,B.STATUS, '
          +' C.PART_NO,C.OPTION7,C.OPTION1,  '
          +' F.FACTORY_CODE,FACTORY_NAME '
          +' FROM SAJET.G_ERP_rc_wip_DETAIL A,SAJET.G_ERP_rc_wip_MASTER B,SAJET.SYS_PART C,'
          +' SAJET.SYS_FACTORY F  '
          +' WHERE B.DOCUMENT_NUMBER=:DOCUMENT_NUMBER  '
          +' and a.part_id=:part_id '
          +' AND A.rc_wip_ID=B.rc_wip_ID '
          +' AND A.ORGANIZATION_ID=B.ORGANIZATION_ID '
          +' AND A.PART_ID=C.PART_ID '
          +' AND B.ORGANIZATION_ID=F.FACTORY_ID '
          +' AND A.ENABLED=''Y''   '
          +' AND B.ENABLED=''Y''  '
          +' and rownum=1 ';
    QryTemp.Params.ParamByName('part_id').AsString := sPartId;
    QryTemp.Params.ParamByName('document_number').AsString := edtwipscno.Text;
    QryTemp.Open;
    //check part_no is not in Document_Number
    if QryTemp.isempty then
    begin
          MessageDlg('Part: ' + editWIRpart.Text + #10#13+' Not in Document_Number:'+edtwipscno.Text, mtError, [mbOK], 0);
          Exit;
    end;
    //限超退 limit by key 2012/9/12
    if QryTemp.FieldByName('APPLY_QTY').AsInteger - QryTemp.FieldByName('PRINT_QTY').AsInteger  < sedtWIRQty.Value then
    begin
        MessageDlg('Part: ' + editWIRpart.Text + ' - Over Request(DN). ', mtError, [mbOK], 0);
        Exit;
    end;
    src_wip_ID := QryTemp.FieldByName('rc_wip_ID').AsString;
    sissue_line_id := QryTemp.FieldByName('issue_line_id').AsString;
    sISSUE_HEADER_ID := QryTemp.FieldByName('ISSUE_HEADER_ID').AsString;
    sISSUE_TYPE := QryTemp.FieldByName('ISSUE_TYPE').AsString;
    sISSUE_TYPE_NAME := QryTemp.FieldByName('ISSUE_TYPE_NAME').AsString;
    sSEQ_NUMBER := QryTemp.FieldByName('SEQ_NUMBER').AsString;
    sINVENTORY_ITEM_ID := QryTemp.FieldByName('OPTION7').AsString;
    sORG_ID  := QryTemp.FieldByName('FACTORY_CODE').AsString;

    with QryTemp do
    begin
        //get material id
        Close;
        Params.Clear;
        CommandText := 'select sajet.to_label(''' + lablWIRType.Caption + ''', ''' + gsWO + ''') SNID from dual';
        Open;
        sMaterial := FieldByName('SNID').AsString;

       //insert into mes_to_erp_rc_wip   add by key 2012/9/8
        with sproc do
        begin
            try
                Close;
                DataRequest('SAJET.MES_ERP_RC_WIP');
                FetchParams;
                Params.ParamByName('TDOCUMENT_NUMBER').AsString := edtwipscno.Text;
                Params.ParamByName('TWIP_ENTITY_NAME').AsString := gsWO;
                Params.ParamByName('TISSUE_HEADER_ID').AsString := sISSUE_HEADER_ID;
                Params.ParamByName('TISSUE_LINE_ID').AsString := sissue_line_id;
                Params.ParamByName('TISSUE_TYPE').AsString := sISSUE_TYPE;
                Params.ParamByName('TISSUE_TYPE_NAME').AsString := sISSUE_TYPE_NAME;
                Params.ParamByName('TSEQ_NUMBER').AsString := sSEQ_NUMBER;
                Params.ParamByName('TINVENTORY_ITEM_ID').AsString :=sINVENTORY_ITEM_ID;
                Params.ParamByName('TSUBINV').AsString := cmbWIRStock.Text;
                Params.ParamByName('TLOCATOR').AsString := cmbWIRLocate.Text;
                Params.ParamByName('TMATERIAL_NO').AsString := sMaterial;
                Params.ParamByName('TQTY').AsInteger := sedtWIRQty.Value;
                Params.ParamByName('TCREATE_USERID').AsString := UpdateUserID;
                Params.ParamByName('TISSUE_USER').AsString :=edtWIRissueuser.Text;
                Params.ParamByName('TORG_ID').AsString := sORG_ID;
                Params.ParamByName('Ttype_class').AsString :=gstypeclass;
                Params.ParamByName('TPUSH').AsString := 'N';
                Params.ParamByName('TTRXNTYPE').AsString := 'D5'; //D5 工單異常退料
                Params.ParamByName('TRECORD_STATUS').AsString :='';  
                Execute;

                strmsg:=PARAMS.PARAMBYNAME('TRES').AsString;
                if strmsg<>'OK' then
                begin
                  MessageDlg('INSERT SAJET.MES_ERP_RC_WIP ERROR '+#13#13
                          + STRMSG , mtError, [mbOK], 0);
                  Exit;
                end;
            finally
               close;
            end;
        end;

         Close;
         Params.Clear;
         Params.CreateParam(ftString,'DOCUMENT',ptInput) ;
         Params.CreateParam(ftString,'MATERRIAL',ptInput) ;
         CommandText := 'SELECT * FROM SAJET.MES_TO_ERP_RC_WIP WHERE DOCUMENT_NUMBER =:DOCUMENT AND MATERIAL_NO =:MATERRIAL ';
         Params.ParamByName('DOCUMENT').AsString :=  edtwipscno.Text;
         Params.ParamByName('MATERRIAL').AsString := sMaterial;
         Open;

         if IsEmpty then begin
             MessageDlg('INSERT SAJET.MES_ERP_RC_WIP ERROR '+#13#13
                         , mtError, [mbOK], 0);
             Exit;

         end;

          //update sajet.g_wo_pick_list
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'qty', ptInput);
          Params.CreateParam(ftString, 'work_order', ptInput);
          Params.CreateParam(ftString, 'part_id', ptInput);
          Params.CreateParam(ftString, 'qty1', ptInput);
          CommandText := 'update sajet.g_wo_pick_list '
            + 'set issue_qty = issue_qty + :qty,AB_RETURN_QTY=AB_RETURN_QTY+:qty1 '
            + 'where work_order = :work_order and part_id = :part_id ';
          Params.ParamByName('qty').AsInteger := -1 * sedtWIRQty.Value;
          Params.ParamByName('work_order').AsString := gsWO;
          Params.ParamByName('part_id').AsString := sPartId;
          Params.ParamByName('qty1').AsInteger := sedtWIRQty.Value;
          Execute;
          //insert into sajet.g_material
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'PART_ID', ptInput);
          Params.CreateParam(ftString, 'datecode', ptInput);
          Params.CreateParam(ftString, 'material_no', ptInput);
          Params.CreateParam(ftString, 'material_qty', ptInput);
          Params.CreateParam(ftString, 'update_userid', ptInput);
          Params.CreateParam(ftString, 'warehouse_id', ptInput);
          Params.CreateParam(ftString, 'locate_id', ptInput);
          Params.CreateParam(ftString, 'REMARK', ptInput);
          Params.CreateParam(ftString, 'version', ptInput);
          Params.CreateParam(ftString, 'FIFO', ptInput);
          Params.CreateParam(ftString, 'FACTORY_ID', ptInput);
          Params.CreateParam(ftString, 'FACTORY_TYPE', ptInput);
          CommandText := 'insert into sajet.g_material '
            + '(part_id, datecode, material_no, material_qty, update_userid, warehouse_id, locate_id, update_time, status, REMARK, version,FIFOCode,FACTORY_ID,FACTORY_TYPE) '
            + 'values (:part_id, :datecode, :material_no, :material_qty, :update_userid, :warehouse_id, :locate_id, sysdate, 1,:REMARK, :version,:FIFO,:FACTORY_ID,:FACTORY_TYPE)';
          Params.ParamByName('PART_ID').AsString := sPartId;
          Params.ParamByName('datecode').AsString := edtWIRDateCode.Text;
          Params.ParamByName('material_no').AsString := sMaterial;
          Params.ParamByName('material_qty').AsString := sedtWIRQty.Text;
          Params.ParamByName('update_userid').AsString := UpdateUserID;
          Params.ParamByName('warehouse_id').AsString := slWIRStockId[cmbWIRStock.ItemIndex];
          if cmbWIRLocate.ItemIndex <> -1 then
            Params.ParamByName('locate_id').AsString := slWIRLocateId[cmbWIRLocate.ItemIndex]
          else
            Params.ParamByName('locate_id').AsString := '';

          Params.ParamByName('REMARK').AsString := gsWO;
          Params.ParamByName('version').AsString := edtWIRVersion.Text;
          Params.ParamByName('FIFO').AsString := edtWIRFIFO.Text;
          Params.ParamByName('FACTORY_ID').AsString := G_FCID;
          Params.ParamByName('FACTORY_TYPE').AsString := G_FCTYPE;
          Execute;
          //insert into sajet.g_ht_material
          Close;
          Params.CreateParam(ftString, 'material_no', ptInput);
          commandtext:=' insert into sajet.g_ht_material '
                      +' select * from sajet.g_material where material_no =:material_no ';
          Params.ParamByName('material_no').AsString := sMaterial;
          Execute;

          {
          with sproc do
          begin
            try
              Close;
              DataRequest('SAJET.MES_ERP_WIP_RETURN');
              FetchParams;
              Params.ParamByName('TWO').AsString := gsWO;
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
          }

        //update g_erp_rc_wip_detail add by key 2012/9/8
        QryTemp.Close;
        QryTemp.Params.Clear;
        QryTemp.Params.CreateParam(ftInteger, 'QTY', ptInput);
        QryTemp.Params.CreateParam(ftString, 'rc_wip_ID', ptInput);
        QryTemp.Params.CreateParam(ftString, 'issue_line_id', ptInput);
        QryTemp.CommandText := 'update SAJET.G_ERP_rc_wip_DETAIL '
          + 'set PRINT_QTY = PRINT_QTY + :QTY '
          + 'where rc_wip_ID = :rc_wip_ID and issue_line_id = :issue_line_id AND rownum=1 ';
        //QryTemp.Params.ParamByName('QTY').AsInteger := iQty;
        QryTemp.Params.ParamByName('QTY').AsInteger := sedtWIRQty.Value;
        QryTemp.Params.ParamByName('rc_wip_ID').AsString := src_wip_ID;
        QryTemp.Params.ParamByName('issue_line_id').AsString := sissue_line_id;
        QryTemp.Execute;
        QryTemp.Close;

       //print material lable
        sPrintData := G_getPrintData(6, 17, G_sockConnection, 'DspQryData', lablWIRType.Caption + '*&*' + sMaterial, 1, 'DEFAULT');
        if assigned(G_onTransDataToApplication) then
            G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
        else
            showmessage('Not Defined Call Back Function for Code Soft');
          lablWIRMsg.Caption := 'Return OK, New ID: ' + sMaterial + '.';
    end;
  end;
var sType, sPartId: string;
var strwo,strpart:string;
begin
  if gsTypeClass <>'R' then  //發補料
  begin
       MessageDlg('This IS Return Type Class [R]', mtError, [mbOK], 0);
       exit;
  end;
  //check Document Number status //0:正常 ; 1：had check ; 2: had confirm .
  if not CheckWipMsterStatus then exit;
  //check wo
  if not CheckWO then exit;

  if sedtWIRQty.Value <= 0 then Exit;
 // if (cmbStock.Text = '') or ((cmbLocate.Items.Count > 0) and (cmbLocate.ItemIndex = -1)) then
  if cmbWIRLocate.ItemIndex = -1  then
  begin
    MessageDlg('Please select Locator!', mtWarning, [mbOK], 0);
    Exit;
  end;
  if sedtWIRQty.Value>StrToIntDef(lablWIRMQty.Caption,0) then
  begin
    MessageDlg('Qty Error Max:'+lablWIRMQty.Caption, mtWarning, [mbOK], 0);
    Exit;
  end;

  if (editWIRpart.Enabled =true) or (editWIRpart.Text ='' ) then
  begin
      editWIRpart.SelectAll ;
      editWIRpart.SetFocus ;
      lablWIRmsg.Caption :='Please Input Part NO!';
      exit;
  end;

  IF   CheckWIRMqty(gsWO,editWIRpart.Text)='OK' then
    InsertWIRMaterial(edtWIRpartid.Text)
  else
  begin
      lablWIRmsg.Caption :=CheckWIRMqty(gsWO,editWIRpart.Text);
      exit;
  end;

  gslpartno:=editWIRPart.Text;
  
  editWIRPart.Text := '';
  sedtWIRQty.Text := '0';
  edtWIRDateCode.Text := '';
  lablWIRMQty.Caption := '';
  cmbWIRStock.ItemIndex := -1;
  cmbWIRLocate.Items.Clear;
  edtWIRVersion.Text := '';
  edtWIRRequest.Text := '';
  edtWIRIssue.Text := '';
  //editWIRpart.Enabled :=TRUE;

  DateTimePickerWIR.DateTime:=now();
  edtWIRFifo.text:=GetFIFOCode(now());
  //顯示所有數據
  //ShowData(QryDetail.FieldByName('RowId').AsString);
  ShowData(gslpartno);
end;


procedure TfDetail.sbtnMISCClick(Sender: TObject);
var Key: Char;
begin
  with TfCommData.Create(Self) do
  begin
    LabType2.Caption := 'WIP No List';
    LabType1.Caption := LabType2.Caption;
    Label1.Caption := 'Search WIP No';
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
      CommandText := 'SELECT DOCUMENT_NUMBER,WIP_ENTITY_NAME AS WORK_ORDER,ISSUE_TYPE,ISSUE_TYPE_NAME,RECEIVE_TIME from SAJET.G_ERP_rc_wip_MASTER  '
        + 'Where DOCUMENT_NUMBER like :DOCUMENT_NUMBER and ENABLED = ''Y'' and status = 0 '
        + 'Order By DOCUMENT_NUMBER ';
      Params.ParamByName('DOCUMENT_NUMBER').AsString := edtwipscno.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      edtwipscno.Text := QryTemp.FieldByName('DOCUMENT_NUMBER').AsString;
      QryTemp.Close;
      Key := #13;
      edtwipscnoKeyPress(Self, Key);
      //edtwipscno.SetFocus;
      //edtwipscno.SelectAll;
    end;
    free;
  end;
end;


procedure TfDetail.edtWImaterialKeyPress(Sender: TObject; var Key: Char);
var sType,sNoCheck,sStr: string;
    i : Integer;
begin
  if Ord(Key) = vk_Return then
  begin
  
    if gsTypeClass <>'I' then  //發補料
    begin
       MessageDlg('This IS Issue Type Class [I]', mtError, [mbOK], 0);
       exit;
    end;

    //check Document Number status //0:正常 ; 1：had check ; 2: had confirm .
    if not CheckWipMsterStatus then exit;
    //check wo
    if not CheckWO then exit;

    sStr:= checkFIFO(TRIM(edtWIMaterial.Text),sNoCheck);
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
    if CheckWIMaterial then
    begin
       //ShowData(QryDetail.FieldByName('RowId').AsString);
       ShowData(gslpartno);
       edtWIMaterial.SelectAll;
       edtWImaterial.SetFocus ;
    end;
  end;
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

procedure TfDetail.edtWipscNOChange(Sender: TObject);
begin
   editorg.Clear ;
   sbtncheck.Enabled:=false;
end;

procedure TfDetail.sbtnmfgerClick(Sender: TObject);
begin
    if not QryDetail.Active then Exit;
    if QryDetail.IsEmpty then Exit;
    with Tfdata.Create(Self) do
    begin
       MaintainType:='MFGER';
       label1.Caption :='Part_no:'+qrydetail.fieldbyname('part_no').AsString;;
       if Showmodal = mrOK then
       begin
        //
       end;
       Free;
  end;
end;

procedure TfDetail.sbtncheckClick(Sender: TObject);
var strflag:string;
begin
    if MessageDlg('Not Check The Source of '''+edtwipscno.Text+''',Are you sure ?',
        mtConfirmation, [mbYes, mbNo], 0) = mryes then
    begin
      exit;
    end;

    //check Document Number status //0:正常 ; 1：had check ; 2: had confirm .
    if not CheckWipMsterStatus then exit;

    with qrytemp do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
      commandtext:='update sajet.g_erp_rc_wip_master SET status=''1''   '
                  +' where DOCUMENT_NUMBER=:DOCUMENT_NUMBER and status=''0'' ';
      Params.ParamByName('DOCUMENT_NUMBER').AsString :=edtwipscno.Text;
      Execute;

      //如果沒有領補退料則送1筆record_status='-1'的資料
      with qrydetail do
      begin
         strflag:='0';
         first;
         while not eof do
         begin
            if  QryDetail.FieldByName('PRINT_QTY').AsInteger=0 then
              next
            else
            begin
              strflag:='1'  ;
              break;
            end;
         end;
      end;

      IF strflag='0' then
      begin
         with sproc do
         begin
           try
               Close;
               DataRequest('SAJET.MES_ERP_rc_wip');
               FetchParams;
               Params.ParamByName('TDOCUMENT_NUMBER').AsString := QryDetail.FieldByName('DOCUMENT_NUMBER').AsString;
               Params.ParamByName('TWIP_ENTITY_NAME').AsString := QryDetail.FieldByName('WIP_ENTITY_NAME').AsString;
               Params.ParamByName('TISSUE_HEADER_ID').AsString := QryDetail.FieldByName('ISSUE_HEADER_ID').AsString;
               Params.ParamByName('TISSUE_LINE_ID').AsString := QryDetail.FieldByName('ISSUE_LINE_ID').AsString;
               Params.ParamByName('TISSUE_TYPE').AsString := QryDetail.FieldByName('ISSUE_TYPE').AsString;
               Params.ParamByName('TISSUE_TYPE_NAME').AsString := QryDetail.FieldByName('ISSUE_TYPE_NAME').AsString;
               Params.ParamByName('TSEQ_NUMBER').AsString := QryDetail.FieldByName('SEQ_NUMBER').AsString;
               Params.ParamByName('TINVENTORY_ITEM_ID').AsString :=QryDetail.FieldByName('OPTION7').AsString;
               Params.ParamByName('TSUBINV').AsString := QryDetail.FieldByName('SUBINVENTORY').AsString;
               Params.ParamByName('TLOCATOR').AsString := QryDetail.FieldByName('LOCATOR').AsString;
               Params.ParamByName('TMATERIAL_NO').AsString :='';
               Params.ParamByName('TQTY').AsInteger :=0;
               Params.ParamByName('TCREATE_USERID').AsString := UpdateUserID;
               Params.ParamByName('TISSUE_USER').AsString := '';
               Params.ParamByName('TORG_ID').AsString := QryDetail.FieldByName('FACTORY_CODE').AsString;
               Params.ParamByName('Ttype_class').AsString :=QryDetail.FieldByName('type_class').AsString;
               Params.ParamByName('TPUSH').AsString := 'N';
               IF QryDetail.FieldByName('type_class').AsString = 'I' then
                   Params.ParamByName('TTRXNTYPE').AsString := 'D2'  //D2 發補料
               else
                  Params.ParamByName('TTRXNTYPE').AsString := 'D5';  //D5 退料
               Params.ParamByName('TRECORD_STATUS').AsString :='-1';
               Execute;
             finally
               close;
             end;
           end;
      end;

      close;
      params.Clear;
      Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
     // Params.CreateParam(ftString, 'TO_ERP', ptInput);
      Params.CreateParam(ftString, 'check_USERID', ptInput);
      commandtext:='UPDATE  SAJET.mes_to_erp_rc_wip '
                  +' SET '
                 // +' TO_ERP = :TO_ERP, '
                  +' check_TIME = SYSDATE, '
                  +' check_USERID = :check_USERID '
                  +' where document_number=:document_number AND check_time IS NULL  ';
      Params.ParamByName('DOCUMENT_NUMBER').AsString :=edtwipscno.Text;
      {
      if chkPush.Checked then
          Params.ParamByName('TO_ERP').AsString := 'Y'
        else
          Params.ParamByName('TO_ERP').AsString := 'N';
      }
      Params.ParamByName('check_USERID').AsString :=UpdateUserID;
      Execute;
      close;
      sbtncheck.Enabled:=false;
      Showmessage('Check OK!');
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

procedure TfDetail.edtWImaterialChange(Sender: TObject);
begin
   labWIlocate.Caption:='' ;
end;



procedure TfDetail.editWIRPartKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var strpart: string;
begin
   if editWIRpart.Text ='' then exit;
   if UPPERCASE(editWIRpart.Text) ='N/A'  THEN EXIT;
   IF KEY=13 THEN
   begin
      if gsTypeClass <>'R' then  //發補料
      begin
         MessageDlg('This IS Return Type Class [R]', mtError, [mbOK], 0);
         exit;
      end;
      //check Document Number status //0:正常 ; 1：had check ; 2: had confirm .
      if not CheckWipMsterStatus then exit;
      //check wo
      if not CheckWO then exit;
      
      strpart:=GetWIRPart(editWIRpart.Text);
      if strpart<>editWIRpart.Text then
      begin
          lablWIRmsg.Caption:=strpart;
          editWIRpart.SelectAll ;
          editWIRpart.SetFocus ;
          exit;
      end
      else
      begin
        //editWIRpart.Enabled :=false;
         sedtWIRqty.SelectAll ;
         sedtWIRqty.SetFocus ;
      end;

   end;
end;

procedure TfDetail.cmbWIRStockChange(Sender: TObject);
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'warehouse_id', ptInput);
    CommandText := 'select locate_id, locate_name from sajet.sys_locate '
      + 'where warehouse_id = :warehouse_id and enabled = ''Y'' ';
    Params.ParamByName('warehouse_id').AsString := slWIRStockID[cmbWIRStock.ItemIndex];
    Open;
    cmbWIRLocate.Items.Clear;
    slWIRLocateId.Clear;
    while not Eof do
    begin
      cmbWIRLocate.Items.Add(FieldByName('locate_name').AsString);
      slWIRLocateId.Add(FieldByName('locate_id').AsString);
      Next;
    end;
    if cmbWIRLocate.Items.Count = 1 then
      cmbWIRLocate.ItemIndex := 0;
    Close;
  end;
end;

procedure TfDetail.DateTimePickerWIRChange(Sender: TObject);
begin
   edtWIRFifo.text:=GetFIFOCode(datetimepickerWIR.Date);
end;

procedure TfDetail.FormDestroy(Sender: TObject);
begin
  slWIRLocateId.Free;
  slWIRStockId.Free;
  slWRLocateId.Free;
  slWRStockId.Free;
end;

procedure TfDetail.editWIRPartChange(Sender: TObject);
begin
     lablWIRmsg.Caption:='';
     sedtWIRQty.Text := '0';
     edtWIRDateCode.Text := '';
     lablWIRMQty.Caption := '';
     cmbWIRStock.ItemIndex := -1;
     cmbWIRLocate.Items.Clear;
     edtWIRVersion.Text := '';
     edtWIRRequest.Text := '';
     edtWIRIssue.Text := '';

     DateTimePickerWIR.DateTime:=now();
     edtWIRFifo.text:=GetFIFOCode(now());
end;

procedure TfDetail.editWRMaterialKeyPress(Sender: TObject; var Key: Char);
var sLocate, sPartId: string;
var strsql:string;
begin
  if Ord(Key) = vk_Return then
  begin
    editWRwo.Text := '';
    editWRPart.Text := '';
    gsLocateid:='';
    sedtWRQty.Text := '0';
    edtWRDateCode.Text := '';
    lablWRMQty.Caption := '';
    editWRPart.Enabled := False;
    edtWRDateCode.Enabled := False;
    lablWRMsg.Caption := '';
    EditWRSource.Text:='';
    if gsTypeClass <>'R' then  //發補料
    begin
       MessageDlg('This IS Return Type Class [R]', mtError, [mbOK], 0);
       exit;
    end;
    //check Document Number status //0:正常 ; 1：had check ; 2: had confirm .
    if not CheckWipMsterStatus then exit;
    //check wo
    if not CheckWO then exit;

    if CheckWRMaterial(sPartId) then
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
        cmbWRStock.ItemIndex := cmbWRStock.Items.IndexOf(QryTemp.FieldByName('Warehouse_name').AsString);
        sLocate := QryTemp.FieldByName('locate_name').AsString;
        if cmbWRStock.ItemIndex <> -1 then
        begin
          cmbWRStockChange(Self);
          cmbWRLocate.ItemIndex := cmbWRLocate.Items.IndexOf(sLocate);
        end else
        begin
          cmbWRStock.ItemIndex:=-1;
          cmbWRLocate.ItemIndex:=-1;
        end;
      end else
      begin
          cmbWRStock.ItemIndex:=-1;
          cmbWRLocate.ItemIndex:=-1;
      end;
      //add 顯示發料庫的warehouse_name and locate_name
      // add by key 2008/03/07
      // add start
      if copy(editWRMaterial.Text,1,1)='R' then
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
           params.ParamByName('material_no').AsString :=editWRmaterial.Text ;
           open;
           if not isempty then
           begin
              FIRST;
              lblWRwh.Font.Color :=clred;
              lblWRlocate.Font.Color :=clred;
              lblWRwh.Caption :=fieldbyname('warehouse_name').AsString ;
              lblWRlocate.Caption :=fieldbyname('locate_name').AsString ;
           end
           else
           begin
             lblWRwh.Font.Color:=clblack;
             lblWRlocate.Font.Color :=clblack;
             lblWRwh.Caption :='';
             lblWRlocate.Caption :='';
           end
       end;
      //add end
      
      editWRPart.Enabled := False;
      edtWRDateCode.Enabled := False;
      sedtWRQty.SelectAll;
      sedtWRQty.SetFocus;
    end;
  end;
end;

procedure TfDetail.cmbWRStockChange(Sender: TObject);
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'warehouse_id', ptInput);
    CommandText := 'select locate_id, locate_name from sajet.sys_locate '
      + 'where warehouse_id = :warehouse_id and enabled = ''Y'' ';
    Params.ParamByName('warehouse_id').AsString := slWRStockID[cmbWRStock.ItemIndex];
    Open;
    cmbWRLocate.Items.Clear;
    slWRLocateId.Clear;
    while not Eof do
    begin
      cmbWRLocate.Items.Add(FieldByName('locate_name').AsString);
      slWRLocateId.Add(FieldByName('locate_id').AsString);
      Next;
    end;
    if cmbWRLocate.Items.Count = 1 then
      cmbWRLocate.ItemIndex := 0;
    Close;
  end;
end;

procedure TfDetail.sbtnWRprintClick(Sender: TObject);
  procedure InsertWRMaterial(sType, sPartId: string);
  var sMaterial, sPrintData: string;
      iCnt : Integer;
      src_wip_ID,sissue_line_id,sISSUE_HEADER_ID,sISSUE_TYPE,sISSUE_TYPE_NAME,
      sSEQ_NUMBER, sINVENTORY_ITEM_ID,sORG_ID,strmsg:string;
  begin
     //限制超發   add by key 2012/9/8 
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.Params.CreateParam(ftString, 'document_number', ptInput);
    QryTemp.CommandText := 'SELECT A.ROWID, A.rc_wip_ID,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.SEQ_NUMBER, '
          +' A.PART_ID,A.APPLY_QTY,A.PRINT_QTY, '
          +' B.DOCUMENT_NUMBER,B.ISSUE_TYPE,B.ISSUE_TYPE_NAME,A.ORGANIZATION_ID,B.STATUS, '
          +' C.PART_NO,C.OPTION7,C.OPTION1,  '
          +' F.FACTORY_CODE,FACTORY_NAME '
          +' FROM SAJET.G_ERP_rc_wip_DETAIL A,SAJET.G_ERP_rc_wip_MASTER B,SAJET.SYS_PART C,'
          +' SAJET.SYS_FACTORY F  '
          +' WHERE B.DOCUMENT_NUMBER=:DOCUMENT_NUMBER  '
          +' and a.part_id=:part_id '
          +' AND A.rc_wip_ID=B.rc_wip_ID '
          +' AND A.ORGANIZATION_ID=B.ORGANIZATION_ID '
          +' AND A.PART_ID=C.PART_ID '
          +' AND B.ORGANIZATION_ID=F.FACTORY_ID '
          +' AND A.ENABLED=''Y''   '
          +' AND B.ENABLED=''Y''  '
          +' and rownum=1 ';
    QryTemp.Params.ParamByName('part_id').AsString := sPartId;
    QryTemp.Params.ParamByName('document_number').AsString := edtwipscno.Text;
    QryTemp.Open;

    //check part_no is not in document_number
    if QryTemp.isempty then
    begin
          MessageDlg('Part_No: ' + editWRPart.Text + #10#13+' Not in document_number:'+edtwipscno.Text, mtError, [mbOK], 0);
          Exit;
    end;
    //限超退 limit by key 2012/9/12
    if QryTemp.FieldByName('APPLY_QTY').AsInteger - QryTemp.FieldByName('PRINT_QTY').AsInteger  < sedtWRQty.Value then
    begin
        MessageDlg('Part: ' + editWRPart.Text + ' - Over Request(DN). ', mtError, [mbOK], 0);
        Exit;
    end;

    src_wip_ID := QryTemp.FieldByName('rc_wip_ID').AsString;
    sissue_line_id := QryTemp.FieldByName('issue_line_id').AsString;
    sISSUE_HEADER_ID := QryTemp.FieldByName('ISSUE_HEADER_ID').AsString;
    sISSUE_TYPE := QryTemp.FieldByName('ISSUE_TYPE').AsString;
    sISSUE_TYPE_NAME := QryTemp.FieldByName('ISSUE_TYPE_NAME').AsString;
    sSEQ_NUMBER := QryTemp.FieldByName('SEQ_NUMBER').AsString;
    sINVENTORY_ITEM_ID := QryTemp.FieldByName('OPTION7').AsString;
    sORG_ID  := QryTemp.FieldByName('FACTORY_CODE').AsString;

    //get new material ID
    with QryTemp do
    begin
        Close;
        Params.Clear;
        CommandText := 'select sajet.to_label(''' + lablWRType.Caption + ''', ''' + editWRMaterial.Text + ''') SNID from dual';
        Open;
        sMaterial := FieldByName('SNID').AsString;

        //insert into mes_to_erp_rc_wip   add by key 2012/9/8
        with sproc do
        begin
            try
                Close;
                DataRequest('SAJET.MES_ERP_RC_WIP');
                FetchParams;
                Params.ParamByName('TDOCUMENT_NUMBER').AsString := edtwipscno.Text;
                Params.ParamByName('TWIP_ENTITY_NAME').AsString := gsWO;
                Params.ParamByName('TISSUE_HEADER_ID').AsString := sISSUE_HEADER_ID;
                Params.ParamByName('TISSUE_LINE_ID').AsString := sissue_line_id;
                Params.ParamByName('TISSUE_TYPE').AsString := sISSUE_TYPE;
                Params.ParamByName('TISSUE_TYPE_NAME').AsString := sISSUE_TYPE_NAME;
                Params.ParamByName('TSEQ_NUMBER').AsString := sSEQ_NUMBER;
                Params.ParamByName('TINVENTORY_ITEM_ID').AsString :=sINVENTORY_ITEM_ID;
                Params.ParamByName('TSUBINV').AsString := cmbWRStock.Text;
                Params.ParamByName('TLOCATOR').AsString := cmbWRLocate.Text;
                Params.ParamByName('TMATERIAL_NO').AsString := sMaterial;
                Params.ParamByName('TQTY').AsInteger := sedtWRQty.Value;
                Params.ParamByName('TCREATE_USERID').AsString := UpdateUserID;
                Params.ParamByName('TISSUE_USER').AsString :=edtWRissueuser.Text;
                Params.ParamByName('TORG_ID').AsString := sORG_ID;
                Params.ParamByName('Ttype_class').AsString :=gstypeclass;
                Params.ParamByName('TPUSH').AsString := 'N';
                Params.ParamByName('TTRXNTYPE').AsString := 'D5'; //D5 工單異常退料
                Params.ParamByName('TRECORD_STATUS').AsString :='';
                Execute;

                strmsg:=PARAMS.PARAMBYNAME('TRES').AsString;
                if strmsg<>'OK' then
                begin
                  MessageDlg('INSERT SAJET.MES_ERP_RC_WIP ERROR '+#13#13
                          + STRMSG , mtError, [mbOK], 0);
                  Exit;
                end;
            finally
               close;
            end;
        end;

       Close;
       Params.Clear;
       Params.CreateParam(ftString,'DOCUMENT',ptInput) ;
       Params.CreateParam(ftString,'MATERRIAL',ptInput) ;
       CommandText := 'SELECT * FROM SAJET.MES_TO_ERP_RC_WIP WHERE DOCUMENT_NUMBER =:DOCUMENT AND MATERIAL_NO =:MATERRIAL ';
       Params.ParamByName('DOCUMENT').AsString :=  edtwipscno.Text;
       Params.ParamByName('MATERRIAL').AsString := sMaterial;
       Open;

       if IsEmpty then begin
           MessageDlg('INSERT SAJET.MES_ERP_RC_WIP ERROR '+#13#13
                       , mtError, [mbOK], 0);
           Exit;

       end;

       //update sajet.g_wo_pick_list
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'qty', ptInput);
        Params.CreateParam(ftString, 'work_order', ptInput);
        Params.CreateParam(ftString, 'part_id', ptInput);
        Params.CreateParam(ftString, 'qty1', ptInput);
        CommandText := 'update sajet.g_wo_pick_list '
          + 'set issue_qty = issue_qty + :qty, to_wo = 0,AB_RETURN_QTY=AB_RETURN_QTY+:qty1 '
          + 'where work_order = :work_order and part_id = :part_id ';
        Params.ParamByName('qty').AsInteger := -1 * sedtWRQty.Value;
        Params.ParamByName('work_order').AsString := gsWO;
        Params.ParamByName('part_id').AsString := sPartId;
        Params.ParamByName('qty1').AsInteger := sedtWRQty.Value;
        Execute;

        // update sajet.g_pick_list
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'update_userid', ptInput);
        Params.CreateParam(ftString, 'material_no', ptInput);
        Params.CreateParam(ftInteger, 'qty', ptInput);
        CommandText := 'update sajet.g_pick_list '
          + 'set update_time = sysdate, update_userid = :update_userid,qty=qty-:qty '
          + 'where material_no = :material_no ';
        Params.ParamByName('update_userid').AsString := UpdateUserID;
        Params.ParamByName('material_no').AsString := editWRMaterial.Text;
        Params.ParamByName('qty').AsInteger := sedtWRQty.Value;
        Execute;

        // insert  sajet.g_ht_pick_list
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'material_no', ptInput);
        CommandText := 'insert into sajet.g_ht_pick_list '
          + 'select * from sajet.g_pick_list '
          + 'where material_no = :material_no ';
        Params.ParamByName('material_no').AsString := editWRMaterial.Text;
        Execute;

        // delete if qty=0   then  sajet.g_pick_list
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'material_no', ptInput);
        CommandText := 'select *  from sajet.g_pick_list '
          + 'where material_no = :material_no and qty=0 ';
        Params.ParamByName('material_no').AsString := editWRMaterial.Text;
        open;
        if not QryTemp.IsEmpty then
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'material_no', ptInput);
          CommandText := 'delete from sajet.g_pick_list '
                + 'where material_no = :material_no ';
          Params.ParamByName('material_no').AsString := editWRMaterial.Text;
          Execute;
        end;


        //insert  sajet.g_material
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
          + '(part_id, datecode, material_no, material_qty, update_userid, warehouse_id, locate_id, update_time,'
          + ' status, MFGER_NAME, MFGER_PART_NO,RT_ID,REMARK, version,FIFOCode,factory_id,factory_type) '
          + ' values (:part_id, :datecode, :material_no, :material_qty, :update_userid, :warehouse_id, :locate_id,'
          + '  sysdate, 1, :MFGER_NAME, :MFGER_PART_NO,:RT_ID,:REMARK, :version,:FIFO,:factory_id,:factory_type)';
        Params.ParamByName('PART_ID').AsString := sPartId;
        Params.ParamByName('datecode').AsString := edtWRDateCode.Text;
        Params.ParamByName('material_no').AsString := sMaterial;
        Params.ParamByName('material_qty').AsString := sedtWRQty.Text;
        Params.ParamByName('update_userid').AsString := UpdateUserID;
        Params.ParamByName('warehouse_id').AsString := slWRStockId[cmbWRStock.ItemIndex];
        if cmbWRLocate.ItemIndex <> -1 then
          Params.ParamByName('locate_id').AsString := slWRLocateId[cmbWRLocate.ItemIndex]
        else
          Params.ParamByName('locate_id').AsString := '';
        Params.ParamByName('MFGER_NAME').AsString := QryWRDetail.FieldByName('MFGER_NAME').AsString;
        Params.ParamByName('MFGER_PART_NO').AsString := QryWRDetail.FieldByName('MFGER_PART_NO').AsString;
        if gbRTFlag=True then
        begin
          Params.ParamByName('RT_ID').AsString := GetRTID(EditWRSource.Text);
          Params.ParamByName('REMARK').AsString := '';
        end else
        begin
          Params.ParamByName('RT_ID').AsString := '';
          Params.ParamByName('REMARK').AsString := EditWRSource.Text;
        end;
        Params.ParamByName('version').AsString := edtWRVersion.Text;
        Params.ParamByName('FIFO').AsString := edtWRFIFO.Text;
        Params.ParamByName('FACTORY_ID').AsString := G_FCID;
        Params.ParamByName('FACTORY_TYPE').AsString := G_FCTYPE;
        Execute;

        Close;
        Params.Clear;
        Params.CreateParam(ftString,'PART_ID',ptInput) ;
        Params.CreateParam(ftString,'MATERRIAL',ptInput) ;
        CommandText := 'SELECT * FROM SAJET.G_MATERIAL WHERE PART_ID=:PART_ID AND MATERIAL_NO =:MATERRIAL ';
        Params.ParamByName('PART_ID').AsString :=  sPartId;
        Params.ParamByName('MATERRIAL').AsString := sMaterial;
        Open;

        if IsEmpty then
        begin

            MessageDlg('INSERT SAJET.G_MATERIAL ERROR '+#13#13
                         , mtError, [mbOK], 0);
            Close;
            Params.Clear;
            Params.CreateParam(ftString,'DOCUMENT',ptInput) ;
            Params.CreateParam(ftString,'MATERRIAL',ptInput) ;
            CommandText := 'DELETE FROM SAJET.MES_TO_ERP_RC_WIP WHERE DOCUMENT_NUMBER = :DOCUMENT AND MATERIAL_NO =:MATERRIAL ';
            Params.ParamByName('DOCUMENT').AsString :=  edtWipscNO.Text;
            Params.ParamByName('MATERRIAL').AsString := sMaterial;
            Execute;

            Exit;

        end;


        //insert into  sajet.g_ht_material
        Close;
        Params.CreateParam(ftString, 'material_no', ptInput);
        commandtext:=' insert into sajet.g_ht_material '
                    +' select * from sajet.g_material where material_no =:material_no ';
        Params.ParamByName('material_no').AsString := sMaterial;
        Execute;


        //update g_erp_rc_wip_detail add by key 2012/9/8
        QryTemp.Close;
        QryTemp.Params.Clear;
        QryTemp.Params.CreateParam(ftInteger, 'QTY', ptInput);
        QryTemp.Params.CreateParam(ftString, 'rc_wip_ID', ptInput);
        QryTemp.Params.CreateParam(ftString, 'issue_line_id', ptInput);
        QryTemp.CommandText := 'update SAJET.G_ERP_rc_wip_DETAIL '
          + 'set PRINT_QTY = PRINT_QTY + :QTY '
          + 'where rc_wip_ID = :rc_wip_ID and issue_line_id = :issue_line_id AND rownum=1 ';
        QryTemp.Params.ParamByName('QTY').AsInteger := sedtWRQty.Value;
        QryTemp.Params.ParamByName('rc_wip_ID').AsString := src_wip_ID;
        QryTemp.Params.ParamByName('issue_line_id').AsString := sissue_line_id;
        QryTemp.Execute;
        QryTemp.Close;

         //記錄更新后的條碼和以後的條碼   Dennis Shuai 20160428
        QryTemp.Close;
        QryTemp.Params.Clear;
        QryTemp.Params.CreateParam(ftString, 'OLD_MATERIAL', ptInput);
        QryTemp.Params.CreateParam(ftString, 'New_Material', ptInput);
        QryTemp.Params.CreateParam(ftString, 'User_ID', ptInput);
        QryTemp.CommandText := ' Insert into sajet.G_material_Return (Material_No,New_Material,OP_TYPE,UPDATE_USERID)'+
                               '  values(:OLD_MATERIAL,:New_Material,''R'',:User_ID)  ';
        QryTemp.Params.ParamByName('OLD_MATERIAL').AsString :=  editWRMaterial.text;
        QryTemp.Params.ParamByName('New_Material').AsString :=sMaterial ;
        QryTemp.Params.ParamByName('User_ID').AsString := UpdateUserID ;
        QryTemp.Execute;

        //Print Label
        sPrintData := G_getPrintData(6, 17, G_sockConnection, 'DspQryData', lablWRType.Caption + '*&*' + sMaterial, 1, 'DEFAULT');
          if assigned(G_onTransDataToApplication) then
            G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
          else
            showmessage('Not Defined Call Back Function for Code Soft');
          lablWRMsg.Caption := 'Return OK, New ID: ' + sMaterial + '.';
    end;
  end;
var sType, sPartId: string;
begin
    if gsTypeClass <>'R' then  //發補料
    begin
         MessageDlg('This IS Return Type Class [R]', mtError, [mbOK], 0);
         exit;
    end;
    //check Document Number status //0:正常 ; 1：had check ; 2: had confirm .
    if not CheckWipMsterStatus then exit;
    //check wo
    if not CheckWO then exit;

    if sedtWRQty.Value <= 0 then Exit;
    //if (cmbStock.Text = '') or ((cmbLocate.Items.Count > 0) and (cmbLocate.ItemIndex = -1)) then
    if cmbWRLocate.ItemIndex = -1 then
    begin
      MessageDlg('Please select Locator!', mtWarning, [mbOK], 0);
      Exit;
    end;
    if sedtWRQty.Value>StrToIntDef(lablWRMQty.Caption,0) then
    begin
      MessageDlg('Qty Error Max:'+lablWRMQty.Caption, mtWarning, [mbOK], 0);
      Exit;
    end;
    if editWRMaterial.Text = '' then Exit;
    if CheckWRMaterial(sPartId) then
    begin
      InsertWRMaterial(sType, sPartId);
    end;

    gslpartno:=editWRPart.Text;

    editWRMaterial.Text := '';
    editWRPart.Text := '';
    sedtWRQty.Text := '0';
    edtWRDateCode.Text := '';
    lablWRMQty.Caption := '';
    cmbWRStock.ItemIndex := -1;
    cmbWRLocate.Items.Clear;
    editWRMaterial.SetFocus;
    editWRWo.Text := '';
    EditWRSource.Text:='';
    edtWRVersion.Text := '';
    edtWRRequest.Text := '';
    edtWRIssue.Text := '';

    //顯示所有數據 
    //ShowData(QryDetail.FieldByName('RowId').AsString);
    ShowData(gslpartno);
end;

procedure TfDetail.editWRMaterialChange(Sender: TObject);
begin
   lablWRMsg.Caption :='';
   editWRPart.Text := '';
   sedtWRQty.Text := '0';
   edtWRDateCode.Text := '';
   lablWRMQty.Caption := '';
   cmbWRStock.ItemIndex := -1;
   cmbWRLocate.Items.Clear;
   editWRMaterial.SetFocus;
   editWRWo.Text := '';
   EditWRSource.Text:='';
   edtWRVersion.Text := '';
   edtWRRequest.Text := '';
   edtWRIssue.Text := '';
   lblWRwh.Caption :='';
   lblWRlocate.Caption :='';
end;

procedure TfDetail.Delete1Click(Sender: TObject);
begin
   //
end;

end.

