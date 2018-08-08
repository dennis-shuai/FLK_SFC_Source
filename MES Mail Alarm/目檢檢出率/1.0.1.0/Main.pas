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
      function ExportReport:Boolean;
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
  If not FileExists(ExtractFilePath(Paramstr(0))+'ApServer.cfg') Then
     Exit;
  AssignFile(F,ExtractFilePath(Paramstr(0))+'ApServer.cfg');
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
 

     if ExportReport then begin
         Addresslist := TStringList.Create;
         MailPath:=ExtractFilePath(Paramstr(0))+'Glue_Except_Mail.txt';

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
     end;
     Close;

end;

procedure TuMainForm.QueryDetail(QryTemp1:TClientDataset;StartTime,EndTime:string);
begin
   {
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
    QryTemp1.Open; }

end;

procedure TuMainForm.QuerySummary(QryTemp1:TClientDataset;StartTime,EndTime:string);
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'START_TIME',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'END_TIME',ptInput);
    QryTemp1.CommandText := ' select A1.EMP_NAME,A1.QTY TOTAL_QTY,NVL(B1.DEFECT_QTY,0) DEFECT_QTY '+
                            ' FROM (select b.emp_name,count(*) qty from sajet.g_sn_travel a,sajet.sys_emp b '+
                            ' where a.emp_id=b.emp_id and a.process_id=100215 ' +
                            ' and out_process_time>=to_date(:START_TIME,''YYYY/MM/DD hh24:mi:ss'') '+
                            ' and out_process_time <to_date(:END_TIME,''YYYY/MM/DD hh24:mi:ss'') '+
                            ' group by b.emp_name) A1,(SELECT B.EMP_NAME,COUNT(*) DEFECT_QTY '+
                            ' FROM SAJET.G_SN_DEFECT_First A,SAJET.SYS_EMP B '+
                            ' WHERE A.TEST_EMP_ID=B.EMP_ID AND  a.process_id=100215 '+
                            ' AND B.EMP_NO <>''001'' '+
                            ' AND A.REC_TIME>= to_date(:START_TIME,''YYYY/MM/DD hh24:mi:ss'') '+
                            ' AND A.REC_TIME <to_date(:END_TIME,''YYYY/MM/DD hh24:mi:ss'') GROUP BY B.EMP_NAME) b1  '+
                            ' WHERE A1.EMP_NAME=B1.EMP_NAME(+) ';
    QryTemp1.Params.ParamByName('START_TIME').AsString :=  StartTime;
    QryTemp1.Params.ParamByName('End_Time').AsString :=    EndTime;
    QryTemp1.Open;
end;


procedure TuMainForm.SendMail(attachmentFilePath:String;AddressList:TStringList);
var i:integer;
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
            Subject:= FormatDateTime('YYYY/MM/DD',GetSysDate-1)+'目檢人員統計';
            From.Address:='MES_Sajet@foxlink.com';

            for i :=0 to  AddressList.Count-1 do begin
               Recipients.Add;
               Recipients[i].Address:= AddressList.Strings[i];
            end;
            sMaileMessage:=FormatDateTime('YYYY/MM/DD',GetSysDate-1 )+'  目檢人員統計:'+#13;
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

function TuMainForm.ExportReport:Boolean;
var sStartTime,sEndTime:string;
    ExcelApp: Variant;
    i,j:integer;
begin
    sStartTime  := FormatDateTime('YYYY/MM/DD',GetSysDate-1)+' 08:00:00';
    sEndTime := FormatDateTime('YYYY/MM/DD',GetSysDate)+' 08:00:00';
    //-------
    Result :=false;
    QuerySummary(Qrytemp,sStartTime,sEndTime);

    if Qrytemp.IsEmpty then  Exit;

    ExcelApp :=CreateOleObject('Excel.Application');
    ExcelApp.displayAlerts:=False;
    ExcelApp.Visible := False;

    sFileName := ExtractFilePath(Paramstr(0)) +'Report\目檢人員統計.xlsx';

    ExcelApp.WorkBooks.Add;
    ExcelApp.WorkSheets[1].Activate;

    ExcelApp.Cells[1,1].Value := 'Name';
    ExcelApp.Cells[1,2].Value := 'Total Qty';
    ExcelApp.Cells[1,3].Value := 'Defect Qty';

    qrytemp.First;
    for i:=0 to  qrytemp.recordCOunt-1 do
    begin
        ExcelApp.Cells[i+2,1].Value :=  qrytemp.FieldByName('Emp_Name').AsString;
        ExcelApp.Cells[i+2,2].Value :=  qrytemp.FieldByName('Total_qty').AsString;
        ExcelApp.Cells[i+2,3].Value :=  qrytemp.FieldByName('Defect_qty').AsString;
        qrytemp.Next;
    end;

    ExcelApp.WorkSheets[1].Activate;
    ExcelApp.ActiveWorkbook.SaveAs(sFileName);
    ExcelApp.Quit;
    ExcelApp :=Unassigned;
    Result :=True;

end;

function TuMainForm.AddZero(s:string;HopeLength:Integer):String;
begin
   Result:=StringReplace(Format('%'+IntToStr(HopeLength)+'s',[s]),' ','0',[rfIgnoreCase,rfReplaceAll]);
end;



end.
