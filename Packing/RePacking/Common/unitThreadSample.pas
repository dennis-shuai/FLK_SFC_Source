unit unitThreadSample;

interface

uses
  Classes,sysutils,windows,dialogs,unitLog;

type

  TOnTime=function : boolean of object;

  //當後代create完後，須呼叫resume讓thread開始執行
  TThreadSample = class(TThread)
  private
    { Private declarations }
    m_AddLog : TOnAddLog;                        //LOG EVENT
    m_hSingle : array [0..3] of THandle;         //用來控制close execute、destroy、continue、wake up的handle
    m_iExecuteInterval : Cardinal;               //thread休眠的時間，當wakeup handle有被觸發就會醒來工作，否則會在醒來後才工作
    procedure Execute; override;                 //thread execute
  protected
    procedure addLog(f_LogType: TLogType;f_sMessage:string); virtual;    //log event
    function  executeThread : boolean ; virtual;                         //thread的on time event，供後代覆寫用，result是指要不要繼續執行
  public
    m_onExecStart : TOnTime;
    m_onExecOver : TOnTime;
    function  getCLoseHandle : THandle;  //供後代取得close handle，免得卡在後代的execute event
    procedure SetExecOver;               //觸發close single，結束thread的執行
    procedure SetExecStart;              //觸發wake up single，強制執行on time event
    //==============================================================================================
    constructor Create(f_onAddLog : TOnAddLog;f_iInterval : Cardinal) ; virtual;
    destructor Destroy; override;
  end;

  //timer型式的thread，create完成後，須呼叫resume和SetExecStart，才會開始工作
  TThreadSampleTimer=class(TThreadSample)
  protected
    function executeThread : boolean ; override;
  public
    m_onTime : TOnTime;    //當ontime要執行的工作，供後代連結用的
    procedure ExecuteSynchronize(f_Execute:TThreadMethod);   //當後代有須同步執行的event，須呼叫這個event
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

//====================================================================================================
{ 當timer on time的時候，會觸發這個EVENT，檢查後代是否有連結ON TIME EVENT }
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
{ 當TIMER有PROCEDURE須在MAIN THREAD執行，可呼叫這個EVENT }
procedure TThreadSampleTimer.ExecuteSynchronize(f_Execute:TThreadMethod);
begin
  try
    Synchronize(f_Execute);
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.ExecuteSynchronize)'+E.Message);
  end;
end;


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
    if assigned(m_addLog)  then m_AddLog(f_LogType,f_sMessage);
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

//=============================================================================================
{ 當要停止thread的運作時 ，呼叫這個event }
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
    m_hSingle[cContinue]:= CreateEvent(nil,true,false,nil);    //是否還有東西要繼續執行
    m_hSingle[cWakeUp]:= CreateEvent(nil,true,false,nil);     //是否要強制執行
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
    //發出CLOSE的SINGLE，結束thread的執行
    SetExecOver;
    //CLOSE所有SINGLE
    for i:=1 to length(m_hSingle) do closehandle(m_hSingle[i-1]);
    m_AddLog:=nil;
  except
    on E:Exception do addLog(cLogError,'('+ClassName+'.destroy)'+E.Message);
  end;

  inherited destroy;
end;

//=============================================================================================
{ THREAD EXECUTE Event, 被這個component隱藏起來，後代只能覆寫executeThread }
procedure TThreadSample.Execute;
begin
  { Place thread code here }
  try
    resetEvent(m_hSingle[cExecOver]) ;
    try
      if Assigned(m_onExecStart) then m_onExecStart;

      //每50MS會處理一次EVENT，如果EVENT這次有東西處理，則會試著再繼續處理，否則則休息50MS
      while WaitForMultipleObjects(3,@m_hSingle[cDestroy],false,m_iExecuteInterval)<>wait_object_0 do begin
        if WaitForSingleObject(m_hSingle[cDestroy],0)=wait_object_0 then exit;
        try
          ResetEvent(m_hSingle[cWakeUp]);
          //executeThread代表這次執行是否有東西處理
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
