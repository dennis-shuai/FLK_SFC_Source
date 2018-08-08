unit unitDriverLink;

interface

uses classes,windows,sysutils,forms,unitLog,unitDriverDeclare,unitConvert,dialogs;

type
  TDriverLink=class(TComponent)
  private
    m_sDLLName : string;                        //已LINK的DRIVER名稱
    m_DLLHandle : THandle;                      //LINK DRIVER的HANDLE
    m_bDllLink : boolean;                       //DLL是否已LINK OK
    m_addLog : TOnAddLog;                       //用來記錄的FUNCTION
    m_CSDriver : TRTLCriticalSection;           //用來防止同一時間內有人同時要送資料給同一個DRIVER

    { Driver 的FUNCTION }
    m_SetupValue : TSajet_SetupValue;
    m_Get_Gateway_Info : TSajet_Get_Gateway_Info;
    m_Get_Port_Info : TSajet_Get_Port_Info;
    m_setup_Gateway : TSajet_setup_Gateway;
    m_Open_Gateway : TSajet_Open_Gateway ;
    m_close_Gateway : TSajet_close_Gateway;
    m_Send_Data : TSajet_Send_Data;
    m_Check_Setup : TSajet_Check_Setup;
    function LinkDriver(f_sDLLName:string) : boolean;
    procedure addLog(f_LogType: TLogType;f_sMessage:string);
  public
    //Driver的FUNCTION
    function Get_Gateway_Info(var f_Gateway_Information : TGateway_Information) : integer;
    function Get_Port_Info(f_iOrder:integer;var f_Port_Information:TPort_Information) : integer ;
    function setup_Gateway(f_pSetupValue :pchar;var f_iCount : integer) : integer;
    function Check_Setup(f_pSetupValue,f_pSetupOther :pchar) : integer;
    function Open_Gateway(f_iGID : integer;f_pSetupValue:pchar;f_OnReceiveData : TOnTransData ): integer;
    function close_Gateway (f_iGID : integer) : integer;
    function Send_Data(f_iMsgType,f_iGID,f_iSubID,f_iPort,f_iBuzz:integer;f_pData:pchar;f_iLen:integer) : integer ;

    constructor create(AOwner : TComponent;f_addLog:TOnAddLog);
    destructor Destroy; override;
    function initialize(f_sDLLName:string) : boolean;
    function getDriverName : string;
  end;

implementation

//=========================================================================================
function TDriverLink.Get_Gateway_Info(var f_Gateway_Information : TGateway_Information) : integer;
begin
  try
    if m_bDllLink and (@m_Get_Gateway_Info<>nil) then begin
      Result:=m_Get_Gateway_Info(f_Gateway_Information);
      if Result=cResultok then addLog(cLogNormal,'('+ClassName+'.Get_Gateway_Info)  OK')
      else addLog(cLogError,'('+ClassName+'.Get_Gateway_Info) Fail ('+inttostr(result)+')');
    end
    else begin
      Result:=cResultDriverLinkFail;
      addLog(cLogError,'('+ClassName+'.Get_Gateway_Info)'+'Unlink Driver');
    end;
  except
    on E:Exception do begin
      result:=cResultError;
      addLog(cLogError,'('+ClassName+'.Get_Gateway_Info)'+E.Message);
    end;
  end;
end;

//=========================================================================================
function TDriverLink.Get_Port_Info(f_iOrder:integer;var f_Port_Information:TPort_Information) : integer ;
begin
  try
    if m_bDllLink and (@m_Get_Port_Info<>nil) then begin
      Result:=m_Get_Port_Info(f_iOrder,f_Port_Information);
      if Result=cResultok then addLog(cLogNormal,'('+ClassName+'.Get_Port_Info)  OK')
      else addLog(cLogError,'('+ClassName+'.Get_Port_Info) Fail ('+inttostr(result)+')');
    end
    else begin
      Result:=cResultDriverLinkFail;
      addLog(cLogError,'('+ClassName+'.Get_Port_Info)'+'Unlink Driver');
    end;
  except
    on E:Exception do begin
      result:=cResultError;
      addLog(cLogError,'('+ClassName+'.Get_Port_Info)'+E.Message);
    end;
  end;
