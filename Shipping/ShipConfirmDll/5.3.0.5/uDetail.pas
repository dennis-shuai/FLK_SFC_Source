unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Spin, Db,
  DBClient, MConnect, ObjBrkr, IniFiles, SConnect, unitRF, ImgList, Menus,
  ListView1;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    SpeedButton5: TSpeedButton;
    Image2: TImage;
    LabTitle1: TLabel;
    sbtnCommit: TSpeedButton;
    Image3: TImage;
    Label2: TLabel;
    lablCustomer: TLabel;
    lablVehicledNo: TLabel;
    editVehicle: TEdit;
    Label3: TLabel;
    editContainer: TEdit;
    lablWarranty: TLabel;
    spineditWarranty: TSpinEdit;
    dtpickWarranty: TDateTimePicker;
    lablDays: TLabel;
    LabData: TLabel;
    editData: TEdit;
    Label5: TLabel;
    LabQty: TLabel;
    sbtnCancel: TSpeedButton;
    Image4: TImage;
    Image5: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    LabTerminal: TLabel;
    sbtnStart: TSpeedButton;
    QryTemp2: TClientDataSet;
    LabCustomer: TLabel;
    LvDetail: TListView1;
    sgList: TStringGrid;
    edtDN: TEdit;
    BitBtn1: TBitBtn;
    PopupMenu1: TPopupMenu;
    Delete1: TMenuItem;
    QryTemp1: TClientDataSet;
    Image1: TImage;
    SpeedButton1: TSpeedButton;
    ImageList1: TImageList;
    Image6: TImage;
    SpeedButton2: TSpeedButton;
    Label1: TLabel;
    EditORG: TEdit;
    QryTemp3: TClientDataSet;
    procedure FormShow(Sender: TObject);
    procedure sbtnStartClick(Sender: TObject);
    procedure sbtnCancelClick(Sender: TObject);
    procedure editDataKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnCommitClick(Sender: TObject);
    procedure spineditWarrantyChange(Sender: TObject);
    procedure dtpickWarrantyChange(Sender: TObject);
    procedure edtDNKeyPress(Sender: TObject; var Key: Char);
    procedure BitBtn1Click(Sender: TObject);
    procedure editVehicleKeyPress(Sender: TObject; var Key: Char);
    procedure Delete1Click(Sender: TObject);
    procedure sgListSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure SpeedButton1Click(Sender: TObject);
    procedure editContainerKeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, ShippingID: string;
    RF: TRF; giRow, gsRow: Integer;
    gsCustID: string;
    function GetTerminalID: Boolean;
    function GetShipData: Boolean;
    function InputData: Boolean;
    procedure GetShippingQTY;
    function GetPartNo(sItem: string; var sItemId: string): string;
    function GetCfgData: Boolean;
    function InsertShippNo: Boolean;
    procedure ClearData;
    Function CheckFinish:boolean;
  end;

var
  fDetail: TfDetail;

implementation

uses uCommData;

{$R *.DFM}
var TerminalID: string;
  ChkRF: Boolean;

Function TfDetail.CheckFinish:boolean;
var i:integer;
begin
 //
 result:=true;
 for i:=0 to lvDetail.Items.Count-1 do
 begin
    if strtoint(LvDetail.Items[i].SubItems.Strings[1]) <> strtoint(LvDetail.Items[i].SubItems.Strings[2])+strtoint(LvDetail.Items[i].SubItems.Strings[3]) then
      Result:=false;
 end;
end;

function TfDetail.GetPartNo(sItem: string; var sItemId: string): string;
begin
  QryTemp1.Close;
  QryTemp1.Params.Clear;
  QryTemp1.Params.CreateParam(ftString, 'part_id', ptInput);
  QryTemp1.CommandText := 'select part_no, option7 '
    + 'from sajet.sys_part where part_id = :part_id and rownum = 1';
  QryTemp1.Params.ParamByName('part_id').AsString := sItem;
  QryTemp1.Open;
  Result := QryTemp1.FieldByName('part_no').AsString;
  sItemId := QryTemp1.FieldByName('option7').AsString;
  QryTemp1.Close;
end;

