unit uFormPrint;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CPort, DB, ADODB, ExtCtrls, ComCtrls, Grids, DBGrids, DateUtils,
  StdCtrls, jpeg, Buttons, uFormMain, Menus, DBCtrls, RzBorder, LabelView_TLB,
  ComObj, ShellAPI, TLHelp32, ImgList, IniFiles, StrUtils, Mask, clsGlobal,
  clsDataSet, Clrgrid, Math, AppEvnts, unitCodeSoft, unitDataBase, unitCSPrintData ;    //;//
                                        
var
  Up_Limit : double = 0 ;
  Low_Limit : double = 0;
  Wait_Time : double = 0.5;       //ºÙ­«¤W¤U­­
  Weight_Count : Integer = 2 ;
  Weight_Model : string = 'DDT-A1000';
  LOCK_SN, Lot_No,Label_WO : string ;
  WeightResult : string = '0000.00g';
  //float Up_Limit = 0 , Low_Limit = 0 , Wait_Time = 0.5 ;    
  PRG : string = 'Shipper Label Print';
  FUN : string ;
  UserID : string = '100000001';

type
  TFormPrint = class(TForm)
    Panel1: TPanel;
    Label8: TLabel;
    Label7: TLabel;
    EditDate: TEdit;
    EditTime: TEdit;
    PnlTitel: TPanel;
    Panel2: TPanel;
    Image1: TImage;
    Label12: TLabel;
    ShapePrinter: TShape;
    Label11: TLabel;
    ShapeDB: TShape;
    Panel3: TPanel;
    PageControl1: TPageControl;
    tsPrint: TTabSheet;
    Label14: TLabel;
    Label9: TLabel;
    LabWO: TLabel;
    LabPN: TLabel;
    LabQTY: TLabel;
    BitBtn5: TBitBtn;
    Memo1: TMemo;
    BitBtn4: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn1: TBitBtn;
    CheckForFQC: TCheckBox;
    BitBtnWeight: TBitBtn;
    tsErie: TTabSheet;
    Label34: TLabel;
    Label36: TLabel;
    Label38: TLabel;
    LabelHbCount: TLabel;
    LabHbQty: TLabel;
    LabHbPN: TLabel;
    LabHbWo: TLabel;
    ImgPic: TImage;
    LabeColor1: TLabel;
    LabeColor3: TLabel;
    LabeColor2: TLabel;
    LabInfo1: TLabel;
    LabInfo2: TLabel;
    LabeColor4: TLabel;
    LabeColor5: TLabel;
    Label72: TLabel;
    Memo3: TMemo;
    BitBtn2: TBitBtn;
    BitBtn8: TBitBtn;
    BitBtn9: TBitBtn;
    CheckHbForFQC: TCheckBox;
    EditHbSN: TEdit;
    tsColorSet: TTabSheet;
    GroupBox1: TGroupBox;
    lbl10: TLabel;
    lbl11: TLabel;
    lbl12: TLabel;
    lblColorVaule: TLabel;
    ComboColor: TComboBox;
    EditColorSPEC: TEdit;
    btn2: TButton;
    GroupBox2: TGroupBox;
    Label61: TLabel;
    Label60: TLabel;
    ComboSKU_No: TComboBox;
    EditmGifBoxPN: TEdit;
    Button3: TButton;
    GroupBox3: TGroupBox;
    Label66: TLabel;
    Label67: TLabel;
    Label68: TLabel;
    Label69: TLabel;
    Label70: TLabel;
    EditUpLimit: TEdit;
    EditLowLimit: TEdit;
    EditWaitTime: TEdit;
    Button4: TButton;
    Button5: TButton;
    EditSKU: TEdit;
    EditWeightCount: TEdit;
    GroupBox10: TGroupBox;
    Label71: TLabel;
    ComboBox10: TComboBox;
    Button6: TButton;
    tsReprent: TTabSheet;
    Label29: TLabel;
    Label31: TLabel;
    msg: TLabel;
    tsQuery: TTabSheet;
    Label26: TLabel;
    DBGrid1: TDBGrid;
    Panel4: TPanel;
    Label24: TLabel;
    Label25: TLabel;
    Label73: TLabel;
    Label74: TLabel;
    Bevel1: TBevel;
    EditWO: TEdit;
    edtQuerySN: TEdit;
    BitBtn7: TBitBtn;
    RadioGroup1: TRadioGroup;
    dtpDateFrom: TDateTimePicker;
    dtpDateTo: TDateTimePicker;
    dtpTimeFrom: TDateTimePicker;
    dtpTimeTo: TDateTimePicker;
    chkByDateTime: TCheckBox;
    Panel5: TPanel;
    ProgressBar1: TProgressBar;
    BitBtn10: TBitBtn;
    tsAbout: TTabSheet;
    About: TMemo;
    Panel6: TPanel;
    Timer1: TTimer;
    dlgColor: TColorDialog;
    TimerDbLVCheck: TTimer;
    SaveDialog1: TSaveDialog;
    LabelSKU: TLabel;
    ComboSKU: TComboBox;
    Label13: TLabel;
    LabelCount: TLabel;
    ObjSetDataSource: TDataSource;
    LabSN: TLabel;
    EditCSN: TEdit;
    LabCSN: TLabel;
    LabUPC: TLabel;
    EditUPC: TEdit;
    tsConfig: TTabSheet;
    Bevel3: TBevel;
    Image5: TImage;
    sbtnSave: TSpeedButton;
    Label19: TLabel;
    Label75: TLabel;
    Label76: TLabel;
    Label80: TLabel;
    Label84: TLabel;
    Bevel5: TBevel;
    Label85: TLabel;
    Label86: TLabel;
    Label94: TLabel;
    Label95: TLabel;
    Label96: TLabel;
    Label97: TLabel;
    cmbVersion: TComboBox;
    cmbPkBase: TComboBox;
    cnkCSN1: TCheckBox;
    cmbPkAction: TComboBox;
    chkWeight: TCheckBox;
    chkCheckCSN: TCheckBox;
    chkCapsLock: TCheckBox;
    cmbRule: TComboBox;
    chkAdditional: TCheckBox;
    chkbInputEC: TCheckBox;
    EdtAdditionaldll: TEdit;
    LVImageList1: TImageList;
    LabTitle1: TLabel;
    LabTitle2: TLabel;
    lablLine: TLabel;
    Image4: TImage;
    btnOK: TSpeedButton;
    Image6: TImage;
    Label98: TLabel;
    LabPDLine: TLabel;
    Label99: TLabel;
    LabStage: TLabel;
    Label100: TLabel;
    LabProcess: TLabel;
    Label101: TLabel;
    LabTerminal: TLabel;
    cmbFactory: TComboBox;
    panl1: TPanel;
    panlMessage: TLabel;
    lablErrorCode: TLabel;
    Label102: TLabel;
    LabHbTitle1: TLabel;
    LablHbLine: TLabel;
    LabHbTitle2: TLabel;
    tsRetail: TTabSheet;
    panl8: TPanel;
    panlMessageRT: TLabel;
    LabRtErrorCode: TLabel;
    EditGiftBox: TEdit;
    EditRtSN: TEdit;
    ComboSKUR: TComboBox;
    CheckRtForFQC: TCheckBox;
    BitBtn11: TBitBtn;
    BitBtn12: TBitBtn;
    BitBtn13: TBitBtn;
    Memo2: TMemo;
    BitBtnExit: TBitBtn;
    Label105: TLabel;
    LablRtLine: TLabel;
    LabRtTitle1: TLabel;
    Label109: TLabel;
    Label110: TLabel;
    LabelRtCount: TLabel;
    Label112: TLabel;
    Label113: TLabel;
    LabRtQTY: TLabel;
    LabRtPN: TLabel;
    LabRtWO: TLabel;
    Label120: TLabel;
    Label121: TLabel;
    LabRtTitle2: TLabel;
    Label35: TLabel;
    ComboSKUH: TComboBox;
    BitBtn6: TBitBtn;
    cnkCSN: TCheckBox;
    Label22: TLabel;
    Label39: TLabel;
    cnkPrintLabel: TCheckBox;
    Label47: TLabel;
    Label48: TLabel;
    EditLabelVariable: TEdit;
    Label50: TLabel;
    cmbCountPerBox: TComboBox;
    Bevel4: TBevel;
    GroupBox6: TGroupBox;
    Label10: TLabel;
    Label27: TLabel;
    Label49: TLabel;
    LabColorInfo: TLabel;
    Label52: TLabel;
    Label53: TLabel;
    Label54: TLabel;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl7: TLabel;
    ComFirstColor: TComboBox;
    ComSecondColor: TComboBox;
    ComThirdColor: TComboBox;
    ComColor1: TComboBox;
    ComColor2: TComboBox;
    ComColor3: TComboBox;
    comForthColor: TComboBox;
    ComFifthColor: TComboBox;
    ComColor4: TComboBox;
    ComColor5: TComboBox;
    cnkCheckGiftBox: TCheckBox;
    ListGifBoxPN: TListBox;
    Label32: TLabel;
    EditmUPC: TEdit;
    ComboGIFPN: TComboBox;
    ComboUPC: TComboBox;
    BitBtn15: TBitBtn;
    BitBtn16: TBitBtn;
    BitBtn17: TBitBtn;
    Label18: TLabel;
    ComboColorSPEC: TComboBox;
    ComboColorValue: TComboBox;
    GroupBox9: TGroupBox;
    Label63: TLabel;
    Label64: TLabel;
    Edit24: TEdit;
    Edit25: TEdit;
    LVData: TListView;
    LVProcess: TListView;
    ImageList2: TImageList;
    TreePC: TTreeView;
    Image2: TImage;
    BitBtn14: TBitBtn;
    BitBtn18: TBitBtn;
    Panel7: TPanel;
    RadioGroup2: TRadioGroup;
    GroupBox4: TGroupBox;
    btnReprint: TButton;
    edtRePrintSN: TEdit;
    Label1: TLabel;
    GridTravel: TStringGrid;
    btnClear: TButton;
    lstG_SerialNumber: TListBox;
    ListUPC: TListBox;
    lstlpVariableName: TListBox;
    lstlpVariableValue: TListBox;
    tsUpload: TTabSheet;
    EditSN: TEdit;
    edtSKUNO: TEdit;
    edtRTSKUNO: TEdit;
    edtHbSKUNO: TEdit;
    btnReload: TBitBtn;
    BitBtn19: TBitBtn;
    BitBtn20: TBitBtn;
    chkProductUPC: TCheckBox;
    Label2: TLabel;
    ButtonTest: TButton;
    TreeView1: TTreeView;
    ButtonLocked: TButton;
    TimerDisibleSaveAs: TTimer;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboSKUDropDown(Sender: TObject);
    procedure ComboSKUChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure TimerDbLVCheckTimer(Sender: TObject);
    procedure BitBtnWeightClick(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
    procedure TreePCClick(Sender: TObject);
    procedure TreePCGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tsPrintShow(Sender: TObject);
    procedure tsErieShow(Sender: TObject);
    procedure tsRetailShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure EditSNKeyPress(Sender: TObject; var Key: Char);
    procedure EditUPCKeyPress(Sender: TObject; var Key: Char);
    procedure cnkPrintLabelClick(Sender: TObject);
    procedure chkCheckCSNClick(Sender: TObject);
    procedure EditCSNKeyPress(Sender: TObject; var Key: Char);
    procedure cnkCSN1Click(Sender: TObject);
    procedure cnkCSNClick(Sender: TObject);
    procedure lblColorVauleClick(Sender: TObject);
    procedure ComboSKU_NoDropDown(Sender: TObject);
    procedure ComboSKU_NoChange(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure EditGiftBoxKeyPress(Sender: TObject; var Key: Char);
    procedure EditRtSNKeyPress(Sender: TObject; var Key: Char);
    procedure EditHbSNKeyPress(Sender: TObject; var Key: Char);
    procedure BitBtn16Click(Sender: TObject);
    procedure BitBtn11Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure EditSKUKeyPress(Sender: TObject; var Key: Char);
    procedure ComboSKU_NoKeyPress(Sender: TObject; var Key: Char);
    procedure PageControl1Change(Sender: TObject);
    procedure ComboColorDropDown(Sender: TObject);
    procedure ComboColorChange(Sender: TObject);
    procedure ComboColorKeyPress(Sender: TObject; var Key: Char);
    procedure btn2Click(Sender: TObject);
    procedure Label72Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure BitBtnExitClick(Sender: TObject);
    procedure chkByDateTimeClick(Sender: TObject);
    procedure ComFirstColorDropDown(Sender: TObject);
    procedure BitBtn14Click(Sender: TObject);
    procedure edtRePrintSNKeyPress(Sender: TObject; var Key: Char);
    procedure btnClearClick(Sender: TObject);
    procedure btnReprintClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btnReloadClick(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure ButtonTestClick(Sender: TObject);
    procedure ButtonLockedClick(Sender: TObject);
    procedure TimerDisibleSaveAsTimer(Sender: TObject);
  private
    { Private declarations }
    LabelFile, PassWord, LabelSKUNO, File_Type : string;
    RunPrintProg : Boolean ;
    m_CodeSoft : TCodeSoft;
    //m_CodeSoft, m_Documents, m_Variables  : Variant ;
    //RunError : string;

    procedure IniPrintPage;
    procedure FreeNewControl;
    function  GetTempDirectory : String;
    function  DownloadSampleFile(SKU : string): string;
    procedure IniSKU_No(Sender: TObject);
    procedure SelectLabelFile(SKU_No : string; var TRES :string);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    function FindWidowByWinClsName(WinCls: String; WinName: String): Longint;

    //
    procedure StartLabelViewApp ;
    procedure StopLabelViewApp ;
    procedure LabelDocApply ;
    procedure DisibleSaveAs ;
    procedure OpenLabelFile(lpFilePath : string);
    function  GetLabelValue(lpVarName : String) : String ;
    procedure DonwLoadLabel(Part_No : string ;var TRES : string);
    function  SetLabelValue(lpVarName , lpValues : String) : Boolean ;
    function  ExistVariableName (lpVarName: String; var lpValues : String) : Boolean ;
    procedure LvPrintLabel(lpPrintValue : array of string; Loop :Integer ;var TRES :string ;lpPrintQty : Integer = 1) ;
    procedure  AddChildMenus(pnd:TTreeNode ; m:HMENU ;hTreeView : TTreeView );
    function   LVMenuClick(hTreeView : TTreeView ; MenuStr : string) : Boolean ;
    function   LVMenuPrint(hTreeView : TTreeView ; PrintQty : Integer = 1) : Boolean ;

    function Check_LV_Open : Boolean ;
    function Check_LV_DbOpen : Boolean ;
    function Get_OpenLV_ProcessID : Boolean ;
    procedure ClearNewEdit(EditItem : Integer = -1);
    procedure SetNextFocus( Index : Integer ) ;

    procedure ShowTerminal;
    //procedure GetWoRange ;
    function GetTerminalID: Boolean;
    function GetCfgData: Boolean;
    procedure InitializeForm;
    function GetPdLineData(PdLineName: string; var PdLineID: string): Boolean;
    function GetProcessData(ProcessName: string; var ProcessID: string; var ProcessCode: string; var ProcessDesc: string): Boolean;
    function GetTerminalData(TerminalName: string; PdLineID: string; ProcessID: string; var TerminalID: string): Boolean;
    function SaveCfgData: Boolean;
    procedure ShowOption;

    //function GetDB_Time : TDateTime ;
    function CheckSN: Boolean;
    function CheckRtSN(TTSN : string): Boolean;
    procedure ShowMsg(sMsg, sType: string;PanlMsg :string = 'PRINT');
    function CheckPDlineStatus(TTerminalID:string):Boolean;
    function CheckSNRange(TSN : string ) : Boolean ;
    procedure SetEditStatus(Kind: string);
    function CheckDupCSN: Boolean;

    procedure GetGifBoxPN(SKU :string ;var TRES : string) ;
    procedure GetWeigthLimit(SKU :string ;var TRES : string);
    procedure CheckWeigthSN(TWO,TSN : string;WeigthCount : Integer ;var TRES : string );

    //procedure GetLVcolorData;
    function  GetLVcolorData : Boolean ;
    function  GetColorID(Color_Name : string) : string ;
    procedure GetColorCombo(objCombo : TComboBox);
    procedure SavePicture(ColorName : string;lpImgPic : TImage );    //PicturePath
    procedure LoadPicture(ColorID : Integer ;lpImgPic : TImage);
    procedure LoadLabColor(iIndex : Integer ) ;
    procedure ZeroColorLabel ;

    function GetProcessHandle(ProcessID : Integer ) : THandle;
    function GetFileCreationTime(const   AFileName:   String;   var   ACreateTime:   TDateTime):   Boolean;
    function GetTimeString(ProcessID : Integer ) : TDateTime ;
    function GetDB_DateTime : TDateTime ;
    procedure GetSetStation;
    procedure GetSetProcessID;
    procedure ShowFactory;
    function  SetStatusbyAuthority(PRG,FUN : string): Boolean;
    function  GetMaxID(DB_Tabel,Column : string): string;
    procedure SJ_DB_PRINT_GO(TerminalID,TSN,TEMP : string ; var TRES : string);
    procedure DB_Weigth_GO(TWO,TSN : string; TTerminalID : Integer ;WEIGHT,CUSTATUS : string ;var TRES : string);
    procedure DspTravelData;
    procedure ClearData;
    procedure InsertPrintLog(WO, SN, LINE_ID, PROCESS_ID, TERMINAL_ID,
      CARTON_NO, PALLET_NO, UPDATE_USERID: string);
    function   DBGridAutoSize(mDBGrid:   TDBGrid;   mOffset:   Integer   =   5):   Boolean;
    function   DBGridRecordSize(mColumn:   TColumn):   Boolean;

  public
    { Public declarations }
    OpenLV_ProcessID : DWORD ;
    OpenCS_ProcessID : DWORD ;
    Running : Boolean ;
    hLVHandle : THandle ;
    BanPrintDlage : Boolean ;


    //±þ±¼¶iµ{
    function  KillProcess( PID : Integer ) : Boolean ;
    function  StrToColor(s: string): TColor;
    procedure HotKeyDown(var Msg: Tmessage); message WM_HOTKEY;

    //¤å¥ó§R°£¾Þ§@
    function  DeleteDirectory(NowPath:   string; FileType : string = '*.lbl'):   Boolean;   //§R°£¾ã­Ó¥Ø¿ý
    procedure DeleteFolder_SHF(sDeleteFolder : String; Recycling : Boolean = False);
    procedure FileDel(FileString : String; Recycling : Boolean = False);

  end;

  type
    ModelSpaceType = record
    ModelName   :string;
    ModelID     :string;
    CountPerBox :Integer;
    SN_TypeNum  :Integer;
    SN_Name:    array   of   string;
    SN_Prefix:  array   of   string;
    SN_Length:  array   of   Integer;
  end;

  //procedure EnabledLabelDocApply ;external 'LabelDocApply.DLL';
  //procedure DisabledLabelDocApply ;external'LabelDocApply.DLL';

var
  FormPrint: TFormPrint;
  CurModelInfo :ModelSpaceType ;
  RunOnce : Boolean = true ;
  LabelNew :array   of   TLabel;
  EditNew  :array   of   TEdit;

  mArrTypeSN : array[0..29] of string ;
  //mArrTypeSN : array of string ;
  mCurrentCount : Integer = 1 ;
  MingleCurrCount : Integer = 1 ;
  LVCurrentCount : Integer = 0 ;

  //LabelView ©w¸q
  LabelApp: ILabelApplication;
  LabelDoc: ILabelDocument;
  LabelFields: ILabelFields;
  LabelField: ILabelField ;
  iDIsp: IDispatch;
  {iDIspDoc,
  iDIspField,
  iDIspFields,}
  Lbl: OleVariant;

  hThread: THandle;
  ThreadID : DWORD ;
  HotKeyId: Integer;

  WinClsName: string = '#32770';
  WinCaption: string = 'Label';

  {sPdLineID, sPdLineName ,sTerminalID, sTerminalName,
  sProcessID, sProcessName, sProcessCode, sProcessDesc: string;}

implementation

uses uExceptionInfo, uFormWeight, uAuthorityLogin ,
     uFormSKU, uFormInfo , uFormLabelData;

{$R *.dfm}

var
  FcID, TerminalID ,G_sProcessID,G_sLineID,G_sStageID: string;

  AutoCreateCSN,NotChangeCSN,CheckGiftBoxPN,
  PrintLabel,CheckCSNeqSN,CheckSNWeight : Boolean ;
  LabelVariable : string; mCountPerBox : Integer ;
  CheckProductUPC : Boolean ; PackingBase: string;

  g_bInputEC, bNoPopUp :Boolean; //2007/08/16 ¬O§_¥i¿é¤J¤£¨}¥N½X
  SNNO, CSNNo: string;


procedure AutoInputPWD ;
  //«öÃþ¦W©MCaption§ä¨ìµ¡«~¦W¬`
  function FindWidowByClassAndName(WinCls: String; WinName: String): Longint;
  var
    winHandle1: Longint;
    clsna: array[0..254] of char;
    objtext: array[0..254] of char;
    cn,ot: string;
  begin
    winHandle1 := GetTopWindow(0);
    while (winHandle1>0) do
    begin
      ZeroMemory(@clsna,255);
      ZeroMemory(@objtext,255);
      GetClassName(winHandle1,clsna,255);
      GetWindowText(winHandle1,objtext,255);
      cn := clsna;
      ot := objtext;
      cn := Trim(cn);
      ot := Trim(ot);
      if (copy(cn,1,Length(WinCls))=WinCls) and (copy(ot,1,Length(WinName))=WinName) then
      begin
        break;
      end
      else
      begin
        winHandle1 := GetNextWindow(winHandle1,GW_HWNDNEXT);
      end;
    end;
    Result := winHandle1;
  end;
var
  LVFormHwnd,EditHwnd,
  OKHwnd : LongWord ;
  Running : Integer ;
begin
  Running := 1;
  repeat
    LVFormHwnd := FindWidowByClassAndName(WinClsName,WinCaption);
    if LVFormHwnd <= 0 then Inc(Running);
    if Running >=1000 then
    begin
      TerminateThread(hThread ,2);//µ²§ô½uµ{
      ShowMessage('Can not found LabelView Application!');
      Break ;
    end;
  until (LVFormHwnd > 0) ;

  if LVFormHwnd > 0 then
  begin
    Sleep(20);
    Application.ProcessMessages ;
    EditHwnd := FindWindowEx(LVFormHwnd, 0, 'Edit', nil);
    OKHwnd := FindWindowEx(LVFormHwnd, 0, 'Button', 'OK');

    SendMessage( EditHwnd, WM_SETTEXT, 0, WM_NULL);    //·¥«~²MªÅ¤º®eªº¤èªk
    SendMessage(EditHwnd,WM_SETTEXT,Length(FormPrint.PassWord),
                 Integer(PChar(FormPrint.PassWord)));   //µo°e±K½X

    PostMessage(OKHwnd ,  WM_LBUTTONDOWN, 0, 0);
    PostMessage(OKHwnd ,  WM_LBUTTONUP, 0, 0);
    {PostMessage(OKHwnd,   WM_SETFOCUS,0, 0);//TEXT1«@µÃ½¹¾à
    PostMessage(OKHwnd,   WM_KEYDOWN,   VK_RETURN,   0);//«ö¤U
    PostMessage(OKHwnd,   WM_KEYUP  ,   VK_RETURN,   0);//?°_ }
    TerminateThread(hThread ,2);//µ²§ô½uµ{
  end;
end;

procedure LabelDocValueApply ;
var
  LVSetHwnd, OKHwnd : LongWord ;
  Running : Integer ;
begin
  Running := 1; 
  repeat
    LVSetHwnd := FindWindow('#32770','¼ÐÅÒ³]©w');
    if LVSetHwnd <= 0 then
      LVSetHwnd := FindWindow('#32770','Label Setup');
    if LVSetHwnd <= 0 then Inc(Running);
    if Running >=1000 then
    begin
      TerminateThread(hThread ,2);//µ²§ô½uµ{
      ShowMessage('Can not found LabelView Application!');
      Break ;
    end;
  until (LVSetHwnd > 0 ) ;

  //MoveWindow(LVSetHwnd ,0,-100,0,0,False);
  Running := 1;
  repeat
    OKHwnd := FindWindowEx(LVSetHwnd , 0, 'Button', nil);
    if OKHwnd <= 0 then Inc(Running);
    if Running >=1000 then
    begin
      TerminateThread(hThread ,2);//µ²§ô½uµ{
      ShowMessage('Can not found LabelView Application!');
      Break ;
    end;
  until (OKHwnd>0);
  if OKHwnd <= 0 then Exit ;

  //PostMessage(OKHwnd,   WM_SETFOCUS,0, 0);//TEXT1«@µÃ½¹¾à
  //PostMessage(OKHwnd,   WM_KEYDOWN,   VK_RETURN,   0);//«ö¤U
  //PostMessage(OKHwnd,   WM_KEYUP  ,   VK_RETURN,   0);//?°_

  PostMessage(OKHwnd ,  WM_LBUTTONDOWN, 0, 0);
  PostMessage(OKHwnd ,  WM_LBUTTONUP, 0, 0);

  TerminateThread(hThread ,2);//µ²§ô½uµ{
end;

{procedure TFormPrint.InitModelInfo(Model_Name,PARAM_TYPE : string) ;
var
  SqlStr : string;
  i : Integer ;
begin
    //¥ý¨ú±o¾÷ºØSN­Ó¼Æ
    SqlStr := 'SELECT B.PARAM_VALUE ' +
                        'FROM SYS_MODEL A, SYS_MODEL_PARAM B WHERE A.MODEL_ID=B.MODEL_ID AND ' +
                        ' A.MODEL_NAME='''+Model_Name+''' AND B.PARAM_TYPE='''+PARAM_TYPE+''' ' +
                        '  AND B.PARAM_NAME=''CountPerBox''  ';
    ObjSQLQuery.Close();
    ObjSQLQuery.SQL.Clear();                   
    ObjSQLQuery.SQL.Text := SqlStr;
    ObjSQLQuery.Open() ;

    if ObjSQLQuery.IsEmpty() then
    begin
        CurModelInfo.CountPerBox := 0;
        CurModelInfo.SN_TypeNum := 0;
        Exit ;
    end
    else
        CurModelInfo.CountPerBox := ObjSQLQuery.FieldValues['PARAM_VALUE'] ;

    SqlStr := 'SELECT A.MODEL_NAME,A.MODEL_ID,B.PARAM_NAME,B.PARAM_VALUE,B.PARAM_VALUE2,B.PARAM_SEQ  ' +
             'FROM SYS_MODEL A, SYS_MODEL_PARAM B WHERE A.MODEL_ID=B.MODEL_ID and ' +
             ' A.MODEL_NAME='''+Model_Name+''' AND B.PARAM_TYPE='''+PARAM_TYPE+''' ' +
             ' AND B.PARAM_NAME <> ''CountPerBox'' ORDER BY PARAM_SEQ ';

    ObjSQLQuery.Close();
    ObjSQLQuery.SQL.Clear();
    ObjSQLQuery.SQL.Text := SqlStr;
    ObjSQLQuery.Open() ;
    ObjSQLQuery.First();

    if not ObjSQLQuery.IsEmpty() then
    begin
        CurModelInfo.ModelName := ObjSQLQuery.FieldValues['MODEL_NAME'] ;
        CurModelInfo.ModelID := ObjSQLQuery.FieldValues['MODEL_ID'] ;
        CurModelInfo.SN_TypeNum := ObjSQLQuery.RecordCount;

        ZeroMemory(CurModelInfo.SN_Name,0);
        ZeroMemory(CurModelInfo.SN_Prefix,0);
        ZeroMemory(CurModelInfo.SN_Length,0);

        SetLength(CurModelInfo.SN_Name,CurModelInfo.SN_TypeNum);
        SetLength(CurModelInfo.SN_Prefix,CurModelInfo.SN_TypeNum);
        SetLength(CurModelInfo.SN_Length,CurModelInfo.SN_TypeNum);

        //while(not ObjSQLQuery.Eof) do
        for i := 0 to CurModelInfo.SN_TypeNum-1  do
        begin;
            CurModelInfo.SN_Name[i] := ObjSQLQuery.FieldByName('PARAM_NAME').AsString ;
            CurModelInfo.SN_Prefix[i] := ObjSQLQuery.FieldByName('PARAM_VALUE').AsString ;
            CurModelInfo.SN_Length[i] := ObjSQLQuery.FieldByName('PARAM_VALUE2').AsInteger ;
            ObjSQLQuery.Next();
        end;
    end;
    ObjSQLQuery.Close();
end;

function TFormPrint.GetDB_Time : TDateTime ;
begin
  //Result := 0 ;
  with  ObjSQLQuery do
  begin
    Close ;
    SQL.Clear ;
    SQL.Text := 'SELECT GETDATE() TTIME' ;
    Open ;
    Result := FieldByName('TTIME').Asdatetime;
    Close ;
  end;
end; }

//¨ú±o¥y¬`©Ò¥Hµæ³æ
procedure TFormPrint.AddChildMenus(pnd:TTreeNode ;m:HMENU ;hTreeView : TTreeView );
var
  i,id:Integer ;
  nd:TTreeNode ;
  MText : array[0..255] of Char ;
begin
  for i := 0 to GetMenuItemCount(m)-1 do
  begin
    id := Integer(GetMenuItemID(m,i));
    GetMenuString(m,i,MText,255,MF_BYPOSITION);
    if id =-1 then begin
      nd := hTreeView.Items.AddChild(pnd,MText);
      AddChildMenus(nd,GetSubMenu(m,i),hTreeView);
    end else if Length(Trim(MText)) >0 then
      hTreeView.Items.AddChildObject(pnd,Format('%s [ID=%d]',[MText,id]),Pointer(id)) ;
  end;
end;

{procedure TFormPrint.AddChildMenus(pnd:TTreeNode ;m:HMENU );
var
  i,id:Integer ;
  nd:TTreeNode ;
  MText : array[0..255] of Char ;
begin
  for i := 0 to GetMenuItemCount(m)-1 do
  begin
    id := Integer(GetMenuItemID(m,i));
    GetMenuString(m,i,MText,255,MF_BYPOSITION);
    if id =-1 then begin
      nd := treeview1.Items.AddChild(pnd,MText);
      AddChildMenus(nd,GetSubMenu(m,i));
    end else if Length(Trim(MText)) >0 then
      TreeView1.Items.AddChildObject(pnd,Format('%s [ID=%d]',[MText,id]),Pointer(id)) ;
  end;
end;}

//«öÃþ¦W©MCaption§ä¨ìµ¡«~¦W¬`
function TFormPrint.FindWidowByWinClsName(WinCls: String; WinName: String): Longint;
var
  winHandle1: Longint;
  clsna: array[0..254] of char;
  objtext: array[0..254] of char;
  cn,ot: string;
begin
  winHandle1 := GetTopWindow(0);
  while (winHandle1>0) do
  begin
    ZeroMemory(@clsna,255);
    ZeroMemory(@objtext,255);
    GetClassName(winHandle1,clsna,255);
    GetWindowText(winHandle1,objtext,255);
    cn := clsna;
    ot := objtext;
    cn := Trim(cn);
    ot := Trim(ot);
    if (copy(cn,1,Length(WinCls))=WinCls) and (copy(ot,1,Length(WinName))=WinName) then
    begin
      break;
    end
    else
    begin
      winHandle1 := GetNextWindow(winHandle1,GW_HWNDNEXT);
    end;
  end;
  Result := winHandle1;
end;

function TFormPrint.GetMaxID(DB_Tabel,Column : string): string;
begin
  with ObjDataSet.ObjQryTemp do
  begin
    try
      Close;
      Params.Clear;
      CommandText := 'Select NVL(Max('+Column+'),0) + 1 MAXID ' +
                 'From '+DB_Tabel;
      Open;
      if Fieldbyname('MAXID').AsString = '1' then
      begin
        Close;
        CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || ''000001'' MAXID ' +
                      'From SAJET.SYS_BASE ' +
                      'Where PARAM_NAME = ''DBID'' ';
        Open;
      end;
      Result := Fieldbyname('MAXID').AsString;
    finally
      Close;
    end;
  end;
end;

procedure TFormPrint.ShowMsg(sMsg, sType: string;PanlMsg :string = 'PRINT');
begin
  if PanlMsg = 'PRINT' then
  begin
    if sType = 'ERROR' then
    begin
      if bNoPopUp then
      begin
        PanlMessage.Caption := sMsg;
        panlMessage.Color := clSilver;
        panlMessage.Font.Color := clRed;
        panlMessage.Repaint;
        messageBeep(48);
      end
      else
      begin
        PanlMessage.Caption := '';
        panlMessage.Color := clWhite;
        panlMessage.Font.Color := clGreen;
        panlMessage.Repaint;
        messageBeep(48);
        MessageDlg(sMsg, mtError, [mbOK], 0);
      end;
    end
    else
    begin
      PanlMessage.Caption := sMsg;
      panlMessage.Color := clWhite;
      panlMessage.Font.Color := clGreen;
      panlMessage.Repaint;
    end;
  end else
  begin
    if sType = 'ERROR' then
    begin
      if bNoPopUp then
      begin
        PanlMessageRT.Caption := sMsg;
        PanlMessageRT.Color := clSilver;
        PanlMessageRT.Font.Color := clRed;
        PanlMessageRT.Repaint;
        messageBeep(48);
      end
      else
      begin
        PanlMessageRT.Caption := '';
        PanlMessageRT.Color := clWhite;
        PanlMessageRT.Font.Color := clGreen;
        PanlMessageRT.Repaint;
        messageBeep(48);
        MessageDlg(sMsg, mtError, [mbOK], 0);
      end;
    end
    else
    begin
      PanlMessageRT.Caption := sMsg;
      PanlMessageRT.Color := clWhite;
      PanlMessageRT.Font.Color := clGreen;
      PanlMessageRT.Repaint;
    end;
  end;
end;

procedure TFormPrint.IniPrintPage;
var
  snType,i : Integer ;
begin
    snType := CurModelInfo.SN_TypeNum ;

    ZeroMemory(LabelNew,0);
    ZeroMemory(EditNew,0);

    SetLength(LabelNew,snType);
    SetLength(EditNew,snType);
    
    for i :=0 to snType-1 do
    begin
        LabelNew[i] := TLabel.Create(self);
        with LabelNew[i] do
        begin
            Parent := tsPrint;
            Caption := CurModelInfo.SN_Name[i] +':';
            Font := LabelSKU.Font;
            Top := LabelSKU.Top + (i+1)*45;
            Left := LabelSKU.Left + LabelSKU.Width - LabelNew[i].Width;
            Transparent := true ;
        end ;

        EditNew[i] := TEdit.Create(self);
        with EditNew[i] do
        begin
            Parent := tsPrint;
            Tag := i ;
            Width := 289 ;    //265
            Top := LabelNew[i].Top-8;
            Left := ComboSKU.Left;
            OnKeyPress := EditKeyPress;
            Font.Name :='Arial';
            Font.size := 16 ;
            Font.Color := clPurple ;
            CharCase := ecUpperCase ;
        end;
    end;
end;

procedure TFormPrint.FreeNewControl;
var
  n,i : Integer ;
  hwnd : THandle ;
begin
    n := CurModelInfo.SN_TypeNum ;
    try
        begin
            for i :=0 to n-1  do
            begin
                hwnd := EditNew[i].Handle ;
                if (IsWindow(hwnd)) and (EditNew[i] <> nil) then
                    EditNew[i].Free ;
                if (LabelNew[i]<> nil) then
                    LabelNew[i].Free
            end;
        end;
    finally
          //delete [] LabelNew;
          //delete [] EditNew;
    end;

    ZeroMemory(CurModelInfo.SN_Name,0);
    ZeroMemory(CurModelInfo.SN_Prefix,0);
    ZeroMemory(CurModelInfo.SN_Length,0);
    ZeroMemory(LabelNew,0);
    ZeroMemory(EditNew,0);
end;

procedure TFormPrint.EditKeyPress(Sender: TObject; var Key: Char);
var
  CurveEdit : TEdit;
begin
  //CurveEdit := TEdit(Sender) ;
  CurveEdit :=  (Sender AS TEdit )
end;

//--------------------------------------------------------------------------
procedure TFormPrint.ClearNewEdit(EditItem : Integer = -1);
var
  snType,i : Integer ;
begin
  if EditItem = -1 then
  begin
    snType := CurModelInfo.SN_TypeNum;
    for i := 0 to snType -1 do
        EditNew[i].Clear ;
  end else  EditNew[EditItem].Clear ;

end;
//--------------------------------------------------------------------------
procedure TFormPrint.SetNextFocus( Index : Integer ) ;
begin
    if(Index >= 0) then
    begin
        EditNew[Index].Clear();
        EditNew[Index].SetFocus();
    end;
end;

function TFormPrint.StrToColor(s: string): TColor;
var
  clo: Integer;
  sClo: string;
begin
  {±N¦r²Å¦êÂà´«¬°ÃC¦â}
  try
    if IdentToColor(s,clo)then
    begin
      sClo := IntToStr(clo);
      Result := StrToInt64(sClo);
    end
    else
    begin
      Result := StrToInt64(s) ;
    end;
  except
    Result := $000000;
  end;
end;

procedure TFormPrint.IniSKU_No(Sender: TObject);
var
  objCombox : TComboBox ;
begin
  objCombox := (Sender as TComboBox);
  objCombox.Clear ;
  with ObjDataSet.ObjQryData do
  begin
    Close ;
    Params.Clear ;
    Params.CreateParam(ftString ,'LABELTYPE',ptInput );
    CommandText := 'SELECT DISTINCT SKU_NO FROM SAJET.SYS_PRINT_LABEL_FILE  '+
                   '   WHERE LABEL_TYPE LIKE :LABELTYPE GROUP BY SKU_NO ORDER BY SKU_NO ';
    {CommandText := 'SELECT DISTINCT PARAM_TYPE SKU_NO FROM SAJET.SYS_PRINT_LABEL_FILE_PARAM '+
                   ' GROUP BY PARAM_TYPE ORDER BY  PARAM_TYPE '; }
    Params.ParamByName('LABELTYPE').AsString := LabelType +'%' ;
    Open ;
    if not IsEmpty then
    begin
      First ;
      while not Eof do
      begin
        if FieldByName('SKU_NO').AsString <> '' then
          objCombox.AddItem(FieldValues['SKU_NO'],objCombox );
        Next ;
      end;
    end;
    Close ;
  end;
end;

function TFormPrint.GetTempDirectory : String;
var
  TempDir : array[0..MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, @TempDir);
  Result := StrPas(TempDir);
end;

function TFormPrint.DownloadSampleFile(SKU : string): string;
VAR
  //LABELID : Integer ;
  //LABTYPE : string ;
  GetTempPath : string;
begin
  Result := 'Label SKU<'+SKU +'> not Found!';
  try
    //²Ä¤@ºØ¤èªk
    {FormLabelData := TFormLabelData.Create(Self) ;
    with FormLabelData do
    begin
      LabType2.Caption := 'SKU No List';
      LabType1.Caption := LabType2.Caption;
      lbl1.Caption := 'Search SKU ID';
      DataSource1.DataSet := ObjDataSet.ObjQryTemp ;
      with ObjDataSet.ObjQryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'SKU_NO', ptInput);
        Params.CreateParam(ftString, 'LABELTYPE', ptInput);
        CommandText := 'Select LABELFILE_ID,SKU_NO,LABEL_NAME,LABEL_FILE,LABEL_TYPE '
          + ' From SAJET.SYS_PRINT_LABEL_FILE Where SKU_NO LIKE :SKU_NO AND  '
          + '  LABEL_TYPE = :LABELTYPE  AND ENABLED = ''Y'' ORDER BY  LABEL_NAME ';
        Params.ParamByName('SKU_NO').AsString := SKU + '%';
        Params.ParamByName('LABELTYPE').AsString := LabelType ;
        //Params.CreateParam(ftString, 'TYPE', ptInput);
        //CommandText := 'Select LABELFILE_ID,SKU_NO,LABEL_NAME,LABEL_FILE,LABEL_TYPE ' +
                       //'  From SAJET.SYS_PRINT_LABEL_FILE Where LABEL_TYPE := TYPE AND '
                       //'   ENABLED = ''Y'' ORDER BY  LABEL_NAME ';
        //Params.ParamByName('TYPE').AsString := LabelType ;
        Open;
        if not IsEmpty then
        BEGIN
          edtComm.Text := Fields.Fields[0].AsString ;
          LABELID := FieldByName('LABELFILE_ID').AsInteger ;
          LABTYPE := FieldByName('LABEL_TYPE').AsString ;
        end ;
      end;

      if Showmodal = mrOK then
      begin
        LABELID := ObjDataSet.ObjQryTemp.FieldByName('LABELFILE_ID').AsInteger ;
        LABTYPE := ObjDataSet.ObjQryTemp.FieldByName('LABEL_TYPE').AsString ;
        ObjDataSet.ObjQryTemp.Close;
        DataSource1.DataSet := nil ;
        with ObjDataSet.ObjQryData do
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString,'RP_NO',ptInput);
          Params.CreateParam(ftString,'LABEL_ID',ptInput);
          Params.CreateParam(ftString,'LABELTYPE',ptInput);
          CommandText := 'Select LABEL_NAME,LABEL_FILE,LABEL_PWD ' +
                         '  From SAJET.SYS_PRINT_LABEL_FILE Where SKU_NO = :RP_NO AND ' +
                         '     LABELFILE_ID = :LABEL_ID AND  LABEL_TYPE = :LABELTYPE '+
                         '        AND ROWNUM = 1 ';
          Params.ParamByName('RP_NO').Value := SKU ;
          Params.ParamByName('LABEL_ID').Value := LABELID ;
          Params.ParamByName('LABELTYPE').Value := LABTYPE ;
          Open;
          if not Eof then
          begin
            if not FileExists(GetTempDirectory + Fieldbyname('LABEL_NAME').AsString) then
              TBlobField(Fieldbyname('LABEL_FILE')).SaveToFile(GetTempDirectory + Fieldbyname('LABEL_NAME').AsString);
            LabelFile := GetTempDirectory + Fieldbyname('LABEL_NAME').AsString;
            PassWord := Fieldbyname('LABEL_PWD').AsString;
            Result := 'OK';
          end;
          Close;
        end;
      end;
      FreeAndNil(FormLabelData);
    end;}

    //²Ä¤GºØ¤èªk,ª½±µ¤U¸üÀÉ®×
    with ObjDataSet.ObjQryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SKU_NO', ptInput);
      Params.CreateParam(ftString, 'LABELTYPE', ptInput);
      CommandText := 'Select LABEL_NAME,LABEL_FILE,LABEL_PWD, FILE_TYPE'
        + ' From SAJET.SYS_PRINT_LABEL_FILE Where SKU_NO = :SKU_NO AND  '
        + '  LABEL_TYPE = :LABELTYPE  AND ENABLED = ''Y'' AND '
        + '   ROWNUM = 1 ORDER BY  LABEL_NAME ';
      Params.ParamByName('SKU_NO').AsString := SKU ;
      Params.ParamByName('LABELTYPE').AsString := LabelType ;
      Open;
      if not Eof then
      begin
        GetTempPath := GetTempDirectory ;
        if not FileExists( GetTempPath+ Fieldbyname('LABEL_NAME').AsString) then
          TBlobField(Fieldbyname('LABEL_FILE')).SaveToFile(GetTempPath + Fieldbyname('LABEL_NAME').AsString);
        LabelFile := GetTempPath + Fieldbyname('LABEL_NAME').AsString;
        PassWord := Fieldbyname('LABEL_PWD').AsString;
        File_Type := Fieldbyname('FILE_TYPE').AsString;
        Result := 'OK';
      end;
      Close;
    end;

    {//²Ä¤TºØ¤èªk
    with ObjDataSet.ObjQryData do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'RP_NO',ptInput);
      Params.CreateParam(ftString,'LABEL_ID',ptInput);
      Params.CreateParam(ftString,'LABELTYPE',ptInput);
      CommandText := 'Select PARAM_TYPE,LABEL_NAME,LABEL_FILE,LABEL_PWD, ' +
                     ' LABEL_TYPE,PARAM_NAME,PARAM_VALUE From '+
                     '  SAJET.SYS_PRINT_LABEL_FILE A,SAJET.SYS_PRINT_LABEL_FILE_PARAM B '+
                     '   Where B.PARAM_TYPE = :RP_NO AND B.LF_ID = A.LABELFILE_ID(+) ' +
                     //'    AND B.LF_ID = :LABEL_ID '+
                     '     AND  B.FUNCTION_NAME = :LABELTYPE '+
                     '      ORDER BY PARAM_NAME ';
      Params.ParamByName('RP_NO').Value := SKU ;
      //Params.ParamByName('LABEL_ID').Value := LABELID ;
      Params.ParamByName('LABELTYPE').Value := LabelType ;
      Open;
      if  not Eof  then
      begin
        if TBlobField(Fieldbyname('LABEL_FILE')).BlobSize <= 0 then
        begin
          Close ;
          Result := 'Label File Is Empty!!' ;
          Exit ;
        end;
        if not FileExists(GetTempDirectory + Fieldbyname('LABEL_NAME').AsString) then
          TBlobField(Fieldbyname('LABEL_FILE')).SaveToFile(GetTempDirectory + Fieldbyname('LABEL_NAME').AsString);
        LabelFile := GetTempDirectory + Fieldbyname('LABEL_NAME').AsString;
        PassWord := Fieldbyname('LABEL_PWD').AsString;

        lstlpVariableName.Clear ;
        lstlpVariableValue.Clear ;
        while not Eof do
        begin
          lstlpVariableName.Items.Add(FieldByName('PARAM_NAME').AsString);
          lstlpVariableValue.Items.Add(FieldByName('PARAM_VALUE').AsString);
          Next ;
        end;
        Result := 'OK';
      end;
      Close;
    end;}
  except
    on E : Exception do
    begin
      if FormLabelData <> nil then
      begin
        FormLabelData.Close ;
        FreeAndNil(FormLabelData);
      end;
      Result := 'DownloadSampleFile ERROR ' + E.Message;
    end;
  end;
end;

procedure TFormPrint.StartLabelViewApp ;
begin
  try
    LabelApp := CoLabelApplication.Create;
    LabelApp.Visible := False ;   //Åã¥Üµ¡Åé   True
    iDIsp := LabelApp.ActiveDocument;
    //Lbl := CreateOleObject('Lblvw.Document');
  except
    on E: Exception do
    begin
      MessageDlg('±Ò°ÊLabelView¥¢±Ñ:'+E.Message,mtError ,[mbOK],0 );
      Application.Terminate ;
    end;
  end;
end;

procedure TFormPrint.StopLabelViewApp;
begin
  try
    if (LabelDoc <> nil) then
      LabelDoc.Close(True);
    if  LabelApp<>nil then
      LabelApp.Quit ;
  finally
    LabelField := nil;
    LabelFields := nil;
    LabelDoc := nil;
    LabelApp := nil;
  end;
end;

function TFormPrint.GetDB_DateTime : TDateTime ;
begin
  //¨ú±o¼Æ¾Ú®w¤¤ªº®É¶¡
  with ObjDataSet.ObjQryTemp do
  begin
     close;
     commandtext:='select sysdate from dual ';
     open;
     Result :=FieldByName('sysdate').AsDateTime ;
     Close ;
  end;
end;

function TFormPrint.GetProcessHandle(ProcessID : Integer ) : THandle;
begin
  Result :=  OpenProcess(PROCESS_ALL_ACCESS, FALSE, ProcessID);
end;

function TFormPrint.GetTimeString(ProcessID : Integer ) : TDateTime ;
var
  ASysTime: TSystemTime;
  ftCreationTime, ftExitTime, ftKernelTime, ftUserTime : FILETIME ;
  hProcess : THandle;
begin
  if ProcessID =0 then
  begin
    Result := 0;
    Exit ;
  end;
  hProcess := GetProcessHandle(ProcessID);
  GetProcessTimes(hProcess,ftCreationTime,ftExitTime,ftKernelTime,ftUserTime);
  FileTimeToSystemTime(ftCreationTime, ASysTime);
  Result := SystemTimeToDateTime(ASysTime);
end;

function TFormPrint.Check_LV_DbOpen : Boolean ;
var
   pe32 : PROCESSENTRY32 ;
   FindLV_Count : Integer ;
   FindCS_Count : Integer ;
   SnapshotHandle : THandle ;
   Str : string;
   ACreateTime,TNow : TDateTime ;
begin
   FindLV_Count := 0;
   FindCS_Count := 0 ;
   LVProcess.Clear ;
   pe32.dwSize := sizeof(PROCESSENTRY32);
   SnapshotHandle := CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, TH32CS_SNAPALL );
   if SnapshotHandle <> INVALID_HANDLE_VALUE  then
   begin
      if  Process32First( SnapshotHandle, pe32) then
      begin
         while Process32Next( SnapshotHandle, pe32 ) do
         begin
           Str := StrPas(pe32.szExeFile) ;
           if UpperCase(Str)='LV.EXE' then
           begin
              with LVProcess.Items.Add do
              begin
                Caption := Str ;
                SubItems.Add(FloatToStr(pe32.th32ProcessID));
                ACreateTime := GetTimeString(pe32.th32ProcessID);
                TNow := GetTimeString(GetCurrentProcessId) ;
                SubItems.Add(DateTimeToStr(ACreateTime));
                SubItems.Add(DateTimeToStr(TNow));
                //¨â­Ó®É®t¬O§_¦b2¤À¤§¤º
                {if WithinPastMinutes(TNow,ACreateTime,2) then
                  if WithinPastSeconds(TNow,ACreateTime,30) then //¨â­Ó®É®t¬O§_¦b20¬í¤º
                    SubItems.Add('N')
                  else
                  begin
                     SubItems.Add('Y') ;
                     ImageIndex := 1;
                  end
                else
                begin
                  SubItems.Add('Y');
                  ImageIndex:=0;
                end;}
                if pe32.th32ProcessID <> OpenLV_ProcessID then
                begin
                  SubItems.Add('Y') ;
                  ImageIndex := 1;
                end else
                  SubItems.Add('N') ;
              end;
              inc(FindLV_Count) ;
           end else if UpperCase(Str)=UpperCase('lppa.exe') then
           begin
              with LVProcess.Items.Add do
              begin
                Caption := Str ;
                SubItems.Add(FloatToStr(pe32.th32ProcessID));
                ACreateTime := GetTimeString(pe32.th32ProcessID);
                TNow := GetTimeString(GetCurrentProcessId) ;
                SubItems.Add(DateTimeToStr(ACreateTime));
                SubItems.Add(DateTimeToStr(TNow));
                //¨â­Ó®É®t¬O§_¦b2¤À¤§¤º
                {if WithinPastMinutes(TNow,ACreateTime,2) then
                  if WithinPastSeconds(TNow,ACreateTime,30) then //¨â­Ó®É®t¬O§_¦b20¬í¤º
                    SubItems.Add('N')
                  else
                  begin
                     SubItems.Add('Y') ;
                     ImageIndex := 1;
                  end
                else
                begin
                  SubItems.Add('Y');
                  ImageIndex:=0;
                end;}
                if pe32.th32ProcessID <> OpenCS_ProcessID then
                begin
                  SubItems.Add('Y') ;
                  ImageIndex := 1;
                end else
                  SubItems.Add('N') ;
              end;
              inc(FindCS_Count) ;
           end else if UpperCase(Str)=UpperCase('LabelDocApply.exe') then
           begin
             with LVProcess.Items.Add do
              begin
                Caption := Str ;
                SubItems.Add(FloatToStr(pe32.th32ProcessID));
                ACreateTime := GetTimeString(pe32.th32ProcessID);
                TNow := GetTimeString(GetCurrentProcessId) ;
                SubItems.Add(DateTimeToStr(ACreateTime));
                SubItems.Add(DateTimeToStr(TNow));
                SubItems.Add('N') ;
              end;
           end;
         end
      end;
   end;
   CloseHandle( SnapshotHandle );
   if (FindLV_Count >1) or (FindCS_Count >1) then
     Result := true
   else
     Result := false ;
end;

function TFormPrint.Check_LV_Open : Boolean ;
var
   pe32 : PROCESSENTRY32 ;
   SnapshotHandle : THandle ;
   Str : string;
begin
   Result := False ;
   pe32.dwSize := sizeof(PROCESSENTRY32);
   SnapshotHandle := CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, TH32CS_SNAPALL );
   if SnapshotHandle <> INVALID_HANDLE_VALUE  then
   begin
      if  Process32First( SnapshotHandle, pe32) then
      begin
         while Process32Next( SnapshotHandle, pe32 ) do
         begin
           Str := StrPas(pe32.szExeFile);
           if (UpperCase(Str)='LV.EXE') or (UpperCase(Str)='LPPA.EXE') then
           begin
              with LVProcess.Items.Add do
              begin
                Caption := Str ;
                SubItems.Add(FloatToStr(pe32.th32ProcessID));
                SubItems.Add('Y');
              end;
              Result :=True ;
           end;
         end
      end;
   end;
   CloseHandle( SnapshotHandle );
end;

function TFormPrint.Get_OpenLV_ProcessID : Boolean ;
var
   pe32 : PROCESSENTRY32 ;
   SnapshotHandle : THandle ;
   Str : string;
begin
   Result := False ;
   pe32.dwSize := sizeof(PROCESSENTRY32);
   SnapshotHandle := CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, TH32CS_SNAPALL );
   if SnapshotHandle <> INVALID_HANDLE_VALUE  then
   begin
      if  Process32First( SnapshotHandle, pe32) then
      begin
         while Process32Next( SnapshotHandle, pe32 ) do
         begin
           Str := StrPas(pe32.szExeFile);
           if UpperCase(Str)='LV.EXE' then
           begin
              OpenLV_ProcessID := pe32.th32ProcessID ;
              Result :=True ;
              Break ;
           end else if UpperCase(Str)='LPPA.EXE' then
           begin
             OpenCS_ProcessID := pe32.th32ProcessID ;
             Result := True ;
             Break ;
           end;
         end
      end;
   end;
   CloseHandle( SnapshotHandle );
end;

function TFormPrint.KillProcess( PID : Integer ) : Boolean ;
var
  Killed : Boolean;
begin
    Killed := TerminateProcess(OpenProcess(PROCESS_TERMINATE,False,PID),$FFFFFFFF);
    if not Killed then
      Result := False
    else
      Result := True ;
end;

// §R°£¥Ø¿ý©M¥Ø¿ý¤U­±ªº¤º®e ,  ¦ý©ñ¦^¦¬¯¸
procedure TFormPrint.DeleteFolder_SHF(sDeleteFolder : String; Recycling : Boolean = False);
var
  FileOp:SHFILEOPSTRUCT ;
begin
  if not DirectoryExists(sDeleteFolder) then Exit ;
  ZeroMemory(@FileOp,sizeof(FileOp));
  with FileOp do
  begin
    wFunc := FO_DELETE ;
    pFrom := PChar(sDeleteFolder) ;
    if Recycling then
      fFlags := FOF_ALLOWUNDO + FOF_NOCONFIRMATION + FOF_SILENT  // ¤£Åã¥Ü¶i«×®Ø , ¤£´£¥Ü¨t²Î«H®§ ,©ñ¤J¦^¦¬¯¸
    else
      fFlags := FOF_NOCONFIRMATION + FOF_SILENT ; // ¤£Åã¥Ü¶i«×®Ø , ¤£´£¥Ü¨t²Î«H®§ ,¤£©ñ¤J¦^¦¬¯¸
  end;
  SHFileOperation(FileOp);
End;

//¥u§R°£¤å¥ó , ¥B©ñ¦^¦¬¯¸
procedure TFormPrint.FileDel(FileString : String;Recycling : Boolean = False );
var
  FileOp:SHFILEOPSTRUCT ;
begin
  if not FileExists(FileString) then Exit ;
  ZeroMemory(@FileOp,sizeof(FileOp));
  With FileOp  do
  begin
    wnd := 0 ;
    wFunc := FO_DELETE ;            // H1¬O²¾°Ê H2¬O´_¨î H3¬O§R°£ H4¬O§ó¦W
    pFrom := PChar(FileString) ;
    if Recycling  then
      fFlags := FOF_ALLOWUNDO + FOF_NOCONFIRMATION + FOF_SILENT   // ¤£Åã¥Ü¶i«×®Ø , ¤£´£¥Ü¨t²Î«H®§ ,©ñ¤J¦^¦¬¯¸
    else
      fFlags := FOF_NOCONFIRMATION + FOF_SILENT;    // ¤£Åã¥Ü¶i«×®Ø , ¤£´£¥Ü¨t²Î«H®§ ,©ñ¤J¦^¦¬¯¸
  End ;
  SHFileOperation(FileOp)
end ;

procedure TFormPrint.FormCreate(Sender: TObject);
var
  i : Integer ;
  //root : TTreeNode ;
begin
  //µù¥UWindows¼öÁä
  //HotKeyId := GlobalAddAtom('MyHotKey') - $C000;
  //RegisterHotKey(Handle, HotKeyId, 0, VK_F5);

  //³Ð«ØLabelVies¤§«e¥ýÀË¬d¬O§_¤w¸g¦³¶}±Ò¥´¦Lµ{§Ç
  if Check_LV_Open then
  begin
    if (LVProcess.Items.Count >0) then
    begin
      for i :=  0 to LVProcess.Items.Count - 1 do
        KillProcess(StrToInt(LVProcess.Items.Item[i].SubItems[0]));
    end ;
  end;

  //¥ý¤£­n³Ð«Ø¥´¦Lµ{§Ç,=¨ì¿ï¾ÜÀÉ®×«á¦A³Ð«Ø
  {StartLabelViewApp ;     //³Ð«ØLabel App
  Get_OpenLV_ProcessID ;  //¨úªº³Ð«ØLabelViewªº¶iµ{ID

  //«Ì½ªLABELVIEWªºÃö³¬«öÁä,¨¾¤î·N¥~³QÃö³¬
  hLVHandle := FindWidowByWinClsName('LabelViewMFC','Teklynx LabelView XLT') ;
  EnableMenuItem(GetSystemMenu(hLVHandle, FALSE), SC_CLOSE, MF_BYCOMMAND or MF_GRAYED);//¤ä±¼Ãö³¬«ö¶s
  SetWindowPos(hLVHandle ,HWND_NOTOPMOST ,500 ,500 ,400 ,200 ,SWP_HIDEWINDOW );    //SWP_NOMOVE or SWP_NOSIZE   SWP_NOMOVE
  //¨ú±o©Ò¥Hµæ³æ¶µ¥Ø
  if hLVHandle <> 0 then
  begin
    if GetMenu(hLVHandle) <>0 then
    begin
      TreeView1.Items.Clear ;
      root := TreeView1.Items.Add(nil,'Main Menu');
      AddChildMenus(root,GetMenu(hLVHandle),TreeView1);
      TreeView1.FullExpand ;
      Refresh ;
    end;
  end;}

  InitializeForm ;
  //TimerDbLVCheck.Enabled := true ;   //LabelViewÂù¶}ÀË¬d
  //Timer1.Enabled := true ;
  RunOnce := true ;
  Running := False ;
  RunPrintProg := false ;
  BanPrintDlage := true ;
end;

function  TFormPrint.DeleteDirectory(NowPath:   string; FileType : string = '*.lbl'):   Boolean;   //§R°£¾ã­Ó¥Ø¿ý
var
    search:   TSearchRec;
    ret:   integer;
    key:   string;
begin
    if   NowPath[Length(NowPath)] <> '\' then
        NowPath   :=   NowPath   +   '\';
    key   :=   Nowpath   +  FileType ;//'*.lbl';
    ret   :=   FindFirst(key,   faanyfile,   search);
    while   ret   =   0   do
    begin
        if   ((search.Attr   and   fadirectory)   =   faDirectory)
            then   begin
            if   (Search.Name   <>   '.')   and   (Search.name   <>   '..')   then
                DeleteDirectory(NowPath   +   Search.name);
        end   else   begin
            if   ((search.attr   and   fadirectory)   <>   fadirectory)   then   begin
                deletefile(NowPath   +   search.name);
                //FileDel(NowPath   +   search.name);   //§R°£ÀÉ®×
            end;
        end;
        ret   :=   FindNext(search);
    end;
    FindClose(search);
    Removedir(NowPath);
    Result   :=   True;
end;

procedure TFormPrint.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FormMain.Show ;
  Action := caFree ;
end;

procedure TFormPrint.FormDestroy(Sender: TObject);
begin
  {DeleteDirectory(GetTempDirectory) ;   //§R°£¤å¥ó§¨¤U©Ò¥Hlbl¤å¥ó
  DeleteDirectory(GetTempDirectory,'*.lvd') ;   //§R°£¤å¥ó§¨¤U©Ò¥Hlbl¤å¥ó
  DeleteDirectory(GetTempDirectory,'*.prv') ;   //§R°£¤å¥ó§¨¤U©Ò¥Hlbl¤å¥ó}
  StopLabelViewApp;
  {if not VarIsNull(m_Documents) then
    m_Documents.Close ;
  if not VarIsNull(m_CodeSoft) then
    m_CodeSoft.Quit; }
  m_CodeSoft.Free ;
end;

procedure TFormPrint.ComboSKUDropDown(Sender: TObject);
begin
  IniSKU_No(Sender);
end;

procedure TFormPrint.ComboSKUChange(Sender: TObject );
var
  TRES : string ;
  objCombox : TComboBox;
  //i : Integer ;
  WeekOfYear : string ;
begin
  objCombox := (Sender as TComboBox );
  if CheckSNWeight then
  begin
    GetWeigthLimit(objCombox.Text ,TRES);
    if TRES <> 'OK' then
    begin
      ShowMsg(TRES ,'ERROR');
      objCombox.ItemIndex := -1;
      Exit ;
    end;
  end;

  if CheckGiftBoxPN then
    GetGifBoxPN(objCombox.Text ,TRES) ;
  if Sender = ComboSKUR then
  begin
    if CheckGiftBoxPN then
    begin
      if TRES <>'OK' then
      begin
        ShowMsg(TRES ,'ERROR');
        objCombox.ItemIndex := -1;
        Exit ;
      end;
      SetEditStatus('GIFBOX');
      ShowMsg('SKU Select OK.', '');
    end else
    begin
      SetEditStatus('RTSN');
      ShowMsg('SKU Select OK.', '');
    end;
  end else if Sender = ComboSKUH then
  begin
    if not GetLVcolorData then
    begin
      objCombox.ItemIndex := -1;
      Exit ;
    end else
    begin
      SetEditStatus('HBSN');
      ShowMsg('SKU Select OK.', '');
    end;
  end else if Sender = ComboSKU then
  begin
    GetGifBoxPN(objCombox.Text ,TRES) ;
    if TRES <>'OK' then
    begin
      ShowMsg(TRES ,'ERROR');
      objCombox.ItemIndex := -1;
      Exit ;
    end;
    SetEditStatus('SN');
    ShowMsg('SKU Select OK.', '');
  end;

  SelectLabelFile(objCombox.Text ,TRES);
  if TRES <> 'OK' then
  begin
    MessageBox(GetActiveWindow ,PChar(TRES),'Error',MB_OK+MB_ICONERROR) ;
    objCombox.Enabled := True ;
    objCombox.ItemIndex := -1;
    objCombox.SetFocus ;
    Exit ;
  end;

  if Sender = ComboSKUR then
  begin
    edtRTSKUNO.Text := GetLabelValue('SKU_No') ;
  end else if Sender = ComboSKUH then
  begin
    edtHbSKUNO.Text := GetLabelValue('SKU_No');
  end else if Sender = ComboSKU then
  begin
    edtSKUNO.Text := GetLabelValue('SKU_No') ;
  end;

  WeekOfYear := FormatDateTime('YY',GetDB_DateTime)+IntToStr(WeekOfTheYear(GetDB_DateTime));
  //¿é¤JLabel Lot_No
  if FormSKU <> nil then
  begin
    FormSKU.Close ;
    FreeAndNil(FormSKU);
  end;
  with TFormSKU.Create(nil) do
  begin
    Caption := 'Enter Lot_No' ;
    Label1.Caption := 'Enter Label Lot Number';
    TBarcode.Text := WeekOfYear ;
    EditWO.Text := Copy(mWO,3,6) ;

    if ShowModal = mrok then
    begin
      if not SetLabelValue('Lot_No',Lot_No ) then
      begin
        MessageDlg('¼g¤JLot No¥¢±Ñ',mtError ,[mbOK],0);
        Exit ;
      end;
      if not SetLabelValue('WO',Label_WO) then
      begin
        MessageDlg('¼g¤JWO¥¢±Ñ',mtError ,[mbOK],0);
        Exit ;
      end;
      LabelDocApply ;
    end else
    begin
      MessageBox(GetActiveWindow ,'Label Lot No ¿é¤J¿ù»~!','Error',MB_OK+MB_ICONERROR) ;
      objCombox.Enabled := True ;
      objCombox.ItemIndex := -1;
      objCombox.SetFocus ;
    end;
    Free ;
  end;
end;

procedure TFormPrint.SelectLabelFile(SKU_No : string; var TRES :string) ;
var
  root : TTreeNode ;
  sMessage : string;
begin
  TRES := DownloadSampleFile(SKU_No );      //±qªA°È¾¹¤U¸ü¥´¦LÀÉ®×
  if TRES <> 'OK' then Exit ;
  if not FileExists(LabelFile) then
  begin
    TRES := 'DownloadSampleFile Error(¤U¸ü¼ÐÅÒ¤å¥ó¥¢±Ñ)!!' ;
    Exit ;
  end;

  if UpperCase(File_Type) = UpperCase('.lbl') then
  begin
    //¥ý³Ð«Ø¥´¦Lµ{§Ç
    if not RunPrintProg then
    begin
      StartLabelViewApp ;     //³Ð«ØLabel App
      Get_OpenLV_ProcessID ;  //¨úªº³Ð«ØLabelViewªº¶iµ{ID

      //«Ì½ªLABELVIEWªºÃö³¬«öÁä,¨¾¤î·N¥~³QÃö³¬
      hLVHandle := FindWidowByWinClsName('LabelViewMFC','Teklynx LabelView XLT') ;
      EnableMenuItem(GetSystemMenu(hLVHandle, FALSE), SC_CLOSE, MF_BYCOMMAND or MF_GRAYED);//¤ä±¼Ãö³¬«ö¶s
      SetWindowPos(hLVHandle ,HWND_NOTOPMOST ,500 ,500 ,400 ,200 ,SWP_HIDEWINDOW );    //SWP_NOMOVE or SWP_NOSIZE   SWP_NOMOVE
      //¨ú±o©Ò¥Hµæ³æ¶µ¥Ø
      if hLVHandle <> 0 then
      begin
        if GetMenu(hLVHandle) <>0 then
        begin
          TreeView1.Items.Clear ;
          root := TreeView1.Items.Add(nil,'Main Menu');
          AddChildMenus(root,GetMenu(hLVHandle),TreeView1);
          TreeView1.FullExpand ;
          Refresh ;
        end;
      end;

      if LabelApp <> nil then
        ShapePrinter.Brush.Color := clGreen
      else
        ShapePrinter.Brush.Color := clRed ;
      RunPrintProg := True ;
    end;

    //¦h½uµ{¿é¤J±K½X
    hThread := CreateThread(nil,0,@AutoInputPWD,nil,0,tHreadid );    //³Ð«Ø½uµ{¨Ã¥ß§Y°õ¦æ
    if hThread=0 then
    begin
      messagebox(handle,'³Ð«Ø¥¢±Ñ',nil,mb_ok);
      Exit ;
    end;
    OpenLabelFile(LabelFile) ;
    TerminateThread(hThread ,2);//µ²§ô½uµ{
  end else if UpperCase(File_Type) = UpperCase('.lab') then
  begin
    //¥ý³Ð«Ø¥´¦Lµ{§Ç
    if not RunPrintProg then
    begin
      m_CodeSoft:=TCodeSoft.Create(Self);   //³Ð«ØCS6¹ê¨Ò
      m_CodeSoft.Linked:= not m_CodeSoft.Linked;   //³s±µCS
      m_CodeSoft.LockedCS(True);      //Âê¦í 
      Get_OpenLV_ProcessID ;  //¨úªº³Ð«ØLabelViewªº¶iµ{ID

      //«Ì½ªLABELVIEWªºÃö³¬«öÁä,¨¾¤î·N¥~³QÃö³¬
      hLVHandle := FindWidowByWinClsName('CodesoftWndClass','CODESOFT 6 Enterprise') ;
      EnableMenuItem(GetSystemMenu(hLVHandle, FALSE), SC_CLOSE, MF_BYCOMMAND or MF_GRAYED);//¤ä±¼Ãö³¬«ö¶s
      if not m_CodeSoft.OpenSampleFile(LabelFile,sMessage) then showmessage(sMessage);

      if m_CodeSoft.Linked then
        ShapePrinter.Brush.Color := clGreen
      else
        ShapePrinter.Brush.Color := clRed ;
      RunPrintProg := True ;
    end else if not m_CodeSoft.OpenSampleFile(LabelFile,sMessage) then showmessage(sMessage);
  end;
  TimerDisibleSaveAs.Enabled := true ;
  TimerDbLVCheck.Enabled := true ;   //LabelViewÂù¶}ÀË¬d
  Timer1.Enabled := true ;
  TRES := 'OK';
end;

procedure TFormPrint.OpenLabelFile(lpFilePath : string) ;
{var
  lpFilePath : string ;}
begin
  //FreeOnRelease := True ;
  //lpFilePath := LabelFile ;
  iDIsp := LabelApp.ActiveDocument;
  if iDIsp <> nil then
  begin
    iDIsp.QueryInterface(ILabelDocument, LabelDoc);
    LabelDoc.Open(lpFilePath, True );  //¥´¶}¤å¥ó
  end ;
  //Lbl.Open(lpFilePath, True);
  //LabelDoc
end;

function TFormPrint.SetLabelValue(lpVarName , lpValues : String) :Boolean ;
begin
  Result := False ;
  try
    {iDIspFields := LabelDoc.LabelFields;  //Àò¨ú¦r¬q¦Cªí±µ¤f
    if iDIspFields <> nil then
    begin
      iDIspFields.QueryInterface(DIID_ILabelFields, LabelFields);
      iDIspField := LabelFields.Item(lpVarName);
      if iDIspField <> nil then
      begin
        iDIspField.QueryInterface(DIID_ILabelField, LabelField);
        LabelField.Value := lpValues;
        Result := True ;
      end;
    end;}
    if LabelDoc = nil then Exit ;
    iDIsp := LabelDoc.LabelFields;  //Àò¨ú¦r¬q¦Cªí±µ¤f
    if iDIsp <> nil then
    begin
      iDIsp.QueryInterface(DIID_ILabelFields, LabelFields);
      iDIsp := LabelFields.Item(lpVarName);
      if iDIsp <> nil then
      begin
        iDIsp.QueryInterface(DIID_ILabelField, LabelField);
        //LabelField.Length := Length(lpValues);
        LabelField.Value :=lpValues ;
        Result := True ;
      end;
    end;
    LabelFields := nil ;
    LabelField := nil ;
    iDIsp := nil ;
  except
    Result := False ;
  end;
End ;

function TFormPrint.ExistVariableName (lpVarName: String; var lpValues : String) : Boolean ;
var
  i : Integer ;
begin
  Result := False ;
  try
    if LabelDoc = nil then Exit ;
    iDIsp := LabelDoc.LabelFields;  //Àò¨ú¦r¬q¦Cªí±µ¤f
    if iDIsp <> nil then
    begin
      iDIsp.QueryInterface(DIID_ILabelFields, LabelFields);
      for i := 0 to LabelFields.Count -1 do
      begin
        iDIsp := LabelFields.Item(i);
        if iDIsp <> nil then
        begin
          iDIsp.QueryInterface(DIID_ILabelField, LabelField);
          if UpperCase(LabelField.Name) = UpperCase(lpVarName) then
          begin
            lpValues := LabelField.Value ;
            Result := True ;
            Break ;
          end;
        end;
      end;
    end;
    LabelFields := nil ;
    LabelField := nil ;
    iDIsp := nil ;
  except
    Result := False ;
  end;
End ;

procedure TFormPrint.LabelDocApply ;
begin
  //¦h½uµ{¿é¤J±K½X
  hThread := CreateThread(nil,0,@LabelDocValueApply,nil,0,tHreadid );    //³Ð«Ø½uµ{¨Ã¥ß§Y°õ¦æ
  if hThread=0 then
  begin
    messagebox(handle,'³Ð«Ø¥¢±Ñ',nil,mb_ok);
    Exit ;
  end;
  //if LabelDoc <> nil then LabelDoc.LabelSetup ;
  LabelDoc.LabelSetup ;
  TerminateThread(hThread ,2);//µ²§ô½uµ{
  {EnabledLabelDocApply ;
  LabelDoc.LabelSetup ;
  DisabledLabelDocApply ;}

  {SetWindowText(FindWindow('TLabelDocApplyForm',nil),'START');
  LabelDoc.LabelSetup ;
  SetWindowText(FindWindow('TLabelDocApplyForm',nil),'STOP');}
end;

function TFormPrint.GetLabelValue(lpVarName : String) : String ;
begin
  Result := '';
  try
    if not Assigned(LabelDoc) then Exit ;
    iDIsp := LabelDoc.LabelFields;  //Àò¨ú¦r¬q¦Cªí±µ¤f
    if iDIsp <> nil then
    begin
      iDIsp.QueryInterface(DIID_ILabelFields, LabelFields);   //Àò¨ú¦r¬q±µ¤f
      iDIsp := LabelFields.Item(lpVarName);
      if iDIsp <> nil then
      begin
        iDIsp.QueryInterface(DIID_ILabelField, LabelField);
        Result := LabelField.Value;
      end;
    end;
  finally
    LabelFields := nil ;
    LabelField := nil ;
    iDIsp := nil ;
  end;
End ;

procedure TFormPrint.LvPrintLabel(lpPrintValue : array of string; Loop : Integer ;var TRES :string ;lpPrintQty : Integer = 1) ;
var
  i : Integer ;
begin
  TRES := 'LvPrintLabel Fail';
  for i := 1 to Loop do
  begin
    if lpPrintValue[i-1] <> '' then
    begin
      Delay(20);
      if not SetLabelValue(LabelVariable + IntToStr(i),lpPrintValue[i-1]) then Exit;
      if PrintType = 'Shipper_Pack' then
        self.Memo1.Lines.Add(lpPrintValue[i-1])
      else if PrintType = 'Mingle_Pack' then
        Self.Memo3.Lines.Add(lpPrintValue[i-1]);
    end;
  end;
  //LabelDocApply ;  //¨ê·s¶Ç¤Jªº¥´¦L¤º®e,§_«h¥´¦L¥X¨Óªº¤º®e¤£ÅÜ
  //Sleep(20);
  if LabelDoc <> nil then
    //LabelDoc.PrintLabel(lpPrintQty, 0, 0, 0, 0, 0, 0); //¥´¦L¡A¼Æ¶q¬°1
    LVMenuPrint(TreeView1,lpPrintQty);
  if PrintType = 'Shipper_Pack' then
    self.Memo1.Lines.Add('******************************')
  else if PrintType = 'Mingle_Pack' then
    Self.Memo3.Lines.Add('******************************');
  TRES := 'OK';
end;

procedure TFormPrint.GetGifBoxPN(SKU :string ;var TRES : string) ;
begin
  TRES := 'GifBox PN or UPC No not found!';
  ListGifBoxPN.Clear;
  ListUPC.Clear ;
  with ObjDataSet.ObjQryTemp do
  begin
    Close ;
    Params.Clear ;
    Params.CreateParam(ftString,'SKU',ptInput);
    CommandText := 'SELECT  SKU_NO,Gift_Box_PN,UPC_NO FROM SAJET.SYS_PART_GIFT_BOX_PN ' +
                   '  WHERE SKU_NO = :SKU AND ENABLED = ''Y'' ' ;
    Params.ParamByName('SKU').Value := SKU;
    Open ;
    if not IsEmpty then
    begin
      while not eof do
      begin
        ListGifBoxPN.AddItem(FieldByName('Gift_Box_PN').AsString,ListGifBoxPN);
        ListUPC.AddItem(FieldByName('UPC_NO').AsString,ListUPC);
        Next ;
      end;
      Close ;
      TRES := 'OK';
    end;
    Close ;
  end;
end;

procedure TFormPrint.GetWeigthLimit(SKU :string ;var TRES : string);
begin
  TRES := 'Weight Limit not found!';
  with ObjDataSet.ObjQryData do
  begin
    Close ;
    Params.Clear ;
    Params.CreateParam(ftString ,'SKU',ptInput);
    CommandText := 'SELECT UP_LIMIT,LOW_LIMIT,WAIT_TIME,WEIGHT_COUNT FROM SAJET.SYS_PART_WEIGHT_PARAM ' +
                   ' WHERE SKU_NO = :SKU AND ENABLED = ''Y'' AND ROWNUM = 1 ' ;
    Params.ParamByName('SKU').Value := SKU;
    Open ;
    if not IsEmpty then
    begin
      Up_Limit := FieldValues['UP_LIMIT'] ;
      Low_Limit := FieldValues['LOW_LIMIT'];
      Wait_Time := FieldValues['WAIT_TIME'];
      Weight_Count := FieldValues['WEIGHT_COUNT'];
      WeightForm.EditUpLimit.Text := FloatToStr(Up_Limit);
      WeightForm.EditLowLimit.Text := FloatToStr(Low_Limit);
      TRES := 'OK';
    end;
    Close ;
  end;
end;

procedure TFormPrint.Timer1Timer(Sender: TObject);
var
  LabelView_Handle, Button_HWND : LongInt ;
begin
  EditDate.Text := FormatDateTime('YYYY/MM/DD',now);
  EditTime.Text := FormatDateTime('HH:MM:SS',now);

  if BanPrintDlage then
  begin
    LabelView_Handle := FindWindow(nil, 'Quick Printing') ;
    if  LabelView_Handle <=0 then
      LabelView_Handle := FindWindow(nil, '§Ö³t¥´¦L') ;
    if  LabelView_Handle > 0 then
    begin
      Button_HWND := FindWindowEx(LabelView_Handle,0,'Button','Ãö³¬(&C)') ;
      if Button_HWND <= 0 then
         Button_HWND := FindWindowEx(LabelView_Handle,0,'Button','&Close') ;
      if Button_HWND >0 then begin
        PostMessage(Button_HWND,WM_LBUTTONDOWN ,0,0);
        PostMessage(Button_HWND,WM_LBUTTONUP ,0,0);
      end;
      //MoveWindow(LabelView_Handle, 0, Screen.Height - 10, 0, 0, True);
      InvalidateRgn(GetDesktopWindow, 0, True) ;
    end;

    LabelView_Handle := FindWindow('#32770', 'When Printed Field') ;
    if  LabelView_Handle > 0 then
    begin
      Button_HWND := FindWindowEx(LabelView_Handle,0,'Button','¨ú®ø[&C]') ;
      if Button_HWND <= 0 then
         Button_HWND := FindWindowEx(LabelView_Handle,0,'Button','&Cancel') ;
      if Button_HWND >0 then begin
        PostMessage(Button_HWND,WM_LBUTTONDOWN ,0,0);
        PostMessage(Button_HWND,WM_LBUTTONUP ,0,0);
      end;
    end;
  end;
end;

procedure TFormPrint.BitBtn1Click(Sender: TObject);
begin
  if LabelDoc <> nil then
    LabelDoc.Close(False ) ;
  mCurrentCount := 1;
  ZeroMemory(@mArrTypeSN,SizeOf(mArrTypeSN));
  ListGifBoxPN.Clear ;
  ListUPC.Clear ;
  lstlpVariableName.Clear ;
  lstlpVariableValue.Clear ;
  SetEditStatus('SKU');
end;

procedure TFormPrint.TimerDbLVCheckTimer(Sender: TObject);
{var
  I : Integer ;
  FindExE : Boolean ;}
begin
  if not Running then
  begin
    if Check_LV_DbOpen then
    begin
        TimerDbLVCheck.Enabled :=false ;
        ErrorForm := TErrorForm.Create(Self);
        ErrorForm.Show ;
        ErrorForm.Memo1.Text := 'ÀË´ú¨ìLabelView©ÎCodeSoft¥´¦Lµ{§ÇÂù¶}';
        ErrorForm.Edit1.SetFocus ;
    end;

    if LVProcess.Items.Count <= 0 then
    begin
      ShapePrinter.Pen.Color := clRed ;
      TimerDbLVCheck.Enabled :=false ;
      MessageDlg(#13+'ÀË´ú¨ìLabelView©ÎCodeSoftµ{§Ç³Q«DªkÃö³¬,½Ð­«·s¶}±Ò¦¹µ{§Ç!',mtWarning ,[mbOK],0);
      Close ;
      Application.Terminate ;
    end;
    Running := False ;
  end;
end;

procedure TFormPrint.BitBtnWeightClick(Sender: TObject);
begin
   WeightForm.Show;
end;

procedure TFormPrint.BitBtn4Click(Sender: TObject);
var
  LabelView_Handle : LongInt ;
  hpbt :HWND ;
begin
  if UpperCase(File_Type) ='.LBL' then
  begin
    if LabelApp <> nil then
      LabelApp.Visible := not LabelApp.Visible ;
    if LabelApp <> nil then
    begin
      if LabelApp.Visible then
        TBitBtn(Sender).Caption := 'ÁôÂÃ&H'
      else
        TBitBtn(Sender).Caption := 'Åã¥Ü&O';

      if LabelApp.Visible then
      begin
        PostMessage(hLVHandle,WM_SYSCOMMAND,SC_MAXIMIZE,0);        //   SC_RESTORE
        LabelView_Handle := FindWindow(nil, 'Quick Printing') ;
        if  LabelView_Handle <=0 then
          LabelView_Handle := FindWindow(nil, '§Ö³t¥´¦L') ;
        if  LabelView_Handle > 0 then
        begin
          hpbt := FindWindowEx(LabelView_Handle, 0, 'Button', '&Close') ;
          If hpbt <= 0 Then hpbt := FindWindowEx(LabelView_Handle, 0, 'Button', 'Ãö³¬(&C)') ;
          If hpbt > 0 Then
          begin
              PostMessage(hpbt, WM_LBUTTONDOWN, 0, 0) ;
              PostMessage(hpbt, WM_LBUTTONUP, 0, 0) ;
          End ;
        end;
      end;
    end;
  end else if UpperCase(File_Type)= '.LAB' then
  begin
    m_CodeSoft.Visibled := not m_CodeSoft.Visibled;
    if m_CodeSoft.Visibled then TBitBtn(Sender).Caption := 'ÁôÂÃ&H'//bbtnVisible.Caption:='CS Visible'
    else TBitBtn(Sender).Caption := 'Åã¥Ü&O';//bbtnVisible.Caption:='CS NOT Visible';
  end;
end;

procedure  TFormPrint.ShowTerminal;
var sLine, sStage, sProcess: string; bNoMatch: Boolean;
  mNodeLine, mNodeStage, mNodeProcess, mNodeTerminal: TTreeNode;
begin
  TreePC.Items.Clear;
  bNoMatch := True;
  with ObjDataSet.ObjQryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'FCID', ptInput);
    Params.CreateParam(ftString, 'TYPENAME', ptInput);
    CommandText := 'SELECT PDLINE_NAME, STAGE_CODE, STAGE_NAME, PROCESS_CODE, PROCESS_NAME, ' +
      'TERMINAL_ID, TERMINAL_NAME ' +
      'FROM SAJET.SYS_TERMINAL A, ' +
      'SAJET.SYS_PDLINE B, ' +
      'SAJET.SYS_STAGE C, ' +
      'SAJET.SYS_PROCESS D, ' +
      'SAJET.SYS_OPERATE_TYPE E ' +
      'WHERE B.FACTORY_ID = :FCID AND ' +
      'A.PDLINE_ID = B.PDLINE_ID AND ' +
      'A.STAGE_ID = C.STAGE_ID AND ' +
      'A.PROCESS_ID = D.PROCESS_ID AND ' +
      'D.OPERATE_ID = E.OPERATE_ID AND ' +
      'E.TYPE_NAME = :TYPENAME AND ' +
      'A.ENABLED = ''Y'' AND ' +
      'B.ENABLED = ''Y'' AND ' +
      'C.ENABLED = ''Y'' AND ' +
      'D.ENABLED = ''Y'' ' +
      'ORDER BY PDLINE_NAME, STAGE_CODE, PROCESS_CODE, TERMINAL_NAME ';
    Params.ParamByName('FCID').AsString := FcID;
    Params.ParamByName('TYPENAME').AsString := 'Packing';
    Open;
    if not IsEmpty then
    begin
      sLine := Fieldbyname('PDLINE_NAME').AsString;
      sStage := Fieldbyname('STAGE_NAME').AsString;
      sProcess := Fieldbyname('PROCESS_NAME').AsString;
      mNodeLine := TreePC.Items.AddChildFirst(nil, FieldByName('PDLINE_NAME').asstring);
      mNodeLine.ImageIndex := 0;
      mNodeStage := TreePC.Items.AddChildFirst(mNodeLine, FieldByName('STAGE_NAME').asstring);
      mNodeStage.ImageIndex := 1;
      mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, FieldByName('PROCESS_NAME').asstring);
      mNodeProcess.ImageIndex := 2;
    end;
    while not Eof do
    begin
      if sLine <> Fieldbyname('PDLINE_NAME').AsString then
      begin
        sLine := Fieldbyname('PDLINE_NAME').AsString;
        sStage := Fieldbyname('STAGE_NAME').AsString;
        sProcess := Fieldbyname('PROCESS_NAME').AsString;
        mNodeLine := TreePC.Items.AddChildFirst(nil, FieldByName('PDLINE_NAME').asstring);
        mNodeLine.ImageIndex := 0;
        mNodeStage := TreePC.Items.AddChildFirst(mNodeLine, FieldByName('STAGE_NAME').asstring);
        mNodeStage.ImageIndex := 1;
        mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, FieldByName('PROCESS_NAME').asstring);
        mNodeProcess.ImageIndex := 2;
      end;
      if sStage <> Fieldbyname('STAGE_NAME').AsString then
      begin
        sStage := Fieldbyname('STAGE_NAME').AsString;
        sProcess := Fieldbyname('PROCESS_NAME').AsString;
        mNodeStage := TreePC.Items.AddChildFirst(mNodeLine, FieldByName('STAGE_NAME').asstring);
        mNodeStage.ImageIndex := 1;
        mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, FieldByName('PROCESS_NAME').asstring);
        mNodeProcess.ImageIndex := 2;
      end;
      if sProcess <> Fieldbyname('PROCESS_NAME').AsString then
      begin
        sProcess := Fieldbyname('PROCESS_NAME').AsString;
        mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, FieldByName('PROCESS_NAME').asstring);
        mNodeProcess.ImageIndex := 2;
      end;

      mNodeTerminal := TreePC.Items.AddChild(mNodeProcess, FieldByName('TERMINAL_NAME').asstring);
      mNodeTerminal.ImageIndex := 3;
      if FieldByName('TERMINAL_ID').asstring = TerminalID then
      begin
        TreePC.Selected := mNodeTerminal;
        LabPDLine.Caption := mNodeTerminal.Parent.Parent.Parent.Text;
        LabStage.Caption := mNodeTerminal.Parent.Parent.Text;
        LabProcess.Caption := mNodeTerminal.Parent.Text;
        LabTerminal.Caption := mNodeTerminal.Text;
        bNoMatch := False;
      end;
      next;
    end;
    Close;
    mNodeLine := nil;
    mNodeStage := nil;
    mNodeProcess := nil;
    if bNoMatch then TerminalID := '';
  end;
end;

function TFormPrint.GetTerminalData(TerminalName: string; PdLineID: string; ProcessID: string; var TerminalID: string): Boolean;
var S: string;
begin
  Result := False;
  with ObjDataSet.ObjQryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PDLINE_ID', ptInput);
    Params.CreateParam(ftString, 'PROCESS_ID', ptInput);
    Params.CreateParam(ftString, 'TERMINAL_NAME', ptInput);
    CommandText := 'SELECT TERMINAL_ID ' +
      'FROM SAJET.SYS_TERMINAL ' +
      'WHERE PDLINE_ID = :PDLINE_ID AND ' +
      'PROCESS_ID = :PROCESS_ID AND ' +
      'TERMINAL_NAME = :TERMINAL_NAME ';
    Params.ParamByName('PDLINE_ID').AsString := PdLineID;
    Params.ParamByName('PROCESS_ID').AsString := ProcessID;
    Params.ParamByName('TERMINAL_NAME').AsString := TerminalName;
    Open;
    if RecordCount > 0 then
      TerminalID := Fieldbyname('TERMINAL_ID').AsString;
    Close;
  end;

  if TerminalID = '' then
  begin
    S := 'Terminal data Error !! ' + #13#10 +
      'Terminal Name : ' + TerminalName;
    MessageDlg(S, mtError, [mbCancel], 0);
    Exit;
  end;
  Result := True;
end;

procedure TFormPrint.cmbFactoryChange(Sender: TObject);
begin
  FcID := '';
  LabPDLine.Caption := '';
  LabStage.Caption := '';
  LabProcess.Caption := '';
  LabTerminal.Caption := '';

  with ObjDataSet.ObjQryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'FACTORYCODE', ptInput);
    CommandText := 'SELECT FACTORY_ID, FACTORY_CODE, FACTORY_NAME, FACTORY_DESC ' +
      'FROM SAJET.SYS_FACTORY ' +
      'WHERE FACTORY_CODE = :FACTORYCODE ';
    Params.ParamByName('FACTORYCODE').AsString := Copy(cmbFactory.Text, 1, POS(' ', cmbFactory.Text) - 1);
    Open;
    if RecordCount > 0 then
      FcID := Fieldbyname('FACTORY_ID').AsString;
    Close;
  end;
  ShowTerminal;
end;

procedure TFormPrint.TreePCClick(Sender: TObject);
begin
  if TreePC.Selected = nil then Exit;

  LabPDLine.Caption := '';
  LabStage.Caption := '';
  LabProcess.Caption := '';
  LabTerminal.Caption := '';

  if TreePC.Selected.Level <> 3 then Exit;

  LabPDLine.Caption := TreePC.Selected.Parent.Parent.Parent.Text;
  LabStage.Caption := TreePC.Selected.Parent.Parent.Text;
  LabProcess.Caption := TreePC.Selected.Parent.Text;
  LabTerminal.Caption := TreePC.Selected.Text;
end;

function TFormPrint.GetPdLineData(PdLineName: string; var PdLineID: string): Boolean;
var S: string;
begin
  Result := False;
  with ObjDataSet.ObjQryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PDLINE_NAME', ptInput);
    CommandText := 'SELECT PDLINE_ID,PDLINE_NAME ' +
      'FROM SAJET.SYS_PDLINE ' +
      'WHERE PDLINE_NAME = :PDLINE_NAME ';
    Params.ParamByName('PDLINE_NAME').AsString := PdLineName;
    Open;
    if RecordCount > 0 then
    begin
      PdLineID := Fieldbyname('PDLINE_ID').AsString;
    end;
    Close;
  end;

  if PdLineID = '' then
  begin
    S := 'Production Line data Error !! ' + #13#10 +
      'Production Name : ' + PdLineName;
    MessageDlg(S, mtError, [mbCancel], 0);
    Exit;
  end;
  Result := True;
end;

function TFormPrint.GetProcessData(ProcessName: string; var ProcessID: string; var ProcessCode: string; var ProcessDesc: string): Boolean;
var S: string;
begin
  Result := False;
  with ObjDataSet.ObjQryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PROCESS_NAME', ptInput);
    CommandText := 'SELECT PROCESS_ID, PROCESS_CODE, PROCESS_NAME, PROCESS_DESC ' +
      'FROM SAJET.SYS_PROCESS ' +
      'WHERE PROCESS_NAME = :PROCESS_NAME ';
    Params.ParamByName('PROCESS_NAME').AsString := ProcessName;
    Open;
    if RecordCount > 0 then
    begin
      ProcessID := Fieldbyname('PROCESS_ID').AsString;
      ProcessCode := Fieldbyname('PROCESS_CODE').AsString;
      ProcessDesc := Fieldbyname('PROCESS_DESC').AsString;
    end;
    Close;
  end;

  if ProcessID = '' then
  begin
    S := 'Process data Error !! ' + #13#10 +
      'Process Name : ' + ProcessName;
    MessageDlg(S, mtError, [mbCancel], 0);
    Exit;
  end;
  Result := True;
end;

procedure TFormPrint.TreePCGetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := Node.Level;
end;

procedure TFormPrint.btnOKClick(Sender: TObject);
var sPdLineID, sPdLineName: string;
  sProcessID, sProcessName, sProcessCode, sProcessDesc: string;
  sTerminalID, sTerminalName: string;
begin
  if LabTerminal.Caption = '' then
  begin
    MessageDlg('Work Terminal Not Assign !! ', mtError, [mbCancel], 0);
    Exit;
  end;

  sPdLineID := '';
  sPdLineName := LabPdLine.Caption;
  if not GetPdLineData(sPdLineName, sPdLineID) then
    Exit;

  sProcessID := '';
  sProcessName := LabProcess.Caption;
  if not GetProcessData(sProcessName, sProcessID, sProcessCode, sProcessDesc) then
    Exit;

  sTerminalID := '';
  sTerminalName := LabTerminal.Caption;
  if not GetTerminalData(sTerminalName, sPdLineID, sProcessID, sTerminalID) then
    Exit;

  with TIniFile.Create('SAJET.ini') do
  begin
    WriteString('System', 'Factory', FCID);
    WriteString('Print', 'Terminal', sTerminalID);
    Free;
  end;

  TerminalID := sTerminalID;
  MessageDlg('Save OK!', mtInformation, [mbOK], 0);
end;

procedure TFormPrint.InitializeForm;
  function CheckValue(sName, sValue: string): Boolean;
  begin
    with ObjDataSet.ObjQryData do
    begin
      Close;
      Params.Clear;
      CommandText := 'SELECT param_value ' +
        'FROM   SAJET.SYS_BASE ' +
        'WHERE  PARAM_NAME = :sName AND PARAM_VALUE = :sValue ';
      Params.ParamByName('sName').Value := sName;
      Params.ParamByName('sValue').Value := sValue;
      Open;
      Result := not IsEmpty;
      Close;
    end;
  end;
begin
  GetSetStation ;
  //ShowFactory ;
  // Åª¨ú¥»¯¸ ID
  {if not GetTerminalID then
  begin
    ComboSKU.Enabled := False;
    BitBtn1.Enabled := False;
    EditSN.Enabled := False;
    EditCSN.Enabled := False;
    EditUPC.Enabled := False;

    ComboSKUR.Enabled := False;
    BitBtn11.Enabled := False;
    EditGiftBox.Enabled := False;
    EditRtSN.Enabled := False;

    ComboSKUH.Enabled := False;
    BitBtn6.Enabled := False;
    EditHbSN.Enabled := False;

    Exit;
  end;}
  // Åª¨ú Option ­È
  if not GetCfgData then
  begin
    ComboSKU.Enabled := False;
    BitBtn1.Enabled := False;
    EditSN.Enabled := False;
    EditCSN.Enabled := False;
    EditUPC.Enabled := False;

    ComboSKUR.Enabled := False;
    BitBtn11.Enabled := False;
    EditGiftBox.Enabled := False;
    EditRtSN.Enabled := False;

    ComboSKUH.Enabled := False;
    BitBtn6.Enabled := False;
    EditHbSN.Enabled := False;
    
    Exit;
  end;
      
  ComFirstColor.Clear ;
  ComSecondColor.Clear ;
  ComThirdColor.Clear ;
  comForthColor.Clear ;
  ComFifthColor.Clear ;
  with ObjDataSet.ObjQryTemp do
  begin
    ComFirstColor.Items.Add('');
    ComSecondColor.Items.Add('');
    ComThirdColor.Items.Add('');
    comForthColor.Items.Add('');
    ComFifthColor.Items.Add('');
    Close ;
    Params.Clear ;
    CommandText := 'SELECT COLOR_NAME||''(''||COLOR_SPEC||'')'' COLOR_NAME,'+
                ' COLOR_VALUE FROM SAJET.SYS_COLOR WHERE ENABLED = ''Y'' ';
    Open ;
    while not eof do
    begin
      ComFirstColor.Items.Add(FieldValues['COLOR_NAME']);
      ComSecondColor.Items.Add(FieldValues['COLOR_NAME']);
      ComThirdColor.Items.Add(FieldValues['COLOR_NAME']);
      comForthColor.Items.Add(FieldValues['COLOR_NAME']);
      ComFifthColor.Items.Add(FieldValues['COLOR_NAME']);
      Next ;
    end;
    Close ;
  end;

  bNoPopUp := CheckValue('Shipper Label Print', 'NOPOPUP'); // Åª¨ú¬O§_¼u¥X¿ù»~°T®§¹ï¸Ü®Ø
  //AutoClose := CheckValue('PACKING', 'AUTOCLOSE'); // Åª¨ú¬O§_¦Û°ÊÃö³¬´ÌªO»P½c¸¹
  //ShowEmpty := CheckValue('PACKING', 'NOSHOWEMPTY'); // Åª¨ú¬O§_­n¼u¥X Empty XXXXX
  //gbRefreshQty := CheckValue('PACKING REFRESH QTY', 'Y');  //¬O§_¨C¦¸³£­«·s¥ÑDB¬d§ä¤@¦¸¼Æ¶q 2007/7/5

  //gbShowCloseMsg := CheckValue('PACKING', 'SHOWCLOSE');  //ClosePallet«á¥X²{°T®§,¥Ñuser«ö¤UOK«á¤~¥i°Ê§@
  //gbCycle := CheckValue('Packing Pack Spec', 'Cycle');
  //LabPN.Caption := '';
  //LabBoxCap.Caption := '0';
  //LabBoxQty.Caption := '0';
  //LabCartonCap.Caption := '0';
  //LabCartonQty.Caption := '0';
  //LabPalletCap.Caption := '0';
  //LabPalletQty.Caption := '0';
  //editMO.Text := '';

  //editPallet.Text := '';
  //panlMessage.Caption := 'Please Input WO !';
  //ShowMsg('Please Input WO !', '');
  //SetEditStatus('MO');
  // 2007.05.23 Call Dll °µ¨ä¥LÄæ¦ìÀË¬d
  //if g_bAdditional then
  //begin
    //g_tsAddParam:=TStringList.Create;
    //g_tsAddData:=TStringList.Create;
  //end;

  editSN.Text := '';
  editCSN.Text := '';
  EditUPC.Text := '';

  EditGiftBox.Clear ;
  EditRtSN.Clear ;
  EditHbSN.Clear ;
  
  ShowOption ;        //Åã¥Ü³]¸m«H®§
  //GetColorCombo(ComFirstColor );
  //ShowTerminal ;     //Åã¥ÜCongif­¶­±¤¤ªº«H®§
end;

procedure TFormPrint.GetSetStation;
begin
  With TIniFile.Create('SAJET.ini') do
  begin
     FcID := ReadString('System','Factory','');
     TerminalID := ReadString('Print','Terminal','');
     Free;
  end;
end;

procedure TFormPrint.GetSetProcessID;
begin
  with ObjDataSet.ObjQryData do
  begin
    Close ;
    Params.Clear ;
    Params.CreateParam(ftString ,'TerminalID',ptInput );
    CommandText := 'SELECT A.TERMINAL_NAME,B.PROCESS_NAME FROM '+
                   '  SAJET.SYS_TERMINAL A,SAJET.SYS_PROCESS B WHERE '+
                   '     A.TERMINAL_ID=10009032 AND A.PROCESS_ID=B.PROCESS_ID '+
                   '          AND A.ENABLED=''Y'' ';
    Params.ParamByName('TerminalID').AsString :=  TerminalID ;
    Open ;
    if not IsEmpty then
    begin
      //G_sProcessID
    end;
  end;
end;

function TFormPrint.GetTerminalID: Boolean;
begin
  Result := False;
  {with TIniFile.Create('SAJET.ini') do
  begin
    TerminalID := ReadString('Print', 'Terminal', '');
    Free;
  end;}
  if TerminalID = '' then
  begin
    ShowMsg('Terminal not be assign !!', 'ERROR');
    //MessageDlg('Terminal not be assign !!',mtError, [mbCancel],0);
    Exit;
  end;

  with ObjDataSet.ObjQryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'SELECT A.TERMINAL_NAME, B.PROCESS_NAME, C.PDLINE_NAME,A.PROCESS_ID ' +
      ' ,A.PDLINE_ID,A.STAGE_ID '+
      'FROM   SAJET.SYS_TERMINAL A, SAJET.SYS_PROCESS B, SAJET.SYS_PDLINE C ' +
      'WHERE  A.TERMINAL_ID = :TERMINALID ' +
      'AND    A.PROCESS_ID = B.PROCESS_ID ' +
      'AND    A.PDLINE_ID = C.PDLINE_ID ';
    Params.ParamByName('TERMINALID').AsString := TerminalID;
    Open;
    if IsEmpty then
    begin
      Close;
      ShowMsg('Terminal data error !!', 'ERROR');
      //MessageDlg('Terminal data error !!',mtError, [mbCancel],0);
      Exit;
    end;
    //lablLine.Caption := Fieldbyname('PDLINE_NAME').AsString;
    lablLine.Caption := Fieldbyname('PDLINE_NAME').AsString + ' / ' + Fieldbyname('PROCESS_NAME').AsString + ' / ' +
      Fieldbyname('TERMINAL_NAME').AsString;      // LabTerminal
    LablRtLine.Caption := Fieldbyname('PDLINE_NAME').AsString + ' / ' + Fieldbyname('PROCESS_NAME').AsString + ' / ' +
      Fieldbyname('TERMINAL_NAME').AsString;      // LabTerminal
    lablHbLine.Caption := Fieldbyname('PDLINE_NAME').AsString + ' / ' + Fieldbyname('PROCESS_NAME').AsString + ' / ' +
      Fieldbyname('TERMINAL_NAME').AsString;      // LabTerminal
    G_sProcessID:= Fieldbyname('PROCESS_ID').AsString;
    G_sLineID:= Fieldbyname('PDLINE_ID').AsString;
    G_sStageID:= Fieldbyname('STAGE_ID').AsString;
    Close;
  end;
  Result := True;
end;

function TFormPrint.GetCfgData: Boolean;
var sWeightDll,sAdditionalDll: string; bCapsLock: Boolean;   //, sAction
begin
  Result := False;
  chkWeight.Checked := False;
  bCapsLock := False;
  with ObjDataSet.ObjQryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'SELECT * ' +
      'FROM SAJET.SYS_MODULE_PARAM ' +
      'WHERE MODULE_NAME = :MODULE_NAME AND ' +
      'FUNCTION_NAME = :FUNCTION_NAME AND ' +
      'PARAME_NAME = :TERMINALID ';
    Params.ParamByName('MODULE_NAME').AsString := 'Shipper Label Print';
    Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
    Params.ParamByName('TERMINALID').Value := TerminalID;
    Open ;
    if IsEmpty then
    begin
      Close;
      ShowMsg('Configuration not Exist !!', 'ERROR');
      Exit;
    end;

    while not Eof do
    begin
      if Fieldbyname('PARAME_ITEM').AsString = 'Check CSN=SN' then
        CheckCSNeqSN := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if  Fieldbyname('PARAME_ITEM').AsString = 'Customer SN' then
      begin
        AutoCreateCSN := (Fieldbyname('PARAME_VALUE').AsString = 'System Create');
        NotChangeCSN := (Fieldbyname('PARAME_VALUE').AsString = 'Not Change CSN');
      end
      else if  Fieldbyname('PARAME_ITEM').AsString = 'Check Gift Box PN' then
        CheckGiftBoxPN := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if  Fieldbyname('PARAME_ITEM').AsString = 'Print Label' then
        PrintLabel := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if  Fieldbyname('PARAME_ITEM').AsString = 'Label Variable' then
        LabelVariable := Fieldbyname('PARAME_VALUE').AsString
      else if  Fieldbyname('PARAME_ITEM').AsString = 'Each Box Number' then
        mCountPerBox := Fieldbyname('PARAME_VALUE').AsInteger
      else if  Fieldbyname('PARAME_ITEM').AsString = 'Input Error Code' then
        g_bInputEC := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Packing Base' then
        PackingBase := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Check Weight' then
        CheckSNWeight := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Weight Dll' then
        sWeightDll := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_ITEM').AsString = 'Check Product UPC' then
        CheckProductUPC := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Caps Lock' then
        bCapsLock := (Fieldbyname('PARAME_VALUE').AsString = 'Y')
      else if Fieldbyname('PARAME_ITEM').AsString = 'Additional DLL'  then
        sAdditionalDll := Fieldbyname('PARAME_VALUE').AsString
      // 2007/08/27 ¬O§_¥i¿é¤J¤£¨}¥N½X
      else if Fieldbyname('PARAME_ITEM').AsString = 'Input Error Code' then
        g_bInputEC := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      Next;
    end;
    Close;
  end;
  
  if bCapsLock then
  begin
    EditSN.CharCase := ecUpperCase;
    EditUPC.CharCase := ecUpperCase; //EditSN.CharCase;
    editCSN.CharCase := ecUpperCase; //EditSN.CharCase;
    EditGiftBox.CharCase := ecUpperCase; //EditSN.CharCase;
    EditRtSN.CharCase := ecUpperCase; //EditSN.CharCase;
    EditHbSN.CharCase := ecUpperCase; //EditSN.CharCase;
  end;
  if not CheckProductUPC then
     EditUPC.Text := 'N/A';
  Result := True;
end;

function TFormPrint.GetLVcolorData : Boolean ;
var iIndex : Integer ;
begin
  LVData.Items.Clear ;
  Result := false;
  try
    with ObjDataSet.ObjQryData do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString ,'FUN',ptInput);
      Params.CreateParam(ftString ,'TERMINAL_ID',ptInput);
      CommandText := 'SELECT B.COLOR_ID,B.COLOR_NAME,B.COLOR_SPEC,B.COLOR_VALUE, ' +
        ' (A.PARAME_ITEM) COLOR_COUNT,(A.PARAME_VALUE) COLOR_SEQ  ' +
        '   FROM SAJET.SYS_MODULE_PARAM A,SAJET.SYS_COLOR B  ' +
        '     WHERE  A.MODULE_NAME = :FUN AND A.FUNCTION_NAME = :TERMINAL_ID AND ' +
        '        A.PARAME_NAME=B.COLOR_ID AND B.ENABLED=''Y'' AND A.ENABLED=''Y'' '+
        '          ORDER BY COLOR_SEQ ';
      Params.ParamByName('FUN').AsString := 'Shipper Label Print';
      Params.ParamByName('TERMINAL_ID').Value := TerminalID;
      Open ;
      if not IsEmpty then
      begin
        while not eof do
        begin
          with LVData.Items.Add do
          begin
            Caption := Fieldbyname('COLOR_NAME').AsString;
            Subitems.Add(Fieldbyname('COLOR_SPEC').AsString);
            Subitems.Add(Fieldbyname('COLOR_VALUE').AsString);
            Subitems.Add(Fieldbyname('COLOR_COUNT').AsString);
            Subitems.Add(Fieldbyname('COLOR_ID').AsString);
          end;
          Next ;
        end;

        for iIndex := 0 to LVData.Items.Count -1 do
        begin
          //TLabel(Self.FindComponent('LabeColor'+IntToStr(iIndex+1))).Caption := LvData.Items.Item[iIndex].SubItems[2];
          TLabel(Self.FindComponent('LabeColor'+IntToStr(iIndex+1))).Color := StrToColor(LvData.Items.Item[iIndex].SubItems[1]);
        end;

        LoadPicture(StrToInt(LvData.Items.Item[LVCurrentCount].SubItems[3]), ImgPic);
        LabInfo2.Caption := LvData.Items.Item[LVCurrentCount].SubItems[0]+'²£«~' ;

        Result := True ;
      end else
      begin
        ImgPic.Picture := nil;
        ImgPic.Visible := False ;
        Image2.Visible := True ; ;
        MessageDlg(#13+'GetColorData Empty!',mtWarning ,[mbOK],0);
      end;
    end;
  finally
    ObjDataSet.ObjQryData.Close ;
  end;
end;

procedure TFormPrint.SavePicture(ColorName :string;lpImgPic : TImage );
var
  tStream:TMemoryStream;
begin
  try
    tStream := TMemoryStream.Create;  //³Ð«Ø¤º¦s¬y
    lpImgPic.Picture.Graphic.SaveToStream(tStream); //±N¹Ï¤ù«O¦s¨ì¤º¦s¬y¤¤
    with ObjDataSet.ObjQryTemp do
    begin
      Close ;
      Params.Clear ;
      Params.CreateParam(ftString,'COLOR_NAME',ptInput);
      CommandText := 'SELECT COLOR_NAME FROM  SAJET.SYS_COLOR WHERE COLOR_NAME =:COLOR_NAME ';
      Open ;
      if IsEmpty then
      begin
        Close ;
        Params.Clear ;
        Params.CreateParam(ftString,'COLOR_NAME',ptInput);
        Params.CreateParam(ftString,'PIC',ptInput);
        Params.CreateParam(ftString,'EMPID',ptInput);
        CommandText := 'INSERT INTO SAJET.SYS_COLOR (COLOR_NAME,COLOR_PICTURE,UPDATE_USERID) '+
                       ' VALUES (:COLOR_NAME,:PIC,:EMPID) ';
        Params.ParamByName('COLOR_NAME').Value := ColorName ;
        //TBlobField(Parameters.ParamByName('PIC')).LoadFromFile(PicturePath) ;
        Params.ParamByName('PIC').LoadFromStream(tStream,ftBlob);  //Åª¨ú«O¦sªº¤º¦s¹Ï¤ù
        Params.ParamByName('EMPID').Value := ObjGlobal.objUser.uEmpID ;
        Execute ;
        MessageDlg('Color Picture Add Successful!!',mtInformation ,[mbOK],0);
      end else
      begin
        Close ;
        Params.Clear ;
        Params.CreateParam(ftString,'COLOR_NAME',ptInput);
        Params.CreateParam(ftString,'PIC',ptInput);
        CommandText := 'UPDATE SAJET.SYS_COLOR SET COLOR_PICTURE = :PIC WHERE COLOR_NAME =:COLOR_NAME ';
        Params.ParamByName('COLOR_NAME').Value := ColorName ;
        //TBlobField(Parameters.ParamByName('PIC')).LoadFromFile(PicturePath) ;
        Params.ParamByName('PIC').LoadFromStream(tStream,ftBlob);  //Åª¨ú«O¦sªº¤º¦s¹Ï¤ù
        Execute ;
        MessageDlg('Color Picture Update Successful!!',mtInformation ,[mbOK],0);
      end;
      Close ;
    end;
    {Image1.Picture.Graphic.SaveToStream(tStream);                    //±N¹Ï¤ù«O¦s¨ì¤º¦s¬y¤¤
    adoquery1.Close;
    adoquery1.SQL.Clear;
    adoQuery1.SQL.Add('Insert into test (id,photo) values (:id,:photo)');//¼g¤J¨ì¼Æ¾Ú®w
    adoquery1.Parameters.ParamByName('id').Value := '003';
    adoQuery1.Parameters.ParamByName('photo').LoadFromStream(tStream,ftBlob);  //Åª¨ú«O¦sªº¤º¦s¹ÏˆD
    adoquery1.ExecSQL; }
  finally 
    tStream.Free;                                                             //ÄÀ©ñ¤º¦s¬y
  end;
end;

procedure TFormPrint.LoadLabColor(iIndex : Integer ) ;
begin
  TLabel(Self.FindComponent('LabeColor'+IntToStr(iIndex))).Caption :=
    IntToStr(StrToInt(TLabel(Self.FindComponent('LabeColor'+IntToStr(iIndex))).Caption )+1);
end;

procedure TFormPrint.LoadPicture(ColorID : Integer ;lpImgPic : TImage);
var
  mStream : TStringStream;
  JpgFile:TjpegImage;
begin
  with ObjDataSet.ObjQryTemp do
  begin
    Close ;
    Params.Clear ;
    Params.CreateParam(ftString,'COLOR_ID',ptInput);
    CommandText := 'SELECT COLOR_PICTURE FROM SAJET.SYS_COLOR WHERE COLOR_ID = :COLOR_ID AND ROWNUM = 1';
    Params.ParamByName('COLOR_ID').Value := ColorID ;
    Open ;
    if (not isempty) and
      ( not FieldByName('COLOR_PICTURE').IsNull) then
    begin
      mStream := TstringStream.Create('') ;
      JpgFile := TjpegImage.Create ;
      TBlobField(FieldByName('COLOR_PICTURE')).SaveToStream(mStream); //Åã¥ÜªºÂà´«¬°BlobFiled¨Ã«O¦s¨ì¤º¦s¬y
      mStream.Position :=0;
      JpgFile.LoadFromStream(MStream);
      lpImgPic.Picture.Assign(JpgFile);
      mStream.Free ;
      JpgFile.Free ;
      lpImgPic.Visible := True ;
      Image2.Visible := False ; ;
    end else
    begin
      lpImgPic.Picture := nil;
      lpImgPic.Visible := False ;
      Image2.Visible := True ; ;
    end;
    Close ;
  end;
end;

function  TFormPrint.GetFileCreationTime(const   AFileName:   String;   var   ACreateTime:   TDateTime):   Boolean;
var 
    hFile:   THandle;
    Security:   TSecurityAttributes; 
    CreateTime,   LocalTime:   TFILETIME; 
    SystemTime:   TSystemTime; 
begin 
    Security.nLength   :=   SizeOf(TSecurityAttributes); 
    Security.lpSecurityDescriptor   :=   nil; 
    Security.bInheritHandle   :=   False; 
    hFile   :=   CreateFile(PChar(AFileName),GENERIC_READ   ,   1   ,@Security, 
                                            OPEN_EXISTING,   FILE_ATTRIBUTE_NORMAL,   1); 
    if  hFile=INVALID_HANDLE_VALUE   then 
    begin 
        ACreateTime   :=   0; 
        Result   :=   False; 
    end 
    else 
    begin 
        GetFileTime(hFile,   @CreateTime,   nil,   nil); 
        FileTimeToLocalFileTime(CreateTime,   LocalTime); 
        FileTimeToSystemTime(LocalTime,   SystemTime); 
        ACreateTime   :=   SystemTimeToDateTime(SystemTime); 
        Result   :=   True; 
    end; 
end;

procedure TFormPrint.ShowOption;
//var S: string;
begin
  cnkCSN.Checked := False;
  cnkCSN1.Checked := False;
  chkCheckCSN.Checked := False;
  cnkPrintLabel.Checked := False;
  cnkCheckGiftBox.Checked := False;
  {cmbCSNPntMethod.ItemIndex := 0;
  editCSNLabQty.Text := '1';
  cmbCSNPort.ItemIndex := 0;

  cnkBox.Checked := False;
  chkCheckBox.Checked := False;
  cnkBoxLabel.Checked := False;
  cmbBoxPntMethod.ItemIndex := 0;
  editBoxLabQty.Text := '1';
  cmbBoxPort.ItemIndex := 0;

  cnkCarton.Checked := False;
  cnkCartonLabel.Checked := False;
  cmbCartonPntMethod.ItemIndex := 0;
  editCartonLabQty.Text := '1';
  cmbCartonPort.ItemIndex := 0;

  cnkPallet.Checked := False;
  cnkPalletLabel.Checked := False;
  cmbPalletPntMethod.ItemIndex := 0;
  editPalletLabQty.Text := '1';
  cmbPalletPort.ItemIndex := 0;}

  cmbPkBase.ItemIndex := 0;
  cmbVersion.ItemIndex := 2;
  cmbPkAction.ItemIndex := 0;
  cmbRule.ItemIndex := 0;
  ChkAdditional.Checked:= False;
  ChkbInputEC.Checked := False;

  with ObjDataSet.ObjQryData do
  begin
    {Close;
    Parameters.Clear;
    sql.Clear ;
    sql.Text := 'select param_value from sys_base where param_name = ''Packing Action''';
    Open;
    cmbPkAction.Items.Clear;
    slPackAction.Clear;
    S := FieldByName('param_value').AsString;
    while Pos(',', S) <> 0 do begin
      cmbPkAction.Items.Add(Copy(S, 2, Pos(',', S) - 2));
      slPackAction.Add(Copy(S, 1, 1));
      S := Copy(S, Pos(',', S) + 1, Length(S));
    end;
    cmbPkAction.Items.Add(Copy(S, 2, Length(S)));
    slPackAction.Add(Copy(S, 1, 1));}
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'SELECT * ' +
      'FROM SAJET.SYS_MODULE_PARAM ' +
      'WHERE MODULE_NAME = :MODULE_NAME AND ' +
      'FUNCTION_NAME = :FUNCTION_NAME AND ' +
      'PARAME_NAME = :TERMINALID ';
    Params.ParamByName('MODULE_NAME').AsString := 'Shipper Label Print';
    Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
    Params.ParamByName('TERMINALID').AsString := TerminalID;
    Open;
    while not Eof do
    begin
        //Customer SN
      if Fieldbyname('PARAME_ITEM').AsString = 'Customer SN' then
        cnkCSN.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'System Create');
      if Fieldbyname('PARAME_ITEM').AsString = 'Customer SN' then
        cnkCSN1.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Not Change CSN');
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Label' then
        cnkPrintLabel.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Check Gift Box PN' then
        cnkCheckGiftBox.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      {if Fieldbyname('PARAME_ITEM').AsString = 'Print Customer SN Label Method' then
        cmbCSNPntMethod.ItemIndex := cmbCSNPntMethod.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Customer SN Label Qty' then
        editCSNLabQty.Text := Fieldbyname('PARAME_VALUE').AsString;
      if Fieldbyname('PARAME_ITEM').AsString = 'Customer SN COM Port' then
        cmbCSNPort.ItemIndex := cmbCSNPort.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'Check CSN=SN' then
        chkCheckCSN.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');

      
        //Box
      if Fieldbyname('PARAME_ITEM').AsString = 'Box No' then
        cnkBox.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'System Create');
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Box No Label' then
        cnkBoxLabel.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Box No Label Method' then
        cmbBoxPntMethod.ItemIndex := cmbCSNPntMethod.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Box No Label Qty' then
        editBoxLabQty.Text := Fieldbyname('PARAME_VALUE').AsString;
      if Fieldbyname('PARAME_ITEM').AsString = 'Box No COM Port' then
        cmbBoxPort.ItemIndex := cmbCSNPort.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'Check Box=SN' then
        chkCheckBox.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');

        //Carton
      if Fieldbyname('PARAME_ITEM').AsString = 'Carton No' then
        cnkCarton.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'System Create');
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Carton No Label' then
        cnkCartonLabel.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Carton No Label Method' then
        cmbCartonPntMethod.ItemIndex := cmbCartonPntMethod.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Carton No Label Qty' then
        editCartonLabQty.Text := Fieldbyname('PARAME_VALUE').AsString;
      if Fieldbyname('PARAME_ITEM').AsString = 'Carton No COM Port' then
        cmbCartonPort.ItemIndex := cmbCartonPort.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);

        //Pallet
      if Fieldbyname('PARAME_ITEM').AsString = 'Pallet No' then
        cnkPallet.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'System Create');
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Pallet No Label' then
        cnkPalletLabel.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Pallet No Label Method' then
        cmbPalletPntMethod.ItemIndex := cmbPalletPntMethod.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Pallet No Label Qty' then
        editPalletLabQty.Text := Fieldbyname('PARAME_VALUE').AsString;
      if Fieldbyname('PARAME_ITEM').AsString = 'Pallet No COM Port' then
        cmbPalletPort.ItemIndex := cmbPalletPort.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      }

      

      //¥´¦L
      if Fieldbyname('PARAME_ITEM').AsString = 'Label Variable' then
        EditLabelVariable.Text := Fieldbyname('PARAME_VALUE').AsString ;
      if Fieldbyname('PARAME_ITEM').AsString = 'Each Box Number' then
        cmbCountPerBox.ItemIndex := cmbCountPerBox.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString);

      {if Fieldbyname('PARAME_ITEM').AsString = 'Caps Lock' then
        chkCapsLock.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Check Rule by Function' then
        cmbRule.ItemIndex := cmbRule.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString);}

      //¯¯­«  ¬O§_±½´yUPC
      if Fieldbyname('PARAME_ITEM').AsString = 'Check Weight' then
        chkWeight.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      {if Fieldbyname('PARAME_ITEM').AsString = 'Weight Dll' then
        edtDll.Text := Fieldbyname('PARAME_VALUE').AsString;}
      if Fieldbyname('PARAME_ITEM').AsString = 'Check Rule by Function' then
        cmbRule.ItemIndex := cmbRule.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'Check Product UPC' then
        chkProductUPC.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');

      //ªþ¥ó
      if Fieldbyname('PARAME_ITEM').AsString = 'Additional Data' then
        chkAdditional.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Additional DLL' then
        edtAdditionaldll.Text := Fieldbyname('PARAME_VALUE').AsString;

      //¬O§_¤j¼g  ¬O§_¿é¤J¤£¨}¥N½X
      if Fieldbyname('PARAME_ITEM').AsString = 'Caps Lock' then
        chkCapsLock.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Input Error Code' then
        chkbInputEC.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');

      //ÃC¦â³]©w
      if  Fieldbyname('PARAME_ITEM').AsString ='FirstColor' then
        ComFirstColor.ItemIndex := ComFirstColor.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString);
      if  Fieldbyname('PARAME_ITEM').AsString ='SecondColor' then
        ComSecondColor.ItemIndex := ComSecondColor.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString);
      if  Fieldbyname('PARAME_ITEM').AsString ='ThirdColor' then
        ComThirdColor.ItemIndex := ComThirdColor.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString);
      if  Fieldbyname('PARAME_ITEM').AsString ='ForthColor' then
        comForthColor.ItemIndex := comForthColor.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString);
      if  Fieldbyname('PARAME_ITEM').AsString ='FifthColor' then
        ComFifthColor.ItemIndex := ComFifthColor.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString);

      if  Fieldbyname('PARAME_ITEM').AsString ='Color1' then
        ComColor1.ItemIndex := ComColor1.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString);
      if  Fieldbyname('PARAME_ITEM').AsString ='Color2' then
        ComColor2.ItemIndex := ComColor2.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString);
      if  Fieldbyname('PARAME_ITEM').AsString ='Color3' then
        ComColor3.ItemIndex := ComColor3.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString);
      if  Fieldbyname('PARAME_ITEM').AsString ='Color4' then
        ComColor4.ItemIndex := ComColor4.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString);
      if  Fieldbyname('PARAME_ITEM').AsString ='Color5' then
        ComColor5.ItemIndex := ComColor5.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString);

        //ÀË¬d³]©w
      if Fieldbyname('PARAME_ITEM').AsString = 'Packing Base' then
        cmbPkBase.ItemIndex := cmbPkBase.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'CodeSoft' then
        cmbVersion.ItemIndex := cmbVersion.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'Packing Action' then begin
        cmbPkAction.ItemIndex := cmbPkAction.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
        {if cmbPkAction.ItemIndex = -1 then
           cmbPkAction.ItemIndex := cmbPkAction.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);}
      end;

      Next;
    end;
    Close;
  end;

  LabColorInfo.Caption := 'Color1:'+ComColor1.Text +' Color2:'+ComColor2.Text+
                          ' Color3:'+ComColor3.Text+' Color4:'+ComColor4.Text+' Color5:'+ComColor5.Text ;
  if cmbPkAction.ItemIndex = -1 then
    cmbPkAction.ItemIndex := 0;
