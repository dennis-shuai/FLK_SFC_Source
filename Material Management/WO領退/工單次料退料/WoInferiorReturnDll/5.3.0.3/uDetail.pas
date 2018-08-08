unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, DBGrid1, RzButton, RzRadChk, ComCtrls;

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
    Label12: TLabel;
    editPart: TEdit;
    Image1: TImage;
    sbtnClear: TSpeedButton;
    lablLocate: TLabel;
    cmbStock: TComboBox;
    cmbLocate: TComboBox;
    Label4: TLabel;
    edtDateCode: TEdit;
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
    Qrytemp1: TClientDataSet;
    QryWO: TClientDataSet;
    QryID: TClientDataSet;
    edtFIFO: TEdit;
    Label8: TLabel;
    DateTimePicker1: TDateTimePicker;
    Label5: TLabel;
    LaBLMqty: TLabel;
    Edtpartid: TEdit;
    Label9: TLabel;
    EditORG: TEdit;
    procedure FormShow(Sender: TObject);
    procedure sbtnMaterialClick(Sender: TObject);
    procedure sbtnClearClick(Sender: TObject);
    procedure cmbStockChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DateTimePicker1Change(Sender: TObject);
    procedure editWoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure editPartKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsGroupWo, gsLabelField, gsLocateField,gsLocateid: string;
    slLocateId, slStockId: TStringList;
    G_FCID,G_FCCODE,G_FCTYPE:string;
    procedure ClearData;
    Function GetFIFOCode(dDate:TDateTime):string;
    Function GetWO(WO:String):string;
    Function GetPart(PART_NO:string):string;
    Function CheckMqty(WO:string;PART_NO:string):string;
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

Function TfDetail.CheckMqty(WO:string;PART_NO:string):string;
begin
   with qrytemp do
   begin
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
       lablmqty.Caption :=fieldbyname('maxqty').AsString ;
       if sedtqty.Value > fieldbyname('maxqty').AsInteger then
       begin
           result:='Qty Error Max:'+lablMQty.Caption ;
           exit;
       end;
       result:='OK' ;

   end;
end;


Function TfDetail.GetPart(PART_NO:string):string;
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
      commandtext:='select b.work_order,a.part_no,a.part_id,b.request_qty,b.issue_qty ,a.version, a.option7 , '
                  + gsLabelField + ','  + gsLocateField  
                  +' from sajet.sys_part a,sajet.g_wo_pick_list b '
                  +' where b.work_order=:work_order and a.part_no=:part_no and a.part_id=b.part_id and rownum=1 ';
      params.ParamByName('work_order').AsString :=editwo.Text ;
      params.ParamByName('part_no').AsString :=part_no;
      open;
      if isempty then
      begin
          result:='Part_no: '+part_no+' Not Find In The WO: '+Editwo.Text;
          exit;
      end;
      edtrequest.Text :=fieldbyname('request_qty').AsString ;
      edtissue.Text :=fieldbyname('issue_qty').AsString ;
      lablmqty.Caption := inttostr(fieldbyname('request_qty').AsInteger * (-1) - fieldbyname('issue_qty').AsInteger*(-1) ) ;
      edtversion.Text :=fieldbyname('version').AsString ;
      lablType.Caption := FieldByName(gsLabelField).AsString;
      if lablType.Caption = '' then
        lablType.Caption := 'QTY ID';
     if fieldbyname('request_qty').AsString >='0' then
      begin
          result:='Part_no: '+part_no+' request_qty >=0 !';
          exit;
      end;
      result:=fieldbyname('part_no').AsString ;
      edtitem.Text :=fieldbyname('option7').AsString ;
      edtpartid.Text :=fieldbyname('part_id').AsString ;

      gsLocateid:=FieldByName(gsLocateField).AsString;
      if gsLocateid <> '' then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'locate_id', ptInput);
        CommandText := 'select locate_name, warehouse_name, b.warehouse_id, locate_id from sajet.sys_locate b, sajet.sys_warehouse c '
          + 'where b.locate_id = :locate_id and b.warehouse_id = c.warehouse_id and rownum = 1';
        Params.ParamByName('locate_id').AsString := gsLocateid;
        Open;
        cmbStock.ItemIndex := cmbStock.Items.IndexOf(FieldByName('Warehouse_name').AsString);
        sLocate := FieldByName('locate_name').AsString;
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
   end;
