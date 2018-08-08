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
    DBGrid2: TDBGrid;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    cmbModel: TComboBox;
    Label3: TLabel;
    Label5: TLabel;
    edtWo: TEdit;
    SpeedButton1: TSpeedButton;
    Image3: TImage;
    LV_Role: TListView;
    Label4: TLabel;
    cmbProcess: TComboBox;
    QryDefectDetail: TClientDataSet;
    chkRetest: TCheckBox;
    procedure sbtnQueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure cmbModelChange(Sender: TObject);
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
    function  QueryOutput( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function  QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function  QueryOutputByPDLine( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String;PDLine:String):boolean;
    procedure QueryLine(QryTemp1:TClientDataSet;START_DATE,END_DATE:string);
    function  QueryDefectByPDLine(QryTemp1:TClientDataset;sStart:String;sEnd:String;PDLine:String):boolean;
    function  QueryDefectItemByPdline(QryTemp1:TClientDataset;sStart:String;sEnd:String;PDLine:string;Defect_Code:string):boolean;
  end;

var
  fDetail: TfDetail;
  mWO,mPartID,mPartNO,mCustPartNO,sPdlineList:string;


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

    sDStartTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+ ' '+ sTime1+':00:00'  ;
    sDEndTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker2.Date) + ' ' + sTime2 +':00:00' ;

    QueryOutput(QryData, sStartTime, sEndTime);
    QueryDefect(QryDefect,sDStartTime,sDEndTime);
    DbGrid2.Columns[0].Width :=120;
    DbGrid2.Columns[1].Width :=120;
    DbGrid2.Columns[2].Width :=240;
    DbGrid2.Columns[3].Width :=120;
end;

procedure TfDetail.QueryLine(QryTemp1:TClientDataSet;START_DATE,END_DATE:string);
var
  sSTART_DATE,sEND_DATE:string;
  sStart_Time,sEnd_Time:string;
