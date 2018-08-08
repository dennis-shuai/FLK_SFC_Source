unit uWOManager;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, uData, Db,
  DBClient, MConnect, SConnect, DBCtrls, ObjBrkr, uLog, Menus, uBom;

type
  TfWOManager = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    Label13: TLabel;
    cmbStatus: TComboBox;
    sbtnNew: TSpeedButton;
    sbtnModify: TSpeedButton;
    DBGrid1: TDBGrid;
    Label7: TLabel;
    Label8: TLabel;
    LabTitle1: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label10: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    QryTemp: TClientDataSet;
    QryData: TClientDataSet;
    DataSource1: TDataSource;
    Label22: TLabel;
    cmbWorkType: TComboBox;
    Label23: TLabel;
    LabWOcount: TLabel;
    dbtxtWO: TDBText;
    dbtxtType: TDBText;
    dbtxtPart: TDBText;
    dbtxtVersion: TDBText;
    dbtxtTarget: TDBText;
    dbtxtScheduledata: TDBText;
    dbtxtRoute: TDBText;
    dbtxtPDLine: TDBText;
    dbtxtSProcess: TDBText;
    dbtxtEProcess: TDBText;
    dbtxtCust: TDBText;
    dbtxtPO: TDBText;
    dbtxtMastWO: TDBText;
    dbtxtInQty: TDBText;
    dbtxtOutQty: TDBText;
    dbtxtRemark: TDBText;
    editWO: TEdit;
    Label25: TLabel;
    Image2: TImage;
    Image1: TImage;
    Image3: TImage;
    sbtnLog: TSpeedButton;
    PopupMenu1: TPopupMenu;
    Modify1: TMenuItem;
    ViewLog1: TMenuItem;
    New1: TMenuItem;
    Label26: TLabel;
    dbtxtModelName: TDBText;
    QryTemp2: TClientDataSet;
    Label27: TLabel;
    dbtxtduedata: TDBText;
    Image4: TImage;
    cmbFactory: TComboBox;
    Label28: TLabel;
    dbtxtSO: TDBText;
    Label29: TLabel;
    Label32: TLabel;
    LabStatus: TLabel;
    Label33: TLabel;
    dbtxtBurnInTime: TDBText;
    sbtnStatus: TSpeedButton;
    Image5: TImage;
    sbtnSNList: TSpeedButton;
    Image6: TImage;
    DataSource2: TDataSource;
    QryData1: TClientDataSet;
    SpecGrid: TDBGrid;
    imgRelease: TImage;
    sbtnRelease: TSpeedButton;
    Sproc: TClientDataSet;
    Label2: TLabel;
    editPart: TEdit;
    SpeedButton1: TSpeedButton;
    Label3: TLabel;
    DBText1: TDBText;
    procedure sbtnNewClick(Sender: TObject);
    procedure sbtnModifyClick(Sender: TObject);
    procedure cmbStatusChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure editWOChange(Sender: TObject);
    procedure sbtnLogClick(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure sbtnStatusClick(Sender: TObject);
    procedure sbtnSNListClick(Sender: TObject);
    procedure cmbWorkTypeDropDown(Sender: TObject);
    procedure QryDataAfterScroll(DataSet: TDataSet);
    procedure sbtnReleaseClick(Sender: TObject);
    procedure editPartKeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
    FcID, UserFcID, UpdateUserID, Authoritys, AuthorityRole: string;
    procedure CopyToHistory(RecordID: string);
    procedure SetStatusbyAuthority;
  end;

var
  fWOManager: TfWOManager;

implementation

uses uSNList, uPFilter;

{$R *.DFM}                        

procedure TfWOManager.SetStatusbyAuthority;
var iPrivilege: integer;
begin
  iPrivilege := 0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'W/O Manager';
      Params.ParamByName('FUN').AsString := 'W/O Maintain';
      Execute;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;
  sbtnNew.Enabled := (iPrivilege >= 1);
  New1.Enabled := sbtnNew.Enabled;
  sbtnModify.Enabled := sbtnNew.Enabled;
  Modify1.Enabled := sbtnNew.Enabled;
end;

procedure TfWOManager.sbtnNewClick(Sender: TObject);
begin
  if not QryData.Active then Exit;

  fData := TfData.Create(Self);
  with fData do
  begin
    ModiType := 'New';
    Labtype1.Caption := 'Append Work Order ';
    Labtype2.Caption := 'Append Work Order ';
    LabFactory.Caption := cmbFactory.Text;

    if Showmodal = mrOk then
    begin
      QryData.Close;
      QryData.Open;
    end;
    Free;
  end;

end;

procedure TfWOManager.sbtnModifyClick(Sender: TObject);
begin
  if (not QryData.Active) or (QryData.RecordCount = 0) then Exit;

  fData := TfData.Create(Self);
  with fData do
  begin
    ModiType := 'Modi';
    Labtype1.Caption := 'Work Order Modify ';
    Labtype2.Caption := 'Work Order Modify ';
    LabFactory.Caption := cmbFactory.Text;

    editWO.Text := QryData.Fieldbyname('WORK_ORDER').AsString;
    editPart.Text := QryData.Fieldbyname('PART_NO').AsString;
    editPartExit(Self);
    if QryData.Fieldbyname('VERSION').AsString <> ''  then combVersion.ItemIndex := combVersion.Items.IndexOf(QryData.Fieldbyname('VERSION').AsString);
    if QryData.Fieldbyname('WO_RULE').AsString <> ''  then cmbRule.ItemIndex := cmbRule.Items.Indexof(QryData.Fieldbyname('WO_RULE').AsString);
    if QryData.Fieldbyname('WO_TYPE').AsString <> ''  then cmbType.ItemIndex := cmbType.Items.Indexof(QryData.Fieldbyname('WO_TYPE').AsString);
    if combVersion.ItemIndex =-1 then  combVersion.ItemIndex :=0;
    if (not QryData.FieldByName('Model_Name').IsNull) then
      combModelName.ItemIndex := combModelName.Items.IndexOf(QryData.FieldByName('Model_Name').AsString);
    editQty.Text := QryData.Fieldbyname('TARGET_QTY').AsString;
    if QryData.Fieldbyname('WO_SCHEDULE_DATE').AsString = '' then
      dateScheduledate.Date := Date
    else
      dateScheduledate.Date := QryData.Fieldbyname('WO_SCHEDULE_DATE').AsDateTime;
    if QryData.Fieldbyname('WO_DUE_DATE').AsString = '' then
      dateDuedate.Date := Date
    else
      dateDuedate.Date := QryData.Fieldbyname('WO_DUE_DATE').AsDateTime;
    if QryData.Fieldbyname('ROUTE_NAME').AsString <> '' then
    begin
      cmbRoute.ItemIndex := cmbRoute.Items.Indexof(QryData.Fieldbyname('ROUTE_NAME').AsString);
      cmbRouteChange(cmbRoute);
      cmbInProcess.ItemIndex := cmbInProcess.Items.Indexof(QryData.Fieldbyname('START_PROCESS').AsString);
      cmbOutProcess.ItemIndex := cmbOutProcess.Items.Indexof(QryData.Fieldbyname('END_PROCESS').AsString);
    end else begin

       cmbRouteChange(cmbRoute);

    end;
{    qryTemp.Close;
    qryTemp.Params.Clear;
    qryTemp.Params.CreateParam(ftString	,'WO', ptInput);
    qryTemp.CommandText := 'select serial_number from sajet.g_sn_status where work_order = :wo and rownum =1 ';
    qryTemp.Params.ParamByName('WO').AsString := QryData.Fieldbyname('WORK_ORDER').AsString;
    qryTemp.Open;
    if not qryTemp.IsEmpty then
      cmbRoute.Enabled := False;
    qryTemp.Close;
    cmbInProcess.Enabled := cmbRoute.Enabled;
    cmbOutProcess.Enabled := cmbRoute.Enabled; }
    cmbLine.ItemIndex := cmbLine.Items.Indexof(QryData.Fieldbyname('PDLINE_NAME').AsString);
    cmbCustomer.ItemIndex := cmbCustomer.Items.Indexof(QryData.Fieldbyname('CUSTOMER_CODE').AsString + ' ' + QryData.Fieldbyname('CUSTOMER_NAME').AsString);
    editPO.Text := QryData.Fieldbyname('PO_NO').AsString;
    editSO.Text := QryData.Fieldbyname('SALES_ORDER').AsString;
    editMasterWO.Text := QryData.Fieldbyname('MASTER_WO').AsString;
    editRemark.Text := QryData.Fieldbyname('REMARK').AsString;
    if QryData.Fieldbyname('BURNIN_TIME').AsString <> '' then
      editBurnInTime.Text := QryData.Fieldbyname('BURNIN_TIME').AsString;

    editWO.Enabled := False;
    //GetPackSpecName;
    if QryData1.Fieldbyname('PKSPEC_NAME').AsString <> '' then
    begin
      GetWOPackSpecData;
    end
    else
      GetPackSpecData;

{    if QryData.FieldbyName('WO_Status').AsInteger = 4 then begin
       cmbRoute.Enabled := True;
       cmbInProcess.Enabled := True;
       cmbOutProcess.Enabled := True;
    end else}if QryData.FieldbyName('WO_Status').AsInteger >= 3 then
    begin
      editPart.Enabled := False;
      cmbRoute.Enabled := False;
      editQty.Enabled := False;
      cmbInProcess.Enabled := False;
      cmbOutProcess.Enabled := False;
      combVersion.Enabled := False;
    end;

    if Showmodal = mrOk then
    begin
      QryData.Close;
      QryData.Open;
      QryData.Locate('WORK_ORDER', editWO.Text, []);
    end;
    Free;
  end;

end;

procedure TfWOManager.cmbStatusChange(Sender: TObject);
  procedure CheckRelease;
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      CommandText := 'Select FUNCTION '
        + 'From SAJET.SYS_EMP_PRIVILEGE '
        + 'Where EMP_ID = :EMP_ID '
        + 'and PROGRAM = :PRG '
        + 'and FUNCTION = ''W/O Release'' ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'W/O Manager';
      Open;
      sbtnRelease.Visible := not (QryTemp.IsEmpty);
      if not sbtnRelease.Visible then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'EMP_ID', ptInput);
        Params.CreateParam(ftString, 'PRG', ptInput);
        CommandText := 'Select FUNCTION '
          + 'From SAJET.SYS_ROLE_PRIVILEGE A, '
          + 'SAJET.SYS_ROLE_EMP B '
          + 'Where A.ROLE_ID = B.ROLE_ID '
          + 'and EMP_ID = :EMP_ID '
          + 'and PROGRAM = :PRG '
          + 'and FUNCTION = ''W/O Release'' ';
        Params.ParamByName('EMP_ID').AsString := UpdateUserID;
        Params.ParamByName('PRG').AsString := 'W/O Manager';
        Open;
        sbtnRelease.Visible := not (QryTemp.IsEmpty);
      end;
    end;
  end;
