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
    cmbboxlinename: TComboBox;
    Label4: TLabel;
    Label2: TLabel;
    ComboBoxmodelname: TComboBox;
    Label3: TLabel;
    ComboBoxProcessname: TComboBox;
    DateTimePicker1: TDateTimePicker;
    Label6: TLabel;
    Label7: TLabel;
    ComboBoxsampletype: TComboBox;
    Chart1: TChart;
    StringGrid1: TStringGrid;
    DateTimePicker2: TDateTimePicker;
    Label8: TLabel;
    Label9: TLabel;
    Sbtnexport: TSpeedButton;
    Image1: TImage;
    SaveDialog1: TSaveDialog;
    cmbfactory: TComboBox;
    QryTop3Defect: TClientDataSet;
    QryTop3DefectYeild: TClientDataSet;
    Series1: TFastLineSeries;
    Label5: TLabel;
    edtWO: TEdit;
    procedure FormShow(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure SbtnexportClick(Sender: TObject);
    procedure cmbfactoryChange(Sender: TObject);
    procedure ComboBoxmodelnameChange(Sender: TObject);
    procedure cmbboxlinenameChange(Sender: TObject);
    procedure ComboBoxProcessnameChange(Sender: TObject);
    procedure ChkViewrealfailClick(Sender: TObject);
    procedure ChkViewtargetfailClick(Sender: TObject);
    procedure CHkViewalarmfailClick(Sender: TObject);
    procedure ChkViewlslfailClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    icol,irow:integer;
    Griviseday:integer;
    procedure getlinename;
    procedure getprocessname;
    procedure getmodelname;
    procedure gettargetfail(modelid,pdlineid,processid:string);
    Function Addchart(strdate,strfail,strdpoint:string):boolean;
    Function DownloadSampleFile : String;
    procedure cleardata;
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);
    procedure viewtchart;

    //procedure QueryTop3DEFECTCode(QryTemp1:TClientDataSet;Start_Time,End_Time:string);
    //procedure QueryTop3DEFECTYield(QryTemp1:TClientDataSet;START_DATE,END_DATE,Start_Time,End_Time,ALL_Defect_Code:string);
    //procedure QueryAllFailYield(QryTemp1:TClientDataSet;START_DATE,END_DATE,Start_Time,End_Time:string);

    procedure QueryOutput( QryTemp1:TClientDataSet;START_DATE:string;sTime:Integer);
    procedure QueryLine( QryTemp1:TClientDataSet;START_DATE,END_DATE:string);
      
  end;

var
  fMain: TfMain;
  FcID :string;
  G_target_fail,g_alarm_fail,g_lower_fail:string;
  g_modelid,g_pdlineid,g_processid,g_stageid :string;
  TopErrCode:string;
  sModelName:string;

implementation

{$R *.DFM}
uses uDllform;

procedure TfMain.cleardata;
var i,j: integer;
begin
   DateTimePicker1.Date :=now-6;
   Datetimepicker2.Date :=now;
   DateTimePicker1.Enabled:=False;
   DateTimePicker2.Enabled:=False;

   ComboBoxsampletype.ItemIndex:=0;
   //ComboBoxsampletype.ItemIndex:=ComboBoxsampletype.Items.Count-1;
   //ComboBoxsampletype.Enabled:=False;

   for i:=0 to stringgrid1.RowCount   do
     for j:=0 to stringgrid1.ColCount  do
       stringgrid1.Cells[j,i]:='';
   stringgrid1.ColWidths[0]:=100 ;


   ComboBoxProcessname.Clear ;
   comboboxmodelname.Clear ;
   cmbboxlinename.Clear ;
   series1.Clear ;    // target fail

end;

Function TfMain.Addchart(strdate,strfail,strdpoint:string):boolean;
begin

end;

