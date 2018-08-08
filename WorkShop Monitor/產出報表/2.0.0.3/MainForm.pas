unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, MConnect, ObjBrkr, DB, DBClient,
  SConnect,IniFiles,math,uMyClassHelpers, Grids,DateUtils;

type
  TuMainForm = class(TfmForm)
    lblTitle: TLabel;
    lblTime: TLabel;
    SimpleObjectBroker1: TSimpleObjectBroker;
    Timer1: TTimer;
    QryData: TClientDataSet;
    qryTemp: TClientDataSet;
    SocketConnection1: TSocketConnection;
    QryOutput: TClientDataSet;
    QryTotal: TClientDataSet;
    pnlMain: TPanel;
    pnlD: TPanel;
    pnl3: TPanel;
    pnl5: TPanel;
    pnl7: TPanel;
    pnl9: TPanel;
    pnlG: TPanel;
    pnlWO: TPanel;
    pnl39: TPanel;
    pnlDWO01: TPanel;
    pnlDWO02: TPanel;
    pnlDWO03: TPanel;
    pnlDWO04: TPanel;
    pnl74: TPanel;
    pnlDWO05: TPanel;
    pnlDWO06: TPanel;
    pnlDWO07: TPanel;
    pnlDWO08: TPanel;
    pnl79: TPanel;
    pnlGWO01: TPanel;
    pnlGWO02: TPanel;
    pnlGWO03: TPanel;
    pnlGWO04: TPanel;
    pnl84: TPanel;
    pnlGWO05: TPanel;
    pnlGWO06: TPanel;
    pnlGWO07: TPanel;
    pnlGWO08: TPanel;
    pnlMaterial: TPanel;
    pnl29: TPanel;
    pnlDM01: TPanel;
    pnlDM02: TPanel;
    pnlDM03: TPanel;
    pnlDM04: TPanel;
    pnl34: TPanel;
    pnlDM05: TPanel;
    pnlDM06: TPanel;
    pnlDM07: TPanel;
    pnlDM08: TPanel;
    pnl42: TPanel;
    pnlGM01: TPanel;
    pnlGM02: TPanel;
    pnlGM03: TPanel;
    pnlGM04: TPanel;
    pnl47: TPanel;
    pnlGM05: TPanel;
    pnlGM06: TPanel;
    pnlGM07: TPanel;
    pnlGM08: TPanel;
    pnlInput: TPanel;
    pnlInput1: TPanel;
    pnlDInput01: TPanel;
    pnlDInput02: TPanel;
    pnlDInput03: TPanel;
    pnlDInput04: TPanel;
    pnl60: TPanel;
    pnlDInput05: TPanel;
    pnlDInput06: TPanel;
    pnlDInput07: TPanel;
    pnlDInput08: TPanel;
    pnl89: TPanel;
    pnlGInput05: TPanel;
    pnlGInput06: TPanel;
    pnlGInput07: TPanel;
    pnlGInput08: TPanel;
    pnlSeg1: TPanel;
    pnl6: TPanel;
    pnlDSeg101: TPanel;
    pnlDSeg102: TPanel;
    pnlDSeg103: TPanel;
    pnlDSeg104: TPanel;
    pnl13: TPanel;
    pnlDSeg105: TPanel;
    pnlDSeg106: TPanel;
    pnlDSeg107: TPanel;
    pnlDSeg108: TPanel;
    pnl18: TPanel;
    pnlGSeg101: TPanel;
    pnlGSeg102: TPanel;
    pnlGSeg103: TPanel;
    pnlGSeg104: TPanel;
    pnl23: TPanel;
    pnlGSeg105: TPanel;
    pnlGSeg106: TPanel;
    pnlGSeg107: TPanel;
    pnlGSeg108: TPanel;
    pnlTSeg1: TPanel;
    pnl99: TPanel;
    pnl100: TPanel;
    pnlSeg2: TPanel;
    pnl102: TPanel;
    pnlDSeg201: TPanel;
    pnlDSeg202: TPanel;
    pnlDSeg203: TPanel;
    pnlDSeg204: TPanel;
    pnl107: TPanel;
    pnlDSeg205: TPanel;
    pnlDSeg206: TPanel;
    pnlDSeg207: TPanel;
    pnlDSeg208: TPanel;
    pnl112: TPanel;
    pnlGSeg201: TPanel;
    pnlGSeg202: TPanel;
    pnlGSeg203: TPanel;
    pnlGSeg204: TPanel;
    pnl117: TPanel;
    pnlGSeg205: TPanel;
    pnlGSeg206: TPanel;
    pnlGSeg207: TPanel;
    pnlGSeg208: TPanel;
    pnlSeg3: TPanel;
    pnl123: TPanel;
    pnlDSeg301: TPanel;
    pnlDSeg302: TPanel;
    pnlDSeg303: TPanel;
    pnlDSeg304: TPanel;
    pnl128: TPanel;
    pnlDSeg305: TPanel;
    pnlDSeg306: TPanel;
    pnlDSeg307: TPanel;
    pnlDSeg308: TPanel;
    pnl133: TPanel;
    pnlGSeg301: TPanel;
    pnlGSeg302: TPanel;
    pnlGSeg303: TPanel;
    pnlGSeg304: TPanel;
    pnl138: TPanel;
    pnlGSeg305: TPanel;
    pnlGSeg306: TPanel;
    pnlGSeg307: TPanel;
    pnlGSeg308: TPanel;
    pnlSeg4: TPanel;
    pnlSeg41: TPanel;
    pnlDSeg401: TPanel;
    pnlDSeg402: TPanel;
    pnlDSeg403: TPanel;
    pnlDSeg404: TPanel;
    pnl149: TPanel;
    pnlDSeg405: TPanel;
    pnlDSeg406: TPanel;
    pnlDSeg407: TPanel;
    pnlDSeg408: TPanel;
    pnl154: TPanel;
    pnlGSeg401: TPanel;
    pnlGSeg402: TPanel;
    pnlGSeg403: TPanel;
    pnlGSeg404: TPanel;
    pnl159: TPanel;
    pnlGSeg405: TPanel;
    pnlGSeg406: TPanel;
    pnlGSeg407: TPanel;
    pnlGSeg408: TPanel;
    pnlSeg5: TPanel;
    pnl165: TPanel;
    pnlDSeg501: TPanel;
    pnlDSeg502: TPanel;
    pnlDSeg503: TPanel;
    pnlDSeg504: TPanel;
    pnl170: TPanel;
    pnlDSeg505: TPanel;
    pnlDSeg506: TPanel;
    pnlDSeg507: TPanel;
    pnlDSeg508: TPanel;
    pnl175: TPanel;
    pnlGSeg501: TPanel;
    pnlGSeg502: TPanel;
    pnlGSeg503: TPanel;
    pnlGSeg504: TPanel;
    pnl180: TPanel;
    pnlGSeg505: TPanel;
    pnlGSeg506: TPanel;
    pnlGSeg507: TPanel;
    pnlGSeg508: TPanel;
    pnlPack: TPanel;
    pnlPack1: TPanel;
    pnlPackD01: TPanel;
    pnlPackD02: TPanel;
    pnlPackD03: TPanel;
    pnlPackD04: TPanel;
    pnl191: TPanel;
    pnlPackD05: TPanel;
    pnlPackD06: TPanel;
    pnlPackD07: TPanel;
    pnlPackD08: TPanel;
    pnl196: TPanel;
    pnlPackG01: TPanel;
    pnlPackG02: TPanel;
    pnlPackG03: TPanel;
    pnlPackG04: TPanel;
    pnl201: TPanel;
    pnlPackG05: TPanel;
    pnlPackG06: TPanel;
    pnlPackG07: TPanel;
    pnlPackG08: TPanel;
    pnlFPY: TPanel;
    pnl207: TPanel;
    pnlFPYD01: TPanel;
    pnlFPYD02: TPanel;
    pnlFPYD03: TPanel;
    pnlFPYD04: TPanel;
    pnl212: TPanel;
    pnlFPYD05: TPanel;
    pnlFPYD06: TPanel;
    pnlFPYD07: TPanel;
    pnlFPYD08: TPanel;
    pnl217: TPanel;
    pnlFPYG01: TPanel;
    pnlFPYG02: TPanel;
    pnlFPYG03: TPanel;
    pnlFPYG04: TPanel;
    pnl222: TPanel;
    pnlFPYG05: TPanel;
    pnlFPYG06: TPanel;
    pnlFPYG07: TPanel;
    pnlFPYG08: TPanel;
    pnl65: TPanel;
    pnlGInput01: TPanel;
    pnlGInput02: TPanel;
    pnlGInput03: TPanel;
    pnlGInput04: TPanel;
    pnlT2: TPanel;
    pnlT1: TPanel;
    pnl1: TPanel;
    pnl15: TPanel;
    pnl16: TPanel;
    pnl17: TPanel;
    pnlTSeg2: TPanel;
    pnlT4: TPanel;
    pnlT3: TPanel;
    pnl14: TPanel;
    pnlTSeg3: TPanel;
    pnlT6: TPanel;
    pnlT5: TPanel;
    pnl22: TPanel;
    pnlTSeg4: TPanel;
    pnlT8: TPanel;
    pnlT7: TPanel;
    pnl27: TPanel;
    pnlTSeg5: TPanel;
    pnlT10: TPanel;
    pnlT9: TPanel;
    pnl32: TPanel;
    pnlOutput: TPanel;
    pnl8: TPanel;
    pnlOutputD01: TPanel;
    pnlOutputD02: TPanel;
    pnlOutputD03: TPanel;
    pnlOutputD04: TPanel;
    pnl25: TPanel;
    pnlOutputD05: TPanel;
    pnlOutputD06: TPanel;
    pnlOutputD07: TPanel;
    pnlOutputD08: TPanel;
    pnl35: TPanel;
    pnlOutputG01: TPanel;
    pnlOutputG02: TPanel;
    pnlOutputG03: TPanel;
    pnlOutputG04: TPanel;
    pnl41: TPanel;
    pnlOutputG05: TPanel;
    pnlOutputG06: TPanel;
    pnlOutputG07: TPanel;
    pnlOutputG08: TPanel;
    pnlWIP: TPanel;
    pnl49: TPanel;
    pnlWIPD01: TPanel;
    pnlWIPD02: TPanel;
    pnlWIPD03: TPanel;
    pnlWIPD04: TPanel;
    pnl55: TPanel;
    pnlWIPD05: TPanel;
    pnlWIPD06: TPanel;
    pnlWIPD07: TPanel;
    pnlWIPD08: TPanel;
    pnl61: TPanel;
    pnlWIPG01: TPanel;
    pnlWIPG02: TPanel;
    pnlWIPG03: TPanel;
    pnlWIPG04: TPanel;
    pnl67: TPanel;
    pnlWIPG05: TPanel;
    pnlWIPG06: TPanel;
    pnlWIPG07: TPanel;
    pnlWIPG08: TPanel;
    pnlDefect: TPanel;
    pnl73: TPanel;
    pnlDefectD01: TPanel;
    pnlDefectD02: TPanel;
    pnlDefectD03: TPanel;
    pnlDefectD04: TPanel;
    pnl80: TPanel;
    pnlDefectD05: TPanel;
    pnlDefectD06: TPanel;
    pnlDefectD07: TPanel;
    pnlDefectD08: TPanel;
    pnl86: TPanel;
    pnlDefectG01: TPanel;
    pnlDefectG02: TPanel;
    pnlDefectG03: TPanel;
    pnlDefectG04: TPanel;
    pnl92: TPanel;
    pnlDefectG05: TPanel;
    pnlDefectG06: TPanel;
    pnlDefectG07: TPanel;
    pnlDefectG08: TPanel;
    pnl2: TPanel;
    pnl4: TPanel;
    pnl10: TPanel;
    pnl11: TPanel;
    btn1: TButton;
    qry1: TClientDataSet;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DayofMonth:Integer;
    StartTime,EndTime,sWOStr:string;
    IsDongle,ISDG:Boolean;
    function  LoadApServer: Boolean;
    function  AddZero(s:string;HopeLength:Integer):String;
    procedure ClearAllPanel;
    function  GetSysDate:TDateTime;
    function  ZsGetDay(mYear, mMonth: Integer): Integer;
    procedure QueryProcessOutput(WO,Process,Start_Time,End_Time:string);
    procedure DisplayInfo;
    procedure QueryPMCQTY(pdline_id,Start_Time,End_Time:string);
    procedure QueryWO(Model,Start_Time,End_Time:string);
    procedure QueryWIP(WO :string);
    procedure QueryProcessOutputAll(WO,Process:string);
    procedure QueryDefectWIP(WO :string);
    procedure QueryPackOut(WO:string);
    procedure SetDColor(iRows,iColor:integer);
    procedure SetGColor(iRows,iColor:integer);
    procedure QueryFPY(WO,Start_Time,End_Time:string);
    procedure QueryMaterial(Part_NO:string);
    procedure SetGBkColor(iRows,iColor:Integer);
    procedure QueryShiftProcessOutput(Model,Process,Start_Time,End_Time:string);
    procedure QueryUnPGI(PartNO:string);
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
var i:Integer;
begin
    LoadApServer;
    Timer1Timer(Self);