end;

Function TfDetail.GetWO(wo:string):string;
begin
   with qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'work_order',ptinput);
       commandtext:='select work_order,wo_status,factory_id from sajet.g_wo_base where work_order=:work_order and rownum=1 ';
       params.ParamByName('work_order').AsString :=wo;
       open;
       if isempty then
       begin
           result:='Work Order: '+ wo +' Not Find!' ;
           exit;
       end;
       if FieldByName('wo_status').AsString = '9' then
       begin
          RESULT:='Work Order: ' + FieldByName('work_order').AsString + ' is complete no charge!' ;
          exit;
       end;

       result:= FieldByName('work_order').AsString;

       G_FCID:='';
       G_FCCODE:='';
       G_FCTYPE:='';
       editorg.Clear ;
       G_FCID:=fieldbyname('factory_id').AsString;
       if Getfctype(G_FCID)<>'OK' then
       begin
          editorg.Clear;
          exit;
       end
       else
          editorg.Text :=G_FCCODE;
       close;
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
    Params.ParamByName('dll_name').AsString := 'WOINFERIORRETURNDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then begin
      editWo.CharCase := ecUpperCase;
      editPart.CharCase := ecUpperCase;
    end;
  end;
  
  DateTimePicker1.DateTime:=now();
  edtFifo.text:=GetFIFOCode(now());
end;

procedure TfDetail.sbtnMaterialClick(Sender: TObject);
  procedure InsertMaterial(sPartId: string);
  var sMaterial, sPrintData: string;
      iCnt : Integer;
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select sajet.to_label(''' + lablType.Caption + ''', ''' + editwo.Text + ''') SNID from dual';
      Open;
      sMaterial := FieldByName('SNID').AsString;

      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'qty', ptInput);
      Params.CreateParam(ftString, 'work_order', ptInput);
      Params.CreateParam(ftString, 'part_id', ptInput);
      Params.CreateParam(ftString, 'qty1', ptInput);
      CommandText := 'update sajet.g_wo_pick_list '
        + 'set issue_qty = issue_qty + :qty,AB_RETURN_QTY=AB_RETURN_QTY+:qty1 '
        + 'where work_order = :work_order and part_id = :part_id ';
      Params.ParamByName('qty').AsInteger := -1 * sedtQty.Value;
      Params.ParamByName('work_order').AsString := editwo.Text;
      Params.ParamByName('part_id').AsString := sPartId;
      Params.ParamByName('qty1').AsInteger := sedtQty.Value;
      Execute;

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
      Params.ParamByName('datecode').AsString := edtDateCode.Text;
      Params.ParamByName('material_no').AsString := sMaterial;
      Params.ParamByName('material_qty').AsString := sedtQty.Text;
      Params.ParamByName('update_userid').AsString := UpdateUserID;
      Params.ParamByName('warehouse_id').AsString := slStockId[cmbStock.ItemIndex];
      if cmbLocate.ItemIndex <> -1 then
        Params.ParamByName('locate_id').AsString := slLocateId[cmbLocate.ItemIndex]
      else
        Params.ParamByName('locate_id').AsString := '';

      Params.ParamByName('REMARK').AsString := editwo.Text;
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

        sPrintData := G_getPrintData(6, 17, G_sockConnection, 'DspQryData', lablType.Caption + '*&*' + sMaterial, 1, 'DEFAULT');
        if assigned(G_onTransDataToApplication) then
          G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
        else
          showmessage('Not Defined Call Back Function for Code Soft');
        lablMsg.Caption := 'Return OK, New ID: ' + sMaterial + '.';

      with sproc do
      begin
        try
          Close;
          DataRequest('SAJET.MES_ERP_WIP_RETURN');
          FetchParams;
          Params.ParamByName('TWO').AsString := editwo.Text;
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
var strwo,strpart:string;
begin
  if trim(editorg.Text)='' then
  begin
     MessageDlg(editwo.Text + ' ORG IS ERROR', mtWarning, [mbOK], 0);
     Exit;
  end;
  if sedtQty.Value <= 0 then Exit;
 // if (cmbStock.Text = '') or ((cmbLocate.Items.Count > 0) and (cmbLocate.ItemIndex = -1)) then
  if cmbLocate.ItemIndex = -1  then
  begin
    MessageDlg('Please select Locator!', mtWarning, [mbOK], 0);
    Exit;
  end;
  if sedtQty.Value>StrToIntDef(lablMQty.Caption,0) then
  begin
    MessageDlg('Qty Error Max:'+lablMQty.Caption, mtWarning, [mbOK], 0);
    Exit;
  end;
  if (editwo.Enabled =true) or (editwo.Text ='') then
  begin
     editwo.SelectAll ;
     editwo.SetFocus ;
     lablmsg.Caption :='Please Input WO !';
     exit;
  end;
  if (editpart.Enabled =true) or (editpart.Text ='' ) then
  begin
      editpart.SelectAll ;
      editpart.SetFocus ;
      lablmsg.Caption :='Please Input Part NO!';
      exit;
  end;


  IF   CheckMqty(editwo.Text,editpart.Text)='OK' then
    InsertMaterial(edtpartid.Text)
  else
  begin
      lablmsg.Caption :=CheckMqty(editwo.Text,editpart.Text);
      exit;
  end;

  editWo.Text := '';
  editPart.Text := '';
  sedtQty.Text := '0';
  edtDateCode.Text := '';
  lablMQty.Caption := '';
  cmbStock.ItemIndex := -1;
  cmbLocate.Items.Clear;
  edtVersion.Text := '';
  edtRequest.Text := '';
  edtIssue.Text := '';
  editwo.Enabled :=true;
  editpart.Enabled :=false;
  editorg.Text :='';

  DateTimePicker1.DateTime:=now();
  edtFifo.text:=GetFIFOCode(now());
