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
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    edtRT: TEdit;
    lablType: TLabel;
    Label6: TLabel;
    sedtReel: TSpinEdit;
    Label8: TLabel;
    Image1: TImage;
    sbtnReel: TSpeedButton;
    DBGrid3: TDBGrid;
    Bevel1: TBevel;
    lablReel: TLabel;
    Label11: TLabel;
    QryReel: TClientDataSet;
    DataSource3: TDataSource;
    Label12: TLabel;
    sedtReelQty: TSpinEdit;
    Image2: TImage;
    SpeedButton1: TSpeedButton;
    Edit1: TEdit;
    EditDC: TEdit;
    Label2: TLabel;
    lablDesc: TLabel;
    lablLabel: TLabel;
    QryHT: TClientDataSet;
    Label3: TLabel;
    editFifo: TEdit;
    DateTimePicker1: TDateTimePicker;
    procedure FormShow(Sender: TObject);
    procedure edtRTKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnReelClick(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure sedtReelDblClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure EditDCKeyPress(Sender: TObject; var Key: Char);
    procedure DateTimePicker1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelField, sCaps, gsReelField: string;
    procedure ShowReel;
    Function GetFIFOCode(dDate:TDateTime):string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin;

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

procedure TfDetail.ShowReel;
var iTemp: Integer;
begin
  with QryReel do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'material_no', ptInput);
    CommandText := 'select reel_no, reel_qty from sajet.g_material '
      + 'where material_no = :material_no and reel_no is not null '
      + 'order by UPDATE_TIME ';
    Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
    Open;
{    lablReel.Caption := '0';
    QryReel.DisableControls;
    QryReel.First;
    while not Eof do
    begin
      lablReel.Caption := IntToStr(StrToInt(lablReel.Caption) + QryReel.FieldByName('Reel_Qty').AsInteger);
      Next;
    end;
    QryReel.Last;
    QryReel.EnableControls;}
    {First;
    if sedtReel.Value <> 0 then begin
      iTemp := (QryMaterial.FieldByName('Material_QTY').AsInteger - STrToInt(lablReel.Caption)) mod sedtReel.Value;
      if iTemp <> 0 then iTemp := 1;
        sedtReelQty.Value := (QryMaterial.FieldByName('Material_QTY').AsInteger - STrToInt(lablReel.Caption)) div sedtReel.Value + iTemp;
    end;}
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
    Params.ParamByName('dll_name').AsString := 'RELEASEREELDLL.DLL';
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
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where Param_Name = ''Material Caps Lock'' ';
    Open;
    if RecordCount = 0 then
      sCaps := 'N'
    else
      sCaps := 'Y';
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Reel Qty Field'' ';
    Open;
    gsReelField := FieldByName('param_value').AsString;
    Close;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then
      edtRT.CharCase := ecUpperCase;
  end;
  DateTimePicker1.DateTime:=now();
  editFifo.Text := GetFIFOCode(now());
end;

