unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB, Grids, DBGrids;

type
  TfData = class(TForm)
    sbtnCancel: TSpeedButton;
    sbtnSave: TSpeedButton;
    Image5: TImage;
    Image1: TImage;
    Label6: TLabel;
    LabType1: TLabel;
    LabType2: TLabel;
    Imagemain: TImage;
    edtPart: TEdit;
    Label1: TLabel;
    cmbFIFO: TComboBox;
    SpeedButton1: TSpeedButton;
    Label4: TLabel;
    edtLast: TEdit;
    Label2: TLabel;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure cmbFIFOChange(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    MaintainType : String;
    ItemID,tLevel: String;
    UpdateSuccess : Boolean;
    tPass,tFail:integer;
    procedure SetTheRegion;
    function GetPart(PartNo:string;var PartID:string):boolean;
  end;

var
  fData: TfData;

implementation

{$R *.DFM}
uses uformMain, uDetail;


function TfData.GetPart(PartNo:string;var PartID:string):boolean;
begin
  result:=false;
  With formMain.qryTemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString	,'PartNo', ptInput);
    commandtext:=' select part_id  from sajet.sys_part '
                +' where part_no=:partNo ';
    Params.ParamByName('PartNo').AsString := PartNo;
    open;
    if not isempty then
    begin
      PartID:=fieldbyname('part_id').asstring;
      result:=true;
    end;
  end;
end;

procedure TfData.sbtnCancelClick(Sender: TObject);
begin
  If UpdateSuccess Then
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



procedure TfData.sbtnSaveClick(Sender: TObject);
Var S : String; sItemId,sSamplingRuleName,sSamplingRuleID,sSamplingName,sSamplingID: String; I : Integer;
    tPartID:string;
