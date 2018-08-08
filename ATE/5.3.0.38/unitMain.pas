unit unitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, Buttons, ExtCtrls, Menus, CoolTrayIcon, DB, BmpRgn,
  IniFiles, ShellAPI ;

type
  TFormMain = class(TForm)
    Edit1: TEdit;
    lablMsg: TLabel;
    edtPath: TEdit;
    sbtnPath: TSpeedButton;
    edtEmp: TEdit;
    lBlVer2: TLabel;
    Image1: TImage;
    Image4: TImage;
    SpeedButton2: TSpeedButton;
    CoolTrayIcon1: TCoolTrayIcon;
    PopupMenu1: TPopupMenu;
    Show1: TMenuItem;
    Exit1: TMenuItem;
    Timer1: TTimer;
    sbtnStart: TSpeedButton;
    sbtnStop: TSpeedButton;
    Label1: TLabel;
    Label4: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    combTestPrg: TComboBox;
    combVersion: TComboBox;
    sbtnSave: TSpeedButton;
    Bevel1: TBevel;
    sbtnStartLink: TSpeedButton;
    sbtnStopLink: TSpeedButton;
    Label7: TLabel;
    combType: TComboBox;
    Bevel2: TBevel;
    Label8: TLabel;
    Label9: TLabel;
    editPwd: TEdit;
    sbtnLogin: TSpeedButton;
    sbtnLogout: TSpeedButton;
    Label10: TLabel;
    edtDefect: TEdit;
    Label11: TLabel;
    sbtnRetry: TSpeedButton;
    Timer2: TTimer;
    edtRetry: TEdit;
    Label12: TLabel;
    LblVer1: TLabel;
    Label2: TLabel;
    edtReason: TEdit;
    Label13: TLabel;
    editStatus: TEdit;
    chekAutoRetry: TCheckBox;
    lablAutoRetry: TLabel;
    procedure sbtnPathClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Show1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure CoolTrayIcon1DblClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure edtEmpKeyPress(Sender: TObject; var Key: Char);
    procedure combTestPrgChange(Sender: TObject);
    procedure combVersionChange(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure sbtnStartClick(Sender: TObject);
    procedure sbtnStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnStartLinkClick(Sender: TObject);
    procedure sbtnStopLinkClick(Sender: TObject);
    procedure combTypeChange(Sender: TObject);
    procedure sbtnLoginClick(Sender: TObject);
    procedure editPwdKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnLogoutClick(Sender: TObject);
    procedure sbtnRetryClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure edtRetryKeyPress(Sender: TObject; var Key: Char);
    procedure edtRetryClick(Sender: TObject);
    function CheckVersion(sVer:string):boolean;
    procedure lablAutoRetryClick(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
  public
    { Public declarations }
    slSpcItem, slSpcId, slField, slValue: TStringList;
    gbShow: Boolean; UpdateUserID: String;
    slDefectATE,slDefectSFC,sAOIParam,sAOISeq:TStringList;
    G_AOI_SN,G_AOI_Param:Tstringlist;
    temp,sCnt:integer;
    sUpper,sAutoMin,sAutoMax,sRetry,sAutoRetry : string ;
    sOntop,sAOItype,sOrderBy,sAutoRetryField : string;
    iFeild,iLocation,iCode:integer;
    //
    DefaultButton : string ;  //彈出對話框後默認點南的按鈕ID
    MsgDelayTime : Integer ;   //彈出對話框後默認關閉時間(秒)
    //
    function CheckEmp: Boolean;
    function SendData(sResult: string): string;
    function InitialForm(var sProgram, sVersion: string): Boolean;
    function StartLink: Boolean;
    function SetStatusbyAuthority: Boolean;
    function Login: Boolean;
    procedure ClearData;
    procedure GetTestPrgData;
    procedure SetTheRegion;
    function GetDefect(DefaulDefect:string;var DefectCode :string):boolean;
    procedure ProParam(sDefect:TStringList;var sDefectATE:TStringList;var sDefectSFC:TStringList) ;
    procedure MoveFile ;
    Function Transdata(tSN:string; var tResult:string):boolean;
    procedure ShowErrorMessage(sError:string);
    procedure CloseErrorMessage;
    procedure BeepEx(cnt:integer);
    function GetVersion(sFile:string):string;
    procedure CloseAPServer;
    procedure OpenAPserver;
    function SetAOIParam(tstr:string;var AOIStr,sResult,sBox:string):string;
    procedure WriteLog(sTrLog:string);
    procedure GetSN(BoxNO,tType:string);
    function CheckFile(sFile:string):boolean;
    function CheckSNStatus(TSN:string;var sRESULT:STRING):boolean;
    //procedure GetAOIParam(AOIFile:Textfile);
    procedure RetrySN(TREV : string; out TRES : string) ;
    function  GetFileDateTime(const FileName: string): TDateTime;
    function  DelLogFile(Path: string) : Boolean;
    function  FileDel_Zhijie(FileString : String; UndoMK : Boolean = False ): Boolean ;
    procedure DelOldFileByDate (sFilePath : string);
  end;

  function SajetTransData(f_iCommandNo : integer;f_pData,f_pLen : pointer) : byte; stdcall; external 'SajetConnect.dll';
  function SajetTransStart : boolean; stdcall;external 'SajetConnect.dll';
  function SajetTransClose : boolean; stdcall;external 'SajetConnect.dll';
var
  FormMain: TFormMain;
  ShowTime : Integer ;
  
implementation

uses uDir, uDM, uRetry,uMessage;
var mesfrm:TfMessage;

{$R *.dfm}
//***********************************************************************************
//                         The Version (5.3.0.26)
//            The Version Add action log to find the reason of the ATE down  (5.3.0.21)
//               for AOI Machine : Read AOI　File(5.3.0.22)
//               For AOI Machine: To Read the new syle text file  (5.3.0.23)
//               Add Reason Code and Repair The SN Auto by the Reason (5.3.0.24)(not support the new AOI file syle)
//               Add Reason Code ,Repair Auto by the Reason code (5.3.0.25) (support the AOI File)   Linkey  2006/9/19
//               Modify the File  opened can not read (the function CheckFile)
//***********************************************************************************

//***************************************************************************************
//                      The Version (5.3.0.27)
//           This Version Add the Type of 'Version' to Fix the Version of sajet.g_sn_status and sajet.g_sn_keyparts after Assy
//                     Linkey  2006/11/23
//***************************************************************************************
procedure TimerProc(hwnd:HWND;uMsg,idEvent:UINT;dwTime:DWORD); stdcall;
var
  hwd, YesID, NOID : THandle ;
begin
  hwd :=  FindWindow(nil,'警告(Warning)');
  YesID := FindWindowEx(hwd,0,'Button',nil);
  NOID := FindWindowEx(hwd,YesID,'Button',nil);
  SetWindowText(YesID ,PChar('是(&Y)'+IntToStr(ShowTime)));
  if ShowTime <=0 then
  begin
    IF UpperCase(FormMain.DefaultButton) ='YESID' then
    begin
      PostMessage(YesID ,WM_LBUTTONDOWN,0,0);
      PostMessage(YesID ,WM_LBUTTONUP,0,0);
    end else
    begin
      PostMessage(NOID ,WM_LBUTTONDOWN,0,0);
      PostMessage(NOID ,WM_LBUTTONUP,0,0);
    end;
  end;
  Dec(ShowTime);
end;

function TFormMain.CheckSNStatus(TSN:string;var sRESULT: string):boolean;
begin
    if sUpper='1' then tSN:=uppercase(tSN);
    
    result:=True;
    sRESULT:='';
    with dmProject.cdsTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SN', ptInput);
      CommandText := 'SELECT SERIAL_NUMBER, CURRENT_STATUS  '
            +' FROM SAJET.G_SN_STATUS WHERE SERIAL_NUMBER = :SN AND ROWNUM = 1 ';
      Params.ParamByName('SN').AsString :=TSN;
      Open;
      if not isempty then //找到 了 SN
      begin
         if fieldbyname('CURRENT_STATUS').AsInteger=0 then
         begin
              sRESULT:='SN STATUS IS GOOD!';
              result:=false;
         end;
      end
      else //沒有找到SN,找SCN
      begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'CSN', ptInput);
          CommandText := 'SELECT SERIAL_NUMBER, CURRENT_STATUS'
            +' FROM SAJET.G_SN_STATUS WHERE customer_sn = :CSN AND ROWNUM = 1 ';
          Params.ParamByName('CSN').AsString :=TSN;
          Open;
          if not isempty then //找到了 CSN
          begin
              if fieldbyname('CURRENT_STATUS').AsInteger=0 then
              begin
                  sRESULT:='SN STATUS IS GOOD!';
                  result:=false;
              end;
          END
          ELSE  //沒有找到 CSN
          BEGIN
               sRESULT:='NOT FIND THE SN';
               result:=false;
          END;
      end;
      Close;
    end;
end;

function TFormMain.CheckFile(sFile:string):boolean;
var sFileName:string;
    iFileHandle:integer;
begin
   Result:=false;
  iFileHandle := FileOpen(sFile, fmOpenWrite);
  iF iFileHandle > 0 then Result:=true;
  if Result  then
    FileClose(iFileHandle);
end;

procedure DecodeStr(sType, sTemp: string; var sFront, sBack: string);
var iPos: integer;
begin
  iPos := Pos(sType, sTemp);
  sFront := Copy(sTemp, 1, iPos - 1);
  sBack := Copy(sTemp, iPos + 1, Length(sTemp));
end;

procedure TFormMain.GetSN(BoxNO,tType:string);
var tFields:string;
begin
  G_AOI_SN.Clear;
  openApserver;
  if uppercase(tType)='BOX' then  tFields:='Box_no'
  else tFields:='serial_number';
  with dmProject.cdsTemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'iBox', ptInput);
    commandtext:=' select serial_number from sajet.g_sn_status '
                +' where '+tFields+' = :iBox ';
    IF sOrderBy='DESC' then
      commandtext:=commandtext +' order by serial_number DESC '
    else   commandtext:=commandtext +' order by serial_number ';

    Params.ParamByName('iBox').AsString := BOXNO;
    open;
    while not eof do
    begin
      G_AOI_SN.Add(fieldbyname('serial_number').AsString);
      writeLog('Get Serial Number: '+fieldbyname('serial_number').AsString);
      next;
    end;
  end;
  CloseAPServer;
