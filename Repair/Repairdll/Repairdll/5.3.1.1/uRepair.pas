unit uRepair;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db, uData,
  DBClient, MConnect, SConnect, IniFiles, ImgList, ObjBrkr, Menus, Variants;

type
  TfRepair = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabelPacking: TLabel;
    Label1: TLabel;
    sbtnFinish: TSpeedButton;
    Image3: TImage;
    cmbSN: TComboBox;
    Label3: TLabel;
    LVDefect: TListView;
    Label5: TLabel;
    LVReason: TListView;
    Image1: TImage;
    Image4: TImage;
    sbtnAdd: TSpeedButton;
    sbtnDelete: TSpeedButton;
    Image5: TImage;
    sbtnRepair: TSpeedButton;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    sbtnFailSN: TSpeedButton;
    sbtnScrap: TSpeedButton;
    Image6: TImage;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    AddDefect1: TMenuItem;
    DeleteDfect1: TMenuItem;
    RepairRecord1: TMenuItem;
    N1: TMenuItem;
    Scrap1: TMenuItem;
    Finish1: TMenuItem;
    DBGrid1: TDBGrid;
    QryReplace: TClientDataSet;
    DataSource1: TDataSource;
    Label8: TLabel;
    Bevel1: TBevel;
    Image7: TImage;
    Image8: TImage;
    sbtnReplace: TSpeedButton;
    sbtnRemove: TSpeedButton;
    Label9: TLabel;
    ImageItem: TImage;
    sbtnRPItem: TSpeedButton;
    chkBoxKp: TCheckBox;
    DbGrid2: TDBGrid;
    Label10: TLabel;
    DataSource2: TDataSource;
    QryRepair: TClientDataSet;
    editRepairer: TEdit;
    sbtnRepairer: TSpeedButton;
    labRPName: TLabel;
    Bevel2: TBevel;
    LabProcess: TLabel;
    LabTerminal: TLabel;
    LabLine: TLabel;
    Label25: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    LabWO: TLabel;
    LabPN: TLabel;
    LabVersion: TLabel;
    Label16: TLabel;
    Label13: TLabel;
    Label7: TLabel;
    Label12: TLabel;
    Label11: TLabel;
    Label14: TLabel;
    Label2: TLabel;
    Label15: TLabel;
    Image2: TImage;
    Image9: TImage;
    SbtnQueryRepaired: TSpeedButton;
    SbtQueryReplace: TSpeedButton;
    LabRECID: TLabel;
    procedure sbtnFailSNClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnScrapClick(Sender: TObject);
    procedure sbtnRepairClick(Sender: TObject);
    procedure cmbSNKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnAddClick(Sender: TObject);
    procedure sbtnDeleteClick(Sender: TObject);
    procedure LVDefectClick(Sender: TObject);
    procedure sbtnFinishClick(Sender: TObject);
    procedure cmbSNChange(Sender: TObject);
    procedure sbtnReplaceClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnRPItemClick(Sender: TObject);
    procedure chkBoxKpClick(Sender: TObject);
    procedure sbtnRepairerClick(Sender: TObject);
    procedure editRepairerChange(Sender: TObject);
    procedure editRepairerKeyPress(Sender: TObject; var Key: Char);
    procedure cmbSNCloseUp(Sender: TObject);
    procedure SbtQueryReplaceClick(Sender: TObject);
    procedure SbtnQueryRepairedClick(Sender: TObject);
  private
    { Private declarations }
    procedure ShowReasonHistory(DefectCode: string);
  public
    { Public declarations }
    mPartID, sRouteID, sStep, gbSN: string;
    UpdateUserID: string;
    LoginUserID, gsSN: string;
    TerminalID, StageID, ProcessId, PDLineId: string;
    FcID: string;
    Authoritys, AuthorityRole: string;
    dtOutTime: TDateTime;
    g_tsItem, g_tsItemPart: TStrings;
    giLocateItem: Integer;

    g_startkpcount,g_endkpcount :integer;  //計錄kp 的個數
    
    function GetTerminalID: Boolean;
    function GetDefectRECID: string;
    function CheckSN: Boolean;
    procedure InputSN;
    function ShowDefect: Boolean;
    procedure ShowReason(RECID: string);
    procedure ClearData;
    procedure SetStatusbyAuthority;
    function GetEmpNo(psUserID: string): string;
    function GetEmpName(psUserID: string): string;
    function GetEmpID(sEMPNO: string): string;

    procedure ShowReplace;
    procedure ShowKP;
    procedure showRepair;
    function ShowDefectTemp(RECID: string): Boolean;
    procedure CheckEMPPRI(EmpNO: string; var sMSG, sEMPID, sEMP_NO, sEMP_NAME: string);
  end;

var
  fRepair: TfRepair;
const g_iCol = 5; //g_tsItem行數

implementation

uses uKP, uProcess, uRPItem, uFilter;

{$R *.DFM}

function TfRepair.GetEmpNo(psUserID: string): string;
begin
  Result := '0';

  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select EMP_NO '
      + '  From SAJET.SYS_EMP '
      + ' Where EMP_ID = ' + psUserID;
    Open;
    Result := FieldByName('Emp_No').AsString;
    Close;
  end;
end;

