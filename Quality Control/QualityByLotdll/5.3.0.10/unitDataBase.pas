unit unitDataBase;

interface

uses classes, sysutils, SConnect, DB, dbclient, unitCSPrintData, forms, dialogs;

const
  cSNTitle = 'SN_';
  cCSNTitle = 'CSN_';
  cBoxTitle = 'BOX_';
  cCartonTitle = 'CARTON_';
  cBoxCount = 'BOX_COUNT';
  cCartonCount = 'CARTON_COUNT';
  cPalletCount = 'PALLET_COUNT';
  cBoxTotal = 'BOX_TOTAL';
  cCartonTotal = 'CARTON_TOTAL';
  cPalletTotal = 'PALLET_TOTAL';

function G_getTableData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sTableName, f_sParam, f_sData: string; var f_tsParam, f_tsData: tstrings): boolean;
function G_getParamData(f_tsParam, f_tsData: tstrings; f_sParam: string): string;
procedure G_deleteParamData(f_sParam: string; var f_tsParam, f_tsData: tstrings);
function G_getFieldsData(f_Fields: TFields; var f_tsParam, f_tsData: tstrings): boolean;

function G_getWOData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sWO: string; var f_tsParam, f_tsData: tstrings): boolean;
function G_getSNData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sSN: string; var f_tsParam, f_tsData: tstrings): boolean;
function G_getQCData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sQC: string; var f_tsParam, f_tsData: tstrings): boolean;
function G_getBoxNoData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sBoxNO: string; var f_tsParam, f_tsData: tstrings): boolean;
function G_getCartonNoData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sCartonNO: string; var f_tsParam, f_tsData: tstrings): boolean;
function G_getPalletNoData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sPalletNO: string; var f_tsParam, f_tsData: tstrings): boolean;
function G_getBCCartonNoData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sCartonNO: string; var f_tsParam, f_tsData: tstrings): boolean;
function G_getBCPalletNoData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sPalletNO: string; var f_tsParam, f_tsData: tstrings): boolean;
function G_getBCData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sType, f_sLabelNO: string; var f_tsParam, f_tsData: tstrings; var sTitle: string): boolean;
function G_getBCCustomerSNData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sCustomerSN: string; var f_tsParam, f_tsData: tstrings): boolean;
function G_getBCWOData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sWO: string; var f_tsParam, f_tsData: tstrings): boolean;
function G_getPNLabel(f_SocketConnection: TSocketConnection; f_sProvideName, f_sCartionNO: string; var f_tsParam, f_tsData: tstrings): boolean;
function G_getRFPacking1(f_SocketConnection: TSocketConnection; f_sProvideName, f_sSN: string; var f_tsParam, f_tsData: tstrings): boolean;
function G_getWOOoutput(f_SocketConnection: TSocketConnection; f_sProvideName, f_sCarton: string; var f_tsParam, f_tsData: tstrings): boolean;
function G_getMaterialData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sType, f_sLabelNO: string; var f_tsParam, f_tsData: tstrings; var sTitle: string): boolean;

function G_getPrintData(f_iVersion, f_iType: integer; f_SocketConnection: TSocketConnection; f_sProvideName, f_sKeyWord: string; f_iQty: integer; f_sRuleName: string): string; overload;
function G_getPrintData(f_iVersion, f_iType: integer; f_SocketConnection: TSocketConnection; f_sProvideName, f_sKeyWord, f_sRuleName: string): string; overload;

implementation

function G_getWOOoutput(f_SocketConnection: TSocketConnection; f_sProvideName, f_sCarton: string; var f_tsParam, f_tsData: tstrings): boolean;
var sTable: string;
  sParam: string;
  sData: string;
begin
  result := false;
  try
    with TClientDataSet.Create(Application) do
    begin
      try
        RemoteServer := f_SocketConnection;
        ProviderName := f_sProvideName;
        params.CreateParam(ftString, 'carton_no', ptInput);
        CommandText := ' select work_order,carton_no,route_id,pdline_id,stage_id,process_id,terminal_id,sum(output_qty) output_qty ' +
          ' from SAJET.G_CUST_WO_OUTPUT ' +
          ' where carton_no=:carton_no ' +
          ' group by work_order,carton_no,route_id,pdline_id,stage_id,process_id,terminal_id ';
        Params.ParamByName('carton_no').AsString := f_sCarton;
        open;
        if recordcount <> 1 then raise Exception.create('Print Data Error');

        G_getFieldsData(Fields, f_tsParam, f_tsData);

        close;
      finally
        free;
      end;
    end;

    sParam := 'work_order';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getWOData(f_SocketConnection, f_sProvideName, sData, f_tsParam, f_tsData) then exit;

    sTable := 'sajet.sys_pdline';
    sParam := 'PDLINE_ID';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sTable := 'SAJET.SYS_STAGE';
    sParam := 'STAGE_ID';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sTable := 'SAJET.SYS_PROCESS';
    sParam := 'PROCESS_ID';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sTable := 'SAJET.SYS_TERMINAL';
    sParam := 'TERMINAL_ID';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    result := true;
  except
  end;
