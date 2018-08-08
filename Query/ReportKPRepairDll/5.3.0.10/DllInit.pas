unit DllInit;

interface

uses uDllform, uDetail, classes, extctrls, Controls, Forms, SConnect, SysUtils;

procedure InitSajetParamDll(SenderOwner: TForm; ParentApplication: TApplication; UserID, sCaption: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc, gsParam: string); stdcall; export;
function CloseSajetDll: LongInt; stdcall; export;
function ActiveForm: LongInt; StdCall; export;
function MinimizeForm: LongInt; StdCall; export;

implementation

function MinimizeForm: LongInt; stdcall;
begin
  if assigned(fDllForm) then
    fDllForm.WindowState := wsMinimized;
  Result := 0;
end;

function ActiveForm: LongInt; stdcall;
begin
  if assigned(fDllForm) then
  begin
    fDllForm.SetFocus;
    fDllForm.BringToFront;
    if fDllForm.WindowState = wsMinimized then
      fDllForm.WindowState := wsNormal;
  end;
  Result := 0;
end;

function CloseSajetDll: LongInt; StdCall;
begin
  try
    if assigned(fDllForm) then begin
      FreeAndNil(fDllForm);
      fDllForm.Release;
    end;
    Result := 0;
  except
    on E: Exception do raise Exception.create('(CloseSajetDll)' + E.Message);
  end;
end;

procedure InitSajetParamDll(SenderOwner: TForm; ParentApplication: TApplication; UserID, sCaption: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc, gsParam: string);
begin
  try
    Application := ParentApplication;

    fDllForm := TfDllForm.Create(nil);
    with fDllForm do
    begin
      MyParentForm := SenderOwner;
      MyParentApplication := ParentApplication;
      G_sockConnection := parentSocketConnection;
      Caption := sCaption;
      if UserID = 'Steven&Jack&Tommy' then
        UpdateUserID := '0'
      else
        UpdateUserID := UserID;
      RPID := gsParam;
      LoadImage;
      fDetail := TfDetail.Create(fDllForm);
      With fDetail do
      begin
        Parent := fDllForm;
        Align := alClient;
        BorderStyle := bsNone;
        ImageTitle.Picture := Imagemain.Picture;
        UpdateUserID := fDllForm.UpdateUserID;
        RPID := fDllForm.RPID;
        SocketConnection1 := parentSocketConnection;
        QryData.RemoteServer := G_sockConnection;
        QryTemp.RemoteServer := G_sockConnection;
        QryTemp2.RemoteServer := G_sockConnection;
        Show;
      end;
      Show;
    end;

  except
    on E: Exception do raise Exception.create('(InitSajetParamDll)' + E.Message);
  end;
end;

end.

