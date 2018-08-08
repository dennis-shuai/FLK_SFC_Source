unit uformMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, Menus, jpeg, StdCtrls, Db, DBClient, MConnect, SConnect,
  ObjBrkr, ToolWin, ComCtrls, ImgList, StdActns, ActnList, IniFiles;

type
  TInitSajetParamDll = procedure(SenderOwner: TForm; ParentApplication: TApplication; UserID, sCaption: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc, Param: string); stdcall;
  TActiveForm = function: LongInt; StdCall;
  TMinimizeForm = function: LongInt; StdCall;
  TCloseSajetDll = function : LongInt; StdCall;
  TRefreshMenu = function: string; stdcall;
  TformMain = class(TForm)
    SocketConnection1: TSocketConnection;
    csFTemp: TClientDataSet;
    SimpleObjectBroker1: TSimpleObjectBroker;
    ImageList1: TImageList;
    panelFunction: TPanel;
    Splitter1: TSplitter;
    PanelDisEmp: TPanel;
    Label22: TLabel;
    LabNo: TLabel;
    LabName: TLabel;
    PageScroller1: TPageScroller;
    ToolBar1: TToolBar;
    Image1: TImage;
    ActionList1: TActionList;
    WindowCascade1: TWindowCascade;
    WindowTileHorizontal1: TWindowTileHorizontal;
    WindowTileVertical1: TWindowTileVertical;
    WindowMinimizeAll1: TWindowMinimizeAll;
    WindowArrangeAll1: TWindowArrange;
    MainMenu1: TMainMenu;
    Window1: TMenuItem;
    WindowCascadeItem: TMenuItem;
    WindowArrangeItem: TMenuItem;
    WindowTileItem: TMenuItem;
    WindowTileItem2: TMenuItem;
    WindowMinimizeItem: TMenuItem;
    SetupBackgroundImage1: TMenuItem;
    ShowAll1: TMenuItem;
    CloseAll1: TMenuItem;
    ImageList2: TImageList;
    N1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ToolButtonClick(Sender: TObject);
    procedure WindowCascadeItemClick(Sender: TObject);
    procedure WindowTileItemClick(Sender: TObject);
    procedure WindowTileItem2Click(Sender: TObject);
    procedure ShowAll1Click(Sender: TObject);
    procedure WindowMinimizeItemClick(Sender: TObject);
    procedure CloseAll1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    MyParentApplication: TApplication;
    FormOwner: TForm;
    FormParent: TPanel;
    LoginUserID, gsProgram, gsPath: string;
    G_tsDllName, G_tsDllParam, G_tsGroup, G_tsMDI, slHandle, slCaption, slGroup: TStrings;
    gsTag, gsCaption, gsParam: string;
    m_initialSajetParamDll: TInitSajetParamDll;
    m_CloseSajetDll: TCloseSajetDll;
    m_ActiveForm: TActiveForm;
    m_MinimizeForm: TMinimizeForm;
    m_RefreshMenu: TRefreshMenu;
    function LoadApServer: Boolean;
    procedure ChkAuthority(PrgName: string);
    procedure AppException(Sender: TObject; E: Exception);
    procedure PopupMenuItemsClick(Sender: TObject);
  end;

var
  formMain: TformMain;

implementation

{$R *.DFM}

procedure TformMain.ChkAuthority(PrgName: string);
var I, j: Byte; mFunType: string; bGroup: Boolean;
  NewItem: TMenuItem; slCount: TStringList;
  iIndex, iLength, udfClassCount: integer;
