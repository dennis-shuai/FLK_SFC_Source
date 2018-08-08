unit uPacking;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db, Variants,
  DBClient, MConnect, SConnect, IniFiles, ObjBrkr, unitCSPrintData,
  ImgList;

type
  TCheckWeightData = function: Real; stdcall;
  // 2007.05.23新增 客製畫面
  TAdditionalData = function(tsInParam,tsInData:TStrings;parentSocketConnection : TSocketConnection): Boolean; stdcall;
  TAssyData = function(tsInParam,tsInData:TStrings;parentSocketConnection : TSocketConnection): Boolean; stdcall;
  TfPacking = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    LabSN: TLabel;
    editSN: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    LabPN: TLabel;
    LabCartonInfo: TLabel;
    LabPalletInfo: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    LabCarton: TLabel;
    lablCartonCap: TLabel;
    LabPallet: TLabel;
    LabPalCap: TLabel;
    LabCartonCap: TLabel;
    LabCartonQty: TLabel;
    LabPalletCap: TLabel;
    LabPalletQty: TLabel;
    sbtnCloseCarton: TSpeedButton;
    Image3: TImage;
    sbtnClosePallet: TSpeedButton;
    Image1: TImage;
    LabCSN: TLabel;
    editCSN: TEdit;
    editCarton: TEdit;
    Image4: TImage;
    Label26: TLabel;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    LabTerminal: TLabel;
    SProc: TClientDataSet;
    editPallet: TEdit;
    editMO: TEdit;
    panl1: TPanel;
    Label4: TLabel;
    Image5: TImage;
    sbtnChangeSpec: TSpeedButton;
    Label6: TLabel;
    LVData: TListView;
    ImageList1: TImageList;
    GBInitial: TGroupBox;
    Image6: TImage;
    sbtnPalletIni: TSpeedButton;
    Image7: TImage;
    Image8: TImage;
    sbtnCartonIni: TSpeedButton;
    sbtnCustini: TSpeedButton;
    panlMessage: TLabel;
    listSN: TListBox;
    lstField: TListBox;
    lstValue: TListBox;
    lablWeight: TLabel;
    chkWeight: TCheckBox;
    edtWeight: TEdit;
    ImageNG: TImage;
    edtWeight2: TEdit;
    lablCartonDiv: TLabel;
    labPalDiv: TLabel;
    LabBoxInfo: TLabel;
    Image2: TImage;
    sbtnCloseBox: TSpeedButton;
    Bevel3: TBevel;
    LabBox: TLabel;
    editBox: TEdit;
    LabBCap: TLabel;
    LabBoxQty: TLabel;
    labBoxDiv: TLabel;
    LabBoxCap: TLabel;
    Image9: TImage;
    sbtnBoxIni: TSpeedButton;
    lablLine: TLabel;
    lablVersion: TLabel;
    lvEC: TListView;
    lablErrorCode: TLabel;
    sbtnWoFilter: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure editSNKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnCloseCartonClick(Sender: TObject);
    procedure sbtnClosePalletClick(Sender: TObject);
    procedure editCSNKeyPress(Sender: TObject; var Key: Char);
    procedure editCartonKeyPress(Sender: TObject; var Key: Char);
    procedure editPalletKeyPress(Sender: TObject; var Key: Char);
    procedure Label3Click(Sender: TObject);
    procedure editMOKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnChangeSpecClick(Sender: TObject);
    procedure sbtnPalletIniClick(Sender: TObject);
    procedure sbtnCartonIniClick(Sender: TObject);
    procedure sbtnCustiniClick(Sender: TObject);
    procedure editBoxKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnCloseBoxClick(Sender: TObject);
    procedure sbtnBoxIniClick(Sender: TObject);
    // 2007.05.23 FormClose改為FormDestory
    procedure FormDestroy(Sender: TObject);
    procedure sbtnWoFilterClick(Sender: TObject);
  private
    { Private declarations }
    CheckWeightData: TCheckWeightData;
    // 2007.05.23新增 客製畫面  AdditionalData, m_DLLHandle1
    AdditionalData: TAdditionalData;
    m_DLLHandle, m_DLLHandle1,m_DLLHandle2: THandle;
    AssyData: TAssyData; //2007/6/22 附件包裝 AssyData,m_DLLHandle2
  public
    { Public declarations }
    mWO, mPartID, mPartNo, gSNWo, gSN, gsCheckSum, mLabelFile, mCustPartNo: string;
    mCarry: string;
    mDateCode: string;
    UpdateUserID, UpdateUserNo, gsLoginUser: string;
    mCode, mCodeNo, mCodeDef: string;
    Authoritys, AuthorityRole: string;
    SNNO, CSNNo, CartonNo, PalletNo, BoxNo: string;
    AutoClose, NoCartonRule, NoBoxRule, bNoPopUp, ShowEmpty: Boolean;
    sPKSpec: string;
    mPalletComPort, mCartonComPort, mCSNComPort: string;
    mPalletBaudRate, mCartonBaudRate, mCSNBaudRate: string;
    mBoxComPort, mBoxBaudRate, gsRuleFunction: string;
    gsPallet, gsCarton, gsBox: string;
    g_MultiFlag, gsWeightFail, gsLoadWeight, gbCycle,gbRefreshQty,gbShowCloseMsg: Boolean;
    G_iClosePrivilege:Integer;
    // 2007.05.23新增 客製畫面 begin
    g_bAdditional,g_bLoadAdditional:Boolean;
    g_tsAddParam,g_tsAddData:tstrings;
    // End
    g_bPackAssy,g_bLoadAssy:Boolean; //2007/6/21 附件包裝
    g_tsAssyParam,g_tsAssyData:tstrings;
    g_bInputEC:Boolean; //2007/08/16 是否可輸入不良代碼
    procedure loadSajetDll(f_sDllName: string);
    function GetTerminalID: Boolean;
    function GetCfgData: Boolean;
    function InputSN: Boolean;
    function CheckSN: Boolean;
    function CheckDupCSN: Boolean;
    function CheckDupBox: Boolean;
    function CheckDupCarton: Boolean;
    function CheckDupPallet: Boolean;
    function GetUnfinishBox: Boolean;
    function GetUnfinishCarton: Boolean;
    function GetUnfinishPallet: Boolean;
    function GetPackSpec: Boolean;
    function GetPackBoxQty: Boolean;
    function GetPackCartonQty: Boolean;
    function GetPackPalletQty: Boolean;
    function GetNewNo(NoType: string; var NewNo: string): Boolean;
    function GetBox: Boolean;
    function GetCarton: Boolean;
    function GetPallet: Boolean;
    function GetUserNo(sUserID: string): string;
    procedure CreateBox;
    procedure AppendBoxNo;
    procedure AppendCartonNo;
    procedure AppendPalletNo;
    procedure SetStatusbyAuthority;
    procedure SetEditStatus(Kind: string);
    procedure GetLastPackSpec;
    procedure GetPack(sSpecName, sClosePallet: string);
    function CallDllPrint(iType: integer): Boolean;
    procedure ShowPackSpec;
    procedure PackGo(sValue, sType: string);
    function CheckRule(NoType, sInputNo: string): Boolean;
    function CheckCarton(var sType: string): Boolean;
    function CheckBox(var sType: string): Boolean;
    function F_CHK_CLOSE_CARTON(sCartonNo: string): Boolean;
    function F_CHK_CLOSE_BOX(sBoxNo: string): Boolean;
    procedure ShowMsg(sMsg, sType: string);
    function CheckWeight: Boolean;
    procedure ShowPackAction;
    procedure UpdatePackTerminal;
    function ShowClose(sType: string): string;
    procedure GetVersion(S: string);
    //===add by rita=====================================
    function CheckDefect(psDefectCode:String): Boolean;
    function InputErrorSN:Boolean;
    //===================================================
    // 2007.05.23新增 客製畫面 begin
    function CallAdditionalDll:Boolean;
    procedure LoadAdditionalDll(f_sDllName: string);
    // 2007.05.23新增 客製畫面 end
    function checkChangeUserClosePrivilege:Boolean;

    procedure LoadAssyDll(f_sDllName: string);
    function CallAssyDll:Boolean;

    function RefreshPalletQty(sPallet:string): Boolean;
    function RefreshCartonQty(sCarton:string): Boolean;
    function RefreshBoxQty(sBox:string): Boolean;
    function checkpdlinestatus(TTerminalID:string):boolean;
  end;

var
  fPacking: TfPacking;
  CarryM, CarryD, CarryW, CarryK: TStrings;
  SNUdf: TStringList;
  Carry16: string;
  g_sSN: string;
  g_iSEQ: integer;
function SendData(iType, PrintLabQty: integer; tsParam, tsData: TStrings; PComPort, PBaudRate: string; G_sockConnection: TSocketConnection): Boolean; stdcall; external 'PackingPrintdll.DLL';
function PrintInitial(iType: integer; PcomPort, PBaudRate, sPartNo, sWO, sCustPartNo, sLabelFile: string): Boolean; stdcall; external 'PackingPrintdll.DLL';
function G_getPrintData(f_iVersion, f_iType: integer; f_SocketConnection: TSocketConnection; f_sProvideName, f_sKeyWord: string; f_iQty: integer; f_sRuleName: string; var g_tsParam, g_tsData: tstrings): string; stdcall; external 'GetPrintDataDll.DLL';
implementation

{$R *.DFM}

uses uDllform, Dllinit, uPackSpec, uFilter, uPFilter, uConfirm, uPassword;

var
  TerminalID,G_sProcessID,G_sLineID,G_sStageID: string;
  AutoCreateBox, PrintBoxLabel, CheckBoxeqSN,
    AutoCreateCSN, PrintCSNLabel, NotChangeCSN,
    AutoCreateCarton, PrintCartonLabel, CheckCSNeqSN,
    AutoCreatePallet, PrintPalletLabel: Boolean;
  PrintBoxMethod, PrintCSNMethod, PrintCartonMethod, PrintPalletMethod: string;
  PrintBoxLabQty, PrintCSNLabQty, PrintCartonLabQty, PrintPalletLabQty: Integer;
  PackingBase: string; PackAction: Integer;
  CodesoftVersion: Byte;

function TfPacking.checkpdlinestatus(TTerminalID:string):boolean;
var sres:string;
begin
   result:=false;
   with sproc do
   begin
     try
         Close;
         DataRequest('SAJET.SJ_CKRT_PDLINE_STATUS');
         FetchParams;
         Params.ParamByName('TTERMINALID').AsString := TTerminalID;
         Execute;
         sRes := Params.ParamByName('TRES').AsString;
     except
     end;
     Close;
  end;

  if sRes <> 'OK' then
  begin
    ShowMsg(sRes, 'ERROR');
    Exit;
  end;
  Result := True;
end;

function TfPacking.checkChangeUserClosePrivilege:Boolean;
begin
   Result := False;

   with TfPassword.Create(Self) do
   begin
      if ShowModal = mrOK then
      begin
         with sproc do
         begin
          try
            Close;
            DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
            FetchParams;
            Params.ParamByName('EMPID').AsString := m_sEmpID;
            Params.ParamByName('PRG').AsString := 'Packing';
            Params.ParamByName('FUN').AsString := 'Close Pallet(Carton)';
            Execute;
            if Params.ParamByName('TRES').AsString = 'OK' then
            begin
               Result := (Params.ParamByName('PRIVILEGE').AsInteger >= 1);
            end;
          finally
            close;
          end;
         end;
      end;
   end;
end;

function TfPacking.CheckRule(NoType, sInputNo: string): Boolean;
var sCode, sDefault, sM, sD, sW, uM, uD, uK, uW, sP, sQ, sR, sF, sSeqType, S: string;
  i, iR, j: integer; slValue: TStringList;
  sField1, sType1, sField2, sType2, sField3, sType3, sValue: string;
