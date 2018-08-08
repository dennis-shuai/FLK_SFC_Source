unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, Db, DBClient,
  Menus, ComCtrls, RzButton, RzRadChk;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    ImageLocate: TImage;
    LabTitle2: TLabel;
    sbtnLocate: TSpeedButton;
    LabTitle1: TLabel;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    QryDetail: TClientDataSet;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    edtRT: TEdit;
    lablLocate: TLabel;
    Label8: TLabel;
    StringGrid1: TStringGrid;
    edtMaterial: TEdit;
    sbtnConfirm: TSpeedButton;
    Image1: TImage;
    Image2: TImage;
    SpeedButton1: TSpeedButton;
    cmbStock: TComboBox;
    cmbLocate: TComboBox;
    LvList: TListView;
    Label2: TLabel;
    combLocate: TComboBox;
    Label3: TLabel;
    combPart: TComboBox;
    sbtnRT: TSpeedButton;
    Image3: TImage;
    SpeedButton2: TSpeedButton;
    QryTemp1: TClientDataSet;
    chkPush1: TRzCheckBox;
    chkPush: TCheckBox;
    Label4: TLabel;
    Qryht: TClientDataSet;
    DateTimePicker1: TDateTimePicker;
    edtFIFO: TEdit;
    Label5: TLabel;
    sbtnFifo: TSpeedButton;
    Image4: TImage;
    Label6: TLabel;
    EditORG: TEdit;
    combStock: TEdit;
    procedure FormShow(Sender: TObject);
    procedure edtRTKeyPress(Sender: TObject; var Key: Char);
    procedure edtMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure sbtnLocateClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sbtnConfirmClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure cmbStockChange(Sender: TObject);
    procedure LvListCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure combPartChange(Sender: TObject);
    procedure sbtnRTClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure chkPush1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DateTimePicker1Change(Sender: TObject);
    procedure sbtnFifoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsRTID, gsLocateField: string;
    giRow, giLocate: Integer;
    glMaterial, slLocateId, slStockId, slPartLocate, slPartLocateId, slPartStock: TStringList;
    G_FCID,G_FCCODE,G_FCTYPE:string;
    function CheckRT: Boolean;
    function GetRtSeq(MaterialNo:string):string;
    procedure CheckMaterial;
    procedure ClearData(bClearAll: Boolean);
    Function GetFIFOCode(dDate:TDateTime):string;
    Function GetFCTYPE(sFCID:string):string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uCommData, uLogin;

Function TfDetail.Getfctype(sFCid:string):string;
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

function TfDetail.GetRtSeq(MaterialNo:string):string;
begin
   with qrytemp1 do
   begin
     close;
     params.Clear;
     Params.CreateParam(ftString, 'iMaterial', ptInput);
     commandtext:=' select * from sajet.g_material where material_no=:iMaterial and rownum=1  ';
     Params.ParamByName('iMaterial').AsString := MaterialNo;
     open;
     result:=fieldbyname('remark').AsString;
   end;
end;

procedure TfDetail.CheckMaterial;
var iRow: Integer;
    swhId,swhName:string;
