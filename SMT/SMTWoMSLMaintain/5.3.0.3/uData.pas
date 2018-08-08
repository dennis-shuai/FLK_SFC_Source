unit uData;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB;

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
      Label8: TLabel;
    labLine: TLabel;
      edtPart: TEdit;
    labMachine: TLabel;
    lablStation: TLabel;
    editStationNo: TEdit;
    Label2: TLabel;
    editLocation: TEdit;
    Label5: TLabel;
    editSEQ: TEdit;
    Label7: TLabel;
    editNozzle: TEdit;
    Label9: TLabel;
    editFedder: TEdit;
    Image2: TImage;
    sbtnFilter: TSpeedButton;
    labMsl: TLabel;
    Label3: TLabel;
    labSide: TLabel;
    editQty: TEdit;
    Label4: TLabel;
      procedure sbtnCancelClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure sbtnSaveClick(Sender: TObject);
    procedure sbtnFilterClick(Sender: TObject);
    procedure editQtyKeyPress(Sender: TObject; var Key: Char);
   private
    { Private declarations }
      procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
      procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
   public
    { Public declarations }
      MaintainType: string;
      G_sStationNo, gsLocation:String;
      procedure SetTheRegion;
   end;

var
   fData: TfData;

implementation

uses uformMain, uFilter;

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
var PartID : string;
    tsLocation, tsNew:TStringList;
    sLocation,sSEQ,sTemp,sWoSequence:String;
    iIndex, i:integer;
    iReal : Real;
    procedure InsertSubMsl(PartId,ItemPArt: string);
    var i: Integer;
    begin
      // 新增一筆 Sub BOM 紀錄
      try
         with formMain.QryTemp do
         begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString	,'wo_sequence', ptInput);
            Params.CreateParam(ftString	,'ITEM_PART_Id', ptInput);
            Params.CreateParam(ftString	,'SUB_PART_ID', ptInput);
            CommandText := 'Insert Into SMT.G_WO_MSL_SUB '
                         + ' (WO_SEQUENCE,ITEM_PART_Id,SUB_PART_ID) '
                         + ' VALUES '
                         + ' (:WO_SEQUENCE,:ITEM_PART_Id,:SUB_PART_ID) ';
            Params.ParamByName('WO_SEQUENCE').AsString := labMsl.Caption;
            Params.ParamByName('ITEM_PART_Id').AsString := PartId;
            Params.ParamByName('SUB_PART_ID').AsString := ItemPart;
            Execute;
            Close;
         end;
      except
         MessageDlg('Database Error !!' + #13#10 +
            'could not save to Database !!', mtError, [mbCancel], 0);
         Exit;
      end;
    end;
    procedure InsertMsl(PartId: string);
    var i: Integer;
    begin
      // 新增一筆 BOM 紀錄
      try
         with formMain.QryTemp do
         begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString	,'wo_sequence', ptInput);
            Params.CreateParam(ftString	,'STATION_NO', ptInput);
            Params.CreateParam(ftString	,'ITEM_PART_Id', ptInput);
            Params.CreateParam(ftString	,'ITEM_COUNT', ptInput);
            Params.CreateParam(ftString	,'LOCATION', ptInput);
            Params.CreateParam(ftString	,'FEDDER', ptInput);
            CommandText := 'Insert Into SMT.G_WO_MSL_DETAIL '
                         + ' (WO_SEQUENCE,STATION_NO,ITEM_PART_Id,ITEM_COUNT,LOCATION,FEDDER) '
                         + ' VALUES '
                         + ' (:WO_SEQUENCE,:STATION_NO,:ITEM_PART_Id,:ITEM_COUNT, :LOCATION, :FEDDER) ';
            //for i := 0 to tsNew.Count - 1 do
            //begin
              Close;
              Params.ParamByName('WO_SEQUENCE').AsString := labMsl.Caption;
              Params.ParamByName('STATION_NO').AsString := editStationNo.Text;
              Params.ParamByName('ITEM_PART_Id').AsString := PartId;
              Params.ParamByName('ITEM_COUNT').AsString := editQty.Text ;
              Params.ParamByName('FEDDER').AsString := editFedder.Text;
              Params.ParamByName('LOCATION').AsString := editLocation.Text;//tsNew[i];
