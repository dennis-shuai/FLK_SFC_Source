unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IniFiles, StdCtrls, Buttons, Spin, Menus, ExtCtrls, jpeg;

type
  TformMain = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    combLine: TComboBox;
    combShift: TComboBox;
    bbtnQuery: TBitBtn;
    combLineID: TComboBox;
    combShiftID: TComboBox;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    combS1: TComboBox;
    combE1: TComboBox;
    combS2: TComboBox;
    combE2: TComboBox;
    combS3: TComboBox;
    combE3: TComboBox;
    combS4: TComboBox;
    combE4: TComboBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    seditO1: TSpinEdit;
    seditO4: TSpinEdit;
    seditO2: TSpinEdit;
    seditO3: TSpinEdit;
    seditO7: TSpinEdit;
    combP1: TComboBox;
    Label12: TLabel;
    combP2: TComboBox;
    combP3: TComboBox;
    combP4: TComboBox;
    combP5: TComboBox;
    combP6: TComboBox;
    seditH1: TSpinEdit;
    seditH2: TSpinEdit;
    bbtnSave: TBitBtn;
    bbtnCancel: TBitBtn;
    Image1: TImage;
    ImageData: TImage;
    combPID1: TComboBox;
    combPID2: TComboBox;
    combPID3: TComboBox;
    combPID4: TComboBox;
    combPID5: TComboBox;
    combPID6: TComboBox;
    combS5: TComboBox;
    Label13: TLabel;
    combE5: TComboBox;
    seditO5: TSpinEdit;
    combS6: TComboBox;
    Label14: TLabel;
    combE6: TComboBox;
    seditO6: TSpinEdit;
    procedure combLineChange(Sender: TObject);
    procedure combShiftChange(Sender: TObject);
    procedure bbtnQueryClick(Sender: TObject);
    procedure bbtnCancelClick(Sender: TObject);
    procedure bbtnSaveClick(Sender: TObject);
    procedure combP1Change(Sender: TObject);
    procedure combP2Change(Sender: TObject);
    procedure combP3Change(Sender: TObject);
    procedure combP4Change(Sender: TObject);
    procedure combP5Change(Sender: TObject);
    procedure combP6Change(Sender: TObject);
  private
    { Private declarations }
  public
    RecID : Integer;
    procedure InitialForm();
    procedure ClearField;
    function  GetMaxRecID : Integer;
    function  CheckField : Boolean;
    procedure InsertBaseTable(psRecID : String);
    procedure InsertParamTable(psRecID : Integer; psType, psName, psValue : String);
    procedure GetProcess(psLineID : String);
    procedure DisplayHuman(psRecID : Integer);
    procedure DisplayTimeSection(psRecID : Integer);
    procedure DisplayProcess(psRecID : Integer);
    { Public declarations }
  end;

var
  formMain: TformMain;

implementation

uses uDM, DB, DBClient;

{$R *.dfm}

procedure TformMain.ClearField;
begin
  combS1.ItemIndex := 0;
  combS2.ItemIndex := 0;
  combS3.ItemIndex := 0;
  combS4.ItemIndex := 0;
  combS5.ItemIndex := 0;
  combS6.ItemIndex := 0;
  combE1.ItemIndex := 0;
  combE2.ItemIndex := 0;
  combE3.ItemIndex := 0;
  combE4.ItemIndex := 0;
  combE5.ItemIndex := 0;
  combE6.ItemIndex := 0;
  combP1.Items.Clear;
  combP2.Items.Clear;
  combP3.Items.Clear;
  combP4.Items.Clear;
  combP5.Items.Clear;
  combP6.Items.Clear;
  combP1.Items.Add('');
  combP2.Items.Add('');
  combP3.Items.Add('');
  combP4.Items.Add('');
  combP5.Items.Add('');
  combP6.Items.Add('');
  combPID1.Items.Clear;
  combPID2.Items.Clear;
  combPID3.Items.Clear;
  combPID4.Items.Clear;
  combPID5.Items.Clear;
  combPID6.Items.Clear;
  combPID1.Items.Add('');
  combPID2.Items.Add('');
  combPID3.Items.Add('');
  combPID4.Items.Add('');
  combPID5.Items.Add('');
  combPID6.Items.Add('');
  seditO1.Value := 0;
  seditO2.Value := 0;
  seditO3.Value := 0;
  seditO4.Value := 0;
  seditO5.Value := 0;
  seditO6.Value := 0;
  seditO7.Value := 0;
  seditH1.Value := 0;
  seditH2.Value := 0;
  bbtnSave.Enabled := False;
  bbtnCancel.Enabled := False;
  GroupBox1.Enabled := False;
  GroupBox2.Enabled := False;
  GroupBox3.Enabled := False;
