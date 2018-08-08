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
    Series1: TFastLineSeries;
    Series2: TFastLineSeries;
    Series3: TFastLineSeries;
    procedure FormShow(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure SbtnexportClick(Sender: TObject);
    procedure cmbfactoryChange(Sender: TObject);
    procedure ComboBoxmodelnameChange(Sender: TObject);
    procedure cmbboxlinenameChange(Sender: TObject);
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
    procedure getlinename;
    procedure getprocessname;
    procedure getmodelname;
    procedure gettargetyield(modelid,pdlineid,processid:string);
    Function Addchart(strdate,stryield:string):boolean;
    Function DownloadSampleFile : String;
    procedure cleardata;
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);
  end;

var
  fMain: TfMain;
  FcID :string;
  G_target_yield,g_alarm_yield,g_lower_yield:string;
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
   stringgrid1.Cells[0,1]:='Pass_qty';
   stringgrid1.Cells[0,2]:='Total_qty';
   stringgrid1.Cells[0,3]:='Real Yield(%)' ;
   stringgrid1.Cells[0,4]:='Target Yield(%)';
   stringgrid1.Cells[0,5]:='Alarm Yield(%)';
   stringgrid1.Cells[0,6]:='Lsl Yield(%)';

   ComboBoxProcessname.Clear ;
   comboboxmodelname.Clear ;
   cmbboxlinename.Clear ;
   sFastline.Clear;   // real yield
   series1.Clear ;    // target yield
   series2.Clear ;    // alarm yield
   series3.Clear ;    // lsl yield

end;

Function TfMain.Addchart(strdate,stryield:string):boolean;
begin

  with sFastline do
   begin
     add(strtofloat(stryield),strdate);
   end;

  with series1 do
  begin
      add(strtofloat(g_target_yield),strdate) ;
  end;

  With series2 do
  begin
      add(strtofloat(g_alarm_yield),strdate)  ;
  end;

  With series3 do
  begin
      add(strtofloat(g_lower_yield),strdate)  ;
  end;
end;

procedure TfMain.gettargetyield(modelid,pdlineid,processid:string);
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
          g_target_yield:=formatfloat('0.00',(1000000-fieldbyname('target_limit').AsInteger) / 1000000 * 100)   ;
          g_alarm_yield:=formatfloat('0.00',(1000000-fieldbyname('alarm_limit').AsInteger) / 1000000 * 100)   ;
          g_lower_yield:=formatfloat('0.00',(1000000-fieldbyname('lower_limit').AsInteger) / 1000000 * 100)   ;
        end
        else
        begin
           g_target_yield:='99.00';
           g_alarm_yield:='97.00';
           g_lower_yield:='95.00';
        end;
    end;
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
    Params.ParamByName('dll_name').AsString := 'QueryYieldTChart.DLL';
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
VAR strsql1:string;
var strworkdate,strenddate,strstartdate:string;
var stryield:string;
begin

   sFastline.Clear;
   series1.Clear;
   series2.Clear ;
   series3.Clear ;
    for i:=0 to stringgrid1.RowCount   do
     for j:=0 to stringgrid1.ColCount  do
       stringgrid1.Cells[j,i]:='';
   stringgrid1.ColWidths[0]:=100 ;
   stringgrid1.Cells[0,0]:='Sample';
   stringgrid1.Cells[0,1]:='Pass_qty';
   stringgrid1.Cells[0,2]:='Total_qty';
   stringgrid1.Cells[0,3]:='Real Yield(%)' ;
   stringgrid1.Cells[0,4]:='Target Yield(%)';
   stringgrid1.Cells[0,5]:='Alarm Yield(%)';
   stringgrid1.Cells[0,6]:='Lsl Yield(%)';

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
      MessageDlg('Please select one Line name!', mtInformation, [mbOk], 0);
      exit;
   end;

   if ComboBoxProcessname.Text  ='' then
   begin
      MessageDlg('Please select one Process name!', mtInformation, [mbOk], 0);
      exit;
   end;

   gettargetyield(g_modelid,g_pdlineid,g_processid);

   idate:=0;
   strstartdate:=FormatDateTime( 'YYYYMMDD',DateTimePicker1.Date);
   strworkdate:=strstartdate;
   strenddate:=FormatDateTime( 'YYYYMMDD',DateTimePicker2.Date);

   strsql1:=' SELECT nvl(sum(pass_qty+repass_qty),0) as pass_qty,nvl(sum(fail_qty+refail_qty),0) as fail_qty  '
           +'  from sajet.G_SN_COUNT A ,SAJET.SYS_PART b, sajet.g_wo_base c '
           +'  where work_date=:workdate and work_time between :sstart and :ssend  '
           +'  and a.model_id=b.part_id and b.model_id ='''+g_modelid+''' '
           +'  and a.pdline_id='''+g_pdlineid+''' '
           +'  and a.process_id ='''+g_processid+''' '
           +'  and a.work_order=c.work_order and c.factory_id='''+fcid+''' ';

  if trim(editwo.Text)<>'' then
  begin
      strsql1:=strsql1 + '  AND c.WORK_ORDER='''+trim(editwo.Text)+''' ';
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
               stringgrid1.Cells[icol,1]:= fieldbyname('pass_qty').AsString  ;
               stringgrid1.Cells[icol,2]:= inttostr(fieldbyname('pass_qty').AsInteger  + fieldbyname('fail_qty').AsInteger ) ;
               stryield:=formatfloat('0.00',fieldbyname('pass_qty').AsInteger  / (fieldbyname('pass_qty').AsInteger   + fieldbyname('fail_qty').AsInteger  )*100 );
               stringgrid1.Cells[icol,3]:=stryield;
               stringgrid1.Cells[icol,4]:=g_target_yield;
               stringgrid1.Cells[icol,5]:=g_alarm_yield;
               stringgrid1.Cells[icol,6]:=g_lower_yield;
               Addchart(stringgrid1.Cells[icol,0],stringgrid1.Cells[icol,3]);
               //series1.Add(99.5,stringgrid1.Cells[icol,0]);
              // series2.Add(95.5,stringgrid1.Cells[icol,0]);

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
    Result:=ExtractFilePath(Application.ExeName) + ExtractFileName('QueryKPITChart.xlt')
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

end.