//              Params.ParamByName('NOZZLE').AsString := editNozzle.Text;
//              Params.ParamByName('SEQ').AsString :='';
              Execute;
              Close;
            //end;
         end;
      except
         MessageDlg('Database Error !!' + #13#10 +
            'could not save to Database !!', mtError, [mbCancel], 0);
         Exit;
      end;
    end;
begin
   editStationNo.Text := trim(editStationNo.Text);
   edtPart.Text := trim(edtPart.Text);
   editFedder.Text:=trim(editFedder.Text) ;
   if editStationNo.Text = '' then
   begin
     MessageDlg('Please Input Station No!!',mtError,[mbOK],0);
     editStationNo.SetFocus;
     exit;
   end;
   if edtPart.Text = '' then
   begin
     MessageDlg('Please Input Part No!!',mtError,[mbOK],0);
     edtPart.SetFocus;
     exit;
   end;
   if editFedder.Text = '' then
   begin
     MessageDlg('Please Input Feeder!!',mtError,[mbOK],0);
     editFedder.SetFocus;
     exit;
   end;
   PartID := '';
   if not formMain.GetPartNoID(edtPart.Text, PartId) then
   begin
      edtPart.SetFocus;
      edtPart.SelectAll;
      Exit;
   end;
   Try
      iReal := StrToFloat(editQty.Text);
   except
      editQty.SetFocus;
      editQty.SelectAll;
      Exit;
   end;

   try
     (* 2005 12 31 決定先不卡太多限制
     tsNew := TStringList.Create;
     tsNew.CommaText := editLocation.Text;
     //檢查是否有重覆的Location
     with formMain.QryTemp do
     begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString, 'wo_sequence', ptInput);
       Params.CreateParam(ftString, 'location', ptInput);
       if MaintainType = 'Modify' then
         Params.CreateParam(ftString, 'station', ptInput);
       CommandText := 'select station_no from smt.g_wo_msl_detail '
                    + 'where wo_sequence = :wo_sequence '
                    + 'and location Like :location ';
       if MaintainType = 'Modify' then
         CommandText := CommandText + 'and station_no <> :station ';
       CommandText := CommandText + 'and rownum = 1 ';
       Close;
       for i := 0 to tsNew.Count - 1 do
       begin
         Close;
         Params.ParamByName('wo_sequence').AsString := labMsl.Caption;
         Params.ParamByName('location').AsString := '%'+tsNew[i]+'%';
         if MaintainType = 'Modify' then
           Params.ParamByName('station').AsString := G_sStationNo;
         Open;
         if not IsEmpty then
         begin
           MessageDlg('Location Duplicate.' + #10#13
             + 'Station: ' + FieldByName('station_no').AsString + #10#13
             + 'Location: ' + tsNew[i] ,mtError,[mbOK],0);
           editLocation.SetFocus;
           Exit;
         end;
       end;
     end;
     *)
     if MaintainType = 'Append' then
     begin
        with formMain.QryTemp do
        begin
               //檢查Station No是否重複
               Close;
               Params.Clear;
               Params.CreateParam(ftString	,'wo_sequence', ptInput);
               Params.CreateParam(ftString	,'STATION_NO', ptInput);
               CommandText := ' select station_no '
                            + '   from SMT.G_WO_MSL_DETAIL A '
                            + '  WHERE A.WO_SEQUENCE = :WO_SEQUENCE '
                            + '    AND STATION_NO = :STATION_NO '
                            + '    AND ROWNUM = 1 ';
               Params.ParamByName('WO_SEQUENCE').AsString := labMsl.Caption;
               Params.ParamByName('STATION_NO').AsString := editStationNo.Text;
               open;
               if not eof then
               begin
                 close;
                 MessageDlg('Station No Duplicate!!' ,mtError,[mbOK],0);
                 editStationNo.SetFocus;
                 editStationNo.SelectAll;
                 exit;
               end;
        end;
        InsertMsl(PartID);
        MessageDlg('Station: '+editStationNo.Text + #10#13 +' Append OK!!', mtCustom, [mbOK], 0);
        ModalResult := mrOK;
     end
     else if MaintainType = 'Modify' then
     begin
       // tsLocation := TStringList.Create;
       // tsLocation.CommaText := gsLocation;
        try
           with formMain.QryTemp do
           begin
             {if G_sStationNo <> editStationNo.Text then
             begin
                //檢查Station No是否重複
                Close;
                Params.Clear;
                Params.CreateParam(ftString	,'wo_sequence', ptInput);
                Params.CreateParam(ftString	,'STATION_NO', ptInput);
                CommandText := 'select station_no '
                             + '   from SMT.G_WO_MSL_DETAIL A '
                             + '  WHERE A.WO_SEQUENCE = :WO_SEQUENCE '
                             + '    AND STATION_NO = :STATION_NO '
                             + '    AND ROWNUM = 1 ';
                Params.ParamByName('WO_SEQUENCE').AsString := labMsl.Caption;
                Params.ParamByName('STATION_NO').AsString := editStationNo.Text;
                open;
                if not eof then
                begin
                  close;
                  MessageDlg('Station No Duplicate!!' ,mtError,[mbOK],0);
                  editStationNo.SetFocus;
                  editStationNo.SelectAll;
                  exit;
                end;
              end; }
              Close;
              Params.Clear;
              Params.CreateParam(ftString	,'wo_sequence', ptInput);
              Params.CreateParam(ftString	,'STATION_NO', ptInput);
              CommandText := 'delete from smt.g_wo_msl_detail '
                           + 'Where WO_SEQUENCE =:WO_SEQUENCE '
                           + '  and station_no = :station_no ';
              Params.ParamByName('WO_SEQUENCE').AsString := labMsl.Caption;
              Params.ParamByName('STATION_NO').AsString := G_sStationNo;
              Execute;
              Close;
              InsertMsl(PartID);
              MessageDlg('Station: '+editStationNo.Text + #10#13 + ' Modify OK!!', mtCustom, [mbOK], 0);
              ModalResult := mrOK;
           end;
        except
           MessageDlg('Database Error !!' + #13#10 +
              'could not Update Database !!', mtError, [mbCancel], 0);
           Exit;
        end;
     end;
   finally
     //tsNew.Free;
     //tsLocation.Free;
   end;
end;

procedure TfData.sbtnFilterClick(Sender: TObject);
begin
  TRY
    with TfFilter.Create(Self) do
    begin
      qryData.RemoteServer := formMain.QryTemp.RemoteServer;
      qryData.Close;
      qryData.Params.Clear;
      qryData.CommandText := '  SELECT Part_No '
                           + '   FROM SAJET.SYS_PART '
                           + '   WHERE PART_NO LIKE :PART_NO '
                           + '   ORDER BY PART_NO ';
      qryData.Params.ParamByName('PART_NO').AsString := Trim(edtPart.Text) + '%';
      qryData.Open;
      if not qryData.IsEmpty then
      begin
         if Showmodal = mrOK then
         begin
            edtPart.Text := qryData.Fieldbyname('PART_NO').AsString;
         end;
      end;
      qryData.Close;
    end;
  finally
    fFilter.free;
  end;
end;

procedure TfData.editQtyKeyPress(Sender: TObject; var Key: Char);
begin
     if not (KEY in ['0'..'9',#13,#8]) then Key:=#0;
end;

end.

