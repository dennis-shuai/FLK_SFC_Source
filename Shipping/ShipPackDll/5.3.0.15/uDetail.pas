unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, Db, DBClient,
  Menus, ComCtrls, ListView1, IniFiles, StringGrid1, ImgList;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    QryDetail: TClientDataSet;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    sbtnCommit: TSpeedButton;
    Image1: TImage;
    QryTemp1: TClientDataSet;
    Label2: TLabel;
    btnNewNo: TBitBtn;
    editData: TEdit;
    LabData: TLabel;
    LabTerminal: TLabel;
    Label5: TLabel;
    LabQty: TLabel;
    LvDetail: TListView1;
    sgList: TStringGrid;
    LabCustomer: TLabel;
    ImageList1: TImageList;
    edtDN: TEdit;
    Image4: TImage;
    sbtnCancel: TSpeedButton;
    PopupMenu1: TPopupMenu;
    Delete1: TMenuItem;
    Image2: TImage;
    SpeedButton1: TSpeedButton;
    lablCustomer: TLabel;
    Image3: TImage;
    SpeedButton2: TSpeedButton;
    cdstemp: TClientDataSet;
    cdsData: TClientDataSet;
    Label3: TLabel;
    EditORG: TEdit;
    procedure FormShow(Sender: TObject);
    procedure btnNewNoClick(Sender: TObject);
    procedure editDataKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnCommitClick(Sender: TObject);
    procedure edtDNKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnCancelClick(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure sgListSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure SpeedButton1Click(Sender: TObject);
    procedure LvDetailCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure SpeedButton2Click(Sender: TObject);
    procedure sgListDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, TerminalID, ShippingID, gsCustID: string;
    giRow, gsRow: Integer;
    G_FCID:string;
    function GetTerminalID: Boolean;
    function GetShipData: Boolean;
    function CheckPallet(FIFOFlag:boolean): Boolean;
    function CheckCarton(FIFOFlag:boolean): Boolean;
    function CheckBox(FIFOFlag:boolean): Boolean;
    function CheckSN(CheckFIFO:boolean): Boolean;
    function CheckMaterial(FIFOFlag:boolean): Boolean;
    function GetPartNo(sItem: string): string;
    procedure GetShippingQTY;
    procedure InputData(FIFOFlag:boolean);
    procedure ClearData;
    function checkFIFO(MaterailNo:string;VAR NOCHECK:STRING):string;
    function checkFIFO_Pallet(MaterailNo:string;VAR NOCHECK:STRING):string;
    function SendMsg:boolean;
    function InsertTemp(MaterialNO:string):boolean;
    function InsertTempPallet(MaterialNO:string):boolean;
    function DeleteTemp(Shipid:string) :boolean;
    function Checkinstock(Sdate:string): Boolean;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}

uses uCommData, uDNItem;

function TfDetail.Checkinstock(Sdate:string): Boolean;
begin
   { result:=true;
    with qrytemp do
    begin
      close;
      params.Clear;
      params.CreateParam(ftstring,'material_no',ptinput);
      commandtext:=' select material_no,material_qty,factory_id,factory_type  '
                  +' from sajet.g_material where material_no =:material_no ';
      params.ParamByName('material_no').AsString :=sdate;
      open;
      if isempty then
      begin
         close;
         params.Clear;
         params.CreateParam(ftstring,'material_no',ptinput);
         commandtext:=' select a.material_no,a.material_qty,a.factory_id,a.factory_type from sajet.g_material a,sajet.g_sn_status b  '
                     +' where b.pallet_no = :material_no and a.material_no=b.carton_no  and rownum=1  ';
         params.ParamByName('material_no').AsString :=sdate; 
         open;
         if isempty then
         begin
             result:=false;
             MessageDlg(trim(editData.Text)+' NOT IN STOCK', mtWarning, [mbOK], 0);
             editData.SetFocus;
             editData.SelectAll;
             exit;
         end;
      end;
      // chekc DN ORG 是否與物料相同，不相同不能出貨　
      if fieldbyname('factory_id').AsString <> G_FCID then
      begin
             result:=false;
             MessageDlg(trim(editData.Text)+' ORG IS NOT '+editorg.Text, mtWarning, [mbOK], 0);
             editData.SetFocus;
             editData.SelectAll;
             exit;
      end;

   end;
   }
end;

function TfDetail.InsertTempPallet(MaterialNO:string):boolean;
begin
  Result:=false;
  cdsData.Close;
  cdsData.Params.Clear;
  cdsData.Params.CreateParam(ftString, 'Material', ptInput);
  cdsdata.CommandText:=' select distinct carton_no '
                      +' from sajet.g_sn_status '
                      +' where pallet_no = :Material ';
  cdsData.Params.ParamByName('Material').AsString := MaterialNo;
  cdsData.Open;
  while not cdsData.Eof do
  begin
    with cdstemp do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'ShipID', ptInput);
      Params.CreateParam(ftString, 'Material', ptInput);
      commandtext:=' select * from sajet.g_material_shipping_temp  '
                +' where shipping_id=:shipid and pallet_no=:Material ';
      Params.ParamByName('ShipID').AsString := ShippingID;
      Params.ParamByName('Material').AsString := cdsData.fieldbyname('carton_no').AsString;;
      open;
      if not isEmpty then begin
        continue;
      end;
      close;
      params.Clear;
      Params.CreateParam(ftString, 'ShipID', ptInput);
      Params.CreateParam(ftString, 'Material', ptInput);
      Params.CreateParam(ftString, 'UserID', ptInput);
      commandtext:=' insert into sajet.g_material_shipping_temp '
                +'    (shipping_id,pallet_no,update_userID,update_time ) '
                +'  values '
                +'    (:shipID,:Material,:UserID,sysdate) ';
      Params.ParamByName('ShipID').AsString := ShippingID;
      Params.ParamByName('Material').AsString := cdsData.fieldbyname('Carton_no').AsString;
      Params.ParamByName('UserID').AsString := UpdateUserID;
      execute;
      result:=true;
    end;
    cdsData.Next;
  end;
end;

function TfDetail.checkFIFO_Pallet(MaterailNo:string;VAR NOCHECK:STRING):string;
begin
  with sproc do
  begin
    try
       try
        Close;
        DataRequest('SAJET.SJ_CHECK_FIFO_Shipping');
        FetchParams;
        Params.ParamByName('MATERIALNO').AsString := MaterailNo;
        Params.ParamByName('MATERIALTYPE').AsString := 'PALLET';
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

function TfDetail.InsertTemp(MaterialNO:string):boolean;
begin
  Result:=false;
  with cdstemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'ShipID', ptInput);
    Params.CreateParam(ftString, 'Material', ptInput);
    commandtext:=' select * from sajet.g_material_shipping_temp  '
                +' where shipping_id=:shipid and pallet_no=:Material ';
    Params.ParamByName('ShipID').AsString := ShippingID;
    Params.ParamByName('Material').AsString := MaterialNo;
    open;
    if not isEmpty then begin
     result:=false;
     exit;
    end;
    close;
    params.Clear;
    Params.CreateParam(ftString, 'ShipID', ptInput);
    Params.CreateParam(ftString, 'Material', ptInput);
    Params.CreateParam(ftString, 'UserID', ptInput);
    commandtext:=' insert into sajet.g_material_shipping_temp '
                +'    (shipping_id,pallet_no,update_userID,update_time ) '
                +'  values '
                +'    (:shipID,:Material,:UserID,sysdate) ';
    Params.ParamByName('ShipID').AsString := ShippingID;
    Params.ParamByName('Material').AsString := MaterialNo;
    Params.ParamByName('UserID').AsString := UpdateUserID;
    execute;
    result:=true;
  end;
end;

function TfDetail.DeleteTemp(ShipID:string) :boolean;
begin
   Result:=true;
   with cdstemp do
   begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'ShipID', ptInput);
      commandtext:=' delete from sajet.g_material_shipping_temp where shipping_id=:ShipID ';
      Params.ParamByName('ShipID').AsString := ShipID;
      execute;
   end;
   Result:=false;
