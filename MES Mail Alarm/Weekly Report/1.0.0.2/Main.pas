unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DB, DBClient, MConnect, SConnect, ObjBrkr, ComObj,
  IdComponent, IdTCPConnection, IdTCPClient, IdMessageClient, IdSMTP,
  IdBaseComponent, IdMessage,Excel2000,DateUtils, StdCtrls;

type
  TuMainForm = class(TForm)
    SimpleObjectBroker1: TSimpleObjectBroker;
    SocketConnection1: TSocketConnection;
    Qrytemp: TClientDataSet;
    Timer1: TTimer;
    IdMessage1: TIdMessage;
    IdSMTP1: TIdSMTP;
    SaveDialog1: TSaveDialog;
    QryDate: TClientDataSet;
    QryDefect: TClientDataSet;
    QryTemp2: TClientDataSet;
    QryTemp3: TClientDataSet;
    QryData1: TClientDataSet;
    QryModel: TClientDataSet;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    QryTemp4: TClientDataSet;
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
      sModelName,sFileName,sStartTime,sEndTime,sDStartTIme,sDEndTime,sAllProcess:string;
      StartTime_List,EndTime_list,TotalTarget_List,TotalSPY_List,TotalModel_list,Week_List:TStringList;
      function LoadApServer : Boolean;
      function GetSysDate:TDatetime;
      procedure SendMail(attachmentFilePath:String;AddressList:TStringList);
      procedure QueryModel(QryTemp1:TClientDataset;StartTime,EndTime:string);
      function  QueryOutput(QryTemp1:TClientDataset;StartTime,EndTime:String):boolean;
      function  QueryDefect(QryTemp1:TClientDataset;StartTime:String;EndTime:String;PROCESS_NAME:string):boolean;
      function  QueryDefectCode(QryTemp1:TClientDataset;StartTime:String;EndTime:String;PROCESS_NAME:string):boolean;
      function  QueryProcessName(QryTemp1:TClientDataset;StartTime:String;EndTime:String):boolean;
      function  GetDateTimeList():boolean;
      procedure QueryTop3DEFECTCode(QryTemp4:TClientDataSet;Start_Time,End_Time:string);
      procedure QueryTop3DEFECTYield(QryTemp4:TClientDataSet;START_DATE,END_DATE,Start_Time,End_Time,ALL_Defect_Code:string);
     // function  GetTop3Code(QryTemp:TClientDataSet;Start_Time,End_Time:string):string;
      procedure ExportReport;
      procedure SendSettingMail(sMessage:string);
 end;

var
  uMainForm: TuMainForm;

implementation

{$R *.dfm}


function TuMainForm.LoadApServer : Boolean;
var
  F : TextFile;
  S : String;
begin
  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  If not FileExists(GetCurrentDir+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,GetCurrentDir+'\ApServer.cfg');
  Reset(F);
  While True do
  begin
    Readln(F, S);
    If S <> '' Then
    begin
      SimpleObjectBroker1.Servers.Add;
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
    end Else
      Break;
  end;
  CloseFile(F);
  Result := True;
end;

function TuMainForm.GetDateTimeList():boolean;
var  i,Year,Month,Week,tempWeek:integer;
     LastMonth,MonthFirst,WeekFirst,tempFirst:TDateTime;
begin
    LastMonth := incmonth(Getsysdate,-1) ;
    Year := StrToInt(FormatDateTime('YYYY',LastMonth));
    Month := StrToInt(FormatDateTime('MM',LastMonth));

    sStartTime := FormatDateTime('YYYYMMDD',StartofAMonth(Year,Month)) + '08' ;
    sEndTime := FormatDateTime('YYYYMMDDHH',Getsysdate) ;

    sDStartTime :=sStartTime +':00:00';
    sDEndTime := sEndTime + ':00:00';
    StartTime_List := TStringList.Create;
    EndTime_list := TStringLIst.Create;
    Week_List :=   TStringLIst.Create;
    StartTime_List.Add(sStartTime);
    EndTime_list.Add( FormatDateTime('YYYYMM',Getsysdate)+'0108' );
    Week_list.Add( IntToStr(Month)+'月');
    //本周第一天
    WeekFirst:=StartoftheWeek(Getsysdate);
    // 本月第一天
    MonthFirst := StartOfTheMonth( Getsysdate);
   // Week :=WeekoftheYear(Getsysdate);

    tempFirst := MonthFirst;

    Year := StrToInt(FormatDateTime('YYYY',GetSysDate));
    Month := StrToInt(FormatDateTime('MM',GetSysDate));
    while tempFirst< weekFirst do begin
         tempWeek := WeekoftheYear(tempFirst);
         Week_list.Add('W'+IntToStr(tempWeek));
         StartTime_List.Add(FormatDateTime('YYYYMMDD', StartOfAWeek(Year,tempWeek))+'08');
         EndTime_List.Add(FormatDateTime('YYYYMMDD', EndOfAWeek(Year,tempWeek)+1)+'08');
         tempFirst :=tempFirst+7;
    end;

    if  WeekoftheYear(tempFirst) =  WeekoftheYear(WeekFirst) then begin
       tempFirst := WeekFirst;
        while tempFirst<GetsysDate-1 do begin
            StartTime_List.Add(FormatDateTime('YYYYMMDD', tempFirst)+'08');
            EndTime_List.Add(FormatDateTime('YYYYMMDD', tempFirst +1)+'08');
            Week_list.Add(FormatDateTime('YYYY/MM/DD', tempFirst)) ;
            tempFirst :=  tempFirst+1;
        end;
        if  DateTostr(tempFirst) = DateTostr(GetsysDate)  then  begin
            StartTime_List.Add(FormatDateTime('YYYYMMDD', tempFirst)+'08');
            EndTime_List.Add(FormatDateTime('YYYYMMDD', tempFirst )+'20');
            Week_list.Add(FormatDateTime('YYYY/MM/DD', tempFirst)) ;
            tempFirst :=  tempFirst+1;
        end;
    end;

    memo1.Lines.AddStrings(StartTime_List);
    memo2.Lines.AddStrings(EndTime_List);
    memo3.Lines.AddStrings(Week_list);
  
end;

function TuMainForm.GetSysDate:TDateTime;
begin
    QryDate.Close;
    QryDate.CommandText := 'select SysDate from  dual';
    QryDate.Open;
    result := QryDate.fieldbyname('SYSDate').AsDateTime;
end;

procedure TuMainForm.FormShow(Sender: TObject);
var Addresslist:TStringList;
    i:integer;
