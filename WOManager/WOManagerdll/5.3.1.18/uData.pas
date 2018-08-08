unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, ComCtrls, DB, Grids, uFilter,
  DBGrids;

type
  TfData = class(TForm)
    sbtnClose: TSpeedButton;
    sbtnSave: TSpeedButton;
    Image5: TImage;
    Image1: TImage;
    Labtype1: TLabel;
    Labtype2: TLabel;
    Imagemain: TImage;
    Label7: TLabel;
    editWO: TEdit;
    Label8: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    editVersion: TEdit;
    Label6: TLabel;
    editQty: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    editPO: TEdit;
    Label18: TLabel;
    editMasterWO: TEdit;
    Label21: TLabel;
    editRemark: TEdit;
    cmbRoute: TComboBox;
    cmbType: TComboBox;
    cmbInProcess: TComboBox;
    cmbOutProcess: TComboBox;
    cmbCustomer: TComboBox;
    cmbLine: TComboBox;
    dateScheduledate: TDateTimePicker;
    editPart: TEdit;
    Label5: TLabel;
    cmbRule: TComboBox;
    Label13: TLabel;
    Label20: TLabel;
    combModelName: TComboBox;
    sbtnShowBom: TSpeedButton;
    Label22: TLabel;
    dateDuedate: TDateTimePicker;
    Label25: TLabel;
    editSO: TEdit;
    Label26: TLabel;
    LabFactory: TLabel;
    combVersion: TComboBox;
    Label27: TLabel;
    editBurnInTime: TEdit;
    Bevel2: TBevel;
    ImgNew: TImage;
    ImgDelete: TImage;
    sbtnNew: TSpeedButton;
    sbtnDelete: TSpeedButton;
    strgridSpec: TStringGrid;
    SpeedButton1: TSpeedButton;
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure cmbRouteChange(Sender: TObject);
    procedure editPartKeyPress(Sender: TObject; var Key: Char);
    procedure editPartExit(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmbRuleChange(Sender: TObject);
    procedure sbtnShowBomClick(Sender: TObject);
    procedure sbtnNewClick(Sender: TObject);
    procedure sbtnDeleteClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
  public
    { Public declarations }
    ModiType: string; // 'New', 'Modi'
    gPartID: string;
    function CheckWODup: Boolean;
    function GetPackSpecData: Boolean;
    function GetWOPackSpecData: Boolean;
    procedure SaveWOPackSpecData(PartId: string);
    function GetRouteID(var RouteId: string): Boolean;
    function GetPartID(var PartId: string): Boolean;
    function GetPart: string;
    function GetCustID(var CustId: string): Boolean;
    function GetPdLineID(var PdLineId: string): Boolean;
    function GetProcessID(ProcessName: string; var ProcessId: string): Boolean;
    function ExecNew(PartId, RouteID, PdLineID, CustID, InProcessID, OutProcessID: string): Boolean;
    function ExecModi(PartId, RouteID, PdLineID, CustID, InProcessID, OutProcessID: string): Boolean;
    function CheckWORoute: Boolean;
    function CheckWOBom: Boolean;
    procedure SetTheRegion;
    procedure CopyToHistory(RecordID: string);
    procedure GetDefaultData;
    procedure getModelName;
    procedure getWoRule(PartId: string);
    procedure CopyToWORoute(RouteID: string);
    procedure CopyToWOBOM(PartId, Ver: string);
    procedure GetPartVersion;
    function BackupWORule: Boolean;
  end;

var
  fData: TfData;

implementation

{$R *.DFM}

uses uWOManager, uBom, uPFilter;

function TfData.CheckWOBom: Boolean;
begin
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select B.* '
      + 'From SAJET.SYS_PART A,'
      + '     SAJET.G_WO_BOM B '
      + 'WHERE B.WORK_ORDER = ''' + editWO.Text + ''' '
      + '  AND A.PART_NO = ''' + editPart.Text + ''' '
      + '  AND A.PART_ID = B.PART_ID '
      + '  AND ROWNUM = 1 ';
    Open;
    if RecordCount = 0 then
      Result := True
    else
      Result := False;
  end;
end;

procedure TfData.CopyToWOBOM(PartId, Ver: string);
var
  sBomID: string;
begin
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'DELETE SAJET.G_WO_BOM '
      + ' WHERE WORK_ORDER = ''' + editWO.Text + ''' ';
    Execute;

    if Trim(Ver) = '' then Ver := 'N/A';
    Close;
    Params.Clear;
    CommandText := 'select bom_id FROM SAJET.SYS_BOM_INFO '
      + ' WHERE PART_ID = ' + PartId + ' and Version = ''' + Ver + ''' ';
    Open;
    if RecordCount > 0 then
      sBomID := FieldByName('bom_id').AsString
    else
      Exit;

    Close;
    Params.Clear;
    CommandText := 'SELECT * FROM SAJET.SYS_BOM '
      + 'WHERE BOM_ID = ' + sBomId
//                   + 'AND PROCESS_ID IS not Null ' //add by 2005/01/27
    + 'AND ENABLED = ''Y'' ';

    Open;
    while not Eof do
    begin
      with fWOManager.QryTemp2 do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'WO', ptInput);
        Params.CreateParam(ftString, 'PARTID', ptInput);
        Params.CreateParam(ftString, 'ITEMPARTID', ptInput);
        Params.CreateParam(ftString, 'ITEMGROUP', ptInput);
        Params.CreateParam(ftString, 'ITEMCOUNT', ptInput);
        Params.CreateParam(ftString, 'PROCESSID', ptInput);
        Params.CreateParam(ftString, 'VERSION', ptInput);
        Params.CreateParam(ftString, 'UPDATEUSERID', ptInput);
        CommandText := 'INSERT INTO SAJET.G_WO_BOM '
          + ' (WORK_ORDER, PART_ID, ITEM_PART_ID, ITEM_GROUP, ITEM_COUNT, PROCESS_ID, VERSION, UPDATE_USERID) '
          + 'VALUES (:WO, :PARTID, :ITEMPARTID, :ITEMGROUP, :ITEMCOUNT, :PROCESSID, :VERSION, :UPDATEUSERID) ';
        Params.ParamByName('WO').AsString := editWO.Text;
        Params.ParamByName('PARTID').AsString := PartID;
        Params.ParamByName('ITEMPARTID').AsString := fWOManager.QryTemp.FieldByName('ITEM_PART_ID').AsString;
        Params.ParamByName('ITEMGROUP').AsString := fWOManager.QryTemp.FieldByName('ITEM_GROUP').AsString;
        Params.ParamByName('ITEMCOUNT').AsString := fWOManager.QryTemp.FieldByName('ITEM_COUNT').AsString;
        Params.ParamByName('PROCESSID').AsString := fWOManager.QryTemp.FieldByName('PROCESS_ID').AsString;
        Params.ParamByName('VERSION').AsString := fWOManager.QryTemp.FieldByName('VERSION').AsString;
        Params.ParamByName('UPDATEUSERID').AsString := fWOManager.UpdateUserID;
        Execute;
      end;
      Next;
    end;
    Close;
  end;
end;

function TfData.CheckWORoute: Boolean;
begin
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select B.* '
      + 'From SAJET.SYS_ROUTE A,'
      + '     SAJET.G_WO_ROUTE B '
      + 'WHERE B.WORK_ORDER = ''' + editWO.Text + ''' '
      + '  AND A.ROUTE_NAME = ''' + cmbRoute.Text + ''' '
      + '  AND A.ROUTE_ID = B.ROUTE_ID '
      + '  AND ROWNUM = 1 ';
    Open;
    if RecordCount = 0 then
      Result := True
    else
      Result := False;
  end;
end;

procedure TfData.CopyToWORoute(RouteID: string);
begin
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'DELETE SAJET.G_WO_ROUTE '
      + ' WHERE WORK_ORDER = ''' + editWO.Text + ''' ';
    Execute;

    Close;
    Params.Clear;
    CommandText := 'SELECT * FROM SAJET.SYS_ROUTE_DETAIL '
      + ' WHERE ROUTE_ID = ' + RouteID
      + '   AND ENABLED = ''Y'' ';
    Open;
    while not Eof do
    begin
      with fWOManager.QryTemp2 do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'WO', ptInput);
        Params.CreateParam(ftString, 'ROUTEID', ptInput);
        Params.CreateParam(ftString, 'PROCESSID', ptInput);
        Params.CreateParam(ftString, 'NEXTPROCESSID', ptInput);
        Params.CreateParam(ftString, 'RESULT', ptInput);
        Params.CreateParam(ftString, 'SEQ', ptInput);
        Params.CreateParam(ftString, 'PDCODE', ptInput);
        Params.CreateParam(ftString, 'NECESSARY', ptInput);
        Params.CreateParam(ftString, 'STEP', ptInput);
        Params.CreateParam(ftString, 'UPDATEUSERID', ptInput);
        CommandText := 'INSERT INTO SAJET.G_WO_ROUTE '
          + ' (WORK_ORDER, ROUTE_ID, PROCESS_ID, NEXT_PROCESS_ID, RESULT, SEQ, PD_CODE, NECESSARY, STEP, UPDATE_USERID) '
          + ' VALUES(:WO, :ROUTEID, :PROCESSID, :NEXTPROCESSID, :RESULT, :SEQ, :PDCODE, :NECESSARY, :STEP, :UPDATEUSERID) ';
        Params.ParamByName('WO').AsString := editWO.Text;
        Params.ParamByName('ROUTEID').AsString := fWOManager.QryTemp.FieldByName('Route_ID').AsString;
        Params.ParamByName('PROCESSID').AsString := fWOManager.QryTemp.FieldByName('PROCESS_ID').AsString;
        Params.ParamByName('NEXTPROCESSID').AsString := fWOManager.QryTemp.FieldByName('NEXT_PROCESS_ID').AsString;
        Params.ParamByName('RESULT').AsString := fWOManager.QryTemp.FieldByName('RESULT').AsString;
        Params.ParamByName('SEQ').AsString := fWOManager.QryTemp.FieldByName('SEQ').AsString;
        Params.ParamByName('PDCODE').AsString := fWOManager.QryTemp.FieldByName('PD_CODE').AsString;
        Params.ParamByName('NECESSARY').AsString := fWOManager.QryTemp.FieldByName('NECESSARY').AsString;
        Params.ParamByName('STEP').AsString := fWOManager.QryTemp.FieldByName('STEP').AsString;
        Params.ParamByName('UPDATEUSERID').AsString := fWOManager.UpdateUserID;
        Execute;
      end;
      Next;
    end;
    Close;
  end;
end;

procedure TfData.getModelName;
begin
  combModelName.Clear;

  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT MODEL_NAME '
      + '  FROM SAJET.G_WO_BASE A, SAJET.SYS_PART B '
      + ' WHERE B.PART_NO = ''' + editPart.Text + ''' '
      + '   AND MODEL_NAME IS NOT NULL '
      + '   AND A.MODEL_ID = B.PART_ID '
      + ' GROUP BY MODEL_NAME ';
    Open;
    while not Eof do
    begin
      combModelName.Items.Add(FieldByName('Model_Name').AsString);
      Next;
    end;
    Close;
  end;
  combModelName.Items.Add('');
  combModelName.ItemIndex := 0;
end;

procedure TfData.getWoRule(PartId: string);
begin
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT Rule_Value '
      + '  FROM SAJET.SYS_PART_RULE B '
      + ' WHERE B.PART_ID = ' + PartId
      + '   AND Rule_Type = ''W/O Rule'' '
      + '   AND ROWNUM = 1 ';
    Open;
    cmbRule.ItemIndex := cmbRule.Items.IndexOf(FieldByName('Rule_Value').AsString);
    if cmbRule.ItemIndex = -1 then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PN', ptInput);
      CommandText := 'Select Rule_Value '
        + 'From SAJET.SYS_MODEL_RULE B, SAJET.SYS_PART C '
        + 'Where B.MODEL_ID = C.MODEL_ID '
        + '  AND B.Rule_Type = ''W/O Rule'' '
        + '  AND C.PART_ID = :PN';
      Params.ParamByName('PN').AsString := PartId;
      Open;
      cmbRule.ItemIndex := cmbRule.Items.IndexOf(FieldByName('Rule_Value').AsString);
      Close;
    end;
    Close;
  end;
end;

procedure TfData.GetDefaultData;
var sModel: string;
begin
  // Default Route
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PN', ptInput);
    CommandText := 'Select ROUTE_NAME,A.BURNIN_TIME,a.model_id, rule_set ' +
      'From SAJET.SYS_PART A,' +
      'SAJET.SYS_ROUTE B ' +
      'Where A.ROUTE_ID = B.ROUTE_ID(+) and ' +
      'A.PART_NO = :PN ';
    Params.ParamByName('PN').AsString := editPart.Text;
    Open;
    cmbRoute.ItemIndex := cmbRoute.Items.IndexOf(FieldByname('ROUTE_NAME').AsString);
    editBurnInTime.Text := FieldByName('BurnIn_Time').AsString;
    sModel := FieldByName('model_id').AsString;
    cmbRule.ItemIndex := cmbRule.Items.IndexOf(FieldByName('rule_set').AsString);
    if (cmbRoute.ItemIndex = -1) or (StrToIntDef(editBurnInTime.Text, 0) = 0) then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PN', ptInput);
      CommandText := 'Select ROUTE_NAME,C.BURNIN_TIME ' +
        'From SAJET.SYS_ROUTE B, SAJET.SYS_MODEL C ' +
        'Where C.ROUTE_ID = B.ROUTE_ID(+) and ' +
        'C.MODEL_ID = :PN';
      Params.ParamByName('PN').AsString := sModel;
      Open;
      if cmbRoute.ItemIndex = -1 then
        cmbRoute.ItemIndex := cmbRoute.Items.IndexOf(FieldByname('ROUTE_NAME').AsString);
      if StrToIntDef(editBurnInTime.Text, 0) = 0 then
        editBurnInTime.Text := FieldByName('BurnIn_Time').AsString;
    end;
    Close;
  end;

  if cmbRoute.Text <> '' then
    cmbRouteChange(Self);
  // Get Max Version
  if combVersion.Items.Count > 0 then
    combVersion.ItemIndex := 0;
end;

procedure TfData.CopyToHistory(RecordID: string);
begin
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WO', ptInput);
    CommandText := 'Insert Into SAJET.G_HT_WO_BASE ' +
      'Select * from SAJET.G_WO_BASE ' +
      'Where WORK_ORDER = :WO ';
    Params.ParamByName('WO').AsString := RecordID;
    Execute;
  end;
end;

procedure TfData.SaveWOPackSpecData(PartId: string);
var i: integer;
begin
  with fWOManager.QryTemp do
  begin
     //If cmbPKSpec.Text <> '' Then
    if strgridSpec.Cells[0, 1] <> '' then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'MODEL_ID', ptInput);
      Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
      Params.CreateParam(ftString, 'PALLET_CAPACITY', ptInput);
      Params.CreateParam(ftString, 'CARTON_CAPACITY', ptInput);
      Params.CreateParam(ftString, 'Box_CAPACITY', ptInput);
      Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
      CommandText := 'Insert Into SAJET.G_PACK_SPEC ' +
        '(WORK_ORDER,MODEL_ID,PKSPEC_NAME,PALLET_CAPACITY,CARTON_CAPACITY,BOX_CAPACITY,UPDATE_USERID)' +
        'Values (:WORK_ORDER,:MODEL_ID,:PKSPEC_NAME,:PALLET_CAPACITY,:CARTON_CAPACITY,:BOX_CAPACITY,:UPDATE_USERID) ';
      for i := 1 to strgridSpec.RowCount - 1 do
      begin
        Params.ParamByName('WORK_ORDER').AsString := Trim(editWO.Text);
        Params.ParamByName('MODEL_ID').AsString := PartId;
        Params.ParamByName('PKSPEC_NAME').AsString := strgridSpec.Cells[0, i];
        Params.ParamByName('PALLET_CAPACITY').AsString := strgridSpec.Cells[3, i];
        Params.ParamByName('CARTON_CAPACITY').AsString := strgridSpec.Cells[2, i];
        Params.ParamByName('Box_CAPACITY').AsString := strgridSpec.Cells[1, i];
        Params.ParamByName('UPDATE_USERID').AsString := fWOManager.UpdateUserID;
        Execute;
      end;
    end;
  end;
end;

function TfData.GetWOPackSpecData: Boolean;
var i, iRow: integer;
begin
  for i := 1 to strgridSpec.RowCount - 1 do
    strgridSpec.Rows[i].Clear;
  strgridSpec.RowCount := 2;

  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    CommandText := 'Select PKSPEC_NAME,Box_CAPACITY,CARTON_CAPACITY,PALLET_CAPACITY ' +
      'From SAJET.G_PACK_SPEC ' +
      'Where WORK_ORDER = :WORK_ORDER ' +
      'ORDER BY Box_CAPACITY desc, CARTON_CAPACITY desc,PALLET_CAPACITY desc';
    Params.ParamByName('WORK_ORDER').AsString := Trim(editWO.Text);
    Open;
    iRow := 0;
    while not Eof do
    begin
      inc(iRow);
      strgridSpec.Cells[0, iRow] := FieldByName('PKSPEC_NAME').asstring;
      strgridSpec.Cells[1, iRow] := FieldByName('Box_CAPACITY').asstring;
      strgridSpec.Cells[2, iRow] := FieldByName('CARTON_CAPACITY').asstring;
      strgridSpec.Cells[3, iRow] := FieldByName('PALLET_CAPACITY').asstring;
      Next;
    end;

    if iRow <= 1 then
      strgridSpec.RowCount := 2
    else
      strgridSpec.RowCount := iRow + 1;
  end;
  Close;

end;

function TfData.GetPackSpecData: Boolean;
var i, iRow: integer;
begin
  if Trim(editPart.Text) = '' then Exit;

  for i := 1 to strgridSpec.RowCount - 1 do
    strgridSpec.Rows[i].Clear;
  strgridSpec.RowCount := 2;

  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PART_NO', ptInput);
    fWOManager.QryTemp.CommandText := 'Select C.PKSPEC_NAME,C.BOX_QTY,C.CARTON_QTY,C.PALLET_QTY ' +
      'From SAJET.SYS_PART A, ' +
      'SAJET.SYS_PART_PKSPEC B, ' +
      'SAJET.SYS_PKSPEC C ' +
      'Where A.PART_NO = :PART_NO and ' +
      'A.PART_ID = B.PART_ID and ' +
      'B.PKSPEC_NAME = C.PKSPEC_NAME and ' +
      'C.ENABLED = ''Y'' ' +
      'Group By C.PKSPEC_NAME,C.BOX_QTY,C.CARTON_QTY,C.PALLET_QTY ' +
      'ORDER BY C.BOX_QTY desc,C.CARTON_QTY desc,C.PALLET_QTY desc';
    Params.ParamByName('PART_NO').AsString := Trim(editPart.Text);
    Open;
    iRow := 0;
    if not IsEmpty then
    begin
      while not Eof do
      begin
        inc(iRow);
        strgridSpec.Cells[0, iRow] := FieldByName('PKSPEC_NAME').asstring;
        strgridSpec.Cells[1, iRow] := FieldByName('BOX_QTY').asstring;
        strgridSpec.Cells[2, iRow] := FieldByName('CARTON_QTY').asstring;
        strgridSpec.Cells[3, iRow] := FieldByName('PALLET_QTY').asstring;
        Next;
      end;
    end
    else
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PART_NO', ptInput);
      fWOManager.QryTemp.CommandText := 'Select C.PKSPEC_NAME,C.BOX_QTY,C.CARTON_QTY,C.PALLET_QTY ' +
        'From SAJET.SYS_PART A, ' +
        'SAJET.SYS_MODEL D, ' +
        'SAJET.SYS_MODEL_PKSPEC B, ' +
        'SAJET.SYS_PKSPEC C ' +
        'Where A.PART_NO = :PART_NO ' +
        'AND A.MODEL_ID = D.MODEL_ID ' +
        'AND A.MODEL_ID = B.MODEL_ID ' +
        'AND B.PKSPEC_NAME = C.PKSPEC_NAME ' +
        'AND C.ENABLED = ''Y'' ' +
        'Group By C.PKSPEC_NAME,C.BOX_QTY,C.CARTON_QTY,C.PALLET_QTY ' +
        'ORDER BY C.BOX_QTY desc, C.CARTON_QTY desc,C.PALLET_QTY desc';
      Params.ParamByName('PART_NO').AsString := Trim(editPart.Text);
      Open;
      while not Eof do
      begin
        inc(iRow);
        strgridSpec.Cells[0, iRow] := FieldByName('PKSPEC_NAME').asstring;
        strgridSpec.Cells[1, iRow] := FieldByName('BOX_QTY').asstring;
        strgridSpec.Cells[2, iRow] := FieldByName('CARTON_QTY').asstring;
        strgridSpec.Cells[3, iRow] := FieldByName('PALLET_QTY').asstring;
        Next;
      end;
    end;

    if iRow <= 1 then
      strgridSpec.RowCount := 2
    else
      strgridSpec.RowCount := iRow + 1;
  end;
end;

procedure TfData.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfData.FormCreate(Sender: TObject);
begin
  Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'bDetail.bmp');
  SetTheRegion;

// 找出所有生產線
  cmbLine.Items.Clear;
  with fWOManager.QryTemp do
  begin
    Close;
    //限定factory_id
    {
    Params.Clear;
    Params.CreateParam(ftString, 'FACTORY_ID', ptInput);
    CommandText := 'Select PDLINE_NAME ' +
      'From SAJET.SYS_PDLINE ' +
      'Where ENABLED = ''Y'' and ' +
      'FACTORY_ID = :FACTORY_ID ' +
      'Order By PDLINE_NAME ';
    Params.ParamByName('FACTORY_ID').AsString := fWOManager.FcID;
    }
    //不限定factory_id
    CommandText := 'Select PDLINE_NAME ' +
      'From SAJET.SYS_PDLINE ' +
      'Where ENABLED = ''Y'' ' +
      'Order By PDLINE_NAME ';
    Open;
    while not Eof do
    begin
      cmbLine.Items.Add(Fieldbyname('PDLINE_NAME').AsString);
      Next;
    end;
    Close;
  end;

// 找出所有 ROUTE
  cmbRoute.Items.Clear;
  with fWOManager.QryTemp do
  begin
    Close;
    //有限定FACTORY_ID
   {
    Params.Clear;
    Params.CreateParam(ftString, 'FACTORY_ID', ptInput);
    CommandText := 'Select ROUTE_NAME ' +
      'From SAJET.SYS_ROUTE A, ' +
      'SAJET.SYS_ROUTE_DETAIL B, ' +
      'SAJET.SYS_PROCESS C ' +
      'Where A.ENABLED = ''Y'' and ' +
      'A.ROUTE_ID = B.ROUTE_ID and ' +
      'B.NEXT_PROCESS_ID = C.PROCESS_ID and ' +
      'C.FACTORY_ID = :FACTORY_ID ' +
      'Group By ROUTE_NAME ';
    Params.ParamByName('FACTORY_ID').AsString := fWOManager.FcID;
    }
    //不限定FACTORY_ID
    CommandText := 'Select ROUTE_NAME ' +
      'From SAJET.SYS_ROUTE A, ' +
      'SAJET.SYS_ROUTE_DETAIL B, ' +
      'SAJET.SYS_PROCESS C ' +
      'Where A.ENABLED = ''Y'' and ' +
      'A.ROUTE_ID = B.ROUTE_ID and  ' +
      'B.NEXT_PROCESS_ID = C.PROCESS_ID  ' +
      'Group By ROUTE_NAME  Order by ROUTE_NAME ';
    Open;
    while not Eof do
    begin
      cmbRoute.Items.Add(Fieldbyname('ROUTE_NAME').AsString);
      Next;
    end;
    Close;
  end;

// 找出所有客戶
  cmbCustomer.Items.Clear;
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select CUSTOMER_CODE, CUSTOMER_CODE || '' '' || CUSTOMER_NAME CUST ' +
      'From SAJET.SYS_CUSTOMER ' +
      'Where ENABLED = ''Y'' ' +
      'Order By CUSTOMER_CODE ';
    Open;
    while not Eof do
    begin
       if Trim(Fieldbyname('CUST').AsString) <> '' then
          cmbCustomer.Items.Add(Fieldbyname('CUST').AsString);
       Next;
    end;
    Close;
  end;

// 找出所有工單類型
  cmbType.Items.Clear;
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'FACTORY_ID', ptInput);
    CommandText := 'Select WO_TYPE ' +
      'From SAJET.G_WO_BASE ' +
      'Where FACTORY_ID = :FACTORY_ID ' +
      'Group By WO_TYPE ';
    Params.ParamByName('FACTORY_ID').AsString := fWOManager.FcID;
    Open;
    while not Eof do
    begin
      cmbType.Items.Add(Fieldbyname('WO_TYPE').AsString);
      Next;
    end;
    Close;
  end;

// 找出所有工單規則
  cmbRule.Items.Clear;
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select FUNCTION_NAME ' +
      'From SAJET.SYS_MODULE_PARAM ' +
      'Where MODULE_NAME = ''W/O RULE'' ' +
      'Group By FUNCTION_NAME ';
    Open;
    while not Eof do
    begin
      cmbRule.Items.Add(Fieldbyname('FUNCTION_NAME').AsString);
      Next;
    end;
    Close;
  end;

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

function TfData.CheckWODup: Boolean;
begin
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WO', ptInput);
    CommandText := 'Select WORK_ORDER ' +
      'From SAJET.G_WO_BASE ' +
      'Where WORK_ORDER = :WO ';
    Params.ParamByName('WO').AsString := Trim(editWO.Text);
    Open;
    Result := (RecordCount <= 0);
    Close;
  end;
  if not Result then
  begin
    MessageDlg('Work Order Duplicate !!', mtError, [mbOK], 0);
    editWO.SetFocus;
    Exit;
  end;
end;

function TfData.GetPartID(var PartId: string): Boolean;
begin
  Result := False;
  PartId := '';
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PART_NO', ptInput);
    CommandText := 'Select PART_ID ' +
      'From SAJET.SYS_PART ' +
      'Where PART_NO = :PART_NO ';
    Params.ParamByName('PART_NO').AsString := Trim(editPart.Text);
    Open;
    if recordCount <= 0 then
    begin
      MessageDlg('Part No Error !!', mtError, [mbOK], 0);
      Exit;
    end;
    PartId := Fieldbyname('PART_ID').AsString;
    Result := True;
    Close;
  end;
end;

function TfData.GetRouteID(var RouteId: string): Boolean;
begin
  Result := False;
  RouteId := '';
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'ROUTE_NAME', ptInput);
    CommandText := 'Select ROUTE_ID ' +
      'From SAJET.SYS_ROUTE ' +
      'Where ROUTE_NAME = :ROUTE_NAME ';
    Params.ParamByName('ROUTE_NAME').AsString := Trim(cmbRoute.Text);
    Open;
    if recordCount <= 0 then
    begin
      MessageDlg('Route Name Error !!', mtError, [mbOK], 0);
      Exit;
    end;
    RouteId := Fieldbyname('ROUTE_ID').AsString;
    Result := True;
    Close;
  end;
end;

function TfData.GetCustID(var CustId: string): Boolean;
begin
  Result := False;
  CustId := '';
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CUSTOMER_CODE', ptInput);
    CommandText := 'Select CUSTOMER_ID ' +
      'From SAJET.SYS_CUSTOMER ' +
      'Where CUSTOMER_CODE = :CUSTOMER_CODE ';
    Params.ParamByName('CUSTOMER_CODE').AsString := Trim(Copy(cmbCustomer.Text, 1, Pos(' ', cmbCustomer.Text) - 1));
    Open;
    if recordCount <= 0 then
    begin
      MessageDlg('Customer Data Error !!', mtError, [mbOK], 0);
      Exit;
    end;
    CustId := Fieldbyname('CUSTOMER_ID').AsString;
    Result := True;
    Close;
  end;
end;

function TfData.GetPdLineID(var PdLineId: string): Boolean;
begin
  Result := False;
  PdLineId := '';
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PDLINE_NAME', ptInput);
    CommandText := 'Select PDLINE_ID ' +
      'From SAJET.SYS_PDLINE ' +
      'Where PDLINE_NAME = :PDLINE_NAME ';
    Params.ParamByName('PDLINE_NAME').AsString := cmbLine.Text;
    Open;
    if recordCount <= 0 then
    begin
      MessageDlg('Production Line Data Error !!', mtError, [mbOK], 0);
      Exit;
    end;
    PdLineId := Fieldbyname('PDLINE_ID').AsString;
    Result := True;
    Close;
  end;
end;

function TfData.GetProcessID(ProcessName: string; var ProcessId: string): Boolean;
begin
  Result := False;
  ProcessId := '';
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PROCESS_NAME', ptInput);
    CommandText := 'Select PROCESS_ID ' +
      'From SAJET.SYS_PROCESS ' +
      'Where PROCESS_NAME = :PROCESS_NAME ';
    Params.ParamByName('PROCESS_NAME').AsString := ProcessName;
    Open;
    if recordCount <= 0 then
    begin
      MessageDlg('Process Data Error !!', mtError, [mbOK], 0);
      Exit;
    end;
    ProcessId := Fieldbyname('PROCESS_ID').AsString;
    Result := True;
    Close;
  end;
end;

function TfData.ExecNew(PartId, RouteID, PdLineID, CustID, InProcessID, OutProcessID: string): Boolean;
begin
  Result := False;
  try
    with fWOManager.QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'FACTORY_ID', ptInput);
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'WO_TYPE', ptInput);
      Params.CreateParam(ftString, 'WO_RULE', ptInput);
      Params.CreateParam(ftString, 'MODEL_ID', ptInput);
      Params.CreateParam(ftString, 'VERSION', ptInput);
      Params.CreateParam(ftString, 'TARGET_QTY', ptInput);
      Params.CreateParam(ftDateTime, 'WO_SCHEDULE_DATE', ptInput);
      Params.CreateParam(ftDateTime, 'WO_DUE_DATE', ptInput);
      Params.CreateParam(ftString, 'ROUTE_ID', ptInput);
      Params.CreateParam(ftString, 'DEFAULT_PDLINE_ID', ptInput);
      Params.CreateParam(ftString, 'START_PROCESS_ID', ptInput);
      Params.CreateParam(ftString, 'END_PROCESS_ID', ptInput);
      Params.CreateParam(ftString, 'CUSTOMER_ID', ptInput);
      Params.CreateParam(ftString, 'PO_NO', ptInput);
      Params.CreateParam(ftString, 'SALES_ORDER', ptInput);
      Params.CreateParam(ftString, 'MASTER_WO', ptInput);
      Params.CreateParam(ftString, 'REMARK', ptInput);
      Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
      Params.CreateParam(ftString, 'MODEL_NAME', ptInput);
      Params.CreateParam(ftInteger, 'BT', ptInput);
      CommandText := 'Insert Into SAJET.G_WO_BASE ' +
        '(FACTORY_ID,WORK_ORDER,WO_TYPE,WO_RULE,MODEL_ID,VERSION,' +
        'TARGET_QTY,WO_SCHEDULE_DATE,WO_DUE_DATE,' +
        'ROUTE_ID,DEFAULT_PDLINE_ID,' +
        'START_PROCESS_ID,END_PROCESS_ID,' +
        'CUSTOMER_ID,PO_NO,SALES_ORDER,MASTER_WO,' +
        'REMARK,UPDATE_USERID, MODEL_NAME, BURNIN_TIME) ' +
        'Values (:FACTORY_ID,:WORK_ORDER,:WO_TYPE,:WO_RULE,:MODEL_ID,:VERSION,' +
        ':TARGET_QTY,:WO_SCHEDULE_DATE,:WO_DUE_DATE,' +
        ':ROUTE_ID,:DEFAULT_PDLINE_ID,' +
        ':START_PROCESS_ID,:END_PROCESS_ID,' +
        ':CUSTOMER_ID,:PO_NO,:SALES_ORDER,:MASTER_WO,' +
        ':REMARK,:UPDATE_USERID, :MODEL_NAME, :BT) ';
      Params.ParamByName('FACTORY_ID').AsString := fWOManager.FcID;
      Params.ParamByName('WORK_ORDER').AsString := Trim(editWO.Text);
      Params.ParamByName('WO_TYPE').AsString := Trim(cmbType.Text);
      Params.ParamByName('WO_RULE').AsString := Trim(cmbRule.Text);
      Params.ParamByName('MODEL_ID').AsString := PartId;
       //Params.ParamByName('VERSION').AsString := Trim(editVersion.Text);
      Params.ParamByName('VERSION').AsString := Trim(combVersion.Text);
      Params.ParamByName('TARGET_QTY').AsString := InttoStr(StrToIntDef(Trim(editQty.Text), 0));
      Params.ParamByName('WO_SCHEDULE_DATE').AsDate := dateScheduledate.Date;
      Params.ParamByName('WO_DUE_DATE').AsDate := dateDuedate.Date;
      Params.ParamByName('ROUTE_ID').AsString := RouteID;
      Params.ParamByName('DEFAULT_PDLINE_ID').AsString := PdLineID;
      Params.ParamByName('START_PROCESS_ID').AsString := InProcessID;
      Params.ParamByName('END_PROCESS_ID').AsString := OutProcessID;
      Params.ParamByName('CUSTOMER_ID').AsString := CustID;
      Params.ParamByName('PO_NO').AsString := Trim(editPO.Text);
      Params.ParamByName('SALES_ORDER').AsString := Trim(editSO.Text);
      Params.ParamByName('MASTER_WO').AsString := Trim(editMasterWO.Text);
      Params.ParamByName('REMARK').AsString := Trim(editRemark.Text);
      Params.ParamByName('UPDATE_USERID').AsString := fWOManager.UpdateUserID;
      Params.ParamByName('Model_Name').AsString := combModelName.Text;
      Params.ParamByName('BT').AsString := Trim(editBurnInTime.Text); //StrToIntDef(Trim(editBurnInTime.Text),0);
      Execute;
      SaveWOPackSpecData(PartId);
    end;
    CopyToHistory(Trim(editWO.Text));
    Result := True;
  except
    MessageDlg('Database Update Error !!', mtError, [mbOK], 0);
  end;
end;

function TfData.ExecModi(PartId, RouteID, PdLineID, CustID, InProcessID, OutProcessID: string): Boolean;
begin
  Result := False;
  try
    with fWOManager.QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WO_TYPE', ptInput);
      Params.CreateParam(ftString, 'WO_RULE', ptInput);
      Params.CreateParam(ftString, 'MODEL_ID', ptInput);
      Params.CreateParam(ftString, 'VERSION', ptInput);
      Params.CreateParam(ftString, 'TARGET_QTY', ptInput);
      Params.CreateParam(ftDateTime, 'WO_SCHEDULE_DATE', ptInput);
      Params.CreateParam(ftDateTime, 'WO_DUE_DATE', ptInput);
      Params.CreateParam(ftString, 'ROUTE_ID', ptInput);
      Params.CreateParam(ftString, 'DEFAULT_PDLINE_ID', ptInput);
      Params.CreateParam(ftString, 'START_PROCESS_ID', ptInput);
      Params.CreateParam(ftString, 'END_PROCESS_ID', ptInput);
      Params.CreateParam(ftString, 'CUSTOMER_ID', ptInput);
      Params.CreateParam(ftString, 'PO_NO', ptInput);
      Params.CreateParam(ftString, 'SALES_ORDER', ptInput);
      Params.CreateParam(ftString, 'MASTER_WO', ptInput);
      Params.CreateParam(ftString, 'REMARK', ptInput);
      Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'MODEL_NAME', ptInput);
      Params.CreateParam(ftString, 'BT', ptInput);
      CommandText := 'Update SAJET.G_WO_BASE ' +
        'Set WO_TYPE = :WO_TYPE,' +
        'WO_RULE = :WO_RULE,' +
        'MODEL_ID = :MODEL_ID,' +
        'VERSION = :VERSION,' +
        'TARGET_QTY = :TARGET_QTY,' +
        'WO_SCHEDULE_DATE = :WO_SCHEDULE_DATE,' +
        'WO_DUE_DATE = :WO_DUE_DATE,' +
        'ROUTE_ID = :ROUTE_ID,' +
        'DEFAULT_PDLINE_ID = :DEFAULT_PDLINE_ID,' +
        'START_PROCESS_ID = :START_PROCESS_ID,' +
        'END_PROCESS_ID = :END_PROCESS_ID,' +
        'CUSTOMER_ID = :CUSTOMER_ID,' +
        'PO_NO = :PO_NO,' +
        'SALES_ORDER = :SALES_ORDER,' +
        'MASTER_WO = :MASTER_WO,' +
        'REMARK = :REMARK,' +
        'UPDATE_USERID = :UPDATE_USERID, ' +
        'UPDATE_TIME = SYSDATE, ' +
        'BURNIN_TIME = :BT, ' +
        'MODEL_NAME = :MODEL_NAME ' +
        'Where WORK_ORDER = :WORK_ORDER ';
      Params.ParamByName('WO_TYPE').AsString := Trim(cmbType.Text);
      Params.ParamByName('WO_RULE').AsString := Trim(cmbRule.Text);
      Params.ParamByName('MODEL_ID').AsString := PartId;
       //Params.ParamByName('VERSION').AsString := Trim(editVersion.Text);
      Params.ParamByName('VERSION').AsString := Trim(combVersion.Text);
      Params.ParamByName('TARGET_QTY').AsString := InttoStr(StrToIntDef(Trim(editQty.Text), 0));
      Params.ParamByName('WO_SCHEDULE_DATE').AsDate := dateScheduledate.Date;
      Params.ParamByName('WO_DUE_DATE').AsDate := dateDuedate.Date;
      Params.ParamByName('ROUTE_ID').AsString := RouteID;
      Params.ParamByName('DEFAULT_PDLINE_ID').AsString := PdLineID;
      Params.ParamByName('START_PROCESS_ID').AsString := InProcessID;
      Params.ParamByName('END_PROCESS_ID').AsString := OutProcessID;
      Params.ParamByName('CUSTOMER_ID').AsString := CustID;
      Params.ParamByName('PO_NO').AsString := Trim(editPO.Text);
      Params.ParamByName('SALES_ORDER').AsString := Trim(editSO.Text);
      Params.ParamByName('MASTER_WO').AsString := Trim(editMasterWO.Text);
      Params.ParamByName('REMARK').AsString := Trim(editRemark.Text);
      Params.ParamByName('UPDATE_USERID').AsString := fWOManager.UpdateUserID;
      Params.ParamByName('WORK_ORDER').AsString := Trim(editWO.Text);
      Params.ParamByName('MODEL_NAME').AsString := Trim(combModelName.Text);
      Params.ParamByName('BT').AsString := Trim(editBurnInTime.Text); //StrToIntDef(Trim(editBurnInTime.Text),0);
      Execute;
      CopyToHistory(Trim(editWO.Text));

       //If cmbPkSpec.Text <> fWOManager.QryData.FieldByName('PKSPEC_NAME').AsString Then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
        CommandText := 'Delete SAJET.G_PACK_SPEC ' +
          'Where WORK_ORDER = :WORK_ORDER ';
        Params.ParamByName('WORK_ORDER').AsString := Trim(editWO.Text);
        Execute;
        SaveWOPackSpecData(PartId);
      end;

      if fWOManager.QryData.FieldByName('WO_STATUS').AsString = '0' then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
        CommandText := 'Update SAJET.G_WO_BASE ' +
          'Set WO_STATUS = ''1'' ' +
          'Where WORK_ORDER = :WORK_ORDER ';
        Params.ParamByName('WORK_ORDER').AsString := Trim(editWO.Text);
        Execute;
      end;

    end;
    Result := True;
  except
    MessageDlg('Database Update Error !!', mtError, [mbOK], 0);
  end;
end;

procedure TfData.sbtnSaveClick(Sender: TObject);
var PartId, RouteID, PdLineID, CustID, InProcessID, OutProcessID: string;
begin
// 檢查工單號碼
  if editWO.Text = '' then
  begin
    MessageDlg('Work Order Error !!', mtError, [mbOK], 0);
    editWO.SetFocus;
    Exit;
  end;

// 檢查工單規則
  if cmbRule.Text = '' then
  begin
    MessageDlg('WO Rule Error !!', mtError, [mbOK], 0);
    Exit;
  end;

// 檢查工單號碼是否重複
  if ModiType = 'New' then
    if not CheckWODup then
      Exit;

// 檢查機種
  if not GetPartID(PartId) then Exit;

// 檢查機種 Version
  if combVersion.ItemIndex = -1 then
  begin
    MessageDlg('Version Empty !!', mtError, [mbOK], 0);
    Exit;
  end;

// 檢查 Route
  if not GetRouteID(RouteId) then Exit;

// 檢查 Production Line
  if not GetPdLineID(PdLineId) then Exit;

// 檢查 In Process
  if not GetProcessID(cmbInProcess.Text, InProcessID) then Exit;

// 檢查 Out Process
  if not GetProcessID(cmbOutProcess.Text, OutProcessID) then Exit;

// 檢查 Customer
  if cmbCustomer.Text <> '' then
  begin
    if not GetCustID(CustID) then Exit;
  end
  else
    CustID := '0';

// 檢查 Target Qty
  if StrToIntDef(editQty.Text, 0) = 0 then
  begin
    MessageDlg('Target Qty Error !!', mtError, [mbOK], 0);
    editQty.SetFocus;
    Exit;
  end;

// 檢查 BurnInTime
  if Trim(editBurnInTime.Text) = '' then editBurnInTime.Text := '0';
  try
    StrToFloat(editBurnInTime.Text);
  except
    MessageDlg('BurnIn Time Error !!', mtError, [mbOK], 0);
    editBurnInTime.SetFocus;
    Exit;
  end;

  if cmbCustomer.Color = $0088FFFF then
    if cmbCustomer.Text = '' then
    begin
      MessageDlg('Customer Empty !!', mtError, [mbOK], 0);
      cmbCustomer.SetFocus;
      Exit;
    end;
  if combModelName.Color = $0088FFFF then
    if combModelName.Text = '' then
    begin
      MessageDlg('Model Name Empty !!', mtError, [mbOK], 0);
      combModelName.SetFocus;
      Exit;
    end;

  if editPO.Color = $0088FFFF then
    if editPO.Text = '' then
    begin
      MessageDlg('PO Number Empty !!', mtError, [mbOK], 0);
      editPO.SetFocus;
      Exit;
    end;

  if editMasterWO.Color = $0088FFFF then
    if editMasterWO.Text = '' then
    begin
      MessageDlg('Master W/O Empty !!', mtError, [mbOK], 0);
      editMasterWO.SetFocus;
      Exit;
    end;

  if editRemark.Color = $0088FFFF then
    if editRemark.Text = '' then
    begin
      MessageDlg('Remark Empty !!', mtError, [mbOK], 0);
      editRemark.SetFocus;
      Exit;
    end;

  if editSO.Color = $0088FFFF then
    if editSO.Text = '' then
    begin
      MessageDlg('Sales Order Empty !!', mtError, [mbOK], 0);
      editSO.SetFocus;
      Exit;
    end;

  if CombVersion.Color = $0088FFFF then
    if (CombVersion.Text = 'N/A') or (CombVersion.Text = '') then
    begin
      MessageDlg('Version Empty !!', mtError, [mbOK], 0);
      CombVersion.SetFocus;
      Exit;
    end;

  if cmbType.Color = $0088FFFF then
    if (cmbType.Text = '') then
    begin
      MessageDlg('W/O Type Empty !!', mtError, [mbOK], 0);
      cmbType.SetFocus;
      Exit;
    end;

  if ModiType = 'New' then
    if not ExecNew(PartId, RouteID, PdLineID, CustID, InProcessID, OutProcessID) then
      Exit;

  if ModiType = 'Modi' then
  begin
    if not ExecModi(PartId, RouteID, PdLineID, CustID, InProcessID, OutProcessID) then
      Exit;
    if cmbRoute.Text <> fWoManager.QryData.FieldByName('Route_Name').AsString then
    begin
      if fWoManager.QryData.FieldByName('Input_Qty').AsInteger <> 0 then
        MessageDlg('This step can cause certain products to be possibly unable to produce.', mtInformation, [mbOK], 0);
      fWoManager.qryTemp.Close;
      fWoManager.qryTemp.Params.Clear;
      fWoManager.qryTemp.Params.CreateParam(ftString, 'WO', ptInput);
      fWoManager.qryTemp.CommandText := 'select serial_number from sajet.g_sn_status where work_order = :wo and rownum =1 ';
      fWoManager.qryTemp.Params.ParamByName('WO').AsString := fWoManager.QryData.Fieldbyname('WORK_ORDER').AsString;
      fWoManager.qryTemp.Open;
      if not fWoManager.qryTemp.IsEmpty then
      begin
        fWoManager.qryTemp.Close;
        fWoManager.qryTemp.Params.Clear;
        fWoManager.qryTemp.Params.CreateParam(ftString, 'rout_id', ptInput);
        fWoManager.qryTemp.Params.CreateParam(ftString, 'WO', ptInput);
        fWoManager.qryTemp.Params.CreateParam(ftString, 'old_route', ptInput);
        fWoManager.qryTemp.CommandText := 'update sajet.g_sn_status '
          + 'set route_id = :rout_id '
          + 'where work_order = :wo and route_id = :old_route';
        fWoManager.qryTemp.Params.ParamByName('rout_id').AsString := RouteID;
        fWoManager.qryTemp.Params.ParamByName('WO').AsString := fWoManager.QryData.Fieldbyname('WORK_ORDER').AsString;
        fWoManager.qryTemp.Params.ParamByName('old_route').AsString := fWoManager.QryData.Fieldbyname('ROUTE_ID').AsString;
        fWoManager.qryTemp.Execute;
      end;
      fWoManager.qryTemp.Close;
    end;
  end;

  if checkWOBom then
    CopyToWoBOM(PartId, combVersion.Text);

  BackupWORule;

  ModalResult := mrOK;

end;

function TfData.BackupWORule: Boolean;
begin
  Result := False;
  with fWOManager.QryTemp do
  begin
    //Delete G_WO_PARAM
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    CommandText := 'Delete SAJET.G_WO_PARAM '
      + 'Where WORK_ORDER = :WORK_ORDER '
      + 'And MODULE_NAME in (select upper(label_name) || '' RULE'' from sajet.sys_label) ';
    Params.ParamByName('WORK_ORDER').AsString := editWO.Text;
    Execute;

    //Insert G_WO_PARAM
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    Params.CreateParam(ftString, 'WORULE', ptInput);
    Params.CreateParam(ftString, 'CODERULE', ptInput);
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    CommandText := 'Insert Into SAJET.G_WO_PARAM '
      + 'Select :WORK_ORDER WORK_ORDER,B.* '
      + 'From SAJET.SYS_MODULE_PARAM A, '
      + 'SAJET.SYS_MODULE_PARAM B, '
      + 'sajet.sys_label c '
      + 'Where A.MODULE_NAME = ''W/O RULE'' '
      + 'and A.FUNCTION_NAME = :WORULE '
      + 'and A.PARAME_NAME = c.label_name || '' Rule'' '
      + 'and A.PARAME_ITEM = B.FUNCTION_NAME '
      + 'and B.MODULE_NAME = upper(c.label_name || '' Rule'') '
      + 'and c.type <> ''U'' ';
    Params.ParamByName('WORK_ORDER').AsString := editWO.Text;
    Params.ParamByName('WORULE').AsString := Trim(cmbRule.Text);
    Execute;
    Close;
  end;
  Result := True;
end;

procedure TfData.cmbRouteChange(Sender: TObject);
begin
  cmbInProcess.Items.Clear;
  cmbOutProcess.Items.Clear;
  if cmbRoute.Items.IndexOf(cmbRoute.Text) < 0 then Exit;
  with fWOManager.QryTemp do
  begin
{     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'WORK_ORDER', ptInput);
     Params.CreateParam(ftString	,'ROUTE_NAME', ptInput);
     CommandText := 'Select C.PROCESS_NAME,B.RESULT,B.SEQ '+
                    'From SAJET.SYS_ROUTE A,'+
                         'SAJET.G_WO_ROUTE B,'+
                         'SAJET.SYS_PROCESS C '+
                    'Where B.WORK_ORDER = :WORK_ORDER and '+
                          'A.ROUTE_NAME = :ROUTE_NAME AND '+
                          'A.ROUTE_ID = B.ROUTE_ID and '+
                          'B.NEXT_PROCESS_ID = C.PROCESS_ID '+
                    'Order By B.SEQ ';
     Params.ParamByName('WORK_ORDER').AsString := editWO.Text;
     Params.ParamByName('ROUTE_NAME').AsString := cmbRoute.Text;
     Open;
     if RecordCount = 0 then
     begin
     }
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'ROUTE_NAME', ptInput);
    CommandText := 'Select C.PROCESS_NAME,B.RESULT,B.SEQ ' +
      'From SAJET.SYS_ROUTE A,' +
      'SAJET.SYS_ROUTE_DETAIL B,' +
      'SAJET.SYS_PROCESS C ' +
      'Where A.ROUTE_NAME = :ROUTE_NAME and ' +
      'B.ENABLED = ''Y'' and ' +
      'A.ROUTE_ID = B.ROUTE_ID  and ' +
      'B.NEXT_PROCESS_ID = C.PROCESS_ID ' +
      'Order By B.SEQ ';
    Params.ParamByName('ROUTE_NAME').AsString := cmbRoute.Text;
    Open;
    while not Eof do
    begin
      if Fieldbyname('RESULT').AsString = '1' then
        Break;
      if cmbInProcess.Items.IndexOf(Fieldbyname('PROCESS_NAME').AsString) < 0 then
      begin
          cmbInProcess.Items.Add(Fieldbyname('PROCESS_NAME').AsString);
          cmbOutProcess.Items.Add(Fieldbyname('PROCESS_NAME').AsString);
      end;
      Next;
    end;

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'ROUTE_NAME', ptInput);
    CommandText := 'Select C.PROCESS_NAME,B.RESULT,B.SEQ ' +
      'From SAJET.SYS_ROUTE A,' +
      'SAJET.SYS_ROUTE_DETAIL B,' +
      'SAJET.SYS_PROCESS C ' +
      'Where A.ROUTE_NAME = :ROUTE_NAME and ' +
      'B.ENABLED = ''Y'' and ' +
      'A.ROUTE_ID = B.ROUTE_ID  and B.Necessary =''Y'' and ' +
      'B.NEXT_PROCESS_ID = C.PROCESS_ID and b.Step=b.Seq  ' +
      'Order By B.SEQ ';
    Params.ParamByName('ROUTE_NAME').AsString := cmbRoute.Text;
    Open;
    if RecordCount <=0 then exit;

    first;
    cmbInProcess.Text :=  Fieldbyname('PROCESS_NAME').AsString;
    while not Eof do
    begin
        if Fieldbyname('RESULT').AsString = '1' then  Break;

        Next;
    end;
    cmbOutProcess.Text :=  Fieldbyname('PROCESS_NAME').AsString;
  end;
end;

procedure TfData.editPartKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) and (editPart.Text <> '') then
  begin
    editPartExit(Self);
  end;
end;

procedure TfData.editPartExit(Sender: TObject);
var sPartId: string;
begin
  sPartId := GetPart;
  GetPartVersion;
  GetDefaultData;
  GetModelName;
  GetPackSpecData;
//  GetWoRule(sPartId);
end;

procedure TfData.FormShow(Sender: TObject);
var i: integer;
begin
  if ModiType = 'New' then
  begin
    dateDueDate.DateTime := now;
    dateScheduleDate.DateTime := now;
  end;
  cmbRuleChange(Self);

  strgridSpec.Cells[0, 0] := 'Code';
  strgridSpec.Cells[1, 0] := 'Box';
  strgridSpec.Cells[2, 0] := 'Carton';
  strgridSpec.Cells[3, 0] := 'Pallet';
end;

procedure TfData.cmbRuleChange(Sender: TObject);
begin
  if cmbRule.Text = '' then
    Exit;

  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'PARAME_NAME', ptInput);
    CommandText := 'Select PARAME_ITEM,PARAME_VALUE ' +
      'From SAJET.SYS_MODULE_PARAM ' +
      'Where MODULE_NAME = :MODULE_NAME and ' +
      'FUNCTION_NAME = :FUNCTION_NAME and ' +
      'PARAME_NAME = :PARAME_NAME ';
    Params.ParamByName('MODULE_NAME').AsString := 'W/O RULE';
    Params.ParamByName('FUNCTION_NAME').AsString := cmbRule.text;
    Params.ParamByName('PARAME_NAME').AsString := 'Necessary Information';
    Open;
    while not Eof do
    begin
      if Fieldbyname('PARAME_ITEM').AsString = 'Customer' then
        if Fieldbyname('PARAME_VALUE').AsString = 'Y' then
          cmbCustomer.Color := $0088FFFF
        else
          cmbCustomer.Color := clWindow;

      if Fieldbyname('PARAME_ITEM').AsString = 'Model Name' then
        if Fieldbyname('PARAME_VALUE').AsString = 'Y' then
          combModelName.Color := $0088FFFF
        else
          combModelName.Color := clWindow;

      if Fieldbyname('PARAME_ITEM').AsString = 'PO Number' then
        if Fieldbyname('PARAME_VALUE').AsString = 'Y' then
          editPO.Color := $0088FFFF
        else
          editPO.Color := clWindow;

      if Fieldbyname('PARAME_ITEM').AsString = 'Master Work Order' then
        if Fieldbyname('PARAME_VALUE').AsString = 'Y' then
          editMasterWO.Color := $0088FFFF
        else
          editMasterWO.Color := clWindow;

      if Fieldbyname('PARAME_ITEM').AsString = 'Remark' then
        if Fieldbyname('PARAME_VALUE').AsString = 'Y' then
          editRemark.Color := $0088FFFF
        else
          editRemark.Color := clWindow;

      if Fieldbyname('PARAME_ITEM').AsString = 'Sales Order' then
        if Fieldbyname('PARAME_VALUE').AsString = 'Y' then
          editSO.Color := $0088FFFF
        else
          editSO.Color := clWindow;

      if Fieldbyname('PARAME_ITEM').AsString = 'Version' then
        if Fieldbyname('PARAME_VALUE').AsString = 'Y' then
          combVersion.Color := $0088FFFF
        else
          combVersion.Color := clWindow;

      if Fieldbyname('PARAME_ITEM').AsString = 'WO Type' then
        if Fieldbyname('PARAME_VALUE').AsString = 'Y' then
          cmbType.Color := $0088FFFF
        else
          cmbType.Color := clWindow;

      Next;
    end;
    Close;
  end;
end;

procedure TfData.sbtnShowBomClick(Sender: TObject);
var sBom, sVer: string;
begin
  if editPart.Text = '' then
    Exit;

  sBom := editPart.Text;
  sVer := combVersion.Text;
  fBom := TfBom.Create(Self);
  with fBom do
  begin
    QryData.RemoteServer := fWOManager.QryData.RemoteServer;
    QryData.ProviderName := 'DspQryData';
    QryTemp.RemoteServer := fWOManager.QryData.RemoteServer;
    QryTemp.ProviderName := 'DspQryTemp1';
//    ShowProcess;
    lablWorkOrder.Caption := editWO.Text;
    GetPartID(gsPartID);
    cmbBom.Text := sBom;
    labVersion.Caption := sVer;
    ShowBom;
    if ModiType = 'New' then
    begin
      editPNFilter.Enabled := False;
      Delete1.Visible := False;
      AddProcess1.Visible := False;
      lablReadOnly.Visible := True;
    end
    else if (fWOManager.QryData.FieldbyName('WO_Status').AsInteger = 3) or (fWOManager.QryData.FieldbyName('WO_Status').AsInteger > 4) then
    begin
      editPNFilter.Enabled := False;
      Delete1.Visible := False;
      AddProcess1.Visible := False;
      lablReadOnly.Visible := True;
    end;
    ShowModal;
    Free;
  end;
end;

function TfData.GetPart: string;
begin
  // Get Max Version
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PN', ptInput);
    CommandText := 'Select part_id ' +
      'From SAJET.SYS_PART ' +
      'Where PART_NO = :PN and rownum = 1';
    Params.ParamByName('PN').AsString := editPart.Text;
    Open;
    Result := FieldByName('part_id').AsString;
    Close;
  end;
end;

procedure TfData.GetPartVersion;
begin

 
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PN', ptInput);
    CommandText := 'Select  nvl(b.version,''N/A'') version ' +
      'From SAJET.G_WO_BASE a,sajet.sys_part b ' +
      'Where a.Model_id(+) =b.part_ID and b.PART_NO = :PN ';
    Params.ParamByName('PN').AsString := editPart.Text;
    Open;
    if RecordCount > 0 then
    begin
      while not Eof do
      begin
        if combVersion.Items.IndexOf(FieldByName('Version').AsString) = -1 then
          combVersion.Items.Add(FieldByname('Version').AsString);
        Next;
      end;
    end;
    Close;
  end;
  // Get Max Version
  {
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PN', ptInput);
    CommandText := 'Select nvl(b.Version,''N/A'') Version ,b.update_time,a.version Ver ' +
      'From SAJET.SYS_PART A, ' +
      'SAJET.SYS_BOM_INFO B ' +
      'Where A.PART_ID = B.PART_ID(+) and ' +
      'A.PART_NO = :PN ' +
      'order by b.update_time desc ';
    Params.ParamByName('PN').AsString := editPart.Text;
    Open;
    combVersion.Clear;
    combVersion.Items.Add(FieldByname('Ver').AsString);
    if RecordCount > 0 then
    begin
      while not Eof do
      begin
        if combVersion.Items.IndexOf(FieldByname('Version').AsString) = -1 then
          combVersion.Items.Add(FieldByname('Version').AsString);
        Next;
      end;
    end;
    Close;
  end;

  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PN', ptInput);
    CommandText := 'Select update_time,nvl(version,''N/A'') version ' +
      'From SAJET.SYS_PART ' +
      'Where PART_NO = :PN ';
    Params.ParamByName('PN').AsString := editPart.Text;
    Open;
    if RecordCount > 0 then
    begin
      while not Eof do
      begin
        if combVersion.Items.IndexOf(FieldByName('Version').AsString) = -1 then
          combVersion.Items.Add(FieldByname('Version').AsString);
        Next;
      end;
    end;
    Close;
  end;}
end;

procedure TfData.sbtnNewClick(Sender: TObject);
var iRow, i: integer;
begin
  with TfFilter.Create(Self) do
  begin
    QryData.RemoteServer := fWOManager.QryData.RemoteServer;
    QryData.ProviderName := fWOManager.QryData.ProviderName;

    with QryData do
    begin
      Close;
      Params.Clear;
      CommandText := 'Select PKSPEC_NAME, BOX_QTY, CARTON_QTY, PALLET_QTY ' +
        'From SAJET.SYS_PKSPEC ' +
        'Order By PKSPEC_NAME';
      Open;
    end;

    if Showmodal = mrOK then
    begin
      // 檢查是否重複
      for i := 1 to strgridSpec.RowCount - 1 do
      begin
        if strgridSpec.Cells[0, i] = QryData.Fieldbyname('PKSPEC_NAME').AsString then
        begin
          MessageDlg('Packing Spec. Duplicate !! ', mtError, [mbCancel], 0);
          Exit;
        end;
      end;

      with strgridSpec do
      begin
        if Cells[0, 1] = '' then
          iRow := 1
        else
          iRow := RowCount;
        Cells[0, iRow] := QryData.Fieldbyname('PKSPEC_NAME').AsString;
        Cells[1, iRow] := QryData.Fieldbyname('BOX_QTY').AsString;
        Cells[2, iRow] := QryData.Fieldbyname('CARTON_QTY').AsString;
        Cells[3, iRow] := QryData.Fieldbyname('PALLET_QTY').AsString;
        RowCount := iRow + 1;
      end;
    end;
    QryData.Close;
    Free;
  end;
end;

procedure TfData.sbtnDeleteClick(Sender: TObject);
var iCol, iRow, i, j: integer;
  tsData: TStrings;
begin
  iRow := strgridSpec.Row;
  tsData := TStringList.Create;
  for i := 1 to strgridSpec.RowCount - 1 do
    for j := 0 to strgridSpec.colCount - 1 do
      tsData.Add(strgridSpec.Cells[j, i]);
  tsData.Delete((iRow - 1) * 4 + 3);
  tsData.Delete((iRow - 1) * 4 + 2);
  tsData.Delete((iRow - 1) * 4 + 1);
  tsData.Delete((iRow - 1) * 4);

  for i := 1 to strgridSpec.RowCount - 1 do
  begin
    strgridSpec.Rows[i].Clear;
    strgridSpec.RowCount := 2;
  end;

  for i := 0 to tsData.Count - 1 do
  begin
    iCol := i mod 4;
    iRow := i div 4 + 1;
    strgridSpec.Cells[iCol, iRow] := tsData.Strings[i];
  end;
  strgridSpec.RowCount := iRow + 1;
  tsData.Free;
end;

procedure TfData.SpeedButton1Click(Sender: TObject);
begin
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PN', ptInput);
    CommandText := 'Select PART_NO, SPEC1, SPEC2, VERSION ' +
      'From SAJET.SYS_PART ' +
      'Where PART_NO Like :PN and Enabled = ''Y'' ' +
      'Order By PART_NO';
    Params.ParamByName('PN').AsString := Trim(editPart.Text) + '%';
    Open;
  end;

  with TfPFilter.Create(Self) do
  begin
    edtPart.Text := Trim(editPart.Text);
    if Showmodal = mrOK then
    begin
      editPart.Text := fWOManager.QryTemp.Fieldbyname('PART_NO').AsString;
      editPart.SetFocus;
      editPartExit(Self);
    end;
    Free;
  end;
  fWOManager.QryTemp.Close;
end;

end.

