unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, Db, ImgList, ComCtrls,
  DBClient, MConnect, SConnect, IniFiles, ObjBrkr, uSort;

type
  TfDetail = class(TForm)
    Label5: TLabel;
    Label9: TLabel;
    ImageBack: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    Label2: TLabel;
    cmbFactory: TComboBox;
    Label6: TLabel;
    Label17: TLabel;
    ChkLine: TCheckBox;
    ChkProcess: TCheckBox;
    Label19: TLabel;
    Label21: TLabel;
    ChkWO: TCheckBox;
    Label23: TLabel;
    ChkPart: TCheckBox;
    Bevel1: TBevel;
    Bevel2: TBevel;
    ListSort: TListBox;
    sbtnSort: TSpeedButton;
    Label11: TLabel;
    editName: TEdit;
    Label12: TLabel;
    editFile: TEdit;
    sbtnImport: TSpeedButton;
    sbtnSave: TSpeedButton;
    Image2: TImage;
    OpenDialog1: TOpenDialog;
    TlbReportFile: TClientDataSet;
    Label14: TLabel;
    cmbMain: TComboBox;
    Label15: TLabel;
    cmbSecond: TComboBox;
    chkForPersonnal: TCheckBox;
    Label8: TLabel;
    lablReportBack: TLabel;
    lablReport: TLabel;
    LvReport: TListView;
    Image4: TImage;
    sbtnAdd: TSpeedButton;
    Image3: TImage;
    sbtnInspDel: TSpeedButton;
    ImageList2: TImageList;
    Label3: TLabel;
    edtDll: TEdit;
    Image5: TImage;
    Image1: TImage;
    sbtnSaveAs: TSpeedButton;
    lablModel: TLabel;
    ChkModel: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnImportClick(Sender: TObject);
    procedure sbtnSortClick(Sender: TObject);
    procedure cmbMainDropDown(Sender: TObject);
    procedure ChkLineClick(Sender: TObject);
    procedure sbtnAddClick(Sender: TObject);
    procedure sbtnInspDelClick(Sender: TObject);
    procedure LvReportClick(Sender: TObject);
    procedure cmbSecondDropDown(Sender: TObject);
    procedure sbtnSaveAsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID: string;
    SampleFileName, gsDll: string;
    gsRpID, RPID, RpName, gsRPTypeIDX, gsRPName: string;
    FcID: string;
    lstReportID: TStringList;
    function GetMaxReportID: string;
    function GetFactoryID: string;
    procedure GetFactoryData;
    procedure ShowFactory;
    procedure ShowReportCfgData;
    procedure ShowAllReport;
    procedure ChkAuthority;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}

procedure TfDetail.ChkAuthority;
var sProgram: string;
begin
  sbtnSave.Enabled := False;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    CommandText := 'select program from sajet.sys_program_name '
      + 'where upper(EXE_FILENAME) = :EXE_FILENAME and rownum = 1 ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Open;
    sProgram := FieldByName('Program').AsString;
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
    Params.ParamByName('PRG').AsString := sProgram;
    Params.ParamByName('FUN').AsString := gsRPName;
    Open;
    while not Eof do
    begin
      sbtnSave.Enabled := (FieldByName('AUTHORITYS').AsString = 'Allow To Change');
      if sbtnSave.Enabled then
        break;
      Next;
    end;
    Close;
  end;
  if not sbtnSave.Enabled then
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
      Params.ParamByName('PRG').AsString := sProgram;
      Params.ParamByName('FUN').AsString := gsRPName;
      Open;
      while not Eof do
      begin
        sbtnSave.Enabled := (FieldByName('AUTHORITYS').AsString = 'Allow To Change');
        if sbtnSave.Enabled then
          break;
        Next;
      end;
      Close;
    end;
  sbtnInspDel.Enabled := sbtnSave.Enabled;
  sbtnSaveAs.Enabled := sbtnSave.Enabled;
  sbtnAdd.Enabled := sbtnSave.Enabled;
end;

