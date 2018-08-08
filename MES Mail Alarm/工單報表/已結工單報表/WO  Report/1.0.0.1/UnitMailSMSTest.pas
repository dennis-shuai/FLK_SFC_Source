unit UnitMailSMSTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,ADODB, IdComponent, IdTCPConnection, IdTCPClient,
  IdMessageClient, IdSMTP, IdBaseComponent, IdMessage, DB, DBClient,
  MConnect, ObjBrkr, SConnect, Excel2000,
  Buttons ,ExtCtrls, ComCtrls,Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids,DateUtils,IdGlobal;

type
  TfMailRepairReport = class(TForm)
    btnSendMail: TButton;
    DBConn: TADOConnection;
    dbCommand: TADOCommand;
    SocketConnection1: TSocketConnection;
    SimpleObjectBroker1: TSimpleObjectBroker;
    Button1: TButton;
    Qrytemp: TClientDataSet;
    QryDate: TClientDataSet;
    QryTemp2: TClientDataSet;
    QryDefect: TClientDataSet;
    QryTemp4: TClientDataSet;
    QryData1: TClientDataSet;
    QryModel: TClientDataSet;
    QryTemp3: TClientDataSet;
    QryData: TClientDataSet;
    IdSMTP1: TIdSMTP;
    IdMessage1: TIdMessage;
    //procedure btnSendMailClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    UpdateUserID,UpdateUserNO:string;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID : String;
    Count:Integer;
    UpDate_Time :TDateTime;
    sStartTime, sEndTime, sDStartTime, sDEndTime,sTime1,sTime2 :string;

    work_time:string;
    work_date:string;
    work_dateTile:string;
    work_timeTitle:string;
    MobileInfo:string;
    Shift:string;
    sFileName:string;

    function QueryOutput( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function QueryRepirOutput( QryTemp1:TClientDataset;Work_order:String):boolean;

    
    function QueryWo(QryTemp1: TClientDataset;start_time,end_time:string): boolean;
    function  LoadApServer : Boolean;
    procedure ExportReport;
    function GetSysDate:TDatetime;
    procedure SendMail(attachmentFilePath:String;AddressList:TStringList);

  end;

var
  fMailRepairReport: TfMailRepairReport;

implementation

{$R *.dfm}

function TfMailRepairReport.GetSysDate:TDateTime;
begin
    QryDate.Close;
    QryDate.CommandText := 'select SysDate from  dual';
    QryDate.Open;
    result := QryDate.fieldbyname('SYSDate').AsDateTime;
end;


function TfMailRepairReport.LoadApServer : Boolean;
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


procedure TfMailRepairReport.Button1Click(Sender: TObject);
begin
  close;
end;

procedure TfMailRepairReport.FormShow(Sender: TObject);
var Addresslist:TStringList;
    i:integer;
    MailPath:string;
    
    FpOpen: TextFile;
    sMail:string;
begin
    LoadApServer;
    QryData.ProviderName:='DspQryData';
    Qrytemp.ProviderName := 'DspQryTemp1';

    Qrytemp2.ProviderName := 'DspQryTemp1';
    Qrytemp3.ProviderName := 'DspQryTemp1';
    Qrytemp4.ProviderName := 'DspQryTemp1';
    QryDate.ProviderName := 'DspQryTemp1';
    QryDefect.ProviderName := 'DspQryData1';
    QryData1.ProviderName := 'DspQryData1';
    QryModel.ProviderName := 'DspQryData1';

    ExportReport;

    Addresslist := TStringList.Create;


    MailPath:=ExtractFilePath(Paramstr(0))+'\' + 'Mail.txt';
    AssignFile(FpOpen, MailPath);
    Reset(FpOpen);//打開文件
    while not EOF(FpOpen)do begin
        Readln(FpOpen,sMail);
        if trim(sMail)<>'' THEN
           Addresslist.Add(sMail);
    end;
    CloseFile(FpOpen);


    {
    Addresslist := TStringList.Create;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.CommandText :='SELECT EMAIL FROM sajet.SYS_MOBILE WHERE SEND_DAILY_MAIL =''Y'' ORDER BY DEPT_NAME ';
    QryTemp.Open;
    if QryTemp.IsEmpty then exit;
    QryTemp.First;
    for i:=0 to QryTemp.RecordCount-1 do begin
        Addresslist.Add(Qrytemp.fieldbyname('EMail').AsString);
        QryTemp.Next;
    end;
    }
    //Addresslist.Clear;
    //Addresslist.Add('killy_zhou@foxlink.com');

    if sFileName <>'' then
         SendMail(sFileName,Addresslist);
    Addresslist.Free;

    Close;


end;

procedure TfMailRepairReport.SendMail(attachmentFilePath:String;AddressList:TStringList);
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
            Subject:=FormatDateTime('YYYY/MM/DD',GetSysDate-1)+'  已結工單明細';
            From.Address:='MES_Sajet@foxlink.com';

            for i :=0 to  AddressList.Count-1 do begin
               Recipients.Add;
               Recipients[i].Address:= AddressList.Strings[i];
            end;
            sMaileMessage:='Dear All:'+#13+#13+'  附件是'+FormatDateTime('YYYY/MM/DD',GetSysDate-1)+'  SFC已結工單明細！'+#13+#13+'   ';
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


function TfMailRepairReport.QueryOutput(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.CommandText:='';
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sEndTime;
    QryTemp1.Open;
end;

procedure TfMailRepairReport.ExportReport;
var

    ExcelApp: Variant;
    j:Integer;
    sWo,sModel:string;
    sWoQty,sInput,sOutput,sRepairOutput,sScrapQty:Integer;
    sDate:TDateTime;
    start_time,end_time:string;
begin
     sFileName := ExtractFilePath(Paramstr(0))+'Report\'+FormatDateTime('YYYY年M月D日',GetSysDate)+' SFC已結工單明細.xlsx'  ;
     if FileExists(sFileName) then
        DeleteFile(sFileName);

    //查詢已結工單   WO_STATUS  Release=2  Wip=3     PGI= 100203   SMT_PGI=100242
    start_time :=FormatDateTime('YYYYMMDD ',GetSysDate-1)+'08:00:00';
    end_time := FormatDateTime('YYYYMMDD ',GetSysDate)+'08:00:00';
    QueryWO(QryData,start_time,End_time);
    if  QryData.IsEmpty then  Exit;


    ExcelApp :=CreateOleObject('Excel.Application');
    ExcelApp.Visible :=false;
    ExcelApp.displayAlerts:=false;
    ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'Wo Complete Report.xltx');
    ExcelApp.WorkSheets[1].Activate;

    QryData.First;
    for  j:=0 to QryData.RecordCount-1  do
    begin
          sWo :=QryData.FieldByName('Work_order').AsString ;
          sModel:=QryData.FieldByName('Model_Name').AsString ;
          sWoQty :=  QryData.FieldByName('TARGET_QTY').asInteger;
          sInput :=  QryData.FieldByName('INPUT_QTY').asInteger;
          sOutput :=  QryData.FieldByName('Output_QTY').asInteger;
          sDate:= QryData.FieldByName('wo_create_date').AsDateTime;

          if (sInput=0) and (sOutput=0) then
          begin
              ExcelApp.Cells[j+3,1].Value :=MonthOf(sDate);
              ExcelApp.Cells[j+3,2].Value := DayOf(sDate);
              ExcelApp.Cells[j+3,3].Value := sWo;
              ExcelApp.Cells[j+3,4].Value := sModel;
              ExcelApp.Cells[j+3,5].Value := IntToStr(sWoQty);
              ExcelApp.Cells[j+3,6].Value := IntToStr(sInput);
              ExcelApp.Cells[j+3,7].Value := IntToStr(sOutput);
             // ExcelApp.Cells[j+3,8].Value := IntToStr(sOutput);
              ExcelApp.Cells[j+3,9].Value := '0';
             // ExcelApp.Cells[j+3,10].Value := IntToStr(sOutput);
              ExcelApp.Cells[j+3,11].Value := '0';     //報廢數
             // ExcelApp.Cells[j+3,12].Value := IntToStr(sOutput);
              ExcelApp.Cells[j+3,13].Value := '0';    //差異數
          end else begin
              QueryRepirOutput(Qrytemp, sWo);
              sRepairOutput := Qrytemp.fieldbyName('Repair_Qty').AsInteger;

              //報廢數
              QryData1.Close;
              QryData1.Params.Clear;
              QryData1.Params.CreateParam(ftstring,'tWo',ptInput);
              QryData1.CommandText:='SELECT COUNT(*) as SCRAP_QTY  FROM SAJET.G_SN_STATUS where Work_order=:tWo and WORK_FLAG=1 ';
              QryData1.Params.ParamByName('tWo').AsString := sWo;
              QryData1.Open;
              if not QryData1.IsEmpty then
                  sScrapQty:=QryData1.FieldByName('SCRAP_QTY').asInteger
              else
                  sScrapQty:=0;

              ExcelApp.Cells[j+3,1].Value :=MonthOf(sDate);
              ExcelApp.Cells[j+3,2].Value := DayOf(sDate);
              ExcelApp.Cells[j+3,3].Value := sWo;
              ExcelApp.Cells[j+3,4].Value := sModel;
              ExcelApp.Cells[j+3,5].Value := IntToStr(sWoQty);
              ExcelApp.Cells[j+3,6].Value := IntToStr(sInput);
              ExcelApp.Cells[j+3,7].Value  := IntToStr(sOutput-sRepairOutput);
              ExcelApp.Cells[j+3,8].Value  := FloatToStr((sOutput-sRepairOutput)/sInput);
              ExcelApp.Cells[j+3,9].Value  := IntToStr(sRepairOutput);
              ExcelApp.Cells[j+3,10].Value := FloatToStr(sRepairOutput/sInput);
              ExcelApp.Cells[j+3,11].Value := IntToStr(sScrapQty);     //報廢數
              ExcelApp.Cells[j+3,12].Value := FloatToStr(sScrapQty/sInput);     //報廢Rate
              ExcelApp.Cells[j+3,13].Value := IntToStr(sInput-soutput-sscrapqty);    //差異數
          end;
          QryData.Next;
    end;

    ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(J+2)].HorizontalAlignment :=3;
    ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(J+2)].VerticalAlignment :=2;
    ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(J+2)].Font.Size :=8;
    ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(J+2)].Font.Name :='tahoma';
    ExcelApp.ActiveSheet.Columns[8].NumberFormat  := '0.00%';
    ExcelApp.ActiveSheet.Columns[10].NumberFormat  := '0.00%';
    ExcelApp.ActiveSheet.Columns[12].NumberFormat  := '0.00%';
    ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(J+2)].Borders[1].Weight := 2;
    ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(J+2)].Borders[2].Weight := 2;
    ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(J+2)].Borders[3].Weight := 2;
    ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(J+2)].Borders[4].Weight := 2;
    ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(J+2)].Borders[7].Weight := xlThick;
    ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(J+2)].Borders[8].Weight := xlThick;
    ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(J+2)].Borders[9].Weight := xlThick;
    ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(J+2)].Borders[10].Weight := xlThick;

    ExcelApp.WorkSheets[1].Activate;
    ExcelApp.ActiveSheet.SaveAs(sFileName);
    ExcelApp.Quit;






