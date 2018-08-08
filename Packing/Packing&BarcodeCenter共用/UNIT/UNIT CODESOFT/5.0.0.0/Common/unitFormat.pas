unit unitFormat;

interface
  uses sysutils;

  function G_CheckIPFormat(f_sData : string) : boolean;
implementation

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
