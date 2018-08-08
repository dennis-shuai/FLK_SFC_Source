unit unitRF;

interface

uses classes,sysutils,windows,inifiles,forms,unitDriverLink,unitDriverDeclare,
     unitLog,unitConvert,unitDriverThread;

type


  TRF=class(TComponent)
  private
    m_DriverLink : TDriverLink;
    m_bInitialOK : boolean;
    m_bStart : boolean;
    m_Log : TLog;
    m_DriverThread : TDriverThread;
    procedure addLog(f_LogType: TLogType;f_sMessage:string);
    function getStarted : boolean;
    procedure setStarted(f_bStart : boolean);
    function onRsvDataFromDriver(f_iMsgType,f_iGID,f_iSubID,f_iPort,f_iBuzz:integer;f_pData:pchar;f_iLen:integer) : integer;
    procedure setReceiveData(f_onRsvData : TOnRsvData);
  public
    property OnReceiveData : TOnRsvData write setReceiveData;
    property Started : boolean read getStarted write setStarted;
    function Setup(var f_sMessage : string):boolean;
    constructor Create(AOwner : Tcomponent) ; override;
    destructor Destroy; override;
  end;

implementation

procedure TRF.setReceiveData(f_onRsvData : TOnRsvData);
begin
  m_DriverThread.OnReceiveData:=f_onRsvData;
end;


function TRF.onRsvDataFromDriver(f_iMsgType,f_iGID,f_iSubID,f_iPort,f_iBuzz:integer;f_pData:pchar;f_iLen:integer) : integer;
begin
  if f_iMsgType=cMsgReceiveData then begin
    m_DriverThread.addData(f_iGID,f_iSubID,f_iPort,G_convertBufferToStr(f_pData,f_iLen));
  end;
end;

function TRF.getStarted : boolean;
begin
  Result:=m_bStart;
end;

procedure TRF.setStarted(f_bStart : boolean);
var iCount : integer;
    sSetupValue : string;
    pSetupValue : pchar;
begin
  try
    if m_bStart=f_bStart then exit;
    if not m_bInitialOK then raise Exception.Create('Driver Not Initialize OK');

    if f_bStart then begin
      pSetupValue:=AllocMem(2048);
      with TIniFile.Create(ExtractFilePath(Application.ExeName)+'Driver.ini') do begin
        try
          iCount:=ReadInteger('Driver','Count',0);
          sSetupValue:=ReadString('Driver','Value','');
          sSetupValue:=G_convertASCIIBufferToStr(@sSetupValue[1],length(sSetupValue));
          G_convertStringToEncodePchar(sSetupValue,pSetupValue);
          if m_DriverLink.Open_Gateway(1,pSetupValue,onRsvDataFromDriver)<>cResultOk then raise Exception.create('Open Gateway Fail');
        finally
          free;
          FreeMem(pSetupValue,2048);
        end;
      end;
    end
    else if m_DriverLink.close_Gateway(1)<>cResultOK then raise Exception.create('Close Gateway Fail');
    m_bStart:=f_bStart;
  except
    on E:Exception do begin
      addLog(cLogError,'('+ClassName+'.setStarted)'+e.message);
      raise  Exception.Create(E.Message);
    end;
  end;
end;

function TRF.Setup(var f_sMessage : string):boolean;
var iCount : integer;
    sSetupValue : string;
    pSetupValue : pchar;
begin
  result:=false;
  try
    if not m_bInitialOK then raise Exception.create('Driver Link Fail');

    pSetupValue:=AllocMem(2048);
    with TIniFile.Create(ExtractFilePath(Application.ExeName)+'Driver.ini') do begin
      try
        iCount:=ReadInteger('Driver','Count',0);
        sSetupValue:=ReadString('Driver','Value','');
        sSetupValue:=G_convertASCIIBufferToStr(@sSetupValue[1],length(sSetupValue));
        G_convertStringToEncodePchar(sSetupValue,pSetupValue);
        if m_DriverLink.setup_Gateway(pSetupValue,iCount)<>cResultOk then raise Exception.create('Setup Fail');
        sSetupValue:=G_convertEncodePcharToString(pSetupValue);
        WriteInteger('Driver','Count',iCount);
        WriteString('Driver','Value',G_convertBufferToStrASCII(@sSetupValue[1],length(sSetupValue)));
      finally
        free;
        FreeMem(pSetupValue,2048);
      end;
    end;
    result:=true;
  except
    on E:Exception do begin
      addLog(cLogError,'('+ClassName+'.Setup)'+e.message);
      f_sMessage:=e.Message;
    end;
  end;
end;


procedure TRF.addLog(f_LogType: TLogType;f_sMessage:string);
begin
  try
    if m_Log<>nil then m_Log.add(f_LogType,f_sMessage);
  except
    on E:Exception do raise Exception.create('('+ClassName+'.addLog)'+E.Message);
  end;
end;

constructor TRF.Create(AOwner:TComponent) ;
begin

  inherited Create(AOwner);

  try
    m_Log:=nil;
    m_Log:=TLog.create(nil);
    m_Log.Initialize([cLogNormal,cLogWarnning,cLogError,cLogTest],cLogHour,'RF') ;
    m_bStart:=false;

    m_DriverLink:=TDriverLink.create(nil,addLog);
    m_DriverThread:=TDriverThread.Create(addLog,INFINITE);
    m_DriverThread.OnSendData:=m_DriverLink.Send_Data;
    m_DriverThread.Resume;
    if not m_DriverLink.initialize('sajet_RF.dll') then  addLog(cLogError,'('+ClassName+'.Create)'+'Link Driver OK')
    else m_bInitialOK:=true;

  except
    on E:Exception do raise Exception.create('('+classname+'.Create)'+E.Message);
  end;
end;

destructor TRF.Destroy;
begin
  try
    m_DriverThread.free;
    m_DriverLink.free;
    m_Log.free;
  except
    on E:Exception do addLog(cLogError,e.Message);
  end;
  inherited Destroy;
end;

end.
