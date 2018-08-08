unit uInspDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, Grids, DBGrids, ExtCtrls, GradPanel, Variants, comobj,
  Buttons, DBClient;

type
  TfInspDetail = class(TForm)
    GradPanel1: TGradPanel;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    GradPanel2: TGradPanel;
    sbtnSave: TSpeedButton;
    SaveDialog1: TSaveDialog;
    Image7: TImage;
    QuryInspDetail: TClientDataSet;
    DBGrid2: TDBGrid;
    Panel1: TPanel;
    QuryInspDefect: TClientDataSet;
    DataSource2: TDataSource;
    procedure DBGrid1DblClick(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
  end;

var
  fInspDetail: TfInspDetail;

implementation

{$R *.DFM}

uses uTravel;

procedure TfInspDetail.DBGrid1DblClick(Sender: TObject);
begin
  with TfTravelCard.Create(nil) do
  begin
    gsSN := 'SN-' + Self.QuryInspDetail.Fieldbyname('Serial_Number').AsString;
    Show;
  end;
end;

procedure TfInspDetail.sbtnSaveClick(Sender: TObject);
var sFileName: string;
  MsExcel, MsExcelWorkBook: Variant;
begin
  if not QuryInspDetail.Active then Exit;
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'xls';
  SaveDialog1.Filter := 'All Files(*.xls)|*.xls';

  if SaveDialog1.Execute then
  begin
    try
      sFileName := SaveDialog1.FileName;
      MsExcel := CreateOleObject('Excel.Application');
      MsExcelWorkBook := MsExcel.WorkBooks.add;

      MsExcel.Worksheets['Sheet1'].select;
      SaveExcel(MsExcel, MsExcelWorkBook);
      MsExcelWorkBook.SaveAs(sFileName);
      showmessage('Save Excel OK!!');
    except
      ShowMessage('Could not start Microsoft Excel.');
    end;
    MsExcel.Application.Quit;
    MsExcel := Null;
  end
  else
    MessageDlg('You did not Save Any Data', mtWarning, [mbok], 0);
end;

procedure TfInspDetail.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var iRow, j: integer;
begin
  for j := 0 to DBGrid1.Columns.Count - 1 do
    MsExcel.Worksheets['Sheet1'].Cells[1, j + 1] := DBGrid1.Columns[j].Title.Caption;
  QuryInspDetail.First;
  iRow := 0;
  while not QuryInspDetail.Eof do
  begin
    for j := 0 to DBGrid1.Columns.Count - 1 do
      MsExcel.Worksheets['Sheet1'].Cells[iRow + 2, j + 1] := QuryInspDetail.Fields.Fields[J].AsString;
    Inc(iRow);
    if not QuryInspDefect.Eof then
      while not QuryInspDefect.Eof do
      begin
        for j := 0 to QuryInspDefect.FieldCount - 1 do
          MsExcel.WorkSheets['Sheet1'].Cells[iRow + 2, j + 2] := QuryInspDefect.Fields[j].AsString;
        Inc(iRow);
        QuryInspDefect.Next;
      end;
    QuryInspDetail.Next;
  end;
end;


procedure TfInspDetail.DataSource1DataChange(Sender: TObject;
  Field: TField);
var sSQL: string;
begin
  sSQL := 'Select B.Defect_Code,'
    + '       Decode(A.Defect_Level,''0'',''Critical'',''1'',''Major'',''2'',''Minor'') Defect_Level,'
    + '       A.Defect_Qty, '
    + '       B.Defect_Desc '
    + '  From SAJET.G_QC_SN_DEFECT A '
    + '      ,SAJET.SYS_DEFECT B '
    + ' Where A.Serial_Number = :Serial_Number '
    + '   And A.QC_LotNo = :QC_LotNo '
    + '   And A.QC_CNT = :QC_Cnt '
    + '   And A.Defect_ID = B.Defect_ID(+) ';

  QuryInspDefect.Close;
  QuryInspDefect.Params.Clear;
  QuryInspDefect.Params.CreateParam(ftString, 'Serial_Number', ptInput);
  QuryInspDefect.Params.CreateParam(ftString, 'QC_LotNo', ptInput);
  QuryInspDefect.Params.CreateParam(ftString, 'QC_Cnt', ptInput);
  QuryInspDefect.CommandText := sSQL;
  QuryInspDefect.Params.ParamByName('Serial_Number').AsString := QuryInspDetail.FieldByName('Serial_Number').AsString;
  QuryInspDefect.Params.ParamByName('QC_LotNo').AsString := QuryInspDetail.FieldByName('QC_LotNo').AsString;
  QuryInspDefect.Params.ParamByName('QC_Cnt').AsString := QuryInspDetail.FieldByName('QC_Cnt').AsString;
  QuryInspDefect.Open;
end;

procedure TfInspDetail.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  if not QuryInspDetail.Active then Exit;
  if QuryInspDetail.IsEmpty then Exit;
  if QuryInspDetail.FieldByName('QC_Result').AsString = 'NG' then
  begin
    DBGrid1.Canvas.Brush.Color := clRed;
    DBGrid1.Canvas.Font.Color := clBlack;
    DBGrid1.DefaultDrawDataCell(rect, Column.Field, State);
  end;
end;

end.

