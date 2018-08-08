unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, StdCtrls, DB, DBClient, MConnect, ObjBrkr,
  SConnect, Buttons, IniFiles;

type
  TformMain = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    ImageFunction: TImage;
    ImageTitle: TImage;
    ImageData: TImage;
    Label2: TLabel;
    Label22: TLabel;
    LabNo: TLabel;
    LabName: TLabel;
    Label11: TLabel;
    SocketConnection1: TSocketConnection;
    SimpleObjectBroker1: TSimpleObjectBroker;
    csFTemp: TClientDataSet;
    Label7: TLabel;
    Label19: TLabel;
    sbtnConfiguration: TSpeedButton;
    Label1: TLabel;
    Label3: TLabel;
    sbtnTestProcess: TSpeedButton;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    lablLine: TLabel;
    lablStage: TLabel;
    lablProcess: TLabel;
    lablTerminal: TLabel;
    lablInput: TLabel;
    csFTemp1: TClientDataSet;
    SProc: TClientDataSet;
    Label9: TLabel;
    lablShift: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnTestProcessClick(Sender: TObject);
    procedure sbtnConfigurationClick(Sender: TObject);
  private
    { Private declarations }
  public
    LoginUserID, LoginUserNO : String;
    FCID, G_TerminalID, G_ProcessID, G_StageID, G_LineID, G_ShiftID : String;
    function  LoadApServer : Boolean;
    procedure ChkAuthority(PrgName : String);
    procedure GetTerminalID;
    procedure GetShiftID;
    { Public declarations }
  end;

var
  formMain: TformMain;
                                               
implementation

uses uConfig, uTest;

{$R *.dfm}

procedure TformMain.FormCreate(Sender: TObject);
begin
  LoginUserID := ParamStr(1);
end;

function TformMain.LoadApServer : Boolean;
var
  F : TextFile;
  S : String;
begin
  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  If not FileExists(GetCurrentDir+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,GetCurrentDir+'\ApServer.cfg');
  Reset(F);
  While True do
  begin
    Readln(F, S);
    If S <> '' Then
    begin
      SimpleObjectBroker1.Servers.Add;
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
    end Else
      Break;
  end;
  CloseFile(F);
  Result := True;
end;

procedure TformMain.FormShow(Sender: TObject);
begin
  LoadApServer;
  LabNO.Caption := '';
  LabName.Caption := '';
  with csFTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'EMP_ID', ptInput);
    CommandText := 'SELECT EMP_NO, EMP_NAME, PASSWD, ENABLED '+
                   '  FROM SAJET.SYS_EMP '+
                   ' WHERE UPPER(EMP_ID) = :EMP_ID ';
    Params.ParamByName('EMP_ID').AsString := UpperCase(Trim(LoginUserID)) ;
    Open;
    if RecordCount > 0 Then
    begin
      LabNO.Caption := Fieldbyname('EMP_NO').AsString;
      LabName.Caption := Fieldbyname('EMP_NAME').AsString;
      LoginUserNO := Fieldbyname('EMP_NO').AsString;
    end else
    begin
      // 檢查是否為系統使用者
      if LoginUserID <> 'Steven&Jack&Tommy' Then
      begin
        Close;
        MessageDlg('Login User Not Found !!', mtError, [mbCancel], 0);
      end;
      LabNO.Caption := 'Administrator';
      LabName.Caption := '';
      Close;
    end;
  end;
  ChkAuthority('PrintReplaceLable');
  GetTerminalID;
  GetShiftID;
end;

procedure TformMain.ChkAuthority(PrgName : String);
begin
  with csFTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'EMP_ID', ptInput);
    Params.CreateParam(ftString	,'PRG', ptInput);
    CommandText := 'SELECT FUNCTION '+
                   'FROM SAJET.SYS_EMP_PRIVILEGE '+
                   'WHERE EMP_ID = :EMP_ID AND '+
                         'PROGRAM = :PRG '+
                   'GROUP BY FUNCTION';
    Params.ParamByName('EMP_ID').AsString := UpperCase(Trim(LoginUserID)) ;
    Params.ParamByName('PRG').AsString := PrgName;
    Open;

    sbtnConfiguration.Enabled := Locate('FUNCTION','Configuration',[]);
    Label7.Enabled := sbtnConfiguration.Enabled;
    Label19.Enabled := sbtnConfiguration.Enabled;

    sbtnTestProcess.Enabled := Locate('FUNCTION','Execute',[]);
    Label1.Enabled := sbtnTestProcess.Enabled;
    Label3.Enabled := sbtnTestProcess.Enabled;

    Close;

    Params.Clear;
    Params.CreateParam(ftString	,'EMP_ID', ptInput);
    Params.CreateParam(ftString	,'PRG', ptInput);
    CommandText := 'SELECT FUNCTION '+
                   'FROM SAJET.SYS_ROLE_PRIVILEGE A, '+
                        'SAJET.SYS_ROLE_EMP B '+
                   'WHERE A.ROLE_ID = B.ROLE_ID AND '+
                         'EMP_ID = :EMP_ID AND '+
                         'PROGRAM = :PRG '+
                   'GROUP BY FUNCTION';
    Params.ParamByName('EMP_ID').AsString := UpperCase(Trim(LoginUserID)) ;
    Params.ParamByName('PRG').AsString := PrgName;
    Open;

    if not sbtnConfiguration.Enabled Then
    begin
      sbtnConfiguration.Enabled := Locate('FUNCTION','Configuration',[]);
      Label7.Enabled := sbtnConfiguration.Enabled;
      Label19.Enabled := sbtnConfiguration.Enabled;
    end;

    if not sbtnTestProcess.Enabled Then
    begin
      sbtnTestProcess.Enabled := Locate('FUNCTION','Execute',[]);
      Label1.Enabled := sbtnTestProcess.Enabled;
      Label3.Enabled := sbtnTestProcess.Enabled;
    end;

    Close;
  end;
