unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, Db, DBClient, ComObj,
  MConnect, SConnect, ComCtrls, ObjBrkr, ImgList, Menus, CheckLst,
  ShellCtrls, IniFiles, DBTables;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    Label9: TLabel;
    Label3: TLabel;
    imageAll: TImage;
    Label35: TLabel;
    Label1: TLabel;
    combMachine: TComboBox;
    DataSource2: TDataSource;
    lablMachineDesc: TLabel;
    Label4: TLabel;
    combLine: TComboBox;
    Label5: TLabel;
    editPartNo: TEdit;
    sbtnFilter: TSpeedButton;
    Panel2: TPanel;
    Splitter1: TSplitter;
    ShellTreeView1: TShellTreeView;
    ShellListView1: TShellListView;
    ShellComboBox1: TShellComboBox;
    sbtnPath: TSpeedButton;
    sbtnExecl: TSpeedButton;
    Image4: TImage;
    combSide: TComboBox;
    QryData: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    QryData1: TClientDataSet;
    DataSource3: TDataSource;
    Shape1: TShape;
    Label2: TLabel;
    combType: TComboBox;
    Label6: TLabel;
    combVersion: TComboBox;
    procedure sbtnExeclClick(Sender: TObject);
    procedure ShellListView1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure combMachineChange(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure sbtnPathClick(Sender: TObject);
    procedure sbtnFilterClick(Sender: TObject);
    procedure editPartNoKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure combTypeChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    sPath, UpdateUserID: string;
    slMachineDesc, slMachineId, slPdLineID, slTypeID: TStringList;
    G_iRow: Integer;
    gbMulti: Boolean;
    procedure GetPartVersion;
  end;

var
  fDetail: TfDetail;
function MSLFileTransfer(iType: integer; sFileName: string): string; stdcall; external 'MSLFiledll.dll';

implementation

uses uMain, uFilter;

{$R *.DFM}

procedure TfDetail.sbtnExeclClick(Sender: TObject);
  function CheckModelExist(sItem: string; var sPartID: string): Boolean;
  begin
    Result := False;
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PART_NO', ptInput);
      CommandText := 'Select part_id '
        + ' From  sajet.sys_part '
        + ' Where part_no = :part_no '
        + '  and rownum = 1 ';
      Params.ParamByName('part_no').AsString := sItem;
      Open;
      if not eof then
      begin
        sPartID := FieldByName('part_id').AsString;
        Result := true;
      end;
      Close;
    end;
  end;
  function GetMaxMSL: string;
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'Select NVL(Max(MSL_No),0) + 1 MSL '
        + 'From SMT.Sys_MSL';
      Open;
      if Fieldbyname('MSL').AsString = '1' then
      begin
        Close;
        Params.Clear;
        CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || ''000001'' MSL '
          + 'From SAJET.SYS_BASE '
          + 'Where PARAM_NAME = ''DBID'' ';
        Open;
      end;
      Result := Fieldbyname('MSL').AsString;
      Close;
    end;
  end;
  function GetMaxPartID: string;
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'Select NVL(Max(PART_ID),0) + 1 PARTID '
        + 'From sajet.SYS_PART';
      Open;
      if Fieldbyname('PARTID').AsString = '1' then
      begin
        Close;
        Params.Clear;
        CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || ''000001'' PARTID '
          + 'From SAJET.SYS_BASE '
          + 'Where PARAM_NAME = ''DBID'' ';
        Open;
      end;
      Result := Fieldbyname('PARTID').AsString;
      Close;
    end;
  end;
  function InsertPart(sItem, sItemSpec, sItemSpec2: string): string;
  var sPartId: string; i: Integer;
  begin
    sPartId := '';
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PART_NO', ptInput);
      CommandText := 'Select PART_Id ' +
        'From SAJET.SYS_PART ' +
        'Where PART_NO = :PART_NO ' +
        'and rownum = 1 ';
      Params.ParamByName('PART_NO').AsString := sItem;

      Open;
      if RecordCount > 0 then
      begin
        sPartId := FieldByName('Part_Id').AsString;
        Close;
      end
      else
      begin
        I := 0;
        sPartId := '';
        while True do
        begin
          try
            sPartId := GetMaxPartID;
            Break;
          except
            Inc(I); // try 10 次, 若抓不到, 則跳離開來
            if I >= 10 then
              Break;
          end;
        end;
        if sPartId = '' then
        begin
          MessageDlg('Database Error !!' + #13#10 +
            'could not get Part Id !!', mtError, [mbCancel], 0);
          Exit;
        end;
        try
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'PART_ID', ptInput);
          Params.CreateParam(ftString, 'PART_NO', ptInput);
          Params.CreateParam(ftString, 'Spec1', ptInput);
          Params.CreateParam(ftString, 'Spec2', ptInput);
          CommandText := 'Insert Into SAJET.SYS_PART '
            + ' (Part_ID, PART_NO, Spec1 ,Spec2) '
            + ' Values  '
            + '(:Part_ID, :PART_NO, :Spec1 ,:Spec2) ';
          Params.ParamByName('PART_ID').AsString := sPartId;
          Params.ParamByName('PART_NO').AsString := Trim(sItem);
          Params.ParamByName('Spec1').AsString := Trim(sItemSpec);
          Params.ParamByName('Spec2').AsString := Trim(sItemSpec2);
          Execute;
          Close;
        except
          on E: Exception do
          begin
            MessageDlg('Save to SYS_PART Error !!' + #13#10 +
              E.Message, mtError, [mbCancel], 0);
            exit;
          end;
        end;
      end;
      Result := sPartId;
    end;
  end;
  procedure InsertMSL(sMSL, sMachineCode, sStationNo, sSubPartId, sLocation, sQty, sFedder: string);
  begin
    with QryTemp do
    begin
        // Insert MSL
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'MSL_NO', ptInput);
      Params.CreateParam(ftString, 'MACHINE_ID', ptInput);
      Params.CreateParam(ftString, 'STATION_NO', ptInput);
      Params.CreateParam(ftString, 'ITEM_PART_Id', ptInput);
      Params.CreateParam(ftString, 'ITEM_COUNT', ptInput);
      Params.CreateParam(ftString, 'FEDDER', ptInput);
      Params.CreateParam(ftString, 'LOCATION', ptInput);
      CommandText := 'Insert Into SMT.SYS_MSL_DETAIL '
        + '(MSL_NO,MACHINE_ID,STATION_NO,ITEM_PART_Id,ITEM_COUNT,FEDDER,LOCATION) '
        + 'Values (:MSL_NO,:MACHINE_ID,:STATION_NO,:ITEM_PART_Id,:ITEM_COUNT,:FEDDER,:LOCATION) ';
      Params.ParamByName('MSL_NO').AsString := sMSL;
      Params.ParamByName('STATION_NO').AsString := sStationNo;
      Params.ParamByName('ITEM_PART_Id').AsString := sSubPartID;
      Params.ParamByName('ITEM_COUNT').AsString := sQty;
      Params.ParamByName('FEDDER').AsString := sFEDDER;
      Params.ParamByName('LOCATION').AsString := sLocation;
      Execute;
      Close;
    end;
  end;
  procedure InsertSubItem(sMSL, sPartID, sItemPartID: string);
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'MSL_NO', ptInput);
      Params.CreateParam(ftString, 'ITEM_PART_Id', ptInput);
      Params.CreateParam(ftString, 'SUB_PART_Id', ptInput);
      CommandText := 'Select * from SMT.SYS_MSL_SUB '
        + 'Where MSL_NO = :MSL_NO '
        + 'and ITEM_PART_Id=:ITEM_PART_Id '
        + 'and SUB_PART_Id=:SUB_PART_Id ';
      Params.ParamByName('MSL_NO').AsString := sMSL;
      Params.ParamByName('ITEM_PART_Id').AsString := sPartID;
      Params.ParamByName('SUB_PART_Id').AsString := sItemPartID;
      Open;
      if IsEmpty then
      begin
          // Insert MSL
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'MSL_NO', ptInput);
        Params.CreateParam(ftString, 'ITEM_PART_Id', ptInput);
        Params.CreateParam(ftString, 'SUB_PART_Id', ptInput);
        CommandText := 'Insert Into SMT.SYS_MSL_SUB '
          + '(MSL_NO,ITEM_PART_Id,SUB_PART_Id ) '
          + 'Values (:MSL_NO,:ITEM_PART_Id,:SUB_PART_Id) ';
        Params.ParamByName('MSL_NO').AsString := sMSL;
        Params.ParamByName('ITEM_PART_Id').AsString := sPartID;
        Params.ParamByName('SUB_PART_Id').AsString := sItemPartID;
        Execute;
      end;
      close;
    end;
  end;
