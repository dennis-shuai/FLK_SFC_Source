library ReportRepairCfgDll;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes,
  Forms,
  Windows,
  DllInit in 'DllInit.pas',
  uDllForm in 'uDllForm.pas' {fDllForm},
  uDetail in 'uDetail.pas' {fDetail};

{$R *.RES}
procedure DLLUnloadProc(Reason: Integer); register;
begin
  if Reason = DLL_PROCESS_DETACH then Application := DllApplication;
end;

exports
  InitSajetParamDll,
  ActiveForm,
  MinimizeForm,
  CloseSajetDll;

begin
  DllApplication := Application;
  DLLProc := @DLLUnloadProc;
end.
