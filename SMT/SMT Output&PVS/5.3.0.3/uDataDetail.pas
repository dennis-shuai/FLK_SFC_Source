unit uDataDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, Grids, DBGrids, ExtCtrls, GradPanel, Variants, comobj,
  Buttons, DBClient, DBGrid1, StdCtrls;

type
  TfDataDetail = class(TForm)
    GradPanel1: TGradPanel;
    DataSource1: TDataSource;
    GradPanel2: TGradPanel;
    SaveDialog1: TSaveDialog;
    QuryDataDetail: TClientDataSet;
    DBGrid1: TDBGrid1;
    Label18: TLabel;
    GPRecords: TGradPanel;
    Image1: TImage;
    sbtnClose: TSpeedButton;
    Image7: TImage;
    sbtnSave: TSpeedButton;
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
  end;

var
  fDataDetail: TfDataDetail;

implementation

{$R *.DFM}


procedure TfDataDetail.sbtnSaveClick(Sender: TObject);
var
  sFileName, My_FileName: string;
  MsExcel, MsExcelWorkBook: Variant;
  i: Integer;
begin
  if not QuryDataDetail.Active then Exit;
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
  end;
end;

procedure TfDataDetail.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var i, j: integer;
  vRange1: variant;
begin
  for i := 0 to DBGrid1.Columns.Count - 1 do
    MsExcel.Worksheets['Sheet1'].Cells[1, i + 1] := DBGrid1.Columns[i].Title.Caption;
  QuryDataDetail.First;
  for i := 0 to QuryDataDetail.RecordCount - 1 do
  begin
    for j := 0 to QuryDataDetail.FieldCount - 1 do
    begin
      if DBGrid1.Columns[j].Alignment = taLeftJustify then
        MsExcel.Worksheets['Sheet1'].Cells[i + 2, j + 1].NumberFormatLocal := '@';
      MsExcel.Worksheets['Sheet1'].Cells[i + 2, j + 1] := QuryDataDetail.Fields.Fields[J].AsString;
    end;
    QuryDataDetail.Next;
  end;
end;


procedure TfDataDetail.FormShow(Sender: TObject);
var Col: Integer;
begin
  for Col := 0 to DBGrid1.Columns.Count - 1 do
    if DBGrid1.Columns[Col].Width > 130 then
      DBGrid1.Columns[Col].Width := 130;
end;

procedure TfDataDetail.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

end.

