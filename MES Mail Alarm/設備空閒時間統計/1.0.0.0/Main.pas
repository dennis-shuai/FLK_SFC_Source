unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DB, DBClient, MConnect, SConnect, ObjBrkr, ComObj,
  IdComponent, IdTCPConnection, IdTCPClient, IdMessageClient, IdSMTP,
  IdBaseComponent, IdMessage,Excel2000;

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
    dsSproc: TClientDataSet;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
      sFileName: string;
      IsFound :boolean;
      function LoadApServer : Boolean;
      function GetSysDate:TDatetime;
      procedure SendMail(attachmentFilePath:String;AddressList:TStringList);
      procedure ExportReport;
      procedure QuerySummary(QryTemp1:TClientDataset;StartTime,EndTime,workdate:string);
      procedure QueryDetail(QryTemp1:TClientDataset;StartTime,EndTime,workdate:string);

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
function TuMainForm.GetSysDate:TDateTime;
begin
    QryDate.Close;
    QryDate.CommandText := 'select SysDate from  dual';
    QryDate.Open;
    result := QryDate.fieldbyname('SYSDate').AsDateTime;
end;

procedure TuMainForm.FormShow(Sender: TObject);
var Addresslist:TStringList;
begin
     LoadApServer;
     Qrytemp.ProviderName := 'DspQryTemp1';
     Qrytemp2.ProviderName := 'DspQryTemp1';
     Qrytemp3.ProviderName := 'DspQryTemp1';
     QryDate.ProviderName := 'DspQryTemp1';
     QryDefect.ProviderName := 'DspQryData1';
     QryData1.ProviderName := 'DspQryData1';
     QryModel.ProviderName := 'DspQryData1';
 
     
     ExportReport;
     Addresslist := TStringList.Create;
     Addresslist.Add('Dennis_Shuai@Foxlink.com');
     {Addresslist.Add('CI_Liang@Foxlink.com');
     Addresslist.Add('GAVIN094_Huang@Foxlink.com');
     Addresslist.Add('JLING_JI@Foxlink.com');
     Addresslist.Add('CHRIS_ZHANG@Foxlink.com');
     Addresslist.Add('ANAKIN_LEE@Foxlink.com');
     Addresslist.Add('Dingjie_Li@Foxlink.com');
     Addresslist.Add('CheCheng_Lee@Foxlink.com');
     Addresslist.Add('Cassie_DU@Foxlink.com');
     Addresslist.Add('Power_Zhang@Foxlink.com');
     Addresslist.Add('Robin_Yeh@Foxlink.com');
     Addresslist.Add('michael_song@Foxlink.com'); }

     if sFileName <>'' then
         SendMail(sFileName,Addresslist);
     Addresslist.Free;
     Close;
     with dsSproc do begin
        close;
        DataRequest('sajet.ccm_insert_idle_time');
        FetchParams;
        Execute;
     end;
     
end;

