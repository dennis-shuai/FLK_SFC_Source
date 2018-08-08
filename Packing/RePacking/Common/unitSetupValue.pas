unit unitSetupValue;

interface

uses inifiles;

type
  TSetupValue = record
    bPrintSNLabel : boolean;
    bPrintCartonLabel : boolean;
    bPrintPalletLabel : boolean;
    bPrintCustSNLabel : boolean;
    iQtySNLabel : integer;
    iQtyCartonLabel : integer;
    iQtyPalletLabel : integer;
    iQtyCustSNLabel : integer;
    iQtyUDLabel : integer;
    iCodeSoftVersion : integer;
    sPrintSNMethod : string;
    sSNComPort : string;
    sSNBaudRate : string;
    sPrintCartonMethod : string;
    sCartonComPort : string;
    sCartonBaudRate : string;
    sPrintPalletMethod : string;
    sPalletComPort : string;
    sPalletBaudRate : string;
    sPrintCustSNMethod : string;
    sCustSNComPort : string;
    sCustSNBaudRate : string;
    sPrintUDMethod : string;
    sUDComPort : string;
    sUDBaudRate : string;
    bPrintLabel: Boolean;
    iQtyLabel: Integer;
    sPrintMethod, sComPort, sBaudRate: String;
  end;

  procedure G_LoadSetupValue_BC;
  procedure G_SaveSetupValue_BC;
  procedure G_LoadSetupValue(gsFunction: string);
  procedure G_SaveSetupValue(gsFunction: string);

var SetupValue : TSetupValue;

implementation


const cProgramName = 'BarCode Center';

procedure G_SaveSetupValue(gsFunction: string);
begin
  with TIniFile.Create('SAJET.INI') do begin
    try
      with SetupValue do begin
        WriteInteger(cProgramName,'Code Soft Version',iCodeSoftVersion);
        WriteBool(cProgramName, 'Print ' + gsFunction, bPrintLabel);
        WriteInteger(cProgramName, gsFunction + ' Qty', iQtyLabel);
        WriteString(cProgramName, 'Print ' + gsFunction + ' Method', sPrintMethod);
        WriteString(cProgramName, gsFunction + ' ComPort', sComPort);
        WriteString(cProgramName, gsFunction + ' BaudRate', sBaudRate);
      end;
    finally
      free;
    end;
  end;
end;

procedure G_LoadSetupValue(gsFunction: string);
begin
  with TIniFile.Create('SAJET.INI') do begin
    try
      with SetupValue do begin
        iCodeSoftVersion :=ReadInteger(cProgramName,'Code Soft Version',6);
        if gsFunction = 'User Define' then
          bPrintLabel := True
        else
          bPrintLabel := ReadBool(cProgramName, 'Print ' + gsFunction, false);
        iQtyLabel := ReadInteger(cProgramName, gsFunction + ' Qty', 1);
        sPrintMethod := ReadString(cProgramName, 'Print ' + gsFunction + ' Method', 'CodeSoft');
        sComPort := ReadString(cProgramName, gsFunction + ' ComPort', 'COM1');
        sBaudRate := ReadString(cProgramName, gsFunction + ' BaudRate', '19200');
      end;
    finally
      free;
    end;
  end;
end;