end;



procedure TfDetail.sbtnClearClick(Sender: TObject);
begin
  ClearData;
end;

procedure TfDetail.ClearData;
begin
  editwo.Enabled :=true;
  editpart.Enabled :=false;
  editwo.Clear ;
  editwo.SetFocus;
  editpart.Clear;
  edtpartid.Clear ;
  edtitem.Clear ;
  gsLocateid:='';
  sedtQty.Text := '0';
  edtDateCode.Text := '';
  lablMQty.Caption := '';
  lablMsg.Caption := '';
  lablmqty.Caption :='';
  QryAbnormal.Close;
  edtversion.Clear;
  edtrequest.Clear ;
  edtissue.Clear ;
  cmbStock.ItemIndex:=-1;
  cmbLocate.ItemIndex:=-1;

  DateTimePicker1.DateTime:=now();
  edtFifo.text:=GetFIFOCode(now());
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

procedure TfDetail.DateTimePicker1Change(Sender: TObject);
begin
   edtFifo.text:=GetFIFOCode(datetimepicker1.Date);
end;

procedure TfDetail.editWoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var strwo:string;
begin
  IF trim(editwo.Text)='' then exit;
  if trim(editwo.Text)='N/A' then exit;
  if key=13 then
  begin
    strwo:=GetWO(editwo.Text) ;
    if strwo=editwo.Text then
    begin
        editwo.Enabled:=false;
        editpart.Enabled :=true;
        editpart.SelectAll ;
        editpart.SetFocus;
    end
    else
    begin
        lablmsg.Caption:=strwo;
        editwo.SelectAll ;
        editwo.SetFocus ;
        exit;
    end;
  end;
end;

procedure TfDetail.editPartKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var strpart: string;
begin
   if editpart.Text ='' then exit;
   if UPPERCASE(editpart.Text) ='N/A'  THEN EXIT;
   IF KEY=13 THEN
   begin
      strpart:=GetPart(editpart.Text);
      if strpart<>editpart.Text then
      begin
          lablmsg.Caption:=strpart;
          editpart.SelectAll ;
          editpart.SetFocus ;
          exit;
      end
      else
      begin
         editpart.Enabled :=false;
         sedtqty.SelectAll ;
         sedtqty.SetFocus ;
      end;

   end;
end;

end.

