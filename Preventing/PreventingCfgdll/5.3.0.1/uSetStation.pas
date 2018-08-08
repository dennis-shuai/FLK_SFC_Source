unit uSetStation;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ComCtrls, StdCtrls, Buttons, ExtCtrls, DB, IniFiles;

type
  TfStation = class(TForm)
    TreePC: TTreeView;
    Image1: TImage;
    sbtnClose: TSpeedButton;
    sbtnSave: TSpeedButton;
    Label4: TLabel;
    Image2: TImage;
    Label3: TLabel;
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
    cmbOpType: TComboBox;
    Label7: TLabel;
    cmbOpid: TComboBox;
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
    procedure TreePCClick(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure TreePCGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure cmbOpTypeChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FcID : String;
    Procedure ShowTerminal;
    Function  GetPdLineData(PdLineName : String; var PdLineID : String): Boolean;
    Function  GetProcessData(ProcessName : String; var ProcessID : String; var ProcessCode : String; var ProcessDesc : String): Boolean;
    Function  GetTerminalData(TerminalName : String; PdLineID : String; ProcessID : String; var TerminalID : String): Boolean;
    procedure ShowOperateType;
  end;

var
  fStation: TfStation;

implementation

{$R *.DFM}
Uses uData;

Procedure TfStation.ShowTerminal;
var sLine,sStage,sProcess : string;
    mNodeLine,mNodeStage,mNodeProcess, mNode, mCurrentNode: TTreeNode;
begin

  LabPDLine.Caption := '';
  LabStage.Caption := '';
  LabProcess.Caption := '';
  LabTerminal.Caption := '';
  
  TreePC.Items.Clear;
  With fData.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'FCID', ptInput);
   // Params.CreateParam(ftString	,'TYPENAME1', ptInput);
    Params.CreateParam(ftString	,'OPERATEID1', ptInput);
    //Params.CreateParam(ftString	,'OPERATEID2', ptInput);
    CommandText := 'Select PDLINE_NAME,STAGE_CODE,STAGE_NAME,PROCESS_CODE,PROCESS_NAME,TERMINAL_ID,TERMINAL_NAME '+
                   'From SAJET.SYS_TERMINAL A, '+
                        'SAJET.SYS_PDLINE B, '+
                        'SAJET.SYS_STAGE C, '+
                        'SAJET.SYS_PROCESS D '+
                       // 'SAJET.SYS_OPERATE_TYPE E '+
                   'Where B.FACTORY_ID = :FCID and '+
                         'A.PDLINE_ID = B.PDLINE_ID and '+
                         'A.STAGE_ID = C.STAGE_ID and '+
                         'A.PROCESS_ID = D.PROCESS_ID and '+
                         //'D.OPERATE_ID = E.OPERATE_ID and '+
                        // 'E.TYPE_NAME = :TYPENAME1 and '+
                         'D.OPERATE_ID = :OPERATEID1  AND '+
                         'A.ENABLED = ''Y'' and '+
                         'B.ENABLED = ''Y'' and '+
                         'C.ENABLED = ''Y'' and '+
                         'D.ENABLED = ''Y'' '+
                   'Order By PDLINE_NAME,STAGE_CODE,STAGE_NAME,PROCESS_CODE,PROCESS_NAME,TERMINAL_NAME ';
    Params.ParamByName('FCID').AsString := FcID;
   // Params.ParamByName('TYPENAME1').AsString := 'Input';
    Params.ParamByName('OPERATEID1').AsString := trim(cmbOpId.Text);
  //  Params.ParamByName('OPERATEID2').AsString := '6';
    Open;
    if RecordCount > 0 then
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

     While not Eof do
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

        With TreePC.Items.AddChild(mNodeProcess, FieldByName('TERMINAL_NAME').asstring) do
        begin
           ImageIndex := 3;
           If FieldByName('TERMINAL_ID').asstring = fData.TerminalID Then
           begin
              LabPDLine.Caption := Parent.Parent.Parent.Text;
              LabStage.Caption := Parent.Parent.Text;
              LabProcess.Caption := Parent.Text;
              LabTerminal.Caption := Text;
           end;
        end;
        next;
     end;
    Close;
    mNodeLine := nil;
    mNodeStage := nil;
    mNodeProcess := nil;
  end;
end;

Function TfStation.GetTerminalData(TerminalName : String; PdLineID : String; ProcessID : String; var TerminalID : String): Boolean;
Var S : String;
begin
  Result := False;
  With fData.QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'PDLINE_ID', ptInput);
     Params.CreateParam(ftString	,'PROCESS_ID', ptInput);
     Params.CreateParam(ftString	,'TERMINAL_NAME', ptInput);
     CommandText := 'Select TERMINAL_ID '+
                    'From SAJET.SYS_TERMINAL '+
                    'Where PDLINE_ID = :PDLINE_ID and '+
                          'PROCESS_ID = :PROCESS_ID and '+
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
     MessageDlg(S,mtError, [mbCancel],0);
     Exit;
  end;
  Result := True;
end;

