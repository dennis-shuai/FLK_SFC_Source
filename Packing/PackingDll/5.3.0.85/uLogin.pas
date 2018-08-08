unit uLogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ExtCtrls, BmpRgn, DB;

type
  TfLogin = class(TForm)
    Imagemain: TImage;
    Bevel1: TBevel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label4: TLabel;
    editUserNO: TEdit;
    editPwd: TEdit;
    Image4: TImage;
    sbtnLogIn: TSpeedButton;
    Image2: TImage;
    SpeedButton1: TSpeedButton;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure sbtnLogInClick(Sender: TObject);
    procedure editUserNOKeyPress(Sender: TObject; var Key: Char);
    procedure editPwdKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
  public
    { Public declarations }
    gbAuth: Boolean;
    procedure SetTheRegion;
    function SetStatusbyAuthority: Boolean;
  end;

var
  fLogin: TfLogin;

implementation

uses uPacking;

{$R *.dfm}

procedure TfLogin.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion(Self, Imagemain.Picture.Bitmap);
  SetWindowRgn(handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.

procedure TfLogin.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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

procedure TfLogin.WMNCHitTest(var msg: TWMNCHitTest);
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

procedure TfLogin.FormCreate(Sender: TObject);
begin
  Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'sLogin.bmp');
  SetTheRegion;
end;

procedure TfLogin.SpeedButton1Click(Sender: TObject);
begin
  Close;
end;

function TfLogin.SetStatusbyAuthority: Boolean;
var sAuth, UserID: string;
begin
  Result := False;
  with fPacking.QryTemp do
  begin
    Close;
    Params.Clear;
    //Params.CreateParam(ftString, 'PWD', ptInput);
    Params.CreateParam(ftString, 'EMP_NO', ptInput);
    CommandText := 'Select EMP_ID,EMP_NAME,EMP_NO,trim(SAJET.password.decrypt(PASSWD)) PWD '
      + '      ,ENABLED,NVL(TO_CHAR(QUIT_DATE,''yyyy/mm/dd''),''N/A'') QUIT_DATE '
      + '      ,CHANGE_PW_TIME '
      + 'From SAJET.SYS_EMP '
      + 'Where Upper(EMP_NO) = :EMP_NO ';
    //Params.ParamByName('PWD').AsString := Trim(editPwd.Text) ;
    Params.ParamByName('EMP_NO').AsString := UpperCase(Trim(editUserNO.Text));
    Open;
    if not IsEmpty then
    begin
      // 檢查 PWD
      if Trim(editPwd.Text) <> Fieldbyname('PWD').AsString then
      begin
        Close;
        editPwd.Text := '';
        MessageDlg('Invalid Password!!', mtError, [mbCancel], 0);
        Exit;
      end;
      // 檢查是否已離職
      if (trim(Fieldbyname('QUIT_DATE').AsString) <> 'N/A') then
      begin
        Close;
        editPwd.Text := '';
        editUserNO.SetFocus;
        editUserNO.SelectAll;
        MessageDlg('This User have Terminate!!', mtError, [mbCancel], 0);
        Exit;
      end;
      // 檢查是否有效
      if (Copy(Fieldbyname('ENABLED').AsString, 1, 1) <> 'Y') then
      begin
        Close;
        editPwd.Text := '';
        editUserNO.SetFocus;
        editUserNO.SelectAll;
        MessageDlg('User invalid !!', mtError, [mbCancel], 0);
        Exit;
      end;
      UserID := Fieldbyname('EMP_ID').AsString;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      Params.CreateParam(ftString, 'FUN', ptInput);
      CommandText := 'Select AUTHORITYS '
        + 'From SAJET.SYS_EMP_PRIVILEGE '
        + 'Where EMP_ID = :EMP_ID '
        + 'and PROGRAM = :PRG '
        + 'and FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := UserID;
      Params.ParamByName('PRG').AsString := 'Packing';
      Params.ParamByName('FUN').AsString := 'Clear Lock';
      Open;
      while not Eof do
      begin
        sAuth := Fieldbyname('AUTHORITYS').AsString;
        Result := (sAuth = 'Allow To Execute') or (sAuth = 'Full Control');
        if Result then
          break;
        Next;
      end;
      Close;
      if not Result then
      begin
        with fPacking.QryTemp do
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'EMP_ID', ptInput);
          Params.CreateParam(ftString, 'PRG', ptInput);
          Params.CreateParam(ftString, 'FUN', ptInput);
          CommandText := 'Select AUTHORITYS '
            + 'From SAJET.SYS_ROLE_PRIVILEGE A, '
            + 'SAJET.SYS_ROLE_EMP B '
            + 'Where A.ROLE_ID = B.ROLE_ID '
            + 'and b.EMP_ID = :EMP_ID '
            + 'and PROGRAM = :PRG '
            + 'and FUNCTION = :FUN ';
          Params.ParamByName('EMP_ID').AsString := UserID;
          Params.ParamByName('PRG').AsString := 'Packing';
          Params.ParamByName('FUN').AsString := 'Clear Lock';
          Open;
          while not Eof do
          begin
            sAuth := Fieldbyname('AUTHORITYS').AsString;
            Result := (sAuth = 'Allow To Execute') or (sAuth = 'Full Control');
            if Result then
              break;
            Next;
          end;
          Close;
        end;
      end;
      if not Result then
      begin
        MessageDlg('Privilege NG!!', mtError, [mbCancel], 0);
        editPwd.Text := '';
        editUserNO.SetFocus;
        editUserNO.SelectAll;
      end;
    end else
      MessageDlg('Login User Not Found !!', mtError, [mbCancel], 0);
  end;
end;

procedure TfLogin.sbtnLogInClick(Sender: TObject);
begin
  ModalResult := mrNone;
  if SetStatusbyAuthority then
    ModalResult := mrOK;
end;

procedure TfLogin.editUserNOKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
    editPwd.SetFocus;
end;

procedure TfLogin.editPwdKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
    sbtnLogInClick(Self);
end;

end.

