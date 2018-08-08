unit LabelManager2_TLB;

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
// File generated on 2004/4/6 ¤W¤È 10:39:05 from Type Library described below.

// ************************************************************************  //
// Type Lib: E:\SAJET\Program\Common\Lppx2.tlb (1)
// LIBID: {3624B9C2-9E5D-11D3-A896-00C04F324E22}
// LCID: 0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT\System32\stdole2.tlb)
//   (2) v4.0 StdVCL, (C:\WINNT\System32\STDVCL40.DLL)
// Errors:
//   Hint: Parameter 'Type' of DocObjects.Add changed to 'Type_'
//   Hint: Member 'Type' of 'Text' changed to 'Type_'
//   Hint: Parameter 'Var' of Text.InsertVariable changed to 'Var_'
//   Hint: Parameter 'Var' of Text.AppendVariable changed to 'Var_'
//   Hint: Member 'Type' of 'Barcode' changed to 'Type_'
//   Hint: Member 'Type' of 'Image' changed to 'Type_'
//   Hint: Member 'Type' of 'Shape' changed to 'Type_'
//   Hint: Member 'Type' of 'OLEObject' changed to 'Type_'
//   Hint: Member 'Object' of 'OLEObject' changed to 'Object_'
//   Hint: Member 'Type' of 'DocObject' changed to 'Type_'
//   Hint: Member 'Type' of 'DocumentProperty' changed to 'Type_'
//   Hint: Member 'Type' of 'Dialog' changed to 'Type_'
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
  LabelManager2MajorVersion = 6;
  LabelManager2MinorVersion = 0;

  LIBID_LabelManager2: TGUID = '{3624B9C2-9E5D-11D3-A896-00C04F324E22}';

  DIID_IApplication: TGUID = '{3624B9C3-9E5D-11D3-A896-00C04F324E22}';
  DIID_Documents: TGUID = '{3624B9CB-9E5D-11D3-A896-00C04F324E22}';
  DIID_IDocument: TGUID = '{3624B9C6-9E5D-11D3-A896-00C04F324E22}';
  DIID_Variables: TGUID = '{3624B9CF-9E5D-11D3-A896-00C04F324E22}';
  DIID_FreeVariables: TGUID = '{3624B9D3-9E5D-11D3-A896-00C04F324E22}';
  DIID_Free: TGUID = '{3624B9E8-9E5D-11D3-A896-00C04F324E22}';
  DIID_FormVariables: TGUID = '{3624B9D1-9E5D-11D3-A896-00C04F324E22}';
  DIID_DatabaseVariables: TGUID = '{3624B9D2-9E5D-11D3-A896-00C04F324E22}';
  DIID_Counters: TGUID = '{3624B9D5-9E5D-11D3-A896-00C04F324E22}';
  DIID_Counter: TGUID = '{3624B9E5-9E5D-11D3-A896-00C04F324E22}';
  DIID_Formulas: TGUID = '{3624B9D4-9E5D-11D3-A896-00C04F324E22}';
  DIID_Formula: TGUID = '{3624B9E7-9E5D-11D3-A896-00C04F324E22}';
  DIID_TableLookups: TGUID = '{3624B9D6-9E5D-11D3-A896-00C04F324E22}';
  DIID_TableLookup: TGUID = '{3624B9E9-9E5D-11D3-A896-00C04F324E22}';
  DIID_Dates: TGUID = '{3624B9D7-9E5D-11D3-A896-00C04F324E22}';
  DIID_Variable: TGUID = '{3624B9DD-9E5D-11D3-A896-00C04F324E22}';
  DIID_DocObjects: TGUID = '{3624B9D0-9E5D-11D3-A896-00C04F324E22}';
  DIID_Texts: TGUID = '{3624B9D8-9E5D-11D3-A896-00C04F324E22}';
  DIID_Text: TGUID = '{3624B9DF-9E5D-11D3-A896-00C04F324E22}';
  DIID_TextSelection: TGUID = '{3624B9EE-9E5D-11D3-A896-00C04F324E22}';
  DIID_Barcodes: TGUID = '{3624B9D9-9E5D-11D3-A896-00C04F324E22}';
  DIID_Barcode: TGUID = '{3624B9E0-9E5D-11D3-A896-00C04F324E22}';
  DIID_Code2D: TGUID = '{3624B9E4-9E5D-11D3-A896-00C04F324E22}';
  DIID_Images: TGUID = '{3624B9DA-9E5D-11D3-A896-00C04F324E22}';
  DIID_Image: TGUID = '{3624B9E3-9E5D-11D3-A896-00C04F324E22}';
  DIID_Shapes: TGUID = '{3624B9DB-9E5D-11D3-A896-00C04F324E22}';
  DIID_Shape: TGUID = '{3624B9E2-9E5D-11D3-A896-00C04F324E22}';
  DIID_OLEObjects: TGUID = '{3624B9DC-9E5D-11D3-A896-00C04F324E22}';
  DIID_OLEObject: TGUID = '{3624B9E1-9E5D-11D3-A896-00C04F324E22}';
  DIID_DocObject: TGUID = '{3624B9DE-9E5D-11D3-A896-00C04F324E22}';
  DIID_Printer: TGUID = '{3624B9CC-9E5D-11D3-A896-00C04F324E22}';
  DIID_Strings: TGUID = '{3624B9CA-9E5D-11D3-A896-00C04F324E22}';
  DIID_Format: TGUID = '{3624B9CE-9E5D-11D3-A896-00C04F324E22}';
  DIID_Database: TGUID = '{3624B9CD-9E5D-11D3-A896-00C04F324E22}';
  DIID_DocumentProperties: TGUID = '{3624B9EA-9E5D-11D3-A896-00C04F324E22}';
  DIID_DocumentProperty: TGUID = '{3624B9EB-9E5D-11D3-A896-00C04F324E22}';
  DIID_Dialogs: TGUID = '{3624B9C8-9E5D-11D3-A896-00C04F324E22}';
  DIID_Dialog: TGUID = '{3624B9C9-9E5D-11D3-A896-00C04F324E22}';
  DIID_Options: TGUID = '{3624B9C7-9E5D-11D3-A896-00C04F324E22}';
  DIID_RecentFiles: TGUID = '{3624B9ED-9E5D-11D3-A896-00C04F324E22}';
  DIID_RecentFile: TGUID = '{3624B9EC-9E5D-11D3-A896-00C04F324E22}';
  DIID_PrinterSystem: TGUID = '{3624B9EF-9E5D-11D3-A896-00C04F324E22}';
  DIID_INotifyApplicationEvent: TGUID = '{3624B9C4-9E5D-11D3-A896-00C04F324E22}';
  DIID_INotifyDocumentEvent: TGUID = '{3624B9C5-9E5D-11D3-A896-00C04F324E22}';
  DIID_Date: TGUID = '{3624B9E6-9E5D-11D3-A896-00C04F324E22}';
  CLASS_Application: TGUID = '{3624B9C0-9E5D-11D3-A896-00C04F324E22}';
  CLASS_Document: TGUID = '{3624B9C1-9E5D-11D3-A896-00C04F324E22}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum enumKindOfPrinters
type
  enumKindOfPrinters = TOleEnum;
const
  lppxInternalPrinters = $00000001;
  lppxWindowsPrinters = $00000002;
  lppxAllPrinters = $00000003;

// Constants for enum enumTriggerForm
type
  enumTriggerForm = TOleEnum;
const
  lppxNever = $00000001;
  lppxForEachSerie = $00000002;
  lppxForEachLabel = $00000003;

// Constants for enum enumDataSource
type
  enumDataSource = TOleEnum;
const
  lppxDataSourceCounter = $00000001;
  lppxDataSourceTableLookup = $00000002;
  lppxDataSourceDate = $00000003;
  lppxDataSourceFormula = $00000004;
  lppxDataSourceFree = $00000005;
  lppxDataSourceForm = $00000006;
  lppxDataSourceDataBase = $00000007;

// Constants for enum enumRotation
type
  enumRotation = TOleEnum;
const
  lppxNoRotation = $00000000;
  lppx90DegreeRight = $00000A8C;
  lppxUpSideDown = $00000708;
  lppx90DegreeLeft = $00000384;

// Constants for enum enumAlignment
type
  enumAlignment = TOleEnum;
const
  lppxAlignLeft = $00000000;
  lppxAlignCenter = $00000001;
  lppxAlignRight = $00000002;

// Constants for enum enumHRPosition
type
  enumHRPosition = TOleEnum;
const
  lppxHRNone = $00000000;
  lppxHRBelow = $00000001;
  lppxHRAbove = $00000002;
  lppxHRFree = $00000003;

// Constants for enum enumCheckMode
type
  enumCheckMode = TOleEnum;
const
  lppxNone = $00000000;
  lppx1Digit = $00000001;
  lppx2Digits = $00000002;
  lppxMod11Mod10 = $00000003;

// Constants for enum enumAnchorPoint
type
  enumAnchorPoint = TOleEnum;
const
  lppxTopLeft = $00000001;
  lppxTopCenter = $00000002;
  lppxTopRight = $00000003;
  lppxCenterLeft = $00000004;
  lppxCenter = $00000005;
  lppxCenterRight = $00000006;
  lppxBottomLeft = $00000007;
  lppxBottomCenter = $00000008;
  lppxBottomRight = $00000009;

// Constants for enum enumCounterBase
type
  enumCounterBase = TOleEnum;
const
  lppxBaseBinary = $00000002;
  lppxBaseOctal = $00000008;
  lppxBaseDecimal = $0000000A;
  lppxBaseHexadecimal = $00000010;
  lppxBaseAlphabetic = $0000001A;
  lppxBaseAlphaNumeric = $00000024;
  lppxBaseCustom = $000000FF;

// Constants for enum enumDocObject
type
  enumDocObject = TOleEnum;
const
  lppxObjectText = $00000001;
  lppxObjectBarCode = $00000002;
  lppxObjectImage = $00000003;
  lppxObjectLine = $00000004;
  lppxObjectRectangle = $00000005;
  lppxObjectEllipse = $00000006;
  lppxObjectPolygon = $00000007;
  lppxObjectOblique = $00000008;
  lppxObjectRoundRect = $00000009;
  lppxObjectOLEObject = $0000000A;

// Constants for enum enumWindowState
type
  enumWindowState = TOleEnum;
const
  lppxNormal = $00000001;
  lppxMinimized = $00000002;
  lppxMaximized = $00000003;

// Constants for enum enumViewMode
type
  enumViewMode = TOleEnum;
const
  lppxViewModeName = $00000001;
  lppxViewModeSize = $00000002;
  lppxViewModeValue = $00000003;
  lppxViewModeForm = $00000004;

// Constants for enum enumMeasureSystem
type
  enumMeasureSystem = TOleEnum;
const
  lppxMillimeter = $00000000;
  lppxInch = $00000001;

// Constants for enum enumDialogType
type
  enumDialogType = TOleEnum;
const
  lppxPrinterSelectDialog = $00000001;
  lppxOptionsDialog = $00000002;
  lppxFormDialog = $00000003;
  lppxPrinterSetupDialog = $00000004;
  lppxPageSetupDialog = $00000005;
  lppxDocumentPropertiesDialog = $00000006;

// Constants for enum enumTriggerMode
type
  enumTriggerMode = TOleEnum;
const
  lppxNumberOfPrintedLabels = $00000001;
  lppxResetOfAnotherCounter = $00000002;

// Constants for enum enumBuiltinDocumentProperty
type
  enumBuiltinDocumentProperty = TOleEnum;
const
  lppxPropertyManager = $00000001;
  lppxPropertyCompany = $00000002;
  lppxPropertyCategory = $00000003;
  lppxPropertyTitle = $00000004;
  lppxPropertySubject = $00000005;
  lppxPropertyAuthor = $00000006;
  lppxPropertyKeywords = $00000007;
  lppxPropertyComments = $00000008;

// Constants for enum enumProperty
type
  enumProperty = TOleEnum;
const
  lppxPropertyTypeNumber = $00000001;
  lppxPropertyTypeBoolean = $00000002;
  lppxPropertyTypeDate = $00000003;
  lppxPropertyTypeString = $00000004;
  lppxPropertyTypeFloat = $00000005;

// Constants for enum enumEndPrinting
type
  enumEndPrinting = TOleEnum;
const
  lppxEndOfJob = $00000001;
  lppxCancelled = $00000002;
  lppxSystemFailure = $00000003;

// Constants for enum enumPausedReasonPrinting
type
  enumPausedReasonPrinting = TOleEnum;
