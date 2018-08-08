unit uRepair;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db,
  DBClient, MConnect, SConnect, IniFiles, ImgList, ObjBrkr, Menus, Variants;

type
  TfRepair = class(TForm)
    Panel1: TPanel;
    LabelPacking: TLabel;
    Label1: TLabel;
    sbtnFinish: TSpeedButton;
    Image3: TImage;
    cmbSN: TComboBox;
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
    QryReplace: TClientDataSet;
    QryRepair: TClientDataSet;
    editRepairer: TEdit;
    sbtnRepairer: TSpeedButton;
    labRPName: TLabel;
    Label12: TLabel;
    Label11: TLabel;
    Label14: TLabel;
    Label2: TLabel;
    LabTerminal: TLabel;
    ImageAll: TImage;
    StringGrid1: TStringGrid;
    Label3: TLabel;
    edtReason: TEdit;
    Label4: TLabel;
    edtMethod: TEdit;
    Label5: TLabel;
    cmbLocation: TComboBox;
    lblReason: TLabel;
    lblMethod: TLabel;
    lblAD: TLabel;
    PopupMenu2: TPopupMenu;
    Delete1: TMenuItem;
    Label6: TLabel;
    edtDateCode: TComboBox;
    Label7: TLabel;
    QryTemp2: TClientDataSet;
    procedure sbtnFailSNClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnScrapClick(Sender: TObject);
    procedure sbtnRepairClick(Sender: TObject);
    procedure cmbSNKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnFinishClick(Sender: TObject);
    procedure edtReasonKeyPress(Sender: TObject; var Key: Char);
    procedure edtMethodKeyPress(Sender: TObject; var Key: Char);
    procedure Delete1Click(Sender: TObject);
  private
    { Private declarations }
    procedure ShowReasonHistory(DefectCode: string);
  public
    { Public declarations }
    mPartID, sRouteID, sStep, gbSN,mStageID: string;
    UpdateUserID: string;
    LoginUserID, gsSN,sReason,sDuty: string;
    TerminalID, StageID, ProcessId, PDLineId: string;
    FcID: string;
    Authoritys, AuthorityRole,sWO,sPN,sRECID: string;
    dtOutTime: TDateTime;
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

    function ShowDefectTemp(RECID: string): Boolean;
  
  end;

var
  fRepair: TfRepair;
const g_iCol = 5; //g_tsItem行數

implementation

uses  uProcess;

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
begin

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
     i:integer;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SN', ptInput);
    Params.CreateParam(ftDateTime, 'sTime', ptInput);
    CommandText := 'Select A.WORK_ORDER,A.MODEL_ID,A.Serial_NUMBER,J.CUSTOMER_SN,A.RECID,B.DEFECT_CODE,B.DEFECT_DESC,h.Location,C.PDLINE_NAME,' +
      'D.TERMINAL_NAME,E.PROCESS_NAME,A.RP_STATUS,NVL(G.REASON_CODE,''N/A'') REASON_CODE, a.Process_Id ' +
      ',sajet.Sj_Get_Defect_Location(A.RECID) "LOCATION" ' +
      'From SAJET.G_SN_DEFECT A, ' +
      'SAJET.SYS_DEFECT B,' +
      'SAJET.SYS_PDLINE C,' +
      'SAJET.SYS_TERMINAL D,' +
      'SAJET.SYS_PROCESS E, ' +
      'SAJET.G_SN_REPAIR F,' +
      'SAJET.SYS_REASON G ,' +
      'SAJET.G_SN_REPAIR_LOCATION H ,' +
      'SAJET.G_SN_STATUS J ' +
      'Where A.Serial_Number = :SN and ' +
      'a.Serial_number =J.Serial_number and '+
      //'a.rec_time >= :sTime and ' +
      'A.DEFECT_ID = B.DEFECT_ID(+) and ' +
      'A.PDLINE_ID = C.PDLINE_ID(+) and ' +
      'A.TERMINAL_ID = D.TERMINAL_ID(+) and ' +
      'A.PROCESS_ID = E.PROCESS_ID(+) and ' +
      'A.RECID = F.RECID(+) and ' +
      'F.REASON_ID = G.REASON_ID(+) ' +
      '   AND a.recid = h.recid(+) '+
      'Order by a.rec_time DEsc ';
    Params.ParamByName('SN').AsString := gbSN;
    //Params.ParamByName('sTime').AsDateTime := dtOutTime;
    Open;
    
    for i:=0 to StringGrid1.RowCOunt-1 do begin
       if   StringGrid1.Cells[1,i] =  FieldByName('SERIAL_NUMBER').AsString then begin
          exit;
       end;

    end;

    StringGrid1.Cells[0,StringGrid1.RowCount-1] := FieldByName('WORK_ORDER').AsString;
    StringGrid1.Cells[1,StringGrid1.RowCount-1] := FieldByName('SERIAL_NUMBER').AsString;
    StringGrid1.Cells[2,StringGrid1.RowCount-1] := FieldByName('CUSTOMER_SN').AsString;
    StringGrid1.Cells[3,StringGrid1.RowCount-1] := FieldByName('DEFECT_CODE').AsString;
    StringGrid1.Cells[4,StringGrid1.RowCount-1] := FieldByName('PDLINE_NAME').AsString;
    StringGrid1.Cells[5,StringGrid1.RowCount-1] := sRouteID;
    StringGrid1.Cells[6,StringGrid1.RowCount-1] := sstep;
    StringGrid1.Cells[7,StringGrid1.RowCount-1] := FieldByName('RECID').AsString;;
    StringGrid1.Cells[8,StringGrid1.RowCount-1] := FieldByName('Model_ID').AsString;
    StringGrid1.RowCount :=  StringGrid1.RowCount +1;
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
    
    Close;
  end;
