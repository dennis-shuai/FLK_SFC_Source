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
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
      sFileName,sMonth: string;
      IsFound :boolean;
      function LoadApServer : Boolean;
      function GetSysDate:TDatetime;
      procedure SendMail(attachmentFilePath:String;AddressList:TStringList);
      procedure ExportReport;
      procedure QuerySummary(QryTemp1:TClientDataset;StartTime,EndTime:string);
      procedure QueryDetail(QryTemp1:TClientDataset;StartTime,EndTime:string);
      function  AddZero(s:string;HopeLength:Integer):String;

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
function TuMainForm.GetSysDate:TDateTime;
begin
    QryDate.Close;
    QryDate.CommandText := 'select SysDate from  dual';
    QryDate.Open;
    result := QryDate.fieldbyname('SYSDate').AsDateTime;
end;

procedure TuMainForm.FormShow(Sender: TObject);
var Addresslist:TStringList;
MailPath:string;
FpOpen: TextFile;
sMail:string;
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
     MailPath:=ExtractFilePath(Paramstr(0))+'\' + 'Glue_Except_Mail.txt';

     AssignFile(FpOpen, MailPath);
     Reset(FpOpen);//打開文件
     while not EOF(FpOpen)do begin
        Readln(FpOpen,sMail);
        if trim(sMail)<>'' THEN
           Addresslist.Add(sMail);
     end;
     CloseFile(FpOpen);

     // Addresslist.Add('Dennis_shuai@Foxlink.com');
     if sFileName <>'' then
         SendMail(sFileName,Addresslist);
     Addresslist.Free;
     Close;
     
end;

procedure TuMainForm.QueryDetail(QryTemp1:TClientDataset;StartTime,EndTime:string);
begin

    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'START_TIME',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'END_TIME',ptInput);
    QryTemp1.CommandText := ' select pdline_name,SN,out_process_time,emp_name,defect_desc,vi_name,rec_Time from '+
                            ' (select pdline_name,SN,out_process_time,emp_name,vi_name,rec_Time ,defect_desc,'+
                            ' ROW_NUMBER() OVER(partition by  sn ORDER BY out_process_time DESC)  ran from  '+
                            ' (select d.pdline_name,b.defect_desc, decode(c.customer_sn,''N/A'',                          '+
                            ' c.serial_number,c.Customer_SN) SN,c.out_process_time,e.emp_name,A.REC_TIME ,f.emp_name VI_Name  '+
                            ' from sajet.g_sn_defect a,sajet.sys_defect b, sajet.g_sn_travel c ,sajet.sys_pdline d,sajet.sys_emp e ,sajet.sys_emp f '+
                            ' where A.REC_TIME>=to_date(:start_time,''YYYY/MM/DD HH24:MI:SS'') and A.REC_TIME <to_date(:end_time,''YYYY/MM/DD HH24:MI:SS'')'+
                            ' and A.SERIAL_NUMBER =C.SERIAL_NUMBER and a.defect_id =b.defect_id and a.process_id =100215 and c.process_id =100266 and a.test_emp_id=f.emp_ID  '+
                            ' and b.defect_desc like ''%膠%'' and c.pdline_id=d.pdline_id and c.emp_id=e.emp_id and c.out_process_time < a.rec_time ' +
                            ' )) where ran=1 ';
    QryTemp1.Params.ParamByName('START_TIME').AsString :=  StartTime;
    QryTemp1.Params.ParamByName('End_Time').AsString :=    EndTime;
    QryTemp1.Open;

end;

procedure TuMainForm.QuerySummary(QryTemp1:TClientDataset;StartTime,EndTime:string);
begin

    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'START_TIME',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'END_TIME',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'iMonth',ptInput);
    QryTemp1.CommandText := ' select pdline_name,substr(workdate,5,4) workdate,count(*) allCount  from '+
                            ' (select pdline_name,SN,out_process_time,emp_name,rec_Time,sajet.sj_get_time_Date(out_process_time) as workdate from '+
                            ' (select pdline_name,SN,out_process_time,emp_name,rec_Time ,ROW_NUMBER() OVER(partition by  sn ORDER BY out_process_time DESC)  ran from  '+
                            ' (select d.pdline_name,decode(c.customer_sn,''N/A'',                                                                  '+
                            ' c.serial_number,c.Customer_SN) SN,c.out_process_time,e.emp_name,A.REC_TIME                                         '+
                            ' from sajet.g_sn_defect a,sajet.sys_defect b, sajet.g_sn_travel c ,sajet.sys_pdline d,sajet.sys_emp e               '+
                            ' where A.REC_TIME>=to_date(:start_time,''YYYY/MM/DD HH24:MI:SS'') and A.REC_TIME <to_date(:end_time,''YYYY/MM/DD HH24:MI:SS'')'+
                            ' and A.SERIAL_NUMBER =C.SERIAL_NUMBER and a.defect_id =b.defect_id and a.process_id =100215 and c.process_id =100266 and d.pdline_Name like ''CM%''  '+
                            ' and b.defect_desc like ''%膠%'' and c.pdline_id=d.pdline_id and c.emp_id=e.emp_id and c.out_process_time < a.rec_time ' +
                            ' )) where ran=1  ) where substr(workdate,5,2) =:iMonth  group by pdline_name,workdate order by workdate,pdline_name';
    QryTemp1.Params.ParamByName('START_TIME').AsString :=  StartTime;
    QryTemp1.Params.ParamByName('End_Time').AsString :=    EndTime;
    QryTemp1.Params.ParamByName('iMonth').AsString :=    sMonth;
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
            Subject:= FormatDateTime('YYYY/MM/DD',GetSysDate-1)+' 機台點膠異常統計';
            From.Address:='MES_Sajet@foxlink.com';

            for i :=0 to  AddressList.Count-1 do begin
               Recipients.Add;
               Recipients[i].Address:= AddressList.Strings[i];
            end;
            sMaileMessage:=FormatDateTime('YYYY/MM/DD',GetSysDate-1 )+' 機台點膠異常如附件:'+#13;
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
var sStartTime,sEndTime,sTemp,sDate,sPdline:string;
    ExcelApp,ChartObjects,xRange,yRange,lRange: Variant;
    i,j,k,iDate:integer;

