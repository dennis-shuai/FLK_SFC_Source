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
    Label2: TLabel;
    CmbBoxalarmtype: TComboBox;
    Label3: TLabel;
    ComboBoxProcessname: TComboBox;
    DateTimePicker1: TDateTimePicker;
    Label6: TLabel;
    DateTimePicker2: TDateTimePicker;
    Label8: TLabel;
    Label9: TLabel;
    SaveDialog1: TSaveDialog;
    cmbfactory: TComboBox;
    Label5: TLabel;
    StringGrid1: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
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
    procedure getalarmtypebase;
    procedure getprocessname;
    procedure cleardata;
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
   DateTimePicker1.Date :=now-1;
   Datetimepicker2.Date :=now;
   for i:=0 to stringgrid1.RowCount   do
     for j:=0 to stringgrid1.ColCount  do
       stringgrid1.Cells[j,i]:='';
   stringgrid1.Cells[0,0]:='Rows';
   stringgrid1.Cells[1,0]:='type_name';
   stringgrid1.Cells[2,0]:='event_level';
   stringgrid1.Cells[3,0]:='factory';
   stringgrid1.Cells[4,0]:='pdline_name' ;
   stringgrid1.Cells[5,0]:='process_name';
   stringgrid1.Cells[6,0]:='terminal_name';
   stringgrid1.Cells[7,0]:='record_time' ;
   stringgrid1.Cells[8,0]:='event_desc' ;

   stringgrid1.ColWidths[0] :=40;
   stringgrid1.ColWidths[1]:=180;
   stringgrid1.ColWidths[2]:=50;
   stringgrid1.ColWidths[3]:=50 ;
   stringgrid1.ColWidths[4]:=100;
   stringgrid1.ColWidths[5]:=100;
   stringgrid1.ColWidths[6]:=100 ;
   stringgrid1.ColWidths[7]:=120 ;
   stringgrid1.ColWidths[8]:=950 ;

   ComboBoxProcessname.Clear ;
   cmbboxalarmtype.Clear ;
   cmbboxlinename.Clear ;
end;

procedure TfMain.getalarmtypebase;
begin
      with QryTemp do
        begin
          Close;
          commandtext:='select type_id,type_name from sajet.alarm_type_base where enaBled=''Y'' ORDER BY TYPE_NAME ASC ';
          open;

          if recordcount<>0 then
            begin
                first;
                cmbboxalarmtype.clear ;
                while not eof do
                   begin
                       cmbboxalarmtype.Items.Add(fieldbyname('type_name').AsString );
                       next;
                   end;
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
    Params.ParamByName('dll_name').AsString := 'QueryAlarmMail.dll';
    Open;
  end;
  cleardata;
  getalarmtypebase;
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
var i,j,irow:integer;
VAR strsql1:string;
var strenddate,strstartdate:string;
begin
   for i:=0 to stringgrid1.RowCount   do
     for j:=0 to stringgrid1.ColCount  do
       stringgrid1.Cells[j,i]:='';
   stringgrid1.Cells[0,0]:='ROWS';
   stringgrid1.Cells[1,0]:='type_name';
   stringgrid1.Cells[2,0]:='event_level';
   stringgrid1.Cells[3,0]:='factory';
   stringgrid1.Cells[4,0]:='pdline_name' ;
   stringgrid1.Cells[5,0]:='process_name';
   stringgrid1.Cells[6,0]:='terminal_name';
   stringgrid1.Cells[7,0]:='record_time' ;
   stringgrid1.Cells[8,0]:='event_desc' ;

   if datetimepicker1.DateTime >datetimepicker2.DateTime then
   begin
      MessageDlg('Start date > End date', mtInformation, [mbOk], 0);
      exit;
   end;

   strstartdate:=FormatDateTime('YYYYMMDD',DateTimePicker1.Date) ;

   strenddate:= FormatDateTime('YYYYMMDD',DateTimePicker2.Date) ;

   strsql1:= ' select f.type_name ,decode(event_level,2,''Waring'',3,''Error'') as event_level ,  '
            +' b.factory_code||'' ''||b.factory_desc as factory ,c.pdline_name,d.process_name,  '
            +' e.terminal_name,event_desc,record_time  '
            +' from sajet.alarm_event a,sajet.sys_factory b,sajet.sys_pdline c, '
            +' sajet.sys_process d, sajet.sys_terminal e,sajet.alarm_type_base f  '
            +' where a.factory_id=b.factory_id '
            +' and a.pdline_id=c.pdline_id  '
            +' and a.process_id=d.process_id  '
            +' and a.terminal_id=e.terminal_id   '
            +' and a.type_id=f.type_id  ' ;
            //+' order by a.event_id desc '
   IF cmbboxalarmtype.Text<>'' then
      strsql1:=strsql1 + ' and f.type_name = +'''+cmbboxalarmtype.Text +''' ' ;
   if cmbboxlinename.Text <> '' then
      strsql1:=strsql1 + ' and c.pdline_name = +'''+cmbboxlinename.Text+'''  ';
   if comboboxprocessname.Text <>'' then
      strsql1:=strsql1 +'  and d.process_name = +'''+comboboxprocessname.Text +'''  ';

   strsql1:=strsql1 +' and a.factory_id = +'''+fcid+''' ';
   strsql1:=strsql1 +' and to_char(a.record_time,''YYYYMMDD'') between +'''+ strstartdate +''' and +'''+strenddate+''' ';
   strsql1:=strsql1 +' order by a.event_id desc ';
   with qrydata do
      begin
         close;
         commandtext:=strsql1;
         open;

         irow:=1;
         while not eof do
         begin
           stringgrid1.Cells[0,irow]:=inttostr(irow);
           stringgrid1.Cells[1,irow]:=FIELDBYNAME('type_name').AsString ;
           stringgrid1.Cells[2,irow]:=fieldbyname('event_level').AsString ;
           stringgrid1.Cells[3,irow]:=fieldbyname('factory').AsString ;
           stringgrid1.Cells[4,irow]:=fieldbyname('pdline_name').AsString  ;
           stringgrid1.Cells[5,irow]:=fieldbyname('process_name').AsString ;
           stringgrid1.Cells[6,irow]:=fieldbyname('terminal_name').AsString ;
           stringgrid1.Cells[7,irow]:=fieldbyname('record_time').AsString  ;
           stringgrid1.Cells[8,irow]:=fieldbyname('event_desc').AsString  ;
           next;
           inc(irow);
           stringgrid1.RowCount:=irow;
         end;
     end;
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



