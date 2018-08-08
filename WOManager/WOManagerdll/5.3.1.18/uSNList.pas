unit uSNList;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, ComCtrls, DB, DBCtrls,
  DBClient, Grids, DBGrids, uWoManager;

type
  TfSNList = class(TForm)
    sbtnClose: TSpeedButton;
    Image1: TImage;
    Labtype1: TLabel;
    Labtype2: TLabel;
    Imagemain: TImage;
    Label20: TLabel;
    DataSource1: TDataSource;
    QryData: TClientDataSet;
    DBGrid1: TDBGrid;
    labWO: TLabel;
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
  public
    { Public declarations }
    procedure SetTheRegion;
    procedure ShowWOLog(WO: string);
    procedure ShowSNLog(WO: string);
  end;

var
  fSNList: TfSNList;

implementation

{$R *.DFM}

procedure TfSNList.ShowWOLog(WO: string);
begin
  labWO.Caption := WO;
  with QryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WO', ptInput);
    CommandText := 'Select A.UPDATE_TIME, ' +
      'decode(A.WO_STATUS,''0'',''Initial''' +
      ',''1'',''Prepare''' +
      ',''2'',''Release''' +
      ',''3'',''WIP''' +
      ',''4'',''Hold''' +
      ',''5'',''Cancel''' +
      ',''6'',''Complete'' '+
      ',''9'',''Complete-No Charge'') STATUS, ' +
      'A.MEMO, ' +
      'B.EMP_NAME ' +
      'From SAJET.G_WO_STATUS A' +
      ',SAJET.SYS_EMP B ' +
      'Where A.WORK_ORDER = :WO ' +
      'and A.update_userid = b.emp_id ' +
      'Order by UPDATE_TIME ';
    Params.ParamByName('WO').AsString := WO;
    Open;
  end;
end;

procedure TfSNList.ShowSNLog(WO: string);
begin
  labWO.Caption := WO;
  with QryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WO', ptInput);
    CommandText := 'Select A.SERIAL_NUMBER,A.Customer_SN,B.Part_No,B.VERSION' +
      ',C.PDLine_Name,D.Stage_Name,E.Process_Name,F.Terminal_Name' +
      ',A.CURRENT_STATUS,I.EMP_NAME,nvl(G.Process_Name,M.Process_Name) Next_Process' +
      ',A.Work_Flag,A.In_Process_Time,A.Out_Process_Time,A.In_PDLine_Time,A.Out_PDLine_Time ' +
      ',A.Box_No,A.CARTON_NO,A.PALLET_NO,A.CONTAINER,A.QC_NO,A.QC_RESULT,A.ENC_CNT,H.CUSTOMER_NAME ' +
      ',J.Shipping_No,A.Warranty,A.Rework_No,K.update_Time Rework_Time,L.emp_name Rework_OP ' +
      'From SAJET.G_SN_STATUS A' +
      ',SAJET.SYS_Part B ' +
      ',SAJET.SYS_PDLine C ' +
      ',SAJET.SYS_Stage D ' +
      ',SAJET.SYS_Process E ' +
      ',SAJET.SYS_Terminal F ' +
      ',SAJET.SYS_Process G ' +
      ',SAJET.SYS_Customer H ' +
      ',SAJET.SYS_Emp I ' +
      ',SAJET.G_Shipping_No J ' +
      ',SAJET.G_Rework_No K ' +
      ',SAJET.SYS_Process M ' +
      ',SAJET.SYS_Emp L ' +
      'Where A.WORK_ORDER = :WO ' +
      'and A.Model_ID=B.Part_ID ' +
      'and A.PDLine_ID = C.PDLine_ID(+) ' +
      'and A.Stage_ID = D.Stage_ID(+) ' +
      'and A.Process_ID = E.Process_ID(+) ' +
      'and A.Terminal_ID = F.Terminal_ID(+) ' +
      'and A.Next_Process = G.Process_ID(+) ' +
      'and A.Wip_Process = M.Process_ID(+) ' +
      'and A.Customer_id = H.Customer_ID(+) ' +
      'and A.Emp_id = I.Emp_ID(+) ' +
      'and A.Shipping_id = J.Shipping_ID(+) ' +
      'and A.Rework_No = K.Rework_No(+) ' +
      'and K.emp_id = L.emp_id(+) ' +
      'Order by A.SERIAL_NUMBER ';
    Params.ParamByName('WO').AsString := WO;
    Open;
  end;
end;

procedure TfSNList.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfSNList.FormCreate(Sender: TObject);
begin
  Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'bDetail.bmp');
  SetTheRegion;
end;

procedure TfSNList.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion(Self, Imagemain.Picture.Bitmap);
  SetWindowRgn(handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.

procedure TfSNList.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
var Brush: TBrush;
begin
  Brush := TBrush.Create;
  Brush.Color := Color;
  FillRect(Msg.DC, ClientRect, Brush.Handle);
  Brush.Free;
  with Imagemain.Picture.Bitmap do
    BitBlt(Msg.DC, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := 1;
end;

// This routine takes care of letting the user move the form
// around on the desktop.

procedure TfSNList.WMNCHitTest(var msg: TWMNCHitTest);
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
    for i := 0 to ControlCount - 1 do
    begin
      if not MouseOnControl
        then
      begin
        AControl := Controls[i];
        if ((AControl is TWinControl) or (AControl is TGraphicControl))
          and (AControl.Visible)
          then MouseOnControl := PtInRect(AControl.BoundsRect, p);
      end
      else
        break;
    end;
    if (not MouseOnControl) then msg.Result := HTCAPTION;
  end;
end;

end.