begin

  if (combStock.Text = '') or (combLocate.ItemIndex = -1) then
  begin
    MessageDlg('Please Choose Locator.', mtError, [mbOK], 0);
    exit;
  end;

  if glMaterial.IndexOf(edtMaterial.Text) <> -1 then
  begin
    StringGrid1.Row := glMaterial.IndexOf(edtMaterial.Text) + 1;
    MessageDlg('ID No Duplicate.', mtWarning, [mbOK], 0);
  end
  else
    with QryTemp1 do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'rt_id', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
     { CommandText := 'select rt_seq, material_no, material_qty, sum(reel_qty) reel_qty, part_no, status, a.part_id, option7 '
        + 'from sajet.g_material a, sajet.sys_part b, sajet.g_erp_rt_item c '
        + 'where a.rt_id = :rt_id and material_no = :material_no and a.part_id = b.part_id '
        + 'and a.rt_id = c.rt_id and a.part_id = c.part_id '
        + 'group by material_no, material_qty, part_no, status, a.part_id, option7, rt_seq';  }
     commandtext:= ' select material_no,material_qty,sum(reel_qty) reel_qty, C.warehouse_ID,c.wareHouse_name,part_no, status ,a.part_id ,option7,a.rt_seq,a.fifocode,a.factory_id  '
                  +' from sajet.g_material a,sajet.sys_part b,sajet.sys_warehouse c '
                  + 'where a.rt_id = :rt_id and material_no = :material_no and a.part_id = b.part_id  and a.warehouse_ID =c.warehouse_id '
                  + 'group by material_no, material_qty, part_no,C.warehouse_ID,c.wareHouse_name,status, a.part_id, option7,rt_seq,fifocode,factory_id ';
      Params.ParamByName('rt_id').AsString := gsRTID;
      Params.ParamByName('material_no').AsString := edtMaterial.Text;
      Open;
      if IsEmpty then
      begin
        MessageDlg('ID No. not found.', mtError, [mbOK], 0);
      end
      else
      begin
        if fieldbyname('factory_id').AsString <> G_FCID then
        begin
          MessageDlg('Material ORG IS NOT '+editorg.Text, mtError, [mbOK], 0);
          Exit;
        end;
        if FieldByName('part_no').AsString <> combPart.Text then
        begin
          MessageDlg('Part Not Match.' + #13#13 + 'Material Part: ' + FieldByName('part_no').AsString, mtError, [mbOK], 0);
          Exit;
        end;
        if FieldByName('Reel_Qty').AsInteger <> 0 then
          if FieldByName('Material_Qty').AsInteger <> FieldByName('Reel_Qty').AsInteger then
          begin
               MessageDlg('Reel No not enough.', mtError, [mbOK], 0);
               Exit;
          end;
        if FieldByName('Status').AsString = '1' then
        begin
          MessageDlg('ID No InStock.', mtError, [mbOK], 0);
        end
        else
        begin
          if StringGrid1.Cells[1, 1] = '' then
              iRow := 1
          else
          begin
              iRow := StringGrid1.RowCount;
              StringGrid1.RowCount := StringGrid1.RowCount + 1;
          end;
          sWHName :=FieldByName('warehouse_name').AsString;
          swhID := FieldByName('warehouse_ID').AsString;

          if Trim(combStock.Text) <> Trim( sWHName) then
          begin
              combStock.Text :=  sWHName;

              with QryTemp do
              begin
                  Close;
                  Params.Clear;
                  Params.CreateParam(ftString, 'rt_id', ptInput);
                  CommandText := ' SELECT distinct warehouse_id FROM SAJET.G_MATERIAL A where A.RT_ID =:rt_id and a.TYPE=''P'' ';
                  Params.ParamByName('rt_id').AsString := gsRTID;
                  Open;
                  if IsEmpty then begin
                     MessageDlg('採購沒有設置默認倉別',mtError,[mbOK],0);
                     Exit;
                  end;
                  swhId := FieldByName('warehouse_id').AsString ;

                  Close;
                  Params.Clear;
                  Params.CreateParam(ftString, 'wh_id', ptInput);
                  CommandText := 'select a.locate_id, a.locate_name from sajet.sys_locate a '  +
                                 'where a.warehouse_id = :wh_id  and a.enabled =''Y'' ';
                  Params.ParamByName('wh_id').AsString :=swhId;
                  Open;

                  combLocate.Items.Clear;
                  slPartLocateId.Clear;

                  while not Eof do
                  begin
                    combLocate.Items.Add(FieldByName('locate_name').AsString);
                    slPartLocateId.Add(FieldByName('locate_id').AsString);
                    Next;
                  end;
                  if combLocate.Items.Count = 1 then
                    combLocate.ItemIndex := 0;
                  Close;
              end;

              Exit;

          end;

          StringGrid1.Cells[0, iRow] := IntToStr(iRow);
          StringGrid1.Cells[1, iRow] := FieldByName('Material_No').AsString;
          StringGrid1.Cells[2, iRow] := FieldByName('Part_No').AsString;
          StringGrid1.Cells[3, iRow] := FieldByName('Material_Qty').AsString;
          StringGrid1.Cells[4, iRow] := combStock.Text + '-' + combLocate.Text;
          StringGrid1.Cells[5, iRow] :=  fieldbyname('fifocode').AsString;
          StringGrid1.Cells[6, iRow] := FieldByName('Part_id').AsString;
          StringGrid1.Cells[10, iRow] := FieldByName('option7').AsString;
          StringGrid1.Cells[11, iRow] := FieldByName('rt_seq').AsString;

          StringGrid1.Cells[7, iRow] := swhID ;

          if combLocate.ItemIndex <> -1 then
            StringGrid1.Cells[8, iRow] := slPartLocateId[combLocate.ItemIndex];

          QryTemp.Close;
          glMaterial.Add(StringGrid1.Cells[1, iRow]);
          if StringGrid1.Cells[4, iRow] = '-' then
            Inc(giLocate);
          iRow := LvList.Items.IndexOf(LvList.FindCaption(0, StringGrid1.Cells[1, iRow], True, True, True));
          LvList.Items.Item[iRow].SubItems[0] := '1';
          LvList.Refresh;
          sbtnConfirm.enabled := True;
        end;
      end;
      Close;
    end;
end;

function TfDetail.CheckRT: Boolean;
begin
  Result := True;
  with QryDetail do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RT_NO', ptInput);
    CommandText := 'Select rt_id, status,factory_id ' +
      'From SAJET.G_ERP_RTNO C ' +
      'Where C.ENABLED = ''Y'' AND C.RT_NO = :RT_NO';
    Params.ParamByName('RT_NO').AsString := edtRT.Text;
    Open;
    if IsEmpty then
    begin
      MessageDlg('RT Not Found.', mtWarning, [mbOK], 0);
      Result := False;
      exit;
    end
    else if FieldByName('status').AsString <> '1' then
    begin
      if FieldByName('status').AsString = '0' then
        MessageDlg('Some Material never print.', mtWarning, [mbOK], 0)
      else
        MessageDlg('All Material had InStock.', mtWarning, [mbOK], 0);
      Result := False;
      exit;
    end
    else
    begin

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



      gsRTID := FieldByName('RT_ID').AsString;
      // 預設loacte 取sys_part table中的值
     { Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RT_ID', ptInput);
      CommandText := 'Select part_no, ' + gsLocateField
        + ' From SAJET.G_ERP_RT_ITEM A, SAJET.SYS_PART C '
        + ' Where a.part_id = c.part_id and A.ENABLED = ''Y'' '
        + ' AND A.RT_ID = :RT_ID group by part_no, ' + gsLocateField;
      Params.ParamByName('RT_ID').AsString := gsRTID;
      Open;
      if RecordCount > 0 then
      begin
        while not Eof do
        begin
          combPart.Items.Add(FieldByName('part_no').AsString);
          slPartLocate.Add(FieldByName(gsLocateField).AsString);
          Next;
        end;
      end
      else
      begin
        MessageDlg('Part NO not found.', mtError, [mbOK], 0);
        Result := False;
        exit;
      end;
      }
     //預設loacte 取sys_part_factory table中的值　 change by key 2008/07/23　
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RT_ID', ptInput);
      Params.CreateParam(ftString, 'factory_ID', ptInput);
      CommandText := 'Select c.part_no, b.locate_id '
                    +' From SAJET.G_ERP_RT_ITEM A, '
                    +' sajet.sys_part_factory b ,'
                    +' SAJET.SYS_PART C '
                    +' Where A.RT_ID = :RT_ID '
                    +' and b.factory_id(+) = :FACTORY_ID '
                    +' and a.part_id = c.part_id '
                    +' and A.ENABLED = ''Y''  '
                    +' AND A.part_id = b.part_id(+) '
                    +' group by c.part_no,b.locate_id ';
      Params.ParamByName('RT_ID').AsString := gsRTID;
      Params.ParamByName('factory_ID').AsString := G_FCID;
      Open;
      if RecordCount > 0 then
      begin
        while not Eof do
        begin
          combPart.Items.Add(FieldByName('part_no').AsString);
          slPartLocate.Add(FieldByName('locate_id').AsString);
          Next;
        end;
      end
      else
      begin
        MessageDlg('Part NO not found.', mtError, [mbOK], 0);
        Result := False;
        exit;
      end;






      combPart.ItemIndex := 0;
      combPartChange(Self);
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RT_ID', ptInput);
      CommandText := 'Select material_no ' +
        'From SAJET.G_material ' +
        'Where RT_ID = :RT_ID and locate_id is null group by material_no order by material_no ';
      Params.ParamByName('RT_ID').AsString := gsRTID;
      Open;
      while not Eof do
      begin
        with LvList.Items.Add do
        begin
          Caption := Fieldbyname('Material_No').AsString;
          Subitems.Add('0');
        end;
        Next;
      end;
      Close;
    end;
  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
  slLocateId := TStringList.Create;
  slStockId := TStringList.Create;
  slPartLocate := TStringList.Create;
  slPartLocateId := TStringList.Create;
  slPartStock := TStringList.Create;
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  LvList.Column[0].Width := LvList.Width - 3;
  glMaterial := TStringList.Create;
  edtRT.SetFocus;
  StringGrid1.Cells[1, 0] := 'ID No';
  StringGrid1.Cells[2, 0] := 'Part No';
  StringGrid1.Cells[3, 0] := 'Qty';
  StringGrid1.Cells[4, 0] := 'Locator';
  StringGrid1.Cells[5, 0] := 'FIFO Code';
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
    Params.ParamByName('dll_name').AsString := 'MATERIALINCOMINGDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Locate'' ';
    Open;
    gsLocateField := FieldByName('param_name').AsString;
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where Param_Name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then
    begin
      edtRT.CharCase := ecUpperCase;
      edtMaterial.CharCase := ecUpperCase;
    end;
    {
    Close;
    Params.Clear;
    CommandText := 'select warehouse_id, warehouse_name '
      + 'from sajet.sys_warehouse where enabled = ''Y'' order by warehouse_name';

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
      combStock.Items.Add(FieldByName('warehouse_name').AsString);
      cmbStock.Items.Add(FieldByName('warehouse_name').AsString);
      slStockId.Add(FieldByName('warehouse_id').AsString);
      Next;
    end;
    //combStock.Items := cmbStock.Items;
    }
    Close;
  end;
  edtFiFO.Text:=GetFIFOCode(now());
  DateTimePicker1.DateTime:=now();
  if edtrt.Enabled=false then
     edtrt.Enabled :=True;
  edtrt.SelectAll ;
  edtrt.SetFocus ;
end;

procedure TfDetail.edtRTKeyPress(Sender: TObject; var Key: Char);
var swhId:string;
begin
  if Ord(Key) = vk_Return then
  begin
    ClearData(False);
    if CheckRT then
    begin
      edtrt.Enabled:=False;
      edtMaterial.Enabled := True;
      edtMaterial.SetFocus;

      with QryTemp do
      begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'rt_id', ptInput);
          CommandText := ' SELECT distinct warehouse_id FROM SAJET.G_MATERIAL A where A.RT_ID =:rt_id and a.TYPE=''P'' ';
          Params.ParamByName('rt_id').AsString := gsRTID;
          Open;
          if IsEmpty then begin
             MessageDlg('採購沒有設置默認倉別',mtError,[mbOK],0);
             Exit;
          end;
          swhId := FieldByName('warehouse_id').AsString ;

          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'wh_id', ptInput);
          CommandText := 'select b.warehouse_name,a.locate_id, a.locate_name from sajet.sys_locate a ,sajet.sys_warehouse b '  +
                         'where a.warehouse_id =b.warehouse_id and a.warehouse_id = :wh_id and b.enabled = ''Y'' and a.enabled =''Y'' ';
          Params.ParamByName('wh_id').AsString :=swhId;
          Open;

          combStock.Text := FieldByName('warehouse_name').AsString ;

          combLocate.Items.Clear;
          slPartLocateId.Clear;
          while not Eof do
          begin
            combLocate.Items.Add(FieldByName('locate_name').AsString);
            slPartLocateId.Add(FieldByName('locate_id').AsString);
            Next;
          end;
          if combLocate.Items.Count = 1 then
            combLocate.ItemIndex := 0;
          Close;
      end;
    end
    else
    begin
      edtRT.SelectAll;
      edtRT.SetFocus;
    end;
  end;
