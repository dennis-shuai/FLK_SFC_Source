unit uRepair;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db, uData,
   DBClient, MConnect, SConnect, IniFiles, ImgList, ObjBrkr, Menus, Variants, uLang;

type
   TfRepair = class(TForm)
      Panel1: TPanel;
      ImageAll: TImage;
      LabelPacking: TLabel;
      Label1: TLabel;
      Image3: TImage;
      cmbSN: TComboBox;
      Label25: TLabel;
      Label3: TLabel;
      Label4: TLabel;
      Label6: TLabel;
      LVDefect: TListView;
      Label5: TLabel;
      LVReason: TListView;
      Image1: TImage;
      Image4: TImage;
      Image5: TImage;
      LabPN: TLabel;
      LabLine: TLabel;
      LabTerminal: TLabel;
      LabProcess: TLabel;
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
    dsrcDefect: TDataSource;
    qryData1: TClientDataSet;
    qryDetail: TClientDataSet;
    dsrcReason: TDataSource;
    sbtnAdd: TSpeedButton;
    sbtnDelete: TSpeedButton;
    sbtnRepair: TSpeedButton;
    Panel2: TPanel;
    sbtnFinish: TSpeedButton;
    Label7: TLabel;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    editRepairer: TEdit;
    sbtnRepairer: TSpeedButton;
    labRPName: TLabel;
    Label8: TLabel;
    Label11: TLabel;
    Label9: TLabel;
    Label2: TLabel;
    Label10: TLabel;
    Label16: TLabel;
      procedure sbtnCloseClick(Sender: TObject);
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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cmbSNSelect(Sender: TObject);
    procedure cmbSNCloseUp(Sender: TObject);
    procedure sbtnRepairerClick(Sender: TObject);
    procedure editRepairerChange(Sender: TObject);
    procedure editRepairerKeyPress(Sender: TObject; var Key: Char);
    procedure qryData1AfterScroll(DataSet: TDataSet);
   private
    { Private declarations }
      procedure ShowReasonHistory(DefectCode: string);
   public

      G_sPartSNID :String;
      G_sPartSN:String;
      UpdateUserID: string;
      LoginUserID: string;
      TerminalID,LineID, ProcessId,StageID: string;
      FcID: string;
      Authoritys, AuthorityRole: string;
      function GetTerminalID: Boolean;
      function InputSN: Boolean;
      function ShowDefect(sPartSNID:String): Boolean;
      function ShowReason(RECID: string): Boolean;
      procedure ClearData;
      procedure SetStatusbyAuthority;
      function showPartSN(sPartSN :String):Boolean;
      function ShowDefectHistory(sPartSN:String):Boolean;
      Function GetEmpNo(psUserID: String) : String;
      Function GetEmpName(psUserID: String) : String;
      Function GetEmpID(sEMPNO: String) : String;
      Procedure CheckEMPPRI(EmpNO: string ; Var sMSG , sEMPID,sEMP_NO ,sEMP_NAME : String);      
   end;

var
   //Language : TLanguage;
   fRepair: TfRepair;

implementation

uses  uFilter;
{$R *.DFM}