procedure TfDetail.edtRTKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
    sbtnReel.Enabled:=false;
    SpeedButton1.Enabled:=false;
    if sCaps = 'Y' then
      edtRT.Text := UpperCase(edtRT.Text);
    EditDC.Text := '';
    Edit1.Text := '';
    if (Copy(edtRT.Text, 1, 1) <> 'B') and (Copy(edtRT.Text, 1, 1) <> 'Q') then
    begin
      MessageDlg('Label Type NG. (Bxxxxxxx)or(Qxxxxxxx)', mtError, [mbOK], 0);
      edtRT.SelectAll;
      edtRT.SetFocus;
      exit;
    end
    else
    begin
      with QryMaterial do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'material_no', ptInput);
        CommandText := 'select distinct material_no, material_qty, a.datecode, part_no, '
          + 'nvl(b.label_type, c.' + gsLabelField + ') label_type, release_qty, a.part_id,a.fifoCode '
          + 'from sajet.g_material_temp a, sajet.g_erp_rt_item b, sajet.sys_part c '
          + 'where a.part_id = c.part_id '
          + 'and material_no = :material_no '
          + 'and a.rt_id = b.rt_id(+) '
          + 'and a.part_id = b.part_id(+) ';
        Params.ParamByName('material_no').AsString := edtRT.Text;
        Open;
        if IsEmpty then
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'material_no', ptInput);
          CommandText := 'select distinct material_no, material_qty, a.datecode, part_no, '
            + 'nvl(b.label_type, c.' + gsLabelField + ') label_type, release_qty, a.part_id,warehouse_id,a.FIFOCode,a.type '
            + 'from sajet.g_material a, sajet.g_erp_rt_item b, sajet.sys_part c '
            + 'where a.part_id = c.part_id '
            + 'and material_no = :material_no '
            + 'and a.rt_id = b.rt_id(+) '
            + 'and a.part_id = b.part_id(+) ';
          Params.ParamByName('material_no').AsString := edtRT.Text;
          Open;
          if IsEmpty then
          begin
            MessageDlg('Box ID not found.', mtError, [mbOK], 0);
            edtRT.SelectAll;
            edtRT.SetFocus;
            Exit;
          end
          else if fieldbyname('warehouse_id').AsString='' then
          begin
            MessageDlg('Material Not Incoming.', mtError, [mbOK], 0);
            edtRT.SelectAll;
            edtRT.SetFocus;
            Exit;
          end
          else if fieldbyname('type').AsString='O' then
          begin
            MessageDlg('Transfer UnComfirm.', mtError, [mbOK], 0);
            edtRT.SelectAll;
            edtRT.SetFocus;
            Exit;
          end;
        end;
        {else if FieldByName('label_type').AsString = 'QTY ID' then
        begin
          edtRT.SelectAll;
          edtRT.SetFocus;
          MessageDlg('Label Type NG.', mtError, [mbOK], 0);
          Close;
          Exit;
        end;}

        lablReel.Caption := FieldByName('Release_Qty').AsString;
        editFIFO.Text:=fieldbyname('FIFOCode').AsString;
      end;
    end;
    sbtnReel.Enabled:=true;
    SpeedButton1.Enabled:=true;
    EditDC.SelectAll;
    EditDC.SetFocus;
  end;
end;

procedure TfDetail.sbtnReelClick(Sender: TObject);
var sReel, sPrintData, str1, sTable: string; i, iRelease, iTemp, iMod: Integer;
  bOver: Boolean;
