unit uRepair;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db, uData,
   DBClient, MConnect, SConnect, IniFiles, ImgList, ObjBrkr, Menus;

type
   TfRepair = class(TForm)
      Panel1: TPanel;
      ImageAll: TImage;
      LabelPacking: TLabel;
      sbtnClose: TSpeedButton;
      Image2: TImage;
      Label1: TLabel;
      sbtnFinish: TSpeedButton;
      Label22: TLabel;
      Image3: TImage;
      Label2: TLabel;
      cmbSN: TComboBox;
      Label7: TLabel;
      Label16: TLabel;
      Label25: TLabel;
      Label3: TLabel;
      Label4: TLabel;
      Label6: TLabel;
      LVDefect: TListView;
      Label5: TLabel;
      LVReason: TListView;
      Label8: TLabel;
      Label9: TLabel;
      Image1: TImage;
      Image4: TImage;
      sbtnAdd: TSpeedButton;
      sbtnDelete: TSpeedButton;
      Label10: TLabel;
      Image5: TImage;
      sbtnRepair: TSpeedButton;
      LabWO: TLabel;
      LabPN: TLabel;
      Label13: TLabel;
      LabVersion: TLabel;
      LabLine: TLabel;
      LabTerminal: TLabel;
      LabProcess: TLabel;
      QryData: TClientDataSet;
      QryTemp: TClientDataSet;
      SProc: TClientDataSet;
      sbtnFailSN: TSpeedButton;
      sbtnScrap: TSpeedButton;
      Label19: TLabel;
      Image6: TImage;
      ImageList1: TImageList;
      PopupMenu1: TPopupMenu;
      AddDefect1: TMenuItem;
      DeleteDfect1: TMenuItem;
      RepairRecord1: TMenuItem;
      N1: TMenuItem;
      Scrap1: TMenuItem;
      Finish1: TMenuItem;
      Label11: TLabel;
      Image7: TImage;
      sbtnReplace: TSpeedButton;
      procedure sbtnCloseClick(Sender: TObject);
      procedure sbtnFailSNClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure sbtnScrapClick(Sender: TObject);
      procedure sbtnRepairClick(Sender: TObject);
      procedure cmbSNKeyPress(Sender: TObject; var Key: Char);
      procedure sbtnAddClick(Sender: TObject);
      procedure FormClose(Sender: TObject; var Action: TCloseAction);
      procedure sbtnDeleteClick(Sender: TObject);
      procedure LVDefectClick(Sender: TObject);
      procedure sbtnFinishClick(Sender: TObject);
      procedure cmbSNChange(Sender: TObject);
      procedure sbtnReplaceClick(Sender: TObject);
   private
    { Private declarations }
      procedure ShowReasonHistory(DefectCode: string);
      procedure ShowKP;
   public
    { Public declarations }
      mPartID, sRouteID, sStep, gbSN: string;
      UpdateUserID: string;
      TerminalID, ProcessId: string;
      FcID: string;
      Authoritys, AuthorityRole: string;
      dtOutTime: TDateTime;
      function GetTerminalID: Boolean;
      function GetDefectRECID: string;
      function CheckSN: Boolean;
      function InputSN: Boolean;
      function ShowDefect: Boolean;
      function ShowReason(RECID: string): Boolean;
      procedure ClearData;
      procedure SetStatusbyAuthority;
   end;

var
   fRepair: TfRepair;

implementation

uses uKP, uProcess;

{$R *.DFM}

