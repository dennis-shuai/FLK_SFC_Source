unit uRetry;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls,BmpRgn,Spin;

type
  TfRetry = class(TForm)
    labSN: TLabel;
    edtSN: TEdit;
    lablMsg: TLabel;
    SpeedButton1: TSpeedButton;
    Image1: TImage;
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SetTheRegion;
  private
    { Private declarations }
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
  public
    { Public declarations }
  end;

var
  fRetry: TfRetry;

implementation

uses unitMain;

{$R *.dfm}
procedure TfRetry.SetTheRegion;
var
  HR: HRGN;
begin
  HR := BmpToRegion(Self, Image1.Picture.Bitmap);
  SetWindowRgn(handle, HR, true);
  Invalidate;
end;

procedure TfRetry.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
var
  Brush: TBrush;
begin
  Brush := TBrush.Create;
  Brush.Color := Color;
  FillRect(Msg.DC, ClientRect, Brush.Handle);
  Brush.Free;
  with Image1.Picture.Bitmap do
    BitBlt(Msg.DC, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := 1;
end;

// This routine takes care of letting the user move the form
// around on the desktop.

procedure TfRetry.WMNCHitTest(var msg: TWMNCHitTest);
var
  i: integer;
  p: TPoint;
  AControl: TControl;
  MouseOnControl: boolean;
begin
  inherited;
  if msg.result = HTCLIENT then
  begin
    p.x := msg.XPos;
    p.y := msg.YPos;
    p := ScreenToClient(p);
    MouseOnControl := false;
    for i := 0 to ControlCount - 1 do
    begin
      if not MouseOnControl
        then
      begin
        AControl := Controls[i];
        if ((AControl is TWinControl) or (AControl is TGraphicControl))
          and (AControl.Visible)
          then MouseOnControl := PtInRect(AControl.BoundsRect, p);
      end
      else
        break;
    end;
    if (not MouseOnControl) then msg.Result := HTCAPTION;
  end;
end ;

procedure TfRetry.edtSNKeyPress(Sender: TObject; var Key: Char);
var sResult:string;
begin
   sResult:='';
   if key=#13 then
     if trim(edtSN.Text)<>'' then
        if not formMain.Transdata(trim(edtSN.Text)+';',sResult) then
        begin
          edtSN.SelectAll;
          edtSN.SetFocus;
          lablMsg.Caption:=sResult;
          lablMsg.Font.Color := clred;
          MessageBeep(48);
        end
        else begin
          lablMsg.Font.Color := clBlue;
          lablMsg.Caption:=sResult;
          ModalResult:=mrOK;
          close;
        end
     else begin
          lablMsg.Caption:='S/N Blank!!';
          lablMsg.Font.Color := clred;
          MessageBeep(48);
     end;
end;

procedure TfRetry.SpeedButton1Click(Sender: TObject);
begin
   CLOSE;
end;

procedure TfRetry.FormShow(Sender: TObject);
begin
   edtSN.Text:='';
   LablMsg.Caption:='Result:' ;
   lablMsg.Font.Color :=clBlack;
end;

end.
