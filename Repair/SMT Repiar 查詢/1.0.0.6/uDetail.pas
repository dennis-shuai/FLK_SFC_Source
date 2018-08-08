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
    Label1: TLabel;
    Label3: TLabel;
    Label6: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Edit1: TEdit;
    StringGrid1: TStringGrid;
    Edt_ErrorDesc: TEdit;
    cbbProcess: TComboBox;
    Image2: TImage;
    SpeedButton1: TSpeedButton;
    Label5: TLabel;
    ComboBox1: TComboBox;
    Label7: TLabel;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    Label8: TLabel;
    DateTimePicker3: TDateTimePicker;
    DateTimePicker4: TDateTimePicker;
    procedure FormShow(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure sbtnQueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    iRow: integer;
    
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);



  end;

var
  fDetail: TfDetail;

implementation

{$R *.dfm}
uses uDllform,DllInit;



procedure TfDetail.FormShow(Sender: TObject);
var
  i,j:Integer;
begin
  for i:=0 to stringgrid1.RowCount   do
       for j:=0 to stringgrid1.ColCount  do
         stringgrid1.Cells[j,i]:='';

     stringgrid1.ColWidths[0]:=1 ;
     stringgrid1.ColWidths[1]:=120 ;
     stringgrid1.ColWidths[2]:=150 ;
     stringgrid1.ColWidths[3]:=80 ;
     stringgrid1.ColWidths[4]:=120 ;
     stringgrid1.ColWidths[5]:=70 ;
     stringgrid1.ColWidths[6]:=120;
     stringgrid1.ColWidths[7]:=70;
     stringgrid1.ColWidths[8]:=80 ;
     stringgrid1.ColWidths[9]:=80 ;
     stringgrid1.ColWidths[10]:=70 ;
     stringgrid1.ColWidths[11]:=70 ;

     stringgrid1.Cells[0,0]:=' ';
     stringgrid1.Cells[1,0]:='條碼';
     stringgrid1.Cells[2,0]:='不良現象';
     stringgrid1.Cells[3,0]:='測試機台' ;
     stringgrid1.Cells[4,0]:='測試時間' ;
     stringgrid1.Cells[5,0]:='測試人員' ;
     stringgrid1.Cells[6,0]:='維修時間' ;
     stringgrid1.Cells[7,0]:='維修人員' ;
     stringgrid1.Cells[8,0]:='不良原因' ;
     stringgrid1.Cells[9,0]:='維修內容' ;
     stringgrid1.Cells[10,0]:='維修后測試' ;
     stringgrid1.Cells[11,0]:='維修后目檢' ;
     //stringgrid1.Cells[11,0]:='維修內容' ;
     ComboBox1.ItemIndex:=1;
     iRow:=0;
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
  Sn,cSn:string;
  i,j:Integer;
  FpOpen: TextFile;
  S:string;
  FilePath:string;
  mType:string;
  ErrorDesc:string;
  Process_Name,rp_time,start_time,end_time:string;
