unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, MConnect, ObjBrkr, DB, DBClient,
  SConnect, CoolTrayIcon, TextTrayIcon, Menus,TlHelp32,Registry;

const
MAX_HOSTNAME_LEN = 128; { from IPTYPES.H }
MAX_DOMAIN_NAME_LEN = 128;
MAX_SCOPE_ID_LEN = 256;
MAX_ADAPTER_NAME_LENGTH = 256;
MAX_ADAPTER_DESCRIPTION_LENGTH = 128;
MAX_ADAPTER_ADDRESS_LENGTH = 8;

 

type
    TIPAddressString = array[0..4 * 4 - 1] of AnsiChar;
    PIPAddrString = ^TIPAddrString;
    TIPAddrString = record
    Next: PIPAddrString;
    IPAddress: TIPAddressString;
    IPMask: TIPAddressString;
    Context: Integer;
end;



PFixedInfo = ^TFixedInfo;
TFixedInfo = record { FIXED_INFO }
    HostName: array[0..MAX_HOSTNAME_LEN + 3] of AnsiChar;
    DomainName: array[0..MAX_DOMAIN_NAME_LEN + 3] of AnsiChar;
    CurrentDNSServer: PIPAddrString;
    DNSServerList: TIPAddrString;
    NodeType: Integer;
    ScopeId: array[0..MAX_SCOPE_ID_LEN + 3] of AnsiChar;
    EnableRouting: Integer;
    EnableProxy: Integer;
    EnableDNS: Integer;
end;


PIPAdapterInfo = ^TIPAdapterInfo;
TIPAdapterInfo = record { IP_ADAPTER_INFO }
    Next: PIPAdapterInfo;
    ComboIndex: Integer;
    AdapterName: array[0..MAX_ADAPTER_NAME_LENGTH + 3] of AnsiChar;
    Description: array[0..MAX_ADAPTER_DESCRIPTION_LENGTH + 3] of AnsiChar;
    AddressLength: Integer;
    Address: array[1..MAX_ADAPTER_ADDRESS_LENGTH] of Byte;
    Index: Integer;
    _Type: Integer;
    DHCPEnabled: Integer;
    CurrentIPAddress: PIPAddrString;
    IPAddressList: TIPAddrString;
    GatewayList: TIPAddrString;
    DHCPServer: TIPAddrString;
    HaveWINS: Bool;
    PrimaryWINSServer: TIPAddrString;
    SecondaryWINSServer: TIPAddrString;
    LeaseObtained: Integer;
    LeaseExpires: Integer;
end;

//---------------------------Process Protect---------------------------
{
type
TWin = record
    Msg:TMsg;
    wClass:TWndClass;
    hMain:integer;
end;

type
TDbgUiDebugActiveProcess = function(ProcessHandle: THANDLE): Cardinal; stdcall;
TDbgUiConnectToDbg = function:Cardinal; stdcall;
 }
