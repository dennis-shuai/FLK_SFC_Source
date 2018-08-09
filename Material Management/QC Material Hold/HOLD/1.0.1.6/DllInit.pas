unit DllInit;

interface

uses uDllform, classes, extctrls, Controls, Forms, SConnect, SysUtils, unitHeadSajet;

procedure InitSajetDll(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc: string); stdcall; export;
procedure CloseSajetDll; stdcall; export;
procedure AssignCBFunction(f_onTransData: TOnTransDataToApplication);stdcall; export;

var
  G_onTransDataToApplication : TOnTransDataToApplication;

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
      Show;
    end;
  except
    on E: Exception do raise Exception.create('(InitSajetDll)' + E.Message);
  end;
end;

procedure AssignCBFunction(f_onTransData: TOnTransDataToApplication);stdcall;
begin
  G_onTransDataToApplication:=f_onTransData;
end;

end.

