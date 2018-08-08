unit uDetail;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids,DateUtils,Excel2000;

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
    DBGrid1: TDBGrid;
    SaveDialog1: TSaveDialog;
    Label2: TLabel;
    DateTimePicker2: TDateTimePicker;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    DBGrid2: TDBGrid;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    cmbModel: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    cmbLine: TComboBox;
    Label5: TLabel;
    edtWo: TEdit;
    chkDefect: TCheckBox;
    QryDate: TClientDataSet;
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
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID : String;
    Count:Integer;
    UpDate_Time :TDateTime;
    sStartTime, sEndTime, sDStartTime, sDEndTime,sTime1,sTime2 :string;
    function QueryOutput( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function QueryDefectSN(QryTemp1:TClientDataset;sStartTime,sEndTime:String):boolean;
    function GetSysDate:TDateTime;
  end;

var
  fDetail: TfDetail;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit;

function TfDetail.GetSysDate:TDateTime;
begin
    QryDate.Close;
    QryDate.CommandText := 'select SysDate from  dual';
    QryDate.Open;
    result := QryDate.fieldbyname('SYSDate').AsDateTime;
end;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
begin
    if length(ComboBox1.Text)=1  then  sTime1 := '0' + ComboBox1.Text
    else  sTime1 := ComboBox1.Text;

    if length(ComboBox2.Text)=1  then  sTime2 := '0' + ComboBox2.Text
    else  sTime2 := ComboBox2.Text;

    sStartTime  := FormatDateTime('yyyymmdd',DateTimePicker1.Date)+ sTime1  ;
    sEndTime  := FormatDateTime('yyyymmdd',DateTimePicker2.Date)+ sTime2 ;

    sDStartTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+ ' '+ sTime1+':00:00'  ;
    sDEndTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker2.Date) + ' ' + sTime2 +':00:00' ;

    QueryOutput(QryData, sStartTime, sEndTime);
    QueryDefect(QryDefect,sDStartTime,sDEndTime);
    DbGrid2.Columns[0].Width :=120;
    DbGrid2.Columns[1].Width :=120;
    DbGrid2.Columns[2].Width :=240;
    DbGrid2.Columns[3].Width :=120;
end;


