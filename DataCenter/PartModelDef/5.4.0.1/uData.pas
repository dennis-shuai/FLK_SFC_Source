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
    Label1: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    Label3: TLabel;
    SpeedButton1: TSpeedButton;
    editPart: TEdit;
    LabName: TLabel;
    EditTarget: TEdit;
    CmbShift: TComboBox;
    LabStartTime: TLabel;
    EditRemark: TEdit;
    CombShiftID: TComboBox;
    CombStartTime: TComboBox;
    CombEndTime: TComboBox;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure editPartKeyPress(Sender: TObject; var Key: Char);
    procedure CmbShiftChange(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
    procedure GetModelName;
  public
    { Public declarations }
    MaintainType : String;
    UpdateSuccess : Boolean;
    //PDlineID,ProcessID,
    ModelID : String;
    procedure SetTheRegion;
  end;

var
  fData: TfData;

implementation

{$R *.DFM}
uses uFormMain, uPFilter ;

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
  LabStartTime.Caption := '';
  LabName.Caption := '';
  with FormMain.QryTemp do
  begin
    close;
    Params.Clear;
    CommandText := 'SELECT SHIFT_ID,SHIFT_NAME,START_TIME,END_TIME FROM SAJET.SYS_SHIFT WHERE Enabled = ''Y'' ';
    Open;
    CmbShift.Clear;
    CombShiftID.Clear;
    CombStartTime.Clear;
    CombEndTime.Clear;
    while not Eof do
    begin
      CombShiftID.Items.Add(FieldByName('SHIFT_ID').AsString);
      CmbShift.Items.Add(FieldByName('SHIFT_NAME').AsString);
      CombStartTime.Items.Add(FieldByName('START_TIME').AsString);
      CombEndTime.Items.Add(FieldByName('END_TIME').AsString);
      Next;
    end;
    Close ;
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
Var S : String;
begin
  if editPart.Text = '' then
  begin
    MessageDlg('Model Part Error !!', mtError, [mbOK], 0);
    editPart.SetFocus;
    Exit;
  end;

  if EditTarget.Text<>'' then
  begin
    try
      strtofloat(EditTarget.Text);
    except
      MessageDlg('Target Limit must be Integer',mtError, [mbCancel],0);
      Exit;
    end;
  end;

  If CmbShift.ItemIndex = -1 Then
  begin
     MessageDlg('Model Shift Error !!',mtError, [mbCancel],0);
     CmbShift.SetFocus ;
     Exit;
  end;

  if EditRemark.Text = '' then
  begin
    MessageDlg('Model Remark Error !!', mtError, [mbOK], 0);
    EditRemark.SetFocus;
    Exit;
  end;

  If MaintainType = 'Append' Then
  begin
     // 檢查 Process 是否已有設定
     With FormMain.QryTemp do
     begin
        {Close;
        Params.Clear;
        Params.CreateParam(ftString	,'PROCESS_NAME', ptInput);
        CommandText := 'Select PROCESS_ID '+
                       'From SAJET.SYS_PROCESS '+
                       'Where PROCESS_NAME = :PROCESS_NAME ';
        Params.ParamByName('PROCESS_NAME').AsString := cmbProcess.Text;
        Open;
        ProcessID := FieldByName('PROCESS_ID').AsString;

        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'PDLINE_NAME', ptInput);
        CommandText := 'Select PDLINE_ID '+
                       'From SAJET.SYS_PDLINE '+
                       'Where PDLINE_NAME = :PDLINE_NAME ';
        Params.ParamByName('PDLINE_NAME').AsString := cmbLine.Text;
        Open;
        PDlineID := FieldByName('PDLINE_ID').AsString;}

        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'PART_NO', ptInput);
        CommandText := 'Select PART_ID '+
                       'From SAJET.SYS_PART '+
                       'Where PART_NO = :PART_NO ';
        Params.ParamByName('PART_NO').AsString := Trim(editPart.Text);
        Open ;
        ModelID := FieldByName('PART_ID').AsString;

        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'MODEL_ID', ptInput);
        Params.CreateParam(ftString	,'SHIFT_ID', ptInput);
        CommandText := 'Select MODEL_ID '+
                       'From SAJET.SYS_MODEL_MONITOR_BASE '+
                       'Where MODEL_ID = :MODEL_ID ' +
                       'and SHIFT_ID = :SHIFT_ID ' ;
        Params.ParamByName('MODEL_ID').AsString := ModelID;
        Params.ParamByName('SHIFT_ID').AsString := CombShiftID.Text ;
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'Part_No : '+ editPart.Text + #13#10 +
                'Shift : '+ CmbShift.Text ;
           Close;
           MessageDlg(S,mtError, [mbCancel],0);
           Exit;
        end;
     end;

     Try
        With FormMain.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'MODEL_ID', ptInput);
           Params.CreateParam(ftString	,'TARGET_QTY', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'REMARK', ptInput);
           Params.CreateParam(ftString	,'SHIFT_ID', ptInput);
           CommandText := 'Insert Into SAJET.SYS_MODEL_MONITOR_BASE '+
                          ' (MODEL_ID,TARGET_QTY,UPDATE_USERID,REMARK,SHIFT_ID) '+
                          'Values (:MODEL_ID,:TARGET_QTY,:UPDATE_USERID,:REMARK,:SHIFT_ID) ';
           Params.ParamByName('MODEL_ID').AsString := ModelID;
           Params.ParamByName('TARGET_QTY').AsString := trim(EditTarget.Text);
           Params.ParamByName('UPDATE_USERID').AsString := FormMain.UpdateUserID;
           Params.ParamByName('REMARK').AsString := trim(EditRemark.Text);
           Params.ParamByName('SHIFT_ID').AsString := CombShiftID.Text;
           Execute;
           //FormMain.CopyToHistory(PDLineID,ProcessID);
        end;
     Except
       on E:Exception do
       begin
         MessageDlg('Database Error !!'+#13#10 +
                    E.Message ,mtError, [mbCancel],0);
         Exit;
       end;
     end;

     MessageDlg('LCD Monitor Data Append OK!!',mtCustom, [mbOK],0);
     UpdateSuccess := True;
     If MessageDlg('Append Other LCD Monitor Data ?',mtCustom, mbOKCancel,0) <> mrOK Then
        ModalResult := mrOK
     else
     begin
        editPart.Text := '';
        LabName.Caption := '';
        EditTarget.Text := '';
        CmbShift.ItemIndex:=-1;
        LabStartTime.Caption := '';
        EditRemark.Text := '';
        editPart.SetFocus ;
        Exit;
     end;
     Exit;
  end;

  If MaintainType = 'Modify' Then
  begin
     Try
        With FormMain.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'TARGET_QTY', ptInput);
           Params.CreateParam(ftString	,'REMARK', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'MODEL_ID', ptInput);
           Params.CreateParam(ftString	,'SHIFT_ID', ptInput);
           CommandText := 'Update SAJET.SYS_MODEL_MONITOR_BASE '+
                          'Set TARGET_QTY = :TARGET_QTY,'+
                              'SHIFT_ID = :SHIFT_ID,'+
                              'REMARK = :REMARK, '+
                              'UPDATE_USERID = :UPDATE_USERID,'+
                              'UPDATE_TIME = SYSDATE '+
                          'Where MODEL_ID = :MODEL_ID ';
                          //'and PDLINE_ID = :PDLINE_ID '
           Params.ParamByName('TARGET_QTY').AsString := trim(EditTarget.Text);
           Params.ParamByName('REMARK').AsString := trim(EditRemark.Text);
           Params.ParamByName('UPDATE_USERID').AsString := FormMain.UpdateUserID;
           Params.ParamByName('SHIFT_ID').AsString := CombShiftID.Text ;
           Params.ParamByName('MODEL_ID').AsString := ModelID;
           Execute;
           //FormMain.CopyToHistory(PDLineID,ProcessID);
           MessageDlg('LCD Monitor Data Update OK!!',mtCustom, [mbOK],0);
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
begin
  with FormMain.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PN', ptInput);
    CommandText := 'Select PART_NO, SPEC1, SPEC2, ' +
      ' VERSION,NVL(B.MODEL_NAME,A.PART_NO) AS MODEL_NAME ' +
      'From SAJET.SYS_PART A,SAJET.SYS_MODEL B' +
      ' Where PART_NO Like :PN and A.Enabled = ''Y'' AND A.PART_ID=B.MODEL_ID(+)' +
      'Order By PART_NO';
    Params.ParamByName('PN').AsString := Trim(editPart.Text) + '%';
    Open;
  end;

  with TfPFilter.Create(Self) do
  begin
    edtPart.Text := Trim(editPart.Text);
    if Showmodal = mrOK then
    begin
      editPart.Text := FormMain.QryTemp.Fieldbyname('PART_NO').AsString;
      editPart.SetFocus;
      GetModelName ;
    end;
    Free;
  end;
  FormMain.QryTemp.Close;
