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
    sbtnMaterial: TSpeedButton;
    LabTitle1: TLabel;
    QryTemp: TClientDataSet;
    QryDetail: TClientDataSet;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    QryReel: TClientDataSet;
    Label9: TLabel;
    editMaterial: TEdit;
    Label12: TLabel;
    Image1: TImage;
    sbtnClear: TSpeedButton;
    Label6: TLabel;
    cmbStock: TComboBox;
    cmbLocate: TComboBox;
    Label4: TLabel;
    lablLocate: TLabel;
    lablPart: TLabel;
    lablDateCode: TLabel;
    lablQty: TLabel;
    Label3: TLabel;
    lablMsg: TLabel;
    SProc: TClientDataSet;
    Label5: TLabel;
    lablStock: TLabel;
    combVersion: TComboBox;
    Label8: TLabel;
    edtSource: TMaskEdit;
    chkPush: TRzCheckBox;
    sgData: TStringGrid;
    Image2: TImage;
    sbtnCommit: TSpeedButton;
    PopupMenu1: TPopupMenu;
    Delete1: TMenuItem;
    QryHT: TClientDataSet;
    sbtnDelete: TSpeedButton;
    Image4: TImage;
    QryData: TClientDataSet;
    Label11: TLabel;
    lablFifocode: TLabel;
    Label13: TLabel;
    cmbFactory: TComboBox;
    sbtnstock: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure sbtnMaterialClick(Sender: TObject);
    procedure sbtnClearClick(Sender: TObject);
    procedure cmbStockChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure editMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure edtSourceChange(Sender: TObject);
    procedure editMaterialChange(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sbtnCommitClick(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure sgDataSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure edtSourceKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnDeleteClick(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
    procedure sbtnstockClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsType: string;
    gsOrgID, FcID, UserFcID: string;
    slLocateId, slStockId, slData: TStringList;
    giRow: Integer;
    function CheckMaterial: Boolean;
    procedure ClearData;
    procedure ShowMsg(sMsg: string);
    Function GetSource(Source:string):string;
    function checkFIFO(MaterailNo:string;VAR NOCHECK:STRING):string;
    function SendMsg:boolean;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uCommData, uLogin, Udata;

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
        Params.ParamByName('EMPID').AsString := UpdateUserID;
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

function TfDetail.GetSource(Source:string):string;
var sCnt:integer;
var strorgid:string;
begin
  Result:='OK';
  with qrytemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'Source', ptInput);
    commandtext:=' select distinct source,type,factory_id'
                +' from sajet.g_transfer_detail '
                +' where source=:Source ';
    Params.ParamByName('Source').AsString := Source;
    open;
    if Not ISEmpty then
    begin
        if fieldbyname('type').AsString='T' then
        begin
           Result:='Source Has Confirm';
           exit;
        end;
        if fieldbyname('factory_id').AsString <>  FCID then
        begin
             strorgid:= fieldbyname('factory_id').AsString;
             with Qrytemp do
             begin
                close;
                params.Clear ;
                Params.CreateParam(ftString, 'factory_id', ptInput);
                commandtext:=' select factory_code from sajet.sys_factory '
                   +' where factory_id =:factory_id and enabled=''Y'' ';
                Params.ParamByName('FACTORY_ID').AsString := strorgid;
                open;

                Result:='Source ORG IS '+ fieldbyname('FACTORY_code').AsString;
             end;
             exit;
         end;
     end;
  end;

  if Result<>'OK' then exit;

  with Qrytemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'Source', ptInput);
    commandtext:='select nvl(a.reel_no,a.material_no) material_no,b.part_no,c.warehouse_name from_wh,d.locate_name from_loc,e.warehouse_name to_wh,f.locate_name to_loc,nvl(a.reeL_qty,a.material_qty) qty,a.version,a.DATECODE '
                +'   ,b.option7,a.to_warehouse,a.to_locate,a.fifocode,g.factory_code '
                +' from sajet.g_transfer_detail a,sajet.sys_part b,sajet.sys_warehouse c,sajet.sys_locate d  '
                +'            ,sajet.sys_warehouse e,sajet.sys_locate f, sajet.sys_factory g  '
                +' where a.FROM_WAREHOUSE=c.WAREHOUSE_ID(+) and a.FROM_LOCATE=d.locate_id(+)  '
                +'    and a.to_warehouse=e.warehouse_id(+) and a.to_locate=f.locate_id(+)  '
                +'    and a.part_id=b.Part_id  '
                +'    and a.factory_id=g.factory_id(+) '
                +'    and a.source=:source ';
    Params.ParamByName('Source').AsString := Source;
    open;
    while not eof do
    begin
      if sgData.Cells[0, 1] = '' then
      begin
        sgData.RowCount := 2;
        sCnt := 0;
      end
      else
      begin
        sCnt := sgData.RowCount - 1;
        sgData.RowCount := sgData.RowCount + 1;
      end;
      sgData.Cells[0, sCnt + 1] := IntToStr(sCnt + 1);
      sgData.Cells[1, sCnt + 1] := fieldbyname('material_no').AsString;
      sgData.Cells[2, sCnt + 1] := fieldbyname('Part_no').asstring;//lablPart.Caption;
      sgData.Cells[3, sCnt + 1] := fieldbyname('Version').asstring;//combVersion.Text;
      sgData.Cells[4, sCnt + 1] := fieldbyname('DateCode').asstring;//lablDateCode.Caption;
      sgData.Cells[5, sCnt + 1] := Fieldbyname('Qty').asstring;//lablQty.Caption;
      sgData.Cells[6, sCnt + 1] := fieldbyname('from_wh').AsString;//lablStock.Caption;
      sgData.Cells[7, sCnt + 1] := Fieldbyname('from_loc').asstring;//lablLocate.Caption;
      sgData.Cells[8, sCnt + 1] := Fieldbyname('to_wh').asstring;
      sgData.Cells[9, sCnt + 1] := Fieldbyname('to_loc').asstring;
      {sgData.Cells[10, sCnt + 1] := QryReel.FieldByName('part_no').AsString;
      sgData.Cells[11, sCnt + 1] := QryReel.FieldByName('option7').AsString;}
      sgData.Cells[12, sCnt + 1] := Fieldbyname('to_warehouse').asstring;
      sgData.Cells[13, sCnt + 1] := Fieldbyname('to_locate').asstring;
      sgData.Cells[14, sCnt + 1] := Fieldbyname('fifocode').asstring;
      sgData.Cells[15, sCnt + 1] := Fieldbyname('factory_code').asstring; 
      next;
    end;
  end;

end;

procedure TfDetail.FormShow(Sender: TObject);
begin
  slLocateId := TStringList.Create;
  slStockId := TStringList.Create;
  slData := TStringList.Create;
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  sgData.Cells[0, 0] := 'No';
  sgData.Cells[1, 0] := 'Material No/Reel No';
  sgData.Cells[2, 0] := 'Part No';
  sgData.Cells[3, 0] := 'Version';
  sgData.Cells[4, 0] := 'Date Code';
  sgData.Cells[5, 0] := 'Qty';
  sgData.Cells[6, 0] := 'From WH';
  sgData.Cells[7, 0] := 'From Locator';
  sgData.Cells[8, 0] := 'To WH';
  sgData.Cells[9, 0] := 'To Locator';
  sgData.Cells[10, 0] := 'Part NO';
  sgData.Cells[11, 0] := 'Item NO';
  sgData.Cells[12, 0] := 'To WH_ID';
  sgData.Cells[13, 0] := 'To Locator_ID';
  sgData.Cells[14, 0] := 'Fifocode';
  sgData.Cells[15, 0] := 'ORG';
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
    Params.ParamByName('dll_name').AsString := 'MATERIALTRANSFERDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
    Close;
    Params.Clear;
    CommandText := 'select warehouse_id, warehouse_name '
      + 'from sajet.sys_warehouse Where enabled=''Y'' order by warehouse_name ASC ';
    Open;
    cmbStock.Items.Add('');
    slStockId.Add('');
    while not Eof do
    begin
      cmbStock.Items.Add(FieldByName('warehouse_name').AsString);
      slStockId.Add(FieldByName('warehouse_id').AsString);
      Next;
    end;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then
    begin
      edtSource.CharCase := ecUpperCase;
      editMaterial.CharCase := ecUpperCase;
    end;
    Close;
  end;

  // ADD BY KEY 2008/05/07
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


  edtsource.Enabled :=true;
  editmaterial.Enabled :=false;
  edtSource.SetFocus;

end;

function TfDetail.CheckMaterial: Boolean;
var sPartId: string;
   sStr,sNoCheck:string;
begin
  Result := False;
  gsType := 'Material';
  if slData.IndexOf(editMaterial.Text) <> -1 then
  begin
    MessageDlg('ID No: ' + editMaterial.Text + ' have Input.', mtWarning, [mbOK], 0);
    sgData.Row := slData.IndexOf(editMaterial.Text) + 1;
    if  sbtnMaterial.Enabled=true then
        sbtnmaterial.Enabled:=false;
    Exit;
  end;
  if sgData.Cols[1].IndexOf(editMaterial.Text) <>-1 then
  begin
    MessageDlg('ID No: ' + editMaterial.Text + ' have Input.', mtWarning, [mbOK], 0);
    sgData.Row := sgData.Cols[1].IndexOf(editMaterial.Text);
    if  sbtnMaterial.Enabled=true then
        sbtnmaterial.Enabled:=false;
    Exit;
  end;

  sStr:= checkFIFO(TRIM(editMaterial.Text),sNoCheck);
    if sStr  <>'OK' then
    begin
      MessageDlg(sStr, mtError, [mbOK], 0);
      if  sbtnMaterial.Enabled=true then
        sbtnmaterial.Enabled:=false;
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


  with QryReel do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'material_no', ptInput);
    CommandText := 'select a.part_id, part_no, material_qty, datecode, '
      + ' locate_name, warehouse_name, option7, a.version,nvl(reel_no,''N/A'') Reel_No,Fifocode, a.factory_id '
      + ' from sajet.g_material a, sajet.sys_part b, sajet.sys_locate c, sajet.sys_warehouse d '
      + ' where material_no = :material_no and a.part_id = b.part_id '
      + ' and a.locate_id = c.locate_id(+) and a.warehouse_id = d.warehouse_id(+) ';
    Params.ParamByName('material_no').AsString := editMaterial.Text;
    Open;
    if IsEmpty then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'material_no', ptInput);
      CommandText := 'select a.part_id, part_no, reel_qty material_qty, datecode, '
        + ' locate_name, warehouse_name, option7, a.version,Fifocode, a.factory_id '
        + ' from sajet.g_material a, sajet.sys_part b, sajet.sys_locate c, sajet.sys_warehouse d '
        + ' where reel_no = :material_no and a.part_id = b.part_id '
        + ' and a.locate_id = c.locate_id(+) and a.warehouse_id = d.warehouse_id(+) ';
      Params.ParamByName('material_no').AsString := editMaterial.Text;
      Open;
      if IsEmpty then
      begin
        ShowMsg('ID No: ' + editMaterial.Text + ' not found!');
        Close;
        if  sbtnMaterial.Enabled=true then
           sbtnmaterial.Enabled:=false;
        editMaterial.SelectAll;
        editMaterial.SetFocus;
        Exit;
      end
      else if fieldbyname('Warehouse_name').AsString='' then
      begin
        MessageDlg('ID No: ' + editMaterial.Text + ' Not InStock.', mtWarning, [mbOK], 0);
        if  sbtnMaterial.Enabled=true then
          sbtnmaterial.Enabled:=false;
        Exit;
      end
      else if fieldbyname('factory_id').AsString<>fcid then
      begin
        MessageDlg('ID No: ' + editMaterial.Text + ' ORG IS NOT '+CMBFACTORY.Text, mtWarning, [mbOK], 0);
        if  sbtnMaterial.Enabled=true then
           sbtnmaterial.Enabled:=false;
        Exit;
      end;
      gsType := 'Reel';
    end
    else if fieldbyname('Reel_no').AsString<>'N/A' then
    begin
      MessageDlg('ID No: ' + editMaterial.Text + ' have Reel.', mtWarning, [mbOK], 0);
      if  sbtnMaterial.Enabled=true then
        sbtnmaterial.Enabled:=false;
      Exit;
    end
    else if fieldbyname('Warehouse_name').AsString='' then
    begin
      MessageDlg('ID No: ' + editMaterial.Text + ' Not InStock.', mtWarning, [mbOK], 0);
      if  sbtnMaterial.Enabled=true then
        sbtnmaterial.Enabled:=false;
      Exit;
    end
    else if fieldbyname('factory_id').AsString<>fcid then
    begin
      MessageDlg('ID No: ' + editMaterial.Text + ' ORG IS NOT '+CMBFACTORY.Text, mtWarning, [mbOK], 0);
      if  sbtnMaterial.Enabled=true then
        sbtnmaterial.Enabled:=false;
      Exit;
    end;

    lablPart.Caption := FieldByName('part_no').AsString;
    sPartID := FieldByName('part_id').AsString;
    lablQty.Caption := FieldByName('material_qty').AsString;
    lablDateCode.Caption := FieldByName('DateCode').AsString;
    lablStock.Caption := FieldByName('warehouse_name').AsString;
    lablLocate.Caption := FieldByName('Locate_name').AsString;
    lablLocate.Left := lablStock.Left + lablStock.Width + 10;
    lablFifocode.Caption := FieldByName('FIFOCODE').AsString;
    combVersion.Items.Clear;
    if FieldByName('version').AsString <> '' then begin
      combVersion.Items.Add(FieldByName('version').AsString);
      combVersion.ItemIndex := 0;
    end else
      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'part_id', ptInput);
        CommandText := 'select version from sajet.sys_bom_info '
          + 'where part_id = :part_id order by version';
        Params.ParamByName('part_id').AsString := sPartID;
        Open;
        while not Eof do
        begin
          if combVersion.Items.IndexOf(FieldByName('version').AsString) = -1 then
            combVersion.Items.Add(FieldByName('version').AsString);
          Next;
        end;
        Close;
      end;
    if combVersion.Items.Count = 1 then
      combVersion.ItemIndex := 0;
    Result := True;
    if  sbtnMaterial.Enabled=false then
        sbtnmaterial.Enabled:=true;
  end;
