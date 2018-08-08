unit uRPItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, DBGrids, StdCtrls, Buttons, DB,BmpRgn, DBClient,
  jpeg;

type
  TformRPItem = class(TForm)
    Imagemain: TImage;
    Label1: TLabel;
    Label5: TLabel;
    Image3: TImage;
    sbtnOK: TSpeedButton;
    Image1: TImage;
    sbtnClose: TSpeedButton;
    editVendor: TEdit;
    LabRemark: TLabel;
    labSN: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    editItem: TEdit;
    sbtnShowBom: TSpeedButton;
    editDateCode: TEdit;
    editQty: TEdit;
    sbtnVenFilter: TSpeedButton;
    LabVendor: TLabel;
    LabPart: TLabel;
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnOKClick(Sender: TObject);
    procedure sbtnShowBomClick(Sender: TObject);
    procedure sbtnVenFilterClick(Sender: TObject);
    procedure editVendorKeyPress(Sender: TObject; var Key: Char);
    procedure editItemKeyPress(Sender: TObject; var Key: Char);
    procedure editDateCodeKeyPress(Sender: TObject; var Key: Char);
    procedure editQtyKeyPress(Sender: TObject; var Key: Char);
  private
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
    { Private declarations }
  public
     RecID,gVendorId,gPartId : String;
     procedure SetTheRegion;
     function CheckVendor: Boolean;
     function CheckPart: Boolean;
    { Public declarations }
  end;

var
  formRPItem: TformRPItem;

implementation

{$R *.dfm}

uses uRepair, uFilter;




procedure TformRPItem.sbtnCloseClick(Sender: TObject);
begin
     Close;
end;

procedure TformRPItem.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;

procedure TformRPItem.FormCreate(Sender: TObject);
begin
  if FileExists(ExtractFilePath(Application.ExeName) + 'bDetail.bmp') then
  begin
    Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'bDetail.bmp');
    SetTheRegion;
  end;
end;

procedure TformRPItem.sbtnOKClick(Sender: TObject);
var sRes:string;
begin
   if not CheckPart then Exit;
   if not CheckVendor then Exit;
   
   with fRepair.SProc do
   begin
      try
         Close;
         DataRequest('SAJET.SJ_REPAIR_REPLACE_ITEM');
         FetchParams;
         Params.ParamByName('TWO').AsString := fRepair.LabWO.Caption;
         Params.ParamByName('TPROCESSID').AsString := fRepair.ProcessId;
         Params.ParamByName('TLINEID').AsString := fRepair.PDLineId;
         Params.ParamByName('TPARTID').AsString := gPartId;
         Params.ParamByName('TEMP').AsString := fRepair.UpdateUserID;
         Params.ParamByName('TVENDORID').AsString := gVendorId;
         Params.ParamByName('TDATECODE').AsString := editDateCode.Text;
         Params.ParamByName('TQTY').AsString := editQty.Text;
         Execute;
         sRes := Params.ParamByName('TRES').AsString;
      except
         on E: Exception do
           sRes:='SJ_REPAIR_REPLACE_ITEM Exception:'+E.Message;
      end;
      Close;
   end;
   if sRes <> 'OK' then
   begin
      MessageDlg(sRes, mtError, [mbCancel], 0);
      Exit;
   end;
   ModalResult := mrOK;
end;

procedure TformRPItem.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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

procedure TformRPItem.WMNCHitTest(var msg: TWMNCHitTest);
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

procedure TformRPItem.sbtnShowBomClick(Sender: TObject);
var K:Char;
begin
   with TfFilter.Create(Self) do
   begin
      with QryData do
      begin
        RemoteServer:=fRepair.QryData.RemoteServer;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'PN', ptInput);
        CommandText := 'Select PART_NO "Part", SPEC1 "Spec1",SPEC2 "Spec2" '
                     + 'From SAJET.SYS_PART '
                     + 'Where PART_NO Like :PN '
                     + 'and Enabled = ''Y'' '
                     + 'Order By PART_NO';
        Params.ParamByName('PN').AsString := Trim(editItem.Text) + '%';
        Open;
      end;
      if Showmodal = mrOK then
      begin
         K := #13;
         editItem.Text := QryData.Fieldbyname('Part').AsString;
         editItemKeyPress(editItem, K);
      end;
      QryData.Close;
      Free;
   end;
end;

procedure TformRPItem.sbtnVenFilterClick(Sender: TObject);
var K:Char;
begin
   with TfFilter.Create(Self) do
   begin
      with QryData do
      begin
        RemoteServer:=fRepair.QryData.RemoteServer;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'PN', ptInput);
        CommandText := 'Select VENDOR_CODE "Vendor", VENDOR_NAME "Name"'
                     + 'From SAJET.SYS_VENDOR '
                     + 'Where VENDOR_CODE Like :PN '
                     + 'and Enabled = ''Y'' '
                     + 'Order By VENDOR_CODE';
        Params.ParamByName('PN').AsString := Trim(editVendor.Text) + '%';
        Open;
      end;
      if Showmodal = mrOK then
      begin
         K := #13;
         editVendor.Text := QryData.Fieldbyname('Vendor').AsString;
         editVendorKeyPress(editVendor, K);
      end;
      QryData.Close;
      Free;
   end;   
end;

procedure TformRPItem.editVendorKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then
      if CheckVendor then
         editDateCode.SetFocus;
end;

function TformRPItem.CheckVendor: Boolean;
begin
   Result := False;
   with fRepair.QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'VENDOR_CODE', ptInput);
      CommandText := 'Select * '
                   +'From SAJET.SYS_VENDOR '
                   +'Where VENDOR_CODE = :VENDOR_CODE';
      Params.ParamByName('VENDOR_CODE').AsString := editVendor.Text;
      Open;
      if RecordCount <= 0 then
      begin
         Close;
         MessageDlg('Vendor Code error !!' + #13#10 +
                    'Vendor Code : ' + editVendor.Text, mtError, [mbCancel], 0);
         Exit;
      end;
      gVendorId := Fieldbyname('VENDOR_Id').AsString;
      LabVendor.Caption := Fieldbyname('VENDOR_NAME').AsString;
      Close;
   end;
   Result := True;
end;

procedure TformRPItem.editItemKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then
      if CheckPart then
         editVendor.SetFocus;
end;

function TformRPItem.CheckPart: Boolean;
begin
   Result := False;
   with fRepair.QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PART_NO', ptInput);
      CommandText := 'Select * '
                   +'From SAJET.SYS_PART '
                   +'Where PART_NO = :PART_NO';
      Params.ParamByName('PART_NO').AsString := editItem.Text;
      Open;
      if RecordCount <= 0 then
      begin
         Close;
         MessageDlg('Part No error !!' + #13#10 +
                    'Part No : ' + editItem.Text, mtError, [mbCancel], 0);
         Exit;
      end;
      gPartId := Fieldbyname('PART_ID').AsString;
      LabPart.Caption := Fieldbyname('SPEC1').AsString;
      Close;
   end;
   Result := True;
end;

procedure TformRPItem.editDateCodeKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
    editDateCode.SetFocus;
end;

procedure TformRPItem.editQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (key in ['0'..'9',#8]) then key:=#0;
end;

end.
