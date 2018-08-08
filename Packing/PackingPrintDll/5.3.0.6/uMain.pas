unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, StdCtrls, Db, DBClient, MConnect, SConnect,
  ObjBrkr, Variants, comobj, VSSComm32;

type
  TfMain = class(TForm)
    Memo1: TMemo;
    Memo2: TMemo;
    VSSComm321: TVSSComm32;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
  private
    { Private declarations }
  public
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
    function SaveToFile(sType: string; iQty: integer): Boolean;
    function Print(sComPort, sPrintData: string; iQty, iCount: integer): Boolean;
    function IntToBaud(data: Integer): TBaudRate;
    function SendComPort(sComPort, sBaudRate, sPrintData: string; iQty: integer): Boolean;
    function GET_FILE(sTitle, sPartNo, sWO, sCustPartNo, sExName, sLabelFile: string; bShowMsg: Boolean): Boolean;
    procedure ReplaceData;
    procedure ReplaceDataExcel(sString: string; var sReplace: string);
    { Public declarations }
  end;

var
  fMain: TfMain;
  g_tsParam, g_tsData: TStrings;
  g_sSampleFile: string;
function SendData(iType, PrintLabQty: integer; tsParam, tsData: TStrings; PcomPort, PBaudRate: string; G_sockConnection: TSocketConnection): Boolean; stdcall; export;
function SendDataMaterial(iType, PrintLabQty: integer; tsParam, tsData: TStrings; PcomPort, PBaudRate: string; G_sockConnection: TSocketConnection; sLabelType: string; iPrintSeq: Integer): Boolean; stdcall; export;
function PrintInitial(iType: integer; PcomPort, PBaudRate, sPartNo, sWO, sCustPartNo, sLabelFile: string): Boolean; stdcall; export;
implementation

{$R *.DFM}

function PrintInitial(iType: integer; PcomPort, PBaudRate, sPartNo, sWO, sCustPartNo, sLabelFile: string): Boolean;
var sTitle: string;
begin
  //初始化Label Printer
  Result := False;
  try
    case iType of
      1: sTitle := 'P_';
      2: sTitle := 'C_';
      3: sTitle := 'S_';
      4: sTitle := 'B_';
    end;
    fMain := TfMain.Create(nil);
    if not fMain.GET_FILE(sTitle, sPartNo, sWO, sCustPartNo, 'init', sLabelFile, True) then
      exit;
    WinExec(Pchar('PRINT /D:' + PcomPort + ' ' + g_sSampleFile), SW_HIDE);
    Sleep(30000);
    Result := True;
  finally
    fMain.VSSComm321.StopComm;
    fMain.Free;
  end;
end;

function SendData(iType, PrintLabQty: integer; tsParam, tsData: TStrings; PcomPort, PBaudRate: string; G_sockConnection: TSocketConnection): Boolean;
var sPartNo, sWO, sCustPartNo, sLabelFile, sTitle: string;
  i, iPrintType: integer;
