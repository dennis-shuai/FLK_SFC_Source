unit unitCodeSoft5;

interface

uses classes,sysutils,unitCodeSoftSample,unitLog,LabelManager_TLB,dialogs;

type
  TCodeSoft5=class(TCodeSoftSample)
  private
    m_CS5 : TCS_5;
    m_Document  : Document;
    m_Variables : Variables;
    m_Parameter  : Variable;
    function getVariable(f_iIndex : integer) : boolean;
  protected
    { ³B²zvisible¨Æ©y }
    procedure setVisible(f_bVisible : Boolean); override;
    function getVisible : boolean; override;
    function getParamIndex(f_sParam : string) : integer;
  public
    function  selectPrinter(var f_sMessage : string) : boolean;  override;
    function  addPrinter(var f_sMessage : string) : boolean;  override;
    function  getParameter(var f_tsParameter : tstrings;var f_sMessage:string) : boolean; override;
    function openSampleFile(f_sFileName:string;var f_sMessage : string): boolean; override;
    constructor Create(AOwner : TCOmponent);  override;
    destructor destroy; override;
    procedure print; override;
  end;

implementation

function TCodeSoft5.getVariable(f_iIndex : integer) : boolean;
begin
  result:=false;
  if f_iIndex>m_Variables.count then exit;
  m_Variables.Item[f_iIndex].QueryInterface(DIID_Variable,m_parameter);
  result:=true;
end;


function  TCodeSoft5.addPrinter(var f_sMessage : string) : boolean;
begin
  result:=false;
  try
    m_CS5.ActivePrinterSetup;
    result:=true;
  except
    on E:Exception do  f_sMessage:=E.Message;
  end;
end;


function  TCodeSoft5.selectPrinter(var f_sMessage : string) : boolean;
begin
  result:=false;
  try
    m_CS5.AddPrinter;
    result:=true;
  except
    on E:Exception do  f_sMessage:=E.Message;
  end;
end;

function TCodeSoft5.getParameter(var f_tsParameter : tstrings;var f_sMessage:string) : boolean;
var i : integer;
begin
  result:=false;
  try
    f_tsParameter.Clear;

    for i:=1 to m_Variables.Count do begin
      if not getVariable(i) then raise Exception.Create('Get Parameter Fail');
      f_tsParameter.Add(m_Parameter.Name);
    end;

    result:=true;
  except
    on E:Exception do f_sMessage:=E.Message;
  end;
end;


function TCodeSoft5.openSampleFile(f_sFileName:string;var f_sMessage : string): boolean;
begin
  result:=false;
  try
    if not inherited openSampleFile(f_sFileName,f_sMessage) then exit;

    m_CS5.Document.QueryInterface(DIID_Document,m_Document);
    m_Document.Close(false);
    m_Document.Open(f_sFileName,true);
    m_Document.Variables.QueryInterface(DIID_Variables,m_Variables);

    result:=true;
  except
    on E:Exception do f_sMessage:='Error : '+E.Message;
  end;
end;


function TCodeSoft5.getVisible : boolean;
begin
  result:=m_CS5.Visible;
end;


procedure TCodeSoft5.setVisible(f_bVisible : Boolean);
begin
  m_CS5.Visible:=f_bVisible;
end;


constructor TCodeSoft5.Create(AOwner : TCOmponent);
begin
  inherited create(AOwner);

  try
    m_CS5:=TCS_5.Create(Self);
    m_CS5.AutoQuit:=true;
  except
    on E:Exception do raise Exception.Create('('+ClassName+'.Create)'+E.Message);
  end;
end;

destructor TCodeSoft5.destroy;
begin
  try
    m_CS5.free;
  except
  end;

  inherited Destroy;
end;


function TCodeSoft5.getParamIndex(f_sParam : string) : integer;
var i : integer;
begin
  result:=0;
  f_sParam:=UpperCase(f_sParam);

  for i:=1 to m_Variables.Count do begin
    if not getVariable(i) then exit;

    if UpperCase(m_Parameter.Name)=f_sParam then begin
      result:=i;
      exit;
    end;
  end;
end;


procedure TCodeSoft5.print;
var i : integer;
    iIndex : integer;
begin
  for i:=1 to m_PrintData.m_tsParam.Count do begin
    iIndex:=getParamIndex(m_PrintData.m_tsParam[i-1]);
    if iIndex=0 then Continue;
    if not getVariable(iIndex) then Continue;
    m_Parameter.Value:=m_PrintData.m_tsData[i-1];
  end;

  m_Document.Print(m_PrintData.m_iQty);
end;

end.
