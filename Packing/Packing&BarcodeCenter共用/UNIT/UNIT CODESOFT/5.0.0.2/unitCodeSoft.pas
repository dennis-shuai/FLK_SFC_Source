unit unitCodeSoft;

interface

uses classes,sysutils,windows,dialogs,forms,unitThreadSample, ExtCtrls,
     unitLog,unitCodeSoft6,unitCodeSoftSample,unitCodeSoft5,unitCodeSoft4,unitCSPrintData;

type
  TLabelType=(LabelSN,LabelCarton,LabelelPallet);
  TCSType=(CS6,CS5,CS4);

  TCodeSoft=class(TComponent)
  private
    m_threadTimer : TThreadSampleTimer;
    m_CSData: TRTLCriticalSection;                      //用來防止同一時間處理資料，造成錯誤
    m_CSComponent : TRTLCriticalSection;                //用來防止同一時間異動到m_cs
    m_NewPrintData : TCSPrintData;
    m_CS : TCodeSoftSample;                             //CodeSoft6的控制元件
    m_CSVersion : TCSType;                              //現在使用的VERSION為何，預設值為VERSION 6
    m_sSampleFile : string;                             //現在所open的sample file的完整路徑
    m_sTempSampleFile : string;

    //設定使用的code soft
    procedure SetVersion(f_CSVersion : TCSType);
    function getVersion : TCSType;

    //設定是否要連結code soft
    procedure SetLink(f_bLink : boolean);
    function getLink : boolean;

    //設定是否要連結顯示code soft的主程式
    procedure SetVisible(f_bVisible: boolean);
    function getVisible : boolean;

    function DeletePrintData : boolean;
    function onTime : Boolean;
    function getNewPrintData : TCSPrintData;
    procedure changeSampleFile;
    procedure OpenCS;
    procedure CloseCS;
  public
    m_aTsPrintData : array of TCSPrintData;               //PRINT資料的暫存區
    //控制CODE SOFT的相關變數
    property Version : TCSType read getVersion write SetVersion;        //CODE SOFT所要連結的version
    property Linked : boolean read getLink write SetLink;               //CODE SOFT是否已被連結
    property Visibled : boolean read getVisible write setVisible;       //CODE SOFT是否要被顯示出來

    //開啟CODE SOFT的SAMPLE FILE
    function openSampleFile(f_sFileName:string;var f_sMessage : string): boolean;   //依照傳入的完整路徑，開啟SAMPLE FILE，假如傳入的是空值，則會CLOSE SAMPLE FILE
    function selectSampleFile(var f_sFileName,f_sMessage : string) : boolean;       //選值且開啟一個SAMPLE FILE
    function getSampleFile : string;                                                //取得現在開啟的SAMPLE FILE的完整路徑

    //CODE SOFT 列印的相關函數
    function  selectPrinter(var f_sMessage : string):boolean;
    function  SetupPrinter(var f_sMessage : string):boolean;
    function  getParameter(var f_tsParameter : tstrings;var f_sMessage:string) : boolean;
    function  assignSampleFile(f_sSampleFile : string;var f_sMessage:string) : boolean;
    procedure assignPrintData(f_sParamName,f_sValue : string); overload;
    procedure assignPrintData(f_sData:string); overload;
    procedure print(f_iQty : integer);

    //資源相關函式

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

implementation


procedure TCodeSoft.assignPrintData(f_sData:string);
begin
  try
    EnterCriticalSection(m_CSData);
    try
      m_NewPrintData.decodePrintData(f_sData);
      m_NewPrintData.m_bComplete:=true;
      m_NewPrintData:=getNewPrintData;
      m_threadTimer.SetExecStart;
    finally
      LeaveCriticalSection(m_CSData);
    end;
  except

    on E:Exception do raise Exception.create('Assign Print Data Error -- '+E.Message);
  end;
end;
procedure TCodeSoft.changeSampleFile;
var sMessage : string;
begin
  if not openSampleFile(m_sTempSampleFile,sMessage) then raise Exception.create(sMessage);
end;


function TCodeSoft.setupPrinter(var f_sMessage : string):boolean;
begin
  Result:=false;
  try
    if not Assigned(m_CS) then raise Exception.create('Not Link Code Soft');
    if m_sSampleFile='' then raise Exception.create('Not Open Sample File');
    if not m_CS.addPrinter(f_sMessage) then exit;
    result:=true;
  except
    on E:Exception do f_sMessage:=E.Message;
  end;
end;


function TCodeSoft.selectPrinter(var f_sMessage : string):boolean;
begin
  Result:=false;
  try
    if not Assigned(m_CS) then raise Exception.create('Not Link Code Soft');
    if m_sSampleFile='' then raise Exception.create('Not Open Sample File');
    if not m_CS.selectPrinter(f_sMessage) then exit;
    result:=true;
  except
    on E:Exception do f_sMessage:=E.Message;
  end;
end;

