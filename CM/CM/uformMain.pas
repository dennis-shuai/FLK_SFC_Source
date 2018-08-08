unit uformMain;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   Buttons, ExtCtrls,Menus, jpeg, StdCtrls, Db, DBClient, MConnect, SConnect,
   ObjBrkr, ToolWin, ComCtrls, ImgList, StdActns, ActnList, IniFiles;

type
  TInitSajetDll = procedure(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc: string); stdcall;
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
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ToolButtonClick(Sender: TObject);
   private
    { Private declarations }
   public
    { Public declarations }
      MyParentApplication: TApplication;
      FormOwner: TForm;
      FormParent: TPanel;
      LoginUserID, gsProgram: string;
      G_tsDllName:TStrings;
      gsTag, gsCaption: string;
      m_initialSajetDll: TInitSajetDll;
      function LoadApServer: Boolean;
      procedure ChkAuthority(PrgName: string);
      //procedure TestButtonMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
      procedure PopupMenuItemsClick(Sender: TObject);
   end;

var
   formMain: TformMain;

implementation

uses uMDIChild;

{$R *.DFM}

procedure TformMain.ChkAuthority(PrgName: string);
Var I,j : Byte; mFunType: String;
   NewItem: TMenuItem;
   iIndex,iLength,udfClassCount:integer;

begin
  G_tsDllName.Clear;
  With csFTemp do
  begin
    Close;
    If LoginUserID <> 'Steven&Jack&Tommy' Then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'EMPID',ptInput);
      Params.CreateParam(ftString,'PROGRAM',ptInput);
      Params.CreateParam(ftString,'EMP_ID',ptInput);
      Params.CreateParam(ftString,'PRG',ptInput);
      CommandText := 'Select C.FUN_TYPE_IDX,C.FUN_TYPE,C.FUN_IDX,C.FUNCTION,C.DLL_FILENAME '
                   + '  From ( '
                   + 'Select PROGRAM, FUNCTION '
                   + '  From SAJET.SYS_EMP_PRIVILEGE A, '
                   + '       SAJET.SYS_EMP B '
                   + ' Where A.EMP_ID = B.EMP_ID '
                   + '   and B.EMP_ID = :EMPID '
                   + '   and A.PROGRAM = :PROGRAM '
                   + ' union '
                   + 'Select PROGRAM, FUNCTION '
                   + '  From SAJET.SYS_ROLE_PRIVILEGE A, '
                   + '       SAJET.SYS_ROLE_EMP B '
                   + '  Where A.ROLE_ID = B.ROLE_ID '
                   + '    and B.EMP_ID = :EMP_ID '
                   + '    and A.PROGRAM = :PRG) A, '
                   + ' SAJET.SYS_PROGRAM_FUN C '
                   + '  WHERE A.PROGRAM = C.PROGRAM '
                   + '    and A.FUNCTION = C.FUNCTION '
                   + '    and C.FUN_IDX <> ''0'' '
                   + 'Group By FUN_TYPE_IDX,FUN_TYPE,FUN_IDX,C.FUNCTION,DLL_FILENAME '
                   + 'Order by FUN_TYPE_IDX, FUN_IDX ';
      Params.ParamByName('EMPID').AsString := LoginUserID;
      Params.ParamByName('PROGRAM').AsString := PrgName;
      Params.ParamByName('EMP_ID').AsString := LoginUserID;
      Params.ParamByName('PRG').AsString := PrgName;
      Open;
    end Else
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'PRG',ptInput);
      CommandText := 'Select FUN_TYPE,FUNCTION,FUN_TYPE_IDX,FUN_IDX,DLL_FILENAME ' +
                     'From SAJET.SYS_PROGRAM_FUN ' +
                     'Where PROGRAM = :PRG ' +
                     'and DLL_FILENAME is not null '+
                     'Group By FUN_TYPE_IDX,FUN_IDX,FUN_TYPE,FUNCTION,DLL_FILENAME '+
                     'Order by FUN_TYPE_IDX,FUN_IDX ';
      Params.ParamByName('PRG').AsString := PrgName;
      Open;
    end;

    mFunType := '';
    udfClassCount:=0 ;
    iLength:=0;
    iIndex := 0;

    while not eof do
    begin
      If Fieldbyname('FUN_TYPE').AsString <> mFunType Then
      begin
        inc(udfClassCount);
        with TToolButton.Create(ToolBar1) do
        begin
          ImageIndex :=udfClassCount-1;
          Parent := ToolBar1;
          Style := tbsDropDown;
          AutoSize := true;
          Left := iLength;
          Caption := Fieldbyname('FUN_TYPE').AsSTring;
          iLength := iLength+width;
          OnClick := ToolButtonClick; 
        end;
        with TPopupMenu.Create(panelFunction) do
        begin
           Name:='tpopmenu'+InttoStr(udfClassCount);
        end;
      end;
      For I := 1 to panelFunction.ComponentCount  do
      begin
        if  (panelFunction.Components[i-1] is TPopupMenu)  then
        begin
          if (panelFunction.Components[i-1] AS TPopupMenu).Name =  'tpopmenu'+InttoStr(udfClassCount) then
          begin
            inc(iIndex);
            NewItem := TMenuItem.Create(panelFunction.Components[i-1] AS TPopupMenu);
            NewItem.Tag :=iIndex;
            NewItem.Caption := FieldByName('Function').AsString;
           (panelFunction.Components[i-1] AS TPopupMenu).Items.Add(NEWITEM);
            NewItem.OnClick := PopupMenuItemsClick;// assign it an event handler
            G_tsDllName.add(FieldByName('DLL_FILENAME').AsString);
          end;
        end;
      end;
      mFunType:=Fieldbyname('FUN_TYPE').AsString;
      Next;
    end;

    Close;
  end;

  if panelFunction.ComponentCount>0 then
  begin
    for i:=0 to ToolBar1.ButtonCount-1 do
    begin
      for j:=0 to  panelFunction.ComponentCount-1 do
      begin
         if  (panelFunction.Components[j] is TPopupMenu)  then
         begin
           if (panelFunction.Components[j] as TPopupMenu).Name = 'tpopmenu'+IntTostr(i+1) then
           begin
             (ToolBar1.Buttons[i] AS TToolButton).PopupMenu :=  (panelFunction.Components[j] AS TPopupMenu);
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
   SocketConnection1.Host:='';
   SocketConnection1.Address:='';

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
        SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
        SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
      end else
        Break;
   end;
   CloseFile(F);
   Result := True;
