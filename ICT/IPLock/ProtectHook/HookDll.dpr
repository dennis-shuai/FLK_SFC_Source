library Hookdll;

uses
  SysUtils,
  Classes,
  Windows,Dialogs,
  unitHook in 'unitHook.pas';


const
  HOOK_MEM_FILENAME  =  'tmp.hkt';
var
  hhk: HHOOK;
  Hook: array[0..2] of TNtHookClass;

  //内存映射
  MemFile: THandle;
  startPid: PDWORD;   //保存PID
  fhProcess: THandle;  //保存本进程在远程进程中的句柄


//拦截 OpenProcess
function NewOpenProcess(dwDesiredAccess: DWORD; bInheritHandle: BOOL; dwProcessId: DWORD): THandle; stdcall;
type
  TNewOpenProcess = function (dwDesiredAccess: DWORD; bInheritHandle: BOOL; dwProcessId: DWORD): THandle; stdcall;
begin
  if startPid^ = dwProcessId then begin
  Hook[1].UnHook;
  Result := TNewOpenProcess(Hook[1].BaseAddr)(dwDesiredAccess, bInheritHandle, dwProcessId);
  fhProcess:=Result;
  Hook[1].Hook;
  exit;
  end;
  Hook[1].UnHook;
  Result := TNewOpenProcess(Hook[1].BaseAddr)(dwDesiredAccess, bInheritHandle, dwProcessId);
  Hook[1].Hook;

end;

function NewTerminateProcess(hProcess: THandle;uExitCode: UINT): BOOL; Stdcall;
type
  TNewTerminateProcess = function (hProcess: THandle;uExitCode: UINT): BOOL; Stdcall;
begin
  if fhProcess = hProcess then begin
    showmessage('不准关闭我！');
    result := true;
    exit;
  end;
  Hook[2].UnHook;
  Result := TNewTerminateProcess(Hook[2].BaseAddr)(hProcess, uExitCode );
  Hook[2].Hook;
end;

procedure InitHook;     //安装 Hook
begin
  Hook[1] := TNtHookClass.Create('kernel32.dll', 'OpenProcess', @NewOpenProcess);
  hook[2] := TNtHookClass.Create('kernel32.dll', 'TerminateProcess', @NewTerminateProcess);
end;

procedure UninitHook;     //删除 Hook
var
  I: Integer;
begin
  for I := 0 to High(Hook) do
  begin
    FreeAndNil(Hook[I]);
  end;
end;

procedure MemShared();
begin
  MemFile:=OpenFileMapping(FILE_MAP_ALL_ACCESS,False, HOOK_MEM_FILENAME);   //打开内存映射文件
  if MemFile = 0 then begin
    MemFile := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0,
                             4, HOOK_MEM_FILENAME);
  end;
  if MemFile <> 0 then
    //映射文件到变量
    startPid := MapViewOfFile(MemFile,FILE_MAP_ALL_ACCESS,0,0,0);
end;

//传递消息
function HookProc(nCode, wParam, lParam: Integer): Integer; stdcall;
begin
  Result := CallNextHookEx(hhk, nCode, wParam, lParam);
end;

//开始HOOK
procedure StartHook(pid: DWORD); stdcall;
begin
  startPid^ := pid;
  hhk := SetWindowsHookEx(WH_CALLWNDPROC, HookProc, hInstance, 0);
end;

//结束HOOK
procedure EndHook; stdcall;
begin
  if hhk <> 0 then
    UnhookWindowsHookEx(hhk);
end;

//环境处理
procedure DllEntry(dwResaon: DWORD);
begin
  case dwResaon of
    DLL_PROCESS_ATTACH: InitHook;   //DLL载入
    DLL_PROCESS_DETACH: UninitHook; //DLL删除
  end;
end;

exports
  StartHook, EndHook;

begin
  MemShared;

  { 分配DLL程序到 DllProc 变量 }
  DllProc := @DllEntry;
  { 调用DLL加载处理 }
  DllEntry(DLL_PROCESS_ATTACH);
end.
 
