unit DllInit;

interface

uses uDllform, classes, extctrls, Controls, Forms, SConnect, SysUtils, unitHeadSajet;

procedure InitSajetParamDll(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc, gsParam: string); stdcall; export;
procedure CloseSajetDll; stdcall; export;
procedure AssignCBFunction(f_onTransData: TOnTransDataToApplication); stdcall; export;

var
  G_onTransDataToApplication: TOnTransDataToApplication;


implementation

procedure CloseSajetDll;
begin
  try
    if fDllBCLabel <> nil then
    begin
      if fDllBCLabel.Showing then
        fDllBCLabel.Close;
      fDllBCLabel.free;
      fDllBCLabel := nil;
    end;
  except
    on E: Exception do raise Exception.create('(CloseSajetDll)' + E.Message);
  end;
end;

procedure InitSajetParamDll(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc, gsParam: string);
begin
  try
    CloseSajetDll;
    fDllBCLabel := TfDllBCLabel.Create(nil);
    with fDllBCLabel do
    begin
      ParentWindow := SenderParent.Handle;
      Align := alClient;
      BorderStyle := bsNone;
      G_sockConnection := parentSocketConnection;
      gsLabelType := gsParam;
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

procedure AssignCBFunction(f_onTransData: TOnTransDataToApplication); stdcall;
begin
  G_onTransDataToApplication := f_onTransData;
end;


end.

