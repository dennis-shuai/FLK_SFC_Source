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
    QryTemp: TClientDataSet;
    Label1: TLabel;
    Label10: TLabel;
    labCnt: TLabel;
    labcost: TLabel;
    Image2: TImage;
    sbtnQuery: TSpeedButton;
    SBTNUpdateToUsed: TSpeedButton;
    CMBBOXTYPE: TComboBox;
    Label4: TLabel;
    StringGrid1: TStringGrid;
    lblstatus: TLabel;
    Label2: TLabel;
    cmbboxwh: TComboBox;
    cmbboxlocate: TComboBox;
    Label3: TLabel;
    EditSN: TEdit;
    Label5: TLabel;
    cmbboxusedstatus: TComboBox;
    Image1: TImage;
    Image3: TImage;
    sbtnupdatetounused: TSpeedButton;
    Editmonitordept: TEdit;
    procedure FormShow(Sender: TObject);
    procedure cmbboxwhChange(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure CMBBOXTYPEChange(Sender: TObject);
    procedure cmbboxlocateChange(Sender: TObject);
    procedure cmbboxusedstatusChange(Sender: TObject);
    procedure EditSNChange(Sender: TObject);
    procedure SBTNUpdateToUsedClick(Sender: TObject);
    procedure sbtnupdatetounusedClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    icol,irow:integer;
    maintainstandardtime:integer;
    Gtoolingsnid:string;
    procedure cleardata;
    procedure gettoolingtype;
    procedure getwarehouse;
    procedure getlocate;
    procedure querytoolingusedstatus;
    procedure upatetoolingstatustoused;
    procedure upatetoolingstatustoUNused ;
    function gettoolingsnid(tooling_sn:string):String;
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform;

function tfmain.gettoolingsnid(tooling_sn:string):String;
var strtoolingsnid:string;
Begin
   with  qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'tooling_sn',ptinput);
       commandtext:=' select A.TOOLING_SN_ID from sajet.sys_tooling_sn A,SAJET.G_TOOLING_MATERIAL b   '
                   +' where a.tooling_sn_id=b.tooling_sn_id '
                   +' and a.tooling_sn=:tooling_sn and rownum=1 ';
       params.ParamByName('tooling_sn').AsString:= tooling_sn;
       open;
       if isempty then
          result:='XXX'
       else
          result:=fieldbyname('tooling_sn_id').AsString ;
   end;
end;

procedure tfmain.upatetoolingstatustoused ;
var i:integer;
begin
    for i:=1 to stringgrid1.RowCount-1 do
    begin
       if (trim(stringgrid1.Cells[0,i])<>'') and (Gettoolingsnid(stringgrid1.cells[3,i])<>'XXX') and (UPPERCASE(Copy(stringgrid1.Cells[7,i],0,1))='N') then
       begin
         gtoolingsnid:=Gettoolingsnid(stringgrid1.cells[3,i]);
         with qrydata do
          begin
            close;
            params.CreateParam(ftstring,'tooling_sn_id',ptinput);
            params.CreateParam(ftstring,'Update_UserID',ptinput);
            commandtext:='update SAJET.G_TOOLING_MATERIAL set machine_used=''Y'',update_userid=:update_userid , update_time=sysdate '
                      +'where tooling_sn_id=:tooling_sn_id and rownum=1';
            params.ParamByName('tooling_sn_id').AsString:=Gtoolingsnid;
            params.ParamByName('update_userid').AsString :=UpdateUserID ;
            execute;

            close;
            params.CreateParam(ftstring,'tooling_sn_id',ptinput);
            commandtext:='insert into sajet.g_ht_tooling_material '
                        +' select * from sajet.g_tooling_material '
                        +' where tooling_sn_id=:tooling_sn_id and rownum=1 ';
            params.ParamByName('tooling_sn_id').AsString:=Gtoolingsnid;
            execute;
          end;
       end;
     end;
end;

