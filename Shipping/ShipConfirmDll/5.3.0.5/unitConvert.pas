unit unitConvert;

interface

uses sysutils,classes,dialogs;

//=====================================================================================================================
  //�N�ƭ�(�Q�i�쪺�r��)�ন�S��榡���r��A���p�O�Q���i��A��f_stype��"0123456789ABCDEF" �Q�i��hf_sType��"0123456789"
  function G_convertIntToSpecial(f_sType,f_sOldValue:string) : string;
  //�N�S��ƭȪ��r���ন�Q�i��ƭȪ��r��A�A���p�O�Q���i��A��f_stype��"0123456789ABCDEF" �Q�i��hf_sType��"0123456789"
  function G_convertSpecialToInt(f_sType,f_sOldValue:string) : string;
  //�N�Q�i�쪺�ƭ��ন�Q���i�쪺�ƭȦr��
  function G_convertIntToHex(f_iValue:integer) : string;
  //�N�Q���i�쪺�ƭȦr���ন�Q�i�쪺�ƭȦr��
  function G_convertHexToInt(f_sValue:string) : integer;
//=====================================================================================================================
  //�Nstring�নpchar���榡
  procedure G_convertStrToBuffer(f_sData:string;f_pBuffer:pchar);
  //�Npchar���榡�নstring
  function  G_convertBufferToStr(f_pBuffer:pchar;f_iLen:integer) : string;
  //�Npchar���榡�ন�ѽX�L��(�|�N�C�@��byte�ন�Q���i�쪺�ƭ�)���r��A
  function  G_convertBufferToStrASCII(f_pBuffer:pchar;f_iLen:integer) : string;
  //�NG_convertBufferToStrASCII���檺���G�A�٭즨��r��
  function  G_convertASCIIBufferToStr(f_pBuffer:pchar;f_iLen:integer) : string;

//=====================================================================================================================
  //�Npchar(�榡������1+�r��1+����2+�r��2)�A���Ѧ�TSTRINGS
  procedure G_convertEncodePcharToTstrings(f_pValue : pchar;var f_tsData : tstrings);
  //�NTSTRINGS���Ѧ�pchar(�榡������1+�r��1+����2+�r��2)
  procedure G_convertTstringsToEncodePchar(f_tsData : tstrings;f_pValue : pchar);

  procedure G_convertEncodeStringToTstrings(f_sData:string;var f_tsData : tstrings);
  function  G_convertTstringsToEncodeString(f_tsData : tstrings) : string;

  //�Nlength+data��pchar��ơA�নstring
  function G_convertEncodePcharToString(f_pValue : pchar) : string;
  //�Nstring�নlength+data��pchar���
  procedure G_convertStringToEncodePchar(f_sData:string; f_pValue : pchar);
//=====================================================================================================================
  procedure G_convertStrintToTstrings(f_sData,f_sSpare : string;var tsData : tstrings);
  function  G_convertTstringsToString(f_tsData:tstrings;f_sSpare:string):string;
implementation

function G_convertIntToSpecial(f_sType,f_sOldValue:string) : string;
var iOldValue : integer;
begin
  try
    iOldValue:=strtoint(f_sOldValue);
    Result:='';

    while iOldValue<>0 do begin
      Result:=f_sType[(iOldValue mod length(f_sType))+1]+Result;
      iOldValue:=iOldValue div length(f_sType);
    end;
  except
    on E:Exception do raise Exception.create('(G_convertIntToSpecial)'+E.Message);
  end;
end;

function G_convertSpecialToInt(f_sType,f_sOldValue:string) : string;
var i,iResult,iDegree,iIndex : integer;
begin
  try
    iResult:=0;
    iDegree:=1;

    for i:=length(f_sOldValue) downto 1 do begin
      iIndex:=pos(f_sOldValue[i],f_sType);
      if iIndex=0 then raise Exception.Create('Value Not match Type');
      iResult:=iResult+iDegree*(iIndex-1);
      if i<>1 then iDegree:=iDegree*length(f_sType)
    end;

    result:=inttostr(iResult);
  except
    on E:Exception do raise Exception.create('(G_convertSpecialToInt)'+E.Message);
  end;
end;

function G_convertIntToHex(f_iValue:integer) : string;
begin
  try
    result:=G_convertIntToSpecial('0123456789ABCDEF',inttostr(f_iValue));
  except
    on E:Exception do raise Exception.create('(G_convertIntToHex)'+E.Message);
  end;
end;

function G_convertHexToInt(f_sValue:string) : integer;
begin
  try
    result:=strtoint(G_convertSpecialToInt('0123456789ABCDEF',f_sValue));
  except
    on E:Exception do raise Exception.create('(G_convertHexToInt)'+E.Message);
  end;
end;


procedure G_convertStrToBuffer(f_sData:string;f_pBuffer:pchar); overload;
var i : integer;
begin
  try
    for i:=1 to Length(f_sData) do f_pBuffer[i-1]:=f_sData[i];
  except
    on E:Exception do raise Exception.create('(G_convertStrToBuffer)'+E.Message);
  end;
end;

function G_convertBufferToStr(f_pBuffer:pchar;f_iLen:integer) : string;
var i : integer;
begin
  try
    result:='';
    if f_pBuffer=nil then exit;
    SetLength(Result,f_iLen);
    for i:=1 to f_iLen do Result[i]:=f_pBuffer[i-1];
  except
    on E:Exception do raise Exception.create('(G_convertBufferToStr)'+E.Message);
  end;
end;

