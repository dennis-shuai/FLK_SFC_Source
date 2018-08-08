unit uTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, DB, Grids, Clrgrid, Buttons;

type
  TformTest = class(TForm)
    Image1: TImage;
    editWO: TEdit;
    lablWO: TLabel;
    csData: TColorStringGrid;
    Label1: TLabel;
    editPanel: TEdit;
    Label2: TLabel;
    editSN: TEdit;
    bbtnConfirm: TBitBtn;
    panlMessage: TLabel;
    procedure FormShow(Sender: TObject);
    procedure editWOKeyPress(Sender: TObject; var Key: Char);
    procedure editPanelKeyPress(Sender: TObject; var Key: Char);
    procedure editSNKeyPress(Sender: TObject; var Key: Char);
    procedure bbtnConfirmClick(Sender: TObject);
  private
    { Private declarations }
  public
    G_ModelID, G_PartVersion : String;
    procedure ClearGrid;
    FUNCTION GetWOModel(wo:string):string;
    function CheckPartSN(psPartSN : String) : Boolean;
    function CheckSN(psSN : String) : Boolean;
    { Public declarations }
  end;

var
  G_Now : TDateTime;
  formTest: TformTest;

implementation

uses uMain;

{$R *.dfm}

FUNCTION TformTest.GetWOModel(wo:string):string;
begin
 with formMain.csFTemp1 do
 begin
   close;
   params.clear;
   Params.CreateParam(ftString	,'iWO', ptInput);
   commandtext:='select * from sajet.g_wo_base where work_order=:iWO and rownum=1 ';
   Params.ParamByName('iWO').AsString :=wo;
   open;
   result:=fieldbyname('Model_id').AsString;
 end;
end;

procedure TformTest.ClearGrid;
var
  i : Integer;
begin
  for i := 0 to csData.RowCount - 1 do
    csData.Rows[i].Clear;
  csData.RowCount := 2;
  csData.Cells[0, 0] := 'Keyparts SN';
  csData.Cells[1, 0] := 'Serial Number';
end;

procedure TformTest.FormShow(Sender: TObject);
begin
  ClearGrid;
  editWO.Text := '';
  editPanel.Text := '';
  editSN.Text := '';
  editWO.SetFocus;
  editWO.SelectAll;
  editPanel.Enabled := False;
  editSN.Enabled := False;
end;

procedure TformTest.editWOKeyPress(Sender: TObject; var Key: Char);
begin
  ClearGrid;
  editPanel.Text := '';
  editSN.Text := '';
  editPanel.Enabled := False;
  editSN.Enabled := False;
  if Key <> #13 then Exit;
  with formMain.Sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_WO_INPUT');
      FetchParams;
      Params.ParamByName('TREV').AsString := editWO.Text;
      Execute;
      panlMessage.Caption := Params.ParamByName('TRES').AsString;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        panlMessage.Font.Color := clBlue;
        editPanel.Enabled := True;
        editPanel.SetFocus;
        editPanel.SelectAll;
      end else
      begin
        panlMessage.Font.Color := clRed;
        MessageBeep(48);
        editWO.SetFocus;
        editWO.SelectAll;
      end;
    finally
      Close;
    end;
  end;
end;

function TformTest.CheckPartSN(psPartSN : String) : Boolean;
begin
  Result := False;
  with formMain.csFTemp1 do
  begin
    try
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'ITEM_PART_SN', ptInput);
      CommandText := 'SELECT ITEM_PART_SN FROM SAJET.G_SN_KEYPARTS '+
                     ' WHERE ITEM_PART_SN = :ITEM_PART_SN ';
      Params.ParamByName('ITEM_PART_SN').AsString := psPartSN;
      Open;
      if RecordCount = 0 then
        Result := True;
    finally
      Close;
    end;
  end;
end;

