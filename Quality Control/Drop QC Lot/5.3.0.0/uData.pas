unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DBCtrls, Db, DBClient,
  MConnect, SConnect, ObjBrkr, ComCtrls;

type
  TfData = class(TForm)
    sbtnExit: TSpeedButton;
    sbtnSave: TSpeedButton;
    LabType3: TLabel;
    Image5: TImage;
    Label4: TLabel;
    Image1: TImage;
    LabType1: TLabel;
    LabType2: TLabel;
    Imagemain: TImage;
    Label11: TLabel;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    Label1: TLabel;
    SProc: TClientDataSet;
    lvPallet: TListView;
    lvDetail: TListView;
    stbnAdd: TSpeedButton;
    lablWorkOrder: TLabel;
    lablModel: TLabel;
    listbPallet: TListBox;
    Label2: TLabel;
    editPalletNo: TEdit;
    Label3: TLabel;
    procedure sbtnExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure lvPalletClick(Sender: TObject);
    procedure stbnAddClick(Sender: TObject);
    procedure editPalletNoKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    UpdateUserID : String;
    Authoritys : String;
    UserFcID : String; // User 本身的廠別，若為 0 可選所有廠別
    procedure SetTheRegion;

    procedure showPalletDetail(psPalletNO:String);
    function  checkPallet(psPallet: String):Boolean;
  end;

var
  fData: TfData;
  AryStatus : Array[0..7] of String;
  G_sockConnection : TSocketConnection;

implementation

uses uQuality;

{$R *.DFM}

function TfData.checkPallet(psPallet: String):Boolean;
begin
   Result := False;
   with fQuality.QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT QC_NO '
                   + '  FROM SAJET.G_SN_STATUS '
                   + ' WHERE PALLET_NO = ''' + psPallet + ''' '
                   + '   AND QC_NO <> ''N/A'' ';
      Open;
      if not Eof then
      begin
         MessageDlg('Pallet - ' + psPallet +
                    ' in QC Lot NO - ' + FieldByName('QC_No').AsString,mtError,[mbCancel],0);
         Close;
         Exit;
      end;
      Close;
   end;

   Result := True;
end;

Procedure TfData.showPalletDetail(psPalletNO:String);
begin
   lvDetail.Items.Clear;
   with fQuality.QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT CUSTOMER_SN, SERIAL_NUMBER, CARTON_NO '
                   + '  FROM SAJET.G_SN_STATUS '
                   + ' WHERE PALLET_NO = ''' + psPalletNo + ''' ';
      Open;
      while not Eof do
      begin
         with lvDetail.Items.Add do
         begin
            Caption := FieldByName('Customer_Sn').AsString;
            SubItems.Add(FieldByName('Serial_Number').AsString);
            SubItems.Add(FieldByname('Carton_No').AsString);
         end;
         Next;
      end;
   end;
end;

procedure TfData.sbtnExitClick(Sender: TObject);
begin
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

procedure TfData.FormShow(Sender: TObject);
begin
  //LoadApServer;

  With fQuality.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT A.PALLET_NO, COUNT(SERIAL_NUMBER) QTY '
                 + '  FROM SAJET.G_SN_STATUS A, '
                 + '       SAJET.G_PACK_PALLET B '
                 + ' WHERE A.WORK_ORDER = ''' + lablWorkOrder.Caption + ''' '
                 + '   AND B.CLOSE_FLAG = ''Y'' '
                 + '   AND A.QC_NO = ''N/A'' '
                 + '   AND A.PALLET_NO = B.PALLET_NO '
                 + ' GROUP BY A.PALLET_NO ';
    Open;
    while not Eof do
    begin
       with lvPallet.Items.Add do
       begin
             Caption := FieldByName('Pallet_No').AsString;
             SubItems.Add(FieldByname('Qty').AsString);
       end;
       Next;
    end;
    if RecordCount <> 0 then
       showPalletDetail(lvPallet.Items[0].Caption);
  end;
  editPalletNo.Setfocus;
end;

procedure TfData.sbtnSaveClick(Sender: TObject);
Var i: Integer;
    sPalletList: String;
begin
   if listbPallet.Items.Count <> 0 then
   begin
      for i:=0 to listbPallet.Items.Count-1 do
         if not checkPallet(listbPallet.items[i]) then Exit;

      for i:=0 to listbPallet.Items.Count-1 do
         fQuality.updateQCLot_Pallet(listbPallet.Items[i], fQuality.cmbQCLotNo.Text);
      fQuality.G_SysDateTime := now;
      fQuality.UpdateQCLot(0);
//      fQuality.updateLotSize;
   end;

   ModalResult := mrOK;
end;

procedure TfData.lvPalletClick(Sender: TObject);
begin
   if lvPallet.Selected <> nil then
      showPalletDetail(lvPallet.Selected.Caption);
end;

procedure TfData.stbnAddClick(Sender: TObject);
begin
   if lvPallet.SelCount <> 0 then
   begin
      lvPallet.CopySelection(listbPallet);
      lvPallet.DeleteSelected;
      if lvPallet.Items.Count <> 0 then
         showPalletDetail(lvPallet.Items[0].Caption)
      else
         lvDetail.Items.Clear;
   end;
end;

procedure TfData.editPalletNoKeyPress(Sender: TObject; var Key: Char);
var i:integer;
    sPalletNo:String;
begin
  IF KEY <>#13 then exit;
  try
    editPalletNo.Text := Trim(editPalletNo.Text);
    sPalletNo := editPalletNo.Text;
    if lvPallet.FindCaption(0,sPalletNo,False,True,False) = nil then
    begin
      Messagedlg('Pallet No : '+sPalletNO+'  Error!',mtWarning,[mbOK],0);
      exit;
    end;
    for i:=  lvPallet.Items.Count-1 downto 0 do
    begin
      if lvPallet.Items[i].Caption = sPalletNo then
      begin
        if listbPallet.Items.IndexOf(sPalletNo) =-1 then
          listbPallet.Items.Add(sPalletNo);
        lvPallet.Items[i].Delete;
      end;
    end;
    if lvPallet.Items.Count <> 0 then
      showPalletDetail(lvPallet.Items[0].Caption)
    else
      lvDetail.Items.Clear;
  finally
    editPalletNo.Setfocus;
    editPalletNo.SelectAll;
  end;
end;

end.