begin
  G_tsDllName.Clear;
  G_tsDllParam.Clear;
  G_tsGroup.Clear;
  G_tsMDI.Clear;
  slCount := TStringList.Create;
  with csFTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select * from all_tab_columns '
      + 'where owner=''SAJET'' and table_name = ''SYS_REPORT_NAME'' and column_name =''GROUP_FLAG''';
    Open;
    bGroup := not IsEmpty;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EMP_ID', ptInput);
    CommandText := 'Select RP_TYPE_IDX,RP_TYPE FUN_TYPE,RP_ID,RP_NAME Function,DLL_FILENAME';
    if bGroup then
      CommandText := CommandText + ',GROUP_FLAG ';
    CommandText := CommandText + ' From SAJET.SYS_REPORT_NAME where (EMP_ID = 0 or EMP_ID = :EMP_ID) '
      + ' Order By RP_TYPE_IDX, RP_TYPE, RP_ID, RP_NAME';
    if bGroup then
      CommandText := CommandText + ', GROUP_FLAG ';
    Params.ParamByName('EMP_ID').AsString := LoginUserID;
    Open;
    iIndex := 0;
    mFunType := '';
    while not eof do
    begin
      if Fieldbyname('FUN_TYPE').AsString <> mFunType then
      begin
        slCount.Add('');
        iIndex := 0;
      end;
      mFunType := Fieldbyname('FUN_TYPE').AsString;
      Inc(iIndex);
      slCount[slCount.Count - 1] := IntToStr(iIndex);
      Next;
    end;
    mFunType := '';
    udfClassCount := 0;
    iLength := 0;
    iIndex := 0;
    First;
    while not eof do
    begin
      if Fieldbyname('FUN_TYPE').AsString <> mFunType then
      begin
        inc(udfClassCount);
        with TToolButton.Create(ToolBar1) do
        begin
          ImageIndex := udfClassCount - 1;
          Parent := ToolBar1;
          AutoSize := true;
          Left := iLength;
          Caption := Fieldbyname('FUN_TYPE').AsSTring;
          if slCount[udfClassCount - 1] <> '1' then
          begin
            Style := tbsDropDown;
            OnClick := ToolButtonClick
          end
          else
          begin
            Style := tbsButton;
            inc(iIndex);
            OnClick := PopupMenuItemsClick;
            Tag := iIndex;
            G_tsDllName.add(FieldByName('DLL_FILENAME').AsString);
            G_tsDllParam.add(FieldByName('RP_ID').AsString);
            G_tsGroup.add(Fieldbyname('FUN_TYPE').AsString);
            if bGroup then
              G_tsMDI.add(Fieldbyname('GROUP_FLAG').AsString)
            else
              G_tsMDI.add('1');
            if not FileExists(gsPath + FieldByName('DLL_FILENAME').AsString) then
              Enabled := False;
          end;
          iLength := iLength + width;
        end;
        if slCount[udfClassCount - 1] <> '1' then
          with TPopupMenu.Create(panelFunction) do
          begin
            Name := 'tpopmenu' + InttoStr(udfClassCount);
          end;
      end;
      if slCount[udfClassCount - 1] <> '1' then
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
              G_tsDllParam.add(FieldByName('RP_ID').AsString);
              G_tsGroup.add(Fieldbyname('FUN_TYPE').AsString);
              if bGroup then
                G_tsMDI.add(Fieldbyname('GROUP_FLAG').AsString)
              else
                G_tsMDI.add('1');
              if not FileExists(formMain.gsPath + FieldByName('DLL_FILENAME').AsString) then
                NewItem.Enabled := False;
            end;
          end;
        end;
      mFunType := Fieldbyname('FUN_TYPE').AsString;
      Next;
    end;
    Close;
  end;
  slCount.Free;
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

  if not FileExists(GetCurrentDir + '\ReportServer.cfg') then
    Exit;
  AssignFile(F, GetCurrentDir + '\ReportServer.cfg');
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