end;

procedure TuMainForm.Timer1Timer(Sender: TObject);
begin
    Timer1.Enabled :=false;
    lblTime.Caption := 'UpdateTime:  '+FormatDateTime('yyyy/mm/dd hh:mm:ss',GetSysDate);
    ClearAllPanel;
    DisplayInfo;
    Timer1.Enabled :=true;
end;

{
procedure TuMainForm.QueryWO(Model,Start_Time,End_Time:string);
begin
     qryTemp.Close;
     qryTemp.Params.Clear;
     qryTemp.Params.CreateParam(ftString,'Model',ptInput);
     qryTemp.Params.CreateParam(ftString,'Start_Time',ptInput);
     qryTemp.Params.CreateParam(ftString,'End_Time',ptInput);
     qryTemp.CommandText := ' select a.work_Order ,e.Target_Qty,e.Input_qty   '+
                            ' from sajet.g_sn_Count a,sajet.sys_part b,sajet.sys_model c,sajet.g_wo_base e  '+
                            ' where a.model_id =b.part_id and b.Model_id = c.Model_id  and a.work_order=e.work_order  '+
                            '  and c.Model_name =:Model and  a.work_order like ''%MA%'' and'+
                            ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) >=:Start_time and '+
                            ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00'')))<:end_time '+
                            ' Group by a.work_Order ,e.Target_Qty,e.Input_qty  ' ;

     qryTemp.Params.ParambyName('Model').AsString := Model;
     qryTemp.Params.ParambyName('Start_Time').AsString := Start_Time;
     qryTemp.Params.ParambyName('End_Time').AsString := End_Time;
     QryTemp.Open;

