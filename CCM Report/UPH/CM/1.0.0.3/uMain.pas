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
    Label7: TLabel;
    ComboBoxsampletype: TComboBox;
    Chart1: TChart;
    StringGrid1: TStringGrid;
    Sbtnexport: TSpeedButton;
    Image1: TImage;
    SaveDialog1: TSaveDialog;
    cmbfactory: TComboBox;
    QryTop3Defect: TClientDataSet;
    QryTop3DefectYeild: TClientDataSet;
    Series1: TFastLineSeries;
    Label5: TLabel;
    edtWO: TEdit;
    SpeedButton1: TSpeedButton;
    Image3: TImage;
    LV_Role: TListView;
    Label4: TLabel;
    DateTimePicker2: TDateTimePicker;
    cmbStartHour: TComboBox;
    cmbEndHour: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure SbtnexportClick(Sender: TObject);
    procedure cmbfactoryChange(Sender: TObject);
    procedure ComboBoxmodelnameChange(Sender: TObject);
    procedure ComboBoxProcessnameChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure DateTimePicker1CloseUp(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    icol,irow:integer;
    Griviseday:integer;
    strworkdate,strenddate,strstartdate:string;
    procedure getprocessname;
    procedure getmodelname;
    procedure gettargetfail(modelid,pdlineid,processid:string);
    Function DownloadSampleFile : String;
    procedure cleardata;
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);
    procedure QueryOutput( QryTemp1:TClientDataSet;START_DATE,END_DATE,sLineName:string;sTime:Integer);
    procedure QueryLine( QryTemp1:TClientDataSet;START_DATE,END_DATE:string);
    procedure QueryDateInfo(QryTemp1:TClientDataSet;START_DATE,END_DATE,sLineName:string);
  end;

var
  fMain: TfMain;
  FcID :string;
  G_target_fail,g_alarm_fail,g_lower_fail:string;
  g_modelid,g_pdlineid,g_processid,g_stageid :string;
  TopErrCode:string;
  sModelName:string;
  sLineName:string;

implementation

{$R *.DFM}
uses uDllform,UFrmList;

procedure TfMain.cleardata;
var i,j: integer;
begin
   DateTimePicker1.Date :=now;
   DateTimePicker2.Date :=tomorrow;
   ComboBoxsampletype.ItemIndex:=0;
   ComboBoxsampletype.Enabled:=False;

   for i:=0 to stringgrid1.RowCount   do
     for j:=0 to stringgrid1.ColCount  do
       stringgrid1.Cells[j,i]:='';
   stringgrid1.ColWidths[0]:=80 ;
   
   ComboBoxProcessname.Clear ;
   comboboxmodelname.Clear ;
   series1.Clear ;    // target fail

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




procedure TfMain.getprocessname;
var
  i,sIndex:Integer;
