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
    DBGrid2: TDBGrid;
    btn1: TSpeedButton;
    Image3: TImage;
    LV_Role: TListView;
    procedure sbtnQueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure DateTimePicker1Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure DateTimePicker2Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID : String;
    Count:Integer;
    UpDate_Time :TDateTime;
    sStartTime, sEndTime, sDStartTime, sDEndTime,sTime1,sTime2,sModelList :string;
    function QueryDefectReason(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    procedure QueryModel(QryTemp1:TClientDataSet;START_DATE,END_DATE:string);
  end;

var
  fDetail: TfDetail;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit, UFrmList;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
begin
    if length(ComboBox1.Text)=1  then  sTime1 := '0' + ComboBox1.Text
    else  sTime1 := ComboBox1.Text;

    if length(ComboBox2.Text)=1  then  sTime2 := '0' + ComboBox2.Text
    else  sTime2 := ComboBox2.Text;

    sStartTime  := FormatDateTime('yyyymmdd',DateTimePicker1.Date)+ sTime1  ;
    sEndTime  := FormatDateTime('yyyymmdd',DateTimePicker2.Date)+ sTime2 ;
    sDStartTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+' '+ sTime1+':00:00'  ;
    sDEndTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker2.Date)+ ' '+sTime2+':00:00'   ;

    QueryDefectReason(QryDefect,sStartTime,sEndTime);
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
                            ' WHERE A.RECID=B.RECID and B.LOCATION IS NOT NUll and a.recid=C.RECID and A.REPAIR_TIME >=to_date(:StartTime,''yyyymmddhh24'') '+
                            ' and A.REPAIR_TIME <to_date(:EndTime,''yyyymmddhh24'') '+
                            ' AND C.DEFECT_ID =D.DEFECT_ID AND E.PROCESS_ID = C.PROCESS_ID AND A.MODEL_ID = F.PART_ID AND F.MODEL_ID = H.MODEL_ID AND A.REASON_ID =G.REASON_ID ';
     if  LV_Role.Items.Count>0 then
            QryData.CommandText := QryData.CommandText +  ' AND H.MODEL_NAME IN  '+sModelList ;

     QryData.CommandText := QryData.CommandText + ' GROUP BY  E.PROCESS_NAME ,E.PROCESS_CODE ,D.DEFECT_CODE,D.DEFECT_DESC,G.REASON_DESC) WHERE RAN <=7 ) aa, '+
                            ' (SELECT * FROM (SELECT  E.PROCESS_NAME ,E.PROCESS_CODE,D.DEFECT_CODE,D.DEFECT_DESC ,COUNT(*) TOTAL_DEFECT, '+
                            '   ROW_NUMBER() OVER(partition by E.PROCESS_NAME ,E.PROCESS_CODE ORDER BY COUNT(*) DESC)  RAN  '+
                            ' FROM SAJET.G_SN_REPAIR A,SAJET.G_SN_REPAIR_LOCATION B ,SAJET.G_SN_DEFECT C ,sajet.sys_defect D,  '+
                            ' SAJET.SYS_PROCESS E,SAJET.SYS_PART F,SAJET.SYS_MODEL H  '+
                            ' WHERE A.RECID=B.RECID and B.LOCATION IS NOT NUll and a.recid=C.RECID and A.REPAIR_TIME >=to_date(:StartTime,''yyyymmddhh24'') '+
                            ' and A.REPAIR_TIME <to_date(:EndTime,''yyyymmddhh24'') '+
                            ' AND C.DEFECT_ID =D.DEFECT_ID AND E.PROCESS_ID = C.PROCESS_ID AND A.MODEL_ID = F.PART_ID AND F.MODEL_ID = H.MODEL_ID AND D.DEFECT_CODE <>''123'' ';
     if  LV_Role.Items.Count>0 then
            QryData.CommandText := QryData.CommandText +  'AND H.MODEL_NAME IN   '+ sModelList ;

     QryData.CommandText := QryData.CommandText + ' GROUP BY E.PROCESS_NAME ,E.PROCESS_CODE ,D.DEFECT_CODE,D.DEFECT_DESC ORDER BY  E.PROCESS_CODE,D.DEFECT_CODE) '+
                            ' WHERE RAN <=7 ORDER BY PROCESS_CODE,RAN ) bb WHERE  AA.PROCESS_CODE =BB.PROCESS_CODE AND AA.DEFECT_CODE =BB.DEFECT_CODE  '+
                            '  ORDER BY  PROCESS_CODE, Total_Defect Desc,Defect_Qty Desc';
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
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Add;
        ExcelApp.WorkSheets[1].Activate;

        ExcelApp.WorkSheets[1].Name :=  ' 不良原因 Top3 Report' ;
        ExcelApp.Cells[1,1].Value := ' 不良原因 Top3 Report' ;
        ExcelApp.Cells[2,1].Value := 'Start Time:';
        ExcelApp.Cells[2,2].Value := sDStartTime;
        ExcelApp.Cells[2,3].Value := 'End Time:';
        ExcelApp.Cells[2,4].Value := sDEndTime;

        ExcelApp.Cells[3,1].Value := 'PROCESS';
        ExcelApp.Cells[3,2].Value := 'Defect_Desc';
        ExcelApp.Cells[3,3].Value := 'Reason_Desc';
        ExcelApp.Cells[3,4].Value := 'Q''ty';
        ExcelApp.Cells[3,5].Value := 'Rate';

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
             ExcelApp.Cells[UsedRow,4].Value :=QryData.FieldByName('DEFECT_QTY').AsString;
             ExcelApp.Cells[UsedRow,5].Value :=QryData.FieldByName('Rate(%)').AsString+'%';
             if ( tempProcess <> CurrProcess)  then begin
                yHeg  := yHeg -  16.55*pRows;
                if m=0 then  begin
                    ExcelApp.ActiveSheet.range['A'+IntToStr(UsedRow-pRows+1)+ ':A'+IntToStr(UsedRow-1)].Merge ;
                    ChartObjects :=ExcelApp.ActiveSheet.ChartObjects.add(290,50+(UsedRow-pRows-3)*16.55 ,300,16.55*(pRows-1)-3);
                    ChartObjects.Chart.ChartType:=xlLineMarkers;
                    ChartObjects.Chart.HasLegend := FALSE;
                    chartObjects.chart.SetSourceData(ExcelApp.ActiveSheet.Range['B'+IntToStr(UsedRow-pRows+1)+ ':D'+IntToStr(UsedRow-1)]);
                end else  begin
                    ExcelApp.ActiveSheet.range['A'+IntToStr(UsedRow-pRows)+ ':A'+IntToStr(UsedRow-1)].Merge;
                    ChartObjects :=ExcelApp.ActiveSheet.ChartObjects.add(290,50+(UsedRow-pRows-4-m)*16.55+m*5 ,300,16.55*(pRows)-3);
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

                  ChartObjects :=ExcelApp.ActiveSheet.ChartObjects.add(290,50+(UsedRow-pRows-m-4)*16.55+m*5,300,16.55*(pRows+1)-3);
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
        ExcelApp.ActiveSheet.range['A1:K1'].Merge;
        ExcelApp.ActiveSheet.range['A1:K1'].Font.Color :=clWhite;
        ExcelApp.ActiveSheet.range['A1:K1'].Font.Size :=18;
        ExcelApp.ActiveSheet.range['A1:K'+IntToStr(usedRow)].Font.Name :='Tohama';
        ExcelApp.ActiveSheet.range['A1:K1'].Font.Bold :=True;
        ExcelApp.ActiveSheet.range['A1:K1'].Interior.Color :=rgb(0,32,96);
        ExcelApp.ActiveSheet.range['A3:E3'].Font.Color :=clWhite;
        ExcelApp.ActiveSheet.range['A3:E3'].Font.Bold :=True;
        ExcelApp.ActiveSheet.range['A3:E3'].Interior.Color :=rgb(0,32,96);

        ExcelApp.Columns[1].columnwidth :=15;
        ExcelApp.Columns[2].columnwidth :=20;
        ExcelApp.Columns[3].columnwidth :=20;
        ExcelApp.Columns[4].columnwidth :=15;
        ExcelApp.Columns[5].columnwidth :=15;


        ExcelApp.ActiveSheet.Range['A3:E'+IntToStr(UsedRow-1)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A3:E'+IntToStr(UsedRow-1)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A3:E'+IntToStr(UsedRow-1)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A3:E'+IntToStr(UsedRow-1)].Borders[4].Weight := 2;
        
        ExcelApp.ActiveSheet.Range['A1:J'+IntToStr(UsedRow-1)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:J'+IntToStr(UsedRow-1)].VerticalAlignment :=2;

        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
        ExcelApp.Quit;
        MessageDlg('Save OK',mtConfirmation,[mbyes],0);

    end;
end;

procedure TfDetail.QueryModel(QryTemp1:TClientDataSet;START_DATE,END_DATE:string);
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'STARTDATE',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'ENDDATE',ptInput);
    QryTemp1.CommandText := ' SELECT distinct Model_Name  ' +
                            ' from ( SELECT C.Model_Name,A.Repair_time ' +
                            ' FROM SAJET.G_SN_REPAIR A,SAJET.SYS_PART B, SAJET.SYS_MODEL C ' +
                            ' WHERE A.MODEL_ID=B.PART_ID AND B.MODEL_ID=C.MODEL_ID  and '+
                            ' A.Repair_time > =to_date(:STARTDATE,''yyyymmddhh24'') AND '+
                            ' A.Repair_time < to_date(:ENDDATE,''yyyymmddhh24'')) order by Model_Name ' ;

    QryTemp1.Params.ParamByName('STARTDATE').AsString := START_DATE;
    QryTemp1.Params.ParamByName('ENDDATE').AsString := END_DATE;
    QryTemp1.Open;
end;

procedure TfDetail.FormShow(Sender: TObject);
var i:integer;
begin
    DateTimePicker1.Date :=  Now;
    DateTimePicker2.Date :=  tomorrow;
end;

procedure TfDetail.btn1Click(Sender: TObject);
var Index,j:Integer;
begin
   FrmList:=TFrmList.Create(nil);
   FrmList.PL_Left.Caption:=' Model List' ;
   FrmList.PL_Right.Caption:='Choosen Model List' ;

   DateTimePicker1.OnChange(Sender);
   DateTimePicker2.OnChange(Sender);
   QueryModel(QryTemp,sStartTime,sEndTime);
   if not QryTemp.IsEmpty then begin
       QryTemp.First;
       for j:=0  to QryTemp.RecordCount-1 do begin
            FrmList.LB_Left.Items.Add(QryTemp.fieldbyName('Model_Name').asString);
            QryTemp.Next;
       end;
   end else begin
        Exit;
   end;

   Try
        if LV_Role.Items.Count<>0 then begin
           FrmList.LB_Right.Clear;
           For Index:=0 to Lv_ROle.Items.Count-1 do
           FrmList.LB_Right.Items.Add(Lv_ROle.Items[Index].Caption);
        End;
        if FrmList.ShowModal=MrOK then  begin
           Lv_Role.Clear;
           sModelList := '(';
          if FrmList.LB_Right.Items.Count<>0 then
             For Index:=0 to FrmList.LB_Right.Items.Count-1 do
             begin
                 Lv_ROle.Items.Add().Caption:=FrmList.LB_Right.Items[Index];
                 sModelList := sModelList+''''+ FrmList.LB_Right.Items[Index]+''',';
             end;
        End;
   Finally
        FrmList.Free;
   End;
   sModelList := Copy(sModelList,1,Length(sModelList)-1)+')';
end;

procedure TfDetail.DateTimePicker1Change(Sender: TObject);
begin
    if length(ComboBox1.Text)=1  then  sTime1 := '0' + ComboBox1.Text
    else  sTime1 := ComboBox1.Text;
    sStartTime  := FormatDateTime('yyyymmdd',DateTimePicker1.Date)+ sTime1  ;
end;

procedure TfDetail.ComboBox1Change(Sender: TObject);
begin
     DateTimePicker1.OnChange(Sender);
end;

procedure TfDetail.DateTimePicker2Change(Sender: TObject);
begin
   if length(ComboBox2.Text)=1  then  sTime2 := '0' + ComboBox2.Text
   else  sTime2 := ComboBox2.Text;
    sEndTime  := FormatDateTime('yyyymmdd',DateTimePicker2.Date)+ sTime2 ;
end;

procedure TfDetail.ComboBox2Change(Sender: TObject);
begin
    DateTimePicker2.OnChange(Sender);
end;

end.