var sExcelFile, sFileTemp: string;  iTemp, iRow, iTotal, i: Integer; bError: Boolean;
  sQty, sPart, sPDLineID, sSubPartID, sSpec, sSpec2, sVer: string;
  sLocation, sAllLocation, sItem, sMachineCode, sStationNo: string;
  sMessage, ms, sMSL, sTemp, sTempPartID, sFedder: string;
  sPartNo, sMachine, sSide: string;
  iQty: Real; iStart, iIndex, iLength: integer; vFile: Textfile; PIni: TIniFile;
begin
  editPartNo.Text := trim(editPartNo.Text);
  if combLine.ItemIndex = -1 then
  begin
    MessageDlg('Please Select Line !', mtError, [mbOK], 0);
    Exit;
  end;

  if (not CheckModelExist(editPartNo.Text, sPart)) and (editPartNo.Enabled) then
  begin
    MessageDlg('Part Error !', mtError, [mbOK], 0);
    editPartNo.SetFocus;
    Exit;
  end;
  if ShellListView1.SelCount <> 1 then
  begin
    MessageDlg('File not Select', mtError, [mbOK], 0);
    exit;
  end;
  sExcelFile := ShellListView1.SelectedFolder.PathName;
  sPDLineID := slPdLineID[combLine.ItemIndex];