procedure TfRepair.SetStatusbyAuthority;
begin
  // Read Only,Allow To Change,Full Control
  try
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      CommandText := 'Select FUNCTION,AUTHORITYS ' +
         'From SAJET.SYS_EMP_PRIVILEGE ' +
         'Where EMP_ID = :EMP_ID and ' +
         'PROGRAM = :PRG ' ;

      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Repair';
      Open;
      If RecordCount > 0 Then
      begin
        sbtnScrap.Enabled := Locate('FUNCTION;AUTHORITYS',VarArrayOf(['Scrap','Allow To Execute']),[]);
        cmbSN.Enabled := Locate('FUNCTION;AUTHORITYS',VarArrayOf(['Execution','Allow To Execute']),[]);
      end;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      CommandText := 'Select FUNCTION,AUTHORITYS ' +
         'From SAJET.SYS_ROLE_PRIVILEGE A, ' +
         'SAJET.SYS_ROLE_EMP B ' +
         'Where A.ROLE_ID = B.ROLE_ID and ' +
         'EMP_ID = :EMP_ID and ' +
         'PROGRAM = :PRG ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Repair';
      Open;
      if not sbtnScrap.Enabled then
        sbtnScrap.Enabled := Locate('FUNCTION;AUTHORITYS',VarArrayOf(['Scrap','Allow To Execute']),[]);
      if not cmbSN.Enabled then
        cmbSN.Enabled := Locate('FUNCTION;AUTHORITYS',VarArrayOf(['Execution','Allow To Execute']),[]);
    end;
    sbtnAdd.Enabled := cmbSN.Enabled;
    AddDefect1.Enabled := cmbSN.Enabled;

    sbtnDelete.Enabled := cmbSN.Enabled;
    DeleteDfect1.Enabled := cmbSN.Enabled;

    sbtnRepair.Enabled := cmbSN.Enabled;
    RepairRecord1.Enabled := cmbSN.Enabled;

    sbtnFinish.Enabled := cmbSN.Enabled;
    Finish1.Enabled := cmbSN.Enabled;

    Scrap1.Enabled := sbtnScrap.Enabled;
  finally
    qrytemp.Close;
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
      CommandText := 'Select A.TERMINAL_NAME,B.PROCESS_NAME, a.PROCESS_ID ,a.Stage_ID,a.PDLINE_ID ' +
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
      StageID :=Fieldbyname('Stage_ID').AsString;
      LineID := Fieldbyname('PDLINE_ID').AsString;
      LabTerminal.Caption := Fieldbyname('PROCESS_NAME').AsString + ' ' +
         Fieldbyname('TERMINAL_NAME').AsString;
      Close;
   end;
   Result := True;
end;

function TfRepair.ShowDefect(sPartSNID:String): Boolean;
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PARENT_ID', ptInput);
      Params.CreateParam(ftString, 'PARENT_ID1', ptInput);
      commandText :=' SELECT C.DEFECT_CODE,C.DEFECT_DESC,A.RECID,A.PROCESS_ID '
                  +'       , NVL(B.RECID,''0'') RP_STATUS ,A.From_Repair '
                  + ' FROM '
                  +'  SAJET.G_KP_DEFECT_D A'
                  +' ,( SELECT B.RECID '
                  +'    FROM SAJET.G_KP_DEFECT_D B '
                  +'        ,SAJET.G_KP_REPAIR C '
                  +'    WHERE B.PARENT_ID = :PARENT_ID  '
                  +'      AND B.RECID = C.RECID '
                  +'   GROUP BY B.RECID ) B '
                  +' ,SAJET.SYS_DEFECT C '
                  +'  WHERE A.PARENT_ID = :PARENT_ID '
                  +'    AND A.DEFECT_ID = C.DEFECT_ID(+) '
                  +'    AND A.RECID = B.RECID(+) '
                  +' ORDER BY C.DEFECT_CODE ';
      Params.ParamByName('PARENT_ID').AsString := sPartSNID;
      Params.ParamByName('PARENT_ID').AsString := sPartSNID;
      Open;
      LVDefect.Items.Clear;
      while not Eof do
      begin
        with LVDefect.Items.Add do
        begin
           Caption := Fieldbyname('DEFECT_CODE').AsString;
           SubItems.Add(Fieldbyname('DEFECT_DESC').AsString);
           SubItems.Add(Fieldbyname('RECID').AsString);
           SubItems.Add(Fieldbyname('PROCESS_ID').AsString);
           IF  FieldByName('RP_STATUS').AsString ='0' then
             ImageIndex := 1
           else
             ImageIndex := 0;
           SubItems.Add(Fieldbyname('From_Repair').AsString);
        END;
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
    try
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      CommandText := 'Select B.REASON_CODE,B.REASON_DESC '
                    +' From  '
                    +'     SAJET.G_KP_REPAIR A '
                    +'    ,SAJET.SYS_REASON B '
                    +'  WHERE A.RECID =:RECID '
                    +'    AND A.REASON_ID = B.REASON_ID(+) '
                    +'  ORDER BY B.REASON_CODE ' ;
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

    finally
     Close;
    end;
  end;
   Result := True;
