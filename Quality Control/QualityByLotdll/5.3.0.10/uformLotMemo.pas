unit uformLotMemo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,BmpRgn, Buttons, ExtCtrls, StdCtrls;

type
  TformLotMemo = class(TForm)
    Imagemain: TImage;
    Image5: TImage;
    Image1: TImage;
    Label2: TLabel;
    editLotMemo: TEdit;
    Label3: TLabel;
    editInspWorkHours: TEdit;
    LabType2: TLabel;
    Label5: TLabel;
    sbtnSave: TSpeedButton;
    sbtnCancel: TSpeedButton;
    Bevel1: TBevel;
    Label4: TLabel;
    lablLotNO: TLabel;
    Label1: TLabel;
    Label6: TLabel;
    lablPassQty: TLabel;
    Label7: TLabel;
    lablLotSize: TLabel;
    labl8: TLabel;
    lablFailQty: TLabel;
    lablAcceptQty: TLabel;
    editReceiveQty: TEdit;
    Label8: TLabel;
    lablCheckQty: TLabel;
    lablResult: TPanel;
    Label9: TLabel;
    lablWorkOrder: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure sbtnCancelClick(Sender: TObject);
    procedure editInspWorkHoursKeyPress(Sender: TObject; var Key: Char);
    procedure editReceiveQtyKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    procedure SetTheRegion;    
  end;

var
  formLotMemo: TformLotMemo;

implementation

uses uformMain;

{$R *.dfm}

procedure TformLotMemo.FormCreate(Sender: TObject);
begin
  SetTheRegion;
end;

procedure TformLotMemo.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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
procedure TformLotMemo.WMNCHitTest( var msg: TWMNCHitTest );
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
procedure TformLotMemo.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;
procedure TformLotMemo.sbtnSaveClick(Sender: TObject);
begin
  editLotMemo.Text := Trim(editLotMemo.Text);
  editInspWorkHours.Text := Trim(editInspWorkHours.Text);
  if editInspWorkHours.Color =clyellow then
  begin
    if editInspWorkHours.Text ='' then
    begin
      MessageDlg('Please Input "Insp Work Hours" !',mtWarning,[mbOK],0);
      editInspWorkHours.SetFocus;
      editInspWorkHours.SelectAll;
      exit;
    end;
  end;
  if editInspWorkHours.Text<>'' then
  begin
    try
      StrToInt(editInspWorkHours.Text);
    except
      MessageDlg('"Insp Work Hours"  Data Error !',mtWarning,[mbOK],0);
      editInspWorkHours.SetFocus;
      editInspWorkHours.SelectAll;
      exit;
    end;
  end;
  if editReceiveQty.Color =clyellow then
  begin
    if StrToIntDef(editReceiveQty.Text,0) =0 then
    begin
      IF lablResult.Caption <>'SORTING' then  //Sorting¤¹³\RECEIVE QTY ¬°¹s
      begin
        MessageDlg('"Receive Qty"  Data Error !',mtWarning,[mbOK],0);
        editReceiveQty.SetFocus;
        editReceiveQty.SelectAll;
        exit;
      end;
    end;
    if  StrToInt(editReceiveQty.Text) > StrToInt(lablLotSize.Caption) then
    begin
      MessageDlg('Receive Qty : '+editReceiveQty.Text+' "more than" LOT SIZE : '+lablLotSize.Caption ,mtWarning,[mbOK],0);
      editReceiveQty.SetFocus;
      editReceiveQty.SelectAll;
      exit;
    end;
  end;

  modalResult := mrOK;
end;

procedure TformLotMemo.sbtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TformLotMemo.editInspWorkHoursKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (KEY in ['0'..'9',#13,#8]) then Key:=#0;
end;

procedure TformLotMemo.editReceiveQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (KEY in ['0'..'9',#13,#8]) then Key:=#0;
end;

end.
