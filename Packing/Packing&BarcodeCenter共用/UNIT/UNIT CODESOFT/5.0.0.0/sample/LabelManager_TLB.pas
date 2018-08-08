unit LabelManager_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : $Revision:   1.130  $
// File generated on 2004/4/6 ¤W¤È 10:41:29 from Type Library described below.

// ************************************************************************  //
// Type Lib: E:\SAJET\Program\Common\Lppx.tlb (1)
// LIBID: {FDCF6309-0127-11D2-A5B0-00A02455FFDC}
// LCID: 0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT\System32\stdole2.tlb)
//   (2) v4.0 StdVCL, (C:\WINNT\System32\STDVCL40.DLL)
// Errors:
//   Hint: Member 'Type' of 'Variable' changed to 'Type_'
// ************************************************************************ //
// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}

interface

uses ActiveX, Classes, Graphics, OleServer, StdVCL, Variants, Windows;
  


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  LabelManagerMajorVersion = 5;
  LabelManagerMinorVersion = 0;

  LIBID_LabelManager: TGUID = '{FDCF6309-0127-11D2-A5B0-00A02455FFDC}';

  DIID_Document: TGUID = '{0D156CD3-125B-11D2-A5C1-00A02455FFDC}';
  DIID_Variables: TGUID = '{0D156CD6-125B-11D2-A5C1-00A02455FFDC}';
  DIID_Variable: TGUID = '{C547B200-DDF2-11D2-899B-00600872E6DE}';
  DIID_IApplication: TGUID = '{0D156CD9-125B-11D2-A5C1-00A02455FFDC}';
  CLASS_Application: TGUID = '{52A0A8C0-1886-11D1-A61E-00A0C943BFFD}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum enumVariableType
type
  enumVariableType = TOleEnum;
const
  ImportType = $00000000;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  Document = dispinterface;
  Variables = dispinterface;
  Variable = dispinterface;
  IApplication = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  Application = IApplication;


// *********************************************************************//
// DispIntf:  Document
// Flags:     (4096) Dispatchable
// GUID:      {0D156CD3-125B-11D2-A5C1-00A02455FFDC}
// *********************************************************************//
  Document = dispinterface
    ['{0D156CD3-125B-11D2-A5C1-00A02455FFDC}']
    property Variables: IDispatch dispid 1;
    property Name: WideString dispid 2;
    function  Close(Save: OleVariant): Smallint; dispid 3;
    function  Save: Smallint; dispid 4;
    function  SaveAs(const PathName: WideString): Smallint; dispid 5;
    function  Print(Quantity: Integer): Smallint; dispid 6;
    function  PrintLabel(Quantity: Integer; LabelCopy: OleVariant; InterCut: OleVariant; 
                         PageCopy: OleVariant; NoFrom: OleVariant; ToFile: OleVariant; 
                         FileName: OleVariant): Smallint; dispid 7;
    function  GeneratePOF(DestFileName: OleVariant; ModeleFileName: OleVariant): Smallint; dispid 8;
    function  DataBaseMerge(Quantity: Integer; LabelCopy: OleVariant; InterCut: OleVariant; 
                            PageCopy: OleVariant; NoFrom: OleVariant; ToFile: OleVariant; 
                            FileName: OleVariant): Smallint; dispid 9;
    function  Open(const PathName: WideString; ReadOnly: OleVariant): Smallint; dispid 10;
    function  Insert(const PathName: WideString): Smallint; dispid 11;
    function  CopyToClipboard: WordBool; dispid 12;
    function  SelectPrinter(const PrinterName: WideString): Smallint; dispid 13;
    function  FormFeed: Smallint; dispid 14;
    function  Escape(const Escape: WideString): WordBool; dispid 15;
  end;

// *********************************************************************//
// DispIntf:  Variables
// Flags:     (4096) Dispatchable
// GUID:      {0D156CD6-125B-11D2-A5C1-00A02455FFDC}
// *********************************************************************//
  Variables = dispinterface
    ['{0D156CD6-125B-11D2-A5C1-00A02455FFDC}']
    property Count: Smallint dispid 1;
    function  ShowFiller: Smallint; dispid 2;
    procedure SetFieldList(const FieldList: WideString); dispid 3;
    property Item[Key: OleVariant]: IDispatch readonly dispid 4;
    function  Add(Item: OleVariant): OleVariant; dispid 5;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// DispIntf:  Variable