end;

procedure TformMain.InitialForm();
begin
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT PDLINE_ID, PDLINE_NAME '
                 + 'FROM   SAJET.SYS_PDLINE '
                 + 'WHERE  ENABLED = ''Y'' ORDER BY PDLINE_NAME ';
    Open;
    First;
    combLine.Items.Clear;
    combLineID.Items.Clear;
    while not Eof do
    begin
      combLine.Items.Add(FieldByName('PDLINE_NAME').AsString);
      combLineID.Items.Add(FieldByName('PDLINE_ID').AsString);
      Next;
    end;
    Close;
    Params.Clear;
    CommandText := 'SELECT SHIFT_ID, SHIFT_NAME '
                 + 'FROM   SAJET.SYS_SHIFT '
                 + 'WHERE  ENABLED = ''Y'' ORDER BY SHIFT_NAME ';
    Open;
    First;
    combShift.Items.Clear;
    combShiftID.Items.Clear;
    while not Eof do
    begin
      combShift.Items.Add(FieldByName('SHIFT_NAME').AsString);
      combShiftID.Items.Add(FieldByName('SHIFT_ID').AsString);
      Next;
    end;
    Close;
  end;
  ClearField;
end;

procedure TformMain.combLineChange(Sender: TObject);
begin
  ClearField;
end;

procedure TformMain.combShiftChange(Sender: TObject);
begin
  ClearField;
end;

procedure TformMain.bbtnQueryClick(Sender: TObject);
begin
  ClearField;
  if (combLine.ItemIndex = -1) or (combShift.ItemIndex = -1) then
    Exit;
  bbtnSave.Enabled := True;
  bbtnCancel.Enabled := True;
  GroupBox1.Enabled := True;
  GroupBox2.Enabled := True;
  GroupBox3.Enabled := True;
  combLineID.ItemIndex := combLine.ItemIndex;
  combShiftID.ItemIndex := combShift.ItemIndex;
  GetProcess(combLineID.Text);
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT REC_ID '
                 + 'FROM   SAJET.SYS_PDLINE_SHIFT_BASE '
                 + 'WHERE  PDLINE_ID  = ' + combLineID.Text
                 + 'AND    SHIFT_ID = ' + combShiftID.Text;
    Open;
    if RecordCount > 0 then
    begin
      RecID := FieldByName('REC_ID').AsInteger;
      DisplayHuman(RecID);
      DisplayTimeSection(RecID);
      DisplayProcess(RecID);
    end else
    begin
      RecID := GetMaxRecID;
      InsertBaseTable(IntToStr(RecID));
    end;
    Close;
  end;
end;

procedure TformMain.DisplayHuman(psRecID : Integer);
begin
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT PARAM_NAME, PARAM_VALUE '
                 + 'FROM   SAJET.SYS_PDLINE_SHIFT_PARAM '
                 + 'WHERE  REC_ID = ' + IntToStr(psRecID) + ' '
                 + 'AND    PARAM_TYPE = ''HUMAN'' '
                 + 'GROUP BY PARAM_NAME, PARAM_VALUE ';
    Open;
    First;
    while not Eof do
    begin
      if FieldByName('PARAM_NAME').AsString = 'NEED' then
        seditH1.Text := FieldByName('PARAM_VALUE').AsString;
      if FieldByName('PARAM_NAME').AsString = 'ACTUAL' then
        seditH2.Text := FieldByName('PARAM_VALUE').AsString;
      Next;
    end;
    Close;
  end;
