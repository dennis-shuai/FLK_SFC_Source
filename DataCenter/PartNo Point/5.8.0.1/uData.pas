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
    editPartno: TEdit;
    Label2: TLabel;
    Label5: TLabel;
    Editpointqty: TEdit;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    MaintainType : String;
    UpdateSuccess : Boolean;
    partID,LocateID : String;
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
  if trim(editpointqty.Text)='' then
  begin
     editpointqty.SelectAll ;
     editpointqty.SetFocus ;
  end;

  try
    editpointqty.Text :=inttostr(strtoint(editpointqty.Text))
  except
    begin
        MessageDlg('Defect Point Count values input Error!!'+#13#10,mtError, [mbCancel],0);
         editpointqty.SelectAll ;
         editpointqty.SetFocus ;
        exit;
    end;
  end;


  if strtoint( editpointqty.Text)<0 then
  begin
    MessageDlg('Defect Point Count values input Error!!'+#13#10,mtError, [mbCancel],0);
    editpointqty.SelectAll ;
    editpointqty.SetFocus ;
    exit;
  end;



  If MaintainType = 'Append' Then
  begin
     // 檢查 Process 是否已有設定
     With fDPPM.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'part_no', ptInput);
        CommandText := 'Select part_ID '+
                       'From SAJET.SYS_part '+
                       'Where part_no = :part_no ';
        Params.ParamByName('part_no').AsString := editpartno.Text;
        Open;
        if isempty then
        begin
           MessageDlg('PART_NO Data Error !!'+#13#10,mtError, [mbCancel],0);
           editpartno.SelectAll ;
           editpartno.SetFocus ;
           exit;
        end;
        partID := FieldByName('part_ID').AsString;



        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'part_ID', ptInput);
        CommandText := 'Select * '+
                       'From SAJET.SYS_part_point '+
                       'Where part_ID = :part_ID ';
        Params.ParamByName('part_ID').AsString := partID;
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'part_no : '+ editpartno.Text+ #13#10 ;
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
           Params.CreateParam(ftString	,'part_ID', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'Defect_point_count', ptInput);
           CommandText := 'Insert Into SAJET.SYS_part_point '+
                          ' (part_ID,point_qty,UPDATE_USERID,update_time) '+
                          'Values (:part_ID,:point_qty,:UPDATE_USERID,sysdate) ';
           Params.ParamByName('part_ID').AsString := partID;
           params.ParamByName('point_qty').AsString :=trim( editpointqty.Text);
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Execute;
           fDPPM.CopyToHistory(partid);
        end;
     Except
       on E:Exception do
       begin
         MessageDlg('Database Error !!'+#13#10 +
                    E.Message ,mtError, [mbCancel],0);
         Exit;
       end;
     end;

     MessageDlg('Data Append OK!!',mtCustom, [mbOK],0);
     UpdateSuccess := True;
     If MessageDlg('Append Other Data ?',mtCustom, mbOKCancel,0) <> mrOK Then
        ModalResult := mrOK
     else
     begin
        editpartno.SelectAll ;
        editpartno.SetFocus ;
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
           Params.CreateParam(ftString	,'part_ID', ptInput);
           params.CreateParam(ftstring,'point_qty',ptinput);
           CommandText := 'Update SAJET.SYS_part_point '+
                          'Set point_qty=:point_qty, '+
                          ' UPDATE_USERID = :UPDATE_USERID,'+
                          'UPDATE_TIME = SYSDATE '+
                          'Where part_ID = :part_ID ';
           Params.ParamByName('point_qty').AsString := trim( editpointqty.Text);
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Params.ParamByName('part_ID').AsString := partID;
           Execute;
           fDPPM.CopyToHistory(partid);
           MessageDlg('Data Update OK!!',mtCustom, [mbOK],0);
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


end.
