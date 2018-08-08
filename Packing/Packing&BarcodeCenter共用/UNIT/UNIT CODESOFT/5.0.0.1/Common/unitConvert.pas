unit unitConvert;

interface

uses sysutils,classes,dialogs;

//=====================================================================================================================
  //將數值(十進位的字串)轉成特殊格式的字串，假如是十六進位，賺f_stype為"0123456789ABCDEF" 十進位則f_sType為"0123456789"
  function G_convertIntToSpecial(f_sType,f_sOldValue:string) : string;
  //將特殊數值的字串轉成十進位數值的字串，，假如是十六進位，賺f_stype為"0123456789ABCDEF" 十進位則f_sType為"0123456789"
  function G_convertSpecialToInt(f_sType,f_sOldValue:string) : string;
  //將十進位的數值轉成十六進位的數值字串
  function G_convertIntToHex(f_iValue:integer) : string;
  //將十六進位的數值字串轉成十進位的數值字串
  function G_convertHexToInt(f_sValue:string) : integer;
//=====================================================================================================================
  //將string轉成pchar的格式
  procedure G_convertStrToBuffer(f_sData:string;f_pBuffer:pchar);
  //將pchar的格式轉成string
  function  G_convertBufferToStr(f_pBuffer:pchar;f_iLen:integer) : string;
  //將pchar的格式轉成解碼過後(會將每一個byte轉成十六進位的數值)的字串，
  function  G_convertBufferToStrASCII(f_pBuffer:pchar;f_iLen:integer) : string;
  //將G_convertBufferToStrASCII執行的結果，還原成原字串
  function  G_convertASCIIBufferToStr(f_pBuffer:pchar;f_iLen:integer) : string;
//=====================================================================================================================
  //將總長度+data的EncodePchar，轉成string
  function G_convertEncodePcharToString(f_pValue : pchar) : string;
  //將string轉成總長度+data的EncodePchar資料
  procedure G_convertStringToEncodePchar(f_sData:string;f_pValue : pchar);
  //將string(格式為長度1+字串1+長度2+字串2)，分解成TSTRINGS
  procedure G_convertEncodeStringToTstrings(f_sData:string;var f_tsData : tstrings);
  //將TSTRINGS分解成STRING(格式為長度1+字串1+長度2+字串2)
  function  G_convertTstringsToEncodeString(f_tsData : tstrings) : string;
  //將EncodePchar(格式為總長度+長度1+字串1+長度2+字串2)，分解成TSTRINGS
  procedure G_convertEncodePcharToTstrings(f_pValue : pchar;var f_tsData : tstrings);
  //將TSTRINGS分解成EncodePchar(格式為總長度+長度1+字串1+長度2+字串2)
  procedure G_convertTstringsToEncodePchar(f_tsData : tstrings;f_pValue : pchar);
//=====================================================================================================================
  //將tstrings依照順序累加成一個string，並在每個數直之間加上f_sSpare的字串(data1+spare+data2+spare+...)
  function  G_convertTstringsToString(f_tsData:tstrings;f_sSpare:string):string;
  //將經由G_convertTstringsToString得到的string(data1+spare+data2+spare+...)，再轉換成string
  procedure G_convertStringToTstrings(f_sData,f_sSpare : string;var tsData : tstrings);
//=====================================================================================================================
  //會將tstrings的資料，先轉成encodeString的格式，再加上head和check sum來做為資料的傳輸
  function G_convertTstringsToTransferData(f_tsData : tstrings) : string;
  //會將string，依照head和check sum來判斷是否為正確的資料，再轉換成tstrings
  function G_convertTransferDataToTstrings(var f_sData:string;var f_tsData : tstrings) : boolean;
//=====================================================================================================================



implementation

//=====================================================================================================================
{ 將數值(十進位的字串)轉成特殊格式的字串，假如是十六進位，f_stype為"0123456789ABCDEF" 十進位則f_sType為"0123456789" }
function G_convertIntToSpecial(f_sType,f_sOldValue:string) : string;
var iOldValue : cardinal;
begin
  try
    //將十進位的字串，轉回integer
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

//=====================================================================================================================
{ 將特殊數值的字串轉成十進位數值的字串，，假如是十六進位，賺f_stype為"0123456789ABCDEF" 十進位則f_sType為"0123456789" }
function G_convertSpecialToInt(f_sType,f_sOldValue:string) : string;
var i,iResult,iDegree,iIndex : cardinal;
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

