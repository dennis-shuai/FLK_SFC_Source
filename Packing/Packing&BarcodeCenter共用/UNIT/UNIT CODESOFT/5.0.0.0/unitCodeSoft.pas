unit unitCodeSoft;

interface

uses classes,sysutils,windows,dialogs,forms,unitThreadSample,
     unitLog,unitCodeSoft6,unitCodeSoftSample;

type


  TCSType=(CS6);

  TCodeSoft=class(TThreadSample)
  private
    m_CSData: TRTLCriticalSection;                      //�ΨӨ���P�@�ɶ��B�z��ơA�y�����~
    m_CSComponent : TRTLCriticalSection;                //�ΨӨ���P�@�ɶ����ʨ�m_cs
    m_aTsPrintData : array of TPrintData;               //PRINT��ƪ��Ȧs��
    m_CS : TCodeSoftSample;                             //CodeSoft6�������
    m_CSVersion : TCSType;                              //�{�b�ϥΪ�VERSION����A�w�]�Ȭ�VERSION 6
    m_sSampleFile : string;                             //�{�b��open��sample file��������|

    //�]�w�ϥΪ�code soft
    procedure SetVersion(f_CSVersion : TCSType);
    function getVersion : TCSType;

    //�]�w�O�_�n�s��code soft
    procedure SetLink(f_bLink : boolean);
    function getLink : boolean;

    //�]�w�O�_�n�s�����code soft���D�{��
    procedure SetVisible(f_bVisible: boolean);
    function getVisible : boolean;


    function DeletePrintData : boolean;
  protected
    function executeThread : boolean ; override;

  public
    //����CODE SOFT�������ܼ�
    property Version : TCSType read getVersion write SetVersion;        //CODE SOFT�ҭn�s����version
    property Linked : boolean read getLink write SetLink;               //CODE SOFT�O�_�w�Q�s��
    property Visibled : boolean read getVisible write setVisible;       //CODE SOFT�O�_�n�Q��ܥX��

    //�}��CODE SOFT��SAMPLE FILE
    function openSampleFile(f_sFileName:string;var f_sMessage : string): boolean;   //�̷ӶǤJ��������|�A�}��SAMPLE FILE�A���p�ǤJ���O�ŭȡA�h�|CLOSE SAMPLE FILE
    function selectSampleFile(var f_sFileName,f_sMessage : string) : boolean;       //��ȥB�}�Ҥ@��SAMPLE FILE
    function getSampleFile : string;                                                //���o�{�b�}�Ҫ�SAMPLE FILE��������|

    //CODE SOFT �C�L���������
    function  selectPrinter(var f_sMessage : string):boolean;
    function  SetupPrinter(var f_sMessage : string):boolean;
    function  getParameter(var f_tsParameter : tstrings;var f_sMessage:string) : boolean;
    procedure assignPrintData(f_sParamName,f_sValue : string);
    procedure print(f_iQty : integer);

    //�귽�����禡
    constructor Create;
    destructor Destroy; override;
  end;

implementation

function TCodeSoft.setupPrinter(var f_sMessage : string):boolean;
begin
  Result:=false;
  try
    if m_CS=nil then raise Exception.create('Not Link Code Soft');
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
    if m_CS=nil then raise Exception.create('Not Link Code Soft');
    if m_sSampleFile='' then raise Exception.create('Not Open Sample File');
    if not m_CS.selectPrinter(f_sMessage) then exit;

    result:=true;
  except
    on E:Exception do f_sMessage:=E.Message;
  end;
end;


//���o�{�b�}�Ҫ�SAMPLE FILE�W���Ҧ�PRINT �ܼ�
function  TCodeSoft.getParameter(var f_tsParameter : tstrings;var f_sMessage:string) : boolean;
begin
  Result:=false;
  try
    f_tsParameter.clear;

    if m_CS=nil then raise Exception.create('Not Link Code Soft');
    if m_sSampleFile='' then raise Exception.create('Not Open Sample File');
    if not m_CS.getParameter(f_tsParameter,f_sMessage) then exit;

    result:=true;
  except
    on E:Exception do f_sMessage:=E.Message;
  end;
end;


//�^�ǲ{�b�Ҷ}�Ҫ����XFILE��������|�A�p�G�S�}�Ҫ��ܡA�h�^�Ǫŭ�
function TCodeSoft.getSampleFile : string;
begin
  result:=m_sSampleFile;
end;

//��ܥBopen�@��label�Ӱ���sample file�A�^�ǥL�����|��user
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
      if m_CS=nil then begin
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
    if m_CS=nil then exit;
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
    if m_CS=nil then exit;
    Result:=m_CS.Visibled;
  finally
    LeaveCriticalSection(m_CSComponent);
  end;
end;


