unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, Db,
  DBClient, MConnect, SConnect, IniFiles, Grids, DBGrids, Menus;

type
  TfData = class(TForm)
    sbtnClose: TSpeedButton;
    Image1: TImage;
    Label5: TLabel;
    Label9: TLabel;
    Imagemain: TImage;
    Image3: TImage;
    sbtnSave: TSpeedButton;
    Label7: TLabel;
    Label2: TLabel;
    Label6: TLabel;
    LabDefectDesc: TLabel;
    LabDefectCode: TLabel;
    DBGrid1: TDBGrid;
    Label12: TLabel;
    Label1: TLabel;
    Remark: TMemo;
    DataSource1: TDataSource;
    sbtnReason: TSpeedButton;
    Bevel1: TBevel;
    editItem: TEdit;
    Label4: TLabel;
    sbtnShowBom: TSpeedButton;
    gridLo: TStringGrid;
    PopupMenu1: TPopupMenu;
    Delete1: TMenuItem;
    Image2: TImage;
    sbtnAdd: TSpeedButton;
    SpeedButton1: TSpeedButton;
    Image4: TImage;
    SbtnQuery: TSpeedButton;
    Label3: TLabel;
    Editpoint: TEdit;
    EditPartQty: TEdit;
    Label8: TLabel;
    Label13: TLabel;
    Label10: TLabel;
    edtDateCode: TEdit;
    cmbReason: TComboBox;
    cmbRepair: TComboBox;
    cmblocation: TComboBox;
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure editReasonKeyPress(Sender: TObject; var Key: Char);
    procedure editDutyKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnSaveClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure sbtnShowBomClick(Sender: TObject);
    procedure sbtnReasonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure editItemKeyPress(Sender: TObject; var Key: Char);
    procedure Delete1Click(Sender: TObject);
    procedure gridLoSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure sbtnAddClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SbtnQueryClick(Sender: TObject);
    procedure EditPartQtyChange(Sender: TObject);
    procedure EditpointChange(Sender: TObject);
    procedure cmbReasonSelect(Sender: TObject);
    procedure cmbRepairSelect(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
  public
    { Public declarations }
    RecID,First_Recid: string;
    ReasonID,sReasonCode: string;
    DutyID,sDutyCode: string;
    sItemID: string;
    sString: TStrings;
    procedure SetTheRegion;
    function CheckReason: Boolean;
    function CheckDuty: Boolean;
    function CheckItem: Boolean;
    function GetItemID(PARTNO: string): string;
    procedure ShowLocation(sID: string);
    function CheckRepairedTimes: Boolean;
    function Checkitemno: Boolean;
  end;

var
  fData: TfData;

implementation

{$R *.DFM}
uses uRepair, uItem, uReason, uFilter;

// check item no 2008/06/11
function TfData.Checkitemno: Boolean;
begin
   result:=true;
   if (trim(edititem.Text)='') or (UPPERCASE(trim(edititem.Text))='N/A') then
   begin
      result:=false;
      MessageDlg('Part No Check Fail!!',mtConfirmation,[mbOK],0);
      edititem.SelectAll ;
      edititem.SetFocus ;
      exit;
   end;
   with fRepair.QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'wo', ptInput);
      Params.CreateParam(ftString, 'part', ptInput);
      CommandText := 'Select b.part_no from SAJET.g_wo_pick_list a, sajet.sys_part b '
         + 'where a.work_order = :wo  '
         + 'and (b.part_no = :part or  CUST_PART_NO= :part or  VENDOR_PART_NO=:part ) '
         + 'and a.part_id=b.part_id ';
    Params.ParamByName('wo').AsString := fRepair.LabWO.Caption;
    Params.ParamByName('part').AsString := editItem.text;
    open;
    if RecordCount = 0 then
    begin
      result:=false;
      MessageDlg('Part No Check Fail!!',mtConfirmation,[mbOK],0);
      edititem.SelectAll ;
      edititem.SetFocus ;
      exit;
    end;
  end;
end;