procedure TfRepair.SetStatusbyAuthority;
begin
  // Read Only,Allow To Change,Full Control
   Authoritys := '';
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      Params.CreateParam(ftString, 'FUN', ptInput);
      CommandText := 'Select AUTHORITYS ' +
         'From SAJET.SYS_EMP_PRIVILEGE ' +
         'Where EMP_ID = :EMP_ID and ' +
         'PROGRAM = :PRG and ' +
         'FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Repair';
      Params.ParamByName('FUN').AsString := 'Execution';
      Open;
      if RecordCount > 0 then
         Authoritys := Fieldbyname('AUTHORITYS').AsString;
      Close;
   end;

   //sbtnFailSN.Enabled := (Authoritys = 'Allow To Execute');
   cmbSN.Enabled := (Authoritys = 'Allow To Execute');

   sbtnAdd.Enabled := cmbSN.Enabled;
   AddDefect1.Enabled := cmbSN.Enabled;
   Label8.Enabled := cmbSN.Enabled;

   sbtnDelete.Enabled := cmbSN.Enabled;
   DeleteDfect1.Enabled := cmbSN.Enabled;
   Label9.Enabled := cmbSN.Enabled;

   sbtnRepair.Enabled := cmbSN.Enabled;
   RepairRecord1.Enabled := cmbSN.Enabled;
   Label10.Enabled := cmbSN.Enabled;

   sbtnScrap.Enabled := cmbSN.Enabled;
   Scrap1.Enabled := cmbSN.Enabled;
   Label19.Enabled := cmbSN.Enabled;

   sbtnFinish.Enabled := cmbSN.Enabled;
   Finish1.Enabled := cmbSN.Enabled;
   Label22.Enabled := cmbSN.Enabled;

   AuthorityRole := '';
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      Params.CreateParam(ftString, 'FUN', ptInput);
      CommandText := 'Select AUTHORITYS ' +
         'From SAJET.SYS_ROLE_PRIVILEGE A, ' +
         'SAJET.SYS_ROLE_EMP B ' +
         'Where A.ROLE_ID = B.ROLE_ID and ' +
         'EMP_ID = :EMP_ID and ' +
         'PROGRAM = :PRG and ' +
         'FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Repair';
      Params.ParamByName('FUN').AsString := 'Execution';
      Open;
      if RecordCount > 0 then
         AuthorityRole := Fieldbyname('AUTHORITYS').AsString;
      Close;
   end;

   if not cmbSN.Enabled then
   begin
      cmbSN.Enabled := (AuthorityRole = 'Allow To Execute');

      sbtnAdd.Enabled := cmbSN.Enabled;
      AddDefect1.Enabled := cmbSN.Enabled;
      Label8.Enabled := cmbSN.Enabled;

      sbtnDelete.Enabled := cmbSN.Enabled;
      DeleteDfect1.Enabled := cmbSN.Enabled;
      Label9.Enabled := cmbSN.Enabled;

      sbtnRepair.Enabled := cmbSN.Enabled;
      RepairRecord1.Enabled := cmbSN.Enabled;
      Label10.Enabled := cmbSN.Enabled;

      sbtnScrap.Enabled := cmbSN.Enabled;
      Scrap1.Enabled := cmbSN.Enabled;
      Label19.Enabled := cmbSN.Enabled;

      sbtnFinish.Enabled := cmbSN.Enabled;
      Finish1.Enabled := cmbSN.Enabled;
      Label22.Enabled := cmbSN.Enabled;
   end;

end;

function TfRepair.GetDefectRECID: string;
begin
  // 取新的 Rec ID
   try
      with QryTemp do
      begin
         Close;
         Params.Clear;
         CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || TO_CHAR(SYSDATE,''YYMMDD'') || LPAD(SAJET.S_DEF_CODE.NEXTVAL,5,''0'') SNID ' +
            'From SAJET.SYS_BASE ' +
            'Where PARAM_NAME = ''DBID'' ';
         Open;
         Result := Fieldbyname('SNID').AsString;
         Close;
      end;
   except
      MessageDlg('Database Error !!' + #13#10 +
         'Can not get new Defect Record ID !!', mtError, [mbCancel], 0);
      Result := '';
   end;
end;

function TfRepair.GetTerminalID: Boolean;
begin
   Result := False;

   with TIniFile.Create('SAJET.ini') do
   begin
      FcID := ReadString('System', 'Factory', '');
      TerminalID := ReadString('Repair', 'Terminal', '');
      Free;
   end;

   if TerminalID = '' then
   begin
      MessageDlg('Terminal not be assign !!', mtError, [mbCancel], 0);
      Exit;
   end;

   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'TERMINALID', ptInput);
      CommandText := 'Select A.TERMINAL_NAME,B.PROCESS_NAME, a.PROCESS_ID ' +
         'From SAJET.SYS_TERMINAL A,' +
         'SAJET.SYS_PROCESS B ' +
         'Where A.TERMINAL_ID = :TERMINALID and ' +
         'A.PROCESS_ID = B.PROCESS_ID ';
      Params.ParamByName('TERMINALID').AsString := TerminalID;
      Open;
      if RecordCount <= 0 then
      begin
         Close;
         MessageDlg('Terminal data error !!', mtError, [mbCancel], 0);
         Exit;
      end;
      ProcessId := Fieldbyname('PROCESS_ID').AsString;
      LabTerminal.Caption := Fieldbyname('PROCESS_NAME').AsString + ' ' +
         Fieldbyname('TERMINAL_NAME').AsString;
      Close;
   end;
   Result := True;