function TfDetail.GetCfgData: Boolean;
begin
  Result := False;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'Select * ' +
      'From SAJET.SYS_MODULE_PARAM ' +
      'Where MODULE_NAME = :MODULE_NAME and ' +
      'FUNCTION_NAME = :FUNCTION_NAME and ' +
      'PARAME_NAME = :TERMINALID ';
    Params.ParamByName('MODULE_NAME').AsString := 'Shipping';
    Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
    Params.ParamByName('TERMINALID').AsString := TerminalID;
    Open;
    if RecordCount <= 0 then
    begin
      Close;
      MessageDlg('Configuration not Exist !!', mtError, [mbOK], 0);
      Exit;
    end;

    while not Eof do
    begin
      if Fieldbyname('PARAME_ITEM').AsString = 'Link RF' then
        ChkRF := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      Next;
    end;
    Close;
  end;
  Result := True;
end;

function TfDetail.InputData: Boolean;
var ICount, iRow, i,j: Integer; sItem, sField, wField, sType, sItemId,sDNItem, sPallet, sWH, sLocate: string;
  sCarton, sBox, sCSN, sSN, sInputType: string;
begin
  Result := True;
  for i := 0 to 4 do
  begin
    case i of
      0:
        begin
          sField := 'Pallet_No'; wField := 'Pallet_No'; sType := 'Pallet';
        end;
      1:
        begin
          sField := 'Pallet_No, Carton_No'; wField := 'Carton_No'; sType := 'Carton';
        end;
      2:
        begin
          sField := 'Pallet_No, Carton_No, Box_No'; sType := 'Box';
        end;
    else
      sField := 'Pallet_No, Carton_No, Box_No, Customer_SN, Serial_Number';
      sType := 'Serial Number';
      if i = 3 then wField := 'Customer_SN'
      else wField := 'Serial_Number';
    end;
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'INPUT', ptInput);
      CommandText := 'Select PALLET_NO '
        + 'From SAJET.G_SHIPPING_SN A '
        + 'Where ' + wField + ' = :INPUT AND ROWNUM = 1 ';
      Params.ParamByName('INPUT').AsString := editData.Text;
      Open;
      if not IsEmpty then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'INPUT', ptInput);
        Params.CreateParam(ftString, 'DN_ID', ptInput);
        CommandText := 'Select ' + sField + ', Confirm_Userid, Sum(WIP_QTY) WIP_QTY, PART_ID, DN_NO, Type,a.DN_item '
          + 'From SAJET.G_SHIPPING_SN A, SAJET.G_DN_BASE B '
          + 'Where ' + wField + ' = :INPUT '
          + 'AND A.DN_ID = :DN_ID '
          + 'AND A.DN_ID = B.DN_ID '
          + 'Group by ' + sField + ', Confirm_Userid, PART_ID, DN_NO, Type,dn_item ';
        Params.ParamByName('INPUT').AsString := editData.Text;
        Params.ParamByName('DN_ID').AsString := ShippingID;
        Open;
        if IsEmpty then
        begin
          Close;
          MessageDlg('Input Data: ' + editData.Text + ' DN Differect!!', mtError, [mbOK], 0);
          Result := False;
          break;
        end
        else if FieldByName('Confirm_Userid').AsString <> '' then
        begin
          Close;
          MessageDlg('Input Data: ' + editData.Text + ' had Confirmed!!', mtError, [mbOK], 0);
          Result := False;
          break;
        end
        else
        begin
          iRow := sgList.Cols[0].IndexOf(FieldByName('Pallet_No').AsString);
          if iRow <> -1 then
          begin
            sgList.Row := iRow;
            MessageDlg('Input Duplicate.', mtWarning, [mbOK], 0);
            Result := False;
            Exit;
            break;
          end;
          sInputType := Fieldbyname('Type').AsString;
          iCount := Fieldbyname('WIP_QTY').AsInteger;
          sItem := GetPartNo(FieldByName('PART_ID').AsString, sItemId);
          sDNItem:=fieldbyname('DN_item').AsString;

          iRow:=-1;
          for j:=0 to lvDetail.Items.Count-1 do
            if (LvDetail.Items[j].Caption=sItem) and (Lvdetail.Items[j].SubItems.Strings[0]=sDNItem) then
            begin
              iRow:=j;
              break;
            end;

          //iRow := LvDetail.Items.IndexOf(LvDetail.FindCaption(0, sItem, True, True, True));
          sCarton := ''; sBox := ''; sCSN := ''; sSN := '';
          if i > 0 then
            sCarton := FieldByName('Carton_No').AsString;
          if i > 1 then
            sBox := FieldByName('Box_No').AsString;
          if i > 2 then
          begin
            sCSN := FieldByName('Customer_SN').AsString;
            sSN := FieldByName('Serial_Number').AsString;
          end;
          sPallet := FieldByName('Pallet_No').AsString;
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'material_no', ptInput);
          CommandText := 'select locate_name, warehouse_name '
            + 'from sajet.g_material a, sajet.sys_warehouse b, sajet.sys_locate c '
            + 'where a.material_no = :material_no '
            + 'and a.warehouse_id = b.warehouse_id(+) '
            + 'and a.locate_id = c.locate_id(+) ';
          if sInputType = 'ID No' then
            Params.ParamByName('material_no').AsString := editData.Text
          else
            Params.ParamByName('material_no').AsString := sCarton;
          Open;
          sWH := FieldByName('warehouse_name').AsString;
          sLocate := FieldByName('locate_name').AsString;
          Close;
          sgList.Cells[0, sgList.RowCount - 1] := sPallet;
          sgList.Cells[1, sgList.RowCount - 1] := sCarton;
          sgList.Cells[2, sgList.RowCount - 1] := sBox;
          sgList.Cells[3, sgList.RowCount - 1] := sCSN;
          sgList.Cells[4, sgList.RowCount - 1] := sSN;
          sgList.Cells[5, sgList.RowCount - 1] := IntToStr(iCount);
          sgList.Cells[6, sgList.RowCount - 1] := LvDetail.Items[iRow].SubItems[0];
          sgList.Cells[7, sgList.RowCount - 1] := sType;
          sgList.Cells[8, sgList.RowCount - 1] := sItem;
          sgList.Cells[9, sgList.RowCount - 1] := sItemId;
          sgList.Cells[10, sgList.RowCount - 1] := sWH;
          sgList.Cells[11, sgList.RowCount - 1] := sLocate;

          sgList.RowCount := sgList.RowCount + 1;
          sgList.Rows[sgList.RowCount - 1].Clear;
          LvDetail.Items[iRow].SubItems.Strings[3] := InttoStr(StrToIntDef(LvDetail.Items[iRow].SubItems.Strings[3], 0) + iCount);
          LabQty.Caption := InttoStr(StrToIntDef(LabQty.Caption, 0) + iCount);
          LvDetail.Items.Item[iRow].ImageIndex := 0;
          if giRow <> -1 then
            LvDetail.Items.Item[giRow].ImageIndex := -1;
          giRow := iRow;
          break;
        end;
      end
      else
        if i = 4 then begin
          MessageDlg('Input Data not found!!', mtError, [mbOK], 0);
          Result := False;
        end;
      Close;
    end;
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

