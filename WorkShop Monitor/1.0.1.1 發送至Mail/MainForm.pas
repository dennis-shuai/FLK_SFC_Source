unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, MConnect, ObjBrkr, DB, DBClient,
  SConnect,IniFiles,math, IdComponent, IdTCPConnection,Comobj,
  IdTCPClient, IdMessageClient, IdSMTP, IdBaseComponent, IdMessage,Excel2000;

type
  TuMainForm = class(TForm)
    SimpleObjectBroker1: TSimpleObjectBroker;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SocketConnection1: TSocketConnection;
    Label1: TLabel;
    IdMessage1: TIdMessage;
    IdSMTP1: TIdSMTP;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    StrLst,StrLst1,StrLstPdLineID,StrLstPdLineName,StrLstProcess,sStr,StrLstProcessName,StrLstDate,StrLstHour,sShiftID,sStrTmp: TStringList;
    sDayShiftID,sNightShiftID,sDayShiftTime,sNightShiftTime : TStringList;
    ALL_Pages,G_Page,ALL_PDLINE ,TimeSeq,PDLINECount: Integer;
    G_Repeat,G_status,G_UpdateStatus,sStartTime,sEndTime,sShift,sFailPdline: String;
    G_FIRST  : Boolean;
    sFileName:string;
    sShiftHour: array[0..11] of integer;
    sDayShiftDay,sNightShiftDay,sCurrentHour,sPDLine,sCurrentPDLine,sCurrentModel,sStartDateTime,sEndDateTime : String;
    function LoadApServer: Boolean;
    Procedure QueryTotalYield(DataTemp:TClientDataSet);
    Procedure QueryYieldPH(DataTemp:TClientDataSet);
    Procedure QueryOutput(DataTemp:TClientDataSet);
    Procedure QueryCurrentDate(DataTemp:TClientDataSet);
    Procedure QueryTotal(DataTemp:TClientDataSet);
    Procedure DisplayTotalOutput;
    Procedure DisplayTotalYield;
    function  GetSysDate:TDateTime;
    Procedure ExportExcel;
    Procedure QueryTotalOutput(DataTemp:TClientDataSet);
    function  AddZero(s:string;HopeLength:Integer):String;
    procedure SendMail(attachmentFilePath:String;AddressList:TStringList);
    function  QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
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
   if  FileExists(GetCurrentDir + '\ApServer.cfg') then
     AssignFile(F, GetCurrentDir + '\ApServer.cfg')
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

procedure TuMainForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
    if Key = #27  then uMainForm.Close;
end;

procedure TuMainForm.FormShow(Sender: TObject);
Var fInI: TIniFile;
    J,I : Integer;
    sIstr: String;
    Addresslist:TStringList;
