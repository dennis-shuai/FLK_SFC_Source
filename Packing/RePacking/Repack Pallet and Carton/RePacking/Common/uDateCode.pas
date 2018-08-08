unit uDateCode;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ValEdit, ExtCtrls;

type
  TfDateCode = class(TForm)
    Panel1: TPanel;
    ValueListEditor1: TValueListEditor;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ListBox1: TListBox;
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    MaxLimit: Integer;
    function GetCode(idx: Integer): String;
    { Public declarations }
  end;

var
  fDateCode: TfDateCode;

implementation

{$R *.dfm}

procedure TfDateCode.FormShow(Sender: TObject);
var
   i: Integer;
begin
   {for i := 1 to ValueListEditor1.RowCount do
      ValueListEditor1.DeleteRow(i);}
   case MaxLimit of
     31: ValueListEditor1.TitleCaptions.Strings[0] := 'Day';
     12: ValueListEditor1.TitleCaptions.Strings[0] := 'Month';
     53: ValueListEditor1.TitleCaptions.Strings[0] := 'Week';
     else
       MessageDlg('¥¼©w¸q', mtWarning, [mbOK], 0);
   end;
   for i := 1 to MaxLimit do
      ValueListEditor1.InsertRow(IntToStr(i),GetCode(i),True);
end;

function TfDateCode.GetCode(idx: Integer): String;
begin
   if ListBox1.Count >= idx then
      Result := ListBox1.Items[idx-1]
   else
      Result := '';
end;

procedure TfDateCode.BitBtn1Click(Sender: TObject);
var i, iLen: Integer;
begin
   ModalResult := mrOK;
   iLen := Length(ValueListEditor1.Cells[1, 1]);
   if iLen = 0 then
   begin
     MessageDlg('Length Error.' + #10#10 + 'Length: ' + IntToStr(iLen)
       + #10#10 + ValueListEditor1.TitleCaptions.Strings[0] + ': ' + IntToStr(1), mtError, [mbOK], 0);
     ModalResult := mrNone;
   end else
     for i := 2 to ValueListEditor1.RowCount - 1 do
       if iLen <> Length(ValueListEditor1.Cells[1, i]) then
       begin
         MessageDlg('Length Error.' + #10#10 + 'Length: ' + IntToStr(iLen)
           + #10#10 + ValueListEditor1.TitleCaptions.Strings[0] + ': ' + IntToStr(i), mtError, [mbOK], 0);
         ModalResult := mrNone;
         break;
       end;
end;

end.
