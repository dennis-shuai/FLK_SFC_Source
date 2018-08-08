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
    SaveDialog1: TSaveDialog;
    Label2: TLabel;
    DateTimePicker2: TDateTimePicker;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    cmbModel: TComboBox;
    Label3: TLabel;
    DBGrid2: TDBGrid;
    procedure sbtnQueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
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
    function QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function QueryDistWeek(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function QueryDistDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String;Process:string):boolean;
    
  end;

var
  fDetail: TfDetail;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit;

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

    QueryDefect(QryDefect,sStartTime,sEndTime);
    DbGrid2.Columns[0].Width :=120;
    DbGrid2.Columns[1].Width :=120;
    DbGrid2.Columns[2].Width :=240;
    DbGrid2.Columns[3].Width :=120;
end;

function TfDetail.QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
     QryData.Close;
     QryData.Params.Clear;
     QryData.Params.CreateParam(ftstring,'StartTime',ptInput);
     QryData.Params.CreateParam(ftstring,'EndTime',ptInput);
     QryData.CommandText := ' SELECT AA.WEEK,BB.PROCESS_NAME,AA.DEFECT_DESC,AA.DEFECT_QTY,BB.TOTAL_INPUT,'+
                            ' DECODE(BB.TOTAL_INPUT,0,0,ROUND((AA.DEFECT_QTY/BB.TOTAL_INPUT)*100,2)) "Rate(%)"  FROM ( '+
                            ' SELECT * FROM( SELECT WEEK,PROCESS_NAME,DEFECT_CODE,DEFECT_DESC ,COUNT(*) DEFECT_QTY ,'+
                            ' ROW_NUMBER() OVER(PARTITION BY WEEK,PROCESS_NAME ORDER BY COUNT(*) DESC)  RAN FROM '+
                            ' (select a.serial_number, ''W''||to_char(a.rec_time+3,''WW'') WEEK,B.PROCESS_NAME,'+
                            ' C.DEFECT_CODE,C.defect_DESC,  E.MODEL_NAME from sajet.g_sn_defect_first a,sajet.sys_process b, '+
                            ' sajet.sys_defect c,sajet.sys_part d,sajet.sys_model e '+
                            ' where a.model_id=d.Part_id and D.MODEL_ID =e.model_id   and a.ntf_time is null';
     if pos('%',cmbModel.Text )>0 then
           QryData.CommandText := QryData.CommandText +  ' AND e.MODEL_NAME LIKE '''+cmbModel.Text+''''
     else
           QryData.CommandText := QryData.CommandText +  ' AND e.MODEL_NAME ='''+cmbModel.Text+'''' ;

     QryData.CommandText := QryData.CommandText + ' and b.process_id=A.PROCESS_ID and A.DEFECT_ID = C.DEFECT_ID AND C.DEFECT_CODE <>''123'' '+
                            '  and a.rec_time>=to_date(:STARTTIME,''YYYYMMDDHH24'') '+
                            '  and  a.rec_time<to_date(:ENDTIME,''YYYYMMDDHH24'') ) '+
                            '  GROUP BY  WEEK,PROCESS_NAME,DEFECT_CODE,DEFECT_DESC ) WHERE RAN<=5 )aa, '+
                            '  ( SELECT  WEEK, PROCESS_NAME ,PROCESS_CODE,SUM(TOTAL_QTY) TOTAL_INPUT  '+
                            '  FROM (SELECT ''W''||to_char(TO_DATE(A.WORK_DATE,''YYYYMMDD'')+3,''WW'') WEEK '+
                            '  ,B.PROCESS_NAME,B.PROCESS_CODE ,(A.PASS_QTY+A.FAIL_QTY) TOTAL_QTY '+
                            '  FROM SAJET.G_SN_COUNT A,sajet.sys_process b,sajet.sys_part C,sajet.sys_model D '+
                            '  WHERE A.MODEL_ID =C.PART_ID AND C.MODEL_ID =D.MODEL_ID AND A.PROCESS_ID=B.PROCESS_ID '+
                            '  AND  a.WORK_DATE||TRIM(TO_CHAR(A.WORK_TIME,''00''))>=:STARTTIME '+
                            '  AND  a.WORK_DATE||TRIM(TO_CHAR(A.WORK_TIME,''00'')) <:ENDTIME  and B.PROCESS_CODE IS NOT NULL ';
     if pos('%',cmbModel.Text )>0 then
            QryData.CommandText := QryData.CommandText +  ' AND D.MODEL_NAME LIKE '''+cmbModel.Text+''''
     else
            QryData.CommandText := QryData.CommandText +  ' AND D.MODEL_NAME ='''+cmbModel.Text+'''' ;
     QryData.CommandText := QryData.CommandText +  '   )  GROUP BY WEEK, PROCESS_CODE,PROCESS_NAME   '+
                            ' ) bb  '+                                                
                            ' WHERE AA.WEEK=BB.WEEK AND AA.PROCESS_NAME=BB.PROCESS_NAME  '+
                            ' ORDER BY BB.PROCESS_CODE,AA.WEEK,BB.PROCESS_NAME,AA.DEFECT_QTY DESC ';

     QryData.Params.ParamByName('StartTime').AsString :=sStartTime;
     QryData.Params.ParamByName('EndTime').AsString :=sEndTime;
     QryData.Open;


end;

function TfDetail.QueryDistWeek(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
     QryTemp1.Close;
     QryTemp1.Params.Clear;
     QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
     QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
     QryTemp1.CommandText := '    SELECT DISTINCT(''W''||to_char(TO_DATE(A.WORK_DATE,''YYYYMMDD'')+3,''WW'')) WEEK '+
                            '  FROM SAJET.G_SN_COUNT A,sajet.sys_part C,sajet.sys_model D '+
                            '  WHERE A.MODEL_ID =C.PART_ID AND C.MODEL_ID =D.MODEL_ID  '+
                            '  AND  a.WORK_DATE||TRIM(TO_CHAR(A.WORK_TIME,''00''))>=:STARTTIME '+
                            '  AND  a.WORK_DATE||TRIM(TO_CHAR(A.WORK_TIME,''00'')) <:ENDTIME   ';
     if pos('%',cmbModel.Text )>0 then
            QryTemp1.CommandText := QryTemp1.CommandText +  ' AND D.MODEL_NAME LIKE '''+cmbModel.Text+''''
     else
            QryTemp1.CommandText := QryTemp1.CommandText +  ' AND D.MODEL_NAME ='''+cmbModel.Text+'''' ;
     QryTemp1.CommandText := QryTemp1.CommandText +  '   ORDER BY WEEK    ';
     QryTemp1.Params.ParamByName('StartTime').AsString :=sStartTime;
     QryTemp1.Params.ParamByName('EndTime').AsString :=sEndTime;
     QryTemp1.Open;

end;

function TfDetail.QueryDistDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String;Process:string):boolean;
begin
     QryTemp1.Close;
     QryTemp1.Params.Clear;
     QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
     QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
     QryTemp1.Params.CreateParam(ftstring,'PROCESS',ptInput);
     QryTemp1.CommandText := ' SELECT DEFECT_DESC,SUM(DEFECT_QTY) DEFECT_QTY  FROM(SELECT  DEFECT_DESC,  DEFECT_QTY FROM( SELECT WEEK,PROCESS_NAME,DEFECT_CODE,DEFECT_DESC ,COUNT(*) DEFECT_QTY ,'+
                             ' ROW_NUMBER() OVER(PARTITION BY WEEK,PROCESS_NAME ORDER BY COUNT(*) DESC)  RAN FROM '+
                             ' (select a.serial_number, ''W''||to_char(a.rec_time+3,''WW'') WEEK,B.PROCESS_NAME,'+
                             ' C.DEFECT_CODE,C.defect_DESC,  E.MODEL_NAME from sajet.g_sn_defect_first a,sajet.sys_process b, '+
                             ' sajet.sys_defect c,sajet.sys_part d,sajet.sys_model e '+
                             ' where a.model_id=d.Part_id and D.MODEL_ID =e.model_id  ';
     if pos('%',cmbModel.Text )>0 then
           QryTemp1.CommandText := QryTemp1.CommandText +  ' AND e.MODEL_NAME LIKE '''+cmbModel.Text+''''
     else
           QryTemp1.CommandText := QryTemp1.CommandText +  ' AND e.MODEL_NAME ='''+cmbModel.Text+'''' ;

     QryTemp1.CommandText := QryTemp1.CommandText + ' and b.process_id=A.PROCESS_ID and A.DEFECT_ID = C.DEFECT_ID AND C.DEFECT_CODE <>''123'' '+
                            '  and a.rec_time>=to_date(:STARTTIME,''YYYYMMDDHH24'') '+
                            '  and  a.rec_time<to_date(:ENDTIME,''YYYYMMDDHH24'') ) '+
                            '  GROUP BY  WEEK,PROCESS_NAME,DEFECT_CODE,DEFECT_DESC ) WHERE RAN<=3  '+
                            '  AND PROCESS_NAME =:PROCESS) GROUP BY DEFECT_DESC   ORDER BY DEFECT_QTY DESC';

     QryTemp1.Params.ParamByName('StartTime').AsString :=sStartTime;
     QryTemp1.Params.ParamByName('EndTime').AsString :=sEndTime;
     QryTemp1.Params.ParamByName('PROCESS').AsString :=PROCESS;
     QryTemp1.Open;
end;

procedure TfDetail.sBtnExportClick(Sender: TObject);
var
    i,j,k,m,UsedRow,pRows,UsedCol:integer;
    yHeg:double;
    tempProcess,CurrProcess,CurrWeek,CurrDefect,sCulmns:String;
    ExcelApp,ChartObjects: Variant;
begin
    if SaveDialog1.Execute then begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);

        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Add;
        ExcelApp.WorkSheets[1].Activate;
        if pos('%',cmbModel.Text )>0 then
            ExcelApp.WorkSheets[1].Name :=  Copy(cmbModel.Text,1,Length(cmbModel.Text)-1)
        else
            ExcelApp.WorkSheets[1].Name :=  cmbModel.Text ;
        if pos('%',cmbModel.Text )>0 then
           ExcelApp.Cells[1,1].Value := Copy(cmbModel.Text,1,Length(cmbModel.Text)-1)  +' Top3 不良推移圖 Report'
        else
           ExcelApp.Cells[1,1].Value := cmbModel.Text   +' Top3不良推移圖' ;
        ExcelApp.Cells[2,1].Value := 'Start Time:';
        ExcelApp.Cells[2,2].Value := sDStartTime;
        ExcelApp.Cells[2,3].Value := 'End Time:';
        ExcelApp.Cells[2,4].Value := sDEndTime;
        ExcelApp.ActiveSheet.Range['D2:E2'].Merge;
        ExcelApp.Columns[1].ColumnWidth := 15;
        ExcelApp.Columns[2].ColumnWidth := 20;
        ExcelApp.Columns[3].ColumnWidth := 8;
        ExcelApp.Columns[4].ColumnWidth := 8;
        ExcelApp.Columns[5].ColumnWidth := 8;
        ExcelApp.Columns[6].ColumnWidth := 8;
        ExcelApp.Columns[7].ColumnWidth := 8;
        ExcelApp.Columns[8].ColumnWidth := 8;
        ExcelApp.Columns[9].ColumnWidth := 8;
        ExcelApp.Columns[10].ColumnWidth := 8;
        ExcelApp.Columns[11].ColumnWidth := 8;
        ExcelApp.Columns[12].ColumnWidth := 8;
        QryData.First;

        UsedRow :=4;
        tempProcess :='';
        QueryDistWeek(QryTemp,sStartTime,sEndTime);
        m:=0;
        for i:=0 to  QryData.RecordCount -1 do begin
             CurrProcess :=  QryData.fieldByName('PROCESS_NAME').AsString;
             if ( CurrProcess ='SMT_VI_T') OR ( CurrProcess ='FUNC TEST')
                    OR ( CurrProcess ='AutoTest') OR ( CurrProcess ='CM-VI') then begin
               if tempProcess <> CurrProcess  then begin
                   ExcelApp.Cells[UsedRow,1].Value := CurrProcess;
                   QryTemp.First;
                   for j:= 0 to  QryTemp.RecordCount-1 do begin
                       ExcelApp.Cells[UsedRow-1,j+3].Value := QryTemp.FieldByName('Week').AsString;
                       QryTemp.Next;
                   end;
                   QueryDistDefect(QryDefect, sStartTime, sEndTime,CurrProcess);
                   QryDefect.First;
                   for j:= 0 to  QryDefect.RecordCount-1 do begin
                       ExcelApp.Cells[UsedRow,1].Value := CurrProcess;
                       ExcelApp.Cells[UsedRow,2].Value := QryDefect.FieldByName('Defect_DESC').AsString;
                       Inc(UsedRow);
                       QryDefect.Next;
                   end;
               //畫圖
                  // ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow-1) +':A'+IntToStr(UsedRow-j)].Merge;
                   ChartObjects :=ExcelApp.ActiveSheet.ChartObjects.add((290+69*QryTemp.RecordCount)/1.344+30,30+(UsedRow-j-4-m)*16.5+m*8,500,16.5*(j+1));
                   ChartObjects.Chart.ChartType:=xlLineMarkers;
                   //ChartObjects.Chart.HasLegend := false;
                   sCulmns := Char(66+QryTemp.RecordCount);
                   chartObjects.chart.SetSourceData(ExcelApp.ActiveSheet.Range['B'+IntToStr(UsedRow-j-1)+ ':'+sCulmns+IntToStr(UsedRow-1)]);
                   ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow) +':'+sCulmns+IntToStr(UsedRow)].Merge;
                   ExcelApp.Rows[UsedRow].RowHeight :=8;
                   inc(UsedRow );
                   inc(UsedRow );
                   inc(m);
                   tempProcess := CurrProcess;
                 
               end;
             end;
           QryData.Next;

        end;
        UsedRow :=UsedRow-2;
        QryData.First;
        for i:=0 to  QryData.RecordCount -1 do begin
             CurrProcess :=  QryData.fieldByName('PROCESS_NAME').AsString;
             CurrDefect :=   QryData.fieldByName('DEFECT_DESC').AsString;
             CurrWeek :=   QryData.fieldByName('WEEK').AsString;
             for j:=1 to UsedRow -1 do begin
                 if  (CurrProcess = ExcelApp.Cells[j,1].Value)
                      and (CurrDefect = ExcelApp.Cells[j,2].Value)  then begin
                      for k:=2 to QryTemp.RecordCount+2 do begin
                             if CurrWeek =   ExcelApp.Cells[3,k].Value  then begin
                                   ExcelApp.Cells[j,k].Value := QryData.fieldByName('Rate(%)').AsString;
                             end;
                      end;
                 end;
             end ;
             QryData.Next;
        end;

        for i:=UsedROw downto 3   do begin
             if   (ExcelApp.Cells[i,1].Value  =  ExcelApp.Cells[i-1,1].Value) and
                  ( ExcelApp.Cells[i-1,1].Value <>'')  then  begin
                  ExcelApp.ActiveSheet.Range['A'+IntToStr(i) +':A'+IntToStr(i-1)].Merge;

             end;

        end;

        ExcelApp.ActiveSheet.Range['A1:'+Char(66+QryTemp.RecordCount)+'1'].Merge;
        ExcelApp.Rows[1].RowHeight :=20;
        ExcelApp.Rows[1].Font.Color :=clWhite;
        ExcelApp.ActiveSheet.Range['A1:G1'].Interior.Color :=rgb(55,96,145);;
        ExcelApp.Rows[1].Font.Size :=16;
        ExcelApp.ActiveSheet.Range['A3:'+Char(66+QryTemp.RecordCount)+IntToStr(UsedRow-1)].Font.Name :='Tohoma';

        ExcelApp.ActiveSheet.Range['A3:'+Char(66+QryTemp.RecordCount)+IntToStr(UsedRow-1)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A3:'+Char(66+QryTemp.RecordCount)+IntToStr(UsedRow-1)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A3:'+Char(66+QryTemp.RecordCount)+IntToStr(UsedRow-1)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A3:'+Char(66+QryTemp.RecordCount)+IntToStr(UsedRow-1)].Borders[4].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:'+Char(66+QryTemp.RecordCount)+IntToStr(UsedRow-1)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:J'+IntToStr(UsedRow-1)].VerticalAlignment :=2;
        
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
        ExcelApp.Quit;
        MessageDlg('Save OK',mtConfirmation,[mbyes],0);

    end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var i:integer;
begin
    cmbModel.Style :=csDropDown;
    DateTimePicker1.Date :=  Now;
    DateTimePicker2.Date :=  tomorrow;
    qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Commandtext := 'select distinct (model_Name) Model from sajet.sys_model where Enabled =''Y'' order by model_Name ';
    qrytemp.Open;
    qrytemp.First;
    for i:=0 to qrytemp.recordcount-1 do begin
       cmbModel.Items.Add(qrytemp.fieldbyname('model').asstring) ;
       qrytemp.Next;
    end;

end;

end.
