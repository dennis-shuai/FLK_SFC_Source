unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils, ComObj,// shellapi,
  Menus, uLang, IniFiles,DateUtils;

type
  TfMainForm = class(TForm)
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    QryTemp1: TClientDataSet;
    ImageAll: TImage;
    btnQuery: TSpeedButton;
    Image3: TImage;
    lbl1: TLabel;
    Image1: TImage;
    lbl2: TLabel;
    Image2: TImage;
    lbl3: TLabel;
    dtp1: TDateTimePicker;
    dtp2: TDateTimePicker;
    dtp3: TDateTimePicker;
    dtp4: TDateTimePicker;
    cmbDefect: TComboBox;
    Image4: TImage;
    btnExport: TSpeedButton;
    dbgrd1: TDBGrid;
    ds1: TDataSource;
    dlgSave1: TSaveDialog;
    procedure btnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure dtp1Change(Sender: TObject);

    //procedure editReelnoKeyPress(Sender: TObject; var Key: Char);
  private

  public
    UpdateUserID,sPartID : String;
    isStart,IsOpen:boolean;
    sPdline,sProcess,sTerminal:string;
    StartTime,EndTime:string;
    Authoritys,AuthorityRole,FunctionName : String;
    BarApp,BarDoc,BarVars:variant;
    function GETSYSDATE:TDateTime;

  end;

var
  fMainForm: TfMainForm;
  iTerminal:string;

implementation


{$R *.dfm}
function TfMainForm.GetSYSDATE:TDateTime;
begin
   Qrytemp.Close;
   QryTemp.CommandText :=' SELECT SYSDATE iDATE FROM DUAL';
   QryTemp.Open;
   Result :=QryTemp.FieldByName('IDate').AsDateTime;

end;

procedure TfMainForm.btnQueryClick(Sender: TObject);
begin
    cmbDefect.Text := Trim(cmbDefect.Text);
    StartTime := FormatDateTime('YYYY/MM/DD',dtp1.date) +' '+FormatDateTime('HH:MM:SS',dtp2.time);
    EndTime := FormatDateTime('YYYY/MM/DD',dtp3.date) +' '+FormatDateTime('HH:MM:SS',dtp4.time);
    QryData.Close;
    QryData.Params.Clear;
    if cmbDefect.Text <> '' then
       QryData.Params.CreateParam(ftstring,'Defect',ptInput);
    QryData.Params.CreateParam(ftstring,'Start_TIME',ptInput);
    QryData.Params.CreateParam(ftstring,'End_Time',ptInput);
    QryData.CommandText:=' SELECT A.Container,C.Defect_Desc,Count(*) Qty FROM SAJET.G_SN_STATUS A,SAJET.G_SN_DEFECT_FIRST B,'+
                         ' SAJET.SYS_DEFECT C WHERE A.SERIAL_NUMBER =B.SERIAL_NUMBER '+
                         ' AND B.DEFECT_ID =C.DEFECT_ID AND B.REC_TIME >=TO_DATE( :START_TIME,''YYYY/MM/DD HH24:MI:SS'') '+
                         ' AND B.REC_TIME < TO_DATE(:END_TIME,''YYYY/MM/DD HH24:MI:SS'') AND A.CONTAINER <>''N/A'' AND B.STAGE_ID =10001 ';
    if cmbDefect.Text <> '' then
    begin
       QryData.CommandText:= QryData.CommandText+ 'AND C.DEFECT_DESC =:Defect ';
       QryData.Params.ParamByName('Defect').AsString :=cmbDefect.Text;
    end;
    QryData.CommandText:= QryData.CommandText+ 'GROUP BY A.Container,C.Defect_Desc ORDER BY QTY DESC,A.CONTAINER ';
    QryData.Params.ParamByName('Start_Time').AsString :=StartTime;
    QryData.Params.ParamByName('End_Time').AsString :=EndTime;
    QryData.open;



end;

