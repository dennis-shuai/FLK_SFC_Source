unit DllInit;

interface

uses uDllform, classes, extctrls, Controls, Forms, SConnect, SysUtils,unitHeadSajet,dialogs;

procedure InitSajetDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection; providerQuery, providerSproc:string); stdcall; export;
procedure CloseSajetDll; stdcall; export;
procedure AssignCBFunction(f_onTransData: TOnTransDataToApplication);stdcall; export;

var
  G_onTransDataToApplication : TOnTransDataToApplication;


implementation

procedure CloseSajetDll;
begin
  try
    if fDllReprintLabel<>nil then begin
      fDllReprintLabel.Close;
      fDllReprintLabel.free;
      fDllReprintLabel:=nil;
    end;
  except
    on E:Exception do raise Exception.create('(CloseSajetDll)'+E.Message);
  end;
end;

procedure InitSajetDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection;providerQuery,providerSproc:string);
begin
  try
    CloseSajetDll;

    fDllReprintLabel := TfDllReprintLabel.Create(nil);
    With fDllReprintLabel do
    begin
      ParentWindow := SenderParent.Handle;
      Align := alClient;
      BorderStyle := bsNone;
      G_sockConnection:=parentSocketConnection;
      If UserID = 'Steven&Jack&Tommy' Then
        UpdateUserID := '0'
      Else
        UpdateUserID := UserID;
      Show;
    end;

  except
    on E:Exception do raise Exception.create('(InitSajetDll)'+E.Message);
  end;
end;

procedure AssignCBFunction(f_onTransData: TOnTransDataToApplication);stdcall;
begin
  G_onTransDataToApplication:=f_onTransData;
end;


end.