function TformTest.CheckSN(psSN : String) : Boolean;
begin
  Result := False;
  with formMain.csFTemp1 do
  begin
    try
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'SERIAL_NUMBER', ptInput);
      CommandText := 'SELECT SERIAL_NUMBER FROM SAJET.G_SN_STATUS '+
                     ' WHERE SERIAL_NUMBER = :SERIAL_NUMBER ';
      Params.ParamByName('SERIAL_NUMBER').AsString := psSN;
      Open;
      if RecordCount = 0 then
        Result := True;
    finally
      Close;
    end;
  end;
end;

procedure TformTest.editPanelKeyPress(Sender: TObject; var Key: Char);
begin
  ClearGrid;
  editSN.Text := '';
  if Key <> #13 then Exit;
  if Trim(editPanel.Text) = '' then Exit;
  if Trim(editPanel.Text) = 'N/A' then Exit;
  with formMain.csFTemp do
  begin
    try
      Close;
      Params.Clear;
      Params.createParam(ftString	,'work_order', ptInput);
      Params.CreateParam(ftString	,'PANEL', ptInput);
      CommandText := 'SELECT SERIAL_NUMBER, MODEL_ID, VERSION '+
                     '  FROM SAJET.G_SN_STATUS '+
                     ' WHERE WORK_ORDER=:WORK_ORDER AND  BOX_NO = :PANEL '+
                     '   AND OUT_PDLINE_TIME IS  NULL '+
                     '   AND WORK_FLAG = 0 '+
                     ' ORDER BY SERIAL_NUMBER ';
      params.ParamByName('work_order').AsString :=editWO.Text ;
      Params.ParamByName('PANEL').AsString := editPanel.Text;
      Open;
      if RecordCount > 0 then
      begin
        First;
        while not Eof do
        begin
          if CheckPartSN(FieldByName('SERIAL_NUMBER').AsString) then
          begin
            if csData.Cells[0, csData.RowCount - 1] <> '' then
              csData.RowCount := csData.RowCount + 1;
            csData.Cells[0, csData.RowCount - 1] := FieldByName('SERIAL_NUMBER').AsString;
          end;
          Next;
        end;
        if csData.Cells[0, csData.RowCount - 1] = '' then
        begin
          panlMessage.Caption := 'DUP PCBA PANEL';
          panlMessage.Font.Color := clRed;
          MessageBeep(48);
          editPanel.SetFocus;
          editPanel.SelectAll;
        end else
        begin
          panlMessage.Caption := 'OK';
          panlMessage.Font.Color := clBlue;
          editSN.Enabled := True;
          editSN.SetFocus;
          editSN.SelectAll;
        end;
        G_ModelID := FieldByName('MODEL_ID').AsString;
        G_PartVersion := FieldByName('VERSION').AsString;
      end else
      begin
        panlMessage.Caption := 'INVALID PCBA PANEL';
        panlMessage.Font.Color := clRed;
        MessageBeep(48);
        editPanel.SetFocus;
        editPanel.SelectAll;
      end;
    finally
      Close;
    end;
  end;
end;

procedure TformTest.editSNKeyPress(Sender: TObject; var Key: Char);
var
  I : Integer;