end;


procedure TfRepair.InputSN;
begin
  if not CheckSN then Exit;

  // 顯示 Defect Data
  if not ShowDefect then Exit;

  // 顯示 Reason Data

//  showReplace;   //2007/09/12 by key 資料太大，等待時間太長　
  //ShowBomItem;
 // showRepair;   //2007/09/12 by key 資料太大，等待時間太長　
end;

function TfRepair.CheckSN: Boolean;
var sRes, sProcessID: string;
FAIL_TIMES,REPAIR_TIMES,MAX_REPAIR_TIMES:integer;
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
      CommandText := 'Select A.PROCESS_ID,a.serial_number, A.stage_id,A.WORK_ORDER,A.WORK_FLAG,A.MODEL_ID,B.PART_NO,A.VERSION, A.OUT_PROCESS_TIME, a.route_id ' //, c.step '
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
    sWO := Fieldbyname('WORK_ORDER').AsString;
    sPN  := Fieldbyname('PART_NO').AsString;
    mPartID := Fieldbyname('MODEL_ID').AsString;
    mStageID := Fieldbyname('Stage_ID').AsString;
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
    if UPPERCASE(sRes) = 'REPAIR NG' then begin
      sRes :='OK';
    end;
    if sRes <> 'OK' then
    begin
       gbSN := '';
       MessageDlg(sRes, mtError, [mbCancel], 0);
       Exit;
    end;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.CommandText :='select * from SAJET.SYS_BASE  '+
                        ' where  PARAM_NAME =''MAX_REPAIR_TIMES'' ';
    QryTemp.Open;
    MAX_REPAIR_TIMES := QryTemp.fieldByName('PARAM_VALUE').AsInteger;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'SN',ptInput);
    QryTemp.Params.CreateParam(ftString,'stage',ptInput);
    QryTemp.CommandText :='select Count(*) REPAIR_TIMES from SAJET.G_SN_REPAIR a,SAJET.G_SN_DEFECT b '+
                          ' where A.SERIAL_NUMBER = :SN  and a.RECID =b.RECID  and b.Stage_id=:stage ';
    QryTemp.Params.ParamByName('SN').AsString := gbSN;
    QryTemp.Params.ParamByName('stage').AsString := mStageID;
    QryTemp.Open;

    REPAIR_TIMES := QryTemp.FieldByName('REPAIR_TIMES').AsInteger;

    if  REPAIR_TIMES >=MAX_REPAIR_TIMES then
    begin
       MessageDlg('維修次數不能大於 !!'+IntToStr(MAX_REPAIR_TIMES), mtError, [mbCancel], 0);
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
var i,j:integer;
begin
  for i:=0 to StringGrid1.ColCount-1 do
   for j:=1 to StringGrid1.RowCOunt-1 do
  StringGrid1.Cells [i,j]:='';
  StringGrid1.RowCount :=2;
  edtReason.text :='';
  edtMethod.text :='';
  cmbLocation.text :='';
  cmbSN.Text :='';
  cmbSN.SetFocus;
  edtDateCode.Text;

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


  gbSN := '';
  if UpdateUserID <> '0' then
  begin
    LoginUserID := UpdateUserID;
    editRepairer.Text := GetEmpNo(UpdateUserID);
    labRPName.Caption := GetEmpName(UpdateUserID);
    SetStatusbyAuthority;
  end;


  if Pos('SN-', gsSN) <> 0 then
  begin
    cmbSN.Text := Copy(gsSN, 4, Length(gsSN));
    sKey := #13;
    cmbSN.OnKeyPress(self, sKey);
    cmbSN.Enabled := False;
    sbtnFailSN.Enabled := False;
  end;
  StringGrid1.RowCount :=2;
  StringGrid1.FixedRows :=1;
  StringGrid1.Cells[0,0] :='WORK_ORDER';
  StringGrid1.Cells[1,0] :='SERIAL_NUMBER';
  StringGrid1.Cells[2,0] :='CUSTOMER_SN';
  StringGrid1.Cells[3,0] :='DEFECT_CODE';
  StringGrid1.Cells[4,0] :='LINE';
  StringGrid1.Cells[5,0] :='Route';
  StringGrid1.Cells[6,0] :='Step';
  StringGrid1.Cells[7,0] :='sRECID';
  StringGrid1.Cells[8,0] :='Model_ID';
  StringGrid1.RowHeights[0] :=20;
  cmbSN.SetFocus;
