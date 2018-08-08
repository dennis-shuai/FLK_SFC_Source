unit uLang;

interface

uses
  Classes, Dialogs, Windows,SysUtils, DBTables, StdCtrls, Grids, Controls,
  Graphics, ExtCtrls, Buttons, Mask, CheckLst, ComCtrls, Forms, Db, DBClient ;

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
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    Function GetLanguage(Qry : TClientDataSet) : Boolean;
    procedure Translation(AObject : TComponent);
    procedure TranslationObject(Sender : TComponent);
    Function  TranslationText(sText : String) : String;
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
begin
  if Sender is TForm then               //TFORM
    (Sender as TForm).Caption := TranslationText((Sender as TForm).Caption)
  else if (Sender is TLabel) then       //TLabel
    (Sender as TLabel).Caption := TranslationText((Sender as TLabel).Caption)
  else if (Sender is TSpeedButton) then //TSpeedButton
    (Sender as TSpeedButton).Caption := TranslationText((Sender as TSpeedButton).Caption)
  else if (Sender is TButton) then      //TButton
    (Sender as TButton).Caption := TranslationText((Sender as TButton).Caption)
  else if (Sender is TCheckBox) then    //TCheckBox
    (Sender as TCheckBox).Caption := TranslationText((Sender as TCheckBox).Caption)
  else if (Sender is TRadioButton) then //TRadioButton
    (Sender as TRadioButton).Caption := TranslationText((Sender as TRadioButton).Caption)
  else if (Sender is TGroupBox) then //TGroupBox
    (Sender as TGroupBox).Caption := TranslationText((Sender as TGroupBox).Caption);
end;

Function TLanguage.TranslationText(sText : String) : String;
Var iLang,iIDx : Integer;  sSource : String;
begin
  Result := sText;
  sSource := '';
  // ¥Ø«eªº
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
                     'Order By LANG_CODE, TEXT_DESC ';
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
end;

destructor TLanguage.Destroy;
Var I,mi : Integer;
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
