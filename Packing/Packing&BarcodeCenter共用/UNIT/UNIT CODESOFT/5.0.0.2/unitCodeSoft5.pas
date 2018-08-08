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
    m_tsParameter : tstrings;
  protected
    { ³B²zvisible¨Æ©y }
    procedure setVisible(f_bVisible : Boolean); override;
    function getVisible : boolean; override;
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

    for i:= 1 to m_tsParameter.Count do f_tsParameter.Add(m_tsParameter[i-1]);

    result:=true;
  except
    on E:Exception do f_sMessage:=E.Message;
  end;
end;


function TCodeSoft5.openSampleFile(f_sFileName:string;var f_sMessage : string): boolean;
var i : integer;
begin
  result:=false;
  try
    if not inherited openSampleFile(f_sFileName,f_sMessage) then exit;

    m_CS5.Document.QueryInterface(DIID_Document,m_Document);
    m_Document.Close(false);
    m_Document.Open(f_sFileName,true);
    m_Document.Variables.QueryInterface(DIID_Variables,m_Variables);

    m_tsParameter.Clear;
    for i:= 1  to  m_Variables.Count do begin
      m_Variables.Item[i].QueryInterface(DIID_Variable,m_parameter);
      m_tsParameter.Add(m_Parameter.Name);
    end;

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
    m_tsParameter:=TStringList.create;
    m_CS5:=TCS_5.Create(Self);
    m_CS5.AutoQuit:=true;
  except
    on E:Exception do raise Exception.Create('('+ClassName+'.Create)'+E.Message);
  end;
end;

destructor TCodeSoft5.destroy;
begin
  try
    m_tsParameter.free;
    m_CS5.free;
  except
  end;

  inherited Destroy;
end;



procedure TCodeSoft5.print;
var i : integer;
    iIndex : integer;
    tsParameter : tstrings;
begin
  tsParameter:=TStringList.create;
  try
    for i:=1 to m_PrintData.m_tsParam.count do tsParameter.add(uppercase(m_PrintData.m_tsParam[i-1]));

    for i:=1 to m_tsParameter.Count do begin
      iIndex:=tsParameter.IndexOf(uppercase(m_tsParameter[i-1]));
      m_Variables.Item[i].QueryInterface(DIID_Variable,m_parameter);

      if iIndex>=0 then m_Parameter.Value:=m_printData.m_tsData[iIndex];
    end;
  finally
    tsParameter.free;
  end;

  m_Document.Print(m_PrintData.m_iQty);
end;

end.