end;

procedure TfDetail.sbtnMaterialClick(Sender: TObject);
var sCnt: Integer;
begin
  if Length(Trim(edtSource.Text)) <> 10 then
  begin
    MessageDlg('Source must has 10 characters!', mtError, [mbOK], 0);
    edtSource.SelectAll;
    edtSource.SetFocus;
    Exit;
  end;
  if combVersion.Items.Count <> 0 then
  begin
    if combVersion.ItemIndex = -1 then
    begin
      MessageDlg('Please select Version!', mtError, [mbOK], 0);
      combVersion.SelectAll;
      combVersion.SetFocus;
      Exit;
    end;
  end;
  //要選擇locate
  //if (cmbStock.Text = '') or ((cmbLocate.Items.Count > 0) and (cmbLocate.ItemIndex = -1)) then
  if cmbLocate.ItemIndex = -1  then
  begin
    MessageDlg('Please select Locate!', mtWarning, [mbOK], 0);
    cmbStock.SelectAll;
    cmbStock.SetFocus;
    Exit;
  end;
  if not QryReel.Active then begin
    MessageDlg('Please Press [Enter] on "ID No".', mtWarning, [mbOK], 0);
    editMaterial.SelectAll;
    editMaterial.SetFocus;
    Exit;
  end;
  if QryReel.IsEmpty then Exit;
  if sgData.Cells[0, 1] = '' then
  begin
    sgData.RowCount := 2;
    sCnt := 0;
  end
  else
  begin
    sCnt := sgData.RowCount - 1;
    sgData.RowCount := sgData.RowCount + 1;
  end;
  sgData.Cells[0, sCnt + 1] := IntToStr(sCnt + 1);
  sgData.Cells[1, sCnt + 1] := editMaterial.Text;
  sgData.Cells[2, sCnt + 1] := lablPart.Caption;
  sgData.Cells[3, sCnt + 1] := combVersion.Text;
  sgData.Cells[4, sCnt + 1] := lablDateCode.Caption;
  sgData.Cells[5, sCnt + 1] := lablQty.Caption;
  sgData.Cells[6, sCnt + 1] := lablStock.Caption;
  sgData.Cells[7, sCnt + 1] := lablLocate.Caption;
  sgData.Cells[8, sCnt + 1] := cmbStock.Text;
  sgData.Cells[9, sCnt + 1] := cmbLocate.Text;
  sgData.Cells[10, sCnt + 1] := QryReel.FieldByName('part_no').AsString;
  sgData.Cells[11, sCnt + 1] := QryReel.FieldByName('option7').AsString;
  sgData.Cells[12, sCnt + 1] := slStockId[cmbStock.ItemIndex];
  sgData.Cells[14, sCnt + 1] := QryReel.FieldByName('fifocode').AsString;
  sgData.Cells[15, sCnt + 1] := gsOrgID;
  QryReel.Close;
  //  要選擇loacte,因此禁用如下的if詰句　
  //if cmbLocate.Text <> '' then
    sgData.Cells[13, sCnt + 1] := slLocateId[cmbLocate.ItemIndex] ;
 // else
   // sgData.Cells[13, sCnt + 1] := '';



  with QryHt do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftString, 'userid', ptInput);
        commandtext:=' update sajet.g_material '
                    +'       set type=''O'' '
                    +'      ,update_userid=:userid '
                    +'      ,update_time=sysDate '
                    +' where (material_no=:material_no) or (Reel_no=:material_no) ';
      Params.ParamByName('material_no').AsString := sgData.Cells[1, sCnt + 1];
      Params.ParamByName('userid').AsString := UpdateUserID;
      Execute;

      close;
      Params.CreateParam(ftString, 'material_no', ptInput);
        commandtext:=' insert into sajet.g_ht_material '
                    +'  select * from sajet.g_material where (material_no=:material_no) or (reel_no=:material_no) ';
      Params.ParamByName('material_no').AsString := sgData.Cells[1, sCnt + 1];
      Execute;
    end;

  with Qrytemp do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'source', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftString, 'to_locate', ptInput);
      Params.CreateParam(ftString, 'to_warehouse', ptInput);
      Params.CreateParam(ftString, 'FACTORY_ID', ptInput);
      commandtext:=' insert into sajet.g_transfer_detail '
                  +' select :source, RT_ID, PART_ID,DATECODE,MATERIAL_NO,MATERIAL_QTY,REEL_NO,REEL_QTY, STATUS,locate_id, Warehouse_id '
                  +'  ,:TO_LOCATE,:TO_WAREHOUSE,UPDATE_USERID,UPDATE_TIME,REMARK,RELEASE_QTY,VERSION,MFGER_NAME,MFGER_PART_NO,RT_SEQ,TYPE, FIFOCODE, :FACTORY_ID '
                  +' from sajet.g_material ';
      commandtext:=commandtext+ ' where (Material_no=:Material_no) or (reel_no=:Material_no)';
      Params.ParamByName('source').AsString := edtsource.Text;
      Params.ParamByName('material_no').AsString := sgData.Cells[1, sCnt + 1];
      Params.ParamByName('to_locate').AsString := sgData.Cells[13, sCnt + 1];
      Params.ParamByName('to_warehouse').AsString:=sgData.Cells[12, sCnt + 1];
      Params.ParamByName('FACTORY_ID').AsString:= FCID;
      execute;
    end;



  slData.Add(editMaterial.Text);
  edtSource.Enabled := False;
  sbtnCommit.Enabled := True;
  lablPart.Caption := '';
  lablDateCode.Caption := '';
  lablQty.Caption := '';
  lablStock.Caption := '';
  lablLocate.Caption := '';
  Lablfifocode.Caption:='';
  cmbStock.ItemIndex := -1;
  cmbLocate.Items.Clear;
  combVersion.Items.Clear;
  editMaterial.SelectAll;
  editMaterial.SetFocus;

  if cmbfactory.Enabled = true then
     cmbfactory.Enabled := false ;
