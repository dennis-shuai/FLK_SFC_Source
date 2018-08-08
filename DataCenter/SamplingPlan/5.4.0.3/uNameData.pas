unit uNameData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB, DBClient, Grids, DBGrids;

type
  TfNameData = class(TForm)
    sbtnClose: TSpeedButton;
    sbtnSave: TSpeedButton;
    Image5: TImage;
    Image1: TImage;
    LabPName: TLabel;
    Label5: TLabel;
    Label9: TLabel;
    Imagemain: TImage;
    LabPCode: TLabel;
    editSamplingName: TEdit;
    editSamplingDesc: TEdit;
    qryGrade: TClientDataSet;
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    SamplingPlanID : String;
    procedure SetTheRegion;
//    Procedure CopyToHistory(RecordID : String);
  end;

var
  fNameData: TfNameData;

implementation

{$R *.DFM}
uses uSamplingPlan;

procedure TfNameData.sbtnCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TfNameData.FormCreate(Sender: TObject);
begin
  if FileExists(ExtractFilePath(Application.ExeName) + 'sDetail.bmp') then
  begin
    Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'sDetail.bmp');
    SetTheRegion;
  end;  
end;

procedure TfNameData.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.
procedure TfNameData.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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
procedure TfNameData.WMNCHitTest( var msg: TWMNCHitTest );
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

procedure TfNameData.sbtnSaveClick(Sender: TObject);
begin
  if Trim(editSamplingName.Text)='' then
  begin
    MessageDlg('Sampling Plan Name Error !!',mtError, [mbCancel],0);
    editSamplingName.SetFocus;
    Exit;
  end;

  Try
    With fSamplingPlan.QryTemp do
    begin
      //¬O§_­«½Æ
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'SAMPLING_TYPE', ptInput);
      Params.CreateParam(ftString	,'SAMPLING_ID', ptInput);
      CommandText := 'Select SAMPLING_ID from SAJET.SYS_QC_SAMPLING_PLAN '+
                     'where SAMPLING_TYPE = :SAMPLING_TYPE '+
                     'and SAMPLING_ID <> :SAMPLING_ID ';
      Params.ParamByName('SAMPLING_TYPE').AsString := editSamplingName.Text;
      Params.ParamByName('SAMPLING_ID').AsString := SamplingPlanID;
      Open;
      if not IsEmpty then
      begin
        MessageDlg('Sampling Plan Name Duplicate !! ',mtError,[mbCancel],0);
        editSamplingName.SetFocus;
        editSamplingName.SelectAll;
        exit;
      end;
      
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'SAMPLING_TYPE', ptInput);
      Params.CreateParam(ftString	,'SAMPLING_DESC', ptInput);
      Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
      Params.CreateParam(ftString	,'SAMPLING_ID', ptInput);
      CommandText := 'Update SAJET.SYS_QC_SAMPLING_PLAN '+
                     'Set SAMPLING_TYPE = :SAMPLING_TYPE,'+
                         'SAMPLING_DESC = :SAMPLING_DESC,'+
                         'UPDATE_USERID = :UPDATE_USERID '+
                     'Where SAMPLING_ID = :SAMPLING_ID ';
      Params.ParamByName('SAMPLING_TYPE').AsString := editSamplingName.Text;
      Params.ParamByName('SAMPLING_DESC').AsString := editSamplingDesc.Text;
      Params.ParamByName('UPDATE_USERID').AsString := fSamplingPlan.UpdateUserID;
      Params.ParamByName('SAMPLING_ID').AsString := SamplingPlanID;
      Execute;
      MessageDlg('Update OK!!',mtCustom, [mbOK],0);
      ModalResult := mrOK;
    end;
  Except
    on e:Exception do
    begin
      MessageDlg('Database Error !!'+e.message+#13#10 +
                 'could not Update Database !!' ,mtError, [mbCancel],0);
      Exit;
    end;
  end;
end;

end.

