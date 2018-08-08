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
  //�N�`����+data��EncodePchar�A�নstring
  function G_convertEncodePcharToString(f_pValue : pchar) : string;
  //�Nstring�ন�`����+data��EncodePchar���
  procedure G_convertStringToEncodePchar(f_sData:string;f_pValue : pchar);
  //�Nstring(�榡������1+�r��1+����2+�r��2)�A���Ѧ�TSTRINGS
  procedure G_convertEncodeStringToTstrings(f_sData:string;var f_tsData : tstrings);
  //�NTSTRINGS���Ѧ�STRING(�榡������1+�r��1+����2+�r��2)
  function  G_convertTstringsToEncodeString(f_tsData : tstrings) : string;
  //�NEncodePchar(�榡���`����+����1+�r��1+����2+�r��2)�A���Ѧ�TSTRINGS
  procedure G_convertEncodePcharToTstrings(f_pValue : pchar;var f_tsData : tstrings);
  //�NTSTRINGS���Ѧ�EncodePchar(�榡���`����+����1+�r��1+����2+�r��2)
  procedure G_convertTstringsToEncodePchar(f_tsData : tstrings;f_pValue : pchar);
//=====================================================================================================================
  //�Ntstrings�̷Ӷ��ǲ֥[���@��string�A�æb�C�Ӽƪ������[�Wf_sSpare���r��(data1+spare+data2+spare+...)
  function  G_convertTstringsToString(f_tsData:tstrings;f_sSpare:string):string;
  //�N�g��G_convertTstringsToString�o�쪺string(data1+spare+data2+spare+...)�A�A�ഫ��string
  procedure G_convertStringToTstrings(f_sData,f_sSpare : string;var tsData : tstrings);
//=====================================================================================================================
  //�|�Ntstrings����ơA���নencodeString���榡�A�A�[�Whead�Mcheck sum�Ӱ�����ƪ��ǿ�
  function G_convertTstringsToTransferData(f_tsData : tstrings) : string;
  //�|�Nstring�A�̷�head�Mcheck sum�ӧP�_�O�_�����T����ơA�A�ഫ��tstrings
  function G_convertTransferDataToTstrings(var f_sData:string;var f_tsData : tstrings) : boolean;
//=====================================================================================================================



implementation

//=====================================================================================================================
{ �N�ƭ�(�Q�i�쪺�r��)�ন�S��榡���r��A���p�O�Q���i��Af_stype��"0123456789ABCDEF" �Q�i��hf_sType��"0123456789" }
function G_convertIntToSpecial(f_sType,f_sOldValue:string) : string;
var iOldValue : cardinal;
begin
  try
    //�N�Q�i�쪺�r��A��^integer
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
{ �N�S��ƭȪ��r���ন�Q�i��ƭȪ��r��A�A���p�O�Q���i��A��f_stype��"0123456789ABCDEF" �Q�i��hf_sType��"0123456789" }
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
{ �Ninteger�ন�Q���i��X }
function G_convertIntToHex(f_iValue:integer) : string;
begin
  try
    result:=G_convertIntToSpecial('0123456789ABCDEF',inttostr(f_iValue));
  except
    on E:Exception do raise Exception.create('(G_convertIntToHex)'+E.Message);
  end;
end;

//=====================================================================================================================
{ �N�Q���i��X�নinteger }
function G_convertHexToInt(f_sValue:string) : integer;
begin
  try
    result:=strtoint(G_convertSpecialToInt('0123456789ABCDEF',f_sValue));
  except
    on E:Exception do raise Exception.create('(G_convertHexToInt)'+E.Message);
  end;
end;

//=====================================================================================================================
{ �N�r�����r���A�s���pchare }
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
{ �Npchare���r��A�̳y�����নstring }
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
{ �Npchare���r��A�̷Ӫ��ױN�C�Ӧr���ন�Q���i��X }
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
{ �NG_convertBufferToStrASCII�ഫ�����r��A��^��r�� }
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
{ �N�`����+data��EncodePchar�A�নstring }
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
{ �Nstring�ন�`����+data��EncodePchar��� }
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
{ �NTSTRINGS���Ѧ�EncodeString(�榡������1+�r��1+����2+�r��2) }
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
{ �NEncodeString(�榡������1+�r��1+����2+�r��2)�A���Ѧ�TSTRINGS }
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
{ �NEncodePchar(�榡���`����+����1+�r��1+����2+�r��2)�A���Ѧ�TSTRINGS }
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
{ �NTSTRINGS���Ѧ�EncodePchar(�榡���`����+����1+�r��1+����2+�r��2) }
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
{ �Ntstrings�̷Ӷ��ǲ֥[���@��string�A�æb�C�Ӽƪ������[�Wf_sSpare���r��(data1+spare+data2+spare+...) }
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
{ �N�g��G_convertTstringsToString�o�쪺string(data1+spare+data2+spare+...)�A�A�ഫ��string }
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
{ �|�Ntstrings����ơA���নencodeString���榡�A�A�[�Whead�Mcheck sum�Ӱ�����ƪ��ǿ�
  �榡 head�T�X(#00+#250+#08)+checksum(word)+data�`����(integer)+data}
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
{ �|�Ntstrings����ơA���নencodeString���榡�A�A�[�Whead�Mcheck sum�Ӱ�����ƪ��ǿ�
  �榡 head�T�X(#00+#250+#08)+checksum(word)+data�`����(integer)+data}
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

    sData:=f_sData;  //�N�쥻����ơA���s�b���BUFFER��

    while true do begin
      iPos:=pos(csHead,sData); // ���oHEAD����m�A�㵧��ƪ��_�l��m

      { ���p��ƪ�buffer���S��head�A�h�P�_��l��Ƥ��O�_��head�A
        ���p�S�����ܡA�h�N��l��ƧR����head�����סA�H�����l��ƷU�ӷU��
        ���p�����ܡA�h�Nhead���e���U����ƧR�� }
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

      // ���p��ƪ��`���פp��̤p���׫h�����A�N���Ʃ|������
      if length(sData)<Length(csHead)+sizeof(word)+SizeOf(integer) then begin
        Delete (sData,1,3);
        Continue;
      end;

      //MAPPING�ƭ�
      iCheckSum:=@sData[length(csHead)+1];
      iTotalLen:=@sData[length(csHead)+sizeof(word)+1];

      //���p��ƪ����פp���ƪ��������סA�h���i���ƿ��~�A�h�R��HEAD�A���s�P�_
      if length(sData)<Length(csHead)+sizeof(word)+SizeOf(integer)+iTotalLen^ then begin
        Delete (sData,1,3);
        Continue;
      end;

      //�P�_checksum�O�_���T
      iCheckSumTemp:=0;
      for i:=(Length(csHead)+sizeof(word)+1) to (Length(csHead)+sizeof(word)+SizeOf(integer)+iTotalLen^) do iCheckSumTemp:=iCheckSumTemp+byte(sData[i]);
      if iCheckSumTemp<>iCheckSum^ then begin
        Delete (sData,1,3);
        Continue;
      end;

      //���o��ơA���٭즨tstrings
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
