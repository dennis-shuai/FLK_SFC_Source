unit uData;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, Db,
   DBClient, MConnect, SConnect, IniFiles, Grids, DBGrids;

type
   TfData = class(TForm)
      sbtnClose: TSpeedButton;
      Label4: TLabel;
      Image1: TImage;
      Label5: TLabel;
      Label9: TLabel;
      Imagemain: TImage;
      Label8: TLabel;
      Image3: TImage;
      sbtnSave: TSpeedButton;
      Label7: TLabel;
      LabReasonDesc: TLabel;
      editReason: TEdit;
      Label2: TLabel;
      editDuty: TEdit;
      LabDutyDesc: TLabel;
      Label6: TLabel;
      LabDefectDesc: TLabel;
      LabDefectCode: TLabel;
      DBGrid1: TDBGrid;
      Label12: TLabel;
      Label1: TLabel;
      Remark: TMemo;
      DataSource1: TDataSource;
    sbtnReason: TSpeedButton;
    SpeedButton1: TSpeedButton;
      procedure sbtnCloseClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure editReasonKeyPress(Sender: TObject; var Key: Char);
      procedure editDutyKeyPress(Sender: TObject; var Key: Char);
      procedure sbtnSaveClick(Sender: TObject);
      procedure DBGrid1DblClick(Sender: TObject);

    procedure FormShow(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure sbtnReasonClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
   private
    { Private declarations }
      procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
      procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
   public
    { Public declarations }
      RecID: string;
      ReasonID: string;
      DutyID: string;
      RepairCodeID:String;
      procedure SetTheRegion;
      function CheckReason: Boolean;
      function CheckDuty: Boolean;

   end;

var
   fData: TfData;

implementation

{$R *.DFM}
uses uRepair,uReason, uFilter;

function TfData.CheckReason: Boolean;
begin
   Result := False;
   with fRepair.QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'REASON_CODE', ptInput);
      CommandText := 'Select Reason_Id, Reason_Code, Reason_Desc,ENABLED ' +
         'From SAJET.SYS_REASON ' +
         'Where REASON_CODE = :REASON_CODE';
      Params.ParamByName('REASON_CODE').AsString := editReason.Text;
      Open;
      if RecordCount <= 0 then
      begin
         Close;
         MessageDlg('Reason Code error !!' + #13#10 +
            'Reason Code : ' + editReason.Text, mtError, [mbCancel], 0);
         Exit;
      end;
      if FieldByName('ENABLED').AsString = 'N' then
      begin
         Close;
         MessageDlg('Reason Code Disable !!' + #13#10 +
            'Reason Code : ' + editReason.Text, mtError, [mbCancel], 0);
         Exit;
      end;
      ReasonId := Fieldbyname('Reason_Id').AsString;
      LabReasonDesc.Caption := Fieldbyname('Reason_Desc').AsString;
      Close;
   end;
   Result := True;
end;

function TfData.CheckDuty: Boolean;
begin
   Result := False;
   with fRepair.QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'DUTY_CODE', ptInput);
      CommandText := 'Select Duty_Id, Duty_Code, Duty_Desc,Enabled ' +
         'From SAJET.SYS_DUTY ' +
         'Where DUTY_CODE = :DUTY_CODE ';
      Params.ParamByName('DUTY_CODE').AsString := editDuty.Text;
      Open;
      if RecordCount <= 0 then
      begin
         Close;
         MessageDlg('Duty Code error !!' + #13#10 +
            'Duty Code : ' + editDuty.Text, mtError, [mbCancel], 0);
         Exit;
      end;
      if FieldByName('Enabled').AsString = 'N' then
      begin
         Close;
         MessageDlg('Duty Code Disable !!' + #13#10 +
            'Duty Code : ' + editDuty.Text, mtError, [mbCancel], 0);
         Exit;
      end;
      DutyId := Fieldbyname('Duty_Id').AsString;
      LabDutyDesc.Caption := Fieldbyname('Duty_Desc').AsString;
      Close;
   end;
   Result := True;
end;

procedure TfData.sbtnCloseClick(Sender: TObject);
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

procedure TfData.editReasonKeyPress(Sender: TObject; var Key: Char);
begin
  if key <>#13 then exit;
  editReason.Text := Trim(editReason.text);
  if not CheckReason then
  begin
    editReason.SetFocus;
    editReason.SelectAll;
    exit;
  end;
  editDuty.SetFocus;
end;

procedure TfData.editDutyKeyPress(Sender: TObject; var Key: Char);
begin
  if  Key <> #13 then exit;
  editDuty.Text := Trim(editDuty.Text);

  if not CheckDuty then
  begin
    editDuty.Setfocus;
    editDuty.SelectAll;
    exit;
  end;

end;

procedure TfData.sbtnSaveClick(Sender: TObject);
var I: Integer; B: Boolean;
    sRemark,sMessage :String;