procedure TCodeSoft.SetLink(f_bLink : boolean);
var sMessage : string;
begin
  EnterCriticalSection(m_csComponent);
  try
    if f_bLink=(m_CS<>nil) then exit;
    if f_bLink then begin
      case m_CSVersion of
        CS6 : m_CS:= TCodeSoft6.Create(nil);
      end;

      if (m_sSampleFile<>'') and (not m_CS.openSampleFile(m_sSampleFile,sMessage)) then raise Exception.create(sMessage);
    end
    else begin
      m_CS.free;
      m_CS:=nil;
    end;
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
  //���pversion�S�ܫhexit
  if m_CSVersion=f_CSVersion then exit;
  //���p�SLINKED�h����CHANGE VERSION
  if not Linked then exit;
  //������LINK�A�A���s�s��
  Linked:=false;
  Linked:=true;
end;



function TCodeSoft.DeletePrintData : boolean;
var DataTemp : TPrintData;
    i : integer;
begin
  result:=false;
  //�ˬd�O�_����ƧR��
  IF length(m_aTsPrintData)=0 then exit;
  //�R���¦���Ʈ�
  m_aTsPrintData[0].m_tsData.free;
  m_aTsPrintData[0].m_tsParam.free;
  for i:=1 to Length(m_aTsPrintData)-1 do m_aTsPrintData[i-1]:=m_aTsPrintData[i];
  //free�귽
  if length(m_aTsPrintData)=1 then finalize(m_aTsPrintData)
  else SetLength(m_aTsPrintData,length(m_aTsPrintData)-1);
  result:=TRUE;
end;


function TCodeSoft.executeThread : boolean ;
var i : integer;
begin
  result:=false;
  //���i�JCriticalSection�A����print�ɡAm_CS�Q����
  EnterCriticalSection(m_csComponent);
  try
    if m_CS=nil then exit;

    //�ˬd�O�_����ƭnprint�p�G�����ܡA�h����ƪ��h��
    EnterCriticalSection(m_CSData);
    try
      if length(m_aTsPrintData)=0 then exit;
      if not m_aTsPrintData[0].m_bComplete then exit;

      //�N�nprint data�h����m_CS���A�çR�����¦������@��
      m_CS.clearPrintData;
      m_CS.setPrintQty(m_aTsPrintData[0].m_iQty);
      for i:=1 to m_aTsPrintData[0].m_tsParam.Count do m_CS.addPrintData(m_aTsPrintData[0].m_tsParam[i-1],m_aTsPrintData[0].m_tsData[i-1]);
      DeletePrintData;
    finally
      LeaveCriticalSection(m_CSData);
    end;

    //print data
    Synchronize(m_CS.print);
  finally
    LeaveCriticalSection(m_CSComponent);
  end;

  result:=true;
end;

//�N�|��print����ơA���ª��@����complete flag�]��true�A�q��thread�nprint
procedure TCodeSoft.print(f_iQty:integer);
var i : integer;
begin
  EnterCriticalSection(m_CSData);
  try
    for i:=1 to length(m_aTsPrintData) do begin
      if not m_aTsPrintData[i-1].m_bComplete then begin
        m_aTsPrintData[i-1].m_iQty:=f_iQty;
        m_aTsPrintData[i-1].m_bComplete:=true;
        SetExecStart;
        exit;
      end;
    end;
  finally
    LeaveCriticalSection(m_CSData);
  end;
end;

procedure TCodeSoft.assignPrintData(f_sParamName,f_sValue : string);
var DataTemp : ^TPrintData;
    iIndex : integer;
begin
  EnterCriticalSection(m_CSData);
  try
    //���o�n�s�W��ƪ�printData
    f_sParamName:=UpperCase(f_sParamName);
    if (Length(m_aTsPrintData)=0) or (m_aTsPrintData[Length(m_aTsPrintData)-1].m_bComplete) then begin
      setLength(m_aTsPrintData,length(m_aTsPrintData)+1);
      m_aTsPrintData[length(m_aTsPrintData)-1].m_bComplete:=false;
      m_aTsPrintData[length(m_aTsPrintData)-1].m_tsParam:=TStringList.create;
      m_aTsPrintData[length(m_aTsPrintData)-1].m_tsData:=TStringList.create;
    end;
    DataTemp:=@m_aTsPrintData[Length(m_aTsPrintData)-1];

    //�s�W���
    DataTemp.m_tsParam.Add(f_sParamName);
    DataTemp.m_tsData.Add(f_sValue);
  finally
    LeaveCriticalSection(m_CSData);
  end;
end;


constructor TCodeSoft.Create;
begin
  inherited create(nil,INFINITE);

  //�]�w��l��
  m_CSVersion:=CS6;
  m_CS:=nil;
  InitializeCriticalSection(m_CSData);
  InitializeCriticalSection(m_CSComponent);
  resume;
end;

destructor TCodeSoft.destroy;
begin
  //�Ȱ�thread������
  SetExecOver;

  linked:=false;

  EnterCriticalSection(M_csData);
  EnterCriticalSection(m_csComponent);


  //�R���٨Sprint�����
  while DeletePrintData do ;

  //Free �귽
  DeleteCriticalSection(m_CSData);
  DeleteCriticalSection(m_CSComponent);

  inherited Destroy;
end;


end.
