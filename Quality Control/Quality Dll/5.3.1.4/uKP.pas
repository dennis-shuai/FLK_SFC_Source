unit uKP;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, DBGrids, StdCtrls, Buttons, DB,BmpRgn, DBClient,
  jpeg, ComCtrls;

type
  TformKP = class(TForm)
    Imagemain: TImage;
    Label1: TLabel;
    Label5: TLabel;
    dbgridKP: TDBGrid;
    DataSource1: TDataSource;
    Image1: TImage;
    sbtnClose: TSpeedButton;
    LabSN: TLabel;
    editSN: TEdit;
    lablLot: TLabel;
    LabKP: TLabel;
    editKP: TEdit;
    ListBox1: TListBox;
    Image2: TImage;
    SpeedButton1: TSpeedButton;
    lablCount: TLabel;
    labl: TLabel;
    lablTotal: TLabel;
    QryKP: TClientDataSet;
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure editSNKeyPress(Sender: TObject; var Key: Char);
    procedure editKPKeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton1Click(Sender: TObject);
    procedure dbgridKPDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure FormShow(Sender: TObject);
  private
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
    { Private declarations }
  public
     RecID, psSN, g_sType: String;
     procedure SetTheRegion;
     procedure ResetText;
     procedure DeleteCheckPart;
    { Public declarations }
  end;

var
  formKP: TformKP;

implementation

uses uQuality;

{$R *.dfm}

{ TformKP }

procedure TformKP.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TformKP.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;
procedure TformKP.FormCreate(Sender: TObject);
begin
    SetTheRegion;
end;

procedure TformKP.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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

procedure TformKP.WMNCHitTest(var msg: TWMNCHitTest);
var
  i: integer;
  p: TPoint;
  AControl: TControl;
  MouseOnControl: boolean;
begin
  inherited;
  if msg.result = HTCLIENT then
  begin
    p.x := msg.XPos;
    p.y := msg.YPos;
    p := ScreenToClient(p);
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

procedure TformKP.editSNKeyPress(Sender: TObject; var Key: Char);
procedure ShowKP;
begin
   with QryKP do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SN', ptInput);
      CommandText := 'Select A.rowid, B.PART_NO "KPNO",A.ITEM_PART_ID "ID",A.ITEM_PART_SN "KPSN",B.SPEC1 "SPEC", B.Cust_Part_No '
                   + '      ,C.FIX1 '
                   + 'From SAJET.G_SN_KEYPARTS A '
                   + '    ,SAJET.SYS_PART B '
                   + '    ,(select * from sajet.sys_part_sn_rule where length1=(To1-From1+1)) C '
                   + 'Where A.SERIAL_NUMBER = :SN '
                   + 'and A.ITEM_PART_ID = B.PART_ID(+) '
                   + 'and A.PROCESS_ID in ('+fQuality.G_PartProcess+') '
                   + 'and A.ITEM_PART_ID = C.PART_ID(+) ';
      Params.ParamByName('SN').AsString := psSN;
      Open;
   end;
end;
begin
   if Ord(Key) <> vk_Return then Exit;

   psSN := editSN.Text;

   try
     with fQuality.QryTemp do
     begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
         Params.CreateParam(ftString, 'QC_NO', ptInput);
         CommandText := 'Select A.SERIAL_NUMBER '
                      + 'From SAJET.G_SN_STATUS A '
                      + '    ,SAJET.G_QC_CHECK_PART B '
                      + 'Where A.SERIAL_NUMBER = :SERIAL_NUMBER '
                      + 'And A.SERIAL_NUMBER = B.SERIAL_NUMBER '
                      + 'And B.QC_NO = :QC_NO ';
         Params.ParamByName('SERIAL_NUMBER').AsString := editSN.Text;
         Params.ParamByName('QC_NO').AsString := lablLot.Caption;
         Open;
         if RecordCount <= 0 then
         begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
            Params.CreateParam(ftString, 'QC_NO', ptInput);
            CommandText := 'Select A.SERIAL_NUMBER '
                         + 'From SAJET.G_SN_STATUS A '
                         + '    ,SAJET.G_QC_CHECK_PART B '
                         + 'Where A.CUSTOMER_SN = :SERIAL_NUMBER '
                         + 'And A.SERIAL_NUMBER = B.SERIAL_NUMBER '
                         + 'And B.QC_NO = :QC_NO ';
            Params.ParamByName('SERIAL_NUMBER').AsString := editSN.Text;
            Params.ParamByName('QC_NO').AsString := lablLot.Caption;
            Open;
            if Eof then
            begin
               MessageBeep(17);
               MessageDlg('Input Data error !!', mtError, [mbOK], 0);
               editSN.SelectAll;
               editSN.SetFocus;
               Exit;
            end;
         end;
         psSN := FieldByName('Serial_Number').AsString;
     end; 

     ShowKP;
    { editKP.Visible := not QryKP.IsEmpty;
     LabKP.Visible := editKP.Visible;
     lablTotal.Visible := editKP.Visible;
     lablCount.Visible := editKP.Visible;
     labl.Visible := editKP.Visible; }

     editSN.Enabled := False;
     lablCount.Caption := '0';
     lablTotal.Caption := IntToStr(QryKP.RecordCount);
     if g_sType = '1' then
     begin
       if editKP.Visible then
       begin
          editKP.Enabled := True;
          editKP.SetFocus;
       end;
     end;
   finally
      fQuality.QryTemp.close;
   end;
