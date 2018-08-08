library TestDataUploaddll;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
   Windows,SysUtils, Classes, DB, IniFiles, ADODB,ComObj,WinSock,ActiveX;

{$R *.res}



var sktConn: TADOConnection;
Ados_InsertData: TADOStoredProc;
RGB_Config,IR_Config,Normal_Config,sModel,sPath,sLightBox :string;
slogFile:string;



Function GetComputer:String;
   var  Buffer:Pchar;
        BufferLen:DWORD;
        StrName:String;
begin
   BufferLen:=  MAX_COMPUTERNAME_LENGTH+1 ;
   GetMem(Buffer,BufferLen);
   GetComputerName(Buffer,BufferLen);
   StrName:=StrPas(Buffer);
   FreeMem(Buffer,BufferLen);
   Result:=StrName;
end;

function GetIP: string;
type
    TaPInAddr = array[0..10] of PInAddr;
    PaPInAddr = ^TaPInAddr;
var
    phe: PHostEnt;
    pptr: PaPInAddr;
    Buffer: array[0..63] of Char;
    i: Integer;
    GInitData: TWSAData;
    sResult:TStringList;
    ipCount:Integer;
begin
    Result:='';
    WSAStartup($101, GInitData);
    sResult := TstringList.Create;
    sResult.Clear;
    GetHostName(Buffer, SizeOf(Buffer));
    phe := GetHostByName(buffer);
    if phe = nil then Exit;
    pPtr := PaPInAddr(phe^.h_addr_list);
    i:= 0;
    while pPtr^[i] <> nil do
    begin 
      sResult.Add(inet_ntoa(pptr^[i]^));
      Inc(i); 
    end;
    WSACleanup;
    ipCount:=i;
    for i:=0 to ipCount-1 do
    begin
      //if Copy(sResult[i],1,11)='192.168.80.' then
      if Copy(sResult[i],1,5)='172.1' then
          Result:= sResult[i];
    end;


end;



function CloseConnect:Boolean;
begin
   try
      if Assigned(Ados_InsertData )  then
      begin
         Ados_InsertData.Free;
         Ados_InsertData :=nil;
      end;

      if Assigned(sktConn ) then
      begin
          sktConn.Close;
          sktConn.Free;
          sktConn :=nil;
      end;
      CoUninitialize;
   Except
       Result :=false;
       Exit;
   end;
   Result :=True;

end;

function ConnectServer:string;
var iniFile:TIniFile;
sfileName,connStr:string;
begin
   sfileName := ExtractFilePath(ParamStr(0))+'SFCS_Config.ini';

   if FileExists(sfileName) then
   begin
      iniFile :=  TIniFile.Create(sfileName);
      connStr := iniFile.ReadString('DataServ','StrConnServer','');
      RGB_Config :=  iniFile.ReadString('WorkOrder','RGB_CONFIG','');
      IR_Config :=  iniFile.ReadString('WorkOrder','IR_CONFIG','');
      Normal_Config := iniFile.ReadString('WorkOrder','NORMAL_CONFIG','');
      sModel := iniFile.ReadString('WorkOrder','Model','');
      sLightBox := iniFile.ReadString('TestLogFile','LightBox','');
      sPath := iniFile.ReadString('TestLogFile','LogFilePath','');
      iniFile.Free;
      if connStr = '' then begin
          Result := 'NG;找不到連接字串';
         //CloseConnect;
          Exit;
      end;
      if sPath ='' then begin
         sPath :=ExtractFilePath(ParamStr(0))+'log\';

         if not DirectoryExists(sPath) then begin
             Result := 'NG;找不到測試Log路徑';
             Exit;
         end;
      end else begin
         if not DirectoryExists(sPath) then begin
             sPath :=  ExtractFilePath(ParamStr(0))+'Log\';
             if not DirectoryExists(sPath) then begin
                 Result := 'NG;找不到測試Log路徑';
                 Exit;
             end;
         end;
      end;


   end else begin
       Result := 'NG;找不到文件 SFCS_Config.ini';
       Exit;
   end;


   try
       if not Assigned(sktConn) then
          sktConn := TADOConnection.Create(nil);
       sktConn.Close;
       sktConn.ConnectionString := connStr;
       sktConn.ConnectionTimeout := 15;
       sktConn.LoginPrompt :=False;
       sktConn.Connected := True;

   except
         Result := 'NG;連接測試數據庫失敗';
         CloseConnect;
         Exit;
   end;

   Result := 'OK';

