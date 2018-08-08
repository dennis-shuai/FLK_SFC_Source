unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DB, DBClient, MConnect, SConnect, ObjBrkr, ComObj,
  IdComponent, IdTCPConnection, IdTCPClient, IdMessageClient, IdSMTP,
  IdBaseComponent, IdMessage,Excel2000,DateUtils, StdCtrls,IniFiles;

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
    QryTemp4: TClientDataSet;
    Memo3: TMemo;
    mmo1: TMemo;
    mmo2: TMemo;
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
      iModelCount,processCount:integer;
      sModelName,sFileName,sLogFileName,sStartTime,sEndTime,sDStartTIme,sDEndTime,sAllProcess,startHour,endHour,sSegStart,sSegEnd:string;
      StartTime_List,EndTime_list,TotalTarget_List,TotalSPY_List,TotalModel_list,Week_list:TStringList;
      function  LoadApServer : Boolean;
      function  GetSysDate:TDatetime;
      procedure SendMail(attachmentFilePath:String;AddressList:TStringList);
      procedure QueryModel(QryTemp1:TClientDataset;StartTime,EndTime:string);
      function  QueryOutput(QryTemp1:TClientDataset;StartTime,EndTime:String):boolean;
      function  QueryDefect(QryTemp1:TClientDataset;StartTime:String;EndTime:String;PROCESS_NAME:string):boolean;
      function  QueryDefectCode(QryTemp1:TClientDataset;StartTime:String;EndTime:String;PROCESS_NAME:string):boolean;
      function  QueryProcessName(QryTemp1:TClientDataset;StartTime:String;EndTime:String):boolean;
      function  GetDateTimeList():boolean;
      procedure QueryTop3DEFECTCode(QryTemp4:TClientDataSet;Start_Time,End_Time:string);
      procedure QueryTop3DEFECTYield(QryTemp4:TClientDataSet;START_DATE,END_DATE,Start_Time,End_Time,ALL_Defect_Code:string);
      procedure ExportReport;
      procedure SendSettingMail(sMessage:string);
      procedure GetYieldByStage;
      function  GetWIPQTY(model_name,Process_Name,PDLINE_NAME:string): string;
      function  GetSMTWIPQTY (model_name:string): string;
      function  GetWIPWO (model_name,stage_name:string):string;
      function  GetCOBWIPWO (model_name,stage_name:string): string;
 end;

var
  uMainForm: TuMainForm;


implementation

{$R *.dfm}


type
  TModelRecord = record
   ModelName  : string;
   SPYTarget:   string;
   ProcessList: array [0..29] of string;
   Stagelist:   array [0..29] of string;
   SPYList:     array [0..29] of string;
   Input:       array [0..29] of string;
   Output:      array [0..29] of string;
end;

type
  TSMTModelRecord = record
   ModelName  : string;
   Input:string;
   Output:string;
   FPY:string;
   WIP:string;
   WIPWO:string;
end;

type
  TCOBModelRecord = record
   ModelName  : string;
   Input:string;
   Output:string;
   FPY:string;
   WIP:string;
   WIPWO:string;
end;

type
  TCMModelRecord = record
   ModelName  : string;
   Input:string;
   Output:string;
   SPYTarget:string;
   FPY:string;
   WIP:string;
   WIPWO:string;
end;

var  AllModelArray:array of TModelRecord;
var  SMTReordlist:array of TSMTModelRecord;
var  COBReordlist:array of TCOBModelRecord;
var  CmReordlist: array of TCMModelRecord;

procedure TuMainForm.GetYieldByStage;
var ii,jj,k,m,n,processCount:integer;
    SMTYield,COBYield,CMYield:double;
    SMTModelYield :array of string ;
    COBModelYield :array of string ;
    CMModelYield : array of string ;
    sStage,sProcess:string;