begin


    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'STARTDATE',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'ENDDATE',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'WO',ptInput);
    QryTemp1.CommandText := ' SELECT distinct PDLINE_NAME  ' +
                            ' from ( SELECT D.PDLINE_NAME,A.output_qty,TO_NUMBER(TO_CHAR(A.WORK_DATE)||TRIM(TO_CHAR(A.WORK_TIME,''00''))) DATETIME ' +
                            ' FROM SAJET.G_SN_COUNT A,SAJET.SYS_PART B, SAJET.SYS_MODEL C ,SAJET.SYS_PDLINE D ,SAJET.SYS_PROCESS E ' +
                            ' WHERE A.MODEL_ID=B.PART_ID AND B.MODEL_ID=C.MODEL_ID AND A.PDLINE_ID=D.PDLINE_ID AND A.PROCESS_ID=E.PROCESS_ID ' +
                            ' AND A.output_qty <> 0 AND A.MODEL_ID=B.PART_ID AND B.MODEL_ID =C.MODEL_ID AND ' ;
     if pos('%',cmbModel.Text)<0 then
           QryTemp1.CommandText := QryTemp1.CommandText + ' C.MODEL_NAME ='''+cmbModel.Text+''' '
     else
           QryTemp1.CommandText := QryTemp1.CommandText + ' C.MODEL_NAME  like '''+cmbModel.Text+''' ' ;


     QryTemp1.CommandText:=QryTemp1.CommandText +  ' AND A.Work_Order like :WO '  ;

    {
    if  g_processid <> '' then
    begin
        QryTemp1.CommandText:=QryTemp1.CommandText +  ' AND a.process_id= '''+g_processid+''' ';
    end;
    }
    QryTemp1.CommandText:=QryTemp1.CommandText + ' ) WHERE  DATETIME > =:STARTDATE AND DATETIME < :ENDDATE  order by PDLINE_NAME ' ;


    QryTemp1.Params.ParamByName('STARTDATE').AsString := START_DATE;
    QryTemp1.Params.ParamByName('ENDDATE').AsString := END_DATE;
    QryTemp1.Params.ParamByName('WO').AsString := edtWo.Text+'%';
    QryTemp1.Open;
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
                         ' from SAJET.G_SN_COUNT where WORK_ORDER  LIKE :WO )  C ,sajet.sys_part d ,sajet.sys_Part e,sajet.sys_model f' +
                         ' ,sajet.sys_pdline g  where  c.pdline_ID=g.PDLINE_ID and              '+
                         ' C.DateTime >=:StartTime and C.DateTime <:endTime   AND '+

                         ' c.model_ID =d.Part_ID and C.Model_ID = E.Part_ID and e.Model_ID= f.Model_ID and C.PROCESS_ID = B.PROCESS_ID and ';
     if Pos('%',cmbModel.Text)>=0 then
            QryTemp1.CommandText:=  QryTemp1.CommandText+' f.MOdel_Name like '''+cmbModel.Text+''''
     else
          QryTemp1.CommandText:=  QryTemp1.CommandText+' f.MOdel_Name ='''+cmbModel.Text+'''';

    QryTemp1.CommandText:=  QryTemp1.CommandText+ '  GROUP BY B.PROCESS_NAME, B.PROCESS_CODE   ORDER BY B.PROCESS_CODE ';

    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sEndTime;
    QryTemp1.Params.ParamByName('WO').AsString := edtWo.Text+'%';
    QryTemp1.Open;
end;

function TfDetail.QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'WO',ptInput);
    QryTemp1.CommandText:= 'select Process_NAME ,Process_Code, DEFECT_CODE ,Defect_desc,count(C_SN) as Count  '+
                           ' from  '+
                           ' (   select Serial_number,PROCESS_NAME,Process_Code,defect_code,Defect_desc,c_SN from  '+
                           '     ( '+
                           '      select   a.Serial_number,B.PROCESS_NAME ,b.Process_Code,C.defect_code, '+
                           '     c.Defect_desc,1 as C_SN   from '+
                           '     sajet.g_SN_defect_first a,sajet.SYS_PROCESS b,sajet.sys_defect c ,sajet.sys_part d , sajet.sys_Model e ,sajet.sys_pdline f '+
                           '     where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyy/mm/dd hh24:mi:ss'') '+
                           '    and a.REC_Time <to_date(:EndTime, ''yyyy/mm/dd hh24:mi:ss'')   and a.WORK_ORDER NOT LIKE ''RM%'' '+
                           '     and a.MOdel_ID=d.Part_ID and e.MOdel_ID =d.Model_ID and  a.pdline_id =f.pdline_ID and ';
    if chkRetest.Checked then
          QryTemp1.CommandText:=  QryTemp1.CommandText+'   a.ntf_time is null and ';

     if Pos('%',cmbModel.Text)>=0 then
            QryTemp1.CommandText:=  QryTemp1.CommandText+' e.MOdel_Name like '''+cmbModel.Text+''''
     else
          QryTemp1.CommandText:=  QryTemp1.CommandText+' e.MOdel_Name ='''+cmbModel.Text+'''';

     QryTemp1.CommandText:=  QryTemp1.CommandText+' and  a.WORK_ORDER  like :WO';
     QryTemp1.CommandText:=  QryTemp1.CommandText+' group by  B.PROCESS_NAME ,b.Process_Code, C.defect_Code, c.Defect_desc ,a. Serial_number '+
                           '    )'+
                           ' )  '+
                           ' group by Process_NAME,Process_Code,DEFECT_CODE ,Defect_desc '+
                           ' order  by Process_Code, Count desc ' ;
    QryTemp1.Params.ParamByName('StartTime').AsString := sDStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sDEndTime;
    QryTemp1.Params.ParamByName('WO').AsString := edtWo.Text+'%';
    QryTemp1.Open;
end;


function TfDetail.QueryDefectByPdline(QryTemp1:TClientDataset;sStart:String;sEnd:String;PDLine:string):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'PDLINE',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Process',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'WO',ptInput);
    QryTemp1.CommandText:= 'select  C.defect_Code, c.Defect_desc,COUNT(*) as DEFECT_QTY   '+
                           ' from           '+
                           ' sajet.g_SN_defect_first a,sajet.SYS_PROCESS b,sajet.sys_defect c ,sajet.sys_part d,sajet.sys_Model e ,sajet.sys_pdline H '+
                           ' where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyy/mm/dd hh24:mi:ss'') '+
                           ' and a.REC_Time <to_date(:EndTime, ''yyyy/mm/dd hh24:mi:ss'')  AND B.PROCESS_NAME =:PROCESS  '+
                           ' and a.pdline_id =H.pdline_id and H.PDLINE_NAME =:pdline ' +
                           ' and a.WORK_ORDER   LIKE :WO and a.MOdel_ID=d.Part_ID and e.MOdel_ID =d.Model_ID AND ';
    if chkReTest.Checked then
         QryTemp1.CommandText:= QryTemp1.CommandText +  '  a.ntf_time is null and ' ;
    if pos('%',cmbModel.Text)<0 then
        QryTemp1.CommandText:= QryTemp1.CommandText + ' E.Model_Name = '''+cmbModel.Text +''''
    else
        QryTemp1.CommandText:= QryTemp1.CommandText + ' E.Model_Name Like '''+cmbModel.Text +'''' ;

    QryTemp1.CommandText:= QryTemp1.CommandText + ' group by  C.defect_Code , c.Defect_desc order by DEFECT_QTY DESC' ;
    QryTemp1.Params.ParamByName('StartTime').AsString := sStart;
    QryTemp1.Params.ParamByName('EndTime').AsString := sEnd;
    QryTemp1.Params.ParamByName('PDLINE').AsString :=pdline;
    QryTemp1.Params.ParamByName('Process').AsString :=cmbProcess.Text;
    QryTemp1.Params.ParamByName('WO').AsString := edtWo.Text+'%';
    QryTemp1.Open;

end;

function TfDetail.QueryDefectItemByPdline(QryTemp1:TClientDataset;sStart:String;sEnd:String;PDLine:string;Defect_Code:string):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'PDLINE',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Process',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Defect',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'WO',ptInput);
    QryTemp1.CommandText:= ' SELECT REC_HOUR,COUNT(*) DEFECT_QTY FROM(select TO_CHAR(REC_TIME ,''HH24'') REC_HOUR  from '+
                           ' sajet.g_SN_defect_first a,sajet.SYS_PROCESS b,sajet.sys_defect c ,sajet.sys_part d,sajet.sys_Model e ,sajet.sys_pdline H '+
                           ' where  A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyy/mm/dd hh24:mi:ss'') '+
                           ' and a.REC_Time <to_date(:EndTime, ''yyyy/mm/dd hh24:mi:ss'')  AND B.PROCESS_NAME =:PROCESS  '+
                           ' and a.pdline_id =H.pdline_id and H.PDLINE_NAME =:pdline ';
    if chkRetest.Checked then
        QryTemp1.CommandText:=  QryTemp1.CommandText +  ' and a.ntf_time is null ';

    QryTemp1.CommandText:=  QryTemp1.CommandText + ' and a.WORK_ORDER LIKE :WO and C.DEFECT_CODE =:defect '+
                           ' and a.MOdel_ID=d.Part_ID and e.MOdel_ID =d.Model_ID and ';
    if pos('%',cmbModel.Text)<0 then
        QryTemp1.CommandText:= QryTemp1.CommandText + ' E.Model_Name = '''+cmbModel.Text +''''
    else
        QryTemp1.CommandText:= QryTemp1.CommandText + ' E.Model_Name Like '''+cmbModel.Text +'''' ;

    QryTemp1.CommandText:= QryTemp1.CommandText + ' ) group by REC_HOUR  ' ;
    QryTemp1.Params.ParamByName('StartTime').AsString := sStart;
    QryTemp1.Params.ParamByName('EndTime').AsString := sEnd;
    QryTemp1.Params.ParamByName('PDLINE').AsString :=pdline;
    QryTemp1.Params.ParamByName('Process').AsString :=cmbProcess.Text;
    QryTemp1.Params.ParamByName('Defect').AsString :=Defect_Code;
    QryTemp1.Params.ParamByName('WO').AsString := edtWo.Text+'%';
    QryTemp1.Open;

end;

function TfDetail.QueryOutputByPDLine( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String;PDLine:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'PROCESS',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'PDLINE',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'WO',ptInput);
    if chkReTest.Checked then
    QryTemp1.CommandText:=' SELECT DECODE((SUM(C.FAIL_QTY-C.NTF_QTY)), NULL, 0, (SUM(C.FAIL_QTY-C.NTF_QTY))) NG_QTY, '+
                          ' DECODE((SUM(C.PASS_QTY+C.NTF_QTY)), NULL, 0, (SUM(C.PASS_QTY+C.NTF_QTY))) PASS_QTY, '
    else
     QryTemp1.CommandText:=' SELECT DECODE((SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.FAIL_QTY))) NG_QTY, '+
                          ' DECODE((SUM(C.PASS_QTY)), NULL, 0, (SUM(C.PASS_QTY))) PASS_QTY, ';
     QryTemp1.CommandText :=  QryTemp1.CommandText +
                          ' DECODE((SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY))) TOTAL_QTY  '+
                          ' FROM   sajet.sys_pdline a  ,SAJET.SYS_PROCESS B ,  ' +
                          ' (select WORK_ORDER,MODEL_ID,PDLINE_ID,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REFAIL_QTY,OUTPUT_QTY,NTF_QTY,Repair_qty,'+
                          ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime  '+
                          ' from SAJET.G_SN_COUNT ) C ,sajet.sys_part d,sajet.sys_model e ,SAJET.SYS_PDLINE F' +
                          ' WHERE   C.DateTime >=:StartTime and C.DateTime <:endTime   AND a.pdline_ID =c.PDLINE_ID and C.WORK_ORDER  Like :WO AND '+
                          ' c.model_ID =d.Part_ID and d.Model_ID = e.Model_ID and ';
    if pos('%',cmbModel.Text)<0 then
        QryTemp1.CommandText:= QryTemp1.CommandText + ' E.Model_Name = '''+cmbModel.Text +''''
    else
        QryTemp1.CommandText:= QryTemp1.CommandText + ' E.Model_Name Like '''+cmbModel.Text +'''' ;



    QryTemp1.CommandText:= QryTemp1.CommandText + '  and A.PDLINE_ID=F.PDLINE_ID AND F.PDLINE_NAME =:PDLINE AND'+
                         ' C.PROCESS_ID = B.PROCESS_ID AND B.PROCESS_NAME =:PROCESS GROUP BY a.pdLine_NAME  ORDER BY B.PROCESS_CODE ';

    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sEndTime;
    QryTemp1.Params.ParamByName('PROCESS').AsString := cmbProcess.Text;
    QryTemp1.Params.ParamByName('PDLINE').AsString :=PDLINE;
    QryTemp1.Params.ParamByName('WO').AsString := edtWo.Text+'%';
    QryTemp1.Open;
end;

procedure TfDetail.sBtnExportClick(Sender: TObject);
var
     strNTF,Defect_Code,rec_Hour :string;
     strTitle,strFPY,strPDline,strPDLineFrist,strRepass,strTotal,strDefectName,strDefect_QTY,strDefect_Desc,strFailAll :string;
    i,j,K,m,LineCount,UsedRow,UsedCount,defect_count,count,iHourCount:integer;
    ExcelApp: Variant;
begin

    if LV_Role.Items.Count =0 then
    begin
        MessageDlg('NO SELECT PDLINE',mtError,[mbok],0);
        exit;
    end;

    if SaveDialog1.Execute then
    begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);

        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'PDLINE Yield Report.xltx');
        ExcelApp.WorkSheets[1].Activate;
        if pos('%', cmbModel.Text)>0 then
        begin
            ExcelApp.WorkSheets[1].Name :=   Copy(cmbModel.Text,1,length(cmbModel.Text)-1) ;
            ExcelApp.Cells[1,1].Value :=  Copy(cmbModel.Text,1,length(cmbModel.Text)-1) +' Yield Report';
        end
        else
        begin
            ExcelApp.WorkSheets[1].Name :=   cmbModel.Text;
            ExcelApp.Cells[1,1].Value := cmbModel.Text +' Yield Report';
        end;

        ExcelApp.Cells[2,2].Value := 'Start Time:'+sDStartTime +'    End Time:'+sDEndTime;
        if not chkRetest.Checked then
             ExcelApp.Cells[3,6].Value  :='ª½³q²v';
        iHourCount :=  Round((StrToDateTime(sDEndTime)- StrToDateTime(sDStartTime))*24);
        if iHourCount>24 then iHourCOunt :=24;
        for i:=0 to iHourCount -1 do
             ExcelApp.Cells[4,10+i].Value := FormatDateTime('HH',(StrToDateTime(sDStartTime)+i/24)) ;
        UsedRow :=5;
        For I:=0 to LV_Role.Items.Count-1 do begin
              QueryOutPutbyPdline(Qrytemp,sStartTime,SEndTime,LV_Role.Items[i].Caption);
              ExcelApp.Cells[UsedRow,1].Value :=cmbModel.Text;
              ExcelApp.Cells[UsedRow,2].Value :=   LV_Role.Items[i].Caption ;
              ExcelApp.Cells[UsedRow,3].Value :=  QryTemp.FieldByName('TOTAL_QTY').AsString ;
              ExcelApp.Cells[UsedRow,4].Value :=  QryTemp.FieldByName('PASS_QTY').AsString ;
              ExcelApp.Cells[UsedRow,5].Value :=  QryTemp.FieldByName('NG_QTY').AsString ;
              ExcelApp.Cells[UsedRow,6].Value :=  '=D'+IntToStr(UsedRow)+'/C'+IntToStr(UsedRow);
              QueryDefectByPdline(QryDefect,sDStartTime,sDEndTime,LV_Role.Items[i].Caption);
              if QryDefect.IsEmpty then
                       UsedRow :=UsedRow +1
              else begin
                    QryDefect.First;
                    for j:=0 to QryDefect.RecordCount-1 do
                    begin
                        Defect_Code :=    QryDefect.FieldByName('Defect_Code').AsString ;
                        ExcelApp.Cells[UsedRow+j,7].Value :=   QryDefect.FieldByName('Defect_Desc').AsString ;
                        ExcelApp.Cells[UsedRow+j,8].Value :=   QryDefect.FieldByName('Defect_Qty').AsString ;
                        ExcelApp.Cells[UsedRow+j,9].Value :=   '=H'+IntToStr(UsedRow+j)+'/C'+IntToStr(UsedRow);
                        ExcelApp.ActiveSheet.Range['B'+IntToStr(UsedRow)+':B'+IntToStr(UsedRow+j)].Merge;
                        ExcelApp.ActiveSheet.Range['C'+IntToStr(UsedRow)+':C'+IntToStr(UsedRow+j)].Merge;
                        ExcelApp.ActiveSheet.Range['D'+IntToStr(UsedRow)+':D'+IntToStr(UsedRow+j)].Merge;
                        ExcelApp.ActiveSheet.Range['E'+IntToStr(UsedRow)+':E'+IntToStr(UsedRow+j)].Merge;
                        ExcelApp.ActiveSheet.Range['F'+IntToStr(UsedRow)+':F'+IntToStr(UsedRow+j)].Merge;
                        QueryDefectItemByPdline(QryDefectDetail,sDStartTime,sDEndTime,LV_Role.Items[i].Caption,Defect_Code);
                        QryDefectDetail.first;
                        for K:=0 to QryDefectDetail.RecordCount-1 do
                        begin
                            rec_Hour := QryDefectDetail.FieldByName('REC_HOUR').AsString;
                            for m:=0 to  iHourCount-1 do
                            begin
                                if  StrToInt( ExcelApp.Cells[4,10+m].Value) = StrToInt(rec_Hour) then
                                begin
                                          ExcelApp.Cells[UsedRow+j,10+m].Value := QryDefectDetail.FieldByName('Defect_Qty').AsString;
                                end;

                            end;
                            QryDefectDetail.Next;
                        end;
                        QryDefect.Next;
                    end;
                    UsedRow :=UsedRow + QryDefect.RecordCount;
              end;
        end;

        ExcelApp.ActiveSheet.Range['A'+IntToStr(5)+':A'+IntToStr(UsedRow-1)].Merge;
        ExcelApp.ActiveSheet.Range['A5:AG'+IntToStr(UsedRow-1)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A5:AG'+IntToStr(UsedRow-1)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A5:AG'+IntToStr(UsedRow-1)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A5:AG'+IntToStr(UsedRow-1)].Borders[4].Weight := 2;
        ExcelApp.ActiveSheet.Range['A5:AG'+IntToStr(UsedRow-1)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A5:AG'+IntToStr(UsedRow-1)].Font.Name :='Tohama';
        ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
        ExcelApp.Quit;
        MessageDlg('Save OK',mtConfirmation,[mbyes],0);
        QueryDefect(QryDefect,sDStartTime,sDEndTime);
    end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var i:integer;
begin

    cmbProcess.Style :=csDropDownList;
    ComboBox1.Style :=csDropDownList;
    ComboBox2.Style :=csDropDownList;
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

end;

procedure TfDetail.SpeedButton1Click(Sender: TObject);
var strstartdate,strenddate:string;
Index,j:integer;
begin
    if cmbModel.Text ='' then
   begin
      MessageDlg('Please select one Model name!', mtInformation, [mbOk], 0);
      exit;
   end;

   strstartdate:=FormatDateTime( 'YYYYMMDD',DateTimePicker1.Date);
   strenddate :=FormatDateTime( 'YYYYMMDD',DateTimePicker2.Date);


   FrmList:=TFrmList.Create(nil);
   FrmList.PL_Left.Caption:=' Line List' ;
   FrmList.PL_Right.Caption:='Choosen Line List' ;

   QueryLine(QryTemp,strstartdate+Format('%.2d',[StrToInt(ComboBox1.Text)]),strenddate+Format('%.2d',[StrToInt(ComboBox2.Text)]));
   if not QryTemp.IsEmpty then begin
       QryTemp.First;
       for j:=0  to QryTemp.RecordCount-1 do begin
            FrmList.LB_Left.Items.Add(QryTemp.fieldbyName('PDLine_Name').asString);
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
          if FrmList.LB_Right.Items.Count<>0 then
             For Index:=0 to FrmList.LB_Right.Items.Count-1 do
                 Lv_ROle.Items.Add().Caption:=FrmList.LB_Right.Items[Index];
        End;
   Finally
        FrmList.Free;
   End;
end;

procedure TfDetail.cmbModelChange(Sender: TObject);
begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'STARTDATE',ptInput);
    QryTemp.Params.CreateParam(ftstring,'ENDDATE',ptInput);
    QryTemp.Params.CreateParam(ftstring,'WO',ptInput);
    QryTemp.CommandText := ' SELECT distinct PROCESS_NAME  ' +
                            ' FROM ( SELECT E.PROCESS_NAME,A.output_qty,TO_NUMBER(TO_CHAR(A.WORK_DATE)||TRIM(TO_CHAR(A.WORK_TIME,''00''))) DATETIME ' +
                            ' FROM SAJET.G_SN_COUNT  A,SAJET.SYS_PART B, SAJET.SYS_MODEL C ,SAJET.SYS_PROCESS E ' +
                            ' WHERE A.MODEL_ID=B.PART_ID AND B.MODEL_ID=C.MODEL_ID AND A.PROCESS_ID=E.PROCESS_ID ' +
                            ' AND A.output_qty <> 0 AND A.MODEL_ID=B.PART_ID AND B.MODEL_ID =C.MODEL_ID AND ' ;
     if pos('%',cmbModel.Text)<0 then
           QryTemp.CommandText := QryTemp.CommandText + ' C.MODEL_NAME ='''+cmbModel.Text+''' '
     else
           QryTemp.CommandText := QryTemp.CommandText + ' C.MODEL_NAME  like '''+cmbModel.Text+''' ' ;


     QryTemp.CommandText:=QryTemp.CommandText +  ' AND A.Work_Order like :WO '  ;


    QryTemp.CommandText:=QryTemp.CommandText + ' ) WHERE  DATETIME > =:STARTDATE AND DATETIME < :ENDDATE ORDER BY  PROCESS_NAME ' ;


    QryTemp.Params.ParamByName('STARTDATE').AsString := FormatDateTime('YYYYYMMDD',DateTimePicker1.Date)+ Format('%.2d',[StrToInt(ComboBox1.Text)]);
    QryTemp.Params.ParamByName('ENDDATE').AsString := FormatDateTime('YYYYYMMDD',DateTimePicker2.Date)+ Format('%.2d',[StrToInt(ComboBox2.Text)]);
    QryTemp.Params.ParamByName('WO').AsString := edtWo.Text +'%' ;
    QryTemp.Open;

    if QryTemp.IsEmpty then exit;
    QryTemp.First;

    cmbProcess.Items.Clear;
    while not Qrytemp.Eof do begin
      cmbProcess.Items.Add( QryTemp.fieldbyName('PROCESS_NAME').AsString);
      QryTemp.Next;
    end;


end;

end.