procedure TfDetail.ShowFactory;
begin
  cmbFactory.Items.Clear;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select FACTORY_CODE,FACTORY_NAME ' +
      'From SAJET.SYS_FACTORY ' +
      'Where ENABLED = ''Y'' ';
    Open;
    while not Eof do
    begin
      cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString);
      Next;
    end;
    Close;
  end;

  if cmbFactory.Items.Count = 1 then
  begin
    cmbFactory.ItemIndex := 0;
  end;
end;

procedure TfDetail.GetFactoryData;
var S: string;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'FACTORY_ID', ptInput);
    CommandText := 'Select FACTORY_CODE,FACTORY_NAME ' +
      'From SAJET.SYS_FACTORY ' +
      'Where FACTORY_ID = :FACTORY_ID ';
    Params.ParamByName('FACTORY_ID').AsString := FcID;
    Open;
    if RecordCount > 0 then
    begin
      S := Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString;
      cmbFactory.ItemIndex := cmbFactory.Items.Indexof(S);
    end;
    Close;
  end;

  if cmbFactory.Items.Count = 1 then
    cmbFactory.ItemIndex := 0;
end;

procedure TfDetail.ShowReportCfgData;
begin
  FcID := '0';
  chkForPersonnal.Checked := (LvReport.Selected.ImageIndex = 1);
  ChkModel.Checked := False;
  ListSort.Items.Clear;
  cmbMain.Items.Clear;
  cmbSecond.Items.Clear;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RP_ID', ptInput);
    CommandText := 'Select B.*,A.RP_NAME,A.SAMPLE_NAME,A.Dll_FileName ' +
      'From SAJET.SYS_REPORT_NAME A, ' +
      'SAJET.SYS_REPORT_PARAM B ' +
      'Where A.RP_ID = :RP_ID and ' +
      'A.RP_ID = B.RP_ID ' +
      'Order By PARAM_TYPE,PARAM_VALUE ';
    Params.ParamByName('RP_ID').AsString := RpID;
    Open;
    if RecordCount > 0 then
    begin
      editFile.Text := Fieldbyname('SAMPLE_NAME').AsString;
      editName.Text := Fieldbyname('RP_NAME').AsString;
      edtDll.Text := Fieldbyname('Dll_FileName').AsString;
      if editFile.Text = 'N/A' then
        editFile.Text := '';
      SampleFileName := editFile.Text;
    end;
    while not eof do
    begin
      if Fieldbyname('PARAM_TYPE').AsString = 'Query Condition' then
      begin
        if Fieldbyname('PARAM_NAME').AsString = 'FACTORY_ID' then
          FcID := Fieldbyname('PARAM_VALUE').AsString;
      end;
      if Fieldbyname('PARAM_TYPE').AsString = 'Display Information' then
      begin
        if Fieldbyname('PARAM_NAME').AsString = 'Production Line' then
          ChkLine.Checked := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Process Name' then
          ChkProcess.Checked := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Work Order' then
          ChkWO.Checked := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Part No' then
          ChkPart.Checked := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        if Fieldbyname('PARAM_NAME').AsString = 'Model Name' then
          ChkModel.Checked := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
      end;
      if Fieldbyname('PARAM_TYPE').AsString = 'Chart Set' then
      begin
        if Fieldbyname('PARAM_NAME').AsString = 'Main' then
        begin
          if Fieldbyname('PARAM_VALUE').AsString <> '' then
            if cmbMain.Items.IndexOf(Fieldbyname('PARAM_VALUE').AsString) = -1 then
              cmbMain.Items.Add(Fieldbyname('PARAM_VALUE').AsString);
          cmbMain.ItemIndex := cmbMain.Items.IndexOf(Fieldbyname('PARAM_VALUE').AsString);
        end;
        if Fieldbyname('PARAM_NAME').AsString = 'Second' then
        begin
          if Fieldbyname('PARAM_VALUE').AsString <> '' then
            if (Fieldbyname('PARAM_VALUE').AsString <> 'N/A') and (cmbSecond.Items.IndexOf(Fieldbyname('PARAM_VALUE').AsString) = -1) then
              cmbSecond.Items.Add(Fieldbyname('PARAM_VALUE').AsString);
          cmbSecond.ItemIndex := cmbSecond.Items.IndexOf(Fieldbyname('PARAM_VALUE').AsString);
          if cmbSecond.Text = 'N/A' then cmbSecond.ItemIndex := -1;
        end;
      end;

      if Fieldbyname('PARAM_TYPE').AsString = 'Sort Condition' then
        ListSort.Items.Add(Fieldbyname('PARAM_NAME').AsString);
      Next;
    end;
  end;
  if FcID <> '0' then
    GetFactoryData;