end;


function G_getRFPacking1(f_SocketConnection: TSocketConnection; f_sProvideName, f_sSN: string; var f_tsParam, f_tsData: tstrings): boolean;
var iCount: integer;
begin
  result := false;
  try
    if not G_getSNData(f_SocketConnection, f_sProvideName, f_sSN, f_tsParam, f_tsData) then exit;

    with TClientDataSet.Create(Application) do
    begin
      try
        RemoteServer := f_SocketConnection;
        ProviderName := f_sProvideName;
        Params.CreateParam(ftString, 'serial_number', ptInput);
        Params.CreateParam(ftString, 'process_id', ptInput);
        CommandText := ' select * ' +
          ' from sajet.G_SN_KEYPARTS r1, ' +
          '      sajet.sys_part r2 ' +
          ' where r1.item_part_id=r2.part_id ' +
          '   and r1.serial_number=:serial_number ' +
          '   and r1.process_id=:process_id ' +
          ' order by part_no ';
        Params.ParamByName('serial_number').asstring := G_getParamData(f_tsParam, f_tsData, 'serial_number');
        Params.ParamByName('process_id').asstring := G_getParamData(f_tsParam, f_tsData, 'process_id');
        open;
        first;

        f_tsParam.Add('KP_COUNT');
        f_tsData.add(inttostr(recordcount));

        iCount := 0;
        while not eof do
        begin
          inc(iCount);
          f_tsParam.Add(uppercase(fieldbyname('part_no').FieldName + '_' + IntToStr(iCount)));
          f_tsData.Add(uppercase(fieldbyname('part_no').AsString));
          f_tsParam.Add(uppercase(fieldbyname('ITEM_PART_SN').FieldName + '_' + IntToStr(iCount)));
          f_tsData.Add(uppercase(fieldbyname('ITEM_PART_SN').AsString));
          next;
        end;
      finally
        free;
      end;
    end;

    result := true;
  except
  end;
end;


function G_getPNLabel(f_SocketConnection: TSocketConnection; f_sProvideName, f_sCartionNO: string; var f_tsParam, f_tsData: tstrings): boolean;
var sTable: string;
  sParam: string;
  sData: string;
begin
  result := false;
  try
    sTable := 'SAJET.G_CUST_STOCKOUT';
    sParam := 'carton_no';
    sData := f_sCartionNO;
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sTable := 'SAJET.SYS_PART';
    sParam := 'PART_ID';
    sData := G_getParamData(f_tsParam, f_tsData, 'part_id');
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    result := true;
  except
  end;
end;


function G_getWOData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sWO: string; var f_tsParam, f_tsData: tstrings): boolean;
var sTable: string;
  sParam: string;
  sData: string;
begin
  result := false;
  try
    sTable := 'sajet.g_wo_base';
    sParam := 'work_order';
    sData := f_sWO;
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sTable := 'SAJET.SYS_PART';
    sParam := 'PART_ID';
    sData := G_getParamData(f_tsParam, f_tsData, 'MODEL_ID');
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sTable := 'SAJET.SYS_CUSTOMER';
    sParam := 'CUSTOMER_ID';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    result := true;
  except
  end;
end;

function G_getPrintData(f_iVersion, f_iType: integer; f_SocketConnection: TSocketConnection; f_sProvideName, f_sKeyWord, f_sRuleName: string): string;
begin
  result := G_getPrintData(f_iVersion, f_iType, f_SocketConnection, f_sProvideName, f_sKeyWord, 1, f_sRuleName);
end;

function G_getPrintData(f_iVersion, f_iType: integer; f_SocketConnection: TSocketConnection; f_sProvideName, f_sKeyWord: string; f_iQty: integer; f_sRuleName: string): string;
var printTemp: TCSPrintData;
  sPartNo, sTitle, sSN, sWo, sType, sValue, sFileName: string;
