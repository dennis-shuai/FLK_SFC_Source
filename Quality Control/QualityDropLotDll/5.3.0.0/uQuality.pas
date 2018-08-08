unit uQuality;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db,
   DBClient, MConnect, SConnect, IniFiles, ObjBrkr, Menus, GradPanel;

type
   TfQuality = class(TForm)
      Panel1: TPanel;
      SocketConnection1: TSocketConnection;
      QryData: TClientDataSet;
      QryTemp: TClientDataSet;
      SProc: TClientDataSet;
      SimpleObjectBroker1: TSimpleObjectBroker;
      SimpleObjectBroker2: TSimpleObjectBroker;
      PopupMenu1: TPopupMenu;
      pitemRemove: TMenuItem;
      QryTemp2: TClientDataSet;
    PopupMenu2: TPopupMenu;
    itemDelete: TMenuItem;
    PopupMenu3: TPopupMenu;
    itemChange: TMenuItem;
    GradPanel9: TGradPanel;
    PanelLeft: TPanel;
    PanelRight: TPanel;
    PanelPallet: TPanel;
    GradPanel7: TGradPanel;
    Label4: TLabel;
    Image3: TImage;
    sbtnAddMore: TSpeedButton;
    LVPallet: TListView;
    PanelDefectSN: TPanel;
    LVDefect: TListView;
    GradPanel4: TGradPanel;
    Label6: TLabel;
    PanelSNData: TPanel;
    Splitter1: TSplitter;
    GradPanel10: TGradPanel;
    Label20: TLabel;
    LabTotQty: TLabel;
    Label15: TLabel;
    LabChkQty: TLabel;
    Label16: TLabel;
    LabFailed: TLabel;
    Label17: TLabel;
    LabCritical: TLabel;
    Label18: TLabel;
    LabMajor: TLabel;
    Label19: TLabel;
    LabMinor: TLabel;
    Splitter5: TSplitter;
    PanelCheckSN: TPanel;
    LVCheckSN: TListView;
    GradPanel5: TGradPanel;
    Label24: TLabel;
    Splitter6: TSplitter;
    Splitter7: TSplitter;
    GradPanel6: TGradPanel;
    Label10: TLabel;
    LabInspType: TLabel;
    Label12: TLabel;
    LabCriQty: TLabel;
    Label13: TLabel;
    LabMajQty: TLabel;
    Label14: TLabel;
    LabMinQty: TLabel;
    Label11: TLabel;
    LabSampleQty: TLabel;
    Splitter3: TSplitter;
    GradPanel2: TGradPanel;
    Panel8: TPanel;
    listbDefect: TListBox;
    GradPanel1: TGradPanel;
    LabTerminal: TLabel;
    Label1: TLabel;
    Image2: TImage;
    LabelPacking: TLabel;
    sbtnClose: TSpeedButton;
    Splitter2: TSplitter;
    Label2: TLabel;
    cmbQCLotNo: TComboBox;
    Label5: TLabel;
    LabWO: TLabel;
    Label8: TLabel;
    lablInspTimes: TLabel;
    Label7: TLabel;
    LabPart: TLabel;
    sbtnNewLot: TSpeedButton;
    sbtnAQL: TSpeedButton;
    GradPanel8: TGradPanel;
    Label3: TLabel;
    editSN: TEdit;
    GradPanel3: TGradPanel;
    lvEC: TListView;
    btnDefect: TButton;
    GradPanel11: TGradPanel;
    IncludeBtn: TSpeedButton;
    Splitter4: TSplitter;
    GradPanel12: TGradPanel;
    Image1: TImage;
    Image4: TImage;
    Image6: TImage;
    Label21: TLabel;
    Label23: TLabel;
    Label25: TLabel;
    Label9: TLabel;
    ImgPass: TImage;
    ImgReject: TImage;
    ImgWaive: TImage;
    Label22: TLabel;
    lablProcess: TLabel;
    Label27: TLabel;
    lablTerminal: TLabel;
    sbtnPass: TSpeedButton;
    sbtnReject: TSpeedButton;
    sbtnWaive: TSpeedButton;
      procedure sbtnCloseClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure sbtnNewLotClick(Sender: TObject);
      procedure FormClose(Sender: TObject; var Action: TCloseAction);
      procedure editSNKeyPress(Sender: TObject; var Key: Char);
      procedure cmbQCLotNoChange(Sender: TObject);
      procedure sbtnPassClick(Sender: TObject);
      procedure sbtnAQLClick(Sender: TObject);
      procedure sbtnAddMoreClick(Sender: TObject);
      procedure PopupMenu1Popup(Sender: TObject);
      procedure pitemRemoveClick(Sender: TObject);
    procedure itemDeleteClick(Sender: TObject);
    procedure itemChangeClick(Sender: TObject);
    procedure IncludeBtnClick(Sender: TObject);
    procedure btnDefectClick(Sender: TObject);
   private
    { Private declarations }
   public
    { Public declarations }
      UpdateUserID: string;
      TerminalID: string;
      PartID: string;
      G_SysDateTime: TDateTime;
      Authoritys, AuthorityRole: string;
      bGetSamplingPlan: Boolean;
      G_sPalletNO: string;
      G_sCartonNO: string;
      G_sRouteID: string;
      slPallet: TStringList;

      function GetWorkStaionOption(var bPassClear,bRejectClear:Boolean):Boolean;
      function GetTerminalID: Boolean;
      function GetQCLotNo: Boolean;
      function GetQCData(sQCCNT: string): Boolean;
      function CheckSN(var psSN: string): Boolean;
      function CheckRoute(psSN: string): Boolean;
      function checkDefaultSamplingPlan: Boolean;
      function CheckSN_InQC(psSN: string): Boolean;
      function CheckDefect(psDefectCode:String): Boolean;
      function InputData: Boolean;
      function GetPallet: string;
      function GetPriorProcess: string;
      procedure ClearData;
      procedure SetStatusbyAuthority;
      function GetSamplingPlan(sSamplingType: string): string;
      function CheckSamplingPlan: Boolean;
      function UpdateSN(psSN: string): Boolean;
      function UpdateQCLot(sSize: Integer): Boolean;
      function InsertSNDefect(psSN: string): Boolean;
      function InsertSNDefectTo109(psSN: string): Boolean;
      function GetDefectRecID: string;
      function InsertQCSN(psSN: string): Boolean;
      function GetPlace(sTerminal: string; var pline, pstage, pprocess: string): Boolean;
      function InsertNewLotNO(LotNo: string): Boolean;
      procedure updateLotSize;
      function checkPallet_InQC(psPalletNO: string): Boolean;
      procedure updateQCLot_Pallet(psPalletNO, psLotNo: string);
      function confirmResult(psPalletNo, psResult: String):Boolean;
      function GET_NEXTPROCESS(prouteid, pprocessid, presult: string):string;
      procedure ModifyWOInfo(WO, QC: String);
      function UpdateSNCount(psSN,pFlag: string;pPass,pFail,pOutput:integer): Boolean;
      procedure GetAllDefect;
   end;

var
   fQuality: TfQuality;
   //DefectList: TStringList;
   G_pline, G_pstage, G_pprocess: string;

implementation

uses uAQL, uData, uChange;

{$R *.DFM}

procedure TfQuality.GetAllDefect;
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select Defect_Code, Defect_Desc '
                   + '  From SAJET.SYS_DEFECT '
                   + ' Where Enabled = ''Y'' '
                   + ' Order By Defect_Code ';
      Open;
      while not Eof do
      begin
         listbDefect.Items.Add(FieldByName('Defect_Code').AsString + ' - ' +
                               FieldByName('Defect_Desc').AsString);
         Next;
      end;
      Close;
   end;
end;

Function TfQuality.confirmResult(psPalletNo, psResult: String):Boolean;
var sMsg, sQty : String;
begin
   if psResult = '2' then
   begin
      sMsg := 'Waive this Lot - ' + cmbQCLotNo.Text + ' ??';

      with QryTemp do
      begin
         Close;
         Params.Clear;
         CommandText := 'Select count(*) from SAJET.G_SN_STATUS '
                      + ' Where Pallet_No in (' + psPalletNo + ') '
                      + '   And (Current_Status = ''1'' '
                      + '    or Work_Flag = ''1'') ';
         Open;
         sQty := FieldByName('Count(*)').AsString;
         Close;
      end;
      If sQty <> '0' then
         sMsg := sMsg + #13#13#10 +
                 sQty + ' S/N need Repair or Scrap !!';
   end
   else if psResult = '1' then
   begin
      sMsg := 'Rejet this Lot - ' + cmbQCLotNo.Text + ' ??';
   end
   else
   begin
      sMsg := 'Pass this Lot - ' + cmbQCLotNo.Text + ' ??';
   end;

   Result := (MessageDlg(sMsg,mtConfirmation,[mbOK,mbCancel],0) = mrOK);
end;