end;

//=========================================================================================
function TDriverLink.setup_Gateway(f_pSetupValue :pchar;var f_iCount : integer) : integer;
begin
  try
    if m_bDllLink and (@m_setup_Gateway<>nil) then begin
      result:=m_setup_Gateway(f_pSetupValue,f_iCount);
      if Result=cResultok then addLog(cLogNormal,'('+ClassName+'.setup_Gateway)  OK')
      else addLog(cLogError,'('+ClassName+'.setup_Gateway) Fail ('+inttostr(result)+')');
    end
    else begin
      Result:=cResultDriverLinkFail;
      addLog(cLogError,'('+ClassName+'.setup_Gateway)'+'Unlink Driver');
    end;
  except
    on E:Exception do begin
      result:=cResultError;
      addLog(cLogError,'('+ClassName+'.setup_Gateway)'+E.Message);
    end;
  end;
end;

//=========================================================================================
function TDriverLink.Check_Setup(f_pSetupValue,f_pSetupOther :pchar) : integer;
begin
  try
    if m_bDllLink and (@m_Check_Setup<>nil) then begin
      result:=m_Check_Setup(f_pSetupValue,f_pSetupOther);
      if Result=cResultok then addLog(cLogNormal,'('+ClassName+'.Check_Setup)  OK')
      else addLog(cLogError,'('+ClassName+'.Check_Setup) Fail ('+inttostr(result)+')');
    end
    else begin
      Result:=cResultDriverLinkFail;
      addLog(cLogError,'('+ClassName+'.Check_Setup)'+'Unlink Driver');
    end;
  except
    on E:Exception do begin
      result:=cResultError;
      addLog(cLogError,'('+ClassName+'.Check_Setup)'+E.Message);
    end;
  end;
end;

//=========================================================================================
function TDriverLink.Open_Gateway(f_iGID : integer;f_pSetupValue:pchar;f_OnReceiveData : TOnTransData ): integer;
begin
  try
    if m_bDllLink and (@m_Open_Gateway<>nil) then begin
      addLog(cLogNormal,'('+ClassName+'.Open_Gateway)('+inttostr(f_iGid)+')'+'Open Gateway Start');
      result:=m_Open_Gateway(f_iGID,f_pSetupValue,f_OnReceiveData);
      if Result=cResultOk then addLog(cLogNormal,'('+ClassName+'.Open_Gateway)('+inttostr(f_iGid)+')'+'Open Gateway OK')
      else addLog(cLogNormal,'('+ClassName+'.Open_Gateway)('+inttostr(f_iGid)+')'+'Open Gateway Fail ('+inttostr(result)+')');
    end
    else begin
      Result:=cResultDriverLinkFail;
      addLog(cLogError,'('+ClassName+'.Open_Gateway)('+inttostr(f_iGid)+')'+'Unlink Driver');
    end;
  except
    on E:Exception do begin
      result:=cResultError;
      addLog(cLogError,'('+ClassName+'.Open_Gateway)('+inttostr(f_iGid)+')'+E.Message);
    end;
  end;
end;

//=========================================================================================
function TDriverLink.close_Gateway (f_iGID : integer) : integer;
begin
  try
    if m_bDllLink and (@m_close_Gateway<>nil) then begin
      result:=m_close_Gateway(f_iGID);
      if Result=cResultok then addLog(cLogNormal,'('+ClassName+'.close_Gateway)  OK')
      else addLog(cLogError,'('+ClassName+'.close_Gateway) Fail ('+inttostr(result)+')');
    end
    else begin
      Result:=cResultDriverLinkFail;
      addLog(cLogError,'('+ClassName+'.close_Gateway)'+'Unlink Driver');
    end;
  except
    on E:Exception do begin
      result:=cResultError;
      addLog(cLogError,'('+ClassName+'.close_Gateway)'+E.Message);
    end;
  end;
end;