const
  lppxGenericError = $00000000;
  lppxNoPaper = $00000002;
  lppxNoRibbon = $00000003;
  lppxPortNotAvailable = $00000004;
  lppxPrinterNotReady = $00000005;
  lppxCommunicationError = $00000006;
  lppxHeadLifted = $00000007;

// Constants for enum enumLanguage
type
  enumLanguage = TOleEnum;
const
  lppxEnglish = $00000001;
  lppxFrench = $00000002;
  lppxGerman = $00000003;
  lppxItalian = $00000004;
  lppxSpanish = $00000005;
  lppxDanish = $00000006;
  lppxSwedish = $00000007;
  lppxJapanese = $00000008;
  lppxHungarian = $00000009;
  lppxDutch = $0000000A;
  lppxCzech = $0000000B;
  lppxNorwegian = $0000000C;
  lppxFinnish = $0000000D;
  lppxPortuguese = $0000000E;
  lppxSimplifiedChinese = $0000000F;
  lppxTraditionalChinese = $00000010;
  lppxKorean = $00000011;

// Constants for enum enumSymbology
type
  enumSymbology = TOleEnum;
const
  lppxCode11 = $00000031;
  lppx25Interleave = $00000032;
  lppxCode39 = $00000033;
  lppxCode49 = $00000034;
  lppxMaxicode = $00000035;
  lppxCode16K = $00000036;
  lppxGermanPostcode = $00000037;
  lppxEAN8 = $00000038;
  lppxUPCE = $00000039;
  lppxBC412 = $0000003A;
  lppxMicroPDF = $0000003B;
  lppxCode93 = $00000041;
  lppx25Beared = $00000042;
  lppxCode128 = $00000043;
  lppxEAN128 = $00000044;
  lppxEAN13 = $00000045;
  lppxCode39Full = $00000046;
  lppxCode128Auto = $00000047;
  lppxCodablockF = $00000048;
  lppx25Industrial = $00000049;
  lppx25Standard = $0000004A;
  lppxCodabar = $0000004B;
  lppxLogmars = $0000004C;
  lppxMsi = $0000004D;
  lppxCodablockA = $0000004E;
  lppxPostnet = $0000004F;
  lppxPlessey = $00000050;
  lppxCode128SSCC = $00000051;
  lppxUPCExtended = $00000053;
  lppxUPCA = $00000055;
  lppxUPCEXT2 = $00000056;
  lppxUPCEXT5 = $00000057;
  lppxCode25PRDG = $00000058;
  lppxUPCWEIGHT = $00000059;
  lppxUPCEPLUS2 = $00000061;
  lppxUPCEPLUS5 = $00000062;
  lppxUPCAPLUS2 = $00000063;
  lppxUPCAPLUS5 = $00000064;
  lppxEAN8PLUS2 = $00000065;
  lppxEAN8PLUS5 = $00000066;
  lppxEAN13PLUS2 = $00000067;
  lppxEAN13PLUS5 = $00000068;
  lppxITF = $00000069;
  lppx25MatrixEuropean = $0000006A;
  lppx25MatrixJapan = $0000006B;
  lppxDatamatrix = $00000078;
  lppxItf14 = $00000079;
  lppxPdf = $0000007A;
  lppxQrcode = $0000007B;
  lppxRss = $0000007C;
  lppxComposite = $0000007D;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IApplication = dispinterface;
  Documents = dispinterface;
  IDocument = dispinterface;
  Variables = dispinterface;
  FreeVariables = dispinterface;
  Free = dispinterface;
  FormVariables = dispinterface;
  DatabaseVariables = dispinterface;
  Counters = dispinterface;
  Counter = dispinterface;
  Formulas = dispinterface;
  Formula = dispinterface;
  TableLookups = dispinterface;
  TableLookup = dispinterface;
  Dates = dispinterface;
  Variable = dispinterface;
  DocObjects = dispinterface;
  Texts = dispinterface;
  Text = dispinterface;
  TextSelection = dispinterface;
  Barcodes = dispinterface;
  Barcode = dispinterface;
  Code2D = dispinterface;
  Images = dispinterface;
  Image = dispinterface;
  Shapes = dispinterface;
  Shape = dispinterface;
  OLEObjects = dispinterface;
  OLEObject = dispinterface;
  DocObject = dispinterface;
  Printer = dispinterface;
  Strings = dispinterface;
  Format = dispinterface;
  Database = dispinterface;
  DocumentProperties = dispinterface;
  DocumentProperty = dispinterface;
  Dialogs = dispinterface;
  Dialog = dispinterface;
  Options = dispinterface;
  RecentFiles = dispinterface;
  RecentFile = dispinterface;
  PrinterSystem = dispinterface;
  INotifyApplicationEvent = dispinterface;
  INotifyDocumentEvent = dispinterface;
  Date = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  Application = IApplication;
  Document = IDocument;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PTDateTime1 = ^TDateTime; {*}


// *********************************************************************//
// DispIntf:  IApplication
// Flags:     (4096) Dispatchable
// GUID:      {3624B9C3-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  IApplication = dispinterface
    ['{3624B9C3-9E5D-11D3-A896-00C04F324E22}']
    property Visible: WordBool dispid 1;
    property UserControl: WordBool dispid 2;
    property Documents: Documents dispid 3;
    property Dialogs: Dialogs dispid 4;
    property Parent: IDispatch dispid 5;
    property Caption: WideString dispid 6;
    property DefaultFilePath: WideString dispid 7;
    property FullName: WideString dispid 8;
    property Name: WideString dispid 9;
    property _Name: WideString dispid 0;
    property Path: WideString dispid 10;
    property Application: IApplication dispid 11;
    property Options: Options dispid 12;
    property Version: WideString dispid 13;
    property Width: Integer dispid 14;
    property Height: Integer dispid 15;
    property Left: Integer dispid 16;
    property Top: Integer dispid 17;
    property ActiveDocument: IDocument dispid 18;
    property Locked: WordBool dispid 19;
    property RecentFiles: RecentFiles dispid 20;
    property EnableEvents: WordBool dispid 21;
    property ActivePrinterName: WideString dispid 22;
    procedure Quit; dispid 23;
    function  PrinterSystem: PrinterSystem; dispid 24;
    procedure Resize(Width: Integer; Height: Integer); dispid 25;
    procedure Move(Left: Integer; Top: Integer); dispid 26;
    procedure ShowHelp(const strHelpFile: WideString; HelpContextID: Integer); dispid 27;
    function  GetLastError: Smallint; dispid 28;
    function  ErrorMessage(ErrorCode: Smallint): WideString; dispid 29;
  end;

// *********************************************************************//
// DispIntf:  Documents
// Flags:     (4096) Dispatchable
// GUID:      {3624B9CB-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Documents = dispinterface
    ['{3624B9CB-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Application: IApplication dispid 2;
    property Parent: IDispatch dispid 3;
    property _NewEnum: IUnknown dispid -4;
    property DefaultExt: WideString dispid 4;
    function  Add(const Key: WideString): IDocument; dispid 5;
    function  Item(Key: OleVariant): IDocument; dispid 6;
    function  _Item(Key: OleVariant): IDocument; dispid 0;
    function  Open(const strDocName: WideString; ReadOnly: WordBool): IDocument; dispid 7;
    procedure SaveAll(AlwaysPrompt: WordBool); dispid 8;
    procedure CloseAll(Save: WordBool); dispid 9;
  end;

// *********************************************************************//
// DispIntf:  IDocument
// Flags:     (4096) Dispatchable
// GUID:      {3624B9C6-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  IDocument = dispinterface
    ['{3624B9C6-9E5D-11D3-A896-00C04F324E22}']
    property Variables: Variables dispid 1;
    property Name: WideString dispid 2;
    property _Name: WideString dispid 0;
    property DocObjects: DocObjects dispid 3;
    property Printer: Printer dispid 4;
    property Format: Format dispid 5;
    property Database: Database dispid 6;
    property Application: IApplication dispid 7;
    property Parent: IDispatch dispid 8;
    property FullName: WideString dispid 9;
    property ReadOnly: WordBool dispid 10;
    property ViewMode: enumViewMode dispid 11;
    property WindowState: enumWindowState dispid 12;
    property BuiltInDocumentProperties: DocumentProperties dispid 13;
    property TriggerForm: enumTriggerForm dispid 14;
    property ViewOrientation: enumRotation dispid 15;
    property IsModified: WordBool dispid 16;
    function  Save: Smallint; dispid 17;
    function  SaveAs(const strPathName: WideString): Smallint; dispid 18;
    function  PrintDocument(Quantity: Integer): Smallint; dispid 19;
    function  PrintLabel(Quantity: Integer; LabelCopy: Integer; InterCut: Integer; 
                         PageCopy: Integer; NoFrom: Integer; const FileName: WideString): Smallint; dispid 20;
    function  GeneratePOF(const DestFileName: WideString; const ModeleFileName: WideString): Smallint; dispid 21;
    function  Merge(Quantity: Integer; LabelCopy: Integer; InterCut: Integer; PageCopy: Integer; 
                    NoFrom: Integer; const FileName: WideString): Smallint; dispid 22;
    function  Insert(const strPathName: WideString): Smallint; dispid 23;
    function  CopyToClipboard: WordBool; dispid 24;
    function  FormFeed: Smallint; dispid 25;
    procedure Close(Save: WordBool); dispid 26;
    procedure Activate; dispid 27;
    function  CopyImageToFile(Colors: Smallint; const Extension: WideString; Rotation: Smallint; 
                              Percent: Smallint; const FileName: WideString): WideString; dispid 28;
  end;

// *********************************************************************//
// DispIntf:  Variables
// Flags:     (4096) Dispatchable
// GUID:      {3624B9CF-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Variables = dispinterface
    ['{3624B9CF-9E5D-11D3-A896-00C04F324E22}']
    property FreeVariables: FreeVariables dispid 1;
    property FormVariables: FormVariables dispid 2;
    property DatabaseVariables: DatabaseVariables dispid 3;
    property Counters: Counters dispid 4;
    property Formulas: Formulas dispid 5;
    property TableLookups: TableLookups dispid 6;
    property Dates: Dates dispid 7;
    property Count: Smallint dispid 8;
    property Parent: IDispatch dispid 9;
    property Application: IApplication dispid 10;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: OleVariant): Variable; dispid 11;
    function  _Item(Key: OleVariant): Variable; dispid 0;
    function  Add(Item1: OleVariant; Item2: OleVariant): Variable; dispid 12;
    procedure Remove(Key: OleVariant); dispid 13;
  end;

// *********************************************************************//
// DispIntf:  FreeVariables
// Flags:     (4096) Dispatchable
// GUID:      {3624B9D3-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  FreeVariables = dispinterface
    ['{3624B9D3-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Parent: IDispatch dispid 2;
    property Application: IApplication dispid 3;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: OleVariant): Free; dispid 4;
    function  _Item(Key: OleVariant): Free; dispid 0;
    function  Add(Key: OleVariant): Free; dispid 5;
    procedure Remove(Key: OleVariant); dispid 6;
  end;

// *********************************************************************//
// DispIntf:  Free
// Flags:     (4096) Dispatchable
// GUID:      {3624B9E8-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Free = dispinterface
    ['{3624B9E8-9E5D-11D3-A896-00C04F324E22}']
    property Name: WideString dispid 1;
    property Value: WideString dispid 2;
    property _Value: WideString dispid 0;
    property DataSource: enumDataSource dispid 3;
    property Parent: IDispatch dispid 4;
    property Application: IApplication dispid 5;
    property Increment: OleVariant dispid 257;
    property ISO: Integer dispid 258;
    property BaseType: enumCounterBase dispid 259;
    property TriggerMode: enumTriggerMode dispid 260;
    property TriggerParameter: OleVariant dispid 261;
    property CustomSet: WideString dispid 262;
    property MaxValue: OleVariant dispid 263;
    property ResetToValue: OleVariant dispid 264;
    property Prefix: WideString dispid 265;
    property Suffix: WideString dispid 266;
    property PadCharacter: WideString dispid 267;
    property DecimalUse: WordBool dispid 268;
    property NumberOfDecimals: Smallint dispid 269;
    property DecimalSeparator: WideString dispid 270;
    property ThousandSeparator: WideString dispid 271;
    property CounterUse: Integer dispid 513;
    property FormOrder: Smallint dispid 514;
    property FormPrompt: WideString dispid 515;
    property DisplayInForm: WordBool dispid 516;
    property InputMask: WideString dispid 517;
    property Shared: WordBool dispid 518;
    property Length: Integer dispid 519;
    property PadLength: Smallint dispid 520;
  end;

