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
    SaveDialog1: TSaveDialog;
    Label2: TLabel;
    DateTimePicker2: TDateTimePicker;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    QryAll: TClientDataSet;
    dbgrd1: TDBGrid;
    btn1: TSpeedButton;
    Label3: TLabel;
    dbgrd2: TDBGrid;
    Label4: TLabel;
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
    G_sProcessList,G_sModelList : String;
    Count:Integer;
    UpDate_Time :TDateTime;
    sStartTime, sEndTime, sDStartTime, sDEndTime,sTime1,sTime2 :string;
    function QueryOutput(QryTemp1:TClientDataset;sStartTime,sEndTime:String):boolean;
    function QueryYield(QryTemp1:TClientDataset;sStartTime,sEndTime:String):boolean;
    function QueryDefectTop3(QryTemp1:TClientDataset;sStartTime,sEndTime:String):boolean;
  end;

var
  fDetail: TfDetail;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit,uSelect;

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
    QueryDefectTop3(QryDefect, sStartTime, sEndTime);

end;


function TfDetail.QueryOutput(QryTemp1:TClientDataset;sStartTime,sEndTime:String):boolean;
begin

    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.CommandText:=' select  model_name,sum(pgi_qty) pgi_qty,sum(Dmylar_qty) Dmylar_qty ,sum(Nmylar_qty) Nmylar_qty, sum(FPY_YIELD)  FPY_YIELD FROM  '+
                          ' (select c.model_name, sum(output_qty) pgi_qty,0 Dmylar_qty,0 Nmylar_qty,0 FPY_YIELD  '+
                          ' from (select model_id,output_qty,to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime '+
                          '  from sajet.g_sn_count   where process_id=100203 ) a,sajet.sys_part b,sajet.sys_model c  '+
                          ' where dateTime>=:StartTime and dateTime <:EndTime and a.model_id=b.part_id and b.model_id=c.Model_id '+
                          ' group by c.model_name   union   '+
                          {' ( select d.model_name,sum(qty) pgi_qty ,0 Dmylar_qty,0 Nmylar_qty,0 FPY_YIELD '+
                          '  from SAJET.MES_HT_TO_ERP_WIP_DELIVER a,sajet.g_wo_base b, sajet.sys_part c,sajet.sys_model d '+
                          ' where a.work_order=b.work_order and  a.work_order like ''%MA%''   '+
                          ' and b.model_id=c.part_id and c.model_id=d.model_id  and a.create_time >= to_date(:StartTime,''YYYYMMDDHH24'') '+
                          ' and a.create_time < to_date(:EndTime,''YYYYMMDDHH24'') group by d.model_name  union  '+  }
                          '  select c.model_name,0,sum(output_qty)   Dmylar_qty ,0,0 '+
                          '  from (select model_id,output_qty,to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime '+
                          '   from sajet.g_sn_count   where process_id=100215 and shift_id=1000001 and output_qty <>0 ) a,sajet.sys_part b,sajet.sys_model c   '+
                          ' where dateTime>=:StartTime and dateTime <:EndTime and a.model_id=b.part_id and b.model_id=c.Model_id  '+
                          ' group by c.model_name   union   '+
                          ' select c.model_name,0,0,sum(output_qty)   Nmylar_qty,0  '+
                          ' from (select model_id,output_qty,to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime '+
                          '   from sajet.g_sn_count   where process_id=100215 and shift_id=1000002 and output_qty <>0 ) a,sajet.sys_part b,sajet.sys_model c   '+
                          ' where dateTime>=:StartTime and dateTime <:EndTime and a.model_id=b.part_id and b.model_id=c.Model_id  '+
                          '  group by c.model_name    union    '+
                          ' select Model_name,0,0,0, round(exp(sum(ln(decode(FPY_YIELD,0,0.000001,FPY_YIELD)))),3)*100  as FPY_YIELD '+
                          '  from (select c.Model_name, sum(a.pass_qty+a.fail_qty) total_qty,sum(a.pass_qty) pass_qty,d.process_name  '+
                          '  ,decode(sum(a.pass_qty+a.fail_qty),0,1,sum(a.pass_qty)/sum(a.pass_qty+a.fail_qty) )  Fpy_yield  '+
                          ' from (select model_id,to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime ,pass_qty,fail_qty, '+
                          '  PROCESS_id  from sajet.g_sn_count  where stage_id =10022 and (pass_qty+fail_qty)<>0 ) a,sajet.sys_part b,sajet.sys_model c,sajet.sys_process d '+
                          '  where dateTime>=:StartTime and dateTime <:EndTime and a.model_id=b.part_id and b.model_id=c.Model_id '+
                          '  and a.process_id=d.process_id and (d.Process_name not like ''%OQC%'' and d.process_name not like ''Mylar'' '+
                          '  and d.process_name not like ''FQC_R'' )'+
                          '  group by c.Model_name,d.process_name) where total_qty<>0 and Fpy_yield <>0   group by Model_name) '+
                          ' group by model_name order by model_name  ';

    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sEndTime;
    QryTemp1.Open;

end;