//取得現在開啟的SAMPLE FILE上的所有PRINT 變數
function TCodeSoft.getParameter(var f_tsParameter : tstrings;var f_sMessage:string) : boolean;
begin
  Result:=false;
  try
    f_tsParameter.clear;
    if not Assigned(m_CS) then raise Exception.create('Not Link Code Soft');
    if m_sSampleFile='' then raise Exception.create('Not Open Sample File');
    if not m_CS.getParameter(f_tsParameter,f_sMessage) then exit;
    result:=true;
  except
    on E:Exception do f_sMessage:=E.Message;
  end;
end;

//回傳現在所開啟的條碼FILE的完整路徑，如果沒開啟的話，則回傳空值
function TCodeSoft.getSampleFile : string;
begin
  result:=m_sSampleFile;
end;

//選擇且open一個label來做為sample file，回傳他的路徑給user
function TCodeSoft.SelectSampleFile(var f_sFileName,f_sMessage : string) : boolean;
var sFileName : string;
begin
  result:=false;
  try
    f_sFileName:='';
    with TOpenDialog.Create(nil) do begin
      try
        if getSampleFile='' then InitialDir:=ExtractFilePath(application.exename)
        else InitialDir:=ExtractFilePath(getSampleFile);
        Filter := 'Label files (*.LAB)|*.LAB';
        if not Execute then raise Exception.create('User Cancel');
        sFileName:=FileName;
      finally
        free;
      end;
    end;

    if not openSampleFile(sFileName,f_sMessage) then exit;
    f_sFileName:=getSampleFile;
    result:=true;
  except
    on E:Exception do f_sMessage:=E.Message;
  end;
end;


function TCodeSoft.openSampleFile(f_sFileName:string;var f_sMessage : string): boolean;
begin
  result:=false;
  try
    EnterCriticalSection(m_CSComponent);
    try
      if not Assigned(m_CS) then begin
        if f_sFileName='' then begin
           m_sSampleFile:='';
           result:=true;
           exit;
        end
        else raise Exception.create('Not Link Code Soft');
      end;

      if not m_CS.openSampleFile(f_sFileName,f_sMessage) then exit;
      m_sSampleFile:=f_sFileName;
      result:=true;
    finally
      LeaveCriticalSection(m_CSComponent);
    end;
  except
    on E:Exception do f_sMessage:=E.Message;
  end;
end;

procedure TCodeSoft.SetVisible(f_bVisible : boolean);
begin
  EnterCriticalSection(m_csComponent);
  try
    if not Assigned(m_CS) then exit;
    if f_bVisible=m_CS.Visibled then exit;
    m_CS.Visibled:=f_bVisible;
  finally
    LeaveCriticalSection(m_CsComponent);
  end;
end;

function TCodeSoft.getVisible : boolean;
begin
  EnterCriticalSection(m_CSComponent);
  try
    result:=false;
    if not assigned(m_CS) then exit;
    Result:=m_CS.Visibled;
  finally
    LeaveCriticalSection(m_CSComponent);
  end;
end;


procedure TCodeSoft.SetLink(f_bLink : boolean);
begin
  EnterCriticalSection(m_csComponent);
  try
    if f_bLink=(assigned(m_CS)) then exit;

    if f_bLink then OpenCS
    else closeCS;
  finally
    LeaveCriticalSection(m_CSComponent);
  end;
end;

function TCodeSoft.getLink : boolean;
begin
  EnterCriticalSection(m_csComponent);
  try
    result:=(m_CS<>nil);
  finally
    LeaveCriticalSection(m_CSComponent);
  end;
end;


function TCodeSoft.getVersion : TCSType;
begin
  Result:=m_CSVersion;
end;


procedure TCodeSoft.SetVersion(f_CSVersion : TCSType);
begin
  //假如version沒變則exit
  if m_CSVersion=f_CSVersion then exit;
  m_CSVersion:=f_CSVersion;
  //假如沒LINKED則完成CHANGE VERSION
  if not Linked then exit;
  //先停止LINK，再重新連結
  Linked:=false;
  Linked:=true;
end;



function TCodeSoft.DeletePrintData : boolean;
var i : integer;
begin
  result:=false;
  try
    //檢查是否有資料刪除
    IF length(m_aTsPrintData)=0 then exit;

    //刪掉舊有資料料
    m_aTsPrintData[0].Free;
    for i:=1 to Length(m_aTsPrintData)-1 do m_aTsPrintData[i-1]:=m_aTsPrintData[i];

    //free資源
    if length(m_aTsPrintData)=1 then finalize(m_aTsPrintData)
    else SetLength(m_aTsPrintData,length(m_aTsPrintData)-1);

    result:=TRUE;
  except
    on E:Exception do raise Exception.create('Delete Print Data Error -- '+E.Message);
  end;
end;