end;

function TfMailRepairReport.QueryWo(QryTemp1: TClientDataset;start_time,end_time:string): boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'Start_Time',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'End_Time',ptInput);
    QryTemp1.CommandText:=' SELECT A.WORK_ORDER,C.MODEL_NAME,A.Wo_Create_Date,A.WO_STATUS,A.TARGET_QTY,A.INPUT_QTY,A.OUTPUT_QTY,A.Output_QTY '+
                          ' FROM SAJET.G_WO_BASE A,SAJET.SYS_PART B,SAJET.SYS_MODEL C ' +
                          ' WHERE A.MODEL_ID=B.PART_ID AND B.MODEL_ID=C.MODEL_ID ' +
                          ' and (wo_status=6 or wo_status=9) and (work_order like ''NM%'' OR work_order like ''RM%'') ' +
                          ' and to_char(A.Update_time,''YYYYMMDD HH24:MI:SS'')  >=:START_TIME '+
                          ' and to_char(A.Update_time,''YYYYMMDD HH24:MI:SS'')  <=:END_TIME and a.Input_qty<>0 '+
                          ' order by A.Wo_Create_Date,A.WORK_ORDER,MODEL_NAME';
    QryTemp1.Params.ParamByName('Start_Time').AsString := start_time  ;
    QryTemp1.Params.ParamByName('End_Time').AsString :=  end_time  ;
    QryTemp1.Open;
end;

function TfMailRepairReport.QueryRepirOutput(QryTemp1: TClientDataset;
  Work_order: String): boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'tWo',ptInput);
    QryTemp1.CommandText:='SELECT Count(distinct a.serial_number) as REPAIR_QTY   '+
                          ' FROM SAJET.g_sn_repair a,sajet.g_sn_status b '+
                          ' where a.Work_order=:tWo and  '+
                          ' a.serial_number =b.serial_number and b.work_flag<>1';
    QryTemp1.Params.ParamByName('tWo').AsString := Work_order;
    QryTemp1.Open;
end;

end.
