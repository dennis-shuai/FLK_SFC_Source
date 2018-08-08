unit uSetStation;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ComCtrls, StdCtrls, Buttons, ExtCtrls, DB, IniFiles;

type
  TfStation = class(TForm)
    TreePC: TTreeView;
    Image1: TImage;
    sbtnSave: TSpeedButton;
    Image5: TImage;
    Image3: TImage;
    cmbFactory: TComboBox;
    Label2: TLabel;
    LabPDLine: TLabel;
    Label1: TLabel;
    LabStage: TLabel;
    Label5: TLabel;
    LabProcess: TLabel;
    Label6: TLabel;
    LabTerminal: TLabel;
    ImageList2: TImageList;
    procedure FormShow(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
    procedure TreePCClick(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure TreePCGetImageIndex(Sender: TObject; Node: TTreeNode);
  private
    { Private declarations }
  public
    { Public declarations }
    FcID: string;
    procedure ShowTerminal;
    function GetPdLineData(PdLineName: string; var PdLineID: string): Boolean;
    function GetProcessData(ProcessName: string; var ProcessID: string; var ProcessCode: string; var ProcessDesc: string): Boolean;
    function GetTerminalData(TerminalName: string; PdLineID: string; ProcessID: string; var TerminalID: string): Boolean;
  end;

var
  fStation: TfStation;

implementation

{$R *.DFM}
uses uData;

procedure TfStation.ShowTerminal;
var sLine, sStage, sProcess: string; bNoMatch: Boolean; 
  mNodeLine, mNodeStage, mNodeProcess, mNodeTerminal: TTreeNode;
begin
  TreePC.Items.Clear;
  bNoMatch := True;
  with fData.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'FCID', ptInput);
    Params.CreateParam(ftString, 'TYPENAME', ptInput);
    CommandText := 'SELECT PDLINE_NAME, STAGE_CODE, STAGE_NAME, PROCESS_CODE, PROCESS_NAME, ' +
      'TERMINAL_ID, TERMINAL_NAME ' +
      'FROM SAJET.SYS_TERMINAL A, ' +
      'SAJET.SYS_PDLINE B, ' +
      'SAJET.SYS_STAGE C, ' +
      'SAJET.SYS_PROCESS D, ' +
      'SAJET.SYS_OPERATE_TYPE E ' +
      'WHERE B.FACTORY_ID = :FCID AND ' +
      'A.PDLINE_ID = B.PDLINE_ID AND ' +
      'A.STAGE_ID = C.STAGE_ID AND ' +
      'A.PROCESS_ID = D.PROCESS_ID AND ' +
      'D.OPERATE_ID = E.OPERATE_ID AND ' +
      'E.TYPE_NAME = :TYPENAME AND ' +
      'A.ENABLED = ''Y'' AND ' +
      'B.ENABLED = ''Y'' AND ' +
      'C.ENABLED = ''Y'' AND ' +
      'D.ENABLED = ''Y'' ' +
      'ORDER BY PDLINE_NAME, STAGE_CODE, PROCESS_CODE, TERMINAL_NAME ';
    Params.ParamByName('FCID').AsString := FcID;
    Params.ParamByName('TYPENAME').AsString := 'Packing';
    Open;
    if not IsEmpty then
    begin
      sLine := Fieldbyname('PDLINE_NAME').AsString;
      sStage := Fieldbyname('STAGE_NAME').AsString;
      sProcess := Fieldbyname('PROCESS_NAME').AsString;
      mNodeLine := TreePC.Items.AddChildFirst(nil, FieldByName('PDLINE_NAME').asstring);
      mNodeLine.ImageIndex := 0;
      mNodeStage := TreePC.Items.AddChildFirst(mNodeLine, FieldByName('STAGE_NAME').asstring);
      mNodeStage.ImageIndex := 1;
      mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, FieldByName('PROCESS_NAME').asstring);
      mNodeProcess.ImageIndex := 2;
    end;
    while not Eof do
    begin
      if sLine <> Fieldbyname('PDLINE_NAME').AsString then
      begin
        sLine := Fieldbyname('PDLINE_NAME').AsString;
        sStage := Fieldbyname('STAGE_NAME').AsString;
        sProcess := Fieldbyname('PROCESS_NAME').AsString;
        mNodeLine := TreePC.Items.AddChildFirst(nil, FieldByName('PDLINE_NAME').asstring);
        mNodeLine.ImageIndex := 0;
        mNodeStage := TreePC.Items.AddChildFirst(mNodeLine, FieldByName('STAGE_NAME').asstring);
        mNodeStage.ImageIndex := 1;
        mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, FieldByName('PROCESS_NAME').asstring);
        mNodeProcess.ImageIndex := 2;
      end;
      if sStage <> Fieldbyname('STAGE_NAME').AsString then
      begin
        sStage := Fieldbyname('STAGE_NAME').AsString;
        sProcess := Fieldbyname('PROCESS_NAME').AsString;
        mNodeStage := TreePC.Items.AddChildFirst(mNodeLine, FieldByName('STAGE_NAME').asstring);
        mNodeStage.ImageIndex := 1;
        mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, FieldByName('PROCESS_NAME').asstring);
        mNodeProcess.ImageIndex := 2;
      end;
      if sProcess <> Fieldbyname('PROCESS_NAME').AsString then
      begin
        sProcess := Fieldbyname('PROCESS_NAME').AsString;
        mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, FieldByName('PROCESS_NAME').asstring);
        mNodeProcess.ImageIndex := 2;
      end;

      mNodeTerminal := TreePC.Items.AddChild(mNodeProcess, FieldByName('TERMINAL_NAME').asstring);
      mNodeTerminal.ImageIndex := 3;
      if FieldByName('TERMINAL_ID').asstring = fData.TerminalID then
      begin
        TreePC.Selected := mNodeTerminal;
        LabPDLine.Caption := mNodeTerminal.Parent.Parent.Parent.Text;
        LabStage.Caption := mNodeTerminal.Parent.Parent.Text;
        LabProcess.Caption := mNodeTerminal.Parent.Text;
        LabTerminal.Caption := mNodeTerminal.Text;
        bNoMatch := False;
      end;
      next;
    end;
    Close;
    mNodeLine := nil;
    mNodeStage := nil;
    mNodeProcess := nil;
    if bNoMatch then fData.TerminalID := '';
  end;
