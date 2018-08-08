library PartNoPointdll;

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
  DllInit in 'DllInit.pas',
  uDllform in 'uDllform.pas' {fDllForm},
  uDPPM in 'uDPPM.pas' {fDPPM},
  uData in 'uData.pas' {fData},
  uHistory in 'uHistory.pas' {fHistory};

{$R *.RES}

exports
  InitSajetDll     index 1,
  CloseSajetDll    index 2;

begin
end.
