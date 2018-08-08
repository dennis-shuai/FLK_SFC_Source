unit uRole;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB, DBClient, ImgList,
  ComCtrls, Grids, Menus;

type
  TfRole = class(TForm)
    sbtnCancel: TSpeedButton;
    sbtnSave: TSpeedButton;
    Label3: TLabel;
    Image5: TImage;
    Label4: TLabel;
    Image1: TImage;
    LabEMp: TLabel;
    LabType1: TLabel;
    LabType2: TLabel;
    LvList: TListView;
    Iimglist1: TImageList;
    LvRole: TListView;
    Imagemain: TImage;
    Label13: TLabel;
    Label1: TLabel;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    sGridAuth: TStringGrid;
    PopupMenu1: TPopupMenu;
    Delete1: TMenuItem;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure LvRoleDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure LvRoleDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Delete1Click(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    UpdateUserID : String;
    EmpID : String;
    procedure SetTheRegion;
    Procedure ShowAllRole;
    Procedure ShowEmpRole;
  end;

var
  fRole: TfRole;

implementation

{$R *.DFM}
uses uEmp;

procedure TfRole.sbtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfRole.FormCreate(Sender: TObject);
begin
  SetTheRegion;
end;

procedure TfRole.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.
procedure TfRole.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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
procedure TfRole.WMNCHitTest( var msg: TWMNCHitTest );
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

Procedure TfRole.ShowAllRole;
begin
  sGridAuth.RowCount := 2;
  LvList.Items.Clear;
  With QryTemp do
  begin
    Close;
    CommandText := 'Select ROLE_ID,ROLE_NAME,ROLE_DESC '+
                   'From SAJET.SYS_ROLE '+
                   'Where ENABLED = ''Y'' '+
                   'Order By ROLE_NAME ';
    Open;
    While not Eof do
    begin
      With LvList.Items.Add do
      begin
        Caption := Fieldbyname('ROLE_NAME').AsString;
        SubItems.Add(Fieldbyname('ROLE_DESC').AsString);
      end;
      sGridAuth.RowCount := sGridAuth.RowCount + 1;
      sGridAuth.Cells[0,sGridAuth.RowCount-2] := Fieldbyname('ROLE_ID').AsString;
      sGridAuth.Cells[1,sGridAuth.RowCount-2] := Fieldbyname('ROLE_NAME').AsString;
      Next;
    end;
    Close;
  end;
end;

Procedure TfRole.ShowEmpRole;
begin
  LvRole.Items.Clear;
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'EMPID', ptInput);
    CommandText := 'Select ROLE_NAME,ROLE_DESC '+
                   'From SAJET.SYS_ROLE_EMP A,'+
                        'SAJET.SYS_ROLE B,'+
                        'SAJET.SYS_EMP C '+
                   'Where A.ROLE_ID = B.ROLE_ID and '+
                         'A.EMP_ID = C.EMP_ID and '+
                         'C.EMP_ID = :EMPID '+
                   'Order By ROLE_NAME ';
    Params.ParamByName('EMPID').AsString := UpperCase(Trim(EmpId));
    Open;
    While not Eof do
    begin
      With LvRole.Items.Add do
      begin
        Caption := Fieldbyname('ROLE_NAME').AsString;
        SubItems.Add(Fieldbyname('ROLE_DESC').AsString);
      end;
      Next;
    end;
    Close;
  end;
end;

procedure TfRole.sbtnSaveClick(Sender: TObject);
Var I : Integer; S : String;
  Function GetRoleID(mRoleName : String) : String;
  Var mI : Integer;
  begin
    Result := '';
    For mI := 0 to sGridAuth.RowCount - 1 do
      If (sGridAuth.Cells[1,mI] = mRoleName) Then
      begin
        Result := sGridAuth.Cells[0,mI];
        Break;
      end;
  end;
begin
  //  刪除原有的
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'EMPID', ptInput);
    CommandText := 'Delete SAJET.SYS_ROLE_EMP '+
                   'Where EMP_ID = :EMPID ';
    Params.ParamByName('EMPID').AsString := EmpId;
    Execute;

    // Append
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'ROLEID', ptInput);
    Params.CreateParam(ftString	,'EMPID', ptInput);
    Params.CreateParam(ftString	,'UPDATEID', ptInput);
    CommandText := 'Insert Into SAJET.SYS_ROLE_EMP '+
                   '(ROLE_ID,EMP_ID,UPDATE_USERID ) '+
                   'Values (:ROLEID,:EMPID,:UPDATEID) ';
    For I := 0 to LvRole.Items.Count - 1 do
    begin
      S := GetRoleID(LvRole.Items[I].Caption);
      Params.ParamByName('ROLEID').AsString := S;
      Params.ParamByName('EMPID').AsString := EmpId;
      Params.ParamByName('UPDATEID').AsString := UpdateUserID;
      Execute;
    end;
  end;
  Close;
end;

procedure TfRole.LvRoleDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if (Source is TListView) then
  begin
    if (Source as TListView).Name <> 'LvList' then
      Exit;
    if (Source as TListView).Selected <> nil then
      Accept := True;
  end;
end;

procedure TfRole.LvRoleDragDrop(Sender, Source: TObject; X, Y: Integer);
var I : Integer; mNode : TTreeNode; mB: Boolean;
begin
  if (Source is TListView) then
  begin
    if (Source as TListView).Name <> 'LvList' then Exit;
      mB := False;

    for I := 0 to LvRole.Items.Count - 1 do
      if LvRole.Items[I].Caption = LvList.Selected.Caption then
      begin
        mB := True;
        Break;
      end;

    if not mB then
    begin
      With LvRole.Items.Add do
      begin
        Caption := LvList.Selected.Caption;
        SubItems.Add(LvList.Selected.SubItems[0]);
      end;
    end;
    Exit;
  end;
end;

procedure TfRole.Delete1Click(Sender: TObject);
begin
  If LvRole.Selected = nil Then Exit;
  LvRole.Selected.Delete ;
end;

end.
