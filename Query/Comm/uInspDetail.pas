unit uInspDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, Grids, DBGrids, ExtCtrls, GradPanel, Variants, comobj,
  Buttons, DBClient, DBGrid1, StdCtrls;

type
  TfInspDetail = class(TForm)
    GradPanel1: TGradPanel;
    DataSource1: TDataSource;
    GradPanel2: TGradPanel;
    sbtnSave: TSpeedButton;
    SaveDialog1: TSaveDialog;
    Image7: TImage;
    QuryInspDetail: TClientDataSet;
    QuryInspDefect: TClientDataSet;
    DataSource2: TDataSource;
    Image1: TImage;
    sbtnClose: TSpeedButton;
    Label18: TLabel;
    GPRecords: TGradPanel;
    DataSource3: TDataSource;
    QryLot: TClientDataSet;
    DBGrid3: TDBGrid;
    DBGrid1: TDBGrid1;
    Panel1: TPanel;
    DBGrid2: TDBGrid1;
    Splitter1: TSplitter;
    procedure DBGrid1DblClick(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure FormShow(Sender: TObject);
    procedure sbtnCloseClick(Sender: TObject);
    procedure DataSource3DataChange(Sender: TObject; Field: TField);
    procedure DBGrid3DrawDataCell(Sender: TObject; const Rect: TRect;
      Field: TField; State: TGridDrawState);
    procedure DBGrid1DrawDataCell(Sender: TObject; const Rect: TRect;
      Field: TField; State: TGridDrawState);
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

uses uTravel, uDetail;

procedure TfInspDetail.DBGrid1DblClick(Sender: TObject);
begin
  with TfTravelCard.Create(nil) do
  begin
    gsSN := 'SN-' + Self.QuryInspDetail.Fieldbyname('Serial Number').AsString;
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
    begin
      if DBGrid1.Columns[j].Alignment = taLeftJustify then
        MsExcel.Worksheets['Sheet1'].Cells[iRow + 2, j + 1].NumberFormatLocal := '@';
      MsExcel.Worksheets['Sheet1'].Cells[iRow + 2, j + 1] := QuryInspDetail.Fields.Fields[J].AsString;
    end;
    Inc(iRow);
    if not QuryInspDefect.Eof then
      while not QuryInspDefect.Eof do
      begin
        for j := 0 to QuryInspDefect.FieldCount - 1 do
        begin
          if DBGrid2.Columns[j].Alignment = taLeftJustify then
            MsExcel.Worksheets['Sheet1'].Cells[iRow + 2, j + 2].NumberFormatLocal := '@';
          MsExcel.WorkSheets['Sheet1'].Cells[iRow + 2, j + 2] := QuryInspDefect.Fields[j].AsString;
        end;
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
  sSQL := 'Select B.Defect_Code "Defect Code",'
    + '       Decode(A.Defect_Level,''0'',''Critical'',''1'',''Major'',''2'',''Minor'') "Defect Level",'
    + '       A.Defect_Qty "Defect Qty", '
    + '       B.Defect_Desc "Defect Desc" '
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
  QuryInspDefect.Params.ParamByName('Serial_Number').AsString := QuryInspDetail.FieldByName('Serial Number').AsString;
  QuryInspDefect.Params.ParamByName('QC_LotNo').AsString := QuryInspDetail.FieldByName('Lot No').AsString;
  QuryInspDefect.Params.ParamByName('QC_Cnt').AsString := QuryInspDetail.FieldByName('Qc Times').AsString;
  QuryInspDefect.Open;
end;

procedure TfInspDetail.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  if not QuryInspDetail.Active then Exit;
  if QuryInspDetail.IsEmpty then Exit;
  if QuryInspDetail.FieldByName('Insp Result').AsString = 'NG' then
  begin
    DBGrid1.Canvas.Brush.Color := clRed;
    DBGrid1.Canvas.Font.Color := clBlack;
    DBGrid1.DefaultDrawDataCell(rect, Column.Field, State);
  end;
end;

procedure TfInspDetail.FormShow(Sender: TObject);
var Col: Integer;
begin
  DataSource3.DataSet := QryLot;
  for Col := 0 to DBGrid3.Columns.Count - 1 do
    if DBGrid3.Columns[Col].Width > 130 then
      DBGrid3.Columns[Col].Width := 130;
end;

procedure TfInspDetail.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfInspDetail.DataSource3DataChange(Sender: TObject;
  Field: TField);
var sSQL: String; Col: Integer;
begin
  sSQL := 'Select A.SERIAL_NUMBER "Serial Number"' +
    ',B.Customer_SN "Customer SN"' +
    ',A.QC_LotNo "Lot No"' +
    ',A.QC_Cnt "Qc Times" ' +
    ',A.WORK_ORDER "Work Order"' +
    ',C.PART_NO "Part No"';
  if fDetail.gbBox then
      sSQL := sSQL + ',B.Box_No "Box No"';
  sSQL := sSQL + ',B.Carton_No "Carton No"' +
    ',B.Pallet_No "Pallet No"' +
    ',sajet.Inspection_Result(A.QC_Result) "Insp Result"' +
    ',A.INSP_TIME "Inspection Time"' +
    ',D.EMP_NAME "Employee" ';
  //if slField.IndexOf('Spec') <> -1 then
  //  sSQL := sSQL + ',c.Spec1 "Spec" ';
  if ChkModel then
    sSQL := sSQL + ',G.Model_Name "Model Name" ';
  if ChkModel {and (slField.IndexOf('Model Desc') <> -1)} then
    sSQL := sSQL + ',G.Model_Desc1 "Model Desc" ';
  sSQL := sSQL + 'From SAJET.G_QC_SN A,' +
    ' SAJET.G_SN_Status B, ' +
    ' SAJET.SYS_PART C, ' +
    ' SAJET.SYS_EMP D ';
  if ChkModel then
    sSQL := sSQL + ',SAJET.SYS_MODEL G ';
  sSQL := sSQL + 'Where A.QC_LOTNO = :Qc_LotNo ' +
    ' And A.QC_CNT = :QC_Cnt ';
  sSQL := sSQL + '  and A.Serial_Number = B.Serial_Number(+) '
    + '  and A.MODEL_ID = C.PART_ID ';
  if ChkModel then
    sSQL := sSQL + ' and C.MODEL_ID = G.MODEL_ID(+) ';
  sSQL := sSQL + ' and A.INSP_EMP_ID = D.EMP_ID(+) ' +
    'Order by "Serial Number" ';
  QuryInspDetail.Close;
  QuryInspDetail.Params.Clear;
  QuryInspDetail.Params.CreateParam(ftString, 'QC_LotNo', ptInput);
  QuryInspDetail.Params.CreateParam(ftString, 'QC_Cnt', ptInput);
  QuryInspDetail.CommandText := sSQL;
  QuryInspDetail.Params.ParamByName('QC_LotNo').AsString := QryLot.FieldByName('Lot No').AsString;
  QuryInspDetail.Params.ParamByName('QC_Cnt').AsString := QryLot.FieldByName('Qc Times').AsString;
  QuryInspDetail.Open;
  for Col := 0 to DBGrid1.Columns.Count - 1 do
    if DBGrid1.Columns[Col].Width > 130 then
      DBGrid1.Columns[Col].Width := 130;
end;

procedure TfInspDetail.DBGrid3DrawDataCell(Sender: TObject;
  const Rect: TRect; Field: TField; State: TGridDrawState);
var P: array [0..50] of char; bs: TStream; hStr: String;
begin
 if Field is TMemoField then
  begin
    with (Sender as TDBGrid).Canvas do
    begin
      bs := QryLot.CreateBlobStream(field, bmRead);
      FillChar(P,SizeOf(P),#0);
      bs.Read(P, 50);
      bs.Free;
      hStr := StrPas(P);
      while Pos(#13, hStr) > 0 do
        hStr[Pos(#13, hStr)] := ' ';
      while Pos(#10, hStr) > 0 do
        hStr[Pos(#10, hStr)] := ' ';
      FillRect(Rect);
      TextOut(Rect.Left + 2, Rect.Top + 2, hStr);
    end;
  end;
end;

procedure TfInspDetail.DBGrid1DrawDataCell(Sender: TObject;
  const Rect: TRect; Field: TField; State: TGridDrawState);
var P: array [0..50] of char; bs: TStream; hStr: String;
begin
 if Field is TMemoField then
  begin
    with (Sender as TDBGrid).Canvas do
    begin
      bs := QuryInspDetail.CreateBlobStream(field, bmRead);
      FillChar(P,SizeOf(P),#0);
      bs.Read(P, 50);
      bs.Free;
      hStr := StrPas(P);
      while Pos(#13, hStr) > 0 do
        hStr[Pos(#13, hStr)] := ' ';
      while Pos(#10, hStr) > 0 do
        hStr[Pos(#10, hStr)] := ' ';
      FillRect(Rect);
      TextOut(Rect.Left + 2, Rect.Top + 2, hStr);
    end;
  end;
end;

end.

