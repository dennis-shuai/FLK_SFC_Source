unit uformMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, Menus, jpeg, StdCtrls, Db, DBClient, MConnect, SConnect,
  ObjBrkr, ToolWin, ComCtrls, ImgList, unitHeadSajet, unitConvert, unitCodeSoft, IniFiles;

type
  TInitSajetDll = procedure(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc: string); stdcall;
  TCloseSajetDll = procedure; stdcall;
  TInitSajetWOStatusDll = procedure(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc: string; WOStatus: string); stdcall;
  TAssignCBFunction = procedure(f_onTransData: TOnTransDataToApplication); stdcall;

  TformMain = class(TForm)
    SocketConnection1: TSocketConnection;
    csFTemp: TClientDataSet;
    SimpleObjectBroker1: TSimpleObjectBroker;
    PanelBotton: TPanel;
    panelFunction: TPanel;
    PanelParent: TPanel;
    Image1: TImage;
    PanelDisEmp: TPanel;
    Label22: TLabel;
    LabNo: TLabel;
    PageScroller1: TPageScroller;
    ToolBar1: TToolBar;
    LabName: TLabel;
    Splitter1: TSplitter;
    ImageList1: TImageList;
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ToolButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    m_sDLLName: string;
    m_DLLHandle: THandle;
    m_initialSajetDll: TInitSajetDll;
    m_closeSajetDll: TCloseSajetDll;
    m_initialSajetWOStatusDll: TInitSajetWOStatusDll;
    m_AssignCBFunction: TAssignCBFunction;
    m_codeSoft: TcodeSoft;
    procedure closeSajetDll;
    procedure loadSajetDll(f_sDllName: string);
    procedure LoadSajetWOStatusDll(f_sDllName: string; WOStatus: string);
  public
    { Public declarations }
    gsProgram: string;
    m_onTransDataToServer: TOnTransDataToApplication;
    MyParentApplication: TApplication;
    FormOwner: TForm;
    FormParent: TPanel;
    LoginUserID: string;
    G_tsDllName: TStrings;
    G_tsDllParam: TStrings;
    function LoadApServer: Boolean;

    procedure ChkAuthority(PrgName: string);
      //procedure TestButtonMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure PopupMenuItemsClick(Sender: TObject);
    procedure onRsvDataFromDll(f_pData: pchar; f_iLen: integer; f_onTransData: TOnTransData);
  end;

var
  formMain: TformMain;

implementation

{$R *.DFM}

procedure TformMain.onRsvDataFromDll(f_pData: pchar; f_iLen: integer; f_onTransData: TOnTransData);
var sData: string;
begin
  try
    sData := G_convertBufferToStr(f_pData, f_iLen);
    m_codeSoft.assignPrintData(sData);
    //m_codeSoft.Visibled:=TRUE;
  except
    on E: Exception do showmessage(E.Message);
  end;
end;

procedure TformMain.ChkAuthority(PrgName: string);
var I, j: Byte; mFunType: string;
  NewItem: TMenuItem;
  iIndex, iLength, udfClassCount: integer;
