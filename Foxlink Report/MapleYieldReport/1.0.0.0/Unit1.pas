unit Unit1;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids;

type
  TForm1 = class(TForm)
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
    function QueryOutputByPDLine( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function QueryOutput( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String;Process_Name:String):boolean;

  end;

var
  Form1: TForm1;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit;

procedure TForm1.sbtnQueryClick(Sender: TObject);
var
    sStartTime,sEndTime ,swStartTime,swEndTime,sDStartTime,sDEndTime,sNStartTime,sNEndTime:string;
begin
    sStartTime := FormatDateTime('yyyymmdd',DateTimePicker1.Date)+'08';
    sEndTime := FormatDateTime('yyyymmdd',DateTimePicker1.Date+1)+'08';

    QueryOutput(QryData, sStartTime, sEndTime);

end;

function TForm1.QueryOutputByPDLine( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    //QryTemp1.Params.CreateParam(ftstring,'Model',ptInput);
    QryTemp1.CommandText:=' select  a.pdLine_NAME,B.PROCESS_NAME, B.PROCESS_CODE, '+
                         ' DECODE((SUM(C.PASS_QTY)), NULL, 0, (SUM(C.PASS_QTY))) FPY_QTY,  '+
                         ' DECODE((SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.FAIL_QTY))) FAIL_QTY, '+
                         ' DECODE((SUM(C.OUTPUT_QTY)), NULL, 0, (SUM(C.OUTPUT_QTY))) PASS_QTY, ' +
                         ' DECODE((SUM(C.NTF_QTY)), NULL, 0, (SUM(C.NTF_QTY))) NTF_QTY, ' +
                         ' DECODE((SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY))) TOTAL_QTY   '+
                         ' FROM   sajet.sys_pdline a  ,SAJET.SYS_PROCESS B ,  ' +
                         ' (select WORK_ORDER,MODEL_ID,PDLINE_ID,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REFAIL_QTY,OUTPUT_QTY,NTF_QTY,to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime  '+
                         ' from SAJET.G_SN_COUNT ) C ,sajet.sys_part d ' +
                         ' WHERE   C.DateTime >=:StartTime and C.DateTime <:endTime   AND a.pdline_ID =c.PDLINE_ID and'+
                         ' c.model_ID =d.Part_ID and d.Part_no like ''7690-3368%'' and'+
                         ' C.PROCESS_ID = B.PROCESS_ID GROUP BY a.pdLine_NAME,B.PROCESS_NAME, B.PROCESS_CODE ORDER BY B.PROCESS_CODE ';
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sEndTime;
    //QryTemp1.Params.ParamByName('Model').AsString := cmbModel.Text;
    QryTemp1.Open;
end;

function TForm1.QueryOutput(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
   // QryTemp1.Params.CreateParam(ftstring,'Model',ptInput);
    QryTemp1.CommandText:=' select B.PROCESS_NAME, B.PROCESS_CODE, '+
                         ' DECODE((SUM(C.PASS_QTY)), NULL, 0, (SUM(C.PASS_QTY))) FPY_QTY , '+
                         ' DECODE((SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.FAIL_QTY))) FAIL_QTY, '+
                         ' DECODE((SUM(C.OUTPUT_QTY)), NULL, 0, (SUM(C.OUTPUT_QTY))) PASS_QTY, '+
                         ' DECODE((SUM(C.NTF_QTY)), NULL, 0, (SUM(C.NTF_QTY))) NTF_QTY, '+
                         ' DECODE((SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY))) TOTAL_QTY   '+
                         ' FROM   SAJET.SYS_PROCESS B ,  ' +
                         ' (select WORK_ORDER,MODEL_ID,PDLINE_ID,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REFAIL_QTY,OUTPUT_QTY,NTF_QTY,to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime  '+
                         ' from SAJET.G_SN_COUNT)  C ,sajet.sys_part d ' +
                         ' WHERE   C.DateTime >=:StartTime and C.DateTime <:endTime   AND '+
                         ' c.model_ID =d.Part_ID and d.Part_no like ''7690-3368%'' and'+
                         ' C.PROCESS_ID = B.PROCESS_ID GROUP BY B.PROCESS_NAME, B.PROCESS_CODE ORDER BY B.PROCESS_CODE ';
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sEndTime;
    //QryTemp1.Params.ParamByName('Model').AsString := cmbModel.Text;
    QryTemp1.Open;
end;

function TForm1.QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String;Process_Name:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Process',ptInput);
    QryTemp1.CommandText:='select Process_NAME , DEFECT_CODE ,Defect_desc,count(C_SN) as Count  ' +
                           ' from '    +
                           ' (    '    +
                           '  ( select   a.Serial_number,B.PROCESS_NAME , C.defect_Code, c.Defect_desc,1 as C_SN   '+
                           ' from           '+
                           ' sajet.g_SN_defect a,sajet.SYS_PROCESS b,sajet.sys_defect c    '+
                           ' where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyy/mm/dd hh24:mi:ss'') '+
                           ' and a.REC_Time <to_date(:EndTime, ''yyyy/mm/dd hh24:mi:ss'')   and c.defect_Code not like ''SFR%''   ' +
                           ' and B.Process_Name=:process '+
                           ' group by  B.PROCESS_NAME , C.defect_Code , c.Defect_desc,a. Serial_number  )  '+
                           ' union           '+
                           ' ( select   a.Serial_number,B.PROCESS_NAME , ''SFR'' as Defect_Code, c.Defect_desc,1 as C_SN   '+
                           ' from                   '+
                           ' sajet.g_SN_defect a,sajet.SYS_PROCESS b,sajet.sys_defect c     '+
                           ' where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyy/mm/dd hh24:mi:ss'')  '+
                           ' and a.REC_Time <to_date(:EndTime, ''yyyy/mm/dd hh24:mi:ss'')   and c.defect_Code  like ''SFR%''  and B.Process_Name=:process '+
                           ' group by  B.PROCESS_NAME , C.defect_Code, c.Defect_desc ,a. Serial_number  ) '+
                           ' )     '+
                           ' group by Process_NAME,DEFECT_CODE ,Defect_desc ' +
                           ' order  by process_name, Count desc ' ;
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sEndTime;
    QryTemp1.Params.ParamByName('Process').AsString := Process_Name;
    QryTemp1.Open;
end;

procedure TForm1.sBtnExportClick(Sender: TObject);
var
    sDStartTime,sNEndTime :string;
    swStartTime,swEndTime,strTitle,strFPY,strPDline,strPDLineFrist,strRepass,strTotal,strDefectName,strDefect_QTY,strDefect_Desc :string;
    i,j,LineCount,UsedRow,UsedCount,defect_count:integer;
    ExcelApp: Variant;
begin
    if SaveDialog1.Execute then begin
        sDStartTime := FormatDateTime('yyyymmdd',DateTimePicker1.Date)+'08';
        sNEndTime    := FormatDateTime('yyyymmdd',DateTimePicker1.Date+1)+'08';

        swStartTime := FormatDateTime('yyyy/mm/dd ',DateTimePicker1.Date)+'08:00:00';
        swEndTime    := FormatDateTime('yyyy/mm/dd ',DateTimePicker1.Date+1)+'08:00:00';

        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=true;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'\SFC Yeild Report.xlt');
        ExcelApp.WorkSheets[1].Activate;

        ExcelApp.Cells[2,2].Value := swStartTime;
        ExcelApp.Cells[2,4].Value := swEndTime;
        QueryOutput(QryTemp, sDStartTime,  sNEndTime);
        if not QryTemp.IsEmpty then
        begin
             QryTemp.First;
             for  i:=0 to QryTemp.RecordCount-1  do
             begin

                  strTitle :=QryTemp.FieldByName('PROCESS_NAME').AsString ;
                  strFPY :=  QryTemp.FieldByName('FPY_QTY').AsString;
                  strTotal :=  QryTemp.FieldByName('Total_QTY').AsString;
                  strRepass :=  QryTemp.FieldByName('NTF_QTY').AsString;
                  if  strTitle= 'AOO' then  begin
                     ExcelApp.Cells[4,2].Value := strTotal;
                     ExcelApp.Cells[4,3].Value := strFPY;
                     ExcelApp.Cells[4,4].Value := StrToInt(strFPY)/StrToInt(strTotal);
                     ExcelApp.Cells[4,5].Value := strRepass;
                     ExcelApp.Cells[4,6].Value :=  (StrToInt(strRepass)+ StrToInt(strFPY))/StrToInt(strTotal);;
                   end;

                  if  strTitle = 'FF' then begin
                     ExcelApp.Cells[5,2].Value := strTotal;
                     ExcelApp.Cells[5,3].Value := strFPY;
                     ExcelApp.Cells[5,4].Value := StrToInt(strFPY)/StrToInt(strTotal);
                     ExcelApp.Cells[5,5].Value := strRepass;
                     ExcelApp.Cells[5,6].Value :=  (StrToInt(strRepass)+ StrToInt(strFPY))/StrToInt(strTotal);;
                   end;

                  if  strTitle = 'FQC' then  begin
                     ExcelApp.Cells[6,2].Value := strTotal;
                     ExcelApp.Cells[6,3].Value := strFPY;
                     ExcelApp.Cells[6,4].Value := StrToInt(strFPY)/StrToInt(strTotal);
                     ExcelApp.Cells[6,5].Value := strRepass;
                     ExcelApp.Cells[6,6].Value :=  (StrToInt(strRepass)+ StrToInt(strFPY))/StrToInt(strTotal);;
                   end;
                  QryTemp.Next;
           end;
        end;

        QueryDefect(QryTemp,sDStartTime,sNEndTime,'AOO');

        if not QryTemp.IsEmpty then
        begin
             QryTemp.First;
             if  QryTemp.RecordCount>3 then
                  defect_count :=2
             else
                  defect_count :=   QryTemp.RecordCount-1;

              for  i:=0 to defect_count  do
              begin
                  strTitle :=QryTemp.FieldByName('PROCESS_NAME').AsString ;
                  strDefectName :=  QryTemp.FieldByName('Defect_Code').AsString;
                  strDefect_Desc := QryTemp.FieldByName('Defect_Desc').AsString;
                  strDefect_QTY :=  QryTemp.FieldByName('Count').AsString;
                  ExcelApp.Cells[11+i,3].Value := strDefectName;
                  ExcelApp.Cells[11+i,2].Value := strtoint(strDefect_QTY)/StrtoInt(ExcelApp.Cells[4,2]);
                  ExcelApp.Cells[11+i,1].Value := strDefect_QTY;
                  ExcelApp.Cells[11+i,4].Value := strDefect_Desc;
                  QryTemp.Next;
              end;
        end;

        QueryDefect(QryTemp,sDStartTime,sNEndTime,'FF');
        if not QryTemp.IsEmpty then
        begin
             QryTemp.First;
              if  QryTemp.RecordCount>3 then
                  defect_count :=2
              else
                  defect_count :=   QryTemp.RecordCount-1;
              for  i:=0 to defect_count  do
              begin
                  strTitle :=QryTemp.FieldByName('PROCESS_NAME').AsString ;
                  strDefectName :=  QryTemp.FieldByName('Defect_Code').AsString;
                  strDefect_Desc := QryTemp.FieldByName('Defect_Desc').AsString;
                  strDefect_QTY :=  QryTemp.FieldByName('Count').AsString;
                  ExcelApp.Cells[18+i,3].Value := strDefectName;
                  ExcelApp.Cells[18+i,2].Value := strtoint(strDefect_QTY)/StrtoInt(ExcelApp.Cells[5,2]);
                  ExcelApp.Cells[18+i,1].Value := strDefect_QTY;
                  ExcelApp.Cells[18+i,4].Value := strDefect_Desc;
                  QryTemp.Next;
              end;
        end;

        QueryDefect(QryTemp,sDStartTime,sNEndTime,'FQC');
        if not QryTemp.IsEmpty then
        begin
             QryTemp.First;
             if  QryTemp.RecordCount>3 then
                  defect_count :=2
             else
                  defect_count :=   QryTemp.RecordCount-1;
             for  i:=0 to defect_count  do
             begin
                  strTitle :=QryTemp.FieldByName('PROCESS_NAME').AsString ;
                  strDefectName :=  QryTemp.FieldByName('Defect_Code').AsString;
                  strDefect_Desc := QryTemp.FieldByName('Defect_Desc').AsString;
                  strDefect_QTY :=  QryTemp.FieldByName('Count').AsString;
                  ExcelApp.Cells[25+i,3].Value := strDefectName;
                  ExcelApp.Cells[25+i,2].Value := strtoint(strDefect_QTY)/StrtoInt(ExcelApp.Cells[6,2]);
                  ExcelApp.Cells[25+i,1].Value := strDefect_QTY;
                  ExcelApp.Cells[25+i,4].Value := strDefect_Desc;
                  QryTemp.Next;
             end;
        end;

        if FileExists(SaveDialog1.FileName) then
             DeleteFile(SaveDialog1.FileName);


        ExcelApp.WorkSheets[2].Activate;
        QueryOutputByPDLine( QryTemp,sDStartTime,sNEndTime);
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
          strTotal :=  QryTemp.FieldByName('Total_QTY').AsString;

          if  strTitle= 'AOO' then  begin
              if strTotal='0' then begin
                 ExcelApp.Cells[3,LineCount].Value :='';
              end;
              ExcelApp.Cells[3,LineCount].Value := strtoInt(strFPY)/strtoInt(strTotal);
          end;

          if  strTitle = 'FF' then begin
              if strTotal='0' then begin
                 ExcelApp.Cells[4,LineCount].Value :='';
              end
              else
                ExcelApp.Cells[4,LineCount].Value := strtoInt(strFPY)/strtoInt(strTotal);
          end;

          if  strTitle = 'FQC' then  begin
              if strTotal='0' then begin
                 ExcelApp.Cells[5,LineCount].Value :='';
              end else
              ExcelApp.Cells[5,LineCount].Value := strtoInt(strFPY)/strtoInt(strTotal);
          end;
          QryTemp.Next;
        end;

        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
        ExcelApp.Quit;
        MessageDlg('Save OK',mtConfirmation,[mbyes],0);


    end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
    DateTimePicker1.Date := Now;
end;

end.
