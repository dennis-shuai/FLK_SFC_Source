unit uCumDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, DB, DBClient, StdCtrls, ComCtrls, ExtCtrls, DateUtils,
  Buttons;

type
  TuCum = class(TForm)
    DataSource1: TDataSource;
    sbtnQuery: TSpeedButton;
    ImageSample: TImage;
    ComboBox2: TComboBox;
    DateTimePicker2: TDateTimePicker;
    Label2: TLabel;
    ComboBox1: TComboBox;
    DateTimePicker1: TDateTimePicker;
    Label1: TLabel;
    DataSource2: TDataSource;
    QryTemp1: TClientDataSet;
    QryTemp2: TClientDataSet;
    Panelpnl1: TPanel;
    pnl5: TPanel;
    pnl6: TPanel;
    pnl16: TPanel;
    pnl4: TPanel;
    Panel1: TPanel;
    PanelM1: TPanel;
    PanelModel1: TPanel;
    PanelLine11: TPanel;
    PanelLine12: TPanel;
    PanelLine13: TPanel;
    PanelInput13: TPanel;
    PanelInput12: TPanel;
    PanelInput11: TPanel;
    PanelOutput11: TPanel;
    PanelOutput12: TPanel;
    PanelOutput13: TPanel;
    PanelYield13: TPanel;
    PanelYield12: TPanel;
    PanelYield11: TPanel;
    PanelM2: TPanel;
    PanelModel2: TPanel;
    PanelLine21: TPanel;
    PanelLine22: TPanel;
    PanelLine23: TPanel;
    PanelInput23: TPanel;
    PanelInput22: TPanel;
    PanelInput21: TPanel;
    PanelOutput21: TPanel;
    PanelOutput22: TPanel;
    PanelOutput23: TPanel;
    PanelYield23: TPanel;
    PanelYield22: TPanel;
    PanelYield21: TPanel;
    PanelM3: TPanel;
    PanelModel3: TPanel;
    PanelLine31: TPanel;
    PanelLine32: TPanel;
    PanelLine33: TPanel;
    PanelInput33: TPanel;
    PanelInput32: TPanel;
    PanelInput31: TPanel;
    PanelOutput31: TPanel;
    PanelOutput32: TPanel;
    PanelOutput33: TPanel;
    PanelYield33: TPanel;
    PanelYield32: TPanel;
    PanelYield31: TPanel;
    PanelM4: TPanel;
    PanelModel4: TPanel;
    PanelLine41: TPanel;
    PanelLine42: TPanel;
    PanelLine43: TPanel;
    PanelInput43: TPanel;
    PanelInput42: TPanel;
    PanelInput41: TPanel;
    PanelOutput41: TPanel;
    PanelOutput42: TPanel;
    PanelOutput43: TPanel;
    PanelYield43: TPanel;
    PanelYield42: TPanel;
    PanelYield41: TPanel;
    Panelpnl2: TPanel;
    Panel19: TPanel;
    Panel20: TPanel;
    Panel21: TPanel;
    Panel22: TPanel;
    Panel23: TPanel;
    PanelM5: TPanel;
    PanelModel5: TPanel;
    PanelLine51: TPanel;
    PanelLine52: TPanel;
    PanelLine53: TPanel;
    PanelInput53: TPanel;
    PanelInput52: TPanel;
    PanelInput51: TPanel;
    PanelOutput51: TPanel;
    PanelOutput52: TPanel;
    PanelOutput53: TPanel;
    PanelYield53: TPanel;
    PanelYield52: TPanel;
    PanelYield51: TPanel;
    PanelM6: TPanel;
    PanelModel6: TPanel;
    PanelLine61: TPanel;
    PanelLine62: TPanel;
    PanelLine63: TPanel;
    PanelInput63: TPanel;
    PanelInput62: TPanel;
    PanelInput61: TPanel;
    PanelOutput61: TPanel;
    PanelOutput62: TPanel;
    PanelOutput63: TPanel;
    PanelYield63: TPanel;
    PanelYield62: TPanel;
    PanelYield61: TPanel;
    PanelM7: TPanel;
    PanelModel7: TPanel;
    PanelLine71: TPanel;
    PanelLine72: TPanel;
    PanelLine73: TPanel;
    PanelInput73: TPanel;
    PanelInput72: TPanel;
    PanelInput71: TPanel;
    PanelOutput71: TPanel;
    PanelOutput72: TPanel;
    PanelOutput73: TPanel;
    PanelYield73: TPanel;
    PanelYield72: TPanel;
    PanelYield71: TPanel;
    PanelM8: TPanel;
    PanelModel8: TPanel;
    PanelLine81: TPanel;
    PanelLine82: TPanel;
    PanelLine83: TPanel;
    PanelInput83: TPanel;
    PanelInput82: TPanel;
    PanelInput81: TPanel;
    PanelOutput81: TPanel;
    PanelOutput82: TPanel;
    PanelOutput83: TPanel;
    PanelYield83: TPanel;
    PanelYield82: TPanel;
    PanelYield81: TPanel;
    btnBtNext: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure btnBtNextClick(Sender: TObject);
 
  private
    { Private declarations }
  public
    { Public declarations }
    sStartTime,sEndTime, sDStartTime ,sDEndTime:string;
    sStartHour,sEndHour,sFirstModel,sModel,sProcess:string;
    Model_Count ,Total_RecordCount,iRecordCount:Integer;
    function QueryOutputAll(QryTemp1:TClientDataset;sStartTime,sEndTime,StartPdline,EndPDline:string):boolean;
    procedure ClearAllCumPanel;
    procedure DisplayData;
  end;