//  sMachineCode := slMachineID[combMachine.ItemIndex];
  sMSL := '';
  sMessage := MSLFileTransfer(StrToInt(slTypeId[combType.Items.IndexOf(combType.Text)]), sExcelFile);
  if sMessage <> 'OK' then
  begin
    MessageDlg(sMessage, mtError, [mbOK], 0);
    Exit;
  end;
  iTotal := 1;
  if gbMulti then begin
    PIni := TIniFile.Create(ChangeFileExt(sExcelFile, '.ini'));
    iTotal := PIni.ReadInteger('TotalPage', 'Count', 1);
    PIni.Free;
  end;
  for i := 1 to iTotal do
  begin
    if gbMulti then begin
      sFileTemp := ChangeFileExt(sExcelFile, '-' + FormatFloat('00', i) + '.msl');
      PIni := TIniFile.Create(ChangeFileExt(sExcelFile, '.ini'));
      sPartNo := PIni.ReadString(IntToStr(i), 'Part', '');
      sVer := PIni.ReadString(IntToStr(i), 'Version', 'N/A');
      sMachine := PIni.ReadString(IntToStr(i), 'Machine', '');
      combMachine.ItemIndex := combMachine.Items.IndexOf(sMachine);
      if combMachine.ItemIndex = -1 then
      begin
        MessageDlg('Machine: ' + sMachine + ' Error!', mtError, [mbOK], 0);
        bError := True;
        break;
      end;
      sMachineCode := slMachineID[combMachine.ItemIndex];
      sSide := PIni.ReadString(IntToStr(i), 'Side', '');
      combSide.ItemIndex := combSide.Items.IndexOf(sSide);
      PIni.Free;
      if not CheckModelExist(sPartNo, sPart) then
      begin
        MessageDlg('Part No: ' + sPartNo + ' Error!', mtError, [mbOK], 0);
        bError := True;
        break;
      end;
    end else
      sFileTemp := ChangeFileExt(sExcelFile, '.msl');
    editPartNO.Text := sPartNo;
