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
    Label3: TLabel;
    Label4: TLabel;
    lbl1: TLabel;
    cmbModel: TComboBox;
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
    //QryTemp1.Params.CreateParam(ftstring,'WO',ptInput);
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
    // if CmbLine.text <> '' then
    //       QryTemp1.CommandText:=  QryTemp1.CommandText+' and  g.PDLINE_NAME = '''+cmbLine.Text+'''';


     QryTemp1.CommandText:=  QryTemp1.CommandText+' and  c.WORK_ORDER  not like ''RM%'' ';

     QryTemp1.CommandText:=  QryTemp1.CommandText+ '  GROUP BY B.PROCESS_NAME, B.PROCESS_CODE   ORDER BY B.PROCESS_CODE ';

    //QryTemp1.Params.ParamByName('WO').AsString := edtwo.text+'%';
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
    //QryTemp1.Params.CreateParam(ftstring,'WO',ptInput);
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

     //if CmbLine.text <> '' then
      //    QryTemp1.CommandText:=  QryTemp1.CommandText+' and  f.PDLINE_NAME = '''+cmbLine.Text+'''';

     QryTemp1.CommandText:=  QryTemp1.CommandText+' and  a.WORK_ORDER not like ''RM%'' ';


     QryTemp1.CommandText:=  QryTemp1.CommandText+' group by  B.PROCESS_NAME ,b.Process_Code, C.defect_Code, c.Defect_desc ,a. Serial_number '+
                           '    )'+
                           ' )  '+
                           ' group by Process_NAME,Process_Code,DEFECT_CODE ,Defect_desc '+
                           ' order  by Process_Code, Count desc ' ;

    //QryTemp1.Params.ParamByName('WO').AsString := edtWo.Text+'%';
    QryTemp1.Params.ParamByName('StartTime').AsString := sDStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sDEndTime;
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
var i:integer;
     iYield:Double;
begin

    sStartTime  :=   FormatDateTime('yyyymmdd',DateTimePicker1.Date)+  sStartHour   ;
    sEndTime    :=   FormatDateTime('yyyymmdd',DateTimePicker2.Date)+  sEndHour   ;
    sDStartTime :=   FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+  sStartHour+':00:00' ;
    sDEndTime   :=   FormatDateTime('yyyy/mm/dd',DateTimePicker2.Date)+  sEndHour+':00:00';

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
end;

procedure TuCum.FormKeyPress(Sender: TObject; var Key: Char);
begin
     if Key=#27 then uCum.Close;
end;

end.