//---------------------------uMain----------------------------------
type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    lbl1: TLabel;
    lbl2: TLabel;
    edtUser: TEdit;
    edtPwd: TEdit;
    btnLogin: TBitBtn;
    btnLogout: TBitBtn;
    btnGetIP: TBitBtn;
    btnSetIP: TBitBtn;
    btnExit: TBitBtn;
    cmbAdapter: TComboBox;
    lbl3: TLabel;
    lbl4: TLabel;
    edtIP: TEdit;
    lbl5: TLabel;
    edtMask: TEdit;
    lbl6: TLabel;
    edtGateway: TEdit;
    lblMac: TLabel;
    con1: TSocketConnection;
    smplbjctbrkr1: TSimpleObjectBroker;
    Qry1: TClientDataSet;
    pm1: TPopupMenu;
    Show1: TMenuItem;
    N1: TMenuItem;
    tmr1: TTimer;
    tmr2: TTimer;
    cltrycn1: TCoolTrayIcon;
    mmo1: TMemo;
    procedure btnExitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnGetIPClick(Sender: TObject);
    procedure Show1Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure cmbAdapterSelect(Sender: TObject);
    procedure btnSetIPClick(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtUserKeyPress(Sender: TObject; var Key: Char);
    procedure edtPwdKeyPress(Sender: TObject; var Key: Char);
    procedure btnLoginClick(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
    procedure tmr2Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    sOldIP,sOldMask,sOldGateway,sEMPID:string;
    IsConnSvr,IsAdminLogin:Boolean;
    procedure DisableConnWindow;
    function MakeMeCritical(Yes: Boolean): Boolean;
    procedure SetAutoRun;
    Function GetComputer:String;
    Function LoadApServer:Boolean;
    function GetAuthority(qrytmp:TClientDataSet;progr,func,empid:string):Boolean;
    procedure UpdateTerminalStatus;
    procedure InsertLogData;
  end;

var
  Form1: TForm1;
  {Win:TWin;
  Msg: TMsg; }
  function GetAdaptersInfo(AI: PIPAdapterInfo; var BufLen: Integer): Integer; stdcall; external 'iphlpapi.dll' Name 'GetAdaptersInfo';


implementation

{$R *.dfm}

{
function findprocess(TheProcName: string): DWORD;
var
isOK: Boolean;
ProcessHandle: Thandle;
ProcessStruct: TProcessEntry32;
begin
    ProcessHandle := createtoolhelp32snapshot(Th32cs_snapprocess, 0);
    processStruct.dwSize := sizeof(ProcessStruct);
    isOK := process32first(ProcessHandle, ProcessStruct);
    Result := 0;
    while isOK do
    begin
        if Trim(UpperCase(TheProcName)) = Trim(UpperCase(ProcessStruct.szExeFile)) then
        begin
            Result := ProcessStruct.th32ProcessID;
            CloseHandle(ProcessHandle);
            exit;
        end;
        isOK := process32next(ProcessHandle, ProcessStruct);
    end;
    CloseHandle(ProcessHandle);
end;

procedure SetPrivilege;
var
TPPrev, TP: TTokenPrivileges;
TokenHandle: THandle;
dwRetLen: DWORD;
lpLuid: TLargeInteger;
begin
    OpenProcessToken(GetCurrentProcess, TOKEN_ALL_ACCESS, TokenHandle);
    if (LookupPrivilegeValue(nil, 'SeDebugPrivilege', lpLuid)) then
    begin
        TP.PrivilegeCount := 1;
        TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
        TP.Privileges[0].Luid := lpLuid;
        AdjustTokenPrivileges(TokenHandle, False, TP, SizeOf(TPPrev), TPPrev, dwRetLen);
    end;
    CloseHandle(TokenHandle);
end;

procedure protectme;
var
MyDbgUiDebugActiveProcess: TDbgUiDebugActiveProcess;
MyDbgUiConnectToDbg: TDbgUiConnectToDbg;
dllhandle: dword;
dwret:dword;
ProcessHandle: dword;
begin
    dllhandle := LoadLibrary('ntdll.dll');
    if dllhandle <> 0 then
    begin
        MyDbgUiConnectToDbg := GetProcAddress(dllhandle, 'DbgUiConnectToDbg');
        MyDbgUiDebugActiveProcess := GetProcAddress(dllhandle, 'DbgUiDebugActiveProcess');
        MyDbgUiConnectToDbg;
        ProcessHandle:=OpenProcess(process_all_access, False, findprocess('winlogon.exe'));
        dwret:=MyDbgUiDebugActiveProcess(ProcessHandle);
        if dwret<>0 then messagebox(0,pchar('進程保護失敗'),'提示',0) else
        messagebox(0,pchar('進程保護成功'),'提示',0)
    end;
    CloseHandle(dllhandle);
end;   }

function TForm1.LoadApServer: Boolean;
var F: TextFile;
   S,sfileName: string;
   i:Integer;
begin
   Result := False;
   mmo1.Lines.Add(' begin load file ');
   con1.Connected := False;
   //mmo1.Lines.Add(' Clear servers ');
   for i:=0 to smplbjctbrkr1.Servers.count-1 do
   begin
       smplbjctbrkr1.Servers[i].Enabled :=false;
       smplbjctbrkr1.Servers[i].ComputerName :='';
       smplbjctbrkr1.Servers[i].Free;
   end;
   smplbjctbrkr1.Servers.Clear;
   //mmo1.Lines.Add('End Clear  ');
   con1.Host:='';
   con1.Address:='';
   i:=0;
   sfileName := ExtractFilePath(ParamStr(0))+'ApServer.cfg';
   mmo1.Lines.Add(sfileName);
   if  FileExists(sfileName) then
     AssignFile(F, sfileName)
   else
     exit;

   Reset(F);
   while True do
   begin
      Readln(F, S);
      if trim(S) <> '' then
      begin
          smplbjctbrkr1.Servers.Add;
          //mmo1.Lines.Add('smplbjctbrkr1 begin add ');
          smplbjctbrkr1.Servers[smplbjctbrkr1.Servers.Count-1].ComputerName := Trim(S);
          smplbjctbrkr1.Servers[smplbjctbrkr1.Servers.Count-1].Enabled := True;
          mmo1.Lines.Add(smplbjctbrkr1.Servers[i].ComputerName);
          Inc(i);
      end else
        Break;
   end;
   //mmo1.Lines.Add('i= '+intTostr(i));
   CloseFile(F);
   Result := True;
end;


function TForm1.GetComputer:String;
   var  Buffer:Pchar;
        BufferLen:DWORD;
        StrName:String;
begin
     BufferLen:=  MAX_COMPUTERNAME_LENGTH+1 ;
     GetMem(Buffer,BufferLen);
     GetComputerName(Buffer,BufferLen);
     StrName:=StrPas(Buffer);
     FreeMem(Buffer,BufferLen);
     Result:=StrName;
end;

function MACToStr(ByteArr: PByte; Len: Integer): string;
begin
    Result := '';
    while (Len > 0) do
    begin
        Result := Result + IntToHex(ByteArr^, 2) + '-';
        ByteArr := Pointer(Integer(ByteArr) + SizeOf(Byte));
        Dec(Len);
    end;
    SetLength(Result, Length(Result) - 1); { remove last dash }
end;

function GetMaskString(Addr: PIPAddrString): string;
begin
    Result := '';
    while (Addr <> nil) do
    begin
        Result := Result + Addr^.IPMask + #13;
        Addr := Addr^.Next;
    end;
end;

function GetIPString(Addr: PIPAddrString): string;
begin
    Result := '';
    while (Addr <> nil) do
    begin
        Result := Result + Addr^.IPAddress + #13;
        Addr := Addr^.Next;
    end;
end;

procedure TForm1.DisableConnWindow;
var hwnd1,hwnd2,hwnd3,hwnd4:Integer;
begin
     hwnd1  := FindWindow('#32770','區域連線 狀態');
     if hwnd1 <>0 then
     begin
         hwnd2 := FindWindowEx(hwnd1,0,'#32770','一般');
         if hwnd2 <>0 then
         begin
             hwnd3 :=   FindWindowEx(hwnd2,0,'Button','內容(&P)');
             hwnd4 :=   FindWindowEx(hwnd2,0,'Button','停用(&D)');
             If  IsWindowEnabled(hwnd3) then EnableWindow(hwnd3,false);
             If  IsWindowEnabled(hwnd4) then EnableWindow(hwnd4,false);
         end;
     end;

     hwnd1  := FindWindow('#32770','區域連線 內容');
     if hwnd1 <>0 then
     begin
         hwnd2 := FindWindowEx(hwnd1,0,'#32770','網路功能');
         if hwnd2 <>0 then
         begin
             If  IsWindowEnabled(hwnd2) then EnableWindow(hwnd2,false);
             hwnd3 :=   FindWindowEx(hwnd2,0,'Button','內容(&R)');
             If  IsWindowEnabled(hwnd3) then EnableWindow(hwnd3,false);
         end;
     end;

end;
procedure TForm1.btnExitClick(Sender: TObject);
begin
   MakeMeCritical(False);
   Application.Terminate;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   WindowState := wsMinimized;
   Action := caNone;
   cltrycn1.HideMainForm;

end;

procedure TForm1.btnGetIPClick(Sender: TObject);
Var
AI,Work : PIPAdapterInfo;
Size : Integer;
Res : Integer;
I : Integer;
begin
    Size := 5120;
    GetMem(AI,Size);
    Res := GetAdaptersInfo(AI,Size);
    if (Res <> ERROR_SUCCESS) then
    begin
        SetLastError(Res);
        RaiseLastWin32Error;
    end;
    Work := AI;
    I := 1;
    cmbAdapter.Items.Clear;
    cmbAdapter.Text :='';

    Repeat
        cmbAdapter.Items.Add(PChar(@Work^.Description));
        cmbAdapter.ItemIndex :=0;
        if i=1 then
        begin
            lblMac.Caption := MACToStr(@Work^.Address,Work^.AddressLength);
            edtIP.Text := Trim(GetIPString(@Work^.IPAddressList)) ;
            edtMask.Text := Trim(GetMaskString(@Work^.IPAddressList)) ;
            edtGateway.Text := Trim(Work^.GatewayList.IPAddress);
            sOldIP :=  edtIP.Text;
            sOldMask := edtMask.Text;
            sOldGateway := edtGateway.Text;
        end;
        Inc(I);
        Work := Work^.Next;
    Until (Work = nil);

    FreeMem(AI);
    
end;
function TForm1.GetAuthority(qrytmp:TClientDataSet;progr,func,empid:string):Boolean;
var Authority :string;
begin
     Result :=false;
     try
          with qrytmp do
          begin
               Close;
               Params.Clear;
               Params.CreateParam(ftString,'empId',ptInput);
               Params.CreateParam(ftString,'Prog',ptInput);
               Params.CreateParam(ftString,'func',ptInput);
               CommandText := 'select A.AUTHORITYS from SAJET.SYS_ROLE_PRIVILEGE a,sajet.sys_role_emp b '+
                              ' where A.ROLE_ID =B.ROLE_ID and A.PROGRAM =:prog '+
                              ' and A.FUNCTION =:func and B.EMP_ID =:empId ' ;
               Params.ParamByName('empid').AsString :=empid;
               Params.ParamByName('prog').AsString :=progr;
               Params.ParamByName('func').AsString :=func;
               Open;

               Authority := fieldbyName('AUTHORITYS').AsString;

               if (Authority = 'Allow To Execute') or  (Authority = 'Full Control') then
                   result :=True
               else
                   result :=false;
          end;
     except
          Result :=false;
     end;
end;

procedure TForm1.Show1Click(Sender: TObject);
begin
   cltrycn1.ShowMainForm;
   Form1.WindowState :=wsNormal;
end;

procedure TForm1.N1Click(Sender: TObject);
begin
   Form1.WindowState :=wsMinimized;
   cltrycn1.HideMainForm;
end;

procedure TForm1.cmbAdapterSelect(Sender: TObject);
Var
AI,Work : PIPAdapterInfo;
Size : Integer;
Res : Integer;
I : Integer;
begin
    Size := 5120;
    GetMem(AI,Size);
    Res := GetAdaptersInfo(AI,Size);
    if (Res <> ERROR_SUCCESS) then
    begin
        SetLastError(Res);
        RaiseLastWin32Error;
    end;
    Work := AI;
    I := 1;

    Repeat
        if cmbAdapter.Text = PChar(@Work^.Description) then
        begin
            lblMac.Caption := MACToStr(@Work^.Address,Work^.AddressLength);
            edtIP.Text := Trim(GetIPString(@Work^.IPAddressList)) ;
            edtMask.Text := Trim(GetMaskString(@Work^.IPAddressList)) ;
            edtGateway.Text := Trim(Work^.GatewayList.IPAddress);
            sOldIP :=  edtIP.Text;
            sOldMask := edtMask.Text;
            sOldGateway := edtGateway.Text;
            Break;
        end;
        Inc(I);
        Work := Work^.Next;
    Until (Work = nil);

    FreeMem(AI);

end;

procedure TForm1.btnSetIPClick(Sender: TObject);
var netstr,sNewIp,sNewMask,sNewGate:string;
begin

   if edtIP.Text ='' then exit;
   if edtMask.Text ='' then exit;
   if edtGateway.Text ='' then exit;
   sNewIp := edtIP.Text ;
   sNewMask := edtMask.Text ;
   sNewGate := edtGateway.Text ;
   if (edtIP.Text <> sOldIP) or  (edtMask.Text <> sOldMask)
       or (edtGateway.Text <> sOldGateway) then
   begin
       netstr := 'netsh interface ip set address name="區域連線" source=static addr='+edtIp.Text+
                    ' mask='+edtMask.Text +' gateway= '+edtGateway.Text;
       WinExec(PChar(netstr),SW_HIDE);
       
       if not IsAdminLogin then
       begin
           try
               LoadApServer;
               UpdateTerminalStatus;
               InsertLogData;
           except

           end;
       end;
       Sleep(2000);
       btnGetIP.Click;
       if (edtIP.Text <> sNewIp) or  (edtMask.Text <> sNewMask)
                  or (edtGateway.Text <> sNewGate) or (edtIP.Text ='0.0.0.0') then
       begin
            MessageDlg('沒有設置成功',mtError,[mbOK],0);
            edtIP.Text := sNewIp;
            edtMask.Text := sNewMask;
            edtGateway.Text := sNewGate;
            Exit;
       end;

       btnLogout.Click;
   end;


end;

procedure TForm1.UpdateTerminalStatus;
begin

    with Qry1 do
    begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'mac',ptInput);
       CommandText :='SELECT * FROM SAJET.G_IP_STATUS WHERE MAC_ADDRESS=:MAC';
       Params.ParamByName('mac').AsString := lblMac.Caption;
       Open;
       if IsEmpty then
       begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString,'newip',ptInput);
           Params.CreateParam(ftString,'newmask',ptInput);
           Params.CreateParam(ftString,'newgateway',ptInput);
           Params.CreateParam(ftString,'mac',ptInput);
           Params.CreateParam(ftString,'computer',ptInput);
           CommandText :='INSERT INTO SAJET.G_IP_STATUS(COMPUTER_NAME,IP_Addr,MASK,GATEWAY,UPDATE_TIME,MAC_ADDRESS ) '+
                         'VALUES (:computer,:newip,:newmask,:newgateway,sysdate,:mac) ';
           Params.ParamByName('newip').AsString := edtIP.Text;
           Params.ParamByName('newmask').AsString := edtMask.Text;
           Params.ParamByName('newgateway').AsString := edtGateway.Text;
           Params.ParamByName('mac').AsString := lblMac.Caption;
           Params.ParamByName('computer').AsString := GetComputer;
           Execute;
       end else begin
            Close;
           Params.Clear;
           Params.CreateParam(ftString,'newip',ptInput);
           Params.CreateParam(ftString,'newmask',ptInput);
           Params.CreateParam(ftString,'newgateway',ptInput);
           Params.CreateParam(ftString,'mac',ptInput);
           Params.CreateParam(ftString,'computer',ptInput);
           CommandText :='UPDATE  SAJET.G_IP_STATUS SET COMPUTER_NAME =:computer,IP_Addr=:newIP,MASK=:newmask'+
                         ' ,GATEWAY = :newgateway ,UPDATE_TIME =sysdate  where MAC_ADDRESS =:mac ';
           Params.ParamByName('newip').AsString := edtIP.Text;
           Params.ParamByName('newmask').AsString := edtMask.Text;
           Params.ParamByName('newgateway').AsString := edtGateway.Text;
           Params.ParamByName('mac').AsString := lblMac.Caption;
           Params.ParamByName('computer').AsString := GetComputer;
           Execute;

       end;
    end;
    