procedure tfmain.upatetoolingstatustoUNused ;
var i:integer;
begin
    for i:=1 to stringgrid1.RowCount-1 do
    begin
       if (trim(stringgrid1.Cells[0,i])<>'') and (Gettoolingsnid(stringgrid1.cells[3,i])<>'XXX') and (UPPERCASE(Copy(stringgrid1.Cells[7,i],0,1))='Y') then
       begin
         gtoolingsnid:=Gettoolingsnid(stringgrid1.cells[3,i]);
         with qrydata do
          begin
            close;
            params.CreateParam(ftstring,'tooling_sn_id',ptinput);
            params.CreateParam(ftstring,'Update_UserID',ptinput);
            commandtext:='update SAJET.G_TOOLING_MATERIAL set machine_used=''N'',update_userid=:update_userid , update_time=sysdate '
                      +'where tooling_sn_id=:tooling_sn_id and rownum=1';
            params.ParamByName('tooling_sn_id').AsString:=Gtoolingsnid;
            params.ParamByName('update_userid').AsString :=UpdateUserID ;
            execute;

            close;
            params.CreateParam(ftstring,'tooling_sn_id',ptinput);
            commandtext:='insert into sajet.g_ht_tooling_material '
                        +' select * from sajet.g_tooling_material '
                        +' where tooling_sn_id=:tooling_sn_id and rownum=1 ';
            params.ParamByName('tooling_sn_id').AsString:=Gtoolingsnid;
            execute;
          end;
       end;
     end;
end;

procedure tfmain.getwarehouse;
begin
   with  qrytemp do
   begin
       close;
       commandtext:=' SELECT warehouse_NAME from SAJET.SYS_warehouse WHERE ENABLED=''Y'' order by warehouse_name asc ';
       open;
       IF ISEMPTY THEN EXIT;
       cmbboxwh.Clear ;
       first;
       WHILE NOT EOF DO
         BEGIN
            cmbboxwh.Items.Add(fieldbyname('warehouse_NAME').AsString );
            next;
         END;
   end;
end;

procedure tfmain.getlocate;
begin
   cmbboxlocate.Clear ;
   with  qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'warehouse_name',ptinput);
       commandtext:='  SELECT a.locate_name FROM SAJET.SYS_LOCATE A,SAJET.SYS_WAREHOUSE B '
                   +' WHERE A.WAREHOUSE_ID=b.warehouse_id '
                   +' and b.warehouse_name=:warehouse_name'
                   +' and a.enabled=''Y'' order by locate_name asc ';
       params.ParamByName('warehouse_name').AsString:=cmbboxwh.Text ;
       open;
       IF ISEMPTY THEN EXIT;
       first;
       WHILE NOT EOF DO
         BEGIN
            cmbboxlocate.Items.Add(fieldbyname('locate_name').AsString );
            next;
         END;
         

   end;
end;

procedure TfMain.CLEARDATA;
var i,j:integer;
BEGIN
   lblstatus.Caption :='';
   if stringgrid1.Cells[0,1]<>'' then
   for i:=0 to stringgrid1.RowCount  do
     for j:=0 to stringgrid1.ColCount   do
       stringgrid1.Cells[j,i]:='';
   irow:=5;
   icol:=8;
   stringgrid1.FixedRows:=1;
   stringgrid1.FixedCols:=0;
   stringgrid1.ColCount :=icol;
   stringgrid1.Rowcount :=irow;
   stringgrid1.Cells[0,0]:='項次';
   stringgrid1.Cells[1,0]:='類別代碼' ;
   stringgrid1.Cells[2,0]:='類別名稱' ;
   stringgrid1.Cells[3,0]:='設備條碼';
   stringgrid1.Cells[4,0]:='機身編號' ;
   stringgrid1.Cells[5,0]:='資料編號';
   stringgrid1.Cells[6,0]:='locate' ;
   stringgrid1.Cells[7,0]:='使用狀態' ;
   stringgrid1.ColWidths[0]:=25;
   stringgrid1.ColWidths[1]:=70;
   stringgrid1.ColWidths[2]:=90;
   stringgrid1.ColWidths[3]:=130;
   stringgrid1.ColWidths[4]:=130;
   stringgrid1.ColWidths[5]:=130;
   stringgrid1.ColWidths[6]:=130;
   stringgrid1.ColWidths[7]:=90;

   if sbtnupdatetoused.Enabled =true then
      sbtnupdatetoused.Enabled :=false;
   if sbtnupdatetounused.Enabled =true then
      sbtnupdatetounused.Enabled :=false ;

