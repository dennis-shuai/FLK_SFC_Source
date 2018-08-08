unit unitLog;

interface

uses classes,windows,sysutils,forms;

type
  //定義LOG的訊息類型
  TLogType=(cLogNormal,cLogWarnning,cLogError,cLogTest);
  TSLogType=set of TLogType;
  //定義LOG的分檔案方式以什麼為單位
  TLogTime=(cLogAll,cLogDay,cLogHour);
  //log function的type
  TOnAddLog= procedure (f_LogType: TLogType;f_sMessage:string) of Object;

  TLog=class(TComponent)
  private
    m_bLogFileExist : boolean;          //記錄log file是否已經存在了
    m_tfLog : textfile;                 //用來記錄的log file
    m_CSLog : TRTLCriticalSection;      //用來管制log時的唯一性
    m_tsLogType:tsLogType;              //記錄要log的type
    m_tLogTime : TLogTime;              //log檔案要分檔的依據
    m_sLogFileTiltle : string;          //log file的檔名title
    m_sLogFileTime : string;            //log file檔名的時間
    m_sLogPath : string;                //log file的儲存路徑
    procedure checkLogFile ;            //檢查是否要CHANGE LOG FILE，如果要的話，就會create新的log file
  public
    //=============================================================================================
    { create相關resource及做初始化的動作 }
    constructor create(f_Awoner:TComponent);override;
    destructor destroy;override;
    function Initialize(f_tsLogType:TSLogType;f_tLogTime:TLogTime;f_sLogTitle:string) : boolean;
    //=============================================================================================
    { 記錄log至檔案中 }
    procedure add(f_LogType: TLogType;f_sMessage:string);
  end;

implementation

//=============================================================================================
{ 設定這個COMPONENT的各個變數
  f_tsLogType : 定義COMPONENT要記錄的訊息類型，不在類型之中的訊息會被忽略
  f_tLogTime : 定義 COMPONENT要分檔案的依據(不分檔，以天為單位，以小時為單位)
  f_sLogTitle : 定義LOG FILE的TITLE，LOG FILE的檔名=TITLE+時間
  f_sMessage : Initialize失敗時的原因  }
function TLog.Initialize(f_tsLogType:TSLogType;f_tLogTime:TLogTime;f_sLogTitle:string) : boolean;
begin
  result:=false;
  try
    //記錄各個PARAMETER
    m_tsLogType:=f_tsLogType;
    m_tLogTime:=f_tLogTime;
    m_sLogFileTiltle:=f_sLogTitle+'('+ExtractFileName(Application.ExeName)+')';
    //如果要記錄訊息，則確認LOG的路徑是否存在，如果不在則強制建立
    if m_tsLogType<>[] then begin
      m_sLogPath:=ExtractFilePath(Application.ExeName)+'LOG';
      if not ForceDirectories(m_sLogPath) then raise Exception.create('Create Log Path Fail');
    end;

    result:=true;
  except
    on E:Exception do m_tsLogType:=[];
  end;

end;
//=============================================================================================
{ Creaqte LOG Component }
constructor TLog.create(f_Awoner:TComponent);
begin
  try
    inherited Create(f_Awoner);
    m_bLogFileExist := false;
    m_sLogFileTime:='';
    InitializeCriticalSection(m_CSLog);
  except
    on E:Exception do raise Exception.create('('+ClassName+'.Create)'+E.Message);
  end;
end;
//=============================================================================================
{ Destroy LOG Component }
destructor TLog.destroy;
begin
  try
    if m_bLogFileExist then CloseFile(m_tfLog);
    DeleteCriticalSection(m_CSLog);
    inherited Destroy;
  except
    on E:Exception do raise Exception.create('('+ClassName+'.Destroy)'+E.Message);
  end;
end;
//=============================================================================================
{ 確認是否要建立LOG FILE }
procedure TLog.checkLogFile ;
var FileHandle : integer;
begin
  try
    //判斷檔案的日期格式是否跟原本的相同 ，如果不同則CLOSE並取得現在的日期格式
    case m_tLogTime of
      cLogAll  : if m_sLogFileTime<>'' then exit;
      cLogDay  : if FormatDateTime('yyyymmdd',now)=m_sLogFileTime then exit;
      cLogHour : if FormatDateTime('yyyymmddhh',now)=m_sLogFileTime then exit;
    end;

    if m_bLogFileExist then closefile(m_tfLog);
    m_bLogFileExist:=false;

    case m_tLogTime of
      cLogAll  : m_sLogFileTime:=FormatDateTime('yyyymmddhhnnss',now);
      cLogDay  : m_sLogFileTime:=FormatDateTime('yyyymmdd',now);
      cLogHour : m_sLogFileTime:=FormatDateTime('yyyymmddhh',now);
    end;

    //建立LOG FILE，LOG FILE的檔名=TITLE+日期格式+.LOG
    FileHandle := FileOpen(m_sLogPath+'\'+m_sLogFileTiltle+m_sLogFileTime+'.Log',fmOpenWrite);
    if FileHandle <0 then FileHandle := FileCreate(m_sLogPath+'\'+m_sLogFileTiltle+m_sLogFileTime+'.Log');
    if FileHandle <0 then raise Exception.create('Create Log FIle Fail');
    FileClose(FileHandle);

    AssignFile(m_tfLog,m_sLogPath+'\'+m_sLogFileTiltle+m_sLogFileTime+'.Log');
    Append(m_tfLog);
    m_bLogFileExist:=true;
  except
    on E:Exception do raise Exception.create('('+ClassName+'.checkLogFile)'+E.Message);
  end;
end;
//=============================================================================================
{ 將LOG 訊息記錄到檔案上 }
procedure TLog.add(f_LogType: TLogType;f_sMessage:string);
var sType : string;
begin
  EnterCriticalSection(m_CSLog);
  try
    try
      if not (f_LogType in m_tsLogType) then exit;
      //確認LOG FILE是否存在，是否需重新建立
      case f_LogType of
        cLogNormal : sType:=format('[%-10S] ',['']);
        cLogWarnning : sType:=format('[%-10S] ',['WARRING']);
        cLogError : sType:=format('[%-10S] ',['ERROR']);
        cLogTest : sType:=format('[%-10S] ',['TEST']);
        else sType:=format('[%-10S] ',['UNKNOW']);
      end;
      checkLogFile;
      Writeln(m_tfLog,formatDateTime('yyyy-mm-dd hh:mm:ss  ',now)+sType+f_sMessage);
    except
      on E:Exception do begin
        m_tsLogType:=[];
        raise Exception.create('('+ClassName+'.Add)'+E.Message);
      end;
    end;
  finally
    LeaveCriticalSection(m_CSLog);
  end;
end;

end.