end;}
procedure TuMainForm.SetDColor(iRows,iColor:integer);
begin
     TPanel(FindComponent('pnlDWO0'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlDM0'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlDInput0'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlDSeg10'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlDSeg20'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlDSeg30'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlDSeg40'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlDSeg50'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlOutputD0'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlFPYD0'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlWIPD0'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlDefectD0'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlPackD0'+IntToStr(iRows))).Font.Color :=iColor;
end;
procedure TuMainForm.SetGColor(iRows,iColor:integer);
begin
     TPanel(FindComponent('pnlGWO0'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlGM0'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlGInput0'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlGSeg10'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlGSeg20'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlGSeg30'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlGSeg40'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlGSeg50'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlOutputG0'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlFPYG0'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlWIPG0'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlDefectG0'+IntToStr(iRows))).Font.Color :=iColor;
     TPanel(FindComponent('pnlPackG0'+IntToStr(iRows))).Font.Color :=iColor;


end;


procedure TuMainForm.QueryWO(Model,Start_Time,End_Time:string);
begin
     qryTemp.Close;
     qryTemp.Params.Clear;
     qryTemp.Params.CreateParam(ftString,'Model',ptInput);
     qryTemp.CommandText := ' select a.work_Order ,B.PART_NO,a.Target_Qty,a.Input_qty   '+
                            ' from sajet.sys_part b,sajet.sys_model c,sajet.g_wo_base a  '+
                            ' where a.model_id =b.part_id and b.Model_id = c.Model_id    '+
                            ' and c.Model_name =:Model and  a.work_order like ''%MA%'' and'+
                            ' a.wo_status in( 2,3) and  a.work_order not like ''%TEST%'''+
                            ' and a.Input_qty <>0 and a.REMARK is NULL'+
                            ' Group by a.work_Order ,B.PART_NO,a.Target_Qty,a.Input_qty  ORDER BY a.WORK_ORDER ' ;

     qryTemp.Params.ParambyName('Model').AsString := Model;
     QryTemp.Open;

end;


procedure TuMainForm.QueryWIP(WO :string);
begin
     QryData.Close;
     QryData.Params.Clear;
     QryData.Params.CreateParam(ftString,'wo',ptInput);
     QryData.CommandText := ' SELECT COUNT(*) QTY FROM (  '+
                            ' SELECT * FROM SAJET.G_SN_STATUS WHERE WORK_ORDER=:WO AND NEXT_PROCESS <>0 and NEXT_PROCESS NOT IN( 100198,100203,100201,100217 ) '+
                            ' UNION  '+
                            ' SELECT * FROM SAJET.G_SN_STATUS WHERE WORK_ORDER=:WO AND   NEXT_PROCESS =0 AND WIP_PROCESS <> 0   '+
                            ' AND WIP_PROCESS NOT IN(100198,100203,100201,100217 ))' ;
     QryData.Params.ParambyName('wo').AsString := WO;
     QryData.Open;
end;

procedure TuMainForm.QueryMaterial(Part_NO:string);
begin
     QryData.Close;
     QryData.Params.Clear;
     //QryData.Params.CreateParam(ftString,'PART',ptInput);
     QryData.CommandText := ' SELECT NVL(SUM(A.Material_QTY),0) Material_QTY FROM SAJET.G_MATERIAL A,SAJET.SYS_PART B '+
                            ' WHERE A.PART_ID =B.PART_ID AND B.PART_NO in( '+ Part_NO +')' ;
    // QryData.Params.ParambyName('PART').AsString := PART_NO;
     QryData.Open;
end;


procedure TuMainForm.QueryDefectWIP(WO :string);
begin
     QryData.Close;
     QryData.Params.Clear;
     QryData.Params.CreateParam(ftString,'wo',ptInput);
     QryData.CommandText := ' SELECT COUNT(*) QTY FROM SAJET.G_SN_STATUS WHERE WORK_ORDER=:WO AND (NEXT_PROCESS =100201 OR WIP_PROCESS =100201) ';
     QryData.Params.ParambyName('wo').AsString := WO;
     QryData.Open;
end;

{
procedure TuMainForm.QueryMaterial(WO :string);
begin
     QryData.Close;
     QryData.Params.Clear;
     QryData.Params.CreateParam(ftString,'wo',ptInput);
     QryData.CommandText := ' select nvl( target_qty * (select min(Issue_qty/request_qty) from SAJET.G_WO_PICK_LIST '+
                            ' where  work_order=:wo and request_qty <> 0),0) qty from sajet.g_wo_base  where work_order=:wo  ' ;
     QryData.Params.ParambyName('wo').AsString := WO;
     QryData.Open;

end;  }

procedure TuMainForm.QueryProcessOutput(WO,Process,Start_Time,End_Time:string);
begin
     QryData.Close;
     QryData.Params.Clear;
     QryData.Params.CreateParam(ftString,'WO',ptInput);
     QryData.Params.CreateParam(ftString,'Process',ptInput);
     QryData.Params.CreateParam(ftString,'Start_Time',ptInput);
     QryData.Params.CreateParam(ftString,'End_Time',ptInput);
     QryData.CommandText := ' select Nvl(Sum(Output_qty),0) Output_qty '+
                            ' from sajet.g_sn_Count a,sajet.sys_process b  '+
                            ' where a.work_order =:wo and a.process_id = b.Process_id and b.Process_name =:process and'+
                            ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) >=:Start_time and '+
                            ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00'')))<:end_time ' ;
     QryData.Params.ParambyName('wo').AsString := WO;
     QryData.Params.ParambyName('Process').AsString := Process;
     QryData.Params.ParambyName('Start_Time').AsString := Start_Time;
     QryData.Params.ParambyName('End_Time').AsString := End_Time;
     QryData.Open;

