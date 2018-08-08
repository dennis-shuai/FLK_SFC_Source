unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles, ComCtrls;

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
    edtRT: TEdit;
    sedtQty: TSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    lablType: TLabel;
    Label5: TLabel;
    lablOutput: TLabel;
    Label4: TLabel;
    DBGrid1: TDBGrid;
    edtDateCode: TEdit;
    Bevel2: TBevel;
    Label9: TLabel;
    sedtBoxQty: TSpinEdit;
    sbtnRT: TSpeedButton;
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
    procedure FormShow(Sender: TObject);
    procedure edtRTKeyPress(Sender: TObject; var Key: Char);
    procedure DataSource2DataChange(Sender: TObject; Field: TField);
    procedure sbtnMaterialClick(Sender: TObject);
    procedure sedtQtyDblClick(Sender: TObject);
    procedure sbtnRTClick(Sender: TObject);
    procedure edtDateCodeKeyPress(Sender: TObject; var Key: Char);
    procedure edtPNKeyPress(Sender: TObject; var Key: Char);
    procedure DateTimePicker1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelField, gsBoxField, gsReelField: string;
    procedure showData(sLocate: string);
    Function GetFIFOCode(dDate:TDateTime):string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin, uCommData;

procedure TfDetail.ShowData(sLocate: string);
var sSQL: string;  bPrinted: Boolean;
begin
  sSQL := 'Select A.ROWID, A.RT_ID, A.PART_ID, B.PART_NO, A.PART_VERSION, A.DATECODE, A.INCOMING_QTY, LOT_NO,A.RT_SEQ, ' +
    '       A.VENDOR_LOTNO, A.VENDOR_PARTNO, A.INCOMING_TIME, LABEL_TYPE, PRINT_QTY, a.MFGER_NAME, a.MFGER_PART_NO  ' +
    'From SAJET.G_ERP_RT_ITEM A, SAJET.G_ERP_RTNO C, ' +
    '     SAJET.SYS_PART B ' +
    'Where C.ENABLED = ''Y'' ' +
    '  AND A.RT_ID = C.RT_ID AND C.RT_NO = :RT_NO ' +
    '  and A.PART_ID = B.PART_ID ' +
    'Order By PART_NO ';
  with QryDetail do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RT_NO', ptInput);
    CommandText := sSQL;
    Params.ParamByName('RT_NO').AsString := edtRT.Text;
    Open;
    if IsEmpty then begin
      MessageDlg('RT No: ' + edtRT.Text + ' not found.', mtError, [mbOK], 0);
      edtRT.SelectAll;
      edtRT.SetFocus;
      Exit;
    end;
    bPrinted := True;
    while not Eof do begin
      if FieldByName('INCOMING_QTY').AsInteger <> FieldByName('PRINT_QTY').AsInteger then
      begin
        bPrinted := False;
        break;
      end;
      Next;
    end;
    if bPrinted then begin
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString, 'RT_NO', ptInput);
      QryTemp.CommandText := 'update sajet.g_erp_rtno '
        + 'set status = 1 where rt_no = :rt_no ';
      QryTemp.Params.ParamByName('RT_NO').AsString := edtRT.Text;
      QryTemp.Execute;
      QryTemp.Close;
      MessageDlg('RT No: ' + edtRT.Text + #13#13 + 'Print OK.', mtInformation, [mbOK], 0);
      edtRT.SelectAll;
      edtRT.SetFocus;
    end;
    if sLocate <> '' then
      Locate('RowId', sLocate, []);
  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var PIni: TIniFile;
begin
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
    Params.ParamByName('dll_name').AsString := 'RTLABELPRINTDLL.DLL';
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
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then begin
      edtRT.CharCase := ecUpperCase;
      edtDateCode.CharCase := ecUpperCase;
      edtPN.CharCase := ecUpperCase;
      edtName.CharCase := ecUpperCase;
    end;
  end;

  DateTimePicker1.DateTime:=now();
  edtFifo.Text:=getfifocode(now());
end;

procedure TfDetail.edtRTKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
    ShowData('');
end;

procedure TfDetail.DataSource2DataChange(Sender: TObject; Field: TField);
var iTemp: Integer;
begin
  lablType.Caption := QryDetail.FieldByName('Label_Type').AsString;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PART_ID', ptInput);
    CommandText := 'select ' + gsLabelField + ' label_type, ' + gsBoxField + ',' + gsReelField
      + ' from sajet.sys_part '
      + ' where part_id = :part_id and rownum = 1';
    Params.ParamByName('PART_ID').AsString := QryDetail.FieldByName('Part_ID').AsString;
    Open;
    if lablType.Caption = '' then
      lablType.Caption := FieldByName('Label_Type').AsString;
{    if lablType.Caption = '' then
      lablType.Caption := 'QTY ID';}
    sedtQty.Value := StrToIntDef(FieldByName(gsBoxField).AsString, 0);
    Close;
  end;
  edtDateCode.Text:= QryDetail.FieldByName('DATECODE').AsString;
  edtPN.Text:= QryDetail.FieldByName('MFGER_PART_NO').AsString;
  edtName.Text:=QryDetail.FieldByName('MFGER_NAME').AsString;
  lablOutput.Caption := QryDetail.FieldByName('PRINT_Qty').AsString;
  if sedtQty.Value <> 0 then begin
    iTemp := (QryDetail.FieldByName('INCOMING_QTY').AsInteger - QryDetail.FieldByName('PRINT_Qty').AsInteger) mod sedtQty.Value;
    if iTemp <> 0 then iTemp := 1;
      sedtBoxQty.Value := (QryDetail.FieldByName('INCOMING_QTY').AsInteger - QryDetail.FieldByName('PRINT_Qty').AsInteger) div sedtQty.Value + iTemp;
  end;
  if lablType.Caption='QTY ID' then
  begin
     sedtQty.Value:=QryDetail.FieldByName('INCOMING_QTY').AsInteger;
     sedtBoxQty.Value:=1;
  end;

  with QryMaterial do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RT_ID', ptInput);
    Params.CreateParam(ftString, 'Part_ID', ptInput);
    Params.CreateParam(ftString, 'RT_ID2', ptInput);
    Params.CreateParam(ftString, 'Part_ID2', ptInput);
    CommandText := 'select material_no, decode(nvl(sum(reel_qty),0), 0, material_qty,sum(reel_qty)) material_qty, '
      + 'decode(status,''0'',''Print'',''InStock'') status '
      + 'from sajet.g_material a '
      + 'where rt_id = :rt_id and part_id = :part_id and type=''P'' '
      + 'group by material_no, decode(status,''0'',''Print'',''InStock''), material_qty '
      + 'union  select material_no, decode(nvl(sum(reel_qty),0), 0, material_qty,sum(reel_qty)) material_qty, ''Picked'' status '
      + 'from sajet.g_ht_material a '
      + 'where rt_id = :rt_id2 and part_id = :part_id2 and type<>''P'' '
      + 'group by material_no, decode(status,''0'',''Print'',''InStock''), material_qty '
      + 'order by material_no ';
    Params.ParamByName('RT_ID').AsString := QryDetail.FieldByName('RT_ID').AsString;
    Params.ParamByName('Part_ID').AsString := QryDetail.FieldByName('Part_ID').AsString;
    Params.ParamByName('RT_ID2').AsString := QryDetail.FieldByName('RT_ID').AsString;
    Params.ParamByName('Part_ID2').AsString := QryDetail.FieldByName('Part_ID').AsString;
    Open;
  end;
end;

procedure TfDetail.sbtnMaterialClick(Sender: TObject);
var sMaterial, sPrintData: string; i, iTemp, iMod: Integer; slMaterial: TStringList; bOver: Boolean;
begin
  if not QryDetail.Active then Exit;
  if QryDetail.IsEmpty then Exit;
  if trim(edtDateCode.Text)='' then
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
  if lablType.Caption = '' then begin
    MessageDlg('Please Setup Label Type.', mtError, [mbOK], 0);
    Exit;
  end;
  if StrToIntDef(sedtQty.Text, 0) = 0 then Exit;
  if StrToIntDef(sedtBoxQty.Text, 0) = 0 then Exit;
  iTemp := 0;
  //³Ñ¾l¾l¼Æ
  iMod := (QryDetail.FieldByName('INCOMING_QTY').AsInteger - QryDetail.FieldByName('PRINT_Qty').AsInteger) mod sedtQty.Value;
  if iMod <> 0 then iTemp := 1;
  bOver := False;
  if sedtBoxQty.Value = (QryDetail.FieldByName('INCOMING_QTY').AsInteger - QryDetail.FieldByName('PRINT_Qty').AsInteger) div sedtQty.Value + iTemp then
    bOver := True
  else if sedtQty.Value * sedtBoxQty.Value + StrToIntDef(lablOutput.Caption,0) > QryDetail.FieldByName('Incoming_Qty').AsInteger then
  begin
    MessageDlg('Release Qty > Incoming Qty', mtWarning, [mbOK], 0);
    Exit;
  end;
  slMaterial := TStringList.Create;
  for i := 1 to sedtBoxQty.Value do
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select sajet.to_label(''' + lablType.Caption + ''', '''') SNID from dual';
      Open;
      sMaterial := FieldByName('SNID').AsString;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'rt_id', ptInput);
      Params.CreateParam(ftString, 'PART_ID', ptInput);
      Params.CreateParam(ftString, 'datecode', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftInteger, 'material_qty', ptInput);
      Params.CreateParam(ftString, 'update_userid', ptInput);
      Params.CreateParam(ftString, 'MFGER_NAME', ptInput);
      Params.CreateParam(ftString, 'MFGER_PART_NO', ptInput);
      Params.CreateParam(ftString, 'version', ptInput);
      Params.CreateParam(ftString, 'RT_SEQ', ptInput);
      Params.CreateParam(ftString, 'FIFOCODE', ptInput);
      CommandText := 'insert into sajet.g_material '
        + '(rt_id, part_id, datecode, material_no, material_qty, update_userid, MFGER_NAME, MFGER_PART_NO, version,RT_seq,type,FIFOCODE) '
        + 'values (:rt_id, :part_id, :datecode, :material_no, :material_qty, :update_userid, :MFGER_NAME, :MFGER_PART_NO, :version,:rt_seq,''P'',:FIFOCODE)';
      Params.ParamByName('rt_id').AsString := QryDetail.FieldByName('rt_id').AsString;
      Params.ParamByName('PART_ID').AsString := QryDetail.FieldByName('Part_ID').AsString;
      {if edtDateCode.Text = '' then
        Params.ParamByName('datecode').AsString := QryDetail.FieldByName('datecode').AsString
      else
        Params.ParamByName('datecode').AsString := QryDetail.FieldByName('datecode').AsString;}
      Params.ParamByName('datecode').AsString :=edtDateCode.Text;
      Params.ParamByName('material_no').AsString := sMaterial;
      if (bOver) and (i = sedtBoxQty.Value) and (iMod <> 0) then
        Params.ParamByName('material_qty').AsInteger := iMod
      else
        Params.ParamByName('material_qty').AsInteger := sedtQty.Value;
      Params.ParamByName('update_userid').AsString := UpdateUserID;
      Params.ParamByName('RT_SEQ').AsString := QryDetail.FieldByName('RT_SEQ').AsString;
      Params.ParamByName('MFGER_NAME').AsString := edtName.text;//QryDetail.FieldByName('MFGER_NAME').AsString;
      Params.ParamByName('MFGER_PART_NO').AsString := edtPN.Text;
      Params.ParamByName('version').AsString := QryDetail.FieldByName('PART_VERSION').AsString;
      Params.ParamByName('FIFOCODE').AsString := edtFifo.Text;
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
      Params.CreateParam(ftString, 'srowid', ptInput);
      if QryMaterial.IsEmpty then
        Params.CreateParam(ftString, 'label_type', ptInput);
      CommandText := 'update sajet.g_erp_rt_item '
        + 'set PRINT_QTY = PRINT_QTY + :PRINT_QTY ';
      if QryMaterial.IsEmpty then
        CommandText := CommandText + ', label_type = :label_type ';
      CommandText := CommandText + 'where rowid = :srowid';
      if (bOver) and (i = sedtBoxQty.Value) and (iMod <> 0) then
        Params.ParamByName('PRINT_QTY').AsInteger := iMod
      else
        Params.ParamByName('PRINT_QTY').AsInteger := sedtQty.Value;
      Params.ParamByName('srowid').AsString := QryDetail.FieldByName('RowId').AsString;
      if QryMaterial.IsEmpty then
        Params.ParamByName('label_type').AsString := lablType.Caption;
      Execute;
      Close;
      slMaterial.Add(sMaterial);
    end;
  for i := 1 to sedtBoxQty.Value do
  begin
    sMaterial := slMaterial[i - 1];
    sPrintData := G_getPrintData(6, 17, G_sockConnection, 'DspQryData', lablType.Caption + '*&*' + sMaterial, 1, 'DEFAULT');
    if assigned(G_onTransDataToApplication) then
      G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
    else
      showmessage('Not Defined Call Back Function for Code Soft');
  end;
  slMaterial.Free;
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

procedure TfDetail.sbtnRTClick(Sender: TObject);
var Key: Char;
begin
  with TfCommData.Create(Self) do
  begin
    LabType2.Caption := 'RT No List';
    LabType1.Caption := LabType2.Caption;
    Label1.Caption := 'Search RT No';
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'rt_no', ptInput);
      CommandText := 'Select C.RT_NO, B.Vendor_Code, C.Receive_Time '
        + 'From SAJET.G_ERP_RTNO C, SAJET.SYS_VENDOR B '
        + 'Where C.RT_NO like :RT_NO and C.ENABLED = ''Y'' '
        + 'and c.status = 0 and c.vendor_id = b.vendor_id '
        + 'Order By RT_NO ';
      Params.ParamByName('RT_NO').AsString := edtRT.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      edtRT.Text := QryTemp.FieldByName('RT_NO').AsString;
      QryTemp.Close;
      Key := #13;
      edtRTKeyPress(Self, Key);
      edtRT.SetFocus;
      edtRT.SelectAll;
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

end.