end;

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
        DataRequest('SAJET.SJ_CHECK_FIFO_Shipping');
        FetchParams;
        Params.ParamByName('MATERIALNO').AsString := MaterailNo;
        Params.ParamByName('MATERIALtype').AsString := 'CARTON';
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


procedure TfDetail.GetShippingQTY;
var I, iShipQty: Integer; sPart, sDNItem: string;
begin
  // 統計 DN 總數
  LvDetail.Items.Clear;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DN_NO', ptInput);
    CommandText := 'Select PART_NO,DN_ITEM,QTY, a.Part_ID ' +
      'From SAJET.SYS_PART A,' +
      '(Select Part_ID,DN_ITEM,Sum(Qty) QTY ' +
      'From SAJET.G_DN_BASE A ' +
      '    ,SAJET.G_DN_DETAIL B ' +
      'Where A.DN_NO = :DN_NO ' +
      'and A.DN_ID = B.DN_ID ' +
      'Group By PART_ID,DN_ITEM ) B ' +
      'Where A.PART_ID = B.PART_ID ' +
      'Order By PART_NO,DN_ITEM ';
    Params.ParamByName('DN_NO').AsString := edtDN.Text;
    Open;
    while not eof do
    begin
      with LvDetail.Items.Add do
      begin
        Caption := Fieldbyname('PART_NO').AsString; //Part
        ImageIndex := -1;
        SubItems.Add(Fieldbyname('DN_ITEM').AsString); //DN ITEM
        SubItems.Add(Fieldbyname('QTY').AsString); //應出貨數量
        SubItems.Add('0'); //已出貨數量
        SubItems.Add('0'); //此次出貨數量
      end;
      Next;
    end;
    Close;
    // 統計已出貨總數
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DN_NO', ptInput);
    CommandText := 'Select PART_NO,DN_ITEM,QTY ' +
      'From SAJET.SYS_PART A,' +
      '(Select B.PART_ID,B.DN_ITEM,sum(wip_qty) QTY ' +
      'From SAJET.G_DN_BASE A' +
      ',SAJET.G_SHIPPING_SN B ' +
      'Where A.DN_NO = :DN_NO ' +
      'and A.DN_ID = B.DN_ID ' +
      'Group By B.PART_ID,B.DN_ITEM ) B ' +
      'Where A.PART_ID = B.PART_ID ' +
      'ORDER BY PART_NO,DN_ITEM ';
    Params.ParamByName('DN_NO').AsString := edtDN.Text;
    Open;
    LabQty.Caption := '0';
    while not Eof do
    begin
      iShipQty := Fieldbyname('QTY').AsInteger; //已出貨數量
      LabQty.Caption := InttoStr(StrToIntDef(LabQty.Caption, 0) + iShipQty);
      for I := 0 to LvDetail.Items.Count - 1 do
      begin
        sPart := LvDetail.Items[I].Caption;
        sDNItem := LvDetail.Items[I].SubItems.Strings[0];
        if (sPart = Fieldbyname('PART_NO').AsString) and (sDNItem = Fieldbyname('DN_ITEM').AsString) then
        begin
          LvDetail.Items[I].SubItems.Strings[2] := IntToStr(iShipQty);
          break;
        end;
      end;
      Next;
    end;
    Close;
  end;
end;

function TfDetail.GetShipData: Boolean;
begin
  Result := True;
  editData.Text := '';
  LvDetail.Items.Clear;
  // 顯示 Customer,Hub
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DN_NO', ptInput);
    CommandText := 'Select DN_ID, A.CUSTOMER_ID,B.CUSTOMER_CODE || '' : '' || B.CUSTOMER_NAME CUST, Work_Flag, ' +
                  ' C.FACTORY_ID,C.FACTORY_CODE||''-''||C.FACTORY_NAME AS FC_TYPE    '+
      'From SAJET.G_DN_BASE A, ' +
      'SAJET.SYS_CUSTOMER B, ' +
      'SAJET.SYS_FACTORY C ' +
      'Where A.DN_NO = :DN_NO  ' +
      'and A.CUSTOMER_ID = B.CUSTOMER_ID(+) ' +
      'and a.factory_id=c.factory_id '+
      'and Rownum = 1 ';
    Params.ParamByName('DN_NO').AsString := edtDN.Text;
    Open;
    if not IsEmpty then
    begin
      if FieldByName('work_flag').AsString = '1' then begin
        ShippingID := Fieldbyname('DN_ID').AsString;
        LabCustomer.Caption := Fieldbyname('CUST').AsString;
        gsCustID := Fieldbyname('CUSTOMER_ID').AsString;
        G_FCID:= Fieldbyname('FACTORY_ID').AsString;
        editorg.Text :=Fieldbyname('fc_type').AsString;
      end else begin
        MessageDlg('DN No: ' + edtDN.Text + ' had been shipped', mtError, [mbOK], 0);
        Result := False;
      end;
    end
    else
    begin
      MessageDlg('DN No: ' + edtDN.Text + ' not found.', mtError, [mbOK], 0);
      Result := False;
    end;
    Close;
  end;
end;

function TfDetail.GetTerminalID: Boolean;
begin
  Result := False;

  with TIniFile.Create('SAJET.ini') do
  begin
    TerminalID := ReadString('Shipping', 'Terminal', '');
    Free;
  end;

  if TerminalID = '' then
  begin
    MessageDlg('Terminal not be assign !!', mtError, [mbOK], 0);
    Exit;
  end;

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'Select A.TERMINAL_NAME,B.PROCESS_NAME ' +
      'From SAJET.SYS_TERMINAL A,' +
      'SAJET.SYS_PROCESS B ' +
      'Where A.TERMINAL_ID = :TERMINALID and ' +
      'A.PROCESS_ID = B.PROCESS_ID ';
    Params.ParamByName('TERMINALID').AsString := TerminalID;
    Open;
    if RecordCount <= 0 then
    begin
      Close;
      MessageDlg('Terminal data error !!', mtError, [mbOK], 0);
      Exit;
    end;
    LabTerminal.Caption := Fieldbyname('PROCESS_NAME').AsString + ' ' +
      Fieldbyname('TERMINAL_NAME').AsString;
    Close;
  end;
  Result := True;
end;

procedure TfDetail.FormShow(Sender: TObject);
var i: Integer;
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  edtDN.SetFocus;
  sgList.Cells[0, 0] := 'Pallet/ID No';
  sgList.Cells[1, 0] := 'Carton';
  sgList.Cells[2, 0] := 'Box';
  sgList.Cells[3, 0] := 'Cust. SN';
  sgList.Cells[4, 0] := 'Serial Number';
  sgList.Cells[5, 0] := 'QTY';
  sgList.Cells[6, 0] := 'DN Item';
  sgList.Cells[7, 0] := 'Type';
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
    Params.ParamByName('dll_name').AsString := 'SHIPPACKDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then
    begin
      edtDN.CharCase := ecUpperCase;
      editData.CharCase := ecUpperCase;
    end;
  end;
  if not GetTerminalID then
  begin
    editData.Enabled := False;
    LabData.Enabled := editData.Enabled;
    sbtnCommit.Enabled := False;
    Exit;
  end;
  for i := 0 to sgList.ColCount - 1 do
    sgList.ColWidths[i] := (sgList.Width - 50) div sgList.ColCount;
  for i := 0 to LvDetail.Columns.Count - 1 do
    LvDetail.Column[i].Width := LvDetail.Width div LvDetail.Columns.Count;
end;

procedure TfDetail.btnNewNoClick(Sender: TObject);
var Key: Char;
begin
  with TfCommData.Create(Self) do
  begin
    LabType2.Caption := 'DN List';
    LabType1.Caption := LabType2.Caption;
    Label1.Caption := 'Search DN No';
    with QryTemp do
    begin
      Close;
      Params.Clear;
      if edtDN.Text <> '' then
        Params.CreateParam(ftString, 'DN_No', ptInput);
      CommandText := 'Select DN_NO "DN No", customer_name "Customer Name" ' +
        'From SAJET.G_DN_BASE a, Sajet.sys_customer b ' +
        'Where NVL(WORK_FLAG,''N/A'') = ''1'' and a.customer_id = b.customer_id(+) ';
      if edtDN.Text <> '' then
        CommandText := CommandText + 'and DN_No like :DN_No ';
      CommandText := CommandText + 'Order By DN_NO ';
      if edtDN.Text <> '' then
        Params.ParamByName('DN_No').AsString := edtDN.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      clearData;
      edtDN.Text := QryTemp.FieldByName('DN No').AsString;
      Key := #13;
      edtDN.OnKeyPress(Self, Key);
      QryTemp.Close;
    end;
    free;
  end;