procedure TformMain.FormShow(Sender: TObject);
var pIni: TIniFile; sImage: string;
begin
  formMain.ScaleBy(formMain.Height, 600);
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString(gsProgram, 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Image1.Picture.LoadFromFile(sImage);
  G_tsDllName := TStringList.Create;
  G_tsDllParam:= TStringList.Create;
  G_tsGroup := TStringList.Create;
  G_tsMDI := TStringList.Create;
  slHandle := TStringList.Create;
  slCaption := TStringList.Create;
  slGroup := TStringList.Create;
  LoadApServer;
  LabNO.Caption := '';
  LabName.Caption := '';
  with csFTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    CommandText := 'select program from sajet.sys_program_name '
      + 'where upper(EXE_FILENAME) = :EXE_FILENAME and rownum = 1 ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Open;
    gsProgram := FieldByName('Program').AsString;
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
  function ShowMdi(formName, sGroup: string): Boolean;
  var i: Integer;
  begin
    Result := True;
    for i := 0 to formMain.MDIChildCount - 1 do
    begin
      if formMain.MDIChildren[i].Caption = formName then
      begin
        if formMain.MDIChildren[i].WindowState = wsMinimized then
          ShowWindow(formMain.MDIChildren[i].handle, SW_SHOWNORMAL)
        else
          ShowWindow(formMain.MDIChildren[i].handle, SW_SHOWNA);
        if (not formMain.MDIChildren[i].Visible) then
          formMain.MDIChildren[i].Visible := True;
        formMain.MDIChildren[i].BringToFront;
        Result := False;
        break;
      end else if Pos(sGroup, formMain.MDIChildren[i].Caption) <> 0 then begin
        formMain.MDIChildren[i].Close;
      end;
    end;
  end;
  procedure LoadMDISajetDll(f_sDllName, f_sParam, f_sCaption, f_sGroup: string);
  var bParam: Boolean; m_DLLHandle: THandle;
  begin
    try
      f_sDllName := uppercase(f_sDllName);
      m_DLLHandle := LoadLibrary(pchar(ExtractFilePath(Application.exename) + f_sDLLName));
      if m_DLLHandle <= 32 then raise Exception.create('Can Not Find DLL File(' + f_sDllName + ')');
      bParam := True;
      m_initialSajetParamDll := GetProcAddress(m_DLLHandle, 'InitSajetParamDll');
      if (@m_initialSajetParamDll = nil) then raise Exception.Create('DLL Function Not Match (InitSajetParamDll)');
      m_closeSajetDll := GetProcAddress(m_DLLHandle, 'CloseSajetDll');
      if (@m_closeSajetDll = nil) then raise Exception.Create('DLL Function Not Match (CloseSajetDll)');
      m_ActiveForm := GetProcAddress(m_DLLHandle, 'ActiveForm');
      if (@m_ActiveForm = nil) then raise Exception.Create('DLL Function Not Match (ActiveForm)');
      m_MinimizeForm := GetProcAddress(m_DLLHandle, 'MinimizeForm');
      if (@m_MinimizeForm = nil) then raise Exception.Create('DLL Function Not Match (MinimizeForm)');
      try
        m_initialSajetParamDll(self, Application, LoginUserID, f_sCaption, SocketConnection1, '', '', f_sParam);
        slCaption.Add(f_sCaption);
        slGroup.Add(f_sGroup);
        slHandle.Add(IntToStr(m_DLLHandle));
      except
      end;
    except
      on E: Exception do raise Exception.create('(' + ClassName + '.LoadSajetDll)' + E.Message);
    end;
  end;
var iTag, iPos, iGroup: Integer; sCaption, sGroup: String; 
begin
  if (Sender is TMenuItem) then
  begin
    with (Sender as TMenuItem) do begin
      iTag := Tag;
      sCaption := Caption;
    end;
  end
  else
    with (Sender as TToolButton) do
    begin
      iTag := Tag;
      sCaption := Caption;
    end;
  gsTag := formMain.G_tsDllName.Strings[iTag - 1];
  gsParam := formMain.G_tsDllParam.Strings[iTag - 1];
  sGroup := formMain.G_tsGroup.Strings[iTag - 1];
  iPos := Pos('(&', sCaption);
  if iPos <> 0 then
    gsCaption := sGroup + '-' + Copy(sCaption, 1, iPos - 1) + Copy(sCaption, iPos + 4, Length(sCaption))
  else begin
    iPos := Pos('&', sCaption);
    if iPos <> 0 then
      gsCaption := sGroup + '-' + Copy(sCaption, 1, iPos - 1) + Copy(sCaption, iPos + 1, Length(sCaption))
    else
      gsCaption := sCaption;
  end;
  if G_tsMDI.Strings[iTag - 1] = '1' then
  begin
    if slGroup.IndexOf(sGroup) = -1 then begin
      LoadMDISajetDll(gsTag, gsParam, gsCaption, sGroup)
    end else begin
      iGroup := slGroup.IndexOf(sGroup);
      if slCaption.IndexOf(gsCaption) <> -1 then
      begin
        try
          m_ActiveForm := GetProcAddress(StrToInt(slHandle[slCaption.IndexOf(gsCaption)]), 'ActiveForm');
          if Assigned(m_ActiveForm) then m_ActiveForm;
        except
          slCaption.Delete(iGroup);
          slGroup.Delete(iGroup);
          slHandle.Delete(iGroup);
          LoadMDISajetDll(gsTag, gsParam, gsCaption, sGroup);
        end;
      end else begin
        try
          m_CloseSajetDll := GetProcAddress(StrToInt(slHandle[iGroup]), 'CloseSajetDll');
          if Assigned(m_CloseSajetDll) then begin
            m_CloseSajetDll;
            FreeLibrary(StrToInt(slHandle[iGroup]));
          end;
        except
        end;
        slCaption.Delete(iGroup);
        slGroup.Delete(iGroup);
        slHandle.Delete(iGroup);
        LoadMDISajetDll(gsTag, gsParam, gsCaption, sGroup);
      end;
    end;
  end else begin
    if slCaption.IndexOf(gsCaption) <> -1 then
    begin
      try
        m_ActiveForm := GetProcAddress(StrToInt(slHandle[slCaption.IndexOf(gsCaption)]), 'ActiveForm');
        if Assigned(m_ActiveForm) then m_ActiveForm;
      except
        LoadMDISajetDll(gsTag, gsParam, gsCaption, sGroup);
      end;
    end else begin
      LoadMDISajetDll(gsTag, gsParam, gsCaption, sGroup);
    end;
  end;
end;

procedure TformMain.FormDestroy(Sender: TObject);
begin
  G_tsDllName.Free;
  G_tsDllParam.Free;
  G_tsGroup.Free;
  G_tsMDI.Free;
  slHandle.Free;
  slCaption.Free;
  slGroup.Free;
  Application.Terminate;
end;

procedure TformMain.FormCreate(Sender: TObject);
begin
  gsPath := ExtractFilePath(Application.exename);
  Application.OnException := AppException;
  LoginUserID := ParamStr(1);
end;

procedure TformMain.AppException(Sender: TObject; E: Exception);
begin
  Application.ProcessMessages;
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

procedure TformMain.WindowCascadeItemClick(Sender: TObject);
begin
  Cascade;
end;

procedure TformMain.WindowTileItemClick(Sender: TObject);
begin
  TileMode := tbHorizontal;
  Tile;
end;

procedure TformMain.WindowTileItem2Click(Sender: TObject);
begin
  TileMode := tbVertical;
  Tile;
end;

procedure TformMain.ShowAll1Click(Sender: TObject);
var i: Integer;
begin
  for i := 1 to slHandle.Count do
    try
      m_ActiveForm := GetProcAddress(StrToInt(slHandle[i - 1]), 'ActiveForm');
      if Assigned(m_ActiveForm) then m_ActiveForm;
    except
    end;
end;

procedure TformMain.WindowMinimizeItemClick(Sender: TObject);
var i: Integer;
begin
  for i := 1 to slHandle.Count do
    try
      m_MinimizeForm := GetProcAddress(StrToInt(slHandle[i - 1]), 'MinimizeForm');
      if Assigned(m_MinimizeForm) then m_MinimizeForm;
    except
    end;
end;

procedure TformMain.CloseAll1Click(Sender: TObject);
var i: Integer;
begin
  for i := slHandle.Count downto 1 do
    try
      m_CloseSajetDll := GetProcAddress(StrToInt(slHandle[i - 1]), 'CloseSajetDll');
      if Assigned(m_CloseSajetDll) then m_CloseSajetDll;
    except
    end;
  slCaption.Clear;
  slGroup.Clear;
  slHandle.Clear;
end;

end.