end;

procedure TfDetail.ShowMsg(sMsg: string);
begin
  MessageDlg(sMsg, mtError, [mbOK], 0);
  lablMsg.Caption := sMsg;
  lablMsg.Font.Color := clRed;
end;

procedure TfDetail.sbtnClearClick(Sender: TObject);
begin
  ClearData;
end;

procedure TfDetail.ClearData;
begin
  editMaterial.Text := '';
  edtSource.Text := '';
  edtSource.Enabled := True;
  lablPart.Caption := '';
  lablQty.Caption := '';
  lablStock.Caption := '';
  combVersion.Items.Clear;
  lablLocate.Caption := '';
  cmbLocate.Items.Clear;
  cmbStock.ItemIndex := -1;
  combVersion.ItemIndex := -1;
  cmbLocate.ItemIndex := -1;
  lablDateCode.Caption := '';
  lablMsg.Caption := '';
  sgData.RowCount := 2;
  sgData.Rows[1].Clear;
  slData.Clear;
  sbtnMaterial.Enabled:=false;
  edtSource.SetFocus;
end;

procedure TfDetail.cmbStockChange(Sender: TObject);
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'warehouse_id', ptInput);
    CommandText := 'select locate_id, locate_name from sajet.sys_locate '
      + 'where warehouse_id = :warehouse_id order by locate_name asc ';
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

