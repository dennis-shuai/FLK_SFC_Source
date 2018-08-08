unit uReworkbyPiece;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls,
  Db, DBClient, MConnect, SConnect, IniFiles, ObjBrkr;

type
  TfReworkbyPiece = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    Image1: TImage;
    sbtnExecute: TSpeedButton;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    Label4: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label14: TLabel;
    editSN: TEdit;
    Label8: TLabel;
    LabRoute: TLabel;
    LabInProcess: TLabel;
    cmbProcess: TComboBox;
    Bevel2: TBevel;
    DataSource1: TDataSource;
    GridTravel: TStringGrid;
    LabReworkNo: TLabel;
    editReworkNo: TEdit;
    cmbRoute: TComboBox;
    chkbPacking: TCheckBox;
    LabPacking: TLabel;
    chkbQC: TCheckBox;
    LabQC: TLabel;
    Image3: TImage;
    SpeedButton1: TSpeedButton;
    chkRWWo: TCheckBox;
    LabRWWO: TLabel;
    editRWWO: TEdit;
    sbtnWOSearch: TSpeedButton;
    chkbCSN: TCheckBox;
    LabNewCSN: TLabel;
    Label1: TLabel;
    chkbPallet: TCheckBox;
    chkbBox: TCheckBox;
    Label2: TLabel;
    QryTemp1: TClientDataSet;
    chkbKeypart: TCheckBox;
    lbl1: TLabel;
    procedure editSNKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure cmbRouteChange(Sender: TObject);
    procedure sbtnExecuteClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure chkRWWoClick(Sender: TObject);
    procedure editRWWOChange(Sender: TObject);
    procedure editRWWOKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnWOSearchClick(Sender: TObject);
    procedure chkbPackingClick(Sender: TObject);
    procedure chkbPalletClick(Sender: TObject);
    procedure chkbBoxClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID: string;
    FCID: string;

    Authoritys, AuthorityRole: string;
    G_sWorkOrder: string;
    G_tsSerialNumber: TStrings;
    G_tsQCLot: TStrings;
    gbRewWO: Boolean;
    G_rModelID, G_rVersion: string;
    procedure showSNData;
    procedure ClearData;
    function GetRouteID(RouteName: string; var RouteId: string): Boolean;
    function GetProcessID(ProcessName: string; var ProcessID: string): Boolean;
    procedure ShowRoute;
    procedure ShowRouteProcess;
    procedure DspTravelData;
    procedure SetStatusbyAuthority;
    procedure SetStatusbyAuthority_Configuration;
    function CheckReworkNo: Boolean;
    procedure SetReworkCondition;
    procedure GET_REWORK_NO;
    function  checkQCEmpty(sQCLot:String):Boolean;
    procedure disableQCLot(sQCLotList:String);
  end;

var
  fReworkbyPiece: TfReworkbyPiece;
const G_sPrgName = 'Rework';

implementation

uses uWOFilter, uConfirm;

{$R *.DFM}

