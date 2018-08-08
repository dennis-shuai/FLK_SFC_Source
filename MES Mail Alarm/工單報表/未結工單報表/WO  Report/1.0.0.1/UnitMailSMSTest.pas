unit UnitMailSMSTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,ADODB, IdComponent, IdTCPConnection, IdTCPClient,
  IdMessageClient, IdSMTP, IdBaseComponent, IdMessage, DB, DBClient,
  MConnect, ObjBrkr, SConnect,
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
    function QueryWo( QryTemp1:TClientDataset):boolean;
    function QueryRepirOutput( QryTemp1:TClientDataset;Work_order:String):boolean;

    

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

    {
    MailPath:=GetCurrentDir+'\' + 'Mail.txt';
    AssignFile(FpOpen, MailPath);
    Reset(FpOpen);//打開文件
    while not EOF(FpOpen)do begin
        Readln(FpOpen,sMail);
        if trim(sMail)<>'' THEN
           Addresslist.Add(sMail);
    end;
    CloseFile(FpOpen);

    //Addresslist.Add('killy_zhou@foxlink.com');

    }

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
            Subject:=FormatDateTime('YYYY/MM/DD',GetSysDate)+'  未結工單明細';
            From.Address:='MES_Sajet@foxlink.com';

            for i :=0 to  AddressList.Count-1 do begin
               Recipients.Add;
               Recipients[i].Address:= AddressList.Strings[i];
            end;
            sMaileMessage:='Dear All:'+#13+#13+'  附件是'+FormatDateTime('YYYY/MM/DD',GetSysDate)+'  SFC已結工單明細！'+#13+#13+'   ';
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
    QryTemp1.Params.CreateParam(ftstring,'Model_NAme',ptInput);
    QryTemp1.CommandText:=' select B.PROCESS_NAME, B.PROCESS_CODE, '+
                         ' DECODE((SUM(C.PASS_QTY)), NULL, 0, (SUM(C.PASS_QTY))) FPY_QTY , '+
                         ' DECODE((SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.FAIL_QTY))) FAIL_QTY, '+
                         ' DECODE((SUM(C.OUTPUT_QTY)), NULL, 0, (SUM(C.OUTPUT_QTY))) Output_QTY, '+
                         ' DECODE((SUM(C.NTF_QTY)), NULL, 0, (SUM(C.NTF_QTY))) NTF_QTY, '+
                         ' DECODE((SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY))) TOTAL_QTY , '+
                         ' round(DECODE(SUM(C.PASS_QTY),  NULL, 0,SUM(C.PASS_QTY)) / DECODE(SUM(C.PASS_QTY) +SUM(C.FAIL_QTY), NULL, 0,0,1000000000, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)))*100,2)  as "FPY(%)" , '+
                         ' round( DECODE( SUM(C.PASS_QTY) +SUM(C.NTF_QTY), NULL, 0,0,1, SUM(C.PASS_QTY) +SUM(C.NTF_QTY) )  / DECODE(  SUM(C.PASS_QTY+C.FAIL_QTY), NULL, 0,0,100000000 ,(SUM(C.PASS_QTY +C.FAIL_QTY)))*100,2) as "SPY(%)" '+
                         ' FROM   SAJET.SYS_PROCESS B ,  ' +
                         ' (select WORK_ORDER,MODEL_ID,PDLINE_ID,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REFAIL_QTY,OUTPUT_QTY,NTF_QTY,to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime  '+
                         ' from SAJET.G_SN_COUNT where WORK_ORDER LIKE ''RM%'' )  C ,sajet.sys_part d ,sajet.sys_Part e,sajet.sys_model f' +
                         ' WHERE   C.DateTime >=:StartTime and C.DateTime <:endTime   AND '+
                         ' c.model_ID =d.Part_ID and C.Model_ID = E.Part_ID and e.Model_ID= f.Model_ID and f.MOdel_Name =:Model_Name  and'+
                         ' C.PROCESS_ID = B.PROCESS_ID GROUP BY B.PROCESS_NAME, B.PROCESS_CODE ORDER BY B.PROCESS_CODE ';

    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sEndTime;
    QryTemp1.Params.ParamByName('Model_Name').AsString :=   'Maple';
    QryTemp1.Open;
end;

procedure TfMailRepairReport.ExportReport;
var

    ExcelApp: Variant;
    j:Integer;

    sWo,sModel:string;
    sWoQty,sInput,sOutput,sRepairOutput,sScrapQty:Integer;

    sDate:TDateTime;
