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
    QryDetail: TClientDataSet;
    QrySum: TClientDataSet;
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
    DBGrid1: TDBGrid;
    SaveDialog1: TSaveDialog;
    Label2: TLabel;
    DateTimePicker2: TDateTimePicker;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    QryDate: TClientDataSet;
    DataSource2: TDataSource;
    LV_Role: TListView;
    procedure sBtnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    sFileName,sMonth,sStartTime,sEndTime,ssStartTime,ssEndTime: string;
    IsFound :boolean;
    function GetSysDate:TDatetime;
    procedure QueryDetail(QryTemp1:TClientDataset;StartTime,EndTime:string);
    procedure QuerySummary(QryTemp1:TClientDataset;StartTime,EndTime,sStartTime,sEndTime:string);
    function AddZero(s:string;HopeLength:Integer):String;
  end;

var
  fDetail: TfDetail;



implementation

{$R *.dfm}
uses uDllform,DllInit, UFrmList;

function TfDetail.GetSysDate:TDateTime;
begin
    QryDate.Close;
    QryDate.CommandText := 'select SysDate from  dual';
    QryDate.Open;
    result := QryDate.fieldbyname('SYSDate').AsDateTime;
end;


procedure TfDetail.QueryDetail(QryTemp1:TClientDataset;StartTime,EndTime:string);
begin

    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'START_TIME',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'END_TIME',ptInput);
    QryTemp1.CommandText := ' select pdline_name,SN,out_process_time,emp_name,defect_desc,vi_name,rec_Time from '+
                            ' (select pdline_name,SN,out_process_time,emp_name,vi_name,rec_Time ,defect_desc,'+
                            ' ROW_NUMBER() OVER(partition by  sn ORDER BY out_process_time DESC)  ran from  '+
                            ' (select d.pdline_name,b.defect_desc, decode(c.customer_sn,''N/A'',                          '+
                            ' c.serial_number,c.Customer_SN) SN,c.out_process_time,e.emp_name,A.REC_TIME ,f.emp_name VI_Name  '+
                            ' from sajet.g_sn_defect a,sajet.sys_defect b, sajet.g_sn_travel c ,sajet.sys_pdline d,sajet.sys_emp e ,sajet.sys_emp f '+
                            ' where A.REC_TIME>=to_date(:start_time,''YYYY/MM/DD HH24:MI:SS'') and A.REC_TIME <to_date(:end_time,''YYYY/MM/DD HH24:MI:SS'')'+
                            ' and A.SERIAL_NUMBER =C.SERIAL_NUMBER and a.defect_id =b.defect_id and a.process_id =100215 and c.process_id =100266 and a.test_emp_id=f.emp_ID  '+
                            ' and b.defect_desc like ''%膠%'' and c.pdline_id=d.pdline_id and c.emp_id=e.emp_id and c.out_process_time < a.rec_time ' +
                            ' )) where ran=1 ';
    QryTemp1.Params.ParamByName('START_TIME').AsString :=  StartTime;
    QryTemp1.Params.ParamByName('End_Time').AsString :=    EndTime;
    QryTemp1.Open;

end;