function TCodeSoft.onTime : boolean ;
var versionTemp : TCSType;
begin
  result:=false;
  try
    if not m_aTsPrintData[0].m_bComplete then exit;

    try
      if (m_aTsPrintData[0].m_sSampleFile='') and (getSampleFile='') then raise Exception.create('Not Define Sample File');

      case m_aTsPrintData[0].m_iVerstion of
        0 : versionTemp:=Version;
        4 : VersionTemp:=CS4;
        5 : VersionTemp:=CS5;
        6 : VersionTemp:=Cs6;
        else raise Exception.create('Unknow Version');
      end;

      if Linked and (versionTemp<>Version)  then m_threadTimer.ExecuteSynchronize(closeCS);
      Version:=versionTemp;
      if not Linked then m_threadTimer.ExecuteSynchronize(OpenCS);
      //將要print data搬移到m_CS中，並刪除掉舊有的那一筆
      m_sTempSampleFile:=m_aTsPrintData[0].m_sSampleFile;
      if (m_sTempSampleFile<>'') and (m_sTempSampleFile<>getSampleFile) then m_threadTimer.ExecuteSynchronize(changeSampleFile);
      m_threadTimer.ExecuteSynchronize(m_CS.print);
    finally
      DeletePrintData;
      result:=true;
    end;
  except
  end;
end;

//將尚未print的資料，最舊的一筆的complete flag設成true，通知thread要print
procedure TCodeSoft.print(f_iQty:integer);
var i : integer;
begin
  EnterCriticalSection(m_CSData);
  try
    m_NewPrintData.m_iQty:= f_iQty;
    m_NewPrintData.m_bComplete:=true;
    case Version of
      CS4 : m_NewPrintData.m_iVerstion:=4;
      CS5 : m_NewPrintData.m_iVerstion:=5;
      CS6 : m_NewPrintData.m_iVerstion:=6;
    end;
    m_NewPrintData:= getNewPrintData;
    m_threadTimer.SetExecStart;
  finally
    LeaveCriticalSection(m_CSData);
  end;
end;

procedure TCodeSoft.assignPrintData(f_sParamName,f_sValue : string);
begin
  EnterCriticalSection(m_CSData);
  try
    m_NewPrintData.m_tsParam.Add(f_sParamName);
    m_NewPrintData.m_tsData.Add(f_sValue);
  finally
    LeaveCriticalSection(m_CSData);
  end;
end;


constructor TCodeSoft.Create(AOwner : TComponent);
begin
  inherited create(AOwner);

  m_CSVersion:=CS6;
  m_CS:=nil;
  InitializeCriticalSection(m_CSData);
  InitializeCriticalSection(m_CSComponent);
  m_NewPrintData:=getNewPrintData;

  m_threadTimer:=TThreadSampleTimer.Create(nil,infinite);
  m_threadTimer.m_onTime:=onTime;
  m_threadTimer.Resume;
end;

destructor TCodeSoft.destroy;
var i : integer;
begin
  //暫停thread的執行
  try
    m_threadTimer.free;

    linked:=false;

    EnterCriticalSection(M_csData);
    EnterCriticalSection(m_csComponent);
    try
      //刪除還沒print的資料
      m_NewPrintData:=nil;
      for i:=1 to length(m_aTsPrintData) do m_aTsPrintData[i-1].free;
      finalize(m_aTsPrintData);
    finally
      //Free 資源
      DeleteCriticalSection(m_CSData);
      DeleteCriticalSection(m_CSComponent);
    end;
  except
  end;

  inherited Destroy;
end;


function TCodeSoft.assignSampleFile(f_sSampleFile : string;var f_sMessage:string) : boolean;
begin
  result:=false;
  try
    EnterCriticalSection(m_CSData);
    try
      if not FileExists(f_sSampleFile) then raise Exception.Create('Sample File not Exist');
      m_NewPrintData.m_sSampleFile:=f_sSampleFile;
    finally
      LeaveCriticalSection(m_CSDAta);
    end;
    result:=true;
  except
    on E:Exception do f_sMessage:=E.Message;
  end;
end;


function TCodeSoft.getNewPrintData : TCSPrintData;
begin
  result:=nil;
  try
    setLength(m_aTsPrintData,length(m_aTsPrintData)+1);
    m_aTsPrintData[length(m_aTsPrintData)-1]:=TCSPrintData.Create(Self);
    case m_CSVersion of
      CS4 : m_aTsPrintData[length(m_aTsPrintData)-1].m_iVerstion:=4;
      CS5 : m_aTsPrintData[length(m_aTsPrintData)-1].m_iVerstion:=5;
      CS6 : m_aTsPrintData[length(m_aTsPrintData)-1].m_iVerstion:=6;
    end;
    result:=m_aTsPrintData[length(m_aTsPrintData)-1];
  except
    on E:Exception do raise Exception.Create('Add New Print Data Error -- '+E.Message);
  end;
end;


procedure TCodeSoft.OpenCS;
var sMessage : string;
begin
  case m_CSVersion of
    CS6 : m_CS:= TCodeSoft6.Create(self);
    CS5 : m_CS:= TCodeSoft5.Create(self);
    CS4 : m_CS:= TCodeSoft4.create(self);
  end;

  if (m_sSampleFile<>'') and (not m_CS.openSampleFile(m_sSampleFile,sMessage)) then raise Exception.create(sMessage);
end;

procedure TCodeSoft.CloseCS;
begin
  m_CS.free;
  m_CS:=nil;
end;

end.
