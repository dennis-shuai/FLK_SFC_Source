unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  MConnect, SConnect, {FileCtrl,} ObjBrkr, Menus,DateUtils,comobj,Variants,
  ComCtrls, TeeProcs, TeEngine, Chart, DbChart, Series, TeeShape, ArrowCha,
  GanttCh, BubbleCh, TeeFunci;

type
  TfMain = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    labCnt: TLabel;
    labcost: TLabel;
    qryReel: TClientDataSet;
    Image2: TImage;
    sbtnQuery: TSpeedButton;
    Label2: TLabel;
    ComboBoxmodelname: TComboBox;
    Label3: TLabel;
    ComboBoxProcessname: TComboBox;
    DateTimePicker1: TDateTimePicker;
    Label6: TLabel;
    Chart1: TChart;
    sFastLine: TFastLineSeries;
    StringGrid1: TStringGrid;
    DateTimePicker2: TDateTimePicker;
    Label8: TLabel;
    Label9: TLabel;
    Sbtnexport: TSpeedButton;
    Image1: TImage;
    SaveDialog1: TSaveDialog;
    cmbfactory: TComboBox;
    Series1: TFastLineSeries;
    Series2: TFastLineSeries;
    Series3: TFastLineSeries;
    QryTop3Defect: TClientDataSet;
    QryTop3DefectYeild: TClientDataSet;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    DateTimePicker3: TDateTimePicker;
    ComboBox3: TComboBox;
    Label7: TLabel;
    DateTimePicker4: TDateTimePicker;
    ComboBox4: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure SbtnexportClick(Sender: TObject);
    procedure cmbfactoryChange(Sender: TObject);
    procedure ComboBoxmodelnameChange(Sender: TObject);
    procedure ComboBoxProcessnameChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    icol,irow:integer;
    Griviseday:integer;
   // procedure getlinename;
    procedure getprocessname;
    procedure getmodelname;
   // procedure getStageName;
    //procedure gettargetfail(modelid,pdlineid,processid:string);
    //Function Addchart(strdate,strfail,strdpoint:string):boolean;
    Function DownloadSampleFile : String;
    procedure cleardata;
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);


    procedure QueryFF2HM(QryTemp1:TClientDataSet;sStart_Time,sEnd_Time,sDStart_Time,sDEnd_Time,sTime,eTime:string);

      
  end;

var
  fMain: TfMain;
  FcID :string;
  G_target_fail,g_alarm_fail,g_lower_fail:string;
  g_modelid,g_pdlineid,g_processid,g_stageid :string;
  TopErrCode:string;
  sModelName:string;
  sProcessName:string;

implementation

{$R *.DFM}
uses uDllform;

procedure TfMain.cleardata;
var i,j: integer;
begin
   DateTimePicker1.Date :=now;
   Datetimepicker2.Date :=now+1;
   DateTimePicker3.Date :=now-1;
   Datetimepicker4.Date :=now;
   
   
   for i:=0 to stringgrid1.RowCount   do
     for j:=0 to stringgrid1.ColCount  do
       stringgrid1.Cells[j,i]:='';
   stringgrid1.ColWidths[0]:=100 ;
   stringgrid1.Cells[0,0]:='Sample';
   stringgrid1.Cells[0,1]:='Fail Yield(%)';


   ComboBoxProcessname.Clear ;
   comboboxmodelname.Clear ;

   sFastline.Clear;   // real fail

end;



procedure TfMain.getprocessname;
begin
  ComboBoxProcessname.Clear ;
  ComboBoxProcessname.Items.Add('');
  ComboBoxProcessname.Items.Add('DIE BOND');
  ComboBoxProcessname.Items.Add('HODLE MOUNT');
  {
      with QryTemp do
        begin
          Close;
          commandtext:='select * FROM SAJET.SYS_process WHERE ENABLED=''Y'' ORDER BY process_NAME ASC ';
          open;

          if recordcount<>0 then
            begin
                first;
                ComboBoxProcessname.Clear ;
                while not eof do
                   begin
                       ComboBoxProcessname.Items.Add(fieldbyname('process_name').AsString );
                       next;
                   end;
            end;
        end;    }
end;