end;

procedure TfDetail.FormCreate(Sender: TObject);
begin
  lstReportID := TStringList.Create;
  SampleFileName := '';
end;

function TfDetail.GetFactoryID: string;
var S: string;
begin
  Result := '0';
  s := Trim(Copy(cmbFactory.Text, 1, POS(' ', cmbFactory.Text) - 1));
  if S = '' then Exit;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'FACTORY_CODE', ptInput);
    CommandText := 'Select FACTORY_ID ' +
      'From SAJET.SYS_FACTORY ' +
      'Where FACTORY_CODE = :FACTORY_CODE ';
    Params.ParamByName('FACTORY_CODE').AsString := S;
    Open;
    if RecordCount > 0 then
      Result := Fieldbyname('FACTORY_ID').AsString;
    Close;
  end;
end;

function TfDetail.GetMaxReportID: string;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select NVL(Max(RP_ID),0) + 1 RPID ' +
      'From SAJET.SYS_REPORT_NAME';
    Open;
    if Fieldbyname('RPID').AsString = '1' then
    begin
      Close;
      CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || ''000001'' RPID ' +
        'From SAJET.SYS_BASE ' +
        'Where PARAM_NAME = ''DBID'' ';
      Open;
    end;
    Result := Fieldbyname('RPID').AsString;
    Close;
  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
  ShowFactory;
  ShowAllReport;
  ChkAuthority;
  edtDll.Text := gsDll;
end;

procedure TfDetail.ShowAllReport;
begin
  LvReport.Items.Clear;
  lstReportID.Clear;
  if gsRPId <> '' then
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select * from all_tab_columns '
        + 'where owner=''SAJET'' and table_name = ''SYS_MODEL''';
      Open;
      ChkModel.Visible := not IsEmpty;
      lablModel.Visible := ChkModel.Visible;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RP_ID', ptInput);
      CommandText := 'Select Sample_Name ' +
        'From SAJET.SYS_REPORT_NAME ' +
        'Where RP_ID = :RP_ID ' +
        'ORder By RP_TYPE,RP_NAME';
      Params.ParamByName('RP_ID').AsString := gsRPID;
      Open;
      gsDll := FieldByName('Sample_Name').AsString;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RP_ID', ptInput);
      CommandText := 'Select RP_ID,RP_NAME,RP_TYPE,EMP_ID,RP_TYPE_IDX ' +
        'From SAJET.SYS_REPORT_NAME ' +
        'Where RP_ID = :RP_ID ' +
        'ORder By RP_TYPE,RP_NAME';
      Params.ParamByName('RP_ID').AsString := gsRPID;
      Open;
      gsRPTypeIDX := FieldByName('RP_TYPE_IDX').AsString;
      gsRPName := FieldByName('RP_NAME').AsString;
      lablReport.Caption := FieldByName('RP_TYPE').AsString;
      lablReportBack.Caption := lablReport.Caption;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'RP_Type', ptInput);
      Params.CreateParam(ftString, 'RP_ID', ptInput);
      CommandText := 'Select RP_ID,RP_NAME,RP_TYPE,EMP_ID ' +
        'From SAJET.SYS_REPORT_NAME ' +
        'Where (EMP_ID = 0 or EMP_ID = :EMP_ID) ' +
        'and RP_Type = :RP_Type and RP_ID <> :RP_ID ' +
        'ORder By RP_TYPE,RP_NAME';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('RP_Type').AsString := lablReport.Caption;
      Params.ParamByName('RP_ID').AsString := gsRPID;
      Open;
      while not Eof do
      begin
        with LvReport.Items.Add do
        begin
          Caption := Fieldbyname('RP_NAME').AsString;
          if Fieldbyname('EMP_ID').AsString <> '0' then
            ImageIndex := 1;
        end;
        lstReportID.Add(Fieldbyname('RP_ID').AsString);
        Next;
      end;
      Close;
    end;
  end;
