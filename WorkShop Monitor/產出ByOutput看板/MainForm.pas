unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, MConnect, ObjBrkr, DB, DBClient,
  SConnect,IniFiles,math,uMyClassHelpers;

type
  TuMainForm = class(TfmForm)
    lblTitle: TLabel;
    Panel3: TPanel;
    PanelSN: TPanel;
    PanelSN01: TPanel;
    PanelSN02: TPanel;
    PanelSN03: TPanel;
    PanelSN04: TPanel;
    PanelSN05: TPanel;
    PanelSN06: TPanel;
    PanelSN07: TPanel;
    PanelSN08: TPanel;
    PanelSN10: TPanel;
    PanelSN09: TPanel;
    PanelPDLine: TPanel;
    PanelPDLine02: TPanel;
    PanelPDLine03: TPanel;
    PanelPDLine04: TPanel;
    PanelPDLine05: TPanel;
    PanelPDLine06: TPanel;
    PanelPDLine07: TPanel;
    PanelPDLine08: TPanel;
    PanelPDLine10: TPanel;
    PanelPDLine09: TPanel;
    PanelPDLine01: TPanel;
    PanelTYield: TPanel;
    PanelCT01: TPanel;
    PanelCT02: TPanel;
    PanelCT03: TPanel;
    PanelCT04: TPanel;
    PanelCT05: TPanel;
    PanelCT06: TPanel;
    PanelCT07: TPanel;
    PanelCT08: TPanel;
    PanelCT10: TPanel;
    PanelCT09: TPanel;
    PanelT1: TPanel;
    PanelOutput101: TPanel;
    PanelOutput102: TPanel;
    PanelOutput103: TPanel;
    PanelOutput104: TPanel;
    PanelOutput105: TPanel;
    PanelOutput106: TPanel;
    PanelOutput107: TPanel;
    PanelOutput108: TPanel;
    PanelOutput110: TPanel;
    PanelOutput109: TPanel;
    PanelTitle: TPanel;
    Panel42: TPanel;
    PanelLine: TPanel;
    Panel40: TPanel;
    PanelTittleT11: TPanel;
    PanelTittleT4: TPanel;
    PanelTittleT1: TPanel;
    PanelTitleUPH: TPanel;
    PanelTittleT2: TPanel;
    PanelTittleT3: TPanel;
    PanelTittleT7: TPanel;
    PanelTittleT5: TPanel;
    PanelTittleT6: TPanel;
    PanelTittleT8: TPanel;
    PanelTittleT9: TPanel;
    PanelTittleT10: TPanel;
    PanelTittleT12: TPanel;
    Panel14: TPanel;
    Panel13: TPanel;
    PanelModel: TPanel;
    PanelModel02: TPanel;
    PanelModel03: TPanel;
    PanelModel04: TPanel;
    PanelModel05: TPanel;
    PanelModel06: TPanel;
    PanelModel07: TPanel;
    PanelModel08: TPanel;
    PanelModel10: TPanel;
    PanelModel09: TPanel;
    PanelModel01: TPanel;
    PanelYield101: TPanel;
    PanelYield102: TPanel;
    PanelYield103: TPanel;
    PanelYield104: TPanel;
    PanelYield105: TPanel;
    PanelYield106: TPanel;
    PanelYield107: TPanel;
    PanelYield108: TPanel;
    PanelYield109: TPanel;
    PanelYield110: TPanel;
    PanelT2: TPanel;
    PanelOutput201: TPanel;
    PanelOutput202: TPanel;
    PanelOutput203: TPanel;
    PanelOutput204: TPanel;
    PanelOutput205: TPanel;
    PanelOutput206: TPanel;
    PanelOutput207: TPanel;
    PanelOutput208: TPanel;
    PanelOutput210: TPanel;
    PanelOutput209: TPanel;
    PanelYield201: TPanel;
    PanelYield202: TPanel;
    PanelYield203: TPanel;
    PanelYield204: TPanel;
    PanelYield205: TPanel;
    PanelYield206: TPanel;
    PanelYield207: TPanel;
    PanelYield208: TPanel;
    PanelYield209: TPanel;
    PanelYield210: TPanel;
    PanelT3: TPanel;
    PanelOutput301: TPanel;
    PanelOutput302: TPanel;
    PanelOutput303: TPanel;
    PanelOutput304: TPanel;
    PanelOutput305: TPanel;
    PanelOutput306: TPanel;
    PanelOutput307: TPanel;
    PanelOutput308: TPanel;
    PanelOutput310: TPanel;
    PanelOutput309: TPanel;
    PanelYield301: TPanel;
    PanelYield302: TPanel;
    PanelYield303: TPanel;
    PanelYield304: TPanel;
    PanelYield305: TPanel;
    PanelYield306: TPanel;
    PanelYield307: TPanel;
    PanelYield308: TPanel;
    PanelYield309: TPanel;
    PanelYield310: TPanel;
    PanelT4: TPanel;
    PanelOutput401: TPanel;
    PanelOutput402: TPanel;
    PanelOutput403: TPanel;
    PanelOutput404: TPanel;
    PanelOutput405: TPanel;
    PanelOutput406: TPanel;
    PanelOutput407: TPanel;
    PanelOutput408: TPanel;
    PanelOutput410: TPanel;
    PanelOutput409: TPanel;
    PanelYield401: TPanel;
    PanelYield402: TPanel;
    PanelYield403: TPanel;
    PanelYield404: TPanel;
    PanelYield405: TPanel;
    PanelYield406: TPanel;
    PanelYield407: TPanel;
    PanelYield408: TPanel;
    PanelYield409: TPanel;
    PanelYield410: TPanel;
    PanelT5: TPanel;
    PanelOutput501: TPanel;
    PanelOutput502: TPanel;
    PanelOutput503: TPanel;
    PanelOutput504: TPanel;
    PanelOutput505: TPanel;
    PanelOutput506: TPanel;
    PanelOutput507: TPanel;
    PanelOutput508: TPanel;
    PanelOutput510: TPanel;
    PanelOutput509: TPanel;
    PanelYield501: TPanel;
    PanelYield502: TPanel;
    PanelYield503: TPanel;
    PanelYield504: TPanel;
    PanelYield505: TPanel;
    PanelYield506: TPanel;
    PanelYield507: TPanel;
    PanelYield508: TPanel;
    PanelYield509: TPanel;
    PanelYield510: TPanel;
    PanelT6: TPanel;
    PanelOutput601: TPanel;
    PanelOutput602: TPanel;
    PanelOutput603: TPanel;
    PanelOutput604: TPanel;
    PanelOutput605: TPanel;
    PanelOutput606: TPanel;
    PanelOutput607: TPanel;
    PanelOutput608: TPanel;
    PanelOutput610: TPanel;
    PanelOutput609: TPanel;
    PanelYield601: TPanel;
    PanelYield602: TPanel;
    PanelYield603: TPanel;
    PanelYield604: TPanel;
    PanelYield605: TPanel;
    PanelYield606: TPanel;
    PanelYield607: TPanel;
    PanelYield608: TPanel;
    PanelYield609: TPanel;
    PanelYield610: TPanel;
    PanelT7: TPanel;
    PanelOutput701: TPanel;
    PanelOutput702: TPanel;
    PanelOutput703: TPanel;
    PanelOutput704: TPanel;
    PanelOutput705: TPanel;
    PanelOutput706: TPanel;
    PanelOutput707: TPanel;
    PanelOutput708: TPanel;
    PanelOutput710: TPanel;
    PanelOutput709: TPanel;
    PanelYield701: TPanel;
    PanelYield702: TPanel;
    PanelYield703: TPanel;
    PanelYield704: TPanel;
    PanelYield705: TPanel;
    PanelYield706: TPanel;
    PanelYield707: TPanel;
    PanelYield708: TPanel;
    PanelYield709: TPanel;
    PanelYield710: TPanel;
    PanelT8: TPanel;
    PanelOutput801: TPanel;
    PanelOutput802: TPanel;
    PanelOutput803: TPanel;
    PanelOutput804: TPanel;
    PanelOutput805: TPanel;
    PanelOutput806: TPanel;
    PanelOutput807: TPanel;
    PanelOutput808: TPanel;
    PanelOutput810: TPanel;
    PanelOutput809: TPanel;
    PanelYield801: TPanel;
    PanelYield802: TPanel;
    PanelYield803: TPanel;
    PanelYield804: TPanel;
    PanelYield805: TPanel;
    PanelYield806: TPanel;
    PanelYield807: TPanel;
    PanelYield808: TPanel;
    PanelYield809: TPanel;
    PanelYield810: TPanel;
    PanelT9: TPanel;
    PanelOutput901: TPanel;
    PanelOutput902: TPanel;
    PanelOutput903: TPanel;
    PanelOutput904: TPanel;
    PanelOutput905: TPanel;
    PanelOutput906: TPanel;
    PanelOutput907: TPanel;
    PanelOutput908: TPanel;
    PanelOutput910: TPanel;
    PanelOutput909: TPanel;
    PanelYield901: TPanel;
    PanelYield902: TPanel;
    PanelYield903: TPanel;
    PanelYield904: TPanel;
    PanelYield905: TPanel;
    PanelYield906: TPanel;
    PanelYield907: TPanel;
    PanelYield908: TPanel;
    PanelYield909: TPanel;
    PanelYield910: TPanel;
    PanelT10: TPanel;
    PanelOutputA01: TPanel;
    PanelOutputA02: TPanel;
    PanelOutputA03: TPanel;
    PanelOutputA04: TPanel;
    PanelOutputA05: TPanel;
    PanelOutputA06: TPanel;
    PanelOutputA07: TPanel;
    PanelOutputA08: TPanel;
    PanelOutputA10: TPanel;
    PanelOutputA09: TPanel;
    PanelYieldA01: TPanel;
    PanelYieldA02: TPanel;
    PanelYieldA03: TPanel;
    PanelYieldA04: TPanel;
    PanelYieldA05: TPanel;
    PanelYieldA06: TPanel;
    PanelYieldA07: TPanel;
    PanelYieldA08: TPanel;
    PanelYieldA09: TPanel;
    PanelYieldA10: TPanel;
    PanelT11: TPanel;
    PanelOutputB01: TPanel;
    PanelOutputB02: TPanel;
    PanelOutputB03: TPanel;
    PanelOutputB04: TPanel;
    PanelOutputB05: TPanel;
    PanelOutputB06: TPanel;
    PanelOutputB07: TPanel;
    PanelOutputB08: TPanel;
    PanelOutputB10: TPanel;
    PanelOutputB09: TPanel;
    PanelYieldB01: TPanel;
    PanelYieldB02: TPanel;
    PanelYieldB03: TPanel;
    PanelYieldB04: TPanel;
    PanelYieldB05: TPanel;
    PanelYieldB06: TPanel;
    PanelYieldB07: TPanel;
    PanelYieldB08: TPanel;
    PanelYieldB09: TPanel;
    PanelYieldB10: TPanel;
    PanelT12: TPanel;
    PanelOutputC01: TPanel;
    PanelOutputC02: TPanel;
    PanelOutputC03: TPanel;
    PanelOutputC04: TPanel;
    PanelOutputC05: TPanel;
    PanelOutputC06: TPanel;
    PanelOutputC07: TPanel;
    PanelOutputC08: TPanel;
    PanelOutputC10: TPanel;
    PanelOutputC09: TPanel;
    PanelYieldC01: TPanel;
    PanelYieldC02: TPanel;
    PanelYieldC03: TPanel;
    PanelYieldC04: TPanel;
    PanelYieldC05: TPanel;
    PanelYieldC06: TPanel;
    PanelYieldC07: TPanel;
    PanelYieldC08: TPanel;
    PanelYieldC09: TPanel;
    PanelYieldC10: TPanel;
    PanelCQ: TPanel;
    PanelTargetOP01: TPanel;
    PanelTargetOP02: TPanel;
    PanelTargetOP03: TPanel;
    PanelTargetOP04: TPanel;
    PanelTargetOP05: TPanel;
    PanelTargetOP06: TPanel;
    PanelTargetOP07: TPanel;
    PanelTargetOP08: TPanel;
    PanelTargetOP10: TPanel;
    PanelTargetOP09: TPanel;
    PanelTargetYieldT01: TPanel;
    PanelTargetYieldT02: TPanel;
    PanelTargetYieldT03: TPanel;
    PanelTargetYieldT04: TPanel;
    PanelTargetYieldT05: TPanel;
    PanelTargetYieldT06: TPanel;
    PanelTargetYieldT07: TPanel;
    PanelTargetYieldT08: TPanel;
    PanelTargetYieldT09: TPanel;
    PanelTargetYieldT10: TPanel;
    PanelCY: TPanel;
    PanelActualOP01: TPanel;
    PanelActualOP02: TPanel;
    PanelActualOP03: TPanel;
    PanelActualOP04: TPanel;
    PanelActualOP05: TPanel;
    PanelActualOP06: TPanel;
    PanelActualOP07: TPanel;
    PanelActualOP08: TPanel;
    PanelActualOP10: TPanel;
    PanelActualOP09: TPanel;
    PanelActualYieldT01: TPanel;
    PanelActualYieldT02: TPanel;
    PanelActualYieldT03: TPanel;
    PanelActualYieldT04: TPanel;
    PanelActualYieldT05: TPanel;
    PanelActualYieldT06: TPanel;
    PanelActualYieldT07: TPanel;
    PanelActualYieldT08: TPanel;
    PanelActualYieldT09: TPanel;
    PanelActualYieldT10: TPanel;
    PanelTUPH: TPanel;
    PanelUPH02: TPanel;
    PanelUPH03: TPanel;
    PanelUPH04: TPanel;
    PanelUPH05: TPanel;
    PanelUPH06: TPanel;
    PanelUPH07: TPanel;
    PanelUPH08: TPanel;
    PanelUPH10: TPanel;
    PanelUPH09: TPanel;
    PanelUPH01: TPanel;
    SpeedButton1: TSpeedButton;
    BtNext: TSpeedButton;
    BtSetup: TSpeedButton;
    lblTime: TLabel;
    SimpleObjectBroker1: TSimpleObjectBroker;
    Timer1: TTimer;
    Timer2: TTimer;
    QryData: TClientDataSet;
    csFTemp: TClientDataSet;
    SocketConnection1: TSocketConnection;
    Panel1: TPanel;
    PanelYN01: TPanel;
    PanelYN02: TPanel;
    PanelYN03: TPanel;
    PanelYN04: TPanel;
    PanelYN05: TPanel;
    PanelYN06: TPanel;
    PanelYN07: TPanel;
    PanelYN08: TPanel;
    PanelYN09: TPanel;
    PanelYN10: TPanel;
    btnCum: TSpeedButton;
    QryOutput: TClientDataSet;
    QryTotal: TClientDataSet;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure BtSetupClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BtNextClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PanelPDLine01DblClick(Sender: TObject);
    procedure btnCumClick(Sender: TObject);
    procedure PanelModel01DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    StrLst,StrLst1,StrLstPdLineID,StrLstPdLineName,StrLstProcess,sStr,StrLstProcessName,StrLstDate,StrLstHour,sShiftID,sStrTmp: TStringList;
    sDayShiftID,sNightShiftID,sDayShiftTime,sNightShiftTime : TStringList;
    ALL_Pages,G_Page,ALL_PDLINE ,TimeSeq,PDLINECount: Integer;
    G_Repeat,G_status,G_UpdateStatus,sStartTime,sEndTime,sShift: String;
    G_FIRST  : Boolean;
    sShiftHour: array[0..11] of integer;
    sDayShiftDay,sNightShiftDay,sCurrentHour,sPDLine,sCurrentPDLine,sCurrentModel,sStartDateTime,sEndDateTime : String;
    function LoadApServer: Boolean;
    Procedure QueryTotalYield(DataTemp:TClientDataSet);
    Procedure QueryYieldPH(DataTemp:TClientDataSet);
    Procedure QueryOutput(DataTemp:TClientDataSet);
    Procedure QueryCurrentDate(DataTemp:TClientDataSet);
    Procedure QueryTotal(DataTemp:TClientDataSet);
    Procedure DisplayOutput;
    Procedure DisplayYieldPH;
    Procedure DisplayTotalYield;
    function  AddZero(s:string;HopeLength:Integer):String;
    procedure ClearAllPanel;
    function  GetSysDate:TDateTime;
  end;