end;

procedure TuMainForm.QueryShiftProcessOutput(Model,Process,Start_Time,End_Time:string);
begin
     QryData.Close;
     QryData.Params.Clear;
     QryData.Params.CreateParam(ftString,'Model',ptInput);
     QryData.Params.CreateParam(ftString,'Process',ptInput);
     QryData.Params.CreateParam(ftString,'Start_Time',ptInput);
     QryData.Params.CreateParam(ftString,'End_Time',ptInput);
     QryData.CommandText := ' select Nvl(Sum(Output_qty),0) Output_qty '+
                            ' from sajet.g_sn_Count a,sajet.sys_process b,sajet.sys_part c,sajet.sys_model d  '+
                            ' where a.process_id = b.Process_id and b.Process_name =:process and'+
                            ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) >=:Start_time and '+
                            ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00'')))<:end_time ' +
                            ' and a.Model_ID =C.PART_ID and C.MODEL_ID =D.MODEL_ID and D.Model_Name =:Model ';
     QryData.Params.ParambyName('Model').AsString := Model;
     QryData.Params.ParambyName('Process').AsString := Process;
     QryData.Params.ParambyName('Start_Time').AsString := Start_Time;
     QryData.Params.ParambyName('End_Time').AsString := End_Time;
     QryData.Open;

end;

procedure TuMainForm.QueryUnPGI(PartNO:string);
begin
     Qry1.Close;
     Qry1.Params.Clear;
     Qry1.CommandText := ' select Count(*) Output_qty '+
                            ' from sajet.g_sn_status a ,sajet.sys_part b  '+
                            ' where a.work_order in ( '+sWOStr+') and a.model_id = b.part_id and '+
                            ' b.part_no in ('+PartNO+') and '+
                            '  (a.box_no <>''N/A'' or a.Pallet_no <>''N/A'' ) and  a.WIP_PROCESS <> 0 ';
     Qry1.Open;

end;



procedure TuMainForm.QueryPackOut(WO:string);
begin
     QryData.Close;
     QryData.Params.Clear;
     QryData.Params.CreateParam(ftString,'WO',ptInput);
     QryData.CommandText := ' select Count(*) Output_qty '+
                            ' from sajet.g_sn_status a where a.work_order =:wo and '+
                            '  (a.box_no <>''N/A'' or a.Pallet_no <>''N/A'') ';;
     QryData.Params.ParambyName('wo').AsString := WO;
     QryData.Open;

end;


procedure TuMainForm.QueryProcessOutputAll(WO,Process:string);
begin
     QryData.Close;
     QryData.Params.Clear;
     QryData.Params.CreateParam(ftString,'WO',ptInput);
     QryData.Params.CreateParam(ftString,'Process',ptInput);
     QryData.CommandText := ' select Nvl(Sum(Output_qty),0) Output_qty '+
                            ' from sajet.g_sn_Count a,sajet.sys_process b  '+
                            ' where a.work_order =:wo and a.process_id = b.Process_id and b.Process_name =:process ';;
     QryData.Params.ParambyName('wo').AsString := WO;
     QryData.Params.ParambyName('Process').AsString := Process;
     QryData.Open;

end;

procedure TuMainForm.QueryFPY(WO,Start_Time,End_Time:string);
begin
    QryData.Close;
    QryData.Params.Clear;
    QryData.Params.CreateParam(ftString,'Start_Time',ptInput);
    QryData.Params.CreateParam(ftString,'End_Time',ptInput);
    QryData.Params.CreateParam(ftString,'WO',ptInput);
    QryData.CommandText := ' SELECT ROUND(exp(sum(ln(decode(FPY,0,0.000001,FPY))))*100,2)  FPY_YIELD FROM '+
                           ' ( SELECT process_ID,Sum(Pass_QTY+FAIL_QTY) TOTAL_QTY,SUM(PASS_QTY) FPY_QTY,  '+
                           '  DECODE(Sum(Pass_QTY+FAIL_QTY),0,1,SUM(PASS_QTY)/Sum(Pass_QTY+FAIL_QTY)) FPY '+
                           ' FROM SAJET.G_SN_COUNT WHERE WORK_ORDER=:WO AND ' +
                           ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) >=:Start_time and '+
                           ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00'')))<:end_time   '+
                           ' group by process_ID )';

     QryData.Params.ParambyName('Start_Time').AsString := Start_Time;
     QryData.Params.ParambyName('End_Time').AsString := End_Time;
     QryData.Params.ParambyName('WO').AsString := WO;
     QryData.Open;
end;


