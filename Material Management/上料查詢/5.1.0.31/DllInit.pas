unit DllInit;

interface

uses uDllform, classes, extctrls, Controls, Forms, SConnect, SysUtils,unitHeadSajet;

procedure InitSajetDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection; providerQuery, providerSproc:string); stdcall; export;
//procedure InitSajetQueryDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection;providerQuery,providerSproc:string; Parameter : String); stdcall; export;
procedure CloseSajetDll; stdcall; export;
//procedure AssignCBFunction(f_onTransData: TOnTransDataToApplication);stdcall; export;
procedure ResizeWindows(high,width:integer); stdcall; export;
var
  G_onTransDataToApplication : TOnTransDataToApplication;


implementation

procedure ResizeWindows(high,width:integer);
begin
  try
    fDllMain.ResizeForm(high,width);
  except
  end;
end;

procedure CloseSajetDll;
begin
  try
    if fDllMain<>nil then begin
      fDllMain.free;
      fDllMain:=nil;
    end;
  except
    on E:Exception do raise Exception.create('(CloseSajetDll)'+E.Message);
  end;
end;

procedure InitSajetDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection;providerQuery,providerSproc:string);
//procedure InitSajetQueryDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection;providerQuery,providerSproc:string; Parameter : String); stdcall; export;
begin
  try
    CloseSajetDll;
    fDllMain := TfDllMain.Create(nil);
    With fDllMain do
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

{procedure AssignCBFunction(f_onTransData: TOnTransDataToApplication);stdcall;
begin
  G_onTransDataToApplication:=f_onTransData;
end;
    }

end.
