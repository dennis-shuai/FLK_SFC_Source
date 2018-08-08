unit unitCodeSoft4;

interface

uses classes,sysutils,windows,ddeman,inifiles,unitCodeSoftSample,unitLog,unitConvert;

type
  TCodeSoft4=class(TCodeSoftSample)
  private
    m_CS4: TDdeClientConv;
    m_sOpenFileName : string;
    m_bVisible : boolean;
    m_tsParameter : tstrings;
    function getCSPath : string;
    function closeLabelFile : boolean;
    function decodeCSFileName(f_sfileName:string) : string;
  protected
    { 處理visible事宜 }
    procedure setVisible(f_bVisible : Boolean); override;
    function getVisible : boolean; override;
  public
    function  getParameter(var f_tsParameter : tstrings;var f_sMessage:string) : boolean; override;
    function openSampleFile(f_sFileName:string;var f_sMessage : string): boolean; override;
    constructor Create(AOwner : TCOmponent);  override;
    destructor destroy; override;
    procedure print; override;
  end;

implementation



function TCodeSoft4.decodeCSFileName(f_sfileName:string) : string;
var sTemp : string;
    i : integer;
begin
  result:='';
  try
    sTemp:='';
    for i:=1 to Length(f_sfileName) do begin
      if f_sfileName[i] in ['\','[',']','"',',','(',')'] then sTemp:=sTemp+'\';
      sTemp:=sTemp+f_sfileName[i];
    end;

    Result := sTemp;
  except
  end;
end;


//=================================================================================================
{ 關閉CODESOFT所連結的label file }
function TCodeSoft4.closeLabelFile : boolean;
begin
  result:=false;
  try
    if m_sOpenFileName<>'' then begin
      m_tsParameter.clear;
      while m_CS4.WaitStat do ;
      if not m_CS4.ExecuteMacro(PChar('[CloseLab()]'),false) then exit;
    end;
    result:=true;
  except
  end;
end;

//=================================================================================================
{ 取得label上的列印變數 }
function TCodeSoft4.getParameter(var f_tsParameter : tstrings;var f_sMessage:string) : boolean;
var sParameter : string;
    i : integer;
begin
  result:=false;
  try
    f_tsParameter.Clear;
    for i:=1 to m_tsParameter.count do f_tsParameter.Add(uppercase(m_tsParameter[i-1]));
    result:=true;
  except
    on E:Exception do f_sMessage:=E.Message;
  end;
end;


//=================================================================================================
{ OPEN SAMPLE FILE，如果傳入的file name是空值的話，代表要close file }
function TCodeSoft4.openSampleFile(f_sFileName:string;var f_sMessage : string): boolean;
var sParameter : string;
    i : integer;
begin
  result:=false;
  try
    if not inherited openSampleFile(f_sFileName,f_sMessage) then exit;

    if  f_sFileName<>m_sOpenFileName then begin
      if not closeLabelFile then raise Exception.Create('Close Label File Fail');

      if f_sFileName<>'' then begin
        while m_CS4.WaitStat do ;
        if not m_CS4.ExecuteMacro(PChar('[OpenLab('+decodeCSFileName(f_sFileName)+')]'),FALSE) then exit;

        while m_CS4.WaitStat do ;
        sParameter:=StrPas(m_CS4.RequestData('VARLIST'));
        G_convertStringToTstrings(sParameter,';',m_tsParameter);
      end;

      m_sOpenFileName:=f_sFileName;
    end;

    result:=true;
  except
    on E:Exception do f_sMessage:='Error : '+E.Message;
  end;
end;


function TCodeSoft4.getVisible : boolean;
begin
  result:=m_bVisible;
end;


procedure TCodeSoft4.setVisible(f_bVisible : Boolean);
begin
  if f_bVisible=m_bVisible then exit;
  if f_bVisible then  begin
    while m_CS4.WaitStat do ;
    m_CS4.ExecuteMacro(PChar('[Display(F)]'),false);
  end
  else begin
     while m_CS4.WaitStat do ;
    m_CS4.ExecuteMacro(PChar('[Display(K)]'),false);
  end;
  m_bVisible:=f_bVisible;
end;


constructor TCodeSoft4.Create(AOwner : TCOmponent);
var iStartTime : cardinal;
begin
  inherited create(AOwner);

  try
    m_tsParameter:= tstringlist.Create;

    m_CS4:=TDdeClientConv.Create(self);
    m_CS4.ConnectMode:=ddeManual;
    m_CS4.DdeService:='CS';
    m_CS4.DdeTopic:='CS';
    m_CS4.ServiceApplication:=getCSPath;
    m_CS4.SetLink('CS','CS');

    iStartTime:=gettickcount+5000;
    while (GetTickCount<=iStartTime) and  (not m_CS4.OpenLink) do Sleep(200);
    if GetTickCount>iStartTime  then raise exception.create('Connect to CS4 false !!');
    m_bVisible:=true;
    Visibled:=false;
  except
    on E:Exception do raise Exception.Create('('+ClassName+'.Create)'+E.Message);
  end;
end;

destructor TCodeSoft4.destroy;
begin
  try
    closeLabelFile;
    m_cs4.PokeData('Close','1');
    m_cs4.CloseLink;
    m_CS4.Free;

    m_tsParameter.free;
  except
  end;

  inherited Destroy;
end;


procedure TCodeSoft4.print;
var i,iIndex : integer;
    tsParameter : tstrings;
begin
  tsParameter:=TStringList.create;
  try
    for i:=1 to m_PrintData.m_tsParam.count do tsParameter.add(uppercase(m_PrintData.m_tsParam[i-1]));

    for i:=1 to m_tsParameter.Count do begin
      iIndex:=tsParameter.IndexOf(uppercase(m_tsParameter[i-1]));

      while m_CS4.WaitStat do ;
      if iIndex>=0 then m_CS4.ExecuteMacro(PChar('[Set('+m_tsParameter[i-1]+','+m_printData.m_tsData[iIndex]+')]'),false);
    end;
  finally
    tsParameter.free;
  end;


  while m_CS4.WaitStat do ;
  m_CS4.ExecuteMacro(PChar('[PrintLabel('+IntToStr(m_printData.m_iQty)+')]'),false);
  while m_CS4.WaitStat do ;
  m_CS4.ExecuteMacro(PChar('[FormFeed()]'),false);
end;


function TCodeSoft4.getCSPath : string;
var sCSFilePath : string;
begin
  result:='';
  try
    with TIniFile.Create('Win.INI') do begin
      try
        sCSFilePath := ReadString('CS','Path','');
        if sCSFilePath = '' then sCSFilePath := ReadString('CS4DMX','Path','');
        if sCSFilePath = '' then sCSFilePath := ReadString('ELTPLUS','Path','');
        if sCSFilePath = '' then sCSFilePath := ReadString('LSPRO','Path','');
        if sCSFilePath = '' then sCSFilePath := ReadString('CSRUN','Path','');
        if sCSFilePath = '' then sCSFilePath := ReadString('DMXRUN','Path','');
        if sCSFilePath = '' then sCSFilePath := ReadString('ELTRUN','Path','');
        if sCSFilePath = '' then sCSFilePath := ReadString('LSRUN','Path','');
        if sCSFilePath = '' then sCSFilePath := ReadString('LWISE','Path','');
        if sCSFilePath = '' then sCSFilePath := ReadString('LWRUN','Path','');
        if sCSFilePath = '' then sCSFilePath := ReadString('IPAL','Path','');
        if sCSFilePath = '' then sCSFilePath := ReadString('IPALRUN','Path','');
        if sCSFilePath = '' then sCSFilePath := ReadString('IMPULS','Path','');
        if sCSFilePath = '' then sCSFilePath := ReadString('IMPRUN','Path','');
        if sCSFilePath = '' then sCSFilePath := ReadString('VITA','Path','');
        if sCSFilePath = '' then sCSFilePath := ReadString('VITARUN','Path','');
        if sCSFilePath = '' then exit;
      finally
        free;
      end;
    end;

    with TIniFile.Create(sCSFilePath+'\CS.INI') do begin
      try
        sCSFilePath := sCSFilePath +'\'+ReadString('General','ExeName','')
      finally
        free;
      end;
    end;

    if not FileExists(sCSFilePath) then exit;

    result:=sCSFilePath;
  except
  end;
end;



end.