END;

procedure TfMain.gettoolingtype;
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

procedure TfMain.querytoolingusedstatus;
var i,j:integer;
VAR strsql:string;
begin
      for i:=1 to irow do
        for j:=0 to icol do
           stringgrid1.Cells[j,i]:='';

          strsql:= ' SELECT A.TOOLING_TYPE,A.TOOLING_NAME,B.TOOLING_SN,C.MACHINE_NO,C.ASSET_NO,  '
                  +' D.WAREHOUSE_NAME||''-''||E.LOCATE_NAME AS LOCATE,C.MACHINE_USED,C.MONITOR_DEPT '
                  +' FROM SAJET.SYS_TOOLING A,SAJET.SYS_TOOLING_SN B,SAJET.G_TOOLING_MATERIAL C, '
                  +' SAJET.SYS_WAREHOUSE D,SAJET.SYS_LOCATE E '
                  +' WHERE A.TOOLING_ID=B.TOOLING_ID  '
                  +' AND B.TOOLING_SN_ID=C.TOOLING_SN_ID  '
                  +' AND B.ENABLED=''Y'' '
                  +' AND C.WAREHOUSE_ID=D.WAREHOUSE_ID   '
                  +' AND C.LOCATE_ID=E.LOCATE_ID  ' ;
          if trim(editsn.Text)<>'' then
            strsql:=strsql+' AND B.TOOLING_SN=:tooling_sn ' ;
         { if trim(cmbboxtype.Text)<>'' then
            strsql:=strsql+' AND A.TOOLING_TYPE=:tooling_type ' ;
          if trim(cmbboxwh.Text)<>'' then
            strsql:=strsql+' AND D.WAREHOUSE_NAME=:warehouse_name ';
          if trim(cmbboxlocate.Text)<>'' then
            strsql:=strsql+' AND E.LOCATE_NAME=:locate_name ';
          if trim(cmbboxusedstatus.Text)<>'' then
            strsql:=strsql+' AND C.MACHINE_USED=:machine_used ';

          strsql:=strsql+' order by b.tooling_sn ';
         }

   with Qrytemp do
       begin
          close;
          if trim(editsn.Text)<>'' then
              params.CreateParam(ftstring,'tooling_sn',ptinput);
         { if trim(cmbboxtype.Text)<>'' then
             params.CreateParam(ftstring,'tooling_type',ptinput);
          if trim(cmbboxwh.Text)<>'' then
             params.CreateParam(ftstring,'warehouse_name',ptinput);
          if trim(cmbboxlocate.Text)<>'' then
             params.CreateParam(ftstring,'locate_name',ptinput);
          if trim(cmbboxusedstatus.Text)<>'' then
             params.CreateParam(ftstring,'machine_used',ptinput);
         }
          commandtext:=strsql;

          if trim(editsn.Text)<>'' then
              params.ParamByName('tooling_sn').AsString :=editsn.Text ;
         { if trim(cmbboxtype.Text)<>'' then
             params.ParamByName('tooling_type').AsString :=cmbboxtype.Text ;
          if trim(cmbboxwh.Text)<>'' then
             params.ParamByName('warehouse_name').AsString :=cmbboxwh.Text ;
          if trim(cmbboxlocate.Text)<>'' then
             params.ParamByName('locate_name').AsString :=cmbboxlocate.Text ;
          if trim(cmbboxusedstatus.Text)<>'' then
             params.ParamByName('machine_used').AsString :=copy(cmbboxusedstatus.Text,0,1);
          }
          open;

      first;
      irow:=1;
      while not eof do
       begin
          stringgrid1.Cells[0,irow]:=inttostr(irow);
          stringgrid1.Cells[1,irow]:= fieldbyname('tooling_type').AsString ;
          stringgrid1.Cells[2,irow]:=fieldbyname('tooling_name').AsString ;
          stringgrid1.Cells[3,irow]:= fieldbyname('tooling_sn').AsString ;
          stringgrid1.Cells[4,irow]:=fieldbyname('machine_no').AsString ;
          stringgrid1.Cells[5,irow]:= fieldbyname('asset_no').AsString ;
          stringgrid1.Cells[6,irow]:=fieldbyname('locate').AsString ;

          if UPPERCASE(fieldbyname('machine_used').AsString)='Y' then
             stringgrid1.Cells[7,irow]:=UPPERCASE(fieldbyname('machine_used').AsString)+'-使用中'
          else
             stringgrid1.Cells[7,irow]:=UPPERCASE(fieldbyname('machine_used').AsString)+'-非使用';
          inc(irow);
          next;
       end;
       if irow<=1 then
          irow:=5;
       stringgrid1.FixedCols :=0;
       stringgrid1.FixedRows :=1;
       stringgrid1.ColCount :=icol;
       stringgrid1.Rowcount :=irow;

       lblstatus.Caption :=inttostr(recordcount) ;

       if recordcount >0 then
       begin
           editmonitordept.Text:=fieldbyname('monitor_dept').AsString ;
           close;
           params.Clear ;
           params.CreateParam(ftstring,'emp_id',ptinput);
           params.CreateParam(ftstring,'dept_id',ptinput);
           commandtext:='select * from sajet.sys_emp_dept where dept_id=:dept_id and emp_id=:emp_id and enabled=''Y'' and rownum=1' ;
           params.ParamByName('emp_id').AsString :=UpdateUserID;
           params.ParamByName('dept_id').AsString :=editmonitordept.Text;
           open;
           if isempty then
           begin
              close;
              params.Clear ;
              params.CreateParam(ftstring,'dept_id',ptinput);
              commandtext:='select * from sajet.sys_dept where dept_id=:dept_id and rownum=1';
              params.ParamByName('dept_id').AsString:=editmonitordept.Text;
              open;
              lblstatus.Caption :='DEPT ERROR:'+fieldbyname('dept_name').AsString ;
              exit;
           end;

           
           sbtnupdatetoused.Enabled :=true;
           sbtnupdatetounused.Enabled :=true;
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
    Params.ParamByName('dll_name').AsString := 'ToolingChangeUsedStatusDLL.dll';
    Open;
  end;


 // gettoolingtype;
 // getwarehouse;

  editsn.Clear ;
  cleardata;
