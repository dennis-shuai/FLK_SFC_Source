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
    Label2: TLabel;
    Label5: TLabel;
    EditPARTNO: TEdit;
    Edittoolingsn: TEdit;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure EditPARTNOKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    MaintainType : String;
    UpdateSuccess : Boolean;
    partID,toolingsnID : String;
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
 

  editpartno.Clear ;
  edittoolingsn.Clear ;
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
  If trim(edittoolingsn.Text)='' Then
  begin
     MessageDlg('tooling sn Error !!',mtError, [mbCancel],0);
     edittoolingsn.SetFocus ;
     Exit;
  end;

  if trim(editpartno.Text)='' then
  begin
     MessageDlg('part no Error !!',mtError, [mbCancel],0);
     editpartno.SetFocus ;
     Exit;
  end;

  If MaintainType = 'Append' Then
  begin
     // 檢查 Process 是否已有設定
     With fDPPM.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'TOOLING_SN', ptInput);
        CommandText := 'SELECT b.tooling_sn,b.tooling_sn_id '
                      +' FROM  SAJET.SYS_TOOLING A,SAJET.SYS_TOOLING_SN B,SAJET.G_TOOLING_SN_STATUS C  '
                      +' WHERE  B.TOOLING_SN=:tooling_sn AND  A.TOOLING_ID=B.TOOLING_ID AND B.TOOLING_SN_ID=C.TOOLING_SN_ID  '
                      +' AND A.TOOLING_TYPE LIKE ''STENCIL%'' AND A.ENABLED=''Y'' AND B.ENABLED=''Y'' AND C.STATUS=''Y'' ';
        Params.ParamByName('TOOLING_SN').AsString := edittoolingsn.Text;
        Open;
        if isempty then
        begin
          Close;
           MessageDlg('Tooling SN NOT FIND!',mtError, [mbCancel],0);
           edittoolingsn.SelectAll ;
           edittoolingsn.SetFocus ;
           Exit;
        end;
        toolingsnid := FieldByName('tooling_sn_ID').AsString;

        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'part_NO', ptInput);
        CommandText := 'Select part_ID '+
                       'From SAJET.SYS_part '+
                       'Where part_NO = :part_NO ';
        Params.ParamByName('part_NO').AsString := editpartno.Text;
        Open;
        if isempty then
        begin
          Close;
           MessageDlg('PART_NO NOT FIND!',mtError, [mbCancel],0);
           editpartno.SelectAll ;
           editpartno.SetFocus ;
           Exit;
        end;
        partID := FieldByName('part_ID').AsString;

        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'tooling_sn_ID', ptInput);
        Params.CreateParam(ftString	,'part_ID', ptInput);
        CommandText := 'Select tooling_sn_ID '+
                       'From SAJET.SYS_part_stencil '+
                       'Where tooling_sn_ID = :tooling_sn_ID '+
                       'and part_ID = :part_ID ';
        Params.ParamByName('tooling_sn_ID').AsString := toolingsnid;
        Params.ParamByName('part_ID').AsString := partID;
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'TOOLING SN  : '+ EDITTOOLINGSN.Text + #13#10 +
                'PART NO : '+ EDITPARTNO.Text  ;
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
           Params.CreateParam(ftString	,'TOOLING_SN_ID', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'PART_ID', ptInput);
           CommandText := 'Insert Into SAJET.SYS_PART_STENCIL '+
                          ' (TOOLING_SN_ID,UPDATE_USERID,PART_ID) '+
                          'Values (:TOOLING_SN_ID,:UPDATE_USERID,:PART_ID) ';
           Params.ParamByName('TOOLING_SN_ID').AsString := TOOLINGSNID;
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Params.ParamByName('PART_ID').AsString := PARTID;
           Execute;
           fDPPM.CopyToHistory(PARTID,TOOLINGSNID);
        end;
     Except
       on E:Exception do
       begin
         MessageDlg('Database Error !!'+#13#10 +
                    E.Message ,mtError, [mbCancel],0);
         Exit;
       end;
     end;

     MessageDlg('PART NO  Data Append OK!!',mtCustom, [mbOK],0);
     UpdateSuccess := True;
     If MessageDlg('Append Other PART NO Data ?',mtCustom, mbOKCancel,0) <> mrOK Then
        ModalResult := mrOK
     else
     begin
        editpartno.Clear ;
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
           Params.CreateParam(ftString	,'tooling_sn_ID', ptInput);
           Params.CreateParam(ftString	,'part_ID', ptInput);
           CommandText := 'Update SAJET.SYS_part_stencil '+
                          'Set    '+
                              'UPDATE_USERID = :UPDATE_USERID,'+
                              'UPDATE_TIME = SYSDATE '+
                          'Where tooling_sn_ID = :tooling_sn_ID '+
                          'and part_ID = :part_ID ';
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Params.ParamByName('tooling_sn_ID').AsString := toolingsnID;
           Params.ParamByName('part_ID').AsString := partID;
           Execute;
           fDPPM.CopyToHistory(partid,toolingsnid);
           MessageDlg('part no Data Update OK!!',mtCustom, [mbOK],0);
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

procedure TfData.EditPARTNOKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if trim(editpartno.Text)='' then exit;
   if key=13 then
   begin
     With fDPPM.QryTemp do
     begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'part_no',ptinput);
       commandtext:='select * from sajet.sys_part where part_no=:part_no and rownum=1';
       params.ParamByName('part_no').AsString :=editpartno.Text ;
       open;
       if isempty then
       begin
          MessageDlg('Not Find The part no:'+editpartno.Text,mtError, [mbCancel],0);
          editpartno.SelectAll ;
          editpartno.SetFocus ;
          exit;
       end;
       if fieldbyname('enabled').AsString='N' Then
       begin
          MessageDlg('The part no:'+editpartno.Text+' Is Disabled!',mtError, [mbCancel],0);
          editpartno.SelectAll ;
          editpartno.SetFocus ;
          exit;
       end;
     end;
   end;
end;

end.