end;

function TfRepair.InputSN: Boolean;
begin
   G_sPartSN:='';
   result := False;
   qryData1.Close;
   qryDetail.close;
  // G_sPartSN:=cmbSN.Text;
  // 顯示 Defect Data
   showPartSN(cmbSN.Text);
   ShowDefect(G_sPartSNID);


  // 顯示 Reason Data
   if LVDefect.Items.Count>0 then
   begin
     LVDefect.SetFocus;
     LVDefect.items[0].Selected :=True;
     LVDefect.OnClick(self);
   end;
   ShowDefectHistory(G_sPartSN);
   result := True;
end;

procedure TfRepair.ClearData;
begin

   LabPN.Caption := '';
   LabLine.Caption := '';
   LabTerminal.Caption := '';
   LabProcess.Caption := '';
   LVDefect.Items.Clear;
   LVReason.Items.Clear;
   cmbSN.Text := '';
   G_sPartSN := '';
    qryData1.Close;
    qryDetail.Close;
   if cmbSN.Items.Count > 0 then
      sbtnFailSN.OnClick(Self);
end;

procedure TfRepair.sbtnCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TfRepair.sbtnFailSNClick(Sender: TObject);
begin
  if ProcessID <> '' then
  begin
    cmbSN.Items.Clear;
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'SELECT A.PART_SN   '
         + 'FROM SAJET.G_KP_DEFECT_H  A,SAJET.G_SN_REPAIR_REPLACE_KP B '
         +' WHERE A.RP_STATUS IS NULL '
         +' AND A.PART_SN = B.OLD_PART_SN '
         +' AND A.REC_TIME = B.REPLACE_TIME '
         +' AND B.FLAG =''Y'' '
         +' ORDER BY A.PART_SN  ';
      Open;
      while not Eof do
      begin
         cmbSN.Items.Add(Fieldbyname('PART_SN').AsString);
         Next;
      end;
      Close;
    end;
  end;  
end;

procedure TfRepair.FormShow(Sender: TObject);
var
  I : Integer;