//=========================================================================================
function TDriverLink.Send_Data(f_iMsgType,f_iGID,f_iSubID,f_iPort,f_iBuzz:integer;f_pData:pchar;f_iLen:integer) : integer ;
begin
  try
    EnterCriticalSection(m_CSDriver);
    try
      addLog(cLogNormal,'('+ClassName+'.Send_Data) Send -- ('+IntToStr(f_iMsgType)+','+IntToStr(f_iGID)+','+IntToStr(f_iSubID)+','+IntToStr(f_iPort)+','+IntToStr(f_iBuzz)+')'+G_convertBufferToStr(f_pData,f_iLen));
      if m_bDllLink and (@m_Send_Data<>nil) then begin
        result:=m_Send_Data(f_iMsgType,f_iGID,f_iSubID,f_iPort,f_iBuzz,f_pData,f_iLen);
        if Result=cResultok then addLog(cLogNormal,'('+ClassName+'.Send_Data)  OK')
        else addLog(cLogError,'('+ClassName+'.Send_Data) Fail ('+inttostr(result)+')');
      end
      else begin
        Result:=cResultDriverLinkFail;
        addLog(cLogError,'('+ClassName+'.Send_Data)'+'Unlink Driver');
      end;
    finally
      LeaveCriticalSection(m_CSDriver);
    end;
  except
    on E:Exception do begin
      Result:=cResultError;
      addLog(cLogError,'('+ClassName+'.Send_Data)'+E.Message);
    end;
  end;
end;

//=========================================================================================
{ 用來log的event }
procedure TDriverLink.addLog(f_LogType: TLogType;f_sMessage:string);
begin
  TRY
    if @m_addLog<>nil then m_addLog(f_LogType,f_sMessage);
  except
    on E:Exception do raise Exception.create('('+ClassName+'.addLog)'+E.Message);
  end;
end;

//=========================================================================================
{ create event }
constructor TDriverLink.create(AOwner : TComponent;f_addLog:TOnAddLog);
begin
  try
    inherited Create(AOwner);
    { LINK LOG EVENT }
    if @f_addLog<>nil then m_addLog:=f_addLog;
    addLog(cLognormal,'('+classname+'.create)'+'Create Driver Link Start');
    { 初始化FLAG }
    m_DLLHandle:=0;
    m_bDllLink:=false;
    m_sDLLName:='';
    InitializeCriticalSection(m_CSDriver);
    { 將LINK的FUNCTOIN先設成nil }
    m_SetupValue := nil;
    m_Get_Gateway_Info := nil;
    m_Get_Port_Info := nil;
    m_setup_Gateway := nil;
    m_Open_Gateway := nil;
    m_close_Gateway := nil;
    m_Send_Data := nil;
    m_Check_Setup := nil;
    addLog(cLognormal,'('+classname+'.create)'+'Create Driver Link OK');
  except
    on E:Exception do Raise Exception.create('('+ClassName+'.create)'+E.Message);
  end;
end;

//=========================================================================================
destructor TDriverLink.Destroy;
begin
  try
    addLog(cLognormal,'('+classname+'.Destroy)'+'Destroy Driver Link('+m_sDLLName+') Start');
    { 假如CLOSE EVENT有LINK，則執行來 FREE 所有GATEWAY }
    close_Gateway(0);
    { 假如有LINK DRIVER的話，則FREE }
    if m_DLLHandle>32 then FreeLibrary(m_DLLHandle);
    EnterCriticalSection(m_CSDriver);
    DeleteCriticalSection(m_CSDriver);
    addLog(cLognormal,'('+classname+'.Destroy)'+'Destroy Driver Link('+m_sDLLName+') OK');
  except
    on E:Exception do Raise Exception.create('('+ClassName+'.Destroy)'+E.Message);
  end;

  inherited Destroy;
end;

//=========================================================================================
function TDriverLink.initialize(f_sDLLName:string): boolean;
begin
  result:=false;
  try
    result:=LINKDriver(f_sDLLName);
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.initialize)'+E.message);
  end;
end;


//=========================================================================================
{ 連接driver，並確認其合法性 }
function TDriverLink.LinkDriver(f_sDLLName:string) : boolean;
var sFeedBack,sCheck : string;
    pcharData : pchar;
