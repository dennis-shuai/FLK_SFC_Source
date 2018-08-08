unit unitServerTCP;

interface

uses classes,sysutils,windows,ScktComp,unitLog,unitDriverDeclare,unitConvert;

type
  TOnTransTCPData=function (f_sIP:string;f_iPort:integer;f_bStatus:boolean;var f_sData:string):boolean of object;

  TServerTCP=class(TServerSocket)
  private
    m_CSRsv,m_CSSend : TRTLCriticalSection;
    m_addLog : TOnAddLog;
    m_tsIP : tstrings;
    m_tsData : tstrings;
    m_onRsvTCPData : TOnTransTCPData;
   //===================================================================================================
    procedure ServerSocketAccept(Sender: TObject;Socket: TCustomWinSocket);
    procedure ServerSocketClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServerSocketClientDisconnect(Sender: TObject;Socket: TCustomWinSocket);
    procedure ServerSocketClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ServerSocketClientWrite(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServerSocketGetSocket(Sender: TObject; Socket: Integer; var ClientSocket: TServerClientWinSocket);
    procedure ServerSocketGetThread(Sender: TObject; ClientSocket: TServerClientWinSocket; var SocketThread: TServerClientThread);
    procedure ServerSocketListen(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServerSocketThreadEnd(Sender: TObject; Thread: TServerClientThread);
    procedure ServerSocketThreadStart(Sender: TObject; Thread: TServerClientThread);
    //===================================================================================================
  protected
    procedure addLog(f_LogType: TLogType;f_sMessage:string);
  public
    constructor Create(AOwner : TComponent;f_iPort : integer;f_onAddLog : TOnAddLog;f_onRsvTCPData : TOnTransTCPData);
    destructor Destroy; override;
    function SendDataToClientDevice(f_sIP,f_sData : string) : boolean;
  end;


implementation

//===================================================================================================
{ Destroy Event }
destructor TServerTCP.Destroy;
begin
  try
    Active:=false;
    EnterCriticalSection(m_CSRsv);
    try
      m_onRsvTCPData := nil;
      m_tsIP.free;
      m_tsData.free;
    finally
      DeleteCriticalSection(m_CSRsv);
    end;

    EnterCriticalSection(m_CSSend);
    DeleteCriticalSection(m_CSSend);

    m_addLog := nil;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.Destroy)'+E.Message);
  end;

  inherited Destroy;
end;


//===================================================================================================
{ 傳送資料給CLIENT端的device }
function TServerTCP.SendDataToClientDevice(f_sIP,f_sData : string) : boolean;
var i : integer;
begin
  result:=false;
  try
    EnterCriticalSection(m_CSSend);
    try
      //由ip取得connection來傳送資料
      for i := 1 to Socket.ActiveConnections do begin
        with Socket.Connections[i-1] do begin
          if RemoteAddress=f_sIP then begin
            if not Connected then raise Exception.create('Connection not Connected');
            SendText(f_sData);
            Result:=true;
            exit;
          end;
        end;
      end;

      //假如connection不存在的話，則產生exception
      raise Exception.create('Connection not Exist');
    finally
      LeaveCriticalSection(m_CSSend);
    end;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.getClientData)'+e.Message+'(IP:'+f_sIP+')');
  end;
end;

//===================================================================================================
{ LOG EVENT }
procedure TServerTCP.addLog(f_LogType: TLogType;f_sMessage:string);
begin
  try
    if @m_addLog<>nil then m_addLog(f_LogType,f_sMessage);
  except
    on E:Exception do raise Exception.create('('+classname+'.addLog)'+e.message+'[PORT:'+IntToStr(Port)+']');
  end;
end;

//===================================================================================================
{ CREATE EVETN }
constructor TServerTCP.Create(AOwner : TComponent;f_iPort : integer;f_onAddLog : TOnAddLog;f_onRsvTCPData : TOnTransTCPData);
begin
  inherited Create(AOwner);

  try
    //Create
    InitializeCriticalSection(m_CSRsv);
    InitializeCriticalSection(m_CSSend);
    m_addLog:=f_onAddLog;
    m_onRsvTCPData :=f_onRsvTCPData;
    m_tsIP := tstringlist.create;
    m_tsData := TStringList.create;

    //連結SERVER SOCKET的EVENT
    ServerType:=stNonBlocking;
    Port:=f_iPort;
    OnAccept:=ServerSocketAccept;
    OnClientConnect:=ServerSocketClientConnect;
    OnClientDisconnect:=ServerSocketClientDisconnect;
    OnClientError:=ServerSocketClientError;
    OnClientRead:=ServerSocketClientRead;
    OnClientWrite:=ServerSocketClientWrite;
    OnGetSocket:=ServerSocketGetSocket;
    OnGetThread:=ServerSocketGetThread;
    OnListen:=ServerSocketListen;
    OnThreadEnd:=ServerSocketThreadEnd;
    OnThreadStart:=ServerSocketThreadStart;

    Active:=true;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.Create)'+E.Message);
  end;
