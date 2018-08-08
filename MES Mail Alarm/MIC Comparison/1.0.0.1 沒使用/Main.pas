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
      sModelName,sFileName:string;
      TotalTarget_List,TotalSPY_List,TotalModel_list:TStringList;
      IsFound :boolean;
      function LoadApServer : Boolean;
      function GetSysDate:TDatetime;
      procedure SendMail(attachmentFilePath:String;AddressList:TStringList);
      procedure QueryYield(QryTemp1:TClientDataset;StartTime,EndTime:string;Process_ID:integer);
      procedure ExportReport;
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
    i:integer;
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

     
     Addresslist.Add('Amigo_Chen@Foxlink.com');
     Addresslist.Add('Robin_yeh@Foxlink.com');
     Addresslist.Add('Jling_Ji@Foxlink.com');
     Addresslist.Add('Chris_zhang@Foxlink.com');
     Addresslist.Add('Jing_Wu@Foxlink.com');
     Addresslist.Add('Jolly_jiang@Foxlink.com');
     Addresslist.Add('Power_Zhang@Foxlink.com');
     Addresslist.Add('Anakin_Lee@Foxlink.com');
     Addresslist.Add('Cm_wang@Foxlink.com');

     Addresslist.Add('Dennis_Shuai@Foxlink.com');
     Addresslist.Add('Killy_Zhou@Foxlink.com');


     if sFileName <>'' then
         SendMail(sFileName,Addresslist);
     Addresslist.Free;
     Close;
     
end;

procedure TuMainForm.QueryYield(QryTemp1:TClientDataset;StartTime,EndTime:string;Process_ID:integer);
begin

    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftInteger,'ProcessID',ptInput);
    QryTemp1.CommandText :='select AA.MODEL_NAME,AA.PDLINE_NAME,AA.EMP_NO,AA.EMP_NAME ,BB.TEST_QTY,AA.REC_QTY FAIL_QTY , '+
                           ' AA.REC_QTY/BB.TEST_QTY NG_RATE FROM ('+
                           ' select MOdel_name,PDLINE_NAME,EMP_NO,EMP_NAME,COUNT(*) REC_QTY FROM '+
                           ' ( '+
                           ' select F.MODEL_NAME, a.serial_number,a.rec_time,b.emp_NO,b.emp_name,C.PDLINE_NAME,D.TERMINAL_NAME '+
                           ' from SAJET.G_SN_DEFECT_FIRST a,sajet.sys_emp b,sajet.sys_pdline c,sajet.sys_terminal d, '+
                           ' sajet.sys_part e,sajet.sys_model f where '+
                           ' a.rec_time >=to_Date(:StartTime,''yyyy/mm/dd hh24:mi:ss'') and  a.work_order not like ''RMA%'' '+
                           ' and  a.rec_time <to_Date(:endtime,''yyyy/mm/dd hh24:mi:ss'') and a.Process_ID =:ProcessID '+
                           ' and A.TEST_EMP_ID =B.EMP_ID and A.PDLINE_ID =C.PDLINE_ID and D.TERMINAL_ID = A.TERMINAL_ID '+
                           ' and a.ntf_time is null and A.MODEL_ID =E.PART_ID and E.MODEL_ID =F.MODEL_ID'+
                           ' ) GROUP BY MOdel_name,PDLINE_NAME,EMP_NO,EMP_NAME order by MODEL_NAME ,PDLINE_NAME,EMP_NO ) AA, '+
                           ' ( select e.MODEL_NAME,C.PDLINE_NAME ,b.EMP_NO,b.EMP_NAME,COUNT(A.SERIAL_NUMBER) TEST_QTY '+
                           ' from sajet.g_SN_TRAVEL a,sajet.sys_EMP b,sajet.sys_pdline c , '+
                           ' sajet.sys_part d,sajet.sys_model e '+
                           ' where a.OUT_PROCESS_TIME >=to_Date(:StartTime,''yyyy/mm/dd hh24:mi:ss'')'+
                           ' and a.OUT_PROCESS_TIME<to_Date(:EndTime,''yyyy/mm/dd hh24:mi:ss'') '+
                           ' and a.Process_ID =:ProcessID '+
                           ' and a.emp_ID=b.EMP_ID and a.model_ID=d.part_ID and D.MODEL_ID = E.MODEL_ID and a.WORK_ORDER not like ''RMA%'' AND '+
                           ' A.PDLINE_ID =C.PDLINE_ID group by e.MODEL_NAME,C.PDLINE_NAME ,b.EMP_NO,b.EMP_NAME'+
                           ' order by MODEL_NAME ,PDLINE_NAME,EMP_NO ) BB '+
                           ' where AA.MODEL_NAME=BB.MODEL_NAME AND AA.PDLINE_NAME =BB.PDLINE_NAME AND AA.EMP_NO=BB.EMP_NO '+
                           ' And BB.TEST_QTY > 50';
    QryTemp1.Params.ParamByName('StartTime').AsString :=  StartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=    EndTime;
    QryTemp1.Params.ParamByName('ProcessID').AsInteger := Process_ID ;
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
            Subject:= FormatDateTime('YYYY/MM/DD HH時',GetSysDate )+' 麥克風測試人員線別對比';
            From.Address:='MES_Sajet@foxlink.com';

            for i :=0 to  AddressList.Count-1 do begin
               Recipients.Add;
               Recipients[i].Address:= AddressList.Strings[i];
            end;
            sMaileMessage:=FormatDateTime('YYYY/MM/DD',GetSysDate )+'  麥克風測試人員線別對比如附件:'+#13;
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
var sStartTime,sEndTime:string;
    ExcelApp,ChartObjects,xRange,yRange,lRange: Variant;
    i,j:integer;
    ProcessList :TstringList;
    SpareNo :TstringList;
