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
    Label3: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    Label8: TLabel;
    DateTimePicker3: TDateTimePicker;
    DateTimePicker4: TDateTimePicker;
    DBGrid1: TDBGrid;
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
    QryTemp.CommandText:=  '      select  e.Model_Name,a.rec_time ,a.Serial_number,K.EMP_NAME TEST_NAME,L.EMP_NAME REPAIR_NAME, '+
                           '      g.customer_sn, p.rp_status, a.RECEIVE_TIME,f.PDLINE_NAME, r.pdline_name RETEST_PDLINE,'+
                           '      b.PROCESS_NAME ,b.PROCESS_CODE,C.defect_code,  h.Repair_time, '+
                           '      c.Defect_desc , j.reason_desc , M.Duty_DESC from '+
                           '      sajet.g_SN_defect a, sajet.SYS_PROCESS b, sajet.sys_defect c , sajet.sys_part d , '+
                           '      sajet.sys_Model e , sajet.sys_pdline f , sajet.g_sn_status g , sajet.g_sn_repair h ,'+
                           '      sajet.sys_reason j ,sajet.sys_emp K,sajet.sys_emp L,SAJET.SYS_DUTY M,'+
                           '       sajet.g_sn_repair_location n,SAJET.G_SN_DEFECT_FIRST P,sajet.PDLINE_name R'+
                           '      where A.DEFECT_ID=C.DEFECT_ID and A.PROCESS_ID=B.PROCESS_ID and '+
                           '      a.REC_Time >= to_date(:Start_Time, ''yyyy/mm/dd hh24:mi:ss'') '+
                           '      and a.REC_Time <to_date(:End_Time, ''yyyy/mm/dd hh24:mi:ss'') '+
                           '      and a.serial_number=g.serial_number and a.RECID = h.RECID '+
                           '      and h.recid = n.recid and a.SERIAL_NUMBER =p.SERIAL_NUMBER AND '+
                           '      A.PROCESS_ID =P.PROCESS_ID AND a.WORK_ORDER =p.work_order '+
                           '      and n.reason_id  =j.reason_id and a.serial_number = h.serial_number '+
                           '      and a.TEST_EMP_ID =K.EMP_ID and n.Update_UserID = L.EMP_ID '+
                           '      and h.Duty_ID =m.DUTY_ID and b.PROCESS_NAME <> ''REPAIR_TEST'' and r.pdline_id =a.pdline_id '+
                           '      and a.MOdel_ID=d.Part_ID and e.MOdel_ID =d.Model_ID and  p.pdline_id =f.pdline_ID ' +
                           '      order by Model_Name,PROCESS_CODE,serial_number, rec_time ';

    QryTemp.Params.ParamByName('START_TIME').AsString := start_time;
    QryTemp.Params.ParamByName('END_TIME').AsString := end_time;
    QryTemp.Open;
    QryTemp.First;

    label3.Caption := IntToStr(Qrytemp.RecordCount);




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
