unit uProcess;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, DB, DBClient, BmpRgn;

type
  TfProcess = class(TForm)
    sbtnCancel: TSpeedButton;
    sbtnSave: TSpeedButton;
    imageSave: TImage;
    imageCancel: TImage;
    lablTitleA: TLabel;
    Imagemain: TImage;
    Label1: TLabel;
    lstProcess: TListBox;
    procedure sbtnCancelClick(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure lstProcessDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetTheRegion;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
  end;
var fProcess: TfProcess;

implementation

{$R *.DFM}

// This routine takes care of drawing the bitmap on the form.

procedure TfProcess.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion(Self, Imagemain.Picture.Bitmap);
  SetWindowRgn(handle, HR, true);
  Invalidate;
end;

procedure TfProcess.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
var Brush: TBrush;
begin
  Brush := TBrush.Create;
  Brush.Color := Color;
  FillRect(Msg.DC, ClientRect, Brush.Handle);
  Brush.Free;
  with Imagemain.Picture.Bitmap do
    BitBlt(Msg.DC, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := 1;
end;

// This routine takes care of letting the user move the form
// around on the desktop.

procedure TfProcess.WMNCHitTest(var msg: TWMNCHitTest);
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
end;

procedure TfProcess.sbtnCancelClick(Sender: TObject);
begin
  modalresult := mrcancel;
end;

procedure TfProcess.sbtnSaveClick(Sender: TObject);
begin
  if lstProcess.ItemIndex > -1 then
    modalresult := mrok
  else
    modalresult := mrNone;
end;

procedure TfProcess.lstProcessDblClick(Sender: TObject);
begin
  if lstProcess.ItemIndex > -1 then
    modalresult := mrok;
end;

procedure TfProcess.FormCreate(Sender: TObject);
begin
  if FileExists(ExtractFilePath(Application.ExeName) + 'sDetail.bmp') then
  begin
    Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'sDetail.bmp');
    SetTheRegion;
  end;
end;

end.
