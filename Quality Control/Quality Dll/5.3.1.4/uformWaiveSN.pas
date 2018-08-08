unit uformWaiveSN;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ComCtrls, ExtCtrls,BmpRgn, StdCtrls, ListView1;

type
  TformWaiveSN = class(TForm)
    Imagemain: TImage;
    ImgOK: TImage;
    Image1: TImage;
    sbtnExit: TSpeedButton;
    sbtnSave: TSpeedButton;
    Label4: TLabel;
    lablLotNO: TLabel;
    Label1: TLabel;
    lablResult: TLabel;
    PanelMsg: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    lablScrapQty: TLabel;
    lablRepairQty: TLabel;
    lablRouteErrorQty: TLabel;
    lvSN: TListView1;
    procedure sbtnExitClick(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
     procedure SetTheRegion;
  end;

var
  formWaiveSN: TformWaiveSN;

implementation

{$R *.dfm}
// This routine takes care of drawing the bitmap on the form.
procedure TformWaiveSN.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
var Brush: TBrush;
begin
  Brush := TBrush.Create;
  Brush.Color := Color;
  FillRect( Msg.DC, ClientRect, Brush.Handle);
  Brush.Free;
  with Imagemain.Picture.Bitmap do
    BitBlt( Msg.DC, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := 1;
end;

// This routine takes care of letting the user move the form
// around on the desktop.
procedure TformWaiveSN.WMNCHitTest( var msg: TWMNCHitTest );
var
  i: integer;
  p: TPoint;
  AControl: TControl;
  MouseOnControl: boolean;
begin
  inherited;
  if msg.result = HTCLIENT then begin
    p.x := msg.XPos;
    p.y := msg.YPos;
    p := ScreenToClient( p);
    MouseOnControl := false;
    for i := 0 to ControlCount-1 do begin
      if not MouseOnControl
      then begin
        AControl := Controls[i];
        if ((AControl is TWinControl) or (AControl is TGraphicControl))
          and (AControl.Visible)
        then MouseOnControl := PtInRect( AControl.BoundsRect, p);
      end
      else
        break;
    end;
    if (not MouseOnControl) then msg.Result := HTCAPTION;
  end;
end;
procedure TformWaiveSN.sbtnExitClick(Sender: TObject);
begin
  close;
end;

procedure TformWaiveSN.sbtnSaveClick(Sender: TObject);
begin
  modalResult :=mrOK;
end;

procedure TformWaiveSN.SetTheRegion;
var HR: HRGN;
begin
   HR := BmpToRegion(Self, Imagemain.Picture.Bitmap);
   SetWindowRgn(handle, HR, true);
   Invalidate;
end;
procedure TformWaiveSN.FormCreate(Sender: TObject);
begin
   SetTheRegion;
end;

end.
