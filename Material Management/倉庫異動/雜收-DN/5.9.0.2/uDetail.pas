unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles, ComCtrls, RzButton, RzRadChk;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    Image3: TImage;
    LabTitle2: TLabel;
    sbtnMaterial: TSpeedButton;
    LabTitle1: TLabel;
    QryMaterial: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    DBGrid2: TDBGrid;
    QryDetail: TClientDataSet;
    DataSource2: TDataSource;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    edtMISCNO: TEdit;
    sedtQty: TSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    lablType: TLabel;
    Label4: TLabel;
    DBGrid1: TDBGrid;
    edtDateCode: TEdit;
    Bevel2: TBevel;
    sbtnMISC: TSpeedButton;
    lablLabel: TLabel;
    lablDesc: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    edtPN: TEdit;
    edtName: TEdit;
    Label11: TLabel;
    DateTimePicker1: TDateTimePicker;
    Label12: TLabel;
    edtFifo: TEdit;
    EditORG: TEdit;
    Label13: TLabel;
    sbtnmfger: TSpeedButton;
    Image1: TImage;
    sbtnconfirm: TSpeedButton;
    chkPush: TRzCheckBox;
    procedure FormShow(Sender: TObject);
    procedure edtMISCNOKeyPress(Sender: TObject; var Key: Char);
    procedure DataSource2DataChange(Sender: TObject; Field: TField);
    procedure sbtnMaterialClick(Sender: TObject);
    procedure sedtQtyDblClick(Sender: TObject);
    procedure sbtnMISCClick(Sender: TObject);
    procedure edtDateCodeKeyPress(Sender: TObject; var Key: Char);
    procedure edtPNKeyPress(Sender: TObject; var Key: Char);
    procedure DateTimePicker1Change(Sender: TObject);
    procedure edtMISCNOChange(Sender: TObject);
    procedure sbtnmfgerClick(Sender: TObject);
    procedure sbtnconfirmClick(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelField, gsBoxField, gsReelField: string;
    G_FCID,G_FCCODE,G_FCTYPE:string;
    procedure showData(sLocate: string);
    Function GetFIFOCode(dDate:TDateTime):string;
    Function GetFCTYPE(sFCID:string):string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin, uCommData, Udata;

procedure TfDetail.ShowData(sLocate: string);
var sSQL: string;  bPrinted: Boolean;
begin
  sSQL := 'SELECT A.ROWID, A.RC_MIS_ID,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.SEQ_NUMBER, '
          +' A.PART_ID,A.APPLY_QTY,A.PRINT_QTY,A.LOCATE_ID, '
          +' B.DOCUMENT_NUMBER,B.ISSUE_TYPE,B.ISSUE_TYPE_NAME,A.ORGANIZATION_ID,B.STATUS, '
          +' C.PART_NO,C.OPTION7,C.OPTION1,  '
          +' D.WAREHOUSE_NAME,D.WAREHOUSE_ID,E.LOCATE_NAME,  '
          +' F.FACTORY_CODE,FACTORY_NAME '
          +' FROM SAJET.G_ERP_RC_MIS_DETAIL A,SAJET.G_ERP_RC_MIS_MASTER B,SAJET.SYS_PART C,'
          +' SAJET.SYS_WAREHOUSE D,SAJET.SYS_LOCATE E,SAJET.SYS_FACTORY F  '
          +' WHERE B.DOCUMENT_NUMBER=:DOCUMENT_NUMBER  '
          +' AND  A.RC_MIS_ID=B.RC_MIS_ID '
          +' AND A.ORGANIZATION_ID=B.ORGANIZATION_ID '
          +' AND A.PART_ID=C.PART_ID '
          +' AND E.LOCATE_ID=A.LOCATE_ID '
          +' AND E.WAREHOUSE_ID=D.WAREHOUSE_ID  '
          +' AND B.ORGANIZATION_ID=F.FACTORY_ID '
          +' AND A.ENABLED=''Y''   '
          +' AND B.ENABLED=''Y''  '
          +' AND D.ENABLED=''Y''  '
          +' AND E.ENABLED=''Y''   '
          +' AND B.type_class=''R''    '
          +' Order By A.SEQ_NUMBER ';
  with QryDetail do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
    CommandText := sSQL;
    Params.ParamByName('DOCUMENT_NUMBER').AsString := edtMISCNO.Text;
    Open;
    if IsEmpty then begin
      MessageDlg('MISC No: ' + edtMISCNO.Text + ' not found.', mtError, [mbOK], 0);
      edtMISCNO.SelectAll;
      edtMISCNO.SetFocus;
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

    while not Eof do begin
     if FieldByName('APPLY_QTY').AsInteger > FieldByName('PRINT_QTY').AsInteger then
      begin
        bPrinted := False;
        break;
      end;
      Next;
    end;
    
    if sLocate <> '' then
      Locate('RowId', sLocate, []);

    // sedtqty.Value :=0;
    edtname.Clear;
    edtdatecode.Clear ;
    edtpn.Clear;
    if  FieldByName('status').AsInteger=1 then //had confirm
    begin
       sbtnconfirm.Enabled :=false;
       edtname.Enabled :=false;
       edtdatecode.Enabled :=false;
       edtpn.Enabled :=false;
       sbtnMaterial.Enabled :=false;
       edtmiscno.Enabled :=true;
       showmessage('The source had confirm!') ;
       exit;
    end;
    if  FieldByName('status').AsInteger=0 then //NOT confirm
    begin
       sbtnconfirm.Enabled :=true;
       edtname.Enabled :=true;
       edtdatecode.Enabled :=true;
       edtpn.Enabled :=true;
       sbtnMaterial.Enabled :=true;
       edtmiscno.Enabled :=false;
    end;

  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var PIni: TIniFile;
begin
  sbtnconfirm.Enabled:=false;
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
  edtMISCNO.SetFocus;
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
    Params.ParamByName('dll_name').AsString := 'RCMISCRECEIVEDLL.DLL';
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
    if not IsEmpty then begin
      edtMISCNO.CharCase := ecUpperCase;
      edtDateCode.CharCase := ecUpperCase;
      edtPN.CharCase := ecUpperCase;
      edtName.CharCase := ecUpperCase;
    end;
  end;

  DateTimePicker1.DateTime:=now();
  edtFifo.Text:=getfifocode(now());
end;

procedure TfDetail.edtMISCNOKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
    ShowData('');
end;

procedure TfDetail.DataSource2DataChange(Sender: TObject; Field: TField);
var iTemp: Integer;
begin
  LablType.Caption := QryDetail.FieldByName('OPTION1').AsString;
  sedtQty.Value:=QryDetail.FieldByName('APPLY_QTY').AsInteger - QryDetail.FieldByName('PRINT_QTY').AsInteger;
  with QryMaterial do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
    CommandText := ' SELECT A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.ISSUE_TYPE,A.ISSUE_TYPE_NAME,A.SEQ_NUMBER,A.INVENTORY_ITEM_ID, '
                  +' A.SUBINV,A.LOCATOR,A.MATERIAL_NO,A.QTY, A.CREATE_TIME,A.CREATE_USERID,A.ORG_ID, '
                  +' B.PART_NO,C.EMP_NO||''-''||C.EMP_NAME AS CREATE_USER  '
                  +' FROM  SAJET.MES_TO_ERP_RC_MIS A,SAJET.SYS_PART B,SAJET.SYS_EMP C '
                  +' WHERE  A.DOCUMENT_NUMBER=:DOCUMENT_NUMBER '
                  +'  AND A.INVENTORY_ITEM_ID = B.OPTION7 '
                  +'  AND A.CREATE_USERID = C.EMP_ID '
                  +'   ORDER BY A.SEQ_NUMBER,B.PART_NO,A.CREATE_TIME ';
    Params.ParamByName('DOCUMENT_NUMBER').AsString := QryDetail.FieldByName('DOCUMENT_NUMBER').AsString;
    Open;
  end;
end;

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
  {if trim(edtDateCode.Text)='' then
  begin
    MessageDlg('Please Input DateCode', mtError, [mbOK], 0);
    Exit;
  end;
  if trim(edtPN.Text)='' then
  begin
    MessageDlg('Please Input MFGER P/N.', mtError, [mbOK], 0);
    Exit;
  end;
  if trim(edtName.Text)='' then
  begin
    MessageDlg('Please Input MFGER Name.', mtError, [mbOK], 0);
    Exit;
  end;
  }
  if lablType.Caption = '' then begin
    MessageDlg('Please Setup Label Type.', mtError, [mbOK], 0);
    Exit;
  end;
  if StrToIntDef(sedtQty.Text, 0) <= 0 then Exit;
  iTemp := 0;
  if sedtqty.Value + QryDetail.FieldByName('print_qty').AsInteger  > QryDetail.FieldByName('APPLY_QTY').AsInteger then
  begin
    MessageDlg('Part: ' + QryDetail.FieldByName('part_no').AsString + ' - Over Request. ', mtWarning, [mbOK], 0);
    Exit;
  end;
  //CHECK EMP WAREHOUSE 權限 
  with qrytemp do
  begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'emp_id', ptInput);
      Params.CreateParam(ftString, 'WAREHOUSE_ID', ptInput);
      commandtext:='select emp_id,warehouse_id from sajet.sys_emp_warehouse  '
                  +' WHERE emp_id=:emp_id AND WAREHOUSE_ID=:WAREHOUSE_ID '
                  +' AND enabled=''Y'' ';
      Params.ParamByName('emp_id').AsString := UpdateUserID;
      Params.ParamByName('WAREHOUSE_ID').AsString :=QryDetail.FieldByName('Warehouse_ID').AsString;
      open;
      if isempty then
      begin
         MessageDlg('You can not use the WH OF '+QryDetail.FieldByName('Warehouse_name').AsString, mtWarning, [mbOK], 0);
         Exit;
      end;
  end;


  with QryTemp do
  begin
      Close;
      Params.Clear;
      CommandText := 'select sajet.to_label(''' + lablType.Caption + ''', '''') SNID from dual';
      Open;
      sMaterial := FieldByName('SNID').AsString;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'REMARK', ptInput);
      Params.CreateParam(ftString, 'PART_ID', ptInput);
      Params.CreateParam(ftString, 'datecode', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftInteger, 'material_qty', ptInput);
      Params.CreateParam(ftString, 'update_userid', ptInput);
      Params.CreateParam(ftString, 'MFGER_NAME', ptInput);
      Params.CreateParam(ftString, 'MFGER_PART_NO', ptInput);
      Params.CreateParam(ftString, 'FIFOCODE', ptInput);
      Params.CreateParam(ftString, 'factory_id', ptInput);
      Params.CreateParam(ftString, 'factory_type', ptInput);
      Params.CreateParam(ftString, 'Warehouse_ID', ptInput);
      Params.CreateParam(ftString, 'LOCATE_ID', ptInput);
      CommandText := 'insert into sajet.g_material '
        + '(REMARK, part_id, datecode, material_no, material_qty, update_userid, MFGER_NAME, MFGER_PART_NO,type,FIFOCODE,factory_ID,factory_type,Warehouse_ID,LOCATE_ID,STATUS) '
        + 'values (:REMARK, :part_id, :datecode, :material_no, :material_qty, :update_userid, :MFGER_NAME, :MFGER_PART_NO,''I'',:FIFOCODE,:factory_id,:factory_type,:Warehouse_ID,:LOCATE_ID,''1'')';
      Params.ParamByName('REMARK').AsString := QryDetail.FieldByName('DOCUMENT_NUMBER').AsString;
      Params.ParamByName('PART_ID').AsString := QryDetail.FieldByName('Part_ID').AsString;
      Params.ParamByName('datecode').AsString :=edtDateCode.Text;
      Params.ParamByName('material_no').AsString := sMaterial;
      Params.ParamByName('material_qty').AsInteger := sedtQty.Value;
      Params.ParamByName('update_userid').AsString := UpdateUserID;
      Params.ParamByName('MFGER_NAME').AsString := edtName.text;
      Params.ParamByName('MFGER_PART_NO').AsString := edtPN.Text;
      Params.ParamByName('FIFOCODE').AsString := edtFifo.Text;
      Params.ParamByName('factory_id').AsString := G_FCID;
      Params.ParamByName('factory_type').AsString := G_FCTYPE;
      Params.ParamByName('Warehouse_ID').AsString:=QryDetail.FieldByName('Warehouse_ID').AsString;
      Params.ParamByName('LOCATE_ID').AsString:=QryDetail.FieldByName('LOCATE_ID').AsString;
      Execute;

      close;
      Params.CreateParam(ftString, 'material_no', ptInput);
      commandtext:='insert into sajet.g_ht_material '
                  +' select * from sajet.g_material where material_no=:material_no ';
      Params.ParamByName('material_no').AsString := sMaterial;
      Execute;


      Close;
      Params.Clear;
      Params.CreateParam(ftInteger, 'PRINT_QTY', ptInput);
      Params.CreateParam(ftString, 'RC_MIS_ID', ptInput);
      Params.CreateParam(ftString, 'ISSUE_LINE_ID', ptInput);
      CommandText := ' update SAJET.G_ERP_RC_MIS_DETAIL '
        + ' set PRINT_QTY = PRINT_QTY + :PRINT_QTY '
        + ' where RC_MIS_ID = :RC_MIS_ID AND ISSUE_LINE_ID =:ISSUE_LINE_ID AND ROWNUM=1';
      Params.ParamByName('PRINT_QTY').AsInteger := sedtQty.Value;
      Params.ParamByName('RC_MIS_ID').AsString :=  QryDetail.FieldByName('RC_MIS_ID').AsString;
      Params.ParamByName('ISSUE_LINE_ID').AsString := QryDetail.FieldByName('ISSUE_LINE_ID').AsString;
      Execute;
      Close;

      with sproc do
      begin
      try
        Close;
        DataRequest('SAJET.MES_ERP_RC_MIS');
        FetchParams;
        Params.ParamByName('TDOCUMENT_NUMBER').AsString := QryDetail.FieldByName('DOCUMENT_NUMBER').AsString;
        Params.ParamByName('TISSUE_HEADER_ID').AsString := QryDetail.FieldByName('ISSUE_HEADER_ID').AsString;
        Params.ParamByName('TISSUE_LINE_ID').AsString := QryDetail.FieldByName('ISSUE_LINE_ID').AsString;
        Params.ParamByName('TISSUE_TYPE').AsString := QryDetail.FieldByName('ISSUE_TYPE').AsString;
        Params.ParamByName('TISSUE_TYPE_NAME').AsString := QryDetail.FieldByName('ISSUE_TYPE_NAME').AsString;
        Params.ParamByName('TSEQ_NUMBER').AsString := QryDetail.FieldByName('SEQ_NUMBER').AsString;
        Params.ParamByName('TINVENTORY_ITEM_ID').AsString :=QryDetail.FieldByName('OPTION7').AsString;
        Params.ParamByName('TSUBINV').AsString := QryDetail.FieldByName('WAREHOUSE_NAME').AsString;
        Params.ParamByName('TLOCATOR').AsString := QryDetail.FieldByName('LOCATE_NAME').AsString;
        Params.ParamByName('TMATERIAL_NO').AsString := sMaterial;
        Params.ParamByName('TQTY').AsInteger := sedtQty.Value;
        Params.ParamByName('TCREATE_USERID').AsString := UpdateUserID;
        Params.ParamByName('TISSUE_USER').AsString := '';
        Params.ParamByName('TORG_ID').AsString := QryDetail.FieldByName('FACTORY_CODE').AsString;
        Params.ParamByName('Ttype_class').AsString :='R';
        Params.ParamByName('TPUSH').AsString := 'N';
        Params.ParamByName('TTRXNTYPE').AsString := 'A3';
        Params.ParamByName('TRECORD_STATUS').AsString :='';
        Execute;
      finally
        close;
      end;
     end;

     sPrintData := G_getPrintData(6, 17, G_sockConnection, 'DspQryData', lablType.Caption + '*&*' + sMaterial, 1, 'DEFAULT');
     if assigned(G_onTransDataToApplication) then
        G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
     else
        showmessage('Not Defined Call Back Function for Code Soft');
  end;
  ShowData(QryDetail.FieldByName('RowId').AsString);