// *********************************************************************//
// DispIntf:  FormVariables
// Flags:     (4096) Dispatchable
// GUID:      {3624B9D1-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  FormVariables = dispinterface
    ['{3624B9D1-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Parent: IDispatch dispid 2;
    property Application: IApplication dispid 3;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: OleVariant): Free; dispid 4;
    function  _Item(Key: OleVariant): Free; dispid 0;
    function  Add(Key: OleVariant): Free; dispid 5;
    procedure Remove(Key: OleVariant); dispid 6;
  end;

// *********************************************************************//
// DispIntf:  DatabaseVariables
// Flags:     (4096) Dispatchable
// GUID:      {3624B9D2-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  DatabaseVariables = dispinterface
    ['{3624B9D2-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Parent: IDispatch dispid 2;
    property Application: IApplication dispid 3;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: OleVariant): Free; dispid 4;
    function  _Item(Key: OleVariant): Free; dispid 0;
    function  Add(Key: OleVariant): Free; dispid 5;
    procedure Remove(Key: OleVariant); dispid 6;
  end;

// *********************************************************************//
// DispIntf:  Counters
// Flags:     (4096) Dispatchable
// GUID:      {3624B9D5-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Counters = dispinterface
    ['{3624B9D5-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Parent: IDispatch dispid 2;
    property Application: IApplication dispid 3;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: OleVariant): Counter; dispid 4;
    function  _Item(Key: OleVariant): Counter; dispid 0;
    function  Add(Key: OleVariant): Counter; dispid 5;
    procedure Remove(Key: OleVariant); dispid 6;
  end;

// *********************************************************************//
// DispIntf:  Counter
// Flags:     (4096) Dispatchable
// GUID:      {3624B9E5-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Counter = dispinterface
    ['{3624B9E5-9E5D-11D3-A896-00C04F324E22}']
    property Name: WideString dispid 1;
    property Value: WideString dispid 2;
    property _Value: WideString dispid 0;
    property DataSource: enumDataSource dispid 3;
    property Parent: IDispatch dispid 4;
    property Application: IApplication dispid 5;
    property Increment: OleVariant dispid 257;
    property ISO: Integer dispid 258;
    property BaseType: enumCounterBase dispid 259;
    property TriggerMode: enumTriggerMode dispid 260;
    property TriggerParameter: OleVariant dispid 261;
    property CustomSet: WideString dispid 262;
    property MaxValue: OleVariant dispid 263;
    property ResetToValue: OleVariant dispid 264;
    property Prefix: WideString dispid 265;
    property Suffix: WideString dispid 266;
    property PadCharacter: WideString dispid 267;
    property DecimalUse: WordBool dispid 268;
    property NumberOfDecimals: Smallint dispid 269;
    property DecimalSeparator: WideString dispid 270;
    property ThousandSeparator: WideString dispid 271;
  end;

// *********************************************************************//
// DispIntf:  Formulas
// Flags:     (4096) Dispatchable
// GUID:      {3624B9D4-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Formulas = dispinterface
    ['{3624B9D4-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Parent: IDispatch dispid 2;
    property Application: IApplication dispid 3;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: OleVariant): Formula; dispid 4;
    function  _Item(Key: OleVariant): Formula; dispid 0;
    function  Add(Key: OleVariant): Formula; dispid 5;
    procedure Remove(Key: OleVariant); dispid 6;
  end;

// *********************************************************************//
// DispIntf:  Formula
// Flags:     (4096) Dispatchable
// GUID:      {3624B9E7-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Formula = dispinterface
    ['{3624B9E7-9E5D-11D3-A896-00C04F324E22}']
    property Name: WideString dispid 1;
    property Value: WideString dispid 2;
    property _Value: WideString dispid 0;
    property DataSource: enumDataSource dispid 3;
    property Parent: IDispatch dispid 4;
    property Application: IApplication dispid 5;
    property Increment: OleVariant dispid 257;
    property ISO: Integer dispid 258;
    property BaseType: enumCounterBase dispid 259;
    property TriggerMode: enumTriggerMode dispid 260;
    property TriggerParameter: OleVariant dispid 261;
    property CustomSet: WideString dispid 262;
    property MaxValue: OleVariant dispid 263;
    property ResetToValue: OleVariant dispid 264;
    property Prefix: WideString dispid 265;
    property Suffix: WideString dispid 266;
    property PadCharacter: WideString dispid 267;
    property DecimalUse: WordBool dispid 268;
    property NumberOfDecimals: Smallint dispid 269;
    property DecimalSeparator: WideString dispid 270;
    property ThousandSeparator: WideString dispid 271;
    property CounterUse: Integer dispid 513;
    property Expression: WideString dispid 514;
    property Length: Integer dispid 515;
    property PadLength: Smallint dispid 516;
    function  Test: WordBool; dispid 517;
  end;

// *********************************************************************//
// DispIntf:  TableLookups
// Flags:     (4096) Dispatchable
// GUID:      {3624B9D6-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  TableLookups = dispinterface
    ['{3624B9D6-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Parent: IDispatch dispid 2;
    property Application: IApplication dispid 3;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: OleVariant): TableLookup; dispid 4;
    function  _Item(Key: OleVariant): TableLookup; dispid 0;
    function  Add(Key: OleVariant): TableLookup; dispid 5;
    procedure Remove(Key: OleVariant); dispid 6;
  end;

// *********************************************************************//
// DispIntf:  TableLookup
// Flags:     (4096) Dispatchable
// GUID:      {3624B9E9-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  TableLookup = dispinterface
    ['{3624B9E9-9E5D-11D3-A896-00C04F324E22}']
    property Name: WideString dispid 1;
    property Value: WideString dispid 2;
    property _Value: WideString dispid 0;
    property DataSource: enumDataSource dispid 3;
    property Parent: IDispatch dispid 4;
    property Application: IApplication dispid 5;
    property Increment: OleVariant dispid 257;
    property ISO: Integer dispid 258;
    property BaseType: enumCounterBase dispid 259;
    property TriggerMode: enumTriggerMode dispid 260;
    property TriggerParameter: OleVariant dispid 261;
    property CustomSet: WideString dispid 262;
    property MaxValue: OleVariant dispid 263;
    property ResetToValue: OleVariant dispid 264;
    property Prefix: WideString dispid 265;
    property Suffix: WideString dispid 266;
    property PadCharacter: WideString dispid 267;
    property DecimalUse: WordBool dispid 268;
    property NumberOfDecimals: Smallint dispid 269;
    property DecimalSeparator: WideString dispid 270;
    property ThousandSeparator: WideString dispid 271;
    property CounterUse: Integer dispid 513;
    property DatabaseSource: WideString dispid 514;
    property TableName: WideString dispid 515;
    property ResultField: WideString dispid 516;
    property Keys: WideString dispid 517;
    property Length: Integer dispid 518;
    property PadLength: Smallint dispid 519;
    procedure AddKey(const strField: WideString; const strVariableName: WideString); dispid 520;
    procedure DeleteKey(const strField: WideString); dispid 521;
  end;

// *********************************************************************//
// DispIntf:  Dates
// Flags:     (4096) Dispatchable
// GUID:      {3624B9D7-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Dates = dispinterface
    ['{3624B9D7-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Parent: IDispatch dispid 2;
    property Application: IApplication dispid 3;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: OleVariant): {??PTDateTime1}OleVariant; dispid 4;
    function  _Item(Key: OleVariant): {??PTDateTime1}OleVariant; dispid 0;
    function  Add(Key: OleVariant): {??PTDateTime1}OleVariant; dispid 5;
    procedure Remove(Key: OleVariant); dispid 6;
  end;

// *********************************************************************//
// DispIntf:  Variable
// Flags:     (4096) Dispatchable
// GUID:      {3624B9DD-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Variable = dispinterface
    ['{3624B9DD-9E5D-11D3-A896-00C04F324E22}']
    property Name: WideString dispid 1;
    property Value: WideString dispid 2;
    property _Value: WideString dispid 0;
    property DataSource: enumDataSource dispid 3;
    property Parent: IDispatch dispid 4;
    property Application: IApplication dispid 5;
  end;

