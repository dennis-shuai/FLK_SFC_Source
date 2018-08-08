unit uKP1;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, Db,
   DBClient, MConnect, SConnect, IniFiles, Grids, DBGrids, Menus;

type
   TfKP1 = class(TForm)
      Imagemain: TImage;
      procedure sbtnCloseClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure editReasonKeyPress(Sender: TObject; var Key: Char);
      procedure editDutyKeyPress(Sender: TObject; var Key: Char);
      procedure sbtnSaveClick(Sender: TObject);
      procedure DBGrid1DblClick(Sender: TObject);
      procedure sbtnShowBomClick(Sender: TObject);
      procedure sbtnReasonClick(Sender: TObject);
    procedure editLocationKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure editItemKeyPress(Sender: TObject; var Key: Char);
    procedure Delete1Click(Sender: TObject);
    procedure gridLoSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure sbtnAddClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure editDutyChange(Sender: TObject);
    procedure editReasonChange(Sender: TObject);
   private
    { Private declarations }
      procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
      procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
   public
    { Public declarations }
      RecID: string;
      ReasonID: string;
      DutyID: string;
      sItemID :string;
      sString : TStrings;
      procedure SetTheRegion;
      function CheckReason: Boolean;
      function CheckDuty: Boolean;
      function CheckItem: Boolean;
      function GetItemID(PARTNO:STRing): String;
      procedure ShowLocation(sID: string);
   end;

var
   fKP1: TfKP1;

implementation

{$R *.DFM}
uses uRepair, uItem, uReason, uFilter;

function TfKP1.CheckReason: Boolean;
begin
   Result := False;
   with fRepair.QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'REASON_CODE', ptInput);
      CommandText := 'Select Reason_Id, Reason_Code, Reason_Desc,Enabled ' +
         'From SAJET.SYS_REASON ' +
         'Where REASON_CODE = :REASON_CODE ';
      Params.ParamByName('REASON_CODE').AsString := editReason.Text;
      Open;
      if RecordCount <= 0 then
      begin
         Close;
         MessageDlg('Reason Code error !!' + #13#10 +
            'Reason Code : ' + editReason.Text, mtError, [mbCancel], 0);
         Exit;
      end
      else
      begin
        IF Fieldbyname('Enabled').AsString <> 'Y' Then
        begin
           Close;
           MessageDlg('Reason Code Disabled !!' + #13#10 +
              'Reason Code : ' + editReason.Text, mtError, [mbCancel], 0);
           Exit;
        end
        else
        begin
           ReasonId := Fieldbyname('Reason_Id').AsString;
           LabReasonDesc.Caption := Fieldbyname('Reason_Desc').AsString;
           Close;
        end;
      end;
   end;
   Result := True;
end;

function TfKP1.CheckDuty: Boolean;
begin
   Result := False;
   with fRepair.QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'DUTY_CODE', ptInput);
      CommandText := 'Select Duty_Id, Duty_Code, Duty_Desc ,Enabled ' +
         'From SAJET.SYS_DUTY ' +
         'Where DUTY_CODE = :DUTY_CODE ';
      Params.ParamByName('DUTY_CODE').AsString := editDuty.Text;
      Open;
      if RecordCount <= 0 then
      begin
         Close;
         MessageDlg('Duty Code Error !!' + #13#10 +
            'Duty Code : ' + editDuty.Text, mtError, [mbCancel], 0);
         Exit;
      end
      else
        IF Fieldbyname('Enabled').AsString <> 'Y' Then
        begin
           Close;
           MessageDlg('Duty Code Disabled !!' + #13#10 +
              'Duty Code : ' + editDuty.Text, mtError, [mbCancel], 0);
           Exit;
        end
        else
        begin
          DutyId := Fieldbyname('Duty_Id').AsString;
          LabDutyDesc.Caption := Fieldbyname('Duty_Desc').AsString;
          Close;
        end;
   end;
   Result := True;
end;

procedure TfKP1.sbtnCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TfKP1.FormCreate(Sender: TObject);
begin
   SetTheRegion;
   sString:= TStringList.Create;
end;

procedure TfKP1.SetTheRegion;
var HR: HRGN;
begin
   HR := BmpToRegion(Self, Imagemain.Picture.Bitmap);
   SetWindowRgn(handle, HR, true);
   Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.