begin
  SNUdf.Clear;
  Result := True;

  {update by key 2008/01/22
   線外列印的pallet,carton,box input 時，不能CSAN SSN.
   了為能夠scan ssn 把
    if gsRuleFunction <> '' then
    改成
  　if (gsRuleFunction <> '') and NoType<>'SSN' then

   }
 // if gsRuleFunction <> '' then
  if (gsRuleFunction <> '') and ( NoType<>'SSN' ) then
  begin
    with qryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select ' + gsRuleFunction + '(''' + NoType + ''',''' + sInputNo + ''') result from dual ';
      Open;
      if FieldByName('result').AsString <> 'OK' then
      begin
        Result := False;
        ShowMsg(FieldByName('result').AsString, 'ERROR');
      end;
      Close;
    end;
  end
  else
  begin
    with qryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
      CommandText := 'SELECT * FROM SAJET.G_WO_PARAM '
        + 'WHERE WORK_ORDER = :WORK_ORDER '
        + 'AND MODULE_NAME = :MODULE_NAME ';
      Params.ParamByName('WORK_ORDER').AsString := mWO;
      if NoType = 'Carton' then
        Params.ParamByName('MODULE_NAME').AsString := 'CARTON NO RULE'
      else if NoType = 'Box' then
        Params.ParamByName('MODULE_NAME').AsString := 'BOX NO RULE'
      else if NoType = 'Pallet' then
        Params.ParamByName('MODULE_NAME').AsString := 'PALLET NO RULE'
      else
        Params.ParamByName('MODULE_NAME').AsString := 'CUSTOMER SN RULE';
      Open;
      if not IsEmpty then
      begin
        if Locate('PARAME_ITEM', 'Code', []) then
          sCode := FieldByName('parame_value').asstring
        else
          exit;
        if Locate('PARAME_ITEM', 'Default', []) then
          sDefault := FieldByName('parame_value').asstring
        else
          exit;
        if Locate('PARAME_ITEM', 'Code Type', []) then
          sSeqType := FieldByName('parame_value').asstring;
        if Locate('PARAME_NAME', '1-Digit Type & Field', []) then
        begin
          sField1 := Fieldbyname('PARAME_VALUE').AsString;
          sType1 := Fieldbyname('PARAME_ITEM').AsString;
        end;
        if Locate('PARAME_NAME', '2-Digit Type & Field', []) then
        begin
          sField2 := Fieldbyname('PARAME_VALUE').AsString;
          sType2 := Fieldbyname('PARAME_ITEM').AsString;
        end;
        if Locate('PARAME_NAME', '3-Digit Type & Field', []) then
        begin
          sField3 := Fieldbyname('PARAME_VALUE').AsString;
          sType3 := Fieldbyname('PARAME_ITEM').AsString;
        end;
        First;
        while not Eof do begin
          if (Fieldbyname('PARAME_NAME').AsString = 'Carton No User Define') or
            (Fieldbyname('PARAME_NAME').AsString = 'Pallet No User Define') or
            (Fieldbyname('PARAME_NAME').AsString = 'Box No User Define') or
            (Fieldbyname('PARAME_NAME').AsString = 'Customer SN User Define') then
            SNUdf.Add(Fieldbyname('PARAME_ITEM').AsString + ' : ' +
              Fieldbyname('PARAME_VALUE').AsString);
          Next;
        end;
        //檢查長度
        if Length(sCode) <> Length(sInputNo) then
        begin
          Result := False;
          ShowMsg('Rule not match (Length)', 'ERROR');
          exit;
        end;
        //檢查固定碼
        sM := ''; sD := ''; sW := ''; uM := ''; uK := ''; uD := ''; uW := ''; sR := ''; sF := ''; sP := ''; sQ := '';
        for i := 1 to length(sCode) do
        begin
          if sCode[i] in ['A', 'C', 'L', '9'] then
          begin
            if (sDefault[i] <> ' ') and (sDefault[i] <> sInputNo[i]) then
            begin
              Result := False;
              ShowMsg('Rule not match (Fix Character)', 'ERROR');
              exit;
            end;
          end
          else if sCode[i] = 'Y' then
          begin
            if StrToIntDef(sInputNo[i], -1) = -1 then
            begin
              Result := False;
              ShowMsg('Rule not match (Year)', 'ERROR');
              exit;
            end;
          end
          else if sCode[i] = 'K' then
          begin
            if sInputNo[i] in ['1'..'7'] then
            else
            begin
              Result := False;
              ShowMsg('Rule not match (Day of Week)', 'ERROR');
              exit;
            end;
          end
          else if sCode[i] = 'S' then
          begin
            if sSeqType = '10' then
            begin
              if StrToIntDef(sInputNo[i], -1) = -1 then
              begin
                Result := False;
                ShowMsg('Rule not match (Sequence)', 'ERROR');
                exit;
              end;
            end
            else
            begin
              if sInputNo[i] in ['0'..'F'] then
              else
              begin
                Result := False;
                ShowMsg('Rule not match (Sequence)', 'ERROR');
                exit;
              end;
            end;
          end
          else if sCode[i] = 'P' then
            sP := sP + sInputNo[i]
          else if sCode[i] = 'Q' then
            sQ := sQ + sInputNo[i]
          else if sCode[i] = 'R' then
            sR := sR + sInputNo[i]
          else if sCode[i] = 'M' then
            sM := sM + sInputNo[i]
          else if sCode[i] = 'D' then
            sD := sD + sInputNo[i]
          else if sCode[i] = 'W' then
            sW := sW + sInputNo[i]
          else if sCode[i] = 'm' then
            uM := uM + sInputNo[i]
          else if sCode[i] = 'k' then
            uK := uK + sInputNo[i]
          else if sCode[i] = 'd' then
            uD := uD + sInputNo[i]
          else if sCode[i] = 'w' then
            uW := uW + sInputNo[i]
          else begin
            for j := 0 to SNUdf.Count - 1 do begin
              if Copy(SNUdf.Strings[j], 1, 1) = sCode[i] then
              begin
                S := Trim(Copy(SNUdf.Strings[j], POS(':', SNUdf.Strings[j]) + 1, Length(SNUdf.Strings[j]) - POS(':', SNUdf.Strings[j])));
                if Pos(sInputNo[i], S) = 0 then begin
                  Result := False;
                  ShowMsg('Rule not match (User Define Sequence)', 'ERROR');
                  exit;
                end;
                break;
              end;
            end;
          end; // if
        end; // for
      end; // if
      slValue := TStringList.Create;
      if uM <> '' then
      begin
        Locate('PARAME_NAME', 'Month User Define', []);
        slValue.CommaText := Fieldbyname('PARAME_VALUE').AsString;
        if slValue.IndexOf(uM) = -1 then
        begin
          slValue.Free;
          Result := False;
          ShowMsg('Rule not match (Month User Define)', 'ERROR');
          exit;
        end;
      end;
      if uD <> '' then
      begin
        Locate('PARAME_NAME', 'Day User Define', []);
        slValue.CommaText := Fieldbyname('PARAME_VALUE').AsString;
        if slValue.IndexOf(uD) = -1 then
        begin
          slValue.Free;
          Result := False;
          ShowMsg('Rule not match (Day User Define)', 'ERROR');
          exit;
        end;
      end;
      if uW <> '' then
      begin
        Locate('PARAME_NAME', 'Week User Define', []);
        slValue.CommaText := Fieldbyname('PARAME_VALUE').AsString;
        if slValue.IndexOf(uW) = -1 then
        begin
          slValue.Free;
          Result := False;
          ShowMsg('Rule not match (Week User Define)', 'ERROR');
          exit;
        end;
      end;
      if uK <> '' then
      begin
        Locate('PARAME_NAME', 'Day of Week User Define', []);
        slValue.CommaText := Fieldbyname('PARAME_VALUE').AsString;
        if slValue.IndexOf(uK) = -1 then
        begin
          slValue.Free;
          Result := False;
          ShowMsg('Rule not match (Day of Week User Define)', 'ERROR');
          exit;
        end;
      end;
      slValue.Free;
      if sField1 <> '' then
      begin
        sValue := lstValue.Items[lstField.Items.IndexOf(sField1)];
        with QryTemp do
        begin
          Close;
          Params.Clear;
          CommandText := 'select ' + sType1 + '(''' + sValue + ''') snid from dual ';
          Open;
          sValue := FieldByName('snid').AsString;
        end;
        if sP <> sValue then
        begin
          Result := False;
          ShowMsg('Rule not match (1-Option)', 'ERROR');
          exit;
        end;
      end;
      if sField2 <> '' then
      begin
        sValue := lstValue.Items[lstField.Items.IndexOf(sField2)];
        with QryTemp do
        begin
          Close;
          Params.Clear;
          CommandText := 'select ' + sType2 + '(''' + sValue + ''') snid from dual ';
          Open;
          sValue := FieldByName('snid').AsString;
        end;
        if sQ <> sValue then
        begin
          Result := False;
          ShowMsg('Rule not match (2-Option)', 'ERROR');
          exit;
        end;
      end;
      if sField3 <> '' then
      begin
        sValue := lstValue.Items[lstField.Items.IndexOf(sField3)];
        with QryTemp do
        begin
          Close;
          Params.Clear;
          CommandText := 'select ' + sType3 + '(''' + sValue + ''') snid from dual ';
          Open;
          sValue := FieldByName('snid').AsString;
        end;
        if sR <> sValue then
        begin
          Result := False;
          ShowMsg('Rule not match (3-Option)', 'ERROR');
          exit;
        end;
      end;
      if sM <> '' then
      begin
        iR := StrToIntDef(sM, -1);
        if (iR < 1) or (iR > 12) then
        begin
          Result := False;
          ShowMsg('Rule not match (Month)', 'ERROR');
          exit;
        end;
      end;
      if sD <> '' then
      begin
        iR := StrToIntDef(sD, -1);
        if (iR < 1) or (iR > 31) then
        begin
          Result := False;
          ShowMsg('Rule not match (Day)', 'ERROR');
          exit;
        end;
      end;
      if sW <> '' then
      begin
        iR := StrToIntDef(sW, -1);
        if (iR < 1) or (iR > 53) then
        begin
          Result := False;
          ShowMsg('Rule not match (Week)', 'ERROR');
          exit;
        end;
      end;
      if sF <> '' then
      begin
        iR := StrToIntDef(sF, -1);
        if (iR < 1) or (iR > 366) then
        begin
          Result := False;
          ShowMsg('Rule not match (Day of Year)', 'ERROR');
          exit;
        end;
      end;
      Close;
    end;
  end;
end;

function TfPacking.GetNewNo(NoType: string; var NewNo: string): Boolean;
  function GetMaxSeq(sSNCode, SNDef: string): string;
  var S: string; i, j: integer; iSeq: Real;
  begin
    S := sSNCode;
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
        for j := 0 to SNUdf.Count - 1 do
          if S[I] = Copy(SNUdf.Strings[J], 1, 1) then
          begin
            iSeq := iSeq * (Length(SNUdf.Strings[j]) - 4);
            break;
          end;
      end;
    Result := FloatToStr(iSeq - 1);
  end;
  procedure CreateSeq(RuleName: string; iLength: Integer; sSNCode, sSNDef: string);
  var sTemp: string;
  begin
    sTemp := GetMaxSeq(sSNCode, sSNDef);
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'CREATE SEQUENCE ' + RuleName + ' INCREMENT BY 1 START WITH 1 MAXVALUE ' + sTemp + ' NOCYCLE NOCACHE ORDER';
      Execute;
      Close;
      Params.Clear;
      CommandText := 'GRANT SELECT ON ' + RuleName + ' TO SYS_USER';
      Execute;
      Close;
    end;
  end;
  procedure SavetoDB(ParamName, ParamItem, ParamValue, sModule, sRuleName: string);
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
      Params.ParamByName('MODULE_NAME').AsString := sModule;
      Params.ParamByName('FUNCTION_NAME').AsString := sRuleName;
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
        Params.ParamByName('MODULE_NAME').AsString := sModule;
        Params.ParamByName('FUNCTION_NAME').AsString := sRuleName;
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
var mDY, mDM, mDD, mDW, mDK, mcDM, mcDD, mcDW, mDYW, mcDK, sModule: string; mDate: TDateTime;
  sSNCode, sSEQ, sSNDef, sSeqName, S, S1, gsMark, sRuleName: string;
  sType1, sField1, sType2, sField2, sType3, sField3, sValue1, sValue2, sValue3: string;
  I, J, mMod, mDiv, iCycle: Integer; bReset: Boolean;
begin
  Result := False;
  SNUdf.Clear;
   // 讀取 Carton or Pallet or Customer SN編碼規則
  LabCartonQty.Visible := LabCartonCap.Visible;
  sField1 := ''; sField2 := ''; sField3 := '';
  if NoType = 'Carton' then
    sModule := 'CARTON NO RULE'
  else if NoType = 'Pallet' then
    sModule := 'PALLET NO RULE'
  else if NoType = 'Box' then
    sModule := 'BOX NO RULE'
  else
    sModule := 'CUSTOMER SN RULE';
  with qryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    CommandText := 'SELECT * ' +
      'FROM SAJET.G_WO_PARAM ' +
      'WHERE WORK_ORDER = :WORK_ORDER AND ' +
      'MODULE_NAME = :MODULE_NAME ';
    Params.ParamByName('WORK_ORDER').AsString := mWO;
    Params.ParamByName('MODULE_NAME').AsString := sModule;
    Open;
      //======System Create,且無設定編碼規則=======
    if IsEmpty then
    begin
      if (NoType = 'SSN') then
      begin
        //SSN與SN相同
        Result := True;
        NewNo := SNNO;
      end
      else if (NoType = 'Box') and (AutoCreateBox) and (LabBoxCap.Caption = '1') then
      begin
        //Box與CSN相同
        NoBoxRule := True;
        Result := True;
        LabBoxQty.Visible := False;
        sbtnCloseBox.Enabled := False;
      end
      else if (NoType = 'Carton') and (AutoCreateCarton) and (LabCartonCap.Caption = '1') then
      begin
        //Carton與CSN相同
        NoCartonRule := True;
        Result := True;
        LabCartonQty.Visible := False;
        sbtnCloseCarton.Enabled := False;
      end
      else
      begin
        if ((NoType = 'Box') and AutoCreateBox) or ((NoType = 'Carton') and AutoCreateCarton) or ((NoType = 'Pallet') and AutoCreatePallet) then
        begin
          Close;
          Params.Clear;
          if PackingBase = 'Work Order' then
            CommandText := 'select sajet.packing_label(''' + NoType + ''',''' + PackingBase + ''',''' + mWO + ''') SNID from dual'
          else
            CommandText := 'select sajet.packing_label(''' + NoType + ''',''' + PackingBase + ''',''' + mPartNo + ''') SNID from dual';
          Open;
          Result := True;
          NewNo := FieldByName('SNID').AsString;
        end;
      end;
      exit;
    end
    else
    begin
      sSeqName := Fieldbyname('FUNCTION_NAME').AsString;
      sRuleName := sSeqName;
      if NoType = 'Carton' then
        sSeqName := 'S_CTN_' + sSeqName
      else if NoType = 'Pallet' then
        sSeqName := 'S_PLT_' + sSeqName
      else
        sSeqName := 'S_SSN_' + sSeqName;
    end;
      //===============================================
    while not Eof do
    begin
      if (Fieldbyname('PARAME_NAME').AsString = 'Carton No Code') or
        (Fieldbyname('PARAME_NAME').AsString = 'Pallet No Code') or
        (Fieldbyname('PARAME_NAME').AsString = 'Box No Code') or
        (Fieldbyname('PARAME_NAME').AsString = 'Customer SN Code') then
      begin
        if Fieldbyname('PARAME_ITEM').AsString = 'Code' then
          mCode := Fieldbyname('PARAME_VALUE').AsString;

        if Fieldbyname('PARAME_ITEM').AsString = 'Default' then
          mCodeDef := Fieldbyname('PARAME_VALUE').AsString;

        if Fieldbyname('PARAME_ITEM').AsString = 'Code Type' then
        begin
          mCarry := '0';
          if Fieldbyname('PARAME_VALUE').AsString = '16' then
            mCarry := '16';
        end;
      end
      else if Fieldbyname('PARAME_NAME').AsString = 'Check Sum' then
        gsCheckSum := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_NAME').AsString = 'Month User Define' then
        CarryM.CommaText := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_NAME').AsString = 'Day User Define' then
        CarryD.CommaText := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_NAME').AsString = 'Week User Define' then
        CarryW.CommaText := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_NAME').AsString = 'Day of Week User Define' then
        CarryK.CommaText := Fieldbyname('PARAME_VALUE').AsString
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
      else if (Fieldbyname('PARAME_NAME').AsString = 'Carton No User Define') or
        (Fieldbyname('PARAME_NAME').AsString = 'Pallet No User Define') or
        (Fieldbyname('PARAME_NAME').AsString = 'Box No User Define') or
        (Fieldbyname('PARAME_NAME').AsString = 'Customer SN User Define') then
        SNUdf.Add(Fieldbyname('PARAME_ITEM').AsString + ' : ' +
          Fieldbyname('PARAME_VALUE').AsString);
      Next;
    end;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'PARAME_NAME', ptInput);
    CommandText := 'Select PARAME_VALUE ' +
      'From SAJET.SYS_MODULE_PARAM A ' +
      'Where MODULE_NAME = :MODULE_NAME and ' +
      'A.FUNCTION_NAME = :FUNCTION_NAME and ' +
      'A.PARAME_NAME = :PARAME_NAME ';
    Params.ParamByName('MODULE_NAME').AsString := sModule;
    Params.ParamByName('FUNCTION_NAME').AsString := sRuleName;
    Params.ParamByName('PARAME_NAME').AsString := 'Reset Sequence Mark';
    Open;
    gsMark := Fieldbyname('PARAME_VALUE').AsString;
    Close;
    sSNCode := mCode;
    sSNDef := mCodeDef;
  end;
  if sField1 <> '' then
  begin
    sValue1 := lstValue.Items[lstField.Items.IndexOf(sField1)];
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
    sValue2 := lstValue.Items[lstField.Items.IndexOf(sField2)];
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
    sValue3 := lstValue.Items[lstField.Items.IndexOf(sField3)];
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select ' + sType1 + '(''' + sValue3 + ''') snid from dual ';
      Open;
      sValue3 := FieldByName('snid').AsString;
    end;
  end;
  with qryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select TO_CHAR(SYSDATE,''YYYYMMDDIWDDD'') YMD, sysdate FROM DUAL ';
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
  if CarryK.Count >= StrToInt(mDK) then
    mcDK := CarryK[StrToInt(mDK) - 1];
  for I := Length(sSNCode) downto 1 do
  begin
    if sSNCode[I] = 'Y' then
    begin
      if Length(mDY) > 0 then
      begin
        sSNDef[I] := mDY[Length(mDY)];
        mDY := Copy(mDY, 1, Length(mDY) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'M' then
    begin
      if Length(mDM) > 0 then
      begin
        sSNDef[I] := mDM[Length(mDM)];
        mDM := Copy(mDM, 1, Length(mDM) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'm' then
    begin
      if Length(mcDM) > 0 then
      begin
        sSNDef[I] := mcDM[Length(mcDM)];
        mcDM := Copy(mcDM, 1, Length(mcDM) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'D' then
    begin
      if Length(mDD) > 0 then
      begin
        sSNDef[I] := mDD[Length(mDD)];
        mDD := Copy(mDD, 1, Length(mDD) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'd' then
    begin
      if Length(mcDD) > 0 then
      begin
        sSNDef[I] := mcDD[Length(mcDD)];
        mcDD := Copy(mcDD, 1, Length(mcDD) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'F' then
    begin
      if Length(mDYW) > 0 then
      begin
        sSNDef[I] := mDYW[Length(mDYW)];
        mDYW := Copy(mDYW, 1, Length(mDYW) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'W' then
    begin
      if Length(mDW) > 0 then
      begin
        sSNDef[I] := mDW[Length(mDW)];
        mDW := Copy(mDW, 1, Length(mDW) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'w' then
    begin
      if Length(mcDW) > 0 then
      begin
        sSNDef[I] := mcDW[Length(mcDW)];
        mcDW := Copy(mcDW, 1, Length(mcDW) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'K' then
    begin
      sSNDef[I] := mDK[1];
    end
    else if sSNCode[I] = 'k' then
    begin
      if Length(mcDK) > 0 then
      begin
        sSNDef[I] := mcDK[Length(mcDK)];
        mcDK := Copy(mcDK, 1, Length(mcDK) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'P' then
    begin
      if Length(sValue1) > 0 then
      begin
        sSNDef[I] := sValue1[Length(sValue1)];
        sValue1 := Copy(sValue1, 1, Length(sValue1) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'Q' then
    begin
      if Length(sValue2) > 0 then
      begin
        sSNDef[I] := sValue2[Length(sValue2)];
        sValue2 := Copy(sValue2, 1, Length(sValue2) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'R' then
    begin
      if Length(sValue3) > 0 then
      begin
        sSNDef[I] := sValue3[Length(sValue3)];
        sValue3 := Copy(sValue3, 1, Length(sValue3) - 1);
      end
      else
        sSNDef[I] := '0';
    end;
  end;
  mCodeNo := sSNDef;

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
  if CarryK.Count >= StrToInt(mDK) then
    mcDK := CarryK[StrToInt(mDK) - 1];
  sSNCode := '';
  sSEQ := '';
  S := mCode;
  for I := 1 to Length(S) do
    if not (S[I] in ['Y', 'M', 'm', 'D', 'd', 'W', 'w', 'A', 'C', 'L', 'R', 'k', 'K', 'P', 'Q', 'F']) then
    begin
      sSNCode := sSNCode + S[I];
      sSEQ := sSEQ + Copy(mCodeNo, I, 1);
    end;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select Last_Number from all_sequences '
      + 'where sequence_name = ''' + UpperCase(sSeqName) + ''' '
      + 'and sequence_owner = user';
    Open;
    if IsEmpty then begin
      CreateSeq(sSeqName, Length(sSEQ) + 1, sSNCode, sSNDef);
      case iCycle of
        0:
          begin
            if Pos('D', mCode) <> 0 then
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
            if Pos('W', mCode) <> 0 then
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
            if Pos('M', mCode) <> 0 then
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
    end else begin
      mDiv := Fieldbyname('Last_Number').AsInteger;
      if bReset then
      begin
        bReset := False;
        case iCycle of
          0:
            begin
              if Pos('D', mCode) <> 0 then
              begin
                if gsMark = '' then
                  gsMark := mDD
                else if mDD <> gsMark then
                begin
                  gsMark := mDD;
                  bReset := True;
                end;
              end else if Pos('K', UpperCase(mCode)) <> 0 then
              begin
                if gsMark = '' then
                  gsMark := mDK
                else if mDK <> gsMark then
                begin
                  gsMark := mDK;
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
              if Pos('W', mCode) <> 0 then
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
              if Pos('M', mCode) <> 0 then
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
          CommandText := ' drop sequence ' + sSeqName;
          Execute;
          Close;
          CreateSeq(sSeqName, Length(sSEQ) + 1, sSNCode, sSNDef);
        end;
      end;
    end;
    Close;
    SaveToDB('Reset Sequence Mark', '', gsMark, sModule, sRuleName);
  end;
  S := '';
  QryTemp.Close;
  QryTemp.Params.Clear;
  QryTemp.CommandText := 'SELECT ' + sSeqName + '.NEXTVAL SNID FROM DUAL ';
  QryTemp.Open;

  mDiv := QryTemp.Fieldbyname('SNID').AsInteger;

  for I := Length(sSNCode) downto 1 do
  begin
    if mDiv <> 0 then
    begin
      if sSNCode[I] = 'S' then
      begin
        if mCarry = '16' then
        begin
          mMod := mDiv mod 16;
          mDiv := mDiv div 16;
          if mMod = 0 then
            sSEQ[I] := '0'
          else
            sSEQ[I] := Carry16[mMod];
        end
        else
        begin
          mMod := mDiv mod 10;
          mDiv := mDiv div 10;
          if mMod = 0 then
            sSEQ[I] := '0'
          else
            sSEQ[I] := Carry16[mMod];
        end;
      end
      else
      begin
        for J := 0 to SNUdf.Count - 1 do
        begin
          if Copy(SNUdf.Strings[J], 1, 1) = sSNCode[I] then
          begin
            S := Trim(Copy(SNUdf.Strings[J], POS(':', SNUdf.Strings[J]) + 1, Length(SNUdf.Strings[J]) - POS(':', SNUdf.Strings[J])));
            mMod := mDiv mod Length(S);
            mDiv := mDiv div Length(S);
            if mMod = 0 then
              sSEQ[I] := S[1]
            else
              sSEQ[I] := S[mMod + 1];
            Break;
          end;
        end;
      end;
    end
    else
      if sSNCode[I] = 'S' then
        sSEQ[I] := '0'
      else begin
        for J := 0 to SNUdf.Count - 1 do
        begin
          if Copy(SNUdf.Strings[J], 1, 1) = sSNCode[I] then
          begin
            S := Trim(Copy(SNUdf.Strings[J], POS(':', SNUdf.Strings[J]) + 1, Length(SNUdf.Strings[J]) - POS(':', SNUdf.Strings[J])));
            sSEQ[I] := S[1];
            Break;
          end;
        end;
      end;
  end;

  S := mCode;
  S1 := mCodeNo;
  J := 1;
  for I := 1 to Length(S) do
    if not (S[I] in ['Y', 'M', 'm', 'D', 'd', 'W', 'w', 'A', 'C', 'L', 'R', 'k', 'K', 'P', 'Q', 'F']) then
    begin
      S1[I] := sSEQ[J];
      Inc(J);
    end;
  if Pos('X', S) <> 0 then
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select ' + gsCheckSum + '(''' + S1 + ''') SNID from dual';
      Open;
      S1 := FieldByName('SNID').AsString;
      Close;
    end;
  Result := True;
  NewNo := S1;
end;

procedure TfPacking.SetStatusbyAuthority;
var iPrivilege: integer;
begin
  //Execute
  iPrivilege := 0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Packing';
      Params.ParamByName('FUN').AsString := '順序包裝';
      Execute;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;
  editSN.Enabled := (iPrivilege >= 1);

  G_iClosePrivilege := 0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Packing';
      Params.ParamByName('FUN').AsString := 'Close Pallet(Carton)';
      Execute;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        G_iClosePrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;
  //sbtnCloseCarton.Enabled := (iPrivilege >= 1);
  //sbtnClosePallet.Enabled := sbtnCloseCarton.Enabled;
  //sbtnCloseBox.Enabled := sbtnCloseCarton.Enabled;
end;

function TfPacking.GetTerminalID: Boolean;
begin
  Result := False;

  with TIniFile.Create('SAJET.ini') do
  begin
    TerminalID := ReadString('Packing', 'Terminal', '');
    Free;
  end;

  if TerminalID = '' then
  begin
    ShowMsg('Terminal not be assign !!', 'ERROR');
     //MessageDlg('Terminal not be assign !!',mtError, [mbCancel],0);
    Exit;
  end;

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'SELECT A.TERMINAL_NAME, B.PROCESS_NAME, C.PDLINE_NAME,A.PROCESS_ID ' +
      ' ,A.PDLINE_ID,A.STAGE_ID '+
      'FROM   SAJET.SYS_TERMINAL A, SAJET.SYS_PROCESS B, SAJET.SYS_PDLINE C ' +
      'WHERE  A.TERMINAL_ID = :TERMINALID ' +
      'AND    A.PROCESS_ID = B.PROCESS_ID ' +
      'AND    A.PDLINE_ID = C.PDLINE_ID ';
    Params.ParamByName('TERMINALID').AsString := TerminalID;
    Open;
    if IsEmpty then
    begin
      Close;
      ShowMsg('Terminal data error !!', 'ERROR');
        //MessageDlg('Terminal data error !!',mtError, [mbCancel],0);
      Exit;
    end;
    LabTerminal.Caption := Fieldbyname('PDLINE_NAME').AsString + ' / ' + Fieldbyname('PROCESS_NAME').AsString + ' / ' +
      Fieldbyname('TERMINAL_NAME').AsString;
    lablLine.Caption := Fieldbyname('PDLINE_NAME').AsString;
    G_sProcessID:= Fieldbyname('PROCESS_ID').AsString;
    G_sLineID:= Fieldbyname('PDLINE_ID').AsString;
    G_sStageID:= Fieldbyname('STAGE_ID').AsString;
    Close;
  end;
  Result := True;
end;

function TfPacking.GetCfgData: Boolean;
var sWeightDll,sAdditionalDll, sAction: string; bCapsLock: Boolean;
begin
  Result := False;
  PackAction := 0;
  chkWeight.Checked := False;
  bCapsLock := False;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'SELECT * ' +
      'FROM SAJET.SYS_MODULE_PARAM ' +
      'WHERE MODULE_NAME = :MODULE_NAME AND ' +
      'FUNCTION_NAME = :FUNCTION_NAME AND ' +
      'PARAME_NAME = :TERMINALID ';
    Params.ParamByName('MODULE_NAME').AsString := 'PACKING';
    Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
    Params.ParamByName('TERMINALID').AsString := TerminalID;
    Open;
    if IsEmpty then
    begin
      Close;
      ShowMsg('Configuration not Exist !!', 'ERROR');
        //MessageDlg('Configuration not Exist !!',mtError, [mbCancel],0);
      Exit;
    end;

    while not Eof do
    begin
        //Customer SN
      if Fieldbyname('PARAME_ITEM').AsString = 'Customer SN' then
      begin
        AutoCreateCSN := (Fieldbyname('PARAME_VALUE').AsString = 'System Create');
        NotChangeCSN := (Fieldbyname('PARAME_VALUE').AsString = 'Not Change CSN');
      end
      else if Fieldbyname('PARAME_ITEM').AsString = 'Check CSN=SN' then
        CheckCSNeqSN := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Customer SN Label' then
        PrintCSNLabel := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Customer SN Label Method' then
        PrintCSNMethod := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Customer SN Label Qty' then
        PrintCSNLabQty := StrToIntDef(Fieldbyname('PARAME_VALUE').AsString, 1)
      else if Fieldbyname('PARAME_ITEM').AsString = 'Customer SN COM Port' then
        mCSNComPort := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Customer SN BaudRate' then
        mCSNBaudRate := Fieldbyname('PARAME_VALUE').AsString
      //Box
      else if Fieldbyname('PARAME_ITEM').AsString = 'Box No' then
        AutoCreateBox := (Fieldbyname('PARAME_VALUE').AsString = 'System Create')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Check Box=SN' then
        CheckBoxeqSN := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Box No Label' then
        PrintBoxLabel := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Box No Label Method' then
        PrintBoxMethod := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Box No Label Qty' then
        PrintBoxLabQty := StrToIntDef(Fieldbyname('PARAME_VALUE').AsString, 1)
      else if Fieldbyname('PARAME_ITEM').AsString = 'Box No COM Port' then
        mBoxComPort := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Box No BaudRate' then
        mBoxBaudRate := Fieldbyname('PARAME_VALUE').AsString

        //Carton
      else if Fieldbyname('PARAME_ITEM').AsString = 'Carton No' then
        AutoCreateCarton := (Fieldbyname('PARAME_VALUE').AsString = 'System Create')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Carton No Label' then
        PrintCartonLabel := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Carton No Label Method' then
        PrintCartonMethod := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Carton No Label Qty' then
        PrintCartonLabQty := StrToIntDef(Fieldbyname('PARAME_VALUE').AsString, 1)
      else if Fieldbyname('PARAME_ITEM').AsString = 'Carton No COM Port' then
        mCartonComPort := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Carton No BaudRate' then
        mCartonBaudRate := Fieldbyname('PARAME_VALUE').AsString

        //Pallet
      else if Fieldbyname('PARAME_ITEM').AsString = 'Pallet No' then
        AutoCreatePallet := (Fieldbyname('PARAME_VALUE').AsString = 'System Create')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Pallet No Label' then
        PrintPalletLabel := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Pallet No Label Method' then
        PrintPalletMethod := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Print Pallet No Label Qty' then
        PrintPalletLabQty := StrToIntDef(Fieldbyname('PARAME_VALUE').AsString, 1)
      else if Fieldbyname('PARAME_ITEM').AsString = 'Pallet No COM Port' then
        mPalletComPort := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Pallet No BaudRate' then
        mPalletBaudRate := Fieldbyname('PARAME_VALUE').AsString


      else if Fieldbyname('PARAME_ITEM').AsString = 'Packing Base' then
        PackingBase := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'CodeSoft' then
      begin
        if Fieldbyname('PARAME_VALUE').AsString = 'Version 4' then
          CodesoftVersion := 4
        else if Fieldbyname('PARAME_VALUE').AsString = 'Version 5' then
          CodesoftVersion := 5
        else
          CodesoftVersion := 6;
      end
      else if Fieldbyname('PARAME_ITEM').AsString = 'Packing Action' then
      begin
        sAction := Fieldbyname('PARAME_VALUE').AsString;
        if sAction = 'Both' then
          PackAction := 0
        else if sAction = 'Carton' then
          PackAction := 1
        else if sAction = 'Pallet' then
          PackAction := 2
        else
          PackAction := StrToInt(sAction);
      //秤重
      end
      else if Fieldbyname('PARAME_ITEM').AsString = 'Check Weight' then
        chkWeight.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Weight Dll' then
        sWeightDll := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Check Rule by Function' then
        gsRuleFunction := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Caps Lock' then
        bCapsLock := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      // 2007.05.23 是否Call Dll做其他欄位檢查
      else if Fieldbyname('PARAME_ITEM').AsString = 'Additional Data' then
        g_bAdditional := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Additional DLL'  then
        sAdditionalDll := Fieldbyname('PARAME_VALUE').AsString

      // 2007/08/27 是否可輸入不良代碼
      else if Fieldbyname('PARAME_ITEM').AsString = 'Input Error Code' then
        g_bInputEC := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      Next;
    end;
    Close;
  end;
  if bCapsLock then
    editMO.CharCase := ecUpperCase;
  editPallet.CharCase := editMO.CharCase;
  editCarton.CharCase := editMO.CharCase;
  editBox.CharCase := editMO.CharCase;
  editSN.CharCase := editMO.CharCase;
  editCSN.CharCase := editMO.CharCase;
  edtWeight2.Visible := chkWeight.Checked;
  lablWeight.Visible := chkWeight.Checked;
  chkWeight.Visible := chkWeight.Checked;
  if PrintCSNMethod <> 'DLL' then
  begin
    sbtnCustini.Visible := False;
    Image8.Visible := sbtnCustini.Visible;
  end;
  if PrintBoxMethod <> 'DLL' then
  begin
    sbtnBoxini.Visible := False;
    Image9.Visible := sbtnBoxini.Visible;
  end;
  if PrintCartonMethod <> 'DLL' then
  begin
    sbtnCartonini.Visible := False;
    Image7.Visible := sbtnCartonini.Visible;
  end;
  if PrintPalletMethod <> 'DLL' then
  begin
    sbtnPalletini.Visible := False;
    Image6.Visible := sbtnPalletini.Visible;
  end;
  GBInitial.Visible := (sbtnPalletini.Visible) or (sbtnCartonini.Visible) or (sbtnBoxini.Visible) or (sbtnCustini.Visible);

  ShowPackAction;

  if chkWeight.Checked then
    LoadSajetDll(sWeightDll);

  // 2007.05.23 Call Dll 做其他欄位檢查
  if g_bAdditional then
   // LoadAdditionalDll('Additionaldll.DLL');
    LoadAdditionalDll(sAdditionalDll);   //update by key 2007/10/09

  Result := True;
end;

procedure TfPacking.ShowPackAction;
begin
  if PackAction in [2, 4] then
  begin
    // SN
    LabSN.Visible := False;
    LabCSN.Visible := False;
    editSN.Visible := False;
    editCSN.Visible := False;
    // Box
    LabBoxInfo.Visible := False;
    sbtnCloseBox.Visible := False;
    Image2.Visible := False;
    editBox.Visible := False;
    LabBoxCap.Visible := False;
    LabBoxQty.Visible := False;
    labBoxDiv.Visible := False;
    LabBox.Visible := False;
    LabBoxCap.Visible := False;
    Bevel3.Visible := False;
    LabBCap.Visible := False;
    // Carton
    sbtnCloseCarton.Visible := False;
    Image3.Visible := False;
    lablCartonCap.Visible := False;
    LabCartonQty.Visible := False;
    LabCartonCap.Visible := False;
    lablCartonDiv.Visible := False;
  end
  else if PackAction in [1, 3, 5, 6, 7, 8] then
  begin
    if PackAction <> 7 then
    begin
      // Pallet
      LabPalletInfo.Visible := False;
      sbtnClosePallet.Visible := False;
      Image1.Visible := False;
      editPallet.Visible := False;
      LabPalletCap.Visible := False;
      LabPalletQty.Visible := False;
      LabPallet.Visible := False;
      LabPalCap.Visible := False;
      Bevel2.Visible := False;
      labPalDiv.Visible := False;
    end;
    if PackAction = 5 then
    begin
      // Carton
      LabCartonInfo.Visible := False;
      sbtnCloseCarton.Visible := False;
      Image3.Visible := False;
      editCarton.Visible := False;
      lablCartonCap.Visible := False;
      LabCartonQty.Visible := False;
      LabCarton.Visible := False;
      Bevel1.Visible := False;
      LabCartonCap.Visible := False;
      lablCartonDiv.Visible := False;
    end
    else if PackAction in [6, 7, 8] then
    begin
      // SN, CSN
      LabSN.Visible := False;
      LabCSN.Visible := False;
      editSN.Visible := False;
      editCSN.Visible := False;
      // Box
      sbtnCloseBox.Visible := False;
      Image2.Visible := False;
      labBCap.Visible := False;
      LabBoxQty.Visible := False;
      LabBoxCap.Visible := False;
      labBoxDiv.Visible := False;
    end;
  end;
end;

procedure TfPacking.SetEditStatus(Kind: string);
var sKey: Char;
begin
//  ComPort.Close;
  edtWeight.Text := '';
//  memoWeight.Lines.Clear;
  ImageNG.Visible := False;
  editMO.Enabled := False;
  sbtnWoFilter.Enabled := False;
  editSN.Enabled := False;
  editBox.Enabled := False;
  editCSN.Enabled := False;
  editCarton.Enabled := False;
  editPallet.Enabled := False;
  editMO.Color := clWhite;
  editSN.Color := clWhite;
  editCSN.Color := clWhite;
  editBox.Color := clWhite;
  editCarton.Color := clWhite;
  editPallet.Color := clWhite;

  if PrintPalletLabel then
    sbtnPalletini.Enabled := True;
  if PrintCartonLabel then
    sbtnCartonini.Enabled := True;
  if PrintBoxLabel then
    sbtnBoxini.Enabled := True;
  if PrintCSNLabel then
    sbtnCustini.Enabled := True;

  if Kind = 'MO' then
  begin
    editMO.Enabled := True;
    sbtnWoFilter.Enabled := True;
    editMO.Color := clYellow;
    editMO.SetFocus;
    editMO.SelectAll;
    sbtnPalletini.Enabled := False;
    sbtnCartonini.Enabled := False;
    sbtnBoxini.Enabled := False;
    sbtnCustini.Enabled := False;
  end
  else if Kind = 'SN' then
  begin
    editSN.Enabled := True;
    editSN.Color := clYellow;
    editSN.SetFocus;
    editSN.SelectAll;
    if gSN <> '' then
    begin
      editSN.Text := gSN;
      gSN := '';
      sKey := #13;
      editSNKeyPress(Self, sKey);
    end;
  end
  else if Kind = 'CSN' then
  begin
    editCSN.Enabled := True;
    editCSN.Color := clYellow;
    editCSN.SetFocus;
    editCSN.SelectAll;
  end
  else if Kind = 'BOX' then
  begin
    editBOX.Enabled := True;
    editBOX.Color := clYellow;
    editBOX.SetFocus;
    editBOX.SelectAll;
  end
  else if Kind = 'CARTON' then
  begin
    editCarton.Enabled := True;
    editCarton.Color := clYellow;
    editCarton.SetFocus;
    editCarton.SelectAll;
  end
  else if Kind = 'PALLET' then
  begin
    editPallet.Enabled := True;
    editPallet.Color := clYellow;
    editPallet.SetFocus;
    editPallet.SelectAll;
  end;
end;

function TfPacking.GetUserNo(sUserID: string): string;
begin
  Result := '0';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT EMP_NO ' +
      'FROM   SAJET.SYS_EMP ' +
      'WHERE  EMP_ID = ' + sUserID;
    Open;
    Result := FieldByName('EMP_NO').AsString;
    Close;
  end;
end;

procedure TfPacking.GetVersion(S: string);
  function HexToInt(HexNum: string): LongInt;
  begin
    Result := StrToInt('$' + HexNum);
  end;
var VersinInfo: Pchar; //版本資訊
  VersinInfoSize: DWord; //版本資訊size (win32 使用)
  pv_info: PVSFixedFileInfo; //版本格式
  Mversion, Sversion: string; //版本No
begin
  VersinInfoSize := GetFileVersionInfoSize(pchar(S), VersinInfoSize);
  VersinInfo := AllocMem(VersinInfoSize);
  try
    GetFileVersionInfo(pchar(S), 0, VersinInfoSize, Pointer(VersinInfo));
    VerQueryValue(pointer(VersinInfo), '\', pointer(pv_info), VersinInfoSize);
    Mversion := inttohex(pv_info.dwProductVersionMS, 0);
    Mversion := copy('00000000', 1, 8 - length(Mversion)) + Mversion;
    Sversion := inttohex(pv_info.dwProductVersionLS, 0);
    Sversion := copy('00000000', 1, 8 - length(Sversion)) + Sversion;
    lablVersion.Caption := 'Version: ' +
      FloatToStr(hextoint(copy(MVersion, 1, 4))) + '.' +
      FloatToStr(hextoint(copy(MVersion, 5, 4))) + '.' +
      FloatToStr(hextoint(copy(SVersion, 1, 4))) + '.' +
      FloatToStr(hextoint(copy(SVersion, 5, 4)));
  finally
    FreeMem(VersinInfo, VersinInfoSize);
  end;
end;

procedure TfPacking.FormShow(Sender: TObject);
  function CheckValue(sName, sValue: string): Boolean;
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'sName', ptInput);
      Params.CreateParam(ftString, 'sValue', ptInput);
      CommandText := 'SELECT param_value ' +
        'FROM   SAJET.SYS_BASE ' +
        'WHERE  PARAM_NAME = :sName AND PARAM_VALUE = :sValue ';
      Params.ParamByName('sName').AsString := sName;
      Params.ParamByName('sValue').AsString := sValue;
      Open;
      Result := not IsEmpty;
      Close;
    end;
  end;
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  GetVersion(ExtractFileDir(Application.ExeName) + '\SeqPackingDll.Dll');
  LVData.Column[0].Width := LVData.Width - LVData.Column[1].Width - LVData.Column[2].Width - LVData.Column[3].Width - 3;
  NoCartonRule := False;
  NoBoxRule := False;
  Carry16 := '123456789ABCDEF';
  SNUdf := TStringList.Create;
  CarryM := TStringList.Create;
  CarryD := TStringList.Create;
  CarryW := TStringList.Create;
  CarryK := TStringList.Create;
  LVData.Clear;
  if UpdateUserID <> '0' then
    SetStatusbyAuthority;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select user from dual';
    Open;
    gsLoginUser := FieldByName('user').AsString;
    Close;
  end;
  UpdateUserNo := GetUserNo(UpdateUserID);
  // 讀取本站 ID
  if not GetTerminalID then
  begin
    editMO.Enabled := False;
    editSN.Enabled := False;
    sbtnWoFilter.Enabled := False;
    Exit;
  end;
  // 讀取 Option 值
  if not GetCfgData then
  begin
    editMO.Enabled := False;
    editSN.Enabled := False;
    sbtnWoFilter.Enabled := False;
    Exit;
  end;
  AutoClose := CheckValue('PACKING', 'AUTOCLOSE'); // 讀取是否自動關閉棧板與箱號
  bNoPopUp := CheckValue('PACKING', 'NOPOPUP'); // 讀取是否彈出錯誤訊息對話框
  ShowEmpty := CheckValue('PACKING', 'NOSHOWEMPTY'); // 讀取是否要彈出 Empty XXXXX
  gbCycle := CheckValue('Packing Pack Spec', 'Cycle');
  gbRefreshQty := CheckValue('PACKING REFRESH QTY', 'Y');  //是否每次都重新由DB查找一次數量 2007/7/5
  gbShowCloseMsg := CheckValue('PACKING', 'SHOWCLOSE');  //ClosePallet後出現訊息,由user按下OK後才可動作

  LabPN.Caption := '';
  LabBoxCap.Caption := '0';
  LabBoxQty.Caption := '0';
  LabCartonCap.Caption := '0';
  LabCartonQty.Caption := '0';
  LabPalletCap.Caption := '0';
  LabPalletQty.Caption := '0';
  editMO.Text := '';
  editSN.Text := '';
  editCSN.Text := '';
  editCarton.Text := '';
  editPallet.Text := '';
  //panlMessage.Caption := 'Please Input WO !';
  ShowMsg('Please Input WO !', '');
  SetEditStatus('MO');
  // 2007.05.23 Call Dll 做其他欄位檢查
  if g_bAdditional then
  begin
    g_tsAddParam:=TStringList.Create;
    g_tsAddData:=TStringList.Create;
  end;
end;

function TfPacking.GetPackSpec: Boolean;
begin
  Result := False;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    CommandText := 'SELECT PKSPEC_NAME, PALLET_CAPACITY, CARTON_CAPACITY, BOX_CAPACITY ' +
      'FROM SAJET.G_PACK_SPEC ' +
      'WHERE WORK_ORDER = :WORK_ORDER '+
      'Order By Sequence';
    Params.ParamByName('WORK_ORDER').AsString := mWO;
    Open;
    if IsEmpty then
    begin
      Close;
      ShowMsg('Packing specification not define !!', 'ERROR');
      Exit;
    end;

    LVData.Clear;
    while not Eof do
    begin
      with LVData.Items.Add do
      begin
        Caption := Fieldbyname('PKSPEC_NAME').AsString;
        Subitems.Add(Fieldbyname('BOX_CAPACITY').AsString);
        Subitems.Add(Fieldbyname('CARTON_CAPACITY').AsString);
        Subitems.Add(Fieldbyname('PALLET_CAPACITY').AsString);
      end;
      Next;
    end;
    if LVData.Items.Count > 1 then
      gbCycle := True;
    ShowPackSpec;
    Result := True;
  end;
end;

procedure TfPacking.ShowPackSpec;
var i, iIndex: integer;
begin
  iIndex := LvData.Items.IndexOf(LvData.FindCaption(0, sPKSpec, True, True, True));
  if iIndex <> -1 then
    LVData.Items[iIndex].ImageIndex := 0;
end;

procedure TfPacking.CreateBox;
begin
  editBox.Text := '';  // 2007.08.29
  if editBox.Visible then
  begin
    if AutoCreateBox then
    begin
      if GetBox then
      begin
        SetEditStatus('SN');
        if NoBoxRule then
          editBox.Text := editCSN.Text;
      end
      else
      begin
        SetEditStatus('BOX');
      end;
    end
    else if (LabBoxCap.Caption <> '1') or ((LabBoxCap.Caption = '1') and (not CheckBoxeqSN)) then
      SetEditStatus('BOX')
    else // 2007.05.23
      SetEditStatus('SN');
  end
  else
    SetEditStatus('SN');
end;

procedure TfPacking.editMOKeyPress(Sender: TObject; var Key: Char);
var i: Integer;
begin
  if Key <> #13 then Exit;
  if Key = #13 then Key := #0; // 2007.05.23 消除按下ENTER後會發出聲音
  if chkWeight.Checked then
    if not gsLoadWeight then
    begin
      ShowMsg('Weight Dll Fault!!', 'ERROR');
      SetEditStatus('MO'); // 2007.05.23 新增
      EXit;
    end;
  // 2007.05.23 Call Dll 做其他欄位檢查
  if g_bAdditional then
  begin
    if not g_bLoadAdditional then
    begin
      ShowMsg('Load Dll (Additionaldll.dll) Fault!!', 'ERROR');
      SetEditStatus('MO');
      EXit;
    end;
  end;


  //可輸入SN or CSN代替輸入WO 2005/2/15
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
    CommandText := 'SELECT WORK_ORDER ' +
      'FROM   SAJET.G_SN_STATUS ' +
      'WHERE  SERIAL_NUMBER = :SERIAL_NUMBER ' +
      'AND ROWNUM=1';
    Params.ParamByName('SERIAL_NUMBER').AsString := editMO.Text;
    Open;
    if IsEmpty then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
      CommandText := 'SELECT WORK_ORDER ' +
        'FROM   SAJET.G_SN_STATUS ' +
        'WHERE  CUSTOMER_SN = :SERIAL_NUMBER ' +
        'AND ROWNUM=1';
      Params.ParamByName('SERIAL_NUMBER').AsString := editMO.Text;
      Open;
    end;
    if not IsEmpty then
    begin
      gSN := '';
      editMO.Text := FieldByName('WORK_ORDER').asstring;
    end;
  end;

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WO_NUMBER', ptInput);
    CommandText := 'SELECT A.*, B.PART_NO, Label_File, CUST_PART_NO ' +
      'FROM   SAJET.G_WO_BASE A, SAJET.SYS_PART B ' +
      'WHERE  A.WORK_ORDER = :WO_NUMBER ' +
      'AND    A.MODEL_ID = B.PART_ID(+) and rownum = 1';  // rownum 2006.11.13 add
    Params.ParamByName('WO_NUMBER').AsString := editMO.Text;
    Open;
    lstField.Items.Clear;
    lstValue.Items.Clear;
    if not IsEmpty then
    begin
      if (FieldByName('WO_STATUS').AsString = '3') or (FieldByName('WO_STATUS').AsString = '2') then
      begin
        mWO := FieldByName('WORK_ORDER').AsString;
        mPartID := FieldByName('MODEL_ID').AsString;
        mPartNO := FieldByName('PART_NO').AsString;
        mCustPartNo := FieldByName('CUST_PART_NO').AsString;
        mLabelFile := FieldByName('Label_File').AsString;
        for i := 0 to FieldCount - 1 do
        begin
          lstField.Items.Add(QryTemp.Fields.Fields[i].FieldName);
          lstValue.Items.Add(QryTemp.Fields.Fields[i].AsString);
        end;
        LabPN.Caption := mPartNO;

        { ===2008/10/28 禁用此功能by key=====用任意的附加程式更代替此功能＝＝＝
       //===2007/06/22 增加附件包裝功能 begin====================================
        g_bPackAssy:=False;
        with QryTemp do
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'PART_ID', ptInput);
          Params.CreateParam(ftString, 'PROCESS_ID', ptInput);
          CommandText :='SELECT count(*) cnt '
                       +'from sajet.sys_bom '
                       +'WHERE BOM_ID = (SELECT bom_id FROM SAJET.SYS_BOM_INFO WHERE (PART_ID,VERSION) = (SELECT PART_ID,VERSION FROM SAJET.SYS_PART WHERE PART_ID=:PART_ID))'
                       //+'FROM SAJET.G_WO_BOM '
                       //+'WHERE WORK_ORDER = :WORK_ORDER '
                       +'AND PROCESS_ID = :PROCESS_ID ';
          Params.ParamByName('PART_ID').AsString := mPartID;
          Params.ParamByName('PROCESS_ID').AsString := G_sProcessID;
          Open;
          if FieldByName('cnt').AsInteger>0 then
            g_bPackAssy:=True;
        end;
        if g_bPackAssy then
        begin
          LoadAssyDll('PackingAccyDll.DLL');
          if not g_bLoadAssy then
          begin
            ShowMsg('Load Dll (PackingAccyDll.dll) Fault!!', 'ERROR');
            SetEditStatus('MO');
            Exit;
          end;
          g_tsAssyParam:=TStringList.Create;
          g_tsAssyData:=TStringList.Create;
        end;
       //=====2007/06/22  end===================================================
       }

        if not GetPackSpec then
          Exit;
        //此次用的包裝方式
        GetLastPackSpec;
        //
        if not editBox.Visible then
          // 用SN包Box, 若Box為0, 則默認為Box/Carton, 所以要將Carton Visible
          if PackAction = 5 then
          begin
            PackAction := 1;
            LabCartonInfo.Visible := True;
            sbtnCloseCarton.Visible := True;
            Image3.Visible := True;
            editCarton.Visible := True;
            lablCartonCap.Visible := True;
            LabCartonQty.Visible := True;
            LabCarton.Visible := True;
            Bevel1.Visible := True;
            LabCartonCap.Visible := True;
            lablCartonDiv.Visible := True;
          end
          // 用Box包Carton, 若Box為0, 則默認為Box/Carton, 所以要將SN Visible
          else if PackAction in [6, 7, 8] then
          begin
            case PackAction of
              6: PackAction := 1;
              7: PackAction := 0;
              8: PackAction := 3;
            end;
            LabSN.Visible := True;
            LabCSN.Visible := True;
            editSN.Visible := True;
            editCSN.Visible := True;
          end;
        //=======只包棧板================
        LabPalletQty.Caption := '0';
        LabCartonQty.Caption := '0';
        LabBoxQty.Caption := '0';
        if PackAction in [2, 4] then
        begin
          //有未滿的棧板
          if GetUnfinishPallet then
          begin
            GetPackPalletQty;
            SetEditStatus('CARTON');
          end
          else
          begin
            if AutoCreatePallet then
            begin
              if GetPallet then
              begin
                SetEditStatus('CARTON');
              end
              else
              begin
                SetEditStatus('PALLET');
              end;
            end
            else
            begin
              SetEditStatus('PALLET');
            end;
          end;
        end
        else {//=======裝箱, Box================} if PackAction in [1, 3, 6, 8] then
        begin //有未滿的箱
          if GetUnfinishCarton then
          begin
            GetPackCartonQty;
            if LabBoxCap.Caption <> '0' then
            begin
              if PackAction in [6, 8] then // 用Box裝Carton
                SetEditStatus('BOX')
              else if GetUnfinishBox then
              begin
                GetPackBoxQty;
                SetEditStatus('SN');
              end
              else
              begin
                CreateBox;
              end;
            end
            else
              SetEditStatus('SN');
          end
          else
          begin
            if AutoCreateCarton then
            begin
              if GetCarton then
              begin
                if PackAction in [6, 8] then
                  SetEditStatus('BOX')
                else
                begin
                  if LabBoxCap.Caption <> '0' then
                  begin
                    if GetUnfinishBox then
                    begin
                      GetPackBoxQty;
                      SetEditStatus('SN');
                    end
                    else
                      CreateBox;
                  end
                  else
                    SetEditStatus('SN');
                end;
              end
              else
              begin
                SetEditStatus('CARTON');
              end;
            end
            else
            begin
              SetEditStatus('CARTON');
            end;
          end;
        end
        else if PackAction = 5 then
        begin
          //有未滿的箱
          if GetUnfinishBox then
          begin
            GetPackBoxQty;
            SetEditStatus('SN');
          end
          else
          begin
            CreateBox;
          end;
        end
        else //=========包棧板和箱=================== PackAction = 'Both'
        begin
          //有未滿的棧板
          if GetUnfinishPallet then
          begin
            GetPackPalletQty;
            //有未滿的箱
            if GetUnfinishCarton then
            begin
              GetPackCartonQty;
              if LabBoxCap.Caption <> '0' then
              begin
                if PackAction = 7 then // 用Box裝Carton
                  SetEditStatus('BOX')
                else if GetUnfinishBox then
                begin
                  GetPackBoxQty;
                  SetEditStatus('SN');
                end
                else
                  CreateBox;
              end
              else
                SetEditStatus('SN');
            end
            else
            begin //無未滿的箱
              if AutoCreateCarton then
              begin
                if GetCarton then
                begin
                  if PackAction = 7 then // 用Box裝Carton
                    SetEditStatus('BOX')
                  else if LabBoxCap.Caption <> '0' then
                  begin
                    if GetUnfinishBox then
                    begin
                      GetPackBoxQty;
                      SetEditStatus('SN');
                    end
                    else
                      CreateBox;
                  end
                  else
                    SetEditStatus('SN');
                end
                else
                begin
                  SetEditStatus('CARTON');
                end;
              end
              else
              begin
                SetEditStatus('CARTON');
              end;
            end;
          end
          else
          begin //無未滿的棧板
            if AutoCreatePallet then
            begin
              if GetPallet then
              begin
                if AutoCreateCarton then
                begin
                  if GetCarton then
                  begin
                    if PackAction = 7 then // 用Box裝Carton
                      SetEditStatus('BOX')
                    else
                      CreateBox;
                  end
                  else
                  begin
                    SetEditStatus('CARTON');
                  end;
                end
                else
                begin
                  SetEditStatus('CARTON');
                end;
              end
              else
              begin
                SetEditStatus('PALLET');
              end;
            end
            else
            begin
              SetEditStatus('PALLET');
            end;
          end;
        end;
      end
      else
      begin
        Close;
        ShowMsg('WO Number Not In Work!!', 'ERROR');
        SetEditStatus('MO');
        Exit;
      end;
    end
    else
    begin
      Close;
      ShowMsg('Invalid WO Number !!', 'ERROR');
      SetEditStatus('MO');
      Exit;
    end;
  end;
  if editSN.Text = '' then
    ShowMsg('WO Number OK.', '');
end;

function TfPacking.ShowClose(sType: string): string;
var i, iRow: Integer; sField, sFrom, sFromField: string;
begin
  sFrom := ''; sFromField := '';
  if sType = 'Pallet' then
    sField := 'Carton_No'
  else if sType = 'Box' then
  begin
    sFromField := 'Carton_No sFrom, ';
    sField := 'Serial_Number';
    if editCarton.Visible then sFrom := editCarton.Text;
  end
  else if sType = 'Carton' then
  begin
    sFromField := 'Pallet_No sFrom, ';
    if editBox.Visible then
      sField := 'Box_No'
    else
      sField := 'Serial_Number';
    if editPallet.Visible then sFrom := editPallet.Text;
  end;
  try
    fFilter := TfFilter.Create(self);
    fFilter.Caption := 'Unfinished/Empty ' + sType;
    i := 1; iRow := 0;
    fFilter.StringGrid11.Cells[1, 0] := sType + ' No';
    fFilter.StringGrid11.Cells[2, 0] := 'Count';
    while not QryTemp.Eof do
    begin
      QryData.Close;
      QryData.Params.Clear;
      QryData.Params.CreateParam(ftString, 'sNo', ptInput);
      QryData.CommandText := 'SELECT distinct ' + sFromField + sType + '_No sNo, ' + sField + ' sCount ' +
        'FROM SAJET.G_SN_STATUS A ' +
        'WHERE A.' + sType + '_NO = :sNo ';
      QryData.Params.ParamByName('sNo').AsString := QryTemp.FieldByName(sType + '_NO').AsString;
      QryData.Open;
      if QryData.IsEmpty then
      begin
        fFilter.StringGrid11.Cells[1, i] := QryTemp.FieldByName(sType + '_NO').AsString;
        fFilter.StringGrid11.Cells[2, i] := '0';
        if fFilter.StringGrid11.Cells[2, i] <> '0' then
          iRow := i;
        Inc(i);
      end
      else if sFrom <> '' then
      begin
        if QryData.FieldByName('sFrom').AsString = sFrom then
        begin
          fFilter.StringGrid11.Cells[1, i] := QryTemp.FieldByName(sType + '_NO').AsString;
          fFilter.StringGrid11.Cells[2, i] := IntToStr(QryData.RecordCount);
          if fFilter.StringGrid11.Cells[2, i] <> '0' then
            iRow := i;
          Inc(i);
        end;
      end
      else
      begin
        fFilter.StringGrid11.Cells[1, i] := QryTemp.FieldByName(sType + '_NO').AsString;
        fFilter.StringGrid11.Cells[2, i] := IntToStr(QryData.RecordCount);
        if fFilter.StringGrid11.Cells[2, i] <> '0' then
          iRow := i;
        Inc(i);
      end;
      QryData.Close;
      QryTemp.Next;
    end;
    fFilter.StringGrid11.RowCount := i;
    if iRow <> 0 then
      fFilter.StringGrid11.Row := iRow;
    if fFilter.StringGrid11.RowCount = 2 then
      Result := fFilter.StringGrid11.Cells[1, 1]
    else if fFilter.StringGrid11.RowCount = 1 then
      Result := ''
    else if fFilter.Showmodal = mrOK then
    begin
      Result := fFilter.StringGrid11.Cells[1, fFilter.StringGrid11.Row];
      QryTemp.First;
      for i := 1 to fFilter.StringGrid11.RowCount - 1 do
        if (fFilter.StringGrid11.Cells[1, i] <> Result) and (fFilter.StringGrid11.Cells[2, i] = '0') then
          with QryData do
          begin
            Close;
            Params.Clear;
            if fFilter.StringGrid11.Cells[1, i] <> '' then
              Params.CreateParam(ftString, 'sNo', ptInput);
            CommandText := 'delete from sajet.g_pack_' + sType;
            if fFilter.StringGrid11.Cells[1, i] <> '' then
            begin
              CommandText := CommandText + ' where ' + sType + '_No = :sNo ';
              Params.ParamByName('sNo').AsString := fFilter.StringGrid11.Cells[1, i];
            end
            else
              CommandText := CommandText + ' where ' + sType + '_No is null ';
            Execute;
            Close;
          end;
    end;
    QryTemp.Close;
  finally
    fFilter.Free;
  end;
end;

function TfPacking.GetUnfinishPallet: Boolean;
begin
  Result := False;
  PalletNo := '';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
    Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
    CommandText := 'SELECT PALLET_NO '
      + 'FROM   SAJET.G_PACK_PALLET ';
    if PackingBase = 'Work Order' then
      CommandText := CommandText + 'WHERE  WORK_ORDER = :WORK_ORDER '
    else
      CommandText := CommandText + 'WHERE  MODEL_ID = :WORK_ORDER ';
    CommandText := CommandText + 'AND    TERMINAL_ID = :TERMINAL_ID ' //205/03/01
      + 'AND    CLOSE_FLAG = ''N'' AND PKSPEC_NAME = :PKSPEC_NAME';
    if PackingBase = 'Work Order' then
      Params.ParamByName('WORK_ORDER').AsString := mWO
    else
      Params.ParamByName('WORK_ORDER').AsString := mPartID;
    Params.ParamByName('TERMINAL_ID').AsString := TerminalID;
    Params.ParamByName('PKSPEC_NAME').AsString := sPKSpec;
    Open;
    if not IsEmpty then
    begin
      if RecordCount = 1 then
        PalletNo := Fieldbyname('PALLET_NO').AsString
      else
        PalletNo := ShowClose('Pallet');
      Result := True;
    end;
    Close;
    if PalletNo <> '' then
      editPallet.Text := PalletNo;
  end;
end;

function TfPacking.GetUnfinishCarton: Boolean;
begin
  Result := False;
  CartonNo := '';
//  if LabCartonCap.Caption = '1' then begin

//  end else begin
    if (AutoCreateCarton) then begin
      sbtnCloseCarton.Enabled := True;
      NoCartonRule := False;
    end;
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
      Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
      CommandText := 'SELECT CARTON_NO ' +
        'FROM   SAJET.G_PACK_CARTON ';
      if PackingBase = 'Work Order' then
        CommandText := CommandText + 'WHERE  WORK_ORDER = :WORK_ORDER '
      else
        CommandText := CommandText + 'WHERE  MODEL_ID = :WORK_ORDER ';
      CommandText := CommandText + 'AND    TERMINAL_ID = :TERMINAL_ID ' + //205/03/01
        'AND    CLOSE_FLAG = ''N'' AND PKSPEC_NAME = :PKSPEC_NAME';
      if PackingBase = 'Work Order' then
        Params.ParamByName('WORK_ORDER').AsString := mWO
      else
        Params.ParamByName('WORK_ORDER').AsString := mPartID;
      Params.ParamByName('TERMINAL_ID').AsString := TerminalID;
      Params.ParamByName('PKSPEC_NAME').AsString := sPKSpec;
      Open;
      if not IsEmpty then
      begin
        CartonNo := ShowClose('Carton');
        if CartonNo <> '' then Result := True;
      end;
      Close;
      if CartonNo <> '' then
        editCarton.Text := CartonNo;
    end;
//  end;
end;

function TfPacking.GetUnfinishBox: Boolean;
begin
  Result := False;
  BoxNo := '';
  if LabBoxCap.Caption = '1' then begin
  end else begin
    if (AutoCreateBox) then begin
      sbtnCloseBox.Enabled := True;
      NoBoxRule := False;
    end;
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
      Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
      CommandText := 'SELECT Box_NO ' +
        'FROM   SAJET.G_PACK_Box ';
      if PackingBase = 'Work Order' then
        CommandText := CommandText + 'WHERE  WORK_ORDER = :WORK_ORDER '
      else
        CommandText := CommandText + 'WHERE  MODEL_ID = :WORK_ORDER ';
      CommandText := CommandText + 'AND    TERMINAL_ID = :TERMINAL_ID ' + //205/03/01
        'AND    CLOSE_FLAG = ''N'' AND PKSPEC_NAME = :PKSPEC_NAME';
      if PackingBase = 'Work Order' then
        Params.ParamByName('WORK_ORDER').AsString := mWO
      else
        Params.ParamByName('WORK_ORDER').AsString := mPartID;
      Params.ParamByName('TERMINAL_ID').AsString := TerminalID;
      Params.ParamByName('PKSPEC_NAME').AsString := sPKSpec;
      Open;
      if not IsEmpty then
      begin
        BoxNo := ShowClose('Box');
        if BoxNo <> '' then Result := True;
      end;
      Close;
      if BoxNo <> '' then
        editBox.Text := BoxNo;
    end;
  end;  
end;

function TfPacking.GetPackPalletQty: Boolean;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PALLET_NO', ptInput);
    CommandText := 'SELECT A.CARTON_NO ' +
      'FROM SAJET.G_SN_STATUS A,' +
      'SAJET.G_PACK_CARTON B ' +
      'WHERE A.PALLET_NO = :PALLET_NO AND ' +
      'A.CARTON_NO = B.CARTON_NO AND ' +
      'B.CLOSE_FLAG = ''Y'' ' +
      'GROUP BY A.CARTON_NO ';
    Params.ParamByName('PALLET_NO').AsString := PalletNo;
    Open;
    LabPalletQty.Caption := InttoStr(RecordCount);
    if LabPalletQty.Caption = '0' then
    begin
      if ShowEmpty then
        MessageDlg('Empty Pallet.', mtWarning, [mbOK], 0);
    end
    else
      MessageDlg('Unfinished Pallet.', mtWarning, [mbOK], 0);
    Result := True;
  end;
end;

function TfPacking.GetPackCartonQty: Boolean;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CARTON_NO', ptInput);
    if editBox.Visible then
    begin
      CommandText := 'SELECT A.BOX_NO, nvl(B.CLOSE_FLAG, ''Y'') close_flag ' +
        'FROM SAJET.G_SN_STATUS A ' +
        ',SAJET.G_PACK_BOX B ' +
        'WHERE CARTON_NO = :CARTON_NO ' +
        'AND A.BOX_NO = B.BOX_NO(+) ' +
        'GROUP BY A.BOX_NO, B.CLOSE_FLAG ';
      Params.ParamByName('CARTON_NO').AsString := CartonNo;
      Open;
      LabCartonQty.Caption := '0';
      if IsEmpty then
      begin
        if ShowEmpty then
          MessageDlg('Empty Carton.', mtWarning, [mbOK], 0);
      end
      else
      begin
        while not Eof do
        begin
          if FieldByName('Close_Flag').AsString = 'Y' then
            LabCartonQty.Caption := InttoStr(StrToInt(LabCartonQty.Caption) + 1);
          Next;
        end;
        MessageDlg('Unfinished Carton.', mtWarning, [mbOK], 0);
      end;
    end
    else
    begin
      CommandText := 'SELECT SERIAL_NUMBER ' +
        'FROM SAJET.G_SN_STATUS ' +
        'WHERE CARTON_NO = :CARTON_NO ';
      Params.ParamByName('CARTON_NO').AsString := CartonNo;
      Open;
      LabCartonQty.Caption := InttoStr(RecordCount);
      if LabCartonQty.Caption = '0' then
      begin
        if ShowEmpty then
          MessageDlg('Empty Carton.', mtWarning, [mbOK], 0);
      end
      else
        MessageDlg('Unfinished Carton.', mtWarning, [mbOK], 0);
    end;
    Result := True;
  end;
end;

function TfPacking.GetPackBoxQty: Boolean;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'Box_NO', ptInput);
    CommandText := 'SELECT SERIAL_NUMBER ' +
      'FROM SAJET.G_SN_STATUS ' +
      'WHERE Box_NO = :Box_NO ';
    Params.ParamByName('Box_NO').AsString := BoxNo;
    Open;
    LabBoxQty.Caption := InttoStr(RecordCount);
    if LabBoxQty.Caption = '0' then
    begin
      if ShowEmpty then
        MessageDlg('Empty Box.', mtWarning, [mbOK], 0);
    end
    else
      MessageDlg('Unfinished Box.', mtWarning, [mbOK], 0);
    Result := True;
  end;
end;

function TfPacking.GetPallet: Boolean;
begin
  Result := False;
  PalletNo := '';
  if not GetNewNo('Pallet', PalletNo) then Exit;
  if PalletNo = '' then Exit;
  editPallet.Text := PalletNo;
  LabPalletQty.Caption := InttoStr(StrToIntDef(LabPalletQty.Caption, 0));
  AppendPalletNo;
  Result := True;
end;

function TfPacking.GetCarton: Boolean;
begin
  Result := False;
  CartonNo := '';
  if GetUnfinishCarton then
     GetPackCartonQty
  else if not GetNewNo('Carton', CartonNo) then Exit;
  if CartonNo = '' then
    if (AutoCreateCarton) and (LabCartonCap.Caption = '1') then
    else
      Exit;
  editCarton.Text := CartonNo;
  LabCartonQty.Caption := InttoStr(StrToIntDef(LabCartonQty.Caption, 0));
  if CartonNo <> '' then
    AppendCartonNo;
  Result := True;
end;

function TfPacking.GetBox: Boolean;
begin
  Result := False;
  BoxNo := '';
  if GetUnfinishBox then
     GetPackBoxQty
  else if not GetNewNo('Box', BoxNo) then Exit;
  if BoxNo = '' then
    if (AutoCreateBox) and (LabBoxCap.Caption = '1') then
    else
      Exit;
  editBox.Text := BoxNo;
  LabBoxQty.Caption := InttoStr(StrToIntDef(LabBoxQty.Caption, 0));
  if BoxNo <> '' then
    AppendBoxNo;
  Result := True;
end;

function TfPacking.CheckDupPallet: Boolean;
begin
  Result := False;
  PalletNo := '';
  with QryTemp do
  begin
{    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PNO', ptInput);
    CommandText := 'SELECT SERIAL_NUMBER ' +
      'FROM SAJET.G_SN_STATUS ' +
      'WHERE PALLET_NO = :PNO ';
    Params.ParamByName('PNO').AsString := editPallet.Text;
    Open;
    if not IsEmpty then
    begin
      Close;
      ShowMsg('Pallet No. Duplicate !!', 'ERROR');
      Exit;
    end;}


    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PNO', ptInput);
    CommandText := 'SELECT A.Close_Flag,A.Pallet_no,B.PDLINE_NAME ' +
                   '  FROM SAJET.G_Pack_Pallet A ' +
                   ' LEFT JOIN ( SELECT A.TERMINAL_ID,B.PDLINE_NAME  '+
                   '              FROM SAJET.SYS_TERMINAL A,SAJET.SYS_PDLINE B WHERE A.PDLINE_ID = B.PDLINE_ID ) B ' +
                   '  ON A.TERMINAL_ID = B.TERMINAL_ID '+
                   'WHERE PALLET_NO = :PNO and rownum = 1'; // rownum 2006.11.13 add
    Params.ParamByName('PNO').AsString := editPallet.Text;
    Open;
    if not IsEmpty then
    begin
      if FieldByName('CLOSE_FLAG').AsString = 'Y' then
      begin
        ShowMsg('Pallet No. Closed !!'+#10#13+editPallet.Text, 'ERROR');
        exit;
      end;
      ShowMsg('Pallet No. Duplicate !!'+#10#13+'Line Name : '+FieldByname('PDLINE_NAME').AsString, 'ERROR');
      Close;
      Exit;
    end;
    Close;
  end;
  PalletNo := editPallet.Text;
  Result := True;
end;

function TfPacking.CheckDupCarton: Boolean;
begin
  Result := False;
  CartonNo := '';
  with QryTemp do
  begin
{    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CNO', ptInput);
    CommandText := 'SELECT SERIAL_NUMBER ' +
      'FROM SAJET.G_SN_STATUS ' +
      'WHERE CARTON_NO = :CNO ';
    Params.ParamByName('CNO').AsString := editCarton.Text;
    Open;
    if not IsEmpty then
    begin
      Close;
      ShowMsg('Carton No. Duplicate !!', 'ERROR');
      Exit;
    end; }

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CNO', ptInput);
    CommandText := 'SELECT A.CLOSE_FLAG,A.CARTON_NO,B.PDLINE_NAME ' +
                   '  FROM SAJET.G_Pack_Carton A ' +
                   ' LEFT JOIN ( SELECT A.TERMINAL_ID,B.PDLINE_NAME  '+
                   '              FROM SAJET.SYS_TERMINAL A,SAJET.SYS_PDLINE B WHERE A.PDLINE_ID = B.PDLINE_ID ) B ' +
                   '  ON A.TERMINAL_ID = B.TERMINAL_ID '+
                   'WHERE CARTON_NO = :CNO and rownum = 1'; // rownum 2006.11.13 add
    Params.ParamByName('CNO').AsString := editCarton.Text;
    Open;
    if not IsEmpty then
    begin
      if FieldByName('CLOSE_FLAG').AsString = 'Y' then
      begin
        ShowMsg('Carton No. Closed !!'+#10#13+editCarton.Text, 'ERROR');
        exit;
      end;

      ShowMsg('Carton No. Duplicate !!'+#10#13+'Line Name : '+FieldByname('PDLINE_NAME').AsString, 'ERROR');
      Close;      
      Exit;
    end;
    Close;
  end;
  CartonNo := editCarton.Text;
  Result := True;
end;

function TfPacking.CheckDupBox: Boolean;
begin
  Result := False;
  BoxNo := '';
  with QryTemp do
  begin
{    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CNO', ptInput);
    CommandText := 'SELECT SERIAL_NUMBER ' +
      'FROM SAJET.G_SN_STATUS ' +
      'WHERE BOX_NO = :CNO ';
    Params.ParamByName('CNO').AsString := editBox.Text;
    Open;
    if not IsEmpty then
    begin
      Close;
      ShowMsg('Box No. Duplicate !!', 'ERROR');
      Exit;
    end;}



    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CNO', ptInput);
    CommandText := 'SELECT A.CLOSE_FLAG,A.Box_NO,B.PDLINE_NAME ' +
                   '  FROM SAJET.G_Pack_Box A ' +
                   ' LEFT JOIN ( SELECT A.TERMINAL_ID,B.PDLINE_NAME  '+
                   '              FROM SAJET.SYS_TERMINAL A,SAJET.SYS_PDLINE B WHERE A.PDLINE_ID = B.PDLINE_ID ) B ' +
                   '  ON A.TERMINAL_ID = B.TERMINAL_ID '+
                   'WHERE Box_NO = :CNO and rownum = 1'; // rownum 2006.11.13 add
    Params.ParamByName('CNO').AsString := editBox.Text;
    Open;
    if not IsEmpty then
    begin
      if FieldByName('CLOSE_FLAG').AsString = 'Y' then
      begin
        ShowMsg('Box No. Closed !!'+#10#13+editBox.Text, 'ERROR');
        exit;
      end;

      ShowMsg('Box No. Duplicate !!'+#10#13+'Line Name : '+FieldByname('PDLINE_NAME').AsString, 'ERROR');
      Close;
      Exit;
    end;
    Close;
  end;
  BoxNo := editBox.Text;
  Result := True;
end;

procedure TfPacking.editPalletKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    //2005/9/5==
    edtWeight2.Text := '';
    if trim(editPallet.Text) = '' then
    begin
      ShowMsg('Please Input Pallet No !!', 'ERROR');
      //MessageDlg('Please Input Pallet No !!',mtError, [mbCancel],0);
      SetEditStatus('PALLET');
      exit;
    end;
    if not CheckRule('Pallet', editPallet.Text) then
    begin
      SetEditStatus('PALLET');
      exit;
    end;
    //2005/9/5==

    if not CheckDupPallet then
    begin
      SetEditStatus('PALLET');
      exit;
    end
    else
    begin
      if (not (PackAction in [2, 4])) and (AutoCreateCarton) then
      begin
        if GetCarton then
        begin
          if (not (PackAction in [6..8])) and (AutoCreateBox) then
            CreateBox
          else if editBox.Visible then
            SetEditStatus('BOX')
          else
            SetEditStatus('SN');
        end
        else
        begin
          SetEditStatus('CARTON');
        end;
      end
      else
      begin
        SetEditStatus('CARTON');
      end;
    end;
    ShowMsg('Pallet No OK !', '');
    //panlMessage.Caption := 'Pallet No OK !';
  end;
end;

procedure TfPacking.LoadSajetDll(f_sDllName: string);
begin
  gsLoadWeight := False;
  try
    f_sDllName := uppercase(f_sDllName);
    m_DLLHandle := LoadLibrary(pchar(ExtractFilePath(Application.exename) + f_sDLLName));
    if m_DLLHandle <= 32 then raise Exception.create('Can Not Find DLL File(' + f_sDllName + ')');
    CheckWeightData := GetProcAddress(m_DLLHandle, 'CheckWeightData');
    if (@CheckWeightData = nil) then raise Exception.Create('DLL Function Not Match (1)');
    gsLoadWeight := True;
  except
    on E: Exception do
    begin
      raise Exception.create('(' + ClassName + '.LoadSajetDll)' + E.Message);
    end;
  end;
end;

procedure TfPacking.LoadAdditionalDll(f_sDllName: string);
begin
  g_bLoadAdditional := False;
  try
    f_sDllName := uppercase(f_sDllName);
    m_DLLHandle1 := LoadLibrary(pchar(ExtractFilePath(Application.exename) + f_sDLLName));
    if m_DLLHandle1 <= 32 then raise Exception.create('Can Not Find DLL File(' + f_sDllName + ')');

    AdditionalData := GetProcAddress(m_DLLHandle1, 'AdditionalData');
    if (@AdditionalData = nil) then raise Exception.Create('DLL Function Not Match (1)');
    g_bLoadAdditional := True;
  except
    on E: Exception do
    begin
      raise Exception.create('(' + ClassName + '.LoadAdditionalDll)' + E.Message);
    end;
  end;
end;

procedure TfPacking.editCartonKeyPress(Sender: TObject; var Key: Char);
var sType: string;
begin
  if Key = #13 then
  begin
    Key := #0;
    if trim(editCarton.Text) = '' then
    begin
      ShowMsg('Please Input Carton No !', 'ERROR');
      SetEditStatus('CARTON');
      exit;
    end;

    //只包棧板
    if PackAction in [2, 4] then
    begin
      if not CheckCarton(sType) then
      begin
        SetEditStatus('CARTON');
        Exit;
      end;
      {
      if chkWeight.Checked then
      begin
        ImageNG.Visible := True;
        edtWeight.Text := FloatToStr(CheckWeightData);
        edtWeight2.Text := edtWeight.Text;
        if (edtWeight.Text = '0') or (edtWeight.Text = '') then
        begin
          edtWeight2.Text := '';
          SetEditStatus('CARTON');
          Exit;
        end;
      end;
      }
      //若刷SN且原本已有Pallet and Carton,保留此號並過站 -2005/8/19
      if PackAction = 2 then
      begin
        if sType = 'SN' then
        begin
          if (gsPallet <> 'N/A') and (gsCarton <> gsPallet) then
          begin
            panlMessage.Color := clMaroon;
            panlMessage.Font.Color := clYellow;
            panlMessage.Caption := 'SN OK !' + #13#10
              + 'Pallet No : ' + gsPallet + #13#10
              + 'Carton No : ' + gsCarton + #13#10
              + 'Box No : ' + gsBox;
            PackGo(SNNO, sType);
            SetEditStatus('CARTON');
            Exit;
          end
          else
          begin
            ShowMsg('Please input Carton No!!', 'ERROR');
            SetEditStatus('CARTON');
            Exit;
          end;
        end
        else if (sType = 'CARTON') and (gsPallet <> 'N/A') and (gsCarton <> gsPallet) then
        begin
          panlMessage.Color := clMaroon;
          panlMessage.Font.Color := clYellow;
          panlMessage.Caption := 'CARTON OK !' + #13#10
            + 'Pallet No : ' + gsPallet;
          PackGo(gsCarton, sType);
          SetEditStatus('CARTON');
          Exit;
        end;
      end;

      //add by key 2007/10/06  ,除了（若刷SN且原本已有Pallet and Carton,保留此號並過站 ）
      //此條件外的其它條件都不能pass.
      if sType = 'SN' then
      begin
          ShowMsg('Please Input Carton!!', 'ERROR');
          SetEditStatus('CARTON');
          Exit;
      end;

      if gbRefreshQty then
      begin
        if not RefreshPalletQty(PalletNo) then exit; //2007/7/5
      end;
      
      if LabPalletQty.Caption <> '' then
      begin
        if StrToIntDef(LabPalletCap.Caption, 0) <= StrToIntDef(LabPalletQty.Caption, 0) then
        begin
          ShowMsg('Please Close Pallet !!', 'ERROR');
          SetEditStatus('CARTON');
          Exit;
        end;
      end;

      if not InputSN then
      begin
        SetEditStatus('CARTON');
        exit;
      end;

      LabPalletQty.Caption := InttoStr(StrToIntDef(LabPalletQty.Caption, 0) + 1);

      if StrToIntDef(LabPalletCap.Caption, 0) <= StrToIntDef(LabPalletQty.Caption, 0) then
        sbtnClosePalletClick(self)
      else
        SetEditStatus('CARTON');
    end
    else
    begin
      //2005/9/5==檢查carton編碼規則
      if not CheckRule('Carton', editCarton.Text) then
      begin
        SetEditStatus('CARTON');
        exit;
      end;
      //2005/9/5==

      if not CheckDupCarton then
      begin
        SetEditStatus('CARTON');
        exit;
      end
      else
      begin
        if (not (PackAction in [6..8])) then // 將AutoCreateBox拿掉, CreateBox裡已有檢查
          CreateBox
        else if editBox.Visible then
          SetEditStatus('BOX')
        else
          SetEditStatus('SN');
      end;
    end;
    ShowMsg('Carton No OK !', '');
  end;
end;

function TfPacking.CheckBox(var sType: string): Boolean;
var sRes: string;
begin
  Result := False;
  sType := 'BOX';
  gsBox := 'N/A';
  gsCarton := 'N/A';
  gsPallet := 'N/A';
  with QryTemp do
  begin
    //刷入的是Box號
    //CHECK SN號的current_status值 add  by key 2007/10/05
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'BOX_NO', ptInput);
    CommandText := 'Select serial_number from sajet.g_sn_status where box_no=:box_no '
                  +' and current_status=1 and rownum=1 ';
    Params.ParamByName('BOX_NO').AsString := editBox.Text;
    Open;
    if not isempty then
      begin
          SNNO := Fieldbyname('SERIAL_NUMBER').AsString;
          ShowMsg('SN '+snno+' is Fail', 'ERROR');
          close;
          Exit;
      end;

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'BOX_NO', ptInput);
    CommandText := 'SELECT A.WORK_ORDER, A.MODEL_ID,A.SERIAL_NUMBER '
      + '     , A.BOX_NO, B.PART_NO, NVL(A.PALLET_NO,''N/A'') PALLET_NO '
      + '     , NVL(A.CARTON_NO,''N/A'') CARTON_NO '
      + 'FROM  SAJET.G_SN_STATUS A, SAJET.SYS_PART B '
      + 'WHERE A.BOX_NO = :BOX_NO '
      + 'AND   A.MODEL_ID = B.PART_ID(+) and rownum = 1'; // rownum 2006.11.13 add
    Params.ParamByName('BOX_NO').AsString := editBox.Text;
    Open;
    if IsEmpty then
    begin
      //====2006/3/17===
      //刷入的是SN號
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
      CommandText := 'SELECT A.WORK_ORDER, A.MODEL_ID,A.SERIAL_NUMBER,B.PART_NO '
        + '     , NVL(A.BOX_NO,''N/A'') BOX_NO '
        + '     , NVL(A.CARTON_NO,''N/A'') CARTON_NO, NVL(A.PALLET_NO,''N/A'') PALLET_NO '
        + 'FROM  SAJET.G_SN_STATUS A, SAJET.SYS_PART B '
        + 'WHERE A.SERIAL_NUMBER = :SERIAL_NUMBER '
        + 'AND   A.MODEL_ID = B.PART_ID(+) and rownum = 1'; // rownum 2006.11.13 add
      Params.ParamByName('SERIAL_NUMBER').AsString := editBox.Text;
      Open;
      if IsEmpty then
      begin
        //刷入的是Customer SN號
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
        CommandText := 'SELECT A.WORK_ORDER, A.MODEL_ID,A.SERIAL_NUMBER,B.PART_NO '
          + '     , NVL(A.BOX_NO,''N/A'') BOX_NO '
          + '     , NVL(A.CARTON_NO,''N/A'') CARTON_NO, NVL(A.PALLET_NO,''N/A'') PALLET_NO '
          + 'FROM  SAJET.G_SN_STATUS A, SAJET.SYS_PART B '
          + 'WHERE A.CUSTOMER_SN = :SERIAL_NUMBER '
          + 'AND   A.MODEL_ID = B.PART_ID(+) and rownum = 1'; // rownum 2006.11.13 add
        Params.ParamByName('SERIAL_NUMBER').AsString := editBox.Text;
        Open;
        if IsEmpty then
        begin
          Close;
          ShowMsg('Box not found!!', 'ERROR');
          Exit;
        end;
      end;
      sType := 'SN';
      SNNO := Fieldbyname('SERIAL_NUMBER').AsString;
      gsBox := Fieldbyname('Box_NO').AsString;
      gsCarton := Fieldbyname('CARTON_NO').AsString;
      gsPallet := Fieldbyname('PALLET_NO').AsString;
//    if (gsCarton = 'N/A') or (gsPallet = 'N/A') then
      if (gsBox = 'N/A') then
         begin
           ShowMsg('SN: ' + SNNO + #10#10 + ' Box is null !!', 'ERROR');
           exit;
      end;
    end
    else
    begin
      SNNO := Fieldbyname('SERIAL_NUMBER').AsString;
      gsBox := Fieldbyname('Box_NO').AsString;
      gsCarton := Fieldbyname('CARTON_NO').AsString;
      gsPallet := Fieldbyname('PALLET_NO').AsString;
    end;
    gSNWo := Fieldbyname('WORK_ORDER').AsString;
    if PackingBase = 'Work Order' then
    begin
      if mWO <> '' then
      begin
        if mWO <> Fieldbyname('WORK_ORDER').AsString then
        begin
          ShowMsg('Work Order is Different !!' + #13#10 + Fieldbyname('WORK_ORDER').AsString, 'ERROR');
          Close;
          Exit;
        end;
      end;
    end
    else
    begin
      if mPartNo <> '' then
      begin
        if mPartNo <> Fieldbyname('PART_NO').AsString then
        begin
          ShowMsg('Model is Different !!' + #13#10 + Fieldbyname('PART_NO').AsString, 'ERROR');
          Close;
          Exit;
        end;
      end;
    end;

    //檢查此Carton是否已Close
    if not F_CHK_CLOSE_BOX(Fieldbyname('BOX_NO').AsString) then exit;

    first;
    listSN.Clear;
    while not Eof do
    begin
      listSN.Items.Add(Fieldbyname('SERIAL_NUMBER').AsString);
      Next;
    end;
    if sType = 'BOX' then
    begin
      BoxNo := editBox.Text;
      LabBoxQty.Caption := IntToStr(RecordCount);
    end;
    Close;
  end;

  // Check Route
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CKRT_ROUTE');
      FetchParams;
      Params.ParamByName('TERMINALID').AsString := TerminalID;
      Params.ParamByName('TSN').AsString := listSN.Items.Strings[0];
      Execute;
      sRes := Params.ParamByName('TRES').AsString;
    except
    end;
    Close;
  end;

  if sRes <> 'OK' then
  begin
    ShowMsg('Route Error: ' + sRes, 'ERROR');
    Exit;
  end;
  Result := True;
end;

function TfPacking.CheckCarton(var sType: string): Boolean;
var sRes: string;
begin
  Result := False;
  sType := 'CARTON';
  gsCarton := 'N/A';
  gsPallet := 'N/A';
  with QryTemp do
  begin
    //刷入的是Carton號
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CARTON_NO', ptInput);
    CommandText := 'SELECT A.WORK_ORDER, A.MODEL_ID,A.SERIAL_NUMBER '
      + '     , A.CARTON_NO, B.PART_NO,NVL(A.PALLET_NO,''N/A'') PALLET_NO '
      + 'FROM  SAJET.G_SN_STATUS A, SAJET.SYS_PART B '
      + 'WHERE A.CARTON_NO = :CARTON_NO '
      + 'AND   A.MODEL_ID = B.PART_ID(+) and rownum = 1'; // rownum 2006.11.13 add
    Params.ParamByName('CARTON_NO').AsString := editCarton.Text;
    Open;
    if IsEmpty then
    begin
      //====2006/3/17===
      //刷入的是SN號
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
      CommandText := 'SELECT A.WORK_ORDER, A.MODEL_ID,A.SERIAL_NUMBER,B.PART_NO '
        + '     , NVL(A.CARTON_NO,''N/A'') CARTON_NO, NVL(A.PALLET_NO,''N/A'') PALLET_NO '
        + 'FROM  SAJET.G_SN_STATUS A, SAJET.SYS_PART B '
        + 'WHERE A.SERIAL_NUMBER = :SERIAL_NUMBER '
        + 'AND   A.MODEL_ID = B.PART_ID(+) and rownum = 1';  // rownum 2006.11.13 add
      Params.ParamByName('SERIAL_NUMBER').AsString := editCarton.Text;
      Open;
      if IsEmpty then
      begin
        //刷入的是Customer SN號
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
        CommandText := 'SELECT A.WORK_ORDER, A.MODEL_ID,A.SERIAL_NUMBER,B.PART_NO '
          + '     , NVL(A.CARTON_NO,''N/A'') CARTON_NO, NVL(A.PALLET_NO,''N/A'') PALLET_NO '
          + 'FROM  SAJET.G_SN_STATUS A, SAJET.SYS_PART B '
          + 'WHERE A.CUSTOMER_SN = :SERIAL_NUMBER '
          + 'AND   A.MODEL_ID = B.PART_ID(+) and rownum = 1'; // rownum 2006.11.13 add
        Params.ParamByName('SERIAL_NUMBER').AsString := editCarton.Text;
        Open;
        if IsEmpty then
        begin
          Close;
          ShowMsg('Carton not found!!', 'ERROR');
          Exit;
        end;
      end;
      sType := 'SN';  
      SNNO := Fieldbyname('SERIAL_NUMBER').AsString;
      gsCarton := Fieldbyname('CARTON_NO').AsString;
      gsPallet := Fieldbyname('PALLET_NO').AsString;
      if (gsCarton = 'N/A') then
      begin
        ShowMsg('SN: ' + SNNO + #10#10 + ' Carton is null !!', 'ERROR');
        exit;
      end;
    end
    else
    begin
      SNNO := Fieldbyname('SERIAL_NUMBER').AsString;
      gsCarton := Fieldbyname('CARTON_NO').AsString;
      gsPallet := Fieldbyname('PALLET_NO').AsString;
    end;
    gSNWo := Fieldbyname('WORK_ORDER').AsString;
    if PackingBase = 'Work Order' then
    begin
      if mWO <> '' then
      begin
        if mWO <> Fieldbyname('WORK_ORDER').AsString then
        begin
          ShowMsg('Work Order is Different !!' + #13#10 + Fieldbyname('WORK_ORDER').AsString, 'ERROR');
          Close;
          Exit;
        end;
      end;
    end
    else
    begin
      if mPartNo <> '' then
      begin
        if mPartNo <> Fieldbyname('PART_NO').AsString then
        begin
          ShowMsg('Model is Different !!' + #13#10 + Fieldbyname('PART_NO').AsString, 'ERROR');
          Close;
          Exit;
        end;
      end;
    end;

    //檢查此Carton是否已Close
    if not F_CHK_CLOSE_CARTON(Fieldbyname('CARTON_NO').AsString) then exit;

    first;
    listSN.Clear;
    while not Eof do
    begin
      listSN.Items.Add(Fieldbyname('SERIAL_NUMBER').AsString);
      Next;
    end;
    if sType = 'CARTON' then
    begin
      CartonNo := editCarton.Text;
      LabCartonQty.Caption := IntToStr(RecordCount);
    end;
    Close;
  end;

  // Check Route
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CKRT_ROUTE');
      FetchParams;
      Params.ParamByName('TERMINALID').AsString := TerminalID;
      Params.ParamByName('TSN').AsString := listSN.Items.Strings[0];
      Execute;
      sRes := Params.ParamByName('TRES').AsString;
    except
    end;
    Close;
  end;

  if sRes <> 'OK' then
  begin
    ShowMsg('Route Error: ' + sRes, 'ERROR');
    Exit;
  end;
  Result := True;
end;

function TfPacking.F_CHK_CLOSE_CARTON(sCartonNo: string): Boolean;
begin
  Result := False;
  with QryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CARTON_NO', ptInput);
    CommandText := 'SELECT CLOSE_FLAG from SAJET.G_PACK_CARTON '
      + 'WHERE CARTON_NO = :CARTON_NO and rownum = 1'; // rownum 2006.11.13 add
    Params.ParamByName('CARTON_NO').AsString := sCartonNo;
    Open;
    if FieldByName('CLOSE_FLAG').asstring <> 'Y' then
    begin
      ShowMsg('This Carton have not Close', 'ERROR');
      exit;
    end;
    Result := True;
  end;
end;

function TfPacking.F_CHK_CLOSE_Box(sBoxNo: string): Boolean;
begin
  Result := False;
  with QryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'BOX_NO', ptInput);
    CommandText := 'SELECT CLOSE_FLAG from SAJET.G_PACK_BOX '
      + 'WHERE BOX_NO = :BOX_NO and rownum = 1'; // rownum 2006.11.13 add
    Params.ParamByName('BOX_NO').AsString := sBoxNo;
    Open;
    if FieldByName('CLOSE_FLAG').asstring = 'N' then //2007.03.29改回 = 'N', 因為連版未填
    begin
      ShowMsg('This Box have not Close', 'ERROR');
      exit;
    end;
    Result := True;
  end;
end;

procedure TfPacking.editSNKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    // ADD BY KEY 2009/04/01
    IF NOT checkpdlinestatus(TerminalID) THEN EXIT ;
    // ADD END
    Key := #0;
    panlMessage.Caption := '';

  //===== add by rita 20070604 檢查是否為 Defect Code=====
    editSN.Text := Trim(editSN.Text);
    if UpperCase(editSN.Text)='UNDO' then
    begin
      LvEC.Clear;
      lablErrorCode.Caption:='';
      editCSN.Text := '';
      SetEditStatus('SN');
      ShowMsg('UNDO OK','');
      Exit;
    end;
    if g_bInputEC then   // 2007/08/17 Add - 檢查是否可輸入不良代碼
       if CheckDefect(editSN.Text) then
       begin
         editCSN.Text := '';
         SetEditStatus('SN');
         Exit;
       end;
   //=======================================================

    if not CheckSN then
    begin
      SetEditStatus('SN');
      Exit;
    end;

   //=====add by rita 20070604 不良品直接過站 ===============
    IF lvEC.Items.Count > 0 then
    begin
      if InputErrorSN then
      begin
        LvEC.Clear;
        lablErrorCode.Caption:='';
        ShowMsg('SN OK !', '');
      end;
      SetEditStatus('SN');
      Exit;
    end;
    //=======================================================
   {  //check weight 此程式段移到　input sn  FUNCTION 模塊中　2008/10/22 by key
   if chkWeight.Checked then
    begin
      ImageNG.Visible := True;
      edtWeight.Text := FloatToStr(CheckWeightData);
      edtWeight2.Text := edtWeight.Text;
      if (edtWeight.Text = '0') or (edtWeight.Text = '') then
      begin
        edtWeight2.Text := '';
        SetEditStatus('SN');
        Exit;
      end;
    end;
    }
    //若SN原本已有Pallet and Carton,保留此號並過站 -2005/8/19
    //(packAction in [0, 3]) and
    if (gsPallet <> 'N/A') and (gsCarton <> 'N/A') then
    begin
      panlMessage.Color := clMaroon;
      panlMessage.Font.Color := clYellow;
      panlMessage.Caption := 'SN: ' + editSN.Text + ' OK !' + #13#10
        + 'Pallet No: ' + gsPallet + #13#10
        + 'Carton No: ' + gsCarton;
      if editBox.Visible then
        panlMessage.Caption := panlMessage.Caption + #13#10 + 'Box No: ' + gsBox;
      editCSN.Text := CSNNo;
      PackGo(SNNO, 'SN');
      SetEditStatus('SN');
      Exit;
    end;

    //2007/7/5 -Refresh Qty,避免兩台同時作業
    if gbRefreshQty then
    begin
      if packAction in [3] then palletno:=cartonno; //add by key 2007/10/05 palletno取值不正確
      if not RefreshPalletQty(PalletNo) then exit;
      if not RefreshCartonQty(CartonNo) then exit;
    end;

    if (LabBoxQty.Caption <> '') and (LabBoxQty.Visible) then
    begin
      if gbRefreshQty then
      begin
        if not RefreshBoxQty(BoxNo) then exit;  //2007/7/5
      end;

      if StrToIntDef(LabBoxCap.Caption, 0) <= StrToIntDef(LabBoxQty.Caption, 0) then
      begin
        ShowMsg('Please Close Box !!', 'ERROR');
        Exit;
      end;
    end;

    if not (packAction in [2, 4, 5]) then
      if LabCartonQty.Caption <> '' then
      begin
        if StrToIntDef(LabCartonCap.Caption, 0) <= StrToIntDef(LabCartonQty.Caption, 0) then
        begin
          ShowMsg('Please Close Carton !!', 'ERROR');
          Exit;
        end;
      end;

    if not (packAction in [1, 3, 5, 6, 8]) then
      if LabPalletQty.Caption <> '' then
      begin
        if StrToIntDef(LabPalletCap.Caption, 0) <= StrToIntDef(LabPalletQty.Caption, 0) then
        begin
          ShowMsg('Please Close Pallet !!', 'ERROR');
          Exit;
        end;
      end;

    if AutoCreateCSN then
    begin
      if not GetNewNo('SSN', CSNNo) then Exit;
      editCSN.Text := CSNNo;
      if (CheckBoxeqSN) and (editBox.Visible) then
      begin
        SetEditStatus('BOX');
        exit;
      end;
      if not InputSN then
      begin
        SetEditStatus('SN');
        exit;
      end;

      ShowMsg('SN OK !', '');
      if (LabBoxCap.Visible) and (StrToIntDef(LabBoxCap.Caption, 0) <= StrToIntDef(LabBoxQty.Caption, 0)) then
        sbtnCloseBoxClick(self)
      else if not editBox.Visible then
        sbtnCloseBoxClick(self)
      else
        SetEditStatus('SN');
    end
    else if NotChangeCSN then
    begin
      editCSN.Text := CSNNo;
      if (CheckBoxeqSN) and (editBox.Visible) then
      begin
        SetEditStatus('BOX');
        exit;
      end;
      if not InputSN then
      begin
        SetEditStatus('SN');
        exit;
      end;
      ShowMsg('SN OK !', '');
      if (LabBoxCap.Visible) and (StrToIntDef(LabBoxCap.Caption, 0) <= StrToIntDef(LabBoxQty.Caption, 0)) then
        sbtnCloseBoxClick(self)
      else if not editBox.Visible then
        sbtnCloseBoxClick(self)
      else
        SetEditStatus('SN');
    end
    else
    begin
      SetEditStatus('CSN');
    end;
  end;
end;

function TfPacking.CheckSN: Boolean;
var sRes: string;
 ipos:integer;
begin
  Result := False;

  // Check SN
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CKRT_SN_PSN');
      FetchParams;
      Params.ParamByName('TREV').AsString := editSN.Text;
      Execute;
      sRes := Params.ParamByName('TRES').AsString;
      SNNO := Params.ParamByName('PSN').AsString;
    except
      on E: Exception do
      begin
        sRes := 'SJ_CKRT_SN_PSN Exception' + #13#10 + E.Message;
      end;
    end;
    Close;
  end;
  if sRes <> 'OK' then
  begin
    ShowMsg(sRes, 'ERROR');
    Exit;
  end;


  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
    CommandText := 'SELECT A.WORK_ORDER, A.WORK_FLAG, A.MODEL_ID '
      + '     , A.CUSTOMER_SN, A.SERIAL_NUMBER, B.PART_NO '
      + '     , NVL(A.PALLET_NO,''N/A'') PALLET_NO,NVL(A.CARTON_NO,''N/A'') CARTON_NO '
      + '     ,NVL(A.BOX_NO,''N/A'') BOX_NO '
      + 'FROM   SAJET.G_SN_STATUS A '
      + '     , SAJET.SYS_PART B '
      + 'WHERE  A.SERIAL_NUMBER = :SERIAL_NUMBER '
      + 'AND    A.MODEL_ID = B.PART_ID(+) and rownum = 1 ';  // rownum 2006.11.13 add
    Params.ParamByName('SERIAL_NUMBER').AsString := SNNO;
    Open;
   {if IsEmpty then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'CUSTOMER_SN', ptInput);
      CommandText := 'SELECT A.WORK_ORDER, A.WORK_FLAG, A.MODEL_ID '
        + '     , A.CUSTOMER_SN, A.SERIAL_NUMBER, B.PART_NO '
        + '     , NVL(A.PALLET_NO,''N/A'') PALLET_NO,NVL(A.CARTON_NO,''N/A'') CARTON_NO '
        + '     ,NVL(A.BOX_NO,''N/A'') BOX_NO '
        + 'FROM   SAJET.G_SN_STATUS A '
        + '     , SAJET.SYS_PART B '
        + 'WHERE  A.CUSTOMER_SN = :CUSTOMER_SN '
        + 'AND    A.MODEL_ID = B.PART_ID(+) and rownum = 1'; // rownum 2006.11.13 add
      Params.ParamByName('CUSTOMER_SN').AsString := editSN.Text;
      Open;
      if IsEmpty then
      begin
        Close;
        ShowMsg('Serial Number not found!!', 'ERROR');
        Exit;
      end;
    end;
    if Fieldbyname('WORK_FLAG').AsString = '1' then
    begin
      Close;
      ShowMsg('Serial Number Srcap.', 'ERROR');
      Exit;
    end;  }

    if PackingBase = 'Work Order' then
    begin
      if mWO <> '' then
      begin
        if mWO <> Fieldbyname('WORK_ORDER').AsString then
        begin
          ShowMsg('Work Order is Different!!' + #13#10 + Fieldbyname('WORK_ORDER').AsString, 'ERROR');
          Close;
          Exit;
        end;
      end;
    end
    else
    begin
      if mPartNo <> '' then
      begin
        if mPartNo <> Fieldbyname('PART_NO').AsString then
        begin
          ShowMsg('Model is Different!!' + #13#10 + Fieldbyname('PART_NO').AsString, 'ERROR');
          Close;
          Exit;
        end;
      end;
    end;
    //2008/10/21 ADD   gSNWo := Fieldbyname('WORK_ORDER').AsString for check weight
    gSNWo := Fieldbyname('WORK_ORDER').AsString;
    SNNO := Fieldbyname('SERIAL_NUMBER').AsString;
    CSNNo := Fieldbyname('CUSTOMER_SN').AsString;

    gsPallet := Fieldbyname('PALLET_NO').AsString;
    gsCarton := Fieldbyname('CARTON_NO').AsString;
    gsBox := Fieldbyname('BOX_NO').AsString;
    listSN.Items.Clear;
    listSN.Items.Add(SNNO);
    Close;
  end;

   //---找最小的沒有包裝的條碼----
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WO', ptInput);
      CommandText := 'SELECT NVL(MIN(substr(CUSTOMER_SN,INSTR(CUSTOMER_SN,substr(:WO,4,2),1)+2,5)),''00000'') MIN_SEQ '+
                    'FROM SAJET.G_SN_STATUS WHERE WORK_ORDER=:WO AND CARTON_NO =''N/A'' and CUSTOMER_SN <>''N/A'' and WIP_PROCESS = ' +G_sPROCESSID ;
      Params.ParamByName('WO').AsString := editMO.Text;
      Open;


      ipos := pos( COpy(editmo.Text,4,2),  CSNNo);

      if   Copy( CSNNo,ipos+2,5) <> Fieldbyname('MIN_SEQ').AsString  then begin
           ShowMsg('Seq Error: 不是最小序列號','ERROR');
           Exit;
      end;
   end;

  // Check Route
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CKRT_ROUTE');
      FetchParams;
      Params.ParamByName('TERMINALID').AsString := TerminalID;
      Params.ParamByName('TSN').AsString := SNNO;
      Execute;
      sRes := Params.ParamByName('TRES').AsString;
    except
      on E: Exception do
      begin
        sRes := 'SJ_CKRT_ROUTE Exception' + #13#10 + E.Message;
      end;
    end;
    Close;
  end;
  if sRes <> 'OK' then
  begin
    ShowMsg('Route Error: ' + sRes, 'ERROR');
    Exit;
  end;
  Result := True;

end;

function TfPacking.InputErrorSN:Boolean;
var dtSysdate: TDateTime;
    sRes:String;
    i:integer;
begin
  sRes:='OK';
  result := True;
  with QryTemp do
  begin
    try
      Close;
      Params.Clear;
      CommandText := 'SELECT SYSDATE FROM DUAL ';
      OPEN;
      dtSysdate := FieldByName('SYSDATE').AsDateTime;
    finally
      Close;
    end;
  end;
  // 過站紀錄
  for i:= 0 to LVEc.Items.Count-1 do
  begin
    with SProc do
    begin
      try
        Close;
        DataRequest('SAJET.SJ_NOGO');
        FetchParams;
        Params.ParamByName('TTERMINALID').AsString := TerminalID;
        Params.ParamByName('TSN').AsString := listSN.items.strings[0]; //SNNO;
        Params.ParamByName('TDEFECT').AsString := LVEc.Items[i].Caption;
        Params.ParamByName('TNOW').AsDateTime := dtSysdate;
        Params.ParamByName('TEMP').AsString := UpdateUserNo;
        Execute;
        sRes := Params.ParamByName('TRES').AsString;
       //Limit by key 2009/03/17 : 因為不為顯示sj_nogo中的錯誤信息
        //if sRes <> 'OK' then
       // begin
         // exit;
       // end;
      except
        on E: Exception do
        begin
          sRes := 'Call SAJET.SJ_NOGO Exception-' + E.Message;
        end;
      end;
      Close;
    end;
  end;
  if sRes<>'OK' then
  begin
    Result := False;
    ShowMsg(sRes, 'ERROR');
  end;

end;
function TfPacking.InputSN: Boolean;
var sRes, sPrintData: string; dtSysdate: TDateTime; g_tsParam, g_tsData: TStrings;
begin
  Result := False;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT SYSDATE FROM DUAL ';
    OPEN;
    dtSysdate := FieldByName('SYSDATE').AsDateTime;
    Close;
  end;

  {   if chkWeight.Checked then
         if not CheckWeight then Exit;
  }
  //add weight 2008/10/21
  if chkWeight.Checked then
  BEGIN
      ImageNG.Visible := True;
      edtWeight.Text := FloatToStr(CheckWeightData);
      edtWeight2.Text := edtWeight.Text;
      if (edtWeight.Text = '0') or (edtWeight.Text = '') then
      begin
        edtWeight2.Text := '';
        if PackAction in [2,4] then
            SetEditStatus('CARTON')
        else if PackAction in [6,7,8] then
            SetEditStatus('BOX')
        else
            SetEditStatus('SN') ;
        Exit;
      end;
      if not CheckWeight then Exit;
  END;

  //2007/3/8 客製欄位檢查
  if g_bAdditional then
  begin
    if not CallAdditionalDll then
      exit;
  end;

  //2007/6/22 附件包裝
  if g_bPackAssy then
  begin
    if not CallAssyDll then
    begin
      exit;
    end;
  end;
    
  if packAction in [0, 2, 3, 4, 7, 8] then
  begin
    if packAction in [3, 8] then PalletNo := CartonNo;
    AppendPalletNo;
  end;
  if (packAction <> 2) and (packAction <> 4) then
  begin
    if not (packAction in [6..8]) then
    begin
      if NoBoxRule then
      begin
        editBox.Text := CSNNo;
        BoxNo := CSNNo;
      end;
      if BoxNo <> '' then
        AppendBoxNo;
    end;
    if packAction <> 5 then
    begin
      if NoCartonRule then
      begin
        if BoxNo = '' then
        begin
          editCarton.Text := CSNNo;
          CartonNo := CSNNo;
        end
        else
        begin
          editCarton.Text := BoxNo;
          CartonNo := BoxNo;
        end;
      end;
      AppendCartonNo;
    end;
  end;

  // 過站紀錄
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_PACKING_GO');
      FetchParams;
      Params.ParamByName('TTERMINALID').AsString := TerminalID;
      Params.ParamByName('TSN').AsString := listSN.items.strings[0]; //SNNO;
      Params.ParamByName('TNOW').AsDateTime := dtSysdate;
      Params.ParamByName('TEMP').AsString := UpdateUserNo;
      Params.ParamByName('PACKACTION').AsString := IntToStr(packAction);
      Params.ParamByName('PALLETNO').AsString := PalletNo;
      Params.ParamByName('CARTONNO').AsString := CartonNo;
      if LabBoxCap.Caption = '0' then
        Params.ParamByName('BOXNO').AsString := 'N/A'
      else
        Params.ParamByName('BOXNO').AsString := BoxNo;
      Params.ParamByName('CUSTOMERSN').AsString := CSNNo;
      Execute;
      sRes := Params.ParamByName('TRES').AsString;
    except
      on E: Exception do
      begin
        sRes := 'Call SJ_PACKING_GO Exception-' + E.Message;
      end;
    end;
    Close;
  end;

  if sRes <> 'OK' then
  begin
    ShowMsg(sRes, 'ERROR');
    exit;
  end;

  if not (packAction in [2, 4]) then
  begin
    if PrintCSNLabel then
    begin
      if PrintCSNMethod = 'CodeSoft' then
      begin
        sPrintData := G_getPrintData(CodesoftVersion, 3, G_sockConnection, 'DspQryData', SNNO, PrintCSNLabQty, '', g_tsParam, g_tsData);
        G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil);
      end
      else if PrintCSNMethod = 'DLL' then
      begin
        CallDllPrint(3);
      end;
    end;
    LabBoxQty.Caption := InttoStr(StrToIntDef(LabBoxQty.Caption, 0) + 1);
  end;
  Result := True;
end;

procedure TfPacking.AppendPalletNo;
begin
  if PalletNo = 'N/A' then Exit;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PALLET_NO', ptInput);
    CommandText := 'SELECT PALLET_NO ' +
      'FROM SAJET.G_PACK_PALLET ' +
      'WHERE PALLET_NO = :PALLET_NO and rownum = 1'; // rownum 2006.11.13 add
    Params.ParamByName('PALLET_NO').AsString := PalletNo;
    Open;
    if isEmpty then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'MODEL_ID', ptInput);
      Params.CreateParam(ftString, 'PALLET_NO', ptInput);
      Params.CreateParam(ftString, 'CLOSE_FLAG', ptInput);
      Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
      Params.CreateParam(ftString, 'CREATE_EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
      CommandText := 'INSERT INTO SAJET.G_PACK_PALLET ' +
        ' (WORK_ORDER,MODEL_ID, PALLET_NO, CLOSE_FLAG, TERMINAL_ID, CREATE_EMP_ID, PKSPEC_NAME) ' +
        'VALUES (:WORK_ORDER, :MODEL_ID, :PALLET_NO, :CLOSE_FLAG, :TERMINAL_ID, :CREATE_EMP_ID, :PKSPEC_NAME)';
      Params.ParamByName('WORK_ORDER').AsString := mWO;
      Params.ParamByName('MODEL_ID').AsString := mPartID;
      Params.ParamByName('PALLET_NO').AsString := PalletNo;
      Params.ParamByName('CLOSE_FLAG').AsString := 'N';
      Params.ParamByName('TERMINAL_ID').AsString := TerminalID;
      Params.ParamByName('CREATE_EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PKSPEC_NAME').AsString := sPKSpec;
      Execute;
      Close;
    end;
  end;
end;

procedure TfPacking.AppendCartonNo;
begin
  if CartonNo = 'N/A' then Exit;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CARTON_NO', ptInput);
    CommandText := 'SELECT CARTON_NO ' +
      'FROM SAJET.G_PACK_CARTON ' +
      'WHERE CARTON_NO = :CARTON_NO and rownum = 1'; // rownum 2006.11.13 add
    Params.ParamByName('CARTON_NO').AsString := CartonNo;
    Open;
    if isEmpty then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'MODEL_ID', ptInput);
      Params.CreateParam(ftString, 'CARTON_NO', ptInput);
      Params.CreateParam(ftString, 'CLOSE_FLAG', ptInput);
      Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
      Params.CreateParam(ftString, 'CREATE_EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
      CommandText := 'INSERT INTO SAJET.G_PACK_CARTON ' +
        ' (WORK_ORDER, MODEL_ID, CARTON_NO, CLOSE_FLAG, TERMINAL_ID, CREATE_EMP_ID, PKSPEC_NAME) ' +
        'VALUES (:WORK_ORDER, :MODEL_ID, :CARTON_NO, :CLOSE_FLAG, :TERMINAL_ID, :CREATE_EMP_ID, :PKSPEC_NAME)';
      Params.ParamByName('WORK_ORDER').AsString := mWO;
      Params.ParamByName('MODEL_ID').AsString := mPartID;
      Params.ParamByName('CARTON_NO').AsString := CartonNo;
      Params.ParamByName('CLOSE_FLAG').AsString := 'N';
      Params.ParamByName('TERMINAL_ID').AsString := TerminalID;
      Params.ParamByName('CREATE_EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PKSPEC_NAME').AsString := sPKSpec;
      Execute;
      Close;
    end;
  end;
end;

procedure TfPacking.AppendBoxNo;
begin
  if BoxNo = 'N/A' then Exit;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'Box_NO', ptInput);
    CommandText := 'SELECT Box_NO ' +
      'FROM SAJET.G_PACK_Box ' +
      'WHERE Box_NO = :Box_NO and rownum = 1';  // rownum 2006.11.13 add
    Params.ParamByName('Box_NO').AsString := BoxNo;
    Open;
    if IsEmpty then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'MODEL_ID', ptInput);
      Params.CreateParam(ftString, 'Box_NO', ptInput);
      Params.CreateParam(ftString, 'CLOSE_FLAG', ptInput);
      Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
      Params.CreateParam(ftString, 'CREATE_EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
      CommandText := 'INSERT INTO SAJET.G_PACK_Box ' +
        ' (WORK_ORDER, MODEL_ID, Box_NO, CLOSE_FLAG, TERMINAL_ID, CREATE_EMP_ID, PKSPEC_NAME) ' +
        'VALUES (:WORK_ORDER, :MODEL_ID, :Box_NO, :CLOSE_FLAG, :TERMINAL_ID, :CREATE_EMP_ID, :PKSPEC_NAME)';
      Params.ParamByName('WORK_ORDER').AsString := mWO;
      Params.ParamByName('MODEL_ID').AsString := mPartID;
      Params.ParamByName('Box_NO').AsString := BoxNo;
      Params.ParamByName('CLOSE_FLAG').AsString := 'N';
      Params.ParamByName('TERMINAL_ID').AsString := TerminalID;
      Params.ParamByName('CREATE_EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PKSPEC_NAME').AsString := sPKSpec;
      Execute;
    end;
  end;
end;

procedure TfPacking.editCSNKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    if trim(editCSN.Text) = '' then
    begin
      ShowMsg('Please Input Customer SN !!', 'ERROR');
      SetEditStatus('CSN');
      exit;
    end;

    if CheckCSNeqSN then // 2007.05.23 先檢查是否要相等
    begin
        if editCSN.Text <> editSN.Text then
        begin
          ShowMsg('Customer SN <> Serial Number!', 'ERROR');
          SetEditStatus('CSN');
          Exit;
        end;
    end else
    begin  
      //2005/9/5==  檢查客戶序號規則
      if not CheckRule('SSN', editCSN.Text) then
      begin
        SetEditStatus('CSN');
        exit;
      end;
    end;
    if not CheckDupCSN then
    begin
      SetEditStatus('CSN');
      Exit;
    end;

    if (CheckBoxeqSN) and (editBox.Visible) then
    begin
      SetEditStatus('BOX');
      exit;
    end;
    if not InputSN then
    begin
      SetEditStatus('SN');
      exit;
    end;

    ShowMsg('CSN OK !', '');

    if StrToIntDef(LabBoxCap.Caption, 0) <= StrToIntDef(LabBoxQty.Caption, 0) then
      sbtnCloseBoxClick(self)
    else
      SetEditStatus('SN');
  end;
end;

function TfPacking.CheckDupCSN: Boolean;
begin
  Result := False;
  CSNNo := '';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CSN', ptInput);
    CommandText := 'SELECT SERIAL_NUMBER ' +
      'FROM SAJET.G_SN_STATUS ' +
      'WHERE CUSTOMER_SN = :CSN and rownum = 1';  // rownum 2006.11.13 add
    Params.ParamByName('CSN').AsString := editCSN.Text;
    Open;
    if not IsEmpty then
    begin
      Close;
      ShowMsg('Customer SN Duplicate !!', 'ERROR');
       //MessageDlg('Customer SN Duplicate !!',mtError, [mbCancel],0);
      Exit;
    end;
    Close;
  end;
  CSNNo := editCSN.Text;
  Result := True;
end;

procedure TfPacking.Label3Click(Sender: TObject);
begin
  ShowMessage(PrintCSNMethod);
end;

procedure TfPacking.sbtnCloseCartonClick(Sender: TObject);
var sPrintData: string; g_tsParam, g_tsData: TStrings; bCreate: Boolean;
begin
  if editCarton.Text = '' then
    Exit;

  if not AutoClose then
  begin
    if (Sender is TForm) or ((Sender is TSpeedButton) and ((Sender as TSpeedButton).Name = 'sbtnCloseCarton')) then
      if MessageDlg('Close This Carton ??', mtCustom, mbOKCancel, 0) <> mrOK then Exit;
  end;

  //Check Privilege.if no Change User
  if ((Sender is TSpeedButton) and ((Sender as TSpeedButton).Name = 'sbtnCloseCarton')) then
  begin
    if G_iClosePrivilege < 1 then
       if not checkChangeUserClosePrivilege then Exit;
  end;

  //若Carton中無序號,不需Close Carton
  with QryTemp do
  begin
    if not (packAction in [6..8]) and (editBox.Visible) then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'BOX', PtInput);
      CommandText := 'Select serial_number FROM SAJET.G_SN_STATUS '
        + 'WHERE BOX_NO = :BOX and rownum = 1';
      Params.ParamByName('BOX').AsString := editBox.Text;
      Open;
      if not IsEmpty then
        sbtnCloseBoxClick(sbtnCloseCarton)
      else begin
        if editBox.Text <> '' then begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'BOX', PtInput);
          CommandText := 'delete from sajet.g_pack_box '
            + 'where box_no = :BOX and rownum = 1';
          Params.ParamByName('BOX').AsString := editBox.Text;
          Execute;
          Close;
        end;
      end;
    end;
    Close;
    if LabCartonQty.Caption <> '0' then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'CARTON_NO', ptInput);
      CommandText := 'UPDATE SAJET.G_PACK_CARTON ' +
        'SET CLOSE_FLAG = ''Y'' ' +
        'WHERE CARTON_NO = :CARTON_NO and rownum = 1'; // rownum 2006.11.13 add
      Params.ParamByName('CARTON_NO').AsString := CartonNo;
      Execute;
      if packAction in [3, 8] then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'Pallet_No', ptInput);
        CommandText := 'UPDATE SAJET.G_PACK_Pallet ' +
          'SET CLOSE_FLAG = ''Y'' ' +
          'WHERE Pallet_No = :Pallet_No and rownum = 1'; // rownum 2006.11.13 add
        Params.ParamByName('Pallet_No').AsString := CartonNo;
        Execute;
      end;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PACK_NO', ptInput);
      Params.CreateParam(ftString, 'PACK_TYPE', ptInput);
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      CommandText := 'INSERT INTO SAJET.G_PACK_FORCECLOSE ' +
        '(PACK_NO, PACK_TYPE, EMP_ID) ' +
        'VALUES (:PACK_NO, :PACK_TYPE, :EMP_ID)';
      Params.ParamByName('PACK_NO').AsString := CartonNo;
      Params.ParamByName('PACK_TYPE').AsString := 'Carton';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Execute;
      if PrintCartonLabel then
      begin
        if PrintCartonMethod = 'CodeSoft' then
        begin
          sPrintData := G_getPrintData(CodesoftVersion, 2, G_sockConnection, 'DspQryData', editCarton.Text, PrintCartonLabQty, '', g_tsParam, g_tsData);
          G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil);
        end
        else if PrintCartonMethod = 'DLL' then
        begin
          CallDllPrint(2);
        end;
      end;
      ShowMsg('Close Carton [' + CartonNo + '] !', '');
      LabPalletQty.Caption := InttoStr(StrToIntDef(LabPalletQty.Caption, 0) + 1);

      //2007/6/11加入確認畫面提示
      if gbShowCloseMsg then
      begin
        with TfConfirm.Create(Self) do
        begin
          LabMsg.Caption:='Carton Closed!'+#13#10+'[' + CartonNo + ']';
          if ShowModal=mrOK then
          begin
            Close;
            free;
          end;
        end;
      end;
    end
    else
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'CARTON_NO', ptInput);
      CommandText := 'delete from SAJET.G_PACK_CARTON ' +
        'WHERE CARTON_NO = :CARTON_NO ';
      Params.ParamByName('CARTON_NO').AsString := CartonNo;
      Execute;
      ShowMsg('Delete Carton [' + CartonNo + '] !', '');
    end;
    Close;
  end;
  CartonNo := '';
  editCarton.Text := '';
  LabCartonQty.Caption := '0';
  if (Sender is TForm) or ((Sender is TSpeedButton) and ((Sender as TSpeedButton).Name <> 'sbtnClosePallet')) then
 // if (Sender as TSpeedButton).Name <> 'sbtnClosePallet' then
  begin
    if not (packAction in [1, 3, 6, 8]) and (StrToIntDef(LabPalletCap.Caption, 0) <= StrToIntDef(LabPalletQty.Caption, 0)) then
    begin
      sbtnClosePalletClick(self);
    end
    else
    begin
      bCreate := True;
      if (gbCycle) and (packAction in [1, 3, 6, 8]) then begin
       // GetPack(sPKSpec, 'Y');  //limit by key 2007/10/05  不適應多個包規同時多線包裝
        UpdatePackTerminal;
        if GetUnfinishCarton then
        begin
          GetPackCartonQty;
          if LabBoxCap.Caption <> '0' then
          begin
            if PackAction in [6, 8] then // 用Box裝Carton
              SetEditStatus('BOX')
            else if GetUnfinishBox then
            begin
              GetPackBoxQty;
              SetEditStatus('SN');
            end
            else
            begin
              CreateBox;
            end;
          end
          else
            SetEditStatus('SN');
          bCreate := False;
        end;
      end;
      if bCreate then begin
        if AutoCreateCarton then
        begin
          if GetCarton then
          begin
            if packAction in [6..8] then
              SetEditStatus('BOX')
            else
              CreateBox;
          end
          else
          begin
            SetEditStatus('CARTON');
          end;
        end
        else
        begin
          SetEditStatus('CARTON');
        end;
      end;
    end;
  end;
end;

procedure TfPacking.sbtnClosePalletClick(Sender: TObject);
var sPrintData: string; g_tsParam, g_tsData: TStrings; bCreate: Boolean;
begin
  if editPallet.Text = '' then Exit;

  if not AutoClose then
    if MessageDlg('Close This Pallet ??', mtCustom, mbOKCancel, 0) <> mrOK then Exit;

  //Check Privilege.if no Change User
  if ((Sender is TSpeedButton) and ((Sender as TSpeedButton).Name = 'sbtnClosePallet')) then
  begin
    if G_iClosePrivilege < 1 then
       if not checkChangeUserClosePrivilege then Exit;
  end;

  //若Carton中無序號,不需Close Carton
  if not (packAction in [2, 4]) then
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'CARTON', PtInput);
      CommandText := 'Select NVL(COUNT(*) ,0) "COUNT" FROM SAJET.G_SN_STATUS '
        + 'WHERE CARTON_NO = :CARTON ';
      Params.ParamByName('CARTON').AsString := editCarton.Text;
      Open;
      if FieldByNAme('COUNT').AsInteger <> 0 then
        sbtnCloseCartonClick(sbtnClosePallet);
      Close;
    end;

  if LabPalletQty.Caption = '0' then
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PALLET_NO', ptInput);
      CommandText := 'delete from SAJET.G_PACK_PALLET ' +
        'WHERE PALLET_NO = :PALLET_NO ';
      Params.ParamByName('PALLET_NO').AsString := PalletNo;
      Execute;
      Close;
    end;
    ShowMsg('Delete Pallet [' + PalletNo + '] !', '');
  end
  else
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PALLET_NO', ptInput);
      CommandText := 'UPDATE SAJET.G_PACK_PALLET ' +
        'SET CLOSE_FLAG = ''Y'' ' +
        'WHERE PALLET_NO = :PALLET_NO ';
      Params.ParamByName('PALLET_NO').AsString := PalletNo;
      Execute;

      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PACK_NO', ptInput);
      Params.CreateParam(ftString, 'PACK_TYPE', ptInput);
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      CommandText := 'INSERT INTO SAJET.G_PACK_FORCECLOSE ' +
        '(PACK_NO, PACK_TYPE, EMP_ID) ' +
        'VALUES (:PACK_NO, :PACK_TYPE, :EMP_ID)';
      Params.ParamByName('PACK_NO').AsString := PalletNo;
      Params.ParamByName('PACK_TYPE').AsString := 'Pallet';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Execute;
    end;

    if PrintPalletLabel then
    begin
      if PrintPalletMethod = 'CodeSoft' then
      begin
        sPrintData := G_getPrintData(CodesoftVersion, 1, G_sockConnection, 'DspQryData', editPallet.Text, PrintPalletLabQty, '', g_tsParam, g_tsData);
        G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil);
      end
      else if PrintPalletMethod = 'DLL' then
      begin
        CallDllPrint(1);
      end;
    end;
    ShowMsg('Close Pallet [' + PalletNo + '] !', '');

    //2007/6/11加入確認畫面提示
    if gbShowCloseMsg then
    begin
      with TfConfirm.Create(Self) do
      begin
        LabMsg.Caption:='Pallet Closed!'+#13#10+'[' + PalletNo + ']';
        if ShowModal=mrOK then
        begin
          Close;
          free;
        end;
      end;
    end;
  end;
 
  PalletNo := '';
  editPallet.Text := '';
  LabPalletQty.Caption := '0';
  bCreate := True;
  if gbCycle then begin
    //GetPack(sPKSpec, 'Y');  //limit by key 2007/10/05  不適應多個包規同時多線包裝
    UpdatePackTerminal;
    if GetUnfinishPallet then
    begin
      GetPackPalletQty;
      //有未滿的箱
      if GetUnfinishCarton then
      begin
        GetPackCartonQty;
        if LabBoxCap.Caption <> '0' then
        begin
          if PackAction = 7 then // 用Box裝Carton
            SetEditStatus('BOX')
          else if GetUnfinishBox then
          begin
            GetPackBoxQty;
            SetEditStatus('SN');
          end
          else
            CreateBox;
        end
        else
          SetEditStatus('SN');
      end
      else
      begin //無未滿的箱
        if AutoCreateCarton then
        begin
          if GetCarton then
          begin
            if PackAction = 7 then // 用Box裝Carton
              SetEditStatus('BOX')
            else if LabBoxCap.Caption <> '0' then
            begin
              if GetUnfinishBox then
              begin
                GetPackBoxQty;
                SetEditStatus('SN');
              end
              else
                CreateBox;
            end
            else
              SetEditStatus('SN');
          end
          else
          begin
            SetEditStatus('CARTON');
          end;
        end
        else
        begin
          SetEditStatus('CARTON');
        end;
      end;
      bCreate := False;
    end;
  end;
  if bCreate then begin
    if AutoCreatePallet then
    begin
      if GetPallet then
      begin
        if packAction in [2, 4] then
        begin
          SetEditStatus('CARTON');
        end
        else
        begin
          if AutoCreateCarton then
          begin
            if GetCarton then
            begin
              if packAction in [7, 8] then
                SetEditStatus('BOX')
              else
                CreateBox;
            end
            else
            begin
              SetEditStatus('CARTON');
            end;
          end
          else
          begin
            SetEditStatus('CARTON');
          end;
        end;
      end
      else
      begin
        SetEditStatus('PALLET');
      end;
    end
    else
    begin
      SetEditStatus('PALLET');
    end;
  end;
end;

procedure TfPacking.sbtnChangeSpecClick(Sender: TObject);
var Key: Char;
begin
  if editMO.Text = '' then Exit;
  if editMO.Enabled then Exit;

  formPackSpec := TformPackSpec.Create(Self);
  formPackSpec.lablWO.Caption := editMO.Text;
  formPackSpec.lablPart.Caption := LabPN.Caption;
  formPackSpec.combPackSpec.Clear;
  with QryTemp do
  begin
    //此工單定義之包裝方式
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    CommandText := 'SELECT a.PKSPEC_NAME, c.PALLET_QTY, c.CARTON_QTY, c.BOX_QTY ' +
      'FROM SAJET.G_PACK_SPEC A, SAJET.SYS_PKSPEC C ' +
      'WHERE WORK_ORDER = :WORK_ORDER ' +
      'AND A.PKSPEC_NAME = C.PKSPEC_NAME '+
      'Order By sequence ';
    Params.ParamByName('WORK_ORDER').AsString := editMO.Text;
    Open;
    while not Eof do
    begin
      formPackSpec.combPackSpec.Items.Add(FieldByName('PKSPEC_NAME').AsString);
      with formPackSpec.LvSort.Items.Add do
      begin
        Caption := FieldByName('PKSPEC_NAME').AsString;
        Subitems.Add(FieldByName('BOX_QTY').AsString);
        Subitems.Add(FieldByName('CARTON_QTY').AsString);
        Subitems.Add(FieldByName('PALLET_QTY').AsString);
      end;
      Next;
    end;

    //此料有定義的包裝方式
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PART_NO', ptInput);
    CommandText := 'SELECT B.PKSPEC_NAME, c.PALLET_QTY, c.CARTON_QTY, c.BOX_QTY ' +
      'FROM   SAJET.SYS_PART A, SAJET.SYS_PART_PKSPEC B, SAJET.SYS_PKSPEC C ' +
      'WHERE  A.PART_NO = :PART_NO ' +
      'AND    A.PART_ID = B.PART_ID ' +
      'AND    B.PKSPEC_NAME = C.PKSPEC_NAME ' +
      'AND    C.ENABLED=''Y'' '+
      'Order BY B.PKSPEC_NAME ';
    Params.ParamByName('PART_NO').AsString := LabPN.Caption;
    Open;
    while not Eof do
    begin
      if formPackSpec.combPackSpec.Items.IndexOf(FieldByName('PKSPEC_NAME').AsString) = -1 then
        with formPackSpec.LVData.Items.Add do
        begin
          Caption := FieldByName('PKSPEC_NAME').AsString;
          Subitems.Add(FieldByName('BOX_QTY').AsString);
          Subitems.Add(FieldByName('CARTON_QTY').AsString);
          Subitems.Add(FieldByName('PALLET_QTY').AsString);
        end;
      Next;
    end;
    Close;
  end;
  formPackSpec.combPackSpec.ItemIndex := formPackSpec.combPackSpec.Items.IndexOf(sPKSpec);
  if formPackSpec.ShowModal = mrOK then
  begin
    UpdatePackTerminal;
    GetCfgData;
    Key := #13;
    editMOKeyPress(Self, Key);
  end;
  formPackSpec.Free;
end;

procedure TfPacking.UpdatePackTerminal;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
    CommandText := 'select pkspec_name '
      + 'from sajet.G_PACK_SPEC_TERMINAL ';
    if PackingBase = 'Work Order' then
      CommandText := CommandText + 'WHERE  WORK_ORDER = :WORK_ORDER '
    else
      CommandText := CommandText + 'where model_id = :work_order ';
    CommandText := CommandText + 'AND    TERMINAL_ID = :TERMINAL_ID ';
    if PackingBase = 'Work Order' then
      Params.ParamByName('WORK_ORDER').AsString := mWO
    else
      Params.ParamByName('WORK_ORDER').AsString := mPartID;
    Params.ParamByName('TERMINAL_ID').AsString := TERMINALID;
    Open;
    if IsEmpty then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'model_id', ptInput);
      Params.CreateParam(ftString, 'terminal_id', ptInput);
      Params.CreateParam(ftString, 'create_emp_id', ptInput);
      Params.CreateParam(ftString, 'pkspec_name', ptInput);
      CommandText := 'insert into sajet.G_PACK_SPEC_TERMINAL '
        + '(work_order, model_id, terminal_id, create_emp_id, pkspec_name) '
        + 'values (:work_order, :model_id, :terminal_id, :create_emp_id, :pkspec_name) ';
      Params.ParamByName('WORK_ORDER').AsString := mWO;
      Params.ParamByName('model_id').AsString := mPartID;
      Params.ParamByName('terminal_id').AsString := TERMINALID;
      Params.ParamByName('create_emp_id').AsString := UpdateUserID;
      Params.ParamByName('pkspec_name').AsString := sPKSpec;
    end
    else
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'pkspec_name', ptInput);
      Params.CreateParam(ftString, 'update_userid', ptInput);
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
      CommandText := 'update sajet.G_PACK_SPEC_TERMINAL '
        + 'set pkspec_name = :pkspec_name, create_emp_id = :update_userid ';
      if PackingBase = 'Work Order' then
        CommandText := CommandText + 'WHERE  WORK_ORDER = :WORK_ORDER '
      else
        CommandText := CommandText + 'where model_id = :work_order ';
      CommandText := CommandText + 'AND    TERMINAL_ID = :TERMINAL_ID ';
      Params.ParamByName('pkspec_name').AsString := sPKSpec;
      Params.ParamByName('update_userid').AsString := UpdateUserID;
      if PackingBase = 'Work Order' then
        Params.ParamByName('WORK_ORDER').AsString := mWO
      else
        Params.ParamByName('WORK_ORDER').AsString := mPartID;
      Params.ParamByName('terminal_id').AsString := TERMINALID;
    end;
    Execute;
    Close;
  end;
end;

procedure TfPacking.GetLastPackSpec;
var sPackSpec: string;
begin
  //找此工單最後一次的包裝方式
  with QryTemp do
  begin
{    if gbCycle then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
      CommandText := 'SELECT PKSPEC_NAME, CLOSE_FLAG ';
      if editPallet.Visible then
        CommandText := CommandText + 'FROM SAJET.G_PACK_PALLET '
      else if editCarton.Visible then
        CommandText := CommandText + 'FROM SAJET.G_PACK_Carton '
      else if editBox.Visible then
        CommandText := CommandText + 'FROM SAJET.G_PACK_Box ';
      if PackingBase = 'Work Order' then
        CommandText := CommandText + 'WHERE  WORK_ORDER = :WORK_ORDER '
      else
        CommandText := CommandText + 'where model_id = :work_order ';
      CommandText := CommandText + 'AND TERMINAL_ID = :TERMINAL_ID ' + //2005/03/01
        'Order By Create_Time desc ';
      if PackingBase = 'Work Order' then
        Params.ParamByName('WORK_ORDER').AsString := mWO
      else
        Params.ParamByName('WORK_ORDER').AsString := mPartID;
      Params.ParamByName('TERMINAL_ID').AsString := TERMINALID;
      Open;
      if not IsEmpty then
        GetPack(Fieldbyname('PKSPEC_NAME').AsString, FieldByName('Close_Flag').AsString)
      else
        GetPack('', 'N');
    end
    else
    begin }
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
    CommandText := 'SELECT PKSPEC_NAME ' +
      'FROM   SAJET.G_PACK_SPEC_TERMINAL ';
    if PackingBase = 'Work Order' then
      CommandText := CommandText + 'WHERE  WORK_ORDER = :WORK_ORDER '
    else
      CommandText := CommandText + 'where model_id = :work_order ';
    CommandText := CommandText + 'AND TERMINAL_ID = :TERMINAL_ID and rownum = 1'; // rownum 2006.11.13 add
    if PackingBase = 'Work Order' then
      Params.ParamByName('WORK_ORDER').AsString := mWO
    else
      Params.ParamByName('WORK_ORDER').AsString := mPartID;
    Params.ParamByName('TERMINAL_ID').AsString := TERMINALID;
    Open;
    if not IsEmpty then
    begin
      sPackSpec := Fieldbyname('PKSPEC_NAME').AsString;
      GetPack(sPackSpec, '');
    end
    else
    begin
      GetPack('', 'N');  
    end;
    UpdatePackTerminal;
    Close;
  end;
end;

procedure TfPacking.GetPack(sSpecName, sClosePallet: string);
var i, iIndex: integer;
begin
  iIndex := LvData.Items.IndexOf(LvData.FindCaption(0, sSpecName, True, True, True));
    //若pallet已滿,此次就用下個包裝方式
  if gbCycle then
    if sClosePallet = 'Y' then
      iIndex := iIndex + 1;

  if (iIndex = -1) or (iIndex > LvData.Items.Count - 1) then
    iIndex := 0;

  sPKSpec := LvData.Items.Item[iIndex].Caption;
  LabBoxCap.Caption := LvData.Items.Item[iIndex].SubItems[0];
  LabCartonCap.Caption := LvData.Items.Item[iIndex].SubItems[1];
  LabPalletCap.Caption := LvData.Items.Item[iIndex].SubItems[2];

  for i := 0 to LVData.items.Count - 1 do
    LVData.Items[i].ImageIndex := -1;
  LVData.Items[iIndex].ImageIndex := 0;
  if not (packAction in [2, 4]) then
  begin
    LabBoxInfo.Visible := not (LabBoxCap.Caption = '0');
    editBox.Visible := LabBoxInfo.Visible;
    if not (packAction in [6..8]) then
    begin
      sbtnCloseBox.Visible := LabBoxInfo.Visible;
      Image2.Visible := LabBoxInfo.Visible;
      LabBoxCap.Visible := LabBoxInfo.Visible;
      LabBoxQty.Visible := LabBoxInfo.Visible;
      labBoxDiv.Visible := LabBoxInfo.Visible;
      LabBCap.Visible := LabBoxInfo.Visible;
    end;
    LabBox.Visible := LabBoxInfo.Visible;
    Bevel3.Visible := LabBoxInfo.Visible;
  end;
end;

function TfPacking.CallDllPrint(iType: integer): Boolean;
var g_tsParam, g_tsData: TStrings;
begin
  try
    Result := False;
    g_tsParam := TStringList.create;
    g_tsData := TStringList.create;
    case iType of
      1:
        begin
          G_getPrintData(-1, 1, G_sockConnection, 'DspQryData', editPallet.Text, 0, '', g_tsParam, g_tsData);
          if not SendData(iType, PrintPalletLabQty, g_tsParam, g_tsData, mPalletComPort, mPalletBaudRate, G_sockConnection) then exit;
        end;
      2:
        begin
          G_getPrintData(-1, 2, G_sockConnection, 'DspQryData', editCarton.Text, 0, '', g_tsParam, g_tsData);
          if not SendData(iType, PrintCartonLabQty, g_tsParam, g_tsData, mCartonComPort, mCartonBaudRate, G_sockConnection) then exit;
        end;
      3:
        begin
          G_getPrintData(-1, 3, G_sockConnection, 'DspQryData', SNNO, 0, '', g_tsParam, g_tsData);
          if not SendData(iType, PrintCSNLabQty, g_tsParam, g_tsData, mCSNComPort, mCSNBaudRate, G_sockConnection) then exit;
        end;
      4:
        begin
          G_getPrintData(-1, 16, G_sockConnection, 'DspQryData', editBox.Text, 0, '', g_tsParam, g_tsData);
          if not SendData(iType, PrintBoxLabQty, g_tsParam, g_tsData, mBoxComPort, mBoxBaudRate, G_sockConnection) then exit;
        end;
    end;
    Result := True;
  finally
  end;
end;

procedure TfPacking.sbtnPalletIniClick(Sender: TObject);
begin
  ShowMsg('Initial now !  Please Wait...', '');
  if not PrintInitial(1, mPalletComPort, mPalletBaudRate, LabPN.Caption, editMO.Text, mCustPartNo, mLabelFile) then
    ShowMsg('Initial Fail', '')
  else
    ShowMsg('Initial OK', '');
end;

procedure TfPacking.sbtnCartonIniClick(Sender: TObject);
begin
  ShowMsg('Initial now !  Please Wait...', '');
  if not PrintInitial(2, mCartonComPort, mCartonBaudRate, LabPN.Caption, editMO.Text, mCustPartNo, mLabelFile) then
    ShowMsg('Initial Fail', '')
  else
    ShowMsg('Initial OK', '');
end;

procedure TfPacking.sbtnCustiniClick(Sender: TObject);
begin
  ShowMsg('Initial now !  Please Wait...', '');
  if not PrintInitial(3, mCSNComPort, mCSNBaudRate, LabPN.Caption, editMO.Text, mCustPartNo, mLabelFile) then
    ShowMsg('Initial Fail', '')
  else
    ShowMsg('Initial OK', '');
end;

procedure TfPacking.PackGo(sValue, sType: string);
var dtSysdate: TDateTime;
  sRes: string;
begin
  if chkWeight.Checked then
    if not CheckWeight then Exit;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT SYSDATE FROM DUAL ';
    OPEN;
    dtSysdate := FieldByName('SYSDATE').AsDateTime;
  end;
  // 過站紀錄
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_REPACKING_GO');
      FetchParams;
      Params.ParamByName('TTERMINALID').AsString := TerminalID;
      Params.ParamByName('TNOW').AsDateTime := dtSysdate;
      Params.ParamByName('TEMP').AsString := UpdateUserNo;
      Params.ParamByName('PACKACTION').AsString := sType;
      Params.ParamByName('PACKVALUE').AsString := sValue;
      Execute;
      sRes := Params.ParamByName('TRES').AsString;
    except
      on E: Exception do
      begin
        sRes := 'Call SJ_REPACKING_GO Exception-' + E.Message;
      end;
    end;
    Close;
  end;

  if sRes <> 'OK' then
  begin
    ShowMsg(sRes, 'ERROR');
    exit;
  end;
end;

function TfPacking.CheckWeight: Boolean;
  function getUCLLCL(var fUL, fLL: Real): Boolean;
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'part_id', ptInput);
      CommandText := 'select weight, error from sajet.sys_part_weight '
        + 'where Part_Id = :Part_Id and enabled=''Y''  ';
      Params.ParamByName('Part_Id').AsString := mPartID;
      Open;
      if IsEmpty then
      begin
        Result := False;
        fUL := 0;
        fLL := 0;
      end
      else
      begin
        fUL := FieldByName('weight').AsFloat + FieldByName('error').AsFloat;
        fLL := FieldByName('weight').AsFloat - FieldByName('error').AsFloat;
        Result := True;
      end;
      close;
    end;
  end;
  function CheckWeight(var fWeight: Real): Boolean;
  begin
    gsWeightFail := False;
    if chkWeight.Checked then
    begin
      panlMessage.Caption := '';
      if edtWeight.Text = '' then
      begin
        panlMessage.Caption := 'Waiting for Weight!';
        gsWeightFail := True;
      end
      else
      begin
        try
          fWeight := StrToFloat(edtWeight.Text);
        except
          panlMessage.Caption := 'Invalid Weight.';
          gsWeightFail := True;
        end;
      end;
    end;
    Result := not gsWeightFail;
  end;
  procedure InsertWeight(fWeight: Real);
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'serial_number', ptInput);
      CommandText := 'select serial_number from sajet.g_sn_weight '
        + 'where serial_number = :serial_number and rownum = 1';
      if packAction in [2, 4] then
        Params.ParamByName('serial_number').AsString := CartonNo
      else if packAction in [6,7,8] then
          Params.ParamByName('serial_number').AsString := gsbox
      else
        Params.ParamByName('serial_number').AsString := SNNO;
      Open;
      if IsEmpty then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'work_order', ptInput);
        Params.CreateParam(ftString, 'serial_number', ptInput);
        Params.CreateParam(ftString, 'weight', ptInput);
        Params.CreateParam(ftString, 'update_userid', ptInput);
        CommandText := 'insert into sajet.g_sn_weight '
          + '(work_order, serial_number, weight, update_userid) '
          + 'values (:work_order,:serial_number, :weight, :update_userid)';
        Params.ParamByName('work_order').AsString := gSNWo;
        if packAction in [2, 4] then
          Params.ParamByName('serial_number').AsString := CartonNo
        else if packAction in [6,7,8] then
          Params.ParamByName('serial_number').AsString := gsbox
        else
          Params.ParamByName('serial_number').AsString := SNNO;
        Params.ParamByName('weight').AsFloat := fWeight;
        Params.ParamByName('update_userid').AsString := UpdateUserID;
        Execute;
      end
      else
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'work_order', ptInput);
        Params.CreateParam(ftString, 'weight', ptInput);
        Params.CreateParam(ftString, 'update_userid', ptInput);
        Params.CreateParam(ftString, 'serial_number', ptInput);
        CommandText := 'update sajet.g_sn_weight '
          + 'set work_order = :work_order, weight = :weight, update_userid=:update_userid, update_time = sysdate '
          + 'where serial_number=:serial_number and rownum = 1';
        Params.ParamByName('work_order').AsString := gSNWo;
        Params.ParamByName('weight').AsFloat := fWeight;
        Params.ParamByName('update_userid').AsString := UpdateUserID;
        if packAction in [2, 4] then
          Params.ParamByName('serial_number').AsString := CartonNo
        else if packAction in [6,7,8] then
          Params.ParamByName('serial_number').AsString := gsbox
        else
          Params.ParamByName('serial_number').AsString := SNNO;
        Execute;
      end;
      Close;
    end;
  end;
var fUL, fLL, fWeight: Real;
begin
  Result := False;
  if not CheckWeight(fWeight) then
  begin
    if PackAction in [2, 4] then
      editCarton.Enabled := False
    else if packAction in [6,7,8] then
      editbox.Enabled :=false
    else if (AutoCreateCSN) or (NotChangeCSN) then //or (CSNeqSN) then
      editSN.Enabled := False
    else
      editCSN.Enabled := False;
    Exit;
  end;
  getUCLLCL(fUL, fLL);
  if (fWeight >= fLL) and (fWeight <= fUL) then
  begin
    InsertWeight(fWeight);
  end
  else
  begin
    ShowMsg('    Weight Error!' + #10#10
      + 'Standard: ' + FloatToStr(fLL) + ' ~ ' + FloatToStr(fUL) + #10#10
      + 'Weight:   ' + FloatToStr(fWeight), 'ERROR');
    if PackAction in [2, 4] then
      SetEditStatus('CARTON')
    else if packAction in [6,7,8] then
      SetEditStatus('BOX')
    else
      SetEditStatus('SN');
    Exit;
  end;
  Result := True;
end;

procedure TfPacking.ShowMsg(sMsg, sType: string);
begin
  if sType = 'ERROR' then
  begin
    if bNoPopUp then
    begin
      PanlMessage.Caption := sMsg;
      panlMessage.Color := clSilver;
      panlMessage.Font.Color := clRed;
      panlMessage.Repaint;
      messageBeep(48);
    end
    else
    begin
      PanlMessage.Caption := '';
      panlMessage.Color := clWhite;
      panlMessage.Font.Color := clGreen;
      panlMessage.Repaint;
      messageBeep(48);
      MessageDlg(sMsg, mtError, [mbOK], 0);
    end;
  end
  else
  begin
    PanlMessage.Caption := sMsg;
    panlMessage.Color := clWhite;
    panlMessage.Font.Color := clGreen;
    panlMessage.Repaint;
  end;
end;

procedure TfPacking.editBoxKeyPress(Sender: TObject; var Key: Char);
var sType: string;
begin
  if Key = #13 then
  begin
    // ADD BY KEY 2009/04/01
    IF NOT checkpdlinestatus(TerminalID) THEN EXIT ;
    // ADD END
    Key := #0;
    if PackAction in [6..8] then
    begin
      if not CheckBox(sType) then
      begin
        SetEditStatus('BOX');
        Exit;
      end;
     { if chkWeight.Checked then
      begin
        ImageNG.Visible := True;
        edtWeight.Text := FloatToStr(CheckWeightData);
        edtWeight2.Text := edtWeight.Text;
        if (edtWeight.Text = '0') or (edtWeight.Text = '') then
        begin
          edtWeight2.Text := '';
          SetEditStatus('BOX');
          Exit;
        end;
      end;
      }
      //若刷SN且原本已有Pallet and Carton,保留此號並過站 -2005/8/19
      if sType = 'SN' then
      begin
        if (gsCarton <> 'N/A') and (gsPallet <> 'N/A') and (gsCarton <> gsPallet) then
        begin
          panlMessage.Color := clMaroon;
          panlMessage.Font.Color := clYellow;
          panlMessage.Caption := 'SN OK !' + #13#10
            + 'Pallet No : ' + gsPallet + #13#10
            + 'Carton No : ' + gsCarton + #13#10
            + 'Box No : ' + gsBox;
          PackGo(SNNO, sType);
          SetEditStatus('BOX');
          Exit;
        end
        else
        begin
          ShowMsg('Please input Box No!!', 'ERROR');
          SetEditStatus('BOX');
          Exit;
        end;
      end
      else if (sType = 'BOX') and (gsCarton <> 'N/A') and (gsPallet <> 'N/A') and (gsCarton <> gsPallet) then
      begin
        panlMessage.Color := clMaroon;
        panlMessage.Font.Color := clYellow;
        panlMessage.Caption := 'BOX OK !' + #13#10
          + 'Pallet No : ' + gsPallet + #13#10
          + 'Carton No : ' + gsCarton;
        PackGo(gsBox, sType);
        SetEditStatus('BOX');
        Exit;
      end;

      if not RefreshCartonQty(CartonNo) then exit; //2007/7/5

      if LabCartonQty.Caption <> '' then
      begin
        if StrToIntDef(LabCartonCap.Caption, 0) <= StrToIntDef(LabCartonQty.Caption, 0) then
        begin
          ShowMsg('Please Close Carton !!', 'ERROR');
          SetEditStatus('BOX');
          Exit;
        end;
      end;

      if not InputSN then
      begin
        SetEditStatus('BOX');
        exit;
      end;

      LabCartonQty.Caption := InttoStr(StrToIntDef(LabCartonQty.Caption, 0) + 1);

      if StrToIntDef(LabCartonCap.Caption, 0) <= StrToIntDef(LabCartonQty.Caption, 0) then
        sbtnCloseCartonClick(self)
      else
        SetEditStatus('BOX');
    end
    else
    begin
      if (CheckBoxeqSN) and (LabBoxCap.Caption = '1') then // 2007.08.29 新增檢查 Cap = 1才需檢查
      begin
        if editBox.Text <> editCSN.Text then // 2007.05.23 editSN.Text改為editCSN.Text
        begin
          ShowMsg('Box No <> Customer SN!', 'ERROR');
          SetEditStatus('BOX');
          Exit;
        end;
        BoxNo := editCSN.Text; // 2007.05.23 editSN.Text改為editCSN.Text
        if not InputSN then
        begin
          SetEditStatus('SN');
          exit;
        end;
        ShowMsg('BOX OK!', '');
        if StrToIntDef(LabBoxCap.Caption, 0) <= StrToIntDef(LabBoxQty.Caption, 0) then
          sbtnCloseBoxClick(self)
        else
          SetEditStatus('SN');
      end
      else
      begin
        if trim(editBox.Text) = '' then
        begin
          ShowMsg('Please Input Box No!', 'ERROR');
          SetEditStatus('BOX');
          exit;
        end;
        if not CheckRule('Box', editBox.Text) then
        begin
          SetEditStatus('BOX');
          exit;
        end;
        //2005/9/5==
        if not CheckDupBox then
        begin
          SetEditStatus('BOX');
          exit;
        end
        else
        begin
          SetEditStatus('SN');
        end;
        ShowMsg('Box No OK !', '');
      end;
    end;
  end;
end;

procedure TfPacking.sbtnCloseBoxClick(Sender: TObject);
var sPrintData: string; g_tsParam, g_tsData: TStrings; bCreate: Boolean;
begin
  if (editBox.Visible) and (editBox.Text = '') then Exit;
  if (not AutoClose) and (editBox.Visible) then
  begin
    if (Sender is TForm) or ((Sender is TSpeedButton) and ((Sender as TSpeedButton).Name = 'sbtnCloseBox')) then
    begin
      if MessageDlg('Close This Box ??', mtCustom, mbOKCancel, 0) <> mrOK then Exit;
    end;
  end;  

  //Check Privilege.if no Change User
  if ((Sender is TSpeedButton) and ((Sender as TSpeedButton).Name = 'sbtnCloseBox')) then
  begin
    if G_iClosePrivilege < 1 then
       if not checkChangeUserClosePrivilege then Exit;
  end;

  if (LabBoxQty.Caption = '0') then
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'Box_NO', ptInput);
      CommandText := 'delete from SAJET.G_PACK_Box ' +
        'WHERE Box_NO = :Box_NO ';
      Params.ParamByName('Box_NO').AsString := BoxNo;
      Execute;
      Close;
    end;
    ShowMsg('Delete Box [' + BoxNo + '] !', '');
  end
  else if not editBox.Visible then
    LabCartonQty.Caption := InttoStr(StrToIntDef(LabCartonQty.Caption, 0) + 1)
  else
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'Box_NO', ptInput);
      CommandText := 'UPDATE SAJET.G_PACK_Box ' +
        'SET CLOSE_FLAG = ''Y'' ' +
        'WHERE Box_NO = :Box_NO ';
      Params.ParamByName('Box_NO').AsString := BoxNo;
      Execute;

      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PACK_NO', ptInput);
      Params.CreateParam(ftString, 'PACK_TYPE', ptInput);
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      CommandText := 'INSERT INTO SAJET.G_PACK_FORCECLOSE ' +
        '(PACK_NO, PACK_TYPE, EMP_ID) ' +
        'VALUES (:PACK_NO, :PACK_TYPE, :EMP_ID)';
      Params.ParamByName('PACK_NO').AsString := BoxNo;
      Params.ParamByName('PACK_TYPE').AsString := 'Box';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Execute;
    end;

    if PrintBoxLabel then
    begin
      if PrintBoxMethod = 'CodeSoft' then
      begin
        sPrintData := G_getPrintData(CodesoftVersion, 16, G_sockConnection, 'DspQryData', editBox.Text, PrintBoxLabQty, '', g_tsParam, g_tsData);
        G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil);
      end
      else if PrintBoxMethod = 'DLL' then
      begin
        CallDllPrint(4);
      end;
    end;
    if editBox.Visible then
    begin
      ShowMsg('Close Box [' + BoxNo + '] !', '');

      //2007/6/11加入確認畫面提示
      if gbShowCloseMsg then
      begin
        with TfConfirm.Create(Self) do
        begin
          LabMsg.Caption:='Box Closed!'+#13#10+'[' + BoxNo + ']';
          if ShowModal=mrOK then
          begin
            Close;
            free;
          end;
        end;
      end;
    end;
    LabCartonQty.Caption := InttoStr(StrToIntDef(LabCartonQty.Caption, 0) + 1);
  end;
  BoxNo := '';
  editBox.Text := '';
  LabBoxQty.Caption := '0';
  if (Sender is TForm) or ((Sender is TSpeedButton) and ((Sender as TSpeedButton).Name <> 'sbtnCloseCarton')) then
  begin
    if not (packAction in [5]) and (StrToIntDef(LabCartonCap.Caption, 0) <= StrToIntDef(LabCartonQty.Caption, 0)) then
    begin
      sbtnCloseCartonClick(self);
    end
    else
    begin
      bCreate := True;
      if (gbCycle) and (packAction = 5) then begin
      //  GetPack(sPKSpec, 'Y');  //limit by key 2007/10/05  不適應多個包規同時多線包裝
        UpdatePackTerminal;
        if GetUnfinishBox then
        begin
          GetPackBoxQty;
          SetEditStatus('SN');
          bCreate := False;
        end;
      end;
      if bCreate then
        CreateBox;
    end;
  end;
end;

procedure TfPacking.sbtnBoxIniClick(Sender: TObject);
begin
  ShowMsg('Initial now !  Please Wait...', '');
  if not PrintInitial(4, mBoxComPort, mBoxBaudRate, LabPN.Caption, editMO.Text, mCustPartNo, mLabelFile) then
    ShowMsg('Initial Fail', '')
  else
    ShowMsg('Initial OK', '');
end;

procedure TfPacking.FormDestroy(Sender: TObject);
begin
  FreeLibrary(m_DLLHandle);
  if g_bAdditional then
    FreeLibrary(m_DLLHandle1);
  if g_bPackAssy then
    FreeLibrary(m_DLLHandle2);

  SNUdf.Free;
  CarryM.Free;
  CarryD.Free;
  CarryW.Free;
  CarryK.Free;

  if g_bAdditional then
  begin
    g_tsAddParam.Free;
    g_tsAddData.Free;
  end;

  if g_bPackAssy then
  begin
    g_tsAssyParam.Free;
    g_tsAssyData.Free;
  end;
end;

function TfPacking.CallAdditionalDll:Boolean;
begin
  g_tsAddParam.Clear;
  g_tsAddData.Clear;

  g_tsAddParam.Add('SERIAL_NUMBER');
  g_tsAddData.Add(listSN.items.strings[0]);
  g_tsAddParam.Add('CUSTOMER_SN');
  g_tsAddData.Add(CSNNo);
  g_tsAddParam.Add('BOX_NO');
  if LabBoxCap.Caption = '0' then
    g_tsAddData.Add('N/A')
  else
    g_tsAddData.Add(BoxNo);
  g_tsAddParam.Add('CARTON_NO');
  g_tsAddData.Add(CartonNo);
  g_tsAddParam.Add('PALLET_NO');
  g_tsAddData.Add(PalletNo);

  g_tsAddParam.Add('EMP_NO');
  g_tsAddData.Add(UpdateUserNo);
  g_tsAddParam.Add('LINE_ID');
  g_tsAddData.Add(G_sLineID);
  g_tsAddParam.Add('STAGE_ID');
  g_tsAddData.Add(G_sStageID);
  g_tsAddParam.Add('PROCESS_ID');
  g_tsAddData.Add(G_sProcessID);
  g_tsAddParam.Add('TERMINAL_ID');
  g_tsAddData.Add(TerminalID);
  
  Result:=AdditionalData(g_tsAddParam,g_tsAddData,G_sockConnection);
end;
function TfPacking.CheckDefect(psDefectCode:String): Boolean;
begin
  Result := False;
  with QryTemp do
  begin
    try
      Close;

      Params.Clear;
      Params.CreateParam(ftString, 'NO', ptInput);
      CommandText := 'Select DEFECT_CODE,DEFECT_ID,DEFECT_LEVEL,DEFECT_DESC, ' +
                     '       DECODE(DEFECT_LEVEL,''0'',''CRITICAL'',''1'',''MAJOR'',''2'',''MINOR'') "LEVEL" '+
                     'From SAJET.SYS_DEFECT ' +
                     'Where DEFECT_CODE = :NO and ' +
                     'ENABLED = ''Y'' ';
      Params.ParamByName('NO').AsString := psDefectCode;//editSN.Text;
      Open;
      if RecordCount > 0 then
      begin
         if lvEc.findCaption(0,psDefectCode,False,True,False) = nil then
         begin
            with lvEC.Items.Add do
            begin
               Caption := FieldByName('Defect_Code').AsString;
               SubItems.Add(FieldByName('LEVEL').AsString);
               SubItems.Add(FieldByName('Defect_Desc').AsString);
               SubItems.Add(FieldByName('Defect_ID').AsString);
               SubItems.Add(FieldByName('Defect_Level').AsString);
            end;
            ShowMsg('Defect Code : '+ editSN.Text+' OK', '');
            lablErrorCode.Caption:=lablErrorCode.Caption+editSN.Text+';';
         end
         else
         begin
            ShowMsg('Defect Code Duplicate !!', 'ERROR');
         end;
         Result := True;
      end;
    finally
      Close;
    end;
  end;
end;

procedure TfPacking.sbtnWoFilterClick(Sender: TObject);
var sKey:char;
begin
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'WORK_ORDER', ptInput);
    CommandText := 'Select WORK_ORDER '+
                   'From SAJET.G_WO_BASE '+
                   'Where WORK_ORDER Like :WORK_ORDER '+
                   'and WO_STATUS in (''2'',''3'') '+
                   'Order By WORK_ORDER';
    Params.ParamByName('WORK_ORDER').AsString := Trim(editMO.Text) + '%' ;
    Open;
  end;

  With TfPFilter.Create(Self) do
  begin
    editMO.Text := Trim(editMO.Text);
    dsrcFilter.DataSet:= fPacking.QryTemp;

    If Showmodal = mrOK then begin
      editMO.Text := QryTemp.Fieldbyname('WORK_ORDER').AsString;
      sKey:=#13;
      editMO.OnKeyPress(self,sKey);
    end;
    Free;
  end;
  QryTemp.Close;
end;

procedure TfPacking.LoadAssyDll(f_sDllName: string);
begin
  g_bLoadAssy := False;
  try
    f_sDllName := uppercase(f_sDllName);
    m_DLLHandle2 := LoadLibrary(pchar(ExtractFilePath(Application.exename) + f_sDLLName));
    if m_DLLHandle2 <= 32 then raise Exception.create('Can Not Find DLL File(' + f_sDllName + ')');

    AssyData := GetProcAddress(m_DLLHandle2, 'AssyData');
    if (@AssyData = nil) then raise Exception.Create('DLL Function Not Match (1)');
    g_bLoadAssy := True;
  except
    on E: Exception do
    begin
      raise Exception.create('(' + ClassName + '.LoadAssyDll)' + E.Message);
    end;
  end;
end;

function TfPacking.CallAssyDll:Boolean;
begin
  g_tsAssyParam.Clear;
  g_tsAssyData.Clear;

  g_tsAssyParam.Add('EMP_ID');
  g_tsAssyData.Add(UpdateUserID);
  g_tsAssyParam.Add('SERIAL_NUMBER');
  g_tsAssyData.Add(listSN.Items.Strings[0]);

  Result:=AssyData(g_tsAssyParam,g_tsAssyData,G_sockConnection);
end;

function TfPacking.RefreshBoxQty(sBox:string):boolean;
begin
  Result:=False;
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'BOX_NO', ptInput);
    CommandText := 'SELECT CLOSE_FLAG ' +
      'FROM SAJET.G_PACK_BOX ' +
      'WHERE BOX_NO = :BOX_NO ';
    Params.ParamByName('BOX_NO').AsString := sBox;
    Open;
    if FieldByName('CLOSE_FLAG').AsString='Y' then
    begin
      ShowMsg('Box had been Closed','ERROR');
      Exit;
    end;

    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'BOX_NO', ptInput);
    CommandText := 'Select COUNT(*) CNT '+   //CNT ADD BY KEY 2007/10/06
                   'From SAJET.G_SN_STATUS '+
                   'Where BOX_NO = :BOX_NO ';
    Params.ParamByName('BOX_NO').AsString := sBox ;
    Open;
    LabBoxQty.Caption := FieldByName('CNT').asstring;
  end;
  Result:=True;
end;

function TfPacking.RefreshCartonQty(sCarton:string):boolean;
begin
  Result:=False;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CARTON_NO', ptInput);
    CommandText := 'SELECT CLOSE_FLAG ' +
      'FROM SAJET.G_PACK_CARTON ' +
      'WHERE CARTON_NO = :CARTON_NO ';
    Params.ParamByName('CARTON_NO').AsString := sCarton;
    Open;
    if FieldByName('CLOSE_FLAG').AsString='Y' then
    begin
      ShowMsg('Carton had been Closed','ERROR');
      Exit;
    end;

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CARTON_NO', ptInput);
    if editBox.Visible then
    begin
      CommandText := 'SELECT A.BOX_NO, nvl(B.CLOSE_FLAG, ''Y'') close_flag ' +
        'FROM SAJET.G_SN_STATUS A ' +
        ',SAJET.G_PACK_BOX B ' +
        'WHERE CARTON_NO = :CARTON_NO ' +
        'AND A.BOX_NO = B.BOX_NO(+) ' +
        'GROUP BY A.BOX_NO, B.CLOSE_FLAG ';
      Params.ParamByName('CARTON_NO').AsString := sCarton;
      Open;
      LabCartonQty.Caption := '0';
      if not IsEmpty then
      begin
        while not Eof do
        begin
          if FieldByName('Close_Flag').AsString = 'Y' then
            LabCartonQty.Caption := InttoStr(StrToInt(LabCartonQty.Caption) + 1);
          Next;
        end;
      end;
    end
    else
    begin
      CommandText := 'SELECT COUNT(*) CNT ' +
                     'FROM SAJET.G_SN_STATUS ' +
                     'WHERE CARTON_NO = :CARTON_NO ';
      Params.ParamByName('CARTON_NO').AsString := sCarton;
      Open;
      LabCartonQty.Caption := FieldByName('CNT').asstring;
    end;
  end;
  Result:=True;
end;

function TfPacking.RefreshPalletQty(sPallet:string):boolean;
begin
  Result:=False;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PALLET_NO', ptInput);
    CommandText := 'SELECT CLOSE_FLAG ' +
      'FROM SAJET.G_PACK_PALLET ' +
      'WHERE PALLET_NO = :PALLET_NO ';
    Params.ParamByName('PALLET_NO').AsString := sPallet;
    Open;
    if FieldByName('CLOSE_FLAG').AsString='Y' then
    begin
      ShowMsg('PALLET had been Closed','ERROR');
      Exit;
    end;

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PALLET_NO', ptInput);
    CommandText := 'SELECT A.CARTON_NO ' +
      'FROM SAJET.G_SN_STATUS A,' +
      'SAJET.G_PACK_CARTON B ' +
      'WHERE A.PALLET_NO = :PALLET_NO AND ' +
      'A.CARTON_NO = B.CARTON_NO AND ' +
      'B.CLOSE_FLAG = ''Y'' ' +
      'GROUP BY A.CARTON_NO ';
    Params.ParamByName('PALLET_NO').AsString := sPallet;
    Open;
    LabPalletQty.Caption := InttoStr(RecordCount);
  end;
  Result:=True;
end;

end.


