unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db,
  DBClient, MConnect, SConnect, DBCtrls, ObjBrkr, unitSetupValue, Mask;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    Label11: TLabel;
    Label9: TLabel;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    Label1: TLabel;
    Label8: TLabel;
    dbtxtType: TDBText;
    Label2: TLabel;
    dbtxtPart: TDBText;
    Label3: TLabel;
    dbtxtVersion: TDBText;
    Label6: TLabel;
    dbtxtTarget: TDBText;
    Label10: TLabel;
    dbtxtDuedata: TDBText;
    Label12: TLabel;
    dbtxtRoute: TDBText;
    Label13: TLabel;
    dbtxtPDLine: TDBText;
    dbtxtSProcess: TDBText;
    Label14: TLabel;
    Label15: TLabel;
    dbtxtEProcess: TDBText;
    Label16: TLabel;
    dbtxtCust: TDBText;
    Label17: TLabel;
    dbtxtPO: TDBText;
    Label18: TLabel;
    dbtxtMastWO: TDBText;
    Label21: TLabel;
    dbtxtRemark: TDBText;
    DataSource1: TDataSource;
    Label4: TLabel;
    editWO: TEdit;
    LabQty: TLabel;
    Label5: TLabel;
    editQty: TEdit;
    sbtnRelease: TSpeedButton;
    Image5: TImage;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label7: TLabel;
    LabCode: TLabel;
    Label19: TLabel;
    QryGetSeq: TClientDataSet;
    Shape1: TShape;
    Label20: TLabel;
    DBMin_Number: TDBText;
    Label23: TLabel;
    DBMax_Number: TDBText;
    Label22: TLabel;
    edtStart: TEdit;
    editLabelNo: TMaskEdit;
    LabMessage: TLabel;
    imgInitial: TImage;
    sbtnInitial: TSpeedButton;
    lablLabel: TLabel;
    lablDesc: TLabel;
    sbtnFailSN: TSpeedButton;
    QryTemp1: TClientDataSet;
    lablSNCount: TLabel;
    SProc: TClientDataSet;
    editSNCount: TEdit;
    procedure editWOKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure sbtnReleaseClick(Sender: TObject);
    procedure sbtnInitialClick(Sender: TObject);
    procedure sbtnFailSNClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure editSNCountKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    gbAuth: Boolean; giQty: Integer;
    mCarry, g_sRule, gsMark, mDateCode: string;
    gsTable, gsField, cSeqName, gsFunction, gsFileName, gsCheckkSum, gsType, gsQtyField,gsLabelFile: string;
    UpdateUserID, gsLabelType, gsLabelType2: string;
    Authoritys, AuthorityRole: string;
    function SeqTran(Seq: Integer): string;
    procedure ShowWOData(bRelease: Boolean);
    procedure ShowData;
    function CodeNum(Seq: Integer): string;
    procedure SetStatusbyAuthority;
    function CreateRuleSeq(RuleName: string): Boolean;
    function SeqCode(sStart: string): integer;
    function XY(X, Y: integer): integer;
    function CheckRule(sInputNo: string; var sStart: string): Boolean;
  end;

var
  fDetail: TfDetail;
  NumUdf: TStringList;
  CarryM, CarryD, CarryW: TStrings;
  Carry16: string;
procedure StopComm; stdcall; external 'PrintBCdll.DLL';
function StartComm(PcomPort, PBaudRate: string): Boolean; stdcall; external 'PrintBCdll.DLL';
function SendBCData(PrintLabQty: integer; tsParam, tsData: TStrings; PComPort, PBaudRate, sRule, sType: string;iCount :integer): Boolean; stdcall; external 'PrintBCdll.DLL';
function BCInitial(PcomPort, PBaudRate, sRule, sType,sLabelFile:String): Boolean; stdcall; external 'PrintBCdll.DLL';

implementation

{$R *.DFM}

uses unitDataBase, uDllForm, DllInit, uCommData;

procedure TfDetail.SetStatusbyAuthority;
begin
  // Read Only,Allow To Change,Full Control
  Authoritys := '';
  gbAuth := False;
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
    Params.ParamByName('PRG').AsString := 'Barcode Center';
    Params.ParamByName('FUN').AsString := gsFunction;
    Open;
    while not Eof do
    begin
      Authoritys := Fieldbyname('AUTHORITYS').AsString;
      gbAuth := (Authoritys = 'Allow To Execute') or (Authoritys = 'Full Control');
      if gbAuth then
        break;
      Next;
    end;
    Close;
  end;

//  sbtnRelease.Enabled := (Authoritys = 'Allow To Execute') or (Authoritys = 'Full Control');
  if not gbAuth then
  begin
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
      Params.ParamByName('PRG').AsString := 'Barcode Center';
      Params.ParamByName('FUN').AsString := gsFunction;
      Open;
      while not Eof do
      begin
        AuthorityRole := Fieldbyname('AUTHORITYS').AsString;
        gbAuth := (AuthorityRole = 'Allow To Execute') or (AuthorityRole = 'Full Control');
        if gbAuth then
          break;
        Next;
      end;
      Close;
    end;
  end;
end;

function TfDetail.CodeNum(Seq: Integer): string;
var I, J: Integer;
  sSEQ: string;
  S, S1, sSeqText: string;