begin
    for i :=1 to stringgrid1.RowCount -2  do
      for j :=0 to 11  do
          stringgrid1.Cells[j,i] :='';


    for i :=0 to stringgrid1.RowCount -1  do
        if (stringgrid1.Cells[1,i]=cSn) and (cSn<>'') AND (stringgrid1.Cells[1,i]<>'') then  Exit;
    start_time := FormatDateTime('YYYY/MM/DD',DateTimePicker1.Date)+' '+ FormatDateTime('HH:mm:ss',DateTimePicker2.Time);
    end_time := FormatDateTime('YYYY/MM/DD',DateTimePicker3.Date)+' '+ FormatDateTime('HH:mm:ss',DateTimePicker4.Time);
    
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'START_TIME',ptInput);
    QryTemp.Params.CreateParam(ftstring,'END_TIME',ptInput);
    QryTemp.CommandText:= ' SELECT * FROM (   '+
                          ' SELECT a1.serial_number,a1.defect_desc,a1.pdline_name,a1.C_SN,a1.rec_time,a1.emp_name,a1.repair_time,  '+
                          ' a1.reason_desc,a1.duty_desc,a1.repair_name,b1.TEST_AFRP,c1.VI_AFRP,b1.out_process_time TEST_TIME_AFRP,c1.out_process_time VI_TIME_AFRP ,'+
                          ' ROW_NUMBER() OVER (PARTITION BY a1.serial_number  ORDER BY a1.repair_time,b1.out_process_time,c1.out_process_time) RAN FROM '+
                          ' ( select aa.serial_number,aa.defect_desc,aa.pdline_name,decode(aa.customer_sn,''N/A'',aa.serial_number,aa.customer_sn) C_SN '+
                          ' ,aa.rec_time,aa.emp_name,bb.repair_time,bb.reason_desc,bb.duty_desc,bb.repair_name '+
                          ' from (Select c.serial_number,d.defect_code,d.defect_desc,e.pdline_name,c.customer_sn,a.rec_time,b.emp_name from '+
                          ' ( SELECT * FROM sajet.g_sn_defect_first WHERE REC_TIME >=TO_DATE(:START_TIME,''YYYY/MM/DD HH24:MI:SS'')  '+
                          ' AND REC_TIME<TO_DATE(:END_TIME,''YYYY/MM/DD HH24:MI:SS'') AND PROCESS_ID  = 100266 and  ntf_time is null) a,sajet.sys_emp b, '+
                          ' sajet.g_sn_status c,sajet.sys_defect d,sajet.sys_pdline e '+
                          '  where  a.serial_number =C.SERIAL_NUMBER and a.pdline_id=e.pdline_id and b.emp_id=a.test_emp_id  '+
                          ' and a.defect_id=d.defect_id) aa,  '+
                          ' ( select a.serial_number,a.repair_time,b.reason_desc,c.duty_Desc,d.emp_name repair_name from sajet.g_sn_repair a,sajet.sys_reason b,sajet.sys_duty c,sajet.sys_emp d '+
                          '  where   a.repair_emp_id=d.emp_id and a.reason_id=b.reason_id and a.duty_id=c.duty_id) bb '+
                          ' where aa.serial_number = bb.serial_number(+) and (bb.repair_time >aa.rec_time or bb.repair_time is null) ORDER BY aa.serial_number,bb.repair_time) a1, '+
                          ' (select serial_number,decode(current_status,''0'',''OK'',''NG'') Test_AFRP ,Out_process_time from sajet.g_sn_travel '+
                          ' where   process_id=100266) b1, '+
                          ' (select serial_number,decode(current_status,''0'',''OK'',''NG'') VI_AFRP ,Out_process_time from sajet.g_sn_travel '+
                          ' where   process_id=100215) c1 where a1.serial_number=b1.serial_number(+) and b1.serial_number =c1.serial_number(+) '+
                          ' and ( a1.REPAIR_TIME < b1.out_process_time  OR  a1.REPAIR_TIME IS NULL )'+
                          ' and ( a1.REPAIR_TIME < c1.out_process_time  OR  a1.REPAIR_TIME IS NULL )) WHERE RAN=1 ' +
                          ' Union ( SELECT * FROM (    ' +
                          '  SELECT a1.serial_number,a1.defect_desc,a1.pdline_name,a1.C_SN,a1.rec_time,a1.emp_name,a1.repair_time, ' +
                          '  a1.reason_desc,a1.duty_desc,a1.repair_name,b1.TEST_AFRP,c1.VI_AFRP,b1.out_process_time TEST_TIME_AFRP,c1.out_process_time VI_TIME_AFRP ,  ' +
                          '  ROW_NUMBER() OVER (PARTITION BY a1.serial_number  ORDER BY a1.repair_time,b1.out_process_time,c1.out_process_time) RAN       ' +
                          '  FROM  ( select aa.serial_number,aa.defect_desc,aa.pdline_name,decode(aa.customer_sn,''N/A'',aa.serial_number,aa.customer_sn) C_SN  ,   ' +
                          '  aa.rec_time,aa.emp_name,bb.repair_time,bb.reason_desc,bb.duty_desc,bb.repair_name    ' +
                          '  from (Select c.serial_number,d.defect_code,d.defect_desc,e.pdline_name,c.customer_sn,c.out_process_Time rec_time,b.emp_name  ' +
                          '  from  ( SELECT * FROM sajet.g_sn_defect_first WHERE REC_TIME >=TO_DATE(:START_TIME,''YYYY/MM/DD HH24:MI:SS'')    ' +
                          '  AND REC_TIME<TO_DATE(:END_TIME,''YYYY/MM/DD HH24:MI:SS'') AND PROCESS_ID  = 100215 and  ntf_time is null) a,  ' +
                          '  sajet.sys_emp b,  sajet.g_SN_TRAVEL c,sajet.sys_defect d,sajet.sys_pdline e   ' +
                          '  where  a.serial_number =C.SERIAL_NUMBER and c.pdline_id=e.pdline_id and b.emp_id=c.emp_id  and a.defect_id=d.defect_id and c.process_ID =100266) aa,   ' +
                          '  ( select a.serial_number,a.repair_time,b.reason_desc,c.duty_Desc,d.emp_name repair_name from sajet.g_sn_repair a,  ' +
                          '  sajet.sys_reason b,sajet.sys_duty c,sajet.sys_emp d   where   a.repair_emp_id=d.emp_id and a.reason_id=b.reason_id and a.duty_id=c.duty_id) bb  ' +
                          '   where aa.serial_number = bb.serial_number(+) and (bb.repair_time >aa.rec_time or bb.repair_time is null) ORDER BY aa.serial_number,bb.repair_time) a1,   ' +
                          '  (select serial_number,decode(current_status,''0'',''OK'',''1'',''NG'') Test_AFRP ,Out_process_time   from sajet.g_sn_travel  where   process_id=100266) b1,   ' +
                          '  (select serial_number,decode(current_status,''0'',''OK'',''1'',''NG'') VI_AFRP ,Out_process_time from sajet.g_sn_travel  where   process_id=100215) c1  ' +
                          '  where a1.serial_number=b1.serial_number(+) and b1.serial_number =c1.serial_number(+)  and ( a1.REPAIR_TIME < b1.out_process_time  OR   ' +
                          '  a1.REPAIR_TIME IS NULL ) and ( a1.REPAIR_TIME < c1.out_process_time  OR  a1.REPAIR_TIME IS NULL )) WHERE RAN=1 )';

    QryTemp.Params.ParamByName('START_TIME').AsString := start_time;
    QryTemp.Params.ParamByName('END_TIME').AsString := end_time;
    QryTemp.Open;
    QryTemp.First;
    for i:=0 to  QryTemp.RecordCount-1    do begin
      stringgrid1.Cells[0,i+1]:= QryTemp.fieldbyName('Serial_number').AsString;
      stringgrid1.Cells[1,i+1]:= QryTemp.fieldbyName('C_SN').AsString;
      stringgrid1.Cells[2,i+1]:= QryTemp.fieldbyName('Defect_Desc').AsString;
      stringgrid1.Cells[3,i+1]:= QryTemp.fieldbyName('PDLINE_NAME').AsString;
      stringgrid1.Cells[4,i+1]:= FormatDateTime('YYYY/MM/DD HH:mm:ss',QryTemp.fieldbyName('REC_TIME').AsDateTime);
      stringgrid1.Cells[5,i+1]:= QryTemp.fieldbyName('EMP_NAME').AsString;
      stringgrid1.Cells[6,i+1]:= FormatDateTime('YYYY/MM/DD HH:mm:ss',QryTemp.fieldbyName('Repair_time').AsDateTime);
      stringgrid1.Cells[7,i+1]:= QryTemp.fieldbyName('repair_name').AsString;
      stringgrid1.Cells[8,i+1]:= QryTemp.fieldbyName('REASON_DESC').AsString;
      stringgrid1.Cells[9,i+1]:= QryTemp.fieldbyName('DUTY_DESC').AsString;
      stringgrid1.Cells[10,i+1]:= QryTemp.fieldbyName('TEST_AFRP').AsString;
      stringgrid1.Cells[11,i+1]:= QryTemp.fieldbyName('VI_AFRP').AsString;
      QryTemp.Next;
      if i>5 then stringGrid1.RowCount :=stringGrid1.RowCount +1;

    end;
    Label3.Caption := IntToStr(i);

    

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
         MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);
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

