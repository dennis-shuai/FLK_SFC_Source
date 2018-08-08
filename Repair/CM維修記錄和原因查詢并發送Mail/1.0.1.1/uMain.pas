unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MConnect, ObjBrkr, IdComponent, IdTCPConnection, IdTCPClient,
  IdMessageClient, IdSMTP, IdBaseComponent, IdMessage, DB, DBClient,ComObj,
  SConnect,excel2000;

type
  TuMainForm = class(TForm)
    QryTemp: TClientDataSet;
    SocketConnection1: TSocketConnection;
    IdMessage1: TIdMessage;
    IdSMTP1: TIdSMTP;
    SimpleObjectBroker1: TSimpleObjectBroker;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     sFileName:string;
     function LoadApServer: Boolean;
     Procedure ExportExcel;
     function  GetSysDate:TDateTime;
     procedure QueryData(Stage:string);
     procedure QueryCMData;
     procedure SendMail(attachmentFilePath:String;AddressList:TStringList);
     procedure QueryReason(model_name:string);
     procedure QuerySMTReason(model_name:string);
  end;

var
  uMainForm: TuMainForm;

implementation

{$R *.dfm}


function TuMainForm.LoadApServer: Boolean;
var F: TextFile;
   S: string;
begin
   Result := False;
   SocketConnection1.Connected := False;
   SimpleObjectBroker1.Servers.Clear;
   SocketConnection1.Host:='';
   SocketConnection1.Address:='';
   if  FileExists(ExtractFilePath(Paramstr(0)) + 'ApServer.cfg') then
     AssignFile(F, ExtractFilePath(Paramstr(0)) + 'ApServer.cfg')
   else
     exit;
   Reset(F);
   while True do
   begin
      Readln(F, S);
      if trim(S) <> '' then
      begin
        SimpleObjectBroker1.Servers.Add;
        SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
        SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
      end else
        Break;
   end;
   CloseFile(F);
   Result := True;
end;


procedure TuMainForm.SendMail(attachmentFilePath:String;AddressList:TStringList);
var i,LowerCount:integer;
    sMaileMessage:string;
begin
  with IdSMTP1 do
    begin
      Host:='192.168.78.201';
      Port:=25;
      Username:='SFC_KS_CCM_ALERT';
      Password:='ksccmsfc';
      AuthenticationType := atLogin;
    end;

    try
      IdSMTP1.Connect;
        with IdMessage1 do
          begin
            Subject:=FormatDateTime('YYYY/MM/DD',GetSysDate-4)+'維修不良原因統計報表';
            From.Address:='MES_Sajet@foxlink.com';

            for i :=0 to  AddressList.Count-1 do begin
               Recipients.Add;
               Recipients[i].Address:= AddressList.Strings[i];
            end;

            sMaileMessage:='Dear All:'+#13+'  '+FormatDateTime('YYYY/MM/DD',GetSysDate-4)+' 維修不良原因統計報表如下:'+#13 ;

            Body.Clear;
            Body.Add(sMaileMessage);
          end;
          attachmentFilePath:=sFileName;
          if FileExists(attachmentFilePath) then
          begin
              TIdAttachment.Create(IdMessage1.MessageParts,attachmentFilePath);
          end;
      IdSMTP1.Send(IdMessage1);
    finally
        IdSMTP1.Disconnect;
        IdSMTP1.Free;
    end;
end;


Procedure TuMainForm.ExportExcel;
var i,j,k,m:integer;
    MsExcel,ChartObjects:Variant;
    pList:TStringList;
    AllDayOfMonth:Integer;
    colName:string;
    sworkdate ,sreason :string;
    srate:Double;
    sDate:Integer;