end;

procedure TfDetail.sbtnSaveClick(Sender: TObject);
var iCnt: Integer; S, sRPIDTemp: string;
  function GetData(LstBox: TListBox): string;
  var I: Integer;
  begin
    Result := LstBox.Items.Strings[0];
    for I := 1 to LstBox.Items.Count - 1 do
    begin
      Result := Result + ',' + LstBox.Items.Strings[I];
    end;
  end;

  procedure SaveReportParams(RpID, ParamType, ParamName, ParamValue: string);
  begin
    with QryTemp do
    begin
      Close;
      Params.ParamByName('RP_ID').AsString := RpID;
      Params.ParamByName('PARAM_TYPE').AsString := ParamType;
      Params.ParamByName('PARAM_NAME').AsString := ParamName;
      Params.ParamByName('PARAM_VALUE').AsString := ParamValue;
      Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
      Execute;
    end;
  end;

  function SaveReportNameWithBlob: Boolean;
  begin
    with TlbReportFile do
    begin
      Open;
      Insert;
      FieldByName('RP_ID').AsString := RpID;
      FieldByName('RP_NAME').AsString := editName.Text;
      FieldByName('RP_TYPE').AsString := lablReport.Caption;
      FieldByName('SAMPLE_NAME').AsString := ExtractFilename(editFile.Text);
      TBlobField(FieldByName('SAMPLE_FILE')).LoadFromFile(Trim(editFile.Text));
      FieldByName('UPDATE_USERID').AsString := UpdateUserID;
      if chkForPersonnal.Checked then
         FieldByName('EMP_ID').AsString := UpdateUserID
      else
         FieldByName('EMP_ID').AsString := '0'; 
      FieldByName('RP_TYPE_IDX').AsString := gsRPTypeIDX;
      FieldByName('DLL_FILENAME').AsString := edtDll.Text;
      ApplyUpdates(0);
    end;
    Result := True;
  end;

  function InsertReportNameWithNoBlob: Boolean;
  begin
    Result := False;
    try
      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'RP_ID', ptInput);
        Params.CreateParam(ftString, 'RP_NAME', ptInput);
        Params.CreateParam(ftString, 'RP_TYPE', ptInput);
        Params.CreateParam(ftString, 'SAMPLE_NAME', ptInput);
        Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
        Params.CreateParam(ftString, 'EMP_ID', ptInput);
        Params.CreateParam(ftString, 'RP_TYPE_IDX', ptInput);
        Params.CreateParam(ftString, 'DLL_FILENAME', ptInput);
        CommandText := 'Insert Into SAJET.SYS_REPORT_NAME ' +
          ' (RP_ID,RP_NAME,RP_TYPE,SAMPLE_NAME,UPDATE_USERID,EMP_ID,RP_TYPE_IDX,DLL_FILENAME) ' +
          'Values (:RP_ID,:RP_NAME,:RP_TYPE,:SAMPLE_NAME,:UPDATE_USERID,:EMP_ID,:RP_TYPE_IDX,:DLL_FILENAME) ';
        Params.ParamByName('RP_ID').AsString := RpID;
        Params.ParamByName('RP_NAME').AsString := editName.Text;
        Params.ParamByName('RP_TYPE').AsString := lablReport.Caption;
        Params.ParamByName('SAMPLE_NAME').AsString := 'N/A';
        Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
        if chkForPersonnal.Checked then
          Params.ParamByName('EMP_ID').AsString := UpdateUserID
        else
          Params.ParamByName('EMP_ID').AsString := '0';
        Params.ParamByName('RP_TYPE_IDX').AsString := gsRPTypeIDX;
        Params.ParamByName('DLL_FILENAME').AsString := edtDll.Text;
        Execute;
      end;
    except
      QryTemp.Close;
      MessageDlg('Database Error !!' + #13#10 +
        'could not save to Database !', mtError, [mbCancel], 0);
      Exit;
    end;
    Result := True;
  end;

  function AddReportName: Boolean;
  begin
    // 檢查 NAME 是否重複
    Result := False;
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'REPORT_NAME', ptInput);
      Params.CreateParam(ftString, 'RP_TYPE', ptInput);
      CommandText := 'Select RP_NAME ' +
        'From SAJET.SYS_REPORT_NAME ' +
        'Where RP_NAME = :REPORT_NAME ' +
        'and RP_TYPE = :RP_TYPE';
      Params.ParamByName('REPORT_NAME').AsString := Trim(editName.Text);
      Params.ParamByName('RP_TYPE').AsString := lablReport.Caption;
      Open;
      if RecordCount > 0 then
      begin
        Close;
        MessageDlg('Report Name Duplicate !! ', mtError, [mbCancel], 0);
        Exit;
      end;

      RpId := GetMaxReportID;

      if RpId = '' then
      begin
        MessageDlg('Database Error !!' + #13#10 +
          'could not get Report Id !!', mtError, [mbCancel], 0);
        Exit;
      end;

      try
        if not FileExists(editFile.Text) then
          editFile.Text := 'C:\' + editFile.Text;
        if (Trim(editFile.Text) <> '') and ((FileExists(editFile.Text))) then
        begin
          if not SaveReportNameWithBlob then
            Exit;
        end
        else
        begin
          if not InsertReportNameWithNoBlob then
            Exit;
        end;
      except
        MessageDlg('Database Error !!' + #13#10 +
          'could not save to Database !!', mtError, [mbCancel], 0);
        Exit;
      end;
    end;
    Result := True;
  end;

  function ModiReportName: Boolean;
  begin
    Result := False;
    // 檢查是否重複
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'REPORT_NAME', ptInput);
      Params.CreateParam(ftString, 'RP_TYPE', ptInput);
      Params.CreateParam(ftString, 'RP_ID', ptInput);
      CommandText := 'Select RP_NAME ' +
        'From SAJET.SYS_REPORT_NAME ' +
        'Where RP_NAME = :REPORT_NAME ' +
        'and RP_TYPE = :RP_TYPE ' +
        'and RP_ID <> :RP_ID ';
      Params.ParamByName('REPORT_NAME').AsString := editName.Text;
      Params.ParamByName('RP_TYPE').AsString := lablReport.Caption;
      Params.ParamByName('RP_ID').AsString := RpID;
      Open;
      if RecordCount > 0 then
      begin
        Close;
        MessageDlg('Report Name Duplicate !! ', mtError, [mbCancel], 0);
        Exit;
      end;
    end;

    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RP_ID', ptInput);
      CommandText := 'Delete SAJET.SYS_REPORT_PARAM ' +
        'Where RP_ID = :RP_ID ';
      Params.ParamByName('RP_ID').AsString := RpID;
      Execute;
    end;

    if Trim(editFile.Text) <> SampleFileName then
    begin
      // 刪除
      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'RP_ID', ptInput);
        CommandText := 'Delete SAJET.SYS_REPORT_NAME ' +
          'Where RP_ID = :RP_ID ';
        Params.ParamByName('RP_ID').AsString := RpID;
        Execute;
      end;
      if Trim(editFile.Text) <> '' then
      begin
        SaveReportNameWithBlob;
        Result := True;
        Exit;
      end
      else
      begin
        InsertReportNameWithNoBlob;
        Result := True;
        Exit;
      end;
    end;

    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RP_NAME', ptInput);
      Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'DLL_FILENAME', ptInput);
      Params.CreateParam(ftString, 'RP_ID', ptInput);
      CommandText := 'Update SAJET.SYS_REPORT_NAME ' +
        'Set RP_NAME = :RP_NAME,' +
        'UPDATE_USERID = :UPDATE_USERID,' +
        'EMP_ID = :EMP_ID,' +
        'DLL_FILENAME = :DLL_FILENAME,' +
        'UPDATE_TIME = SYSDATE ' +
        'Where RP_ID = :RP_ID ';
      Params.ParamByName('RP_NAME').AsString := editName.Text;
      Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
      if chkForPersonnal.Checked then
        Params.ParamByName('EMP_ID').AsString := UpdateUserID
      else
        Params.ParamByName('EMP_ID').AsString := '0';
      Params.ParamByName('DLL_FILENAME').AsString := edtDll.Text;
      Params.ParamByName('RP_ID').AsString := RpID;
      Execute;
    end;
    Result := True;
  end;