procedure TfDetail.editMaterialKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
    CheckMaterial;
    editMaterial.SelectAll;
    editMaterial.SetFocus;
  end;
end;

procedure TfDetail.edtSourceChange(Sender: TObject);
var i,j:integer;
begin
  QryReel.Close;
  editMaterial.Text := '';
  lablPart.Caption := '';
  lablQty.Caption := '';
  lablStock.Caption := '';
  lablLocate.Caption := '';
  cmbLocate.Items.Clear;
  combVersion.Items.Clear;
  cmbStock.ItemIndex := -1;
  combVersion.ItemIndex := -1;
  cmbLocate.ItemIndex := -1;
  lablDateCode.Caption := '';
  lablMsg.Caption := '';
  sbtnmaterial.Enabled:= false;
  sgData.RowCount := 2;
  sgData.Rows[1].Clear;
end;

procedure TfDetail.editMaterialChange(Sender: TObject);
begin
  QryReel.Close;
  lablPart.Caption := '';
  lablQty.Caption := '';
  lablStock.Caption := '';
  lablLocate.Caption := '';
  combVersion.Items.Clear;
  cmbLocate.Items.Clear;
  cmbStock.ItemIndex := -1;
  combVersion.ItemIndex := -1;
  cmbLocate.ItemIndex := -1;
  lablDateCode.Caption := '';
  lablMsg.Caption := '';
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
    end;
  end;
