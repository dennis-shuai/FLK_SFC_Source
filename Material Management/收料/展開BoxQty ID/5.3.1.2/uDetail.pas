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
    LabTitle2: TLabel;
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
    edtRT: TEdit;
    sbtnRT: TSpeedButton;
    EditORG: TEdit;
    Label13: TLabel;
    plPrint: TPanel;
    Label12: TLabel;
    edtFifo: TEdit;
    edtDateCode: TEdit;
    Label4: TLabel;
    Label2: TLabel;
    sedtQty: TSpinEdit;
    Label9: TLabel;
    sedtBoxQty: TSpinEdit;
    Label5: TLabel;
    Label3: TLabel;
    Label11: TLabel;
    edtName: TEdit;
    sbtnmfger: TSpeedButton;
    edtPN: TEdit;
    Label8: TLabel;
    DateTimePicker1: TDateTimePicker;
    sbtnMaterial: TSpeedButton;
    DBGrid1: TDBGrid;
    Image3: TImage;
    lablOutput: TLabel;
    lablType: TLabel;
    lablLabel: TLabel;
    lablDesc: TLabel;
    Label6: TLabel;
    lablVersion: TLabel;
    SProc: TClientDataSet;
    ClientDataSet1: TClientDataSet;
    lblAQL: TPanel;
    Image1: TImage;
    Image2: TImage;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    sbtnPass: TSpeedButton;
    sbtnReject: TSpeedButton;
    Image4: TImage;
    sbtnWaive: TSpeedButton;
    Label22: TLabel;
    editLotQty: TSpinEdit;
    editCheckQty: TSpinEdit;
    editFailQty: TSpinEdit;
    editPassQty: TSpinEdit;
    plDefect: TPanel;
    Label19: TLabel;
    Label20: TLabel;
    lablDefectDesc: TLabel;
    Label21: TLabel;
    editDefectCode: TEdit;
    combDefectLevel: TComboBox;
    seditDefectQty: TSpinEdit;
    lvDefect: TListView;
    lblSampleSize: TLabel;
    lblSamplingType: TLabel;
    Label23: TLabel;
    editDefectMemo: TEdit;
    Label24: TLabel;
    lblComplete: TLabel;
    Label25: TLabel;
    MemoRemark: TMemo;
    procedure FormShow(Sender: TObject);
    procedure edtRTKeyPress(Sender: TObject; var Key: Char);
    procedure DataSource2DataChange(Sender: TObject; Field: TField);
    procedure sbtnMaterialClick(Sender: TObject);
    procedure sedtQtyDblClick(Sender: TObject);
    procedure sbtnRTClick(Sender: TObject);
    procedure edtDateCodeKeyPress(Sender: TObject; var Key: Char);
    procedure edtPNKeyPress(Sender: TObject; var Key: Char);
    procedure DateTimePicker1Change(Sender: TObject);
    procedure edtRTChange(Sender: TObject);
    procedure sbtnmfgerClick(Sender: TObject);
    procedure sedtQtyChange(Sender: TObject);
    procedure sedtBoxQtyChange(Sender: TObject);
    procedure editLotQtyChange(Sender: TObject);
    procedure seditDefectQtyKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure editDefectCodeKeyPress(Sender: TObject; var Key: Char);
    procedure editCheckQtyKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sbtnPassClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelField, gsBoxField, gsReelField: string;
    sSamplingID,sPartid,sPrefixWH,sPrefixWHID:string;
    G_FCID,G_FCCODE,G_FCTYPE:string;
    procedure showData(sLocate: string);
    Function GetFIFOCode(dDate:TDateTime):string;
    Function GetFCTYPE(sFCID:string):string;
    procedure GetVersion(S: string);
    function checkInput: Boolean;
    function IsDefect: Boolean;
    function getSamplingPlanRange(sSamplingType: string; iLotSize: integer): Boolean;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin, uCommData, Udata;

