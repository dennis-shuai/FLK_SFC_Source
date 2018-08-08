unit uExceptionInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls;

type
  TErrorForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Edit1: TEdit;
    Memo1: TMemo;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  PKBDLLHOOKSTRUCT   =   ^KBDLLHOOKSTRUCT;
  tagKBDLLHOOKSTRUCT   =   packed   record
  //KBDLLHOOKSTRUCT = record
    vkCode:   DWORD;//????
    scanCode:   DWORD;//????(????)
    flags:   DWORD;
    time:   DWORD;//?????
    dwExtraInfo:   DWORD;//??????????
  end ;

KBDLLHOOKSTRUCT  =  tagKBDLLHOOKSTRUCT;

const
  //APP ICON
  IDI_APPICON = 10010;
  // Class Name
  IDS_CLASSNAME = 'Exception Information';
 //Global文件映射名
  IDS_KEYMAPNAME = IDS_CLASSNAME;
  //發送消息到主window
  WM_KEYMESSAGE = WM_USER + 1001;
  //底層Keyboard hookid
  WH_KEYBOARD_LL = 13;
  //底層Mouse hookid
  WM_MOUSE_LL = 14;

  LLKHF_ALTDOWN   =   $20;

//const   WH_KEYBOARD_LL   =   13;
//const   LLKHF_ALTDOWN   =   $20;

var
  ErrorForm: TErrorForm;
  CloseForm : boolean;
  KeybordHookNext: HHook;

implementation

uses uFormPrint;

{$R *.dfm}

function KeyHookProc(nCode : Integer;wParam : WPARAM ;lParam : LPARAM ):LRESULT ;stdcall;
var 
  fEatKeystroke:  BOOL;
  P:   PKBDLLHOOKSTRUCT;
begin
  Result   :=   0;
  fEatKeystroke   :=   FALSE;
  P   :=   PKBDLLHOOKSTRUCT (lParam);
  //nCode??HC_ACTION???WParam?LParam?????????
  if (nCode = HC_ACTION) then
  begin
      //????????????Ctrl+Esc?Alt+Tab??Alt+Esc????
      case wParam of
          WM_KEYDOWN,
          WM_SYSKEYDOWN,
          WM_KEYUP,
          WM_SYSKEYUP:
              fEatKeystroke   :=
              ((p.vkCode = VK_TAB) and ((p.flags and LLKHF_ALTDOWN) <> 0)) or   //   Alt+Tab
              ((p.vkCode = VK_ESCAPE) and ((p.flags and LLKHF_ALTDOWN)   <>   0))or   //   Alt+ESC
              (p.vkCode = VK_Lwin) or (p.vkCode = VK_Rwin) or (p.vkCode = VK_apps) or     //?????WIN??
              (p.vkCode = LLKHF_ALTDOWN ) or (p.vkCode = KF_ALTDOWN ) or
              ((p.vkCode = VK_CONTROL) and (P.vkCode = LLKHF_ALTDOWN) and (P.vkCode = VK_Delete)) or  //Ctrl+Alt+Delete
              ((p.vkCode = VK_ESCAPE) and ((GetKeyState(VK_CONTROL) and $8000) <> 0)) or     // Ctrl+Esc
              ((p.vkCode = VK_F4) and ((p.flags and LLKHF_ALTDOWN) <> 0)) or      //Alt+F4
              ((p.vkCode = VK_SPACE) and ((p.flags and LLKHF_ALTDOWN) <> 0)) or     //Alt+'   '
              ((p.vkCode = VK_CONTROL) and ((p.flags and LLKHF_ALTDOWN) <> 0)) or    //CTRL+'   '
              (((p.vkCode = VK_CONTROL) and (P.vkCode = LLKHF_ALTDOWN and p.flags) and (P.vkCode = VK_Delete)))   //AND   (p.flags   =   true)   ;
      end;
  end;

  if fEatKeystroke = True then
      Result := 1;
  if nCode <> 0 then
      Result := CallNextHookEx(KeybordHookNext,   nCode,   wParam,   lParam);
end;