end;

procedure TFormMain.WriteLog(sTrLog:string);
{var sBackupFile,sDir:string;
    vFile: Textfile;}
begin
  //20110801取消Log檔寫入
  {sDir:=ExtractFilePath(Application.ExeName)+'\';
  ForceDirectories(sDir + 'ATELOG');
  sBackupFile := sDir + 'ATELOG\'+FormatDateTime('YYYYMMDDHH',now())+'.log';
  AssignFile(vFile, sBackupFile);
  if FileExists(sBackupFile) then
    Append(vFile)
  else
    Rewrite(vFile);
  WriteLn(vFile, FormatDateTime('yyyy/mm/dd hh:mm:ss', Now) + ' - ' + sTrlog);
  CloseFile(vFile);}
end;

function TFormMain.SetAOIParam(tstr:string;var AOIStr,sResult,sBox:string):string;
var i,j,tIndex:integer;
    temp,strtmp,tmpdefect:string;
    sTime,sDate,sSN,sErr,sLocation,sCount,sStatus:string;
begin
   result:='OK';
   sResult:='PASS';
   temp:=tstr;
   i:=0;
   sLocation:='N/A';
   sErr:='N/A';
   while pos(';',temp)>0 do
   begin
     inc(i);
     tIndex:=sAOISeq.IndexOf(inttostr(i));
     if tIndex<>-1 then
     begin
       if sAOIParam[tIndex]='Serial Number' then
         sSN:=copy(temp,0,pos(';',temp)-1)
       else if sAOIParam[tIndex]='TDate' then
         sDate:=copy(temp,0,pos(';',temp)-1)
       else if sAOIParam[tIndex]='TTime' then
         sTime:=copy(temp,0,pos(';',temp)-1)
       else if sAOIParam[tIndex]='Skipped' then
       begin
         sStatus:=copy(temp,0,pos(';',temp)-1);
         if sSTatus='1' then
         begin
           result:='SKIPPED';
           break;
         end;
       end
       else if sAOIParam[tIndex]='Error Cnt'  then
       begin
         sCount:=copy(temp,0,pos(';',temp)-1);
         if strtoint(sCount)>0 then
         begin
           sLocation:='';
           sErr:='';
           sResult:='NG';
           temp:=copy(temp,pos(';',temp)+1,length(temp));
           strtmp:=temp;
           j:=0;
           while pos(';',strtmp)>0 do
           begin
             inc(j);
             if (j mod iFeild)=iLocation then
                sLocation:=sLocation+':'+ copy(strtmp,0,pos(';',strtmp)-1)
             else if (j mod iFeild)=iCode then
             begin
                tmpdefect:= copy(strtmp,0,pos(';',strtmp)-1);
                if not GetDefect(trim(edtdefect.Text),tmpdefect) then
                    result:='Defect Code Error!'
                else begin
                    sErr:=sErr+':'+tmpdefect;
                end;
             end;
             strtmp:=copy(strtmp,pos(';',strtmp)+1,length(strtmp));
           end;
           sErr:=copy(sErr,2,length(sErr));
           sLocation:=copy(sLocation,2,length(sLocation));
         end;
         break;
       end;
     end;
     temp:=copy(temp,pos(';',temp)+1,length(temp));
   end;
   IF UPPERCASE(sAOItype)='BOX' THEN
      sBox:=sSN
   ELSE sBOX:=copy(sSN,1,length(sSN)-2);
   writeLog('AOI Serial Number: '+sSN);
   AOIStr:= sDate+sTime+';'+sErr+';'+sLocation;
end;

procedure TFormMain.CloseAPServer;
begin
 { if  dmProject.SocketConnection1.Connected then
    dmProject.SocketConnection1.Connected:=false; }
end;
procedure TFormMain.OpenAPserver;
begin
 {if  not dmProject.SocketConnection1.Connected then
  dmProject.SocketConnection1.Connected:=true;   }
end;

function TFormMain.CheckVersion(sVer:string):boolean;
begin
  result:=true;
  with dmProject.cdsTemp do
  begin
    close;
    params.Clear;
    commandtext:=' select Param_value from sajet.sys_base where param_name=''ATEVersion'' ';
    open;
    if recordcount>0 then
      if sVer<>fieldbyname('Param_value').AsString then result:=false;
  end;
end;
function TFormMain.GetVersion(sFile:string):string;
var
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  szName: array[0..255] of Char;
  Value: Pointer;
  Len: UINT;
  TransString:string;
begin
  InfoSize := GetFileVersionInfoSize(PChar(sFile), Wnd);
  if InfoSize <> 0 then
  begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(sFile), Wnd, InfoSize, VerBuf) then
      begin
        Value :=nil;
        VerQueryValue(VerBuf, '\VarFileInfo\Translation', Value, Len);
        if Value <> nil then
           TransString := IntToHex(MakeLong(HiWord(Longint(Value^)), LoWord(Longint(Value^))), 8);
        Result := '';
        StrPCopy(szName, '\StringFileInfo\'+Transstring+'\FileVersion');

        if VerQueryValue(VerBuf, szName, Value, Len) then
           Result := StrPas(PChar(Value));
      end;
    finally
      FreeMem(VerBuf);
    end;
  end;
end; 

procedure TFormMain.BeepEx(Cnt:integer);
var i:integer;
begin
  for i:=1 to Cnt do
     windows.Beep(3500,100);
end;

procedure TFormMain.ShowErrorMessage(sError:string);
var temp :string;
begin
   if timer2.Enabled then
   begin
        CloseErrorMessage;
   end ;
    mesfrm:=tfMessage.create(application);
    temp:=copy(sError,1,pos('NG;',sError)-1);
    temp:=temp+#13+copy(sError,pos('NG;',sError),length(sError)-length(temp));
    //if sOntop='1' then mesfrm.FormStyle:=fsStayOnTop;
    mesfrm.show(temp);
    timer2.Enabled:=true;
end;

procedure TFormMain.CloseErrorMessage ;
begin
  timer2.Enabled:=false;
  mesfrm.close;
  mesfrm.Free;
  //if sOntop='1' then mesfrm.FormStyle:=fsNormal;   
end;

Function TFormMain.Transdata(tSN:string;var tResult:string):boolean;
var sData: string; i, iLen: integer;
begin
  if sUpper='1' then tSN:=uppercase(tSN);
  
  iLen := Length(tSN);
  if iLen < 100 then
    SetLength(sData, 100)
  else
    SetLength(sData, iLen);
  for i := 1 to iLen do
    sData[i] := tSN[i];
  if SajetTransData(9, @sdata[1], @iLen) = 1 then
  begin
    result:=true;
  end
  else begin
    result:=false;
  end;
  SetLength(sData, iLen);
  tResult := sData;
end;

procedure TFormMain.MoveFile ;
var sDir,sBackupFile,sTxtFile:string;
    sr: TSearchRec;
begin
  sDir := Trim(edtPath.Text);
  if Copy(sDir, Length(sDir), 1) <> '\' then
    sDir := sDir + '\';

  ForceDirectories(sDir + 'BackUp');
  while  FindFirst(sDir + '*.txt', 0, sr) = 0 do
  begin
    //CheckFile(sDir+sr.Name);
    sBackupFile := sDir + 'BackUp' + '\' + sr.name;
    sTxtFile := sDir + sr.name;
    try
      CopyFile(PChar(sTxtFile), PChar(sBackupFile), False);
      writeLog('Copy File '+sTxtFile+' to '+sBackupFile);
      DeleteFile(PChar(sTxtFile));
      writeLog('Delete File: '+sTxtFile);
    except
    end;
  end;
end;

procedure TFormMain.ProParam(sDefect:TStringList;var sDefectATE:TStringList;var sDefectSFC:TStringList);
var i,j:integer;
    tStr:string;
begin
  for i:=0 to sDefect.Count-1 do
  begin
     tStr:=sDefect[i];
     j:=pos('=',tStr);
     sDefectATE.Add(copy(tStr,0,j-1));
     sDefectSFC.Add(copy(tStr,j+1,length(tStr)));
  end;
end;    

function TFormMain.GetDefect(DefaulDefect:string;var DefectCode :string) :boolean;
var tIndex:integer;
begin
  result:=true;
  tIndex:=sldefectATE.IndexOf(DefectCode);
  if tIndex<>-1 then
     DefectCode:=slDefectSFC[tIndex]
  else begin
     if DefectCode='' then
       if DefaulDefect<>'' then
          DefectCode:=DefaulDefect
       else
         result:=false;
  end;
end;

function TFormMain.Login: Boolean;
var sAuth: string;
begin
  Result := False;
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EMP_NO', ptInput);
    CommandText := 'Select EMP_ID,EMP_NAME,EMP_NO,trim(SAJET.password.decrypt(PASSWD)) PWD '
      + '      ,ENABLED,NVL(TO_CHAR(QUIT_DATE,''yyyy/mm/dd''),''N/A'') QUIT_DATE '
      + '      ,CHANGE_PW_TIME '
      + 'From SAJET.SYS_EMP '
      + 'Where Upper(EMP_NO) = :EMP_NO ';
    Params.ParamByName('EMP_NO').AsString := UpperCase(Trim(edtEmp.Text));
    Open;
    if not IsEmpty then
    begin
      // 檢查 PWD
      if Trim(editPwd.Text) <> Fieldbyname('PWD').AsString then
      begin
        Close;
        editPwd.Text := '';
        MessageDlg('Invalid Password!!', mtError, [mbOK], 0);
        Exit;
      end;
      // 檢查是否已離職
      if (trim(Fieldbyname('QUIT_DATE').AsString) <> 'N/A') then
      begin
        Close;
        editPwd.Text := '';
        edtEmp.SetFocus;
        edtEmp.SelectAll;
        MessageDlg('This User have Terminate!!', mtError, [mbOK], 0);
        Exit;
      end;
      // 檢查是否有效
      if (Copy(Fieldbyname('ENABLED').AsString, 1, 1) <> 'Y') then
      begin
        Close;
        editPwd.Text := '';
        edtEmp.SetFocus;
        edtEmp.SelectAll;
        MessageDlg('User invalid !!', mtError, [mbOK], 0);
        Exit;
      end;
      UpdateUserID := Fieldbyname('EMP_ID').AsString;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      Params.CreateParam(ftString, 'FUN', ptInput);
      CommandText := 'Select AUTHORITYS '
        + 'From SAJET.SYS_EMP_PRIVILEGE '
        + 'Where EMP_ID = :EMP_ID '
        + 'and PROGRAM = :PRG '
        + 'and FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'ATE';
      Params.ParamByName('FUN').AsString := 'Execute';
      Open;
      while not Eof do
      begin
        sAuth := Fieldbyname('AUTHORITYS').AsString;
        Result := (sAuth = 'Allow To Execute') or (sAuth = 'Full Control');
        if Result then
          break;
        Next;
      end;
      Close;
      if not Result then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'EMP_ID', ptInput);
        Params.CreateParam(ftString, 'PRG', ptInput);
        Params.CreateParam(ftString, 'FUN', ptInput);
        CommandText := 'Select AUTHORITYS '
          + 'From SAJET.SYS_ROLE_PRIVILEGE A, '
          + 'SAJET.SYS_ROLE_EMP B '
          + 'Where A.ROLE_ID = B.ROLE_ID '
          + 'and b.EMP_ID = :EMP_ID '
          + 'and PROGRAM = :PRG '
          + 'and FUNCTION = :FUN ';
        Params.ParamByName('EMP_ID').AsString := UpdateUserID;
        Params.ParamByName('PRG').AsString := 'ATE';
        Params.ParamByName('FUN').AsString := 'Execute';
        Open;
        while not Eof do
        begin
          sAuth := Fieldbyname('AUTHORITYS').AsString;
          Result := (sAuth = 'Allow To Execute') or (sAuth = 'Full Control');
          if Result then
            break;
          Next;
        end;
        Close;
      end;
      if not Result then
      begin
        MessageDlg('Privilege NG!!', mtError, [mbOK], 0);
        editPwd.Text := '';
        edtEmp.SetFocus;
        edtEmp.SelectAll;
      end;
    end
    else
      MessageDlg('Login User Not Found !!', mtError, [mbOK], 0);
  end;