// *********************************************************************//
// DispIntf:  DocObjects
// Flags:     (4096) Dispatchable
// GUID:      {3624B9D0-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  DocObjects = dispinterface
    ['{3624B9D0-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Parent: IDispatch dispid 2;
    property Application: IApplication dispid 3;
    property _NewEnum: IUnknown dispid -4;
    property Texts: Texts dispid 4;
    property Barcodes: Barcodes dispid 5;
    property Images: Images dispid 6;
    property Shapes: Shapes dispid 7;
    property OLEObjects: OLEObjects dispid 8;
    function  Item(Key: OleVariant): DocObject; dispid 9;
    function  _Item(Key: OleVariant): DocObject; dispid 0;
    function  Add(Type_: enumDocObject; Key: OleVariant): DocObject; dispid 10;
    procedure Remove(Key: OleVariant); dispid 11;
  end;

// *********************************************************************//
// DispIntf:  Texts
// Flags:     (4096) Dispatchable
// GUID:      {3624B9D8-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Texts = dispinterface
    ['{3624B9D8-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Parent: IDispatch dispid 2;
    property Application: IApplication dispid 3;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: OleVariant): Text; dispid 4;
    function  _Item(Key: OleVariant): Text; dispid 0;
    function  Add(Key: OleVariant): Text; dispid 5;
    procedure Remove(Key: OleVariant); dispid 6;
  end;

// *********************************************************************//
// DispIntf:  Text
// Flags:     (4096) Dispatchable
// GUID:      {3624B9DF-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Text = dispinterface
    ['{3624B9DF-9E5D-11D3-A896-00C04F324E22}']
    property Left: Integer dispid 1;
    property Top: Integer dispid 2;
    property Width: Integer dispid 3;
    property Height: Integer dispid 4;
    property Name: WideString dispid 5;
    property _Name: WideString dispid 0;
    property Type_: enumDocObject dispid 6;
    property Application: IApplication dispid 7;
    property Parent: IDispatch dispid 8;
    property Locked: Integer dispid 9;
    property Printable: Integer dispid 10;
    property AnchorPoint: enumAnchorPoint dispid 11;
    property Rotation: Integer dispid 12;
    property BackColor: Integer dispid 13;
    property ForeColor: Integer dispid 14;
    property Font: IFontDisp dispid 257;
    property Value: WideString dispid 258;
    property WordWrap: Integer dispid 259;
    property WordHyphenation: Integer dispid 260;
    property FitToFrame: Integer dispid 261;
    property Alignment: enumAlignment dispid 262;
    property VariableObject: Variable dispid 263;
    property VariableName: WideString dispid 264;
    property SelText: TextSelection dispid 265;
    procedure Move(X: Integer; Y: Integer); dispid 15;
    procedure Bound(Left: Integer; Top: Integer; Right: Integer; Bottom: Integer); dispid 16;
    procedure InsertString(const strString: WideString; Position: OleVariant; const Font: IFontDisp); dispid 266;
    procedure InsertTextObject(const TextObject: Text; Position: OleVariant); dispid 267;
    procedure InsertVariable(const Var_: Variable; Position: OleVariant; const Font: IFontDisp); dispid 268;
    procedure InsertCRLF(Position: OleVariant; const Font: IFontDisp); dispid 269;
    procedure AppendString(const strString: WideString; Position: OleVariant; const Font: IFontDisp); dispid 270;
    procedure AppendTextObject(const TextObject: Text); dispid 271;
    procedure AppendVariable(const Var_: Variable; const Font: IFontDisp); dispid 272;
    procedure AppendCRLF(const Font: IFontDisp); dispid 273;
    procedure Copy; dispid 274;
    procedure Paste(Position: OleVariant); dispid 275;
  end;

// *********************************************************************//
// DispIntf:  TextSelection
// Flags:     (4096) Dispatchable
// GUID:      {3624B9EE-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  TextSelection = dispinterface
    ['{3624B9EE-9E5D-11D3-A896-00C04F324E22}']
    property Font: IFontDisp dispid 1;
    property Value: WideString dispid 2;
    property BackColor: Integer dispid 3;
    property ForeColor: Integer dispid 4;
    property IsEmpty: WordBool dispid 5;
    procedure Select(FirstPosition: OleVariant; LastPosition: OleVariant); dispid 6;
    procedure Cut; dispid 7;
    procedure Copy; dispid 8;
    procedure Paste; dispid 9;
  end;

// *********************************************************************//
// DispIntf:  Barcodes
// Flags:     (4096) Dispatchable
// GUID:      {3624B9D9-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Barcodes = dispinterface
    ['{3624B9D9-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Parent: IDispatch dispid 2;
    property Application: IApplication dispid 3;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: OleVariant): Barcode; dispid 4;
    function  _Item(Key: OleVariant): Barcode; dispid 0;
    function  Add(Key: OleVariant): Barcode; dispid 5;
    procedure Remove(Key: OleVariant); dispid 6;
  end;

// *********************************************************************//
// DispIntf:  Barcode
// Flags:     (4096) Dispatchable
// GUID:      {3624B9E0-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Barcode = dispinterface
    ['{3624B9E0-9E5D-11D3-A896-00C04F324E22}']
    property Left: Integer dispid 1;
    property Top: Integer dispid 2;
    property Width: Integer dispid 3;
    property Height: Integer dispid 4;
    property Name: WideString dispid 5;
    property _Name: WideString dispid 0;
    property Type_: enumDocObject dispid 6;
    property Application: IApplication dispid 7;
    property Parent: IDispatch dispid 8;
    property Locked: Integer dispid 9;
    property Printable: Integer dispid 10;
    property AnchorPoint: enumAnchorPoint dispid 11;
    property Rotation: Integer dispid 12;
    property BackColor: Integer dispid 13;
    property ForeColor: Integer dispid 14;
    property BarHeight: Integer dispid 257;
    property NarrowBarWidth: Integer dispid 258;
    property Ratio: Smallint dispid 259;
    property CheckMode: enumCheckMode dispid 260;
    property Device: Integer dispid 261;
    property Code2D: Code2D dispid 262;
    property Value: WideString dispid 263;
    property VariableName: WideString dispid 264;
    property Symbology: enumSymbology dispid 265;
    property VariableObject: Variable dispid 266;
    property HRGap: Integer dispid 267;
    property HRAlignment: enumAlignment dispid 268;
    property HRPosition: enumHRPosition dispid 269;
    property HRCheckCharacter: Integer dispid 270;
    property HRFont: IFontDisp dispid 271;
    property HRFreeTextObject: Text dispid 272;
    property HRDevice: WordBool dispid 273;
    procedure Move(X: Integer; Y: Integer); dispid 15;
    procedure Bound(Left: Integer; Top: Integer; Right: Integer; Bottom: Integer); dispid 16;
  end;

// *********************************************************************//
// DispIntf:  Code2D
// Flags:     (4096) Dispatchable
// GUID:      {3624B9E4-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Code2D = dispinterface
    ['{3624B9E4-9E5D-11D3-A896-00C04F324E22}']
    property ModuleX: Integer dispid 1;
    property ModuleY: Integer dispid 2;
    property Columns: Integer dispid 3;
    property Rows: Integer dispid 4;
    property ECC: WideString dispid 5;
    procedure SetOption(const strOptionName: WideString; varValue: OleVariant); dispid 6;
  end;

// *********************************************************************//
// DispIntf:  Images
// Flags:     (4096) Dispatchable
// GUID:      {3624B9DA-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Images = dispinterface
    ['{3624B9DA-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Parent: IDispatch dispid 2;
    property Application: IApplication dispid 3;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: OleVariant): Image; dispid 4;
    function  _Item(Key: OleVariant): Image; dispid 0;
    function  Add(Key: OleVariant): Image; dispid 5;
    procedure Remove(Key: OleVariant); dispid 6;
  end;

// *********************************************************************//
// DispIntf:  Image
// Flags:     (4096) Dispatchable
// GUID:      {3624B9E3-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Image = dispinterface
    ['{3624B9E3-9E5D-11D3-A896-00C04F324E22}']
    property Left: Integer dispid 1;
    property Top: Integer dispid 2;
    property Width: Integer dispid 3;
    property Height: Integer dispid 4;
    property Name: WideString dispid 5;
    property _Name: WideString dispid 0;
    property Type_: enumDocObject dispid 6;
    property Application: IApplication dispid 7;
    property Parent: IDispatch dispid 8;
    property Locked: Integer dispid 9;
    property Printable: Integer dispid 10;
    property AnchorPoint: enumAnchorPoint dispid 11;
    property Rotation: Integer dispid 12;
    property BackColor: Integer dispid 13;
    property ForeColor: Integer dispid 14;
    property FileName: WideString dispid 257;
    property VertFlip: Integer dispid 258;
    property HorzFlip: Integer dispid 259;
    property Negative: Integer dispid 260;
    property Brightness: Smallint dispid 261;
    property VariableObject: Variable dispid 262;
    property VariableName: WideString dispid 263;
    procedure Move(X: Integer; Y: Integer); dispid 15;
    procedure Bound(Left: Integer; Top: Integer; Right: Integer; Bottom: Integer); dispid 16;
  end;

// *********************************************************************//
// DispIntf:  Shapes
// Flags:     (4096) Dispatchable
// GUID:      {3624B9DB-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Shapes = dispinterface
    ['{3624B9DB-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Parent: IDispatch dispid 2;
    property Application: IApplication dispid 3;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: OleVariant): Shape; dispid 4;
    function  _Item(Key: OleVariant): Shape; dispid 0;
    procedure Remove(Key: OleVariant); dispid 5;
    function  AddLine(Left: Integer; Top: Integer; Right: Integer; Bottom: Integer): Shape; dispid 257;
    function  AddOblique(Left: Integer; Top: Integer; Right: Integer; Bottom: Integer): Shape; dispid 258;
    function  AddPolygon(Key: OleVariant): Shape; dispid 259;
    function  AddRectangle(Left: Integer; Top: Integer; Right: Integer; Bottom: Integer): Shape; dispid 260;
    function  AddRoundRect(Left: Integer; Top: Integer; Right: Integer; Bottom: Integer; 
                           Radius: Integer): Shape; dispid 261;
    function  AddEllipse(Left: Integer; Top: Integer; Right: Integer; Bottom: Integer): Shape; dispid 262;
  end;

// *********************************************************************//
// DispIntf:  Shape
// Flags:     (4096) Dispatchable
// GUID:      {3624B9E2-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Shape = dispinterface
    ['{3624B9E2-9E5D-11D3-A896-00C04F324E22}']
    property Left: Integer dispid 1;
    property Top: Integer dispid 2;
    property Width: Integer dispid 3;
    property Height: Integer dispid 4;
    property Name: WideString dispid 5;
    property _Name: WideString dispid 0;
    property Type_: enumDocObject dispid 6;
    property Application: IApplication dispid 7;
    property Parent: IDispatch dispid 8;
    property Locked: Integer dispid 9;
    property Printable: Integer dispid 10;
    property AnchorPoint: enumAnchorPoint dispid 11;
    property Rotation: Integer dispid 12;
    property BackColor: Integer dispid 13;
    property ForeColor: Integer dispid 14;
    property LineWidth: Integer dispid 257;
    procedure Move(X: Integer; Y: Integer); dispid 15;
    procedure Bound(Left: Integer; Top: Integer; Right: Integer; Bottom: Integer); dispid 16;
    procedure SetPoints(pts: OleVariant); dispid 258;
  end;

// *********************************************************************//
// DispIntf:  OLEObjects
// Flags:     (4096) Dispatchable
// GUID:      {3624B9DC-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  OLEObjects = dispinterface
    ['{3624B9DC-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Parent: IDispatch dispid 2;
    property Application: IApplication dispid 3;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: OleVariant): OLEObject; dispid 4;
    function  _Item(Key: OleVariant): OLEObject; dispid 0;
    function  Add(Key: OleVariant): OLEObject; dispid 5;
    procedure Remove(Key: OleVariant); dispid 6;
  end;

// *********************************************************************//
// DispIntf:  OLEObject
// Flags:     (4096) Dispatchable
// GUID:      {3624B9E1-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  OLEObject = dispinterface
    ['{3624B9E1-9E5D-11D3-A896-00C04F324E22}']
    property Left: Integer dispid 1;
    property Top: Integer dispid 2;
    property Width: Integer dispid 3;
    property Height: Integer dispid 4;
    property Name: WideString dispid 5;
    property _Name: WideString dispid 0;
    property Type_: enumDocObject dispid 6;
    property Application: IApplication dispid 7;
    property Parent: IDispatch dispid 8;
    property Locked: Integer dispid 9;
    property Printable: Integer dispid 10;
    property AnchorPoint: enumAnchorPoint dispid 11;
    property Rotation: Integer dispid 12;
    property BackColor: Integer dispid 13;
    property ForeColor: Integer dispid 14;
    property Object_: IDispatch dispid 257;
    procedure Move(X: Integer; Y: Integer); dispid 15;
    procedure Bound(Left: Integer; Top: Integer; Right: Integer; Bottom: Integer); dispid 16;
    function  EmbedFile(const strFileName: WideString): WordBool; dispid 258;
    function  LinkFile(const strLinkFileName: WideString): WordBool; dispid 259;
    function  ConnectServer(const strCLSIDOrServerName: WideString): WordBool; dispid 260;
  end;

// *********************************************************************//
// DispIntf:  DocObject
// Flags:     (4096) Dispatchable
// GUID:      {3624B9DE-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  DocObject = dispinterface
    ['{3624B9DE-9E5D-11D3-A896-00C04F324E22}']
    property Left: Integer dispid 1;
    property Top: Integer dispid 2;
    property Width: Integer dispid 3;
    property Height: Integer dispid 4;
    property Name: WideString dispid 5;
    property _Name: WideString dispid 0;
    property Type_: enumDocObject dispid 6;
    property Application: IApplication dispid 7;
    property Parent: IDispatch dispid 8;
    property Locked: Integer dispid 9;
    property Printable: Integer dispid 10;
    property AnchorPoint: enumAnchorPoint dispid 11;
    property Rotation: Integer dispid 12;
    property BackColor: Integer dispid 13;
    property ForeColor: Integer dispid 14;
    procedure Move(X: Integer; Y: Integer); dispid 15;
    procedure Bound(Left: Integer; Top: Integer; Right: Integer; Bottom: Integer); dispid 16;
  end;

// *********************************************************************//
// DispIntf:  Printer
// Flags:     (4096) Dispatchable
// GUID:      {3624B9CC-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Printer = dispinterface
    ['{3624B9CC-9E5D-11D3-A896-00C04F324E22}']
    property Name: WideString dispid 1;
    property XDPI: Integer dispid 2;
    property YDPI: Integer dispid 3;
    property FullName: WideString dispid 4;
    property _FullName: WideString dispid 0;
    property Application: IApplication dispid 5;
    property Parent: IDispatch dispid 6;
    property WindowsFontNames: Strings dispid 7;
    property DeviceFontNames: Strings dispid 8;
    property WindowsCodeNames: Strings dispid 9;
    property DeviceCodeNames: Strings dispid 10;
    function  ShowSetup: Smallint; dispid 11;
    function  SetParameter(const strParameter: WideString; Value: OleVariant): WordBool; dispid 12;
    function  SwitchTo(const strPrinterName: WideString; const strPortName: WideString; 
                       DirectAccess: WordBool): WordBool; dispid 13;
    function  Send(const strEscapeSequence: WideString): WordBool; dispid 14;
  end;

// *********************************************************************//
// DispIntf:  Strings
// Flags:     (4096) Dispatchable
// GUID:      {3624B9CA-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Strings = dispinterface
    ['{3624B9CA-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Application: IApplication dispid 2;
    property Parent: IDispatch dispid 3;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: Integer): WideString; dispid 4;
    function  _Item(Key: Integer): WideString; dispid 0;
  end;

// *********************************************************************//
// DispIntf:  Format
// Flags:     (4096) Dispatchable
// GUID:      {3624B9CE-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Format = dispinterface
    ['{3624B9CE-9E5D-11D3-A896-00C04F324E22}']
    property Application: IApplication dispid 1;
    property Parent: IDispatch dispid 2;
    property PageHeight: Integer dispid 3;
    property PageWidth: Integer dispid 4;
    property LabelHeight: Integer dispid 5;
    property LabelWidth: Integer dispid 6;
    property MarginLeft: Integer dispid 7;
    property MarginTop: Integer dispid 8;
    property Corner: Integer dispid 9;
    property HorizontalGap: Integer dispid 10;
    property VerticalGap: Integer dispid 11;
    property RowCount: Integer dispid 12;
    property ColumnCount: Integer dispid 13;
    property Portrait: WordBool dispid 14;
    property AutoSize: WordBool dispid 15;
    property StockType: WideString dispid 16;
    property StockName: WideString dispid 17;
    procedure SaveStock; dispid 18;
  end;

// *********************************************************************//
// DispIntf:  Database
// Flags:     (4096) Dispatchable
// GUID:      {3624B9CD-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Database = dispinterface
    ['{3624B9CD-9E5D-11D3-A896-00C04F324E22}']
    property Parent: IDispatch dispid 1;
    property Application: IApplication dispid 2;
    property EOF: WordBool dispid 3;
    property BOF: WordBool dispid 4;
    property CreatingVariables: WordBool dispid 5;
    property IsOpen: WordBool dispid 6;
    function  MoveNext: WordBool; dispid 7;
    function  MovePrevious: WordBool; dispid 8;
    function  MoveFirst: WordBool; dispid 9;
    function  MoveLast: WordBool; dispid 10;
    function  OpenASCII(const strFileName: WideString; const strDescriptorFileName: WideString): WordBool; dispid 11;
    function  OpenQuery(const strQueryFileName: WideString): WordBool; dispid 12;
    function  OpenODBC(const strDatasourceName: WideString; const strSQLQuery: WideString): WordBool; dispid 13;
    procedure Close; dispid 14;
  end;

// *********************************************************************//
// DispIntf:  DocumentProperties
// Flags:     (4096) Dispatchable
// GUID:      {3624B9EA-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  DocumentProperties = dispinterface
    ['{3624B9EA-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Application: IApplication dispid 2;
    property Parent: IDispatch dispid 3;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: OleVariant): DocumentProperty; dispid 4;
    function  _Item(Key: OleVariant): DocumentProperty; dispid 0;
  end;

// *********************************************************************//
// DispIntf:  DocumentProperty
// Flags:     (4096) Dispatchable
// GUID:      {3624B9EB-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  DocumentProperty = dispinterface
    ['{3624B9EB-9E5D-11D3-A896-00C04F324E22}']
    property Parent: IDispatch dispid 1;
    property Application: IApplication dispid 2;
    property Value: OleVariant dispid 3;
    property _Value: OleVariant dispid 0;
    property Type_: enumProperty dispid 4;
    property Name: WideString dispid 5;
  end;

// *********************************************************************//
// DispIntf:  Dialogs
// Flags:     (4096) Dispatchable
// GUID:      {3624B9C8-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Dialogs = dispinterface
    ['{3624B9C8-9E5D-11D3-A896-00C04F324E22}']
    property Count: Smallint dispid 1;
    property Application: IApplication dispid 2;
    property Parent: IDispatch dispid 3;
    property _NewEnum: IUnknown dispid -4;
    function  Item(Key: enumDialogType): Dialog; dispid 4;
    function  _Item(Key: enumDialogType): Dialog; dispid 0;
  end;

// *********************************************************************//
// DispIntf:  Dialog
// Flags:     (4096) Dispatchable
// GUID:      {3624B9C9-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Dialog = dispinterface
    ['{3624B9C9-9E5D-11D3-A896-00C04F324E22}']
    property Parent: IDispatch dispid 1;
    property Application: IApplication dispid 2;
    property Type_: enumDialogType dispid 3;
    function  Show: Smallint; dispid 4;
  end;

// *********************************************************************//
// DispIntf:  Options
// Flags:     (4096) Dispatchable
// GUID:      {3624B9C7-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Options = dispinterface
    ['{3624B9C7-9E5D-11D3-A896-00C04F324E22}']
    property LoadPrinterSetup: WordBool dispid 1;
    property LoadPrinter: WordBool dispid 2;
    property OpenMergeDatabase: WordBool dispid 3;
    property CreateBackup: WordBool dispid 4;
    property OpenReadOnly: WordBool dispid 5;
    property MeasureSystem: enumMeasureSystem dispid 6;
    property DefaultImagePath: WideString dispid 7;
    property DefaultQueryPath: WideString dispid 8;
    property DefaultDescriberPath: WideString dispid 9;
    property DefaultPrintOutPath: WideString dispid 10;
    property DefaultSharedVarPath: WideString dispid 11;
    property Application: IApplication dispid 12;
    property Parent: IDispatch dispid 13;
    property TrayNotification: WordBool dispid 14;
    property Language: enumLanguage dispid 15;
    property EuroConversionRate: Single dispid 16;
    property DefaultUserSettingsPath: WideString dispid 17;
    property SharedFileAccessTimeout: Integer dispid 18;
  end;

// *********************************************************************//
// DispIntf:  RecentFiles
// Flags:     (4096) Dispatchable
// GUID:      {3624B9ED-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  RecentFiles = dispinterface
    ['{3624B9ED-9E5D-11D3-A896-00C04F324E22}']
    property Application: IApplication dispid 1;
    property Parent: IDispatch dispid 2;
    property Maximum: Integer dispid 3;
    property Count: Integer dispid 4;
    property _NewEnum: IUnknown dispid -4;
    function  Add(Key: OleVariant; ReadOnly: WordBool): RecentFile; dispid 5;
    function  Item(Key: Integer): RecentFile; dispid 6;
    function  _Item(Key: Integer): RecentFile; dispid 0;
    procedure Clear; dispid 7;
    procedure Remove(Key: Smallint); dispid 8;
  end;

// *********************************************************************//
// DispIntf:  RecentFile
// Flags:     (4096) Dispatchable
// GUID:      {3624B9EC-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  RecentFile = dispinterface
    ['{3624B9EC-9E5D-11D3-A896-00C04F324E22}']
    property Application: IApplication dispid 1;
    property Parent: IDispatch dispid 2;
    property Path: WideString dispid 3;
    property Name: WideString dispid 4;
    function  Open: IDocument; dispid 5;
  end;

// *********************************************************************//
// DispIntf:  PrinterSystem
// Flags:     (4096) Dispatchable
// GUID:      {3624B9EF-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  PrinterSystem = dispinterface
    ['{3624B9EF-9E5D-11D3-A896-00C04F324E22}']
    function  Families: Strings; dispid 1;
    function  Models(const Family: WideString): Strings; dispid 2;
    function  Printers(KindOfPrinter: enumKindOfPrinters): Strings; dispid 3;
    function  Ports: Strings; dispid 4;
    function  Add(const strPrinterName: WideString; const strPortName: WideString; 
                  DirectAccess: WordBool): WideString; dispid 5;
    procedure Remove(const strPrinterName: WideString); dispid 6;
    procedure Rename(const strPrinterName: WideString; const strNewPrinterName: WideString); dispid 7;
  end;

// *********************************************************************//
// DispIntf:  INotifyApplicationEvent
// Flags:     (4096) Dispatchable
// GUID:      {3624B9C4-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  INotifyApplicationEvent = dispinterface
    ['{3624B9C4-9E5D-11D3-A896-00C04F324E22}']
    procedure Quit; dispid 1;
    procedure Close; dispid 2;
    procedure DocumentClosed(const strDocTitle: WideString); dispid 3;
  end;

// *********************************************************************//
// DispIntf:  INotifyDocumentEvent
// Flags:     (4096) Dispatchable
// GUID:      {3624B9C5-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  INotifyDocumentEvent = dispinterface
    ['{3624B9C5-9E5D-11D3-A896-00C04F324E22}']
    procedure Change; dispid 1;
    procedure BeginPrinting(const strDocName: WideString); dispid 2;
    procedure ProgressPrinting(Percent: Smallint; var Cancel: Smallint); dispid 3;
    procedure EndPrinting(Reason: enumEndPrinting); dispid 4;
    procedure PausedPrinting(Reason: enumPausedReasonPrinting; var Cancel: Smallint); dispid 5;
  end;

// *********************************************************************//
// DispIntf:  Date
// Flags:     (4096) Dispatchable
// GUID:      {3624B9E6-9E5D-11D3-A896-00C04F324E22}
// *********************************************************************//
  Date = dispinterface
    ['{3624B9E6-9E5D-11D3-A896-00C04F324E22}']
    property Name: WideString dispid 1;
    property Value: WideString dispid 2;
    property _Value: WideString dispid 0;
    property DataSource: enumDataSource dispid 3;
    property Parent: IDispatch dispid 4;
    property Application: IApplication dispid 5;
    property Device: Integer dispid 257;
    property Format: WideString dispid 258;
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

  TCS_6DocumentClosed = procedure(Sender: TObject; var strDocTitle: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TCS_6
// Help String      : 
// Default Interface: IApplication
// Def. Intf. DISP? : Yes
// Event   Interface: INotifyApplicationEvent
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TCS_6Properties= class;
{$ENDIF}
  TCS_6 = class(TOleServer)
  private
    FOnQuit: TNotifyEvent;
    FOnClose: TNotifyEvent;
    FOnDocumentClosed: TCS_6DocumentClosed;
    FAutoQuit:    Boolean;
    FIntf:        IApplication;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TCS_6Properties;
    function      GetServerProperties: TCS_6Properties;
{$ENDIF}
    function      GetDefaultInterface: IApplication;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function Get_Visible: WordBool;
    procedure Set_Visible(Value: WordBool);
    function Get_UserControl: WordBool;
    procedure Set_UserControl(Value: WordBool);
    function Get_Documents: Documents;
    procedure Set_Documents(const Value: Documents);
    function Get_Dialogs: Dialogs;
    procedure Set_Dialogs(const Value: Dialogs);
    function Get_Parent: IDispatch;
    procedure Set_Parent(const Value: IDispatch);
    function Get_Caption: WideString;
    procedure Set_Caption(const Value: WideString);
    function Get_DefaultFilePath: WideString;
    procedure Set_DefaultFilePath(const Value: WideString);
    function Get_FullName: WideString;
    procedure Set_FullName(const Value: WideString);
    function Get_Name: WideString;
    procedure Set_Name(const Value: WideString);
    function Get__Name: WideString;
    procedure Set__Name(const Value: WideString);
    function Get_Path: WideString;
    procedure Set_Path(const Value: WideString);
    function Get_Application: IApplication;
    procedure Set_Application(const Value: IApplication);
    function Get_Options: Options;
    procedure Set_Options(const Value: Options);
    function Get_Version: WideString;
    procedure Set_Version(const Value: WideString);
    function Get_Width: Integer;
    procedure Set_Width(Value: Integer);
    function Get_Height: Integer;
    procedure Set_Height(Value: Integer);
    function Get_Left: Integer;
    procedure Set_Left(Value: Integer);
    function Get_Top: Integer;
    procedure Set_Top(Value: Integer);
    function Get_ActiveDocument: IDocument;
    procedure Set_ActiveDocument(const Value: IDocument);
    function Get_Locked: WordBool;
    procedure Set_Locked(Value: WordBool);
    function Get_RecentFiles: RecentFiles;
    procedure Set_RecentFiles(const Value: RecentFiles);
    function Get_EnableEvents: WordBool;
    procedure Set_EnableEvents(Value: WordBool);
    function Get_ActivePrinterName: WideString;
    procedure Set_ActivePrinterName(const Value: WideString);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IApplication);
    procedure Disconnect; override;
    procedure Quit;
    function  PrinterSystem: PrinterSystem;
    procedure Resize(Width: Integer; Height: Integer);
    procedure Move(Left: Integer; Top: Integer);
    procedure ShowHelp(const strHelpFile: WideString; HelpContextID: Integer);
    function  GetLastError: Smallint;
    function  ErrorMessage(ErrorCode: Smallint): WideString;
    property  DefaultInterface: IApplication read GetDefaultInterface;
    property Parent: IDispatch read Get_Parent write Set_Parent;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property UserControl: WordBool read Get_UserControl write Set_UserControl;
    property Documents: Documents read Get_Documents write Set_Documents;
    property Dialogs: Dialogs read Get_Dialogs write Set_Dialogs;
    property Caption: WideString read Get_Caption write Set_Caption;
    property DefaultFilePath: WideString read Get_DefaultFilePath write Set_DefaultFilePath;
    property FullName: WideString read Get_FullName write Set_FullName;
    property Name: WideString read Get_Name write Set_Name;
    property _Name: WideString read Get__Name write Set__Name;
    property Path: WideString read Get_Path write Set_Path;
    property Application: IApplication read Get_Application write Set_Application;
    property Options: Options read Get_Options write Set_Options;
    property Version: WideString read Get_Version write Set_Version;
    property Width: Integer read Get_Width write Set_Width;
    property Height: Integer read Get_Height write Set_Height;
    property Left: Integer read Get_Left write Set_Left;
    property Top: Integer read Get_Top write Set_Top;
    property ActiveDocument: IDocument read Get_ActiveDocument write Set_ActiveDocument;
    property Locked: WordBool read Get_Locked write Set_Locked;
    property RecentFiles: RecentFiles read Get_RecentFiles write Set_RecentFiles;
    property EnableEvents: WordBool read Get_EnableEvents write Set_EnableEvents;
    property ActivePrinterName: WideString read Get_ActivePrinterName write Set_ActivePrinterName;
  published
    property AutoQuit: Boolean read FAutoQuit write FAutoQuit; 
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TCS_6Properties read GetServerProperties;
{$ENDIF}
    property OnQuit: TNotifyEvent read FOnQuit write FOnQuit;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnDocumentClosed: TCS_6DocumentClosed read FOnDocumentClosed write FOnDocumentClosed;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TCS_6
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TCS_6Properties = class(TPersistent)
  private
    FServer:    TCS_6;
    function    GetDefaultInterface: IApplication;
    constructor Create(AServer: TCS_6);
  protected
    function Get_Visible: WordBool;
    procedure Set_Visible(Value: WordBool);
    function Get_UserControl: WordBool;
    procedure Set_UserControl(Value: WordBool);
    function Get_Documents: Documents;
    procedure Set_Documents(const Value: Documents);
    function Get_Dialogs: Dialogs;
    procedure Set_Dialogs(const Value: Dialogs);
    function Get_Parent: IDispatch;
    procedure Set_Parent(const Value: IDispatch);
    function Get_Caption: WideString;
    procedure Set_Caption(const Value: WideString);
    function Get_DefaultFilePath: WideString;
    procedure Set_DefaultFilePath(const Value: WideString);
    function Get_FullName: WideString;
    procedure Set_FullName(const Value: WideString);
    function Get_Name: WideString;
    procedure Set_Name(const Value: WideString);
    function Get__Name: WideString;
    procedure Set__Name(const Value: WideString);
    function Get_Path: WideString;
    procedure Set_Path(const Value: WideString);
    function Get_Application: IApplication;
    procedure Set_Application(const Value: IApplication);
    function Get_Options: Options;
    procedure Set_Options(const Value: Options);
    function Get_Version: WideString;
    procedure Set_Version(const Value: WideString);
    function Get_Width: Integer;
    procedure Set_Width(Value: Integer);
    function Get_Height: Integer;
    procedure Set_Height(Value: Integer);
    function Get_Left: Integer;
    procedure Set_Left(Value: Integer);
    function Get_Top: Integer;
    procedure Set_Top(Value: Integer);
    function Get_ActiveDocument: IDocument;
    procedure Set_ActiveDocument(const Value: IDocument);
    function Get_Locked: WordBool;
    procedure Set_Locked(Value: WordBool);
    function Get_RecentFiles: RecentFiles;
    procedure Set_RecentFiles(const Value: RecentFiles);
    function Get_EnableEvents: WordBool;
    procedure Set_EnableEvents(Value: WordBool);
    function Get_ActivePrinterName: WideString;
    procedure Set_ActivePrinterName(const Value: WideString);
  public
    property DefaultInterface: IApplication read GetDefaultInterface;
  published
    property Visible: WordBool read Get_Visible write Set_Visible;
    property UserControl: WordBool read Get_UserControl write Set_UserControl;
    property Documents: Documents read Get_Documents write Set_Documents;
    property Dialogs: Dialogs read Get_Dialogs write Set_Dialogs;
    property Caption: WideString read Get_Caption write Set_Caption;
    property DefaultFilePath: WideString read Get_DefaultFilePath write Set_DefaultFilePath;
    property FullName: WideString read Get_FullName write Set_FullName;
    property Name: WideString read Get_Name write Set_Name;
    property _Name: WideString read Get__Name write Set__Name;
    property Path: WideString read Get_Path write Set_Path;
    property Application: IApplication read Get_Application write Set_Application;
    property Options: Options read Get_Options write Set_Options;
    property Version: WideString read Get_Version write Set_Version;
    property Width: Integer read Get_Width write Set_Width;
    property Height: Integer read Get_Height write Set_Height;
    property Left: Integer read Get_Left write Set_Left;
    property Top: Integer read Get_Top write Set_Top;
    property ActiveDocument: IDocument read Get_ActiveDocument write Set_ActiveDocument;
    property Locked: WordBool read Get_Locked write Set_Locked;
    property RecentFiles: RecentFiles read Get_RecentFiles write Set_RecentFiles;
    property EnableEvents: WordBool read Get_EnableEvents write Set_EnableEvents;
    property ActivePrinterName: WideString read Get_ActivePrinterName write Set_ActivePrinterName;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoDocument provides a Create and CreateRemote method to          
// create instances of the default interface IDocument exposed by              
// the CoClass Document. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDocument = class
    class function Create: IDocument;
    class function CreateRemote(const MachineName: string): IDocument;
  end;

  TDocumentBeginPrinting = procedure(Sender: TObject; var strDocName: OleVariant) of object;
  TDocumentProgressPrinting = procedure(Sender: TObject; Percent: Smallint; var Cancel: OleVariant) of object;
  TDocumentEndPrinting = procedure(Sender: TObject; Reason: enumEndPrinting) of object;
  TDocumentPausedPrinting = procedure(Sender: TObject; Reason: enumPausedReasonPrinting; 
                                                       var Cancel: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TDocument
// Help String      : 
// Default Interface: IDocument
// Def. Intf. DISP? : Yes
// Event   Interface: INotifyDocumentEvent
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TDocumentProperties= class;
{$ENDIF}
  TDocument = class(TOleServer)
  private
    FOnChange: TNotifyEvent;
    FOnBeginPrinting: TDocumentBeginPrinting;
    FOnProgressPrinting: TDocumentProgressPrinting;
    FOnEndPrinting: TDocumentEndPrinting;
    FOnPausedPrinting: TDocumentPausedPrinting;
    FIntf:        IDocument;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TDocumentProperties;
    function      GetServerProperties: TDocumentProperties;
{$ENDIF}
    function      GetDefaultInterface: IDocument;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function Get_Variables: Variables;
    procedure Set_Variables(const Value: Variables);
    function Get_Name: WideString;
    procedure Set_Name(const Value: WideString);
    function Get__Name: WideString;
    procedure Set__Name(const Value: WideString);
    function Get_DocObjects: DocObjects;
    procedure Set_DocObjects(const Value: DocObjects);
    function Get_Printer: Printer;
    procedure Set_Printer(const Value: Printer);
    function Get_Format: Format;
    procedure Set_Format(const Value: Format);
    function Get_Database: Database;
    procedure Set_Database(const Value: Database);
    function Get_Application: IApplication;
    procedure Set_Application(const Value: IApplication);
    function Get_Parent: IDispatch;
    procedure Set_Parent(const Value: IDispatch);
    function Get_FullName: WideString;
    procedure Set_FullName(const Value: WideString);
    function Get_ReadOnly: WordBool;
    procedure Set_ReadOnly(Value: WordBool);
    function Get_ViewMode: enumViewMode;
    procedure Set_ViewMode(Value: enumViewMode);
    function Get_WindowState: enumWindowState;
    procedure Set_WindowState(Value: enumWindowState);
    function Get_BuiltInDocumentProperties: DocumentProperties;
    procedure Set_BuiltInDocumentProperties(const Value: DocumentProperties);
    function Get_TriggerForm: enumTriggerForm;
    procedure Set_TriggerForm(Value: enumTriggerForm);
    function Get_ViewOrientation: enumRotation;
    procedure Set_ViewOrientation(Value: enumRotation);
    function Get_IsModified: WordBool;
    procedure Set_IsModified(Value: WordBool);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDocument);
    procedure Disconnect; override;
    function  Save: Smallint;
    function  SaveAs(const strPathName: WideString): Smallint;
    function  PrintDocument(Quantity: Integer): Smallint;
    function  PrintLabel(Quantity: Integer; LabelCopy: Integer; InterCut: Integer; 
                         PageCopy: Integer; NoFrom: Integer; const FileName: WideString): Smallint;
    function  GeneratePOF(const DestFileName: WideString; const ModeleFileName: WideString): Smallint;
    function  Merge(Quantity: Integer; LabelCopy: Integer; InterCut: Integer; PageCopy: Integer; 
                    NoFrom: Integer; const FileName: WideString): Smallint;
    function  Insert(const strPathName: WideString): Smallint;
    function  CopyToClipboard: WordBool;
    function  FormFeed: Smallint;
    procedure Close(Save: WordBool);
    procedure Activate;
    function  CopyImageToFile(Colors: Smallint; const Extension: WideString; Rotation: Smallint; 
                              Percent: Smallint; const FileName: WideString): WideString;
    property  DefaultInterface: IDocument read GetDefaultInterface;
    property Parent: IDispatch read Get_Parent write Set_Parent;
    property Variables: Variables read Get_Variables write Set_Variables;
    property Name: WideString read Get_Name write Set_Name;
    property _Name: WideString read Get__Name write Set__Name;
    property DocObjects: DocObjects read Get_DocObjects write Set_DocObjects;
    property Printer: Printer read Get_Printer write Set_Printer;
    property Format: Format read Get_Format write Set_Format;
    property Database: Database read Get_Database write Set_Database;
    property Application: IApplication read Get_Application write Set_Application;
    property FullName: WideString read Get_FullName write Set_FullName;
    property ReadOnly: WordBool read Get_ReadOnly write Set_ReadOnly;
    property ViewMode: enumViewMode read Get_ViewMode write Set_ViewMode;
    property WindowState: enumWindowState read Get_WindowState write Set_WindowState;
    property BuiltInDocumentProperties: DocumentProperties read Get_BuiltInDocumentProperties write Set_BuiltInDocumentProperties;
    property TriggerForm: enumTriggerForm read Get_TriggerForm write Set_TriggerForm;
    property ViewOrientation: enumRotation read Get_ViewOrientation write Set_ViewOrientation;
    property IsModified: WordBool read Get_IsModified write Set_IsModified;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TDocumentProperties read GetServerProperties;
{$ENDIF}
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnBeginPrinting: TDocumentBeginPrinting read FOnBeginPrinting write FOnBeginPrinting;
    property OnProgressPrinting: TDocumentProgressPrinting read FOnProgressPrinting write FOnProgressPrinting;
    property OnEndPrinting: TDocumentEndPrinting read FOnEndPrinting write FOnEndPrinting;
    property OnPausedPrinting: TDocumentPausedPrinting read FOnPausedPrinting write FOnPausedPrinting;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TDocument
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TDocumentProperties = class(TPersistent)
  private
    FServer:    TDocument;
    function    GetDefaultInterface: IDocument;
    constructor Create(AServer: TDocument);
  protected
    function Get_Variables: Variables;
    procedure Set_Variables(const Value: Variables);
    function Get_Name: WideString;
    procedure Set_Name(const Value: WideString);
    function Get__Name: WideString;
    procedure Set__Name(const Value: WideString);
    function Get_DocObjects: DocObjects;
    procedure Set_DocObjects(const Value: DocObjects);
    function Get_Printer: Printer;
    procedure Set_Printer(const Value: Printer);
    function Get_Format: Format;
    procedure Set_Format(const Value: Format);
    function Get_Database: Database;
    procedure Set_Database(const Value: Database);
    function Get_Application: IApplication;
    procedure Set_Application(const Value: IApplication);
    function Get_Parent: IDispatch;
    procedure Set_Parent(const Value: IDispatch);
    function Get_FullName: WideString;
    procedure Set_FullName(const Value: WideString);
    function Get_ReadOnly: WordBool;
    procedure Set_ReadOnly(Value: WordBool);
    function Get_ViewMode: enumViewMode;
    procedure Set_ViewMode(Value: enumViewMode);
    function Get_WindowState: enumWindowState;
    procedure Set_WindowState(Value: enumWindowState);
    function Get_BuiltInDocumentProperties: DocumentProperties;
    procedure Set_BuiltInDocumentProperties(const Value: DocumentProperties);
    function Get_TriggerForm: enumTriggerForm;
    procedure Set_TriggerForm(Value: enumTriggerForm);
    function Get_ViewOrientation: enumRotation;
    procedure Set_ViewOrientation(Value: enumRotation);
    function Get_IsModified: WordBool;
    procedure Set_IsModified(Value: WordBool);
  public
    property DefaultInterface: IDocument read GetDefaultInterface;
  published
    property Variables: Variables read Get_Variables write Set_Variables;
    property Name: WideString read Get_Name write Set_Name;
    property _Name: WideString read Get__Name write Set__Name;
    property DocObjects: DocObjects read Get_DocObjects write Set_DocObjects;
    property Printer: Printer read Get_Printer write Set_Printer;
    property Format: Format read Get_Format write Set_Format;
    property Database: Database read Get_Database write Set_Database;
    property Application: IApplication read Get_Application write Set_Application;
    property FullName: WideString read Get_FullName write Set_FullName;
    property ReadOnly: WordBool read Get_ReadOnly write Set_ReadOnly;
    property ViewMode: enumViewMode read Get_ViewMode write Set_ViewMode;
    property WindowState: enumWindowState read Get_WindowState write Set_WindowState;
    property BuiltInDocumentProperties: DocumentProperties read Get_BuiltInDocumentProperties write Set_BuiltInDocumentProperties;
    property TriggerForm: enumTriggerForm read Get_TriggerForm write Set_TriggerForm;
    property ViewOrientation: enumRotation read Get_ViewOrientation write Set_ViewOrientation;
    property IsModified: WordBool read Get_IsModified write Set_IsModified;
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

procedure TCS_6.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{3624B9C0-9E5D-11D3-A896-00C04F324E22}';
    IntfIID:   '{3624B9C3-9E5D-11D3-A896-00C04F324E22}';
    EventIID:  '{3624B9C4-9E5D-11D3-A896-00C04F324E22}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TCS_6.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IApplication;
  end;
end;

procedure TCS_6.ConnectTo(svrIntf: IApplication);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TCS_6.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    if FAutoQuit then
      Quit();
    FIntf := nil;
  end;
end;

function TCS_6.GetDefaultInterface: IApplication;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TCS_6.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TCS_6Properties.Create(Self);
{$ENDIF}
end;

destructor TCS_6.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TCS_6.GetServerProperties: TCS_6Properties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TCS_6.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   1: if Assigned(FOnQuit) then
            FOnQuit(Self);
   2: if Assigned(FOnClose) then
            FOnClose(Self);
   3: if Assigned(FOnDocumentClosed) then
            FOnDocumentClosed(Self, Params[0] {const WideString});
  end; {case DispID}
end;

function TCS_6.Get_Visible: WordBool;
begin
  Result := DefaultInterface.Visible;
end;

procedure TCS_6.Set_Visible(Value: WordBool);
begin
  DefaultInterface.Visible := Value;
end;

function TCS_6.Get_UserControl: WordBool;
begin
  Result := DefaultInterface.UserControl;
end;

procedure TCS_6.Set_UserControl(Value: WordBool);
begin
  DefaultInterface.UserControl := Value;
end;

function TCS_6.Get_Documents: Documents;
begin
  Result := DefaultInterface.Documents;
end;

procedure TCS_6.Set_Documents(const Value: Documents);
begin
  DefaultInterface.Documents := Value;
end;

function TCS_6.Get_Dialogs: Dialogs;
begin
  Result := DefaultInterface.Dialogs;
end;

procedure TCS_6.Set_Dialogs(const Value: Dialogs);
begin
  DefaultInterface.Dialogs := Value;
end;

function TCS_6.Get_Parent: IDispatch;
begin
  Result := DefaultInterface.Parent;
end;

procedure TCS_6.Set_Parent(const Value: IDispatch);
begin
  DefaultInterface.Parent := Value;
end;

function TCS_6.Get_Caption: WideString;
begin
  Result := DefaultInterface.Caption;
end;

procedure TCS_6.Set_Caption(const Value: WideString);
begin
  DefaultInterface.Caption := Value;
end;

function TCS_6.Get_DefaultFilePath: WideString;
begin
  Result := DefaultInterface.DefaultFilePath;
end;

procedure TCS_6.Set_DefaultFilePath(const Value: WideString);
begin
  DefaultInterface.DefaultFilePath := Value;
end;

function TCS_6.Get_FullName: WideString;
begin
  Result := DefaultInterface.FullName;
end;

procedure TCS_6.Set_FullName(const Value: WideString);
begin
  DefaultInterface.FullName := Value;
end;

function TCS_6.Get_Name: WideString;
begin
  Result := DefaultInterface.Name;
end;

procedure TCS_6.Set_Name(const Value: WideString);
begin
  DefaultInterface.Name := Value;
end;

function TCS_6.Get__Name: WideString;
begin
  Result := DefaultInterface._Name;
end;

procedure TCS_6.Set__Name(const Value: WideString);
begin
  DefaultInterface._Name := Value;
end;

function TCS_6.Get_Path: WideString;
begin
  Result := DefaultInterface.Path;
end;

procedure TCS_6.Set_Path(const Value: WideString);
begin
  DefaultInterface.Path := Value;
end;

function TCS_6.Get_Application: IApplication;
begin
  Result := DefaultInterface.Application;
end;

procedure TCS_6.Set_Application(const Value: IApplication);
begin
  DefaultInterface.Application := Value;
end;

function TCS_6.Get_Options: Options;
begin
  Result := DefaultInterface.Options;
end;

procedure TCS_6.Set_Options(const Value: Options);
begin
  DefaultInterface.Options := Value;
end;

function TCS_6.Get_Version: WideString;
begin
  Result := DefaultInterface.Version;
end;

procedure TCS_6.Set_Version(const Value: WideString);
begin
  DefaultInterface.Version := Value;
end;

function TCS_6.Get_Width: Integer;
begin
  Result := DefaultInterface.Width;
end;

procedure TCS_6.Set_Width(Value: Integer);
begin
  DefaultInterface.Width := Value;
end;

function TCS_6.Get_Height: Integer;
begin
  Result := DefaultInterface.Height;
end;

procedure TCS_6.Set_Height(Value: Integer);
begin
  DefaultInterface.Height := Value;
end;

function TCS_6.Get_Left: Integer;
begin
  Result := DefaultInterface.Left;
end;

procedure TCS_6.Set_Left(Value: Integer);
begin
  DefaultInterface.Left := Value;
end;

function TCS_6.Get_Top: Integer;
begin
  Result := DefaultInterface.Top;
end;

procedure TCS_6.Set_Top(Value: Integer);
begin
  DefaultInterface.Top := Value;
end;

function TCS_6.Get_ActiveDocument: IDocument;
begin
  Result := DefaultInterface.ActiveDocument;
end;

procedure TCS_6.Set_ActiveDocument(const Value: IDocument);
begin
  DefaultInterface.ActiveDocument := Value;
end;

function TCS_6.Get_Locked: WordBool;
begin
  Result := DefaultInterface.Locked;
end;

procedure TCS_6.Set_Locked(Value: WordBool);
begin
  DefaultInterface.Locked := Value;
end;

function TCS_6.Get_RecentFiles: RecentFiles;
begin
  Result := DefaultInterface.RecentFiles;
end;

procedure TCS_6.Set_RecentFiles(const Value: RecentFiles);
begin
  DefaultInterface.RecentFiles := Value;
end;

function TCS_6.Get_EnableEvents: WordBool;
begin
  Result := DefaultInterface.EnableEvents;
end;

procedure TCS_6.Set_EnableEvents(Value: WordBool);
begin
  DefaultInterface.EnableEvents := Value;
end;

function TCS_6.Get_ActivePrinterName: WideString;
begin
  Result := DefaultInterface.ActivePrinterName;
end;

procedure TCS_6.Set_ActivePrinterName(const Value: WideString);
begin
  DefaultInterface.ActivePrinterName := Value;
end;

procedure TCS_6.Quit;
begin
  DefaultInterface.Quit;
end;

function  TCS_6.PrinterSystem: PrinterSystem;
begin
  DefaultInterface.PrinterSystem;
end;

procedure TCS_6.Resize(Width: Integer; Height: Integer);
begin
  DefaultInterface.Resize(Width, Height);
end;

procedure TCS_6.Move(Left: Integer; Top: Integer);
begin
  DefaultInterface.Move(Left, Top);
end;

procedure TCS_6.ShowHelp(const strHelpFile: WideString; HelpContextID: Integer);
begin
  DefaultInterface.ShowHelp(strHelpFile, HelpContextID);
end;

function  TCS_6.GetLastError: Smallint;
begin
  DefaultInterface.GetLastError;
end;

function  TCS_6.ErrorMessage(ErrorCode: Smallint): WideString;
begin
  DefaultInterface.ErrorMessage(ErrorCode);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TCS_6Properties.Create(AServer: TCS_6);
begin
  inherited Create;
  FServer := AServer;
end;

function TCS_6Properties.GetDefaultInterface: IApplication;
begin
  Result := FServer.DefaultInterface;
end;

function TCS_6Properties.Get_Visible: WordBool;
begin
  Result := DefaultInterface.Visible;
end;

procedure TCS_6Properties.Set_Visible(Value: WordBool);
begin
  DefaultInterface.Visible := Value;
end;

function TCS_6Properties.Get_UserControl: WordBool;
begin
  Result := DefaultInterface.UserControl;
end;

procedure TCS_6Properties.Set_UserControl(Value: WordBool);
begin
  DefaultInterface.UserControl := Value;
end;

function TCS_6Properties.Get_Documents: Documents;
begin
  Result := DefaultInterface.Documents;
end;

procedure TCS_6Properties.Set_Documents(const Value: Documents);
begin
  DefaultInterface.Documents := Value;
end;

function TCS_6Properties.Get_Dialogs: Dialogs;
begin
  Result := DefaultInterface.Dialogs;
end;

procedure TCS_6Properties.Set_Dialogs(const Value: Dialogs);
begin
  DefaultInterface.Dialogs := Value;
end;

function TCS_6Properties.Get_Parent: IDispatch;
begin
  Result := DefaultInterface.Parent;
end;

procedure TCS_6Properties.Set_Parent(const Value: IDispatch);
begin
  DefaultInterface.Parent := Value;
end;

function TCS_6Properties.Get_Caption: WideString;
begin
  Result := DefaultInterface.Caption;
end;

procedure TCS_6Properties.Set_Caption(const Value: WideString);
begin
  DefaultInterface.Caption := Value;
end;

function TCS_6Properties.Get_DefaultFilePath: WideString;
begin
  Result := DefaultInterface.DefaultFilePath;
end;

procedure TCS_6Properties.Set_DefaultFilePath(const Value: WideString);
begin
  DefaultInterface.DefaultFilePath := Value;
end;

function TCS_6Properties.Get_FullName: WideString;
begin
  Result := DefaultInterface.FullName;
end;

procedure TCS_6Properties.Set_FullName(const Value: WideString);
begin
  DefaultInterface.FullName := Value;
end;

function TCS_6Properties.Get_Name: WideString;
begin
  Result := DefaultInterface.Name;
end;

procedure TCS_6Properties.Set_Name(const Value: WideString);
begin
  DefaultInterface.Name := Value;
end;

function TCS_6Properties.Get__Name: WideString;
begin
  Result := DefaultInterface._Name;
end;

procedure TCS_6Properties.Set__Name(const Value: WideString);
begin
  DefaultInterface._Name := Value;
end;

function TCS_6Properties.Get_Path: WideString;
begin
  Result := DefaultInterface.Path;
end;

procedure TCS_6Properties.Set_Path(const Value: WideString);
begin
  DefaultInterface.Path := Value;
end;

function TCS_6Properties.Get_Application: IApplication;
begin
  Result := DefaultInterface.Application;
end;

procedure TCS_6Properties.Set_Application(const Value: IApplication);
begin
  DefaultInterface.Application := Value;
end;

function TCS_6Properties.Get_Options: Options;
begin
  Result := DefaultInterface.Options;
end;

procedure TCS_6Properties.Set_Options(const Value: Options);
begin
  DefaultInterface.Options := Value;
end;

function TCS_6Properties.Get_Version: WideString;
begin
  Result := DefaultInterface.Version;
end;

procedure TCS_6Properties.Set_Version(const Value: WideString);
begin
  DefaultInterface.Version := Value;
end;

function TCS_6Properties.Get_Width: Integer;
begin
  Result := DefaultInterface.Width;
end;

procedure TCS_6Properties.Set_Width(Value: Integer);
begin
  DefaultInterface.Width := Value;
end;

function TCS_6Properties.Get_Height: Integer;
begin
  Result := DefaultInterface.Height;
end;

procedure TCS_6Properties.Set_Height(Value: Integer);
begin
  DefaultInterface.Height := Value;
end;

function TCS_6Properties.Get_Left: Integer;
begin
  Result := DefaultInterface.Left;
end;

procedure TCS_6Properties.Set_Left(Value: Integer);
begin
  DefaultInterface.Left := Value;
end;

function TCS_6Properties.Get_Top: Integer;
begin
  Result := DefaultInterface.Top;
end;

procedure TCS_6Properties.Set_Top(Value: Integer);
begin
  DefaultInterface.Top := Value;
end;

function TCS_6Properties.Get_ActiveDocument: IDocument;
begin
  Result := DefaultInterface.ActiveDocument;
end;

procedure TCS_6Properties.Set_ActiveDocument(const Value: IDocument);
begin
  DefaultInterface.ActiveDocument := Value;
end;

function TCS_6Properties.Get_Locked: WordBool;
begin
  Result := DefaultInterface.Locked;
end;

procedure TCS_6Properties.Set_Locked(Value: WordBool);
begin
  DefaultInterface.Locked := Value;
end;

function TCS_6Properties.Get_RecentFiles: RecentFiles;
begin
  Result := DefaultInterface.RecentFiles;
end;

procedure TCS_6Properties.Set_RecentFiles(const Value: RecentFiles);
begin
  DefaultInterface.RecentFiles := Value;
end;

function TCS_6Properties.Get_EnableEvents: WordBool;
begin
  Result := DefaultInterface.EnableEvents;
end;

procedure TCS_6Properties.Set_EnableEvents(Value: WordBool);
begin
  DefaultInterface.EnableEvents := Value;
end;

function TCS_6Properties.Get_ActivePrinterName: WideString;
begin
  Result := DefaultInterface.ActivePrinterName;
end;

procedure TCS_6Properties.Set_ActivePrinterName(const Value: WideString);
begin
  DefaultInterface.ActivePrinterName := Value;
end;

{$ENDIF}

class function CoDocument.Create: IDocument;
begin
  Result := CreateComObject(CLASS_Document) as IDocument;
end;

class function CoDocument.CreateRemote(const MachineName: string): IDocument;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Document) as IDocument;
end;