begin
  G_tsDllName.Clear;
  G_tsDllParam.Clear;
  with csFTemp do
  begin
    Close;
    if LoginUserID <> 'Steven&Jack&Tommy' then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      CommandText := 'Select C.FUN_TYPE_IDX,C.FUN_TYPE,C.FUN_IDX,C.FUNCTION,C.DLL_FILENAME,C.FUN_PARAM '
        + 'From SAJET.SYS_ROLE_PRIVILEGE A, '
        + '     SAJET.SYS_ROLE_EMP B, '
        + '     SAJET.SYS_PROGRAM_FUN C '
        + 'Where A.ROLE_ID = B.ROLE_ID '
        + 'and B.EMP_ID = :EMP_ID '
        + 'and A.PROGRAM = :PRG '
        + 'and A.PROGRAM = C.PROGRAM '
        + 'and A.FUNCTION = C.FUNCTION '
        + 'and C.FUN_IDX <> ''0'' '
        + 'Group By C.FUN_TYPE_IDX,C.FUN_TYPE,C.FUN_IDX,C.FUNCTION,C.DLL_FILENAME,C.FUN_PARAM '
        + 'Order By C.FUN_TYPE_IDX,C.FUN_IDX ';
      Params.ParamByName('EMP_ID').AsString := LoginUserID;
      Params.ParamByName('PRG').AsString := PrgName;
      Open;
    end
    else
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PRG', ptInput);
      CommandText := 'Select FUN_TYPE,FUNCTION,FUN_TYPE_IDX,FUN_IDX,DLL_FILENAME,C.FUN_PARAM ' +
        'From SAJET.SYS_PROGRAM_FUN ' +
        'Where PROGRAM = :PRG ' +
        'Group By FUN_TYPE_IDX,FUN_IDX,FUN_TYPE,FUNCTION,DLL_FILENAME,C.FUN_PARAM ' +
        'Order By FUN_TYPE_IDX,FUN_IDX ';
      Params.ParamByName('PRG').AsString := PrgName;
      Open;
    end;

    mFunType := '';
    udfClassCount := 0;
    iLength := 0;
    iIndex := 0;

    while not eof do
    begin
      if Fieldbyname('FUN_TYPE').AsString <> mFunType then
      begin
        inc(udfClassCount);
        with TToolButton.Create(ToolBar1) do
        begin
          ImageIndex := udfClassCount - 1;
          Parent := ToolBar1;
          Style := tbsDropDown;
          AutoSize := true;
          Left := iLength;
          Caption := Fieldbyname('FUN_TYPE').AsSTring;
          iLength := iLength + width;
          OnClick := ToolButtonClick;
        end;
        with TPopupMenu.Create(panelFunction) do
        begin
          Name := 'tpopmenu' + InttoStr(udfClassCount);
        end;
      end;
      for I := 1 to panelFunction.ComponentCount do
      begin
        if (panelFunction.Components[i - 1] is TPopupMenu) then
        begin
          if (panelFunction.Components[i - 1] as TPopupMenu).Name = 'tpopmenu' + InttoStr(udfClassCount) then
          begin
            inc(iIndex);
            NewItem := TMenuItem.Create(panelFunction.Components[i - 1] as TPopupMenu);
            NewItem.Tag := iIndex;
            NewItem.Caption := FieldByName('Function').AsString;
            (panelFunction.Components[i - 1] as TPopupMenu).Items.Add(NEWITEM);
            NewItem.OnClick := PopupMenuItemsClick; // assign it an event handler
            G_tsDllName.add(FieldByName('DLL_FILENAME').AsString);
            G_tsDllParam.add(FieldByName('FUN_PARAM').AsString);
          end;
        end;
      end;
      mFunType := Fieldbyname('FUN_TYPE').AsString;
      Next;
    end;

    Close;
  end;

  if panelFunction.ComponentCount > 0 then
  begin
    for i := 0 to ToolBar1.ButtonCount - 1 do
    begin
      for j := 0 to panelFunction.ComponentCount - 1 do
      begin
        if (panelFunction.Components[j] is TPopupMenu) then
        begin
          if (panelFunction.Components[j] as TPopupMenu).Name = 'tpopmenu' + IntTostr(i + 1) then
          begin
            (ToolBar1.Buttons[i] as TToolButton).PopupMenu := (panelFunction.Components[j] as TPopupMenu);
            break;
          end;
        end;
      end;
    end;
  end;
  if G_tsDllParam.Strings[0] = '' then
    loadSajetDll(G_tsDllName.Strings[0])
  else
    loadSajetWOStatusDll(G_tsDllName.Strings[0], G_tsDllParam.Strings[0]);
end;

function TformMain.LoadApServer: Boolean;
var F: TextFile;
  S: string;
begin
  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  SocketConnection1.Host := '';
  SocketConnection1.Address := '';

  if not FileExists(GetCurrentDir + '\ApServer.cfg') then
    Exit;
  AssignFile(F, GetCurrentDir + '\ApServer.cfg');
  Reset(F);
  while True do
  begin
    Readln(F, S);
    if trim(S) <> '' then
    begin
      SimpleObjectBroker1.Servers.Add;
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count - 1].ComputerName := Trim(S);
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count - 1].Enabled := True;
    end
    else
      Break;
  end;
  CloseFile(F);
  Result := True;
end;

procedure TformMain.closeSajetDll;
begin
  if m_sDLLName <> '' then
  begin
    m_closeSajetDll;
    FreeLibrary(m_DLLHandle);
    m_sDLLName := '';
  end;
end;

procedure TformMain.LoadSajetWOStatusDll(f_sDllName: string; WOStatus: string);
begin
  try
    f_sDllName := uppercase(f_sDllName);
    //如果已LOAD DRIVER，則先釋放
    if (m_sDLLName <> '') then closeSajetDll;

    m_DLLHandle := LoadLibrary(pchar(ExtractFilePath(Application.exename) + f_sDLLName));
    if m_DLLHandle <= 32 then raise Exception.create('Can Not Find DLL File(' + f_sDllName + ')');
    m_sDLLName := f_sDLLName;

    m_initialSajetWOStatusDll := GetProcAddress(m_DLLHandle, 'InitSajetDll');
    if (@m_initialSajetWOStatusDll = nil) then raise Exception.Create('DLL Function Not Match (1)');
    m_closeSajetDll := GetProcAddress(m_DLLHandle, 'CloseSajetDll');
    if (@m_closeSajetDll = nil) then raise Exception.Create('DLL Function Not Match (2)');

    m_initialSajetWOStatusDll(self, PanelParent, Application, LoginUserID, SocketConnection1, '', '', WOStatus);
  except
    on E: Exception do raise Exception.create('(' + ClassName + '.LoadSajetDll)' + E.Message);
  end;
