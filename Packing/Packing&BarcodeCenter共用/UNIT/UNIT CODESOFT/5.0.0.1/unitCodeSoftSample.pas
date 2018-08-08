unit unitCodeSoftSample;

interface

uses classes,sysutils,unitLog;

type
  TPrintData=record
    m_bComplete : boolean;                      //�N��USER�O�_�U�O�}�lPRINT
    m_iQty : integer;
    m_tsParam : tstrings;                       //�x�sPARAMETER NAME��BUFFER
    m_tsData : tstrings;                         //�x�s��ƪ�BUFFER
  end;


  TCodeSoftSample = class(TComponent)
  private
  protected
    m_PrintData : TPrintData;
    m_sSampleFile : string;
    { �B�zCODE SOFT�O�_�n��ܪ��Ʃy }
    procedure setVisible(f_bVisible : Boolean); virtual;
    function getVisible : boolean; virtual;
  public
    property Visibled : boolean read getVisible write setVisible;
    { �B�z�n�C�L���Ʃy }
    function  selectPrinter(var f_sMessage : string) : boolean; virtual;
    function  addPrinter(var f_sMessage:string) : boolean; virtual;
    function  getParameter(var f_tsParameter : tstrings;var f_sMessage:string) : boolean; virtual;
    procedure setPrintQty(f_iQty:integer) ;
    procedure addPrintData(f_sParam,f_sData : string);  //�s�W�n�C�L�����
    procedure clearPrintData;                           //�M������C�L�����
    procedure print; virtual;                           //�C�L
    { �B�zCOMPONENT���귽�Ʃy }
    constructor Create(AOwner : TCOmponent);  virtual;
    destructor destroy; override;
    { �B�zopen label file���Ʃy }
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
    //���p�ǤJ�����|�O�ŭȡA�N��O�nCLOSE SAMPLE FILE
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