procedure TDocument.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{3624B9C1-9E5D-11D3-A896-00C04F324E22}';
    IntfIID:   '{3624B9C6-9E5D-11D3-A896-00C04F324E22}';
    EventIID:  '{3624B9C5-9E5D-11D3-A896-00C04F324E22}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TDocument.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IDocument;
  end;
end;

procedure TDocument.ConnectTo(svrIntf: IDocument);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TDocument.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TDocument.GetDefaultInterface: IDocument;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TDocument.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TDocumentProperties.Create(Self);
{$ENDIF}
end;

destructor TDocument.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TDocument.GetServerProperties: TDocumentProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TDocument.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   1: if Assigned(FOnChange) then
            FOnChange(Self);
   2: if Assigned(FOnBeginPrinting) then
            FOnBeginPrinting(Self, Params[0] {const WideString});
   3: if Assigned(FOnProgressPrinting) then
            FOnProgressPrinting(Self, Params[1] {var Smallint}, Params[0] {Smallint});
   4: if Assigned(FOnEndPrinting) then
            FOnEndPrinting(Self, Params[0] {enumEndPrinting});
   5: if Assigned(FOnPausedPrinting) then
            FOnPausedPrinting(Self, Params[1] {var Smallint}, Params[0] {enumPausedReasonPrinting});
  end; {case DispID}
