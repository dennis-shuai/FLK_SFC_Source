unit DllInit;

interface

uses uMainForm, classes, extctrls, Controls, Forms, SConnect, SysUtils;

procedure InitSajetDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection; providerQuery, providerSproc:string); stdcall; export;
procedure CloseSajetDll; stdcall; export;
procedure ResizeWindows(high,width:integer); stdcall; export;

implementation

procedure CloseSajetDll;
begin
  try
    if fMainForm<>nil then begin
      fMainForm.free;
      fMainForm:=nil;
    end;
  except
    on E:Exception do raise Exception.create('(CloseSajetDll)'+E.Message);
  end;
end;

procedure InitSajetDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection;providerQuery,providerSproc:string);
begin
  try
    //CloseSajetDll;
    fMainForm := TfMainForm.Create(nil);
    With fMainForm do
    begin
      ParentWindow := SenderParent.Handle;
      Align := alClient;
      BorderStyle := bsNone;
      If UserID = 'Steven&Jack&Tommy' Then
        UpdateUserID := '0'
      Else
        UpdateUserID := UserID;
      QryData.RemoteServer := parentSocketConnection;
      QryData.ProviderName := 'DspQryData';
      QryTemp.RemoteServer := parentSocketConnection;
      QryTemp.ProviderName := 'DspQryTemp1';
      Show;
      ResizeForm(SenderOwner.Height,SenderOwner.Width);
    end;
  except
    on E:Exception do raise Exception.create('(InitSajetDll)'+E.Message);
  end;
end;

procedure ResizeWindows(high,width:integer);
begin
  Try
    fMainForm.ResizeForm(high,width);
  except
  end;
end;

end.
