unit unitClientTCP;

interface

uses classes,sysutils,windows,ScktComp,unitLog,unitDriverDeclare;

type
  TOnRsvTCPClient=procedure (Sender : TObject) of object;


  TTCPClient=class(TClientSocket)
  private
    function  getClientDesc : string;
    procedure ClientSocketConnect(Sender: TObject;Socket: TCustomWinSocket);
    procedure ClientSocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketDisconnect(Sender: TObject;Socket: TCustomWinSocket);
    procedure ClientSocketError(Sender: TObject;Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;var ErrorCode: Integer);
    procedure ClientSocketLookup(Sender: TObject;Socket: TCustomWinSocket);
    procedure ClientSocketWrite(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure addLog(f_LogType: TLogType;f_sMessage:string);
  public
    m_bReconnect : boolean;
    m_bDestroy : boolean;
    m_OnAddLog :  TOnAddLog;
    m_onRsvTCPClient : TOnRsvTCPClient;
    m_CSRsvData : TRTLCriticalSection;
    m_iGatewayID : integer;
    m_iSubID : integer;
    m_sRsvData : string;
    m_iACKTime : Cardinal;
    m_hStatus : THandle;
    m_bConnected : boolean;
    destructor Destroy; override;
    constructor Create(AOwner: Tcomponent); override;
  end;

implementation

function  TTCPClient.getClientDesc:string;
begin
  try
    result:='(GID:'+inttostr(m_iGatewayID)+' SubID:'+IntToStr(m_iSubID)+' )(IP:'+Address+' PORT:'+inttostr(Port)+') ';
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.getClientDesc)'+E.Message);
  end;
end;


procedure TTCPClient.addLog(f_LogType: TLogType;f_sMessage:string);
begin
  try
    if @m_OnAddLog<>nil then m_OnAddLog(f_LogType,f_sMessage);
  except
    on E:Exception do raise Exception.create('('+ClassName+'.addLog)'+getClientDesc+E.Message)
  end;
end;

destructor TTCPClient.Destroy;
begin
  try
    m_bDestroy:=true;
    Active:=false;

    m_OnAddLog := nil;
    m_onRsvTCPClient := nil;

    DeleteCriticalSection(m_CSRsvdata);
    CloseHandle(m_hStatus) ;
    inherited Destroy;
  except
    on E:Exception do addlog(cLogError,'('+ClassName+'.Destroy)'+getClientDesc+E.Message);
  end;
end;

constructor TTCPClient.Create(AOwner: Tcomponent);
begin
  try
    inherited Create(AOwner);

    m_bDestroy:=false;
    ClientType:=ctNonBlocking;
    InitializeCriticalSection(m_CSRsvData);
    m_bConnected:=false;
    m_iACKTime:=0;
    m_hStatus:=CreateEvent(nil,true,false,nil);
    OnConnect:=ClientSocketConnect;
    OnConnecting:=ClientSocketConnecting;
    OnDisconnect:=ClientSocketDisconnect;
    OnError:=ClientSocketError;
    OnLookup:=ClientSocketLookup;
    OnRead:=ClientSocketRead;
    OnWrite:=ClientSocketWrite;
  except
    on E:Exception do addlog(cLogError,'('+ClassName+'.Create)'+getClientDesc+E.Message);
  end;
end;

//===================================================================================================
{ Occurs on client sockets just after the connection to the server is opened }
procedure TTCPClient.ClientSocketConnect(Sender: TObject;Socket: TCustomWinSocket);
begin
  try
    addLog(cLogNormal,'('+ClassName+'.ClientSocketConnect)'+getClientDesc+'Connect');
    m_bConnected:=true;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ClientSocketConnect)'+getClientDesc+E.Message);
  end;
end;

//===================================================================================================
{ Occurs for a client socket after the server socket has been located,
  but before the connection is established. }