end;

function TDocument.Get_Variables: Variables;
begin
  Result := DefaultInterface.Variables;
end;

procedure TDocument.Set_Variables(const Value: Variables);
begin
  DefaultInterface.Variables := Value;
end;

function TDocument.Get_Name: WideString;
begin
  Result := DefaultInterface.Name;
end;

procedure TDocument.Set_Name(const Value: WideString);
begin
  DefaultInterface.Name := Value;
end;

function TDocument.Get__Name: WideString;
begin
  Result := DefaultInterface._Name;
end;

procedure TDocument.Set__Name(const Value: WideString);
begin
  DefaultInterface._Name := Value;
end;

function TDocument.Get_DocObjects: DocObjects;
begin
  Result := DefaultInterface.DocObjects;
end;

procedure TDocument.Set_DocObjects(const Value: DocObjects);
begin
  DefaultInterface.DocObjects := Value;
end;

function TDocument.Get_Printer: Printer;
begin
  Result := DefaultInterface.Printer;
end;

procedure TDocument.Set_Printer(const Value: Printer);
begin
  DefaultInterface.Printer := Value;
end;

function TDocument.Get_Format: Format;
begin
  Result := DefaultInterface.Format;
end;

procedure TDocument.Set_Format(const Value: Format);
begin
  DefaultInterface.Format := Value;
