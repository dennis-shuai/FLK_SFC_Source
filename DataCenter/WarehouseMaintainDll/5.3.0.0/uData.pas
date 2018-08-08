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
    editWHName: TEdit;
    Label1: TLabel;
    editWHDesc: TEdit;
    Label5: TLabel;
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
    WHID : String;
    UpdateSuccess : Boolean;
    function  GetMaxWHID : String;
    procedure SetTheRegion;
  end;

var
  fData: TfData;

implementation

{$R *.DFM}

uses uLocate;

procedure TfData.sbtnCancelClick(Sender: TObject);
begin
  if UpdateSuccess then
    ModalResult := mrOK
  else
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

function TfData.GetMaxWHID : String;
begin
  With fLocate.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT NVL(MAX(WAREHOUSE_ID), 0) + 1 WAREHOUSEID '+
                   '  FROM SAJET.SYS_WAREHOUSE ';
    Open;
    if Fieldbyname('WAREHOUSEID').AsString = '1' Then
    begin
      Close;
      CommandText := 'SELECT RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || ''000001'' WAREHOUSEID '+
                     '  FROM SAJET.SYS_BASE '+
                     ' WHERE PARAM_NAME = ''DBID'' ' ;
      Open;
    end;
    Result := Fieldbyname('WAREHOUSEID').AsString;
    Close;
  end;
end;

procedure TfData.sbtnSaveClick(Sender: TObject);
var
  S, sWHID : String;
  I : Integer;
begin
  if Trim(editWHName.Text) = '' then
  begin
     MessageDlg('Warehouse Error !!', mtError, [mbCancel], 0);
     editWHName.SetFocus ;
     Exit;
  end;

  if MaintainType = 'Append' then
  begin
     // 檢查 NO 是否重複
     with fLocate.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'WAREHOUSE_NAME', ptInput);
        CommandText := 'SELECT WAREHOUSE_ID, WAREHOUSE_NAME, WAREHOUSE_DESC '+
                       '  FROM SAJET.SYS_WAREHOUSE '+
                       ' WHERE WAREHOUSE_NAME = :WAREHOUSE_NAME ';
        Params.ParamByName('WAREHOUSE_NAME').AsString := editWHName.Text;
        Open;
        if RecordCount > 0 then
        begin
           S := 'Warehouse Duplicate !! ' + #13#10 +
                'Warehouse Name : ' + Fieldbyname('WAREHOUSE_NAME').AsString + #13#10 +
                'Warehouse Desc : ' + Fieldbyname('WAREHOUSE_DESC').AsString;
           Close;
           MessageDlg(S, mtError, [mbCancel], 0);
           Exit;
        end;
     end;
     // 新增一筆不良紀錄
     I := 0;
     sWHID := '';
     while True do
     begin
       try
         sWHID := GetMaxWHID;
         Break;
       except
         Inc(I);  // try 10 次, 若抓不到, 則跳離開來
         if I >= 10 then
            Break;
       end;
     end;

     if sWHID = '' then
     begin
        MessageDlg('Database Error !!' + #13#10 +
                   'could not get Warehouse ID !!', mtError, [mbCancel], 0);
        Exit;
     end;

     try
        with fLocate.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'WAREHOUSE_ID', ptInput);
           Params.CreateParam(ftString	,'WAREHOUSE_NAME', ptInput);
           Params.CreateParam(ftString	,'WAREHOUSE_DESC', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           CommandText := 'INSERT INTO SAJET.SYS_WAREHOUSE '+
                          '(WAREHOUSE_ID, WAREHOUSE_NAME, WAREHOUSE_DESC, UPDATE_USERID) VALUES '+
                          '(:WAREHOUSE_ID, :WAREHOUSE_NAME, :WAREHOUSE_DESC, :UPDATE_USERID) ';
           Params.ParamByName('WAREHOUSE_ID').AsString := sWHID;
           Params.ParamByName('WAREHOUSE_NAME').AsString := editWHName.Text;
           Params.ParamByName('WAREHOUSE_DESC').AsString := editWHDesc.Text;
           Params.ParamByName('UPDATE_USERID').AsString := fLocate.UpdateUserID;
           Execute;
        end;
     except
        MessageDlg('Database Error !!'+#13#10 +
                   'could not save to Database !!' ,mtError, [mbCancel],0);
        Exit;
     end;

     MessageDlg('Warehouse Data Append OK!!', mtCustom, [mbOK], 0);
     UpdateSuccess := True;
     if MessageDlg('Append Other Warehouse Data ?', mtCustom, mbOKCancel, 0) <> mrOK then
        ModalResult := mrOK
     else
     begin
        editWHName.Text := '';
        editWHDesc.Text := '';
        editWHName.SetFocus ;
        Exit;
     end;
     Exit;
  end;

  if MaintainType = 'Modify' then
  begin
     // 檢查 NO 是否重複
     with fLocate.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'WAREHOUSE_NAME', ptInput);
        Params.CreateParam(ftString	,'WAREHOUSE_ID', ptInput);
        CommandText := 'SELECT WAREHOUSE_ID, WAREHOUSE_NAME, WAREHOUSE_DESC '+
                       '  FROM SAJET.SYS_WAREHOUSE '+
                       ' WHERE WAREHOUSE_NAME = :WAREHOUSE_NAME '+
                       '   AND WAREHOUSE_ID <> :WAREHOUSE_ID ';
        Params.ParamByName('WAREHOUSE_NAME').AsString := editWHName.Text;
        Params.ParamByName('WAREHOUSE_ID').AsString := WHID;
        Open;
        if RecordCount > 0 then
        begin
           S := 'Warehouse Duplicate !! ' + #13#10 +
                'Warehouse Name : ' + Fieldbyname('WAREHOUSE_NAME').AsString + #13#10 +
                'Warehouse Desc : ' + Fieldbyname('WAREHOUSE_DESC').AsString;
           Close;
           MessageDlg(S,mtError, [mbCancel],0);
           Exit;
        end;
     end;

     try
        with fLocate.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'WAREHOUSE_NAME', ptInput);
           Params.CreateParam(ftString	,'WAREHOUSE_DESC', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'WAREHOUSE_ID', ptInput);
           CommandText := 'UPDATE SAJET.SYS_WAREHOUSE '+
                          '   SET WAREHOUSE_NAME = :WAREHOUSE_NAME, '+
                          '       WAREHOUSE_DESC = :WAREHOUSE_DESC, '+
                          '       UPDATE_USERID = :UPDATE_USERID, '+
                          '       UPDATE_TIME = SYSDATE '+
                          ' WHERE WAREHOUSE_ID = :WAREHOUSE_ID ';
           Params.ParamByName('WAREHOUSE_NAME').AsString := editWHName.Text;
           Params.ParamByName('WAREHOUSE_DESC').AsString := editWHDesc.Text;
           Params.ParamByName('UPDATE_USERID').AsString := fLocate.UpdateUserID;
           Params.ParamByName('WAREHOUSE_ID').AsString := WHID;
           Execute;
           
           MessageDlg('Warehouse Data Update OK!!', mtCustom, [mbOK], 0);
           ModalResult := mrOK;
        end;
     except
        MessageDlg('Database Error !!' + #13#10 +
                   'could not Update Database !!', mtError, [mbCancel], 0);
        Exit;
     end;
  end;
end;

end.
