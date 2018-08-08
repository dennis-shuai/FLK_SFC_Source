unit DllInit;

interface

uses uDllLocateform, classes, extctrls, Controls, Forms, SConnect, SysUtils;

procedure InitSajetDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String; parentSocketConnection : TSocketConnection; providerQuery, providerSproc : string); stdcall; export;
procedure CloseSajetDll; stdcall; export;

var FormEnabled : Boolean;

implementation

procedure CloseSajetDll;
begin
  try
    if fDllLocateForm <> nil then begin
      fDllLocateForm.free;
      fDllLocateForm := nil;
    end;
  except
    on E:Exception do raise Exception.create('(CloseSajetDll)'+E.Message);
  end;
end;

procedure InitSajetDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection;providerQuery,providerSproc:string);
begin
  try
    CloseSajetDll;
    fDllLocateForm := TfDllLocateForm.Create(nil);
    With fDllLocateForm do
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

end.