end;

procedure TformMain.GetTerminalID;
begin
  with TIniFile.Create('SAJET.ini') do
  begin
    FCID := ReadString('TEST FUNCTION', 'FACTORY', '');
    G_TerminalID := ReadString('TEST FUNCTION', 'TERMINAL', '');
    Free;
  end;

  with csFTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'TERMINALID', ptInput);
    CommandText := 'SELECT A.TERMINAL_NAME, B.PROCESS_NAME, B.PROCESS_ID, C.STAGE_NAME, '+
                   '       C.STAGE_ID, D.PDLINE_NAME, D.PDLINE_ID '+
                   'FROM   SAJET.SYS_TERMINAL A, SAJET.SYS_PROCESS B, '+
                   '       SAJET.SYS_STAGE C, SAJET.SYS_PDLINE D '+
                   'WHERE  A.TERMINAL_ID = :TERMINALID '+
                   'AND    A.ENABLED = ''Y'' '+
                   'AND    A.PROCESS_ID = B.PROCESS_ID '+
                   'AND    A.STAGE_ID = C.STAGE_ID '+
                   'AND    A.PDLINE_ID = D.PDLINE_ID ';
    Params.ParamByName('TERMINALID').AsString := G_TerminalID;
    Open;
    if RecordCount <= 0 Then
    begin
      lablLine.Caption := 'Not Define';
      lablStage.Caption := 'Not Define';
      lablProcess.Caption := 'Not Define';
      lablTerminal.Caption := 'Not Define';
      G_ProcessID := '';
      G_StageID := '';
      G_LineID := '';
    end else
    begin
      lablLine.Caption := FieldByName('PDLINE_NAME').AsString;
      lablStage.Caption := FieldByName('STAGE_NAME').AsString;
      lablProcess.Caption := FieldByName('PROCESS_NAME').AsString;
      lablTerminal.Caption := FieldByName('TERMINAL_NAME').AsString;
      G_ProcessID := FieldByName('PROCESS_ID').AsString;
      G_StageID := FieldByName('STAGE_ID').AsString;
      G_LineID := FieldByName('PDLINE_ID').AsString;
    end;
    Close;
  end;
end;

procedure TformMain.GetShiftID;
begin
  with csFTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'PDLINE_ID', ptInput);
    CommandText := 'SELECT B.SHIFT_ID, B.SHIFT_NAME '+
                   'FROM   SAJET.SYS_PDLINE_SHIFT_BASE A, SAJET.SYS_SHIFT B '+
                   'WHERE  A.PDLINE_ID = :PDLINE_ID '+
                   'AND    A.SHIFT_ID = B.SHIFT_ID ';
    Params.ParamByName('PDLINE_ID').AsString := G_LineID;
    Open;
    if RecordCount <= 0 Then
    begin
      lablShift.Caption := 'Not Define';
      G_ShiftID := '';
    end else
    begin
      lablShift.Caption := FieldByName('SHIFT_NAME').AsString;
      G_ShiftID := FieldByName('SHIFT_ID').AsString;
    end;
    Close;
  end;
end;

procedure TformMain.sbtnTestProcessClick(Sender: TObject);
begin
  if (G_TerminalID = '') or (G_ProcessID = '') or (G_StageID = '') or (G_LineID = '') then
  begin
    MessageDlg('Terminal not be assign !!', mtError, [mbCancel], 0);
    Exit;
  end;
  if (G_ShiftID = '') then
  begin
    MessageDlg('Shift not be assign !!', mtError, [mbCancel], 0);
    Exit;
  end;
  formTest.Close;
  formConfig.Close;
  with formTest do
  begin
    Parent := Panel4;
    Align := alClient;
    BorderStyle := bsNone;
    Image1.Picture := Self.ImageData.Picture;
    Show;
  end;
end;

procedure TformMain.sbtnConfigurationClick(Sender: TObject);
begin
  formTest.Close;
  formConfig.Close;
  with formConfig do
  begin
    Parent := Panel4;
    Align := alClient;
    BorderStyle := bsNone;
    Image1.Picture := Self.ImageData.Picture;
    Show;
  end;
end;

end.