end;

procedure TForm1.InsertLogData;
begin
      with Qry1 do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString,'oldip',ptInput);
         Params.CreateParam(ftString,'newip',ptInput);
         Params.CreateParam(ftString,'oldmask',ptInput);
         Params.CreateParam(ftString,'newmask',ptInput);
         Params.CreateParam(ftString,'oldgateway',ptInput);
         Params.CreateParam(ftString,'newgateway',ptInput);
         Params.CreateParam(ftString,'mac',ptInput);
         Params.CreateParam(ftString,'computer',ptInput);
         Params.CreateParam(ftString,'empid',ptInput);
         CommandText :='INSERT INTO SAJET.G_IP_LOG(COMPUTER_NAME,OLD_IP,NEW_IP,OLD_MASK,NEW_MASK,'+
                       '    OLD_GATEWAY,NEW_GATEWAY,EMP_ID,UPDATE_TIME,MAC_ADDRESS ) '+
                       'VALUES (:computer,:oldip,:newip,:oldmask,:newmask,:oldgateway,:newgateway,'+
                       '       :empid,sysdate,:mac) ';
         Params.ParamByName('oldip').AsString := sOldIP;
         Params.ParamByName('newip').AsString := edtIP.Text;
         Params.ParamByName('oldmask').AsString := sOldMask;
         Params.ParamByName('newmask').AsString := edtMask.Text;
         Params.ParamByName('oldgateway').AsString := sOldGateway;
         Params.ParamByName('newgateway').AsString := edtGateway.Text;
         Params.ParamByName('mac').AsString := lblMac.Caption;
         Params.ParamByName('computer').AsString := GetComputer;
         Params.ParamByName('empid').AsString := sEMPID;
         Execute;
      end;