function TfDetail.GetShipData: Boolean;
var i:integer;
begin
  Result := True;
  LabCustomer.Caption := '';
  editVehicle.Text := '';
  editContainer.Text := '';
  dtpickWarranty.DateTime := Now + 365;
  spineditWarranty.Text := '365';
  editData.Text := '';
  LabQty.Caption := '0';
  LvDetail.Items.Clear;
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
      if FieldByName('work_flag').AsString = '2' then
      begin
        LabCustomer.Caption := Fieldbyname('CUST').AsString;
        gsCustID := Fieldbyname('CUSTOMER_ID').AsString;
        ShippingID := Fieldbyname('DN_ID').AsString;
        //G_FCID:= Fieldbyname('FACTORY_ID').AsString;
        editorg.Text :=Fieldbyname('fc_type').AsString;
      end
      else
      begin
        MessageDlg('DN No: ' + edtDN.Text + ' cann''t use this function.', mtError, [mbOK], 0);
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
  dtpickWarranty.Date := Date;
  sgList.Cells[0, 0] := 'Pallet/ID No';
  sgList.Cells[1, 0] := 'Carton';
  sgList.Cells[2, 0] := 'Box';
  sgList.Cells[3, 0] := 'Cust. SN';
  sgList.Cells[4, 0] := 'Serial Number';
  sgList.Cells[5, 0] := 'QTY';
  sgList.Cells[6, 0] := 'DN Item';
  sgList.Cells[7, 0] := 'Type';
  edtDN.SetFocus;
  if not GetTerminalID then
  begin
    editData.Enabled := False;
    LabData.Enabled := editData.Enabled;
    sbtnCommit.Enabled := False;
    Exit;
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
    Params.ParamByName('dll_name').AsString := 'SHIPCONFIRMDLL.DLL';
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
      editVehicle.CharCase := ecUpperCase;
      editContainer.CharCase := ecUpperCase;
      editData.CharCase := ecUpperCase;
    end;
  end;
