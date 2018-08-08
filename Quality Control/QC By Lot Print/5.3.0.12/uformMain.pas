unit uformMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect, inifiles,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, Menus;

type
  TQCByLot = record
    bWOInput: Boolean;
    bGetSampleRange: Boolean;
    sWorkOrder: string;
    sPartNo: string;
    sSampleType: string;
    ssamplingTypeID: string;
    iLotSize: Integer;
  end;
  TformMain = class(TForm)
    ImageAll: TImage;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    Label15: TLabel;
    Label16: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label9: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    lablSamplingType: TLabel;
    lablSampleSize: TLabel;
    lablCriticalRej: TLabel;
    lablMajorRej: TLabel;
    lablMinorRej: TLabel;
    ImageSample: TImage;
    PMenuDefect: TPopupMenu;
    Delete1: TMenuItem;
    Image1: TImage;
    Image3: TImage;
    sbtnByPass: TSpeedButton;
    Label18: TLabel;
    seditPassQty: TSpinEdit;
    Label25: TLabel;
    seditFailQty: TSpinEdit;
    Bevel5: TBevel;
    editDefectCode: TEdit;
    combDefectLevel: TComboBox;
    Label23: TLabel;
    editDefectMemo: TEdit;
    seditDefectQty: TSpinEdit;
    lvDefect: TListView;
    Label26: TLabel;
    speditInspLotQty: TSpinEdit;
    Image4: TImage;
    ImageReject: TImage;
    ImagePass: TImage;
    sbtnSorting: TSpeedButton;
    sbtnPass: TSpeedButton;
    sbtnReject: TSpeedButton;
    sbtnWaive: TSpeedButton;
    Image7: TImage;
    sbtnHold: TSpeedButton;
    Label27: TLabel;
    seditCheckQty: TSpinEdit;
    Image8: TImage;
    sbtnPartialWaive: TSpeedButton;
    Bevel3: TBevel;
    Label5: TLabel;
    lablPartNo: TLabel;
    Label7: TLabel;
    lablLotSize: TLabel;
    sbtnSamplePlan: TSpeedButton;
    Label30: TLabel;
    lablLotPartDesc: TLabel;
    lablDefectDesc: TLabel;
    lablDefectDesc2: TLabel;
    Bevel4: TBevel;
    editWorkOrder: TEdit;
    Label1: TLabel;
    Label6: TLabel;
    editLotNo: TEdit;
    sbtnNewLot: TSpeedButton;
    Label8: TLabel;
    lablReceivedQty: TLabel;
    Label35: TLabel;
    editStage: TEdit;
    Label34: TLabel;
    editProcessName: TEdit;
    Label36: TLabel;
    editTerminal: TEdit;
    Label33: TLabel;
    combLine: TComboBox;
    sbtnFilter: TSpeedButton;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    Label4: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    combProductLine: TComboBox;
    combProductLineID: TComboBox;
    lablMsg: TLabel;
    Label14: TLabel;
    labID: TLabel;
    lbl1: TLabel;
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnPassClick(Sender: TObject);
    procedure editDefectCodeKeyPress(Sender: TObject; var Key: Char);
    procedure seditDefectQtyKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure seditPassQtyKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure sbtnSamplePlanClick(Sender: TObject);
    procedure editDefectMemoKeyPress(Sender: TObject; var Key: Char);
    procedure Delete1Click(Sender: TObject);
    procedure seditFailQtyKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure speditInspLotQtyKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure seditCheckQtyKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure editWorkOrderChange(Sender: TObject);
    procedure editWorkOrderKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnNewLotClick(Sender: TObject);
    procedure editLotNoKeyPress(Sender: TObject; var Key: Char);
    procedure speditInspLotQtyChange(Sender: TObject);
    procedure sbtnFilterClick(Sender: TObject);
  private
    procedure clearData;
    function GetWorkOrder(sWorkOrder: string): boolean;
    function GetDefaultSamplingPlan(sPartNo: string): Boolean;
    function IsDefect: Boolean;
    function checkInput: Boolean;
    function getSamplingPlanRange(sSamplingType: string; iLotSize: integer): Boolean;
  public
    UpdateUserID: string;
    TerminalID,sProcessId: string;
    QC: TQCByLot;
    procedure SetStatusbyAuthority;
    function GetTerminalID: Boolean;
    function GetReceivedQty(sWorkOrder: string): Integer;
    procedure GetLineName;
  end;

var
  formMain: TformMain;

implementation

{$R *.dfm}

uses uAQL, uformLotMemo, uFilter, unitDataBase, uDllform, DllInit;

function TformMain.checkInput: Boolean;
begin
  Result := False;
  if editDefectCode.Text = '' then
  begin
    MessageDlg('Please input Defect Code !!', mtError, [mbOK], 0);
    editDefectCode.SetFocus;
    Exit;
  end
  else if not IsDefect then
  begin
    MessageDlg('No such Defect Code !!', mtError, [mbOK], 0);
    editDefectCode.SelectAll;
    editDefectCode.SetFocus;
    Exit;
  end
  else if seditDefectQty.Value <= 0 then
  begin
    MessageDlg('Defect Qty'' can''t be 0 !!', mtError, [mbOK], 0);
    seditDefectQty.SetFocus;
    seditDefectQty.SelectAll;
    Exit;
  end;
  Result := True;