end;

procedure TForm1.tmr1Timer(Sender: TObject);
begin
    DisableConnWindow;
end;
//----------------  防止任務管理器關閉---------------------
function TForm1.MakeMeCritical(Yes: Boolean): Boolean;
const  
  SE_DEBUG_PRIVILEGE = $14;  
  SE_PROC_INFO = $1D;  
var  
  Enabled: PBOOL;  
  DllHandle: THandle;  
  BreakOnTermination: ULong;  
  HR: HRESULT;  
  RtlAdjustPrivilege: function(Privilege: ULONG; Enable: BOOL; CurrentThread: BOOL; var Enabled: PBOOL): DWORD; stdcall;  
  NtSetInformationProcess: function(ProcHandle: THandle; ProcInfoClass: ULONG; ProcInfo: Pointer;  ProcInfoLength: ULONG): HResult; stdcall;  
begin  
  Result := False;  
  DllHandle := LoadLibrary('ntdll.dll') ;  
  if DllHandle <> 0 then  
  begin  
     @RtlAdjustPrivilege := GetProcAddress(dllHandle, 'RtlAdjustPrivilege');  
     if (@RtlAdjustPrivilege <> nil) then  
     begin  
       if RtlAdjustPrivilege(SE_DEBUG_PRIVILEGE, True, True, Enabled) = 0 then  
       begin  
          @NtSetInformationProcess := GetProcAddress(dllHandle, 'NtSetInformationProcess');  
          if (@NtSetInformationProcess <> nil) then  
          begin  
            BreakOnTermination := Ord(Yes);  
            HR := NtSetInformationProcess(GetCurrentProcess(), SE_PROC_INFO, @BreakOnTermination, SizeOf(BreakOnTermination));  
            Result := HR = S_OK;  
          end;  
       end;  
     end;  
     FreeLibrary(DllHandle);  
  end  