// check 維修次數  2008/06/10  by key
function TfData.CheckRepairedTimes: Boolean;
var i :integer;
begin
Result := False;
for I := 1 to gridLo.RowCount - 1 do
  if Trim(gridLo.Cells[1, I]) <> '' then
  begin
      with fRepair.sproc do
      begin
         try
           Close;
           DataRequest('SAJET.SJ_REPAIR_CHK_REPAIREDTIMES');
           FetchParams;
           Params.ParamByName('TTYPE').AsString := 'LOCATION';
           Params.ParamByName('TRECID').AsString := RecId;
           Params.ParamByName('TSN').AsString := fRepair.gbSN;
           Params.ParamByName('TWO').AsString := fRepair.LabWO.Caption;
           Params.ParamByName('TREADONID').AsString := ReasonID;
           Params.ParamByName('TLOCATION').AsString := gridLo.Cells[1, I];;
           Params.ParamByName('TITEMNO').AsString := gridLo.Cells[2, I];
           Params.ParamByName('TEMPID').AsString := fRepair.UpdateUserID;
           Execute;
           if Params.ParamByName('TRES').AsString <> 'OK' then
           begin
               result:=False;
               MessageDlg(Params.ParamByName('TRES').AsString, mtError, [mbCancel], 0);
               Exit;
           end
           else
             result:=TRUE;

          finally
            close;
          end;
        end;
    end;
end;

function TfData.CheckReason: Boolean;
begin
  Result := False;
  with fRepair.QryTemp do
  begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'REASON_CODE', ptInput);
      CommandText := 'Select Reason_Id, Reason_Code, Reason_Desc,Enabled ' +
        'From SAJET.SYS_REASON ' +
        'Where REASON_CODE = :REASON_CODE and enabled=''Y'' order by reason_code';
      Params.ParamByName('REASON_CODE').AsString := sReasonCode;
      Open;
      if RecordCount <= 0 then
      begin
          Close;
          MessageDlg('Reason Code error !!' + #13#10 +
            'Reason Code : ' + cmbReason.Text, mtError, [mbCancel], 0);
          Exit;
      end
      else
      begin
          if Fieldbyname('Enabled').AsString <> 'Y' then
          begin
            Close;
            MessageDlg('Reason Code Disabled !!' + #13#10 +
              'Reason Code : ' + cmbReason.Text, mtError, [mbCancel], 0);
            Exit;
          end
          else
          begin
            ReasonId := Fieldbyname('Reason_Id').AsString;
            //LabReasonDesc.Caption := Fieldbyname('Reason_Desc').AsString;
            Close;
          end;
      end;
  end;
  Result := True;
end;

function TfData.CheckDuty: Boolean;
begin
  Result := False;
  with fRepair.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DUTY_CODE', ptInput);
    CommandText := 'Select Duty_Id, Duty_Code, Duty_Desc ,Enabled ' +
      'From SAJET.SYS_DUTY ' +
      'Where DUTY_CODE = :DUTY_CODE ';
    Params.ParamByName('DUTY_CODE').AsString := sDutyCode;
    Open;
    if RecordCount <= 0 then
    begin
      Close;
      MessageDlg('Duty Code Error !!' + #13#10 +
        'Duty Code : ' + cmbRepair.Text, mtError, [mbCancel], 0);
      Exit;
    end
    else if Fieldbyname('Enabled').AsString <> 'Y' then
    begin
      Close;
      MessageDlg('Duty Code Disabled !!' + #13#10 +
        'Duty Code : ' + cmbRepair.Text, mtError, [mbCancel], 0);
      Exit;
    end
    else
    begin
      DutyId := Fieldbyname('Duty_Id').AsString;
      //LabDutyDesc.Caption := Fieldbyname('Duty_Desc').AsString;
      Close;
    end;
  end;
  Result := True;
end;

procedure TfData.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfData.FormCreate(Sender: TObject);
begin
  if FileExists(ExtractFilePath(Application.ExeName) + 'bDetail.bmp') then
  begin
    Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'bDetail.bmp');
    SetTheRegion;
  end;
  sString := TStringList.Create;
end;