begin
  result:=false;
  try
    addLog(cLogNormal,'('+classname+'.LinkDriver)'+'Link Driver ('+f_sDLLName+') Start');
    pcharData:=AllocMem(300);
    try
      { 檢查是否已經有初始化過 }
      if (m_sDLLName<>'') then raise Exception.Create('Duplicate Link ('+f_sDLLName+')('+m_sDLLName+')');
      m_sDLLName:=Uppercase(f_sDLLName);

      { LINK DRIVER }
      m_DLLHandle:=LoadLibrary(pchar(ExtractFilePath(Application.exename)+f_sDLLName));
      if m_DLLHandle<=32 then raise Exception.create('Can Not Find DLL File ('+f_sDLLName+')');

      { LINK DRIVER EVENT }
      m_SetupValue := GetProcAddress(m_DLLHandle,'Sajet_SetupValue');
      m_Get_Gateway_Info := GetProcAddress(m_DLLHandle,'Sajet_Get_Gateway_Info');
      m_Get_Port_Info:=GetProcAddress(m_DLLHandle,'Sajet_Get_Port_Info');
      m_setup_Gateway := GetProcAddress(m_DLLHandle,'sajet_setup_Gateway');
      m_Open_Gateway := GetProcAddress(m_DLLHandle,'sajet_open_Gateway');
      m_close_Gateway := GetProcAddress(m_DLLHandle,'sajet_close_Gateway');
      m_Send_Data := GetProcAddress(m_DLLHandle,'sajet_Send_Data');
      m_Check_Setup := GetProcAddress(m_DLLHandle,'Sajet_Check_Setup');

      { 檢查所有EVENT是否有連結正常 }
      if (@m_SetupValue=nil) then addLog(cLogError, '('+classname+'.LinkDriver)'+'DLL Function Not Match (1)');
      if (@m_Get_Gateway_Info=nil) then addLog(cLogError,'('+classname+'.LinkDriver)'+'DLL Function Not Match (2)');
      if (@m_Get_Port_Info=nil) then addLog(cLogError,'('+classname+'.LinkDriver)'+'DLL Function Not Match (3)');
      if (@m_setup_Gateway=nil) then addLog(cLogError,'('+classname+'.LinkDriver)'+'DLL Function Not Match (4)');
      if (@m_Open_Gateway=nil)  then addLog(cLogError,'('+classname+'.LinkDriver)'+'DLL Function Not Match (5)');
      if (@m_close_Gateway=nil) then addLog(cLogError,'('+classname+'.LinkDriver)'+'DLL Function Not Match (6)');
      if (@m_Send_Data=nil)  then addLog(cLogError,'('+classname+'.LinkDriver)'+'DLL Function Not Match (7)');
      if (@m_Check_Setup=nil)  then addLog(cLogError,'('+classname+'.LinkDriver)'+'DLL Function Not Match (8)');

      if (@m_SetupValue=nil) or (@m_Get_Gateway_Info=nil) or (@m_setup_Gateway=nil) or
         (@m_Open_Gateway=nil) or (@m_close_Gateway=nil) or (@m_Send_Data=nil) or
         (@m_Get_Port_Info=nil) or (@m_Check_Setup=nil)
      then raise Exception.create('DLL Function Not Match');

      { 檢查DRIVER 是否是合法的 }
      sCheck := G_DriverGetRandomString  ;    //取得RANDOM STRING 用來檢查
      G_convertStringToEncodePchar(sCheck,pcharData);   //將STRING轉成ENCODE PCHAR
      m_SetupValue(pcharData);  //取得DRIVER的回傳值
      sFeedBack:=G_convertEncodePcharToString(pcharData);       //將回傳的ENCODE PCHAR轉成STRING
      if G_DriverGetFeedBackString(sCheck)<>sFeedBack then raise Exception.create('Driver Illegeal');//檢查回傳值是否是合法的
    finally
      FreeMem(pcharData);
    end;
    addLog(cLogNormal,'('+classname+'.LinkDriver)'+'Link Driver ('+f_sDLLName+') OK');
    m_bDllLink:=true;
    result:=true;
  except
    on E:Exception do  addLog(cLogError,'('+classname+'.LinkDriver)'+E.Message);
  end;
end;

function TDriverLink.getDriverName : string;
begin
  Result:=m_sDLLName;
end;


end.
