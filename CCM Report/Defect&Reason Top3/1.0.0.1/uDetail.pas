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
    function QueryDefectReason(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
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

    QueryDefectReason(QryDefect,sDStartTime,sDEndTime);
    DbGrid2.Columns[0].Width :=120;
    DbGrid2.Columns[1].Width :=120;
    DbGrid2.Columns[2].Width :=240;
    DbGrid2.Columns[3].Width :=120;
end;

function TfDetail.QueryDefectReason(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
     QryData.Close;
     QryData.Params.Clear;
     QryData.Params.CreateParam(ftstring,'StartTime',ptInput);
     QryData.Params.CreateParam(ftstring,'EndTime',ptInput);
     QryData.CommandText := ' SELECT AA.PROCESS_NAME,AA.PROCESS_CODE ,AA.DEFECT_CODE,AA.DEFECT_DESC,AA.REASON_DESC ,BB.TOTAL_DEFECT,AA.DEFECT_QTY, '+
                            ' ROUND((AA.DEFECT_QTY/BB.TOTAL_DEFECT)*100,2) "Rate(%)" FROM  '+
                            ' (SELECT * FROM (SELECT E.PROCESS_NAME ,E.PROCESS_CODE,D.DEFECT_CODE,D.DEFECT_DESC,G.REASON_DESC ,COUNT(*) DEFECT_QTY, '+
                            ' ROW_NUMBER() OVER(PARTITION BY  E.PROCESS_NAME ,E.PROCESS_CODE,D.DEFECT_CODE,D.DEFECT_DESC ORDER BY COUNT(*) DESC)  RAN '+
                            ' FROM SAJET.G_SN_REPAIR A,SAJET.G_SN_REPAIR_LOCATION B ,SAJET.G_SN_DEFECT C ,sajet.sys_defect D, '+
                            ' SAJET.SYS_PROCESS E,SAJET.SYS_PART F,SAJET.SYS_MODEL H,SAJET.SYS_REASON G  '+
                            ' WHERE A.RECID=B.RECID and B.LOCATION IS NOT NUll and a.recid=C.RECID and A.REPAIR_TIME >to_date(:StartTime,''yyyy-mm-dd hh24:mi:ss'') '+
                            ' and A.REPAIR_TIME <=to_date(:EndTime,''yyyy-mm-dd hh24:mi:ss'') '+
                            ' AND C.DEFECT_ID =D.DEFECT_ID AND E.PROCESS_ID = C.PROCESS_ID AND A.MODEL_ID = F.PART_ID AND F.MODEL_ID = H.MODEL_ID AND A.REASON_ID =G.REASON_ID ';
      if pos('%',cmbModel.Text )>0 then
            QryData.CommandText := QryData.CommandText +  ' AND H.MODEL_NAME LIKE '''+cmbModel.Text+''''
     else
            QryData.CommandText := QryData.CommandText +  ' AND H.MODEL_NAME ='''+cmbModel.Text+'''' ;

     QryData.CommandText := QryData.CommandText + ' GROUP BY  E.PROCESS_NAME ,E.PROCESS_CODE ,D.DEFECT_CODE,D.DEFECT_DESC,G.REASON_DESC) WHERE RAN <=7 ) aa, '+
                            ' (SELECT * FROM (SELECT  E.PROCESS_NAME ,E.PROCESS_CODE,D.DEFECT_CODE,D.DEFECT_DESC ,COUNT(*) TOTAL_DEFECT, '+
                            '   ROW_NUMBER() OVER(partition by E.PROCESS_NAME ,E.PROCESS_CODE ORDER BY COUNT(*) DESC)  RAN  '+
                            ' FROM SAJET.G_SN_REPAIR A,SAJET.G_SN_REPAIR_LOCATION B ,SAJET.G_SN_DEFECT C ,sajet.sys_defect D,  '+
                            ' SAJET.SYS_PROCESS E,SAJET.SYS_PART F,SAJET.SYS_MODEL H  '+
                            ' WHERE A.RECID=B.RECID and B.LOCATION IS NOT NUll and a.recid=C.RECID and A.REPAIR_TIME >to_date(:StartTime,''yyyy-mm-dd hh24:mi:ss'') '+
                            ' and A.REPAIR_TIME <=to_date(:EndTime,''yyyy-mm-dd hh24:mi:ss'') '+
                            ' AND C.DEFECT_ID =D.DEFECT_ID AND E.PROCESS_ID = C.PROCESS_ID AND A.MODEL_ID = F.PART_ID AND F.MODEL_ID = H.MODEL_ID AND D.DEFECT_CODE <>''123'' ';
     if pos('%',cmbModel.Text )>0 then
            QryData.CommandText := QryData.CommandText +  ' AND H.MODEL_NAME LIKE '''+cmbModel.Text+''''
     else
            QryData.CommandText := QryData.CommandText +  ' AND H.MODEL_NAME ='''+cmbModel.Text+'''' ;

     QryData.CommandText := QryData.CommandText + ' GROUP BY E.PROCESS_NAME ,E.PROCESS_CODE ,D.DEFECT_CODE,D.DEFECT_DESC ORDER BY  E.PROCESS_CODE,D.DEFECT_CODE) '+
                            ' WHERE RAN <=7 ORDER BY PROCESS_CODE,RAN ) bb WHERE  AA.PROCESS_CODE =BB.PROCESS_CODE AND AA.DEFECT_CODE =BB.DEFECT_CODE  '+
                            ' AND AA.PROCESS_NAME IN(''SMT_VI_T'',''FUNC TEST'',''AutoTest'',''CM-VI'')   ORDER BY ' +
                            '  PROCESS_CODE, Total_Defect Desc,Defect_Qty Desc';
     QryData.Params.ParamByName('StartTime').AsString :=sStartTime;
     QryData.Params.ParamByName('EndTime').AsString :=sEndTime;
     QryData.Open;


end;

procedure TfDetail.sBtnExportClick(Sender: TObject);
var
    i,m,UsedRow,pRows:integer;
    yHeg:double;
    tempProcess,CurrProcess:String;
    ExcelApp,ChartObjects: Variant;
begin
    if SaveDialog1.Execute then begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);

        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=true;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Add;
        ExcelApp.WorkSheets[1].Activate;
        if pos('%',cmbModel.Text )>0 then
            ExcelApp.WorkSheets[1].Name :=  Copy(cmbModel.Text,1,Length(cmbModel.Text)-1)
        else
            ExcelApp.WorkSheets[1].Name :=  cmbModel.Text ;
        if pos('%',cmbModel.Text )>0 then
           ExcelApp.Cells[1,1].Value := Copy(cmbModel.Text,1,Length(cmbModel.Text)-1)  +' 不良原因 Top3 Report'
        else
           ExcelApp.Cells[1,1].Value := cmbModel.Text   +' 不良原因 Top3 Report' ;
        ExcelApp.Cells[2,1].Value := 'Start Time:';
        ExcelApp.Cells[2,2].Value := sDStartTime;
        ExcelApp.Cells[2,3].Value := 'End Time:';
        ExcelApp.Cells[2,4].Value := sDEndTime;

        ExcelApp.Cells[3,1].Value := 'PROCESS';
        ExcelApp.Cells[3,2].Value := 'Defect_Desc';
        ExcelApp.Cells[3,3].Value := 'Reason_Desc';
        ExcelApp.Cells[3,4].Value := 'Rate';

        QryData.First;
        UsedRow :=4;
        m:=0;
        tempProcess := QryData.FieldByName('PROCESS_NAME').AsString;
        pRows :=0;
        yHeg :=55;
        for I:=0 to QryData.RecordCount-1 do begin
             inc(pRows);
             CurrProcess := QryData.FieldByName('PROCESS_NAME').AsString;
             ExcelApp.Cells[UsedRow,1].Value :=CurrProcess;
             ExcelApp.Cells[UsedRow,2].Value :=QryData.FieldByName('Defect_DESC').AsString;
             ExcelApp.Cells[UsedRow,3].Value :=QryData.FieldByName('Reason_Desc').AsString;
             ExcelApp.Cells[UsedRow,4].Value :=QryData.FieldByName('Rate(%)').AsString+'%';
             if ( tempProcess <> CurrProcess)  then begin
                yHeg  := yHeg -  16.55*pRows;
                if m=0 then  begin
                    ExcelApp.ActiveSheet.range['A'+IntToStr(UsedRow-pRows+1)+ ':A'+IntToStr(UsedRow-1)].Merge ;
                    ChartObjects :=ExcelApp.ActiveSheet.ChartObjects.add(240,50+(UsedRow-pRows-3)*16.55 ,300,16.55*(pRows-1)-3);
                    ChartObjects.Chart.ChartType:=xlLineMarkers;
                    ChartObjects.Chart.HasLegend := FALSE;
                    chartObjects.chart.SetSourceData(ExcelApp.ActiveSheet.Range['B'+IntToStr(UsedRow-pRows+1)+ ':D'+IntToStr(UsedRow-1)]);
                end else  begin
                    ExcelApp.ActiveSheet.range['A'+IntToStr(UsedRow-pRows)+ ':A'+IntToStr(UsedRow-1)].Merge;
                    ChartObjects :=ExcelApp.ActiveSheet.ChartObjects.add(240,50+(UsedRow-pRows-4-m)*16.55+m*5 ,300,16.55*(pRows)-3);
                    ChartObjects.Chart.ChartType:=xlLineMarkers;
                    ChartObjects.Chart.HasLegend := FALSE;
                    chartObjects.chart.SetSourceData(ExcelApp.ActiveSheet.Range['B'+IntToStr(UsedRow-pRows)+ ':D'+IntToStr(UsedRow-1)]);

                end;

                 ExcelApp.ActiveSheet.Rows[UsedRow].Insert;
                 ExcelApp.Rows[UsedRow].RowHeight :=5;
                 inc(UsedRow);
                 inc(m);
                 pRows :=0;
             end;

             if i = QryData.RecordCount-1 then begin

                  ChartObjects :=ExcelApp.ActiveSheet.ChartObjects.add(240,50+(UsedRow-pRows-m-4)*16.55+m*5,300,16.55*(pRows+1)-3);
                  ChartObjects.Chart.ChartType:=xlLineMarkers;
                  ChartObjects.Chart.HasLegend := false;
                  ExcelApp.ActiveSheet.range['A'+IntToStr(UsedRow-pRows)+ ':A'+IntToStr(UsedRow)].Merge;
                  chartObjects.chart.SetSourceData(ExcelApp.ActiveSheet.Range['B'+IntToStr(UsedRow-pRows)+ ':D'+IntToStr(UsedRow)]);
             end;

             inc(UsedRow);
             tempProcess := CurrProcess;
             QryData.Next;

        end;
        for i:=UsedRow-1 downto 4  do begin
             if   ExcelApp.Cells[i,2].Value =  ExcelApp.Cells[i-1,2].Value then begin
                    ExcelApp.ActiveSheet.range['B'+IntToStr(i-1)+ ':B'+IntToStr(i)].Merge;

             end;

        end;
        ExcelApp.ActiveSheet.range['A1:J1'].Merge;
        ExcelApp.ActiveSheet.range['A1:J1'].Font.Color :=clWhite;
        ExcelApp.ActiveSheet.range['A1:J1'].Font.Size :=18;
        ExcelApp.ActiveSheet.range['A1:J'+IntToStr(usedRow)].Font.Name :='Tohama';
        ExcelApp.ActiveSheet.range['A1:J1'].Font.Bold :=True;
        ExcelApp.ActiveSheet.range['A1:J1'].Interior.Color :=rgb(0,32,96);
        ExcelApp.ActiveSheet.range['A3:D3'].Font.Color :=clWhite;
        ExcelApp.ActiveSheet.range['A3:D3'].Font.Bold :=True;
        ExcelApp.ActiveSheet.range['A3:D3'].Interior.Color :=rgb(0,32,96);

        ExcelApp.Columns[1].columnwidth :=15;
        ExcelApp.Columns[2].columnwidth :=20;
        ExcelApp.Columns[3].columnwidth :=20;
        ExcelApp.Columns[4].columnwidth :=15;


        ExcelApp.ActiveSheet.Range['A3:D'+IntToStr(UsedRow-1)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A3:D'+IntToStr(UsedRow-1)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A3:D'+IntToStr(UsedRow-1)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A3:D'+IntToStr(UsedRow-1)].Borders[4].Weight := 2;
        
        ExcelApp.ActiveSheet.Range['A1:J'+IntToStr(UsedRow-1)].HorizontalAlignment :=3;
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
    qrytemp.Commandtext := 'select distinct (model_Name) MOdel from sajet.sys_model where Enabled =''Y'' order by model_Name ';
    qrytemp.Open;
    qrytemp.First;
    for i:=0 to qrytemp.recordcount-1 do begin
       cmbModel.Items.Add(qrytemp.fieldbyname('model').asstring) ;
       qrytemp.Next;
    end;
 
end;

end.