procedure G_LoadSetupValue_BC;
begin
  with TIniFile.Create('SAJET.INI') do begin
    try
      with SetupValue do begin
        bPrintSNLabel :=ReadBool(cProgramName,'Print SN Label',false);
        bPrintCartonLabel :=ReadBool(cProgramName,'Print Carton Label',false);
        bPrintPalletLabel :=ReadBool(cProgramName,'Print Pallet Label',false);
        bPrintCustSNLabel :=ReadBool(cProgramName,'Print Customer SN Label',false);

        iQtySNLabel :=ReadInteger(cProgramName,'SN Label Qty',1);
        iQtyCartonLabel :=ReadInteger(cProgramName,'Carton Label Qty',1);
        iQtyPalletLabel :=ReadInteger(cProgramName,'Pallet Label Qty',1);
        iQtyCustSNLabel :=ReadInteger(cProgramName,'Customer SN Label Qty',1);
        iQtyUDLabel :=ReadInteger(cProgramName,'User Define Label Qty',1);

        iCodeSoftVersion :=ReadInteger(cProgramName,'Code Soft Version',6);

        sPrintSNMethod :=ReadString(cProgramName,'Print SN Method','CodeSoft');
        sSNComPort :=ReadString(cProgramName,'SN ComPort','COM1');
        sSNBaudRate :=ReadString(cProgramName,'SN BaudRate','19200');

        sPrintCartonMethod :=ReadString(cProgramName,'Print Carton Method','CodeSoft');
        sCartonComPort :=ReadString(cProgramName,'Carton ComPort','COM1');
        sCartonBaudRate :=ReadString(cProgramName,'Carton BaudRate','19200');

        sPrintPalletMethod :=ReadString(cProgramName,'Print Pallet Method','CodeSoft');
        sPalletComPort :=ReadString(cProgramName,'Pallet ComPort','COM1');
        sPalletBaudRate :=ReadString(cProgramName,'Pallet BaudRate','19200');

        sPrintCustSNMethod :=ReadString(cProgramName,'Print Customer SN Method','CodeSoft');
        sCustSNComPort :=ReadString(cProgramName,'Customer SN ComPort','COM1');
        sCustSNBaudRate :=ReadString(cProgramName,'Customer SN BaudRate','19200');

        sPrintUDMethod :=ReadString(cProgramName,'Print User Define Method','CodeSoft');
        sUDComPort :=ReadString(cProgramName,'User Define ComPort','COM1');
        sUDBaudRate :=ReadString(cProgramName,'User Define BaudRate','19200');
      end;
    finally
      free;
    end;
  end;
end;


procedure G_SaveSetupValue_BC;
begin
  with TIniFile.Create('SAJET.INI') do begin
    try
      with SetupValue do begin
        WriteBool(cProgramName,'Print SN Label',bPrintSNLabel);
        WriteBool(cProgramName,'Print Carton Label',bPrintCartonLabel);
        WriteBool(cProgramName,'Print Pallet Label',bPrintPalletLabel);
        WriteBool(cProgramName,'Print Customer SN Label',bPrintCustSNLabel);

        WriteInteger(cProgramName,'SN Label Qty',iQtySNLabel);
        WriteInteger(cProgramName,'Carton Label Qty',iQtyCartonLabel);
        WriteInteger(cProgramName,'Pallet Label Qty',iQtyPalletLabel);
        WriteInteger(cProgramName,'Customer SN Label Qty',iQtyCustSNLabel);
        WriteInteger(cProgramName,'User Define Label Qty',iQtyUDLabel);
        WriteInteger(cProgramName,'Code Soft Version',iCodeSoftVersion);

        WriteString(cProgramName,'Print SN Method',sPrintSNMethod);
        WriteString(cProgramName,'SN ComPort',sSNComPort);
        WriteString(cProgramName,'SN BaudRate',sSNBaudRate);

        WriteString(cProgramName,'Print Carton Method',sPrintCartonMethod);
        WriteString(cProgramName,'Carton ComPort',sCartonComPort);
        WriteString(cProgramName,'Carton BaudRate',sCartonBaudRate);

        WriteString(cProgramName,'Print Pallet Method',sPrintPalletMethod);
        WriteString(cProgramName,'Pallet ComPort',sPalletComPort);
        WriteString(cProgramName,'Pallet BaudRate',sPalletBaudRate);

        WriteString(cProgramName,'Print Customer SN Method',sPrintCustSNMethod);
        WriteString(cProgramName,'Customer SN ComPort',sCustSNComPort);
        WriteString(cProgramName,'Customer SN BaudRate',sCustSNBaudRate);

        WriteString(cProgramName,'Print User Define Method',sPrintUDMethod);
        WriteString(cProgramName,'User Define ComPort',sUDComPort);
        WriteString(cProgramName,'User Define BaudRate',sUDBaudRate);
      end;
    finally
      free;
    end;
  end;
end;

end.
