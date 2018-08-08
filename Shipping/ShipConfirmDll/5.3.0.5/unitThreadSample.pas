unit unitThreadSample;

interface

uses
  Classes,sysutils,windows,dialogs,unitLog;

type
  //���Ncreate����A���I�sresume��thread�}�l����
  TThreadSample = class(TThread)
  private
    { Private declarations }
    m_AddLog : TOnAddLog;
    m_hSingle : array [0..3] of THandle;
    m_iExecuteInterval : Cardinal;
    procedure Execute; override;
  protected
    procedure addLog(f_LogType: TLogType;f_sMessage:string);    //log event
    function  getCLoseHandle : THandle;                         //�ѫ�N���oclose handle�A�K�o�d�b��N��execute event
    procedure SetExecOver;                                      //Ĳ�oclose single�A����thread������
    procedure SetExecStart;                                     //Ĳ�owake up single�A�j�����on time event
  public
    function  executeThread : boolean ; virtual;                //thread��on time event�A�ѫ�N�мg�ΡAresult�O���n���n�~�����
    constructor Create(f_onAddLog : TOnAddLog;f_iInterval : Cardinal) ; virtual;
    destructor Destroy; override;
  end;

implementation

{ Important: Methods and properties of objects in VCL or CLX can only be used
  in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TThreadSample.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }
const
//SINGLE���N�X
  cExecOver=0;
  cDestroy=1;
  cContinue=2;
  cWakeUp=3;
{ TThreadSample }


//=============================================================================================
{ Ĳ�owake up single�A�j�����on time event }
procedure TThreadSample.SetExecStart;
begin
  try
    SetEvent(m_hSingle[cWakeUp]);
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.SetExecStart)'+E.Message);
  end;
end;


//=============================================================================================
{ Log Event }
procedure TThreadSample.addLog(f_LogType: TLogType;f_sMessage:string);
begin
  try
    if @m_addLog<>nil then m_AddLog(f_LogType,f_sMessage);
  except
    on E:EXception do raise Exception.Create('('+classname+'.addLog)'+E.Message);
  end;
end;

//=============================================================================================
{ �ѫ�N���oSINGLE }
function TThreadSample.getCLoseHandle : THandle;
begin
  Result:=m_hSingle[cDestroy];
end;

procedure TThreadSample.SetExecOver;
begin
  try
    SetEvent(m_hSingle[cDestroy]);
    if WaitForSingleObject(m_hSingle[cExecOver],3000)=wait_timeout then raise Exception.create('Destroy Thread TimeOut');
  except
    on E:Exception do raise Exception.create('('+ClassName+'.SetExecOver)'+E.Message);
  end
end;


//=============================================================================================
{ Create Event }
constructor  TThreadSample.Create(f_onAddLog : TOnAddLog;f_iInterval : Cardinal);
begin
  inherited Create(TRUE);

  try
    m_iExecuteInterval:=f_iInterval;
    FreeOnTerminate:=false;
    m_AddLog:=f_onAddLog;
    addLog(cLogNormal,'('+ClassName+'.Create)'+'Thread Create Start');
    //CREATE SINGLE
    m_hSingle[cDestroy]:=CreateEvent(nil,true,false,nil);     //CLOSE SINGLE
    m_hSingle[cExecOver]:= CreateEvent(nil,true,true,nil);    //Execute Over Single
    m_hSingle[cContinue]:= CreateEvent(nil,true,false,nil);    //�O�_�٦��F��n�~�����
    m_hSingle[cWakeUp]:= CreateEvent(nil,true,false,nil);     //�O�_�n�j�����
    addLog(cLogNormal,'('+ClassName+'.Create)'+'Thread Create OK');
  except
    on E:Exception do raise Exception.create('('+ClassName+'.Create)'+E.Message);
  end;
end;

//=============================================================================================
{ Destroy Event }
destructor TThreadSample.destroy;
var i : integer;
begin
  try
    addLog(cLogNormal,'('+ClassName+'.destroy)'+'Destroy Thread Start');
    //�o�XCLOSE��SINGLE�A����thread������
    SetExecOver;
    //CLOSE�Ҧ�SINGLE
    for i:=1 to length(m_hSingle) do closehandle(m_hSingle[i-1]);
    addLog(cLogNormal,'('+ClassName+'.destroy)'+'Destroy Thread OK');
  except
    on E:Exception do raise Exception.create('('+ClassName+'.destroy)'+E.Message);
  end;

  inherited destroy;
end;

//=============================================================================================
{ THREAD EXECUTE Event, �Q�o��component���ð_�ӡA��N�u���мgexecuteThread }
procedure TThreadSample.Execute;
begin
  { Place thread code here }
  resetEvent(m_hSingle[cExecOver]) ;
  try
    //�C50MS�|�B�z�@��EVENT�A�p�GEVENT�o�����F��B�z�A�h�|�յۦA�~��B�z�A�_�h�h��50MS
    while WaitForMultipleObjects(3,@m_hSingle[cDestroy],false,infinite)<>wait_object_0 do begin
      try
        ResetEvent(m_hSingle[cWakeUp]);
        //executeThread�N��o������O�_���F��B�z
        if executeThread then SetEvent(m_hsingle[cContinue])
        else ReSetEvent(m_hsingle[cContinue]);
      Except
        on E:Exception do addLog(cLogError,'('+ClassName+'.Execute)'+E.Message);
      end;
    end;
  finally
    setevent(m_hSingle[cExecOver]) ;
  end;
end;

//=============================================================================================
function TThreadSample.executeThread : boolean;
begin
  result:=false;
end;

end.
