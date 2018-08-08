unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  MConnect, SConnect, {FileCtrl,} ObjBrkr, Menus,DateUtils,comobj,Variants,
  ComCtrls, TeeProcs, TeEngine, Chart, DbChart, Series, TeeShape, ArrowCha,
  GanttCh, BubbleCh;

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
    sPie: TPieSeries;
    RadioGroup1: TRadioGroup;
    sBar: TBarSeries;
    shorizbar: THorizBarSeries;
    sArea: TAreaSeries;
    sPoint: TPointSeries;
    SShape: TChartShape;
    sgantt: TGanttSeries;
    Sarrow: TArrowSeries;
    Sbubble: TBubbleSeries;
    GroupBox1: TGroupBox;
    CheckBoxlegend: TCheckBox;
    CheckBoxshowaxis: TCheckBox;
    CheckBox3D: TCheckBox;
    CheckBoxMarks: TCheckBox;
    Sbtnexport: TSpeedButton;
    Image1: TImage;
    SaveDialog1: TSaveDialog;
    cmbfactory: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure CheckBoxlegendClick(Sender: TObject);
    procedure CheckBoxshowaxisClick(Sender: TObject);
    procedure CheckBox3DClick(Sender: TObject);
    procedure CheckBoxMarksClick(Sender: TObject);
    procedure SbtnexportClick(Sender: TObject);
    procedure cmbfactoryChange(Sender: TObject);

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
    Function Addchart(strdate,stryield:string):boolean;
    Function DownloadSampleFile : String;
    procedure cleardata;
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);
  end;

var
  fMain: TfMain;
  FcID :string;

  
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
   stringgrid1.Cells[0,0]:='Sample';
   stringgrid1.Cells[0,1]:='Pass_qty';
   stringgrid1.Cells[0,2]:='Total_qty';
   stringgrid1.Cells[0,3]:='Yield(%)' ;

   ComboBoxProcessname.Clear ;
   comboboxmodelname.Clear ;
   cmbboxlinename.Clear ;
   sArea.Clear ;
  // sArrow.Clear ;
   sBar.Clear;
  // sBubble.Clear ;
   sFastline.Clear;
  // sGantt.Clear;
   sHorizbar.Clear;
   sPie.Clear;
   sPoint.Clear;
   //sShape.Clear;
end;

