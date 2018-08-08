unit unitDriverThread;

interface

uses classes,windows,sysutils,unitLog,unitThreadSample,unitDriverDeclare;

type
  TOnRsvData= function(f_iSubID:integer;var f_sData : string) : boolean of Object;

  TDriverThread =class(TThreadSample)
  private
    m_CSData : TRTLCriticalSection;
    m_tsRsvData : Tstrings;
  protected
    function executeThread : boolean ; override;
  public
    OnSendData : TOnTransData;
    OnReceiveData : TOnRsvData;
    procedure addData(f_iGID,f_iSubID,f_iPort:integer;f_sData : string);
    constructor Create(f_onAddLog : TOnAddLog;f_iInterval : Cardinal) ; override;
    destructor Destroy; override;
  end;

implementation

function TDriverThread.executeThread : boolean ;
type
  TSaveData=record
    m_iGID : byte;
    m_iSubID : byte;
    m_iPort : Byte;
  end;

var sSaveData,sData : string;
    pSaveData :^TSaveData;
    iBuzz : integer;
begin
  result:=false;
  try
    EnterCriticalSection(m_CSData);
    try
      if m_tsRsvData.Count=0 then exit;
      sSaveData:=m_tsRsvData[0];
      m_tsRsvData.Delete(0);
      result:=true;
    finally
      LeaveCriticalSection(m_CSData);
    end;

    pSaveData:=@sSaveData[1];
    sData:=sSaveData;
    Delete(sData,1,3);
    if @OnReceiveData=nil then raise Exception.Create('Not Link Rsv Function')
    else if OnReceiveData(pSaveData.m_iSubID,sData) then iBuzz:=cSoundOK
    else iBuzz:=cSoundError;
    if @OnSendData=nil then raise Exception.create('Not Link Send Function')
    else OnSendData(cMsgSendEnglish,pSaveData.m_iGID,pSaveData.m_iSubID,1,iBuzz,@sData[1],length(sData));
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.executeThread)'+E.Message);
  end;
end;

procedure TDriverThread.addData(f_iGID,f_iSubID,f_iPort:integer;f_sData : string);
begin
  try
    EnterCriticalSection(m_CSData);
    try
      m_tsRsvData.Add(char(f_iGID)+char(f_iSubID)+char(f_iPort)+f_sData);
    finally
      LeaveCriticalSection(m_CSData);
    end;
    SetExecStart;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.addData)'+E.Message);
  end;
end;

constructor TDriverThread.Create(f_onAddLog : TOnAddLog;f_iInterval : Cardinal) ;
begin
  try
    inherited Create(f_onAddLog,f_iInterval);
    m_tsRsvData:=TStringList.create;
    InitializeCriticalSection(m_CSData);
    OnReceiveData:=nil;
    OnSendData:=nil;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.addData)'+E.Message);
  end;
end;

destructor TDriverThread.Destroy;
begin
  try
    SetExecOver;
    m_tsRsvData.Free;
    DeleteCriticalSection(m_CSData);
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.Destroy)'+E.Message);
  end;

  inherited Destroy;
end;


end.