procedure TfKP1.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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

procedure TfKP1.WMNCHitTest(var msg: TWMNCHitTest);
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

procedure TfKP1.editReasonKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then
      if CheckReason then
         editDuty.SetFocus;
end;

procedure TfKP1.editDutyKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then
      if CheckDuty then
         editLocation.SetFocus;
end;

procedure TfKP1.sbtnSaveClick(Sender: TObject);
var I: Integer; B: Boolean;
    sPart,sPartID :String;
begin
   if not CheckReason then Exit;
   if not CheckDuty then Exit;
   //if not CheckItem then Exit;  // 檢查Item 有沒有在Bom中
    B := False;
   for I := 0 to fRepair.LVReason.Items.Count - 1 do
   begin
      if editReason.Text = fRepair.LVReason.Items[I].Caption then
      begin
         B := True;
         Break;
      end;
   end;

   if B then
   begin
      MessageDlg('Reason Code Duplicate !!' + #13#10 +
         'Reason Code : ' + editReason.Text, mtError, [mbCancel], 0);
      Exit;
   end;
   
   try
      with fRepair.QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'RECID', ptInput);
         Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
         Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
         Params.CreateParam(ftString, 'MODEL_ID', ptInput);
         Params.CreateParam(ftString, 'REPAIR_EMP_ID', ptInput);
         Params.CreateParam(ftString, 'REASON_ID', ptInput);
         Params.CreateParam(ftString, 'DUTY_PROCESS_ID', ptInput);
         Params.CreateParam(ftString, 'DUTY_ID', ptInput);
         Params.CreateParam(ftString, 'ITEM_ID', ptInput);
         Params.CreateParam(ftString, 'RECORD_TYPE', ptInput);
         Params.CreateParam(ftString, 'REMARK', ptInput);
         Params.CreateParam(ftString, 'LOCATION', ptInput);
         Params.CreateParam(ftString, 'TERMINALID', ptInput);
         CommandText := 'Insert Into SAJET.G_SN_REPAIR ' +
            '(RECID,SERIAL_NUMBER,WORK_ORDER,MODEL_ID,REPAIR_EMP_ID,REASON_ID,' +
            ' RP_TERMINAL_ID,RP_PROCESS_ID,RP_STAGE_ID,DUTY_PROCESS_ID,DUTY_ID,' +
            ' ITEM_ID,RECORD_TYPE,REMARK,LOCATION  ) ' +
            'Select :RECID RECID,:SERIAL_NUMBER SERIAL_NUMBER,:WORK_ORDER WORK_ORDER,:MODEL_ID MODEL_ID,:REPAIR_EMP_ID REPAIR_EMP_ID,:REASON_ID REASON_ID,' +
            ' TERMINAL_ID RP_TERMINAL_ID,PROCESS_ID RP_PROCESS_ID,STAGE_ID RP_STAGE_ID,' +
            ' :DUTY_PROCESS_ID DUTY_PROCESS_ID,:DUTY_ID DUTY_ID,:ITEM_ID ITEM_ID,:RECORD_TYPE RECORD_TYPE,:REMARK REMARK,:LOCATION LOCATION ' +
            'From SAJET.SYS_TERMINAL ' +
            'Where TERMINAL_ID = :TERMINALID ';
         Params.ParamByName('RECID').AsString := RecId;
         Params.ParamByName('SERIAL_NUMBER').AsString := fRepair.gbSN;
         Params.ParamByName('WORK_ORDER').AsString := fRepair.LabWO.Caption;
         Params.ParamByName('MODEL_ID').AsString := fRepair.mPartId;
         Params.ParamByName('REPAIR_EMP_ID').AsString := fRepair.UpdateUserID;
         Params.ParamByName('REASON_ID').AsString := ReasonID;
         Params.ParamByName('DUTY_PROCESS_ID').AsString := '0';
         Params.ParamByName('DUTY_ID').AsString := DutyId;
         Params.ParamByName('ITEM_ID').AsString := sItemID;
         Params.ParamByName('RECORD_TYPE').AsString := '';
         Params.ParamByName('REMARK').AsString := '';
         Params.ParamByName('LOCATION').AsString := editLocation.Text;
         Params.ParamByName('TERMINALID').AsString := fRepair.TerminalID;
         Execute;
      end;
   except
      MessageDlg('Append Defect Reason Error !!', mtError, [mbCancel], 0);
      Exit;
   end;

   // 2006 02 13 新增Location 另外存Table
   try
      with fRepair.QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'RECID', ptInput);
         Params.CreateParam(ftString, 'REASON', ptInput);
         CommandText := 'Delete SAJET.G_SN_REPAIR_LOCATION ' +
                        'WHERE RECID = :RECID ' +
                        'AND REASON_ID = :REASON ';
         Params.ParamByName('RECID').AsString := RecId;
         Params.ParamByName('REASON').AsString := ReasonID;
         Execute;
         Close;
      end;
      for I := 1 to gridLo.RowCount - 1 do
       if (Trim(gridLo.Cells[1,I]) <> '') or (Trim(gridLo.Cells[2,I]) <> '')then
       begin
          sPartID := GetItemID(gridLo.Cells[2,I]);
          with fRepair.QryTemp do
          begin
             Close;
             Params.Clear;
             Params.CreateParam(ftString, 'RECID', ptInput);
             Params.CreateParam(ftString, 'LOCATION', ptInput);
             Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
             Params.CreateParam(ftString, 'ITEM_NO', ptInput);
             Params.CreateParam(ftString, 'REASON_ID', ptInput);
             Params.CreateParam(ftString, 'ITEM_ID', ptInput);
             CommandText := 'Insert Into SAJET.G_SN_REPAIR_LOCATION ' +
                            '        (RECID,LOCATION,UPDATE_USERID,UPDATE_TIME,ITEM_NO,REASON_ID,ITEM_ID) ' +
                             'VALUES (:RECID,:LOCATION,:UPDATE_USERID,SYSDATE,:ITEM_NO,:REASON_ID,:ITEM_ID) ';
             Params.ParamByName('RECID').AsString := RecId;
             Params.ParamByName('LOCATION').AsString := gridLo.Cells[1,I];
             Params.ParamByName('UPDATE_USERID').AsString := fRepair.UpdateUserID;
             Params.ParamByName('ITEM_NO').AsString := gridLo.Cells[2,I];
             Params.ParamByName('REASON_ID').AsString := ReasonID;
             Params.ParamByName('ITEM_ID').AsString := sPartID;
             Execute;
         end;
       end;
   except
      MessageDlg('Append Location Error !!', mtError, [mbCancel], 0);
      Exit;
   end;

   try
      with fRepair.QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'RECID', ptInput);
         Params.CreateParam(ftString, 'REPAIR_REMARK', ptInput);
         Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
         CommandText := 'Insert Into SAJET.G_SN_REPAIR_REMARK ' +
            '(RECID,REPAIR_REMARK,UPDATE_USERID ) ' +
            'VALUES (:RECID,:REPAIR_REMARK,:UPDATE_USERID)';
         for I := 0 to Remark.Lines.Count - 1 do
            if Trim(Remark.Lines[I]) <> '' then
            begin
               Params.ParamByName('RECID').AsString := RecId;
               Params.ParamByName('REPAIR_REMARK').AsString := Trim(Remark.Lines[I]);
               Params.ParamByName('UPDATE_USERID').AsString := fRepair.UpdateUserID;
               Execute;
            end;
      end;
   except
      MessageDlg('Append Defect Reason Error !!', mtError, [mbCancel], 0);
      Exit;
   end;

   ModalResult := mrOK;
