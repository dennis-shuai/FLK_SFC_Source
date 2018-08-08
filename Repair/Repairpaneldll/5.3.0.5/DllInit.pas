unit DllInit;

interface

uses uDllform, classes, extctrls, Controls, Forms, SConnect, SysUtils;

procedure InitSajetDll(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc: string); stdcall; export;
procedure CloseSajetDll; stdcall; export;

implementation

procedure CloseSajetDll;
begin
  try
    if fDllMain <> nil then
    begin
      fDllMain.free;
      fDllMain := nil;
    end;
  except
    on E: Exception do raise Exception.create('(CloseSajetDll)' + E.Message);
  end;
end;

procedure InitSajetDll(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc: string);
begin
  try
    CloseSajetDll;
    fDllMain := TfDllMain.Create(nil);
    with fDllMain do
    begin
      ParentWindow := SenderParent.Handle;
      Align := alClient;
      BorderStyle := bsNone;
      G_sockConnection := parentSocketConnection;
      if UserID = 'Steven&Jack&Tommy' then
        UpdateUserID := '0'
      else
        UpdateUserID := UserID;
      Show;
    end;
  except
    on E: Exception do raise Exception.create('(InitSajetDll)' + E.Message);
  end;
end;

end.