procedure TfData.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion(Self, Imagemain.Picture.Bitmap);
  SetWindowRgn(handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.

procedure TfData.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
var Brush: TBrush;
begin
  Brush := TBrush.Create;
  Brush.Color := Color;
  FillRect(Msg.DC, ClientRect, Brush.Handle);
  Brush.Free;
  with Imagemain.Picture.Bitmap do
    BitBlt(Msg.DC, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := 1;
end;

// This routine takes care of letting the user move the form
// around on the desktop.

procedure TfData.WMNCHitTest(var msg: TWMNCHitTest);
var
  i: integer;
  p: TPoint;
  AControl: TControl;
  MouseOnControl: boolean;
begin
  inherited;
  if msg.result = HTCLIENT then
  begin
    p.x := msg.XPos;
    p.y := msg.YPos;
    p := ScreenToClient(p);
    MouseOnControl := false;
    for i := 0 to ControlCount - 1 do
    begin
      if not MouseOnControl
        then
      begin
        AControl := Controls[i];
        if ((AControl is TWinControl) or (AControl is TGraphicControl))
          and (AControl.Visible)
          then MouseOnControl := PtInRect(AControl.BoundsRect, p);
      end
      else
        break;
    end;
    if (not MouseOnControl) then msg.Result := HTCAPTION;
  end;
end;

procedure TfData.editReasonKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    if CheckReason then
      cmbRepair.SetFocus;
end;

procedure TfData.editDutyKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    if CheckDuty then
      cmblocation.SetFocus;
end;

procedure TfData.sbtnSaveClick(Sender: TObject);
var I: Integer; B: Boolean;
  sPart, sPartID: string;
begin
  if not CheckReason then Exit;
  if not CheckDuty then Exit;
  if not CheckRepairedTimes then Exit;

   //if not CheckItem then Exit;  // 檢查Item 有沒有在Bom中
  B := False;
  for I := 0 to fRepair.LVReason.Items.Count - 1 do
  begin
    if cmbReason.Text = fRepair.LVReason.Items[I].Caption then
    begin
      B := True;
      Break;
    end;
  end;

  if B then
  begin
    MessageDlg('Reason Code Duplicate !!' + #13#10 +
      'Reason Code : ' + cmbReason.Text, mtError, [mbCancel], 0);
    Exit;
  end;

  try
    with fRepair.QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'MODEL_ID', ptInput);
      Params.CreateParam(ftString, 'REPAIR_EMP_ID', ptInput);
      Params.CreateParam(ftString, 'REASON_ID', ptInput);
      Params.CreateParam(ftString, 'DUTY_PROCESS_ID', ptInput);
      Params.CreateParam(ftString, 'DUTY_ID', ptInput);
      Params.CreateParam(ftString, 'ITEM_ID', ptInput);
      Params.CreateParam(ftString, 'RECORD_TYPE', ptInput);
      Params.CreateParam(ftString, 'REMARK', ptInput);
      Params.CreateParam(ftString, 'LOCATION', ptInput);
      Params.CreateParam(ftString, 'TERMINALID', ptInput);
      CommandText := 'Insert Into SAJET.G_SN_REPAIR ' +
        '(RECID,SERIAL_NUMBER,WORK_ORDER,MODEL_ID,REPAIR_EMP_ID,REASON_ID,' +
        ' RP_TERMINAL_ID,RP_PROCESS_ID,RP_STAGE_ID,DUTY_PROCESS_ID,DUTY_ID,' +
        ' ITEM_ID,RECORD_TYPE,REMARK,LOCATION  ) ' +
        'Select :RECID RECID,:SERIAL_NUMBER SERIAL_NUMBER,:WORK_ORDER WORK_ORDER,:MODEL_ID MODEL_ID,:REPAIR_EMP_ID REPAIR_EMP_ID,:REASON_ID REASON_ID,' +
        ' TERMINAL_ID RP_TERMINAL_ID,PROCESS_ID RP_PROCESS_ID,STAGE_ID RP_STAGE_ID,' +
        ' :DUTY_PROCESS_ID DUTY_PROCESS_ID,:DUTY_ID DUTY_ID,:ITEM_ID ITEM_ID,:RECORD_TYPE RECORD_TYPE,:REMARK REMARK,:LOCATION LOCATION ' +
        'From SAJET.SYS_TERMINAL ' +
        'Where TERMINAL_ID = :TERMINALID ';
      Params.ParamByName('RECID').AsString := RecId;
      Params.ParamByName('SERIAL_NUMBER').AsString := fRepair.gbSN;
      Params.ParamByName('WORK_ORDER').AsString := fRepair.LabWO.Caption;
      Params.ParamByName('MODEL_ID').AsString := fRepair.mPartId;
      Params.ParamByName('REPAIR_EMP_ID').AsString := fRepair.UpdateUserID;
      Params.ParamByName('REASON_ID').AsString := ReasonID;
      Params.ParamByName('DUTY_PROCESS_ID').AsString := '0';
      Params.ParamByName('DUTY_ID').AsString := DutyId;
      Params.ParamByName('ITEM_ID').AsString := sItemID;
      Params.ParamByName('RECORD_TYPE').AsString := '';
      Params.ParamByName('REMARK').AsString := '';
      Params.ParamByName('LOCATION').AsString := cmbLocation.Text;
      Params.ParamByName('TERMINALID').AsString := fRepair.TerminalID;
      Execute;
    end;
  except
    MessageDlg('Append Defect Reason Error !!', mtError, [mbCancel], 0);
    Exit;
  end;

   // 2006 02 13 新增Location 另外存Table
  try
    with fRepair.QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      Params.CreateParam(ftString, 'REASON', ptInput);
      CommandText := 'Delete SAJET.G_SN_REPAIR_LOCATION ' +
        'WHERE RECID = :RECID ' +
        'AND REASON_ID = :REASON ';
      Params.ParamByName('RECID').AsString := RecId;
      Params.ParamByName('REASON').AsString := ReasonID;
      Execute;
      Close;
    end;
    for I := 1 to gridLo.RowCount - 1 do
      if (Trim(gridLo.Cells[1, I]) <> '') or (Trim(gridLo.Cells[2, I]) <> '') then
      begin
        sPartID := GetItemID(gridLo.Cells[2, I]);
        with fRepair.QryTemp do
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'RECID', ptInput);
          Params.CreateParam(ftString, 'LOCATION', ptInput);
          Params.CreateParam(ftString, 'DateCode', ptInput);
          Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
          Params.CreateParam(ftString, 'ITEM_NO', ptInput);
          Params.CreateParam(ftString, 'REASON_ID', ptInput);
          Params.CreateParam(ftString, 'ITEM_ID', ptInput);
          Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
          CommandText := 'Insert Into SAJET.G_SN_REPAIR_LOCATION ' +
            '        (RECID,LOCATION,UPDATE_USERID,UPDATE_TIME,ITEM_NO,REASON_ID,ITEM_ID,WORK_ORDER,Item_DateCode) ' +
            'VALUES (:RECID,:LOCATION,:UPDATE_USERID,SYSDATE,:ITEM_NO,:REASON_ID,:ITEM_ID,:WORK_ORDER,:DateCode ) ';
          Params.ParamByName('RECID').AsString := RecId;
          Params.ParamByName('LOCATION').AsString := gridLo.Cells[1, I];
          Params.ParamByName('DateCode').AsString := edtDateCode.Text;
          Params.ParamByName('UPDATE_USERID').AsString := fRepair.UpdateUserID;
          Params.ParamByName('ITEM_NO').AsString := gridLo.Cells[2, I];
          Params.ParamByName('REASON_ID').AsString := ReasonID;
          Params.ParamByName('ITEM_ID').AsString := sPartID;
          Params.ParamByName('WORK_ORDER').AsString := fRepair.LabWO.Caption;
          Execute;
        end;
      end;
  except
    MessageDlg('Append Location Error !!', mtError, [mbCancel], 0);
    Exit;
  end;

  try
    with fRepair.QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      Params.CreateParam(ftString, 'REPAIR_REMARK', ptInput);
      Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      CommandText := 'Insert Into SAJET.G_SN_REPAIR_REMARK ' +
        '(RECID,REPAIR_REMARK,UPDATE_USERID,WORK_ORDER) ' +
        'VALUES (:RECID,:REPAIR_REMARK,:UPDATE_USERID,:WORK_ORDER)';
      for I := 0 to Remark.Lines.Count - 1 do
        if Trim(Remark.Lines[I]) <> '' then
        begin
          Params.ParamByName('RECID').AsString := RecId;
          Params.ParamByName('REPAIR_REMARK').AsString := Trim(Remark.Lines[I]);
          Params.ParamByName('UPDATE_USERID').AsString := fRepair.UpdateUserID;
          Params.ParamByName('WORK_ORDER').AsString := fRepair.LabWO.Caption;
          Execute;
        end;
    end;
  except
    MessageDlg('Append Repair remark Error !!', mtError, [mbCancel], 0);
    Exit;
  end;

  // 2008 /03/28  新加 defect point by key
  //2008/11/05 新中defet part_qty  for 不良零件個數
  try
    with fRepair.QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      Params.CreateParam(ftString, 'REPAIR_POINT', ptInput);
      Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'FIRST_RECID', ptInput);
      Params.CreateParam(ftString, 'PART_QTY', ptInput);
      CommandText := 'Insert Into SAJET.G_SN_REPAIR_POINT ' +
        '(RECID,REPAIR_POINT,UPDATE_USERID,WORK_ORDER,FIRST_RECID,PART_QTY) ' +
        'VALUES (:RECID,:REPAIR_POINT,:UPDATE_USERID,:WORK_ORDER,:FIRST_RECID,:PART_QTY)';
     if (trim(editpartqty.Text)<>'') or (trim(editpoint.Text)<>'')  then
     begin
          Params.ParamByName('RECID').AsString := RecId;
          if trim(editpoint.Text)='' then
             Params.ParamByName('REPAIR_POINT').AsString :='0'
          else
             Params.ParamByName('REPAIR_POINT').AsString := Trim(editpoint.Text);
          Params.ParamByName('UPDATE_USERID').AsString := fRepair.UpdateUserID;
          Params.ParamByName('WORK_ORDER').AsString := fRepair.LabWO.Caption;
          Params.ParamByName('FIRST_RECID').AsString := First_recid;
          if trim(editpartqty.Text)='' then
             Params.ParamByName('PART_QTY').AsString :='0'
          else
             Params.ParamByName('PART_QTY').AsString := Trim(editpartqty.Text);
          Execute;
     end;
    end;
  except
    MessageDlg('Append point OR Part_Qty Error !!', mtError, [mbCancel], 0);
    Exit;
  end;


  ModalResult := mrOK;