procedure TuMainForm.QueryPMCQTY(Pdline_id,Start_Time,End_Time:string);
begin
     qryTemp.Close;
     qryTemp.Params.Clear;
     qryTemp.Params.CreateParam(ftString,'Start_Time',ptInput);
     qryTemp.Params.CreateParam(ftString,'End_Time',ptInput);
     qryTemp.Params.CreateParam(ftString,'pdline',ptInput);
     qryTemp.CommandText := ' select NVL(SUM(PRODUCE_QTY),0) PMC_QTY from sajet.g_pdline_manage '+
                            ' where pd_status =1 and pdline_id =:pdline  and enabled =''Y'' '+
                            ' and Work_date>=:Start_Time and Work_date<:end_Time ' ;
     qryTemp.Params.ParambyName('Start_Time').AsString := Start_Time;
     qryTemp.Params.ParambyName('End_Time').AsString := End_Time;
     qryTemp.Params.ParambyName('pdline').AsString := Pdline_id;
     QryTemp.Open;

end;


procedure TuMainForm.DisplayInfo;
var CurrDate:TDateTime;
    i,j,CurrDay,iHour,iQty1,iQty2,iQty3,iQty4,iQty5,iQty6,iQty7,iQty8,iQty9,iQty10,iQty11:Integer;
    sWO,sInput,sTarget,sPartNo:string;
    StartList,EndList:TStringList;