end;

procedure TfDetail.edtMaterialKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
    CheckMaterial;
    edtMaterial.SelectAll;
    edtMaterial.SetFocus;
  end;
end;

procedure TfDetail.StringGrid1DblClick(Sender: TObject);
begin
  if StringGrid1.Cells[1, giRow] = '' then Exit;
  edtMaterial.Text := StringGrid1.Cells[1, giRow];
  if StringGrid1.Cells[4, giRow] <> '-' then
  begin

    cmbStock.Text := StringGrid1.Cells[7, giRow];
    cmbLocate.ItemIndex := slLocateId.IndexOf(StringGrid1.Cells[8, giRow]);
  end
  else
  begin
    cmbStock.Text := '';
    cmbLocate.Items.Clear;
  end;
  edtFIFO.Text:=StringGrid1.Cells[5, giRow];
  cmbLocate.Visible := True;
  cmbStock.Visible := True;
  cmbLocate.Visible := True;
  lablLocate.Visible := True;
  sbtnLocate.Visible := True;
  ImageLocate.Visible := True;
  label5.Visible:=true;
  edtFIFO.Visible:=true;
  DateTimePicker1.Visible:=true;
  sbtnfifo.Visible:=true;
  Image4.Visible:=true;
  cmbStock.SetFocus;
  edtMaterial.Enabled := False;
