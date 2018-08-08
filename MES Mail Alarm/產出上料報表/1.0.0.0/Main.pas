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
      procedure QuerySummary(QryTemp1:TClientDataset;StartTime,EndTime:string);
      procedure QueryDetail(QryTemp1:TClientDataset;StartTime,EndTime:string);

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
MailPath,sMail:string;
FpOpen:TextFile;
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
     MailPath:=ExtractFilePath(Paramstr(0))+'\' + 'SMT_PVS.txt';

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
    QryTemp1.CommandText :=' select aaa.work_order,aaa.PART_NO,aaa.target_qty,aaa.REQUEST_QTY ,aaa.total_output,aaa.bom_Need_qty , '+
          ' bbb.station_no,bbb.is_sub_part,bbb.In_time,bbb.out_time,bbb.qty,bbb.reel_no,bbb.emp_name,bbb.pdline_name,'+
          ' round((decode(bbb.out_time,null,sysdate,bbb.out_time)-bbb.In_time)*24,2) diff_Time  from    '+
          ' (select a.work_order,a.target_qty,B.REQUEST_QTY ,C.PART_NO,sum(pass_qty+fail_qty) total_output,      '+
          ' ceil(sum(pass_qty+fail_qty)/a.target_qty*B.REQUEST_QTY) BOM_NEED_QTY from sajet.g_wo_base a,SAJET.G_WO_PICK_LIST b, '+
          ' sajet.sys_part c,SAJET.g_sn_count d,sajet.sys_pdline e where a.work_order=b.work_order  and b.part_id=c.part_id  and a.work_order=d.work_order    '+
          ' and a.work_order in( select distinct work_order from sajet.g_sn_count where  '+
          ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) >=:Start_Time  and '+
          ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) < :End_Time and process_id =100187 ) ' +
          ' and d.process_id =100187  and e.pdline_id =d.pdline_id  and a.work_order <>''NMS68006'' '+
          ' group by a.work_order,a.target_qty,B.REQUEST_QTY,C.PART_NO ) aaa,          '+
          '  ( Select bb.work_order, aa.station_no,aa.part_no,aa.is_sub_part,  '+
          ' bb.In_time,bb.out_time,bb.status,bb.datecode,bb.qty,bb.reel_no,dd.emp_Name,CC.PDLINE_NAME     '+
          ' from (                                                           '+
          ' select A.WORK_ORDER,A.PDLINE_ID,D.PART_NO,d.part_id,B.STATION_NO, ''0'' IS_SUB_PART      '+
          ' from SMT.G_WO_MSL A,SMT.G_WO_MSL_DETAIL B, sajet.sys_part D               '+
          ' where    a.WO_SEQUENCE =b.WO_SEQUENCE and D.PART_ID =B.ITEM_PART_ID                      '+
          ' UNION                                                     '+
          ' select A.WORK_ORDER, A.PDLINE_ID,D.PART_NO,d.part_id,B.STATION_NO  ,''1'' IS_SUB_PART    '+
          ' from SMT.G_WO_MSL A, SMT.G_WO_MSL_DETAIL B,smt.g_wo_msl_sub C ,sajet.sys_part D           '+
          ' where  a.WO_SEQUENCE =b.WO_SEQUENCE and B.WO_SEQUENCE=C.WO_SEQUENCE '+
          '  AND B.ITEM_PART_ID = C.ITEM_PART_ID AND  C.SUB_PART_ID =D.PART_ID ) aa,   '+
          ' (select * from SMT.G_SMT_STATUS                            '+
          ' union                                                      '+
          ' select * from SMT.G_SMT_TRAVEL ) bb ,sajet.sys_pdline cc ,sajet.sys_emp dd    '+
          ' where aa.work_order =bb.work_order and bb.item_part_id = aa.part_id  and    '+
          ' bb.pdline_id=cc.pdline_id and BB.EMP_ID =dd.EMP_ID  and aa.pdline_id =bb.pdline_id  ' +
          ' and aa.station_no =bb.station_no     ) bbb                              '+
          ' where aaa.work_order = bbb.work_order and aaa.part_no = bbb.part_no     '+
          ' order by work_order,part_no,station_no,in_Time  ';
    QryTemp1.Params.ParamByName('START_TIME').AsString :=  StartTime;
    QryTemp1.Params.ParamByName('End_Time').AsString :=    EndTime;
    QryTemp1.Open;