begin
   uMainForm.Left :=0;
   uMainFOrm.Top :=0;

   LoadApServer;

   if not (DirectoryExists(ExtractFilePath(Application.ExeName)+'\InI')) then
    ForceDirectories(ExtractFilePath(Application.ExeName)+'\InI');
   fInI:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'InI\SAJETMonitor.ini');
   With fInI do
   begin
     J := StrToInt(ReadString('Monitor Chosen Pdline Name', 'Count', '0'));
     for I := 1 to J  do
     begin
      sIstr:=fInI.ReadString('Monitor Chosen Pdline Name', 'Pdline_' + IntToStr(I), '');
      StrLstPDLineID.Add(sIstr);
    end;
   end;

   sPDline := ''''+StrLstPDLineID.Strings[0]+ '''';
   for i:=1 to j-1 do  begin
        sPDline := sPDline+  ','''+StrLstPDLineID.Strings[i] +'''';
   end;

   if StrLstPDLineID.Count<=0 then
       MessageDlg('Please Choose PDLine ',mtInformation, [mbOK],0)
   else begin
     ExportExcel;
     Addresslist := TStringList.Create;


     
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


     //Addresslist.Add('Dennis_shuai@foxlink.com');
     if sFileName <>'' then
         SendMail(sFileName,Addresslist);
     Addresslist.Free;
     Close;

   end;
end;

procedure TuMainForm.Timer1Timer(Sender: TObject);
begin
     QueryCurrentDate( QryData);
     QueryYieldPH(QryData);
     //DisplayYieldPH ;
     QueryTotalYield(QryData);
     //DisplayTotalYield;
end;


Procedure TuMainForm.QueryYieldPH(DataTemp:TClientDataSet);
begin
      DataTemp.Close;
      DataTemp.Params.Clear;
      DataTemp.Params.CreateParam(ftstring,'StartTime',ptInput);
      DataTemp.Params.CreateParam(ftstring,'EndTime',ptInput);
      DataTemp.CommandText :=   ' select  MODEL_NAME,PDLINE_NAME,DATETIME,WORK_TIME,UPH,Cycle_Time,Remark,SUBSTR(exp(sum(ln(decode(SPY_YIELD,0,0.000001,SPY_YIELD)))),1,4)*100 as SPY_YIELD, '+
                               '         round(exp(sum(ln(decode(FPY_YIELD,0,0.000001,FPY_YIELD))))*100,2) as FPY_YIELD  '+
                               '  from (  ' +
                               '      SELECT   MODEL_NAME,PDLINE_NAME,PROCESS_NAME,PROCESS_CODE,DATETIME ,WORK_TIME,UPH,CYCLE_TIME,Remark,'+
                               '                 NVL(SUM(PASS_QTY),0) as FPY_QTY ,  '+
                               '                 NVL(SUM(FAIL_QTY),0) AS FAIL_QTY ,NVL(SUM(NTF_QTY),0) AS NTF_QTY,  '+
                               '                 NVL(SUM(PASS_QTY)+SUM(FAIL_QTY),0) as TOTAL_QTY, NVL(SUM(PASS_QTY)+SUM(NTF_QTY),0) as OUTPUT_QTY, '+
                               '                 DECODE (SUM(PASS_QTY)+SUM(FAIL_QTY),0,0,SUBSTR(TO_CHAR(SUM(PASS_QTY)/(SUM(PASS_QTY)+SUM(FAIL_QTY))),1,4)) as FPY_YIELD, '+
                               '                 DECODE (SUM(PASS_QTY)+SUM(FAIL_QTY),0,0,SUBSTR(TO_CHAR((SUM(PASS_QTY)+SUM(NTF_QTY))/(SUM(PASS_QTY)+SUM(FAIL_QTY))),1,4)) as SPY_YIELD  '+
                               '       from (  '+
                               '                  select  g.MODEL_NAME,A.PDLINE_ID,C.PDLINE_NAME ,b.PROCESS_NAME,b.PROCESS_CODE,to_char(A.WORK_DATE)||TRIM(to_CHAR(A.WORK_TIME,''00'')) as "DATETIME",'+
                               '                         A.WORK_TIME, D.Target_Qty as "UPH",d.Cycle_Time ,'+
                               '                         A.PASS_QTY,A.FAIL_QTY,A.NTF_QTY ,d.Remark '+
                               '                  from  SAJET.G_SN_COUNT a,SAJET.SYS_PROCESS b,SAJET.SYS_PDLINE c,SAJET.SYS_PDLINE_MONITOR_BASE d ,'+
                               '                        SAJET.sys_process e   ,sajet.sys_PART f,sajet.sys_MODEL g,SAJET.G_PDLINE_MANAGE H  '+
                               '                  where A.PDLINE_ID =C.PDLINE_ID and A.PROCESS_ID =b.PROCESS_ID  and d.PDline_ID=a.PDLINE_ID  and d.PROCESS_ID =E.PROCESS_ID AND H.PRODUCE_QTY <>0  '+
                               '                          and (A.Pass_Qty+A.NTF_Qty) <> 0  and to_char(A.WORK_DATE)||TRIM(to_CHAR(A.WORK_TIME,''00'')) >=H.STARTTIME '+
                               '                          and to_char(A.WORK_DATE)||TRIM(to_CHAR(A.WORK_TIME,''00''))< H.ENDTIME  '+
                               '                          and A.PDLINE_ID =H.PDLINE_ID '+
                               '                          and A.SHIFT_ID=H.SHIFT_ID AND H.REPAIR_LINE =''N'' and H.Produce_qty <>0 and H.PD_STATUS=1 '+
                               '                          and B.PROCESS_CODE <=e.process_Code and a.Model_ID=f.PART_ID and f.MODEL_ID =g.MODEL_ID and b.Process_code is not null) '+
                               '        where  DATETIME >= :StartTime  and DATETIME<:EndTime  AND PDLINE_NAME IN '+
                               '        ( '+
                                         sPDline+    //       '    'CM01','CM02','CM03','CM04','CM05','CM06','CM07','CM08','CM09','CM10','CM11','CM12','CM13','CM14'
                               '        ) group by   MODEL_NAME,PDLINE_NAME ,PROCESS_NAME,PROCESS_CODE,DATETIME, WORK_TIME,UPH,Cycle_Time,Remark   ORDER BY PDLINE_NAME,WORK_TIME,PROCESS_CODE '+
                               '   ) '+
                               '   group by MODEL_NAME,PDLINE_NAME,DATETIME,WORK_TIME,UPH,Cycle_Time,Remark ORDER BY PDLINE_NAME ';

    DataTemp.Params.ParamByName('StartTime').AsString :=sStartTime;
    DataTemp.Params.ParamByName('EndTime').AsString :=sEndDateTime;
    DataTemp.Open;

end;


Procedure TuMainForm.QueryCurrentDate(DataTemp:TClientDataSet);
var i:integer;
begin
    
     DataTemp.Close;
     DataTemp.Params.Clear;
     DataTemp.CommandText := 'select to_Char(sysDate,''yyyymmdd'') as DATE1, to_Char(sysDate,''HH24'') as TIME1 ,  '+
                                    ' to_Char(sysDate,''yyyymmddHH24'') as DATETIME, to_Char(sysDate-1,''yyyymmdd'')'+
                                    ' as lastDate, to_Char(sysDate+1,''yyyymmdd'') as NextDay from dual';
     DataTemp.Open;
     if    (DataTemp.FieldByName( 'TIME1').AsInteger >= 8 ) and  (DataTemp.FieldByName( 'TIME1').AsInteger <20 ) then begin
         sStartTime :=  DataTemp.FieldByName( 'DATE1').AsString+'08';
         sEndTime :=    DataTemp.FieldByName( 'DATETIME').AsString;
         sEndDateTime :=    DataTemp.FieldByName( 'DATE1').AsString +'20';
         sShift :='D';
     end else if (DataTemp.FieldByName( 'TIME1').AsInteger >= 0) and (DataTemp.FieldByName( 'TIME1').AsInteger <8) then begin

          sStartTime :=  DataTemp.FieldByName( 'lastDate').AsString +'20' ;
          sEndTime   :=  DataTemp.FieldByName( 'DATE1').AsString +   DataTemp.FieldByName( 'TIME1').AsString ;
          sEndDateTime :=    DataTemp.FieldByName( 'DATE1').AsString +'08';
          sShift :='N';
     end else   if DataTemp.FieldByName( 'TIME1').AsInteger >= 20  then begin
          sStartTime :=  DataTemp.FieldByName( 'DATE1').AsString +'20' ;
          sEndTime   :=  DataTemp.FieldByName( 'DATE1').AsString + DataTemp.FieldByName( 'TIME1').AsString ;
          sEndDateTime :=    DataTemp.FieldByName( 'NextDay').AsString +'08';
          sShift :='N';
     end;

     if   sShift ='D' then begin
        for i:=0 to 11 do begin
           sShiftHour[i] := i+8 ;
          TPanel(FindComponent('panelTittleT'+ IntToStr(i+1))).Caption :=  IntToStr(sShiftHour[i] )+'時';
        end;
      end else begin
         for i:=0 to 3 do begin
            TPanel(FindComponent('panelTittleT'+ IntToStr(i+1))).Caption := IntToStr(20+i )+'時';
            sShiftHour[i] := 20+i;
         end;
         for i:=4 to 11 do begin
            sShiftHour[i] := i-4;
            TPanel(FindComponent('panelTittleT'+ IntToStr(i+1))).Caption := IntToStr(i-4 )+'時';
         end;
     end;

     for i:=0 to 11 do begin
          if  DataTemp.FieldByName( 'TIME1').AsInteger = sShiftHour[i] then
               TimeSeq := i+1;
     end;


end;

Procedure TuMainForm.QueryTotalYield(DataTemp:TClientDataSet);
begin
     DataTemp.Close;
     DataTemp.Params.Clear;
     DataTemp.Params.CreateParam(ftstring,'StartTime',ptInput);
     DataTemp.Params.CreateParam(ftstring,'EndTime',ptInput);
     DataTemp.CommandText :=   ' select  PDLINE_NAME,Total_QTY,ROUND(exp(sum(ln(decode(SPY_YIELD,0,0.000001,SPY_YIELD))))*100,2)  as SPY_YIELD, '+
                               '        round(exp(sum(ln(decode(FPY_YIELD,0,0.000001,FPY_YIELD))))*100,2)  as FPY_YIELD       '   +
                               '  from (                                                            '  +
                               '      SELECT  PDLINE_NAME,PROCESS_NAME,PROCESS_CODE,NVL(SUM(PASS_QTY),0)  as FPY_QTY  ,                                        '+
                               '                 NVL(SUM(FAIL_QTY),0) AS FAIL_QTY ,NVL(SUM(NTF_QTY),0) as  NTF_QTY,                                                                      '+
                               '                 NVL(SUM(PASS_QTY+FAIL_QTY),0) as TOTAL_QTY, NVL(SUM(PASS_QTY)+SUM(NTF_QTY),0) as  OUTPUT_QTY,                                      '+
                               '                 DECODE (SUM(PASS_QTY)+SUM(FAIL_QTY),0,0,SUBSTR(TO_CHAR(SUM(PASS_QTY)/(SUM(PASS_QTY)+SUM(FAIL_QTY))),1,4))  as FPY_YIELD,                '+
                               '                 DECODE (SUM(PASS_QTY)+SUM(FAIL_QTY),0,0,SUBSTR(TO_CHAR((SUM(PASS_QTY)+SUM(NTF_QTY))/(SUM(PASS_QTY)+SUM(FAIL_QTY))),1,4)) as  SPY_YIELD  '+
                               '       from (                                                                                                                                            '+
                               '                  select  C.PDLINE_NAME ,b.PROCESS_NAME,b.PROCESS_CODE,to_char(WORK_DATE)||TRIM(to_CHAR(WORK_TIME,''00'')) as "DATETIME",  '+
                               '                         A.PASS_QTY,A.FAIL_QTY,A.NTF_QTY                                                                                                '+
                               '                  from  SAJET.G_SN_COUNT a,SAJET.SYS_PROCESS b,SAJET.SYS_PDLINE c,SAJET.SYS_PDLINE_MONITOR_BASE d ,                                     '+
                               '                        SAJET.sys_process e      '+
                               '                  where A.PDLINE_ID =C.PDLINE_ID and A.PROCESS_ID =b.PROCESS_ID  and d.PDline_ID=a.PDLINE_ID  and d.PROCESS_ID =E.PROCESS_ID            '+
                               '                          and B.PROCESS_CODE <=e.process_Code and b.Process_code is not null  and (A.PASS_QTY+A.FAIL_QTY <>0))                          '+
                               '        where  DATETIME >= :StartTime  and DATETIME<:EndTime  AND PDLINE_NAME IN                                                                        '+
                               '        (                                                                                                                                               '+
                                         sPDline +
                               '        ) group by  PDLINE_NAME ,PROCESS_NAME,PROCESS_CODE  ORDER BY PDLINE_NAME,PROCESS_CODE          '+
                               '   )                                                                                                                                                    '+
                               '   group by PDLINE_NAME,Total_QTY  ORDER BY PDLINE_NAME ';

   DataTemp.Params.ParamByName('StartTime').AsString :=sStartTime;
   DataTemp.Params.ParamByName('EndTime').AsString :=sEndDateTime;
   DataTemp.Open;
end;

Procedure TuMainForm.QueryOutput(DataTemp:TClientDataSet);
begin
     DataTemp.Close;
     DataTemp.Params.Clear;
     DataTemp.Params.CreateParam(ftstring,'StartTime',ptInput);
     DataTemp.Params.CreateParam(ftstring,'EndTime',ptInput);
     DataTemp.CommandText :=   ' SELECT PDLINE_NAME,PROCESS_NAME,PROCESS_CODE,DATETIME ,WORK_TIME,NVL(SUM(PASS_QTY),0) as FPY_QTY ,  '+
                               '      NVL(SUM(FAIL_QTY),0) AS FAIL_QTY ,NVL(SUM(NTF_QTY),0) AS NTF_QTY,                                   '+
                               '      NVL(SUM(PASS_QTY)+SUM(FAIL_QTY),0) as TOTAL_QTY, NVL(SUM(PASS_QTY)+SUM(NTF_QTY),0) as OUTPUT_QTY   '+
                               '      from (                                                                                '+
                               '           select C.PDLINE_NAME ,b.PROCESS_NAME,b.PROCESS_CODE,to_char(WORK_DATE)||TRIM(to_CHAR(WORK_TIME,''00'')) as "DATETIME",'+
                               '                  A.WORK_TIME,                                '+
                               '              A.PASS_QTY,A.FAIL_QTY,A.NTF_QTY  from SAJET.G_SN_COUNT a,                           '+
                               '              SAJET.SYS_PROCESS b,SAJET.SYS_PDLINE c ,  SAJET.SYS_PDLINE_MONITOR_BASE d       '+
                               '            where A.PDLINE_ID =C.PDLINE_ID and A.PROCESS_ID =b.PROCESS_ID  '+
                               '       and a.PROCESS_ID =d.PROCESS_ID  and a.PDLINE_ID =d.PDLINE_ID ) '+
                               '       where  DATETIME >= :StartTime  and DATETIME <:EndTime  AND PDLINE_NAME IN   '+
                               '      (                               '+
                                      sPDline +
                               ')  group by PDLINE_NAME ,PROCESS_NAME,PROCESS_CODE,DATETIME, WORK_TIME  ORDER BY PDLINE_NAME,WORK_TIME,PROCESS_CODE';

   DataTemp.Params.ParamByName('StartTime').AsString :=sStartTime;
   DataTemp.Params.ParamByName('EndTime').AsString :=sEndDateTime;
   DataTemp.Open;

end;

Procedure TuMainForm.QueryTotal(DataTemp:TClientDataSet);
begin
     DataTemp.Close;
     DataTemp.Params.Clear;
     DataTemp.Params.CreateParam(ftstring,'StartTime',ptInput);
     DataTemp.Params.CreateParam(ftstring,'EndTime',ptInput);
     DataTemp.CommandText :=   ' SELECT PDLINE_NAME,PROCESS_NAME,PROCESS_CODE,DATETIME ,WORK_TIME,NVL(SUM(PASS_QTY),0) as FPY_QTY ,  '+
                               '      NVL(SUM(FAIL_QTY),0) AS FAIL_QTY ,NVL(SUM(NTF_QTY),0) AS NTF_QTY,                                   '+
                               '      NVL(SUM(PASS_QTY)+SUM(FAIL_QTY),0) as TOTAL_QTY, NVL(SUM(PASS_QTY)+SUM(NTF_QTY),0) as OUTPUT_QTY   '+
                               '      from (                                                                                '+
                               '           select C.PDLINE_NAME ,b.PROCESS_NAME,b.PROCESS_CODE,to_char(WORK_DATE)||TRIM(to_CHAR(WORK_TIME,''00'')) as "DATETIME",'+
                               '                  A.WORK_TIME,                                '+
                               '              A.PASS_QTY,A.FAIL_QTY,A.NTF_QTY  from SAJET.G_SN_COUNT a,                           '+
                               '              SAJET.SYS_PROCESS b,SAJET.SYS_PDLINE c ,  SAJET.SYS_PDLINE_MONITOR_BASE d       '+
                               '            where A.PDLINE_ID =C.PDLINE_ID and A.PROCESS_ID =b.PROCESS_ID  '+
                               '       and a.PROCESS_ID =d.PROCESS_ID  and a.PDLINE_ID =d.PDLINE_ID ) '+
                               '       where  DATETIME >= :StartTime  and DATETIME <:EndTime  AND PDLINE_NAME IN   '+
                               '      (                               '+
                                      sPDline +
                               ')  group by PDLINE_NAME ,PROCESS_NAME,PROCESS_CODE,DATETIME, WORK_TIME  ORDER BY PDLINE_NAME,WORK_TIME,PROCESS_CODE';

   DataTemp.Params.ParamByName('StartTime').AsString :=sStartTime;
   DataTemp.Params.ParamByName('EndTime').AsString :=sEndDateTime;
   DataTemp.Open;
end;


Procedure TuMainForm.QueryTotalOutput(DataTemp:TClientDataSet);
begin
     DataTemp.Close;
     DataTemp.Params.Clear;
     DataTemp.Params.CreateParam(ftstring,'StartTime',ptInput);
     DataTemp.Params.CreateParam(ftstring,'EndTime',ptInput);
     DataTemp.CommandText :=   ' SELECT PDLINE_NAME,PROCESS_NAME,PROCESS_CODE,NVL(SUM(PASS_QTY),0) as FPY_QTY ,  '+
                               '      NVL(SUM(FAIL_QTY),0) AS FAIL_QTY ,NVL(SUM(NTF_QTY),0) AS NTF_QTY,                                   '+
                               '      NVL(SUM(PASS_QTY)+SUM(FAIL_QTY),0) as TOTAL_QTY, NVL(SUM(PASS_QTY)+SUM(NTF_QTY),0) as OUTPUT_QTY   '+
                               '      from (                                                                                '+
                               '           select C.PDLINE_NAME ,b.PROCESS_NAME,b.PROCESS_CODE,to_char(WORK_DATE)||TRIM(to_CHAR(WORK_TIME,''00'')) as "DATETIME",'+
                               '                  A.WORK_TIME,                                '+
                               '              A.PASS_QTY,A.FAIL_QTY,A.NTF_QTY  from SAJET.G_SN_COUNT a,                           '+
                               '              SAJET.SYS_PROCESS b,SAJET.SYS_PDLINE c ,  SAJET.SYS_PDLINE_MONITOR_BASE d       '+
                               '            where A.PDLINE_ID =C.PDLINE_ID and A.PROCESS_ID =b.PROCESS_ID  '+
                               '       and a.PROCESS_ID =d.PROCESS_ID  and a.PDLINE_ID =d.PDLINE_ID ) '+
                               '       where  DATETIME >= :StartTime  and DATETIME <:EndTime  AND PDLINE_NAME IN   '+
                               '      (                               '+
                                      sPDline +
                               ')  group by PDLINE_NAME ,PROCESS_NAME,PROCESS_CODE  ORDER BY PDLINE_NAME,PROCESS_CODE';

   DataTemp.Params.ParamByName('StartTime').AsString :=sStartTime;
   DataTemp.Params.ParamByName('EndTime').AsString :=sEndDateTime;
   DataTemp.Open;
end;


Procedure TuMainForm.DisplayTotalOutput;
var i,j :integer;
sPdline,sOutput:string;
begin
    qrydata.First;
    for i :=0 to qrydata.RecordCount-1 do
    begin
         sPdline :=  qrydata.FieldByName('PDLINE_NAME').AsString ;
         sOutput := qrydata.FieldByName('OUTPUT_QTY').AsString;
          for j:=1 to 10 do begin
               if sPdline = TPANEL(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j),2))).Caption then
               begin
                     TPANEL(FindComponent( 'PanelActualOp'+   AddZero(IntToStr(j),2))).Caption   := sOutput;
               end;
          end;
          qrydata.Next;
    end;

end;

Procedure TuMainForm.DisplayTotalYield;
var i,j,tempRow,iPos:integer;
    sPDLineName,sSPY,sTargetYield,sRPDLINE,sWorkTime :string;
begin
     tempRow:=0;
     if QryData.IsEmpty then exit;
     QryData.First;
     for  i:=0 to  QryData.RecordCount-1  do   begin
        sPDLineName :=    QryData.FieldByName('PDLINE_NAME').AsString ;
        if    sPDLineName = '' then exit;

        sSPY :=    QryData.FieldByName('FPY_YIELD').AsString ;
        for j:=0 to 9  do   begin
            if TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j+1),2))).Caption <> '' then begin
                iPos :=Pos('自動',TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j+1),2))).Caption );
                if iPos >0 then
                    sRPDLINE := Copy(TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j+1),2))).Caption ,1,
                                        Length(TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j+1),2))).Caption)-6)
                else
                    sRPDLINE := TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j+1),2))).Caption;

                if  sPDLineName  = sRPDLINE then begin
                    tempRow :=  j+1;
                    TPanel(FindComponent( 'PanelActualYieldT' +  AddZero(IntToStr(tempRow),2))).Caption := sSPY+'%';
                    sTargetYield := TPanel(FindComponent( 'PanelTargetYieldT' +  AddZero(IntToStr(tempRow),2))).Caption;

                    if  StrToFloat(sSPY) <  StrToFloat(Copy(sTargetYield,1,length(sTargetYield)-1))-2 then
                        TPanel(FindComponent( 'PanelActualYieldT' +  AddZero(IntToStr(tempRow),2))).Color :=clRed;

                    if  StrToFloat(sSPY) >= StrToFloat(Copy(sTargetYield,1,length(sTargetYield)-1)) then
                        TPanel(FindComponent( 'PanelActualYieldT' +  AddZero(IntToStr(tempRow),2))).Color :=clGreen;

                    if  (StrToFloat(sSPY) >=  StrToFloat(Copy(sTargetYield,1,length(sTargetYield)-1))-2)   and
                        ( StrToFloat(sSPY) < StrToFloat(Copy(sTargetYield,1,length(sTargetYield)-1)) ) then
                        TPanel(FindComponent( 'PanelActualYieldT' +  AddZero(IntToStr(tempRow),2))).Color :=clYellow;

                end;
            end;
        end;
        QryData.Next;
     end;
end;

Procedure TuMainForm.ExportExcel;
var   ExcelApp:variant;
      sFTYield,sFAYield:Double;
      i,j,iPos,CurrentTime,PDLINECount,tempRow:integer;
      sFristPDLine, sPDLineName,sModel,sSpy,sTargetYield,sWorkTime,sRemark,sRPDLINE,sTotalQty:string;
begin

    QueryCurrentDate( QryData);
    //showmessage('2');
    QueryYieldPH(qryData);

    if qryData.IsEmpty then exit;
    ExcelApp :=CreateOleObject('Excel.Application');
    ExcelApp.Visible := false;
    ExcelApp.displayAlerts:=false;
    ExcelApp.WorkBooks.Add;
    //ExcelApp.WorkSheets[1].Activate;


    if sShift ='D' then  begin
        ExcelApp.WorkSheets[1].Name := '白班看板數據';
        sFileName := ExtractFileDir(ParamStr(0))+'\'+ FormatDateTime('YYYYMMDD',GetSYSDATE)+'白班看板數據.xlsx';
        ExcelApp.Cells[1,1].value :=  '白班看板數據';
        ExcelApp.Cells[3,4].value := '8時';
        ExcelApp.Cells[3,5].value := '9時';
        ExcelApp.Cells[3,6].value := '10時';
        ExcelApp.Cells[3,7].value := '11時';
        ExcelApp.Cells[3,8].value := '12時';
        ExcelApp.Cells[3,9].value := '13時';
        ExcelApp.Cells[3,10].value := '14時';
        ExcelApp.Cells[3,11].value := '15時';
        ExcelApp.Cells[3,12].value := '16時';
        ExcelApp.Cells[3,13].value := '17時';
        ExcelApp.Cells[3,14].value := '18時';
        ExcelApp.Cells[3,15].value := '19時';
        ExcelApp.Cells[3,18].value := '總投入數';
    end
    else begin
        ExcelApp.WorkSheets[1].Name := '夜班看板數據';
        sFileName := ExtractFileDir(ParamStr(0))+'\'+ FormatDateTime('YYYYMMDD',GetSYSDATE)+'晚班看板數據.xlsx';
        ExcelApp.Cells[1,1].value :=  '夜班看板數據';
        ExcelApp.Cells[3,1].value := '行數';
        ExcelApp.Cells[3,2].value := '纖體/機台';
        ExcelApp.Cells[3,3].value := '機種';
        ExcelApp.Cells[3,4].value := '20時';
        ExcelApp.Cells[3,5].value := '21時';
        ExcelApp.Cells[3,6].value := '22時';
        ExcelApp.Cells[3,7].value := '23時';
        ExcelApp.Cells[3,8].value := '0時';
        ExcelApp.Cells[3,9].value := '1時';
        ExcelApp.Cells[3,10].value := '2時';
        ExcelApp.Cells[3,11].value := '3時';
        ExcelApp.Cells[3,12].value := '4時';
        ExcelApp.Cells[3,13].value := '5時';
        ExcelApp.Cells[3,14].value := '6時';
        ExcelApp.Cells[3,15].value := '7時';
        ExcelApp.Cells[3,18].value := '總投入數';
    end;

    ExcelApp.Cells[3,1].value := '行數';
    ExcelApp.Cells[3,2].value := '纖體/機台';
    ExcelApp.Cells[3,3].value := '機種';
    ExcelApp.Cells[3,16].value := '目標直通率';
    ExcelApp.Cells[3,17].value := '實際總直通率';
    ExcelApp.Cells[1,1].Font.Size := 32;
    ExcelApp.Cells[1,1].Font.Name := 'Tahoma';
    ExcelApp.Cells[1,1].Font.Bold := true;
    ExcelApp.Cells[1,1].Font.Color :=clBlue;
    ExcelApp.Rows[3].Font.Size := 14;
    ExcelApp.Rows[3].Font.Bold := true;
    ExcelApp.Range['A3:R3'].Interior.Color :=clBlue;
    ExcelApp.Rows[3].Font.Color :=clWhite;
    ExcelApp.Range['A1:R2'].Merge;
    ExcelApp.Columns[1].ColumnWidth := 5;
    ExcelApp.Columns[2].ColumnWidth := 18;
    ExcelApp.Columns[3].ColumnWidth := 12;
    for i:= 0 to 11 do begin
         ExcelApp.Columns[i+4].ColumnWidth := 8.5;
    end;
    ExcelApp.Columns[4].ColumnWidth := 12;
    ExcelApp.Columns[16].ColumnWidth := 15;
    ExcelApp.Columns[17].ColumnWidth := 15;
    ExcelApp.Columns[18].ColumnWidth := 10;
    QryData.First;

    sFristPDLine :=  QryData.FieldByName('PDLINE_NAME').AsString ;
    PDLINECount :=0;
    for  i:=0 to  QryData.RecordCount-1  do
    begin
          sPDLineName :=    QryData.FieldByName('PDLINE_NAME').AsString ;
          if  sPDLineName <>  sFristPDLine  then
          begin
            sFristPDLIne :=  sPDLineName;
            ExcelApp.Cells[PDLINECount+4,1].Value:= PDLINECount+1;
            inc(PDLINECount);
          end;
          QryData.Next;
    end;
    PDLINECount :=0;
    QryData.First;
    for  i:=0 to QryData.RecordCount-1 do
    begin
          Application.ProcessMessages();
          sPDLineName :=    QryData.FieldByName('PDLINE_NAME').AsString ;
          sSpy :=  QryData.FieldByName('FPY_YIELD').AsString ;
          sModel := QryData.FieldByName('Model_NAME').AsString ;
          sTargetYield :=   QryData.FieldByName('Cycle_Time').AsString ;
          sWorkTime :=  QryData.FieldByName('Work_TIME').AsString ;
          sRemark :=  QryData.FieldByName('Remark').AsString ;
          CurrentTime :=0;
          for j:=0 to 11 do begin
              iPos :=  Pos('時',ExcelApp.Cells[3,j+4].Value);

              if  sWorkTime = Copy(ExcelApp.Cells[3,j+4].Value,1,iPos-1) then begin
                  CurrentTime := j+1;
              end;
          end;
          if sPDLineName <> sFristPDLine then begin
              ExcelApp.Cells[PDLINECount+4,1].Value:= PDLINECount+1;
              ExcelApp.Cells[PDLINECount+4,2].Value:= sPDLineName+sRemark;
              ExcelApp.Cells[PDLINECount+4,16].Value:= sTargetYield+'%';
              ExcelApp.Cells[PDLINECount+4,3].Value:= sModel;
              Inc(PDLINECount);
              sFristPDLIne := sPDLineName;
          end;

          ExcelApp.Cells[PDLINECount+3,CurrentTime+3].Value := sSpy+'%';

          if StrToFloat(sSPY) <  StrToFloat(sTargetYield)   then
                  ExcelApp.Cells[PDLINECount+3,CurrentTime+3].Interior.Color :=rgb(250,169,227);

          QryData.Next;
    end;
  
    QueryTotalYield(QryData);

    if QryData.IsEmpty then exit;
    QryData.First;
    for  i:=0 to  QryData.RecordCount-1  do   begin
        sPDLineName :=    QryData.FieldByName('PDLINE_NAME').AsString ;
        if    sPDLineName = '' then exit;

        sSPY :=    QryData.FieldByName('FPY_YIELD').AsString ;
        sTotalQty :=  QryData.FieldByName('Total_QTY').AsString ;
        for j:=0 to    PDLINECount-1 do begin
            if ExcelApp.Cells[j+4 ,2].Value <> '' then begin
                iPos :=Pos('自動', ExcelApp.Cells[j+4 ,2].Value );
                if iPos >0 then
                    sRPDLINE := Copy(ExcelApp.Cells[j+4 ,2].Value ,1,
                                        Length(ExcelApp.Cells[j+4 ,2].Value)-6)
                else
                    sRPDLINE := ExcelApp.Cells[j+4 ,2].Value;

                if  sPDLineName  = sRPDLINE then begin
                    ExcelApp.Cells[j+4 ,17].Value := sSPY+'%';
                    ExcelApp.Cells[j+4 ,18].Value := sTotalQty;
                    sFTYield := ExcelApp.Cells[j+4 ,16].Value;
                    sFAYield := ExcelApp.Cells[j+4 ,17].Value;
                    if  sFAYield <  sFTYield then  begin
                        ExcelApp.Cells[j+4 ,17].Interior.Color :=clRed;
                        sFailPdline := sFailPdline+''''+ sPDLineName+''',';
                    end;

                    if sFAYield >=  sFTYield then
                         ExcelApp.Cells[j+4 ,17].Interior.Color :=clGreen;

                    if  (sFAYield >= sFTYield-0.02 ) and
                        (sFAYield < sFTYield ) then
                        ExcelApp.Cells[j+4 ,17].Interior.Color :=clYellow;

                end;
            end;
        end;
        QryData.Next;
    end;
    for i:=1 to PDLINECount+3 do
         ExcelApp.Rows[i].RowHeight := 40;
    sFailPdline :=Copy(sFailPdline,1,Length(sFailPdline)-1);
    QueryDefect(QryTemp,sStartTime,sEndDateTime);

    ExcelApp.Cells[PDLINECount+5 ,2].Value := '不良明細';
    ExcelApp.ActiveSheet.Range['B'+InttoStr(PDLINECount+5) +':E'+InttoStr(PDLINECount+5)].Merge;
    ExcelApp.ActiveSheet.Range['B'+InttoStr(PDLINECount+5) +':E'+InttoStr(PDLINECount+6)].Font.Color :=clBlue;
    ExcelApp.ActiveSheet.Range['B'+InttoStr(PDLINECount+5) +':E'+InttoStr(PDLINECount+6)].Font.Size :=14;
    ExcelApp.ActiveSheet.Range['B'+InttoStr(PDLINECount+5) +':E'+InttoStr(PDLINECount+6)].Font.Bold :=true;
    ExcelApp.Cells[PDLINECount+6 ,2].Value := '纖體/機台';
    ExcelApp.Cells[PDLINECount+6 ,3].Value := '站別';
    ExcelApp.Cells[PDLINECount+6 ,4].Value := '不良現象';
    ExcelApp.Cells[PDLINECount+6 ,5].Value := '數量';

    if not QryTemp.IsEmpty then begin
       QryTemp.First;
       for i:=0 to QryTemp.RecordCount-1 do begin
          ExcelApp.Cells[PDLINECount+7+i ,2].Value := QryTemp.FieldByName('Pdline_name').AsString;
          ExcelApp.Cells[PDLINECount+7+i ,3].Value := QryTemp.FieldByName('Process_name').AsString;
          ExcelApp.Cells[PDLINECount+7+i ,4].Value := QryTemp.FieldByName('Defect_Desc').AsString;
          ExcelApp.Cells[PDLINECount+7+i ,5].Value := QryTemp.FieldByName('Defect_Qty').AsString;
          QryTemp.Next;
       end;
    end;
    ExcelApp.ActiveSheet.Range['B'+InttoStr(PDLINECount+5) +':E'+InttoStr(PDLINECount+6+i)].HorizontalAlignment :=3;
    ExcelApp.ActiveSheet.Range['B'+InttoStr(PDLINECount+5) +':E'+InttoStr(PDLINECount+6+i)].VerticalAlignment :=2;
    ExcelApp.ActiveSheet.Range['B'+InttoStr(PDLINECount+5) +':E'+InttoStr(PDLINECount+6+i)].Borders[1].Weight := 2;
    ExcelApp.ActiveSheet.Range['B'+InttoStr(PDLINECount+5) +':E'+InttoStr(PDLINECount+6+i)].Borders[2].Weight := 2;
    ExcelApp.ActiveSheet.Range['B'+InttoStr(PDLINECount+5) +':E'+InttoStr(PDLINECount+6+i)].Borders[3].Weight := 2;
    ExcelApp.ActiveSheet.Range['B'+InttoStr(PDLINECount+5) +':E'+InttoStr(PDLINECount+6+i)].Borders[4].Weight := 2;

    ExcelApp.ActiveSheet.Range['A1:R'+IntToStr(PDLINECount+3)].HorizontalAlignment :=3;
    ExcelApp.ActiveSheet.Range['A1:R'+IntToStr(PDLINECount+3)].VerticalAlignment :=2;
    ExcelApp.ActiveSheet.Range['A3:R'+IntToStr(PDLINECount+3)].Font.Size :=11;
    ExcelApp.ActiveSheet.Range['A3:R'+IntToStr(PDLINECount+3)].Font.Name :='Arial';
    ExcelApp.ActiveSheet.Range['A3:R'+IntToStr(PDLINECount+3)].Font.Bold :=True;
    ExcelApp.ActiveSheet.Range['B4:R'+IntToStr(PDLINECount+3)].Font.Color :=clBlue;
    ExcelApp.ActiveSheet.Range['A4:A'+IntToStr(PDLINECount+3)].Font.Color :=clRed;
    ExcelApp.WorkSheets[2].Delete;
    ExcelApp.WorkSheets[2].Delete;
    ExcelApp.WorkSheets[1].Activate;
    ExcelApp.ActiveWorkbook.SaveAs(sFileName);
    ExcelApp.Quit;
    ExcelApp :=Unassigned;

