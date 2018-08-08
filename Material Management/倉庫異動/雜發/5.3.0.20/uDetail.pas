unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, Mask, RzButton, RzRadChk;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    Image3: TImage;
    LabTitle2: TLabel;
    sbtnCommit: TSpeedButton;
    LabTitle1: TLabel;
    QryMaterial: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    QryDetail: TClientDataSet;
    DataSource2: TDataSource;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    Label2: TLabel;
    Bevel2: TBevel;
    sedtQty: TSpinEdit;
    Label6: TLabel;
    Label12: TLabel;
    edtMaterial: TEdit;
    lablLocate: TLabel;
    Image1: TImage;
    sbtnClear: TSpeedButton;
    lablMsg: TLabel;
    Label4: TLabel;
    edtVersion: TEdit;
    Label3: TLabel;
    edtPart: TEdit;
    edtStock: TEdit;
    edtLocate: TEdit;
    Label5: TLabel;
    edtDateCode: TEdit;
    edtRT: TMaskEdit;
    combAlias: TComboBox;
    sgData: TStringGrid;
    Memo1: TMemo;
    SpeedButton1: TSpeedButton;
    Image2: TImage;
    PopupMenu1: TPopupMenu;
    Delete1: TMenuItem;
    chkPush: TRzCheckBox;
    cmbFactory: TComboBox;
    Label8: TLabel;
    sbtnalias: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure edtRTKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnCommitClick(Sender: TObject);
    procedure edtMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnClearClick(Sender: TObject);
    procedure combAliasChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure sgDataSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cmbFactoryChange(Sender: TObject);
    procedure sbtnaliasClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelField, gsRTID, gsLocateField, gsOrgID,sCaps: string;
    FcID, UserFcID: string ;
    slAlias: TStringList;
    sCnt,FieldsRow : Integer;
    function CheckMaterial(var sType: string): Boolean;
    function checkFIFO(MaterailNo:string;VAR NOCHECK:STRING):string;
    function SendMsg:boolean;
    procedure CheckSource;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, DllInit, {uCommData,}uLogin, Udata;

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

procedure TfDetail.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  sgData.Cells[0,0] :='No';
  sgData.Cells[1,0] :='ID No';
  sgData.Cells[2,0] :='Part No';
  sgData.Cells[3,0] :='Date Code';
  sgData.Cells[4,0] :='Version';
  sgData.Cells[5,0] :='Qty';
  sgData.Cells[6,0] :='Warehouse';
  sgData.Cells[7,0] :='Locator';
  sgData.ColWidths[8]:=-1;
  sgData.ColWidths[9]:=-1;
  sgData.ColWidths[10]:=-1;
  sCnt:=0;
  edtRT.SetFocus;
  slAlias := TStringList.Create;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Label Type'' ';
    Open;
    gsLabelField := FieldByName('param_name').AsString;
    {
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''ORG ID'' ';
    Open;
    gsOrgID := FieldByName('param_value').AsString;
    }
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where Param_Name = ''Material Caps Lock'' ';
    Open;
    if RecordCount=0 then
      sCaps:= 'N'
    else
      sCaps:= 'Y';
    Close;
    Params.Clear;
    CommandText := 'select alias_name, alias_code from sajet.sys_alias where enabled=''Y'' '
      + 'order by alias_name ';
    Open;
    while not Eof do
    begin
      combAlias.Items.Add(FieldByName('alias_name').AsString);
      slAlias.Add(FieldByName('alias_code').AsString);
      Next;
    end;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'ABNORMALFEEDDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
    Close;

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EMP_ID', ptInput);
    CommandText := 'Select NVL(FACTORY_ID,0) FACTORY_ID ' +
      'From SAJET.SYS_EMP ' +
      'Where EMP_ID = :EMP_ID ';
    Params.ParamByName('EMP_ID').AsString := UpdateUserID;
    Open;
    if RecordCount = 0 then
    begin
      Close;
      MessageDlg('Account Error !!', mtError, [mbOK], 0);
      Exit;
    end;
    UserFcID := Fieldbyname('FACTORY_ID').AsString;
    FcID := UserFcID;
    Close;
  end;

  cmbFactory.Items.Clear;
  with QryTemp do
  begin
    Close;
    CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
      'From SAJET.SYS_FACTORY ' +
      'Where ENABLED = ''Y'' ';
    Open;
    while not Eof do
    begin
      cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString);
      if Fieldbyname('FACTORY_ID').AsString = UserFcID then
      begin
        cmbFactory.ItemIndex := cmbFactory.Items.Count - 1;
      end;
      Next;
    end;
    Close;
  end;
  { change by key 2008/05/05
  　一個user 可以作業多個org 的工令。
  禁用如下語句

  cmbFactory.Enabled := (UserFcID = '0');
  }
  if UserFcID = '0' then
    cmbFactory.ItemIndex := 0;

  cmbFactoryChange(Self);


  end;
