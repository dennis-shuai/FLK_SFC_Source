unit DllInit;

interface

uses uDllform, classes, extctrls, Controls, Forms, SConnect, SysUtils, uLang;

procedure InitSajetDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection; FunctionName, providerSproc, Params : string; GLang : TLanguage ); stdcall; export;
procedure CloseSajetDll; stdcall; export;

implementation

procedure CloseSajetDll;
begin
  try
    if fDllform<>nil then begin
      fDllform.free;
      fDllform:=nil;
    end;
  except
    on E:Exception do raise Exception.create('(CloseSajetDll)'+E.Message);
  end;
end;

procedure InitSajetDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection; FunctionName, providerSproc, Params : string; GLang : TLanguage );
begin
  try
    CloseSajetDll;
    fDllform := TfDllform.Create(nil);
    With fDllform do
    begin
      ParentWindow := SenderParent.Handle;
      Align := alClient;
      BorderStyle := bsNone;
      G_sockConnection:=parentSocketConnection;
      G_FunctionName := FunctionName;
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