// Flags:     (4096) Dispatchable
// GUID:      {C547B200-DDF2-11D2-899B-00600872E6DE}
// *********************************************************************//
  Variable = dispinterface
    ['{C547B200-DDF2-11D2-899B-00600872E6DE}']
    property Name: WideString dispid 1;
    property Value: WideString dispid 2;
    property Prompt: WideString dispid 3;
    property Length: Smallint dispid 4;
    property Type_: enumVariableType dispid 5;
  end;

// *********************************************************************//
// DispIntf:  IApplication
// Flags:     (4096) Dispatchable
// GUID:      {0D156CD9-125B-11D2-A5C1-00A02455FFDC}
// *********************************************************************//
  IApplication = dispinterface
    ['{0D156CD9-125B-11D2-A5C1-00A02455FFDC}']
    property Visible: WordBool dispid 1;
    property UserControl: WordBool dispid 2;
    property Document: IDispatch dispid 3;
    property ActiveDocument: IDispatch dispid 4;
    property PrinterName: WideString dispid 5;
    function  DataBaseOpenQuery(const PathName: WideString): Smallint; dispid 6;
    function  DataBaseClose: Smallint; dispid 7;
    function  GetLastError(var Item: OleVariant): Smallint; dispid 8;
    function  GetPrinters(var Item: OleVariant; AllPrinters: WordBool): Smallint; dispid 9;
    procedure AddPrinter; dispid 10;
    procedure ActivePrinterSetup; dispid 11;
    procedure Quit; dispid 12;
  end;

// *********************************************************************//
// The Class CoApplication provides a Create and CreateRemote method to          
// create instances of the default interface IApplication exposed by              
// the CoClass Application. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoApplication = class
    class function Create: IApplication;
    class function CreateRemote(const MachineName: string): IApplication;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TCS_5
// Help String      : 
// Default Interface: IApplication
// Def. Intf. DISP? : Yes
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TCS_5Properties= class;
{$ENDIF}
  TCS_5 = class(TOleServer)
  private
    FAutoQuit:    Boolean;
    FIntf:        IApplication;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TCS_5Properties;
    function      GetServerProperties: TCS_5Properties;
{$ENDIF}
    function      GetDefaultInterface: IApplication;
  protected
    procedure InitServerData; override;
    function Get_Visible: WordBool;
    procedure Set_Visible(Value: WordBool);
    function Get_UserControl: WordBool;
    procedure Set_UserControl(Value: WordBool);
    function Get_Document: IDispatch;
    procedure Set_Document(const Value: IDispatch);
    function Get_ActiveDocument: IDispatch;
    procedure Set_ActiveDocument(const Value: IDispatch);
    function Get_PrinterName: WideString;
    procedure Set_PrinterName(const Value: WideString);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IApplication);
    procedure Disconnect; override;
    function  DataBaseOpenQuery(const PathName: WideString): Smallint;
    function  DataBaseClose: Smallint;
    function  GetLastError(var Item: OleVariant): Smallint;
    function  GetPrinters(var Item: OleVariant; AllPrinters: WordBool): Smallint;
    procedure AddPrinter;
    procedure ActivePrinterSetup;
    procedure Quit;
    property  DefaultInterface: IApplication read GetDefaultInterface;
    property Document: IDispatch read Get_Document write Set_Document;
    property ActiveDocument: IDispatch read Get_ActiveDocument write Set_ActiveDocument;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property UserControl: WordBool read Get_UserControl write Set_UserControl;
    property PrinterName: WideString read Get_PrinterName write Set_PrinterName;
  published
    property AutoQuit: Boolean read FAutoQuit write FAutoQuit; 
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TCS_5Properties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TCS_5
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TCS_5Properties = class(TPersistent)
  private
    FServer:    TCS_5;
    function    GetDefaultInterface: IApplication;
    constructor Create(AServer: TCS_5);
  protected
    function Get_Visible: WordBool;
    procedure Set_Visible(Value: WordBool);
    function Get_UserControl: WordBool;
    procedure Set_UserControl(Value: WordBool);
    function Get_Document: IDispatch;
    procedure Set_Document(const Value: IDispatch);
    function Get_ActiveDocument: IDispatch;
    procedure Set_ActiveDocument(const Value: IDispatch);
    function Get_PrinterName: WideString;
    procedure Set_PrinterName(const Value: WideString);
  public
    property DefaultInterface: IApplication read GetDefaultInterface;
  published
    property Visible: WordBool read Get_Visible write Set_Visible;
    property UserControl: WordBool read Get_UserControl write Set_UserControl;
    property PrinterName: WideString read Get_PrinterName write Set_PrinterName;
  end;
{$ENDIF}


procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

implementation

uses ComObj;

class function CoApplication.Create: IApplication;
begin
  Result := CreateComObject(CLASS_Application) as IApplication;
