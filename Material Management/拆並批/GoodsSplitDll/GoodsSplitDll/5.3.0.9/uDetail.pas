unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles;

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
    Image1: TImage;
    sbtnReel: TSpeedButton;
    QryReel: TClientDataSet;
    DataSource3: TDataSource;
    lablMsg: TLabel;
    lablLabel: TLabel;
    lablDesc: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    QryHT: TClientDataSet;
    procedure FormShow(Sender: TObject);
    procedure edtRTKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnReelClick(Sender: TObject);
    procedure sedtReelDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsType, gsLabelField: string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin;

procedure TfDetail.FormShow(Sender: TObject);
var PIni: TIniFile;
begin
  PIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Material.Ini');
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
    Params.ParamByName('dll_name').AsString := 'GOODSSPLITDLL.DLL';
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
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then begin
      edtRT.CharCase := ecUpperCase;
    end;  
  end;
end;

procedure TfDetail.edtRTKeyPress(Sender: TObject; var Key: Char);
begin
  lablMsg.Caption := '';
  if Ord(Key) = vk_Return then
  begin
    gsType := 'Material_No';
    with QryMaterial do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'material_no', ptInput);
      CommandText := 'select distinct material_no, material_qty, a.datecode, part_no, '
        + 'nvl(b.label_type, c.' + gsLabelField + ') label_type, reel_qty, status,FIFOCode,a.type '
        + 'from sajet.g_material a, sajet.g_erp_rt_item b, sajet.sys_part c '
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
        CommandText := 'select distinct a.reel_no material_no, a.reel_qty material_qty, a.datecode, c.part_no, '
          + ' ''Reel_No'' label_type, a.status,FIFOCode,a.type '
          + 'from sajet.g_material a, sajet.sys_part c '
          + 'where a.part_id = c.part_id '
          + 'and reel_no = :material_no ';
        Params.ParamByName('material_no').AsString := edtRT.Text;
        Open;
        if IsEmpty then
        begin
          MessageDlg('ID No: ' + edtRT.Text + ' not found.', mtError, [mbOK], 0);
          Close;
        end
        else if fieldbyname('type').AsString = 'O' then
        begin
          MessageDlg('Transfer UnConfirm.', mtError, [mbOK], 0);
          Close;
        end;
        gsType := 'Reel_No';
      end
      else if (RecordCount > 1) or (FieldByName('reel_qty').AsString <> '') then
      begin
        MessageDlg('This Box ID cann''t Split - Have Reel.', mtError, [mbOK], 0);
        Close;
{      end
      else if FieldByName('status').AsString = '0' then
      begin
        MessageDlg('This ID No cann''t Split - Not InStock.', mtError, [mbOK], 0);
        Close;}
      end
      else if fieldbyname('type').AsString = 'O' then
      begin
          MessageDlg('Transfer UnConfirm.', mtError, [mbOK], 0);
          Close;
      end;
      edtRT.SelectAll;
      edtRT.SetFocus;
    end;
  end;
end;

