unit uDetail;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids,DateUtils;

type
  TfDetail = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    lblLabTitle1: TLabel;
    lblLabTitle2: TLabel;
    DateTimePicker1: TDateTimePicker;
    Label1: TLabel;
    sbtnQuery: TSpeedButton;
    ImageSample: TImage;
    sBtnExport: TSpeedButton;
    Image1: TImage;
    DataSource1: TDataSource;
    SaveDialog1: TSaveDialog;
    Label2: TLabel;
    DateTimePicker2: TDateTimePicker;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    QryAll: TClientDataSet;
    dbgrd1: TDBGrid;
    ds1: TDataSource;
    btn1: TSpeedButton;
    Label3: TLabel;
    procedure sbtnQueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBGrid2DblClick(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    G_sProcessList,G_sModelList : String;
    Count:Integer;
    UpDate_Time :TDateTime;
    sStartTime, sEndTime, sDStartTime, sDEndTime,sTime1,sTime2 :string;
    function QueryOutput(QryTemp1:TClientDataset;sStartTime,sEndTime:String):boolean;
  end;

var
  fDetail: TfDetail;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit,uSelect;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
begin
    if length(ComboBox1.Text)=1  then  sTime1 := '0' + ComboBox1.Text
    else  sTime1 := ComboBox1.Text;

    if length(ComboBox2.Text)=1  then  sTime2 := '0' + ComboBox2.Text
    else  sTime2 := ComboBox2.Text;

    sStartTime  := FormatDateTime('yyyymmdd',DateTimePicker1.Date)+ sTime1  ;
    sEndTime  := FormatDateTime('yyyymmdd',DateTimePicker2.Date)+ sTime2 ;

    //sDStartTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+ ' '+ sTime1+':00:00'  ;
    //sDEndTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker2.Date) + ' ' + sTime2 +':00:00' ;


    QueryOutput(QryData, sStartTime, sEndTime);
    //QueryDefect(QryDefect, sStartTime, sEndTime);

end;


function TfDetail.QueryOutput(QryTemp1:TClientDataset;sStartTime,sEndTime:String):boolean;
begin

    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.CommandText:=' select MODEL_NAME,shift_name,SUM(sum_DB_qty) DB_QTY,SUM(sum_HM_qty) HM_QTY from (select c.model_name, d.shift_name, '+
        ' sum(a.OUTPUT_QTY) sum_DB_qty,0 SUM_HM_QTY from (select   MODEL_ID ,PROCESS_ID,OUTPUT_QTY, shift_id, '+
        ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime  '+
        ' from SAJET.G_SN_COUNT ) a,sajet.sys_part b,sajet.sys_model c,sajet.sys_shift d   '+
        ' where   a.DateTime >:StartTime and  a.DateTime <:EndTime  and process_id=100220 and d.shift_id=a.shift_id '+
        ' and a.model_id=b.part_id and b.model_id=c.model_id group by c.model_name,d.shift_name   union  '+
        ' select c.model_name, d.shift_name,0 SUM_DB_QTY,                 '+
        ' sum(a.OUTPUT_QTY) sum_DB_qty from (select   MODEL_ID ,PROCESS_ID,OUTPUT_QTY, shift_id, '+
        ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime    '+
        ' from SAJET.G_SN_COUNT ) a,sajet.sys_part b,sajet.sys_model c,sajet.sys_shift d   '+
        ' where   a.DateTime >:StartTime and  a.DateTime <:EndTime  and process_id=100221 and d.shift_id=a.shift_id  '+
        ' and a.model_id=b.part_id and b.model_id=c.model_id group by c.model_name,d.shift_name)  '+
        ' group by MODEL_NAME,shift_name ORDER BY MODEL_NAME,SHIFT_NAME DESC';

    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sEndTime;
    QryTemp1.Open;
end;


procedure TfDetail.sBtnExportClick(Sender: TObject);
var
     strModel,strFirstModel,strDBTotal,strHMTotal,strShift :string;
     i,j,iRow:integer;
     ExcelApp: Variant;
begin
    if SaveDialog1.Execute then
    begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);

        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'COB MFG Report.xls');
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.WorkSheets[1].Name :=   FormatDateTime('MM.DD',Today) ;


        i:=0;
        j:=0;


        strFirstModel :='';
        with QryData do begin
            if not IsEmpty then begin
                 First;
                 iRow :=3;

                 for  i:=0 to QryData.RecordCount-1 do
                 begin
                     strModel  := FieldByName('Model_Name').AsString ;
                     if i=0  then  strFirstModel := strModel;
                     if strFirstModel <> strModel then begin
                           Inc(iRow);
                           strFirstModel  := strModel;
                     end;
                     StrDBTotal :=  FieldByName('DB_Qty').AsString ;
                     StrHMTotal :=  FieldByName('HM_Qty').AsString ;
                     strShift :=    FieldByName('Shift_Name').AsString;
                     ExcelApp.Cells[iRow,1].Value := iRow-2;
                     ExcelApp.Cells[iRow,2].Value := strModel;
                     if  strShift='¥Õ¯Z' then begin
                         ExcelApp.Cells[iRow,4].Value := StrDBTotal;
                         ExcelApp.Cells[iRow,13].Value := strHMTotal;
                     end;
                     if  strShift='±ß¯Z' then begin
                         ExcelApp.Cells[iRow,5].Value := StrDBTotal;
                         ExcelApp.Cells[iRow,14].Value := strHMTotal;
                     end;
                     ExcelApp.Cells[iRow,6].Value := ExcelApp.Cells[iRow,4].Value+ExcelApp.Cells[iRow,5].Value;
                     ExcelApp.Cells[iRow,15].Value := ExcelApp.Cells[iRow,13].Value+ExcelApp.Cells[iRow,14].Value;

                     Next;
                 end;
                 ExcelApp.Cells[2,3].Value := '=SUM(C3:C'+IntToStr(iRow)+')';
                 ExcelApp.Cells[2,4].Value := '=SUM(D3:D'+IntToStr(iRow)+')';
                 ExcelApp.Cells[2,5].Value := '=SUM(E3:E'+IntToStr(iRow)+')';
                 ExcelApp.Cells[2,6].Value := '=SUM(F3:F'+IntToStr(iRow)+')';
                 for j:=2 to iRow do begin
                    ExcelApp.Cells[j,7].Value := '= F'+InttoStr(j) +'/C'+InttoStr(j);
                    ExcelApp.Cells[j,16].Value := '= O'+InttoStr(j) +'/C'+InttoStr(j);
                 end;
                 ExcelApp.Cells[2,13].Value := '=SUM(M3:M'+IntToStr(iRow)+')';
                 ExcelApp.Cells[2,14].Value := '=SUM(N3:N'+IntToStr(iRow)+')';
                 ExcelApp.Cells[2,15].Value := '=SUM(O3:O'+IntToStr(iRow)+')';

                 ExcelApp.ActiveSheet.Range['G2:G'+IntToStr(iRow)].NumberFormat:='0.00%';
                 ExcelApp.ActiveSheet.Range['P2:P'+IntToStr(iRow)].NumberFormat:='0.00%';
                 ExcelApp.ActiveSheet.Range['A2:U'+IntToStr(iRow)].Font.Name :='Tahoma';
                 ExcelApp.ActiveSheet.Range['A2:U'+IntToStr(iRow)].Font.Size :=9;
                 ExcelApp.ActiveSheet.Range['A2:U'+IntToStr(iRow)].Borders[1].Weight := 2;
                 ExcelApp.ActiveSheet.Range['A2:U'+IntToStr(iRow)].Borders[2].Weight := 2;
                 ExcelApp.ActiveSheet.Range['A2:U'+IntToStr(iRow)].Borders[3].Weight := 2;
                 ExcelApp.ActiveSheet.Range['A2:U'+IntToStr(iRow)].Borders[4].Weight := 2;
                 ExcelApp.ActiveSheet.Range['A2:U'+IntToStr(iRow)].HorizontalAlignment :=3;
                 ExcelApp.ActiveSheet.Range['A2:U'+IntToStr(iRow)].VerticalAlignment :=2;

            end;

        end;





       ExcelApp.WorkSheets[1].Activate;
       ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
       ExcelApp.Quit;
       MessageDlg('Save OK',mtConfirmation,[mbyes],0);

    end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var i:integer;
begin

    DateTimePicker1.Date :=  Yesterday;
    DateTimePicker2.Date :=  Today;

end;

procedure TfDetail.DBGrid2DblClick(Sender: TObject);
begin
  //
  
end;

end.