begin
     LoadApServer;
     Qrytemp.ProviderName := 'DspQryTemp1';
     Qrytemp2.ProviderName := 'DspQryTemp1';
     Qrytemp3.ProviderName := 'DspQryTemp1';
     Qrytemp4.ProviderName := 'DspQryTemp1';
     QryDate.ProviderName := 'DspQryTemp1';
     QryDefect.ProviderName := 'DspQryData1';
     QryData1.ProviderName := 'DspQryData1';
     QryModel.ProviderName := 'DspQryData1';

     GetDateTimeList();

     ExportReport;
     Addresslist := TStringList.Create;

     QryTemp.Close;
     QryTemp.Params.Clear;
     QryTemp.CommandText :='SELECT EMAIL FROM SAJET.SYS_MOBILE WHERE SEND_DAILY_MAIL =''Y'' ORDER BY DEPT_NAME ';
     QryTemp.Open;
     if QryTemp.IsEmpty then exit;
     QryTemp.First;
     for i:=0 to QryTemp.RecordCount-1 do begin
        Addresslist.Add(Qrytemp.fieldbyname('EMail').AsString);
        QryTemp.Next;
     end;

     //Addresslist.Add('Dennis_shuai@foxlink.com');
     if sFileName <>'' then
         SendMail(sFileName,Addresslist);

     Addresslist.Free;

     Close;


end;
procedure TuMainForm.QueryModel(QryTemp1:TClientDataset;StartTime,EndTime:string);
begin

    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.CommandText :='select DISTINCT(C.MODEL_NAME)   from (  select * from ( '+
                        '  select model_ID ,PROCESS_ID,max(Pass_qty) Pass_qty from ( '+
                        '  Select MODEL_ID,PROCESS_ID,SUM(Pass_qty) Pass_qty from (select  MODEL_ID,PROCESS_ID, '+
                        '  to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime  ,pass_qty '+
                        '  from SAJET.G_SN_COUNT where WORK_ORDER NOT LIKE ''RM%'' and (PDLINE_ID <11525 OR PDLINE_ID>11534) ) '+
                        '  where DATETIME >= :STARTTIME AND DATETIME<=:ENDTIME '+
                        '  group by model_id,Process_Id  )  group by model_ID ,PROCESS_ID) where Pass_qty>200 ) A, SAJET.SYS_PART B, '+
                        '  SAJET.SYS_MODEL C,SAJET.SYS_PROCESS D Where A.MODEL_ID =B.PART_ID AND B.MODEL_ID '+
                        '  =C.MODEL_ID  AND D.PROCESS_CODE IS NOT NULL AND A.PROCESS_ID =D.PROCESS_ID  ORDER BY C.MODEL_NAME  ';
    QryTemp1.Params.ParamByName('StartTime').AsString := StartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   EndTime;
    QryTemp1.Open;

end;

function TuMainForm.QueryOutput(QryTemp1:TClientDataset;StartTime,EndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Model_NAme',ptInput);
    QryTemp1.CommandText:=' Select * from (Select B.PROCESS_NAME, B.PROCESS_CODE,  '+
                          ' DECODE((SUM(C.PASS_QTY)), NULL, 0, (SUM(C.PASS_QTY))) FPY_QTY ,  '+
                          ' DECODE((SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.FAIL_QTY))) FAIL_QTY, '+
                          ' DECODE((SUM(C.OUTPUT_QTY)), NULL, 0, (SUM(C.OUTPUT_QTY))) Output_QTY, '+
                          ' DECODE((SUM(C.NTF_QTY)), NULL, 0, (SUM(C.NTF_QTY))) NTF_QTY,  '+
                          ' DECODE((SUM(C.REPAIR_QTY)), NULL, 0, (SUM(C.REPAIR_QTY))) REPAIR_QTY, '+
                          ' DECODE((SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY))) TOTAL_QTY , '+
                          ' round(DECODE(SUM(C.PASS_QTY),  NULL, 0,SUM(C.PASS_QTY)) / DECODE(SUM(C.PASS_QTY) +SUM(C.FAIL_QTY), NULL, 0,0,1000000000, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)))*100,2)  as "FPY(%)" , '+
                          ' round( DECODE( SUM(C.PASS_QTY) +SUM(C.NTF_QTY), NULL, 0,0,1, SUM(C.PASS_QTY) +SUM(C.NTF_QTY) )  / DECODE(  SUM(C.PASS_QTY+C.FAIL_QTY), NULL, 0,0,100000000 ,(SUM(C.PASS_QTY +C.FAIL_QTY)))*100,2) as "SPY(%)" '+
                          ' FROM   SAJET.SYS_PROCESS B , '+
                          ' (select WORK_ORDER,MODEL_ID,STAGE_ID,PDLINE_ID,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REFAIL_QTY,OUTPUT_QTY,NTF_QTY,REPAIR_QTY, '+
                          ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00'')))   DateTime  '+
                          ' from SAJET.G_SN_COUNT where WORK_ORDER LIKE ''%MS%'' and PASS_QTY +FAIL_QTY <>0 AND STAGE_ID =10001  '+
                          ' AND to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00'')))   >=:StartTime '+
                          ' and to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00'')))   <:endTime '+
                          ' union                                                                 '+
                          ' select WORK_ORDER,MODEL_ID,STAGE_ID,PDLINE_ID,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REFAIL_QTY,OUTPUT_QTY,NTF_QTY,REPAIR_QTY, '+
                          ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00'')))   DateTime   '+
                          ' from SAJET.G_SN_COUNT where WORK_ORDER LIKE ''NMC%'' and PASS_QTY +FAIL_QTY <>0 AND STAGE_ID =10023  '+
                          ' AND to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00'')))   >=:StartTime   '+
                          ' and to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00'')))   <:endTime   '+
                          ' union                                                            '+
                          ' select WORK_ORDER,MODEL_ID,STAGE_ID,PDLINE_ID,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REFAIL_QTY,OUTPUT_QTY,NTF_QTY,REPAIR_QTY, '+
                          ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00'')))   DateTime  '+
                          ' from SAJET.G_SN_COUNT where (WORK_ORDER LIKE ''NMA%'' or WORK_ORDER LIKE ''VMA%'') and PASS_QTY +FAIL_QTY <>0 AND PROCESS_ID NOT IN(100219, 100220,100221,100243,100263)'+
                          ' AND to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00'')))   >=:StartTime and (PDLINE_ID <11525 OR PDLINE_ID>11534)'+
                          ' and to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00'')))   <:endTime )  C ,sajet.sys_part d ,sajet.sys_Part e,sajet.sys_model f'+
                          ' WHERE   C.DateTime >=:StartTime and C.DateTime <:endTime   AND '+
                          ' c.model_ID =d.Part_ID and C.Model_ID = E.Part_ID and e.Model_ID= f.Model_ID and f.MOdel_Name =:Model_Name and B.PROCESS_CODE IS NOT NULL and '+
                          ' C.PROCESS_ID = B.PROCESS_ID GROUP BY B.PROCESS_NAME, B.PROCESS_CODE ORDER BY B.PROCESS_CODE ) where Process_name IN '+sAllProcess;

    QryTemp1.Params.ParamByName('StartTime').AsString := StartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   EndTime;
    QryTemp1.Params.ParamByName('Model_Name').AsString :=  sModelName;
    QryTemp1.Open;
end;