end;

procedure TfDetail.sbtnCommitClick(Sender: TObject);
var i: Integer;
begin
  if sgData.Cells[1, 1] = '' then Exit;
  with qrytemp do
  begin
     close;
      params.Clear;
      Params.CreateParam(ftString, 'Source', ptInput);
      commandtext:=' delete from sajet.g_transfer_detail where source=:source ';
      Params.ParamByName('Source').AsString := edtSource.Text;
      execute;
  end;
  for i := 1 to sgData.RowCount - 1 do
  begin
    with QryHt do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftString, 'userid', ptInput);
      //if gsType = 'Material' then
        commandtext:=' update sajet.g_material '
                    +'       set type=''O'' '
                    +'      ,update_userid=:userid '
                    +'      ,update_time=sysDate '
                    +' where (material_no=:material_no) or (Reel_no=:material_no) ';
      {else
        commandtext:=' update sajet.g_material '
                    +'       set type=''O'' '
                    +'      ,update_userid=:userid '
                    +'      ,update_time=sysDate '
                    +' where reel_no=:material_no '; }
      Params.ParamByName('material_no').AsString := sgData.Cells[1, i];
      Params.ParamByName('userid').AsString := UpdateUserID;
      Execute;

      close;
      Params.CreateParam(ftString, 'material_no', ptInput);
      //if gsType = 'Material' then
        commandtext:=' insert into sajet.g_ht_material '
                    +'  select * from sajet.g_material where (material_no=:material_no) or (reel_no=:material_no) ';
     { else
        commandtext:=' insert into sajet.g_ht_material '
                    +'  select * from sajet.g_material where reel_no=:material_no '; }
      Params.ParamByName('material_no').AsString := sgData.Cells[1, i];
      Execute;
    end;

    with Qrytemp do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'source', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftString, 'to_locate', ptInput);
      Params.CreateParam(ftString, 'to_warehouse', ptInput);
      commandtext:=' insert into sajet.g_transfer_detail '
                  +' select :source, RT_ID, PART_ID,DATECODE,MATERIAL_NO,MATERIAL_QTY,REEL_NO,REEL_QTY, STATUS,locate_id, Warehouse_id '
                  +'  ,:TO_LOCATE,:TO_WAREHOUSE,UPDATE_USERID,UPDATE_TIME,REMARK,RELEASE_QTY,VERSION,MFGER_NAME,MFGER_PART_NO,RT_SEQ,TYPE, FIFOCODE '
                  +' from sajet.g_material ';
      {if gsType = 'Material' then
        commandtext:=commandtext
                   +' where material_no=:Material_no '
      else
        Commandtext:=commandtext
                   +' where reel_no=:material_no '; }
      commandtext:=commandtext+ ' where (Material_no=:Material_no) or (reel_no=:Material_no)';
      Params.ParamByName('source').AsString := edtsource.Text;
      Params.ParamByName('material_no').AsString := sgData.Cells[1, i];
      Params.ParamByName('to_locate').AsString := sgData.Cells[13, i];
      Params.ParamByName('to_warehouse').AsString:=sgData.Cells[12, i];
      execute;
    end;

    {with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftInteger, 'locate_id', ptInput);
      Params.CreateParam(ftString, 'warehouse_id', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftString, 'userid', ptInput);
      CommandText := 'update sajet.g_material '
        + 'set  warehouse_id = :warehouse_id, locate_id = :locate_id,UPDATE_USERID=:userid,update_time=sysdate,type=''I'' ';
      if gsType = 'Material' then
        CommandText := CommandText + 'where material_no = :material_no '
      else
         commandtext:= commandtext + 'where reel_no = :material_no ';
      Params.ParamByName('warehouse_id').AsString := sgData.Cells[12, i];
      Params.ParamByName('locate_id').AsString := sgData.Cells[13, i];
      Params.ParamByName('material_no').AsString := sgData.Cells[1, i];
      Params.ParamByName('userid').AsString := UpdateUserID;
      Execute;
      Close;
      // Upload Push Title
      with sproc do
      begin
        try
          Close;
          DataRequest('SAJET.MES_ERP_TRANSFER');
          FetchParams;
          Params.ParamByName('TSOURCE').AsString := edtSource.Text;
          Params.ParamByName('TPARTNO').AsString := sgData.Cells[10, i];
          Params.ParamByName('TITEMID').AsString := sgData.Cells[11, i];
          Params.ParamByName('TVERSION').AsString := sgData.Cells[3, i];
          Params.ParamByName('TFSUBINV').AsString := sgData.Cells[6, i];
          Params.ParamByName('TFLOCATOR').AsString := sgData.Cells[7, i];
          Params.ParamByName('TLSUBINV').AsString := sgData.Cells[8, i];
          Params.ParamByName('TLLOCATOR').AsString := sgData.Cells[9, i];
          Params.ParamByName('TQTY').AsString := sgData.Cells[5, i];
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

    with qryHT do
    begin
       close;
       params.Clear;
       Params.CreateParam(ftString, 'material_no', ptInput);
       if gsType = 'Material' then
         commandtext:=' insert into  sajet.g_ht_material '
                     +'  select * from sajet.g_material where material_no=:material_no '
       else
         commandtext:=' insert into sajet.g_ht_material '
                     +'  select * from sajet.g_material where reel_no=:material_no ';
       Params.ParamByName('material_no').AsString := sgData.Cells[1, i];
       execute;
    end;}
  end;
  ClearData;
