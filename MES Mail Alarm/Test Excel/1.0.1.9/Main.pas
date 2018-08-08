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
            CMReordlist[ii].WIP :=  GetWIPQTY(CMReordlist[ii].ModelName  ,'AutoTest','3F_CLEAN01' );
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
    {try
       mmo1.Lines.Add('start get time....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
       GetDateTimeList();

       mmo1.Lines.Add('start export excel....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
       ExportReport;
       Addresslist := TStringList.Create;




       Addresslist.Add('Dennis_shuai@foxlink.com');
       if sFileName <>'' then  begin
           mmo1.Lines.Add('start send mail....'+FormatDateTime('yyyy/mm/dd hh:mm:ss',getsysdate));
           SendMail(sFileName,Addresslist);
       end;
       Addresslist.Free;
    finally
       mmo1.Lines.SaveToFile(sLogFileName);
       Close;
    end;
    }
    ExportReport;
end;

procedure TuMainForm.QueryModel(QryTemp1:TClientDataset;StartTime,EndTime:string);
begin

    QryTemp1.Close;
    QryTemp1.CommandText :=' select work_order,model_id,work_date,work_time,pass_qty,fail_qty '+
                           ' from sajet.g_sn_count where rownum <= 100 ';
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
                        stemp :=  '     '+format('%-20s',[COBReordlist[i].ModelName +'機種'])+
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
   ExcelApp,xRange: Variant;
   arr:  Variant;
   i,j:Integer;
   stemp:string;
begin

    QueryModel(QryModel, sStartTime ,sEndTime);
    if QryModel.IsEmpty then exit;

    iModelCount :=QryModel.RecordCount;
    Application.ProcessMessages();
    try
        ExcelApp :=CreateOleObject('Excel.Application');
    except
        Exit;
    end;
    ExcelApp.Visible := true;
    ExcelApp.displayAlerts:=false;
    try
        ExcelApp.WorkBooks.Add;
    except
        Exit;
    end;

    QryModel.First;
    //SetLength(arr,4, iModelCount);
    arr :=VarArrayCreate([1,100,1,6],varVariant);

    for j:=1 to  iModelCount do
    begin
        for i:=0 to 5 do
        begin
             stemp := QryModel.Fields[i].AsString;
             VarArrayPut(arr,stemp ,[j,i+1]);
        end;
        QryModel.Next;
    end;

    ExcelApp.WorkSheets[1].Activate;
    ExcelApp.ActiveSheet.Range['A1:F'+IntToStr(iModelCount)].Value :=arr ;
    sFileName := ExtractFilePath(ParamStr(0))+'Report\'+FormatDateTime('yyyymmddhhmmss',getsysdate)+'.xlsx';
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