begin
  editPart.Text := Trim(editPart.Text);
  sbtnRelease.Visible := False;
  if cmbStatus.Text = 'Prepare' then
    CheckRelease;
  imgRelease.Visible := sbtnRelease.Visible;
  with QryData do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select A.WORK_ORDER,' +
      'A.WO_TYPE,' +
      'A.WO_RULE,' +
      'A.VERSION,' +
      'A.TARGET_QTY,' +
      'A.WO_CREATE_DATE,' +
      'A.WO_SCHEDULE_DATE,' +
      'A.WO_DUE_DATE,' +
      'A.WO_START_DATE,' +
      'A.WO_CLOSE_DATE,' +
      'A.INPUT_QTY,' +
      'A.OUTPUT_QTY,' +
      'A.WORK_FLAG,' +
      'A.WO_STATUS,' +
      'A.PO_NO,' +
      'A.MASTER_WO,' +
      'A.REMARK,' +
      'A.MODEL_NAME, ' +
      'B.PART_NO,' +
      'C.ROUTE_NAME,' +
      'D.PDLINE_NAME,' +
      'E.CUSTOMER_CODE,' +
      'E.CUSTOMER_NAME,' +
      'F.PROCESS_NAME START_PROCESS,' +
      'G.PROCESS_NAME END_PROCESS, ' +
      'A.ROUTE_ID, ' +
                           // 'H.CARTON_CAPACITY, '+
                           // 'H.PALLET_CAPACITY, '+
    'A.SALES_ORDER, ' +
      'A.BURNIN_TIME ' +
      'From SAJET.G_WO_BASE A,' +
      'SAJET.SYS_PART B,' +
      'SAJET.SYS_ROUTE C,' +
      'SAJET.SYS_PDLINE D,' +
      'SAJET.SYS_CUSTOMER E,' +
      'SAJET.SYS_PROCESS F,' +
      'SAJET.SYS_PROCESS G ' +
                           //'SAJET.G_PACK_SPEC H '+
    'Where A.MODEL_ID=B.PART_ID(+) and ' +
      'A.ROUTE_ID=C.ROUTE_ID(+) and ' +
      'A.DEFAULT_PDLINE_ID=D.PDLINE_ID(+) and ' +
      'A.CUSTOMER_ID=E.CUSTOMER_ID(+) and ' +
      'A.START_PROCESS_ID=F.PROCESS_ID(+) and ' +
      'A.END_PROCESS_ID=G.PROCESS_ID(+) and ' +
                            //'A.WORK_ORDER = H.WORK_ORDER(+) and '+
    'A.FACTORY_ID = :FCID ';
    Params.CreateParam(ftString, 'FCID', ptInput);
    if cmbStatus.ItemIndex <= 7 then
    begin
      Params.CreateParam(ftString, 'WOSTATUS', ptInput);
      CommandText := CommandText + ' and WO_STATUS = :WOSTATUS ';
    end;

    if cmbWorkType.ItemIndex > 0 then
    begin
      Params.CreateParam(ftString, 'WO_TYPE', ptInput);
      CommandText := CommandText + ' and WO_TYPE = :WO_TYPE ';
    end;

    if editPart.Text <> '' then
    begin
      Params.CreateParam(ftString, 'PART_NO', ptInput);
      CommandText := CommandText + ' and B.PART_NO = :PART_NO ';
    end;
    CommandText := CommandText + ' Order by WORK_ORDER ';

    if cmbStatus.ItemIndex <= 6 then
      Params.ParamByName('WOSTATUS').AsString := InttoStr(cmbStatus.ItemIndex)
    else if cmbStatus.ItemIndex = 7 then
      Params.ParamByName('WOStatus').AsString := InttoStr(cmbStatus.ItemIndex+2);
    if cmbWorkType.ItemIndex > 0 then
      Params.ParamByName('WO_TYPE').AsString := cmbWorkType.Text;
    if editPart.Text <> '' then
      Params.ParamByName('PART_NO').AsString := editPart.Text;

    Params.ParamByName('FCID').AsString := FcID;
    Open;
    LabWOcount.Caption :=InttoStr(RecordCount);
  end;