begin
    CurrDate := GetSysDate;
    //CurrDate := StrToDateTime('2015/07/23 19:30:00');
    
    CurrDay :=StrToInt(FormatDateTime('dd',CurrDate));
    iHour := StrToInt(FormatDateTime('hh',CurrDate));
    StartList :=TStringList.Create;
    EndList :=TStringList.Create;
     if (iHour >=8) and  (iHour <20) then
     begin
        pnlT1.Caption :='08:00';
        pnlT2.Caption :='10:00';
        pnlT3.Caption :='10:00';
        pnlT4.Caption :='12:00';
        pnlT5.Caption :='12:00';
        pnlT6.Caption :='15:00';
        pnlT7.Caption :='15:00';
        pnlT8.Caption :='17:00';
        pnlT9.Caption :='17:00';
        pnlT10.Caption :='20:00';
     end else begin
        pnlT1.Caption :='20:00';
        pnlT2.Caption :='22:00';
        pnlT3.Caption :='22:00';
        pnlT4.Caption :='01:00';
        pnlT5.Caption :='01:00';
        pnlT6.Caption :='03:00';
        pnlT7.Caption :='03:00';
        pnlT8.Caption :='05:00';
        pnlT9.Caption :='05:00';
        pnlT10.Caption :='08:00';
     end;
     if ISDG then begin
         pnlD.Caption :='鼓';
         pnlG.Caption :='吉他';
         pnlDM07.Caption :='黑色未入庫數';
         pnlDSeg207.Caption :='白色未入庫數';
         pnlDSeg507.Caption :='紅色未入庫數';

         pnlGM07.Caption :='黑色未入庫數';
         pnlGSeg207.Caption :='白色未入庫數';
         pnlGSeg507.Caption :='紅色未入庫數';

         SetDColor(7,$00005B0A);
         SetGColor(7,$00005B0A);

         pnlDM08.Caption :='黑色入庫數';
         pnlDSeg208.Caption :='白色入庫數';
         pnlDSeg508.Caption :='紅色入庫數';

         pnlGM08.Caption :='黑色入庫數';
         pnlGSeg208.Caption :='白色入庫數';
         pnlGSeg508.Caption :='紅色入庫數';

         QueryMaterial('''769A-0501-0280'',''769A-0501-0580'',''769A-0501-0880''');
         pnlDInput08.Caption := QryData.fieldbyname('Material_qty').AsString;
         QueryMaterial('''769A-0501-0180'',''769A-0501-0480'',''769A-0501-0780''');
         pnlDSeg308.Caption := QryData.fieldbyname('Material_qty').AsString;
         QueryMaterial('''769A-0501-0080'',''769A-0501-0380'',''769A-0501-0680''');
         pnloutputD08.Caption := QryData.fieldbyname('Material_qty').AsString;
         QueryMaterial('''769A-0500-0280'',''769A-0500-0580'',''769A-0500-0880''');
         pnlGInput08.Caption := QryData.fieldbyname('Material_qty').AsString;
         QueryMaterial('''769A-0500-0180'',''769A-0500-0480'',''769A-0500-0780''');
         pnlGSeg308.Caption := QryData.fieldbyname('Material_qty').AsString;
         QueryMaterial('''769A-0500-0080'',''769A-0500-0380'',''769A-0500-0680''');;
         pnlOutputG08.Caption := QryData.fieldbyname('Material_qty').AsString;
         SetDColor(8,$00005B0A);
         SetGColor(8,$00005B0A);
     end;
     if IsDongle then begin
         pnlD.Caption :='Dongle';
         pnlDM07.Caption :='未入庫數';
         QueryMaterial('''7699-0513-0080''');
         pnlDInput08.Caption := QryData.fieldbyname('Material_qty').AsString;
         pnlDM08.Caption :='入庫數';

     end;

     pnlWIPD08.Caption :='前班產出';
     if isDG then pnlWIPG08.Caption :='前班產出';
     if (iHour >=8) and  (iHour <20)  then
     begin
        StartTime :=   FormatDateTime('yyyymmdd',CurrDate-1)+'20';
        EndTime :=    FormatDateTime('yyyymmdd',CurrDate)+'08';
     end
     else  if  iHour <8 then
     begin
        StartTime :=   FormatDateTime('yyyymmdd',CurrDate-1)+'08';
        EndTime :=    FormatDateTime('yyyymmdd',CurrDate-1)+'20';
     end else begin
         StartTime :=   FormatDateTime('yyyymmdd',CurrDate)+'08';
         EndTime :=    FormatDateTime('yyyymmdd',CurrDate)+'20';
     end;

     if ISDG then begin
         QueryShiftProcessOutput('501','CM-PACK-BOX',StartTime,EndTime );
         pnlDefectD08.Caption := QryData.fieldbyName('OutPut_Qty').AsString;

         QueryShiftProcessOutput('500','CM-PACK-BOX',StartTime,EndTime );
         pnlDefectG08.Caption := QryData.fieldbyName('OutPut_Qty').AsString;
     end;


      if IsDongle then begin
         QueryShiftProcessOutput('513','CM-PACK-BOX',StartTime,EndTime );
         pnlDefectD08.Caption := QryData.fieldbyName('OutPut_Qty').AsString;
     end;

    if (iHour >=8) and  (iHour <20)  then
    begin
        StartTime :=   FormatDateTime('yyyymmdd',CurrDate)+'08';
        EndTime :=    FormatDateTime('yyyymmdd',CurrDate)+'20';
        StartList.Add( FormatDateTime('yyyymmdd',CurrDate)+'08') ;
        EndList.Add( FormatDateTime('yyyymmdd',CurrDate)+'10') ;
        if iHour>=10 then begin
           StartList.Add( FormatDateTime('yyyymmdd',CurrDate)+'10') ;
           EndList.Add( FormatDateTime('yyyymmdd',CurrDate)+'12') ;
        end;
        if iHour>=12 then begin
           StartList.Add( FormatDateTime('yyyymmdd',CurrDate)+'12') ;
           EndList.Add( FormatDateTime('yyyymmdd',CurrDate)+'15') ;
        end;
        if iHour>=15 then begin
           StartList.Add( FormatDateTime('yyyymmdd',CurrDate)+'15') ;
           EndList.Add( FormatDateTime('yyyymmdd',CurrDate)+'17') ;
        end;
        if iHour>=17 then begin
           StartList.Add( FormatDateTime('yyyymmdd',CurrDate)+'17') ;
           EndList.Add( FormatDateTime('yyyymmdd',CurrDate)+'20') ;
        end;
       
    end else if  iHour <8 then
       begin
          StartTime :=   FormatDateTime('yyyymmdd',CurrDate-1)+'20';
          EndTime :=    FormatDateTime('yyyymmdd',CurrDate)+'08';
          StartList.Add( FormatDateTime('yyyymmdd',CurrDate-1)+'20') ;
          StartList.Add( FormatDateTime('yyyymmdd',CurrDate-1)+'22') ;
          EndList.Add( FormatDateTime('yyyymmdd',CurrDate-1)+'22') ;
          EndList.Add( FormatDateTime('yyyymmdd',CurrDate)+'01') ;
          if iHour>=1 then begin
             StartList.Add( FormatDateTime('yyyymmdd',CurrDate)+'01') ;
             EndList.Add( FormatDateTime('yyyymmdd',CurrDate)+'03') ;
          end;
          if iHour>=3 then begin
             StartList.Add( FormatDateTime('yyyymmdd',CurrDate)+'03') ;
             EndList.Add( FormatDateTime('yyyymmdd',CurrDate)+'05') ;
          end;
          if iHour>=5 then begin
             StartList.Add( FormatDateTime('yyyymmdd',CurrDate)+'05') ;
             EndList.Add( FormatDateTime('yyyymmdd',CurrDate)+'08') ;
          end;
       end
    else
    begin
        StartTime :=   FormatDateTime('yyyymmdd',CurrDate)+'20';
        EndTime :=    FormatDateTime('yyyymmdd',CurrDate+1)+'08';
        StartList.Add( FormatDateTime('yyyymmdd',CurrDate)+'20') ;
        EndList.Add( FormatDateTime('yyyymmdd',CurrDate)+'22') ;
        if iHour>=22  then
        begin
            StartList.Add( FormatDateTime('yyyymmdd',CurrDate)+'22') ;
            EndList.Add( FormatDateTime('yyyymmdd',CurrDate+1)+'01') ;
        end;
    end;


    if isdg then begin
          sWOStr :='';
          QueryWo('501', StartTime, EndTime );
          if not qryTemp.IsEmpty then
          begin
             qryTemp.First;
             for i:=0 to qryTemp.RecordCount -1 do
             begin
                if i>=5 then Continue;
          
                sWO :=  qryTemp.fieldbyname('WORK_ORDER').AsString;
                sPartNo :=  qryTemp.fieldbyname('PART_NO').AsString;
                if Copy(sPartNo ,1,4) ='769A' then
                   sWOStr := sWOStr +''''+sWO + ''',';
                TPanel(FindComponent('pnlDWO'+Addzero(IntToStr(i+1),2))).Caption := sWO;

                if Copy(sWO ,1,3) ='VMA' then
                begin
                   SetDColor(i+1,clRed);
                end;

                if (Copy(sWO ,1,3) ='NMA') or (Copy(sWO ,1,3) ='RMA' )then
                begin
                   SetDColor(i+1,clPurple);
                end;


                //INPUT,TARGET
                QueryProcessOutput(sWO,'CM-Input',StartTime ,EndTime);
                sInput := QryData.fieldbyname('Output_Qty').AsString;
                TPanel(FindComponent('pnlDInput'+Addzero(IntToStr(i+1),2))).Caption := sInput;
                sTarget := qryTemp.fieldbyname('Target_Qty').AsString;
                TPanel(FindComponent('pnlDM'+Addzero(IntToStr(i+1),2))).Caption := sTarget;

                //---FPY---
                QueryFPY(sWO,StartTime,EndTime);
                sInput := QryData.fieldbyname('FPY_YIELD').AsString;
                if sInput <>'' then
                    TPanel(FindComponent('pnlFPYD'+Addzero(IntToStr(i+1),2))).Caption := sInput+'%';

               //時間段產出
                for j:=0 to StartList.Count-1 do
                begin
                     QueryProcessOutput(sWO,'CM-PACK-BOX',StartList.Strings[j] ,EndList.Strings[j]);
                     TPanel(FindComponent('pnlDSeg'+InttoStr(j+1)+Addzero(IntToStr(i+1),2))).Caption
                             :=QryData.fieldbyname('Output_Qty').AsString;
                end;

                iQty1 :=0;
                for j:=0 to 4 do begin
                     iQty1 := StrTointDef(TPanel(FindComponent('pnlDSeg'+InttoStr(j+1)+Addzero(IntToStr(i+1),2))).Caption ,0)+ iQty1;
                end;
                TPanel(FindComponent('pnlOutputD'+Addzero(IntToStr(i+1),2))).Caption := IntToStr(iQty1) ;

                //PACKING
                QueryPackOut(sWO);
                TPanel(FindComponent('pnlPackD'+Addzero(IntToStr(i+1),2))).Caption
                             :=QryData.fieldbyname('Output_Qty').AsString;

                //WIP
                QueryWIP(sWO);
                TPanel(FindComponent('pnlWIPD'+Addzero(IntToStr(i+1),2))).Caption
                             :=QryData.fieldbyname('Qty').AsString;

                QueryDefectWIP(sWO);
                TPanel(FindComponent('pnlDefectD'+Addzero(IntToStr(i+1),2))).Caption
                             :=QryData.fieldbyname('Qty').AsString;
                qryTemp.Next;
             end;

          end;
          sWOStr := Copy(sWOStr,1,Length(sWOStr)-1);


          if sWOStr <>'' then begin
              QueryUnPGI('''769A-0501-0280'',''769A-0501-0580'',''769A-0501-0880''');
              pnlDInput07.Caption := qry1.fieldbyname('Output_qty').AsString;
              QueryUnPGI('''769A-0501-0180'',''769A-0501-0480'',''769A-0501-0780''');
              pnlDSeg307.Caption := qry1.fieldbyname('Output_qty').AsString;
              QueryUnPGI('''769A-0501-0080'',''769A-0501-0380'',''769A-0501-0680''');
              pnloutputD07.Caption := qry1.fieldbyname('Output_qty').AsString;
          end;

          sWOStr :='';
          QueryWo('500', StartTime, EndTime );
          if not qryTemp.IsEmpty then
          begin

             qryTemp.First;
             for i:=0 to qryTemp.RecordCount -1 do
             begin
                 if i>=5 then Continue;

                 sWO :=  qryTemp.fieldbyname('WORK_ORDER').AsString;
                 sPartNo :=  qryTemp.fieldbyname('PART_NO').AsString;
                 if Copy(sPartNo ,1,4) ='769A' then
                   sWOStr := sWOStr +''''+sWO + ''',';

                 TPanel(FindComponent('pnlGWO'+Addzero(IntToStr(i+1),2))).Caption := sWO;
                if Copy( sPartNo,1,4)='7686' then begin
                   SetGBkColor(i+1,clYellow);
                end;


                 if Copy(sWO ,1,3) ='VMA' then
                 begin
                     SetGColor(i+1,clRed);
                     SetGBkColor (i+1,clWhite);
                     QueryProcessOutput(sWO,'CM-Input',StartTime ,EndTime);
                     sInput := QryData.fieldbyname('Output_Qty').AsString;
                     TPanel(FindComponent('pnlGInput'+Addzero(IntToStr(i+1),2))).Caption := sInput;

                     sTarget := qryTemp.fieldbyname('Target_Qty').AsString;
                     TPanel(FindComponent('pnlGM'+Addzero(IntToStr(i+1),2))).Caption := sTarget;
                 end;

                 if (Copy(sWO ,1,3) ='NMA') or (Copy(sWO ,1,3) ='RMA' )then
                 begin
                       SetGColor(i+1,clPurple);
                       QueryProcessOutput(sWO,'CM-VI',StartTime ,EndTime);
                       sInput := QryData.fieldbyname('Output_Qty').AsString;
                       TPanel(FindComponent('pnlGInput'+Addzero(IntToStr(i+1),2))).Caption := sInput;

                       sTarget := qryTemp.fieldbyname('Target_Qty').AsString;
                       TPanel(FindComponent('pnlGM'+Addzero(IntToStr(i+1),2))).Caption := sTarget;
                 end;

                   //---FPY---
                 QueryFPY(sWO,StartTime,EndTime);
                 sInput := QryData.fieldbyname('FPY_YIELD').AsString;
                 if sInput <>'' then
                    TPanel(FindComponent('pnlFPYG'+Addzero(IntToStr(i+1),2))).Caption := sInput+'%';

                 for j:=0 to StartList.Count-1 do
                 begin
                     QueryProcessOutput(sWO,'CM-PACK-BOX',StartList.Strings[j] ,EndList.Strings[j]);
                     iQty1 :=QryData.fieldbyname('Output_Qty').AsInteger;
                     TPanel(FindComponent('pnlGSeg'+InttoStr(j+1)+Addzero(IntToStr(i+1),2))).Caption
                             := IntToStr(iQty1);

                 end;

                 iQty1 :=0;
                 for j:=0 to 4 do begin
                     iQty1 := StrTointDef(TPanel(FindComponent('pnlGSeg'+InttoStr(j+1)+Addzero(IntToStr(i+1),2))).Caption ,0)+ iQty1;
                 end;
                 TPanel(FindComponent('pnlOutputG'+Addzero(IntToStr(i+1),2))).Caption := IntToStr(iQty1) ;

                 QueryPackOut(sWO);
                 TPanel(FindComponent('pnlPackG'+Addzero(IntToStr(i+1),2))).Caption
                             :=QryData.fieldbyname('Output_Qty').AsString;

                 QueryWIP(sWO);
                 TPanel(FindComponent('pnlWIPG'+Addzero(IntToStr(i+1),2))).Caption
                             :=QryData.fieldbyname('Qty').AsString;

                 QueryDefectWIP(sWO);
                 TPanel(FindComponent('pnlDefectG'+Addzero(IntToStr(i+1),2))).Caption
                             :=QryData.fieldbyname('Qty').AsString;

                 qryTemp.Next;

             end;

          end;
          sWOStr := Copy(sWOStr,1,Length(sWOStr)-1);
          if sWOStr <>'' then begin
              QueryUnPGI('''769A-0500-0280'',''769A-0500-0580'',''769A-0500-0880''');
              pnlGInput07.Caption := Qry1.fieldbyname('Output_qty').AsString;
              QueryUnPGI('''769A-0500-0180'',''769A-0500-0480'',''769A-0500-0780''');
              pnlGSeg307.Caption := Qry1.fieldbyname('Output_qty').AsString;
              QueryUnPGI('''769A-0500-0080'',''769A-0500-0380'',''769A-0500-0680''');
              pnloutputG07.Caption := Qry1.fieldbyname('Output_qty').AsString;
          end;
          ISDG :=False;
          IsDongle :=True;
    end else
    begin
          QueryWo('513', StartTime, EndTime );
          if not qryTemp.IsEmpty then
          begin
             qryTemp.First;
             for i:=0 to qryTemp.RecordCount -1 do
             begin
                if i>=5 then Continue;
          
                sWO :=  qryTemp.fieldbyname('WORK_ORDER').AsString;
                sPartNo :=  qryTemp.fieldbyname('PART_NO').AsString;
                if Copy(sPartNo ,1,4) ='7699' then
                   sWOStr := sWOStr +''''+sWO + ''',';
                TPanel(FindComponent('pnlDWO'+Addzero(IntToStr(i+1),2))).Caption := sWO;

                if Copy(sWO ,1,3) ='VMA' then
                begin
                   SetDColor(i+1,clRed);
                end;

                if (Copy(sWO ,1,3) ='NMA') or (Copy(sWO ,1,3) ='RMA' )then
                begin
                   SetDColor(i+1,clPurple);
                end;


                //INPUT,TARGET
                QueryProcessOutput(sWO,'FUNTION-TEST',StartTime ,EndTime);
                sInput := QryData.fieldbyname('Output_Qty').AsString;
                TPanel(FindComponent('pnlDInput'+Addzero(IntToStr(i+1),2))).Caption := sInput;
                sTarget := qryTemp.fieldbyname('Target_Qty').AsString;
                TPanel(FindComponent('pnlDM'+Addzero(IntToStr(i+1),2))).Caption := sTarget;

                //---FPY---
                QueryFPY(sWO,StartTime,EndTime);
                sInput := QryData.fieldbyname('FPY_YIELD').AsString;
                if sInput <>'' then
                    TPanel(FindComponent('pnlFPYD'+Addzero(IntToStr(i+1),2))).Caption := sInput+'%';

               //時間段產出
                for j:=0 to StartList.Count-1 do
                begin
                     QueryProcessOutput(sWO,'CM-VI',StartList.Strings[j] ,EndList.Strings[j]);
                     TPanel(FindComponent('pnlDSeg'+InttoStr(j+1)+Addzero(IntToStr(i+1),2))).Caption
                             :=QryData.fieldbyname('Output_Qty').AsString;
                end;

                iQty1 :=0;
                for j:=0 to 4 do begin
                     iQty1 := StrTointDef(TPanel(FindComponent('pnlDSeg'+InttoStr(j+1)+Addzero(IntToStr(i+1),2))).Caption ,0)+ iQty1;
                end;
                TPanel(FindComponent('pnlOutputD'+Addzero(IntToStr(i+1),2))).Caption := IntToStr(iQty1) ;

                //PACKING
                QueryPackOut(sWO);
                TPanel(FindComponent('pnlPackD'+Addzero(IntToStr(i+1),2))).Caption
                             :=QryData.fieldbyname('Output_Qty').AsString;

                //WIP
                QueryWIP(sWO);
                TPanel(FindComponent('pnlWIPD'+Addzero(IntToStr(i+1),2))).Caption
                             :=QryData.fieldbyname('Qty').AsString;

                QueryDefectWIP(sWO);
                TPanel(FindComponent('pnlDefectD'+Addzero(IntToStr(i+1),2))).Caption
                             :=QryData.fieldbyname('Qty').AsString;
                qryTemp.Next;
             end;

          end;
          sWOStr := Copy(sWOStr,1,Length(sWOStr)-1);
          if sWOStr <> '' then begin
              QueryUnPGI('7699-0513-0080');
              pnlDInput07.Caption := Qry1.fieldbyname('Output_qty').AsString;
          end;
          isDG:=true;
          isdongle :=false;

    end;

