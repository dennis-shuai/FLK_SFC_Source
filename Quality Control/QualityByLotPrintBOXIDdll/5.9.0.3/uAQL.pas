unit uAQL;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, ExtCtrls, DB, DBClient, BmpRgn, Buttons, jpeg, Grids,
  DBGrids;

type
   TfAQL = class(TForm)
    dsrcSamplingPlan: TDataSource;
    Imagemain: TImage;
    Image5: TImage;
    Image2: TImage;
    Label1: TLabel;
    cmbAQL: TComboBox;
    Label6: TLabel;
    LabType2: TLabel;
    Label2: TLabel;
    DBGrid2: TDBGrid;
    sbtnSave: TSpeedButton;
    sbtnCancel: TSpeedButton;
    lablLotNO: TLabel;
    Label3: TLabel;
    lablWorkOrder: TLabel;
      procedure FormCreate(Sender: TObject);
      procedure sbtnCancelClick(Sender: TObject);
      procedure sbtnSaveClick(Sender: TObject);
    procedure cmbAQLChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
   private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;

   public
    { Public declarations }
      G_tsSampling:TStringList;
      procedure GetAllPlan;
      procedure SetTheRegion;

   end;

var
   fAQL: TfAQL;


implementation

uses uformMain;

{$R *.dfm}

{ TfAQL }

procedure TfAQL.GetAllPlan;
begin
   cmbAQL.Clear;
   with formMain.QryTemp do
   begin
     try
        Close;
        CommandText := 'Select D.SAMPLING_ID,SAMPLING_TYPE, SAMPLE_SIZE, CRITICAL_REJECT_QTY, MAJOR_REJECT_QTY, MINOR_REJECT_QTY ' +
           'From ' +
           'SAJET.SYS_QC_SAMPLING_PLAN_DETAIL C, ' +
           'SAJET.SYS_QC_SAMPLING_PLAN D ' +
           'Where C.SAMPLING_ID = D.SAMPLING_ID ';
        Open;
        G_tsSampling.Clear;
        while not Eof do
        begin
           if cmbAQL.Items.IndexOF(Fieldbyname('SAMPLING_TYPE').AsString) < 0 then
           begin
              cmbAQL.Items.Add(Fieldbyname('SAMPLING_TYPE').AsString);
              G_tsSampling.Add(Fieldbyname('SAMPLING_TYPE').AsString);
              G_tsSampling.Add(Fieldbyname('SAMPLING_ID').AsString);
           end;
           Next;
        end;
        cmbAQL.ItemIndex := 0;
        IF  cmbAQL.Items.IndexOF(formMain.lablSamplingType.Caption) >= 0 then
          cmbAQL.ItemIndex := cmbAQL.Items.IndexOF(formMain.lablSamplingType.Caption);
     finally
       close;
     end;
   end;
end;

procedure TfAQL.FormCreate(Sender: TObject);
begin
   SetTheRegion;
   G_tsSampling:=TStringList.Create;

   GetAllPlan ;
   if cmbAQL.ItemIndex >=0 then
     cmbAQLChange(self);
end;

procedure TfAQL.SetTheRegion;
var HR: HRGN;
begin
   HR := BmpToRegion(Self, Imagemain.Picture.Bitmap);
   SetWindowRgn(handle, HR, true);
   Invalidate;
end;
procedure TfAQL.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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
procedure TfAQL.WMNCHitTest( var msg: TWMNCHitTest );
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

procedure TfAQL.sbtnCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TfAQL.sbtnSaveClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TfAQL.cmbAQLChange(Sender: TObject);
begin
   dsrcSamplingPlan.DataSet := formMain.QryTemp;
   with formMain.QryTemp do
   begin
     try
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'SAMPLING_TYPE',ptInput);
        CommandText := 'Select C.MIN_LOT_SIZE "Min Size" ,C.MAX_LOT_SIZE "Max Size" '
                      +'      ,C.SAMPLE_SIZE "Sample Size", CRITICAL_REJECT_QTY "Critical Qty"   '
                      +'      , MAJOR_REJECT_QTY "Major Qty", MINOR_REJECT_QTY "Minor Qty" '
                      +'From '
                      + 'SAJET.SYS_QC_SAMPLING_PLAN_DETAIL C, '
                      + 'SAJET.SYS_QC_SAMPLING_PLAN D '
                      + 'Where D.SAMPLING_TYPE = :SAMPLING_TYPE '
                      + '  AND C.SAMPLING_ID = D.SAMPLING_ID '
                       +'ORDER BY MIN_LOT_SIZE ';
        Params.ParamByName('SAMPLING_TYPE').AsString := cmbAQL.Text;
        Open;
     finally

     end;
   end;
end;

procedure TfAQL.FormDestroy(Sender: TObject);
begin
  G_tsSampling.Free;
end;

end.