var
  uMainForm: TuMainForm;

implementation

{$R *.dfm}

uses uLine,uLineDetail,uCumDetail, uModelDetail;


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
begin
   uMainForm.Left :=0;
   uMainFOrm.Top :=0;
   lblTitle.Left := round((uMainForm.Width -lblTitle.Width)/2);

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
    lblTitle.Caption:=fInI.ReadString('Monitor Factory Name', 'Name', 'Workshop Produce Status Monitor');
    Timer1.Interval :=StrToInt(fInI.ReadString('Interval', 'Data', '1'))*1000*60;
    Timer2.Interval :=StrToInt(fInI.ReadString('Interval', 'Page', '10'))*1000;
   end;

   sPDline := ''''+StrLstPDLineID.Strings[0]+ '''';
   for i:=1 to j-1 do  begin
        sPDline := sPDline+  ','''+StrLstPDLineID.Strings[i] +'''';
   end;


   if StrLstPDLineID.Count<=0 then
    MessageDlg('Please Choose PDLine ',mtInformation, [mbOK],0)
   else
    Timer1Timer(Self);

end;

procedure TuMainForm.BtSetupClick(Sender: TObject);
var fIni:TIniFile;
begin
   uMainForm.Timer1.Enabled := False;
   uMainForm.Timer2.Enabled := False;
   SpeedButton1.Caption:='Start';
   SpeedButton1.Font.Color:=clRed;
   with TformLine.Create(Self) do
   begin
     seditRefresh.Value:=Round(uMainForm.Timer1.Interval/60000);
     seditChange.Value :=Round(uMainForm.Timer2.Interval/1000);
     if Showmodal = mrOK then
     begin
        uMainForm.Timer1.Interval :=  seditRefresh.Value*60000;
        uMainForm.Timer2.Interval :=  seditChange.Value*1000;
     
       Timer1Timer(Self);
       Timer2.Enabled:=true;
       G_UpdateStatus:='Y';
     end else
       G_UpdateStatus:='N';
    end;
    if  G_UpdateStatus='N' then
    begin
       uMainForm.Timer1.Enabled := True;
       uMainForm.Timer2.Enabled := True;
    end;
    SpeedButton1.Caption:='Pause';
    SpeedButton1.Font.Color:=clBlack;
end;

procedure TuMainForm.Timer1Timer(Sender: TObject);
begin
     Timer1.Enabled :=false;
     lblTime.Caption := 'UpdateTime:  '+FormatDateTime('yyyy/mm/dd hh:mm:ss',now);
     ClearAllPanel;
     QueryCurrentDate( QryData);

     QueryYieldPH(QryData);
     DisplayYieldPH ;

     QueryOutput(QryOutput);
     DisplayOutput;

     QueryTotalYield(QryTotal);
     DisplayTotalYield;

     Timer1.Enabled :=true;
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
                               '                          and (A.Pass_Qty+A.NTF_Qty) <> 0  AND (A.WORK_DATE =H.WORK_DATE OR ((A.WORK_DATE =H.WORK_DATE+1)  AND H.SHIFT_ID =1000002)) '+
                               '                          and A.PDLINE_ID =H.PDLINE_ID AND A.SHIFT_ID=H.SHIFT_ID AND H.REPAIR_LINE =''N'' and H.PD_STATUS =1'+
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

     if sShift ='D' then begin
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
     DataTemp.CommandText :=   ' select  PDLINE_NAME,ROUND(exp(sum(ln(decode(SPY_YIELD,0,0.000001,SPY_YIELD))))*1000,2) as SPY_YIELD, '+
                               '         ROUND(exp(sum(ln(decode(FPY_YIELD,0,0.000001,FPY_YIELD))))*100,2) as FPY_YIELD      '   +
                               '  from (                                                            '  +
                               '      SELECT  PDLINE_NAME,PROCESS_NAME,PROCESS_CODE,NVL(SUM(PASS_QTY),0) as FPY_QTY ,                                         '+
                               '                 NVL(SUM(FAIL_QTY),0) AS FAIL_QTY ,NVL(SUM(NTF_QTY),0) AS NTF_QTY,                                                                      '+
                               '                 NVL(SUM(PASS_QTY)+SUM(FAIL_QTY),0) as TOTAL_QTY, NVL(SUM(PASS_QTY)+SUM(NTF_QTY),0) as OUTPUT_QTY,                                      '+
                               '                 DECODE (SUM(PASS_QTY)+SUM(FAIL_QTY),0,0,SUBSTR(TO_CHAR(SUM(PASS_QTY)/(SUM(PASS_QTY)+SUM(FAIL_QTY))),1,4)) as FPY_YIELD,                '+
                               '                 DECODE (SUM(PASS_QTY)+SUM(FAIL_QTY),0,0,SUBSTR(TO_CHAR((SUM(PASS_QTY)+SUM(NTF_QTY))/(SUM(PASS_QTY)+SUM(FAIL_QTY))),1,4)) as SPY_YIELD  '+
                               '       from (                                                                                                                                            '+
                               '                  select  C.PDLINE_NAME ,b.PROCESS_NAME,b.PROCESS_CODE,to_char(WORK_DATE)||TRIM(to_CHAR(WORK_TIME,''00'')) as "DATETIME",  '+
                               '                         A.PASS_QTY,A.FAIL_QTY,A.NTF_QTY                                                                                                '+
                               '                  from  SAJET.G_SN_COUNT a,SAJET.SYS_PROCESS b,SAJET.SYS_PDLINE c,SAJET.SYS_PDLINE_MONITOR_BASE d ,                                     '+
                               '                        SAJET.sys_process e      '+
                               '                  where A.PDLINE_ID =C.PDLINE_ID and A.PROCESS_ID =b.PROCESS_ID  and d.PDline_ID=a.PDLINE_ID  and d.PROCESS_ID =E.PROCESS_ID            '+
                               '                          and B.PROCESS_CODE <=e.process_Code and b.Process_code is not null AND (A.PASS_QTY+A.FAIL_QTY) <> 0 )                                     '+
                               '        where  DATETIME >= :StartTime  and DATETIME<:EndTime  AND PDLINE_NAME IN                                                                       '+
                               '        (                                                                                                                                               '+
                                         sPDline+
                               '        ) group by   PDLINE_NAME ,PROCESS_NAME,PROCESS_CODE  ORDER BY PDLINE_NAME,PROCESS_CODE          '+
                               '   )                                                                                                                                                    '+
                               '   group by PDLINE_NAME  ORDER BY PDLINE_NAME ';

   DataTemp.Params.ParamByName('StartTime').AsString :=sStartTime;
   DataTemp.Params.ParamByName('EndTime').AsString :=sEndDateTime;
   DataTemp.Open;

end;

Procedure TuMainForm.QueryOutput(DataTemp:TClientDataSet);
begin
     //sPDline :='CM_252';
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
                               '       and a.PROCESS_ID =d.PROCESS_ID  and a.PDLINE_ID =d.PDLINE_ID and (a.Pass_QTY+a.FAIL_QTY) <>0 ) '+
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


Procedure TuMainForm.DisplayTotalYield;
var i,j,tempRow,iPos:integer;
    sPDLineName,sSPY,sTargetYield,sRPDLINE :string;
begin
     tempRow:=0;
     if QryTotal.IsEmpty then exit;
     QryTotal.First;
     for  i:=0 to  QryTotal.RecordCount-1  do   begin
        Application.ProcessMessages;
        sPDLineName :=    QryTotal.FieldByName('PDLINE_NAME').AsString ;
        if    sPDLineName = '' then exit;

        sSPY :=    QryTotal.FieldByName('FPY_YIELD').AsString ;
        for j:=0 to 9  do   begin
            if TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j+1),2))).Caption <> '' then begin
              iPos :=Pos('自動',TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j+1),2))).Caption );
              if iPos >0 then
                   sRPDLINE := Copy(TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j+1),2))).Caption ,1,
                                      Length(TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j+1),2))).Caption)-6)
              else
                   sRPDLINE := TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j+1),2))).Caption;


            if sPDLineName  = sRPDLINE then begin
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

        QryTotal.Next;
     end;
end;

Procedure TuMainForm.DisplayYieldPH;
var i,j,CurrentTime ,UsedHour,iPos:Integer;
    sFristPDLIne ,sPDLineName,sModel,sUPH,sTargetYield,sWorkTime,sSPY,sRemark:string;
begin
     if QryData.IsEmpty  then  exit;

     All_PDLINE :=1 ;
     QryData.First;
     sFristPDLine :=  QryData.FieldByName('PDLINE_NAME').AsString ;

     for  i:=0 to  QryData.RecordCount-1  do
     begin
          sPDLineName :=    QryData.FieldByName('PDLINE_NAME').AsString ;
            if  sPDLineName <>  sFristPDLIne  then  begin
              sFristPDLIne :=  sPDLineName;
              All_PDLINE :=  All_PDLINE+1;
             end;
             QryData.Next;
     end;
     ALL_Pages  :=  ceil(All_PDLINE/10);

     QryData.First;
     j:=1;
     if (G_Page >1 ) and (G_Page <= ALL_Pages) then begin
         sFristPDLine :=  QryData.FieldByName('PDLINE_NAME').AsString ;

         for  i:=0 to  QryData.RecordCount-1  do
         begin
              sPDLineName := QryData.FieldByName('PDLINE_NAME').AsString ;
                if  sPDLineName <>  sFristPDLIne  then  begin
                    sFristPDLIne :=  sPDLineName;
                    j :=  j+1;
                 end;
                 if  j <= (G_Page-1) *10  then
                     QryData.Next;
         end;
     end;


     PDLINECount :=1;
     sFristPDLIne :=  QryData.FieldByName('PDLINE_NAME').AsString ;
     sSpy :=  QryData.FieldByName('SPY_YIELD').AsString ;
     sModel := QryData.FieldByName('Model_NAME').AsString ;
     sUPH :=   QryData.FieldByName('UPH').AsString ;
     sTargetYield :=   QryData.FieldByName('Cycle_Time').AsString ;
     sWorkTime :=  QryData.FieldByName('Work_TIME').AsString ;
     sRemark :=  QryData.FieldByName('Remark').AsString ;
     TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(PDLINECount),2))).Caption := sFristPDLIne+sRemark;
     TPanel(FindComponent( 'PanelUPH'+   AddZero(IntToStr(PDLINECount),2))).Caption := sUPH;
     TPanel(FindComponent( 'PanelTargetYieldT'+   AddZero(IntToStr(PDLINECount),2))).Caption := sTargetYield +'%';
     TPanel(FindComponent( 'PanelModel'+   AddZero(IntToStr(PDLINECount),2))).Caption := sModel;


     for  i:=0 to  QryData.RecordCount-1  do   begin
          Application.ProcessMessages;
          if    PDLINECount <= 10 then begin
              sPDLineName :=    QryData.FieldByName('PDLINE_NAME').AsString ;
              sSpy :=  QryData.FieldByName('FPY_YIELD').AsString ;
              sModel := QryData.FieldByName('Model_NAME').AsString ;
              sUPH :=   QryData.FieldByName('UPH').AsString ;
              sTargetYield :=   QryData.FieldByName('Cycle_Time').AsString ;
              sWorkTime :=  QryData.FieldByName('Work_TIME').AsString ;
              sRemark :=  QryData.FieldByName('Remark').AsString ;
              CurrentTime :=0;
              for j:=0 to 11 do begin
                  iPos :=  Pos('時',TPanel(FindComponent( 'PanelTittleT'+IntToStr(j+1))).Caption);

                  if  sWorkTime = Copy(TPanel(FindComponent( 'PanelTittleT'+IntToStr(j+1))).Caption,1,iPos-1) then begin
                      CurrentTime := j+1;
                  end;
              end;
              if  sPDLineName <>  sFristPDLIne  then  begin
                  sFristPDLIne :=  sPDLineName;
                  PDLINECount :=  PDLINECount+1;
                  TPanel(FindComponent( 'PanelPDLine'+ AddZero(IntToStr(PDLINECount),2))).Caption := sPDLineName+sRemark;
                  TPanel(FindComponent( 'PanelUPH'+    AddZero(IntToStr(PDLINECount),2))).Caption := sUPH;
                  TPanel(FindComponent( 'PanelTargetYieldT'+     AddZero(IntToStr(PDLINECount),2))).Caption := sTargetYield+'%';
                  TPanel(FindComponent( 'PanelModel'+  AddZero(IntToStr(PDLINECount),2))).Caption := sModel;
              end;
              TPanel(FindComponent( 'PanelYield'+ Format('%x',[CurrentTime]) +  AddZero(IntToStr(PDLINECount),2))).Caption := sSpy+'%';
              TPanel(FindComponent( 'PanelSN'+   AddZero(IntToStr(PDLINECount),2))).Caption := IntToStr(PDLINECount);


               if  PDLINECount <= 10 then
                    if ( StrToFloat(sSPY) <  StrToFloat(sTargetYield))   then
                       TPanel(FindComponent( 'PanelYield' + Format('%x',[CurrentTime]) +  AddZero(IntToStr(PDLINECount),2))).Color :=rgb(250,169,227);



              QryData.Next;
           end;
    end;

      if sShift ='D' then    begin
          if  (TimeSeq  > 4) and (TimeSeq  <=9 ) then   usedHour :=  TimeSeq-1;
          if  (TimeSeq  > 9 )  then   usedHour :=  TimeSeq-2;
          if  (TimeSeq  <= 4 )  then   usedHour :=  TimeSeq;
      end;

      if sShift ='N' then    begin
          if  (TimeSeq  >=4) and (TimeSeq  <=9 ) then   usedHour :=  TimeSeq-1;
          if  (TimeSeq  > 9 )  then   usedHour :=  TimeSeq-2;
          if  (TimeSeq  <= 3 )  then   usedHour :=  TimeSeq;
      end;
 
      if PDLINECount >10 then  PDLINECount :=10;
      for i:=0 to PDLINECount-1 do begin
          TPanel(FindComponent( 'PanelCT'+ AddZero(IntTostr(i+1),2))).Caption  := '產出';
          TPanel(FindComponent( 'PanelCT'+ AddZero(IntTostr(i+1),2))).Color := clNavy;
          TPanel(FindComponent( 'PanelYN'+ AddZero(IntTostr(i+1),2))).Caption  := '直通率' ;
          TPanel(FindComponent( 'PanelYN'+ AddZero(IntTostr(i+1),2))).Color  := clBlue ;
          if  ((TimeSeq =5) and (sShift ='D')) or  ((TimeSeq =4) and (sShift ='N')) then
            TPanel(FindComponent( 'PanelTargetOP'+ AddZero(IntTostr(i+1),2))).Caption  :=
                IntToSTR(round(StrToInt(TPanel(FindComponent( 'PanelUPH'+AddZero(IntTostr(i+1),2))).Caption)*usedHour))
          else
              //iMinu =Round((GetSysdate*24-trunc(GetSysdate*24))*60);
              TPanel(FindComponent( 'PanelTargetOP'+ AddZero(IntTostr(i+1),2))).Caption  :=
                  IntToSTR(round(StrToInt(TPanel(FindComponent( 'PanelUPH'+AddZero(IntTostr(i+1),2))).Caption)
                       *((usedHour-1)+(GetSysdate*24-trunc(GetSysdate*24)))));
      end;
end;


Procedure TuMainForm.DisplayOutput;
var i,j,CurrentTime,TempOP,tempRow,iPos:Integer;
    sPDLineName,soutput,sWorkTime,sHourTitle,sRPDLINE: string;
begin
     PDLINECount :=0;
     QryOutput.First;

     for  i:=0 to  QryOutput.RecordCount-1  do   begin
        sPDLineName :=    QryOutput.FieldByName('PDLINE_NAME').AsString ;
        soutput :=    QryOutput.FieldByName('Output_Qty').AsString ;
        sWorkTime :=  QryOutput.FieldByName('WORK_TIME').AsString ;
        CurrentTime :=0;

        for j:=0 to 9  do   begin
              if TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j+1),2))).Caption <> '' then  begin
                  iPos :=Pos('自動',TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j+1),2))).Caption );
                  if iPos >0 then
                     sRPDLINE := Copy(TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j+1),2))).Caption ,1,
                                          Length(TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j+1),2))).Caption)-6)
                  else
                     sRPDLINE := TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(j+1),2))).Caption;

                 if sPDLineName  =sRPDLINE then begin
                      tempRow :=  j+1;
                 end;
             end;
        end;

        for j:=0 to 11 do begin
              iPos :=  Pos('時',TPanel(FindComponent( 'PanelTittleT'+IntToStr(j+1))).Caption);
              if  sWorkTime = Copy(TPanel(FindComponent( 'PanelTittleT'+IntToStr(j+1))).Caption,1,iPos-1) then begin
                    CurrentTime := j+1;
              end;
        end;

         if Trim(TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(tempRow),2))).Caption) <> '' then  begin
            iPos :=Pos('自動',TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(tempRow),2))).Caption );
            if iPos >0 then
                sRPDLINE := Copy(TPanel(FindComponent( 'PanelPDLine'+ AddZero(IntToStr(tempRow),2))).Caption ,1,
                               Length(TPanel(FindComponent( 'PanelPDLine'+ AddZero(IntToStr(tempRow),2))).Caption)-6)
            else
                sRPDLINE := TPanel(FindComponent( 'PanelPDLine'+   AddZero(IntToStr(tempRow),2))).Caption;


            if sPDLineName  = sRPDLINE then
                 TPanel(FindComponent( 'PanelOutPut'+Format('%x',[CurrentTime]) +  AddZero(IntToStr(tempRow),2))).Caption := soutput;
         end else begin
                 TPanel(FindComponent( 'PanelOutPut'+Format('%x',[CurrentTime]) +  AddZero(IntToStr(tempRow),2))).Caption := '';
         end;

         QryOutput.Next;

     end;

     for j:=0 to 9 do begin
        TempOP :=0;
        for i:=0 to 11 do begin
           if TPanel(FindComponent( 'PanelOutput'+ Format('%x',[i+1]) +  AddZero(IntToStr(j+1),2))).Caption <> '' then
           begin
              TempOP :=TempOP +   StrToIntDef( TPanel(FindComponent( 'PanelOutput'+ Format('%x',[i+1]) +  AddZero(IntToStr(j+1),2))).Caption,0 );
              if   (TPanel(FindComponent( 'PanelTittleT'+ IntToStr(i+1))).Caption = '7時') or
                   (TPanel(FindComponent( 'PanelTittleT'+ IntToStr(i+1))).Caption = '19時') then begin
                   if StrToIntDef(TPanel(FindComponent( 'PanelOutput'+ Format('%x',[i+1]) +  AddZero(IntToStr(j+1),2))).Caption,0)
                      <  StrToIntDef( TPanel(FindComponent( 'PanelUPH' +AddZero(IntToStr(j+1),2))).Caption,0)/2  then
                      TPanel(FindComponent( 'PanelOutPut'+Format('%x',[i+1]) +  AddZero(IntToStr(j+1),2))).Color :=rgb(255,255,104);
              end else
              if (TPanel(FindComponent( 'PanelTittleT'+ IntToStr(i+1))).Caption <> '12時') and
                   (TPanel(FindComponent( 'PanelTittleT'+ IntToStr(i+1))).Caption <> '23時') then begin
                   if StrToIntDef(TPanel(FindComponent( 'PanelOutput'+ Format('%x',[i+1]) +  AddZero(IntToStr(j+1),2))).Caption,0)
                      <  StrToIntDef( TPanel(FindComponent( 'PanelUPH' +AddZero(IntToStr(j+1),2))).Caption,0)  then
                      TPanel(FindComponent( 'PanelOutPut'+Format('%x',[i+1]) +  AddZero(IntToStr(j+1),2))).Color :=rgb(255,255,104);
               end;
           end;
        end;
        if  TPanel(FindComponent( 'PanelPDLine'+  AddZero(IntToStr(j+1),2))).Caption  <>'' then
           TPanel(FindComponent( 'PanelActualOP'+  AddZero(IntToStr(j+1),2))).Caption :=   IntToStr(TempOP);
     end;
end;

procedure TuMainForm.ClearAllPanel;
var i,j:integer;
begin
     for i:=0 to 9 do begin
          TPanel(FindComponent( 'PanelSN'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelSN'+  AddZero(IntToStr(i+1),2))).Color :=clWhite;
          TPanel(FindComponent( 'PanelPDline'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelPDline'+  AddZero(IntToStr(i+1),2))).Color :=clWhite;
          TPanel(FindComponent( 'PanelModel'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelModel'+  AddZero(IntToStr(i+1),2))).Color :=clWhite;
          TPanel(FindComponent( 'PanelUPH'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelUPH'+  AddZero(IntToStr(i+1),2))).Color :=clWhite;
          TPanel(FindComponent( 'PanelCT'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelCT'+  AddZero(IntToStr(i+1),2))).Color :=clWhite;
          TPanel(FindComponent( 'PanelYN'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelYN'+  AddZero(IntToStr(i+1),2))).Color :=clWhite;
          TPanel(FindComponent( 'PanelModel'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelModel'+  AddZero(IntToStr(i+1),2))).Color :=clWhite;
          TPanel(FindComponent( 'PanelTargetOP'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelTargetOP'+  AddZero(IntToStr(i+1),2))).Color :=clWhite;
          TPanel(FindComponent( 'PanelTargetYieldT'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelTargetYieldT'+  AddZero(IntToStr(i+1),2))).Color :=clWhite;
          TPanel(FindComponent( 'PanelActualOP'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelActualOP'+  AddZero(IntToStr(i+1),2))).Color :=clWhite;
          TPanel(FindComponent( 'PanelActualYieldT'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelActualYieldT'+  AddZero(IntToStr(i+1),2))).Color :=clWhite;
          for  j:=0 to 11 do begin
                TPanel(FindComponent( 'PanelOutput'+ Format('%x',[j+1]) + AddZero(IntToStr(i+1),2))).Caption :='';
                TPanel(FindComponent( 'PanelOutput'+ Format('%x',[j+1]) + AddZero(IntToStr(i+1),2))).Color :=clWhite;
                TPanel(FindComponent( 'PanelYield'+ Format('%x',[j+1]) + AddZero(IntToStr(i+1),2))).Caption :='';
                TPanel(FindComponent( 'PanelYield'+ Format('%x',[j+1]) + AddZero(IntToStr(i+1),2))).Color :=clWhite;
          end;
     end;
end;

function TuMainForm.AddZero(s:string;HopeLength:Integer):String;
begin
   Result:=StringReplace(Format('%'+IntToStr(HopeLength)+'s',[s]),' ','0',[rfIgnoreCase,rfReplaceAll]);
end;

procedure TuMainForm.BtNextClick(Sender: TObject);
begin
    if ALL_Pages >1 then G_Page := G_Page+1;
    if G_Page >   ALL_Pages   then    G_Page :=1;
    ClearAllPanel;
    Timer1Timer(self);
end;

procedure TuMainForm.Timer2Timer(Sender: TObject);
begin
     if  Timer1.Enabled  then   begin
          BTNEXT.Click;
     end;
end;

procedure TuMainForm.SpeedButton1Click(Sender: TObject);
begin
    if SpeedButton1.Caption='Pause' then
    begin
            SpeedButton1.Caption:='Start';
            SpeedButton1.Font.Color:=clRed;
            Timer1.Enabled:=False;
            Timer2.Enabled:=False;
    end else begin
             SpeedButton1.Caption:='Pause';
             SpeedButton1.Font.Color:=clBlack;
              Timer1Timer(Self) ;
    end;
end;

function TuMainForm.GetSysDate:TDateTime;
begin
    csFTemp.Close;
    csFTemp.CommandText := 'select SysDate from  dual';
    csFTemp.Open;
    result := csFTemp.fieldbyname('SYSDate').AsDateTime;
end;

procedure TuMainForm.FormCreate(Sender: TObject);
begin
    StrLstPDLineID :=TStringList.Create;
    if   (SCREEN.WIDTH <1360) or  (SCREEN.Height<768) then begin
           MessageBox(0,'屏幕分辨率太低,請調高分辨率再開啟','提示',MB_ICONERROR);
           Application.Terminate;
    end;
    width :=SCREEN.WIDTH;
    height :=SCREEN.Height;
end;

procedure TuMainForm.PanelPDLine01DblClick(Sender: TObject);
var iPos:integer;
begin

    if (Sender as TPANEL).Caption ='' then exit;
    ipos := pos('自動',(Sender as TPANEL).Caption);
    if ipos >0 then
     sCurrentPDLine := Copy((Sender as TPANEL).Caption,1,length((Sender as TPANEL).Caption)-6)
    else
      sCurrentPDLine := (Sender as TPANEL).Caption;
    Timer1.Enabled :=false;
    Timer2.Enabled :=false;
    SpeedButton1.Caption:='Start';
    SpeedButton1.Font.Color:=clRed;
    LineDetail:= TLineDetail.Create(self);
    if LineDetail.ShowModal = mrok then
    begin
    end;
    Timer1.Enabled :=Enabled;
    
end;

procedure TuMainForm.btnCumClick(Sender: TObject);
var uCum : TuCum ;
begin
     uCum := TuCum.Create(self);
     uCum.ShowModal;
end;

procedure TuMainForm.PanelModel01DblClick(Sender: TObject);
var iPos:integer;
     sName,sPdlineName:String;
begin
    if (Sender as TPANEL).Caption ='' then exit;
    sCurrentModel := (Sender as TPANEL).Caption;
    sName := (Sender as TPANEL).Name;
    sPdlineName := TPanel(FindComponent('PanelPDLine'+Copy(sName,Length(SNAME)-1,2))).Caption;
    ipos := pos('自動',sPdlineName);
    if ipos >0 then
         sCurrentPDLine := Copy(sPdlineName,1,length(sPdlineName)-6)
    else
         sCurrentPDLine := sPdlineName;
    Timer1.Enabled :=false;
    Timer2.Enabled :=false;
    SpeedButton1.Caption:='Start';
    SpeedButton1.Font.Color:=clRed;
    ModelDetail:= TModelDetail.Create(self);
    if  ModelDetail.ShowModal = mrok then
    begin

    end;
    Timer1.Enabled :=Enabled;
end;


end.