//  GetCfgData;
  for i := 0 to sgList.ColCount - 1 do
    sgList.ColWidths[i] := (sgList.Width - 50) div sgList.ColCount;
  for i := 0 to LvDetail.Columns.Count - 1 do
    LvDetail.Column[i].Width := LvDetail.Width div LvDetail.Columns.Count;
end;

procedure TfDetail.sbtnStartClick(Sender: TObject);
var Key:Char;
i :integer;
begin
  if edtDN.Text = '' then
  begin
    MessageDlg('Shipping NO. Error !!', mtError, [mbOK], 0);
    edtDN.SetFocus;
    edtDN.SelectAll;
    exit;
  end;
  if LvDetail.Items.Count = 0 then begin
    edtDN.SetFocus;
    edtDN.SelectAll;
    exit;
  end;
  if editVehicle.Text = '' then begin
    MessageDlg('Please input Vehicle.', mtError, [mbOK], 0);
    editVehicle.SetFocus;
    Exit;
  end;
  if editContainer.Text = '' then begin
    MessageDlg('Please input Container.', mtError, [mbOK], 0);
    editContainer.SetFocus;
    Exit;
  end;
  edtDN.Enabled := False;
  editVehicle.Enabled := False;
  editContainer.Enabled := False;
  dtpickWarranty.Enabled := False;
  spineditWarranty.Enabled := False;
  sbtnStart.Enabled := False;

  editData.Enabled := True;
  LabData.Enabled := editData.Enabled;

  editData.SetFocus;
  editData.SelectAll;

  if ChkRf then
    RF.Started := True;


  with QryTemp3 do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DN_NO', ptInput);
    CommandText :='SELECT A.Pallet_NO, Count(*) Qty ,A.Type FROM SAJET.G_SHIPPING_SN A,SAJET.G_DN_BASE B where ' +
                 ' A.shipping_id =b.DN_ID and b.DN_NO =:DN_NO  group by A.Pallet_NO ,A.Type ';
    Params.ParamByName('DN_NO').AsString := edtDN.Text;
    Open;

   // sgList.RowCount :=  QryTemp.RecordCount+1  ;
    if Isempty then exit;
    First;
    for i:=0 to  RecordCount-1 do begin

       EditData.Text := FieldByName( 'Pallet_NO').Asstring;
       Key :=#13;
       editDataKeyPress(Self,Key);
       Next;
    end;
   end;
end;

procedure TfDetail.sbtnCancelClick(Sender: TObject);
begin
  ClearData;
end;

procedure TfDetail.ClearData;
begin
  sgList.RowCount := 2;
  sgList.Rows[1].Clear;
  giRow := -1;
  edtDN.Text := '';
  LabQty.Caption := '0';
  edtDN.Enabled := True;
  editVehicle.Enabled := True;
  editContainer.Enabled := True;
  dtpickWarranty.Enabled := True;
  spineditWarranty.Enabled := True;
  sbtnStart.Enabled := True;
  editData.Enabled := False;
  LvDetail.Clear;
  LabCustomer.Caption := '';
  editVehicle.Text := '';
  editContainer.Text := '';
  editData.Text := '';
  editorg.Text :='';
  edtDN.SetFocus;
end;

procedure TfDetail.editDataKeyPress(Sender: TObject; var Key: Char);
var i, iRow: Integer;
begin
  if Key = #13 then
  begin
    if editData.Text = '' then Exit;
    //浪琩琌狡
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
    InputData;
    editData.SetFocus;
    editData.SelectAll;
  end;
end;

procedure TfDetail.sbtnCommitClick(Sender: TObject);
var I: Integer; sData: string; bFinish: Boolean;
  tNow: TDateTime; Key: Char;