end;

procedure TfDetail.edtRTKeyPress(Sender: TObject; var Key: Char);
Var i,j : Integer;
begin
  lablMsg.Caption := '';
  if Ord(Key) = vk_Return then
  begin
    CheckSource;
    if sCaps='Y' then
     edtRT.Text:=UpperCase(edtRT.Text);
    Memo1.Clear;
    for i:=1 to sgData.RowCount-1  do
      for j:=0 to 11 do
      sgData.Cells[j,i]:='';

    combAlias.SelectAll;
    combAlias.SetFocus;
  end;
end;

procedure TfDetail.sbtnCommitClick(Sender: TObject);
var sType,spart_id: string;
  i,j :Integer;
begin
  if MessageDlg('The ORG IS '''+gsOrgID+''',Are you sure ?',
        mtConfirmation, [mbYes, mbNo], 0) = mrNo then
  begin
     exit;
  end;

  for i:=1 to sgData.RowCount-1  do
  begin
    sType:=sgData.Cells[8,i];
    spart_id:=sgData.Cells[9,i];
  with QryTemp do
  begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'update_userid', ptInput);
    QryTemp.Params.CreateParam(ftString, 'material_no', ptInput);
    QryTemp.CommandText := 'insert into sajet.g_pick_list '
      + '(work_order,update_userid, material_no, part_id, qty) ';
    if sType = 'Material' then
      QryTemp.CommandText := QryTemp.CommandText
        + 'values( :work_order, :update_userid, :material_no, :part_id, :material_qty) '
    else
    begin
      QryTemp.CommandText := QryTemp.CommandText
        + 'select :work_order, :update_userid, reel_no, part_id, reel_qty ';
      QryTemp.CommandText := QryTemp.CommandText + 'from sajet.g_material ';
      if sType = 'Material1' then
        QryTemp.CommandText := QryTemp.CommandText + 'where material_no = :material_no'
      else
        QryTemp.CommandText := QryTemp.CommandText + 'where reel_no = :material_no ';
    end;
    QryTemp.Params.ParamByName('work_order').AsString := edtRT.Text;
    QryTemp.Params.ParamByName('update_userid').AsString := UpdateUserid;
    QryTemp.Params.ParamByName('material_no').AsString := sgData.Cells[1,i];
    if sType = 'Material' then
    begin
      QryTemp.Params.ParamByName('part_id').AsString := spart_id;
      QryTemp.Params.ParamByName('material_qty').AsInteger := StrToIntDef(sgData.Cells[5,i],0);
    end;
    QryTemp.Execute;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
    QryTemp.Params.CreateParam(ftString, 'userid', ptInput);
    QryTemp.CommandText:=' update sajet.g_material '
                        +'   set Type=''O'' '
                        +'      ,update_userid=:userid '
                        +'      ,update_time=sysdate ';
    if sType = 'Reel' then
      QryTemp.CommandText:= QryTemp.CommandText+' where reel_no=:reel_no '
    else
      QryTemp.CommandText:= QryTemp.CommandText+' where material_no=:reel_no ';
    QryTemp.Params.ParamByName('reel_no').AsString := sgData.Cells[1,i];
    QryTemp.Params.ParamByName('userid').AsString := UpdateUserID;
    QryTemp.Execute;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
    if sType = 'Reel' then
      QryTemp.CommandText := 'insert into sajet.g_ht_material '
        //+ 'select * from sajet.g_material where reel_no = :reel_no and rt_id is not null '
          +'select * from sajet.g_material where reel_no = :reel_no  '
    else
      QryTemp.CommandText := 'insert into sajet.g_ht_material '
        //+ 'select * from sajet.g_material where material_no = :reel_no and rt_id is not null ';
        + 'select * from sajet.g_material where material_no = :reel_no  ';
    QryTemp.Params.ParamByName('reel_no').AsString := sgData.Cells[1,i];
    QryTemp.Execute;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
    if sType = 'Reel' then
      QryTemp.CommandText := 'delete from sajet.g_material '
        + 'where reel_no = :reel_no '
    else
      QryTemp.CommandText := 'delete from sajet.g_material '
        + 'where material_no = :reel_no ';
    QryTemp.Params.ParamByName('reel_no').AsString := sgData.Cells[1,i];
    QryTemp.Execute;
    QryTemp.Close;
    with sproc do
    begin
      try
        Close;
        DataRequest('SAJET.MES_ERP_MISC');
        FetchParams;
        Params.ParamByName('TSOURCE').AsString := edtRT.Text;
        Params.ParamByName('talias').AsString := slAlias[combAlias.ItemIndex];
        Params.ParamByName('TPARTNO').AsString := sgData.Cells[2,i];
        Params.ParamByName('TITEMID').AsString := sgData.Cells[10,i];
        Params.ParamByName('TVERSION').AsString := sgData.Cells[4,i];
        Params.ParamByName('TSUBINV').AsString := sgData.Cells[6,i];
        Params.ParamByName('TLOCATOR').AsString := sgData.Cells[7,i];
        Params.ParamByName('TQTY').AsString := sgData.Cells[5,i];
        Params.ParamByName('TTRXNTYPE').AsString := 'D3';
        Params.ParamByName('TORGID').AsString := gsOrgID;
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
    lablMsg.Caption := 'ID No: ' + sgData.Cells[1,i] + ' Feed OK.';
    Memo1.Lines.Add(lablMsg.Caption);
  end;

  end;
  for i:=1 to sgData.RowCount-1  do
    for j:=0 to 11 do
    sgData.Cells[j,i]:='';
  sgData.RowCount:=2;
  sCnt:=0;
  edtRT.Enabled:=True;
  combAlias.Enabled:=True;
  sbtnalias.Enabled :=true;
  sbtnCommit.Enabled:=False;
  edtPart.Text := '';
  sedtQty.Value := 0;
  edtStock.Text := '';
  edtLocate.Text := '';
  edtDateCode.Text := '';
  edtMaterial.Text := '';
  edtVersion.Text := '';
  edtMaterial.SetFocus;
  edtPart.Text := '';
  edtDateCode.Text := '';
  QryDetail.Close;
  edtRT.SelectAll;
  edtRT.SetFocus;
end;

function TfDetail.CheckMaterial(var sType: string): Boolean;
var iQty: Integer;
begin
  Result := True;
  QryDetail.Close;
  QryDetail.Params.Clear;
  QryDetail.Params.CreateParam(ftString, 'material_no', ptInput);
  QryDetail.CommandText := 'select reel_no, material_no, part_no, a.part_id, a.version, a.datecode, option7, a.factory_id '
    + 'from sajet.g_material a, sajet.sys_part b '
    + 'where material_no = :material_no and rownum = 1 '
    + 'and a.part_id = b.part_id ';
  QryDetail.Params.ParamByName('material_no').AsString := edtMaterial.Text;
  QryDetail.Open;
  sType := 'Material';
  if QryDetail.IsEmpty then
  begin
    QryDetail.Close;
    QryDetail.Params.Clear;
    QryDetail.Params.CreateParam(ftString, 'material_no', ptInput);
    QryDetail.CommandText := 'select reel_no, material_no, part_no, a.part_id, a.version, a.datecode, option7, a.factory_id '
      + 'from sajet.g_material a, sajet.sys_part b '
      + 'where reel_no = :material_no and rownum = 1 '
      + 'and a.part_id = b.part_id ';
    QryDetail.Params.ParamByName('material_no').AsString := edtMaterial.Text;
    QryDetail.Open;
    if QryDetail.IsEmpty then
    begin
      MessageDlg('ID No: ' + edtMaterial.Text + ' not found.', mtError, [mbOK], 0);
      edtMaterial.SelectAll;
      edtMaterial.SetFocus;
      Result := False;
      Exit;
    end;
    sType := 'Reel';
  end;
  QryTemp.Close;
  QryTemp.Params.Clear;
  QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
  QryTemp.CommandText := 'select reel_no, reel_qty, material_no, material_qty, status, '
    + 'a.part_id, a.datecode, d.warehouse_name, e.locate_name, a.factory_id '
    + 'from sajet.g_material a, sajet.sys_warehouse d, sajet.sys_locate e '
    + 'where ' + sType + '_No = :reel_no '
    + 'and a.locate_id = e.locate_id(+) and a.warehouse_id = d.warehouse_id(+) ';
  QryTemp.Params.ParamByName('reel_no').AsString := edtMaterial.Text;
  QryTemp.Open;
  if QryTemp.FieldByName('warehouse_name').AsString = '' then
  begin
    MessageDlg('ID No: ' + edtMaterial.Text + ' not InStock.', mtError, [mbOK], 0);
    edtMaterial.SelectAll;
    edtMaterial.SetFocus;
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
  if QryTemp.FieldByName('Status').AsString <> '1' then
  begin
    MessageDlg('ID No: ' + edtMaterial.Text + ' not InStock.', mtError, [mbOK], 0);
    edtMaterial.SelectAll;
    edtMaterial.SetFocus;
    Result := False;
  end;

  if QryTemp.FieldByName('factory_id').AsString <> fcid then
  begin
    MessageDlg('ID No: ' + edtMaterial.Text + ' ORG IS NOT '+cmbfactory.Text, mtError, [mbOK], 0);
    edtMaterial.SelectAll;
    edtMaterial.SetFocus;
    Result := False;
  end;

  edtPart.Text := QryDetail.FieldByName('part_no').AsString;
  edtStock.Text := QryTemp.FieldByName('warehouse_name').AsString;
  edtLocate.Text := QryTemp.FieldByName('locate_name').AsString;
  edtVersion.Text := QryDetail.FieldByName('version').AsString;
  edtDateCode.Text := QryDetail.FieldByName('datecode').AsString;
  sedtQty.Value := iQty;
  QryTemp.Close;
end;

procedure TfDetail.edtMaterialKeyPress(Sender: TObject; var Key: Char);
var sType,sNoCheck,sStr: string;
    i : Integer;
begin
  if Ord(Key) = vk_Return then
  begin
    SpeedButton1.Enabled:=false;
    if sCaps='Y' then
     edtMaterial.Text:=UpperCase(edtMaterial.Text);
    for i:=1 to sgData.RowCount-1  do
       if sgData.Cells[1, i]=edtMaterial.Text then
       begin
         MessageDlg('ID NO Dup!', mtError, [mbOK], 0);
         edtMaterial.SelectAll;
         edtMaterial.SetFocus;
         exit;
       end;

    sStr:= checkFIFO(TRIM(edtMaterial.Text),sNoCheck);
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
    if CheckMaterial(sType) then
    begin
      edtMaterial.SelectAll;
    end;
    SpeedButton1.Enabled:=True;
  end;
end;

procedure TfDetail.sbtnClearClick(Sender: TObject);
begin
  edtPart.Text := '';
  edtRT.Text := '';
  combAlias.ItemIndex := -1;
  sedtQty.Value := 0;
  edtStock.Text := '';
  edtLocate.Text := '';
  edtDateCode.Text := '';
  edtMaterial.Text := '';
  edtVersion.Text := '';
  memo1.Clear;
  if edtRT.Enabled=true then
  begin
    edtRT.Text := '';
    combAlias.ItemIndex := -1;
    edtRT.SetFocus;
  end else
  begin
    edtPart.SetFocus;
  end;
end;

procedure TfDetail.combAliasChange(Sender: TObject);
begin
  edtMaterial.SelectAll;
  edtMaterial.SetFocus;
end;

procedure TfDetail.SpeedButton1Click(Sender: TObject);
var sType1: string;
begin
  if sCaps='Y' then
  begin
     edtRT.Text:=UpperCase(edtRT.Text);
     edtMaterial.Text:=UpperCase(edtMaterial.Text);
  end;
  if edtRT.Text = '' then
  begin
    MessageDlg('Please input Source!', mtError, [mbOK], 0);
    edtRT.SelectAll;
    edtRT.SetFocus;
    Exit;
  end;
  if Length(Trim(edtRT.Text)) <> 10 then
  begin
    MessageDlg('Source must has 10 characters!', mtError, [mbOK], 0);
    edtRT.SelectAll;
    edtRT.SetFocus;
    Exit;
  end;
  CheckSource;
  if combAlias.ItemIndex = -1 then
  begin
    MessageDlg('Please input Alias!', mtError, [mbOK], 0);
    combAlias.SelectAll;
    combAlias.SetFocus;
    Exit;
  end;
  if edtMaterial.Text = '' then
  begin
    MessageDlg('Please input ID No!', mtError, [mbOK], 0);
    edtMaterial.SelectAll;
    edtMaterial.SetFocus;
    Exit;
  end;
  if not CheckMaterial(sType1) then Exit;

  if sCnt=0 then
    sgData.RowCount:=2
  else
    sgData.RowCount:=sgData.RowCount+1;

  sgData.Cells[0, sCnt+1]:=IntToStr(sCnt+1);
  sgData.Cells[1, sCnt+1]:=edtMaterial.Text;
  sgData.Cells[2, sCnt+1]:=edtPart.Text;
  sgData.Cells[3, sCnt+1]:=edtDateCode.Text;
  sgData.Cells[4, sCnt+1]:=edtVersion.Text;
  sgData.Cells[5, sCnt+1]:=sedtQty.Text;
  sgData.Cells[6, sCnt+1]:=edtStock.Text;
  sgData.Cells[7, sCnt+1]:=edtLocate.Text;
  sgData.Cells[8, sCnt+1]:=sType1;
  sgData.Cells[9, sCnt+1]:=QryDetail.FieldByName('part_id').AsString;
  sgData.Cells[10, sCnt+1]:=QryDetail.FieldByName('option7').AsString;

  sgData.row:=sgData.rowcount-1;
  Inc(sCnt);
  edtRT.Enabled:=False;
  combAlias.Enabled:=False;
  sbtnalias.Enabled :=false;
  sbtnCommit.Enabled:=True;
  edtPart.Text := '';
  edtMaterial.Text := '';
  edtDateCode.Text := '';
  edtStock.Text := '';
  edtLocate.Text := '';
  sedtQty.Value := 0;
  edtMaterial.SelectAll;
  edtMaterial.SetFocus;
  SpeedButton1.Enabled:=False;

  if cmbfactory.Enabled = true then
     cmbfactory.Enabled :=false;
end;

procedure TfDetail.Delete1Click(Sender: TObject);
var i:integer;
begin
  if (sgData.RowCount=2) then
  begin
    sgData.Cells[0,1]:= '';
    sgData.Cells[1,1]:= '';
    sgData.Cells[2,1]:= '';
    sgData.Cells[3,1]:= '';
    sgData.Cells[4,1]:= '';
    sgData.Cells[5,1]:= '';
    sgData.Cells[6,1]:= '';
    sgData.Cells[7,1]:= '';
    sgData.Cells[8,1]:= '';
    sgData.Cells[9,1]:= '';
    sgData.Cells[10,1]:= '';
    sCnt:=0;
    sbtnCommit.Enabled:=False;
  end
  else begin
    for i:=FieldsRow to sgData.RowCount-1 do
    begin
      sgData.Cells[0,i]:= inttostr(i);
      sgData.Cells[1,i]:= sgData.Cells[1,i+1];
      sgData.Cells[2,i]:= sgData.Cells[2,i+1];
      sgData.Cells[3,i]:= sgData.Cells[3,i+1];
      sgData.Cells[4,i]:= sgData.Cells[4,i+1];
      sgData.Cells[5,i]:= sgData.Cells[5,i+1];
      sgData.Cells[6,i]:= sgData.Cells[6,i+1];
      sgData.Cells[7,i]:= sgData.Cells[7,i+1];
      sgData.Cells[8,i]:= sgData.Cells[8,i+1];
      sgData.Cells[9,i]:= sgData.Cells[9,i+1];
      sgData.Cells[10,i]:= sgData.Cells[10,i+1];
    end;
    sgData.RowCount:=sgData.RowCount-1;
    sCnt:=sCnt-1;
  end;

end;

procedure TfDetail.sgDataSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  FieldsRow:=ARow;
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
    end;
  end;

end;

procedure TfDetail.cmbFactoryChange(Sender: TObject);
begin
  FcID := '';
  gsOrgID := '';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'FACTORYCODE', ptInput);
    CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
      'From SAJET.SYS_FACTORY ' +
      'Where FACTORY_CODE = :FACTORYCODE ';
    Params.ParamByName('FACTORYCODE').AsString := Copy(cmbFactory.Text, 1, POS(' ', cmbFactory.Text) - 1);
    Open;
    if RecordCount > 0 then
      FcID := Fieldbyname('FACTORY_ID').AsString;
      gsOrgID := Fieldbyname('FACTORY_CODE').AsString;
    Close;
  end;
end;


procedure TfDetail.sbtnaliasClick(Sender: TObject);
begin
  with Tfdata.Create(Self) do
  begin

    MaintainType:='ALIAS';
    label1.Caption :='ALIAS';

    if Showmodal = mrOK then
    begin
      //
    end;
    Free;
  end;

end;
procedure TfDetail.CheckSource;
begin
    with  QryTemp  do
    begin
       close;
       Params.Clear;
       Params.CreateParam(ftString,'SOURCE',ptinput);
       CommandText :='SELECT * FROM SAJET.MES_TO_ERP_MISC where SOURCE=:SOURCE';
       Params.ParamByName('SOURCE').AsString := edtRT.Text;
       Open;

       if IsEmpty then
       begin
           close;
           Params.Clear;
           Params.CreateParam(ftString,'SOURCE',ptinput);
           CommandText :='SELECT * FROM SAJET.MES_HT_TO_ERP_MISC where SOURCE=:SOURCE';
           Params.ParamByName('SOURCE').AsString := edtRT.Text;
           Open;
           if not IsEmpty then
           begin
               MessageDlg('Source Has Used',mtError,[mbOK],0);
               edtRT.SelectAll;
               edtRT.SetFocus;
               Abort;
           end;
       end
       else
       begin
           MessageDlg('Source Has Used',mtError,[mbOK],0);
           edtRT.SelectAll;
           edtRT.SetFocus;
           Abort;
       end;

    end;
end;

end.

