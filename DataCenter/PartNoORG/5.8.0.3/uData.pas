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
    cmbOrg: TComboBox;
    Label5: TLabel;
    Label1: TLabel;
    CmBStock: TComboBox;
    Cmblocate: TComboBox;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure CmBStockChange(Sender: TObject);
    procedure CmblocateChange(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    MaintainType : String;
    UpdateSuccess : Boolean;
    FactoryID,partID,LocateID : String;
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
    CommandText := 'Select a.warehouse_Name '+
                   'From SAJET.SYS_warehouse a '+
                   'Where a.Enabled = ''Y'' '+
                   'Order by a.warehouse_Name ';
    Open;
    cmbstock.Clear;
    while not Eof do
    begin
      cmbstock.Items.Add(FieldByName('warehouse_Name').AsString);
      Next;
    end;
  end;

  with fDPPM.QryTemp do
  begin
    close;
    Params.Clear;
    CommandText := 'Select a.factory_code '+
                   'From SAJET.SYS_factory a '+
                   'Where a.Enabled = ''Y'' '+
                   'Order by a.factory_code ';
    Open;
    cmborg.Clear;
    while not Eof do
    begin
      cmborg.Items.Add(FieldByName('factory_code').AsString);
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
  If cmborg.ItemIndex = -1 Then
  begin
     MessageDlg('Factory Code Error !!',mtError, [mbCancel],0);
     cmborg.SetFocus ;
     Exit;
  end;

  If trim(editpartno.Text)='' Then
  begin
     MessageDlg('part_no Error !!',mtError, [mbCancel],0);
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
        Params.CreateParam(ftString	,'factory_code', ptInput);
        CommandText := 'Select factory_ID '+
                       'From SAJET.SYS_factory '+
                       'Where factory_code = :factory_code ';
        Params.ParamByName('factory_code').AsString := cmborg.Text;
        Open;
        if isempty then
        begin
           MessageDlg('ORG Data Error !!'+#13#10,mtError, [mbCancel],0);
           cmborg.SelectAll ;
           cmborg.SetFocus ;
           exit;
        end;
        factoryID := FieldByName('factory_ID').AsString;

        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'part_ID', ptInput);
        Params.CreateParam(ftString	,'factory_ID', ptInput);
        CommandText := 'Select part_ID,factory_id '+
                       'From SAJET.SYS_part_factory '+
                       'Where part_ID = :part_ID '+
                       'and factory_ID = :factory_ID ';
        Params.ParamByName('part_ID').AsString := partID;
        Params.ParamByName('factory_ID').AsString := factoryID;
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'factory code : '+ cmborg.Text + #13#10 +
                'part_no : '+ editpartno.Text ;
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
           Params.CreateParam(ftString	,'part_ID', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'factory_ID', ptInput);
           Params.CreateParam(ftString	,'locate_id', ptInput);
           CommandText := 'Insert Into SAJET.SYS_part_factory '+
                          ' (part_ID,factory_ID,locate_id,UPDATE_USERID,update_time) '+
                          'Values (:part_ID,:factory_ID,:locate_id,:UPDATE_USERID,sysdate) ';
           Params.ParamByName('part_ID').AsString := partID;
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Params.ParamByName('factory_ID').AsString := factoryID;
           Params.ParamByName('locate_id').AsString := locateid;
           Execute;
           fDPPM.CopyToHistory(factoryID,partID);
        end;
     Except
       on E:Exception do
       begin
         MessageDlg('Database Error !!'+#13#10 +
                    E.Message ,mtError, [mbCancel],0);
         Exit;
       end;
     end;

     MessageDlg('Part_no Data Append OK!!',mtCustom, [mbOK],0);
     UpdateSuccess := True;
     If MessageDlg('Append Other Part_no Data ?',mtCustom, mbOKCancel,0) <> mrOK Then
        ModalResult := mrOK
     else
     begin
        editpartno.SelectAll ;
       // cmborg.ItemIndex:=-1;
        cmbstock.ItemIndex:=-1;
        cmblocate.ItemIndex :=-1;
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
           Params.CreateParam(ftString	,'locate_id', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'part_ID', ptInput);
           Params.CreateParam(ftString	,'factory_ID', ptInput);
           CommandText := 'Update SAJET.SYS_part_factory '+
                          'Set locate_id = :locate_id , '+
                          ' UPDATE_USERID = :UPDATE_USERID,'+
                          'UPDATE_TIME = SYSDATE '+
                          'Where part_ID = :part_ID '+
                          'and factory_ID = :factory_ID ';
           Params.ParamByName('locate_id').AsString := locateid;
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Params.ParamByName('Part_ID').AsString := partID;
           Params.ParamByName('factory_ID').AsString := factoryID;
           Execute;
           fDPPM.CopyToHistory(factoryID,partID);
           MessageDlg('Part_no Data Update OK!!',mtCustom, [mbOK],0);
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

procedure TfData.CmBStockChange(Sender: TObject);
begin
  if Length(Trim(cmbStock.Text))=0 then exit;
  with fDPPM.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'warehouse_name', ptInput);
    CommandText := 'select a.locate_id, a.locate_name from sajet.sys_locate a,sajet.sys_warehouse b '
      + 'where b.warehouse_name = :warehouse_name and '
      + 'a.warehouse_id=b.warehouse_id and a.enabled = ''Y''  ';
    Params.ParamByName('warehouse_name').AsString := cmbStock.Text;
    Open;
    cmbLocate.Items.Clear;
    if isempty  then
    begin
      MessageDlg('Not Find locate !!'+#13#10,mtError, [mbCancel],0);
      Exit;
    end;
    while not Eof do
    begin
      cmbLocate.Items.Add(FieldByName('locate_name').AsString);
      Next;
    end;
    if cmbLocate.Items.Count = 1 then
      cmbLocate.ItemIndex := 0;
    Close;
  end;
end;

procedure TfData.CmblocateChange(Sender: TObject);
begin
     with fDPPM.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'warehouse_name', ptInput);
        if  trim(cmblocate.Text)<>'' then
             Params.CreateParam(ftString	,'locate_name', ptInput);
        CommandText := 'Select b.locate_ID '+
                       'From SAJET.SYS_warehouse a,sajet.sys_locate b '+
                       'Where a.warehouse_name=:warehouse_name  '+
                       ' and a.warehouse_id=b.warehouse_id and b.enabled=''Y'' ' ;
        if trim(cmblocate.Text)='' then
           commandtext:=commandtext+' and b.locate_name is null '
        else
           commandtext:=commandtext+' and b.locate_name=:locate_name ';
        Params.ParamByName('warehouse_name').AsString := cmbstock.Text;
        if  trim(cmblocate.Text)<>'' then
            Params.ParamByName('locate_name').AsString := cmblocate.Text;
        Open;
        if isempty then
        begin
           MessageDlg('Not Find locate !!'+#13#10,mtError, [mbCancel],0);
           Exit;
        end;
        Locateid := FieldByName('locate_ID').AsString;
    end ;
end;

end.