begin
  if Trim(editName.Text) = '' then
  begin
    MessageDlg('Report Name Error !!', mtError, [mbCancel], 0);
    editName.SetFocus;
    Exit;
  end;
  if Trim(edtDll.Text) = '' then
  begin
    MessageDlg('Dll File Name Error !!', mtError, [mbCancel], 0);
    edtDll.SetFocus;
    Exit;
  end;
  if Trim(cmbMain.Text) = '' then
  begin
    if cmbMain.Items.Count = 0 then
      MessageDlg('Please choose least 1 display field !!', mtError, [mbCancel], 0)
    else
      MessageDlg('Chart Main Set Error !!', mtError, [mbCancel], 0);
    cmbMain.SetFocus;
    Exit;
  end;
  if (editFile.Text <> '') and (editFile.Text <> SampleFileName) then
    if not FileExists(editFile.Text) then
    begin
      MessageDlg('Report Sample File not Exists !!', mtError, [mbCancel], 0);
      Exit;
    end;
  sRPIDTemp := RpID;
  if RpID = '' then
  begin
    if not AddReportName then
      Exit;

  end
  else
  begin
    if not ModiReportName then
      Exit;
  end;

  FCID := GetFactoryID;

  // 紀錄 Report 參數
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RP_ID', ptInput);
    Params.CreateParam(ftString, 'PARAM_TYPE', ptInput);
    Params.CreateParam(ftString, 'PARAM_NAME', ptInput);
    Params.CreateParam(ftString, 'PARAM_VALUE', ptInput);
    Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
    CommandText := 'Insert Into SAJET.SYS_REPORT_PARAM ' +
      ' (RP_ID,PARAM_TYPE,PARAM_NAME,PARAM_VALUE,UPDATE_USERID) ' +
      'Values ' +
      ' (:RP_ID,:PARAM_TYPE,:PARAM_NAME,:PARAM_VALUE,:UPDATE_USERID) ';
  end;

  SaveReportParams(RpID, 'Query Condition', 'FACTORY_ID', FcID);

  S := 'N';
  if ChkLine.Checked then S := 'Y';
  SaveReportParams(RpID, 'Display Information', 'Production Line', S);
  if S = 'N' then
    if ListSort.Items.IndexOf('Production Line') <> -1 then
      ListSort.Items.Delete(ListSort.Items.IndexOf('Production Line'));

  S := 'N';
  if ChkProcess.Checked then S := 'Y';
  SaveReportParams(RpID, 'Display Information', 'Process Name', S);
  if S = 'N' then
    if ListSort.Items.IndexOf('Process Name') <> -1 then begin
      ListSort.Items.Delete(ListSort.Items.IndexOf('Process Name'));
      ListSort.Items.Delete(ListSort.Items.IndexOf('Process Code'));
    end;

  S := 'N';
  if ChkWO.Checked then S := 'Y';
  SaveReportParams(RpID, 'Display Information', 'Work Order', S);
  if S = 'N' then
    if ListSort.Items.IndexOf('Work Order') <> -1 then
      ListSort.Items.Delete(ListSort.Items.IndexOf('Work Order'));

  S := 'N';
  if ChkPart.Checked then S := 'Y';
  SaveReportParams(RpID, 'Display Information', 'Part No', S);
  if S = 'N' then
    if ListSort.Items.IndexOf('Part No') <> -1 then
      ListSort.Items.Delete(ListSort.Items.IndexOf('Part No'));

  if ChkModel.Visible then begin
    S := 'N';
    if ChkModel.Checked then S := 'Y';
    SaveReportParams(RpID, 'Display Information', 'Model Name', S);
    if S = 'N' then
      if ListSort.Items.IndexOf('Model Name') <> -1 then
        ListSort.Items.Delete(ListSort.Items.IndexOf('Model Name'));
  end;

  for iCnt := 0 to ListSort.Items.Count - 1 do
    SaveReportParams(RpID, 'Sort Condition', ListSort.Items[iCnt], IntToStr(iCnt));

  SaveReportParams(RpID, 'Chart Set', 'Main', cmbMain.Text);
  SaveReportParams(RpID, 'Chart Set', 'Second', cmbSecond.Text);
  if sRPIDTemp = '' then
    ShowAllReport
  else
  begin
    LvReport.Selected.Caption := editName.Text;
    if chkForPersonnal.Checked then
      LvReport.Selected.ImageIndex := 1
    else
      LvReport.Selected.ImageIndex := 0;
  end;
  MessageDlg('Save Query Configuration OK.', mtInformation, [mbOK], 0);
