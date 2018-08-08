unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db,
  DBClient, MConnect, SConnect, IniFiles, ImgList, ObjBrkr, Menus, Variants;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabelPacking: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    cmbSN: TComboBox;
    Label7: TLabel;
    Label16: TLabel;
    Label25: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    LVDefect: TListView;
    LabWO: TLabel;
    LabPN: TLabel;
    Label13: TLabel;
    LabVersion: TLabel;
    LabLine: TLabel;
    LabTerminal: TLabel;
    LabProcess: TLabel;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    sbtnFailSN: TSpeedButton;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    AddDefect1: TMenuItem;
    DeleteDfect1: TMenuItem;
    RepairRecord1: TMenuItem;
    N1: TMenuItem;
    Scrap1: TMenuItem;
    Finish1: TMenuItem;
    Label5: TLabel;
    combSerialNumber: TComboBox;
    Image1: TImage;
    sbtnRepair: TSpeedButton;
    procedure sbtnFailSNClick(Sender: TObject);
    procedure cmbSNChange(Sender: TObject);
    procedure cmbSNKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnRepairClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure combSerialNumberChange(Sender: TObject);
    procedure cmbSNCloseUp(Sender: TObject);
  private
    { Private declarations }
    procedure ClearData;
    function GetTerminalID: Boolean;
    function ShowDefect(dtOutTime: TDateTime): Boolean;
  public
    { Public declarations }
    UpdateUserID, FcID: string;
    TerminalID, StageID, ProcessId, PDLineId: string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}

uses uRepair;

procedure TfDetail.ClearData;
begin
  combSerialNumber.Items.Clear;
  LabVersion.Caption := '';
  LabWO.Caption := '';
  LabPN.Caption := '';
  LabLine.Caption := '';
  LabTerminal.Caption := '';
  LabProcess.Caption := '';
  LVDefect.Items.Clear;
  cmbSN.Text := '';
  if cmbSN.Items.Count > 0 then
    sbtnFailSN.OnClick(Self);
end;

function TfDetail.GetTerminalID: Boolean;
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
    CommandText := 'Select A.TERMINAL_NAME,B.PROCESS_NAME, a.PROCESS_ID '
      + '       ,A.PDLINE_ID,a.Stage_ID '
      + 'From SAJET.SYS_TERMINAL A,'
      + '     SAJET.SYS_PROCESS B '
      + 'Where A.TERMINAL_ID = :TERMINALID '
      + 'AND A.PROCESS_ID = B.PROCESS_ID ';
    Params.ParamByName('TERMINALID').AsString := TerminalID;
    Open;
    if RecordCount <= 0 then
    begin
      Close;
      MessageDlg('Terminal data error !!', mtError, [mbCancel], 0);
      Exit;
    end;
    PDLineId := Fieldbyname('PDLINE_ID').AsString;
    ProcessId := Fieldbyname('PROCESS_ID').AsString;
    StageID := Fieldbyname('Stage_ID').AsString;
    LabTerminal.Caption := Fieldbyname('PROCESS_NAME').AsString + ' ' +
      Fieldbyname('TERMINAL_NAME').AsString;
    Close;
  end;
  Result := True;
end;

procedure TfDetail.sbtnFailSNClick(Sender: TObject);
begin
  // 禁用by key 2008/07/09
 { if ProcessID <> '' then
  begin
    cmbSN.Text := '';
    cmbSN.Items.Clear;
    with QryTemp do
    begin
      Close;
      Params.Clear;
    }
      {CommandText := 'Select Box_No '
        + 'From SAJET.G_SN_STATUS a, sajet.sys_route_detail b '
        + 'Where NVL(CURRENT_STATUS,''1'') = ''1'' '
        + 'and WORK_FLAG = ''0'' '
        + 'and a.process_id = b.process_id and next_process_id = ' + ProcessID
        + 'and a.route_id = b.route_id '
        + 'and box_no <> ''N/A'' '
        + 'Group by Box_No '
        + 'Order By Box_No';
      }
     {  CommandText := 'Select Box_No '
        + 'From SAJET.G_SN_STATUS a, sajet.sys_route_detail b '
        + 'Where CURRENT_STATUS = ''1'' '
        + 'and WORK_FLAG = ''0'' '
        + 'and a.process_id = b.process_id and next_process_id = ' + ProcessID
        + 'and a.route_id = b.route_id '
        + 'and box_no <> ''N/A'' '
        + 'Group by Box_No '
        + 'Order By Box_No';
      Open;
      while not Eof do
      begin
        cmbSN.Items.Add(Fieldbyname('Box_No').AsString);
        Next;
      end;
      Close;
    end;
    cmbSN.SetFocus;
  end;
  }
end;

procedure TfDetail.cmbSNKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    combSerialNumber.Items.Clear;
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'Box_No', ptInput);
      CommandText := 'Select serial_number, out_process_time '
        + 'From SAJET.G_SN_STATUS a, sajet.sys_route_detail b '
        + 'Where NVL(CURRENT_STATUS,''1'') = ''1'' '
        + 'and WORK_FLAG = ''0'' and box_no = :box_no '
        + 'and a.process_id = b.process_id and next_process_id = ' + ProcessID
        + 'and a.route_id = b.route_id '
        + 'Order By serial_number';
      Params.ParamByName('Box_No').AsString := cmbSN.Text;
      Open;
      while not Eof do
      begin
        combSerialNumber.Items.Add(Fieldbyname('serial_number').AsString);
        Next;
      end;
      if combSerialNumber.Items.Count = 1 then
      begin
        combSerialNumber.ItemIndex := 0;
        combSerialNumberChange(Self);
      end else begin
        LabVersion.Caption := '';
        LabWO.Caption := '';
        LabPN.Caption := '';
        LabLine.Caption := '';
        LabTerminal.Caption := '';
        LabProcess.Caption := '';
        LVDefect.Items.Clear;
      end;
      Close;
    end;
    cmbSN.SetFocus;
    cmbSN.SelectAll;
    if LVDefect.Items.Count > 0 then
    begin
      LVDefect.SetFocus;
      LVDefect.items[0].Selected := True;
