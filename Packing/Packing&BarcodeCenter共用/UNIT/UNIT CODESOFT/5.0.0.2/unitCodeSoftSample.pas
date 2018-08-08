unit unitCodeSoftSample;

interface

uses classes,sysutils,unitLog,unitCSPrintData;

type


  TCodeSoftSample = class(TComponent)
  private
  protected
    { 處理CODE SOFT是否要顯示的事宜 }
    procedure setVisible(f_bVisible : Boolean); virtual;
    function m_printData : TCSPrintData;
    function getVisible : boolean; virtual;
  public
    property Visibled : boolean read getVisible write setVisible;
    { 處理要列印的事宜 }
    function  selectPrinter(var f_sMessage : string) : boolean; virtual;
    function  addPrinter(var f_sMessage:string) : boolean; virtual;
    function  getParameter(var f_tsParameter : tstrings;var f_sMessage:string) : boolean; virtual;
    procedure print; virtual;                           //列印
    procedure LoadPrintData(f_PrintData : TCSPrintData);
    { 處理COMPONENT的資源事宜 }
    constructor Create(AOwner : TCOmponent);  virtual;
    destructor destroy; override;
    { 處理open label file的事宜 }
    function openSampleFile(f_sFileName:string;var f_sMessage : string): boolean; virtual;
  end;

implementation

uses unitCodeSoft;

procedure TCodeSoftSample.LoadPrintData(f_PrintData : TCSPrintData);
var i : integer;
begin
  m_PrintData.m_iVerstion:=f_PrintData.m_iVerstion;
  m_PrintData.m_bComplete:=f_PrintData.m_bComplete;
  m_PrintData.m_iQty:=f_PrintData.m_iQty;
  m_PrintData.m_sSampleFile:=f_PrintData.m_sSampleFile;
  m_PrintData.m_tsParam.Clear;
  m_PrintData.m_tsData.Clear;
  for i:=1 to f_PrintData.m_tsParam.Count do m_PrintData.m_tsParam.Add(f_PrintData.m_tsParam[i-1]);
  for i:=1 to f_PrintData.m_tsData.Count do m_PrintData.m_tsData.Add(f_PrintData.m_tsData[i-1]);
end;


function  TCodeSoftSample.addPrinter(var f_sMessage : string) : boolean;
begin
  result:=false;
  f_sMessage := 'Not Support this Function';
end;


function  TCodeSoftSample.selectPrinter(var f_sMessage : string) : boolean;
begin
  result:=false;
  f_sMessage := 'Not Support this Function';
end;


function TCodeSoftSample.getParameter(var f_tsParameter : tstrings;var f_sMessage:string) : boolean;
begin
  result:=false;
  f_sMessage := 'Not Support this Function';
end;

function TCodeSoftSample.openSampleFile(f_sFileName:string;var f_sMessage : string): boolean;
begin
  result:=false;
  try
    //假如傳入的路徑是空值，代表是要CLOSE SAMPLE FILE
    if f_sFileName<>'' then begin
      if not FileExists(f_sFileName) then raise Exception.create('File ('+f_sFileName+') not Exist !!');
      if UpperCase(ExtractFileExt(f_sFileName))<>'.LAB' then raise Exception.create('File Type ('+UpperCase(ExtractFileExt(f_sFileName))+') Error !!');
    end;

    result:=true;
  except
    on E:Exception do f_sMessage:=E.Message;
  end;
end;


function TCodeSoftSample.getVisible : boolean;
begin
  result:=false;
end;


constructor TCodeSoftSample.Create(AOwner : TCOmponent);
begin
  inherited Create(AOwner);
end;

procedure TCodeSoftSample.print ;
begin
end;


destructor TCodeSoftSample.destroy;
begin
  inherited Destroy;
end;

procedure TCodeSoftSample.setVisible(f_bVisible : Boolean);
begin
end;

function TCodeSoftSample.m_printData : TCSPrintData;
begin
  if not (Owner is TCodeSoft) then raise Exception.create('Unknow Owner')
  else result:=(Owner as TCodeSoft).m_aTsPrintData[0];
end;


end.