procedure TfStation.sbtnCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TfStation.FormShow(Sender: TObject);
Var S : String;
begin
  cmbFactory.Items.Clear;
  TreePC.Items.Clear;
  LabPDLine.Caption := '';
  LabStage.Caption := '';
  LabProcess.Caption := '';
  LabTerminal.Caption := '';

  S := '';
  With fData.QryTemp do
  begin
     Close;
     Params.Clear;
     CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME '+
                    'From SAJET.SYS_FACTORY '+
                    'Where ENABLED = ''Y'' ';
     Open;
     While Not Eof do
     begin
        cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString);
        If Fieldbyname('FACTORY_ID').AsString = fData.FCID Then
           S := Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString;
        Next;
     end;
     Close;
  end;

  showOperateType;
  if fData.cmbTypeID <> '' then
  begin
    cmbOpType.ItemIndex := cmbOpid.Items.IndexOf(fData.cmbTypeID);
    cmbOpid.ItemIndex := cmbOpid.Items.IndexOf(fData.cmbTypeID);
  end;

  If S <> '' Then
  begin
     cmbFactory.ItemIndex := cmbFactory.Items.IndexOf(S);
     cmbFactoryChange(Self);
     Exit;
  end;

  If cmbFactory.Items.Count = 1 Then
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

  With fData.QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'FACTORYCODE', ptInput);
     CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC '+
                    'From SAJET.SYS_FACTORY '+
                    'Where FACTORY_CODE = :FACTORYCODE ';
     Params.ParamByName('FACTORYCODE').AsString := Copy(cmbFactory.Text,1,POS(' ',cmbFactory.Text)-1) ;
     Open;
     If RecordCount > 0 Then
        FcID := Fieldbyname('FACTORY_ID').AsString;
     Close;
  end;

  ShowTerminal;
end;

Function TfStation.GetPdLineData(PdLineName : String; var PdLineID : String): Boolean;
Var S : String;
begin
  Result := False;
  With fData.QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'PDLINE_NAME', ptInput);
     CommandText := 'Select PDLINE_ID,PDLINE_NAME '+
                    'From SAJET.SYS_PDLINE '+
                    'Where PDLINE_NAME = :PDLINE_NAME ';
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
     MessageDlg(S,mtError, [mbCancel],0);
     Exit;
  end;
  Result := True;
end;

Function TfStation.GetProcessData(ProcessName : String; var ProcessID : String; var ProcessCode : String; var ProcessDesc : String): Boolean;
Var S : String;
begin
  Result := False;
  With fData.QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'PROCESS_NAME', ptInput);
     CommandText := 'Select PROCESS_ID,PROCESS_CODE,PROCESS_NAME,PROCESS_DESC '+
                    'From SAJET.SYS_PROCESS '+
                    'Where PROCESS_NAME = :PROCESS_NAME ';
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
     MessageDlg(S,mtError, [mbCancel],0);
     Exit;
  end;
  Result := True;
end;

procedure TfStation.TreePCClick(Sender: TObject);
begin
  If TreePC.Selected = nil Then Exit;

  LabPDLine.Caption := '';
  LabStage.Caption := '';
  LabProcess.Caption := '';
  LabTerminal.Caption := '';

  If TreePC.Selected.Level <> 3 Then Exit;

  LabPDLine.Caption := TreePC.Selected.Parent.Parent.Parent.Text;
  LabStage.Caption := TreePC.Selected.Parent.Parent.Text;
  LabProcess.Caption := TreePC.Selected.Parent.Text;
  LabTerminal.Caption := TreePC.Selected.Text;
end;

procedure TfStation.sbtnSaveClick(Sender: TObject);
Var sPdLineID,sPdLineName : String;
    sProcessID,sProcessName,sProcessCode,sProcessDesc : String;
    sTerminalID,sTerminalName : String;
    S : String;
begin
  If LabTerminal.Caption = '' Then
  begin
     MessageDlg('Work Terminal Not Assign !! ',mtError, [mbCancel],0);
     Exit;
  end;

  if cmbOpType.ItemIndex = 0 then
  begin
     MessageDlg('Operate Type Not Assign !! ',mtError, [mbCancel],0);
     Exit;
  end;

  sPdLineID := '';
  sPdLineName := LabPdLine.Caption;
  If not GetPdLineData(sPdLineName,sPdLineID) Then
     Exit;

  sProcessID := '';
  sProcessName := LabProcess.Caption;
  If not GetProcessData(sProcessName,sProcessID,sProcessCode,sProcessDesc) Then
     Exit;

  sTerminalID := '';
  sTerminalName := LabTerminal.Caption;
  If not GetTerminalData(sTerminalName, sPdLineID, sProcessID, sTerminalID) Then
     Exit;

  With TIniFile.Create('SAJET.ini') do
  begin
     WriteString('System','Factory', FCID);
     WriteString('Preventing','Terminal',sTerminalID);
     WriteString('Preventing','TypeID',trim(cmbOpid.Text));
     Free;
  end;

  fData.TerminalID := sTerminalID;
  fData.FcID := FCID;
  Close;

end;

procedure TfStation.TreePCGetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := Node.Level;
end;

procedure TfStation.ShowOperateType;
begin
  cmbOpType.Items.Clear;
  cmbOpId.Items.Clear;
  With fData.QryTemp do
  begin
     Close;
     Params.Clear;
     CommandText := 'Select operate_id,Type_name from sajet.sys_operate_type ';
     Open;
     If RecordCount > 0 Then
     begin
        cmbOpType.Items.Add('Not Assigned ');
        cmbOpid.Items.Add('0');
        while not eof do
        begin
           cmbOpType.Items.Add(Fieldbyname('Type_name').AsString);
           cmbOpid.Items.Add(Fieldbyname('operate_id').AsString);
           next;
        end;
     end;
     Close;
  end;
end;

procedure TfStation.cmbOpTypeChange(Sender: TObject);
begin
  cmbOpID.ItemIndex := cmbOpType.ItemIndex;
  showTerminal;
end;

end.