end;

procedure TfDetail.StringGrid1SelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  giRow := ARow;
end;

procedure TfDetail.sbtnLocateClick(Sender: TObject);
begin
  if cmbLocate.ItemIndex = -1 then Exit;
  if StringGrid1.Cells[4, giRow] = '-' then giLocate := giLocate - 1;
  StringGrid1.Cells[4, giRow] := cmbStock.Text + '-' + cmbLocate.Text;
  StringGrid1.Cells[7, giRow] := slStockId[cmbStock.ItemIndex];
  StringGrid1.Cells[8, giRow] := slLocateId[cmbLocate.ItemIndex];
  cmbLocate.Visible := False;
  cmbStock.Visible := False;
  lablLocate.Visible := False;
  sbtnLocate.Visible := False;
  ImageLocate.Visible := False;
  label5.Visible:=false;
  edtFIFO.Visible:=false;
  DateTimePicker1.Visible:=false;
  sbtnfifo.Visible:=false;
  Image4.Visible:=false;
  edtMaterial.Enabled := True;
  edtMaterial.SelectAll;
  edtMaterial.SetFocus;
end;

procedure TfDetail.FormDestroy(Sender: TObject);
begin
  slLocateId.Free;
  slStockId.Free;
  glMaterial.Free;
  slPartLocate.Free;
  slPartLocateId.Free;
  slPartStock.Free;