end;

function TfData.CheckItem: Boolean;
var iItemIndex: integer;
begin
  Result := False;
   //Check Item是否在BOM中  --2005/10/31
  sItemID := '0';
  if trim(editItem.Text) <> '' then
  begin
    iItemIndex := fRepair.g_tsItemPart.IndexOf(trim(editItem.Text));
    if iItemIndex = -1 then
    begin
      MessageDlg('Item Error', mtError, [mbOK], 0);
      Exit;
    end
    else
    begin
      sItemID := fRepair.g_tsItem.Strings[iItemIndex * g_iCol];
    end;
  end;
  Result := True;
end;

procedure TfData.DBGrid1DblClick(Sender: TObject);
begin
  cmbReason.Text := DBGrid1.Fields[0].AsString;
  if CheckReason then
    cmbRepair.SetFocus;
end;

procedure TfData.sbtnShowBomClick(Sender: TObject);
var
  sLocation, sItem: string;
begin
   {fItem := TfItem.Create(Self);
   with fItem do
   begin
      QryTemp.RemoteServer := fRepair.QryData.RemoteServer;
      QryTemp.ProviderName := 'DspQryTemp1';
      g_sItemFilter:=trim(editItem.Text);
      g_sLocation:=trim(editLocation.Text);
      ShowListView;
      if ShowModal= mrOK then
      begin
        editItem.Text:= LVItem.Selected.Caption;
        editItem.SetFocus;
        editItem.SelectAll;
      end;
      Free;
   end;  }
   // K := #13;
   //editItemKeyPress(self,K);

  sLocation := trim(cmblocation.Text);
  sItem := trim(editItem.Text);
  fReason := TfReason.Create(Self);
  with fReason do
  begin
    g_type := 'L';
    QryTemp.RemoteServer := fRepair.QryData.RemoteServer;
    QryTemp.ProviderName := 'DspQryTemp1';
    ShowItemList(sLocation, sItem);
    if ShowModal = mrOK then
    begin
      editItem.Text := Copy(TreeReason.Selected.Text, 1, pos('..(', TreeReason.Selected.Text) - 1);
      editItem.SetFocus;
      editItem.SelectAll;
    end;
    Free;
  end;