begin
  sSeqText := 'S';
  for i := 0 to NumUdf.Count - 1 do
    sSeqText := sSeqText + Copy(NumUdf.Strings[i], 1, 1);
  sSeq := SeqTran(Seq);
  S := LabCode.Caption;
  S1 := editLabelNo.Text;
  J := 1;
  for I := 1 to Length(S) do
    if POS(S[I], sSeqText) > 0 then
    begin
      S1[I] := sSEQ[J];
      Inc(J);
    end;
  if Pos('X', LabCode.Caption) <> 0 then
    with QryTemp1 do
    begin
      Close;
      Params.Clear;
      CommandText := 'select ' + gsCheckkSum + '(''' + S1 + ''') SNID from dual';
      Open;
      S1 := FieldByName('SNID').AsString;
    end;
  Result := S1;
end;

function TfDetail.SeqTran(Seq: Integer): string;
var mMod, mDiv, i, j: Integer; S, sSeq, sCode, sSeqText: string;
  function SetZero(iLen: integer): string;
  var i: integer;
  begin
    Result := '';
    for i := 1 to iLen do
      Result := '0' + Result;
  end;
begin
  S := LabCode.Caption;
  sCode := '';
  sSEQ := '';
  sSeqText := 'S';
  for i := 0 to NumUdf.Count - 1 do
    sSeqText := sSeqText + Copy(NumUdf.Strings[i], 1, 1);
  for I := 1 to Length(S) do
    if POS(S[I], sSeqText) > 0 then
      sCode := sCode + S[I];
  mDiv := Seq;
  if sSeqText = 'S' then
  begin
    if mCarry = '0' then
      Result := FormatFloat(SetZero(Length(sCode)), Seq)
    else if mCarry = '16' then
      Result := IntToHex(Seq, Length(sCode));
  end
  else
  begin
    for I := Length(sCode) downto 1 do
    begin
      if sCode[I] = 'S' then
      begin
        if mCarry = '16' then
          S := Carry16
        else
          S := Copy(Carry16, 1, 10);
      end
      else
      begin
        for j := 0 to NumUdf.Count - 1 do
        begin
          if sCode[I] = Copy(NumUdf.Strings[J], 1, 1) then
          begin
            S := Copy(NumUdf.Strings[j], 5, Length(NumUdf.Strings[j]));
            break;
          end;
        end;
      end;
      if mDiv <> 0 then
      begin
        mMod := mDiv mod Length(S);
        mDiv := mDiv div Length(S);
        if mMod = 0 then
          sSEQ := Copy(S, 1, 1) + sSeq
        else
          sSEQ := Copy(S, mMod + 1, 1) + sSeq;
      end
      else
      begin
        if sCode[I] = 'S' then
          sSeq := '0' + sSeq
        else
          sSEQ := Copy(S, 1, 1) + sSeq;
      end;
    end;
    Result := sSeq;
  end;
end;

procedure TfDetail.ShowWOData(bRelease: Boolean);
var mDY, mDM, mDD, mDW, mcDM, mcDD, mcDW, mDK, mDYW, sCode, sMask, sDefault: string;
  iInputQty, I, iCycle, iStart, iR: Integer; bReset: Boolean; mDate: TDateTime;
  sType1, sField1, sType2, sField2, sType3, sField3, sValue1, sValue2, sValue3: string;
begin
  sbtnRelease.Enabled := False;
  LabCode.Caption := '';
  LabQty.Caption := '0';
  editQty.Text := '0';
  mCarry := '';
  NumUdf.Clear;
  editLabelNo.EditMask := '';
  with QryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    CommandText := 'Select A.WORK_ORDER,' +
      'A.MODEL_ID,' +
      'A.WO_TYPE,' +
      'A.WO_RULE,' +
      'A.VERSION,' +
      'A.TARGET_QTY,' +
      'A.WO_CREATE_DATE,' +
      'A.WO_SCHEDULE_DATE,' +
      'A.WO_START_DATE,' +
      'A.WO_CLOSE_DATE,' +
      'A.INPUT_QTY,' +
      'A.OUTPUT_QTY,' +
      'A.WORK_FLAG,' +
      'A.WO_STATUS,' +
      'A.PO_NO,' +
      'A.MASTER_WO,' +
      'A.REMARK,' +
      'A.ROUTE_ID,' +
      'B.*,' +
      'C.ROUTE_NAME,' +
      'D.PDLINE_NAME,' +
      'E.CUSTOMER_CODE,' +
      'E.CUSTOMER_NAME,' +
      'F.PROCESS_NAME START_PROCESS,' +
      'G.PROCESS_NAME END_PROCESS, ' +
      '(Select MAX(' + gsField + ') FROM ' + gsTable + ' WHERE WORK_ORDER=A.WORK_ORDER) MAX_NUMBER,' +
      '(Select MIN(' + gsField + ') FROM ' + gsTable + ' WHERE WORK_ORDER=A.WORK_ORDER) MIN_NUMBER ' +
      'From SAJET.G_WO_BASE A,' +
      'SAJET.SYS_PART B,' +
      'SAJET.SYS_ROUTE C,' +
      'SAJET.SYS_PDLINE D,' +
      'SAJET.SYS_CUSTOMER E,' +
      'SAJET.SYS_PROCESS F,' +
      'SAJET.SYS_PROCESS G ' +
      'Where A.MODEL_ID=B.PART_ID(+) and ' +
      'A.ROUTE_ID=C.ROUTE_ID(+) and ' +
      'A.DEFAULT_PDLINE_ID=D.PDLINE_ID(+) and ' +
      'A.CUSTOMER_ID=E.CUSTOMER_ID(+) and ' +
      'A.START_PROCESS_ID=F.PROCESS_ID(+) and ' +
      'A.END_PROCESS_ID=G.PROCESS_ID(+) and ' +
      'A.WORK_ORDER=:WORK_ORDER';
    Params.ParamByName('WORK_ORDER').AsString := Trim(editWO.Text);
    Open;
    if IsEmpty then
    begin
      Close;
      MessageDlg('Work Order Not Found !!', mtError, [mbOK], 0);
      editWo.SelectAll;
      Exit;
    end;
  end;
  gsLabelFile := qryData.FieldByName('LABEL_FILE').AsString;
  iInputQty := qryData.FieldByName('INPUT_QTY').AsInteger;

   // 計算已展的Num
  with qryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    CommandText := 'Select Count(*) CNT ' +
      ' From ' + gsTable +
      ' Where WORK_ORDER = :WORK_ORDER ';
    if gsLabelType = 'Serial Number' then
      CommandText := CommandText + '   AND PROCESS_ID = 0 ';
    Params.ParamByName('WORK_ORDER').AsString := Trim(editWO.Text);
    Open;
    LabQty.Caption := Fieldbyname('CNT').AsString;
    if gsLabelType = 'Serial Number' then
    begin
      iInputQty := iInputQty + FieldByName('CNT').AsInteger;
      labQty.Caption := IntToStr(iInputQty);
      editQty.Text := InttoStr(qryData.Fieldbyname('TARGET_QTY').AsInteger - iInputQty);
    end
    else
      editQty.Text := '0';
    Close;
  end;
  giQty := 1;
  if gsQtyField <> '' then
    giQty := StrToIntDef(QryData.FieldByName(gsQtyField).AsString, 1);
  gsLabelType2 := '';
  if giQty <> 1 then begin
    lablSNCount.Caption := gsLabelType + ' Qty: ' + IntToStr(giQty);
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'label_name', ptInput);
    QryTemp.CommandText := 'select b.* from sajet.sys_label b '
      + 'where qty_field = :label_name '
      + 'and rownum = 1';
    QryTemp.Params.ParamByName('label_name').AsString := gsLabelType;
    QryTemp.Open;
    if not QryTemp.IsEmpty then
      gsLabelType2 := QryTemp.FieldByName('label_name').AsString;
    QryTemp.Close;
  end;
  lablSNCount.Visible := (giQty <> 1);
  editSNCount.Visible := lablSNCount.Visible;
  editSNCount.Text := IntToStr(giQty);
  if gsLabelType = 'Serial Number' then
    editQty.Text := IntToStr(StrToInt(editQty.Text) div giQty);
  if StrToInt(LabQty.Caption) div giQty >= StrToInt(dbtxtTarget.Caption) then
  begin
    if bRelease then
      MessageDlg('Release Qty = Target Qty!!', mtInformation, [mbOK], 0)
    else
      MessageDlg('Release Qty = Target Qty!!', mtWarning, [mbOK], 0);
    editWo.SelectAll;
    Exit;
  end;
  // 讀取編碼規則
  gsMark := '';
  with qryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    CommandText := 'Select * ' +
      'From SAJET.G_WO_PARAM ' +
      'Where WORK_ORDER = :WORK_ORDER and ' +
      'MODULE_NAME = :MODULE_NAME ';
    Params.ParamByName('WORK_ORDER').AsString := QryData.Fieldbyname('WORK_ORDER').AsString;
    Params.ParamByName('MODULE_NAME').AsString := Uppercase(gsLabelType) + ' RULE';
    Open;
    g_sRule := FieldByName('FUNCTION_NAME').AsString;
    while not Eof do
    begin
      if Fieldbyname('PARAME_NAME').AsString = gsLabelType + ' Code' then
      begin
        if Fieldbyname('PARAME_ITEM').AsString = 'Code' then
          LabCode.Caption := Fieldbyname('PARAME_VALUE').AsString;
        if (Fieldbyname('PARAME_ITEM').AsString = 'Default') and (not bRelease) then
          editLabelNo.Text := Fieldbyname('PARAME_VALUE').AsString;
        if Fieldbyname('PARAME_ITEM').AsString = 'Code Type' then
        begin
          mCarry := '0';
          if Fieldbyname('PARAME_VALUE').AsString = '16' then
            mCarry := '16';
        end;
      end
      else if Fieldbyname('PARAME_NAME').AsString = 'Month User Define' then
        CarryM.CommaText := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_NAME').AsString = 'Day User Define' then
        CarryD.CommaText := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_NAME').AsString = 'Week User Define' then
        CarryW.CommaText := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_NAME').AsString = 'Check Sum' then
        gsCheckkSum := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_NAME').AsString = '1-Digit Type & Field' then
      begin
        sType1 := Fieldbyname('PARAME_ITEM').AsString;
        sField1 := Fieldbyname('PARAME_VALUE').AsString;
      end
      else if Fieldbyname('PARAME_NAME').AsString = '2-Digit Type & Field' then
      begin
        sType2 := Fieldbyname('PARAME_ITEM').AsString;
        sField2 := Fieldbyname('PARAME_VALUE').AsString;
      end
      else if Fieldbyname('PARAME_NAME').AsString = '3-Digit Type & Field' then
      begin
        sType3 := Fieldbyname('PARAME_ITEM').AsString;
        sField3 := Fieldbyname('PARAME_VALUE').AsString;
      end
      else if Fieldbyname('PARAME_NAME').AsString = 'Reset Sequence' then
      begin
        bReset := (Fieldbyname('PARAME_ITEM').AsString = '1');
        iCycle := Fieldbyname('PARAME_VALUE').AsInteger;
      end
      else if Fieldbyname('PARAME_NAME').AsString = gsLabelType + ' User Define' then
        NumUdf.Add(Fieldbyname('PARAME_ITEM').AsString + ' : ' +
          Fieldbyname('PARAME_VALUE').AsString);
      Next;
    end;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'PARAME_NAME', ptInput);
    CommandText := 'Select PARAME_VALUE ' +
      'From SAJET.SYS_MODULE_PARAM A ' +
      'Where MODULE_NAME = ''' + Uppercase(gsLabelType) + ' RULE'' and ' +
      'A.FUNCTION_NAME = :FUNCTION_NAME and ' +
      'A.PARAME_NAME = :PARAME_NAME ';
    Params.ParamByName('FUNCTION_NAME').AsString := g_sRule;
    Params.ParamByName('PARAME_NAME').AsString := 'Reset Sequence Mark';
    Open;
    gsMark := Fieldbyname('PARAME_VALUE').AsString;
    Close;
    sCode := LabCode.Caption;
    sDefault := editLabelNo.Text;
  end;
  if g_sRule = '' then
  begin
    MessageDlg(gsLabelType + ' Rule NG!!', mtError, [mbOK], 0);
    editWo.SelectAll;
    Exit;
  end;
  sbtnRelease.Enabled := gbAuth;

  with qryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select TO_CHAR(SYSDATE,''YYYYMMDDIWDDD'') YMD, sysdate '
      + 'From DUAL ';
    Open;
    mDateCode := Fieldbyname('YMD').AsString;
    mDate := FieldByName('sysdate').AsDateTime;
    Close;
  end;
   // Y M D W A C L S
  mDY := Copy(mDateCode, 1, 4);
  mDM := Copy(mDateCode, 5, 2);
  mDD := Copy(mDateCode, 7, 2);
  mDW := Copy(mDateCode, 9, 2);
  mDYW := Copy(mDateCode, 11, 3);
  mDK := IntToStr(DayofWeek(mDate));
  if CarryM.Count >= StrToInt(mDM) then
    mcDM := CarryM[StrToInt(mDM) - 1];
  if CarryD.Count >= StrToInt(mDD) then
    mcDD := CarryD[StrToInt(mDD) - 1];
  if CarryW.Count >= StrToInt(mDW) then
    mcDW := CarryW[StrToInt(mDW) - 1];
  if gsType = 'S' then
  begin
    edtStart.Enabled := True;
    editLabelNo.Enabled := False;
    editQty.Text := '';
    edtStart.Text := '';
  end
  else if gsType = 'Y' then
    with qryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select Last_Number from all_sequences '
        + 'where sequence_name = ''' + cSeqName + UpperCase(g_sRule) + '''  and sequence_owner = user';
      Open;
      if IsEmpty then
      begin
        edtStart.Enabled := True;
        edtStart.Text := SeqTran(1);
        case iCycle of
          0:
            begin
              if Pos('D', sCode) <> 0 then
              begin
                if gsMark = '' then
                  gsMark := mDD
                else if mDD <> gsMark then
                  gsMark := mDD;
              end
              else if gsMark = '' then
                gsMark := mcDD
              else if mcDD <> gsMark then
                gsMark := mcDD;
            end;
          1:
            begin
              if Pos('W', sCode) <> 0 then
              begin
                if gsMark = '' then
                  gsMark := mDW
                else if mDW <> gsMark then
                  gsMark := mDW;
              end
              else if gsMark = '' then
                gsMark := mcDW
              else if mcDW <> gsMark then
                gsMark := mcDW;
            end;
          2:
            begin
              if Pos('M', sCode) <> 0 then
              begin
                if gsMark = '' then
                  gsMark := mDM
                else if mDM <> gsMark then
                  gsMark := mDM;
              end
              else if gsMark = '' then
                gsMark := mcDM
              else if mcDM <> gsMark then
                gsMark := mcDM;
            end;
          3:
            begin
              if gsMark = '' then
                gsMark := mDY
              else if mDY <> gsMark then
                gsMark := mDY;
            end;
        end;
      end
      else
      begin
        iStart := Fieldbyname('Last_Number').AsInteger;
        if bReset then
        begin
          bReset := False;
          case iCycle of
            0:
              begin
                if Pos('D', sCode) <> 0 then
                begin
                  if gsMark = '' then
                    gsMark := mDD
                  else if mDD <> gsMark then
                  begin
                    gsMark := mDD;
                    bReset := True;
                  end;
                end
                else if gsMark = '' then
                  gsMark := mcDD
                else if mcDD <> gsMark then
                begin
                  gsMark := mcDD;
                  bReset := True;
                end;
              end;
            1:
              begin
                if Pos('W', sCode) <> 0 then
                begin
                  if gsMark = '' then
                    gsMark := mDW
                  else if mDW <> gsMark then
                  begin
                    gsMark := mDW;
                    bReset := True;
                  end;
                end
                else if gsMark = '' then
                  gsMark := mcDW
                else if mcDW <> gsMark then
                begin
                  gsMark := mcDW;
                  bReset := True;
                end;
              end;
            2:
              begin
                if Pos('M', sCode) <> 0 then
                begin
                  if gsMark = '' then
                    gsMark := mDM
                  else if mDM <> gsMark then
                  begin
                    gsMark := mDM;
                    bReset := True;
                  end;
                end
                else if gsMark = '' then
                  gsMark := mcDM
                else if mcDM <> gsMark then
                begin
                  gsMark := mcDM;
                  bReset := True;
                end;
              end;
            3:
              begin
                if gsMark = '' then
                  gsMark := mDY
                else if mDY <> gsMark then
                begin
                  gsMark := mDY;
                  bReset := True;
                end;
              end;
          end;
          if bReset then
          begin
            Close;
            Params.Clear;
            CommandText := ' drop sequence ' + cSeqName + g_sRule;
            Execute;
            Close;
            iStart := 1;
          end;
        end;
        edtStart.Enabled := bReset;
        edtStart.Text := SeqTran(iStart);
      end;
    end;
  sMask := '';
  if sField1 <> '' then
  begin
    sValue1 := QryData.FieldByName(sField1).AsString;
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select ' + sType1 + '(''' + sValue1 + ''') snid from dual ';
      Open;
      sValue1 := FieldByName('snid').AsString;
    end;
  end;
  if sField2 <> '' then
  begin
    sValue2 := QryData.FieldByName(sField2).AsString;
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select ' + sType2 + '(''' + sValue2 + ''') snid from dual ';
      Open;
      sValue2 := FieldByName('snid').AsString;
    end;
  end;
  if sField3 <> '' then
  begin
    sValue3 := QryData.FieldByName(sField3).AsString;
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select ' + sType1 + '(''' + sValue3 + ''') snid from dual ';
      Open;
      sValue3 := FieldByName('snid').AsString;
    end;
  end;
  for I := Length(sCode) downto 1 do
  begin
    if sCode[I] = 'Y' then
    begin
      sMask := '0' + sMask;
      if Length(mDY) > 0 then
      begin
        sDefault[I] := mDY[Length(mDY)];
        mDY := Copy(mDY, 1, Length(mDY) - 1);
      end
      else
        sDefault[I] := '0';
    end
    else if sCode[I] = 'M' then
    begin
      sMask := '0' + sMask;
      if Length(mDM) > 0 then
      begin
        sDefault[I] := mDM[Length(mDM)];
        mDM := Copy(mDM, 1, Length(mDM) - 1);
      end
      else
        sDefault[I] := '0';
    end
    else if sCode[I] = 'm' then
    begin
      sMask := 'A' + sMask;
      if Length(mcDM) > 0 then
      begin
        sDefault[I] := mcDM[Length(mcDM)];
        mcDM := Copy(mcDM, 1, Length(mcDM) - 1);
      end
      else
        sDefault[I] := '0';
    end
    else if sCode[I] = 'D' then
    begin
      sMask := '0' + sMask;
      if Length(mDD) > 0 then
      begin
        sDefault[I] := mDD[Length(mDD)];
        mDD := Copy(mDD, 1, Length(mDD) - 1);
      end
      else
        sDefault[I] := '0';
    end
    else if sCode[I] = 'F' then
    begin
      sMask := '0' + sMask;
      if Length(mDYW) > 0 then
      begin
        sDefault[I] := mDYW[Length(mDYW)];
        mDYW := Copy(mDYW, 1, Length(mDYW) - 1);
      end
      else
        sDefault[I] := '0';
    end
    else if sCode[I] = 'd' then
    begin
      sMask := 'A' + sMask;
      if Length(mcDD) > 0 then
      begin
        sDefault[I] := mcDD[Length(mcDD)];
        mcDD := Copy(mcDD, 1, Length(mcDD) - 1);
      end
      else
        sDefault[I] := '0';
    end
    else if sCode[I] = 'W' then
    begin
      sMask := '0' + sMask;
      if Length(mDW) > 0 then
      begin
        sDefault[I] := mDW[Length(mDW)];
        mDW := Copy(mDW, 1, Length(mDW) - 1);
      end
      else
        sDefault[I] := '0';
    end
    else if sCode[I] = 'w' then
    begin
      sMask := 'A' + sMask;
      if Length(mcDW) > 0 then
      begin
        sDefault[I] := mcDW[Length(mcDW)];
        mcDW := Copy(mcDW, 1, Length(mcDW) - 1);
      end
      else
        sDefault[I] := '0';
    end
    else if sCode[I] = 'K' then
    begin
      sMask := 'A' + sMask;
      sDefault[I] := mDK[1];
    end
    else if sCode[I] = 'P' then
    begin
      sMask := 'A' + sMask;
      if Length(sValue1) > 0 then
      begin
        sDefault[I] := sValue1[Length(sValue1)];
        sValue1 := Copy(sValue1, 1, Length(sValue1) - 1);
      end
      else
        sDefault[I] := '0';
    end
    else if sCode[I] = 'Q' then
    begin
      sMask := 'A' + sMask;
      if Length(sValue2) > 0 then
      begin
        sDefault[I] := sValue2[Length(sValue2)];
        sValue2 := Copy(sValue2, 1, Length(sValue2) - 1);
      end
      else
        sDefault[I] := '0';
    end
    else if sCode[I] = 'R' then
    begin
      sMask := 'A' + sMask;
      if Length(sValue3) > 0 then
      begin
        sDefault[I] := sValue3[Length(sValue3)];
        sValue3 := Copy(sValue3, 1, Length(sValue3) - 1);
      end
      else
        sDefault[I] := '0';
    end
    else if sCode[I] = 'C' then
      sMask := 'C' + sMask
    else if sCode[I] = 'L' then
      sMask := 'L' + sMask
    else if sCode[I] = '9' then
      sMask := '9' + sMask
    else
      sMask := 'A' + sMask;
  end;
  editLabelNo.EditMask := sMask;
  editLabelNo.Text := sDefault;
  if gsType <> 'S' then
    editLabelNo.Enabled := (Pos(' ', editLabelNo.Text) <> 0);
end;

procedure TfDetail.ShowData;
begin
  with QryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    CommandText := 'Select A.WORK_ORDER,' +
      'A.MODEL_ID,' +
      'A.WO_TYPE,' +
      'A.WO_RULE,' +
      'A.VERSION,' +
      'A.TARGET_QTY,' +
      'A.WO_CREATE_DATE,' +
      'A.WO_SCHEDULE_DATE,' +
      'A.WO_START_DATE,' +
      'A.WO_CLOSE_DATE,' +
      'A.INPUT_QTY,' +
      'A.OUTPUT_QTY,' +
      'A.WORK_FLAG,' +
      'A.WO_STATUS,' +
      'A.PO_NO,' +
      'A.MASTER_WO,' +
      'A.REMARK,' +
      'A.ROUTE_ID,' +
      'B.PART_NO,' +
      'C.ROUTE_NAME,' +
      'D.PDLINE_NAME,' +
      'E.CUSTOMER_CODE,' +
      'E.CUSTOMER_NAME,' +
      'F.PROCESS_NAME START_PROCESS,' +
      'G.PROCESS_NAME END_PROCESS, ' +
      '(Select MAX(' + gsField + ') FROM ' + gsTable + ' WHERE WORK_ORDER=A.WORK_ORDER) MAX_NUMBER,' +
      '(Select MIN(' + gsField + ') FROM ' + gsTable + ' WHERE WORK_ORDER=A.WORK_ORDER) MIN_NUMBER ' +
      'From SAJET.G_WO_BASE A,' +
      'SAJET.SYS_PART B,' +
      'SAJET.SYS_ROUTE C,' +
      'SAJET.SYS_PDLINE D,' +
      'SAJET.SYS_CUSTOMER E,' +
      'SAJET.SYS_PROCESS F,' +
      'SAJET.SYS_PROCESS G ' +
      'Where A.MODEL_ID=B.PART_ID(+) and ' +
      'A.ROUTE_ID=C.ROUTE_ID(+) and ' +
      'A.DEFAULT_PDLINE_ID=D.PDLINE_ID(+) and ' +
      'A.CUSTOMER_ID=E.CUSTOMER_ID(+) and ' +
      'A.START_PROCESS_ID=F.PROCESS_ID(+) and ' +
      'A.END_PROCESS_ID=G.PROCESS_ID(+) and ' +
      'A.WORK_ORDER=:WORK_ORDER';
    Params.ParamByName('WORK_ORDER').AsString := Trim(editWO.Text);
    Open;
    if RecordCount <= 0 then
    begin
      Close;
      MessageDlg('Work Order Not Found !!', mtError, [mbOK], 0);
      Exit;
    end;
  end;

   // 計算已展的數量
  with qryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    CommandText := 'Select Count(*) CNT ' +
      ' From ' + gsTable +
      'Where WORK_ORDER = :WORK_ORDER ';
    Params.ParamByName('WORK_ORDER').AsString := Trim(editWO.Text);
    Open;
    LabQty.Caption := Fieldbyname('CNT').AsString;
    if gsLabelType = 'Serial Number' then
      editQty.Text := InttoStr(qryData.Fieldbyname('TARGET_QTY').AsInteger - qryTemp.Fieldbyname('CNT').AsInteger)
    else
      editQty.Text := '0';
    Close;
    Params.Clear;
    CommandText := 'select Last_Number from all_sequences '
      + 'where sequence_name = ''' + cSeqName + UpperCase(g_sRule) + '''';
    Open;
    if IsEmpty then
    begin
      edtStart.Enabled := True;
      edtStart.Text := SeqTran(1);
    end
    else
    begin
      edtStart.Enabled := False;
      edtStart.Text := SeqTran(Fieldbyname('Last_Number').AsInteger);
    end;
    Close;
  end;
end;

procedure TfDetail.editWOKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    ShowWOData(False);
    editWo.SetFocus;
    editWo.SelectAll;
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
  G_LoadSetupValue(gsLabelType);
  NumUdf := TStringList.Create;
  CarryM := TStringList.Create;
  CarryD := TStringList.Create;
  CarryW := TStringList.Create;
  Carry16 := '0123456789ABCDEF';
  Shape1.Width := 0;
//  if SetupValue.bPrintSNLabel then

  if SetupValue.bPrintLabel then
    if SetupValue.sPrintMethod <> 'CodeSoft' then
    begin
//      StartComm(SetupValue.sComPort, SetupValue.sBaudRate);
      sbtnInitial.Visible := True;
      imgInitial.Visible := True;
    end;
  editWo.SetFocus;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'label_name', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select b.*, a.function f1 from sajet.sys_label b, sajet.sys_program_fun a '
      + 'where label_name = :label_name and b.label_name = a.fun_param '
      + 'and a.program = ''Barcode Center'' and upper(dll_filename) = :dll_name and rownum = 1';
    Params.ParamByName('label_name').AsString := gsLabelType;
    Params.ParamByName('dll_name').AsString := 'BCLABELDLL.DLL';
    Open;
    gsTable := FieldByName('Table_Name').AsString;
    gsField := FieldByName('Field_Name').AsString;
    cSeqName := FieldByName('Seq_Name').AsString;
    gsFunction := FieldByName('f1').AsString;
    gsFileName := FieldByName('file_name').AsString;
    gsType := FieldByName('Type').AsString;
    gsQtyField := FieldByName('Qty_Field').AsString;
    Close;
  end;
  if gsType = 'S' then
  begin
    Label5.Caption := 'Start Number';
    Label22.Caption := 'End Number';
    editLabelNo.Visible := False;
    Label19.Visible := False;
    lablLabel.Visible := False;
    lablDesc.Visible := False;
  end
  else
    Label5.Caption := 'Input ' + gsLabelType;
  Label11.Caption := gsFunction;
  Label9.Caption := Label11.Caption;
  Label7.Caption := gsLabelType + ' Code';
  Label4.Caption := 'Release ' + gsLabelType;
  Label19.Caption := 'Default ' + gsLabelType;
  Label20.Caption := 'Released ' + gsLabelType;
  lablDesc.Caption := gsFileName + ' + Part No (Default)';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select file_name from sajet.sys_label '
      + 'where label_name = ''' + gsLabelType + '-Box'' and rownum = 1 ';
    Open;
    if not IsEmpty then
      lablDesc.Caption := lablDesc.Caption + ' / ' + FieldByName('file_name').AsString + ' + Part No (Default)';
  end;
  if UpdateUserID <> '0' then
    SetStatusbyAuthority;