procedure TuMainForm.QueryDetail(QryTemp1:TClientDataset;StartTime,EndTime,workdate:string);
begin

    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'START_TIME',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'END_TIME',ptInput);
   // QryTemp1.Params.CreateParam(ftInteger,'startdate',ptInput);
    QryTemp1.CommandText := ' Select bb.pdline_name,aa.test_out_time,aa.test_in_time,aa.timediff from  '+
                            ' (select a.terminal_id,a. work_date,a.shift_ID, '+
                             ' a.test_out_time,b.test_in_time,(b.test_in_time -a.test_out_time)*24*60*60 AS timediff '+
                            '  from (select Terminal_id,test_in_time,test_out_time,work_date,shift_id,ROW_NUMBER() OVER(PARTITION BY terminal_id ,work_date '+
                             ' ORDER BY test_out_time ) RAN from  '+
                             ' sajet.g_sn_time_count where test_in_time >=to_date(:START_TIME,''YYYYMMDD HH24:MI:SS'')'+
                             ' and test_out_time <=to_date(:END_TIME,''YYYYMMDD HH24:MI:SS'')) a, '+
                             ' (select Terminal_id,test_in_time,test_out_time,work_date,shift_id,ROW_NUMBER() OVER(PARTITION BY terminal_id,work_date  '+
                             ' ORDER BY test_out_time ) RAN from '+
                             ' sajet.g_sn_time_count where test_in_time >=to_date(:START_TIME,''YYYYMMDD HH24:MI:SS'') '+
                             ' and test_out_time <=to_date(:END_TIME,''YYYYMMDD HH24:MI:SS'')) b '+
                             ' where A.TERMINAL_ID=b.terminal_ID and a.ran=b.ran-1 and a.work_date=b.work_date and a.shift_Id =b.shift_id '+
                             ' and (b.test_in_time -a.test_out_time)*24*60*60>=60 and   a.test_in_time <b.test_in_time and a.test_out_time < b.test_in_time) aa, '+
                             ' sajet.sys_pdline bb,sajet.sys_terminal cc ,sajet.G_PDLINE_MANAGE DD'+
                             ' where aa.terminal_id =cc.terminal_id and aa.work_date=dd.work_date and  '+
                             ' aa.shift_id =dd.shift_id and dd.repair_line=''N'' and dd.pd_status=1 and bb.pdline_id =dd.pdline_id   '+
                             ' and cc.pdline_id =bb.pdline_id and bb.pdline_name like ''CM%'' and timediff>60 and cc.enabled=''Y'' ';
    QryTemp1.Params.ParamByName('START_TIME').AsString :=  StartTime;
    QryTemp1.Params.ParamByName('End_Time').AsString :=    EndTime;
    //QryTemp1.Params.ParamByName('startdate').AsString :=  workdate ;
    QryTemp1.Open;

end;

procedure TuMainForm.QuerySummary(QryTemp1:TClientDataset;StartTime,EndTime,workdate:string);
begin

    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'START_TIME',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'END_TIME',ptInput);
   // QryTemp1.Params.CreateParam(ftInteger,'startdate',ptInput);
    QryTemp1.CommandText :=  ' Select bb.pdline_name,aa.work_date,sum(aa.timediff/60) timediff from  '+
                             ' (select a.terminal_id,a. work_date,a.shift_ID, '+
                             ' a.test_out_time,b.test_in_time,(b.test_in_time -a.test_out_time)*24*60*60 AS timediff '+
                             '  from (select Terminal_id,test_in_time,test_out_time,work_date,shift_id,ROW_NUMBER() OVER(PARTITION BY terminal_id,work_date '+
                             ' ORDER BY test_out_time ) RAN from  '+
                             ' sajet.g_sn_time_count where test_in_time >=to_date(:START_TIME,''YYYYMMDD HH24:MI:SS'')'+
                             ' and test_out_time <=to_date(:END_TIME,''YYYYMMDD HH24:MI:SS'')) a, '+
                             ' (select Terminal_id,test_in_time,test_out_time,work_date,shift_id,ROW_NUMBER() OVER(PARTITION BY terminal_id,work_date '+
                             ' ORDER BY test_out_time ) RAN from '+
                             ' sajet.g_sn_time_count where test_in_time >=to_date(:START_TIME,''YYYYMMDD HH24:MI:SS'') '+
                             ' and test_out_time <=to_date(:END_TIME,''YYYYMMDD HH24:MI:SS'')) b '+
                             ' where A.TERMINAL_ID=b.terminal_ID and a.ran=b.ran-1 and a.work_Date=b.work_date and a.shift_Id =b.shift_id'+
                             ' and (b.test_in_time -a.test_out_time)*24*60*60>=60 and a.test_in_time <b.test_in_time and a.test_out_time < b.test_in_time ) aa, '+
                             ' sajet.sys_pdline bb,sajet.sys_terminal cc ,sajet.G_PDLINE_MANAGE DD'+
                             ' where aa.terminal_id =cc.terminal_id and aa.work_date=dd.work_date and  '+
                             ' aa.shift_id =dd.shift_id and dd.repair_line=''N'' and dd.pd_status=1 and bb.pdline_id =dd.pdline_id   '+
                             ' and cc.pdline_id =bb.pdline_id and bb.pdline_name like ''CM%'' and timediff>60 and cc.enabled=''Y'' '+
                             ' group by bb.pdline_name, aa.work_date ';
    QryTemp1.Params.ParamByName('START_TIME').AsString :=  StartTime;
    QryTemp1.Params.ParamByName('End_Time').AsString :=    EndTime;
  //  QryTemp1.Params.ParamByName('startdate').AsString :=  workdate ;
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
            Subject:= FormatDateTime('YYYY/MM/DD',GetSysDate-1)+' 設備空閒時間統計';
            From.Address:='MES_Sajet@foxlink.com';

            for i :=0 to  AddressList.Count-1 do begin
               Recipients.Add;
               Recipients[i].Address:= AddressList.Strings[i];
            end;
            sMaileMessage:=FormatDateTime('YYYY/MM/DD',GetSysDate-1 )+' 設備空閒時間統計如附件:'+#13;
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