begin
  result := '';

  printTemp := TCSPrintData.create(Application);
  try
    printTemp.clear;
    case f_iType of
      1:
        begin
          if not G_getPalletNoData(f_SocketConnection, f_sProvideName, f_sKeyWord, printTemp.m_tsParam, printTemp.m_tsData) then raise Exception.Create('Get Pallet No(' + f_sKeyWord + ') Data Fail');
          sTitle := 'P_';
        end;
      2:
        begin
          if not G_getCartonNoData(f_SocketConnection, f_sProvideName, f_sKeyWord, printTemp.m_tsParam, printTemp.m_tsData) then raise Exception.Create('Get Carton No(' + f_sKeyWord + ') Data Fail');
          sTitle := 'C_';
        end;
      3:
        begin
          if not G_getSNData(f_SocketConnection, f_sProvideName, f_sKeyWord, printTemp.m_tsParam, printTemp.m_tsData) then raise Exception.Create('Get SN(' + f_sKeyWord + ') Data Fail');
          sTitle := 'S_';
        end;
      4:
        begin
          if not G_getBCPalletNoData(f_SocketConnection, f_sProvideName, f_sKeyWord, printTemp.m_tsParam, printTemp.m_tsData) then raise Exception.Create('Get WO (' + f_sKeyWord + ') Data Fail');
          sTitle := 'BP_';
        end;
      5:
        begin
          if not G_getBCCartonNoData(f_SocketConnection, f_sProvideName, f_sKeyWord, printTemp.m_tsParam, printTemp.m_tsData) then raise Exception.Create('Get Carton No(' + f_sKeyWord + ') Data Fail');
          sTitle := 'BC_';
        end;
      6:
        begin
          if not G_getSNData(f_SocketConnection, f_sProvideName, f_sKeyWord, printTemp.m_tsParam, printTemp.m_tsData) then raise Exception.Create('Get SN(' + f_sKeyWord + ') Data Fail');
          sTitle := 'BS_';
        end;
      7:
        begin //PROD的PrintPNLabelDll
          if not G_getPNLabel(f_SocketConnection, f_sProvideName, f_sKeyWord, printTemp.m_tsParam, printTemp.m_tsData) then raise Exception.Create('Get Cation (' + f_sKeyWord + ') Data Fail');
        end;
      8:
        begin //PROD的RFPacking1Dll
          if not G_getRFPacking1(f_SocketConnection, f_sProvideName, f_sKeyWord, printTemp.m_tsParam, printTemp.m_tsData) then raise Exception.Create('Get SN (' + f_sKeyWord + ') Data Fail');
          sTitle := 'RF_BOX_';
        end;
      9:
        begin //PROD的RFPacking2Dll
          if not G_getSNData(f_SocketConnection, f_sProvideName, f_sKeyWord, printTemp.m_tsParam, printTemp.m_tsData) then raise Exception.Create('Get SN(' + f_sKeyWord + ') Data Fail');
          sTitle := 'RF_SN_';
        end;
      10:
        begin //PROD的WOoutputDll
          if not G_getWOOoutput(f_SocketConnection, f_sProvideName, f_sKeyWord, printTemp.m_tsParam, printTemp.m_tsData) then raise Exception.Create('Get Cartion(' + f_sKeyWord + ') Data Fail');
        end;
      11:
        begin
          if not G_getBCCustomerSNData(f_SocketConnection, f_sProvideName, f_sKeyWord, printTemp.m_tsParam, printTemp.m_tsData) then raise Exception.Create('Get Customer SN(' + f_sKeyWord + ') Data Fail');
          sTitle := 'BCSN_';
        end;
      12:
        begin
          sSN := Copy(f_sKeyWord, 1, Pos('*&*', f_sKeyWord) - 1);
          sWo := Copy(f_sKeyWord, Pos('*&*', f_sKeyWord) + 3, Length(f_sKeyWord));
          if sWo <> '' then
            if not G_getBCWOData(f_SocketConnection, f_sProvideName, sWo, printTemp.m_tsParam, printTemp.m_tsData) then raise Exception.Create('Get WO(' + f_sKeyWord + ') Data Fail');
          sTitle := 'BUD_';
        end;
      13, 14:
        begin
        end;
      15:
        begin
          sType := Copy(f_sKeyWord, 1, Pos('*&*', f_sKeyWord) - 1);
          sValue := Copy(f_sKeyWord, Pos('*&*', f_sKeyWord) + 3, Length(f_sKeyWord));
          if not G_getBCData(f_SocketConnection, f_sProvideName, sType, sValue, printTemp.m_tsParam, printTemp.m_tsData, sTitle) then raise Exception.Create('Get ' + sType + '(' + f_sKeyWord + ') Data Fail');
        end;
      16:
        begin
          if not G_getBoxNoData(f_SocketConnection, f_sProvideName, f_sKeyWord, printTemp.m_tsParam, printTemp.m_tsData) then raise Exception.Create('Get Box No(' + f_sKeyWord + ') Data Fail');
          sTitle := 'B_';
        end;
      17:
        begin
          sType := Copy(f_sKeyWord, 1, Pos('*&*', f_sKeyWord) - 1);
          sValue := Copy(f_sKeyWord, Pos('*&*', f_sKeyWord) + 3, Length(f_sKeyWord));
          if not G_getMaterialData(f_SocketConnection, f_sProvideName, sType, sValue, printTemp.m_tsParam, printTemp.m_tsData, sTitle) then raise Exception.Create('Get ' + sType + '(' + sValue + ') Data Fail');
          sTitle := 'M' + Copy(sValue, 1, 1) + '_';
        end;
      18:
        begin
          if not G_getSNData(f_SocketConnection, f_sProvideName, f_sKeyWord, printTemp.m_tsParam, printTemp.m_tsData) then raise Exception.Create('Get SN(' + f_sKeyWord + ') Data Fail');
          sTitle := 'PL_';
        end;
      19:
        begin
          if not G_getQCData(f_SocketConnection, f_sProvideName, f_sKeyWord, printTemp.m_tsParam, printTemp.m_tsData) then raise Exception.Create('Get SN(' + f_sKeyWord + ') Data Fail');
          sTitle := 'QC_';
        end;
    else
      raise Exception.Create('Unknow Print Type');
    end;

    case f_iType of
      1, 2, 3, 4, 5, 6, 8, 9, 11, 15, 16, 17, 18, 19:
        begin
          sPartNo := G_getParamData(printTemp.m_tsParam, printTemp.m_tsData, 'PART_NO');
          sFileName := G_getParamData(printTemp.m_tsParam, printTemp.m_tsData, 'LABEL_FILE');
          printTemp.m_sSampleFile := ExtractFilePath(Application.ExeName) + sTitle + sFileName + '.LAB';
          if not FileExists(printTemp.m_sSampleFile) then
            printTemp.m_sSampleFile := ExtractFilePath(Application.ExeName) + sTitle + sPartNo + '.LAB';
          if not FileExists(printTemp.m_sSampleFile) then
            printTemp.m_sSampleFile := ExtractFilePath(Application.ExeName) + sTitle + 'DEFAULT' + '.LAB';
        end;
      7: printTemp.m_sSampleFile := ExtractFilePath(Application.ExeName) + 'StockOut.lab';
      10: printTemp.m_sSampleFile := ExtractFilePath(Application.ExeName) + 'WO_OUTPUT.lab';
      12:
        begin
          printTemp.m_tsParam.Add('SERIAL_NUMBER');
          printTemp.m_tsData.add(sSN);
          printTemp.m_sSampleFile := ExtractFilePath(Application.ExeName) + sTitle + f_sRuleName + '.lab';
          if not FileExists(printTemp.m_sSampleFile) then printTemp.m_sSampleFile := ExtractFilePath(Application.ExeName) + sTitle + 'DEFAULT' + '.LAB';
        end;
      13:
        begin
          printTemp.m_tsParam.Clear;
          printTemp.m_tsData.Clear;
          printTemp.m_tsParam.Add('PARTNO');
          printTemp.m_tsData.add(f_sKeyWord);
          printTemp.m_sSampleFile := ExtractFilePath(Application.ExeName) + 'PartNo.lab';
        end;
      14:
        begin
          printTemp.m_tsParam.Clear;
          printTemp.m_tsData.Clear;
          printTemp.m_tsParam.Add('MAC');
          printTemp.m_tsData.add(f_sKeyWord);
          printTemp.m_sSampleFile := ExtractFilePath(Application.ExeName) + f_sRuleName + '.lab';
        end;
    else
      raise Exception.Create('Unknow Print Type');
    end;

    printTemp.m_iQty := f_iQty;
    if f_iVersion in [0, 4, 5, 6] then printTemp.m_iVerstion := f_iVersion;
    result := printTemp.encodePrintData;
  finally
    printTemp.free;
  end;