end;

procedure TfData.sbtnReasonClick(Sender: TObject);
begin
  fReason := TfReason.Create(Self);
  with fReason do
  begin
    g_type := 'R';
    QryTemp.RemoteServer := fRepair.QryData.RemoteServer;
    QryTemp.ProviderName := 'DspQryTemp1';
    ShowReasonList(trim(cmbReason.Text));
    if ShowModal = mrOK then
    begin
      cmbReason.Text := Copy(TreeReason.Selected.Text, 1, pos('..(', TreeReason.Selected.Text) - 1);
      CheckReason;
      cmbReason.SetFocus;
      cmbReason.SelectAll;
    end;
    Free;
  end;
end;

procedure TfData.FormShow(Sender: TObject);
var
  I: Integer;
begin
  gridLo.RowCount := 2;
  gridLo.Cells[1, 0] := 'Location';
  gridLo.Cells[2, 0] := 'Item No';
  gridLo.Cells[3, 0] := 'DateCode';
  case fRepair.giLocateItem of
    1: cmblocation.Color := $0080FFFF;
    2: editItem.Color := $0080FFFF;
    3: begin
      cmblocation.Color := $0080FFFF;
      editItem.Color := $0080FFFF;
    end;
  end;

  with  fRepair.QryTemp do
  begin
      Close;
      Params.CreateParam(ftString,'defect',ptInput);
      CommandText := ' select distinct b.reason_code,b.reason_desc from sajet.sys_defect_reason a,sajet.sys_reason b,sajet.sys_defect c '+
                     ' where a.reason_id = b.reason_id and a.defect_id =c.defect_id  and c.defect_Code =:defect and a.enabled=''Y'' '+
                     ' and b.enabled=''Y'' and c.enabled=''Y'' order by b.reason_code';
      Params.ParamByName('defect').AsString := LabDefectCode.Caption ;
      Open;
      if IsEmpty then Exit;
      First;
      for i :=0 to RecordCount-1 do
      begin
          cmbReason.Items.Add(fieldbyName('reason_code').AsString+'^~^'+fieldbyName('reason_desc').AsString);
          Next;
      end;

  end;


  //ShowLocation(RecID);
