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
    Label6: TLabel;
    LabType1: TLabel;
    LabType2: TLabel;
    Imagemain: TImage;
    edtDefect: TEdit;
    Label1: TLabel;
    edtReason: TEdit;
    Label2: TLabel;
    Label5: TLabel;
    lblDefect: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    lblReason: TLabel;
    lblDuty: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    edtDuty: TEdit;
    btn1: TSpeedButton;
    lbl1: TLabel;
    edtLocation: TEdit;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    MaintainType : String;
    UpdateSuccess:boolean;
    sOreasonid,sOdutyid:string;
    procedure SetTheRegion;
    function GetID(sFieldID,sfield,sTable,sCondition:string):integer;
  end;

var
  fData: TfData;

implementation

uses uMain,uDetail;

{$R *.DFM}
//uses uDPPM;
function TfData.GetID(sfieldID,sField,sTable,sCondition:string):integer;
begin
  result:=0;
  With fDPPM.QryTemp do
  begin
    close;
    params.Clear;
    commandtext:=' select '+sFieldID + ' sID from '+sTable+' where '+sField+' = '+''''+ sCondition+'''';
    open;
    if Not IsEmpty then
      Result:=fieldbyname('sID').AsInteger;
  end;
end;

procedure TfData.sbtnCancelClick(Sender: TObject);
begin
  if UpdateSuccess then
     ModalResult:=mrok
  else
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
   sDefectID,sReasonID,sDutyID:integer;
