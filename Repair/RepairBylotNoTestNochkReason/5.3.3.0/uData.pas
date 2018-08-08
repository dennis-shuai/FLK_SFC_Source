unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB;

type
  TfData = class(TForm)
    sbtnCancel: TSpeedButton;
    Image1: TImage;
    LabType2: TLabel;
    LabType1: TLabel;
    lblReason: TLabel;
    lblTime: TLabel;
    lblDuty: TLabel;
    pnl1: TPanel;
    ImageMain: TImage;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd);
  private
    { Private declarations }

  public
    { Public declarations }
    procedure SetTheRegion;

  end;

var
  fData: TfData;

implementation



{$R *.DFM}




procedure TfData.sbtnCancelClick(Sender: TObject);
begin
     ModalResult := mrOK
end;

procedure TfData.FormCreate(Sender: TObject);
begin
  SetTheRegion;
end;

procedure TfData.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.
procedure TfData.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
var Brush: TBrush;
begin
  {Brush := TBrush.Create;
  Brush.Color := Color;
  FillRect( Msg.DC, ClientRect, Brush.Handle);
  Brush.Free;
  with Imagemain.Picture.Bitmap do
    BitBlt( Msg.DC, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := 1; }
end;



end.