end;

function TfRepair.ShowDefect: Boolean;
var S: string;
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SN', ptInput);
      Params.CreateParam(ftDateTime, 'sTime', ptInput);
      CommandText := 'Select A.RECID,B.DEFECT_CODE,B.DEFECT_DESC,C.PDLINE_NAME,' +
         'D.TERMINAL_NAME,E.PROCESS_NAME,A.RP_STATUS,NVL(G.REASON_CODE,''N/A'') REASON_CODE, a.Process_Id ' +
         'From SAJET.G_SN_DEFECT A, ' +
         'SAJET.SYS_DEFECT B,' +
         'SAJET.SYS_PDLINE C,' +
         'SAJET.SYS_TERMINAL D,' +
         'SAJET.SYS_PROCESS E, ' +
         'SAJET.G_SN_REPAIR F,' +
         'SAJET.SYS_REASON G ' +
         'Where A.Serial_Number = :SN and ' +
         'a.rec_time >= :sTime and ' +
         'A.DEFECT_ID = B.DEFECT_ID(+) and ' +
         'A.PDLINE_ID = C.PDLINE_ID(+) and ' +
         'A.TERMINAL_ID = D.TERMINAL_ID(+) and ' +
         'A.PROCESS_ID = E.PROCESS_ID(+) and ' +
         'A.RECID = F.RECID(+) and ' +
         'F.REASON_ID = G.REASON_ID(+) ';
//                         'A.RP_STATUS = ''1'' ';
      Params.ParamByName('SN').AsString := gbSN;
      Params.ParamByName('sTime').AsDateTime := dtOutTime;
      Open;
      S := '';
      if RecordCount > 0 then
      begin
         LabLine.Caption := Fieldbyname('PDLINE_NAME').AsString;
         LabTerminal.Caption := Fieldbyname('TERMINAL_NAME').AsString;
         LabProcess.Caption := Fieldbyname('PROCESS_NAME').AsString;
//      S := Fieldbyname('DEFECT_CODE').AsString;
      end;
      LVDefect.Items.Clear;
      while not Eof do
      begin
         if Fieldbyname('DEFECT_CODE').AsString <> S then
         begin
            with LVDefect.Items.Add do
            begin
               Caption := Fieldbyname('DEFECT_CODE').AsString;
               SubItems.Add(Fieldbyname('DEFECT_DESC').AsString);
               SubItems.Add(Fieldbyname('RECID').AsString);
               SubItems.Add(Fieldbyname('Process_Id').AsString);
               if Fieldbyname('REASON_CODE').AsString = 'N/A' then
                  ImageIndex := 1
               else
                  ImageIndex := 0;
            end;
            //DefectList.Add(Fieldbyname('RECID').AsString);
            S := Fieldbyname('DEFECT_CODE').AsString;
         end;
         Next;
      end;
      Close;
   end;
   Result := True;
end;

function TfRepair.ShowReason(RECID: string): Boolean;
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SN', ptInput);
      Params.CreateParam(ftString, 'RECID', ptInput);
      CommandText := 'Select D.REASON_CODE,D.REASON_DESC ' +
         'From SAJET.G_SN_DEFECT A, ' +
         'SAJET.SYS_DEFECT B, ' +
         'SAJET.G_SN_REPAIR C, ' +
         'SAJET.SYS_REASON D ' +
         'Where A.Serial_Number = :SN and ' +
      //                   'A.RP_STATUS = ''1'' and '+
      'A.DEFECT_ID = B.DEFECT_ID and ' +
         'A.RECID = :RECID and ' +
//         'B.DEFECT_CODE = :DEFECT and ' +
      'A.RECID = C.RECID and ' +
         'C.REASON_ID = D.REASON_ID ';

      Params.ParamByName('SN').AsString := gbSN;
      Params.ParamByName('RECID').AsString := RECID;
      Open;
      LVReason.Items.Clear;
      while not Eof do
      begin
         with LVReason.Items.Add do
         begin
            Caption := Fieldbyname('REASON_CODE').AsString;
            SubItems.Add(Fieldbyname('REASON_DESC').AsString);
         end;
         Next;
      end;
      Close;
   end;
   Result := True;
