unit Cl_crypt32;
{
*************************************************************************
*名稱: Cl_crypt32.pas
*
*說明: Cl_crypt32.pas為一支編解碼模組，乃修改『Martin Djern犘』先生所修改
*      的《crypt32.pas 32 bits encode/decode module》而成（修改的理由請詳
*      見下述）。
*
*函數原型: function cl_encrypt(s:string):string;
*          function cl_decrypt(s:string):string;
*
*使用方法: 《編碼》encrypted:=cl_encrypt('password');
*          《解碼》decrypted:=cl_decrypt(encrypted);
*
*注意: 使用時，請先修改cl_crypt32.pas內StartKey,MultKey,AddKey三個key值。
*       (其中startkey的值最好不要小於256）。
*
*修改的理由: 僅管『Martin Djern犘』先生的《crypt32.pas 32 bits encode/decode module》
*            已經很好用，但是我在實際應用時，卻發現下列的問題：
*             1.無法把編碼後的字串指定給edit元件。
*             2.無法把編碼後的字串存放在.ini檔內。
*                上述兩點可以舉下例兩個例子證明：
*                 （例一〉
*                       edit1.text:=Encrypt('password',StartKey,MultKey,AddKey);
*                       edit2.text:=decrypt(edit1.text,StartKey,MultKey,AddKey);
*                   結果: edit2.text的內容不等於'password'
*                 （例二）
*                       var
*                          IniFile: TIniFile;
*                       begin
*                          IniFile := TIniFile.Create('test.INI');
*                          IniFile.WriteString('demo', 'password', Encrypt('password',StartKey,MultKey,AddKey));
*                          IniFile.Free;
*
*                          IniFile := TIniFile.Create('test.INI');
*                          edit2.text:=decrypt(IniFile.readString('demo', 'password', ''),StartKey,MultKey,AddKey);
*                          IniFile.Free;
*                    結果: edit2.text的內容不等於'password'
*              上述兩種情況的發生原因，大概是因為編碼後的字元碼大於127，
*              因此無法被『具有處理文字型態能力的元件』正確處理。
*          基於上述理由，我把它修改了一下，並加上以系統時間值為參數，
*          使其編碼後的值可以成功存放在edit.text及.ini files內。
*
*修改者: cloudy@tpts4.seed.net.tw
*
*************************************************************************
}


{
*************************************************************************
* Name:					Crypt32.Pas				  																		*
* Description:	32 bits encode/decode module			  										*
*								2^96 variants it is very high to try hack								*
*	Purpose:			Good for encrypting passwors and text										*
*	Security:			avoid use StartKey less than 256												*
*								if it use only for internal use you may use default 		*
*								key, but MODIFY unit before compiling										*
* Call:					Encrypted := Encrypt(InString,StartKey,MultKey,AddKey)	*
*								Decrypted := Decrypt(InString,StartKey)		  						*
* Parameters:		InString	= long string (max 2 GB) that need to encrypt	*
*														decrypt	  																	*
*								MultKey		= MultKey key			              							*
*								AddKey		= Second key			              							*
*								StartKey	= Third key			              								*
*								(posible use defaults from interface)			  						*
* Return:				OutString	= result string			  												*
* Editor:				Besr viewed with Tab stops = 2, Courier new							*
* Started:			01.08.1996					  																	*
* Revision:			22.05.1997 - ver.2.01 converted from Delphi 1						*
*								and made all keys as parameters, before only start key	*
* Platform:			Delphi 2.0, 3.0 				  															*
* 							work in Delphi 1.0, 2^48 variants, 0..255 strings				*
* Author:				Anatoly Podgoretsky				  														*
* 							Base alghoritm from Borland				  										*
* Address:			Vahe 4-31, Johvi, Estonia, EE2045, tel. 61-142    			*
*								kvk@estpak.ee					  																*
* Status:				Freeware, but any sponsor help will be appreciated here	*
*								need to buy books, shareware products, tools etc				*
*************************************************************************
* Modified:     Supports Delphi 1.0 & 2.0                         			*
*               Overflow checking removed                         			*
* By:           Martin Djern犘                                    			*
* e-mail:       djernaes@einstein.ot.dk                           			*
* web:          einstein.ot.dk/~djernaes                          			*
*************************************************************************
}
interface

uses
  SysUtils;

const
  StartKey = 956; {Start default key}
  MultKey = 58645; {Mult default key}
  AddKey = 28564; {Add default key}

function cl_encrypt(s: string): string;
function cl_decrypt(s: string): string;

//function Encrypt(const InString:string; StartKey,MultKey,AddKey:Integer): string;
//function Decrypt(const InString:string; StartKey,MultKey,AddKey:Integer): string;

implementation

{$R-}
{$Q-}
{*******************************************************
 * Standard Encryption algorithm - Copied from Borland *
 *******************************************************}

function Encrypt(const InString: string; StartKey, MultKey, AddKey: Integer): string;
var
  I: Byte;
begin
  Result := '';
  for I := 1 to Length(InString) do
  begin
    Result := Result + CHAR(Byte(InString[I]) xor (StartKey shr 8));
    StartKey := (Byte(Result[I]) + StartKey) * MultKey + AddKey;
  end;
end;
{*******************************************************
 * Standard Decryption algorithm - Copied from Borland *
 *******************************************************}

function Decrypt(const InString: string; StartKey, MultKey, AddKey: Integer): string;
var
  I: Byte;
begin
  Result := '';
  for I := 1 to Length(InString) do
  begin
    Result := Result + CHAR(Byte(InString[I]) xor (StartKey shr 8));
    StartKey := (Byte(InString[I]) + StartKey) * MultKey + AddKey;
  end;
end;
{$R+}
{$Q+}

{Coded by cloudy}

function cl_intto0str(int1: integer; len: integer): string;
var
  i, j: integer;
begin
  if length(inttostr(int1)) >= len then
    result := inttostr(int1)
  else
  begin
    result := '';
    i := len - length(inttostr(int1));
    for j := 1 to i do result := result + '0';
    result := result + inttostr(int1);
  end;
end;

{Coded by cloudy}

function cl_chartobytestr(s: string): string;
var
  i: byte;
begin
  result := '';
  for i := 1 to length(s) do
    result := result + cl_intto0str(byte(s[i]), 3);
end;

function cl_bytetocharstr(s: string): string;
var
  i: integer;
begin
  i := 1;
  result := '';
  if (length(s) mod 3) = 0 then
    while i < length(s) do
    begin
      result := result + char(strtoint(copy(s, i, 3)));
      i := i + 3;
    end;
end;

{Coded by cloudy}

function cl_encrypt(s: string): string;
var
  years, months, days, hours, mins, secs, msec: word;
  cl_StartKey, cl_MultKey, cl_AddKey: longint;

begin
  decodedate(now, years, months, days);
  decodetime(now, hours, mins, secs, msec);
  cl_StartKey := msec;
  if cl_StartKey < 256 then cl_StartKey := cl_StartKey + 256;
  cl_Multkey := ((years - 1900) * 12 + months) * 30 + days + cl_StartKey * 10 + cl_StartKey;
  cl_AddKey := (23 * hours + mins) * 60 + secs + cl_StartKey * 10 + cl_StartKey;
  result := cl_chartobytestr(Encrypt(cl_intto0str(cl_StartKey, 3), StartKey, MultKey, AddKey)) + cl_chartobytestr(Encrypt(cl_intto0str(cl_Multkey, 5), StartKey, MultKey, AddKey)) + cl_chartobytestr(Encrypt(cl_intto0str(cl_Addkey, 5), StartKey, MultKey, AddKey)) + cl_chartobytestr(Encrypt(s, cl_StartKey, cl_MultKey, cl_AddKey));
end;

{Coded by cloudy}

function cl_decrypt(s: string): string;
var
  cl_StartKey, cl_Multkey, cl_AddKey: longint;
begin
  cl_StartKey := strtoint(decrypt(cl_bytetocharstr(copy(s, 1, 9)), StartKey, MultKey, AddKey));
  cl_MultKey := strtoint(decrypt(cl_bytetocharstr(copy(s, 10, 15)), StartKey, MultKey, AddKey));
  cl_AddKey := strtoint(decrypt(cl_bytetocharstr(copy(s, 25, 15)), StartKey, MultKey, AddKey));
  result := decrypt(cl_bytetocharstr(copy(s, 40, length(s) - 39)), cl_StartKey, cl_MultKey, cl_AddKey);
end;

end.