begin
  Result := False;
  try
    g_tsParam := TStringList.Create;
    g_tsData := TStringList.Create;
    for i := 0 to tsParam.Count - 1 do
      g_tsParam.Add(tsParam.Strings[i]);
    for i := 0 to tsData.Count - 1 do
      g_tsData.Add(tsData.Strings[i]);

    sPartNo := g_tsData.Strings[g_tsParam.IndexOf('PART_NO')];
    sWO := g_tsData.Strings[g_tsParam.IndexOf('WORK_ORDER')];
    sCustPartNo := g_tsData.Strings[g_tsParam.IndexOf('CUST_PART_NO')];
    sLabelFile := g_tsData.Strings[g_tsParam.IndexOf('LABEL_FILE')];
    case iType of
      1: sTitle := 'P_';
      2: sTitle := 'C_';
      3: sTitle := 'S_';
      4: sTitle := 'B_';
    end;
    fMain := TfMain.Create(nil);

    if fMain.GET_FILE(sTitle, sPartNo, sWO, sCustPartNo, 'out', sLabelFile, False) then
      iPrintType := 2
    else if fMain.GET_FILE(sTitle, sPartNo, sWO, sCustPartNo, 'txt',sLabelFile, False) then
      iPrintType := 2
    else if fMain.GET_FILE(sTitle, sPartNo, sWO, sCustPartNo, 'xlt', sLabelFile, True) then
      iPrintType := 3
    else
      Exit;
    if iType = 1 then
    begin
      //找DN DATA
      fMain.QryTemp.RemoteServer := G_sockConnection;
      fMain.QryTemp.ProviderName := 'DspQryTemp1';
      with fMain.QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
        CommandText := 'select b.DN_NO,C.DN_ITEM,C.SO_NO,C.SO_ITEM,C.DESCRIPTION "DN_ITEM_DESC" '
          + 'from sajet.g_wo_dn a, sajet.g_dn_base b,sajet.g_dn_detail c '
          + 'where a.work_order=:WORK_ORDER '
          + 'and a.dn_id=b.dn_id '
          + 'and a.dn_id=c.dn_id '
          + 'and a.dn_item=c.dn_item '
          + 'and rownum = 1';
        Params.ParamByName('WORK_ORDER').AsString := sWO;
        Open;
        for i := 1 to Fields.Count do
        begin
          if g_tsParam.IndexOf(Uppercase(Fields.Fields[i - 1].FieldName)) < 0 then
          begin
            g_tsParam.Add(UpperCase(Fields.Fields[i - 1].FieldName));
            g_tsData.add(Fields.Fields[i - 1].AsString);
          end;
        end;
      end;
    end;
    case iPrintType of
      1:
        begin
          fMain.ReplaceData;
          if not fMain.SendComPort(PComPort, PBaudRate, fMain.Memo2.Text, PrintLabQty) then Exit;
        end;
      2:
        begin
          fMain.ReplaceData;
          if not fMain.Print(PComPort, fMain.Memo2.Text, PrintLabQty, PrintLabQty) then Exit;
        end;
      3:
        begin
          fMain.ReplaceData;
          if not fMain.SaveToFile('PRINT', PrintLabQty) then Exit;
        end;
    end;
    Result := True;
  finally
    g_tsParam.Free;
    g_tsData.Free;
    if iPrintType = 1 then fMain.VSSComm321.StopComm;
    fMain.Free;
  end;
end;

function SendDataMaterial(iType, PrintLabQty: integer; tsParam, tsData: TStrings; PcomPort, PBaudRate: string; G_sockConnection: TSocketConnection; sLabelType: string; iPrintSeq: Integer): Boolean;
var sPartNo, sWO, sCustPartNo, sLabelFile, sTitle: string;
  i, iPrintType: integer;
begin
  Result := False;
  try
    g_tsParam := TStringList.Create;
    g_tsData := TStringList.Create;
    for i := 0 to tsParam.Count - 1 do
      g_tsParam.Add(tsParam.Strings[i]);
    for i := 0 to tsData.Count - 1 do
      g_tsData.Add(tsData.Strings[i]);

    sPartNo := g_tsData.Strings[g_tsParam.IndexOf('PART_NO')];
    sLabelFile := g_tsData.Strings[g_tsParam.IndexOf('LABEL_FILE')];
    sWO := 'N/A';
    sCustPartNo := 'N/A';
    case iType of
      1: sTitle := 'P_';
      2: sTitle := 'C_';
      3: sTitle := 'S_';
      4: sTitle := 'B_';
      5: sTitle := 'M' + sLabelType + '_';
    end;
    fMain := TfMain.Create(nil);

    if fMain.GET_FILE(sTitle, sPartNo, sWO, sCustPartNo, 'out', sLabelFile, False) then
      iPrintType := 2
    else if fMain.GET_FILE(sTitle, sPartNo, sWO, sCustPartNo, 'txt', sLabelFile, False) then
      iPrintType := 2
    else if fMain.GET_FILE(sTitle, sPartNo, sWO, sCustPartNo, 'xlt', sLabelFile, True) then
      iPrintType := 3
    else
      Exit;
    case iPrintType of
      1:
        begin
          fMain.ReplaceData;
          if not fMain.SendComPort(PComPort, PBaudRate, fMain.Memo2.Text, PrintLabQty) then Exit;
        end;
      2:
        begin
          fMain.ReplaceData;
          if not fMain.Print(PComPort, fMain.Memo2.Text, PrintLabQty, iPrintSeq) then Exit;
        end;
      3:
        begin
          fMain.ReplaceData;
          if not fMain.SaveToFile('PRINT', PrintLabQty) then Exit;
        end;
    end;
    Result := True;
  finally
    g_tsParam.Free;
    g_tsData.Free;
    if iPrintType = 1 then fMain.VSSComm321.StopComm;
    fMain.Free;
  end;
end;

function TfMain.Print(sComPort, sPrintData: string; iQty, iCount: integer): Boolean;
var i: integer;
  sFileName: string;