end;

procedure TfData.GetModelName;
begin
  with FormMain.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PN', ptInput);
    CommandText := 'Select NVL(B.MODEL_NAME,A.PART_NO) AS MODEL_NAME ' +
                   ' From SAJET.SYS_PART A,SAJET.SYS_MODEL B' +
                   ' Where PART_NO = :PN and A.Enabled = ''Y'' AND A.PART_ID=B.MODEL_ID(+)' +
                   'Order By PART_NO';
    Params.ParamByName('PN').AsString := Trim(editPart.Text);
    Open;
    if not IsEmpty then
    begin
      LabName.Caption := Fieldbyname('MODEL_NAME').AsString;
    end else LabName.Caption := '';
    Close ;
  end;
end;

procedure TfData.editPartKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) and (editPart.Text <> '') then
  begin
    GetModelName ;
  end;
end;

procedure TfData.CmbShiftChange(Sender: TObject);
begin
    CmbShift.ItemIndex := CmbShift.ItemIndex ;
    CombShiftID.ItemIndex := CmbShift.ItemIndex ;
    CombStartTime.ItemIndex := CmbShift.ItemIndex ;
    CombEndTime.ItemIndex := CmbShift.ItemIndex ;
    LabStartTime.Caption := Copy(CombStartTime.Text,1,2)+':'+ Copy(CombStartTime.Text,3,2) +
                           '-'+Copy(CombEndTime.Text,1,2)+':'+ Copy(CombEndTime.Text,3,2) ;
end;

end.