end;

procedure TFormPrint.FormShow(Sender: TObject);
var
  TRES : string ;
begin
  Self.Left :=Round((Screen.Width -Self.Width)/2);
  Self.Top :=Round((Screen.Height-Self.Height)/2);

  if (UpperCase(ObjGlobal.objUser.uEmpName) ='XIAOBO_YUAN') or
     (UpperCase(ObjGlobal.objUser.uEmpNo) ='H6334') then
  begin
    ButtonTest.Visible := true ;
    //ButtonLocked.Visible := true ;
  end
  else
  begin
    ButtonTest.Visible := false ;
    //ButtonLocked.Visible := false ;
  end;

  //Print ­¶­±¤u¥O«H®§
  LabWO.Caption := FormMain.EditWorkOrder.Text ;
  LabPN.Caption := mPartNo;
  LabQTY.Caption := FormMain.EditBatch.Text ;

  //Retail ­¶­±¤u¥O«H®§
  LabRtWO.Caption := FormMain.EditWorkOrder.Text ;
  LabRtPN.Caption := mPartNo;
  LabRtQTY.Caption := FormMain.EditBatch.Text ;

  //Mingle ­¶­±¤u¥O«H®§
  LabHbWO.Caption := FormMain.EditWorkOrder.Text ;
  LabHbPN.Caption := mPartNo;
  LabHbQTY.Caption := FormMain.EditBatch.Text ;
  
  if ObjGlobal.objDataConnect.ObjConnection.Connected then
    ShapeDB.Brush.Color := clGreen
  else
    ShapeDB.Brush.Color := clRed ;

  mCurrentCount := 1;
  ZeroMemory(@mArrTypeSN,SizeOf(mArrTypeSN));

  //¤U¸ü¹ïÀ³®Æ¸¹ªºLabel¥´¦LÀÉ®×
  DonwLoadLabel( mPartNo, TRES );
  if TRES <> 'OK' then
  begin
    MessageBox(GetActiveWindow ,PChar('ÀË´ú¨ìµ{§Ç¦b°õ¦æ¤¤µo¥Í¿ù»~,½Ð¥ý³B²z¿ù»~!!'+
                   #13+#13+'¿ù»~«H®§: '+TRES),'Error',MB_SYSTEMMODAL+MB_OK+MB_ICONERROR) ;
    if LabelType ='RETAIL' then
    begin
      EditGiftBox.Enabled := False ;
      EditRtSN.Enabled := False ;
      EditGiftBox.Color := clWhite ;
      EditRtSN.Color := clWhite ;
    end else if LabelType ='MINGLE' then
    begin
      EditHbSN.Enabled := False ;
      EditHbSN.Color := clWhite ;
    end else if LabelType = 'SHIPPER' then
    begin
      EditSN.Enabled := False ;
      EditCSN.Enabled := False ;
      EditUPC.Enabled := False ;
      EditSN.Color := clWhite ;
      EditCSN.Color := clWhite ;
      EditUPC.Color := clWhite ;
    end;
  end else
  begin
    if LabelType ='RETAIL' then
    begin
      if CheckGiftBoxPN then
      begin
        SetEditStatus('GIFBOX');
      end else
      begin
        SetEditStatus('RTSN');
      end;
      ShowMsg('SKU Select OK.', '','RT');
    end else if LabelType ='MINGLE' then
    begin
      SetEditStatus('HBSN');
    end else if LabelType = 'SHIPPER' then
    begin
      SetEditStatus('SN');
      ShowMsg('SKU Select OK.', '');
    end
  end;
end;

procedure TFormPrint.DonwLoadLabel(Part_No : string ;var TRES : string);
var
  WeekOfYear : string;
  lpVlues : string;
begin
  TRES := 'OK';
  if CheckSNWeight then
  begin
    GetWeigthLimit(Part_No ,TRES);
    if TRES <> 'OK' then  Exit ;
  end;
  
  if LabelType ='RETAIL' then
  begin
    if CheckGiftBoxPN then
    begin
      GetGifBoxPN(Part_No ,TRES) ;
      if TRES <>'OK' then  Exit ;
    end;
    ShowMsg('SKU Select OK.', '');
  end else if LabelType ='MINGLE' then
  begin
    if not GetLVcolorData then
      Exit
    else
      ShowMsg('SKU Select OK.', '');
  end else if LabelType = 'SHIPPER' then
  begin
    if CheckProductUPC then
    begin
      GetGifBoxPN(Part_No ,TRES) ;
      if TRES <>'OK' then Exit ;
    end;
    //SetEditStatus('SN');
    ShowMsg('SKU Select OK.', '');
  end; 

  //¤U¸üLABELÀÉ®×
  SelectLabelFile( Part_No,TRES);
  if TRES <> 'OK' then Exit ;
  //¿é¤JLabel Lot_No
  if FormSKU <> nil then
  begin
    FormSKU.Close ;
    FreeAndNil(FormSKU);
  end;
  with TFormSKU.Create(nil) do
  begin
    Caption := 'Enter Lot_No' ;
    Label1.Caption := 'Enter Label Lot Number';
    WeekOfYear := FormatDateTime('YY',GetDB_DateTime)+IntToStr(WeekOfTheYear(GetDB_DateTime));
    TBarcode.Text := WeekOfYear ;
    EditWO.Text := Copy(mWO,3,6) ;
    edtDate.Text := FormatDateTime('YYYYMMDD',GetDB_DateTime);

    if UpperCase(File_Type) = '.LBL' then
    begin
      if ExistVariableName('SKU_No',lpVlues)then
        LabelSKUNO := GetLabelValue('SKU_No')   //¨ú®øLabelÀÉ®×¤¤ªºSKU_NO
      else
        LabelSKUNO := 'N/A';

      if LabelType ='RETAIL' then
        edtRTSKUNO.Text := LabelSKUNO
      else if LabelType = 'SHIPPER' then
        edtSKUNO.Text := LabelSKUNO
      else if LabelType ='MINGLE' then
        edtHbSKUNO.Text := LabelSKUNO ;

      if ExistVariableName('LINE',lpVlues)then
      begin
        edtLine.Enabled := true ;
        edtLine.Text := lpVlues ;
      end else
      begin
        edtLine.Enabled := False ;
        edtLine.Text := 'N/A';
      end;
      if ExistVariableName('DATE',lpVlues)then
      begin
        edtDate.Text := FormatDateTime('YYYYMMDD',Now) ;
        edtDate.Enabled := True ;
      end else
      begin
        edtDate.Enabled := false ;
        edtDate.Text := 'N/A';
      end;
      if ExistVariableName('EIPN',lpVlues)then
      begin
        edtEIPN.Enabled := true ;
        edtEIPN.Text := lpVlues ;
      end else
      begin
        edtEIPN.Enabled := false ;
        edtEIPN.Text := 'N/A';
      end;

      if ShowModal = mrok then
      begin
        if ExistVariableName('Lot_No',lpVlues)then
        begin
          if not SetLabelValue('Lot_No',Lot_No ) then
          begin
            MessageDlg('¼g¤JLot No¥¢±Ñ',mtError ,[mbOK],0);
            Exit ;
          end;
        end ;
        if ExistVariableName('WO',lpVlues)then
        begin
          if not SetLabelValue('WO',Label_WO) then     //Copy(mWO,3,6)
          begin
            MessageDlg('¼g¤JWO¥¢±Ñ',mtError ,[mbOK],0);
            Exit ;
          end;
        end ;
        if ExistVariableName('LINE',lpVlues)then
        begin
          if not SetLabelValue('LINE',edtLine.Text) then
          begin
            MessageDlg('¼g¤JLine¥¢±Ñ',mtError ,[mbOK],0);
            Exit ;
          end;
        end;
        if ExistVariableName('DATE',lpVlues)then
        begin
          if not SetLabelValue('DATE',edtDate.Text) then
          begin
            MessageDlg('¼g¤J¤é´Á¥¢±Ñ',mtError ,[mbOK],0);
            Exit ;
          end;
        end;
        if ExistVariableName('EIPN',lpVlues)then
        begin
          if not SetLabelValue('EIPN',edtEIPN.Text) then
          begin
            MessageDlg('¼g¤JEIPN¥¢±Ñ',mtError ,[mbOK],0);
            Exit ;
          end;
        end ;
        LabelDocApply ;
        TRES := 'OK';
      end else
      begin
        TRES := 'Label Lot No ¿é¤J¿ù»~!' ;
      end;
    end
    else if UpperCase(File_Type) ='.LAB' then
    begin
      m_CodeSoft.AcquirePrintData('SKU_No',LabelSKUNO);  //¨úªºLabelÀÉ®×¤¤ªºSKU_NO
      if LabelType ='RETAIL' then
        edtRTSKUNO.Text := LabelSKUNO
      else if LabelType = 'SHIPPER' then
        edtSKUNO.Text := LabelSKUNO
      else if LabelType ='MINGLE' then
        edtHbSKUNO.Text := LabelSKUNO ;

      m_CodeSoft.AcquirePrintData('LINE',lpVlues);
      edtLine.Text := lpVlues ;
      m_CodeSoft.AcquirePrintData('EIPN',lpVlues);
      edtEIPN.Text := lpVlues ;

      if ShowModal = mrok then
      begin
        m_CodeSoft.AssignDataImmediate('Lot_No',Lot_No) ;
        m_CodeSoft.AssignDataImmediate('WO',Label_WO) ;
        m_CodeSoft.AssignDataImmediate('LINE',edtLine.Text) ;
        m_CodeSoft.AssignDataImmediate('DATE',edtDate.Text) ;
        m_CodeSoft.AssignDataImmediate('EIPN',edtEIPN.Text) ;
        TRES := 'OK';
      end else
      begin
        TRES := 'Label Lot No ¿é¤J¿ù»~!' ;
      end;
    end;
    Close ;
    Free ;
  end;
end;

procedure TFormPrint.tsPrintShow(Sender: TObject);
begin
  if (not FormMain.chkRetailLabel.Checked )and
     (not FormMain.chkMinglePack.Checked )then
  begin
    // Åª¨ú¥»¯¸ ID
    if not GetTerminalID then
    begin
      ComboSKU.Enabled := False;
      BitBtn1.Enabled := False;
      EditSN.Enabled := False;
      EditCSN.Enabled := False;
      EditUPC.Enabled := False;
      Exit;
    end;
    // Åª¨ú Option ­È
    if not GetCfgData then
    begin
      ComboSKU.Enabled := False;
      BitBtn1.Enabled := False;
      EditSN.Enabled := False;
      EditCSN.Enabled := False;
      EditUPC.Enabled := False;
      Exit;
    end; 
    {if ComboSKU.Enabled then
    begin
      SetEditStatus('SKU') ;
      ShowMsg('Please Select SKU !', '');
    end
    else if EditSN.Enabled then
      SetEditStatus('SN')
    else if EditCSN.Enabled then
      SetEditStatus('CSN')
    else if EditUPC.Enabled then
      SetEditStatus('UPC');}
  end;
end;

procedure TFormPrint.tsErieShow(Sender: TObject);
begin
  if (not FormMain.chkRetailLabel.Checked )and
     ( FormMain.chkMinglePack.Checked )then
  begin
    // Åª¨ú¥»¯¸ ID
    if not GetTerminalID then
    begin
      ComboSKUH.Enabled := False;
      BitBtn6.Enabled := False;
      EditHbSN.Enabled := False;
      Exit;
    end;
    // Åª¨ú Option ­È
    if not GetCfgData then
    begin
      ComboSKUH.Enabled := False;
      BitBtn6.Enabled := False;
      EditHbSN.Enabled := False;
      Exit;
    end;
    if ComboSKUH.Enabled then
      SetEditStatus('SKUH')
    else if EditHbSN.Enabled then
      SetEditStatus('HBSN') ;
    //GetLVcolorData ;
    //LoadPicture(StrToInt(LvData.Items.Item[0].Caption), ImgPic);
  end;
end;

procedure TFormPrint.tsRetailShow(Sender: TObject);
begin
  if ( FormMain.chkRetailLabel.Checked )and
     (not FormMain.chkMinglePack.Checked )then
  begin
    // Åª¨ú¥»¯¸ ID
    if not GetTerminalID then
    begin
      ComboSKU.Enabled := False;
      BitBtn11.Enabled := False;
      EditGiftBox.Enabled := False;
      EditHbSN.Enabled := False;
      Exit;
    end;
    // Åª¨ú Option ­È
    if not GetCfgData then
    begin
      ComboSKU.Enabled := False;
      BitBtn11.Enabled := False;
      EditGiftBox.Enabled := False;
      EditHbSN.Enabled := False;
      Exit;
    end;

    if ComboSKUR.Enabled then
    begin
      SetEditStatus('SKUR') ;
      ShowMsg('Please Select SKU !', '','RT');
    end
    else if EditGiftBox.Enabled then
    begin
      SetEditStatus('GIFBOX') ;
    end
    else if EditRtSN.Enabled then
    begin
      SetEditStatus('RTSN');
    end;
  end;
end;

procedure TFormPrint.sbtnSaveClick(Sender: TObject);
begin
  if TerminalID = '' then begin
    MessageDlg('Terminal not be assign.', mtError, [mbOK], 0);
    Exit;
  end;
  if SaveCfgData then
    MessageDlg('Save OK!', mtInformation, [mbOK], 0);
end;

function TFormPrint.SaveCfgData: Boolean;
var S : string;  
  procedure SavetoDB(ParamName, ParamItem, ParamValue: string;FUN : string = 'Work Station Configuration');
  begin
    with ObjDataSet.ObjQryTemp do
    begin
      Params.ParamByName('MODULE_NAME').AsString := 'Shipper Label Print';
      Params.ParamByName('FUNCTION_NAME').AsString := FUN ;//'Work Station Configuration';
      Params.ParamByName('PARAME_NAME').AsString := ParamName;
      Params.ParamByName('PARAME_ITEM').AsString := ParamItem;
      Params.ParamByName('PARAME_VALUE').AsString := ParamValue;
      Params.ParamByName('UPDATE_USERID').AsString := ObjGlobal.objUser.uEmpID;
      Execute;
    end;
  end;
begin
  with ObjDataSet.ObjQryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'Delete SAJET.SYS_MODULE_PARAM ' +
      'Where MODULE_NAME = :MODULE_NAME and ' +
      'FUNCTION_NAME = :FUNCTION_NAME  and ' +
      'PARAME_NAME = :TERMINALID ';
    Params.ParamByName('MODULE_NAME').AsString := 'Shipper Label Print';
    Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
    Params.ParamByName('TERMINALID').AsString := TerminalID;
    Execute;

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'Delete SAJET.SYS_MODULE_PARAM ' +
      'Where MODULE_NAME = :MODULE_NAME and ' +
      'FUNCTION_NAME = :TERMINALID  ';
    Params.ParamByName('MODULE_NAME').AsString := 'Shipper Label Print';
    Params.ParamByName('TERMINALID').AsString := TerminalID;
    Execute;
  end;

  with ObjDataSet.ObjQryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'PARAME_NAME', ptInput);
    Params.CreateParam(ftString, 'PARAME_ITEM', ptInput);
    Params.CreateParam(ftString, 'PARAME_VALUE', ptInput);
    Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
    CommandText := 'Insert Into SAJET.SYS_MODULE_PARAM ' +
      '(MODULE_NAME,FUNCTION_NAME,PARAME_NAME,PARAME_ITEM,PARAME_VALUE,UPDATE_USERID )' +
      'Values (:MODULE_NAME,:FUNCTION_NAME,:PARAME_NAME,:PARAME_ITEM,:PARAME_VALUE,:UPDATE_USERID) ';
  end;

  //Customer SN
  S := 'Input';
  if cnkCSN.Checked then
    S := 'System Create'         //System Create
  else if chkCheckCSN.Checked then
    SavetoDB(TerminalID, 'Check CSN=SN', 'Y')
  else
    SavetoDB(TerminalID, 'Check CSN=SN', 'N');
  if cnkCSN1.Checked then S := 'Not Change CSN';
  SavetoDB(TerminalID, 'Customer SN', S);

  if cnkPrintLabel.Checked then
    SavetoDB(TerminalID ,'Print Label','Y')
  else
    SavetoDB(TerminalID ,'Print Label','N');

  if cnkCheckGiftBox.Checked then               //Check Gift Box PN
    SavetoDB(TerminalID ,'Check Gift Box PN','Y')
  else
    SavetoDB(TerminalID ,'Check Gift Box PN','N');

  SavetoDB(TerminalID, 'Packing Base', cmbPkBase.Text);
  SavetoDB(TerminalID, 'CodeSoft', cmbVersion.Text);
  //SavetoDB(TerminalID, 'Packing Action', slPackAction[cmbPkAction.ItemIndex]);

  //¥´¦L
  SavetoDB(TerminalID, 'Label Variable', EditLabelVariable.Text );
  SavetoDB(TerminalID, 'Each Box Number', cmbCountPerBox.Text);

  //¯¯­«
  S := 'Y';
  if not chkWeight.Checked then S := 'N';
  SavetoDB(TerminalID, 'Check Weight', S);
  //SavetoDB(TerminalID, 'Weight Dll', edtDll.Text);

  //±½´yUPC
  S := 'Y';
  if not chkProductUPC.Checked then S := 'N';
  SavetoDB(TerminalID, 'Check Product UPC', S);

  //ªþ¥ó
  S := 'Y';
  if not chkAdditional.Checked then S := 'N';
  SavetoDB(TerminalID, 'Additional Data', S);
  SavetoDB(TerminalID, 'Additional DLL', edtAdditionaldll.Text);

  //¬O§_¥i¿é¤J¤£¨}¥N½X
  if chkbInputEC.Checked then
     SavetoDB(TerminalID, 'Input Error Code', 'Y')
  else
     SavetoDB(TerminalID, 'Input Error Code', 'N');

  //¬O§_¤j¤p¼g
  if chkCapsLock.Checked then
    SavetoDB(TerminalID, 'Caps Lock', 'Y')
  else
    SavetoDB(TerminalID, 'Caps Lock', 'N');
    
  //¼g¤JÃC¦â³]©w
  IF (ComFirstColor.Text <> '') and (ComFirstColor.ItemIndex >=0 ) then
  begin
    SavetoDB(TerminalID, 'FirstColor', ComFirstColor.Text );
    SavetoDB(GetColorID(LeftStr(ComFirstColor.Text,Pos('(',ComFirstColor.Text)-1)),ComColor1.Text,'1',TerminalID) ;
  end;
  IF (ComSecondColor.Text <> '') and (ComSecondColor.ItemIndex >=0 ) then
  begin
    SavetoDB(TerminalID, 'SecondColor',ComSecondColor.Text );
    SavetoDB(GetColorID(LeftStr(ComSecondColor.Text,Pos('(',ComSecondColor.Text)-1)),ComColor2.Text,'2',TerminalID) ;
  end;
  IF (ComThirdColor.Text <> '') and (ComThirdColor.ItemIndex >=0 ) then
  begin
    SavetoDB(TerminalID, 'ThirdColor',ComThirdColor.Text );
    SavetoDB(GetColorID(LeftStr(ComThirdColor.Text,Pos('(',ComThirdColor.Text)-1)),ComColor3.Text,'3',TerminalID) ;
  end;
  IF (comForthColor.Text <> '') and (comForthColor.ItemIndex >=0 ) then
  begin
    SavetoDB(TerminalID, 'ForthColor',comForthColor.Text );
    SavetoDB(GetColorID(LeftStr(comForthColor.Text,Pos('(',comForthColor.Text)-1)),ComColor4.Text,'4',TerminalID) ;
  end;
  IF (ComFifthColor.Text <> '') and (ComFifthColor.ItemIndex >=0 ) then
  begin
    SavetoDB(TerminalID, 'FifthColor',ComFifthColor.Text );
    SavetoDB(GetColorID(LeftStr(ComFifthColor.Text,Pos('(',ComFifthColor.Text)-1)),ComColor5.Text,'5',TerminalID) ;
  end;
  IF (ComColor1.Text <> '0') and (ComColor1.ItemIndex >=0 ) then
    SavetoDB(TerminalID, 'Color1',ComColor1.Text );
  IF (ComColor2.Text <> '0') and (ComColor2.ItemIndex >=0 ) then
    SavetoDB(TerminalID, 'Color2',ComColor2.Text );
  IF (ComColor3.Text <> '0') and (ComColor3.ItemIndex >=0 ) then
    SavetoDB(TerminalID, 'Color3',ComColor3.Text );
  IF (ComColor4.Text <> '0') and (ComColor4.ItemIndex >=0 ) then
    SavetoDB(TerminalID, 'Color4',ComColor4.Text );
  IF (ComColor5.Text <> '0') and (ComColor5.ItemIndex >=0 ) then
    SavetoDB(TerminalID, 'Color5',ComColor5.Text );

  LabColorInfo.Caption := 'Color1:'+ComColor1.Text +' Color2:'+ComColor2.Text+
                          ' Color3:'+ComColor3.Text+' Color4:'+ComColor4.Text+' Color5:'+ComColor5.Text ;  
  Result := True;
end;

function TFormPrint.GetColorID(Color_Name : string) : string ;
begin
  if Color_Name ='' then
  begin
    Result := '0' ;
    Exit ;
  end;
  with ObjDataSet.ObjQryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'COLOR_NAME', ptInput);
    CommandText := 'SELECT COLOR_ID FROM SAJET.SYS_COLOR ' +
      '   WHERE COLOR_NAME = :COLOR_NAME AND ROWNUM = 1 ';
    Params.ParamByName('COLOR_NAME').AsString := Color_Name;
    Open ;
    if not IsEmpty then
      Result := FieldByName('COLOR_ID').AsString
    else
      Result := '0';
    Close;
  end;