begin


    sFileName := ExtractFilePath(Paramstr(0))+'Report\'+FormatDateTime('YYYYMMDD',GetSysDate-4)+' 維修不良原因統計.xlsx';
    MsExcel :=CreateOleObject('Excel.Application');
    MsExcel.Visible := false;
    MsExcel.displayAlerts:=false;
    MsExcel.WorkBooks.Open(ExtractFilePath(Paramstr(0))+'維修不良原因統計.xltx');


    pList :=TStringList.Create;
    pList.LoadFromFile(ExtractFilePath(Paramstr(0))+'\Repair_Config.cfg');
    for j:=0 to 3 do begin
        MsExcel.WorkSheets[j+1].Activate;
        MsExcel.WorkSheets[j+1].Name :=pList.Strings[j];
        MsExcel.Cells[1,1].Value := '機種';
        MsExcel.Cells[1,2].Value := 'Serial_Number';
        MsExcel.Cells[1,3].Value := 'Customer_SN';
        MsExcel.Cells[1,4].Value := '站別';
        MsExcel.Cells[1,5].Value := '不良時間';
        MsExcel.Cells[1,6].Value := '不良現象';
        MsExcel.Cells[1,7].Value := '不良機台/纖體';
        MsExcel.Cells[1,8].Value := '測試人員';
        MsExcel.Cells[1,9].Value := '維修時間';
        MsExcel.Cells[1,10].Value := '維修人員';
        MsExcel.Cells[1,11].Value := '不良原因';
        MsExcel.Cells[1,12].Value := '維修動作';
        MsExcel.Cells[1,13].Value := '維修后測試';
        MsExcel.Cells[1,16].Value := '關聯自動機台';
        MsExcel.Columns[1].columnwidth := 15;
        MsExcel.Columns[2].columnwidth := 20;
        MsExcel.Columns[3].columnwidth := 20;
        MsExcel.Columns[4].columnwidth := 20;
        MsExcel.Columns[5].columnwidth := 20;
        MsExcel.Columns[6].columnwidth := 15;
        MsExcel.Columns[7].columnwidth := 20;
        MsExcel.Columns[8].columnwidth := 15;
        MsExcel.Columns[9].columnwidth := 20;
        MsExcel.Columns[10].columnwidth := 15;
        MsExcel.Columns[11].columnwidth := 20;
        MsExcel.Columns[12].columnwidth := 15;
        MsExcel.Columns[13].columnwidth := 15;
        if pList.Strings[j] ='CM' then
        begin
              MsExcel.Columns[14].columnwidth := 15;
              MsExcel.Columns[15].columnwidth := 15;
              MsExcel.Columns[16].columnwidth := 25;
              MsExcel.Cells[1,14].Value := 'SMT 線別';
              MsExcel.Cells[1,15].Value := '關聯機台';
              QueryCMData;
        end
        else
            QueryData(pList.Strings[j]);

        if not QryTemp.IsEmpty  then
        begin
            QryTemp.First;
            for i:=0 to QryTemp.RecordCount-1 do begin
                 Application.ProcessMessages;
                 MsExcel.Cells[2+i,1].Value := Qrytemp.FieldByName('Model_NAME').AsString;
                 MsExcel.Cells[2+i,2].Value := ''''+Qrytemp.FieldByName('Serial_number').AsString;
                 MsExcel.Cells[2+i,3].Value := Qrytemp.FieldByName('Customer_SN').AsString;
                 MsExcel.Cells[2+i,4].Value := Qrytemp.FieldByName('PROCESS_NAME').AsString;
                 MsExcel.Cells[2+i,5].Value := Qrytemp.FieldByName('REC_TIME').AsString;
                 MsExcel.Cells[2+i,6].Value := Qrytemp.FieldByName('Defect_desc').AsString;
                 MsExcel.Cells[2+i,7].Value := Qrytemp.FieldByName('PDLINE_NAME').AsString;
                 MsExcel.Cells[2+i,8].Value := Qrytemp.FieldByName('TEST_NAME').AsString;
                 MsExcel.Cells[2+i,9].Value := Qrytemp.FieldByName('REPAIR_TIME').AsString;
                 MsExcel.Cells[2+i,10].Value := Qrytemp.FieldByName('REPAIR_NAME').AsString;
                 MsExcel.Cells[2+i,11].Value := Qrytemp.FieldByName('reason_desc').AsString;
                 MsExcel.Cells[2+i,12].Value := Qrytemp.FieldByName('DUTY_DESC').AsString;
                 if Qrytemp.FieldByName('RP_STATUS').AsString ='2' then
                 MsExcel.Cells[2+i,13].Value := 'OK';
                 if Qrytemp.FieldByName('RP_STATUS').AsString ='3' then
                 MsExcel.Cells[2+i,13].Value := 'NG';
                 if  pList.Strings[j]='CM' then  begin
                    MsExcel.Cells[2+i,14].Value :=Qrytemp.FieldByName('SMT_LINE').AsString;
                    MsExcel.Cells[2+i,15].Value :=Qrytemp.FieldByName('relation_pdline').AsString;
                 end;
                 QryTemp.Next;
            end;
        end else
           i:=0;

        if  pList.Strings[j]='CM' then
        begin
            MsExcel.ActiveSheet.Range['A1:O'+IntToStr(i+1)].Borders[1].Weight := 2;
            MsExcel.ActiveSheet.Range['A1:O'+IntToStr(i+1)].Borders[2].Weight := 2;
            MsExcel.ActiveSheet.Range['A1:O'+IntToStr(i+1)].Borders[3].Weight := 2;
            MsExcel.ActiveSheet.Range['A1:O'+IntToStr(i+1)].Borders[4].Weight := 2;
            MsExcel.ActiveSheet.Range['A1:O'+IntToStr(i+1)].HorizontalAlignment :=3;
            MsExcel.ActiveSheet.Range['A1:O'+IntToStr(i+1)].VerticalAlignment :=2;
            MsExcel.ActiveSheet.Range['A1:O'+IntToStr(i+1)].Font.Size :=9;
            MsExcel.ActiveSheet.Range['A1:O'+IntToStr(i+1)].Font.Name :='tahoma';
            MsExcel.ActiveSheet.Range['A1:O1'].Interior.color :=clBlue;
        end else begin
            MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].Borders[1].Weight := 2;
            MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].Borders[2].Weight := 2;
            MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].Borders[3].Weight := 2;
            MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].Borders[4].Weight := 2;
            MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].HorizontalAlignment :=3;
            MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].VerticalAlignment :=2;
            MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].Font.Size :=9;
            MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].Font.Name :='tahoma';
            MsExcel.ActiveSheet.Range['A1:M1'].Interior.color :=clBlue;
        end;
        MsExcel.Rows[1].Font.Size :=14;
        MsExcel.Rows[1].Font.Color :=clwhite;

        MsExcel.Rows[1].Font.Bold :=true;
    end;

    for m :=0 to pList.Count-5 do begin


        MsExcel.WorkSheets[5+m].Activate;

        QuerySMTReason(pList.Strings[4+m]);
        QryTemp.First;
        for i:=0 to qrytemp.RecordCount -1 do
        begin
           sworkdate := qrytemp.fieldbyname('work_date').AsString;
           sdate := StrtoInt(Copy(sworkdate,Length(sworkdate)-1,2));

           sreason := qrytemp.fieldbyname('reason_desc').AsString;
           srate :=   qrytemp.fieldbyname('rate').AsFloat;
           for j:=3 to 8 do
           begin
              for k:=2 to 32 do
              begin
                   if ( sreason = MsExcel.Activesheet.cells[j,1].value) and
                       ( sdate =MsExcel.Activesheet.cells[2,k].value) then
                      MsExcel.Activesheet.cells[j,k] := srate;
              end;
           end;
           QryTemp.Next;
        end;

        QueryReason(pList.Strings[4+m]);
        QryTemp.First;
        for i:=0 to qrytemp.RecordCount -1 do
        begin
           sworkdate := qrytemp.fieldbyname('work_date').AsString;
           sdate := StrtoInt(Copy(sworkdate,Length(sworkdate)-1,2));

           sreason := qrytemp.fieldbyname('reason_desc').AsString;
           srate :=   qrytemp.fieldbyname('rate').AsFloat;
           for j:=25 to 29 do
           begin
              for k:=2 to 32 do
              begin
                   if ( sreason = MsExcel.Activesheet.cells[j,1].value) and
                       ( sdate =MsExcel.Activesheet.cells[2,k].value) then
                      MsExcel.Activesheet.cells[j,k] := srate;
              end;
           end;
           QryTemp.Next;
        end;

    end;

    MsExcel.ActiveWorkbook.SaveAs(sFileName);
    MsExcel.Quit;
    MsExcel :=Unassigned;

end;

procedure TuMainForm.FormShow(Sender: TObject);
var Addresslist:TStringList;
i:Integer;
begin
     LoadApServer;
     ExportExcel;
     Addresslist := TStringList.Create;
     
     {
     QryTemp.Close;
     QryTemp.Params.Clear;
     QryTemp.CommandText :='SELECT EMAIL FROM SAJET.SYS_MOBILE WHERE SEND_MAIL =''Y'' ORDER BY DEPT_NAME ';
     QryTemp.Open;
     if QryTemp.IsEmpty then exit;
     QryTemp.First;
     for i:=0 to QryTemp.RecordCount-1 do begin
        Addresslist.Add(Qrytemp.fieldbyname('EMail').AsString);
        QryTemp.Next;
     end;
     }

     Addresslist.Add('Dennis_shuai@foxlink.com');

     if sFileName <>'' then
         SendMail(sFileName,Addresslist);
     Addresslist.Free;
     Close;

end;

function TuMainForm.GetSysDate:TDateTime;
begin
    Qrytemp.Close;
    Qrytemp.CommandText := 'select SysDate from  dual';
    Qrytemp.Open;
    result := Qrytemp.fieldbyname('SYSDate').AsDateTime;
end;


procedure TuMainForm.QueryData(stage:string);
var
  start_time,end_time:string;
  iDate:TDateTime;
begin
    iDate :=GetsysDate;


    start_time := FormatDateTime('YYYY/MM/DD',iDate-4)+'08:00:00';
    end_time := FormatDateTime('YYYY/MM/DD',iDate-3)+'08:00:00';

    {
    start_time := '2016/02/29 08:00:00';
    end_time := '2016/03/01 08:00:00';
    }
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'START_TIME',ptInput);
    QryTemp.Params.CreateParam(ftstring,'END_TIME',ptInput);
    QryTemp.Params.CreateParam(ftstring,'stage',ptInput);
    QryTemp.CommandText:=  '      select  e.Model_Name,a.rec_time ,a.Serial_number,K.EMP_NAME TEST_NAME,L.EMP_NAME REPAIR_NAME, '+
                           '      g.customer_sn, p.rp_status, a.RECEIVE_TIME,f.PDLINE_NAME, '+
                           '      b.PROCESS_NAME ,b.PROCESS_CODE,C.defect_code,  h.Repair_time, '+
                           '      c.Defect_desc , j.reason_desc , M.Duty_DESC from '+
                           '      sajet.g_SN_defect a, sajet.SYS_PROCESS b, sajet.sys_defect c , sajet.sys_part d , '+
                           '      sajet.sys_Model e , sajet.sys_pdline f , sajet.g_sn_status g , sajet.g_sn_repair h ,'+
                           '      sajet.sys_reason j ,sajet.sys_emp K,sajet.sys_emp L,SAJET.SYS_DUTY M,'+
                           '       sajet.g_sn_repair_location n,SAJET.G_SN_DEFECT_FIRST P,sajet.sys_stage Q'+
                           '      where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and '+
                           '      a.rec_time >= to_date(:Start_Time, ''yyyy/mm/dd hh24:mi:ss'') '+
                           '      and a.rec_time <to_date(:End_Time, ''yyyy/mm/dd hh24:mi:ss'') '+
                           '      and a.serial_number=g.serial_number and a.RECID = h.RECID '+
                           '      and h.recid = n.recid and a.SERIAL_NUMBER =p.SERIAL_NUMBER  '+
                           '      and A.PROCESS_ID =P.PROCESS_ID AND a.WORK_ORDER =p.work_order  '+
                           '      and a.stage_id =Q.stage_id and Q.Stage_name =:stage '+
                           '      and n.reason_id  =j.reason_id and a.serial_number = h.serial_number '+
                           '      and a.TEST_EMP_ID =K.EMP_ID and n.Update_UserID = L.EMP_ID '+
                           '      and h.Duty_ID =m.DUTY_ID and b.PROCESS_NAME <> ''REPAIR_TEST'' '+
                           '      and a.MOdel_ID=d.Part_ID and e.MOdel_ID =d.Model_ID and  a.pdline_id =f.pdline_ID ' +
                           '      order by Model_Name,PROCESS_CODE,serial_number, rec_time ';
    QryTemp.Params.ParamByName('Stage').AsString := Stage;
    QryTemp.Params.ParamByName('START_TIME').AsString := start_time;
    QryTemp.Params.ParamByName('END_TIME').AsString := end_time;
    QryTemp.Open;


end;

procedure TuMainForm.QueryCMData;
var
  start_time,end_time:string;
  iDate:TDateTime;
begin
    iDate :=GetsysDate;


    start_time := FormatDateTime('YYYY/MM/DD',iDate-4)+' 08:00:00';
    end_time := FormatDateTime('YYYY/MM/DD',iDate-3)+' 08:00:00';

    {
    start_time := '2016/02/29 08:00:00';
    end_time := '2016/03/01 08:00:00';
    }
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'START_TIME',ptInput);
    QryTemp.Params.CreateParam(ftstring,'END_TIME',ptInput);
    QryTemp.CommandText:= ' select  e.Model_Name,a.rec_time ,a.Serial_number,K.EMP_NAME TEST_NAME,L.EMP_NAME REPAIR_NAME,'+
                           ' g.customer_sn, p.rp_status, a.RECEIVE_TIME,f.PDLINE_NAME,'+   //--D1.PDLINE_NAME RETEST_LINE, '+
                           ' b.PROCESS_NAME ,b.PROCESS_CODE,C.defect_code,  h.Repair_time,c1.pdline_name relation_pdline, '+
                           ' c.Defect_desc , j.reason_desc , M.Duty_DESC,D1.PDLINE_NAME SMT_LINE   '+
                           ' from sajet.g_SN_defect a, sajet.SYS_PROCESS b, sajet.sys_defect c , sajet.sys_part d , '+
                           ' sajet.sys_Model e , sajet.sys_pdline f , sajet.g_sn_status g , sajet.g_sn_repair h , '+
                           ' sajet.sys_reason j ,sajet.sys_emp K,sajet.sys_emp L,SAJET.SYS_DUTY M,    '+
                           ' sajet.g_sn_repair_location n,SAJET.G_SN_DEFECT_FIRST P,sajet.sys_stage Q, '+
                           ' ( select R.serial_number, t.pdline_name from SAJET.G_SN_TRAVEL R,sajet.sys_pdline t'+
                           ' where r.pdline_id = t.pdline_id and R.PROCESS_ID = 100185   ) D1,   '+
                           ' (select a1.terminal_id,b1.pdline_name from SAJET.sys_terminal a1,SAJET.sys_pdline b1'+
                           ' where a1.pdline_id = b1.pdline_id ) C1   '+
                           ' where A.DEFECT_ID  = C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and  '+
                           ' a.rec_time >= to_date(:start_time, ''yyyy/mm/dd hh24:mi:ss'')  '+
                           ' and a.rec_time <to_date(:end_time, ''yyyy/mm/dd hh24:mi:ss'')'+
                           ' and a.serial_number=g.serial_number and a.RECID = h.RECID    '+
                           ' and h.recid = n.recid and a.SERIAL_NUMBER =p.SERIAL_NUMBER   '+
                           ' and A.PROCESS_ID =P.PROCESS_ID AND a.WORK_ORDER =p.work_order   '+
                           ' and a.stage_id =Q.stage_id and Q.Stage_name = ''CM''         '+
                           ' and n.reason_id  =j.reason_id and a.serial_number = h.serial_number '+
                           ' and a.TEST_EMP_ID =K.EMP_ID and n.Update_UserID = L.EMP_ID '+
                           ' and h.Duty_ID =m.DUTY_ID and b.PROCESS_NAME <> ''REPAIR_TEST''  '+
                           ' and a.Model_ID=d.Part_ID and e.Model_ID =d.Model_ID and  p.pdline_id =f.pdline_ID '+
                           ' and a.Serial_number = D1.serial_number(+) '+
                           ' and n.relation_terminal = c1.terminal_id(+) '+
                           ' order by Model_Name,PROCESS_CODE,serial_number, repair_time ';
    QryTemp.Params.ParamByName('START_TIME').AsString := start_time;
    QryTemp.Params.ParamByName('END_TIME').AsString := end_time;
    QryTemp.Open;


end;

procedure TuMainForm.QuerySMTReason(model_name:string);
var start_time,end_time,starttime,endtime:string;
iDate:TDateTime;
begin

    iDate :=GetsysDate;

    start_time :=   FormatDateTime('YYYYMM',iDate-4)+'01 08:00:00';
    end_time :=FormatDateTime('YYYYMMDD',iDate-3)+' 08:00:00';;
    starttime := FormatDateTime('YYYYMM',iDate-4)+'0108';
    endtime :=FormatDateTime('YYYYMMDD',iDate-3)+'08';

    {
    start_time := '20160201 08:00:00';
    end_time := '20160301 08:00:00';
    starttime := '2016020108';
    endtime :='2016030108';
     }

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'START_TIME',ptInput);
    QryTemp.Params.CreateParam(ftstring,'END_TIME',ptInput);
    QryTemp.Params.CreateParam(ftstring,'STARTTIME',ptInput);
    QryTemp.Params.CreateParam(ftstring,'ENDTIME',ptInput);
    //QryTemp.Params.CreateParam(ftstring,'Model_Name',ptInput);
    QryTemp.CommandText:= ' select  aa.reason_Desc,aa.work_date ,aa.qty,bb.total_qty ,round(aa.qty/bb.total_qty*100,3) rate  from '+
                        ' (select  reason_id,reason_Desc,process_id ,work_date,count(*) qty from (select f.model_name,c.reason_id,d.Process_id,    '+
                        ' d.serial_number, c.reason_Desc,SAJET.SJ_GET_TIME_DATE(d.rec_time) work_date  from SAJET.G_SN_REPAIR a, '+
                        ' SAJET.G_SN_REPAIR_LOCATION b,SAJET.SYS_REASON c ,SAJET.G_SN_DEFECT d,sajet.sys_part e,sajet.sys_model f     '+
                        ' where A.RECID =B.RECID and B.REASON_ID =C.REASON_ID and A.RECID =D.RECID and d.process_id In (100189,100249) '+
                        ' and A.MODEL_ID =E.PART_ID and E.MODEL_ID =f.model_id and f.model_name like '''+model_Name+'%'''+
                        ' and d.rec_time>=to_date(:start_time,''YYYYMMDD HH24:MI:SS'') and  d.rec_time < to_date(:end_time,''YYYYMMDD HH24:MI:SS'')) group by '+
                        ' reason_id,reason_Desc,process_id,work_date  ) aa,( select process_id,work_Date,sum(pass_qty+fail_qty) total_qty from  '+
                        ' (select c.model_name,process_id,pass_qty,fail_qty,'+
                        '  SAJET.SJ_GET_TIME_DATE(to_date(a.work_date||Trim(to_char(a.work_time,''00'')),''YYYYMMDDHH24''))  work_DATE '+
                        ' from sajet.g_sn_count a,sajet.sys_part b ,sajet.sys_model c     '+
                        '  where  a.work_date||Trim(to_char(a.work_time,''00'')) >= :startTime and a.work_date||Trim(to_char(a.work_time,''00'')) '+
                        ' <:endTime  and process_id in (100189,100249) and a.model_id=b.part_id and b.model_id =c.model_id and c.model_name '+
                        ' like '''+model_Name+'%''    )  group by process_id,work_Date ) bb                         '+
                        ' where aa.process_id =bb.Process_ID and aa.work_date=bb.work_date and bb.total_qty >200 order by work_date ' ;
    QryTemp.Params.ParamByName('START_TIME').AsString := start_time;
    QryTemp.Params.ParamByName('END_TIME').AsString := end_time;
    QryTemp.Params.ParamByName('STARTTIME').AsString := starttime;
    QryTemp.Params.ParamByName('ENDTIME').AsString := endtime;
   // QryTemp.Params.ParamByName('Model_Name').AsString := model_name;
    QryTemp.Open;