function TuMainForm.QueryDefect(QryTemp1:TClientDataset;StartTime:String;EndTime:String;PROCESS_NAME:string):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Model_NAme',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'PROCESS_NAme',ptInput);
    QryTemp1.CommandText:= 'SELECT ALL_DEFECT,SUM(C_SN) C_SN FROM  ' +
                           ' (SELECT  DECODE( SUBSTR( DECODE(DEFECT_CODE,''SFR64'',''FOVT01'',''SFR63'',''FOVT01'',DEFECT_CODE),1,3) ,''SFR'',''SFR'', ' +
                           '    DECODE(DEFECT_CODE,''SFR63'',''FOVT01'',DEFECT_CODE)) ALL_DEFECT,  C_SN '+
                           '    FROM  '+
                           '    ( select  a.WORK_ORDER, a.Serial_number,B.PROCESS_NAME ,b.Process_Code, C.Defect_Code, c.Defect_desc,1 as C_SN   '+
                                   ' from                   '+
                                   ' sajet.g_SN_defect_first a,sajet.SYS_PROCESS b,sajet.sys_defect c ,sajet.sys_part d , sajet.sys_Model e  '+
                                   ' where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyymmddhh24:mi:ss'')  '+
                                   ' and a.REC_Time <to_date(:EndTime, ''yyyymmddhh24:mi:ss'')   and a.ntf_time is null and a.WORK_ORDER NOT LIKE ''RM%'' '+
                                   ' and (PDLINE_ID <11525 OR PDLINE_ID>11534) '+
                                   ' and a.MOdel_ID=d.Part_ID and e.MOdel_ID =d.Model_ID and e.Model_Name =:Model_Name  AND B.PROCESS_NAME=:PROCESS_NAME'+
                                   ' group by A.WORK_ORDER, B.PROCESS_NAME ,b.Process_Code, C.defect_Code, c.Defect_desc ,a. Serial_number )  '+
                           ' )    '+
                           ' GROUP BY  ALL_DEFECT ';
    QryTemp1.Params.ParamByName('StartTime').AsString := StartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := EndTime;
    QryTemp1.Params.ParamByName('Model_Name').AsString :=   sModelName;
    QryTemp1.Params.ParamByName('PROCESS_Name').AsString :=   PROCESS_NAME;
    QryTemp1.Open;

end;

function TuMainForm.QueryDefectCode(QryTemp1:TClientDataset;StartTime:String;EndTime:String;PROCESS_NAME:string):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Model_NAme',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Process_Name',ptInput);
    QryTemp1.CommandText:= 'Select aa.defect_CODE,bb.DEFECT_DESC from (SELECT Distinct( DECODE( SUBSTR( DECODE(C.DEFECT_CODE,''SFR63'',''FOVT01'',C.DEFECT_CODE),1,3) '+
                           ' ,''SFR'',''SFR'' , ' +
                           ' DECODE(C.DEFECT_CODE,''SFR63'',''FOVT01'',C.DEFECT_CODE)) ) DEFECT_CODE '+
                           ' FROM SAJET.G_SN_DEFECT_FIRST A,SAJET.SYS_PROCESS B,SAJET.SYS_DEFECT C,SAJET.SYS_PART D,SAJET.SYS_MODEL E '+
                           ' WHERE A.PROCESS_ID=B.PROCESS_ID AND B.PROCESS_NAME=:PROCESS_NAME AND A.DEFECT_ID=C.DEFECT_ID  AND A.NTF_TIME IS NULL AND A.WORK_ORDER NOT LIKE ''RM%'' '+
                           ' AND A.REC_TIME>=to_date(:StartTime,''yyyymmddHH24:mi:ss'') AND A.REC_TIME < to_date(:EndTime,''yyyymmddHH24:MI:SS'') '+
                           ' and (PDLINE_ID <11525 OR PDLINE_ID>11534) '+
                           ' AND E.MODEL_NAME=:Model_NAme AND A.MODEL_ID=D.PART_ID AND D.MODEL_ID =E.MODEL_ID ) aa,sajet.sys_defect bb '+
                           ' where aa.DEFECT_COde=bb.DEFECT_CODE';
    QryTemp1.Params.ParamByName('StartTime').AsString := StartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := EndTime;
    QryTemp1.Params.ParamByName('Model_Name').AsString := sModelName;
    QryTemp1.Params.ParamByName('Process_Name').AsString :=PROCESS_NAME;
    QryTemp1.Open;

end;