procedure TfRepair.SetStatusbyAuthority;
var iPrivilege: integer;
begin
  iPrivilege := 0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Repair';
      Params.ParamByName('FUN').AsString := 'Execution';
      Execute;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;
  sbtnAdd.Enabled := (iPrivilege >= 1);
  sbtnAdd.Enabled := sbtnAdd.Enabled;
  AddDefect1.Enabled := sbtnAdd.Enabled;

  sbtnDelete.Enabled := sbtnAdd.Enabled;
  DeleteDfect1.Enabled := sbtnAdd.Enabled;

  sbtnRepair.Enabled := sbtnAdd.Enabled;
  RepairRecord1.Enabled := sbtnAdd.Enabled;

  sbtnFinish.Enabled := sbtnAdd.Enabled;
  Finish1.Enabled := sbtnAdd.Enabled;

 // sbtnReplace.Enabled := sbtnAdd.Enabled;
 // sbtnRemove.Enabled := sbtnAdd.Enabled;
  sbtnRPItem.Enabled := sbtnAdd.Enabled;


  //update by key 2007/09/19 把replace and remove 功能獨立開
  iPrivilege := 0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Repair';
      Params.ParamByName('FUN').AsString := 'Replace';
      Execute;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;
  sbtnReplace.Enabled := (iPrivilege >= 1);
  sbtnReplace.Enabled := sbtnReplace.Enabled;

  iPrivilege := 0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Repair';
      Params.ParamByName('FUN').AsString := 'Remove';
      Execute;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;
  sbtnRemove.Enabled := (iPrivilege >= 1);
  sbtnRemove.Enabled := sbtnRemove.Enabled;


  iPrivilege := 0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Repair';
      Params.ParamByName('FUN').AsString := 'Scrap';
      Execute;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;
  sbtnScrap.Enabled := (iPrivilege >= 1);
  Scrap1.Enabled := sbtnScrap.Enabled;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Repair';
      Params.ParamByName('FUN').AsString := 'Change Repairer';
      Execute;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;
  sbtnRepairer.Enabled := (iPrivilege >= 1);
  editRepairer.Enabled := sbtnRepairer.Enabled;
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

function TfRepair.ShowDefect: Boolean;
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
      '   AND a.recid = h.recid(+) '+
      'Order by a.rec_time asc ';
    Params.ParamByName('SN').AsString := gbSN;
    Params.ParamByName('sTime').AsDateTime := dtOutTime;
    Open;
    S := '';
    if RecordCount > 0 then
    begin
      Labrecid.Caption := Fieldbyname('RECID').AsString; // add 2008/11/05 by key 用於記錄生產線(非repir)加上的recid
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

procedure TfRepair.ShowReason(RECID: string);
begin
  if not ShowDefectTemp(RECID) then
    ShowMessage('ShowDefectTemp!!');
  Exit;
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
      'A.DEFECT_ID = B.DEFECT_ID and ' +
      'A.RECID = :RECID and ' +
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
end;

procedure TfRepair.ShowReplace;
var i: Integer;
begin
  with QryReplace do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
    if chkBoxKp.Checked then
      CommandText := 'Select c.PART_NO "Part No", b.old_part_sn "Old KPSN", b.new_part_sn "New KPSN",b.replace_time "Replace Time", Remark "Remark" '
        + 'From SAJET.G_sn_repair_replace_kp b, '
        + 'sajet.sys_part c '
        + 'Where b.SERIAL_NUMBER = :SERIAL_NUMBER '
        + 'and b.item_part_id = c.part_id '
        + 'order by b.replace_time '
    else
      CommandText := 'Select c.PART_NO "Part No", b.old_part_sn "Old KPSN", b.new_part_sn "New KPSN",b.replace_time "Replace Time",Remark "Remark" '
        + 'From SAJET.g_sn_keyparts a, '
        + 'SAJET.G_sn_repair_replace_kp b, '
        + 'sajet.sys_part c '
        + 'Where a.SERIAL_NUMBER = :SERIAL_NUMBER '
        + 'and a.item_part_sn = B.new_part_sn '
        + 'and b.item_part_id = c.part_id '
        + 'order by b.replace_time ';
{      CommandText := 'Select a.item_part_sn "Keypart SN", b.serial_number "Serial Number",b.replace_time "Replace Time",c.PART_NO "Part No", Remark "Remark" '
         + 'From SAJET.g_sn_keyparts a, '
         + 'SAJET.G_sn_repair_replace_kp b, '
         + 'sajet.sys_part c '
         + 'Where a.SERIAL_NUMBER = :SERIAL_NUMBER '
         + 'and a.item_part_sn = B.old_part_sn '
         + 'and b.item_part_id = c.part_id ';}
    Params.ParamByName('SERIAL_NUMBER').AsString := cmbSN.Text;
    Open;
  end;
  for i := 0 to 4 do
    DBGrid1.Columns.Items[i].Width := 100;
end;

procedure TfRepair.InputSN;
begin
  if not CheckSN then Exit;

  // 顯示 Defect Data
  if not ShowDefect then Exit;

  // 顯示 Reason Data
  if LVDefect.Items.Count > 0 then
    ShowReason(LVDefect.Items[0].SubItems[2]);

//  showReplace;   //2007/09/12 by key 資料太大，等待時間太長　
  //ShowBomItem;
 // showRepair;   //2007/09/12 by key 資料太大，等待時間太長　
end;