procedure TfDetail.ShowData(sLocate: string);
var sSQL: string;  bPrinted: Boolean;
begin
  sSQL := 'Select A.ROWID, A.RT_ID, A.PART_ID, B.PART_NO, A.PART_VERSION, A.DATECODE, A.INCOMING_QTY, LOT_NO,A.RT_SEQ,A.SubInventory, ' +
    '       A.VENDOR_LOTNO, A.VENDOR_PARTNO, A.INCOMING_TIME, LABEL_TYPE, PRINT_QTY, a.MFGER_NAME, a.MFGER_PART_NO,C.factory_id,C.status  ' +
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
    sPartId := fieldbyname('part_id').AsString;

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

    //已經列印完成or 已經入庫則不允許再次列印
    //add again 2010/5/26
    edtpn.Enabled :=true;
    sbtnmaterial.Enabled :=true;
    //Check print ok or in stock
    IF FieldByName('STATUS').AsInteger <> 0  THEN
    Begin
      MessageDlg('RT No: ' + edtRT.Text + #13#13 + 'Print OK! or In Stock', mtInformation, [mbOK], 0);
      edtPN.Enabled :=fALse;
      sbtnMaterial.Enabled :=false;
      exit;
    end ;
    // add end 


    while not Eof do begin
     // if FieldByName('INCOMING_QTY').AsInteger <> FieldByName('PRINT_QTY').AsInteger then
     //if (FieldByName('INCOMING_QTY').AsInteger > FieldByName('PRINT_QTY').AsInteger )
     if (FieldByName('INCOMING_QTY').AsInteger > FieldByName('PRINT_QTY').AsInteger )
     // INCOMINT_QTY <=0.5 時新加如下條件 2010/5/26
      OR (( FieldByName('INCOMING_QTY').AsFloat >0  ) AND (FieldByName('INCOMING_QTY').AsFloat< 1 )
            AND (FieldByName('PRINT_QTY').AsInteger<1 ) )then
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
      edtPN.Enabled :=fALse;
      sbtnMaterial.Enabled :=false;
      edtRT.SelectAll;
      edtRT.SetFocus;
    end;
    if sLocate <> '' then
      Locate('RowId', sLocate, []);
  end;

  with qrytemp do begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString, 'RTNO', ptInput);
       Params.CreateParam(ftString, 'PARTID', ptInput);
       CommandText :='SELECT NVL(SUM(PASS_QTY),0) ALLLOT FROM SAJET.G_IQC_LOT WHERE LOT_NO= :RTNO AND PART_ID =:PARTID';
       Params.ParamByName('RTNO').AsString := edtRT.Text;
       Params.ParamByName('PARTID').AsString := sPartID;
       Open;
       
       lblComplete.Caption  :=   FieldByName('ALLLOT').AsString;

  end;
end;

function TfDetail.getSamplingPlanRange(sSamplingType: string; iLotSize: integer): Boolean;
var sSQL: string;
begin
  result := False;
  //lablCriticalRej.Caption := '0';
  //lablMajorRej.Caption := '0';
  //lablMinorRej.Caption := '0';
  lblSampleSize.Caption := '0';
//   seditCheckQty.Value      := 0;
//   seditFailQty.Value       := 0;
//   seditPassQty.Value       := 0;

  with QryTemp do
  begin
    try
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SAMPLING_TYPE', ptInput);
      Params.CreateParam(ftInteger, 'LOT_SIZE1', ptInput);
      Params.CreateParam(ftInteger, 'LOT_SIZE2', ptInput);
      sSQL := 'SELECT E.SAMPLE_SIZE, '
        + '       E.CRITICAL_REJECT_QTY, E.MAJOR_REJECT_QTY, E.MINOR_REJECT_QTY '
        + '  FROM SAJET.SYS_QC_SAMPLING_PLAN D, SAJET.SYS_QC_SAMPLING_PLAN_DETAIL E '
        + ' WHERE D.SAMPLING_TYPE =:SAMPLING_TYPE '
        + '   AND D.SAMPLING_ID = E.SAMPLING_ID '
        + '   AND E.MIN_LOT_SIZE <= :LOT_SIZE1 '
        + '   AND E.MAX_LOT_SIZE >= :LOT_SIZE2 ';
      commandtext := sSQL;
      Params.ParamByName('SAMPLING_TYPE').AsString := sSamplingType;
      Params.ParamByName('LOT_SIZE1').AsInteger := iLotSize;
      Params.ParamByName('LOT_SIZE2').AsInteger := iLotSize;
      open;
      if not eof then
      begin
        //lablCriticalRej.Caption := FieldByName('Critical_Reject_Qty').AsString;
        //lablMajorRej.Caption := FieldByName('Major_Reject_Qty').AsString;
        //lablMinorRej.Caption := FieldByName('Minor_Reject_Qty').AsString;
        if StrToInt(FieldByName('SAMPLE_SIZE').AsString) > iLotSize then
          lblSampleSize.Caption := IntToStr(iLotSize)
        else
          lblSampleSize.Caption := FieldByName('SAMPLE_SIZE').AsString;

         editCheckQty.value := StrToIntDef(lblSampleSize.Caption,0);
        result := true;
      end
      else
      begin

      end;
    finally
      Close;
    end;
  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var PIni: TIniFile;
