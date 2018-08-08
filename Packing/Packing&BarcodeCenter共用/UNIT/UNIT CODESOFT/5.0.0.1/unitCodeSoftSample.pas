unit unitCodeSoftSample;

interface

uses classes,sysutils,unitLog;

type
  TPrintData=record
    m_bComplete : boolean;                      //代表USER是否下令開始PRINT
    m_iQty : integer;
    m_tsParam : tstrings;                       //儲存PARAMETER NAME的BUFFER
    m_tsData : tstrings;                         //儲存資料的BUFFER
  end;


  TCodeSoftSample = class(TComponent)
  private
  protected
    m_PrintData : TPrintData;
    m_sSampleFile : string;
    { 處理CODE SOFT是否要顯示的事宜 }
    procedure setVisible(f_bVisible : Boolean); virtual;
    function getVisible : boolean; virtual;
  public
    property Visibled : boolean read getVisible write setVisible;
    { 處理要列印的事宜 }
    function  selectPrinter(var f_sMessage : string) : boolean; virtual;
    function  addPrinter(var f_sMessage:string) : boolean; virtual;
    function  getParameter(var f_tsParameter : tstrings;var f_sMessage:string) : boolean; virtual;
    procedure setPrintQty(f_iQty:integer) ;
    procedure addPrintData(f_sParam,f_sData : string);  //新增要列印的資料
    procedure clearPrintData;                           //清除原先列印的資料
    procedure print; virtual;                           //列印
    { 處理COMPONENT的資源事宜 }
    constructor Create(AOwner : TCOmponent);  virtual;
    destructor destroy; override;
    { 處理open label file的事宜 }
    function openSampleFile(f_sFileName:string;var f_sMessage : string): boolean; virtual;
  end;

implementation

procedure TCodeSoftSample.setPrintQty(f_iQty:integer) ;
begin
  m_PrintData.m_iQty:=f_iQty;
end;


function  TCodeSoftSample.addPrinter(var f_sMessage : string) : boolean;
begin
  result:=false;
  f_sMessage := 'Not Define function';
end;


function  TCodeSoftSample.selectPrinter(var f_sMessage : string) : boolean;
begin
  result:=false;
  f_sMessage := 'Not Define function';
end;


function TCodeSoftSample.getParameter(var f_tsParameter : tstrings;var f_sMessage:string) : boolean;
begin
  result:=false;
  f_sMessage := 'Not Define function';
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

procedure TCodeSoftSample.addPrintData(f_sParam,f_sData : string);
begin
  m_PrintData.m_tsData.add(f_sData);
  m_PrintData.m_tsParam.add(f_sParam);
end;

procedure TCodeSoftSample.clearPrintData;
begin
  m_PrintData.m_tsData.Clear;
  m_PrintData.m_tsParam.Clear;
end;


function TCodeSoftSample.getVisible : boolean;
begin
  result:=false;
end;


constructor TCodeSoftSample.Create(AOwner : TCOmponent);
begin
  inherited Create(AOwner);

  m_PrintData.m_tsData:=TStringList.create;
  m_PrintData.m_tsParam:=TStringList.create;
  m_sSampleFile:='';
end;

procedure TCodeSoftSample.print ;
begin
end;


destructor TCodeSoftSample.destroy;
begin
  m_PrintData.m_tsData.free;
  m_PrintData.m_tsParam.free;

  inherited Destroy;
end;

procedure TCodeSoftSample.setVisible(f_bVisible : Boolean);
begin
end;

end.
