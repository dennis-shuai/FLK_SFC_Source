unit uData;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB;

type
   TfData = class(TForm)
      sbtnCancel: TSpeedButton;
      sbtnSave: TSpeedButton;
      Label3: TLabel;
      Image5: TImage;
      Label4: TLabel;
      Image1: TImage;
      Label6: TLabel;
      LabType1: TLabel;
      LabType2: TLabel;
      Imagemain: TImage;
      Label1: TLabel;
      Label8: TLabel;
      labMSL: TLabel;
      edtPart: TEdit;
      labSlot: TLabel;
    Label2: TLabel;
    EditItemCount: TEdit;
    Label5: TLabel;
    Label7: TLabel;
    EditLocation: TEdit;
    CombSide: TComboBox;
    EditFeeder: TEdit;
    Label9: TLabel;
      procedure sbtnCancelClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure sbtnSaveClick(Sender: TObject);
   private
    { Private declarations }
      procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
      procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
   public
    { Public declarations }
      MaintainType: string;
      procedure CopyToHistory(RecordID: string);
      procedure SetTheRegion;
   end;

var
   fData: TfData;

implementation

uses uManager;

{$R *.DFM}

procedure TfData.sbtnCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TfData.FormCreate(Sender: TObject);
begin
   SetTheRegion;
end;

procedure TfData.SetTheRegion;
var HR: HRGN;
begin
   HR := BmpToRegion(Self, Imagemain.Picture.Bitmap);
   SetWindowRgn(handle, HR, true);
   Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.

procedure TfData.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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

procedure TfData.WMNCHitTest(var msg: TWMNCHitTest);
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