end;

procedure TformMain.DisplayTimeSection(psRecID : Integer);
var
  i : Integer;
begin
  i := 0;
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT SUBSTR(PARAM_NAME, 4, 1) PARAM_INDEX, PARAM_NAME, PARAM_VALUE '
                 + 'FROM   SAJET.SYS_PDLINE_SHIFT_PARAM '
                 + 'WHERE  REC_ID = ' + IntToStr(psRecID) + ' '
                 + 'AND    PARAM_TYPE = ''TIME'' '
                 + 'GROUP BY SUBSTR(PARAM_NAME, 4, 1), PARAM_NAME, PARAM_VALUE '
                 + 'ORDER BY SUBSTR(PARAM_NAME, 4, 1) ';
    Open;
    First;
    while not Eof do
    begin
      if FieldByName('PARAM_NAME').AsString = 'OVERTIME' then
        seditO7.Text := FieldByName('PARAM_VALUE').AsString
      else
      begin
        Inc(i);
        if i < 7 then
        begin
          if FieldByName('PARAM_INDEX').AsString = '1' then
          begin
            combS1.ItemIndex := combS1.Items.IndexOf(Copy(FieldByName('PARAM_NAME').AsString, 1, 2));
            combE1.ItemIndex := combE1.Items.IndexOf(Copy(FieldByName('PARAM_NAME').AsString, 5, 2));
            seditO1.Text := FieldByName('PARAM_VALUE').AsString;
          end else if FieldByName('PARAM_INDEX').AsString = '2' then
          begin
            combS2.ItemIndex := combS2.Items.IndexOf(Copy(FieldByName('PARAM_NAME').AsString, 1, 2));
            combE2.ItemIndex := combE2.Items.IndexOf(Copy(FieldByName('PARAM_NAME').AsString, 5, 2));
            seditO2.Text := FieldByName('PARAM_VALUE').AsString;
          end else if FieldByName('PARAM_INDEX').AsString = '3' then
          begin
            combS3.ItemIndex := combS3.Items.IndexOf(Copy(FieldByName('PARAM_NAME').AsString, 1, 2));
            combE3.ItemIndex := combE3.Items.IndexOf(Copy(FieldByName('PARAM_NAME').AsString, 5, 2));
            seditO3.Text := FieldByName('PARAM_VALUE').AsString;
          end else if FieldByName('PARAM_INDEX').AsString = '4' then
          begin
            combS4.ItemIndex := combS4.Items.IndexOf(Copy(FieldByName('PARAM_NAME').AsString, 1, 2));
            combE4.ItemIndex := combE4.Items.IndexOf(Copy(FieldByName('PARAM_NAME').AsString, 5, 2));
            seditO4.Text := FieldByName('PARAM_VALUE').AsString;
          end else if FieldByName('PARAM_INDEX').AsString = '5' then
          begin
            combS5.ItemIndex := combS5.Items.IndexOf(Copy(FieldByName('PARAM_NAME').AsString, 1, 2));
            combE5.ItemIndex := combE5.Items.IndexOf(Copy(FieldByName('PARAM_NAME').AsString, 5, 2));
            seditO5.Text := FieldByName('PARAM_VALUE').AsString;
          end else if FieldByName('PARAM_INDEX').AsString = '6' then
          begin
            combS6.ItemIndex := combS6.Items.IndexOf(Copy(FieldByName('PARAM_NAME').AsString, 1, 2));
            combE6.ItemIndex := combE6.Items.IndexOf(Copy(FieldByName('PARAM_NAME').AsString, 5, 2));
            seditO6.Text := FieldByName('PARAM_VALUE').AsString;
          end;
        end;
      end;
      Next;
    end;
    Close;
  end;
end;

procedure TformMain.DisplayProcess(psRecID : Integer);
var
  i : Integer;