procedure TfMain.getmodelname;
begin
      with QryTemp do
        begin
          Close;
          commandtext:='select * FROM SAJET.SYS_model WHERE ENABLED=''Y'' ORDER BY model_NAME ASC ';
          open;

          if recordcount<>0 then
            begin
                first;
                comboboxmodelname.Clear ;
                while not eof do
                   begin
                       comboboxmodelname.Items.Add(fieldbyname('model_name').AsString );
                       next;
                   end;
            end;
        end;
end;


procedure TfMain.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  

  with QryTemp do
  begin
    Close;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
    if gsParam <> '' then
      CommandText := CommandText + 'and fun_param = ''' + gsParam + ''' ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'QueryKPIFailTChart.DLL';
    Open;
  end;
  cleardata;
  getmodelname;
  getprocessname;

  cmbFactory.Items.Clear;
  with QryTemp do
  begin
    Close;
    CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
      'From SAJET.SYS_FACTORY ' +
      'Where ENABLED = ''Y'' ';
    Open;
    while not Eof do
    begin
      cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString);
      Next;
      cmbfactory.ItemIndex:=0;
    end;
    cmbFactoryChange(Self);

    Close;
  end;

end;

procedure TfMain.sbtnQueryClick(Sender: TObject);
var
  i,j,k,icol: integer;
  strstart,strend :string;
  iseq,idate :integer;
  strsql1:string;
  strworkdate,strenddate,strstartdate:string;
  strfail:string;
  Defect_Start,Defect_End:TDateTime;
  sDefect_Start,sDefect_End,sAll_Defect,sDefect_Code:String;

  fTime1,fTime2,cTime1,cTime2:string;
  sStartTime,sEndTime,sDStartTime,sDEndTime:string;
  cStartTime,cEndTime,cDStartTime,cDEndTime:string;

  Process_Name:string;
begin

   sFastLine.Clear;

    for i:=0 to stringgrid1.RowCount   do
     for j:=0 to stringgrid1.ColCount  do
       stringgrid1.Cells[j,i]:='';

   stringgrid1.ColWidths[0]:=120 ;
   stringgrid1.Cells[0,0]:='Sample';
   stringgrid1.Cells[0,1]:='Fail Yield(%)';
   stringgrid1.Cells[0,2]:='Fail Qty(Pcs)';
   stringgrid1.Cells[0,3]:='Total Input(Pcs)';


   if datetimepicker1.DateTime >datetimepicker2.DateTime then
   begin
      MessageDlg('Start date > End date', mtInformation, [mbOk], 0);
      exit;
   end;

   if ComboBoxmodelname.Text ='' then
   begin
      MessageDlg('Please select one Model name!', mtInformation, [mbOk], 0);
      exit;
   end;
   if ComboBoxProcessname.Text ='' then
   begin
      MessageDlg('Please select one Process name!', mtInformation, [mbOk], 0);
      exit;
   end;

   if length(ComboBox1.Text)=1  then  fTime1 := '0' + ComboBox1.Text
   else  fTime1 := ComboBox1.Text;

   if length(ComboBox2.Text)=1  then  fTime2 := '0' + ComboBox2.Text
   else  fTime2 := ComboBox2.Text;

   if length(ComboBox3.Text)=1  then  cTime1 := '0' + ComboBox3.Text
   else  cTime1 := ComboBox3.Text;

   if length(ComboBox4.Text)=1  then  cTime2 := '0' + ComboBox4.Text
   else  cTime2 := ComboBox4.Text;

   sStartTime  := FormatDateTime('yyyymmdd',DateTimePicker1.Date)  ;
   sEndTime  := FormatDateTime('yyyymmdd',DateTimePicker2.Date) ;
   sDStartTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+ ' '+ fTime1 +':00:00'  ;
   sDEndTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker2.Date) + ' ' + fTime2 +':00:00' ;

   cStartTime  := FormatDateTime('yyyymmdd',DateTimePicker3.Date) +  cTime1 ;
   cEndTime  := FormatDateTime('yyyymmdd',DateTimePicker4.Date) +cTime2 ;
   cDStartTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker3.Date)+ ' '+ cTime1 +':00:00'  ;
   cDEndTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker4.Date) + ' ' + cTime2 +':00:00' ;


   //QueryFF2HM(QryData,sStartTime,sEndTime,sDStartTime,sDEndTime,fTime1,fTime2);
   QueryFF2HM(QryData,cStartTime,cEndTime,sDStartTime,sDEndTime,cTime1,cTime2);

   icol:=1;
   If not QryData.IsEmpty then begin
        QryData.First;
        for j:=0 to QryData.RecordCount -1 do begin
            Process_Name:=QryData.FieldByName('TERMINAL_NAME').AsString;
           if Copy(Process_Name,1,Length('HODLE MOUNT'))='HODLE MOUNT' then
                stringgrid1.Cells[icol,0]:='    ' + Copy(Process_Name,Length(ComboBoxProcessname.Text)+1,2)
           else
                stringgrid1.Cells[icol,0]:='    ' + Copy(Process_Name,Length(ComboBoxProcessname.Text)+2,1) ;

            stringgrid1.Cells[icol,1]  :=   QryData.FieldByName('Yield').AsString ;
            stringgrid1.Cells[icol,2]  :=   QryData.FieldByName('TOTAL_FAIL').AsString ;
            stringgrid1.Cells[icol,3]  :=   QryData.FieldByName('TOTAL_INPUT').AsString ;
            inc(icol);
            stringgrid1.ColCount :=icol;
            QryData.Next;
        end;
   end else begin
       Exit;
   end;

   if stringgrid1.Cells[1,1]<>'' then
   begin
        for i:=1 to stringgrid1.ColCount-1 do begin
            sFastLine.addXY(i,strtofloat(stringgrid1.Cells[i,1]),stringgrid1.Cells[i,0],CLRED)  ;
        end;
   end;

end;

procedure TfMain.sbtnexportClick(Sender: TObject);
var
  sFileName,My_FileName : String;
  MsExcel, MsExcelWorkBook : Variant;
begin
  if not QryData.Active Then Exit;
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'xls';
  SaveDialog1.Filter := 'All Files(*.xls)|*.xls';
  My_FileName:= DownLoadSampleFile;
  if not FileExists(My_FileName) then
  begin
    showmessage('Error!-The Excel File '+My_FileName+' can''t be found.');
    exit;
  end;
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

procedure TfMain.SaveExcel(MsExcel,MsExcelWorkBook:Variant);
var i,row:integer;
var icol,irow :integer;
begin
  Chart1.CopyToClipboardMetafile(True);
  MsExcel.ActiveSheet.range['A1'].PasteSpecial;
    i:=0;
    for icol :=0 to stringgrid1.ColCount   -1  do
     begin
        MsExcel.ActiveSheet.range[char(65+i)+'17']:=stringgrid1.Cells[icol,0];
        MsExcel.ActiveSheet.range[CHAR(65+i)+'18']:=stringgrid1.Cells[icol,1];
        MsExcel.ActiveSheet.range[char(65+i)+'19']:=stringgrid1.Cells[icol,2];
        MsExcel.ActiveSheet.range[char(65+i)+'20']:=stringgrid1.Cells[icol,3];
        MsExcel.ActiveSheet.range[char(65+i)+'21']:=stringgrid1.Cells[icol,4];
        MsExcel.ActiveSheet.range[char(65+i)+'22']:=stringgrid1.Cells[icol,5];
        MsExcel.ActiveSheet.range[char(65+i)+'23']:=stringgrid1.Cells[icol,6];
     inc(i);
     end;
end;

Function TfMain.DownloadSampleFile : String;
begin
    Result:=ExtractFilePath(Application.ExeName) + ExtractFileName('QueryTChart.xlt')
end;

procedure TfMain.cmbfactoryChange(Sender: TObject);
begin
  FcID := '';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'FACTORYCODE', ptInput);
    CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
      'From SAJET.SYS_FACTORY ' +
      'Where FACTORY_CODE = :FACTORYCODE ';
    Params.ParamByName('FACTORYCODE').AsString := Copy(cmbFactory.Text, 1, POS(' ', cmbFactory.Text) - 1);
    Open;
    if RecordCount > 0 then
      FcID := Fieldbyname('FACTORY_ID').AsString;
    Close;
  end;
end;

procedure TfMain.ComboBoxmodelnameChange(Sender: TObject);
begin
   sModelName:=ComboBoxmodelname.Text;
   with QryTemp do
   begin
       Close;
       commandtext:='select model_id FROM SAJET.SYS_model WHERE model_name= '''+sModelName+''' and rownum=1 ';
       open;

       g_modelid:=fieldbyname('model_id').AsString ;
   end;
end;


procedure TfMain.ComboBoxProcessnameChange(Sender: TObject);
begin
   
   sProcessName:= ComboBoxProcessname.Text;
   with QryTemp do
   begin
       Close;
       commandtext:='select process_id FROM SAJET.SYS_PROCESS WHERE PROCESS_name= '''+sProcessName+''' and rownum=1 ';
       open;

       g_processid:=fieldbyname('process_id').AsString ;
   end;
end;

{
procedure tfmain.viewtchart;
var icol:integer;
begin
   if stringgrid1.Cells[1,0]='' then exit; //無數據則退出
   series1.Clear;
   series2.Clear;
   series3.Clear;
   for icol:=1 to stringgrid1.ColCount-1 do
       Addchart(stringgrid1.Cells[icol,0],stringgrid1.Cells[icol,3],stringgrid1.Cells[icol,6]);
end;  }


procedure TfMain.QueryFF2HM(QryTemp1: TClientDataSet; sStart_Time, sEnd_Time,
  sDStart_Time,sDEnd_Time,sTime,eTime: string);
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'STARTDATE',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'ENDDATE',ptInput);
    //QryTemp1.Params.CreateParam(ftstring,'sStart_Time',ptInput);
    //QryTemp1.Params.CreateParam(ftstring,'sEnd_Time',ptInput);

    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'MODEL_NAME',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'Process_ID',ptInput);

    {QryTemp1.CommandText := 'SELECT BB.TERMINAL_NAME,AA.INPUT_QTY,BB.TOTAL_QTY,SUBSTR(TOTAL_QTY/INPUT_QTY,1,5)*100 AS YIELD FROM ' +
                             '( SELECT D1.PROCESS_NAME,SUM(A1.PASS_QTY+A1.FAIL_QTY) INPUT_QTY FROM SAJET.G_SN_COUNT A1,SAJET.SYS_PART B1,SAJET.SYS_MODEL C1,SAJET.SYS_PROCESS D1' +
                             ' WHERE A1.MODEL_ID=B1.PART_ID AND B1.MODEL_ID=C1.MODEL_ID AND A1.PROCESS_ID=D1.PROCESS_ID ' +
                             ' AND A1.WORK_DATE>=:STARTDATE and A1.WORK_DATE<=:ENDDATE and A1.WORK_TIME>=:sStart_Time AND A1.WORK_TIME<=:sEnd_Time AND D1.PROCESS_NAME=''FF'' AND A1.WORK_ORDER NOT LIKE ''RM%'' ' +
                             ' GROUP BY D1.PROCESS_NAME ) AA, ' +
                             ' ( SELECT TERMINAL_NAME,SUM(NUM) AS TOTAL_QTY FROM ' +
                             ' ( SELECT D.TERMINAL_NAME,A.SERIAL_NUMBER,1 AS NUM FROM SAJET.g_sn_TRAVEL A,SAJET.SYS_PDLINE B,SAJET.SYS_PROCESS C ,SAJET.SYS_TERMINAL D ' +
                             ' WHERE A.PDLINE_ID=B.PDLINE_ID AND A.PROCESS_ID=C.PROCESS_ID AND A.TERMINAL_ID=D.TERMINAL_ID  AND SERIAL_NUMBER IN  ' +
                             ' ( select A.SERIAL_NUMBER from sajet.g_sn_defect_first A,SAJET.SYS_PART B,SAJET.SYS_MODEL C,SAJET.SYS_PROCESS D ' +
                             ' where A.MODEL_ID=B.PART_ID AND B.MODEL_ID=C.MODEL_ID and a.process_ID=d.process_id ' +
                             ' AND REC_TIME>=TO_DATE(:StartTime,''YYYY-MM-DD HH24:MI:SS'')  and REC_TIME<=TO_DATE(:EndTime,''YYYY-MM-DD HH24:MI:SS'') AND ntf_time is null ' +
                             ' and A.WORK_ORDER NOT LIKE ''RM%'' ' +
                             ' AND C.MODEL_NAME=:MODEL_NAME and D.PROCESS_NAME=''FF'') ' +
                             ' AND C.PROCESS_NAME=''HODLE MOUNT'') ' +
                             ' GROUP BY TERMINAL_NAME ) BB ' +
                             ' order by TERMINAL_NAME ';
  }

  QryTemp1.CommandText := 'SELECT BB.TERMINAL_NAME,AA.TOTAL_INPUT,BB.TOTAL_FAIL,SUBSTR(BB.TOTAL_FAIL/AA.TOTAL_INPUT,1,5)*100 AS YIELD ' +
                          ' FROM ( SELECT PROCESS_NAME ,PDLine_Name,SUM(PASS_QTY+FAIL_QTY) TOTAL_INPUT ' +
                          ' FROM ( ' +
                          ' SELECT C.MODEL_NAME,D.PROCESS_NAME,E.PDLine_Name,A.PASS_QTY,A.FAIL_QTY,TO_NUMBER(TO_CHAR(A.WORK_DATE)||TRIM(TO_CHAR(A.WORK_TIME,''00''))) DATETIME ' +
                          ' FROM SAJET.G_SN_COUNT A,SAJET.SYS_PART B, SAJET.SYS_MODEL C ,SAJET.SYS_PROCESS D,SAJET.SYS_PDLINE E ' +
                          ' WHERE A.MODEL_ID=B.PART_ID AND B.MODEL_ID =C.MODEL_ID and A.process_ID=D.PROCESS_ID AND A.PDLINE_ID=E.PDLINE_ID ' +
                          ' AND A.WORK_ORDER NOT LIKE ''RM%'' and  A.PASS_QTY +A.FAIL_QTY <>0 AND C.MODEL_NAME =:MODEL_NAME and A.process_ID=:Process_ID ) ' +
                          ' WHERE  DATETIME > :STARTDATE AND DATETIME < :ENDDATE  GROUP BY PROCESS_NAME ,PDLine_Name order by PDLINE_NAME ) AA,  ' +
                          ' ( SELECT TERMINAL_NAME,PDLINE_NAME,SUM(NUM) AS TOTAL_FAIL ' +
                          ' FROM  ( SELECT D.TERMINAL_NAME,B.PDLINE_NAME,A.SERIAL_NUMBER,1 AS NUM ' +
                          ' FROM SAJET.g_sn_TRAVEL A,SAJET.SYS_PDLINE B,SAJET.SYS_PROCESS C ,SAJET.SYS_TERMINAL D ' +
                          ' WHERE A.PDLINE_ID=B.PDLINE_ID AND A.PROCESS_ID=C.PROCESS_ID AND A.TERMINAL_ID=D.TERMINAL_ID  AND SERIAL_NUMBER IN ' +
                          ' (select A.SERIAL_NUMBER from sajet.g_sn_defect_first A,SAJET.SYS_PART B,SAJET.SYS_MODEL C,SAJET.SYS_PROCESS D ' +
                          ' where A.MODEL_ID=B.PART_ID AND B.MODEL_ID=C.MODEL_ID and a.process_ID=d.process_id  AND REC_TIME>=TO_DATE(:StartTime,''YYYY-MM-DD HH24:MI:SS'') '  +
                          ' and REC_TIME<=TO_DATE(:EndTime,''YYYY-MM-DD HH24:MI:SS'') AND ntf_time is null  and A.WORK_ORDER NOT LIKE ''RM%'' ' +
                          ' AND C.MODEL_NAME=:MODEL_NAME and D.PROCESS_NAME=''FF'' ) AND A.PROCESS_ID=:Process_ID  ) ' +
                          ' GROUP BY TERMINAL_NAME,PDLINE_NAME) BB ' +
                          ' where AA.PDLINE_NAME=BB.PDLINE_NAME order by TERMINAL_NAME ' ;

    QryTemp1.Params.ParamByName('STARTDATE').AsString := sStart_Time;
    QryTemp1.Params.ParamByName('ENDDATE').AsString := sEnd_Time;
    //QryTemp1.Params.ParamByName('sStart_Time').AsString := sTime;
    //QryTemp1.Params.ParamByName('sEnd_Time').AsString := eTime;

    QryTemp1.Params.ParamByName('StartTime').AsString := sDStart_Time;
    QryTemp1.Params.ParamByName('EndTime').AsString := sDEnd_Time;
    QryTemp1.Params.ParamByName('MODEL_NAME').AsString := sModelName;
    QryTemp1.Params.ParamByName('Process_ID').AsString := g_processid;

    QryTemp1.Open;

end;

end.



