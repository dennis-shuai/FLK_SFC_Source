unit uDetail;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids,DateUtils;

type
  TfDetail = class(TForm)
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
    SaveDialog1: TSaveDialog;
    Label2: TLabel;
    DateTimePicker2: TDateTimePicker;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    edtPartNo: TEdit;
    Label5: TLabel;
    Label3: TLabel;
    edtRTNo: TEdit;
    procedure sbtnQueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID : String;
    Count:Integer;
    UpDate_Time :TDateTime;
    sStartTime, sEndTime,sTime1,sTime2 :string;

  end;

var
  fDetail: TfDetail;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
begin
    if length(ComboBox1.Text)=1  then  sTime1 := '0' + ComboBox1.Text
    else  sTime1 := ComboBox1.Text;

    if length(ComboBox2.Text)=1  then  sTime2 := '0' + ComboBox2.Text
    else  sTime2 := ComboBox2.Text;

    sStartTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+ ' '+ sTime1+':00:00'  ;
    sEndTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker2.Date) + ' ' + sTime2 +':00:00' ;

    with QryData do
    begin
         close;
         params.Clear;
         params.CreateParam(ftstring,'PARTNO',ptInput);
         params.CreateParam(ftstring,'RTNO',ptInput);
         params.CreateParam(ftstring,'startTime',ptInput);
         params.CreateParam(ftstring,'endTime',ptInput);
         commandtext :='SELECT A.RT_NO,B.INCOMING_QTY,B.DATECODE,C.PART_NO,D.VENDOR_NAME,E.REMARK, '+
                       ' E.LOT_SIZE,E.SAMPLE_SIZE,E.PASS_QTY,E.FAIL_QTY,DECODE(E.QC_RESULT,0,''PASS'',1,''REJECT'',2,''WAVIE'') QC_RESULT, '+
                       ' H.EMP_NAME,G.SAMPLING_TYPE,B.MFGER_NAME,B.MFGER_PART_NO,E.START_TIME,H.UPDATE_TIME   '+
                       ' from sajet.G_ERP_RTNO A,SAJET.G_ERP_RT_ITEM B,SAJET.SYS_PART C,SAJET.SYS_VENDOR D,SAJET.G_IQC_LOT E, '+
                       ' SAJET.SYS_EMP H,SAJET.SYS_QC_SAMPLING_PLAN G '+//',SAJET.G_IQC_DEFECT H '+
                       ' WHERE A.RT_NO LIKE :RTNO AND A.RT_ID=B.RT_ID AND C.PART_ID =B.PART_ID AND D.VENDOR_ID=A.VENDOR_ID AND E.LOT_NO =A.RT_NO  '+
                       ' AND  E.EMP_ID=H.EMP_ID AND G.SAMPLING_ID=E.SAMPLING_ID AND C.PART_NO LIKE :PARTNO ' +
                      // ' AND E.LOT_NO =H.LOT_NO(+) AND E.START_TIME =H.UPDATE_TIME(+) '+
                       ' AND E.Start_Time >= TO_DATE(:STARTTIME,''YYYY/MM/DD HH24:MI:SS'') AND E.Start_Time < TO_DATE(:ENDTIME,''YYYY/MM/DD HH24:MI:SS'')';
         params.ParamByName('RTNO').AsString :=edtRTNo.Text + '%';
         params.ParamByName('PARTNO').AsString :=edtPartNo.Text + '%';
         params.ParamByName('startTime').AsString :=sStartTime;
         params.ParamByName('endTime').AsString :=sEndTime;
         open;
    end;


    
    
end;

procedure TfDetail.sBtnExportClick(Sender: TObject);
var
     strDefect:string;
     i,j:integer;
     ExcelApp: Variant;
