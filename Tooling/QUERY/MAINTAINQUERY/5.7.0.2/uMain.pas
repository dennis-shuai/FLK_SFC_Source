unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  MConnect, SConnect, {FileCtrl,} ObjBrkr, Menus,DateUtils,comobj,Variants,
  ComCtrls;

type
  TfMain = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryData: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    labCnt: TLabel;
    labcost: TLabel;
    SaveDialog2: TSaveDialog;
    qryReel: TClientDataSet;
    Image2: TImage;
    sbtnQuery: TSpeedButton;
    Image1: TImage;
    SBTNExport: TSpeedButton;
    DTPSTART: TDateTimePicker;
    DTPEND: TDateTimePicker;
    CMBBOXSTART: TComboBox;
    CMBBOXEND: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    CMBBOXTYPE: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    CMBBOXSTATUS: TComboBox;
    StringGrid1: TStringGrid;
    lblstatus: TLabel;
    procedure FormShow(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure LabTitle1Click(Sender: TObject);
    procedure SBTNExportClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    icol,irow:integer;
    maintainstandardtime:integer;
    procedure cleardata;
    procedure querytoolingtype;
    procedure querytoolingmaintain;
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);
    Function DownloadSampleFile : String;
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform;

procedure TfMain.CLEARDATA;
var i,j:integer;
BEGIN
   maintainstandardtime:=30;
   dtpstart.Date:=now;
   dtpend.Date :=now;
   cmbboxstart.ItemIndex :=0;
   cmbboxend.ItemIndex :=24;
   if cmbboxtype.Items.Count>=0 then
     cmbboxtype.ItemIndex :=0;
   cmbboxstatus.ItemIndex :=0;
   lblstatus.Caption :='';
   irow:=5;
   icol:=11;
   stringgrid1.FixedRows:=1;
   stringgrid1.FixedCols:=0;
   stringgrid1.ColCount :=icol;
   stringgrid1.Rowcount :=irow;
   for i:=0 to irow  do
     for j:=0 to icol do
       stringgrid1.Cells[icol,irow]:='';
   stringgrid1.Cells[0,0]:='項次';
   stringgrid1.Cells[1,0]:='日期' ;
   stringgrid1.Cells[2,0]:='TOOLING_SN' ;
   stringgrid1.Cells[3,0]:='維護開始時間' ;
   stringgrid1.Cells[4,0]:='維護原因';
   stringgrid1.Cells[5,0]:='維護完成時間' ;
   stringgrid1.Cells[6,0]:='維護項目';
   stringgrid1.Cells[7,0]:='維護總共用時(分)';
   stringgrid1.Cells[8,0]:='維護標准時間(分)';
   stringgrid1.Cells[9,0]:='維護效率%';
   stringgrid1.Cells[10,0]:='維護人' ;

   stringgrid1.ColWidths[0]:=25;
   stringgrid1.ColWidths[1]:=70;
   stringgrid1.ColWidths[2]:=90;
   stringgrid1.ColWidths[3]:=130;
   stringgrid1.ColWidths[4]:=130;
   stringgrid1.ColWidths[5]:=130;
   stringgrid1.ColWidths[6]:=130;
   stringgrid1.ColWidths[7]:=50;
   stringgrid1.ColWidths[8]:=30;
   stringgrid1.ColWidths[9]:=50;
   stringgrid1.ColWidths[10]:=70;
END;

procedure TfMain.querytoolingtype;
begin
      with QryTemp do
        begin
          Close;
          commandtext:='select distinct tooling_type from  sajet.sys_tooling where tooling_type is not null' ;
          open;

          if recordcount<>0 then
            begin
                first;
                cmbboxtype.Clear ; 
                while not eof do
                   begin
                       cmbboxtype.Items.Add(fieldbyname('tooling_type').AsString );
                       next; 
                   end;
            end;
        end;

end;