end;

procedure TfDetail.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  lstReportID.Free;
end;

procedure TfDetail.sbtnImportClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    editFile.Text := OpenDialog1.FileName;
end;

procedure TfDetail.sbtnSortClick(Sender: TObject);
var I: Integer; lstItem: TListItem;
begin
  with TfSort.Create(Self) do
  begin
    LvItems.Items.Clear;
    if ChkLine.Checked then
      with LvItems.Items.Add do Caption := 'Production Line';
    if ChkProcess.Checked then
      with LvItems.Items.Add do Caption := 'Process Name';
    if ChkProcess.Checked then
      with LvItems.Items.Add do Caption := 'Process Code';
    if ChkWO.Checked then
      with LvItems.Items.Add do Caption := 'Work Order';
    if ChkPart.Checked then
      with LvItems.Items.Add do Caption := 'Part No';
    if ChkModel.Checked then
      with LvItems.Items.Add do Caption := 'Model Name';
    for i := 0 to ListSort.Items.Count - 1 do begin
      lstItem := LvItems.FindCaption(0, ListSort.Items[i], True, True, True);
      if lstItem <> nil then begin
        with LvSort.Items.Add do Caption := ListSort.Items[i];
        LvItems.Items.Delete(LvItems.Items.IndexOf(lstItem));
      end;
    end;
    if Showmodal = mrOK then
    begin
      ListSort.Items.Clear;
      for I := 0 to LvSort.Items.Count - 1 do
        ListSort.Items.Add(LvSort.Items[I].Caption);
    end;
    Free;
  end;