begin
     processCount := 29;
     mmo1.Lines.Add('start get yield by stage....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
     SetLength(SMTModelYield,iModelCount);
     SetLength(COBModelYield,iModelCount);
     SetLength(CMModelYield, iModelCount);

    //計算各段的良率---
     for ii:=0 to  iModelCount-1 do
     begin
          SMTYield :=1;
          COBYield :=1;
          CMYield  :=1;

          if  AllModelArray[ii].ModelName <>'' then
          begin
             mmo1.Lines.Add('start get smt yield ....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
             for jj :=0 to  processCount-1 do
             begin
                if (AllModelArray[ii].Stagelist[jj]= 'SMT') then
                begin
                    SMTYield := SMTYield* StrToFloat(AllModelArray[ii].SPYList[jj]);
                    mmo1.Lines.Add('start get smt yield '+IntToStr(jj+1)+' ....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                end;
             end;

             mmo1.Lines.Add('start get cob yield  ....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
             for jj :=0 to  processCount-1 do begin
                 if (AllModelArray[ii].Stagelist[jj]= 'COB') then
                 begin
                    COBYield := COBYield* StrToFloat(AllModelArray[ii].SPYList[jj]);
                    mmo1.Lines.Add('start get cob yield '+IntToStr(jj+1)+' ....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                 end;
             end;
             mmo1.Lines.Add('start get cm yield ....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
             for jj :=0 to  processCount-1 do
             begin
                if (AllModelArray[ii].Stagelist[jj]= 'CM') and (AllModelArray[ii].ProcessList[jj] ='AutoTest') then
                begin
                    CMYield :=  StrToFloat(AllModelArray[ii].SPYList[jj]);
                    //CMYield := CMYield* StrToFloat(AllModelArray[ii].SPYList[jj]);
                    mmo1.Lines.Add('start get cm yield '+IntToStr(jj+1)+' ....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                end;
             end;
             mmo1.Lines.Add('start get all yield  array'+IntToStr(ii+1)+' ....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
             SMTModelYield[ii] := FormatFloat('0.00%',SMTYield*100);
             COBModelYield[ii] :=FormatFloat('0.00%',COBYield*100);
             CMModelYield[ii] :=FormatFloat('0.00%',CMYield*100);
          end;
     end;

    K:=0;
    M:=0;
    n:=0;


    //計算各段的投入產出
    mmo1.Lines.Add('start get output by stage....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
    for ii:=0 to  iModelCount-1 do
    begin
       if  AllModelArray[ii].ModelName <>'' then
       begin
          mmo1.Lines.Add('start get process count '+IntToStr(processCount)+'...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
          for jj :=0 to  processCount-1 do
          begin
              sStage :=  AllModelArray[ii].Stagelist[jj];
              sProcess := AllModelArray[ii].ProcessList[jj];
              mmo1.Lines.Add('start get stage:'+ sStage +'...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
              mmo1.Lines.Add('start get process:'+ sProcess +'...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
              if (sStage = 'SMT') and ((sProcess ='SMT_INPUT_T') or ( sProcess = 'SMT_VI_T')) then
              begin
                    mmo1.Lines.Add('start set smt array length '+IntToStr(k+1)+'....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                    SetLength(SMTReordlist,k+1);
                    if  AllModelArray[ii].ProcessList[jj] ='SMT_INPUT_T' then
                    begin

                        mmo1.Lines.Add('start get smt Input....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                        SMTReordlist[k].ModelName := AllModelArray[ii].ModelName;
                        SMTReordlist[k].Input := AllModelArray[ii].Input[jj];
                        SMTReordlist[k].FPY := SMTModelYield[ii] ;
                        mmo1.Lines.Add('End get smt Input....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                    end;

                    if  AllModelArray[ii].ProcessList[jj] ='SMT_VI_T' then
                    begin
                        if K >0 then
                         if  AllModelArray[ii].ModelName  =  SMTReordlist[k-1].ModelName then
                            K:=K-1;
                         mmo1.Lines.Add('start get smt Output....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                        SMTReordlist[k].ModelName := AllModelArray[ii].ModelName;
                        SMTReordlist[k].Output := AllModelArray[ii].Output[jj];
                        SMTReordlist[k].FPY := SMTModelYield[ii];
                    end;
                    inc(k);
              end;

              if (sStage = 'COB') and ( ( sProcess ='RANK PCB')or (  sProcess='HODLE MOUNT')) then
              begin
                    mmo1.Lines.Add('start set Cob array length '+IntToStr(m+1)+'....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                    SetLength(COBReordlist,m+1);
                    if (AllModelArray[ii].ProcessList[jj] = 'RANK PCB')   then begin
                         mmo1.Lines.Add('start get COB Input....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                        COBReordlist[m].ModelName := AllModelArray[ii].ModelName;
                        COBReordlist[m].Input := AllModelArray[ii].Input[jj];
                        COBReordlist[m].FPY := COBModelYield[ii] ;
                    end;

                    if  AllModelArray[ii].ProcessList[jj] ='HODLE MOUNT' then begin
                        if m >0 then
                         if  AllModelArray[ii].ModelName  =  COBReordlist[m-1].ModelName then
                            m:=m-1;
                        mmo1.Lines.Add('start get COB Output....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                        COBReordlist[m].ModelName := AllModelArray[ii].ModelName;
                        COBReordlist[m].FPY := COBModelYield[ii] ;
                        COBReordlist[m].Output := AllModelArray[ii].Output[jj];
                    end;
                    inc(m);
              end;

               if  (sStage = 'CM') and (sProcess = 'AutoTest')   then
               begin
                     mmo1.Lines.Add('start set CM array length '+IntToStr(n+1)+'....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                     SetLength(CMReordlist,n+1);
                    if ( AllModelArray[ii].ProcessList[jj]= 'AutoTest')  then begin
                        mmo1.Lines.Add('start get CM Input....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                        CMReordlist[n].ModelName := AllModelArray[ii].ModelName;
                        CMReordlist[n].SPYTarget :=  AllModelArray[ii].SPYTarget;
                        CMReordlist[n].Input := AllModelArray[ii].Input[jj];
                        CMReordlist[n].FPY := CMModelYield[ii] ;
                    end;

                    if  AllModelArray[ii].ProcessList[jj] ='AutoTest' then begin
                        if n >0 then
                          if  AllModelArray[ii].ModelName  =  CMReordlist[n-1].ModelName then
                             n:=n-1;
                        mmo1.Lines.Add('start get CM Output....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                        CMReordlist[n].ModelName := AllModelArray[ii].ModelName;
                        CMReordlist[n].SPYTarget :=  AllModelArray[ii].SPYTarget;
                        CMReordlist[n].Output := AllModelArray[ii].Output[jj];
                        CMReordlist[n].FPY := CMModelYield[ii] ;
                    end;
                    inc(n);
               end;

          end;
       end;
    end;

    mmo1.Lines.Add('start get K: '+IntToStr(k)+'..M: '+IntToStr(m)+'...N: '+IntToStr(n)+'...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));

    for ii:=0 to k-1 do
    begin
       if SMTReordlist[ii].Input ='' then
            SMTReordlist[ii].Input :='0';
       if SMTReordlist[ii].outPut ='' then
       begin
            SMTReordlist[ii].outPut :='0';
            SMTReordlist[ii].FPY := '0%' ;
       end;
       if (SMTReordlist[ii].Input ='0' )and (SMTReordlist[ii].Output ='0') then
            SMTReordlist[ii].ModelName :='';
    end;


    for ii:=0 to m-1 do begin
       if COBReordlist[ii].Input ='' then
          COBReordlist[ii].Input :='0';
       if COBReordlist[ii].outPut ='' then begin
          COBReordlist[ii].outPut :='0';
          COBReordlist[ii].FPY := '0%' ;
       end;
       if (COBReordlist[ii].Input ='0') and  (COBReordlist[ii].outPut ='0') then
          COBReordlist[ii].ModelName :='';
    end;

    for ii:=0 to n-1 do begin
       if CMReordlist[ii].Input ='' then
          CMReordlist[ii].Input :='0';
       if CMReordlist[ii].outPut ='' then begin
          CMReordlist[ii].outPut :='0';
          CMReordlist[ii].FPY := '0%' ;
       end;

       if (CMReordlist[ii].Input ='0') and (CMReordlist[ii].outPut ='0') then
           CMReordlist[ii].ModelName :='';
    end;

    for ii:=0 to K-1 do begin
         SMTReordlist[ii].WIP := GetSMTWIPQTY(SMTReordlist[ii].ModelName );
         SMTReordlist[ii].WIPWO := GetWIPWO(SMTReordlist[ii].ModelName,'SMT');
         mmo1.Lines.Add('start get smt WIP '+IntToStr(ii)+'...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
    end;

    for ii:=0 to m-1 do begin
        COBReordlist[ii].WIP := GetWIPQTY(COBReordlist[ii].ModelName,'RANK PCB','COB_DB_A');
        COBReordlist[ii].WIPWO := GetCOBWIPWO(COBReordlist[ii].ModelName,'COB');
        mmo1.Lines.Add('start get COB WIP '+IntToStr(ii)+'...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
    end;

    for ii:=0 to n-1 do
    begin
        if Copy(CMReordlist[ii].ModelName,1,3)='368' then begin
            CMReordlist[ii].WIP := GetWIPQTY( CMReordlist[ii].ModelName ,'AOO','3F_Particle01' ) ;
            CMReordlist[ii].WIPWO := GetWIPWO(CMReordlist[ii].ModelName ,'CM');
        end
        else begin
            CMReordlist[ii].WIP :=  GetWIPQTY(CMReordlist[ii].ModelName  ,'AutoTest','Depanel Room' );
            CMReordlist[ii].WIPWO := GetWIPWO(CMReordlist[ii].ModelName ,'CM');
        end;
         mmo1.Lines.Add('start get CM WIP '+IntToStr(ii)+'...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
    end;


end;

function TuMainForm.GetSMTWIPQTY(model_name:string):string;
begin

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Model',ptInput);
    QryTemp.CommandText := 'select NVL(SUM(WIP_QTY),0) WIP_QTY  from sajet.g_SN_STATUS a,sajet.sys_part c,sajet.sys_model d,'+
                           ' sajet.g_wo_base e  where a.work_order =e.work_order and E.WO_STATUS <''5'' and A.MODEL_ID ='+
                           ' C.PART_ID and  c.model_id = d.MODEL_ID  and '+
                           ' d.MODEL_NAME like :Model  and a.WORK_ORDER like ''NMS%'' and A.PDLINE_ID =0 and a.TERMINAL_ID=0 ';
    QryTemp.Params.ParamByName('model').AsString := model_name;
    QryTemp.Open;

    result :=  QryTemp.fieldbyname('WIP_QTY').Asstring;

end;

function  TuMainForm.GetWIPWO (model_name,stage_name:string): string;
var i:integer;
    sWO:string;
begin
    sWO:='';
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Model',ptInput);
    QryTemp.Params.CreateParam(ftString,'stage',ptInput);
    QryTemp.Params.CreateParam(ftString,'StartTime',ptInput);
    QryTemp.Params.CreateParam(ftString,'EndTime',ptInput);
    QryTemp.CommandText := ' select distinct WORK_ORDER from (select work_order,MODEL_ID,STAGE_ID,PROCESS_ID, '+
                           ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  WORK_DATE ,FAIL_QTY,PASS_QTY '+
                           ' from SAJET.G_SN_COUNT where WORK_ORDER NOT LIKE ''RM%'') a, sajet.sys_process b ,sajet.sys_stage c,sajet.sys_part d,sajet.sys_model e '+
                           ' where a.process_id =b.process_id and a.stage_id =c.stage_id and d.part_id=a.model_id and d.model_id=e.model_id '+
                           ' and e.Model_Name like :model and c.stage_name =:stage and a.PASS_QTY+a.FAIL_QTY <>0 and'+
                           ' a.work_date >= :StartTime and a.work_date < :EndTime  and b.Process_name not like ''%PACK%'' and b.Process_name not like ''%PGI%''';
    QryTemp.Params.ParamByName('StartTime').AsString := sSegStart;
    QryTemp.Params.ParamByName('EndTime').AsString := sSegEnd;
    QryTemp.Params.ParamByName('model').AsString := model_name;
    QryTemp.Params.ParamByName('stage').AsString := stage_name;
    QryTemp.Open;
    QryTemp.First;
    for i:=0 to  QryTemp.recordcount-1 do  begin
       sWO := sWO+ QryTemp.fieldbyname('work_order').Asstring+',';
       QryTemp.Next;
    end;
    result :=copy(swo,1,length(sWo)-1);
end;

function  TuMainForm.GetCOBWIPWO (model_name,stage_name:string): string;
var i:integer;
    sWO:string;
begin
    sWO:='';
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Model',ptInput);
    QryTemp.Params.CreateParam(ftString,'stage',ptInput);
    QryTemp.Params.CreateParam(ftString,'StartTime',ptInput);
    QryTemp.Params.CreateParam(ftString,'EndTime',ptInput);
    QryTemp.CommandText := ' select distinct WORK_ORDER from (select work_order,MODEL_ID,STAGE_ID,PROCESS_ID, '+
                           ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  WORK_DATE ,FAIL_QTY,PASS_QTY '+
                           ' from SAJET.G_SN_COUNT where WORK_ORDER NOT LIKE ''RM%'') a,sajet.sys_process b ,sajet.sys_stage c,sajet.sys_part d,sajet.sys_model e '+
                           ' where a.process_id =b.process_id and a.stage_id =c.stage_id and d.part_id=a.model_id and d.model_id=e.model_id '+
                           ' and e.Model_Name like :model and c.stage_name =:stage and a.PASS_QTY+a.FAIL_QTY <>0 and a.work_order like ''NM%'' and '+
                           ' a.work_date >= :StartTime and a.work_date < :EndTime and b.Process_name in (''RANK PCB'',''DIE BOND'',''HODLER MOUNT'')';
    QryTemp.Params.ParamByName('StartTime').AsString := sSegStart;
    QryTemp.Params.ParamByName('EndTime').AsString := sSegEnd;
    QryTemp.Params.ParamByName('model').AsString := model_name;
    QryTemp.Params.ParamByName('stage').AsString := stage_name;
    QryTemp.Open;
    QryTemp.First;
    for i:=0 to  QryTemp.recordcount-1 do  begin
       sWO := sWO+ QryTemp.fieldbyname('work_order').Asstring+',';
       QryTemp.Next;
    end;
    result :=copy(swo,1,length(sWo)-1);
end;



function TuMainForm.GetWIPQTY(model_name,PROCESS_NAME,PDLINE_NAME:string):string;
begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Model',ptInput);
    QryTemp.Params.CreateParam(ftString,'Process',ptInput);
    QryTemp.Params.CreateParam(ftString,'PDLINE',ptInput);
    QryTemp.CommandText := ' select  NVL(SUM(WIP_QTY),0) WIP_QTY  from sajet.g_SN_STATUS a,SAJET.SYS_PDLINE b,sajet.sys_part c,sajet.sys_model d,'+
                           ' sajet.g_wo_base e,sajet.sys_process f where a.work_order =e.work_order and E.WO_STATUS <''5'' and A.MODEL_ID ='+
                           ' C.PART_ID and  c.model_id = d.MODEL_ID and F.PROCESS_ID =A.WIP_PROCESS and A.PDLINE_ID =B.PDLINE_ID and '+
                           ' d.MODEL_NAME like :Model  and a.WORK_ORDER like ''NM%'' and f.Process_NAME = :process and b.PDLINE_NAME =:PDLINE';
    QryTemp.Params.ParamByName('model').AsString := model_name;
    QryTemp.Params.ParamByName('PROCESS').AsString := PROCESS_NAME;
    QryTemp.Params.ParamByName('PDLINE').AsString := PDLINE_NAME;
    QryTemp.Open;
    result :=  QryTemp.fieldbyname('WIP_QTY').Asstring;

end;

function TuMainForm.LoadApServer : Boolean;
var
  F : TextFile;
  S : String;
begin
  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  If not FileExists(ExtractFilePath(Paramstr(0))+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,ExtractFilePath(Paramstr(0))+'\ApServer.cfg');
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
var i,HCount:integer;
sStart,sEnd,sWeek:string;
tStartDate:TDATETIME;
cfgFileName:TiniFile;
m_Date :TDateTime;
begin
    StartTime_List :=TStringList.Create;
    EndTime_List :=TStringList.Create;
    Week_List :=  TStringList.Create;
    m_Date := getsysdate;
   // m_Date :=  StrToDateTime('2016/08/16 10:01:00');

    cfgFileName := TiniFile.Create('.\Config.cfg');
    startHour :=cfgFileName.ReadString(IntToStr(StrToInt(FormatDatetime('HH' ,m_Date))),'Start','0') ;
    endHour :=cfgFileName.ReadString(IntToStr(StrToInt(FormatDatetime('HH' ,m_Date))),'End','0') ;
    cfgFileName.Free;

    if StrToInt(FormatDatetime('HH' ,m_Date))<= 8 then
    begin
          tStartDate  :=Yesterday;
    end else
         tStartDate :=today;
        // tStartDate :=Yesterday;
    HCount := Round((m_Date-tStartDate-1/3)*24) -1 ;

    for I:=0 to  HCount do begin
       sStart := FormatDatetime('YYYYMMDDHH',tStartDate+1/3+1/24*i);
       sEnd  := FormatDatetime('YYYYMMDDHH',tStartDate+1/3+1/24*(i+1)) ;

       StartTime_List.Add(sStart);
       EndTime_List.Add(sEnd);

    end;


    for I:=0 to 23  do begin
         sWeek := FormatDatetime('HH',tStartDate+1/3+1/24*i);
         Week_List.Add(sWeek);
    end;
    sStartTime := FormatDatetime('YYYYMMDDHH',tStartDate+1/3);
    sEndTime := FormatDatetime('YYYYMMDDHH', m_Date);
    if StrToInt(endHour)<StrToInt(StartHour) then
    begin
        sSegStart := FormatDatetime('YYYYMMDD',tStartDate)+StartHour;
        sSegEnd :=  FormatDatetime('YYYYMMDD', m_Date)+EndHour;
    end else
    begin
        sSegStart := FormatDatetime('YYYYMMDD',m_Date)+StartHour;
        sSegEnd :=  FormatDatetime('YYYYMMDD', m_Date)+EndHour;
    end;
    //sEndTime := '2014042508';
    sDStartTime :=sStartTime+':00:00';
    sDEndTime := sEndTime+':00:00';
    memo1.Lines.AddStrings(StartTime_List);
    memo2.Lines.AddStrings(EndTime_List);
    memo3.Lines.AddStrings(Week_List);

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
     sLogFileName := ExtractFilePath(Paramstr(0))+'log\'+FormatDateTime('yyyymmdd_hhmmss',getsysdate)+'.txt';
    try
       mmo1.Lines.Add('start get time....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
       GetDateTimeList();

       mmo1.Lines.Add('start export excel....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
       ExportReport;
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
       if sFileName <>'' then  begin
           mmo1.Lines.Add('start send mail....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
           SendMail(sFileName,Addresslist);
       end;
       Addresslist.Free;
    finally
       mmo1.Lines.SaveToFile(sLogFileName);
       Close;
    end;


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
                        '  from SAJET.G_SN_COUNT where WORK_ORDER NOT LIKE ''RM%'' and (PDLINE_ID <11525 OR PDLINE_ID>11534)'+
                        '  and PDLINE_ID <>11563 and PDLINE_ID <>11564  ) '+
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
    QryTemp1.CommandText:=' Select * from (Select B.PROCESS_NAME, B.PROCESS_CODE, g.stage_Name, '+
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
                          ' from SAJET.G_SN_COUNT where ( WORK_ORDER LIKE ''NMA%''  OR  WORK_ORDER LIKE ''VMA%'') and PASS_QTY +FAIL_QTY <>0 AND PROCESS_ID NOT IN(100219, 100220,100221,100243,100263)'+
                          ' AND to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00'')))   >=:StartTime and (PDLINE_ID <11525 OR PDLINE_ID>11534) and PDLINE_ID <>11563 and PDLINE_ID <>11564 '+
                          ' and to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00'')))   <:endTime )  C ,sajet.sys_part d ,sajet.sys_Part e,sajet.sys_model f,sajet.sys_stage g'+
                          ' WHERE   C.DateTime >=:StartTime and C.DateTime <:endTime   AND '+
                          ' c.model_ID =d.Part_ID and C.Model_ID = E.Part_ID and e.Model_ID= f.Model_ID and f.MOdel_Name =:Model_Name and B.PROCESS_CODE IS NOT NULL and '+
                          ' c.stage_id = g.stage_Id and '+
                          ' C.PROCESS_ID = B.PROCESS_ID GROUP BY B.PROCESS_NAME, B.PROCESS_CODE,g.stage_Name ORDER BY B.PROCESS_CODE ) where Process_name IN '+sAllProcess;

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
    QryTemp1.CommandText:= ' SELECT ALL_DEFECT,SUM(C_SN) C_SN FROM  ' +
                           ' (SELECT  DEFECT_CODE ALL_DEFECT,  C_SN '+
                           '    FROM  '+
                           '    ( select  a.WORK_ORDER, a.Serial_number,B.PROCESS_NAME ,b.Process_Code, C.Defect_Code, c.Defect_desc,1 as C_SN   '+
                                   ' from                   '+
                                   ' sajet.g_SN_defect_first a,sajet.SYS_PROCESS b,sajet.sys_defect c ,sajet.sys_part d , sajet.sys_Model e  '+
                                   ' where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and a.REC_Time >= to_date(:StartTime, ''yyyymmddhh24:mi:ss'')  '+
                                   ' and a.REC_Time <to_date(:EndTime, ''yyyymmddhh24:mi:ss'')  and a.WORK_ORDER NOT LIKE ''RM%'' '+
                                   ' and (PDLINE_ID <11525 OR PDLINE_ID>11534 ) and PDLINE_ID <>11563 and PDLINE_ID <>11564  '+
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
    QryTemp1.CommandText:= 'Select aa.defect_CODE,bb.DEFECT_DESC from (SELECT Distinct( C.DEFECT_CODE) '+
                           ' FROM SAJET.G_SN_DEFECT_FIRST A,SAJET.SYS_PROCESS B,SAJET.SYS_DEFECT C,SAJET.SYS_PART D,SAJET.SYS_MODEL E '+
                           ' WHERE A.PROCESS_ID=B.PROCESS_ID AND B.PROCESS_NAME=:PROCESS_NAME AND A.DEFECT_ID=C.DEFECT_ID AND A.WORK_ORDER NOT LIKE ''RM%'' '+
                           ' AND A.REC_TIME>=to_date(:StartTime,''yyyymmddHH24:mi:ss'') AND A.REC_TIME < to_date(:EndTime,''yyyymmddHH24:MI:SS'') '+
                           ' and (PDLINE_ID <11525 OR PDLINE_ID>11534) and PDLINE_ID <>11563 and PDLINE_ID <>11564  '+
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
    QryTemp1.CommandText:= ' SELECT * FROM (SELECT e.stage_name,B.PROCESS_NAME,B.PROCESS_CODE,SUM(FAIL_QTY)  PROCESS_FAIL, SUM(PASS_QTY) PROCESS_PASS  FROM ( select MODEL_ID,STAGE_ID,PROCESS_ID, '+
                           ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  WORK_DATE ,FAIL_QTY,PASS_QTY '+
                           ' from SAJET.G_SN_COUNT where WORK_ORDER NOT LIKE ''RM%'' and PASS_QTY + FAIL_QTY <> 0 and (PDLINE_ID <11525 OR PDLINE_ID>11534) and PDLINE_ID <>11563 and PDLINE_ID <>11564 )'+
                           ' A,SAJET.SYS_PROCESS B, SAJET.SYS_PART C,SAJET.SYS_MODEL D ,sajet.sys_stage e  '+
                           ' WHERE A.PROCESS_ID=B.PROCESS_ID AND A.WORK_DATE>=:StartTime AND A.WORK_DATE <= :EndTime  AND '+
                           '  a.stage_ID =e.stage_ID and    '+
                           ' A.MODEL_ID=C.PART_ID AND C.MODEL_ID =D.MODEL_ID AND D.MODEL_NAME=:Model_NAme  AND B.PROCESS_CODE IS NOT NULL '+
                           ' GROUP BY  e.stage_name, B.PROCESS_NAME,B.PROCESS_CODE ORDER BY PROCESS_CODE ) WHERE PROCESS_PASS>200';
    QryTemp1.Params.ParamByName('StartTime').AsString := StartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := EndTime;
    QryTemp1.Params.ParamByName('Model_Name').AsString := sModelName;
    QryTemp1.Open;
end;


procedure TuMainForm.SendMail(attachmentFilePath:String;AddressList:TStringList);
var i,LowerCount,IsFind :integer;
    sMaileMessage,stemp:string;
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
    GetYieldByStage;
    try
      IdSMTP1.Connect;
        with IdMessage1 do
          begin

              CharSet := 'UTF-8';//'gb2312'; --UTF-8
              ContentType := 'text/html';
              Subject:='時報表報->'+FormatDateTime('YYYY/MM/DD ',GetSysDate)+StartHour +'時~'+endHour+'時報表(廠內數據)';
              From.Address:='MES_Sajet@foxlink.com';

              for i :=0 to  AddressList.Count-1 do
              begin
                  Recipients.Add;
                  Recipients[i].Address:= AddressList.Strings[i];
              end;

              mmo1.Lines.Add('start send smt message ...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
              sMaileMessage := 'Dear All:';
              mmo2.Lines.Add(sMaileMessage);
              stemp:= ' '+FormatDateTime('YYYY/MM/DD ',GetSysDate)+StartHour +'時~'+endHour+'時 生產時段報表';
              sMaileMessage :=   sMaileMessage+stemp;
              mmo2.Lines.Add(stemp);
              stemp:= '   SMT生產明細如下:';
              sMaileMessage :=   sMaileMessage+stemp;
              mmo2.Lines.Add(stemp);
              IsFind :=0;
              for  I:=0 to Length(smtReordlist)-1 do
              begin
                  if smtReordlist[i].ModelName <>'' then
                  begin
                     stemp :=  '    '+format('%-20s',[smtReordlist[i].ModelName +'機種'])+
                                          format('%-12s',['待投:'+ SMTReordlist[i].WIP])+
                                          format('%-12s',['投入:'+ smtReordlist[i].Input])+
                                          format('%-12s',['產出:'+ smtReordlist[i].Output])+
                                          format('%-18s',['目標直通率:99%'])+
                                          format('%-18s',['實際直通率:'+ smtReordlist[i].FPY]) +'    在制工單:'+
                                          smtReordlist[i].WIPWO;
                     mmo1.Lines.Add('start send smt message('+smtReordlist[i].ModelName+') ...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                     sMaileMessage :=   sMaileMessage+stemp;
                     mmo2.Lines.Add(stemp);
                     isFind :=1;
                  end;
              end ;
              mmo1.Lines.Add('End send SMT message(  ...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));

              If  IsFind=0  then
              begin
                   stemp :=  '無投入和產出';
                   sMaileMessage :=   sMaileMessage+stemp;
                   mmo2.Lines.Add(stemp);
              end;

              mmo1.Lines.Add('start send Cob message ...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
              isFind :=0;
              stemp:= #13;
              sMaileMessage :=   sMaileMessage+stemp;
              mmo2.Lines.Add(stemp);

              stemp:= '   COB生產明細如下:';
              sMaileMessage :=   sMaileMessage+stemp;
              mmo2.Lines.Add(stemp);
              for  I:=0 to Length(COBReordlist)-1 do
              begin
                  if  COBReordlist[i].ModelName   <> '' then begin
                        stemp :=  '    '+format('%-20s',[COBReordlist[i].ModelName +'機種'])+
                                  format('%-12s',['待投:'+ COBReordlist[i].WIP])+
                                  format('%-12s',['投入:'+ COBReordlist[i].Input])+
                                  format('%-12s',['產出:'+ COBReordlist[i].Output])+
                                  format('%-18s',['目標直通率:99%'])+
                                  format('%-18s',['實際直通率:'+ COBReordlist[i].FPY])+'    在制工單:'+
                                  COBReordlist[i].WIPWO;
                        mmo1.Lines.Add('start send COB message('+COBReordlist[i].ModelName +') ...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                        sMaileMessage :=   sMaileMessage+stemp;
                        mmo2.Lines.Add(stemp);
                        IsFind :=1;
                  end;
              end ;
               mmo1.Lines.Add('End send COB message(  ...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
              If  IsFind=0  then
              begin
                   stemp :=  '無投入和產出';
                   sMaileMessage :=   sMaileMessage+stemp;
                   mmo2.Lines.Add(stemp);
              end;


              mmo1.Lines.Add('start send CM message ...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
              isFind :=0;
              stemp:= #13;
              sMaileMessage :=   sMaileMessage+stemp;
              mmo2.Lines.Add(stemp);

              stemp:= '   CM生產明細如下:';
              sMaileMessage :=   sMaileMessage+stemp;
              mmo2.Lines.Add(stemp);
              for  I:=0 to Length(CMReordlist)-1 do
              begin
                  if CMReordlist[i].ModelName <>'' then
                  begin
                      stemp :=  '    '+format('%-20s',[CMReordlist[i].ModelName +'機種'])+
                                              format('%-12s',['待投:'+ CMReordlist[i].WIP])+
                                              format('%-12s',['投入:'+ CMReordlist[i].Input])+
                                              format('%-12s',['產出:'+ CMReordlist[i].Output])+
                                              format('%-18s',['目標直通率:'+CMReordlist[i].SPYTarget+'%'])+
                                              format('%-18s',['實際直通率:'+ CMReordlist[i].FPY]) +'    在制工單:'+
                                              CMReordlist[i].WIPWO;
                      mmo1.Lines.Add('start send CM message('+CMReordlist[i].ModelName +') ...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
                      sMaileMessage :=   sMaileMessage+stemp;
                      mmo2.Lines.Add(stemp);
                      IsFind :=1;
                  end;
              end ;
              mmo1.Lines.Add('End send CM message(  ...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));

              If  IsFind=0  then
              begin
                   stemp :=  '無投入和產出';
                   sMaileMessage :=   sMaileMessage+stemp;
                   mmo2.Lines.Add(stemp);
              end;

              Body.Clear;
              //Body.Add(sMaileMessage);
              Body.Add(mmo2.Text);
          end;
          mmo1.Lines.Add('start send atach file('+sFileName+')...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
          mmo2.Lines.SaveToFile(ExtractFilePath(ParamStr(0))+'Report\'+FormatDateTime('yyyymmddhhmmss',getsysdate)+'.txt');
          attachmentFilePath:=sFileName;
          if FileExists(attachmentFilePath) then
          begin
              TIdAttachment.Create(IdMessage1.MessageParts,attachmentFilePath);
          end;

          mmo1.Lines.Add('start send mail ...'+FormatDateTime('yyyy/mm/dd hhmmss',getsysdate));
          IdSMTP1.Send(IdMessage1);
          mmo1.Lines.Add('end send mail...'+FormatDateTime('yyyy/mmdd hhmmss',getsysdate));
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
            Recipients[0].Address:= 'Dennis_shuai@Foxlink.com';

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
    i,j,K,L,M,FirstCount,UsedRow,AllRows,UsedHours,defect_count,count,HourCount,Repair_Qty,Process_Fail,FAIL_QTY,StartCol,EndCol,tempCount:integer;
    ExcelApp,xRange,yRange,ChartObjects: Variant;
    tempStart,tempEnd,tempHStart,tempHEnd,sProcess,FPY_Target,sXValue,stage_Name:string;
    Rowlist,SPYRowlist,FinalRowList,AllRow_list:TStringList;
    FPY,SPY,FinalYield, Total_FPY,Total_SPY,Total_FinalYield:double;
    IsFound :boolean;
    Defect_Start,Defect_End:TDateTime;
    sDefect_Start,sDefect_End,sAll_Defect,StartColName,endColName:String;
    TotalRowList,OutPutRowList,RepassRowList,overallSPYROWList:TStringList ;
begin
    mmo1.Lines.Add('query data....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
    QueryModel(QryModel, sStartTime ,sEndTime);
    if QryModel.IsEmpty then exit;
    mmo1.Lines.Add('query data ok....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
    iModelCount :=QryModel.RecordCount;
    Application.ProcessMessages();
    mmo1.Lines.Add('start excel....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
    try
        ExcelApp :=CreateOleObject('Excel.Application');
        mmo1.Lines.Add('start excel ok....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
    except
        mmo1.Lines.Add('start excel NG....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
        mmo1.Lines.SaveToFile(sLogFileName);
        Exit;
    end;
    ExcelApp.Visible := false;
    mmo1.Lines.Add('set excel  visible ok....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
    ExcelApp.displayAlerts:=false;
    mmo1.Lines.Add('set excel  displayAlerts ok....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
    try
        ExcelApp.WorkBooks.Add;
        mmo1.Lines.Add('excel  WorkBooks add ok....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
    except
        mmo1.Lines.Add('excel  WorkBooks add  NG....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
        mmo1.Lines.SaveToFile(sLogFileName);
        Exit;
    end;

    QryModel.First;
    TotalModel_List :=TStringList.Create;
    TotalTarget_List := TStringList.Create;
    TotalSPY_List := TStringList.Create;
    mmo1.Lines.Add('start start end hour ....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
    for I:= 0 to 23 do begin
        if Week_List.Strings[i] = StartHour then
            StartCOl := 5+i;
        if Week_List.Strings[i] = EndHour then
            EndCOl := 4+i;
    end;

    if EndCol< StartCOl then begin
       EndCol :=28;
    end;

    SetLength(AllModelArray,iModelCount);

    for i:=0 to  QryModel.RecordCount-1 do begin

         sModelName :=  QryModel.FieldbyName('Model_Name').AsString;
          mmo1.Lines.Add('start display ....'+sModelName+' model'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
         //sModelName :='503';
         AllModelArray[i].ModelName := sModelName;

         AllRow_list :=TStringList.Create;
         ExcelApp.Worksheets.Add(After:=ExcelApp.Sheets[i+1]);
         ExcelApp.WorkSheets[i+1].Activate;

         //設置表格名稱
         ExcelApp.WorkSheets[i+1].Name := sModelName;
         mmo1.Lines.Add('start set  start address ....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));

         try
             ExcelApp.Cells[2,2].Value :='=SUBSTITUTE(LEFT(ADDRESS(1,'+IntToStr(StartCOl)+'),3),"$","")';
             ExcelApp.Cells[2,3].Value :='=SUBSTITUTE(LEFT(ADDRESS(1,'+IntToStr(EndCOl)+'),3),"$","")';
         except
             MessageDlg('error get address,start:'+IntToStr(StartCOl)+' end :'+IntToStr(EndCOl),mtError,[mbOK],0);
         end;
         
         try
             StartColName := ExcelApp.Cells[2,2].Value;
             EndColName := ExcelApp.Cells[2,3].Value;
         except
            MessageDlg('get start end columns name error',mtError,mbOKCancel,0);
            Exit;
         end;

         ExcelApp.Cells[2,2].Value :='';
         ExcelApp.Cells[2,3].Value :='';

         //設置標題
         ExcelApp.Cells[1,1].Value :=  sModelName +' Daily Report';
         ExcelApp.Cells[1,1].Font.Size := 18;
         ExcelApp.Cells[1,1].Font.Name := 'Tahoma';
         ExcelApp.Cells[1,1].Font.Bold := false;
         ExcelApp.Cells[1,1].Font.Color :=clwhite;
         ExcelApp.Cells[1,1].Interior.Color :=rgb(0,32,96);
         ExcelApp.Rows[1].RowHeight :=28;
         ExcelApp.Range['A1:AB1'].Merge;

         ExcelApp.ActiveSheet.Range['D15:P15'].Font.Bold :=true;
         ExcelApp.ActiveSheet.Range['D15:P15'].Font.Color :=clwhite;
         ExcelApp.ActiveSheet.Range['D15:P15'].Interior.Color :=rgb(155,187,90);

         ExcelApp.ActiveSheet.Range['Q15:AB15'].Font.Bold :=true;
         ExcelApp.ActiveSheet.Range['Q15:AB15'].Font.Color :=clwhite;
         ExcelApp.ActiveSheet.Range['Q15:AB15'].Interior.Color :=rgb(155,137,90);

         ExcelApp.Cells[16,4].Value := 'Target(%)';
         ExcelApp.Cells[17,4].Value := 'FPY(%)';
         ExcelApp.Cells[18,4].Value := 'SPY(%)';
         ExcelApp.Cells[19,4].Value := 'Final Yield(%)';
         ExcelApp.Cells[15,29].Value := 'Today';
         ExcelApp.ActiveSheet.Range['AC15:AC19'].Interior.Color :=rgb(230,185,184);
         ExcelApp.ActiveSheet.Range['AC15:AC19'].Font.Bold :=True;
         //設置列寬
         ExcelApp.Columns[1].ColumnWidth :=12.5;
         ExcelApp.Columns[2].ColumnWidth :=5;
         ExcelApp.Columns[3].ColumnWidth :=12;
         ExcelApp.Columns[4].ColumnWidth :=12;
         for j:=0 to 23 do ExcelApp.Columns[5+j].ColumnWidth :=5.5;

        // ExcelApp.ActiveSheet.Range['D15:D19'].Interior.Color :=rgb(194,214,154);
        // ExcelApp.ActiveSheet.Range['D15:D19'].Font.Bold :=True;
         mmo1.Lines.Add('start add chart....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
         //添加圖表
         ChartObjects :=ExcelApp.ActiveSheet.ChartObjects.add(192,30,946,200);
         ChartObjects.Chart.ChartType:=xlLineMarkers;
         chartObjects.chart.SetSourceData(ExcelApp.ActiveSheet.Range['D15:AB19']);
         ChartObjects.Chart.PlotBy:=xlRows;
         if  StrToInt(FormatDateTime('HH',GetSysdate)) <= 8 then  begin
              Defect_Start := GetSysdate-1 ;
              sDefect_Start :=  FormatDateTime('yyyy/mm/dd',GetSysdate-1)+' 08:00:00' ;
              Defect_End :=  GetSysdate ;
              sDefect_End :=  FormatDateTime('yyyy/mm/dd',GetSysdate)+' 08:00:00' ;
         end else
         begin
              Defect_Start := GetSysdate ;
              sDefect_Start :=  FormatDateTime('yyyy/mm/dd',GetSysdate)+' 08:00:00' ;
              Defect_End :=  GetSysdate+1 ;
              sDefect_End := FormatDateTime('yyyy/mm/dd',GetSysdate+1)+' 08:00:00' ;
         end;

        //***************設置報表格式**********************************************************//
         mmo1.Lines.Add('start query process....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
         QueryProcessName(QryTemp2,sStartTime,sEndTime);
         sAllProcess :='( ';
         if QryTemp2.IsEmpty then exit;
         QryTemp2.First;
         for j:=0 to QryTemp2.RecordCount-1 do  begin
               strTitle := QryTemp2.FieldByName('PROCESS_NAME').AsString ;
               stage_name := QryTemp2.FieldByName('stage_name').AsString ;
               AllModelArray[i].ProcessList[j] :=strTitle  ;
               AllModelArray[i].stagelist[j] := stage_name ;
               mmo1.Lines.Add('start  model:'+smodelName+' process List:'+strTitle+'....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
               mmo1.Lines.Add('start  model:'+smodelName+' stage List:'+stage_name+'....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
               sAllProcess :=   sAllProcess+'''' + strTitle +''',' ;
               QryTemp2.Next;
         end;
         sAllProcess :=Copy(sAllProcess ,1,Length(sAllProcess)-1)+')';

         mmo1.Lines.Add('start query defect....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
         QueryTop3DefectCode(QryTemp4,sDefect_Start,sDefect_End);
         if not QryTemp4.IsEmpty then begin
               //設置X軸格式
             ExcelApp.ActiveSheet.Range['A38:P38'].Font.Bold :=true;
             ExcelApp.ActiveSheet.Range['A38:P38'].Font.Color :=clwhite;
             ExcelApp.ActiveSheet.Range['A38:P38'].Interior.Color :=rgb(155,187,90);

             ExcelApp.ActiveSheet.Range['Q38:AB38'].Font.Bold :=true;
             ExcelApp.ActiveSheet.Range['Q38:AB38'].Font.Color :=clwhite;
             ExcelApp.ActiveSheet.Range['Q38:AB38'].Interior.Color :=rgb(155,137,90);

             //設置Item 列
             ExcelApp.Cells[38,1].Value := 'Operation';
             ExcelApp.Range['A38:B38'].Merge;
             ExcelApp.Cells[38,3].Value := 'Item';
             ExcelApp.Cells[38,4].Value := 'Total';
             ExcelApp.Cells[38,29].Value :=StartHour+'時~'+ EndHour+'時Total';
             ChartObjects :=ExcelApp.ActiveSheet.ChartObjects.add(210,318,550, 195);
             ChartObjects.Chart.ChartType:=xlLineMarkers;
             chartObjects.chart.SetSourceData(ExcelApp.ActiveSheet.Range['D33:R36']);
             ChartObjects.Chart.PlotBy:=xlRows;

             QryTemp4.First;
             for j:=0  to QryTemp4.RecordCount-1 do begin
                  ExcelApp.Cells[34+j,4].Value :=  QryTemp4.FieldByName('Defect_CODE').AsString;
                  QryTemp4.Next;
             end;
             for j:=0  to 6 do begin
                  ExcelApp.Cells[33,5+2*j].Value := FormatDateTime( 'MM/DD' ,Defect_Start-6+j) ;
             end;

             for j:=0 to 3 do begin
                 ExcelApp.ActiveSheet.Range['E'+IntTOstr(33+j)+':F'+IntTOstr(33+j)].Merge;
                 ExcelApp.ActiveSheet.Range['G'+IntTOstr(33+j)+':H'+IntTOstr(33+j)].Merge;
                 ExcelApp.ActiveSheet.Range['I'+IntTOstr(33+j)+':J'+IntTOstr(33+j)].Merge;
                 ExcelApp.ActiveSheet.Range['K'+IntTOstr(33+j)+':L'+IntTOstr(33+j)].Merge;
                 ExcelApp.ActiveSheet.Range['M'+IntTOstr(33+j)+':N'+IntTOstr(33+j)].Merge;
                 ExcelApp.ActiveSheet.Range['O'+IntTOstr(33+j)+':P'+IntTOstr(33+j)].Merge;
                 ExcelApp.ActiveSheet.Range['Q'+IntTOstr(33+j)+':R'+IntTOstr(33+j)].Merge;
             end;


             ExcelApp.ActiveSheet.Range['D33:D36'].Interior.Color :=rgb(194,214,154);
             ExcelApp.ActiveSheet.Range['D33:D36'].Font.Bold :=True;
             ExcelApp.ActiveSheet.Range['D33:R33'].Interior.Color :=rgb(194,214,154);
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

         mmo1.Lines.Add('start query model rate....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
         //機種目標
        with QryTemp do
        begin
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
              end else
                  FPY_Target := fieldbyName('Upper_level').AsString;
              AllModelArray[i].SPYTarget := FPY_Target;
        end;

         QryTemp2.First;
         TotalRowList :=TStringList.create;
         OutPutRowList := TStringList.create;
         RepassRowList := TStringList.create;
         overallSPYROWList :=  TStringList.create;

         for  j:=0 to QryTemp2.RecordCount-1  do
         begin
             strTitle := QryTemp2.FieldByName('PROCESS_NAME').AsString ;
             Process_Fail := QryTemp2.FieldByName('PROCESS_FAIL').AsInteger ;
             ExcelApp.Cells[UsedRow+1,1].Value :=  strTitle;
             ExcelApp.Cells[UsedRow+1,3].Value :=  'Total Input';
             ExcelApp.Cells[UsedRow+2,3].Value :=  'First Output';
             ExcelApp.Cells[UsedRow+1,4].Value :=  '=SUM(E'+IntToStr(UsedRow+1)+':AB'+InttoStr(UsedRow+1)+')';
             ExcelApp.Cells[UsedRow+2,4].Value :=  '=SUM(E'+IntToStr(UsedRow+2)+':AB'+InttoStr(UsedRow+2)+')';
             ExcelApp.Cells[UsedRow+1,29].Value :=  '=SUM('+StartColName+IntToStr(UsedRow+1)+':'+EndColName+InttoStr(UsedRow+1)+')';
             ExcelApp.Cells[UsedRow+2,29].Value :=  '=SUM('+StartColName+IntToStr(UsedRow+2)+':'+EndColName+InttoStr(UsedRow+2)+')';
             TotalRowList.Add(IntToStr(UsedRow+1));
             OutPutRowList.Add(IntToStr(UsedRow+2));


             if  Process_Fail <> 0 then begin
                 ExcelApp.Cells[UsedRow+3,3].Value :=  'Total Defect';
                 ExcelApp.Cells[UsedRow+4,3].Value :=  'Retest Pass';
                 ExcelApp.Cells[UsedRow+5,3].Value :=  'Final NG';
                 ExcelApp.Cells[UsedRow+6,3].Value :=  'Repair Q''ty';
                 RepassRowList.Add(IntToStr(UsedRow+4));
                 ExcelApp.Cells[UsedRow+7,3].Value :=  'FPY(%)';
                 ExcelApp.Cells[UsedRow+8,3].Value :=  'Retest Yield(%)';
                 overallSPYROWList.Add(IntToStr(UsedRow+7));
                 ExcelApp.Cells[UsedRow+9,3].Value :=  'SPY(%)';
                 ExcelApp.Cells[UsedRow+10,3].Value := 'Final(%)';
                 ExcelApp.Cells[UsedRow+3,29].Value  :=  '=SUM('+StartColName+IntToStr(UsedRow+3)+':'+EndColName+InttoStr(UsedRow+3)+')';
                 ExcelApp.Cells[UsedRow+4,29].Value  :=  '=SUM('+StartColName+IntToStr(UsedRow+4)+':'+EndColName+InttoStr(UsedRow+4)+')';
                 ExcelApp.Cells[UsedRow+5,29].Value  :=  '=SUM('+StartColName+IntToStr(UsedRow+5)+':'+EndColName+InttoStr(UsedRow+5)+')';
                 ExcelApp.Cells[UsedRow+6,29].Value  :=  '=SUM('+StartColName+IntToStr(UsedRow+6)+':'+EndColName+InttoStr(UsedRow+6)+')';
                 ExcelApp.Cells[UsedRow+7,29].Value  :=  '= IF(AC'+IntToStr(UsedRow+1)+'=0,100,AC'+IntToStr(UsedRow+2)+'/AC'+InttoStr(UsedRow+1)+'*100)';
                 ExcelApp.Cells[UsedRow+8,29].Value  :=  '= IF(AC'+InttoStr(UsedRow+3)+'=0,0,AC'+IntToStr(UsedRow+4)+'/AC'+InttoStr(UsedRow+3)+'*100)';
                 ExcelApp.Cells[UsedRow+9,29].Value  :=  '= IF(AC'+IntToStr(UsedRow+1)+'=0,100,(AC'+IntToStr(UsedRow+4)+'+AC'+IntToStr(UsedRow+2)+')/AC'+InttoStr(UsedRow+1)+'*100)';
                 ExcelApp.Cells[UsedRow+10,29].Value := '=IF(AC'+IntToStr(UsedRow+1)+'=0,100,(AC'+IntToStr(UsedRow+4)+'+AC'+IntToStr(UsedRow+2)+'+AC'+IntToStr(UsedRow+6)+')/AC'+InttoStr(UsedRow+1)+'*100)';

                 ExcelApp.Cells[UsedRow+3,4].Value  :=  '=SUM(E'+IntToStr(UsedRow+3)+':AB'+InttoStr(UsedRow+3)+')';
                 ExcelApp.Cells[UsedRow+4,4].Value  :=  '=SUM(E'+IntToStr(UsedRow+4)+':AB'+InttoStr(UsedRow+4)+')';
                 ExcelApp.Cells[UsedRow+5,4].Value  :=  '=SUM(E'+IntToStr(UsedRow+5)+':AB'+InttoStr(UsedRow+5)+')';
                 ExcelApp.Cells[UsedRow+6,4].Value  :=  '=SUM(E'+IntToStr(UsedRow+6)+':AB'+InttoStr(UsedRow+6)+')';
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
                 ExcelApp.ActiveSheet.Range['Q'+IntToStr(UsedRow+1)+':AB'+IntToStr(UsedRow+10)].Interior.Color :=rgb(185,245,205);
                 AllRow_list.Add(IntToStr(UsedRow+7));
                 UsedRow :=  UsedRow+11;
                 QueryDefectCode(QryTemp3,sDStartTime,sDEndTime,strTitle);
                 if not QryTemp3.IsEmpty then begin
                    Qrytemp3.First;
                    FirstCount :=  UsedRow;
                    for k:=0 to  QryTemp3.RecordCount-1  do  begin
                       ExcelApp.Cells[UsedRow,2].Value := Qrytemp3.FieldByName('Defect_Code').AsString;
                       ExcelApp.Cells[UsedRow,3].Value := Qrytemp3.FieldByName('Defect_Desc').AsString;
                       ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow)+':AB'+IntToStr(UsedRow)].Interior.Color :=rgb(235,185,185);
                       ExcelApp.Cells[UsedRow,4].Value :=  '=SUM(E'+IntToStr(UsedRow)+':AB'+InttoStr(UsedRow)+')';
                       UsedRow :=UsedRow+1;
                       Qrytemp3.Next;
                    end;
                    ExcelApp.Cells[FirstCount,1].Value := 'Defect Detail';
                    ExcelApp.ActiveSheet.Range['A'+IntToStr(FirstCount)+':A'+IntToStr(UsedRow-1)].Merge;

                 end;
               end else begin
                 RepassRowList.Add('0');
                 overallSPYROWList.Add('1');
                 ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow+1)+':B'+IntToStr(UsedRow+2)].Merge;
                 ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow+1)+':P'+IntToStr(UsedRow+2)].Interior.Color :=rgb(185,245,245);
                 ExcelApp.ActiveSheet.Range['Q'+IntToStr(UsedRow+1)+':AB'+IntToStr(UsedRow+2)].Interior.Color :=rgb(185,245,205);
                 UsedRow :=  UsedRow+3;
             end;
             ExcelApp.rows[UsedRow].Rowheight :=3;
             ExcelApp.ActiveSheet.Range['A'+IntToStr(UsedRow)+':N'+IntToStr(UsedRow)].Merge;
             QryTemp2.Next;
          end;
          
          if QryTemp4.IsEmpty then begin
              ExcelApp.ActiveSheet.Range['A21:AB'+IntToStr(UsedRow-1)].Borders[1].Weight := 2;
              ExcelApp.ActiveSheet.Range['A21:AB'+IntToStr(UsedRow-1)].Borders[2].Weight := 2;
              ExcelApp.ActiveSheet.Range['A21:AB'+IntToStr(UsedRow-1)].Borders[3].Weight := 2;
              ExcelApp.ActiveSheet.Range['A21:AB'+IntToStr(UsedRow-1)].Borders[4].Weight := 2;
          end else begin
              ExcelApp.ActiveSheet.Range['A38:AB'+IntToStr(UsedRow-1)].Borders[1].Weight := 2;
              ExcelApp.ActiveSheet.Range['A38:AB'+IntToStr(UsedRow-1)].Borders[2].Weight := 2;
              ExcelApp.ActiveSheet.Range['A38:AB'+IntToStr(UsedRow-1)].Borders[3].Weight := 2;
              ExcelApp.ActiveSheet.Range['A38:AB'+IntToStr(UsedRow-1)].Borders[4].Weight := 2;
          end;
          ExcelApp.ActiveSheet.Range['A1:AC'+IntToStr(UsedRow-1)].HorizontalAlignment :=3;
          ExcelApp.ActiveSheet.Range['A1:AC'+IntToStr(UsedRow-1)].VerticalAlignment :=2;
          ExcelApp.ActiveSheet.Columns[3]. HorizontalAlignment :=2;
          ExcelApp.ActiveSheet.Range['A14:AC'+IntToStr(UsedRow-1)].Font.Size :=8;
          ExcelApp.ActiveSheet.Range['A14:AC'+IntToStr(UsedRow-1)].Font.Name :='tahoma';
          ExcelApp.ActiveSheet.Rows[16].NumberFormat  := '0.00';
          ExcelApp.ActiveSheet.Rows[17].NumberFormat  := '0.00';
          ExcelApp.ActiveSheet.Rows[18].NumberFormat  := '0.00';
          ExcelApp.ActiveSheet.Rows[19].NumberFormat  := '0.00';
          ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[1].Weight := 2;
          ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[2].Weight := 2;
          ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[3].Weight := 2;
          ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[4].Weight := 2;
          ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[7].Weight := xlThick;
          ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[8].Weight := xlThick;
          ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[9].Weight := xlThick;
          ExcelApp.ActiveSheet.Range['D15:AC19'].Borders[10].Weight := xlThick;

          AllRows := UsedRow;
           mmo1.Lines.Add('start add time axis value....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
          for j:=0 to Week_list.Count-1 do begin
               sXValue:= Week_list.Strings[j]  ;
               ExcelApp.Cells[15,5+j].value := sXValue;
               if QryTemp4.IsEmpty then
                  ExcelApp.Cells[21,5+j].value := sXValue
               else
                  ExcelApp.Cells[38,5+j].value := sXValue
          end;

        //************************************************************************************//

          //填入TOP3
            mmo1.Lines.Add('start TOP3 display....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
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
                              ExcelApp.Cells[34+k,5+2*j].Value  :=   QryTemp4.FieldByName('Yield').AsString
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
                if QryData1.IsEmpty then continue;
                QryData1.First;
                for M:=0 to   QryData1.RecordCount-1 do begin
                    strTitle := QryData1.FieldByName('PROCESS_NAME').AsString ;
                    Repair_Qty:= QryData1.FieldByName('REPAIR_QTY').AsInteger ;
                    FAIL_Qty:= QryData1.FieldByName('FAIL_QTY').AsInteger ;
                    for k:=3 to AllRows-1 do begin
                       if  strTitle = ExcelApp.Cells[k,1].Value  then
                           UsedRow :=k;
                    end;
                    if UsedRow<=2 then exit;
                    strFPY :=  QryData1.FieldByName('FPY_QTY').AsString;
                    strTotal :=  QryData1.FieldByName('Total_QTY').AsString;
                    strRepass :=  QryData1.FieldByName('NTF_QTY').AsString;

                    if FAIL_Qty>0  then begin
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

                        if   StrToInt(strTotal)<> 0 then
                        begin
                           ExcelApp.Cells[UsedRow+6,5+j].Value := StrToInt(strFPY)/StrToInt(strTotal)*100;
                           ExcelApp.Cells[UsedRow+8,5+j].Value := (StrToInt(strFPY)+StrToInt(strRepass))/StrToInt(strTotal)*100 ;
                           ExcelApp.Cells[UsedRow+9,5+j].Value := FinalYield* (StrToInt(strFPY)+StrToInt(strRepass)+Repair_Qty) /StrToInt(strTotal);
                        end
                        else
                        begin
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
                              defect_count :=10;

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

                if RowList.Count<> 0 then begin
                   for M:=0 to  RowList.Count-1 do begin
                       FPY :=  FPY * ExcelApp.Cells[strtoint(RowList.Strings[M]),5+j].Value/100 ;
                       SPY :=  SPY* ExcelApp.Cells[strtoint(SPYRowList.Strings[M]),5+j].Value/100 ;
                       FinalYield :=  FinalYield* ExcelApp.Cells[strtoint(FinalRowList.Strings[M]),5+j].Value/100 ;
                   end ;
                end;

                ExcelApp.Cells[16,5+j].Value :=  FPY_Target ;
                ExcelApp.Cells[17,5+j].Value := FormatFloat('0.00',FPY);
                ExcelApp.Cells[18,5+j].Value := FormatFloat('0.00',SPY);
                ExcelApp.Cells[19,5+j].Value :=  FinalYield ;

                RowList.Free;
                SPYRowList.Free;
                FinalRowList.Free;
                UsedRow := UsedRow+8;
          end;

         Total_FPY :=100;
         Total_SPY :=100;
         Total_FinalYield:=100;
         if AllRow_list.Count <>0 then
         begin
             for M:=0 to  AllRow_list.Count-1 do begin
               Total_FPY := Total_FPY * ExcelApp.Cells[strtoInt(AllRow_list.strings[M]),4].Value /100;
               Total_SPY := Total_SPY * ExcelApp.Cells[strtoint(AllRow_list.strings[M])+2,4].Value /100;
               Total_FinalYield := Total_FinalYield * ExcelApp.Cells[strtoint(AllRow_list.strings[M])+3,4].Value /100;
             end;
         end;

         //---------------------------------------------------------------------
          for j:=0 to overallSPYROWList.Count-1 do begin
             AllModelArray[i].Input[j] := ExcelApp.Cells[strtoInt(TotalRowList.strings[j]),29].Value;
             if RepassRowList.strings[j]='0' then
                    AllModelArray[i].OutPut[j] :=  ExcelApp.Cells[strtoInt(OutPutRowList.strings[j]),29].Value
             else
             AllModelArray[i].OutPut[j] := ExcelApp.Cells[strtoInt(OutPutRowList.strings[j]),29].Value+
                                    ExcelApp.Cells[strtoInt(RepassRowList.strings[j]),29].Value ;
             if  overallSPYROWList.Strings[j] ='1'  then
                  AllModelArray[i].SPYList[j] := '1'
             else
                  AllModelArray[i].SPYList[j] :=  ExcelApp.Cells[strtoInt(overallSPYROWList.strings[j]),29].Value /100;
         end;

         {
         AllModelArray[i].ProcessList.Free;
         AllModelArray[i].StageList.Free;
         AllModelArray[i].Input.Free;
         AllModelArray[i].Output.Free;
         AllModelArray[i].SPYList.Free;
         }
         //---------------------------------------------------------------------
         ExcelApp.Cells[16,29].Value :=  FPY_Target ;
         ExcelApp.Cells[17,29].Value := FormatFloat('0.00',Total_FPY);
         ExcelApp.Cells[18,29].Value := FormatFloat('0.00',Total_SPY);
         ExcelApp.Cells[19,29].Value :=  Total_FinalYield ;

          AllRow_list.Free;
          if   IntToStr(ExcelApp.Cells[16,4+j].Value)  <> '' then begin
            TotalTarget_list.Add(FormatFloat('0.00',ExcelApp.Cells[16,29]));
            TotalSPY_list.Add(FormatFloat('0.00',ExcelApp.Cells[18,29]));
            TotalModel_List.add(sModelName);
          end;
          QryModel.Next;
    end;

    if FormatDateTime('HH',GetSysDate) <= '08' then
       sFileName := ExtractFilePath(Paramstr(0))+'Report\'+FormatDateTime('YYYY年M月D日 HH時',GetSysDate-1)+' 各機種時段生產報表.xlsx'
    else
       sFileName := ExtractFilePath(Paramstr(0))+'Report\'+FormatDateTime('YYYY年M月D日 HH時',GetSysDate)+' 各機種時段生產報表.xlsx';

    ExcelApp.WorkSheets[QryModel.RecordCount+1].Delete;
    ExcelApp.WorkSheets[QryModel.RecordCount+1].Delete;
    ExcelApp.WorkSheets[QryModel.RecordCount+1].Delete;
    ExcelApp.WorkSheets[1].Activate;
    mmo1.Lines.Add('save excel ('+sFileName+')...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
    ExcelApp.ActiveWorkbook.SaveAs(sFileName);
    ExcelApp.Quit;
    mmo1.Lines.Add('close excel ...'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
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
                           '  SELECT C2.MODEL_NAME,D2. DEFECT_CODE,COUNT(*) DEFECT_COUNT  '+
                           '  FROM SAJET.G_SN_DEFECT_FIRST A2,SAJET.SYS_PART B2,SAJET.SYS_MODEL C2,SAJET.SYS_DEFECT D2,SAJET.SYS_PROCESS E2 '+
                           '  WHERE A2.REC_TIME >= TO_DATE(:STARTTIME,''YYYY/MM/DD HH24:MI:SS'') AND '+
                           '  A2.REC_TIME < TO_DATE(:ENDTIME,''YYYY/MM/DD HH24:MI:SS'') AND A2.WORK_ORDER '+
                           '   NOT LIKE ''RM%''AND  C2.MODEL_NAME =:MODEL_NAME AND A2.PROCESS_ID = E2.PROCESS_ID '+
                           '   AND E2.PROCESS_CODE IS NOT NULL AND E2.Process_NAME IN '+sAllProcess+' AND A2.MODEL_ID =B2.PART_ID AND B2.MODEL_ID=C2.MODEL_ID AND A2.DEFECT_ID =D2.DEFECT_ID '+
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
    QryTemp4.CommandText := ' SELECT BB.DEFECT_CODE,ROUND(SUM(BB.DEFECT_COUNT/AA.TOTAL_INPUT)*100,2) AS "YIELD"  FROM  '+
                           ' ( '+
                           '  SELECT PROCESS_ID ,SUM(PASS_QTY+FAIL_QTY) TOTAL_INPUT FROM( SELECT C.MODEL_NAME,A.PROCESS_ID, '+
                           '  A.PASS_QTY,A.FAIL_QTY,TO_NUMBER(TO_CHAR(A.WORK_DATE)||TRIM(TO_CHAR(A.WORK_TIME,''00''))) DATETIME '+
                           '  FROM SAJET.G_SN_COUNT A,SAJET.SYS_PART B, SAJET.SYS_MODEL C WHERE A.WORK_ORDER NOT LIKE ''RM%'' and '+
                           '  A.PASS_QTY +A.FAIL_QTY <>0 AND A.MODEL_ID=B.PART_ID AND B.MODEL_ID =C.MODEL_ID AND C.MODEL_NAME =:MODEL_NAME  ) '+
                           '  WHERE  DATETIME >= :STARTDATE AND DATETIME < :ENDDATE  GROUP BY PROCESS_ID ) AA,'+
                           '  ( '+
                           '   SELECT PROCESS_ID,DEFECT_CODE ,SUM(C_COUNT) DEFECT_COUNT FROM ( '+
                           '   SELECT C1.MODEL_NAME,D1.DEFECT_CODE, '+
                           '   A1.PROCESS_ID ,1 C_COUNT FROM '+
                           '  SAJET.G_SN_DEFECT_FIRST A1,SAJET.SYS_PART B1,SAJET.SYS_MODEL C1,SAJET.SYS_DEFECT D1 ,SAJET.SYS_PROCESS E1 '+
                           '  WHERE A1.REC_TIME >= TO_DATE(:STARTTIME,''YYYY/MM/DD HH24:MI:SS'') AND E1.PROCESS_NAME IN '+sAllProcess +
                           '  AND A1.REC_TIME < TO_DATE(:ENDTIME,''YYYY/MM/DD HH24:MI:SS'') AND A1.WORK_ORDER '+
                           '  NOT LIKE ''RM%'' AND C1.MODEL_NAME =:MODEL_NAME '+
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
   Week_list.Free;
end;


end.