function TuMainForm.QueryProcessName(QryTemp1:TClientDataset;StartTime:String;EndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Model_NAme',ptInput);
    QryTemp1.CommandText:= ' SELECT * FROM (SELECT B.PROCESS_NAME,B.PROCESS_CODE,SUM(FAIL_QTY)  PROCESS_FAIL, SUM(PASS_QTY) PROCESS_PASS  FROM ( select MODEL_ID,PROCESS_ID, '+
                           ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  WORK_DATE ,FAIL_QTY,PASS_QTY '+
                           ' from SAJET.G_SN_COUNT where WORK_ORDER NOT LIKE ''RM%'' and PASS_QTY + FAIL_QTY <> 0 and (PDLINE_ID <11525 OR PDLINE_ID>11534) )'+
                           ' A,SAJET.SYS_PROCESS B, SAJET.SYS_PART C,SAJET.SYS_MODEL D '+
                           ' WHERE A.PROCESS_ID=B.PROCESS_ID AND A.WORK_DATE>=:StartTime AND A.WORK_DATE <= :EndTime  AND '+
                           ' A.MODEL_ID=C.PART_ID AND C.MODEL_ID =D.MODEL_ID AND D.MODEL_NAME=:Model_NAme  AND B.PROCESS_CODE IS NOT NULL '+
                           ' GROUP BY B.PROCESS_NAME,B.PROCESS_CODE ORDER BY PROCESS_CODE ) WHERE PROCESS_PASS>200';
    QryTemp1.Params.ParamByName('StartTime').AsString := StartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := EndTime;
    QryTemp1.Params.ParamByName('Model_Name').AsString := sModelName;
    QryTemp1.Open;
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
            Subject:='每日週報->'+FormatDateTime('YYYY/MM/DD',GetSysDate)+' 生產周報表(廠內數據)';
            From.Address:='MES_Sajet@foxlink.com';

            for i :=0 to  AddressList.Count-1 do begin
               Recipients.Add;
               Recipients[i].Address:= AddressList.Strings[i];
            end;
            if FormatDateTime('HH',GetSysDate) <= '08' then
                sMaileMessage:='Dear All:'+#13+'  '+FormatDateTime('YYYY/MM/DD',GetSysDate-1)+' 各機種周生產報表'+#13
            else
                sMaileMessage:='Dear All:'+#13+'  '+FormatDateTime('YYYY/MM/DD',GetSysDate)+' 各機種周生產報表'+#13;
             sMaileMessage:= sMaileMessage+'    未達標明細如下:'+#13+'      ';
            LowerCount :=0;
            for i:=0 to TotalModel_List.Count-1 do begin

                  if  StrToFloat( TotalTarget_List.Strings[i]) >   StrToFloat( TotalSPY_List.Strings[i]) then begin

                      sMaileMessage :=    sMaileMessage+  TotalModel_List.Strings[i]+'機種      目標直通率:'+
                                        TotalTarget_List.Strings[i] +'%    實際直通率:'+  TotalSPY_List.Strings[i]+'%'+#13+'      ';
                      LowerCount :=    LowerCount+1;
                  end;
            end;
            if   LowerCount =0 then begin
                  sMaileMessage :=    sMaileMessage + ' 所有機種都達標 ';
            end;
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


procedure TuMainForm.SendSettingMail(sMessage:string);
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
            Subject:='沒有設置機種目標良率';
            From.Address:='MES_Sajet@foxlink.com';


            Recipients.Add;
            Recipients[0].Address:= 'Mary_tao@Foxlink.com';
            Recipients.Add;
            Recipients[1].Address:= 'PH_Gao@Foxlink.com';
            Recipients.Add;
            Recipients[2].Address:= 'Ted_Zhu@Foxlink.com';
            Recipients.Add;
            Recipients[3].Address:= 'Dennis_shuai@Foxlink.com';

            Body.Clear;
            Body.Add(sMessage);
          end;
         // attachmentFilePath:=sFileName;
           
      IdSMTP1.Send(IdMessage1);
    finally
        IdSMTP1.Disconnect;
        IdSMTP1.Free;
    end;
end;


procedure TuMainForm.ExportReport;
var
    strNTF :string;
    strTitle,strFPY,strPDline,strPDLineFrist,strRepass,strTotal,strDefectName,strDefect_QTY,strDefect_Desc,strFailAll,sDefect_Code :string;
    i,j,K,L,M,FirstCount,UsedRow,AllRows,UsedHours,defect_count,count,HourCount,Repair_Qty,Process_Fail:integer;
    ExcelApp,xRange,yRange,ChartObjects: Variant;
    tempStart,tempEnd,tempHStart,tempHEnd,sProcess,FPY_Target,sXValue:string;
    Rowlist,SPYRowlist,FinalRowList :TStringList;
    FPY,SPY,FinalYield, Total_FPY,Total_SPY,Total_FinalYield:double;
    IsFound :boolean;
    Defect_Start,Defect_End:TDateTime;
    sDefect_Start,sDefect_End,sAll_Defect:String;
begin
    QueryModel(QryModel, FOrmatDateTime('YYYYMMDD',today)+'08' , FOrmatDateTime('YYYYMMDD',today)+'20');
    if QryModel.IsEmpty then exit;

    Application.ProcessMessages();
    ExcelApp :=CreateOleObject('Excel.Application');
    ExcelApp.Visible := false;
    ExcelApp.displayAlerts:=false;
    ExcelApp.WorkBooks.Add;
    QryModel.First;
    TotalModel_List :=TStringList.Create;
    TotalTarget_List := TStringList.Create;
    TotalSPY_List := TStringList.Create;

    for i:=0 to QryModel.RecordCount-1 do begin
         sModelName := QryModel.FieldbyName('Model_Name').AsString;
         ExcelApp.Worksheets.Add(After:=ExcelApp.Sheets[i+1]);
         ExcelApp.WorkSheets[i+1].Activate;
         //設置表格名稱
         ExcelApp.WorkSheets[i+1].Name := sModelName;
         //設置標題
         ExcelApp.Cells[1,1].Value :=  sModelName +' Weekly Report';
         ExcelApp.Cells[1,1].Font.Size := 18;
         ExcelApp.Cells[1,1].Font.Name := 'Tahoma';
         ExcelApp.Cells[1,1].Font.Bold := false;
         ExcelApp.Cells[1,1].Font.Color :=clwhite;
         ExcelApp.Cells[1,1].Interior.Color :=rgb(0,32,96);
         ExcelApp.Rows[1].RowHeight :=28;
         ExcelApp.Range['A1:P1'].Merge;

         ExcelApp.ActiveSheet.Range['D15:P15'].Font.Bold :=true;
         ExcelApp.ActiveSheet.Range['D15:P15'].Font.Color :=clwhite;
         ExcelApp.ActiveSheet.Range['D15:P15'].Interior.Color :=rgb(155,187,90);

         ExcelApp.Cells[16,4].Value := 'Target(%)';
         ExcelApp.Cells[17,4].Value := 'FPY(%)';
         ExcelApp.Cells[18,4].Value := 'SPY(%)';
         ExcelApp.Cells[19,4].Value := 'Final Yield(%)';
         //設置列寬
         ExcelApp.Columns[1].ColumnWidth :=12.5;
         ExcelApp.Columns[2].ColumnWidth :=5;
         ExcelApp.Columns[3].ColumnWidth :=12;
         ExcelApp.Columns[4].ColumnWidth :=12;
         for j:=0 to 10 do ExcelApp.Columns[6+j].ColumnWidth :=12;

         ExcelApp.ActiveSheet.Range['D15:D19'].Interior.Color :=rgb(194,214,154);
         ExcelApp.ActiveSheet.Range['D15:D19'].Font.Bold :=True;

         //添加圖表
         ChartObjects :=ExcelApp.ActiveSheet.ChartObjects.add(192,30,922, 200);
         ChartObjects.Chart.ChartType:=xlLineMarkers;
         chartObjects.chart.SetSourceData(ExcelApp.ActiveSheet.Range['D15:P19']);
         ChartObjects.Chart.PlotBy:=xlRows;
         if   FormatDateTime('HH24',GetSysdate) <= '08' then  begin
              Defect_Start := GetSysdate-1 ;
              sDefect_Start :=  FormatDateTime('yyyy/mm/dd',GetSysdate-1)+' 08:00:00' ;
              Defect_End :=  GetSysdate ;
              sDefect_End :=  FormatDateTime('yyyy/mm/dd',GetSysdate)+' 08:00:00' ;
         end else begin
              Defect_Start := GetSysdate ;
              sDefect_Start :=  FormatDateTime('yyyy/mm/dd',GetSysdate)+' 08:00:00' ;
              Defect_End :=  GetSysdate+1 ;
              sDefect_End := FormatDateTime('yyyy/mm/dd',GetSysdate+1)+' 08:00:00' ;
         end;



        //***************設置報表格式**********************************************************//

         QueryProcessName(QryTemp2,FOrmatDateTime('YYYYMMDD',today)+'08' , FOrmatDateTime('YYYYMMDD',today)+'20');
         sAllProcess :='( ';
         if QryTemp2.IsEmpty then exit;
         QryTemp2.First;
         for j:=0 to QryTemp2.RecordCount-1 do  begin
               strTitle := QryTemp2.FieldByName('PROCESS_NAME').AsString ;
               sAllProcess :=   sAllProcess+'''' + strTitle +''',' ;
               QryTemp2.Next;
         end;
         sAllProcess :=Copy(sAllProcess ,1,Length(sAllProcess)-1)+')';

         QueryTop3DefectCode(QryTemp4,sDefect_Start,sDefect_End);
         if not QryTemp4.IsEmpty then begin
               //設置X軸格式
             ExcelApp.ActiveSheet.Range['A38:P38'].Font.Bold :=true;
             ExcelApp.ActiveSheet.Range['A38:P38'].Font.Color :=clwhite;
             ExcelApp.ActiveSheet.Range['A38:P38'].Interior.Color :=rgb(0,32,96);
             //設置Item 列
             ExcelApp.Cells[38,1].Value := 'Operation';
             ExcelApp.Range['A38:B38'].Merge;
             ExcelApp.Cells[38,3].Value := 'Item';
             ExcelApp.Cells[38,4].Value := 'Total';
             ChartObjects :=ExcelApp.ActiveSheet.ChartObjects.add(210,318,550, 195);
             ChartObjects.Chart.ChartType:=xlLineMarkers;
             chartObjects.chart.SetSourceData(ExcelApp.ActiveSheet.Range['D33:K36']);
             ChartObjects.Chart.PlotBy:=xlRows;

             QryTemp4.First;
             for j:=0  to QryTemp4.RecordCount-1 do begin
                  ExcelApp.Cells[34+j,4].Value :=  QryTemp4.FieldByName('Defect_CODE').AsString;
                  QryTemp4.Next;
             end;
             for j:=0  to 6 do begin
                  ExcelApp.Cells[33,5+j].Value := FormatDateTime( 'MM/DD' ,Defect_Start-6+j) ;
             end;
             ExcelApp.ActiveSheet.Range['D33:D36'].Interior.Color :=rgb(194,214,154);
             ExcelApp.ActiveSheet.Range['D33:D36'].Font.Bold :=True;
             ExcelApp.ActiveSheet.Range['D33:K33'].Interior.Color :=rgb(194,214,154);
             ExcelApp.ActiveSheet.Range['D33:D33'].Font.Bold :=True;
             UsedRow :=38;
         end else begin
             ExcelApp.ActiveSheet.Range['A21:P21'].Font.Bold :=true;
             ExcelApp.ActiveSheet.Range['A21:P21'].Font.Color :=clwhite;
             ExcelApp.ActiveSheet.Range['A21:P21'].Interior.Color :=rgb(0,32,96);
             //設置Item 列
             ExcelApp.Cells[21,1].Value := 'Operation';
             ExcelApp.Range['A21:B21'].Merge;
             ExcelApp.Cells[21,3].Value := 'Item';
             ExcelApp.Cells[21,4].Value := 'Total';
             UsedRow :=21;
         end;

         //機種目標
         with QryTemp do begin
             close;
             Params.Clear;
             Params.CreateParam(ftstring,'Model_Name',ptInput);
             commandtext := 'select a.Upper_level from  SAJET.SYS_MODEL_RATE a,sajet.SYS_MODEL B where a.model_ID=b.MODEL_ID '+
                            '  and b.Model_NAME =:MODEL_NAME';
             Params.ParamByName('MODEL_NAME').AsString := sModelName;
             Open;

              if IsEmpty then begin
                 SendSettingMail(sModelName+'機種沒有設置機種良率');
                 FPY_Target :='95';
              end;
              FPY_Target := fieldbyName('Upper_level').AsString;
        end;

         QryTemp2.First;
         for  j:=0 to QryTemp2.RecordCount-1  do
         begin
             strTitle := QryTemp2.FieldByName('PROCESS_NAME').AsString ;
             Process_Fail := QryTemp2.FieldByName('PROCESS_FAIL').AsInteger ;
             ExcelApp.Cells[UsedRow+1,1].Value :=  strTitle;
             ExcelApp.Cells[UsedRow+1,3].Value :=  'Total Input';
             ExcelApp.Cells[UsedRow+2,3].Value :=  'First Output';
             ExcelApp.Cells[UsedRow+1,4].Value :=  '=SUM(E'+IntToStr(UsedRow+1)+':N'+InttoStr(UsedRow+1)+')';
             ExcelApp.Cells[UsedRow+2,4].Value :=  '=SUM(E'+IntToStr(UsedRow+2)+':N'+InttoStr(UsedRow+2)+')';
             if   Process_Fail <> 0 then begin
                 ExcelApp.Cells[UsedRow+3,3].Value :=  'Total Defect';
                 ExcelApp.Cells[UsedRow+4,3].Value :=  'Retest Pass';
                 ExcelApp.Cells[UsedRow+5,3].Value :=  'Final NG';
                 ExcelApp.Cells[UsedRow+6,3].Value :=  'Repair Q''ty';
                 ExcelApp.Cells[UsedRow+7,3].Value :=  'FPY(%)';
                 ExcelApp.Cells[UsedRow+8,3].Value :=  'Retest Yield(%)';
                 ExcelApp.Cells[UsedRow+9,3].Value :=  'SPY(%)';
                 ExcelApp.Cells[UsedRow+10,3].Value := 'Final(%)';
                 ExcelApp.Cells[UsedRow+3,4].Value  :=  '=SUM(E'+IntToStr(UsedRow+3)+':P'+InttoStr(UsedRow+3)+')';
                 ExcelApp.Cells[UsedRow+4,4].Value  :=  '=SUM(E'+IntToStr(UsedRow+4)+':P'+InttoStr(UsedRow+4)+')';
                 ExcelApp.Cells[UsedRow+5,4].Value  :=  '=SUM(E'+IntToStr(UsedRow+5)+':P'+InttoStr(UsedRow+5)+')';
                 ExcelApp.Cells[UsedRow+6,4].Value  :=  '=SUM(E'+IntToStr(UsedRow+6)+':P'+InttoStr(UsedRow+6)+')';
                 ExcelApp.Cells[UsedRow+7,4].Value  :=  '= IF(D'+IntToStr(UsedRow+1)+'=0,100,D'+IntToStr(UsedRow+2)+'/D'+InttoStr(UsedRow+1)+'*100)';
                 ExcelApp.Cells[UsedRow+8,4].Value  :=  '= IF(D'+InttoStr(UsedRow+3)+'=0,0,D'+IntToStr(UsedRow+4)+'/D'+InttoStr(UsedRow+3)+'*100)';
                 ExcelApp.Cells[UsedRow+9,4].Value  :=  '= IF(D'+IntToStr(UsedRow+1)+'=0,100,(D'+IntToStr(UsedRow+4)+'+D'+IntToStr(UsedRow+2)+')/D'+InttoStr(UsedRow+1)+'*100)';
                 ExcelApp.Cells[UsedRow+10,4].Value := '=IF(D'+IntToStr(UsedRow+1)+'=0,100,(D'+IntToStr(UsedRow+4)+'+D'+IntToStr(UsedRow+2)+'+D'+IntToStr(UsedRow+6)+')/D'+InttoStr(UsedRow+1)+'*100)';
                 ExcelApp.ActiveSheet.Rows[UsedRow+7].Font.Color :=clBlue;
                 ExcelApp.ActiveSheet.Rows[UsedRow+7].NumberFormat  := '0.00';
                 ExcelApp.ActiveSheet.Rows[UsedRow+8].Font.Color :=clRed;
                 ExcelApp.ActiveSheet.Rows[UsedRow+8].NumberFormat  := '0.00';
                 ExcelApp.ActiveSheet.Rows[UsedRow+9].NumberFormat  := '0.00';
                 ExcelApp.ActiveSheet.Rows[UsedRow+10].NumberFormat  := '0.00';
                 ExcelApp.ActiveSheet.Rows[UsedRow+9].Font.Color :=RGB(155,51,153);
                 ExcelApp.ActiveSheet.Rows[UsedRow+10].Font.Color :=RGB(255,51,153);
                 ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow+1)+':B'+IntToStr(UsedRow+10)].Merge;
                 ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow+1)+':P'+IntToStr(UsedRow+10)].Interior.Color :=rgb(185,245,245);
                 UsedRow :=  UsedRow+11;
                 QueryDefectCode(QryTemp3,sDStartTime,sDEndTime,strTitle);
                 if not QryTemp3.IsEmpty then begin
                    Qrytemp3.First;
                    FirstCount :=  UsedRow;
                    for k:=0 to  QryTemp3.RecordCount-1  do  begin
                       ExcelApp.Cells[UsedRow,2].Value := Qrytemp3.FieldByName('Defect_Code').AsString;
                       ExcelApp.Cells[UsedRow,3].Value := Qrytemp3.FieldByName('Defect_Desc').AsString;
                       ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow)+':P'+IntToStr(UsedRow)].Interior.Color :=rgb(235,185,185);
                       ExcelApp.Cells[UsedRow,4].Value :=  '=SUM(E'+IntToStr(UsedRow)+':P'+InttoStr(UsedRow)+')';
                       UsedRow :=UsedRow+1;
                       Qrytemp3.Next;
                    end;
                    ExcelApp.Cells[FirstCount,1].Value := 'Defect Detail';
                    ExcelApp.ActiveSheet.Range['A'+IntToStr(FirstCount)+':A'+IntToStr(UsedRow-1)].Merge;

                 end;
               end else begin
                 ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow+1)+':B'+IntToStr(UsedRow+2)].Merge;
                 ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow+1)+':P'+IntToStr(UsedRow+2)].Interior.Color :=rgb(185,245,245);
                 UsedRow :=  UsedRow+3;
             end;
             ExcelApp.rows[UsedRow].Rowheight :=3;
             ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow)+':N'+IntToStr(UsedRow)].Merge;
             QryTemp2.Next;
          end;
          if QryTemp4.IsEmpty then begin
              ExcelApp.ActiveSheet.Range['A21:P'+IntToStr(UsedRow-1)].Borders[1].Weight := 2;
              ExcelApp.ActiveSheet.Range['A21:P'+IntToStr(UsedRow-1)].Borders[2].Weight := 2;
              ExcelApp.ActiveSheet.Range['A21:P'+IntToStr(UsedRow-1)].Borders[3].Weight := 2;
              ExcelApp.ActiveSheet.Range['A21:P'+IntToStr(UsedRow-1)].Borders[4].Weight := 2;
          end else begin
              ExcelApp.ActiveSheet.Range['A38:P'+IntToStr(UsedRow-1)].Borders[1].Weight := 2;
              ExcelApp.ActiveSheet.Range['A38:P'+IntToStr(UsedRow-1)].Borders[2].Weight := 2;
              ExcelApp.ActiveSheet.Range['A38:P'+IntToStr(UsedRow-1)].Borders[3].Weight := 2;
              ExcelApp.ActiveSheet.Range['A38:P'+IntToStr(UsedRow-1)].Borders[4].Weight := 2;
          end;
          ExcelApp.ActiveSheet.Range['A1:P'+IntToStr(UsedRow-1)].HorizontalAlignment :=3;
          ExcelApp.ActiveSheet.Range['A1:P'+IntToStr(UsedRow-1)].VerticalAlignment :=2;
          ExcelApp.ActiveSheet.Columns[3]. HorizontalAlignment :=2;
          ExcelApp.ActiveSheet.Range['A14:P'+IntToStr(UsedRow-1)].Font.Size :=8;
          ExcelApp.ActiveSheet.Range['A14:P'+IntToStr(UsedRow-1)].Font.Name :='tahoma';
          ExcelApp.ActiveSheet.Rows[16].NumberFormat  := '0.00';
          ExcelApp.ActiveSheet.Rows[17].NumberFormat  := '0.00';
          ExcelApp.ActiveSheet.Rows[18].NumberFormat  := '0.00';
          ExcelApp.ActiveSheet.Rows[19].NumberFormat  := '0.00';
          ExcelApp.ActiveSheet.Range['D15:P19'].Borders[1].Weight := 2;
          ExcelApp.ActiveSheet.Range['D15:P19'].Borders[2].Weight := 2;
          ExcelApp.ActiveSheet.Range['D15:P19'].Borders[3].Weight := 2;
          ExcelApp.ActiveSheet.Range['D15:P19'].Borders[4].Weight := 2;
          ExcelApp.ActiveSheet.Range['D15:P19'].Borders[7].Weight := xlThick;
          ExcelApp.ActiveSheet.Range['D15:P19'].Borders[8].Weight := xlThick;
          ExcelApp.ActiveSheet.Range['D15:P19'].Borders[9].Weight := xlThick;
          ExcelApp.ActiveSheet.Range['D15:P19'].Borders[10].Weight := xlThick;

          AllRows := UsedRow;

          for j:=0 to Week_list.Count-1 do begin
               sXValue:= Week_list.Strings[j]  ;
               ExcelApp.Cells[15,5+j].value := sXValue;
               if QryTemp4.IsEmpty then
                  ExcelApp.Cells[21,5+j].value := sXValue
               else
                  ExcelApp.Cells[38,5+j].value := sXValue
          end;

          ExcelApp.ActiveSheet.Rows[15].NumberFormat  := 'mm-dd';
          if QryTemp4.IsEmpty then
             ExcelApp.ActiveSheet.Rows[21].NumberFormat  := 'mm-dd'
          else
             ExcelApp.ActiveSheet.Rows[38].NumberFormat  := 'mm-dd' ;

         //************************************************************************************//
          //填入TOP3
          if not QryTemp4.IsEmpty then begin
              QryTemp4.First;
              sAll_Defect :='' ;
              For j:=0 to QryTemp4.RecordCount-1 do begin
                  sAll_Defect := sAll_Defect +''''+QryTemp4.FieldbyName('Defect_Code').AsString+''',';
                  QryTemp4.Next;
             end;
             sAll_Defect := trim(Copy(  sAll_Defect,1,length(sAll_Defect)-1));
             for j:=0 to 6 do begin
                QueryTop3DefectYield( QryTemp4,FormatDateTime('yyyyMMDD',Defect_Start-6+j)+'08',
                                              FormatDateTime('yyyyMMDD',Defect_Start-5+j)+'08',
                                              FormatDateTime('yyyy/MM/DD',Defect_Start-6+j)+' 08:00:00',
                                              FormatDateTime('yyyy/MM/DD',Defect_Start-5+j)+' 08:00:00',sAll_Defect);

                If not QryTemp4.IsEmpty then begin
                   QryTemp4.First;

                   for L:=0 to QryTemp4.RecordCount -1 do begin
                       sDefect_Code:= QryTemp4.FieldByName('Defect_COde').AsString;
                      for K:=0 to 2 do begin
                           if String(ExcelApp.Cells[34+k,4].Value) = sDefect_Code then
                              ExcelApp.Cells[34+k,5+j].Value  :=   QryTemp4.FieldByName('Yield').AsString
                      end;
                      QryTemp4.Next;
                   end;
                end;
             end;
          end;

          //填入Data ---
          for j:=0 to StartTime_list.Count-1 do
          begin
                tempStart := StartTime_list.Strings[j];
                tempEnd :=  EndTime_list.Strings[j];
                tempHStart := tempStart +':00:00';
                tempHEnd :=  tempEnd +':00:00';
                // 計算產出
                QueryOutput(QryData1,tempStart,tempEnd);
                Rowlist := TStringList.Create;
                SPYRowlist := TStringList.Create;
                FinalRowlist:= TStringList.Create;
                FinalYield :=100;
                UsedRow := 21;

                QryData1.First;
                for M:=0 to   QryData1.RecordCount-1 do begin
                    strTitle := QryData1.FieldByName('PROCESS_NAME').AsString ;
                    Repair_Qty:= QryData1.FieldByName('REPAIR_QTY').AsInteger ;
                    for k:=3 to AllRows-1 do begin
                       if  strTitle = ExcelApp.Cells[k,1].Value  then
                           UsedRow :=k;
                    end;
                    if UsedRow<=2 then exit;
                    strFPY :=  QryData1.FieldByName('FPY_QTY').AsString;
                    strTotal :=  QryData1.FieldByName('Total_QTY').AsString;
                    if  ExcelApp.Cells[UsedRow+10,1].Value ='Defect Detail' then begin
                        strRepass :=  QryData1.FieldByName('NTF_QTY').AsString;
                        ExcelApp.Cells[UsedRow,5+j].Value := strTotal;
                        ExcelApp.Cells[UsedRow+1,5+j].Value := strFPY;
                        ExcelApp.Cells[UsedRow+2,5+j].Value := StrToInt(strTotal)-strToInt(strFPY);
                        ExcelApp.Cells[UsedRow+3,5+j].Value := strRepass;
                        ExcelApp.Cells[UsedRow+4,5+j].Value := StrToInt(strTotal)-strToInt(strFPY)- strToInt(strRepass);
                        ExcelApp.Cells[UsedRow+5,5+j].Value := Repair_Qty;
                        Rowlist.Add(IntToStr(UsedRow+6));
                        SPYRowlist.Add(IntToStr(UsedRow+8));
                        FinalRowlist.Add(IntToStr(UsedRow+9));

                        if (StrToInt(strTotal)-strToInt(strFPY)) <> 0 then
                           ExcelApp.Cells[UsedRow+7,5+j].Value := StrToInt(strRepass)/(StrToInt(strTotal)-strToInt(strFPY))*100
                        else
                           ExcelApp.Cells[UsedRow+7,5+j].Value := 0;

                        if   StrToInt(strTotal)<> 0 then   begin
                           ExcelApp.Cells[UsedRow+6,5+j].Value := StrToInt(strFPY)/StrToInt(strTotal)*100;
                           ExcelApp.Cells[UsedRow+8,5+j].Value := (StrToInt(strFPY)+StrToInt(strRepass))/StrToInt(strTotal)*100 ;
                           ExcelApp.Cells[UsedRow+9,5+j].Value := FinalYield* (StrToInt(strFPY)+StrToInt(strRepass)+Repair_Qty) /StrToInt(strTotal);
                           end
                        else  begin
                           ExcelApp.Cells[UsedRow+6,5+j].Value := 100;
                           ExcelApp.Cells[UsedRow+8,5+j].Value := 100;
                           ExcelApp.Cells[UsedRow+9,5+j].Value := 100;
                        end;
                        UsedRow := UsedRow+10;
                        //計算對應的不良
                        QueryDefect(QryDefect,tempHStart,tempHEnd,strTitle);
                        if  not QryDefect.IsEmpty then begin
                           IsFound :=false;
                           for k:=UsedRow+1 to AllRows-1do begin
                              if  ExcelApp.Cells[k,1].Value <> '' then begin
                                 defect_count :=  k-1;
                                 IsFound :=true;
                                 break;
                              end;
                           end;
                           if IsFound then
                              defect_count := defect_count- UsedRow
                           else
                              defect_count :=100;

                           QryDefect.First;
                           for K:=0 to QryDefect.RecordCount-1 do begin
                             sDefect_Code := QryDefect.FieldByName('ALL_DEFECT').AsString ;
                             for L:=0 to defect_count do begin
                                if String(ExcelApp.Cells[UsedRow+L,2].Value) = sDefect_Code then
                                   ExcelApp.Cells[UsedRow+L,5+j].Value :=  QryDefect.FieldByName('C_SN').AsString ;
                             end;
                             QryDefect.Next;
                           end;
                        end;
                    end else begin
                        ExcelApp.Cells[UsedRow,5+j].Value := strTotal;
                        ExcelApp.Cells[UsedRow+1,5+j].Value := strFPY;
                        UsedRow := UsedRow+3;
                    end;
                    QryData1.Next;
                end;
                // 計算總 良率

                FPY := 100;
                SPY :=100;
                FinalYield :=100;
                Total_FPY :=100;
                Total_SPY :=100;

                if RowList.Count<> 0 then begin
                   for M:=0 to  RowList.Count-1 do begin
                       FPY :=  FPY * ExcelApp.Cells[strtoint(RowList.Strings[M]),5+j].Value/100 ;
                       SPY :=  SPY* ExcelApp.Cells[strtoint(SPYRowList.Strings[M]),5+j].Value/100 ;
                       FinalYield :=  FinalYield* ExcelApp.Cells[strtoint(FinalRowList.Strings[M]),5+j].Value/100 ;
                   end ;

                   ExcelApp.Cells[16,5+j].Value :=  FPY_Target ;
                   ExcelApp.Cells[17,5+j].Value := FormatFloat('0.00',FPY);
                   ExcelApp.Cells[18,5+j].Value := FormatFloat('0.00',SPY);
                   ExcelApp.Cells[19,5+j].Value :=  FinalYield ;
                 end;

                RowList.Free;
                SPYRowList.Free;
                FinalRowList.Free;
                UsedRow := UsedRow+8;
          end;
          if   IntToStr(ExcelApp.Cells[16,4+j].Value)  <> '' then begin
            TotalTarget_list.Add(FormatFloat('0.00',ExcelApp.Cells[16,4+j]));
            TotalSPY_list.Add(FormatFloat('0.00',ExcelApp.Cells[18,4+j]));
            TotalModel_List.add(sModelName);
          end;
          QryModel.Next;
    end;
    if FormatDateTime('HH',GetSysDate) <= '08' then
       sFileName := GetCurrentDir+'\'+FormatDateTime('YYYY年M月D日',GetSysDate-1)+' 各機種周生產報表.xlsx'
    else
       sFileName := GetCurrentDir+'\'+FormatDateTime('YYYY年M月D日',GetSysDate)+' 各機種周生產報表.xlsx';
    ExcelApp.WorkSheets[QryModel.RecordCount+1].Delete;
    ExcelApp.WorkSheets[QryModel.RecordCount+1].Delete;
    ExcelApp.WorkSheets[QryModel.RecordCount+1].Delete;
    ExcelApp.WorkSheets[1].Activate;
    ExcelApp.ActiveWorkbook.SaveAs(sFileName);
    ExcelApp.Quit;
    ExcelApp :=Unassigned;