begin
   // add by MultiLanguage
  {Language := TLanguage.Create(Self);
  Language.GetLanguage(QryTemp);
  with TInifile.Create('.\SFIS.INI') do
  begin
    Language.TransToLanguage := ReadString('SYSTEM','LANGUAGE','English');
    Free;
  end;
  Language.Translation(fRepair);
  Language.CurrentLanguage := Language.TransToLanguage;
  // add by MultiLanguage end
  // ======================== }
  //for I := 0 to 2 do
  //  LVDefect.Columns[I].Caption := Language.TranslationText(LVDefect.Columns[I].Caption);
  //for I := 0 to 3 do
  //  LVReason.Columns[I].Caption := Language.TranslationText(LVReason.Columns[I].Caption);
  //for I := 0 to 2 do
  //  DBGrid1.Columns[I].Title.Caption := Language.TranslationText(DBGrid1.Columns[I].Title.Caption);
  //for I := 0 to 1 do
  //  DBGrid2.Columns[I].Title.Caption := Language.TranslationText(DBGrid2.Columns[I].Title.Caption);
  //AddDefect1.Caption := Language.TranslationText(AddDefect1.Caption);
  //DeleteDfect1.Caption := Language.TranslationText(DeleteDfect1.Caption);
  //RepairRecord1.Caption := Language.TranslationText(RepairRecord1.Caption);
  //Scrap1.Caption := Language.TranslationText(Scrap1.Caption);
  //Finish1.Caption := Language.TranslationText(Finish1.Caption);
  // ========================


   if not GetTerminalID then // 讀取本站 ID
   begin
     cmbSN.Enabled := False;
   end;
   ClearData;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'select param_value from sajet.sys_base '
                   + 'Where param_name = ''Repair Search'' and param_value = ''1'' ';
      Open;
      if RecordCount <> 0 then
      begin
         sbtnFailSN.Visible := True;
         cmbSN.Style := csDropDown;
      end
      else
         cmbSN.Style := csSimple;
   end;
   G_sPartSN := '';
   if UpdateUserID <> '0' then
   begin
      LoginUserID := UpdateUserID;
      editRepairer.Text := GetEmpNo(UpdateUserID);
      labRPName.Caption := GetEmpName(UpdateUserID);
      SetStatusbyAuthority;
   end;
end;

procedure TfRepair.sbtnScrapClick(Sender: TObject);
begin
   if G_sPartSN = '' then Exit;

   if MessageDlg('Scrap this Part SN: "'+G_sPartSN+'" ?',mtConfirmation,[mbYes,mbCancel],0) <> mrYes then
     exit;
   with qryTemp do
   begin
     try
       close;
       Params.Clear;
       Params.CreateParam(ftString, 'PART_SN', ptInput);
       commandText :=' Update Sajet.G_SN_REPAIR_REPLACE_KP '
                    +'    SET Flag=''S'' '
                    +'  WHERE OLD_PART_SN =:PART_SN ';
       Params.ParamByName('PART_SN').AsString := G_sPartSN;
       Execute;
     finally
       Close;
     end;
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
      CommandText := 'Select D.REASON_CODE,D.REASON_DESC,D.ENABLED,Count(REASON_CODE) CNT ' +
                     'From SAJET.G_KP_DEFECT_D A,' +
                     'SAJET.G_KP_REPAIR B,' +
                     'SAJET.SYS_DEFECT C,' +
                     'SAJET.SYS_REASON D ' +
                     'Where A.RECID = B.RECID  ' +
                     ' AND A.DEFECT_ID = C.DEFECT_ID  ' +
                     ' AND C.DEFECT_CODE = :DEFECTCODE  ' +
                     ' AND B.REASON_ID = D.REASON_ID ' +
                     'Group By D.REASON_CODE,D.REASON_DESC,D.ENABLED ' +
                     'Order By CNT DESC ';
      Params.ParamByName('DEFECTCODE').AsString := DefectCode;
      Open;
   end;
end;

procedure TfRepair.sbtnRepairClick(Sender: TObject);
begin
   if G_sPartSN = '' then Exit;
   if LVDefect.Selected = nil then Exit;

    fData := TfData.Create(self);
    fData.LabDefectCode.Caption := LVDefect.Selected.Caption;
    fData.LabDefectDesc.Caption := LVDefect.Selected.SubItems[0];
    fData.RecID := LVDefect.Selected.SubItems[1];
    ShowReasonHistory(LVDefect.Selected.Caption);
    fData.DataSource1.DataSet := QryData;
    if fData.ShowModal = mrOK then
    begin
       LVDefect.Selected.ImageIndex := 0;
       ShowReason(fData.RecID);
    end;
    QryData.Close;
   fData.Free;
end;

procedure TfRepair.cmbSNKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then
   begin
      With QryTemp Do
      Begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'KPSN',PtInput);
        CommandText := 'Select Flag From SAJET.G_SN_REPAIR_REPLACE_KP '
                     + 'Where OLD_PART_SN = :KPSN '
                     + ' AND FLAG =''Y'' ';
        PArams.ParamByName('KPSN').AsString := cmbSN.Text;
        Open;
        IF Eof Then
        begin
          MessageDlg('KPSN Error !!', mtError, [mbCancel], 0);
          Close;
          Exit;
        end;
      End;

      if not InputSN then
      begin
        cmbSN.SetFocus;
        cmbSN.SelectAll;
      end;
   end
   else
   begin
      cmbSNChange(Self);
   end;
end;

procedure TfRepair.sbtnAddClick(Sender: TObject);
var S,sDefectDesc,sDefectID: string; B: Boolean; I: Integer;
    sDefectData,sSUBRecID:String;
