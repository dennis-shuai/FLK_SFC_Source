unit uSort;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ImgList, ExtCtrls, Buttons, StdCtrls, jpeg, GradPanel;

type
  TfSort = class(TForm)
    ImageList1: TImageList;
    GradPanel14: TGradPanel;
    Image3: TImage;
    Image4: TImage;
    sbtnClose: TSpeedButton;
    sbtnOK: TSpeedButton;
    GradPanel1: TGradPanel;
    Label1: TLabel;
    LvItems: TListView;
    LvSort: TListView;
    Label2: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    procedure sbtnOKClick(Sender: TObject);
    procedure sbtnCloseClick(Sender: TObject);
    procedure LvSortDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure LvSortDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fSort: TfSort;

implementation

{$R *.dfm}

procedure TfSort.sbtnOKClick(Sender: TObject);
begin
  modalresult := mrOK;
end;

procedure TfSort.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfSort.LvSortDragDrop(Sender, Source: TObject; X, Y: Integer);
var I: Integer; mS: string;
begin
   if (LvSort.ItemFocused.Index < 0) or (LvSort.DropTarget.index < 0) then Exit;
   if LvSort.ItemFocused.Index <= LvSort.DropTarget.index then begin
      for I := LvSort.ItemFocused.Index to LvSort.DropTarget.index - 1 do begin
         mS := LvSort.Items[I].Caption;
         LvSort.Items[I].Caption := LvSort.Items[I + 1].CAption;
         LvSort.Items[I + 1].Caption := mS;
      end;
   end
   else begin
      for I := LvSort.ItemFocused.Index downto LvSort.DropTarget.index + 1 do begin
         mS := LvSort.Items[I].Caption;
         LvSort.Items[I].Caption := LvSort.Items[I - 1].Caption;
         LvSort.Items[I - 1].Caption := mS;
      end;
   end;
end;

procedure TfSort.LvSortDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
   if (Source is TListView) then Accept := True;
end;

procedure TfSort.SpeedButton1Click(Sender: TObject);
Var I,J : Integer; B : Boolean;
begin
  If LvItems.Selected = nil Then Exit;
  B := False;
  For J := 0 to LvItems.Items.Count - 1 do
    If LvItems.Items[J].Selected Then
    begin
      For I := 0 to LvSort.Items.Count - 1 do
        If LvSort.Items[I].Caption = LvItems.Items[J].Caption Then
        begin
          B := True;
          Break;
        end;
      If not B Then
      begin
        With LvSort.Items.Add do
          Caption := LvItems.Items[J].Caption;
      end;
    end;
end;

procedure TfSort.SpeedButton2Click(Sender: TObject);
var I: Integer; mS: string;
begin
  If LvSort.Selected = nil Then Exit;
  If LvSort.Selected.Index = 0 Then Exit;
  I :=LvSort.Selected.Index;

  mS := LvSort.Items[I].Caption;
  LvSort.Items[I].Caption := LvSort.Items[I - 1].Caption;
  LvSort.Items[I - 1].Caption := mS;
end;

procedure TfSort.SpeedButton3Click(Sender: TObject);
var I: Integer; mS: string;
begin
  If LvSort.Selected = nil Then Exit;
  If LvSort.Selected.Index = (LvSort.Items.Count - 1) Then Exit;
  I :=LvSort.Selected.Index;

  mS := LvSort.Items[I].Caption;
  LvSort.Items[I].Caption := LvSort.Items[I + 1].Caption;
  LvSort.Items[I + 1].Caption := mS;
end;

end.
