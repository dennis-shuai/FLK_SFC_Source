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
    sbtnQuery: TSpeedButton;
    ImageSample: TImage;
    sBtnExport: TSpeedButton;
    Image1: TImage;
    DataSource1: TDataSource;
    SaveDialog1: TSaveDialog;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    Label3: TLabel;
    cmbModel: TComboBox;
    Label5: TLabel;
    cmbPart_No: TComboBox;
    DBGrid1: TDBGrid;
    Label4: TLabel;
    edtQC_LotNo: TEdit;
    Label1: TLabel;
    DateTimePicker1: TDateTimePicker;
    Label2: TLabel;
    cmbShift: TComboBox;
    Label6: TLabel;
    cmbStatus: TComboBox;
    Label7: TLabel;
    Label8: TLabel;
    cmbStage: TComboBox;
    procedure sbtnQueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmbModelChange(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
     sStartTime, sEndTime, sDStartTime, sDEndTime,sTime1,sTime2 :string;
    function QueryQC( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
  end;

var
  fDetail: TfDetail;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit;

procedure TfDetail.sbtnQueryClick(Sender: TObject);

begin
    if cmbModel.Text='' then Exit;
    if cmbShift.Text='' then Exit;

    if cmbShift.Text='白班' then
    begin
       sDStartTime:=FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+ ' '+'08:00:00';
       sDEndTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date) + ' '+'20:00:00' ;
    end else if cmbShift.Text='晚班' then
    begin
       sDStartTime:=FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+ ' '+'20:00:00';
       sDEndTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date+1) + ' '+'08:00:00' ;

    end else  begin
       sDStartTime:=FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+ ' '+'08:00:00';
       sDEndTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date+1) + ' '+'08:00:00' ;
    end;

    QueryQC(QryData, sDStartTime, sDEndTime);

    if not QryData.IsEmpty then
    begin
        DbGrid1.Columns[0].Width :=100;
        DbGrid1.Columns[1].Width :=100;
        DbGrid1.Columns[2].Width :=100;
        DbGrid1.Columns[3].Width :=140;
    end;
end;

procedure TfDetail.sBtnExportClick(Sender: TObject);
var
  ExcelApp: Variant;
  i,j:Integer;

  Work_Order,Serial_Number:string;
  sDefect_Code1,sDefect_Code2,sSerial_Number:string;

