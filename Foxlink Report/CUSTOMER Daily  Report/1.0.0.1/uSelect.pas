unit uSelect;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ImgList, ExtCtrls, Buttons, StdCtrls, jpeg, GradPanel;

type
  TfSelect = class(TForm)
    ImageList1: TImageList;
    GradPanel14: TGradPanel;
    Image3: TImage;
    Image4: TImage;
    sbtnClose: TSpeedButton;
    sbtnOK: TSpeedButton;
    GradPanel1: TGradPanel;
    lablTitle: TLabel;
    Label2: TLabel;
    listbAvail: TListBox;
    IncludeBtn: TSpeedButton;
    IncAllBtn: TSpeedButton;
    ExcludeBtn: TSpeedButton;
    ExAllBtn: TSpeedButton;
    listbSel: TListBox;
    procedure sbtnOKClick(Sender: TObject);
    procedure sbtnCloseClick(Sender: TObject);
    procedure IncludeBtnClick(Sender: TObject);
    procedure IncAllBtnClick(Sender: TObject);
    procedure ExcludeBtnClick(Sender: TObject);
    procedure ExAllBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure MoveSelected(List: TCustomListBox; Items: TStrings);
    procedure SetItem(List: TListBox; Index: Integer);
    function GetFirstSelection(List: TCustomListBox): Integer;

  end;

var
  fSelect: TfSelect;

implementation

{$R *.dfm}

procedure TfSelect.sbtnOKClick(Sender: TObject);
begin
  modalresult := mrOK;
end;

procedure TfSelect.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfSelect.IncludeBtnClick(Sender: TObject);
var
  index: Integer;
begin
  if  listbAvail.Items.Count <> 0 then begin
    Index := GetFirstSelection(listbAvail);
    MoveSelected(listbAvail, listbSel.Items);
    SetItem(listbAvail, index);
  end;
end;

procedure TfSelect.IncAllBtnClick(Sender: TObject);
var
  index,i: Integer;
begin
  if listbAvail.Items.Count <> 0 then begin
    for I := 0 to listbAvail.Items.Count - 1 do
    begin
       if listbSel.Items.IndexOf(listbAvail.Items[i])<0 Then
            listbSel.Items.AddObject(listbAvail.Items[I],
               listbAvail.Items.Objects[I]);
    end;
    listbAvail.Items.Clear;
    SetItem(listbAvail, 0);
  end;
end;

procedure TfSelect.ExcludeBtnClick(Sender: TObject);
var
  index: Integer;
begin
  if listbSel.Items.Count<> 0 then begin
      Index := GetFirstSelection(listbSel);
      MoveSelected(listbSel, listbAvail.Items);
      SetItem(listbSel, index);
    SetItem(listbSel, Index);
  end;
end;

procedure TfSelect.ExAllBtnClick(Sender: TObject);
var I: Integer;
begin
   if listbSel.Items.Count <> 0 then begin
      for I := 0 to listbSel.Items.Count - 1 do
      begin
          if listbAvail.Items.IndexOf(listbSel.Items[i])<0 Then
                listbAvail.Items.AddObject(listbSel.Items[I], listbSel.Items.Objects[I]);
      end;
      listbSel.Items.Clear;
      SetItem(listbSel, 0);
   end;
end;
procedure TfSelect.MoveSelected(List: TCustomListBox; Items: TStrings);
var
   I: Integer;
begin
   for I := List.Items.Count - 1 downto 0 do
      if (List.Selected[I]) Then
      begin
          if (Items.IndexOf(List.Items[i])<0) then
          begin
              Items.AddObject(List.Items[I], List.Items.Objects[I]);
          end;
          List.Items.Delete(I);
      end;
end;
procedure TfSelect.SetItem(List: TListBox; Index: Integer);
var
   MaxIndex: Integer;
begin
   with List do
   begin
      SetFocus;
      MaxIndex := List.Items.Count - 1;
      if Index = -1 then Index := 0
      else if Index > MaxIndex then Index := MaxIndex;
      Selected[Index] := True;
   end;
end;
function TfSelect.GetFirstSelection(List: TCustomListBox): Integer;
begin
   for Result := 0 to List.Items.Count - 1 do
      if List.Selected[Result] then Exit;
   Result := LB_ERR;
end;

end.
