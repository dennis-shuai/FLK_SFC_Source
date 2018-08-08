unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, MConnect, ObjBrkr, DB, DBClient,
  SConnect,IniFiles,math,uMyClassHelpers;

type
  TuMainForm = class(TfmForm)
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
    PanelSN12: TPanel;
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
    PanelCT12: TPanel;
    PanelCT11: TPanel;
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
    PanelTittleT2: TPanel;
    PanelTittleT3: TPanel;
    PanelTittleT7: TPanel;
    PanelTittleT5: TPanel;
    PanelTittleT6: TPanel;
    PanelTittleT8: TPanel;
    PanelTittleT9: TPanel;
    PanelTittleT10: TPanel;
    PanelTittleT12: TPanel;
    Panel13: TPanel;
    PanelModel: TPanel;
    PanelModel02: TPanel;
    PanelModel03: TPanel;
    PanelModel04: TPanel;
    PanelModel05: TPanel;
    PanelModel06: TPanel;
    PanelModel07: TPanel;
    PanelModel08: TPanel;
    PanelModel12: TPanel;
    PanelModel11: TPanel;
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
    SpeedButton1: TSpeedButton;
    BtNext: TSpeedButton;
    BtSetup: TSpeedButton;
    lblTime: TLabel;
    SimpleObjectBroker1: TSimpleObjectBroker;
    Timer1: TTimer;
    Timer2: TTimer;
    QryPlan: TClientDataSet;
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
    PanelYN11: TPanel;
    PanelYN12: TPanel;
    btnCum: TSpeedButton;
    QryOutput: TClientDataSet;
    QryPdline: TClientDataSet;
    QryTemp: TClientDataSet;
    PanelSN11: TPanel;
    PanelSN14: TPanel;
    PanelSN13: TPanel;
    PanelPDLine14: TPanel;
    PanelPDLine12: TPanel;
    PanelPDLine11: TPanel;
    PanelPDLine13: TPanel;
    PanelModel09: TPanel;
    PanelModel10: TPanel;
    PanelModel13: TPanel;
    PanelModel14: TPanel;
    PanelCT09: TPanel;
    PanelYN09: TPanel;
    PanelCT10: TPanel;
    PanelYN10: TPanel;
    PanelCT13: TPanel;
    PanelYN13: TPanel;
    PanelCT14: TPanel;
    PanelYN14: TPanel;
    PanelSN10: TPanel;
    PanelOutput111: TPanel;
    PanelYield111: TPanel;
    PanelOutput112: TPanel;
    PanelYield112: TPanel;
    PanelYield113: TPanel;
    PanelOutput113: TPanel;
    PanelOutput114: TPanel;
    PanelYield114: TPanel;
    PanelOutput211: TPanel;
    PanelYield211: TPanel;
    PanelOutput212: TPanel;
    PanelYield212: TPanel;
    PanelOutput213: TPanel;
    PanelYield213: TPanel;
    PanelOutput214: TPanel;
    PanelYield214: TPanel;
    PanelOutput311: TPanel;
    PanelYield311: TPanel;
    PanelOutput312: TPanel;
    PanelYield312: TPanel;
    PanelOutput313: TPanel;
    PanelYield313: TPanel;
    PanelOutput314: TPanel;
    PanelYield314: TPanel;
    PanelOutput411: TPanel;
    PanelYield411: TPanel;
    PanelOutput412: TPanel;
    PanelYield412: TPanel;
    PanelOutput413: TPanel;
    PanelYield413: TPanel;
    PanelOutput414: TPanel;
    PanelYield414: TPanel;
    PanelOutput511: TPanel;
    PanelYield511: TPanel;
    PanelOutput512: TPanel;
    PanelYield512: TPanel;
    PanelOutput513: TPanel;
    PanelYield513: TPanel;
    PanelOutput514: TPanel;
    PanelYield514: TPanel;
    PanelOutput611: TPanel;
    PanelYield611: TPanel;
    PanelOutput612: TPanel;
    PanelYield612: TPanel;
    PanelOutput613: TPanel;
    PanelYield613: TPanel;
    PanelOutput614: TPanel;
    PanelYield614: TPanel;
    PanelOutput711: TPanel;
    PanelYield711: TPanel;
    PanelOutput712: TPanel;
    PanelYield712: TPanel;
    PanelOutput713: TPanel;
    PanelYield713: TPanel;
    PanelOutput714: TPanel;
    PanelYield714: TPanel;
    PanelOutput811: TPanel;
    PanelYield811: TPanel;
    PanelOutput812: TPanel;
    PanelYield812: TPanel;
    PanelOutput813: TPanel;
    PanelYield813: TPanel;
    PanelOutput814: TPanel;
    PanelYield814: TPanel;
    PanelOutput911: TPanel;
    PanelYield911: TPanel;
    PanelOutput912: TPanel;
    PanelYield912: TPanel;
    PanelOutput913: TPanel;
    PanelYield913: TPanel;
    PanelOutput914: TPanel;
    PanelYield914: TPanel;
    PanelOutputA11: TPanel;
    PanelYieldA11: TPanel;
    PanelOutputA12: TPanel;
    PanelYieldA12: TPanel;
    PanelOutputA13: TPanel;
    PanelYieldA13: TPanel;
    PanelOutputA14: TPanel;
    PanelYieldA14: TPanel;
    PanelOutputB11: TPanel;
    PanelYieldB11: TPanel;
    PanelOutputB12: TPanel;
    PanelYieldB12: TPanel;
    PanelOutputB13: TPanel;
    PanelYieldB13: TPanel;
    PanelOutputB14: TPanel;
    PanelYieldB14: TPanel;
    PanelOutputC11: TPanel;
    PanelYieldC11: TPanel;
    PanelOutputC12: TPanel;
    PanelYieldC12: TPanel;
    PanelOutputC13: TPanel;
    PanelYieldC13: TPanel;
    PanelOutputC14: TPanel;
    PanelYieldC14: TPanel;
    PanelActualOP11: TPanel;
    PanelActualYieldT11: TPanel;
    PanelActualOP12: TPanel;
    PanelActualYieldT12: TPanel;
    PanelActualOP13: TPanel;
    PanelActualYieldT13: TPanel;
    PanelActualOP14: TPanel;
    PanelActualYieldT14: TPanel;
    btnPrefix: TSpeedButton;
    btnFirst: TSpeedButton;
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
    procedure btnPrefixClick(Sender: TObject);
    procedure btnFirstClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    StrLst,StrLst1,StrLstPdLineID,StrLstPdLineName,StrLstProcess,sStr,StrLstProcessName,StrLstDate,StrLstHour,sShiftID,sStrTmp: TStringList;
    sDayShiftID,sNightShiftID,sDayShiftTime,sNightShiftTime : TStringList;
    ALL_Pages,G_Page,ALL_Rows ,iRow,TimeSeq : Integer;
   // G_Repeat,G_status,
   G_UpdateStatus,sStartTime,sEndTime,sShift,sShowPDline: String;
    bCurrentShift  : Boolean;
    sShiftHour: array[0..11] of integer;
    sDayShiftDay,sNightShiftDay,sCurrentHour,sPDLine,sCurrentPDLine,sCurrentModel,sStartDateTime,sEndDateTime : String;
    function LoadApServer: Boolean;
    Procedure QueryOutput(DataTemp:TClientDataSet);
    Procedure QueryCurrentDate(DataTemp:TClientDataSet);
    Procedure QueryPreShiftDate(DataTemp:TClientDataSet);
    Procedure DisplayOutput;
    function  AddZero(s:string;HopeLength:Integer):String;
    procedure ClearAllPanel;
    function  GetSysDate:TDateTime;
    Procedure QueryPlan(DataTemp:TClientDataSet);
    Procedure QueryPdline(DataTemp:TClientDataSet);
    Procedure DisplayPlan;
    //Procedure DisplayPdline;
    procedure  SetPdline(spdline:string;iMyrow,iMult:integer);
    procedure  SetAllPdline;
  end;