end;

procedure TFormPrint.EditSNKeyPress(Sender: TObject; var Key: Char);
var TRES : string; I : Integer ;
begin
  if Key =#13 then
  begin
    Key := #0;
    panlMessage.Caption := '';
    if Trim(editSN.Text) ='' then
    begin
        ShowMsg('SN±ø½X¤£¯à¬°ªÅ,½Ð­«·s±½´y!','ERROR');
        SetEditStatus('SN');
        Exit ;
    end;

    if UpperCase(editSN.Text)='UNDO' then
    begin
      mCurrentCount := 1;
      LVCurrentCount := 0 ;
      ZeroMemory(@mArrTypeSN,SizeOf(mArrTypeSN));
      lablErrorCode.Caption:='';
      editCSN.Text := '';
      SetEditStatus('SN');
      ShowMsg('UNDO OK','');
      Exit;
    end;

    for i := 1 to mCurrentCount do
    begin
      if EditSN.Text = mArrTypeSN[i-1] then
      begin
        ShowMsg('DUP SN!','ERROR');
        SetEditStatus('SN');
        Exit ;
      end;
    end;

    {if not CheckSNRange (SNNO) then
    begin
      ShowMsg('SN¤£¦b°Ï¶¡½d³ò¤º!','ERROR');
      SetEditStatus('SN');
      Exit ;
    end;}

    IF not CheckPDlineStatus(TerminalID) THEN EXIT ;
    //=======================================================
    if not CheckSN then
    begin
      SetEditStatus('SN');
      Exit;
    end;

    if CheckSNWeight then
    begin
      CheckWeigthSN(mWO,SNNO,Weight_Count,TRES);
      if TRES <> 'OK' then
      begin
        ShowMsg(TRES,'ERROR');
        SetEditStatus('SN');
        Exit ;
      end;
    end;

    if PrintLabel then
      mArrTypeSN[mCurrentCount-1] := Trim(EditSN.Text) ;

    if AutoCreateCSN then
    begin
      EditCSN.Text := 'N/A' ;
    end
    else if NotChangeCSN then
    begin
      editCSN.Text := CSNNo;
    end
    else
    begin
      SetEditStatus('CSN');
      Exit ;
    end;

    if not CheckProductUPC then
    begin
      if mCurrentCount >= mCountPerBox then
      begin
        Inc(mCurrentCount);
        LabelCount.Caption := IntToStr(mCurrentCount-1)+'/' + IntToStr(mCountPerBox);
        if UpperCase(File_Type)='.LBL' then
        begin
          //Print Label   ¥ý¥´¦L¼ÐÅÒ«á¦A¶i¨t²Î
          if CheckForFQC.Checked then
          begin
            LvPrintLabel(mArrTypeSN,mCurrentCount,TRES,2 );
            CheckForFQC.Checked := False ;
          end else
          begin
            LvPrintLabel(mArrTypeSN,mCurrentCount,TRES);
          end;

          if TRES <> 'OK' then
          begin
            ShowMsg(TRES, 'ERROR');
            Exit;
          end;
        end else if UpperCase(File_Type)='.LAB' then
        begin
          for i := 1 to mCurrentCount do
          begin
            if mArrTypeSN[i-1] <> '' then
            begin
              //Delay(10);
              m_CodeSoft.AssignPrintData(LabelVariable + IntToStr(i),mArrTypeSN[i-1]);
              if PrintType = 'Shipper_Pack' then
                Self.Memo1.Lines.Add(mArrTypeSN[i-1])
              else if PrintType = 'Mingle_Pack' then
                Self.Memo3.Lines.Add(mArrTypeSN[i-1]);
            end;
          end;
          if CheckForFQC.Checked then
          begin
            m_CodeSoft.Print(2);
            CheckForFQC.Checked := False ;
          end else
          begin
            m_CodeSoft.Print(1);
          end;
          if PrintType = 'Shipper_Pack' then
            Self.Memo1.Lines.Add('******************************')
          else if PrintType = 'Mingle_Pack' then
            Self.Memo3.Lines.Add('******************************');
        end;
        if (ObjGlobal.objUser.uEmpID <> '10000001') and
           (ObjGlobal.objUser.uEmpName <> 'Xiaobo Yuan') then
        begin
          //SN¹L¯¸
          for i := 1 to mCurrentCount do
          begin
            if mArrTypeSN[i-1] <> '' then
            begin
              SJ_DB_PRINT_GO(TerminalID,mArrTypeSN[i-1],ObjGlobal.objUser.uEmpNo,TRES );
              if TRES <> 'OK' then
              begin
                ShowMsg(TRES, 'ERROR');
                Exit;
              end;
              Delay(20);
            end;
          end;
        end;
        mCurrentCount := 1 ;
        ZeroMemory(@mArrTypeSN,SizeOf(mArrTypeSN));
      end else Inc(mCurrentCount);
      ShowMsg('SN OK !', '');
      SetEditStatus('SN');
      //LabelCount.Caption := IntToStr(StrToInt(LabelCount.Caption)+1);
      LabelCount.Caption := IntToStr(mCurrentCount-1)+'/' + IntToStr(mCountPerBox);
    end else
    begin
      ShowMsg('SN OK !', '');
      SetEditStatus('UPC');
    end;
  end;