end;

procedure TformMain.LoadSajetDll(f_sDllName: string);
begin
  try
    f_sDllName := uppercase(f_sDllName);
    //如果已LOAD DRIVER，則先釋放
    if (m_sDLLName <> '') then closeSajetDll;

    m_DLLHandle := LoadLibrary(pchar(ExtractFilePath(Application.exename) + f_sDLLName));
    if m_DLLHandle <= 32 then raise Exception.create('Can Not Find DLL File(' + f_sDllName + ')');
    m_sDLLName := f_sDLLName;

    m_AssignCBFunction := nil;
    m_AssignCBFunction := GetProcAddress(m_DLLHandle, 'AssignCBFunction');
    if assigned(m_AssignCBFunction) then m_AssignCBFunction(m_onTransDataToServer);

    m_initialSajetDll := GetProcAddress(m_DLLHandle, 'InitSajetDll');
    if (@m_initialSajetDll = nil) then raise Exception.Create('DLL Function Not Match (1)');
    m_closeSajetDll := GetProcAddress(m_DLLHandle, 'CloseSajetDll');
    if (@m_closeSajetDll = nil) then raise Exception.Create('DLL Function Not Match (2)');

    m_initialSajetDll(self, PanelParent, Application, LoginUserID, SocketConnection1, 'DspQryTemp1', 'DspStoreproc');

  except
    on E: Exception do raise Exception.create('(' + ClassName + '.LoadSajetDll)' + E.Message);
  end;
end;

procedure TformMain.FormShow(Sender: TObject);
var pIni: TIniFile; sImage: string;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString(gsProgram, 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Image1.Picture.LoadFromFile(sImage);
  formMain.ScaleBy(formMain.Height, 600);
  G_tsDllName := TStringList.Create;
  G_tsDllParam := TStringList.Create;

  LoadApServer;
  LabNO.Caption := '';
  LabName.Caption := '';
  with csFTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PROGRAM', ptInput);
    CommandText := 'Select TITLE_NAME ' +
      'From SAJET.SYS_PROGRAM_NAME ' +
      'Where PROGRAM = :PROGRAM ';
    Params.ParamByName('PROGRAM').AsString := gsProgram;
    Open;
    formMain.Caption := Fieldbyname('TITLE_NAME').AsString;

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EMP_ID', ptInput);
    CommandText := 'Select EMP_NO,EMP_NAME,PASSWD,ENABLED,NVL(TO_CHAR(QUIT_DATE,''yyyy/mm/dd''),''N/A'') QUIT_DATE ' +
      'From SAJET.SYS_EMP ' +
      'Where Upper(EMP_ID) = :EMP_ID ';
    Params.ParamByName('EMP_ID').AsString := UpperCase(Trim(LoginUserID));
    Open;
    if RecordCount > 0 then
    begin
      LabNO.Caption := Fieldbyname('EMP_NO').AsString;
      LabName.Caption := Fieldbyname('EMP_NAME').AsString;
    end
    else
    begin
       // 檢查是否為系統使用者
      if LoginUserID <> 'Steven&Jack&Tommy' then
      begin
        Close;
        MessageDlg('Login User Not Found !!', mtError, [mbCancel], 0);
        Exit;
      end;
      LabNO.Caption := 'Administrator';
      LabName.Caption := 'Administrator'; ;
      Close;
    end;
    ChkAuthority(gsProgram);
  end;

end;

procedure TformMain.PopupMenuItemsClick(Sender: TObject);
begin
  with Sender as TMenuItem do
  begin
    if G_tsDllParam.Strings[Tag - 1] = '' then
      loadSajetDll(G_tsDllName.Strings[Tag - 1])
    else
      loadSajetWOStatusDll(G_tsDllName.Strings[Tag - 1], G_tsDllParam.Strings[Tag - 1]);
//    loadSajetDll(G_tsDllName.Strings[Tag-1]);
  end;
end;

procedure TformMain.FormDestroy(Sender: TObject);
begin
  G_tsDllName.Free;
  G_tsDllParam.Free;
  m_codeSoft.free;
  Application.Terminate;
end;

procedure TformMain.FormCreate(Sender: TObject);
begin
  LoginUserID := ParamStr(1);
//  gsProgram  := ParamStr(2);
  gsProgram := 'Quality Control';
  m_codeSoft := TCodeSoft.Create(self);
  formMain.m_onTransDataToServer := onRsvDataFromDll;
end;

procedure TformMain.ToolButtonClick(Sender: TObject);
var pt: Tpoint;
begin
  if (Sender is TToolButton) then
  begin
    pt := (Sender as TToolButton).ClientToScreen(point(1, 30));
    (Sender as TToolButton).PopupMenu.Popup(pt.X, pt.y);
  end;
end;

procedure TformMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.