procedure TfDetail.SpeedButton1Click(Sender: TObject);
var
  Sn,cSn:string;
  i:Integer;
  FpOpen: TextFile;
  S:string;
  FilePath:string;

begin
  //if Edit1.Text='' then Exit;
 // cSn:=Edit1.Text;
  Application.ProcessMessages;
  for i :=0 to stringgrid1.RowCount -1  do
    if (stringgrid1.Cells[1,i]=cSn) and (cSn<>'') AND (stringgrid1.Cells[1,i]<>'') then  Exit;

  FilePath:=ExtractFilePath(Application.ExeName) + 'SN.TXT';
  AssignFile(FpOpen, FilePath);
    Reset(FpOpen);//打開文件

    while not EOF(FpOpen)do begin
        Readln(FpOpen,S);//讀取一行文本
        if trim(S)<>'' THEN BEGIN
            cSn:=S;

            QryTemp.Close;
            QryTemp.Params.Clear;
            QryTemp.Params.CreateParam(ftstring,'CSN',ptInput);

            QryTemp.CommandText:= 'select serial_Number from Sajet.g_sn_status where Customer_sn=:CSN or Serial_number=:CSN ';

            QryTemp.Params.ParamByName('CSN').AsString := cSn;
            QryTemp.Open;

            IF  NOT QryTemp.Eof then
            begin
               Sn:=QryTemp.FieldByName('Serial_number').AsString;
            end else begin
               Sn:='';
            end;

            if sn='' then Exit;

            QryTemp.Close;
            QryTemp.Params.Clear;
            QryTemp.Params.CreateParam(ftstring,'SN',ptInput);

            QryTemp.CommandText:= ' SELECT SERIAL_NUMBER,REC_TIME,PDLINE_NAME,PROCESS_NAME,DEFECT_CODE,DEFECT_DESC ' +
                                  ' FROM ( SELECT A.SERIAL_NUMBER,A.REC_TIME,D.PDLINE_NAME,B.PROCESS_NAME,C.DEFECT_CODE,C.DEFECT_DESC FROM SAJET.G_SN_DEFECT A,sajet.sys_process B,SAJET.SYS_DEFECT C ,SAJET.SYS_PDLINE D ' +
                                  ' WHERE A.PROCESS_ID=B.PROCESS_ID AND A.DEFECT_ID=C.DEFECT_ID AND A.PDLINE_ID=D.PDLINE_ID AND SERIAL_NUMBER=:SN ' +
                                  ' ORDER BY REC_TIME DESC ) ' +
                                  ' WHERE ROWNUM=1 ' ;
            QryTemp.Params.ParamByName('SN').AsString := Sn;
            QryTemp.Open;
            IF  NOT QryTemp.Eof then
            begin
               iRow:=iRow+1;
               stringgrid1.RowCount:=iRow+1;
               Label3.Caption:= IntToStr(iRow);
               stringgrid1.Cells[0,iRow]:=IntToStr(iRow);
               stringgrid1.Cells[1,iRow]:=cSn;
               stringgrid1.Cells[2,iRow]:=QryTemp.FieldByName('DEFECT_DESC').AsString;
               stringgrid1.Cells[8,iRow]:=QryTemp.FieldByName('PROCESS_NAME').AsString;
            end else BEGIN
               iRow:=iRow+1;
               Label3.Caption:= IntToStr(iRow);
               stringgrid1.Cells[0,iRow]:=IntToStr(iRow);
               stringgrid1.RowCount:=iRow+1;
               stringgrid1.Cells[1,iRow]:=cSn;
            end;

            QryTemp.Close;
            QryTemp.Params.Clear;
            QryTemp.Params.CreateParam(ftstring,'SN',ptInput);

            QryTemp.CommandText:= ' select A.Serial_number,A.PROCESS_ID,A.OUT_PROCESS_TIME,B.TERMINAL_NAME ' +
                                  ' from SAJET.G_SN_TRAVEL A,SAJET.SYS_TERMINAL B ' +
                                  ' WHERE A.TERMINAL_ID=B.TERMINAL_ID AND A.SERIAL_NUMBER=:SN AND A.PROCESS_ID=100245 '  ;
            QryTemp.Params.ParamByName('SN').AsString := Sn;
            QryTemp.Open;
            IF  NOT QryTemp.Eof then
            begin
               stringgrid1.Cells[3,iRow]:=QryTemp.FieldByName('TERMINAL_NAME').AsString;
               stringgrid1.Cells[4,iRow]:=QryTemp.FieldByName('OUT_PROCESS_TIME').AsString;
            end;

            QryTemp.Close;
            QryTemp.Params.Clear;
            QryTemp.Params.CreateParam(ftstring,'SN',ptInput);

            QryTemp.CommandText:= ' select A.Serial_number,A.PROCESS_ID,A.OUT_PROCESS_TIME,B.PDLINE_NAME ' +
                                  ' from SAJET.G_SN_TRAVEL A,SAJET.SYS_PDLINE B ' +
                                  ' WHERE A.PDLINE_ID=B.PDLINE_ID AND A.SERIAL_NUMBER=:SN AND A.PROCESS_ID=100266 '  ;
            QryTemp.Params.ParamByName('SN').AsString := Sn;
            QryTemp.Open;
            IF  NOT QryTemp.Eof then
            begin
               stringgrid1.Cells[5,iRow]:=QryTemp.FieldByName('PDLINE_NAME').AsString;
               stringgrid1.Cells[6,iRow]:=QryTemp.FieldByName('OUT_PROCESS_TIME').AsString;
            end;
        end;
    end;
    CloseFile(FpOpen);

  //Edit1.SelectAll;
  //Edit1.SetFocus;

