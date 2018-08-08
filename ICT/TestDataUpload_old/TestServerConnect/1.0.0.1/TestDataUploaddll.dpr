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
  Windows,SysUtils, Classes, DB, IniFiles, ADODB;

{$R *.res}


var sktConn: TADOConnection;
Ados_InsertData: TADOStoredProc;


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


function ConnectServer:PChar;stdcall;
var iniFile:TIniFile;
sfileName,connStr:string;
begin
   sfileName := ExtractFilePath(ParamStr(0))+'Config.ini';

   if FileExists(sfileName) then
   begin
      iniFile :=  TIniFile.Create(sfileName);
      connStr := iniFile.ReadString('DataServ','StrConnServer','');
      iniFile.Free;
      if connStr = '' then begin
          Result := PChar('NG;找不到文件 '+ sfileName);
          Exit;
      end;
   end else begin
       Result := 'NG;找不到文件 Config.ini';
       Exit;
   end;

   try
       sktConn := TADOConnection.Create(nil);
       sktConn.Close;
       sktConn.ConnectionString := connStr;
       sktConn.ConnectionTimeout := 15;
       sktConn.LoginPrompt :=False;
       sktConn.Connected := True;
   except
         Result := 'NG;連接測試數據庫失敗';
         Exit;
   end;

   Result := 'OK';

end;

function UploadDataOnly(Model,Process,path,Data:PChar):PChar;stdcall;
var i,iTitleCount,iDataCount:Integer;
sFirst,sSN,sModel,sProcess,sPath,sResult,stemp:string;
ItemStr:array [1..150] of string;
strs,slTitle,slData:TStrings;
begin


    if  path ='' then begin
        Result :=  '保存測試數據時,測試Log檔案路徑為空值';
        Exit;
    end;

    sPath := path;
    if not FileExists(sPath) then
    begin
        Result :=  'NG;找不到測試Log檔';
        Exit;
    end;

    if  Model ='' then begin
        Result :=  '保存測試數據時,Model為空值';
        Exit;
    end;

    if  Process ='' then begin
         Result :=  '保存測試數據時,Process為空值';
         Exit;
    end;

    if  Data ='' then begin
         Result := '保存測試數據時,測試數據為空值';
    end;

    Ados_InsertData := TADOStoredProc.Create(nil);
    Ados_InsertData.Connection :=sktConn;
    Ados_InsertData.ProcedureName :='SaveTestFile108_3;1';
    Ados_InsertData.Parameters.CreateParameter('@ReturnValue',ftInteger,pdReturnValue,0,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@SerialCode',ftString,pdInput,30,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@Model',ftString,pdInput,30,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@WorkOrder',ftString,pdInput,8,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@StationName',ftString,pdInput,50,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@UserID',ftString,pdInput,50,varEmpty) ;
    for i:=1 to 150 do
      Ados_InsertData.Parameters.CreateParameter('@Item'+IntToStr(i),ftString,pdInput,50,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@OutFlag',ftInteger,pdInputOutput,0,varEmpty) ;
    Ados_InsertData.Parameters.CreateParameter('@Message',ftString,pdInputOutput,100,varEmpty);
    try
        strs :=TStringList.Create;
        strs.LoadFromFile(path);
        sFirst := strs.Strings[0];
        if sFirst = '' then begin
            Result := 'NG;找不到項目抬頭';
            Exit;
        end;

        slTitle := TStringList.Create;
        slTitle.Delimiter := #9;
        slTitle.DelimitedText :=sFirst;
        iTitleCount := slTitle.Count;


        slData := TStringList.Create;
        slData.Delimiter := #9;
        slData.DelimitedText :=Data;
        iDataCount := slData.Count;
        sSN := slData.Strings[0];
        if sSN ='' then begin
            slTitle.Free;
            slData.Free;
            strs.Free;
            Result :='NG;條碼為空,數據不保存';
            Exit;
        end;
    except
        slTitle.Free;
        slData.Free;
        strs.Free;
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
    sModel := Model;
    sProcess :=Process;
    Ados_InsertData.Parameters.ParamValues['@serialCode']:=sSN;
    Ados_InsertData.Parameters.ParamValues['@Model']:=sModel;
    Ados_InsertData.Parameters.ParamValues['@WorkOrder']:='';
    Ados_InsertData.Parameters.ParamValues['@StationName']:=sProcess;
    Ados_InsertData.Parameters.ParamValues['@UserID']:= GetComputer;
    for  I:=1 to 150 do
      Ados_InsertData.Parameters.ParamValues['@Item'+IntToStr(i)]:=ItemStr[i];
    Ados_InsertData.ExecProc;

    if Ados_InsertData.Parameters.ParamValues['@outFlag']=0 then begin
         sResult := Ados_InsertData.Parameters.ParamValues['@Message'];
         Result :=PChar('NG;'+sResult);
         Exit;
    end;
    
    Result :='OK';

end;

function CloseConnect:Boolean;stdcall;
begin
   try
      if Ados_InsertData <> nil then
         Ados_InsertData.Free;
      if sktConn <> nil then begin
          sktConn.Close;
          sktConn.Free;
      end;
   except
       Result :=false;
       Exit;
   end;
   Result :=True;

end;

function ConnAndUploadData(Model,Process,path,Data:PChar):PChar;stdcall;
var IsConnect:Boolean;
    sResult:PChar;
begin
     sResult :=ConnectServer;
     if Copy(sResult,1,2) <>'OK' then
     begin
       Result := sResult;
       Exit;
     end;
     sResult := UploadDataOnly(Model,Process,path,Data);
     if Copy(sResult,1,2) <>'OK' then
     begin
       Result := sResult;
       Exit;
     end;

     if CloseConnect then
        Result :='OK'
     else
       Result :='NG;不能關閉連接';
end;

exports
ConnectServer,
UploadDataOnly,
CloseConnect,
ConnAndUploadData;

begin
end.
