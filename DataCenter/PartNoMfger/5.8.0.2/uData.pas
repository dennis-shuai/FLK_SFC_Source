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
    Label1: TLabel;
    EditMfgername: TEdit;
    Editmfgerpartno: TEdit;
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
    PARTMFGERID,partID,LocateID : String;
    procedure SetTheRegion;
    Function GetMaxPartMfgerID : String;
  end;

var
  fData: TfData;

implementation

{$R *.DFM}
uses uDPPM;

Function TfData.GetMaxPartMfgerID : String;
Var DBID : String;
begin
  With fDPPM.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select NVL(Max(part_mfger_ID),0) + 1 partmfgerID '+
                   'From SAJET.SYS_part_mfger ' ;
    Open;
    If Fieldbyname('partmfgerID').AsString = '1' Then
    begin
       Close;
       CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),5,''0'') || ''001'' partmfgerID '+
                      'From SAJET.SYS_BASE '+
                      'Where PARAM_NAME = ''DBID'' ' ;
       Open;
    end;
    Result := Fieldbyname('partmfgerID').AsString;
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
  if trim(editmfgername.Text)='' then
  begin
     MessageDlg('Please input Mfger_Name!!'+#13#10,mtError, [mbCancel],0);
     editmfgername.SelectAll ;
     editmfgername.SetFocus ;
     exit;
  end;

  if trim(editmfgerpartno.Text)='' then
  begin
     MessageDlg('Please input Mfger_part_no!!'+#13#10,mtError, [mbCancel],0);
     editmfgerpartno.SelectAll ;
     editmfgerpartno.SetFocus ;
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
        params.CreateParam(ftstring,'mfger_name',ptinput);
        params.CreateParam(ftstring,'mfger_part_no',ptinput); 
        CommandText := 'Select * '+
                       'From SAJET.SYS_part_MFGER '+
                       'Where part_ID = :part_ID '+
                       'and mfger_name = :mfger_name '+
                       ' and mfger_part_no =:mfger_part_no ';
        Params.ParamByName('part_ID').AsString := partID;
        Params.ParamByName('mfger_name').AsString := trim(editmfgername.Text);
        params.ParamByName('mfger_part_no').AsString :=trim(editmfgerpartno.Text);
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'part_no : '+ editpartno.Text+ #13#10 +
                'mfger_name'+editmfgername.Text+#13#10 +
                'mfger_part_no'+editmfgerpartno.Text  ;
           Close;
           MessageDlg(S,mtError, [mbCancel],0);
           Exit;
        end;
     end;

     I := 0;
     partmfgerId := '';
     While True do
     begin
       Try
         partmfgerId := GetMaxpartmfgerID;
         Break;
       Except
         Inc(I);  // try 10 次, 若抓不到, 則跳離開來
         If I >= 10 Then
            Break;
       end;
     end;

     If partmfgerId = '' Then
     begin
        MessageDlg('Database Error !!'+#13#10 +
                   'could not get part_mfger_id Id !!' ,mtError, [mbCancel],0);
        Exit;
     end;


     Try
        With fDPPM.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'part_mfger_ID', ptInput);
           Params.CreateParam(ftString	,'part_ID', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'mfger_name', ptInput);
           Params.CreateParam(ftString	,'mfger_part_no', ptInput);
           CommandText := 'Insert Into SAJET.SYS_part_mfger '+
                          ' (part_mfger_id,part_ID,mfger_name,mfger_part_no,UPDATE_USERID,update_time) '+
                          'Values (:part_mfger_id,:part_ID,:mfger_name,:mfger_part_no,:UPDATE_USERID,sysdate) ';
           Params.ParamByName('part_mfger_ID').AsString := partmfgerID;
           Params.ParamByName('part_ID').AsString := partID;
           params.ParamByName('mfger_name').AsString :=trim(editmfgername.Text);
           params.ParamByName('mfger_part_no').AsString :=trim(editmfgerpartno.Text);  
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Execute;
           fDPPM.CopyToHistory(partmfgerid);
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
           Params.CreateParam(ftString	,'part_mfger_ID', ptInput);
           params.CreateParam(ftstring,'mfger_name',ptinput);
           params.CreateParam(ftstring,'mfger_part_no',ptinput);
           CommandText := 'Update SAJET.SYS_part_mfger '+
                          'Set mfger_name=:mfger_name, '+
                          'mfger_part_no=:mfger_part_no ,'+
                          ' UPDATE_USERID = :UPDATE_USERID,'+
                          'UPDATE_TIME = SYSDATE '+
                          'Where part_mfger_ID = :part_mfger_ID ';
           Params.ParamByName('mfger_name').AsString := trim(editmfgername.Text);
           params.ParamByName('mfger_part_no').AsString :=trim(editmfgerpartno.Text);
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Params.ParamByName('part_mfger_ID').AsString := partmfgerID;
           Execute;
           fDPPM.CopyToHistory(partmfgerid);
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
