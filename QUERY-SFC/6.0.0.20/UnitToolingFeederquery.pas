unit UnitToolingFeederquery;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ComCtrls, DB, DBClient;

type
  TFormToolingFeeder = class(TForm)
    Label1: TLabel;
    ClientDatasettoolingfeeder: TClientDataSet;
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
    Label2: TLabel;
    Label3: TLabel;
    Edituser: TEdit;
    Label4: TLabel;
    cmbboxstatus: TComboBox;
    cmbboxmachine: TComboBox;
    Label7: TLabel;
    lblrecordcount: TLabel;
    ClientDataSetmachine: TClientDataSet;
    ClientDataSetstatus: TClientDataSet;
    SaveDialog1: TSaveDialog;
    Progressfeeder: TProgressBar;
    Btnsave: TButton;
    procedure cleardata;
    procedure WriteLog(sTrLog:string);
    procedure queryfeeder(strtoolingno,strTstart,strtend,strempno,strstatus: string);
    procedure getdata;
    procedure btncloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnqueryClick(Sender: TObject);
    procedure cmbboxmachineDropDown(Sender: TObject);
    procedure cmbboxstatusDropDown(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormToolingFeeder: TFormToolingFeeder;
  icol,irow: integer;
  strtoolingno,strTstart,strtend,strempno,strstatus: string ;

implementation

uses UnitMain;

{$R *.dfm}
procedure TFormToolingFeeder.cleardata;
begin
     edituser.Clear ;
     with stringgridfeeder do
       begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=10;
           ColCount  :=5;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=130;
           cells[0,0]:='機中型號';
           colwidths[1]:=130;
           cells[1,0]:='料架編號';
           colwidths[2]:=100;
           CELLS[2,0]:='保養內容';
            colwidths[3]:=100;
           CELLS[3,0]:='保養人';
            colwidths[4]:=200;
           CELLS[4,0]:='保養時間';
      end;
end;

procedure TFormToolingFeeder.getdata;
begin
   strtoolingno:='';
   strTstart:='';
   strtend:='';
   strempno:='';
   strtstart:='';
   strtend:='';
   strstatus:='';
   if cmbboxmachine.Text ='ALL' then
       strtoolingno:='%'
      else
       strtoolingno:=cmbboxmachine.Text;
   strTstart:=FormatDateTime('YYYYMMDD',datetimepickerstart.Date)+cmbboxhstart.Text;
   strtend:=FormatDateTime('YYYYMMDD',datetimepickerEND.Date)+cmbboxhend.Text;
   if trim(edituser.Text) ='' then
      strempno:='%'
      else
      strempno:=trim(edituser.Text );
   if cmbboxstatus.Text='ALL' Then
      strstatus:='%'
      else
      strstatus:=copy(cmbboxstatus.Text,0,1);
end;

procedure TFormToolingFeeder.queryfeeder(strtoolingno,strTstart,strtend,strempno,strstatus: string);
var i:integer;
begin
    with ClientDatasettoolingfeeder do
        begin
            close;
            commandtext:='  select E.TOOLING_NAME ,B.tooling_sn,A.status,C.EMP_NAME,A.update_time '
                        +'  from SAJET.g_ht_tooling_sn_status A,SAJET.SYS_TOOLING_SN B,SAJET.SYS_EMP C,SAJET.SYS_TOOLING E '
                        +'  WHERE A.TOOLING_SN_ID=B.TOOLING_SN_ID AND B.TOOLING_ID=E.TOOLING_ID AND A.UPDATE_USERID=C.EMP_ID   '
                        +'  AND E.TOOLING_NO LIKE :tooling_no AND TO_CHAR(A.UPDATE_TIME,''YYYYMMDDHH24'') BETWEEN :start_time AND :end_time  '
                        +'  AND C.EMP_NO LIKE :emp_no and a.status like :status  ';
            params.ParamByName('tooling_no').AsString :=strtoolingno;
            params.ParamByName('start_time').AsString :=strtstart;
            params.ParamByName('end_time').AsString :=strtend;
            params.ParamByName('emp_no').AsString := strempno;
            params.ParamByName('status').AsString := strstatus;

            OPEN;

            lblrecordcount.Caption :=inttostr(recordcount);

            if recordcount=0 then
               begin
                 cleardata  ;
                 exit;
               end;

            stringgridfeeder.RowCount :=recordcount+1;
            first;
            for icol:=1 to recordcount do
              begin
                for irow:=1 to fieldcount do
                  begin
                     stringgridfeeder.Cells[irow-1,icol]:=fields[irow-1].AsString ;
                  end;
               next ;
             end;
           for icol:=1 to recordcount do
              begin
                  for i:=1 to cmbboxstatus.Items.Count  do
                      if stringgridfeeder.Cells[2,icol]= copy(cmbboxstatus.Items.Strings[i],0,1) then
                          begin
                            stringgridfeeder.Cells[2,icol]:=copy(cmbboxstatus.Items.Strings[i],3,length(cmbboxstatus.Items.Strings[i]));
                          end;
              end;
     end;
end;

procedure TFormToolingFeeder.btncloseClick(Sender: TObject);
begin
    close;
end;

procedure TFormToolingFeeder.FormShow(Sender: TObject);
Var sStr1,sStrx,sStr2 : String;
begin
   ClientDatasettoolingfeeder.RemoteServer :=formmain.socketconnection1;
   ClientDatasettoolingfeeder.ProviderName :=formmain.Clientdataset1.ProviderName ;
   ClientDatasetmachine.RemoteServer :=formmain.socketconnection1;
   ClientDatasetmachine.ProviderName :=formmain.Clientdataset1.ProviderName ;


    datetimepickerstart.Date:=now;
    datetimepickerend.Date :=now;
    cmbboxhstart.ItemIndex:=0;
    cmbboxhend.ItemIndex:=23;
    cmbboxmachine.Clear ;
    cmbboxmachine.Items.Add('ALL');
    cmbboxmachine.ItemIndex :=0;
    cmbboxstatus.Clear ;
    cmbboxstatus.Items.Add('ALL');
    CMBBOXSTATUS.ItemIndex :=0;

    cleardata;

    cmbboxSTATUS.Clear ;
    cmbboxSTATUS.Items.Add('ALL');
    cmbboxSTATUS.ItemIndex:=0;
    with clientdatasetmachine do
       begin
         close;
         params.Clear;
         CommandText := ' SELECT SQL_VALUE FROM  SAJET.SYS_SQL '+
                   ' WHERE UPPER(SQL_NAME)=''TOOLING SN STATUS'' AND SQL_TYPE=''L'' AND ROWNUM=1 ';
         open;
         if RecordCount>0 then
            begin
                sStr1:=FieldByName('SQL_VALUE').AsString;
                sStr2:=sStr1;
                while Pos(',',sStr2)>0 do
                   begin
                       sStrx:=Copy(sStr2,1,Pos(',',sStr2)-1);
                       sStr2:=Copy(sStr2,Pos(',',sStr2)+1,Length(sStr1));
                       cmbboxSTATUS.Items.add(sStrx);
                       next;
                    end;
               if Trim(sStr2)<>'' then
                   cmbboxSTATUS.Items.add(sStr2);
           END;
    end;



end;

procedure TFormToolingFeeder.btnqueryClick(Sender: TObject);
begin
   GETDATA;
   queryfeeder(strtoolingno,strTstart,strtend,strempno,strstatus) ;
end;

procedure TFormToolingFeeder.cmbboxmachineDropDown(Sender: TObject);
begin
    if cmbboxmachine.Items.Count >=2 then
      exit;
    cmbboxmachine.Clear ;
    cmbboxmachine.Items.Add('ALL');
    cmbboxmachine.ItemIndex:=0;
    with clientdatasetmachine do
        begin
            close;
            commandtext:=' SELECT distinct tooling_no FROM sajet.sys_tooling' ;
            open;

            if recordcount>0 then
               begin
                 first;
                 while not eof do
                    begin
                        cmbboxmachine.Items.Add(fieldbyname('tooling_no').AsString ) ;
                        next;
                    end;
               end;

        end;

end;

procedure TFormToolingFeeder.cmbboxstatusDropDown(Sender: TObject);
Var sStr1,sStrx,sStr2 : String;
begin
   { if cmbboxSTATUS.Items.Count >=2 then
      exit;
    cmbboxSTATUS.Clear ;
    cmbboxSTATUS.Items.Add('ALL');
    cmbboxSTATUS.ItemIndex:=0;
    with clientdatasetmachine do
       begin
         close;
         params.Clear;
         CommandText := ' SELECT SQL_VALUE FROM  SAJET.SYS_SQL '+
                   ' WHERE UPPER(SQL_NAME)=''TOOLING SN STATUS'' AND SQL_TYPE=''L'' AND ROWNUM=1 ';
         open;
         if RecordCount>0 then
            begin
                sStr1:=FieldByName('SQL_VALUE').AsString;
                sStr2:=sStr1;
                while Pos(',',sStr2)>0 do
                   begin
                       sStrx:=Copy(sStr2,1,Pos(',',sStr2)-1);
                       sStr2:=Copy(sStr2,Pos(',',sStr2)+1,Length(sStr1));
                       cmbboxSTATUS.Items.add(sStrx);
                       next;
                    end;
               if Trim(sStr2)<>'' then
                   cmbboxSTATUS.Items.add(sStr2);
           END;
    end; }
end;

procedure TFormToolingFeeder.WriteLog(sTrLog:string);
var vFile: Textfile;
var sBackupFile,sDir:string;
begin
 // sBackupFile := 'C:\'+FormatDateTime('YYYYMMDD',now())+EDITIDTYPE.TEXT+'.log';


 // savedialog1.Execute ;
  sbackupfile:=savedialog1.FileName ;
  AssignFile(vFile, sBackupFile);
  if FileExists(sBackupFile) then
    Append(vFile)
  else
    Rewrite(vFile);
  WriteLn(vFile, sTrlog);
  CloseFile(vFile);

end;

procedure TFormToolingFeeder.btnSaveClick(Sender: TObject);
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
                    // writelog(stringgridfeeder.Cells[1,icol]);
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