end;

function TfKP1.CheckItem: Boolean;
var iItemIndex: integer;
begin
   Result := False;
   //Check Item是否在BOM中  --2005/10/31
   sItemID:='0';
   if trim(editItem.Text)<>'' then
   begin
     iItemIndex:=fRepair.g_tsItemPart.IndexOf(trim(editItem.Text));
     if iItemIndex=-1 then
     begin
       MessageDlg('Item Error',mtError,[mbOK],0);
       Exit;
     end else
     begin
       sItemID:=fRepair.g_tsItem.Strings[iItemIndex*g_iCol];
     end;
   end;
   Result := True;
end;

procedure TfKP1.DBGrid1DblClick(Sender: TObject);
begin
   editReason.Text := DBGrid1.Fields[0].AsString;
   if CheckReason then
      editDuty.SetFocus;
end;

procedure TfKP1.sbtnShowBomClick(Sender: TObject);
Var
   K :Char;
begin
   fItem := TfItem.Create(Self);
   with fItem do
   begin
      QryTemp.RemoteServer := fRepair.QryData.RemoteServer;
      QryTemp.ProviderName := 'DspQryTemp1';
      g_sItemFilter:=trim(editItem.Text);
      g_sLocation:=trim(editLocation.Text);
      ShowListView;
      if ShowModal= mrOK then
      begin
        editItem.Text:= LVItem.Selected.Caption;
        editItem.SetFocus;
        editItem.SelectAll;
      end;
      Free;
   end;
   // K := #13;
   //editItemKeyPress(self,K);
