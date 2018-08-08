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
    Label4: TLabel;
    cmbLine: TComboBox;
    Label5: TLabel;
    edtWo: TEdit;
    chkDefect: TCheckBox;
    procedure sbtnQueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBGrid2DblClick(Sender: TObject);
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
    function QueryDefectSN(QryTemp1:TClientDataset;sStartTime,sEndTime:String):boolean;
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

    QueryOutput(QryData, sStartTime, sEndTime);
    QueryDefect(QryDefect,sDStartTime,sDEndTime);
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
     if CmbLine.text <> '' then
           QryTemp1.CommandText:=  QryTemp1.CommandText+' and  g.PDLINE_NAME = '''+cmbLine.Text+'''';


     QryTemp1.CommandText:=  QryTemp1.CommandText+' and  c.WORK_ORDER  like :WO ';

     QryTemp1.CommandText:=  QryTemp1.CommandText+ '  GROUP BY B.PROCESS_NAME, B.PROCESS_CODE   ORDER BY B.PROCESS_CODE ';

    QryTemp1.Params.ParamByName('WO').AsString := edtwo.text+'%';
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sEndTime;
    QryTemp1.Open;
end;

function TfDetail.QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'WO',ptInput);
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

     if CmbLine.text <> '' then
           QryTemp1.CommandText:=  QryTemp1.CommandText+' and  f.PDLINE_NAME = '''+cmbLine.Text+'''';

     QryTemp1.CommandText:=  QryTemp1.CommandText+' and  a.WORK_ORDER  like :wo';


     QryTemp1.CommandText:=  QryTemp1.CommandText+' group by  B.PROCESS_NAME ,b.Process_Code, C.defect_Code, c.Defect_desc ,a. Serial_number '+
                           '    )'+
                           ' )  '+
                           ' group by Process_NAME,Process_Code,DEFECT_CODE ,Defect_desc '+
                           ' order  by Process_Code, Count desc ' ;

    QryTemp1.Params.ParamByName('WO').AsString := edtWo.Text+'%';
    QryTemp1.Params.ParamByName('StartTime').AsString := sDStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sDEndTime;
    QryTemp1.Open;
end;


function TfDetail.QueryDefectSN(QryTemp1:TClientDataset;sStartTime,sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'WO',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'DEFECT',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'PROCESS',ptInput);
    QryTemp1.CommandText:= '      select * from  (select  e.Model_Name,a.rec_time ,decode(g.customer_sn ,''N/A'', '+
                           '      a.Serial_number,g.customer_sn) customer_sn, a.rp_status, a.RECEIVE_TIME,'+
                           '      B.PROCESS_NAME ,B.PROCESS_CODE,C.defect_code,  decode(a.ntf_time,null,h.Repair_time,a.ntf_time)  Repair_time, '+
                           '      c.Defect_desc , decode(a.ntf_time,null,j.reason_desc,''重測OK'') reason_desc from '+
                           '      sajet.g_SN_defect_first a, sajet.SYS_PROCESS b, sajet.sys_defect c , sajet.sys_part d , '+
                           '      sajet.sys_Model e , sajet.sys_pdline f , sajet.g_sn_status g , sajet.g_sn_repair h ,'+
                           '      sajet.sys_reason j '+
                           '      where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and '+
                           '      a.REC_Time >= to_date(:StartTime, ''yyyy/mm/dd hh24:mi:ss'') '+
                           '      and a.REC_Time <to_date(:EndTime, ''yyyy/mm/dd hh24:mi:ss'') '+
                           '      and   a.serial_number=g.serial_number '+
                           '      and h.reason_id  =j.reason_id(+) and a.serial_number = h.serial_number(+)   '+
                           '      and a.MOdel_ID=d.Part_ID and e.MOdel_ID =d.Model_ID and  a.pdline_id =f.pdline_ID and ';
    //if chkRetest.Checked then
             //QryTemp1.CommandText:=  QryTemp1.CommandText+ ' a.ntf_time is null and ';
             

     if Pos('%',cmbModel.Text)>=0 then
            QryTemp1.CommandText:=  QryTemp1.CommandText+' e.MOdel_Name like '''+cmbModel.Text+''''
     else
          QryTemp1.CommandText:=  QryTemp1.CommandText+' e.MOdel_Name ='''+cmbModel.Text+'''';

     if CmbLine.text <> '' then
           QryTemp1.CommandText:=  QryTemp1.CommandText+' and  f.PDLINE_NAME = '''+cmbLine.Text+'''';

    QryTemp1.CommandText:=  QryTemp1.CommandText+' and  a.WORK_ORDER  like :wo  ) where repair_time >rec_time  '+
                            ' or repair_time is null order by PROCESS_CODE,customer_sn, rec_time ';

    QryTemp1.Params.ParamByName('WO').AsString := edtWO.Text+'%';
    QryTemp1.Params.ParamByName('StartTime').AsString := sDStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sDEndTime;
    QryTemp1.Open;

end;

procedure TfDetail.sBtnExportClick(Sender: TObject);
var  strNTF :string;
     strTitle,strFPY,strFail,strPDline,strPDLineFrist,strRepass,strTotal,strDefectName,
     strDefect_QTY,strTestTIme,strRepairTime, strModelName,
     strDefect_Desc,strFailAll,strDefectSN,strDefect_Reason :string;
     i,j,K,LineCount,UsedRow,UsedCount,defect_count,count:integer;
     ExcelApp: Variant;
begin
    if SaveDialog1.Execute then begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);

        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'NEC Daily Report.xltx');
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.WorkSheets[1].Name :=   cmbModel.Text ;
        ExcelApp.Cells[1,1].Value := cmbModel.Text +' Daily Report';
        ExcelApp.Cells[2,2].Value := sDStartTime;
        ExcelApp.Cells[2,4].Value := sDEndTime;

        i:=0;
        j:=0;
        k:=0;
        if not QryData.IsEmpty then
        begin
             QryData.First;
             for  i:=4 to QryData.RecordCount+3  do
             begin

                  strTitle :=QryData.FieldByName('PROCESS_NAME').AsString ;
                  strFPY :=  QryData.FieldByName('FPY_QTY').AsString;
                  strFail :=   QryData.FieldByName('FAIL_QTY').AsString;

                  
                  strTotal :=  QryData.FieldByName('TOTAL_QTY').AsString;

                  ExcelApp.Cells[i,1].Value := strTitle;
                  ExcelApp.Cells[i,2].Value := strTotal;
                  ExcelApp.Cells[i,3].Value := strFPY;
                  ExcelApp.Cells[i,4].Value := strFail;
                  ExcelApp.Cells[i,5].Value := StrToInt(strFPY)/StrToInt(strTotal);
                  QryData.Next;

             end;
             ExcelApp.Cells[i,3].Value := 'Total';
             ExcelApp.Cells[i,4].Value := '=SUM(D4:D'+IntToStr(i-1);
             ExcelApp.Cells[i,5].Value := '=PRODUCT(E4:E'+IntToStr(i-1);
             ExcelApp.ActiveSheet.Range['C4:E'+IntToStr(i)].Borders[1].Weight := 2;
             ExcelApp.ActiveSheet.Range['C4:E'+IntToStr(i)].Borders[2].Weight := 2;
             ExcelApp.ActiveSheet.Range['C4:E'+IntToStr(i)].Borders[3].Weight := 2;
             ExcelApp.ActiveSheet.Range['C4:E'+IntToStr(i)].Borders[4].Weight := 2;

        end;
        ExcelApp.Cells[i+2,1].Value :=  '不良明細';
        ExcelApp.Cells[i+3,1].Value :=  '站別';
        ExcelApp.Cells[i+3,2].Value :=  '不良比率(%)';
        ExcelApp.Cells[i+3,3].Value :=  '不良代碼';
        ExcelApp.Cells[i+3,4].Value :=  '不良數量';
        ExcelApp.Cells[i+3,5].Value :=  '不良現象';
       // ExcelApp.Cells[i+3,6].Value :=  'NG Barcode SN';
       // ExcelApp.Cells[i+3,7].Value :=  '不良原因分析';


       ExcelApp.ActiveSheet.Range['A4:E'+IntToStr(i-1)].Borders[1].Weight := 2;
       ExcelApp.ActiveSheet.Range['A4:E'+IntToStr(i-1)].Borders[2].Weight := 2;
       ExcelApp.ActiveSheet.Range['A4:E'+IntToStr(i-1)].Borders[3].Weight := 2;
       ExcelApp.ActiveSheet.Range['A4:E'+IntToStr(i-1)].Borders[4].Weight := 2;
       ExcelApp.ActiveSheet.Range['E4:E'+IntToStr(i)].NumberFormat  := '0.00%';
       ExcelApp.ActiveSheet.Range['A4:E'+IntToStr(i-1)].HorizontalAlignment :=3;

       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+2)+':A'+IntToStr(i+2)].Borders[1].Weight := 2;
       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+2)+':A'+IntToStr(i+2)].Borders[2].Weight := 2;
       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+2)+':A'+IntToStr(i+2)].Borders[3].Weight := 2;
       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+2)+':A'+IntToStr(i+2)].Borders[4].Weight := 2;
       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+2)+':A'+IntToStr(i+2)].HorizontalAlignment :=3;
       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+2)+':A'+IntToStr(i+2)].Font.Color := rgb(26,112,6);
       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+2)+':A'+IntToStr(i+2)].Font.Size :=14;
       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+3)+':E'+IntToStr(i+3)].Font.Color :=clWhite;
       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+3)+':E'+IntToStr(i+3)].Font.Size :=10;
       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+3)+':E'+IntToStr(i+3)].Font.Bold :=True;
       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+3)+':E'+IntToStr(i+3)].Interior.Color :=rgb(55,96,145);
       //ExcelApp.ActiveSheet.Columns[6].ColumnWidth := 60;
      // ExcelApp.ActiveSheet.Columns[7].ColumnWidth := 60;

        defect_count := QryDefect.RecordCount-1;
        count :=0;
        if not QryDefect.IsEmpty then
        begin
              QryDefect.First;
              for  j:=i+4 to defect_count+i+4  do
              begin
                  strTitle :=QryDefect.FieldByName('PROCESS_NAME').AsString ;
                  strDefectName :=  QryDefect.FieldByName('Defect_Code').AsString;
                  strDefect_Desc := QryDefect.FieldByName('Defect_Desc').AsString;
                  strDefect_QTY :=  QryDefect.FieldByName('Count').AsString;
                  ExcelApp.Cells[j,1].Value := strTitle;
                  ExcelApp.Cells[j,3].Value := strDefectName;

                  for K:=4 to i  do begin

                     if  ExcelApp.Cells[j,1].Value =   ExcelApp.Cells[k,1].Value then
                     begin
                         ExcelApp.Cells[j,2].Value :=  strtoint(strDefect_QTY)/StrtoInt(ExcelApp.Cells[K,2]) ;
                         break;
                     end;
                  end;
                  ExcelApp.Cells[j,4].Value := strDefect_QTY;
                  ExcelApp.Cells[j,5].Value := strDefect_Desc;
                  


                  {strDefectSN :='';
                      strDefect_Reason :='';
                      while  not QryTemp.Eof do begin
                         strDefectSN := strDefectSN + QryTemp.fieldbyName('CUSTOMER_SN').AsString +',';
                         if QryTemp.fieldbyName('REASON_DESC').AsString  <> 'N/A' then
                              strDefect_Reason :=  strDefect_Reason + QryTemp.fieldbyName('CUSTOMER_SN').AsString +':'
                                                 + QryTemp.fieldbyName('REASON_DESC').AsString +',';
                         QryTemp.Next;
                      end;
                  end;

                  ExcelApp.Cells[j,6].Value := strDefectSN;
                  ExcelApp.Cells[j,7].Value := strDefect_Reason;
                  }
                  QryDefect.Next;
                  
              end;
        end else
           j:=i+4;

       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+3)+':E'+IntToStr(j-1)].Borders[1].Weight := 2;
       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+3)+':E'+IntToStr(j-1)].Borders[2].Weight := 2;
       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+3)+':E'+IntToStr(j-1)].Borders[3].Weight := 2;
       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+3)+':E'+IntToStr(j-1)].Borders[4].Weight := 2;
       ExcelApp.ActiveSheet.Range['A'+IntToStr(i+3)+':E'+IntToStr(j-1)].HorizontalAlignment :=3;
       ExcelApp.ActiveSheet.Range['F'+IntToStr(i+4)+':E'+IntToStr(j-1)].HorizontalAlignment :=2;
       ExcelApp.ActiveSheet.Range['B'+IntToStr(i+4)+':B'+IntToStr(j-1)].NumberFormat  := '0.00%';
       ExcelApp.ActiveSheet.Range['A4:F'+IntToStr(i+3)].Font.Name :='Tohama';


        ExcelApp.Worksheets.Add(After:=ExcelApp.Sheets[1]);
        ExcelApp.WorkSheets[2].Activate;
        ExcelApp.WorkSheets[2].Name :=   'Defect Detials';
        ExcelApp.Cells[1,1].Value := cmbModel.Text +'  Defect Detials';
        ExcelApp.Cells[2,1].Value :=  '項目';
        ExcelApp.Cells[2,2].Value :=  '站別';
        ExcelApp.Cells[2,3].Value :=  '機種';
        ExcelApp.Cells[2,4].Value :=  '條碼';
        ExcelApp.Cells[2,5].Value :=  '測試時間';
        ExcelApp.Cells[2,6].Value :=  '不良現象';
        ExcelApp.Cells[2,7].Value :=  '維修時間';
        ExcelApp.Cells[2,8].Value :=  '不良原因';
        ExcelApp.Cells[2,9].Value :=  '維修后測試時間';
        ExcelApp.Cells[2,10].Value :=  '維修后測試結果';
        ExcelApp.Cells[2,11].Value :=  '改善對策';
        ExcelApp.ActiveSheet.Columns[1].ColumnWidth := 6;
        ExcelApp.ActiveSheet.Columns[2].ColumnWidth := 12;
        ExcelApp.ActiveSheet.Columns[3].ColumnWidth := 15;
        ExcelApp.ActiveSheet.Columns[4].ColumnWidth := 25;
        ExcelApp.ActiveSheet.Columns[5].ColumnWidth := 25;
        ExcelApp.ActiveSheet.Columns[6].ColumnWidth := 25;
        ExcelApp.ActiveSheet.Columns[7].ColumnWidth := 25;
        ExcelApp.ActiveSheet.Columns[8].ColumnWidth := 20;
        ExcelApp.ActiveSheet.Columns[9].ColumnWidth := 20;
        ExcelApp.ActiveSheet.Columns[10].ColumnWidth := 20;
        ExcelApp.ActiveSheet.Columns[11].ColumnWidth := 20;

       ExcelApp.ActiveSheet.Range['A1:K1'].Merge;
       ExcelApp.ActiveSheet.Range['A1:K1'].Font.Size :=16;
       ExcelApp.ActiveSheet.Range['A1:K1'].Font.Bold :=True;
       ExcelApp.ActiveSheet.Range['A2:K2'].Font.Color :=clWhite;
       ExcelApp.ActiveSheet.Range['A2:K2'].Font.Size :=10;
       ExcelApp.ActiveSheet.Range['A2:K2'].Font.Bold :=True;
       ExcelApp.ActiveSheet.Range['A2:K2'].Interior.Color :=rgb(55,96,145);
       if chkDefect.Checked then begin
            QueryDefectSN(QryTemp,sDStartTime,sDEndTime) ;
            if not QryTemp.IsEmpty then begin
                QryTemp.First;
                 for k:=0 to QryTemp.RecordCount-1 do begin
                   strModelName := QryTemp.fieldbyName('Model_Name').AsString ;
                   strDefectSN := QryTemp.fieldbyName('CUSTOMER_SN').AsString ;
                   strDefect_Reason :=QryTemp.fieldbyName('REASON_DESC').AsString;
                   strTestTIme :=QryTemp.fieldbyName('Rec_Time').AsString;
                   strRepairTime :=QryTemp.fieldbyName('Repair_time').AsString;
                   strTitle := QryTemp.fieldbyName('PROCESS_NAME').AsString;
                   strDefect_Desc := QryTemp.fieldbyName('Defect_desc').AsString;
                   ExcelApp.Cells[k+3,1].Value  :=  k+1;
                   ExcelApp.Cells[k+3,2].Value  :=  strTitle;
                   ExcelApp.Cells[k+3,3].Value  :=  strModelName;
                   ExcelApp.Cells[k+3,4].Value  :=  strDefectSN;
                   ExcelApp.Cells[k+3,5].Value  :=  strTestTIme;
                   ExcelApp.Cells[k+3,6].Value  :=  strDefect_Desc;
                   ExcelApp.Cells[k+3,7].Value  :=  strRepairTIme;
                   ExcelApp.Cells[k+3,8].Value  :=  strDefect_Reason;
                    ExcelApp.Cells[k+3,9].Value  := QryTemp.fieldbyName('RECEIVE_TIME').AsString ;
                   if QryTemp.fieldbyName('RP_STATUS').AsString ='2' then begin
                       ExcelApp.Cells[k+3,10].Value := 'OK';
                   end else if QryTemp.fieldbyName('RP_STATUS').AsString = '3'  then
                       ExcelApp.Cells[k+3,10].Value := 'NG';

                   QryTemp.Next;
                end;
            end else
              K:=0;

           ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(K+2)].Borders[1].Weight := 2;
           ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(K+2)].Borders[2].Weight := 2;
           ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(K+2)].Borders[3].Weight := 2;
           ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(K+2)].Borders[4].Weight := 2;
           ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(K+2)].HorizontalAlignment :=3;
           ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(K+2)].Font.Name :='Tohama';
       end;
       ExcelApp.WorkSheets[1].Activate;
       ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
       ExcelApp.Quit;
       MessageDlg('Save OK',mtConfirmation,[mbyes],0);
       QueryDefect(QryDefect,sDStartTime,sDEndTime);
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

    qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Commandtext := 'select distinct (PDLINE_Name)  from sajet.sys_PDLINE where Enabled =''Y'' order by PDLINE_Name ';
    qrytemp.Open;
    qrytemp.First;
     cmbLine.Items.Add('') ;
    for i:=0 to qrytemp.recordcount-1 do begin
       cmbLine.Items.Add(qrytemp.fieldbyname('PDLINE_Name').asstring) ;
       qrytemp.Next;
    end;
end;

procedure TfDetail.DBGrid2DblClick(Sender: TObject);
begin
  //
  
end;

end.
