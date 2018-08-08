unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB;

type
  TfData = class(TForm)
    sbtnCancel: TSpeedButton;
    sbtnSave: TSpeedButton;
    Image5: TImage;
    Image1: TImage;
    LabType1: TLabel;
    LabType2: TLabel;
    Imagemain: TImage;
    edtSaftyNo: TEdit;
    Label2: TLabel;
    cmbDept: TComboBox;
    Label5: TLabel;
    Label1: TLabel;
    cmbToolingNo: TComboBox;
    lbltoolingid: TLabel;
    Image2: TImage;
    lblDeptid: TLabel;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure cmbDeptSelect(Sender: TObject);
    procedure cmbToolingNoSelect(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    MaintainType : String;
    UpdateSuccess : Boolean;
    stoolingId,sdeptid:string;
    procedure SetTheRegion;
  end;

var
  fData: TfData;

implementation

{$R *.DFM}
uses uDPPM;

procedure TfData.sbtnCancelClick(Sender: TObject);
begin
  If UpdateSuccess Then
    ModalResult := mrOK
  Else
    Close;
end;

procedure TfData.FormCreate(Sender: TObject);
begin
 if FileExists(ExtractFilePath(Application.ExeName) + 'sDetail.bmp') then
 begin
   Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'sDetail.bmp');
   SetTheRegion;
 end;
  with fDetail.QryTemp do
  begin
    close;
    Params.Clear;
    Params.CreateParam(ftString,'user_id',ptInput);
    CommandText := 'SELECT B.DEPT_NAME '+
                   'FROM SAJET.SYS_EMP_DEPT a,SAJET.SYS_DEPT B '+
                   'WHERE a.Enabled = ''Y'' AND A.DEPT_ID=B.DEPT_ID '+
                   ' and a.emp_id =:user_id Order by B.DEPT_NAME  ';
    Params.ParamByName('user_id').AsString :=fDetail.UpdateUserID;
    Open;
    cmbDept.Clear;
    while not Eof do
    begin
      cmbDept.Items.Add(FieldByName('DEPT_NAME').AsString);
      Next;
    end;
  end;

  with fDetail.QryTemp do
  begin
    close;
    Params.Clear;
    CommandText := 'Select a.TOOLING_NO '+
                   'From SAJET.SYS_TOOLING a '+
                   'Where a.Enabled = ''Y'' '+
                   'Order by a.TOOLING_NO ';
    Open;
    cmbToolingNo.Clear;
    while not Eof do
    begin
      cmbToolingNo.Items.Add(FieldByName('TOOLING_NO').AsString);
      Next;
    end;
  end;
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