end;

function G_getQCData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sQC: string; var f_tsParam, f_tsData: tstrings): boolean;
var sTable: string;
  sParam: string;
  sData: string;
begin
  result := false;
  try
    f_tsData.clear;
    f_tsParam.clear;

    sTable := 'sajet.g_qc_lot';
    sParam := 'QC_TYPE';
    sData := f_sQC;
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    G_deleteParamData('MODEL_ID', f_tsParam, f_tsData);
    G_deleteParamData('CUSTOMER_ID', f_tsParam, f_tsData);

    sParam := 'work_order';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getWOData(f_SocketConnection, f_sProvideName, sData, f_tsParam, f_tsData) then exit;

    sTable := 'sajet.sys_pdline';
    sParam := 'PDLINE_ID';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sTable := 'SAJET.SYS_STAGE';
    sParam := 'STAGE_ID';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sTable := 'SAJET.SYS_PROCESS';
    sParam := 'PROCESS_ID';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sTable := 'SAJET.SYS_TERMINAL';
    sParam := 'TERMINAL_ID';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;
    result := true;
  except
  end;
end;

function G_getMaterialData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sType, f_sLabelNO: string; var f_tsParam, f_tsData: tstrings; var sTitle: string): boolean;
begin
  result := false;
  try
    with TClientDataSet.Create(Application) do
    begin
      try
        RemoteServer := f_SocketConnection;
        ProviderName := f_sProvideName;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'material_no', ptInput);
        if f_sType = 'Pick List' then
          CommandText := 'select * from sajet.g_pick_list a, sajet.sys_part b '
            + 'where a.part_id = b.part_id '
            + 'and material_no = :material_no and rownum = 1'
        else begin
          CommandText := 'select * from sajet.g_material a, sajet.sys_part b, '
            + 'sajet.g_erp_rtno c, sajet.sys_vendor d '
            + 'where a.part_id = b.part_id and a.rt_id = c.rt_id(+) and c.vendor_id = d.vendor_id(+) ';
          if f_sType <> 'Reel ID' then
            CommandText := CommandText + 'and material_no = :material_no and rownum = 1'
          else
            CommandText := CommandText + 'and reel_no = :material_no and rownum = 1';
        end;
        Params.ParamByName('material_no').AsString := f_sLabelNO;
        Open;
        G_getFieldsData(Fields, f_tsParam, f_tsData);
        if f_sType = 'Pick List' then begin
          if Copy(f_sLabelNO, 1, 1) = 'R' then begin
            f_tsParam[f_tsParam.IndexOf('MATERIAL_NO')] := 'REEL_NO';
            f_tsParam[f_tsParam.IndexOf('QTY')] := 'REEL_QTY';
          end else begin
            f_tsParam[f_tsParam.IndexOf('QTY')] := 'MATERIAL_QTY';
          end;
        end;
        Close;
      finally
        free;
      end;
    end;
    result := true;
  except
  end;