begin
    sStartTime  := FormatDateTime('YYYY/MM/',GetSysDate-1)+'01 08:00:00';
    sEndTime := FormatDateTime('YYYY/MM/DD',GetSysDate)+' 08:00:00';
    //-------
    iDate := StrToInt(FormatDateTime('DD',GetSysDate-1));


    ExcelApp :=CreateOleObject('Excel.Application');
    ExcelApp.displayAlerts:=False;
    ExcelApp.Visible := False;

    sFileName := ExtractFilePath(Paramstr(0)) +'Report\機台點膠異常統計.xlsx';

    ExcelApp.WorkBooks.Open(ExtractFilePath(Paramstr(0))+'機台點膠異常統計.xlsx');


    ExcelApp.WorkSheets[1].Activate;
    for i:=1 to iDate do
    begin
        sDate := FormatDateTime('MM',GetSysDate-1)+AddZero(intToStr(i),2);
       ExcelApp.Cells[16,i+2].Value :=  sDate;
       ExcelApp.Cells[39,i+2].Value :=  sDate;
       ExcelApp.Cells[63,i+2].Value :=  sDate;
       ExcelApp.Cells[85,i+2].Value :=  sDate;
       ExcelApp.Cells[108,i+2].Value :=  sDate;
       ExcelApp.Cells[130,i+2].Value :=  sDate;
       ExcelApp.Cells[152,i+2].Value :=  sDate;
       ExcelApp.Cells[175,i+2].Value :=  sDate;
       ExcelApp.Cells[198,i+2].Value :=  sDate;
       ExcelApp.Cells[220,i+2].Value :=  sDate;
       ExcelApp.Cells[242,i+2].Value :=  sDate;
    end;
    sMonth :=FormatDateTime('MM',GetSysDate-1);
    QuerySummary(Qrytemp,sStartTime,sEndTime);

    qrytemp.First;
    for j:=0 to  qrytemp.recordCOunt-1 do
    begin
        for i:=17 to 248 do
        begin
             sTemp:=Qrytemp.FieldByName('workdate').AsString;

             if  Copy(sTemp,1,2) = sMonth then begin
                 k := StrToInt(Copy(sTemp,Length(sTemp)-1,2));
                 sPdline :=   Qrytemp.FieldByName('pdline_name').AsString;
                 if sPdline  = ExcelApp.Cells[i,2].Value  then
                 begin
                      ExcelApp.Cells[i,k+2].Value :=  qrytemp.FieldByName('allCount').AsString;
                      Continue;
                 end;
             end;
        end;
        qrytemp.Next;
    end;
     
    ExcelApp.WorkSheets[2].Activate;
    sStartTime  := FormatDateTime('YYYY/MM/DD',GetSysDate-1)+' 08:00:00';
    sEndTime := FormatDateTime('YYYY/MM/DD',GetSysDate)+' 08:00:00';

    QueryDetail(Qrytemp,sStartTime,sEndTime);
    ExcelApp.Cells[1,1].Value:='測試機台';
    ExcelApp.Cells[1,2].Value:='測試時間';
    ExcelApp.Cells[1,3].Value:='測試人員';
    ExcelApp.Cells[1,4].Value:='目檢時間';
    ExcelApp.Cells[1,5].Value:='目檢人員';
    ExcelApp.Cells[1,6].Value:='條碼';
    ExcelApp.Cells[1,7].Value:='不良類型';
    qrytemp.First;
    for i:=1 to  qrytemp.RecordCount  do
    begin
        ExcelApp.Cells[i+1,1].Value :=  qrytemp.FieldByName('pdline_name').AsString;
        ExcelApp.Cells[i+1,2].Value :=  qrytemp.FieldByName('Out_process_Time').AsString;
        ExcelApp.Cells[i+1,3].Value :=  qrytemp.FieldByName('Emp_Name').AsString;
        ExcelApp.Cells[i+1,4].Value :=  qrytemp.FieldByName('Rec_time').AsString;
        ExcelApp.Cells[i+1,5].Value :=  qrytemp.FieldByName('VI_Name').AsString;
        ExcelApp.Cells[i+1,6].Value :=  qrytemp.FieldByName('SN').AsString;
        ExcelApp.Cells[i+1,7].Value :=  qrytemp.FieldByName('Defect_Desc').AsString;
        qrytemp.Next;
    end;

    ExcelApp.WorkSheets[1].Activate;
    ExcelApp.ActiveWorkbook.SaveAs(sFileName);
    ExcelApp.Quit;
    ExcelApp :=Unassigned;

end;

function TuMainForm.AddZero(s:string;HopeLength:Integer):String;
begin
   Result:=StringReplace(Format('%'+IntToStr(HopeLength)+'s',[s]),' ','0',[rfIgnoreCase,rfReplaceAll]);
end;



end.