end;

procedure TfDetail.sedtQtyDblClick(Sender: TObject);
var sValue, sLabel: string;
begin
  if QryDetail.IsEmpty then Exit;
  fLogin := TfLogin.Create(Self);
  with fLogin do
  begin
    if ShowModal = mrOK then
    begin
      sValue := sedtQty.Text;
      sLabel := 'QTY';
      while True do
      begin
        if InputQuery('Change QTY', sLabel, sValue) then
        begin
          if StrToIntDef(sValue, 0) <> 0 then
          begin
            sedtQty.Text := sValue;
            break;
          end
          else
            sLabel := 'QTY (Illegal Number)';
        end
        else
          break;
      end;
    end;
  end;
end;

procedure TfDetail.sbtnMISCClick(Sender: TObject);
var Key: Char;
begin
  with TfCommData.Create(Self) do
  begin
    LabType2.Caption := 'MISC No List';
    LabType1.Caption := LabType2.Caption;
    Label1.Caption := 'Search MISC No';
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
      CommandText := 'SELECT DOCUMENT_NUMBER,ISSUE_TYPE,ISSUE_TYPE_NAME,RECEIVE_TIME from SAJET.G_ERP_RC_MIS_MASTER  '
        + 'Where DOCUMENT_NUMBER like :DOCUMENT_NUMBER and ENABLED = ''Y'' and status = 0 AND type_class=''R''  '
        + 'Order By DOCUMENT_NUMBER ';
      Params.ParamByName('DOCUMENT_NUMBER').AsString := edtMISCNO.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      edtMISCNO.Text := QryTemp.FieldByName('DOCUMENT_NUMBER').AsString;
      QryTemp.Close;
      Key := #13;
      edtMISCNOKeyPress(Self, Key);
      //edtMISCNO.SetFocus;
     // edtMISCNO.SelectAll;
    end;
    free;
  end;