begin
  GetVersion(ExtractFileDir(Application.ExeName) + '\RTLabelPrintdll.dll');

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
var iTemp,iFailTimes,iPassTimes: Integer;

begin
  lablType.Caption := QryDetail.FieldByName('Label_Type').AsString;
  lblSamplingType.Caption :='N/A';
  lblSampleSize.Caption :='N/A';
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
   { if lablType.Caption = '' then
      lablType.Caption := 'QTY ID';}
    sedtQty.Value := StrToIntDef(FieldByName(gsBoxField).AsString, 0);


  end;

  edtDateCode.Text:= QryDetail.FieldByName('DATECODE').AsString;
  edtPN.Text:= QryDetail.FieldByName('MFGER_PART_NO').AsString;
  edtName.Text:=QryDetail.FieldByName('MFGER_NAME').AsString;
  lablOutput.Caption := QryDetail.FieldByName('PRINT_Qty').AsString;

  sPrefixWH := QryDetail.fieldbyName('SubInventory').AsString;

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
  
  with qrytemp do begin


     Close;
     Params.Clear;
     Params.CreateParam(ftString, 'PARTID', ptInput);
     CommandText :='SELECT NVL(FAIL_TIMES,0) FTimes ,NVL(PASS_TIMES,0) PTIMES'+
                   ' FROM SAJET.G_IQC_FAIL_TIMES WHERE PART_ID=:PARTID';
     Params.ParamByName('PARTID').AsString := QryDetail.FieldByName('Part_ID').AsString;
     Open;

     iFailTimes :=  FieldByName('FTimes').AsInteger;
     iPassTimes :=  FieldByName('PTimes').AsInteger;

     Close;
     Params.Clear;
     Params.CreateParam(ftString, 'PARTID', ptInput);
     CommandText :='SELECT * FROM SAJET.SYS_IQC_SAMPLING_DEFAULT WHERE PART_ID=:PARTID';
     Params.ParamByName('PARTID').AsString := QryDetail.FieldByName('Part_ID').AsString;
     Open;

     if Isempty then begin
        MessageDlg('該料號沒設置默認的AQL',mterror,[mbok],0);
        exit;
     end;


     if iFailTimes >=3 then begin
         sSamplingID := fieldbyname('Upper_Sampling_ID').AsString;

     end;


     if iPassTimes >=3 then begin
         sSamplingID := fieldbyname('Lower_Sampling_ID').AsString;

     end;

       
     if (iPassTimes <3 )and (iFailTimes <3) then begin
         sSamplingID := fieldbyname('Default_Sampling_ID').AsString;

     end;

     Close;
     Params.Clear;
     Params.CreateParam(ftString, 'SamplingID', ptInput);
     CommandText :='SELECT * FROM SAJET.SYS_QC_SAMPLING_PLAN WHERE Sampling_ID=:SamplingID';
     Params.ParamByName('SamplingID').AsString := sSamplingID;
     Open;

     lblSamplingType.Caption  :=   FieldByName('Sampling_Type').AsString;

     
     Close;
     Params.Clear;
     Params.CreateParam(ftString, 'RTNO', ptInput);
     Params.CreateParam(ftString, 'PARTID', ptInput);
     CommandText :='SELECT NVL(SUM(LOT_SIZE),0) ALLLOT FROM SAJET.G_IQC_LOT WHERE LOT_NO= :RTNO AND PART_ID =:PARTID';
     Params.ParamByName('RTNO').AsString := edtRT.Text;
     Params.ParamByName('PARTID').AsString := sPartID;
     Open;

     lblComplete.Caption  :=   FieldByName('ALLLOT').AsString;


  end;
  sbtnPass.Enabled :=true;
  sbtnReject.Enabled :=true;
  sbtnWaive.Enabled :=true;