end;

procedure G_deleteParamData(f_sParam: string; var f_tsParam, f_tsData: tstrings);
var iIndex: integer;
begin
  iIndex := f_tsParam.indexof(UpperCase(f_sParam));
  if iIndex < 0 then exit;
  f_tsParam.Delete(iIndex);
  f_tsData.Delete(iIndex);
end;

function G_getParamData(f_tsParam, f_tsData: tstrings; f_sParam: string): string;
var iIndex: integer;
begin
  result := '';
  iIndex := f_tsParam.indexof(UpperCase(f_sParam));
  if iIndex < 0 then exit;
  result := f_tsData[iIndex];
end;

function G_getTableData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sTableName, f_sParam, f_sData: string; var f_tsParam, f_tsData: tstrings): boolean;
begin
  result := false;
  try
    with TClientDataSet.Create(Application) do
    begin
      try
        RemoteServer := f_SocketConnection;
        ProviderName := f_sProvideName;

        Params.Clear;
        params.CreateParam(ftString, f_sParam, ptinput);
        CommandText := ' select * from ' + f_sTableName + ' ' +
          ' where ' + f_sParam + '=:' + f_sParam + ' and rownum=1 ';
        Params.parambyname(f_sParam).asstring := f_sData;
        open;

        G_getFieldsData(Fields, f_tsParam, f_tsData);

        close;
      finally
        free;
      end;
    end;
    result := true;
  except
  end;
end;

function G_getFieldsData(f_Fields: TFields; var f_tsParam, f_tsData: tstrings): boolean;
var i: integer;
begin
  result := false;
  try
    for i := 1 to f_Fields.Count do
    begin
      if f_tsParam.IndexOf(Uppercase(f_Fields.Fields[i - 1].FieldName)) < 0 then
      begin
        f_tsParam.Add(UpperCase(f_Fields.Fields[i - 1].FieldName));
        f_tsData.add(f_Fields.Fields[i - 1].AsString);
      end;
    end;
    result := true;
  except
  end;
end;

function G_getSNData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sSN: string; var f_tsParam, f_tsData: tstrings): boolean;
var sTable: string;
  sParam: string;
  sData: string;
begin
  result := false;
  try
    f_tsData.clear;
    f_tsParam.clear;

    sTable := 'sajet.g_sn_status';
    sParam := 'serial_number';
    sData := f_sSN;
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    G_deleteParamData('MODEL_ID', f_tsParam, f_tsData);
    G_deleteParamData('CUSTOMER_ID', f_tsParam, f_tsData);

    sParam := 'work_order';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getWOData(f_SocketConnection, f_sProvideName, sData, f_tsParam, f_tsData) then exit;

    sTable := 'sajet.sys_pdline';
    sParam := 'PDLINE_ID';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sTable := 'SAJET.SYS_STAGE';
    sParam := 'STAGE_ID';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sTable := 'SAJET.SYS_PROCESS';
    sParam := 'PROCESS_ID';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sTable := 'SAJET.SYS_TERMINAL';
    sParam := 'TERMINAL_ID';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;
    result := true;
  except
  end;
end;

