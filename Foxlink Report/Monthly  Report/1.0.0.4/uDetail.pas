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
    DBGrid1: TDBGrid;
    SaveDialog1: TSaveDialog;
    Label2: TLabel;
    DateTimePicker2: TDateTimePicker;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    cmbModel: TComboBox;
    Label3: TLabel;
    qryTemp2: TClientDataSet;
    QryData1: TClientDataSet;
    ProgressBar1: TProgressBar;
    procedure sbtnQueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID,sModelName : String;
    Count:Integer;
    UpDate_Time :TDateTime;
    sStartTime, sEndTime, sDStartTime, sDEndTime,sTime1,sTime2 :string;
    function QueryOutput( QryTemp1:TClientDataset;StartTime:String;EndTime:String):boolean;
    function QueryDefect(QryTemp1:TClientDataset;StartTime:String;EndTime:String;PROCESS_NAME:String):boolean;
    function QueryOutputByPDLine( QryTemp1:TClientDataset;StartTime:String;EndTime:String):boolean;
    function QueryDefectCode(QryTemp1:TClientDataset;StartTime:String;EndTime:String;PROCESS_NAME:string):boolean;
    function QueryProcessName(QryTemp1:TClientDataset;StartTime:String;EndTime:String):boolean;
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


    sModelName := cmbModel.Text;
    QueryOutput(QryData, sStartTime, sEndTime);

end;