begin
   if G_sPartSN = '' then Exit;

   S := InputBox('Append Defect', 'Defect Code', '');
   if S = '' then Exit;

   with QryTemp do
   begin
     try
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'DEFECT', ptInput);
        CommandText := 'Select DEFECT_ID,DEFECT_CODE,DEFECT_DESC,Enabled ' +
                       'From SAJET.SYS_DEFECT ' +
                       'Where DEFECT_CODE = :DEFECT ';
        Params.ParamByName('DEFECT').AsString := S;
        Open;
        if RecordCount = 0 then
        begin
          MessageDlg('Defect Code error !!' + #13#10 +
                      'Defect Code : ' + S, mtError, [mbCancel], 0);
           Exit;
        end;
        IF FieldByName('Enabled').AsString = 'N' Then
        begin
          MessageDlg('Defect Code Disable !!' + #13#10 +
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
        sDefectDesc := Fieldbyname('DEFECT_DESC').AsString;
        sDefectID := Fieldbyname('DEFECT_ID').AsString;
     finally
       Close;
     end;
   end;
   sDefectData := S+'@'+'N/A'+'@';

   with QryTemp do
   begin
     try
        try
           Close;
           Params.Clear;
           CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || TO_CHAR(SYSDATE,''YYMMDD'') || LPAD(SAJET.S_KP_DEFECT.NEXTVAL,5,''0'') REC ' +
                          'From SAJET.SYS_BASE ' +
                          'Where PARAM_NAME = ''DBID'' ';
           Open;
           sSUBRecID := FieldByName('REC').AsString;
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'PARENT_ID', ptInput);
           Params.CreateParam(ftString	,'RECID', ptInput);
           Params.CreateParam(ftString	,'DEFECT_ID', ptInput);
           Params.CreateParam(ftString	,'PROCESS_ID', ptInput);
           Params.CreateParam(ftString	,'TEST_EMP_ID', ptInput);
           CommandText := 'INSERT INTO SAJET.G_KP_DEFECT_D '
                        + '(PARENT_ID,RECID,DEFECT_ID,PROCESS_ID,FROM_REPAIR ,TEST_EMP_ID) '
                        + 'VALUES '
                        + '(:PARENT_ID,:RECID,:DEFECT_ID,:PROCESS_ID,''N'' ,:TEST_EMP_ID) ';
           Params.ParamByName('PARENT_ID').AsString := G_sPartSNID;
           Params.ParamByName('RECID').AsString := sSUBRecID;
           Params.ParamByName('DEFECT_ID').AsString := sDefectID;
           Params.ParamByName('PROCESS_ID').AsString := ProcessId;
           Params.ParamByName('TEST_EMP_ID').AsString := UpdateUserID;
           Execute;
           Close;
           showDefect(G_sPartSNID);
        except
          on E: Exception do
          begin
            MessageDlg('Insert SAJET.G_KP_DEFECT_D Exception:'+E.Message,mtWarning,[mbOK],0);
            exit;
          end;
        end;
     finally
        close;
     end;
   end;
end;

procedure TfRepair.sbtnDeleteClick(Sender: TObject);
begin
   if G_sPartSN = '' then Exit;
   if LVDefect.Selected = nil then Exit;
   if LVDefect.Selected.SubItems[3] = 'N' then
   begin
      // Delete DB
      IF MessageDlg('Delete This Defect Code : ' + LVDefect.Selected.Caption+' ? ',mtConfirmation,[mbYes,mbNo],0)<>mrYes then exit;
      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'RECID',ptInput);
        CommandText :='DELETE SAJET.G_KP_DEFECT_D '
                     +'WHERE RECID = :RECID ';
        Params.ParamByName('RECID').AsString := LVDefect.Selected.SubItems[1];
        Execute;
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'RECID',ptInput);
        CommandText :='DELETE SAJET.G_KP_REPAIR '
                     +'WHERE RECID = :RECID ';
        Params.ParamByName('RECID').AsString := LVDefect.Selected.SubItems[1];
        Execute;
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'RECID',ptInput);
        CommandText :='DELETE SAJET.G_KP_REPAIR_REMARK '
                     +'WHERE RECID = :RECID ';
        Params.ParamByName('RECID').AsString := LVDefect.Selected.SubItems[1];
        Execute;
        Close;
        {*try
          Close;
          DataRequest('SAJET.ICP_KP_DEFECT_DEL');
          FetchParams;
          Params.ParamByName('TRECID').AsString :=
          Execute;
          if Params.ParamByName('TRES').AsString<>'OK' then
            MessageDlg(params.ParamByName('TRES').AsString,mtWarning,[mbOK],0);
        finally
          Close;
        end;*}
      end;
      // Delete LVDefect;
      LVDefect.Selected.Delete;
      LVReason.Items.Clear;
   end;
