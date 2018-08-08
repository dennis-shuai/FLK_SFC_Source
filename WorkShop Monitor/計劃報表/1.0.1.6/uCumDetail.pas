unit uCumDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, DB, DBClient, StdCtrls, ComCtrls, ExtCtrls, DateUtils,
  Buttons;

type
  TuCum = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    sbtnQuery: TSpeedButton;
    ImageSample: TImage;
    ComboBox2: TComboBox;
    DateTimePicker2: TDateTimePicker;
    Label2: TLabel;
    ComboBox1: TComboBox;
    DateTimePicker1: TDateTimePicker;
    Label1: TLabel;
    DataSource2: TDataSource;
    QryTemp1: TClientDataSet;
    QryTemp2: TClientDataSet;
    procedure FormCreate(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
 
  private
    { Private declarations }
  public
    { Public declarations }
    sStartTime,sEndTime, sDStartTime ,sDEndTime:string;
    sStartHour,sEndHour:string;
    function QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function QueryOutput(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function QueryPlanAndOutput(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
  end;

var
  uCum: TuCum;

implementation

uses MainForm;

{$R *.dfm}

function TuCum.QueryOutput(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.CommandText:=' select B.PROCESS_NAME, B.PROCESS_CODE, '+
                         ' DECODE((SUM(C.PASS_QTY)), NULL, 0, (SUM(C.PASS_QTY))) FPY_QTY , '+
                         ' DECODE((SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.FAIL_QTY))) FAIL_QTY, '+
                         ' DECODE((SUM(C.OUTPUT_QTY)), NULL, 0, (SUM(C.OUTPUT_QTY))) Output_QTY, '+
                         ' DECODE((SUM(C.NTF_QTY)), NULL, 0, (SUM(C.NTF_QTY))) NTF_QTY, '+
                         ' DECODE((SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY))) TOTAL_QTY , '+
                         ' round(DECODE((SUM(C.PASS_QTY)),  NULL, 0, (SUM(C.PASS_QTY))) / DECODE((SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)))*100,2)  as "FPY(%)" , '+
                         ' round( DECODE((SUM(C.PASS_QTY) +SUM(C.NTF_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.NTF_QTY)))  / DECODE((SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)))*100,2) as "SPY(%)" '+
                         ' FROM   SAJET.SYS_PROCESS B ,  ' +
                         ' (select WORK_ORDER,MODEL_ID,PDLINE_ID,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REFAIL_QTY,OUTPUT_QTY,NTF_QTY,to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime  '+
                         ' from SAJET.G_SN_COUNT where WORK_ORDER NOT LIKE ''RM%'' and (PASS_QTY+FAIL_QTY)<>0)  C ,sajet.sys_part d ' +
                         ' WHERE   C.DateTime >=:StartTime and C.DateTime <:endTime   AND  b.PROCESS_NAME <> ''Particle Test'' and '+
                         ' c.model_ID =d.Part_ID and '+
                         ' C.PROCESS_ID = B.PROCESS_ID GROUP BY B.PROCESS_NAME, B.PROCESS_CODE ORDER BY B.PROCESS_CODE ';
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sEndTime;
    QryTemp1.Open;
end;


function TuCum.QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.CommandText:= 'select Process_NAME , DEFECT_CODE ,Defect_desc,count(C_SN) as Count  ' +
                           ' from '    +
                           ' (    '    +
                           ' ( select   a.Serial_number,B.PROCESS_NAME , Defect_Code, c.Defect_desc,1 as C_SN   '+
                           ' from                   '+
                           ' sajet.g_SN_defect_first a,sajet.SYS_PROCESS b,sajet.sys_defect c     '+
                           ' where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyy/mm/dd hh24:mi:ss'')  '+
                           ' and a.REC_Time <to_date(:EndTime, ''yyyy/mm/dd hh24:mi:ss'')  and a.WORK_ORDER NOT LIKE ''RM%'' '+
                           ' group by  B.PROCESS_NAME , C.defect_Code, c.Defect_desc ,a. Serial_number )  '+
                           ' )  '+
                           ' group by Process_NAME,DEFECT_CODE ,Defect_desc ' +
                           ' order  by process_name, Count desc ' ;
    QryTemp1.Params.ParamByName('StartTime').AsString := sDStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sDEndTime;
    QryTemp1.Open;
end;

function TuCum.QueryPlanAndOutput(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'Start_Time',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'End_Time',ptInput);
    QryTemp1.CommandText:= ' SELECT AA.MODEL_NAME,AA.PROCESS_NAME,AA.PROCESS_CODE, AA.OUTPUT_QTY,NVL(BB.PLAN_QTY,0) PLAN_QTY '+
                           ' FROM ( SELECT D.MODEL_NAME,B.PROCESS_NAME,B.PROCESS_ID,B.PROCESS_CODE,SUM(A.OUTPUT_QTY) OUTPUT_QTY '+
                           ' FROM sajet.g_SN_COUNT A ,SAJET.SYS_PROCESS B,SAJET.SYS_PART C,SAJET.SYS_MODEL D,SAJET.SYS_PDLINE_MONITOR_BASE E '+
                           ' WHERE A.MODEL_ID=C.PART_ID AND C.MODEL_ID = D.MODEL_ID  AND A.PROCESS_ID=B.PROCESS_ID '+
                           ' AND A.PROCESS_ID=E.PROCESS_ID AND A.PDLINE_ID=E.PDLINE_ID  AND A.OUTPUT_QTY <>0 '+
                           ' AND to_char(A.WORK_DATE)||TRIM(to_CHAR(A.WORK_TIME,''00'')) >= :Start_Time   '+
                           ' AND to_char(A.WORK_DATE)||TRIM(to_CHAR(A.WORK_TIME,''00'')) < :End_Time  AND¡@A.WORK_ORDER LIKE ''NM%'' '+
                           ' GROUP BY D.MODEL_NAME,B.PROCESS_NAME,B.PROCESS_ID,B.PROCESS_CODE) AA, '+
                           ' ( SELECT A.MODEL_NAME,B.PROCESS_ID,SUM(A.PRODUCE_QTY) PLAN_QTY FROM SAJET.G_PDLINE_MANAGE A,SAJET.SYS_PDLINE_MONITOR_BASE B '+
                           '   WHERE  A.REPAIR_LINE=''N'' AND A.PD_STATUS=1 AND A.PDLINE_ID =B.PDLINE_ID AND a.model_name is not null '+
                           '   AND A.STARTTIME >=:Start_Time AND A.ENDTIME<=:End_Time GROUP BY A.MODEL_NAME,B.PROCESS_ID  ) BB   '+
                           '   WHERE  AA.MODEL_NAME=BB.MODEL_NAME(+) AND AA.PROCESS_ID =BB.PROCESS_ID(+)  '+
                           '   ORDER BY AA.PROCESS_CODE,PLAN_QTY DESC,AA.MODEL_NAME' ;
    QryTemp1.Params.ParamByName('Start_Time').AsString := sStartTime;
    QryTemp1.Params.ParamByName('End_Time').AsString :=   sEndTime;
    QryTemp1.Open;

end;

procedure TuCum.FormCreate(Sender: TObject);
begin

    DateTimePicker1.Date := today;
    DateTimePicker2.Date := today;

    QryTemp1.RemoteServer := uMainForm.SocketConnection1;
    QryTemp1.ProviderName := 'DspQryTemp1';
    QryTemp2.RemoteServer := uMainForm.SocketConnection1;
    QryTemp2.ProviderName := 'DspQryTemp1';


    sbtnQuery.Click;

end;

procedure TuCum.sbtnQueryClick(Sender: TObject);
var i:integer;
     iYield:Double;
begin

    {
    QueryOutput(QryTemp1,sStartTime ,sEndTime );
    iYield :=1;
    QryTemp1.First;
    for i:=0 to QryTemp1.RecordCount -1 do
    begin
         if   (QryTemp1.fieldbyname('PROCESS_NAME').AsString <> 'OQC-TEST') and
              (QryTemp1.fieldbyname('PROCESS_NAME').AsString <> 'REPAIR_TEST')  then
               iYield := iYield*QryTemp1.fieldbyname('FPY(%)').AsFloat/100;
        QryTemp1.Next;
    end;
    iYield :=iYield *100;
    Label4.Caption := Format('%.2f',[iYield])+'%';
    QueryDefect(QryTemp2,sDStartTime ,sDEndTime );
    }

    sStartHour := ComboBox1.Text ;
    sEndHour := ComboBox2.Text ;
    if  StrToInt( ComboBox1.Text) <  10  then  sStartHour  :=  '0'+ComboBox1.Text  ;
    if  StrToInt( ComboBox2.Text) <  10  then  sEndHour  :=  '0'+ComboBox2.Text  ;

    sStartTime  :=  FormatDateTime('yyyymmdd',DateTimePicker1.Date)+  sStartHour   ;
    sEndTime    :=  FormatDateTime('yyyymmdd',DateTimePicker2.Date)+  sEndHour   ;


    //sDStartTime :=  FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+  sStartHour+':00:00' ;
    //sDEndTime   :=  FormatDateTime('yyyy/mm/dd',DateTimePicker2.Date)+  sEndHour+':00:00';
    QueryPlanAndOutput(QryTemp1,sStartTime,sEndTime );

end;

procedure TuCum.FormKeyPress(Sender: TObject; var Key: Char);
begin
     if Key=#27 then uCum.Close;
end;

end.
