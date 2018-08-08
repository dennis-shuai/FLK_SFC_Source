unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db,
  DBClient, MConnect, ObjBrkr, SConnect,GradPanel, Variants, comobj, Menus;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    SpeedButton5: TSpeedButton;
    Image2: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    QryTemp2: TClientDataSet;
    PageControl1: TPageControl;
    TabData: TTabSheet;
    GradPanel14: TGradPanel;
    Image7: TImage;
    sbtnSave: TSpeedButton;
    Image8: TImage;
    sbtnPrint: TSpeedButton;
    Label3: TLabel;
    Label4: TLabel;
    SaveDialog1: TSaveDialog;
    strgridData: TStringGrid;
    Image3: TImage;
    sbtnQuery: TSpeedButton;
    LabWO: TLabel;
    LblProcess: TLabel;
    DateTimePickerstart: TDateTimePicker;
    DateTimePickerend: TDateTimePicker;
    Label5: TLabel;
    Label7: TLabel;
    Lblrecordcount: TLabel;
    combStartHour: TComboBox;
    CombstartMinute: TComboBox;
    Combendhour: TComboBox;
    Combendminute: TComboBox;
    CombStartSecond: TComboBox;
    Combendsecond: TComboBox;
    ImageTitle: TImage;
    Labelline: TLabel;
    EditWO: TEdit;
    Editline: TEdit;
    EditProcess: TEdit;
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnQueryClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function GETwo(work_order:string): string;
    function GETPDLINEID(LINE_NAME:string): string;
    function GETPROCESSID(PROCESS_NAME:string): string;
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
  end;

var
  fDetail: TfDetail;
  icol,irow:integer;
implementation

uses uCommData, uSelect;
{$R *.DFM}

function Tfdetail.GETwo(work_order:string): string;
begin
    with qrytemp do
    begin
        RESULT:='XXX'  ;
        close;
        params.CreateParam(ftstring,'work_order',ptinput);
        commandtext:='select work_order from sajet.g_wo_base where work_order=:work_order and rownum=1 ';
        params.ParamByName('WORK_ORDER').AsString:=work_order;
        OPEN;

        IF NOT ISEMPTY THEN
        BEGIN
            RESULT:=FIELDBYNAME('WORK_ORDER').AsString ;
        END;
    end;
end;

function Tfdetail.GETPDLINEID(LINE_NAME:string): string;
begin
    with qrytemp do
    begin
        RESULT:='XXX'  ;
        close;
        params.CreateParam(ftstring,'work_order',ptinput);
        commandtext:='select pdline_id  from sajet.sys_pdline where pdline_name=:pdline_name and rownum=1 ';
        params.ParamByName('pdline_name').AsString:=line_name;
        OPEN;

        IF NOT ISEMPTY THEN
        BEGIN
            RESULT:=FIELDBYNAME('pdline_id').AsString ;
        END;
    end;
end;

function Tfdetail.GETPROCESSID(PROCESS_NAME:string): string;
begin
    with qrytemp do
    begin
        RESULT:='XXX'  ;
        close;
        params.CreateParam(ftstring,'PROCESS_NAME',ptinput);
        commandtext:='select PROCESS_ID  from sajet.sys_PROCESS where PROCESS_name=:PROCESS_name and rownum=1 ';
        params.ParamByName('process_name').AsString:=process_name;
        OPEN;

        IF NOT ISEMPTY THEN
        BEGIN
            RESULT:=FIELDBYNAME('PROCESS_id').AsString ;
        END;
    end;
end;

procedure TfDetail.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var i, j,iStartRow,iDiv,iMod: integer;
    vRange1:Variant;
begin
   istartrow:=2 ;
   for i := 0 to strgridData.RowCount  do
      BEGIN
          for j := 0 to strgridData.ColCount  do
            MsExcel.Worksheets['Sheet1'].Cells[i+iStartRow,j+1].value := strgridData.Cells[j,i];
      END ;
end;



procedure TfDetail.FormShow(Sender: TObject);
var sYear:string;
    i:integer;
begin  //GetReportName;
  with strgridData do
  begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=10;
           ColCount  :=2;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=100;
           cells[0,0]:='SN';
           colwidths[1]:=150;
           cells[1,0]:='生產時間';
  end;
    lblrecordcount.Caption :='';
    DateTimePickerstart.Date:=now;
    DateTimePickerend.Date :=now+1 ;
    editwo.Clear ;
    editline.Clear ;
    editprocess.Clear ;
end;

procedure TfDetail.sbtnSaveClick(Sender: TObject);
var
  sFileName, My_FileName: string;
  MsExcel, MsExcelWorkBook: Variant;
  i: Integer;
