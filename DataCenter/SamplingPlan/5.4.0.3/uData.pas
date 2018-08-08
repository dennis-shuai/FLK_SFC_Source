unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB, DBClient, Grids, DBGrids;

type
  TfData = class(TForm)
    sbtnClose: TSpeedButton;
    sbtnSave: TSpeedButton;
    Image5: TImage;
    Image1: TImage;
    LabPName: TLabel;
    Label5: TLabel;
    Label9: TLabel;
    Imagemain: TImage;
    LabPCode: TLabel;
    LabName: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    editMin: TEdit;
    editMax: TEdit;
    combGrade: TComboBox;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    qryGrade: TClientDataSet;
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure combGradeChange(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    ShowType : String;
    SamplingPlanID : String;
    RowId : String;
    procedure SetTheRegion;
//    Procedure CopyToHistory(RecordID : String);
    Function GetMaxPlanID : String;
    Function GetPlanID : String;
    Function GetGradeID(s:string) : String;
    Function AddData : Boolean;
    Function ModiData : Boolean;
  end;

var
  fData: TfData;

implementation

{$R *.DFM}
uses uSamplingPlan;

Function TfData.GetPlanID : String;
begin
  Result := '0';
  With fSamplingPlan.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'SAMPLING_TYPE', ptInput);
    CommandText := 'Select SAMPLING_ID '+
                   'From SAJET.SYS_QC_SAMPLING_PLAN '+
                   'Where SAMPLING_TYPE = :SAMPLING_TYPE ' ;
    Params.ParamByName('SAMPLING_TYPE').AsString := LabName.Caption;
    Open;
    If RecordCount > 0 Then
       Result := Fieldbyname('SAMPLING_ID').AsString;
    Close;
  end;
end;

Function TfData.GetMaxPlanID : String;
Var DBID : String;
begin
  With fSamplingPlan.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select NVL(Max(SAMPLING_ID),0) + 1 SAMPLING_ID '+
                   'From SAJET.SYS_QC_SAMPLING_PLAN' ;
    Open;
    If Fieldbyname('SAMPLING_ID').AsString = '1' Then
    begin
       Close;
       CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || ''0001'' SAMPLING_ID '+
                      'From SAJET.SYS_BASE '+
                      'Where PARAM_NAME = ''DBID'' ' ;
       Open;
    end;
    Result := Fieldbyname('SAMPLING_ID').AsString;
    Close;
  end;
end;

Function TfData.GetGradeID(s:string) : String;
begin
  Result := '0';
  With fSamplingPlan.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'SAMPLING_GRADE', ptInput);
    CommandText := 'Select SAMPLING_GRADE_ID '+
                   'From SAJET.SYS_QC_SAMPLING_GRADE '+
                   'Where SAMPLING_GRADE = :SAMPLING_GRADE ' ;
    Params.ParamByName('SAMPLING_GRADE').AsString := s;
    Open;
    If RecordCount > 0 Then
       Result := Fieldbyname('SAMPLING_GRADE_ID').AsString;
    Close;
  end;
end;

Function TfData.AddData : Boolean;
Var S : String; I : Integer; PlanId,sGradeID : String;
begin
  Result := False;
  With fSamplingPlan.QryTemp do
  begin
     Close;
     PlanId := GetPlanID;
     If PlanId = '0' Then
     begin
        PlanId := GetMaxPlanID;
        If PlanId = '' Then
        begin
           MessageDlg('Database Error !!'+#13#10 +
                      'could not get Sampling Plan Id !!' ,mtError, [mbCancel],0);
           Exit;
        end;
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'SAMPLING_ID', ptInput);
        Params.CreateParam(ftString	,'SAMPLING_TYPE', ptInput);
        Params.CreateParam(ftString	,'SAMPLING_DESC', ptInput);
        Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
        CommandText := 'Insert Into SAJET.SYS_QC_SAMPLING_PLAN '+
                       ' (SAMPLING_ID,SAMPLING_TYPE,SAMPLING_DESC,UPDATE_USERID) '+
                       'Values (:SAMPLING_ID,:SAMPLING_TYPE,:SAMPLING_DESC,:UPDATE_USERID) ';
        Params.ParamByName('SAMPLING_ID').AsString := PlanId;
        Params.ParamByName('SAMPLING_TYPE').AsString := LabName.Caption;
        Params.ParamByName('SAMPLING_DESC').AsString := '';
        Params.ParamByName('UPDATE_USERID').AsString := fSamplingPlan.UpdateUserID;
        Execute;
     end;

     sGradeID:= GetGradeID(combGrade.Text);
     Try
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'SAMPLING_ID', ptInput);
        Params.CreateParam(ftString	,'MIN_LOT_SIZE', ptInput);
        Params.CreateParam(ftString	,'MAX_LOT_SIZE', ptInput);
        Params.CreateParam(ftString	,'SAMPLING_GRADE_ID', ptInput);
        Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
        CommandText := 'Insert Into SAJET.SYS_QC_SAMPLING_PLAN_DETAIL '+
                       ' (SAMPLING_ID,MIN_LOT_SIZE,MAX_LOT_SIZE,SAMPLING_GRADE_ID,UPDATE_USERID) '+
                       'Values '+
                       ' (:SAMPLING_ID,:MIN_LOT_SIZE,:MAX_LOT_SIZE,:SAMPLING_GRADE_ID,:UPDATE_USERID) ';
        Params.ParamByName('SAMPLING_ID').AsString := PlanId;
        Params.ParamByName('MIN_LOT_SIZE').AsString := Trim(editMin.Text);
        Params.ParamByName('MAX_LOT_SIZE').AsString := Trim(editMax.Text);
        Params.ParamByName('SAMPLING_GRADE_ID').AsString := sGradeID;
        Params.ParamByName('UPDATE_USERID').AsString := fSamplingPlan.UpdateUserID;
        Execute;
        close;
     Except
       on e:Exception do
       begin
         MessageDlg('Database Error !!'+e.message+#13#10 +
                    'could not Update Database !!' ,mtError, [mbCancel],0);
         Exit;
     end;
     end;
  end;
  Result := True;
