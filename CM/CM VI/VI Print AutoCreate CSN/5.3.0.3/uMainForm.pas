unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles,Tlhelp32,ComObj;

type
  TfMainForm = class(TForm)
    sbtnClose: TSpeedButton;
    Image2: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SimpleObjectBroker1: TSimpleObjectBroker;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SocketConnection1: TSocketConnection;
    dsData: TDataSource;
    SaveDialog: TSaveDialog;
    QryTemp1: TClientDataSet;
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    editDefect: TEdit;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    Label2: TLabel;
    ImageAll: TImage;
    Label3: TLabel;
    editSN: TEdit;
    lstValue: TListBox;
    lstField: TListBox;
    procedure FormShow(Sender: TObject);
    procedure editDefectKeyPress(Sender: TObject; var Key: Char);
    procedure editSNKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
  private
    //m_SNDefectLevel: String;
    
    function GetTerminalName(sTerminalID:string):string;
   // procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);

   // function GetPartID(partno :String) :String;
   // procedure ShowData(sCarrier :String);
  public
    UpdateUserID,sPartID ,sPartNo,PrintFile: String;
    isStart,IsOpen:boolean;
    BarApp,BarDoc,BarVars:variant;
    SNUdf,CarryM,CarryD,CarryW,CarryK: TStringList;
    sPdline,sProcess,sProcessID,iTerminal,sTerminal:string;
    mCarry: string;
    mWo,mPartId,mPartNo,mCode,mCodeNo,mCodeDef,gsCheckSum,mDateCode,Carry16,mCartonNO:string;
   // Authoritys,AuthorityRole,FunctionName : String;
    sDefectID,sDefectCode:String;
    function  GetSysDate:TDatetime;
    function  GetEMPNO:string;
    function  GetNewNo(NoType: string; var NewNo: string): Boolean;
    function  PrintLabel(Part_no,sn,sResult:string;IColor:Integer):Boolean;
  end;

var
  fMainForm: TfMainForm;


implementation

uses uLogin;


{$R *.dfm}


function KillTask(ExeFileName: string): integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOLean;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
        OpenProcess(PROCESS_TERMINATE,
        BOOL(0),
        FProcessEntry32.th32ProcessID),
        0));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);


end;

procedure TfMainForm.FormDestroy(Sender: TObject);
begin
   if IsOpen then Bardoc.Close;
   if IsStart then BarApp.Quit;
   KillTask('lppa.exe');

end;

function  TfMainForm.GetSysDate:TDatetime;
begin
   with Qrytemp do
   begin
      Close;
      Params.Clear;
      commandText := 'select sysdate iDate from dual';
      open;
   end;

   result :=  Qrytemp.fieldbyName('iDate').asdatetime;
end;


function  TfMainForm.GetEMPNO:string;
begin
   with Qrytemp do
   begin
      Close;
      Params.Clear;
      commandText := 'select emp_no from sajet.sys_emp where emp_ID ='+updateuserid;
      open;
   end;

   result :=  Qrytemp.fieldbyName('emp_no').asstring;
end;


function TfMainForm.GetTerminalName(sTerminalID:string):string;
begin
try
  with Qrytemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'TerminalID',ptInput);
      CommandText :='select a.pdline_name,b.process_name,b.Process_id,c.terminal_name,c.terminal_id  ' +
                    '  from sajet.sys_pdline a,sajet.sys_process b,sajet.sys_terminal c '+
                    'where c.terminal_id = :TerminalID  '+
                    '  and a.pdline_id=c.pdline_id '+
                    '  and b.process_id=c.process_id';

      Params.ParamByName('TerminalID').AsString :=sTerminalID;
      Open;
      if RecordCount > 0 then
      begin
         sPdline := Fieldbyname('pdline_name').AsString  ;
         sProcess:= Fieldbyname('process_name').AsString  ;
         sProcessID:= Fieldbyname('process_ID').AsString  ;
         sTerminal:= Fieldbyname('terminal_name').AsString  ;
         Result := sPdline + ' \ ' + sProcess + ' \ ' + sTerminal ;
      end   
      else
         Result :='No Terminal information!';
   end;
Except   on e:Exception do
   Result := 'Get Terminal : ' + e.Message;