end;

function TfStation.GetTerminalData(TerminalName: string; PdLineID: string; ProcessID: string; var TerminalID: string): Boolean;
var S: string;
begin
  Result := False;
  with fData.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PDLINE_ID', ptInput);
    Params.CreateParam(ftString, 'PROCESS_ID', ptInput);
    Params.CreateParam(ftString, 'TERMINAL_NAME', ptInput);
    CommandText := 'SELECT TERMINAL_ID ' +
      'FROM SAJET.SYS_TERMINAL ' +
      'WHERE PDLINE_ID = :PDLINE_ID AND ' +
      'PROCESS_ID = :PROCESS_ID AND ' +
      'TERMINAL_NAME = :TERMINAL_NAME ';
    Params.ParamByName('PDLINE_ID').AsString := PdLineID;
    Params.ParamByName('PROCESS_ID').AsString := ProcessID;
    Params.ParamByName('TERMINAL_NAME').AsString := TerminalName;
    Open;
    if RecordCount > 0 then
      TerminalID := Fieldbyname('TERMINAL_ID').AsString;
    Close;
  end;

  if TerminalID = '' then
  begin
    S := 'Terminal data Error !! ' + #13#10 +
      'Terminal Name : ' + TerminalName;
    MessageDlg(S, mtError, [mbCancel], 0);
    Exit;
  end;
  Result := True;
end;

procedure TfStation.FormShow(Sender: TObject);
var S: string;
begin
  cmbFactory.Items.Clear;
  TreePC.Items.Clear;
  LabPDLine.Caption := '';
  LabStage.Caption := '';
  LabProcess.Caption := '';
  LabTerminal.Caption := '';

  S := '';
  with fData.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT FACTORY_ID, FACTORY_CODE, FACTORY_NAME ' +
      'FROM SAJET.SYS_FACTORY ' +
      'WHERE ENABLED = ''Y'' ';
    Open;
    while not Eof do
    begin
      cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString);
      if Fieldbyname('FACTORY_ID').AsString = fData.FCID then
        S := Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString;
      Next;
    end;
    Close;
  end;

  if S <> '' then
  begin
    cmbFactory.ItemIndex := cmbFactory.Items.IndexOf(S);
    cmbFactoryChange(Self);
    Exit;
  end;

  if cmbFactory.Items.Count = 1 then
  begin
    cmbFactory.ItemIndex := 0;
    cmbFactoryChange(Self);
  end;
end;

