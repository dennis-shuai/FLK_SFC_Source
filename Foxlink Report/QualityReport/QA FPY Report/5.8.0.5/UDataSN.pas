unit UDataSN;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, Buttons, Grids, DBGrids,  Db,
  DBClient, MConnect, ObjBrkr, SConnect,GradPanel,  comobj, Menus;

type
  TFDataSN = class(TForm)
    PageControl1: TPageControl;
    Panel1: TPanel;
    Image7: TImage;
    sbtnSave: TSpeedButton;
    StrGriddataSN: TStringGrid;
    SaveDialogSN: TSaveDialog;
    procedure sbtnSaveClick(Sender: TObject);
    procedure StrGriddataSNDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SaveExcelSN(MsExcel, MsExcelWorkBook: Variant);
  end;

var
  FDataSN: TFDataSN;

implementation

uses uDetail, uTravelCard;

{$R *.dfm}

procedure TFDataSN.SaveExcelSN(MsExcel, MsExcelWorkBook: Variant);
var i, j,iStartRow,iDiv,iMod: integer;
    vRange1:Variant;
begin
   istartrow:=2 ;
   for i := 0 to strgridDataSN.RowCount  do
      BEGIN
          for j := 0 to strgridDataSN.ColCount  do
            MsExcel.Worksheets['Sheet1'].Cells[i+iStartRow,j+1].value := strgridDataSN.Cells[j,i];
      END ;
end;

procedure TFDataSN.sbtnSaveClick(Sender: TObject);
var
  sFileName, My_FileName: string;
  MsExcel, MsExcelWorkBook: Variant;
  i: Integer;
begin
  if (not fDetail.QryDataSN.Active) or (fDetail.QryDataSN.IsEmpty) then Exit;
  SaveDialogSN.InitialDir := ExtractFilePath('C:\');
  SaveDialogSN.DefaultExt := 'xls';
  SaveDialogSN.Filter := 'All Files(*.xls)|*.xls';

  My_FileName := ExtractFilePath(Application.ExeName)+'DFPYReport.xlt';

  if not FileExists(My_FileName) then
  begin
    showmessage('Error!-The Excel File ' + My_FileName + ' can''t be found.');
    exit;
  end;

  if Sender = sbtnSave then
  begin
    if SaveDialogSN.Execute then
      sFileName := SaveDialogSN.FileName
    else
      exit;  
  end;

  try
    MsExcel := CreateOleObject('Excel.Application');
    MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);

    MsExcel.Worksheets['Sheet1'].select;
    SaveExcelSN(MsExcel, MsExcelWorkBook);
    if Sender = sbtnSave then
    begin
      MsExcelWorkBook.SaveAs(sFileName);
      showmessage('Save Excel OK!!');
    end;
    {if Sender = sbtnPrint then
    begin
      WindowState := wsMinimized;
      MsExcel.Visible := TRUE;
      MsExcel.WorkSheets['Sheet1'].PrintPreview;
      WindowState := wsMaximized;
    end;
    }
  except
    ShowMessage('Could not start Microsoft Excel.');
  end;
  MsExcelWorkBook.close(False);
  MsExcel.Application.Quit;
  MsExcel := Null;

end;

procedure TFDataSN.StrGriddataSNDblClick(Sender: TObject);
var iDrow,iDcol:integer;
VAR KEY:CHAR;
begin
   iDrow:=strgridDataSN.Row ;
   iDcol:=strgridDataSN.Col;
   With  tfTravelCard.create(self) do
   begin
     try
         if strgridDataSN.Cells[2,iDrow]='' then exit;
         G_SN:= strgridDataSN.Cells[2,iDrow];
     if showmodal=mrOK  Then
     begin

     end;
     finally
         free;
     end;

   end;
end;

end.
