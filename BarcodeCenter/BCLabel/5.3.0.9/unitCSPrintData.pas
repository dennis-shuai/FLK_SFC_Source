unit unitCSPrintData;

interface

uses classes,sysutils,unitConvert,DIALOGS;

type
  TCSPrintData=class(TComponent)
  public
    m_bComplete : boolean;                      //代表USER是否下令開始PRINT
    m_sSampleFile : string;                     //要列印的sample file名稱
    m_iQty : integer;                           //
    m_tsParam : tstrings;                       //儲存PARAMETER NAME的BUFFER
    m_tsData : tstrings;                         //儲存資料的BUFFER
    m_iVerstion : integer;
    //Add by doing
    m_iLabelQty : integer;
    m_iLabelRowQty : integer;
    m_iLabelColQty : integer;
    m_iLabelSeq : integer;
    constructor Create(AOwner : Tcomponent); override;
    destructor Destroy ;override;
    procedure clear;
    function encodePrintData : string;
    procedure decodePrintData(f_sData:string);
    procedure assignData(f_sParam,f_sData : string);
  end;


implementation

procedure TCSPrintData.assignData(f_sParam,f_sData : string);
begin
  m_tsParam.Add(f_sParam);
  m_tsData.add(f_sData);
end;

procedure TCSPrintData.decodePrintData(f_sData:string);
var tsPrintData : tstrings;
begin
  try
    tsPrintData:=TStringList.create;
    try
      G_convertEncodeStringToTstrings(f_sData,tsPrintData);
      //if tsPrintData.Count<>5 then raise Exception.create('Print Data illegeal ('+INTTOSTR(tsPrintData.Count)+')');
      if tsPrintData.Count<>9 then raise Exception.create('Print Data illegeal ('+INTTOSTR(tsPrintData.Count)+')');

      clear;
      m_iVerstion:=strtoint(tsPrintData[0]);
      m_sSampleFile:=tsPrintData[1];
      m_iQty:=strtoint(tsPrintData[2]);
      G_convertEncodeStringToTstrings(tsPrintData[3],m_tsParam);
      G_convertEncodeStringToTstrings(tsPrintData[4],m_tsData);
      //Add by doing
      m_iLabelQty:=strtoint(tsPrintData[5]);
      m_iLabelRowQty:=strtoint(tsPrintData[6]);
      m_iLabelColQty:=strtoint(tsPrintData[7]);
      m_iLabelSeq:=strtoint(tsPrintData[8]);
      //Add by doing

      if m_sSampleFile<>'' then begin
        if (not FileExists(m_sSampleFile)) then raise Exception.create('Sample File not Exist('+m_sSampleFile+')');
        if uppercase(ExtractFileExt(m_sSampleFile))<>'.LAB' then raise Exception.Create('Sample File Type Error')
      end;

      if m_iQty<=0 then m_iQty:=1;
      if not m_iVerstion in [0,4,5,6] then raise Exception.Create('Unknow CS Version');
      if m_tsData.count<>m_tsParam.count then raise Exception.Create('Parameter Count Not Match');
    finally
      tsPrintData.free;
    end;
  except
    on E:Exception do raise Exception.create('Decode Print Data Error -- '+E.Message);
  end;
end;

function TCSPrintData.encodePrintData : string;
var tsPrintData : tstrings;
begin
  if m_sSampleFile<>'' then begin
    if (not FileExists(m_sSampleFile)) then raise Exception.create('Sample File not Exist('+m_sSampleFile+')');
    if uppercase(ExtractFileExt(m_sSampleFile))<>'.LAB' then raise Exception.Create('Sample File Type Error')
  end;

  if m_tsData.count<>m_tsParam.count then raise Exception.Create('Parameter Count Not Match');

  tsPrintData:=TStringList.create;
  try
    tsPrintData.Add(inttostr(m_iVerstion));
    tsPrintData.Add(m_sSampleFile);
    tsPrintData.add(inttostr(m_iQty));
    tsPrintData.Add(G_convertTstringsToEncodeString(m_tsParam));
    tsPrintData.Add(G_convertTstringsToEncodeString(m_tsData));
    //Add by doing
    tsPrintData.add(inttostr(m_iLabelQty));
    tsPrintData.add(inttostr(m_iLabelRowQty));
    tsPrintData.add(inttostr(m_iLabelColQty));
    tsPrintData.add(inttostr(m_iLabelSeq));
    result:=G_convertTstringsToEncodeString(tsPrintData);
  finally
    tsPrintData.free;
  end;
end;


procedure TCSPrintData.clear;
begin
  m_sSampleFile:='';
  m_iQty:=1;
  //Add by doing
  m_iLabelQty:=1;
  m_iLabelRowQty:=1;
  m_iLabelColQty:=1;
  m_iLabelSeq:=1;
  m_iVerstion:=0;
  m_tsParam.clear;
  m_tsData.Clear;
end;


constructor TCSPrintData.Create(AOwner : Tcomponent);
begin
  inherited Create(AOwner);
  m_bComplete := false;
  m_sSampleFile := '';
  m_iQty := 1;
  //Add by doing
  m_iLabelQty:=1;
  m_iLabelRowQty:=1;
  m_iLabelColQty:=1;
  m_iLabelSeq:=1;
  m_tsParam := TStringList.create;
  m_tsData := TStringList.create;
  m_iVerstion:=0;
end;

destructor TCSPrintData.Destroy ;
begin
  m_tsParam.free;
  m_tsData.free;
  inherited Destroy;
end;

end.
