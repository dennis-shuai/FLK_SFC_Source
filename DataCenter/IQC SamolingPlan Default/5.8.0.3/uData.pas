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
    cmbSamplingPlan: TComboBox;
    Label5: TLabel;
    Label1: TLabel;
    cmbDefaultAql: TComboBox;
    Label3: TLabel;
    cmbUpperAQL: TComboBox;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure cmbSamplingPlanSelect(Sender: TObject);
    procedure cmbDefaultAqlSelect(Sender: TObject);
    procedure cmbUpperAQLSelect(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    MaintainType : String;
    UpdateSuccess : Boolean;
    sLowerSampling,sDefaultSampling,sUpperSampling,partID : String;
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
    CommandText := 'Select a.Sampling_Type '+
                   'From SAJET.SYS_QC_Sampling_Plan a '+
                   'Where a.Enabled = ''Y'' '+
                   'Order by a.Sampling_Type ';
    Open;
    cmbSamplingPlan.Clear;
    while not Eof do
    begin
      cmbSamplingPlan.Items.Add(FieldByName('Sampling_Type').AsString);
      cmbDefaultAql.Items.Add(FieldByName('Sampling_Type').AsString);
      cmbUpperAql.Items.Add(FieldByName('Sampling_Type').AsString);
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
Var S,sSqlText : String;
I : Integer;
begin
  If cmbSamplingPlan.ItemIndex = -1 Then
  begin
     MessageDlg('Sampling Plan Error !!',mtError, [mbCancel],0);
     cmbSamplingPlan.SetFocus ;
     Exit;
  end;

  If trim(editpartno.Text)='' Then
  begin
     MessageDlg('part_no Error !!',mtError, [mbCancel],0);
     editpartno.SetFocus ;
     Exit;
  end;


  If MaintainType = 'Append' Then
  begin

     With fDPPM.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'part_no', ptInput);
        CommandText := 'Select part_ID '+
                       'From SAJET.SYS_part '+
                       'Where part_no Like :part_no ';
        Params.ParamByName('part_no').AsString := editpartno.Text;
        Open;
        if isempty then
        begin
           MessageDlg('PART_NO Data Error !!'+#13#10,mtError, [mbCancel],0);
           editpartno.SelectAll ;
           editpartno.SetFocus ;
           exit;
        end;

     end;

     With fDPPM.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'part', ptInput);
        CommandText := 'DELETE FROM SAJET.SYS_IQC_SAMPLING_DEFAULT '+
                       ' Where PART_ID IN(SELECT PART_ID FROM SAJET.SYS_PART WHERE '+
                       ' PART_NO  Like :part )';
        Params.ParamByName('part').AsString := editpartno.Text;
        execute;
        Close;

        Params.Clear;
        Params.CreateParam(ftString	,'part', ptInput);
        Params.CreateParam(ftString	,'sLower', ptInput);
        Params.CreateParam(ftString	,'sDefault', ptInput);
        Params.CreateParam(ftString	,'sUpper', ptInput);
        Params.CreateParam(ftString	,'user_ID', ptInput);
        CommandText := 'Insert into SAJET.SYS_IQC_SAMPLING_DEFAULT SELECT   part_ID ,'+
                       ' :sLower,:sDefault,:sUpper,'+
                       ' :user_ID,sysdate,''Y''  From SAJET.SYS_PART '+
                       ' Where PART_NO Like :part';
                       sSqlText :=  CommandText;
        Params.ParamByName('part').AsString := editpartno.Text;
        Params.ParamByName('sLower').AsString := sLowerSampling;
        Params.ParamByName('sDefault').AsString := sDefaultSampling;
        Params.ParamByName('sUpper').AsString := sUpperSampling;
        Params.ParamByName('user_ID').AsString := fDPPM.UpdateUserID;
        execute;
        MessageDlg('Part_no Data Append OK!!',mtCustom, [mbOK],0);
        UpdateSuccess := True;

     end;



     If MessageDlg('Append Other Part_no Data ?',mtCustom, mbOKCancel,0) <> mrOK Then
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
     with fDPPM.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'part_no', ptInput);
        CommandText := 'Select part_ID '+
                       'From SAJET.SYS_part '+
                       'Where part_no Like :part_no ';
        Params.ParamByName('part_no').AsString := editpartno.Text;
        Open;
        if isempty then
        begin
           MessageDlg('PART_NO Data Error !!'+#13#10,mtError, [mbCancel],0);
           editpartno.SelectAll ;
           editpartno.SetFocus ;
           exit;
        end;

     end;

     With fDPPM.QryTemp do
     begin
     
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'part', ptInput);
        Params.CreateParam(ftString	,'Lower_Plan', ptInput);
        Params.CreateParam(ftString	,'Default_Plan', ptInput);
        Params.CreateParam(ftString	,'Upper_plan', ptInput);
        Params.CreateParam(ftString	,'user_ID', ptInput);
        CommandText := 'UPDATE  SAJET.SYS_IQC_SAMPLING_DEFAULT SET Lower_Sampling =:Lower_Plan, '+
                       ' Default_Sampling =:Default_Plan,Upper_Sampling =:Upper_plan '+
                       ' Update_UserID =:UserID,Update_time =sysdate '+
                       ' Where PART_ID IN(SELECT PART_ID FROM SAJET.SYS_PART WHERE '+
                       ' PART_NO  Like :part )';
        Params.ParamByName('part').AsString := editpartno.Text;
        Params.ParamByName('Lower_Plan').AsString := editpartno.Text;
        Params.ParamByName('Default_Plan').AsString := editpartno.Text;
        Params.ParamByName('Upper_plan').AsString := editpartno.Text;
        Params.ParamByName('user_ID').AsString := fDPPM.UpdateUserID;
        execute;
        Close;

        MessageDlg('Part_no Data Modify OK!!',mtCustom, [mbOK],0);
        UpdateSuccess := True;

     end;



     If MessageDlg('Modify Other Part_no Data ?',mtCustom, mbOKCancel,0) <> mrOK Then
        ModalResult := mrOK
     else
     begin
        editpartno.SelectAll ;
        editpartno.SetFocus ;
        Exit;
     end;
     Exit;

  End;
