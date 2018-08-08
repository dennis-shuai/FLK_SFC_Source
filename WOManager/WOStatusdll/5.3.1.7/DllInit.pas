unit DllInit;

interface

uses uData,classes, extctrls, Controls, Forms, SConnect, SysUtils;

procedure InitSajetParamDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection; providerQuery, providerSproc, gsParam: String); stdcall; export;
procedure CloseSajetDll; stdcall; export;

implementation

procedure CloseSajetDll;
begin
  try
    if fData<>nil then begin
      fData.free;
      fData:=nil;
    end;
  except
    on E:Exception do raise Exception.create('(CloseSajetDll)'+E.Message);
  end;
end;

procedure InitSajetParamDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection;providerQuery,providerSproc, gsParam: String);
begin
  try
    CloseSajetDll;
    fData := TfData.Create(nil);
    With fData do
    begin
      G_sockConnection:=parentSocketConnection;
      QryData.RemoteServer := G_sockConnection;
      QryData.ProviderName := 'DspQryData';
      QryTemp.RemoteServer := G_sockConnection;
      QryTemp.ProviderName := 'DspQryTemp1';
      SProc.RemoteServer := G_sockConnection;
      SProc.ProviderName := 'DspStoreproc';

      ChangeWOType := gsParam;
      If UserID = 'Steven&Jack&Tommy' Then
        UpdateUserID := '0'
      Else
        UpdateUserID := UserID;
      Showmodal;
    end;
  except
    on E:Exception do raise Exception.create('(InitSajetDll)'+E.Message);
  end;
end;

end.
