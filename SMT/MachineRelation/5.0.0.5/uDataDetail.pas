unit uDataDetail;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB, Grids, DBGrids;

type
   TfDataDetail = class(TForm)
      sbtnCancel: TSpeedButton;
      Label4: TLabel;
      Image1: TImage;
      Label6: TLabel;
      LabType1: TLabel;
      LabType2: TLabel;
      Imagemain: TImage;
      Label1: TLabel;
      Label2: TLabel;
      Label5: TLabel;
      LabPartNo: TLabel;
      editCartonQty: TEdit;
      editPalletQty: TEdit;
      Image5: TImage;
      Label3: TLabel;
      sbtnSave: TSpeedButton;
      combCode: TComboBox;
      procedure sbtnCancelClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure sbtnSaveClick(Sender: TObject);
      procedure combCodeChange(Sender: TObject);
   private
    { Private declarations }
      procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
      procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
   public
    { Public declarations }
      MaintainType: string;
      PartID: string;
      procedure CopyToHistory(RecordID: string);
      procedure SetTheRegion;
   end;

var
   fDataDetail: TfDataDetail;

implementation

{$R *.DFM}
uses uTestItem, uData;

procedure TfDataDetail.sbtnCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TfDataDetail.FormCreate(Sender: TObject);
begin
   Imagemain.Picture := fData.Imagemain.Picture;
   SetTheRegion;
end;

procedure TfDataDetail.SetTheRegion;
var HR: HRGN;
begin
   HR := BmpToRegion(Self, Imagemain.Picture.Bitmap);
   SetWindowRgn(handle, HR, true);
   Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.

procedure TfDataDetail.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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

procedure TfDataDetail.WMNCHitTest(var msg: TWMNCHitTest);
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

procedure TfDataDetail.sbtnSaveClick(Sender: TObject);
var S: string; sPartId: string; I: Integer;
   sRouteID: string;
begin
   if Trim(combCode.Text) = '' then
   begin
      MessageDlg('Packing Code Error !!', mtError, [mbCancel], 0);
      combCode.SetFocus;
      Exit;
   end;

   if StrToIntDef(editCartonQty.Text, 0) = 0 then
   begin
      MessageDlg('Carton Capacity Error !!', mtError, [mbCancel], 0);
      editCartonQty.SetFocus;
      editCartonQty.SelectAll;
      Exit;
   end;

   if StrToIntDef(editPalletQty.Text, 0) = 0 then
   begin
      MessageDlg('Pallet Capacity Error !!', mtError, [mbCancel], 0);
      editPalletQty.SetFocus;
      editPalletQty.SelectAll;
      Exit;
   end;

     // 檢查是否重複
   with fTestITem.QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PART_ID', ptInput);
      Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
      CommandText := 'Select PART_ID ' +
         'From SAJET.SYS_PART_PKSPEC ' +
         'Where PART_ID = :PART_ID and ' +
         'PKSPEC_NAME = :PKSPEC_NAME';
      Params.ParamByName('PART_ID').AsString := PartId;
      Params.ParamByName('PKSPEC_NAME').AsString := combCode.Text;
      Open;
      if RecordCount > 0 then
      begin
         S := 'Packing Spec. Duplicate !! ';
         Close;
         MessageDlg(S, mtError, [mbCancel], 0);
         Exit;
      end;
   end;
   
   if MaintainType = 'Append' then
   begin
     // 新增一筆 PACKING SPEC 紀錄
      try
         with fTestItem.QryTemp do
         begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'PART_ID', ptInput);
            Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
