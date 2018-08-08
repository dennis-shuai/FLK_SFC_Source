unit uDataDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, Grids, DBGrids, ExtCtrls, GradPanel, Variants, comobj,
  Buttons, DBClient;

type
  TfDataDetail = class(TForm)
    GradPanel1: TGradPanel;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    GradPanel2: TGradPanel;
    sbtnSave: TSpeedButton;
    SaveDialog1: TSaveDialog;
    Image7: TImage;
    QuryDataDetail: TClientDataSet;
    procedure DBGrid1DblClick(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);
  end;

var
  fDataDetail: TfDataDetail;

implementation

{$R *.DFM}
uses uTravelCard, uDetail;

procedure TfDataDetail.DBGrid1DblClick(Sender: TObject);
begin
  With TfTravelCard.Create(nil) Do
  begin
    UpdateUserID := fDetail.UpdateUserID;    
    QryTemp.RemoteServer := QuryDataDetail.RemoteServer;
    TlbReportFile.RemoteServer := QuryDataDetail.RemoteServer;
    editSN.Text := QuryDataDetail.Fieldbyname('Serial Number').AsString;
    ShowSNData;
    Showmodal;
    Free;
  end;
end;

procedure TfDataDetail.sbtnSaveClick(Sender: TObject);
var
    sFileName,My_FileName : String;
    MsExcel, MsExcelWorkBook : Variant;
    i : Integer;
begin
  if not QuryDataDetail.Active Then Exit;
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
       SaveExcel(MsExcel,MsExcelWorkBook);
       MsExcelWorkBook.SaveAs(sFileName);
       showmessage('Save Excel OK!!');
     Except
       ShowMessage('Could not start Microsoft Excel.');
     end;
     MsExcel.Application.Quit;
     MsExcel:=Null;
  end else
     MessageDlg('You did not Save Any Data',mtWarning,[mbok],0);
end;

procedure TfDataDetail.SaveExcel(MsExcel,MsExcelWorkBook:Variant);
var i,j:integer;
    vRange1: variant;
begin
  for i := 0 to DBGrid1.Columns.Count - 1 do
      MsExcel.Worksheets['Sheet1'].Cells[1,i+1] := DBGrid1.Columns[i].Title.Caption;
      // MsExcel.Worksheets['Sheet1'].Range[Chr(i+65)+'1'].Value:= DBGrid1.Columns[i].Title.Caption;

  QuryDataDetail.First;
  for i:= 0 to QuryDataDetail.RecordCount - 1 do
  begin
      for j:= 0 to QuryDataDetail.FieldCount - 1  do
          MsExcel.Worksheets['Sheet1'].Cells[i+2,j+1] := QuryDataDetail.Fields.Fields[J].AsString ;
       //   MsExcel.Worksheets['Sheet1'].Range[Chr(j+65)+IntToStr(i+2)].Value := QuryDataDetail.Fields.Fields[J].AsString ;
      QuryDataDetail.Next;
  end;
end;


end.
