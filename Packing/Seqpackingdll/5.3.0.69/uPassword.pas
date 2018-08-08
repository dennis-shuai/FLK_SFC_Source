unit uPassword;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, StdCtrls,BmpRgn;

type
  TfPassword = class(TForm)
    Imagemain: TImage;
    LabType1: TLabel;
    LabType2: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    editPW: TEdit;
    Bevel1: TBevel;
    sbtnSave: TSpeedButton;
    sbtnExit: TSpeedButton;
    Image1: TImage;
    Image5: TImage;
    editEmpNo: TEdit;
    procedure sbtnExitClick(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure editPWKeyPress(Sender: TObject; var Key: Char);
    procedure editEmpNoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
    procedure SetTheRegion;
  public
    m_sEmpName, m_sEmpID: String;
  end;

var
  fPassword: TfPassword;

implementation

uses uPacking;

{$R *.dfm}

procedure TfPassword.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.
procedure TfPassword.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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
procedure TfPassword.WMNCHitTest( var msg: TWMNCHitTest );
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

procedure TfPassword.sbtnExitClick(Sender: TObject);
begin
   Close;
end;

procedure TfPassword.sbtnSaveClick(Sender: TObject);
begin
   editEmpNo.Text := Trim(editEmpNo.Text);
   editPW.Text := Trim(editPW.Text);

   if (editEmpNo.Text <> '') and (editPW.Text <> '') then
   begin
      with fPacking.QryTemp do
      begin
         Close;
         Params.Clear;
         CommandText := 'Select Emp_ID, Emp_Name, trim(SAJET.password.decrypt(PASSWD)) PWD '
                      + '  From SAJET.SYS_EMP '
                      + ' Where Emp_No = ''' + editEmpNo.Text + ''' ';
         Open;
         if IsEmpty then
         begin
            MessageDlg('Employee Error !',mtError,[mbCancel],0);
            Close;
            editPW.SelectAll;
            editPW.SetFocus;
            Exit;
         end
         else if editPW.Text <> FieldByName('PWD').AsString then
         begin
            MessageDlg('Password Error !',mtError,[mbCancel],0);
            Close;
            editPW.SelectAll;
            editPW.SetFocus;
            Exit;
         end;
         m_sEmpID := FieldByName('Emp_ID').AsString;
         m_sEmpName := FieldByName('Emp_Name').AsString;
         Close;
      end;
      ModalResult := mrOK;
   end
   else
      MessageDlg('Please Input Emp No. or Password !',mtError,[mbCancel],0);
end;

procedure TfPassword.FormCreate(Sender: TObject);
begin
   if FileExists(ExtractFilePath(Application.ExeName) + 'sDetail.bmp') then
   begin
     Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'sDetail.bmp');
     SetTheRegion;
   end;
end;

procedure TfPassword.editPWKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then
      sbtnSave.Click;
end;

procedure TfPassword.editEmpNoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if (Key = 13) then
   begin
      editPW.SelectAll;
      editPW.SetFocus;
   end;
end;

end.