end;

procedure TfRepair.LVDefectClick(Sender: TObject);
begin
   if LVDefect.Selected = nil then Exit;
   ShowReason(LVDefect.Selected.SubItems[1]);
end;

procedure TfRepair.sbtnFinishClick(Sender: TObject);
var I: Integer; B: Boolean; sRes : string;
begin
   if G_sPartSN = '' then Exit;

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


   try
     with QryTemp do
     begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'EMPID',ptInput);
       Params.CreateParam(ftString,'RP_PDLINE_ID',ptInput);
       Params.CreateParam(ftString,'RP_STAGE_ID',ptInput);
       Params.CreateParam(ftString,'RP_STAGE_ID',ptInput);
       Params.CreateParam(ftString,'RP_PROCESS_ID',ptInput);
       Params.CreateParam(ftString,'RP_TERMINAL_ID',ptInput);

       CommandText := 'UPDATE SAJET.G_KP_DEFECT_H '
                    + 'SET RP_STATUS=''0'' '
                    + ', RP_EMP_ID = :EMPID '
                    + ',RP_FINISH_TIME = SYSDATE '
                    + ',RP_PDLINE_ID = :RP_PDLINE_ID '
                    + ' ,RP_STAGE_ID =	 :RP_STAGE_ID '
                    + ' ,RP_PROCESS_ID = :RP_PROCESS_ID '
                    + '  ,RP_TERMINAL_ID= :RP_TERMINAL_ID '
                    + ' WHERE PART_SN = :KPSN '
                    + 'AND RP_STATUS IS NULL ';
       Params.ParamByName('EMPID').asString := UpdateUserID ;
       Params.ParamByName('RP_PDLINE_ID').asString := LineID ;
       Params.ParamByName('RP_STAGE_ID').asString := StageID ;
       Params.ParamByName('RP_PROCESS_ID').asString := ProcessId ;
       Params.ParamByName('RP_TERMINAL_ID').asString := TerminalID ;
       Params.ParamByName('KPSN').asString := G_sPartSN ;
       Execute;
       Close;

       Params.Clear;
       Params.CreateParam(ftString,'KPSN',ptInput);
       CommandText := 'UPDATE SAJET.G_SN_REPAIR_REPLACE_KP '
                    + 'SET Flag=''N'' '
                    + 'WHERE OLD_PART_SN = :KPSN '
                    + 'AND FLAG = ''Y'' ';
       Params.ParamByName('KPSN').asString := G_sPartSN ;
       Execute;
       Close;


     end;
   finally
     ClearData;
   end;
end;

procedure TfRepair.cmbSNChange(Sender: TObject);
begin
   LabPN.Caption := '';
   LabLine.Caption := '';
   LabTerminal.Caption := '';
   LabProcess.Caption := '';
   LVDefect.Items.Clear;
   LVReason.Items.Clear;
    qryData1.Close;
    qryDetail.Close;
   G_sPartSN := '';
end;