procedure TfDetail.sbtnReelClick(Sender: TObject);
var sReel, sPrintData, sLabelType: string; i: Integer; slReel: TStringList;
begin
  if not QryMaterial.Active then Exit;
  if QryMaterial.IsEmpty then Exit;
  if StrToIntDef(sedtReel.Text, 0) <= 0 then
  begin
    MessageDlg('Split Qty <= 0!', mtWarning, [mbOK], 0);
    sedtReel.SelectAll;
    sedtReel.SetFocus;
    Exit;
  end;
  if sedtReel.Value > QryMaterial.FieldByName('Material_Qty').AsInteger then
  begin
    MessageDlg('Split Qty > Material Qty', mtWarning, [mbOK], 0);
    Exit;
  end;
  slReel := TStringList.Create;
  lablMsg.Caption := 'ID No: ';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    if gsType = 'Reel_No' then
      CommandText := 'select sajet.to_label(''REEL ID2'', ''' + QryMaterial.FieldByName('material_no').AsString + ''') SNID from dual'
    else
    begin
      sLabelType := QryMaterial.FieldByName('label_type').AsString;
      if sLabelType = '' then
        sLabelType := 'QTY ID';
      CommandText := 'select sajet.to_label(''' + sLabelType + ''',''' + QryMaterial.FieldByName('material_no').AsString + ''') SNID from dual';
    end;
    Open;
    sReel := FieldByName('SNID').AsString;
    slReel.Add(sReel);
    if gsType = 'Reel_No' then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'reel_no', ptInput);
      Params.CreateParam(ftInteger, 'reel_qty', ptInput);
      Params.CreateParam(ftString, 'update_userid', ptInput);
      Params.CreateParam(ftString, 'type', ptInput);
      Params.CreateParam(ftString, 'material', ptInput);
      CommandText := 'insert into sajet.g_material '
        + '(rt_id, part_id, datecode, material_no, material_qty,reel_no, reel_qty, update_userid, locate_id, warehouse_id, status, remark, RELEASE_QTY, VERSION, MFGER_NAME, MFGER_PART_NO,type,FIFOCode,factory_id,factory_type) '
        + 'select rt_id, part_id, datecode,material_no, material_qty, :reel_no, :reel_qty, :update_userid, locate_id, warehouse_id, status, remark, RELEASE_QTY, VERSION, MFGER_NAME, MFGER_PART_NO,:type,FIFOCOde,factory_id,factory_type '
        + 'from sajet.g_material where REEL_NO = :material and rownum = 1 ';
      Params.ParamByName('reel_no').AsString := sReel;
      Params.ParamByName('reel_qty').AsInteger := sedtReel.Value;
      lablMsg.Caption := lablMsg.Caption + sReel + '(' + sedtReel.Text + ');';
      Params.ParamByName('update_userid').AsString := UpdateUserid;
      Params.ParamByName('type').AsString := 'S';
      Params.ParamByName('material').AsString := QryMaterial.FieldByName('material_no').AsString;
      Execute;
      Close;

      QryHt.Close;
      Qryht.Params.Clear;
      QryHt.Params.CreateParam(ftString, 'material_no', ptInput);
      Qryht.CommandText:=' insert into sajet.g_ht_material '
                        +'   select * from sajet.g_material '
                        +'   where reel_no=:material_no ';
      qryht.Params.ParamByName('material_no').AsString := sReel;
      qryht.Execute;

      QryHt.Close;
      QryHt.Params.Clear;
      QryHt.Params.CreateParam(ftString, 'material_no', ptInput);
      QryHt.Params.CreateParam(ftString, 'userid', ptInput);
      QryHt.CommandText:=' update sajet.g_material '
                          +'   set type=''S'' '
                          +'     ,update_userid=:userid '
                          +'     ,update_time=sysdate '
                          +'   where reel_no=:material_no ';
      QryHt.Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
      QryHt.Params.ParamByName('userid').AsString := UpdateUserID;
      QryHt.execute;

      if sedtReel.Value = QryMaterial.FieldByName('Material_Qty').AsInteger then
      begin

        close;
        params.Clear;
        Params.CreateParam(ftString, 'material_no', ptInput);
        commandtext:=' insert into sajet.g_ht_material select * from sajet.g_material where Reel_no =:Material_no ';
        Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
        Execute;
        close;
        params.Clear;
        Params.CreateParam(ftString, 'material_no', ptInput);
        commandtext:=' delete from sajet.g_material where Reel_no =:Material_no';
        Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
        Execute;
      end
      else begin
        Params.Clear;
        Params.CreateParam(ftString, 'tqty', ptInput);
        Params.CreateParam(ftString, 'material_no', ptInput);
        CommandText := 'update sajet.g_material '
        + 'set REEL_qty = :tqty '
        + 'where REEL_no = :material_no ';
        Params.ParamByName('tqty').AsString := IntToStr(QryMaterial.FieldByName('material_qty').AsInteger - sedtReel.Value);
        Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
        Execute;

        QryHt.Close;
        Qryht.Params.Clear;
        Qryht.Params.CreateParam(ftString, 'material_no', ptInput);
        Qryht.CommandText:=' insert into sajet.g_ht_material '
                          +'   select * from sajet.g_material '
                          +'   where reel_no=:material_no ';
        qryht.Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
        qryht.Execute;

      end;
      Close;
    end else
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'reel_no', ptInput);
      Params.CreateParam(ftInteger, 'reel_qty', ptInput);
      Params.CreateParam(ftString, 'update_userid', ptInput);
      Params.CreateParam(ftString, 'type', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      CommandText := 'insert into sajet.g_material '
        + '(rt_id, part_id, datecode, material_no, material_qty, update_userid, locate_id, warehouse_id, status, remark, RELEASE_QTY, VERSION, MFGER_NAME, MFGER_PART_NO,type,FIFOCode,factory_id,factory_type ) '
        + 'select rt_id, part_id, datecode, :reel_no, :reel_qty, :update_userid, locate_id, warehouse_id, status, remark, RELEASE_QTY, VERSION, MFGER_NAME, MFGER_PART_NO,:type,FIFOCode,factory_id,factory_type '
        + 'from sajet.g_material where ' + gsType + ' = :material_no and rownum = 1 ';
      Params.ParamByName('reel_no').AsString := sReel;
      Params.ParamByName('reel_qty').AsInteger := sedtReel.Value;
      lablMsg.Caption := lablMsg.Caption + sReel + '(' + sedtReel.Text + ');';
      Params.ParamByName('update_userid').AsString := UpdateUserid;
      Params.ParamByName('type').AsString := 'S';
      Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
      Execute;

      QryHt.Close;
      QryHt.Params.Clear;
      QryHt.Params.CreateParam(ftString, 'material_no', ptInput);
      QryHt.CommandText:=' insert into sajet.g_ht_material '
                        +'    select * from sajet.g_material where ' + gsType + ' = :material_no ';
      QryHt.Params.ParamByName('material_no').AsString :=sReel;
      QryHt.execute;

      QryHt.Close;
      QryHt.Params.Clear;
      QryHt.Params.CreateParam(ftString, 'material_no', ptInput);
      QryHt.Params.CreateParam(ftString, 'userid', ptInput);
      QryHt.CommandText:=' update sajet.g_material '
                          +'   set type=''S'' '
                          +'     ,update_userid=:userid '
                          +'     ,update_time=sysdate '
                          +'   where material_no=:material_no ';
      QryHt.Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
      QryHt.Params.ParamByName('userid').AsString := UpdateUserID;
      QryHt.execute;

      if sedtReel.Value = QryMaterial.FieldByName('Material_Qty').AsInteger then
      begin
        close;
        params.Clear;
        Params.CreateParam(ftString, 'material_no', ptInput);
        commandtext:=' insert into sajet.g_ht_material select * from sajet.g_material where material_no =:Material_no ';
        Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
        Execute;

        close;
        params.Clear;
        Params.CreateParam(ftString, 'material_no', ptInput);
        commandtext:=' delete from sajet.g_material where material_no =:Material_no';
        Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
        Execute;
      end
      else begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'tqty', ptInput);
        Params.CreateParam(ftString, 'material_no', ptInput);
        CommandText := 'update sajet.g_material '
        + 'set material_qty = :tqty '
        + 'where ' + gsType + ' = :material_no ';
        Params.ParamByName('tqty').AsString := IntToStr(QryMaterial.FieldByName('material_qty').AsInteger - sedtReel.Value);
        Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
        Execute;

        QryHt.Close;
        Qryht.Params.Clear;
        Qryht.Params.CreateParam(ftString, 'material_no', ptInput);
        Qryht.CommandText:=' insert into sajet.g_ht_material '
                          +'   select * from sajet.g_material '
                          +'   where ' + gsType + ' = :material_no ';
        qryht.Params.ParamByName('material_no').AsString := QryMaterial.FieldByName('material_no').AsString;
        qryht.Execute;

      end;
      Close;
    end;
    if (QryMaterial.FieldByName('material_qty').AsInteger - sedtReel.Value)>0 then
      lablMsg.Caption := lablMsg.Caption + QryMaterial.FieldByName('material_no').AsString + '(' + IntToStr(QryMaterial.FieldByName('material_qty').AsInteger - sedtReel.Value) + ');';
  end;
  for i := 1 to slReel.Count do
  begin
    sReel := slReel[i - 1];
    if gsType = 'Reel_No' then
      sPrintData := G_getPrintData(6, 19, G_sockConnection, 'DspQryData', 'Reel ID*&*' + sReel, 1, '')
    else
      sPrintData := G_getPrintData(6, 19, G_sockConnection, 'DspQryData', QryMaterial.FieldByName('label_type').AsString + '*&*' + sReel, 1, '');
    if assigned(G_onTransDataToApplication) then
      G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
    else
      showmessage('Not Defined Call Back Function for Code Soft');
  end;
  QryMaterial.Close;
  slReel.Free;
  edtRT.SelectAll;
  edtRT.SetFocus;
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

end.

