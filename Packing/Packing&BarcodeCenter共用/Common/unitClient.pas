unit unitClient;

interface

uses classes,sysutils,windows;

type
  TClientStatus=(cStatusOnLine,cStatusOffLine,cStatusUnknow);

  TClient=class(TComponent)
  private
    m_ClientStatus : TClientStatus;
    m_tsRsvData : TStrings;
    m_CSData : TRTLCriticalSection;
    procedure setStatus(f_ClientStatus : TClientStatus);
    function getStatus : TClientStatus;
  public
    property ClientStatua : TClientStatus read getStatus write setStatus;
    procedure addData(f_sData : string);
    function getData : string;
    constructor Create(AOwner : TComponent);override;
    destructor Destroy ; override;
  end;


implementation

function TClient.getStatus : TClientStatus;
begin
  try
    result:=m_ClientStatus;
  except
    on E:Exception do raise Exception.create('('+ClassName+'.getStatus)'+E.Message);
  end;
end;

procedure TClient.setStatus(f_ClientStatus : TClientStatus);
begin
  try
    m_ClientStatus:=f_ClientStatus;
  except
    on E:Exception do raise Exception.create('('+ClassName+'.setStatus)'+E.Message);
  end;
end;

function TClient.getData : string;
begin
  result:='';
  try
    EnterCriticalSection(m_CSData);
    try
      if m_tsRsvData.Count=0 then exit;
      result:=m_tsRsvData[0];
      m_tsRsvData.Delete(0);
    finally
      LeaveCriticalSection(m_CSData);
    end;
  except
    on E:Exception do raise Exception.create('('+ClassName+'.addData)'+E.Message);
  end;
end;


procedure TClient.addData(f_sData : string);
begin
  try
    EnterCriticalSection(m_CSData);
    try
      m_tsRsvData.Add(f_sData);
    finally
      LeaveCriticalSection(m_CSData);
    end;
  except
    on E:Exception do raise Exception.create('('+ClassName+'.addData)'+E.Message);
  end;
end;

constructor TClient.Create(AOwner : TComponent);
begin
  try
    inherited Create(AOwner);
    m_ClientStatus:=cStatusUnknow;
    m_tsRsvData:=TStringList.create;
    InitializeCriticalSection(m_CSData);
  except
    on E:Exception do raise Exception.create('('+ClassName+'.Create)'+E.Message);
  end;
end;

destructor TClient.Destroy ;
begin
  try
    DeleteCriticalSection(m_CSData);
    m_tsRsvData.Free;
    inherited Destroy;
  except
    on E:Exception do raise Exception.create('('+ClassName+'.Destroy)'+E.Message);
  end;
end;

end.