//=====================================================================================================================
{ 將integer轉成十六進位碼 }
function G_convertIntToHex(f_iValue:integer) : string;
begin
  try
    result:=G_convertIntToSpecial('0123456789ABCDEF',inttostr(f_iValue));
  except
    on E:Exception do raise Exception.create('(G_convertIntToHex)'+E.Message);
  end;
end;

//=====================================================================================================================
{ 將十六進位碼轉成integer }
function G_convertHexToInt(f_sValue:string) : integer;
begin
  try
    result:=strtoint(G_convertSpecialToInt('0123456789ABCDEF',f_sValue));
  except
    on E:Exception do raise Exception.create('(G_convertHexToInt)'+E.Message);
  end;
end;

//=====================================================================================================================
{ 將字成的字元，存放到pchare }
procedure G_convertStrToBuffer(f_sData:string;f_pBuffer:pchar); overload;
var i : integer;
begin
  try
    for i:=1 to Length(f_sData) do f_pBuffer[i-1]:=f_sData[i];
  except
    on E:Exception do raise Exception.create('(G_convertStrToBuffer)'+E.Message);
  end;
end;

//=====================================================================================================================
{ 將pchare的字串，依造長度轉成string }
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

//=====================================================================================================================
{ 將pchare的字串，依照長度將每個字元轉成十六進位碼 }
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


//=====================================================================================================================
{ 將G_convertBufferToStrASCII轉換成的字串，轉回原字串 }
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




//=====================================================================================================================
{ 將總長度+data的EncodePchar，轉成string }
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

//=====================================================================================================================
{ 將string轉成總長度+data的EncodePchar資料 }
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


//=====================================================================================================================
{ 將TSTRINGS分解成EncodeString(格式為長度1+字串1+長度2+字串2) }
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

//=====================================================================================================================
{ 將EncodeString(格式為長度1+字串1+長度2+字串2)，分解成TSTRINGS }
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

//=====================================================================================================================
{ 將EncodePchar(格式為總長度+長度1+字串1+長度2+字串2)，分解成TSTRINGS }
procedure G_convertEncodePcharToTstrings(f_pValue : pchar;var f_tsData : tstrings);
var sData : string;
begin
  try
    f_tsData.clear;

    sData:=G_convertEncodePcharToString(f_pValue);
    G_convertEncodeStringToTstrings(sData,f_tsData);
  except
    on E:Exception do raise Exception.create('(G_convertPcharToTstrings)'+E.Message);
  end;
end;



//=====================================================================================================================
{ 將TSTRINGS分解成EncodePchar(格式為總長度+長度1+字串1+長度2+字串2) }
procedure G_convertTstringsToEncodePchar(f_tsData : tstrings;f_pValue : pchar);
var sData : string;
begin
  try
    sData:=G_convertTstringsToEncodeString(f_tsData);
    G_convertStringToEncodePchar(sData,f_pValue);
  except
    on E:Exception do raise Exception.create('(G_convertTstringsToPchar)'+E.Message);
  end;
end;

//=====================================================================================================================
{ 將tstrings依照順序累加成一個string，並在每個數直之間加上f_sSpare的字串(data1+spare+data2+spare+...) }
function  G_convertTstringsToString(f_tsData:tstrings;f_sSpare:string):string;
var i : integer;
begin
  try
    result:='';
    for i:=1 to f_tsData.Count do result:=Result+f_tsData[i-1]+f_sSpare;
  except
    on E:Exception do raise Exception.create('(G_convertTstringsToString)'+E.Message);
  end;
end;

//=====================================================================================================================
{ 將經由G_convertTstringsToString得到的string(data1+spare+data2+spare+...)，再轉換成string }
procedure G_convertStringToTstrings(f_sData,f_sSpare : string;var tsData : tstrings);
var iPos : integer;
begin
  try
    tsData.clear;

    while f_sData<>'' do begin
      iPos := pos(f_sSpare,f_sData);

      if iPos=0 then begin
        tsData.Add(f_sData) ;
        f_sData:='';
      end
      else begin
        tsData.add(copy(f_sData,1,iPos-1));
        delete(f_sData,1,iPos);
      end;
    end;
  except
    on E:Exception do raise Exception.create('(G_convertStrintToTstrings)'+E.Message);
  end;
end;

