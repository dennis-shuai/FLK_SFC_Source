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
    Label5: TLabel;
    Editwo: TEdit;
    Label2: TLabel;
    ComboBoxmodelname: TComboBox;
    Label3: TLabel;
    ComboBoxProcessname: TComboBox;
    DateTimePicker1: TDateTimePicker;
    Label6: TLabel;
    Label7: TLabel;
    ComboBoxsampletype: TComboBox;
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
    Series1: TLineSeries;
    GroupBox1: TGroupBox;
    ChkboxFailDPPM: TCheckBox;
    Label11: TLabel;
    ChKBOXFAILPARTDPPM: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure SbtnexportClick(Sender: TObject);
    procedure cmbfactoryChange(Sender: TObject);
    procedure ComboBoxmodelnameChange(Sender: TObject);
    procedure cmbboxlinenameChange(Sender: TObject);
    procedure ComboBoxProcessnameChange(Sender: TObject);
    procedure ChKBOXFAILPARTDPPMClick(Sender: TObject);
    procedure ChkboxFailDPPMClick(Sender: TObject);


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
    Function Addchart(strdate,str1,str2:string):boolean;
    Function DownloadSampleFile : String;
    procedure cleardata;
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);
    procedure viewtchart;
  end;

var
  fMain: TfMain;
  FcID :string;
  g_modelid,g_pdlineid,g_processid :string;

implementation

{$R *.DFM}
uses uDllform;

procedure TfMain.cleardata;
var i,j: integer;
begin
   DateTimePicker1.Date :=now;
   Datetimepicker2.Date :=now;
   editwo.Clear ;
   for i:=0 to stringgrid1.RowCount   do
     for j:=0 to stringgrid1.ColCount  do
       stringgrid1.Cells[j,i]:='';
   stringgrid1.ColWidths[0]:=100 ;
   stringgrid1.Cells[0,0]:='Sample';
   stringgrid1.Cells[0,1]:='Fail_qty';
   stringgrid1.Cells[0,2]:='Total_qty';
   stringgrid1.Cells[0,3]:='Fail DPPM';
   stringgrid1.Cells[0,4]:='Fail_Part_qty';
   stringgrid1.Cells[0,5]:='Total_part_qty' ;
   stringgrid1.Cells[0,6]:='Fail_Part DPPM';

   ComboBoxProcessname.Clear ;
   comboboxmodelname.Clear ;
   cmbboxlinename.Clear ;
   sFastline.Clear;   //fail DPPM
   series1.Clear;   //fail Part DPPM

end;

Function TfMain.Addchart(strdate,str1,str2:string):boolean;
begin
  if chkboxfaildppm.Checked then
  with sFastline do
   begin
     add(strtofloat(str1),strdate);
   end;

  if chkboxfailpartdppm.Checked then
  with series1 do
  begin
      add(strtofloat(Str2),strdate) ;
  end;
  {
  With series2 do
  begin
      add(strtofloat(g_alarm_fail),strdate)  ;
  end;

  With series3 do
  begin
      add(strtofloat(g_lower_fail),strdate)  ;
  end;

  With series4 do
  begin
      add(strtofloat(strdpoint),strdate)  ;
  end;
  }
end;



procedure TfMain.getlinename;
begin
      with QryTemp do
        begin
          Close;
          commandtext:='select * FROM SAJET.SYS_PDLINE WHERE ENABLED=''Y'' ORDER BY PDLINE_NAME ASC ';
          open;

          if recordcount<>0 then
            begin
                first;
                cmbboxlinename.Clear ;
                while not eof do
                   begin
                       cmbboxlinename.Items.Add(fieldbyname('pdline_name').AsString );
                       next;
                   end;
            end;
        end;
end;

