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
    class procedure getAllDriverFileName(var tsDriverName : tstrings);
  end;

implementation

//=========================================================================================
{ 取得同一目錄下所有sajet driver的名稱 }
class procedure TDriverLink.getAllDriverFileName(var tsDriverName : tstrings);
var srTemp : TSearchRec;
begin
  try
    tsDriverName.Clear;
    if (FindFirst(ExpandFileName('SAJET_*.DLL'),faAnyFile,srTemp)) = 0 then begin
      tsDriverName.Add(UpperCase(srTemp.name));
      while FindNext(srTemp) = 0 do tsDriverName.Add(uppercase(srTemp.name));
    end;
  except
    on E:Exception do raise Exception.create('('+ClassName+'.getAllDriverFileName)'+E.Message);
  end;
end;


//=========================================================================================
{ 取得gatwway的硬體相關information }
function TDriverLink.Get_Gateway_Info(var f_Gateway_Information : TGateway_Information) : integer;
begin
  try
    if m_bDllLink and  assigned(m_Get_Gateway_Info) then  Result:=m_Get_Gateway_Info(f_Gateway_Information)
    else Result:=cResultDriverLinkFail;
  except
    on E:Exception do result:=cResultError;
  end;
end;

//=========================================================================================
{ 取得gatwway的PORT的information }
function TDriverLink.Get_Port_Info(f_iOrder:integer;var f_Port_Information:TPort_Information) : integer ;
begin
  try
    if m_bDllLink and assigned(m_Get_Port_Info) then begin
      Result:=m_Get_Port_Info(f_iOrder,f_Port_Information)
    end
    else Result:=cResultDriverLinkFail;
  except
    on E:Exception do result:=cResultError;
  end;
end;

//=========================================================================================
{ 設定gatway 的參數 }
function TDriverLink.setup_Gateway(f_pSetupValue :pchar;var f_iCount : integer) : integer;
begin
  try
    if m_bDllLink and assigned(m_setup_Gateway) then result:=m_setup_Gateway(f_pSetupValue,f_iCount)
    else Result:=cResultDriverLinkFail;
  except
    on E:Exception do result:=cResultError;
  end;
end;

//=========================================================================================
{ 確認傳入的設定值，是否有用到重覆的資源 }
function TDriverLink.Check_Setup(f_pSetupValue,f_pSetupOther :pchar) : integer;
begin
  try
    if m_bDllLink and assigned(m_Check_Setup) then result:=m_Check_Setup(f_pSetupValue,f_pSetupOther)
    else Result:=cResultDriverLinkFail;
  except
    on E:Exception do result:=cResultError;
  end;
end;

//=========================================================================================
{ 啟動gatway的運作 }
function TDriverLink.Open_Gateway(f_iGID : integer;f_pSetupValue:pchar;f_OnReceiveData : TOnTransData ): integer;
begin
  try
    if m_bDllLink and assigned(m_Open_Gateway) then result:=m_Open_Gateway(f_iGID,f_pSetupValue,f_OnReceiveData)
    else Result:=cResultDriverLinkFail;
  except
    on E:Exception do result:=cResultError;
  end;
end;

//=========================================================================================
{ 關閉gateway的運作，0是關閉這個driver下的gateway }
function TDriverLink.close_Gateway (f_iGID : integer) : integer;
begin
  try
    if m_bDllLink and assigned(m_close_Gateway) then result:=m_close_Gateway(f_iGID)
    else Result:=cResultDriverLinkFail;
  except
    on E:Exception do result:=cResultError;
  end;
end;

//=========================================================================================
{ 傳入資料給gateway }
function TDriverLink.Send_Data(f_iMsgType,f_iGID,f_iSubID,f_iPort,f_iBuzz:integer;f_pData:pchar;f_iLen:integer) : integer ;
begin
  try
    EnterCriticalSection(m_CSDriver);
    try
      if m_bDllLink and assigned(m_Send_Data) then result:=m_Send_Data(f_iMsgType,f_iGID,f_iSubID,f_iPort,f_iBuzz,f_pData,f_iLen)
      else Result:=cResultDriverLinkFail;
    finally
      LeaveCriticalSection(m_CSDriver);
    end;
  except
    on E:Exception do Result:=cResultError;
  end;
end;

//=========================================================================================
{ 用來log的event }
procedure TDriverLink.addLog(f_LogType: TLogType;f_sMessage:string);
begin
  TRY
    if assigned(m_addLog) then m_addLog(f_LogType,f_sMessage);
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
    m_addLog:=f_addLog;

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
  except
    on E:Exception do Raise Exception.create('('+ClassName+'.create)'+E.Message);
  end;
end;

//=========================================================================================
{ Destroy Event }
destructor TDriverLink.Destroy;
begin
  try
    { FREE 所有GATEWAY }
    close_Gateway(0);
    { 假如有LINK DRIVER的話，則FREE }
    if m_DLLHandle>32 then FreeLibrary(m_DLLHandle);

    EnterCriticalSection(m_CSDriver);
    DeleteCriticalSection(m_CSDriver);
    m_addLog:=nil;
  except
    on E:Exception do Raise Exception.create('('+ClassName+'.Destroy)'+E.Message);
  end;

  inherited Destroy;
end;

//=========================================================================================
{ Link Driver }
function TDriverLink.initialize(f_sDLLName:string): boolean;
var sFeedBack,sCheck : string;
    pcharData : pchar;
begin
  result:=false;
  try
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
      if not assigned(m_SetupValue) then addLog(cLogError, '('+classname+'.LinkDriver)'+'DLL Function Not Match (1)');
      if not assigned(m_Get_Gateway_Info) then addLog(cLogError,'('+classname+'.LinkDriver)'+'DLL Function Not Match (2)');
      if not assigned(m_Get_Port_Info) then addLog(cLogError,'('+classname+'.LinkDriver)'+'DLL Function Not Match (3)');
      if not assigned(m_setup_Gateway) then addLog(cLogError,'('+classname+'.LinkDriver)'+'DLL Function Not Match (4)');
      if not assigned(m_Open_Gateway)  then addLog(cLogError,'('+classname+'.LinkDriver)'+'DLL Function Not Match (5)');
      if not assigned(m_close_Gateway) then addLog(cLogError,'('+classname+'.LinkDriver)'+'DLL Function Not Match (6)');
      if not assigned(m_Send_Data)  then addLog(cLogError,'('+classname+'.LinkDriver)'+'DLL Function Not Match (7)');
      if not assigned(m_Check_Setup)  then addLog(cLogError,'('+classname+'.LinkDriver)'+'DLL Function Not Match (8)');

      if not ( assigned(m_SetupValue) and assigned(m_Get_Gateway_Info) and assigned(m_setup_Gateway) and
               assigned(m_Open_Gateway) and assigned(m_close_Gateway) and assigned(m_Send_Data) and
               assigned(m_Get_Port_Info) and assigned(m_Check_Setup) )
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
