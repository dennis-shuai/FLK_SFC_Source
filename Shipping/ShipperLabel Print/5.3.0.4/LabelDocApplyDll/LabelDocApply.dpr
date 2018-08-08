library LabelDocApply;

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
  uFormMain in 'uFormMain.pas' {FormMain};

{$R *.res}

procedure EnabledLabelDocApply; stdcall;
begin
  if FormMain = nil then
  begin
    FormMain := TFormMain.Create(nil); 
  end;
  FormMain.Timer1.Enabled := True ;
end;

procedure DisabledLabelDocApply; stdcall;
begin
  if FormMain <> nil then
  begin
    FormMain.Timer1.Enabled := False ;
    FormMain.Close ;
    FormMain.Free ;
    FormMain := nil ;
  end;
end;

exports
  EnabledLabelDocApply ,
  DisabledLabelDocApply ;

begin
end.