end;

//===================================================================================================
{ Occurs on server sockets just after the connection to a client socket is accepted. }
procedure TServerTCP.ServerSocketAccept(Sender: TObject;Socket: TCustomWinSocket);
begin
  try
    addLog(cLogNormal,'('+ClassName+'.ServerSocketAccept)'+'Accept Connection from IP:'+Socket.RemoteAddress);
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ServerSocketAccept)'+E.Message);
  end;
end;

//===================================================================================================
{ Occurs when a client socket completes a connection accepted by the server socket. }
procedure TServerTCP.ServerSocketClientConnect(Sender: TObject; Socket: TCustomWinSocket);
var sData : string;
begin
  try
    addLog(cLogNormal,'('+ClassName+'.ServerSocketClientConnect)'+'Clienct Connect from IP:'+Socket.RemoteAddress);

    EnterCriticalSection(m_CSRsv);
    try
      if @m_onRsvTCPData=nil then exit;

      //檢查是否有這個ip的buffer存在
      if m_tsIP.IndexOf(Socket.RemoteAddress)<0 then begin
        m_tsIP.Add(Socket.RemoteAddress);
        m_tsData.Add('');
      end;

      sData:='';
      m_onRsvTCPData(Socket.RemoteAddress,Port,true,sData);
    finally
      LeaveCriticalSection(m_CSRsv);
    end;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ServerSocketClientConnect)'+E.Message);
  end;
end;

//===================================================================================================
{ Occurs when one of the connections to a client socket is closed. }
procedure TServerTCP.ServerSocketClientDisconnect(Sender: TObject;Socket: TCustomWinSocket);
var sData : string;
    iIndex : integer;
begin
  try
    addLog(cLogNormal,'('+ClassName+'.ServerSocketClientDisconnect)'+'Client DisConnect from IP:'+Socket.RemoteAddress);

    EnterCriticalSection(m_CSRsv);
    try
      if @m_onRsvTCPData=nil then exit;

      iIndex:=m_tsIP.IndexOf(Socket.RemoteAddress);
      if iIndex>=0 then begin
        m_tsIP.Delete(iIndex);
        m_tsData.Delete(iIndex);
      end;

      sData:='';
      m_onRsvTCPData(Socket.RemoteAddress,Port,false,sData);
    finally
      LeaveCriticalSection(m_CSRsv);
    end;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ServerSocketClientDisconnect)'+E.Message);
  end;
end;

//===================================================================================================
{ Occurs when there is a failure in establishing, using,
  or terminating the socket connection to an individual client socket.
  當SERVER SOCKET有發生ERROR會觸發這個EVENT }
procedure TServerTCP.ServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  try
    case ErrorEvent of
      eeGeneral :addLog(cLogWarnning,'('+ClassName+'.ServerSocketClientError)'+'Client Error (General) from IP:'+Socket.RemoteAddress+' -- '+inttostr(ErrorCode));
      eeSend    :addLog(cLogWarnning,'('+ClassName+'.ServerSocketClientError)'+'Client Error (Send) from IP:'+Socket.RemoteAddress+' -- '+inttostr(ErrorCode));
      eeReceive :addLog(cLogWarnning,'('+ClassName+'.ServerSocketClientError)'+'Client Error (Receive) from IP:'+Socket.RemoteAddress+' -- '+inttostr(ErrorCode));
      eeConnect :addLog(cLogWarnning,'('+ClassName+'.ServerSocketClientError)'+'Client Error (Connect) from IP:'+Socket.RemoteAddress+' -- '+inttostr(ErrorCode));
      eeDisconnect :addLog(cLogWarnning,'('+ClassName+'.ServerSocketClientError)'+'Client Error (Disconnect) from IP:'+Socket.RemoteAddress+' -- '+inttostr(ErrorCode));
      eeAccept :addLog(cLogWarnning,'('+ClassName+'.ServerSocketClientError)'+'Client Error (Accept) from IP:'+Socket.RemoteAddress+' -- '+inttostr(ErrorCode));
      eeLookup :addLog(cLogWarnning,'('+ClassName+'.ServerSocketClientError)'+'Client Error (lookup) from IP:'+Socket.RemoteAddress+' -- '+inttostr(ErrorCode));
      else addLog(cLogWarnning,'('+ClassName+'.ServerSocketClientError)'+'Client Error (Unknow) from IP:'+Socket.RemoteAddress+' -- '+inttostr(ErrorCode));
    end;

    ErrorCode:=0;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ServerSocketClientError)'+E.Message);
  end;
