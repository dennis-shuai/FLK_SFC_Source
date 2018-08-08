unit UnitwipRepairresultquery;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, ComCtrls, Grids, StdCtrls;

type
  TFormRepairResultQuery = class(TForm)
    Label1: TLabel;
    Label7: TLabel;
    lblrecordcount: TLabel;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    btnclose: TButton;
    btnquery: TButton;
    DateTimePickerSTART: TDateTimePicker;
    DateTimePickerEND: TDateTimePicker;
    cmbBoxHSTART: TComboBox;
    cmbBoxHend: TComboBox;
    StringGridrepair: TStringGrid;
    Progressfeeder: TProgressBar;
    Btnsave: TButton;
    ClientDatasetrepair: TClientDataSet;
    SaveDialog1: TSaveDialog;
    Label2: TLabel;
    Label3: TLabel;
    cmbboxmodelname: TComboBox;
    Editrepairuser: TEdit;
    ClientDataSet1: TClientDataSet;
    Label4: TLabel;
    cmbboxline: TComboBox;
    Label8: TLabel;
    cmbboxprocess: TComboBox;
    ClientDataSetlocation: TClientDataSet;
    procedure cleardata;
    procedure getdata;
    procedure WriteLog(sTrLog:string);
    procedure queryREPAIR(strTstart,strtend,STRMODELNAME,STRLINE,STRPROCESS,STRREPAIRUSER: string);
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
  FormRepairResultQuery: TFormRepairResultQuery;
  icol,irow :integer;
  STRTSTART,STRTEND,STRMODELNAME,STRLINE,STRPROCESS,STRREPAIRUSER: STRING;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormRepairResultQuery.WriteLog(sTrLog:string);
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

procedure TFormRepairResultQuery.cleardata;
begin
     lblrecordcount.Caption :='';
     EDITREPAIRUSER.Text :='';
     with stringgridrepair do
       begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=11;
           ColCount  :=11;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=80;
           cells[0,0]:='機種名稱';
           colwidths[1]:=80;
           cells[1,0]:='產品S/N';
           colwidths[2]:=70;
           CELLS[2,0]:='測試線別';
           colwidths[3]:=70;
           CELLS[3,0]:='測試站別';
           colwidths[4]:=100;
           CELLS[4,0]:='不良描述';
           colwidths[5]:=100;
           CELLS[5,0]:='原因描述';
           colwidths[6]:=110;
           CELLS[6,0]:='Location';
           colwidths[7]:=110;
           CELLS[7,0]:='維修日期';
           colwidths[8]:=60;
           CELLS[8,0]:='維修人員';
           colwidths[9]:=80;
           CELLS[9,0]:='責任歸屬';
           colwidths[10]:=50;
           CELLS[10,0]:='Remark';
      end;
end;

procedure TFormRepairResultQuery.getdata;
begin
   strTstart:='';
   strtend:=''  ;
   strmodelname:='';
   STRLINE:='';
   STRPROCESS:='';
   STRREPAIRUSER:='';
   strTstart:=FormatDateTime('YYYYMMDD',datetimepickerstart.Date)+cmbboxhstart.Text;
   strtend:=FormatDateTime('YYYYMMDD',datetimepickerEND.Date)+cmbboxhend.Text;
   if cmbboxmodelname.Text ='ALL' then
      strmodelname:='%'
    else
      strmodelname:=cmbboxmodelname.Text ;
   if cmbboxLINE.Text ='ALL' then
      STRLINE:='%'
    else
      STRLINE:=cmbboxLINE.Text ;
   if cmbboxPROCESS.Text ='ALL' then
      STRPROCESS:='%'
    else
      STRPROCESS:=cmbboxPROCESS.Text ;
   if editrepairuser.Text ='' THEN
       STRREPAIRUSER:='%'
    ELSE
      STRREPAIRUSER:= editrepairuser.Text ;


end;