end;

function TDocument.Get_Database: Database;
begin
  Result := DefaultInterface.Database;
end;

procedure TDocument.Set_Database(const Value: Database);
begin
  DefaultInterface.Database := Value;
end;

function TDocument.Get_Application: IApplication;
begin
  Result := DefaultInterface.Application;
end;

procedure TDocument.Set_Application(const Value: IApplication);
begin
  DefaultInterface.Application := Value;
end;

function TDocument.Get_Parent: IDispatch;
begin
  Result := DefaultInterface.Parent;
end;

procedure TDocument.Set_Parent(const Value: IDispatch);
begin
  DefaultInterface.Parent := Value;
end;

function TDocument.Get_FullName: WideString;
begin
  Result := DefaultInterface.FullName;
end;

procedure TDocument.Set_FullName(const Value: WideString);
begin
  DefaultInterface.FullName := Value;
end;

function TDocument.Get_ReadOnly: WordBool;
begin
  Result := DefaultInterface.ReadOnly;
end;

procedure TDocument.Set_ReadOnly(Value: WordBool);
begin
  DefaultInterface.ReadOnly := Value;
end;

function TDocument.Get_ViewMode: enumViewMode;
begin
  Result := DefaultInterface.ViewMode;
end;

procedure TDocument.Set_ViewMode(Value: enumViewMode);
begin
  DefaultInterface.ViewMode := Value;