end;

procedure TfDetail.Delete1Click(Sender: TObject);
var i, j: Integer;
var sResult:string;
var smaterialtemp:string;
begin
   //new 沒有commit按鈕，FOR FIFO
  if MessageDlg('Delete Material: '+sgData.Cells[1, giRow] ,
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
     smaterialtemp:=sgData.Cells[1, giRow];
     qrytemp.close;
     Qrytemp.Params.Clear;
     Qrytemp.Params.CreateParam(ftString, 'source', ptInput);
     Qrytemp.CommandText:=' select nvl(reel_no,material_no) material_no from sajet.g_transfer_detail where source=:source ';
     Qrytemp.Params.ParamByName('source').AsString := edtSource.Text;
     Qrytemp.open;
     IF NOT QRYTEMP.ISEMPTY THEN
     begin
       QryData.Close;
       QryData.Params.Clear;
       Qrydata.Params.CreateParam(ftstring,'Material_no1',ptInput);
       Qrydata.Params.CreateParam(ftstring,'Material_no2',ptInput);
       Qrydata.Params.CreateParam(ftstring,'User',ptInput);
       QryData.CommandText:=' UPdate sajet.g_material '
                           +' set type=''I'' '
                           +'    ,update_time=sysdate '
                           +'    ,update_userid=:userid '
                           +' where (material_no=:Material_no1) or (Reel_no=:material_no2) ';
       QryData.Params.ParamByName('material_no1').AsString := sgData.Cells[1, giRow];
       QryData.Params.ParamByName('material_no2').AsString := sgData.Cells[1, giRow];
       QryData.Params.ParamByName('Userid').AsString :=UpdateUserID ;
       QryData.execute;

       QryData.Close;
       QryData.Params.Clear;
       Qrydata.Params.CreateParam(ftstring,'Material_no1',ptInput);
       Qrydata.Params.CreateParam(ftstring,'Material_no2',ptInput);
       QryData.CommandText:=' Insert into sajet.g_ht_material '
                           +' select * from sajet.g_material '
                           +' where (material_no=:Material_no1) or (Reel_no=:material_no2) ';
       QryData.Params.ParamByName('material_no1').AsString :=sgData.Cells[1, giRow];
       QryData.Params.ParamByName('material_no2').AsString :=sgData.Cells[1, giRow];
       QryData.execute;


       Qrytemp.Close;
       Qrytemp.Params.Clear;
       Qrytemp.Params.CreateParam(ftstring,'Source',ptInput);
       Qrytemp.Params.CreateParam(ftstring,'Material_no1',ptInput);
       Qrytemp.Params.CreateParam(ftstring,'Material_no2',ptInput);
       Qrytemp.CommandText:=' Delete sajet.g_transfer_detail where source=:source '
                        +' AND  (material_no=:Material_no1) or (Reel_no=:material_no2) ';
       Qrytemp.Params.ParamByName('source').AsString := edtSource.Text;
       Qrytemp.Params.ParamByName('material_no1').AsString := sgData.Cells[1, giRow];
       Qrytemp.Params.ParamByName('material_no2').AsString := sgData.Cells[1, giRow];
       Qrytemp.Execute;


       sgData.RowCount := 2;
       sgData.Rows[1].Clear;
       sResult:=GetSource(edtSource.Text);
       if slData.IndexOf(smaterialtemp) <> -1 then
          slData.Delete(slData.IndexOf(smaterialtemp)) ;
       MessageDlg('Delete '+smaterialtemp+' OK', mtInformation,[mbOk], 0);
    end
    ELSE
      BEGIN
         MessageDlg('NOT Record To Be Deleted !', mtError, [mbOK], 0);
      END;
  end;


  {  //有commit 按鈕功能
  if (sgData.RowCount = 2) then
  begin
    sgData.Rows[1].Clear;
    sbtnCommit.Enabled := False;
  end
  else
  begin
    for i := giRow to sgData.RowCount - 1 do
      for j := 1 to 14 do
        sgData.Cells[j, i] := sgData.Cells[j, i + 1];
    sgData.RowCount := sgData.RowCount - 1;
  end;
  slData.Delete(giRow - 1);
  }
end;

procedure TfDetail.sgDataSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  giRow := ARow;
end;

procedure TfDetail.edtSourceKeyPress(Sender: TObject; var Key: Char);
var sResult:string;
begin
  if Ord(Key) = vk_Return then
  begin
    sgData.RowCount := 2;
    sgData.Rows[1].Clear;
    sResult:=GetSource(edtSource.Text);
    if sResult<>'OK' then
    begin
      showmessage(sResult);
      //edtsource.SelectAll;
      edtsource.Clear ;
      edtsource.SetFocus;
      editmaterial.Enabled :=false;
      exit;
    end;
    cmbfactory.Enabled :=false;
    editmaterial.Enabled :=true;
    editMaterial.SelectAll;
    editMaterial.SetFocus;
    sbtnmaterial.Enabled:=true;
  end;
end;

procedure TfDetail.sbtnDeleteClick(Sender: TObject);
begin  
  if MessageDlg('Delete Source: '+edtSource.Text ,
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
     qrytemp.close;
     Qrytemp.Params.Clear;
     Qrytemp.Params.CreateParam(ftString, 'source', ptInput);
     Qrytemp.CommandText:=' select nvl(reel_no,material_no) material_no from sajet.g_transfer_detail where source=:source ';
     Qrytemp.Params.ParamByName('source').AsString := edtSource.Text;
     Qrytemp.open;
     while not Qrytemp.eof do
     begin
       QryData.Close;
       QryData.Params.Clear;
       Qrydata.Params.CreateParam(ftstring,'Material_no1',ptInput);
       Qrydata.Params.CreateParam(ftstring,'Material_no2',ptInput);
       Qrydata.Params.CreateParam(ftstring,'User',ptInput);
       QryData.CommandText:=' UPdate sajet.g_material '
                           +' set type=''I'' '
                           +'    ,update_time=sysdate '
                           +'    ,update_userid=:userid '
                           +' where (material_no=:Material_no1) or (Reel_no=:material_no2) ';
       QryData.Params.ParamByName('material_no1').AsString := QryTemp.fieldbyname('Material_no').AsString;
       QryData.Params.ParamByName('material_no2').AsString := QryTemp.fieldbyname('Material_no').AsString;
       QryData.Params.ParamByName('Userid').AsString :=UpdateUserID ;
       QryData.execute;

       QryData.Close;
       QryData.Params.Clear;
       Qrydata.Params.CreateParam(ftstring,'Material_no1',ptInput);
       Qrydata.Params.CreateParam(ftstring,'Material_no2',ptInput);
       QryData.CommandText:=' Insert into sajet.g_ht_material '
                           +' select * from sajet.g_material '
                           +' where (material_no=:Material_no1) or (Reel_no=:material_no2) ';
       QryData.Params.ParamByName('material_no1').AsString := QryTemp.fieldbyname('Material_no').AsString;
       QryData.Params.ParamByName('material_no2').AsString := QryTemp.fieldbyname('Material_no').AsString;
       QryData.execute;
       Qrytemp.next;
     end;

     Qrytemp.Close;
     Qrytemp.Params.Clear;
     Qrytemp.Params.CreateParam(ftstring,'Source',ptInput);
     Qrytemp.CommandText:=' Delete sajet.g_transfer_detail where source=:source ';
      Qrytemp.Params.ParamByName('source').AsString := edtSource.Text;
     Qrytemp.Execute;
  end;
  ClearData;
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

procedure TfDetail.sbtnstockClick(Sender: TObject);
begin
   with Tfdata.Create(Self) do
   begin

    MaintainType:='STOCK';
    label1.Caption :='STOCK';

    if Showmodal = mrOK then
    begin
      //
    end;
    Free;
  end;
end;

end.

