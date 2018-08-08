unit uDataDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, Grids, DBGrids, ExtCtrls, GradPanel, Variants, comobj,
  Buttons, DBClient, StdCtrls, ComCtrls;

type
  TDBGrid = class(DBGrids.TDBGrid)
   public
      function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
   end;
  TfDataDetail = class(TForm)
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    QuryDataDetail: TClientDataSet;
    Panel1: TPanel;
    sbtnQuery: TSpeedButton;
    Image3: TImage;
    sbtnFilter: TSpeedButton;
    Image2: TImage;
    StatusBar1: TStatusBar;
    SaveDialog1: TSaveDialog;
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure SpeedButton1Click(Sender: TObject);
    procedure DBGrid1KeyPress(Sender: TObject; var Key: Char);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure sbtnFilterClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fDataDetail: TfDataDetail;

implementation

{$R *.DFM}
uses uMainForm,uCallDll;


procedure TfDataDetail.DBGrid1TitleClick(Column: TColumn);
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

procedure TfDataDetail.SpeedButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TfDataDetail.DBGrid1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#27 then
    close;
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

procedure TfDataDetail.DBGrid1CellClick(Column: TColumn);
Var sTmp,sStr : String;
    m_DLLHandle1: THandle;
   sStr3: String;
begin
  sStr3:=Column.Title.Caption;
  if ((sStr3 ='Carton No') or (sStr3='Pallet No') or (sStr3='QCLot No') or (sStr3 = 'Serial Number' ) )
    and (Column.Field.AsString<>'N/A') then
  begin
    sStr:=Column.Field.AsString;
    if sStr3='Serial Number' then
      sTmp:='QueryTravel.dll'
    else
    begin
      sTmp:='QuerySNdll.dll';
      if sStr3='Carton No' then
        sStr:='2@@'+sStr
      else if sStr3='Pallet No' then
        sStr:='1@@'+sStr
      else if sStr3='QCLot No' then
        sStr:='0@@'+sStr;
    end;
    m_DLLHandle1 := LoadLibrary(pchar(ExtractFilePath(Application.exename) +sTmp ));
    if m_DLLHandle1 <= 32 then
    begin raise Exception.create('Can Not Find DLL File(' + sTmp + ')'); end
    else
    begin
      with TCallDll.Create(Self) do
      begin
        left:=10;
        Top:=90;
        Str_SN:=sStr;
        Str_Type:=sTmp;
        if Str_Type='QueryTravel.dll' then
          caption:='Travel Card'
        else
          caption:='Query Serial Number';
        Showmodal;
      end;
    end;
  end;
end;

procedure TfDataDetail.DBGrid1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  lCoord: TGridCoord;
  liOldRecord: Integer;
  sStr2: String;
begin
  IF not (TDBGrid(DBGrid1).DataSource.DataSet.active) THEN EXIT;
  lCoord := DBGrid1.MouseCoord(X, Y);
  if dgIndicator in DBGrid1.Options then
    Dec(lCoord.X);
  if dgTitles in DBGrid1.Options then
    Dec(lCoord.Y);
  if (lCoord.Y >= 0) and (lCoord.X >= 0) and Assigned(TDBGrid(DBGrid1).DataLink) then
  begin
    liOldRecord := TDBGrid(DBGrid1).DataLink.ActiveRecord;
    try
      TDBGrid(DBGrid1).DataLink.ActiveRecord := lCoord.Y;
      sStr2:=DBGrid1.Columns.Items[lCoord.X].Title.Caption;
      if ((sStr2 = 'Serial Number' ) or (sStr2 ='Carton No') or (sStr2='Pallet No') or (sStr2='QCLot No') )
      and (DBGrid1.GetEditText(lCoord.X+1,lCoord.Y)<>'N/A') then
        DBGrid1.Cursor:=crHandPoint
      else
        DBGrid1.Cursor:=crDefault;
    finally
      TDBGrid(DBGrid1).DataLink.ActiveRecord := liOldRecord;
    end;
  end else
    DBGrid1.Cursor:=crDefault;
end;

procedure TfDataDetail.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
Var sStrt: String;
begin
  if DataCol<0 then exit;
  sStrt:=Column.Title.Caption;
  if ((sStrt ='Carton No') or (sStrt='Pallet No') or (sStrt='QCLot No') )and (Column.Field.AsString<>'N/A') then
  begin
    DBGrid1.Canvas.Brush.Color:=$00FFF0F0;//¸Ä×ƒµ×É«
    DBGrid1.Canvas.Font.Style:=[fsUnderline,fsBold];
    DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
  end
end;

procedure TfDataDetail.sbtnFilterClick(Sender: TObject);
var
  sFileName : String;
  MsExcel, MsExcelWorkBook : Variant;
  i,j : Integer;
begin
  if DBGrid1.Visible=True then
  begin
    if not QuryDataDetail.Active Then Exit;
    if (QuryDataDetail.RecordCount=0) Then Exit;
  end;
  SaveDialog1.InitialDir := ExtractFilePath(Application.ExeName);
  SaveDialog1.DefaultExt := 'xls';
  SaveDialog1.Filter := 'All Files(*.xls)|*.xls';
  if SaveDialog1.Execute then
  begin
    try
      sFileName := SaveDialog1.FileName;
      //Delete First if Exist
      if FileExists(sFileName) then
      begin
        if MessageDlg('File has exist! Replace or Not ?',mtInformation, [mbYes, mbNo],0)= mrYes Then
        //If messagebox(fDataDetail.Handle,'File has exist! Replace or Not ?','',mb_OkCancel) = idOK Then
           DeleteFile(sFileName)
        else exit;
      end;

      MsExcel := CreateOleObject('Excel.Application');
      MsExcelWorkBook := MsExcel.WorkBooks.add;
      MsExcel.Worksheets['Sheet1'].select;
      //QuryDataDetail.DisableControls;
      for i := 0 to DBGrid1.Columns.Count - 1 do
        MsExcel.Worksheets['Sheet1'].Range[Chr(i+65)+'1'].Value:= DBGrid1.Columns[i].Title.Caption;
      QuryDataDetail.First;
      for i:= 0 to QuryDataDetail.RecordCount - 1 do
      begin
        for j:= 0 to DBGrid1.Columns.Count - 1  do
           MsExcel.Worksheets['Sheet1'].Range[Chr(j+65)+IntToStr(i+2)].Value := QuryDataDetail.Fields.Fields[J].AsString ;
        QuryDataDetail.Next;
      end;
      //QuryDataDetail.EnableControls;
      Try
        MsExcelWorkBook.SaveAs(sFileName);
      Except
        MessageDlg('Could not SaveAs Excel.',mtError, [mbOK],0);
      end;
      MsExcelWorkBook.close;
      MsExcelWorkBook:=Null;
      MsExcel.Application.Quit;
      MsExcel:=Null;
      MessageDlg('Save Excel OK!!',mtInformation, [mbOK],0)
    Except
      MessageDlg('Could not start Microsoft Excel.',mtError, [mbOK],0) ;
    end;   
  end;
end;

end.