procedure TfData.sbtnSaveClick(Sender: TObject);
Var S : String; I : Integer;
begin
  If cmbDept.ItemIndex = -1 Then
  begin
     MessageDlg('dept Name Error !!',mtError, [mbCancel],0);
     cmbDept.SetFocus ;
     Exit;
  end;

  If cmbToolingNo.ItemIndex = -1 Then
  begin
     MessageDlg('tooling no Error !!',mtError, [mbCancel],0);
     cmbToolingNo.SetFocus ;
     Exit;
  end;

   With fDetail.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'tooling_no', ptInput);
        CommandText := 'Select tooling_id '+
                       'From SAJET.SYS_tooling '+
                       'Where tooling_no = :tooling_no ';
        Params.ParamByName('tooling_no').AsString := cmbToolingNo.Text;
        Open;
        if isempty then
        begin
           MessageDlg('tooling_no  Error !!'+#13#10,mtError, [mbCancel],0);
           cmbToolingNo.Text :='' ;
           exit;
        end;
        stoolingId := FieldByName('tooling_id').AsString;

        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'dept_name', ptInput);
        CommandText := 'Select dept_id '+
                       'From SAJET.SYS_dept '+
                       'Where dept_name = :dept_name ';
        Params.ParamByName('dept_name').AsString := cmbDept.Text;
        Open;
        if isempty then
        begin
           MessageDlg('dept Data Error !!'+#13#10,mtError, [mbCancel],0);
           cmbDept.SelectAll ;
           cmbDept.SetFocus ;
           exit;
        end;
        sdeptid  := FieldByName('dept_id').AsString;

  end;

  If MaintainType = 'Append' Then
  begin

     with fDetail.QryTemp do
     begin

        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'dept_id', ptInput);
        Params.CreateParam(ftString	,'tooling_id', ptInput);
        CommandText := 'Select dept_id,tooling_id '+
                       'From sajet.sys_tooling_settings '+
                       'Where dept_id = :dept_id '+
                       'and tooling_id = :tooling_id ';
        Params.ParamByName('dept_id').AsString := sdeptid;
        Params.ParamByName('tooling_id').AsString := stoolingId;
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'dept : '+ cmbDept.Text + #13#10 +
                'tooling no : '+ cmbToolingNo.Text ;
           Close;
           MessageDlg(S,mtError, [mbCancel],0);
           Exit;
        end;
     end;

     Try
        With fDetail.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'dept_id', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'tooling_id', ptInput);
           Params.CreateParam(ftString	,'safty_qty', ptInput);
           CommandText := 'Insert Into SAJET.SYS_tooling_settings'+
                          ' (dept_id,tooling_id,safty_qty,UPDATE_USERID,update_time) '+
                          'Values (:dept_id,:tooling_id,:safty_qty,:UPDATE_USERID,sysdate) ';
           Params.ParamByName('dept_id').AsString := sdeptid;
           Params.ParamByName('UPDATE_USERID').AsString := fDetail.UpdateUserID;
           Params.ParamByName('tooling_id').AsString := stoolingId;
           Params.ParamByName('safty_qty').AsString := edtSaftyNo.Text;
           Execute;
           fDetail.CopyToHistory(sdeptid,stoolingId);
        end;
     Except
       on E:Exception do
       begin
         MessageDlg('Database Error !!'+#13#10 +
                    E.Message ,mtError, [mbCancel],0);
         Exit;
       end;
     end;

     MessageDlg('tooling_no Data Append OK!!',mtCustom, [mbOK],0);
     UpdateSuccess := True;
     If MessageDlg('Append Other Part_no Data ?',mtCustom, mbOKCancel,0) <> mrOK Then
        ModalResult := mrOK
     else
     begin
        cmbToolingNo.ItemIndex:=-1;
        edtSaftyNo.Text :='';
        edtSaftyNo.SetFocus ;
        Exit;
     end;
     Exit;
  end;

  If MaintainType = 'Modify' Then
  begin
     Try
        With fDetail.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'dept_id', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'tooling_id', ptInput);
           Params.CreateParam(ftString	,'safty_qty', ptInput);
           CommandText := 'Update SAJET.SYS_tooling_settings '+
                          'Set safty_qty =:safty_qty, '+
                          ' UPDATE_USERID = :UPDATE_USERID,'+
                          'UPDATE_TIME = SYSDATE '+
                          'Where dept_id = :dept_id '+
                          'and tooling_id = :tooling_id ';
           Params.ParamByName('dept_id').AsString := sdeptid;
           Params.ParamByName('UPDATE_USERID').AsString := fDetail.UpdateUserID;
           Params.ParamByName('tooling_ID').AsString := stoolingId;
           Params.ParamByName('safty_qty').AsString := edtSaftyNo.Text;
           Execute;
           fDetail.CopyToHistory(sdeptid,stoolingId);
           MessageDlg('tooling_no Data Update OK!!',mtCustom, [mbOK],0);
           ModalResult := mrOK;
        end;
     Except
       on E:Exception do
       begin
         MessageDlg('Database Error !!'+#13#10 +
                    E.Message ,mtError, [mbCancel],0);
         Exit;
       end;  
     end;
  End;
end;

procedure TfData.cmbDeptSelect(Sender: TObject);
begin
//
end;

procedure TfData.cmbToolingNoSelect(Sender: TObject);
begin
//
end;

end.