var
  uMainForm: TuMainForm;

implementation

{$R *.dfm}

uses uLine,uCumDetail;


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
   //lblTitle.Left := round((uMainForm.Width -lblTitle.Width)/2);

   LoadApServer;

   if not (DirectoryExists(ExtractFilePath(Application.ExeName)+'\InI')) then
    ForceDirectories(ExtractFilePath(Application.ExeName)+'\InI');
   fInI:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'InI\SAJETMonitor.ini');
   With fInI do
   begin
     J := StrToInt(ReadString('Monitor Chosen Pdline Name', 'Count', '0'));
     for I := 1 to J do
     begin
         sIstr:=fInI.ReadString('Monitor Chosen Pdline Name', 'Pdline_' + IntToStr(I), '');
         StrLstPDLineID.Add(sIstr);
     end;
    //lblTitle.Caption:=fInI.ReadString('Monitor Factory Name', 'Name', 'Workshop Produce Status Monitor');
    Timer1.Interval :=StrToInt(fInI.ReadString('Interval', 'Data', '1'))*1000*60;
    Timer2.Interval :=StrToInt(fInI.ReadString('Interval', 'Page', '10'))*1000;
   end;

   sPDline := ''''+StrLstPDLineID.Strings[0]+ '''';
   for i:=1 to j-1 do  begin
        sPDline := sPDline+  ','''+StrLstPDLineID.Strings[i] +'''';
   end;
   ALL_Pages :=13;

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
   SpeedButton1.Caption:='繼續';
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
    if    G_UpdateStatus='N' then
    begin
         uMainForm.Timer1.Enabled := True;
         uMainForm.Timer2.Enabled := True;
    end;
    btnPrefix.Caption :='前一班別';
    btnPrefix.Font.Color:=clBlack;
    SpeedButton1.Caption:='暫停';
    SpeedButton1.Font.Color:=clBlack;
end;

procedure TuMainForm.Timer1Timer(Sender: TObject);
begin

     Timer1.Enabled :=false;
     lblTime.Caption := 'UpdateTime:  '+FormatDateTime('yyyy/mm/dd hh:mm:ss',now);
     if bCurrentShift then
          QueryCurrentDate(QryTemp)
     else
          QueryPreShiftDate(QryTemp);
     ClearAllPanel;
     Application.ProcessMessages;

     //QueryPdline(qryPdline);
     //DisplayPdline;
     SetAllPdline;
     QueryOutput(QryOutput);
     DisplayOutput;

     QueryPlan(QryPlan);
     DisplayPlan;

     Timer1.Enabled :=true;
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

     //sCurrentTime := DataTemp.FieldByName('DATETime').AsString;

     if sShift ='D' then begin
         for i:=0 to 11 do
         begin
            sShiftHour[i] := i+8 ;
            TPanel(FindComponent('panelTittleT'+ IntToStr(i+1))).Caption :=  IntToStr(sShiftHour[i] )+'時';
         end;
      end else begin
         for i:=0 to 3 do
         begin
            TPanel(FindComponent('panelTittleT'+ IntToStr(i+1))).Caption := IntToStr(20+i )+'時';
            sShiftHour[i] := 20+i;
         end;
         for i:=4 to 11 do
         begin
            sShiftHour[i] := i-4;
            TPanel(FindComponent('panelTittleT'+ IntToStr(i+1))).Caption := IntToStr(i-4 )+'時';
         end;
     end;

     for i:=0 to 11 do
     begin
         if  DataTemp.FieldByName( 'TIME1').AsInteger = sShiftHour[i] then
               TimeSeq := i+1;
     end;

end;


Procedure TuMainForm.QueryPreShiftDate(DataTemp:TClientDataSet);
var i:integer;
begin

     DataTemp.Close;
     DataTemp.Params.Clear;
     DataTemp.CommandText := 'select to_Char(sysDate-0.5,''yyyymmdd'') as DATE1, to_Char(sysDate-0.5,''HH24'') as TIME1 ,  '+
                                    ' to_Char(sysDate-0.5,''yyyymmddHH24'') as DATETIME, to_Char(sysDate-1-0.5,''yyyymmdd'')'+
                                    ' as lastDate, to_Char(sysDate+1-0.5,''yyyymmdd'') as NextDay from dual';
     DataTemp.Open;
     if    (DataTemp.FieldByName( 'TIME1').AsInteger >= 8 ) and  (DataTemp.FieldByName( 'TIME1').AsInteger <20 ) then begin
         sStartTime :=  DataTemp.FieldByName( 'DATE1').AsString+'08';
         sEndTime :=    DataTemp.FieldByName( 'DATE1').AsString +'20';
         sEndDateTime :=   sEndTime ;
         sShift :='D';
     end else if (DataTemp.FieldByName( 'TIME1').AsInteger >= 0) and (DataTemp.FieldByName( 'TIME1').AsInteger <8) then begin

          sStartTime :=  DataTemp.FieldByName( 'lastDate').AsString +'20' ;
          sEndTime   :=   DataTemp.FieldByName( 'DATE1').AsString +'08';
          sEndDateTime :=   sEndTime  ;
          sShift :='N';
     end else   if DataTemp.FieldByName( 'TIME1').AsInteger >= 20  then begin
          sStartTime :=  DataTemp.FieldByName( 'DATE1').AsString +'20' ;
          sEndTime   :=  DataTemp.FieldByName( 'NextDay').AsString +'08';
          sEndDateTime :=   sEndTime;
          sShift :='N';
     end;

     //sCurrentTime := DataTemp.FieldByName('DATETime').AsString;

     if sShift ='D' then
     begin
         for i:=0 to 11 do begin
            sShiftHour[i] := i+8 ;
            TPanel(FindComponent('panelTittleT'+ IntToStr(i+1))).Caption :=  IntToStr(sShiftHour[i] )+'時';
         end;
     end else
     begin
         for i:=0 to 3 do begin
            TPanel(FindComponent('panelTittleT'+ IntToStr(i+1))).Caption := IntToStr(20+i )+'時';
            sShiftHour[i] := 20+i;
         end;
         for i:=4 to 11 do begin
            sShiftHour[i] := i-4;
            TPanel(FindComponent('panelTittleT'+ IntToStr(i+1))).Caption := IntToStr(i-4 )+'時';
         end;
     end;

     TimeSeq := 12;
end;

procedure  TuMainForm.SetPdline(spdline:string;iMyrow,iMult:integer);
var sMyPdline:string;
    i,j,iRow,iColor:Integer;
begin

      sMyPdline :=spdline;
      i:=0;
      TPanel(FindComponent('PanelPDLine'+ AddZero(IntToStr(i+1+iMyrow*iMult),2))).Caption :=sMyPdline;
      sShowPDline := ''''+sMyPdline+'''';
      QueryPdline(QryTemp);
      if (QryTemp.RecordCount<= iMyrow ) then iRow:= QryTemp.RecordCount
      else iRow :=iMyrow;
      QryTemp.First;
      for i:=0 to irow-1 do
      begin
         TPanel(FindComponent('PanelPDLine'+ AddZero(IntToStr(i+1+iMyrow*iMult),2))).Caption  := sMyPdline;
         TPanel(FindComponent('PanelModel'+ AddZero(IntToStr(i+1+iMyrow*iMult),2))).Caption  := QryTemp.fieldByName('Model_Name').AsString;
         TPanel(FindComponent('PanelCT'+ AddZero(IntToStr(i+1+iMyrow*iMult),2))).Caption  := '計劃產出';
         TPanel(FindComponent('PanelYN'+ AddZero(IntToStr(i+1+iMyrow*iMult),2))).Caption  := '實際產出';
         QryTemp.Next;
      end;

       for i:=0 to iMyrow-1 do
      begin
          if iMult mod 2 = 0 then
             iColor :=$00D2FFFF
          else
             iColor :=$00C4FFC4;

          TPanel(FindComponent( 'PanelSN'+  AddZero(IntToStr(i+1+iMyrow*iMult),2))).Color :=iColor;
          TPanel(FindComponent( 'PanelPDline'+  AddZero(IntToStr(i+1+iMyrow*iMult),2))).Color :=iColor;
          TPanel(FindComponent( 'PanelModel'+  AddZero(IntToStr(i+1+iMyrow*iMult),2))).Color :=iColor;
          TPanel(FindComponent( 'PanelCT'+  AddZero(IntToStr(i+1+iMyrow*iMult),2))).Color :=iColor;
          TPanel(FindComponent( 'PanelYN'+  AddZero(IntToStr(i+1+iMyrow*iMult),2))).Color :=iColor;
          TPanel(FindComponent( 'PanelModel'+  AddZero(IntToStr(i+1+iMyrow*iMult),2))).Color :=iColor;
          TPanel(FindComponent( 'PanelActualOP'+  AddZero(IntToStr(i+1+iMyrow*iMult),2))).Color :=iColor;
          TPanel(FindComponent( 'PanelActualYieldT'+  AddZero(IntToStr(i+1+iMyrow*iMult),2))).Color :=iColor;
          for  j:=0 to 11 do
          begin
              TPanel(FindComponent( 'PanelOutput'+ Format('%x',[j+1]) + AddZero(IntToStr(i+1+iMyrow*iMult),2))).Color :=iColor ;
              TPanel(FindComponent( 'PanelYield'+ Format('%x',[j+1]) + AddZero(IntToStr(i+1++iMyrow*iMult),2))).Color :=iColor;
          end;
      end;
end;


procedure  TuMainForm.SetAllPdline;
var iRow:Integer;
    sMyPdline :string;
begin
   if G_Page =1 then
   begin
        sMyPdline :='SMT_A';
        SetPdline(sMyPdline,7,0);

        sMyPdline :='SMT_B';
        SetPdline(sMyPdline,7,1);

        sPDline := '''SMT_A'',''SMT_B''';

   end
   else if G_Page =2 then
   begin
        sMyPdline :='SMT_C';
        SetPdline(sMyPdline,7,0);

        sMyPdline :='SMT_D';
        SetPdline(sMyPdline,7,1);

         sPDline := '''SMT_C'',''SMT_D''';

   end else if G_Page =3 then  begin
        sMyPdline :='CM1_01';
        SetPdline(sMyPdline,3,0);

        sMyPdline :='CM1_02';
        SetPdline(sMyPdline,3,1);

        sMyPdline :='CM1_03';
        SetPdline(sMyPdline,3,2);

        sMyPdline :='CM1_04';
        SetPdline(sMyPdline,3,3);

        sPDline := '''CM1_01'',''CM1_02'',''CM1_03'',''CM1_04''';

   end else if G_Page =4 then  begin

        sMyPdline :='CM1_05';
        SetPdline(sMyPdline,3,0);

        sMyPdline :='CM1_06';
        SetPdline(sMyPdline,3,1);

        sMyPdline :='CM1_07';
        SetPdline(sMyPdline,3,2);

        sMyPdline :='CM1_08';
        SetPdline(sMyPdline,3,3);
        sPDline := '''CM1_05'',''CM1_06'',''CM1_07'',''CM1_08''';

   end else if G_Page =5 then  begin

        sMyPdline :='CM1_09';
        SetPdline(sMyPdline,3,0);

        sMyPdline :='CM1_10';
        SetPdline(sMyPdline,3,1);

        sMyPdline :='CM1_11';
        SetPdline(sMyPdline,3,2);

        sMyPdline :='CM1_12';
        SetPdline(sMyPdline,3,3);

        sPDline := '''CM1_09'',''CM1_10'',''CM1_11'',''CM1_12''';

   end else if G_Page =6 then  begin

        sMyPdline :='CM2_01';
        SetPdline(sMyPdline,3,0);

        sMyPdline :='CM2_02';
        SetPdline(sMyPdline,3,1);

        sMyPdline :='CM2_03';
        SetPdline(sMyPdline,3,2);

        sMyPdline :='CM2_04';
        SetPdline(sMyPdline,3,3);

         sPDline := '''CM2_01'',''CM2_02'',''CM2_03'',''CM2_04''';

   end else if G_Page =7 then  begin

        sMyPdline :='CM2_05';
        SetPdline(sMyPdline,3,0);

        sMyPdline :='CM2_06';
        SetPdline(sMyPdline,3,1);

        sMyPdline :='CM2_07';
        SetPdline(sMyPdline,3,2);

        sMyPdline :='CM2_08';
        SetPdline(sMyPdline,3,3);

        sPDline := '''CM2_05'',''CM2_06'',''CM2_07'',''CM2_08''';

   end else if G_Page =8 then  begin

        sMyPdline :='CM2_09';
        SetPdline(sMyPdline,3,0);

        sMyPdline :='CM2_10';
        SetPdline(sMyPdline,3,1);

        sMyPdline :='CM2_11';
        SetPdline(sMyPdline,3,2);

        sMyPdline :='CM2_12';
        SetPdline(sMyPdline,3,3);
        sPDline := '''CM2_09'',''CM2_10'',''CM2_11'',''CM2_12''';

   end else if G_Page =9 then  begin

        sMyPdline :='CM3_01';
        SetPdline(sMyPdline,3,0);

        sMyPdline :='CM3_02';
        SetPdline(sMyPdline,3,1);

        sMyPdline :='CM3_03';
        SetPdline(sMyPdline,3,2);

        sMyPdline :='CM3_04';
        SetPdline(sMyPdline,3,3);
        sPDline := '''CM3_01'',''CM3_02'',''CM3_03'',''CM3_04''';

   end else if G_Page =10 then begin

        sMyPdline :='CM3_05';
        SetPdline(sMyPdline,3,0);

        sMyPdline :='CM3_06';
        SetPdline(sMyPdline,3,1);

        sMyPdline :='CM3_07';
        SetPdline(sMyPdline,3,2);

        sMyPdline :='CM3_08';
        SetPdline(sMyPdline,3,3);
        sPDline := '''CM3_05'',''CM3_06'',''CM3_07'',''CM3_08''';

   end else if G_Page =11 then begin

        sMyPdline :='CM3_09';
        SetPdline(sMyPdline,3,0);

        sMyPdline :='CM3_10';
        SetPdline(sMyPdline,3,1);

        sMyPdline :='CM3_11';
        SetPdline(sMyPdline,3,2);

        sMyPdline :='CM3_12';
        SetPdline(sMyPdline,3,3);
        sPDline := '''CM3_09'',''CM3_10'',''CM3_11'',''CM3_12''';

   end else if G_Page =12 then begin
        sMyPdline :='CM4_01';
        SetPdline(sMyPdline,3,0);

        sMyPdline :='CM4_02';
        SetPdline(sMyPdline,3,1);

        sMyPdline :='CM4_03';
        SetPdline(sMyPdline,3,2);

        sMyPdline :='CM4_04';
        SetPdline(sMyPdline,3,3);
        sPDline := '''CM4_01'',''CM4_02'',''CM4_03'',''CM4_04''';

   end else if G_Page =13 then begin
        sMyPdline :='CM4_05';
        SetPdline(sMyPdline,3,0);

        sMyPdline :='CM4_06';
        SetPdline(sMyPdline,3,1);
        sMyPdline :='CM4_07';
        SetPdline(sMyPdline,3,2);

        sMyPdline :='CM4_08';
        SetPdline(sMyPdline,3,3);
        sPDline := '''CM4_05'',''CM4_06'',''CM4_07'',''CM4_08''';

   end else if G_Page =14 then begin

        sMyPdline :='CM4_09';
        SetPdline(sMyPdline,3,0);

        sMyPdline :='CM4_10';
        SetPdline(sMyPdline,3,1);

        sMyPdline :='CM4_11';
        SetPdline(sMyPdline,3,2);

        sMyPdline :='CM4_12';
        SetPdline(sMyPdline,3,3);
        sPDline := '''CM4_09'',''CM4_10'',''CM4_11'',''CM4_12''';

   end else if G_Page =15 then begin
        sMyPdline :='CM5_01';
        SetPdline(sMyPdline,3,0);

        sMyPdline :='CM5_02';
        SetPdline(sMyPdline,3,1);

        sMyPdline :='CM5_03';
        SetPdline(sMyPdline,3,2);

        sMyPdline :='CM5_04';
        SetPdline(sMyPdline,3,3);
        sPDline := '''CM5_01'',''CM5_02'',''CM5_03'',''CM5_04''';

   end else if G_Page =16 then begin
        sMyPdline :='CM5_05';
        SetPdline(sMyPdline,3,0);

        sMyPdline :='CM5_06';
        SetPdline(sMyPdline,3,1);
        sMyPdline :='CM5_07';
        SetPdline(sMyPdline,3,2);

        sMyPdline :='CM5_08';
        SetPdline(sMyPdline,3,3);
        sPDline := '''CM5_05'',''CM5_06'',''CM5_07'',''CM5_08''';

   end else if G_Page =17 then begin

        sMyPdline :='CM5_09';
        SetPdline(sMyPdline,3,0);

        sMyPdline :='CM5_10';
        SetPdline(sMyPdline,3,1);

        sMyPdline :='CM5_11';
        SetPdline(sMyPdline,3,2);

        sMyPdline :='CM5_12';
        SetPdline(sMyPdline,3,3);
        sPDline := '''CM5_09'',''CM5_10'',''CM5_11'',''CM5_12''';
   end;

end;


Procedure TuMainForm.QueryPdline(DataTemp:TClientDataSet);
begin
     DataTemp.Close;
     DataTemp.Params.Clear;
     DataTemp.Params.CreateParam(ftstring,'StartTime',ptInput);
     DataTemp.Params.CreateParam(ftstring,'EndTime',ptInput);
     DataTemp.CommandText :=   '  Select Model_name,min(worktime) wktime  from ( '+
                               '  select e.Model_name,b.pdline_name,C.Remark,G.PROCESS_CODE,to_char(A.WORK_DATE)||TRIM(to_CHAR(A.WORK_TIME,''00'')) worktime  '+
                               ' from sajet.g_sn_count a, sajet.sys_pdline b, SAJET.SYS_PDLINE_MONITOR_BASE c, '+
                               ' SAJET.sys_part d,sajet.sys_model e,SAJET.SYS_PROCESS G '+
                               ' where  a.pdline_id =b.pdline_id and a.pdline_id =c.pdline_id and a.process_id = c.process_id and a.model_id =D.part_id '+
                               ' and a.Process_id =g.Process_id  and a.Pass_qty <>0  '+
                               ' and D.MODEL_ID =E.MODEL_ID and to_char(A.WORK_DATE)||TRIM(to_CHAR(A.WORK_TIME,''00'')) >=:StartTime '+
                               ' and to_char(A.WORK_DATE)||TRIM(to_CHAR(A.WORK_TIME,''00'')) <:EndTime  '+
                               ' union      '+
                               ' select a.Model_name,c.Pdline_name,b.Remark,d.Process_code,null from sajet.G_pdline_Manage a,sajet.SYS_PDLINE_MONITOR_BASE b ,sajet.sys_pdline c ,'+
                               ' sajet.sys_process d where  a.pdline_id =b.pdline_id and b.pdline_id=c.pdline_id and a.starttime>=:startTime and '+
                               ' a.endtime <=:endtime  and b.process_id =d.process_id and a.repair_line =''N'' and a.pd_status=1 '+
                               ' ) where  pdline_name ='+sShowPdline+'  group by Model_name,Pdline_name,Remark,PROCESS_CODE  '+
                               ' order by PROCESS_CODE,wktime ';
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
     DataTemp.CommandText :=   ' SELECT PDLINE_NAME,MODEL_NAME,PROCESS_NAME,PROCESS_CODE,Remark,DATETIME ,WORK_TIME,NVL(SUM(PASS_QTY),0) as FPY_QTY ,  '+
                               '      NVL(SUM(FAIL_QTY),0) AS FAIL_QTY ,NVL(SUM(NTF_QTY),0) AS NTF_QTY,                                   '+
                               '      NVL(SUM(PASS_QTY)+SUM(FAIL_QTY),0) as TOTAL_QTY, NVL(SUM(PASS_QTY)+SUM(NTF_QTY),0) as OUTPUT_QTY   '+
                               '      from (                                                                                '+
                               '           select F.MODEL_NAME,C.PDLINE_NAME ,b.PROCESS_NAME,b.PROCESS_CODE,to_char(A.WORK_DATE)||TRIM(to_CHAR(A.WORK_TIME,''00'')) as "DATETIME",'+
                               '               A.WORK_TIME, D.Remark, A.PASS_QTY,A.FAIL_QTY,A.NTF_QTY  from SAJET.G_SN_COUNT A, SAJET.SYS_PROCESS B,SAJET.SYS_PDLINE C , '+
                               '               SAJET.SYS_PDLINE_MONITOR_BASE D ,SAJET.SYS_PART E,SAJET.SYS_MODEL F '+
                               '           where A.PDLINE_ID =C.PDLINE_ID and A.PROCESS_ID =b.PROCESS_ID  and A.PROCESS_ID =D.PROCESS_ID  and A.PDLINE_ID =D.PDLINE_ID '+
                               '                   and (a.Pass_QTY+a.FAIL_QTY) <>0  AND A.MODEL_ID=E.PART_ID AND F.MODEL_ID = E.MODEL_ID AND '+
                               '       to_char(A.WORK_DATE)||TRIM(to_CHAR(A.WORK_TIME,''00'')) >=:StartTime AND to_char(A.WORK_DATE)||TRIM(to_CHAR(A.WORK_TIME,''00'')) <:ENDTIME '+
                               '      ) where   PDLINE_NAME IN (   ' + sPDline +
                               ' )   group by MODEL_NAME,PDLINE_NAME ,PROCESS_NAME,PROCESS_CODE,Remark,DATETIME, WORK_TIME  ORDER BY PROCESS_CODE,PDLINE_NAME,MODEL_NAME,WORK_TIME ';
    DataTemp.Params.ParamByName('StartTime').AsString :=sStartTime;
    DataTemp.Params.ParamByName('EndTime').AsString :=sEndDateTime;
    DataTemp.Open;

end;

Procedure TuMainForm.QueryPlan(DataTemp:TClientDataSet);
begin
     DataTemp.Close;
     DataTemp.Params.Clear;
     DataTemp.Params.CreateParam(ftstring,'StartTime',ptInput);
     DataTemp.Params.CreateParam(ftstring,'EndTime',ptInput);
     DataTemp.CommandText :=  ' SELECT A.MODEL_NAME,B.PDLINE_NAME,A.UPH,A.HOURCOUNT,A.PRODUCE_QTY '+
                              ' FROM SAJET.G_PDLINE_MANAGE A,SAJET.SYS_PDLINE B ' +
                              ' WHERE A.STARTTIME >= :StartTime AND A.ENDTIME <=:EndTime AND A.REPAIR_LINE =''N'' AND A.PD_STATUS=1 '+
                              ' AND A.PDLINE_ID=B.PDLINE_ID  order by B.PDLINE_NAME ';
     DataTemp.Params.ParamByName('StartTime').AsString :=sStartTime;
     DataTemp.Params.ParamByName('EndTime').AsString :=sEndDateTime;
     DataTemp.Open;
end;

Procedure TuMainForm.DisplayOutput;
var i,j,CurrentTime,iPos:Integer;
    sPDLineName,sRPdline,sModel,soutput,sWorkTime,sTemp: string;
begin
     QryOutput.First;
     for  i:=0 to  QryOutput.RecordCount-1  do   begin

          sPDLineName :=    QryOutput.FieldByName('PDLINE_NAME').AsString ;
          sModel := QryOutput.FieldByName('Model_NAME').AsString ;
          soutput := QryOutput.FieldByName('Output_Qty').AsString ;
          sWorkTime :=  QryOutput.FieldByName('Work_TIME').AsString ;

          CurrentTime :=0;
          for j:=0 to 11 do begin
              iPos :=  Pos('時',TPanel(FindComponent( 'PanelTittleT'+IntToStr(j+1))).Caption);

              if  sWorkTime = Copy(TPanel(FindComponent( 'PanelTittleT'+IntToStr(j+1))).Caption,1,iPos-1) then begin
                  CurrentTime := j+1;
              end;
          end;

          for j:=1 to 14 do begin
              sTemp := TPanel(FindComponent( 'PanelPdline'+AddZero(IntToStr(j),2))).Caption ;
              iPos :=  Pos('自動',sTemp);
              if iPos>0 then begin
                   sRPdline := Copy(sTemp,1,length(sTemp)-6);

              end else  sRPdline := sTemp;

              if (sRpdline = sPDLineName) and  ( TPanel(FindComponent( 'PanelModel'+AddZero(IntToStr(j),2))).Caption =sModel) then
                      TPanel(FindComponent( 'PanelYield'+ Format('%x',[CurrentTime]) +  AddZero(IntToStr(j),2))).Caption := soutput;

          end;
          QryOutput.Next;
    end;

end;


Procedure TuMainForm.DisplayPlan;
var i,j,k,m,iPos,iPos1:integer;
     sPdline,sRPdline,sModel,sTime,sHour,sTemp,sTemp2,sTarget,sUPH:string;
     fPlan,fOutput:Double;
begin
     if QryPlan.IsEmpty then exit;
     Qryplan.First;

     for i:=0 to  QryPlan.RecordCount-1 do
     begin
         sPdline := qryPlan.fieldbyName('pdline_Name').AsString;
         sModel :=  qryPlan.fieldbyName('Model_Name').AsString;
         sTemp  :=  qryPlan.fieldbyName('HOURCOUNT').AsString;
         sTarget := qryPlan.fieldbyName('Produce_QTY').AsString;
         sUPH :=    qryPlan.fieldbyName('UPH').AsString;

         for j:=1 to 14 do
         begin
            sTemp2 :=TPanel(FindComponent('PanelPDLine'+AddZero(IntToStr(j),2) )).Caption;
            if Pos('自動',sTemp2)>0 then
                 sRPdline := Copy(sTemp2,1,length(sTemp2)-6)
            else sRPdline := sTemp2;

             if  (sRPdline=sPdline) and (TPanel(FindComponent('PanelModel'+AddZero(IntToStr(j),2) )).Caption =sModel) then
             begin
                  if sTemp <>'' then
                  begin
                       for k :=0 to 11 do
                       begin
                           ipos :=pos(',',sTemp);
                           if ipos >0 then
                           begin
                                sTime := Copy(sTemp,1,ipos-1);
                                ipos1 := pos(':',sTime);
                                shour :=  Copy(sTime,iPos1+1,length(sTime)-iPos1);
                                sTime :=  Copy(sTime,1,iPos1-1);
                                for m:=1 to TimeSeq do
                                begin
                                   sTemp2 :=TPanel(FindComponent('PanelTittleT'+IntToStr(m))).Caption;
                                   if Pos('時',sTemp2) >0 then
                                      sTemp2 := Copy(sTemp2,1,length(sTemp2)-2);
                                   if  sTemp2 = sTime then begin
                                       TPanel(FindComponent('PanelOutput'+ Format('%x',[m])+AddZero(IntToStr(j),2))).Caption
                                             := IntToStr(Round(StrToFloat(shour)*StrToFloat(sUPH)));
                                   end;

                                end;
                           end;

                           stemp:= Copy(sTemp,iPos+1,length(sTemp)-iPos);
                        end;
                  end;


             end;
         end;
         qryPlan.Next;
     end;


     for i:=1 to  14 do
     begin
          if TPanel(FindComponent('PanelPdline'+AddZero(IntToStr(i),2))).Caption <> '' then
          begin
            fPlan:=0;
            fOutput:=0;
             for j:=1 to  12 do
             begin
                 fPlan := fPlan +  StrtoFloatDef(TPanel(FindComponent('PanelOutput'+ Format('%x',[j])+AddZero(IntToStr(i),2))).Caption ,0);
                 fOutput := fOutput +  StrtoFloatDef(TPanel(FindComponent('PanelYield'+ Format('%x',[j])+AddZero(IntToStr(i),2))).Caption ,0);
             end;
             TPanel(FindComponent('PanelActualOP'+AddZero(IntToStr(i),2))).Caption :=FloatToStr(fPlan);
             TPanel(FindComponent('PanelActualYieldT'+AddZero(IntToStr(i),2))).Caption :=FloatToStr(fOutput);
          end;
     end;

end;

procedure TuMainForm.ClearAllPanel;
var i,j:integer;
begin
     for i:=0 to 13 do
     begin
          TPanel(FindComponent( 'PanelSN'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelPDline'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelModel'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelCT'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelYN'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelModel'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelActualOP'+  AddZero(IntToStr(i+1),2))).Caption :='';
          TPanel(FindComponent( 'PanelActualYieldT'+  AddZero(IntToStr(i+1),2))).Caption :='';
          for  j:=0 to 11 do
          begin
                TPanel(FindComponent( 'PanelOutput'+ Format('%x',[j+1]) + AddZero(IntToStr(i+1),2))).Caption :='';
                TPanel(FindComponent( 'PanelYield'+ Format('%x',[j+1]) + AddZero(IntToStr(i+1),2))).Caption :='';
          end;

          if sShift ='D' then
          begin
               TPanel(FindComponent( 'PanelOutput5'+AddZero(IntToStr(i+1),2))).Font.Color :=clRed;
               TPanel(FindComponent( 'PanelYield5' + AddZero(IntToStr(i+1),2))).Font.Color :=clRed;
               TPanel(FindComponent( 'PanelOutput4'+AddZero(IntToStr(i+1),2))).Font.Color :=clBlue;
               TPanel(FindComponent( 'PanelYield4' + AddZero(IntToStr(i+1),2))).Font.Color :=clBlack;
          end else
          begin
               TPanel(FindComponent( 'PanelOutput5'+AddZero(IntToStr(i+1),2))).Font.Color :=clBlue;
               TPanel(FindComponent( 'PanelYield5' + AddZero(IntToStr(i+1),2))).Font.Color :=clBlack;
               TPanel(FindComponent( 'PanelOutput4' + AddZero(IntToStr(i+1),2))).Font.Color :=clRed;
               TPanel(FindComponent( 'PanelYield4' + AddZero(IntToStr(i+1),2))).Font.Color :=clRed;
          end;
          TPanel(FindComponent( 'PanelOutputA'+AddZero(IntToStr(i+1),2))).Font.Color :=clRed;
          TPanel(FindComponent( 'PanelYieldA' + AddZero(IntToStr(i+1),2))).Font.Color :=clRed;
          TPanel(FindComponent( 'PanelOutputC'+AddZero(IntToStr(i+1),2))).Font.Color :=clRed;
          TPanel(FindComponent( 'PanelYieldC' + AddZero(IntToStr(i+1),2))).Font.Color :=clRed;
     end;
end;

function TuMainForm.AddZero(s:string;HopeLength:Integer):String;
begin
   Result:=StringReplace(Format('%'+IntToStr(HopeLength)+'s',[s]),' ','0',[rfIgnoreCase,rfReplaceAll]);
end;

procedure TuMainForm.BtNextClick(Sender: TObject);
begin
    BtNext.Enabled :=false;
    Timer1.Enabled :=false;
    Timer2.Enabled :=false;
    if ALL_Pages >1 then G_Page := G_Page+1;
    if G_Page >   ALL_Pages   then    G_Page :=1;
    Timer1.OnTimer(Sender);
    BtNext.Enabled :=true;
    Timer1.Enabled :=true;
    Timer2.Enabled :=true;
end;

procedure TuMainForm.Timer2Timer(Sender: TObject);
begin
     //if  Timer1.Enabled  then
     //begin
        BTNEXT.Click;
     //end;
end;

procedure TuMainForm.SpeedButton1Click(Sender: TObject);
begin
    if SpeedButton1.Caption='暫停' then
    begin
         SpeedButton1.Caption:='繼續';
         SpeedButton1.Font.Color:=clRed;
         Timer1.Enabled:=False;
         Timer2.Enabled:=False;
    end else begin
          SpeedButton1.Caption:='暫停';
          SpeedButton1.Font.Color:=clBlack;
          if btnPrefix.Caption ='現在班別' then
             Timer1.Enabled:=False 
          else
             Timer1.Enabled:=true;
          Timer2.Enabled:=true;
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
    bCurrentShift :=true;
    //uMainForm.ScaleBy(60,76);
    G_PAGE :=1;
end;

procedure TuMainForm.PanelPDLine01DblClick(Sender: TObject);
var iPos:integer;
begin

   { if (Sender as TPANEL).Caption ='' then exit;
    ipos := pos('自動',(Sender as TPANEL).Caption);
    if ipos >0 then
     sCurrentPDLine := Copy((Sender as TPANEL).Caption,1,length((Sender as TPANEL).Caption)-6)
    else
      sCurrentPDLine := (Sender as TPANEL).Caption;
    Timer1.Enabled :=false;
    Timer2.Enabled :=false;
    SpeedButton1.Caption:='繼續';
    SpeedButton1.Font.Color:=clRed;
    LineDetail:= TLineDetail.Create(self);
    if LineDetail.ShowModal = mrok then
    begin
    end;
    Timer1.Enabled :=Enabled;
    }
    
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
    {if (Sender as TPANEL).Caption ='' then exit;
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
    SpeedButton1.Caption:='繼續';
    SpeedButton1.Font.Color:=clRed;
    ModelDetail:= TModelDetail.Create(self);
    if  ModelDetail.ShowModal = mrok then
    begin

    end;
    Timer1.Enabled :=Enabled;
    }
end;


procedure TuMainForm.btnPrefixClick(Sender: TObject);
begin
     G_Page :=1;
     if btnPrefix.Caption = '現在班別' then
     begin
         bCurrentShift :=True;
         btnPrefix.Font.Color :=clBlack;
         btnPrefix.Caption :='前一班別';
     end
     else if btnPrefix.Caption = '前一班別' then
     begin
         bCurrentShift:=false;
         btnPrefix.Font.Color :=clRed;
         btnPrefix.Caption :='現在班別';
     end;
     Timer1.OnTimer(Sender);
end;

procedure TuMainForm.btnFirstClick(Sender: TObject);
begin
    btnFirst.Enabled :=false;
    if ALL_Pages >1 then G_Page :=  G_Page-1;
    if G_Page <=0   then    G_Page :=ALL_Pages;
    Timer1.Enabled :=false;
    Timer2.Enabled :=false;
    Timer1.OnTimer(Sender);
    btnFirst.Enabled :=true;
    Timer1.Enabled :=true;
    Timer2.Enabled :=true;

end;

end.