var
  uCum: TuCum;

implementation

uses MainForm, uLineDetail;

{$R *.dfm}
procedure TuCum.ClearAllCumPanel;
var i,j:Integer;
begin
    for i:=1 to 8 do begin
        TPanel(FindComponent('PanelModel'+IntToStr(i))).Caption := '';
        for j:=1 to 3 do begin
            TPanel(FindComponent('PanelInput'+IntToStr(i)+IntTOStr(j))).Caption  := '';
            TPanel(FindComponent('PanelOutput'+IntToStr(i)+IntTOStr(j))).Caption := '';
            TPanel(FindComponent('PanelYield'+IntToStr(i)+IntTOStr(j))).Caption  := '';
             TPanel(FindComponent('PanelYield'+IntToStr(i)+IntTOStr(j))).Color  := clWhite;
            TPanel(FindComponent('PanelLine'+IntToStr(i)+IntTOStr(j))).Caption  := '';
        end;
    end;

end;

function TuCum.QueryOutputAll(QryTemp1:TClientDataset;sStartTime,sEndTime,StartPdline,EndPDline:string):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'StartPdline',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndPDline',ptInput);
    QryTemp1.CommandText:= '  SELECT *  FROM (SELECT  E.MODEL_NAME, C.PROCESS_NAME,C.PROCESS_CODE,SUM(A.PASS_QTY) TOTAL_PASS, '+
                           ' SUM(A.PASS_QTY+A.FAIL_QTY) TOTAL_INPUT,           '+
                           '  ROUND(SUM(A.PASS_QTY) /(SUM(A.PASS_QTY+A.FAIL_QTY))*100,2) FPY     '+
                           ' FROM SAJET.G_SN_COUNT A,SAJET.SYS_PDLINE B,SAJET.SYS_PROCESS C,    '+
                           '  SAJET.SYS_PART D,SAJET.SYS_MODEL E         '+
                           ' WHERE A.pdline_id=B.pdline_id and a.process_id=c.process_id '+
                           ' AND A.MODEL_ID=D.PART_ID  AND D.MODEL_ID = E.MODEL_ID AND (A.PASS_QTY+A.FAIL_QTY)<>0  '+
                           ' AND B.Pdline_name>=:StartPdline and B.Pdline_Name<=:EndPdline   '+
                           ' AND to_char(A.WORK_DATE)|| TRIM(to_char(A.WORK_TIME,''00''))>=:StartTime  '+
                           ' AND to_char(A.WORK_DATE)|| TRIM(to_char(A.WORK_TIME,''00'')) <:EndTime  '+
                           ' AND A.PROCESS_ID =100266         '+
                           ' GROUP BY  E.MODEL_NAME,C.PROCESS_NAME,C.PROCESS_CODE   '+
                           ' UNION                             '+
                           ' SELECT  E.MODEL_NAME, C.PROCESS_NAME,C.PROCESS_CODE,SUM(A.PASS_QTY) TOTAL_PASS, '+
                           ' SUM(A.PASS_QTY+A.FAIL_QTY) TOTAL_INPUT,             '+
                           ' ROUND(SUM(A.PASS_QTY) /(SUM(A.PASS_QTY+A.FAIL_QTY))*100,2) FPY   '+
                           ' FROM SAJET.G_SN_COUNT A,SAJET.SYS_PROCESS C,    '+
                           '    SAJET.SYS_PART D,SAJET.SYS_MODEL E       '+
                           ' WHERE  a.process_id=c.process_id and a.Model_Id IN (   '+
                           ' SELECT MODEL_ID FROM ( Select                  '+
                           ' Model_id ,SUM(B.PASS_QTY) TOTAL_PASS FROM sajet.g_sn_count b,sajet.sys_pdline F  '+
                           ' where  (B.PASS_QTY+B.FAIL_QTY)<>0 AND B.PDLINE_ID =F.PDLINE_ID    '+
                           ' AND F.Pdline_name>=:StartPdline and F.Pdline_Name<=:EndPdline    '+
                           '  AND to_char(B.WORK_DATE)|| TRIM(to_char(B.WORK_TIME,''00''))>=:StartTime '+
                           ' AND to_char(B.WORK_DATE)|| TRIM(to_char(B.WORK_TIME,''00'')) <:EndTime  '+
                           ' AND B.PROCESS_ID =100266    GROUP BY MODEL_ID )  WHERE TOTAL_PASS<> 0 ) '+
                           '  AND A.MODEL_ID=D.PART_ID  AND D.MODEL_ID = E.MODEL_ID AND (A.PASS_QTY+A.FAIL_QTY)<>0  '+
                           '  AND to_char(A.WORK_DATE)|| TRIM(to_char(A.WORK_TIME,''00''))>=:StartTime   '+
                           '  AND to_char(A.WORK_DATE)|| TRIM(to_char(A.WORK_TIME,''00'')) <:EndTime   '+
                           '  AND A.PROCESS_ID IN (100215,100261)       '+                                
                           '  GROUP BY  E.MODEL_NAME,C.PROCESS_NAME,C.PROCESS_CODE) '+
                           '  ORDER BY  model_name,PROCESS_CODE,total_input ';
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sEndTime;
    QryTemp1.Params.ParamByName('StartPdline').AsString :=  StartPdline;
    QryTemp1.Params.ParamByName('EndPDline').AsString :=    EndPDline;
    QryTemp1.Open;

