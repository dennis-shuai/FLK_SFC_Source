unit uConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ImgList, ComCtrls, Buttons, DB, DBClient, StdCtrls, IniFiles;

type
  TformConfig = class(TForm)
    Image1: TImage;
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
    Image5: TImage;
    Image2: TImage;
    sbtnSave: TSpeedButton;
    sbtnClose: TSpeedButton;
    TreePC: TTreeView;
    ImageList2: TImageList;
    procedure FormShow(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
    procedure TreePCGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure TreePCClick(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure sbtnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    FCID : String;
    AuthorityRole : String;
    procedure ShowTerminal;
    function  GetPdLineData(PdLineName : String; var PdLineID : String): Boolean;
    function  GetProcessData(ProcessName : String; var ProcessID : String; var ProcessCode : String; var ProcessDesc : String): Boolean;
    function  GetTerminalData(TerminalName : String; PdLineID : String; ProcessID : String; var TerminalID : String): Boolean;
    procedure SetStatusbyAuthority;
    { Public declarations }
  end;

var
  formConfig: TformConfig;

implementation

uses uMain;

{$R *.dfm}

procedure TformConfig.SetStatusbyAuthority;
begin
  AuthorityRole := '';
  with formMain.csFTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'EMP_ID', ptInput);
    Params.CreateParam(ftString	,'PRG', ptInput);
    Params.CreateParam(ftString	,'FUN', ptInput);
    CommandText := 'Select C.AUTH_SEQ, A.AUTHORITYS '+
                   'From SAJET.SYS_ROLE_PRIVILEGE A, '+
                        'SAJET.SYS_ROLE_EMP B, '+
                        'SAJET.SYS_PROGRAM_FUN C '+
                   'Where A.ROLE_ID = B.ROLE_ID and '+
                         'B.EMP_ID = :EMP_ID and '+
                         'A.PROGRAM = :PRG and '+
                         'A.FUNCTION = :FUN and '+
                         'A.PROGRAM = C.PROGRAM and '+
                         'A.FUNCTION = C.FUNCTION and '+
                         'A.AUTHORITYS = C.AUTHORITYS '+
                         'GROUP BY C.AUTH_SEQ, A.AUTHORITYS '+
                         'ORDER BY C.AUTH_SEQ DESC, A.AUTHORITYS';
    Params.ParamByName('EMP_ID').AsString := formMain.LoginUserID;
    Params.ParamByName('PRG').AsString := 'PrintReplaceLable';
    Params.ParamByName('FUN').AsString := 'Configuration';
    Open;
    If RecordCount > 0 Then
      AuthorityRole := Fieldbyname('AUTHORITYS').AsString;
    Close;
  end;

  sbtnSave.Enabled := (AuthorityRole = 'Allow To Change');
end;

procedure TformConfig.FormShow(Sender: TObject);
var
  S : String;
begin
  cmbFactory.Items.Clear;
  TreePC.Items.Clear;
  LabPDLine.Caption := '';
  LabStage.Caption := '';
  LabProcess.Caption := '';
  LabTerminal.Caption := '';
  SetStatusbyAuthority;

  S := '';
  with formMain.csFTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT FACTORY_ID, FACTORY_CODE, FACTORY_NAME '+
                   'FROM SAJET.SYS_FACTORY '+
                   'WHERE ENABLED = ''Y'' ';
    Open;
    while not Eof do
    begin
      cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString);
      if Fieldbyname('FACTORY_ID').AsString = formMain.FCID then
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

procedure TformConfig.cmbFactoryChange(Sender: TObject);
begin
  FcID := '';
  LabPDLine.Caption := '';
  LabStage.Caption := '';
  LabProcess.Caption := '';
  LabTerminal.Caption := '';

  with formMain.csFTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'FACTORYCODE', ptInput);
    CommandText := 'SELECT FACTORY_ID, FACTORY_CODE, FACTORY_NAME, FACTORY_DESC '+
                   'FROM SAJET.SYS_FACTORY '+
                   'WHERE FACTORY_CODE = :FACTORYCODE ';
    Params.ParamByName('FACTORYCODE').AsString := Copy(cmbFactory.Text,1,POS(' ',cmbFactory.Text)-1) ;
    Open;
    If RecordCount > 0 Then
      FcID := Fieldbyname('FACTORY_ID').AsString;
    Close;
  end;
  ShowTerminal;
end;

procedure TformConfig.ShowTerminal;
var
  sLine, sStage, sProcess : String;
  mNodeLine, mNodeStage, mNodeProcess : TTreeNode;