begin
  sDefectID:= getID('defect_Id','Defect_Code','sajet.sys_defect',trim(edtDefect.Text));
  if sDefectID=0 then
  begin
     MessageDlg('defect Code Error !!',mtError, [mbCancel],0);
     edtDefect.SelectAll;
     edtDefect.SetFocus ;
     Exit;
  end;
  sReasonID := getID('Reason_id','Reason_Code','sajet.sys_reason',trim(edtReason.Text)) ;
  if sReasonID=0 then
  begin
     MessageDlg('Reason Code Error !!',mtError, [mbCancel],0);
     edtReason.SelectAll;
     edtReason.SetFocus ;
     Exit;
  end;
  sDutyID := getID('duty_id','duty_Code','sajet.sys_duty',trim(edtDuty.Text)) ;
  if sDutyID=0 then
  begin
     MessageDlg('Duty Code Error !!',mtError, [mbCancel],0);
     edtDuty.SelectAll;
     edtDuty.SetFocus ;
     Exit;
  end;

  If MaintainType = 'Append' Then
  begin
     With fDPPM.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'defectID', ptInput);
        Params.CreateParam(ftString	,'reasonID', ptInput);
        Params.CreateParam(ftString	,'dutyID', ptInput);
        Params.CreateParam(ftString	,'Location', ptInput);
        CommandText := 'Select * '+
                       'From SAJET.sys_defect_reason '+
                       'Where defect_id = :defectID '+
                       'and reason_id = :reasonID '+
                       ' and duty_id =:dutyid and location =:location ';
        Params.ParamByName('defectID').AsInteger := sDefectID;
        Params.ParamByName('reasonID').AsInteger := sReasonID;
        Params.ParamByName('dutyID').AsInteger := sDutyID;
        Params.ParamByName('Location').AsString := edtLocation.text;
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'Defect Desc : '+ trim(lblDefect.Caption) + #13#10 +
                'Reason Desc : '+ trim(lblReason.Caption) + #13#10 +
                'Duty Desc : '+ trim(lblDuty.Caption) ;
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
           Params.CreateParam(ftString	,'defectID', ptInput);
           Params.CreateParam(ftString	,'reasonID', ptInput);
           Params.CreateParam(ftString	,'dutyID', ptInput);
           Params.CreateParam(ftString	,'Location', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           CommandText := 'Insert Into SAJET.sys_defect_reason '+
                          ' (defect_id,reason_id,duty_ID,update_userid,location) '+
                          'Values (:defectID,:reasonid,:dutyID,:UPDATE_USERID,:location) ';
           Params.ParamByName('defectID').AsInteger := sDefectID;
           Params.ParamByName('reasonID').AsInteger := sReasonID;
           Params.ParamByName('dutyID').AsInteger := sDutyID;
           Params.ParamByName('Location').AsString := edtLocation.text;
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Execute;
           fDPPM.CopyToHistory(inttostr(sDefectID),inttostr(sReasonID),IntToStr(sdutyid));

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
        lblDefect.Caption:='';
        edtDefect.Text:='';
        edtReason.Text:='';
        lblReason.Caption:='';
        edtDuty.Text :='';
        lblDuty.Caption:='';

        Exit;
     end;
     Exit;
  end;

  If MaintainType = 'Modify' Then
  begin
     With fDPPM.QryTemp do
     begin
       Close;
        Params.Clear;
        Params.CreateParam(ftString	,'defectID', ptInput);
        Params.CreateParam(ftString	,'reasonID', ptInput);
        Params.CreateParam(ftString	,'dutyID', ptInput);
        Params.CreateParam(ftString	,'Location', ptInput);
        CommandText := 'Select * '+
                       'From SAJET.sys_defect_reason '+
                       'Where defect_id = :defectID '+
                       'and reason_id = :reasonID '+
                       ' and duty_id =:dutyid and location =:location ';
        Params.ParamByName('defectID').AsInteger := sDefectID;
        Params.ParamByName('reasonID').AsInteger := sReasonID;
        Params.ParamByName('dutyID').AsInteger := sDutyID;
        Params.ParamByName('Location').AsString := edtLocation.text;
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'Defect Desc : '+ trim(lblDefect.Caption) + #13#10 +
                'Reason Desc : '+ trim(lblReason.Caption) + #13#10 +
                'Duty Desc : '+ trim(lblDuty.Caption) ;
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
           Params.CreateParam(ftString	,'defectid', ptInput);
           Params.CreateParam(ftString	,'Oreasonid', ptInput);
           Params.CreateParam(ftString	,'Odutyid', ptInput);
           Params.CreateParam(ftString	,'reasonid', ptInput);
           Params.CreateParam(ftString	,'iLocation', ptInput);
           Params.CreateParam(ftString	,'dutyid', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           commandtext := ' Update sajet.sys_defect_reason '
                          +' set reason_id=:reasonid '
                          +'     ,duty_id =:dutyid '
                          +'     ,update_userID=:UPDATE_USERID '
                          +'     ,update_time =sysdate '
                          +'     ,Location =:iLocation '
                          +' where defect_id=:defectid '
                          +' and reason_id = :Oreasonid '
                          +' and duty_id = :Odutyid  ';
           Params.ParamByName('defectid').AsInteger := sDefectID;
           Params.ParamByName('Oreasonid').AsString := sOReasonid;
           Params.ParamByName('Odutyid').AsString := sODutyid;
           Params.ParamByName('reasonid').AsInteger := sReasonID;
           Params.ParamByName('iLocation').AsString := edtLocation.text;
           Params.ParamByName('dutyid').AsInteger := sDutyID;
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Execute;
           fDPPM.CopyToHistory(inttostr(sDefectID),inttostr(sReasonID),inttostr(sDutyiD));
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

procedure TfData.SpeedButton1Click(Sender: TObject);
var fDetail : TfDetail;
begin
   fDetail:=TfDetail.create(self);
   fDetail.DBGrid1.DataSource.DataSet:=fDppm.QryTemp;
   with fDPPM.Qrytemp do
   begin
     close;
     params.Clear;
     commandtext:='select defect_code,defect_desc from sajet.sys_defect where defect_Code like '+''''+trim(edtDefect.Text)+'%'+'''';
     open;
   end;
   if fDetail.ShowModal = mrOk then
   begin
     edtDefect.Text:=fDetail.DBGrid1.DataSource.DataSet.fieldbyname('defect_code').AsString;
     lblDefect.Caption:=fDetail.DBGrid1.DataSource.DataSet.fieldbyname('defect_desc').AsString;
   end;
   fDetail.Free;
end;

procedure TfData.SpeedButton2Click(Sender: TObject);
var fDetail : TfDetail;
begin
   fDetail:=TfDetail.create(self);
   fDetail.DBGrid1.DataSource.DataSet:=fDppm.QryTemp;
   with fDPPM.Qrytemp do
   begin
     close;
     params.Clear;
     commandtext:='select reason_code,reason_desc from sajet.sys_reason where reason_Code like '+''''+trim(edtReason.Text)+'%'+'''';
     open;
   end;
   if fDetail.ShowModal = mrOk then
   begin
     edtReason.Text:=fDetail.DBGrid1.DataSource.DataSet.fieldbyname('reason_code').AsString;
     lblReason.Caption :=fDetail.DBGrid1.DataSource.DataSet.fieldbyname('reason_desc').AsString+' ';
   end;
   fDetail.Free;
end;

procedure TfData.btn1Click(Sender: TObject);
begin
   fDetail:=TfDetail.create(self);
   fDetail.DBGrid1.DataSource.DataSet:=fDppm.QryTemp;
   with fDPPM.Qrytemp do
   begin
     close;
     params.Clear;
     commandtext:='select duty_code,duty_desc from sajet.sys_duty where duty_Code like '+''''+trim(edtDuty.Text)+'%'+'''';
     open;
   end;
   if fDetail.ShowModal = mrOk then
   begin
     edtDuty.Text:=fDetail.DBGrid1.DataSource.DataSet.fieldbyname('duty_code').AsString;
     lblDuty.Caption :=fDetail.DBGrid1.DataSource.DataSet.fieldbyname('duty_desc').AsString+' ';
   end;
   fDetail.Free;
end;

end.