end;

function TFormMain.SetStatusbyAuthority: Boolean;
var Auth: string;
begin
  // Read Only,Allow To Change,Full Control
  Auth := '';
  Result := False;
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EMP_ID', ptInput);
    Params.CreateParam(ftString, 'PRG', ptInput);
    Params.CreateParam(ftString, 'FUN', ptInput);
    CommandText := 'Select AUTHORITYS ' +
      'From SAJET.SYS_EMP_PRIVILEGE ' +
      'Where EMP_ID = :EMP_ID and ' +
      'PROGRAM = :PRG and ' +
      'FUNCTION = :FUN ';
    Params.ParamByName('EMP_ID').AsString := UpdateUserID;
    Params.ParamByName('PRG').AsString := 'ATE';
    Params.ParamByName('FUN').AsString := 'Configuration';
    Open;
    while not Eof do
    begin
      Auth := Fieldbyname('AUTHORITYS').AsString;
      Result := (Auth = 'Allow To Change') or (Auth = 'Full Control');
      if Result then
        break;
      Next;
    end;
    Close;
  end;
  if not Result then
  begin
    Auth := '';
    with dmProject.cdsTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      Params.CreateParam(ftString, 'FUN', ptInput);
      CommandText := 'Select AUTHORITYS ' +
        'From SAJET.SYS_ROLE_PRIVILEGE A, ' +
        'SAJET.SYS_ROLE_EMP B ' +
        'Where A.ROLE_ID = B.ROLE_ID and ' +
        'EMP_ID = :EMP_ID and ' +
        'PROGRAM = :PRG and ' +
        'FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'ATE';
      Params.ParamByName('FUN').AsString := 'Configuration';
      Open;
      while not Eof do
      begin
        Auth := Fieldbyname('AUTHORITYS').AsString;
        Result := (Auth = 'Allow To Change') or (Auth = 'Full Control');
        if Result then
          break;
        Next;
      end;
      Close;
    end;
  end;
end;

procedure TFormMain.SetTheRegion;
var
  HR: HRGN;
