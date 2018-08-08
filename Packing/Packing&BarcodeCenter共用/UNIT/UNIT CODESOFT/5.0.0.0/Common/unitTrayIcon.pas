unit unitTrayIcon;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus,shellAPI;

const WM_TRAYICON=WM_APP+0;

type
  TformTrayIcon = class(TForm)
    ppMenu: TPopupMenu;
    mmShow: TMenuItem;
    mmClose: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure mmCloseClick(Sender: TObject);
    procedure mmShowClick(Sender: TObject);
  private
    { Private declarations }
    procedure WMTrayIcon(var Msg : TMessage);message WM_TRAYICON;
    procedure modifyTrayIcon(Action : Dword);
  public
    { Public declarations }
    procedure HideMainForm;
  end;

implementation

{$R *.dfm}

procedure TformTrayIcon.HideMainForm;
begin
  Application.ShowMainForm:=false;
  Application.MainForm.Visible:=Application.ShowMainForm;
  ShowWindow(Application.Handle,SW_HIDE);
end;

procedure TformTrayIcon.WMTrayIcon(var Msg : TMessage);
begin
  case Msg.LParam of
    WM_LBUTTONDBLCLK : mmShowClick(mmShow);
    WM_RBUTTONDOWN : ppMenu.Popup(mouse .CursorPos.x,mouse.CursorPos.y);
    else begin
    end;
  end;
end;


procedure TformTrayIcon.modifyTrayIcon(Action : Dword);
var  NIData : TNotifyIconData;
begin
  with NIData do begin
    cbSize:=sizeof(TNotifyIconData);
    uID:=0;
    uFlags:=NIF_MESSAGE or NIF_ICON or NIF_TIP;
    wnd:= Handle;
    uCallbackMessage:=WM_TRAYICON;

    hIcon:=Application.Icon.Handle;
    StrPCopy(szTip,Application.Title);
  end;
  Shell_NotifyIcon(Action,@NIData);
end;


procedure TformTrayIcon.FormCreate(Sender: TObject);
begin
  modifyTrayIcon(NIM_ADD);
end;

procedure TformTrayIcon.FormDestroy(Sender: TObject);
begin
  modifyTrayIcon(NIM_DELETE);
end;

procedure TformTrayIcon.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose:=false;
  Self.Visible:=false;
end;

procedure TformTrayIcon.mmCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TformTrayIcon.mmShowClick(Sender: TObject);
begin
  if not Application.ShowMainForm then begin
    Application.ShowMainForm:=true;
    Application.MainForm.Visible:=Application.ShowMainForm;
    ShowWindow(Application.Handle,SW_SHOW);
  end;

  ShowWindow(Application.Handle,Sw_restore);
  SetForegroundWindow(Application.Handle);
end;

end.