Function TfMain.Addchart(strdate,stryield:string):boolean;
begin
   with sArea do
   begin
     add(strtofloat(stryield),strdate);
   end;
  // with sArrow do
  // begin
   //   add(strtofloat(stryield),strdate);
   //end;
   with sBar do
   begin
     add(strtofloat(stryield),strdate);
   end;
   //with sBubble do
  // begin
  //    add(strtofloat(stryield),strdate);
  // end;
    with sFastline do
   begin
     add(strtofloat(stryield),strdate);
   end;
 //  with sGantt do
 //  begin
  //    add(strtofloat(stryield),strdate);
  // end;
    with sHorizbar do
   begin
     add(strtofloat(stryield),strdate);
   end;
   with sPie do
   begin
      add(strtofloat(stryield),strdate);
   end;
   with sPoint do
   begin
     add(strtofloat(stryield),strdate);
   end;
  // with sShape do
  // begin
   //  add(strtofloat(stryield),strdate);
  // end;

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
   sArea.Clear ;
  // sArrow.Clear ;
   sBar.Clear;
  // sBubble.Clear ;
   sFastline.Clear;
  // sGantt.Clear;
   sHorizbar.Clear;
   sPie.Clear;
   sPoint.Clear;
   //sShape.Clear;
    for i:=0 to stringgrid1.RowCount   do
     for j:=0 to stringgrid1.ColCount  do
       stringgrid1.Cells[j,i]:='';
   stringgrid1.Cells[0,0]:='Sample';
   stringgrid1.Cells[0,1]:='Pass_qty';
   stringgrid1.Cells[0,2]:='Total_qty';
   stringgrid1.Cells[0,3]:='Yield(%)' ;

   if datetimepicker1.DateTime >datetimepicker2.DateTime then
   begin
      MessageDlg('Start date > End date', mtInformation, [mbOk], 0);
      exit;
   end;

   idate:=0;
   strstartdate:=FormatDateTime( 'YYYYMMDD',DateTimePicker1.Date);
   strworkdate:=strstartdate;
   strenddate:=FormatDateTime( 'YYYYMMDD',DateTimePicker2.Date);

   strsql1:=' SELECT nvl(sum(pass_qty+repass_qty),0) as pass_qty,nvl(sum(fail_qty+refail_qty),0) as fail_qty  '
             +'  from sajet.G_SN_COUNT A ';
   IF comboboxmodelname.Text<>'' then
      strsql1:=strsql1 + ' , SAJET.SYS_MODEL B,SAJET.SYS_PART C ' ;
   if trim(editwo.Text)<>'' then
      strsql1:=strsql1 + ' ,SAJET.G_WO_BASE D ';
   if cmbboxlinename.Text <> '' then
      strsql1:=strsql1 + ' , SAJET.SYS_PDLINE E ';
   if comboboxprocessname.Text <>'' then
      strsql1:=strsql1 +' , sajet.sys_process F ';

   strsql1:=strsql1 + ' ,sajet.g_wo_base G where work_date=:workdate and work_time between :sstart and :ssend  '
                    +' and a.work_order=g.work_order and g.factory_id='''+fcid+''' ';
  IF comboboxmodelname.Text<>'' then
      strsql1:=strsql1 + ' and  A.MODEL_ID=C.PART_ID AND B.MODEL_ID=C.MODEL_ID  ' ;
  if trim(editwo.Text)<>'' then
  begin
      strsql1:=strsql1 + '  AND A.WORK_ORDER=D.WORK_ORDER ';
      IF comboboxmodelname.Text<>'' then
        strsql1:=strsql1 + ' AND D.MODEL_ID=C.PART_ID ' ;
  end;
  if cmbboxlinename.Text <> '' then
      strsql1:=strsql1 + ' AND A.PDLINE_ID=E.PDLINE_ID  ';
  if comboboxprocessname.Text <>'' then
      strsql1:=strsql1 +'  AND A.PROCESS_ID=F.PROCESS_ID ';


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
         IF comboboxmodelname.Text<>'' then
            params.CreateParam(ftstring,'model_name',ptinput);
         if trim(editwo.Text)<>'' then
            params.CreateParam(ftstring,'work_order',ptinput);
         if cmbboxlinename.Text <> '' then
            params.CreateParam(ftstring,'line_name',ptinput);
         if comboboxprocessname.Text <>'' then
            params.CreateParam(ftstring,'process_name',ptinput);

         IF comboboxmodelname.Text<>'' then
            strsql1:= strsql1+ ' and b.model_name=:model_name ' ;
         if trim(editwo.Text)<>'' then
            strsql1:= strsql1+ ' and d.work_order=:work_order ' ;
         if cmbboxlinename.Text <> '' then
            strsql1:= strsql1+ ' and e.pdline_name=:line_name ' ;
         if comboboxprocessname.Text <>'' then
            strsql1:= strsql1+ ' and f.process_name=:process_name ' ;
        
         commandtext:=strsql1;


         params.ParamByName('workdate').AsString := strworkdate;
         params.ParamByName('sstart').AsString :=strstart;
         params.ParamByName('ssend').AsString :=strend;
         IF comboboxmodelname.Text<>'' then
             params.ParamByName('model_name').AsString :=comboboxmodelname.Text;
         if trim(editwo.Text)<>'' then
              params.ParamByName('work_order').AsString := trim(editwo.Text);
         if cmbboxlinename.Text <> '' then
              params.ParamByName('line_name').AsString := cmbboxlinename.Text;
         if comboboxprocessname.Text <>'' then
              params.ParamByName('process_name').AsString :=  comboboxprocessname.Text;

         open;

          if fieldbyname('pass_qty').AsInteger  + fieldbyname('fail_qty').AsInteger  >0 then
          begin
               stringgrid1.Cells[icol,0]:=formatfloat('0000/00/00',strtoint(strworkdate))+'-'+formatfloat('00',strtoint(strstart))+'~'+formatfloat('00',strtoint(strend));
               stringgrid1.Cells[icol,1]:= fieldbyname('pass_qty').AsString  ;
               stringgrid1.Cells[icol,2]:= inttostr(fieldbyname('pass_qty').AsInteger  + fieldbyname('fail_qty').AsInteger ) ;
               stryield:=formatfloat('0.00',fieldbyname('pass_qty').AsInteger  / (fieldbyname('pass_qty').AsInteger   + fieldbyname('fail_qty').AsInteger  )*100 );
               stringgrid1.Cells[icol,3]:=stryield;
               Addchart(stringgrid1.Cells[icol,0],stringgrid1.Cells[icol,3]);
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

end;


procedure TfMain.Label5Click(Sender: TObject);
begin
     if   Sfastline.Active =true then
     begin
         Sfastline.Active:=false;
         Spie.Active := true;

     end
     else
     begin
         Sfastline.Active:=true;
         Spie.Active := false;
     end;
end;

procedure TfMain.RadioGroup1Click(Sender: TObject);
begin
  if (radiogroup1.ItemIndex =-1) or  (radiogroup1.ItemIndex >9) then
     exit
  else
     checkbox3d.Checked :=false;
     
  if radiogroup1.ItemIndex =0 then  //area
  begin
     sArea.Active :=true;
     sArrow.Active :=false;
     sBar.Active :=false;
     sBubble.Active :=false;
     sFastline.Active :=false;
     sGantt.Active :=false;
     sHorizbar.Active :=false;
     sPie.Active :=false;
     sPoint.Active :=false;
     sShape.Active :=false;
  end;
  if radiogroup1.ItemIndex =1 then  //sBar
  begin
     sArea.Active :=false;
     sArrow.Active :=false;
     sBar.Active :=true;
     sBubble.Active :=false;
     sFastline.Active :=false;
     sGantt.Active :=false;
     sHorizbar.Active :=false;
     sPie.Active :=false;
     sPoint.Active :=false;
     sShape.Active :=false;
  end;
  if radiogroup1.ItemIndex =2 then  //sFastline
  begin
     sArea.Active :=false;
     sArrow.Active :=false;
     sBar.Active :=false;
     sBubble.Active :=false;
     sFastline.Active :=true;
     sGantt.Active :=false;
     sHorizbar.Active :=false;
     sPie.Active :=false;
     sPoint.Active :=false;
     sShape.Active :=false;
  end;
  if radiogroup1.ItemIndex =3 then  //sHorizbar
  begin
     sArea.Active :=false;
     sArrow.Active :=false;
     sBar.Active :=false;
     sBubble.Active :=false;
     sFastline.Active :=false;
     sGantt.Active :=false;
     sHorizbar.Active :=true;
     sPie.Active :=false;
     sPoint.Active :=false;
     sShape.Active :=false;
  end;
  if radiogroup1.ItemIndex =4 then  //sPie
  begin
     sArea.Active :=false;
     sArrow.Active :=false;
     sBar.Active :=false;
     sBubble.Active :=false;
     sFastline.Active :=false;
     sGantt.Active :=false;
     sHorizbar.Active :=false;
     sPie.Active :=true;
     sPoint.Active :=false;
     sShape.Active :=false;
  end;
  if radiogroup1.ItemIndex =5 then  //sPoint
  begin
     sArea.Active :=false;
     sArrow.Active :=false;
     sBar.Active :=false;
     sBubble.Active :=false;
     sFastline.Active :=false;
     sGantt.Active :=false;
     sHorizbar.Active :=false;
     sPie.Active :=false;
     sPoint.Active :=true;
     sShape.Active :=false;
  end;
end;

procedure TfMain.CheckBoxlegendClick(Sender: TObject);
begin
   if checkboxlegend.Checked then
       chart1.Legend.Visible :=true
   else
       chart1.Legend.Visible :=false;
end;

procedure TfMain.CheckBoxshowaxisClick(Sender: TObject);
begin
   if checkboxshowaxis.Checked =true then
      chart1.AxisVisible :=true
   else
      chart1.AxisVisible :=false;
end;

procedure TfMain.CheckBox3DClick(Sender: TObject);
begin
    if checkbox3d.Checked then
    begin
       chart1.View3D :=true;
       if radiogroup1.ItemIndex <> 4 then  //sPie
          chart1.View3DOptions.Orthogonal:=true;
    end
    else
    begin
       chart1.View3D :=false;
       if radiogroup1.ItemIndex =4 then  //sPie
          chart1.View3DOptions.Orthogonal:=false;
    end;
end;

procedure TfMain.CheckBoxMarksClick(Sender: TObject);
begin
  if checkboxmarks.Checked then
  begin
     sArea.Marks.Visible:=true;
     sArrow.Marks.Visible:=true;
     sBar.Marks.Visible:=true;
     sBubble.Marks.Visible:=true;
     sFastline.Marks.Visible:=true;
     sGantt.Marks.Visible:=true;
     sHorizbar.Marks.Visible:=true;
     sPie.Marks.Visible:=true;
     sPoint.Marks.Visible:=true;
     sShape.Marks.Visible:=true;
  end
  else
  begin
     sArea.Marks.Visible :=false;
     sArrow.Marks.Visible :=false;
     sBar.Marks.Visible :=false;
     sBubble.Marks.Visible :=false;
     sFastline.Marks.Visible :=false;
     sGantt.Marks.Visible :=false;
     sHorizbar.Marks.Visible :=false;
     sPie.Marks.Visible :=false;
     sPoint.Marks.Visible :=false;
     sShape.Marks.Visible :=false;
  end
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
     inc(i);
     end;
end;

Function TfMain.DownloadSampleFile : String;
begin
    Result:=ExtractFilePath(Application.ExeName) + ExtractFileName('QueryYieldTChart.xlt')
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

end.



