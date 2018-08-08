unit uAuthority;

interface

uses
  SysUtils, Dialogs, DB, ADODB, ActiveX ;


procedure ChkAuthority(TProgram : string; ADOC : TADOConnection );

var
  ObjQuery, ObjQueryProc : TADOQuery ;

implementation


procedure CreateObjQuery;
begin
  ObjQuery :=  TADOQuery.Create(nil);
  ObjQueryProc := TADOQuery.Create(nil);
end;

procedure FreeObjQuery;
begin
  ObjQueryProc.Close ;
  ObjQuery.Close ;
  ObjQuery.Free ;
  ObjQueryProc.Free ;
end;

procedure ChkAuthority(TProgram : string; ADOC : TADOConnection );
begin
  //
end;

initialization
  //CoInitialize(nil);
  OleInitialize(nil);
  CreateObjQuery ;

finalization
  OleUnInitialize;
  FreeObjQuery ;

end.