procedure TfMain.querytoolingmaintain;
var i,j:integer;
begin
      {if irow<=5 then
          irow:=5;
      stringgrid1.FixedCols :=0;
      stringgrid1.FixedRows :=1;
      stringgrid1.ColCount :=icol;
      stringgrid1.Rowcount :=irow;
      }
      for i:=1 to irow do
        for j:=0 to icol do
           stringgrid1.Cells[j,i]:='';
   with Qrydata do
       begin
          close;
          commandtext:= ' SELECT TO_CHAR(A.REPAIR_TIME,''YYYY-MM-DD'') AS DATA,B.TOOLING_SN,D.DEFECT_CODE||D.DEFECT_DESC AS MAINTAIN_DEFECT,A.DEFECT_TIME AS TO_MAINTAIN_TIME,  '
                      +' A.REPAIR_TIME as MAINTAINED_TIME,E.REASON_CODE||E.REASON_DESC AS MAINTAIN_item,  '
                      +' NVL(SUBSTR((A.REPAIR_TIME-A.DEFECT_TIME)*60*24,0,instr((A.REPAIR_TIME-A.DEFECT_TIME)*60*24,''.'' )-1) ,1)AS CUT_TIME , '
                      +' C.EMP_NAME  '
                      +' FROM SAJET.G_TOOLING_SN_REPAIR A,SAJET.SYS_TOOLING_SN B,SAJET.SYS_EMP C,SAJET.SYS_DEFECT D, '
                      +' SAJET.SYS_REASON E,    '
                      +' SAJET.SYS_TOOLING F    '
                      +' WHERE A.TOOLING_SN_ID=B.TOOLING_SN_ID AND A.REPAIR_USERID=C.EMP_ID AND A.DEFECT_ID=D.DEFECT_ID '
                      +' AND A.REASON_ID=E.REASON_ID '
                      +' AND B.TOOLING_ID=F.TOOLING_ID AND F.TOOLING_TYPE=:tooling_type '
                      +' AND A.STATUS=:status '
                      +' and to_char(A.REPAIR_TIME,''YYYYMMDDHH24'') BETWEEN :STARTTIME AND :ENDTIME ';
          params.ParamByName('tooling_type').AsString :=cmbboxtype.Text ;
          params.ParamByName('status').AsString :=copy(cmbboxstatus.Text,0,1 );
          params.ParamByName('starttime').AsString :=FormatDateTime('YYYYMMDD',DTPSTART.Date)+CMBBOXSTART.Text;
          Params.ParamByName('endtime').AsString:=formatdatetime('YYYYMMDD',DTPEND.Date )+CMBBOXEND.Text ;
          open;

      first;
      irow:=1;
      while not eof do
       begin
          stringgrid1.Cells[0,irow]:=inttostr(irow);
          stringgrid1.Cells[1,irow]:= fieldbyname('data').AsString ;
          stringgrid1.Cells[2,irow]:=fieldbyname('tooling_sn').AsString ;
          stringgrid1.Cells[3,irow]:= fieldbyname('TO_MAINTAIN_TIME').AsString ;
          stringgrid1.Cells[4,irow]:=fieldbyname('MAINTAIN_DEFECT').AsString ;
          stringgrid1.Cells[5,irow]:= fieldbyname('MAINTAINED_TIME').AsString ;
          stringgrid1.Cells[6,irow]:=fieldbyname('MAINTAIN_item').AsString ;
          stringgrid1.Cells[7,irow]:= fieldbyname('CUT_TIME').AsString ;
          stringgrid1.Cells[8,irow]:=inttostr(maintainstandardtime);
          stringgrid1.Cells[9,irow]:= copy(floattostr(maintainstandardtime*100 / strtoint(stringgrid1.Cells[7,irow])),0,6);
          stringgrid1.Cells[10,irow]:=fieldbyname('EMP_NAME').AsString ;
          inc(irow);
          next;
       end;
       if irow<=5 then
          irow:=5;
       stringgrid1.FixedCols :=0;
       stringgrid1.FixedRows :=1;
       stringgrid1.ColCount :=icol;
       stringgrid1.Rowcount :=irow;

       lblstatus.Caption :=inttostr(recordcount) ;
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
    Params.ParamByName('dll_name').AsString := 'MAINTAINQUERYDLL.DLL';
    Open;
  end;


  querytoolingtype;
  cleardata;
end;



procedure TfMain.sbtnQueryClick(Sender: TObject);
begin
   querytoolingmaintain;
end;

procedure TfMain.LabTitle1Click(Sender: TObject);
begin
    maintainstandardtime:= strtoint(InputBox('Input Box', '請輸入維護標准時間', '30'));
end;


procedure TfMain.SBTNExportClick(Sender: TObject);
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
begin
   row:=1;
   if irow>0 then
   for i:=0 to irow do
   begin
     MsExcel.ActiveSheet.range['A'+inttostr(1+row)]:=stringgrid1.Cells[0,i];
     MsExcel.ActiveSheet.range['B'+inttostr(1+row)]:=stringgrid1.Cells[1,i];
     MsExcel.ActiveSheet.range['C'+inttostr(1+row)]:=stringgrid1.Cells[2,i];
     MsExcel.ActiveSheet.range['D'+inttostr(1+row)]:=stringgrid1.Cells[3,i];
     MsExcel.ActiveSheet.range['E'+inttostr(1+row)]:=stringgrid1.Cells[4,i];
     MsExcel.ActiveSheet.range['F'+inttostr(1+row)]:=stringgrid1.Cells[5,i];
     MsExcel.ActiveSheet.range['G'+inttostr(1+row)]:=stringgrid1.Cells[6,i];
     MsExcel.ActiveSheet.range['H'+inttostr(1+row)]:=stringgrid1.Cells[7,i];
     MsExcel.ActiveSheet.range['I'+inttostr(1+row)]:=stringgrid1.Cells[8,i];
     MsExcel.ActiveSheet.range['J'+inttostr(1+row)]:=stringgrid1.Cells[9,i];
     MsExcel.ActiveSheet.range['K'+inttostr(1+row)]:=stringgrid1.Cells[10,i];
     inc(row);
   end;
end;

Function TfMain.DownloadSampleFile : String;
begin
    Result:=ExtractFilePath(Application.ExeName) + ExtractFileName('MAINTAINQUERY.xlt')
end;




end.