//=====================================================================================================================
{ 會將tstrings的資料，先轉成encodeString的格式，再加上head和check sum來做為資料的傳輸
  格式 head三碼(#00+#250+#08)+checksum(word)+data總長度(integer)+data}
function G_convertTstringsToTransferData(f_tsData : tstrings) : string;
const csHead = #00+#250+#08;
var iChkSum : word;
    i,iTemp : integer;
    sCheckSum,sTotalLen,sData : string;
    pTemp : pchar;
begin
  result:='';
  try
    sData:=G_convertTstringsToEncodeString(f_tsData);

    sTotalLen:='';
    iTemp:=length(sData);
    pTemp:=@iTemp;
    for i:=1 to sizeof(iTemp) do sTotalLen:=sTotalLen+char(pTemp[i-1]);

    sCheckSum:='';
    iChkSum:=0;
    for i:=1 to Length(sTotalLen) do iChkSum:=iChkSum+byte(sTotalLen[i]);
    for i:=1 to Length(sData) do iChkSum:=iChkSum+byte(sData[i]);
    pTemp:=@iChkSum;
    for i:=1 to SizeOf(iChkSum) do sCheckSum:=sCheckSum+char(pTemp[i-1]);

    Result:=csHead+sCheckSum+sTotalLen+sData;
  except
    on E:Exception do raise Exception.create('(G_convertTstringsToTransferData)'+E.Message);
  end;
end;

//=====================================================================================================================
{ 會將tstrings的資料，先轉成encodeString的格式，再加上head和check sum來做為資料的傳輸
  格式 head三碼(#00+#250+#08)+checksum(word)+data總長度(integer)+data}
function G_convertTransferDataToTstrings(var f_sData:string;var f_tsData : tstrings) : boolean;
const csHead = #00+#250+#08;
var iCheckSum : ^word;
    iCheckSumTemp : word;
    sData,sTemp : string;
    i,iPos : integer;
    iTotalLen : ^integer;
begin
  result:=false;
  try
    f_tsData.Clear;

    sData:=f_sData;  //將原本的資料，先存在放到BUFFER中

    while true do begin
      iPos:=pos(csHead,sData); // 取得HEAD的位置，整筆資料的起始位置

      { 假如資料的buffer中沒有head，則判斷原始資料中是否有head，
        假如沒有的話，則將原始資料刪除至head的長度，以防止原始資料愈來愈長
        假如有的話，則將head之前的垃圾資料刪除 }
      case iPos of
        0 : begin
          iPos:= pos(csHead,f_sData);
          case iPos of
            0 : Delete(f_sData,1,length(f_sData)-3);
            1 : ;
            else Delete(f_sData,1,iPos-1);
          end;
          exit;
        END;
        1 : ;
        else begin
          Delete(sData,1,iPos-1);
          continue;
        end;
      end;

      // 假如資料的總長度小於最小長度則結束，代表資料尚未齊全
      if length(sData)<Length(csHead)+sizeof(word)+SizeOf(integer) then begin
        Delete (sData,1,3);
        Continue;
      end;

      //MAPPING數值
      iCheckSum:=@sData[length(csHead)+1];
      iTotalLen:=@sData[length(csHead)+sizeof(word)+1];

      //假如資料的長度小於資料的應有長度，則有可能資料錯誤，則刪除HEAD，重新判斷
      if length(sData)<Length(csHead)+sizeof(word)+SizeOf(integer)+iTotalLen^ then begin
        Delete (sData,1,3);
        Continue;
      end;

      //判斷checksum是否正確
      iCheckSumTemp:=0;
      for i:=(Length(csHead)+sizeof(word)+1) to (Length(csHead)+sizeof(word)+SizeOf(integer)+iTotalLen^) do iCheckSumTemp:=iCheckSumTemp+byte(sData[i]);
      if iCheckSumTemp<>iCheckSum^ then begin
        Delete (sData,1,3);
        Continue;
      end;

      //取得資料，並還原成tstrings
      G_convertEncodeStringToTstrings(Copy(sData,Length(csHead)+sizeof(word)+SizeOf(integer)+1,iTotalLen^),f_tsData);
      Delete(sData,1,Length(csHead)+sizeof(word)+SizeOf(integer)+iTotalLen^);
      f_sData:=sData;
      result:=true;
      exit;
    end;
  except
    on E:Exception do raise Exception.create('(G_convertTransferDataToTstrings)'+E.Message);
  end;
end;

end.