function TfReworkbyPiece.checkQCEmpty(sQCLot:String):Boolean;
begin
   Result := False;

   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select * From SAJET.G_SN_STATUS '
                   + ' Where QC_NO = ''' + sQCLot + ''' '
                   + '   And Rownum = 1 ';
      Open;
      if Eof then
         Result := True;
      Close;
   end;
end;

procedure TfReworkbyPiece.disableQCLot(sQCLotList:String);
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Update SAJET.G_QC_LOT '
                   + '   SET ENABLED = ''N'' '
                   + ' Where QC_LOTNO in (' + sQCLotList + ') ';
      Execute;
   end;
end;

procedure TfReworkbyPiece.SetStatusbyAuthority;
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
      Params.ParamByName('PRG').AsString := G_sPrgName;
      Params.ParamByName('FUN').AsString := 'Rework  By Piece Check SN RULL';
      Execute;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;

      if iPrivilege = 0 then
      begin
         Close;
         DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
         FetchParams;
         Params.ParamByName('EMPID').AsString := UpdateUserID;
         Params.ParamByName('PRG').AsString := G_sPrgName;
         Params.ParamByName('FUN').AsString := 'Rework  By Piece Check SN RULL';
         Execute;
         if Params.ParamByName('TRES').AsString = 'OK' then
         begin
            iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
         end;
      end;
    finally
      close;
    end;
  end;
  sbtnExecute.Enabled := (iPrivilege >= 1);
end;

procedure TfReworkbyPiece.SetStatusbyAuthority_Configuration;
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
      Params.ParamByName('PRG').AsString := G_sPrgName;
      Params.ParamByName('FUN').AsString := 'Configuration';
      Execute;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;
  chkbPacking.Enabled := (iPrivilege >= 1);
  chkbPallet.Enabled := chkbPacking.Enabled;
  chkbBox.Enabled := chkbPacking.Enabled;
  chkbQC.Enabled := chkbPacking.Enabled;
  chkbCSN.Enabled := chkbPacking.Enabled;
  LabNewCSN.Enabled := chkbPacking.Enabled;
  LabPacking.Enabled := chkbPacking.Enabled;
  LabQC.Enabled := chkbPacking.Enabled;
end;

function TfReworkbyPiece.GetRouteID(RouteName: string; var RouteId: string): Boolean;
begin
  Result := False;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'ROUTENAME', ptInput);
    CommandText := 'Select ROUTE_ID ' +
      'From SAJET.SYS_ROUTE ' +
      'Where ROUTE_NAME = :ROUTENAME ';
    Params.ParamByName('ROUTENAME').AsString := RouteName;
    Open;
    if RecordCount > 0 then
      RouteId := Fieldbyname('ROUTE_ID').AsString;
    Close;
  end;
  Result := True;
end;

function TfReworkbyPiece.GetProcessID(ProcessName: string; var ProcessID: string): Boolean;
begin
  Result := False;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PROCESSNAME', ptInput);
    CommandText := 'Select PROCESS_ID ' +
      'From SAJET.SYS_PROCESS ' +
      'Where PROCESS_NAME = :PROCESSNAME ';
    Params.ParamByName('PROCESSNAME').AsString := ProcessName;
    Open;
    if RecordCount > 0 then
      ProcessID := Fieldbyname('PROCESS_ID').AsString;
    Close;
  end;
  Result := True;
end;

procedure TfReworkbyPiece.ShowRoute;
begin
  cmbRoute.Items.Clear;
  cmbRoute.Items.Add('');
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select ROUTE_NAME ' +
      'From SAJET.SYS_ROUTE ' +
      'Where ENABLED = ''Y'' ' +
      'Order By ROUTE_NAME ';
    Open;
    while not Eof do
    begin
      cmbRoute.Items.Add(Fieldbyname('ROUTE_NAME').AsString);
      Next;
    end;
    Close;
  end;
  if cmbRoute.Items.Count > 0 then
    cmbRoute.ItemIndex := 0;
  ShowRouteProcess;
end;

procedure TfReworkbyPiece.ShowRouteProcess;
begin
  cmbProcess.Items.Clear;
  if cmbRoute.Items.IndexOf(cmbRoute.Text) < 0 then Exit;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'ROUTE_NAME', ptInput);
    CommandText := 'Select C.PROCESS_NAME,B.RESULT,B.SEQ ' +
      'From SAJET.SYS_ROUTE A,' +
      'SAJET.SYS_ROUTE_DETAIL B,' +
      'SAJET.SYS_PROCESS C ' +
      'Where A.ROUTE_NAME = :ROUTE_NAME and ' +
      'A.ROUTE_ID = B.ROUTE_ID and ' +
      'B.NEXT_PROCESS_ID = C.PROCESS_ID ' +
      'Order By B.SEQ ';
    Params.ParamByName('ROUTE_NAME').AsString := cmbRoute.Text;
    Open;
    while not Eof do
    begin
      if Fieldbyname('RESULT').AsString = '1' then
        Break;
      if cmbProcess.Items.IndexOf(Fieldbyname('PROCESS_NAME').AsString) < 0 then
        cmbProcess.Items.Add(Fieldbyname('PROCESS_NAME').AsString);
      Next;
    end;
    if cmbProcess.Items.Count > 0 then
      cmbProcess.ItemIndex := 0;
  end;
end;

procedure TfReworkbyPiece.editSNKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    if editSN.Text = '' then Exit;
    if editRWWO.Text = '' then Exit;
    showSNData;
    editSN.SetFocus;
    editSN.SelectAll;
  end;
end;

procedure TfReworkbyPiece.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;

  with TIniFile.Create('SAJET.ini') do
  begin
    FcID := ReadString('System', 'Factory', '');
    Free;
  end;
  ShowRoute;
  if UpdateUserID <> '0' then
  begin
    SetStatusbyAuthority;
    SetStatusbyAuthority_Configuration;
  end;
  G_tsSerialNumber := TStringList.Create;
  G_tsQCLot := TStringList.Create;
  ClearData;
  SetReworkCondition;

  //CheckBox透明化 (不要有框框出來)
 { chkRWWo.Brush.style := bsClear;
  SetWindowLong(chkRWWo.Handle, GWL_EXstyle, WS_EX_TRANSPARENT);
  chkbCSN.Brush.style := bsClear;
  SetWindowLong(chkbCSN.Handle, GWL_EXstyle, WS_EX_TRANSPARENT);
  chkbPacking.Brush.style := bsClear;
  SetWindowLong(chkbPacking.Handle, GWL_EXstyle, WS_EX_TRANSPARENT);
  chkbQC.Brush.style := bsClear;
  SetWindowLong(chkbQC.Handle, GWL_EXstyle, WS_EX_TRANSPARENT);
  chkbPallet.Brush.style := bsClear;
  SetWindowLong(chkbPallet.Handle, GWL_EXstyle, WS_EX_TRANSPARENT);}
end;

procedure TfReworkbyPiece.cmbRouteChange(Sender: TObject);
begin
  ShowRouteProcess;
end;

procedure TfReworkbyPiece.showSNData;
begin
  //ClearData;
  DspTravelData;
end;

procedure TfReworkbyPiece.ClearData;
var I: Integer;
begin
  with GridTravel do
  begin
    for i := 0 to RowCount - 1 do
      Rows[i].Clear;
    RowCount := 2;
    ColCount := 8;
    Cells[0, 0] := 'S/N';
    Cells[1, 0] := 'Customer SN';
    Cells[2, 0] := 'Work Order';
    Cells[3, 0] := 'Line';
    Cells[4, 0] := 'Process';
    Cells[5, 0] := 'Terminal';
    Cells[6, 0] := 'Operator';
    Cells[7, 0] := 'Time';
  end;
  editReworkNo.Text := '';
  editSN.Text := '';
  G_sWorkOrder := '';
  G_tsSerialNumber.Clear;
  G_tsQCLot.Clear;

  editRWWO.Text := '';
  if chkRWWo.Checked then
    editRWWO.Setfocus
  else
    editReworkNo.Setfocus;
end;

procedure TfReworkbyPiece.DspTravelData;
var i: integer;
    sSN :string;
begin
  try
    with QryTemp do
    begin

      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SN', ptInput);
      CommandText := 'Select A.SERIAL_NUMBER,NVL(A.CUSTOMER_SN,''N/A'') CUSTOMER_SN  ' +
        '      ,A.WORK_ORDER,NVL(D.PDLINE_NAME,A.PDLINE_ID) PDLINE_NAME ' +
        '      ,NVL(B.PROCESS_NAME,A.PROCESS_ID) PROCESS_NAME ' +
        '      ,NVL(E.TERMINAL_NAME,A.TERMINAL_ID) TERMINAL_NAME ' +
        '      ,NVL(C.EMP_NAME ,A.EMP_ID) EMP_NAME ' +
        '      ,TO_CHAR(A.IN_PROCESS_TIME,''YYYY/MM/DD HH24:MI'') TIME ' +
        '      ,A.Work_Flag, A.QC_No ' +
      'From SAJET.G_SN_STATUS A,' +
        'SAJET.SYS_PROCESS B,' +
        'SAJET.SYS_EMP C,' +
        'SAJET.SYS_PDLINE D,' +
        'SAJET.SYS_TERMINAL E ' +
        'Where A.SERIAL_NUMBER = :SN and ' +
        'A.PROCESS_ID = B.PROCESS_ID(+) and ' +
        'A.EMP_ID=C.EMP_ID(+) and ' +
        'A.PDLINE_ID = D.PDLINE_ID(+) and ' +
        'A.TERMINAL_ID = E.TERMINAL_ID(+) ';

      Params.ParamByName('SN').AsString := editSN.Text;
      Open;
      if IsEmpty then
      begin
        //刷入客戶序號
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'SN', ptInput);
        CommandText := 'Select A.SERIAL_NUMBER,NVL(A.CUSTOMER_SN,''N/A'') CUSTOMER_SN  ' +
          '      ,A.WORK_ORDER,NVL(D.PDLINE_NAME,A.PDLINE_ID) PDLINE_NAME ' +
          '      ,NVL(B.PROCESS_NAME,A.PROCESS_ID) PROCESS_NAME ' +
          '      ,NVL(E.TERMINAL_NAME,A.TERMINAL_ID) TERMINAL_NAME ' +
          '      ,NVL(C.EMP_NAME ,A.EMP_ID) EMP_NAME ' +
          '      ,TO_CHAR(A.IN_PROCESS_TIME,''YYYY/MM/DD HH24:MI'') TIME ' +
          '      ,A.Work_Flag, A.QC_NO ' +

        'From SAJET.G_SN_STATUS A,' +
          'SAJET.SYS_PROCESS B,' +
          'SAJET.SYS_EMP C,' +
          'SAJET.SYS_PDLINE D,' +
          'SAJET.SYS_TERMINAL E ' +
          'Where A.CUSTOMER_SN = :SN and ' +
          'A.PROCESS_ID = B.PROCESS_ID(+) and ' +
          'A.EMP_ID=C.EMP_ID(+) and ' +
          'A.PDLINE_ID = D.PDLINE_ID(+) and ' +
          'A.TERMINAL_ID = E.TERMINAL_ID(+) ';

        Params.ParamByName('SN').AsString := editSN.Text;
        Open;

        if IsEmpty then
        begin
          MessageDlg('Serial Number  or Customer SN Error !', mtWarning, [mbOK], 0);
          exit;
        end;
        ssn:= fieldbyname('Serial_number').AsString;
      end else begin
        sSN:= editSN.Text;
      end ;

      if not IsEmpty then
      begin
         // ssn:= editSn.Text;
          if (chkRWWo.Checked) and (FieldByName('Work_Order').AsString = editRWWO.Text) then
          begin
            MessageDlg('Work Order = New Wo', mtWarning, [mbOK], 0);
            exit;
          end;
          {if G_sWorkOrder <>'' then
          begin
            if FieldByName('Work_Order').AsString <> G_sWorkOrder then
            begin
              MessageDlg('Work Order :'+FieldByName('Work_Order').AsString+' Different!',mtWarning,[mbOK],0);
              exit;
            end;
          end; }
          if FieldByName('Work_Flag').AsString = '1' then
          begin
            MessageDlg('The S/N. Scrap !!', mtError, [mbOK], 0);
            Exit;
          end;
          if G_tsSerialNumber.IndexOf(FieldByName('Serial_Number').AsString) <> -1 then
          begin
              MessageDlg('Serial Number Duplicate!', mtWarning, [mbOK], 0);
              exit;
          end;

         if Copy(editRWWO.Text,2,2) <> 'MS' then
         begin
              SProc.Close;
              SProc.DataRequest('SAJET.SJ_CHK_KP_RULE');
              SProc.FetchParams;
              SProc.Params.ParamByName('ITEM_PART_ID').AsString := G_rModelID ;
              SProc.Params.ParamByName('ITEM_PART_SN').AsString := editSN.Text;
              SProc.Execute;

              if SProc.Params.ParamByName('TRES').AsString <>'OK' then
              begin
                  MessageDlg('SN 編碼原則錯誤', mtWarning, [mbOK], 0);
                  Exit;
              end;
         end;

         QryTemp1.Close;
         QryTemp1.Params.clear ;
         QryTemp1.Params.CreateParam(ftstring,'SN',ptinput);
         QryTemp1.CommandText := 'select FAIL_TIMES from sajet.g_SN_TEST_TIMES where Serial_number = :sn';
         QryTemp1.Params.ParamByName('SN').AsString  := sSN;
         Qrytemp1.Open;

         if not QryTemp1.IsEmpty then begin
             if  QryTemp1.FieldByName('FAIL_TIMES').AsInteger >=3 then begin
               MessageDlg('FAIL TIMES >=3 !', mtWarning, [mbOK], 0);
               exit;
             end;

         end;

 
        for I := 0 to Fields.Count - 2 do
        begin
          GridTravel.Cells[i, GridTravel.RowCount - 1] := FieldS[i].Text;
        end;
        GridTravel.RowCount := GridTravel.RowCount + 1;
        G_sWorkOrder := FieldByName('Work_Order').AsString;
        G_tsSerialNumber.Add(FieldByName('Serial_Number').AsString);
        if (FieldByName('QC_No').AsString <> 'N/A') and (G_tsQCLot.IndexOf(FieldByName('QC_No').AsString)=-1) then
           G_tsQCLot.Add(FieldByName('QC_No').AsString);
      end;
    end;
  finally
    editSN.SelectAll;
    editSN.SetFocus;
    QryTemp.Close;
  end;
end;

procedure TfReworkbyPiece.sbtnExecuteClick(Sender: TObject);
var RouteID, ProcessID, sQCLotList: string;
  I: integer;
  InputKey: Char;
  function GetData(LstBox: TListBox): string;
  var I: Integer;
  begin
    Result := LstBox.Items.Strings[0];
    for I := 1 to LstBox.Items.Count - 1 do
    begin
      Result := Result + ''',''' + LstBox.Items.Strings[I];
    end;
  end;
begin
  if chkRWWo.checked then
  begin
    InputKey := #13;
    if not gbRewWO then
    begin
      editRWWOKeyPress(self, InputKey);
      if not gbRewWO then exit;
    end;
  end;


  if G_tsSerialNumber.count = 0 then
  begin
    MessageDlg('No Serial Number Data To Rework !!', mtError, [mbCancel], 0);
    Exit;
  end;

  editReworkNo.Text := trim(editReworkNo.Text);
  if editReworkNO.Text = '' then
  begin
    MessageDlg('Rework No Error !!', mtError, [mbCancel], 0);
    editReworkNo.SetFocus;
    Exit;
  end;
  if not CheckReworkNo then
  begin
    MessageDlg('Rework No Duplicate !!', mtError, [mbCancel], 0);
    editReworkNo.SelectAll;
    editReworkNo.SetFocus;
    Exit;
  end;

  if cmbRoute.Text = '' then
  begin
    MessageDlg('Rework Way Error !!', mtError, [mbCancel], 0);
    Exit;
  end;

  if cmbProcess.Text = '' then
  begin
    MessageDlg('Rework Way Error !!', mtError, [mbCancel], 0);
    Exit;
  end;

  //確認畫面
  fConfirm := TfConfirm.Create(Self);
  with fConfirm do
  begin
    LabReworkNo.Caption := fReworkbyPiece.editReworkNO.Text;
    LabWO.Caption := fReworkbyPiece.G_sWorkOrder;
    LabRoute.Caption := fReworkbyPiece.cmbRoute.Text;
    LabProcess.Caption := fReworkbyPiece.cmbProcess.Text;
    LabQty.Caption := IntToStr(fReworkbyPiece.G_tsSerialNumber.count);
    if ShowModal <> mrOK then
    begin
      free;
      exit; ;
    end;
    free;
  end;

  RouteID := '';
  if not GetRouteID(cmbRoute.Text, RouteID) then Exit;

  ProcessID := '';
  if not GetProcessID(cmbProcess.Text, ProcessID) then Exit;

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'REWORK_NO', ptInput);
    Params.CreateParam(ftString, 'SN', ptInput);
    CommandText := 'Update SAJET.G_SN_STATUS ' +
                   '   Set REWORK_NO = :REWORK_NO ' +
                   ' Where Serial_Number = :SN ';
    Params.ParamByName('REWORK_NO').AsString := editReworkNO.Text;
    for I := 0 to G_tsSerialNumber.Count - 1 do
    begin
      Params.ParamByName('SN').AsString := G_tsSerialNumber.Strings[I];
      Execute;
    end;
    Close;

    Params.Clear;
    Params.CreateParam(ftString, 'REWORK_NO', ptInput);
    CommandText := 'Insert Into SAJET.G_REWORK_LOG ' +
                   'Select * From SAJET.G_SN_STATUS ' +
                   'Where REWORK_NO = :REWORK_NO ';
    Params.ParamByName('REWORK_NO').AsString := editReworkNO.Text;
    Execute;

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'REWORK_NO', ptInput);
    Params.CreateParam(ftString, 'EMP_ID', ptInput);

    CommandText := ' Insert Into SAJET.G_REWORK_NO '
                 + ' (REWORK_NO,EMP_ID,UPDATE_TIME) '
                 + ' VALUES '
                 + ' (:REWORK_NO,:EMP_ID,SYSDATE) ';
    Params.ParamByName('REWORK_NO').AsString := editReworkNO.Text;
    Params.ParamByName('EMP_ID').AsString := UpdateUserID;
    Execute;

    Params.Clear;
    Params.CreateParam(ftString, 'ROUTEID', ptInput);
    Params.CreateParam(ftString, 'PROCESSID', ptInput);
    Params.CreateParam(ftString, 'WIPPROCESS', ptInput);
    Params.CreateParam(ftString, 'REWORK_NO', ptInput);
    CommandText := 'Update SAJET.G_SN_STATUS ' +
                   'Set ROUTE_ID = :ROUTEID, ' +
                   '    NEXT_PROCESS = :PROCESSID, ' +
                   '    WORK_FLAG = Decode(WORK_FLAG,''2'',''0'',WORK_FLAG), ' +
                   '    Current_Status = Decode(Current_Status,''1'',''0'',Current_Status), ' + //2005/12/15 Add
                   '    WIP_PROCESS = :WIPPROCESS ';
    if chkRWWo.Checked then
      CommandText := CommandText
                   + ' ,WORK_ORDER = ''' + editRWWO.Text + ''' '
                   + ' ,MODEL_ID = ''' + G_rModelID + ''' '
                   + ' ,VERSION = ''' + G_rVersion + ''' '
                   + ' ,IN_PDLINE_TIME = NULL '
                   + ' ,OUT_PDLINE_TIME = NULL '; //2005/8/11 add

    if chkbCSN.Checked then
      CommandText := CommandText
                   + ' ,CUSTOMER_SN =''N/A'' ';
    if chkbBox.Checked then
      CommandText := CommandText
                   + ' ,PALLET_NO =''N/A'',CARTON_NO =''N/A'',Box_No=''N/A'' '
    else if chkbPacking.Checked then
      CommandText := CommandText
                   + ' ,PALLET_NO =''N/A'',CARTON_NO =''N/A'' '
    else if (chkbPallet.Checked) and (not chkbPacking.Checked) then
      CommandText := CommandText
                   + ' ,PALLET_NO =''N/A'' ';
    if chkbQC.Checked then
      CommandText := CommandText
                   + ' ,QC_NO =''N/A'' '
                   + ' ,QC_RESULT =''N/A'' ';
    commandTExt := commandText
                   + 'Where REWORK_NO = :REWORK_NO ';
    Params.ParamByName('ROUTEID').AsString := RouteID;
    Params.ParamByName('PROCESSID').AsString := ProcessID;
    if chkRWWo.Checked then
      Params.ParamByName('WIPPROCESS').AsString := '0'
    else
      Params.ParamByName('WIPPROCESS').AsString := ProcessID;
    Params.ParamByName('REWORK_NO').AsString := editReworkNO.Text;
    Execute;
    Close;

     //20150714檢查Keyparts，Disabled  Dennis Shuai
     if chkbKeypart.Checked then begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'SN', ptInput);
         CommandText := 'UPDATE SAJET.G_SN_KEYPARTS  ' +
                         'SET ENABLED=''N'' ' +
                         'Where Serial_Number = :SN ';
         Params.ParamByName('SN').AsString := editReworkNO.Text;
         for I := 0 to G_tsSerialNumber.Count - 1 do
         begin
            Params.ParamByName('SN').AsString := G_tsSerialNumber.Strings[I];
            Execute;
         end;
         Execute;
     end;
  end;
  //--------------------------------
  //2006/10/18 Add 檢查QC No是否為空並Disabled ====================
  if chkbQC.Checked then
  begin
       if G_tsQCLot.Count <> 0 then
       begin
          for i:=0 to G_tsQCLot.Count-1 do
          begin
             if checkQCEmpty(G_tsQCLot.Strings[i]) then
             begin
                if sQCLotList = '' then
                   sQCLotList := ''''+G_tsQCLot.Strings[i]+''''
                else
                   sQCLotList := sQCLotList+','''+G_tsQCLot.Strings[i]+'''';
             end;
          end;

          if sQCLotList <> '' then
             disableQCLot(sQCLotList);
       end;
  end;
  //===============================================================

  ClearData;
  if chkbPacking.Enabled then
    SetReworkCondition;
end;

function TfReworkbyPiece.CheckReworkNo: Boolean;
begin
  Result := False;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'REWORK_NO', ptInput);
    CommandText := 'Select REWORK_NO ' +
      'From SAJET.G_REWORK_NO ' +
      'Where REWORK_NO = :REWORK_NO ';
    Params.ParamByName('REWORK_NO').AsString := editReworkNO.Text;
    Open;
    Result := (RecordCount <= 0);
    Close;
  end;
end;

procedure TfReworkbyPiece.FormDestroy(Sender: TObject);
begin
  G_tsSerialNumber.Free;
  G_tsQCLot.Free;
end;

procedure TfReworkbyPiece.SetReworkCondition;
begin
  chkbPacking.checked := False;
  chkbQC.Checked := False;
  chkbCSN.Checked := False;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PARAM_NAME', ptInput);

    CommandText := 'Select PARAM_VALUE ' +
      'From SAJET.SYS_BASE ' +
      'Where PARAM_NAME=:PARAM_NAME ';
    Params.ParamByName('PARAM_NAME').AsString := G_sPrgName;
    Open;
    while not eof do
    begin
      if FieldByName('PARAM_VALUE').AsString = 'Remove Carton No' then
        chkbPacking.checked := True;
      if FieldByName('PARAM_VALUE').AsString = 'Remove QCLot' then
        chkbQC.checked := True;
      if FieldByName('PARAM_VALUE').AsString = 'Remove CSN' then
        chkbCSN.checked := True;
      next;
    end;
  end;
end;

procedure TfReworkbyPiece.SpeedButton1Click(Sender: TObject);
begin
  cleardata;
end;

procedure TfReworkbyPiece.chkRWWoClick(Sender: TObject);
begin
  gbRewWO := false;
  if chkRWWo.Checked then
  begin
    editRWWO.Color := $00B0FFFF;
    editRWWO.Enabled := True;
    LabRWWO.Enabled := True;
    sbtnWOSearch.Enabled := True;
    editReworkNO.Enabled := False;
    LabReworkNO.Enabled := False;

    cmbRoute.Enabled := False;
    //LabRoute.Enabled:=False;
    cmbProcess.Enabled := False;
    //LabInProcess.Enabled:=False;

    chkbPacking.Enabled := False;
    chkbQC.Enabled := False;
    chkbBox.Enabled:=False;
    chkbPallet.Enabled := False;

    chkbPacking.checked := True;
    chkbQC.checked := True;
    //chkbCSN.checked:=True;
  end
  else
  begin
    editRWWO.Color := clWhite;
    editRWWO.Enabled := False;
    LabRWWO.Enabled := False;
    sbtnWOSearch.Enabled := False;
    editReworkNO.Enabled := True;
    LabReworkNO.Enabled := True;

    cmbRoute.Enabled := True;
    //LabRoute.Enabled:=True;
    cmbProcess.Enabled := True;
    //LabInProcess.Enabled:=True;

    if UpdateUserID <> '0' then
      SetStatusbyAuthority_Configuration;

    SetReworkCondition;
  end;
end;

procedure TfReworkbyPiece.editRWWOChange(Sender: TObject);
begin
  gbRewWO := False;
  editReworkNo.Text := '';
  cmbRoute.ItemIndex := -1;
  cmbProcess.ItemIndex := -1;
end;

procedure TfReworkbyPiece.editRWWOKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    GET_REWORK_NO;
end;

procedure TfReworkbyPiece.GET_REWORK_NO;
var sMessage, sRWWO, sReworkNo, sWOStartProcess: string;
begin
  sMessage := '';
  try
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);

      CommandText := 'Select WORK_ORDER ,WO_STATUS, B.ROUTE_NAME, A.MODEL_ID, A.VERSION '
        + '      ,C.PROCESS_NAME  '
        + 'From SAJET.G_WO_BASE A '
        + '    ,SAJET.SYS_ROUTE B '
        + '    ,SAJET.SYS_PROCESS C '
        + 'Where WORK_ORDER=:WORK_ORDER '
        + 'and A.Route_ID = B.Route_ID(+) '
        + 'and a.START_PROCESS_ID = C.PROCESS_ID ';
      Params.ParamByName('WORK_ORDER').AsString := editRWWO.Text;
      Open;
      if RecordCount = 0 then
      begin
        sMessage := 'New WO Error';
        exit;
      end;
      case FieldByName('WO_STATUS').AsInteger of
        0: sMessage := 'New WO Initial';
        5: sMessage := 'New WO Cancel';
        6: sMessage := 'New WO Complete';
        7: sMessage := 'New WO Delete';
      else
        sRWWO := editRWWO.Text;
        G_rModelID := FieldByName('MODEL_ID').AsString;

        G_rVersion := FieldByName('VERSION').AsString;
      end;
      if sMessage <> '' then exit;

      //找Rework WO的Route及Process
      sWOStartProcess := FieldByName('PROCESS_NAME').AsString;
      cmbRoute.ItemIndex := cmbRoute.Items.IndexOf(FieldByName('ROUTE_NAME').AsString);
      ShowRouteProcess;
      //指定到工單的Start Process
      if cmbProcess.Items.IndexOf(sWOStartProcess) <> -1 then
        cmbProcess.ItemIndex := cmbProcess.Items.IndexOf(sWOStartProcess);

      //找最大Rework No

      Close;
      Params.Clear;
      //Params.CreateParam(ftString	,'WORK_ORDER' ,ptInput);
      CommandText := 'Select  NVL(max(REWORK_NO),''0'') RWNO ' +
                     'from SAJET.G_REWORK_NO '+
                     'Where Rework_No like '''+editRWWO.Text+'%''';
      //Params.ParamByName('WORK_ORDER').AsString := sRWWO;
      Open;
      sReworkNo:= FieldByName('RWNO').asstring;
      if   sReworkNo = '0' then
           sReworkNo := 'NA'
      else begin
          Close;
          Params.Clear;
          //Params.CreateParam(ftString	,'WORK_ORDER' ,ptInput);
          QryTemp.CommandText := 'Select  max( to_number(subStr( REWORK_NO,'+IntToStr(length(editRWWO.Text)+1)+', length(REWORK_NO)- '+IntTOStr(length(editRWWO.Text)) +')))  RWNO ' +
                         'from SAJET.G_REWORK_NO '+
                         'Where Rework_No like '''+editRWWO.Text+'%''';
          //Params.ParamByName('WORK_ORDER').AsString := sRWWO;
          Open;
          sReworkNo:= FieldByName('RWNO').asstring;
      end;
      if sReworkNo = 'NA' then
        editReworkNO.Text := sRWWO + '001'
      else
        editReworkNO.Text := sRWWO + FormatFloat('000', StrToInt(sReworkNo)+1);

      sReworkNo :=  editReworkNO.Text;
      gbRewWO:=True;
      editSN.SetFocus;

    end;
  finally
    if sMessage <> '' then
    begin
      MessageDlg(sMessage, mtError, [mbCancel], 0);
      editRWWO.SetFocus;
    end;
  end;