function TfDetail.QueryOutput(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'WO',ptInput);
    QryTemp1.CommandText:=' select B.PROCESS_NAME, B.PROCESS_CODE, '+
                          ' DECODE((SUM(C.PASS_QTY)), NULL, 0, (SUM(C.PASS_QTY))) FPY_QTY , '+
                          ' DECODE((SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.FAIL_QTY))) FAIL_QTY, '+
                          ' DECODE((SUM(C.OUTPUT_QTY)), NULL, 0, (SUM(C.OUTPUT_QTY))) Output_QTY, '+
                          ' DECODE((SUM(C.REPAIR_QTY)), NULL, 0, (SUM(C.REPAIR_QTY))) REPAIR_QTY, ' +
                          ' DECODE((SUM(C.NTF_QTY)), NULL, 0, (SUM(C.NTF_QTY))) NTF_QTY, '+
                          ' DECODE((SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY))) TOTAL_QTY , '+
                          ' round(DECODE(SUM(C.PASS_QTY),  NULL, 0,SUM(C.PASS_QTY)) / DECODE(SUM(C.PASS_QTY) +SUM(C.FAIL_QTY), NULL, 0,0,1000000000, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)))*100,2)  as "FPY(%)" , '+
                          ' round( DECODE( SUM(C.PASS_QTY) +SUM(C.NTF_QTY), NULL, 0,0,1, SUM(C.PASS_QTY) +SUM(C.NTF_QTY) )  / DECODE(  SUM(C.PASS_QTY+C.FAIL_QTY), NULL, 0,0,100000000 ,(SUM(C.PASS_QTY +C.FAIL_QTY)))*100,2) as "SPY(%)" , '+
                          ' round( DECODE( SUM(C.PASS_QTY +C.NTF_QTY+C.Repair_QTY), NULL, 0,0,1, SUM(C.PASS_QTY +C.NTF_QTY+C.RePair_QTY) )  / DECODE(  SUM(C.PASS_QTY+C.FAIL_QTY), NULL, 0,0,100000000 ,(SUM(C.PASS_QTY +C.FAIL_QTY)))*100,2) as "Final Yield(%)" '+
                          ' FROM   SAJET.SYS_PROCESS B ,  ' +
                          ' (select WORK_ORDER,MODEL_ID,PDLINE_ID,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REFAIL_QTY,OUTPUT_QTY,NTF_QTY,Repair_qty,to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime  '+
                          ' from SAJET.G_SN_COUNT where    PASS_QTY+FAIL_QTY <>0 )  C ,sajet.sys_part d ,sajet.sys_Part e,sajet.sys_model f' +
                          ' ,sajet.sys_pdline g  where  c.pdline_ID=g.PDLINE_ID and              '+
                          ' C.DateTime >=:StartTime and C.DateTime <:endTime   AND '+
                          //' DECODE((SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)))  <> 0 AND  '+
                          ' c.model_ID =d.Part_ID and C.Model_ID = E.Part_ID and e.Model_ID= f.Model_ID and C.PROCESS_ID = B.PROCESS_ID   '+
                          ' and B.PROCESS_NAME NOT LIKE ''%REPAIR%'' and  B.PROCESS_CODE IS NOT NULL AND ';
     if Pos('%',cmbModel.Text)>=0 then
            QryTemp1.CommandText:=  QryTemp1.CommandText+' f.MOdel_Name like '''+cmbModel.Text+''''
     else
          QryTemp1.CommandText:=  QryTemp1.CommandText+' f.MOdel_Name ='''+cmbModel.Text+'''';
     if CmbLine.text <> '' then
           QryTemp1.CommandText:=  QryTemp1.CommandText+' and  g.PDLINE_NAME = '''+cmbLine.Text+'''';


     QryTemp1.CommandText:=  QryTemp1.CommandText+' and  c.WORK_ORDER  like :WO ';

     QryTemp1.CommandText:=  QryTemp1.CommandText+ '  GROUP BY B.PROCESS_NAME, B.PROCESS_CODE   ORDER BY B.PROCESS_CODE ';

    QryTemp1.Params.ParamByName('WO').AsString := edtwo.text+'%';
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sEndTime;
    QryTemp1.Open;
end;

function TfDetail.QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'WO',ptInput);
    QryTemp1.CommandText:= 'select Process_NAME ,Process_Code, DEFECT_CODE ,Defect_desc,count(C_SN) AS COUNT  '+
                           ' from  '+
                           ' (   select Serial_number,PROCESS_NAME,Process_Code, DEFECT_CODE,Defect_desc,C_SN from  '+
                           '     ( '+
                           '      select   a.Serial_number,B.PROCESS_NAME ,b.Process_Code,c.defect_code, '+
                           '     c.Defect_desc,1 as C_SN   from '+
                           '     sajet.g_SN_defect_first a,sajet.SYS_PROCESS b,sajet.sys_defect c ,sajet.sys_part d , sajet.sys_Model e ,sajet.sys_pdline f '+
                           '     where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyy/mm/dd hh24:mi:ss'') '+
                           '    and a.REC_Time <to_date(:EndTime, ''yyyy/mm/dd hh24:mi:ss'')   '+
                           '     and a.MOdel_ID=d.Part_ID and e.MOdel_ID =d.Model_ID and  a.pdline_id =f.pdline_ID and ';
    //if chkRetest.Checked then
             // QryTemp1.CommandText:=  QryTemp1.CommandText+' a.ntf_time is null and ';

     if Pos('%',cmbModel.Text)>=0 then
            QryTemp1.CommandText:=  QryTemp1.CommandText+' e.MOdel_Name like '''+cmbModel.Text+''''
     else
          QryTemp1.CommandText:=  QryTemp1.CommandText+' e.MOdel_Name ='''+cmbModel.Text+'''';

     if CmbLine.text <> '' then
           QryTemp1.CommandText:=  QryTemp1.CommandText+' and  f.PDLINE_NAME = '''+cmbLine.Text+'''';

     QryTemp1.CommandText:=  QryTemp1.CommandText+' and  a.WORK_ORDER  like :wo';


     QryTemp1.CommandText:=  QryTemp1.CommandText+' group by  B.PROCESS_NAME ,b.Process_Code, C.defect_Code, c.Defect_desc ,a. Serial_number '+
                           '    )'+
                           ' )  '+
                           ' group by Process_NAME,Process_Code,DEFECT_CODE ,Defect_desc '+
                           ' order  by Process_Code, Count desc ' ;

    QryTemp1.Params.ParamByName('WO').AsString := edtWo.Text+'%';
    QryTemp1.Params.ParamByName('StartTime').AsString := sDStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sDEndTime;
    QryTemp1.Open;
end;


function TfDetail.QueryDefectSN(QryTemp1:TClientDataset;sStartTime,sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'WO',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'DEFECT',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'PROCESS',ptInput);
    QryTemp1.CommandText:= '      select * from  (select  e.Model_Name,a.rec_time ,decode(g.customer_sn ,''N/A'', '+
                           '      a.Serial_number,g.customer_sn) customer_sn, a.rp_status, a.RECEIVE_TIME,'+
                           '      B.PROCESS_NAME ,B.PROCESS_CODE,C.defect_code,  decode(a.ntf_time,null,h.Repair_time,a.ntf_time)  Repair_time, '+
                           '      c.Defect_desc , decode(a.ntf_time,null,j.reason_desc,''代OK'') reason_desc from '+
                           '      sajet.g_SN_defect_first a, sajet.SYS_PROCESS b, sajet.sys_defect c , sajet.sys_part d , '+
                           '      sajet.sys_Model e , sajet.sys_pdline f , sajet.g_sn_status g , sajet.g_sn_repair h ,'+
                           '      sajet.sys_reason j '+
                           '      where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and '+
                           '      a.REC_Time >= to_date(:StartTime, ''yyyy/mm/dd hh24:mi:ss'') '+
                           '      and a.REC_Time <to_date(:EndTime, ''yyyy/mm/dd hh24:mi:ss'') '+
                           '      and   a.serial_number=g.serial_number '+
                           '      and h.reason_id  =j.reason_id(+) and a.serial_number = h.serial_number(+)   '+
                           '      and a.MOdel_ID=d.Part_ID and e.MOdel_ID =d.Model_ID and  a.pdline_id =f.pdline_ID and ';
    //if chkRetest.Checked then
             //QryTemp1.CommandText:=  QryTemp1.CommandText+ ' a.ntf_time is null and ';
             

     if Pos('%',cmbModel.Text)>=0 then
            QryTemp1.CommandText:=  QryTemp1.CommandText+' e.MOdel_Name like '''+cmbModel.Text+''''
     else
          QryTemp1.CommandText:=  QryTemp1.CommandText+' e.MOdel_Name ='''+cmbModel.Text+'''';

     if CmbLine.text <> '' then
           QryTemp1.CommandText:=  QryTemp1.CommandText+' and  f.PDLINE_NAME = '''+cmbLine.Text+'''';

    QryTemp1.CommandText:=  QryTemp1.CommandText+' and  a.WORK_ORDER  like :wo  ) where repair_time >rec_time  '+
                            ' or repair_time is null order by PROCESS_CODE,customer_sn, rec_time ';

    QryTemp1.Params.ParamByName('WO').AsString := edtWO.Text+'%';
    QryTemp1.Params.ParamByName('StartTime').AsString := sDStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sDEndTime;
    QryTemp1.Open;

end;

procedure TfDetail.sBtnExportClick(Sender: TObject);
var
    strNTF,sModelName :string;
    strTitle,strFPY,strPDline,strPDLineFrist,strRepass,strTotal,strDefectName,strDefect_QTY,strDefect_Desc,strFailAll,sDefect_Code :string;
    i,j,K,L,M,FirstCount,UsedRow,AllRows,UsedHours,defect_count,count,HourCount,Repair_Qty,Process_Fail,FAIL_QTY,StartCol,EndCol,tempCount:integer;
    ExcelApp,xRange,yRange,ChartObjects: Variant;
    tempStart,tempEnd,tempHStart,tempHEnd,sProcess,FPY_Target,sXValue,stage_Name:string;
    Rowlist,SPYRowlist,FinalRowList,AllRow_list:TStringList;
    FPY,SPY,FinalYield, Total_FPY,Total_SPY,Total_FinalYield:double;
    IsFound :boolean;
    Defect_Start,Defect_End:TDateTime;
    sDefect_Start,sDefect_End,sAll_Defect,StartColName,endColName:String;
    TotalRowList,OutPutRowList,RepassRowList,overallSPYROWList:TStringList ;
begin

    Application.ProcessMessages();

    ExcelApp :=CreateOleObject('Excel.Application');
    ExcelApp.Visible := False;
    ExcelApp.displayAlerts:=false;
    ExcelApp.WorkBooks.Add;

     sModelName :=  cmbModel.Text;

     AllRow_list :=TStringList.Create;
     ExcelApp.Worksheets.Add(After:=ExcelApp.Sheets[i+1]);
     ExcelApp.WorkSheets[i+1].Activate;


     ExcelApp.WorkSheets[i+1].Name := sModelName;


     ExcelApp.Cells[2,2].Value :='';
     ExcelApp.Cells[2,3].Value :='';


     ExcelApp.Cells[1,1].Value :=  sModelName +' Daily Report';
     ExcelApp.Cells[1,1].Font.Size := 18;
     ExcelApp.Cells[1,1].Font.Name := 'Tahoma';
     ExcelApp.Cells[1,1].Font.Bold := false;
     ExcelApp.Cells[1,1].Font.Color :=clwhite;
     ExcelApp.Cells[1,1].Interior.Color :=rgb(0,32,96);
     ExcelApp.Rows[1].RowHeight :=28;
     ExcelApp.Range['A1:AB1'].Merge;

     ExcelApp.ActiveSheet.Range['D15:P15'].Font.Bold :=true;
     ExcelApp.ActiveSheet.Range['D15:P15'].Font.Color :=clwhite;
     ExcelApp.ActiveSheet.Range['D15:P15'].Interior.Color :=rgb(155,187,90);

     ExcelApp.ActiveSheet.Range['Q15:AB15'].Font.Bold :=true;
     ExcelApp.ActiveSheet.Range['Q15:AB15'].Font.Color :=clwhite;
     ExcelApp.ActiveSheet.Range['Q15:AB15'].Interior.Color :=rgb(155,137,90);

     ExcelApp.Cells[16,4].Value := 'Target(%)';
     ExcelApp.Cells[17,4].Value := 'FPY(%)';
     ExcelApp.Cells[18,4].Value := 'SPY(%)';
     ExcelApp.Cells[19,4].Value := 'Final Yield(%)';
     ExcelApp.Cells[15,29].Value := 'Today';
     ExcelApp.ActiveSheet.Range['AC15:AC19'].Interior.Color :=rgb(230,185,184);
     ExcelApp.ActiveSheet.Range['AC15:AC19'].Font.Bold :=True;

     ExcelApp.Columns[1].ColumnWidth :=12.5;
     ExcelApp.Columns[2].ColumnWidth :=5;
     ExcelApp.Columns[3].ColumnWidth :=12;
     ExcelApp.Columns[4].ColumnWidth :=12;
     for j:=0 to 23 do ExcelApp.Columns[5+j].ColumnWidth :=5.5;


     ChartObjects :=ExcelApp.ActiveSheet.ChartObjects.add(192,30,946,200);
     ChartObjects.Chart.ChartType:=xlLineMarkers;
     chartObjects.chart.SetSourceData(ExcelApp.ActiveSheet.Range['D15:AB19']);
     ChartObjects.Chart.PlotBy:=xlRows;
     if  StrToInt(FormatDateTime('HH',GetSysdate)) <= 8 then  begin
          Defect_Start := GetSysdate-1 ;
          sDefect_Start :=  FormatDateTime('yyyy/mm/dd',GetSysdate-1)+' 08:00:00' ;
          Defect_End :=  GetSysdate ;
          sDefect_End :=  FormatDateTime('yyyy/mm/dd',GetSysdate)+' 08:00:00' ;
     end else
     begin
          Defect_Start := GetSysdate ;
          sDefect_Start :=  FormatDateTime('yyyy/mm/dd',GetSysdate)+' 08:00:00' ;
          Defect_End :=  GetSysdate+1 ;
          sDefect_End := FormatDateTime('yyyy/mm/dd',GetSysdate+1)+' 08:00:00' ;
     end;


     QueryProcessName(QryTemp2,sStartTime,sEndTime);
     sAllProcess :='( ';
     if QryTemp2.IsEmpty then exit;
     QryTemp2.First;
     for j:=0 to QryTemp2.RecordCount-1 do  begin
           strTitle := QryTemp2.FieldByName('PROCESS_NAME').AsString ;
           stage_name := QryTemp2.FieldByName('stage_name').AsString ;
           sAllProcess :=   sAllProcess+'''' + strTitle +''',' ;
           QryTemp2.Next;
     end;
     sAllProcess :=Copy(sAllProcess ,1,Length(sAllProcess)-1)+')';


    with QryTemp do
    begin
        close;
        Params.Clear;
        Params.CreateParam(ftstring,'Model_Name',ptInput);
        commandtext := 'select a.Upper_level from  SAJET.SYS_MODEL_RATE a,sajet.SYS_MODEL B where a.model_ID=b.MODEL_ID '+
                        '  and b.Model_NAME =:MODEL_NAME';
        Params.ParamByName('MODEL_NAME').AsString := sModelName;
        Open;

         if IsEmpty then begin
             FPY_Target :='95';
         end else
              FPY_Target := fieldbyName('Upper_level').AsString;
    end;

     QryTemp2.First;
     TotalRowList :=TStringList.create;
     OutPutRowList := TStringList.create;
     RepassRowList := TStringList.create;
     overallSPYROWList :=  TStringList.create;

     for  j:=0 to QryTemp2.RecordCount-1  do
     begin
         strTitle := QryTemp2.FieldByName('PROCESS_NAME').AsString ;
         Process_Fail := QryTemp2.FieldByName('PROCESS_FAIL').AsInteger ;
         ExcelApp.Cells[UsedRow+1,1].Value :=  strTitle;
         ExcelApp.Cells[UsedRow+1,3].Value :=  'Total Input';
         ExcelApp.Cells[UsedRow+2,3].Value :=  'First Output';
         ExcelApp.Cells[UsedRow+1,4].Value :=  '=SUM(E'+IntToStr(UsedRow+1)+':AB'+InttoStr(UsedRow+1)+')';
         ExcelApp.Cells[UsedRow+2,4].Value :=  '=SUM(E'+IntToStr(UsedRow+2)+':AB'+InttoStr(UsedRow+2)+')';
         ExcelApp.Cells[UsedRow+1,29].Value :=  '=SUM('+StartColName+IntToStr(UsedRow+1)+':'+EndColName+InttoStr(UsedRow+1)+')';
         ExcelApp.Cells[UsedRow+2,29].Value :=  '=SUM('+StartColName+IntToStr(UsedRow+2)+':'+EndColName+InttoStr(UsedRow+2)+')';
         TotalRowList.Add(IntToStr(UsedRow+1));
         OutPutRowList.Add(IntToStr(UsedRow+2));


         if  Process_Fail <> 0 then begin
             ExcelApp.Cells[UsedRow+3,3].Value :=  'Total Defect';
             ExcelApp.Cells[UsedRow+4,3].Value :=  'Retest Pass';
             ExcelApp.Cells[UsedRow+5,3].Value :=  'Final NG';
             ExcelApp.Cells[UsedRow+6,3].Value :=  'Repair Q''ty';
             RepassRowList.Add(IntToStr(UsedRow+4));
             ExcelApp.Cells[UsedRow+7,3].Value :=  'FPY(%)';
             ExcelApp.Cells[UsedRow+8,3].Value :=  'Retest Yield(%)';
             overallSPYROWList.Add(IntToStr(UsedRow+7));
             ExcelApp.Cells[UsedRow+9,3].Value :=  'SPY(%)';
             ExcelApp.Cells[UsedRow+10,3].Value := 'Final(%)';
             ExcelApp.Cells[UsedRow+3,29].Value  :=  '=SUM('+StartColName+IntToStr(UsedRow+3)+':'+EndColName+InttoStr(UsedRow+3)+')';
             ExcelApp.Cells[UsedRow+4,29].Value  :=  '=SUM('+StartColName+IntToStr(UsedRow+4)+':'+EndColName+InttoStr(UsedRow+4)+')';
             ExcelApp.Cells[UsedRow+5,29].Value  :=  '=SUM('+StartColName+IntToStr(UsedRow+5)+':'+EndColName+InttoStr(UsedRow+5)+')';
             ExcelApp.Cells[UsedRow+6,29].Value  :=  '=SUM('+StartColName+IntToStr(UsedRow+6)+':'+EndColName+InttoStr(UsedRow+6)+')';
             ExcelApp.Cells[UsedRow+7,29].Value  :=  '= IF(AC'+IntToStr(UsedRow+1)+'=0,100,AC'+IntToStr(UsedRow+2)+'/AC'+InttoStr(UsedRow+1)+'*100)';
             ExcelApp.Cells[UsedRow+8,29].Value  :=  '= IF(AC'+InttoStr(UsedRow+3)+'=0,0,AC'+IntToStr(UsedRow+4)+'/AC'+InttoStr(UsedRow+3)+'*100)';
             ExcelApp.Cells[UsedRow+9,29].Value  :=  '= IF(AC'+IntToStr(UsedRow+1)+'=0,100,(AC'+IntToStr(UsedRow+4)+'+AC'+IntToStr(UsedRow+2)+')/AC'+InttoStr(UsedRow+1)+'*100)';
             ExcelApp.Cells[UsedRow+10,29].Value := '=IF(AC'+IntToStr(UsedRow+1)+'=0,100,(AC'+IntToStr(UsedRow+4)+'+AC'+IntToStr(UsedRow+2)+'+AC'+IntToStr(UsedRow+6)+')/AC'+InttoStr(UsedRow+1)+'*100)';

             ExcelApp.Cells[UsedRow+3,4].Value  :=  '=SUM(E'+IntToStr(UsedRow+3)+':AB'+InttoStr(UsedRow+3)+')';
             ExcelApp.Cells[UsedRow+4,4].Value  :=  '=SUM(E'+IntToStr(UsedRow+4)+':AB'+InttoStr(UsedRow+4)+')';
             ExcelApp.Cells[UsedRow+5,4].Value  :=  '=SUM(E'+IntToStr(UsedRow+5)+':AB'+InttoStr(UsedRow+5)+')';
             ExcelApp.Cells[UsedRow+6,4].Value  :=  '=SUM(E'+IntToStr(UsedRow+6)+':AB'+InttoStr(UsedRow+6)+')';
             ExcelApp.Cells[UsedRow+7,4].Value  :=  '= IF(D'+IntToStr(UsedRow+1)+'=0,100,D'+IntToStr(UsedRow+2)+'/D'+InttoStr(UsedRow+1)+'*100)';
             ExcelApp.Cells[UsedRow+8,4].Value  :=  '= IF(D'+InttoStr(UsedRow+3)+'=0,0,D'+IntToStr(UsedRow+4)+'/D'+InttoStr(UsedRow+3)+'*100)';
             ExcelApp.Cells[UsedRow+9,4].Value  :=  '= IF(D'+IntToStr(UsedRow+1)+'=0,100,(D'+IntToStr(UsedRow+4)+'+D'+IntToStr(UsedRow+2)+')/D'+InttoStr(UsedRow+1)+'*100)';
             ExcelApp.Cells[UsedRow+10,4].Value := '=IF(D'+IntToStr(UsedRow+1)+'=0,100,(D'+IntToStr(UsedRow+4)+'+D'+IntToStr(UsedRow+2)+'+D'+IntToStr(UsedRow+6)+')/D'+InttoStr(UsedRow+1)+'*100)';

             ExcelApp.ActiveSheet.Rows[UsedRow+7].Font.Color :=clBlue;
             ExcelApp.ActiveSheet.Rows[UsedRow+7].NumberFormat  := '0.00';
             ExcelApp.ActiveSheet.Rows[UsedRow+8].Font.Color :=clRed;
             ExcelApp.ActiveSheet.Rows[UsedRow+8].NumberFormat  := '0.00';
             ExcelApp.ActiveSheet.Rows[UsedRow+9].NumberFormat  := '0.00';
             ExcelApp.ActiveSheet.Rows[UsedRow+10].NumberFormat  := '0.00';
             ExcelApp.ActiveSheet.Rows[UsedRow+9].Font.Color :=RGB(155,51,153);
             ExcelApp.ActiveSheet.Rows[UsedRow+10].Font.Color :=RGB(255,51,153);
             ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow+1)+':B'+IntToStr(UsedRow+10)].Merge;
             ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow+1)+':P'+IntToStr(UsedRow+10)].Interior.Color :=rgb(185,245,245);
             ExcelApp.ActiveSheet.Range['Q'+IntToStr(UsedRow+1)+':AB'+IntToStr(UsedRow+10)].Interior.Color :=rgb(185,245,205);
             AllRow_list.Add(IntToStr(UsedRow+7));
             UsedRow :=  UsedRow+11;
             QueryDefectCode(QryTemp3,sDStartTime,sDEndTime,strTitle);
             if not QryTemp3.IsEmpty then begin
                Qrytemp3.First;
                FirstCount :=  UsedRow;
                for k:=0 to  QryTemp3.RecordCount-1  do  begin
                   ExcelApp.Cells[UsedRow,2].Value := Qrytemp3.FieldByName('Defect_Code').AsString;
                   ExcelApp.Cells[UsedRow,3].Value := Qrytemp3.FieldByName('Defect_Desc').AsString;
                   ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow)+':AB'+IntToStr(UsedRow)].Interior.Color :=rgb(235,185,185);
                   ExcelApp.Cells[UsedRow,4].Value :=  '=SUM(E'+IntToStr(UsedRow)+':AB'+InttoStr(UsedRow)+')';
                   UsedRow :=UsedRow+1;
                   Qrytemp3.Next;
                end;
                ExcelApp.Cells[FirstCount,1].Value := 'Defect Detail';
                ExcelApp.ActiveSheet.Range['A'+IntToStr(FirstCount)+':A'+IntToStr(UsedRow-1)].Merge;

             end;
           end else begin
             RepassRowList.Add('0');
             overallSPYROWList.Add('1');
             ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow+1)+':B'+IntToStr(UsedRow+2)].Merge;
             ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow+1)+':P'+IntToStr(UsedRow+2)].Interior.Color :=rgb(185,245,245);
             ExcelApp.ActiveSheet.Range['Q'+IntToStr(UsedRow+1)+':AB'+IntToStr(UsedRow+2)].Interior.Color :=rgb(185,245,205);
             UsedRow :=  UsedRow+3;
         end;
         ExcelApp.rows[UsedRow].Rowheight :=3;
         ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow)+':N'+IntToStr(UsedRow)].Merge;
         QryTemp2.Next;
     end;
          
      if QryTemp4.IsEmpty then begin
          ExcelApp.ActiveSheet.Range['A21:AB'+IntToStr(UsedRow-1)].Borders[1].Weight := 2;
          ExcelApp.ActiveSheet.Range['A21:AB'+IntToStr(UsedRow-1)].Borders[2].Weight := 2;
          ExcelApp.ActiveSheet.Range['A21:AB'+IntToStr(UsedRow-1)].Borders[3].Weight := 2;
          ExcelApp.ActiveSheet.Range['A21:AB'+IntToStr(UsedRow-1)].Borders[4].Weight := 2;
      end;

      ExcelApp.ActiveSheet.Range['A1:AC'+IntToStr(UsedRow-1)].HorizontalAlignment :=3;
      ExcelApp.ActiveSheet.Range['A1:AC'+IntToStr(UsedRow-1)].VerticalAlignment :=2;
      ExcelApp.ActiveSheet.Columns[3]. HorizontalAlignment :=2;
      ExcelApp.ActiveSheet.Range['A14:AC'+IntToStr(UsedRow-1)].Font.Size :=8;
      ExcelApp.ActiveSheet.Range['A14:AC'+IntToStr(UsedRow-1)].Font.Name :='tahoma';
      ExcelApp.ActiveSheet.Rows[16].NumberFormat  := '0.00';
      ExcelApp.ActiveSheet.Rows[17].NumberFormat  := '0.00';
      ExcelApp.ActiveSheet.Rows[18].NumberFormat  := '0.00';
      ExcelApp.ActiveSheet.Rows[19].NumberFormat  := '0.00';
      ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[1].Weight := 2;
      ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[2].Weight := 2;
      ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[3].Weight := 2;
      ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[4].Weight := 2;
      ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[7].Weight := xlThick;
      ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[8].Weight := xlThick;
      ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[9].Weight := xlThick;
      ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[10].Weight := xlThick;

      AllRows := UsedRow;
       mmo1.Lines.Add('start add time axis value....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
      for j:=0 to Week_list.Count-1 do begin
           sXValue:= Week_list.Strings[j]  ;
           ExcelApp.Cells[15,5+j].value := sXValue;
           if QryTemp4.IsEmpty then
              ExcelApp.Cells[21,5+j].value := sXValue
           else
              ExcelApp.Cells[38,5+j].value := sXValue
      end;

      for j:=0 to StartTime_list.Count-1 do
      begin
            tempStart := StartTime_list.Strings[j];
            tempEnd :=  EndTime_list.Strings[j];
            tempHStart := tempStart +':00:00';
            tempHEnd :=  tempEnd +':00:00';

            QueryOutput(QryData1,tempStart,tempEnd);
            Rowlist := TStringList.Create;
            SPYRowlist := TStringList.Create;
            FinalRowlist:= TStringList.Create;
            FinalYield :=100;
            UsedRow := 21;
            if QryData1.IsEmpty then continue;

            QryData1.First;
            for M:=0 to   QryData1.RecordCount-1 do begin
                strTitle := QryData1.FieldByName('PROCESS_NAME').AsString ;
                Repair_Qty:= QryData1.FieldByName('REPAIR_QTY').AsInteger ;
                FAIL_Qty:= QryData1.FieldByName('FAIL_QTY').AsInteger ;
                for k:=3 to AllRows-1 do begin
                   if  strTitle = ExcelApp.Cells[k,1].Value  then
                       UsedRow :=k;
                end;
                if UsedRow<=2 then exit;
                strFPY :=  QryData1.FieldByName('FPY_QTY').AsString;
                strTotal :=  QryData1.FieldByName('Total_QTY').AsString;
                strRepass :=  QryData1.FieldByName('NTF_QTY').AsString;

                if FAIL_Qty>0  then begin
                    ExcelApp.Cells[UsedRow,5+j].Value := strTotal;
                    ExcelApp.Cells[UsedRow+1,5+j].Value := strFPY;
                    ExcelApp.Cells[UsedRow+2,5+j].Value := StrToInt(strTotal)-strToInt(strFPY);
                    ExcelApp.Cells[UsedRow+3,5+j].Value := strRepass;
                    ExcelApp.Cells[UsedRow+4,5+j].Value := StrToInt(strTotal)-strToInt(strFPY)- strToInt(strRepass);
                    ExcelApp.Cells[UsedRow+5,5+j].Value := Repair_Qty;
                    Rowlist.Add(IntToStr(UsedRow+6));
                    SPYRowlist.Add(IntToStr(UsedRow+8));
                    FinalRowlist.Add(IntToStr(UsedRow+9));

                    if (StrToInt(strTotal)-strToInt(strFPY)) <> 0 then
                       ExcelApp.Cells[UsedRow+7,5+j].Value := StrToInt(strRepass)/(StrToInt(strTotal)-strToInt(strFPY))*100
                    else
                       ExcelApp.Cells[UsedRow+7,5+j].Value := 0;

                    if   StrToInt(strTotal)<> 0 then
                    begin
                       ExcelApp.Cells[UsedRow+6,5+j].Value := StrToInt(strFPY)/StrToInt(strTotal)*100;
                       ExcelApp.Cells[UsedRow+8,5+j].Value := (StrToInt(strFPY)+StrToInt(strRepass))/StrToInt(strTotal)*100 ;
                       ExcelApp.Cells[UsedRow+9,5+j].Value := FinalYield* (StrToInt(strFPY)+StrToInt(strRepass)+Repair_Qty) /StrToInt(strTotal);
                    end
                    else
                    begin
                       ExcelApp.Cells[UsedRow+6,5+j].Value := 100;
                       ExcelApp.Cells[UsedRow+8,5+j].Value := 100;
                       ExcelApp.Cells[UsedRow+9,5+j].Value := 100;
                    end;
                    UsedRow := UsedRow+10;
                    //計算對應的不良
                    QueryDefect(QryDefect,tempHStart,tempHEnd,strTitle);
                    if  not QryDefect.IsEmpty then begin
                       IsFound :=false;
                       for k:=UsedRow+1 to AllRows-1do begin
                          if  ExcelApp.Cells[k,1].Value <> '' then begin
                             defect_count :=  k-1;
                             IsFound :=true;
                             break;
                          end;
                       end;
                       if IsFound then
                          defect_count := defect_count- UsedRow
                       else
                          defect_count :=10;

                       QryDefect.First;
                       for K:=0 to QryDefect.RecordCount-1 do begin
                         sDefect_Code := QryDefect.FieldByName('ALL_DEFECT').AsString ;
                         for L:=0 to defect_count do begin
                            if String(ExcelApp.Cells[UsedRow+L,2].Value) = sDefect_Code then
                               ExcelApp.Cells[UsedRow+L,5+j].Value :=  QryDefect.FieldByName('C_SN').AsString ;
                         end;
                         QryDefect.Next;
                       end;
                    end;
                end else begin
                    ExcelApp.Cells[UsedRow,5+j].Value := strTotal;
                    ExcelApp.Cells[UsedRow+1,5+j].Value := strFPY;
                    UsedRow := UsedRow+3;
                end;
                QryData1.Next;
            end;


            FPY := 100;
            SPY :=100;
            FinalYield :=100;

            if RowList.Count<> 0 then begin
               for M:=0 to  RowList.Count-1 do begin
                   FPY :=  FPY * ExcelApp.Cells[strtoint(RowList.Strings[M]),5+j].Value/100 ;
                   SPY :=  SPY* ExcelApp.Cells[strtoint(SPYRowList.Strings[M]),5+j].Value/100 ;
                   FinalYield :=  FinalYield* ExcelApp.Cells[strtoint(FinalRowList.Strings[M]),5+j].Value/100 ;
               end ;
            end;

            ExcelApp.Cells[16,5+j].Value :=  FPY_Target ;
            ExcelApp.Cells[17,5+j].Value := FormatFloat('0.00',FPY);
            ExcelApp.Cells[18,5+j].Value := FormatFloat('0.00',SPY);
            ExcelApp.Cells[19,5+j].Value :=  FinalYield ;

            RowList.Free;
            SPYRowList.Free;
            FinalRowList.Free;
            UsedRow := UsedRow+8;
      end;

     Total_FPY :=100;
     Total_SPY :=100;
     Total_FinalYield:=100;

     if AllRow_list.Count <>0 then
     begin
         for M:=0 to  AllRow_list.Count-1 do begin
           Total_FPY := Total_FPY * ExcelApp.Cells[strtoInt(AllRow_list.strings[M]),4].Value /100;
           Total_SPY := Total_SPY * ExcelApp.Cells[strtoint(AllRow_list.strings[M])+2,4].Value /100;
           Total_FinalYield := Total_FinalYield * ExcelApp.Cells[strtoint(AllRow_list.strings[M])+3,4].Value /100;
         end;
     end;



     //---------------------------------------------------------------------
     ExcelApp.Cells[16,29].Value :=  FPY_Target ;
     ExcelApp.Cells[17,29].Value := FormatFloat('0.00',Total_FPY);
     ExcelApp.Cells[18,29].Value := FormatFloat('0.00',Total_SPY);
     ExcelApp.Cells[19,29].Value :=  Total_FinalYield ;

      AllRow_list.Free;
      if   IntToStr(ExcelApp.Cells[16,4+j].Value)  <> '' then begin
        TotalTarget_list.Add(FormatFloat('0.00',ExcelApp.Cells[16,29]));
        TotalSPY_list.Add(FormatFloat('0.00',ExcelApp.Cells[18,29]));
        TotalModel_List.add(sModelName);
      end;



    if FormatDateTime('HH',GetSysDate) <= '08' then
       sFileName := GetCurrentDir+'\Report\'+FormatDateTime('YYYY年M月D日 HH時',GetSysDate-1)+' 各機種時段生產報表.xlsx'
    else
       sFileName := GetCurrentDir+'\Report\'+FormatDateTime('YYYY年M月D日 HH時',GetSysDate)+' 各機種時段生產報表.xlsx';

    ExcelApp.WorkSheets[QryModel.RecordCount+1].Delete;
    ExcelApp.WorkSheets[QryModel.RecordCount+1].Delete;
    ExcelApp.WorkSheets[QryModel.RecordCount+1].Delete;
    ExcelApp.WorkSheets[1].Activate;
    mmo1.Lines.Add('save excel ('+sFileName+')...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
    ExcelApp.ActiveWorkbook.SaveAs(sFileName);
    ExcelApp.Quit;
    mmo1.Lines.Add('close excel ...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
    ExcelApp :=Unassigned;
end;

end;


function TuMainForm.QueryProcessName(QryTemp1:TClientDataset;StartTime:String;EndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Model_NAme',ptInput);
    QryTemp1.CommandText:= ' SELECT * FROM (SELECT e.stage_name,B.PROCESS_NAME,B.PROCESS_CODE,SUM(FAIL_QTY)  PROCESS_FAIL, SUM(PASS_QTY) PROCESS_PASS  FROM ( select MODEL_ID,STAGE_ID,PROCESS_ID, '+
                           ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  WORK_DATE ,FAIL_QTY,PASS_QTY '+
                           ' from SAJET.G_SN_COUNT where WORK_ORDER NOT LIKE ''RM%'' and PASS_QTY + FAIL_QTY <> 0 and (PDLINE_ID <11525 OR PDLINE_ID>11534) and PDLINE_ID <>11563 and PDLINE_ID <>11564 )'+
                           ' A,SAJET.SYS_PROCESS B, SAJET.SYS_PART C,SAJET.SYS_MODEL D ,sajet.sys_stage e  '+
                           ' WHERE A.PROCESS_ID=B.PROCESS_ID AND A.WORK_DATE>=:StartTime AND A.WORK_DATE <= :EndTime  AND '+
                           '  a.stage_ID =e.stage_ID and    '+
                           ' A.MODEL_ID=C.PART_ID AND C.MODEL_ID =D.MODEL_ID AND D.MODEL_NAME=:Model_NAme  AND B.PROCESS_CODE IS NOT NULL '+
                           ' GROUP BY  e.stage_name, B.PROCESS_NAME,B.PROCESS_CODE ORDER BY PROCESS_CODE ) WHERE PROCESS_PASS>200';
    QryTemp1.Params.ParamByName('StartTime').AsString := StartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := EndTime;
    QryTemp1.Params.ParamByName('Model_Name').AsString := sModelName;
    QryTemp1.Open;
end;


procedure TfDetail.FormShow(Sender: TObject);
var i:integer;
begin
    cmbModel.Style :=csDropDown;
    DateTimePicker1.Date :=  Now;
    DateTimePicker2.Date :=  tomorrow;
    qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Commandtext := 'select distinct (model_Name) MOdel from sajet.sys_model where Enabled =''Y'' order by model_Name ';
    qrytemp.Open;
    qrytemp.First;
    for i:=0 to qrytemp.recordcount-1 do begin
       cmbModel.Items.Add(qrytemp.fieldbyname('model').asstring) ;
       qrytemp.Next;
    end;

    qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Commandtext := 'select distinct (PDLINE_Name)  from sajet.sys_PDLINE where Enabled =''Y'' order by PDLINE_Name ';
    qrytemp.Open;
    qrytemp.First;
     cmbLine.Items.Add('') ;
    for i:=0 to qrytemp.recordcount-1 do begin
       cmbLine.Items.Add(qrytemp.fieldbyname('PDLINE_Name').asstring) ;
       qrytemp.Next;
    end;
end;

procedure TfDetail.DBGrid2DblClick(Sender: TObject);
begin
  //
  
end;

end.