procedure TfData.sbtnSaveClick(Sender: TObject);
var PartID,PdlineID: string;
begin
   PartID := '';
   if not fManager.GetPartNoID(edtPart.Text, PartId) then
   begin
      edtPart.SetFocus;
      edtPart.SelectAll;
      Exit;
   end;
   if MaintainType = 'Append' then
   begin
      if edtPart.Text='' then
        begin
          Showmessage('Part No Null!');
          exit;
        end;
      if EditFeeder.Text='' then
        begin
          Showmessage('Feeder Type Null!');
          exit;
        end;
      if editItemCount.Text='' then
        begin
          Showmessage('Item Count Null!');
          exit;
        end;
      if editLocation.Text='' then
        begin
          Showmessage('Location Null!');
          exit;
        end;
      with fManager.QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'Msl_No', ptInput);
         Params.CreateParam(ftString, 'ITEM_PART_ID', ptInput);
         Params.CreateParam(ftString, 'SLOT_NO', ptInput);
         CommandText := 'Select PART_ID ' +
            'From SMT.g_msl ' +
            'Where Msl_No = :Msl_No and ' +
            'ITEM_PART_ID = :ITEM_PART_ID and '+
            'SLOT_NO =:SLOT_NO ';
         Params.ParamByName('Msl_No').AsString := labMsl.Caption;
         Params.ParamByName('ITEM_PART_ID').AsString := PartId;
         Params.ParamByName('SLOT_NO').AsString := LabSlot.Caption;
         Open; ;
         if RecordCount > 0 then
         begin
            Close;
            MessageDlg('Sub Part No Duplicate !!', mtCustom, [mbOK], 0);
            edtPart.SetFocus;
            edtPart.SelectAll;
            Exit;
         end;
         Close;
      end;
     // ·s¼W¤@µ§ BOM ¬ö¿ý
      try
         with fManager.QryTemp do
         begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'ITEM_PART_ID', ptInput);
            Params.CreateParam(ftString, 'EMP_ID', ptInput);
            Params.CreateParam(ftString, 'Msl_No', ptInput);
            Params.CreateParam(ftString, 'Slot_No', ptInput);
            Params.CreateParam(ftString, 'ITEM_COUNT', ptInput);
            Params.CreateParam(ftString, 'SIDE', ptInput);
            Params.CreateParam(ftString, 'FEEDER', ptInput);
            CommandText := 'Insert Into SMT.g_msl ' +
               ' select MSL_NO,PDLINE_ID,PART_ID,MACHINE_ID,:SLOT_NO,' +
               ':FEEDER,:SIDE,:ITEM_PART_ID,:ITEM_COUNT,VERSION,:EMP_ID,sysdate,''M'',0 ' +
               'from smt.g_msl where msl_no = :msl_no and rownum = 1 ';
            Params.ParamByName('ITEM_PART_ID').AsString := PartId;
            Params.ParamByName('EMP_ID').AsString := fManager.UpdateUserID;
            Params.ParamByName('Msl_No').AsString := labMsl.Caption;
            Params.ParamByName('Slot_No').AsString := labSlot.Caption;
            Params.ParamByName('ITEM_COUNT').AsString := EditItemCount.Text;
            Params.ParamByName('SIDE').AsString := inttostr(CombSide.itemindex);
            Params.ParamByName('FEEDER').AsString := EditFeeder.Text;
            Execute;

            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'Msl_No', ptInput);
            Params.CreateParam(ftString, 'Slot_No', ptInput);
            CommandText := 'SELECT * FROM SMT.g_msl_location ' +
               ' where msl_no = :msl_no and slot_no = :slot_no and rownum = 1 ';
            Params.ParamByName('Msl_No').AsString := labMsl.Caption;
            Params.ParamByName('Slot_No').AsString := labSlot.Caption;
            open;
            if recordcount=0 then
            begin
              Close;
              Params.Clear;
              Params.CreateParam(ftString, 'EMP_ID', ptInput);
              Params.CreateParam(ftString, 'Msl_No', ptInput);
              Params.CreateParam(ftString, 'Slot_No', ptInput);
              Params.CreateParam(ftString, 'LOCATION', ptInput);
              CommandText := 'Insert Into SMT.g_msl_location ' +
                ' select MSL_NO,MACHINE_ID,SLOT_NO,' +
                ':LOCATION,:EMP_ID,sysdate ' +
                'from smt.g_msl where msl_no = :msl_no and slot_no = :slot_no and rownum = 1 ';
              Params.ParamByName('EMP_ID').AsString := fManager.UpdateUserID;
              Params.ParamByName('Msl_No').AsString := labMsl.Caption;
              Params.ParamByName('Slot_No').AsString := labSlot.Caption;
              Params.ParamByName('LOCATION').AsString := EditLocation.Text;
              Execute;
            end;
            Close;
         end;
      except
         MessageDlg('Database Error !!' + #13#10 +
            'could not save to Database !!', mtError, [mbCancel], 0);
         Exit;
      end;

      MessageDlg('BOM Data Save OK!!', mtCustom, [mbOK], 0);
      ModalResult := mrOK;
   end
   else if MaintainType = 'Modify' then
   begin
      try
         with fManager.QryTemp do
         begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'ITEM_PART_ID', ptInput);
            Params.CreateParam(ftString, 'MSL_No', ptInput);
            CommandText := 'Update SAJET.SYS_BOM ' +
               'Set ITEM_PART_ID = :ITEM_PART_ID ' +
               'Where msl_no = :msl_no and ' +
               'ITEM_PART_ID = :ITEM_PART_ID ';
            Params.ParamByName('MSL_No').AsString := labMSL.Caption;
            Params.ParamByName('ITEM_PART_ID').AsString := PartId;
            Params.ParamByName('UPDATE_USERID').AsString := fManager.UpdateUserID;
            Execute;
            Close;
            MessageDlg('Machine Data Update OK!!', mtCustom, [mbOK], 0);
            ModalResult := mrOK;
         end;
      except
         MessageDlg('Database Error !!' + #13#10 +
            'could not Update Database !!', mtError, [mbCancel], 0);
         Exit;
      end;
   end;
end;

procedure TfData.CopyToHistory(RecordID: string);
begin
{  With fBOM.QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'MACHINEID', ptInput);
     CommandText := 'Insert Into SAJET.SYS_HT_MACHINE_BASE_T '+
                      'Select * from SAJET.SYS_MACHINE_BASE_T '+
                      'Where MACHINE_ID = :MACHINEID ';
     Params.ParamByName('MACHINEID').AsString := RecordID;
     Execute;
  end;}
end;

end.

