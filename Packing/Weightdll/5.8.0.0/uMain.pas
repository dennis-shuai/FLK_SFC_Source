unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, StdCtrls, Db, DBClient, MConnect, SConnect,BmpRgn,
  ObjBrkr, Variants, Grids, DBGrids;

type
  TfMain = class(TForm)
    Imagemain: TImage;
    sbtnOK: TBitBtn;
    sbtnCancel: TBitBtn;
    Label7: TLabel;
    Editweight: TEdit;
    Label8: TLabel;
    procedure sbtnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnCancelClick(Sender: TObject);
    procedure EditweightKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
    { Private declarations }
  public
    procedure SetTheRegion;
    { Public declarations }
  end;

var
  fMain: TfMain;
  G_sockConnection : TSocketConnection;
  function CheckWeightData:Real; stdcall; export;
implementation

{$R *.DFM}

procedure TfMain.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.
procedure TfMain.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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
procedure TfMain.WMNCHitTest( var msg: TWMNCHitTest );
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

function CheckWeightData:Real;  stdcall;
var i:integer;
begin
  Result :=0;
  fMain := TfMain.Create(Application);
  with fMain do
  begin
    if ShowModal = mrOK then
    begin
      Result :=strtofloat(editweight.Text);
    end;
    Free;
  end;
end;

procedure TfMain.sbtnOKClick(Sender: TObject);
begin
        if (trim(editweight.Text)='') or (trim(editweight.Text)='0') then exit;
        try
          editweight.Text:=floattostr(strtofloat(editweight.Text));
        except
          editweight.SelectAll ;
          editweight.SetFocus ;
          showmessage('Weight value input Error!') ;
          exit;
        end;
        ModalResult:= mrOK;
end;

procedure TfMain.FormShow(Sender: TObject);
var i,j:integer;
begin
  editweight.SelectAll ;
  editweight.SetFocus ;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
   if FileExists(ExtractFilePath(Application.ExeName) + 'bDetail.bmp') then
   begin
     Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'bDetail.bmp');
     SetTheRegion;
   end;
end;

procedure TfMain.sbtnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfMain.EditweightKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if ORD(Key)=VK_RETURN then
     begin
        {if trim(editweight.Text)='' then exit;
        try
          editweight.Text:=floattostr(strtofloat(editweight.Text));
        except
          editweight.SelectAll ;
          editweight.SetFocus ;
          showmessage('Weight value input Error!') ;
          exit;
        end;
        ModalResult:= mrOK;
        }
         sbtnOKClick(SELF);
     end;
end;

end.