end;

procedure TfDetail.cmbMainDropDown(Sender: TObject);
var sTemp: string;
begin
  sTemp := cmbMain.Text;
  cmbMain.Clear;
  if ChkLine.Checked then
    cmbMain.Items.Add('Production Line');
  if ChkWO.Checked then
    cmbMain.Items.Add('Work Order');
  if ChkPart.Checked then
    cmbMain.Items.Add('Part No');
  if ChkModel.Checked then
    cmbMain.Items.Add('Model Name');
  if ChkProcess.Checked then
    cmbMain.Items.Add('Process Name');
  cmbMain.ItemIndex := cmbMain.Items.IndexOf(sTemp);
end;

procedure TfDetail.ChkLineClick(Sender: TObject);
var sStr: String;
begin
  if (Sender as TCheckBox).Name = 'ChkLine' then
  begin
     sStr := 'Production Line';
  end
  else if (Sender as TCheckBox).Name = 'ChkPart' then
  begin
    sStr := 'Part No';
  end
  else if (Sender as TCheckBox).Name = 'ChkModel' then
  begin
    sStr := 'Model Name';
  end
  else if (Sender as TCheckBox).Name = 'ChkWO' then
  begin
    sStr := 'Work Order';
  end
  else if (Sender as TCheckBox).Name = 'ChkProcess' then
  begin
    sStr := 'Process Name';
  end;
  if (Sender as TCheckBox).Checked then begin
    if cmbMain.Items.IndexOf(sStr) = -1 then begin
      cmbMain.Items.Add(sStr);
      cmbSecond.Items.Add(sStr);
    end
  end else begin
    if cmbMain.Text = sStr then
      cmbMain.ItemIndex := -1;
    cmbMain.Items.Delete(cmbMain.Items.IndexOf(sStr));
    cmbSecond.Items.Delete(cmbSecond.Items.IndexOf(sStr));
  end;