end;


procedure TForm1.FormShow(Sender: TObject);
begin
    SetAutoRun;
    MakeMeCritical(True);
    IsConnSvr :=False;
    IsAdminLogin := false;
   {
    XP進程保護
    GetInputState();
    //PostProcessMessage(GetCurrentThreadId(), 0, 0, 0);
    PostThreadMessage(GetCurrentThreadId(), 0, 0, 0);
    GetMessage(Msg, 0, 0, 0);
    SetPrivilege;
    protectme;
    while(GetMessage(win.Msg,win.hmain,0,0))do
    begin
        TranslateMessage(win.Msg);
        DispatchMessage(win.Msg);
    end;
    }
end;

procedure TForm1.edtUserKeyPress(Sender: TObject; var Key: Char);
begin
   if Key <> #13 then Exit;
   edtPwd.SetFocus;
end;

procedure TForm1.edtPwdKeyPress(Sender: TObject; var Key: Char);
begin
   if Key <> #13 then exit;
   btnLogin.Click;
end;

procedure TForm1.btnLoginClick(Sender: TObject);
var Auth:Boolean;
Authority:string;
begin
   if edtUser.Text ='' then Exit;
   mmo1.Lines.Clear;
   try
       IsConnSvr := LoadApServer;

       with Qry1 do
       begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString,'empno',ptInput);
           CommandText := 'select TRIM(Sajet.Password.Decrypt(passwd)) pwd,EMP_ID from '+
                  ' sajet.sys_emp where emp_no=:empno and enabled=''Y'' ' ;
           Params.ParamByName('empno').AsString :=edtUser.Text;
           Open;
           if IsEmpty then begin
               MessageDlg('Not  Find User',mtError,[mbOK],0);
               Exit;
           end;
           if FieldByName('pwd').AsString <>edtPwd.Text then
           begin
                MessageDlg('Password Error ',mtError,[mbOK],0);
                Exit;
           end;
           sEMPID := fieldbyName('emp_id').AsString;

           if GetAuthority(Qry1,'Data Center','IP Unlock Close',sempId) then  begin
                btnExit.Enabled :=True;
                mmo1.Lines.Add('IP Unlock Close priviledge 1')
           end else  begin
                btnExit.Enabled :=false;
                mmo1.Lines.Add('IP Unlock Close priviledge 0');
           end;
                
           if GetAuthority(Qry1,'Data Center','IP Unlock',sempId) then begin
                btnSetIP.Enabled :=True;
                mmo1.Lines.Add('IP Unlock  priviledge 1')
           end else begin
                btnSetIP.Enabled :=false;
                mmo1.Lines.Add('IP Unlock  priviledge 0');
           end;
       end;
   except
      on E: Exception do
      begin
         mmo1.Lines.Add('異常類別:' + E.ClassName + #13#10 + '異常消息:' + E.Message);

         IsConnSvr :=false;
         //mmo1.Lines.Add();
         if UpperCase(edtUser.Text) ='ADMIN' then
         begin
             if edtPwd.Text ='s%9k6Mg^fc2is&@ac75L' then
             begin
                  IsAdminLogin :=True;
                  btnSetIP.Enabled :=True;
                  btnExit.Enabled :=True;
             end;
         end;
      end;
   end;
   if not DirectoryExists(ExtractFilePath(ParamStr(0))+'log\') then
       ForceDirectories(ExtractFilePath(ParamStr(0))+'log\');
   mmo1.Lines.SaveToFile(ExtractFilePath(ParamStr(0))+'log\'+FormatDateTime('YYYYMMDD',Now)+'.txt');
end;

//---------------------auto run ---------------------------

procedure TForm1.SetAutoRun;
var
  Reg: TRegistry;
  fileName:string;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    fileName := ExpandFileName(ParamStr(0));
    if Reg.OpenKey('\SOFTWARE\Microsoft\windows\CurrentVersion\Run', True) then
    begin
        if not Reg.ValueExists('IPLOCK') then
             Reg.WriteString('IPLOCK',fileName)
        else if Reg.ReadString('IPLOCK')<> fileName then
        begin
            Reg.DeleteValue('IPLOCK');
            Reg.WriteString('IPLOCK', fileName);
        end
    end
    else
        Reg.DeleteValue('IPLOCK');
  finally
    FreeAndNil(Reg);
  end;

end;

procedure TForm1.btnLogoutClick(Sender: TObject);
var i:Integer;
begin
   edtUser.Clear;
   edtPwd.Clear;
   edtUser.SetFocus;
   try
       con1.Connected := False;
       for i:=0 to smplbjctbrkr1.Servers.count-1 do
       begin
           smplbjctbrkr1.Servers[i].ComputerName :='';
           smplbjctbrkr1.Servers[i].Enabled :=false;
           smplbjctbrkr1.Servers[i].Free;
       end;
       con1.Host:='';
       con1.Address:='';
       btnSetIP.Enabled :=False;
       btnExit.Enabled :=false;
       IsAdminLogin :=false;
       IsConnSvr :=false;
   except

   end;
end;

procedure TForm1.tmr2Timer(Sender: TObject);
begin
   try
       LoadApServer;
       btnGetIP.Click;
       UpdateTerminalStatus;
   except
       
   end;
end;

end.
