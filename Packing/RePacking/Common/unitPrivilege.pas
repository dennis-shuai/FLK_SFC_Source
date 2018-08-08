unit unitPrivilege;

interface

uses sysutils,db,Sconnect,dbclient,dialogs;

const
  cPrivilege0='Read Only';
  cPrivilege1='Allow To Change';
  cPrivilege2='Full Control';
  cPrivilege3='Allow To Execute';

function G_ChkAuthority(f_Server : TSocketConnection; f_sProviderName,f_sPrgName,f_sEmpID : String;var f_sEmpNO,f_sEmpName : string) : boolean;
function G_ChkFunction(f_Server : TSocketConnection; f_sProviderName,f_sPrgName,f_sFunction,f_sEmpID : String) : boolean;
function G_getPrivilege(f_Server : TSocketConnection; f_sProviderName,f_sPrgName,f_sFunction,f_sEmpID : String) : integer;
function G_insertPrivilege(f_Server : TSocketConnection; f_sProviderName,f_sPrgName,f_sFunction,f_sEmpID : String) : boolean;

implementation

function G_getPrivilege(f_Server : TSocketConnection; f_sProviderName,f_sPrgName,f_sFunction,f_sEmpID : String) : integer;
var iTemp : integer;
begin
  result:=0;
  try
    with TClientDataSet.Create(nil) do begin
      try
        RemoteServer:= f_Server;
        ProviderName:=f_sProviderName;
        Params.CreateParam(ftString,'EMP_ID',ptInput);
        Params.CreateParam(ftString,'PRG',ptInput);
        Params.CreateParam(ftString,'FUNCTION',ptInput);
        CommandText := 'Select AUTHORITYS '+
                       'From SAJET.SYS_EMP_PRIVILEGE '+
                       'Where EMP_ID = :EMP_ID '+
                       '  and PROGRAM = :PRG '+
                       '  and FUNCTION=:FUNCTION '+
                       '  and rownum=1 ';
        Params.ParamByName('EMP_ID').AsString := UpperCase(Trim(f_sEmpID)) ;
        Params.ParamByName('PRG').AsString := f_sPrgName;
        Params.ParamByName('FUNCTION').AsString := f_sFunction;
        Open;
        if recordcount<>0 then begin
          if FieldByName('AUTHORITYS').asstring=cPrivilege0 then iTemp:=0
          else if FieldByName('AUTHORITYS').asstring=cPrivilege1 then iTemp:=1
          else if FieldByName('AUTHORITYS').asstring=cPrivilege2 then iTemp:=2
          else if FieldByName('AUTHORITYS').asstring=cPrivilege3 then iTemp:=3
          else iTemp:=0;
          if iTemp>result then result:=iTemp;
        end;

        close;
        Params.Clear;
        Params.CreateParam(ftString,'EMP_ID',ptInput);
        Params.CreateParam(ftString,'PRG',ptInput);
        Params.CreateParam(ftString,'FUNCTION',ptInput);
        CommandText := 'Select AUTHORITYS '+
                       'From SAJET.SYS_ROLE_PRIVILEGE A, '+
                       '     SAJET.SYS_ROLE_EMP B '+
                       'Where A.ROLE_ID = B.ROLE_ID '+
                       '  and EMP_ID = :EMP_ID '+
                       '  and PROGRAM = :PRG '+
                       '  and FUNCTION=:FUNCTION '+
                       '  and rownum=1 ';
        Params.ParamByName('EMP_ID').AsString := UpperCase(Trim(f_sEmpID)) ;
        Params.ParamByName('PRG').AsString := f_sPrgName;
        Params.ParamByName('FUNCTION').AsString := f_sFunction;
        Open;
        if recordcount<>0 then begin
          if FieldByName('AUTHORITYS').asstring=cPrivilege0 then iTemp:=0
          else if FieldByName('AUTHORITYS').asstring=cPrivilege1 then iTemp:=1
          else if FieldByName('AUTHORITYS').asstring=cPrivilege2 then iTemp:=2
          else if FieldByName('AUTHORITYS').asstring=cPrivilege3 then iTemp:=3
          else iTemp:=0;
          if iTemp>result then result:=iTemp;
        end;
      finally
        free;
      end;
    end;
  except
    on E:Exception do ShowMessage('(G_getPrivilege)'+E.Message);
  end;
