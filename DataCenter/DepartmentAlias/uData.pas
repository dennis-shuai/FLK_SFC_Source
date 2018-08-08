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
    cmbmodel: TComboBox;
    Label1: TLabel;
    Editempname: TEdit;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure cmbmodelChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    {procedure EditempNOKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);}
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    MaintainType : String;
    Authoritys,AuthorityRole : String;
    UpdateSuccess : Boolean;
    procedure SetTheRegion;
  end;

var
  fData: TfData;

implementation

{$R *.DFM}
uses Unit1 ;

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

  with MainForm.QryTemp do
  begin
    close;
    Params.Clear;
    CommandText := 'Select A.ALIAS_CODE,a.ALIAS_NAME '+
                   'From SAJET.SYS_ALIAS a '+
                   'Where a.Enabled = ''Y'' '+
                   'Order by a.ALIAS_NAME ';
    Open;
    cmbmodel.Clear;
    while not Eof do
    begin
      cmbmodel.Items.Add(FieldByName('ALIAS_CODE').AsString);
      Next;
    end;
  end;

  editempname.Clear ;
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
Var S : String; //I : Integer;
begin
  If cmbmodel.Text ='' Then
  begin
     MessageDlg('Dept Code Error !!',mtError, [mbCancel],0);
     cmbmodel.SetFocus ;
     Exit;
  end;

  if editempname.Text='' then
  begin
     MessageDlg('Dept Name Error !!',mtError, [mbCancel],0);
     cmbmodel.SetFocus ;
     Exit;
  end;

  If MaintainType = 'Append' Then
  begin
     // 檢查 Process 是否已有設定
     With MainForm.QryTemp do
     begin

        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'ALIAS_CODE', ptInput);
        Params.CreateParam(ftString	,'ALIAS_NAME', ptInput);
        CommandText := 'Select ALIAS_CODE '+
                       'From SAJET.SYS_ALIAS '+
                       'Where ALIAS_CODE = :ALIAS_CODE '+
                       'and ALIAS_NAME = :ALIAS_NAME ';
        Params.ParamByName('ALIAS_CODE').AsString := cmbmodel.Text ;
        Params.ParamByName('ALIAS_NAME').AsString := Editempname.Text;
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'ALIAS_CODE  : '+ cmbmodel.Text + #13#10 +
                'ALIAS_NAME : '+ Editempname.Text ;
           Close;
           MessageDlg(S,mtError, [mbCancel],0);
           Exit;
        end;
     end;

     Try
        With MainForm.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'ALIAS_CODE', ptInput);
           Params.CreateParam(ftString	,'ALIAS_NAME', ptInput);
           CommandText := 'Insert Into SAJET.SYS_ALIAS '+
                          ' (ALIAS_CODE,ALIAS_NAME) '+
                          'Values (:ALIAS_CODE,:ALIAS_NAME) ';
           Params.ParamByName('ALIAS_CODE').AsString := cmbmodel.Text ;
           Params.ParamByName('ALIAS_NAME').AsString := Editempname.Text;
           Execute;
        end;
     Except
       on E:Exception do
       begin
         MessageDlg('Database Error !!'+#13#10 +
                    E.Message ,mtError, [mbCancel],0);
         Exit;
       end;
     end;

     MessageDlg('Alias_Code Data Append OK!!',mtCustom, [mbOK],0);
     UpdateSuccess := True;
     If MessageDlg('Append Other Alias_Code Data ?',mtCustom, mbOKCancel,0) <> mrOK Then
        ModalResult := mrOK
     else
     begin
        cmbmodel.Clear ;
        Editempname.Clear ;
        Editempname.SetFocus ;
        Exit;
     end;
     Exit;
  end;

  If MaintainType = 'Modify' Then
  begin
     Try
        With MainForm.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'ALIAS_CODE', ptInput);
           Params.CreateParam(ftString	,'ALIAS_NAME', ptInput);
           CommandText := 'Update SAJET.SYS_ALIAS '+
                          'Set    '+
                              'ALIAS_CODE = :ALIAS_CODE,'+
                              'ALIAS_NAME = ALIAS_NAME '+
                          'Where ALIAS_CODE = :ALIAS_CODE '+
                          'and ALIAS_NAME = :ALIAS_NAME ';
           Params.ParamByName('ALIAS_CODE').AsString := cmbmodel.Text ;
           Params.ParamByName('ALIAS_NAME').AsString := Editempname.Text ;
           Execute;
           MessageDlg('Alias Data Update OK!!',mtCustom, [mbOK],0);
           ModalResult := mrOK;
        end;

        editempname.Clear ;
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

procedure TfData.cmbmodelChange(Sender: TObject);
begin
   Try
      With MainForm.QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString	,'ALIAS_CODE', ptInput);
         CommandText := 'SELECT ALIAS_NAME FROM SAJET.SYS_ALIAS WHERE ALIAS_CODE=:ALIAS_CODE ';
         Params.ParamByName('ALIAS_CODE').AsString := cmbmodel.Text ;
         Open;
         Editempname.Text := Fieldbyname('ALIAS_NAME').AsString;
      end;
   Except
     on E:Exception do
     begin
       MessageDlg('Database Error !!'+#13#10 +
                  E.Message ,mtError, [mbCancel],0);
       Exit;
     end;  
   end;

end;

procedure TfData.FormShow(Sender: TObject);
begin
  If MaintainType = 'Append' Then
    cmbmodel.Style := csDropDown 
  else if  MaintainType = 'Modify' Then
    cmbmodel.Style :=  csDropDownList ;
end;

end.
