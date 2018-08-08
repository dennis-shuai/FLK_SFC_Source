unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, StdCtrls, Db, DBClient, MConnect, SConnect,BmpRgn,
  ObjBrkr, Variants, Grids, DBGrids;

type
  TfMain = class(TForm)
    SProc1: TClientDataSet;
    QryTemp1: TClientDataSet;
    QryData1: TClientDataSet;
    Imagemain: TImage;
    Label5: TLabel;
    LabSN: TLabel;
    LabPart: TLabel;
    Label6: TLabel;
    editCPN: TEdit;
    Label3: TLabel;
    sbtnOK: TBitBtn;
    sbtnCancel: TBitBtn;
    Label7: TLabel;
    EditSN: TEdit;
    Label8: TLabel;
    lstcheckcsnField: TListBox;
    lstcheckcsnValue: TListBox;
    Label1: TLabel;
    LabCPN: TLabel;
    procedure sbtnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnCancelClick(Sender: TObject);
    procedure EditSNKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure editCPNKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
    { Private declarations }
  public
    G_tsParam,G_tsData:TStrings;
    gSN,gPartID,gUPC,gVer,gCustPart:string;
    gbChkCustPart,gbChkVer,gbChkUPC:Boolean;
    gwo:string;
    gkpcount:integer;
    procedure SetTheRegion;
    { Public declarations }
  end;

var
  fMain: TfMain;
  SNUdf: TStringList;
  G_sockConnection : TSocketConnection;
  function AdditionalData(tsInParam,tsInData:TStrings;parentSocketConnection : TSocketConnection): Boolean; stdcall; export;
implementation

{$R *.DFM}

procedure TfMain.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.
procedure TfMain.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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
procedure TfMain.WMNCHitTest( var msg: TWMNCHitTest );
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

function AdditionalData(tsInParam,tsInData:TStrings;parentSocketConnection : TSocketConnection): Boolean;
var i:integer;
begin
  Result := False;
  fMain := TfMain.Create(Application);
  with fMain do
  begin
    G_tsParam:=TStringList.Create;
    G_tsData:=TStringList.Create;
    G_tsParam:=tsInParam;
    G_tsData:=tsInData;

    G_sockConnection := parentSocketConnection;
    QryData1.RemoteServer := G_sockConnection;
    QryData1.ProviderName := 'DspQryData';
    QryTemp1.RemoteServer := G_sockConnection;
    QryTemp1.ProviderName := 'DspQryTemp1';
    SProc1.RemoteServer := G_sockConnection;
    SProc1.ProviderName := 'DspStoreproc';

    if ShowModal = mrOK then
    begin
      Result := True;
    end;
    Free;
  end;
end;

procedure TfMain.sbtnOKClick(Sender: TObject);
var sKey:char;
begin
  sKey:=#13;
 { if not gbChkCustPart then
  begin
    editCustPartKeyPress(self,sKey);
    if not gbChkCustPart then exit;
  end;

  if not gbChkVer then
  begin
    editVersionKeyPress(self,sKey);
    if not gbChkVer then exit;
  end;

  if not gbChkUPC then
  begin
    editUPCKeyPress(self,sKey);
    if not gbChkUPC then exit;
  end;
 }
  ModalResult:= mrOK;
end;

procedure TfMain.FormShow(Sender: TObject);
var i:integer;
begin
  gSN:= G_tsData.Strings[G_tsParam.IndexOf('SERIAL_NUMBER')];
  LabSN.Caption:= gSN;
  
  with QryTemp1 do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SN', ptInput);
    CommandText := 'SELECT * from sajet.G_SN_STATUS '
                 + 'where Serial_Number = :SN ' ;
    Params.ParamByName('SN').AsString := gSN;
    Open;
    gPartID:=FieldByName('MODEL_ID').asstring;
    gwo:=fieldbyname('work_order').AsString ;

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PART_ID', ptInput);
    CommandText := 'SELECT * from sajet.SYS_PART '
                 + 'where PART_ID = :PART_ID ' ;
    Params.ParamByName('PART_ID').AsString := gPartID;
    Open;
    LabPart.Caption:=FieldByName('PART_NO').asstring;
    LabCPN.Caption :=fieldbyname('cust_part_no').AsString ;
   //gUPC:= FieldByName('UPC').asstring;
   // gVer:= FieldByName('VERSION').asstring;
   // gCustPart:= FieldByName('CUST_PART_NO').asstring;
    Close;
  end;
    {
        with QryTemp1 do
        begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'WO_NUMBER', ptInput);
            CommandText := 'SELECT A.*, B.PART_NO, Label_File, CUST_PART_NO ' +
                  'FROM   SAJET.G_WO_BASE A, SAJET.SYS_PART B ' +
                  'WHERE  A.WORK_ORDER = :WO_NUMBER ' +
                  'AND    A.MODEL_ID = B.PART_ID(+) and rownum = 1';
             Params.ParamByName('WO_NUMBER').AsString := gWO;
             Open;
             lstcheckcsnField.Items.Clear;
             lstcheckcsnValue.Items.Clear;
             if not IsEmpty then
             begin
                for i := 0 to FieldCount - 1 do
                begin
                    lstcheckcsnField.Items.Add(QryTemp1.Fields.Fields[i].FieldName);
                    lstcheckcsnValue.Items.Add(QryTemp1.Fields.Fields[i].AsString);
                 end;
            end;
         end;

  SNUdf := TStringList.Create;
  }
  editsn.SelectAll ;
  editsn.SetFocus ;
  editcpn.Enabled :=false;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
   if FileExists(ExtractFilePath(Application.ExeName) + 'bDetail.bmp') then
   begin
     Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'bDetail.bmp');
     SetTheRegion;
   end;
end;

procedure TfMain.sbtnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfMain.EditSNKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if ORD(Key)=VK_RETURN then
   begin
        if editsn.Text = Labsn.Caption then
        begin
            editCPN.Enabled :=true;
            editcpn.SelectAll ;
            editcpn.SetFocus ;
        end
        else
            begin
                 MessageDlg('SN '+editsn.Text+ '<>'+ Labsn.Caption,mtError,[mbCancel],0);
                 editsn.SelectAll ;
                 editsn.SetFocus ;
                 exit;
            end;
    end;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
   SNUdf.Free ;
end;

procedure TfMain.editCPNKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if ORD(Key)=VK_RETURN then
   begin
        if (editcpn.Text <> Labcpn.Caption) or (uppercase(trim(editcpn.Text)) ='N/A')
              or (trim(editcpn.Text) ='')  then
        begin
            MessageDlg('Customer Part NO '+editCPN.Text+ '<>'+ Labcpn.Caption,mtError,[mbCancel],0);
            editcpn.SelectAll ;
            editcpn.SetFocus ;
            exit;
        end;


        ModalResult:= mrOK;

    end;

    
end;

end.
