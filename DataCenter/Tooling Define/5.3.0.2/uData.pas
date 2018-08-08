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
    Label2: TLabel;
    editToolDesc: TEdit;
    LabType2: TLabel;
    LabType1: TLabel;
    Imagemain: TImage;
    Label8: TLabel;
    editMaxUsedCnt: TEdit;
    Label9: TLabel;
    editLimitUsedCnt: TEdit;
    Label10: TLabel;
    editToolNo: TEdit;
    Label1: TLabel;
    editToolName: TEdit;
    Label5: TLabel;
    editUsedTime: TEdit;
    Label7: TLabel;
    editWarnDay: TEdit;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label3: TLabel;
    combType: TComboBox;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure editMaxUsedCntKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    MaintainType : String;
    TOOLID : String;
    UpdateSuccess : Boolean;
    Function GetMaxToolID : String;
    procedure SetTheRegion;
    procedure GetToolingType;
  end;

var
  fData: TfData;

implementation

uses uformMain;

{$R *.DFM}

procedure TfData.GetToolingType;
begin
   combType.Items.Clear;
   with formMain.QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select Tooling_Type '
                   + '  From SAJET.SYS_TOOLING '
                   + ' Where Enabled = ''Y'' '
                   + ' Group by Tooling_Type '
                   + ' Order By Tooling_Type ';
      Open;
      while not Eof do
      begin
         combType.Items.Add(FieldByName('Tooling_Type').AsString);
         Next;
      end;
      Close;
   end;
end;


procedure TfData.sbtnCancelClick(Sender: TObject);
begin
  If UpdateSuccess Then
    ModalResult := mrOK
  Else
    Close;
end;

procedure TfData.FormCreate(Sender: TObject);
begin
  SetTheRegion;
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

Function TfData.GetMaxToolID : String;
Var DBID : String;
begin
  With formMain.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select NVL(Max(TOOLING_ID),0) + 1 TOOLID '+
                   'From SAJET.SYS_TOOLING ' ;
    Open;
    If Fieldbyname('TOOLID').AsString = '1' Then
    begin
       Close;
       CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),5,''0'') || ''001'' TOOLID '+
                      'From SAJET.SYS_BASE '+
                      'Where PARAM_NAME = ''DBID'' ' ;
       Open;
    end;
    Result := Fieldbyname('TOOLID').AsString;
    Close;
  end;
end;