end;

procedure TfWOManager.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
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

  cmbStatus.ItemIndex := 0;
  cmbStatusChange(Self);
  if UpdateUserID <> '0' then
    SetStatusbyAuthority;
end;

procedure TfWOManager.editWOChange(Sender: TObject);
begin
  if not QryData.Active then
    Exit;
   QryData.Locate('WORK_ORDER', Trim(editWO.Text), [loCaseInsensitive, loPartialKey]);
end;

procedure TfWOManager.sbtnLogClick(Sender: TObject);
begin
  if QryData.Eof then
    Exit;
  with TfLog.Create(Self) do
  begin
    QryData.RemoteServer := Self.QryData.RemoteServer;
    ShowWOLog(Self.QryData.Fieldbyname('WORK_ORDER').AsString);
    ShowModal;
    Free;
  end;
end;

procedure TfWOManager.cmbFactoryChange(Sender: TObject);
begin
  FcID := '';
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
    Close;
  end;
  cmbStatusChange(Self); //ShowData;
end;

procedure TfWOManager.DataSource1DataChange(Sender: TObject;
  Field: TField);
begin
  if QryData.Eof then
    Exit;
  case QryData.Fieldbyname('WO_STATUS').AsInteger of
    0: LabStatus.Caption := 'Initial';
    1: LabStatus.Caption := 'Prepare';
    2: LabStatus.Caption := 'Release';
    3: LabStatus.Caption := 'Work In Process';
    4: LabStatus.Caption := 'Hold';
    5: LabStatus.Caption := 'Cancel';
    6: LabStatus.Caption := 'Complete';
    9: LabStatus.Caption := 'Complete-No Charge';
  end;