end;

function TfRepair.InputSN: Boolean;
begin
   if not CheckSN then Exit;

  // 顯示 Defect Data
   if not ShowDefect then Exit;

  // 顯示 Reason Data
   if LVDefect.Items.Count > 0 then
      ShowReason(LVDefect.Items[1].Caption);
      //ShowReason(DefectList.Strings[0]);

end;

function TfRepair.CheckSN: Boolean;
var sRes: string;
begin
   Result := False;
   with QryTemp do
   begin
      gbSN := cmbSN.Text;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
      CommandText := 'Select A.WORK_ORDER,A.WORK_FLAG,A.MODEL_ID,B.PART_NO,A.VERSION, A.OUT_PROCESS_TIME, a.route_id, c.step '
         + 'From SAJET.G_SN_STATUS A, '
         + 'SAJET.SYS_PART B, sajet.sys_route_detail c '
         + 'Where A.SERIAL_NUMBER = :SERIAL_NUMBER '
         + 'and a.route_id = c.route_id '
         + 'and a.process_id = c.process_id '
         + 'and c.next_process_id = ' + ProcessId + ' '
         + 'and A.MODEL_ID = B.PART_ID '
         + 'and rownum = 1';
      Params.ParamByName('SERIAL_NUMBER').AsString := cmbSN.Text;
      Open;
      if RecordCount <= 0 then
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
         CommandText := 'Select a.serial_number, A.WORK_ORDER,A.WORK_FLAG,A.MODEL_ID,B.PART_NO,A.VERSION, A.OUT_PROCESS_TIME, a.route_id, c.step '
            + 'From SAJET.G_SN_STATUS A, '
            + 'SAJET.SYS_PART B, sajet.sys_route_detail c '
            + 'Where A.Customer_SN = :SERIAL_NUMBER '
            + 'and a.route_id = c.route_id '
            + 'and a.process_id = c.process_id '
            + 'and c.next_process_id = ' + ProcessId + ' '
            + 'and A.MODEL_ID = B.PART_ID '
            + 'and rownum = 1';
         Params.ParamByName('SERIAL_NUMBER').AsString := cmbSN.Text;
         Open;
         if RecordCount <= 0 then
         begin
            Close;
            MessageDlg('Serial Number error !!', mtError, [mbCancel], 0);
            Exit;
         end;
         gbSN := FieldByName('serial_number').AsString;
      end;
      if Fieldbyname('WORK_FLAG').AsString = '1' then
      begin
         Close;
         MessageDlg('Serial Number Srcap', mtError, [mbCancel], 0);
         gbSN := '';
         Exit;
      end;
      LabWO.Caption := Fieldbyname('WORK_ORDER').AsString;
      LabPN.Caption := Fieldbyname('PART_NO').AsString;
      LabVersion.Caption := Fieldbyname('VERSION').AsString;
      mPartID := Fieldbyname('MODEL_ID').AsString;
      sRouteID := Fieldbyname('Route_ID').AsString;
      sStep := FieldByName('Step').AsString;
      dtOutTime := Fieldbyname('OUT_PROCESS_TIME').AsDateTime;
      Close;
   end;

  // Check Route
   with SProc do
   begin
      try
         Close;
         DataRequest('SAJET.SJ_CKRT_ROUTE');
         FetchParams;
         Params.ParamByName('TERMINALID').AsString := TerminalID;
         Params.ParamByName('TSN').AsString := gbSN;
         Execute;
         sRes := Params.ParamByName('TRES').AsString;
      except end;
      Close;
   end;
   if sRes <> 'OK' then
   begin
      MessageDlg(sRes, mtError, [mbCancel], 0);
  //  Exit;
   end;
   Result := True;
end;

procedure TfRepair.ClearData;
begin
   LabVersion.Caption := '';
   LabWO.Caption := '';
   LabPN.Caption := '';
   LabLine.Caption := '';
   LabTerminal.Caption := '';
   LabProcess.Caption := '';
   LVDefect.Items.Clear;
   LVReason.Items.Clear;
   //DefectList.Clear;
   cmbSN.Text := '';
   gbSN := '';
   if cmbSN.Items.Count > 0 then
      sbtnFailSN.OnClick(Self);