end;

procedure TfKP1.sbtnReasonClick(Sender: TObject);
begin
   fReason := TfReason.Create(Self);
   with fReason do
   begin
      QryTemp.RemoteServer := fRepair.QryData.RemoteServer;
      QryTemp.ProviderName := 'DspQryTemp1';
      ShowReasonList;
      if ShowModal= mrOK then
      begin
        editReason.Text:= Copy(TreeReason.Selected.Text,1,pos('..(',TreeReason.Selected.Text)-1);
        CheckReason;
        editReason.SetFocus;
        editReason.SelectAll;
      end;
      Free;
   end;
end;

procedure TfKP1.editLocationKeyPress(Sender: TObject; var Key: Char);
begin
  if key <> #13 then
     Exit
  else
     editItem.SetFocus;


end;

procedure TfKP1.FormShow(Sender: TObject);
Var
   I :Integer;
begin
     gridLo.RowCount := 2;
     gridLo.Cells[1,0] := 'Location';
     gridLo.Cells[2,0] := 'Item No';
     //ShowLocation(RecID);
end;

procedure TfKP1.ShowLocation(sID: string);
Var Irow : Integer;
begin
   Irow := 0;
   with fRepair.QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'recid', ptInput);
      CommandText := 'Select RECID,LOCATION,ITEM_NO,UPDATE_USERID ' +
                     'From SAJET.G_SN_REPAIR_LOCATION ' +
                     'WHERE RECID = :RECID ' +
                     'ORDER BY LOCATION ';
      Params.ParamByName('recid').AsString := sID;
      Open;
      IF RecordCount <> 0 Then
      begin
        gridLo.RowCount := RecordCount+1 ;
        While Not EOF Do
        begin
          gridLo.Cells[1,Irow+1] := FieldByName('LOCATION').AsSTring;
          gridLo.Cells[2,Irow+1] := FieldByName('ITEM_NO').AsSTring;
          Inc(iRow);
          Next;
        end;
      end;
      Close;
   end;
end;

procedure TfKP1.editItemKeyPress(Sender: TObject; var Key: Char);
Var
  iRow : Integer;
begin
 IF Key <> #13 Then
    Exit;
 IF Trim(editItem.text) = '' Then
    Exit;    
 with fRepair.QryTemp do
  begin
     Close;
     Params.Clear;
     if editLocation.Text <> '' THEN
        Params.CreateParam(ftString, 'location', ptInput);
     Params.CreateParam(ftString, 'wo', ptInput);
     Params.CreateParam(ftString, 'part', ptInput);
     CommandText := 'Select b.part_no from SAJET.G_WO_BOM a, sajet.sys_part b '
                  + 'where a.work_order = :wo '
                  + 'and b.part_no = :part ';

     if editLocation.Text <> '' THEN
          CommandText := CommandText + 'and a.location = :location ';

     CommandText := CommandText + 'and a.item_part_id = b.part_id '
                                + 'group by b.part_no '
                                + 'order by b.part_no ';
     if editLocation.Text <> '' THEN
         Params.ParamByName('location').AsString := editLocation.Text;
     Params.ParamByName('wo').AsString := fRepair.LabWO.Caption;
     Params.ParamByName('part').AsString := editItem.text;
     open;
     if RecordCount = 0 then
       // MessageDlg('Part No and Location Check Fail!!',mtConfirmation,[mbOK],0)
     else   
        sbtnAddClick(Self);

  end;

end;

