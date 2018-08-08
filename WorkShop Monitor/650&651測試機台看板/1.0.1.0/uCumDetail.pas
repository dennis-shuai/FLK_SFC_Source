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
  end;

var
  uCum: TuCum;

implementation

uses MainForm, uLineDetail;

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
                         ' from SAJET.G_SN_COUNT where WORK_ORDER NOT LIKE ''RM%'')  C ,sajet.sys_part d ' +
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
                                 '  ( select   a.Serial_number,B.PROCESS_NAME , C.defect_Code, c.Defect_desc,1 as C_SN   '+
                                         ' from           '+
                                         ' sajet.g_SN_defect_first a,sajet.SYS_PROCESS b,sajet.sys_defect c    '+
                                         ' where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyy/mm/dd hh24:mi:ss'') '+
                                         ' and a.REC_Time <to_date(:EndTime, ''yyyy/mm/dd hh24:mi:ss'')   and c.defect_Code not like ''SFR%''   ' +
                                         ' and a.ntf_time is null  and a.WORK_ORDER NOT LIKE ''RM%'' '+
                                         ' group by  B.PROCESS_NAME , C.defect_Code , c.Defect_desc,a. Serial_number  )  '+
                                   ' union           '+
                                         ' ( select   a.Serial_number,B.PROCESS_NAME , ''SFR'' as Defect_Code, c.Defect_desc,1 as C_SN   '+
                                         ' from                   '+
                                         ' sajet.g_SN_defect_first a,sajet.SYS_PROCESS b,sajet.sys_defect c     '+
                                         ' where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyy/mm/dd hh24:mi:ss'')  '+
                                         ' and a.REC_Time <to_date(:EndTime, ''yyyy/mm/dd hh24:mi:ss'')   and c.defect_Code  like ''SFR%''  and a.ntf_time is null and a.WORK_ORDER NOT LIKE ''RM%'' '+
                                         ' group by  B.PROCESS_NAME , C.defect_Code, c.Defect_desc ,a. Serial_number )  '+
                           ' )  where Process_NAME <> ''Particle Test'' '+
                           ' group by Process_NAME,DEFECT_CODE ,Defect_desc ' +
                           ' order  by process_name, Count desc ' ;
    QryTemp1.Params.ParamByName('StartTime').AsString := sDStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sDEndTime;
    QryTemp1.Open;
end;

procedure TuCum.FormCreate(Sender: TObject);
begin
    DateTimePicker1.Date := today;
    DateTimePicker2.Date := tomorrow;
    if  StrToInt( ComboBox1.Text) <  10  then  sStartHour  :=  '0'+ComboBox1.Text  ;
    if  StrToInt( ComboBox2.Text) <  10  then  sEndHour  :=  '0'+ComboBox2.Text  ;

    QryTemp1.RemoteServer := uMainForm.SocketConnection1;
    QryTemp1.ProviderName := 'DspQryData';
    QryTemp2.RemoteServer := uMainForm.SocketConnection1;
    QryTemp2.ProviderName := 'DspQryTemp1';

    sStartTime  :=  FormatDateTime('yyyymmdd',DateTimePicker1.Date)+  sStartHour   ;
    sEndTime    :=  FormatDateTime('yyyymmdd',DateTimePicker2.Date)+  sEndHour   ;
    sDStartTime :=  FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+  sStartHour+':00:00' ;
    sDEndTime   :=  FormatDateTime('yyyy/mm/dd',DateTimePicker2.Date)+  sEndHour+':00:00';

    sbtnQuery.Click;

end;

procedure TuCum.sbtnQueryClick(Sender: TObject);
begin

    sStartTime  :=   FormatDateTime('yyyymmdd',DateTimePicker1.Date)+  sStartHour   ;
    sEndTime    :=   FormatDateTime('yyyymmdd',DateTimePicker2.Date)+  sEndHour   ;
    sDStartTime :=   FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+  sStartHour+':00:00' ;
    sDEndTime   :=   FormatDateTime('yyyy/mm/dd',DateTimePicker2.Date)+  sEndHour+':00:00';

    QueryOutput(QryTemp1,sStartTime ,sEndTime );
    QueryDefect(QryTemp2,sDStartTime ,sDEndTime );
end;

procedure TuCum.FormKeyPress(Sender: TObject; var Key: Char);
begin
     if Key=#27 then uCum.Close;
end;

end.