end;

procedure TfDetail.sbtnConfirmClick(Sender: TObject);
var i: Integer;
begin

  if LvList.Items.Count <> StringGrid1.RowCount - 1 then
    MessageDlg('Not Complete!', mtWarning, [mbOK], 0)
  else if giLocate <> 0 then
  begin
    MessageDlg('Please Define Locator!', mtWarning, [mbOK], 0);
    for i := 1 to StringGrid1.RowCount - 1 do
      if StringGrid1.Cells[4, i] = '-' then
      begin
        StringGrid1.Row := i;
        break;
      end;
  end
  else
  begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.Create.CreateParam(ftString, 'output_qty', ptInput);
    QryTemp.Params.Create.CreateParam(ftString, 'RT_ID', ptInput);
    QryTemp.Params.Create.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.CommandText := 'update sajet.g_erp_rt_item '
      + 'set output_qty = output_qty + :output_qty '
      + 'where rt_id = :rt_id and part_id = :part_id';
    QryTemp.Close;
    with QryDetail do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'locate', ptInput);
      Params.CreateParam(ftString, 'warehouse_id', ptInput);
      Params.CreateParam(ftString, 'update_userid', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftString, 'FIFO', ptInput);
      CommandText := 'update sajet.g_material '
          + 'set locate_id = :locate, status = ''1'', warehouse_id = :warehouse_id, '
          + 'update_userid = :update_userid, update_time = sysdate,type=''I'',FIFOCODE=:FIFO '
          + 'where material_no = :material_no ';
      for i := 1 to StringGrid1.RowCount - 1 do
      begin
        Close;
        Params.ParamByName('locate').AsString := StringGrid1.Cells[8, i];
        Params.ParamByName('warehouse_id').AsString := StringGrid1.Cells[7, i];
        Params.ParamByName('update_userid').AsString := UpdateUserId;
        Params.ParamByName('material_no').AsString := StringGrid1.Cells[1, i];
        Params.ParamByName('FIFO').AsString :=StringGrid1.Cells[5, i];
        Execute;
        close;

        qryht.Close;
        qryht.Params.CreateParam(ftString, 'material_no', ptInput);
        qryht.CommandText:=' insert into sajet.g_ht_material '
                          +' select * from sajet.g_material where material_no=:material_no ';
        qryht.Params.ParamByName('material_no').AsString := StringGrid1.Cells[1, i];
        qryht.Execute;

        QryTemp.Close;
        QryTemp.Params.ParamByName('output_qty').AsString := StringGrid1.Cells[3, i];
        QryTemp.Params.ParamByName('rt_id').AsString := gsRTId;
        QryTemp.Params.ParamByName('part_id').AsString := StringGrid1.Cells[6, i];
        QryTemp.Execute;
        QryTemp.Close;
        with sproc do
        begin
          try
            Close;
            DataRequest('SAJET.MES_ERP_RT');
            FetchParams;
            Params.ParamByName('TRTNO').AsString := edtRT.Text;
            Params.ParamByName('TRTSEQ').AsString := StringGrid1.Cells[11, i];    //GetRtSeq(StringGrid1.Cells[1, i]);//
            Params.ParamByName('TPART').AsString := StringGrid1.Cells[2, i];
            Params.ParamByName('TITEMID').AsString := StringGrid1.Cells[10, i];
            Params.ParamByName('TQTY').AsString := StringGrid1.Cells[3, i];
            Params.ParamByName('TSUBINV').AsString := Copy(StringGrid1.Cells[4, i], 1, Pos('-', StringGrid1.Cells[4, i]) - 1);
            Params.ParamByName('TLOCATOR').AsString := Copy(StringGrid1.Cells[4, i], Pos('-', StringGrid1.Cells[4, i]) + 1, Length(StringGrid1.Cells[4, i]));
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
      //處理NG_QTY及 RT Status
    with sproc do
    begin
      try
        Close;
        DataRequest('SAJET.MES_ERP_RT_NG');
        FetchParams;
        Params.ParamByName('TRTNO').AsString := edtRT.Text;
        Params.ParamByName('TRTID').AsString := gsRTId;
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
    sbtnConfirm.Enabled := False;
    MessageDlg('RT No: ' + edtRT.Text + ' Incoming OK.', mtInformation, [mbOK], 0);
    ClearData(True);
  end;