end;

procedure TfData.ShowLocation(sID: string);
var Irow: Integer;
begin
  Irow := 0;
  with fRepair.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'recid', ptInput);
    CommandText := 'Select RECID,LOCATION,ITEM_NO,UPDATE_USERID ' +
      'From SAJET.G_SN_REPAIR_LOCATION ' +
      'WHERE RECID = :RECID ' +
      'ORDER BY LOCATION ';
    Params.ParamByName('recid').AsString := sID;
    Open;
    if RecordCount <> 0 then
    begin
      gridLo.RowCount := RecordCount + 1;
      while not EOF do
      begin
        gridLo.Cells[1, Irow + 1] := FieldByName('LOCATION').AsSTring;
        gridLo.Cells[2, Irow + 1] := FieldByName('ITEM_NO').AsSTring;
        Inc(iRow);
        Next;
      end;
    end;
    Close;
  end;
end;

procedure TfData.editItemKeyPress(Sender: TObject; var Key: Char);
var
  iRow: Integer;
begin
  if Key <> #13 then
    Exit;
  if Trim(editItem.text) = '' then
    Exit;
    // limit by key 2008/06/11
  {with fRepair.QryTemp do
  begin
    Close;
    Params.Clear;
    if editLocation.Text <> '' then
      Params.CreateParam(ftString, 'location', ptInput);
    Params.CreateParam(ftString, 'wo', ptInput);
    Params.CreateParam(ftString, 'part', ptInput);
    CommandText := 'Select b.part_no from SAJET.G_WO_BOM a, sajet.sys_part b '
      + 'where a.work_order = :wo '
      + 'and b.part_no = :part ';

    if editLocation.Text <> '' then
      CommandText := CommandText + 'and a.location = :location ';

    CommandText := CommandText + 'and a.item_part_id = b.part_id '
      + 'group by b.part_no '
      + 'order by b.part_no ';
    if editLocation.Text <> '' then
      Params.ParamByName('location').AsString := editLocation.Text;
    Params.ParamByName('wo').AsString := fRepair.LabWO.Caption;
    Params.ParamByName('part').AsString := editItem.text;
    open;
    if RecordCount = 0 then
       // MessageDlg('Part No and Location Check Fail!!',mtConfirmation,[mbOK],0)
    else
      sbtnAddClick(Self);

  end;
  }

  // add by key 2008/06/11
    if not Checkitemno then
     exit
    else
      sbtnAddClick(Self);

end;