//    sExcelFile := sFileTemp;
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'pdline', ptInput);
      Params.CreateParam(ftString, 'part', ptInput);
      Params.CreateParam(ftString, 'Version', ptInput);
      Params.CreateParam(ftString, 'machine', ptInput);
      Params.CreateParam(ftString, 'side', ptInput);
      CommandText := 'Select MSL_NO '
        + 'From SMT.SYS_MSL '
        + 'Where pdline_id = :pdline '
        + 'and part_id = :part '
        + 'and version = :version '
        + 'and machine_id = :machine '
        + 'and side = :side '
        + 'and rownum = 1';
      Params.ParamByName('pdline').AsString := sPDLineID;
      Params.ParamByName('part').AsString := sPart;
      Params.ParamByName('Version').AsString := sVer;
      Params.ParamByName('machine').AsString := sMachineCode;
      Params.ParamByName('side').AsInteger := combSide.ItemIndex;
      Open;
      if not IsEmpty then
      begin
        sMessage := 'Line: ' + combLine.Text + #10#13
          + 'Part: ' + editPartNO.Text + #10#13
          + 'Version: ' + sVer + #10#13
          + 'Machine: ' + combMachine.Text + #10#13
          + 'Side: ' + combSide.Text + #10#13
          + 'MSL No is Exist, Replace?';
        if MessageDlg(sMessage, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
        begin
          Exit;
        end
        else
        begin
          sMSL := FieldByName('MSL_No').AsString;
          with QryTemp do
          begin
            try
              Close;
              Params.Clear;
              Params.CreateParam(ftString, 'MSL_NO', ptInput);
              CommandText := 'delete From SMT.SYS_MSL ' +
                'Where MSL_NO = :MSL_NO';
              Params.ParamByName('MSL_NO').AsString := sMSL;
              Execute;
              Close;
              Params.Clear;
              Params.CreateParam(ftString, 'MSL_NO', ptInput);
              CommandText := 'delete From SMT.SYS_MSL_DETAIL ' +
                'Where MSL_NO = :MSL_NO';
              Params.ParamByName('MSL_NO').AsString := sMSL;
              Execute;
              Close;
              Params.Clear;
              Params.CreateParam(ftString, 'MSL_NO', ptInput);
              CommandText := 'delete From SMT.SYS_MSL_SUB ' +
                'Where MSL_NO = :MSL_NO';
              Params.ParamByName('MSL_NO').AsString := sMSL;
              Execute;
              Close;
            except
              MessageDlg('Delete MSL Exception!', mtWarning, [mbOK], 0);
              exit;
            end;
          end;
        end;
      end
      else
      begin
        sMessage := 'Import File: ' + sFileTemp + #10#13
          + 'to ' + #10#13
          + 'Line: ' + combLine.Text + #10#13
          + 'Part: ' + editPartNO.Text + #10#13
          + 'Version: ' + sVer + #10#13
          + 'Machine: ' + combMachine.Text + #10#13
          + 'Side: ' + combSide.Text + #10#13;
        if MessageDlg(sMessage, mtConfirmation, [mbYES, mbNO], 0) = mrNo then exit;
        sMSL := GetMaxMSL;
      end;
    end;
    bError := False;
    with QryTemp do
    begin
      close;
      Params.clear;
      Params.CreateParam(ftString, 'MSL_NO', ptInput);
      Params.CreateParam(ftString, 'PDLINE_Id', ptInput);
      Params.CreateParam(ftString, 'PART_Id', ptInput);
      Params.CreateParam(ftString, 'Version', ptInput);
      Params.CreateParam(ftString, 'machine_ID', ptInput);
      Params.CreateParam(ftString, 'side', ptInput);
      Params.CreateParam(ftString, 'EMP_NO', ptInput);
      CommandText := 'Insert into SMT.SYS_MSL '
        + '(MSL_NO,PDLINE_ID,PART_ID,Version,Machine_ID,Side,update_userid,UPDATE_TIME ) '
        + ' VALUES '
        + '(:MSL_NO,:PDLINE_ID,:PART_ID,:Version,:Machine_ID,:Side,:EMP_NO,SYSDATE) ';
      Params.ParamByName('MSL_NO').AsString := sMSL;
      Params.ParamByName('PDLINE_Id').AsString := sPDLineID;
      Params.ParamByName('PART_Id').AsString := sPart;
      Params.ParamByName('Version').AsString := sVer;
      Params.ParamByName('machine_ID').AsString := sMachineCode;
      Params.ParamByName('side').AsInteger := combSide.ItemIndex;
      Params.ParamByName('EMP_NO').AsString := UpdateUserID;
      Execute;
      close;
    end;
    AssignFile(vFile, sFileTemp);
    Reset(vFile);
    sTemp := ''; (* Record Pre Station no*)
    while not EOF(vFile) do
    begin
      Readln(vFile, mS);
      mS := TrimLeft(ms);
          //讀取TAB鍵
      iStart := 1;
      iIndex := 0;
      sStationNo := '';
      sItem := '';
      sSpec := '';
      sSpec2 := '';
      sAllLocation := '';
      sQty := '';
      sFedder := '';
      while mS <> '' do
      begin
        inc(iIndex);
        iLength := Pos(chr(vk_TAB), mS) - 1;
        if iLength = -1 then
          iLength := length(mS);
        case iIndex of
          1: sStationNo := trim(Copy(mS, iStart, iLength));
          2: sItem := trim(Copy(mS, iStart, iLength));
          3: sSpec := trim(Copy(mS, iStart, iLength));
          4: sSpec2 := trim(Copy(mS, iStart, iLength));
          5: sAllLocation := trim(Copy(mS, iStart, iLength));
          6: sQty := trim(Copy(mS, iStart, iLength));
          7: sFedder := trim(Copy(mS, iStart, iLength));
        end;
        mS := copy(mS, iLength + 2, length(mS));
      end;

      if sItem = '' then
      begin
        MessageDlg('Station: ' + sStationNo + #10#10 + 'Part is Empty.' + #10#10 + 'Please check this file.'
          + #10#10 + sFileTemp, mtError, [mbOK], 0);
        bError := True;
        break;
      end;
      if sQty <> '' then
      begin
        try
          StrToFloat(sQty);
        except
          MessageDlg('Station: ' + sStationNo + #10#10 + 'Qty is Error.' + #10#10 + 'Please check this file.'
            + #10#10 + sFileTemp, mtError, [mbOK], 0);
          bError := True;
          break;
        end;
      end;
      sSubPartID := InsertPart(sItem, sSpec, sSpec2);
      if sSubPartID = '' then
      begin
        bError := True;
        break;
      end;

      if sTemp = sStationNo then (* If equal than must be substitute *)
        InsertSubItem(sMSL, sTempPartID, sSubPartID)
      else
      begin
        InsertMSL(sMSL, sMachineCode, sStationNo, sSubPartId, sAllLocation, sQty, sFedder);
        sTemp := sStationNo;
        sTempPartID := sSubPartId;
      end;
    end; //while
    CloseFile(vFile);
  end;
  if gbMulti then begin
    for i := 1 to iTotal do
      DeleteFile(ChangeFileExt(sExcelFile, '-' + FormatFloat('00', i) + '.msl'));
    DeleteFile(ChangeFileExt(sExcelFile, '.Ini'));
  end;
  if not bError then
  begin
    sMessage := 'Line: ' + combLine.Text + #10#13
      + 'Part: ' + editPartNO.Text + #10#13
      + 'Version: ' + sVer + #10#13
      + 'Machine: ' + combMachine.Text + #10#13
      + 'Side: ' + combSide.Text + #10#13
      + 'Impot OK!';
    MessageDlg(sMessage, mtInformation, [mbOK], 0);
  end;
end;

procedure TfDetail.ShellListView1DblClick(Sender: TObject);
begin
  sbtnExeclClick(Self);
end;

procedure TfDetail.FormShow(Sender: TObject);
var sIni: TIniFile; sPath: string;
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;

  sIni := TIniFile.Create('Sajet.Ini');
  sPath := sIni.ReadString('SMT', 'Transfer Path', '');
  if sPath <> '' then
    if DirectoryExists(sPath) then
      ShellTreeView1.Path := sPath;
  sIni.Free;
  with QryTemp do
  begin
    slTypeID := TStringList.Create;
    Close;
    Params.Clear;
    CommandText := 'select type_id, msl_type '
      + 'from smt.sys_msl_type order by msl_type ';
    Open;
    combType.Clear;
    while not eof do
    begin
      combType.Items.Add(FieldByName('msl_type').Asstring);
      slTypeID.Add(FieldByName('type_id').AsString);
      next;
    end;
    Close;
    combType.ItemIndex := 0;
    combTypeChange(Self);
    slPdlineID := TStringList.Create;
    Close;
    Params.Clear;
    CommandText := 'select pdline_name, pdline_id '
      + 'from sajet.sys_pdline where enabled = ''Y'' '
      + 'ORDER BY pdline_name ';
    Open;
    combLine.Clear;
    while not eof do
    begin
      combline.Items.Add(FieldByName('pdline_name').Asstring);
      slPdlineID.Add(FieldByName('pdline_id').AsString);
      next;
    end;
    Close;
    Params.Clear;
    CommandText := 'Select machine_id, machine_code, machine_desc '
      + 'from sajet.SYS_Machine where enabled = ''Y'' order by machine_code';
    Open;
    slMachineID := TStringList.Create;
    slMachineDesc := TStringList.Create;
    slMachineID.Clear;
    slMachineDesc.Clear;
    combMachine.Items.Clear;
    while not eof do
    begin
      combMachine.Items.Add(FieldByName('machine_code').AsString);
      slMachineID.Add(FieldByName('machine_id').AsString);
      slMachineDesc.Add(FieldByName('machine_desc').AsString);
      Next;
    end;
    Close;
    combMachine.ItemIndex := 0;
    if combMachine.ItemIndex <> -1 then
      lablMachineDesc.Caption := slMachineDesc[0];
  end;
end;

procedure TfDetail.combMachineChange(Sender: TObject);
begin
  lablMachineDesc.Caption := slMachineDesc[combMachine.ItemIndex];
end;

procedure TfDetail.Splitter1Moved(Sender: TObject);
begin
  ShellComboBox1.Width := ShellTreeView1.Width;
end;

procedure TfDetail.sbtnPathClick(Sender: TObject);
var sIni: TIniFile;
begin
  sIni := TIniFile.Create('Sajet.Ini');
  sIni.WriteString('SMT', 'Transfer Path', ShellTreeView1.Path);
  sIni.Free;
end;

procedure TfDetail.sbtnFilterClick(Sender: TObject);
begin
  try
    fFilter := TfFilter.Create(self);
    fFilter.qryData.RemoteServer := QryData.RemoteServer;
    with fFilter.qryData do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PART_NO', ptInput);
      CommandText := 'SELECT part_no, spec1 '
        + 'FROM sajet.sys_part '
        + 'WHERE part_no LIKE :part_no '
        + 'ORDER BY part_no ';
      Params.ParamByName('PART_NO').AsString := Trim(editPartNo.Text) + '%';
      Open;
      if not IsEmpty then
      begin
        if fFilter.Showmodal = mrOK then
        begin
          editPartNo.Text := Fieldbyname('part_no').AsString;
        end;
      end;
      Close;
    end;
  finally
    fFilter.Free;
  end;
end;

procedure TfDetail.editPartNoKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
    GetPartVersion;
end;

procedure TfDetail.GetPartVersion;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PN', ptInput);
    CommandText := 'Select nvl(b.Version,''N/A'') Version ,b.update_time,a.version Ver ' +
      'From SAJET.SYS_PART A, ' +
      'SAJET.SYS_BOM_INFO B ' +
      'Where A.PART_ID = B.PART_ID and ' +
      'A.PART_NO = :PN ' +
      'order by b.update_time desc ';
    Params.ParamByName('PN').AsString := editPartNo.Text;
    Open;
    combVersion.Clear;
    if not IsEmpty then
    begin
      while not Eof do
      begin
        combVersion.Items.Add(FieldByname('Version').AsString);
        Next;
      end;
    end;
    Close;
  end;

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PN', ptInput);
    CommandText := 'Select update_time,nvl(version,''N/A'') version ' +
      'From SAJET.SYS_PART ' +
      'Where PART_NO = :PN ';
    Params.ParamByName('PN').AsString := editPartNo.Text;
    Open;
    if not IsEmpty then
    begin
      while not Eof do
      begin
        if combVersion.Items.IndexOf(FieldByName('Version').AsString) = -1 then
          combVersion.Items.Add(FieldByname('Version').AsString);
        Next;
      end;
    end;
    Close;
  end;
end;

procedure TfDetail.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  qryData.Close;
  slTypeID.Free;
  slPdLineId.Free;
  slMachineDesc.Free;
  slMachineId.Free;
  action := cafree;
end;

procedure TfDetail.combTypeChange(Sender: TObject);
begin
  with QryTemp do begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'type_id', ptInput);
    CommandText := 'select * '
      + 'from smt.sys_msl_type where type_id = :type_id and rownum = 1 ';
    Params.ParamByName('type_id').AsString := slTypeId[combType.Items.IndexOf(combType.Text)];
    Open;
    editPartNo.Enabled := (FieldByName('part_enabled').AsString = 'Y');
    sbtnFilter.Enabled := editPartNo.Enabled;
    combVersion.Enabled := editPartNo.Enabled;
    combMachine.Enabled := (FieldByName('machine_enabled').AsString = 'Y');
    combSide.Enabled := (FieldByName('side_enabled').AsString = 'Y');
    gbMulti := (FieldByName('Multi').AsString = 'Y');
    if editPartNo.Enabled then
      editPartNo.Color := $00B5FFFF
    else
      editPartNo.Color := clWindow;
    if combMachine.Enabled then
      combMachine.Color := $00B5FFFF
    else
      combMachine.Color := clWindow;
    if combSide.Enabled then
      combSide.Color := $00B5FFFF
    else
      combSide.Color := clWindow;
    Close;
  end;
end;

end.

