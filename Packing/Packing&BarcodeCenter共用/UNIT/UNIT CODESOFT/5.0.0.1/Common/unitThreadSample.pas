unit unitThreadSample;

interface

uses
  Classes,sysutils,windows,dialogs,unitLog;

type
  //當後代create完後，須呼叫resume讓thread開始執行
  TThreadSample = class(TThread)
  private
    { Private declarations }
    m_AddLog : TOnAddLog;
    m_hSingle : array [0..3] of THandle;
    m_iExecuteInterval : Cardinal;
    procedure Execute; override;
  protected
    procedure addLog(f_LogType: TLogType;f_sMessage:string);    //log event
    function  getCLoseHandle : THandle;                         //供後代取得close handle，免得卡在後代的execute event
    procedure SetExecOver;                                      //觸發close single，結束thread的執行
    function  executeThread : boolean ; virtual;                //thread的on time event，供後代覆寫用，result是指要不要繼續執行
    procedure SetExecStart;                                     //觸發wake up single，強制執行on time event
  public
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
//SINGLE的代碼
  cExecOver=0;
  cDestroy=1;
  cContinue=2;
  cWakeUp=3;
{ TThreadSample }


//=============================================================================================
{ 觸發wake up single，強制執行on time event }
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
{ 供後代取得SINGLE }
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
    m_hSingle[cContinue]:= CreateEvent(nil,true,false,nil);    //是否還有東西要繼續執行
    m_hSingle[cWakeUp]:= CreateEvent(nil,true,false,nil);     //是否要強制執行
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
    //發出CLOSE的SINGLE，結束thread的執行
    SetExecOver;
    //CLOSE所有SINGLE
    for i:=1 to length(m_hSingle) do closehandle(m_hSingle[i-1]);
    addLog(cLogNormal,'('+ClassName+'.destroy)'+'Destroy Thread OK');
  except
    on E:Exception do raise Exception.create('('+ClassName+'.destroy)'+E.Message);
  end;

  inherited destroy;
end;

//=============================================================================================
{ THREAD EXECUTE Event, 被這個component隱藏起來，後代只能覆寫executeThread }
procedure TThreadSample.Execute;
begin
  { Place thread code here }
  resetEvent(m_hSingle[cExecOver]) ;
  try
    addLog(cLogNormal,'('+ClassName+'.Execute)'+'Start');
    //每50MS會處理一次EVENT，如果EVENT這次有東西處理，則會試著再繼續處理，否則則休息50MS
    while WaitForMultipleObjects(3,@m_hSingle[cDestroy],false,m_iExecuteInterval)<>wait_object_0 do begin
      try
        ResetEvent(m_hSingle[cWakeUp]);
        //executeThread代表這次執行是否有東西處理
        if executeThread then SetEvent(m_hsingle[cContinue])
        else ReSetEvent(m_hsingle[cContinue]);
      Except
        on E:Exception do addLog(cLogError,'('+ClassName+'.Execute)'+E.Message);
      end;
    end;
  finally
    addLog(cLogNormal,'('+ClassName+'.Execute)'+'Over');
    setevent(m_hSingle[cExecOver]) ;
  end;
end;

//=============================================================================================
function TThreadSample.executeThread : boolean;
begin
  result:=false;
end;

end.