begin
  TreePC.Items.Clear;
  mNodeLine := nil;
  mNodeStage := nil;
  mNodeProcess := nil;
  with formMain.csFTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'FCID', ptInput);
    Params.CreateParam(ftString	,'TYPENAME', ptInput);
    CommandText := 'SELECT PDLINE_NAME, STAGE_CODE, STAGE_NAME, PROCESS_CODE, PROCESS_NAME, '+
                          'TERMINAL_ID, TERMINAL_NAME '+
                   'FROM SAJET.SYS_TERMINAL A, '+
                        'SAJET.SYS_PDLINE B, '+
                        'SAJET.SYS_STAGE C, '+
                        'SAJET.SYS_PROCESS D, '+
                        'SAJET.SYS_OPERATE_TYPE E '+
                   'WHERE B.FACTORY_ID = :FCID AND '+
                         'A.PDLINE_ID = B.PDLINE_ID AND '+
                         'A.STAGE_ID = C.STAGE_ID AND '+
                         'A.PROCESS_ID = D.PROCESS_ID AND '+
                         'D.OPERATE_ID = E.OPERATE_ID AND '+
                         'E.TYPE_NAME = :TYPENAME AND '+
                         'A.ENABLED = ''Y'' AND '+
                         'B.ENABLED = ''Y'' AND '+
                         'C.ENABLED = ''Y'' AND '+
                         'D.ENABLED = ''Y'' '+
                   'ORDER BY PDLINE_NAME, STAGE_CODE, PROCESS_CODE, TERMINAL_NAME ';
    Params.ParamByName('FCID').AsString := FcID;
    Params.ParamByName('TYPENAME').AsString := 'Input';
    Open;
    if RecordCount > 0 then
    begin
      sLine := FieldByName('PDLINE_NAME').AsString;
      sStage := FieldByName('STAGE_NAME').AsString;
      sProcess := FieldByName('PROCESS_NAME').AsString;
      mNodeLine := TreePC.Items.AddChildFirst(nil, FieldByName('PDLINE_NAME').AsString);
      mNodeLine.ImageIndex := 0;
      mNodeStage := TreePC.Items.AddChildFirst(mNodeLine, FieldByName('STAGE_NAME').AsString);
      mNodeStage.ImageIndex := 1;
      mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, FieldByName('PROCESS_NAME').AsString);
      mNodeProcess.ImageIndex := 2;
    end;

    while not Eof do
    begin
      if sLine <> FieldByName('PDLINE_NAME').AsString then
      begin
        sLine := FieldByName('PDLINE_NAME').AsString;
        sStage := FieldByName('STAGE_NAME').AsString;
        sProcess := FieldByName('PROCESS_NAME').AsString;
        mNodeLine := TreePC.Items.AddChildFirst(nil, FieldByName('PDLINE_NAME').AsString);
        mNodeLine.ImageIndex := 0;
        mNodeStage := TreePC.Items.AddChildFirst(mNodeLine, FieldByName('STAGE_NAME').AsString);
        mNodeStage.ImageIndex := 1;
        mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, FieldByName('PROCESS_NAME').AsString);
        mNodeProcess.ImageIndex := 2;
      end;
      if sStage <> Fieldbyname('STAGE_NAME').AsString then
      begin
        sStage := Fieldbyname('STAGE_NAME').AsString;
        sProcess := Fieldbyname('PROCESS_NAME').AsString;
        mNodeStage := TreePC.Items.AddChildFirst(mNodeLine, FieldByName('STAGE_NAME').AsString);
        mNodeStage.ImageIndex := 1;
        mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, FieldByName('PROCESS_NAME').AsString);
        mNodeProcess.ImageIndex := 2;
      end;
      if sProcess <> FieldByName('PROCESS_NAME').AsString then
      begin
         sProcess := FieldByName('PROCESS_NAME').AsString;
         mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, FieldByName('PROCESS_NAME').AsString);
         mNodeProcess.ImageIndex := 2;
      end;

      with TreePC.Items.AddChild(mNodeProcess, FieldByName('TERMINAL_NAME').AsString) do
      begin
        ImageIndex := 3;
        if FieldByName('TERMINAL_ID').AsString = formMain.G_TerminalID then
        begin
          LabPDLine.Caption := Parent.Parent.Parent.Text;
          LabStage.Caption := Parent.Parent.Text;
          LabProcess.Caption := Parent.Text;
          LabTerminal.Caption := Text;
        end;
      end;
      Next;
    end;
    Close;
  end;
end;

procedure TformConfig.TreePCGetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := Node.Level;
end;

procedure TformConfig.TreePCClick(Sender: TObject);
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

procedure TformConfig.sbtnSaveClick(Sender: TObject);
var
  sPdLineID, sPdLineName : String;
  sProcessID, sProcessName, sProcessCode, sProcessDesc : String;
  sTerminalID, sTerminalName : String;