procedure TfData.Delete1Click(Sender: TObject);
var i, T: Integer;
begin
  if sSTring.Count = 0 then
  begin
    ShowMessage('Please Choose Data !!');
    eXIT;
  end;
    // 針對尚未存入資料庫的資料
  if (sSTring.Strings[0] = '') and (sSTring.Strings[1] = '') then
    EXIT;
  if MessageDlg('Sure to Delete Data !? ', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    for I := 0 to GridLo.RowCount - 1 do
    begin
      if GridLo.Cells[1, I] = sSTring.Strings[0] then
        if GridLo.Cells[2, I] = sSTring.Strings[1] then
        begin
          for T := I to GridLo.RowCount - 1 do
          begin
            GridLo.Cells[1, T] := GridLo.Cells[1, T + 1];
            GridLo.Cells[2, T] := GridLo.Cells[2, T + 1];
          end;
        end;
    end;
    GridLo.Rows[GridLo.RowCount - 1].Clear;
    if GridLo.RowCount > 2 then
      GridLo.RowCount := GridLo.RowCount - 1;
  end;
end;

procedure TfData.gridLoSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  sSTring.Clear;
  sSTring.add(GridLo.Cells[1, ARow]);
  sSTring.add(GridLo.Cells[2, ARow]);
end;

procedure TfData.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if DBGrid1.Columns.Items[3].Field.text = 'N' then
    DBGrid1.Canvas.Font.Color := clRed;
 // else
 //   DBGrid1.Canvas.Brush.Color:=clYellow;

 // DBGrid1.Canvas.Font.Color:=clGreen;
  DBGrid1.DefaultDrawDataCell(rect, Column.Field, State);
end;

procedure TfData.sbtnAddClick(Sender: TObject);
var
  iRow: Integer;
begin
  //check item no by key 2008/06/11
  if (trim(edititem.Text)<>'') and  (not Checkitemno) then
    exit;


    
  case fRepair.giLocateItem of
    0: if (TRIM(cmblocation.Text) = '') and (TRIM(editItem.Text) = '') then
      begin
        MessageDlg('Please input Location', mtError, [mbOK], 0);
        cmblocation.SelectAll;
        cmblocation.SetFocus;
        Exit;
      end;
    1: if (TRIM(cmblocation.Text) = '') then
      begin
        MessageDlg('Please input Location', mtError, [mbOK], 0);
        cmblocation.SelectAll;
        cmblocation.SetFocus;
        Exit;
      end;
    2: if (TRIM(editItem.Text) = '') then
      begin
        MessageDlg('Please input Item No', mtError, [mbOK], 0);
        editItem.SelectAll;
        editItem.SetFocus;
        Exit;
      end;
    3: if TRIM(cmblocation.Text) = '' then
      begin
        MessageDlg('Please input Location', mtError, [mbOK], 0);
        cmblocation.SelectAll;
        cmblocation.SetFocus;
        Exit;
      end
      else if TRIM(editItem.Text) = '' then
      begin
        MessageDlg('Please input Item No', mtError, [mbOK], 0);
        editItem.SelectAll;
        editItem.SetFocus;
        Exit;
      end;
  end;

  if edtDateCode.Text ='' then
  begin
        MessageDlg('Please Date Code ', mtError, [mbOK], 0);
        edtDateCode.SelectAll;
        edtDateCode.SetFocus;
        Exit;
  end;
  // Check duplication
  for iRow := 1 to GridLo.RowCount - 1 do
  begin
    if GridLo.Cells[1, iRow] = Trim(cmblocation.Text) then
    begin
      if GridLo.Cells[2, iRow] = Trim(editItem.Text) then
      begin
        ShowMessage('Data Duplication!');
        Exit;
      end;
    end;
  end;
  iRow := GridLo.RowCount - 1;
  GridLo.RowCount := GridLo.RowCount + 1;
  GridLo.Cells[1, iRow] := Trim(cmblocation.Text);
  GridLo.Cells[2, iRow] := Trim(editItem.Text);
  GridLo.Cells[3, iRow] := Trim(edtDateCode.Text);
  cmblocation.Text := '';
  editItem.Text := '';
end;

function TfData.GetItemID(PARTNO: string): string;
begin

  with fRepair.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PART_NO', ptInput);
    CommandText := 'Select PART_ID ' +
      'From SAJET.SYS_PART ' +
      'Where PART_NO = :PART_NO ';
    Params.ParamByName('PART_NO').AsString := PARTNO;
    Open;
    if RecordCount <= 0 then
    begin
      Result := '';
    end
    else
      Result := FieldByName('PART_ID').AsString;
    Close;
  end;
end;

procedure TfData.SpeedButton1Click(Sender: TObject);

var K: Char;
begin
  with TfFilter.Create(Self) do
  begin
    with QryData do
    begin
      RemoteServer := fRepair.QryData.RemoteServer;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'Duty_Code', ptInput);
      CommandText := 'Select Duty_Code "Duty Code", Duty_Desc "Duty Desc" '
        + 'From SAJET.SYS_DUTY '
        + 'Where Duty_Code Like :Duty_Code '
        + 'AND Enabled = ''Y'' '
        + 'Order By Duty_Code';
      Params.ParamByName('Duty_Code').AsString := Trim(cmbRepair.Text) + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      K := #13;
      cmbRepair.Text := QryData.Fieldbyname('Duty Code').AsString;
      editDutyKeyPress(cmbRepair, K);
    end;
    QryData.Close;
    Free;
  end;

end;