end;

procedure TfDetail.sbtnMaterialClick(Sender: TObject);
var sMaterial, sPrintData: string; i, iTemp, iMod: Integer; slMaterial: TStringList; bOver: Boolean;
begin
  if not QryDetail.Active then Exit;
  if QryDetail.IsEmpty then Exit;
  if trim(editorg.Text)='' then
  begin
    MessageDlg('ORG IS NULL', mtError, [mbOK], 0);
    Exit;
  end;
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
  //剩餘餘數
  iMod := (QryDetail.FieldByName('INCOMING_QTY').AsInteger - QryDetail.FieldByName('PRINT_Qty').AsInteger) mod sedtQty.Value;
  if iMod <> 0 then iTemp := 1;
  bOver := False;
  if sedtBoxQty.Value = (QryDetail.FieldByName('INCOMING_QTY').AsInteger - QryDetail.FieldByName('PRINT_Qty').AsInteger) div sedtQty.Value + iTemp then
    bOver := True
  else if sedtQty.Value * sedtBoxQty.Value + StrToIntDef(lablOutput.Caption,0) > QryDetail.FieldByName('Incoming_Qty').AsInteger then
  begin
    // INCOMINT_QTY <=0.5 時新加可列印條件 2010/5/26
    //add begin
     IF  not ( ( QryDetail.FieldByName('INCOMING_QTY').AsFloat >0  )
          AND (QryDetail.FieldByName('INCOMING_QTY').AsFloat< 1 )
          AND (QryDetail.FieldByName('PRINT_QTY').AsInteger<1 )
          AND (StrToIntDef(sedtQty.Text, 0) = 1 )
          AND (StrToIntDef(sedtBoxQty.Text, 0) = 1) ) THEN
     BEGIN
          MessageDlg('Release Qty > Incoming Qty', mtWarning, [mbOK], 0);
          Exit;
     END;
   // Add end
   // MessageDlg('Release Qty > Incoming Qty', mtWarning, [mbOK], 0);
   // Exit;
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
      Params.CreateParam(ftInteger,'material_qty', ptInput);
      Params.CreateParam(ftString, 'update_userid', ptInput);
      Params.CreateParam(ftString, 'MFGER_NAME', ptInput);
      Params.CreateParam(ftString, 'MFGER_PART_NO', ptInput);
      Params.CreateParam(ftString, 'version', ptInput);
      Params.CreateParam(ftString, 'RT_SEQ', ptInput);
      Params.CreateParam(ftString, 'FIFOCODE', ptInput);
      Params.CreateParam(ftString, 'factory_id', ptInput);
      Params.CreateParam(ftString, 'factory_type', ptInput);
      CommandText := 'insert into sajet.g_material '
        + '(rt_id, part_id, datecode, material_no, material_qty, WareHouse_ID,update_userid, MFGER_NAME, MFGER_PART_NO, version,RT_seq,type,FIFOCODE,factory_ID,factory_type) '
        + 'values (:rt_id, :part_id, :datecode, :material_no, :material_qty,:Warehouse, :update_userid, :MFGER_NAME, :MFGER_PART_NO, :version,:rt_seq,''P'',:FIFOCODE,:factory_id,:factory_type)';
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
      Params.ParamByName('factory_id').AsString := G_FCID;
      Params.ParamByName('factory_type').AsString := G_FCTYPE;
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
      lvdefect.Items.Clear;
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

procedure TfDetail.edtRTChange(Sender: TObject);
begin
   sbtnPass.Enabled :=false;
   sbtnReject.Enabled :=false;
   sbtnWaive.Enabled :=false;
   editorg.Clear ;
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

procedure TfDetail.GetVersion(S: string);
  function HexToInt(HexNum: string): LongInt;
  begin
    Result := StrToInt('$' + HexNum);
  end;
var VersinInfo: Pchar; //版本資訊
  VersinInfoSize: DWord; //版本資訊size (win32 使用)
  pv_info: PVSFixedFileInfo; //版本格式
  Mversion, Sversion: string; //版本No