end;

function TFormPrint.CheckPDlineStatus(TTerminalID:string):Boolean;
var sres:string;
begin
  result:=false;
  with ObjDataSet.ObjProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CKRT_PDLINE_STATUS');
      FetchParams;
      Params.ParamByName('TTERMINALID').AsString := TTerminalID;
      Execute;
      sRes := Params.ParamByName('TRES').AsString;
    except
    end;
    Close;
  end;

  if sRes <> 'OK' then
  begin
    ShowMsg(sRes, 'ERROR');
    Exit;
  end;
  Result := True;
end;

function TFormPrint.CheckSN: Boolean;
var sRes : string ;//,Start_Process_ID,Route_ID: string;
begin
  Result := False;
  //begin-----------------------Bell_Shuai-----------------20100723---------------
  with  ObjDataSet.ObjQryTemp do     //ÀË¬d¬O§_»Ý­n³]©w¥]¸Ë¬°§ë¤J¯¸
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString,'Serial_NUMBER',ptInput);
    CommandText := 'select * from sajet.G_SN_STATUS Where '+
                   ' Serial_NUmber =:Serial_number or '+
                   '   customer_SN=:Serial_number ';
    Params.ParamByName('Serial_NUMBER').AsString := EditSN.Text;
    Open;
  end;

  if not ObjDataSet.ObjQryTemp.IsEmpty then
  begin
    with ObjDataSet.ObjProc do
    begin
      try
        Close;
        DataRequest('SAJET.SJ_CKRT_SN_PSN');
        FetchParams;
        Params.ParamByName('TREV').AsString := EditSN.Text;
        Execute;
        sRes := Params.ParamByName('TRES').AsString;
        SNNO := Params.ParamByName('PSN').AsString;
      except
        on E: Exception do
        begin
          sRes := 'SJ_CKRT_SN_PSN Exception' + #13#10 + E.Message;
        end;
      end;
      Close;
    end;

    if sRes <> 'OK' then
    begin
      ShowMsg(sRes,'ERROR');
      Exit ;
    end;

    if UpperCase(Trim(SNNO)) = UpperCase(Trim(EditSN.Text)) then
    begin
      ShowMsg('Must be Customer_SN!!','ERROR');
      Exit ;
    end;

    with ObjDataSet.ObjQryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
      CommandText := 'SELECT A.WORK_ORDER, A.WORK_FLAG, A.MODEL_ID '
        + '     , A.CUSTOMER_SN, A.SERIAL_NUMBER, B.PART_NO '
        + '     , NVL(A.PALLET_NO,''N/A'') PALLET_NO,NVL(A.CARTON_NO,''N/A'') CARTON_NO '
        + '     ,NVL(A.BOX_NO,''N/A'') BOX_NO '
        + 'FROM   SAJET.G_SN_STATUS A '
        + '     , SAJET.SYS_PART B '
        + 'WHERE  A.SERIAL_NUMBER = :SERIAL_NUMBER '
        + 'AND    A.MODEL_ID = B.PART_ID(+) and rownum = 1 ';  // rownum 2006.11.13 add
      Params.ParamByName('SERIAL_NUMBER').AsString := SNNO;
      Open;
     { if IsEmpty then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'CUSTOMER_SN', ptInput);
        CommandText := 'SELECT A.WORK_ORDER, A.WORK_FLAG, A.MODEL_ID '
          + '     , A.CUSTOMER_SN, A.SERIAL_NUMBER, B.PART_NO '
          + '     , NVL(A.PALLET_NO,''N/A'') PALLET_NO,NVL(A.CARTON_NO,''N/A'') CARTON_NO '
          + '     ,NVL(A.BOX_NO,''N/A'') BOX_NO '
          + 'FROM   SAJET.G_SN_STATUS A '
          + '     , SAJET.SYS_PART B '
          + 'WHERE  A.CUSTOMER_SN = :CUSTOMER_SN '
          + 'AND    A.MODEL_ID = B.PART_ID(+) and rownum = 1'; // rownum 2006.11.13 add
        Params.ParamByName('CUSTOMER_SN').AsString := editSN.Text;
        Open;
        if IsEmpty then
        begin
          Close;
          ShowMsg('Serial Number not found!!', 'ERROR');
          Exit;
        end;
      end;
      if Fieldbyname('WORK_FLAG').AsString = '1' then
      begin
        Close;
        ShowMsg('Serial Number Srcap.', 'ERROR');
        Exit;
      end;  }

      if PackingBase = 'Work Order' then
      begin
        if mWO <> '' then
        begin
          if mWO <> Fieldbyname('WORK_ORDER').AsString then
          begin
            ShowMsg('Work Order is Different!!' + #13#10 + Fieldbyname('WORK_ORDER').AsString, 'ERROR');
            Close;
            Exit;
          end;
        end;
      end
      else
      begin
        if mPartNo <> '' then
        begin
          if mPartNo <> Fieldbyname('PART_NO').AsString then
          begin
            ShowMsg('Model is Different!!' + #13#10 + Fieldbyname('PART_NO').AsString, 'ERROR');
            Close;
            Exit;
          end;
        end;
      end;

      SNNO := Fieldbyname('SERIAL_NUMBER').AsString;
      CSNNo := Fieldbyname('CUSTOMER_SN').AsString;
      Close;
    end;

    // Check Route
    with ObjDataSet.ObjProc do
    begin
      try
        Close;
        DataRequest('SAJET.SJ_CKRT_ROUTE');
        FetchParams;
        Params.ParamByName('TERMINALID').AsString := TerminalID;
        Params.ParamByName('TSN').AsString := SNNO;
        Execute;
        sRes := Params.ParamByName('TRES').AsString;
      except
        on  E: Exception do
        begin
          sRes := 'SJ_CKRT_ROUTE Exception' + #13#10 + E.Message;
        end;
      end;
      Close;
    end;

    if sRes <> 'OK' then
    begin
      ShowMsg('Route Error: ' + sRes, 'ERROR');
      Exit;
    end;
    Result := True;
  end
  else
  begin
    with ObjDataSet.ObjProc do
    begin
      DataRequest('SAJET.BELL_PACKING_Input');
      FetchParams;
      Params.ParamByName('tterminalid').AsString := TerminalID;
      Params.ParamByName('tWO').AsString := mWO;
      Params.ParamByName('tsn').AsString := EditSN.Text;
      Params.ParamByName('tempid').AsString := ObjGlobal.objUser.uEmpID ;
      Execute;

      if Params.ParamByName('Tres').AsString ='OK' then
      begin
        Result := True;
      end
      else
      begin
        Result := false;
        MessageDlg(Params.ParamByName('Tres').AsString,mtError,[mbOK],0);
        editSN.SelectALL;
        editSN.SetFocus;
        Abort;
      end
    end;
    //gsPallet :='N/A';
    //gsCarton :='N/A';
    //gsBox :='N/A';
    //CSNNo :='N/A';
    //SNNO :=editSN.Text;
    //listSN.Items.Clear;
    //listSN.Items.Add(SNNO);
  end;
end;

function TFormPrint.CheckRtSN(TTSN : string): Boolean;
var sRes : string ; //,Start_Process_ID,Route_ID: string;
begin
  Result := False;
  //begin-----------------------Bell_Shuai-----------------20100723---------------
  with  ObjDataSet.ObjQryTemp do     //ÀË¬d¬O§_»Ý­n³]©w¥]¸Ë¬°§ë¤J¯¸
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString,'Serial_NUMBER',ptInput);
    CommandText := 'select * from sajet.G_SN_STATUS Where '+
                   ' Serial_NUmber =:Serial_number or '+
                   '   customer_SN=:Serial_number ';
    Params.ParamByName('Serial_NUMBER').AsString := TTSN;
    Open;
  end;

  if not ObjDataSet.ObjQryTemp.IsEmpty then
  begin
    with ObjDataSet.ObjProc do
    begin
      try
        Close;
        DataRequest('SAJET.SJ_CKRT_SN_PSN');
        FetchParams;
        Params.ParamByName('TREV').AsString := TTSN;
        Execute;
        sRes := Params.ParamByName('TRES').AsString;
        SNNO := Params.ParamByName('PSN').AsString;
      except
        on E: Exception do
        begin
          sRes := 'SJ_CKRT_SN_PSN Exception' + #13#10 + E.Message;
        end;
      end;

      if sRes <> 'OK' then
      begin
        ShowMsg(sRes,'ERROR');
        Exit ;
      end;

      if UpperCase(Trim(SNNO)) = UpperCase(Trim(TTSN)) then
      begin
        ShowMsg('Must be Customer_SN!!','ERROR');
        Exit ;
      end;

      //ÀË¬dSN±ø½X¬OHOLD
      Close;
      DataRequest('SAJET.SJ_CKRT_SN');
      FetchParams;
      Params.ParamByName('TREV').AsString := SNNO;
      Execute;
      sRes :=  Params.ParamByName('TRES').AsString ;
      Close;
      if sRes <>'OK' then
      begin
        ShowMsg(sRes,'ERROR');
        exit;
      end;
    end;

    with ObjDataSet.ObjQryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
      CommandText := 'SELECT A.WORK_ORDER, A.WORK_FLAG, A.MODEL_ID '
        + '     , A.CUSTOMER_SN, A.SERIAL_NUMBER, B.PART_NO '
        + '     , NVL(A.PALLET_NO,''N/A'') PALLET_NO,NVL(A.CARTON_NO,''N/A'') CARTON_NO '
        + '     ,NVL(A.BOX_NO,''N/A'') BOX_NO '
        + 'FROM   SAJET.G_SN_STATUS A '
        + '     , SAJET.SYS_PART B '
        + 'WHERE  A.SERIAL_NUMBER = :SERIAL_NUMBER '
        + 'AND    A.MODEL_ID = B.PART_ID(+) and rownum = 1 ';  // rownum 2006.11.13 add
      Params.ParamByName('SERIAL_NUMBER').AsString := SNNO;
      Open;
      if PackingBase = 'Work Order' then
      begin
        if mWO <> '' then
        begin
          if mWO <> Fieldbyname('WORK_ORDER').AsString then
          begin
            ShowMsg('Work Order is Different!!' + #13#10 + Fieldbyname('WORK_ORDER').AsString, 'ERROR');
            Close;
            Exit;
          end;
        end;
      end
      else
      begin
        if mPartNo <> '' then
        begin
          if mPartNo <> Fieldbyname('PART_NO').AsString then
          begin
            ShowMsg('Model is Different!!' + #13#10 + Fieldbyname('PART_NO').AsString, 'ERROR');
            Close;
            Exit;
          end;
        end;
      end;
      SNNO := Fieldbyname('SERIAL_NUMBER').AsString;
      CSNNo := Fieldbyname('CUSTOMER_SN').AsString;
      Close;
    end;

    // Check Route
    with ObjDataSet.ObjProc do
    begin
      try
        Close;
        DataRequest('SAJET.SJ_CKRT_ROUTE');
        FetchParams;
        Params.ParamByName('TERMINALID').AsString := TerminalID;
        Params.ParamByName('TSN').AsString := SNNO;
        Execute;
        sRes := Params.ParamByName('TRES').AsString;
      except
        on  E: Exception do
        begin
          sRes := 'SJ_CKRT_ROUTE Exception' + #13#10 + E.Message;
        end;
      end;
      Close;
    end;

    if sRes <> 'OK' then
    begin
      ShowMsg('Route Error: ' + sRes, 'ERROR');
      Exit;
    end;
    Result := True;
  end
  else
  begin
    with ObjDataSet.ObjProc do
    begin
      Close;
      DataRequest('SAJET.BELL_PACKING_Input');
      FetchParams;
      Params.ParamByName('tterminalid').AsString := TerminalID;
      Params.ParamByName('tWO').AsString := mWO;
      Params.ParamByName('tsn').AsString := TTSN;
      Params.ParamByName('tempid').AsString := ObjGlobal.objUser.uEmpID ;
      Execute;

      if Params.ParamByName('Tres').AsString ='OK' then
      begin
        Result := True;
      end
      else
      begin
        Result := false;
        MessageDlg(Params.ParamByName('Tres').AsString,mtError,[mbOK],0);
        //EditRtSN.SelectALL;
        //EditRtSN.SetFocus;
        //Abort;
      end
    end;
  end;
end;

function TFormPrint.CheckSNRange(TSN : string ) : Boolean ;
{var
  i : Integer ;
  startsn,endsn : string ;}
BEGIN
  {for i := 0 to ListStartSN.Count -1 do
  begin
    startsn := ListStartSN.Items.Strings[i] ;
    endsn := ListEndSN.Items.Strings[i];
    //if TSN in [startsn..endsn] then
    //begin
      //Result := True  ;
      //Break ;
    //end;
    if (TSN>=startsn) and (TSN<=endsn) then
    begin
      Result := True ;
      Break ;
    end
    else
    begin
      Result := False;
    end;
  end;}
end;

procedure TFormPrint.EditUPCKeyPress(Sender: TObject; var Key: Char);
var sRes : string; i : Integer ;
begin
  if Key = #13 then
  begin
    Key := #0 ;
    panlMessage.Caption := '';
    if Trim(EditUPC.Text) ='' then
    begin
      ShowMsg('UPC±ø½X¤£¯à¬°ªÅ,½Ð­«·s±½´y!','ERROR');
      SetEditStatus('UPC');
      Exit ;
    end;

    if ListUPC.Items.Strings[0] <> Trim(EditUPC.Text) then
    begin
      ShowMsg('UPC ERROR!','ERROR');
      SetEditStatus('UPC');
      Exit ;
    end;

    if mCurrentCount >= mCountPerBox then
    begin
      if UpperCase(File_Type)='.LBL' then
      begin
        //Print Label   ¥ý¥´¦L¼ÐÅÒ«á¦A¶i¨t²Î
        if CheckForFQC.Checked then
        begin
          LvPrintLabel(mArrTypeSN,mCurrentCount,sRes,2 );
          CheckForFQC.Checked := False ;
        end else
        begin
          LvPrintLabel(mArrTypeSN,mCurrentCount,sRes);
        end;

        if sRes <> 'OK' then
        begin
          ShowMsg(sRes, 'ERROR');
          Exit;
        end;
      end else if UpperCase(File_Type)='.LAB' then
      begin
        for i := 1 to mCurrentCount do
        begin
          if mArrTypeSN[i-1] <> '' then
          begin
            //Delay(10);
            m_CodeSoft.AssignPrintData(LabelVariable + IntToStr(i),mArrTypeSN[i-1]);
            if PrintType = 'Shipper_Pack' then
              Self.Memo1.Lines.Add(mArrTypeSN[i-1])
            else if PrintType = 'Mingle_Pack' then
              Self.Memo3.Lines.Add(mArrTypeSN[i-1]);
          end;
        end;
        if CheckForFQC.Checked then
        begin
          m_CodeSoft.Print(2);
          CheckForFQC.Checked := False ;
        end else
        begin
          m_CodeSoft.Print(1);
        end;
        if PrintType = 'Shipper_Pack' then
          Self.Memo1.Lines.Add('******************************')
        else if PrintType = 'Mingle_Pack' then
          Self.Memo3.Lines.Add('******************************');
      end;

      if (ObjGlobal.objUser.uEmpID <> '10000001') and
         (ObjGlobal.objUser.uEmpName <> 'Xiaobo Yuan') then
      begin
        //SN¹L¯¸
        for i := 1 to mCurrentCount do
        begin
          if mArrTypeSN[i-1] <> '' then
          begin
            SJ_DB_PRINT_GO(TerminalID,mArrTypeSN[i-1],ObjGlobal.objUser.uEmpNo,sRes );
            if sRes <> 'OK' then
            begin
              ShowMsg(sRes, 'ERROR');
              Exit;
            end;
            Delay(20);
          end;
        end;
      end;

      mCurrentCount := 1 ;
      ZeroMemory(@mArrTypeSN,SizeOf(mArrTypeSN));
      //SetLength(mArrTypeSN,mCountPerBox );
    end else Inc(mCurrentCount);
    ShowMsg('UPC OK !', '');
    SetEditStatus('SN');
    //LabelCount.Caption := IntToStr(StrToInt(LabelCount.Caption)+1);
    LabelCount.Caption := IntToStr(mCurrentCount-1)+'/' + IntToStr(mCountPerBox);
  end;
end;

procedure TFormPrint.cnkPrintLabelClick(Sender: TObject);
begin
  if cnkPrintLabel.Enabled then
  begin
    if cnkPrintLabel.Checked then
    begin
      EditLabelVariable.Enabled := True ;
      EditLabelVariable.Color := clYellow ;
      cmbCountPerBox.Enabled := true;
    end else
    begin
      EditLabelVariable.Enabled := False ;
      EditLabelVariable.Color := clWhite ;
      cmbCountPerBox.Enabled := False;
    end;
  end;
end;

procedure TFormPrint.chkCheckCSNClick(Sender: TObject);
begin
  IF chkCheckCSN.Checked  then
  begin
    cnkCSN.Checked := False ;
    cnkCSN1.Checked := False ;
  end;
end;

{function TFormPrint.CheckDupCSN: Boolean;
begin
  Result := False;
  CSNNo := '';
  with ObjSQLQuery do
  begin
    Close;
    Parameters.Clear;
    sql.Text := 'SELECT TOP 1 SERIAL_NUMBER ' +
      'FROM G_SN_STATUS ' +
      'WHERE CUSTOMER_SN = :CSN ';  // rownum 2006.11.13 add
    Parameters.ParseSQL(SQL.Text ,True );
    Parameters.ParamByName('CSN').Value := editCSN.Text;
    Open;
    if not IsEmpty then
    begin
      Close;
      ShowMsg('Customer SN Duplicate !!', 'ERROR');
       //MessageDlg('Customer SN Duplicate !!',mtError, [mbCancel],0);
      Exit;
    end;
    Close;
  end;
  CSNNo := editCSN.Text;
  Result := True;
end; }

function TFormPrint.CheckDupCSN: Boolean;
begin
  Result := False;
  CSNNo := '';
  with ObjDataSet.ObjQryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CSN', ptInput);
    CommandText := 'SELECT SERIAL_NUMBER ' +
      'FROM SAJET.G_SN_STATUS ' +
      'WHERE CUSTOMER_SN = :CSN and rownum = 1';  // rownum 2006.11.13 add
    Params.ParamByName('CSN').AsString := EditCSN.Text;
    Open;
    if not IsEmpty then
    begin
      Close;
      ShowMsg('Customer SN Duplicate !!', 'ERROR');
       //MessageDlg('Customer SN Duplicate !!',mtError, [mbCancel],0);
      Exit;
    end;
    Close;
  end;
  CSNNo := EditCSN.Text;
  Result := True;
end;

procedure TFormPrint.SetEditStatus(Kind: string);
begin
  //pirnt
  ComboSKU.Enabled := False;
  EditSN.Enabled := False;
  EditCSN.Enabled := False;
  EditUPC.Enabled := False;
  //retail
  ComboSKUR.Enabled := False;
  EditGiftBox.Enabled := False;
  EditRtSN.Enabled := False;
  // Hybrid Packaging
  ComboSKUH.Enabled := False;
  EditHbSN.Enabled := False;

  ComboSKU.Color := clWhite;
  EditSN.Color := clWhite;
  EditCSN.Color := clWhite;
  EditUPC.Color := clWhite;

  ComboSKUR.Color := clWhite;
  EditGiftBox.Color := clWhite;
  EditRtSN.Color := clWhite;

  ComboSKUH.Color := clWhite;
  EditHbSN.Color := clWhite;

  if Kind = 'SKU' then
  begin
    try
    ComboSKU.Enabled := True;
    ComboSKU.Color := clYellow;
    ComboSKU.SetFocus;
    ComboSKU.SelectAll;
    ComboSKU.ItemIndex := -1 ;
    except
      //Continue ;
    end;
  end
  else if Kind = 'SN' then
  begin
    try
    editSN.Enabled := True;
    editSN.Color := clYellow;
    editSN.SetFocus;
    editSN.SelectAll;
    except
      //Continue ;
    end;
    {if gSN <> '' then
    begin
      editSN.Text := gSN;
      gSN := '';
      sKey := #13;
      editSNKeyPress(Self, sKey);
    end;}
  end
  else if Kind = 'CSN' then
  begin
    try
    editCSN.Enabled := True;
    editCSN.Color := clYellow;
    editCSN.SetFocus;
    editCSN.SelectAll;
    except
      //Continue ;
    end;
  end
  else if Kind = 'UPC' then
  begin
    try
    EditUPC.Enabled := True;
    EditUPC.Color := clYellow;
    EditUPC.SetFocus;
    EditUPC.SelectAll;
    except
      //Continue ;
    end;
  end;

  if Kind = 'SKUR' then
  begin
    try
    ComboSKUR.Enabled := True;
    ComboSKUR.Color := clYellow;
    ComboSKUR.SetFocus;
    ComboSKUR.SelectAll;
    ComboSKUR.ItemIndex := -1 ;
    except
      //Continue ;
    end;
  end
  else if Kind = 'GIFBOX' then
  begin
    try
    EditGiftBox.Enabled := True;
    EditGiftBox.Color := clYellow;
    EditGiftBox.SetFocus;
    EditGiftBox.SelectAll;
    except
      //Continue ;
    end;
  end
  else if Kind = 'RTSN' then
  begin
    try
    EditRtSN.Enabled := True;
    EditRtSN.Color := clYellow;
    EditRtSN.SetFocus;
    EditRtSN.SelectAll;
    except
      //Continue ;
    end;
  end;

  if Kind = 'SKUH' then
  begin
    try
    ComboSKUH.Enabled := True;
    ComboSKUH.Color := clYellow;
    ComboSKUH.SetFocus;
    ComboSKUH.SelectAll;
    ComboSKUH.ItemIndex := -1 ;
    except
      //Continue ;
    end;
  end
  else if Kind = 'HBSN' then
  begin
    try
    EditHbSN.Enabled := True;
    EditHbSN.Color := clYellow;
    EditHbSN.SetFocus;
    EditHbSN.SelectAll;
    except
      //Continue ;
    end;
  end;
end;

procedure TFormPrint.EditCSNKeyPress(Sender: TObject; var Key: Char);
var
  TRES : string;
  i : Integer ;
begin
  if Key =#13 then
  begin
    Key := #0 ;
    if trim(editCSN.Text) = '' then
    begin
      ShowMsg('Please Input Customer SN !!', 'ERROR');
      SetEditStatus('CSN');
      exit;
    end;

    if CheckCSNeqSN then // 2007.05.23 ¥ýÀË¬d¬O§_­n¬Ûµ¥
    begin
      if editCSN.Text <> editSN.Text then
      begin
        ShowMsg('Customer SN <> Serial Number!', 'ERROR');
        SetEditStatus('CSN');
        Exit;
      end;
    end ;

    if not CheckDupCSN then
    begin
      SetEditStatus('CSN');
      Exit;
    end;

    {if not CheckSNRange(editCSN.Text) then
    begin
      ShowMsg('SN¤£¦b°Ï¶¡½d³ò¤º!','ERROR');
      SetEditStatus('SN');
      Exit ;
    end;}
    
    CSNNo := editCSN.Text;
    if not CheckProductUPC then
    begin
      if mCurrentCount >= mCountPerBox then
      begin
        //Print Label   ¥ý¥´¦L¼ÐÅÒ«á¦A¶i¨t²Î
        if CheckForFQC.Checked then
        begin
          LvPrintLabel(mArrTypeSN,mCurrentCount,TRES,2 );
          CheckForFQC.Checked := False ;
        end else
        begin
          LvPrintLabel(mArrTypeSN,mCurrentCount,TRES);
        end;

        if TRES <> 'OK' then
        begin
          ShowMsg(TRES, 'ERROR');
          Exit;
        end;

        //SN¹L¯¸
        for i := 1 to mCurrentCount do
        begin
          if mArrTypeSN[i-1] <> '' then
          begin
            SJ_DB_PRINT_GO(TerminalID,mArrTypeSN[i-1],ObjGlobal.objUser.uEmpNo,TRES );
            if TRES <> 'OK' then
            begin
              ShowMsg(TRES, 'ERROR');
              Exit;
            end;
            Delay(20);
          end;
        end;

        mCurrentCount := 1 ;
        ZeroMemory(@mArrTypeSN,SizeOf(mArrTypeSN));
      end else Inc(mCurrentCount);
      ShowMsg('SN OK !', '');
      SetEditStatus('SN');
      LabelCount.Caption := IntToStr(StrToInt(LabelCount.Caption)+1);
    end else
    begin
      ShowMsg('CSN OK !', '');
      SetEditStatus('UPC');
    end;    
  end;
end;

procedure TFormPrint.cnkCSN1Click(Sender: TObject);
begin
  if cnkCSN1.Checked then
  begin
    cnkCSN.Checked := False;
    chkCheckCSN.Checked := False;
  end;
end;

procedure TFormPrint.cnkCSNClick(Sender: TObject);
begin
  if cnkCSN.Checked then
  begin
    cnkCSN1.Checked := False;
    chkCheckCSN.Checked := False;
  end;
end;

procedure TFormPrint.lblColorVauleClick(Sender: TObject);
begin
  IF dlgColor.Execute then
  begin
    lblColorVaule.Color := dlgColor.Color ;
    lblColorVaule.Caption := ColorToString(dlgColor.Color);
  end;
end;

procedure TFormPrint.ComboSKU_NoDropDown(Sender: TObject);
begin
  ComboSKU_No.Clear ;
  ComboGIFPN.Clear ;
  ComboUPC.Clear ;
  with ObjDataSet.ObjQryTemp do
  begin
    Close ;
    Params.Clear ;
    CommandText := 'SELECT SKU_NO,Gift_Box_PN,UPC_NO FROM SAJET.SYS_PART_GIFT_BOX_PN WHERE ENABLED = ''Y'' ';
    Open ;
    while not eof do
    begin
      ComboSKU_No.Items.Add(FieldByName('SKU_NO').AsString);     //FieldValues['SKU_NO']
      ComboGIFPN.Items.Add(FieldByName('Gift_Box_PN').AsString); //FieldValues['Gift_Box_PN']
      ComboUPC.Items.Add(FieldByName('UPC_NO').AsString);  //FieldValues['UPC_NO']
      Next ;
    end;
    Close ;
  end;
end;

procedure TFormPrint.ComboSKU_NoChange(Sender: TObject);
begin
  ComboGIFPN.ItemIndex := ComboSKU_No.ItemIndex ;
  ComboUPC.ItemIndex := ComboSKU_No.ItemIndex ;
  EditmGifBoxPN.Text := ComboGIFPN.Text ;
  EditmUPC.Text := ComboUPC.Text ;
end;

procedure TFormPrint.Button3Click(Sender: TObject);
begin
  if ComboSKU_No.Text = '' then Exit ;
  if (EditmGifBoxPN.Text ='') and (EditmUPC.Text = '') then Exit ;

  with ObjDataSet.ObjQryTemp do
  begin
    Close ;
    Params.Clear ;
    Params.CreateParam(ftString,'SKU',ptInput);
    CommandText := 'SELECT SKU_NO FROM SAJET.SYS_PART_GIFT_BOX_PN WHERE SKU_NO = :SKU AND ROWNUM = 1 ';
    Params.ParamByName('SKU').Value := ComboSKU_No.Text ;
    Open ;
    IF IsEmpty then
    begin
      if MessageDlg('SKU does not exist, whether to new increased?',
         mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        Close ;
        Params.Clear ;
        Params.CreateParam(ftString,'SKU',ptInput);
        Params.CreateParam(ftString,'Gift_Box_PN',ptInput);
        Params.CreateParam(ftString,'UPC_NO',ptInput);
        Params.CreateParam(ftString,'EMP_ID',ptInput);
        CommandText := 'INSERT INTO SAJET.SYS_PART_GIFT_BOX_PN(SKU_NO,Gift_Box_PN,UPC_NO,UPDATE_USERID)  ' +
                       '  VALUES (:SKU_NO,:Gift_Box_PN,:UPC_NO,:EMP_ID) ' ;
        Params.ParamByName('SKU_NO').Value := ComboSKU_No.Text ;
        Params.ParamByName('Gift_Box_PN').Value := EditmGifBoxPN.Text ;
        Params.ParamByName('UPC_NO').Value := EditmUPC.Text ;
        Params.ParamByName('EMP_ID').Value := ObjGlobal.objUser.uEmpID ;
        Execute ;

        MessageDlg('Increased Successfully',mtConfirmation, [mbOK],0);
      end;
    end else
    begin
      Close ;
      Params.Clear ;
      Params.CreateParam(ftString,'SKU',ptInput);
      Params.CreateParam(ftString,'Gift_Box_PN',ptInput);
      Params.CreateParam(ftString,'UPC_NO',ptInput);
      Params.CreateParam(ftString,'EMP_ID',ptInput);
      CommandText := 'UPDATE SAJET.SYS_PART_GIFT_BOX_PN SET Gift_Box_PN=:Gift_Box_PN,'+
                     '  UPC_NO = :UPC_NO,UPDATE_USERID = :EMP_ID  WHERE SKU_NO=:SKU_NO ';
      Params.ParamByName('SKU_NO').Value := ComboSKU_No.Text ;
      Params.ParamByName('Gift_Box_PN').Value := EditmGifBoxPN.Text ;
      Params.ParamByName('UPC_NO').Value := EditmUPC.Text ;
      Params.ParamByName('EMP_ID').Value := ObjGlobal.objUser.uEmpID ;
      Execute ;

      MessageDlg('Update Successfully',mtConfirmation, [mbOK],0);
    end;
    Close ;
    EditmGifBoxPN.Clear ;
    EditmUPC.Clear ;
    ComboSKU_No.Text := '';
  end;
end;

procedure TFormPrint.CheckWeigthSN(TWO,TSN : string;WeigthCount : Integer ;var TRES : string );
var
  TempWeidght : string ;
begin
  //ÀË¬dSNºÙ­«¦¸¼Æ
  with ObjDataSet.ObjQryTemp do
  begin
    Close ;
    Params.Clear ;
    Params.CreateParam(ftString,'WO',ptInput);
    Params.CreateParam(ftString,'TSN',ptInput);
    CommandText := 'SELECT  COUNT(SERIAL_NUMBER) WEIGHT_COUNT FROM SAJET.G_SN_WEIGHT  ' +
                   '   WHERE WORK_ORDER =:WO AND SERIAL_NUMBER = :TSN '  ;
    Params.ParamByName('WO').Value := TWO ;
    Params.ParamByName('TSN').Value := TSN ;
    Open ;
    if not IsEmpty then
    begin
      if FieldValues['WEIGHT_COUNT'] >= WeigthCount then
      begin
        Close ;
        TRES := '¦¹²£«~ªººÙ­«¦¸¼Æ¤j©ó³]©wºÙ­«¦¸¼Æ';
        Exit ;
      end;
    end;
    Close ;
  end;

  //Åã¥ÜºÙ­«µe­±
  TempWeidght := '';
  WeightForm.Show ;  //Modal
  WeightForm.Timer1.Enabled := true ;
  if Wait_Time <> 0 then
    Delay(Round(Wait_Time*1000));

  WeightResult := Trim(WeightForm.lblReadKG.Caption) ;
  WeightForm.Close ;
  TempWeidght := WeightResult ;

  if Pos('³q«H¥¢±Ñ',TempWeidght) >0 then
  begin
    TRES := '¹q¤l¯¯³q«H¥¢±Ñ,½ÐÀË¬d!';
    Exit ;
  end else if Pos('´ú¶q¥¢±Ñ',TempWeidght) >0 then
  begin
    TRES := '¨ú±o¹q¤l¯¯­«¶q¥¢±Ñ,½ÐÀË¬d!';
    Exit ;
  end;

  {if Pos(TempWeidght,'g') > 0 then
  begin
    TempWeidght := Copy(TempWeidght,1,Pos(TempWeidght,'g')-1);
  end;}
  TempWeidght := Copy(TempWeidght,1,Length(TempWeidght)-1);

  if (StrToFloat(TempWeidght) >= Low_Limit ) and
     (StrToFloat(TempWeidght) <= Up_Limit) then
  begin
    DB_Weigth_GO(TWO,TSN,StrToInt(TerminalID),TempWeidght,'PASS',TRES);
  end else
  begin
    DB_Weigth_GO(TWO,TSN,StrToInt(TerminalID),TempWeidght,'FAIL',TRES);
    if TRES <> 'OK' then Exit ;
    TRES := '²£«~­«¶q¤£¦X®æ!';
  end ;
end;

procedure TFormPrint.DB_Weigth_GO(TWO,TSN : string; TTerminalID : Integer ;WEIGHT,CUSTATUS : string ;var TRES : string);
var
  clineid,pshiftid,cstageid,cprocessid,cmodelid : Integer ;
begin
  with ObjDataSet.ObjProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_GET_PLACE');
      FetchParams;
      Params.ParamByName('tterminalid').AsInteger := TTerminalID;
      Execute;
      clineid := Params.ParamByName('pline').AsInteger ;
      cstageid := Params.ParamByName('pstage').AsInteger ;
      cprocessid := Params.ParamByName('pprocess').AsInteger ;
      TRES := 'OK';
    except
      on E: Exception do
      begin
        TRES := 'SJ_GET_PLACE Exception' + #13#10 + E.Message;
        Exit ;
      end;
    end;

    Close;
    try
      Close;
      DataRequest('SAJET.SJ_GET_PDLINE_SHIFT');
      FetchParams;
      Params.ParamByName('tlineid').AsInteger := clineid;
      Execute;
      pshiftid := Params.ParamByName('pshiftid').AsInteger ;
      TRES := 'OK';
    except
      on E: Exception do
      begin
        TRES := 'SJ_GET_PDLINE_SHIFT Exception' + #13#10 + E.Message;
        Exit ;
      end;
    end;
    Close;
  end;

  if TRES <> 'OK' then Exit ;
  with ObjDataSet.ObjQryData do
  begin
    Close ;
    Params.Clear ;
    Params.CreateParam(ftString,'TSN',ptInput);
    Params.CreateParam(ftString,'TWO',ptInput);
    CommandText := 'select b.work_order,b.model_id,in_pdline_time,out_pdline_time '
                 + '  from sajet.g_sn_status b where b.work_order = :TWO and '
                 + '    b.serial_number = :TSN and rownum = 1 ';
    Params.ParamByName('TSN').AsString := TSN ;
    Params.ParamByName('TWO').AsString := TWO ;
    Open ;
    if not IsEmpty then
    begin
      cmodelid := FieldByName('model_id').AsInteger ;
      Close ;
    end else
    begin
      Close ;
      TRES := 'Invalid Serial_Number!!';
      Exit ;
    end;

    try
      Close ;
      Params.Clear ;
      Params.CreateParam(ftString ,'TWO',ptInput);
      Params.CreateParam(ftString ,'TSN',ptInput);
      Params.CreateParam(ftString ,'MODEL_ID',ptInput);
      Params.CreateParam(ftString ,'PDLINE_ID',ptInput);
      Params.CreateParam(ftString ,'STAGE_ID',ptInput);
      Params.CreateParam(ftString ,'PROCESS_ID',ptInput);
      Params.CreateParam(ftString ,'TERMINAL_ID',ptInput);
      Params.CreateParam(ftString ,'SHIFT_ID',ptInput);
      Params.CreateParam(ftString ,'WEIGHT',ptInput);
      Params.CreateParam(ftString ,'CURRENT_STATUS',ptInput);
      Params.CreateParam(ftString ,'UPDATE_USERID',ptInput);
      CommandText := 'INSERT INTO SAJET.G_SN_WEIGHT (WORK_ORDER,SERIAL_NUMBER,MODEL_ID,PDLINE_ID,STAGE_ID,'
                   + '  PROCESS_ID,TERMINAL_ID,SHIFT_ID,WEIGHT,CURRENT_STATUS,UPDATE_USERID) VALUES ('
                   + '    :TWO,:TSN,:MODEL_ID,:PDLINE_ID,:STAGE_ID,:PROCESS_ID,:TERMINAL_ID,:SHIFT_ID,'
                   + '      :WEIGHT,:CURRENT_STATUS,:UPDATE_USERID)';
      Params.ParamByName('TWO').AsString := TWO ;
      Params.ParamByName('TSN').AsString := TSN ;
      Params.ParamByName('MODEL_ID').AsInteger := cmodelid ;
      Params.ParamByName('PDLINE_ID').AsInteger := clineid ;
      Params.ParamByName('STAGE_ID').AsInteger := cstageid ;
      Params.ParamByName('PROCESS_ID').AsInteger := cprocessid ;
      Params.ParamByName('TERMINAL_ID').AsInteger := TTerminalID ;
      Params.ParamByName('SHIFT_ID').AsInteger := pshiftid ;
      Params.ParamByName('WEIGHT').AsString := WEIGHT ;
      Params.ParamByName('CURRENT_STATUS').AsString := CUSTATUS ;
      Params.ParamByName('UPDATE_USERID').AsString := ObjGlobal.objUser.uEmpID ;
      Execute ;
      TRES := 'OK';
    except
      on E : Exception  do
      begin
        TRES :='SJ_DB_Weigth_GO Error: '+ E.Message ;
      end;
    end;
  end;
end;

procedure TFormPrint.EditGiftBoxKeyPress(Sender: TObject; var Key: Char);
begin
  if Key =#13 then
  begin
    Key := #0 ;
    panlMessageRT.Caption := '';
    if Trim(EditGiftBox.Text) ='' then
    begin
      ShowMsg('GifBox±ø½X¤£¯à¬°ªÅ,½Ð­«·s±½´y!','ERROR','RT');
      SetEditStatus('GIFBOX');
      Exit ;
    end;

    if ListGifBoxPN.Items.Strings[0] <> Trim(EditGiftBox.Text) then
    begin
      ShowMsg('GifBox ERROR!','ERROR','RT');
      SetEditStatus('GIFBOX');
      Exit ;
    end;

    ShowMsg('GifBox OK !', '','RT');
    SetEditStatus('RTSN');
  end;
end;

procedure TFormPrint.EditRtSNKeyPress(Sender: TObject; var Key: Char);
var sRes : string ;
  LvPrintDlg, LvPrintHWND, LvCloseHWND : THandle ;
begin
  if Key =#13 then
  begin
    Key := #0;
    panlMessageRT.Caption := '';
    if Trim(EditRtSN.Text) ='' then
    begin
        ShowMsg('SN±ø½X¤£¯à¬°ªÅ,½Ð­«·s±½´y!','ERROR','RT');
        SetEditStatus('RTSN');
        Exit ;
    end;

    if UpperCase(EditRtSN.Text)='UNDO' then
    begin
      mCurrentCount := 1;
      LVCurrentCount := 0 ;
      ZeroMemory(@mArrTypeSN,SizeOf(mArrTypeSN));
      lablErrorCode.Caption:='';
      EditRtSN.Text := '';
      SetEditStatus('GIFBOX');
      ShowMsg('UNDO OK','','RT');
      Exit;
    end;

    {if not CheckSNRange(EditRtSN.Text) then
    begin
      ShowMsg('SN¤£¦b°Ï¶¡½d³ò¤º!','ERROR');
      SetEditStatus('RTSN');
      Exit ;
    end;}

    IF NOT CheckPDlineStatus(TerminalID) THEN EXIT ;
    //=======================================================
    if not CheckRtSN(EditRtSN.Text) then
    begin
      SetEditStatus('RTSN');
      Exit;
    end;
    
    if PrintLabel then
    begin
      if UpperCase(File_Type)='.LBL' then
      begin
        SetLabelValue(LabelVariable,Trim(EditRtSN.Text)) ;    //³]¸m¥´¦L¤º®e      CSNNo
        //®ÄÅçµo°e¤º®e¬O§_¥¿½T
        if Trim(GetLabelValue(LabelVariable)) <> Trim(EditRtSN.Text) then    //  CSNNo
        begin
          ShowMsg('¥´¦L¤º®e®ÄÅç¥¢±Ñ!', 'ERROR','RT');
          Exit;
        end;
        //LabelDocApply ;

        if LabelDoc <> nil then
        begin
          if CheckRtForFQC.Checked then
            //LabelDoc.PrintLabel(2, 0, 0, 0, 0, 0, 0) //¥´¦L¡A¼Æ¶q¬°1
            LVMenuPrint(TreeView1,2)
          else
            //LabelDoc.PrintLabel(1, 0, 0, 0, 0, 0, 0); //¥´¦L¡A¼Æ¶q¬°1
            LVMenuPrint(TreeView1);
        end;
      end else if UpperCase(File_Type) ='.LAB' then
      begin
        //m_CodeSoft.AssignPrintData(LabelVariable,Trim(EditRtSN.Text)) ;
        m_CodeSoft.AssignDataImmediate(LabelVariable,Trim(EditRtSN.Text));
        if CheckRtForFQC.Checked then
        begin
          //m_CodeSoft.Print(2) ;
          m_CodeSoft.PrintLabel(2);
          CheckRtForFQC.Checked := False ;
        end
        else
          m_CodeSoft.PrintLabel(1) ;
          //m_CodeSoft.Print(1);
      end;
      Memo2.Lines.Add(SNNO);
      Memo2.Lines.Add(EditRtSN.Text);
      Memo2.Lines.Add('******************************');
    end;

    //¥ý¥´¦L,¥´¦LOK«á¦A¹L¯¸
    if (ObjGlobal.objUser.uEmpID <> '10000001') and
       (ObjGlobal.objUser.uEmpName <> 'Xiaobo Yuan') then
    begin
      SJ_DB_PRINT_GO(TerminalID,SNNO,ObjGlobal.objUser.uEmpNo,sRes );
      if sRes <> 'OK' then
      begin
        ShowMsg(sRes, 'ERROR','RT');
        Exit;
      end;
    end;
    
    ShowMsg('SN OK !', '','RT');
    if CheckGiftBoxPN then
      SetEditStatus('GIFBOX')
    else
      SetEditStatus('RTSN');
    LabelRtCount.Caption := IntToStr(StrToInt(LabelRtCount.Caption)+1);
    //LabelRtCount.Caption := IntToStr(mCurrentCount)+'/' + IntToStr(mCountPerBox);
  end;
end;

procedure TFormPrint.ZeroColorLabel ;
begin
  LabeColor1.Caption := '0';
  LabeColor2.Caption := '0';
  LabeColor3.Caption := '0';
  LabeColor4.Caption := '0';
  LabeColor5.Caption := '0';
end;

procedure TFormPrint.EditHbSNKeyPress(Sender: TObject; var Key: Char);
var  sRes : string ; i : Integer ;
begin
  if Key =#13 then
  begin
    Key := #0;
    //panlMessageRT.Caption := '';
    if Trim(EditHbSN.Text) ='' then
    begin
        //ShowMsg('SN±ø½X¤£¯à¬°ªÅ,½Ð­«·s±½´y!','ERROR','RT');
        MessageBox(GetActiveWindow ,'SN±ø½X¤£¯à¬°ªÅ,½Ð­«·s±½´y!','Error',MB_OK+MB_ICONERROR) ;
        SetEditStatus('RTSN');
        Exit ;
    end;

    if UpperCase(EditHbSN.Text)='UNDO' then
    begin
      mCurrentCount := 1;
      LVCurrentCount := 0 ;
      ZeroMemory(@mArrTypeSN,SizeOf(mArrTypeSN));
      //lablErrorCode.Caption:='';
      EditRtSN.Text := '';
      SetEditStatus('HBSN');
      MessageBox(GetActiveWindow ,'UNDO OK','Error',MB_OK+MB_ICONERROR) ;
      Exit;
    end;

    for i := 1 to mCurrentCount do
    begin
      if EditRtSN.Text = mArrTypeSN[i-1] then
      begin
        //ShowMsg('DUP SN!','ERROR','RT');
        MessageBox(GetActiveWindow ,'DUP SN!','Error',MB_OK+MB_ICONERROR) ;
        SetEditStatus('RTSN');
        Exit ;
      end;
    end;

    {if not CheckSNRange(EditRtSN.Text) then
    begin
      ShowMsg('SN¤£¦b°Ï¶¡½d³ò¤º!','ERROR');
      SetEditStatus('RTSN');
      Exit ;
    end;}

    IF NOT checkpdlinestatus(TerminalID) THEN EXIT ;
    //=======================================================
    if not CheckRtSN(EditHbSN.Text) then
    begin
      //MessageBox(GetActiveWindow ,PChar(TRES),'Error',MB_OK+MB_ICONERROR) ;
      SetEditStatus('HBSN');
      Exit;
    end;

    if CheckSNWeight then
    begin
      CheckWeigthSN(mWO,SNNO,Weight_Count,sRes);
      if sRes <> 'OK' then
      begin
        //ShowMsg(sRes,'ERROR','');
        MessageBox(GetActiveWindow ,PChar(sRes),'Error',MB_OK+MB_ICONERROR) ;
        SetEditStatus('SN');
        Exit ;
      end;
    end;

    for i :=0 to LVData.Items.Count -1 do
    begin
      case i of
        0 :
          if mCurrentCount <= StrToInt(LVData.Items.Item[i].SubItems[2]) then
          begin
            LoadLabColor(1);
            if mCurrentCount = StrToInt(LVData.Items.Item[i].SubItems[2]) then
            begin
              if i = (LVData.Items.Count -1) then
              begin
                LVCurrentCount := 0 ;
                ZeroColorLabel ; end else
              LVCurrentCount := i + 1;
              Break ;
            end;
            LVCurrentCount := i ;
            Break ;
          end;
        1 :
          if mCurrentCount <=(StrToInt(LVData.Items.Item[0].SubItems[2])+
                              StrToInt(LVData.Items.Item[1].SubItems[2])) then
          begin
            LoadLabColor(2);
            if mCurrentCount = (StrToInt(LVData.Items.Item[0].SubItems[2])+
                                StrToInt(LVData.Items.Item[1].SubItems[2])) then
            begin
              if i = (LVData.Items.Count -1) then
              begin
                LVCurrentCount := 0 ;
                ZeroColorLabel ; end else
              LVCurrentCount := i + 1;
              Break ;
            end;
            LVCurrentCount := i ;
            Break ;
          end;
        2 :
          if mCurrentCount <= (StrToInt(LVData.Items.Item[0].SubItems[2])+
                               StrToInt(LVData.Items.Item[1].SubItems[2])+
                               StrToInt(LVData.Items.Item[2].SubItems[2])) then
          begin
            LoadLabColor(3);
            if mCurrentCount = (StrToInt(LVData.Items.Item[0].SubItems[2])+
                               StrToInt(LVData.Items.Item[1].SubItems[2])+
                               StrToInt(LVData.Items.Item[2].SubItems[2])) then
            begin
              if i = (LVData.Items.Count -1) then
              begin
                LVCurrentCount := 0 ;
                ZeroColorLabel ; end else
              LVCurrentCount := i + 1 ;
              Break ;
            end;
            LVCurrentCount := i ;
            Break ;
          end;
        3 :
          if mCurrentCount <= (StrToInt(LVData.Items.Item[0].SubItems[2])+
                             StrToInt(LVData.Items.Item[1].SubItems[2])+
                             StrToInt(LVData.Items.Item[2].SubItems[2])+
                             StrToInt(LVData.Items.Item[3].SubItems[2])) then
          begin
            LoadLabColor(4);
            if mCurrentCount = (StrToInt(LVData.Items.Item[0].SubItems[2])+
                                StrToInt(LVData.Items.Item[1].SubItems[2])+
                                StrToInt(LVData.Items.Item[2].SubItems[2])+
                                StrToInt(LVData.Items.Item[3].SubItems[2])) then
            begin
              if i = (LVData.Items.Count -1) then
              begin
                LVCurrentCount := 0 ;
                ZeroColorLabel ; end else
              LVCurrentCount := i + 1;
              Break ;
            end;
            LVCurrentCount := i ;
            Break ;
          end;
        4 :
          if mCurrentCount <= (StrToInt(LVData.Items.Item[0].SubItems[2])+
                               StrToInt(LVData.Items.Item[1].SubItems[2])+
                               StrToInt(LVData.Items.Item[2].SubItems[2])+
                               StrToInt(LVData.Items.Item[3].SubItems[2])+
                               StrToInt(LVData.Items.Item[4].SubItems[2])) then
          begin
            LoadLabColor(5);
            if mCurrentCount = (StrToInt(LVData.Items.Item[0].SubItems[2])+
                                StrToInt(LVData.Items.Item[1].SubItems[2])+
                                StrToInt(LVData.Items.Item[2].SubItems[2])+
                                StrToInt(LVData.Items.Item[3].SubItems[2])+
                                StrToInt(LVData.Items.Item[4].SubItems[2])) then
            begin
              LVCurrentCount := 0;
              ZeroColorLabel ;
            end else
            LVCurrentCount := i ;
          end;
      end;
    end;

    //LoadLabColor(LVCurrentCount+1);
    LabInfo2.Caption := LVData.Items.Item[LVCurrentCount].SubItems[0] + '²£«~';
    LoadPicture(StrToInt(LvData.Items.Item[LVCurrentCount].SubItems[3]), ImgPic);

    if PrintLabel then
      mArrTypeSN[mCurrentCount-1] := Trim(EditHbSN.Text) ;

    if mCurrentCount >= mCountPerBox then
    begin
      if CheckHbForFQC.Checked then
      begin
        LvPrintLabel(mArrTypeSN,mCurrentCount,sRes,2 );
        CheckHbForFQC.Checked := False ;
      end else
      begin
        LvPrintLabel(mArrTypeSN,mCurrentCount,sRes);
      end;
      
      if sRes <> 'OK' then
      begin
        MessageBox(GetActiveWindow ,PChar(sRes),'Error',MB_OK+MB_ICONERROR) ;
        Exit;
      end;

      if (ObjGlobal.objUser.uEmpID <> '10000001') and
         (ObjGlobal.objUser.uEmpName <> 'Xiaobo Yuan') then
      begin
        //SN¹L¯¸
        for i := 1 to mCurrentCount do
        begin
          if mArrTypeSN[i-1] <> '' then
          begin
            SJ_DB_PRINT_GO(TerminalID,mArrTypeSN[i-1],ObjGlobal.objUser.uEmpNo,sRes );
            if sRes <> 'OK' then
            begin
              MessageBox(GetActiveWindow ,PChar(sRes),'Error',MB_OK+MB_ICONERROR) ;
              Exit;
            end;
            Delay(20);
          end;
        end;
      end;

      mCurrentCount := 1 ;
      LVCurrentCount := 0 ;
      ZeroMemory(@mArrTypeSN,SizeOf(mArrTypeSN));
      //SetLength(mArrTypeSN,mCountPerBox );
    end else Inc(mCurrentCount);
    //ShowMsg('SN OK !', '','RT');
    SetEditStatus('HBSN');
    //LabelHbCount.Caption := IntToStr(StrToInt(LabelCount.Caption)+1);
    LabelHbCount.Caption := IntToStr(mCurrentCount-1)+'/' + IntToStr(mCountPerBox);
  end;
end;

procedure TFormPrint.SJ_DB_PRINT_GO(TerminalID,TSN,TEMP : string ; var TRES : string);
var
  StrDate :string;
begin
  TRES := 'SJ_DB_PRINT_GO Fail!';
  with ObjDataSet.ObjProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CKRT_SN_PSN');
      FetchParams;
      Params.ParamByName('TREV').AsString := TSN;
      Execute;
      TRES := Params.ParamByName('TRES').AsString;
      SNNO := Params.ParamByName('PSN').AsString;
    except
      on E: Exception do
      begin
        TRES := 'SJ_CKRT_SN_PSN Exception' + #13#10 + E.Message;
      end;
    end;
    Close;

    //¨ú±o¼Æ¾Ú®w¤¤ªº®É¶¡
    with ObjDataSet.ObjQryTemp do
    begin
       close;
       commandtext:='select sysdate from dual ';
       open;
       StrDate:=fieldbyname('sysdate').AsString ;
       Close ;
    end;

    //SN¹L¯¸
    try
      Close;
      DataRequest('SAJET.SJ_GO');
      FetchParams;
      Params.ParamByName('tterminalid').AsString := TerminalID;
      Params.ParamByName('tsn').AsString := SNNO;
      Params.ParamByName('tnow').AsDateTime := StrtoDateTime(StrDate);
      Params.ParamByName('temp').AsString := TEMP;
      Execute;
      TRES := Params.ParamByName('TRES').AsString;
    except
      on E: Exception do
      begin
        TRES := 'SJ_SJ_GO Exception' + #13#10 + E.Message;
      end;
    end;
  end;
end;

procedure TFormPrint.BitBtn16Click(Sender: TObject);
var
  f_message : string;
begin
  if UpperCase(File_Type) = UpperCase('.lbl') then
  begin
    if LabelDoc <> nil then LabelDoc.LabelSetup ;
  end
  else if UpperCase(File_Type) = UpperCase('.lab') then
    if Assigned (m_CodeSoft) then if not m_CodeSoft.SetupPrinter(f_message) then ShowMessage(f_message) ;
end;

procedure TFormPrint.BitBtn11Click(Sender: TObject);
begin
  mCurrentCount := 1;
  if LabelDoc <> nil then
    LabelDoc.Close(False ) ;
  ZeroMemory(@mArrTypeSN,SizeOf(mArrTypeSN));
  ListGifBoxPN.Clear ;
  ListUPC.Clear ;
  SetEditStatus('SKUR');
end;

procedure TFormPrint.BitBtn6Click(Sender: TObject);
begin
  mCurrentCount := 1;
  LVCurrentCount := 0 ;
  if LabelDoc <> nil then
    LabelDoc.Close(False ) ;
  ZeroColorLabel ;
  ZeroMemory(@mArrTypeSN,SizeOf(mArrTypeSN));
  SetEditStatus('SKUH');
end;

procedure TFormPrint.Button5Click(Sender: TObject);
begin
  if  fAuthorityLogin  <> nil then
  begin
    fAuthorityLogin.Close ;
    FreeAndNil(fAuthorityLogin);
  end;

  FUN := 'Config';
  fAuthorityLogin := TAuthorityLogin.Create(Self);
  with fAuthorityLogin do
  begin
    if ShowModal = mrOK then
    begin
      with ObjDataSet.ObjQryData  do
      begin
        Close ;
        Params.Clear ;
        Params.CreateParam(ftString,'SKU_NO',ptInput);
        Params.CreateParam(ftString,'UP_LIMIT',ptInput);
        Params.CreateParam(ftString,'LOW_LIMIT',ptInput);
        Params.CreateParam(ftString,'WAIT_TIME',ptInput);
        Params.CreateParam(ftString,'WEIGHT_COUNT',ptInput);
        Params.CreateParam(ftString,'EMP',ptInput);
        CommandText := 'UPDATE  SAJET.SYS_PART_WEIGHT_PARAM SET UP_LIMIT = :UP_LIMIT,  '+
                       '  LOW_LIMIT = :LOW_LIMIT,WAIT_TIME = :WAIT_TIME,WEIGHT_COUNT = :WEIGHT_COUNT,  '+
                       '    UPDATE_USERID =:EMP WHERE SKU_NO =:SKU_NO ';
        Params.ParamByName('SKU_NO').Value := EditSKU.Text ;
        Params.ParamByName('UP_LIMIT').Value := EditUpLimit.Text ;
        Params.ParamByName('LOW_LIMIT').Value := EditLowLimit.Text ;
        Params.ParamByName('WAIT_TIME').Value := EditWaitTime.Text ;
        Params.ParamByName('WEIGHT_COUNT').Value := EditWeightCount.Text ;
        Params.ParamByName('EMP').Value := ObjGlobal.objUser.uEmpID ;
        Execute ;
        Close ;
      end;
      MessageDlg(#13+'¸ê®Æ§ó·s¦¨¥\!',mtInformation ,[mbOK],0);
    end;
  end;
  {if Login <> nil then
  begin
    Login.Close ;
    FreeAndNil(Login);
  end;

  Login := TLogin.Create(nil);
  if Login.ShowModal = mrOk then
  begin
    with ObjDataSet.ObjQryData  do
    begin
      Close ;
      Params.Clear ;
      Params.CreateParam(ftString,'SKU_NO',ptInput);
      Params.CreateParam(ftString,'UP_LIMIT',ptInput);
      Params.CreateParam(ftString,'LOW_LIMIT',ptInput);
      Params.CreateParam(ftString,'WAIT_TIME',ptInput);
      Params.CreateParam(ftString,'WEIGHT_COUNT',ptInput);
      Params.CreateParam(ftString,'EMP',ptInput);
      CommandText := 'UPDATE  SAJET.SYS_PART_WEIGHT_PARAM SET UP_LIMIT = :UP_LIMIT,  '+
                     '  LOW_LIMIT = :LOW_LIMIT,WAIT_TIME = :WAIT_TIME,WEIGHT_COUNT = :WEIGHT_COUNT,  '+
                     '    UPDATE_USERID =:EMP WHERE SKU_NO =:SKU_NO ';
      Params.ParamByName('SKU_NO').Value := EditSKU.Text ;
      Params.ParamByName('UP_LIMIT').Value := EditUpLimit.Text ;
      Params.ParamByName('LOW_LIMIT').Value := EditLowLimit.Text ;
      Params.ParamByName('WAIT_TIME').Value := EditWaitTime.Text ;
      Params.ParamByName('WEIGHT_COUNT').Value := EditWeightCount.Text ;
      Params.ParamByName('EMP').Value := ObjGlobal.objUser.uEmpID ;
      Execute ;
      Close ;
    end;
  end;}
end;

procedure TFormPrint.Button4Click(Sender: TObject);
begin
  if  fAuthorityLogin  <> nil then
  begin
    fAuthorityLogin.Close ;
    FreeAndNil(fAuthorityLogin);
  end;

  FUN := 'Config';
  fAuthorityLogin := TAuthorityLogin.Create(Self);
  with fAuthorityLogin do
  begin
    if ShowModal = mrOK then
    begin
      with ObjDataSet.ObjQryData do
      begin
        Close ;
        Params.Clear ;
        Params.CreateParam(ftString,'SKU',ptInput);
        CommandText := 'SELECT  SKU_NO FROM SAJET.SYS_PART_WEIGHT_PARAM WHERE SKU_NO = :SKU ';
        Params.ParamByName('SKU').Value := EditSKU.Text ;
        Open ;
        if IsEmpty then
        begin
          Close ;
          Params.Clear ;
          Params.CreateParam(ftString,'SKU_NO',ptInput);
          Params.CreateParam(ftString,'UP_LIMIT',ptInput);
          Params.CreateParam(ftString,'LOW_LIMIT',ptInput);
          Params.CreateParam(ftString,'WAIT_TIME',ptInput);
          Params.CreateParam(ftString,'WEIGHT_COUNT',ptInput);
          Params.CreateParam(ftString,'EMP',ptInput);
          CommandText := 'INSERT INTO SAJET.SYS_PART_WEIGHT_PARAM(SKU_NO,UP_LIMIT,LOW_LIMIT, '+
                         '  WAIT_TIME,WEIGHT_COUNT,UPDATE_USERID) VALUES (:SKU_NO,:UP_LIMIT, ' +
                          '   :LOW_LIMIT,:WAIT_TIME,:WEIGHT_COUNT,:EMP) ' ;
          Params.ParamByName('SKU_NO').Value := EditSKU.Text ;
          Params.ParamByName('UP_LIMIT').Value := EditUpLimit.Text ;
          Params.ParamByName('LOW_LIMIT').Value := EditLowLimit.Text ;
          Params.ParamByName('WAIT_TIME').Value := EditWaitTime.Text ;
          Params.ParamByName('WEIGHT_COUNT').Value := EditWeightCount.Text ;
          Params.ParamByName('EMP').Value := ObjGlobal.objUser.uEmpID ;
          Execute ;
          MessageDlg(#13+'¸ê®Æ·s¼W¦¨¥\!',mtInformation ,[mbOK],0);
        end else
        begin
          MessageDlg(#13+'REPEAT SKU_NO!!',mtError ,[mbOK ],0);
        end;
        Close ;
      end;
    end;
  end;
  {if Login <> nil then
  begin
    Login.Close ;
    FreeAndNil(Login);
  end;

  Login := TLogin.Create(nil);
  if Login.ShowModal = mrOk then
  begin
    with ObjDataSet.ObjQryData do
    begin
      Close ;
      Params.Clear ;
      Params.CreateParam(ftString,'SKU',ptInput);
      CommandText := 'SELECT  SKU_NO FROM SAJET.SYS_PART_WEIGHT_PARAM WHERE SKU_NO = :SKU ';
      Params.ParamByName('SKU').Value := EditSKU.Text ;
      Open ;
      if IsEmpty then
      begin
        Close ;
        Params.Clear ;
        Params.CreateParam(ftString,'SKU_NO',ptInput);
        Params.CreateParam(ftString,'UP_LIMIT',ptInput);
        Params.CreateParam(ftString,'LOW_LIMIT',ptInput);
        Params.CreateParam(ftString,'WAIT_TIME',ptInput);
        Params.CreateParam(ftString,'WEIGHT_COUNT',ptInput);
        Params.CreateParam(ftString,'EMP',ptInput);
        CommandText := 'INSERT INTO SAJET.SYS_PART_WEIGHT_PARAM(SKU_NO,UP_LIMIT,LOW_LIMIT, '+
                       '  WAIT_TIME,WEIGHT_COUNT,UPDATE_USERID) VALUES (:SKU_NO,:UP_LIMIT, ' +
                        '   :LOW_LIMIT,:WAIT_TIME,:WEIGHT_COUNT,:EMP) ' ;
        Params.ParamByName('SKU_NO').Value := EditSKU.Text ;
        Params.ParamByName('UP_LIMIT').Value := EditUpLimit.Text ;
        Params.ParamByName('LOW_LIMIT').Value := EditLowLimit.Text ;
        Params.ParamByName('WAIT_TIME').Value := EditWaitTime.Text ;
        Params.ParamByName('WEIGHT_COUNT').Value := EditWeightCount.Text ;
        Params.ParamByName('EMP').Value := ObjGlobal.objUser.uEmpID ;
        Execute ;
      end else
      begin
        MessageDlg('REPEAT SKU_NO!!',mtError ,[mbOK ],0);
      end;
      Close ;
    end;
  end;}
end;

procedure TFormPrint.EditSKUKeyPress(Sender: TObject; var Key: Char);
begin
  EditUpLimit.Clear ;
  EditWaitTime.Clear ;
  EditLowLimit.Clear ;
  EditWeightCount.Clear ;
  if Key =#13 then
  begin
    Key := #0 ;
    with ObjDataSet.ObjQryTemp do
    begin
      Close ;
      Params.Clear ;
      Params.CreateParam(ftString,'SKU',ptInput);
      CommandText := 'SELECT  * FROM SAJET.SYS_PART_WEIGHT_PARAM WHERE SKU_NO = :SKU AND ENABLED = ''Y'' AND ROWNUM = 1';
      Params.ParamByName('SKU').Value := EditSKU.Text ;
      Open ;
      IF NOT IsEmpty then
      begin
        EditUpLimit.Text := FieldValues['UP_LIMIT'] ;
        EditWaitTime.Text := FieldValues['WAIT_TIME'] ;
        EditLowLimit.Text := FieldValues['LOW_LIMIT'] ;
        EditWeightCount.Text := FieldValues['WEIGHT_COUNT'] ;
      end else
      begin
        EditUpLimit.Text := '0' ;
        EditWaitTime.Text := '0' ;
        EditLowLimit.Text := '0' ;
        EditWeightCount.Text := '0' ;
      end;
      Close ;
      EditSKU.SetFocus ;
      EditSKU.SelectAll ;
    end;
  end;
end;

procedure TFormPrint.ComboSKU_NoKeyPress(Sender: TObject; var Key: Char);
begin
  EditmGifBoxPN.Clear ;
  EditmUPC.Clear ;
  if Key =#13 then
  begin
    EditmUPC.SetFocus ;
    EditmUPC.SelectAll ;
  end;
end;

procedure TFormPrint.PageControl1Change(Sender: TObject);
var
  PRIVILEGE : Boolean ;
begin
  if PageControl1.ActivePage = tsConfig then
  begin
    if RunOnce then
    begin
      ShowFactory ;
      RunOnce := False ;
    end;
    ShowOption ;
    FUN := 'Config';
    fAuthorityLogin := TAuthorityLogin.Create(Self);
    with fAuthorityLogin do
    begin
      if ShowModal = mrOK then
      begin
        PRIVILEGE := True ;
      end else PRIVILEGE := False ;

      cnkCSN.Enabled := PRIVILEGE ;
      chkCheckCSN.Enabled := PRIVILEGE ;
      cnkCheckGiftBox.Enabled := PRIVILEGE ;
      cnkCSN1.Enabled := PRIVILEGE ;
      cnkPrintLabel.Enabled := PRIVILEGE ;
      EditLabelVariable.Enabled := PRIVILEGE ;
      cmbCountPerBox.Enabled := PRIVILEGE ;
      chkCapsLock.Enabled := PRIVILEGE ;
      chkbInputEC.Enabled := PRIVILEGE ;
      chkWeight.Enabled := PRIVILEGE ;
      chkProductUPC.Enabled := PRIVILEGE ;
      //edtDll.Enabled := PRIVILEGE ;
      chkAdditional.Enabled := PRIVILEGE ;
      EdtAdditionaldll.Enabled := PRIVILEGE ;
      cmbPkBase.Enabled := PRIVILEGE ;
      //cmbPkAction.Enabled := PRIVILEGE ;
      //cmbRule.Enabled := PRIVILEGE ;
      //cmbVersion.Enabled := PRIVILEGE ;
      sbtnSave.Enabled := PRIVILEGE ;

      cmbFactory.Enabled := PRIVILEGE ;
      TreePC.Enabled := PRIVILEGE ;
      btnOK.Enabled := PRIVILEGE ;
      
      if PRIVILEGE then
      begin
        if cnkPrintLabel.Checked then
        begin
          EditLabelVariable.Enabled := True ;
          EditLabelVariable.Color := clYellow ;
          cmbCountPerBox.Enabled := true;
        end else
        begin
          EditLabelVariable.Enabled := False ;
          EditLabelVariable.Color := clWhite ;
          cmbCountPerBox.Enabled := False;
        end;
      end else
      begin
        EditLabelVariable.Enabled := False ;
        EditLabelVariable.Color := clWhite ;
        cmbCountPerBox.Enabled := False;
      end;
    end;
  end else  if PageControl1.ActivePage = tsReprent then
  begin
    FUN := 'Reprint';
    fAuthorityLogin := TAuthorityLogin.Create(Self);
    with fAuthorityLogin do
    begin
      if ShowModal = mrOK then
      begin
        PRIVILEGE := True ;
      end else  PRIVILEGE := False ;
      btnReprint.Enabled := PRIVILEGE ;
      btnClear.Enabled := PRIVILEGE ;
      edtRePrintSN.Enabled := PRIVILEGE ;
      RadioGroup2.Enabled := PRIVILEGE ;
      if  PRIVILEGE then
      begin
        edtRePrintSN.Color := clYellow ;
        edtRePrintSN.SetFocus ;
        edtRePrintSN.Clear ;
        edtRePrintSN.SelectAll ;
      end
      else
        edtRePrintSN.Color := clBtnFace ;
      ClearData ;
    end;
  {end  else if  PageControl1.ActivePage = tsConfig then
  begin
    if RunOnce then
    begin
      ShowFactory ;
      RunOnce := False ;
    end;}
  end
  else if  PageControl1.ActivePage = tsQuery then
  begin
    dtpDateFrom.Date := Now ;
    dtpDateTo.Date := Now ;
  end else
  begin
    edtRePrintSN.Clear ;
    ClearData ;
    RadioGroup2.ItemIndex := -1 ;
    ComboColor.Clear ;
    EditColorSPEC.Clear ;
    ComboSKU_No.Clear ;
    EditmGifBoxPN.Clear ;
    EditmUPC.Clear ;
    EditSKU.Clear ;
    EditUpLimit.Clear ;
    EditWaitTime.Clear ;
    EditLowLimit.Clear ;
    EditWeightCount.Clear ;
  end;
  ObjDataSet.ObjQryTemp1.Close ;
  ObjSetDataSource.DataSet := nil ;
  edtQuerySN.Clear ;
  EditWO.Clear ;
end;

procedure TFormPrint.ComboColorDropDown(Sender: TObject);
begin
  ComboColor.Clear ;
  ComboColorSPEC.Clear ;
  ComboColorValue.Clear ;
  with ObjDataSet.ObjQryData do
  begin
    Close ;
    Params.Clear ;
    CommandText := 'SELECT COLOR_NAME,COLOR_SPEC,COLOR_VALUE FROM SAJET.SYS_COLOR '+
                   '  WHERE ENABLED = ''Y''  ORDER BY COLOR_NAME ';
    Open ;
    while not eof do
    begin
      ComboColor.Items.Add(FieldValues['COLOR_NAME']);
      ComboColorSPEC.Items.Add(FieldValues['COLOR_SPEC']);
      ComboColorValue.Items.Add(FieldValues['COLOR_VALUE']);
      Next ;
    end;
    Close ;
  end;
end;

procedure TFormPrint.GetColorCombo(objCombo : TComboBox);
begin
  objCombo.Clear ;
  {ComFirstColor.Clear ;
  ComSecondColor.Clear ;
  ComThirdColor.Clear ;
  comForthColor.Clear ;
  ComFifthColor.Clear ;}
  with ObjDataSet.ObjQryTemp do
  begin
    objCombo.Items.Add('');
    {ComFirstColor.Items.Add('');
    ComSecondColor.Items.Add('');
    ComThirdColor.Items.Add('');
    comForthColor.Items.Add('');
    ComFifthColor.Items.Add('');}
    Close ;
    Params.Clear ;
    CommandText := 'SELECT COLOR_NAME||''(''||COLOR_SPEC||'')'' COLOR_NAME,'+
                ' COLOR_VALUE FROM SAJET.SYS_COLOR WHERE ENABLED = ''Y'' ';
    Open ;
    while not eof do
    begin
      objCombo.Items.Add(FieldValues['COLOR_NAME']);
      {ComFirstColor.Items.Add(FieldValues['COLOR_NAME']);
      ComSecondColor.Items.Add(FieldValues['COLOR_NAME']);
      ComThirdColor.Items.Add(FieldValues['COLOR_NAME']);
      comForthColor.Items.Add(FieldValues['COLOR_NAME']);
      ComFifthColor.Items.Add(FieldValues['COLOR_NAME']);}
      Next ;
    end;
    Close ;
  end;
end;

procedure TFormPrint.ComboColorChange(Sender: TObject);
begin
  ComboColorSPEC.ItemIndex := ComboColor.ItemIndex ;
  ComboColorValue.ItemIndex := ComboColor.ItemIndex ;
  EditColorSPEC.Text := ComboColorSPEC.Text ;
  if ComboColorValue.Text <> '' then
  begin
    lblColorVaule.Caption := ComboColorValue.Text ;
    lblColorVaule.Color := StrToColor(lblColorVaule.Caption);
  end else
  begin
    lblColorVaule.Caption := '';
    lblColorVaule.Color := clBtnFace ;
  end;
end;

procedure TFormPrint.ComboColorKeyPress(Sender: TObject; var Key: Char);
begin
  EditColorSPEC.Clear ;
  lblColorVaule.Caption := 'clBtnFace';
  lblColorVaule.Color := clBtnFace ;
end;

procedure TFormPrint.btn2Click(Sender: TObject);
var
  ColorID : Integer ;
begin
  if ComboColor.Text = '' then Exit ;
  if EditColorSPEC.Text = '' then Exit ;

  with ObjDataSet.ObjQryData do
  begin
    Close ;
    Params.Clear ;
    Params.CreateParam(ftString,'COLOR_NAME',ptInput);
    CommandText := 'SELECT  COLOR_ID,COLOR_NAME FROM SAJET.SYS_COLOR WHERE  '+
                   '  COLOR_NAME = :COLOR_NAME AND ROWNUM = 1';
    Params.ParamByName('COLOR_NAME').Value := ComboColor.Text ;
    Open ;
    if not IsEmpty then
    begin
      ColorID := FieldByName('COLOR_ID').AsInteger ;
      Close ;
      Params.Clear ;
      Params.CreateParam(ftString,'COLOR_NAME',ptInput);
      Params.CreateParam(ftString,'COLOR_SPEC',ptInput);
      Params.CreateParam(ftString,'COLOR_VALUE',ptInput);
      Params.CreateParam(ftString,'COLOR_ID',ptInput);
      CommandText := 'UPDATE SAJET.SYS_COLOR SET COLOR_NAME = :COLOR_NAME,COLOR_SPEC = :COLOR_SPEC, '+
                     '  COLOR_VALUE = :COLOR_VALUE WHERE COLOR_ID = :COLOR_ID ' ;
      Params.ParamByName('COLOR_NAME').Value := ComboColor.Text ;
      Params.ParamByName('COLOR_SPEC').Value := EditColorSPEC.Text ;
      Params.ParamByName('COLOR_VALUE').Value := lblColorVaule.Caption ;
      Params.ParamByName('COLOR_ID').Value := ColorID ;
      Execute ;
      MessageDlg('Color Update Successful!!',mtInformation ,[mbOK],0);
    end else
    begin
      Close ;
      Params.Clear ;
      Params.CreateParam(ftString,'COLOR_NAME',ptInput);
      Params.CreateParam(ftString,'COLOR_SPEC',ptInput);
      Params.CreateParam(ftString,'COLOR_VALUE',ptInput);
      Params.CreateParam(ftString,'COLOR_ID',ptInput);
      Params.CreateParam(ftString,'USERID',ptInput);
      CommandText := 'INSERT INTO SAJET.SYS_COLOR(COLOR_ID, COLOR_NAME,COLOR_SPEC,COLOR_VALUE,UPDATE_USERID) '+
                     '   VALUES (:COLOR_ID,:COLOR_NAME,:COLOR_SPEC,:COLOR_VALUE,:USERID ) ';
      Params.ParamByName('COLOR_NAME').Value := ComboColor.Text ;
      Params.ParamByName('COLOR_SPEC').Value := EditColorSPEC.Text ;
      Params.ParamByName('COLOR_VALUE').Value := lblColorVaule.Caption ;
      Params.ParamByName('COLOR_ID').Value := GetMaxID('SAJET.SYS_COLOR','COLOR_ID');
      Params.ParamByName('USERID').Value := ObjGlobal.objUser.uEmpID ;
      Execute ;
      MessageDlg('Color Add Successful!!',mtInformation ,[mbOK],0);
    end;
    Close ;
  end;
end;

function TFormPrint.SetStatusbyAuthority(PRG,FUN : string): Boolean;
var Auth: string;
begin
  // Read Only,Allow To Change,Full Control
  Auth := '';
  Result := False;
  with ObjDataSet.ObjQryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EMP_ID', ptInput);
    Params.CreateParam(ftString, 'PRG', ptInput);
    Params.CreateParam(ftString, 'FUN', ptInput);
    CommandText :=  'Select AUTHORITYS ' +
                    'From SAJET.SYS_EMP_PRIVILEGE ' +
                    'Where EMP_ID = :EMP_ID and ' +
                    'PROGRAM = :PRG and ' +
                    'FUNCTION = :FUN ';
    Params.ParamByName('EMP_ID').AsString := ObjGlobal.objUser.uEmpID ;
    Params.ParamByName('PRG').AsString := PRG;
    Params.ParamByName('FUN').AsString := FUN;
    Open;
    while not Eof do
    begin
      Auth := Fieldbyname('AUTHORITYS').AsString;
      Result := (Auth = 'Allow To Change') or (Auth = 'Full Control');
      if Result then
        break;
      Next;
    end;
    Close;
  end;
  
  if not Result then
  begin
    Auth := '';
    with ObjDataSet.ObjQryData do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      Params.CreateParam(ftString, 'FUN', ptInput);
      CommandText := 'Select AUTHORITYS ' +
        'From SAJET.SYS_ROLE_PRIVILEGE A, ' +
        'SAJET.SYS_ROLE_EMP B ' +
        'Where A.ROLE_ID = B.ROLE_ID and ' +
        'EMP_ID = :EMP_ID and ' +
        'PROGRAM = :PRG and ' +
        'FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := ObjGlobal.objUser.uEmpID ;
      Params.ParamByName('PRG').AsString := PRG;
      Params.ParamByName('FUN').AsString := FUN;
      Open;
      while not Eof do
      begin
        Auth := Fieldbyname('AUTHORITYS').AsString;
        Result := (Auth = 'Allow To Change') or (Auth = 'Full Control');
        if Result then
          break;
        Next;
      end;
      Close;
    end;
  end;
end;

procedure TFormPrint.Label72Click(Sender: TObject);
begin
  GetLVcolorData;
end;

procedure TFormPrint.BitBtn3Click(Sender: TObject);
begin
  mCurrentCount := 1;
  LVCurrentCount := 0 ;
  ZeroMemory(@mArrTypeSN,SizeOf(mArrTypeSN));
  //SetEditStatus('SKU');
  //ComboSKU.ItemIndex := -1 ;
  SetEditStatus('SN');
  EditSN.Clear ;
  EditCSN.Clear ;
  EditUPC.Clear ;
end;

procedure TFormPrint.BitBtn12Click(Sender: TObject);
begin
  mCurrentCount := 1;
  LVCurrentCount := 0 ;
  ZeroMemory(@mArrTypeSN,SizeOf(mArrTypeSN));
  //SetEditStatus('SKUR');
  //ComboSKUR.ItemIndex := -1 ;
  SetEditStatus('RTSN');
  EditGiftBox.Clear ;
  EditRtSN.Clear ;
end;

procedure TFormPrint.BitBtn8Click(Sender: TObject);
var i : Integer ;
begin
  mCurrentCount := 1;
  LVCurrentCount := 0 ;
  for i := 1 to 5 do
    TLabel(self.findcomponent('LabeColor'+IntToStr(i))).caption := '0';
  ZeroMemory(@mArrTypeSN,SizeOf(mArrTypeSN));
  //SetEditStatus('SKUH');
  //ComboSKUH.ItemIndex := -1 ;
  SetEditStatus('HBSN');
  EditHbSN.Clear ;
end;

procedure TFormPrint.BitBtnExitClick(Sender: TObject);
begin
  StopLabelViewApp;
  Application.Terminate ;
end;

procedure TFormPrint.HotKeyDown(var Msg: Tmessage);
begin
  if (Msg.LparamLo = MOD_ALT) AND (Msg.LParamHi = VK_F8) then
  begin
     showmessage('ALT' + 'F8');
  end ;
  
  if msg.LParamHi = VK_F5 then
  begin
    if MessageDlg(' Are you sure that reload data?',
        mtWarning,[mbYes, mbNo],0) = mrYes then
    begin
      //
    end;
  end;
end;

procedure TFormPrint.chkByDateTimeClick(Sender: TObject);
begin
  if chkByDateTime.Checked then
  begin
    dtpDateFrom.Enabled := true ;
    dtpDateTo.Enabled := true ;
    dtpTimeFrom.Enabled := true ;
    dtpTimeTo.Enabled := true ;
  end else
  begin
    dtpDateFrom.Enabled := False ;
    dtpDateTo.Enabled := False ;
    dtpTimeFrom.Enabled := False ;
    dtpTimeTo.Enabled := False ;
  end;
end;

procedure TFormPrint.ShowFactory;
var S: string;
begin
  cmbFactory.Items.Clear;
  LabPDLine.Caption := '';
  LabStage.Caption := '';
  LabProcess.Caption := '';
  LabTerminal.Caption := '';
  with ObjDataSet.ObjQryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT FACTORY_ID, FACTORY_CODE, FACTORY_NAME ' +
      'FROM SAJET.SYS_FACTORY ' +
      'WHERE ENABLED = ''Y'' ';
    Open;
    while not Eof do
    begin
      Application.ProcessMessages ;
      cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString);
      if Fieldbyname('FACTORY_ID').AsString = FCID then
        S := Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString;
      Next;
    end;
    Close;
  end;

  if S <> '' then
  begin
    cmbFactory.ItemIndex := cmbFactory.Items.IndexOf(S);
    cmbFactoryChange(Self);
    Exit;
  end;

  if cmbFactory.Items.Count = 1 then
  begin
    cmbFactory.ItemIndex := 0;
    cmbFactoryChange(Self);
  end;
end;

procedure TFormPrint.ComFirstColorDropDown(Sender: TObject);
begin
  GetColorCombo((Sender as TComboBox)) ;
end;

procedure TFormPrint.BitBtn14Click(Sender: TObject);
var
  f_message : string ;
begin
  if UpperCase(File_Type)=UpperCase('.lbl') then
  begin
    if Assigned(LabelApp) then LabelApp.ConfigWindow ;
  end
  else if UpperCase(File_Type)=UpperCase('.lab') then
    if Assigned(m_CodeSoft) then m_CodeSoft.SetupPage(f_message);
end;

procedure TFormPrint.edtRePrintSNKeyPress(Sender: TObject; var Key: Char);
var
  TWO,CartonNo : string ;
  i : Integer ;
begin
  if Key = #13 then
  begin
    Key := #0 ;
    try
      if  RadioGroup2.ItemIndex < 0 then
      begin
        MessageDlg('½Ð¿ï¾ÜSNª¬ºA!', mtWarning, [mbOK], 0);
        edtRePrintSN.SetFocus ;
        edtRePrintSN.SelectAll ;
        Exit ;
      end;

      if RadioGroup2.ItemIndex = 0 then
      begin
        DspTravelData ;
        //btnReprint.Click ;  //¥´¦L
      end else if RadioGroup2.ItemIndex = 1 then
      begin
        ClearData ;
        with ObjDataSet.ObjQryData do
        begin
          Close ;
          Params.Clear ;
          Params.CreateParam(ftString ,'SN',ptInput );
          CommandText := 'SELECT WORK_ORDER,CARTON_NO FROM SAJET.G_SN_STATUS WHERE '
                       + ' SERIAL_NUMBER = :SN  AND ROWNUM = 1 ';//OR CUSTOMER_SN = :SN) AND ROWNUM = 1 ';
          Params.ParamByName('SN').AsString := Trim(edtRePrintSN.Text);
          Open ;
          if IsEmpty then
          begin
            Close ;
            Params.Clear ;
            Params.CreateParam(ftString ,'SN',ptInput );
            CommandText := 'SELECT WORK_ORDER,CARTON_NO FROM SAJET.G_SN_STATUS WHERE ' +
                           '  CUSTOMER_SN = :SN AND ROWNUM = 1  ';
            Params.ParamByName('SN').AsString := Trim(edtRePrintSN.Text);
            Open
          end;
          if not IsEmpty then
          begin
            TWO := FieldByName('WORK_ORDER').AsString ;
            CartonNo := FieldByName('CARTON_NO').AsString ;
            Close ;
          end else
          begin
            Close ;
            MessageDlg('Serial Number  or Customer SN Error !', mtWarning, [mbOK], 0);
            edtRePrintSN.SetFocus ;
            edtRePrintSN.SelectAll ;
            Exit ;
          end;

          if CartonNo ='N/A' then
          begin
            Close ;
            MessageDlg('½Ð½T»{¦¹SN¬O§_¤w¸g¶i¹L¥]¸Ë¨t²Î¨Ã²£¥Í¥d³q¸¹!', mtWarning, [mbOK], 0);
            edtRePrintSN.SetFocus ;
            edtRePrintSN.SelectAll ;
            Exit ;
          end;
          
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'WO', ptInput);
          Params.CreateParam(ftString, 'CARTON_NO', ptInput);
          CommandText := 'Select A.SERIAL_NUMBER,A.WORK_ORDER ' +
            '      ,NVL(D.PDLINE_NAME,A.PDLINE_ID) PDLINE_NAME ' +
            '      ,NVL(B.PROCESS_NAME,A.PROCESS_ID) PROCESS_NAME ' +
            '      ,NVL(E.TERMINAL_NAME,A.TERMINAL_ID) TERMINAL_NAME ' +
            '      ,NVL(C.EMP_NAME ,A.EMP_ID) EMP_NAME ' +
            '      ,TO_CHAR(A.IN_PROCESS_TIME,''YYYY/MM/DD HH24:MI'') TIME ' +
            '      ,NVL(A.CUSTOMER_SN,''N/A'') CUSTOMER_SN ' +
            //'      ,DECODE(A.CUSTOMER_SN,''N/A'',A.SERIAL_NUMBER,A.CUSTOMER_SN) CUSTOMER_SN ' +
            '      ,NVL(A.PALLET_NO,''N/A'') PALLET_NO ' +
            '      ,NVL(A.CARTON_NO,''N/A'') CARTON_NO ' +
            '      ,A.Work_Flag, A.QC_No ' +
          'From SAJET.G_SN_STATUS A,' +
            'SAJET.SYS_PROCESS B,' +
            'SAJET.SYS_EMP C,' +
            'SAJET.SYS_PDLINE D,' +
            'SAJET.SYS_TERMINAL E ' +
            //'Where A.SERIAL_NUMBER = :SN and ' +
            'WHERE WORK_ORDER = :WO AND '+
            'CARTON_NO = :CARTON_NO AND  '+
            'A.PROCESS_ID = B.PROCESS_ID(+) and ' +
            'A.EMP_ID=C.EMP_ID(+) and ' +
            'A.PDLINE_ID = D.PDLINE_ID(+) and ' +
            'A.TERMINAL_ID = E.TERMINAL_ID(+) ';
          Params.ParamByName('WO').AsString := TWO;
          Params.ParamByName('CARTON_NO').AsString :=CartonNo ;
          Open;
          if not IsEmpty then
          begin
            while not Eof do
            begin
              if FieldByName('Work_Flag').AsString = '1' then
              begin
                MessageDlg('The S/N. Scrap !!', mtError, [mbOK], 0);
                Exit;
              end;

              if lstG_SerialNumber.Items.IndexOf(FieldByName('Serial_Number').AsString) <> -1 then
              begin
                MessageDlg('Serial Number Duplicate!', mtWarning, [mbOK], 0);
                exit;
              end;

              for I := 0 to Fields.Count - 2 do
              begin
                GridTravel.Cells[i, GridTravel.RowCount - 1] := FieldS[i].Text;
              end;
              GridTravel.RowCount := GridTravel.RowCount + 1;
              lstG_SerialNumber.Items.Add(FieldByName('Serial_Number').AsString);
              Next ;
            end;
            btnReprint.Click ;  //¥´¦L
          end;
        end;
      end;
    finally
      edtRePrintSN.SelectAll;
      edtRePrintSN.SetFocus;
      ObjDataSet.ObjQryTemp.Close;
    end;
  end;
end;

procedure TFormPrint.DspTravelData;
var i: integer;
begin
  try
    with ObjDataSet.ObjQryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'ProcID', ptInput);
      Params.CreateParam(ftString, 'SN', ptInput);
      //Params.CreateParam(ftString, 'WO', ptInput);
      CommandText := 'Select SERIAL_NUMBER FROM SAJET.G_SN_TRAVEL WHERE '+//WORK_ORDER =:WO AND ' +
                     '  SERIAL_NUMBER =:SN  AND PROCESS_ID =:ProcID AND ROWNUM = 1 ';
      Params.ParamByName('ProcID').AsString := G_sProcessID ;
      Params.ParamByName('SN').AsString := edtRePrintSN.Text;
      //Params.ParamByName('WO').AsString := edtRePrintSN.Text;
      Open;
      if IsEmpty then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'ProcID', ptInput);
        Params.CreateParam(ftString, 'SN', ptInput);
        //Params.CreateParam(ftString, 'WO', ptInput);
        CommandText := 'Select SERIAL_NUMBER FROM SAJET.G_SN_TRAVEL WHERE '+//WORK_ORDER =:WO AND ' +
                       '  CUSTOMER_SN =:SN  AND PROCESS_ID =:ProcID AND ROWNUM = 1 ';
        Params.ParamByName('ProcID').AsString := G_sProcessID ;
        Params.ParamByName('SN').AsString := edtRePrintSN.Text;
        Open ;
        if IsEmpty then
        begin
          Close ;
          MessageDlg('½Ð½T»{¦¹SN¬O§_¤w¸g¥´¦L¹L¼ÐÅÒ!', mtWarning, [mbOK], 0);
          edtRePrintSN.SetFocus ;
          edtRePrintSN.SelectAll ;
          Exit ;
        end;
      end ;

      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SN', ptInput);
      CommandText := 'Select A.SERIAL_NUMBER,A.WORK_ORDER ' +
        '      ,NVL(D.PDLINE_NAME,A.PDLINE_ID) PDLINE_NAME ' +
        '      ,NVL(B.PROCESS_NAME,A.PROCESS_ID) PROCESS_NAME ' +
        '      ,NVL(E.TERMINAL_NAME,A.TERMINAL_ID) TERMINAL_NAME ' +
        '      ,NVL(C.EMP_NAME ,A.EMP_ID) EMP_NAME ' +
        '      ,TO_CHAR(A.IN_PROCESS_TIME,''YYYY/MM/DD HH24:MI'') TIME ' +
        '      ,NVL(A.CUSTOMER_SN,''N/A'') CUSTOMER_SN ' +
        //'      ,DECODE(A.CUSTOMER_SN,''N/A'',A.SERIAL_NUMBER,A.CUSTOMER_SN) CUSTOMER_SN ' +
        '      ,NVL(A.PALLET_NO,''N/A'') PALLET_NO ' +
        '      ,NVL(A.CARTON_NO,''N/A'') CARTON_NO ' +
        '      ,A.Work_Flag, A.QC_No ' +
      'From SAJET.G_SN_STATUS A,' +
        'SAJET.SYS_PROCESS B,' +
        'SAJET.SYS_EMP C,' +
        'SAJET.SYS_PDLINE D,' +
        'SAJET.SYS_TERMINAL E ' +
        'Where A.SERIAL_NUMBER = :SN and ' +
        'A.PROCESS_ID = B.PROCESS_ID(+) and ' +
        'A.EMP_ID=C.EMP_ID(+) and ' +
        'A.PDLINE_ID = D.PDLINE_ID(+) and ' +
        'A.TERMINAL_ID = E.TERMINAL_ID(+) ';

      Params.ParamByName('SN').AsString := edtRePrintSN.Text;
      Open;
      if IsEmpty then
      begin
        //¨ê¤J«È¤á§Ç¸¹
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'SN', ptInput);
        CommandText := 'Select A.SERIAL_NUMBER,A.WORK_ORDER ' +
          '      ,NVL(D.PDLINE_NAME,A.PDLINE_ID) PDLINE_NAME ' +
          '      ,NVL(B.PROCESS_NAME,A.PROCESS_ID) PROCESS_NAME ' +
          '      ,NVL(E.TERMINAL_NAME,A.TERMINAL_ID) TERMINAL_NAME ' +
          '      ,NVL(C.EMP_NAME ,A.EMP_ID) EMP_NAME ' +
          '      ,TO_CHAR(A.IN_PROCESS_TIME,''YYYY/MM/DD HH24:MI'') TIME ' +
          '      ,NVL(A.CUSTOMER_SN,''N/A'') CUSTOMER_SN ' +
          '      ,NVL(A.PALLET_NO,''N/A'') PALLET_NO ' +
          '      ,NVL(A.CARTON_NO,''N/A'') CARTON_NO ' +
          '      ,A.Work_Flag, A.QC_NO ' +
        'From SAJET.G_SN_STATUS A,' +
          'SAJET.SYS_PROCESS B,' +
          'SAJET.SYS_EMP C,' +
          'SAJET.SYS_PDLINE D,' +
          'SAJET.SYS_TERMINAL E ' +
          'Where A.CUSTOMER_SN = :SN and ' +
          'A.PROCESS_ID = B.PROCESS_ID(+) and ' +
          'A.EMP_ID=C.EMP_ID(+) and ' +
          'A.PDLINE_ID = D.PDLINE_ID(+) and ' +
          'A.TERMINAL_ID = E.TERMINAL_ID(+) ';

        Params.ParamByName('SN').AsString := edtRePrintSN.Text;
        Open;
        if IsEmpty then
        begin
          MessageDlg('Serial Number  or Customer SN Error !', mtWarning, [mbOK], 0);
          Abort ;
        end;
      end;

      if not IsEmpty then
      begin
        if FieldByName('Work_Flag').AsString = '1' then
        begin
          MessageDlg('The S/N. Scrap !!', mtError, [mbOK], 0);
          Abort;
        end;
        if lstG_SerialNumber.Items.IndexOf(FieldByName('Serial_Number').AsString) <> -1 then
        begin
          MessageDlg('Serial Number Duplicate!', mtWarning, [mbOK], 0);
          Abort;
        end;
        
        for I := 0 to Fields.Count - 2 do
        begin
          GridTravel.Cells[i, GridTravel.RowCount - 1] := FieldS[i].Text;
        end;
        GridTravel.RowCount := GridTravel.RowCount + 1;
        lstG_SerialNumber.Items.Add(FieldByName('Serial_Number').AsString);
      end;
    end;
  finally
    edtRePrintSN.SetFocus;
    edtRePrintSN.SelectAll;
    ObjDataSet.ObjQryTemp.Close;
  end;
end;

procedure TFormPrint.ClearData;
var I: Integer;
begin
  with GridTravel do
  begin
    for i := 0 to RowCount - 1 do
      Rows[i].Clear;
    RowCount := 2;
    ColCount := 10;
    Cells[0, 0] := 'S/N';
    Cells[1, 0] := 'Work Order';
    Cells[2, 0] := 'Line';
    Cells[3, 0] := 'Process';
    Cells[4, 0] := 'Terminal';
    Cells[5, 0] := 'Operator';
    Cells[6, 0] := 'Time';
    Cells[7, 0] := 'Customer SN';
    Cells[8, 0] := 'PALLET_NO';
    Cells[9, 0] := 'CARTON_NO';
  end;
  lstG_SerialNumber.Clear;
end;

procedure TFormPrint.btnClearClick(Sender: TObject);
begin
  ClearData ;
  edtRePrintSN.Clear ;
  edtRePrintSN.SetFocus ;
  edtRePrintSN.SelectAll ;
end;

procedure TFormPrint.btnReprintClick(Sender: TObject);
var
  MsgStr, sRes, G_Print_SN : string;
  I : Integer ;
  mRePrintArrTypeSN : array of string ;
begin
  if lstG_SerialNumber.Count = 0 then
  begin
    MessageDlg('No Serial Number Data To RePrint !!', mtError, [mbCancel], 0);
    Exit;
  end;
  MsgStr := 'Äµ§i,©Ò¥HSN¼Æ¾Ú¤w¸g¾É¤J,¬O§_­n¥´¦L?«ö<¬O(Y)>¥´¦L,«ö<§_(N)>©ñ±ó'+
            #13+#10+'Warning:All Data already import!!Press<Yes> to Print,<No> to Abort!!'+
            #13+#13+'Work Order='+GridTravel.Cells[1,1]+
            //#13+'Serial Number='+TSN+
            #13+'Print Time='+FormatDateTime('YYYY/MM/DD HH:mm:ss',NOW) ;
  if MessageBox(0,PChar(MsgStr),'Äµ§i(Warning)',MB_SYSTEMMODAL +
     MB_ICONQUESTION + MB_YESNO +MB_DEFBUTTON1)= IDYES  then
  begin
    ZeroMemory(@mRePrintArrTypeSN,SizeOf(mRePrintArrTypeSN));
    SetLength(mRePrintArrTypeSN,GridTravel.RowCount -2);

    if LabelType <> 'RETAIL' then
    begin
      for i := 1 to GridTravel.RowCount -2 do
      begin
        if GridTravel.Cells[7,i] <> 'N/A' then
          G_Print_SN := GridTravel.Cells[7,i]
        else
          G_Print_SN := GridTravel.Cells[0,i];
          
        if  G_Print_SN  = 'N/A' then
        begin
          MessageDlg('Serial Number  or Customer SN Error !', mtWarning, [mbOK], 0);
          edtRePrintSN.SetFocus ;
          edtRePrintSN.SelectAll ;
          Abort ;
        end;
        mRePrintArrTypeSN[i-1] := G_Print_SN ;
      end;
      if UpperCase(File_Type)='.LBL' then
      begin
        LvPrintLabel(mRePrintArrTypeSN,GridTravel.RowCount -2,sRes);
        if sRes <> 'OK' then
        begin
          ShowMsg(sRes, 'ERROR');
          Exit;
        end;
      end else if UpperCase(File_Type)='.LAB' then
      begin
        for i := 1 to GridTravel.RowCount -2  do
        begin
          m_CodeSoft.AssignPrintData(LabelVariable + IntToStr(i),mRePrintArrTypeSN[i-1])
        end;
        m_CodeSoft.Print(1); 
      end;
    end else
    begin
      for i := 1 to GridTravel.RowCount -2 do
      begin
        if GridTravel.Cells[7,i] <> 'N/A' then
          G_Print_SN := GridTravel.Cells[7,i]
        else
          G_Print_SN := GridTravel.Cells[0,i];
        if  G_Print_SN  = 'N/A' then
        begin
          MessageDlg('Serial Number  or Customer SN Error !', mtWarning, [mbOK], 0);
          edtRePrintSN.SetFocus ;
          edtRePrintSN.SelectAll ;
          Abort ;
        end;
        if UpperCase(File_Type)='.LBL' then
        begin
          //LabelDocApply ;  //¨ê·s¶Ç¤Jªº¥´¦L¤º®e,§_«h¥´¦L¥X¨Óªº¤º®e¤£ÅÜ
          if not SetLabelValue(LabelVariable ,G_Print_SN) then Abort ;
          Sleep(20);
          if LabelDoc <> nil then
            //LabelDoc.PrintLabel(1, 0, 0, 0, 0, 0, 0); //¥´¦L¡A¼Æ¶q¬°1
            LVMenuPrint(TreeView1);
        end else if UpperCase(File_Type)='.LAB' then
        begin
          m_CodeSoft.AssignDataImmediate(LabelVariable ,G_Print_SN);
          m_CodeSoft.PrintLabel(1);
        end;
        Sleep(500);
      end;
    end;
    //¼g¤J¼Æ¾Ú®w
    //InsertPrintLog();
    for i := 1 to GridTravel.RowCount -2 do
    begin
      with ObjDataSet.ObjQryData do
      begin
        Close ;
        Params.Clear ;
        Params.CreateParam(ftString ,'WO',ptInput );
        Params.CreateParam(ftString ,'SN',ptInput );
        Params.CreateParam(ftString ,'LINE_ID',ptInput );
        Params.CreateParam(ftString ,'PROCESS_ID',ptInput );
        Params.CreateParam(ftString ,'TERMINAL_ID',ptInput );
        Params.CreateParam(ftString ,'CUSTOMER_SN',ptInput );
        Params.CreateParam(ftString ,'CARTON_NO',ptInput );
        Params.CreateParam(ftString ,'PALLET_NO',ptInput );
        Params.CreateParam(ftString ,'UPDATE_USERID',ptInput );
        CommandText := 'INSERT INTO SAJET.G_SN_PRINT(WORK_ORDER,SERIAL_NUMBER,LINE_ID,PROCESS_ID,  ' +
                       '  TERMINAL_ID,CUSTOMER_SN,CARTON_NO,PALLET_NO,UPDATE_USERID ) VALUES (:WO,:SN, ' +
                       '    :LINE_ID,:PROCESS_ID,:TERMINAL_ID,:CUSTOMER_SN,:CARTON_NO,:PALLET_NO,:UPDATE_USERID )';
        Params.ParamByName('WO').AsString := GridTravel.Cells[1,i] ;
        Params.ParamByName('SN').AsString := GridTravel.Cells[0,i] ;
        Params.ParamByName('LINE_ID').AsString := G_sLineID;      
        Params.ParamByName('PROCESS_ID').AsString := G_sProcessID ;
        Params.ParamByName('TERMINAL_ID').AsString := TerminalID ;
        Params.ParamByName('CUSTOMER_SN').AsString := GridTravel.Cells[7,i] ;
        Params.ParamByName('CARTON_NO').AsString := GridTravel.Cells[9,i] ;
        Params.ParamByName('PALLET_NO').AsString := GridTravel.Cells[8,i] ;
        Params.ParamByName('UPDATE_USERID').AsString := UserID ;
        Execute ;
      end;
    end;
    btnClear.Click ;
  end;
end;

procedure TFormPrint.InsertPrintLog(WO,SN,LINE_ID,PROCESS_ID,TERMINAL_ID,CARTON_NO,PALLET_NO,UPDATE_USERID : string);
begin
  with ObjDataSet.ObjQryData do
  begin
    Close ;
    Params.Clear ;
    Params.CreateParam(ftString ,'WO',ptInput );
    Params.CreateParam(ftString ,'SN',ptInput );
    Params.CreateParam(ftString ,'LINE_ID',ptInput );
    Params.CreateParam(ftString ,'PROCESS_ID',ptInput );
    Params.CreateParam(ftString ,'TERMINAL_ID',ptInput );
    Params.CreateParam(ftString ,'CARTON_NO',ptInput );
    Params.CreateParam(ftString ,'PALLET_NO',ptInput );
    Params.CreateParam(ftString ,'UPDATE_USERID',ptInput );
    CommandText := 'INSERT INTO SAJET.G_SN_PRINT(WORK_ORDER,SERIAL_NUMBER,LINE_ID,PROCESS_ID,  ' +
                   '  TERMINAL_ID,CARTON_NO,PALLET_NO,UPDATE_USERID ) VALUES (:WO,:SN,:LINE_ID, ' +
                   '    :PROCESS_ID,:TERMINAL_ID,:CARTON_NO,:PALLET_NO,:UPDATE_USERID )';
    Params.ParamByName('WO').AsString := WO ;
    Params.ParamByName('SN').AsString := SN ;
    Params.ParamByName('LINE_ID').AsString := LINE_ID;
    Params.ParamByName('PROCESS_ID').AsString := PROCESS_ID ;
    Params.ParamByName('TERMINAL_ID').AsString := TERMINAL_ID ;
    Params.ParamByName('CARTON_NO').AsString := CARTON_NO ;
    Params.ParamByName('PALLET_NO').AsString := PALLET_NO ;
    Params.ParamByName('UPDATE_USERID').AsString := UPDATE_USERID ;
    Execute ;
  end;
end;

procedure TFormPrint.BitBtn7Click(Sender: TObject);
var
  SqlStr : string;
begin
  with ObjDataSet.ObjQryTemp1 do
  begin
    Close ;
    Params.Clear ;
    //Params.CreateParam(ftString ,'',ptInput );
    SqlStr := 'SELECT WORK_ORDER,B.PDLINE_NAME,C.PROCESS_NAME,D.TERMINAL_NAME,A.UPDATE_TIME,'+
              '  E.EMP_NAME ,SERIAL_NUMBER,CUSTOMER_SN,CARTON_NO,PALLET_NO ' +
              '   FROM SAJET.G_SN_PRINT A,SAJET.SYS_PDLINE B,SAJET.SYS_PROCESS C,' +
              '     SAJET.SYS_TERMINAL D ,SAJET.SYS_EMP E  WHERE  ';
    if EditWO.Text <> '' then
      SqlStr := SqlStr + 'a.work_order =''' + EditWO.Text+''' AND ' ;
    if edtQuerySN.Text <> '' then
      SqlStr := SqlStr + '(a.SERIAL_NUMBER =''' + edtQuerySN.Text+'''  OR  ' +
                '  a.CUSTOMER_SN =''' + edtQuerySN.Text+''')  AND  ' ;
    if  chkByDateTime.Checked then
      SqlStr := SqlStr + 'a.UPDATE_TIME >=TO_DATE(''' + FormatDateTime('YYYY/MM/DD',dtpDateFrom.DateTime)+' '+
                         FormatDateTime('hh:mm:ss',dtpTimeFrom.DateTime)+''',''YYYY/MM/DD HH24:MI:SS'') AND ' +
                         'a.UPDATE_TIME <=TO_DATE(''' + FormatDateTime('YYYY/MM/DD',dtpDateTo.DateTime)+' '+
                         FormatDateTime('hh:mm:ss',dtpTimeTo.DateTime)+''',''YYYY/MM/DD HH24:MI:SS'') AND ' ;
    SqlStr := SqlStr + ' A.LINE_ID=B.PDLINE_ID AND A.PROCESS_ID=C.PROCESS_ID AND '+
                       '   A.TERMINAL_ID=D.TERMINAL_ID AND A.UPDATE_USERID=E.EMP_ID '; 
    CommandText := SqlStr;
    Open ;
    ObjSetDataSource.DataSet := ObjDataSet.ObjQryTemp1 ;
    DBGridAutoSize(DBGrid1);
    
    IF EditWO.Text <> '' then
    begin
      EditWO.SetFocus ;
      EditWO.SelectAll ;
    end else if edtQuerySN.Text <> '' then
    begin
      edtQuerySN.SetFocus ;
      edtQuerySN.SelectAll ; 
    end;
  end;
end;

function   TFormPrint.DBGridRecordSize(mColumn:   TColumn):   Boolean;
{   ªð¦^°O¿ý¼Æ¾Úºô®æ¦CÅã¥Ü³Ì¤j¼e«×¬O§_¦¨¥\   }
begin
    Result   :=   False;
    if   not   Assigned(mColumn.Field)   then   Exit;
    mColumn.Field.Tag   :=   Max(mColumn.Field.Tag,
        TDBGrid(mColumn.Grid).Canvas.TextWidth(mColumn.Field.DisplayText));
    Result   :=   True;
end;   {   DBGridRecordSize   }

function   TFormPrint.DBGridAutoSize(mDBGrid:   TDBGrid;   mOffset:   Integer   =   5):   Boolean;
{   ªð¦^¼Æ¾Úºô®æ¦Û°Ê¾AÀ³¼e«×¬O§_¦¨¥\   }
var
    I:   Integer;
begin
    Result   :=   False;
    if   not   Assigned(mDBGrid)   then   Exit;
    if   not   Assigned(mDBGrid.DataSource)   then   Exit;
    if   not   Assigned(mDBGrid.DataSource.DataSet)   then   Exit;
    if   not   mDBGrid.DataSource.DataSet.Active   then   Exit;
    for   I   :=   0   to   mDBGrid.Columns.Count   -   1   do   begin
        if   not   mDBGrid.Columns[I].Visible   then   Continue;
        if   Assigned(mDBGrid.Columns[I].Field)   then
            mDBGrid.Columns[I].Width   :=   Max(mDBGrid.Columns[I].Field.Tag,
                mDBGrid.Canvas.TextWidth(mDBGrid.Columns[I].Title.Caption))   +   mOffset   
        else   mDBGrid.Columns[I].Width   :=
            mDBGrid.Canvas.TextWidth(mDBGrid.Columns[I].Title.Caption)   +   mOffset;
        mDBGrid.Refresh;
    end;
    Result   :=   True;
end;   {   DBGridAutoSize   }

procedure TFormPrint.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  DBGridRecordSize(Column); 
end;

procedure TFormPrint.btnReloadClick(Sender: TObject);
var
  TRES : string;
begin
  if LabelDoc <> nil then
    LabelDoc.Close(False ) ;
  if Assigned(m_CodeSoft) then
    m_CodeSoft.CloseSampleFile(False) ;
  {if (not VarIsEmpty(m_Documents)) and (not VarIsNull(m_Documents)) then
    m_Documents.Close;}

  mCurrentCount := 1;
  ZeroMemory(@mArrTypeSN,SizeOf(mArrTypeSN));
  ListGifBoxPN.Clear ;
  ListUPC.Clear ;
  lstlpVariableName.Clear ;
  lstlpVariableValue.Clear ;

  DonwLoadLabel( mPartNo, TRES );
  if TRES <> 'OK' then
  begin
    MessageBox(GetActiveWindow ,PChar('ÀË´ú¨ìµ{§Ç¦b°õ¦æ¤¤µo¥Í¿ù»~,½Ð¥ý³B²z¿ù»~!!'+
                   #13+#13+'¿ù»~«H®§: '+TRES),'Error',MB_SYSTEMMODAL+MB_OK+MB_ICONERROR) ;
    if LabelType ='RETAIL' then
    begin
      EditGiftBox.Enabled := False ;
      EditRtSN.Enabled := False ;
      EditGiftBox.Color := clWhite ;
      EditRtSN.Color := clWhite ;
    end else if LabelType ='MINGLE' then
    begin
      EditHbSN.Enabled := False ;
      EditHbSN.Color := clWhite ;
    end else if LabelType = 'SHIPPER' then
    begin
      EditSN.Enabled := False ;
      EditCSN.Enabled := False ;
      EditUPC.Enabled := False ;
      EditSN.Color := clWhite ;
      EditCSN.Color := clWhite ;
      EditUPC.Color := clWhite ;
    end;
  end else
  begin
    if LabelType ='RETAIL' then
    begin
      if CheckGiftBoxPN then
      begin
        SetEditStatus('GIFBOX');
      end else
      begin
        SetEditStatus('RTSN');
      end;
      ShowMsg('ReLoad OK.', '','RT');
    end else if LabelType ='MINGLE' then
    begin
      SetEditStatus('HBSN');
    end else if LabelType = 'SHIPPER' then
    begin
      SetEditStatus('SN');
      ShowMsg('ReLoad OK.', '');
    end;
  end;
end;

procedure TFormPrint.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
  if e.Message = 'Cannot focus a disabled or invisible window' then
    exit
  else
    MessageBox(GetActiveWindow ,PChar('ÀË´ú¨ìµ{§Ç¦b°õ¦æ¤¤µo¥Í¿ù»~!!'+
                   #13+#13+'¿ù»~«H®§: '+e.Message),'Error',MB_SYSTEMMODAL+MB_OK+MB_ICONERROR) ;
end;

procedure TFormPrint.ButtonTestClick(Sender: TObject);
begin
  if UpperCase(File_Type)='.LBL' then
  begin
    SetLabelValue(LabelVariable,'0123456789ABC') ;    //³]¸m¥´¦L¤º®e
    LVMenuPrint(TreeView1);
  end else if UpperCase(File_Type)='.LAB' then
  begin
    m_CodeSoft.AssignPrintData('SN','0123456789ABC');
    m_CodeSoft.Print(1);
  end;
end;

function TFormPrint.LVMenuClick(hTreeView : TTreeView ; MenuStr : string) : Boolean ;
var
  i : Integer ;
  TreeData : Integer ;
begin
  for i := 0 to hTreeView.Items.Count - 1 do
  begin
    if Copy(hTreeView.Items[i].Text,1,Length(MenuStr))= MenuStr then
    begin
      BanPrintDlage := False ;
      TreeData := Integer(hTreeView.Items[i].Data) ;
      PostMessage(hLVHandle,WM_COMMAND ,TreeData,0);
      Result := True ;
      BanPrintDlage := True ;
      Break ;
    end else Result := False ;
  end;
end;

function TFormPrint.LVMenuPrint(hTreeView : TTreeView ; PrintQty : Integer = 1) : Boolean ;       //; MenuStr : string
var
  i,ii : Integer ;
  TreeData : Integer ;
  LvPrintDlg, LvPrintHWND, LvCloseHWND : THandle ;
  ntPost : Boolean ;
begin
  FormInfo.Show ;
  BanPrintDlage := False ;
  ntPost := PostMessage(hLVHandle,WM_COMMAND ,1600,0);   //¸g¹L¬d§äµo²{¥´¦L«ö¶sªº­È¬O1600,©Ò¥Hª½±µµo°e¹L¥h
  if not ntPost then
  begin
    Result := False ;
    BanPrintDlage := True ;
    Exit ;
  end;

  Delay(100);
  //ÂIÀ»¥´¦L«ö¶s
  LvPrintDlg := FindWindow('#32770','§Ö³t¥´¦L');  //Button   ¥´¦L(&P)
  if LvPrintDlg <= 0 then
    LvPrintDlg := FindWindow('#32770','Quick Printing');  //Button   ¥´¦L(&P)

  MoveWindow(LvPrintDlg, -100, -100, 100, 100, True);      //Screen.Height - 100

  LvPrintHWND := FindWindowEx(LvPrintDlg ,0,'Button','¥´¦L(&P)');
  if LvPrintHWND <= 0 then
    LvPrintHWND := FindWindowEx(LvPrintDlg ,0,'Button','&Print');

  if  LvPrintHWND > 0 then
  begin
    for ii:= 1 to  PrintQty  do
    begin
      PostMessage(LvPrintHWND ,  WM_LBUTTONDOWN, 0, 0);
      PostMessage(LvPrintHWND ,  WM_LBUTTONUP, 0, 0);
    end;
    LvCloseHWND := FindWindowEx(LvPrintDlg ,0,'Button','Ãö³¬(&P)');
    if LvCloseHWND <=0 then
      LvCloseHWND := FindWindowEx(LvPrintDlg ,0,'Button','&Close');

    PostMessage(LvCloseHWND ,  WM_LBUTTONDOWN, 0, 0);
    PostMessage(LvCloseHWND ,  WM_LBUTTONUP, 0, 0);
    
    Delay(20);
    PostMessage(hLVHandle,WM_SYSCOMMAND,SC_RESTORE,0);        //SC_MAXIMIZE

    Delay(120);
    LabelApp.Visible := not LabelApp.Visible ;
    Result := True ;
  end  else Result := False ;
  BanPrintDlage := True ;

  //´`Àô¬d§ä¥´¦L«ö¶s
  {for i := 0 to hTreeView.Items.Count - 1 do
  begin
    if (Copy(hTreeView.Items[i].Text,1,6)= '&Print') or
       (Copy(hTreeView.Items[i].Text,1,8)='¦C¦L[&P]') then
    begin
      BanPrintDlage := False ;
      TreeData := Integer(hTreeView.Items[i].Data) ;
      PostMessage(hLVHandle,WM_COMMAND ,TreeData,0);
      Delay(150);

      //ÂIÀ»¥´¦L«ö¶s
      LvPrintDlg := FindWindow('#32770','§Ö³t¥´¦L');  //Button   ¥´¦L(&P)
      if LvPrintDlg <= 0 then
        LvPrintDlg := FindWindow('#32770','Quick Printing');  //Button   ¥´¦L(&P)

      MoveWindow(LvPrintDlg, -100, -100, 100, 100, True);      //Screen.Height - 100

      LvPrintHWND := FindWindowEx(LvPrintDlg ,0,'Button','¥´¦L(&P)');
      if LvPrintHWND <= 0 then
        LvPrintHWND := FindWindowEx(LvPrintDlg ,0,'Button','&Print');

      if  LvPrintHWND > 0 then
      begin
        PostMessage(LvPrintHWND ,  WM_LBUTTONDOWN, 0, 0);
        PostMessage(LvPrintHWND ,  WM_LBUTTONUP, 0, 0);

        LvCloseHWND := FindWindowEx(LvPrintDlg ,0,'Button','Ãö³¬(&P)');
        if LvCloseHWND <=0 then
          LvCloseHWND := FindWindowEx(LvPrintDlg ,0,'Button','&Close');

        PostMessage(LvCloseHWND ,  WM_LBUTTONDOWN, 0, 0);
        PostMessage(LvCloseHWND ,  WM_LBUTTONUP, 0, 0);
        PostMessage(hLVHandle,WM_SYSCOMMAND,SC_RESTORE,0);        //SC_MAXIMIZE

        Delay(100);
        LabelApp.Visible := not LabelApp.Visible ;
        Result := True ;
      end else Result := False ;
      BanPrintDlage := True ;
      Break ;
    end else Result := False ;
  end;}
  FormInfo.Close ;
end;

procedure TFormPrint.DisibleSaveAs ;
var
  hWnd, CunChu : THandle;
  ComBox, Toolbar :THandle ;
  LeiXing : THandle ;
begin
  hWnd := FindWindow('#32770','¥t¦s·sÀÉ');
  if hWnd <= 0  then Exit ;
  ComBox := FindWindowEx(hWnd,0,'ComboBox',nil);
  EnableWindow(ComBox ,false);
  LeiXing := FindWindowEx(hWnd,ComBox,'ComboBox',nil);
  EnableWindow( LeiXing,false);
  Toolbar := FindWindowEx(hWnd,0,'ToolbarWindow32',nil);
  EnableWindow(Toolbar,false);
  CunChu := FindWindowEx(hWnd,0,'Button','Àx¦s(&S)');
  EnableWindow(CunChu ,false);
end;

procedure TFormPrint.ButtonLockedClick(Sender: TObject);
begin
  m_CodeSoft.LockedCS(not m_CodeSoft.GetLockedCS) ;
  if  m_CodeSoft.GetLockedCS then
    (Sender as TButton ).Caption := 'CS Locked'
  else
    (Sender as TButton ).Caption := 'CS UnLocked';
end;

procedure TFormPrint.TimerDisibleSaveAsTimer(Sender: TObject);
begin
  DisibleSaveAs ;
end;

end.