end;

//===================================================================================================
{ Occurs when the server socket should read information from a client socket.
  當SERVER SOCKET收到資料時會觸發這個event，將收到的資料傳到client去，由client來做資料的判別 }
procedure TServerTCP.ServerSocketClientRead(Sender: TObject; Socket: TCustomWinSocket);
var sData : string;
    iIndex : integer;
begin
  try
    EnterCriticalSection(m_CSrsv);
    try
      if @m_onRsvTCPData=nil then exit;

      iIndex:=m_tsIP.IndexOf(Socket.RemoteAddress);
      if iindex<0 then raise Exception.Create('Receive Data from No Buffer IP');


      sData:=Socket.ReceiveText;
      Socket.SendText(sDAta);
      //

      sData:=m_tsData[iIndex]+Socket.ReceiveText;
      if sData<>'' then m_onRsvTCPData(Socket.RemoteAddress,Port,true,sData);
      m_tsData[iIndex]:=sData;
    finally
      LeaveCriticalSection(m_CSRsv);
    end;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ServerSocketClientRead)'+E.Message);
  end;
end;

//===================================================================================================
{ Occurs when the server socket should write information to a client socket. }
procedure TServerTCP.ServerSocketClientWrite(Sender: TObject; Socket: TCustomWinSocket);
begin
  try
//    addLog(cLogNormal,'('+ClassName+'.ServerSocketClientWrite)'+'Client write from IP:'+Socket.RemoteAddress);
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ServerSocketClientWrite)'+E.Message);
  end;
end;

//===================================================================================================
{ Occurs when the server socket needs to create a new TServerClientWinSocket object
  to represent the server endpoint of a connection to a client socket. }
procedure TServerTCP.ServerSocketGetSocket(Sender: TObject; Socket: Integer; var ClientSocket: TServerClientWinSocket);
begin
  try
//    addLog(cLogNormal,'('+ClassName+'.ServerSocketGetSocket)'+'Get Socket -- '+ClientSocket.RemoteAddress);
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ServerSocketGetSocket)'+E.Message);
  end;
end;

//===================================================================================================
{ Occurs when the server socket needs to create a new execution thread for a connection to a client socket. }
procedure TServerTCP.ServerSocketGetThread(Sender: TObject; ClientSocket: TServerClientWinSocket; var SocketThread: TServerClientThread);
begin
  try
//    addLog(cLogNormal,'('+ClassName+'.ServerSocketGetThread)'+'Get Thread -- '+ClientSocket.RemoteAddress);
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ServerSocketGetThread)'+E.Message);
  end;

end;
//===================================================================================================
{ Occurs just before a server socket is opened for listening. }
procedure TServerTCP.ServerSocketListen(Sender: TObject; Socket: TCustomWinSocket);
begin
  try
    addLog(cLogNormal,'('+ClassName+'.ServerSocketListen)'+'Listen Port:'+IntToStr(Port));
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ServerSocketListen)'+E.Message);
  end;
end;

//===================================================================================================
{ Occurs when a client socket connection is terminated and the associated thread finishes execution. }
procedure TServerTCP.ServerSocketThreadEnd(Sender: TObject; Thread: TServerClientThread);
begin
  try
//    addLog(cLogNormal,'('+ClassName+'.ServerSocketThreadEnd)'+'Thread End');
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ServerSocketThreadEnd)'+E.Message);
  end;

end;

//===================================================================================================
{ Occurs when the execution thread for a connection to a client socket starts up. }
procedure TServerTCP.ServerSocketThreadStart(Sender: TObject; Thread: TServerClientThread);
begin
  try
//    addLog(cLogNormal,'('+ClassName+'.ServerSocketThreadStart)'+'Thread Start');
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ServerSocketThreadStart)'+E.Message);
  end;
end;


end.