procedure TfDetail.QuerySummary(QryTemp1:TClientDataset;StartTime,EndTime,sStartTime,sEndTime:string);
begin

    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'START_TIME',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'sSTART_TIME',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'END_TIME',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'sEND_TIME',ptInput);
    QryTemp1.CommandText :=  '  select aa.model_name,aa.pdline_name,aa.workdate,aa.ihours,bb.total_qty,aa.ih,aa.allCount fail_QTY  '+
                             '  from (select  model_name,pdline_name, workdate,substr(workdate,9,2) iHours,(to_date(workdate,''YYYYMMDDhh24'') '+
                             '  -to_date(:START_TIME,''YYYY/MM/DD HH24:MI:SS''))*24 IH,count(*) allCount  from     '+
                             '  (select model_name,pdline_name,SN,out_process_time,emp_name,rec_Time,to_char(out_process_time,''YYYYMMDDHH24'')  '+
                             '  as workdate from  (select model_name,pdline_name,SN,out_process_time,emp_name,rec_Time ,'+
                             '  ROW_NUMBER() OVER(partition by  sn ORDER BY out_process_time DESC) '+
                             '  ran from (select h.model_name,d.pdline_name,decode(c.customer_sn,''N/A'',  c.serial_number,c.Customer_SN) SN,c.out_process_time, '+
                             '  e.emp_name,A.REC_TIME  from sajet.g_sn_defect a,sajet.sys_defect b, sajet.g_sn_travel c ,sajet.sys_pdline d,sajet.sys_emp e ,sajet.sys_part f,sajet.sys_model h  '+
                             '  where A.REC_TIME>=to_date(:START_TIME,''YYYY/MM/DD HH24:MI:SS'') and '+
                             '  A.REC_TIME <to_date(:End_Time,''YYYY/MM/DD HH24:MI:SS'')+1/2   '+
                             '  and A.SERIAL_NUMBER =C.SERIAL_NUMBER and a.defect_id =b.defect_id and a.process_id =100215 and c.process_id =100266 and '+
                             '  d.pdline_Name like ''CM%''   and b.defect_desc like ''%膠%'' and c.pdline_id=d.pdline_id and c.emp_id=e.emp_id '+
                             '  and a.model_id=f.part_id and f.model_id=h.model_id '+
                             '  and c.out_process_time < a.rec_time )) where ran=1  )   '+
                             '  where workdate >= :sStart_Time and workdate< :sEnd_Time group by model_name,pdline_name,workdate order by '+
                             '  Model_name,pdline_name,workdate) aa,'+
                             '  (select   model_name,pdline_name,sum(pass_qty+fail_qty) total_qty  from     '+
                             '  (select c.model_name,d.pdline_name,a.pass_qty,a.fail_qty ,to_char(a.work_date||trim(to_char(a.work_time,''00''))) date_time   '+
                             '  from sajet.g_sn_count a,sajet.sys_part b,sajet.sys_model c,sajet.sys_pdline d      '+
                             '  where to_char(a.work_date||trim(to_char(a.work_time,''00''))) >= :sSTART_TIME and a.process_id=100266     '+
                             '  and to_char(a.work_date||trim(to_char(a.work_time,''00''))) < :sEnd_Time    '+
                             '  and a.model_id=b.part_id and b.model_id=c.model_id and a.pdline_id=d.pdline_id)    '+
                             '  group by model_name,pdline_name) bb '+
                             '  where  aa.pdline_name =bb.pdline_name and aa.model_name=bb.model_name    '+
                             '  order by pdline_name,model_name,workdate ';
    QryTemp1.Params.ParamByName('START_TIME').AsString :=  StartTime;
    QryTemp1.Params.ParamByName('End_Time').AsString :=   EndTime;
    QryTemp1.Params.ParamByName('sSTART_TIME').AsString :=  sStartTime;
    QryTemp1.Params.ParamByName('sEnd_Time').AsString :=   sEndTime;
    QryTemp1.Open;

end;

function TfDetail.AddZero(s:string;HopeLength:Integer):String;
begin
     Result:=StringReplace(Format('%'+IntToStr(HopeLength)+'s',[s]),' ','0',[rfIgnoreCase,rfReplaceAll]);
end;

procedure TfDetail.sBtnExportClick(Sender: TObject);
var  sTemp,sDate,sFirstPdline,sPdline,sFirstModel,sModel:string;
    ExcelApp,ChartObjects,xRange,yRange,lRange: Variant;
    i,j,k,iHourCount,usedRows:integer;
