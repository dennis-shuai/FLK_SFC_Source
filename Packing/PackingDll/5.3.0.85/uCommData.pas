unit uCommData;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB, ImgList, ComCtrls, Grids,
   DBGrids;

type
   TfCommData = class(TForm)
      sbtnCancel: TSpeedButton;
      sbtnSave: TSpeedButton;
      Image5: TImage;
      Image1: TImage;
      LabType1: TLabel;
      LabType2: TLabel;
      Imagemain: TImage;
      lablMsg: TLabel;
      DBGrid1: TDBGrid;
      DataSource1: TDataSource;
      Label1: TLabel;
    edtComm: TEdit;
      procedure sbtnCancelClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure sbtnSaveClick(Sender: TObject);
      procedure DBGrid1DblClick(Sender: TObject);
      procedure edtCommChange(Sender: TObject);
      procedure FormShow(Sender: TObject);
   private
    { Private declarations }
      procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
      procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
   public
    { Public declarations }
      procedure SetTheRegion;
   end;

var
   fCommData: TfCommData;

implementation

uses uNoInputReport;

{$R *.DFM}

procedure TfCommData.sbtnCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TfCommData.FormCreate(Sender: TObject);
begin
   SetTheRegion;
end;

procedure TfCommData.SetTheRegion;
var HR: HRGN;
begin
   HR := BmpToRegion(Self, Imagemain.Picture.Bitmap);
   SetWindowRgn(handle, HR, true);
   Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.

procedure TfCommData.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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

procedure TfCommData.WMNCHitTest(var msg: TWMNCHitTest);
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

procedure TfCommData.sbtnSaveClick(Sender: TObject);
begin
   ModalResult := mrOK;
end;

procedure TfCommData.DBGrid1DblClick(Sender: TObject);
begin
  sbtnSaveClick(Self);
end;

procedure TfCommData.edtCommChange(Sender: TObject);
begin
  if not fNoInputReport.qryTemp.Active then
     Exit;
  if not fNoInputReport.QryTemp.IsEmpty then
      fNoInputReport.qryTemp.Locate(fNoInputReport.qryTemp.Fields.Fields[0].FieldName, Trim(edtComm.Text), [loCaseInsensitive, loPartialKey])
end;

procedure TfCommData.FormShow(Sender: TObject);
begin
   edtComm.SetFocus;
end;

end.