end;

procedure TfRepair.sbtnScrapClick(Sender: TObject);
var sRes,sEmpNo: string;
    dtnow :tdatetime;
    i:integer;
begin
  if gbSN = '' then Exit;
  if stringGrid1.RowCount <=2 then Exit;

  if MessageDlg('Scrap this SN?', mtConfirmation, [mbYes, mbCancel], 0) = mrYes then
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

      // 過站紀錄  for  SAJET.sj_repair_transation_count proc
      // 此proc add by key 2009/01/03  ,並且一定要在 SAJET.SJ_REPAIR_SCRAP 被執行前運行

    for i:=1 to StringGrid1.RowCount-2 do begin
        with SProc do
        begin
          try
            Close;
            DataRequest('SAJET.SJ_REPAIR_SCRAP');
            FetchParams;
            Params.ParamByName('TTERMINALID').AsString := TerminalID;
            Params.ParamByName('TSN').AsString := StringGrid1.Cells[1,i];
            Params.ParamByName('TWO').AsString := StringGrid1.Cells[0,i];;
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

    end;
    ClearData;
  end;

end;

procedure TfRepair.ShowReasonHistory(DefectCode: string);
begin
 
end;

procedure TfRepair.sbtnRepairClick(Sender: TObject);
begin
  if gbSN = '' then Exit;

end;

procedure TfRepair.cmbSNKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    InputSN;
    cmbSN.SetFocus;
    cmbSN.SelectAll;
  end

end;

procedure TfRepair.sbtnFinishClick(Sender: TObject);
var i,j: Integer; B: Boolean; sRes, sProcessID, sEmpNo,sReasonID,sDutyID,sLocation: string;
  slProcessID: TStringList; dtNow: TDateTime;
  Form1 : Hwnd;