end;

procedure TformMain.FormShow(Sender: TObject);
var pIni: TIniFile; sImage: String;
begin
 formMain.ScaleBy(formMain.Height,600);
 pini := TIniFile.Create('.\BackGround.Ini');
 sImage := pIni.ReadString(gsProgram, 'BackGround', 'Background.jpg');
 pIni.Free;
 if FileExists(sImage) then
   Image1.Picture.LoadFromFile(sImage);
 G_tsDllName:= TStringList.Create;
 LoadApServer;
 LabNO.Caption := '';
 LabName.Caption := '';
 With csFTemp do
 begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'PROGRAM', ptInput);
    CommandText := 'Select TITLE_NAME '+
                   'From SAJET.SYS_PROGRAM_NAME '+
                   'Where PROGRAM = :PROGRAM ';
    Params.ParamByName('PROGRAM').AsString := gsProgram;
    Open;
    formMain.Caption:=Fieldbyname('TITLE_NAME').AsString;

    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'EMP_ID', ptInput);
    CommandText := 'Select EMP_NO,EMP_NAME,PASSWD,ENABLED,NVL(TO_CHAR(QUIT_DATE,''yyyy/mm/dd''),''N/A'') QUIT_DATE '+
                   'From SAJET.SYS_EMP '+
                   'Where Upper(EMP_ID) = :EMP_ID ';
    Params.ParamByName('EMP_ID').AsString := UpperCase(Trim(LoginUserID)) ;
    Open;
    If RecordCount > 0 Then
    begin
       LabNO.Caption := Fieldbyname('EMP_NO').AsString;
       LabName.Caption := Fieldbyname('EMP_NAME').AsString;
    end Else
    begin
       // 檢查是否為系統使用者
       If LoginUserID <> 'Steven&Jack&Tommy' Then
       begin
          Close;
          MessageDlg('Login User Not Found !!',mtError, [mbCancel],0);
          Exit;
       end;
       LabNO.Caption := 'Administrator';
       LabName.Caption :='Administrator';;
       Close;
    end;
    ChkAuthority(gsProgram);
 end;
end;

procedure TformMain.PopupMenuItemsClick(Sender: TObject);
  function ShowMdi(formName: string): Boolean;
  var i: Integer;
  begin
    Result := True;
    for i := 0 to formMain.MDIChildCount - 1 do
      if formMain.MDIChildren[i].Caption = formName then begin
        formMain.MDIChildren[i].BringToFront;
        Result := False;
        break;
      end;
  end;
var formMDI: TformMDI;
begin
  with Sender as TMenuItem do
  begin
    gsTag := formMain.G_tsDllName.Strings[Tag-1];
    gsCaption := Copy(Caption, 1, Pos('&', Caption)-1) + Copy(Caption, Pos('&', Caption)+1, Length(Caption)); //formMain.G_tsDllName.Strings[Tag-1];
    if ShowMdi(gsCaption) then begin
      formMDI := TformMDI.Create(Self);
    end;
  end;
end;

procedure TformMain.FormDestroy(Sender: TObject);
begin
  G_tsDllName.Free;
  Application.Terminate;
end;

procedure TformMain.FormCreate(Sender: TObject);
begin
  LoginUserID  := ParamStr(1);
  gsProgram := 'CM';
end;
procedure TformMain.ToolButtonClick(Sender: TObject);
    var pt : Tpoint;
begin
  if (Sender is TToolButton) then
  begin
    pt:=(Sender as TToolButton).ClientToScreen(point(1,30));
   (Sender as TToolButton).PopupMenu.Popup(pt.X,pt.y);
  end;
end;

end.