function TfRepair.CheckSN: Boolean;
var sRes, sProcessID: string;
begin
  Result := False;
  with QryTemp do
  begin
      //gbSN := cmbSN.Text;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
    CommandText := 'Select A.PROCESS_ID,a.serial_number,A.WORK_ORDER,A.WORK_FLAG,A.MODEL_ID,B.PART_NO,A.VERSION, A.OUT_PROCESS_TIME, a.route_id ' //, c.step '
      + 'From SAJET.G_SN_STATUS A, '
      + '     SAJET.SYS_PART B '
      + 'Where A.SERIAL_NUMBER = :SERIAL_NUMBER '
      + 'and A.MODEL_ID = B.PART_ID '
      + 'and rownum = 1';
    Params.ParamByName('SERIAL_NUMBER').AsString := cmbSN.Text;
    Open;

    if RecordCount <= 0 then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
      CommandText := 'Select A.PROCESS_ID,a.serial_number, A.WORK_ORDER,A.WORK_FLAG,A.MODEL_ID,B.PART_NO,A.VERSION, A.OUT_PROCESS_TIME, a.route_id ' //, c.step '
        + 'From SAJET.G_SN_STATUS A, '
        + '     SAJET.SYS_PART B '
        + 'Where A.Customer_SN = :SERIAL_NUMBER '
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
    end
    else
      gbSN := FieldByName('serial_number').AsString;

    if Fieldbyname('WORK_FLAG').AsString = '1' then
    begin
      Close;
      gbSN := '';
      MessageDlg('Serial Number Srcap', mtError, [mbCancel], 0);
      Exit;
    end;
    LabWO.Caption := Fieldbyname('WORK_ORDER').AsString;
    LabPN.Caption := Fieldbyname('PART_NO').AsString;
    LabVersion.Caption := Fieldbyname('VERSION').AsString;
    mPartID := Fieldbyname('MODEL_ID').AsString;
    dtOutTime := Fieldbyname('OUT_PROCESS_TIME').AsDateTime;
    sRouteID := Fieldbyname('Route_ID').AsString;
    sProcessID := Fieldbyname('PROCESS_ID').AsString;
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
    except
      on E: Exception do
        sRes := 'SJ_CKRT_ROUTE Exception:' + E.Message;
    end;
    Close;
  end;
  if sRes <> 'OK' then
  begin
    gbSN := '';
    MessageDlg(sRes, mtError, [mbCancel], 0);
    Exit;
  end;

   //找Route中的Step
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'route_id', ptInput);
    Params.CreateParam(ftString, 'process_id', ptInput);
    CommandText := 'Select step '
      + 'From sajet.sys_route_detail '
      + 'Where route_id = :route_id '
      + 'and process_id = :process_id '
      + 'and next_process_id = ' + ProcessId + ' '
      + 'and rownum = 1';
    Params.ParamByName('route_id').AsString := sRouteID;
    Params.ParamByName('process_id').AsString := sProcessID;
    Open;
    if RecordCount <= 0 then
    begin
      Close;
      gbSN := '';
      MessageDlg('Route Step Error !!', mtError, [mbCancel], 0);
      Exit;
    end;

    sStep := FieldByName('Step').AsString;
    Close;
  end;

  Result := True;
end;

procedure TfRepair.ClearData;
begin
  LabVersion.Caption := '';
  LabWO.Caption := '';
  LabPN.Caption := '';
  Labrecid.Caption:='';
  LabLine.Caption := '';
  LabTerminal.Caption := '';
  LabProcess.Caption := '';
  LVDefect.Items.Clear;
  LVReason.Items.Clear;
  cmbSN.Text := '';
  gbSN := '';
  QryReplace.Close;
  QryRepair.Close;
  if cmbSN.Items.Count > 0 then
    sbtnFailSN.OnClick(Self);
end;

procedure TfRepair.sbtnFailSNClick(Sender: TObject);
begin
// 禁用by key 2008/07/09
{  if ProcessID <> '' then
  begin
    cmbSN.Items.Clear;
    with QryTemp do
    begin
      Close;
      Params.Clear;
      }
     { CommandText := 'Select Serial_Number '
        + 'From SAJET.G_SN_STATUS a, sajet.sys_route_detail b '
        + 'Where NVL(CURRENT_STATUS,''1'') = ''1'' '
        + 'and WORK_FLAG = ''0'' '
        + 'and a.process_id = b.process_id and next_process_id = ' + ProcessID
        + 'and a.route_id = b.route_id '
        + 'Order By Serial_Number';
        }
    { CommandText := 'Select Serial_Number '
        + 'From SAJET.G_SN_STATUS a, sajet.sys_route_detail b '
        + 'Where CURRENT_STATUS = ''1'' '
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
  end; }
end;

procedure TfRepair.FormShow(Sender: TObject);
var sKey: Char;
begin
  {case screen.width of
    640: self.ScaleBy(80,100);
    800: self.ScaleBy(100,100);
    1024: self.ScaleBy(125,100);
  else
    self.ScaleBy(100,100);
  end; }
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
    if not eof then
    begin
      sbtnFailSN.Visible := True;
      cmbSN.Style := csDropDown;
    end
    else
    begin
      sbtnFailSN.Visible := False;
      cmbSN.Style := csSimple;
    end;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base ' +
      'Where param_name = ''Repair-Location&Item'' ';
    Open;
    if IsEmpty then
      giLocateItem := 0
    else if FieldByName('param_value').AsString = 'Location' then
      giLocateItem := 1
    else if FieldByName('param_value').AsString = 'Item' then
      giLocateItem := 2
    else
      giLocateItem := 3;
  end;

   //是否顯示Replace Item
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'Where param_name = ''REPAIR ITEM'' '
      + 'and param_value = ''1'' ';
    Open;
    if RecordCount <> 0 then
    begin
      sbtnRPItem.Visible := True;
      ImageItem.Visible := True;
    end
    else
    begin
      sbtnRPItem.Visible := False;
      ImageItem.Visible := False;
    end;
  end;

  gbSN := '';
  if UpdateUserID <> '0' then
  begin
    LoginUserID := UpdateUserID;
    editRepairer.Text := GetEmpNo(UpdateUserID);
    labRPName.Caption := GetEmpName(UpdateUserID);
    SetStatusbyAuthority;
  end;

  g_tsItem := TStringList.Create;
  g_tsItemPart := TStringList.Create;

  if Pos('SN-', gsSN) <> 0 then
  begin
    cmbSN.Text := Copy(gsSN, 4, Length(gsSN));
    sKey := #13;
    cmbSN.OnKeyPress(self, sKey);
    cmbSN.Enabled := False;
    sbtnFailSN.Enabled := False;
  end;
