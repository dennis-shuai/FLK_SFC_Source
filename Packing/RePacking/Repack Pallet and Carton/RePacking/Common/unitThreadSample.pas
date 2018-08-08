unit unitThreadSample;

interface

uses
  Classes,sysutils,windows,dialogs,unitLog;

type

  TOnTime=function : boolean of object;

  //���Ncreate����A���I�sresume��thread�}�l����
  TThreadSample = class(TThread)
  private
    { Private declarations }
    m_AddLog : TOnAddLog;                        //LOG EVENT
    m_hSingle : array [0..3] of THandle;         //�Ψӱ���close execute�Bdestroy�Bcontinue�Bwake up��handle
    m_iExecuteInterval : Cardinal;               //thread��v���ɶ��A��wakeup handle���QĲ�o�N�|���Ӥu�@�A�_�h�|�b���ӫ�~�u�@
    procedure Execute; override;                 //thread execute
  protected
    procedure addLog(f_LogType: TLogType;f_sMessage:string); virtual;    //log event
    function  executeThread : boolean ; virtual;                         //thread��on time event�A�ѫ�N�мg�ΡAresult�O���n���n�~�����
  public
    m_onExecStart : TOnTime;
    m_onExecOver : TOnTime;
    function  getCLoseHandle : THandle;  //�ѫ�N���oclose handle�A�K�o�d�b��N��execute event
    procedure SetExecOver;               //Ĳ�oclose single�A����thread������
    procedure SetExecStart;              //Ĳ�owake up single�A�j�����on time event
    //==============================================================================================
    constructor Create(f_onAddLog : TOnAddLog;f_iInterval : Cardinal) ; virtual;
    destructor Destroy; override;
  end;

  //timer������thread�Acreate������A���I�sresume�MSetExecStart�A�~�|�}�l�u�@
  TThreadSampleTimer=class(TThreadSample)
  protected
    function executeThread : boolean ; override;
  public
    m_onTime : TOnTime;    //��ontime�n���檺�u�@�A�ѫ�N�s���Ϊ�
    procedure ExecuteSynchronize(f_Execute:TThreadMethod);   //���N�����P�B���檺event�A���I�s�o��event
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

//====================================================================================================
{ ��timer on time���ɭԡA�|Ĳ�o�o��EVENT�A�ˬd��N�O�_���s��ON TIME EVENT }
function TThreadSampleTimer.executeThread : boolean ;
begin
  result:=false;
  try
    if assigned(m_onTime) then result:=m_onTime;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.executeThread)'+E.Message);
  end;
end;


//====================================================================================================
{ ��TIMER��PROCEDURE���bMAIN THREAD����A�i�I�s�o��EVENT }
procedure TThreadSampleTimer.ExecuteSynchronize(f_Execute:TThreadMethod);
begin
  try
    Synchronize(f_Execute);
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ExecuteSynchronize)'+E.Message);
  end;
end;


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
    if assigned(m_addLog)  then m_AddLog(f_LogType,f_sMessage);
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

//=============================================================================================
{ ��n����thread���B�@�� �A�I�s�o��event }
procedure TThreadSample.SetExecOver;
begin
  try
    SetEvent(m_hSingle[cDestroy]);
    if WaitForSingleObject(m_hSingle[cExecOver],infinite)=wait_timeout then raise Exception.create('Destroy Thread TimeOut');
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

    //CREATE SINGLE
    m_hSingle[cDestroy]:=CreateEvent(nil,true,false,nil);     //CLOSE SINGLE
    m_hSingle[cExecOver]:= CreateEvent(nil,true,true,nil);    //Execute Over Single
    m_hSingle[cContinue]:= CreateEvent(nil,true,false,nil);    //�O�_�٦��F��n�~�����
    m_hSingle[cWakeUp]:= CreateEvent(nil,true,false,nil);     //�O�_�n�j�����
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
    //�o�XCLOSE��SINGLE�A����thread������
    SetExecOver;
    //CLOSE�Ҧ�SINGLE
    for i:=1 to length(m_hSingle) do closehandle(m_hSingle[i-1]);
    m_AddLog:=nil;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.destroy)'+E.Message);
  end;

  inherited destroy;
end;

//=============================================================================================
{ THREAD EXECUTE Event, �Q�o��component���ð_�ӡA��N�u���мgexecuteThread }
procedure TThreadSample.Execute;
begin
  { Place thread code here }
  try
    resetEvent(m_hSingle[cExecOver]) ;
    try
      if Assigned(m_onExecStart) then m_onExecStart;

      //�C50MS�|�B�z�@��EVENT�A�p�GEVENT�o�����F��B�z�A�h�|�յۦA�~��B�z�A�_�h�h��50MS
      while WaitForMultipleObjects(3,@m_hSingle[cDestroy],false,m_iExecuteInterval)<>wait_object_0 do begin
        if WaitForSingleObject(m_hSingle[cDestroy],0)=wait_object_0 then exit;
        try
          ResetEvent(m_hSingle[cWakeUp]);
          //executeThread�N��o������O�_���F��B�z
          if executeThread then SetEvent(m_hsingle[cContinue])
          else ReSetEvent(m_hsingle[cContinue]);
        Except
          on E:Exception do addLog(cLogError,'('+ClassName+'.Execute)'+E.Message);
        end;
      end;

      if Assigned(m_onExecOver) then m_onExecOver;

    finally
      setevent(m_hSingle[cExecOver]) ;
    end;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.Execute)'+E.Message);
  end;
end;

//=============================================================================================
function TThreadSample.executeThread : boolean;
begin
  result:=false;
end;

end.