function TfDetail.QueryOutput(QryTemp1:TClientDataset;StartTime,EndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Model_NAme',ptInput);
    QryTemp1.CommandText:=' select B.PROCESS_NAME, B.PROCESS_CODE, '+
                         ' DECODE((SUM(C.PASS_QTY)), NULL, 0, (SUM(C.PASS_QTY))) FPY_QTY , '+
                         ' DECODE((SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.FAIL_QTY))) FAIL_QTY, '+
                         ' DECODE((SUM(C.OUTPUT_QTY)), NULL, 0, (SUM(C.OUTPUT_QTY))) Output_QTY, '+
                         ' DECODE((SUM(C.NTF_QTY)), NULL, 0, (SUM(C.NTF_QTY))) NTF_QTY, '+
                         ' DECODE((SUM(C.REPAIR_QTY)), NULL, 0, (SUM(C.REPAIR_QTY))) REPAIR_QTY, '+
                         ' DECODE((SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY))) TOTAL_QTY , '+
                         ' round(DECODE(SUM(C.PASS_QTY),  NULL, 0,SUM(C.PASS_QTY)) / DECODE(SUM(C.PASS_QTY) +SUM(C.FAIL_QTY), NULL, 0,0,1000000000, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)))*100,2)  as "FPY(%)" , '+
                         ' round( DECODE( SUM(C.PASS_QTY) +SUM(C.NTF_QTY), NULL, 0,0,1, SUM(C.PASS_QTY) +SUM(C.NTF_QTY) )  / DECODE(  SUM(C.PASS_QTY+C.FAIL_QTY), NULL, 0,0,100000000 ,(SUM(C.PASS_QTY +C.FAIL_QTY)))*100,2) as "SPY(%)" '+
                         ' FROM   SAJET.SYS_PROCESS B ,  ' +
                         ' (select WORK_ORDER,MODEL_ID,PDLINE_ID,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REFAIL_QTY,OUTPUT_QTY,NTF_QTY,REPAIR_QTY,to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime  '+
                         ' from SAJET.G_SN_COUNT where WORK_ORDER NOT LIKE ''RM%'' )  C ,sajet.sys_part d ,sajet.sys_Part e,sajet.sys_model f' +
                         ' WHERE   C.DateTime >=:StartTime and C.DateTime <:endTime   AND '+
                         ' c.model_ID =d.Part_ID and C.Model_ID = E.Part_ID and e.Model_ID= f.Model_ID and f.MOdel_Name =:Model_Name and B.PROCESS_CODE IS NOT NULL and'+
                         ' C.PROCESS_ID = B.PROCESS_ID GROUP BY B.PROCESS_NAME, B.PROCESS_CODE ORDER BY B.PROCESS_CODE ';

    QryTemp1.Params.ParamByName('StartTime').AsString := StartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   EndTime;
    QryTemp1.Params.ParamByName('Model_Name').AsString :=  sModelName;
    QryTemp1.Open;
end;



function TfDetail.QueryDefect(QryTemp1:TClientDataset;StartTime:String;EndTime:String;PROCESS_NAME:string):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Model_NAme',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'PROCESS_NAme',ptInput);
    QryTemp1.CommandText:= 'SELECT ALL_DEFECT,Defect_desc,SUM(C_SN) C_SN FROM  ' +
                           ' (SELECT  DEFECT_CODE ALL_DEFECT,Defect_desc,  C_SN '+
                           '    FROM  '+
                           '    ( select  a.WORK_ORDER, a.Serial_number,B.PROCESS_NAME ,b.Process_Code, C.Defect_Code, c.Defect_desc,1 as C_SN   '+
                                   ' from                   '+
                                   ' sajet.g_SN_defect_first a,sajet.SYS_PROCESS b,sajet.sys_defect c ,sajet.sys_part d , sajet.sys_Model e  '+
                                   ' where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyy/mm/dd hh24:mi:ss'')  '+
                                   ' and a.REC_Time <to_date(:EndTime, ''yyyy/mm/dd hh24:mi:ss'')   and a.ntf_time is null and a.WORK_ORDER NOT LIKE ''RM%'' '+
                                   ' and a.MOdel_ID=d.Part_ID and e.MOdel_ID =d.Model_ID and e.Model_Name =:Model_Name  AND B.PROCESS_NAME=:PROCESS_NAME'+
                                   ' group by A.WORK_ORDER, B.PROCESS_NAME ,b.Process_Code, C.defect_Code, c.Defect_desc ,a. Serial_number )  '+
                           ' )     '+
                           ' GROUP BY  ALL_DEFECT,Defect_desc ' ;
    QryTemp1.Params.ParamByName('StartTime').AsString := StartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := EndTime;
    QryTemp1.Params.ParamByName('Model_Name').AsString :=   sModelName;
    QryTemp1.Params.ParamByName('PROCESS_Name').AsString :=   PROCESS_NAME;
    QryTemp1.Open;

end;

function TfDetail.QueryDefectCode(QryTemp1:TClientDataset;StartTime:String;EndTime:String;PROCESS_NAME:string):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Model_NAme',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Process_Name',ptInput);
    QryTemp1.CommandText:= 'SELECT  C.DEFECT_CODE,C.DEFECT_DESC '+
                           ' FROM SAJET.G_SN_DEFECT_FIRST A,SAJET.SYS_PROCESS B,SAJET.SYS_DEFECT C,SAJET.SYS_PART D,SAJET.SYS_MODEL E '+
                           ' WHERE A.PROCESS_ID=B.PROCESS_ID AND B.PROCESS_NAME=:PROCESS_NAME AND A.DEFECT_ID=C.DEFECT_ID  '+
                           ' AND A.NTF_TIME IS NULL AND A.WORK_ORDER NOT LIKE ''RM%'' '+
                           ' AND A.REC_TIME>=to_date(:StartTime,''yyyy-mm-dd HH24:mi:ss'') AND A.REC_TIME < '+
                           ' to_date(:EndTime,''yyyy-mm-dd HH24:MI:SS'') AND E.MODEL_NAME=:Model_NAme AND '+
                           ' A.MODEL_ID=D.PART_ID AND D.MODEL_ID =E.MODEL_ID GROUP BY C.DEFECT_CODE,C.DEFECT_DESC  ';
    QryTemp1.Params.ParamByName('StartTime').AsString := StartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := EndTime;
    QryTemp1.Params.ParamByName('Model_Name').AsString := sModelName;
    QryTemp1.Params.ParamByName('Process_Name').AsString :=PROCESS_NAME;
    QryTemp1.Open;

end;

function TfDetail.QueryProcessName(QryTemp1:TClientDataset;StartTime:String;EndTime:String):boolean;
begin

    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Model_NAme',ptInput);
    QryTemp1.CommandText:= ' SELECT B.PROCESS_NAME,B.PROCESS_CODE FROM sajet.g_SN_COUNT A,SAJET.SYS_PROCESS B, SAJET.SYS_PART C,SAJET.SYS_MODEL D '+
                           ' WHERE A.PROCESS_ID=B.PROCESS_ID AND A.WORK_DATE>=:StartTime AND A.WORK_DATE <= :EndTime  AND '+
                           ' A.MODEL_ID=C.PART_ID AND C.MODEL_ID =D.MODEL_ID AND D.MODEL_NAME=:Model_NAme  AND B.PROCESS_CODE IS NOT NULL '+
                           ' GROUP BY B.PROCESS_NAME,B.PROCESS_CODE ORDER BY PROCESS_CODE ';
    QryTemp1.Params.ParamByName('StartTime').AsString := StartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := EndTime;
    QryTemp1.Params.ParamByName('Model_Name').AsString := sModelName;
    QryTemp1.Open;