procedure TTCPClient.ClientSocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
begin
  try
  //  addLog(cLogNormal,'('+ClassName+'.ClientSocketConnecting)'+getClientDesc+'Connecting');
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ClientSocketConnecting)'+getClientDesc+E.Message);
  end;
end;

//===================================================================================================
{ Occurs just before a client socket closes the connection to a server socket. }
procedure TTCPClient.ClientSocketDisconnect(Sender: TObject;Socket: TCustomWinSocket);
begin
  try
    addLog(cLogNormal,'('+ClassName+'.ClientSocketDisconnect)'+getClientDesc+'DisConnect');
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ClientSocketDisconnect)'+getClientDesc+E.Message);
  end;
end;

//===================================================================================================
{ Occurs when the socket fails in making, using, or shutting down a connection. }
procedure TTCPClient.ClientSocketError(Sender: TObject;Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;var ErrorCode: Integer);
begin
  try
    if not (ErrorEvent in [eeConnect]) then  addLog(cLogWarnning,'('+ClassName+'.ClientSocketError)'+getClientDesc+'Error -- '+inttostr(ErrorCode));

    case ErrorEvent of
      eeGeneral :addLog(cLogWarnning,'('+ClassName+'.ClientSocketError)'+getClientDesc+'Client Error (General)');
      eeSend    :addLog(cLogWarnning,'('+ClassName+'.ClientSocketError)'+getClientDesc+'Client Error (Send)');
      eeReceive :addLog(cLogWarnning,'('+ClassName+'.ClientSocketError)'+getClientDesc+'Client Error (Receive)');
      eeConnect : ; //addLog(cLogWarnning,'('+ClassName+'.ClientSocketError)'+getClientDesc+'Client Error (Connect)');
      eeDisconnect :addLog(cLogWarnning,'('+ClassName+'.ClientSocketError)'+getClientDesc+'Client Error (Disconnect)');
      eeAccept :addLog(cLogWarnning,'('+ClassName+'.ClientSocketError)'+getClientDesc+'Client Error (Accept)');
      eeLookup :addLog(cLogWarnning,'('+ClassName+'.ClientSocketError)'+getClientDesc+'Client Error (lookup)');
      else addLog(cLogWarnning,'('+ClassName+'.ClientSocketError)'+getClientDesc+'Client Error (Unknow)');
    end;

    //當有問題產生時，則將connection中斷再重連
    m_bReconnect:=true;

    ErrorCode:=0;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ClientSocketError)'+getClientDesc+E.Message);
  end;

end;

//===================================================================================================
{ Occurs when a client socket is about to look up the server socket with which it wants to connect. }
procedure TTCPClient.ClientSocketLookup(Sender: TObject;Socket: TCustomWinSocket);
begin
  try
//    addLog(cLogNormal,'('+ClassName+'.ClientSocketLookup)'+getClientDesc+'Lookup');
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ClientSocketLookup)'+getClientDesc+E.Message);
  end;
end;


//===================================================================================================
{ Occurs when a client socket should write information to the socket connection. }
procedure TTCPClient.ClientSocketWrite(Sender: TObject; Socket: TCustomWinSocket);
begin
  try
    addLog(cLogNormal,'('+ClassName+'.ClientSocketWrite)'+getClientDesc+' Write');
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ClientSocketWrite)'+getClientDesc+E.Message);
  end;
end;

//===================================================================================================
{ Occurs when a client socket should read information from the socket connection. }
procedure TTCPClient.ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
var sData : string;
begin
  try

    EnterCriticalSection(m_csRsvData);
    try
      sData :=Socket.ReceiveText;
      addLog(cLogNormal,'(TTCPClient.ClientSocketRead)'+getClientDesc+'Rsv Data -- '+sData);

      m_sRsvData:=m_sRsvData+sData;
      if @m_onRsvTCPClient=nil then raise Exception.create('Undefined Function');
      m_onRsvTCPClient(self);
    finally
    end;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ClientSocketRead)'+getClientDesc+E.Message);
  end;
end;


end.
