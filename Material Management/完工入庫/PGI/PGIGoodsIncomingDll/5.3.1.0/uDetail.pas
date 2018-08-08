unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, RzButton, RzRadChk, ComCtrls, IniFiles;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    Image3: TImage;
    LabTitle2: TLabel;
    sbtnMaterial: TSpeedButton;
    LabTitle1: TLabel;
    QryTemp: TClientDataSet;
    Label1: TLabel;
    Label10: TLabel;
    sedtQty: TSpinEdit;
    Label2: TLabel;
    lablType: TLabel;
    Label9: TLabel;
    editMaterial: TEdit;
    Label12: TLabel;
    editPart: TEdit;
    Image1: TImage;
    sbtnClear: TSpeedButton;
    lablLocate: TLabel;
    cmbStock: TComboBox;
    cmbLocate: TComboBox;
    SProc: TClientDataSet;
    lablMsg: TLabel;
    lablLabel: TLabel;
    lablDesc: TLabel;
    chkPush: TRzCheckBox;
    Labwoqty: TLabel;
    Label4: TLabel;
    edtFifo: TEdit;
    DateTimePicker1: TDateTimePicker;
    PanelLine: TPanel;
    PanelShift: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    PanelProcessName: TPanel;
    Label7: TLabel;
    Label8: TLabel;
    PanelTerminal: TPanel;
    ds1: TDataSource;
    dbgrd1: TDBGrid;
    QryPallet: TClientDataSet;
    Label11: TLabel;
    EditORG: TEdit;
    edtWo: TEdit;
    Label3: TLabel;
    mmoRemarks: TMemo;
    procedure FormShow(Sender: TObject);
    procedure sbtnMaterialClick(Sender: TObject);
    procedure editMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnClearClick(Sender: TObject);
    procedure cmbStockChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DateTimePicker1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID,Userno, gsType, gsGroupWo, gsLabelField, gsLocateField: string;
    slLocateId, slStockId: TStringList;
    gbFromWM: Boolean;
    sCnt: Integer;
    G_sTerminalID,G_sProcessID,G_sPDLineID : String;
    G_FCID,G_FCCODE,G_FCTYPE:string;
    i_Material_Type:Integer;  //1:QC_lot,2:Pallet
    procedure ClearData;
    function CheckLot(var PartID, sLotNo: string; bChange: Boolean; var bContinue: Boolean): Boolean;
    //function CheckPallet(var PartID: string; bChange: Boolean): Boolean;
    Function GetFIFOCode(dDate:TDateTime):string;
    Function Getsystime: TdateTime;
    Function GetTerminalID : Boolean;
    Function GetFCTYPE(sFCID:string):string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform,{ unitDataBase,} DllInit, uCommData, uLogin;

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

Function TfDetail.Getsystime: TdateTime;
begin
  with QryTemp do
  begin
    close;
    Params.Clear;
    CommandText :=' SELECT SYSDATE FROM DUAL  ';
    open;
    Result := FieldByName('SYSDATE').asDateTime ;
  end;
end;

Function TfDetail.GetTerminalID : Boolean;
begin
  Result := False;
  With TIniFile.Create('SAJET.ini') do
  begin
     G_sTerminalID := ReadString('Material Management','Terminal','');
     Free;
  end;
  If G_sTerminalID = '' Then
  begin
     MessageDlg('Terminal not be assign !!',mtError, [mbCancel],0);
     Exit;
  end;
  With QryTemp do
  begin
    try
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'TERMINALID', ptInput);
      CommandText := 'Select A.PROCESS_ID,A.TERMINAL_NAME,B.PROCESS_NAME,C.PDLINE_NAME '+
                     '      ,A.PDLINE_ID '+
                     'From  SAJET.SYS_TERMINAL A,'+
                          ' SAJET.SYS_PROCESS B, '+
                          ' SAJET.SYS_PDLINE C '+
                      'Where   A.TERMINAL_ID = :TERMINALID '
                        +  ' AND A.PROCESS_ID = B.PROCESS_ID '
                        +  ' AND A.PDLINE_ID = C.PDLINE_ID ';
      Params.ParamByName('TERMINALID').AsString := G_sTerminalID ;
      Open;
      If RecordCount <= 0 Then
      begin
        Close;
        MessageDlg('Terminal data error !!',mtError, [mbCancel],0);
        Exit;
      end;
      G_sProcessID := FieldByName('PROCESS_ID').AsString;
      G_sPDLineID := FieldByName('PDLINE_ID').AsString;
      PanelProcessName.Caption := FieldbyName('Process_Name').AsString;
      PanelTerminal.Caption := FieldByName('Terminal_Name').AsString;
      PanelLine.Caption := FieldByName('PDLINE_NAME').AsString;
    finally
      Close;
    end;
  end;
  Result := True;
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