end;


procedure TuCum.FormCreate(Sender: TObject);
begin

    DateTimePicker1.Date := today;
    DateTimePicker2.Date := tomorrow;

    QryTemp1.RemoteServer := uMainForm.SocketConnection1;
    QryTemp1.ProviderName := 'DspQryTemp1';
    QryTemp2.RemoteServer := uMainForm.SocketConnection1;
    QryTemp2.ProviderName := 'DspQryTemp1';
   

    sbtnQuery.Click;

end;

procedure TuCum.sbtnQueryClick(Sender: TObject);
var i,Process_Count:integer;
begin
    iRecordCount :=0;
    ClearAllCumPanel;
    sStartHour := ComboBox1.Text ;
    sEndHour := ComboBox2.Text ;
    if  StrToInt( ComboBox1.Text) <  10  then  sStartHour  :=  '0'+ComboBox1.Text  ;
    if  StrToInt( ComboBox2.Text) <  10  then  sEndHour  :=  '0'+ComboBox2.Text  ;

    sStartTime  :=  FormatDateTime('yyyymmdd',DateTimePicker1.Date)+  sStartHour   ;
    sEndTime    :=  FormatDateTime('yyyymmdd',DateTimePicker2.Date)+  sEndHour   ;

    QueryOutputAll(QryTemp1,sStartTime,sEndTime,uMainForm.sStartPdline,uMainForm.sEndPdline) ;
    Total_RecordCount := QryTemp1.RecordCount  ;
    iRecordCount := 0;
    QryTemp1.First;
    Model_Count :=1;
    Process_Count :=0;
    sFirstModel :=QryTemp1.fieldByName('Model_Name').AsString;
    TPanel(FindComponent('PanelModel1')).Caption :=sFirstModel;
    TPanel(FindComponent('PanelLine11')).Caption := '全自動測試';
    TPanel(FindComponent('PanelLine12')).Caption := '目檢';
    TPanel(FindComponent('PanelLine13')).Caption := '貼Mylar';
    for i :=0 to QryTemp1.RecordCount-1 do
    begin
         DisplayData;
    end;



