unit unitCodeSoft6;

interface

uses classes,sysutils,unitCodeSoftSample,unitLog,LabelManager2_TLB,dialogs;

type
  TCodeSoft6=class(TCodeSoftSample)
  private
    m_CS6 : TCS_6;
  protected
    { 處理visible事宜 }
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

function  TCodeSoft6.addPrinter(var f_sMessage : string) : boolean;
begin
  result:=false;
  try
    m_cs6.Dialogs.Item(lppxPrinterSetupDialog).Show;
    result:=true;
  except
    on E:Exception do  f_sMessage:=E.Message;
  end;
end;


function  TCodeSoft6.selectPrinter(var f_sMessage : string) : boolean;
begin
  result:=false;
  try
    m_cs6.Dialogs.Item(lppxPrinterSelectDialog).Show;
    result:=true;
  except
    on E:Exception do  f_sMessage:=E.Message;
  end;
end;

function TCodeSoft6.getParameter(var f_tsParameter : tstrings;var f_sMessage:string) : boolean;
var i : integer;
begin
  result:=false;
  try
    for i:=1 to m_CS6.ActiveDocument.Variables.FormVariables.Count do f_tsParameter.Add(m_CS6.ActiveDocument.Variables.FormVariables.item(i).Name);
    result:=true;
  except
    on E:Exception do f_sMessage:=E.Message;
  end;
end;


function TCodeSoft6.openSampleFile(f_sFileName:string;var f_sMessage : string): boolean;
begin
  result:=false;
  try
    if not inherited openSampleFile(f_sFileName,f_sMessage) then exit;

    m_CS6.Documents.CloseAll(false);
    if f_sFileName<>'' then m_CS6.Documents.Open(f_sFileName,True);

    result:=true;
  except
    on E:Exception do f_sMessage:='Error : '+E.Message;
  end;
end;


function TCodeSoft6.getVisible : boolean;
begin
  result:=m_CS6.Visible;
end;


procedure TCodeSoft6.setVisible(f_bVisible : Boolean);
begin
  m_CS6.Visible:=f_bVisible;
end;


constructor TCodeSoft6.Create(AOwner : TCOmponent);
begin
  inherited create(AOwner);

  try
    m_CS6:=TCS_6.Create(Self);
    m_CS6.Locked:=true;                 //設定不讓user修改
    m_CS6.AutoQuit:=true;               //設定程式結束時，會自動close掉code soft
  except
    on E:Exception do raise Exception.Create('('+ClassName+'.Create)'+E.Message);
  end;
end;

destructor TCodeSoft6.destroy;
begin
  try
    m_CS6.free;
  except
  end;

  inherited Destroy;
end;


function TCodeSoft6.getParamIndex(f_sParam : string) : integer;
var i : integer;
begin
  result:=0;
  f_sParam:=UpperCase(f_sParam);
  for i:=1 to m_CS6.ActiveDocument.Variables.FormVariables.Count do begin
    if f_sParam=UpperCase(m_CS6.ActiveDocument.Variables.FormVariables.Item(i).Name) then begin
      result:=i;
      exit;
    end;
  end;
end;


procedure TCodeSoft6.print;
var i : integer;
    iIndex : integer;
begin
  for i:=1 to m_PrintData.m_tsParam.Count do begin
    iIndex:=getParamIndex(m_PrintData.m_tsParam[i-1]);
    if iIndex=0 then Continue;
    m_CS6.ActiveDocument.Variables.FormVariables.Item(i).Value:=m_PrintData.m_tsData[i-1];
  end;

  m_CS6.ActiveDocument.PrintDocument(m_PrintData.m_iQty);
end;

end.