begin
  {if cmbVendor.Items.IndexOf(cmbVendor.Text)=-1 then
  begin
     MessageDlg('Vendor Error !!',mtError, [mbCancel],0);
     cmbVendor.SetFocus ;
     Exit;
  end;  
  If not getPart(trim(edtPart.Text),tPartID) Then
  begin
     MessageDlg('Part No Error !!',mtError, [mbCancel],0);
     edtPart.SetFocus ;
     Exit;
  end;  }

  {if cmbLevel.Items.IndexOf(cmbLevel.Text)=-1 then
  begin
     MessageDlg('Level Name Error !!',mtError, [mbCancel],0);
     cmbLevel.SetFocus ;
     Exit;
  end;  }
  If not getPart(trim(edtPart.Text),tPartID) Then
  begin
     MessageDlg('Part No Error !!',mtError, [mbCancel],0);
     edtPart.SelectAll;
     edtPart.SetFocus ;
     Exit;
  end;

  if  (cmbFIFo.ItemIndex=1) and (trim(edtLast.Text)='') then
  begin
     MessageDlg('Floor life Error!!',mtError, [mbCancel],0);
     edtLast.SelectAll;
     edtLast.SetFocus ;
     Exit;
  end;

  try
    if strtoint(edtlast.Text)<=0 then
    begin
       MessageDlg('Floor life Error!!',mtError, [mbCancel],0);
       edtLast.SelectAll;
       edtLast.SetFocus ;
       Exit;
     end;
   except
       MessageDlg('Floor life Error!!',mtError, [mbCancel],0);
       edtLast.SelectAll;
       edtLast.SetFocus ;
       Exit;
   end;

  If MaintainType = 'Append' Then
  begin
     // ÀË¬d Name ¬O§_­«½Æ
     
     With formMain.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'PartID', ptInput);
        CommandText := 'Select * '+
                       'From SAJET.sys_part_msd '+
                       'Where part_id=:partid ';
        Params.ParamByName('PartID').AsString := tPartID;
        Open;
        If RecordCount > 0 Then
        begin
           S := ' Duplicate !! ';
           Close;
           MessageDlg(S,mtError, [mbCancel],0);
           Exit;
        end;
     end;

     Try
        With formMain.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'PartID', ptInput);
           Params.CreateParam(ftString	,'MSD', ptInput);
           Params.CreateParam(ftString	,'iTime', ptInput);
           Params.CreateParam(ftString	,'UserID', ptInput);
           commandtext := ' insert into sajet.sys_part_MSD '
                         +' (part_id,Check_MSD,Floor_life,update_userid,update_time) '
                         +' values (:PartID,:msd,:iTime,:UserID,sysdate) ';
           {CommandText := 'Insert Into SAJET.g_iqc_cnt '+
                          ' (vendor_id,part_id,pass_qty,fail_qty,Level_id) '+
                          'Values (:VendorID,:PartID,:iPass,:iFail,:iLevel) '; }
           Params.ParamByName('PartID').AsString := tPartID;
           Params.ParamByName('msd').AsString := Trim(cmbFIFO.Text);
           Params.ParamByName('iTime').AsString := Trim(edtLast.Text);
           Params.ParamByName('UserID').AsString := formMain.UpdateUserID;
           Execute;
        end;
     Except
       ON E:Exception do
       begin
         MessageDlg('Database Error !!'+e.Message+#13#10 +
                    'could not save to Database !!' ,mtError, [mbCancel],0);
         Exit;
       end;
     end;

     MessageDlg(' Append OK!!',mtCustom, [mbOK],0);
     UpdateSuccess := True;
     If MessageDlg('Append Other Data ?',mtCustom, mbOKCancel,0) = mrOK Then
     begin
        EdtPart.Text := '';
        edtLast.Text := '90';
        Exit;
     end;
  end;

  If MaintainType = 'Modify' Then
  begin
     Try
        With formMain.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'PartID', ptInput);
           commandtext:=' insert into sajet.sys_ht_part_msd '
                       +' select * from sajet.sys_part_msd where part_id=:partID ';
           Params.ParamByName('PartID').AsString := tPartID;
           execute;

           close;
           params.Clear;
           Params.CreateParam(ftString	,'PartID', ptInput);
           Params.CreateParam(ftString	,'msd', ptInput);
           Params.CreateParam(ftString	,'iTime', ptInput);
           Params.CreateParam(ftString	,'UserID', ptInput);
           commandtext:= ' update sajet.sys_part_msd '
                        +' set check_msd =:msd '
                        +'    ,floor_life=:iTime '
                        +'    ,update_time=sysdate '
                        +'    ,update_userid=:userID '
                        +' where part_id=:PartID ';
           Params.ParamByName('PartID').AsString := tPartID;
           Params.ParamByName('msd').AsString := Trim(cmbFIFO.Text);
           Params.ParamByName('iTime').AsString := Trim(edtLast.Text);
           Params.ParamByName('UserID').AsString := formMain.UpdateUserID;
           Execute;
           MessageDlg(' Update OK!!',mtCustom, [mbOK],0);
           ModalResult := mrOK;
        end;
     Except
       ON E:Exception do
       begin
         MessageDlg('Database Error !!'+e.Message+#13#10 +
                    'could not save to Database !!' ,mtError, [mbCancel],0);
         Exit;
       end;
     end;
  End;
  ModalResult := mrOK
end;


procedure TfData.SpeedButton1Click(Sender: TObject);
begin
   fDetail := TfDetail.Create(Self);
   fDetail.Qrypart.RemoteServer:=formMain.Qrydata.RemoteServer;
   fDetail.Qrypart.ProviderName := 'DspQryData';
   fDetail.tPartNo:=trim(edtpart.Text);
   If fDetail.Showmodal = mrOK Then
   begin
      edtPart.Text:=fDetail.Qrypart.fieldbyname('part_no').AsString;
   end
   else begin
     edtPart.SelectAll;
     edtPart.SetFocus;
   end;
end;

procedure TfData.cmbFIFOChange(Sender: TObject);
begin
  if cmbFIFO.ItemIndex=1 then
  edtLast.Color:=$00A4FFFF
  else edtLast.Color:=clwhite;
end;

end.
