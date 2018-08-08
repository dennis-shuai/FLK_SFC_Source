unit uPrintLabel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, IniFiles, ExtCtrls, DB, DBClient, StdCtrls, Math, unitCSPrintData, unitDataBase,
  Grids, DBGrids;

type
  TDBGrid = class(DBGrids.TDBGrid)
  public
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
  end;
  TfPrintLabel = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabelPacking: TLabel;
    Label1: TLabel;
    Image4: TImage;
    Label26: TLabel;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    LabTerminal: TLabel;
    SProc: TClientDataSet;
    panlMessage: TPanel;
    Label4: TLabel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Label9: TLabel;
    Label13: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    Label2: TLabel;
    La_GString: TLabel;
    editSN: TEdit;
    lablPartNo: TLabel;
    Label16: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    im4: TImage;
    im5: TImage;
    Image1: TImage;
    LabGPS: TLabel;
    LabCustPart: TLabel;
    Label22: TLabel;
    PanelShift: TPanel;
    PanelLine: TPanel;
    PanelProcess: TPanel;
    PanelTerminal: TPanel;
    Label6: TLabel;
    LabWorkorder: TLabel;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    Label3: TLabel;
    LabSN: TLabel;
    lbl1: TLabel;
    editwo: TEdit;
    procedure FormShow(Sender: TObject);
    procedure editSNKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure editwoKeyPress(Sender: TObject; var Key: Char);
    procedure editwoChange(Sender: TObject);
  private
    { Private declarations }
    function CheckPassSN: Boolean;
    function GetCfgData: Boolean;
  public
    { Public declarations }
    UpdateUserID, UpdateUserNo, Uprocessid, gsType: string;
    function GetTerminalID: Boolean;
    function CheckShift: Boolean;
    function GetUserNo(sUserID: string): string;
  end;

var
  fPrintLabel: TfPrintLabel;
  g_sSampleFile, g_sSaveFile, g_tsTitle, g_tsPrintLabel: string;
  g_tsPrintQty: Integer;
  dtSysdate: TDateTime;
  CodesoftVersion: Byte;
  FlagBox:string;

implementation

{$R *.DFM}

uses uDllform, Dllinit;

var
  TerminalID, sLINDID, sStageID: string;

function TfPrintLabel.GetTerminalID: Boolean;
begin
  Result := False;
  with TIniFile.Create('SAJET.ini') do
  begin
    TerminalID := ReadString('PrintLabel', 'Terminal', '');
    Free;
  end;
  if TerminalID = '' then
  begin
    MessageDlg('Terminal not be assign !!', mtError, [mbCancel], 0);
    Exit;
  end;
  with QryTemp do
  begin
    try
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'TERMINALID', ptInput);
      CommandText := 'Select A.PROCESS_ID,A.TERMINAL_NAME,B.PROCESS_NAME,C.PDLINE_NAME ,D.STAGE_NAME ' +
        '      ,A.PDLINE_ID,A.STAGE_ID ' +
        'From  SAJET.SYS_TERMINAL A,' +
        ' SAJET.SYS_PROCESS B, ' +
        ' SAJET.SYS_STAGE D, ' +
        ' SAJET.SYS_PDLINE C ' +
        'Where   A.TERMINAL_ID = :TERMINALID '
        + ' AND A.PROCESS_ID = B.PROCESS_ID '
        + '   AND A.STAGE_ID = D.STAGE_ID '
        + ' AND A.PDLINE_ID = C.PDLINE_ID ';
      Params.ParamByName('TERMINALID').AsString := TerminalID;
      Open;
      if RecordCount <= 0 then
      begin
        Close;
        MessageDlg('Terminal data error !!', mtError, [mbCancel], 0);
        Exit;
      end;
      LabTerminal.Caption := Fieldbyname('PROCESS_NAME').AsString + ' ' +
        Fieldbyname('TERMINAL_NAME').AsString;
      PanelProcess.Caption := FieldbyName('Process_Name').AsString;
      Uprocessid := FieldbyName('Process_id').AsString;
      sLINDID := FieldbyName('PDLINE_ID').AsString;
      sStageID := FieldbyName('STAGE_ID').AsString;
      PanelTerminal.Caption := FieldByName('Terminal_Name').AsString;
      PanelLine.Caption := FieldByName('PDLINE_NAME').AsString;
    finally
      Close;
    end;
  end;
  Result := True;
end;

function TfPrintLabel.GetUserNo(sUserID: string): string;
begin
  Result := '0';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT EMP_NO ' +
      'FROM   SAJET.SYS_EMP ' +
      'WHERE  EMP_ID = ' + sUserID;
    Open;
    Result := FieldByName('EMP_NO').AsString;
    Close;
  end;
end;