procedure TfMain.getprocessname;
begin
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
    Params.ParamByName('dll_name').AsString := 'QueryPartDPPMChart.DLL';
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
var i,j,icol: integer;
var strstart,strend :string;
var iseq,idate :integer;
VAR strsql1,strsql2,strsql3:string;
var strworkdate,strenddate,strstartdate:string;
begin

   sFastline.Clear;
   series1.Clear;
  // series2.Clear ;
  // series3.Clear ;
  // series4.Clear ;
    for i:=0 to stringgrid1.RowCount   do
     for j:=0 to stringgrid1.ColCount  do
       stringgrid1.Cells[j,i]:='';
   stringgrid1.ColWidths[0]:=120 ;
   stringgrid1.Cells[0,0]:='Sample';
   stringgrid1.Cells[0,1]:='Fail_qty';
   stringgrid1.Cells[0,2]:='Total_qty';
   stringgrid1.Cells[0,3]:='Fail DPPM';
   stringgrid1.Cells[0,4]:='Fail_Part_qty';
   stringgrid1.Cells[0,5]:='Total_part_qty' ;
   stringgrid1.Cells[0,6]:='Fail_Part DPPM';

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
   {
   if cmbboxlinename.Text  ='' then
   begin
      MessageDlg('Please select one Line name!', mtInformation, [mbOk], 0);
      exit;
   end;
   }
   if ComboBoxProcessname.Text  ='' then
   begin
      MessageDlg('Please select one Process name!', mtInformation, [mbOk], 0);
      exit;
   end;

   idate:=0;
   strstartdate:=FormatDateTime( 'YYYYMMDD',DateTimePicker1.Date);
   strworkdate:=strstartdate;
   strenddate:=FormatDateTime( 'YYYYMMDD',DateTimePicker2.Date);

   //strsql1 get pass and fail qty
   strsql1:=' SELECT nvl(sum(pass_qty+repass_qty),0) as pass_qty,nvl(sum(fail_qty+refail_qty),0) as fail_qty  '
           +'  from sajet.G_SN_COUNT A ,SAJET.SYS_PART b, sajet.g_wo_base c '
           +'  where work_date=:workdate and work_time between :sstart and :ssend  '
           +'  and a.model_id=b.part_id and b.model_id ='''+g_modelid+''' '
          // +'  and a.pdline_id='''+g_pdlineid+''' '
           +'  and a.process_id ='''+g_processid+''' '
           +'  and a.work_order=c.work_order and c.factory_id='''+fcid+''' ';

   //strsql2 get total part qty
      strsql2:=' SELECT  NVL(SUM((NVL(PASS_QTY,0)+NVL(REPASS_QTY,0)+NVL(FAIL_QTY,0)+NVL(REFAIL_QTY,0)) * NVL(D.part_QTY,0)),0) AS total_part_QTY '
           +'  from sajet.G_SN_COUNT A ,SAJET.SYS_PART b, sajet.g_wo_base c,sajet.sys_part_point d '
           +'  where work_date=:workdate and work_time between :sstart and :ssend  '
           +'  and a.model_id=b.part_id and b.model_id ='''+g_modelid+''' '
         //  +'  and a.pdline_id='''+g_pdlineid+''' '
           +'  and a.process_id ='''+g_processid+''' '
           +'  and a.work_order=c.work_order and c.factory_id='''+fcid+''' '
           +'  and a.model_id=d.part_id ';

   //strsql3 get repair part qty
    strsql3:=' SELECT nvl(sum(d.part_qty),0 ) as repair_part_qty'
           +'  from sajet.G_SN_defect A ,SAJET.SYS_PART b, sajet.g_wo_base c,sajet.g_sn_repair_point d '
           +'  where to_char(a.rec_time,''YYYYMMDDHH24'') between :startrec_time and :endrec_time  '
           +'  and a.model_id=b.part_id and b.model_id ='''+g_modelid+''' '
          // +'  and a.pdline_id='''+g_pdlineid+''' '
           +'  and a.process_id ='''+g_processid+''' '
           +'  and a.work_order=c.work_order and c.factory_id='''+fcid+''' '
           +'  and a.recid=d.first_recid ';

  if trim(cmbboxlinename.Text)<>'' then
  begin
      strsql1:=strsql1  +'  and a.pdline_id='''+g_pdlineid+''' ';

      strsql2:=strsql2  +'  and a.pdline_id='''+g_pdlineid+''' ';

      strsql3:=strsql3  +'  and a.pdline_id='''+g_pdlineid+''' ';
  end;


  if trim(editwo.Text)<>'' then
  begin
      strsql1:=strsql1 + '  AND c.WORK_ORDER='''+trim(editwo.Text)+''' ';

      strsql2:=strsql2 + '  AND c.WORK_ORDER='''+trim(editwo.Text)+''' ';

      strsql3:=strsql3 + '  AND c.WORK_ORDER='''+trim(editwo.Text)+''' ';
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
      with qrydata do
      begin
         close;
         params.CreateParam(ftstring,'workdate',ptinput);
         params.CreateParam(ftstring,'sstart',ptinput);
         params.CreateParam(ftstring,'ssend',ptinput);

         commandtext:=strsql1;

         params.ParamByName('workdate').AsString := strworkdate;
         params.ParamByName('sstart').AsString :=strstart;
         params.ParamByName('ssend').AsString :=strend;
         open;

          if fieldbyname('pass_qty').AsInteger  + fieldbyname('fail_qty').AsInteger  >0 then
          begin
               stringgrid1.Cells[icol,0]:=formatfloat('0000/00/00',strtoint(strworkdate))+'-'+formatfloat('00',strtoint(strstart))+'~'+formatfloat('00',strtoint(strend));
               stringgrid1.Cells[icol,1]:= fieldbyname('fail_qty').AsString  ;
               stringgrid1.Cells[icol,2]:= inttostr(fieldbyname('pass_qty').AsInteger  + fieldbyname('fail_qty').AsInteger ) ;
               //fail DPPM
               stringgrid1.Cells[icol,3]:= formatfloat('0',(fieldbyname('fail_qty').AsInteger / (fieldbyname('pass_qty').AsInteger  + fieldbyname('fail_qty').AsInteger)) * 1000000);
              // strfail:=formatfloat('0.000',fieldbyname('fail_qty').AsInteger  / (fieldbyname('pass_qty').AsInteger   + fieldbyname('fail_qty').AsInteger  )*100 );

               if chkboxfailpartdppm.Checked then //查詢fail part DPPM的數據
               begin
                    if fieldbyname('fail_qty').AsInteger  >0 then
                     with qrytemp do
                     begin
                           close;
                           params.CreateParam(ftstring,'startrec_time',ptinput);
                           params.CreateParam(ftstring,'endrec_time',ptinput);

                           commandtext:=strsql3;

                           if strtoint(strstart)<=9 then
                               params.ParamByName('startrec_time').AsString := strworkdate+'0'+strstart
                           else
                               params.ParamByName('startrec_time').AsString := strworkdate+strstart;
                           if strtoint(strend)<=9 then
                               params.ParamByName('endrec_time').AsString :=strworkdate+'0'+strend
                           else
                               params.ParamByName('endrec_time').AsString :=strworkdate+strend;
                           open;

                           stringgrid1.Cells[icol,4]:=fieldbyname('repair_part_qty').AsString;
                           close;
                     end
                     else
                         stringgrid1.Cells[icol,4]:='0';

                   
                     with qrytemp do
                     begin
                          close;
                          params.CreateParam(ftstring,'workdate',ptinput);
                          params.CreateParam(ftstring,'sstart',ptinput);
                          params.CreateParam(ftstring,'ssend',ptinput);

                          commandtext:=strsql2;

                          params.ParamByName('workdate').AsString := strworkdate;
                          params.ParamByName('sstart').AsString :=strstart;
                          params.ParamByName('ssend').AsString :=strend;
                          open;

                          stringgrid1.Cells[icol,5]:=fieldbyname('total_part_qty').AsString;
                          close;
                     end;

                     // stringgrid1.Cells[icol,6] FAIL PART DPPM
                     if strtoint(stringgrid1.Cells[icol,5]) >0 then
                        stringgrid1.Cells[icol,6]:= formatfloat('0',(strtoint(stringgrid1.Cells[icol,4])/ strtoint(stringgrid1.Cells[icol,5])) * 1000000)
                     else
                        stringgrid1.Cells[icol,6]:='0';
                end
                else //不查詢fail part DPPM的數據
                begin
                    stringgrid1.Cells[icol,4]:='0';
                    stringgrid1.Cells[icol,5]:='0';
                    stringgrid1.Cells[icol,6]:='0';
                end;

               Addchart(stringgrid1.Cells[icol,0],stringgrid1.Cells[icol,3],stringgrid1.Cells[icol,6]);

               inc(icol);
               stringgrid1.ColCount :=icol;
          end;
          strstart:=inttostr(strtoint(strend) + 1) ;
          strend:=inttostr(strtoint(strstart) + iseq - 1 ) ;
        end;
     end; // edit   當天
    inc(idate);
    strstartdate:=FormatDateTime( 'YYYYMMDD',DateTimePicker1.Date+idate);
    strworkdate:=strstartdate;
   end;  //end 所選日期

   //series1.Active :=true;
   //series2.Active :=true;

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
   with QryTemp do
   begin
       Close;
       commandtext:='select model_id FROM SAJET.SYS_model WHERE model_name= '''+ComboBoxmodelname.Text+''' and rownum=1 ';
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
   sFastline.Clear;   //fail DPPM
   series1.Clear;   //fail Part DPPM
   for icol:=1 to stringgrid1.ColCount-1 do
       Addchart(stringgrid1.Cells[icol,0],stringgrid1.Cells[icol,3],stringgrid1.Cells[icol,6]);
end;

procedure TfMain.ChKBOXFAILPARTDPPMClick(Sender: TObject);
begin
   viewtchart;
end;

procedure TfMain.ChkboxFailDPPMClick(Sender: TObject);
begin
   viewtchart;
end;

end.



