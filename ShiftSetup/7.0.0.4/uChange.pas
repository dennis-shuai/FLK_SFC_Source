unit uChange;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, jpeg;

type
  TformChangeShift = class(TForm)
    Label1: TLabel;
    combLine: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    bbtnOK: TBitBtn;
    bbtnCancel: TBitBtn;
    combShift: TComboBox;
    panlShift: TPanel;
    panlTime: TPanel;
    combLineID: TComboBox;
    combShiftID: TComboBox;
    ImageData: TImage;
    procedure bbtnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure combLineChange(Sender: TObject);
    procedure combShiftChange(Sender: TObject);
    procedure bbtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    sRecID : Integer;
    procedure GetShift;
    procedure UpdateFlag;
    procedure InsertLog;
    procedure InsertBaseTable(psRecID : String);
    function  GetRecID: Integer;
    function  GetMaxRecID : Integer;
    { Public declarations }
  end;

var
  formChangeShift: TformChangeShift;

implementation

uses uDM, DB;

{$R *.dfm}

procedure TformChangeShift.bbtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TformChangeShift.FormShow(Sender: TObject);
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
    if RecordCount > 0 then
      combLine.ItemIndex := 0
    else
      combLine.ItemIndex := -1;
    Close;
  end;
  combLineChange(Self);
end;

procedure TformChangeShift.combLineChange(Sender: TObject);
begin
  combLineID.ItemIndex := combLine.ItemIndex;
  panlShift.Caption := '';
  panlTime.Caption := '';
  combShift.Items.Clear;
  combShiftID.Items.Clear;
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT C.SHIFT_NAME, MAX(B.UPDATE_TIME) UPDATE_TIME '
                 + 'FROM   SAJET.SYS_PDLINE_SHIFT_BASE A, '
                 + '       SAJET.SYS_PDLINE_SHIFT_LOG B, SAJET.SYS_SHIFT C '
                 + 'WHERE  A.PDLINE_ID = ' + combLineID.Text
                 + 'AND    A.ACTIVE_FLAG = ''Y'' '
                 + 'AND    A.REC_ID = B.REC_ID '
                 + 'AND    A.SHIFT_ID = C.SHIFT_ID '
                 + 'GROUP BY C.SHIFT_NAME ';
    Open;
    if RecordCount > 0 then
    begin
      panlShift.Caption := FieldByName('SHIFT_NAME').AsString;
      panlTime.Caption := FieldByName('UPDATE_TIME').AsString;
    end else
    begin
      panlShift.Caption := '©|¥¼³]©w';
      panlTime.Caption := '';
    end;
  end;
  GetShift;
end;

procedure TformChangeShift.GetShift;
begin
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT SHIFT_ID, SHIFT_NAME '
                 + 'FROM   SAJET.SYS_SHIFT '
                 + 'WHERE  ENABLED = ''Y'' ORDER BY SHIFT_NAME ';
    Open;
    First;
    while not Eof do
    begin
      if FieldByName('SHIFT_NAME').AsString <> panlShift.Caption then 
      begin
        combShift.Items.Add(FieldByName('SHIFT_NAME').AsString);
        combShiftID.Items.Add(FieldByName('SHIFT_ID').AsString);
      end;
      Next;
    end;
    Close;
  end;
  if combShift.Items.Count > 0 then
    combShift.ItemIndex := 0;
  combShiftChange(Self);
end;

procedure TformChangeShift.combShiftChange(Sender: TObject);
begin
  combShiftID.ItemIndex := combShift.ItemIndex; 
end;

procedure TformChangeShift.bbtnOKClick(Sender: TObject);
begin
  if (combLine.ItemIndex = -1) or (combShift.ItemIndex = -1) then
    Exit;
  sRecID := GetRecID;
  if sRecID = -1 then
  begin
    sRecID := GetMaxRecID;
    InsertBaseTable(IntToStr(sRecID));
  end;
  UpdateFlag;
  InsertLog;
  ShowMessage('Change Shift OK !!');
  combLineChange(Self); 
end;

procedure TformChangeShift.UpdateFlag;
begin
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'UPDATE SAJET.SYS_PDLINE_SHIFT_BASE '
                 + 'SET    ACTIVE_FLAG = ''N'' '
                 + 'WHERE  PDLINE_ID = ' + combLineID.Text;
    Execute;
    Close;
    Params.Clear;
    CommandText := 'UPDATE SAJET.SYS_PDLINE_SHIFT_BASE '
                 + 'SET    ACTIVE_FLAG = ''Y'' '
                 + 'WHERE  PDLINE_ID = ' + combLineID.Text
                 + 'AND    SHIFT_ID = ' + combShiftID.Text;
    Execute;
    Close;
  end;
end;

procedure TformChangeShift.InsertLog;
var
  sSQL : String;
begin
  sSQL := 'INSERT INTO SAJET.SYS_PDLINE_SHIFT_LOG '
        + '(REC_ID, UPDATE_USERID, UPDATE_TIME) VALUES '
        + '(' + IntToStr(sRecID) + ', 0, SYSDATE) ';
  with dmProject.cdsTemp do
  begin
    Close;
    Params.Clear;
    CommandText := sSQL;
    Execute;
    Close;
  end;
end;

function TformChangeShift.GetRecID: Integer;
begin
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
      Result := FieldByName('REC_ID').AsInteger
    else
      Result := -1;
    Close;
  end;
end;

procedure TformChangeShift.InsertBaseTable(psRecID : String);
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

function TformChangeShift.GetMaxRecID : Integer;
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

end.