function TfDetail.QueryYield(QryTemp1:TClientDataset;sStartTime,sEndTime:String):boolean;
begin

      

end;


    
function TfDetail.QueryDefectTop3(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.CommandText:= ' select aaa.model_name,aaa.defect_desc,aaa.defect_qty,decode(sign(round(bbb.rate,1)-100),-1,round(bbb.rate,1),100) rate,bbb.ran from  '+
                           '(                                                             '+
                           '  select Model_Name  ,Defect_desc,sum(C_SN) Defect_Qty from   '+
                           '   (                                                          '+
                           '      select E.Model_Name,a.Serial_number,B.PROCESS_NAME ,  c.Defect_desc,1 as C_SN '+
                           '      from  sajet.g_SN_defect_first a,sajet.SYS_PROCESS b,sajet.sys_defect c ,sajet.sys_part d , sajet.sys_Model e  '+
                           '      Where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyymmddhh'') '+
                           '         and a.REC_Time < to_date(:EndTime,''yyyymmddhh'')  and  a.stage_Id=10022   '+
                           '         and a.MOdel_ID=d.Part_ID and e.Model_ID =d.Model_ID ) group by Model_Name ,Defect_desc '+
                           ') aaa,                                                                           '+
                           '( select * from                                                                   '+
                           '    ( select  Model_Name,Defect_desc,rate,                                         '+
                           '          ROW_NUMBER() OVER(PARTITION BY Model_Name  ORDER BY rate DESC)  RAN from '+
                           '         (select aa.model_name,aa.Defect_desc,sum(aa.defect_qty/bb.total_qty)*100 rate from '+
                           '           (select Model_Name ,PROCESS_ID,Defect_desc,sum(C_SN) Defect_Qty from(       '+
                           '                select E.Model_Name,a.Serial_number,a.PROCESS_id , c.Defect_desc,1 as C_SN   '+
                           '                from  sajet.g_SN_defect_first a,sajet.sys_process b,sajet.sys_defect c ,sajet.sys_part d , sajet.sys_Model e  '+
                           '                Where A.DEFECT_ID=C.DEFECT_ID  and a.REC_Time >= to_date(:StartTime, ''yyyymmddhh'') '+
                           '                   and a.REC_Time < to_date(:EndTime,''yyyymmddhh'')  and  a.stage_Id=10022 '+
                           '                   and a.process_id =b.process_id and ( B.PROCESS_NAME not like ''%OQC%''   '+
                           '                   and b.process_name not like ''Mylar'' and b.process_name not like ''FQC_R'' )'+
                           '                   and a.MOdel_ID=d.Part_ID and e.Model_ID =d.Model_ID ) group by Model_Name ,PROCESS_ID,Defect_desc '+
                           '            ) aa,                                                             '+
                           '            (select c.Model_Name,a.process_id,sum(a.pass_qty+a.faiL_qty) total_qty  '+
                           '             from  sajet.g_sn_count  a,sajet.sys_part b,sajet.sys_Model c         '+
                           '             where to_number(to_char(a.WORK_DATE)|| TRIM(to_char(a.WORK_TIME,''00'')))>=:StartTime  '+
                           '                 and to_number(to_char(a.WORK_DATE)|| TRIM(to_char(a.WORK_TIME,''00''))) <:EndTime  '+
                           '                 and a.stage_id=10022 and a.model_id=b.part_id and b.model_id=c.model_id '+
                           '                 and (a.pass_qty+a.fail_qty)<>0 group by C.Model_Name,a.process_id '+
                           '           ) bb                                   '+
                           '          where  aa.model_name=bb.Model_name and aa.process_Id=bb.Process_id group by aa.model_name,aa.Defect_desc  '+
                           '       )           '+
                           '    )where ran<=3   '+
                           ') bbb                '+
                           'where aaa.model_name=bbb.model_name and aaa.defect_desc=bbb.defect_desc order by aaa.model_name,ran ';


    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sEndTime;
    QryTemp1.Open;

end;


procedure TfDetail.sBtnExportClick(Sender: TObject);
var
     strModel,strFirstModel,strPGITotal,strDMylarTotal,strNMylarTotal,strFPY,strDefect,
     strDefectQty,strDefectrate,StrDefectSeq,sDefectInfo,sTemp:string;
     i,j,iRow,AllRow:integer;
     ExcelApp: Variant;
begin
    if SaveDialog1.Execute then
    begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);

        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'CM MFG Report.xltx');
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.WorkSheets[1].Name :=   FormatDateTime('MM.DD',Today) ;

        i:=0;
        j:=0;

        strFirstModel :='';
        with QryData do begin
            if not IsEmpty then begin
                 First;
                 AllRow := RecordCount+3;
                 iRow :=4;
                 for  i:=0 to RecordCount-1 do
                 begin
                     strModel  := FieldByName('Model_Name').AsString ;
                     strPGITotal :=  FieldByName('PGI_Qty').AsString ;
                     StrDMylarTotal :=  FieldByName('DMylar_Qty').AsString ;
                     StrNMylarTotal :=  FieldByName('NMylar_Qty').AsString ;
                     strFPY :=    FieldByName('FPY_YIELD').AsString;
                     ExcelApp.Cells[iRow,1].Value := iRow-3;
                     ExcelApp.Cells[iRow,2].Value := strModel;
                     if strPGITotal <>'0' then
                         ExcelApp.Cells[iRow,4].Value := strPGITotal;
                     if StrDMylarTotal <>'0' then
                         ExcelApp.Cells[iRow,6].Value := StrDMylarTotal;
                     if StrNMylarTotal <>'0' then
                        ExcelApp.Cells[iRow,7].Value := StrNMylarTotal;
                     if strFPY <>'0' then
                        ExcelApp.Cells[iRow,10].Value := strFPY;
                     ExcelApp.Cells[iRow,8].Value := ExcelApp.Cells[iRow,6].Value+ExcelApp.Cells[iRow,7].Value;
                     Inc(iRow);
                     Next;
                 end;
                 ExcelApp.Cells[3,3].Value := '=SUM(C4:C'+IntToStr(AllRow)+')';
                 ExcelApp.Cells[3,4].Value := '=SUM(D4:D'+IntToStr(AllRow)+')';

                 ExcelApp.Cells[3,6].Value := '=SUM(F4:F'+IntToStr(AllRow)+')';
                 ExcelApp.Cells[3,7].Value := '=SUM(G4:G'+IntToStr(AllRow)+')';
                 
                 for j:=3 to i do
                 begin
                    ExcelApp.Cells[j,5].Value := '= D'+InttoStr(j) +'/C'+InttoStr(j);
                    ExcelApp.Cells[j,9].Value := '= H'+InttoStr(j) +'/C'+InttoStr(j);
                 end;
                 ExcelApp.Cells[3,8].Value := '=SUM(H4:H'+IntToStr(AllRow)+')' ;


                 ExcelApp.ActiveSheet.Range['E3:E'+IntToStr(AllRow)].NumberFormat:='0.00%';
                 ExcelApp.ActiveSheet.Range['I3:I'+IntToStr(AllRow)].NumberFormat:='0.00%';
                 //ExcelApp.ActiveSheet.Range['J3:J'+IntToStr(AllRow)].NumberFormat:='0.00%';

                 ExcelApp.ActiveSheet.Range['A2:P'+IntToStr(AllRow)].Font.Name :='Tahoma';
                 ExcelApp.ActiveSheet.Range['A2:P'+IntToStr(AllRow)].Font.Size :=8;
                 ExcelApp.ActiveSheet.Range['A2:P'+IntToStr(AllRow)].Borders[1].Weight := 2;
                 ExcelApp.ActiveSheet.Range['A2:P'+IntToStr(AllRow)].Borders[2].Weight := 2;
                 ExcelApp.ActiveSheet.Range['A2:P'+IntToStr(AllRow)].Borders[3].Weight := 2;
                 ExcelApp.ActiveSheet.Range['A2:P'+IntToStr(AllRow)].Borders[4].Weight := 2;
                 ExcelApp.ActiveSheet.Range['A2:P'+IntToStr(AllRow)].HorizontalAlignment :=3;
                 ExcelApp.ActiveSheet.Range['A2:P'+IntToStr(AllRow)].VerticalAlignment :=2;
                 ExcelApp.ActiveSheet.Range['K3:K'+IntToStr(AllRow)].HorizontalAlignment :=1;
                 ExcelApp.ActiveSheet.Range['E3:E'+IntToStr(AllRow)].Interior.Color := $0080FFFF;
                 ExcelApp.ActiveSheet.Range['I3:I'+IntToStr(AllRow)].Interior.Color := $0025E451;
                 ExcelApp.ActiveSheet.Range['J3:J'+IntToStr(AllRow)].Interior.Color := $00FFFF8C;

            end;

        end;

         with QryDefect do begin
             iRow :=4;
             first;
             sDefectInfo :='';
             for  i:=0 to RecordCount-1 do
             begin

                 strModel  := FieldByName('Model_Name').AsString ;
                 if i=0  then  strFirstModel := strModel;

                 if (strFirstModel <> strModel) or (i=0) then begin
                     ExcelApp.Cells[iRow,11].Value := Copy(sDefectInfo,1,length(sDefectInfo)-1);
                     for j:=4 to AllRow do begin
                        sTemp := ExcelApp.Cells[j,2].Value;
                        if   sTemp = strModel  then  begin
                             iRow :=j;
                             sDefectInfo :='';
                             Break;
                        end;
                     end;
                     strFirstModel  := strModel;
                 end;
                 strDefect :=  FieldByName('Defect_desc').AsString ;
                 strDefectQty := FieldByName('Defect_qty').AsString ;
                 strDefectRate :=  FieldByName('rate').AsString ;
                 strDefectSeq :=  FieldByName('ran').AsString ;

                 sDefectInfo := sDefectInfo +strDefectSeq+':'+ strDefect+'*'+strDefectQty+' '+strDefectRate+'%'+#10;

                 Next;
             end;


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

    DateTimePicker1.Date :=  Yesterday;
    DateTimePicker2.Date :=  Today;

end;

procedure TfDetail.DBGrid2DblClick(Sender: TObject);
begin
  //
  
end;

end.
