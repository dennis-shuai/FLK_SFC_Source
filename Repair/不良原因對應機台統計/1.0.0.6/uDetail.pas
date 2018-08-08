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
    QryTemp1: TClientDataSet;
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
    QryTemp2: TClientDataSet;
    DataSource2: TDataSource;
    Label7: TLabel;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    Label8: TLabel;
    DateTimePicker3: TDateTimePicker;
    DateTimePicker4: TDateTimePicker;
    DBGrid1: TDBGrid;
    lbl1: TLabel;
    cmbReason: TComboBox;
    lbl2: TLabel;
    cmbProcess: TComboBox;
    lbl3: TLabel;
    edtWO: TEdit;
    lbl4: TLabel;
    cmbPdline: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure sbtnQueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);



  end;

var
  fDetail: TfDetail;

implementation

{$R *.dfm}
uses uDllform,DllInit;



procedure TfDetail.FormShow(Sender: TObject);
begin
     DateTimePicker1.Date :=yesterday;
     DateTimePicker3.Date :=today;
end;

procedure TfDetail.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key<>#13 then Exit;
   sbtnQueryClick(nil);
end;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
var
  start_time,end_time:string;
begin

    start_time := FormatDateTime('YYYY/MM/DD',DateTimePicker1.Date)+' '+ FormatDateTime('HH:mm:ss',DateTimePicker2.Time);
    end_time := FormatDateTime('YYYY/MM/DD',DateTimePicker3.Date)+' '+ FormatDateTime('HH:mm:ss',DateTimePicker4.Time);


    
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'START_TIME',ptInput);
    QryTemp.Params.CreateParam(ftstring,'END_TIME',ptInput);
    QryTemp.Params.CreateParam(ftstring,'PROCESS',ptInput);
    QryTemp.CommandText:=   ' select aa.pdline_Name,aa.sn,aa.out_process_time,aa.emp_name,aa.workdate,aa.rec_time from '+
                            ' (select d.pdline_name,decode(c.customer_sn,''N/A'',c.serial_number,c.Customer_SN) SN,c.out_process_time,e.emp_name, '+
                            ' sajet.sj_get_time_Date(c.out_process_time) as workdate, A.REC_TIME  from sajet.g_sn_defect a,sajet.sys_reason b,'+
                            '  sajet.g_sn_travel c ,sajet.sys_pdline d,sajet.sys_emp e, sajet.g_sn_repair f,sajet.sys_process g  '+
                            ' where A.REC_TIME>=to_date(:start_time,''YYYY/MM/DD HH24:MI:SS'') and A.REC_TIME <to_date(:end_time,''YYYY/MM/DD HH24:MI:SS'')'+
                            ' and a.recid =f.recId and A.SERIAL_NUMBER =C.SERIAL_NUMBER and f.reason_id =b.reason_id and a.process_id =100215 and c.process_id =g.process_id '+
                            ' and b.reason_desc like ''%'+cmbReason.text+'%'' and c.pdline_id=d.pdline_id and c.emp_id=e.emp_id and c.out_process_time < a.rec_time and g.process_name =:process )aa,'+
                            ' (select sn ,max(out_process_time) max_time from(select  decode(c.customer_sn,''N/A'',c.serial_number,c.Customer_SN) SN, c.out_process_time from sajet.g_sn_defect a,sajet.sys_reason b,'+
                            '  sajet.g_sn_travel c ,sajet.sys_pdline d,sajet.sys_emp e, sajet.g_sn_repair f,sajet.sys_process g  '+
                            ' where A.REC_TIME>=to_date(:start_time,''YYYY/MM/DD HH24:MI:SS'') and A.REC_TIME <to_date(:end_time,''YYYY/MM/DD HH24:MI:SS'')'+
                            ' and a.recid =f.recId and A.SERIAL_NUMBER =C.SERIAL_NUMBER and f.reason_id =b.reason_id and a.process_id =100215 and c.process_id =g.process_id '+
                            ' and b.reason_desc like ''%'+cmbReason.text+'%'' and c.pdline_id=d.pdline_id and c.emp_id=e.emp_id and c.out_process_time < a.rec_time and g.process_name =:process '+
                            ' ) group by sn ) bb '+
                            ' where aa.out_process_time =bb.max_time and aa.sn=bb.sn';
    QryTemp.Params.ParamByName('START_TIME').AsString := start_time;
    QryTemp.Params.ParamByName('END_TIME').AsString := end_time;
    QryTemp.Params.ParamByName('PROCESS').AsString := cmbProcess.Text;
    QryTemp.Open;
    QryTemp.First;





end;

procedure TfDetail.sBtnExportClick(Sender: TObject);
var
  sFileName,My_FileName : String;
  MsExcel, MsExcelWorkBook : Variant;