end;
procedure TuMainForm.QueryTop3DEFECTCode(QryTemp4:TClientDataSet;Start_Time,End_Time:string);
begin
    QryTemp4.Close;
    QryTemp4.Params.Clear;
    QryTemp4.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp4.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp4.Params.CreateParam(ftstring,'MODEL_NAME',ptInput);
    QryTemp4.CommandText := ' SELECT  DEFECT_CODE,DEFECT_COUNT  FROM(   '+
                           '  SELECT  MODEL_NAME,DEFECT_CODE,SUM(DEFECT_COUNT) DEFECT_COUNT FROM ( '+
                           '  SELECT C2.MODEL_NAME,DECODE( SUBSTR( DECODE(D2.DEFECT_CODE,''SFR63'',''FOVT01'',D2.DEFECT_CODE),1,3) ,''SFR'',''SFR'', '+
                           '  DECODE(D2.DEFECT_CODE,''SFR63'',''FOVT01'',D2.DEFECT_CODE))  DEFECT_CODE,COUNT(*) DEFECT_COUNT  '+
                           '  FROM SAJET.G_SN_DEFECT_FIRST A2,SAJET.SYS_PART B2,SAJET.SYS_MODEL C2,SAJET.SYS_DEFECT D2,SAJET.SYS_PROCESS E2 '+
                           '  WHERE A2.REC_TIME >= TO_DATE(:STARTTIME,''YYYY/MM/DD HH24:MI:SS'') AND '+
                           '  A2.REC_TIME < TO_DATE(:ENDTIME,''YYYY/MM/DD HH24:MI:SS'') AND A2.WORK_ORDER '+
                           '   NOT LIKE ''RM%''AND  A2.NTF_TIME IS NULL AND C2.MODEL_NAME =:MODEL_NAME AND A2.PROCESS_ID = E2.PROCESS_ID '+
                           '   AND E2.PROCESS_CODE IS NOT NULL AND A2.MODEL_ID =B2.PART_ID AND B2.MODEL_ID=C2.MODEL_ID AND A2.DEFECT_ID =D2.DEFECT_ID '+
                           '  GROUP BY C2.MODEL_NAME,D2.DEFECT_CODE ) GROUP BY  MODEL_NAME,DEFECT_CODE ORDER BY DEFECT_COUNT DESC ) WHERE ROWNUM <=3 '+
                           '  ORDER BY DEFECT_COUNT DESC ';
    QryTemp4.Params.ParamByName('StartTime').AsString := Start_Time;
    QryTemp4.Params.ParamByName('EndTime').AsString := End_Time;
    QryTemp4.Params.ParamByName('MODEL_NAME').AsString := sModelName;
    QryTemp4.Open;