end;

procedure TfDetail.editDataKeyPress(Sender: TObject; var Key: Char);
var iRow, i: Integer;
begin
  if Key = #13 then
  begin
    if editData.Text = '' then Exit;
    //檢查是否重複
    for i := 0 to 4 do
    begin
      iRow := sgList.Cols[i].IndexOf(editData.Text);
      if iRow <> -1 then
      begin
        sgList.Row := iRow;
        MessageDlg('Input Duplicate', mtWarning, [mbOK], 0);
        editData.SetFocus;
        editData.SelectAll;
        exit;
      end;
    end;

    with cdstemp do
    begin

      close;
      params.Clear;
      commandtext:=' select * from sajet.g_sn_status where pallet_no = '+''''+trim(editData.Text)+'''';
      open;
      if Isempty then
      begin
        close;
        params.Clear;
        commandtext:=' select * from sajet.g_material_shipping_temp where pallet_no = '+''''+trim(editData.Text)+'''';
        open;
        if Not IsEmpty then
        begin
          MessageDlg(trim(editData.Text)+' Has in Other DN!', mtWarning, [mbOK], 0);
          editData.SetFocus;
          editData.SelectAll;
          exit;
        end;
      end
      else begin
        close;
        params.Clear;
        commandtext:=' select * from sajet.g_material_shipping_temp a, '
                    +'        ( select distinct Carton_no from sajet.g_sn_status where Pallet_no = '+''''+trim(editData.Text)+''''
                    +'         ) b '
                    +' where a.pallet_no=b.carton_no ';
        open;
        if Not Isempty then
        begin
          MessageDlg(trim(editData.Text)+' Has in Other DN!', mtWarning, [mbOK], 0);
          editData.SetFocus;
          editData.SelectAll;
          exit;
        end;
      end;
    end;

    //  check 是否已經入庫，沒有入庫不能出貨 　and check org 是否相同
    //if not Checkinstock(trim(editData.Text)) then exit;
    // change by key 2008/06/19
     with SProc do
     begin
         Close;   
         DataRequest('SAJET.SJ_SHIPPING_PACK_CHECK_INPUT');
         FetchParams;
         Params.ParamByName('TDATA').AsString := trim(editData.Text);
         Params.ParamByName('TFCID').AsString := G_FCID ;
         Execute;
         if UPPERCASE(PARAMS.PARAMBYNAME('TRES').AsString)<>'OK' then
         begin
               MessageDlg(PARAMS.PARAMBYNAME('TRES').AsString, mtWarning, [mbOK], 0);
               editData.SetFocus;
               editData.SelectAll;
               exit;
         end;
    end;
    

    InputData(true);
    editData.SetFocus;
    editData.SelectAll;
  end;
end;

procedure TfDetail.InputData(FIFOFlag:boolean);
begin
  if not CheckPallet(FIFOFlag) then // 檢查是否為 Pallet
    if not CheckCarton(FIFOFlag) then // 檢查是否為 Carton
      //if not CheckBox(FIFOFlag) then // 檢查是否為 Box   因導入fifo and 卡org 所以停用
       // if not CheckSN(FIFOFlag) then // 檢查是否為 Serial_Number  　因導入fifo and 卡org 所以停用
          if not CheckMaterial(FIFOFlag) then
            MessageDlg('Input Error !!', mtError, [mbOK], 0);
end;

function TfDetail.CheckMaterial(FIFOFlag:boolean): Boolean; // Result False 表示找不到資料, 其他都不可繼續往下做
var ICount, iRow: Integer; sItem, sReel: string;
    i:integer;
    sStr,sNoCheck:string;