begin
    if QryData.IsEmpty then Exit;
    Try
       //導出excel

       if SaveDialog1.Execute then begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);

        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'QC Query.xltx');
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.WorkSheets[1].Name :=   cmbModel.Text ;
        ExcelApp.Cells[1,1].Value := cmbModel.Text +' OQC檢驗日報表';
        ExcelApp.Cells[3,3].Value := cmbModel.Text;
        ExcelApp.Cells[3,6].Value := QryData.FieldByName('part_no').AsString;
        ExcelApp.Cells[3,9].Value := FormatDateTime('yyyy-mm-dd',DateTimePicker1.Date);
        ExcelApp.Cells[3,14].Value :=cmbShift.Text;




        if not QryData.IsEmpty then
        begin
             QryData.First;
             for  i:=6 to QryData.RecordCount+5  do
             begin
                  ExcelApp.Cells[i,2].Value := QryData.FieldByName('WORK_ORDER').AsString;
                  ExcelApp.Cells[i,3].Value := QryData.FieldByName('LOT_SIZE').AsString;
                  ExcelApp.Cells[i,4].Value := formatdatetime('hh:mm:ss',QryData.FieldByName('end_time').asdatetime);
                  ExcelApp.Cells[i,5].Value := QryData.FieldByName('SAMPLING_SIZE').AsString;
                  ExcelApp.Cells[i,6].Value := QryData.FieldByName('FAIL_QTY').AsString;
                  ExcelApp.Cells[i,7].Value := FloatToStr(((QryData.FieldByName('FAIL_QTY').AsInteger)/(QryData.FieldByName('SAMPLING_SIZE').AsInteger))*100)+'%';

                  ExcelApp.Cells[i,10].Value:=QryData.FieldByName('QC_RESULT').AsString;
                  ExcelApp.Cells[i,12].Value:=QryData.FieldByName('EMP_NAME').AsString;
                  if QryData.FieldByName('QC_RESULT').AsString='NG' then
                  BEGIN
                      ExcelApp.Cells[i,14].Value:='0' ;
                      QryTemp.Close;
                      QryTemp.Params.Clear;

                      QryTemp.Params.CreateParam(ftstring,'QC_LOTNO',ptInput);
                      QryTemp.CommandText:='select a.serial_number,b.defect_code,b.defect_desc,b.defect_desc2 from sajet.g_qc_sn_defect a,sajet.sys_defect b where  a.defect_id=b.defect_id and a.qc_lotno=:QC_LOTNO';

                      QryTemp.Params.ParamByName('QC_LOTNO').AsString := QryData.FieldByName('QC_LOTNO').AsString;
                      QryTemp.Open;
                      if not QryTemp.IsEmpty then
                      begin
                           QryTemp.First;
                           sDefect_Code1:='';
                           sDefect_Code2:='';
                           sSerial_Number:='';
                           for  j:=0 to QryTemp.RecordCount-1  do
                           begin
                              if QryTemp.FieldByName('defect_desc2').AsString='功能' then
                              begin
                                  if sDefect_Code1='' then
                                      sDefect_Code1:= inttostr(j+1) + ':' + QryTemp.FieldByName('defect_code').AsString
                                  else
                                      sDefect_Code1:= sDefect_Code1 + '、' + inttostr(j+1) + ':' + QryTemp.FieldByName('defect_code').AsString;
                              end else begin
                                  if sDefect_Code2='' then
                                      sDefect_Code2:= inttostr(j+1) + ':' + QryTemp.FieldByName('defect_code').AsString
                                  else
                                      sDefect_Code2:= sDefect_Code2 + '、' + inttostr(j+1) + ':' + QryTemp.FieldByName('defect_code').AsString;
                              end;

                              if sSerial_Number='' then
                                  sSerial_Number:= inttostr(j+1) + ':' + QryTemp.FieldByName('serial_number').AsString
                              else
                                  sSerial_Number:= sSerial_Number + '、' + inttostr(j+1) + ':' + QryTemp.FieldByName('serial_number').AsString;
                              QryTemp.Next;
                           end;
                           ExcelApp.Cells[i,8].Value:= sDefect_Code1;
                           ExcelApp.Cells[i,9].Value:= sDefect_Code2;
                           ExcelApp.Cells[i,16].Value:=sSerial_Number;



                           {
                           if QryTemp.FieldByName('defect_desc2').AsString='功能' then
                              ExcelApp.Cells[i,8].Value:= QryTemp.FieldByName('defect_code').AsString
                           else
                              ExcelApp.Cells[i,9].Value:= QryTemp.FieldByName('defect_code').AsString ;

                           ExcelApp.Cells[i,16].Value:= QryTemp.FieldByName('serial_number').AsString ; \
                           }
                      end
                      else begin
                         ExcelApp.Cells[i,8].Value:='';
                         ExcelApp.Cells[i,9].Value:='';
                         ExcelApp.Cells[i,16].Value:='';
                      end;
                  end ELSE BEGIN
                      ExcelApp.Cells[i,14].Value:=QryData.FieldByName('LOT_SIZE').AsString;
                  end;
                  //ExcelApp.Cells[i,17].Value:=QryData.FieldByName('QC_LOTNO').AsString;

                  QryTemp.Close;
                  QryTemp.Params.Clear;
                  QryTemp.Params.CreateParam(ftstring,'QC_LOTNO',ptInput);
                  QryTemp.CommandText:=' select serial_number,Work_Order from sajet.g_qc_sn ' +
                                       ' where qc_lotno=:QC_LOTNO and rownum=1';
                  QryTemp.Params.ParamByName('QC_LOTNO').AsString := QryData.FieldByName('QC_LOTNO').AsString;
                  QryTemp.Open;
                  if not QryTemp.IsEmpty then
                  begin
                      Work_Order:= QryTemp.FieldByName('Work_Order').AsString;
                      Serial_Number:=QryTemp.FieldByName('Serial_Number').AsString;
                  end else begin
                     Work_Order:='';
                     Serial_Number:='';
                  end;

                  QryTemp.Close;
                  QryTemp.Params.Clear;

                  QryTemp.Params.CreateParam(ftstring,'WORK_ORDER',ptInput);
                  QryTemp.Params.CreateParam(ftstring,'serial_number',ptInput);

                  QryTemp.CommandText:='select f.pdline_name from sajet.g_sn_travel e,sajet.sys_pdline f  '
                                     + 'where serial_number=:serial_number and  process_id in '
                                     + '( '
                                     + 'SELECT C.PROCESS_ID FROM SAJET.G_WO_BASE A,SAJET.SYS_ROUTE B,SAJET.SYS_ROUTE_DETAIL C,SAJET.SYS_PROCESS D '
                                     + 'WHERE A.ROUTE_ID=B.ROUTE_ID AND B.ROUTE_ID=C.ROUTE_ID AND C.PROCESS_ID=D.PROCESS_ID '
                                     + 'AND WORK_ORDER=:WORK_ORDER AND NEXT_PROCESS_ID=100215 AND C.NECESSARY='+'''Y''' 
                                     + ')'
                                     + ' and e.pdline_id=f.pdline_id'
                                     + ' order by OUT_PROCESS_TIME DESC ';

                  QryTemp.Params.ParamByName('WORK_ORDER').AsString :=WORK_ORDER;
                  QryTemp.Params.ParamByName('serial_number').AsString :=serial_number;
                  QryTemp.Open;
                  if not QryTemp.IsEmpty then begin
                     QryTemp.First;
                     ExcelApp.Cells[i,1].Value:= QryTemp.FieldByName('PDLINE_NAME').AsString;
                  end
                  else
                     ExcelApp.Cells[i,1].Value:='';

                  ExcelApp.ActiveSheet.Range['A'+IntToStr(i)+':P'+IntToStr(i)].Borders[1].Weight   :=   2;
                  ExcelApp.ActiveSheet.Range['A'+IntToStr(i)+':P'+IntToStr(i)].Borders[2].Weight   :=   2;
                  ExcelApp.ActiveSheet.Range['A'+IntToStr(i)+':P'+IntToStr(i)].Borders[3].Weight   :=   2;
                  ExcelApp.ActiveSheet.Range['A'+IntToStr(i)+':P'+IntToStr(i)].Borders[4].Weight   :=   2;

                  QryData.Next;
             end;
        end;
       ExcelApp.WorkSheets[1].Activate;
       ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
       ExcelApp.Quit;
       MessageDlg('Save OK',mtConfirmation,[mbyes],0);
       end;
    finally

    end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var i:integer;
