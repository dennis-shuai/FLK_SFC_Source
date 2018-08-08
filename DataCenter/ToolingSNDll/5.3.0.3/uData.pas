unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB;

type
  TfData = class(TForm)
    sbtnCancel: TSpeedButton;
    sbtnSave: TSpeedButton;
    Label3: TLabel;
    Image5: TImage;
    Label4: TLabel;
    Image1: TImage;
    LabType2: TLabel;
    LabType1: TLabel;
    Imagemain: TImage;
    Label10: TLabel;
    editToolSN: TEdit;
    Label1: TLabel;
    LabToolNo: TLabel;
    LabToolID: TLabel;
    Label2: TLabel;
    LabToolName: TLabel;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure editToolSNKeyPress(Sender: TObject; var Key: Char);
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
  end;

var
  fData: TfData;

implementation

uses uformMain;

{$R *.DFM}


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
    CommandText := 'Select NVL(Max(TOOLING_SN_ID),0) + 1 TOOLID '+
                   'From SAJET.SYS_TOOLING_SN' ;
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
  editToolSN.Text := Trim(editToolSN.Text);

  If editToolSN.Text = '' Then
  begin
     MessageDlg('Tooling SN Error !!',mtError, [mbCancel],0);
     editToolSN.SetFocus ;
     Exit;
  end;
  
  If MaintainType = 'Append' Then
  begin
     // 檢查 NO 是否重複
     With formMain.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'TOOLING_SN', ptInput);
        CommandText :=  'Select * '
                      + '  From SAJET.SYS_TOOLING_SN '
                      + ' Where TOOLING_SN = :TOOLING_SN '
                      +'    and Rownum = 1 ';
        Params.ParamByName('TOOLING_SN').AsString := editToolSN.Text;
        Open;
        If RecordCount > 0 Then
        begin
           Close;
           MessageDlg('Tooling SN Duplicate !!',mtError, [mbCancel],0);
           editToolSN.SetFocus;
           editToolSN.Selectall;
           Exit;
        end;
     end;
     With formMain.SProc do
     begin
       Try
          Close;
          DataRequest('SAJET.SJ_TOOLING_SN_INSERT');
          FetchParams;
          Params.ParamByName('T_TOOLING_ID').AsString := LabToolID.Caption;
          Params.ParamByName('T_TOOLING_SN').AsString := editToolSN.Text;
          Params.ParamByName('T_EMP_ID').AsString := formMain.UpdateUserID;
          Execute;
          if Params.ParamByName('TRES').AsString <>'OK' then
          begin
            MessageDlg(Params.ParamByName('TRES').AsString ,mtError, [mbCancel],0);
            Exit;
          end;
        finally
         close;
        end;
     end;//end sproc
     //MessageDlg('Tooling SN Data Append OK!!',mtCustom, [mbOK],0);
     UpdateSuccess := True;
     {If MessageDlg('Append Other Tooling SN Data ?',mtCustom, mbOKCancel,0) <> mrOK Then
        ModalResult := mrOK
     else
     begin }
       editToolSN.Text := '';
       editToolSN.SetFocus;
       Exit;
     //end; 
  end;

  If MaintainType = 'Modify' Then
  begin
     // 檢查 No 是否重複
     With formMain.QryTemp do
     begin
       try
          Close;
          Params.Clear;
          Params.CreateParam(ftString	,'TOOLING_SN', ptInput);
          Params.CreateParam(ftString	,'TOOLING_SN_ID', ptInput);
          CommandText := 'Select * '
                       + 'From SAJET.SYS_TOOLING_SN '
                       + 'Where TOOLING_SN = :TOOLING_SN '
                       + 'and TOOLING_SN_ID <> :TOOLING_SN_ID ';
          Params.ParamByName('TOOLING_SN').AsString := editToolSN.Text;
          Params.ParamByName('TOOLING_SN_ID').AsString := TOOLID;
          Open;
          If RecordCount > 0 Then
          begin
             Close;
             MessageDlg('Tooling SN Duplicate !! ',mtError, [mbCancel],0);
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
             Params.CreateParam(ftString	,'TOOLING_SN', ptInput);
             Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
             Params.CreateParam(ftString	,'TOOLING_SN_ID', ptInput);
             CommandText := 'Update SAJET.SYS_TOOLING_SN '+
                            'Set TOOLING_SN = :TOOLING_SN,'+
                                'UPDATE_USERID = :UPDATE_USERID,'+
                                'UPDATE_TIME = SYSDATE '+
                            'Where TOOLING_SN_ID = :TOOLING_SN_ID ';
             Params.ParamByName('TOOLING_SN').AsString :=editToolSN.Text;
             Params.ParamByName('UPDATE_USERID').AsString := formMain.UpdateUserID;
             Params.ParamByName('TOOLING_SN_ID').AsString := TOOLID;
             Execute;
             formMain.CopyToHistory(TOOLID);
             MessageDlg('Tooling SN Data Update OK!!',mtCustom, [mbOK],0);
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

procedure TfData.editToolSNKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    sbtnSaveClick(self);
  end;
end;

end.
