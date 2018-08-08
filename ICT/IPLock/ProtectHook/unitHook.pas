unit unitHook;

interface

uses
  Windows, Messages, Classes, SysUtils;

type

  //NtHook���������
  TNtJmpCode=packed record  //8�ֽ�
    MovEax:Byte;
    Addr:DWORD;
    JmpCode:Word;
    dwReserved:Byte;
  end;

  TNtHookClass=class(TObject)
  private
    hProcess:THandle;
    NewAddr:TNtJmpCode;
    OldAddr:array[0..7] of Byte;
    ReadOK:Boolean;
  public
    BaseAddr:Pointer;
    constructor Create(DllName,FuncName:string;NewFunc:Pointer);
    destructor Destroy; override;
    procedure Hook;
    procedure UnHook;
  end;

implementation

//==================================================
//NtHOOK �࿪ʼ
//==================================================
constructor TNtHookClass.Create(DllName: string; FuncName: string;NewFunc:Pointer);
var
  DllModule:HMODULE;
  dwReserved:DWORD;
begin
  //��ȡģ����
  DllModule:=GetModuleHandle(PChar(DllName));
  //����ò���˵��δ������
  if DllModule=0 then DllModule:=LoadLibrary(PChar(DllName));
  //�õ�ģ����ڵ�ַ����ַ��
  BaseAddr:=Pointer(GetProcAddress(DllModule,PChar(FuncName)));
  //��ȡ��ǰ���̾��
  hProcess:=GetCurrentProcess;
  //ָ���µ�ַ��ָ��
  NewAddr.MovEax:=$B8;
  NewAddr.Addr:=DWORD(NewFunc);
  NewAddr.JmpCode:=$E0FF;
  //����ԭʼ��ַ
  ReadOK:=ReadProcessMemory(hProcess,BaseAddr,@OldAddr,8,dwReserved);
  //��ʼ����
  Hook;
end;

//�ͷŶ���
destructor TNtHookClass.Destroy;
begin
  UnHook;
  CloseHandle(hProcess);

  inherited;
end;

//��ʼ����
procedure TNtHookClass.Hook;
var
  dwReserved:DWORD;
begin
  if (ReadOK=False) then Exit;
  //д���µĵ�ַ
  WriteProcessMemory(hProcess,BaseAddr,@NewAddr,8,dwReserved);
end;

//�ָ�����
procedure TNtHookClass.UnHook;
var
  dwReserved:DWORD;
begin
  if (ReadOK=False) then Exit;
  //�ָ���ַ
  WriteProcessMemory(hProcess,BaseAddr,@OldAddr,8,dwReserved);
end;

end. 