begin
   DateTimePicker1.Date :=  Now;
    //DateTimePicker2.Date :=  tomorrow;
    cmbStage.Style := csDropDownList;
    cmbModel.Style := csDropDownList;
    cmbShift.Style := csDropDownList;
    cmbStatus.Style := csDropDownList;
    
    qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Commandtext := 'select distinct (model_Name) MOdel from sajet.sys_model where Enabled=''Y'' ';
    qrytemp.Open;
    qrytemp.First;
    cmbModel.Items.Add('All') ;
    for i:=0 to qrytemp.recordcount-1 do begin
       cmbModel.Items.Add(qrytemp.fieldbyname('model').asstring) ;
       qrytemp.Next;
    end;
end;

procedure TfDetail.cmbModelChange(Sender: TObject);
var i:Integer;
begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'Model_Name',ptInput);
    //QryTemp.Params.CreateParam(ftstring,'Model_Name',ptInput);
    QryTemp.CommandText:='SELECT Part_No from sajet.sys_Part a,sajet.sys_Model b ' +
                         ' WHERE a.Model_ID=b.Model_ID and b.Model_Name=:Model_Name' +
                         ' order by Part_No';
    QryTemp.Params.ParamByName('Model_Name').AsString := cmbModel.Text;
    //QryTemp.Params.ParamByName('Stage_Name').AsString := cmbStage.Items.Strings[cmbStage.ItemIndex];
    QryTemp.Open;
    cmbPart_No.Clear;
    if not QryTemp.IsEmpty then
       for  i:=0 to QryTemp.RecordCount-1  do
       begin
          cmbPart_No.Items.Add(QryTemp.FieldByName('Part_No').AsString);
          QryTemp.Next;
       end;