end;

procedure TfReworkbyPiece.sbtnWOSearchClick(Sender: TObject);
begin
  fSearchWO := TfSearchWO.Create(Self);
  with fSearchWO do
  begin
    QryWO.RemoteServer := fReworkbyPiece.QryTemp.RemoteServer;
    QryWO.ProviderName := 'DspQryTemp1';

    ShowModal;
    free;
  end;
end;

procedure TfReworkbyPiece.chkbPackingClick(Sender: TObject);
begin
  if chkbPacking.Checked then
  begin
    chkbPallet.Checked := False;
    chkbBox.Checked := False;
    chkbQC.Checked := True;
  end;
  chkbQC.Enabled := not chkbPacking.Checked;
end;

procedure TfReworkbyPiece.chkbPalletClick(Sender: TObject);
begin
  if chkbPallet.Checked then
  begin
    chkbPacking.Checked := False;
    chkbBox.Checked := False;
    chkbQC.Checked := True;
  end;
  chkbQC.Enabled := not chkbPallet.Checked;
end;

procedure TfReworkbyPiece.chkbBoxClick(Sender: TObject);
begin
  if chkbBox.Checked then
  begin
    chkbPacking.Checked := False;
    chkbPallet.Checked := False;
    chkbQC.Checked := True;
  end;
  chkbQC.Enabled := not chkbBox.Checked;
end;

end.