function G_getBoxNoData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sBoxNO: string; var f_tsParam, f_tsData: tstrings): boolean;
var iCount: integer; sTable, sParam, sData: string; m_tsCSN: TStringList;
begin
  result := false;
  try
    m_tsCSN := TStringList.create;
    with TClientDataSet.Create(Application) do
    begin
      try
        RemoteServer := f_SocketConnection;
        ProviderName := f_sProvideName;

        Params.Clear;
        params.CreateParam(ftString, 'box_no', ptinput);
        CommandText := ' select * from sajet.g_sn_status ' +
          ' where box_no=:box_no ' +
          ' order by serial_number ';
        Params.ParamByName('box_no').asstring := f_sBoxNO;
        open;
        first;

        //先取得第一筆sn的基本資料
        if not G_getFieldsData(Fields, f_tsParam, f_tsData) then exit;

        G_deleteParamData('MODEL_ID', f_tsParam, f_tsData);
        G_deleteParamData('CUSTOMER_ID', f_tsParam, f_tsData);

        sParam := 'work_order';
        sData := G_getParamData(f_tsParam, f_tsData, sParam);
        if not G_getWOData(f_SocketConnection, f_sProvideName, sData, f_tsParam, f_tsData) then exit;

        sTable := 'sajet.sys_pdline';
        sParam := 'PDLINE_ID';
        sData := G_getParamData(f_tsParam, f_tsData, sParam);
        if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

        sTable := 'SAJET.SYS_STAGE';
        sParam := 'STAGE_ID';
        sData := G_getParamData(f_tsParam, f_tsData, sParam);
        if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

        sTable := 'SAJET.SYS_PROCESS';
        sParam := 'PROCESS_ID';
        sData := G_getParamData(f_tsParam, f_tsData, sParam);
        if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

        sTable := 'SAJET.SYS_TERMINAL';
        sParam := 'TERMINAL_ID';
        sData := G_getParamData(f_tsParam, f_tsData, sParam);
        if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

        //記錄下Box的count
        iCount := 0;
        while not eof do
        begin
          inc(iCount);
          f_tsParam.Add(cSNTitle + inttostr(iCount));
          f_tsData.Add(fieldbyname('serial_number').AsString);
          m_tsCSN.Add(fieldbyname('customer_sn').AsString);
          next;
        end;
        f_tsParam.Add(UpperCase(cBoxCount));
        f_tsData.Add(inttostr(iCount));
        close;
        m_tsCSN.Sort;
        for iCount := 0 to m_tsCSN.Count - 1 do
        begin
          f_tsParam.Add(cCSNTitle + inttostr(iCount + 1));
          f_tsData.Add(m_tsCSN[iCount]);
        end;
      finally
        m_tsCSN.Free;
        free;
      end;
    end;
    result := true;
  except
  end;
end;

function G_getCartonNoData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sCartonNO: string; var f_tsParam, f_tsData: tstrings): boolean;
var iCount: integer; m_tsCSN, m_tsBox: TStringList;
  sTable, sParam, sData: string;
begin
  result := false;
  try
    m_tsBox := TStringList.create;
    m_tsCSN := TStringList.create;
    with TClientDataSet.Create(Application) do
    begin
      try
        RemoteServer := f_SocketConnection;
        ProviderName := f_sProvideName;

        Params.Clear;
        params.CreateParam(ftString, 'carton_no', ptinput);
        CommandText := ' select * from sajet.g_sn_status ' +
          ' where carton_no=:carton_no ' +
          ' order by serial_number ';
        Params.ParamByName('carton_no').asstring := f_sCartonNO;
        open;

        first;
        //先取得第一筆sn的基本資料
        if not G_getFieldsData(Fields, f_tsParam, f_tsData) then exit;

        G_deleteParamData('MODEL_ID', f_tsParam, f_tsData);
        G_deleteParamData('CUSTOMER_ID', f_tsParam, f_tsData);

        sParam := 'work_order';
        sData := G_getParamData(f_tsParam, f_tsData, sParam);
        if not G_getWOData(f_SocketConnection, f_sProvideName, sData, f_tsParam, f_tsData) then exit;

        sTable := 'sajet.sys_pdline';
        sParam := 'PDLINE_ID';
        sData := G_getParamData(f_tsParam, f_tsData, sParam);
        if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

        sTable := 'SAJET.SYS_STAGE';
        sParam := 'STAGE_ID';
        sData := G_getParamData(f_tsParam, f_tsData, sParam);
        if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

        sTable := 'SAJET.SYS_PROCESS';
        sParam := 'PROCESS_ID';
        sData := G_getParamData(f_tsParam, f_tsData, sParam);
        if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

        sTable := 'SAJET.SYS_TERMINAL';
        sParam := 'TERMINAL_ID';
        sData := G_getParamData(f_tsParam, f_tsData, sParam);
        if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

        //記錄下carton的count
        iCount := 0;
        while not eof do
        begin
          inc(iCount);
          f_tsParam.Add(cSNTitle + inttostr(iCount));
          f_tsData.Add(fieldbyname('serial_number').AsString);
          m_tsCSN.Add(fieldbyname('customer_sn').AsString);
          if m_tsBox.IndexOf(fieldbyname('box_no').AsString) = -1 then
            m_tsBox.Add(fieldbyname('Box_No').asstring);
          next;
        end;
        m_tsCSN.Sort;
        for iCount := 0 to m_tsCSN.Count - 1 do
        begin
          f_tsParam.Add(cCSNTitle + inttostr(iCount + 1));
          f_tsData.Add(m_tsCSN[iCount]);
        end;
        m_tsBox.Sort;
        for iCount := 0 to m_tsBox.Count - 1 do
        begin
          f_tsParam.Add(cBoxTitle + inttostr(iCount + 1));
          f_tsData.Add(m_tsBox[iCount]);
        end;
        f_tsParam.Add(UpperCase(cCartonCount));
        f_tsData.Add(inttostr(m_tsBox.Count));
        f_tsParam.Add(UpperCase(cCartonTotal));
        f_tsData.Add(inttostr(m_tsCSN.Count));
        close;
      finally
        m_tsBox.Free;
        m_tsCSN.Free;
        free;
      end;
    end;
    result := true;
  except
  end;