begin
  if sgList.RowCount = 2 then Exit;
  sData := '';
  if not CheckFinish then
  begin
    MessageDlg('Not Finished !!', mtError, [mbOK], 0);
    exit;
  end;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select Sysdate from dual ';
    open;
    tNow := FieldByName('Sysdate').AsDateTime;
  end;

  InsertShippNo;

  for I := 1 to sgList.RowCount - 2 do
  begin
    with SProc do
    begin
      Close;
      DataRequest('SAJET.SJ_SHIPPING_CONFIRM');
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
      Params.ParamByName('TCONTAINER').AsString := editContainer.Text;
      Params.ParamByName('TVEHICLE').AsString := editVehicle.Text;
      Params.ParamByName('TWARRANTY').AsDateTime := dtpickWarranty.DateTime;
      Params.ParamByName('TSHIPTO').AsString := '';
      Params.ParamByName('TEMPID').AsString := UpdateUserID;
      Params.ParamByName('TNOW').AsDateTime := tNow;
      Params.ParamByName('TDNNO').AsString := edtDN.Text;
      Params.ParamByName('TDNITEM').AsString := sgList.Cells[6, i];
      Params.ParamByName('TITEMID').AsString := sgList.Cells[9, i];
      Params.ParamByName('TQTY').AsString := sgList.Cells[5, i];
      Params.ParamByName('TSUBINV').AsString := sgList.Cells[10, i];
      Params.ParamByName('TLOCATOR').AsString := sgList.Cells[11, i];
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
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SHIPNO', ptInput);
      CommandText := 'Update SAJET.G_DN_BASE ' +
        'Set WORK_FLAG = ''0'' ' +
        'Where DN_NO = :SHIPNO ';
      Params.ParamByName('SHIPNO').AsString := edtDN.Text;
      Execute;

      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SHIPNO', ptInput);
      CommandText := 'Update SAJET.G_SHIPPING_NO ' +
        'Set WORK_FLAG = ''0'' ' +
        'Where SHIPPING_NO = :SHIPNO ';
      Params.ParamByName('SHIPNO').AsString := edtDN.Text;
      Execute;
      Close;
    end;
    with SProc do
    begin
      Close;
      DataRequest('SAJET.MES_ERP_SHIP_CONFIRM');
      FetchParams;
      Params.ParamByName('TSHIPPINGID').AsString := ShippingID;
      Params.ParamByName('TEMPID').AsString := UpdateUserID;
      Execute;
      Close;
    end;
  end;
  if not bFinish then begin
    giRow := -1;
    sgList.RowCount := 2;
    sgList.Rows[1].Clear;
    editVehicle.Enabled := True;
    editContainer.Enabled := True;
    dtpickWarranty.Enabled := True;
    spineditWarranty.Enabled := True;
    sbtnStart.Enabled := True;
    editData.Enabled := False;
    editVehicle.SelectAll;
    editVehicle.SetFocus;
    Key := #13;
    edtDNKeyPress(Self, Key);
  end else
    ClearData;
end;

procedure TfDetail.GetShippingQTY;
var I, iShipQty: Integer; sPart, sDNItem: string;

begin
  // 参璸 DN 羆计
  LvDetail.Items.Clear;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DN_ID', ptInput);
    CommandText := 'Select PART_NO,DN_ITEM,Sum(Qty) QTY ' +
      'From SAJET.SYS_PART A, SAJET.G_DN_DETAIL B ' +
      'Where B.DN_ID = :DN_ID ' +
      'and A.PART_ID = B.PART_ID ' +
      'Group By PART_NO,DN_ITEM ' +
      'Order By PART_NO,DN_ITEM ';
    Params.ParamByName('DN_ID').AsString := ShippingID;
    Open;
    while not eof do
    begin
      with LvDetail.Items.Add do
      begin
        Caption := Fieldbyname('PART_NO').AsString; //Part
        ImageIndex := -1;
        SubItems.Add(Fieldbyname('DN_ITEM').AsString); //DN ITEM
        SubItems.Add(Fieldbyname('QTY').AsString); //莱砯计秖
        SubItems.Add('0'); //砯计秖
        SubItems.Add('0'); //Ω砯计秖
      end;
      Next;
    end;
    Close;

  // 参璸砯羆计
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DN_ID', ptInput);
    CommandText := 'Select PART_NO, DN_ITEM, sum(wip_qty) QTY ' +
      'From SAJET.G_SHIPPING_SN B, SAJET.SYS_PART A ' +
      'Where DN_ID = :DN_ID ' +
      'and A.PART_ID = B.PART_ID ' +
      'and confirm_userid is not null ' +
      'Group By A.PART_No, B.DN_ITEM ' +
      'ORDER BY PART_NO,DN_ITEM ';
    Params.ParamByName('DN_ID').AsString := ShippingID;
    Open;
    LabQty.Caption := '0';

    while not Eof do
    begin
      iShipQty := Fieldbyname('QTY').AsInteger; //砯计秖
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

procedure TfDetail.spineditWarrantyChange(Sender: TObject);
begin
  dtpickWarranty.Date := date + spineditWarranty.Value;
end;

