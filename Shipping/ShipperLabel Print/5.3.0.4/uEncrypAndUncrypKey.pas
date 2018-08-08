unit uEncrypAndUncrypKey;

interface

uses
  SysUtils ;//Messages, Windows, , Classes, Graphics, Controls ;

implementation

//加密函數
Function EncrypKey (Src:String; Key:String = 'Think Space'):string;
var
  //idx   :integer;
  KeyLen   :Integer;
  KeyPos   :Integer;
  offset   :Integer;
  dest   :string;
  SrcPos   :Integer;
  SrcAsc   :Integer;
//  TmpSrcAsc   :Integer;
  Range   :Integer;
begin
  KeyLen:=Length(Key);
  if KeyLen = 0 then key:='Think Space';
  if Length(Src) = 0 then
  begin
    Result := '';
    Exit ;
  end;
  KeyPos:=0;
//  SrcPos:=0;
//  SrcAsc:=0;
  Range:=256;

  Randomize;
  offset:=Random(Range);   
  dest:=format('%1.2x',[offset]);
  for SrcPos := 1 to Length(Src) do
  begin
    SrcAsc:=(Ord(Src[SrcPos]) + offset) MOD 255;
    if KeyPos < KeyLen then KeyPos:= KeyPos + 1 else KeyPos:=1;
    SrcAsc:= SrcAsc xor Ord(Key[KeyPos]);
    dest:=dest + format('%1.2x',[SrcAsc]);
    offset:=SrcAsc;   
  end;
  Result:=Dest;   
end;

//解密函數
Function UncrypKey (Src:String; Key:String = 'Think Space'):string;
var
  //idx   :integer;
  KeyLen   :Integer;
  KeyPos   :Integer;
  offset   :Integer;
  dest   :string;
  SrcPos   :Integer;
  SrcAsc   :Integer;
  TmpSrcAsc   :Integer;
//  Range   :Integer;
begin
  KeyLen:=Length(Key);
  if KeyLen = 0 then key:='Think Space';
  if Length(Src) = 0 then
  begin
    Result := '';
    Exit ;
  end;
  KeyPos:=0;
//  SrcPos:=0;
//  SrcAsc:=0;
//  Range:=256;
  offset:=StrToInt('$'+ copy(src,1,2));
  SrcPos:=3;
  repeat
    SrcAsc:=StrToInt('$'+ copy(src,SrcPos,2));
    if KeyPos < KeyLen Then KeyPos := KeyPos + 1 else KeyPos := 1;
    TmpSrcAsc := SrcAsc xor Ord(Key[KeyPos]);
    if TmpSrcAsc <= offset then
      TmpSrcAsc := 255 + TmpSrcAsc - offset
    else
    TmpSrcAsc := TmpSrcAsc - offset;
    dest := dest + chr(TmpSrcAsc);
    offset:= srcAsc;
    SrcPos:= SrcPos + 2;
  until SrcPos >= Length(Src);
  Result:=Dest;
end ;


end.
 