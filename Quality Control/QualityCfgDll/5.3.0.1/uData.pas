unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, uSetStation, uOption, Db,
  DBClient, MConnect, SConnect, IniFiles, ObjBrkr;

type
  TfData = class(TForm)
    sbtnClose: TSpeedButton;
    Image1: TImage;
    Label5: TLabel;
    Label9: TLabel;
    Imagemain: TImage;
    Image2: TImage;
    sbtnStation: TSpeedButton;
    Image3: TImage;
    sbtnOption: TSpeedButton;
    Bevel1: TBevel;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnStationClick(Sender: TObject);
    procedure sbtnOptionClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    UpdateUserID : String;
    TerminalID : String;
    UpdateSetdata : Boolean;
    FcID : String;
    //Authoritys,AuthorityRole : String;
    G_iPrivilege : Integer;
    procedure SetTheRegion;
    procedure FreeFrom;
    procedure GetSetStation;
    Procedure SetStatusbyAuthority;
  end;

var
  fData: TfData;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

Procedure TfData.SetStatusbyAuthority;
begin
  G_iPrivilege:=0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Quality Control';
      Params.ParamByName('FUN').AsString :='Configuration';
      Execute;
      IF Params.ParamByName('TRES').AsString ='OK' Then
      begin
        G_iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;
end;

procedure TfData.FreeFrom;
Var mI : Integer;
begin
   For mI :=  0 to fData.ComponentCount - 1  do
   begin
      IF (fData.Components[mI] is TForm) Then
      begin
         (fData.Components[mI] as TForm).Free;
         Break;
      end;
   end;
end;

procedure TfData.GetSetStation;
begin
  With TIniFile.Create('SAJET.ini') do
  begin
     FcID := ReadString('System','Factory','');
     TerminalID := ReadString('Quality Control','Terminal','');
     Free;
  end;
end;

procedure TfData.sbtnCloseClick(Sender: TObject);
begin
   Close;
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
procedure TfData.WMNCHitTest( var msg: TWMNCHitTest );
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

procedure TfData.sbtnStationClick(Sender: TObject);
Var Bmp : TBitmap; DestRect,SurcRect : TRect;
begin
  FreeFrom;

  Bmp := TBitmap.Create ;
  Bmp.Assign(Imagemain.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  Imagemain.Picture.Graphic := Bmp;

  fStation := TfStation.Create(Self);
  fStation.Parent := Self;
  fStation.BorderStyle := bsNone;
  fStation.Image1.Picture := Imagemain.Picture;


  With SurcRect do
  begin
     Left := Bevel1.Left+2;
     Top := Bevel1.Top+2;
     Right := Bevel1.Left+2 + Bevel1.Width;
     Bottom := Bevel1.Top+2 + Bevel1.Height;
  end;

  With DestRect do
  begin
     Left := 0;
     Top := 0;
     Right :=  Bevel1.Width;
     Bottom := Bevel1.Height;
  end;
  fStation.Image1.Canvas.CopyRect(DestRect,Imagemain.Canvas,SurcRect  );
  fStation.Left := Bevel1.Left+2;
  fStation.Top := Bevel1.Top+2;
  fStation.Show;
  fStation.sbtnSave.Enabled := (G_iPrivilege>=1);
end;

procedure TfData.sbtnOptionClick(Sender: TObject);
Var Bmp : TBitmap; DestRect,SurcRect : TRect;
begin
  FreeFrom;
  Bmp := TBitmap.Create ;
  Bmp.Assign(Imagemain.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  Imagemain.Picture.Graphic := Bmp;

  fOption := TfOption.Create(Self);
  fOption.Parent := Self;
  fOption.BorderStyle := bsNone;
  fOption.Image1.Picture := Imagemain.Picture;

  With SurcRect do
  begin
     Left := Bevel1.Left+2;
     Top := Bevel1.Top+2;
     Right := Bevel1.Left + Bevel1.Width+2;
     Bottom := Bevel1.Top + Bevel1.Height+2;
  end;

  With DestRect do
  begin
     Left := 0;
     Top := 0;
     Right :=  Bevel1.Width;
     Bottom := Bevel1.Height;
  end;
  fOption.Image1.Canvas.CopyRect(DestRect,Imagemain.Canvas,SurcRect  );
  fOption.Left := Bevel1.Left+2;
  fOption.Top := Bevel1.Top+2;
  fOption.Show;
  fOption.sbtnSave.Enabled := ((G_iPrivilege>=1));
end;

procedure TfData.FormShow(Sender: TObject);
begin
  GetSetStation;
  IF UpdateUserID <> '0' Then
    SetStatusbyAuthority;
  sbtnStationClick(self);    
end;

end.