end;

procedure TfData.cmbSamplingPlanSelect(Sender: TObject);
begin

   with fDPPM.QryTemp do
   begin
     close;
     Params.Clear;
     Params.CreateParam(ftstring,'sampling',ptInput);
     CommandText := 'Select a.Sampling_ID '+
                   'From SAJET.SYS_QC_Sampling_Plan a '+
                   'Where a.Enabled = ''Y'' and A.Sampling_type =:sampling ';
     Params.ParamByName('sampling').AsString := cmbSamplingPlan.Text;
     Open;
     sLowerSampling := fieldByName('Sampling_ID').Asstring;
   end;
end ;

procedure TfData.cmbDefaultAqlSelect(Sender: TObject);
begin
   with fDPPM.QryTemp do
   begin
     close;
     Params.Clear;
     Params.CreateParam(ftstring,'sampling',ptInput);
     CommandText := 'Select a.Sampling_ID '+
                   'From SAJET.SYS_QC_Sampling_Plan a '+
                   'Where a.Enabled = ''Y'' and A.Sampling_type =:sampling ';
     Params.ParamByName('sampling').AsString := cmbDefaultAQL.Text;
     Open;
     sDefaultSampling := fieldByName('Sampling_ID').Asstring;
   end;
end;

procedure TfData.cmbUpperAQLSelect(Sender: TObject);
begin
   with fDPPM.QryTemp do
   begin
     close;
     Params.Clear;
     Params.CreateParam(ftstring,'sampling',ptInput);
     CommandText := 'Select a.Sampling_ID '+
                   'From SAJET.SYS_QC_Sampling_Plan a '+
                   'Where a.Enabled = ''Y'' and A.Sampling_type =:sampling';
     Params.ParamByName('sampling').AsString := cmbUpperAQL.Text;
     Open;
     sUpperSampling := fieldByName('Sampling_ID').Asstring;
   end;
end;

end.
