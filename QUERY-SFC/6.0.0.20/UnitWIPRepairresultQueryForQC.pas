unit UnitWIPRepairresultQueryForQC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, ComCtrls, Grids, StdCtrls;

type
  TFormWipRepairresultforQC = class(TForm)
    Label1: TLabel;
    Label7: TLabel;
    lblrecordcount: TLabel;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label2: TLabel;
    Label8: TLabel;
    btnclose: TButton;
    btnquery: TButton;
    DateTimePickerSTART: TDateTimePicker;
    DateTimePickerEND: TDateTimePicker;
    StringGridrepair: TStringGrid;
    Progressfeeder: TProgressBar;
    Btnsave: TButton;
    ClientDatasetrepair: TClientDataSet;
    SaveDialog1: TSaveDialog;
    ClientDataSet1: TClientDataSet;
    cmbboxmodelname: TComboBox;
    cmbboxprocess: TComboBox;
    procedure cleardata;
    procedure getdata;
    procedure WriteLog(sTrLog:string);
    procedure queryREPAIR(strTstart,strtend,STRMODELNAME,STRPROCESS: string);
    procedure btncloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnqueryClick(Sender: TObject);
    procedure BtnsaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormWipRepairresultforQC: TFormWipRepairresultforQC;
  icol,irow:integer;
  STRTSTART,STRTEND,STRMODELNAME,STRPROCESS: STRING;
implementation

uses UnitMain;

{$R *.dfm}

procedure TFormWipRepairresultforQC.WriteLog(sTrLog:string);
var vFile: Textfile;
var sBackupFile,sDir:string;
begin
  sbackupfile:=savedialog1.FileName ;
  AssignFile(vFile, sBackupFile);
  if FileExists(sBackupFile) then
    Append(vFile)
  else
    Rewrite(vFile);
  WriteLn(vFile, sTrlog);
  CloseFile(vFile);

end;

procedure TFormWipRepairresultforQC.cleardata;
begin
     lblrecordcount.Caption :='';
     with stringgridrepair do
       begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=10;
           ColCount  :=9;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=80;
           cells[0,0]:='機種名稱';
           colwidths[1]:=70;
           cells[1,0]:='維修日期';
           colwidths[2]:=70;
           CELLS[2,0]:='測試站別';
           colwidths[3]:=30;
           CELLS[3,0]:='數量';
           colwidths[4]:=110;
           CELLS[4,0]:='不良描述';
           colwidths[5]:=50;
           CELLS[5,0]:='不良位置';
           colwidths[6]:=170;
           CELLS[6,0]:='責任歸屬';
           colwidths[7]:=110;
           CELLS[7,0]:='原因分析';
           colwidths[8]:=70;
           CELLS[8,0]:='維修人員';
      end;
end;

procedure TFormWipRepairresultforQC.getdata;
begin
   strTstart:='';
   strtend:=''  ;
   strmodelname:='';
   STRPROCESS:='';
   strTstart:=FormatDateTime('YYYYMMDD',datetimepickerstart.Date);
   strtend:=FormatDateTime('YYYYMMDD',datetimepickerEND.Date);
   if cmbboxmodelname.Text ='ALL' then
      strmodelname:='%'
    else
      strmodelname:=cmbboxmodelname.Text ;
   if cmbboxPROCESS.Text ='ALL' then
      STRPROCESS:='%'
    else
      STRPROCESS:=cmbboxPROCESS.Text ;
end;

procedure TFormWipRepairresultforQC.btncloseClick(Sender: TObject);
begin
   CLOSE;
end;



procedure TFormWipRepairresultforQC.FormShow(Sender: TObject);
begin
    ClientDataset1.RemoteServer :=formmain.socketconnection1;
    ClientDataset1.ProviderName :=formmain.Clientdataset1.ProviderName ;

    ClientDatasetrepair.RemoteServer :=formmain.socketconnection1;
    ClientDatasetrepair.ProviderName :=formmain.Clientdataset1.ProviderName ;

    datetimepickerstart.Date:=now-1;
    datetimepickerend.Date :=now;

    with clientdataset1 do
       begin
           close;
           commandtext:='select model_name from sajet.sys_model order by model_name';
           open;
           first;
           cmbboxmodelname.Clear ;
           cmbboxmodelname.Items.Add('ALL');
           while not eof do
             begin
                cmbboxmodelname.Items.Add(fieldbyname('model_name').AsString);
                next;
             end;
           cmbboxmodelname.ItemIndex :=0;
       end;

     with clientdataset1 do
       begin
           close;
           commandtext:='select process_name from sajet.sys_process where enabled=''Y''  order by process_name';
           open;
           first;
           cmbboxPROCESS.Clear ;
           cmbboxPROCESS.Items.Add('ALL');
           while not eof do
             begin
                cmbboxPROCESS.Items.Add(fieldbyname('PROCESS_name').AsString);
                next;
             end;
           cmbboxPROCESS.ItemIndex :=0;
       end;


   cleardata;
end;