end;

function G_insertPrivilege(f_Server : TSocketConnection; f_sProviderName,f_sPrgName,f_sFunction,f_sEmpID : String) : boolean;
begin
  result:=false;
  try
    with TClientDataSet.Create(nil) do begin
      try
        RemoteServer:= f_Server;
        ProviderName:=f_sProviderName;

        Params.Clear;
        Params.CreateParam(ftString,'PROGRAM',ptInput);
        Params.CreateParam(ftString,'FUNCTION',ptInput);

        CommandText :=' delete SAJET.SYS_PROGRAM_FUN '+
                      '   where PROGRAM=:PROGRAM '+
                      '     and FUNCTION=:FUNCTION ';
        Params.parambyname('PROGRAM').asstring:=f_sPrgName;
        Params.parambyname('FUNCTION').asstring:=f_sFunction;
        execute;

        close;
        Params.Clear;
        Params.CreateParam(ftString,'PROGRAM',ptInput);
        Params.CreateParam(ftString,'FUNCTION',ptInput);
        Params.CreateParam(ftstring,'UPDATE_USERID',ptInput);
        Params.CreateParam(ftinteger,'AUTH_SEQ',ptInput);
        Params.CreateParam(ftString,'AUTHORITYS',ptInput);

        CommandText :=' insert into SAJET.SYS_PROGRAM_FUN '+
                      '   (PROGRAM,FUNCTION,UPDATE_USERID,UPDATE_TIME,AUTH_SEQ,AUTHORITYS) '+
                      ' values '+
                      '   (:PROGRAM,:FUNCTION,:UPDATE_USERID,sysdate,:AUTH_SEQ,:AUTHORITYS) ';

        Params.parambyname('PROGRAM').asstring:=f_sPrgName;
        Params.parambyname('FUNCTION').asstring:=f_sFunction;
        Params.parambyname('UPDATE_USERID').asstring:=f_sEmpID;

        Params.parambyname('AUTH_SEQ').asinteger:=0;
        Params.parambyname('AUTHORITYS').asstring:=cPrivilege0;
        execute;

        Params.parambyname('AUTH_SEQ').asinteger:=1;
        Params.parambyname('AUTHORITYS').asstring:=cPrivilege1;
        execute;

        exit;
        Params.parambyname('AUTH_SEQ').asinteger:=2;
        Params.parambyname('AUTHORITYS').asstring:=cPrivilege2;
        execute;

      finally
        free;
      end;
    end;
    result:=true;
  except
    on E:Exception do ShowMessage('(G_insertPrivilege)'+E.Message);
  end;
end;