begin
  i := 0;
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT B.PROCESS_NAME, B.PROCESS_CODE '
                 + 'FROM   SAJET.SYS_PDLINE_SHIFT_PARAM A, SAJET.SYS_PROCESS B '
                 + 'WHERE  A.REC_ID = ' + IntToStr(psRecID) + ' '
                 + 'AND    A.PARAM_TYPE = ''PROCESS'' '
                 + 'AND    A.PARAM_NAME = B.PROCESS_ID '
                 + 'ORDER BY PROCESS_CODE ';
    Open;
    First;
    while not Eof do
    begin
      Inc(i);
      if i = 1 then
      begin
        combP1.ItemIndex := combP1.Items.IndexOf(FieldByName('PROCESS_NAME').AsString);
        combPID1.ItemIndex := combP1.ItemIndex;
      end else if i = 2 then
      begin
        combP2.ItemIndex := combP2.Items.IndexOf(FieldByName('PROCESS_NAME').AsString);
        combPID2.ItemIndex := combP2.ItemIndex;
      end else if i = 3 then
      begin
        combP3.ItemIndex := combP3.Items.IndexOf(FieldByName('PROCESS_NAME').AsString);
        combPID3.ItemIndex := combP3.ItemIndex;
      end else if i = 4 then
      begin
        combP4.ItemIndex := combP4.Items.IndexOf(FieldByName('PROCESS_NAME').AsString);
        combPID4.ItemIndex := combP4.ItemIndex;
      end else if i = 5 then
      begin
        combP5.ItemIndex := combP5.Items.IndexOf(FieldByName('PROCESS_NAME').AsString);
        combPID5.ItemIndex := combP5.ItemIndex;
      end else if i = 6 then
      begin
        combP6.ItemIndex := combP6.Items.IndexOf(FieldByName('PROCESS_NAME').AsString);
        combPID6.ItemIndex := combP6.ItemIndex;
      end;
      Next;
    end;
    Close;
  end;
end;

function TformMain.GetMaxRecID : Integer;
begin
  Result := 1;
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT DECODE(MAX(REC_ID), NULL, 1, MAX(REC_ID)+1) NEW_REC_ID '
                 + 'FROM   SAJET.SYS_PDLINE_SHIFT_BASE ';
    Open;
    if RecordCount > 0 then
      Result := FieldByName('NEW_REC_ID').AsInteger;
    Close;
  end;
end;

procedure TformMain.InsertBaseTable(psRecID : String);
begin
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'INSERT INTO SAJET.SYS_PDLINE_SHIFT_BASE '
                 + '(REC_ID, PDLINE_ID, SHIFT_ID) VALUES '
                 + '(' + psRecID + ',' + combLineID.Text + ',' + combShiftID.Text + ')';
    Execute;
    Close;
  end;
end;

