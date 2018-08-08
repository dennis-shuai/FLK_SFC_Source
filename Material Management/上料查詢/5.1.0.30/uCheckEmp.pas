unit uCheckEmp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons,DateUtils,DB,BmpRgn;

type
  TfCheckEmp = class(TForm)
    Image1: TImage;
    Label7: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    editUserNO: TEdit;
    editPwd: TEdit;
    Image2: TImage;
    sbtnReset: TSpeedButton;
    Image3: TImage;
    SpeedButton1: TSpeedButton;
    procedure sbtnResetClick(Sender: TObject);
    procedure editPwdKeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure editUserNOKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    function CheckPrivilege(UpdateUserID,sProgramName,sFun:String):Boolean;
    function checkEmpNo(sEmpNo,sPassword:String;var sEmpID:String):Boolean;
    procedure SetTheRegion;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
  public
    { Public declarations }
  end;

var
  fCheckEmp: TfCheckEmp;

implementation

uses uSMTQuery;

{$R *.dfm}
procedure TfCheckEmp.sbtnResetClick(Sender: TObject);
var sEmpId:String;
begin
  editUserNO.Text := trim(editUserNO.text);
  editPwd.Text := trim(editPwd.Text);

  if  editUserNO.Text='' then
  begin
    MessageDlg('Please Input Employee No!',mtWarning,[mbOK],0);
    editUserNO.SetFocus;
    exit;
  end;
  if  editPwd.Text='' then
  begin
    MessageDlg('Please Input Password!',mtWarning,[mbOK],0);
    editPwd.SetFocus;
    exit;
  end;
  if not checkEmpNo(editUserNO.Text,editPwd.Text,sEmpId) then
  begin
    exit;
  end;
  if not CheckPrivilege(sEmpId,'Material Management','Reset') then
  begin
    Messagedlg('Employee : '+ editUserNO.Text+#10#13+#10#13+'No "Reset" Privilege !',mtWarning,[mbOK],0);
    editUserNO.Setfocus;
    editUserNO.SelectAll;
    exit;
  end;
  modalResult :=mrok;

end;
function TfCheckEmp.checkEmpNo(sEmpNo,sPassword:String;var sEmpID:String):Boolean;
begin
  result := false;
  with fMaterial.qryTemp do
  begin
    try
      close;
      Params.Clear;
      Params.CreateParam(ftString,'EMP_NO',ptInput);
      commandText :=' select EMP_NO,EMP_ID,TRIM(SAJET.PASSWORD.DECRYPT(PASSWD)) PASSWORD '
                    +'  FROM SAJET.SYS_EMP '
                    +' WHERE EMP_NO =:EMP_NO '
                    +'  AND ROWNUM = 1';
      Params.ParamByName('EMP_NO').AsString:= sEmpNo;
      open;
      if eof then
      begin
        MessageDlg('Employee : '+sEmpNo+ '  Error !',mtWarning,[mbOK],0);
        editUserNO.SetFocus;
        editUserNO.Selectall;
        exit;
      end;
      if FieldByName('PASSWORD').AsString <>sPassword then
      begin
        MessageDlg('Employee : '+sEmpNo+ #10#13+'Password Error !',mtWarning,[mbOK],0);
        editPwd.Setfocus;
        editPwd.SelectAll;
        exit;
      end;
      sEmpID := FieldByName('EMP_ID').AsString;
      result:=true;
    finally
      close;
    end;
  end;
end;
function TfCheckEmp.CheckPrivilege(UpdateUserID,sProgramName,sFun:String):Boolean;
begin
  result := False;
  try
    With fMaterial.QryTemp do
    begin

      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'EMP_ID', ptInput);
      Params.CreateParam(ftString	,'PRG', ptInput);
      Params.CreateParam(ftString	,'FUN', ptInput);
      CommandText := 'Select AUTHORITYS '+
                     'From SAJET.SYS_EMP_PRIVILEGE '+
                     'Where EMP_ID = :EMP_ID and '+
                           'PROGRAM = :PRG and '+
                           'FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := sProgramName;
      Params.ParamByName('FUN').AsString := sFun;
      Open;
      If RecordCount > 0 Then
      begin
        result := true;
        exit;
      end;
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'EMP_ID', ptInput);
      Params.CreateParam(ftString	,'PRG', ptInput);
      Params.CreateParam(ftString	,'FUN', ptInput);
      CommandText := 'Select AUTHORITYS '+
                     'From SAJET.SYS_ROLE_PRIVILEGE A, '+
                          'SAJET.SYS_ROLE_EMP B '+
                     'Where A.ROLE_ID = B.ROLE_ID and '+
                           'EMP_ID = :EMP_ID and '+
                           'PROGRAM = :PRG and '+
                           'FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := sProgramName;
      Params.ParamByName('FUN').AsString := sFun;
      Open;
      If RecordCount > 0 Then
      begin
        if fieldbyname('AUTHORITYS').AsString='Allow To Execute' then 
          result := true;
        exit;
      end;
    end;
  finally
    fMaterial.qryTemp.Close;
  end;
end;


procedure TfCheckEmp.editPwdKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then
    sbtnResetClick(self);
end;

procedure TfCheckEmp.SpeedButton1Click(Sender: TObject);
begin
  close;
end;

procedure TfCheckEmp.SetTheRegion;
var
  HR: HRGN;
begin
  HR := BmpToRegion(Self, Image1.Picture.Bitmap);
  SetWindowRgn(handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.

procedure TfCheckEmp.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
var
  Brush: TBrush;
begin
  Brush := TBrush.Create;
  Brush.Color := Color;
  FillRect(Msg.DC, ClientRect, Brush.Handle);
  Brush.Free;
  with Image1.Picture.Bitmap do
    BitBlt(Msg.DC, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := 1;
end;

// This routine takes care of letting the user move the form
// around on the desktop.

procedure TfCheckEmp.WMNCHitTest(var msg: TWMNCHitTest);
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

procedure TfCheckEmp.FormShow(Sender: TObject);
begin
  SetTheRegion;
end;

procedure TfCheckEmp.editUserNOKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then begin
    editPwd.SelectAll;
    editPwd.SetFocus;
  end;
end;

end.