end;

class function CoApplication.CreateRemote(const MachineName: string): IApplication;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Application) as IApplication;
end;

procedure TCS_5.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{52A0A8C0-1886-11D1-A61E-00A0C943BFFD}';
    IntfIID:   '{0D156CD9-125B-11D2-A5C1-00A02455FFDC}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TCS_5.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IApplication;
  end;
end;

procedure TCS_5.ConnectTo(svrIntf: IApplication);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TCS_5.DisConnect;
begin
  if Fintf <> nil then
  begin
    if FAutoQuit then
      Quit();
    FIntf := nil;
  end;
end;

function TCS_5.GetDefaultInterface: IApplication;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TCS_5.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TCS_5Properties.Create(Self);
{$ENDIF}
end;

destructor TCS_5.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TCS_5.GetServerProperties: TCS_5Properties;
begin
  Result := FProps;
end;
{$ENDIF}

function TCS_5.Get_Visible: WordBool;
begin
  Result := DefaultInterface.Visible;
end;

procedure TCS_5.Set_Visible(Value: WordBool);
begin
  DefaultInterface.Visible := Value;
end;

function TCS_5.Get_UserControl: WordBool;
begin
  Result := DefaultInterface.UserControl;
end;

procedure TCS_5.Set_UserControl(Value: WordBool);
begin
  DefaultInterface.UserControl := Value;
end;

function TCS_5.Get_Document: IDispatch;
begin
  Result := DefaultInterface.Document;
end;

procedure TCS_5.Set_Document(const Value: IDispatch);
begin
  DefaultInterface.Document := Value;
end;

function TCS_5.Get_ActiveDocument: IDispatch;
begin
  Result := DefaultInterface.ActiveDocument;
end;

procedure TCS_5.Set_ActiveDocument(const Value: IDispatch);
begin
  DefaultInterface.ActiveDocument := Value;
end;

function TCS_5.Get_PrinterName: WideString;
begin
  Result := DefaultInterface.PrinterName;
end;

procedure TCS_5.Set_PrinterName(const Value: WideString);
begin
  DefaultInterface.PrinterName := Value;
end;

function  TCS_5.DataBaseOpenQuery(const PathName: WideString): Smallint;
begin
  DefaultInterface.DataBaseOpenQuery(PathName);
end;

function  TCS_5.DataBaseClose: Smallint;
begin
  DefaultInterface.DataBaseClose;
end;

function  TCS_5.GetLastError(var Item: OleVariant): Smallint;
begin
  DefaultInterface.GetLastError(Item);
end;

function  TCS_5.GetPrinters(var Item: OleVariant; AllPrinters: WordBool): Smallint;
begin
  DefaultInterface.GetPrinters(Item, AllPrinters);
end;

procedure TCS_5.AddPrinter;
begin
  DefaultInterface.AddPrinter;
end;

procedure TCS_5.ActivePrinterSetup;
begin
  DefaultInterface.ActivePrinterSetup;
end;

procedure TCS_5.Quit;
begin
  DefaultInterface.Quit;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TCS_5Properties.Create(AServer: TCS_5);
begin
  inherited Create;
  FServer := AServer;
end;

function TCS_5Properties.GetDefaultInterface: IApplication;
begin
  Result := FServer.DefaultInterface;
end;

function TCS_5Properties.Get_Visible: WordBool;
begin
  Result := DefaultInterface.Visible;
end;

procedure TCS_5Properties.Set_Visible(Value: WordBool);
begin
  DefaultInterface.Visible := Value;
end;

function TCS_5Properties.Get_UserControl: WordBool;
begin
  Result := DefaultInterface.UserControl;
end;

procedure TCS_5Properties.Set_UserControl(Value: WordBool);
begin
  DefaultInterface.UserControl := Value;
end;

function TCS_5Properties.Get_Document: IDispatch;
begin
  Result := DefaultInterface.Document;
end;

procedure TCS_5Properties.Set_Document(const Value: IDispatch);
begin
  DefaultInterface.Document := Value;
end;

function TCS_5Properties.Get_ActiveDocument: IDispatch;
begin
  Result := DefaultInterface.ActiveDocument;
end;

procedure TCS_5Properties.Set_ActiveDocument(const Value: IDispatch);
begin
  DefaultInterface.ActiveDocument := Value;
end;

function TCS_5Properties.Get_PrinterName: WideString;
begin
  Result := DefaultInterface.PrinterName;
end;

procedure TCS_5Properties.Set_PrinterName(const Value: WideString);
begin
  DefaultInterface.PrinterName := Value;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TCS_5]);
end;

end.
