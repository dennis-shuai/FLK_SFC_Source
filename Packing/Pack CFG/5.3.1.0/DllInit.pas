unit DllInit;

interface

uses uData,classes, extctrls, Controls, Forms, SConnect, SysUtils, IniFiles;

procedure InitSajetDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection; providerQuery, providerSproc:string); stdcall; export;
procedure CloseSajetDll; stdcall; export;

implementation

procedure LoadImage;
var pIni: TIniFile; sImage: String;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('Packing', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    fData.Imagemain.Picture.LoadFromFile(sImage);
end;

procedure CloseSajetDll;
begin
  try
    if assigned(fData) then begin
      FreeAndNil(fData);
//      fData.Release;
    end;
  except
//    on E:Exception do raise Exception.create('(CloseSajetDll)'+E.Message);
  end;
end;

procedure InitSajetDll(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection;providerQuery,providerSproc:string);
begin
  try
    CloseSajetDll;
    fData := TfData.Create(nil);
    With fData do
    begin
      ParentWindow := SenderParent.Handle;
      Align := alClient;
      BorderStyle := bsNone;
      LoadImage;
      G_sockConnection:=parentSocketConnection;
      QryData.RemoteServer := G_sockConnection;
      QryData.ProviderName := 'DspQryData';
      QryTemp.RemoteServer := G_sockConnection;
      QryTemp.ProviderName := 'DspQryTemp1';
      SProc.RemoteServer := G_sockConnection;
      SProc.ProviderName := 'DspStoreproc';  
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