procedure TformMain.InsertParamTable(psRecID : Integer; psType, psName, psValue : String);
begin
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'INSERT INTO SAJET.SYS_PDLINE_SHIFT_PARAM '
                 + '(REC_ID, PARAM_TYPE, PARAM_NAME, PARAM_VALUE) VALUES '
                 + '(' + IntToStr(psRecID) + ',''' + psType + ''',''' + psName + ''',''' + psValue + ''')';
    Execute;
    Close;
  end;
end;

procedure TformMain.GetProcess(psLineID : String);
begin
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT B.PROCESS_NAME, B.PROCESS_ID, B.PROCESS_CODE '
                 + 'FROM   SAJET.SYS_TERMINAL A, SAJET.SYS_PROCESS B '
                 + 'WHERE  A.PDLINE_ID = ' + psLineID
                 + 'AND    A.PROCESS_ID = B.PROCESS_ID '
                 + 'AND    B.ENABLED = ''Y'' '
                 + 'GROUP BY B.PROCESS_NAME, B.PROCESS_ID, B.PROCESS_CODE '
                 + 'ORDER BY B.PROCESS_CODE';
    Open;
    First;
    while not Eof do
    begin
      combP1.Items.Add(FieldByName('PROCESS_NAME').AsString);
      combP2.Items.Add(FieldByName('PROCESS_NAME').AsString);
      combP3.Items.Add(FieldByName('PROCESS_NAME').AsString);
      combP4.Items.Add(FieldByName('PROCESS_NAME').AsString);
      combP5.Items.Add(FieldByName('PROCESS_NAME').AsString);
      combP6.Items.Add(FieldByName('PROCESS_NAME').AsString);
      combPID1.Items.Add(FieldByName('PROCESS_ID').AsString);
      combPID2.Items.Add(FieldByName('PROCESS_ID').AsString);
      combPID3.Items.Add(FieldByName('PROCESS_ID').AsString);
      combPID4.Items.Add(FieldByName('PROCESS_ID').AsString);
      combPID5.Items.Add(FieldByName('PROCESS_ID').AsString);
      combPID6.Items.Add(FieldByName('PROCESS_ID').AsString);
      Next;
    end;
    Close;
  end;
end;

procedure TformMain.bbtnCancelClick(Sender: TObject);
begin
  ClearField;
end;

function TformMain.CheckField : Boolean;
begin
  Result := False;
  if (seditH1.Value = 0) or (seditH2.Value = 0) then
  begin
    ShowMessage('Human Resource Setup Not Completed !!');
    Exit;
  end;
  Result := True;
end;

procedure TformMain.bbtnSaveClick(Sender: TObject);
begin
  if not CheckField then
    Exit;
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'DELETE SAJET.SYS_PDLINE_SHIFT_PARAM '
                 + 'WHERE  REC_ID = ' + IntToStr(RecID);
    Execute;
    Close;
  end;
  InsertParamTable(RecID, 'HUMAN', 'NEED', seditH1.Text);
  InsertParamTable(RecID, 'HUMAN', 'ACTUAL', seditH2.Text);
  InsertParamTable(RecID, 'TIME', combS1.Text + 'T1' + combE1.Text, seditO1.Text);
  InsertParamTable(RecID, 'TIME', combS2.Text + 'T2' + combE2.Text, seditO2.Text);
  InsertParamTable(RecID, 'TIME', combS3.Text + 'T3' + combE3.Text, seditO3.Text);
  InsertParamTable(RecID, 'TIME', combS4.Text + 'T4' + combE4.Text, seditO4.Text);
  InsertParamTable(RecID, 'TIME', combS5.Text + 'T5' + combE5.Text, seditO5.Text);
  InsertParamTable(RecID, 'TIME', combS6.Text + 'T6' + combE6.Text, seditO6.Text);
  InsertParamTable(RecID, 'TIME', 'OVERTIME', seditO7.Text);
  if combP1.Text <> '' then
    InsertParamTable(RecID, 'PROCESS', combPID1.Text, 'Y');
  if combP2.Text <> '' then
    InsertParamTable(RecID, 'PROCESS', combPID2.Text, 'Y');
  if combP3.Text <> '' then
    InsertParamTable(RecID, 'PROCESS', combPID3.Text, 'Y');
  if combP4.Text <> '' then
    InsertParamTable(RecID, 'PROCESS', combPID4.Text, 'Y');
  if combP5.Text <> '' then
    InsertParamTable(RecID, 'PROCESS', combPID5.Text, 'Y');
  if combP6.Text <> '' then
    InsertParamTable(RecID, 'PROCESS', combPID6.Text, 'Y');
  ShowMessage('Parameter Setup OK !!');
end;

procedure TformMain.combP1Change(Sender: TObject);
begin
   combPID1.ItemIndex := combP1.ItemIndex;
end;

procedure TformMain.combP2Change(Sender: TObject);
begin
   combPID2.ItemIndex := combP2.ItemIndex;
end;

procedure TformMain.combP3Change(Sender: TObject);
begin
   combPID3.ItemIndex := combP3.ItemIndex;
end;

procedure TformMain.combP4Change(Sender: TObject);
begin
   combPID4.ItemIndex := combP4.ItemIndex;
end;

procedure TformMain.combP5Change(Sender: TObject);
begin
   combPID5.ItemIndex := combP5.ItemIndex;
end;

procedure TformMain.combP6Change(Sender: TObject);
begin
   combPID6.ItemIndex := combP6.ItemIndex;
end;

end.