begin
  VersinInfoSize := GetFileVersionInfoSize(pchar(S), VersinInfoSize);
  VersinInfo := AllocMem(VersinInfoSize);
  try
    GetFileVersionInfo(pchar(S), 0, VersinInfoSize, Pointer(VersinInfo));
    VerQueryValue(pointer(VersinInfo), '\', pointer(pv_info), VersinInfoSize);
    Mversion := inttohex(pv_info.dwProductVersionMS, 0);
    Mversion := copy('00000000', 1, 8 - length(Mversion)) + Mversion;
    Sversion := inttohex(pv_info.dwProductVersionLS, 0);
    Sversion := copy('00000000', 1, 8 - length(Sversion)) + Sversion;
    lablVersion.Caption := 'Version: ' +
      FloatToStr(hextoint(copy(MVersion, 1, 4))) + '.' +
      FloatToStr(hextoint(copy(MVersion, 5, 4))) + '.' +
      FloatToStr(hextoint(copy(SVersion, 1, 4))) + '.' +
      FloatToStr(hextoint(copy(SVersion, 5, 4)));
  finally
    FreeMem(VersinInfo, VersinInfoSize);
  end;
end;

procedure TfDetail.sedtQtyChange(Sender: TObject);
begin
  if sedtqty.Value < 0 then
     sedtqty.Value := 0;
end;

procedure TfDetail.sedtBoxQtyChange(Sender: TObject);
begin
   if sedtboxqty.Value < 0 then
      sedtboxqty.Value := 0;
end;

procedure TfDetail.editLotQtyChange(Sender: TObject);
begin
   getSamplingPlanRange(lblSamplingType.Caption,StrToIntDef(editLotQty.Text,0));
end;

procedure TfDetail.seditDefectQtyKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var i, iNgCnt: integer;
  bFlag: Boolean;
begin
  if Key = 13 then
  begin
    if not checkInput then Exit;

    bFlag := True;
    for i := 0 to lvDefect.Items.Count - 1 do
    begin
      if lvDefect.Items[i].Caption = editDefectCode.Text then
      begin
        iNgCnt := StrToInt(lvDefect.Items[i].SubItems[1]);
        lvDefect.Items[i].SubItems[1] := IntToStr(iNgCnt + seditDefectQty.Value);
        bFlag := False;
      end;
    end;

    if bFlag then
    begin
      with lvDefect.Items.Add do
      begin
        Caption := editDefectCode.Text;
        SubItems.Add(seditDefectQty.Text);
        //SubItems.Add(combDefectLevel.Text);
        SubItems.Add(IntToStr(combDefectLevel.Items.IndexOf(combDefectLevel.Text)));
        SubItems.Add(lablDefectDesc.Caption);
       // SubItems.Add(lablDefectDesc2.Caption);
       // SubItems.Add(trim(editDefectMemo.Text));

      end;
    end;

    editDefectCode.Clear;
    lablDefectDesc.Caption := '';
    //lablDefectDesc2.Caption := '';
    seditDefectQty.Value := 0;
    combDefectLevel.ItemIndex := -1;
    editDefectMemo.Text := '';
    editDefectCode.SetFocus;

  end;

end;

function TfDetail.IsDefect: Boolean;
var sSQL: string;
begin
  Result := False;
  sSQL := 'SELECT DEFECT_CODE, DEFECT_DESC, DEFECT_LEVEL, DEFECT_DESC2, '
    + '       DECODE(DEFECT_LEVEL,''0'',''CRITICAL'',''1'',''MAJOR'',''2'',''MINOR'') "LEVEL" '
    + '  FROM SAJET.SYS_DEFECT '
    + ' WHERE DEFECT_CODE = ''' + editDefectCode.Text + ''' ';
  with QryTemp do
  begin
    try
      Close;
      Params.Clear;
      CommandText := sSQL;
      Open;
      if Eof then Exit;

      lablDefectDesc.Caption := FieldByName('Defect_Desc').AsString;
      //lablDefectDesc2.Caption := FieldByName('Defect_Desc2').AsString;
      if combDefectLevel.ItemIndex = -1 then
        combDefectLevel.ItemIndex := FieldByName('DEFECT_LEVEL').AsInteger;
    finally
      Close;
    end;
  end;
  Result := True;
end;

function TfDetail.checkInput: Boolean;
begin
  Result := False;
  if editDefectCode.Text = '' then
  begin
    MessageDlg('Please input Defect Code !!', mtError, [mbOK], 0);
    editDefectCode.SetFocus;
    Exit;
  end
  else if not IsDefect then
  begin
    MessageDlg('No such Defect Code !!', mtError, [mbOK], 0);
    editDefectCode.SelectAll;
    editDefectCode.SetFocus;
    Exit;
  end
  else if seditDefectQty.Value <= 0 then
  begin
    MessageDlg('Defect Qty'' can''t be 0 !!', mtError, [mbOK], 0);
    seditDefectQty.SetFocus;
    seditDefectQty.SelectAll;
    Exit;
  end;
  Result := True;
end;
procedure TfDetail.editDefectCodeKeyPress(Sender: TObject; var Key: Char);
begin
 if Ord(Key) = VK_Return then
  begin
    editDefectCode.Text := UpperCase(editDefectCode.Text);
    combDefectLevel.ItemIndex := -1;
    if not IsDefect then
    begin
      MessageDlg('No such Defect Code !!', mtError, [mbOK], 0);
      editDefectCode.SelectAll;
      editDefectcode.SetFocus;
      Exit;
    end;
    seditDefectQty.SetFocus;
    seditDefectQty.SelectAll;
  end;
end;

procedure TfDetail.editCheckQtyKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if Key = 13 then
  begin
    editFailQty.SetFocus;
    editPassQty.Value := editCheckQty.value - editFailQty.value;
  end;
end;

procedure TfDetail.sbtnPassClick(Sender: TObject);
var i,iDefectQty,iStatus:integer;
sHint,sRes,sDefectData:string;
begin
  if editLotQty.Value <= 0 then
  begin
    MessageDlg('Lot Size Can''t Equal to "0" !', mtError, [mbOK], 0);
    editLotQty.Setfocus;
    editLotQty.SelectAll;
    exit;
  end;

  if lblSamplingType.Caption = 'N/A' then
  begin
    MessageDlg('Sampling Plan Type Error!' + #10#13
      + 'Please Change Sampling Plan !', mtError, [mbOK], 0);
    Exit;
  end;

  //檢驗數不能大於 收到數
  if editCheckQty.Value >editLotQty.value then
  begin
    MessageDlg('Check Qty More than Lot Size !!', mtError, [mbOK], 0);
    editCheckQty.SetFocus;
    editCheckQty.SelectAll;
    Exit;
  end;
   //fail 數不能大於檢驗數
  if editFailQty.Value > editCheckQty.value then
  begin
    MessageDlg('Fail Qty More than Check Qty !!', mtError, [mbOK], 0);
    editFailQty.SetFocus;
    editFailQty.SelectAll;
    Exit;
  end;

   //檢驗良品數自動計算(檢驗總數扣掉不良品數)
  editPassQty.Value := editCheckQty.value - editFailQty.value;



  if (editFailQty.Value > 0) then
  begin
    if (lvDefect.Items.Count = 0) then
    begin
      MessageDlg('Fail Qty > 0. But Not Found Defect Data !!', mtError, [mbOK], 0);
      Exit;
    end;
    iDefectQty := 0;
    for i := 0 to lvDefect.Items.Count - 1 do
    begin
      iDefectQty := iDefectQty + StrToIntDef(LvDefect.Items[i].SubItems[0], 0);
    end;
    if iDefectQty <> editFailQty.Value then
    begin
      MessageDlg('Total Defect Qty <> Fail Qty !!', mtError, [mbOK], 0);
      Exit;
    end;
  end;

  if (lvDefect.Items.Count > 0) and (editFailQty.Value <= 0) then
  begin
    MessageDlg('Have Defect Data but Fail Qty = 0.', mtError, [mbOK], 0);
    Exit;
  end;

   //免驗和判退時,不用檢查抽驗數是否己達抽驗計畫定義的sample size
  if (Sender = sbtnPass) then // or (Sender = sbtnWaive) or (Sender = sbtnPartialWaive) or (Sender = sbtnSorting)then
  begin
    if StrToIntDef(lblSampleSize.Caption, 0) = 0 then
    begin
      MessageDlg('Sampling Plan Type : ' + lblSamplingType.Caption + #10#13
        + 'Sample Size IS "0" !!', mtWarning, [mbOK], 0);
      Exit;
    end;

     //如果此次的收到數量大於等於樣本數,則必須強迫檢驗數要大於等於樣本數
    if editLotQty.Value >= StrToInt(lblSampleSize.Caption) then
    begin
      if editCheckQty.Value < StrToInt(lblSampleSize.Caption) then
      begin
        MessageDlg('Check Qty Must More Than or Equal to  Sample Size !!', mtError, [mbOK], 0);
        editCheckQty.SetFocus;
        editCheckQty.SelectAll;
        Exit;
      end;
    end
    else
    begin
       //當此批當次收到的數量小於樣本數時,則強迫必須全檢
      if editCheckQty.Value <> editLotQty.Value then
      begin
        MessageDlg('Lot Size < Sample Size !' + #10#13
          + 'Check Qty Must Equal to Lot Size !!', mtError, [mbOK], 0);
        editCheckQty.SetFocus;
        editCheckQty.SelectAll;
        Exit;
      end;
    end;
  end;

    //利用BUTTON的TAG屬性讀取判定的STATUS
  iStatus := (Sender as TSpeedButton).Tag;
   //0 : pass ,1 : reject , 2 : Waive, 3 : Sorting, 4 : By Pass , 5 : Hold , 6 : Partial Waive
   
  if Sender = sbtnPass then
  begin
    sHint := 'PASS';
  end
  else if Sender = sbtnReject then
  begin
    sHint := 'REJECT';
    editPASSQTY.Value :=0;
    if editFailQty.Value = 0 then
    begin
      MessageDlg('Fail Qty = 0. Can''t ' + sHint + ' !!', mtError, [mbOK], 0);
      Exit;
    end;
  end
  else if Sender = sbtnWaive then
  begin
    sHint := 'WAIVE';
  end ;
  sDefectData :='';
  for i := 0 to lvDefect.Items.Count - 1 do
  begin
    sDefectData := sDefectData + lvDefect.Items[i].Caption + '@' //code
      + LvDefect.Items[i].SubItems[0] + '@' //ng qty
      + LvDefect.Items[i].SubItems[1] + '@'; //level
//                   +LvDefect.Items[i].SubItems[4]+'@';   //memo
  end;
  
  if lvDefect.Items.Count = 0 then
    sDefectData := 'N/A';

  if MessageDlg(sHint + ' this lot : ' + edtRt.Text + ' ?', mtConfirmation, [mbYes, mbNo], 0) <> mryes then Exit;

  with sproc do begin
      close;
      datarequest('sajet.ccm_iqc_transfer_lot');
      fetchparams;
      params.ParamByName('TLOTNO').AsString := edtRt.Text;
      params.ParamByName('TPARTID').AsString := sPartid;
      params.ParamByName('TSAMPLINGID').AsString :=sSamplingId;
      params.ParamByName('TLOTSIZE').AsInteger := editLotQty.Value;
      params.ParamByName('TSAMPLESIZE').AsString := lblSampleSize.Caption;
      Params.ParamByName('TDEFECTDATA').AsString := sDefectData;
      params.ParamByName('TPASSQTY').AsInteger := editPASSQTY.Value;
      params.ParamByName('TFAILQTY').AsInteger := editFAILQTY.Value;
      params.ParamByName('TEMPID').AsString := UpdateUserID;
      params.ParamByName('TRESULT').AsInteger := iStatus;
      params.ParamByName('TREMARK').AsString := MemoRemark.text;
      execute;
      sRes :=  params.ParamByName('TRES').AsString;
      if sRes <>'OK' then begin
         MessageDlg(sRes,mterror,[mbok],0);
         exit;
      end;
  end;

   editLotQty.Value :=0;
   editCheckQty.Value :=0;
   editFailQty.Value :=0;
   editPassQty.Value :=0;
   lvDefect.Items.Clear;
   lblAQL.Caption :='N/A';

   with qrytemp do begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString, 'RTNO', ptInput);
       Params.CreateParam(ftString, 'PARTID', ptInput);
       CommandText :='SELECT NVL(SUM(PASS_QTY),0) ALLLOT FROM SAJET.G_IQC_LOT WHERE LOT_NO= :RTNO AND PART_ID =:PARTID';
       Params.ParamByName('RTNO').AsString := edtRT.Text;
       Params.ParamByName('PARTID').AsString := sPartID;
       Open;
       
       lblComplete.Caption  :=   FieldByName('ALLLOT').AsString;

   end;
   memoRemark.Text :='';





end;

end.