procedure TfDetail.dtpickWarrantyChange(Sender: TObject);
begin
  spineditWarranty.Value := Trunc(dtpickWarranty.Date - date);
end;

function TfDetail.InsertShippNo: Boolean;
var sShipNo: string;
begin
  sShipNo := edtDN.Text;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SHIPPING_NO', ptInput);
    CommandText := 'Delete SAJET.G_SHIPPING_NO '
      + 'Where SHIPPING_NO = :SHIPPING_NO ';
    Params.ParamByName('SHIPPING_NO').AsString := sShipNo;
    Execute;

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SHIPPING_ID', ptInput);
    Params.CreateParam(ftString, 'SHIPPING_NO', ptInput);
    Params.CreateParam(ftString, 'SHIP_CUST', ptInput);
    Params.CreateParam(ftString, 'SHIP_TO', ptInput);
    Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'Insert Into SAJET.G_SHIPPING_NO ' +
      '(SHIPPING_ID,SHIPPING_NO,SHIP_CUST,SHIP_TO,' +
      'PDLINE_ID,STAGE_ID,PROCESS_ID,TERMINAL_ID,UPDATE_USERID ) ' +
      ' Select :SHIPPING_ID SHIPPING_ID,:SHIPPING_NO SHIPPING_NO,:SHIP_CUST SHIP_CUST,:SHIP_TO SHIP_TO, ' +
      'PDLINE_ID,STAGE_ID,PROCESS_ID,TERMINAL_ID,:UPDATE_USERID UPDATE_USERID ' +
      'From SAJET.SYS_TERMINAL ' +
      'Where TERMINAL_ID = :TERMINALID ';
    Params.ParamByName('SHIPPING_ID').AsString := ShippingID;
    Params.ParamByName('SHIPPING_NO').AsString := sShipNo;
    Params.ParamByName('SHIP_CUST').AsString := gsCustID;
    Params.ParamByName('SHIP_TO').AsString := '';
    Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
    Params.ParamByName('TERMINALID').AsString := TerminalID;
    Execute;

    Close;
  end;
  Result := True;
end;

procedure TfDetail.edtDNKeyPress(Sender: TObject; var Key: Char);
begin
  editData.Enabled := False;
  LvDetail.Items.Clear;
  sgList.RowCount := 2;
  sgList.Rows[1].Clear;
  giRow := -1;
  LabQty.Caption := '0';
  editData.Text := '';
  editorg.Text :='';
  if Ord(Key) = vk_Return then
  begin
    if GetShipData then
    begin
      GetShippingQTY;
      editVehicle.Enabled := True;
      editContainer.Enabled := True;
      editVehicle.SelectAll;
      editVehicle.SetFocus;
    end
    else
    begin
      edtDN.SelectAll;
      edtDN.SetFocus;
    end;
  end;
end;

procedure TfDetail.BitBtn1Click(Sender: TObject);
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
        'Where NVL(WORK_FLAG,''N/A'') = ''2'' and a.customer_id = b.customer_id(+) ';
      if edtDN.Text <> '' then
        CommandText := CommandText + 'and DN_No like :DN_No ';
      CommandText := CommandText + 'Order By DN_NO ';
      if edtDN.Text <> '' then
        Params.ParamByName('DN_No').AsString := edtDN.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      edtDN.Text := QryTemp.FieldByName('DN No').AsString;
      Key := #13;
      edtDN.OnKeyPress(Self, Key);
      QryTemp.Close;
    end;
    free;
  end;
end;

procedure TfDetail.editVehicleKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
    editContainer.SelectAll;
    editContainer.SetFocus;
  end;
end;

procedure TfDetail.Delete1Click(Sender: TObject);
var i, j, iRow: Integer; sItem: string;
begin
  if gsRow = 0 then Exit;
  if sgList.Cells[0, gsRow] = '' then Exit;
  sItem := sgList.Cells[8, gsRow];
  iRow := LvDetail.Items.IndexOf(LvDetail.FindCaption(0, sItem, True, True, True));
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
  //editData.SelectAll;
  //editData.SetFocus;
end;

procedure TfDetail.editContainerKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
    sbtnStartClick(Self);
end;

procedure TfDetail.SpeedButton2Click(Sender: TObject);
begin
  if edtDN.Text = '' then Exit;
  if LvDetail.Items.Count = 0 then Exit;

   //CHECK DN 琌砆Delete   add by key 2008/06/20
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
    ClearData;
  end;
end;

end.