end;

procedure TfRepair.sbtnCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TfRepair.sbtnFailSNClick(Sender: TObject);
begin
   cmbSN.Items.Clear;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select Serial_Number '
         + 'From SAJET.G_SN_STATUS a, sajet.sys_route_detail b '
         + 'Where NVL(CURRENT_STATUS,''1'') = ''1'' '
         + 'and WORK_FLAG = ''0'' '
         + 'and a.process_id = b.process_id and next_process_id = ' + ProcessID
         + 'and a.route_id = b.route_id '
         + 'Order By Serial_Number';
      Open;
      while not Eof do
      begin
         cmbSN.Items.Add(Fieldbyname('Serial_Number').AsString);
         Next;
      end;
      Close;
   end;
end;

procedure TfRepair.FormShow(Sender: TObject);
begin
   //DefectList := TStringList.Create;
   GetTerminalID; // 讀取本站 ID
   ClearData;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'select param_value from sajet.sys_base ' +
         'Where param_name = ''Repair Search'' and param_value = ''1'' ';
      Open;
      if RecordCount <> 0 then
      begin
         sbtnFailSN.Visible := True;
         cmbSN.Style := csDropDown;
      end
      else
         cmbSN.Style := csSimple;
   end;
   gbSN := '';
   if UpdateUserID <> '0' then
      SetStatusbyAuthority;
end;

procedure TfRepair.sbtnScrapClick(Sender: TObject);
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
      CommandText := 'Update SAJET.G_SN_STATUS ' +
         'Set WORK_FLAG = ''1'' ' +
         'Where SERIAL_NUMBER = :SERIAL_NUMBER ';
      Params.ParamByName('SERIAL_NUMBER').AsString := gbSN;
      Execute;
   end;
   ClearData;
end;

procedure TfRepair.ShowReasonHistory(DefectCode: string);
begin
   with QryData do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'DEFECTCODE', ptInput);
      CommandText := 'Select D.REASON_CODE,D.REASON_DESC,Count(REASON_CODE) CNT ' +
         'From SAJET.G_SN_DEFECT A,' +
         'SAJET.G_SN_REPAIR B,' +
         'SAJET.SYS_DEFECT C,' +
         'SAJET.SYS_REASON D ' +
         'Where A.RECID = B.RECID and ' +
         'A.DEFECT_ID = C.DEFECT_ID and ' +
         'C.DEFECT_CODE = :DEFECTCODE and ' +
         'B.REASON_ID = D.REASON_ID ' +
         'Group By D.REASON_CODE,D.REASON_DESC ' +
         'Order By CNT DESC ';
      Params.ParamByName('DEFECTCODE').AsString := DefectCode;
      Open;
   end;
end;

procedure TfRepair.sbtnRepairClick(Sender: TObject);
begin
   if LVDefect.Selected = nil then Exit;

   with TfData.Create(self) do
   begin
      LabDefectCode.Caption := LVDefect.Selected.Caption;
      LabDefectDesc.Caption := LVDefect.Selected.SubItems[0];
      RecID := LVDefect.Selected.SubItems[1]; //DefectList.Strings[LVDefect.Selected.Index];
      ShowReasonHistory(LVDefect.Selected.Caption);
      DataSource1.DataSet := QryData;
      if ShowModal = mrOK then
      begin
         LVDefect.Selected.ImageIndex := 0;
         ShowReason(LVDefect.Selected.SubItems[1]);
         //ShowReason(DefectList.Strings[LVDefect.Selected.Index]);
      end;
      QryData.Close;
      Free;
   end;
end;

procedure TfRepair.cmbSNKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then
   begin
      InputSN;
      cmbSN.SetFocus;
      cmbSN.SelectAll;
   end
   else
   begin
      cmbSNChange(Self);
   end;
end;