end;

procedure TfRepair.sbtnScrapClick(Sender: TObject);
var sRes,sEmpNo: string;
var dtnow :tdatetime;
begin
  if gbSN = '' then Exit;

  if MessageDlg('Scrap this SN: "' + gbSN + '" ?', mtConfirmation, [mbYes, mbCancel], 0) = mrYes then
  begin
      sEmpNo := GetEmpNo(UpdateUserID);
      with QryTemp do
      begin
           Close;
           Params.Clear;
           CommandText := 'Select SYSDATE from dual ';
           open;
           dtNow := FieldByName('SYSDATE').asDateTime;
            close;
       end;
      {
      // 過站紀錄  for  SAJET.sj_repair_transation_count proc
      // 此proc add by key 2009/01/03  ,並且一定要在 SAJET.SJ_REPAIR_SCRAP 被執行前運行
      with SProc do
      begin
         try
            Close;
            DataRequest('SAJET.sj_repair_transation_count');
            FetchParams;
            Params.ParamByName('TRECID').AsString := LabRECID.Caption;
            Params.ParamByName('TNOW').AsDateTime := dtNow;
            Params.ParamByName('TEMP').AsString := sEmpNo; //UpdateUserID;
            Params.ParamByName('TTERMINALID').AsString := TerminalID;
            Params.ParamByName('TTYPE').AsString :='SCRAP'; //選擇了 SCRAP 按鈕
            Execute;
            sRes := Params.ParamByName('TRES').AsString;
          except
            on E: Exception do
                sRes := 'sj_repair_transation_count Exception:' + E.Message;
           end;
           Close;
       end;
    if sRes <> 'OK' then
    begin
           MessageDlg(sRes, mtError, [mbCancel], 0);
            Exit;
    end;
    }
    with SProc do
    begin
      try
        Close;
        DataRequest('SAJET.SJ_REPAIR_SCRAP');
        FetchParams;
        Params.ParamByName('TTERMINALID').AsString := TerminalID;
        Params.ParamByName('TSN').AsString := gbSN;
        Params.ParamByName('TWO').AsString := LabWO.Caption;
        Params.ParamByName('TEMPID').AsString := UpdateUserID;
        Execute;
        sRes := Params.ParamByName('TRES').AsString;
      except
        on E: Exception do
          sRes := 'SJ_REPAIR_SCRAP Exception:' + E.Message;
      end;
      Close;
    end;
{    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
      CommandText := 'Update SAJET.G_SN_STATUS ' +
        'Set WORK_FLAG = ''1'', BOX_NO=''N/A'',CARTON_NO=''N/A'',PALLET_NO=''N/A'',QC_NO=''N/A'' ' +
        'Where SERIAL_NUMBER = :SERIAL_NUMBER ';
      Params.ParamByName('SERIAL_NUMBER').AsString := gbSN;
      Execute;

      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      CommandText := 'Update SAJET.G_WO_BASE ' +
        'Set SCRAP_QTY = SCRAP_QTY+1 ' +
        'Where WORK_ORDER = :WORK_ORDER ';
      Params.ParamByName('WORK_ORDER').AsString := LabWO.Caption;
      Execute;
    end; }
    ClearData;
  end;
end;

procedure TfRepair.ShowReasonHistory(DefectCode: string);
begin
   //2007/09/12 by key 資料太大，等待時間太長　
  {with QryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DEFECTCODE', ptInput);
    CommandText := 'Select D.REASON_CODE,D.REASON_DESC,D.ENABLED,Count(REASON_CODE) CNT ' +
      'From SAJET.G_SN_DEFECT A,' +
      'SAJET.G_SN_REPAIR B,' +
      'SAJET.SYS_DEFECT C,' +
      'SAJET.SYS_REASON D ' +
      'Where A.RECID = B.RECID and ' +
      'A.DEFECT_ID = C.DEFECT_ID and ' +
      'C.DEFECT_CODE = :DEFECTCODE and ' +
      'B.REASON_ID = D.REASON_ID ' +
      'Group By D.REASON_CODE,D.REASON_DESC,D.ENABLED ' +
      'Order By CNT DESC ';
    Params.ParamByName('DEFECTCODE').AsString := DefectCode;
    Open;
  end; }
end;