end;

function TDocument.Get_WindowState: enumWindowState;
begin
  Result := DefaultInterface.WindowState;
end;

procedure TDocument.Set_WindowState(Value: enumWindowState);
begin
  DefaultInterface.WindowState := Value;
end;

function TDocument.Get_BuiltInDocumentProperties: DocumentProperties;
begin
  Result := DefaultInterface.BuiltInDocumentProperties;
end;

procedure TDocument.Set_BuiltInDocumentProperties(const Value: DocumentProperties);
begin
  DefaultInterface.BuiltInDocumentProperties := Value;
end;

function TDocument.Get_TriggerForm: enumTriggerForm;
begin
  Result := DefaultInterface.TriggerForm;
end;

procedure TDocument.Set_TriggerForm(Value: enumTriggerForm);
begin
  DefaultInterface.TriggerForm := Value;
end;

function TDocument.Get_ViewOrientation: enumRotation;
begin
  Result := DefaultInterface.ViewOrientation;
end;

procedure TDocument.Set_ViewOrientation(Value: enumRotation);
begin
  DefaultInterface.ViewOrientation := Value;
end;

function TDocument.Get_IsModified: WordBool;
begin
  Result := DefaultInterface.IsModified;
end;

procedure TDocument.Set_IsModified(Value: WordBool);
begin
  DefaultInterface.IsModified := Value;
end;

function  TDocument.Save: Smallint;
begin
  DefaultInterface.Save;
end;

function  TDocument.SaveAs(const strPathName: WideString): Smallint;
begin
  DefaultInterface.SaveAs(strPathName);
end;

function  TDocument.PrintDocument(Quantity: Integer): Smallint;
begin
  DefaultInterface.PrintDocument(Quantity);
end;

function  TDocument.PrintLabel(Quantity: Integer; LabelCopy: Integer; InterCut: Integer; 
                               PageCopy: Integer; NoFrom: Integer; const FileName: WideString): Smallint;
begin
  DefaultInterface.PrintLabel(Quantity, LabelCopy, InterCut, PageCopy, NoFrom, FileName);
end;

function  TDocument.GeneratePOF(const DestFileName: WideString; const ModeleFileName: WideString): Smallint;
begin
  DefaultInterface.GeneratePOF(DestFileName, ModeleFileName);
end;

function  TDocument.Merge(Quantity: Integer; LabelCopy: Integer; InterCut: Integer; 
                          PageCopy: Integer; NoFrom: Integer; const FileName: WideString): Smallint;
begin
  DefaultInterface.Merge(Quantity, LabelCopy, InterCut, PageCopy, NoFrom, FileName);
end;

function  TDocument.Insert(const strPathName: WideString): Smallint;
begin
  DefaultInterface.Insert(strPathName);
end;

function  TDocument.CopyToClipboard: WordBool;
begin
  DefaultInterface.CopyToClipboard;
end;

function  TDocument.FormFeed: Smallint;
begin
  DefaultInterface.FormFeed;
end;

procedure TDocument.Close(Save: WordBool);
begin
  DefaultInterface.Close(Save);
end;

procedure TDocument.Activate;
begin
  DefaultInterface.Activate;
end;

function  TDocument.CopyImageToFile(Colors: Smallint; const Extension: WideString; 
                                    Rotation: Smallint; Percent: Smallint; 
                                    const FileName: WideString): WideString;
begin
  DefaultInterface.CopyImageToFile(Colors, Extension, Rotation, Percent, FileName);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TDocumentProperties.Create(AServer: TDocument);
begin
  inherited Create;
  FServer := AServer;
end;

function TDocumentProperties.GetDefaultInterface: IDocument;
begin
  Result := FServer.DefaultInterface;
end;

function TDocumentProperties.Get_Variables: Variables;
begin
  Result := DefaultInterface.Variables;
end;

procedure TDocumentProperties.Set_Variables(const Value: Variables);
begin
  DefaultInterface.Variables := Value;
end;

function TDocumentProperties.Get_Name: WideString;
begin
  Result := DefaultInterface.Name;
end;

procedure TDocumentProperties.Set_Name(const Value: WideString);
begin
  DefaultInterface.Name := Value;
end;

function TDocumentProperties.Get__Name: WideString;
begin
  Result := DefaultInterface._Name;
end;

procedure TDocumentProperties.Set__Name(const Value: WideString);
begin
  DefaultInterface._Name := Value;
end;

function TDocumentProperties.Get_DocObjects: DocObjects;
begin
  Result := DefaultInterface.DocObjects;
end;

procedure TDocumentProperties.Set_DocObjects(const Value: DocObjects);
begin
  DefaultInterface.DocObjects := Value;
end;

function TDocumentProperties.Get_Printer: Printer;
begin
  Result := DefaultInterface.Printer;
end;

procedure TDocumentProperties.Set_Printer(const Value: Printer);
begin
  DefaultInterface.Printer := Value;
end;

function TDocumentProperties.Get_Format: Format;
begin
  Result := DefaultInterface.Format;
end;

procedure TDocumentProperties.Set_Format(const Value: Format);
begin
  DefaultInterface.Format := Value;
end;

function TDocumentProperties.Get_Database: Database;
begin
  Result := DefaultInterface.Database;
end;

procedure TDocumentProperties.Set_Database(const Value: Database);
begin
  DefaultInterface.Database := Value;
end;

function TDocumentProperties.Get_Application: IApplication;
begin
  Result := DefaultInterface.Application;
end;

procedure TDocumentProperties.Set_Application(const Value: IApplication);
begin
  DefaultInterface.Application := Value;
end;

function TDocumentProperties.Get_Parent: IDispatch;
begin
  Result := DefaultInterface.Parent;
end;

procedure TDocumentProperties.Set_Parent(const Value: IDispatch);
begin
  DefaultInterface.Parent := Value;
end;

function TDocumentProperties.Get_FullName: WideString;
begin
  Result := DefaultInterface.FullName;
end;

procedure TDocumentProperties.Set_FullName(const Value: WideString);
begin
  DefaultInterface.FullName := Value;
end;

function TDocumentProperties.Get_ReadOnly: WordBool;
begin
  Result := DefaultInterface.ReadOnly;
end;

procedure TDocumentProperties.Set_ReadOnly(Value: WordBool);
begin
  DefaultInterface.ReadOnly := Value;
end;

function TDocumentProperties.Get_ViewMode: enumViewMode;
begin
  Result := DefaultInterface.ViewMode;
end;

procedure TDocumentProperties.Set_ViewMode(Value: enumViewMode);
begin
  DefaultInterface.ViewMode := Value;
end;

function TDocumentProperties.Get_WindowState: enumWindowState;
begin
  Result := DefaultInterface.WindowState;
end;

procedure TDocumentProperties.Set_WindowState(Value: enumWindowState);
begin
  DefaultInterface.WindowState := Value;
end;

function TDocumentProperties.Get_BuiltInDocumentProperties: DocumentProperties;
begin
  Result := DefaultInterface.BuiltInDocumentProperties;
end;

procedure TDocumentProperties.Set_BuiltInDocumentProperties(const Value: DocumentProperties);
begin
  DefaultInterface.BuiltInDocumentProperties := Value;
end;

function TDocumentProperties.Get_TriggerForm: enumTriggerForm;
begin
  Result := DefaultInterface.TriggerForm;
end;

procedure TDocumentProperties.Set_TriggerForm(Value: enumTriggerForm);
begin
  DefaultInterface.TriggerForm := Value;
end;

function TDocumentProperties.Get_ViewOrientation: enumRotation;
begin
  Result := DefaultInterface.ViewOrientation;
end;

procedure TDocumentProperties.Set_ViewOrientation(Value: enumRotation);
begin
  DefaultInterface.ViewOrientation := Value;
end;

function TDocumentProperties.Get_IsModified: WordBool;
begin
  Result := DefaultInterface.IsModified;
end;

procedure TDocumentProperties.Set_IsModified(Value: WordBool);
begin
  DefaultInterface.IsModified := Value;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TCS_6, TDocument]);
end;

end.