end;

procedure TuMainForm.QuerySummary(QryTemp1:TClientDataset;StartTime,EndTime:string);
begin

    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftString,'StartTime',ptInput);
    QryTemp1. Params.CreateParam(ftString,'EndTime',ptInput);
    QryTemp1.CommandText := ' select aaa.work_order,aaa.target_qty,aaa.REQUEST_QTY,aaa.PART_NO ,aaa.SPEC1,aaa.total_output,BOM_QTY ,bbb.PVS_QTY  FROM   '+
           ' ( select a.work_order,a.target_qty,B.REQUEST_QTY ,C.PART_NO,C.SPEC1,sum(pass_qty+fail_qty) total_output,'+
           '  Ceil(sum(pass_qty+fail_qty)/a.target_qty*B.REQUEST_QTY) BOM_QTY '+
           ' from sajet.g_wo_base a,SAJET.G_WO_PICK_LIST b,sajet.sys_part c,SAJET.g_sn_count d ,sajet.sys_pdline e '+
           ' where a.work_order=b.work_order  and b.part_id=c.part_id  and a.work_order=d.work_order and d.pdline_id=e.pdline_id and a.work_order <>''NMS68006'' '+
           ' and a.work_order in( select distinct work_order from sajet.g_sn_count where  '+
           ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) >=:StartTime  and '+
           ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) < :EndTime and process_id =100187 )  and d.process_id =100187 '+
           ' group by a.work_order,a.target_qty,B.REQUEST_QTY,C.PART_NO,C.SPEC1 order by a.work_order,c.part_no )aaa,  '+
           ' ( select work_order,PART_NO,SUM(QTY) PVS_QTY FROM ( '+
            ' Select bb.work_order,AA.part_no, BB.REEL_NO,BB.QTY  from (              '+
           ' select A.WORK_ORDER,A.PDLINE_ID,C.PART_NO ,C.PART_ID,B.STATION_NO  '+
           ' from SMT.G_WO_MSL A, SMT.G_WO_MSL_DETAIL B ,sajet.sys_part c   '+
           ' WHERE  A.WO_SEQUENCE=B.WO_SEQUENCE AND b.Item_part_ID =c.part_id UNION '+
           ' select A.WORK_ORDER,A.PDLINE_ID,D.PART_NO ,D.PART_ID,B.STATION_NO   '+
           ' from  SMT.G_WO_MSL A, SMT.G_WO_MSL_DETAIL B,SMT.g_wo_msl_sub C,SAJET.SYS_PART D  '+
           ' where A.WO_SEQUENCE=B.WO_SEQUENCE  AND B.WO_SEQUENCE = C.WO_SEQUENCE  AND B.ITEM_PART_ID = C.ITEM_PART_ID AND D.PART_ID=C.SUB_PART_ID ) aa ,'+
           ' ( Select * from SMT.G_SMT_STATUS    union    select * from SMT.G_SMT_TRAVEL ) bb ,sajet.sys_pdline cc '+
           ' where aa.WORK_ORDER =bb.WORK_ORDER and bb.item_part_id = aa.part_id and bb.pdline_id=cc.pdline_id  and aa.pdline_id =bb.pdline_id  '+
            '  and aa.station_no =bb.station_no  and aa.work_order in( select distinct work_order from sajet.g_sn_count where  '+
           ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) >=:StartTime  and '+
           ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) < :EndTime and process_id =100187 ) '+
           ' GROUP BY bb.work_order,AA.part_no, BB.REEL_NO,BB.QTY )  GROUP BY work_order,part_no ) bbb  '+
           ' where aaa.work_order=bbb.work_order and aaa.part_no=bbb.part_no   '+
           ' order by aaa.work_order,aaa.part_no ';

    QryTemp1.Params.ParamByName('StartTime').AsString := starttime;
    QryTemp1.Params.ParamByName('EndTime').AsString := endtime;

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
            Subject:= FormatDateTime('YYYY/MM/DD',GetSysDate-1)+' SMT上料和產出數量統計';
            From.Address:='MES_Sajet@foxlink.com';

            for i :=0 to  AddressList.Count-1 do begin
               Recipients.Add;
               Recipients[i].Address:= AddressList.Strings[i];
            end;
            sMaileMessage:=FormatDateTime('YYYY/MM/DD',GetSysDate-1 )+' SMT上料和產出數量統計:'+#13;
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
var sStartTime,sEndTime,sWO,sPN,sTarget,sRequest,sBOM_QTY,sOutput,sPVS_QTY,sSpec:string;
    ExcelApp,ChartObjects,xRange,yRange,lRange: Variant;
    i :integer;
