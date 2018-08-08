unit unitFormat;

interface
  uses sysutils;

  function G_CheckIPFormat(f_sData : string) : boolean;
  function G_checkTimeHour(f_sData:string) : boolean;
implementation


function G_checkTimeHour(f_sData:string) : boolean;
begin
  result:=false;
  try
    if length(f_sData)<4 then exit;
    if not (strtoint(copy(f_sData,1,2)) in [0..24]) then exit;
    if not (StrToInt(copy(f_sData,3,2)) in [0..59]) then exit;
    if (strtoint(copy(f_sData,1,2))=24) and (StrToInt(copy(f_sData,3,2))<>0) then exit;
    result:=true;
  except
  end;
end;


function G_CheckIPFormat(f_sData : string) : boolean;
var sData : array [0..1] of string;
    i,iPos,iValue : integer;
begin
  result:=false;
  try
    sData[1]:=f_sData;
    i := 0;
    while i<3 do begin
      iPos:=pos('.',sData[1]);
      if iPos<0 then exit;
      sData[0]:=copy(sData[1],1,iPos-1);
      if sData[0]='' then exit;
      iValue:=strtoint(sData[0]);
      if not (iValue in [0..255]) then exit;
      Delete(sdata[1],1,iPos);
      inc(i);
    end;
    if sData[1]='' then exit;
    iValue:=strtoint(sData[1]);
    if not (iValue in [0..255]) then exit;
    result:=true;
  except
  end;
end;


end.