end;



function TuMainForm.AddZero(s:string;HopeLength:Integer):String;
begin
   Result:=StringReplace(Format('%'+IntToStr(HopeLength)+'s',[s]),' ','0',[rfIgnoreCase,rfReplaceAll]);
end;

procedure TuMainForm.FormCreate(Sender: TObject);
begin
    StrLstPDLineID :=TStringList.Create;
    //width :=SCREEN.WIDTH;
   // height :=SCREEN.Height;
end;

function TuMainForm.GetSysDate:TDateTime;
begin
    Qrytemp.Close;
    Qrytemp.CommandText := 'select SysDate from  dual';
    Qrytemp.Open;
    result := Qrytemp.fieldbyname('SYSDate').AsDateTime;
end;

procedure TuMainForm.SendMail(attachmentFilePath:String;AddressList:TStringList);
var i,LowerCount,IsFind :integer;
    sMaileMessage:string;
begin
   IsFind :=0;
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
           if sSHift ='D' then  begin
               Subject:= FormatDateTime('YYYY/MM/DD ',GetSysDate)+'白班車間電視看板數據';
           end else begin
               Subject:= FormatDateTime('YYYY/MM/DD ',GetSysDate)+'晚班車間電視看板數據';
           end;
            From.Address:='MES_Sajet@foxlink.com';

            for i :=0 to  AddressList.Count-1 do begin
               Recipients.Add;
               Recipients[i].Address:= AddressList.Strings[i];
            end;
              if sSHift ='D' then  begin
                  sMaileMessage:='Dear All:'+#13+'  '+FormatDateTime('YYYY/MM/DD ',GetSysDate)+  '白班車間電視看板數據如下'+#13;
              end else begin
                  sMaileMessage:='Dear All:'+#13+'  '+FormatDateTime('YYYY/MM/DD ',GetSysDate)+  '晚班車間電視看板數據如下'+#13;
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