//            Params.CreateParam(ftString, 'CARTON_QTY', ptInput);
//            Params.CreateParam(ftString, 'PALLET_QTY', ptInput);
            Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
            CommandText := 'Insert Into SAJET.SYS_PART_PKSPEC ' +
               ' (PART_ID,PKSPEC_NAME,CARTON_QTY,PALLET_QTY,UPDATE_USERID) ' +
               'Values (:PART_ID,:PKSPEC_NAME,:CARTON_QTY,:PALLET_QTY,:UPDATE_USERID) ';
            Params.ParamByName('PART_ID').AsString := PartId;
            Params.ParamByName('PKSPEC_NAME').AsString := Trim(combCode.Text);
            Params.ParamByName('CARTON_QTY').AsString := ''; //Trim(editCartonQty.Text);
            Params.ParamByName('PALLET_QTY').AsString := '';
            Params.ParamByName('UPDATE_USERID').AsString := fTestItem.UpdateUserID;
            Execute;
            CopyToHistory(PartId);
         end;
      except
         MessageDlg('Database Error !!' + #13#10 +
            'could not save to Database !!', mtError, [mbCancel], 0);
         Exit;
      end;

      MessageDlg('Packing Spec. Data Append OK!!', mtCustom, [mbOK], 0);
      if MessageDlg('Append Other Data ?', mtCustom, mbOKCancel, 0) = mrOK then
      begin
         combCode.ItemIndex := -1;
         editCartonQty.Text := '1';
         editPalletQty.Text := '1';
         combCode.SetFocus;
         Exit;
      end;
   end;

   if MaintainType = 'Modify' then
   begin
      try
         with fTestItem.QryTemp do
         begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'PKSPEC_NAME1', ptInput);
//            Params.CreateParam(ftString, 'CARTON_QTY', ptInput);
//            Params.CreateParam(ftString, 'PALLET_QTY', ptInput);
            Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
            Params.CreateParam(ftString, 'PART_ID', ptInput);
            Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
            CommandText := 'Update SAJET.SYS_PART_PKSPEC ' +
               'Set PKSPEC_NAME = :PKSPEC_NAME1,' +
//               'CARTON_QTY = :CARTON_QTY,' +
//               'PALLET_QTY = :PALLET_QTY,' +
               'UPDATE_USERID = :UPDATE_USERID,' +
               'UPDATE_TIME = SYSDATE ' +
               'Where PART_ID = :PART_ID and ' +
               'PKSPEC_NAME = :PKSPEC_NAME';
            Params.ParamByName('PKSPEC_NAME1').AsString := Trim(combCode.Text);
//            Params.ParamByName('CARTON_QTY').AsString := Trim(editCartonQty.Text);
//            Params.ParamByName('PALLET_QTY').AsString := Trim(editPalletQty.Text);
            Params.ParamByName('UPDATE_USERID').AsString := fTestItem.UpdateUserID;
            Params.ParamByName('PART_ID').AsString := PartId;
            Params.ParamByName('PKSPEC_NAME').AsString := fTestItem.QryData1.Fieldbyname('PKSPEC_NAME').aSString;
            Execute;
            CopyToHistory(PartID);
            MessageDlg('Packing Spec. Data Update OK!!', mtCustom, [mbOK], 0);
            ModalResult := mrOK;
         end;
      except
         MessageDlg('Database Error !!' + #13#10 +
            'could not Update Database !!', mtError, [mbCancel], 0);
         Exit;
      end;
   end;
   ModalResult := mrOK
end;

procedure TfDataDetail.CopyToHistory(RecordID: string);
begin
   with fTestItem.QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PARTID', ptInput);
      Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
      CommandText := 'Insert Into SAJET.SYS_HT_PART_PKSPEC ' +
         'Select * from SAJET.SYS_PART_PKSPEC ' +
         'Where PART_ID = :PARTID and ' +
         'PKSPEC_NAME = :PKSPEC_NAME';
      Params.ParamByName('PARTID').AsString := PartID;
      Params.ParamByName('PKSPEC_NAME').AsString := combCode.Text;
      Execute;
   end;
end;

procedure TfDataDetail.combCodeChange(Sender: TObject);
begin
   with fTestItem.QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
      CommandText := 'select * from SAJET.SYS_PKSPEC ' +
         'Where PKSPEC_NAME = :PKSPEC_NAME';
      Params.ParamByName('PKSPEC_NAME').AsString := combCode.Text;
      Open;
      editCartonQty.Text := Fieldbyname('CARTON_QTY').aSString;
      editPalletQty.Text := Fieldbyname('PALLET_QTY').aSString;
   end;
end;

end.

