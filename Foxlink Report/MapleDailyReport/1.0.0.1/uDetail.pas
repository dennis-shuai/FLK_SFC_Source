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
    function QueryOutput( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function QueryOutputByPDLine( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
  end;

var
  fDetail:TfDetail;
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

    QueryOutput(QryData, sStartTime, sEndTime);
    QueryDefect(QryDefect,sDStartTime,sDEndTime);
    DbGrid1.Columns[0].Width :=120;
    DbGrid1.Columns[1].Width :=0;
    //DbGrid1.Columns[2].Width :=80;
   // DbGrid1.Columns[3].Width :=80;

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
    //QryTemp1.Params.CreateParam(ftstring,'Model_NAme',ptInput);
    QryTemp1.CommandText:=' select B.PROCESS_NAME, B.PROCESS_CODE, '+
                         ' DECODE((SUM(C.PASS_QTY)), NULL, 0, (SUM(C.PASS_QTY))) as "FPY_QTY" , '+
                         ' round(  NVL(SUM(C.PASS_QTY),0)  /  NVL(SUM(C.PASS_QTY+C.FAIL_QTY),0)  *100,2)  as  "FPY(%)" , '+
                         ' DECODE((SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.FAIL_QTY))) as "FAIL", '+
                         ' DECODE((SUM(C.OUTPUT_QTY)), NULL, 0, (SUM(C.OUTPUT_QTY))) "羆玻(蝴珇)", '+
                         ' DECODE((SUM(C.NTF_QTY)), NULL, 0, (SUM(C.NTF_QTY))) "代OK计", '+
                         ' DECODE((SUM(C.REPAIR_QTY)), NULL, 0, (SUM(C.REPAIR_QTY))) "蝴计", ' +
                         ' round( (SUM(C.PASS_QTY+ C.NTF_QTY+C.REPAIR_QTY)  / SUM(C.PASS_QTY+ C.FAIL_QTY ))*100,2) as  "蝴▆瞯" , '+
                         ' DECODE((SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY))) as "羆щ" , '+
                         ' DECODE((SUM(C.PASS_QTY) +SUM(C.NTF_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.NTF_QTY))) as "狡代玻" , '+
                         ' round( (SUM(C.PASS_QTY+C.NTF_QTY)/SUM(C.PASS_QTY+C.FAIL_QTY))*100,2) as "狡代▆瞯"   '+
                         ' FROM   SAJET.SYS_PROCESS B ,  ' +
                         ' (select WORK_ORDER,MODEL_ID,PDLINE_ID,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REPAIR_QTY,OUTPUT_QTY,NTF_QTY,to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime  '+
                         ' from SAJET.G_SN_COUNT where WORK_ORDER NOT LIKE ''RM%'' and PASS_QTY+FAIL_QTY <> 0 )  C ,sajet.sys_part d ,sajet.sys_Part e,sajet.sys_model f' +
                         ' WHERE   C.DateTime >=:StartTime and C.DateTime <:endTime   AND '+
                         ' c.model_ID =d.Part_ID and C.Model_ID = E.Part_ID and e.Model_ID= f.Model_ID and f.MOdel_Name like ''368%'' and'+
                         ' C.PROCESS_ID = B.PROCESS_ID GROUP BY B.PROCESS_NAME, B.PROCESS_CODE ORDER BY B.PROCESS_CODE ';

    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sEndTime;
    //QryTemp1.Params.ParamByName('Model_Name').AsString :=   cmbModel.Text;
    QryTemp1.Open;
end;

function TfDetail.QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
   // QryTemp1.Params.CreateParam(ftstring,'Model_NAme',ptInput);
    QryTemp1.CommandText:= 'select Process_NAME , DEFECT_CODE ,Defect_desc,count(C_SN) as Count  ' +
                           ' from '    +
                           ' (    '    +
                                 '  ( select   a.Serial_number,B.PROCESS_NAME , C.defect_Code, c.Defect_desc,1 as C_SN   '+
                                         ' from           '+
                                         ' sajet.g_SN_defect_first a,sajet.SYS_PROCESS b,sajet.sys_defect c ,sajet.sys_part d,sajet.sys_Model e   '+
                                         ' where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyy/mm/dd hh24:mi:ss'') '+
                                         ' and a.REC_Time <to_date(:EndTime, ''yyyy/mm/dd hh24:mi:ss'')   and c.defect_Code not like ''SFR%''   ' +
                                         ' and a.ntf_time is null  and a.WORK_ORDER NOT LIKE ''RM%'' and a.MOdel_ID=d.Part_ID and e.MOdel_ID =d.Model_ID and e.Model_Name  like ''368%'' '+
                                         ' group by  B.PROCESS_NAME , C.defect_Code , c.Defect_desc,a. Serial_number  )  '+
                                   ' union           '+
                                         ' ( select   a.Serial_number,B.PROCESS_NAME , ''SFR'' as Defect_Code, c.Defect_desc,1 as C_SN   '+
                                         ' from                   '+
                                         ' sajet.g_SN_defect_first a,sajet.SYS_PROCESS b,sajet.sys_defect c ,sajet.sys_part d , sajet.sys_Model e  '+
                                         ' where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyy/mm/dd hh24:mi:ss'')  '+
                                         ' and a.REC_Time <to_date(:EndTime, ''yyyy/mm/dd hh24:mi:ss'')   and c.defect_Code  like ''SFR%''  and a.ntf_time is null and a.WORK_ORDER NOT LIKE ''RM%'' '+
                                         ' and a.MOdel_ID=d.Part_ID and e.MOdel_ID =d.Model_ID and e.Model_Name like ''368%'' '+
                                         ' group by  B.PROCESS_NAME , C.defect_Code, c.Defect_desc ,a. Serial_number )  '+
                           ' )     '+
                           ' group by Process_NAME,DEFECT_CODE ,Defect_desc ' +
                           ' order  by process_name, Count desc ' ;
    QryTemp1.Params.ParamByName('StartTime').AsString := sDStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sDEndTime;
   // QryTemp1.Params.ParamByName('Model_Name').AsString :=   cmbModel.Text;
    QryTemp1.Open;

end;

function TfDetail.QueryOutputByPDLine( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
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
                         ' c.model_ID =d.Part_ID and d.Model_ID = e.Model_ID and e.Model_Name =:Model   and '+
                         ' C.PROCESS_ID = B.PROCESS_ID  GROUP BY a.pdLine_NAME,B.PROCESS_NAME, B.PROCESS_CODE ORDER BY B.PROCESS_CODE ';
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sEndTime;
    QryTemp1.Params.ParamByName('Model').AsString := cmbModel.Text;
    QryTemp1.Open;
end;

procedure TfDetail.sBtnExportClick(Sender: TObject);
var
     strNTF :string;
     strTitle,strFPY,strPDline,strPDLineFrist,strRepass,strTotal,strDefectName,strDefect_QTY,strDefect_Desc :string;
    i,j,LineCount,UsedRow,UsedCount,defect_count,count:integer;
    ExcelApp: Variant;
begin
    if SaveDialog1.Execute then begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);

        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'Maple Daily Report.xltx');
        ExcelApp.WorkSheets[1].Activate;

        ExcelApp.Cells[2,3].Value := sDStartTime;
        ExcelApp.Cells[2,5].Value := sDEndTime;

        if not QryData.IsEmpty then
        begin
             QryData.First;
             for  i:=0 to QryData.RecordCount-1  do
             begin

                  strTitle :=QryData.FieldByName('PROCESS_NAME').AsString ;
                  strFPY :=  QryData.FieldByName('FPY_QTY').AsString;
                  strTotal :=  QryData.FieldByName('羆щ').AsString;
                  strRepass :=  QryData.FieldByName('代OK计').AsString;
                  if  strTitle= 'SMT_INPUT_T' then  begin
                     ExcelApp.Cells[4,3].Value := strTotal;
                     ExcelApp.Cells[4,4].Value := strFPY;
                     ExcelApp.Cells[4,5].Value := StrToInt(strFPY)/StrToInt(strTotal);
                     ExcelApp.Cells[4,6].Value := strRepass;
                     ExcelApp.Cells[4,7].Value :=  (StrToInt(strRepass)+ StrToInt(strFPY))/StrToInt(strTotal);;
                   end;

                  if  strTitle = 'KS_PACK' then begin
                     ExcelApp.Cells[5,3].Value := strTotal;
                     ExcelApp.Cells[5,4].Value := strFPY;
                     ExcelApp.Cells[5,5].Value := StrToInt(strFPY)/StrToInt(strTotal);
                     ExcelApp.Cells[5,6].Value := strRepass;
                     ExcelApp.Cells[5,7].Value :=  (StrToInt(strRepass)+ StrToInt(strFPY))/StrToInt(strTotal);;
                   end;

                  if  strTitle = 'DEPANEL' then  begin
                     ExcelApp.Cells[6,3].Value := strTotal;
                     ExcelApp.Cells[6,4].Value := strFPY;
                     ExcelApp.Cells[6,5].Value := StrToInt(strFPY)/StrToInt(strTotal);
                     ExcelApp.Cells[6,6].Value := strRepass;
                     ExcelApp.Cells[6,7].Value :=  (StrToInt(strRepass)+ StrToInt(strFPY))/StrToInt(strTotal);;
                   end;
                   if  strTitle = 'DIE BOND' then  begin
                     ExcelApp.Cells[7,3].Value := strTotal;
                     ExcelApp.Cells[7,4].Value := strFPY;
                     ExcelApp.Cells[7,5].Value := StrToInt(strFPY)/StrToInt(strTotal);
                     ExcelApp.Cells[7,6].Value := strRepass;
                     ExcelApp.Cells[7,7].Value :=  (StrToInt(strRepass)+ StrToInt(strFPY))/StrToInt(strTotal);;
                   end;

                   if  strTitle = 'HODLE MOUNT' then  begin
                     ExcelApp.Cells[8,3].Value := strTotal;
                     ExcelApp.Cells[8,4].Value := strFPY;
                     ExcelApp.Cells[8,5].Value := StrToInt(strFPY)/StrToInt(strTotal);
                     ExcelApp.Cells[8,6].Value := strRepass;
                     ExcelApp.Cells[8,7].Value :=  (StrToInt(strRepass)+ StrToInt(strFPY))/StrToInt(strTotal);;
                   end;

                    if  strTitle = 'AOO' then  begin
                     ExcelApp.Cells[9,3].Value := strTotal;
                     ExcelApp.Cells[9,4].Value := strFPY;
                     ExcelApp.Cells[9,5].Value := StrToInt(strFPY)/StrToInt(strTotal);
                     ExcelApp.Cells[9,6].Value := strRepass;
                     ExcelApp.Cells[9,7].Value :=  (StrToInt(strRepass)+ StrToInt(strFPY))/StrToInt(strTotal);;
                   end;

                   if  strTitle = 'FF' then  begin
                     ExcelApp.Cells[10,3].Value := strTotal;
                     ExcelApp.Cells[10,4].Value := strFPY;
                     ExcelApp.Cells[10,5].Value := StrToInt(strFPY)/StrToInt(strTotal);
                     ExcelApp.Cells[10,6].Value := strRepass;
                     ExcelApp.Cells[10,7].Value :=  (StrToInt(strRepass)+ StrToInt(strFPY))/StrToInt(strTotal);;
                   end;

                   if  strTitle = 'FQC' then  begin
                     ExcelApp.Cells[11,3].Value := strTotal;
                     ExcelApp.Cells[11,4].Value := (StrToInt(strRepass)+ StrToInt(strFPY));
                     ExcelApp.Cells[11,5].Value := (StrToInt(strRepass)+ StrToInt(strFPY))/StrToInt(strTotal);
                     ExcelApp.Cells[11,6].Value := 0;
                     ExcelApp.Cells[11,7].Value :=  (StrToInt(strRepass)+ StrToInt(strFPY))/StrToInt(strTotal);;
                   end;

                   if  strTitle = 'CM-PACK-CARTON' then  begin
                     ExcelApp.Cells[12,3].Value := strTotal;
                     ExcelApp.Cells[12,4].Value := strFPY;
                     ExcelApp.Cells[12,5].Value := StrToInt(strFPY)/StrToInt(strTotal);
                     ExcelApp.Cells[12,6].Value := strRepass;
                     ExcelApp.Cells[12,7].Value :=  (StrToInt(strRepass)+ StrToInt(strFPY))/StrToInt(strTotal);;
                   end;
                  QryData.Next;
           end;
        end;

        defect_count :=   QryDefect.RecordCount-1;
        count :=0;
        if not QryDefect.IsEmpty then
        begin
              QryDefect.First;
              for  i:=0 to defect_count  do
              begin
                  strTitle :=QryDefect.FieldByName('PROCESS_NAME').AsString ;
                  strDefectName :=  QryDefect.FieldByName('Defect_Code').AsString;
                  strDefect_Desc := QryDefect.FieldByName('Defect_Desc').AsString;
                  strDefect_QTY :=  QryDefect.FieldByName('Count').AsString;
                   if strTitle<>'OQC' then begin
                      ExcelApp.Cells[19+i,1].Value := strTitle;

                      ExcelApp.Cells[19+i,3].Value := strDefectName;
                     // ExcelApp.Cells[11+i,2].Value := strtoint(strDefect_QTY)/StrtoInt(ExcelApp.Cells[4,2]);
                      ExcelApp.Cells[19+i,4].Value := strDefect_QTY;
                     if strTitle='AOO' then
                         ExcelApp.Cells[19+i,2].Value := ExcelApp.Cells[19+i,4].Value/ExcelApp.Cells[9,3].Value ;
                     if strTitle='FF' then
                         ExcelApp.Cells[19+i,2].Value := ExcelApp.Cells[19+i,4].Value/ExcelApp.Cells[10,3].Value ;
                     if strTitle='FQC' then
                         ExcelApp.Cells[19+i,2].Value := ExcelApp.Cells[19+i,4].Value/ExcelApp.Cells[11,3].Value ;
                     ExcelApp.Cells[19+i,5].Value := strDefect_Desc;
                     count :=count +1;
                   end  ;
                  QryDefect.Next;
              end;
        end;

       ExcelApp.ActiveSheet.Range['A19:F'+IntToStr(count+19)].Borders[1].Weight := 2;
       ExcelApp.ActiveSheet.Range['A19:F'+IntToStr(count+19)].Borders[2].Weight := 2;
       ExcelApp.ActiveSheet.Range['A19:F'+IntToStr(count+19)].Borders[3].Weight := 2;
       ExcelApp.ActiveSheet.Range['A19:F'+IntToStr(count+19)].Borders[4].Weight := 2;
       ExcelApp.ActiveSheet.Range['A19:F'+IntToStr(count+19)].HorizontalAlignment :=3;



        ExcelApp.WorkSheets[2].Activate;
        QueryOutputByPDLine( QryTemp,sStartTime,sEndTime);
        LineCount :=0;

        QryTemp.First;

        // strPDLine := strPDLineFrist;
        for i:= 0 to QryTemp.RecordCount-1 do  begin
            strPDLine :=  QryTemp.FieldByName('PDLine_NAME').AsString ;
            strTitle :=  QryTemp.FieldByName('PROCESS_NAME').AsString ;

          for j:=1 to 30 do begin
               if  strPDLine = ExcelApp.Cells[2,j].Value then
               begin
                    LineCount :=j;
               end;

          end;

          strTitle :=QryTemp.FieldByName('PROCESS_NAME').AsString ;
          strFPY :=  QryTemp.FieldByName('FPY_QTY').AsString;
          strNTF :=  QryTemp.FieldByName('代OK计').AsString;
          strTotal :=  QryTemp.FieldByName('羆щ').AsString;

          if  strTitle= 'AOO' then  begin
              if strTotal='0' then begin
                 ExcelApp.Cells[3,LineCount].Value :='';
              end;
              ExcelApp.Cells[3,LineCount].Value := (strtoInt(strFPY)+strtoInt(strNTF))/strtoInt(strTotal);
          end;

          if  strTitle = 'FF' then begin
              if strTotal='0' then begin
                 ExcelApp.Cells[4,LineCount].Value :='';
              end
              else
                ExcelApp.Cells[4,LineCount].Value := (strtoInt(strFPY)+strtoInt(strNTF))/strtoInt(strTotal);
          end;

          if  strTitle = 'FQC' then  begin
              if strTotal='0' then begin
                 ExcelApp.Cells[5,LineCount].Value :='';
              end else
              ExcelApp.Cells[5,LineCount].Value := (strtoInt(strFPY)+strtoInt(strNTF))/strtoInt(strTotal);
          end;
          QryTemp.Next;
        end;


        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
        ExcelApp.Quit;
        MessageDlg('Save OK',mtConfirmation,[mbyes],0);

    end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var i:integer;
begin
    DateTimePicker1.Date :=  Now;
    DateTimePicker2.Date :=  tomorrow;
    {
    qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Commandtext := 'select distinct (model_Name) MOdel from sajet.sys_model ';
    qrytemp.Open;
    qrytemp.First;
    for i:=0 to qrytemp.recordcount-1 do begin
       cmbModel.Items.Add(qrytemp.fieldbyname('model').asstring) ;
       qrytemp.Next;
    end;
    }
    cmbModel.Text := 'Maple';
end;

end.