begin

    ComboBoxProcessname.Clear ;
    strstartdate:=FormatDateTime( 'YYYYMMDD',DateTimePicker1.Date);
    strenddate:=FormatDateTime( 'YYYYMMDD',DateTimePicker2.Date);
     with QryTemp do
     begin
        Close;
        Params.CreateParam(ftstring,'StartTime',ptInput);
        Params.CreateParam(ftstring,'EndTime',ptInput);
        commandtext:=  ' select Distinct (B.PROCESS_NAME) PROCESS_NAME,B.PROCESS_CODE FROM SAJET.G_SN_COUNT A ,SAJET.SYS_PROCESS B ,'+
                       ' SAJET.SYS_PART C,SAJET.SYS_MODEL D WHERE b.ENABLED=''Y'''+
                       ' AND A.PROCESS_ID=B.PROCESS_ID AND TO_NUMBER(TO_CHAR(A.WORK_DATE)||TRIM(TO_CHAR(A.WORK_TIME,'+
                       ' ''00''))) >= :StartTime AND TO_NUMBER(TO_CHAR(A.WORK_DATE)||TRIM(TO_CHAR(A.WORK_TIME,'+
                       ' ''00''))) < :EndTime AND (A.PASS_QTY+A.FAIL_QTY <> 0) AND B.PROCESS_CODE IS NOT NULL AND B.STAGE_ID =10022 '+
                       '  AND A.MODEL_ID=C.PART_ID AND C.MODEL_ID =D.MODEL_ID ' +
                       '  ORDER BY B.PROCESS_CODE ASC ';
        Params.ParamByName('StartTIme').AsString := strstartdate+cmbStartHour.Text ;
        Params.ParamByName('EndTime').AsString :=  strenddate+cmbEndHour.Text ;
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
    strstartdate:=FormatDateTime( 'YYYYMMDD',DateTimePicker1.Date);
    strenddate:=FormatDateTime( 'YYYYMMDD',DateTimePicker2.Date);
      with QryTemp do
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftstring,'StartTime',ptInput);
          Params.CreateParam(ftstring,'EndTime',ptInput);
          commandtext:=' select Distinct (b.Model_Name) Model_Name FROM SAJET.G_SN_COUNT A ,SAJET.SYS_MODEL B,sajet.SYS_PART C WHERE b.ENABLED=''Y'''+
                       ' AND B.MODEL_ID=C.MODEL_ID AND TO_NUMBER(TO_CHAR(A.WORK_DATE)||TRIM(TO_CHAR(A.WORK_TIME,'+
                       ' ''00''))) >= :StartTime AND TO_NUMBER(TO_CHAR(A.WORK_DATE)||TRIM(TO_CHAR(A.WORK_TIME,'+
                       ' ''00''))) < :EndTime AND (A.PASS_QTY+A.FAIL_QTY <> 0)  AND C.PART_ID = A.MODEL_ID  '+
                       '  ORDER BY b.model_NAME ASC ';
          Params.ParamByName('StartTIme').AsString := strstartdate+cmbStartHour.Text ;
          Params.ParamByName('EndTime').AsString :=  strenddate+cmbEndHour.Text ;
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

  cleardata;
  getmodelname;

  cmbStartHour.Style :=csDropDownList;
  cmbEndHour.Style := csDropDownList;
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
  i,j,k,icol,Index: integer;
  strstart,strend :string;
  iseq,idate :integer;
  strsql1:string;
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

   stringgrid1.ColWidths[0]:=80 ;
   stringgrid1.Cells[0,0]:=' Line  \  Hour ';

   if ComboBoxmodelname.Text ='' then
   begin
      MessageDlg('Please select one Model name!', mtInformation, [mbOk], 0);
      exit;
   end;

   if LV_Role.Items.Count<>0  then
   begin
      stringgrid1.RowCount:=LV_Role.Items.Count+1;
      for Index:=0 to Lv_Role.Items.Count-1 do
      begin
          stringgrid1.Cells[0,Index+1]:=Trim(Lv_Role.Items[Index].Caption);
          if sLineName='' then
               sLineName:=''''+Trim(Lv_Role.Items[Index].Caption)+''''
          else
               sLineName:=sLineName +',''' + Trim(Lv_Role.Items[Index].Caption) + '''';
      end;
   end else begin
     sLineName:='';
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



   strstartdate:=FormatDateTime( 'YYYYMMDD',DateTimePicker1.Date);
   strworkdate:=strstartdate;
   strenddate:=FormatDateTime( 'YYYYMMDD',DateTimePicker2.Date);

   try
       if sLineName='' then
       begin
           QueryLine(QryData,strworkdate+cmbStartHour.Text,strenddate+cmbEndHour.Text);
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

       QueryDateInfo( QryTemp,strworkdate+cmbStartHour.Text,strenddate+cmbEndHour.Text,sLineName);
       stringgrid1.ColCount :=  QryTemp.RecordCount+1;
       if not QryTemp.IsEmpty then begin
            QryTemp.First;
            for i:=0 to QryTemp.RecordCount-1 do  begin
               stringgrid1.Cells[i+1,0] := Copy(QryTEmp.fieldbyName('DateTime').Asstring,9,2);
               stringgrid1.ColWidths[i+1] :=30;
               QryTemp.Next;
            end;
       end ;


       QueryOutput( QryData,strworkdate+cmbStartHour.Text,strenddate+cmbEndHour.Text,sLineName,i);
       QryData.first;
       for i:=0 to QryData.ReCordCount-1 do begin
          for j:=1 to stringgrid1.rowCount-1 do begin
              if QryData.fieldbyName('PDLINE_NAME').Asstring = stringgrid1.cells[0,j]  then begin
                    for  k:=1 to stringgrid1.ColCount-1 do begin
                         if  Copy(QryData.fieldbyName('DateTime').Asstring,9,2)= stringgrid1.cells[k,0] then  begin
                              stringgrid1.cells[k,j] :=QryData.fieldByName('Output_QTY').AsString;
                         end;
                    end;
              end;
          end;
          QryData.Next;
       end;

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

                    if stringgrid1.rowCount=2 then
                    begin
                        Chart1.Series[i-1].Marks.Visible:=True;
                        Chart1.Series[i-1].Marks.Style:=smsValue;
                    end ;

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
  SaveDialog1.Filter := 'All Files(*.xlsx)|*.xlsx';
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
var row:integer;
var icol,irow :integer;
begin
  Chart1.CopyToClipboardMetafile(True);
  MsExcel.ActiveSheet.range['A1'].PasteSpecial;
   for icol :=0 to stringgrid1.ColCount   -1  do
     for irow :=0 to stringgrid1.RowCount   -1  do
     begin
          MsExcel.ActiveSheet.cells[irow+18,icol+1]:=stringgrid1.Cells[icol,iRow];
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
   GetProcessName;
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



procedure TfMain.QueryLine(QryTemp1:TClientDataSet;START_DATE,END_DATE:string);
var
  sSTART_DATE,sEND_DATE:string;
  sStart_Time,sEnd_Time:string;
begin
    

    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'STARTDATE',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'ENDDATE',ptInput);

    QryTemp1.Params.CreateParam(ftstring,'MODEL_NAME',ptInput);


    QryTemp1.CommandText := ' SELECT distinct PDLINE_NAME  ' +
                            ' from ( SELECT D.PDLINE_NAME,A.output_qty,TO_NUMBER(TO_CHAR(A.WORK_DATE)||TRIM(TO_CHAR(A.WORK_TIME,''00''))) DATETIME ' +
                            ' FROM SAJET.G_SN_COUNT A,SAJET.SYS_PART B, SAJET.SYS_MODEL C ,SAJET.SYS_PDLINE D ,SAJET.SYS_PROCESS E ' +
                            ' WHERE A.MODEL_ID=B.PART_ID AND B.MODEL_ID=C.MODEL_ID AND A.PDLINE_ID=D.PDLINE_ID AND A.PROCESS_ID=E.PROCESS_ID ' +
                            ' AND A.output_qty <> 0 AND A.MODEL_ID=B.PART_ID AND B.MODEL_ID =C.MODEL_ID AND C.MODEL_NAME like :MODEL_NAME ' +
                            ' and A.STAGE_ID=10022 ' ;

    if  Trim(edtWO.Text)<>'' then
    begin
        QryTemp1.CommandText:=QryTemp1.CommandText +  ' AND A.Work_Order= '''+Trim(edtWO.Text)+''' '  ;
    end;
    if  g_processid<>'' then
    begin
        QryTemp1.CommandText:=QryTemp1.CommandText +  ' AND a.process_id= '''+g_processid+''' ';
    end;

    QryTemp1.CommandText:=QryTemp1.CommandText + ' ) WHERE  DATETIME > =:STARTDATE AND DATETIME < :ENDDATE  order by PDLINE_NAME ' ;


    QryTemp1.Params.ParamByName('STARTDATE').AsString := START_DATE;
    QryTemp1.Params.ParamByName('ENDDATE').AsString := END_DATE;
    QryTemp1.Params.ParamByName('MODEL_NAME').AsString := sModelName +'%';
    QryTemp1.Open;
end;


procedure TfMain.QueryOutput(QryTemp1:TClientDataSet;START_DATE,END_DATE,sLineName:string;sTime:Integer);
begin
    
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'STARTDATE',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'ENDDATE',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'MODEL_NAME',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'PROCESS',ptInput);

    QryTemp1.CommandText := 'SELECT D.PDLINE_NAME,nvl(sum(Output_Qty),0) Output_Qty ,A.DateTime  '+
                            ' FROM ( SELECT MODEL_ID,Stage_ID,PDLINE_ID,PROCESS_ID,OUTPUT_QTY,TO_NUMBER(TO_CHAR(WORK_DATE)||TRIM(TO_CHAR(WORK_TIME,''00''))) DATETIME '+
                            ' FROM SAJET.G_SN_COUNT ) A,SAJET.SYS_PART B, SAJET.SYS_MODEL C ,SAJET.SYS_PDLINE D ,SAJET.SYS_PROCESS E ' +
                            ' WHERE A.MODEL_ID=B.PART_ID AND B.MODEL_ID=C.MODEL_ID AND A.PDLINE_ID=D.PDLINE_ID AND A.PROCESS_ID=E.PROCESS_ID ' +
                            '  AND A.MODEL_ID=B.PART_ID AND B.MODEL_ID =C.MODEL_ID AND C.MODEL_NAME like :MODEL_NAME ' +
                            ' and  A.DateTime >=:STARTDATE ANd  A.DateTime<:ENDDATE and A.STAGE_ID=10022 and a.process_id= :PROCESS ' ;

    if sLineName<>'' then
    begin
       QryTemp1.CommandText:=QryTemp1.CommandText +  ' AND D.PDLINE_Name in ( ' + sLineName + ' )'  ;
    end;

    QryTemp1.CommandText:=QryTemp1.CommandText + '  GROUP BY D.PDLINE_NAME,A.DateTime ' ;

    QryTemp1.Params.ParamByName('STARTDATE').AsString := START_DATE;
    QryTemp1.Params.ParamByName('ENDDATE').AsString := END_DATE;
    QryTemp1.Params.ParamByName('MODEL_NAME').AsString := sModelName+'%';
    QryTemp1.Params.ParamByName('PROCESS').AsString := g_processid;
    QryTemp1.Open;
end;

procedure TfMain.QueryDateInfo(QryTemp1:TClientDataSet;START_DATE,END_DATE,sLineName:String);
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'STARTDATE',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'ENDDATE',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'MODEL_NAME',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'PROCESS_ID',ptInput);

    QryTemp1.CommandText := 'SELECT  distinct A.DateTime  '+
                            ' FROM ( SELECT MODEL_ID,Stage_ID,PDLINE_ID,PROCESS_ID,OUTPUT_QTY,TO_NUMBER(TO_CHAR(WORK_DATE)||TRIM(TO_CHAR(WORK_TIME,''00''))) DATETIME '+
                            ' FROM SAJET.G_SN_COUNT ) A,SAJET.SYS_PART B, SAJET.SYS_MODEL C ,SAJET.SYS_PDLINE D ,SAJET.SYS_PROCESS E ' +
                            ' WHERE A.MODEL_ID=B.PART_ID AND B.MODEL_ID=C.MODEL_ID AND A.PDLINE_ID=D.PDLINE_ID AND A.PROCESS_ID=E.PROCESS_ID ' +
                            '  AND A.MODEL_ID=B.PART_ID AND B.MODEL_ID =C.MODEL_ID AND C.MODEL_NAME like :MODEL_NAME ' +
                            ' and  A.DateTime >=:STARTDATE ANd  A.DateTime<:ENDDATE and A.STAGE_ID=10022 and a.process_id= '''+g_processid+''' ' ;

    if sLineName<>'' then
    begin
       QryTemp1.CommandText:=QryTemp1.CommandText +  ' AND D.PDLINE_Name in ( ' + sLineName + ' )'  ;
    end;

    QryTemp1.CommandText:=QryTemp1.CommandText + ' Order By A.DateTime ';

    QryTemp1.Params.ParamByName('STARTDATE').AsString := START_DATE;
    QryTemp1.Params.ParamByName('ENDDATE').AsString := END_DATE;
    QryTemp1.Params.ParamByName('MODEL_NAME').AsString := sModelName +'%';
    QryTemp1.Open;
end;



procedure TfMain.SpeedButton1Click(Sender: TObject);
var 
    Index,j :integer;
    strstartdate:string;
begin
   if ComboBoxmodelname.Text ='' then
   begin
      MessageDlg('Please select one Model name!', mtInformation, [mbOk], 0);
      exit;
   end;

   strstartdate:=FormatDateTime( 'YYYYMMDD',DateTimePicker1.Date);


   FrmList:=TFrmList.Create(nil);
   FrmList.PL_Left.Caption:=' Line List' ;
   FrmList.PL_Right.Caption:='Choosen Line List' ;

   QueryLine(QryData,strstartdate+'00',strstartdate+'23');
   if not QryData.IsEmpty then begin
       QryData.First;
       for j:=0  to QryData.RecordCount-1 do begin
            FrmList.LB_Left.Items.Add(QryData.fieldbyName('PDLine_Name').asString);
            QryData.Next;
       end;
   end else begin
        Exit;
   end;
   Try
        if LV_Role.Items.Count<>0 then begin
           FrmList.LB_Right.Clear;
           For Index:=0 to Lv_ROle.Items.Count-1 do
           FrmList.LB_Right.Items.Add(Lv_ROle.Items[Index].Caption);
        End;
        if FrmList.ShowModal=MrOK then  begin
           Lv_Role.Clear;
          if FrmList.LB_Right.Items.Count<>0 then
             For Index:=0 to FrmList.LB_Right.Items.Count-1 do
                 Lv_ROle.Items.Add().Caption:=FrmList.LB_Right.Items[Index];
        End;
   Finally
        FrmList.Free;
   End;
end;

procedure TfMain.DateTimePicker1CloseUp(Sender: TObject);
begin
    getModelName;
end;

end.