function G_convertBufferToStrASCII(f_pBuffer:pchar;f_iLen:integer) : string;
var i : integer;
begin
  try
    result:='';
    for i:=1 to f_iLen do Result:=result+IntToHex(byte(f_pBuffer[i-1]),2)+'-';
  except
    on E:Exception do raise Exception.create('(G_convertBufferToStr)'+E.Message);
  end;
end;


function G_convertASCIIBufferToStr(f_pBuffer:pchar;f_iLen:integer) : string;
var sTemp,sRes : string;
    iPos : integer;
begin
  result:='';
  try
    sTemp := G_convertBufferToStr(f_pBuffer,f_iLen);
    sRes:='';
    iPos:=pos('-',sTemp);
    while iPos<>0 do begin
      sRes:=sRes+char(G_convertHexToInt(copy(sTemp,1,iPos-1)));
      Delete(sTemp,1,iPos);
      iPos:=pos('-',sTemp);
    end;
    Result:=sRes;
  except
    on E:Exception do raise Exception.create('(G_convertASCIIBufferToStr)'+E.Message);
  end;
end;

procedure G_convertEncodePcharToTstrings(f_pValue : pchar;var f_tsData : tstrings);
var sValue : string;
    iPos : integer;
    iLenTotal,iLen : ^integer;
begin
  try
    f_tsData.clear;
    ipos:=0;
    iLenTotal:=@f_pValue[iPos];
    ipos:=iPos+sizeof(integer);

    while iPos<(iLenTotal^+sizeof(integer)) do begin
      iLen:=@f_pValue[iPos];
      sValue:=G_convertBufferToStr(@f_pValue[iPos+sizeof(integer)],iLen^);
      f_tsData.add(sValue);
      iPos:=iPos+sizeof(integer)+iLen^;
    end;
  except
    on E:Exception do raise Exception.create('(G_convertPcharToTstrings)'+E.Message);
  end;
end;

procedure G_convertTstringsToEncodePchar(f_tsData : tstrings;f_pValue : pchar);
var i,j,iLen,iLenTotal : integer;
    pTemp : pchar;
begin
  try
    iLenTotal:=sizeof(integer);

    for i:=1 to f_tsData.Count do begin
      iLen:=length(f_tsData[i-1]);
      pTemp := @iLen;
      for j:=1 to sizeof(integer) do f_pValue[iLenTotal+j-1]:=pTemp[j-1];
      iLenTotal:=iLenTotal+sizeof(integer);
      for j:=1 to iLen do f_pValue[iLenTotal+j-1]:=f_tsData[i-1][j];
      iLenTotal:=iLenTotal+iLen;
    end;

    iLenTotal:=iLenTotal-sizeof(integer);
    pTemp:=@iLenTotal;
    for j:=1 to sizeof(integer) do f_pValue[j-1]:=pTemp[j-1];
  except
    on E:Exception do raise Exception.create('(G_convertTstringsToPchar)'+E.Message);
  end;
end;

procedure G_convertEncodeStringToTstrings(f_sData:string;var f_tsData : tstrings);
var sValue : string;
    iLen : ^integer;
begin
  try
    f_tsData.clear;
    while f_sData<>'' do begin
      iLen:=@f_sData[1];
      sValue:=copy(f_sData,sizeof(integer)+1,iLen^);
      f_tsData.Add(sValue);
      Delete(f_sData,1,sizeof(integer)+iLen^);
    end;
  except
    on E:Exception do raise Exception.create('(G_convertEncodeStringToTstrings)'+E.Message);
  end;
end;

function  G_convertTstringsToEncodeString(f_tsData : tstrings) : string;
var i,j,iLen : integer;
    pTemp : pchar;
begin
  result:='';
  try
    for i:=1 to f_tsData.Count do begin
      iLen:=length(f_tsData[i-1]);
      pTemp := @iLen;
      for j:=1 to sizeof(integer) do  result:=result+char(pTemp[j-1]);
      Result:=result+f_tsData[i-1];
    end;
  except
    on E:Exception do raise Exception.create('(G_convertTstringsToEncodeString)'+E.Message);
  end;
end;

function G_convertEncodePcharToString(f_pValue : pchar) : string;
var iLen : ^integer;
begin
  try
    iLen:=@f_pValue[0];
    result:=G_convertBufferToStr(@f_pValue[sizeof(integer)],iLen^);
  except
    on E:Exception do raise Exception.create('(G_convertPcharToString)'+E.Message);
  end;
end;

procedure G_convertStringToEncodePchar(f_sData:string; f_pValue : pchar);
var i,iLen : integer;
    pTemp : pchar;
begin
  try
    iLen:=length(f_SData);
    pTemp:=@iLen;
    for i:=1 to sizeof(integer) do f_pValue[i-1]:=pTemp[i-1];
    for i:=1 to iLen do f_pValue[sizeof(integer)+i-1]:=f_sData[i];
  except
    on E:Exception do raise Exception.create('(G_convertTstringsToPchar)'+E.Message);
  end;
end;

procedure G_convertStrintToTstrings(f_sData,f_sSpare : string;var tsData : tstrings);
var iPos : integer;
begin
  tsData.clear;
  IF f_sData='' then exit;
  repeat
    iPos := pos(f_sSpare,f_sData);
    if iPos=0 then begin
      tsData.Add(f_sData) ;
      f_sData:='';
    end
    else begin
      tsData.add(copy(f_sData,1,iPos-1));
      delete(f_sData,1,iPos);
    end;
  until f_sData ='';
end;


function  G_convertTstringsToString(f_tsData:tstrings;f_sSpare:string):string;
var i : integer;
begin
  result:='';
  for i:=1 to f_tsData.Count do result:=Result+f_tsData[i-1]+f_sSpare;
end;

end.