begin
  if Key <> #13 then Exit;
  if Trim(editSN.Text) = '' then Exit;
  if editSN.Text = 'UNDO' then
  begin
    for I := 1 to csData.RowCount - 1 do
      csData.Cells[1, I] := '';
    panlMessage.Caption := 'OK';
    panlMessage.Font.Color := clBlue;
    editSN.SetFocus;
    editSN.SelectAll;
    Exit;
  end;
  with formMain.Sproc do
  begin
    try
      Close;
      {DataRequest('SAJET.FOXLINK_CHECK_SID_RULE');
      FetchParams;
      Params.ParamByName('TTYPE').AsString := 'EDA';
      Params.ParamByName('TSID').AsString := editSN.Text;}
      DataRequest('SAJET.SJ_CHK_KP_RULE');
      FetchParams;
      Params.ParamByName('ITEM_PART_ID').AsString := GetWOModel(editWO.Text);
      Params.ParamByName('ITEM_PART_SN').AsString := editSN.Text;
      Execute;
      if Params.ParamByName('TRES').AsString <> 'OK' then
      begin
        panlMessage.Caption := Params.ParamByName('TRES').AsString ;
        panlMessage.Font.Color := clRed;
        MessageBeep(48);
        editSN.SetFocus;
        editSN.SelectAll;
        Exit;
      end;
    finally
      Close;
    end;;
  end;
  if not CheckSN(editSN.Text) then
  begin
    panlMessage.Caption := 'DUP SN';
    panlMessage.Font.Color := clRed;
    MessageBeep(48);
    editSN.SetFocus;
    editSN.SelectAll;
    Exit;
  end;
  for I := 1 to csData.RowCount - 1 do
  begin
    if csData.Cells[1, I] = '' then
    begin
      csData.Cells[1, I] := editSN.Text;
      panlMessage.Caption := 'OK';
      panlMessage.Font.Color := clBlue;
      if I = csData.RowCount - 1 then
        bbtnConfirmClick(Self)
      else
      begin
        editSN.SetFocus;
        editSN.SelectAll;
        Exit;
      end;
    end else
    begin
      if csData.Cells[1, I] = editSN.Text then
      begin
        panlMessage.Caption := 'DUP SN';
        panlMessage.Font.Color := clRed;
        MessageBeep(48);
        editSN.SetFocus;
        editSN.SelectAll;
        Exit;
      end;
    end;
  end;
end;

procedure TformTest.bbtnConfirmClick(Sender: TObject);
var
  I : Integer;
  sSN, sKPSN : String;
  strdate: string;
begin
  if csData.Cells[1, csData.RowCount - 1] = '' then
  begin
    panlMessage.Caption := 'NOT COMPLETE';
    panlMessage.Font.Color := clRed;
    MessageBeep(48);
    if editSN.Enabled then
    begin
      editSN.SetFocus;
      editSN.SelectAll;
    end else
    begin
      if editPanel.Enabled then
      begin
        editPanel.SetFocus;
        editPanel.SelectAll;
      end else
      begin
        editWO.SetFocus;
        editWO.SelectAll;
      end;
    end;
    Exit;
  end;

  for I := 1 to csData.RowCount - 1 do
  begin
    if I = 1 then
    begin
      sSN := csData.Cells[1, I] + ';';
      sKPSN := csData.Cells[0, I] + ';';
    end else
    begin
      sSN := sSN + csData.Cells[1, I] + ';';
      sKPSN := sKPSN + csData.Cells[0, I] + ';';
    end;
  end;

  with formMain.csFTemp1 do
  begin
     close;
     commandtext:='select sysdate from dual ';
     open;
     strdate:=fieldbyname('sysdate').AsString ;
  end;

  with formMain.Sproc do
  begin
    try
      Close;
      DataRequest('SAJET.FOXLINK_SUBPANEL_REPLACESN');
      FetchParams;
      Params.ParamByName('TSN').AsString := sSN;
      Params.ParamByName('TKPSN').AsString := sKPSN;
      Params.ParamByName('TWO').AsString := editWO.Text;
      Params.ParamByName('TEMP').AsString := formMain.LoginUserNO;
      Params.ParamByName('TEMPID').AsString := formMain.LoginUserID;
      Params.ParamByName('TMODEL').AsString := G_ModelID;
      Params.ParamByName('TVERSION').AsString := G_PartVersion;
      Params.ParamByName('TTERMINALID').AsString := formMain.G_TerminalID;
      Params.ParamByName('TPROCESSID').AsString := formMain.G_ProcessID;
     // Params.ParamByName('TNOW').AsDateTime := Now;
       Params.ParamByName('TNOW').AsDateTime := strtoDateTime(strdate);
      Execute;
      panlMessage.Caption := Params.ParamByName('TRES').AsString;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        panlMessage.Caption := 'COMPLETE';
        panlMessage.Font.Color := clBlue;
        ClearGrid;
        editPanel.Text := '';
        editSN.Text := '';                    
        editPanel.SetFocus;
        editSN.Enabled := False;                    
      end else
      begin
        panlMessage.Font.Color := clRed;
        MessageBeep(48);
        editSN.SetFocus;
        editSN.SelectAll;
      end;
    finally
      Close;
    end;
  end;
end;

end.