begin
  if not QryMaterial.Active then Exit;
  if QryMaterial.IsEmpty then Exit;
  if StrToIntDef(sedtReel.Text, 0) = 0 then Exit;
  if Trim(EditDC.Text) = '' then exit;
  if sCaps = 'Y' then
    EditDC.Text := UpperCase(EditDC.Text);
  if EditDC.Text <> Edit1.Text then
    if MessageDlg('DateCode Different [' + Edit1.Text + '] [' + EditDC.Text + '] ,Are you Sure?', mtCustom, mbOKCancel, 0) = mrCancel then
    begin
      EditDC.SelectAll;
      EditDC.SetFocus;
      exit;
    end;

  //if StrToIntDef(sedtReelQty.Text, 0) = 0 then Exit;
  iTemp := 0; iRelease := 0;
  //iMod := (QryMaterial.FieldByName('Material_QTY').AsInteger - QryMaterial.FieldByName('Release_Qty').AsInteger) mod sedtReel.Value;
  //if iMod <> 0 then iTemp := 1;
  //bOver := False;
  //if (iMod > 0) and (sedtReelQty.Value = (QryMaterial.FieldByName('Material_QTY').AsInteger - QryMaterial.FieldByName('Release_Qty').AsInteger) div sedtReel.Value + iTemp) then
  //  bOver := True
  if sedtReel.Value + StrToIntDef(lablReel.Caption, 0) > QryMaterial.FieldByName('Material_Qty').AsInteger then
  begin
    MessageDlg('Release Qty > Reel Qty', mtWarning, [mbOK], 0);
    Exit;
  end;
  //slReel := TStringList.Create;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select sajet.to_label(''REEL ID'', ''' + QryMaterial.FieldByName('material_no').AsString + ''') SNID from dual';
    Open;
    sReel := FieldByName('SNID').AsString;
    if Copy(sReel, Length(sReel) - 1, 2) = '10' then
    begin
      Close;
      Params.Clear;
      CommandText := 'select max(reel_no) reel from sajet.g_material where material_no = ''' + QryMaterial.FieldByName('material_no').AsString + ''' and length(reel_no) = 11 ';
      Open;
      str1 := FieldByName('reel').AsString;
      if Copy(str1, Length(str1) - 1, 2) = '99' then
      begin
        if Copy(str1, Length(str1) - 2, 1) = '-' then
          sReel := Copy(sReel, 1, Length(sReel) - 3) + '100'
        else if Copy(str1, Length(str1) - 2, 1) < '9' then
          sReel := Copy(sReel, 1, Length(sReel) - 3) + IntToStr(StrToInt(Copy(str1, Length(str1) - 2, 1)) + 1) + '00'
        else
        begin
          MessageDlg('Release Reel Qty Over 999', mtWarning, [mbOK], 0);
          Exit;
        end;
      end;
    end;
    iTemp := sedtReel.Value;
    //if (bOver) and (i = sedtReelQty.Value) then
    //  iTemp := iMod;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'material_no', ptInput);
    CommandText := 'select material_no from sajet.g_material '
      + 'where material_no = :material_no ';
    Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
    Open;
    if (QryReel.IsEmpty) and (not IsEmpty) then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'reel_no', ptInput);
      Params.CreateParam(ftInteger, 'reel_qty', ptInput);
      Params.CreateParam(ftString, 'update_userid', ptInput);
      Params.CreateParam(ftString, 'reel_qty1', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftString, 'DC', ptInput);
      Params.CreateParam(ftString, 'FIFO', ptInput);
      CommandText := 'update sajet.g_material '
        + 'set reel_no = :reel_no, reel_qty = :reel_qty, update_userid = :update_userid, update_time = sysdate, release_qty = :reel_qty1,DATECODE=:DC,FIFOCode=:FIFO '
        + 'where material_no = :material_no';
      Params.ParamByName('reel_no').AsString := sReel;
      Params.ParamByName('reel_qty').AsInteger := iTemp;
      Params.ParamByName('update_userid').AsString := UpdateUserid;
      Params.ParamByName('reel_qty1').AsString := sedtReel.Text;
      Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
      Params.ParamByName('DC').AsString := EditDC.Text;
      Params.ParamByName('FIFO').AsString := editFIFO.Text;
    end
    else
    begin
      if IsEmpty then
        sTable := 'sajet.g_material_temp'
      else
        sTable := 'sajet.g_material';
      Close;
      Params.Clear;
      Params.Clear;
      Params.CreateParam(ftString, 'reel_no', ptInput);
      Params.CreateParam(ftInteger, 'reel_qty', ptInput);
      Params.CreateParam(ftString, 'update_userid', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftString, 'DC', ptInput);
      Params.CreateParam(ftString, 'FIFO', ptInput);
      CommandText := 'insert into sajet.g_material '
        + '(rt_id, part_id, datecode, material_no, material_qty, reel_no, reel_qty, update_userid, locate_id, warehouse_id, status,REMARK, MFGER_NAME, MFGER_PART_NO, version,rt_seq,FIFOCode) '
        + 'select rt_id, part_id,:DC,  material_no, material_qty, :reel_no, :reel_qty, :update_userid, locate_id, warehouse_id, status,REMARK, MFGER_NAME, MFGER_PART_NO, version,rt_seq,:FIFO '
        + 'from ' + sTable + ' where material_no = :material_no and rownum = 1 ';
      Params.ParamByName('reel_no').AsString := sReel;
      Params.ParamByName('reel_qty').AsInteger := iTemp;
      Params.ParamByName('update_userid').AsString := UpdateUserid;
      Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
      Params.ParamByName('DC').AsString := EditDC.Text;
      Params.ParamByName('FIFO').AsString := editFIFO.Text;
    end;
    Execute;
    Close;
    iRelease := iRelease + iTemp;

    //slReel.Add(sReel);
  end;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftInteger, 'release_qty', ptInput);
    Params.CreateParam(ftString, 'material_no', ptInput);
    CommandText := 'update sajet.g_material '
      + 'set release_qty = :release_qty '
      + 'where material_no = :material_no';
    Params.ParamByName('release_qty').AsInteger := StrToIntDef(lablReel.Caption, 0) + iRelease;
    Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
    Execute;

    Close;
    Params.Clear;
    if sedtReel.Value + StrToIntDef(lablReel.Caption, 0) = QryMaterial.FieldByName('Material_Qty').AsInteger then
    begin
      Params.CreateParam(ftString, 'material_no', ptInput);
      CommandText := 'delete from sajet.g_material_temp '
        + 'where material_no = :material_no';
      Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
    end
    else if lablReel.Caption = '0' then
    begin
      Params.CreateParam(ftString, 'material_no', ptInput);
      CommandText := 'insert into sajet.g_material_temp '
        + 'select * from sajet.g_material '
        + 'where material_no = :material_no';
      Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
    end
    else
    begin
      Params.CreateParam(ftInteger, 'release_qty', ptInput);
      Params.CreateParam(ftString, 'reel_no', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      CommandText := 'update sajet.g_material_temp '
        + 'set release_qty = :release_qty, reel_no = :reel_no '
        + 'where material_no = :material_no';
      Params.ParamByName('release_qty').AsInteger := StrToIntDef(lablReel.Caption, 0) + iRelease;
      Params.ParamByName('reel_no').AsString := sReel;
      Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
    end;
    Execute;
    Close;
  end;
    qryht.Close;
    qryht.Params.Clear;
    qryht.Params.CreateParam(ftString, 'material_no', ptInput);
    qryht.CommandText:=' insert into sajet.g_ht_material '
                      +' select * from sajet.g_material '
                      +' where Reel_no=:material_no ';
    qryht.Params.ParamByName('material_no').AsString := sReel;
    qryht.Execute;
    
  //for i := 1 to slReel.Count do
  //begin
    //sReel := slReel[i - 1];
  sPrintData := G_getPrintData(6, 17, G_sockConnection, 'DspQryData', 'Reel ID*&*' + sReel, 1, '');
  if assigned(G_onTransDataToApplication) then
    G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
  else
    showmessage('Not Defined Call Back Function for Code Soft');
  //end;
  ShowReel;
  lablReel.Caption := IntToStr(sedtReel.Value + StrToIntDef(lablReel.Caption, 0));
  Edit1.Text := EditDC.Text;
  EditDC.SelectAll;
  EditDC.SetFocus;
end;

procedure TfDetail.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  if not QryMaterial.Active then Exit;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PART_ID', ptInput);
    CommandText := 'select ' + gsReelField
      + ' from sajet.sys_part '
      + ' where part_id = :part_id and rownum = 1';
    Params.ParamByName('PART_ID').AsString := QryMaterial.FieldByName('Part_ID').AsString;
    Open;
    sedtReel.Value := StrToIntDef(FieldByName(gsReelField).AsString, 0);
    Edit1.Text := QryMaterial.FieldByName('datecode').AsString;
    Close;
  end;
  ShowReel;
end;

procedure TfDetail.sedtReelDblClick(Sender: TObject);
var sValue, sLabel: string;
begin
  if QryMaterial.IsEmpty then Exit;
  fLogin := TfLogin.Create(Self);
  with fLogin do
  begin
    if ShowModal = mrOK then
    begin
      sValue := sedtReel.Text;
      sLabel := 'QTY';
      while True do
      begin
        if InputQuery('Change QTY', sLabel, sValue) then
        begin
          if StrToIntDef(sValue, 0) <> 0 then
          begin
            sedtReel.Text := sValue;
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

procedure TfDetail.SpeedButton1Click(Sender: TObject);
var i: Integer; sReel, sPrintData: string;
begin
  if not assigned(G_onTransDataToApplication) then
  begin
    showmessage('Not Defined Call Back Function for Code Soft');
    Exit;
  end;
  with QryReel do
  begin
    while not Eof do
    begin
      sReel := FieldByName('reel_no').AsString;
      sPrintData := G_getPrintData(6, 17, G_sockConnection, 'DspQryData', 'Reel ID*&*' + sReel, 1, '');
      G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil);
      Next;
    end;
    First;
  end;
end;

procedure TfDetail.EditDCKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
    if sCaps = 'Y' then
      EditDC.Text := UpperCase(EditDC.Text);
    if sbtnReel.Enabled then
      sbtnReelClick(Self);
  end;
end;

procedure TfDetail.DateTimePicker1Change(Sender: TObject);
begin
  editFifo.Text := GetFIFOCode(DateTimePicker1.Date);
end;

end.