procedure TfPrintLabel.FormShow(Sender: TObject);
begin
  g_tsTitle := '';
  g_tsPrintLabel := '';
  La_GString.Caption := gsType;
  if UpdateUserID <> '0' then
    UpdateUserNo := GetUserNo(UpdateUserID);
  if (not GetTerminalID) or (not (GetCfgData)) then
  begin
    La_GString.Top := 166;
    editSN.Top := 162;
    editSN.Enabled := False;
    Image1.top := 166;
    exit;
  end;
  CheckShift;
  lablPartNo.Caption := '';
  LabCustPart.Caption := '';
  LabWorkorder.Caption := '';
  LabSN.Caption := '';
  Label1.Caption := g_tsPrintLabel;
  LabelPacking.Caption := g_tsPrintLabel;
  Label16.Caption := 'Label File Name:  ' + 'PL_Part No ' + ' /  ' + 'PL_DEFAULT';
  panlMessage.Caption := 'Please Input ' + gsType;
  panlMessage.Font.Color := clGreen;
  editWo.SelectAll;
  editWo.SetFocus;
end;

procedure TfPrintLabel.editSNKeyPress(Sender: TObject; var Key: Char);
var sPrintData: string;
begin
  lablPartNo.Caption := '';
  LabCustPart.Caption := '';
  LabWorkorder.Caption := '';
  LabSN.Caption := '';
  panlMessage.Caption := '';
  if not (key = #13) then exit;
  //Get Time
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT SYSDATE FROM DUAL ';
    OPEN;
    dtSysdate := FieldByName('SYSDATE').AsDateTime;
    close;
  end;
  if not CheckPassSN then
  begin
    panlMessage.Font.Color := clRed;
    Image1.Picture := im5.Picture;
    messageBeep(48);
  end else begin
    if gsType = 'Serial Number' then
    begin
      panlMessage.Caption := 'SN OK';
      panlMessage.Font.Color := clGreen;
    end
    else
    begin
      if g_tsPrintQty <> 0 then
      begin

        while not QryTemp.Eof do
        begin
          sPrintData := G_getPrintData(CodesoftVersion, 18, G_sockConnection, 'DspQryData', QryTemp.FieldByName('SERIAL_NUMBER').AsString, g_tsPrintQty, '');
          if assigned(G_onTransDataToApplication) then
            G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
          else
            showmessage('Not Defined Call Back Function for Code Soft');
          QryTemp.Next;
        end;
        panlMessage.Caption := 'Print OK';
        panlMessage.Font.Color := clGreen;
      end;
    end;
  end;
  EditSN.SelectAll;
  EditSN.SetFocus;
end;

function TfPrintLabel.CheckPassSN: Boolean;
var sRes, ssn: string;
begin
    Result := False;
    sRes := 'OK';
    if gsType = 'Serial Number' then
    begin
        //Check SN/CSN
        with SProc do
        begin
            try
              Close;
              DataRequest('SAJET.SJ_CKRT_SN_PSN');
              FetchParams;
              Params.ParamByName('TREV').AsString := EditSN.Text;
              Execute;
              sRes := Params.ParamByName('TRES').AsString;
              ssn := Params.ParamByName('PSN').AsString;
            except
            end;
            Close;
        end;
        if sRes <> 'OK' then
           panlMessage.Caption := sRes
        else
        begin
            labSN.Caption := ssn;
            with SProc do
            begin
                try
                    Close;
                    DataRequest('SAJET.SJ_CKRT_ROUTE');
                    FetchParams;
                    Params.ParamByName('TTERMINALID').AsString := TerminalID;
                    Params.ParamByName('TSN').AsString := ssn;
                    Execute;
                    sRes := Params.ParamByName('TRES').AsString;
                except
                end;
                Close;
            end;



             if sRes <> 'OK' then
                panlMessage.Caption := sRes
             else
             with qryTemp do
             begin
                  close;
                  params.Clear;
                  params.CreateParam(ftString, 'SN', ptInput);
                  CommandText := ' Select A.WORK_ORDER,B.PART_NO,B.CUST_PART_NO ' +
                    ' From SAJET.G_SN_STATUS A,SAJET.SYS_PART B,SAJET.G_WO_BASE C  ' +
                    ' where  A.SERIAL_NUMBER=:SN  AND A.MODEL_ID=B.PART_ID AND A.WORK_ORDER=C.WORK_ORDER AND  ' +
                    '         B.ENABLED=''Y'' AND ROWNUM=1 ';
                  Params.ParamByName('SN').AsString := ssn;
                  open;

                  if IsEmpty then
                    panlMessage.Caption := 'SN Error'
                  else
                  begin
                      panlMessage.Caption := 'Serial Number OK';
                      panlMessage.Font.Color := clGreen;
                      with SProc do
                      begin
                          try
                            Close;
                            DataRequest('SAJET.SJ_GO');
                            FetchParams;
                            Params.ParamByName('TTERMINALID').AsString := TerminalID;
                            Params.ParamByName('TSN').AsString := ssn;
                            Params.ParamByName('TNOW').AsDateTime := dtSysdate;
                            Params.ParamByName('TEMP').AsString := UpdateUserNo;
                            Execute;
                            sRes := Params.ParamByName('TRES').AsString;
                          except
                          end;
                          Close;
                      end;
                      if sRes <> 'OK' then
                        panlMessage.Caption := sRes;
                  end;
             end;
        end;
    end
    else
    begin
        with QryTemp do begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString,'Panel',ptInput);
            CommandText := 'select Serial_number from sajet.g_SN_status where Box_no = :panel and work_flag=0';
            Params.ParamByName('Panel').AsString := editSN.Text;
            Open;
        end;

        with SProc do
        begin
            try
                Close;
                DataRequest('SAJET.SJ_PANEL_WO_INPUT');
                FetchParams;
                Params.ParamByName('TWO').AsString := editwo.Text;
                Params.ParamByName('TTERMINALID').AsString := TerminalID;
                Params.ParamByName('TPANEL').AsString := EditSN.Text;
               // Params.ParamByName('TNOW').AsDateTime := dtSysdate;
                Params.ParamByName('TEMPID').AsString := UpdateUserNO;
                Params.ParamByName('TFLAGBOX').AsString := FlagBox;
                Execute;
                sRes := Params.ParamByName('TRES').AsString;
            except
            end;
            Close;
        end;
        if sRes <> 'OK' then
        begin
            panlMessage.Caption := sRes;
            panlMessage.Font.Color := clRed;
            QryTemp.Close;
            Exit;
        end;
        panlMessage.Caption := 'PANEL OK';
        panlMessage.Font.Color := clGreen;

    end;
    Result := (sRes = 'OK');
    if Result then
      Image1.Picture := im4.Picture;