procedure TfDetail.FormShow(Sender: TObject);
var sTable: string;
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

  sCnt := 0;

  if not GetTerminalID then
  begin
      editmaterial.Enabled :=false;
      exit;
  end;
  with Qrytemp do
  begin
    close;
    Params.Clear;
    Params.CreateParam(ftString	,'USERID', ptInput);
    CommandText :=' SELECT EMP_NO FROM SAJET.SYS_EMP '
                 +' WHERE EMP_ID = :USERID AND ROWNUM=1 ';
    Params.ParamByName('USERID').AsString :=UpdateUserID;
    open;
    UserNo := FieldByName('EMP_NO').asString;
    //Get Shift Name
    close;
    Params.Clear;
    Params.CreateParam(ftString	,'PdlineID', ptInput);
    commandText:=' select a.shift_name '+
                 ' from sajet.sys_shift a,sajet.sys_pdline_shift_base b '+
                 ' where b.shift_id=a.shift_id and b.pdline_id=:PdlineID '+
                 '   and b.ACTIVE_FLAG=''Y'' and rownum=1 ';
    Params.ParamByName('PdlineID').AsString:=G_sPDLineID;
    open;
    if RecordCount=1 then
      PanelShift.Caption:=FieldByName('shift_name').AsString
    else
    begin
      editmaterial.Enabled :=false;
      MessageDlg('The Line'+'''s Shift not Define !!',mtError, [mbCancel],0);
      exit;
    end;
    close;
  end;



  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
    if gsType <> '' then
      CommandText := CommandText + 'and fun_param = ''' + gsType + ''' ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'PGIGOODSINCOMINGDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
    if gsType = 'Pallet No' then
      gsType := 'Goods';
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
    {
    CommandText := 'select warehouse_id, warehouse_name '
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

    if gsType <> 'Goods' then
    begin
      sTable := 'select WORK_ORDER,MATERIAL_NO,UPDATE_TIME FROM SAJET.G_SEMIFINISHED_INCOMING';
      //sgData.Cells[2,0] :='QC Lot No';
      lablLabel.Visible := True;
      lablDesc.Visible := True;
    end
    else
    begin
      sTable := 'select WORK_ORDER,MATERIAL_NO,UPDATE_TIME FROM SAJET.G_GOODS_INCOMING';
      //sgData.Cells[2,0] :='Pallet No';
    end;

    Close;
    Params.Clear;
    CommandText := sTable + ' where UPDATE_USERID=''' + UpdateUserID
      + ''' AND UPDATE_TIME > TO_DATE(TO_CHAR(SYSDATE,''YYYYMMDD''),''YYYYMMDD'') order by UPDATE_TIME ';
    Open;
    while not Eof do
    begin
       mmoRemarks.Lines.Add(fieldbyName('UPDATE_TIME').AsString +'  '+
                            fieldbyName('MATERIAL_NO').AsString  );
       Next;
    end;


    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then
    begin
      editMaterial.CharCase := ecUpperCase;
      editPart.CharCase := ecUpperCase;
      edtWo.CharCase := ecUpperCase;
    end;
    close;
  end;
  editMaterial.SetFocus;

  DateTimePicker1.DateTime:=now();
  edtFifo.text:=GetFIFOCode(now());
end;

procedure TfDetail.sbtnMaterialClick(Sender: TObject);
  procedure InsertMaterial(sLotNo, sPartId, sVersion: string);
  var sResult:string;
  begin
    with QryTemp do
    begin
       //入庫加入流程管控，過process

      with SProc do
      begin
        Close;
        DataRequest('SAJET.CCM_WIP_INCOMING');
        FetchParams;
        Params.ParamByName('TPALLET').AsString := editMaterial.Text;
        Params.ParamByName('TTERMINALID').AsString := G_sTerminalID;
        Params.ParamByName('TMATERIALTYPE').AsInteger := i_Material_Type;
        Params.ParamByName('TFIFO').AsString := edtFifo.Text;
        Params.ParamByName('TGOODSTYPE').AsString := gsType;
        Params.ParamByName('TQTY').AsInteger := sedtQty.Value;
        Params.ParamByName('TEMPID').AsString := UpdateUserID;
        if chkPush.Checked then
            Params.ParamByName('TPUSH_FLAG').AsString := 'Y'
        else
            Params.ParamByName('TPUSH_FLAG').AsString := 'N';
        Params.ParamByName('TWAREHOUSE').AsString := cmbStock.Items.Strings[cmbStock.ItemIndex];
        Params.ParamByName('TLOCATE').AsString :=  cmbLocate.Items.Strings[cmbLocate.ItemIndex];;
        Execute;
        sResult :=  Params.ParamByName('TRES').AsString;
        if sResult <>'OK'  then begin
           MessageDlg('Lot No: ' + editMaterial.Text + ' '+sResult, mtError, [mbOK], 0);
           Close;
           Exit;
        end;

      end;

      lablMsg.Caption := gsType + ': ' + editMaterial.Text + ' incoming OK.';
      //MessageDlg(lablMsg.Caption, mtInformation, [mbOK], 0);
       mmoRemarks.Lines.Add(FormatDateTime('YYYY/MM/dd HH:MM:SS',now) +' '+lablMsg.Caption+
                         '  qty:'+IntToStr(sedtQty.value));

      editMaterial.Text := '';
      editPart.Text := '';
      sedtQty.Text := '0';
      cmbStock.ItemIndex := -1;
      cmbLocate.Items.Clear;
      edtWo.Text := '';
      labwoqty.Caption := '';
      editorg.Text :='';
      QryPallet.Close;
      editMaterial.SetFocus;
    end;
  end;
var sPartID, sVersion, sLotNo: string; bContinue: Boolean;
i:Integer;
begin

  if QryPallet.IsEmpty then
  begin
      MessageDlg('Please Input Data!', mtWarning, [mbOK], 0);
      Exit;
  end;
  //  if (cmbStock.Text = '') or ((cmbLocate.Items.Count > 0) and (cmbLocate.ItemIndex = -1)) then
  if  cmbLocate.ItemIndex = -1 then
  begin
    MessageDlg('Please select Locator!', mtWarning, [mbOK], 0);
    Exit;
  end;
  if sedtQty.Value <= 0 then Exit;


   InsertMaterial(editMaterial.Text, sPartId, sVersion);

end;


procedure TfDetail.editMaterialKeyPress(Sender: TObject; var Key: Char);
var sPart, sLocate, sLotNo: string; bContinue: Boolean;
  sKey: Char;
begin
  sbtnMaterial.Enabled := False;
  lablMsg.Caption := '';
  labwoqty.Caption := '';
  i_Material_Type := 0;
  sKey := #13;
  { //預設的locate 取sys_part table  中的值
  if Ord(Key) = vk_Return then
  begin
    sbtnMaterial.Enabled := CheckLot(sPart, sLotNo, True, bContinue);
    if (bContinue) and (not sbtnMaterial.Enabled) then
      sbtnMaterial.Enabled := CheckPallet(sPart, True);
    if sbtnMaterial.Enabled then
    begin
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
      QryTemp.CommandText := 'select locate_name, warehouse_name, b.warehouse_id, locate_id from sajet.sys_part a, sajet.sys_locate b, sajet.sys_warehouse c '
        + 'where part_id = :part_id and a.' + gsLocateField + ' = to_char(b.locate_id) and b.warehouse_id = c.warehouse_id and rownum = 1';
      QryTemp.Params.ParamByName('part_id').AsString := sPart;
      QryTemp.Open;
      cmbStock.ItemIndex := cmbStock.Items.IndexOf(QryTemp.FieldByName('Warehouse_name').AsString);
      sLocate := QryTemp.FieldByName('locate_name').AsString;
      if cmbStock.ItemIndex <> -1 then
      begin
        cmbStockChange(Self);
        cmbLocate.ItemIndex := cmbLocate.Items.IndexOf(sLocate);
      end;
      if cmbstock.Text='' then
      begin
        if  uppercase(gsType)='GOODS' then
        begin
          qrytemp.Close;
          qrytemp.Params.Clear;
          qrytemp.CommandText:=' select * from sajet.sys_base where PARAM_NAME=''ProductWarehouse'' ';
          qrytemp.Open;
          cmbstock.ItemIndex:=cmbStock.Items.IndexOf(QryTemp.fieldbyname('Param_value').asstring);
          if cmbStock.ItemIndex<>-1 then
            cmbStockChange(Self);
        end;
      end;
      edtWoKeyPress(self, sKey);
    end;
    }
  //預設的locate 取sys_part_factory table  中的值   change by key 2008/07/24
  if Ord(Key) = vk_Return then
  begin
    sbtnMaterial.Enabled := CheckLot(sPart, sLotNo, True, bContinue);

    if sbtnMaterial.Enabled then
    begin
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
      QryTemp.Params.CreateParam(ftString, 'factory_id', ptInput);
      QryTemp.CommandText := 'select locate_name, warehouse_name, b.warehouse_id, a.locate_id from sajet.sys_part_factory a, sajet.sys_locate b, sajet.sys_warehouse c '
        + 'where part_id = :part_id and a.locate_id = to_char(b.locate_id) and b.warehouse_id = c.warehouse_id and a.factory_id = :factory_id and rownum = 1';
      QryTemp.Params.ParamByName('part_id').AsString := sPart;
      QryTemp.Params.ParamByName('factory_id').AsString :=G_FCID ;
      QryTemp.Open;
      cmbStock.ItemIndex := cmbStock.Items.IndexOf(QryTemp.FieldByName('Warehouse_name').AsString);
      sLocate := QryTemp.FieldByName('locate_name').AsString;
      if cmbStock.ItemIndex <> -1 then
      begin
        cmbStockChange(Self);
        cmbLocate.ItemIndex := cmbLocate.Items.IndexOf(sLocate);
      end;
      //預設的locate 再次取g_wo_other table  中的值   change by key 2009/01/16
       qrytemp.Close;
       qrytemp.Params.Clear;
       QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
       qrytemp.CommandText := 'Select B.WAREHOUSE_NAME,C.LOCATE_NAME '+
                    ' From SAJET.G_WO_OTHER A '+
                    '    ,SAJET.SYS_WAREHOUSE B '+
                    '    ,SAJET.SYS_LOCATE   C  '+
                    'Where A.WORK_ORDER=:WORK_ORDER '+
                    'and a.locate_id=c.locate_id(+) '+
                    'and a.enabled=''Y'' '+
                    'and b.warehouse_id(+)=c.warehouse_id and rownum=1 ';
       QryTemp.Params.ParamByName('work_order').AsString := edtwo.Text;
       qrytemp.Open;
       if not qrytemp.isempty then
       begin
            cmbStock.ItemIndex := cmbStock.Items.IndexOf(QryTemp.FieldByName('Warehouse_name').AsString);
            sLocate := QryTemp.FieldByName('locate_name').AsString;
            if cmbStock.ItemIndex <> -1 then
            begin
                cmbStockChange(Self);
                cmbLocate.ItemIndex := cmbLocate.Items.IndexOf(sLocate);
            end;
       end;

      if cmbstock.Text='' then
      begin
        if  uppercase(gsType)='GOODS' then
        begin
          qrytemp.Close;
          qrytemp.Params.Clear;
          qrytemp.CommandText:=' select * from sajet.sys_base where PARAM_NAME=''ProductWarehouse'' ';
          qrytemp.Open;
          cmbstock.ItemIndex:=cmbStock.Items.IndexOf(QryTemp.fieldbyname('Param_value').asstring);
          if cmbStock.ItemIndex<>-1 then
            cmbStockChange(Self);
        end;
      end;
    end;

    editMaterial.SelectAll;
    editMaterial.SetFocus;
  end;
end;

function TfDetail.CheckLot(var PartID, sLotNo: string; bChange: Boolean; var bContinue: Boolean): Boolean;
var sResult:string;
begin
  Result := False;
  bContinue := False;

  with SProc do
  begin
    Close;
    DataRequest('SAJET.CCM_CHK_WIP_INCOMING');
    FetchParams;
    Params.ParamByName('TPALLET').AsString := editMaterial.Text;
    Params.ParamByName('TTERMINALID').AsString := G_sTerminalID;
    Execute;
    sResult :=  Params.ParamByName('TRES').AsString;
    if sResult <>'OK'  then begin
       MessageDlg('Lot No: ' + editMaterial.Text + ' '+sResult, mtError, [mbOK], 0);
       Close;
       Exit;
    end;


    bContinue := True;
    PartID := Params.ParamByName('TPart_id').AsString;
    G_FCID :=  Params.ParamByName('TFACTORY_ID').AsString;
    i_Material_Type :=  Params.ParamByName('TMATERIALTYPE').AsInteger;
    editPart.Text := Params.ParamByName('TPart_NO').AsString;
    sedtQty.Value := Params.ParamByName('TQty').AsInteger;
    Close;


       with qryPallet do
       begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'pallet_no', ptInput);
          if i_Material_Type =2  then
              CommandText := 'select a.work_order,b.erp_qty,b.target_qty,count(*) qty '
                + ' from sajet.g_sn_status a,sajet.g_wo_base b '
                + ' where a.pallet_no = :pallet_no and a.work_order = b.work_order '
                + ' group by a.work_order,b.erp_qty,b.target_qty'
                + ' order by qty desc,a.work_order '
          else if  i_Material_Type =1 then
             CommandText := 'select a.work_order,b.erp_qty,b.target_qty,a.lot_size qty '
                + ' from sajet.g_qc_lot a,sajet.g_wo_base b '
                + ' where a.qc_type = :pallet_no and a.work_order = b.work_order '
                + ' order by qty desc,a.work_order ';
          Params.ParamByName('pallet_no').AsString := editMaterial.Text;
          Open;
       end


  end;
  Result := True;
end;



procedure TfDetail.sbtnClearClick(Sender: TObject);
begin
  ClearData;
end;

procedure TfDetail.ClearData;
begin
  editMaterial.Text := '';
  editPart.Text := '';
  sedtQty.Text := '0';
  cmbStock.ItemIndex := -1;
  cmbLocate.Items.Clear;
  edtWo.Text := '';
  lablMsg.Caption := '';
  labwoqty.Caption := '';
  editorg.Clear ;
end;

procedure TfDetail.cmbStockChange(Sender: TObject);
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'warehouse_id', ptInput);
    CommandText := 'select locate_id, locate_name from sajet.sys_locate '
      + 'where warehouse_id = :warehouse_id and enabled = ''Y'' order by locate_name ';
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
      chkPush.Checked := not (chkPush.Checked);
      MessageDlg('Push Title Change OK', mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfDetail.DateTimePicker1Change(Sender: TObject);
begin
  edtFifo.Text:=GetFIFOCode(DateTimePicker1.DateTime);
end;

end.