procedure TfMainForm.FormShow(Sender: TObject);
var i:integer;
begin
  dtp1.Date := today-7;
  dtp3.Date := tomorrow;
  
    StartTime := FormatDateTime('YYYY/MM/DD',dtp1.date) +' '+FormatDateTime('HH:MM:SS',dtp2.time);
    EndTime := FormatDateTime('YYYY/MM/DD',dtp3.date) +' '+FormatDateTime('HH:MM:SS',dtp4.time);
    cmbDefect.Items.Clear;

    with QryTemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftstring,'Start_TIME',ptInput);
        Params.CreateParam(ftstring,'End_TIME',ptInput);

        CommandText :=' SELECT  C.Defect_Desc ,Count(*) qty FROM  SAJET.G_SN_DEFECT_FIRST B,'+
                      ' SAJET.SYS_DEFECT C WHERE   B.DEFECT_ID =C.DEFECT_ID AND B.REC_TIME >=TO_DATE( :START_TIME,''YYYY/MM/DD HH24:MI:SS'') '+
                      ' AND B.REC_TIME < TO_DATE(:END_TIME,''YYYY/MM/DD HH24:MI:SS'') AND B.STAGE_ID =10001 group by defect_desc order by qty desc ' ;
        Params.ParamByName('Start_Time').AsString :=StartTime;
        Params.ParamByName('End_Time').AsString :=EndTime;
        Open;

        First;
        for i:=0 to recordCount-1 do
        begin
            cmbDefect.Items.Add(fieldbyname('Defect_desc').AsString);
            next;
        end;


    end;

end;

procedure TfMainForm.btnExportClick(Sender: TObject);
 var ExcelApp: Variant; i: integer;
    strCarry,strDefect,strQty :string;
begin
    if dlgSave1.Execute then
    begin
        if FileExists(dlgSave1.FileName) then
           DeleteFile(dlgSave1.FileName);
        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.add;
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.WorkSheets[1].Name := 'ぃ▆更ㄣ癸莱参璸' ;
        ExcelApp.Cells[1,1].Value := 'ぃ▆更ㄣ癸莱参璸';
        ExcelApp.Cells[2,1].Value := '更ㄣ';
        ExcelApp.Cells[2,2].Value := 'ぃ▆瞷禜';
        ExcelApp.Cells[2,3].Value := '计秖';
        if not QryData.IsEmpty then
        begin
            QryData.First;
            for  i:=0 to QryData.RecordCount-1  do
            begin
                  strCarry :=QryData.FieldByName('CONTAINER').AsString ;
                  strDefect :=  QryData.FieldByName('DEFECT_DESC').AsString;
                  strQty :=  QryData.FieldByName('QTY').AsString;

                  ExcelApp.Cells[i+3,1].Value := strCarry;
                  ExcelApp.Cells[i+3,2].Value := strDefect;
                  ExcelApp.Cells[i+3,3].Value := strQty;

                  QryData.Next;
             end;
        end;
        ExcelApp.Columns[1].ColumnWidth :=22;
        ExcelApp.Columns[2].ColumnWidth :=22;
        ExcelApp.Columns[3].ColumnWidth :=22;
        ExcelApp.ActiveSheet.Range['A1:C1'].Merge;
        ExcelApp.ActiveSheet.Range['A1:C'+IntToStr(I+2)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:C'+IntToStr(I+2)].VerticalAlignment :=2;
        ExcelApp.ActiveSheet.Range['A1:C'+IntToStr(I+2)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:C'+IntToStr(I+2)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:C'+IntToStr(I+2)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:C'+IntToStr(I+2)].Borders[4].Weight := 2;


        ExcelApp.ActiveSheet.SaveAs(dlgSave1.FileName);
        ExcelApp.Quit;

        MessageDlg('Save OK',mtInformation,[mbok],0);
    end;


end;

procedure TfMainForm.dtp1Change(Sender: TObject);
var i:Integer;
begin

    StartTime := FormatDateTime('YYYY/MM/DD',dtp1.date) +' '+FormatDateTime('HH:MM:SS',dtp2.time);
    EndTime := FormatDateTime('YYYY/MM/DD',dtp3.date) +' '+FormatDateTime('HH:MM:SS',dtp4.time);
    cmbDefect.Items.Clear;

    with QryTemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftstring,'Start_TIME',ptInput);
        Params.CreateParam(ftstring,'End_TIME',ptInput);

        CommandText :=' SELECT  C.Defect_Desc ,Count(*) qty FROM  SAJET.G_SN_DEFECT_FIRST B,'+
                      ' SAJET.SYS_DEFECT C WHERE   B.DEFECT_ID =C.DEFECT_ID AND B.REC_TIME >=TO_DATE( :START_TIME,''YYYY/MM/DD HH24:MI:SS'') '+
                      ' AND B.REC_TIME < TO_DATE(:END_TIME,''YYYY/MM/DD HH24:MI:SS'') AND B.STAGE_ID =10001 group by defect_desc order by qty desc ' ;
        Params.ParamByName('Start_Time').AsString :=StartTime;
        Params.ParamByName('End_Time').AsString :=EndTime;
        Open;

        First;
        for i:=0 to recordCount-1 do
        begin
            cmbDefect.Items.Add(fieldbyname('Defect_desc').AsString);
            next;
        end;


    end;
end;

end.