begin
  HR := BmpToRegion(Self, Image1.Picture.Bitmap);
  SetWindowRgn(handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.

procedure TFormMain.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
var
  Brush: TBrush;
begin
  Brush := TBrush.Create;
  Brush.Color := Color;
  FillRect(Msg.DC, ClientRect, Brush.Handle);
  Brush.Free;
  with Image1.Picture.Bitmap do
    BitBlt(Msg.DC, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := 1;
end;

// This routine takes care of letting the user move the form
// around on the desktop.

procedure TFormMain.WMNCHitTest(var msg: TWMNCHitTest);
var
  i: integer;
  p: TPoint;
  AControl: TControl;
  MouseOnControl: boolean;
begin
  inherited;
  if msg.result = HTCLIENT then
  begin
    p.x := msg.XPos;
    p.y := msg.YPos;
    p := ScreenToClient(p);
    MouseOnControl := false;
    for i := 0 to ControlCount - 1 do
    begin
      if not MouseOnControl
        then
      begin
        AControl := Controls[i];
        if ((AControl is TWinControl) or (AControl is TGraphicControl))
          and (AControl.Visible)
          then MouseOnControl := PtInRect(AControl.BoundsRect, p);
      end
      else
        break;
    end;
    if (not MouseOnControl) then msg.Result := HTCAPTION;
  end;
end;

function TFormMain.SendData(sResult: string): string;
var sData: string; i, iLen: integer;
begin
  if sUpper='1' then sResult:=uppercase(sResult);
  iLen := Length(sResult);
  if iLen < 100 then
    SetLength(sData, 100)
  else
    SetLength(sData, iLen);
  for i := 1 to iLen do
    sData[i] := sResult[i];
  if SajetTransData(7, @sdata[1], @iLen) = 1 then
    lablMsg.Font.Color := clblue
  else
    lablMsg.Font.Color := clred;
  if pos('DLL Not Initialize',sData)>0 then
  begin
    if not SajetTransStart then SajetTransStart;
    if SajetTransData(7, @sdata[1], @iLen)=1 then
        lablMsg.Font.Color := clblue
    else
       lablMsg.Font.Color := clred;
  end;
  SetLength(sData, iLen);
  Result := sData;
end;

procedure TFormMain.sbtnPathClick(Sender: TObject);
begin
  if formDir.ShowModal = mrOk then
    edtPath.Text := formDir.ShellTreeView1.Path;
end;

procedure TFormMain.SpeedButton2Click(Sender: TObject);
begin
  if sbtnStop.Enabled then
  begin
    formMain.FormStyle := fsNormal;
    CoolTrayIcon1.HideMainForm;
    writeLog('Form Min');
  end;
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  try
    CoolTrayIcon1.ShowMainForm;
  except
  end;
  Timer1.Enabled := False;
  formDir.Free;
  slSpcItem.Free;
  slSpcId.Free;
  slField.Free;
  slValue.Free;
  slDefectATE.free;
  G_AOI_SN.Free;
  G_AOI_Param.Free;
  slDefectSFC.Free;
  sAOIParam.Free;
  sAOISeq.Free;
  try
    SajetTransClose;
  except
  end;
  CanClose := True;
  writelog('Close OK')
end;

procedure TFormMain.Show1Click(Sender: TObject);
begin
  if sOntop='1' then
     formMain.FormStyle:=fsStayOnTop;
  CoolTrayIcon1.ShowMainForm;
  Application.BringToFront;
  if sRetry='1' then
  begin
    edtRetry.SelectAll;
    edtRetry.SetFocus;
  end;
end;

procedure TFormMain.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.CoolTrayIcon1DblClick(Sender: TObject);
begin
  Show1Click(self);
end;

procedure TFormMain.Timer1Timer(Sender: TObject);
var sr: TSearchRec; vFile,AoiFile: Textfile;  i, iIndex: Integer;
  sTxtFile, sDir, sBackupFile, mS, sPath, sTemp, sField, sFront, sSection: string;
  sTerminal, sTime, sSN, sResult, sDefect, sWo, sSPC, sValue, sSPCTemp, sBox, sXid: string;
  sSNVer,sItem1,sItem1Ver,sItem2,sItem2Ver:string;
  StrTmp,sDateDir,strAOI,sBoxNO,sParam:string;
  AoICnt:integer;
  TREV, TSN, SqlStr, MsgStr : string ;
  sMsgStr : string;
  function GetSPCID(sSPC: string): string;
  begin
    Result := '';
    if slSpcItem.IndexOf(sSPC) <> -1 then
      Result := slSpcId[slSpcItem.IndexOf(sSPC)];
  end;
begin
  Timer1.Enabled := False;
  writelog('Timer Close ');
  sDir := Trim(edtPath.Text);

  if Copy(sDir, Length(sDir), 1) <> '\' then
    sDir := sDir + '\';
  if FindFirst(sDir + '*.txt', 0, sr) = 0 then
  begin
    sDateDir:=FormatDateTime('YYYYMMDD',now());
    sTxtFile := sDir + sr.name;
    sPath:='Log';
    WriteLog('Find File: '+sTxtFile);
    if not CheckFile(sTxtFile) then
    begin
      writeLog('the File: '+sTxtFile+' Has Open');
      Timer1.Enabled := True;
      writeLog('Timer Enbled');
      exit;
    end;
    AssignFile(vFile, sTxtFile);
    Reset(vFile);

    if combType.ItemIndex=3 then
    begin
      G_AOI_Param.Clear;
      ReadLn(vFile, mS);
      writeLog('AOI Read String: '+ms);
      while ms<>'' do
      begin
        sParam:='';
        while ms<>'' do
        begin
          if Copy(mS, Length(mS), 1) <> ';' then
             mS := mS + ';';
          sParam:=sParam+ms;
          readln(vFile,ms);
        end;
        writeLog('Get AOI Param: '+sParam);
        strAOI:= SetAOIParam(sParam,sTemp,strtmp,sBoxNO);
        writelog('AOI Get Param :'+sTemp);
        writeLog('AOI Get SN Status: '+strtmp);
        writeLog('AOI Get Box NO : '+ sBoxNO);
        writelog('AOI Get Param Result:'+ StrAOI);
        if StrAOI='OK' then
        begin
          G_AOI_Param.Add(sTemp);
          writeLog('Param Add: '+sTemp);
        end
        else begin
          ForceDirectories(sDir +'ErrorLog\'+ sDateDir);
          sBackupFile := sDir +'ErrorLog\'+ sDateDir + '\Error.Log';
          AssignFile(AoiFile, sBackupFile);
          if FileExists(sBackupFile) then
             Append(AoiFile)
          else
             Rewrite(AoiFile);
          WriteLn(AoiFile, FormatDateTime('yyyy/mm/dd hh:mm:ss', Now) + ' - ' + sr.name + ' - ' + mS + ' (' + StrAOI + ') ');
          CloseFile(AoiFile);
        end;
        ReadLn(vFile, mS);
        writeLog('AOI Read String: '+ms);
      end;

      FindClose(sr);
      Closefile(vFile);
      sTxtFile := sDir + sr.name;
      sBackupFile := sDir + sPath + '\'+ sDateDir+'\'+ sr.name;
      ForceDirectories(sDir + sPath+'\'+sDateDir);
      try
         CopyFile(PChar(sTxtFile), PChar(sBackupFile), False);
         writeLog('AOI Copy File ['+sTxtFile+'] To ['+sBackupFile+']');
         if not DeleteFile(PChar(sTxtFile)) then  DeleteFile(PChar(sTxtFile));
         writeLog('AOI Delete File:['+sTxtFile+']');
      except
         timer1.Enabled:=true;
         writeLog('AOI Delete File ['+sTxtFile+'] Fail and Timer Enabled ');
         exit;
      end;
      if sBoxNO<>'' then
        GetSN(sBoxNO,'BOX');
      //單板沒有BOX_NO 只有serial_number
      // add by key 2008/11/20
      if G_AOI_SN.Count=0 then
        GetSN(sBoxNO,'SN');
      //add end
      sPath := 'Log';
      writeLog('AOI Param Count: '+inttostr(G_AOI_Param.Count));
      writeLog('AOI SN Count: '+inttostr(G_AOI_SN.Count));
      if  G_AOI_Param.Count>G_AOI_SN.Count then
        AOICnt:=G_AOI_SN.Count
      else AOICnt:= G_AOI_Param.Count;
      writeLog('AOI Count:'+inttostr(AOICnt));
      if AOICnt>0 then
        for i:=0 to AOICnt-1 do
        begin
          sTemp:= trim(edtEmp.Text)+';'+'N/A'+';'+ G_AOI_SN[i]+';'+G_AOI_Param[i];
          sResult := SendData(sTemp);
          writeLog(' Send Data: '+sTemp+' (Result: '+sResult+')' );
          if sResult <> 'OK;' then
          begin
            sPath := 'ErrorLog';
            ForceDirectories(sDir +'ErrorLog\'+ sDateDir);
            sBackupFile := sDir +'ErrorLog\'+ sDateDir + '\Error.Log';
            AssignFile(AoiFile, sBackupFile);
            if FileExists(sBackupFile) then
              Append(AoiFile)
            else
              Rewrite(AoiFile);
            WriteLn(AoiFile, FormatDateTime('yyyy/mm/dd hh:mm:ss', Now) + ' - ' + sr.name + ' - ' + mS + ' (' + sResult + ') ');
            CloseFile(AoiFile);
          end;
          Edit1.Text:=sTemp;
          lablMsg.Caption := 'Transfer Finish: ' + FormatDateTime('yyyy/mm/dd hh:mm:ss', Now)+': '+ sResult;
          writeLog('Show Message: '+lablMsg.Caption);
        end;

      Timer1.Enabled:=true;
      writeLog('AOI Send Data Finished And Timer Enabled ');
      exit;
    end;

    ////not AOI
    ReadLn(vFile, mS);
    WriteLog('Read String: '+ms);
    if trim(ms)='' then
    begin
      FindClose(sr);
      Closefile(vFile);
      timer1.Enabled:=true;
      writeLog('Find Empty File and Timer Enabled ');
      exit;
    end;
    if Copy(mS, Length(mS), 1) <> ';' then
      mS := mS + ';';
    sTemp := mS;
    sTerminal := ''; sTime := ''; sSN := ''; sResult := ''; sDefect := ''; sWo := '';
    sSPC := '';  sBox := ''; sXid := '';
    sSNVer:='N/A';
    sItem1:='N/A';sItem1Ver:='N/A';sItem2:='N/A';sItem2Ver:='N/A';
    // 拆碼
      while (Pos(';', sTemp) <> 0) do
      begin
        DecodeStr(';', sTemp, sFront, sTemp); // Time
        DecodeStr('=', sFront, sField, sValue); // Time
        iIndex := -1;
        sField := UpperCase(sField);
        for i := 0 to slField.Count - 1 do
        begin
          iIndex := slValue.IndexOf(sField);
          if iIndex <> -1 then begin
            sSection := UpperCase(slField[iIndex]);
            if sSection = 'TERMINAL' then
              sTerminal := sValue
            else if sSection = 'TIME' then
              sTime := sValue
            else if sSection = 'SERIAL NUMBER' then
              sSN := sValue
            else if sSection= 'SNVER' then
              sSNVer:= sValue
            else if sSection = 'RESULT' then
              sResult := sValue
            else if sSection = 'ERROR CODE' then
              sDefect := sValue
            else if sSection = 'XID' then
              sXid := sValue
            else if sSection = 'BOX ID' then
              sBox := sValue
            else if sSection = 'WORK ORDER' then
              sWo := sValue
            else if sSection = 'ITEM1' then
              sItem1 := sValue
            else if sSection = 'ITEM1VER' then
              sItem1Ver:=sValue
            else if sSection = 'ITEM2' then
              sItem2:= sValue
            else if sSection = 'ITEM2VER' then
              sItem2Ver:= sValue;
            break;
          end;
        end;
        if iIndex = -1 then
          if combTestPrg.Text <> '' then begin
            DecodeStr(';', sTemp, sFront, sTemp);
            DecodeStr('=', sFront, sSPCTemp, sValue);
            sSPCTemp := GetSPCID(sSPCTemp);
            if sSPCTemp <> '' then
              sSPC := sSPC + sSPCTemp + ':' + sValue + ';';
          end;
      end;
      StrTmp:=sResult;
      ////////////////////////////////////
      //ATE 0;ASSY 1; PACKING 2; AOI 3; Version 4; ATE Ver 5; ASSY Ver 6
      if (combType.ItemIndex=0) or (combType.ItemIndex=1)
           or (combType.ItemIndex=4) or (combType.ItemIndex=5) or (combType.ItemIndex=6) then
        if sResult = 'PASS' then
          sDefect := 'N/A'
        else   if not GetDefect(trim(edtDefect.Text),sDefect) then
        begin
          FindClose(sr);
          Closefile(vFile);
          sTxtFile := sDir + sr.name;
          sBackupFile := sDir + 'ErrorLog' + '\'+sDateDir+'\' + sr.name;
          ForceDirectories(sDir + 'ErrorLog'+'\'+sDateDir);
          try
            CopyFile(PChar(sTxtFile), PChar(sBackupFile), False);
            writeLog('Copy File '+sTxtFile+' to '+sBackupFile);
            if not DeleteFile(PChar(sTxtFile)) then  DeleteFile(PChar(sTxtFile));
            writeLog('Delete File: '+sTxtFile);
          except
            timer1.Enabled:=true;
            writeLog('Delete File '+sTxtFile+' Fail and Timer Enabled');
            exit;
          end;
          lablMsg.Font.Color := clred;
          lablMsg.Caption := 'Transfer Finish: ' + FormatDateTime('yyyy/mm/dd hh:mm:ss', Now) + ' ErrorCode  Empty!!';
          //messagebeep(48);
          BeepEx(sCnt);
          ShowErrorMessage(lablMsg.Caption);
          writeLog('Defect Code Error and Show Message: '+lablMsg.Caption);
          Timer1.Enabled := True;
          writeLog('Timer Enbled');
          exit;
        end
        else writeLog('Get Defect Code OK ');
      /////////////////////////////////////////
      case combType.ItemIndex of
        0: sTemp := edtEmp.Text + ';' + sWo + ';' + sSN + ';' + sTime + ';' + sDefect + ';' + sSPC;
        1: sTemp := edtEmp.Text + ';' + sWo + ';' + sSN + ';' + sXid + ';' + sTime + ';' + sDefect + ';';
        2: sTemp := edtEmp.Text + ';' + sBox + ';' + sSN + ';' + sTime + ';';
        4: sTemp := edtEmp.Text + ';' + sWO + ';' + sSN + ';'+ sSNVer + ';'+ sItem1+ ';' + sItem1Ver + ';' + sItem2 + ';' + sItem2Ver + ';'+ sTime +';'+ sDefect + ';';
        5: sTemp := edtEmp.Text + ';' + sWo + ';' + sSN + ';' + sTime + ';' + sDefect + ';' + sSPC + ';' + sSNVer + ';' ;
        6: sTemp := edtEmp.Text + ';' + sWo + ';' + sSN + ';' + sXid + ';' + sTime + ';' + sDefect + ';' + sSNVer + ';';
      end;

    //Check Retry SN
    if sAutoRetry = '1' then
    begin
      if UpperCase(sAutoRetryField) = 'SERIAL NUMBER' then
        TSN := UpperCase(sSN)
      else if sAutoRetryField = 'XID' then
        TSN := UpperCase(sXid)
      else if sAutoRetryField = 'BOX ID' then
        TSN := UpperCase(sBox) ;

      with dmProject.cdsTemp do
      begin
        try
          Close ;
          Params.Clear ;
          Params.CreateParam(ftString ,'TCSN',ptInput);
          SqlStr := 'SELECT AB.Work_Order, NEXT_PROCESS_ID,B.PROCESS_NAME  ' +
                    'FROM SAJET.SYS_ROUTE_DETAIL A,  SAJET.SYS_PROCESS B,  '+
                    '(SELECT Current_Status,A.Process_ID,Work_Order,Route_ID,Next_Process,B.Process_Name '+
                    'FROM SAJET.G_SN_STATUS A, SAJET.SYS_PROCESS B, SAJET.SYS_PROCESS C  '+
                    'WHERE Serial_Number = :TCSN AND A.NEXT_PROCESS = B.PROCESS_ID(+) and  '+
                    'A.PROCESS_ID = C.PROCESS_ID(+) and  ROWNUM = 1) AB  '+
                    'WHERE A.ROUTE_ID = AB.ROUTE_ID AND A.NEXT_PROCESS_ID = B.PROCESS_ID And  '+
                    ' A.SEQ = (SELECT MAX(SEQ)  FROM SAJET.SYS_ROUTE_DETAIL  '+
                    'WHERE PROCESS_ID=AB.PROCESS_ID AND ROUTE_ID = AB.ROUTE_ID AND  '+
                    'RESULT = AB.CURRENT_STATUS )' ;
          CommandText := SqlStr;
          Params.ParamByName('TCSN').AsString := TSN ;
          Open ;
          TREV := FieldByName('PROCESS_NAME').AsString ;
          if Pos('REPAIR', TREV)>0 then
          begin
            MsgStr := '警告,不良產品,是否要重測?按<是(Y)>重測,按<否(N)>放棄'+
                      #13+#10+'Warning:Production Fail!!Press<Yes> to ReTest,<No> to Abort!!'+
                      #13+#13+'Work Order='+FieldByName('Work_Order').AsString+#13+'Serial Number='+TSN+#13+
                      'Test Time='+FormatDateTime('YYYY/MM/DD HH:mm:ss',NOW) ;
            SetTimer(Handle ,10 ,1000 , @TimerProc) ;
            IF MessageBox(0,PChar(MsgStr),'警告(Warning)',MB_SYSTEMMODAL + MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON1)= IDYES  then
            begin
              KillTimer(Handle ,10);
              ShowTime := MsgDelayTime ;
              RetrySN(sSN,TREV);
              writeLog('RetryDate: '+TSN+'  -(Result: '+TREV+')');
            end else
            begin
              KillTimer(Handle ,10);
              ShowTime := MsgDelayTime ;
            end;
          end;
        finally
          Close ;
        end;
      end;
    end;

    //send data
    sResult := SendData(sTemp);
    sMsgStr := sResult ;
    writeLog('SendDate: '+sTemp+'  -(Result: '+sResult+')');
    if sResult = 'OK;' then
      sPath := 'Log'
    else
       sPath := 'ErrorLog';

    if sPath='Log' then
      if StrTmp = 'PASS' then   null
      else begin
         lablMsg.Font.Color := clfuchsia;
         //lablMsg.Font.Color := clRed ;
         //SpeedButton2Click(self);
         if sAutoMax='1' then
         begin
           Show1Click(self);
           writeLog('SN Fail and Form AutoMax');
         end;
      end;

    FindClose(sr);
    Closefile(vFile);
    sPath := sPath+'\'+sDateDir;
    ForceDirectories(sDir + sPath);
    if pos ('ErrorLog',sPath)>0 then
    begin
      sBackupFile := sDir + sPath + '\Error.Log';
      AssignFile(vFile, sBackupFile);
      if FileExists(sBackupFile) then
        Append(vFile)
      else
        Rewrite(vFile);
      WriteLn(vFile, FormatDateTime('yyyy/mm/dd hh:mm:ss', Now) + ' - ' + sr.name + ' - ' + mS + ' (' + sResult + ') ');
      CloseFile(vFile);
      writeLog('Write Error Log: '+ FormatDateTime('yyyy/mm/dd hh:mm:ss', Now) + ' - ' + sr.name + ' - ' + mS + ' (' + sResult + ') ');
    end;
    //移至Log目錄下
    sBackupFile := sDir + sPath + '\' + sr.name;
    try
      CopyFile(PChar(sTxtFile), PChar(sBackupFile), False);
      writeLog('Copy File '+sTxtFile+' to '+sBackupFile);
      if not DeleteFile(PChar(sTxtFile)) then  DeleteFile(PChar(sTxtFile));
      writeLog('Delete File: '+sTxtFile);
    except
      timer1.Enabled:=true;
      writeLog('Delete File '+sTxtFile+' Fail! And Timer Enabled ');
      exit;
    end;
    Edit1.Text := sTemp;
    IF lablMsg.Font.Color=clRed then
       lablMsg.Caption :=FormatDateTime('yyyy/mm/dd hh:mm:ss', Now)+': '+ sResult
    else
    begin
       //lablMsg.Caption := 'Transfer Finish: ' + FormatDateTime('yyyy/mm/dd hh:mm:ss', Now)+': '+ sResult;
      if StrTmp <> 'PASS' then
         lablMsg.Caption := 'Transfer Finish: ' + FormatDateTime('yyyy/mm/dd hh:mm:ss', Now)+': NG;'    //+' '+sResult
      else
        lablMsg.Caption := 'Transfer Finish: ' + FormatDateTime('yyyy/mm/dd hh:mm:ss', Now)+': '+ sResult;
    end;
    if pos ('ErrorLog',sPath)>0 then
    begin
      if (Pos('NO SN',sResult)>0) or (Pos('SN NG',sResult)>0) then
      begin
        with dmProject.cdsTemp do
        begin
          try
            Close ;
            Params.Clear ;
            Params.CreateParam(ftString ,'TCSN',ptInput);
            SqlStr := 'SELECT WORK_ORDER,SERIAL_NUMBER,  ' +
                      'ITEM_PART_SN FROM SAJET.G_SN_KEYPARTS   '+
                      ' WHERE ITEM_PART_SN=:TCSN AND ROWNUM=1 ' ;
            CommandText := SqlStr;
            Params.ParamByName('TCSN').AsString := TSN ;
            Open ;
            if not IsEmpty then
            begin
              TREV := FieldByName('SERIAL_NUMBER').AsString ;

              Close ;
              Params.Clear ;
              Params.CreateParam(ftString ,'TCSN',ptInput);
              SqlStr := 'SELECT AB.Work_Order, NEXT_PROCESS_ID,B.PROCESS_NAME  ' +
                        'FROM SAJET.SYS_ROUTE_DETAIL A,  SAJET.SYS_PROCESS B,  '+
                        '(SELECT Current_Status,A.Process_ID,Work_Order,Route_ID,Next_Process,B.Process_Name '+
                        'FROM SAJET.G_SN_STATUS A, SAJET.SYS_PROCESS B, SAJET.SYS_PROCESS C  '+
                        'WHERE Serial_Number = :TCSN AND A.NEXT_PROCESS = B.PROCESS_ID(+) and  '+
                        'A.PROCESS_ID = C.PROCESS_ID(+) and  ROWNUM = 1) AB  '+
                        'WHERE A.ROUTE_ID = AB.ROUTE_ID AND A.NEXT_PROCESS_ID = B.PROCESS_ID And  '+
                        ' A.SEQ = (SELECT MAX(SEQ)  FROM SAJET.SYS_ROUTE_DETAIL  '+
                        'WHERE PROCESS_ID=AB.PROCESS_ID AND ROUTE_ID = AB.ROUTE_ID AND  '+
                        'RESULT = AB.CURRENT_STATUS )' ;
              CommandText := SqlStr;
              Params.ParamByName('TCSN').AsString := TREV ;
              Open ;
              TREV := FieldByName('PROCESS_NAME').AsString ;
              if Trim(TREV) <>'' then
                lablMsg.Caption := 'Transfer Finish: ' + FormatDateTime('yyyy/mm/dd hh:mm:ss', Now)+': '+ TREV
              else
                lablMsg.Caption := 'Transfer Finish: ' + FormatDateTime('yyyy/mm/dd hh:mm:ss', Now)+': 已入庫' ;
              lablMsg.Font.Color := clfuchsia;
              BeepEx(sCnt);
              ShowErrorMessage(lablMsg.Caption);
            end
            else
            begin
              lablMsg.Caption :=FormatDateTime('yyyy/mm/dd hh:mm:ss', Now)+': 無SN投入信息';
              lablMsg.Font.Color := clRed;
              BeepEx(sCnt);
              ShowErrorMessage(lablMsg.Caption);
            end;
          finally
            Close ;
          end;
        end;
      end
      else
      begin
        BeepEx(sCnt);
        ShowErrorMessage(lablMsg.Caption);
        writeLog('Show Message: '+lablMsg.Caption);
      end;
    end;
  end;
  Timer1.Enabled := True;
  writeLog('Send Data Finish And Timer Enabled ');
end;

function TFormMain.CheckEmp: Boolean;
begin
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'emp_no', ptInput);
    CommandText := 'select emp_no from sajet.sys_emp '
      + 'where emp_no = :emp_no and rownum = 1';
    Params.ParamByName('emp_no').AsString := edtEmp.Text;
    Open;
    Result := (not IsEmpty);
    if not Result then
      MessageDlg('Employee not found.', mtError, [mbOK], 0);
    Close;
  end;
end;

function TFormMain.StartLink: Boolean;
begin
  Result := False;
  if SajetTransStart then
    Result := True
  else
    MessageDlg('Start Fail', mtInformation, [mbOK], 0);
  sbtnStartLink.Enabled := Result;
  sbtnStopLink.Enabled := not Result;
//  if Result then
//    sbtnStartClick(Self);
end;

procedure TFormMain.edtEmpKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
    if CheckEmp then
      editPwd.SetFocus
    else
      edtEmp.SelectAll;
end;

function TFormMain.InitialForm(var sProgram, sVersion: string): Boolean;
begin
  Result := True;
  with TIniFile.Create('.\ATE.ini') do
  begin
    edtPath.Text := ReadString('ATE', 'Path', '');
    combType.ItemIndex := combType.Items.IndexOf(ReadString('ATE', 'Type', 'ATE'));
    sProgram := ReadString('ATE', 'Test Program', '');
    sVersion := ReadString('ATE', 'Version', '');
    edtDefect.Text := ReadString('ATE', 'Defect Code', '');
    edtReason.Text := Readstring('ATE', 'Reason Code', '');
    Free;
  end;
  if not DirectoryExists(edtPath.Text) then
  begin
    edtPath.Text := '';
    Result := False;
  end;
end;

procedure TFormMain.GetTestPrgData;
begin
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select Program ' +
      'From SAJET.SYS_SPC_TP ' +
      'Where Enabled = ''Y'' ' +
      'Group by Program ' +
      'Order By Program ';
    Open;
    combTestPrg.Items.Clear;
    combTestPrg.Items.Add('');
    while not Eof do
    begin
      combTestPrg.Items.Add(Fieldbyname('Program').AsString);
      Next;
    end;
    Close;
  end;
end;

procedure TFormMain.combTestPrgChange(Sender: TObject);
begin
  OpenAPserver;
  if combTestPrg.Text <> '' then
  begin
    with dmProject.cdsTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'Select Version ' +
        'From SAJET.SYS_SPC_TP ' +
        'Where Program = ''' + combTestPrg.Text + ''' ' +
        'And Enabled = ''Y'' ' +
        'Group by Version ' +
        'Order By Version ';
      Open;
      combVersion.Items.Clear;
      while not Eof do
      begin
        combVersion.Items.Add(Fieldbyname('Version').AsString);
        Next;
      end;
      Close;
    end;
    combVersionChange(Self);
  end else
    combVersion.Items.Clear;
  CloseApServer;
end;

procedure TFormMain.combVersionChange(Sender: TObject);
begin
  OpenAPserver;
  slSpcItem.Clear;
  slSpcId.Clear;
  if combVersion.Text <> '' then
  begin
    with dmProject.cdsTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'Select Spc_Item, Spc_Id ' +
        'From SAJET.SYS_SPC ' +
        'Where Program = ''' + combTestPrg.Text + ''' ' +
        'And Version = ''' + combVersion.Text + ''' ' +
        'Order By Spc_Item ';
      Open;
      while not Eof do
      begin
        slSpcItem.Add(Fieldbyname('Spc_Item').AsString);
        slSpcId.Add(Fieldbyname('Spc_Id').AsString);
        Next;
      end;
      Close;
    end;
  end;
  CloseAPserver;
end;

procedure TFormMain.sbtnSaveClick(Sender: TObject);
  function CheckDefect: Boolean;
  begin
    openApserver;
    with dmProject.cdsTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'defect_code', ptInput);
      CommandText := 'select defect_code from sajet.sys_defect '
        + 'where defect_code = :defect_code ';
      Params.ParamByName('defect_code').AsString := edtDefect.Text;
      Open;
      Result := not IsEmpty;
      Close;
    end;
    closeAPserver;
  end;
  function CheckReason:boolean;
  begin
    with dmProject.cdsTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'Reason_code', ptInput);
      CommandText := 'select reason_code from sajet.sys_reason '
        + 'where Reason_code = :Reason_code ';
      Params.ParamByName('Reason_code').AsString := edtReason.Text;
      Open;
      Result := not IsEmpty;
      Close;
    end;
  end;
begin
  if not DirectoryExists(edtPath.Text) then
  begin
    MessageDlg('Please Setup Path.', mtError, [mbOK], 0);
    Exit;
  end;
  if edtDefect.Text <> '' then
    if not CheckDefect then begin
      MessageDlg('Defect Code: ' + edtDefect.Text + ' not found.', mtError, [mbOK], 0);
      edtDefect.SelectAll;
      edtDefect.SetFocus;
      writeLog('Save Param Fail:Defect Code Not Found');
      Exit;
    end;
  if edtReason.Text<>'' then
    if not  CheckReason then
    begin
      MessageDlg('Reason Code: ' + edtReason.Text + ' not found.', mtError, [mbOK], 0);
      edtReason.SelectAll;
      edtReason.SetFocus;
      writeLog('Save Param Fail:Reason Code Not Found');
      Exit;
    end;

  //with TIniFile.Create('SAJET.ini') do
  with TIniFile.Create('.\ATE.ini') do
  begin
    WriteString('ATE', 'Path', edtPath.Text);
    WriteString('ATE', 'Type', combType.Text);
    WriteString('ATE', 'Test Program', combTestPrg.Text);
    WriteString('ATE', 'Version', combVersion.Text);
    WriteString('ATE', 'Defect Code', edtDefect.Text);
    WriteString('ATE', 'Reason Code', edtReason.Text);
    IF chekAutoRetry.Checked  then
    begin
      WriteString('ATE Param', 'AutoRetry', '1') ;
      WriteString('ATE Param', 'Retry', '0');
    end
    else
    begin
      WriteString('ATE Param', 'AutoRetry', '0');
      WriteString('ATE Param', 'Retry', '1')
    end;
    Free;
  end;

  IF chekAutoRetry.Checked  then
  begin
    sReTry:='0';
    edtRetry.Enabled:=false;
    sAutoRetry := '1';
  end
  else
  begin
    sReTry:='1';
    edtRetry.Enabled:=True;
    sAutoRetry := '0';
  end;
  writeLog('Save Param OK');
end;

procedure TFormMain.sbtnStartClick(Sender: TObject);
begin
  //formMain.FormStyle := fsNormal;
  if sAutoMin='1'then
    CoolTrayIcon1.HideMainForm;
  Timer1.Enabled := True;
  writeLog('Start OK and Timer Enabled ');
  sbtnStart.Enabled := not Timer1.Enabled;
  edtEmp.Enabled := False;
  sbtnStop.Enabled := Timer1.Enabled;
  editStatus.Text:='1';
end;

procedure TFormMain.sbtnStopClick(Sender: TObject);
begin
  Timer1.Enabled := False;
  sbtnStart.Enabled := not Timer1.Enabled;
  edtEmp.Enabled := True;
  sbtnStop.Enabled := Timer1.Enabled;
  editStatus.Text:='0';
end;

procedure TFormMain.FormCreate(Sender: TObject);
  procedure AddAPServer(ServerName: string);
  begin
    dmProject.SimpleObjectBroker1.Servers.Add;
    dmProject.SimpleObjectBroker1.Servers[dmProject.SimpleObjectBroker1.Servers.Count - 1].ComputerName := ServerName;
    dmProject.SimpleObjectBroker1.Servers[dmProject.SimpleObjectBroker1.Servers.Count - 1].Enabled := True;
    dmProject.SocketConnection1.Connected:=true;
  end;
var F: TextFile; S: string; bOK: Boolean;
begin
  CoolTrayIcon1.ShowMainForm;
  gbShow := True;
  bOK := False;
  if not FileExists(GetCurrentDir + '\ATEServer.cfg') then
  begin
    MessageDlg('Cann''t find ATEServer.cfg !', mtError, [mbOK], 0);
    Application.Terminate;
  end
  else
  begin
    AssignFile(F, GetCurrentDir + '\ATEServer.cfg');
    Reset(F);
    while True do
    begin
      Readln(F, S);
      if Trim(S) = '' then
        Break;
      AddAPServer(Trim(S));
      bOK := True;
    end;
    CloseFile(F);
    if not bOK then
    begin
      MessageDlg('Cann''t find ATE Server Address !', mtError, [mbOK], 0);
      Application.Terminate;
      Close;
    end;
  end;
end;

procedure TFormMain.FormShow(Sender: TObject);
var sProgram, sVersion,sTimerMsg: string; PIni: TIniFile; i: Integer;
    sDefect,sAOI:TSTringList;
    sCntTmp:string; 
begin
  temp:=0;
  SetTheRegion;
  lblVer1.Caption:='Ver: '+ GetVersion(application.ExeName);
  lblVer2.Caption:=lblVer1.Caption;
  if gbShow then begin
    gbShow := False;
    slField := TSTringList.Create;
    slValue := TSTringList.Create;
    slDefectATE:= TSTringList.Create;
    G_AOI_SN:=TSTringList.Create;
    G_AOI_Param:=TSTringList.Create;
    slDefectSFC:= TSTringList.Create;
    sAOIParam:= TSTringList.Create;
    sAOISeq:= TSTringList.Create;
    sDefect:=TSTringList.Create;
    sAOI:= TSTringList.Create;
    PIni := TInifile.Create('.\ATE.ini');

    sRetry:=PIni.ReadString('ATE Param', 'Retry', '');
    if sReTry='' then
    begin
       PIni.writestring('ATE Param', 'Retry', '0');
       sReTry:='0';
    end;
    if sRetry<>'1' then edtRetry.Enabled:=false;

    sAutoRetry := PIni.ReadString('ATE Param', 'AutoRetry', '') ;
    if sAutoRetry='' then
    begin
       PIni.writestring('ATE Param', 'AutoRetry', '0');
       sAutoRetry:='0';
    end;
    if sAutoRetry<>'1' then
    begin
      if sRetry<>'1' then edtRetry.Enabled:=false ;
      chekAutoRetry.Checked := False ;
      lablAutoRetry.Enabled := chekAutoRetry.Enabled ;
    end
    else
    begin
      chekAutoRetry.Checked := True ;
      lablAutoRetry.Enabled := chekAutoRetry.Enabled ;
      edtRetry.Enabled:=false ;
      PIni.writestring('ATE Param', 'Retry', '0');
      sReTry:='0';
    end;

    DefaultButton := PIni.ReadString('ATE Param','DefaultButton','YESID');
    MsgDelayTime := PIni.ReadInteger('ATE Param','MsgDelayTime',3) ;
    ShowTime := MsgDelayTime ;
    
    sAutoRetryField := PIni.ReadString('ATE Param', 'AutoRetryField', 'SERIAL NUMBER');

    sUpper:=PIni.ReadString('ATE Param', 'UpperCase', '');
    if  sUpper='' then
    begin
       PIni.writestring('ATE Param', 'UpperCase', '1');
       sUpper:='1';
    end;
    sCntTmp:= PIni.ReadString('ATE Param', 'BeepCnt', '');
    if  sCntTmp='' then
    begin
       PIni.writestring('ATE Param', 'BeepCnt', '5');
       sCntTmp:='5';
    end;
    sCnt:=strtoint(sCntTmp);

    sAutoMin:= PIni.ReadString('ATE Param', 'AutoMin', '');
    if  sAutoMin='' then
    begin
       PIni.writestring('ATE Param', 'AutoMin', '1');
       sAutoMin:='1';
    end;

    sAutoMax:= PIni.ReadString('ATE Param', 'AutoMax', '');
    if  sAutoMax='' then
    begin
       PIni.writestring('ATE Param', 'AutoMax', '0');
       sAutoMax:='0';
    end;

    sTimerMsg := PIni.ReadString('ATE Param', 'TimerMsg', '');
    if (sTimerMsg='') or (strtointdef(sTimerMsg,999)<1000) then
    begin
       PIni.writestring('ATE Param', 'TimerMsg', '1000');
       sTimerMsg:='1000';
    end;
    timer2.Interval:=strtointdef(sTimerMsg,1000);

    if sRetry='1' then  sbtnRetry.Enabled:= true
    else sbtnRetry.Enabled:= false;

    sOntop:= PIni.ReadString('ATE Param', 'Ontop', '');
    if sOntop='' then
    begin
       PIni.writestring('ATE Param', 'Ontop', '1');
       sOntop:='1';
    end;

    iFeild:= PIni.ReadInteger('AOI Param', 'ErrorCode Field', 6);
    iLocation:= PIni.ReadInteger('AOI Param', 'ErrorCode Location', 1);
    iCode:= PIni.ReadInteger('AOI Param', 'ErrorCode', 3);
    sAOItype:=PIni.ReadString('AOI Param','Type','BOX');
    sOrderBy:=PIni.ReadString('AOI Param','OrderBy','ASC');
    PIni.ReadSection('ATE Field', slField);
    for i := 0 to slField.Count - 1 do
      slValue.Add(UpperCase(PIni.ReadString('ATE Field', slField[i], slField[i])));
    //7.14 Linkey Insert ;For Mapping the ATE Defect Code to SFC Defect Code;
    PIni.readsectionvalues('Defect Code',sDefect);
    ProParam(sDefect,slDefectATE,slDefectSFC);
    ////////////////////////////
    PIni.readsectionvalues('AOI Field',sAOI);
    ProParam(sAOI,sAOIParam,sAOISeq);
    ////////////////////////

    PIni.Free;
    sDefect.Free;
    sAOI.Free;
    slSpcItem := TStringList.Create;
    slSpcId := TStringList.Create;
    GetTestPrgData;
    if not InitialForm(sProgram, sVersion) then
    begin
      MessageDlg('Configuration not Completed !! ', mtError, [mbOK], 0);
      Exit;
    end;
    combTestPrg.ItemIndex := combTestPrg.Items.IndexOf(sProgram);
    combTestPrgChange(Self);
    combVersion.ItemIndex := combVersion.Items.IndexOf(sVersion);
    combVersionChange(Self);

    //MoveFile;                   //備份舊的測試記錄
    DelLogFile(Trim(edtPath.Text));   //刪除舊的測試記錄

    //刪除Log文件
    DelOldFileByDate('.\Log');
    DelOldFileByDate('.\ATELOG');
    DelOldFileByDate(Trim(edtPath.Text)+'\ErrorLog');
    DelLogFile(Trim(edtPath.Text)+'\BackUp');

    if not StartLink then
    begin
      Messagedlg('Initialization Fail! Please Check TGS and then Restart! ', mtError, [mbOK], 0);
      Close ;
    end;
  end;
end;

procedure TFormMain.sbtnStartLinkClick(Sender: TObject);
begin
   StartLink;
end;

procedure TFormMain.sbtnStopLinkClick(Sender: TObject);
begin
  sbtnStartLink.Enabled := SajetTransClose;
  sbtnStopLink.Enabled := not sbtnStartLink.Enabled;
end;

procedure TFormMain.combTypeChange(Sender: TObject);
begin
  if combType.ItemIndex <> 0 then
  begin
    combTestPrg.ItemIndex := -1;
    combVersion.ItemIndex := -1;
  end
end;

procedure TFormMain.sbtnLoginClick(Sender: TObject);
var sTemp:string;
begin
  ClearData;
  OpenAPserver;
  if Login  then begin
    edtEmp.Enabled := False;
    editPWD.Enabled := False;
    sbtnLogout.Enabled := True;
    sbtnLogin.Enabled := False;
    sbtnPath.Enabled := SetStatusbyAuthority;
    combType.Enabled := sbtnPath.Enabled;
    combTestPrg.Enabled := sbtnPath.Enabled;
    combVersion.Enabled := sbtnPath.Enabled;
    edtDefect.Enabled := sbtnPath.Enabled;
    edtReason.Enabled := sbtnPath.Enabled;
    sbtnSave.Enabled := sbtnPath.Enabled;
    chekAutoRetry.Enabled := sbtnPath.Enabled;
    lablAutoRetry.Enabled := chekAutoRetry.Enabled ;
    sbtnStart.Enabled := True;
    writeLog('Emp: '+edtEmp.Text+' Login ');
  end;
  sTemp:=GetVersion(GetCurrentDir+'\'+'ATE.exe');
  if not CheckVersion(sTemp) then
  begin
     MessageDlg('Version Error!!', mtError, [mbOK], 0);
     sbtnStart.Enabled :=False;
     sbtnPath.Enabled := False;
     combType.Enabled := sbtnPath.Enabled;
     combTestPrg.Enabled := sbtnPath.Enabled;
     combVersion.Enabled := sbtnPath.Enabled;
     edtDefect.Enabled := sbtnPath.Enabled;
     edtReason.Enabled := sbtnPath.Enabled;
     sbtnSave.Enabled := sbtnPath.Enabled;
     chekAutoRetry.Enabled := sbtnPath.Enabled;
     lablAutoRetry.Enabled := chekAutoRetry.Enabled ;
  end;
  CloseAPServer;

end;

procedure TFormMain.ClearData;
begin
  sbtnPath.Enabled := False;
  combType.Enabled := False;
  combTestPrg.Enabled := False;
  combVersion.Enabled := False;
  edtDefect.Enabled := False;
  edtReason.Enabled := false;
  sbtnSave.Enabled := False;
  sbtnStart.Enabled := False;
  sbtnStop.Enabled := False;
end;

procedure TFormMain.editPwdKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
    sbtnLoginClick(Self);
end;

procedure TFormMain.sbtnLogoutClick(Sender: TObject);
begin
  ClearData;
  Timer1.Enabled := False;
  WriteLog('Timer Close and Emp: '+edtEmp.Text+' Logout');
  sbtnLogin.Enabled := True;
  sbtnLogout.Enabled := False;
  edtEmp.Text := '';
  editPWD.Text := '';
  edtEmp.Enabled := True;
  editPWD.Enabled := True;
  edtEmp.SetFocus;
end;

procedure TFormMain.sbtnRetryClick(Sender: TObject);
begin
  fRetry.Image1.Picture.Bitmap :=  Image1.Picture.Bitmap;
  if fRetry.ShowModal = mrOk then
  begin
     //showmessage('OK');
    //lablMsg.Caption:='Retry OK!';  clblue
    lablMsg.Font.Color := clBlack ;
    lablMsg.Caption :=' Retry OK! ';
    if sAutoMin ='1' then
      SpeedButton2Click(self);
  end;
end;

procedure TFormMain.Timer2Timer(Sender: TObject);
begin
  if  timer2.Enabled then
    CloseErrorMessage;
end;

procedure TFormMain.edtRetryKeyPress(Sender: TObject; var Key: Char);
var sResult,sString:string;
begin
  if sRetry<>'1' then exit;
  if key=#13 then
  begin
    if trim(edtRetry.Text)='' then exit;
    sResult:='';
    //良品不能做Retry動作，add by key 2009/1/8
    if not CheckSNStatus(edtRetry.Text,sResult) then
    begin
      edtRetry.SelectAll;
      edtRetry.SetFocus;
      lablMsg.Font.Color := clRed;
      lablMsg.Caption:='Retry: '+sResult;
      BeepEx(sCnt);
      writeLog('Retry '+trim(edtRetry.Text)+' Fail: '+sResult);
      exit;
    end;

    IF trim(edtReason.Text)<>'' THEN
      sString:=trim(edtRetry.Text)+';'+trim(edtReason.Text)
    ELSE
      sString:=trim(edtRetry.Text)+';'+'N/A';

    //RETRY EMP
    sString:=sString + ';'+ edtEmp.Text;

    if not Transdata(sString,sResult) then
    begin
      edtRetry.SelectAll;
      edtRetry.SetFocus;
      lablMsg.Caption:='Retry: '+sResult;
      lablMsg.Font.Color := clred;
      BeepEx(sCnt);
      writeLog('Retry '+trim(edtRetry.Text)+' Fail: '+sResult);
    end
    else begin
      //重測顯示由藍色變為黃色
      //lablMsg.Font.Color := clBlue;
      lablMsg.Font.Color := clBlack ;
      lablMsg.Caption:='Retry: '+sResult;
      writeLog('Retry '+trim(edtRetry.Text)+' OK: '+sResult);
      formmain.FormStyle:=fsNormal;
      if sAutoMin ='1' then
         SpeedButton2Click(self);
    end;
  end;
end;

procedure TFormMain.edtRetryClick(Sender: TObject);
begin
  edtRetry.SelectAll;
  edtRetry.SetFocus;
end;

procedure TFormMain.RetrySN(TREV : string; out TRES : string) ;
var sResult,sString:string;
begin
  if trim(TREV)='' then exit;
  sResult:='';
  TRES := 'RETRY FAILE' ;
  
  //良品不能做Retry動作，add by key 2009/1/8
  if not CheckSNStatus(TREV,sResult) then
  begin
    lablMsg.Caption:='Retry: '+sResult;
    lablMsg.Font.Color := clred;
    TRES := lablMsg.Caption ;
    BeepEx(sCnt);
    writeLog('Retry '+trim(TREV)+' Fail: '+sResult);
    exit;
  end;

  IF trim(TREV)<>'' THEN
    sString:=trim(TREV)+';'+trim(edtReason.Text)
  ELSE
    sString:=trim(TREV)+';'+'N/A';

  //RETRY EMP
  sString:=sString + ';'+ edtEmp.Text;

  if not Transdata(sString,sResult) then
  begin
    lablMsg.Caption:='Retry: '+sResult;
    lablMsg.Font.Color := clred;
    TRES := lablMsg.Caption ;
    BeepEx(sCnt);
    writeLog('Retry '+trim(TREV)+' Fail: '+sResult);
  end
  else begin
    lablMsg.Font.Color :=clBlack ;   //clBlue
    lablMsg.Caption:='Retry: '+sResult;
    TRES := lablMsg.Caption ;
    writeLog('Retry '+trim(TREV)+' OK: '+sResult);
    formmain.FormStyle:=fsNormal;
    if sAutoMin ='1' then
       SpeedButton2Click(self);
  end;
end;

procedure TFormMain.lablAutoRetryClick(Sender: TObject);
begin
  chekAutoRetry.Checked := not chekAutoRetry.Checked ;  
end;

//取得文件創建時間
function TFormMain.GetFileDateTime(const FileName: string): TDateTime;
var
  Handle: THandle;
  FindData: TWin32FindData;
  LocalFileTime: TFileTime;
  DosDateTime: Integer;
begin
  Handle := FindFirstFile(PChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then begin
      FileTimeToLocalFileTime(FindData.ftCreationTime, LocalFileTime);
      if FileTimeToDosDateTime(LocalFileTime, LongRec(DosDateTime).Hi,
        LongRec(DosDateTime).Lo) then
      begin
        Result := FileDateToDateTime(DosDateTime);
        Exit;
      end;
    end;
  end;
  Result := -1;
end;

function TFormMain.FileDel_Zhijie(FileString : String;UndoMK : Boolean = False ): Boolean ;
//只刪除文件 , 不放回收站
var
   SHFileOpStruct: TSHFileOpStruct;
begin
  Result := False ;
  With SHFileOpStruct  do
  begin
    Wnd := Handle ;
    wFunc := FO_DELETE ;  //FO_MOVE,FO_COPY,FO_DELETE,FO_RENAME  // H1是移動 H2是復制 H3是刪除 H4是更名
    pFrom := PChar(FileString + #0);
    pTo := nil;
    if UndoMK then
      fFlags := FOF_ALLOWUNDO + FOF_NOCONFIRMATION + FOF_SILENT   // 不顯示進度框 , 不提示系統信息 ,放入回收站
    else
      fFlags := FOF_NOCONFIRMATION + FOF_SILENT ;   // 不顯示進度框 , 不提示系統信息 ,不放入回收站
    hNameMappings:= nil;
    fAnyOperationsAborted:= False;
    lpszProgressTitle:= nil;
  End ;
  Result := (SHFileOperation(SHFileOpStruct)=0);
End ;

function TFormMain.DelLogFile(Path: string): Boolean;
var
  sr : TSearchRec ;
  sPath : string;
begin
  if FindFirst(Path +'\*.txt', faAnyFile, sr) = 0 then
  begin
    repeat
      if ((sr.Name= '.')or(sr.Name='..'))then
        Continue;
      sPath := Path+ '\'+sr.Name;  //找到的文件或者子目錄
      if (DirectoryExists(sPath))   then  //查找子目錄
        DelLogFile(sPath);
      if (ExtractFileExt(sr.Name)= '.txt')   then
        FileDel_Zhijie(sPath) ;
    until FindNext(sr)<>0;
    FindClose(sr);
  end;
end;

procedure TFormMain.DelOldFileByDate (sFilePath : string);
var
  sr: TSearchRec;
  sPath,sFile : string;
  FileDate : TDateTime ;
  StartDt,EndDt : Integer ;
  Year, Month, Day, Hour, Min, Sec, MSec : Word ;
  FileYear, FileMonth, FileDay : Word ;
begin
  if Copy(sFilePath,Length(sFilePath),1) <> '\' then
    sPath := sFilePath + '\'
  else
    sPath := sFilePath;
  if FindFirst(sPath + '*.log', faAnyFile, sr) = 0 then
  begin
    repeat
      if ((sr.Name= '.')or(sr.Name='..'))then
        Continue;
      sFile := sPath + sr.Name;  //找到的文件或者子目錄
      if (DirectoryExists(sFile))   then  //查找子目錄
        FileDate := GetFileDateTime(sFile);
      if (UpperCase(ExtractFileExt(sr.Name))= '.LOG')   then
        FileDate := GetFileDateTime(sFile) ;

      DecodeDate(Now, Year,Month,Day);
      DecodeDate(FileDate, FileYear, FileMonth, FileDay);

      StartDt := StrToInt(IntToStr(Year)+ IntToStr(Month) + IntToStr(Day));
      EndDt := StrToInt(IntToStr(FileYear)+ IntToStr(FileMonth)+ IntToStr(FileDay)) ;

      if StartDt - EndDt >= 1 then  FileDel_Zhijie(sFile) ;
    until FindNext(sr)<>0;
    FindClose(sr);
  end;
end;

end.