end;

function UploadDataOnly(Model,Path,CfgFile_Name,SN:string):string;
var i,j,iTitleCount,iDataCount:Integer;
sFirst,sSN,sModel,sProcess,sPath,sResult,stemp,sFileName,sData,FilePathTestConfig:string;
CONF_MODEL,CONF_LIGHTBOX,CONF_FIXTURE,CONF_LIGHTPANEL,StationCode,mDate:string;
ItemStr:array [1..150] of string;
strs,slTitle,slData:TStrings;
FpOpen: TextFile;
begin
    if not Assigned(Ados_InsertData) then
       Ados_InsertData := TADOStoredProc.Create(nil);
    Ados_InsertData.Connection :=sktConn;
    Ados_InsertData.ProcedureName :='SaveTestFile108_3;1';
    Ados_InsertData.Parameters.Clear;
    Ados_InsertData.Parameters.CreateParameter('@ReturnValue',ftInteger,pdReturnValue,0,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@SerialCode',ftString,pdInput,30,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@Model',ftString,pdInput,30,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@WorkOrder',ftString,pdInput,30,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@StationName',ftString,pdInput,50,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@UserID',ftString,pdInput,50,varEmpty) ;
    for i:=1 to 150 do
      Ados_InsertData.Parameters.CreateParameter('@Item'+IntToStr(i),ftString,pdInput,50,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@OutFlag',ftInteger,pdInputOutput,0,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@Message',ftString,pdInputOutput,100,varEmpty);


    mDate:=FormatDateTime('YYYY_MM_DD',Now);
    if  path ='' then begin
        Result :=  '保存測試數據時,測試Log檔案路徑為空值';
        Exit;
    end;

    FilePathTestConfig:= ExtractFilePath(ParamStr(0)) + CfgFile_Name+'.txt';
    if not FileExists(FilePathTestConfig) then
    begin
       Result := 'NG;找不到測試程式Config文件'+FilePathTestConfig;
       Exit;
    end;

    AssignFile(FpOpen, FilePathTestConfig);
    Reset(FpOpen);
    while not EOF(FpOpen)do
    begin
        Readln(FpOpen,sTemp);
        if trim(sTemp)<>'' then
        begin
            strs := TStringList.Create;
            strs.Delimiter := ' ';
            strs.DelimitedText := sTemp;
            i:=0;
            j:=1;
            if Strs[i]='CONF_PROJECT_NAME(CHAR)' then
                CONF_MODEL:=Strs[j]
            ELSE if Strs[i]='CONF_STATION_SN(CHAR)' then
                CONF_LIGHTBOX:=Strs[j]
            else if Strs[i]='CONF_FIXTURE_SN(CHAR)' then
                CONF_FIXTURE:=Strs[j]
            else if Strs[i]='CONF_LIGHTPANEL_SN(CHAR)' then
                CONF_LIGHTPANEL:=Strs[j]
             else if Strs[i]='CONF_CELL_INFO(CHAR)' then
                StationCode:=Strs[j];
            strs.Free;
        end;
    end;
    CloseFile(FpOpen);

    sFileName := CONF_MODEL+'_'+mDate+'_'+StationCode+'_'+CONF_LIGHTBOX+'_'+CONF_FIXTURE+'_'+CONF_LIGHTPANEL+'.txt';
    sPath := path;
    sPath := sPath+sFileName;
    if not FileExists(sPath) then
    begin
        Result :=  'NG;找不到測試Log檔:'+sPath;
        Exit;
    end;

    if  CONF_MODEL ='' then begin
        Result :=  '測試Config中機種名為空';
        Exit;
    end;


    try
        strs :=TStringList.Create;
        strs.LoadFromFile(sPath);
        sFirst := strs.Strings[0];
        if sFirst = '' then begin
            Result := 'NG;找不到項目抬頭';
            strs.Free;
            Exit;
        end;

        slTitle := TStringList.Create;
        slTitle.Delimiter := #9;
        slTitle.DelimitedText :=sFirst;
        iTitleCount := slTitle.Count;

        sData :=  strs.Strings[strs.Count-1];
        slData := TStringList.Create;
        slData.Delimiter := #9;
        slData.DelimitedText := sData;
        iDataCount := slData.Count;
        sSN := slData.Strings[0];
        if sSN <> SN then begin
            slTitle.Free;
            slData.Free;
            strs.Free;
            Result := 'NG;測試Log檔案存儲的條碼('+sSN+')+和測試的條碼('+sn+')不對';
            Exit;
        end;

        if sSN ='' then begin
            slTitle.Free;
            slData.Free;
            strs.Free;
            Result :='NG;條碼為空,數據不保存';
            Exit;
        end;
    except
        if Assigned(slTitle) then slTitle.Free;
        if Assigned(slData) then slData.Free;
        if Assigned(strs) then strs.Free;
        Result :='NG;解析數據錯誤';
        Exit;
    end;

    if iDataCount <> iTitleCount then
    begin
       slTitle.Free;
       slData.Free;
       strs.Free;
       Result :='NG;項目抬頭數不等於測試記錄項目數';
       Exit;
    end;

    if  iDataCount > 151 then begin
       slTitle.Free;
       slData.Free;
       strs.Free;
       Result :='NG;測試數值項目大於150項，資料庫無法保存';
       Exit;
    end;

    for i:= 1 to iDataCount-1 do
       ItemStr[i] := slTitle[i] +':'+slData[i];
    slTitle.Free;
    slData.Free;
    strs.Free;

    Ados_InsertData.Parameters.ParamValues['@serialCode']:=sSN;
    Ados_InsertData.Parameters.ParamValues['@Model']:=CONF_MODEL;
    Ados_InsertData.Parameters.ParamValues['@WorkOrder']:='LightBox:'+sLightBox;
    Ados_InsertData.Parameters.ParamValues['@StationName']:=StationCode;
    Ados_InsertData.Parameters.ParamValues['@UserID']:= GetComputer+'@'+GetIP;
    for  I:=1 to 150 do
      Ados_InsertData.Parameters.ParamValues['@Item'+IntToStr(i)]:=ItemStr[i];
    Ados_InsertData.ExecProc;

    if Ados_InsertData.Parameters.ParamValues['@outFlag']=0 then begin
         sResult := Ados_InsertData.Parameters.ParamValues['@Message'];
         Result :='NG;'+sResult;
         Exit;
    end;
    Ados_InsertData.Close;
    Result :='OK';

end;


function SFISDoubleATUploadData(f_pData,f_pLen:Pointer):Boolean;stdcall;
var
sResult,SN:string;
i,iLen:Integer;
begin
     Coinitialize(nil);

     sResult :=ConnectServer;

     if Copy(sResult,1,2) <>'OK' then
     begin
         result := false;
         iLen := Length(sResult);
         PInteger(f_pLen)^ := iLen;
         StrCopy(f_pData,PChar(sResult));
         CloseConnect;
         Exit;
     end;

     SN := PChar(f_pData);
     iLen := PInteger(f_pLen)^;
     SetLength(SN,iLen);
     sResult := UploadDataOnly(sModel,sPath,RGB_Config,SN);

     if Copy(sResult,1,2) <> 'OK' then
     begin
         result := false;
         iLen := Length(sResult);
         PInteger(f_pLen)^ := iLen;
         StrCopy(f_pData,PChar(sResult));
         CloseConnect;
         Exit;
     end;

     sResult := UploadDataOnly(sModel,sPath,IR_Config,SN);

     if Copy(sResult,1,2) <> 'OK' then
     begin
         result := false;
         iLen := Length(sResult);
         PInteger(f_pLen)^ := iLen;
         StrCopy(f_pData,PChar(sResult));
         CloseConnect;
         Exit;
     end;

     sResult :='OK';
     iLen := Length(sResult);
     PInteger(f_pLen)^ := iLen;
     StrCopy(f_pData,PChar(sResult));
     
     CloseConnect;
     Result := True;

end;


function SFISATUploadData(f_pData,f_pLen:Pointer):Boolean;stdcall;
var
sResult,SN:string;
i,iLen:Integer;
begin
     Coinitialize(nil);
     sResult :=ConnectServer;

     if Copy(sResult,1,2) <>'OK' then
     begin
         result := false;
         iLen := Length(sResult);
         PInteger(f_pLen)^ := iLen;
         StrCopy(f_pData,PChar(sResult));
         CloseConnect;
         Exit;
     end;

     SN := PChar(f_pData);
     iLen := PInteger(f_pLen)^;
     SetLength(SN,iLen);
     
     sResult := UploadDataOnly(sModel,sPath,Normal_Config,SN);

     if Copy(sResult,1,2) <> 'OK' then
     begin
         result := false;
         iLen := Length(sResult);
         PInteger(f_pLen)^ := iLen;
         StrCopy(f_pData,PChar(sResult));
         CloseConnect;
         Exit;
     end;

     CloseConnect;
     sResult :='OK';
     iLen := Length(sResult);
     PInteger(f_pLen)^ := iLen;
     StrCopy(f_pData,PChar(sResult));
     CloseConnect;

     Result := True;
     //CoUninitialize;
end;


function UploadStringData(Model,Process,strTitle,SN,strData:string;colCount:Integer):string;
var i,j,iTitleCount,iDataCount:Integer;
ItemStr:array [1..150] of string;
slTitle,slData:TStrings;
sResult:string;
begin
    if strTitle = '' then begin
        Result := 'NG;找不到項目抬頭';
        Exit;
    end;
    if strTitle = '' then begin
        Result := 'NG;找不到資料';
        Exit;
    end;
    if colCount = 0 then begin
        Result := 'NG;總欄位數量為0';
        Exit;
    end;
    if Model = '' then begin
        Result := 'NG;找不到機種名稱';
        Exit;
    end;
    if Process = '' then begin
        Result := 'NG;找不到站別名稱';
        Exit;
    end;

    try

        slTitle := TStringList.Create;
        slTitle.Delimiter := ';';
        slTitle.DelimitedText :=strTitle;
        iTitleCount := slTitle.Count;
        if iTitleCount <> colCount then
        begin
            Result := 'NG;項目抬頭數量'+IntToStr(iTitleCount)+'不等於'+IntToStr(colCount);
            if Assigned(slTitle) then slTitle.Free;
            if Assigned(slData) then slData.Free;
            exit;
        end;

        slData := TStringList.Create;
        slData.Delimiter := ';';
        slData.DelimitedText := strData;
        iDataCount := slData.Count;

        if iDataCount <> colCount then begin
            Result := 'NG;資料欄位數量'+IntToStr(iTitleCount)+'不等於'+IntToStr(colCount);
            if Assigned(slTitle) then slTitle.Free;
            if Assigned(slData) then slData.Free;
            exit;
        end;

        if  iDataCount > 151 then begin
           if Assigned(slTitle) then slTitle.Free;
           if Assigned(slData) then slData.Free;
           Result :='NG;測試數值項目大於150項，資料庫無法保存';
           Exit;
        end;

    except
        if Assigned(slTitle) then slTitle.Free;
        if Assigned(slData) then slData.Free;
        Result :='NG;解析數據錯誤';
        Exit;
    end;

    for i:= 1 to iDataCount-1 do
       ItemStr[i] := slTitle[i] +':'+slData[i];
    slTitle.Free;
    slData.Free;

    if not Assigned(Ados_InsertData) then
       Ados_InsertData := TADOStoredProc.Create(nil);
    Ados_InsertData.Connection :=sktConn;
    Ados_InsertData.ProcedureName :='SaveTestFile108_3;1';
    Ados_InsertData.Parameters.Clear;
    Ados_InsertData.Parameters.CreateParameter('@ReturnValue',ftInteger,pdReturnValue,0,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@SerialCode',ftString,pdInput,30,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@Model',ftString,pdInput,30,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@WorkOrder',ftString,pdInput,30,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@StationName',ftString,pdInput,50,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@UserID',ftString,pdInput,50,varEmpty) ;
    for i:=1 to 150 do
      Ados_InsertData.Parameters.CreateParameter('@Item'+IntToStr(i),ftString,pdInput,50,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@OutFlag',ftInteger,pdInputOutput,0,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@Message',ftString,pdInputOutput,100,varEmpty);

    Ados_InsertData.Parameters.ParamValues['@serialCode']:=SN;
    Ados_InsertData.Parameters.ParamValues['@Model']:=Model;
    Ados_InsertData.Parameters.ParamValues['@WorkOrder']:='LightBox:'+sLightBox;
    Ados_InsertData.Parameters.ParamValues['@StationName']:=Process;
    Ados_InsertData.Parameters.ParamValues['@UserID']:= GetComputer+'@'+GetIP;
    for  I:=1 to 150 do
      Ados_InsertData.Parameters.ParamValues['@Item'+IntToStr(i)]:=ItemStr[i];
    Ados_InsertData.ExecProc;

    if Ados_InsertData.Parameters.ParamValues['@outFlag']=0 then begin
         sResult := Ados_InsertData.Parameters.ParamValues['@Message'];
         Result :=PChar('NG;'+sResult);
         Exit;
    end;
    Ados_InsertData.Close;
    Result :='OK';
end;

function SplitString(Source, Deli: string ): TStringList;
var 
  EndOfCurrentString: byte;
  StringList:TStringList;
begin
    StringList:=TStringList.Create;
    while Pos(Deli, Source)>0 do 
    begin
        EndOfCurrentString := Pos(Deli, Source);
        StringList.add(Copy(Source, 1, EndOfCurrentString - 1));
        Source := Copy(Source, EndOfCurrentString + length(Deli), length(Source) - EndOfCurrentString);
    end;
    Result := StringList;
    StringList.Add(source);
end;


function SFISATUploadStringData(f_pData,f_pLen:Pointer):Boolean;stdcall;
var
sResult,sAllData,SN,sProcess,sStrTitle,sStrData:string;
i,iLen,iColCount:Integer;
slData:TStringList;
begin
     Coinitialize(nil);
     sResult :=ConnectServer;

     if Copy(sResult,1,2) <>'OK' then
     begin
         result := false;
         iLen := Length(sResult);
         PInteger(f_pLen)^ := iLen;
         StrCopy(f_pData,PChar(sResult));
         CloseConnect;
         Exit;
     end;

     sAllData := PChar(f_pData);
     iLen := PInteger(f_pLen)^;
     SetLength(sAllData,iLen);

     try
         slData := TStringList.Create;
         slData := SplitString(sAllData,'==O==');
         sModel := slData.Strings[0];
         sProcess := slData.Strings[1];
         iColCount :=  StrToIntDef(slData.Strings[3],0);
         sStrTitle :=  slData.Strings[2];
         sStrData :=  slData.Strings[4];
         slData.Free;
     except
        if Assigned(slData) then
             slData.Free;

         sResult := '資料格式錯誤:'+sAllData;
         result := false;
         iLen := Length(sResult);
         PInteger(f_pLen)^ := iLen;
         StrCopy(f_pData,PChar(sResult));
         CloseConnect;
         Exit;
     end;

     sResult := UploadStringData(sModel,sProcess,sStrTitle,SN,sstrData,iColCount);
     if Copy(sResult,1,2) <> 'OK' then
     begin
         result := false;
         iLen := Length(sResult);
         PInteger(f_pLen)^ := iLen;
         StrCopy(f_pData,PChar(sResult));
         CloseConnect;
         Exit;
     end;

     CloseConnect;
     sResult :='OK';
     iLen := Length(sResult);
     PInteger(f_pLen)^ := iLen;
     StrCopy(f_pData,PChar(sResult));
     CloseConnect;

     Result := True;
     //CoUninitialize;
end;

exports
SFISDoubleATUploadData,
SFISATUploadData;

begin
end.
