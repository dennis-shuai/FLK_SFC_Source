unit uFormInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormInfo = class(TForm)
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormInfo: TFormInfo;

implementation

{$R *.dfm}

procedure TFormInfo.FormShow(Sender: TObject);
begin
  Self.Left := Round((Screen.Width - Self.Width )/2);
  Self.Top := Round((Screen.Height - Self.Height )/2);
end;

procedure TFormInfo.FormCreate(Sender: TObject);
begin
  SetWindowPos(Handle ,HWND_TOPMOST ,0 ,0 ,0 ,0 , SWP_NOMOVE or SWP_NOSIZE);
end;

procedure TFormInfo.FormPaint(Sender: TObject);
var
    DC : HDC  ;
    Pen : HPEN ;
    OldPen : HPEN ;
    OldBrush : HBRUSH ;
begin
    Canvas.Pen.Color := clBlue ;
    Canvas.Brush.Color := clBlue ;
    DC := GetWindowDC(Handle);
    Pen := CreatePen(PS_SOLID, 1, clGray);
    OldPen := SelectObject(DC, Pen); //載入自定義的畫筆,保存原畫筆
    OldBrush := SelectObject(DC, GetStockObject(NULL_BRUSH));//載入空畫刷,保存原畫刷
    //RoundRect(DC, 0, 0, Width-1, Height-1,21,21); //畫邊框
    RoundRect(DC, 0, 0, Width-1, Height-1,0,0); //畫邊框
    SelectObject(DC,OldBrush);//載入原畫刷
    SelectObject(DC,OldPen); // 載入原畫筆
    DeleteObject(Pen);
    ReleaseDC(Handle, DC);
end;

end.
