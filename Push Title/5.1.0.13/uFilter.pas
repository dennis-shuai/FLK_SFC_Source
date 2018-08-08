unit uFilter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  DB, Ora, DBClient, ComCtrls, Grids, DBGrids, ExtCtrls,DateUtils;

type
   TDBGrid = class(DBGrids.TDBGrid)
   public
      function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
   end;
   TfFilter = class(TForm)
   Image1: TImage;
   DBGrid1: TDBGrid;
   ClientDataSet1: TClientDataSet;
   OraDataSource1: TOraDataSource;
    StatusBar1: TStatusBar;
   procedure FormClose(Sender: TObject; var Action: TCloseAction);
   procedure FormShow(Sender: TObject);
   procedure DBGrid1KeyPress(Sender: TObject; var Key: Char);
   procedure DBGrid1TitleClick(Column: TColumn);
   procedure DBGrid1DblClick(Sender: TObject);
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
Var KTime : Integer;
begin
  if F_Str='Model Name' then
    DBGrid1.Columns.Items[3].Visible:=False
  else if F_Str='Customer Name' then
    DBGrid1.Columns.Items[5].Visible:=False
  else if F_Str='Part No' then
    DBGrid1.Columns.Items[10].Visible:=False
  else if F_Str='Stage Name' then
    DBGrid1.Columns.Items[3].Visible:=False
  else if F_Str='PDLine Name' then
    DBGrid1.Columns.Items[2].Visible:=False
  else if F_Str='Process Name' then
    DBGrid1.Columns.Items[3].Visible:=False;
  StatusBar1.Panels.Items[0].Text:=fMainForm.ShowCnt(fMainForm.G_sSysLang,ClientDataSet1.recordCount);
  KTime:=MilliSecondsBetween(time(),cost2);
  StatusBar1.Panels.Items[1].Text:=fMainForm.ShowTime(fMainForm.G_sSysLang,KTime);
end;

procedure TfFilter.DBGrid1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#27 then
    close;
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
Var sID,sName : String;
begin
  If ClientDataSet1.Eof then  exit;

  sID:='';
  sName:='';
  if F_Str='Model Name' then
  begin
    sID:=ClientDataSet1.Fieldbyname('MODEL_ID').AsString;
    sName:=ClientDataSet1.Fieldbyname('MODEL_NAME').AsString;
  end
  else if F_Str='Customer Name' then
  begin
    sID:=ClientDataSet1.Fieldbyname('CUSTOMER_ID').AsString;
    sName:=ClientDataSet1.Fieldbyname('CUSTOMER_NAME').AsString;
  end
  else if F_Str='Part No' then
  begin
    sID:=ClientDataSet1.Fieldbyname('PART_ID').AsString;
    sName:=ClientDataSet1.Fieldbyname('PART_NO').AsString;
  end
  else if F_Str='Work Order' then
  begin
    sID:=ClientDataSet1.Fieldbyname('WORK_ORDER').AsString;
    sName:=sID;
  end
  else if F_Str='Stage Name' then
  begin
    sID:=ClientDataSet1.Fieldbyname('STAGE_ID').AsString;
    sName:=ClientDataSet1.Fieldbyname('STAGE_NAME').AsString;
  end
  else if F_Str='PDLine Name' then
  begin
    sID:=ClientDataSet1.Fieldbyname('PDLINE_ID').AsString;
    sName:=ClientDataSet1.Fieldbyname('PDLINE_NAME').AsString;
  end
  else if F_Str='Process Name' then
  begin
    sID:=ClientDataSet1.Fieldbyname('PROCESS_ID').AsString;
    sName:=ClientDataSet1.Fieldbyname('PROCESS_NAME').AsString;
  end;
  if not fCondition.ConfirmData(F_Str,R_Str,sID,sName) then exit;
  ModalResult := mrOK;
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

end.