procedure TfRepair.sbtnRepairClick(Sender: TObject);
begin
  if gbSN = '' then Exit;
  if LVDefect.Selected = nil then Exit;

  with TfData.Create(self) do
  begin
    LabDefectCode.Caption := LVDefect.Selected.Caption;
    LabDefectDesc.Caption := LVDefect.Selected.SubItems[0];
    RecID := LVDefect.Selected.SubItems[2];
    First_Recid:=labrecid.Caption;
    ShowReasonHistory(LVDefect.Selected.Caption);
    DataSource1.DataSet := QryData;
    
    if ShowModal = mrOK then
    begin
      LVDefect.Selected.ImageIndex := 0;
      ShowReason(RecID);
    end;
    QryData.Close;
    sString.Free;
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
    if LVDefect.Items.Count > 0 then
    begin
      LVDefect.SetFocus;
      LVDefect.items[0].Selected := True;
      LVDefect.OnClick(self);
    end;
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
      'From SAJET.SYS_DEFECT  ' +
      'Where DEFECT_CODE = :DEFECT  ' +
      'AND ENABLED=''Y''  ';
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
      SubItems.Add('');
      SubItems.Add('');
      SubItems.Add(ProcessId);
      ImageIndex := 1;
    end;
    DefectID := Fieldbyname('DEFECT_ID').AsString;
    Close;
  end;

  // 儲存到 DB
  S := GetDefectRECID;
  if S = '' then Exit;
  LVDefect.Items[LVDefect.Items.Count - 1].SubItems[2] := S;
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

procedure TfRepair.sbtnDeleteClick(Sender: TObject);
begin
  if gbSN = '' then Exit;
  if LVDefect.Selected = nil then Exit;
  if LVDefect.Selected.SubItems[3] = ProcessId then
  begin
    if MessageDlg('Delete Defect Code "' + LVDefect.Selected.Caption + '" ?', mtConfirmation, [mbYes, mbCancel], 0) <> mrYES then
      exit;

      // Delete DB
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      CommandText := 'Delete SAJET.G_SN_DEFECT ' +
        'Where RECID = :RECID ';
      Params.ParamByName('RECID').AsString := LVDefect.Selected.SubItems[2];
      Execute;

      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      CommandText := 'Delete SAJET.G_SN_REPAIR ' +
        'Where RECID = :RECID ';
      Params.ParamByName('RECID').AsString := LVDefect.Selected.SubItems[2];
      Execute;

      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      CommandText := 'Delete SAJET.G_SN_REPAIR_REMARK ' +
        'Where RECID = :RECID ';
      Params.ParamByName('RECID').AsString := LVDefect.Selected.SubItems[2];
      Execute;

      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      CommandText := 'Delete SAJET.G_SN_REPAIR_LOCATION ' +
        'Where RECID = :RECID ';
      Params.ParamByName('RECID').AsString := LVDefect.Selected.SubItems[2];
      Execute;

      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      CommandText := 'Delete SAJET.G_SN_REPAIR_POINT ' +
        'Where RECID = :RECID ';
      Params.ParamByName('RECID').AsString := LVDefect.Selected.SubItems[2];
      Execute;

      Close;
    end;
      // Delete LVDefect;
    LVDefect.Selected.Delete;
    LVReason.Items.Clear;
  end;
end;

procedure TfRepair.LVDefectClick(Sender: TObject);
begin
  if LVDefect.Selected = nil then Exit;
  ShowReason(LVDefect.Selected.SubItems[2]);
end;

procedure TfRepair.sbtnFinishClick(Sender: TObject);
var I: Integer; B: Boolean; sRes, sProcessID, sEmpNo: string;
  slProcessID: TStringList; dtNow: TDateTime;
  Form1 : Hwnd;
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

  sEmpNo := GetEmpNo(UpdateUserID);

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
    end
    else if RecordCount = 1 then
    begin
      sProcessID := FieldByName('next_process_id').AsString;
    end
    else
    begin
      MessageDlg('No Define Return Process!', mtError, [mbOK], 1);
      Exit;
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

  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select SYSDATE from dual ';
    open;
    dtNow := FieldByName('SYSDATE').asDateTime;
    close;
  end;

  {// 過站紀錄  for  SAJET.sj_repair_transation_count proc
  // 此proc add by key 2009/01/03  ,並且一定要在 SAJET.SJ_REPAIR_GO 被執行前運行
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.sj_repair_transation_count');
      FetchParams;
      Params.ParamByName('TRECID').AsString := LabRECID.Caption;
      Params.ParamByName('TNOW').AsDateTime := dtNow;
      Params.ParamByName('TEMP').AsString := sEmpNo; //UpdateUserID;
      Params.ParamByName('TTERMINALID').AsString := TerminalID;
      Params.ParamByName('TTYPE').AsString :='FINISH'; //選擇了 Finish 按鈕 
      Execute;
      sRes := Params.ParamByName('TRES').AsString;
    except
      on E: Exception do
        sRes := 'sj_repair_transation_count Exception:' + E.Message;
    end;
    Close;
  end;
  if sRes <> 'OK' then
  begin
    MessageDlg(sRes, mtError, [mbCancel], 0);
    Exit;
  end;
  }
  // 過站紀錄
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_REPAIR_GO');
      FetchParams;
      Params.ParamByName('TTERMINALID').AsString := TerminalID;
      Params.ParamByName('TSN').AsString := gbSN;
      Params.ParamByName('TNOW').AsDateTime := dtNow;
      Params.ParamByName('TEMP').AsString := sEmpNo; //UpdateUserID;
      Params.ParamByName('NPROCESSID').AsString := sProcessID;
      Execute;
      sRes := Params.ParamByName('TRES').AsString;
    except
      on E: Exception do
        sRes := 'SJ_REPAIR_GO Exception:' + E.Message;
    end;
    Close;
  end;
  if sRes <> 'OK' then
  begin
    MessageDlg(sRes, mtError, [mbCancel], 0);
    Exit;
  end;
  ClearData;
  if gsSN <> '' then begin
    Form1 := FindWindow(nil, 'Repair');
    if Form1 <> 0 then
      SendMessage(Form1, $8001, 0, 0);
  end;
