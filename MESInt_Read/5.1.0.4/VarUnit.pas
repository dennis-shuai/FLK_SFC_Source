unit VarUnit;

interface
uses SysUtils,inifiles,graphics;

Type
  TRGROUP_Item = Record
    Item      : ShortString;
    Item_Desc : ShortString;
    Iqc_Type  : ShortString;
    Value1    : ShortString;
    Value2    : ShortString;
    Value3    : ShortString;
    Result    : ShortString;
  end;

  TRItem = Record
    ITem  : ShortString;
    Value : ShortString;
    Res   : ShortString;
    Rec   : ShortString;
    Value_FLOW : ShortString;
  end;

  TRGroup = Record
    ITemCount  : Byte;
    SimpleSize : Integer;
    ShowModel  : ShortString;
  end;

Function PADR(mString:String; mLength:WORD; mChar:String):String;
Function PADL(mString:String; mLength:WORD; mChar:String):String;
Procedure ReadINI;
Procedure WriteINI;
procedure udfEdit_FontInit;
procedure ClearAry;

var gLocal_Path,gInsModel : String;
    aryItem : Array[0..10,0..20] of TRGROUP_ITEM;
    aryValue : Array[0..10,0..20,0..50] of TRITEM;
    aryGroup : Array[0..10] of TRGroup;
    udfNormalFont,udfFocusFont,udfNormalLabel,udfTitleLabel,udfSimLabel: TFont;
    gItemIndex,gGroupIndex,gValueIndex : Integer;
    gValue : String;

implementation

procedure ClearAry;
Var mI,mG,mV : Integer;
begin
   for mG := 0 to 10 do begin
      for mI := 0 to 20 do begin
         for mV := 0 to 50 do begin
             aryItem[mG,mI].Item := '';
             aryValue[mG,mI,mV].ITem :='';
             aryValue[mG,mI,mV].Value :='';
             aryValue[mG,mI,mV].Res :='';
         end;
      end;
   end;
end;

Procedure ReadINI;
Var INIname : String; vIniFile : TIniFile;
begin
  INIname := gLocal_Path + 'SFIS.INI';
  vInifile := Tinifile.Create(INIname);
  gInsModel := vIniFile.ReadString('IQC','Inspection Model','By P/N');
  vInifile.Free;
end;

Procedure WriteINI;
Var INIname : String; vIniFile : TIniFile;
begin
  INIname := gLocal_Path + 'SFIS.INI';
  vInifile := Tinifile.Create(INIname);
  vIniFile.WriteString('IQC','Inspection Model',gInsModel);
  vInifile.Free;
end;

Function PADR(mString:String; mLength:WORD; mChar:String):String;
Var mI : Byte;
begin
   For mI:=Length(mString) to mLength-1 do mString := mString + mChar[1];
   Result := mString;
end;

Function PADL(mString:String; mLength:WORD; mChar:String):String;
Var mI : Byte;
begin
   For mI:=Length(mString) to mLength-1 do mString := mChar[1]+mString;
   Result := mString;
end;

procedure udfEdit_FontInit;
begin
  udfNormalFont := TFont.Create;
  With udfNormalFont do begin
     Size := 10;
     Name := 'Times New Roman';
     Style := [fsItalic];
  end;
  udfFocusFont := TFont.Create;
  With udfFocusFont do begin
     Size := 10;
     Name := 'Times New Roman';
     Style := [fsBold];
  end;
  udfTitleLabel := TFont.Create;
  With udfTitleLabel do begin
     Size := 10;
     Name := 'Book Antiqua';
     Style := [fsBold,fsItalic];
  end;
  udfSimLabel := TFont.Create;
  With udfSimLabel do begin
     Size := 10;
     Name := 'Century Gothic';
     Color := clMaroon;
     Style := [fsBold,fsItalic];
  end;
  udfNormalLabel := TFont.Create;
  With udfNormalLabel do begin
     Size := 8;
     Name := 'Times New Roman';
     Style := [fsBold];
  end;
end;


end.