end;

procedure TfWOManager.sbtnStatusClick(Sender: TObject);
begin
  if QryData.Eof then
    Exit;
  with TfSNList.Create(Self) do
  begin
    QryData.RemoteServer := Self.QryData.RemoteServer;
    LabType1.Caption := 'Status History';
    LabType2.Caption := LabType1.Caption;
    ShowWOLog(Self.QryData.Fieldbyname('WORK_ORDER').AsString);
    ShowModal;
    Free;
  end;
end;

procedure TfWOManager.sbtnSNListClick(Sender: TObject);
begin
  if QryData.Eof then Exit;
  with TfSNList.Create(Self) do
  begin
    QryData.RemoteServer := Self.QryData.RemoteServer;
    LabType1.Caption := 'SN List';
    LabType2.Caption := LabType1.Caption;
    ShowSNLog(Self.QryData.Fieldbyname('WORK_ORDER').AsString);
    ShowModal;
    Free;
  end;
end;

procedure TfWOManager.cmbWorkTypeDropDown(Sender: TObject);
begin
  cmbWorkType.Items.Clear;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select WO_TYPE ' +
      'From SAJET.G_WO_BASE ' +
      'where WO_TYPE is not null ' +
      'GROUP BY WO_TYPE ';
    Open;
    cmbWorkType.Items.Add('All');
    while not Eof do
    begin
      cmbWorkType.Items.Add(Fieldbyname('WO_TYPE').AsString);
      Next;
    end;
    Close;
  end;