begin
  if (not QryData.Active) or (QryData.IsEmpty) then Exit;
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'xls';
  SaveDialog1.Filter := 'All Files(*.xls)|*.xls';

  My_FileName := ExtractFilePath(Application.ExeName)+'TravelReport.xlt';

  if not FileExists(My_FileName) then
  begin
    showmessage('Error!-The Excel File ' + My_FileName + ' can''t be found.');
    exit;
  end;

  if Sender = sbtnSave then
  begin
    if SaveDialog1.Execute then
      sFileName := SaveDialog1.FileName
    else
      exit;  
  end;

  try
    MsExcel := CreateOleObject('Excel.Application');
    MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);

    MsExcel.Worksheets['Sheet1'].select;
    SaveExcel(MsExcel, MsExcelWorkBook);
    if Sender = sbtnSave then
    begin
      MsExcelWorkBook.SaveAs(sFileName);
      showmessage('Save Excel OK!!');
    end;
    if Sender = sbtnPrint then
    begin
      WindowState := wsMinimized;
      MsExcel.Visible := TRUE;
      MsExcel.WorkSheets['Sheet1'].PrintPreview;
      WindowState := wsMaximized;
    end;
  except
    ShowMessage('Could not start Microsoft Excel.');
  end;
  MsExcelWorkBook.close(False);
  MsExcel.Application.Quit;
  MsExcel := Null;

end;

procedure TfDetail.FormClose(Sender: TObject; var Action: TCloseAction);
begin  
  Action := caFree;
end;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
var sStartDate,sEndDate: string;
    sstarttime,sendtime:string;
    i:integer;
    strwo,strlineid,strprocessid :string;
begin
   sStartDate:='';
   sEndDate:=''  ;
   sStartDate:=FormatDateTime('YYYYMMDD',datetimepickerstart.Date);
   sEndDate:=FormatDateTime('YYYYMMDD',datetimepickerEND.Date);

   sstarttime:=trim(sstartdate)+trim(combstarthour.Text)+trim(combstartminute.Text)+trim(combstartsecond.Text);
   sendtime:=trim(senddate)+trim(combendhour.Text)+trim(combendminute.Text)+trim(combendsecond.Text);

   if trim(editwo.Text)='' then
   begin
      showmessage('Please input WO!');
      exit;
   end
   else
   begin
      strwo:=getwo(trim(editwo.Text));
      if strwo='XXX' then
      begin
          showmessage('Not Find The WO  '+ EDITWO.Text );
          exit;
      end;
   end;


   if trim(editLINE.Text)='' then
   begin
      showmessage('Please input line!');
      exit;
   end
   else
   begin
      strlineid:=getpdlineid(trim(editline.Text));
      if strlineid='XXX' then
      begin
          showmessage('Not Find The line_name  '+ EDITline.Text);
          exit;
      end;
   end;

   if trim(editprocess.Text)='' then
   begin
      showmessage('Please input process!');
      exit;
   end
   else
   begin
      strprocessid:=getprocessid(trim(editprocess.Text));
      if strprocessid='XXX' then
      begin
          showmessage('Not Find The process_name  '+ EDITprocess.Text);
          exit;
      end;
   end;

  for i:= 1 to strgridData.ROWCount do
    strgridData.ROWs[i].Clear;

  with QryData do
  begin
    Close;
    commandtext:=' SELECT SERIAL_NUMBER ,OUT_PROCESS_TIme FROM SAJET.G_SN_TRAVEL '
                +' WHERE WORK_ORDER=:WORK_ORDER AND PROCESS_ID=:PROCESS_ID '
                +' AND to_char(OUT_PROCESS_TIME,''YYYYMMDDHH24MISS'') BETWEEN :starttime AND :endtime  '
                +' AND PDLINE_ID=:PDLINE_ID ';
    params.ParamByName('work_order').AsString :=strwo;
    params.ParamByName('process_id').AsString :=strprocessid;
    params.ParamByName('pdline_id').AsString :=strlineid;     
    params.ParamByName('starttime').AsString :=sstarttime;
    params.ParamByName('endtime').AsString :=sendtime;

    Open;
    if IsEmpty then
    begin
      lblrecordcount.Caption :='TOTAL:0';
      Showmessage('No Data');
      exit;
    end;

   strgridData.RowCount:=10;
   irow:=0;
   icol:=0;

   while not eof do
    begin
        IROW:=IROW+1;
        strgridData.Cells[0,irow]:=fieldbyname('serial_number').asstring ;
        Strgriddata.Cells[1,irow]:=fieldbyname('OUT_PROCESS_TIme').AsString   ;
        next;
        Strgriddata.RowCount:=IROW+1;
        lblrecordcount.Caption :='TOTAL:'+ inttostr(irow);
    END;
  end;
end;

end.

