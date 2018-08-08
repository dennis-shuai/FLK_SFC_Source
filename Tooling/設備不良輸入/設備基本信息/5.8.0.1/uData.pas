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
    edtDefect: TEdit;
    Label2: TLabel;
    Label1: TLabel;
    cmbToolingNo: TComboBox;
    lbltoolingid: TLabel;
    Image2: TImage;
    lblDeptid: TLabel;
    lbl1: TLabel;
    edtReason: TEdit;
    lblDefectDesc: TLabel;
    lblReasonDesc: TLabel;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure cmbDeptSelect(Sender: TObject);
    procedure cmbToolingNoSelect(Sender: TObject);
    procedure edtDefectChange(Sender: TObject);
    procedure edtReasonChange(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    MaintainType : String;
    UpdateSuccess : Boolean;
    stoolingId,sODefectid,sOreasonid,sDefectid,sreasonid:string;
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
    CommandText := 'SELECT TOOLING_NO FROM SAJET.SYS_TOOLING WHERE ENABLED=''Y'' and IsRepair_Control =''Y'' ORDER BY TOOLING_NO  ';
    Open;
    cmbToolingNo.Clear;
    First;
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


  If cmbToolingNo.ItemIndex = -1 Then
  begin
     MessageDlg('tooling no Error !!',mtError, [mbCancel],0);
     cmbToolingNo.SetFocus ;
     Exit;
  end;

  if sDefectid ='' then begin
       with fDetail.QryTemp do
      begin
          Close;
          params.clear;
          Params.CreateParam(ftString,'Defect_Code',ptInput);
          CommandText :='select * from sajet.sys_defect where defect_code=:Defect_Code';
          Params.ParamByName('Defect_Code').AsString :=edtDefect.Text;
          Open;
          if Not IsEmpty then begin
              sDefectid := fieldByName('defect_id').AsString;
              lblDefectDesc.Caption := fieldByName('defect_desc').AsString;
          end;
      end;
  end;
  if sreasonid ='' then begin
      with fDetail.QryTemp do
      begin
          Close;
          params.clear;
          Params.CreateParam(ftString,'Reason_Code',ptInput);
          CommandText :='select * from sajet.sys_reason where Reason_code=:Reason_Code';
          Params.ParamByName('Reason_Code').AsString :=edtReason.Text;
          Open;
          if Not IsEmpty then begin
              sreasonid := fieldByName('reason_id').AsString;
              lblReasonDesc.Caption := fieldByName('Reason_desc').AsString;
          end;
      end;
  end;

  if sDefectid ='' then begin
     MessageDlg('No defect ',mtError,[mbOK],0);
     edtDefect.SetFocus;
     edtDefect.SelectAll;
     Exit;
  end;

  if sreasonid ='' then begin
     MessageDlg('No Reason ',mtError,[mbOK],0);
     edtReason.SetFocus;
     edtReason.SelectAll;
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


  end;

  If MaintainType = 'Append' Then
  begin

     with fDetail.QryTemp do
     begin

        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'defect_id', ptInput);
        Params.CreateParam(ftString	,'Reason_id', ptInput);
        Params.CreateParam(ftString	,'tooling_id', ptInput);
        CommandText := 'Select defect_id,tooling_id ,Reason_id '+
                       'From sajet.sys_tooling_repair_info '+
                       'Where defect_id = :defect_id '+
                       'and Reason_id = :Reason_id '+
                       'and tooling_id = :tooling_id ';
        Params.ParamByName('defect_id').AsString := sDefectid;
        Params.ParamByName('reason_id').AsString := sreasonid;
        Params.ParamByName('tooling_id').AsString := stoolingId;
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'tooling no : '+ cmbToolingNo.Text + #13#10 +
                'Defect : '+ lblDefectDesc.Caption+ #13#10 +
                'Reason : '+ lblReasonDesc.Caption  ;
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
           Params.CreateParam(ftString	,'Defect_ID', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'tooling_id', ptInput);
           Params.CreateParam(ftString	,'Reason_ID', ptInput);
           CommandText := 'Insert Into sajet.sys_tooling_repair_Info'+
                          ' (tooling_id,Defect_ID,Reason_ID,UPDATE_USERID,update_time) '+
                          'Values (:tooling_id,:Defect_ID,:Reason_ID,:UPDATE_USERID,sysdate) ';
           Params.ParamByName('Defect_ID').AsString := sdefectId;
           Params.ParamByName('UPDATE_USERID').AsString := fDetail.UpdateUserID;
           Params.ParamByName('tooling_id').AsString := stoolingId;
           Params.ParamByName('Reason_ID').AsString := sReasonId ;
           Execute;
          
          // fDetail.CopyToHistory(sdeptid,stoolingId);
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
       // cmbToolingNo.ItemIndex:=-1;
        edtReason.Text :='';
        edtReason.SetFocus ;
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
           Params.CreateParam(ftString	,'defect_id', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'tooling_id', ptInput);
           Params.CreateParam(ftString	,'reason_id', ptInput);
           Params.CreateParam(ftString	,'Old_defect_id', ptInput);
           Params.CreateParam(ftString	,'Old_reason_id', ptInput);
           CommandText := 'Update SAJET.sys_tooling_repair_info '+
                          'Set reason_id =:reason_id, defect_id = :defect_id ,'+
                          'UPDATE_USERID = :UPDATE_USERID,'+
                          'UPDATE_TIME = SYSDATE '+
                          'Where defect_id = :Old_defect_id  and '+
                          'reason_id = :Old_reason_id  and '+
                          'tooling_id = :tooling_id ';
           Params.ParamByName('defect_id').AsString := sDefectid;
           Params.ParamByName('UPDATE_USERID').AsString := fDetail.UpdateUserID;
           Params.ParamByName('tooling_ID').AsString := stoolingId;
           Params.ParamByName('reason_id').AsString := sreasonid;
           Params.ParamByName('Old_defect_id').AsString := sODefectid;
           Params.ParamByName('Old_reason_id').AsString := sOreasonid;
           Execute;
           
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

procedure TfData.edtDefectChange(Sender: TObject);
begin
//
  sDefectid :='';
  with fDetail.QryTemp do
  begin
      Close;
      params.clear;
      Params.CreateParam(ftString,'Defect_Code',ptInput);
      CommandText :='select * from sajet.sys_defect where defect_code=:Defect_Code';
      Params.ParamByName('Defect_Code').AsString :=edtDefect.Text;
      Open;
      if Not IsEmpty then begin
          sDefectid := fieldByName('defect_id').AsString;
          lblDefectDesc.Caption := fieldByName('defect_desc').AsString;
      end;
  end;

end;

procedure TfData.edtReasonChange(Sender: TObject);
begin
  sreasonid :='';
  with fDetail.QryTemp do
  begin
      Close;
      params.clear;
      Params.CreateParam(ftString,'Reason_Code',ptInput);
      CommandText :='select * from sajet.sys_reason where Reason_code=:Reason_Code';
      Params.ParamByName('Reason_Code').AsString :=edtReason.Text;
      Open;
      if Not IsEmpty then begin
          sreasonid := fieldByName('reason_id').AsString;
          lblReasonDesc.Caption := fieldByName('Reason_desc').AsString;
      end;
  end;
end;

end.