end;

procedure TfDetail.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var
    i,row:integer;
    icol,irow :integer;
begin

    for irow :=0 to stringgrid1.RowCount -1  do
    begin
        MsExcel.ActiveSheet.range[char(65)+inttostr(irow+1)]:=stringgrid1.Cells[1,irow];
        MsExcel.ActiveSheet.range[CHAR(66)+inttostr(irow+1)]:=stringgrid1.Cells[2,irow];
        MsExcel.ActiveSheet.range[char(67)+inttostr(irow+1)]:=stringgrid1.Cells[3,irow];
        MsExcel.ActiveSheet.range[char(68)+inttostr(irow+1)]:=stringgrid1.Cells[4,irow];
        MsExcel.ActiveSheet.range[char(69)+inttostr(irow+1)]:=stringgrid1.Cells[5,irow];
        if stringgrid1.Cells[6,irow] ='1899/12/30 00:00:00' then  begin
             MsExcel.ActiveSheet.range[char(70)+inttostr(irow+1)]:='';
             MsExcel.ActiveSheet.range[char(71)+inttostr(irow+1)]:='';
             MsExcel.ActiveSheet.range[char(72)+inttostr(irow+1)]:='';
             MsExcel.ActiveSheet.range[char(73)+inttostr(irow+1)]:='';
             MsExcel.ActiveSheet.range[char(74)+inttostr(irow+1)]:='';
             MsExcel.ActiveSheet.range[char(75)+inttostr(irow+1)]:='';
        end
        else begin
             MsExcel.ActiveSheet.range[char(70)+inttostr(irow+1)]:=stringgrid1.Cells[6,irow];
             MsExcel.ActiveSheet.range[char(71)+inttostr(irow+1)]:=stringgrid1.Cells[7,irow];
             MsExcel.ActiveSheet.range[char(72)+inttostr(irow+1)]:=stringgrid1.Cells[8,irow];
             MsExcel.ActiveSheet.range[char(73)+inttostr(irow+1)]:=stringgrid1.Cells[9,irow];
             MsExcel.ActiveSheet.range[char(74)+inttostr(irow+1)]:=stringgrid1.Cells[10,irow];
             MsExcel.ActiveSheet.range[char(75)+inttostr(irow+1)]:=stringgrid1.Cells[11,irow];
        end;
    end;

end;

end.