begin

    if not QrySum.Active then Exit;
    if QrySum.IsEmpty then Exit;
    if SaveDialog1.Execute then
    begin
        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'CCM Glue Except Report_V2.xlsx');
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.Cells[1,1].Value :='CM 點膠異常統計';

        iHourCount :=  Round((StrToDateTime(sEndTime)- StrToDateTime(sStartTime))*24);

        if iHourCount>24 then iHourCOunt :=24;
        for i:=0 to iHourCount -1 do
             ExcelApp.Cells[3,6+i].Value := FormatDateTime('HH',(StrToDateTime(sStartTime)+i/24)) ;

        QrySum.First;
        sFirstPdline := QrySum.FieldByName('PDLINE_NAME').AsString;
        sFirstModel :=  QrySum.FieldByName('Model_NAME').AsString;
        usedRows :=4;
        ExcelApp.Cells[usedRows,1].Value := sFirstPdline ;
        ExcelApp.Cells[usedRows,2].Value := sFirstModel ;
        ExcelApp.Cells[usedRows,3].Value := QrySum.FieldByName('Total_Qty').AsString; ;
        ExcelApp.Cells[usedRows,4].Value := '=E'+IntTostr(usedRows)+ '/C'+IntTostr(usedRows);
        ExcelApp.Cells[usedRows,5].Value := '=SUM(F'+IntTostr(usedRows)+ ':AC'+IntTostr(usedRows)+')' ;
        for j:=0 to  QrySum.recordCOunt-1 do
        begin
             sPdline := QrySum.FieldByName('PDLINE_NAME').AsString;
             sModel :=  QrySum.FieldByName('Model_NAME').AsString;
             if (sPdline <> sFirstPdline) or (sModel <> sFirstModel) then begin
                 inc(usedRows);
                 sFirstPdline := sPdline;
                 sFirstModel :=  sModel ;
                 ExcelApp.Cells[usedRows,1].Value := sPdline ;
                 ExcelApp.Cells[usedRows,2].Value := sFirstModel ;
                 ExcelApp.Cells[usedRows,3].Value := QrySum.FieldByName('Total_Qty').AsString; ;
                 ExcelApp.Cells[usedRows,4].Value := '=E'+IntTostr(usedRows)+ '/C'+IntTostr(usedRows);
                 ExcelApp.Cells[usedRows,5].Value := '=SUM(F'+IntTostr(usedRows)+ ':AC'+IntTostr(usedRows)+')' ;
             end;


             k :=QrySum.FieldByName('IH').AsInteger;
             ExcelApp.Cells[usedRows,k+6].Value := QrySum.FieldByName('FaiL_qty').AsInteger; ;
             QrySum.Next;
        end;
        ExcelApp.ActiveSheet.Range['A3:AC'+IntToStr(usedRows)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A3:AC'+IntToStr(usedRows)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A3:AC'+IntToStr(usedRows)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A3:AC'+IntToStr(usedRows)].Borders[4].Weight := 2;
        ExcelApp.ActiveSheet.Range['D4:D'+IntToStr(usedRows)].NumberFormat  := '0.00%';
        ExcelApp.ActiveSheet.Range['A1:AC'+IntToStr(usedRows)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:AC'+IntToStr(usedRows)].VerticalAlignment :=2;

        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.ActiveWorkbook.SaveAs(saveDialog1.FileName);
        ExcelApp.Quit;
        ExcelApp :=Unassigned;
    end;
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
   DateTimePicker1.Date :=Now;
   DateTimePicker2.Date :=Tomorrow;
end;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
begin
    sStartTime  := FormatDateTime('YYYY/MM/DD ',DateTimePicker1.Date)+AddZero(ComboBox1.Text,2) +':00:00';
    sEndTime    := FormatDateTime('YYYY/MM/DD ',DateTimePicker2.Date)+AddZero(ComboBox2.Text,2) +':00:00';
    ssStartTime := FormatDateTime('YYYYMMDD',DateTimePicker1.Date)+AddZero(ComboBox1.Text,2) ;
    ssEndTime   := FormatDateTime('YYYYMMDD',DateTimePicker2.Date)+AddZero(ComboBox2.Text,2) ;
    //-------
    //iDate := StrToInt(FormatDateTime('DD',GetSysDate-1));
    QuerySummary(QrySum,sStartTime,sEndTime,ssStartTime,ssEndTime);
    
end;

end.