end;

function TfDetail.XY(X, Y: integer): integer;
var i: integer;
begin
  Result := 1;
  for i := 1 to Y do
    Result := X * Result;
end;

function TfDetail.SeqCode(sStart: string): integer;
var i, j, iBase: integer; s, sSeqText, sCode: string;
begin
  sSeqText := 'S';
  for i := 0 to NumUdf.Count - 1 do
    sSeqText := sSeqText + Copy(NumUdf.Strings[i], 1, 1);
  Result := 0;
  if sSeqText = 'S' then
  begin
    if mCarry = '0' then
    begin
      Result := StrToInt(sStart);
    end
    else if mCarry = '16' then
    begin
      S := Carry16;
      Result := 0;
      iBase := Length(S);
      j := 0;
      for i := Length(sStart) downto 1 do
      begin
        Result := Result + XY(iBase, j) * (Pos(sStart[i], S) - 1);
        Inc(j);
      end;
    end;
  end
  else
  begin
    S := LabCode.Caption;
    for I := 1 to Length(S) do
      if POS(S[I], sSeqText) > 0 then
        sCode := sCode + S[I];
    for i := 1 to Length(sStart) do
    begin
      if sCode[I] = 'S' then
      begin
        if mCarry = '16' then
          S := Carry16
        else
          S := Copy(Carry16, 1, 10);
      end
      else
      begin
        for j := 0 to NumUdf.Count - 1 do
        begin
          if sCode[I] = Copy(NumUdf.Strings[J], 1, 1) then
          begin
            S := Copy(NumUdf.Strings[j], 5, Length(NumUdf.Strings[j]));
            break;
          end;
        end;
      end;
      iBase := Length(S);
      Result := Result * iBase + (Pos(sStart[i], S) - 1);
    end;
  end;
