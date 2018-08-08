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

  //�ڴ�ӳ��
  MemFile: THandle;
  startPid: PDWORD;   //����PID
  fhProcess: THandle;  //���汾������Զ�̽����еľ��


//���� OpenProcess
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
    showmessage('��׼�ر��ң�');
    result := true;
    exit;
  end;
  Hook[2].UnHook;
  Result := TNewTerminateProcess(Hook[2].BaseAddr)(hProcess, uExitCode );
  Hook[2].Hook;
end;

procedure InitHook;     //��װ Hook
begin
  Hook[1] := TNtHookClass.Create('kernel32.dll', 'OpenProcess', @NewOpenProcess);
  hook[2] := TNtHookClass.Create('kernel32.dll', 'TerminateProcess', @NewTerminateProcess);
end;

procedure UninitHook;     //ɾ�� Hook
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
  MemFile:=OpenFileMapping(FILE_MAP_ALL_ACCESS,False, HOOK_MEM_FILENAME);   //���ڴ�ӳ���ļ�
  if MemFile = 0 then begin
    MemFile := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0,
                             4, HOOK_MEM_FILENAME);
  end;
  if MemFile <> 0 then
    //ӳ���ļ�������
    startPid := MapViewOfFile(MemFile,FILE_MAP_ALL_ACCESS,0,0,0);
end;

//������Ϣ
function HookProc(nCode, wParam, lParam: Integer): Integer; stdcall;
begin
  Result := CallNextHookEx(hhk, nCode, wParam, lParam);
end;

//��ʼHOOK
procedure StartHook(pid: DWORD); stdcall;
begin
  startPid^ := pid;
  hhk := SetWindowsHookEx(WH_CALLWNDPROC, HookProc, hInstance, 0);
end;

//����HOOK
procedure EndHook; stdcall;
begin
  if hhk <> 0 then
    UnhookWindowsHookEx(hhk);
end;

//��������
procedure DllEntry(dwResaon: DWORD);
begin
  case dwResaon of
    DLL_PROCESS_ATTACH: InitHook;   //DLL����
    DLL_PROCESS_DETACH: UninitHook; //DLLɾ��
  end;
end;

exports
  StartHook, EndHook;

begin
  MemShared;

  { ����DLL���� DllProc ���� }
  DllProc := @DllEntry;
  { ����DLL���ش��� }
  DllEntry(DLL_PROCESS_ATTACH);
end.
 