begin

   if not CheckReason then Exit;
   if not CheckDuty then Exit;
   //if not CheckRepairCode then Exit;
   B := False;
   for I := 0 to fRepair.LVReason.Items.Count - 1 do
   begin
      if editReason.Text = fRepair.LVReason.Items[I].Caption then
      begin
         B := True;
         Break;
      end;
   end;
   try
     if B then
     begin
        sMessage:='Reason Code Duplicate !!' + #13#10 +'Reason Code : ' + editReason.Text;
        Exit;
     end;

     with fRepair.QryTemp do
     begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'RECID', ptInput);
         Params.CreateParam(ftString, 'REPAIR_EMP_ID', ptInput);
         Params.CreateParam(ftString, 'REASON_ID', ptInput);
         Params.CreateParam(ftString, 'RP_TERMINAL_ID', ptInput);
         Params.CreateParam(ftString, 'RP_PROCESS_ID', ptInput);
         Params.CreateParam(ftString, 'RP_STAGE_ID', ptInput);
         Params.CreateParam(ftString, 'DUTY_PROCESS_ID', ptInput);
         Params.CreateParam(ftString, 'DUTY_ID', ptInput);
         Params.CreateParam(ftString, 'ITEM_ID', ptInput);
         CommandText :='INSERT INTO SAJET.G_KP_REPAIR '
                      +' (RECID,REPAIR_EMP_ID,REPAIR_TIME,REASON_ID,RP_TERMINAL_ID,RP_PROCESS_ID,RP_STAGE_ID,DUTY_PROCESS_ID '
                      +'  ,DUTY_ID,ITEM_ID) '
                      +'VALUES '
                      +'	(:RECID,:REPAIR_EMP_ID,SysDate,:REASON_ID,:RP_TERMINAL_ID,:RP_PROCESS_ID,:RP_STAGE_ID,:DUTY_PROCESS_ID '
                      +'  ,:DUTY_ID,:ITEM_ID) ';
         Params.ParamByName('RECID').AsString := RecId;
         Params.ParamByName('REPAIR_EMP_ID').AsString := fRepair.UpdateUserID;
         Params.ParamByName('REASON_ID').AsString := ReasonID;
         Params.ParamByName('RP_TERMINAL_ID').AsString := fRepair.TerminalID;
         Params.ParamByName('RP_PROCESS_ID').AsString := fRepair.ProcessId;
         Params.ParamByName('RP_STAGE_ID').AsString := fRepair.StageID;
         Params.ParamByName('DUTY_PROCESS_ID').AsString := '0';
         Params.ParamByName('DUTY_ID').AsString := DutyId;
         Params.ParamByName('ITEM_ID').AsString := '0';    // 因為沒有Item
         Execute;
         Close;

         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'RECID', ptInput);
         Params.CreateParam(ftString, 'REPAIR_REMARK', ptInput);
         Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
         CommandText := 'Insert Into SAJET.G_KP_REPAIR_REMARK ' +
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
         Close;
     End;

     {try
       with fRepair.sproc do
       begin
         try
           Close;
           DataRequest('SAJET.ICP_KP_REASON_INPUT');
           FetchParams;
           Params.ParamByName('TRECID').AsString := RecId;
           Params.ParamByName('TTERMINALID').AsString := fRepair.TerminalID;
           Params.ParamByName('TEMPID').AsString := fRepair.UpdateUserID;
           Params.ParamByName('TREASON_ID').AsString := ReasonID;
           Params.ParamByName('TDUTY_PROCESS_ID').AsInteger := 0;
           Params.ParamByName('TDUTY_ID').AsString := DutyId;
           Params.ParamByName('TITEM_ID').AsInteger := 0;
           Params.ParamByName('TRECORD_TYPE').AsString := '';
           Params.ParamByName('TLOCATION').AsString := editLocation.Text;
           Params.ParamByName('TREPAIR_CODE_ID').AsString :=RepairCodeID;
           Params.ParamByName('TREMARK').AsString := sRemark;
           execute;

           if Params.ParamByName('TRES').AsString <>'OK' then
           begin
             sMessage:= Params.ParamByName('TRES').AsString;
             exit;
           end;
           ModalResult := mrOK;
         except
           on E: Exception do
             sMessage:='ICP_KP_REASON_INPUT Exception:'+E.Message;
         end;
       end;
     finally
        fRepair.sproc.Close;
     end;}
   finally
     if sMessage<>'' then
     begin
       MessageDlg(sMessage,mtWarning,[mbOK],0);
     end
     else
       ModalResult := mrOK;
   end;
end;

procedure TfData.DBGrid1DblClick(Sender: TObject);
begin
   editReason.Text := DBGrid1.Fields[0].AsString;
   if CheckReason then
      editDuty.SetFocus;
end;


procedure TfData.FormShow(Sender: TObject);
begin
//  Language.Translation(fData);
end;

procedure TfData.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if DBGrid1.Columns.Items[3].Field.text = 'N' then
    DBGrid1.Canvas.Font.Color:=clRed;
 // else
 //   DBGrid1.Canvas.Brush.Color:=clYellow;

 // DBGrid1.Canvas.Font.Color:=clGreen;
  DBGrid1.DefaultDrawDataCell(rect,Column.Field,State);
end;

procedure TfData.sbtnReasonClick(Sender: TObject);
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

procedure TfData.SpeedButton1Click(Sender: TObject);

var K:Char;
begin
   with TfFilter.Create(Self) do
   begin
      with QryData do
      begin
        RemoteServer:=fRepair.QryData.RemoteServer;
        Close;
        Params.Clear;
        //Params.CreateParam(ftString, 'Duty_Code', ptInput);
        CommandText := 'Select Duty_Code "Duty Code", Duty_Desc "Duty Desc" '
                     + 'From SAJET.SYS_DUTY '
                     //+ 'Where Duty_Code Like :Duty_Code '
                     + 'where Enabled = ''Y'' '
                     + 'Order By Duty_Code';
        //Params.ParamByName('Duty_Code').AsString := Trim(editDuty.Text) + '%';
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

end.