end;

procedure TfRepair.cmbSNChange(Sender: TObject);
begin
  LabVersion.Caption := '';
  LabWO.Caption := '';
  LabPN.Caption := '';
  Labrecid.Caption:='';
  LabLine.Caption := '';
  LabTerminal.Caption := '';
  LabProcess.Caption := '';
  LVDefect.Items.Clear;
  LVReason.Items.Clear;
  gbSN := '';
  labRPName.Caption := '';
  QryReplace.Close;
  QryRepair.Close;
end;

procedure TfRepair.sbtnReplaceClick(Sender: TObject);
begin
  if gbSN = '' then Exit;
  if (LVDefect.Selected = nil) then Exit;
  with TformKP.Create(self) do
  begin
    labSN.Caption := fRepair.gbSN;
    ShowKP;
    g_startkpcount:=0;
    g_startkpcount:= QryData.recordcount;  //replace kp　之前kpsn的個數
    DataSource1.DataSet := QryData;
    RecID := LVDefect.Selected.SubItems[2];
    if Sender = sbtnRemove then
    begin
      LabNewKP.Visible := False;
      editKP.Visible := LabNewKP.Visible;
      LabNewKP.Visible:= LabNewKP.Visible;
      editkpno.Visible := LabNewKP.Visible;
      cbyes.Visible:= LabNewKP.Visible;
      Labcbyes.Visible:= LabNewKP.Visible;
      LabRemark.Visible := LabNewKP.Visible;
      memo.Visible := LabNewKP.Visible;
      sbtnRemoveKP.Top := sbtnSave.top;
      sbtnRemoveKP.Left := sbtnSave.Left;
      ImgRemove.Top := Image3.Top;
      ImgRemove.Left := Image3.Left;
      sbtnSave.Visible := LabNewKP.Visible;
      Image3.Visible := LabNewKP.Visible;
      dbgridKP.Height := 214;
    end
    else if Sender = sbtnReplace then
    begin
      sbtnRemoveKP.Visible := False;
      ImgRemove.Visible := sbtnRemoveKP.Visible;
      sbtnRemoveAllKP.Visible := sbtnRemoveKP.Visible;
      ImgRemoveAll.Visible := sbtnRemoveKP.Visible;
      dbgridKP.Height := 102;
      LabNewKP.Visible := True;
      editKP.Visible := LabNewKP.Visible;
      LabRemark.Visible := LabNewKP.Visible;
      memo.Visible := LabNewKP.Visible;
    end;
    ShowModal;
    QryData.Close;
    Free;
  end;
  //showReplace;    //2007/09/12 by key 資料太大，等待時間太長
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
    CommandText := 'Select A.work_order,A.SERIAL_NUMBER "SerialNumber",B.PART_NO "KPNO",A.ITEM_PART_ID "ID",ITEM_PART_SN "KPSN",B.SPEC1 "SPEC", Item_Group, Process_Id ' +
      'From SAJET.G_SN_KEYPARTS A,' +
      'SAJET.SYS_PART B ' +
      'Where A.SERIAL_NUMBER = :SN and ' +
      'A.ITEM_PART_ID = B.PART_ID(+) ' +
      'Order By B.PART_NO ';
    Params.ParamByName('SN').AsString := Trim(SN);
    Open;
  end;
end;

procedure TfRepair.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  g_tsItem.free;
  g_tsItemPart.free;
end;

procedure TfRepair.sbtnRPItemClick(Sender: TObject);
begin
  if gbSN = '' then Exit;
  if LVDefect.Selected = nil then Exit;

  with TformRpItem.Create(self) do
  begin
    ShowModal;
  end;

end;

procedure TfRepair.chkBoxKpClick(Sender: TObject);
begin
   ShowReplace; 
end;