end;

procedure TuMainForm.ClearAllPanel;
var i :Integer;
begin
  for i:=1 to 8 do
  begin
     pnlD.Caption :='';
     pnlG.Caption :='';
     TPanel(FindComponent('pnlDWO0'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlGWO0'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlDM0'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlGM0'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlDInput0'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlGInput0'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlDSeg10'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlGSeg10'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlDSeg20'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlGSeg20'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlDSeg30'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlGSeg30'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlDSeg40'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlGSeg40'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlDSeg50'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlGSeg50'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlOutputD0'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlOutputG0'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlWIPD0'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlWIPG0'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlDefectD0'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlDefectG0'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlPACKD0'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlPACKG0'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlFPYD0'+IntToStr(i))).Caption := '';
     TPanel(FindComponent('pnlFPYG0'+IntToStr(i))).Caption := '';

     SetGBkColor(i,clWhite);

  end;
end;

function TuMainForm.AddZero(s:string;HopeLength:Integer):String;
begin
   Result:=StringReplace(Format('%'+IntToStr(HopeLength)+'s',[s]),' ','0',[rfIgnoreCase,rfReplaceAll]);
end;

function TuMainForm.GetSysDate:TDateTime;
begin
    qryTemp.Close;
    qryTemp.CommandText := 'select SysDate from  dual';
    qryTemp.Open;
    result := qryTemp.fieldbyname('SYSDate').AsDateTime;
