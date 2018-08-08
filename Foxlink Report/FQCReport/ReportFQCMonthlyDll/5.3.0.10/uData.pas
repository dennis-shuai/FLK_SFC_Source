unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db,
  DBClient, MConnect, ObjBrkr, SConnect, GradPanel, Variants, comobj,Excel97,OleCtnrs;

type
  TfData = class(TForm)
    Panel1: TPanel;
    SpeedButton5: TSpeedButton;
    Image2: TImage;
    QryData1: TClientDataSet;
    QryTemp1: TClientDataSet;
    PageControl1: TPageControl;
    TabData: TTabSheet;
    GradPanel14: TGradPanel;
    Image7: TImage;
    sbtnSave1: TSpeedButton;
    Image8: TImage;
    sbtnPrint1: TSpeedButton;
    ImageTitle1: TImage;
    Label3: TLabel;
    Label4: TLabel;
    SaveDialog2: TSaveDialog;
    editModel: TEdit;
    combMonth1: TComboBox;
    strgridCorr: TStringGrid;
    LabMonth: TLabel;
    combYear1: TComboBox;
    Image3: TImage;
    sbtnRefresh: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure sbtnSave1Click(Sender: TObject);
    procedure sbtnRefreshClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    sStartHour:string;
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
  end;

var
  fData: TfData;

implementation

{$R *.DFM}

procedure TfData.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var i,iStartRow,iRow:integer;
    sPerWeek:string;
    vRange1:Variant;
begin
  MsExcel.Worksheets['Sheet2'].Range['A2']:= combYear1.Text+' Year - '+combMonth1.Text+'Month';

  iStartRow:= 4;
  iRow:=-1;
  sPerWeek:='';
  for i := 1 to strgridCorr.RowCount - 1 do
  begin
    if sPerWeek <> strgridCorr.Cells[7,i] then
    begin
      MsExcel.Worksheets['Sheet2'].Cells[i+iStartRow+iRow,1].value := strgridCorr.Cells[7,i]+'Week';
      MsExcel.Worksheets['sheet2'].Range['A'+IntToStr(i+iStartRow+iRow),'M'+IntToStr(i+iStartRow+iRow)].MergeCells:=True;
      MsExcel.Worksheets['sheet2'].Range['A'+IntToStr(i+iStartRow+iRow)].HorizontalAlignment :=xlLeft;
      MsExcel.Worksheets['sheet2'].Range['A'+IntToStr(i+iStartRow+iRow)].Font.bold:=true;   
      inc(iRow);
    end;
    MsExcel.Worksheets['Sheet2'].Cells[i+iStartRow+iRow,1].value := strgridCorr.Cells[0,i];
    MsExcel.Worksheets['Sheet2'].Cells[i+iStartRow+iRow,2].value := strgridCorr.Cells[1,i];
    MsExcel.Worksheets['Sheet2'].Cells[i+iStartRow+iRow,4].value := strgridCorr.Cells[2,i];
    MsExcel.Worksheets['Sheet2'].Cells[i+iStartRow+iRow,5].value := strgridCorr.Cells[3,i];
    MsExcel.Worksheets['Sheet2'].Cells[i+iStartRow+iRow,6].value := strgridCorr.Cells[4,i];
    MsExcel.Worksheets['Sheet2'].Cells[i+iStartRow+iRow,7].value := strgridCorr.Cells[5,i];
    MsExcel.Worksheets['Sheet2'].Cells[i+iStartRow+iRow,8].value := strgridCorr.Cells[6,i];
    sPerWeek:= strgridCorr.Cells[7,i];
  end;

  //畫格線
  vRange1 := MsExcel.Worksheets['sheet2'].Range['A'+IntToStr(iStartRow)+':'+'M'+IntToStr(i+iStartRow+iRow-1)];
  vRange1.Borders.LineStyle:=$00000001; 
end;

procedure TfData.FormShow(Sender: TObject);
begin
  with strgridCorr do
  begin
    cells[0,0]:='NO';
    cells[1,0]:='日期';
    cells[2,0]:='線別';
    cells[3,0]:='機種';
    cells[4,0]:='料號';
    cells[5,0]:='不良現象';
    cells[6,0]:='原因分析';
  end;
end;

procedure TfData.sbtnSave1Click(Sender: TObject);
var
  sFileName, My_FileName: string;
  MsExcel, MsExcelWorkBook: Variant;
  i: Integer;