procedure TFormRepairResultQuery.queryREPAIR(strTstart,strtend,STRMODELNAME,STRLINE,STRPROCESS,STRREPAIRUSER: string);
begin
    with ClientDatasetrepair do
        begin
            close;
            //g_sn_repair 中 fields of duty id,repair_emp_id  沒有build index;
          {  commandtext:='SELECT A.RECID,C.MODEL_NAME, A.SERIAL_NUMBER,G.REASON_code,G.REASON_DESC,h.DUTY_desc, d.emp_name,A.REPAIR_TIME,    '
                      +'  G.DEFECT_CODE,G.DEFECT_DESC,f.process_name,J.REPAIR_REMARK,k.pdline_name  '
                      +'  from sajet.G_SN_REPAIR A ,sajet.SYS_PART B,sajet.SYS_MODEL C,sajet.sys_emp d,sajet.g_sn_defect e,sajet.sys_process f,sajet.sys_defect g,sajet.SYS_REASON G,sajet.sys_duty H ,Sajet.g_sn_repair_remark J ,sajet.sys_pdline k '
                      +'  WHERE TO_CHAR(A.REPAIR_TIME,''YYYYMMDDHH24'') BETWEEN :start_time AND :end_time AND REMARK IS NULL    '
                      +'  AND A.MODEL_ID=B.PART_ID AND B.MODEL_ID=C.MODEL_ID and  c.model_name like :MODEL_NAME   '
                      +'  and e.pdline_id=k.pdline_id and k.pdline_name like :pdline_name '
                      +'  and e.process_id=f.process_id and f.process_name like :process_name  '
                      +'  and a.repair_emp_id=d.emp_id and d.emp_no like :emp_no '
                      +'  and a.recid=e.recid '
                      +'  AND E.DEFECT_ID=G.DEFECT_ID   '
                      +'  AND A.REASON_ID=G.REASON_ID '
                      +'  and a.duty_id=h.duty_id(+) '
                      +'  and a.recid=J.RECID(+) ';
            }
           commandtext:='SELECT A.RECID,C.MODEL_NAME, A.SERIAL_NUMBER,G.REASON_code,G.REASON_DESC,h.DUTY_desc, d.emp_name,A.REPAIR_TIME,    '
                      +'  G.DEFECT_CODE,G.DEFECT_DESC,f.process_name,J.REPAIR_REMARK,k.pdline_name  '
                      +'  from sajet.G_SN_REPAIR A ,sajet.SYS_PART B,sajet.SYS_MODEL C,sajet.sys_emp d,sajet.g_sn_defect e,sajet.sys_process f,sajet.sys_defect g,sajet.SYS_REASON G,sajet.sys_duty H ,Sajet.g_sn_repair_remark J ,sajet.sys_pdline k '
                      +'  WHERE TO_CHAR(A.REPAIR_TIME,''YYYYMMDDHH24'') BETWEEN :start_time AND :end_time AND REMARK IS NULL    '
                      +'  AND A.MODEL_ID=B.PART_ID AND B.MODEL_ID=C.MODEL_ID    '
                      +'  and e.pdline_id=k.pdline_id  '
                      +'  and e.process_id=f.process_id  '
                      +'  and a.repair_emp_id=d.emp_id  '
                      +'  and a.recid=e.recid '
                      +'  AND E.DEFECT_ID=G.DEFECT_ID   '
                      +'  AND A.REASON_ID=G.REASON_ID '
                      +'  and a.duty_id=h.duty_id(+) '
                      +'  and a.recid=J.RECID(+) ';
            if strmodelname<>'%' then
               commandtext:= commandtext+ ' and  c.model_name  =:MODEL_NAME';
            if STRLINE<>'%' then
               commandtext:= commandtext+' and k.pdline_name =:pdline_name';
            if STRPROCESS<>'%' then
               commandtext:= commandtext+' and f.process_name =:process_name';
            if STRREPAIRUSER<>'%' then
               commandtext:= commandtext+' and d.emp_no  =:emp_no ';

            if strmodelname<>'%' then
               params.ParamByName('MODEL_NAME').AsString :=strmodelname;
            if STRLINE<>'%' then
               params.ParamByName('pdline_name').AsString :=STRLINE;
            if STRPROCESS<>'%' then
               params.ParamByName('process_name').AsString :=STRPROCESS;
            if STRREPAIRUSER<>'%' then  
               params.ParamByName('EMP_NO').AsString   :=STRREPAIRUSER;
            params.ParamByName('start_time').AsString :=strtstart;
            params.ParamByName('end_time').AsString :=strtend;

            OPEN;
            FIRST;
            if fieldbyname('RECID').asstring='' then
               begin
                 cleardata  ;
                 exit;
               end;
            for icol:=0 to StringGridrepair.colcount-1 do
               for irow:=1 to StringGridrepair.rowcount-1 do
                  StringGridrepair.Cells[icol,irow]:='';
            stringgridrepair.RowCount:=10;
            irow:=0;
            icol:=0;
            WHILE NOT EOF DO
              BEGIN
                  IROW:=IROW+1;
                  stringgridrepair.Cells[0,irow]:=fieldbyname('MODEL_NAME').asstring ;
                  stringgridrepair.Cells[1,irow]:=fieldbyname('SERIAL_NUMBER').AsString   ;
                  stringgridrepair.Cells[2,irow]:=fieldbyname('PDLINE_NAME').AsString   ;
                  stringgridrepair.Cells[3,irow]:=fieldbyname('process_name').AsString ;
                  stringgridrepair.Cells[4,irow]:=fieldbyname('DEFECT_code').AsString+'-'+fieldbyname('DEFECT_desc').AsString ;
                  stringgridrepair.Cells[5,irow]:= fieldbyname('REASON_code').AsString+'-'+fieldbyname('reason_desc').AsString ;
                 // stringgridrepair.Cells[6,irow]:= fieldbyname('locate').AsString ;
                  with ClientDatasetlocation do
                    begin
                        close;
                        Params.CreateParam(ftString, 'recid', ptInput);
                        commandtext:='SELECT location from sajet.G_SN_REPAIR_LOCATION WHERE RECID=:recid and reason_id is not null ';
                        params.ParamByName('recid').AsString :=ClientDatasetrepair.fieldbyname('recid').asstring ;
                        open;
                        while not eof do
                          begin
                              stringgridrepair.Cells[6,irow]:=stringgridrepair.Cells[6,irow]+ fieldbyname('location').AsString+',';
                              next;
                          end;
                        close;
                    end;
                  stringgridrepair.Cells[7,irow]:= fieldbyname('REPAIR_TIME').AsString ;
                  stringgridrepair.Cells[8,irow]:= fieldbyname('emp_name').AsString;
                  stringgridrepair.Cells[9,irow]:=fieldbyname('DUTY_desc').AsString ;
                  stringgridrepair.Cells[10,irow]:= fieldbyname('REPAIR_REMARK').AsString ;
                  next;
                  stringgridrepair.RowCount:=IROW+1;
                  lblrecordcount.Caption :=inttostr(irow);
            END; 

        END;
