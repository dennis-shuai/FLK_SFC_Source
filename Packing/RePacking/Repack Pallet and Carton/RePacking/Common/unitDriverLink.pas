unit unitDriverLink;

interface

uses classes,windows,sysutils,forms,unitLog,unitDriverDeclare,unitConvert,dialogs;

type
  TDriverLink=class(TComponent)
  private
    m_sDLLName : string;                        //�wLINK��DRIVER�W��
    m_DLLHandle : THandle;                      //LINK DRIVER��HANDLE
    m_bDllLink : boolean;                       //DLL�O�_�wLINK OK
    m_addLog : TOnAddLog;                       //�ΨӰO����FUNCTION
    m_CSDriver : TRTLCriticalSection;           //�ΨӨ���P�@�ɶ������H�P�ɭn�e��Ƶ��P�@��DRIVER
    { Driver ��FUNCTION }
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
    //Driver��FUNCTION
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
{ ���o�P�@�ؿ��U�Ҧ�sajet driver���W�� }
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
{ ���ogatwway���w�����information }
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
{ ���ogatwway��PORT��information }
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
{ �]�wgatway ���Ѽ� }
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
{ �T�{�ǤJ���]�w�ȡA�O�_���Ψ쭫�Ъ��귽 }
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
{ �Ұ�gatway���B�@ }
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
{ ����gateway���B�@�A0�O�����o��driver�U��gateway }
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
{ �ǤJ��Ƶ�gateway }
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
{ �Ψ�log��event }
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

    { ��l��FLAG }
    m_DLLHandle:=0;
    m_bDllLink:=false;
    m_sDLLName:='';
    InitializeCriticalSection(m_CSDriver);

    { �NLINK��FUNCTOIN���]��nil }
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
    { FREE �Ҧ�GATEWAY }
    close_Gateway(0);
    { ���p��LINK DRIVER���ܡA�hFREE }
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
      { �ˬd�O�_�w�g����l�ƹL }
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

      { �ˬd�Ҧ�EVENT�O�_���s�����` }
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

      { �ˬdDRIVER �O�_�O�X�k�� }
      sCheck := G_DriverGetRandomString  ;    //���oRANDOM STRING �Ψ��ˬd
      G_convertStringToEncodePchar(sCheck,pcharData);   //�NSTRING�নENCODE PCHAR
      m_SetupValue(pcharData);  //���oDRIVER���^�ǭ�
      sFeedBack:=G_convertEncodePcharToString(pcharData);       //�N�^�Ǫ�ENCODE PCHAR�নSTRING
      if G_DriverGetFeedBackString(sCheck)<>sFeedBack then raise Exception.create('Driver Illegeal');//�ˬd�^�ǭȬO�_�O�X�k��
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