begin
  Result := True;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PALLET_NO', ptInput);
    CommandText := 'Select confirm_userid ' +
      'From SAJET.G_SHIPPING_SN ' +
      'Where PALLET_NO = :PALLET_NO ';
    Params.ParamByName('PALLET_NO').AsString := editData.Text;
    Open;
    if not IsEmpty then
    begin
      if FieldByName('confirm_userid').AsString = '' then
        MessageDlg('ID No: ' + editData.Text + ' had been pack!!', mtError, [mbOK], 0)
      else
        MessageDlg('ID No: ' + editData.Text + ' had been shipped!!', mtError, [mbOK], 0);
      Close;
      Exit;
    end;

    if FIFOFlag then
    begin
      sStr:= checkFIFO(TRIM(editData.Text),sNoCheck);
      if sStr  <>'OK' then
      begin
        MessageDlg(sStr, mtError, [mbOK], 0);
        exit;
      end;
    end;

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MATERIAL_NO', ptInput);
    CommandText := 'Select MATERIAL_NO, MATERIAL_QTY, REEL_NO, PART_ID ' +
      'From SAJET.G_MATERIAL ' +
      'Where MATERIAL_NO = :MATERIAL_NO ';
    Params.ParamByName('MATERIAL_NO').AsString := editData.Text;
    Open;
    iCount := Fieldbyname('MATERIAL_QTY').AsInteger;
    sReel := FieldByName('REEL_NO').AsString;
    sItem := GetPartNo(FieldByName('PART_ID').AsString);
    if iCount > 0 then
    begin
      if sReel <> '' then
      begin
        Close;
        MessageDlg('ID No: ' + editData.Text + ' have Reel, Cann''t Ship!!', mtError, [mbOK], 0);
        Exit;
      end;

      iRow:=-1;
      for i:=0 to LvDetail.Items.Count-1 do
      begin
         if LvDetail.Items[i].Caption=sItem  then
         begin
            if StrToInt(LvDetail.Items[i].SubItems.Strings[1]) >= StrToInt(LvDetail.Items[i].SubItems.Strings[2]) + StrToInt(LvDetail.Items[i].SubItems.Strings[3]) + iCount then
            begin
              iRow:=i;
              break;
            end;
         end;
      end;

      //iRow := LvDetail.Items.IndexOf(LvDetail.FindCaption(0, sItem, True, True, True));
      if iRow = -1 then
      begin
        Close;
        MessageDlg('Cann''t Use this Part/Over Request!! ' + #13#10 + 'Part No : ' + sItem, mtError, [mbOK], 0);
        Exit;
      end;
      if StrToInt(LvDetail.Items[iRow].SubItems.Strings[1]) < StrToInt(LvDetail.Items[iRow].SubItems.Strings[2]) + StrToInt(LvDetail.Items[iRow].SubItems.Strings[3]) + iCount then
        MessageDlg('Over Request(' + LvDetail.Items[iRow].SubItems.Strings[1] + ')!! ' + #13#10 + 'Part No: ' + LvDetail.Items[iRow].Caption
          + '(' + IntToStr(iCount) + '+' + IntToStr(StrToInt(LvDetail.Items[iRow].SubItems.Strings[2]) + StrToInt(LvDetail.Items[iRow].SubItems.Strings[3])) + ')', mtError, [mbOK], 0)
      else
      begin
        InsertTemp(trim(editData.text));

        if (sNoCheck='NG') and SendMsg then
        begin
          MessageDlg('Not Check FIFO!', mtError, [mbOK], 0);
        end;

        sgList.Cells[0, sgList.RowCount - 1] := editData.Text;
        sgList.Cells[1, sgList.RowCount - 1] := '';
        sgList.Cells[2, sgList.RowCount - 1] := '';
        sgList.Cells[3, sgList.RowCount - 1] := '';
        sgList.Cells[4, sgList.RowCount - 1] := '';
        sgList.Cells[5, sgList.RowCount - 1] := IntToStr(iCount);
        sgList.Cells[6, sgList.RowCount - 1] := LvDetail.Items[iRow].SubItems[0];
        sgList.Cells[7, sgList.RowCount - 1] := 'ID No';
        sgList.Cells[8, sgList.RowCount - 1] := sItem;
        sgList.RowCount := sgList.RowCount + 1;
        sgList.Rows[sgList.RowCount - 1].Clear;
        LvDetail.Items[iRow].SubItems.Strings[3] := InttoStr(StrToIntDef(LvDetail.Items[iRow].SubItems.Strings[3], 0) + iCount);
        LabQty.Caption := InttoStr(StrToIntDef(LabQty.Caption, 0) + iCount);
        if giRow <> -1 then
          LvDetail.Items.Item[giRow].ImageIndex := -1;
        LvDetail.Items.Item[iRow].ImageIndex := 0;
        giRow := iRow;
      end;
    end
    else
      Result := False;
    Close;
  end;
end;

function TfDetail.CheckPallet(FIFOFlag:boolean): Boolean; // Result False 表示找不到資料, 其他都不可繼續往下做
var ICount, iRow: Integer; sItem,sStr,sNoCheck: string;
    i:integer;
begin
  Result := True;

  if FIFOFlag then
  begin
    sStr:= checkFIFO_pallet(TRIM(editData.Text),sNoCheck);
    if sStr  <>'OK' then
    begin
      if pos('EXIST',uppercase(sStr))<=0 then
      begin
        MessageDlg(sStr, mtError, [mbOK], 0);
        exit;
      end
      else begin
        result:=false;
        exit;
      end;
    end;
  end;

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PALLET', ptInput);
    CommandText := 'Select Count(SERIAL_NUMBER) CNT, Model_ID ' +
      'From SAJET.G_SN_STATUS ' +
      'Where PALLET_NO = :PALLET group by model_id ';
    Params.ParamByName('PALLET').AsString := editData.Text;
    Open;
    iCount := Fieldbyname('CNT').AsInteger;
    sItem := GetPartNo(FieldByName('Model_Id').AsString);
    if iCount > 0 then
    begin
      // 資料是否可出貨 QC_RESULT, SHIPPING_ID, WORK_FLAG, CURRENT_STATUS
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PALLET', ptInput);
      CommandText := 'Select Count(SERIAL_NUMBER) CNT ' +
        'From SAJET.G_SN_STATUS ' +
        'Where PALLET_NO = :PALLET ' +
        'and QC_RESULT in (''0'',''2'',''4'',''N/A'') ' +
        'and out_pdline_time is not null '+
        'and SHIPPING_ID = 0 ' +
        'and WORK_FLAG = ''0'' ' +
        'and CURRENT_STATUS = ''0'' ';
      Params.ParamByName('PALLET').AsString := editData.Text;
      Open;
      iCount := Fieldbyname('CNT').AsInteger;
      if Fieldbyname('CNT').AsInteger = 0 then
      begin
         // Check QC_RESULT
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'PALLET', ptInput);
        CommandText := 'Select serial_number ' +
          'From SAJET.G_SN_STATUS ' +
          'Where PALLET_NO = :PALLET ' +
          'and (out_pdline_time is  null  or  QC_RESULT in (''1'')) ';
        Params.ParamByName('PALLET').AsString := editData.Text;
        Open;
        if not isempty then
        begin
          Close;
          MessageDlg('SN : ' + fieldbyname('serial_number').AsString + ' Has Not Finished/Qc Result Error !!', mtError, [mbOK], 0);
          Exit;
        end;
        Close;
        // Check Shipping Id
        Params.Clear;
        Params.CreateParam(ftString, 'PALLET', ptInput);
        CommandText := 'Select Count(SERIAL_NUMBER) CNT ' +
          'From SAJET.G_SN_STATUS ' +
          'Where PALLET_NO = :PALLET and ' +
          'SHIPPING_ID = 0 ';
        Params.ParamByName('PALLET').AsString := editData.Text;
        Open;
        if Fieldbyname('CNT').AsInteger = 0 then
        begin
          Close;
          MessageDlg('Pallet : ' + editData.Text + ' had been shipped !!', mtError, [mbOK], 0);
          Exit;
        end;
         // Check Current Status , Work Flag
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'PALLET', ptInput);
        CommandText := 'Select Count(SERIAL_NUMBER) CNT ' +
          'From SAJET.G_SN_STATUS ' +
          'Where PALLET_NO = :PALLET and ' +
          'WORK_FLAG = ''0'' and ' +
          'CURRENT_STATUS = ''0'' ';
        Params.ParamByName('PALLET').AsString := editData.Text;
        Open;
        if Fieldbyname('CNT').AsInteger = 0 then
        begin
          Close;
          MessageDlg('Pallet : ' + editData.Text + ' Scraped or Repaired !!', mtError, [mbOK], 0);
          Exit;
        end;
        MessageDlg('Pallet : ' + editData.Text + ' Fail !!', mtError, [mbOK], 0);
        Exit;
      end;

      iRow:=-1;
      for i:=0 to LvDetail.Items.Count-1 do
      begin
         if LvDetail.Items[i].Caption=sItem  then
         begin
            if StrToInt(LvDetail.Items[i].SubItems.Strings[1]) >= StrToInt(LvDetail.Items[i].SubItems.Strings[2]) + StrToInt(LvDetail.Items[i].SubItems.Strings[3]) + iCount then
            begin
              iRow:=i;
              break;
            end;
         end;
      end;
      //iRow := LvDetail.Items.IndexOf(LvDetail.FindCaption(0, sItem, True, True, True));

      if iRow = -1 then
      begin
        Close;
        MessageDlg('Cann''t Use this Part/Over Request!! ' + #13#10 + 'Part No : ' + sItem, mtError, [mbOK], 0);
        Exit;
      end;
      if StrToInt(LvDetail.Items[iRow].SubItems.Strings[1]) < StrToInt(LvDetail.Items[iRow].SubItems.Strings[2]) + StrToInt(LvDetail.Items[iRow].SubItems.Strings[3]) + iCount then
        MessageDlg('Over Request(' + LvDetail.Items[iRow].SubItems.Strings[1] + ')!! ' + #13#10 + 'Part No: ' + LvDetail.Items[iRow].Caption
          + '(' + IntToStr(iCount) + '+' + IntToStr(StrToInt(LvDetail.Items[iRow].SubItems.Strings[2]) + StrToInt(LvDetail.Items[iRow].SubItems.Strings[3])) + ')', mtError, [mbOK], 0)
      else
      begin
        InsertTempPallet(trim(editData.Text));

        if (sNoCheck='NG') and SendMsg then
        begin
          MessageDlg('Not Check FIFO!', mtError, [mbOK], 0);
        end;        

        sgList.Cells[0, sgList.RowCount - 1] := editData.Text;
        sgList.Cells[1, sgList.RowCount - 1] := '';
        sgList.Cells[2, sgList.RowCount - 1] := '';
        sgList.Cells[3, sgList.RowCount - 1] := '';
        sgList.Cells[4, sgList.RowCount - 1] := '';
        sgList.Cells[5, sgList.RowCount - 1] := IntToStr(iCount);
        sgList.Cells[6, sgList.RowCount - 1] := LvDetail.Items[iRow].SubItems[0];
        sgList.Cells[7, sgList.RowCount - 1] := 'Pallet';
        sgList.Cells[8, sgList.RowCount - 1] := sItem;
        sgList.RowCount := sgList.RowCount + 1;
        sgList.Rows[sgList.RowCount - 1].Clear;
        LvDetail.Items[iRow].SubItems.Strings[3] := InttoStr(StrToIntDef(LvDetail.Items[iRow].SubItems.Strings[3], 0) + iCount);
        LabQty.Caption := InttoStr(StrToIntDef(LabQty.Caption, 0) + iCount);
        LvDetail.Items.Item[iRow].ImageIndex := 0;
        if giRow <> -1 then
          LvDetail.Items.Item[giRow].ImageIndex := -1;
        giRow := iRow;
      end;
    end
    else
      Result := False;
    Close;
  end;
end;

function TfDetail.GetPartNo(sItem: string): string;
begin
  QryTemp1.Close;
  QryTemp1.Params.Clear;
  QryTemp1.Params.CreateParam(ftString, 'part_id', ptInput);
  QryTemp1.CommandText := 'select part_no '
    + 'from sajet.sys_part where part_id = :part_id and rownum = 1';
  QryTemp1.Params.ParamByName('part_id').AsString := sItem;
  QryTemp1.Open;
  Result := QryTemp1.FieldByName('part_no').AsString;
  QryTemp1.Close;
end;

function TfDetail.CheckCarton(FIFOFlag:boolean): Boolean;
var iCount, iRow, iIndex: Integer; sItem, sPallet,sStr,sNoCheck: string;
     i:integer;
begin
  Result := True;

  sNoCheck:='OK';
  if FIFOFlag then
  begin
    sStr:= checkFIFO(TRIM(editData.Text),sNoCheck);
    if sStr  <>'OK' then
    begin
      if pos('EXIST',uppercase(sStr))<=0 then
      begin
        MessageDlg(sStr, mtError, [mbOK], 0);
        exit;
      end
      else begin
        result:=false;
        exit;
      end;
    end;
  end;


  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CARTON', ptInput);
    CommandText := 'Select Count(SERIAL_NUMBER) CNT, Model_Id, Pallet_No ' +
      'From SAJET.G_SN_STATUS ' +
      'Where CARTON_NO = :CARTON group by model_id, Pallet_No ';
    Params.ParamByName('CARTON').AsString := editData.Text;
    Open;
    iCount := Fieldbyname('CNT').AsInteger;
    sPallet := FieldByName('Pallet_No').AsString;
    sItem := GetPartNo(FieldByName('Model_Id').AsString);
    if iCount > 0 then
    begin
       // 資料是否可出貨 QC_RESULT, SHIPPING_ID, WORK_FLAG, CURRENT_STATUS
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'CARTON', ptInput);
      CommandText := 'Select Count(SERIAL_NUMBER) CNT ' +
        'From SAJET.G_SN_STATUS ' +
        'Where CARTON_NO = :CARTON  ' +
        'and out_pdline_time is not null '+
        'and QC_RESULT in (''0'',''2'',''4'',''N/A'') and ' +
        'SHIPPING_ID = 0 and ' +
        'WORK_FLAG = ''0'' and ' +
        'CURRENT_STATUS = ''0'' ';

      Params.ParamByName('CARTON').AsString := editData.Text;
      Open;
      iCount := Fieldbyname('CNT').AsInteger;
      if iCount = 0 then
      begin
         // Check QC_RESULT
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'CARTON', ptInput);
        {CommandText := 'Select Count(SERIAL_NUMBER) CNT ' +
          'From SAJET.G_SN_STATUS ' +
          'Where CARTON_NO = :CARTON and ' +
          'and out_pdline_time is not null ';
          //'QC_RESULT in (''0'',''2'',''4'',''N/A'') '; }
        commandtext:=' select serial_number '
                    +' from sajet.g_sn_status '
                    +' where carton_no =:carton '
                    +' and (out_pdline_time is not null  or  qc_result in(''1'')) ';
        Params.ParamByName('CARTON').AsString := editData.Text;
        Open;
        if not isEmpty then
        begin
          Close;
          MessageDlg('SN : ' + fieldbyname('serial_number').AsString + ' Has Not Finished !!', mtError, [mbOK], 0);
          Exit;
        end;
        Close;
           // Check Shipping Id
        Params.Clear;
        Params.CreateParam(ftString, 'CARTON', ptInput);
        CommandText := 'Select Count(SERIAL_NUMBER) CNT ' +
          'From SAJET.G_SN_STATUS ' +
          'Where CARTON_NO = :CARTON and ' +
          'SHIPPING_ID = 0 ';
        Params.ParamByName('CARTON').AsString := editData.Text;
        Open;
        if Fieldbyname('CNT').AsInteger = 0 then
        begin
          Close;
          MessageDlg('Carton : ' + editData.Text + ' had been shipped !!', mtError, [mbOK], 0);
          Exit;
        end;

         // Check Current Status , Work Flag
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'CARTON', ptInput);
        CommandText := 'Select Count(SERIAL_NUMBER) CNT ' +
          'From SAJET.G_SN_STATUS ' +
          'Where CARTON_NO = :CARTON and ' +
          'WORK_FLAG = ''0'' and ' +
          'CURRENT_STATUS = ''0'' ';
        Params.ParamByName('CARTON').AsString := editData.Text;
        Open;
        if Fieldbyname('CNT').AsInteger = 0 then
        begin
          Close;
          MessageDlg('Carton : ' + editData.Text + ' Scraped or Repaired !!', mtError, [mbOK], 0);
          Exit;
        end;
        MessageDlg('Carton : ' + editData.Text + ' Fail !!', mtError, [mbOK], 0);
        Exit;
      end;

      iRow:=-1;
      for i:=0 to LvDetail.Items.Count-1 do
      begin
         if LvDetail.Items[i].Caption=sItem  then
         begin
            if StrToInt(LvDetail.Items[i].SubItems.Strings[1]) >= StrToInt(LvDetail.Items[i].SubItems.Strings[2]) + StrToInt(LvDetail.Items[i].SubItems.Strings[3]) + iCount then
            begin
              iRow:=i;
              break;
            end; 
         end;
      end;

      //iRow := LvDetail.Items.IndexOf(LvDetail.FindCaption(0, sItem, True, True, True));
      if iRow = -1 then
      begin
        Close;
        MessageDlg('Cann''t Use this Part/Over Request!! ' + #13#10 + 'Part No : ' + sItem, mtError, [mbOK], 0);
        Exit;
      end;
      if StrToInt(LvDetail.Items[iRow].SubItems.Strings[1]) < StrToInt(LvDetail.Items[iRow].SubItems.Strings[2]) + StrToInt(LvDetail.Items[iRow].SubItems.Strings[3]) + iCount then
        MessageDlg('Over Request(' + LvDetail.Items[iRow].SubItems.Strings[1] + ')!! ' + #13#10 + 'Part No: ' + LvDetail.Items[iRow].Caption
          + '(' + IntToStr(iCount) + '+' + IntToStr(StrToInt(LvDetail.Items[iRow].SubItems.Strings[2]) + StrToInt(LvDetail.Items[iRow].SubItems.Strings[3])) + ')', mtError, [mbOK], 0)
      else
      begin
        iIndex := sgList.Cols[0].IndexOf(sPallet);
        if iIndex <> -1 then
        begin
          sgList.Row := iIndex;
          if sgList.Cols[1].Strings[iIndex]='' then
          begin
            MessageDlg('Input Duplicate.', mtWarning, [mbOK], 0);
            //Result := False;
            Exit;
          end;
        end;
        InsertTemp(trim(editData.Text));

        if (sNoCheck='NG') and SendMsg then
        begin
          MessageDlg('Not Check FIFO!', mtError, [mbOK], 0);
        end;

       if sgList.RowCount=35 then
        MessageDlg('35',mtError,[mbOK],0);

        sgList.Cells[0, sgList.RowCount - 1] := sPallet;
        sgList.Cells[1, sgList.RowCount - 1] := editData.Text;
        sgList.Cells[2, sgList.RowCount - 1] := '';
        sgList.Cells[3, sgList.RowCount - 1] := '';
        sgList.Cells[4, sgList.RowCount - 1] := '';
        sgList.Cells[5, sgList.RowCount - 1] := IntToStr(iCount);
        sgList.Cells[6, sgList.RowCount - 1] := LvDetail.Items[iRow].SubItems[0];
        sgList.Cells[7, sgList.RowCount - 1] := 'Carton';
        sgList.Cells[8, sgList.RowCount - 1] := sItem;
        sgList.RowCount := sgList.RowCount + 1;
        sgList.Rows[sgList.RowCount - 1].Clear;
        LvDetail.Items[iRow].SubItems.Strings[3] := InttoStr(StrToIntDef(LvDetail.Items[iRow].SubItems.Strings[3], 0) + iCount);
        LabQty.Caption := InttoStr(StrToIntDef(LabQty.Caption, 0) + iCount);
        LvDetail.Items.Item[iRow].ImageIndex := 0;
        if giRow <> -1 then
          LvDetail.Items.Item[giRow].ImageIndex := -1;
        giRow := iRow;
      end;
    end
    else
      Result := False;
    Close;
  end;
end;

function TfDetail.CheckBox(FIFOFlag:boolean): Boolean;
var iCount, iRow, iIndex: Integer; sItem, sPallet, sCarton: string;
    i:integer;
begin
  Result := True;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CARTON', ptInput);
    CommandText := 'Select Count(SERIAL_NUMBER) CNT, Model_Id, Pallet_No, Carton_No ' +
      'From SAJET.G_SN_STATUS ' +
      'Where Box_No = :CARTON group by model_id, Pallet_No, Carton_No ';
    Params.ParamByName('CARTON').AsString := editData.Text;
    Open;
    iCount := Fieldbyname('CNT').AsInteger;
    sPallet := FieldByName('Pallet_No').AsString;
    sCarton := FieldByName('Carton_No').AsString;
    sItem := GetPartNo(FieldByName('Model_Id').AsString);
    if iCount > 0 then
    begin
       // 資料是否可出貨 QC_RESULT, SHIPPING_ID, WORK_FLAG, CURRENT_STATUS
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'CARTON', ptInput);
      CommandText := 'Select Count(SERIAL_NUMBER) CNT ' +
        'From SAJET.G_SN_STATUS ' +
        'Where CARTON_NO = :CARTON and ' +
        'and out_pdline_time is not null '+
        'and QC_RESULT in (''0'',''2'',''4'',''N/A'') and ' +
        'SHIPPING_ID = 0 and ' +
        'WORK_FLAG = ''0'' and ' +
        'CURRENT_STATUS = ''0'' ';
      Params.ParamByName('CARTON').AsString := editData.Text;
      Open;
      iCount := Fieldbyname('CNT').AsInteger;
      if iCount = 0 then
      begin
         // Check QC_RESULT
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'CARTON', ptInput);
        {CommandText := 'Select Count(SERIAL_NUMBER) CNT ' +
          'From SAJET.G_SN_STATUS ' +
          'Where CARTON_NO = :CARTON and ' +
          'and out_pdline_time is not null ';
          //'QC_RESULT in (''0'',''2'',''4'',''N/A'') ';  }
        commandtext:=' select serial_number '
                    +' from sajet.g_sn_status '
                    +' where carton_no=:carton '
                    +'     and (out_pdline_time is null or qc_result in (''1''))';
        Params.ParamByName('CARTON').AsString := editData.Text;
        Open;
        if not isEmpty then
        begin
          Close;
          MessageDlg('SN : ' + Fieldbyname('serial_number').AsString + ' Has Not Finished !!', mtError, [mbOK], 0);
          Exit;
        end;
        Close;
           // Check Shipping Id
        Params.Clear;
        Params.CreateParam(ftString, 'CARTON', ptInput);
        CommandText := 'Select Count(SERIAL_NUMBER) CNT ' +
          'From SAJET.G_SN_STATUS ' +
          'Where CARTON_NO = :CARTON and ' +
          'SHIPPING_ID = 0 ';
        Params.ParamByName('CARTON').AsString := editData.Text;
        Open;
        if Fieldbyname('CNT').AsInteger = 0 then
        begin
          Close;
          MessageDlg('Carton : ' + editData.Text + ' had been shipped !!', mtError, [mbOK], 0);
          Exit;
        end;

         // Check Current Status , Work Flag
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'CARTON', ptInput);
        CommandText := 'Select Count(SERIAL_NUMBER) CNT ' +
          'From SAJET.G_SN_STATUS ' +
          'Where CARTON_NO = :CARTON and ' +
          'WORK_FLAG = ''0'' and ' +
          'CURRENT_STATUS = ''0'' ';
        Params.ParamByName('CARTON').AsString := editData.Text;
        Open;
        if Fieldbyname('CNT').AsInteger = 0 then
        begin
          Close;
          MessageDlg('Carton : ' + editData.Text + ' Scraped or Repaired !!', mtError, [mbOK], 0);
          Exit;
        end;
        MessageDlg('Carton : ' + editData.Text + ' Fail !!', mtError, [mbOK], 0);
        Exit;
      end;

      iRow:=-1;
      for i:=0 to LvDetail.Items.Count-1 do
      begin
         if LvDetail.Items[i].Caption=sItem  then
         begin
            if StrToInt(LvDetail.Items[i].SubItems.Strings[1]) >= StrToInt(LvDetail.Items[i].SubItems.Strings[2]) + StrToInt(LvDetail.Items[i].SubItems.Strings[3]) + iCount then
            begin
              iRow:=i;
              break;
            end; 
         end;
      end;
      //iRow := LvDetail.Items.IndexOf(LvDetail.FindCaption(0, sItem, True, True, True));
      if iRow = -1 then
      begin
        Close;
        MessageDlg('Cann''t Use this Part/Over Request!! ' + #13#10 + 'Part No : ' + sItem, mtError, [mbOK], 0);
        Exit;
      end;
      if StrToInt(LvDetail.Items[iRow].SubItems.Strings[1]) < StrToInt(LvDetail.Items[iRow].SubItems.Strings[2]) + StrToInt(LvDetail.Items[iRow].SubItems.Strings[3]) + iCount then
        MessageDlg('Over Request(' + LvDetail.Items[iRow].SubItems.Strings[1] + ')!! ' + #13#10 + 'Part No: ' + LvDetail.Items[iRow].Caption
          + '(' + IntToStr(iCount) + '+' + IntToStr(StrToInt(LvDetail.Items[iRow].SubItems.Strings[2]) + StrToInt(LvDetail.Items[iRow].SubItems.Strings[3])) + ')', mtError, [mbOK], 0)
      else
      begin
        iIndex := sgList.Cols[0].IndexOf(sPallet);
        if iIndex <> -1 then
        begin
          sgList.Row := iIndex;
          if sgList.Cols[2].Strings[iIndex]='' then
          begin
            MessageDlg('Input Duplicate.', mtWarning, [mbOK], 0);
           // Result := False;
            Exit;
          end;
        end;

        sgList.Cells[0, sgList.RowCount - 1] := sPallet;
        sgList.Cells[1, sgList.RowCount - 1] := sCarton;
        sgList.Cells[2, sgList.RowCount - 1] := editData.Text;
        sgList.Cells[3, sgList.RowCount - 1] := '';
        sgList.Cells[4, sgList.RowCount - 1] := '';
        sgList.Cells[5, sgList.RowCount - 1] := IntToStr(iCount);
        sgList.Cells[6, sgList.RowCount - 1] := LvDetail.Items[iRow].SubItems[0];
        sgList.Cells[7, sgList.RowCount - 1] := 'Carton';
        sgList.Cells[8, sgList.RowCount - 1] := sItem;
        sgList.RowCount := sgList.RowCount + 1;
        sgList.Rows[sgList.RowCount - 1].Clear;
        LvDetail.Items[iRow].SubItems.Strings[3] := InttoStr(StrToIntDef(LvDetail.Items[iRow].SubItems.Strings[3], 0) + iCount);
        LabQty.Caption := InttoStr(StrToIntDef(LabQty.Caption, 0) + iCount);
        LvDetail.Items.Item[iRow].ImageIndex := 0;
        if giRow <> -1 then
          LvDetail.Items.Item[giRow].ImageIndex := -1;
        giRow := iRow;
      end;
    end
    else
      Result := False;
    Close;
  end;
end;

function TfDetail.CheckSN(CheckFIFO:boolean): Boolean;
var iRow, iIndex: Integer; sItem, sSN, sCSN, sPallet, sCarton, sBox: string;
    i:integer;
begin
  Result := True;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SN', ptInput);
    CommandText := 'Select * ' +
      'From SAJET.G_SN_STATUS ' +
      'Where SERIAL_NUMBER = :SN ';
    Params.ParamByName('SN').AsString := editData.Text;
    Open;
    if IsEmpty then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SN', ptInput);
      CommandText := 'Select * ' +
        'From SAJET.G_SN_STATUS ' +
        'Where ((CUSTOMER_SN = :SN) or (serial_number=:SN)) ';
      Params.ParamByName('SN').AsString := editData.Text;
      Open;
    end;
    if IsEmpty then
    begin
      Result := False;
      Exit;
    end;
    if RecordCount > 0 then
    begin
      sPallet := FieldByName('Pallet_No').AsString;
      sCarton := FieldByName('Carton_No').AsString;
      sBox := FieldByName('Box_No').AsString;
      sItem := GetPartNo(FieldByName('Model_Id').AsString);
      sSN := Fieldbyname('SERIAL_NUMBER').AsString;
      sCSN := Fieldbyname('Customer_SN').AsString;
      // 資料是否可出貨 QC_RESULT, SHIPPING_ID, WORK_FLAG, CURRENT_STATUS
      if Fieldbyname('QC_RESULT').AsString = '1' then
      begin
        MessageDlg(sSN + ' QC Result Error !!', mtError, [mbOK], 0);
        Exit;
      end;
      if Fieldbyname('SHIPPING_ID').AsString <> '0' then
      begin
        MessageDlg(sSN + ' Shippinged !!', mtError, [mbOK], 0);
        Exit;
      end;
      if Fieldbyname('CURRENT_STATUS').AsString <> '0' then
      begin
        MessageDlg(sSN + ' Should be Repaired !!', mtError, [mbOK], 0);
        Exit;
      end;
      if Fieldbyname('WORK_FLAG').AsString <> '0' then
      begin
        MessageDlg(sSN + ' Scrap !!', mtError, [mbOK], 0);
        Exit;
      end;

      iRow:=-1;
      for i:=0 to LvDetail.Items.Count-1 do
      begin
         if LvDetail.Items[i].Caption=sItem  then
         begin
            if StrToInt(LvDetail.Items[i].SubItems.Strings[1]) >= StrToInt(LvDetail.Items[i].SubItems.Strings[2]) + StrToInt(LvDetail.Items[i].SubItems.Strings[3]) + 1 then
            begin
              iRow:=i;
              break;
            end;
         end;
      end;
      //iRow := LvDetail.Items.IndexOf(LvDetail.FindCaption(0, sItem, True, True, True));
      if iRow = -1 then
      begin
        Close;
        MessageDlg('Cann''t Use this Part/Over Request!! ' + #13#10 + 'Part No : ' + sItem, mtError, [mbOK], 0);
        Exit;
      end;
      if StrToInt(LvDetail.Items[iRow].SubItems.Strings[1]) < StrToInt(LvDetail.Items[iRow].SubItems.Strings[2]) + StrToInt(LvDetail.Items[iRow].SubItems.Strings[3]) + 1 then
        MessageDlg('Over Request(' + LvDetail.Items[iRow].SubItems.Strings[1] + ')!! ' + #13#10 + 'Part No: ' + LvDetail.Items[iRow].Caption
          + '(1+' + IntToStr(StrToInt(LvDetail.Items[iRow].SubItems.Strings[2]) + StrToInt(LvDetail.Items[iRow].SubItems.Strings[3])) + ')', mtError, [mbOK], 0)
      else
      begin
        iIndex := sgList.Cols[0].IndexOf(sPallet);
        if iIndex <> -1 then
        begin
          sgList.Row := iIndex;
          MessageDlg('Input Duplicate.', mtWarning, [mbOK], 0);
          Result := False;
          Exit;
        end;
        sgList.Cells[0, sgList.RowCount - 1] := sPallet;
        sgList.Cells[1, sgList.RowCount - 1] := sCarton;
        sgList.Cells[2, sgList.RowCount - 1] := sBox;
        sgList.Cells[3, sgList.RowCount - 1] := sSN;
        sgList.Cells[4, sgList.RowCount - 1] := sCSN;
        sgList.Cells[5, sgList.RowCount - 1] := '1';
        sgList.Cells[6, sgList.RowCount - 1] := LvDetail.Items[iRow].SubItems[0];
        sgList.Cells[7, sgList.RowCount - 1] := 'Serial Number';
        sgList.Cells[8, sgList.RowCount - 1] := sItem;
        sgList.RowCount := sgList.RowCount + 1;
        sgList.Rows[sgList.RowCount - 1].Clear;
        LvDetail.Items[iRow].SubItems.Strings[3] := InttoStr(StrToIntDef(LvDetail.Items[iRow].SubItems.Strings[3], 0) + 1);
        LabQty.Caption := InttoStr(StrToIntDef(LabQty.Caption, 0) + 1);
        LvDetail.Items.Item[iRow].ImageIndex := 0;
        if giRow <> -1 then
          LvDetail.Items.Item[giRow].ImageIndex := -1;
        giRow := iRow;
      end;
    end
    else
      Result := False;
    Close;
  end;
end;

procedure TfDetail.ClearData;
begin
  LvDetail.enabled := true;
  edtDN.Enabled := True;
  editData.Enabled := False;
  LvDetail.Items.Clear;
  sgList.RowCount := 2;
  sgList.Rows[1].Clear;
  giRow := -1;
  LabQty.Caption := '0';
  editData.Text := '';
  LabCustomer.Caption := '';
  G_FCID:='';
  editorg.Text :='';
  edtDN.Text := '';
  edtDN.SetFocus;
end;

procedure TfDetail.sbtnCommitClick(Sender: TObject);
var bFinish: Boolean;
var tNow: TDateTime; i,j: Integer;
begin
  if sgList.RowCount = 2 then Exit;

  {
  for i:=0 to LvDetail.Items.Count-1 do
  begin
    if StrToInt(LvDetail.Items[i].SubItems.Strings[1]) > StrToInt(LvDetail.Items[i].SubItems.Strings[2]) + StrToInt(LvDetail.Items[i].SubItems.Strings[3]) then
    begin
        if Application.MessageBox(pChar(Lvdetail.Items[i].Caption+' not Complete, Commit? '), 'Warning',MB_YESNO+MB_ICONINFORMATION+256)<> IDYES then
        begin
          editData.SelectAll;
          editData.SetFocus;
          exit;
        end;
    end;
  end;
  }

  // ship pack 只能commit 1次　change by key 2008/06/19
  for i:=0 to LvDetail.Items.Count-1 do
  begin
    if StrToInt(LvDetail.Items[i].SubItems.Strings[1]) > StrToInt(LvDetail.Items[i].SubItems.Strings[2]) + StrToInt(LvDetail.Items[i].SubItems.Strings[3]) then
    begin
          Messagedlg(Lvdetail.Items[i].Caption+' not Complete!', mtError, [mbOK], 0);
          editData.SelectAll;
          editData.SetFocus;
          exit;
    end;
  end;


  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select Sysdate from dual ';
    open;
    tNow := FieldByName('Sysdate').AsDateTime;
  end;

  for I := 1 to sgList.RowCount - 2 do
  begin
    with SProc do
    begin
      Close;
      DataRequest('SAJET.SJ_SHIPPING_PACK');
      FetchParams;
      Params.ParamByName('TTERMINALID').AsString := TerminalID;
      if sgList.Cells[7, i] = 'Serial Number' then
        Params.ParamByName('TREV').AsString := sgList.Cells[4, i]
      else if sgList.Cells[7, i] = 'Box' then
        Params.ParamByName('TREV').AsString := sgList.Cells[2, i]
      else if sgList.Cells[7, i] = 'Carton' then
        Params.ParamByName('TREV').AsString := sgList.Cells[1, i]
      else
        Params.ParamByName('TREV').AsString := sgList.Cells[0, i];
      Params.ParamByName('TTYPE').AsString := sgList.Cells[7, i];
      Params.ParamByName('TSHIPPINGID').AsString := ShippingID;
      Params.ParamByName('TEMPID').AsString := UpdateUserID;
      Params.ParamByName('TNOW').AsDateTime := tNow;
      Params.ParamByName('TDNID').AsString := ShippingID;
      Params.ParamByName('TDNITEM').AsString := sgList.Cells[6, i];
      Execute;
    end;
  end;
  bFinish := True;
  for i := 0 to LvDetail.Items.Count - 1 do
  begin
    if StrToInt(LvDetail.Items[i].SubItems.Strings[1]) <> StrToInt(LvDetail.Items[i].SubItems.Strings[2]) + StrToInt(LvDetail.Items[i].SubItems.Strings[3]) then
    begin
      bFinish := False;
      break;
    end;
  end;
  if bFinish then
  begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'Dn_No', ptInput);
    QryTemp.CommandText := 'update sajet.G_DN_BASE set work_flag = ''2'' '
      + 'where DN_No = :DN_No and rownum = 1';
    QryTemp.Params.ParamByName('Dn_No').AsString := edtDN.Text;
    QryTemp.Execute;
    QryTemp.Close;
  end;
  DeleteTemp(ShippingID);
  ClearData;
end;

procedure TfDetail.edtDNKeyPress(Sender: TObject; var Key: Char);
begin
    editData.Enabled := False;
    LvDetail.Items.Clear;
    sgList.RowCount := 2;
    sgList.Rows[1].Clear;
    giRow := -1;
    LabQty.Caption := '0';
    G_FCID:='';
    editorg.Text:='';

    editData.Text := '';
    if Ord(Key) = vk_Return then
    begin
        if GetShipData then
        begin
            GetShippingQTY;
            editData.Enabled := True;
            with cdsData do
            begin
                close;
                params.Clear;
                Params.CreateParam(ftString, 'ShipID', ptInput);
                commandtext:=' select pallet_no from sajet.g_material_shipping_temp where shipping_id =:shipID ';
                Params.ParamByName('Shipid').AsString := ShippingID;
                open;
                while not eof do
                begin
                    editData.Text:=fieldbyname('Pallet_no').AsString;
                  //editDataKeyPress(self,sKey);
                    InputData(false);
                    next;
                end;
            end;


            //DN 只能key down 一次 , add by key 2008/08/02
            edtdn.Enabled :=false;
            btnnewno.Enabled :=false;
            //確何每次出貨時正確(type 一定要為pallet),DN 每次key down時，清除已經做好ship pack的資料　add by key 2008/08/02
            SpeedButton2Click(self) ;
            editdata.Clear;
            editData.SetFocus;

        end
        else
        begin
            edtDN.SelectAll;
            edtDN.SetFocus;
        end;
    end;
end;

procedure TfDetail.sbtnCancelClick(Sender: TObject);
begin
  ClearData;
end;

procedure TfDetail.Delete1Click(Sender: TObject);
var i, j, iRow: Integer; sItem,sPart: string;
begin
  if gsRow = 0 then Exit;
  if sgList.Cells[0, gsRow] = '' then Exit;
  sPart := sgList.Cells[8, gsRow];
  sItem := sgList.Cells[6,gsRow];

  for i:=0 to LvDetail.Items.Count-1 do
  begin
    if (LvDetail.Items[i].Caption=sPart) and (LvDetail.Items[i].SubItems.Strings[0]=sItem) then
    begin
      iRow:=i;
      break;
    end;
  end;
 // iRow := LvDetail.Items.IndexOf(LvDetail.FindCaption(0, sItem, True, True, True));
  LvDetail.Items[iRow].SubItems.Strings[3] := InttoStr(StrToIntDef(LvDetail.Items[iRow].SubItems.Strings[3], 0) - StrToInt(sgList.Cells[5, gsRow]));
  LabQty.Caption := IntToStr(StrToInt(LabQty.Caption) - StrToInt(sgList.Cells[5, gsRow]));
  if (sgList.RowCount = 3) then
    sgList.Rows[1].Clear
  else
  begin
    for i := gsRow to sgList.RowCount - 1 do
      for j := 0 to sgList.ColCount do
        sgList.Cells[j, i] := sgList.Cells[j, i + 1];
  end;
  sgList.RowCount := sgList.RowCount - 1;
end;

procedure TfDetail.sgListSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  gsRow := ARow;
end;

procedure TfDetail.SpeedButton1Click(Sender: TObject);
var Key: Char;
begin
  if edtDN.Text = '' then Exit;
  if LvDetail.Items.Count = 0 then Exit;

  //CHECK DN 是否可以被Delete   add by key 2008/06/20
   with SProc do
     begin
         Close;   
         DataRequest('SAJET.SJ_SHIPPING_DELETE_CHECK_DN');
         FetchParams;
         Params.ParamByName('TDNNO').AsString := edtDN.Text;
         Execute;
         if UPPERCASE(PARAMS.PARAMBYNAME('TRES').AsString)<>'OK' then
         begin
               MessageDlg(PARAMS.PARAMBYNAME('TRES').AsString, mtWarning, [mbOK], 0);
               exit;
         end;
    end;


  if MessageDlg('Delete Ship Data? (DN No: ' + edtDN.Text + ')', mtWarning, [mbYes, mbNo], 0) = mrYes then
  begin
    with SProc do
    begin
      Close;
      DataRequest('SAJET.SJ_SHIPPING_DELETE');
      FetchParams;
      Params.ParamByName('TSHIPPINGID').AsString := ShippingID;
      Params.ParamByName('TEMPID').AsString := UpdateUserID;
      Execute;
    end;
    DeleteTemp(ShippingID);
    Key := #13;
    edtDNKeyPress(Self, Key);
  end;
end;

procedure TfDetail.LvDetailCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if StrToIntDef(Item.SubItems.Strings[1], 0) > StrToIntDef(Item.SubItems.Strings[2], 0) + StrToIntDef(Item.SubItems.Strings[3], 0) then
    LvDetail.Canvas.brush.Color := clRed;
end;

procedure TfDetail.SpeedButton2Click(Sender: TObject);
var i: Integer;
begin
  if sgList.RowCount = 2 then Exit;
  for i := 0 to LvDetail.Items.Count - 1 do
  begin
    LabQty.Caption := IntToStr(StrToInt(LabQty.Caption) - StrToInt(LvDetail.Items[i].SubItems.Strings[3]));
    LvDetail.Items[i].SubItems.Strings[3] := '0';
  end;
  sgList.RowCount := 2;
  sgList.Rows[1].Clear;
  giRow := -1;
  DeleteTemp(ShippingID);
  editData.SelectAll;
  editData.SetFocus;
end;

procedure TfDetail.sgListDblClick(Sender: TObject);
var sOItem,sNItem,sPart:string;
    i:integer;
begin
  if gsRow = 0 then Exit;
  if sgList.Cells[0, gsRow] = '' then Exit;

  sPart := sgList.Cells[8, gsRow];
  sOItem := sgList.Cells[6, gsRow];

  fItem:=TfItem.Create(self);
  fItem.cmbItem.Clear;
  for i:= 0 to Lvdetail.Items.Count-1 do
  begin
    if Lvdetail.Items[i].Caption=sPart then
    begin
     if StrToInt(LvDetail.Items[i].SubItems.Strings[1]) > StrToInt(LvDetail.Items[i].SubItems.Strings[2]) + StrToInt(LvDetail.Items[i].SubItems.Strings[3]) then
     begin
       if strtoint(LvDetail.Items[i].SubItems.Strings[1])>=strtoint(sglist.Cells[5,gsRow])+strtoint(lvDetail.Items[i].SubItems.Strings[2])+strtoint(LvDetail.Items[i].SubItems.Strings[3]) then
         fItem.cmbItem.Items.Add(LvDetail.Items[i].SubItems.Strings[0]);
     end;
     if LvDetail.Items[i].SubItems.Strings[0]=sOItem then
       if fItem.cmbItem.Items.IndexOf(sOItem)=-1 then
          fItem.cmbItem.Items.Add(sOItem);
    end;
  end;

  fitem.cmbItem.ItemIndex:=fItem.cmbItem.Items.IndexOf(sOItem);
  if fItem.ShowModal=mrOK then
  begin
    sNitem:=fItem.cmbItem.Text;
    if sNitem<>'' then begin
     for i:=0 to Lvdetail.Items.Count-1 do
     begin
      if LvDetail.Items[i].Caption=sPart then
      begin
        if LvDetail.Items[i].SubItems.Strings[0]=sOItem then
           Lvdetail.Items[i].SubItems.Strings[3]:=inttostr(strtoint(Lvdetail.Items[i].SubItems.Strings[3])-strtoint(sgList.Cells[5,gsRow]));
        if LvDetail.Items[i].SubItems.Strings[0]=sNItem then
           Lvdetail.Items[i].SubItems.Strings[3]:=inttostr(strtoint(Lvdetail.Items[i].SubItems.Strings[3])+strtoint(sgList.Cells[5,gsRow]));
      end;
     end;
     LvDetail.Refresh;
     sgList.Cells[6,gsRow]:=sNItem;
    end;
  end;
end;

end.