begin
  if stringGrid1.RowCount <=2 then Exit;
  if edtReason.Text =''  then exit;
  if edtMethod.Text ='' then exit;
  if Trim(cmbLocation.Text) ='' then exit;

  sReason :=edtReason.Text ;
  sDuty :=  edtMethod.Text;
  sLocation := cmbLocation.Text;

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'REASON_CODE', ptInput);
    CommandText:='Select Reason_Id, Reason_Code, Reason_Desc,Enabled From SAJET.SYS_REASON Where REASON_Code = :REASON_CODE ';
    Params.ParamByName('REASON_CODE').AsString := sReason;
    Open;
    sReasonID := fieldbyName('Reason_Id').AsString;
  end;
  if QryTemp.Isempty then begin
      MessageDlg('不良原因代碼錯誤',mterror,[mbok],0);
      exit;

  end;

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'Duty_Code', ptInput);
    CommandText:='Select Duty_Id, Duty_Code, Duty_Desc ,Enabled From SAJET.SYS_DUTY Where Duty_Code = :DUTY_CODE';
    Params.ParamByName('DUTY_CODE').AsString := sDuty;
    Open;
    sDutyID := fieldbyName('Duty_Id').AsString;
  end;

  if QryTemp.Isempty then begin
      MessageDlg('維修動作錯誤',mterror,[mbok],0);
      exit;

  end;

  IF EDTdATEcODE.Text ='' THEN BEGIN
     MessageDlg('請輸入更換物料DateCode，沒有更換請選擇第一項',mterror,[mbok],0);
     exit;
  END;

  for i:=1 to StringGrid1.RowCount-2 do begin
  
      {
      Sproc.Close;
      Sproc.DataRequest('SAJET.SJ_REPAIR_CHK_REPAIREDTIMES') ;
      Sproc.FetchParams;
      Sproc.Params.ParamByName('TTYPE').AsString :='LOCATION';
      Sproc.Params.ParamByName('TRECID').AsString :=StringGrid1.Cells[7,i];
      Sproc.Params.ParamByName('TSN').AsString := StringGrid1.Cells[1,i];
      Sproc.Params.ParamByName('TWO').AsString := StringGrid1.Cells[0,i];
      Sproc.Params.ParamByName('TREADONID').AsString :=sReasonID;
      Sproc.Params.ParamByName('TLOCATION').AsString := sLocation;
      Sproc.Params.ParamByName('TEMPID').AsString :=UpdateUserID;
      Sproc.Execute;

      if  Sproc.Params.ParamValues['TRES'] <> 'OK' then  begin
        MessageDlg(Sproc.Params.ParamValues['TRES'],mtERROR,[mbOK],0);
        exit;
      end;
      }

      with QryTemp do
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
        Params.CreateParam(ftString, 'TERMINALID', ptInput);
        CommandText := 'Insert Into SAJET.G_SN_REPAIR (RECID,SERIAL_NUMBER,WORK_ORDER,MODEL_ID,REPAIR_EMP_ID,REASON_ID, RP_TERMINAL_ID,RP_PROCESS_ID, '
                       +'RP_STAGE_ID,DUTY_PROCESS_ID,DUTY_ID, ITEM_ID,RECORD_TYPE,REMARK,LOCATION  ) Select :RECID RECID,:SERIAL_NUMBER SERIAL_NUMBER, '
                       +':WORK_ORDER WORK_ORDER,:MODEL_ID MODEL_ID,:REPAIR_EMP_ID REPAIR_EMP_ID,:REASON_ID REASON_ID, TERMINAL_ID RP_TERMINAL_ID, '
                       +'PROCESS_ID RP_PROCESS_ID,STAGE_ID RP_STAGE_ID, :DUTY_PROCESS_ID DUTY_PROCESS_ID,:DUTY_ID DUTY_ID,:ITEM_ID ITEM_ID,:RECORD_TYPE '
                       +'RECORD_TYPE,:REMARK REMARK,:LOCATION LOCATION From SAJET.SYS_TERMINAL Where TERMINAL_ID = :TERMINALID' ;
        Params.ParamByName('RECID').AsString := StringGrid1.Cells[7,i];
        Params.ParamByName('SERIAL_NUMBER').AsString :=  StringGrid1.Cells[1,i];
        Params.ParamByName('WORK_ORDER').AsString := StringGrid1.Cells[0,i];
        Params.ParamByName('MODEL_ID').AsString := StringGrid1.Cells[8,i];
        Params.ParamByName('REPAIR_EMP_ID').AsString := UpdateUserID;
        Params.ParamByName('REASON_ID').AsString := sReasonID;
        Params.ParamByName('DUTY_PROCESS_ID').AsString := '0';
        Params.ParamByName('DUTY_ID').AsString := sDutyID;
        Params.ParamByName('TERMINALID').AsString := TerminalID;
        execute;
      end;

      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'RECID', ptInput);
        Params.CreateParam(ftString, 'REASON_ID', ptInput);
        CommandText := 'Delete SAJET.G_SN_REPAIR_LOCATION WHERE RECID = :RECID AND REASON_ID = :REASON ' ;
        Params.ParamByName('RECID').AsString := StringGrid1.Cells[7,i];
        Params.ParamByName('REASON').AsString := sReasonID;
        execute;
      end;

      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'RECID', ptInput);
        Params.CreateParam(ftString, 'LOCATION ', ptInput);
        Params.CreateParam(ftString, 'UPDATE_USERID ', ptInput);
        Params.CreateParam(ftString, 'REASON_ID ', ptInput);
        Params.CreateParam(ftString, 'WORK_ORDER ', ptInput);
        Params.CreateParam(ftString, 'DateCode ', ptInput);
        CommandText := 'Insert Into SAJET.G_SN_REPAIR_LOCATION      (RECID,LOCATION,UPDATE_USERID,UPDATE_TIME,ITEM_NO,REASON_ID,ITEM_ID,WORK_ORDER,ITem_DateCode) '
                       + 'VALUES (:RECID,:LOCATION,:UPDATE_USERID,SYSDATE,:ITEM_NO,:REASON_ID,:ITEM_ID,:WORK_ORDER,:DateCode) ' ;
        Params.ParamByName('RECID').AsString := StringGrid1.Cells[7,i];
        Params.ParamByName('LOCATION').AsString := sLocation;
        Params.ParamByName('LOCATION').AsString := edtDateCode.Text;
        Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
        Params.ParamByName('REASON_ID').AsString := sReasonID;
        Params.ParamByName('WORK_ORDER').AsString := StringGrid1.Cells[0,i];
        execute;
      end;

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
        Params.ParamByName('iRoute').AsString := StringGrid1.Cells[5,i];
        Params.ParamByName('iStep').AsString := StringGrid1.Cells[6,i];
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
     // sProcessID := '100272';

      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'SN', ptInput);
        CommandText := 'Update SAJET.G_SN_DEFECT ' +
          'Set RP_STATUS = ''0'' ' +
          'Where SERIAL_NUMBER = :SN ';
        Params.ParamByName('SN').AsString := StringGrid1.Cells[1,i];;
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

      // 過站紀錄
      with SProc do
      begin
        try
          Close;
          DataRequest('SAJET.SJ_REPAIR_GO');
          FetchParams;
          Params.ParamByName('TTERMINALID').AsString := TerminalID;
          Params.ParamByName('TSN').AsString := StringGrid1.Cells[1,i];;
          Params.ParamByName('TNOW').AsDateTime := dtNow;
          Params.ParamByName('TEMP').AsString := GetEmpNo(UpdateUserID);
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
    
      if gsSN <> '' then begin
        Form1 := FindWindow(nil, 'Repair');
        if Form1 <> 0 then
          SendMessage(Form1, $8001, 0, 0);
      end;
  end;


  MessageDlg('Repair ok',mtConfirmation,[mbOK],0);
  ClearData;
  
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
  end ;
  Result := True;
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