procedure TfRepair.showRepair;
var i: Integer;
begin
  with QryRepair do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SN', ptInput);

   { CommandText := 'SELECT C.PROCESS_NAME "Defect Process", E.DEFECT_CODE||'',''||E.DEFECT_DESC "Defect" '
      + '       ,D.PROCESS_NAME "RP Process", F.REASON_DESC "Reason", G.DUTY_CODE||'',''||G.DUTY_DESC  "Duty", '
      + '       A.REC_TIME "Rec Time" '
      + '  FROM sajet.G_SN_DEFECT A,sajet.G_SN_REPAIR B,SAJET.SYS_PROCESS C ,SAJET.SYS_PROCESS D , '
      + '       SAJET.SYS_DEFECT E,SAJET.SYS_REASON F, SAJET.SYS_DUTY G '
      + ' WHERE A.SERIAL_NUMBER = :SN '
      + ' AND A.RP_STATUS =''0'' '
      + ' AND A.RECID = B.RECID '
      + ' AND A.PROCESS_ID = C.PROCESS_ID '
      + ' AND A.DEFECT_ID = E.DEFECT_ID '
      + ' AND B.RP_PROCESS_ID=D.PROCESS_ID '
      + ' AND B.REASON_ID = F.REASON_ID '
      + ' AND B.DUTY_ID=G.DUTY_ID '
      + ' ORDER BY "Rec Time","Defect" ';
      }
     CommandText := 'SELECT C.PROCESS_NAME "Defect Process", E.DEFECT_CODE||'',''||E.DEFECT_DESC "Defect" '
      + '       ,D.PROCESS_NAME "RP Process", F.REASON_DESC "Reason", G.DUTY_CODE||'',''||G.DUTY_DESC  "Duty", '
      + '       A.REC_TIME "Rec Time",H.LOCATION,H.ITEM_NO '
      + '  FROM sajet.G_SN_DEFECT A,sajet.G_SN_REPAIR B,SAJET.SYS_PROCESS C ,SAJET.SYS_PROCESS D , '
      + '       SAJET.SYS_DEFECT E,SAJET.SYS_REASON F, SAJET.SYS_DUTY G,SAJET.G_SN_REPAIR_LOCATION H '
      + ' WHERE A.SERIAL_NUMBER = :SN '
      + ' AND A.RP_STATUS =''0'' '
      + ' AND A.RECID = B.RECID '
      +'  AND A.RECID = H.RECID '
      + ' AND A.PROCESS_ID = C.PROCESS_ID '
      + ' AND A.DEFECT_ID = E.DEFECT_ID '
      + ' AND B.RP_PROCESS_ID=D.PROCESS_ID '
      + ' AND B.REASON_ID = F.REASON_ID '
      + ' AND B.DUTY_ID=G.DUTY_ID '
      + ' ORDER BY "Rec Time","Defect" ';
    Params.ParamByName('SN').AsString := cmbSN.Text;
    Open;
  end;
  for i := 0 to 5 do
    DBGrid2.Columns.Items[i].Width := 100;
end;

function TfRepair.ShowDefectTemp(RECID: string): Boolean;
var
  sReason: string;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SN', ptInput);
    Params.CreateParam(ftString, 'RECID', ptInput);
    CommandText := 'Select D.REASON_CODE,D.REASON_DESC,e.Location,e.Item_no ' +
      'From SAJET.G_SN_DEFECT A, ' +
      'SAJET.SYS_DEFECT B, ' +
      'SAJET.G_SN_REPAIR C, ' +
      'SAJET.SYS_REASON D, ' +
      'sajet.G_SN_REPAIR_LOCATION e ' +
      'Where A.Serial_Number = :SN and ' +
      'A.DEFECT_ID = B.DEFECT_ID and ' +
      'A.RECID = :RECID and ' +
      'A.RECID = C.RECID and ' +
      'C.REASON_ID = D.REASON_ID ' +
      'AND C.recId = e.RecID(+) ' +
      'AND C.Reason_id = e.REASON_ID(+) ' +
      'ORDER BY d.reason_code, d.reason_desc,e.Location,e.Item_no ';
    Params.ParamByName('SN').AsString := gbSN;
    Params.ParamByName('RECID').AsString := RECID;
    Open;
    LVReason.Items.Clear;
    sReason := '';
    while not Eof do
    begin
      with LVReason.Items.Add do
      begin
        if sReason <> Fieldbyname('REASON_CODE').AsString then
        begin
          Caption := Fieldbyname('REASON_CODE').AsString;
          SubItems.Add(Fieldbyname('REASON_DESC').AsString);
          SubItems.Add(Fieldbyname('Location').AsString);
          SubItems.Add(Fieldbyname('Item_no').AsString);
          sReason := Fieldbyname('REASON_CODE').AsString;
        end
        else
        begin
          Caption := '';
          SubItems.Add('');
          SubItems.Add(Fieldbyname('Location').AsString);
          SubItems.Add(Fieldbyname('Item_no').AsString);
          sReason := Fieldbyname('REASON_CODE').AsString;
        end;
      end;
      Next;
    end;
    Close;
  end;
  Result := True;
end;

procedure TfRepair.sbtnRepairerClick(Sender: TObject);
begin
  with TfFilter.Create(Self) do
  begin
    with QryData do
    begin
      RemoteServer := fRepair.QryData.RemoteServer;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_NO', ptInput);
      CommandText := 'SELECT B.EMP_NO,B.EMP_NAME,B.EMP_ID '
        + '  FROM( '
        + '        SELECT  EMP_ID '
        + '          FROM SAJET.SYS_EMP_PRIVILEGE  '
        + '         WHERE PROGRAM =''Repair'' '
        + '        UNION '
        + '       SELECT B.EMP_ID  '
        + '             FROM SAJET.SYS_ROLE_PRIVILEGE A, '
        + '                          SAJET.SYS_ROLE_EMP B, '
        + '                          SAJET.SYS_PROGRAM_FUN C '
        + '           WHERE A.ROLE_ID = B.ROLE_ID '
        + '                AND A.PROGRAM = ''Repair''  '
        + '                 AND  A.PROGRAM = C.PROGRAM '
        + '                 AND   A.FUNCTION = C.FUNCTION  '
        + '                 AND  A.AUTHORITYS = C.AUTHORITYS  '
        + '        GROUP BY   B.EMP_ID '
        + '      )A , '
        + '   SAJET.SYS_EMP B '
        + '  WHERE A.EMP_ID = B.EMP_ID(+) '
        + '  AND EMP_NO Like :EMP_NO '
        + '  AND B.ENABLED = ''Y'' '
        + '  ORDER BY B.EMP_NO,B.EMP_NAME ';
      Params.ParamByName('EMP_NO').AsString := Trim(editRepairer.Text) + '%';
      Open;
    end;
    DBGrid1.Columns.Items[2].Visible := False;
    if Showmodal = mrOK then
    begin
      editRepairer.Text := QryData.Fieldbyname('EMP_NO').AsString;
      labRPName.caption := QryData.Fieldbyname('EMP_NAME').AsString;
      UpdateUserID := QryData.Fieldbyname('EMP_ID').AsString;
      if UpdateUserID <> '0' then
        SetStatusbyAuthority;
         //editVendorKeyPress(editVendor, K);
    end;
    QryData.Close;
    Free;
  end;