end;

function TfDetail.CreateRuleSeq(RuleName: string): Boolean;
  function GetMaxSeq: string;
  var S: string; i, j: integer; iSeq: Real;
  begin
    S := LabCode.Caption;
    iSeq := 1;
    for I := 1 to Length(S) do
      if S[I] = 'S' then
      begin
        if mCarry = '16' then
          iSeq := iSeq * 16
        else
          iSeq := iSeq * 10
      end
      else
      begin
        for j := 0 to NumUdf.Count - 1 do
          if S[I] = Copy(NumUdf.Strings[J], 1, 1) then
          begin
            iSeq := iSeq * (Length(NumUdf.Strings[j]) - 4);
            break;
          end;
      end;
    Result := FloatToStr(iSeq - 1);
  end;
var sStart, sEnd: string;
begin
  sStart := IntToStr(SeqCode(edtStart.Text));
  sEnd := GetMaxSeq;
  Result := True;
  try
    with QryTemp do
    begin
      Close;
      Params.Clear;
      if sStart <> '0' then
        CommandText := 'CREATE SEQUENCE ' + cSeqName + RuleName + ' INCREMENT BY 1 START WITH ' + sStart + ' MAXVALUE ' + sEnd + ' NOCYCLE NOCACHE ORDER '
      else
        CommandText := 'CREATE SEQUENCE ' + cSeqName + RuleName + ' INCREMENT BY 1 START WITH ' + sStart + ' minvalue 0 MAXVALUE ' + sEnd + ' NOCYCLE NOCACHE ORDER ';
      Execute;
      Close;
      Params.Clear;
      CommandText := 'GRANT SELECT ON ' + cSeqName + RuleName + ' TO SYS_USER';
      Execute;
      Close;
    end;
  except
  end;