procedure TfRepair.sbtnAddClick(Sender: TObject);
var S, DefectID: string; B: Boolean; I: Integer;
begin
   if gbSN = '' then Exit;

   S := InputBox('Append Defect', 'Defect Code', '');
   if S = '' then Exit;

   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'DEFECT', ptInput);
      CommandText := 'Select DEFECT_ID,DEFECT_CODE,DEFECT_DESC ' +
         'From SAJET.SYS_DEFECT ' +
         'Where DEFECT_CODE = :DEFECT ';
      Params.ParamByName('DEFECT').AsString := S;
      Open;
      if RecordCount = 0 then
      begin
         Close;
         MessageDlg('Defect Code error !!' + #13#10 +
            'Defect Code : ' + S, mtError, [mbCancel], 0);
         Exit;
      end;

      B := False;
      for I := 0 to LVDefect.Items.Count - 1 do
      begin
         if LVDefect.Items[I].Caption = S then
         begin
            B := True;
            Break;
         end;
      end;

      if B then
      begin
         MessageDlg('Defect Code Duplicate !!' + #13#10 +
            'Defect Code : ' + S, mtError, [mbCancel], 0);
         Exit;
      end;

      with LVDefect.Items.Add do
      begin
         Caption := S;
         SubItems.Add(Fieldbyname('DEFECT_DESC').AsString);
         ImageIndex := 1;
      end;
      DefectID := Fieldbyname('DEFECT_ID').AsString;
      Close;
   end;

  // 儲存到 DB
   S := GetDefectRECID;
   if S = '' then Exit;

   //DefectList.Add(S);
   with QryData do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'MODEL_ID', ptInput);
      Params.CreateParam(ftString, 'DEFECT_ID', ptInput);
      Params.CreateParam(ftString, 'TEST_EMP_ID', ptInput);
      Params.CreateParam(ftString, 'RP_STATUS', ptInput);
      Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
      CommandText := 'Insert Into SAJET.G_SN_DEFECT ' +
         '(RECID,SERIAL_NUMBER,WORK_ORDER,MODEL_ID,DEFECT_ID,' +
         ' TERMINAL_ID,PROCESS_ID,STAGE_ID,PDLINE_ID,TEST_EMP_ID,RP_STATUS) ' +
         ' Select :RECID RECID,:SERIAL_NUMBER SERIAL_NUMBER,:WORK_ORDER WORK_ORDER,:MODEL_ID MODEL_ID,:DEFECT_ID DEFECT_ID,' +
         'TERMINAL_ID,PROCESS_ID,STAGE_ID,PDLINE_ID,:TEST_EMP_ID,:RP_STATUS ' +
         ' From SAJET.SYS_TERMINAL ' +
         ' Where TERMINAL_ID = :TERMINAL_ID ';
      Params.ParamByName('RECID').AsString := S;
      Params.ParamByName('SERIAL_NUMBER').AsString := gbSN;
      Params.ParamByName('WORK_ORDER').AsString := LabWO.Caption;
      Params.ParamByName('MODEL_ID').AsString := mPartID;
      Params.ParamByName('DEFECT_ID').AsString := DefectID;
      Params.ParamByName('TEST_EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('RP_STATUS').AsString := '1';
      Params.ParamByName('TERMINAL_ID').AsString := TerminalID;
      Execute;
   end;
   LVReason.Items.Clear;
end;

procedure TfRepair.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   //DefectList.Free;
end;

procedure TfRepair.sbtnDeleteClick(Sender: TObject);
begin
   if LVDefect.Selected = nil then Exit;
   if LVDefect.Selected.SubItems[2] = ProcessId then
   begin
      // Delete DB
      with QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'RECID', ptInput);
         CommandText := 'Delete SAJET.G_SN_DEFECT ' +
            'Where RECID = :RECID ';
         Params.ParamByName('RECID').AsString := LVDefect.Selected.SubItems[1]; //DefectList.Strings[LVDefect.Selected.Index];
         Execute;
      end;
      // Delete LVDefect;
      //DefectList.Delete(LVDefect.Selected.Index);
      LVDefect.Selected.Delete;
      LVReason.Items.Clear;
   end;
end;

procedure TfRepair.LVDefectClick(Sender: TObject);
begin
   if LVDefect.Selected = nil then Exit;
   ShowReason(LVDefect.Selected.SubItems[1]);
//   ShowReason(DefectList.Strings[LVDefect.Selected.Index]);
end;

