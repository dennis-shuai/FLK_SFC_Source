unit uImage;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   jpeg, ExtCtrls, StdCtrls, Buttons, Db, DBClient, MConnect, SConnect,
   ObjBrkr, ComCtrls, Grids, ValEdit, Spin, IniFiles, ShellCtrls, BmpRgn;

type
   TformImage = class(TForm)
    Imagemain: TImage;
    Label9: TLabel;
    Label3: TLabel;
    sbtnBG: TSpeedButton;
    Panel2: TPanel;
    ShellTreeView1: TShellTreeView;
    Panel4: TPanel;
    ShellComboBox1: TShellComboBox;
    Panel3: TPanel;
    Image1: TImage;
    ShellListView2: TShellListView;
    Image5: TImage;
    sbtnClose: TSpeedButton;
    Image3: TImage;
    procedure ShellListView2Click(Sender: TObject);
    procedure sbtnBGClick(Sender: TObject);
    procedure sbtnCloseClick(Sender: TObject);
   private
    { Private declarations }
      gsImage: String;
      procedure SetTheRegion;
      procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
      procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
   public
    { Public declarations }
   end;

var
   formImage: TformImage;

implementation

{$R *.DFM}

procedure TformImage.SetTheRegion;
var HR: HRGN;
begin
   HR := BmpToRegion(Self, Imagemain.Picture.Bitmap);
   SetWindowRgn(handle, HR, true);
   Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.

procedure TformImage.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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

procedure TformImage.WMNCHitTest(var msg: TWMNCHitTest);
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
      p := ScreenToClient(p);
      MouseOnControl := false;
      for i := 0 to ControlCount - 1 do begin
         if not MouseOnControl
            then begin
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

procedure TformImage.ShellListView2Click(Sender: TObject);
var sFileName: string;
begin
  sFileName := ShellListView2.SelectedFolder.PathName;
  gsImage := '';
  if (UpperCase(Copy(sFileName, Length(sFileName) - 2, 3)) = 'JPG')
    or (UpperCase(Copy(sFileName, Length(sFileName) - 2, 3)) = 'BMP')
  then
  begin
    gsImage := sFileName;
    Image1.Picture.LoadFromFile(gsImage);
  end;
end;

procedure TformImage.sbtnBGClick(Sender: TObject);
var Pini: TIniFile;
begin
  if gsImage <> '' then
  begin
    PIni := TIniFile.Create('Sajet.ini');
    PIni.WriteString('DataCenter','Background',gsImage);
    Pini.Free;
  end;
end;

procedure TformImage.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

end.

