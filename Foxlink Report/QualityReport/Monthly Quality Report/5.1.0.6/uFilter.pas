unit uFilter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  DB, DBClient, ComCtrls, Grids, DBGrids, ExtCtrls,DateUtils, StdCtrls,
  DBCtrls, CheckLst, Buttons;

type
   TDBGrid = class(DBGrids.TDBGrid)
   public
      function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
   end;
   TfFilter = class(TForm)
   Image1: TImage;
   DBGrid1: TDBGrid;
   ClientDataSet1: TClientDataSet;
    StatusBar1: TStatusBar;
    DataSource1: TDataSource;
    ChkListData: TCheckListBox;
    Button3: TSpeedButton;
    Image3: TImage;
    SpeedButton1: TSpeedButton;
    Image2: TImage;
   procedure FormClose(Sender: TObject; var Action: TCloseAction);
   procedure FormShow(Sender: TObject);
   procedure DBGrid1KeyPress(Sender: TObject; var Key: Char);
   procedure DBGrid1TitleClick(Column: TColumn);
   procedure DBGrid1DblClick(Sender: TObject);
   procedure Button3Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
    F_Str,R_Str : String;
    cost2 : TDateTime;
  end;

var
  fFilter: TfFilter;

implementation

uses
   uCondition, uMainForm;

{$R *.dfm}

procedure TfFilter.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfFilter.FormShow(Sender: TObject);
Var KTime,iTemp : Integer;
    sTmp : String;
begin
  ChkListData.Clear;
  if F_Str='Model Name' then
  begin
    DBGrid1.Columns.Items[3].Visible:=False;
    ChkListData.Visible:=False;
    DBGrid1.Align:=alClient;
  end
  else if F_Str='Process Name' then
  begin
    DBGrid1.Columns.Items[3].Visible:=False;
    for iTemp:=0 to fMainForm.StrLstProcessName.Count-1 do
    begin
      ChkListData.AddItem(fMainForm.StrLstProcessName.Strings[iTemp]+'  ||  '+fMainForm.StrLstStageName.Strings[iTemp],Self);
      ChkListData.Checked[iTemp]:=True;
    end;
  end;
  StatusBar1.Panels.Items[0].Text:=fMainForm.ShowCnt(fMainForm.G_sSysLang,ClientDataSet1.recordCount);
  KTime:=MilliSecondsBetween(time(),cost2);
  StatusBar1.Panels.Items[1].Text:=fMainForm.ShowTime(fMainForm.G_sSysLang,KTime);
end;

procedure TfFilter.DBGrid1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then
    DBGrid1DblClick(Self);
end;

procedure TfFilter.DBGrid1TitleClick(Column: TColumn);
var bAesc: Boolean;
begin
  bAesc := True;
  if DBGrid1.DataSource = nil then Exit;
  if DBGrid1.DataSource.DataSet = nil then Exit;
  if not (DBGrid1.DataSource.DataSet is TClientDataSet) then Exit;
  if (DBGrid1.DataSource.DataSet as TClientDataSet).Active then
  begin
    if (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName <> '' then
    begin
      bAesc := True;
      if (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName = Column.FieldName then
        bAesc := False;
       (DBGrid1.DataSource.DataSet as TClientDataSet).deleteIndex((DBGrid1.DataSource.DataSet as TClientDataSet).Indexname);
    end;
    if bAesc then begin
      (DBGrid1.DataSource.DataSet as TClientDataSet).AddIndex(Column.FieldName, Column.FieldName, [], '', '', 0);
      (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName := Column.FieldName;
    end else begin
      (DBGrid1.DataSource.DataSet as TClientDataSet).AddIndex(Column.FieldName + 'D', Column.FieldName, [ixDescending], '', '', 0);
      (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName := Column.FieldName + 'D';
    end;
    (DBGrid1.DataSource.DataSet as TClientDataSet).IndexDefs.Update;
  end;
end;

procedure TfFilter.DBGrid1DblClick(Sender: TObject);
Var sID,sName,sName2,cDesc : String;
begin
  If ClientDataSet1.Eof then  exit;
  sID:='';
  sName:='';
  sName2:='';
  cDesc:='';
  if F_Str='Model Name' then
  begin
    sID:=ClientDataSet1.Fieldbyname('MODEL_ID').AsString;
    sName:=ClientDataSet1.Fieldbyname('MODEL_NAME').AsString;
  end
  else if F_Str='Process Name' then
  begin
    sID:=ClientDataSet1.Fieldbyname('PROCESS_ID').AsString;
    sName:=ClientDataSet1.Fieldbyname('PROCESS_NAME').AsString;
    sName2:=ClientDataSet1.Fieldbyname('Stage_NAME').AsString;
  end;
  if not fCondition.ConfirmData(F_Str,R_Str,sID,sName,sName2,cDesc) then exit;
  if F_Str='Process Name' then
  begin
    ChkListData.AddItem(sName+'  ||  '+sName2,Self);
    ChkListData.Checked[ChkListData.Items.Count-1]:=True;
  end;
  if F_Str='Model Name' then  ModalResult := mrOK;
end;

function TDBGrid.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  IF not (datasource.DataSet.active) THEN EXIT;
  if WheelDelta > 0 then
    datasource.DataSet.Prior;
  if wheelDelta < 0 then
    DataSource.DataSet.Next;
  Result := True;
end;

procedure TfFilter.Button3Click(Sender: TObject);
begin
  ModalResult := mrOK;
end;


procedure TfFilter.SpeedButton1Click(Sender: TObject);
Var i,i1 : Integer;
begin
  for i:=0 to (ChkListData.Items.Count-1) do
  begin
    if ChkListData.Checked[i]=False then
    begin
      i1:=fMainForm.StrLstProcessName.IndexOf(Copy(ChkListData.Items.Strings[i],1,Pos('  ||  ',ChkListData.Items.Strings[i])-1));
      fMainForm.StrLstProcess.Delete(i1);
      fMainForm.StrLstProcessName.Delete(i1);
      fMainForm.StrLstStageName.Delete(i1);
    end;
  end;
  ModalResult := mrOK;
end;

end.