end;

procedure TfDetail.ClearData(bClearAll: Boolean);
begin
  StringGrid1.Rows[1].Clear;
  StringGrid1.RowCount := 2;
  cmbLocate.Visible := False;
  cmbStock.Visible := False;
  lablLocate.Visible := False;
  sbtnLocate.Visible := False;
  ImageLocate.Visible := False;
  sbtnConfirm.Enabled := False;
  LvList.Items.Clear;
  giRow := -1;
  glMaterial.Clear;
  giLocate := 0;
  cmbLocate.Visible := False;
  cmbStock.Visible := False;
  lablLocate.Visible := False;
  sbtnLocate.Visible := False;
  ImageLocate.Visible := False;
  edtMaterial.Text := '';
  edtMaterial.Enabled := False;
  combPart.Items.Clear;
  combLocate.Items.Clear;
  //combStock.ItemIndex := -1;
  slPartLocate.Clear;
  slPartLocateId.Clear;
  slPartStock.Clear;
  editorg.Text :='';
  if bClearAll then
  begin
    IF edtRt.Enabled=False then
       edtrt.Enabled :=True;
    edtRt.Text := '';
    edtRT.Enabled := True;
    edtRT.SetFocus;
  end;
end;

procedure TfDetail.SpeedButton1Click(Sender: TObject);
begin
  if MessageDlg('Clear Data?', mtWarning, [mbYes, mbNo], 0) = mrYes then
    ClearData(True);
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

