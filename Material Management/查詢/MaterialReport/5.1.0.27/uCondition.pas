unit uCondition;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
IniFiles, DB, DBClient, StdCtrls, Buttons, ComCtrls, ExtCtrls;

type
  TfCondition = class(TForm)
    ConditionDataSet: TClientDataSet;
    GroupBox1: TGroupBox;
    listbAvail: TListBox;
    ExcludeBtn: TSpeedButton;
    IncludeBtn: TSpeedButton;
    GroupBox2: TGroupBox;
    listbSelect: TListBox;
    Image3: TImage;
    Button3: TSpeedButton;
    Button2: TSpeedButton;
    Button1: TSpeedButton;
    Image2: TImage;
    Image1: TImage;
    Image4: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure IncludeBtnClick(Sender: TObject);
    procedure ExcludeBtnClick(Sender: TObject);
    procedure listbAvailDblClick(Sender: TObject);
    procedure listbSelectDblClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);

  private
    { Private declarations }
    function  GetFirstSelection(List: TCustomListBox): Integer;
    procedure SetItem(List: TListBox; Index: Integer);
    procedure MoveSelected(List: TCustomListBox; Items: TStrings);
  public
    { Public declarations }

  end;

var
  fCondition: TfCondition;

implementation


{$R *.dfm}

procedure TfCondition.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfCondition.IncludeBtnClick(Sender: TObject);
var
  index : Integer;
begin
  if listbAvail.Focused=False then
     listbAvail.Selected[0]:=True;
  if  listbAvail.Items.Count <> 0 then
  begin
    Index := GetFirstSelection(listbAvail);
    MoveSelected(listbAvail, listbSelect.Items);
    SetItem(listbAvail, index);
  end;
end;

function TfCondition.GetFirstSelection(List: TCustomListBox): Integer;
begin
  for Result := 0 to List.Items.Count - 1 do
    if List.Selected[Result] then Exit;
  Result := LB_ERR;
end;

procedure TfCondition.MoveSelected(List: TCustomListBox; Items: TStrings);
var
  I: Integer;
begin
  for I := List.Items.Count - 1 downto 0 do
    if (List.Selected[I]) Then
    begin
      if (Items.IndexOf(List.Items[i])<0) then
        Items.AddObject(List.Items[I], List.Items.Objects[I]);
      List.Items.Delete(I);
    end;
end;

procedure TfCondition.SetItem(List: TListBox; Index: Integer);
var
   MaxIndex: Integer;
begin
   with List do
   begin
      SetFocus;
      MaxIndex := List.Items.Count - 1;
      if Index = -1 then Index := 0
      else if Index > MaxIndex then Index := MaxIndex;
      if List.Count>0 then
        Selected[Index] := True;
   end;
end;

procedure TfCondition.ExcludeBtnClick(Sender: TObject);
var
  index: Integer;
begin
  if listbSelect.Focused=False then
     listbSelect.Selected[0]:=True;
  if listbSelect.Items.Count>1 then
  begin
    Index := GetFirstSelection(listbSelect);
    MoveSelected(listbSelect, listbAvail.Items);
    SetItem(listbSelect, index);
    SetItem(listbSelect, Index);
  end;
end;

procedure TfCondition.listbAvailDblClick(Sender: TObject);
begin
  IncludeBtnClick(Self);
end;

procedure TfCondition.listbSelectDblClick(Sender: TObject);
begin
  ExcludeBtnClick(Self);
end;

procedure TfCondition.Button2Click(Sender: TObject);
Var i : Integer;
    fInI: TIniFile;
    Str : String;
begin
   ModalResult:=mrOK;
end;

procedure TfCondition.Button1Click(Sender: TObject);
begin
   listbSelect.Items.Clear;
end;

procedure TfCondition.Button3Click(Sender: TObject);
begin
   close;
end;

end.
