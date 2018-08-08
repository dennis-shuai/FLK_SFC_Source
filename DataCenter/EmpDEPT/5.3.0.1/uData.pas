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
    Label2: TLabel;
    Label5: TLabel;
    cmbModel: TComboBox;
    EditempNO: TEdit;
    Label1: TLabel;
    Editempname: TEdit;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure EditempNOKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    MaintainType : String;
    UpdateSuccess : Boolean;
    DEPTID,EMPID : String;
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

  with fDPPM.QryTemp do
  begin
    close;
    Params.Clear;
    CommandText := 'Select a.Dept_NAME '+
                   'From SAJET.SYS_dept a '+
                   'Where a.Enabled = ''Y'' '+
                   'Order by a.dept_NAME ';
    Open;
    cmbmodel.Clear;
    while not Eof do
    begin
      cmbmodel.Items.Add(FieldByName('dept_NAME').AsString);
      Next;
    end;
  end;

  editempno.Clear ;
  editempname.Clear ;
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
  If cmbmodel.ItemIndex = -1 Then
  begin
     MessageDlg('dept Name Error !!',mtError, [mbCancel],0);
     cmbmodel.SetFocus ;
     Exit;
  end;

  if editempname.Text='' then
  begin
     MessageDlg('EMP NAME Error !!',mtError, [mbCancel],0);
     editempno.SetFocus ;
     Exit;
  end;

  If MaintainType = 'Append' Then
  begin
     // 檢查 Process 是否已有設定
     With fDPPM.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'EMP_NO', ptInput);
        CommandText := 'Select EMP_ID '+
                       'From SAJET.SYS_EMP '+
                       'Where EMP_NO = :EMP_NO ';
        Params.ParamByName('EMP_NO').AsString := editempNO.Text;
        Open;
        EMPID := FieldByName('EMP_ID').AsString;

        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'DEPT_NAME', ptInput);
        CommandText := 'Select DEPT_ID '+
                       'From SAJET.SYS_DEPT '+
                       'Where DEPT_NAME = :DEPT_NAME ';
        Params.ParamByName('DEPT_NAME').AsString := cmbmodel.Text;
        Open;
        DEPTID := FieldByName('DEPT_ID').AsString;

        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'EMP_ID', ptInput);
        Params.CreateParam(ftString	,'DEPT_ID', ptInput);
        CommandText := 'Select EMP_ID '+
                       'From SAJET.SYS_EMP_DEPT '+
                       'Where EMP_ID = :EMP_ID '+
                       'and DEPT_ID = :DEPT_ID ';
        Params.ParamByName('EMP_ID').AsString := EMPID;
        Params.ParamByName('DEPT_ID').AsString := DEPTID;
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'DEPT  : '+ cmbmodel.Text + #13#10 +
                'EMP : '+ editempNO.Text ;
           Close;
           MessageDlg(S,mtError, [mbCancel],0);
           Exit;
        end;
     end;

     Try
        With fDPPM.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'EMP_ID', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'DEPT_ID', ptInput);
           CommandText := 'Insert Into SAJET.SYS_EMP_DEPT '+
                          ' (EMP_ID,UPDATE_USERID,DEPT_ID) '+
                          'Values (:EMP_ID,:UPDATE_USERID,:DEPT_ID) ';
           Params.ParamByName('EMP_ID').AsString := EMPID;
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Params.ParamByName('DEPT_ID').AsString := DEPTID;
           Execute;
           fDPPM.CopyToHistory(DEPTID,EMPID);
        end;
     Except
       on E:Exception do
       begin
         MessageDlg('Database Error !!'+#13#10 +
                    E.Message ,mtError, [mbCancel],0);
         Exit;
       end;
     end;

     MessageDlg('EMP_DEPT Data Append OK!!',mtCustom, [mbOK],0);
     UpdateSuccess := True;
     If MessageDlg('Append Other EMP_DEPT Data ?',mtCustom, mbOKCancel,0) <> mrOK Then
        ModalResult := mrOK
     else
     begin
        editempname.Clear ;
        editempno.Clear ;
        editempno.SetFocus ;
        Exit;
     end;
     Exit;
  end;

  If MaintainType = 'Modify' Then
  begin
     Try
        With fDPPM.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'EMP_ID', ptInput);
           Params.CreateParam(ftString	,'DEPT_ID', ptInput);
           CommandText := 'Update SAJET.SYS_EMP_DEPT '+
                          'Set    '+
                              'UPDATE_USERID = :UPDATE_USERID,'+
                              'UPDATE_TIME = SYSDATE '+
                          'Where EMP_ID = :EMP_ID '+
                          'and DEPT_ID = :DEPT_ID ';
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Params.ParamByName('EMP_ID').AsString := EMPID;
           Params.ParamByName('DEPT_ID').AsString := DEPTID;
           Execute;
           fDPPM.CopyToHistory(DEPTID,EMPID);
           MessageDlg('EMP_DEPT Data Update OK!!',mtCustom, [mbOK],0);
           ModalResult := mrOK;
        end;

        editempname.Clear ;
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

procedure TfData.EditempNOKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if trim(editempno.Text)='' then exit;
   if key=13 then
   begin
     With fDPPM.QryTemp do
     begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'emp_no',ptinput);
       commandtext:='select * from sajet.sys_emp where emp_no=:emp_no and rownum=1';
       params.ParamByName('emp_no').AsString :=editempno.Text ;
       open;
       if isempty then
       begin
          MessageDlg('Not Find The EMP:'+editempno.Text,mtError, [mbCancel],0);
          editempno.SelectAll ;
          editempno.SetFocus ;
          exit;
       end;
       if fieldbyname('enabled').AsString='N' Then
       begin
          MessageDlg('The EMP:'+editempno.Text+' Is Disabled!',mtError, [mbCancel],0);
          editempno.SelectAll ;
          editempno.SetFocus ;
          exit;
       end;
       editempname.Text :=fieldbyname('emp_name').AsString ;
     end;
   end;
end;

end.