begin
  if (not QryData1.Active) or (QryData1.IsEmpty) then Exit;
  SaveDialog2.InitialDir := ExtractFilePath('C:\');
  SaveDialog2.DefaultExt := 'xls';
  SaveDialog2.Filter := 'All Files(*.xls)|*.xls';

  My_FileName := ExtractFilePath(Application.ExeName)+'FQCCorrectiveReport.xlt';

  if not FileExists(My_FileName) then
  begin
    showmessage('Error!-The Excel File ' + My_FileName + ' can''t be found.');
    exit;
  end;

  if Sender = sbtnSave1 then
  begin
    if SaveDialog2.Execute then
      sFileName := SaveDialog2.FileName
    else
      exit;  
  end;

  try
    MsExcel := CreateOleObject('Excel.Application');
    MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);

    MsExcel.Worksheets['Sheet2'].select;
    SaveExcel(MsExcel, MsExcelWorkBook);
    if Sender = sbtnSave1 then
    begin
      MsExcelWorkBook.SaveAs(sFileName);
      showmessage('Save Excel OK!!');
    end;
    if Sender = sbtnPrint1 then
    begin
      WindowState := wsMinimized;
      MsExcel.Visible := TRUE;
      MsExcel.WorkSheets['Sheet2'].PrintPreview;
      WindowState := wsMaximized;
    end;
  except
    ShowMessage('Could not start Microsoft Excel.');
  end;
  MsExcelWorkBook.close(False);
  MsExcel.Application.Quit;
  MsExcel := Null;

end;

procedure TfData.sbtnRefreshClick(Sender: TObject);
var sSQL,sStartDate,sEndDate: string;
    i,iRow:integer;
begin
  for i:= 1 to strgridCorr.RowCount do
    strgridCorr.Rows[i].Clear;

  sStartDate:=combYear1.Text+combMonth1.Text+'01';
  if combMonth1.Text='12' then
    sEndDate:=IntToStr(StrToInt(combYear1.Text)+1)+'0101'
  else
    sEndDate:=combYear1.Text+FormatFloat('00',StrToInt(combMonth1.Text)+1)+'01';

  sSQL:='select to_char(a.insp_time - '+sStartHour+'/24,''iw'') sWeek,to_char(a.insp_time - '+sStartHour+'/24,''mm/dd'') insptime,part.part_no,line.pdline_name,model.model_name '
       +'      ,c.defect_code,c.defect_desc ,e.reason_code,e.reason_desc,sum(defect_qty) defect_qty '
       +'from sajet.g_qc_sn a,sajet.sys_part part,sajet.sys_pdline line,sajet.sys_model model '
       +'    ,sajet.g_sn_defect b,sajet.sys_defect c '
       +'    ,sajet.g_sn_repair d,sajet.sys_reason e '
       +'where to_char(a.insp_time - '+sStartHour+'/24,''yyyymmdd'') >= '''+sStartDate+''' '
       +'and   to_char(a.insp_time - '+sStartHour+'/24,''yyyymmdd'') < '''+sEndDate+''' '
       +'and a.MODEL_ID = part.part_id '
       +'and b.pdline_id = line.pdline_id '
       +'and part.model_id = model.model_id(+) '
       +'and (a.serial_number=b.serial_number and a.insp_time = b.REC_TIME) '
       +'and b.defect_id = c.defect_id '
       +'and b.recid = d.RECID(+) '
       +'and d.reason_id = e.reason_id(+) ';
  if editModel.Text<>'' then
    sSQL:=sSQL+'and model.model_name = '''+editModel.Text+''' ';
  sSQL:=sSQL
       +'group by to_char(a.insp_time - '+sStartHour+'/24,''iw''),to_char(a.insp_time - '+sStartHour+'/24,''mm/dd'') ,part.part_no,line.pdline_name,model.model_name,c.defect_code,c.defect_desc ,e.reason_code,e.reason_desc '
       +'order by insptime ';

  with QryData1 do
  begin
    Close;
    Params.Clear;
    CommandText := sSQL;
    Open;
    if IsEmpty then
    begin
      Showmessage('No Data');
      exit;
    end;

    iRow:=0;
    while not eof do
    begin
      inc(iRow);
      strgridCorr.Cells[0,iRow]:=IntToStr(iRow);
      strgridCorr.Cells[1,iRow]:=FieldbyName('insptime').asstring;
      strgridCorr.Cells[2,iRow]:=FieldbyName('pdline_name').asstring;
      strgridCorr.Cells[3,iRow]:=FieldbyName('model_name').asstring;
      strgridCorr.Cells[4,iRow]:=FieldbyName('part_no').asstring;
      strgridCorr.Cells[5,iRow]:=FieldbyName('defect_desc').asstring+'*'+FieldbyName('defect_qty').asstring;
      strgridCorr.Cells[6,iRow]:=FieldbyName('reason_desc').asstring;
      strgridCorr.Cells[7,iRow]:=FieldbyName('sWeek').asstring;
      Next;
    end;  
  end;

  if iRow = 0 then
    strgridCorr.RowCount:=2
  else
    strgridCorr.RowCount:=iRow+1;
end;

end.