end;
end;

{
procedure TfMainForm.ShowMSG(sShowHead,sShowResult,sNextMsg:string);
var sShowData:string;
begin
  if sShowResult = 'OK' then
  begin
    msgPanel.Color := clGreen;
  end
  else
  begin
    msgPanel.Color := clRed;
  end;
  sShowData := sShowHead + ' ' +  sShowResult;
  if sNextMsg <> '' then
  begin
    sShowData := sShowData + '  =>  ' + sNextMsg;
  end;
  msgPanel.Caption := sShowData;
end;


function TfMainForm.GetPartID(partno :String) :String;
begin
    with Qrytemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'PARTNO',ptInput);
        CommandText :='SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO= :PARTNO AND ENABLED=''Y'' AND ROWNUM=1 ' ;
        Params.ParamByName('PARTNO').AsString := partno;
        Open;
        if Recordcount = 0 then
            Result :=''
        else
            Result := FieldbyName('PART_ID').AsString;
    end;
end;

procedure TfMainForm.ShowData(sCarrier :String);
begin

    With QryData do
    begin
       Close;
       Params.Clear;
       //Params.CreateParam(ftString,'WO',ptInput);
       Params.CreateParam(ftString,'CarrierNO',ptInput);
       CommandText := 'SELECT A.WORK_ORDER,A.BOX_NO,A.serial_number,a.Customer_SN,A.in_process_time '+
                      '  FROM SAJET.g_sn_status A '+
                      //' WHERE A.WORK_ORDER = :WO '+        //modify by phoenix 2013-5-9
                      ' WHERE A.Box_NO= :CarrierNO '+
                      '   AND A.WORK_FLAG= ''0'' '+          //add by phoenix 2013-05-09
                      '   AND A.CUSTOMER_SN <> ''N/A'' '+    //add by phoenix 2013-05-09
                      ' ORDER BY A.serial_number ';
     //Params.ParamByName('WO').AsString := sWO;
     Params.ParamByName('CarrierNO').AsString := sCarrier;
     Open;

    end;
end;
}

procedure TfMainForm.FormShow(Sender: TObject);
var iniFile:TIniFile;
begin
   iniFile :=TIniFile.Create('SAJET.ini');
   iTerminal :=iniFile.ReadString('CM','Terminal','N/A' );
   iniFile.Free;
   LabTerminal.Caption := 'Terminal:'+ GetTerminalName(iTerminal);
   editSN.SetFocus;

   isStart :=false;
   IsOpen :=false;
   KillTask('lppa.exe');
   try
      BarApp := CreateOleObject('lppx.Application');
   except
      isStart:=false;
      msgPanel.Caption := '沒有安裝codesoft軟體';
      msgpanel.Color :=clRed;
      Exit;
   end;
   IsStart :=true;
   
   SNUdf := TStringList.Create;
   CarryM := TStringList.Create;
   CarryD := TStringList.Create;
   CarryW := TStringList.Create;
   CarryK := TStringList.Create;
   Carry16 := '123456789ABCDEF';

   msgPanel.Caption := '請掃描不良代碼或條碼';
   msgpanel.Color :=clGreen;

end;

procedure TfMainForm.editDefectKeyPress(Sender: TObject; var Key: Char);
begin
    if Key <> #13 then exit;
    editDefect.Text := Trim(editDefect.Text);
    if Length(editDefect.Text) =0 then exit;
    
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTEmp.Params.CreateParam(ftstring,'Defect',ptInput)  ;
    QryTemp.CommandText :='Select * from sajet.sys_defect where Defect_code=:Defect';
    QryTemp.Params.ParamByName('Defect').AsString :=editDefect.Text;
    QryTemp.Open;

    if QryTemp.IsEmpty then begin
         editDefect.SelectAll;
         editDefect.SetFocus;
         editSN.Enabled :=false;
         msgpanel.Caption :='不良代碼錯誤';
         msgpanel.Color := clRed;
         exit;
    end;
    
    editSN.SelectAll;
    editSN.SetFocus;
    msgpanel.Caption :='OK,請掃描條碼';
    msgpanel.Color := clGreen;
    exit;
    
end;