procedure TfRepair.sbtnFinishClick(Sender: TObject);
var I: Integer; B: Boolean; sRes, sProcessID: string; slProcessID: TStringList;
begin
   if gbSN = '' then Exit;

   B := False;
   for I := 0 to LVDefect.Items.Count - 1 do
   begin
      if LVDefect.Items[I].ImageIndex <> 0 then
      begin
         B := True;
         Break;
      end;
   end;

   if B then
   begin
      MessageDlg('Repair not Complete !!', mtError, [mbCancel], 0);
      Exit;
   end;
   sProcessID := '0';
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'iRoute', ptInput);
      Params.CreateParam(ftString, 'iStep', ptInput);
      CommandText := 'select a.next_process_id, process_name '
         + 'from sajet.sys_route_detail a, sajet.sys_process b '
         + 'Where route_id = :iRoute '
         + 'and a.process_id = ' + ProcessID + ' '
         + 'and a.step = :iStep '
         + 'and a.next_process_id = b.process_id '
         + 'order by process_name';
      Params.ParamByName('iRoute').AsString := sRouteID;
      Params.ParamByName('iStep').AsString := sStep;
      Open;
      if RecordCount > 1 then
      begin
         fProcess := TfProcess.Create(Self);
         fProcess.lstProcess.Items.Clear;
         slProcessID := TStringList.Create;
         while not eof do
         begin
            slProcessID.Add(FieldByName('next_process_id').AsString);
            fProcess.lstProcess.Items.Add(FieldByName('process_name').AsString);
            next;
         end;
         if fProcess.ShowModal = mrOK then
         begin
            sProcessID := slProcessID[fProcess.lstProcess.ItemIndex];
         end
         else
         begin
            slProcessID.Free;
            fProcess.Free;
            Exit;
         end;
         slProcessID.Free;
         fProcess.Free;
      end;
   end;

   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SN', ptInput);
      CommandText := 'Update SAJET.G_SN_DEFECT ' +
         'Set RP_STATUS = ''0'' ' +
         'Where SERIAL_NUMBER = :SN ';
      Params.ParamByName('SN').AsString := gbSN;
      Execute;
   end;

  // 過站紀錄
   with SProc do
   begin
      try
         Close;
         DataRequest('SAJET.SJ_REPAIR_GO');
         FetchParams;
         Params.ParamByName('TTERMINALID').AsString := TerminalID;
         Params.ParamByName('TSN').AsString := gbSN;
         Params.ParamByName('TNOW').AsDate := Now;
         Params.ParamByName('TEMP').AsString := UpdateUserID;
         Params.ParamByName('NPROCESSID').AsString := sProcessID;
         Execute;
         sRes := Params.ParamByName('TRES').AsString;
      except end;
      Close;
   end;
   if sRes <> 'OK' then
   begin
      MessageDlg(sRes, mtError, [mbCancel], 0);
   end;
   ClearData;
end;

procedure TfRepair.cmbSNChange(Sender: TObject);
begin
   LabVersion.Caption := '';
   LabWO.Caption := '';
   LabPN.Caption := '';
   LabLine.Caption := '';
   LabTerminal.Caption := '';
   LabProcess.Caption := '';
   LVDefect.Items.Clear;
   LVReason.Items.Clear;
//   DefectList.Clear;
   gbSN := '';
{   InputSN;
   cmbSN.SetFocus;
   cmbSN.SelectAll; }
end;

procedure TfRepair.sbtnReplaceClick(Sender: TObject);
begin
   if gbSN = '' then
      Exit;
   if LVDefect.Selected = nil then Exit;

   with TformKP.Create(self) do
   begin
      RecID := LVDefect.Selected.SubItems[1];//DefectList.Strings[LVDefect.Selected.Index];
      labSN.Caption := fRepair.gbSN;
      ShowKP;
      DataSource1.DataSet := QryData;
      ShowModal;
      QryData.Close;
      Free;
   end;
end;

procedure TfRepair.ShowKP;
var
   SN: string;
begin
   SN := fRepair.gbSN;
   with QryData do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SN', ptInput);
      CommandText := 'Select A.SERIAL_NUMBER "SerialNumber",B.PART_NO "KPNO",A.ITEM_PART_ID "ID",ITEM_PART_SN "KPSN",B.SPEC1 "SPEC" ' +
         'From SAJET.G_SN_KEYPARTS A,' +
         'SAJET.SYS_PART B ' +
         'Where A.SERIAL_NUMBER = :SN and ' +
         'A.ITEM_PART_ID = B.PART_ID(+) ' +
         'Order By B.PART_NO ';
      Params.ParamByName('SN').AsString := Trim(SN);
      Open;
   end;
end;

end.

