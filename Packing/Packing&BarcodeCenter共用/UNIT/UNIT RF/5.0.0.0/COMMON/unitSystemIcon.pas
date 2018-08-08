unit unitSystemIcon;

interface

uses SysUtils,Classes,Messages,windows,shellAPI,Menus,controls,forms,dialogs;

const WM_TRAYICON=WM_APP+0;

type
  TTrayIcon = class(TForm)
  private
    PopupMenu : TPopupMenu;
    mmClose : Tmenuitem;
    mmShow : Tmenuitem;
    procedure modifyTrayIcon(Action : Dword);

    procedure mmShowClick(Sender: TObject);
    procedure mmCloseClick(Sender: TObject);
  public
    procedure WMTrayIcon(var message : TMessage) ; message WM_TRAYICON;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy ; override;
    procedure test;
  end;

  var TrayIcon : TTrayIcon;
implementation
uses unitMain;


procedure TTrayIcon.test;
begin
  PopupMenu.Popup(mouse.CursorPos.x,mouse.CursorPos.y);
end;


procedure TTrayIcon.mmShowClick(Sender: TObject);
begin
  showmessage('show');
end;

procedure TTrayIcon.mmCloseClick(Sender: TObject);
begin
  showmessage('close');
end;

constructor TTrayIcon.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  PopupMenu:=TPopupMenu.Create(self);
  mmShow:=TMenuItem.Create(self);
  mmShow.Caption:='Show';
  mmShow.OnClick:=mmShowClick;
  mmClose:=TMenuItem.Create(self);
  mmClose.Caption:='Close';
  mmClose.OnClick:=mmCloseClick;
  PopupMenu.Items.Add(mmShow);
  PopupMenu.Items.Add(mmclose);
  modifyTrayIcon(NIM_ADD);
end;

destructor TTrayIcon.Destroy ;
begin
  modifyTrayIcon(NIM_DELETE);
  mmShow.Free;
  mmClose.free;
  PopupMenu.Free;
  inherited Destroy;
end;


procedure TTrayIcon.WMTrayIcon(var message : TMessage);
begin
  case message.LParam of
    WM_LBUTTONDBLCLK :
    begin
      if not Application.ShowMainForm then begin
        Application.ShowMainForm:=true;
        Application.MainForm.Visible:=Application.ShowMainForm;
        ShowWindow(Application.Handle,SW_SHOW);
      end;

      ShowWindow(Application.Handle,Sw_restore);
      SetForegroundWindow(Application.Handle);

    end;
    WM_RBUTTONDOWN : PopupMenu.Popup(mouse .CursorPos.x,mouse.CursorPos.y);
    else begin
    end;
  end;
end;


procedure TTrayIcon.modifyTrayIcon(Action : Dword);
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


end.
