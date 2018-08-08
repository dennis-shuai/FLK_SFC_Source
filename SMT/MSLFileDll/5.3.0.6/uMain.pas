unit uMain;

interface

uses SysUtils, Classes, Variants, ComObj, ObjBrkr, IniFiles, Dialogs;

function MSLFileTransfer(iType: integer; sFileName: string): string; stdcall; export;
function FileTrans1(sExcelFile: string): string;
function FileTrans2(sExcelFile: string): string;
procedure DecodeStr(sTemp: string; var sStationNo, sItem, sSpec, sAllLocate, sQty: string);

implementation

function MSLFileTransfer(iType: integer; sFileName: string): string;
begin
  case iType of
    1: Result := FileTrans1(sFileName);
    2: Result := FileTrans2(sFileName);
  else
    Result := 'MSL Type Error.';
  end;
end;

procedure DecodeStr(sTemp: string; var sStationNo, sItem, sSpec, sAllLocate, sQty: string);
begin
  sStationNo := Copy(sTemp, 1, Pos(',', sTemp) - 1);
  sTemp := Copy(sTemp, Pos(',', sTemp) + 1, Length(sTemp));
  sItem := Copy(sTemp, 1, Pos(',', sTemp) - 1);
  sTemp := Copy(sTemp, Pos(',', sTemp) + 1, Length(sTemp));
  sSpec := Copy(sTemp, 1, Pos(',', sTemp) - 1);
  sTemp := Copy(sTemp, Pos(',', sTemp) + 1, Length(sTemp));
  sTemp := Copy(sTemp, Pos(',', sTemp) + 1, Length(sTemp));
  sAllLocate := Copy(sTemp, 1, Pos(',', sTemp) - 1);
  sQty := Copy(sTemp, Pos(',', sTemp) + 1, Length(sTemp));
end;

function FileTrans2(sExcelFile: string): string;
var MsExcel, MsExcelworkBook: Variant;
  sTemp, sSpec, sSpec2, sItem, sAllLocation, sStationNo, sItem2, sSide, sLTemp, sSTemp,sFeeder: string;
  iTemp, iRow, iQty, iQTemp, iSubQty, i, j: Integer;
  FileTemp: TStrings; PIni: TIniFile;