procedure TfKP1.Delete1Click(Sender: TObject);
Var i,T : Integer;
begin
    if sSTring.Count = 0 tHEN
    begin
       ShowMessage('Please Choose Data !!');
       eXIT;
    end;
    // 針對尚未存入資料庫的資料
    IF (sSTring.Strings[0] = '') and (sSTring.Strings[1] = '') Then
       EXIT;
    If MessageDlg('Sure to Delete Data !? ',mtConfirmation, [mbYes, mbNo],0) = mrYes then
    begin
      For I := 0 To GridLo.RowCount -1 Do
      begin
        IF GridLo.Cells[1,I] = sSTring.Strings[0] Then
           IF GridLo.Cells[2,I] = sSTring.Strings[1] Then
           begin
              For T := I To  GridLo.RowCount-1 Do
              begin
                GridLo.Cells[1,T] := GridLo.Cells[1,T+1];
                GridLo.Cells[2,T] := GridLo.Cells[2,T+1];
              end;
           end;
      end;
      GridLo.Rows[GridLo.RowCount-1].Clear;
      IF GridLo.RowCount > 2 Then
         GridLo.RowCount := GridLo.RowCount-1;
    end;
end;

procedure TfKP1.gridLoSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
    sSTring.Clear;
    sSTring.add(GridLo.Cells[1,ARow]);
    sSTring.add(GridLo.Cells[2,ARow]);
end;

procedure TfKP1.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if DBGrid1.Columns.Items[3].Field.text = 'N' then
    DBGrid1.Canvas.Font.Color:=clRed;
 // else
 //   DBGrid1.Canvas.Brush.Color:=clYellow;

 // DBGrid1.Canvas.Font.Color:=clGreen;
  DBGrid1.DefaultDrawDataCell(rect,Column.Field,State);
end;

procedure TfKP1.sbtnAddClick(Sender: TObject);
Var
  iRow : Integer;
begin
     if (TRIM(editLocation.Text)='') AND (TRIM(editItem.Text)='') Then
         Exit;
        // Check duplication
        For iRow := 1 To GridLo.RowCount -1 Do
        begin
           IF GridLo.Cells[1,iRow] =  Trim(editLocation.Text) Then
           begin
              IF GridLo.Cells[2,iRow] = Trim(editItem.Text) Then
              begin
                  ShowMessage('Data Duplication!');
                  Exit;
              end;
           end;
        end;
        iRow := GridLo.RowCount -1 ;
        GridLo.RowCount := GridLo.RowCount  + 1;
        GridLo.Cells[1,iRow] := Trim(editLocation.Text);
        GridLo.Cells[2,iRow] := Trim(editItem.Text);
end;

function TfKP1.GetItemID(PARTNO:STRing): String;
begin

   with fRepair.QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PART_NO', ptInput);
      CommandText := 'Select PART_ID ' +
         'From SAJET.SYS_PART ' +
         'Where PART_NO = :PART_NO ';
      Params.ParamByName('PART_NO').AsString := PARTNO;
      Open;
      if RecordCount <= 0 then
      begin
         Result :=  '';
      end
      else
        Result := FieldByName('PART_ID').AsString;
      Close;
   end;
end;

procedure TfKP1.SpeedButton1Click(Sender: TObject);

var K:Char;
begin
   with TfFilter.Create(Self) do
   begin
      with QryData do
      begin
        RemoteServer:=fRepair.QryData.RemoteServer;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'Duty_Code', ptInput);
        CommandText := 'Select Duty_Code "Duty Code", Duty_Desc "Duty Desc" '
                     + 'From SAJET.SYS_DUTY '
                     + 'Where Duty_Code Like :Duty_Code '
                     + 'and Enabled = ''Y'' '
                     + 'Order By Duty_Code';
        Params.ParamByName('Duty_Code').AsString := Trim(editDuty.Text) + '%';
        Open;
      end;
      if Showmodal = mrOK then
      begin
         K := #13;
         editDuty.Text := QryData.Fieldbyname('Duty Code').AsString;
         editDutyKeyPress(editDuty, K);
      end;
      QryData.Close;
      Free;
   end;

end;

procedure TfKP1.editDutyChange(Sender: TObject);
begin
    LabDutyDesc.Caption := '';
end;

procedure TfKP1.editReasonChange(Sender: TObject);
begin
   LabReasonDesc.Caption := '';
end;

end.

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    