end;

function G_getBCCartonNoData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sCartonNO: string; var f_tsParam, f_tsData: tstrings): boolean;
var sTable, sParam, sData: string;
begin
  result := false;
  try
    sTable := 'SAJET.G_WO_CARTON';
    sParam := 'CARTON_NO';
    sData := f_sCartonNO;
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sParam := 'work_order';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getWOData(f_SocketConnection, f_sProvideName, sData, f_tsParam, f_tsData) then exit;

    result := true;
  except
  end;
end;

function G_getBCData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sType, f_sLabelNO: string; var f_tsParam, f_tsData: tstrings; var sTitle: string): boolean;
var sTable, sParam, sData: string;
begin
  result := false;
  try
    with TClientDataSet.Create(Application) do
    begin
      try
        RemoteServer := f_SocketConnection;
        ProviderName := f_sProvideName;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'label_name', ptInput);
        CommandText := 'select * from sajet.sys_label b '
          + 'where label_name = :label_name and rownum = 1';
        Params.ParamByName('label_name').AsString := f_sType;
        Open;
        sTable := FieldByName('Table_Name').AsString;
        sParam := FieldByName('Field_Name').AsString;
        sTitle := FieldByName('file_name').AsString;
        Close;
      finally
        free;
      end;
    end;
    sData := f_sLabelNO;
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sParam := 'work_order';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getWOData(f_SocketConnection, f_sProvideName, sData, f_tsParam, f_tsData) then exit;

    result := true;
  except
  end;
end;

function G_getBCPalletNoData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sPalletNO: string; var f_tsParam, f_tsData: tstrings): boolean;
var sTable, sParam, sData: string;
begin
  result := false;
  try
    sTable := 'SAJET.G_WO_PALLET';
    sParam := 'PALLET_NO';
    sData := f_sPalletNO;
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sParam := 'work_order';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getWOData(f_SocketConnection, f_sProvideName, sData, f_tsParam, f_tsData) then exit;

    result := true;
  except
  end;
end;

function G_getBCCustomerSNData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sCustomerSN: string; var f_tsParam, f_tsData: tstrings): boolean;
var sTable, sParam, sData: string;
begin
  result := false;
  try
    sTable := 'SAJET.G_WO_CUSTOMER_SN';
    sParam := 'CUSTOMER_SN';
    sData := f_sCustomerSN;
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sParam := 'work_order';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getWOData(f_SocketConnection, f_sProvideName, sData, f_tsParam, f_tsData) then exit;

    result := true;
  except
  end;
end;

function G_getBCWOData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sWO: string; var f_tsParam, f_tsData: tstrings): boolean;
var sTable, sParam, sData: string;
begin
  result := false;
  try
    sTable := 'SAJET.G_WO_BASE';
    sParam := 'WORK_ORDER';
    sData := f_sWO;
    if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

    sParam := 'work_order';
    sData := G_getParamData(f_tsParam, f_tsData, sParam);
    if not G_getWOData(f_SocketConnection, f_sProvideName, sData, f_tsParam, f_tsData) then exit;

    result := true;
  except
  end;
end;

function G_getPalletNoData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sPalletNO: string; var f_tsParam, f_tsData: tstrings): boolean;
var iCount: integer; m_tsCARTON, m_tsSN, m_tsCSN, m_tsBox: TStringList;
  sCarton, sTable, sParam, sData: string;
