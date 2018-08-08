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
    //if cmbModel.Text='' then Exit;
    if cmbShift.Text='' then Exit;

    if cmbShift.Text='¥Õ¯Z' then
    begin
       sDStartTime:=FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+ ' '+'08:00:00';
       sDEndTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date) + ' '+'20:00:00' ;
    end else if cmbShift.Text='±ß¯Z' then
    begin
       sDStartTime:=FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+ ' '+'20:00:00';
       sDEndTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date+1) + ' '+'08:00:00' ;

    end else
    begin
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
  i:Integer;
  Serial_Number,sDesc,sDesc2,sTemp:string;
begin
    if QryData.IsEmpty then Exit;
    Try
       //Œ§³öexcel

       if SaveDialog1.Execute then begin
            if FileExists(SaveDialog1.FileName) then
               DeleteFile(SaveDialog1.FileName);

            ExcelApp :=CreateOleObject('Excel.Application');
            ExcelApp.Visible :=false;
            ExcelApp.displayAlerts:=false;
            ExcelApp.WorkBooks.Open(ExtractFilePath(ParamStr(0))+'QC Query.xltx');
            ExcelApp.WorkSheets[1].Activate;
            if  cmbModel.Text ='' then
               ExcelApp.WorkSheets[1].Name :=   'All QC Record' 
            else
               ExcelApp.WorkSheets[1].Name :=   cmbModel.Text ;
            ExcelApp.Cells[1,1].Value := cmbModel.Text +' OQC ÀËÅç¤é³øªí';
            ExcelApp.Cells[3,4].Value := cmbModel.Text;
            //ExcelApp.Cells[3,7].Value := QryData.FieldByName('part_no').AsString;
            ExcelApp.Cells[3,10].Value := FormatDateTime('yyyy-mm-dd',DateTimePicker1.Date);
            ExcelApp.Cells[3,15].Value :=cmbShift.Text;
            ExcelApp.Cells[4,1].Value :='¾÷ºØ¦W';
            if not QryData.IsEmpty then
            begin
                 QryData.First;
                 for  i:=6 to QryData.RecordCount+5  do
                 begin
                      ExcelApp.Cells[i,1].Value:= QryData.FieldByName('Model_Name').AsString;
                      ExcelApp.Cells[i,2].Value := QryData.FieldByName('WORK_ORDER').AsString;
                      ExcelApp.Cells[i,3].Value := QryData.FieldByName('Target_Qty').AsString;
                      ExcelApp.Cells[i,4].Value := QryData.FieldByName('LOT_SIZE').AsString;
                      ExcelApp.Cells[i,5].Value := formatdatetime('hh:mm:ss',QryData.FieldByName('end_time').asdatetime);
                      ExcelApp.Cells[i,6].Value := QryData.FieldByName('SAMPLING_SIZE').AsString;
                      ExcelApp.Cells[i,7].Value := QryData.FieldByName('FAIL_QTY').AsString;
                      ExcelApp.Cells[i,8].Value := FloatToStr(((QryData.FieldByName('FAIL_QTY').AsInteger)/(QryData.FieldByName('SAMPLING_SIZE').AsInteger))*100)+'%';

                      ExcelApp.Cells[i,11].Value:=QryData.FieldByName('QC_RESULT').AsString;
                      ExcelApp.Cells[i,13].Value:=QryData.FieldByName('EMP_NAME').AsString;
                      if QryData.FieldByName('QC_RESULT').AsString='NG' then
                      BEGIN
                          ExcelApp.Cells[i,15].Value:='0' ;
                          QryTemp.Close;
                          QryTemp.Params.Clear;

                          QryTemp.Params.CreateParam(ftstring,'QC_LOTNO',ptInput);
                          QryTemp.CommandText:='select a.serial_number,b.defect_code,b.defect_desc,b.defect_desc2 '+
                                               ' from sajet.g_qc_sn_defect a,sajet.sys_defect b where  a.defect_id=b.defect_id '+
                                               ' and a.qc_lotno=:QC_LOTNO    ';

                          QryTemp.Params.ParamByName('QC_LOTNO').AsString := QryData.FieldByName('QC_LOTNO').AsString;
                          QryTemp.Open;
                          QryTemp.first;
                          while not QryTemp.eof do
                          begin
                             sDesc2 :=QryTemp.FieldByName('defect_desc2').AsString ;
                             Serial_Number :=QryTemp.FieldByName('serial_number').AsString;
                             sDesc :=  QryTemp.FieldByName('defect_desc').AsString ;

                             if sDesc2='¥\¯à' then  begin
                                 sTemp := ExcelApp.Cells[i,9].Value;
                                 ExcelApp.Cells[i,9].Value := sTemp+#10#13+Serial_Number+' '+ sDesc;
                             end
                             else begin
                                 sTemp := ExcelApp.Cells[i,10].Value;
                                ExcelApp.Cells[i,10].Value:= ExcelApp.Cells[i,8].Value+#10#13+Serial_Number+' '+ sDesc;
                             end;
                             //ExcelApp.Cells[i,17].Value:= ExcelApp.Cells[i,17].Value +#10#13+QryTemp.FieldByName('serial_number').AsString ;
                             QryTemp.next;
                          end;
                          //else
                           //  ExcelApp.Cells[i,9].Value:='';
                      end else begin
                          ExcelApp.Cells[i,15].Value:=QryData.FieldByName('LOT_SIZE').AsString;
                      end;
                      //ExcelApp.Cells[i,17].Value:=QryData.FieldByName('QC_LOTNO').AsString;


                      ExcelApp.ActiveSheet.Range['A1:Q'+IntToStr(i)].Borders[1].Weight   :=   2;
                      ExcelApp.ActiveSheet.Range['A1:Q'+IntToStr(i)].Borders[2].Weight   :=   2;
                      ExcelApp.ActiveSheet.Range['A1:Q'+IntToStr(i)].Borders[3].Weight   :=   2;
                      ExcelApp.ActiveSheet.Range['A1:Q'+IntToStr(i)].Borders[4].Weight   :=   2;
                      ExcelApp.ActiveSheet.Range['A1:Q'+IntToStr(i)].HorizontalAlignment :=3;
                      ExcelApp.ActiveSheet.Range['A1:Q'+IntToStr(i)].VerticalAlignment :=2;

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
    cmbModel.Style := csDropDownList;
    cmbShift.Style := csDropDownList;
    cmbStatus.Style := csDropDownList;
    cmbPart_No.Style := csDropDownList;
    cmbStage.Style := csDropDownList;
    qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Commandtext := 'select distinct (model_Name) MOdel from sajet.sys_model where Enabled=''Y'' order by model_name ';
    qrytemp.Open;
    qrytemp.First;
    cmbModel.Items.Add('All');
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
    QryTemp.CommandText:='SELECT Part_No from sajet.sys_Part a,sajet.sys_Model b' +
                         ' WHERE a.Model_ID=b.Model_ID and b.Model_Name=:Model_Name' +
                         ' and A.PART_NO LIKE ''7690-%''' +
                         ' order by Part_No';
    QryTemp.Params.ParamByName('Model_Name').AsString := cmbModel.Text;
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
    QryTemp1.CommandText:=' select  A.WORK_ORDER,g.target_qty,b.model_name,C.PART_NO,a.QC_LOTNO,a.LOT_SIZE,a.SAMPLING_SIZE, ' +
                          ' a.PASS_QTY,A.FAIL_QTY, '+
                          ' DECODE (A.QC_RESULT,1,'+ '''NG'''+','+'''PASS'''+') as QC_RESULT,E.EMP_NAME,a.START_TIME,a.end_time' +
                          ' from SAJET.G_QC_LOT a,sajet.sys_model b,sajet.sys_part c ,SAJET.SYS_PDLINE d,SAJET.SYS_EMP e ,sajet.sys_stage f,sajet.g_wo_base g ' +
                          ' WHERE  a.model_id=c.part_id and b.model_id=c.model_id and d.PDLINE_ID=A.PDLINE_ID and A.INSP_EMPID=E.EMP_ID'+
                          ' and f.stage_name =:stage and a.stage_id=f.stage_id '+
                          ' and a.QC_RESULT<>'+ '''N/A'' and a.work_order=g.work_order ' +
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
     QryTemp1.CommandText:=QryTemp1.CommandText + ' order by b.model_name,a.START_TIME  ' ;
    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sEndTime;
    if sModel <>'All' then
        QryTemp1.Params.ParamByName('Model_Name').AsString :=   sModel;
    QryTemp1.Params.ParamByName('Stage').AsString :=   cmbStage.Items.Strings[cmbStage.ItemIndex];
    QryTemp1.Open;
end;

end.
