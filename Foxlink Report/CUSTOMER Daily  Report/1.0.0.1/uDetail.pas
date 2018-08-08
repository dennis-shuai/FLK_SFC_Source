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
    Label5: TLabel;
    edtWo: TEdit;
    QryAll: TClientDataSet;
    dbgrd1: TDBGrid;
    ds1: TDataSource;
    btn1: TSpeedButton;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    cmbCustomer: TComboBox;
    Label8: TLabel;
    cmbStage: TComboBox;
    rgDefectType: TRadioGroup;
    chkDefect: TCheckBox;
    chkModel: TCheckBox;
    procedure sbtnQueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBGrid2DblClick(Sender: TObject);
    procedure cmbCustomerSelect(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO,sStage:string;
    G_sProcessList,G_sModelList : String;
    Count:Integer;
    UpDate_Time :TDateTime;
    sStartTime, sEndTime, sDStartTime, sDEndTime,sTime1,sTime2,sCustomer :string;
    function QueryOutput( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function QueryAllOutput(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function QueryDefectSN(QryTemp1:TClientDataset;sStartTime,sEndTime:String):boolean;
    //procedure ShowAllData(sTitle,sFieldName,sFieldID:string;ListField:TListBox);
  end;

var
  fDetail: TfDetail;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit,uSelect;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
begin
    sCustomer := cmbCustomer.Items.Strings[cmbCustomer.ItemIndex];
    sStage := cmbStage.Items.Strings[cmbStage.ItemIndex];
    if length(ComboBox1.Text)=1  then  sTime1 := '0' + ComboBox1.Text
    else  sTime1 := ComboBox1.Text;

    if length(ComboBox2.Text)=1  then  sTime2 := '0' + ComboBox2.Text
    else  sTime2 := ComboBox2.Text;

    sStartTime  := FormatDateTime('yyyymmdd',DateTimePicker1.Date)+ sTime1  ;
    sEndTime  := FormatDateTime('yyyymmdd',DateTimePicker2.Date)+ sTime2 ;

    sDStartTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+ ' '+ sTime1+':00:00'  ;
    sDEndTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker2.Date) + ' ' + sTime2 +':00:00' ;

    QueryAllOutput(QryAll, sStartTime, sEndTime);
    QryData.Close;
    if chkModel.Checked then
       QueryOutput(QryData, sStartTime, sEndTime);
    QryDefect.Close;
    if chkDefect.Checked  then
       QueryDefect(QryDefect, sStartTime, sEndTime);

end;

function TfDetail.QueryAllOutput(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'WO',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Customer',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Stage',ptInput);
    QryTemp1.CommandText:=' SELECT  B.PROCESS_NAME, B.PROCESS_CODE, NVL(SUM(C.PASS_QTY),0) FPY_QTY , NVL(SUM(C.FAIL_QTY),0) FAIL_QTY, '+
                          ' NVL(SUM(C.OUTPUT_QTY),0) Output_QTY, NVL(SUM(C.REPAIR_QTY),0) REPAIR_QTY, NVL (SUM(C.NTF_QTY),0) NTF_QTY,   '+
                          ' NVL(SUM(C.PASS_QTY+C.FAIL_QTY),0) TOTAL_QTY ,    '+
                          ' round(  DECODE(SUM(C.PASS_QTY +C.FAIL_QTY),0,0.00,SUM(C.PASS_QTY )/SUM(C.PASS_QTY +C.FAIL_QTY))*100,2)   FPY , '+
                          ' round(  DECODE(SUM(C.PASS_QTY +C.FAIL_QTY),0,0.00,SUM(C.PASS_QTY +C.NTF_QTY)/SUM(C.PASS_QTY +C.FAIL_QTY))*100,2)   SPY , '+
                          ' round(  DECODE(SUM(C.PASS_QTY +C.FAIL_QTY),0,0.00,SUM(C.PASS_QTY +C.NTF_QTY+C.REPAIR_QTY)/SUM(C.PASS_QTY +C.FAIL_QTY))*100,2)   Final_SPY  '+
                          ' FROM   SAJET.SYS_PROCESS B ,                             '+
                          ' (select * from (select WORK_ORDER,MODEL_ID,PDLINE_ID,Stage_id,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REFAIL_QTY,OUTPUT_QTY,NTF_QTY,Repair_qty,'+
                          ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime   '+
                          ' from SAJET.G_SN_COUNT where      (PASS_QTY+FAIL_QTY)<>0 ) where   DateTime >:startTime and  DateTime <:endTime )  C, '+
                          ' sajet.sys_part d,sajet.sys_model e,sajet.sys_customer f,sajet.sys_stage g '+
                          ' where  d.part_id= c.model_id and d.model_id= e.model_id and  C.PROCESS_ID = B.PROCESS_ID '+
                          ' and  c.WORK_ORDER  like :WO  and e.customer_id=f.customer_id and f.customer_name=:Customer  ' +
                          ' and c.stage_id=g.stage_id and g.stage_name=:stage '+
                          ' and Upper(b.Process_name) not like ''%PACK%''  and Upper(b.Process_name) not like ''SN%'' '+
                          ' and Upper(b.Process_name) not like ''%INPUT%'' and Upper(b.Process_name) not like ''%MYLAR%'' '+
                          ' group by  B.PROCESS_NAME, B.PROCESS_CODE order by B.process_code,FPY ';

    QryTemp1.Params.ParamByName('WO').AsString := edtwo.text+'%';
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sEndTime;
    QryTemp1.Params.ParamByName('Customer').AsString :=  sCustomer;
    QryTemp1.Params.ParamByName('Stage').AsString :=  sStage;
    QryTemp1.Open;
end;


function TfDetail.QueryOutput(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'WO',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Customer',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Stage',ptInput);
    QryTemp1.CommandText:=' SELECT e.MODEL_NAME,B.PROCESS_NAME, B.PROCESS_CODE, NVL(SUM(C.PASS_QTY),0) FPY_QTY , NVL(SUM(C.FAIL_QTY),0) FAIL_QTY, '+
                          ' NVL(SUM(C.OUTPUT_QTY),0) Output_QTY, NVL(SUM(C.REPAIR_QTY),0) REPAIR_QTY, NVL (SUM(C.NTF_QTY),0) NTF_QTY,   '+
                          ' NVL(SUM(C.PASS_QTY+C.FAIL_QTY),0) TOTAL_QTY ,    '+
                          ' round(  DECODE(SUM(C.PASS_QTY +C.FAIL_QTY),0,0.00,SUM(C.PASS_QTY )/SUM(C.PASS_QTY +C.FAIL_QTY))*100,2)   FPY , '+
                          ' round(  DECODE(SUM(C.PASS_QTY +C.FAIL_QTY),0,0.00,SUM(C.PASS_QTY +C.NTF_QTY)/SUM(C.PASS_QTY +C.FAIL_QTY))*100,2)   SPY , '+
                          ' round(  DECODE(SUM(C.PASS_QTY +C.FAIL_QTY),0,0.00,SUM(C.PASS_QTY +C.NTF_QTY+C.REPAIR_QTY)/SUM(C.PASS_QTY +C.FAIL_QTY))*100,2)   Final_SPY  '+
                          ' FROM   SAJET.SYS_PROCESS B ,                             '+
                          ' (select * from (select WORK_ORDER,MODEL_ID,Stage_id,PDLINE_ID,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REFAIL_QTY,OUTPUT_QTY,NTF_QTY,Repair_qty,'+
                          ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime   '+
                          ' from SAJET.G_SN_COUNT where    PASS_QTY+FAIL_QTY <>0  )'+
                          ' where   DateTime >:startTime and  DateTime <:endTime   )  C ,'+
                          ' sajet.sys_part d , sajet.sys_model e ,sajet.sys_customer f,sajet.sys_stage g '+
                          ' where c.model_ID =d.Part_ID and d.Model_ID = E.Model_ID and C.PROCESS_ID = B.PROCESS_ID '+
                          ' and  c.WORK_ORDER  like :WO and e.customer_id=f.customer_id and f.customer_name=:Customer   ' +
                          ' and c.stage_id=g.stage_id and g.stage_name=:stage '+
                          ' and Upper(b.Process_name) not like ''%PACK%'' and Upper(b.Process_name) not like ''SN%'' '+
                          ' and Upper(b.Process_name) not like ''%INPUT%'' and Upper(b.Process_name) not like ''%MYLAR%'' '+
                          ' group by e.MODEL_NAME,B.PROCESS_NAME, B.PROCESS_CODE '+
                          ' order by  e.MODEL_NAME,B.PROCESS_CODE ';

    QryTemp1.Params.ParamByName('WO').AsString := edtwo.text+'%';
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sEndTime;
    QryTemp1.Params.ParamByName('Customer').AsString :=  sCustomer;
    QryTemp1.Params.ParamByName('Stage').AsString :=  sStage;
    QryTemp1.Open;
end;

function TfDetail.QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'WO',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Customer',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Stage',ptInput);
    QryTemp1.CommandText:= ' select AA.Model_Name,AA.PROCESS_NAME,AA.Process_Code,AA.Defect_desc,AA.QTY,'+
                           ' round(aa.qty/bb.Total_qty*100,2) rate ,'+
                           ' ROW_NUMBER() OVER(PARTITION BY AA.Model_Name  ORDER BY AA.QTY DESC)  RAN '+
                           ' from (select Model_Name,Process_NAME ,Process_Code,Defect_desc,count(C_SN) AS QTY  '+
                           ' from  '+
                           ' (   select Model_Name,Serial_number,PROCESS_NAME,Process_Code,Defect_desc,C_SN from  '+
                           '     ( '+
                           '      select E.Model_Name,a.Serial_number,B.PROCESS_NAME ,b.Process_Code, '+
                           '     c.Defect_desc,1 as C_SN   from '+
                           '     sajet.g_SN_defect_first a,sajet.SYS_PROCESS b,sajet.sys_defect c ,sajet.sys_part d , sajet.sys_Model e  '+
                           '     ,sajet.sys_customer f,sajet.sys_stage g '+
                           '     where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyymmddhh'') '+
                           '     and a.REC_Time < to_date(:EndTime, ''yyyymmddhh'') ';
    if rgDefectType.ItemIndex =1 then
        QryTemp1.CommandText :=QryTemp1.CommandText +' and a.NTF_TIME IS NULL  ';
    QryTemp1.CommandText := QryTemp1.CommandText + ' and e.customer_id=f.customer_id and f.customer_name=:Customer   ' +
                           '     and a.stage_id=g.stage_id and g.stage_name=:stage '+
                           '     and Upper(b.Process_name) not like ''%PACK%'' and Upper(b.Process_name) not like ''%BINDING%'' '+
                           '     and Upper(b.Process_name) not like ''%INPUT%'' and Upper(b.Process_name) not like ''%MYLAR%'' '+
                           '     and a.MOdel_ID=d.Part_ID and e.MOdel_ID =d.Model_ID ';


     QryTemp1.CommandText:=  QryTemp1.CommandText+' and  a.WORK_ORDER  like :WO ' +
                           '  group by  E.Model_Name,B.PROCESS_NAME ,b.Process_Code, c.Defect_desc ,a. Serial_number '+
                           '    )'+
                           ' )  '+
                           ' group by   Model_Name,Process_NAME,Process_Code ,Defect_desc ) AA,'+
                           ' ( SELECT  e.MODEL_NAME,B.PROCESS_NAME, B.PROCESS_CODE,     '+
                           '   NVL(SUM(C.PASS_QTY+C.FAIL_QTY),0) TOTAL_QTY    '+
                           '   FROM   SAJET.SYS_PROCESS B ,( select * from (select  WORK_ORDER,model_ID, PROCESS_ID,PASS_QTY,FAIL_QTY ,'+
                           '   to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime   '+
                           '   from SAJET.G_SN_COUNT   ) where   DateTime >=:startTime and  DateTime <:endTime )  C ,'+
                           '   sajet.sys_part d , sajet.sys_model e                             '+
                           '   where c.model_ID =d.Part_ID and d.Model_ID = E.Model_ID and C.PROCESS_ID = B.PROCESS_ID ';

     QryTemp1.CommandText:=  QryTemp1.CommandText+' and  c.WORK_ORDER  like :WO ';

     QryTemp1.CommandText:=  QryTemp1.CommandText+ ' group by  e.MODEL_NAME,B.PROCESS_NAME, B.PROCESS_CODE ) BB '+
                           '  where aa.Model_Name=bb.Model_Name and aa.process_Name=bb.Process_name  and bb.Total_qty <>0  ' +
                           '  Order by  MODEL_NAME,QTY Desc,RATE DESC  ';

    QryTemp1.Params.ParamByName('WO').AsString := edtWo.Text+'%';
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sEndTime;
    QryTemp1.Params.ParamByName('Customer').AsString :=  sCustomer;
    QryTemp1.Params.ParamByName('Stage').AsString :=  sStage;
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
                           '      c.Defect_desc , decode(a.ntf_time,null,j.reason_desc,''­«´úOK'') reason_desc from '+
                           '      sajet.g_SN_defect_first a, sajet.SYS_PROCESS b, sajet.sys_defect c , sajet.sys_part d , '+
                           '      sajet.sys_Model e , sajet.sys_pdline f , sajet.g_sn_status g , sajet.g_sn_repair h ,'+
                           '      sajet.sys_reason j '+
                           '      where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and '+
                           '      a.REC_Time >= to_date(:StartTime, ''yyyy/mm/dd hh24:mi:ss'') '+
                           '      and a.REC_Time <to_date(:EndTime, ''yyyy/mm/dd hh24:mi:ss'') '+
                           '      and   a.serial_number=g.serial_number '+
                           '      and h.reason_id  =j.reason_id(+) and a.serial_number = h.serial_number(+)   '+
                           '      and a.MOdel_ID=d.Part_ID and e.MOdel_ID =d.Model_ID and  a.pdline_id =f.pdline_ID and ';

    QryTemp1.CommandText:=  QryTemp1.CommandText+' and  a.WORK_ORDER  like :wo  ) where repair_time >rec_time  '+
                            ' or repair_time is null order by PROCESS_CODE,customer_sn, rec_time ';

    QryTemp1.Params.ParamByName('WO').AsString := edtWO.Text+'%';
    QryTemp1.Params.ParamByName('StartTime').AsString := sDStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sDEndTime;
    QryTemp1.Open;

end;

procedure TfDetail.sBtnExportClick(Sender: TObject);
var  strNTF,strFirstModel,strFirstMergeRow :string;
     strModel,strTitle,strFPY,strFail,strOutput,strPDline,strPDLineFrist,strRepass,strTotal,strDefectName,
     strDefect_QTY,strTestTIme,strRepairTime, strModelName,
     strDefect_Desc,strFailAll,strRepairAll,strDefectSN,strDefect_Reason,FPY,SPY,Final_SPY :string;
     i,j,defect_count,Color_Count,iRow:integer;
     ExcelApp: Variant;
     AColor: array[0..1] of TColor;
begin
    if SaveDialog1.Execute then
    begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);

        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'Customer Daily Report.xlsx');
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.WorkSheets[1].Name :=   'Summary' ;
        ExcelApp.Cells[1,1].Value := sCustomer +' Daily Report';
        ExcelApp.Cells[2,3].Value := sDStartTime;
        ExcelApp.Cells[2,5].Value := sDEndTime;

        i:=0;
        j:=0;

        AColor[0] := $00D8DAA5;
        AColor[1] := $00B0D2E3;
        Color_Count :=0;
        if   QryAll.IsEmpty then Exit;
        ExcelApp.ActiveSheet.Range['A1:K1'].Merge;
        ExcelApp.Cells[3,11].Value := 'Output_qty';
        ExcelApp.Cells[3,11].Font.Color := clWhite;
        ExcelApp.Cells[3,11].Interior.Color := RGB(55,96,146);
        ExcelApp.Cells[3,11].Font.Bold := true;
        with QryAll do begin
             First;
             for  i:=5 to QryAll.RecordCount+4  do
             begin
                  strTitle :=  FieldByName('PROCESS_NAME').AsString ;
                  strFPY :=    FieldByName('FPY_QTY').AsString;
                  strFail :=   FieldByName('FAIL_QTY').AsString;
                  strOutput :=  FieldByName('Output_qty').AsString;
                  strRepairAll := FieldByName('REPAIR_QTY').AsString;
                  strNTF :=  FieldByName('NTF_QTY').AsString;
                  strTotal :=   FieldByName('TOTAL_QTY').AsString;
                  SPY :=    FieldByName('SPY').AsString;
                  FPY :=    FieldByName('FPY').AsString;
                  Final_SPY := FieldByName('Final_SPY').AsString;

                  ExcelApp.Cells[i,2].Value := strTitle;
                  ExcelApp.Cells[i,3].Value := strTotal;
                  ExcelApp.Cells[i,4].Value := strFPY;
                  ExcelApp.Cells[i,5].Value := strFail;
                  ExcelApp.Cells[i,6].Value := FPY;
                  ExcelApp.Cells[i,7].Value := strNTF;
                  ExcelApp.Cells[i,8].Value := SPY;
                  ExcelApp.Cells[i,9].Value :=  strRepairAll;
                  ExcelApp.Cells[i,10].Value := Final_SPY;
                  ExcelApp.Cells[i,11].Value := strOutput;
                  ExcelApp.Cells[i,1].Value := sCustomer+' All';
                  Next;
             end;
        end;

        ExcelApp.ActiveSheet.Range['A'+intTostr(5)+':A'+ intTostr(i-1)].Merge;
        ExcelApp.Cells[i,1].Value := 'Detail';
        ExcelApp.ActiveSheet.Range['B'+intTostr(i)+':K'+ intTostr(i)].Merge;
        ExcelApp.Cells[i,1].Interior.Color := clBlack;
        ExcelApp.Cells[i,1].Font.Color := clWhite;
        ExcelApp.Cells[i,1].Font.Bold := True;



        with QryData do begin
            if  Active and (not IsEmpty) then
            begin
                 First;
                 for   j:=i+1 to RecordCount+i  do
                 begin

                      strModel :=  FieldByName('Model_NAME').AsString ;
                      if j=i+1 then
                      begin
                           strFirstModel :=  strModel ;
                           strFirstMergeRow := IntToStr(j);

                      end;
                      strTitle :=  FieldByName('PROCESS_NAME').AsString ;
                      strFPY :=    FieldByName('FPY_QTY').AsString;
                      strFail :=   FieldByName('FAIL_QTY').AsString;
                      strOutput :=  FieldByName('Output_qty').AsString;
                      strRepairAll := FieldByName('REPAIR_QTY').AsString;
                      strNTF :=  FieldByName('NTF_QTY').AsString;
                      strTotal :=   FieldByName('TOTAL_QTY').AsString;
                      SPY :=    FieldByName('SPY').AsString;
                      FPY :=    FieldByName('FPY').AsString;
                      Final_SPY := FieldByName('Final_SPY').AsString;
                      if  strFirstModel<>  strModel then
                      begin
                            ExcelApp.ActiveSheet.Range['A'+strFirstMergeRow+':A'+ intTostr(j-1)].Merge;
                            ExcelApp.ActiveSheet.Range['A'+strFirstMergeRow+':K'+IntToStr(j-1)].Interior.Color := AColor[Color_Count Mod 2];
                            strFirstModel :=  strModel;
                            strFirstMergeRow := IntToStr(j);
                            Inc(Color_Count);
                      end;

                      ExcelApp.Cells[J,1].Value := strModel;
                      ExcelApp.Cells[J,2].Value := strTitle;
                      ExcelApp.Cells[J,3].Value := strTotal;
                      ExcelApp.Cells[J,4].Value := strFPY;
                      ExcelApp.Cells[J,5].Value := strFail;
                      ExcelApp.Cells[J,6].Value := FPY;
                      ExcelApp.Cells[J,7].Value := strNTF;
                      ExcelApp.Cells[J,8].Value := SPY;
                      ExcelApp.Cells[J,9].Value :=  strRepairAll;
                      ExcelApp.Cells[J,10].Value := Final_SPY;
                      ExcelApp.Cells[J,11].Value := strOutput;
                      Next;
                 end;

                 if  Eof then
                 begin
                     ExcelApp.ActiveSheet.Range['A'+strFirstMergeRow+':A'+ intTostr(J-1)].Merge;
                     ExcelApp.ActiveSheet.Range['A'+strFirstMergeRow+':K'+IntToStr(J-1)].Interior.Color := AColor[Color_Count Mod 2];
                 end;



            end;
        end;
        if QryData.Active and (not QryData.IsEmpty) then
            iRow := J-1
        else
            iRow :=i;
        ExcelApp.ActiveSheet.Range['A3:K'+IntToStr(iRow)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A3:K'+IntToStr(iRow)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A3:K'+IntToStr(iRow)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A3:K'+IntToStr(iRow)].Borders[4].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(iRow)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(iRow)].VerticalAlignment :=2;
        ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(iRow)].Font.Name :='Tohama';
        ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(iRow)].Font.Size :=10;

       ExcelApp.WorkSheets[2].Activate;



       Color_Count :=0;
       if QryDefect.Active and ( not QryDefect.IsEmpty) then
       begin
            defect_count := QryDefect.RecordCount-1;
            QryDefect.First;

            for  j:=3 to defect_count+3  do
            begin
                strModel :=QryDefect.FieldByName('Model_Name').AsString ;
                if j=3 then
                begin
                    strFirstModel :=  strModel ;
                    strFirstMergeRow := IntToStr(j);
                end;
                strTitle :=QryDefect.FieldByName('PROCESS_NAME').AsString ;
                strDefect_Desc := QryDefect.FieldByName('Defect_Desc').AsString;
                strDefect_QTY :=  QryDefect.FieldByName('QTY').AsString;
                ExcelApp.Cells[j,1].Value := strModel;
                ExcelApp.Cells[j,2].Value := strTitle;
                ExcelApp.Cells[j,3].Value := strDefect_Desc;
                ExcelApp.Cells[j,4].Value := strDefect_QTY;
                ExcelApp.Cells[j,5].Value := QryDefect.FieldByName('Rate').AsString;
                if  strFirstModel<>  strModel then
                begin
                    ExcelApp.ActiveSheet.Range['A'+strFirstMergeRow+':A'+ intTostr(j-1)].Merge;
                    ExcelApp.ActiveSheet.Range['A'+strFirstMergeRow+':E'+IntToStr(j-1)].Interior.Color := AColor[Color_Count Mod 2];
                    strFirstModel :=  strModel;
                    strFirstMergeRow := IntToStr(j);
                    Inc(Color_Count);
                end;
                QryDefect.Next;

            end;

             if  QryDefect.Eof then
             begin
                 ExcelApp.ActiveSheet.Range['A'+strFirstMergeRow+':A'+ intTostr(j-1)].Merge;
                 ExcelApp.ActiveSheet.Range['A'+strFirstMergeRow+':E'+IntToStr(j-1)].Interior.Color := AColor[Color_Count Mod 2];
             end;

             ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(J-1)].Borders[1].Weight := 2;
             ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(J-1)].Borders[2].Weight := 2;
             ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(J-1)].Borders[3].Weight := 2;
             ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(J-1)].Borders[4].Weight := 2;
             ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(J-1)].HorizontalAlignment :=3;
             ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(J-1)].VerticalAlignment :=2;
             ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(J-1)].Font.Name :='Tohama';
             ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(J-1)].Font.Size :=10;

             
       end ;


       ExcelApp.WorkSheets[2].Name :=   'Defect Detials';

       ExcelApp.WorkSheets[1].Activate;
       ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
       ExcelApp.Quit;
       MessageDlg('Save OK',mtConfirmation,[mbyes],0);
       //QueryDefect(QryDefect,sDStartTime,sDEndTime);
    end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var i:integer;
begin

    DateTimePicker1.Date :=  Yesterday;
    DateTimePicker2.Date :=  Today;
    cmbCustomer.Style :=csDropDownList;
    with QryTemp do
    begin
        Close;
        Params.Clear;
        CommandText :=  'select distinct Customer_Name from sajet.sys_customer where enabled=''Y'' and Report_flag=''Y''';
        Open;

        cmbCustomer.Items.Clear;
        cmbCustomer.Style := csDropDownList;
        First;
        while not Eof do
        begin
            cmbCustomer.Items.Add(fieldByname('Customer_Name').AsString);
            Next;
        end;
        cmbCustomer.ItemIndex :=cmbCustomer.Items.IndexOf('HP');
    end;

end;

procedure TfDetail.DBGrid2DblClick(Sender: TObject);
begin
  //
  
end;

procedure TfDetail.cmbCustomerSelect(Sender: TObject);
begin
   sCustomer :=cmbCustomer.Items.Strings[cmbCustomer.ItemIndex];
end;

end.