//開始KeyHOOK
function StartKeyHook : BOOL;
  function GetSystemPath : string;
    var
      WinDir:  array[0..MAX_PATH]   of   char;       //   holds   the   Windows   directory
  begin
      GetWindowsDirectory(WinDir,   MAX_PATH);
      Result := StrPas(WinDir)
  end;
//var Handle : THandle ;
begin
  //設置 全局HOOK                 這裡不知為什麼用WH_KEYBOARD會重複記錄兩次
  //用WH_JOURNALRECORD，如果按Win鍵就UnHook了。    WH_JOURNALRECORD     WH_keyboard
  KeybordHookNext := SetWindowsHookEx(WH_KEYBOARD_LL, @KeyHookProc, hInstance, 0);
  Result := KeybordHookNext <> 0;
  if Result then
  begin
     FileOpen(GetSystemPath()+'\\system32\\Taskmgr.exe',fmOpenWrite);
  end // if Result then
  else
    MessageBox(GetActiveWindow,
    IDS_KEYMAPNAME + ': Create a HookNext hook handle failed',  IDS_KEYMAPNAME, MB_ICONHAND or MB_OK +MB_SYSTEMMODAL);
end;

function StopKeyHook: Bool;
begin
  Result := False;
  //卸載HOOK
  if KeybordHookNext <> 0 then  begin
    Result := UnhookWindowsHookEx(KeybordHookNext);
    KeybordHookNext := 0;
  end;
end;

procedure TErrorForm.FormShow(Sender: TObject);
begin
    Self.Height :=Screen.Height ;
    Self.Width :=Screen.Width ;

    Self.Top := Round((Screen.Height -Self.Height )/2);
    Self.Left := Round((Screen.Width -Self.Width )/2);

    Label1.Left :=Round((Screen.Width -Label1.Width )/2);
    Label2.Left :=Round((Screen.Width -Label2.Width )/2);
    Label4.Left :=Round((Screen.Width -Label2.Width )/2);
    Memo1.Left := Round((Screen.Width -Memo1.Width )/2);

    Label1.Top :=Round((Screen.Height -(Label1.Height+200 +Label2.Height+200+Memo1.Height))/2);
    Label2.Top :=Label1.Top +50;
    Label4.Top :=Label2.Top +50;
    Memo1.Top := Label4.Top +100;

    Label3.Left :=Round((Self.Width -(Label3.Width +Edit1.Width +10))/2);
    Edit1.Left :=Label3.Left + Label3.Width +10 ;

    Label3.Top := Memo1.Top+ Memo1.Height+20;
    Edit1.Top :=Memo1.Top + Memo1.Height+20;

    CloseForm := false ;
end;

procedure TErrorForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i : Integer ;
begin
    if (CloseForm) then
    begin
        StopKeyHook ;     //卸載鉤子
        //LOCK_SN := '' ;
        if  Pos(Memo1.Text,'檢測到LabelView或CodeSoft打印程序雙開')>0 then
        begin
            if (FormPrint.LVProcess.Items.Count >0) then
            begin
                {for  i := 1 to FormPrint.ListBoxProcessID.Count -1 do
                    FormPrint.KillProcess(StrToInt(FormPrint.ListBoxProcessID.Items.Strings[i]));}
                for i :=  0 to FormPrint.LVProcess.Items.Count - 1 do
                  if FormPrint.LVProcess.Items.Item[i].SubItems[3] = 'Y' then
                     FormPrint.KillProcess(StrToInt(FormPrint.LVProcess.Items.Item[i].SubItems[0]));
            end ;
        end ;
        FormPrint.TimerDbLVCheck.Enabled := True ;
        Action := caFree ;
        //FreeAndNil(ErrorForm) ;
    end else
    begin
        Action := caNone ;
    end
end;

procedure TErrorForm.FormCreate(Sender: TObject);
begin
  SetWindowPos(Handle ,HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE);
  StartKeyHook ;
end;

procedure TErrorForm.FormDblClick(Sender: TObject);
begin
  CloseForm := true;
  Close ;
end;

end.
