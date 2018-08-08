unit Cl_crypt32;
{
*************************************************************************
*�W��: Cl_crypt32.pas
*
*����: Cl_crypt32.pas���@��s�ѽX�ҲաA�D�ק�yMartin Djern�s�z���ͩҭק�
*      ���mcrypt32.pas 32 bits encode/decode module�n�Ӧ��]�ק諸�z�ѽи�
*      ���U�z�^�C
*
*��ƭ쫬: function cl_encrypt(s:string):string;
*          function cl_decrypt(s:string):string;
*
*�ϥΤ�k: �m�s�X�nencrypted:=cl_encrypt('password');
*          �m�ѽX�ndecrypted:=cl_decrypt(encrypted);
*
*�`�N: �ϥήɡA�Х��ק�cl_crypt32.pas��StartKey,MultKey,AddKey�T��key�ȡC
*       (�䤤startkey���ȳ̦n���n�p��256�^�C
*
*�ק諸�z��: �ȺޡyMartin Djern�s�z���ͪ��mcrypt32.pas 32 bits encode/decode module�n
*            �w�g�ܦn�ΡA���O�ڦb������ήɡA�o�o�{�U�C�����D�G
*             1.�L�k��s�X�᪺�r����w��edit����C
*             2.�L�k��s�X�᪺�r��s��b.ini�ɤ��C
*                �W�z���I�i�H�|�U�Ҩ�ӨҤl�ҩ��G
*                 �]�Ҥ@�r
*                       edit1.text:=Encrypt('password',StartKey,MultKey,AddKey);
*                       edit2.text:=decrypt(edit1.text,StartKey,MultKey,AddKey);
*                   ���G: edit2.text�����e������'password'
*                 �]�ҤG�^
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
*                    ���G: edit2.text�����e������'password'
*              �W�z��ر��p���o�ͭ�]�A�j���O�]���s�X�᪺�r���X�j��127�A
*              �]���L�k�Q�y�㦳�B�z��r���A��O������z���T�B�z�C
*          ���W�z�z�ѡA�ڧ⥦�ק�F�@�U�A�å[�W�H�t�ήɶ��Ȭ��ѼơA
*          �Ϩ�s�X�᪺�ȥi�H���\�s��bedit.text��.ini files���C
*
*�ק��: cloudy@tpts4.seed.net.tw
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
* By:           Martin Djern�s                                    			*
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