function TfRepair.showPartSN(sPartSN:String):Boolean;
begin
  result := false;
  with qryTemp do
  begin
    try
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PART_SN', ptInput);
      commandText :=' SELECT A.RECID,B.TERMINAL_NAME,C.PROCESS_NAME,D.PDLINE_NAME   '
                  +'        ,PART.PART_NO '
                  +' FROM SAJET.G_KP_DEFECT_H A '
                  +' ,SAJET.SYS_PART PART '
                  +' ,SAJET.SYS_TERMINAL B '
                  +' ,SAJET.SYS_PROCESS C '
                  +' ,SAJET.SYS_PDLINE D '

                  +' WHERE A.PART_SN = :PART_SN '
                  +'   AND A.RP_STATUS IS NULL '
                  +'   AND A.PART_ID = PART.PART_ID(+) '
                  +'   AND A.PDLINE_ID = D.PDLINE_ID(+) '
                  +'   AND A.PROCESS_ID = C.PROCESS_ID(+) '
                  +'   AND A.TERMINAL_ID = B.TERMINAL_ID(+) ';
      Params.ParamByName('PART_SN').AsString := sPartSN;
      Open;
      IF not eof then
      begin
         G_sPartSN:=cmbSN.Text ;
         G_sPartSNID := FieldByName('RECID').AsString;
         LabLine.Caption := Fieldbyname('PDLINE_NAME').AsString;
         LabTerminal.Caption := Fieldbyname('TERMINAL_NAME').AsString;
         LabProcess.Caption := Fieldbyname('PROCESS_NAME').AsString;
         LabPN.Caption := Fieldbyname('PART_NO').AsString;
      end;
      result := true;
    finally
      Close;
    end;
   end;
end;

function TfRepair.showDefectHistory(sPartSN:String):Boolean;
Var s:String;
begin
  result := false;
  with qryData1 do
  begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
      commandText :=' Select D.RECID,B.PROCESS_NAME,A.DEFECT_CODE,A.DEFECT_DESC,REC_TIME '
                  +' From SAJET.G_KP_DEFECT_H H, '
                  +'      SAJET.G_KP_DEFECT_D D, '
                  +'      SAJET.SYS_DEFECT A, '
                  +'      SAJET.SYS_PROCESS B '
                  +'WHERE PART_SN =:SERIAL_NUMBER '
                  +'AND RP_STATUS =''0'' '
                  +'AND H.RECID = D.PARENT_ID '
                  +'AND D.DEFECT_ID = A.DEFECT_ID(+) '
                  +'AND D.PROCESS_ID = B.PROCESS_ID(+) ';
      Params.ParamByName('SERIAL_NUMBER').AsString := sPartSN;
      Open;
  end;
  {with qryDetail do
  begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'RECID', ptInput);
        commandText :='SELECT A.RECID,B.EMP_NO "repairer",C.REASON_CODE,C.REASON_DESC,Repair_Time '
                     +'FROM SAJET.G_KP_REPAIR A, '
                     +'SAJET.SYS_EMP B, '
                     +'SAJET.SYS_REASON C  '
                     +'WHERE A.RECID =:RECID '
                     +'AND A.REPAIR_EMP_ID = B.EMP_ID(+) '
                     +'AND A.REASON_ID = C.REASON_ID(+) '
                     +'ORDER BY B.EMP_NO,C.REASON_CODE ';
        Open;
   end; }
   qryData1.First;
end;  

procedure TfRepair.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //Language.Free;
end;

procedure TfRepair.cmbSNSelect(Sender: TObject);
var sKey:Char;
begin
//  sKey:=#13;
 // cmbSN.OnKeyPress(self,sKey);
end;
procedure TfRepair.cmbSNCloseUp(Sender: TObject);
var sKey:Char;
begin
  cmbSN.Text := cmbSN.Items.Strings[cmbSN.ItemIndex];
  if cmbSN.Text = '' tHEN Exit;
  sKey:=#13;
  cmbSN.OnKeyPress(self,sKey);
end;

function TfRepair.GetEmpID(sEMPNO: String): String;
begin
   Result := '0';
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select EMP_Name '
                   + '  From SAJET.SYS_EMP '
                   + ' Where EMP_NO = ' + sEMPNO ;
      Open;
      Result := FieldByName('EMP_ID').AsString;
      Close;
   end;
end;

function TfRepair.GetEmpName(psUserID: String): String;
begin
   Result := '0';

   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select EMP_Name '
                   + '  From SAJET.SYS_EMP '
                   + ' Where EMP_ID = ' + psUserID ;
      Open;
      Result := FieldByName('EMP_Name').AsString;
      Close;
   end;