procedure TfMain.gettargetfail(modelid,pdlineid,processid:string);
begin
      with QryTemp do
      begin
          Close;
          commandtext:='select target_limit,alarm_limit,lower_limit '
                      +'  from SAJET.SYS_pdline_PROCESS_RATE '
                      +'  where model_id = '''+modelid+''' '
                      +' and pdline_id ='''+pdlineid+''' '
                      +' and process_id = '''+processid+''' '
                      +' and rownum=1 ';
          open;

        if not isempty then
        begin
          g_target_fail:=formatfloat('0.00',fieldbyname('target_limit').AsInteger / 1000000 * 100)   ;
          g_alarm_fail:=formatfloat('0.00',fieldbyname('alarm_limit').AsInteger / 1000000 * 100)   ;
          g_lower_fail:=formatfloat('0.00',fieldbyname('lower_limit').AsInteger / 1000000 * 100)   ;
        end
        else
        begin
           g_target_fail:='1.00';
           g_alarm_fail:='3.00';
           g_lower_fail:='5.00';
        end;
    end;
end;


procedure TfMain.getlinename;
begin
      with QryTemp do
        begin
          Close;
          commandtext:='SELECT * FROM SAJET.SYS_PDLINE WHERE PDLINE_DESC LIKE ''CM%'' ORDER BY PDLINE_NAME ASC ';
          open;

          if recordcount<>0 then
            begin
                first;
                cmbboxlinename.Clear ;
                cmbboxlinename.Items.Add('');
                while not eof do
                   begin
                       cmbboxlinename.Items.Add(fieldbyname('pdline_name').AsString );
                       next;
                   end;
            end;
        end;
end;

procedure TfMain.getprocessname;
var
  i,sIndex:Integer;
begin
     ComboBoxProcessname.Clear ;


     with QryTemp do
     begin
        Close;
        commandtext:=' select * from SAJET.SYS_process where  ENABLED=''Y'' AND STAGE_ID=10022 and process_code is not null ' +
                     ' and process_code not in (select max(process_code) FROM SAJET.SYS_process WHERE ENABLED=''Y'' AND STAGE_ID=10022 and process_code is not null) ' +
                     ' order by process_code desc';
        open;

        if recordcount<>0 then
        begin
            first;
            i:=0;
            ComboBoxProcessname.Clear ;
            while not eof do
            begin
               i:=i+1;
               ComboBoxProcessname.Items.Add(fieldbyname('process_name').AsString );
               if fieldbyname('process_name').AsString='FQC' then
                   sIndex:=i;
               next;
            end;
            ComboBoxProcessname.ItemIndex:=sIndex-1;
        end;
     end;
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
  getlinename;
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
  sPDLine:string;
  series:TFastLineSeries ;
begin
    for j := (Chart1.SeriesList.Count - 1) downto 0 do
      Chart1.Series[j].Free;

    for i:=0 to stringgrid1.RowCount   do
     for j:=0 to stringgrid1.ColCount  do
       stringgrid1.Cells[j,i]:='';

   stringgrid1.ColWidths[0]:=100 ;
   stringgrid1.Cells[0,0]:='Sample';

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
   
   if cmbboxlinename.Text  ='' then
   begin
      g_pdlineid:='';
   end;

   if g_processid='' then
   begin
     with QryTemp do
     begin
         Close;
         commandtext:='select process_id FROM SAJET.SYS_PROCESS WHERE PROCESS_name= '''+ComboBoxProcessname.Text+''' and rownum=1 ';
         open;

         g_processid:=fieldbyname('process_id').AsString ;
     end;
   end;


   idate:=0;
   strstartdate:=FormatDateTime( 'YYYYMMDD',DateTimePicker1.Date);
   strworkdate:=strstartdate;
   strenddate:=FormatDateTime( 'YYYYMMDD',DateTimePicker2.Date);

   sDefect_Start:=FormatDateTime( 'YYYY/MM/DD',DateTimePicker1.Date);
   sDefect_End:=FormatDateTime( 'YYYY/MM/DD',DateTimePicker2.Date);

   try

       if cmbboxlinename.Text<>'' then
       begin
            stringgrid1.RowCount:=2;
            stringgrid1.Cells[0,1]:=cmbboxlinename.Text ;
       end else begin
           QueryLine(QryData,strworkdate+strstart,strenddate+strend);

           if not QryData.IsEmpty then begin
               stringgrid1.RowCount:=QryData.RecordCount+1;
               QryData.First;
               for j:=0  to QryData.RecordCount-1 do begin
                    stringgrid1.Cells[0,j+1]:=QryData.FieldByName('PDLINE_Name').AsString;
                    QryData.Next;
               end;
           end else begin
               Exit;
           end;
       end;


       if ComboBoxsampletype.ItemIndex=0 then      //1 hour
           iseq:=1
       else if ComboBoxsampletype.ItemIndex=1 then  //2 hours
           iseq:=2
       else if ComboBoxsampletype.ItemIndex=2 then  //3 hours
           iseq:=3
       else if  ComboBoxsampletype.ItemIndex=3 then //4 hours
           iseq:=4
       else if ComboBoxsampletype.ItemIndex=4 then  //6 hours
           iseq:=6
       else if  ComboBoxsampletype.ItemIndex=5 then //8 hours
           iseq:=8
       else if  ComboBoxsampletype.ItemIndex=6 then //12 hours
           iseq:=12
       else if  ComboBoxsampletype.ItemIndex=7 then //24 hours  one day
           iseq:=24 ;


       icol:=1;

        while strworkdate<=strenddate do
        begin
           strend:='0';
           strstart:=strend;
           strend:=inttostr(strtoint(strstart) + iseq - 1) ;

           for i:=1 to 24 div iseq  do
           begin
               if Length(strstart)<2 then
                  strstart:='0' + strstart;
               if Length(strend)<2 then
                  strend:='0' + strend;

               QueryOutput( QryData,strworkdate,i);


               If not QryData.IsEmpty then begin
                    stringgrid1.colCount:=icol+1;
                    stringgrid1.ColWidths[icol]:=80;
                    stringgrid1.Cells[icol,0]:=formatfloat('0000/00/00',strtoint(strworkdate))+' '+strstart;
                    QryData.First;
                    for j:=0 to QryData.RecordCount -1 do begin
                        sPDLine:= QryData.FieldByName('PDLine_Name').AsString;

                        for K:=1 to stringgrid1.rowCount-1 do begin
                            if stringgrid1.Cells[0,k] = sPDLine  then
                                stringgrid1.Cells[icol,k]   :=   QryData.FieldByName('Output').AsString ;
                        end;
                        QryData.Next;
                    end;
                    inc(icol);
               end;

               strstart:=inttostr(strtoint(strend) + 1) ;
               strend:=inttostr(strtoint(strstart) + iseq - 1 ) ;

           end; // edit   當天
          inc(idate);
          strstartdate:=FormatDateTime( 'YYYYMMDD',DateTimePicker1.Date+idate);
          strworkdate:=strstartdate;
        end;  //end 所選日期

       for i:=1 to stringgrid1.rowCount-1 do
          for j:=1 to stringgrid1.colCount - 1 do
            if  (stringgrid1.Cells[0,i]<>'') AND (stringgrid1.Cells[j,0]<>'') THEN
                if  stringgrid1.Cells[j,i]='' then
                    stringgrid1.Cells[j,i]:='0';

       if stringgrid1.Cells[1,0]<>'' then
       begin
             for i:=1 to stringgrid1.rowCount-1 do begin
                if stringgrid1.Cells[0,i]<>'' then
                begin
                    series:=TFastLineSeries.Create(Chart1);
                    Chart1.AddSeries(Series);
                    series.LinePen.Width:=3;
                    Chart1.Series[i-1].VertAxis := aLeftAxis;
                    Chart1.Series[i-1].Title:=stringgrid1.Cells[0,i];
                    randomize;

                    for j := 1 to stringgrid1.colCount - 1 do
                      Chart1.Series[i-1].Add(strtofloat(stringgrid1.Cells[j,i]), stringgrid1.Cells[j,0]);

                   { if stringgrid1.rowCount=2 then
                    begin
                        Chart1.Series[i-1].Marks.Visible:=True;
                        Chart1.Series[i-1].Marks.Style:=smsValue;
                    end ;
                    }
                end;
            end;
       end;

   except
      QryData.Close;
      exit;
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

procedure TfMain.cmbboxlinenameChange(Sender: TObject);
begin
   with QryTemp do
   begin
       Close;
       commandtext:='select pdline_id FROM SAJET.SYS_pdline WHERE pdline_name= '''+cmbboxlinename.Text+''' and rownum=1 ';
       open;

       g_pdlineid:=fieldbyname('pdline_id').AsString ;
   end;
end;

procedure TfMain.ComboBoxProcessnameChange(Sender: TObject);
begin
   with QryTemp do
   begin
       Close;
       commandtext:='select process_id FROM SAJET.SYS_PROCESS WHERE PROCESS_name= '''+ComboBoxProcessname.Text+''' and rownum=1 ';
       open;

       g_processid:=fieldbyname('process_id').AsString ;
   end;
end;

procedure tfmain.viewtchart;
var icol:integer;
begin
   if stringgrid1.Cells[1,0]='' then exit; //無數據則退出

   series1.Clear;

   for icol:=1 to stringgrid1.ColCount-1 do
       Addchart(stringgrid1.Cells[icol,0],stringgrid1.Cells[icol,3],stringgrid1.Cells[icol,6]);
end;

procedure TfMain.ChkViewrealfailClick(Sender: TObject);
begin
    viewtchart;
end;

procedure TfMain.ChkViewtargetfailClick(Sender: TObject);
begin
     viewtchart;
end;

procedure TfMain.CHkViewalarmfailClick(Sender: TObject);
begin
    viewtchart;
end;

procedure TfMain.ChkViewlslfailClick(Sender: TObject);
begin
    viewtchart;
end;


procedure TfMain.QueryLine(QryTemp1:TClientDataSet;START_DATE,END_DATE:string);
var
  sSTART_DATE,sEND_DATE:string;
  sStart_Time,sEnd_Time:string;
begin
    sSTART_DATE:=Copy(START_DATE,1,8) ;
    sEND_DATE:=Copy(END_DATE,1,8);
    sStart_Time:=Copy(START_DATE,Length(START_DATE)-2+1,2);
    sEnd_Time:=Copy(END_DATE,Length(END_DATE)-2+1,2);

    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'STARTDATE',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'ENDDATE',ptInput);

    QryTemp1.Params.CreateParam(ftstring,'MODEL_NAME',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'PROCESS_ID',ptInput);

    QryTemp1.CommandText := ' select D.PDLINE_NAME,SUM(A.PASS_QTY+A.REPASS_QTY) AS OUTPUT ' +
                            ' from SAJET.G_SN_COUNT A,SAJET.SYS_PART B,SAJET.SYS_MODEL C,SAJET.SYS_PDLINE D,SAJET.SYS_PROCESS E ' +
                            ' WHERE A.MODEL_ID=B.PART_ID AND B.MODEL_ID=C.MODEL_ID AND A.PDLINE_ID=D.PDLINE_ID AND A.PROCESS_ID=E.PROCESS_ID ' +
                            ' and A.WORK_DATE>=:STARTDATE and A.WORK_DATE<=:ENDDATE AND A.PROCESS_ID=:PROCESS_ID AND C.MODEL_NAME=:MODEL_NAME ' ;
    if  cmbboxlinename.Text<>'' then
    begin
        QryTemp1.CommandText:=QryTemp1.CommandText +  ' AND A.PDLINE_ID= '''+g_pdlineid+''' '  ;
    end;
    if  Trim(edtWO.Text)<>'' then
    begin
        QryTemp1.CommandText:=QryTemp1.CommandText +  ' AND A.Work_Order= '''+Trim(edtWO.Text)+''' '  ;
    end;
    QryTemp1.CommandText:=QryTemp1.CommandText + ' GROUP BY D.PDLINE_NAME ORDER BY PDLINE_NAME ' ;


    QryTemp1.Params.ParamByName('STARTDATE').AsString := sSTART_DATE;
    QryTemp1.Params.ParamByName('ENDDATE').AsString := sEND_DATE;

    QryTemp1.Params.ParamByName('MODEL_NAME').AsString := sModelName;
    QryTemp1.Params.ParamByName('PROCESS_ID').AsString := g_processid;
    QryTemp1.Open;
end;


procedure TfMain.QueryOutput(QryTemp1:TClientDataSet;START_DATE:string;sTime:Integer);
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'STARTDATE',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'sTime',ptInput);

    QryTemp1.Params.CreateParam(ftstring,'MODEL_NAME',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'PROCESS_ID',ptInput);

    QryTemp1.CommandText := ' select C.MODEL_NAME,D.PDLINE_NAME,E.PROCESS_NAME,A.WORK_DATE,SUM(A.PASS_QTY+A.REPASS_QTY) AS OUTPUT ' +
                            ' from SAJET.G_SN_COUNT A,SAJET.SYS_PART B,SAJET.SYS_MODEL C,SAJET.SYS_PDLINE D,SAJET.SYS_PROCESS E ' +
                            ' WHERE A.MODEL_ID=B.PART_ID AND B.MODEL_ID=C.MODEL_ID AND A.PDLINE_ID=D.PDLINE_ID AND A.PROCESS_ID=E.PROCESS_ID ' +
                            ' and A.WORK_DATE=:STARTDATE AND A.WORK_TIME=:sTime and  A.PROCESS_ID=:PROCESS_ID AND C.MODEL_NAME=:MODEL_NAME ' ;
    if  cmbboxlinename.Text<>'' then
    begin
        QryTemp1.CommandText:=QryTemp1.CommandText +  ' AND A.PDLINE_ID= '''+g_pdlineid+''' '  ;
    end;
    if  Trim(edtWO.Text)<>'' then
    begin
        QryTemp1.CommandText:=QryTemp1.CommandText +  ' AND A.Work_Order= '''+Trim(edtWO.Text)+''' '  ;
    end;
    QryTemp1.CommandText:=QryTemp1.CommandText + ' GROUP BY C.MODEL_NAME,D.PDLINE_NAME,E.PROCESS_NAME,A.WORK_DATE ORDER BY PDLINE_NAME ' ;


    QryTemp1.Params.ParamByName('STARTDATE').AsString := START_DATE;
    QryTemp1.Params.ParamByName('sTime').AsInteger := sTime;

    QryTemp1.Params.ParamByName('MODEL_NAME').AsString := sModelName;
    QryTemp1.Params.ParamByName('PROCESS_ID').AsString := g_processid;
    QryTemp1.Open;
end;


end.



