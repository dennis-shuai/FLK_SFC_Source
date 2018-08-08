unit Unittoolingfeederrepairquery;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, ComCtrls, Grids, StdCtrls;

type
  TFormfeederrepairquery = class(TForm)
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
    StringGridfeeder: TStringGrid;
    Progressfeeder: TProgressBar;
    Btnsave: TButton;
    ClientDatasettoolingfeeder: TClientDataSet;
    SaveDialog1: TSaveDialog;
    procedure cleardata;
    procedure getdata;
    procedure WriteLog(sTrLog:string);
    procedure queryfeeder(strTstart,strtend: string);
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
  Formfeederrepairquery: TFormfeederrepairquery;
  icol,irow:integer;
  strTstart,strtend:string;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormfeederrepairquery.WriteLog(sTrLog:string);
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

procedure TFormfeederrepairquery.cleardata;
begin
     lblrecordcount.Caption :='';
     with stringgridfeeder do
       begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=10;
           ColCount  :=10;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=30;
           cells[0,0]:='項目';
           colwidths[1]:=60;
           cells[1,0]:='日期';
           colwidths[2]:=50;
           CELLS[2,0]:='料架編號';
           colwidths[3]:=130;
           CELLS[3,0]:='達到25萬次維修時間';
           colwidths[4]:=130;
           CELLS[4,0]:='維修完成到正常時間';
           colwidths[5]:=90;
           CELLS[5,0]:='維修總共用時(分)';
           colwidths[6]:=90;
           CELLS[6,0]:='維修標准時間(分)';
           colwidths[7]:=70;
           CELLS[7,0]:='維修效率%';
           colwidths[8]:=80;
           CELLS[8,0]:='累計維修次數';
           colwidths[9]:=60;
           CELLS[9,0]:='維修人';
      end;
end;

procedure TFormfeederrepairquery.getdata;
begin
   strTstart:='';
   strtend:=''  ;
   strTstart:=FormatDateTime('YYYYMMDD',datetimepickerstart.Date)+cmbboxhstart.Text;
   strtend:=FormatDateTime('YYYYMMDD',datetimepickerEND.Date)+cmbboxhend.Text;
end;

