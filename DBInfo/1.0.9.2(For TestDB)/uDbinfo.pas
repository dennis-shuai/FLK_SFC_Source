unit uDbinfo;

interface

Function SajetAPUser : PChar; stdcall; export;
Function SajetAPPwd  : PChar; stdcall; export;

implementation

Function SajetAPUser : PChar;
begin
  Result := 'SJ';
end;

Function SajetAPPwd : PChar;
begin
  Result := 'testsfc01';
end;

end.