begin
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'xlsx';
  SaveDialog1.Filter := 'All Files(*.xlsx)|*.xlsx';

  if SaveDialog1.Execute then
  begin
    try
          sFileName := SaveDialog1.FileName;
          if FileExists(sFileName) then
          begin
            If MessageDlg('File has exist! Replace or Not ?',mtCustom, mbOKCancel,0) = mrOK Then
              DeleteFile(sFileName)
            else
              exit;
          end;
         My_FileName:=ExtractFilePath(Application.ExeName) + ExtractFileName('Query AutoTest.xlt');
         MsExcel := CreateOleObject('Excel.Application');
         MsExcelWorkBook := MsExcel.WorkBooks.Add;
         SaveExcel(MsExcel,MsExcelWorkBook);
         MsExcelWorkBook.SaveAs(sFileName);
         showmessage('Save Excel OK!!');
    Except
      ShowMessage('Could not start Microsoft Excel.');
    end;

    MsExcel.Application.Quit;
    MsExcel:=Null;
  end
  else
    MessageDlg('You did not Save Any Data',mtWarning,[mbok],0);

end;

procedure TfDetail.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var i:integer;
begin
    MsExcel.WorkSheets[1].Activate;
    MsExcel.Cells[1,1].Value := '機種';
    MsExcel.Cells[1,2].Value := 'Serial_Number';
    MsExcel.Cells[1,3].Value := 'Customer_SN';
    MsExcel.Cells[1,4].Value := '站別';
    MsExcel.Cells[1,5].Value := '不良時間';
    MsExcel.Cells[1,6].Value := '不良現象';
    MsExcel.Cells[1,7].Value := '不良機台/纖體';
    MsExcel.Cells[1,8].Value := '測試人員';
    MsExcel.Cells[1,9].Value := '維修時間';
    MsExcel.Cells[1,10].Value := '維修人員';
    MsExcel.Cells[1,11].Value := '不良原因';
    MsExcel.Cells[1,12].Value := '維修動作';
    MsExcel.Cells[1,13].Value := '維修后測試';
    MsExcel.Columns[1].columnwidth := 15;
    MsExcel.Columns[2].columnwidth := 20;
    MsExcel.Columns[3].columnwidth := 20;
    MsExcel.Columns[4].columnwidth := 20;
    MsExcel.Columns[5].columnwidth := 20;
    MsExcel.Columns[6].columnwidth := 15;
    MsExcel.Columns[7].columnwidth := 20;
    MsExcel.Columns[8].columnwidth := 15;
    MsExcel.Columns[9].columnwidth := 20;
    MsExcel.Columns[10].columnwidth := 15;
    MsExcel.Columns[11].columnwidth := 20;
    MsExcel.Columns[12].columnwidth := 15;
    MsExcel.Columns[13].columnwidth := 15;
    QryTemp.First;
    for i:=0 to QryTemp.RecordCount-1 do begin
         Application.ProcessMessages;
         MsExcel.Cells[2+i,1].Value := Qrytemp.FieldByName('Model_NAME').AsString;
         MsExcel.Cells[2+i,2].Value := Qrytemp.FieldByName('Serial_number').AsString;
         MsExcel.Cells[2+i,3].Value := Qrytemp.FieldByName('Customer_SN').AsString;
         MsExcel.Cells[2+i,4].Value := Qrytemp.FieldByName('PROCESS_NAME').AsString;
         MsExcel.Cells[2+i,5].Value := Qrytemp.FieldByName('REC_TIME').AsString;
         MsExcel.Cells[2+i,6].Value := Qrytemp.FieldByName('Defect_desc').AsString;
         MsExcel.Cells[2+i,7].Value := Qrytemp.FieldByName('PDLINE_NAME').AsString;
         MsExcel.Cells[2+i,8].Value := Qrytemp.FieldByName('TEST_NAME').AsString;
         MsExcel.Cells[2+i,9].Value := Qrytemp.FieldByName('REPAIR_TIME').AsString;
         MsExcel.Cells[2+i,10].Value := Qrytemp.FieldByName('REPAIR_NAME').AsString;
         MsExcel.Cells[2+i,11].Value := Qrytemp.FieldByName('reason_desc').AsString;
         MsExcel.Cells[2+i,12].Value := Qrytemp.FieldByName('DUTY_DESC').AsString;
         if Qrytemp.FieldByName('RP_STATUS').AsString ='2' then
         MsExcel.Cells[2+i,13].Value := 'OK';
         if Qrytemp.FieldByName('RP_STATUS').AsString ='3' then
         MsExcel.Cells[2+i,13].Value := 'NG';
         QryTemp.Next;

    end;
    
    MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].Borders[1].Weight := 2;
    MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].Borders[2].Weight := 2;
    MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].Borders[3].Weight := 2;
    MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].Borders[4].Weight := 2;
    MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].HorizontalAlignment :=3;
    MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].VerticalAlignment :=2;
    MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].Font.Size :=9;
    MsExcel.ActiveSheet.Range['A1:M'+IntToStr(i+1)].Font.Name :='tahoma';
    MsExcel.Rows[1].Font.Size :=14;
    MsExcel.Rows[1].Font.Color :=clwhite;
    MsExcel.ActiveSheet.Range['A1:M1'].Interior.color :=clBlue;
    MsExcel.Rows[1].Font.Bold :=true;

end;

end.