end;

procedure TuMainForm.QueryReason(model_name:string);
var start_time,end_time,starttime,endtime:string;
iDate:TDateTime;
begin

    iDate :=GetsysDate;

    start_time :=   FormatDateTime('YYYYMM',iDate-4)+'01 08:00:00';
    end_time :=FormatDateTime('YYYYMMDD',iDate-3)+' 08:00:00';;
    starttime := FormatDateTime('YYYYMM',iDate-4)+'0108';
    endtime :=FormatDateTime('YYYYMMDD',iDate-3)+'08';

    {
    start_time := '20160201 08:00:00';
    end_time := '20160301 08:00:00';
    starttime := '2016020108';
    endtime :='2016030108';
     }
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'START_TIME',ptInput);
    QryTemp.Params.CreateParam(ftstring,'END_TIME',ptInput);
    QryTemp.Params.CreateParam(ftstring,'STARTTIME',ptInput);
    QryTemp.Params.CreateParam(ftstring,'ENDTIME',ptInput);
    QryTemp.Params.CreateParam(ftstring,'Model_Name',ptInput);
    QryTemp.CommandText:= ' select  aa.reason_Desc,aa.work_date ,aa.qty,bb.total_qty ,round(aa.qty/bb.total_qty*100,3) rate  from '+
                        ' (select  reason_id,reason_Desc,process_id ,work_date,count(*) qty from (select f.model_name,c.reason_id,d.Process_id,    '+
                        ' d.serial_number, c.reason_Desc,SAJET.SJ_GET_TIME_DATE(d.rec_time)  work_date  from SAJET.G_SN_REPAIR a, '+
                        ' SAJET.G_SN_REPAIR_LOCATION b,SAJET.SYS_REASON c ,SAJET.G_SN_DEFECT d,sajet.sys_part e,sajet.sys_model f     '+
                        ' where A.RECID =B.RECID and B.REASON_ID =C.REASON_ID and A.RECID =D.RECID and d.process_id In (100266,100215,100197,100241) '+
                        ' and A.MODEL_ID =E.PART_ID and E.MODEL_ID =f.model_id and f.model_name like :model_name '+
                        ' and d.rec_time>=to_date(:start_time,''YYYYMMDD HH24:MI:SS'') and  d.rec_time < to_date(:end_time,''YYYYMMDD HH24:MI:SS'')) group by '+
                        ' reason_id,reason_Desc,process_id,work_date  ) aa,( select process_id,work_Date,sum(pass_qty+fail_qty) total_qty from  '+
                        ' (select c.model_name,process_id,pass_qty,fail_qty,'+
                        ' SAJET.SJ_GET_TIME_DATE(to_date(a.work_date||Trim(to_char(a.work_time,''00'')),''YYYYMMDDHH24''))  work_DATE '+
                        ' from sajet.g_sn_count a,sajet.sys_part b ,sajet.sys_model c     '+
                        '  where  a.work_date||Trim(to_char(a.work_time,''00'')) >= :startTime and a.work_date||Trim(to_char(a.work_time,''00'')) '+
                        ' <:endTime  and process_id in (100266,100215,100197,100241) and a.model_id=b.part_id and b.model_id =c.model_id and c.model_name '+
                        ' like  :model_name    )  group by process_id,work_Date ) bb                         '+
                        ' where aa.process_id =bb.Process_ID and aa.work_date=bb.work_date and bb.total_qty >200 order by work_date ' ;
    QryTemp.Params.ParamByName('START_TIME').AsString := start_time;
    QryTemp.Params.ParamByName('END_TIME').AsString := end_time;
    QryTemp.Params.ParamByName('STARTTIME').AsString := starttime;
    QryTemp.Params.ParamByName('ENDTIME').AsString := endtime;
    QryTemp.Params.ParamByName('Model_Name').AsString := model_name+'%';
    QryTemp.Open;
    //if QryTemp.Isempty then MessageDlg('empty',mtError,[mbOK],0);


end;

end.
