unit uLang;

interface

uses
  Classes, Dialogs, Windows,SysUtils,DBTables,StdCtrls,Grids,Controls,
  Graphics,ExtCtrls,Buttons,Mask,CheckLst,ComCtrls,Forms, Db, DBClient,DBGrids, Menus ;

  type
  TLanguage = class(TComponent)
  private
  public
    lstLanguage : TStrings;
    lstLangCode : TStrings;
    lstText  : Array of TStrings;
    lstTrans : Array of TStrings;
    CurrentLanguage : String;
    TransToLanguage : String;
    ModuleName : String;
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    Function GetLanguage(Qry : TClientDataSet) : Boolean;
    procedure Translation(AObject : TComponent);
    procedure TranslationObject(Sender : TComponent);
    Function  TranslationText(sText,sSpecialLang : String) : String;
    Function  TranslationTextDef(sText : String) : String;
    Function  TranslationTextMsg(sText : String) : String;
    Function  TranslationTextID(sText : String) : String;
  end;

implementation

procedure TLanguage.Translation(AObject : TComponent);
Var I : Integer;
begin
  If (AObject is TForm) Then
  begin
    for I := 0 to (AObject.ComponentCount - 1) do
      TranslationObject(AObject.Components[i]);
    Exit;
  end;
end;

procedure TLanguage.TranslationObject(Sender : TComponent);
Var I : Integer;
begin

  if Sender is TForm then               //TFORM
    (Sender as TForm).Caption := TranslationText((Sender as TForm).Caption,'')
  Else if (Sender is TLabel) then       //TLabel
    (Sender as TLabel).Caption := TranslationText((Sender as TLabel).Caption,'')
  Else If (Sender is TSpeedButton) then //TSpeedButton
    (Sender as TSpeedButton).Caption := TranslationText((Sender as TSpeedButton).Caption,'')
  Else If (Sender is TButton) then      //TButton
    (Sender as TButton).Caption := TranslationText((Sender as TButton).Caption,'')
  Else If (Sender is TCheckBox) then    //TCheckBox
    (Sender as TCheckBox).Caption := TranslationText((Sender as TCheckBox).Caption,'')
  Else If (Sender is TRadioButton) then //TRadioButton
    (Sender as TRadioButton).Caption := TranslationText((Sender as TRadioButton).Caption,'')
  Else If (Sender is TMenuItem) then //TMenuItem
    (Sender as TMenuItem).Caption := TranslationText((Sender as TMenuItem).Caption,'')
  Else If (Sender is TListView) then //TMenuItem
  begin
    for I := 0 to (Sender as TListView).Columns.Count - 1 do
      (Sender as TListView).Columns[I].Caption := TranslationText((Sender as TListView).Columns[I].Caption,'');
  end Else If (Sender is TDBGrid) then
  begin
    for I := 0 to (Sender as TDBGrid).Columns.Count - 1 do
      (Sender as TDBGrid).Columns[I].Title.Caption := TranslationText((Sender as TDBGrid).Columns[I].Title.Caption,'');
  end;
end;

Function TLanguage.TranslationTextID(sText : String) : String;
Var iLang,iIDx : Integer;
begin
  Result := sText;
  iLang := lstLanguage.IndexOf(CurrentLanguage);

  If iLang >= 0 Then
  begin
    iIDx := lstTrans[iLang].IndexOf(sText);
    If iIDx >= 0 Then
      Result := lstText[iLang].Strings[iIDx];
  end;
end;

Function TLanguage.TranslationTextMsg(sText : String) : String;
var I : Integer;
    sStr : String;
begin
   Result := '';
   sStr := sText;
   while true do
   begin
     I := POS(#13,sStr);
     If I > 0 Then
     begin
       Result := Result + TranslationText(Copy(sStr,1,I-1),'English') + #13;
       sStr := Copy(sStr,I+1,Length(sStr)-I);
     end else
     begin
       Result := Result + TranslationText(sStr,'English');
       break;
     end;
   end;
end;

Function TLanguage.TranslationTextDef(sText : String) : String;
begin
  Result := TranslationText(sText,'English');
end;

Function TLanguage.TranslationText(sText,sSpecialLang : String) : String;
Var iLang,iIDx : Integer;  sSource : String;
begin
  sText := Trim(sText);
  Result := sText;
  sSource := '';
  // ¥Ø«eªº
  If sSpecialLang <> '' Then
    iLang := lstLanguage.IndexOf(sSpecialLang)
  else
    iLang := lstLanguage.IndexOf(CurrentLanguage);

  If iLang >= 0 Then
  begin
    iIDx := lstTrans[iLang].IndexOf(sText);
    If iIDx >= 0 Then
      sSource := lstText[iLang].Strings[iIDx];
  end;

  If sSource = '' Then
    sSource := sText;

  iLang := lstLanguage.IndexOf(TransToLanguage);
  If iLang < 0 Then
    Exit;

  iIDx := lstText[iLang].IndexOf(sSource);
  If iIDx < 0 Then
    Exit;

  Result := lstTrans[iLang].Strings[iIDx];
end;

Function TLanguage.GetLanguage(Qry : TClientDataSet) : Boolean;
Var i : Integer; sCode : String;
begin
  Result := False;
  lstLanguage := TStringList.Create;
  lstLangCode := TStringList.Create;
  Try
    i := 0;
    With Qry do
    begin
      Close;
      Params.Clear;
      CommandText := 'Select * From LANG.LANG_TYPE '+
                     'Order By LANG_CODE ';
      Open;
      SetLength(lstText,RecordCount);
      SetLength(lstTrans,RecordCount);
      While not eof do
      begin
        lstLangCode.Add(Fieldbyname('LANG_CODE').AsString);
        lstLanguage.Add(Fieldbyname('LANG_NAME').AsString);
        lstText[i] := TStringList.Create;
        lstTrans[i] := TStringList.Create;
        inc(i);
        Next;
      end;
      Close;

      Params.Clear;
      CommandText := 'Select * From LANG.LANG_TRANSLATION '+
                     'Where KIND in (''DEFAULT'','''+ModuleName+''') '+
                     'Order By LANG_CODE,KIND,TEXT_DESC ';
      Open;
      sCode := '';
      While not eof do
      begin
        If sCode <> Fieldbyname('LANG_CODE').AsString Then
        begin
          sCode := Fieldbyname('LANG_CODE').AsString;
          i := lstLangCode.Indexof(sCode);
        end;
        If i >= 0 Then
        begin
          lstText[i].Add(Fieldbyname('TEXT_DESC').AsString);
          lstTrans[i].Add(Fieldbyname('TRANSLATION').AsString);
        end;
        Next;
      end;
      Close;
    end;
  Except
  end;
end;

constructor TLanguage.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  CurrentLanguage := 'English';
  TransToLanguage := 'English';
  ModuleName := 'N/A';
end;

destructor TLanguage.Destroy;
Var I : Integer;
begin
  for i := 0 to lstLanguage.Count - 1 do
  begin
    Try lstText[i].free; except end;
    try lstTrans[i].free; Except end;
  end;

  lstLanguage.Free;
  lstLangCode.Free;

  inherited Destroy;
end;

end.