function TfMainForm.GetNewNo(NoType: string; var NewNo: string): Boolean;
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
  //LabCartonQty.Visible := LabCartonCap.Visible;
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
        if  NoType = 'Pallet' then
        begin
          Close;
          Params.Clear;
          CommandText := 'select sajet.packing_label(''' + NoType + ''',''Work Order'',''' + mWO + ''') SNID from dual';
          Open;
          Result := True;
          NewNo := FieldByName('SNID').AsString;
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

procedure TfMainForm.editSNKeyPress(Sender: TObject; var Key: Char);
var iResult,sNewNo,iSN:String;

begin
     if Key <> #13 then exit;

     if length(editsn.Text)=0 then exit;

     with SProc do begin
         Close;
         DataRequest('SAJET.SJ_CKRT_SN_PSN');
         FetchParams;
         Params.ParamByName('TREV').AsString :=editSN.Text;
         Execute;
         iResult := Params.ParamByName('TRES').AsString;

         if iResult ='OK' then begin
             iSN := Params.ParamByName('PSN').AsString;
         end else begin
               with QryTemp do
               begin
                    Close;
                    Params.Clear;
                    Params.CreateParam(ftString,'SN',ptInput);
                    Params.CreateParam(ftString,'PROCESS',ptInput);
                    CommandText := ' Select A.SERIAL_NUMBER,B.WORK_ORDER,B.CUSTOMER_SN,C.PART_NO  FROM '
                                 + '  SAJET.G_SN_KEYPARTS A,SAJET.G_SN_STATUS B,SAJET.SYS_PART C   '
                                 + '  WHERE A.WORK_ORDER = B.WORK_ORDER AND A.PROCESS_ID =:PROCESS  '
                                 + '        AND  A.ITEM_PART_SN =:SN '
                                 + '        AND A.SERIAL_NUMBER =B.SERIAL_NUMBER '
                                 + '        AND A.ENABLED=''Y'' AND B.MODEL_ID =C.PART_ID';
                    Params.ParamByName('SN').AsString := Trim(editSN.Text);
                    Params.ParamByName('PROCESS').AsString := sProcessID;
                    Open;
                    if IsEmpty then begin
                        msgPanel.Caption :='NO SN';
                        msgPanel.Color :=clRed;
                        editSN.Text :='';
                        editSN.SetFocus ;
                        Exit;
                    end else begin
                        mWO := FieldByName('WORK_ORDER').AsString;
                        sPartNO:= FieldByName('PART_NO').AsString;
                        iSN := FieldByName('SERIAL_NUMBER').AsString;
                        sNewNo :=  FieldByName('CUSTOMER_SN').AsString;
                         fLogin := TfLogin.Create(Self);
                        if fLogin.ShowModal = mrOK then
                        begin
                             if not PrintLabel(sPartNO,sNewNo,iResult,clYellow) then Exit;
                        end;
                        exit;
                    end;
               end;

         end;
     end;

     with QryTemp1 do
     begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString,'SN',ptInput);
          Params.CreateParam(ftString,'PROCESS',ptInput);
          CommandText := ' Select A.SERIAL_NUMBER,B.WORK_ORDER,B.CUSTOMER_SN,C.PART_NO  FROM '
                       + '  SAJET.G_SN_KEYPARTS A,SAJET.G_SN_STATUS B,SAJET.SYS_PART C   '
                       + '  WHERE A.WORK_ORDER = B.WORK_ORDER AND A.PROCESS_ID =:PROCESS  '
                       + '        AND  A.SERIAL_NUMBER =:SN '
                       + '        AND A.SERIAL_NUMBER =B.SERIAL_NUMBER '
                       + '        AND A.ENABLED=''Y'' AND B.MODEL_ID =C.PART_ID';
          Params.ParamByName('SN').AsString := iSN;
          Params.ParamByName('PROCESS').AsString := sProcessID;
          Open;
          mWO := FieldByName('WORK_ORDER').AsString;
          sPartNO:= FieldByName('PART_NO').AsString;
     end;

     if editDefect.Text = '' then
     begin
           if  QryTemp1.IsEmpty then
           begin
                with QryData do begin
                    Close;
                    Params.Clear;
                    Params.CreateParam(ftString,'SN',ptInput);
                    CommandText := ' Select B.WORK_ORDER,B.CUSTOMER_SN,C.PART_NO  FROM '
                                 + '  SAJET.G_SN_STATUS B,SAJET.SYS_PART C   '
                                 + '  WHERE  B.SERIAL_NUMBER =:SN AND B.MODEL_ID =C.PART_ID';
                    Params.ParamByName('SN').AsString :=iSN;
                    Open;
                    mWO := FieldByName('WORK_ORDER').AsString;
                    sPartNO:= FieldByName('PART_NO').AsString;
                end;

                GetNewNo('SN',sNewNo) ;
                if sNewNo ='' then begin
                    msgPanel.Caption :='Can not Get CSN,Please Check WO Rull';
                    msgPanel.Color :=clRed;
                    editSN.Text :='';
                    editSN.SetFocus ;
                    Exit;
                end;
           end else begin

             sNewNo :=  QryTemp1.FieldByName('CUSTOMER_SN').AsString;
           end;
     end;


     Sproc.Close;
     Sproc.DataRequest('SAJET.CCM_SN_TEST_KP') ;
     Sproc.FetchParams;
     Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal;
     if editDefect.Text ='' then
        Sproc.Params.ParamByName('TDEFECT').AsString :='N/A'
     else
        Sproc.Params.ParamByName('TDEFECT').AsString :=editDefect.Text;

     Sproc.Params.ParamByName('TREV').AsString := editSN.Text;
     Sproc.Params.ParamByName('TCSN').AsString := sNewNo;
     Sproc.Params.ParamByName('TEMP').AsString := UpdateUserID;
     Sproc.Execute;
     iResult := Sproc.Params.parambyname('TRES').AsString;

     if iResult ='OK' then
     begin
        if editDefect.Text ='' then
        begin
            if not PrintLabel(sPartNo,sNewNo,iResult,clGreen) then Exit;
        end else begin
            msgPanel.Caption :=iResult;
            msgPanel.Color :=clGreen;
            editSN.Text :='';
            editSN.SetFocus ;
            Exit;
        end;

     end else
     begin
          if not QryTemp1.IsEmpty then
          begin

              fLogin := TfLogin.Create(Self);
              if fLogin.ShowModal = mrOK then
              begin
                  if PrintLabel(sPartNo,sNewNo,iResult,clYellow) then Exit;
              end;

          end else begin
              msgPanel.Caption :=iResult;
              msgPanel.Color :=clRed;
              editSN.Text :='';
              editSN.SetFocus ;
              Exit;
          end;
     end;


     msgPanel.Caption :='OK';
     msgPanel.Color :=clGreen;
     editSN.SetFocus;
     editDefect.Text :='';
     editSN.Text :='';

end;

function TfMainForm.PrintLabel(Part_no,sn,sResult:string;IColor:Integer):Boolean;
begin
    result :=True;
    PrintFile :=GetCurrentDir +'\\S_'+Part_no+'.Lab';
    If not FileExists( PrintFile) then
    begin
           msgPanel.Caption := 'Label 檔案不存在';
           msgPanel.Color :=clRed;
           editSN.SelectAll;
           editSN.SetFocus;
           IsOpen :=false;
           result :=False;
           Exit;
    end;

    if IsStart then begin
        try
           BarApp.Visible:=false;
           BarDoc:=BarApp.ActiveDocument;
           BarVars:=BarDoc.Variables;
           BarDoc.Open(PrintFile);
           IsOpen :=true;
        except
           msgPanel.Caption := '打開檔案錯誤';
           msgPanel.Color :=clRed;
           IsOpen :=false;
           result :=False;
           Exit;
        end;
    end;

    try
        BarDoc.Variables.Item('SN').Value := sn;
        Bardoc.PrintLabel(1);
        Bardoc.FormFeed;

        msgpanel.Caption :=sResult+'======>>'+'條碼列印完畢';
        msgPanel.Color :=icolor;
        editSN.Text :='';
        editSN.Setfocus;
    except
       msgpanel.Caption :='條碼列印錯誤';
       msgPanel.Color :=clRed;
       editSN.Text :='';
       editSN.Setfocus;
       result :=False;
       exit;
    end;

end;


end.