end;

function TfRepair.GetEmpNo(psUserID: String): String;
begin
   Result := '0';

   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select EMP_NO '
                   + '  From SAJET.SYS_EMP '
                   + ' Where EMP_ID = ' + psUserID ;
      Open;
      Result := FieldByName('Emp_No').AsString;
      Close;
   end;
end;

procedure TfRepair.sbtnRepairerClick(Sender: TObject);
var K:Char;
begin
   with TfFilter.Create(Self) do
   begin
      with QryData do
      begin
        RemoteServer:=fRepair.QryData.RemoteServer;
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
         K := #13;
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

      sbtnScrap.Enabled := sbtnAdd.Enabled;
      Scrap1.Enabled := sbtnAdd.Enabled;
end;

procedure TfRepair.editRepairerKeyPress(Sender: TObject; var Key: Char);
Var
  sTemp : String;
  sEMPID , sEMPNO , sEMPNAME : String;
begin
    IF (Key = #13) Then
    begin
        // 過濾
        editRepairer.text := Trim(editRepairer.text);
        // If repairer 空白 則自動帶出login user
        IF editRepairer.text = '' Then
        begin
           UpdateUserID := LoginUserID;
           editRepairer.Text := GetEmpNo(UpdateUserID);
           labRPName.caption := GetEmpName(UpdateUserID);
           if UpdateUserID <> '0' then
              SetStatusbyAuthority;
           IF CmbSN.Enabled Then
              CmbSN.SetFocus;
           Exit;
        end
        else
        begin
           CheckEMPPRI(editRepairer.text,sTemp,sEMPID,sEMPNO,sEMPNAME);
           IF sTemp <> 'OK' Then
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
           IF CmbSN.Enabled Then
              CmbSN.SetFocus;
        end;
    end;
end;


procedure TfRepair.CheckEMPPRI(EmpNO: string; var sMSG, sEMPID, sEMP_NO,
  sEMP_NAME: String);
begin
   sMSG := '';
   sEMPID := '0';
   sEMP_NO := '0';
   sEMP_NAME := '0';
   with QryTemp do
   begin
      Close;
      Params.Clear;
      params.CreateParam(ftString,'EMP_NO',ptInput);
        CommandText := '  SELECT B.EMP_NO,B.EMP_NAME,B.EMP_ID,B.ENABLED '
                     + '  FROM SAJET.SYS_EMP B '
                     + '  WHERE EMP_NO Like :EMP_NO ';
      Params.ParamByName('EMP_NO').AsString := EmpNO;
      Open;
      IF EOF Then
         sMSG := 'EMP('+EmpNO+') NOT FOUND!'
      else iF  FieldByName('ENabled').AsString <> 'Y' Then
         sMSG := 'EMP('+EmpNO+') Disable!';
      IF sMSG <> '' Then Exit;
      sMSG := 'OK';
      sEMPID := FieldByName('EMP_ID').AsString;
      sEMP_NO := FieldByName('EMP_NO').AsString;
      sEMP_NAME := FieldByName('EMP_NAME').AsString;
      Close;
   end;
end;


procedure TfRepair.qryData1AfterScroll(DataSet: TDataSet);
begin
  with qryDetail do
  begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'RECID', ptInput);
        commandText :='SELECT A.RECID,B.EMP_NO "repairer",C.REASON_CODE,C.REASON_DESC,Repair_Time '
                     +'FROM SAJET.G_KP_REPAIR A, '
                     +'SAJET.SYS_EMP B, '
                     +'SAJET.SYS_REASON C  '
                     +'WHERE A.RECID =:RECID '
                     +'AND A.REPAIR_EMP_ID = B.EMP_ID(+) '
                     +'AND A.REASON_ID = C.REASON_ID(+) '
                     +'ORDER BY B.EMP_NO,C.REASON_CODE ';
        Params.ParamByName('RECID').AsSTring := QryData1.FieldByName('RECID').AsString;
        Open;
   end;
end;

end.