procedure TFormWipRepairresultforQC.queryREPAIR(strTstart,strtend,STRMODELNAME,STRPROCESS: string);
begin
   with ClientDatasetrepair do
        begin
            close;
            commandtext:=' SELECT A.REPAIR_TIME,A.LOCATION,A.TOTAL,C.MODEL_NAME,E.REASON_CODE,E.REASON_DESC,F.EMP_NAME,G.DUTY_CODE ,G.DUTY_DESC,    '
                        +' H.PROCESS_NAME,J.DEFECT_CODE,J.DEFECT_DESC FROM    '
                        +' (select A.model_id ,A.reason_id,to_char(A.repair_time,''YYYY/MM/DD'') REPAIR_TIME,A.repair_emp_id ,A.duty_id ,B.LOCATION,   '
                        +' C.PROCESS_ID,C.DEFECT_ID,COUNT(A.SERIAL_NUMBER) as total   '
                        +' from sajet.g_sn_repair A,sajet.g_sn_repair_location B,sajet.g_sn_defect C   '
                        +' where to_char(A.repair_time,''YYYYMMDD'') BETWEEN :start_time  AND :end_time  '
                        +'  AND A.REMARK IS NULL  '
                        +'  AND A.RECID=C.RECID AND A.RECID=B.RECID(+)   '
                        +' GROUP BY A.model_id ,A.reason_id,repair_emp_id,duty_id,B.LOCATION,c.PROCESS_ID,c.DEFECT_ID, '
                        +' to_char(A.repair_time,''YYYY/MM/DD'')  )A,  '
                        +' sajet.SYS_PART B ,sajet.SYS_MODEL C,sajet.SYS_REASON E ,sajet.SYS_EMP F,sajet.SYS_DUTY G,sajet.SYS_PROCESS H,sajet.SYS_DEFECT J  '
                        +' WHERE A.MODEL_ID=B.PART_ID AND B.MODEL_ID=C.MODEL_ID AND C.MODEL_NAME like :MODEL_NAME    '
                        +' AND A.REASON_ID=E.REASON_ID AND   '
                        +' A.REPAIR_EMP_ID=F.EMP_ID AND A.DUTY_ID=G.DUTY_ID AND A.PROCESS_ID=H.PROCESS_ID  AND H.PROCESS_NAME like :process_name  '
                        +' AND A.DEFECT_ID=J.DEFECT_ID   '
                        +' ORDER BY REPAIR_TIME ,location ';

            params.ParamByName('start_time').AsString :=strtstart;
            params.ParamByName('end_time').AsString :=strtend;
            params.ParamByName('MODEL_NAME').AsString :=strmodelname;
            params.ParamByName('process_name').AsString :=STRPROCESS;


            OPEN;
            FIRST;
            if fieldbyname('REPAIR_TIME').asstring='' then
               begin
                 cleardata  ;
                 exit;
               end;
            stringgridrepair.RowCount:=10;
            irow:=0;
            icol:=0;
            WHILE NOT EOF DO
              BEGIN
                  IROW:=IROW+1;
                  stringgridrepair.Cells[0,irow]:=fieldbyname('MODEL_NAME').asstring ;
                  stringgridrepair.Cells[1,irow]:=fieldbyname('REPAIR_TIME').AsString   ;
                  stringgridrepair.Cells[2,irow]:=fieldbyname('PROCESS_NAME').AsString   ;
                  stringgridrepair.Cells[3,irow]:=fieldbyname('TOTAL').AsString ;
                  stringgridrepair.Cells[4,irow]:=fieldbyname('DEFECT_code').AsString+'-'+fieldbyname('DEFECT_desc').AsString ;
                  stringgridrepair.Cells[5,irow]:= fieldbyname('LOCATION').AsString ;
                  stringgridrepair.Cells[6,irow]:= fieldbyname('duty_code').AsString+'-'+fieldbyname('duty_desc').AsString ;
                  stringgridrepair.Cells[7,irow]:= fieldbyname('REASON_code').AsString+'-'+fieldbyname('reason_desc').AsString ;
                  stringgridrepair.Cells[8,irow]:= fieldbyname('emp_name').AsString;
                  next;
                  stringgridrepair.RowCount:=IROW+1;
                  lblrecordcount.Caption :=inttostr(irow);
            END; 

        END;
end;

procedure TFormWipRepairresultforQC.btnqueryClick(Sender: TObject);
begin
   getdata;
   queryREPAIR(strTstart,strtend,STRMODELNAME,STRPROCESS);
end;

procedure TFormWipRepairresultforQC.BtnsaveClick(Sender: TObject);
var strfieldsvalue: string;
begin
 if length(stringgridrepair.Cells[0,1]) >0 then
   begin
    if savedialog1.Execute then
      begin
           btnsave.Enabled :=false;
           Progressfeeder.Position :=0;
           Progressfeeder.Max:=stringgridrepair.RowCount ;
           for icol:=0 to strtoint(lblrecordcount.Caption )do
               begin
                  strfieldsvalue:='';
                  for irow:=0 to stringgridrepair.ColCount do
                     begin
                         if  strfieldsvalue='' then
                              strfieldsvalue:=stringgridrepair.Cells[irow,icol]
                          else
                              strfieldsvalue:=strfieldsvalue+';'+ stringgridrepair.Cells[irow,icol] ;
                     end;
                     writelog(strfieldsvalue);
                     Progressfeeder.Position :=icol ;
               end;
          showmessage('Save ok!');
          btnsave.Enabled :=true;
          Progressfeeder.Position :=0;
      end;
   end;

end;

end.
