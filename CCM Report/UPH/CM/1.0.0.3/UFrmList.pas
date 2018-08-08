unit UFrmList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TFrmList = class(TForm)
    LB_Left: TListBox;
    Cmd_Left: TBitBtn;
    Cmd_Right: TBitBtn;
    LB_Right: TListBox;
    Cmd_OK: TBitBtn;
    Cmd_Cancel: TBitBtn;
    PL_Left: TPanel;
    PL_Right: TPanel;
    Cmd_LeftAll: TBitBtn;
    Cmd_RightAll: TBitBtn;
    procedure Cmd_LeftClick(Sender: TObject);
    procedure Cmd_RightClick(Sender: TObject);
    procedure Cmd_CancelClick(Sender: TObject);
    procedure Cmd_LeftAllClick(Sender: TObject);
    procedure Cmd_RightAllClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmList: TFrmList;

implementation

{$R *.dfm}

procedure TFrmList.Cmd_LeftClick(Sender: TObject);
begin
if Lb_Left.ItemIndex=-1 then
   Exit;
  if Lb_Right.Items.IndexOf(Lb_Left.items[Lb_Left.ItemIndex])<>-1 then
     Lb_Left.Items.Delete(Lb_Left.ItemIndex)
  else begin
  Lb_Right.Items.Add(Lb_Left.items[Lb_Left.ItemIndex]);
  Lb_Left.Items.Delete(Lb_Left.ItemIndex);
  End;

end;

procedure TFrmList.Cmd_RightClick(Sender: TObject);
begin
    if Lb_Right.ItemIndex=-1 then
       Exit;
    if Lb_Left.Items.IndexOf(Lb_Right.items[Lb_Right.ItemIndex])<>-1 then
       Lb_Right.Items.Delete(Lb_Right.ItemIndex)
    Else begin
    Lb_Left.Items.Add(Lb_Right.items[Lb_Right.ItemIndex]);
    Lb_Right.Items.Delete(Lb_Right.ItemIndex);
    end;
end;

procedure TFrmList.Cmd_CancelClick(Sender: TObject);
begin
Close;
end;

procedure TFrmList.Cmd_LeftAllClick(Sender: TObject);
begin
{if Lb_Left.Items.Count=0 then
   Exit;
Lb_Right.Items:=Lb_Left.Items;
Lb_Left.Clear; }
end;

procedure TFrmList.Cmd_RightAllClick(Sender: TObject);
var
  i:Integer;
begin
    if Lb_Right.Items.Count=0 then
       Exit;

    for i:=0 to Lb_Right.Items.Count-1 do
    begin
        if Lb_Left.Items.IndexOf(Lb_Right.items[0])<>-1 then
           Lb_Right.Items.Delete(0)
        Else begin
            Lb_Left.Items.Add(Lb_Right.items[0]);
            Lb_Right.Items.Delete(0);
        end;
    end;
end;

end.