end;

procedure TformKP.DeleteCheckPart;
begin
  with fQuality.QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
     CommandText := 'delete from SAJET.G_QC_Check_Part ' +
                    'Where SERIAL_NUMBER = :SERIAL_NUMBER';
     Params.ParamByName('SERIAL_NUMBER').AsString := editSN.Text;
     Execute;
     Close;
  end;
end;

procedure TformKP.editKPKeyPress(Sender: TObject; var Key: Char);
var bLocate: Boolean;
begin
  if Ord(Key) = vk_Return then
  begin
    if editKP.Text = 'N/A' then
    begin
       MessageBeep(17);
       MessageDlg('Key Part Error!!', mtError, [mbOK], 0);
       Exit;
    end;
    bLocate := QryKP.Locate('KPSN', editKP.Text, []);
    if not bLocate then
      bLocate := QryKP.Locate('KPNO', editKP.Text, []);
    if not bLocate then
      bLocate := QryKP.Locate('CUST_PART_NO', editKP.Text, []);

    //是否符合KPSN RULE
    //(規則中KPSN長度與特徵所設的長度相同時,KPSN是填'N/A',因此刷入值會固定為FIX欄位)
    if not bLocate then
      bLocate := QryKP.Locate('FIX1', editKP.Text, []);

    if bLocate then
    begin
      editKp.SelectAll;
      editKp.SetFocus; 
      if ListBox1.Items.IndexOf(QryKP.FieldByName('rowid').AsString) = -1 then
      begin
        ListBox1.Items.Add(QryKP.FieldByName('rowid').AsString);
        editKp.SelectAll;
        editKp.SetFocus;
        lablCount.Caption := IntToStr(ListBox1.Items.Count);
        if ListBox1.Items.Count = QryKP.RecordCount then
        begin
          editKP.Enabled := False;
          DeleteCheckPart;
          if g_sType='0' then
            formKP.Close
          else
            ResetText;  
        end;
      end;
    end else
    begin
       MessageBeep(17);
       MessageDlg('Key Part Error!!', mtError, [mbOK], 0);
       editKp.SelectAll;
       editKp.SetFocus;
    end;
  end;
end;

procedure TformKP.ResetText;
begin
  QryKP.Close;
  ListBox1.Items.Clear;
  editKp.Text := '';
  editKp.Enabled := False;
  editSN.Enabled := True;
  editSN.SetFocus;
  editSN.SelectAll;
end;

procedure TformKP.SpeedButton1Click(Sender: TObject);
begin
  ResetText;
end;

procedure TformKP.dbgridKPDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var Canvas: TCanvas;
begin
  Canvas := (Sender as TDBGrid).Canvas;
  if ListBox1.Items.Indexof(QryKP.FieldByName('RowId').AsString) = -1 then
  begin
     Canvas.Brush.Color := clRed;
     Canvas.Brush.Style := bsSolid;
     dbgridKP.DefaultDrawColumnCell(Rect,DataCol,Column,State);
  end;
end;

procedure TformKP.FormShow(Sender: TObject);
begin
  SpeedButton1.Visible:=False;
  Image2.Visible:=False;
  if g_sType='1' then
  begin
    SpeedButton1.Visible:=True;
    Image2.Visible:=True;
  end;

  if editSN.Enabled then
    editSN.SetFocus
  else
    editKP.SetFocus;
end;

end.