end;

function TfDetail.CheckRule(sInputNo: string; var sStart: string): Boolean;
var sCode, sDefault, sValue, sType, sM, sD, sW, uM, uD, uW, sR, sSeqType, sF: string;
  i, iR: integer; slValue: TStringList;
begin
  Result := True; sStart := '';
  sDefault := editLabelNo.Text;
  sCode := LabCode.Caption;
  //檢查長度
  if Length(sCode) <> Length(sInputNo) then
  begin
    Result := False;
    MessageDlg('Rule not match (Length)', mtError, [mbOK], 0);
    exit;
  end;
  //檢查固定碼
  sM := ''; sD := ''; sW := ''; uM := ''; uD := ''; uW := ''; sR := ''; sF := '';
  for i := 1 to length(sCode) do
  begin
    if sCode[i] in ['A', 'C', 'L', 'P', 'Q', 'R', '9'] then
    begin
      if (sDefault[i] <> ' ') and (sDefault[i] <> sInputNo[i]) then
      begin
        Result := False;
        MessageDlg('Rule not match (Fix Character)', mtError, [mbOK], 0);
        exit;
      end;
    end
    else if sCode[i] = 'Y' then
    begin
      if StrToIntDef(sInputNo[i], -1) = -1 then
      begin
        Result := False;
        MessageDlg('Rule not match (Year)', mtError, [mbOK], 0);
        exit;
      end;
    end
    else if sCode[i] = 'K' then
    begin
      if sInputNo[i] in ['1'..'7'] then
      else
      begin
        Result := False;
        MessageDlg('Rule not match (Day of Week)', mtError, [mbOK], 0);
        exit;
      end;
    end
    else if sCode[i] = 'S' then
    begin
      sStart := sStart + sInputNo[i];
      if sSeqType = '10' then
      begin
        if StrToIntDef(sInputNo[i], -1) = -1 then
        begin
          Result := False;
          MessageDlg('Rule not match (Sequence)', mtError, [mbOK], 0);
          exit;
        end;
      end
      else
      begin
        if sInputNo[i] in ['0'..'F'] then
        else
        begin
          Result := False;
          MessageDlg('Rule not match (Sequence)', mtError, [mbOK], 0);
          exit;
        end;
      end;
    end
    else if sCode[i] = 'M' then
      sM := sM + sInputNo[i]
    else if sCode[i] = 'D' then
      sD := sD + sInputNo[i]
    else if sCode[i] = 'W' then
      sW := sW + sInputNo[i]
    else if sCode[i] = 'm' then
      uM := uM + sInputNo[i]
    else if sCode[i] = 'd' then
      uD := uD + sInputNo[i]
    else if sCode[i] = 'w' then
      uW := uW + sInputNo[i]
    else if sCode[i] = 'F' then
      sF := sF + sInputNo[i]
  end;
  slValue := TStringList.Create;
  if uM <> '' then
  begin
    if CarryM.IndexOf(uM) = -1 then
    begin
      slValue.Free;
      Result := False;
      MessageDlg('Rule not match (Month User Define)', mtError, [mbOK], 0);
      exit;
    end;
  end;
  if uD <> '' then
  begin
    if CarryD.IndexOf(uM) = -1 then
    begin
      slValue.Free;
      Result := False;
      MessageDlg('Rule not match (Day User Define)', mtError, [mbOK], 0);
      exit;
    end;
  end;
  if uW <> '' then
  begin
    if CarryW.IndexOf(uM) = -1 then
    begin
      slValue.Free;
      Result := False;
      MessageDlg('Rule not match (Week User Define)', mtError, [mbOK], 0);
      exit;
    end;
  end;
  slValue.Free;
  if sM <> '' then
  begin
    iR := StrToIntDef(sM, -1);
    if (iR < 1) or (iR > 12) then
    begin
      Result := False;
      MessageDlg('Rule not match (Month)', mtError, [mbOK], 0);
      exit;
    end;
  end;
  if sD <> '' then
  begin
    iR := StrToIntDef(sD, -1);
    if (iR < 1) or (iR > 31) then
    begin
      Result := False;
      MessageDlg('Rule not match (Day)', mtError, [mbOK], 0);
      exit;
    end;
  end;
  if sW <> '' then
  begin
    iR := StrToIntDef(sW, -1);
    if (iR < 1) or (iR > 53) then
    begin
      Result := False;
      MessageDlg('Rule not match (Week)', mtError, [mbOK], 0);
      exit;
    end;
  end;
  if sF <> '' then
  begin
    iR := StrToIntDef(sF, -1);
    if (iR < 1) or (iR > 366) then
    begin
      Result := False;
      MessageDlg('Rule not match (Day of Year)', mtError, [mbOK], 0);
      exit;
    end;
  end;