end;

procedure TfDetail.sbtnAddClick(Sender: TObject);
begin
  RPID := '';
  RpName := '';
  editName.Text := '';
  edtDll.Text := gsDll;
  editFile.Text := '';
  editName.SetFocus;
end;

procedure TfDetail.sbtnInspDelClick(Sender: TObject);
begin
  if RpName = '' then Exit;
  if MessageDlg('Do You Want To Delete This Report ' + #13#10 + RpName, mtWarning, mbOKCancel, 0) <> mrOK then
    Exit;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RP_ID', ptInput);
    CommandText := 'Delete SAJET.SYS_REPORT_NAME ' +
      'Where RP_ID = :RP_ID ';
    Params.ParamByName('RP_ID').AsString := RpID;
    Execute;

    Params.Clear;
    Params.CreateParam(ftString, 'RP_ID', ptInput);
    CommandText := 'Delete SAJET.SYS_REPORT_PARAM ' +
      'Where RP_ID = :RP_ID ';
    Params.ParamByName('RP_ID').AsString := RpID;
    Execute;
    Close;
    sbtnAddClick(Self);
    lstReportId.Delete(LvReport.Selected.Index);
    LvReport.Selected.Delete;
  end;
end;

procedure TfDetail.LvReportClick(Sender: TObject);
begin
  RpName := '';
  if LvReport.Selected = nil then Exit;
  RPID := lstReportID[LvReport.Selected.Index];
  RpName := LvReport.Selected.Caption;
  ShowReportCfgData;
end;

procedure TfDetail.cmbSecondDropDown(Sender: TObject);
var sTemp: string;
begin
  sTemp := cmbSecond.Text;
  cmbSecond.Clear;
  cmbSecond.Items.Add('');
  if ChkLine.Checked then
    cmbSecond.Items.Add('Production Line');
  if ChkWO.Checked then
    cmbSecond.Items.Add('Work Order');
  if ChkPart.Checked then
    cmbSecond.Items.Add('Part No');
  if ChkModel.Checked then
    cmbSecond.Items.Add('Model Name');
  if ChkProcess.Checked then
    cmbSecond.Items.Add('Process Name');
  cmbSecond.ItemIndex := cmbSecond.Items.IndexOf(sTemp);
end;

procedure TfDetail.sbtnSaveAsClick(Sender: TObject);
  procedure DownloadSampleFile;
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RP_ID', ptInput);
      CommandText := 'Select nvl(SAMPLE_NAME,''N/A'') SAMPLE_NAME,SAMPLE_FILE ' +
        'From SAJET.SYS_REPORT_NAME ' +
        'Where RP_ID = :RP_ID ';
      Params.ParamByName('RP_ID').AsString := RpID;
      Open;
      if not Eof then
      begin
        if Fieldbyname('SAMPLE_NAME').AsString <> 'N/A' then
          TBlobField(Fieldbyname('SAMPLE_FILE')).SaveToFile('C:\' + Fieldbyname('SAMPLE_NAME').AsString)
        else
          editFile.Text := '';
      end;
      Close;
    end;
  end;
begin
  DownloadSampleFile;
  RPID := '';
  sbtnSaveClick(Self);
  editFile.Text := Copy(editFile.Text, 4, Length(editFile.Text));
  DeleteFile('C:\' + editFile.Text);
end;

end.

