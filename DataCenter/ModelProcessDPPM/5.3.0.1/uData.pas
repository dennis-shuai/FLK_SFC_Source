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
    editLower: TEdit;
    Label1: TLabel;
    editUpper: TEdit;
    Label2: TLabel;
    cmbProcess: TComboBox;
    Label5: TLabel;
    cmbModel: TComboBox;
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
    MODELID,ProcessID : String;
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
    CommandText := 'Select a.Process_Name '+
                   'From SAJET.SYS_PROCESS a,sajet.sys_stage b '+
                   'Where a.Enabled = ''Y'' '+
                   'and b.enabled=''Y'' '+
                   'and a.stage_id = b.stage_id '+
                   'Order by a.Process_Name ';
    Open;
    cmbProcess.Clear;
    while not Eof do
    begin
      cmbProcess.Items.Add(FieldByName('Process_Name').AsString);
      Next;
    end;
  end;

  with fDPPM.QryTemp do
  begin
    close;
    Params.Clear;
    CommandText := 'Select a.MODEL_NAME '+
                   'From SAJET.SYS_MODEL a '+
                   'Where a.Enabled = ''Y'' '+
                   'Order by a.MODEL_NAME ';
    Open;
    cmbmodel.Clear;
    while not Eof do
    begin
      cmbmodel.Items.Add(FieldByName('MODEL_NAME').AsString);
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
  If cmbmodel.ItemIndex = -1 Then
  begin
     MessageDlg('Model Name Error !!',mtError, [mbCancel],0);
     cmbmodel.SetFocus ;
     Exit;
  end;

  If cmbProcess.ItemIndex = -1 Then
  begin
     MessageDlg('Process Error !!',mtError, [mbCancel],0);
     cmbProcess.SetFocus ;
     Exit;
  end;

  if editLower.Text<>'' then
  begin
    try
      strtofloat(editLower.Text);
    except
      MessageDlg('Lower Limit must be Integer',mtError, [mbCancel],0);
      Exit;
    end;
  end;

  try
    strtofloat(editUpper.Text);
  except
    MessageDlg('Upper Limit must be Integer',mtError, [mbCancel],0);
    Exit;
  end;

  If MaintainType = 'Append' Then
  begin
     // �ˬd Process �O�_�w���]�w
     With fDPPM.QryTemp do
     begin
        Close;
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
        Params.CreateParam(ftString	,'MODEL_NAME', ptInput);
        CommandText := 'Select MODEL_ID '+
                       'From SAJET.SYS_MODEL '+
                       'Where MODEL_NAME = :MODEL_NAME ';
        Params.ParamByName('MODEL_NAME').AsString := cmbmodel.Text;
        Open;
        MODELID := FieldByName('MODEL_ID').AsString;

        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'PROCESS_ID', ptInput);
        Params.CreateParam(ftString	,'MODEL_ID', ptInput);
        CommandText := 'Select PROCESS_ID,LOWER_LIMIT,UPPER_LIMIT '+
                       'From SAJET.SYS_MODEL_PROCESS_RATE '+
                       'Where PROCESS_ID = :PROCESS_ID '+
                       'and MODEL_ID = :MODEL_ID ';
        Params.ParamByName('PROCESS_ID').AsString := ProcessID;
        Params.ParamByName('MODEL_ID').AsString := MODELID;
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'Line : '+ cmbmodel.Text + #13#10 +
                'Process : '+ cmbProcess.Text ;
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
           Params.CreateParam(ftString	,'PROCESS_ID', ptInput);
           Params.CreateParam(ftString	,'LOWER_LIMIT', ptInput);
           Params.CreateParam(ftString	,'UPPER_LIMIT', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'MODEL_ID', ptInput);
           CommandText := 'Insert Into SAJET.SYS_MODEL_PROCESS_RATE '+
                          ' (PROCESS_ID,LOWER_LIMIT,UPPER_LIMIT,UPDATE_USERID,MODEL_ID) '+
                          'Values (:PROCESS_ID,:LOWER_LIMIT,:UPPER_LIMIT,:UPDATE_USERID,:MODEL_ID) ';
           Params.ParamByName('PROCESS_ID').AsString := ProcessID;
           Params.ParamByName('LOWER_LIMIT').AsString := trim(editLower.Text);
           Params.ParamByName('UPPER_LIMIT').AsString := trim(editUpper.Text);
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Params.ParamByName('MODEL_ID').AsString := MODELID;
           Execute;
           fDPPM.CopyToHistory(MODELID,ProcessID);
        end;
     Except
       on E:Exception do
       begin
         MessageDlg('Database Error !!'+#13#10 +
                    E.Message ,mtError, [mbCancel],0);
         Exit;
       end;
     end;

     MessageDlg('DPPM Data Append OK!!',mtCustom, [mbOK],0);
     UpdateSuccess := True;
     If MessageDlg('Append Other DPPM Data ?',mtCustom, mbOKCancel,0) <> mrOK Then
        ModalResult := mrOK
     else
     begin
        cmbProcess.ItemIndex:=-1;
        editLower.Text := '';
        editUpper.Text := '';
        cmbProcess.SetFocus ;
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
           Params.CreateParam(ftString	,'LOWER_LIMIT', ptInput);
           Params.CreateParam(ftString	,'UPPER_LIMIT', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'PROCESS_ID', ptInput);
           Params.CreateParam(ftString	,'MODEL_ID', ptInput);
           CommandText := 'Update SAJET.SYS_MODEL_PROCESS_RATE '+
                          'Set LOWER_LIMIT = :LOWER_LIMIT,'+
                              'UPPER_LIMIT = :UPPER_LIMIT,'+
                              //'FPY_GOAL = :FPY_GOAL, '+
                              'UPDATE_USERID = :UPDATE_USERID,'+
                              'UPDATE_TIME = SYSDATE '+
                          'Where PROCESS_ID = :PROCESS_ID '+
                          'and MODEL_ID = :MODEL_ID ';
           Params.ParamByName('LOWER_LIMIT').AsString := trim(editLower.Text);
           Params.ParamByName('UPPER_LIMIT').AsString := trim(editUpper.Text);
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Params.ParamByName('PROCESS_ID').AsString := ProcessID;
           Params.ParamByName('MODEL_ID').AsString := MODELID;
           Execute;
           fDPPM.CopyToHistory(MODELID,ProcessID);
           MessageDlg('DPPM Data Update OK!!',mtCustom, [mbOK],0);
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