procedure TfDetail.LvListCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if StrtoIntDef(Item.SubItems.Strings[0], 0) = 0 then
    LvList.Canvas.brush.Color := clred;
end;

procedure TfDetail.combPartChange(Sender: TObject);
begin
{  if slPartLocate[combPart.ItemIndex] = '' then
  begin
    combStock.ItemIndex := -1;
    combLocate.Items.Clear;
  end
  else
  begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'locate_id', ptInput);
    QryTemp.CommandText := 'select locate_name, warehouse_name, b.warehouse_id, locate_id from sajet.sys_part a, sajet.sys_locate b, sajet.sys_warehouse c '
      + 'where b.locate_id = :locate_id and b.warehouse_id = c.warehouse_id and rownum = 1';
    QryTemp.Params.ParamByName('locate_id').AsString := slPartLocate[combPart.ItemIndex];
    QryTemp.Open;
    if QryTemp.RecordCount > 0 then
    begin
      combStock.ItemIndex := combStock.Items.IndexOf(QryTemp.FieldByName('warehouse_name').AsString);
      if combStock.ItemIndex <> -1 then
      begin
        combStockChange(Self);
        combLocate.ItemIndex := slPartLocateId.IndexOf(slPartLocate[combPart.ItemIndex]);
      end;

    end
    else
    begin
      combStock.ItemIndex := -1;
      combLocate.ItemIndex := -1;
    end;
    QryTemp.Close;
  end;
  }
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
        + 'and c.status = 1 and c.vendor_id = b.vendor_id '
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
      //edtRT.SetFocus;
      //edtRT.SelectAll;
    end;
    free;
  end;
end;

procedure TfDetail.SpeedButton2Click(Sender: TObject);
var i: Integer;
begin
 // if combStock.ItemIndex = -1 then Exit;
  if combLocate.ItemIndex = -1 then Exit;
  if combPart.ItemIndex = -1 then Exit;
  for i := 1 to StringGrid1.RowCount - 1 do
    if StringGrid1.Cells[2, i] = combPart.Text then
    begin
      if StringGrid1.Cells[4, i] = '-' then giLocate := giLocate - 1;
      StringGrid1.Cells[4, i] := combStock.Text + '-' + combLocate.Text;
      StringGrid1.Cells[7, i] := combStock.Text;
      if combLocate.ItemIndex <> -1 then
        StringGrid1.Cells[8, i] := slPartLocateId[combLocate.ItemIndex];
    end;
end;

procedure TfDetail.chkPush1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  fLogin := TfLogin.Create(Self);
  with fLogin do
  begin
    if ShowModal = mrOK then
    begin
      chkPush.Checked := not (chkPush.Checked);
    end;
  end;
end;

procedure TfDetail.DateTimePicker1Change(Sender: TObject);
begin
   edtFifo.Text:=GetFIFOCode(DateTimePicker1.DateTime);
end;

procedure TfDetail.sbtnFifoClick(Sender: TObject);
begin
  if trim(edtfifo.Text)='' then exit;
  StringGrid1.Cells[5, giRow]:= trim(edtFIFO.Text);
  cmbLocate.Visible := False;
  cmbStock.Visible := False;
  lablLocate.Visible := False;
  sbtnLocate.Visible := False;
  ImageLocate.Visible := False;
  label5.Visible:=false;
  edtFIFO.Visible:=false;
  DateTimePicker1.Visible:=false;
  sbtnfifo.Visible:=false;
  Image4.Visible:=false;
  edtMaterial.Enabled := True;
  edtMaterial.SelectAll;
  edtMaterial.SetFocus;
end;

end.