procedure TfQuality.updateLotSize;
var sLotSize: string;
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT COUNT(SERIAL_NUMBER) QTY '
         + '  FROM SAJET.G_SN_STATUS '
         + ' WHERE QC_NO = ''' + cmbQCLotNo.Text + ''' ';
      Open;
      sLotSize := FieldByName('Qty').AsString;

      Close;
      Params.Clear;
      CommandText := 'UPDATE SAJET.G_QC_LOT '
         + '   SET LOT_SIZE = ' + sLotSize
         + '      ,INSP_EMPID = ''' + UpdateUserID + ''' '
         + ' WHERE QC_LOTNO = ''' + cmbQCLotNo.Text + ''' '
         + '   AND NG_CNT = ''' + lablInspTimes.Caption + ''' ';
      Execute;
   end;
end;

procedure TfQuality.SetStatusbyAuthority;
begin
  // Read Only,Allow To Change,Full Control
   Authoritys := '';
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      Params.CreateParam(ftString, 'FUN', ptInput);
      CommandText := 'Select AUTHORITYS ' +
         'From SAJET.SYS_EMP_PRIVILEGE ' +
         'Where EMP_ID = :EMP_ID and ' +
         'PROGRAM = :PRG and ' +
         'FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Quality Control';
      Params.ParamByName('FUN').AsString := 'Execution';
      Open;
      if RecordCount > 0 then
         Authoritys := Fieldbyname('AUTHORITYS').AsString;
      Close;
   end;

   sbtnNewLot.Enabled := (Authoritys = 'Allow To Execute');
   cmbQCLotNo.Enabled := sbtnNewLot.Enabled;
   editSN.Enabled := sbtnNewLot.Enabled;
   sbtnAddMore.Enabled := sbtnNewLot.Enabled;
   sbtnPass.Enabled := sbtnNewLot.Enabled;
   sbtnReject.Enabled := sbtnNewLot.Enabled;
   sbtnWaive.Enabled := sbtnNewLot.Enabled;

   AuthorityRole := '';
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      Params.CreateParam(ftString, 'FUN', ptInput);
      CommandText := 'Select AUTHORITYS ' +
         'From SAJET.SYS_ROLE_PRIVILEGE A, ' +
         'SAJET.SYS_ROLE_EMP B ' +
         'Where A.ROLE_ID = B.ROLE_ID and ' +
         'EMP_ID = :EMP_ID and ' +
         'PROGRAM = :PRG and ' +
         'FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Quality Control';
      Params.ParamByName('FUN').AsString := 'Execution';
      Open;
      if RecordCount > 0 then
         AuthorityRole := Fieldbyname('AUTHORITYS').AsString;
      Close;
   end;

   if not sbtnNewLot.Enabled then
   begin
      sbtnNewLot.Enabled := (AuthorityRole = 'Allow To Execute');
      cmbQCLotNo.Enabled := sbtnNewLot.Enabled;
      editSN.Enabled := sbtnNewLot.Enabled;
      sbtnAddMore.Enabled := sbtnNewLot.Enabled;
      sbtnPass.Enabled := sbtnNewLot.Enabled;
      sbtnReject.Enabled := sbtnNewLot.Enabled;
      sbtnWaive.Enabled := sbtnNewLot.Enabled;
   end;

  // Modify by jeaus user can change AQL
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      Params.CreateParam(ftString, 'FUN', ptInput);
      CommandText := 'Select AUTHORITYS ' +
         'From SAJET.SYS_EMP_PRIVILEGE ' +
         'Where EMP_ID = :EMP_ID and ' +
         'PROGRAM = :PRG and ' +
         'FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Quality Control';
      Params.ParamByName('FUN').AsString := 'Change AQL';
      Open;
      if sbtnNewLot.Enabled then
         if QryTemp.RecordCount > 0 then
            sbtnAQL.Enabled := true
         else
            sbtnAQL.Enabled := False;
      Close;
   end;

  //add by Rita 2004/08/16
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      Params.CreateParam(ftString, 'FUN', ptInput);
      CommandText := 'Select AUTHORITYS ' +
         'From SAJET.SYS_ROLE_PRIVILEGE A, ' +
         'SAJET.SYS_ROLE_EMP B ' +
         'Where A.ROLE_ID = B.ROLE_ID and ' +
         'EMP_ID = :EMP_ID and ' +
         'PROGRAM = :PRG and ' +
         'FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Quality Control';
      Params.ParamByName('FUN').AsString := 'Change AQL';
      Open;
      if (sbtnNewLot.Enabled) and (not sbtnAQL.Enabled) then
      begin
         if RecordCount > 0 then
            sbtnAQL.Enabled := true
         else
            sbtnAQL.Enabled := False;
      end;
   end;
end;

function TfQuality.GetSamplingPlan(sSamplingType: string): string;
begin
   result := '0';
   bGetSamplingPlan := False;
   LabSampleQty.Caption := '0';
   LabCriQty.Caption := '0';
   LabMajQty.Caption := '0';
   LabMinQty.Caption := '0';
 // 讀取 Sampling Plan,檢查區間
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SAMPLING_TYPE', ptInput);
      Params.CreateParam(ftString, 'QTY1', ptInput);
      Params.CreateParam(ftString, 'QTY2', ptInput);

      CommandText := ' SELECT A.SAMPLING_ID,A.SAMPLING_TYPE,B.SAMPLE_SIZE,B.CRITICAL_REJECT_QTY '
         + '       ,B.MAJOR_REJECT_QTY,B.MINOR_REJECT_QTY '
         + ' FROM SAJET.SYS_QC_SAMPLING_PLAN A  '
         + '     , SAJET.SYS_QC_SAMPLING_PLAN_DETAIL B '
         + ' WHERE A.SAMPLING_TYPE =:SAMPLING_TYPE '
         + '   AND A.SAMPLING_ID = B.SAMPLING_ID '
         + '   AND B.MIN_LOT_SIZE <= :QTY1 '
         + '   AND B.MAX_LOT_SIZE >= :QTY2 ';
      Params.ParamByName('SAMPLING_TYPE').AsString := sSamplingType;
      Params.ParamByName('QTY1').AsString := LabTotQty.Caption;
      Params.ParamByName('QTY2').AsString := LabTotQty.Caption;
      Open;
      if RecordCount > 0 then
      begin
         bGetSamplingPlan := True;
         LabInspType.Caption := Fieldbyname('SAMPLING_TYPE').AsString;
         LabSampleQty.Caption := Fieldbyname('SAMPLE_SIZE').AsString;
         //如果抽驗樣本數  大於 批量,則以批量當作樣本數
         if StrToIntDef(LabSampleQty.Caption, 0) > StrToIntDef(LabTotQty.Caption, 0) then
            LabSampleQty.Caption := LabTotQty.Caption;
         LabCriQty.Caption := Fieldbyname('CRITICAL_REJECT_QTY').AsString;
         LabMajQty.Caption := Fieldbyname('MAJOR_REJECT_QTY').AsString;
         LabMinQty.Caption := Fieldbyname('MINOR_REJECT_QTY').AsString;
         result := FieldByName('SAMPLING_ID').AsString;
      end
      else
      begin
         MessageBeep(17);
         MessageDlg('Sampling Plan Range not found !!', mtError, [mbCancel], 0);
      end;
      Close;
   end;
end;

function TfQuality.CheckSamplingPlan: Boolean;
begin
   ImgReject.Visible := False;
   ImgPass.Visible := False;
   ImgWaive.Visible := False;
   sbtnPass.Enabled := False;
   sbtnWaive.Enabled := False;
   Result := False;
   if not bGetSamplingPlan then
      Exit;
  //當抽驗數大於等於樣本數時
   if StrToIntDef(LabChkQty.Caption, 0) >= StrToIntDef(LabSampleQty.Caption, 0) then
   begin
      sbtnPass.Enabled := True;
      sbtnWaive.Enabled := True;
      if (StrToIntDef(LabCriQty.Caption, 0) <= StrToIntDef(LabCritical.Caption, 0)) or
         (StrToIntDef(LabMajQty.Caption, 0) <= StrToIntDef(LabMajor.Caption, 0)) or
         (StrToIntDef(LabMinQty.Caption, 0) <= StrToIntDef(LabMinor.Caption, 0)) then
         ImgReject.Visible := True
      else begin
         ImgPass.Visible := True;
         ImgWaive.Visible := True;
      end;
   end
   else
   // modify by Jack in 2004/12/20
   // for LiteonKL "Reject" 只要達到錯誤數即提示Reject
   begin
      if (StrToIntDef(LabCriQty.Caption, 0) <= StrToIntDef(LabCritical.Caption, 0)) or
         (StrToIntDef(LabMajQty.Caption, 0) <= StrToIntDef(LabMajor.Caption, 0)) or
         (StrToIntDef(LabMinQty.Caption, 0) <= StrToIntDef(LabMinor.Caption, 0)) then
         ImgReject.Visible := True;
   end;
   Label21.Enabled := sbtnPass.Enabled;
   Label25.Enabled := sbtnWaive.Enabled ;
   if ImgPass.Visible then
      Label21.Visible := False;
   if ImgWaive.Visible then
      Label25.Visible := False;
   Label23.Visible := not ImgReject.Visible;
   Result := True;
end;

procedure TfQuality.ClearData;
begin
   LabPart.Caption := '';
   Label21.Visible := True;
   Label23.Visible := True;
   Label25.Visible := True;
   LabWO.Caption := '';
   LVPallet.Items.Clear;
   LVDefect.Items.Clear;
   LVCheckSN.Items.Clear;
   slPallet.Clear;
   LabSampleQty.Caption := '0';
   LabCriQty.Caption := '0';
   LabMajQty.Caption := '0';
   LabMinQty.Caption := '0';
   LabTotQty.Caption := '0';
   LabChkQty.Caption := '0';
   LabFailed.Caption := '0';
   LabCritical.Caption := '0';
   LabMajor.Caption := '0';
   LabMinor.Caption := '0';
   editSN.Text := '';
end;

function TfQuality.GetQCData(sQCCNT: string): Boolean;
var I: Integer;
begin
   Result := False;
   with QryTemp do
   begin
    // 目前檢驗批的基本資料
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'QC_LOTNO', ptInput);
      Params.CreateParam(ftString, 'NG_CNT', ptInput);

      CommandText := 'Select B.PART_NO,LOT_SIZE,SAMPLING_SIZE,PASS_QTY,FAIL_QTY,WORK_ORDER , NG_CNT, MODEL_ID ' +
         'From SAJET.G_QC_LOT A, ' +
         'SAJET.SYS_PART B ' +
         'Where A.MODEL_ID = B.PART_ID(+)  ' +
         '  and A.QC_LOTNO = :QC_LOTNO ' +
         '  and A.NG_CNT =:NG_CNT ';
      Params.ParamByName('QC_LOTNO').AsString := cmbQCLotNo.Text;
      Params.ParamByName('NG_CNT').AsString := sQCCNT;
      Open;
      if RecordCount > 0 then
      begin
         LabWO.Caption := Fieldbyname('WORK_ORDER').AsString;
         LabPart.Caption := Fieldbyname('PART_NO').AsString;
         LabTotQty.Caption := Fieldbyname('LOT_SIZE').AsString;
         LabChkQty.Caption := Fieldbyname('SAMPLING_SIZE').AsString;
         LabFailed.Caption := Fieldbyname('FAIL_QTY').AsString;
         PartId := Fieldbyname('MODEL_ID').AsString;
      //lablInspTimes.Caption :=Fieldbyname('NG_CNT').AsString;
      end;
      Close;
    // 目前檢驗出不良數的資料
      Params.Clear;
      Params.CreateParam(ftString, 'QC_LOTNO', ptInput);
      CommandText := 'Select NVL(SUM(DECODE(DEFECT_LEVEL,''0'',1,0)),0) CRITICAL, ' +
         'NVL(SUM(DECODE(DEFECT_LEVEL,''1'',1,0)),0) MAJOR, ' +
         'NVL(SUM(DECODE(DEFECT_LEVEL,''2'',1,0)),0) MINOR ' +
         'From SAJET.G_QC_SN_DEFECT ' +
         'Where QC_LOTNO = :QC_LOTNO ' +
         '  and QC_CNT =:QC_CNT ';
      Params.ParamByName('QC_LOTNO').AsString := cmbQCLotNo.Text;
      Params.ParamByName('QC_CNT').AsString := sQCCNT;
      Open;
      LabCritical.Caption := Fieldbyname('CRITICAL').AsString;
      LabMajor.Caption := Fieldbyname('MAJOR').AsString;
      LabMinor.Caption := Fieldbyname('MINOR').AsString;
      Close;
    // 已檢驗的不良SN
      Params.Clear;
      Params.CreateParam(ftString, 'QC_NO', ptInput);
      CommandText := ' Select SERIAL_NUMBER,DEFECT_CODE,DEFECT_DESC '
         + 'From SAJET.G_QC_SN_Defect A,'
         + 'SAJET.SYS_DEFECT B '
         + 'Where A.QC_LOTNO = :QC_NO '
         + '  and A.QC_CNT =:QC_CNT '
         + '  and A.DEFECT_ID = B.DEFECT_ID '
         + 'Order By A.SERIAL_NUMBER ';
      Params.ParamByName('QC_NO').AsString := cmbQCLotNo.Text;
      Params.ParamByName('QC_CNT').AsString := sQCCNT;
      Open;
      I := 0;
      while not Eof do
      begin
         with LVDefect.Items.Add do
         begin
            Caption := Fieldbyname('SERIAL_NUMBER').AsString;
            Subitems.Add(Fieldbyname('DEFECT_CODE').AsString);
            Subitems.Add(Fieldbyname('DEFECT_DESC').AsString);
         end;
         Next;
      end;
      Close;

    // 已檢驗的 Pallet
      Params.Clear;
      Params.CreateParam(ftString, 'QC_NO', ptInput);
      CommandText := 'Select PALLET_NO,CARTON_NO,Count(SERIAL_NUMBER) QTY ' +
         'From SAJET.G_SN_STATUS ' +
         'Where QC_NO = :QC_NO ' +
         'Group By Pallet_No,CARTON_NO ';
      Params.ParamByName('QC_NO').AsString := cmbQCLotNo.Text;
      Open;
      I := 0;
      while not Eof do
      begin
         with LVPallet.Items.Add do
         begin
            Caption := Fieldbyname('PALLET_NO').AsString;
            slPallet.Add(Caption);
            Subitems.Add(Fieldbyname('CARTON_NO').AsString);
            Subitems.Add(Fieldbyname('QTY').AsString);
            I := I + Fieldbyname('QTY').AsInteger;
         end;
         Next;
      end;
      Close;
      LabTotQty.Caption := IntToStr(I);

  //已抽驗的序號
      Params.Clear;
      Params.CreateParam(ftString, 'QC_NO', ptInput);
      CommandText := ' Select A.SERIAL_NUMBER,A.INSP_TIME,B.EMP_NAME '
         + 'From SAJET.G_QC_SN A,'
         + 'SAJET.SYS_EMP B '
         + 'Where A.QC_LOTNO = :QC_NO '
         + '  and A.QC_CNT =:QC_CNT '
         + '  and A.INSP_EMP_ID = B.EMP_ID '
         + 'Order By A.SERIAL_NUMBER ';
      Params.ParamByName('QC_NO').AsString := cmbQCLotNo.Text;
      Params.ParamByName('QC_CNT').AsString := sQCCNT;
      Open;
      I := 0;
      while not Eof do
      begin
         with LVCheckSN.Items.Add do
         begin
            Caption := Fieldbyname('SERIAL_NUMBER').AsString;
            Subitems.Add(Fieldbyname('INSP_TIME').AsString);
            Subitems.Add(Fieldbyname('EMP_NAME').AsString);
         end;
         Next;
      end;
      Close;
   end;
end;

function TfQuality.CheckDefect(psDefectCode:String): Boolean;
var sRes: string;
   I: Integer;
   B: Boolean;
   S: string;
begin
   Result := False;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'NO', ptInput);
      CommandText := 'Select DEFECT_CODE,DEFECT_ID,DEFECT_LEVEL,DEFECT_DESC, ' +
         '                   DECODE(DEFECT_LEVEL,''0'',''CRITICAL'',''1'',''MAJOR'',''2'',''MINOR'') "LEVEL" '+
         'From SAJET.SYS_DEFECT ' +
         'Where DEFECT_CODE = :NO and ' +
         'ENABLED = ''Y'' ';
      Params.ParamByName('NO').AsString := psDefectCode;//editSN.Text;
      Open;
      if RecordCount > 0 then
      begin
         {S := Fieldbyname('DEFECT_CODE').AsString + ',' +
            Fieldbyname('DEFECT_ID').AsString + ',' +
            Fieldbyname('DEFECT_LEVEL').AsString;
         B := False;
         for I := 0 to DefectList.Count - 1 do
         begin
            if DefectList.Strings[I] = S then
               B := True;
         end;
         if not B then }
         if lvEc.findCaption(0,psDefectCode,False,True,False) = nil then
         begin
            //DefectList.Add(S);
            with lvEC.Items.Add do
            begin
               Caption := FieldByName('Defect_Code').AsString;
               SubItems.Add(FieldByName('LEVEL').AsString);
               SubItems.Add(FieldByName('Defect_Desc').AsString);
               SubItems.Add(FieldByName('Defect_ID').AsString);
               SubItems.Add(FieldByName('Defect_Level').AsString);
            end;
         end
         else
         begin
            MessageBeep(17);
            MessageDlg('Defect Code Duplicate !!', mtError, [mbCancel], 0);
         end;
         Result := True;
      end;
      Close;
   end;
end;

function TfQuality.GetPlace(sTerminal: string; var pline, pstage, pprocess: string): Boolean;
begin
   result := true;
   with SProc do
   begin
      try
         begin
            Close;
            DataRequest('SAJET.SJ_GET_PLACE');
            FetchParams;
            Close;
            FetchParams;
            Params.ParamByName('tterminalid').AsString := TerminalID;
            Execute;
            pline := Params.ParamByName('pline').AsString;
            pstage := Params.ParamByName('pstage').AsString;
            pprocess := Params.ParamByName('pprocess').AsString;
         end;
      except
         result := False;
      end;
      Close;
   end;
end;

function TfQuality.UpdateSN(psSN: string): Boolean;
var I: Integer;
   S, sRes: string;
   sCurrentStatus: string;
begin
   Result := False;
   sCurrentStatus := '0';
   //if DefectList.Count > 0 then
   if lvEC.Items.Count > 0 then
      sCurrentStatus := '1';
  // update g_sn_status
   if G_sPalletNO <> 'N/A' then
   begin
      with QryTemp do
      begin
         close;
         Params.Clear;
         Params.CreateParam(ftString, 'QCNO', ptInput);
         Params.CreateParam(ftString, 'PALLET_NO', ptInput);
         CommandText := ' Update SAJET.G_SN_STATUS  '
            + '    Set QC_NO = :QCNO '
            + '    ,QC_RESULT = ''N/A'' '
            + '  WHERE PALLET_NO = :PALLET_NO ';

         Params.ParamByName('QCNO').AsString := cmbQCLotNo.Text;
         Params.ParamByName('PALLET_NO').AsString := G_sPalletNO;
         Execute;
      end;
   end
   else
   begin
      with QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'QCNO', ptInput);
         Params.CreateParam(ftString, 'CARTON_NO', ptInput);
         CommandText := ' Update SAJET.G_SN_STATUS  '
            + '    Set QC_NO = :QCNO '
            + '    ,QC_RESULT = ''N/A'' '
            + '  WHERE CARTON_NO = :CARTON_NO ';

         Params.ParamByName('QCNO').AsString := cmbQCLotNo.Text;
         Params.ParamByName('CARTON_NO').AsString := G_sCartonNO;
         Execute;
      end;
   end;
   with QryTemp do
   begin
      close;
      Params.Clear;
      Params.CreateParam(ftString, 'CURRENT_STATUS', ptInput);
      Params.CreateParam(ftString, 'CURRENT_STATUS1', ptInput);
      Params.CreateParam(ftString, 'PROCESS_ID', ptInput);
      Params.CreateParam(ftString, 'CURRENT_STATUS3', ptInput);
      Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftDateTime, 'TNOW', ptInput);
      Params.CreateParam(ftString, 'CURRENT_STATUS2', ptInput);
      Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
      CommandText := ' Update SAJET.G_SN_STATUS '
         + '    SET CURRENT_STATUS =:CURRENT_STATUS '
         + '       ,PROCESS_ID = DECODE(:CURRENT_STATUS1,''0'',PROCESS_ID,:PROCESS_ID)  '
         + '       ,TERMINAL_ID = DECODE(:CURRENT_STATUS3,''0'',TERMINAL_ID,:TERMINAL_ID) '
         + '       ,EMP_ID  =:EMP_ID '
         + '       ,in_process_time=out_process_time '
         + '       ,out_process_time=:tnow '
         + '       ,NEXT_PROCESS = DECODE(:CURRENT_STATUS2 ,''1'',''0'',NEXT_PROCESS) '
         + '       ,wip_process = DECODE(:CURRENT_STATUS4,''0'',wip_process,:wip_process)  '
         + '  WHERE SERIAL_NUMBER =:SERIAL_NUMBER ';
      Params.ParamByName('CURRENT_STATUS').AsString := sCurrentStatus;
      Params.ParamByName('CURRENT_STATUS1').AsString := sCurrentStatus;
      Params.ParamByName('PROCESS_ID').AsString := G_pprocess;
      Params.ParamByName('CURRENT_STATUS3').AsString := sCurrentStatus;
      Params.ParamByName('TERMINAL_ID').AsString := TerminalID;
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('TNOW').AsDateTime := G_SysDateTime;
      Params.ParamByName('CURRENT_STATUS2').AsString := sCurrentStatus;
      Params.ParamByName('CURRENT_STATUS4').AsString := sCurrentStatus;
      Params.ParamByName('wip_process').AsString := GET_NEXTPROCESS(G_sRouteID,G_pprocess,sCurrentStatus);
      Params.ParamByName('SERIAL_NUMBER').AsString := psSN; //editSN.Text ;
      Execute;
   end;
   Result := True;
end;

function TfQuality.InsertQCSN(psSN: string): Boolean;
begin
// g_qc_sn
   try
      with QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'QC_LOTNO', ptInput);
         Params.CreateParam(ftString, 'MODEL_ID', ptInput);
         Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
         Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
         Params.CreateParam(ftString, 'QC_RESULT', ptInput);
         Params.CreateParam(ftString, 'INSP_EMP_ID', ptInput);
         Params.CreateParam(ftString, 'QC_CNT', ptInput);
         Params.CreateParam(ftDate, 'INSP_TIME', ptInput);
         CommandText := 'Insert Into SAJET.G_QC_SN ' +
            ' (QC_LOTNO,MODEL_ID,WORK_ORDER,SERIAL_NUMBER,QC_RESULT,' +
            '  INSP_EMP_ID,QC_CNT,INSP_TIME ) ' +
            'Values ' +
            ' (:QC_LOTNO,:MODEL_ID,:WORK_ORDER,:SERIAL_NUMBER,:QC_RESULT,' +
            '  :INSP_EMP_ID,:QC_CNT,:INSP_TIME) ';
         Params.ParamByName('QC_LOTNO').AsString := cmbQCLotNo.Text;
         Params.ParamByName('MODEL_ID').AsString := PartID;
         Params.ParamByName('WORK_ORDER').AsString := LabWO.Caption;
         Params.ParamByName('SERIAL_NUMBER').AsString := psSN; //editSN.Text;
         //if DefectList.Count > 0 then
         if lvEc.Items.Count > 0 then
            Params.ParamByName('QC_RESULT').AsString := '1'
         else
            Params.ParamByName('QC_RESULT').AsString := '0';
         Params.ParamByName('QC_CNT').AsString := lablInspTimes.Caption;
         Params.ParamByName('INSP_EMP_ID').AsString := UpdateUserID;
         Params.ParamByName('INSP_TIME').AsDateTime := G_SysDateTime;
         Execute;
      end;
   finally
      QryTemp.close;
   end;
end;

function TfQuality.UpdateQCLot(sSize: Integer): Boolean;
var TotCnt: string;
   sSamplingID: string;
begin
  // g_qc_lot
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'QC_NO', ptInput);
      CommandText := 'Select Count(SERIAL_NUMBER) QTY ' +
         'From SAJET.G_SN_STATUS ' +
         'Where QC_NO = :QC_NO ';
      Params.ParamByName('QC_NO').AsString := cmbQCLotNo.Text;
      Open;
      TotCnt := Fieldbyname('QTY').AsString;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SAMPLING_TYPE', ptInput);

      CommandText := ' SELECT SAMPLING_TYPE,SAMPLING_ID from SAJET.SYS_QC_SAMPLING_PLAN '
         + '  WHERE SAMPLING_TYPE =:SAMPLING_TYPE '
         + '   AND ROWNUM = 1 ';

      Params.ParamByName('SAMPLING_TYPE').AsString := LabInspType.Caption;
      Open;
      sSamplingID := '0';
      if not eof then
         sSamplingID := FieldbyName('SAMPLING_ID').AsString;
   end;
// g_qc_sn
   try
      with QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'QC_LOTNO', ptInput);
         Params.CreateParam(ftString, 'QC_CNT', ptInput);
         CommandText := 'SELECT * FROM SAJET.G_QC_LOT '
            + ' WHERE QC_LOTNO = :QC_LOTNO '
            + '   AND NG_CNT =:QC_CNT '
            + '   AND ROWNUM = 1 ';
         Params.ParamByName('QC_LOTNO').AsString := cmbQCLotNo.Text;
         Params.ParamByName('QC_CNT').AsString := lablInspTimes.Caption;
         OPEN;
         if eof then
         begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'QC_LOTNO', ptInput);
            Params.CreateParam(ftString, 'MODEL_ID', ptInput);
            Params.CreateParam(ftString, 'WORK_ORDER ', ptInput);
            Params.CreateParam(ftString, 'INSP_EMPID ', ptInput);
            Params.CreateParam(ftString, 'QC_CNT', ptInput);
            Params.CreateParam(ftString, 'LOT_SIZE', ptInput);
            Params.CreateParam(ftString, 'PASS_QTY', ptInput);
            Params.CreateParam(ftString, 'FAIL_QTY', ptInput);
            Params.CreateParam(ftDateTime, 'START_TIME', ptInput);
            Params.CreateParam(ftInteger, 'SAMPLING_SIZE', ptInput);
            Params.CreateParam(ftString, 'SAMPLING_PLAN_ID', ptInput);
            Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
            CommandText := ' INSERT INTO SAJET.G_QC_LOT ' +
               ' (QC_LOTNO,MODEL_ID,WORK_ORDER ' +
               '  , PDLINE_ID,STAGE_ID,PROCESS_ID,TERMINAL_ID,INSP_EMPID  ' +
               '  , NG_CNT,LOT_SIZE,SAMPLING_SIZE ,PASS_QTY ,FAIL_QTY,  START_TIME,SAMPLING_PLAN_ID ) ' +
               '  SELECT :QC_LOTNO,:MODEL_ID,:WORK_ORDER ' +
               '  , PDLINE_ID,STAGE_ID,PROCESS_ID,TERMINAL_ID,:INSP_EMPID  ' +
               '  , :QC_CNT ,:LOT_SIZE,:SAMPLING_SIZE,:PASS_QTY ,:FAIL_QTY,:START_TIME ,:SAMPLING_PLAN_ID ' +
               '  FROM SAJET.SYS_TERMINAL  ' +
               '  WHERE  TERMINAL_ID =:TERMINAL_ID ' +
               '    AND ROWNUM = 1 ';
            Params.ParamByName('QC_LOTNO').AsString := cmbQCLotNo.Text;
            Params.ParamByName('MODEL_ID').AsString := PartID;
            Params.ParamByName('WORK_ORDER').AsString := LabWO.Caption;
            Params.ParamByName('INSP_EMPID').AsString := UpdateUserID;
            Params.ParamByName('QC_CNT').AsString := lablInspTimes.Caption;
            Params.ParamByName('LOT_SIZE').AsString := TotCnt;
            Params.ParamByName('SAMPLING_SIZE').AsInteger := sSize;
            Params.ParamByName('SAMPLING_PLAN_ID').AsString := sSamplingID;
            Params.ParamByName('START_TIME').AsDateTime := G_SysDateTime;
            Params.ParamByName('TERMINAL_ID').AsString := TerminalID;
            //if DefectList.Count > 0 then
            if lvEc.Items.Count > 0 then
            begin
               Params.ParamByName('PASS_QTY').AsInteger := 0;
               Params.ParamByName('FAIL_QTY').AsInteger := sSize;
            end
            else
            begin
               Params.ParamByName('PASS_QTY').AsInteger := sSize;
               Params.ParamByName('FAIL_QTY').AsInteger := 0;
            end;
            Execute;
         end
         else
         begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'LOT_SIZE', ptInput);
            Params.CreateParam(ftInteger, 'sSIZE', ptInput);
            Params.CreateParam(ftString, 'PASS_QTY', ptInput);
            Params.CreateParam(ftString, 'FAIL_QTY', ptInput);
            Params.CreateParam(ftString, 'MODEL_ID', ptInput);
            Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
            Params.CreateParam(ftString, 'QC_LOTNO', ptInput);
            Params.CreateParam(ftString, 'NG_CNT', ptInput);
            Params.CreateParam(ftString, 'SAMPLING_PLAN_ID', ptInput);
            CommandText := 'Update SAJET.G_QC_LOT ' +
               'Set LOT_SIZE = :LOT_SIZE,' +
               'SAMPLING_SIZE = SAMPLING_SIZE + :sSize,' +
               'PASS_QTY = PASS_QTY + :PASS_QTY,' +
               'FAIL_QTY = FAIL_QTY + :FAIL_QTY,' +
               'MODEL_ID = :MODEL_ID,' +
               'WORK_ORDER = :WORK_ORDER, ' +
               'SAMPLING_PLAN_ID = :SAMPLING_PLAN_ID ' +
               'Where QC_LOTNO = :QC_LOTNO ' +
               '  and NG_CNT =:NG_CNT ';
            Params.ParamByName('LOT_SIZE').AsString := TotCnt;
            Params.ParamByName('sSIZE').AsInteger := sSize;
            Params.ParamByName('SAMPLING_PLAN_ID').AsString := sSamplingID;
            //if DefectList.Count > 0 then
            if lvEC.Items.Count > 0 then
            begin
               Params.ParamByName('PASS_QTY').AsInteger := 0;
               Params.ParamByName('FAIL_QTY').AsInteger := sSize;
            end
            else
            begin
               Params.ParamByName('PASS_QTY').AsInteger := sSize;
               Params.ParamByName('FAIL_QTY').AsInteger := 0;
            end;
            Params.ParamByName('MODEL_ID').AsString := PartID;
            Params.ParamByName('WORK_ORDER').AsString := LabWO.Caption;
            Params.ParamByName('QC_LOTNO').AsString := cmbQCLotNo.Text;
            Params.ParamByName('NG_CNT').AsString := lablInspTimes.Caption;
            Execute;
         end;
      end;
   finally
      QryTemp.close;
   end;
end;

function TfQuality.InsertSNDefect(psSN: string): Boolean;
var S: string;
   I: integer;
begin
   try
      with QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'QC_LOTNO', ptInput);
         Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
         Params.CreateParam(ftString, 'QC_CNT', ptInput);
         Params.CreateParam(ftString, 'DEFECT_ID', ptInput);
         Params.CreateParam(ftString, 'DEFECT_LEVEL', ptInput);
         CommandText := 'Insert Into SAJET.G_QC_SN_DEFECT ' +
            ' (QC_LOTNO,SERIAL_NUMBER,QC_CNT,' +
            '  DEFECT_ID,DEFECT_LEVEL ) ' +
            'Values ' +
            ' (:QC_LOTNO,:SERIAL_NUMBER,:QC_CNT,:DEFECT_ID,:DEFECT_LEVEL ) ';
         //if DefectList.Count > 0 then
         if lvEC.Items.Count > 0 then
         begin
            //for I := 0 to DefectList.Count - 1 do
            for I := 0 to lvEC.Items.Count - 1 do
            begin
               //S := DefectList.Strings[I];
               //S := Copy(S, POS(',', S) + 1, Length(S) - POS(',', S));
               Params.ParamByName('QC_LOTNO').AsString := cmbQCLotNo.Text;
               Params.ParamByName('SERIAL_NUMBER').AsString := psSN; //editSN.Text;
               Params.ParamByName('QC_CNT').AsString := lablInspTimes.Caption;
               Params.ParamByName('DEFECT_ID').AsString := lvEC.Items[I].SubItems[2];//Copy(S, 1, POS(',', S) - 1);
               Params.ParamByName('DEFECT_LEVEL').AsString := lvEC.Items[I].SubItems[3];//Copy(S, POS(',', S) + 1, Length(S) - POS(',', S));
               Execute;
            end;
         end;
      end;
   finally
      QryTemp.close;
   end;
end;

function TfQuality.GetDefectRecID: string;
begin
   result := '0';
   with QryTemp do
   begin
      close;
      Params.clear;
      Params.CreateParam(ftDateTime, 'TNOW', ptInput);
      commandText := 'SELECT TO_CHAR(:tnow,''YYYYMMDD'') || LPAD(SAJET.S_DEF_CODE.NEXTVAL,5,''0'') crecID FROM DUAL ';
      Params.ParamByName('TNOW').AsDateTime := G_SysDateTime;
      open;
      Result := FieldbyName('crecID').AsString;
      close;
   end;
end;

function TfQuality.InsertSNDefectTo109(psSN: string): Boolean;
var //S: string;
   I: integer;
   sDefectID: string;
begin
   result := false;
   try
      with QryData do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'CRECID', ptInput);
         Params.CreateParam(ftDateTime, 'TNOW', ptInput);
         Params.CreateParam(ftString, 'DEFECT_ID', ptInput);
         Params.CreateParam(ftString, 'EMP_ID', ptInput);
         Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
         commandText := ' INSERT INTO sajet.G_SN_DEFECT(recid,serial_number,work_order,model_id,rec_time, '
            + '        defect_id,terminal_id,process_id,stage_id,pdline_id,test_emp_id) '
            + ' SELECT :CRECID,SERIAL_NUMBER ,WORK_ORDER ,MODEL_ID,:TNOW , '
            + '        :DEFECT_ID,TERMINAL_ID,PROCESS_ID,STAGE_ID,PDLINE_ID,:EMP_ID '
            + '   FROM SAJET.G_SN_STATUS '
            + '  WHERE SERIAL_NUMBER = :SERIAL_NUMBER '
            + '    AND ROWNUM = 1 ';
         //if DefectList.Count > 0 then
         if lvEC.Items.Count > 0 then
         begin
            //for I := 0 to DefectList.Count - 1 do
            for I := 0 to lvEC.Items.Count - 1 do
            begin
               sDefectID := GetDefectRecID;
               //S := DefectList.Strings[I];
               //S := Copy(S, POS(',', S) + 1, Length(S) - POS(',', S));
               Params.ParamByName('CRECID').AsString := sDefectID;
               Params.ParamByName('TNOW').AsDateTime := G_SysDateTime;
               Params.ParamByName('DEFECT_ID').AsString := lvEC.Items[I].SubItems[2];//Copy(S, 1, POS(',', S) - 1);
               Params.ParamByName('EMP_ID').AsString := UpdateUserID;
               Params.ParamByName('SERIAL_NUMBER').AsString := psSN; //editSN.Text;
               Execute;
            end;
         end;
         result := true;
      end;
   finally
      QryData.close;
   end;
end;

function TfQuality.CheckSN(var psSN: string): Boolean;
begin
   Result := False;
   psSN := editSN.Text;
  // Check SN & 檢查工單是否一致
   try
      with QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
         CommandText := 'Select A.WORK_ORDER,A.WORK_FLAG,A.MODEL_ID,B.PART_NO,NVL(A.QC_NO,''N/A'') QC_NO  ' +
            ',NVL(A.QC_RESULT,''N/A'') QC_RESULT ,NVL(A.CARTON_NO,''N/A'') CARTON_NO,NVL(A.PALLET_NO,''N/A'') PALLET_NO,A.ROUTE_ID  ' +
            'From SAJET.G_SN_STATUS A, ' +
            'SAJET.SYS_PART B ' +
            'Where A.SERIAL_NUMBER = :SERIAL_NUMBER and ' +
            'A.MODEL_ID = B.PART_ID ';
         Params.ParamByName('SERIAL_NUMBER').AsString := editSN.Text;
         Open;
         if RecordCount <= 0 then
         begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
            CommandText := 'Select SERIAL_NUMBER, A.WORK_ORDER,A.WORK_FLAG,A.MODEL_ID,B.PART_NO,NVL(A.QC_NO,''N/A'') QC_NO  ' +
               ',NVL(A.QC_RESULT,''N/A'') QC_RESULT ,NVL(A.CARTON_NO,''N/A'') CARTON_NO,NVL(A.PALLET_NO,''N/A'') PALLET_NO,A.ROUTE_ID  ' +
               'From SAJET.G_SN_STATUS A, ' +
               'SAJET.SYS_PART B ' +
               'Where A.CUSTOMER_SN = :SERIAL_NUMBER and ' +
               'A.MODEL_ID = B.PART_ID ';
            Params.ParamByName('SERIAL_NUMBER').AsString := editSN.Text;
            Open;
            if Eof then
            begin
               MessageBeep(17);
               MessageDlg('Input Data error !!', mtError, [mbCancel], 0);
               Close;
               Exit;
            end;
            psSN := FieldByName('Serial_Number').AsString;
         end;
         if Fieldbyname('WORK_FLAG').AsString = '1' then
         begin
            MessageBeep(17);
            MessageDlg('Serial Number Srcap', mtError, [mbCancel], 0);
            Exit;
         end;
{         if LabWO.Caption <> '' then
            if LabWO.Caption <> Fieldbyname('WORK_ORDER').AsString then
            begin
               MessageBeep(17);
               MessageDlg('WORK ORDER Error !!', mtError, [mbCancel], 0);
               Exit;
            end;}

         if LabPart.Caption <> '' then
            if LabPart.Caption <> Fieldbyname('PART_NO').AsString then
            begin
               MessageBeep(17);
               MessageDlg('Model Error !!', mtError, [mbCancel], 0);
               Exit;
            end;
         //檢查流程
         if not checkRoute(psSN) then
         begin
            Exit;
         end;

         //if FieldByName('CARTON_NO').AsString ='N/A' then
         if FieldByName('PALLET_NO').AsString = 'N/A' then
         begin
            MessageBeep(17);
            MessageDlg('NO Pallet No !', mtWarning, [mbOK], 0);
            exit;
         end;

         if (Fieldbyname('QC_NO').AsString <> 'N/A') and (FieldByName('QC_RESULT').AsString = 'N/A') then
            if cmbQCLotNo.Text <> Fieldbyname('QC_NO').AsString then
            begin
               MessageBeep(17);
               MessageDlg('S/N QC Lot No IS :' + Fieldbyname('QC_NO').AsString + '!!', mtError, [mbCancel], 0);
               Exit;
            end;
         if not sbtnAddMore.Enabled then
         begin
            if slPallet.IndexOf(FieldByName('PALLET_NO').AsString) < 0 then
            begin
               MessageBeep(17);
               MessageDlg('Cann''t Add S/N!!', mtError, [mbCancel], 0);
               Exit;
            end;
         end
         else
         // 當每次要新加入一Pallet都必須作確認
         begin
            if slPallet.IndexOf(FieldByName('PALLET_NO').AsString) < 0 then
            begin
               MessageBeep(17);
               if MessageDLG('Add Pallet('+FieldByName('PALLET_NO').AsString+') into this QC Lot?',mtWarning,[mbOk,mbCancel],0) <> mrOk then
               begin
                  MessageBeep(17);
                  MessageDlg('Cann''t Add S/N!!', mtError, [mbCancel], 0);
                  Exit;
               end;
            end;
         end;
         LabWO.Caption := Fieldbyname('WORK_ORDER').AsString;
         LabPart.Caption := Fieldbyname('PART_NO').AsString;
         PartID := Fieldbyname('MODEL_ID').AsString;
         G_sCartonNo := FieldByName('CARTON_NO').AsString;
         G_sPalletNO := FieldBYName('PALLET_NO').AsString;
         G_sRouteID := FieldBYName('ROUTE_ID').AsString;
         Close;
      end;
      Result := True;
   finally
      QryTemp.Close;
   end;
end;

function TfQuality.CheckRoute(psSN: string): Boolean;
var sRes: string;
begin
  // Check Route
   result := true;
   with SProc do
   begin
      try
         Close;
         DataRequest('SAJET.SJ_CKRT_ROUTE');
         FetchParams;
         Params.ParamByName('TERMINALID').AsString := TerminalID;
         Params.ParamByName('TSN').AsString := psSN; //editSN.Text;
         Execute;
         sRes := Params.ParamByName('TRES').AsString;
      except
      end;
      Close;
   end;
   if sRes <> 'OK' then
   begin
      MessageBeep(17);
      MessageDlg('ROUTE ERROR , ' + sRes, mtError, [mbCancel], 0);
      result := false;
   end;
end;

function TfQuality.checkDefaultSamplingPlan: Boolean;
begin
  // Check Route
   result := true;
   try
      with QryTemp do
      begin
         Close;
      // 讀取 Sampling Plan 預設
         Params.Clear;
         Params.CreateParam(ftString, 'PN', ptInput);
         CommandText := ' SELECT A.ENABLED ,B.SAMPLING_ID ,C.SAMPLING_TYPE '
            + ' FROM SAJET.SYS_PART A  '
            + '     ,SAJET.SYS_QC_SAMPLING_DEFAULT B '
            + '     ,SAJET.SYS_QC_SAMPLING_PLAN C '
            + '  WHERE A.PART_NO =:PART_NO '
            + '    AND A.PART_ID = B.PART_ID '
            + '    AND B.SAMPLING_ID = C.SAMPLING_ID ';
         Params.ParamByName('PART_NO').AsString := LabPart.Caption;
         Open;
         if eof then
         begin
            MessageBeep(17);
            MessageDlg('Part No :' + LabPart.Caption + 'Sampling Plan not Define !!', mtError, [mbCancel], 0);
            result := false;
         end
         else
         begin
            if FieldByName('ENABLED').AsString <> 'Y' then
            begin
               MessageBeep(17);
               MessageDlg('Part No :' + LabPart.Caption + 'Sampling Plan Disabled !!', mtError, [mbCancel], 0);
               result := false;
            end
            else
               LabInspType.Caption := FieldByName('SAMPLING_TYPE').AsString;
         end;
      end;
   finally
      QryTemp.Close;
   end;
end;

function TfQuality.CheckSN_InQC(psSN: string): Boolean;
begin
  // Check Route
   result := true;
   try
      with QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'QCNO', ptInput);
         Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
         CommandText := 'Select SERIAL_NUMBER '
            + '  From SAJET.G_QC_SN '
            + ' Where QC_LOTNO = :QCNO '
            + '   and Serial_Number = :SERIAL_NUMBER '
            + '   and QC_CNT =:QC_CNT '
            + '   and Rownum = 1 ';
         Params.ParamByName('QCNO').AsString := cmbQCLotNo.Text;
         Params.ParamByName('SERIAL_NUMBER').AsString := psSN; //editSN.Text ;
         Params.ParamByName('QC_CNT').AsString := lablInspTimes.Caption;
         Open;
         if RecordCount > 0 then
         begin
            result := False;
            MessageBeep(17);
            MessageDlg('Inspect Serial Number Duplicate !!', mtError, [mbCancel], 0);
         end;
      end;
   finally
      QryTemp.Close;
   end;
end;

function TfQuality.InputData: Boolean;
var Temp, sSN: string;
begin
   if Trim(cmbQCLotNo.Text) = '' then
   begin
      MessageBeep(17);
      MessageDlg('QC Lot No error !!', mtError, [mbCancel], 0);
      Exit;
   end;
   if UpperCase(editSN.Text) = 'UNDO' then
   begin
      ClearData;
      GetQCData(lablInspTimes.Caption);
      //DefectList.Clear;
      lvEC.Items.Clear;
      editSN.SetFocus;
      editSN.SelectAll;
      Exit;
   end;
  // 檢查是否為 Defect Code
   if CheckDefect(editSN.Text) then
   begin
      editSN.SetFocus;
      editSN.SelectAll;
      Exit;
   end;
  // 檢查是否為 SN 與流程
   if not CheckSN(sSN) then Exit;
 // 檢查序號在當次是否已檢驗過
   if not CheckSN_InQC(sSN) then exit;
  //檢查DEFAULT的抽驗計畫
   if LabInspType.Caption = 'N/A' then
      if not checkDefaultSamplingPlan then exit;

   with qryTemp do
   begin
     Close;
     Params.Clear;
     CommandText:='Select Sysdate From Dual';
     open;
     G_SysDateTime:=FieldByName('Sysdate').asDateTime;
     close;
   end;

   UpdateSN(sSN);
   InsertQCSN(sSN);
   UpdateQCLot(1);
   InsertSNDefect(sSN);
   InsertSNDefectTo109(sSN);
   //抽驗時只填Pass or Fail Qty;最後整批PASS時才填OUTPUT QTY
   //if DefectList.Count=0 then
   if lvEC.Items.Count=0 then
   begin
     if not UpdateSNCount(sSN,'0',1,0,0) then
       exit
   end else
   begin
     if not UpdateSNCount(sSN,'1',0,1,0) then
       exit;
   end;
   //DefectList.Clear;
   lvEC.Items.Clear;
  // 重新顯示資料
   ClearData;
   GetQCData(lablInspTimes.Caption);
   if GetSamplingPlan(LabInspType.Caption) = '0' then exit;
   CheckSamplingPlan;
   editSN.SetFocus;
   editSN.SelectAll;
end;

function TfQuality.GetQCLotNo: Boolean;
begin
   Result := False;
   cmbQCLotNo.Text := '';
   cmbQCLotNo.Items.Clear;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'TERMINALID', ptInput);
      CommandText := 'Select a.QC_LOTNO '
         + 'From SAJET.G_QC_LOT A, '
         + '(select qc_lotno, max(ng_cnt) ng_cnt from sajet.g_qc_lot '
         + 'Where TERMINAL_ID = :TERMINALID group by qc_lotno) b '
         + 'where a.qc_lotno = b.qc_lotno '
         + 'and a.ng_cnt = b.ng_cnt '
         + 'and NVL(QC_RESULT,''N/A'') not in (''0'',''2'') ' //2:CSP Hold(for GSP)
         + 'group  By a.QC_LOTNO';
      Params.ParamByName('TERMINALID').AsString := TerminalID;
      Open;
      while not Eof do
      begin
         cmbQCLotNo.Items.Add(Fieldbyname('QC_LOTNO').AsString);
         Next;
      end;
      Close;
   end;
   Result := True;
end;

function TfQuality.GetTerminalID: Boolean;
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
      CommandText := 'Select A.PROCESS_ID,A.TERMINAL_NAME,B.PROCESS_NAME,C.PDLINE_NAME ,D.STAGE_NAME '+
                     '      ,A.PDLINE_ID '+
                     'From  SAJET.SYS_TERMINAL A,'+
                          ' SAJET.SYS_PROCESS B, '+
                          ' SAJET.SYS_STAGE D, '+
                          ' SAJET.SYS_PDLINE C '+
                      'Where   A.TERMINAL_ID = :TERMINALID '
                        +  ' AND A.PROCESS_ID = B.PROCESS_ID '
                        +'   AND A.STAGE_ID = D.STAGE_ID '
                        +  ' AND A.PDLINE_ID = C.PDLINE_ID ';

      Params.ParamByName('TERMINALID').AsString := TerminalID;
      Open;
      if RecordCount <= 0 then
      begin
         Close;
         MessageBeep(17);
         MessageDlg('Terminal data error !!', mtError, [mbCancel], 0);
         Exit;
      end;
      LabTerminal.Caption := Fieldbyname('PROCESS_NAME').AsString + ' ' +
         Fieldbyname('TERMINAL_NAME').AsString;

      lablProcess.Caption := FieldbyName('Process_Name').AsString;
      lablTerminal.Caption := FieldByName('Terminal_Name').AsString;
      Close;
   end;
   Result := True;
end;

procedure TfQuality.sbtnCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TfQuality.FormShow(Sender: TObject);
begin

   LabWO.Caption := '';
   LabPart.Caption := '';
   if not GetTerminalID then Exit;
   //DefectList := TStringList.Create;
   GetPlace(TerminalID, G_pline, G_pstage, G_pprocess);
   slPallet := TStringList.Create;
   GetQCLotNo;
   GetAllDefect;
   if UpdateUserID <> '0' then
      SetStatusbyAuthority;
end;
function TfQuality.GetWorkStaionOption(var bPassClear,bRejectClear:Boolean):boolean;
begin
  result := False;
  bPassClear := False;
  bRejectClear := False;
  With QryTemp do
  begin
    try
       Close;
       Params.Clear;
       Params.CreateParam(ftString	,'MODULE_NAME', ptInput);
       Params.CreateParam(ftString	,'FUNCTION_NAME', ptInput);
       Params.CreateParam(ftString	,'TERMINALID', ptInput);
       CommandText := 'SELECT * '+
                      'FROM SAJET.SYS_MODULE_PARAM '+
                      'WHERE MODULE_NAME = :MODULE_NAME AND '+
                            'FUNCTION_NAME = :FUNCTION_NAME AND '+
                            'PARAME_NAME = :TERMINALID ';
       Params.ParamByName('MODULE_NAME').AsString := 'Quality Control';
       Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
       Params.ParamByName('TERMINALID').AsString := TerminalID;
       Open;
       While not Eof do
       begin
          If Fieldbyname('PARAME_ITEM').AsString = 'Clear QC Data' Then
             bPassClear := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
          If Fieldbyname('PARAME_ITEM').AsString = 'Clear QC Data After Reject' Then
             bRejectClear := (Fieldbyname('PARAME_VALUE').AsString = 'Y');

          Next;
       end;
       result := True;
     finally
       Close;
     end;  
  end;
end;

procedure TfQuality.sbtnNewLotClick(Sender: TObject);
var S: string;
begin
   if MessageDlg('Add New Lot No?', mtConfirmation, [mbYes, mbNo], 1) = mrYes then
   begin
  // 取新的 Lot No
  //SAJET.G_QC_LOT的index要取消
      with QryTemp do
      begin
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
            S := Fieldbyname('SNID').AsString;
         Close;
      end;
      InsertNewLotNO(S);
      cmbQCLotNo.ItemIndex := cmbQCLotNo.Items.IndexOf(S);
      ImgReject.Visible := False;
      ImgPass.Visible := False;
      ImgWaive.Visible := False;
      sbtnAddMore.Enabled := True;
      Label21.Visible := not ImgPass.Visible;
      sbtnPass.Enabled := ImgPass.Visible;
      Label23.Visible := not ImgReject.Visible;
      sbtnWaive.Enabled := ImgWaive.Visible;
      Label25.Visible := not ImgWaive.Visible;
      editSN.SetFocus;
   end;
end;

function TfQuality.InsertNewLotNO(LotNo: string): Boolean;
begin
 // Insert Lot No to SAJET.G_QC_LOT
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'QC_LOTNO', ptInput);
      Params.CreateParam(ftString, 'INSP_EMPID', ptInput);
      Params.CreateParam(ftString, 'TERMINALID', ptInput);
      Params.CreateParam(ftString, 'NG_CNT', ptInput);
      CommandText := 'Insert Into SAJET.G_QC_LOT ' +
         '(QC_LOTNO,PDLINE_ID,STAGE_ID,PROCESS_ID,TERMINAL_ID,INSP_EMPID,NG_CNT ) ' +
         ' Select :QC_LOTNO QC_LOTNO,PDLINE_ID,STAGE_ID,PROCESS_ID,TERMINAL_ID,:INSP_EMPID INSP_EMPID,:NG_CNT ' +
         'From SAJET.SYS_TERMINAL ' +
         'Where TERMINAL_ID = :TERMINALID';
      Params.ParamByName('QC_LOTNO').AsString := LotNo;
      Params.ParamByName('INSP_EMPID').AsString := UpdateUserID;
      Params.ParamByName('TERMINALID').AsString := TerminalID;
      Params.ParamByName('NG_CNT').AsString := '1';
      Execute;
   end;
   GetQCLotNo;
   //DefectList.Clear;
   lvEC.Items.Clear;
   lablInspTimes.Caption := '1';
   LabInspType.Caption := 'N/A';
   LabWO.Caption := '';
   LabPart.Caption := '';
   ClearData;
end;

procedure TfQuality.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   //DefectList.Free;
   slPallet.Free;
end;

procedure TfQuality.editSNKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then
   begin
      InputData;
      editSN.SetFocus;
      editSN.SelectAll;
   end;
end;

procedure TfQuality.cmbQCLotNoChange(Sender: TObject);
var sQCCNT: string;
begin
   //DefectList.Clear;
   lvEC.Items.Clear;
   LabWO.Caption := '';
   LabPart.Caption := '';
   ImgReject.Visible := False;
   ImgPass.Visible := False;
   ImgWaive.Visible := False;
   LabInspType.Caption := 'N/A';
   lablInspTimes.Caption := '1';
   ClearData;
   sbtnAddMore.Enabled := True;
   with QryTemp do
   begin
    // 目前檢驗批的基本資料
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'QC_LOTNO', ptInput);
      Params.CreateParam(ftString, 'QC_LOTNO1', ptInput);

      CommandText := ' select NG_CNT,QC_RESULT,SAMPLING_PLAN_ID ,LOT_SIZE, SAMPLING_SIZE, WORK_ORDER, Part_No, MODEL_ID '
         + ' from SAJET.G_QC_LOT a, sajet.sys_part b '
         + '  WHERE  QC_LOTNO =:QC_LOTNO '
         + '    AND NG_CNT =( select Max(NG_CNT) from SAJET.G_QC_LOT '
         + '                  where QC_LOTNO =:QC_LOTNO1 ) '
         + '    and a.model_id = b.part_id(+) '
         + '    AND ROWNUM = 1 ';

      Params.ParamByName('QC_LOTNO').AsString := cmbQCLotNo.Text;
      Params.ParamByName('QC_LOTNO1').AsString := cmbQCLotNo.Text;
      Open;
      if eof then exit;
      sbtnAddMore.Enabled := False;
      if FieldByName('QC_RESULT').AsString = 'N/A' then
      begin
         sQCCNT := FieldByName('NG_CNT').AsString;
         if FieldByName('NG_CNT').AsString = '1' then
         begin
            sbtnAddMore.Enabled := True;
         end;
         LabChkQty.Caption := Fieldbyname('SAMPLING_SIZE').AsString;
      end
      else if FieldByName('QC_RESULT').AsString = '1' then
      begin
         sQCCNT := IntTostr(FieldByName('NG_CNT').AsInteger + 1);
         LabChkQty.Caption := '0';
      end
      else
      begin
         MessageBeep(17);
         MessageDlg('QC LOT NO STATUS ERROR!', mtWarning, [mbOK], 0);
         close;
         exit;
      end;

      lablInspTimes.Caption := sQCCNT;
      if FieldByName('LOT_SIZE').AsInteger > 0 then
         LabInspType.Caption := FieldByName('SAMPLING_PLAN_ID').AsString
      else
         LabInspType.Caption := 'N/A';
      ClearData;
      LabWO.Caption := Fieldbyname('WORK_ORDER').AsString;
      LabPart.Caption := Fieldbyname('PART_NO').AsString;
      LabTotQty.Caption := Fieldbyname('LOT_SIZE').AsString;
      PartID := Fieldbyname('MODEL_ID').AsString;
      GetQCData(sQCCNT);
      if LabInspType.Caption <> 'N/A' then
      begin
         close;
         Params.Clear;
         Params.CreateParam(ftString, 'SAMPLING_ID', ptInput);

         CommandText := ' SELECT SAMPLING_TYPE from SAJET.SYS_QC_SAMPLING_PLAN '
            + '  WHERE SAMPLING_ID =:SAMPLING_ID '
            + '   AND ROWNUM = 1 ';

         Params.ParamByName('SAMPLING_ID').AsString := LabInspType.Caption;
         Open;
         if eof then
         begin
            MessageBeep(17);
            MessageDlg('Sampling Plan not Found ' + '(' + LabInspType.Caption + ') !', mtWarning, [mbOK], 0);
            LabInspType.Caption := 'N/A';
         end
         else
         begin
            LabInspType.Caption := FieldByName('SAMPLING_TYPE').AsString;
            if GetSamplingPlan(LabInspType.Caption) <> '0' then
               CheckSamplingPlan;
         end;
      end;
      editSN.SetFocus;
      close;
   end;
end;

function TfQuality.GetPallet: string;
var I: Integer;
    ssPallet: TStrings;
begin
   ssPallet := TStringList.Create;
   for I := 0 to LvPallet.Items.Count - 1 do
     if ssPallet.IndexOf(LvPallet.Items[i].Caption) = -1 then
        ssPallet.Add(LvPallet.Items[i].Caption);
   Result := '''' + ssPallet[0] + '''';
   for I := 1 to ssPallet.Count - 1 do
     Result := Result + ',''' + ssPallet[I] + '''';
   ssPallet.Free;
end;


function TfQuality.GetPriorProcess: string;
var I: Integer;
begin
   result := 'N/A';
   with QryTemp do
   begin
      close;
      Params.clear;
      Params.CreateParam(ftString, 'QC_NO', ptInput);
      Params.CreateParam(ftString, 'PROCESS_ID', ptInput);
      commandText := '   SELECT PROCESS_ID  FROM SAJET.SYS_ROUTE_DETAIL A '
         + '    WHERE A.ROUTE_ID=(SELECT ROUTE_ID FROM SAJET.G_SN_STATUS       '
         + '                     WHERE QC_NO = :QC_NO AND ROWNUM = 1 ) '
         + '      AND A.NEXT_PROCESS_ID =:PROCESS_ID ';
      Params.ParamByName('PROCESS_ID').AsString := G_pprocess;
      Params.ParamByName('QC_NO').AsString := cmbQCLotNo.Text;
      open;
      Result := '''' + FieldByName('PROCESS_ID').AsString + '''';
      Next;
      while not eof do
      begin
         Result := Result + ',''' + FieldByName('PROCESS_ID').AsString + '''';
         next;
      end;
      close;
   end;
end;

procedure TfQuality.sbtnPassClick(Sender: TObject);
var sResult, sRes: string;
   sSamplingTypeID: string;
   sPalletNo: string;
   sPriorProcess: string;
   I: Integer;
   iLotSize, iPassQty, iWoCanOutputQty: Integer;
   bPassClear,bRejectclear:Boolean;
begin
   if LvPallet.Items.Count <= 0 then
      Exit;

   if LabChkQty.Caption = '0' then exit;
  //檢查抽驗計畫
   sSamplingTypeID := GetSamplingPlan(LabInspType.Caption);
  //抽驗計畫不存在則離開
   if sSamplingTypeID = '0' then exit;

   for I := 0 to LvPallet.Items.Count - 1 do
   begin
      if LvPallet.Items[I].Caption = 'N/A' then
      begin
         MessageBeep(17);
         MessageDlg('Carton No : ' + LvPallet.Items[I].SubItems[0] + ' , NO Pallet!', mtWarning, [mbOK], 0);
         exit;
      end;
   end;

   sResult := InttoStr((Sender as TSpeedButton).Tag);

  //檢查所有PALLET是否都已裝滿
   sPalletNO := GetPallet;
   sPriorProcess := GetPriorProcess;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select Pallet_No,CLose_Flag ' +
         'From SAJET.G_PACK_PALLET ' +
         'Where Pallet_No in ( ' + sPalletNO + ')';
      Open;
      while not Eof do
      begin
         if FieldByName('CLose_Flag').Asstring = 'N' then
         begin
            MessageBeep(17);
            MessageDlg(FieldByName('Pallet_No').AsString + ' not full !!', mtWarning, [mbOK], 0);
            Exit;
         end;
         Next;
      end;
   end;

   if sResult = '0' then
   begin
      with QryTemp do
      begin
      //PASS時,檢查是否有維修未完成
         Close;
         Params.Clear;
         //Params.CreateParam(ftString, 'RES', ptInput);
         //Params.CreateParam(ftString, 'QC_NO', ptInput);
         CommandText := 'SELECT SERIAL_NUMBER FROM  SAJET.G_SN_STATUS ' +
            //' Where QC_NO = :QC_NO ' +
            ' Where PALLET_NO IN (' + sPalletNo + ') '+
            '   AND CURRENT_STATUS =''1'' ' +
            '   AND ROWNUM = 1 ';
         //Params.ParamByName('QC_NO').AsString := cmbQCLotNo.Text;
         Open;
         if not eof then
         begin
            MessageBeep(17);
            MessageDlg(' S/N : ' + FieldByName('Serial_Number').AsString + ' Not Repair OK ', mtInformation, [mbOK], 0);
            close;
            exit;
         end;
      end;
   end;

    //檢查所有PALLET內的序號是否流程皆正確
   If (sResult = '0') or (sResult = '2') then
   begin
      try
         with QryTemp do
         begin
            Close;
            Params.Clear;
            //Params.CreateParam(ftString, 'QCNO', ptInput);
            Params.CreateParam(ftString, 'PROCESS_ID', ptInput);
            CommandText := ' SELECT SERIAL_NUMBER FROM SAJET.G_SN_STATUS'
               //+ '  WHERE  QC_NO = :QCNO '
               + '  Where Pallet_No in (' + sPalletNO + ') '
               + '    AND  ( PROCESS_ID NOT IN ( ' + sPriorProcess + ')  AND  NEXT_PROCESS<>:PROCESS_ID ) ';
            If sResult = '2' then
               CommandText := CommandText
                            + ' And Current_Status = ''0'' ';
            CommandText := CommandText
                         + '    AND ROWNUM = 1 ';
            //Params.ParamByName('QCNO').AsString := cmbQCLotNo.Text;
            Params.ParamByName('PROCESS_ID').AsString := G_pprocess;
            open;
            if not eof then
            begin
               MessageBeep(17);
               MessageDlg('S/N :' + FieldByName('Serial_Number').AsString + ' Route Error !', mtWarning, [mbOK], 0);
               exit;
            end;
         end;
      finally
         QryTemp.close;
      end;
   end;

   if not confirmResult(sPalletNo, sResult) then Exit;

   GetWorkStaionOption(bPassClear,bRejectClear);//取得QC站別的設定; 是否要清除QCLOTNO,PALLET,CARTON
  //將pallet內的序號qc_no更新
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'QCNO', ptInput);
      CommandText := 'Update SAJET.G_SN_STATUS ' +
                     '   Set QC_NO = :QCNO ' +
                     ' Where Pallet_No in ( ' + sPalletNO + ')';
      Params.ParamByName('QCNO').AsString := cmbQCLotNo.Text;
      Execute;
   end;

   //如果是特採，不良品不納入Lot Size計算
   If sResult = '2' then
   begin
      with QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'QCNO', ptInput);
         CommandText := 'Update SAJET.G_SN_STATUS '
                      + '   SET CARTON_NO = ''N/A'' '
                      + '      ,PALLET_NO = ''N/A'' '
                      + '      ,QC_NO = ''N/A'' '
                      + '      ,QC_RESULT = ''N/A''  '
                      + ' Where QC_NO = :QCNO '
                      + '   And (Current_Status = ''1'' '
                      + '    or Work_Flag = ''1'') ';
         Params.ParamByName('QCNO').AsString := cmbQCLotNo.Text;
         Execute;
      end;
   end;

  //找整個LOT內的數量
   with qryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'QC_NO', ptInput);
      CommandText := ' Select Count(*) LotSize from sajet.g_sn_status '
                   + '  where QC_NO =:QC_NO ';
      Params.ParamByName('QC_NO').AsString := cmbQCLotNo.Text;
      open;
      iLotSize := FieldByName('LotSize').AsInteger;
   end;

   //if sResult = '0' then
   If (sResult = '0') or (sResult = '2') then
   begin
      //更改g_sn_status的過站記錄
      with QryTemp do
      begin
         close;
         Params.Clear;
         Params.CreateParam(ftString, 'PDLINE_ID', ptInput);
         Params.CreateParam(ftString, 'STAGE_ID', ptInput);
         Params.CreateParam(ftString, 'PROCESS_ID', ptInput);
         Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
         Params.CreateParam(ftString, 'Result', ptInput);
         Params.CreateParam(ftString, 'EMP_ID', ptInput);
         Params.CreateParam(ftString, 'WIP_PROCESS', ptInput);
         Params.CreateParam(ftString, 'QC_NO', ptInput);

         CommandText := ' Update SAJET.G_SN_STATUS '
            + '    SET NEXT_PROCESS =''0'' '
            + '       ,PDLINE_ID =:PDLINE_ID'
            + '       ,STAGE_ID =:STAGE_ID '
            + '       ,PROCESS_ID =:PROCESS_ID '
            + '       ,TERMINAL_ID =:TERMINAL_ID '
            + '       ,IN_PROCESS_TIME = OUT_PROCESS_TIME '
            + '       ,OUT_PROCESS_TIME = SYSDATE '
            + '       ,QC_RESULT = :Result '
            + '       ,EMP_ID  = :EMP_ID '
            + '       ,wip_process = :WIP_PROCESS '
            + '  WHERE QC_NO = :QC_NO ';
         Params.ParamByName('PDLINE_ID').AsString := G_pline;
         Params.ParamByName('STAGE_ID').AsString := G_pstage;
         Params.ParamByName('PROCESS_ID').AsString := G_pprocess;
         Params.ParamByName('TERMINAL_ID').AsString := TerminalID;
         Params.ParamByName('Result').AsString := sResult;
         Params.ParamByName('EMP_ID').AsString := UpdateUserID;
         Params.ParamByName('wip_process').AsString := GET_NEXTPROCESS(G_sRouteID,G_pprocess,'0');
         Params.ParamByName('QC_NO').AsString := cmbQCLotNo.Text;
         Execute;
      end;

    //若是工單的最後一站.則將數量加入工單的output數中

      with QryTemp do
      begin
         close;
         Params.Clear;
         Params.CreateParam(ftString, 'QC_NO', ptInput);
         commandText := '  SELECT WORK_ORDER '
            + '    FROM SAJET.G_SN_STATUS '
            + '   WHERE QC_NO = :QC_NO '
            + '   GROUP BY WORK_ORDER ';
         Params.ParamByName('QC_NO').AsString := cmbQCLotNo.Text;
         Open;
         while not EOF do
         begin
            ModifyWOInfo(FieldByName('Work_Order').AsString,cmbQCLotNo.Text);
            Next;
         end;
         Close;
      end; //WITH
      with SProc do
      begin
         try
            begin
               Close;
               DataRequest('SAJET.SJ_QC_GO');
               FetchParams;
               Close;
               FetchParams;
               Params.ParamByName('tQcNo').AsString := cmbQCLotNo.Text;
               Execute;
               Close;
            end;
         except
         end;
         Close;
      end;
      //寫到G_SN_TRAVEL
      with QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'QC_NO', ptInput);
         CommandText := ' INSERT INTO SAJET.G_SN_TRAVEL '
            + ' SELECT * FROM SAJET.G_SN_STATUS '
            + '  Where QC_NO = :QC_NO ';
         Params.ParamByName('QC_NO').AsString := cmbQCLotNo.Text;
         Execute;
         Close;
      end;
   end;
  //Reject 時,可原批重批,故原批內的序號可再回本站
   if sResult = '1' then
   begin
      with QryTemp do
      begin
         close;
         Params.Clear;
         Params.CreateParam(ftString, 'QC_NO', ptInput);
         CommandText := 'UPDATE SAJET.G_SN_STATUS '
            + '   SET QC_RESULT =''1'' '
            + ' WHERE QC_NO =:QC_NO ';
         Params.ParamByName('QC_NO').AsString := cmbQCLotNo.Text;
         Execute;
      end;
   end;

    //add by rita 2005/11/09==================================================
   if (bPassClear) or (bRejectClear) then
   begin
      with QryTemp do
      begin
        try
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'QC_NO', ptInput);
          CommandText := ' UPDATE SAJET.G_SN_STATUS '
                        +'    SET QC_NO =''N/A'' '
                        +'       ,QC_RESULT =''N/A'' '
                        +'       ,CARTON_NO =''N/A'' '
                        +'       ,PALLET_NO =''N/A'' '
                        + '  Where QC_NO = :QC_NO ';
          Params.ParamByName('QC_NO').AsString := cmbQCLotNo.Text;
          Execute;
        finally
          Close;
        end;
      end;
   end;
    //========================================================================

  // Update SAJET.G_QC_LOT.QC_RESULT
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RES', ptInput);
      Params.CreateParam(ftString, 'QC_NO', ptInput);
      Params.CreateParam(ftString, 'NG_CNT', ptInput);
      Params.CreateParam(ftString, 'SAMPLING_PLAN_ID', ptInput);
      Params.CreateParam(ftString, 'INSP_EMPID', ptInput);
      //Params.CreateParam(ftInteger, 'LOT_SIZE', ptInput);

      CommandText := 'Update SAJET.G_QC_LOT ' +
         'Set QC_RESULT = :RES ' +
         '   ,END_TIME = SYSDATE ' +
         '   ,SAMPLING_PLAN_ID = :SAMPLING_PLAN_ID ' +
         '   ,INSP_EMPID = :INSP_EMPID ' +
         //'   ,LOT_SIZE = :LOT_SIZE ' +  2005/7/29 mark
         'Where QC_LOTNO = :QC_NO ' +
         '  AND NG_CNT =:NG_CNT ';
      Params.ParamByName('RES').AsString := sResult;
      Params.ParamByName('QC_NO').AsString := cmbQCLotNo.Text;
      Params.ParamByName('NG_CNT').AsString := lablInspTimes.Caption;
      Params.ParamByName('SAMPLING_PLAN_ID').AsString := sSamplingTypeID;
      Params.ParamByName('INSP_EMPID').AsString := UpdateUserID;
      //Params.ParamByName('LOT_SIZE').AsInteger := iLotSize;
      Execute;
   end;

   //DefectList.Clear;
   lvEC.Items.Clear;
   LabWO.Caption := '';
   LabPart.Caption := '';
   ImgReject.Visible := False;
   ImgPass.Visible := False;
   ImgWaive.Visible := False;
   LabInspType.Caption := 'N/A';
   lablInspTimes.Caption := '1';
   ClearData;
   GetQCLotNo;
end;

procedure TfQuality.sbtnAQLClick(Sender: TObject);
begin
   if cmbQCLotNo.Text = '' then
      Exit;
   with TfAQL.Create(Self) do
   begin
      editQCLot.Text := cmbQCLotNo.Text;
      GetAllPlan;
      //If Showmodal = mrOK Then
      showmodal;
      Free;
   end;
end;

procedure TfQuality.sbtnAddMoreClick(Sender: TObject);
begin
   if LabWO.Caption = '' then Exit;

   fData := TfData.Create(Self);
   with fData do
   begin
      LabType1.Caption := 'Add More Pallet for QC NO : ' + cmbQCLotNo.Text;
      LabType2.Caption := LabType1.Caption;
      lablWorkOrder.Caption := LabWO.Caption;
      lablModel.Caption := LabPart.Caption;
      if ShowModal = mrOK then
      begin
         ClearData;
         GetQCData(lablInspTimes.Caption);
         GetSamplingPlan(LabInspType.Caption);
      end;
      Free;
   end;
end;

procedure TfQuality.PopupMenu1Popup(Sender: TObject);
begin
   pitemRemove.Enabled := False;
   if sbtnAddMore.Enabled then
   begin
      if (lvPallet.Selected <> nil) and (not checkPallet_InQC(lvPallet.Selected.Caption)) then
         pitemRemove.Enabled := True;
   end;
end;

function TfQuality.checkPallet_InQC(psPalletNO: string): Boolean;
begin
   Result := True;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT CUSTOMER_SN '
         + '  FROM SAJET.G_SN_STATUS A, '
         + '       SAJET.G_QC_SN B '
         + ' WHERE A.PALLET_NO = ''' + psPalletNO + ''' '
         + '   AND B.QC_LOTNO = ''' + cmbQCLotNo.Text + ''' '
                   //+ '   AND B.QC_CNT = ''' + lablInspTimes.Caption + ''' '
      + '   AND A.SERIAL_NUMBER = B.SERIAL_NUMBER ';
      Open;
      if Eof then
         Result := False;
      Close;
   end;
end;

procedure TfQuality.pitemRemoveClick(Sender: TObject);
begin
   if MessageDlg('Remove Pallet No - ' + lvPallet.Selected.Caption + #13#13#10 +
      'Ary you sure ?? ', mtConfirmation, [mbOK, mbCancel], 0) = mrOK then
   begin
      with qryTemp do
      begin
        Close;
        Params.Clear;
        CommandText:='Select Sysdate From Dual';
        open;
        G_SysDateTime:=FieldByName('Sysdate').asDateTime;
        close;
      end;

      updateQCLot_Pallet(lvPallet.Selected.Caption, 'N/A');
      UpdateQCLot(0);
//      updateLotSize;
      ClearData;
      GetQCData(lablInspTimes.Caption);
      GetSamplingPlan(LabInspType.Caption);
   end;
end;

procedure TfQuality.updateQCLot_Pallet(psPalletNO, psLotNo: string);
begin
   with fQuality.QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'UPDATE SAJET.G_SN_STATUS '
         + '   SET QC_NO = ''' + psLotNo + ''' '
         + ' WHERE PALLET_NO = ''' + psPalletNO + ''' ';
      Execute;
   end;
end;

function TfQuality.GET_NEXTPROCESS(prouteid, pprocessid, presult: string):string;
begin
  Result:='0';
  with SProc do
  begin
     try
        begin
           Close;
           DataRequest('SAJET.SJ_GET_NEXTPROCESS');
           FetchParams;
           Close;
           FetchParams;
           Params.ParamByName('prouteid').AsString := prouteid;
           Params.ParamByName('pprocessid').AsString := pprocessid;
           Params.ParamByName('presult').AsString := presult;
           Execute;
           Result := Params.ParamByName('pnextprocess').AsString;
           Close;
        end;
     except
     end;
     Close;
  end;
end;

procedure TfQuality.ModifyWOInfo(WO, QC: String);
var
   iWoCanOutputQty, iPassQty: Integer;
begin
    //若是工單的最後一站.則將數量加入工單的output數中

      with QryTemp2 do
      begin
         close;
         Params.Clear;
         Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
         commandText := '  SELECT END_PROCESS_ID ,NVL(TARGET_QTY,0)-NVL(OUTPUT_QTY,0) CAN_OUTPUT_QTY '
            + '    FROM SAJET.G_WO_BASE '
            + '   WHERE WORK_ORDER = :WORK_ORDER '
            + '     AND ROWNUM = 1 ';
         Params.ParamByName('WORK_ORDER').AsString := WO;
         Open;
         if not eof then
         begin
        //工單剩餘可產出數
            iWoCanOutputQty := FieldByName('CAN_OUTPUT_QTY').AsInteger;
            if FieldByName('END_PROCESS_ID').AsString = G_pprocess then
            begin
          //從sn_travel中找出REPAS的數量
               close;
               Params.clear;
               Params.CreateParam(ftString, 'WO', ptInput);
               Params.CreateParam(ftString, 'QC_NO', ptInput);
               commandtext := ' select nvl(count(*),0) PaSSQty '
                  + '   from sajet.g_sn_status '
                  + '        where qc_no = :qc_no '
                  + '   and work_order = :wo '
                  + '   and out_pdline_time is null';
{               commandtext := ' select nvl(count(*),0) RePaSSQty '
                  + '   from sajet.g_sn_travel '
                  + '  where (serial_number,work_order,process_id ) '
                  + '  in ( Select serial_number,work_order,Process_id '
                  + '         from sajet.g_sn_status '
                  + '        where qc_no = :qc_no ) '; }
               Params.ParamByName('QC_NO').AsString := QC;
               Params.ParamByName('WO').AsString := WO;
               open;
//               iRepassQty := FieldByName('RePassQty').AsInteger;
               iPassQty := FieldByName('PassQty').AsInteger;
          //累加工單的產出數
               close;
               Params.clear;
               Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
               Params.CreateParam(ftInteger, 'OUTPUT_QTY', ptInput);
               commandtext := ' Update sajet.g_wo_base '
                  + '   set  output_qty = nvl(output_qty,0) + :output_qty '
                  + '  where work_order =:work_order ';
               Params.ParamByName('WORK_ORDER').AsString := WO;
               Params.ParamByName('OUTPUT_QTY').AsInteger := iPassQty;
//               Params.ParamByName('OUTPUT_QTY').AsInteger := iLotSize - iRepassQty;
               Execute;
          //如果產出數大於等於工單可產出數,則將工單close
//               if iLotSize - iRepassQty >= iWoCanOutputQty then
               if iPassQty >= iWoCanOutputQty then
               begin
                  close;
                  Params.Clear;
                  Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
                  Params.CreateParam(ftString, 'update_userid', ptInput);
                  commandtext := ' Update sajet.g_wo_base '
                     + '   set  wo_close_date = sysdate  '
                     + '       ,wo_status =''6'' '
                     + '       ,output_qty = target_qty '
                     + '       ,update_userid =:update_userid '
                     + '  where work_order =:work_order ';
                  Params.ParamByName('WORK_ORDER').AsString := WO;
                  Params.ParamByName('update_userid').AsString := UpdateUserID;
                  Execute;

            //工單狀態變更,Copy至G_HT_WO_BASE
                  Close;
                  Params.Clear;
                  CommandText := 'INSERT INTO SAJET.G_HT_WO_BASE '
                     + ' SELECT * FROM SAJET.G_WO_BASE '
                     + '  WHERE WORK_ORDER = ''' + WO + ''' ';
                  Execute;
               end;
          //更新sn_travel中的out_pdline_time
               close;
               Params.clear;
               Params.CreateParam(ftInteger, 'QC_NO', ptInput);
               commandtext := ' Update sajet.g_sn_status '
                  + '   set  out_pdline_time = sysdate '
                  + '   Where QC_NO = :QC_NO ';
               Params.ParamByName('QC_NO').AsString := QC;
               Execute;
               Close;
            end;
         end;
      end; //WITH
end;

function TfQuality.UpdateSNCount(psSN,pFlag: string;pPass,pFail,pOutput:integer): Boolean;
var sRes: string;
begin
   result := true;
   //抽驗時只填Pass及Fail Qty;最後整批PASS時才填OUTPUT QTY
   with SProc do
   begin
      try
         Close;
         DataRequest('SAJET.SJ_QC_TRANSATION_COUNT');
         FetchParams;
         Params.ParamByName('TLINEID').AsString := G_pline;
         Params.ParamByName('TSTAGEID').AsString := G_pstage;
         Params.ParamByName('TPROCESSID').AsString := G_pprocess;
         Params.ParamByName('TEMP').AsString := UpdateUserID;
         Params.ParamByName('TNOW').AsDateTime := G_SysDateTime;
         Params.ParamByName('TSN').AsString := psSN;
         Params.ParamByName('PWO').AsString := LabWO.caption;
         Params.ParamByName('PMODELID').AsString := PartID;
         Params.ParamByName('TPASS').AsInteger := pPass;
         Params.ParamByName('TFAIL').AsInteger := pFail;
         Params.ParamByName('TOUTPUT').AsInteger := pOutput;
         Params.ParamByName('FLAG').AsString := pFlag;
         Execute;
         sRes := Params.ParamByName('TRES').AsString;
      except
         sRes :='CALL SJ_QC_TRANSATION_COUNT Exception';
      end;
      Close;
   end;
   if sRes <> 'OK' then
   begin
      MessageBeep(17);
      MessageDlg(sRes, mtError, [mbCancel], 0);
      result := false;
   end;
end;

procedure TfQuality.itemDeleteClick(Sender: TObject);
begin
   if lvEC.SelCount <> 0 then
      lvEC.Selected.Delete;
end;

procedure TfQuality.itemChangeClick(Sender: TObject);
begin
   if lvDefect.SelCount <> 0 then
   begin
      fChangeSN := TfChangeSN.Create(Self);
      with fChangeSN do
      begin
         editDefectSN.Text := lvDefect.Selected.Caption;
         editChangeSNChange(Self);
         if ShowModal = mrOK then
         begin
            fQuality.ClearData;
            fQuality.GetQCData(lablInspTimes.Caption);
            if GetSamplingPlan(LabInspType.Caption) = '0' then exit;
               CheckSamplingPlan;
         end;
         Free;
      end;
   end;
end;

procedure TfQuality.IncludeBtnClick(Sender: TObject);
var i: integer;
begin
      for i:=0 to listbDefect.Items.Count-1 do
         if listbDefect.Selected[i] then
            checkDefect(Copy(listbDefect.Items[i],1,Pos(' - ',listbDefect.Items[i])-1));

end;

procedure TfQuality.btnDefectClick(Sender: TObject);
begin
  if btnDefect.Caption='Disabled Def.' then
  begin
    GradPanel3.Visible := False;
    listbDefect.Visible := False;
    btnDefect.Caption :='Enabled Def.';
  end else
  begin
    btnDefect.Caption := 'Disabled Def.';
    listbDefect.Visible := true;
    GradPanel3.Visible := true;

  end;
    {
//  listbDefect.Visible := not listbDefect.Visible;
//  GradPanel3.Visible := not GradPanel3.Visible;
  if not listbDefect.Visible then
    btnDefect.Caption :='Enabled Def.'
  else
    btnDefect.Caption := 'Disabled Def.'
    }

end;

end.