end;


function TfRepair.GetEmpName(psUserID: string): string;
begin
  Result := '0';

  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select EMP_Name '
      + '  From SAJET.SYS_EMP '
      + ' Where EMP_ID = ' + psUserID;
    Open;
    Result := FieldByName('EMP_Name').AsString;
    Close;
  end;
end;

procedure TfRepair.editRepairerChange(Sender: TObject);
begin

  labRPName.Caption := '';

  sbtnAdd.Enabled := False;
  AddDefect1.Enabled := sbtnAdd.Enabled;

  sbtnDelete.Enabled := sbtnAdd.Enabled;
  DeleteDfect1.Enabled := sbtnAdd.Enabled;

  sbtnRepair.Enabled := sbtnAdd.Enabled;
  RepairRecord1.Enabled := sbtnAdd.Enabled;

  sbtnFinish.Enabled := sbtnAdd.Enabled;
  Finish1.Enabled := sbtnAdd.Enabled;

  sbtnReplace.Enabled := sbtnAdd.Enabled;
  sbtnRemove.Enabled := sbtnAdd.Enabled;
  sbtnRPItem.Enabled := sbtnAdd.Enabled;
  sbtnScrap.Enabled := sbtnAdd.Enabled;
  Scrap1.Enabled := sbtnAdd.Enabled;
end;

procedure TfRepair.editRepairerKeyPress(Sender: TObject; var Key: Char);
var
  sTemp: string;
  sEMPID, sEMPNO, sEMPNAME: string;
begin
  if (Key = #13) then
  begin
        // 過濾
    editRepairer.text := Trim(editRepairer.text);
        // If repairer 空白 則自動帶出login user
    if editRepairer.text = '' then
    begin
      UpdateUserID := LoginUserID;
      editRepairer.Text := GetEmpNo(UpdateUserID);
      labRPName.caption := GetEmpName(UpdateUserID);
      if UpdateUserID <> '0' then
        SetStatusbyAuthority;
      if CmbSN.Enabled then
        CmbSN.SetFocus;
      Exit;
    end
    else
    begin
      CheckEMPPRI(editRepairer.text, sTemp, sEMPID, sEMPNO, sEMPNAME);
      if sTemp <> 'OK' then
      begin
        MessageDlg(sTemp, mtError, [mbCancel], 0);
        editRepairer.SelectAll;
        editRepairer.SetFocus;
        Exit;
      end;
      labRPName.caption := sEMPNAME;
      editRepairer.Text := sEMPNO;
      UpdateUserID := sEMPID;
      if UpdateUserID <> '0' then
        SetStatusbyAuthority;
      if CmbSN.Enabled then
        CmbSN.SetFocus;
    end;
  end;
end;



function TfRepair.GetEmpID(sEMPNO: string): string;
begin
  Result := '0';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select EMP_Name '
      + '  From SAJET.SYS_EMP '
      + ' Where EMP_NO = ' + sEMPNO;
    Open;
    Result := FieldByName('EMP_ID').AsString;
    Close;
  end;
end;


procedure TfRepair.CheckEMPPRI(EmpNO: string; var sMSG, sEMPID, sEMP_NO,
  sEMP_NAME: string);
begin
  sMSG := '';
  sEMPID := '0';
  sEMP_NO := '0';
  sEMP_NAME := '0';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    params.CreateParam(ftString, 'EMP_NO', ptInput);
    CommandText := '  SELECT B.EMP_NO,B.EMP_NAME,B.EMP_ID,B.ENABLED '
      + '  FROM SAJET.SYS_EMP B '
      + '  WHERE EMP_NO Like :EMP_NO ';
    Params.ParamByName('EMP_NO').AsString := EmpNO;
    Open;
    if EOF then
      sMSG := 'EMP(' + EmpNO + ') NOT FOUND!'
    else if FieldByName('ENabled').AsString <> 'Y' then
      sMSG := 'EMP(' + EmpNO + ') Disable!';
    if sMSG <> '' then Exit;
    sMSG := 'OK';
    sEMPID := FieldByName('EMP_ID').AsString;
    sEMP_NO := FieldByName('EMP_NO').AsString;
    sEMP_NAME := FieldByName('EMP_NAME').AsString;
    Close;
  end;
end;


procedure TfRepair.cmbSNCloseUp(Sender: TObject);
var sKey: Char;
begin
  cmbSN.Text := cmbSN.Items.Strings[cmbSN.ItemIndex];
  if cmbSN.Text = '' then Exit;
  sKey := #13;
  cmbSN.OnKeyPress(self, sKey);
end;

procedure TfRepair.SbtQueryReplaceClick(Sender: TObject);
begin
   ShowReplace;
end;

procedure TfRepair.SbtnQueryRepairedClick(Sender: TObject);
begin
   showRepair;
end;

end.