end;

procedure TfWOManager.QryDataAfterScroll(DataSet: TDataSet);
begin
  with QryData1 do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WO', ptInput);
    CommandText := 'Select PKSPEC_NAME,BOX_CAPACITY,CARTON_CAPACITY,PALLET_CAPACITY ' +
      'from SAJET.G_PACK_SPEC ' +
      'where WORK_ORDER =:WO ' +
      'Order By BOX_CAPACITY desc,CARTON_CAPACITY desc,PALLET_CAPACITY desc ';
    Params.ParamByName('WO').AsString := QryData.FieldByName('WORK_ORDER').asstring;
    open;
  end;
end;

procedure TfWOManager.sbtnReleaseClick(Sender: TObject);
begin
  if not QryData.Active then Exit;
  if QryData.IsEmpty then Exit;
  if MessageDlg('Change Work Order Status to Release?',
    mtConfirmation, [mbOK, mbCancel], 0) <> mrOK then
    Exit;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WO_STATUS', ptInput);
    Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    CommandText := 'Update SAJET.G_WO_BASE ' +
      'Set WO_STATUS = :WO_STATUS,' +
      'UPDATE_USERID = :UPDATE_USERID,' +
      'UPDATE_TIME = SYSDATE ' +
      'Where WORK_ORDER = :WORK_ORDER ';
    Params.ParamByName('WO_STATUS').AsString := '2';
    Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
    Params.ParamByName('WORK_ORDER').AsString := QryData.Fieldbyname('WORK_ORDER').AsString;
    Execute;

    // 紀錄狀態變更
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'STA', ptInput);
    Params.CreateParam(ftString, 'EMP', ptInput);
    Params.CreateParam(ftString, 'WO', ptInput);
    Params.CreateParam(ftString, 'MEMO', ptInput);
    CommandText := 'Insert into SAJET.G_WO_STATUS (Work_Order,WO_Status,Memo,update_userid) ' +
      'values (:WO,:STA,:MEMO,:EMP)';
    Params.ParamByName('STA').AsString := '2';
    Params.ParamByName('EMP').AsString := UpdateUserID;
    Params.ParamByName('WO').AsString := QryData.Fieldbyname('WORK_ORDER').AsString;
    Execute;
    Close;
  end;
  CopyToHistory(QryData.Fieldbyname('WORK_ORDER').AsString);
  MessageDlg('Change Work Order Status OK!!', mtCustom, [mbOK], 0);
  cmbStatusChange(Self);
end;

procedure TfWOManager.CopyToHistory(RecordID: string);
begin
  with QryTemp do
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

procedure TfWOManager.editPartKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    cmbStatusChange(Self);
  end;
end;

procedure TfWOManager.SpeedButton1Click(Sender: TObject);
var sKey: Char;
begin
  with QryTemp do
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
    editPart.Text := Trim(editPart.Text);
    if Showmodal = mrOK then
    begin
      editPart.Text := QryTemp.Fieldbyname('PART_NO').AsString;
      sKey := #13;
      editPart.OnKeyPress(self, sKey);
    end;
    Free;
  end;
  QryTemp.Close;
end;

end.