end;

function TfDetail.QueryQC(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
var sModel:string;
begin

    sModel :=cmbModel.Items.Strings[cmbModel.ItemIndex];
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.CommandText:='';
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    if sModel <>'All' then
        QryTemp1.Params.CreateParam(ftstring,'Model_Name',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'QC_LOTNO',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Stage',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'QC_RESULT',ptInput);
    QryTemp1.CommandText:=' select A.WORK_ORDER,b.model_name,C.PART_NO,a.QC_LOTNO,a.LOT_SIZE,a.SAMPLING_SIZE, ' +
                          ' a.PASS_QTY,A.FAIL_QTY, '+
                          ' DECODE (A.QC_RESULT,1,'+ '''NG'''+','+'''PASS'''+') as QC_RESULT,E.EMP_NAME,a.START_TIME,a.end_time' +
                          ' from SAJET.G_QC_LOT a,sajet.sys_model b,sajet.sys_part c ,SAJET.SYS_PDLINE d,SAJET.SYS_EMP e ,sajet.sys_stage f ' +
                          ' WHERE  a.model_id=c.part_id and b.model_id=c.model_id and d.PDLINE_ID=A.PDLINE_ID and A.INSP_EMPID=E.EMP_ID'+
                          ' and f.stage_name =:stage and a.stage_id=f.stage_id '+
                          ' and a.QC_RESULT<>'+ '''N/A''  ' +
                          ' and a.end_time>=to_date(:StartTime,'+'''yyyy-mm-dd hh24:mi:ss'''+ ') '  +
                          ' and a.end_time<to_date(:EndTime,' + '''yyyy-mm-dd hh24:mi:ss'''+ ') ' ;
    if sModel <>'All' then
      QryTemp1.CommandText := QryTemp1.CommandText+ ' and b.Model_Name=:Model_Name';


    if cmbPart_No.text<>'' then
    begin
       QryTemp1.CommandText:=QryTemp1.CommandText + ' and c.Part_No=:Part_No ' ;
       QryTemp1.Params.ParamByName('Part_No').AsString :=   cmbPart_No.Text;
    end;

    if edtQC_LotNo.Text<>'' then
    BEGIN
       QryTemp1.CommandText:=QryTemp1.CommandText + ' and A.QC_LOTNO=:QC_LOTNO ' ;
       QryTemp1.Params.ParamByName('QC_LOTNO').AsString := edtQC_LotNo.Text;
    end;
    IF cmbStatus.text='PASS' THEN
    BEGIN
       QryTemp1.CommandText:=QryTemp1.CommandText + ' AND QC_RESULT=:QC_RESULT  ' ;
       QryTemp1.Params.ParamByName('QC_RESULT').AsString := '0';
    end else
    IF cmbStatus.text='NG' THEN
    BEGIN
       QryTemp1.CommandText:=QryTemp1.CommandText + ' AND QC_RESULT=:QC_RESULT  ' ;
       QryTemp1.Params.ParamByName('QC_RESULT').AsString := '1';
    end ;
    
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sEndTime;
    if sModel <>'All' then
        QryTemp1.Params.ParamByName('Model_Name').AsString :=   sModel;
    QryTemp1.Params.ParamByName('Stage').AsString :=   cmbStage.Items.Strings[cmbStage.ItemIndex];
    QryTemp1.Open;
end;

end.