end;

function TformMain.IsDefect: Boolean;
var sSQL: string;
begin
  Result := False;
  sSQL := 'SELECT DEFECT_CODE, DEFECT_DESC, DEFECT_LEVEL, DEFECT_DESC2, '
    + '       DECODE(DEFECT_LEVEL,''0'',''CRITICAL'',''1'',''MAJOR'',''2'',''MINOR'') "LEVEL" '
    + '  FROM SAJET.SYS_DEFECT '
    + ' WHERE DEFECT_CODE = ''' + editDefectCode.Text + ''' ';
  with QryTemp do
  begin
    try
      Close;
      Params.Clear;
      CommandText := sSQL;
      Open;
      if Eof then Exit;

      lablDefectDesc.Caption := FieldByName('Defect_Desc').AsString;
      lablDefectDesc2.Caption := FieldByName('Defect_Desc2').AsString;
      if combDefectLevel.ItemIndex = -1 then
        combDefectLevel.ItemIndex := FieldByName('DEFECT_LEVEL').AsInteger;
    finally
      Close;
    end;
  end;
  Result := True;
end;



function TformMain.GetWorkOrder(sWorkOrder: string): Boolean;
var sSQL: string;
begin
  Result := false;
  lablPartNo.Caption := '';
  lablLotSize.Caption := '';
  lablSamplingType.Caption := 'N/A';
  lablLotPartDesc.Caption := '';
  lablReceivedQty.Caption := '0';
  lablLotPartDesc.Hint := lablLotPartDesc.Caption;
  with QryTemp do
  begin
    try
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      sSQL := 'SELECT A.WORK_ORDER,A.TARGET_QTY,A.MODEL_ID '
        + '      ,DECODE(A.WO_STATUS,''0'',''Initial'',''1'',''Prepare'',''2'',''Release'',A.WO_STATUS) WO_STATUS_DESC,WO_STATUS '
        + '      , B.PART_NO , B.SPEC1 '
        + '   FROM SAJET.G_WO_BASE A '
        + '  LEFT JOIN SAJET.SYS_PART B ON A.MODEL_ID = B.PART_ID '
        + '  WHERE A.WORK_ORDER = :WORK_ORDER '
        + '  AND ROWNUM = 1';
      commandtext := sSQL;
      Params.ParamByName('WORK_ORDER').AsString := sWorkOrder;
      open;
      if eof then
      begin
        Messagedlg('Work Order : ' + sWorkOrder + ' Error!', mtError, [mbOK], 0);
        exit;
      end;
      if FieldByName('WO_STATUS').AsString < '2' then
      begin
        Messagedlg('Work Order : ' + sWorkOrder + ' is ' + FieldbyName('WO_STATUS_DESC').AsString + ' ! ', mtError, [mbOK], 0);
        exit;
      end;

      if not eof then
      begin
        lablPartNo.Caption := FieldByName('PART_NO').AsString;
        lablLotPartDesc.Caption := FieldByName('SPEC1').AsString;
        lablLotPartDesc.Hint := lablLotPartDesc.Caption;
        lablLotSize.Caption := FieldByName('TARGET_QTY').AsString;
        QC.sWorkOrder := FieldByName('WORK_ORDER').AsString;
        QC.sPartNO := FieldByName('PART_NO').AsString;
        QC.bWOInput := True;
        result := True;
      end;
    finally
      Close;
    end;
  end;
end;

procedure TformMain.clearData;
begin
   //combLotNo.Clear;
  lablPartNo.Caption := '';
  lablLotPartDesc.Caption := '';
  lablLotSize.Caption := '0';
  lablReceivedQty.Caption := '0';

  lablLotPartDesc.Hint := lablLotPartDesc.Caption;

  lablSamplingType.Caption := 'N/A';
  lablSampleSize.Caption := '';
  lablCriticalRej.Caption := '';
  lablMajorRej.Caption := '';
  lablMinorRej.Caption := '';

   //editInput.Clear;
  speditInspLotQty.value := 0;
  seditCheckQty.Value := 0;
  seditPassQty.Value := 0;
  seditFailQty.Value := 0;
  editDefectCode.Text := '';
  lablDefectDesc.Caption := '';
  lablDefectDesc2.Caption := '';
  editDefectMemo.Text := '';
  seditDefectQty.Text := '0';
  combDefectLevel.ItemIndex := -1;
  QC.bGetSampleRange := False;

end;


procedure TformMain.SetStatusbyAuthority;
var iPrivilege: integer;
begin
  // Read Only,Allow To Change,Full Control
  iPrivilege := 0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Quality Control';
      Params.ParamByName('FUN').AsString := 'QC By Lot-Print';
      Execute;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;
  sbtnPass.Enabled := (iPrivilege >= 3);
  sbtnHold.Enabled := sbtnPass.Enabled;
  sbtnWaive.Enabled := sbtnPass.Enabled;
  sbtnReject.Enabled := sbtnPass.Enabled;
  sbtnSorting.Enabled := sbtnPass.Enabled;
  sbtnByPass.Enabled := sbtnPass.Enabled;
  sbtnPartialWaive.Enabled := sbtnPass.Enabled;
end;

procedure TformMain.Image2Click(Sender: TObject);
begin
  Close;
end;

procedure TformMain.FormShow(Sender: TObject);
begin
 { if UpdateUserID <> '0' then
    SetStatusbyAuthority; }
  if not GetTerminalID then
  begin
    sbtnPass.Visible := false;
    sbtnReject.Visible := False;
    ImagePass.Visible := False;
    ImageReject.Visible := False;
  end;
  GetLineName;
  combProductLine.ItemIndex := combProductLine.Items.IndexOf(combLine.Text);
  combProductLineID.ItemIndex := combProductLine.ItemIndex;

  editWorkOrder.Setfocus;
  ClearData;
end;

procedure TformMain.GetLineName;
begin
  combProductLine.Clear;
  combProductLineID.Clear;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select PDLINE_ID,PDLINE_NAME FROM SAJET.SYS_PDLINE '
      + ' WHERE ENABLED=''Y'' '
      + ' ORDER BY PDLINE_NAME ';
    Open;
    while not eof do
    begin
      combProductLineID.Items.Add(FieldByName('PDLINE_ID').AsString);
      combProductLine.Items.Add(FieldByName('PDLINE_NAME').AsString);
      Next;
    end;
    Close;
  end;
end;

procedure TformMain.sbtnPassClick(Sender: TObject);
var iDefectQty, I, iStatus, iTotal, iSortingQty: integer;
  sHint, sInspWorkHours, sLotNoMemo, sDefectData, sMaterial, sPrintData: string;
  InputKey: Char;
begin
  InputKey := #13;
  if not QC.bWOInput then
  begin
    if trim(editWorkOrder.Text) = '' then exit;
    editWorkOrderKeyPress(self, InputKey);
    if not QC.bWoInput then exit;
  end;
  editLotNo.Text := Trim(editLotNo.Text);
  if editLotNo.Text = '' then
  begin
    MessageDlg('Please Input "QC Lot No" !', mtError, [mbOK], 0);
    editLotNo.SetFocus;
    exit;
  end;
   //檢查是否有定義抽驗計畫
  if lablSamplingType.Caption = 'N/A' then
  begin
    MessageDlg('Sampling Plan Type Error!' + #10#13
      + 'Please Change Sampling Plan !', mtError, [mbOK], 0);
    Exit;
  end;

  QC.iLotSize := speditInspLotQty.Value;
  if QC.iLotSize <= 0 then
  begin
    MessageDlg('Lot Size Can''t Equal to "0" !', mtError, [mbOK], 0);
    speditInspLotQty.Setfocus;
    speditInspLotQty.SelectAll;
    exit;
  end;
  if not QC.bGetSampleRange then
  begin
    if not getSamplingPlanRange(QC.sSampleType, QC.iLotSize) then
    begin
      MessageDlg('Sampling Plan Type : ' + QC.sSampleType + #10#13
        + 'Lot Size Range : ' + IntToStr(QC.iLotSize) + #10#13
        + 'Not Define Sample Size !', mtwarning, [mbOK], 0);
      exit;
    end;
  end;


   //檢驗數不能大於 收到數
  if seditCheckQty.Value > speditInspLotQty.value then
  begin
    MessageDlg('Check Qty More than Lot Size !!', mtError, [mbOK], 0);
    seditCheckQty.SetFocus;
    seditCheckQty.SelectAll;
    Exit;
  end;
   //fail 數不能大於檢驗數
  if seditFailQty.Value > seditCheckQty.value then
  begin
    MessageDlg('Fail Qty More than Check Qty !!', mtError, [mbOK], 0);
    seditFailQty.SetFocus;
    seditFailQty.SelectAll;
    Exit;
  end;

   //檢驗良品數自動計算(檢驗總數扣掉不良品數)
  seditPassQty.Value := seditCheckQty.value - seditFailQty.value;



  if (seditFailQty.Value > 0) then
  begin
    if (lvDefect.Items.Count = 0) then
    begin
      MessageDlg('Fail Qty > 0. But Not Found Defect Data !!', mtError, [mbOK], 0);
      Exit;
    end;
    iDefectQty := 0;
    for i := 0 to lvDefect.Items.Count - 1 do
    begin
      iDefectQty := iDefectQty + StrToIntDef(LvDefect.Items[i].SubItems[1], 0);
    end;
    if iDefectQty < seditFailQty.Value then
    begin
      MessageDlg('Total Defect Qty < Fail Qty !!', mtError, [mbOK], 0);
      Exit;
    end;
  end;

  if (lvDefect.Items.Count > 0) and (seditFailQty.Value <= 0) then
  begin
    MessageDlg('Have Defect Data but Fail Qty = 0.', mtError, [mbOK], 0);
    Exit;
  end;

   //免驗和判退時,不用檢查抽驗數是否己達抽驗計畫定義的sample size
  if (Sender = sbtnPass) then // or (Sender = sbtnWaive) or (Sender = sbtnPartialWaive) or (Sender = sbtnSorting)then
  begin
    if StrToIntDef(lablSampleSize.Caption, 0) = 0 then
    begin
      MessageDlg('Sampling Plan Type : ' + lablSamplingType.Caption + #10#13
        + 'Sample Size IS "0" !!', mtWarning, [mbOK], 0);
      Exit;
    end;
     //檢查總數是否超過LOT SIZE
    iTotal := StrToInt(lablReceivedQty.Caption) + speditInspLotQty.value;
    if iTotal > StrToInt(lablLotSize.Caption) then
    begin
      MessageDlg('Received Qty : ' + lablReceivedQty.Caption + ' + Lot Size : ' + speditInspLotQty.Text + #10#13
        + 'More than Target Qty : ' + lablLotSize.Caption, mtError, [mbOK], 0);
      Exit;
    end;
     //如果此次的收到數量大於等於樣本數,則必須強迫檢驗數要大於等於樣本數
    if speditInspLotQty.Value >= StrToInt(lablSampleSize.Caption) then
    begin
      if seditCheckQty.Value < StrToInt(lablSampleSize.Caption) then
      begin
        MessageDlg('Check Qty Must More Than or Equal to  Sample Size !!', mtError, [mbOK], 0);
        seditCheckQty.SetFocus;
        seditCheckQty.SelectAll;
        Exit;
      end;
    end
    else
    begin
       //當此批當次收到的數量小於樣本數時,則強迫必須全檢
      if seditCheckQty.Value <> speditInspLotQty.Value then
      begin
        MessageDlg('Lot Size < Sample Size !' + #10#13
          + 'Check Qty Must Equal to Lot Size !!', mtError, [mbOK], 0);
        seditCheckQty.SetFocus;
        seditCheckQty.SelectAll;
        Exit;
      end;
    end;
  end;
  combProductLineID.ItemIndex := combProductLine.ItemIndex;

    //利用BUTTON的TAG屬性讀取判定的STATUS
  iStatus := (Sender as TSpeedButton).Tag;
   //0 : pass ,1 : reject , 2 : Waive, 3 : Sorting, 4 : By Pass , 5 : Hold , 6 : Partial Waive

  if Sender = sbtnPass then
  begin
    sHint := 'PASS';
     {
     if StrToIntDef(lablFailQ.Caption,0) > 0 then
     begin
        MessageDlg('Fail Qty  > "0" ,Can''t PASS !!',mtError,[mbOK],0);
        Exit;
     end;
     }
  end
  else if Sender = sbtnReject then
  begin
    sHint := 'REJECT';
    if seditFailQty.Value = 0 then
    begin
      MessageDlg('Fail Qty = 0. Can''t ' + sHint + ' !!', mtError, [mbOK], 0);
      Exit;
    end;
  end
  else if Sender = sbtnWaive then
  begin
    sHint := 'WAIVE';
  end
  else if Sender = sbtnSorting then
  begin
    sHint := 'SORTING';
  end
  else if Sender = sbtnByPass then
  begin
    sHint := 'BY PASS';
  end
  else if Sender = sbtnHold then
  begin
    sHint := 'HOLD';
  end
  else if Sender = sbtnPartialWaive then
  begin
    sHint := 'Partial WAIVE';
  end;

  if MessageDlg(sHint + ' this lot : ' + editLotNo.Text + ' ?', mtConfirmation, [mbYes, mbNo], 0) <> mryes then Exit;

  formLotMemo := TformLotMemo.Create(self);

  try
    formLotMemo.lablWorkOrder.Caption := QC.sWorkOrder;
    formLotMemo.lablLotNO.Caption := editLotNo.Text;
    formLotMemo.lablResult.Caption := sHint;
    formLotMemo.lablLotSize.Caption := speditInspLotQty.Text;
    formLotMemo.lablPassQty.Caption := seditPassQty.Text;
    formLotMemo.lablFailQty.Caption := seditFailQty.Text;
    formLotMemo.editReceiveQty.Text := speditInspLotQty.Text;
    formLotMemo.lablCheckQty.Caption := IntToStr(StrToInt(formLotMemo.lablPassQty.Caption) + StrToInt(formLotMemo.lablFailQty.Caption));
    formLotMemo.editReceiveQty.Enabled := False;
    if (sHint = 'SORTING') then
      formLotMemo.editInspWorkHours.Color := clYellow;
    if sHint = 'REJECT' then
      formLotMemo.lablAcceptQty.Caption := 'Reject Qty';
    if (sHint = 'SORTING') or (sHint = 'Partial WAIVE') then
    begin
      formLotMemo.editReceiveQty.Enabled := True;
      formLotMemo.editReceiveQty.Color := clYellow;
      formLotMemo.editReceiveQty.Text := IntToStr(StrToInt(formLotMemo.lablLotSize.Caption) - StrToInt(formLotMemo.lablFailQty.Caption));
    end;
    if formLotMemo.showmodal <> mrOK then exit;
    sInspWorkHours := formLotMemo.editInspWorkHours.Text;
    sLotNoMemo := formLotMemo.editLotMemo.Text;

    iSortingQty := StrtoInt(formLotMemo.editReceiveQty.Text);

  finally
    formLotMemo.free;
  end;

  sDefectData := '';
  for i := 0 to lvDefect.Items.Count - 1 do
  begin
    sDefectData := sDefectData + lvDefect.Items[i].Caption + '@' //code
      + LvDefect.Items[i].SubItems[1] + '@' //ng qty
      + LvDefect.Items[i].SubItems[5] + '@'; //level
//                   +LvDefect.Items[i].SubItems[4]+'@';   //memo
  end;
  if lvDefect.Items.Count = 0 then
    sDefectData := 'N/A';
  sMaterial := '';
  try
    with SProc do
    begin
      try
        Close;
        DataRequest('SAJET.SJ_QC_TRANSFER_LOT');
        FetchParams;
        Params.ParamByName('TTERMINALID').AsString := TerminalID;
        Params.ParamByName('TWO').AsString := QC.sWorkOrder;
        Params.ParamByName('TLOTNO').AsString := editLotNo.Text;
        Params.ParamByName('TSAMPLINGTYPE').AsString := lablSamplingType.Caption;
        Params.ParamByName('TDEFECTDATA').AsString := sDefectData;
        Params.ParamByName('TLOTSIZE').AsInteger := speditInspLotQty.Value;
        Params.ParamByName('TSAMPLINGSIZE').AsInteger := StrToIntDef(lablSampleSize.Caption, 0);
        Params.ParamByName('TPASSQTY').AsInteger := seditPassQty.Value;
        Params.ParamByName('TFAILQTY').AsInteger := seditFailQty.Value;
        Params.ParamByName('TEMPID').AsInteger := StrToInt(UpdateUserID);
        Params.ParamByName('TQCRESULT').AsString := IntToStr(iStatus);
        Params.ParamByName('TSAMPLINGID').AsString := QC.ssamplingTypeID;
        Params.ParamByName('TLOTMEMO').AsString := sLotNoMemo;
        Params.ParamByName('TPRODUCTLINE').AsString := combProductLineID.Text;
        Execute;
        if Params.ParamByName('TRES').AsString <> 'OK' then
        begin
          MessageDlg(Params.ParamByName('TRES').AsString, mtWarning, [mbOK], 0);
          exit;
        end
        else
        begin
          QryTemp.Close;
          QryTemp.Params.Clear;
          QryTemp.CommandText := 'select sajet.to_label(''QTY ID'','''') SNID from dual';
          QryTemp.Open;
          sMaterial := QryTemp.FieldByName('SNID').AsString;
          QryTemp.Close;
          QryTemp.Params.Clear;
          QryTemp.Params.CreateParam(ftString, 'qc_type', ptInput);
          QryTemp.Params.CreateParam(ftString, 'qc_lotno', ptInput);
          QryTemp.CommandText := 'update sajet.g_qc_lot '
            + 'set qc_type = :qc_type where qc_lotno = :qc_lotno and rownum = 1';
          QryTemp.Params.ParamByName('qc_type').AsString := sMaterial;
          QryTemp.Params.ParamByName('qc_lotno').AsString := editLotNo.Text;
          QryTemp.Execute;
          QryTemp.Close;
        

          sPrintData := G_getPrintData(6, 19, G_sockConnection, 'DspQryData', sMaterial, 1, 'DEFAULT');
          if assigned(G_onTransDataToApplication) then
            G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
          else
            MessageDlg('Not Defined Call Back Function for Code Soft', mtWarning, [mbOK], 0);


          LabID.Caption:=sMaterial;
        end;

        clearData;

        lvDefect.Items.Clear;
        editWorkOrder.Text := '';
        editLotNo.Text := '';
        editWorkOrder.Setfocus;
        if sMaterial <> '' then
          lablMsg.Caption := 'ID No: ' + sMaterial + ' print OK.';
      except
        on e: Exception do
          MessageDlg('Execute SAJET.SJ_QC_TRANSFER_LOT Exception!' + #10#13 + E.Message, mtWarning, [mbOK], 0);
      end;
    end; //with
  finally
    SProc.Close;
  end;
end;

procedure TformMain.editDefectCodeKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Ord(Key) = VK_Return then
  begin
    editDefectCode.Text := UpperCase(editDefectCode.Text);
    combDefectLevel.ItemIndex := -1;
    if not IsDefect then
    begin
      MessageDlg('No such Defect Code !!', mtError, [mbOK], 0);
      editDefectCode.SelectAll;
      editDefectcode.SetFocus;
      Exit;
    end;
    seditDefectQty.SetFocus;
    seditDefectQty.SelectAll;
  end;
end;

procedure TformMain.seditDefectQtyKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var i, iNgCnt: integer;
  bFlag: Boolean;
begin
  if Key = 13 then
  begin
    if not checkInput then Exit;

    bFlag := True;
    for i := 0 to lvDefect.Items.Count - 1 do
    begin
      if lvDefect.Items[i].Caption = editDefectCode.Text then
      begin
        iNgCnt := StrToInt(lvDefect.Items[i].SubItems[1]);
        lvDefect.Items[i].SubItems[1] := IntToStr(iNgCnt + seditDefectQty.Value);
        bFlag := False;
      end;
    end;

    if bFlag then
    begin
      with lvDefect.Items.Add do
      begin
        Caption := editDefectCode.Text;
        SubItems.Add(combDefectLevel.Text);
        SubItems.Add(seditDefectQty.Text);
        SubItems.Add(lablDefectDesc.Caption);
        SubItems.Add(lablDefectDesc2.Caption);
        SubItems.Add(trim(editDefectMemo.Text));
        SubItems.Add(IntToStr(combDefectLevel.Items.IndexOf(combDefectLevel.Text)));
      end;
    end;

    editDefectCode.Clear;
    lablDefectDesc.Caption := '';
    lablDefectDesc2.Caption := '';
    seditDefectQty.Value := 0;
    combDefectLevel.ItemIndex := -1;
    editDefectMemo.Text := '';
    editDefectCode.SetFocus;

  end;
end;

procedure TformMain.seditPassQtyKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
    seditFailQty.SetFocus;
end;

procedure TformMain.sbtnSamplePlanClick(Sender: TObject);
var
  bChangeAQL: Boolean;
  sSamplingType, sSamplingID: string;
begin
  if not QC.bWOInput then exit;

  fAQL := TfAQL.Create(Self);
  try
    fAQL.lablLotNO.Caption := self.editLotNo.Text;
    fAQL.lablWorkOrder.Caption := self.editWorkOrder.Text;

    if fAQL.showmodal <> mrOK then
      exit;
    bChangeAQL := true;
    sSamplingType := fAQL.cmbAQL.Text;
    sSamplingID := '0';
    sSamplingID := fAQL.G_tsSampling.Strings[fAQL.G_tsSampling.indexof(sSamplingType) + 1];
  finally
    fAQL.Free;
  end;

  if not bChangeAQL then exit;
  if sSamplingType <> lablSamplingType.Caption then
  begin
     //檢查抽驗計畫的範圍是否有定義
    lablSamplingType.Caption := sSamplingType;
    seditCheckQty.Value := 0;
    if speditInspLotQty.Value > 0 then
    begin
      if getSamplingPlanRange(sSamplingType, speditInspLotQty.Value) then
      begin
        seditCheckQty.value := StrToInt(lablSampleSize.Caption); //應檢驗數DEFAULT帶SAMPLE SIZE
      end;
    end;
    QC.sSampleType := sSamplingType;
    QC.ssamplingTypeID := sSamplingID;
  end;
end;

function TformMain.getSamplingPlanRange(sSamplingType: string; iLotSize: integer): Boolean;
var sSQL: string;
begin
  result := False;
  lablCriticalRej.Caption := '0';
  lablMajorRej.Caption := '0';
  lablMinorRej.Caption := '0';
  lablSampleSize.Caption := '0';
//   seditCheckQty.Value      := 0;
//   seditFailQty.Value       := 0;
//   seditPassQty.Value       := 0;

  with QryTemp do
  begin
    try
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SAMPLING_TYPE', ptInput);
      Params.CreateParam(ftInteger, 'LOT_SIZE1', ptInput);
      Params.CreateParam(ftInteger, 'LOT_SIZE2', ptInput);
      sSQL := 'SELECT E.SAMPLE_SIZE, '
        + '       E.CRITICAL_REJECT_QTY, E.MAJOR_REJECT_QTY, E.MINOR_REJECT_QTY '
        + '  FROM SAJET.SYS_QC_SAMPLING_PLAN D, SAJET.SYS_QC_SAMPLING_PLAN_DETAIL E '
        + ' WHERE D.SAMPLING_TYPE =:SAMPLING_TYPE '
        + '   AND D.SAMPLING_ID = E.SAMPLING_ID '
        + '   AND E.MIN_LOT_SIZE <= :LOT_SIZE1 '
        + '   AND E.MAX_LOT_SIZE >= :LOT_SIZE2 ';
      commandtext := sSQL;
      Params.ParamByName('SAMPLING_TYPE').AsString := sSamplingType;
      Params.ParamByName('LOT_SIZE1').AsInteger := iLotSize;
      Params.ParamByName('LOT_SIZE2').AsInteger := iLotSize;
      open;
      if not eof then
      begin
        lablCriticalRej.Caption := FieldByName('Critical_Reject_Qty').AsString;
        lablMajorRej.Caption := FieldByName('Major_Reject_Qty').AsString;
        lablMinorRej.Caption := FieldByName('Minor_Reject_Qty').AsString;
        if StrToInt(FieldByName('SAMPLE_SIZE').AsString) > iLotSize then
          lablSampleSize.Caption := IntToStr(iLotSize)
        else
          lablSampleSize.Caption := FieldByName('SAMPLE_SIZE').AsString;

        //  seditCheckQty.value := StrToIntDef(lablSampleSize.Caption,0);
        result := true;
      end
      else
      begin

      end;
    finally
      Close;
    end;
  end;
end;

procedure TformMain.editDefectMemoKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    seditDefectQty.SetFocus;
    seditDefectQty.SelectAll;
  end;
end;

procedure TformMain.Delete1Click(Sender: TObject);
var iIndex: Integer;
begin
  if LVDefect.Items.Count = 0 then exit;
  iIndex := LVDefect.Selected.Index;
  LVDefect.Items[iIndex].Delete;
end;

procedure TformMain.seditFailQtyKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    editDefectCode.SetFocus;
    seditPassQty.Value := seditCheckQty.value - seditFailQty.value;
  end;
end;

procedure TformMain.speditInspLotQtyKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then
  begin
    QC.iLotSize := speditInspLotQty.Value;
    if QC.iLotSize <= 0 then
    begin
      MessageDlg('Lot Size Can''t Equal to "0" !', mtError, [mbOK], 0);
      speditInspLotQty.Setfocus;
      speditInspLotQty.SelectAll;
      exit;
    end;
    if not getSamplingPlanRange(QC.sSampleType, QC.iLotSize) then
    begin
      MessageDlg('Sampling Plan Type : ' + QC.sSampleType + #10#13
        + 'Lot Size Range : ' + IntToStr(QC.iLotSize) + #10#13
        + 'Not Define Sample Size !', mtwarning, [mbOK], 0);
      speditInspLotQty.Setfocus;
      speditInspLotQty.SelectAll;
      exit;
    end;
    QC.bGetSampleRange := true;
    seditCheckQty.SetFocus;
    seditCheckQty.SelectAll;
  end;
end;

procedure TformMain.seditCheckQtyKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    seditFailQty.SetFocus;
    seditPassQty.Value := seditCheckQty.value - seditFailQty.value;
  end;
end;



procedure TformMain.FormCreate(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
end;

function TformMain.GetTerminalID: Boolean;
begin
  Result := False;

  with TIniFile.Create('SAJET.ini') do
  begin
    TerminalID := ReadString('Quality Control', 'Terminal', '');
    Free;
  end;
  if TerminalID = '' then
  begin
    MessageBeep(17);
    MessageDlg('Terminal not be assign !!', mtError, [mbCancel], 0);
    Exit;
  end;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'Select A.PROCESS_ID,A.TERMINAL_NAME,B.PROCESS_NAME,C.PDLINE_NAME ,D.STAGE_NAME ' +
      '      ,A.PDLINE_ID ' +
      'From  SAJET.SYS_TERMINAL A,' +
      ' SAJET.SYS_PROCESS B, ' +
      ' SAJET.SYS_STAGE D, ' +
      ' SAJET.SYS_PDLINE C ' +
      'Where   A.TERMINAL_ID = :TERMINALID '
      + ' AND A.PROCESS_ID = B.PROCESS_ID '
      + '   AND A.STAGE_ID = D.STAGE_ID '
      + ' AND A.PDLINE_ID = C.PDLINE_ID ';

    Params.ParamByName('TERMINALID').AsString := TerminalID;
    Open;
    if RecordCount <= 0 then
    begin
      Close;
      MessageBeep(17);
      MessageDlg('Terminal data error !!', mtError, [mbCancel], 0);
      Exit;
    end;
    sProcessId :=  FieldbyName('Process_id').AsString;
    combLine.Text := FieldbyName('PDLINE_NAME').AsString;
    editStage.Text := FieldbyName('STAGE_NAME').AsString;
    editProcessName.Text := FieldbyName('Process_Name').AsString;
    editTerminal.Text := FieldByName('Terminal_Name').AsString;
    Close;
  end;
  Result := True;
end;


procedure TformMain.editWorkOrderChange(Sender: TObject);
begin
  clearData;
  lablMsg.Caption := '';
  QC.bWOInput := False;
end;

procedure TformMain.editWorkOrderKeyPress(Sender: TObject; var Key: Char);
begin
  if key <> #13 then exit;
  editWorkOrder.Text := Trim(editWorkOrder.Text);
  if not GetWorkOrder(editWorkOrder.Text) then
  begin
    editWorkOrder.SetFocus;
    editWorkOrder.SelectAll;
    exit;
  end;
  lablReceivedQty.Caption := IntToStr(GetReceivedQty(editWorkOrder.Text));

  if not GetDefaultSamplingPlan(QC.sPartNO) then
  begin
    editWorkOrder.SetFocus;
    editWorkOrder.SelectAll;
    exit;
  end;
  QC.sSampleType := lablSamplingType.Caption;
  editLotNo.SetFocus;
end;

function TformMain.GetDefaultSamplingPlan(sPartNo: string): Boolean;
begin
  result := false;
  with SProc do
  begin
    try
      try
        Close;
        DataRequest('SAJET.SJ_QC_GET_DEF_SAMPLETYPE');
        FetchParams;
        Params.ParamByName('TPARTNO').AsString := sPartNo;
        Execute;
        if Params.ParamByName('TRES').AsString <> 'OK' then
        begin
          MessageDlg(Params.ParamByName('TRES').AsString, mtError, [mbOK], 0);
          exit;
        end;
        lablSamplingType.Caption := Params.ParamByName('TSAMPLINGTYPE').AsString;
        QC.ssamplingTypeID := Params.ParamByName('TSAMPLINGID').AsString;
        result := True;
      except
        on E: ExceptION do
          MessageDlg('SAJET.QC_GET_DEF_SAMPLETYPE Exception' + #10#13 + E.MESSAGE, mtError, [mbCancel], 0);
      end;
    finally
      Close;
    end;
  end; //with
end;

procedure TformMain.sbtnNewLotClick(Sender: TObject);
begin

  if MessageDlg('Add New Lot No?', mtConfirmation, [mbYes, mbNo], 1) <> mrYes then exit;
  with QryTemp do
  begin
    try
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'TERMINALID', ptInput);
      CommandText := 'Select ''QC'' || B.PDLINE_NAME || TO_CHAR(SYSDATE,''YYMMDD'') || LPAD(SAJET.S_QC_CODE.NEXTVAL,5,''0'') SNID ' +
        'From SAJET.SYS_TERMINAL A, ' +
        'SAJET.SYS_PDLINE B ' +
        'Where A.TERMINAL_ID = :TERMINALID and ' +
        'A.PDLINE_ID = B.PDLINE_ID ';
      Params.ParamByName('TERMINALID').AsString := TerminalID;
      Open;
      if RecordCount <= 0 then
      begin
        Close;
        MessageBeep(17);
        MessageDlg('Create QC Lot No Error !!', mtError, [mbCancel], 0);
        Exit;
      end
      else
      begin
        editLotNo.Text := Fieldbyname('SNID').AsString;
        speditInspLotQty.SetFocus;
        speditInspLotQty.SelectAll;
      end;
    finally
      Close;
    end;
  end;
end;

procedure TformMain.editLotNoKeyPress(Sender: TObject; var Key: Char);
begin
  if key <> #13 then exit;
  editLotNO.Text := Trim(editLotNO.Text);
  if editLotNo.Text = '' then exit;
  speditInspLotQty.Setfocus;
  speditInspLotQty.SelectAll;
end;

procedure TformMain.speditInspLotQtyChange(Sender: TObject);
begin
  QC.bGetSampleRange := False;
end;

function TformMain.GetReceivedQty(sWorkOrder: string): Integer;
begin
  with QryTemp do
  begin
    try
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      //Params.CreateParam(ftString, 'PROCESS_ID', ptInput);
      CommandText := '  SELECT erp_qty QTY '
        + '    FROM SAJET.g_wo_BASE '
        + '		WHERE WORK_ORDER = :WORK_ORDER ';
      Params.ParamByName('WORK_ORDER').AsString := sWorkOrder;
      //Params.ParamByName('PROCESS_ID').AsString := sProcessId;
      Open;
      Result := FieldByName('QTY').AsInteger;
    finally
      close;
    end;
  end;
end;

procedure TformMain.sbtnFilterClick(Sender: TObject);
var sWorkOrder: string;
  InputKey: Char;
begin

  sWorkOrder := Trim(editWorkOrder.Text);
  InputKey := #13;
  with TfFilter.Create(Self) do
  begin
    try
      qryData.RemoteServer := formMain.QryData.RemoteServer;
      with QryData do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
        CommandText := ' Select A.WORK_ORDER , B.PART_NO  '
          + '       ,DECODE(A.WO_STATUS,''0'',''Initial'',''1'',''Prepare'',''2'',''Release'',''3'',''In Wip'',''4'',''Hold'',''5'',''Cancel'',''6'',''Complete'',A.WO_STATUS) WO_STATUS  '
          + ' from sajet.G_WO_BASE A '
          + ' LEFT JOIN SAJET.SYS_PART B ON A.MODEL_ID = B.PART_ID '
          + ' WHERE A.WORK_ORDER LIKE :WORK_ORDER   '
          + ' ORDER BY A.WORK_ORDER ';
        Params.ParamByName('WORK_ORDER').AsString := sWorkOrder + '%';
        Open;
      end;
      if Showmodal = mrOK then
      begin
        editWorkOrder.Text := qryData.FieldByName('WORK_ORDER').AsString;
        editWorkOrder.SetFocus;
        editWorkOrder.SelectAll;
        editWorkOrderKeyPress(self, InputKey);
      end;
    finally
      qryData.Close;
      Free;
    end;
  end;
end;

end.