function G_ChkFunction(f_Server : TSocketConnection; f_sProviderName,f_sPrgName,f_sFunction,f_sEmpID : String) : boolean;
begin
  result:=false;
  try
    with TClientDataSet.Create(nil) do begin
      try
        RemoteServer:= f_Server;
        ProviderName:=f_sProviderName;
        Params.CreateParam(ftString,'EMP_ID',ptInput);
        Params.CreateParam(ftString,'PRG',ptInput);
        Params.CreateParam(ftString,'FUNCTION',ptInput);
        CommandText := 'Select FUNCTION '+
                       'From SAJET.SYS_EMP_PRIVILEGE '+
                       'Where EMP_ID = :EMP_ID '+
                       '  and PROGRAM = :PRG '+
                       '  and FUNCTION=:FUNCTION '+
                       '  and rownum=1 '+
                       'Group By FUNCTION';
        Params.ParamByName('EMP_ID').AsString := UpperCase(Trim(f_sEmpID)) ;
        Params.ParamByName('PRG').AsString := f_sPrgName;
        Params.ParamByName('FUNCTION').AsString := f_sFunction;
        Open;
        result:=(recordcount<>0);
        if Result then exit;

        close;
        Params.Clear;
        Params.CreateParam(ftString,'EMP_ID',ptInput);
        Params.CreateParam(ftString,'PRG',ptInput);
        Params.CreateParam(ftString,'FUNCTION',ptInput);
        CommandText := 'Select FUNCTION '+
                       'From SAJET.SYS_ROLE_PRIVILEGE A, '+
                       '     SAJET.SYS_ROLE_EMP B '+
                       'Where A.ROLE_ID = B.ROLE_ID '+
                       '  and EMP_ID = :EMP_ID '+
                       '  and PROGRAM = :PRG '+
                       '  and FUNCTION=:FUNCTION '+
                       '  and rownum=1 '+
                       'Group By FUNCTION';
        Params.ParamByName('EMP_ID').AsString := UpperCase(Trim(f_sEmpID)) ;
        Params.ParamByName('PRG').AsString := f_sPrgName;
        Params.ParamByName('FUNCTION').AsString := f_sFunction;
        Open;
        result:=(recordcount<>0);
      finally
        free;
      end;
    end;
  except
    on E:Exception do showmessage('(G_ChkFunction)'+E.Message);
  end;
end;


function G_ChkAuthority(f_Server : TSocketConnection; f_sProviderName,f_sPrgName,f_sEmpID : String;var f_sEmpNO,f_sEmpName : string) : boolean;
begin
  result:=false;
  try
    with TClientDataSet.Create(nil) do begin
      try
        RemoteServer:= f_Server;
        ProviderName:=f_sProviderName;
        Params.clear;
        Params.CreateParam(ftString,'EMP_ID', ptInput);
        CommandText := ' select * from ( select r1.*,NVL(to_char(QUIT_DATE),''N/A'') QUIT '+
                       '                 From SAJET.SYS_EMP r1 '+
                       '                 where r1.emp_id=:EMP_ID '+
                       '                   and enabled=''Y'' '+
                       '                   and rownum=1 ) '+
                       ' where quit=''N/A'' ';

        Params.ParamByName('EMP_ID').AsString := f_sEmpID;
        open;


        if recordcount=0 then exit;
        f_sEmpNO := Fieldbyname('EMP_NO').AsString;
        f_sEmpName := Fieldbyname('EMP_NAME').AsString;

        close;
        Params.Clear;
        Params.CreateParam(ftString,'EMP_ID',ptInput);
        Params.CreateParam(ftString,'PRG',ptInput);
        CommandText := 'Select FUNCTION '+
                       'From SAJET.SYS_EMP_PRIVILEGE '+
                       'Where EMP_ID = :EMP_ID '+
                       '  and PROGRAM = :PRG '+
                       '  and rownum=1 '+
                       'Group By FUNCTION';
        Params.ParamByName('EMP_ID').AsString := UpperCase(Trim(f_sEmpID)) ;
        Params.ParamByName('PRG').AsString := f_sPrgName;
        Open;
        result:=(recordcount<>0);
        if Result then exit;

        close;
        Params.Clear;
        Params.CreateParam(ftString,'EMP_ID',ptInput);
        Params.CreateParam(ftString,'PRG',ptInput);
        CommandText := 'Select FUNCTION '+
                       'From SAJET.SYS_ROLE_PRIVILEGE A, '+
                       '     SAJET.SYS_ROLE_EMP B '+
                       'Where A.ROLE_ID = B.ROLE_ID '+
                       '  and EMP_ID = :EMP_ID '+
                       '  and PROGRAM = :PRG '+
                       '  and rownum=1 '+
                       'Group By FUNCTION';
        Params.ParamByName('EMP_ID').AsString := UpperCase(Trim(f_sEmpID)) ;
        Params.ParamByName('PRG').AsString := f_sPrgName;
        Open;
        result:=(recordcount<>0);
      finally
        free;
      end;
    end;
  except
    on E:Exception do showmessage('(G_ChkAuthority)'+E.Message);
  end;
end;


end.
