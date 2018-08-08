unit unitLog;

interface

uses classes,windows,sysutils,forms;



type
  //�w�qLOG���T������
  TLogType=(cLogNormal,cLogWarnning,cLogError,cLogTest);
  TSLogType=set of TLogType;
  //�w�qLOG�����ɮפ覡�H���򬰳��
  TLogTime=(cLogAll,cLogDay,cLogHour);
  //log function��type
  TOnAddLog= procedure (f_LogType: TLogType;f_sMessage:string) of Object;

  TLog=class(TComponent)
  private
    m_bLogFileExist : boolean;          //�O��log file�O�_�w�g�s�b�F
    m_tfLog : textfile;                 //�ΨӰO����log file
    m_CSLog : TRTLCriticalSection;      //�ΨӺި�log�ɪ��ߤ@��
    m_tsLogType:tsLogType;              //�O���nlog��type
    m_tLogTime : TLogTime;              //log�ɮ׭n���ɪ��̾�
    m_sLogFileTiltle : string;          //log file���ɦWtitle
    m_sLogFileTime : string;            //log file�ɦW���ɶ�
    m_sLogPath : string;                //log file���x�s���|
    procedure checkLogFile ;            //�ˬd�O�_�nCHANGE LOG FILE�A�p�G�n���ܡA�N�|create�s��log file
  public
    //=============================================================================================
    { create����resource�ΰ���l�ƪ��ʧ@ }
    constructor create(f_Awoner:TComponent);override;
    destructor destroy;override;
    function Initialize(f_tsLogType:TSLogType;f_tLogTime:TLogTime;f_sLogTitle:string) : boolean;
    //=============================================================================================
    { �O��log���ɮפ� }
    procedure add(f_LogType: TLogType;f_sMessage:string);
  end;

implementation

//=============================================================================================
{ �]�w�o��COMPONENT���U���ܼ�
  f_tsLogType : �w�qCOMPONENT�n�O�����T�������A���b�����������T���|�Q����
  f_tLogTime : �w�q COMPONENT�n���ɮת��̾�(�����ɡA�H�Ѭ����A�H�p�ɬ����)
  f_sLogTitle : �w�qLOG FILE��TITLE�ALOG FILE���ɦW=TITLE+�ɶ�
  f_sMessage : Initialize���Ѯɪ���]  }
function TLog.Initialize(f_tsLogType:TSLogType;f_tLogTime:TLogTime;f_sLogTitle:string) : boolean;
begin
  result:=false;
  try
    //�O���U��PARAMETER
    m_tsLogType:=f_tsLogType;
    m_tLogTime:=f_tLogTime;
    m_sLogFileTiltle:=f_sLogTitle+'('+ExtractFileName(Application.ExeName)+')';
    //�p�G�n�O���T���A�h�T�{LOG�����|�O�_�s�b�A�p�G���b�h�j��إ�
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
{ �T�{�O�_�n�إ�LOG FILE }
procedure TLog.checkLogFile ;
var FileHandle : integer;
begin
  try
    //�P�_�ɮת�����榡�O�_��쥻���ۦP �A�p�G���P�hCLOSE�è��o�{�b������榡
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

    //�إ�LOG FILE�ALOG FILE���ɦW=TITLE+����榡+.LOG
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
{ �NLOG �T���O�����ɮפW }
procedure TLog.add(f_LogType: TLogType;f_sMessage:string);
var sType : string;
begin
  EnterCriticalSection(m_CSLog);
  try
    try
      if not (f_LogType in m_tsLogType) then exit;
      //�T�{LOG FILE�O�_�s�b�A�O�_�ݭ��s�إ�
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