end;

procedure TuMainForm.FormCreate(Sender: TObject);
var i:Integer;
begin
    if   (SCREEN.WIDTH <1360) or  (SCREEN.Height<768) then begin
           MessageBox(0,'屏幕分辨率太低,請調高分辨率再開啟','提示',MB_ICONERROR);
           //Application.Terminate;
    end;
    width :=SCREEN.WIDTH;
    height :=SCREEN.Height;
    IsDongle :=False;
    ISDG :=True;
    uMainForm.ScaleBy(60,76);

end;
procedure TuMainForm.SetGBkColor(iRows,iColor:Integer);
begin
    TPanel(FindComponent('pnlGWO0'+IntToStr(iRows))).Color :=iColor;
    TPanel(FindComponent('pnlGM0'+IntToStr(iRows))).Color :=iColor;
    TPanel(FindComponent('pnlGInput0'+IntToStr(iRows))).Color :=iColor;
    TPanel(FindComponent('pnlGSeg10'+IntToStr(iRows))).Color :=iColor;
    TPanel(FindComponent('pnlGSeg20'+IntToStr(iRows))).Color :=iColor;
    TPanel(FindComponent('pnlGSeg30'+IntToStr(iRows))).Color :=iColor;
    TPanel(FindComponent('pnlGSeg40'+IntToStr(iRows))).Color :=iColor;
    TPanel(FindComponent('pnlGSeg50'+IntToStr(iRows))).Color :=iColor;
    TPanel(FindComponent('pnlOutputG0'+IntToStr(iRows))).Color :=iColor;
    TPanel(FindComponent('pnlFPYG0'+IntToStr(iRows))).Color :=iColor;
    TPanel(FindComponent('pnlWIPG0'+IntToStr(iRows))).Color :=iColor;
    TPanel(FindComponent('pnlDefectG0'+IntToStr(iRows))).Color :=iColor;
    TPanel(FindComponent('pnlPackG0'+IntToStr(iRows))).Color :=iColor;
end;

function TuMainForm.ZsGetDay(mYear, mMonth: Integer): Integer;
begin
  case mMonth of
    1, 3, 5, 7, 8, 10, 12 : Result := 31;
    2                     : if IsLeapYear(mYear)then Result :=29
                                else  Result:=28;
  else
    Result := 30;
  end;
end;

procedure TuMainForm.btn1Click(Sender: TObject);
begin
    Timer1.OnTimer(Self);
end;

end.