//      LVDefect.OnClick(self);
    end;
  end
  else
  begin
    cmbSNChange(Self);
  end;
end;

procedure TfDetail.cmbSNChange(Sender: TObject);
begin
  combSerialNumber.Items.Clear;
  LabVersion.Caption := '';
  LabWO.Caption := '';
  LabPN.Caption := '';
  LabLine.Caption := '';
  LabTerminal.Caption := '';
  LabProcess.Caption := '';
  LVDefect.Items.Clear;
end;

procedure TfDetail.sbtnRepairClick(Sender: TObject);
begin
  with TfRepair.Create(nil) do
  begin
    gsSN := 'SN-' + combSerialNumber.Text;
    Show;
  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
  GetTerminalID; // 讀取本站 ID
  ClearData;
   //SN是否可用選的
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
  cmbSN.SetFocus;
end;

procedure TfDetail.combSerialNumberChange(Sender: TObject);
begin
  sbtnRepair.Enabled := False;
  if combSerialNumber.Text <> '' then
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
      CommandText := 'Select A.PROCESS_ID,a.serial_number,A.WORK_ORDER,A.WORK_FLAG,A.MODEL_ID,B.PART_NO,A.VERSION, A.OUT_PROCESS_TIME, a.route_id ' //, c.step '
        + 'From SAJET.G_SN_STATUS A, '
        + '     SAJET.SYS_PART B '
        + 'Where A.SERIAL_NUMBER = :SERIAL_NUMBER '
        + 'and A.MODEL_ID = B.PART_ID '
        + 'and rownum = 1';
      Params.ParamByName('SERIAL_NUMBER').AsString := combSerialNumber.Text;
      Open;
      LabWO.Caption := Fieldbyname('WORK_ORDER').AsString;
      LabPN.Caption := Fieldbyname('PART_NO').AsString;
      LabVersion.Caption := Fieldbyname('VERSION').AsString;
      if not ShowDefect(FieldByName('out_process_time').AsDateTime) then
        Exit;
    end;
    sbtnRepair.Enabled := True;
  end;
end;

function TfDetail.ShowDefect(dtOutTime: TDateTime): Boolean;
var S: string;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SN', ptInput);
    Params.CreateParam(ftDateTime, 'sTime', ptInput);
    CommandText := 'Select A.RECID,B.DEFECT_CODE,B.DEFECT_DESC,h.Location,C.PDLINE_NAME,' +
      'D.TERMINAL_NAME,E.PROCESS_NAME,A.RP_STATUS,NVL(G.REASON_CODE,''N/A'') REASON_CODE, a.Process_Id ' +
      ',sajet.Sj_Get_Defect_Location(A.RECID) "LOCATION" ' +
      'From SAJET.G_SN_DEFECT A, ' +
      'SAJET.SYS_DEFECT B,' +
      'SAJET.SYS_PDLINE C,' +
      'SAJET.SYS_TERMINAL D,' +
      'SAJET.SYS_PROCESS E, ' +
      'SAJET.G_SN_REPAIR F,' +
      'SAJET.SYS_REASON G ,' +
      'SAJET.G_SN_REPAIR_LOCATION H ' +
      'Where A.Serial_Number = :SN and ' +
      'a.rec_time >= :sTime and ' +
      'A.DEFECT_ID = B.DEFECT_ID(+) and ' +
      'A.PDLINE_ID = C.PDLINE_ID(+) and ' +
      'A.TERMINAL_ID = D.TERMINAL_ID(+) and ' +
      'A.PROCESS_ID = E.PROCESS_ID(+) and ' +
      'A.RECID = F.RECID(+) and ' +
      'F.REASON_ID = G.REASON_ID(+) ' +
      '   AND a.recid = h.recid(+) ';
    Params.ParamByName('SN').AsString := combSerialNumber.Text;
    Params.ParamByName('sTime').AsDateTime := dtOutTime;
    Open;
    S := '';
    if RecordCount > 0 then
    begin
      LabLine.Caption := Fieldbyname('PDLINE_NAME').AsString;
      LabTerminal.Caption := Fieldbyname('TERMINAL_NAME').AsString;
      LabProcess.Caption := Fieldbyname('PROCESS_NAME').AsString;
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
          SubItems.Add(Fieldbyname('LOCATION').AsString);
          SubItems.Add(Fieldbyname('RECID').AsString);
          SubItems.Add(Fieldbyname('Process_Id').AsString);

          if Fieldbyname('REASON_CODE').AsString = 'N/A' then
            ImageIndex := 1
          else
            ImageIndex := 0;
        end;
        S := Fieldbyname('DEFECT_CODE').AsString;
      end;
      Next;
    end;
    Close;
  end;
  Result := True;
end;

procedure TfDetail.cmbSNCloseUp(Sender: TObject);
var sKey: Char;
begin
   cmbSN.Text := cmbSN.Items.Strings[cmbSN.ItemIndex];
   if cmbSN.Text = '' then begin
    cmbSNChange(Self);
    Exit;
  end;
  sKey := #13;
  cmbSN.OnKeyPress(self, sKey);
end;

end.