end;

function TfDetail.QueryOutputByPDLine( QryTemp1:TClientDataset;StartTime:String;EndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Model',ptInput);
    QryTemp1.CommandText:=' select  a.pdLine_NAME,B.PROCESS_NAME, B.PROCESS_CODE, '+
                         ' DECODE((SUM(C.PASS_QTY)), NULL, 0, (SUM(C.PASS_QTY))) FPY_QTY,  '+
                         ' DECODE((SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.FAIL_QTY))) FAIL_QTY, '+
                         ' DECODE((SUM(C.OUTPUT_QTY)), NULL, 0, (SUM(C.OUTPUT_QTY))) OUTPUT_QTY, ' +
                         ' DECODE((SUM(C.NTF_QTY)), NULL, 0, (SUM(C.NTF_QTY))) NTF_QTY, ' +
                         ' DECODE((SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY))) TOTAL_QTY   '+
                         ' FROM   sajet.sys_pdline a  ,SAJET.SYS_PROCESS B ,  ' +
                         ' (select WORK_ORDER,MODEL_ID,PDLINE_ID,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REFAIL_QTY,OUTPUT_QTY,NTF_QTY,to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime  '+
                         ' from SAJET.G_SN_COUNT ) C ,sajet.sys_part d,sajet.sys_model e ' +
                         ' WHERE   C.DateTime >=:StartTime and C.DateTime <:endTime   AND a.pdline_ID =c.PDLINE_ID and C.WORK_ORDER NOT Like ''RM%'' AND '+
                         ' c.model_ID =d.Part_ID and d.Model_ID = e.Model_ID and e.Model_Name =:Model   and  a.pdLine_NAME  like ''%CM-%'' and '+
                         ' C.PROCESS_ID = B.PROCESS_ID  GROUP BY a.pdLine_NAME,B.PROCESS_NAME, B.PROCESS_CODE ORDER BY B.PROCESS_CODE ';
    QryTemp1.Params.ParamByName('StartTime').AsString := StartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := EndTime;
    QryTemp1.Params.ParamByName('Model').AsString := sModelName;
    QryTemp1.Open;
end;

procedure TfDetail.sBtnExportClick(Sender: TObject);
var
    strNTF :string;
    strTitle,strFPY,strPDline,strPDLineFrist,strRepass,strTotal,strDefectName,strDefect_QTY,strDefect_Desc,strFailAll,sDefect_Code :string;
    i,j,K,L,FirstCount,UsedRow,AllRows,UsedDays,defect_count,count,DayCounts,AllMDay_Count,Repair_Qty,iPos:integer;
    ExcelApp,Range: Variant;
    sStartTime,sEndTime,sProcess,FPY_Target:string;
    Rowlist,SPYRowlist :TStringList;
    FPY,SPY,FinalYield:double;

begin

    if SaveDialog1.Execute then begin
        if FileExists(SaveDialog1.FileName) then
             DeleteFile(SaveDialog1.FileName);

        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible := false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'Monthly Report.xlt');
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.WorkSheets[1].Name :=   sModelName ;
        ExcelApp.Cells[1,1].Value := cmbModel.Text +' Monthly Report';

        i:=0;
        j:=0;
        k:=0;
        UsedDays:=0;

        DayCounts:= Round(DateTimePicker2.Date - DateTimePicker1.Date);
        if  StartoftheMonth(Now) = Date then   begin
            AllMDay_Count :=   Round( EndoftheMonth(Now-1)- StartoftheMonth(Now-1));
        end else begin
            AllMDay_Count :=   Round( EndoftheMonth(Now)- StartoftheMonth(Now));
        end;
        
        for I:=0 to AllMDay_Count-1 do begin
            ExcelApp.Cells[16,4+i].Value := DateTimePicker1.Date+i;
        end;

        UsedRow := 16;
        ProgressBar1.Position :=10;
        if QryData.IsEmpty then exit;
        sStartTime := FormatDateTime('yyyymmdd',DateTimePicker1.Date);
        sEndTime  :=  FormatDateTime('yyyymmdd',DateTimePicker2.Date+1) ;
        sDStartTime := FormatDateTime('yyyy-mm-dd',DateTimePicker1.Date)+' 08:00:00' ;
        sDEndTime  :=  FormatDateTime('yyyy-mm-dd',DateTimePicker2.Date+1)+' 08:00:00' ;
        
        with QryTemp do begin
             close;
             Params.Clear;
             Params.CreateParam(ftstring,'Model_Name',ptInput);
             commandtext := 'select a.Lower_level from  SAJET.SYS_MODEL_RATE a,sajet.SYS_MODEL B where a.model_ID=b.MODEL_ID '+
                            '  and b.Model_NAME =:MODEL_NAME';
             Params.ParamByName('MODEL_NAME').AsString := sModelName;
             Open;

              if IsEmpty then begin
                  MessageBox(0,'沒有設置該機種的 良率目標','ERROR',MB_ICONERROR);
                  exit;
              end;
              FPY_Target := fieldbyName('Lower_level').AsString;

        end;


        QueryProcessName(QryTemp2,sStartTime,sEndTime);
        if not QryTemp2.IsEmpty then
        begin

             QryTemp2.First;
             for  j:=0 to QryTemp2.RecordCount-1  do
             begin
                 strTitle := QryTemp2.FieldByName('PROCESS_NAME').AsString ;
                 Application.ProcessMessages();
                 ExcelApp.Cells[UsedRow+1,1].Value :=  strTitle;
                 ExcelApp.Cells[UsedRow+1,2].Value :=   'Total Input';
                 ExcelApp.Cells[UsedRow+2,2].Value :=   'First Output';
                 ExcelApp.Cells[UsedRow+3,2].Value :=   'Total Defect';
                 ExcelApp.Cells[UsedRow+4,2].Value :=   'Retest Pass';
                 ExcelApp.Cells[UsedRow+5,2].Value :=   'Final NG';
                 ExcelApp.Cells[UsedRow+6,2].Value :=   'FPY(%)';
                 ExcelApp.Cells[UsedRow+7,2].Value :=   'Retest Yield(%)';
                 ExcelApp.Cells[UsedRow+8,2].Value :=   'SPY(%)';
                 ExcelApp.Cells[UsedRow+1,3].Value :=  '=SUM(D'+IntToStr(UsedRow+1)+':AH'+InttoStr(UsedRow+1)+')';
                 ExcelApp.Cells[UsedRow+2,3].Value :=  '=SUM(D'+IntToStr(UsedRow+2)+':AH'+InttoStr(UsedRow+2)+')';
                 ExcelApp.Cells[UsedRow+3,3].Value :=  '=SUM(D'+IntToStr(UsedRow+3)+':AH'+InttoStr(UsedRow+3)+')';
                 ExcelApp.Cells[UsedRow+4,3].Value :=  '=SUM(D'+IntToStr(UsedRow+4)+':AH'+InttoStr(UsedRow+4)+')';
                 ExcelApp.Cells[UsedRow+5,3].Value :=  '=SUM(D'+IntToStr(UsedRow+5)+':AH'+InttoStr(UsedRow+5)+')';
                 ExcelApp.Cells[UsedRow+6,3].Value :=  '= C'+IntToStr(UsedRow+2)+'/C'+InttoStr(UsedRow+1)+'*100';
                 ExcelApp.Cells[UsedRow+7,3].Value :=  '= IF( C'+InttoStr(UsedRow+3)+'=0,0,C'+IntToStr(UsedRow+4)+'/C'+InttoStr(UsedRow+3)+'*100)';
                 ExcelApp.Cells[UsedRow+8,3].Value :=  '= (C'+IntToStr(UsedRow+4)+'+C'+IntToStr(UsedRow+2)+')/C'+InttoStr(UsedRow+1)+'*100';

                 ExcelApp.ActiveSheet.Rows[UsedRow+6].Font.Color :=clBlue;
                 ExcelApp.ActiveSheet.Rows[UsedRow+6].NumberFormat  := '0.00';
                 ExcelApp.ActiveSheet.Rows[UsedRow+7].Font.Color :=clRed;
                 ExcelApp.ActiveSheet.Rows[UsedRow+7].NumberFormat  := '0.00';
                 ExcelApp.ActiveSheet.Rows[UsedRow+8].NumberFormat  := '0.00';
                 ExcelApp.ActiveSheet.Rows[UsedRow+8].Font.Color :=RGB(255,51,153);

                 ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow+1)+':A'+IntToStr(UsedRow+8)].Merge;
                 ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow+1)+':AH'+IntToStr(UsedRow+8)].Interior.Color :=rgb(185,245,245);;
                 UsedRow :=  UsedRow+9;
                 QueryDefectCode(QryTemp,sDStartTime,sDEndTime,strTitle);
                 if not QryTemp.IsEmpty then begin
                    Qrytemp.First;
                    FirstCount :=  UsedRow;
                    for k:=0 to  QryTemp.RecordCount-1  do
                    begin
                       ExcelApp.Cells[UsedRow,2].Value := Qrytemp.FieldByName('Defect_Code').AsString +'('
                                                          + Qrytemp.FieldByName('Defect_Desc').AsString +')';
                       ExcelApp.rows[UsedRow].Interior.Color :=rgb(235,185,185);
                       ExcelApp.Cells[UsedRow,3].Value :=  '=SUM(D'+IntToStr(UsedRow)+':AH'+InttoStr(UsedRow)+')';
                       UsedRow :=UsedRow+1;
                       Qrytemp.Next;
                    end;
                    ExcelApp.Cells[FirstCount,1].Value := 'Defect Detail';
                    ExcelApp.ActiveSheet.Range['A'+IntToStr(FirstCount)+':A'+IntToStr(UsedRow-1)].Merge;

                 end;
                 ExcelApp.rows[UsedRow].rowheight :=5;
                 ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow)+':AH'+IntToStr(UsedRow)].Merge;
                 QryTemp2.Next;
             end;
             
             ExcelApp.ActiveSheet.Range['A15:AH'+IntToStr(UsedRow-1)].Borders[1].Weight := 2;
             ExcelApp.ActiveSheet.Range['A15:AH'+IntToStr(UsedRow-1)].Borders[2].Weight := 2;
             ExcelApp.ActiveSheet.Range['A15:AH'+IntToStr(UsedRow-1)].Borders[3].Weight := 2;
             ExcelApp.ActiveSheet.Range['A15:AH'+IntToStr(UsedRow-1)].Borders[4].Weight := 2;
             ExcelApp.ActiveSheet.Range['A15:AH'+IntToStr(UsedRow-1)].HorizontalAlignment :=3;
             ExcelApp.ActiveSheet.Range['A15:AH'+IntToStr(UsedRow-1)].VerticalAlignment :=2;
             ExcelApp.ActiveSheet.Range['A15:AH'+IntToStr(UsedRow-1)].Font.Size :=8;
             ExcelApp.ActiveSheet.Range['A15:AH'+IntToStr(UsedRow-1)].Font.Name :='tahoma';

             AllRows := UsedRow;
             ProgressBar1.Position :=20;
             for I:=0 to DayCounts-1 do begin
                  Application.ProcessMessages();
                  ProgressBar1.Position :=  Round(I/DayCounts*80)+20 ;
                  sStartTime := FormatDateTime('yyyymmdd',DateTimePicker1.Date+i)+'08' ;
                  sEndTime  :=  FormatDateTime('yyyymmdd',DateTimePicker1.Date+i+1)+'08' ;
                  sDStartTime := FormatDateTime('yyyy-mm-dd',DateTimePicker1.Date+i)+' 08:00:00' ;
                  sDEndTime  :=  FormatDateTime('yyyy-mm-dd',DateTimePicker1.Date+i+1)+' 08:00:00' ;
                  QueryOutput(QryData1,sStartTime,sEndTime);
                  Rowlist := TStringList.Create;
                  SPYRowlist := TStringList.Create;
                  FinalYield :=100;
                  UsedRow := 16;
                  QryData1.First;
                  for j:=0 to   QryData1.RecordCount-1 do begin
                      strTitle := QryData1.FieldByName('PROCESS_NAME').AsString ;
                      Repair_Qty:= QryData1.FieldByName('REPAIR_QTY').AsInteger ;
                      for k:=3 to AllRows-1 do
                      begin
                         if  strTitle = ExcelApp.Cells[k,1].Value  then
                             UsedRow :=k;
                      end;
                      if UsedRow<=2 then exit;
                      strFPY :=  QryData1.FieldByName('FPY_QTY').AsString;
                      strTotal :=  QryData1.FieldByName('Total_QTY').AsString;
                      strRepass :=  QryData1.FieldByName('NTF_QTY').AsString;
                      ExcelApp.Cells[UsedRow,4+i].Value := strTotal;
                      ExcelApp.Cells[UsedRow+1,4+i].Value := strFPY;
                      ExcelApp.Cells[UsedRow+2,4+i].Value := StrToInt(strTotal)-strToInt(strFPY);
                      ExcelApp.Cells[UsedRow+3,4+i].Value := strRepass;
                      ExcelApp.Cells[UsedRow+4,4+i].Value := StrToInt(strTotal)-strToInt(strFPY)- strToInt(strRepass);

                      Rowlist.Add(IntToStr(UsedRow+5));
                      SPYRowlist.Add(IntToStr(UsedRow+7));

                      //ColList.Add(IntToStr(i+4));
                      if (StrToInt(strTotal)-strToInt(strFPY)) <> 0 then
                         ExcelApp.Cells[UsedRow+6,4+i].Value := StrToInt(strRepass)/(StrToInt(strTotal)-strToInt(strFPY))*100
                      else
                         ExcelApp.Cells[UsedRow+6,4+i].Value := 0;

                      if   StrToInt(strTotal)<> 0 then
                      begin
                         ExcelApp.Cells[UsedRow+5,4+i].Value := StrToInt(strFPY)/StrToInt(strTotal)*100;
                         ExcelApp.Cells[UsedRow+7,4+i].Value := (StrToInt(strFPY)+StrToInt(strRepass))/StrToInt(strTotal)*100 ;
                         FinalYield := FinalYield* (StrToInt(strFPY)+StrToInt(strRepass)+Repair_Qty) /StrToInt(strTotal);
                      end
                      else
                      begin
                         ExcelApp.Cells[UsedRow+7,4+i].Value := 100;
                         ExcelApp.Cells[UsedRow+5,4+i].Value := 100;
                      end;
                      UsedRow := UsedRow+7;
                      QueryDefect(QryDefect,sDStartTime,sDEndTime,strTitle);
                      if  not QryDefect.IsEmpty then
                      begin

                         for k:=UsedRow+1 to AllRows-1 do
                         begin
                            if ExcelApp.Cells[k,1].Value <> '' then
                                defect_count :=  k-1;
                         end;
                         QryDefect.First;
                         for K:=0 to QryDefect.RecordCount-1 do
                         begin

                            sDefect_Code := QryDefect.FieldByName('ALL_DEFECT').AsString ;

                            for L:=0 to defect_count do
                            begin
                                iPos := Pos('(', ExcelApp.Cells[UsedRow+L,2].Value );

                                if Copy(ExcelApp.Cells[UsedRow+L,2].Value,1,iPos-1) = sDefect_Code then
                                    ExcelApp.Cells[UsedRow+L,4+i].Value :=  QryDefect.FieldByName('C_SN').AsString ;
                            end;

                            QryDefect.Next;;
                         end;
                      end;
                      QryData1.Next;
                  end;
                  FPY := 100;
                  SPY :=100;
                  if RowList.Count<> 0 then begin
                     for j:=0 to  RowList.Count-1 do begin
                         FPY :=  FPY * ExcelApp.Cells[strtoint(RowList.Strings[j]),4+i].Value/100 ;
                         SPY :=  SPY* ExcelApp.Cells[strtoint(SPYRowList.Strings[j]),4+i].Value/100 ;
                     end  ;

                     ExcelApp.Cells[13,4+i].Value := FormatFloat('0.00',FPY);
                     ExcelApp.Cells[14,4+i].Value := FormatFloat('0.00',SPY);
                     ExcelApp.Cells[12,4+i].Value :=  FPY_Target ;
                     ExcelApp.Cells[15,4+i].Value :=  FinalYield ;
                   end;
                  RowList.Free;
                  SPYRowList.Free;
                  UsedRow := UsedRow+8;
             end;
        end;
       ExcelApp.WorkSheets[1].Activate;
       ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
       ExcelApp.Quit;
       ProgressBar1.Position :=100;
       MessageDlg('Save OK',mtConfirmation,[mbyes],0);

    end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var i:integer;
begin
    if  StartoftheMonth(Now) = Date then   begin
      DateTimePicker1.Date :=  StartoftheMonth(Now-1);
      DateTimePicker2.Date :=  EndoftheMonth(Now-1);
    end else begin
      DateTimePicker1.Date :=  StartoftheMonth(Now);
      DateTimePicker2.Date :=  tomorrow;
    end;
    qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Commandtext := 'select distinct (model_Name) MOdel from sajet.sys_model where ENABLED=''Y'' order by Model_Name ';
    qrytemp.Open;
    qrytemp.First;
    for i:=0 to qrytemp.recordcount-1 do begin
       cmbModel.Items.Add(qrytemp.fieldbyname('model').asstring) ;
       qrytemp.Next;
    end;
    cmbModel.Style :=csDropDownlist;
end;

end.