end;


procedure TfMain.cmbboxwhChange(Sender: TObject);
begin
   getlocate;
   cleardata;
end;

procedure TfMain.sbtnQueryClick(Sender: TObject);
begin
   querytoolingusedstatus;
end;

procedure TfMain.CMBBOXTYPEChange(Sender: TObject);
begin
   cleardata;
end;

procedure TfMain.cmbboxlocateChange(Sender: TObject);
begin
   cleardata;
end;

procedure TfMain.cmbboxusedstatusChange(Sender: TObject);
begin
  cleardata;
end;

procedure TfMain.EditSNChange(Sender: TObject);
begin
    cleardata;
end;

procedure TfMain.SBTNUpdateToUsedClick(Sender: TObject);
begin
   if MessageDlg('You Are Changing the Machines To Uesed Status.  Are You',mtConfirmation, [mbYes,mbNo], 0) = mrYes then
     BEGIN
      upatetoolingstatustoused;
      lblstatus.Caption :='Update To Used OK!' ;
     END;
end;

procedure TfMain.sbtnupdatetounusedClick(Sender: TObject);
var i:integer;
begin
  if MessageDlg('You Are Changing The Machines To Unuesed Status.  Are You',mtConfirmation, [mbYes,mbNo], 0) = mrYes then
     BEGIN
       upatetoolingstatustoUNused;
       lblstatus.Caption :='Update To Unused OK!';
     end;
end;

end.




