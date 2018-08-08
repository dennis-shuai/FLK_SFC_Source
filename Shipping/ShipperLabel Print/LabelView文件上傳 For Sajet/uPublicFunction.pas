{******************************************************************************}
{  Unit description:                                                           }
{  Developer: Kevin                  Date:      2003/2/26                      }
{  Modifier:                         Date:                                     }
{         Copyright(C)  SCM , All right reserved                               }
{******************************************************************************}
unit uPublicFunction;

interface

uses
  SysUtils, StrUtils;

function GetSeqNo(Prefix, Surfix: string; MinSize, CurrentNo: Integer): string;
function String_Crypt(const ASourceStr, ASubStr: string; ACryptType: integer): string;
function ConnectionString_Crypt(const AConStrring: string; ACryptType: integer): string;

implementation

uses
  Cl_crypt32;

function GetSeqNo(Prefix, Surfix: string; MinSize,
  CurrentNo: Integer): string;
var
  Str: string;
begin
  Str := Format('%' + IntToStr(MinSize) + 'd', [CurrentNo]);
  Result := Prefix + AnsiReplaceText(Str, ' ', '0') + Surfix;
end;

function String_Crypt(const ASourceStr, ASubStr: string; ACryptType: integer): string;
var
  i, lPos1, lPos2, lPos3: integer;
  lSource: string;
begin
  lSource := ASourceStr;
  result := ASourceStr;
  lpos1 := Pos(ASubStr, lSource);
  if lPos1 = 0 then exit;
  lpos2 := -1;
  lpos3 := -1;
  for i := lPos1 to length(lSource) do
    if lSource[i] = '=' then
    begin
      lpos2 := i;
      break;
    end;
  for i := lPos1 to length(lSource) do
    if lSource[i] = ';' then
    begin
      lpos3 := i;
      break;
    end;
  if lpos3 = -1 then lpos3 := length(lSource);
  if lpos2 = -1 then //if Pos2 equal -1 then error
    exit;
  case ACryptType of
    0:
      lSource := copy(lSource, 1, lpos2) + cl_encrypt(copy(lSource, lpos2 + 1, lpos3 - lpos2 - 1)) +
        copy(lSource, lpos3, length(lSource));
    1:
      lSource := copy(lSource, 1, lpos2) + cl_decrypt(copy(lSource, lpos2 + 1, lpos3 - lpos2 - 1)) +
        copy(lSource, lpos3, length(lSource))
  end;
  Result := lSource;
end;

{*         ACryptType : 0 --- Encrypt
 *                      1 --- Decrypt                                         *}

function ConnectionString_Crypt(const AConStrring: string; ACryptType: integer): string;
var
  lConStr: string;
begin
  lConStr := AConStrring;
  if copy(lConStr, length(lConStr), 1) <> ';' then lConStr := lConStr + ';';
  lConStr := String_crypt(lConStr, 'User ID', ACryptType);
  lConStr := String_crypt(lConStr, 'Password', ACryptType);
  Result := lConStr;
end;

end.