end;

procedure TuCum.DisplayData;
var process_count:Integer;
Spy:string;
begin
   if Model_Count <=8 then begin
       sModel :=QryTemp1.fieldByName('Model_Name').AsString;
       sModel :=QryTemp1.fieldByName('Model_Name').AsString;
       if sModel <> sFirstModel then begin
            sFirstModel := sModel;
            Model_Count :=Model_Count+1;
            TPanel(FindComponent('PanelModel'+IntToStr(Model_Count))).Caption :=sModel;
            TPanel(FindComponent('PanelLine'+IntToStr(Model_Count)+IntTOStr(1))).Caption := '全自動測試';
            TPanel(FindComponent('PanelLine'+IntToStr(Model_Count)+IntTOStr(2))).Caption := '目檢';
            TPanel(FindComponent('PanelLine'+IntToStr(Model_Count)+IntTOStr(3))).Caption := '貼Mylar';
       end;
       sProcess := QryTemp1.fieldByName('Process_Name').AsString;

       if sProcess = 'AutoTest' then
       begin
           Process_Count :=1;
       end
       else if  sProcess = 'CM-VI' then
       begin
          Process_Count :=2;
       end
       else if sProcess = 'Mylar' then
       begin
          Process_Count :=3 ;
       end;

       TPanel(FindComponent('PanelInput'+IntToStr(Model_Count)+IntTOStr(Process_Count))).Caption :=
               QryTemp1.fieldByName('Total_input').AsString;
       TPanel(FindComponent('PanelOutput'+IntToStr(Model_Count)+IntTOStr(Process_Count))).Caption :=
               QryTemp1.fieldByName('Total_Pass').AsString;
       Spy :=     QryTemp1.fieldByName('FPY').AsString;
       TPanel(FindComponent('PanelYield'+IntToStr(Model_Count)+IntTOStr(Process_Count))).Caption :=
               Spy +'%';

       if TPanel(FindComponent('PanelYield'+IntToStr(Model_Count)+IntTOStr(Process_Count))).Caption  <>'' then
           if StrToFloatDef(Spy,0)>=98 then
                TPanel(FindComponent('PanelYield'+IntToStr(Model_Count)+IntTOStr(Process_Count))).Color := clGreen
           else if   (StrToFloatDef(Spy,0)>=96 )  and (StrToFloatDef(Spy,0)<98) then
                TPanel(FindComponent('PanelYield'+IntToStr(Model_Count)+IntTOStr(Process_Count))).Color := clYellow
           else if   StrToFloatDef(Spy,0)< 96    then
                 TPanel(FindComponent('PanelYield'+IntToStr(Model_Count)+IntTOStr(Process_Count))).Color := clRed;


       QryTemp1.Next;
       iRecordCount :=iRecordCount+1;
   end;
end;

procedure TuCum.FormKeyPress(Sender: TObject; var Key: Char);
begin
     if Key=#27 then uCum.Close;
end;

procedure TuCum.btnBtNextClick(Sender: TObject);
var i,Process_count,j:Integer;
begin
    ClearAllCumPanel;
    j:= Total_RecordCount-iRecordCount;
    if iRecordCount > Total_RecordCount then
    begin
        iRecordCount :=0;
        QryTemp1.First;
        j:=0;
    end;
    sFirstModel :=QryTemp1.fieldByName('Model_Name').AsString;
    TPanel(FindComponent('PanelModel1')).Caption :=sFirstModel;
    TPanel(FindComponent('PanelLine11')).Caption := '全自動測試';
    TPanel(FindComponent('PanelLine12')).Caption := '目檢';
    TPanel(FindComponent('PanelLine13')).Caption := '貼Mylar';
    Model_Count :=1;
    Process_count :=0;
    QryTemp1.Prior;
    for i:= j to Total_RecordCount-1 do
    begin
         DisplayData;
    end;
end;

end.