begin
    if SaveDialog1.Execute then begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);

        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'IQC Inspection Report.xltx');
        ExcelApp.WorkSheets[1].Activate;

        ExcelApp.Cells[2,2].Value := sStartTime;
        ExcelApp.Cells[2,7].Value := sEndTime;

        i:=0;

        if not QryData.IsEmpty then
        begin
             QryData.First;
             for  i:=4 to QryData.RecordCount+3  do
             begin
                  ExcelApp.Cells[i,1].Value := QryData.FieldByName('RT_NO').AsString;
                  ExcelApp.Cells[i,2].Value := QryData.FieldByName('Vendor_Name').AsString;
                  ExcelApp.Cells[i,3].Value := QryData.FieldByName('Part_NO').AsString;
                  ExcelApp.Cells[i,4].Value := QryData.FieldByName('Mfger_Name').AsString;
                  ExcelApp.Cells[i,5].Value := QryData.FieldByName('Mfger_Part_No').AsString;
                  ExcelApp.Cells[i,6].Value := QryData.FieldByName('Sampling_Type').AsString;
                  ExcelApp.Cells[i,7].Value :=  QryData.FieldByName('InComing_Qty').AsString;
                  ExcelApp.Cells[i,8].Value :=  QryData.FieldByName('Lot_Size').AsString;
                  ExcelApp.Cells[i,9].Value :=  QryData.FieldByName('Sample_Size').AsString;
                  ExcelApp.Cells[i,10].Value :=  QryData.FieldByName('Pass_Qty').AsString;
                  ExcelApp.Cells[i,11].Value :=  QryData.FieldByName('Fail_Qty').AsString;

                  ExcelApp.Cells[i,12].Value :=  QryData.FieldByName('Start_time').AsString;
                  ExcelApp.Cells[i,13].Value :=  QryData.FieldByName('Emp_NAme').AsString;
                  //ExcelApp.Cells[i,14].Value :=  QryData.FieldByName('Remark').AsString;
                  if QryData.FieldByName('Fail_Qty').AsString <> '0' then begin
                      QryDefect.Close;
                      QryDefect.Params.Clear;
                      QryDefect.Params.CreateParam(ftString,'rtno',ptInput);
                      QryDefect.CommandText :=' SELECT A.START_TIME,C.PART_NO,D.DEFECT_DESC,SUM(B.NG_CNT) NG_COUNT ,A.START_TIME '+
                                              ' FROM SAJET.G_IQC_LOT A,SAJET.G_IQC_DEFECT B,SAJET.SYS_PART C,SAJET.SYS_DEFECT D '+
                                              ' WHERE A.LOT_NO=B.LOT_NO AND A.PART_ID=C.PART_ID AND B.DEFECT_ID=D.DEFECT_ID AND A.LOT_NO =:RTNO '+
                                              ' AND A.START_TIME =B.INSP_TIME '+
                                              ' GROUP BY A.START_TIME,C.PART_NO,D.DEFECT_DESC ';
                      QryDefect.Params.ParamByName('rtno').AsString := QryData.FieldByName('RT_NO').AsString;
                      QryDefect.Open;
                      if not  QryDefect.IsEmpty then begin
                         QryDefect.First;
                         strDefect :='';
                         for j:=0 to QryDefect.RecordCount-1  do begin
                             if QryDefect.FieldByName('START_TIME').AsString =  ExcelApp.Cells[i,12].Value then
                                strDefect := strDefect+QryDefect.fieldbyname('DEFECT_DESC').AsString +':'+QryDefect.fieldbyname('NG_COUNT').AsString +#13;
                              QryDefect.Next;
                         end;
                         if  QryData.FieldByName('Remark').AsString <> '' then
                             ExcelApp.Cells[i,14].Value :=  QryData.FieldByName('Remark').AsString + '('+strDefect+')'
                         else
                             ExcelApp.Cells[i,14].Value := strDefect;

                      end;

                  end;
                  QryData.Next;

             end;
        end;


       ExcelApp.ActiveSheet.Range['A4:F'+IntToStr(i-1)].Borders[1].Weight := 2;
       ExcelApp.ActiveSheet.Range['A4:N'+IntToStr(i-1)].Borders[2].Weight := 2;
       ExcelApp.ActiveSheet.Range['A4:N'+IntToStr(i-1)].Borders[3].Weight := 2;
       ExcelApp.ActiveSheet.Range['A4:N'+IntToStr(i-1)].Borders[4].Weight := 2;
       ExcelApp.ActiveSheet.Range['A4:N'+IntToStr(i-1)].HorizontalAlignment :=3;
       ExcelApp.ActiveSheet.Range['A4:N'+IntToStr(i-1)].Font.Name :='Tohama';

       ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
       ExcelApp.Quit;
       MessageDlg('Save OK',mtConfirmation,[mbyes],0);

    end;
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
    DateTimePicker1.Date :=  Now;
    DateTimePicker2.Date :=  tomorrow;

end;

end.
