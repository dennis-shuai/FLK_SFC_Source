unit uformLotMemo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,BmpRgn, Buttons, ExtCtrls, StdCtrls,Db;

type
  TformLotMemo = class(TForm)
    Imagemain: TImage;
    Image5: TImage;
    Image1: TImage;
    Label2: TLabel;
    LabType2: TLabel;
    Label5: TLabel;
    sbtnSave: TSpeedButton;
    sbtnCancel: TSpeedButton;
    Bevel1: TBevel;
    Label4: TLabel;
    LabRTNO: TLabel;
    Label1: TLabel;
    LabPartNO: TLabel;
    Label6: TLabel;
    LabAcceptQty: TLabel;
    Label8: TLabel;
    LabScheduleQty: TLabel;
    editLotMemo: TMemo;
    Label3: TLabel;
    LabWHCode: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    procedure SetTheRegion;
  end;

var
  formLotMemo: TformLotMemo;

implementation

{$R *.dfm}

procedure TformLotMemo.FormCreate(Sender: TObject);
begin
  SetTheRegion;
end;

procedure TformLotMemo.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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
procedure TformLotMemo.WMNCHitTest( var msg: TWMNCHitTest );
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
procedure TformLotMemo.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;
procedure TformLotMemo.sbtnSaveClick(Sender: TObject);
begin

    editLotMemo.Text := Trim(editLotMemo.Text);
   {IF editLotMemo.Text='' THEN
    BEGIN
      MessageDlg('Please Input LotMemo!', mtError, [mbCancel], 0);
      editLotMemo.SetFocus;
      EXIT;
    END;
    }
    modalResult := mrOK;
end;

procedure TformLotMemo.sbtnCancelClick(Sender: TObject);
begin
  Close;
end;


procedure TformLotMemo.FormShow(Sender: TObject);
begin
  editLotMemo.SelectAll;
  editLotMemo.SetFocus;
end;

end.