procedure TFormfeederrepairquery.queryfeeder(strTstart,strtend: string);
var strtoolingsn :string;
VAR STRAT,STRBT: string;
begin
    with ClientDatasettoolingfeeder do
        begin
            close;
            commandtext:='  select a.tooling_sn ,A.USED_COUNT,A.status,a.update_time a_time,b.update_time b_time,  '
                        +'  (b.update_time-a.update_time)*24*60 as aa,b.emp_name from  '
                        +'  (select b.tooling_sn ,A.USED_COUNT,A.status,a.update_time,c.emp_name from  '
                        +'  sajet.g_ht_tooling_sn_status a,sajet.sys_tooling_sn b,sajet.sys_emp c '
                        +'  where a.tooling_sn_id =b.tooling_sn_id and a.update_userid =c.emp_id  '
                        +'   and a.status in (''R'') '
                        +'   AND TO_CHAR(A.UPDATE_TIME,''YYYYMMDDHH24'' )BETWEEN :start_time AND :end_time ) A, '
                        +'  (select b.tooling_sn ,A.USED_COUNT,A.status,a.update_time,c.emp_name from  '
                        +'   sajet.g_ht_tooling_sn_status a,sajet.sys_tooling_sn b,sajet.sys_emp c   '
                        +'   where a.tooling_sn_id =b.tooling_sn_id and a.update_userid =c.emp_id  '
                        +'   and a.status in (''Y'') AND USED_COUNT=''0''  '
                        +'   AND TO_CHAR(A.UPDATE_TIME,''YYYYMMDDHH24'' )BETWEEN :start_time AND :end_time )  B  '
                        +'    where a.tooling_sn=b.tooling_sn and b.update_time >a.update_time  '
                        +'    order by a.tooling_sn,a.update_time  ';


            params.ParamByName('start_time').AsString :=strtstart;
            params.ParamByName('end_time').AsString :=strtend;

            OPEN;

            if recordcount=0 then
               begin
                 cleardata  ;
                 exit;
               end;

            stringgridfeeder.RowCount:=10 ;
            first;
            irow:=0;
            icol:=0;
            strtoolingsn:='';
            WHILE NOT EOF DO
              BEGIN
                 if fieldbyname('status').asstring='R' then
                    begin
                      STRAT:='';
                      strtoolingsn:=fieldbyname('tooling_sn').asstring;
                      irow:=irow+1;
                      stringgridfeeder.RowCount :=irow+1;
                      stringgridfeeder.Cells[0,irow]:=inttostr(irow) ;
                      stringgridfeeder.Cells[1,irow]:=FormatDateTime('YYYY-MM-DD',fieldbyname('A_time').AsDateTime ) ;
                      stringgridfeeder.Cells[2,irow]:=fieldbyname('tooling_sn').asstring;
                      stringgridfeeder.Cells[3,irow]:=fieldbyname('A_time').AsString ;
                      stringgridfeeder.Cells[4,irow]:=fieldbyname('B_time').AsString ;
                      stringgridfeeder.Cells[5,irow]:=inttostr(fieldbyname('AA').AsInteger ) ;
                      IF  stringgridfeeder.Cells[5,irow]='0' THEN
                          stringgridfeeder.Cells[5,irow]:='1' ;
                      stringgridfeeder.Cells[6,irow]:='60' ;
                      stringgridfeeder.Cells[7,irow]:=copy(floattostr(60*100 / strtoint(stringgridfeeder.Cells[5,irow])),0,6);
                      stringgridfeeder.Cells[8,irow]:='1' ;
                      stringgridfeeder.Cells[9,irow]:=fieldbyname('EMP_NAME').AsString
                    end;

                      next;
                      //去除double 記錄 ,如果a_time is duble ,則remove the record
                      while not eof do
                         begin
                             if  fieldbyname('tooling_sn').asstring = strtoolingsn  then
                                begin
                                 if  fieldbyname('A_TIME').AsDateTime =strtodatetime(stringgridfeeder.Cells[3,irow]) Then
                                       next
                                    else
                                    begin
                                       break;
                                    end
                                 end
                              else
                                break ;
                         end;
              END;
              lblrecordcount.Caption :=inttostr(irow) ;
          end;
end;


procedure TFormfeederrepairquery.btncloseClick(Sender: TObject);
begin
   close;
end;

procedure TFormfeederrepairquery.FormShow(Sender: TObject);
begin
    ClientDatasettoolingfeeder.RemoteServer :=formmain.socketconnection1;
    ClientDatasettoolingfeeder.ProviderName :=formmain.Clientdataset1.ProviderName ;

    datetimepickerstart.Date:=now;
    datetimepickerend.Date :=now;
    cmbboxhstart.ItemIndex:=0;
    cmbboxhend.ItemIndex:=23;

    cleardata;
end;

procedure TFormfeederrepairquery.btnqueryClick(Sender: TObject);
begin
    GETDATA;
    queryfeeder(strTstart,strtend);
end;

procedure TFormfeederrepairquery.BtnsaveClick(Sender: TObject);
var strfieldsvalue: string;
begin
 if strtoint(lblrecordcount.Caption)>=1 then
   begin
    if savedialog1.Execute then
      begin
           btnsave.Enabled :=false;
           Progressfeeder.Position :=0;
           Progressfeeder.Max:=stringgridfeeder.RowCount ;
           for icol:=0 to strtoint(lblrecordcount.Caption )do
               begin
                  strfieldsvalue:='';
                  for irow:=0 to stringgridfeeder.ColCount do
                     begin
                         if  strfieldsvalue='' then
                              strfieldsvalue:=stringgridfeeder.Cells[irow,icol] 
                          else
                              strfieldsvalue:=strfieldsvalue+';'+ stringgridfeeder.Cells[irow,icol] ;
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
