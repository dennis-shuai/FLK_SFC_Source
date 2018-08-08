unit DllInit;

interface

uses uDllform, classes, extctrls, Controls, Forms, SConnect, SysUtils;

procedure InitSajetParamDll(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc, Param: string); stdcall; export;
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

procedure InitSajetParamDll(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc, Param: string);
begin
  try
    CloseSajetDll;
    fDllForm := TfDllForm.Create(nil);
    with fDllForm do
    begin
      ParentWindow := SenderParent.Handle;
      Align := alClient;
      BorderStyle := bsNone;
      gsParam := Param;
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