end;

procedure TfPrintLabel.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

function TfPrintLabel.CheckShift: Boolean;
var sRes: string;
begin
  Result := False;
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PDLINE_SHIFT');
      FetchParams;
      Params.ParamByName('TTERMINALID').AsString := TerminalID;
      Execute;
      sRes := Params.ParamByName('TRES').AsString;
    except
    end;
    Close;
  end;
  with qryTemp do
  begin
    close;
    params.Clear;
    params.CreateParam(ftString, 'tlineid', ptInput);
    CommandText := ' select b.SHIFT_NAME  ' +
      ' from sajet.sys_pdline_shift_base a,sajet.SYS_SHIFT b ' +
      ' where a.pdline_id = :tlineid  and a.active_flag = ''Y'' and a.SHIFT_ID=b.SHIFT_ID and rownum=1  ';
    Params.ParamByName('tlineid').AsString := sLINDID;
    open;
    PanelShift.Caption := FieldByName('SHIFT_NAME').AsString;
    close;
  end;
  Result := True;
end;

function TfPrintLabel.GetCfgData: Boolean;
begin
  Result := False;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'SELECT * ' +
      'FROM SAJET.SYS_MODULE_PARAM ' +
      'WHERE MODULE_NAME = :MODULE_NAME AND ' +
      'FUNCTION_NAME = :FUNCTION_NAME AND ' +
      'PARAME_NAME = :TERMINALID ';
    Params.ParamByName('MODULE_NAME').AsString := 'PrintLabel';
    Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
    Params.ParamByName('TERMINALID').AsString := TerminalID;
    Open;
    if RecordCount <= 0 then
    begin
      Close;
      MessageDlg('Configuration not Exist !!', mtError, [mbCancel], 0);
      Exit;
    end;
    while not Eof do
    begin
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Label Qty' then
        g_tsPrintQty := StrToIntDef(Fieldbyname('PARAME_VALUE').AsString, 1);
      if Fieldbyname('PARAME_ITEM').AsString = 'CodeSoft' then
      begin
        if Fieldbyname('PARAME_VALUE').AsString = 'Version 4' then
          CodesoftVersion := 4
        else if Fieldbyname('PARAME_VALUE').AsString = 'Version 5' then
          CodesoftVersion := 5
        else
          CodesoftVersion := 6;
      end;

      if Fieldbyname('PARAME_ITEM').AsString = 'BoxFlag' then
         FlagBox:=Fieldbyname('PARAME_VALUE').AsString;
         
      Next;
    end;
    Close;
  end;
  Result := True;
end;

function TDBGrid.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  if not (datasource.DataSet.active) then EXIT;
  if WheelDelta > 0 then
    datasource.DataSet.Prior;
  if wheelDelta < 0 then
    DataSource.DataSet.Next;
  Result := True;
end;

procedure TfPrintLabel.editwoKeyPress(Sender: TObject; var Key: Char);
var sRes:string;
begin
   if Key <> #13 then Exit;
   with SProc do
   begin
        Close;
        DataRequest('SAJET.SJ_CHK_WO_INPUT');
        FetchParams;
        Params.ParamByName('TREV').AsString :=editwo.Text;
        Execute;

        sRes := Params.ParamByName('TRES').AsString;

        if sRes <> 'OK' then begin
            panlMessage.Font.Color :=clRed;
            panlMessage.Caption := sRes;
            Exit;
        end;

        panlMessage.Font.Color :=clGreen;
        panlMessage.Caption := 'WO:'+sRes;
        editSN.Enabled :=True;
        editSN.SetFocus;
        editSN.SelectAll;
        editwo.Enabled :=False;
   end;


end;

procedure TfPrintLabel.editwoChange(Sender: TObject);
begin
   editSN.Text :='';
   editSN.Enabled :=False;
end;

end.

