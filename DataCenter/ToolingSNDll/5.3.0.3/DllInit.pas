unit DllInit;

interface

uses uDllform, classes, extctrls, Controls, Forms, SConnect, SysUtils;

procedure InitSajetDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection; providerQuery, providerSproc:string); stdcall; export;
procedure CloseSajetDll; stdcall; export;

implementation

procedure CloseSajetDll;
begin
  try
    if fDllForm<>nil then begin
      fDllForm.free;
      fDllForm:=nil;
    end;
  except
    on E:Exception do raise Exception.create('(CloseSajetDll)'+E.Message);
  end;
end;

procedure InitSajetDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection;providerQuery,providerSproc:string);
begin
  try
    CloseSajetDll;

    fDllForm := TfDllForm.Create(nil);
    With fDllForm do
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