end;

procedure TfDetail.sbtnReleaseClick(Sender: TObject);
var I,iSubBoardQty: Integer; iStart: Int64;
  sLabelNo, sPrintData, sStart, sEnd: string;
  slLabel: TStringList;
  g_tsParam, g_tsData: TStrings;
  function GetSeq: Integer;
  begin
    QryGetSeq.Close;
    QryGetSeq.Open;
    Result := QryGetSeq.Fieldbyname('SNID').AsInteger;
    QryGetSeq.Close;
  end;
  procedure SaveCode(sValue: string;iSubBoardQty:integer);
  begin
{    with QryTemp do
    begin
      Close;
      CommandText := 'select sajet.bc_' + gsField + '(''' + editWo.Text + ''','''
        + sValue + ''',' + IntToStr(giQty) + ',' + UpdateUserID + ') result from dual';
      Open;
      if FieldByName('result').AsString <> 'OK' then
        MessageDlg(FieldByName('result').AsString, mtError, [mbOK], 0);
    end; }
    with sproc do
    begin
      try
        Close;
        DataRequest('SAJET.BC_' + gsField);
        FetchParams;
        Params.ParamByName('TWO').AsString := editWo.Text;
        Params.ParamByName('TBOX').AsString := sValue;
//        Params.ParamByName('iQTY').AsInteger := giQty;
        Params.ParamByName('iQTY').AsInteger := iSubBoardQty;
        Params.ParamByName('TEMPID').AsString := UpdateUserID;
        Execute;
        if Params.ParamByName('TRES').AsString <> 'OK' then
          MessageDlg(FieldByName('TRES').AsString, mtError, [mbOK], 0);
      finally
        close;
      end;
    end;
  end;
  procedure SaveSN(SN: string);
  begin
    with QryTemp do
    begin
      Params.ParamByName('WORK_ORDER').AsString := Trim(editWO.Text);
      Params.ParamByName('MODEL_ID').AsString := QryData.Fieldbyname('MODEL_ID').aSString;
      Params.ParamByName('SERIAL_NUMBER').AsString := SN;
      Params.ParamByName('ROUTE_ID').AsString := QryData.Fieldbyname('ROUTE_ID').aSString;
      Params.ParamByName('Version').AsString := QryData.Fieldbyname('Version').aSString;
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Execute;
    end;
  end;
  procedure SaveLabel(CODE: string);
  begin
    with QryTemp do
    begin
      Params.ParamByName('WORK_ORDER').AsString := Trim(editWO.Text);
      Params.ParamByName('LABEL_NO').AsString := CODE;
      Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
      Execute;
    end;
  end;
  function checkCode: Boolean;
  var sSeqText, sCode, sStart, S: string;
    i, j: integer;
  begin
    Result := True;
    sSeqText := 'S';
    sStart := edtStart.Text;
    for i := 0 to NumUdf.Count - 1 do
      sSeqText := sSeqText + Copy(NumUdf.Strings[i], 1, 1);
    if sSeqText = 'S' then
    begin
      if mCarry = '0' then
      begin
        try
          StrToInt(sStart);
        except
          Result := False;
        end;
      end
      else if mCarry = '16' then
      begin
        for i := 1 to Length(sStart) do
          if Pos(sStart[i], Carry16) = 0 then
          begin
            Result := False;
            break;
          end;
      end;
    end
    else
    begin
      S := LabCode.Caption;
      for I := 1 to Length(S) do
        if POS(S[I], sSeqText) > 0 then
          sCode := sCode + S[I];
      for i := Length(sStart) downto 1 do
      begin
        if sCode[I] = 'S' then
        begin
          if mCarry = '16' then
          begin
            if Pos(sStart[i], Carry16) = 0 then
            begin
              Result := False;
              break;
            end;
          end
          else
          try
            StrToInt(sStart[i]);
          except
            Result := False;
            break;
          end;
        end
        else
        begin
          for j := 0 to NumUdf.Count - 1 do
          begin
            if sCode[I] = Copy(NumUdf.Strings[J], 1, 1) then
            begin
              S := Copy(NumUdf.Strings[j], 5, Length(NumUdf.Strings[j]));
              if Pos(sStart[i], S) = 0 then
              begin
                Result := False;
                break;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  procedure SavetoDB(ParamName, ParamItem, ParamValue: string);
  var sRow: string;
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
      Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
      Params.CreateParam(ftString, 'PARAME_NAME', ptInput);
      CommandText := 'select rowid from sajet.sys_module_param '
        + 'where module_name = :module_name '
        + 'and function_name = :function_name '
        + 'and parame_name = :parame_name ';
      Params.ParamByName('MODULE_NAME').AsString := Uppercase(gsLabelType) + ' RULE';
      Params.ParamByName('FUNCTION_NAME').AsString := g_sRule;
      Params.ParamByName('PARAME_NAME').AsString := ParamName;
      Open;
      if IsEmpty then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
        Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
        Params.CreateParam(ftString, 'PARAME_NAME', ptInput);
        Params.CreateParam(ftString, 'PARAME_ITEM', ptInput);
        Params.CreateParam(ftString, 'PARAME_VALUE', ptInput);
        Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
        CommandText := 'Insert Into SAJET.SYS_MODULE_PARAM ' +
          '(MODULE_NAME,FUNCTION_NAME,PARAME_NAME,PARAME_ITEM,PARAME_VALUE,UPDATE_USERID )' +
          'Values (:MODULE_NAME,:FUNCTION_NAME,:PARAME_NAME,:PARAME_ITEM,:PARAME_VALUE,:UPDATE_USERID) ';
        Params.ParamByName('MODULE_NAME').AsString := Uppercase(gsLabelType) + ' RULE';
        Params.ParamByName('FUNCTION_NAME').AsString := g_sRule;
        Params.ParamByName('PARAME_NAME').AsString := ParamName;
        Params.ParamByName('PARAME_ITEM').AsString := ParamItem;
        Params.ParamByName('PARAME_VALUE').AsString := ParamValue;
        Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
        Execute;
        Close;
      end
      else
      begin
        sRow := FieldByName('rowid').AsString;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'parame_value', ptInput);
        Params.CreateParam(ftString, 'Data', ptInput);
        CommandText := 'update sajet.sys_module_param '
          + 'set parame_value = :parame_value '
          + 'where rowid = :Data ';
        Params.ParamByName('PARAME_VALUE').AsString := ParamValue;
        Params.ParamByName('Data').AsString := sRow;
        Execute;
        Close;
      end;
    end;
  end;
  procedure CopyToHistory(RecordID: string);
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
begin
  if not QryData.Active then Exit;

  if QryData.RecordCount <= 0 then Exit;

  if trim(editLabelNo.Text) = '' then exit;

  iSubBoardQty := StrToIntDef(editSNCount.Text,0);
  if iSubBoardQty = 0 then
  begin
    MessageDlg(gsLabelType+' Qty Error !',mtError,[mbOK],0);
    editSNCount.SetFocus;
    editSNCount.SelectAll;
    exit;
  end;
  if iSubBoardQty > giQty then
  begin
    Messagedlg(gsLabelType+' Qty Can not more than : ( '+ IntToStr(giQty)+' ) ',mtError,[mbOK],0);
    editSNCount.SetFocus;
    editSNCount.SelectAll;
    exit;
  end;




  if gsType = 'Y' then
  begin
    if (Pos(' ', editLabelNo.Text) <> 0) then
    begin
      MessageDlg('Please keyin Default ' + gsLabelType + '.', mtError, [mbOK], 0);
      exit;
    end;
//    if (StrToInt(LabQty.Caption) + StrToInt(editQty.Text) * giQty) > StrToInt(dbtxtTarget.Caption) then
    if (StrToInt(LabQty.Caption) + StrToInt(editQty.Text) * iSubBoardQty) > StrToInt(dbtxtTarget.Caption) then
    begin
      MessageDlg('Release Qty > Target Qty!!', mtError, [mbOK], 0);
      Exit;
    end;
    if not checkCode then
    begin
      MessageDlg('Start Number NG!!', mtError, [mbOK], 0);
      Exit;
    end;
  end
  else
  begin
    if gsType = 'S' then
      if not CheckRule(editQty.Text, sStart) then
        Exit;
    if not CheckRule(edtStart.Text, sStart) then
      Exit;
  end;
  if gsType = 'S' then // 先產生序號, 再附與
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'sMAC', ptInput);
      Params.CreateParam(ftString, 'eMAC', ptInput);
      CommandText := 'select work_order, count(*) from ' + gsTable
        + ' where ' + gsField + ' >= :sMac '
        + ' and ' + gsField + ' <= :eMac '
        + ' group by work_order ';
      Params.ParamByName('sMAC').AsString := editQty.Text;
      Params.ParamByName('eMAC').AsString := edtStart.Text;
      Open;
      if IsEmpty then
      begin
        MessageDlg(gsLabelType + ' not Exist!!', mtError, [mbOK], 0);
        editQty.SetFocus;
        Close;
        Exit;
      end
      else if RecordCount > 1 then
      begin
        MessageDlg(gsLabelType + ' have been Used - ' + FieldByName('work_order').AsString + '!!', mtError, [mbOK], 0);
        editQty.SetFocus;
        Close;
        Exit;
      end
      else if FieldByName('work_order').AsString <> '' then
      begin
        MessageDlg(gsLabelType + ' have been Used - ' + FieldByName('work_order').AsString + '!!', mtError, [mbOK], 0);
        editQty.SetFocus;
        Close;
        Exit;
{      end
      else if FieldByName('count(*)').AsInteger > edtQty.Value * giQty then
      begin
        iQty := edtQty.Value - FieldByName('count(*)').AsInteger div giQty;
        MessageDlg(gsLabelType + ' not enough - ' + IntToStr(iQty) + '!!', mtError, [mbOK], 0);
        editQty.SetFocus;
        Close;
        Exit;}
      end;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
      Params.CreateParam(ftString, 'Field1', ptInput);
      Params.CreateParam(ftString, 'Field2', ptInput);
      CommandText := 'update ' + gsTable
        + ' set WORK_ORDER = :WORK_ORDER, UPDATE_USERID = :UPDATE_USERID, UPDATE_TIME = SYSDATE '
        + ' WHERE ' + gsField + '>= :Field1 and ' + gsField + ' <= :Field2';
      Params.ParamByName('WORK_ORDER').AsString := editWO.Text;
      Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
      Params.ParamByName('Field1').AsString := editQty.Text;
      Params.ParamByName('Field2').AsString := edtStart.Text;
      Execute;
      Close;
      if SetupValue.bPrintLabel then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'sMAC', ptInput);
        Params.CreateParam(ftString, 'eMAC', ptInput);
        CommandText := 'select work_order, ' + gsField + ' from ' + gsTable
          + ' where ' + gsField + ' >= :sMac '
          + ' and ' + gsField + ' <= :eMac ';
        Params.ParamByName('sMAC').AsString := editQty.Text;
        Params.ParamByName('eMAC').AsString := edtStart.Text;
        Open;
        slLabel := TStringList.Create;
        while not Eof do
        begin
          slLabel.Add(sLabelNo);
          Next;
        end;
        Close;
      end;
    end;
  end
  else
  begin
    if gsType = 'Y' then // 有Sequence
    begin
      //動態建立此規則的Sequence
      if not CreateRuleSeq(g_sRule) then
      begin
        MessageDlg('Start Number Error!!', mtError, [mbOK], 0);
        Exit;
      end;
      QryGetSeq.Close;
      QryGetSeq.Params.Clear;
      QryGetSeq.CommandText := 'Select ' + cSeqName + g_sRule + '.NEXTVAL SNID From Dual ';
      SaveToDB('Reset Sequence Mark', '', gsMark);
    end
    else
    begin
      iStart := SeqCode(sStart);
      sEnd := CodeNum(iStart + StrToInt(editQty.Text) - 1);
      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'sMAC', ptInput);
        Params.CreateParam(ftString, 'eMAC', ptInput);
        CommandText := 'select work_order, ' + gsField + ' from ' + gsTable
          + ' where ' + gsField + ' >= :sMac '
          + ' and ' + gsField + ' <= :eMac '
          + ' and rownum = 1';
        Params.ParamByName('sMAC').AsString := edtStart.Text;
        Params.ParamByName('eMAC').AsString := sEnd;
        Open;
        if not IsEmpty then
        begin
          MessageDlg(gsLabelType + ' have been Used - ' + FieldByName('work_order').AsString, mtError, [mbCancel], 0);
          edtStart.SetFocus;
          Close;
          Exit;
        end;
        Close;
      end;
    end;
    with QryTemp do
    begin
      Close;
      Params.Clear;
      if gsLabelType = 'Serial Number' then
      begin
        Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
        Params.CreateParam(ftString, 'MODEL_ID', ptInput);
        Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
        Params.CreateParam(ftString, 'ROUTE_ID', ptInput);
        Params.CreateParam(ftString, 'Version', ptInput);
        Params.CreateParam(ftString, 'EMP_ID', ptInput);
        CommandText := 'Insert Into SAJET.G_SN_STATUS ' +
          '(WORK_ORDER,MODEL_ID,SERIAL_NUMBER,ROUTE_ID,Version,EMP_ID) ' +
          'Values (:WORK_ORDER,:MODEL_ID,:SERIAL_NUMBER,:ROUTE_ID,:Version,:EMP_ID)';
      end
      else
      begin
        Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
        Params.CreateParam(ftString, 'LABEL_NO', ptInput);
        Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
        CommandText := 'Insert Into ' + gsTable +
          '(WORK_ORDER,' + gsField + ',UPDATE_USERID) ' +
          'Values (:WORK_ORDER,:LABEL_NO,:UPDATE_USERID)';
      end;
    end;
    slLabel := TStringList.Create;
    for I := 1 to StrToIntDef(editQty.Text, 1) do
    begin
      if gsType = 'Y' then
        sLabelNo := CodeNum(GetSeq)
      else
        sLabelNo := CodeNum(iStart);
      if giQty <> 1 then
        SaveCode(sLabelNo,iSubBoardQty)
      else if gsLabelType = 'Serial Number' then
        SaveSN(sLabelNo)
      else
        SaveLabel(sLabelNo);
      if SetupValue.bPrintLabel then
        slLabel.Add(sLabelNo);
      if gsType <> 'Y' then
        Inc(iStart);
      Shape1.Width := StrToInt(formatfloat('00', (I / StrToIntDef(editQty.Text, 1) * 590)));
      Shape1.Refresh;
    end;
  end;
  if gsLabelType = 'Serial Number' then
    if StrToIntDef(editQty.Text, 1) > 1 then
    begin
      if QryData.FieldByName('WO_STATUS').AsInteger <= 1 then
      begin
        with QryTemp do
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'UserID', ptInput);
          Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
          CommandText := 'Update SAJET.G_WO_BASE ' +
            'Set WO_STATUS = ''2'',' +
            'UPDATE_USERID = :UserID,' +
            'UPDATE_TIME = SYSDATE ' +
            'Where WORK_ORDER = :WORK_ORDER ';
          Params.ParamByName('UserID').AsString := UpdateUserID;
          Params.ParamByName('WORK_ORDER').AsString := Trim(editWO.Text);
          Execute;
        end;
        CopyToHistory(Trim(editWO.Text));
      end;
    end;
  Shape1.Width := 0;
  if SetupValue.bPrintLabel then
  begin
    for I := 0 to slLabel.Count - 1 do
    begin
      sLabelNo := slLabel[i];
      if SetupValue.sPrintMethod = 'CodeSoft' then
      begin
        if gsLabelType2 <> '' then
          sPrintData := G_getPrintData(SetupValue.iCodeSoftVersion, 15, G_sockConnection, 'DspQryData', gsLabelType2 + '*&*' + sLabelNo, SetupValue.iQtyLabel, g_sRule)
        else
          sPrintData := G_getPrintData(SetupValue.iCodeSoftVersion, 15, G_sockConnection, 'DspQryData', gsLabelType + '*&*' + sLabelNo, SetupValue.iQtyLabel, g_sRule);
        if Assigned(G_onTransDataToApplication) then
          G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
        else
          showmessage('Not Defined Call Bcak Function for CodeSoft');
      end
      else
      begin
        try
          try
            g_tsParam := TStringList.create;
            g_tsData := TStringList.create;
            if gsLabelType2 <> '' then
            begin
              if not G_getBCData(G_sockConnection, 'DspQryData', gsLabelType2, sLabelNo, g_tsParam, g_tsData, gsFileName) then raise Exception.Create('Get ' + gsLabelType2 + '(' + sLabelNo + ') Data Fail')
            end else
            begin
              if not G_getBCData(G_sockConnection, 'DspQryData', gsLabelType, sLabelNo, g_tsParam, g_tsData, gsFileName) then raise Exception.Create('Get ' + gsLabelType + '(' + sLabelNo + ') Data Fail');
            end;  
            if not SendBCData(SetupValue.iQtyLabel, g_tsParam, g_tsData, SetupValue.sComPort, SetupValue.sBaudRate, QryData.FieldByName('Part_No').AsString, gsFileName,I) then exit; //PrintBCSNdll.DLL
          //  if not G_getSNData(G_sockConnection, 'DspQryData', sLabelNo, g_tsParam, g_tsData) then raise Exception.Create('Get ' + gsLabelType + '(' + sLabelNo + ') Data Fail');
          //  if not SendBCData(SetupValue.iQtyLabel, g_tsParam, g_tsData, SetupValue.sComPort, SetupValue.sBaudRate, QryData.FieldByName('Part_No').AsString, gsFileName,I) then exit; //PrintBCSNdll.DLL
          finally
            g_tsParam.Free;
            g_tsData.free;
          end;
        except
          on e:exception do
          begin
            MessageDlg(e.message,mtError,[mbOK],0);
          end;
        end;  
      end;
      Shape1.Width := StrToInt(formatfloat('00', (I + 1) / slLabel.Count * 590));
      Shape1.Refresh;
    end;
  end;
  Shape1.Width := 0;
  slLabel.Free;
  ShowWoData(True);
end;

procedure TfDetail.sbtnInitialClick(Sender: TObject);
var sLabelFile:String;
begin
  if QryData.Active then
    if not QryData.IsEmpty then
    begin
      LabMessage.Caption := 'Initial Now,Please Wait...';
      LabMessage.Repaint;
      if not BCInitial(SetupValue.sComPort, SetupValue.sBaudRate, QryData.FieldByName('Part_No').AsString, gsFileName,gsLabelFile) then exit;
      LabMessage.Caption := '';
      LabMessage.Repaint;
    end;
end;

procedure TfDetail.sbtnFailSNClick(Sender: TObject);
begin
  with TfCommData.Create(Self) do
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      if editWo.Text <> '' then
        Params.CreateParam(ftString, 'work_order', ptInput);
      CommandText := 'select A.work_order "Work Order", A.target_qty "Target Qty", '
        + 'B.part_no "Part No", B.part_type "Part Type", B.spec1 "Spec1", B.spec2 "Spec2" '
        + 'from sajet.g_wo_base a, sajet.sys_part b '
        + 'where wo_status > 0 and wo_status < 5 ';
      if gsLabelType = 'Serial Number' then
        CommandText := CommandText + 'and input_qty <> target_qty ';
      if editWo.Text <> '' then
        CommandText := CommandText + 'and work_order like :work_order ';
      CommandText := CommandText + 'and a.model_id = b.part_id '
        + 'order by work_order ';
      if editWo.Text <> '' then
        Params.ParamByName('work_order').AsString := editWo.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      editWo.Text := QryTemp.FieldByName('work order').AsString;
      QryTemp.Close;
      ShowWOData(False);
      editWo.SetFocus;
      editWo.SelectAll;
    end;
    free;
  end;
end;

procedure TfDetail.FormDestroy(Sender: TObject);
begin
  NumUdf.Free;
  CarryM.Free;
  CarryD.Free;
  CarryW.Free;
//  StopComm;
end;

procedure TfDetail.editSNCountKeyPress(Sender: TObject; var Key: Char);
begin
  if not (KEY in ['0'..'9',#13,#8]) then Key:=#0;
end;

end.