begin
  sFileName := 'C:\PrintTemp';
  sFileName := sFileName + (IntToStr(iCount mod 20)) + '.txt';
  Memo2.Lines.SaveToFile(sFileName);
  sFileName := 'PRINT /D:' + sComPort + ' ' + sFileName;
  for i := 1 to iQty do
    WinExec(Pchar(sFileName), SW_HIDE);
  Result := True;
end;

function TfMain.SAVETOFILE(sType: string; iQty: integer): Boolean;
var sFileName: string;
  MsExcel, MsExcelWorkBook: Variant;
  i: integer;
begin
  Result := False;
  if sType = 'SAVE' then
  begin
    SaveDialog1.InitialDir := ExtractFilePath('C:\');
    SaveDialog1.DefaultExt := 'xls';
    SaveDialog1.Filter := 'All Files(*.xls)|*.xls';
    if SaveDialog1.Execute then
    begin
      try
        sFileName := SaveDialog1.FileName;
        MsExcel := CreateOleObject('Excel.Application');
        MsExcelWorkBook := MsExcel.WorkBooks.Open(g_sSampleFile);
        MsExcel.Worksheets['Sheet1'].select;
        SaveExcel(MsExcel, MsExcelWorkBook);
        MsExcelWorkBook.SaveAs(sFileName);
        Result := True;
        showmessage('Save Excel OK!!');
      except
        ShowMessage('Could not start Microsoft Excel.');
      end;
      MsExcel.Application.Quit;
      MsExcel := Null;
    end;
  end
  else
  begin
    try
      MsExcel := CreateOleObject('Excel.Application');
      MsExcelWorkBook := MsExcel.WorkBooks.Open(g_sSampleFile);
      MsExcel.Worksheets['Sheet1'].select;
      SaveExcel(MsExcel, MsExcelWorkBook);

      for i := 1 to iQty do
      begin
        MsExcel.WorkSheets['Sheet1'].PrintOut;
      end;
      Result := True;
    except
      ShowMessage('Could not start Microsoft Excel.');
    end;
    MsExcelWorkBook.close(False);
    MsExcel.Application.Quit;
    MsExcel := Null;
  end;
end;

procedure TfMain.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var i, j: integer; sLocString, sData: string;
begin
  //A1..M51
  for i := 0 to 12 do
  begin
    for j := 0 to 50 do
    begin
      sLocString := MsExcel.Worksheets['Sheet1'].Range[Chr(65 + i) + IntToStr(j + 1)];
      if Pos('%', sLocString) <> 0 then
      begin
        ReplaceDataExcel(sLocString, sData);
        MsExcel.Worksheets['Sheet1'].Range[Chr(65 + i) + IntToStr(j + 1)] := sData;
      end;
    end;
  end;
end;

function TfMain.GET_FILE(sTitle, sPartNo, sWO, sCustPartNo, sExName, sLabelFile: string; bShowMsg: Boolean): Boolean;
begin
  //找標籤範本檔;檔名為P_DEFAULT(若需分Part則將DEFAULT改為PART_NO值)

  g_sSampleFile := ExtractFilePath(Application.ExeName) + sTitle + sWO + '.' + sExName;
  //找料號的LABEL_FILE
  if not FileExists(g_sSampleFile) then
  begin
    g_sSampleFile := ExtractFilePath(Application.ExeName) + sTitle + sLabelFile + '.' + sExName;
  end;
  if not FileExists(g_sSampleFile) then
    g_sSampleFile := ExtractFilePath(Application.ExeName) + sTitle + sPartNo + '.' + sExName;
  if not FileExists(g_sSampleFile) then
    g_sSampleFile := ExtractFilePath(Application.ExeName) + sTitle + sCustPartNo + '.' + sExName;
  if not FileExists(g_sSampleFile) then
    g_sSampleFile := ExtractFilePath(Application.ExeName) + sTitle + 'DEFAULT' + '.' + sExName;

  if not FileExists(g_sSampleFile) then
  begin
    if bShowMsg then
      MessageDlg('The file ''' + g_sSampleFile + ''' is not found!!', mtError, [mbOK], 0);
    Result := False;
    exit;
  end;

  //把標籤原始檔load進Memo2中
  Memo2.Clear;
  Memo2.Lines.LoadFromFile(g_sSampleFile);

  Result := True;
end;

function TfMain.SendComPort(sComPort, sBaudRate, sPrintData: string; iQty: integer): Boolean;
var i, iVSSCommSleepTime: integer;
begin
  Result := False;

  if sComPort = 'COM1' then
    VSSComm321.CommPort := COM1
  else
    VSSComm321.CommPort := COM2;
  VSSComm321.BaudRate := IntToBaud(StrToIntDef(sBaudRate, 0));
  iVSSCommSleepTime := 1000;

  try
    VSSComm321.StartComm;
  except
    MessageDlg('Com Port Open Error !!', mtWarning, [mbOK], 0);
    exit;
  end;

  sleep(iVSSCommSleepTime);

  for i := 1 to iQty do
  begin
    VSSComm321.WriteCommData(PChar(sPrintData), Length(sPrintData));
    sleep(iVSSCommSleepTime);
  end;
  Result := True;
end;

procedure TfMain.ReplaceDataExcel(sString: string; var sReplace: string);
var sLocString, sPrintParam: string;
  iCount, iLocStringIndex: integer;
begin
  sLocString := sString;
  //將變數以值取代
  for iCount := 0 to (g_tsParam.Count - 1) do
  begin
    sPrintParam := '%' + g_tsParam.Strings[iCount] + '%';
    iLocStringIndex := pos(sPrintParam, sLocString);
    while iLocStringIndex <> 0 do
    begin
      Delete(sLocString, iLocStringIndex, Length(sPrintParam));
      Insert(Trim(g_tsData.Strings[iCount]), sLocString, iLocStringIndex);
      iLocStringIndex := pos(sPrintParam, sLocString);
    end;
  end;
  sReplace := sLocString;
end;

procedure TfMain.ReplaceData;
var sLocString, sPrintParam, sLoc: string;
  iCount, iLocStringIndex, iLoc: integer;
begin
  sLocString := Memo2.Text;

    //將變數以值取代
  for iCount := 0 to (g_tsParam.Count - 1) do
  begin
    sPrintParam := '%' + g_tsParam.Strings[iCount] + '%';
    iLocStringIndex := pos(sPrintParam, sLocString);

    while iLocStringIndex <> 0 do
    begin
      Delete(sLocString, iLocStringIndex, Length(sPrintParam));
      Insert(Trim(g_tsData.Strings[iCount]), sLocString, iLocStringIndex);
      iLocStringIndex := pos(sPrintParam, sLocString);
    end;
  end;
  //將沒用到的%SN_1%,....改為空值
  sPrintParam := '%SN_';
  iLocStringIndex := pos(sPrintParam, sLocString);
  while iLocStringIndex <> 0 do
  begin
    sLoc := Copy(sLocString, iLocStringIndex + length(sPrintParam), length(sLocString));
    iLoc := Pos('%', sLoc);
    Delete(sLocString, iLocStringIndex, length(sPrintParam) + iLoc);
    Insert('', sLocString, iLocStringIndex);
    iLocStringIndex := pos(sPrintParam, sLocString);
  end;

    //將沒用到的%CSN_1%,....改為空值
  sPrintParam := '%CSN_';
  iLocStringIndex := pos(sPrintParam, sLocString);
  while iLocStringIndex <> 0 do
  begin
    sLoc := Copy(sLocString, iLocStringIndex + length(sPrintParam), length(sLocString));
    iLoc := Pos('%', sLoc);
    Delete(sLocString, iLocStringIndex, length(sPrintParam) + iLoc);
    Insert('', sLocString, iLocStringIndex);
    iLocStringIndex := pos(sPrintParam, sLocString);
  end;

    //將沒用到的%CARTON_1%,....改為空值
  sPrintParam := '%CARTON_';
  iLocStringIndex := pos(sPrintParam, sLocString);
  while iLocStringIndex <> 0 do
  begin
    sLoc := Copy(sLocString, iLocStringIndex + length(sPrintParam), length(sLocString));
    iLoc := Pos('%', sLoc);
    Delete(sLocString, iLocStringIndex, length(sPrintParam) + iLoc);
    Insert('', sLocString, iLocStringIndex);
    iLocStringIndex := pos(sPrintParam, sLocString);
  end;

  Memo2.Clear;
  Memo2.Text := sLocString;
end;

function TfMain.IntToBaud(data: Integer): TBaudRate;
begin
  case data of
    110: Result := ____110;
    300: Result := ____300;
    600: Result := ____600;
    1200: Result := ___1200;
    2400: Result := ___2400;
    4800: Result := ___4800;
    9600: Result := ___9600;
    14400: Result := __14400;
    19200: Result := __19200;
    38400: Result := __38400;
    56000: Result := __56000;
    128000: Result := _128000;
    256000: Result := _256000;
  else
    Result := ____110;
  end;
end;

end.