procedure TfStation.cmbFactoryChange(Sender: TObject);
begin
  FcID := '';
  LabPDLine.Caption := '';
  LabStage.Caption := '';
  LabProcess.Caption := '';
  LabTerminal.Caption := '';

  with fData.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'FACTORYCODE', ptInput);
    CommandText := 'SELECT FACTORY_ID, FACTORY_CODE, FACTORY_NAME, FACTORY_DESC ' +
      'FROM SAJET.SYS_FACTORY ' +
      'WHERE FACTORY_CODE = :FACTORYCODE ';
    Params.ParamByName('FACTORYCODE').AsString := Copy(cmbFactory.Text, 1, POS(' ', cmbFactory.Text) - 1);
    Open;
    if RecordCount > 0 then
      FcID := Fieldbyname('FACTORY_ID').AsString;
    Close;
  end;

  ShowTerminal;
end;

function TfStation.GetPdLineData(PdLineName: string; var PdLineID: string): Boolean;
var S: string;
begin
  Result := False;
  with fData.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PDLINE_NAME', ptInput);
    CommandText := 'SELECT PDLINE_ID,PDLINE_NAME ' +
      'FROM SAJET.SYS_PDLINE ' +
      'WHERE PDLINE_NAME = :PDLINE_NAME ';
    Params.ParamByName('PDLINE_NAME').AsString := PdLineName;
    Open;
    if RecordCount > 0 then
    begin
      PdLineID := Fieldbyname('PDLINE_ID').AsString;
    end;
    Close;
  end;

  if PdLineID = '' then
  begin
    S := 'Production Line data Error !! ' + #13#10 +
      'Production Name : ' + PdLineName;
    MessageDlg(S, mtError, [mbCancel], 0);
    Exit;
  end;
  Result := True;
end;

function TfStation.GetProcessData(ProcessName: string; var ProcessID: string; var ProcessCode: string; var ProcessDesc: string): Boolean;
var S: string;
begin
  Result := False;
  with fData.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PROCESS_NAME', ptInput);
    CommandText := 'SELECT PROCESS_ID, PROCESS_CODE, PROCESS_NAME, PROCESS_DESC ' +
      'FROM SAJET.SYS_PROCESS ' +
      'WHERE PROCESS_NAME = :PROCESS_NAME ';
    Params.ParamByName('PROCESS_NAME').AsString := ProcessName;
    Open;
    if RecordCount > 0 then
    begin
      ProcessID := Fieldbyname('PROCESS_ID').AsString;
      ProcessCode := Fieldbyname('PROCESS_CODE').AsString;
      ProcessDesc := Fieldbyname('PROCESS_DESC').AsString;
    end;
    Close;
  end;

  if ProcessID = '' then
  begin
    S := 'Process data Error !! ' + #13#10 +
      'Process Name : ' + ProcessName;
    MessageDlg(S, mtError, [mbCancel], 0);
    Exit;
  end;
  Result := True;
end;

procedure TfStation.TreePCClick(Sender: TObject);
begin
  if TreePC.Selected = nil then Exit;

  LabPDLine.Caption := '';
  LabStage.Caption := '';
  LabProcess.Caption := '';
  LabTerminal.Caption := '';

  if TreePC.Selected.Level <> 3 then Exit;

  LabPDLine.Caption := TreePC.Selected.Parent.Parent.Parent.Text;
  LabStage.Caption := TreePC.Selected.Parent.Parent.Text;
  LabProcess.Caption := TreePC.Selected.Parent.Text;
  LabTerminal.Caption := TreePC.Selected.Text;
end;

procedure TfStation.sbtnSaveClick(Sender: TObject);
var sPdLineID, sPdLineName: string;
  sProcessID, sProcessName, sProcessCode, sProcessDesc: string;
  sTerminalID, sTerminalName: string;
begin
  if LabTerminal.Caption = '' then
  begin
    MessageDlg('Work Terminal Not Assign !! ', mtError, [mbCancel], 0);
    Exit;
  end;

  sPdLineID := '';
  sPdLineName := LabPdLine.Caption;
  if not GetPdLineData(sPdLineName, sPdLineID) then
    Exit;

  sProcessID := '';
  sProcessName := LabProcess.Caption;
  if not GetProcessData(sProcessName, sProcessID, sProcessCode, sProcessDesc) then
    Exit;

  sTerminalID := '';
  sTerminalName := LabTerminal.Caption;
  if not GetTerminalData(sTerminalName, sPdLineID, sProcessID, sTerminalID) then
    Exit;

  with TIniFile.Create('SAJET.ini') do
  begin
    WriteString('System', 'Factory', FCID);
    WriteString('Packing', 'Terminal', sTerminalID);
    Free;
  end;

  fData.TerminalID := sTerminalID;
  fData.FcID := FCID;
  MessageDlg('Save OK!', mtInformation, [mbOK], 0);
//  Close;
end;

procedure TfStation.TreePCGetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := Node.Level;
end;

end.