begin
     sFileName := GetCurrentDir+'\'+FormatDateTime('YYYY年M月D日',GetSysDate)+' SFC未結工單明細.xlsx'  ;
     if FileExists(sFileName) then
        DeleteFile(sFileName);

     ExcelApp :=CreateOleObject('Excel.Application');
     ExcelApp.Visible :=false;
     ExcelApp.displayAlerts:=false;
     ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'Wo Report.xltx');
     ExcelApp.WorkSheets[1].Activate;

    //查詢未結工單   WO_STATUS  Release=2  Wip=3     PGI= 100203   SMT_PGI=100242
    QueryWO(QryData);
    if not QryData.IsEmpty then
    begin
        QryData.First;
        for  j:=0 to QryData.RecordCount-1  do
        begin
              sWo :=QryData.FieldByName('Work_order').AsString ;
              sModel:=QryData.FieldByName('Model_Name').AsString ;
              sWoQty :=  QryData.FieldByName('TARGET_QTY').asInteger;
              sInput :=  QryData.FieldByName('INPUT_QTY').asInteger;
              sOutput :=  QryData.FieldByName('OUTPUT_QTY').asInteger;
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
                  ExcelApp.Cells[j+3,8].Value := '0';
                  ExcelApp.Cells[j+3,9].Value := '0'; //待處理
                  ExcelApp.Cells[j+3,10].Value := '0';     //報廢數
                  ExcelApp.Cells[j+3,11].Value := '0';    //差異數
              end else begin
                   if   sOutput>0 then
                  begin
                      QryData1.Close;
                      QryData1.Params.Clear;
                      QryData1.Params.CreateParam(ftstring,'tWo',ptInput);
                      QryData1.CommandText:='SELECT SUM(repair_qty) as REPAIR_QTY  FROM SAJET.G_SN_COUNT where Work_order=:tWo and repair_qty<>0 ';
                      QryData1.Params.ParamByName('tWo').AsString := sWo;
                      QryData1.Open;
                      if not QryData1.IsEmpty then
                         sRepairOutput:=QryData1.FieldByName('Repair_Qty').asInteger
                      else
                        sRepairOutput:=0;
                  end else begin
                      sRepairOutput:=0;
                  end;
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
                  if sOutput-sRepairOutput>=0 then
                  begin
                      ExcelApp.Cells[j+3,7].Value := IntToStr(sOutput-sRepairOutput);
                      ExcelApp.Cells[j+3,8].Value := IntToStr(sRepairOutput);
                  end else begin
                      ExcelApp.Cells[j+3,7].Value := IntToStr(sOutput);
                      ExcelApp.Cells[j+3,8].Value := '0';
                  end;
                  ExcelApp.Cells[j+3,9].Value := IntToStr(sInput-sOutput-sScrapQty); //待處理
                  ExcelApp.Cells[j+3,10].Value := IntToStr(sScrapQty);     //報廢數
                  ExcelApp.Cells[j+3,11].Value := IntToStr(sWoQty-sInput);    //差異數

              end;

              QryData.Next;

        end;
    end;

    ExcelApp.WorkSheets[1].Activate;
    ExcelApp.ActiveSheet.SaveAs(sFileName);
    ExcelApp.Quit;
    //MessageDlg('Save OK',mtConfirmation,[mbyes],0);

end;

function TfMailRepairReport.QueryWo(QryTemp1: TClientDataset): boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    //QryTemp1.Params.CreateParam(ftstring,'Model_NAme',ptInput);
    QryTemp1.CommandText:='select A.WORK_ORDER,C.MODEL_NAME,A.Wo_Create_Date,A.WO_STATUS,A.TARGET_QTY,A.INPUT_QTY,A.OUTPUT_QTY from SAJET.G_WO_BASE A,SAJET.SYS_PART B,SAJET.SYS_MODEL C ' +
                          ' where A.MODEL_ID=B.PART_ID AND B.MODEL_ID=C.MODEL_ID ' +
                          ' and (wo_status=2 or wo_status=3) and (work_order like ''NM%'' OR work_order like ''RM%'') ' +
                          ' AND SUBSTR(WORK_ORDER,6,3)<''490'' ' +
                          ' order by A.WORK_ORDER';
    //QryTemp1.Params.ParamByName('Model_Name').AsString :=   'Maple';
    QryTemp1.Open;
end;

function TfMailRepairReport.QueryRepirOutput(QryTemp1: TClientDataset;
  Work_order: String): boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'tWo',ptInput);
    QryTemp1.CommandText:='SELECT SUM(repair_qty) as REPAIR_QTY  FROM SAJET.G_SN_COUNT where Work_order=:tWo ';
    QryTemp1.Params.ParamByName('tWo').AsString := Work_order;
    QryTemp1.Open;
end;

end.
