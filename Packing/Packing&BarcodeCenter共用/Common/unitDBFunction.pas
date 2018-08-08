unit unitDBFunction;

interface

uses classes,sysutils, SConnect,DB,dbclient,forms,dialogs;

const
  cSNTitle='SN_';
  cCartonTitle='CARTON_';
  cCartonCount='CARTON_COUNT';
  cPalletCount='PALLET_COUNT';

  function  G_getTableData(f_SocketConnection:TSocketConnection;f_sProvideName,f_sTableName,f_sParam,f_sData:string;var f_tsParam,f_tsData:tstrings) : boolean;
  function  G_getParamData(f_tsParam,f_tsData:tstrings;f_sParam:string) : string;
  procedure G_deleteParamData(f_sParam:string;var f_tsParam,f_tsData:tstrings) ;
  function  G_getFieldsData(f_Fields:TFields;var f_tsParam,f_tsData:tstrings) : boolean;


implementation



procedure G_deleteParamData(f_sParam:string;var f_tsParam,f_tsData:tstrings) ;
var iIndex : integer;
begin
  iIndex:=f_tsParam.indexof(UpperCase(f_sParam));
  if iIndex<0 then exit;
  f_tsParam.Delete(iIndex);
  f_tsData.Delete(iIndex);
end;


function G_getParamData(f_tsParam,f_tsData:tstrings;f_sParam:string) : string;
var iIndex : integer;
begin
  result:='';
  iIndex:=f_tsParam.indexof(UpperCase(f_sParam));
  if iIndex<0 then exit;
  result:=f_tsData[iIndex];
end;


function G_getTableData(f_SocketConnection:TSocketConnection;f_sProvideName,f_sTableName,f_sParam,f_sData:string;var f_tsParam,f_tsData:tstrings) : boolean;
begin
  result:=false;
  try
    with TClientDataSet.Create(Application) do begin
      try
        RemoteServer:=f_SocketConnection;
        ProviderName:=f_sProvideName;

        Params.Clear;
        params.CreateParam(ftString,f_sParam,ptinput);
        CommandText:=' select * from '+f_sTableName+' '+
                     ' where '+f_sParam+'=:'+f_sParam+' and rownum=1 ';
        Params.parambyname(f_sParam).asstring:=f_sData;
        open;

        G_getFieldsData(Fields,f_tsParam,f_tsData);

        close;
      finally
        free;
      end;
    end;
    result:=true;
  except
  end;
end;

function G_getFieldsData(f_Fields:TFields;var f_tsParam,f_tsData:tstrings) : boolean;
var i : integer;
begin
  result:=false;
  try
    for i:=1 to f_Fields.Count do begin
      if f_tsParam.IndexOf(Uppercase(f_Fields.Fields[i-1].FieldName))<0 then begin
        f_tsParam.Add(UpperCase(f_Fields.Fields[i-1].FieldName));
        f_tsData.add(f_Fields.Fields[i-1].AsString);
      end;
    end;
    result:=true;
  except
  end;
end;


end.