begin
  if LabTerminal.Caption = '' then
  begin
    MessageDlg('Work Terminal Not Assign !!', mtError, [mbCancel], 0);
    Exit;
  end;

  sPdLineID := '';
  sPdLineName := LabPdLine.Caption;
  if not GetPdLineData(sPdLineName, sPdLineID) then Exit;

  sProcessID := '';
  sProcessName := LabProcess.Caption;
  if not GetProcessData(sProcessName, sProcessID, sProcessCode, sProcessDesc) then Exit;

  sTerminalID := '';
  sTerminalName := LabTerminal.Caption;
  if not GetTerminalData(sTerminalName, sPdLineID, sProcessID, sTerminalID) then Exit;

  with TIniFile.Create('SAJET.ini') do
  begin
    WriteString('TEST FUNCTION', 'FACTORY', FCID);
    WriteString('TEST FUNCTION', 'TERMINAL', sTerminalID);
    Free;
  end;

  formMain.G_TerminalID := sTerminalID;
  formMain.FCID := FCID;
  formMain.GetTerminalID;
  formMain.GetShiftID;
  Close;
end;

function TformConfig.GetPdLineData(PdLineName : String; var PdLineID : String): Boolean;
var
  S : String;
begin
  Result := False;
  with formMain.csFTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'PDLINE_NAME', ptInput);
    CommandText := 'SELECT PDLINE_ID,PDLINE_NAME '+
                   'FROM SAJET.SYS_PDLINE '+
                   'WHERE PDLINE_NAME = :PDLINE_NAME ';
    Params.ParamByName('PDLINE_NAME').AsString := PdLineName;
    Open;
    If RecordCount > 0 Then
    begin
      PdLineID := Fieldbyname('PDLINE_ID').AsString;
    end;
    Close;
  end;

  If PdLineID = '' Then
  begin
    S := 'Production Line data Error !! '+#13#10 +
         'Production Name : '+ PdLineName;
    MessageDlg(S, mtError, [mbCancel],0);
    Exit;
  end;
  Result := True;
end;

function TformConfig.GetProcessData(ProcessName : String; var ProcessID : String; var ProcessCode : String; var ProcessDesc : String): Boolean;
var
  S : String;
begin
  Result := False;
  with formMain.csFTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'PROCESS_NAME', ptInput);
    CommandText := 'SELECT PROCESS_ID, PROCESS_CODE, PROCESS_NAME, PROCESS_DESC '+
                   'FROM SAJET.SYS_PROCESS '+
                   'WHERE PROCESS_NAME = :PROCESS_NAME ';
    Params.ParamByName('PROCESS_NAME').AsString := ProcessName;
    Open;
    If RecordCount > 0 Then
    begin
      ProcessID := Fieldbyname('PROCESS_ID').AsString;
      ProcessCode := Fieldbyname('PROCESS_CODE').AsString;
      ProcessDesc := Fieldbyname('PROCESS_DESC').AsString;
    end;
    Close;
  end;

  If ProcessID = '' Then
  begin
    S := 'Process data Error !! '+#13#10 +
         'Process Name : '+ ProcessName;
    MessageDlg(S, mtError, [mbCancel],0);
    Exit;
  end;
  Result := True;
end;

function TformConfig.GetTerminalData(TerminalName : String; PdLineID : String; ProcessID : String; var TerminalID : String): Boolean;
var
  S : String;
begin
  Result := False;
  with formMain.csFTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'PDLINE_ID', ptInput);
    Params.CreateParam(ftString	,'PROCESS_ID', ptInput);
    Params.CreateParam(ftString	,'TERMINAL_NAME', ptInput);
    CommandText := 'SELECT TERMINAL_ID '+
                   'FROM SAJET.SYS_TERMINAL '+
                   'WHERE PDLINE_ID = :PDLINE_ID AND '+
                         'PROCESS_ID = :PROCESS_ID AND '+
                         'TERMINAL_NAME = :TERMINAL_NAME ';
    Params.ParamByName('PDLINE_ID').AsString := PdLineID;
    Params.ParamByName('PROCESS_ID').AsString := ProcessID;
    Params.ParamByName('TERMINAL_NAME').AsString := TerminalName;
    Open;
    If RecordCount > 0 Then
      TerminalID := Fieldbyname('TERMINAL_ID').AsString;
    Close;
  end;

  If TerminalID = '' Then
  begin
    S := 'Terminal data Error !! '+#13#10 +
         'Terminal Name : '+ TerminalName;
    MessageDlg(S, mtError, [mbCancel],0);
    Exit;
  end;
  Result := True;
end;

procedure TformConfig.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