begin
  Result := '';
  try
    try
      FileTemp := TStringList.Create;
      MsExcel := CreateOleObject('Excel.Application');
      MsExcelWorkBook := MsExcel.WorkBooks.Open(sExcelFile);
      for i := 1 to MsExcel.Worksheets.Count do
      begin
        MsExcel.Worksheets[i].select;
        if MsExcel.WorkSheets[i].Range['A4'].Value <> '站別' then
        begin
          Result := 'Excel File Format Error-站別!!';
          Exit;
        end;
        if (MsExcel.WorkSheets[i].Range['C4'].Value <> '新料號') and (MsExcel.WorkSheets[i].Range['C4'].Value <> '料號') then
        begin
          Result := 'Excel File Format Error-料號!!';
          Exit;
        end;
        if MsExcel.WorkSheets[i].Range['D4'].Value <> '代用料' then
        begin
          Result := 'Excel File Format Error-代用料!!';
          Exit;
        end;
        iSubQty := 0;
        iTemp := MsExcel.WorkSheets[i].UsedRange.Columns.Count;
        for j := 4 to iTemp do
        begin
          if MsExcel.WorkSheets[i].Range[Char(64 + j) + '4'].Value = '代用料' then
            Inc(iSubQty)
          else if MsExcel.WorkSheets[i].Range[Char(64 + j) + '4'].Value = '用量' then
            break;
        end;
        if MsExcel.WorkSheets[i].Range[Char(68 + iSubQty) + '4'].Value <> '用量' then
        begin
          Result := 'Excel File Format Error-用量!!';
          Exit;
        end;
        if MsExcel.WorkSheets[i].Range[Char(69 + iSubQty) + '4'].Value <> '位置' then
        begin
          Result := 'Excel File Format Error-位置!!';
          Exit;
        end;
        if MsExcel.WorkSheets[i].Range[Char(70 + iSubQty) + '4'].Value <> '規格' then
        begin
          Result := 'Excel File Format Error-規格!!';
          Exit;
        end;
        //ADD BY KEY 2008/01/24
        if MsExcel.WorkSheets[i].Range[Char(71 + iSubQty) + '4'].Value <> '料架類型' then
        begin
          Result := 'Excel File Format Error-料架類型!!';
          Exit;
        end;
        // ADD END
        iQTemp := 0; sLTemp := ''; sSTemp := '';
        iTemp := MsExcel.WorkSheets[i].UsedRange.Rows.Count;
        for iRow := 5 to iTemp do
        begin
          sStationNo := Trim(MsExcel.WorkSheets[i].Range['A' + IntToStr(iRow)].Value);
          sSide := Trim(MsExcel.WorkSheets[i].Range['B' + IntToStr(iRow)].Value);
          if (sSide <> '') and (sStationNo = '') then
            sStationNo := sSTemp;
          sItem := Trim(MsExcel.WorkSheets[i].Range['C' + IntToStr(iRow)].Value);
          iQty := StrToIntDef(Trim(MsExcel.WorkSheets[i].Range[Char(68 + iSubQty) + IntToStr(iRow)].Value), 0);
          if iQty = 0 then
            iQty := iQTemp;
          sAllLocation := Trim(MsExcel.WorkSheets[i].Range[Char(69 + iSubQty) + IntToStr(iRow)].Value);
          if sAllLocation = '' then
            sAllLocation := sLTemp;
          sSpec := Trim(MsExcel.WorkSheets[i].Range[Char(70 + iSubQty) + IntToStr(iRow)].Value);
          //ADD BY KEY 2008/01/24
          sFeeder:= Trim(MsExcel.WorkSheets[i].Range[Char(71 + iSubQty) + IntToStr(iRow)].Value);
          //ADD END
          iQTemp := iQty;
          sLTemp :=  sAllLocation;
          sSTemp := sStationNo;
          if (sStationNo <> '') and (sItem <> '') then
          begin
            if Pos('/', sStationNo) <> 0 then
              sStationNo := Copy(sStationNo, 1, Pos('/', sStationNo) - 1);
            sStationNo := sStationNo + sSide;
            //FileTemp.Add(sStationNo + #9 + sItem + #9 + sSpec + #9 + sSpec2 + #9 + sAllLocation + #9 + IntToStr(iQty) + #9 + #9);
            FileTemp.Add(sStationNo + #9 + sItem + #9 + sSpec + #9 + sSpec2 + #9 + sAllLocation + #9 + IntToStr(iQty) + #9 + sFeeder + #9);
            for j := 1 to iSubQty do
            begin
              sItem2 := Trim(MsExcel.WorkSheets[i].Range[Char(67 + j) + IntToStr(iRow)].Value);
              if sItem2 <> '' then
                //FileTemp.Add(sStationNo + #9 + sItem2 + #9 + sSpec + #9 + sSpec2 + #9 + sAllLocation + #9 + IntToStr(iQty) + #9 + #9);
                FileTemp.Add(sStationNo + #9 + sItem2 + #9 + sSpec + #9 + sSpec2 + #9 + sAllLocation + #9 + IntToStr(iQty) + #9 + sFeeder + #9);
            end;
          end;
        end;
        if FileTemp.Count > 0 then begin
          sTemp := ChangeFileExt(sExcelFile, '-' + FormatFloat('00', i) + '.msl');
          FileTemp.SaveToFile(sTemp);
          PIni := TIniFile.Create(ChangeFileExt(sExcelFile, '.ini'));
          sTemp := Trim(MsExcel.WorkSheets[i].Range['A2'].Value);
          sTemp := Trim(Copy(sTemp, Pos('：', sTemp) + 2, Length(sTemp)));
          PIni.WriteString(IntToStr(i), 'Part', sTemp);
          sTemp := Trim(MsExcel.WorkSheets[i].Range[Char(68 + iSubQty) + '3'].Value);
          sTemp := Trim(Copy(sTemp, Pos(':', sTemp) + 1, Pos(' ', sTemp) - 1));
          PIni.WriteString(IntToStr(i), 'Machine', sTemp);
          sTemp := Trim(MsExcel.WorkSheets[i].Range[Char(70 + iSubQty) + '3'].Value);
          sTemp := Trim(Copy(sTemp, Pos(':', sTemp) + 1, Length(sTemp)));
          PIni.WriteString(IntToStr(i), 'Version', sTemp);
          sTemp := Trim(MsExcel.WorkSheets[i].Range['A1'].Value);
          if Pos('BOT', sTemp) <> 0 then sTemp := 'Bottom'
          else sTemp := 'Top';
          PIni.WriteString(IntToStr(i), 'Side', sTemp);
          PIni.WriteInteger('TotalPage', 'Count', MsExcel.Worksheets.Count);
          PIni.Free;
        end;
        FileTemp.Clear;
      end;
      Result := 'OK';
      FileTemp.Free;
    finally
      MsExcel.Quit;
      MsExcel := Null;
    end;
  except
    Result := 'Can''t Open File!!';
  end;
end;

function FileTrans1(sExcelFile: string): string;
var MsExcel, MsExcelworkBook: Variant;
  sTemp, sSpec, sSpec2, sItem, sAllLocation, sStationNo, sItem2, sLTemp, sFeeder: string;
  iTemp, iRow, iQty, iQTemp, iSubQty, i, j: Integer;
  FileTemp: TStrings; PIni: TIniFile;
begin
  Result := '';
  try
    try
      FileTemp := TStringList.Create;
      MsExcel := CreateOleObject('Excel.Application');
      MsExcelWorkBook := MsExcel.WorkBooks.Open(sExcelFile);
      for i := 1 to MsExcel.Worksheets.Count do
      begin
        MsExcel.Worksheets[i].select;
        if MsExcel.WorkSheets[i].Range['A4'].Value <> '站別' then
        begin
          Result := 'Excel File Format Error-站別!!';
          Exit;
        end;
        if (MsExcel.WorkSheets[i].Range['B4'].Value <> '新料號') and (MsExcel.WorkSheets[i].Range['B4'].Value <> '料號') then
        begin
          Result := 'Excel File Format Error-料號!!';
          Exit;
        end;
        if MsExcel.WorkSheets[i].Range['C4'].Value <> '代用料' then
        begin
          Result := 'Excel File Format Error-代用料!!';
          Exit;
        end;
        iSubQty := 0;
        iTemp := MsExcel.WorkSheets[i].UsedRange.Columns.Count;
        for j := 3 to iTemp do
        begin
          if MsExcel.WorkSheets[i].Range[Char(64 + j) + '4'].Value = '代用料' then
            Inc(iSubQty)
          else if MsExcel.WorkSheets[i].Range[Char(64 + j) + '4'].Value = '用量' then
            break;
        end;
        if MsExcel.WorkSheets[i].Range[Char(67 + iSubQty) + '4'].Value <> '用量' then
        begin
          Result := 'Excel File Format Error-用量!!';
          Exit;
        end;
        if MsExcel.WorkSheets[i].Range[Char(68 + iSubQty) + '4'].Value <> '位置' then
        begin
          Result := 'Excel File Format Error-位置!!';
          Exit;
        end;
        if MsExcel.WorkSheets[i].Range[Char(69 + iSubQty) + '4'].Value <> '規格' then
        begin
          Result := 'Excel File Format Error-規格!!';
          Exit;
        end;
        //ADD BY KEY 2008/01/24
        if MsExcel.WorkSheets[i].Range[Char(70 + iSubQty) + '4'].Value <> '料架類型' then
        begin
          Result := 'Excel File Format Error-料架類型!!';
          Exit;
        end;
        // ADD END
        iTemp := MsExcel.WorkSheets[i].UsedRange.Rows.Count;
        iQTemp := 0; sLTemp := '';
        for iRow := 5 to iTemp do
        begin
          sStationNo := Trim(MsExcel.WorkSheets[i].Range['A' + IntToStr(iRow)].Value);
          sItem := Trim(MsExcel.WorkSheets[i].Range['B' + IntToStr(iRow)].Value);
          iQty := StrToIntDef(Trim(MsExcel.WorkSheets[i].Range[Char(67 + iSubQty) + IntToStr(iRow)].Value), 0);
          if iQty = 0 then
            iQty := iQTemp;
          sAllLocation := Trim(MsExcel.WorkSheets[i].Range[Char(68 + iSubQty) + IntToStr(iRow)].Value);
          if sAllLocation = '' then
            sAllLocation := sLTemp;
          sSpec := Trim(MsExcel.WorkSheets[i].Range[Char(69 + iSubQty) + IntToStr(iRow)].Value);
          //ADD BY KEY 2008/01/24
          sFeeder:= Trim(MsExcel.WorkSheets[i].Range[Char(70 + iSubQty) + IntToStr(iRow)].Value);
          //ADD END
          iQTemp := iQty;
          sLTemp :=  sAllLocation;
          if (sStationNo <> '') and (sItem <> '') then
          begin
            if Pos('/', sStationNo) <> 0 then
              sStationNo := Copy(sStationNo, 1, Pos('/', sStationNo) - 1);
            //FileTemp.Add(sStationNo + #9 + sItem + #9 + sSpec + #9 + sSpec2 + #9 + sAllLocation + #9 + IntToStr(iQty) + #9 + #9);
             FileTemp.Add(sStationNo + #9 + sItem + #9 + sSpec + #9 + sSpec2 + #9 + sAllLocation + #9 + IntToStr(iQty) + #9 + sFeeder + #9);
            for j := 1 to iSubQty do
            begin
              sItem2 := Trim(MsExcel.WorkSheets[i].Range[Char(66 + j) + IntToStr(iRow)].Value);
              if sItem2 <> '' then
               // FileTemp.Add(sStationNo + #9 + sItem2 + #9 + sSpec + #9 + sSpec2 + #9 + sAllLocation + #9 + IntToStr(iQty) + #9 + #9);
               FileTemp.Add(sStationNo + #9 + sItem2 + #9 + sSpec + #9 + sSpec2 + #9 + sAllLocation + #9 + IntToStr(iQty) + #9 + sFeeder + #9);
            end;
          end;
        end;
        if FileTemp.Count > 0 then begin
          sTemp := ChangeFileExt(sExcelFile, '-' + FormatFloat('00', i) + '.msl');
          FileTemp.SaveToFile(sTemp);
          PIni := TIniFile.Create(ChangeFileExt(sExcelFile, '.ini'));
          sTemp := Trim(MsExcel.WorkSheets[i].Range['A2'].Value);
          sTemp := Trim(Copy(sTemp, Pos('：', sTemp) + 2, Length(sTemp)));
          PIni.WriteString(IntToStr(i), 'Part', sTemp);
          sTemp := Trim(MsExcel.WorkSheets[i].Range[Char(67 + iSubQty) + '3'].Value);
          sTemp := Trim(Copy(sTemp, Pos(':', sTemp) + 1, Pos(' ', sTemp) - 1));
          PIni.WriteString(IntToStr(i), 'Machine', sTemp);
          sTemp := Trim(MsExcel.WorkSheets[i].Range[Char(69 + iSubQty) + '3'].Value);
          sTemp := Trim(Copy(sTemp, Pos(':', sTemp) + 1, Length(sTemp)));
          PIni.WriteString(IntToStr(i), 'Version', sTemp);
          sTemp := Trim(MsExcel.WorkSheets[i].Range['A1'].Value);
          if Pos('BOT', sTemp) <> 0 then sTemp := 'Bottom'
          else sTemp := 'Top';
          PIni.WriteString(IntToStr(i), 'Side', sTemp);
          PIni.WriteInteger('TotalPage', 'Count', MsExcel.Worksheets.Count);
          PIni.Free;
        end;
        FileTemp.Clear;
      end;
      Result := 'OK';
      FileTemp.Free;
    finally
      MsExcel.Quit;
      MsExcel := Null;
    end;
  except
    Result := 'Can''t Open File!!';
  end;
end;

end.

