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
    Label1: TLabel;
    LvItems: TListView;
    Label11: TLabel;
    editItems: TEdit;
    procedure LvItemsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure sbtnOKClick(Sender: TObject);
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fSelect: TfSelect;

implementation

{$R *.dfm}

procedure TfSelect.LvItemsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin

  If Item.Selected Then
  begin
    If POS(Item.Caption, editItems.Text) > 0 Then Exit;
    editItems.Text := Trim(editItems.Text + ' "'+ Item.Caption + '"');
  end Else
  begin
    If POS(Item.Caption, editItems.Text) <= 0 Then Exit;
    editItems.Text := Trim(Copy(editItems.Text,1,POS(Item.Caption,editItems.Text)-2)+
                           Copy(editItems.Text,POS(Item.Caption,editItems.Text)+Length(Item.Caption)-1+3,
                                Length(editItems.Text)-POS(Item.Caption,editItems.Text)-Length(Item.Caption)+1));

  end;                   

end;

procedure TfSelect.sbtnOKClick(Sender: TObject);
begin
  modalresult := mrOK;
end;

procedure TfSelect.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfSelect.FormCreate(Sender: TObject);
begin
  LvItems.Items.Clear;
end;

end.