begin
  result := false;
  try
    f_tsParam.clear;
    f_tsData.clear;

    m_tsCarton := TStringList.create;
    m_tsSN := TStringList.create;
    m_tsCSN := TStringList.create;
    m_tsBox := TStringList.create;
    with TClientDataSet.Create(Application) do
    begin
      try
        RemoteServer := f_SocketConnection;
        ProviderName := f_sProvideName;

        close;
        Params.Clear;
        params.CreateParam(ftString, 'pallet_no', ptinput);
        CommandText := ' select * from sajet.g_sn_status ' +
          ' where pallet_no=:pallet_no ' +
          ' order by carton_no, serial_number ';
        Params.ParamByName('pallet_no').asstring := f_sPalletNO;
        open;
        first;

        if not G_getFieldsData(Fields, f_tsParam, f_tsData) then exit;

        G_deleteParamData('MODEL_ID', f_tsParam, f_tsData);
        G_deleteParamData('CUSTOMER_ID', f_tsParam, f_tsData);

        sParam := 'work_order';
        sData := G_getParamData(f_tsParam, f_tsData, sParam);
        if not G_getWOData(f_SocketConnection, f_sProvideName, sData, f_tsParam, f_tsData) then exit;

        sTable := 'sajet.sys_pdline';
        sParam := 'PDLINE_ID';
        sData := G_getParamData(f_tsParam, f_tsData, sParam);
        if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

        sTable := 'SAJET.SYS_STAGE';
        sParam := 'STAGE_ID';
        sData := G_getParamData(f_tsParam, f_tsData, sParam);
        if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

        sTable := 'SAJET.SYS_PROCESS';
        sParam := 'PROCESS_ID';
        sData := G_getParamData(f_tsParam, f_tsData, sParam);
        if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

        sTable := 'SAJET.SYS_TERMINAL';
        sParam := 'TERMINAL_ID';
        sData := G_getParamData(f_tsParam, f_tsData, sParam);
        if not G_getTableData(f_SocketConnection, f_sProvideName, sTable, sParam, sData, f_tsParam, f_tsData) then exit;

        sCarton := '';
        while not eof do
        begin
{          if (fieldbyname('carton_no').asstring <> sCarton) then
          begin
            if m_tsSN.Count > 0 then
            begin
              f_tsParam.Add(UpperCase(cCartonCount) + '_' + inttostr(m_tsCARTON.Count));
              f_tsData.Add(inttostr(m_tsSN.Count));
              for iCount := 1 to m_tsSN.Count do
              begin
                f_tsParam.Add(cSNTitle + inttostr(m_tsCARTON.Count) + '_' + inttostr(iCount));
                f_tsData.Add(m_tsSN.Strings[iCount - 1]);

                f_tsParam.Add(cCSNTitle + inttostr(m_tsCARTON.Count) + '_' + inttostr(iCount));
                f_tsData.Add(m_tsCSN.Strings[iCount - 1]);
              end;
              for iCount := 1 to m_tsBox.Count do
              begin
                f_tsParam.Add(cBoxTitle + inttostr(m_tsCARTON.Count) + '_' + inttostr(iCount));
                f_tsData.Add(m_tsBox.Strings[iCount - 1]);
              end;
            end;
            m_tsSN.clear;
            m_tsCSN.clear;
            m_tsBox.clear;
            m_tsCARTON.Add(fieldbyname('carton_no').asstring);
            f_tsParam.Add(UpperCase(cCartonTitle) + inttostr(m_tsCARTON.Count));
            f_tsData.Add(fieldbyname('carton_no').asstring);
          end; }
          m_tsSN.Add(fieldbyname('serial_number').asstring);
          m_tsCSN.Add(fieldbyname('Customer_SN').asstring);
          if m_tsBox.IndexOf(fieldbyname('Box_No').asstring) = -1 then
            m_tsBox.Add(fieldbyname('Box_No').asstring);
          if m_tsCarton.IndexOf(fieldbyname('Carton_No').asstring) = -1 then
          begin
            m_tsCARTON.Add(fieldbyname('carton_no').asstring);
            f_tsParam.Add(UpperCase(cCartonTitle) + inttostr(m_tsCARTON.Count));
            f_tsData.Add(fieldbyname('carton_no').asstring);
          end;
//          sCarton := fieldbyname('carton_no').asstring;
          next;
        end;

        //2005/12/15 add
        m_tsSN.Sort;
        for iCount := 0 to m_tsSN.Count - 1 do
        begin
          f_tsParam.Add(cSNTitle + inttostr(iCount + 1));
          f_tsData.Add(m_tsSN[iCount]);
        end;
        m_tsCSN.Sort;
        for iCount := 0 to m_tsCSN.Count - 1 do
        begin
          f_tsParam.Add(cCSNTitle + inttostr(iCount + 1));
          f_tsData.Add(m_tsCSN[iCount]);
        end;
        m_tsBox.Sort;
        for iCount := 0 to m_tsBox.Count - 1 do
        begin
          f_tsParam.Add(cBoxTitle + inttostr(iCount + 1));
          f_tsData.Add(m_tsBox[iCount]);
        end;

{        if m_tsSN.Count > 0 then
        begin
          f_tsParam.Add(UpperCase(cCartonCount) + '_' + inttostr(m_tsCARTON.Count));
          f_tsData.Add(inttostr(m_tsSN.Count));
          for iCount := 1 to m_tsSN.Count do
          begin
            f_tsParam.Add(cSNTitle + inttostr(m_tsCARTON.Count) + '_' + inttostr(iCount));
            f_tsData.Add(m_tsSN.Strings[iCount - 1]);

            f_tsParam.Add(cCSNTitle + inttostr(m_tsCARTON.Count) + '_' + inttostr(iCount));
            f_tsData.Add(m_tsCSN.Strings[iCount - 1]);
          end;
        end;  }

        f_tsParam.Add(cPalletCount);
        f_tsData.add(inttostr(m_tsCARTON.Count));
        f_tsParam.Add(cBoxTotal);
        f_tsData.add(inttostr(m_tsBox.Count));
        f_tsParam.Add(cPalletTotal);
        f_tsData.add(inttostr(m_tsSN.Count));

        close;
      finally
        m_tsSN.free;
        m_tsCSN.free;
        m_tsBox.free;
        m_tsCARTON.free;
        free;
      end;
    end;
    result := true;
  except
  end;
end;


end.

