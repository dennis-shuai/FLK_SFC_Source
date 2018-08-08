unit tDllInit;

interface

uses tuDllform, classes, extctrls, Controls, Forms, SConnect, SysUtils;

procedure InitSajetDll(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc: string); stdcall; export;
procedure InitSajetParamDll(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc, gsParam: string); stdcall; export;
procedure CloseSajetDll; stdcall; export;

implementation

procedure CloseSajetDll;
begin
  try
    if fDllForm <> nil then
    begin
      fDllForm.free;
      fDllForm := nil;
    end;
  except
    on E: Exception do raise Exception.create('(CloseSajetDll)' + E.Message);
  end;
end;

procedure InitSajetParamDll(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc, gsParam: string);
begin
  try
    CloseSajetDll;

    fDllForm := TfDllForm.Create(nil);
    with fDllForm do
    begin
      ParentWindow := SenderParent.Handle;
      //Align := alClient;
      BorderStyle := bsNone;
      G_sockConnection := parentSocketConnection;
      if UserID = 'Steven&Jack&Tommy' then
        UpdateUserID := '0'
      else
        UpdateUserID := UserID;
      gsSN := gsParam;
      Show;
    end;

  except
    on E: Exception do raise Exception.create('(InitSajetDll)' + E.Message);
  end;
end;

procedure InitSajetDll(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc: string);
begin
  try
    CloseSajetDll;

    fDllForm := TfDllForm.Create(nil);
    with fDllForm do
    begin
      ParentWindow := SenderParent.Handle;
      Align := alClient;
      BorderStyle := bsNone;
      G_sockConnection := parentSocketConnection;
      if UserID = 'Steven&Jack&Tommy' then
        UpdateUserID := '0'
      else
        UpdateUserID := UserID;
      gsSN := '';
      Show;
    end;

  except
    on E: Exception do raise Exception.create('(InitSajetDll)' + E.Message);
  end;
end;

end.