begin
    sStartTime  := FormatDateTime('YYYYMMDD',GetSysDate-1)+'20';
    sEndTime := FormatDateTime('YYYYMMDD',GetSysDate)+'20';
    //-------
    ProcessList := TStringList.Create();
    SpareNo :=  TStringList.Create();
    ExcelApp :=CreateOleObject('Excel.Application');
    ExcelApp.displayAlerts:=false;
    ExcelApp.Visible := false;
    ExcelApp.WorkBooks.Open(GetCurrentDir+'\各制程測試人員線別對比Report.xltx');
    ProcessList.add('100238');
    ProcessList.add('100199');
    ProcessList.add('100193');
    ProcessList.add('100241');
    ProcessList.add('100197');
    for I:=0 to ProcessList.Count-1 do begin
      QueryYield(qrytemp,sStartTime ,sEndTime,StrToInt(ProcessList.Strings[i]));

      if QryTemp.IsEmpty then begin
         SpareNo.Add(IntTostr(i+1)) ;
         Continue;
      end;
      ExcelApp.WorkSheets[i+1].Activate;
      //ExcelApp.WorkSheets[1].Name := '麥克風測試';
      ChartObjects :=ExcelApp.ActiveSheet.ChartObjects.Item(1);

      qrytemp.First;
      for j:=0 to  qrytemp.recordCOunt-1 do begin
        ExcelApp.Cells[20+j,1].Value :=  qrytemp.FieldByName('MODEL_NAME').AsString;
        ExcelApp.Cells[20+j,2].Value :=  qrytemp.FieldByName('PDLINE_NAME').AsString;
        ExcelApp.Cells[20+j,3].Value :=  qrytemp.FieldByName('EMP_NAME').AsString;
        ExcelApp.Cells[20+j,7].Value :=  qrytemp.FieldByName('NG_RATE').AsString;
        ExcelApp.Cells[20+j,5].Value :=  qrytemp.FieldByName('TEST_QTY').AsString;
        ExcelApp.Cells[20+j,6].Value :=  qrytemp.FieldByName('FAIL_QTY').AsString;
        ExcelApp.Cells[20+j,4].Value :=  qrytemp.FieldByName('EMP_NO').AsString;
        qrytemp.Next;
      end;
    end;

    sFileName :=  GetCurrentDir+'\'+FormatDateTime('YYYYMMDD',GetSysDate) +'各制程測試人員與纖體對比Report.xlsx';
    ExcelApp.ActiveWorkbook.SaveAs(sFileName);
    ExcelApp.Quit;
    ExcelApp :=Unassigned;

end;


end.