procedure TfData.sbtnSaveClick(Sender: TObject);
Var S : String; sToolId : String; I : Integer;
begin
  editToolNo.Text := Trim(editToolNo.Text);
  editToolName.Text := trim(editToolName.text);
  editToolDesc.Text := trim(editToolDesc.text);
  editMaxUsedCnt.Text := Trim(editMaxUsedCnt.Text);
  editLimitUsedCnt.Text := trim(editLimitUsedCnt.Text);
  editWarnDay.Text := trim(editWarnDay.Text);
  editUsedTime.Text := trim(editUsedTime.Text);
  combType.Text := Trim(combType.Text);
  
  If editToolNo.Text = '' Then
  begin
     MessageDlg('Tooling No Error !!',mtError, [mbCancel],0);
     editToolNo.SetFocus ;
     Exit;
  end;

  If editToolName.Text = '' Then
  begin
     MessageDlg('Tooling Name Error !!',mtError, [mbCancel],0);
     editToolName.SetFocus ;
     Exit;
  end;

  If MaintainType = 'Append' Then
  begin
     // 檢查 NO 是否重複
     With formMain.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'TOOLING_NO', ptInput);
        CommandText :=  'Select * '
                      + '  From SAJET.SYS_TOOLING '
                      + ' Where TOOLING_NO = :TOOLING_NO '
                      +'    and Rownum = 1 ';
        Params.ParamByName('TOOLING_NO').AsString := editToolNo.Text;
        Open;
        If RecordCount > 0 Then
        begin
           Close;
           MessageDlg('Tooling No Duplicate !!',mtError, [mbCancel],0);
           Exit;
        end;
     end;

     // 新增一筆治具紀錄
     I := 0;
     sToolId := '';
     While True do
     begin
       Try
         sToolId := GetMaxToolID;
         Break;
       Except
         Inc(I);  // try 10 次, 若抓不到, 則跳離開來
         If I >= 10 Then
            Break;
       end;
     end;

     If sToolId = '' Then
     begin
        MessageDlg('Database Error !!'+#13#10 +
                   'could not get Tooling Id !!' ,mtError, [mbCancel],0);
        Exit;
     end;

     Try
        With formMain.QryTemp do
        begin
          try
             Close;
             Params.Clear;
             Params.CreateParam(ftString	,'TOOLING_ID', ptInput);
             Params.CreateParam(ftString	,'TOOLING_NO', ptInput);
             Params.CreateParam(ftString	,'TOOLING_NAME', ptInput);
             Params.CreateParam(ftString	,'TOOLING_DESC', ptInput);
             Params.CreateParam(ftString	,'MAX_USED_COUNT', ptInput);
             Params.CreateParam(ftString	,'LIMIT_USED_COUNT', ptInput);
             Params.CreateParam(ftString	,'USED_TIME', ptInput);
             Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
             Params.CreateParam(ftString	,'WARNING_USED_TIME', ptInput);
             Params.CreateParam(ftString	,'TOOLING_TYPE', ptInput);
             CommandText := 'Insert Into SAJET.SYS_TOOLING '+
                            ' (TOOLING_ID,TOOLING_NO,TOOLING_NAME,TOOLING_DESC,MAX_USED_COUNT,LIMIT_USED_COUNT,USED_TIME,UPDATE_USERID,WARNING_USED_TIME,TOOLING_TYPE) '+
                            'Values '+
                            ' (:TOOLING_ID,:TOOLING_NO,:TOOLING_NAME,:TOOLING_DESC,:MAX_USED_COUNT,:LIMIT_USED_COUNT,:USED_TIME,:UPDATE_USERID,:WARNING_USED_TIME,:TOOLING_TYPE) ';
             Params.ParamByName('TOOLING_ID').AsString := sToolId;
             Params.ParamByName('TOOLING_NO').AsString := editToolNo.Text;
             Params.ParamByName('TOOLING_NAME').AsString := editToolName.Text;
             Params.ParamByName('TOOLING_DESC').AsString := editToolDesc.Text;
             Params.ParamByName('MAX_USED_COUNT').AsString := editMaxUsedCnt.Text;
             Params.ParamByName('LIMIT_USED_COUNT').AsString := editLimitUsedCnt.Text;
             Params.ParamByName('USED_TIME').AsString := editUsedTime.Text;
             Params.ParamByName('UPDATE_USERID').AsString := formMain.UpdateUserID;
             Params.ParamByName('WARNING_USED_TIME').AsString := editWarnDay.Text;
             Params.ParamByName('TOOLING_TYPE').AsString := combType.Text;
             Execute;
             formMain.CopyToHistory(sToolId);
          finally
             close;
          end;
        end;
     Except
        MessageDlg('Database Error !!'+#13#10 +
                   'could not save to Database !!' ,mtError, [mbCancel],0);
        Exit;
     end;

     MessageDlg('Tooling Data Append OK!!',mtCustom, [mbOK],0);
     UpdateSuccess := True;
     If MessageDlg('Append Other Tooling Data ?',mtCustom, mbOKCancel,0) <> mrOK Then
        ModalResult := mrOK
     else
     begin
        editToolNo.Text := '';
        editToolName.Text := '';
        editToolDesc.Text := '';
        editMaxUsedCnt.Text := '';
        editLimitUsedCnt.Text := '';
        editUsedTime.Text := '';
        editWarnDay.Text := '';
        combType.Text := '';
        editToolNo.SetFocus;
        GetToolingType;
        Exit;
     end;
     Exit;
  end;

  If MaintainType = 'Modify' Then
  begin
     // 檢查 No 是否重複
     With formMain.QryTemp do
     begin
       try
          Close;
          Params.Clear;
          Params.CreateParam(ftString	,'TOOLING_NO', ptInput);
          Params.CreateParam(ftString	,'TOOLING_ID', ptInput);
          CommandText := 'Select * '
                       + 'From SAJET.SYS_TOOLING '
                       + 'Where TOOLING_NO = :TOOLING_NO '
                       + 'and TOOLING_ID <> :TOOLING_ID ';
          Params.ParamByName('TOOLING_NO').AsString := editToolNo.Text;
          Params.ParamByName('TOOLING_ID').AsString := TOOLID;
          Open;
          If RecordCount > 0 Then
          begin
             Close;
             MessageDlg('Tooling No Duplicate !! ',mtError, [mbCancel],0);
             Exit;
          end;
       finally
          close;
       end;
     end;

     Try
        With formMain.QryTemp do
        begin
          try
             Close;
             Params.Clear;
             Params.CreateParam(ftString	,'TOOLING_NO', ptInput);
             Params.CreateParam(ftString	,'TOOLING_NAME', ptInput);
             Params.CreateParam(ftString	,'TOOLING_DESC', ptInput);
             Params.CreateParam(ftString	,'MAX_USED_COUNT', ptInput);
             Params.CreateParam(ftString	,'LIMIT_USED_COUNT', ptInput);
             Params.CreateParam(ftString	,'USED_TIME', ptInput);
             Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
             Params.CreateParam(ftString	,'WARNING_USED_TIME', ptInput);
             Params.CreateParam(ftString	,'TOOLING_TYPE', ptInput);
             Params.CreateParam(ftString	,'TOOLING_ID', ptInput);
             CommandText := 'Update SAJET.SYS_TOOLING '+
                            'Set TOOLING_NO = :TOOLING_NO,'+
                                'TOOLING_NAME = :TOOLING_NAME,'+
                                'TOOLING_DESC = :TOOLING_DESC,'+
                                'MAX_USED_COUNT = :MAX_USED_COUNT,'+
                                'LIMIT_USED_COUNT = :LIMIT_USED_COUNT,'+
                                'USED_TIME = :USED_TIME,'+
                                'UPDATE_USERID = :UPDATE_USERID,'+
                                'UPDATE_TIME = SYSDATE, '+
                                'WARNING_USED_TIME = :WARNING_USED_TIME, '+
                                'TOOLING_TYPE = :TOOLING_TYPE '+
                            'Where TOOLING_ID = :TOOLING_ID ';
             Params.ParamByName('TOOLING_NO').AsString :=editToolNo.Text;
             Params.ParamByName('TOOLING_NAME').AsString := editToolName.Text;
             Params.ParamByName('TOOLING_DESC').AsString := editToolDesc.Text;
             Params.ParamByName('MAX_USED_COUNT').AsString := editMaxUsedCnt.Text;
             Params.ParamByName('LIMIT_USED_COUNT').AsString := editLimitUsedCnt.Text;
             Params.ParamByName('USED_TIME').AsString := editUsedTime.Text;
             Params.ParamByName('UPDATE_USERID').AsString := formMain.UpdateUserID;
             Params.ParamByName('WARNING_USED_TIME').AsString := editWarnDay.Text;
             Params.ParamByName('TOOLING_TYPE').AsString := combType.Text;
             Params.ParamByName('TOOLING_ID').AsString := TOOLID;
             Execute;
             formMain.CopyToHistory(TOOLID);
             MessageDlg('Tooling Data Update OK!!',mtCustom, [mbOK],0);
             ModalResult := mrOK;
           finally
             close;
           end;
        end;
     Except
        MessageDlg('Database Error !!'+#13#10 +
                   'could not Update Database !!' ,mtError, [mbCancel],0);
        Exit;
     end;
  End;
end;

procedure TfData.editMaxUsedCntKeyPress(Sender: TObject; var Key: Char);
begin
  if not (key in ['0'..'9',#8]) then key:=#0;
end;

procedure TfData.FormShow(Sender: TObject);
begin
   GetToolingType;
end;

end.
