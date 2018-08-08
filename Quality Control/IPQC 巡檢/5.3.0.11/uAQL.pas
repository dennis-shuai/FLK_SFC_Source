unit uAQL;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, ExtCtrls, DB, DBClient, BmpRgn, Buttons, jpeg, Grids,
  DBGrids;

type
   TfAQL = class(TForm)
    dsrcSamplingPlan: TDataSource;
    Imagemain: TImage;
    Image5: TImage;
    Image2: TImage;
    Label1: TLabel;
    cmbAQL: TComboBox;
    Label6: TLabel;
    LabType2: TLabel;
    Label2: TLabel;
    DBGrid2: TDBGrid;
    sbtnSave: TSpeedButton;
    sbtnCancel: TSpeedButton;
    lablLotNO: TLabel;
    Label3: TLabel;
    lablWorkOrder: TLabel;
   private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;

   public
    { Public declarations }



   end;

var
   fAQL: TfAQL;


implementation

uses uformMain;

{$R *.dfm}

{ TfAQL }


procedure TfAQL.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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
procedure TfAQL.WMNCHitTest( var msg: TWMNCHitTest );
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