procedure TfRepair.edtReasonKeyPress(Sender: TObject; var Key: Char);
begin
   if Key <> #13 then exit;
   if Length(edtReason.Text)=0 then exit;
   QryTemp.Close;
   QryTemp.Params.Clear;
   QryTemp.Params.CreateParam(ftstring,'Reason',ptInput) ;
   QryTemp.CommandText :='Select * from Sajet.SYS_REASON WHERE REASON_CODE =:REASON';
   QryTemp.Params.ParamByName('REASON').AsString :=edtReason.Text;
   QryTEmp.Open;

   if QryTemp.IsEmpty then begin
        MessageDlg('ERROR REPAIR REASON',mterror,[mbOK],0);
        edtReason.SelectAll;
        edtReason.SetFocus;
        exit;

   end;
   lblReason.Caption := '不良原因:'+QryTemp.FieldByName('REASON_DESC').AsString;
   lblAD.Caption := '建議維修方法:'+QryTemp.FieldByName('REASON_DESC2').AsString;
   edtmethod.setfocus;
   edtMethod.SelectAll;
   sReason := edtReason.Text;

end;

procedure TfRepair.edtMethodKeyPress(Sender: TObject; var Key: Char);
begin
   if Key <> #13 then exit;
   if Length(edtMethod.Text)=0 then exit;
   QryTemp.Close;
   QryTemp.Params.Clear;
   QryTemp.Params.CreateParam(ftstring,'duty',ptInput) ;
   QryTemp.CommandText :='Select * from Sajet.SYS_DUTY WHERE DUTY_CODE=:duty';
   QryTemp.Params.ParamByName('duty').AsString :=edtMethod.Text;
   QryTEmp.Open;

   if QryTemp.IsEmpty then begin
        MessageDlg('ERROR REPAIR METHOD',mterror,[mbOK],0);
        edtMethod.SelectAll;
        edtMethod.SetFocus;
        exit;
   end;
   lblMethod.Caption := QryTemp.FieldByName('DUTY_DESC').AsString;
   sDuty := edtMethod.Text;
   cmbLocation.SetFocus;

end;

procedure TfRepair.Delete1Click(Sender: TObject);
var 
i_row,j_col:integer; 
begin
  if stringgrid1.rowcount >1 then begin
    stringgrid1.Rows[stringgrid1.row].Clear;
    for j_col:=0 to stringgrid1.colcount do
    for i_row:=stringgrid1.Row to stringgrid1.rowcount-1 do
    stringgrid1.cells[j_col,i_row]:=stringgrid1.cells[j_col,i_row+1];
    stringgrid1.RowCount:=stringgrid1.RowCount-1;
    stringgrid1.Refresh;
  end;
end;

end.