end;

procedure TfDetail.edtDateCodeKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
    edtPN.SelectAll;
    edtPN.SetFocus;
  end;
end;

procedure TfDetail.edtPNKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
    sbtnMaterialClick(Self);
  end;
end;

procedure TfDetail.DateTimePicker1Change(Sender: TObject);
begin
   edtFifo.Text:= GetFIFOCode(DateTimePicker1.Date);
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

procedure TfDetail.edtMISCNOChange(Sender: TObject);
begin
   editorg.Clear ;
   sbtnconfirm.Enabled:=false;
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

procedure TfDetail.sbtnconfirmClick(Sender: TObject);
var strflag:string;
begin
    if MessageDlg('Not confirm The Source of '''+edtmiscno.Text+''',Are you sure ?',
        mtConfirmation, [mbYes, mbNo], 0) = mryes then
    begin
      exit;
    end;

    with qrytemp do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
      commandtext:='update sajet.g_erp_rc_mis_master SET status=''1''   '
                  +' where DOCUMENT_NUMBER=:DOCUMENT_NUMBER and status=''0'' ';
      Params.ParamByName('DOCUMENT_NUMBER').AsString :=edtmiscno.Text;
      Execute;

      close;
      params.Clear;
      Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
      commandtext:='update sajet.g_erp_rc_mis_master SET status=''1''   '
                  +' where DOCUMENT_NUMBER=:DOCUMENT_NUMBER and status=''0'' ';
      Params.ParamByName('DOCUMENT_NUMBER').AsString :=edtmiscno.Text;

      //如果沒有收料則送1筆record_status='-1'的資料  
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
               DataRequest('SAJET.MES_ERP_RC_MIS');
               FetchParams;
               Params.ParamByName('TDOCUMENT_NUMBER').AsString := QryDetail.FieldByName('DOCUMENT_NUMBER').AsString;
               Params.ParamByName('TISSUE_HEADER_ID').AsString := QryDetail.FieldByName('ISSUE_HEADER_ID').AsString;
               Params.ParamByName('TISSUE_LINE_ID').AsString := QryDetail.FieldByName('ISSUE_LINE_ID').AsString;
               Params.ParamByName('TISSUE_TYPE').AsString := QryDetail.FieldByName('ISSUE_TYPE').AsString;
               Params.ParamByName('TISSUE_TYPE_NAME').AsString := QryDetail.FieldByName('ISSUE_TYPE_NAME').AsString;
               Params.ParamByName('TSEQ_NUMBER').AsString := QryDetail.FieldByName('SEQ_NUMBER').AsString;
               Params.ParamByName('TINVENTORY_ITEM_ID').AsString :=QryDetail.FieldByName('OPTION7').AsString;
               Params.ParamByName('TSUBINV').AsString := QryDetail.FieldByName('WAREHOUSE_NAME').AsString;
               Params.ParamByName('TLOCATOR').AsString := QryDetail.FieldByName('LOCATE_NAME').AsString;
               Params.ParamByName('TMATERIAL_NO').AsString :='';
               Params.ParamByName('TQTY').AsInteger :=0;
               Params.ParamByName('TCREATE_USERID').AsString := UpdateUserID;
               Params.ParamByName('TISSUE_USER').AsString := '';
               Params.ParamByName('TORG_ID').AsString := QryDetail.FieldByName('FACTORY_CODE').AsString;
               Params.ParamByName('Ttype_class').AsString :='R';
               Params.ParamByName('TPUSH').AsString := 'N';
               Params.ParamByName('TTRXNTYPE').AsString := 'A3';
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
      Params.CreateParam(ftString, 'TO_ERP', ptInput);
      Params.CreateParam(ftString, 'CONFIRM_USERID', ptInput);
      commandtext:='UPDATE  SAJET.mes_to_erp_rc_mis '
                  +' SET TO_ERP = :TO_ERP, '
                  +' CONFIRM_TIME = SYSDATE, '
                  +' CONFIRM_USERID = :CONFIRM_USERID '
                  +' where document_number=:document_number AND confirm_time IS NULL  ';
      Params.ParamByName('DOCUMENT_NUMBER').AsString :=edtmiscno.Text;
      if chkPush.Checked then
          Params.ParamByName('TO_ERP').AsString := 'Y'
        else
          Params.ParamByName('TO_ERP').AsString := 'N';
      Params.ParamByName('CONFIRM_USERID').AsString :=UpdateUserID;
      Execute;
      sbtnconfirm.Enabled:=false;
      edtname.Enabled :=false;
      edtdatecode.Enabled :=false;
      edtpn.Enabled :=false;
      sbtnMaterial.Enabled :=false;
      Showmessage('Confirm OK!');
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

end.