procedure TuMainForm.ExportReport;
var sStartTime,sEndTime,sMonth,sStartDate,sTemp:string;
    ExcelApp,ChartObjects,xRange,yRange,lRange: Variant;
    i,j,iDateIndex:integer;

begin
    sStartTime  := FormatDateTime('YYYYMM',GetSysDate-1)+'01 08:00:00';
    if  sStartTime = '20160601 08:00:00' then  sStartTime := '20160606 08:00:00';
    sEndTime := FormatDateTime('YYYYMMDD',GetSysDate)+'08:00:00';
    //-------

    ExcelApp :=CreateOleObject('Excel.Application');
    ExcelApp.displayAlerts:=false;
    ExcelApp.Visible := false;
    sMonth := FormatDateTime('YYYY年M',Getsysdate-1);
    sFileName := GetCurrentDir +'\Report\'+sMonth+'月機台閒置時間統計.xlsx';

    ExcelApp.WorkBooks.Open(GetCurrentDir+'\機台閒置時間統計.xlsx');
    
    ExcelApp.WorkSheets[1].Activate;
    QuerySummary(Qrytemp,sStartTime,sEndTime,sStartDate);

    qrytemp.First;
    for j:=0 to  qrytemp.recordCOunt-1 do
    begin
        for i:=18 to 148 do
        begin
             if Qrytemp.FieldByName('pdline_name').AsString =   ExcelApp.Cells[i,2].Value  then
             begin
                   sTemp :=Qrytemp.FieldByName('work_Date').AsString ;
                   if Copy(sTemp,7,1)='0' then  idateindex := StrToInt(Copy(sTemp,8,1))
                   else  idateindex := StrToInt( Copy(sTemp,7,2));

                  ExcelApp.Cells[i,idateindex+2].Value :=  qrytemp.FieldByName('TimeDIff').AsString;
             end;
        end;
        qrytemp.Next;
    end;
    ExcelApp.WorkSheets[2].Activate;


    sStartTime  := FormatDateTime('YYYYMMDD',GetSysDate-1)+' 08:00:00';
    sEndTime := FormatDateTime('YYYYMMDD',GetSysDate)+'08:00:00';
    QueryDetail(Qrytemp,sStartTime,sEndTime,sStartDate);
    ExcelApp.Cells[1,1].Value:='機台名';
    ExcelApp.Cells[1,2].Value:='前結束時間';
    ExcelApp.Cells[1,3].Value:='后起始時間';
    ExcelApp.Cells[1,4].Value:='間隔(秒)';
    qrytemp.First;
    for i:=1 to  qrytemp.RecordCount  do
    begin
        ExcelApp.Cells[i+1,1].Value :=  qrytemp.FieldByName('pdline_name').AsString;
        ExcelApp.Cells[i+1,2].Value :=  qrytemp.FieldByName('Test_out_time').AsString;
        ExcelApp.Cells[i+1,3].Value :=  qrytemp.FieldByName('Test_in_time').AsString;
        ExcelApp.Cells[i+1,4].Value :=  qrytemp.FieldByName('timediff').AsString;
        qrytemp.Next;
    end;

     ExcelApp.WorkSheets[1].Activate;
    ExcelApp.ActiveWorkbook.SaveAs(sFileName);
    ExcelApp.Quit;
    ExcelApp :=Unassigned;

end;


end.
