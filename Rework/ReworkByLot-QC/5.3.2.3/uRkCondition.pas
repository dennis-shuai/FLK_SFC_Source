unit uRkCondition;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Buttons, GradPanel, BmpRgn;

type
  TfRkCondition = class(TForm)
    Label1: TLabel;
    LabelPacking: TLabel;
    sbtnSaveOK: TSpeedButton;
    Label22: TLabel;
    Image3: TImage;
    Imagemain: TImage;
    Label11: TLabel;
    combPO: TComboBox;
    listbMO: TListBox;
    Label3: TLabel;
    Label15: TLabel;
    DateTimePickerStart: TDateTimePicker;
    Label16: TLabel;
    DateTimePickerEnd: TDateTimePicker;
    Label2: TLabel;
    combLine: TComboBox;
    listbGroup: TListBox;
    Label7: TLabel;
    listbPallet: TListBox;
    Label9: TLabel;
    listbCarton: TListBox;
    Label10: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    procedure sbtnSaveOKClick(Sender: TObject);
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
  fRkCondition: TfRkCondition;

implementation

{$R *.DFM}

procedure TfRkCondition.sbtnSaveOKClick(Sender: TObject);
begin
   Close;
end;

procedure TfRkCondition.FormCreate(Sender: TObject);
begin
  SetTheRegion;
end;

procedure TfRkCondition.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.
procedure TfRkCondition.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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
procedure TfRkCondition.WMNCHitTest( var msg: TWMNCHitTest );
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

end.