procedure TfData.SbtnQueryClick(Sender: TObject);
begin
  with fRepair.QryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DEFECTCODE', ptInput);
    CommandText := 'Select D.REASON_CODE,D.REASON_DESC,D.ENABLED,Count(REASON_CODE) CNT ' +
      'From SAJET.G_SN_DEFECT A,' +
      'SAJET.G_SN_REPAIR B,' +
      'SAJET.SYS_DEFECT C,' +
      'SAJET.SYS_REASON D ' +
      'Where A.RECID = B.RECID and ' +
      'A.DEFECT_ID = C.DEFECT_ID and ' +
      'C.DEFECT_CODE = :DEFECTCODE and ' +
      'B.REASON_ID = D.REASON_ID and ' +
      'D.ENABLED=''Y'' ' +
      'Group By D.REASON_CODE,D.REASON_DESC,D.ENABLED ' +
      'Order By CNT DESC ';
    Params.ParamByName('DEFECTCODE').AsString :=LabDefectCode.Caption;
    Open;
  end;
end;

procedure TfData.EditPartQtyChange(Sender: TObject);
begin
   if trim(editpartqty.Text)='' then exit;
   try
       editpartqty.Text:=inttostr(strtoint(editpartqty.Text));
   except
       MessageDlg('Part Qty Input Error', mtError, [mbOK], 0);
       editpartqty.Text:='';
       editpartqty.SetFocus;
   end;

end;

procedure TfData.EditpointChange(Sender: TObject);
begin
   if trim(editpoint.Text)='' then exit;
   try
       editpoint.Text:=inttostr(strtoint(editpoint.Text));
   except
       MessageDlg('Point Input Error', mtError, [mbOK], 0);
       editpoint.Text:='';
       editpoint.SetFocus;
   end;

end;

procedure TfData.cmbReasonSelect(Sender: TObject);
var i,iPos:Integer;
begin
   iPos := Pos('^~^',cmbReason.Text);
   sReasonCode :=  Copy( cmbReason.Text,1,iPos-1);
   CheckReason;
   cmbRepair.Items.Clear;
   with fRepair.QryTemp do
   begin
       Close;
       Params.CreateParam(ftString,'defect',ptInput);
       Params.CreateParam(ftString,'reason',ptInput);
       CommandText := ' select distinct d.duty_code,d.duty_desc from sajet.sys_defect_reason a,'+
                      ' sajet.sys_reason b,sajet.sys_defect c ,sajet.sys_duty d   '+
                      ' where a.reason_id = b.reason_id and a.defect_id =c.defect_id  '+
                      ' and c.defect_Code = :defect and a.duty_id=d.duty_id and '+
                      ' b.reason_code =:reason order by duty_code desc ';
       Params.ParamByName('defect').AsString := LabDefectCode.Caption ;
       Params.ParamByName('reason').AsString := sReasonCode ;
       Open;
       if IsEmpty then Exit;
       First;
       for i :=0 to RecordCount-1 do
       begin
           cmbRepair.Items.Add(fieldbyName('duty_code').AsString+'^~^'+fieldbyName('duty_Desc').AsString);
           Next;
       end;
   end;
   cmbRepair.SetFocus;
end;

procedure TfData.cmbRepairSelect(Sender: TObject);
var i,iPos:Integer;
begin
    iPos := Pos('^~^',cmbRepair.Text);
    sDutyCode :=  Copy( cmbRepair.Text,1,iPos-1);
    CheckDuty;
    cmblocation.Items.Clear;
    with fRepair.QryTemp do
    begin
       Close;
       Params.CreateParam(ftString,'defect',ptInput);
       Params.CreateParam(ftString,'reason',ptInput);
       Params.CreateParam(ftString,'duty',ptInput);
       CommandText := ' select distinct location from sajet.sys_defect_reason a,'+
                      ' sajet.sys_reason b,sajet.sys_defect c ,sajet.sys_duty d   '+
                      ' where a.reason_id = b.reason_id and a.defect_id =c.defect_id  '+
                      ' and c.defect_Code = :defect and a.duty_id=d.duty_id and '+
                      ' b.reason_code =:reason and d.duty_code=:duty ';
       Params.ParamByName('defect').AsString := LabDefectCode.Caption ;
       Params.ParamByName('reason').AsString := sReasonCode ;
       Params.ParamByName('duty').AsString := sDutyCode ;
       Open;
       if IsEmpty then Exit;
       First;
       for i :=0 to RecordCount-1 do
       begin
           cmblocation.Items.Add(fieldbyName('location').AsString);
           Next;
       end;
    end;
end;

end.