end;

Function TfData.ModiData : Boolean;
Var S,sGradeID : String;
begin
   // ÀË¬d NAME ¬O§_­«½Æ
   Result := False;
   sGradeID:= GetGradeID(combGrade.Text);
   Try
      With fSamplingPlan.QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'MIN_LOT_SIZE', ptInput);
        Params.CreateParam(ftString	,'MAX_LOT_SIZE', ptInput);
        Params.CreateParam(ftString	,'SAMPLING_GRADE_ID', ptInput);
        Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
        Params.CreateParam(ftString	,'DATA', ptInput);
        CommandText := 'Update SAJET.SYS_QC_SAMPLING_PLAN_DETAIL '+
                       'Set MIN_LOT_SIZE = :MIN_LOT_SIZE,'+
                           'MAX_LOT_SIZE = :MAX_LOT_SIZE,'+
                           'SAMPLING_GRADE_ID = :SAMPLING_GRADE_ID,'+
                           'UPDATE_USERID = :UPDATE_USERID '+
                       'Where ROWID = :DATA ';
        Params.ParamByName('MIN_LOT_SIZE').AsString := Trim(editMin.Text);
        Params.ParamByName('MAX_LOT_SIZE').AsString := Trim(editMax.Text);
        Params.ParamByName('SAMPLING_GRADE_ID').AsString := sGradeID;
        Params.ParamByName('UPDATE_USERID').AsString := fSamplingPlan.UpdateUserID;
        Params.ParamByName('DATA').AsString := RowId;
        Execute;
        MessageDlg('Update OK!!',mtCustom, [mbOK],0);
        Result := True;
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

procedure TfData.sbtnCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TfData.FormCreate(Sender: TObject);
begin
  combGrade.Clear;
  With fSamplingPlan.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select SAMPLING_GRADE '
                 + 'From SAJET.SYS_QC_SAMPLING_GRADE '
                 + 'Group By SAMPLING_GRADE '
                 + 'Order By SAMPLING_GRADE '   ;
    Open;
    While not Eof Do
    begin
      combGrade.Items.Add(FieldByName('SAMPLING_GRADE').asstring);
      Next;
    end;
  end;

  QryGrade.RemoteServer := fSamplingPlan.QryTemp.RemoteServer;
  QryGrade.ProviderName := 'DspQryData';

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
begin
  if combGrade.itemIndex=-1 then
  begin
    MessageDlg('Sampling Grade Error !!',mtError, [mbCancel],0);
    combGrade.SetFocus;
    Exit;
  end;

  If StrToIntDef(Trim(editMin.Text),0) = 0 Then
  begin
     MessageDlg('Lot Size Error !!',mtError, [mbCancel],0);
     editMin.SetFocus;
     editMin.SelectAll;
     Exit;
  end;

  If StrToIntDef(Trim(editMax.Text),0) = 0 Then
  begin
     MessageDlg('Lot Size Error !!',mtError, [mbCancel],0);
     editMax.SetFocus;
     editMax.SelectAll;
     Exit;
  end;

  If StrToIntDef(Trim(editMax.Text),0) < StrToIntDef(Trim(editMin.Text),0) Then
  begin
     MessageDlg('Lot Size Define Error !!',mtError, [mbCancel],0);
     editMax.SetFocus;
     editMax.SelectAll;
     Exit;
  end;

  If ShowType = 'Append' Then
  begin
    If not AddData Then
      Exit;
  end Else
  begin
    If not ModiData Then
      Exit;
  end;

  Close;
end;

procedure TfData.combGradeChange(Sender: TObject);
begin
  with qryGrade do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'SAMPLING_GRADE', ptInput);
    CommandText := 'Select decode(sampling_level,''0'',''Normal'',''1'',''Tight'',''2'',''Reduced'',''3'',''No Inspect'',''N/A'') LevelNAME '
                 + '       ,SAMPLING_LEVEL,SAMPLE_SIZE,CRITICAL_REJECT_QTY,MAJOR_REJECT_QTY,MINOR_REJECT_QTY '
                 + 'From SAJET.SYS_QC_SAMPLING_GRADE '
                 + 'Where SAMPLING_GRADE = :SAMPLING_GRADE '
                 + 'order by SAMPLING_LEVEL';
    Params.ParamByName('SAMPLING_GRADE').AsString := combGrade.Text;
    Open;
  end;
end;

end.

