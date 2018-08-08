unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB, Spin, Mask, RzEdit,
  RzSpnEdt;

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
    Label1: TLabel;
    edtName: TEdit;
    Label2: TLabel;
    Label5: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    edtValue: TEdit;
    lbl1: TLabel;
    edtUpper: TEdit;
    edtCode: TEdit;
    edtDesc: TEdit;
    Label3: TLabel;
    edtLower: TEdit;
    edtDeviation: TEdit;
    LabID: TLabel;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure edtValueChange(Sender: TObject);
    procedure edtDeviationChange(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    MaintainType : String;
    UpdateSuccess:boolean;
    sOreasonid,sOdutyid:string;
    procedure SetTheRegion;
    function GetID(sFieldID,sfield,sTable,sCondition:string):integer;
  end;

var
  fData: TfData;

implementation

uses uMain,uDetail;

{$R *.DFM}
//uses uDPPM;
function TfData.GetID(sfieldID,sField,sTable,sCondition:string):integer;
begin
  result:=0;
  With fDPPM.QryTemp do
  begin
    close;
    params.Clear;
    commandtext:=' select '+sFieldID + ' sID from '+sTable+' where '+sField+' = '+''''+ sCondition+'''';
    open;
    if Not IsEmpty then
      Result:=fieldbyname('sID').AsInteger;
  end;
end;

procedure TfData.sbtnCancelClick(Sender: TObject);
begin
  if UpdateSuccess then
     ModalResult:=mrok
  else
    Close;
end;

procedure TfData.FormCreate(Sender: TObject);
begin
 if FileExists(ExtractFilePath(Application.ExeName) + 'sDetail.bmp') then
 begin
   Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'sDetail.bmp');
   SetTheRegion;
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

  If MaintainType = 'Append' Then
  begin
     With fDPPM.QryTemp do
     begin
       Close;
        Params.Clear;
        Params.CreateParam(ftString	,'itemId', ptInput);
        Params.CreateParam(ftString	,'ItemCode', ptInput);
        Params.CreateParam(ftString	,'ItemName', ptInput);
        CommandText := 'Select *  From SAJET.sys_cal_item '+
                       'Where item_id = :itemId or item_code=:ItemCode or item_Name=:ItemName ';
        Params.ParamByName('itemId').AsString := LabID.Caption;
        Params.ParamByName('ItemCode').AsString := edtCode.Text;
        Params.ParamByName('ItemName').AsString := edtName.Text;
        Open;

        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                 'Item ID : ' +  LabID.Caption +#13#10+
                 'Item Code  : ' +   edtCode.Text +#13#10+
                 'Item Name  : ' +   edtName.Text ;
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
           Params.CreateParam(ftString	,'ItemID', ptInput);
           Params.CreateParam(ftString	,'ItemCode', ptInput);
           Params.CreateParam(ftString	,'ItemName', ptInput);
           Params.CreateParam(ftString	,'ItemDesc', ptInput);
           Params.CreateParam(ftString	,'ItemValue', ptInput);
           Params.CreateParam(ftString	,'ItemDev', ptInput);
           Params.CreateParam(ftString	,'UpperValue', ptInput);
           Params.CreateParam(ftString	,'LowerValue', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           CommandText := 'Insert Into SAJET.sys_cal_item '+
                          ' (item_id,item_code,item_Name,Item_Desc,Item_Value,Item_Deviation,Upper_Value,Lower_Value,update_userid,update_time,enabled) '+
                          'Values (:ItemID,:ItemCode,:ItemName,:ItemDesc,:ItemValue,:ItemDev,:UpperValue,:LowerValue,:UPDATE_USERID,sysdate,''Y'') ';
           Params.ParamByName('ItemID').AsString := LabID.caption;
           Params.ParamByName('ItemCode').AsString := edtCode.Text;
           Params.ParamByName('ItemName').AsString := edtName.Text;
           Params.ParamByName('ItemDesc').AsString :=   edtDesc.text;
           Params.ParamByName('ItemValue').AsString := edtValue.text;
           Params.ParamByName('ItemDev').AsString := edtDeviation.text;
           Params.ParamByName('UpperValue').AsString := edtUpper.text;
           Params.ParamByName('LowerValue').AsString := edtLower.text;
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Execute;
           fDPPM.CopyToHistory(LabID.caption);

        end;
     Except
       on E:Exception do
       begin
         MessageDlg('Database Error !!'+#13#10 +
                    E.Message ,mtError, [mbCancel],0);
         Exit;
       end;
     end;

     MessageDlg('Data Append OK!!',mtCustom, [mbOK],0);
     UpdateSuccess := True;
     If MessageDlg('Append Other Data ?',mtCustom, mbOKCancel,0) <> mrOK Then
        ModalResult := mrOK
     else
     begin
        LabID.Caption := fDPPM.GetMaxID;
        edtCode.Clear;
        edtName.Clear;
        Exit;
     end;
     Exit;
  end;

  If MaintainType = 'Modify' Then
  begin
     With fDPPM.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'itemId', ptInput);
        Params.CreateParam(ftString	,'ItemCode', ptInput);
        Params.CreateParam(ftString	,'ItemName', ptInput);
        CommandText := 'Select *  From SAJET.sys_cal_item '+
                       'Where item_id <> :itemId and (item_code=:ItemCode or item_Name=:ItemName) ';
        Params.ParamByName('itemId').AsString := LabID.Caption;
        Params.ParamByName('ItemCode').AsString := edtCode.Text;
        Params.ParamByName('ItemName').AsString := edtName.Text;
        Open;

        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                 'Item ID : ' +  LabID.Caption +#13#10+
                 'Item Code  : ' +   edtCode.Text +#13#10+
                 'Item Name  : ' +   edtName.Text ;
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
           Params.CreateParam(ftString	,'ItemID', ptInput);
           Params.CreateParam(ftString	,'ItemCode', ptInput);
           Params.CreateParam(ftString	,'ItemName', ptInput);
           Params.CreateParam(ftString	,'ItemDesc', ptInput);
           Params.CreateParam(ftString	,'ItemValue', ptInput);
           Params.CreateParam(ftString	,'ItemDev', ptInput);
           Params.CreateParam(ftString	,'UpperValue', ptInput);
           Params.CreateParam(ftString	,'LowerValue', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           CommandText := 'UPDATE SAJET.sys_cal_item SET '+
                          '  item_code=:ItemCode,item_Name =:ItemName,Item_Desc =:ItemDesc ,'+
                          '  Item_Value=:ItemValue,Item_Deviation=:ItemDev,Upper_Value=:UpperValue,Lower_Value =:LowerValue,'+
                          '  update_userid=:UPDATE_USERID,update_time=sysdate,enabled =''Y'' where item_id =:ItemID ';
           Params.ParamByName('ItemID').AsString := LabID.caption;
           Params.ParamByName('ItemCode').AsString := edtCode.Text;
           Params.ParamByName('ItemName').AsString := edtName.Text;
           Params.ParamByName('ItemDesc').AsString :=   edtDesc.text;
           Params.ParamByName('ItemValue').AsString := edtValue.text;
           Params.ParamByName('ItemDev').AsString := edtDeviation.text;
           Params.ParamByName('UpperValue').AsString := edtUpper.text;
           Params.ParamByName('LowerValue').AsString := edtLower.text;
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Execute;
           fDPPM.CopyToHistory(LabID.caption);
           MessageDlg('Data Update OK!!',mtCustom, [mbOK],0);
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

procedure TfData.edtValueChange(Sender: TObject);
begin
    edtUpper.Text :=  FloatToStr(StrToFloatDef(edtValue.Text,0) + StrToFloatDef(edtDeviation.Text,0));
    edtLower.Text :=  FloatToStr(StrToFloatDef(edtValue.Text,0) - StrToFloatDef(edtDeviation.Text,0));
end;

procedure TfData.edtDeviationChange(Sender: TObject);
begin
    edtUpper.Text :=  FloatToStr(StrToFloatDef(edtValue.Text,0) + StrToFloatDef(edtDeviation.Text,0));
    edtLower.Text :=  FloatToStr(StrToFloatDef(edtValue.Text,0) - StrToFloatDef(edtDeviation.Text,0));
end;

end.