begin
    sStartTime  := FormatDateTime('YYYYMMDD',GetSysDate-1)+'08';
    sEndTime := FormatDateTime('YYYYMMDD',GetSysDate)+'08';
    //-------
    QuerySummary(Qrytemp,sStartTime,sEndTime);
    if Qrytemp.IsEmpty then exit;
    ExcelApp :=CreateOleObject('Excel.Application');
    ExcelApp.displayAlerts:=false;
    ExcelApp.Visible := false;
    sFileName := ExtractFilePath(Paramstr(0)) +'Report\SMT上料和產出數量對比統計.xlsx';

    ExcelApp.WorkBooks.Open(ExtractFilePath(Paramstr(0))+'SMT上料和產出數量對比統計.xlsx');
    ExcelApp.WorkSheets[1].Activate;
    ExcelApp.WorkSheets[1].Name :=  'SMT上料和產出數量對比' ;
    ExcelApp.Cells[1,1].Value := 'SMT上料和產出數量對比';

    ExcelApp.Cells[2,1].Value := '在制工單';
    ExcelApp.Cells[2,2].Value := '料號';
    ExcelApp.Cells[2,3].Value := '工單總數';
    ExcelApp.Cells[2,4].Value := 'BOM需求量';
    ExcelApp.Cells[2,5].Value := '產出';
    ExcelApp.Cells[2,6].Value := '應上料數';
    ExcelApp.Cells[2,7].Value := '已上料數';
    ExcelApp.Cells[2,8].Value := '物料描述';
    ExcelApp.ActiveSheet.Range['A1:H1'].Merge;
    for i:=1 to 7 do
       ExcelApp.Columns[1].ColumnWidth := 22;

    i:=0;
    if not Qrytemp.IsEmpty then
    begin
        Qrytemp.First;
        for  i:=0 to Qrytemp.RecordCount-1  do
        begin
              swo := Qrytemp.FieldByName('WORK_ORDER').AsString ;
              sPN := Qrytemp.FieldByName('PART_NO').AsString ;
              sTarget :=  Qrytemp.FieldByName('TARGET_QTY').AsString;
              sRequest :=  Qrytemp.FieldByName('REQUEST_QTY').AsString;
              sOutput :=  Qrytemp.FieldByName('total_output').AsString;
              sBOM_Qty :=  Qrytemp.FieldByName('BOM_QTY').AsString;
              sPVS_QTY :=  Qrytemp.FieldByName('PVS_QTY').AsString;
              sSpec := Qrytemp.FieldByName('Spec1').AsString;

              if Qrytemp.FieldByName('PVS_QTY').AsInteger <  Qrytemp.FieldByName('BOM_QTY').AsInteger then
              begin
                   ExcelApp.ActiveSheet.Range['A'+IntToStr(I+3)+':H'+IntToStr(I+3)].Interior.Color :=clRed;
              end;

              ExcelApp.Cells[i+3,1].Value := sWO;
              ExcelApp.Cells[i+3,2].Value := sPN;
              ExcelApp.Cells[i+3,3].Value := sTarget;
              ExcelApp.Cells[i+3,4].Value := sRequest;
              ExcelApp.Cells[i+3,5].Value := sOutput;
              ExcelApp.Cells[i+3,6].Value := sBOM_Qty;
              ExcelApp.Cells[i+3,7].Value := sPVS_QTY;
              ExcelApp.Cells[i+3,8].Value := sSpec;
              Qrytemp.Next;
        end;
    end;

    ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].HorizontalAlignment :=3;
    ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].VerticalAlignment :=2;
    ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[1].Weight := 2;
    ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[2].Weight := 2;
    ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[3].Weight := 2;
    ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[4].Weight := 2;
    ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[7].Weight := xlThick;
    ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[8].Weight := xlThick;
    ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[9].Weight := xlThick;
    ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[10].Weight := xlThick;

    ExcelApp.WorkSheets[2].Activate;
    QueryDetail(Qrytemp,sStartTime,sEndTime);
    qrytemp.First;
    for i:=1 to  qrytemp.RecordCount  do
    begin
        ExcelApp.Cells[i+1,1].Value  :=  qrytemp.FieldByName('work_order').AsString;
        ExcelApp.Cells[i+1,2].Value  :=  qrytemp.FieldByName('part_no').AsString;
        ExcelApp.Cells[i+1,3].Value  :=  qrytemp.FieldByName('Target_qty').AsString;
        ExcelApp.Cells[i+1,4].Value  :=  qrytemp.FieldByName('REQUEST_QTY').AsString;
        ExcelApp.Cells[i+1,5].Value  :=  qrytemp.FieldByName('BOM_NEED_QTY').AsString;
        ExcelApp.Cells[i+1,6].Value  :=  qrytemp.FieldByName('pdline_name').AsString;
        ExcelApp.Cells[i+1,7].Value  :=  qrytemp.FieldByName('STATION_NO').AsString;
        ExcelApp.Cells[i+1,8].Value  :=  qrytemp.FieldByName('IN_TIME').AsString;
        ExcelApp.Cells[i+1,9].Value  :=  qrytemp.FieldByName('OUT_TIME').AsString;
        ExcelApp.Cells[i+1,10].Value  :=  qrytemp.FieldByName('REEL_NO').AsString;
        ExcelApp.Cells[i+1,11].Value :=  qrytemp.FieldByName('QTY').AsString;
        ExcelApp.Cells[i+1,12].Value :=  qrytemp.FieldByName('DIFF_TIME').AsString;
        ExcelApp.Cells[i+1,13].Value :=  qrytemp.FieldByName('EMP_name').AsString;
        qrytemp.Next;
    end;

    ExcelApp.ActiveSheet.Range['A1:M'+IntToStr(I)].HorizontalAlignment :=3;
    ExcelApp.ActiveSheet.Range['A1:M'+IntToStr(I)].VerticalAlignment :=2;
    ExcelApp.ActiveSheet.Range['A1:M'+IntToStr(I)].Borders[1].Weight := 2;
    ExcelApp.ActiveSheet.Range['A1:M'+IntToStr(I)].Borders[2].Weight := 2;
    ExcelApp.ActiveSheet.Range['A1:M'+IntToStr(I)].Borders[3].Weight := 2;
    ExcelApp.ActiveSheet.Range['A1:M'+IntToStr(I)].Borders[4].Weight := 2;
    ExcelApp.ActiveSheet.Range['A1:M'+IntToStr(I)].Borders[7].Weight := xlThick;
    ExcelApp.ActiveSheet.Range['A1:M'+IntToStr(I)].Borders[8].Weight := xlThick;
    ExcelApp.ActiveSheet.Range['A1:M'+IntToStr(I)].Borders[9].Weight := xlThick;
    ExcelApp.ActiveSheet.Range['A1:M'+IntToStr(I)].Borders[10].Weight := xlThick;

    ExcelApp.WorkSheets[1].Activate;
    ExcelApp.ActiveWorkbook.SaveAs(sFileName);
    ExcelApp.Quit;
    ExcelApp :=Unassigned;

end;


end.