function TuMainForm.QueryDefect(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    //QryTemp1.Params.CreateParam(ftstring,'pdline',ptInput);
    QryTemp1.CommandText:= ' select * from ( select  pdline_name,Process_name,Process_Code,defect_desc ,count(*) defect_qty from  '+
                           ' (select c.pdline_NAME,e.Process_name,e.Process_Code, a.Serial_number  ,B.DEFECT_CODE ,B.DEFECT_DESC, '+
                           ' to_char(a.REC_TIME,''YYYYMMDDHH24'' ) as "DATETIME",to_number(to_char(a.REC_TIME,''YYYY'')) as "DATE", '+
                           ' to_number(to_char(a.REC_TIME,''HH24'')) as "TIME", a.defect_QTY from sajet.g_SN_defect_first a, '+
                           ' SAJET.sys_defect B,SAJET.SYS_PDLINE C ,SAJET.SYS_PDLINE_MONITOR_BASE d ,sajet.SYS_Process e ,sajet.SYS_Process f '+
                           ' where a.PDLINE_ID =c.PDLINE_ID and a.defect_ID =B.DEFECT_ID  and a.rec_TIME >=to_date(:StartTime, ''yyyymmddhh24miss'') '+
                           ' and a.process_id =e.process_id and d.process_id =f.process_id and d.pdline_id =a.pdline_id and e.process_code <= f.Process_code '+
                           ' and a.rec_TIME <to_date(:EndTime,''yyyymmddhh24miss'' ) and c.PDLINE_NAME in ( '+sFailPdline+' ) order by datetime,c.pdline_NAME,a.Serial_number)'+
                           ' group by pdline_name, Process_name,Process_Code,defect_desc ) order by pdline_name,Process_Code,defect_qty desc ';
   // QryTemp1.Params.ParamByName('pdline').AsString :=sFailPdline;
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sEndTime;
    QryTemp1.Open;
end;


end.
