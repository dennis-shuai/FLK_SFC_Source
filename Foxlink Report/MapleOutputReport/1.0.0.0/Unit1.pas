unit Unit1;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids;

type
  TForm1 = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    lblLabTitle1: TLabel;
    lblLabTitle2: TLabel;
    DateTimePicker1: TDateTimePicker;
    Label1: TLabel;
    sbtnQuery: TSpeedButton;
    ImageSample: TImage;
    sBtnExport: TSpeedButton;
    Image1: TImage;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Label3: TLabel;
    cmbModel: TComboBox;
    SaveDialog1: TSaveDialog;
    procedure sbtnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID : String;
    Count:Integer;
    UpDate_Time :TDateTime;
    function QueryOutputByPDLine( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
    function QueryOutput( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;

  end;

var
  Form1: TForm1;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit;

procedure TForm1.sbtnQueryClick(Sender: TObject);
var
    sStartTime,sEndTime ,swStartTime,swEndTime,sDStartTime,sDEndTime,sNStartTime,sNEndTime:string;
begin
    sStartTime := FormatDateTime('yyyymmdd',DateTimePicker1.Date)+'08';
    sEndTime := FormatDateTime('yyyymmdd',DateTimePicker1.Date+1)+'08';

    QueryOutputByPDLine(QryData, sStartTime, sEndTime);
    
end;

function TForm1.QueryOutputByPDLine( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    //QryTemp1.Params.CreateParam(ftstring,'Model',ptInput);
    QryTemp1.CommandText:=' select  a.pdLine_NAME,B.PROCESS_NAME, B.PROCESS_CODE, '+
                         ' DECODE((SUM(C.OUTPUT_QTY)), NULL, 0, (SUM(C.OUTPUT_QTY))) OUTPUT_QTY  '+
                        // ' DECODE((SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.FAIL_QTY))) FAIL_QTY, '+
                        // ' DECODE((SUM(C.PASS_QTY) -SUM(C.REPASS_QTY)), NULL, 0, (SUM(C.PASS_QTY) -SUM(C.REPASS_QTY))) FPY_QTY, '+
                        // ' DECODE((SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY))) TOTAL_QTY   '+
                         ' FROM   sajet.sys_pdline a  ,SAJET.SYS_PROCESS B ,  ' +
                         ' (select WORK_ORDER,MODEL_ID,PDLINE_ID,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REFAIL_QTY,OUTPUT_QTY,NTF_QTY,to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime  '+
                         ' from SAJET.G_SN_COUNT) C ,sajet.sys_part d ' +
                         ' WHERE   C.DateTime >=:StartTime and C.DateTime <:endTime   AND a.pdline_ID =c.PDLINE_ID AND c.WORK_ORDER NOT Like ''RM%'' and'+
                         ' c.model_ID =d.Part_ID and d.Part_no in( ''7690-3368-0071'',''7690-3368-0171'',''7690-3368-0271'',''7690-3368-0371'' ) and'+
                         ' C.PROCESS_ID = B.PROCESS_ID GROUP BY a.pdLine_NAME,B.PROCESS_NAME, B.PROCESS_CODE ORDER BY B.PROCESS_CODE ';
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sEndTime;
    //QryTemp1.Params.ParamByName('Model').AsString := cmbModel.Text;
    QryTemp1.Open;
end;

function TForm1.QueryOutput(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
   // QryTemp1.Params.CreateParam(ftstring,'Model',ptInput);
    QryTemp1.CommandText:=' select B.PROCESS_NAME, B.PROCESS_CODE, '+
                         ' DECODE((SUM(C.OUTPUT_QTY)), NULL, 0, (SUM(C.OUTPUT_QTY))) OUTPUT_QTY  '+
                         //' DECODE((SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.FAIL_QTY))) FAIL_QTY, '+
                         //' DECODE((SUM(C.PASS_QTY) -SUM(C.REPASS_QTY)), NULL, 0, (SUM(C.PASS_QTY) -SUM(C.REPASS_QTY))) FPY_QTY, '+
                        // ' DECODE((SUM(C.PASS_QTY) +SUM(C.FAIL_QTY)), NULL, 0, (SUM(C.PASS_QTY) +SUM(C.FAIL_QTY))) TOTAL_QTY   '+
                         ' FROM   SAJET.SYS_PROCESS B ,  ' +
                         ' (select WORK_ORDER,MODEL_ID,PDLINE_ID,PROCESS_ID,PASS_QTY,FAIL_QTY,REPASS_QTY,REFAIL_QTY,OUTPUT_QTY,NTF_QTY,' +
                         ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) as  DateTime  '+
                         ' from SAJET.G_SN_COUNT) C ,sajet.sys_part d ' +
                         ' WHERE   C.DateTime >=:StartTime and C.DateTime <:endTime   AND c.WORK_ORDER NOT Like ''RM%'' AND '+
                         ' c.model_ID =d.Part_ID and d.Part_no in( ''7690-3368-0071'',''7690-3368-0171'',''7690-3368-0271'',''7690-3368-0371'' ) and'+
                         ' C.PROCESS_ID = B.PROCESS_ID GROUP BY B.PROCESS_NAME, B.PROCESS_CODE ORDER BY B.PROCESS_CODE ';
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString := sEndTime;
    //QryTemp1.Params.ParamByName('Model').AsString := cmbModel.Text;
    QryTemp1.Open;
end;

procedure TForm1.FormShow(Sender: TObject);
   var i:integer;
begin
   // cmbModel.Text :='Maple-CM';
    QryTemp.Close;
    QryTemp.CommandText:=' select distinct(Model_NAME) from sajet.sys_model where enabled=''Y'' ';
    QryTemp.Open;
    cmbModel.Items.Clear;
    QryTemp.First;
    for i:=0  to QryTemp.RecordCount-1 do
    begin
       cmbModel.Items.Add( QryTemp.FieldByName('Model_NAME').AsString);
       QryTemp.Next;
    end;
    DateTimePicker1.Date := Now;

end;

procedure TForm1.sBtnExportClick(Sender: TObject);
var
    sDStartTime,sDEndTime, sNStartTime,sNEndTime :string;
    swStartTime,swEndTime,strTitle,strOutput,strPDline,strPDLineFrist :string;
    i,LineCount,UsedRow,j:integer;
    ExcelApp: Variant;
begin
    if  SaveDialog1.Execute then begin
        sDStartTime := FormatDateTime('yyyymmdd',DateTimePicker1.Date)+'08';
        sDEndTime := FormatDateTime('yyyymmdd',DateTimePicker1.Date)+'20';
        sNStartTime  :=  sDEndTime;
        sNEndTime    := FormatDateTime('yyyymmdd',DateTimePicker1.Date+1)+'08';

        swStartTime := FormatDateTime('yyyy/mm/dd ',DateTimePicker1.Date)+'08:00:00';
        swEndTime    := FormatDateTime('yyyy/mm/dd ',DateTimePicker1.Date+1)+'08:00:00';

        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'\SFC Output Report.xlt');
        ExcelApp.WorkSheets[1].Activate;

        ExcelApp.Cells[2,2].Value := swStartTime;
        ExcelApp.Cells[2,5].Value := swEndTime;
        QueryOutput(QryTemp, sDStartTime,  sDEndTime);
        if not QryTemp.IsEmpty then
        begin
             QryTemp.First;
             for  i:=0 to QryTemp.RecordCount-1  do
             begin

                  strTitle :=QryTemp.FieldByName('PROCESS_NAME').AsString ;
                  strOutput :=  QryTemp.FieldByName('OUTPUT_QTY').AsString;

                  if  strTitle= 'AOO' then
                    ExcelApp.Cells[6,2].Value := strOutput;

                  if  strTitle = 'FF' then
                    ExcelApp.Cells[6,4].Value :=  strOutput;

                  if  strTitle = 'FQC' then
                    ExcelApp.Cells[6,6].Value :=  strOutput;

                  if  strTitle = 'CM-PACK-BOX' then
                    ExcelApp.Cells[6,8].Value := strOutput;

                  if  strTitle = 'OQC' then
                    ExcelApp.Cells[7,10].Value :=  strOutput;

                  if  strTitle = 'CM-PACK-PALLET' then
                    ExcelApp.Cells[8,12].Value := strOutput;

                  QryTemp.Next;
             end;
        end;

        QueryOutput(QryTemp, sNStartTime,  sNEndTime);
        if not QryTemp.IsEmpty then
        begin
             QryTemp.First;
             for  i:=0 to QryTemp.RecordCount-1  do
             begin

                  strTitle :=QryTemp.FieldByName('PROCESS_NAME').AsString ;
                  strOutput :=  QryTemp.FieldByName('OUTPUT_QTY').AsString;

                  if  strTitle= 'AOO' then
                    ExcelApp.Cells[6,3].Value := strOutput;

                  if  strTitle = 'FF' then
                    ExcelApp.Cells[6,5].Value :=  strOutput;

                  if  strTitle = 'FQC' then
                    ExcelApp.Cells[6,7].Value :=  strOutput;

                  if  strTitle = 'CM-PACK-BOX' then
                    ExcelApp.Cells[6,9].Value := strOutput;

                  if  strTitle = 'OQC' then
                    ExcelApp.Cells[7,11].Value :=  strOutput;

                   if  strTitle = 'CM-PACK-PALLET' then
                    ExcelApp.Cells[8,13].Value := strOutput;
                  QryTemp.Next;
             end;
        end;

    
      ExcelApp.WorkSheets['Detail Output Report'].Activate;
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.CommandText :=' SELECT DISTINCT PDLINE_NAME  '+
                            ' FROM (select b.PDLINE_NAME,a.* from  sajet.sys_pdline b , '  +
                            ' (select TO_NUMBER( TO_CHAR(WORK_DATE)||TRIM(TO_CHAR(WORK_TIME,''00''))) '   +
                            ' AS DATETIME,WORK_ORDER,WORK_DATE,WORK_TIME,PDLINE_ID ,PASS_QTY,FAIL_QTY,NTF_QTY,OUTPUT_QTY ' +
                            ' FROM SAJET.G_SN_COUNT) a  '+
                            ' where a.PDLINE_ID =b.PDLINE_ID and  a.dateTIME >='+sDStartTime +' and   a.dateTIME <'+ sNEndTime +  ' and '+
                            ' a.WORK_ORDER not like ''RM%'' and b.PDLINE_NAME like ''CM%''  and b.PDLINE_NAME not like ''CM-%'' )  '+
                            ' ORDER BY PDLINE_NAME ';
      QryTemp.Open;
      if not QryTemp.IsEmpty then begin
          lineCount :=    QryTemp.RecordCount;
          QryTemp.First ;
          for i:=0 to   lineCount -1 do begin
              ExcelApp.Cells[i+2,1].Value :=QryTemp.FieldByName('PDLINE_NAME').AsString   ;
              QryTemp.Next;
          end;


          QueryOutputByPDLine(QryTemp,sDStartTime,sNEndTime);

          if  not  QryTemp.IsEmpty then begin

                QryTemp.First;
                for  i:=0 to QryTemp.RecordCount-1  do
                begin
                     strPDLine :=QryTemp.FieldByName('PDLINE_NAME').AsString ;
                     strTitle :=QryTemp.FieldByName('PROCESS_NAME').AsString ;
                     strOutput :=  QryTemp.FieldByName('OUTPUT_QTY').AsString;

                     for j:=0 to lineCount-1 do begin

                       if  strPDLine  =   ExcelApp.Cells[2+j,1].Value  then
                       begin
                            if  strTitle= 'AOO' then
                            begin
                                ExcelApp.Cells[2+j,2].Value := strOutput;
                            end;

                            if  strTitle= 'FF' then
                            begin
                                ExcelApp.Cells[2+j,3].Value := strOutput;
                            end;

                            if  strTitle= 'FQC' then
                            begin
                                 ExcelApp.Cells[2+j,4].Value := strOutput;
                            end;
                        end;
                    end;

                    QryTemp.Next;
               end;
        end;

      ExcelApp.ActiveSheet.Range['A1:D'+IntToStr(lineCount+1)].Borders[1].Weight := 2;
      ExcelApp.ActiveSheet.Range['A1:D'+IntToStr(lineCount+1)].Borders[2].Weight := 2;
      ExcelApp.ActiveSheet.Range['A1:D'+IntToStr(lineCount+1)].Borders[3].Weight := 2;
      ExcelApp.ActiveSheet.Range['A1:D'+IntToStr(lineCount+1)].Borders[4].Weight := 2;
      ExcelApp.ActiveSheet.Range['A1:D'+IntToStr(lineCount+1)].HorizontalAlignment :=3;
      
      ExcelApp.WorkSheets[1].Activate;
       if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);
            ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
      end;

     ExcelApp.Quit;
     MessageDlg('Save OK',mtConfirmation,[mbyes],0);

    end;

end;

end.
