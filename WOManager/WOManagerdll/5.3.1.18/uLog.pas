unit uLog;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, ComCtrls, DB, DBCtrls,
  DBClient, Grids, DBGrids;

type
  TfLog = class(TForm)
    sbtnClose: TSpeedButton;
    Image1: TImage;
    Labtype1: TLabel;
    Labtype2: TLabel;
    Imagemain: TImage;
    Label7: TLabel;
    Label8: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label6: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label21: TLabel;
    Label5: TLabel;
    Label13: TLabel;
    Bevel1: TBevel;
    Label20: TLabel;
    cmbTime: TComboBox;
    dbtxtWO: TDBText;
    dbtxtPart: TDBText;
    dbtxtType: TDBText;
    dbtxtVersion: TDBText;
    dbtxtTarget: TDBText;
    dbtxtDuedata: TDBText;
    dbtxtRoute: TDBText;
    dbtxtPDLine: TDBText;
    dbtxtSProcess: TDBText;
    dbtxtEProcess: TDBText;
    dbtxtCust: TDBText;
    dbtxtPO: TDBText;
    dbtxtMastWO: TDBText;
    dbtxtRemark: TDBText;
    dbtxtWORule: TDBText;
    DataSource1: TDataSource;
    QryData: TClientDataSet;
    Label3: TLabel;
    dbtxtEmp: TDBText;
    Label22: TLabel;
    dbtxtModelName: TDBText;
    SpecGrid: TDBGrid;
    QryData1: TClientDataSet;
    DataSource2: TDataSource;
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmbTimeChange(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    procedure SetTheRegion;
    Procedure ShowWOLog(WO : String);
  end;

var
  fLog: TfLog;

implementation

uses uWOManager;

{$R *.DFM}

Procedure TfLog.ShowWOLog(WO : String);
begin
  With QryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'WO', ptInput);
    CommandText := 'Select A.WORK_ORDER,'+
                          'A.WO_TYPE,'+
                          'A.WO_RULE,'+
                          'A.VERSION,'+
                          'A.TARGET_QTY,'+
                          'A.WO_CREATE_DATE,'+
                          'A.WO_SCHEDULE_DATE,'+
                          'A.WO_START_DATE,'+
                          'A.WO_CLOSE_DATE,'+
                          'A.INPUT_QTY,'+
                          'A.OUTPUT_QTY,'+
                          'A.WORK_FLAG,'+
                          'A.WO_STATUS,'+
                          'A.PO_NO,'+
                          'A.MASTER_WO,'+
                          'A.REMARK,'+
                          'A.MODEL_NAME,'+
                          'B.PART_NO,'+
                          'C.ROUTE_NAME,'+
                          'D.PDLINE_NAME,'+
                          'E.CUSTOMER_CODE,'+
                          'E.CUSTOMER_NAME,'+
                          'F.PROCESS_NAME START_PROCESS,'+
                          'G.PROCESS_NAME END_PROCESS, '+
                      //    'H.PKSPEC_NAME,'+
                      //    'H.PALLET_CAPACITY,'+
                      //    'H.CARTON_CAPACITY,'+
                          'TO_CHAR(A.UPDATE_TIME,''YYYY/MM/DD HH24:MI:SS'') UPDATE_TIME,'+
                          'A.UPDATE_USERID,' +
                          'I.EMP_NAME '+
                   'From SAJET.G_HT_WO_BASE A,'+
                         'SAJET.SYS_PART B,'+
                         'SAJET.SYS_ROUTE C,'+
                         'SAJET.SYS_PDLINE D,'+
                         'SAJET.SYS_CUSTOMER E,'+
                         'SAJET.SYS_PROCESS F,'+
                         'SAJET.SYS_PROCESS G,'+
                     //    'SAJET.G_PACK_SPEC H,'+
                         'SAJET.SYS_EMP I '+
                   'Where A.MODEL_ID=B.PART_ID(+) and '+
                         'A.ROUTE_ID=C.ROUTE_ID(+) and '+
                         'A.DEFAULT_PDLINE_ID=D.PDLINE_ID(+) and '+
                         'A.CUSTOMER_ID=E.CUSTOMER_ID(+) and '+
                         'A.START_PROCESS_ID=F.PROCESS_ID(+) and '+
                         'A.END_PROCESS_ID=G.PROCESS_ID(+) and '+
                     //    'A.WORK_ORDER = H.WORK_ORDER(+) and '+
                         'A.UPDATE_USERID = I.EMP_ID and '+
                         'A.WORK_ORDER = :WO '+
                   'Order by UPDATE_TIME ';
    Params.ParamByName('WO').AsString := WO;
    Open;
    cmbTime.Items.Clear ;
    While not Eof do
    begin
      cmbTime.Items.Add(Fieldbyname('UPDATE_TIME').AsString);
      Next;
    end;
    If cmbTime.Items.Count > 0 Then
    begin
      cmbTime.ItemIndex := 0;
      cmbTimeChange(Self);
    end;
  end;


  QryData1.RemoteServer := QryData.RemoteServer;
  with QryData1 do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'WO', ptInput);
     CommandText := 'Select PKSPEC_NAME,CARTON_CAPACITY,PALLET_CAPACITY '+
                    'from SAJET.G_PACK_SPEC '+
                    'where WORK_ORDER =:WO '+
                    'Order By CARTON_CAPACITY desc,PALLET_CAPACITY desc ';
     Params.ParamByName('WO').AsString := QryData.FieldByName('WORK_ORDER').asstring;
     open;
  end;
end;

procedure TfLog.sbtnCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TfLog.FormCreate(Sender: TObject);
begin
  Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'bDetail.bmp');
  SetTheRegion;
end;

procedure TfLog.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.
procedure TfLog.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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
procedure TfLog.WMNCHitTest( var msg: TWMNCHitTest );
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

procedure TfLog.cmbTimeChange(Sender: TObject);
begin
  QryData.Locate('UPDATE_TIME',cmbTime.Text,[]);
end;

end.