end;

procedure TFormRepairResultQuery.btncloseClick(Sender: TObject);
begin
    close;
end;

procedure TFormRepairResultQuery.FormShow(Sender: TObject);
begin
    ClientDataset1.RemoteServer :=formmain.socketconnection1;
    ClientDataset1.ProviderName :=formmain.Clientdataset1.ProviderName ;

    ClientDatasetrepair.RemoteServer :=formmain.socketconnection1;
    ClientDatasetrepair.ProviderName :=formmain.Clientdataset1.ProviderName ;

    ClientDatasetlocation.RemoteServer :=formmain.socketconnection1;
    ClientDatasetlocation.ProviderName :=formmain.Clientdataset1.ProviderName ;

    datetimepickerstart.Date:=now;
    datetimepickerend.Date :=now;
    cmbboxhstart.ItemIndex:=0;
    cmbboxhend.ItemIndex:=23;

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
           commandtext:='select pdline_name from sajet.sys_pdline where enabled=''Y'' order by pdline_name';
           open;
           first;
           cmbboxline.Clear ;
           cmbboxline.Items.Add('ALL');
           while not eof do
             begin
                cmbboxline.Items.Add(fieldbyname('pdline_name').AsString);
                next;
             end;
           cmbboxline.ItemIndex :=0;
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

procedure TFormRepairResultQuery.btnqueryClick(Sender: TObject);
begin
    GETDATA;
    queryREPAIR(strTstart,strtend,strmodelname,Strline,strprocess,STRREPAIRUSER);
end;

procedure TFormRepairResultQuery.BtnsaveClick(Sender: TObject);
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