end;



procedure TuMainForm.QueryTop3DEFECTYield(QryTemp4:TClientDataSet;START_DATE,END_DATE,Start_Time,End_Time,ALL_Defect_Code:string);
begin
    QryTemp4.Close;
    QryTemp4.Params.Clear;
    QryTemp4.Params.CreateParam(ftstring,'STARTDATE',ptInput);
    QryTemp4.Params.CreateParam(ftstring,'ENDDATE',ptInput);
    QryTemp4.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp4.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp4.Params.CreateParam(ftstring,'MODEL_NAME',ptInput);
    QryTemp4.CommandText := ' SELECT BB.DEFECT_CODE,SUBSTR(SUM(BB.DEFECT_COUNT/AA.TOTAL_INPUT),1,5)*100 AS "YIELD"  FROM  '+
                           ' ( '+
                           '  SELECT PROCESS_ID ,SUM(PASS_QTY+FAIL_QTY) TOTAL_INPUT FROM( SELECT C.MODEL_NAME,A.PROCESS_ID, '+
                           '  A.PASS_QTY,A.FAIL_QTY,TO_NUMBER(TO_CHAR(A.WORK_DATE)||TRIM(TO_CHAR(A.WORK_TIME,''00''))) DATETIME '+
                           '  FROM SAJET.G_SN_COUNT A,SAJET.SYS_PART B, SAJET.SYS_MODEL C WHERE A.WORK_ORDER NOT LIKE ''RM%'' and '+
                           '  A.PASS_QTY +A.FAIL_QTY <>0 AND A.MODEL_ID=B.PART_ID AND B.MODEL_ID =C.MODEL_ID AND C.MODEL_NAME =:MODEL_NAME  ) '+
                           '  WHERE  DATETIME >= :STARTDATE AND DATETIME < :ENDDATE  GROUP BY PROCESS_ID ) AA,'+
                           '  ( '+
                           '   SELECT PROCESS_ID,DEFECT_CODE ,SUM(C_COUNT) DEFECT_COUNT FROM ( '+
                           '   SELECT C1.MODEL_NAME,DECODE( SUBSTR( DECODE(D1.DEFECT_CODE,''SFR63'',''FOVT01'',D1.DEFECT_CODE),1,3) ,''SFR'',''SFR'', '+
                           '   DECODE(D1.DEFECT_CODE,''SFR63'',''FOVT01'',D1.DEFECT_CODE))  DEFECT_CODE, '+
                           '   A1.PROCESS_ID ,1 C_COUNT FROM '+
                           '  SAJET.G_SN_DEFECT_FIRST A1,SAJET.SYS_PART B1,SAJET.SYS_MODEL C1,SAJET.SYS_DEFECT D1 ,SAJET.SYS_PROCESS E1 '+
                           '  WHERE A1.REC_TIME >= TO_DATE(:STARTTIME,''YYYY/MM/DD HH24:MI:SS'') AND'+
                           '  A1.REC_TIME < TO_DATE(:ENDTIME,''YYYY/MM/DD HH24:MI:SS'') AND A1.WORK_ORDER '+
                           '  NOT LIKE ''RM%''AND  A1.NTF_TIME IS NULL AND C1.MODEL_NAME =:MODEL_NAME '+
                           '  AND A1.MODEL_ID =B1.PART_ID AND B1.MODEL_ID=C1.MODEL_ID AND A1.DEFECT_ID =D1.DEFECT_ID AND E1.PROCESS_ID=A1.PROCESS_ID AND '+
                           '  E1.PROCESS_CODE IS NOT NULL ) WHERE DEFECT_CODE IN '+
                           ' ( '+  All_Defect_Code +')'+
                           '  GROUP BY DEFECT_CODE,PROCESS_ID,DEFECT_CODE   )BB '+
                           '  WHERE   AA.PROCESS_ID=BB.PROCESS_ID  GROUP BY BB.DEFECT_CODE ORDER BY "YIELD"  DESC ';
    QryTemp4.Params.ParamByName('STARTDATE').AsString := START_DATE;
    QryTemp4.Params.ParamByName('ENDDATE').AsString := END_DATE;
    QryTemp4.Params.ParamByName('StartTime').AsString := Start_Time;
    QryTemp4.Params.ParamByName('EndTime').AsString := End_Time;
    QryTemp4.Params.ParamByName('MODEL_NAME').AsString := sModelName;
    QryTemp4.Open;
end;

procedure TuMainForm.FormDestroy(Sender: TObject);
begin
   TotalModel_List.Free;
   TotalTarget_list.Free;
   TotalSPY_list.Free;
   StartTime_List.Free;
   EndTime_list.Free;
   Week_List.Free;
end;

end.
