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
    Label2: TLabel;
    EditSN: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Edittoolingtype: TEdit;
    editmachineno: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    edittoolingname: TEdit;
    Image2: TImage;
    sbtnOK: TSpeedButton;
    Image1: TImage;
    SBTNCANCEL: TSpeedButton;
    LBLSTATUS: TLabel;
    Label7: TLabel;
    editassetno: TEdit;
    Label12: TLabel;
    cmbboxwarehouse: TComboBox;
    cmbboxlocate: TComboBox;
    Editmonitordept: TEdit;
    Memomachine: TMemo;
    Label8: TLabel;
    procedure sbtnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cleardata;
    procedure cmbboxwarehouseChange(Sender: TObject);
    procedure EditSNKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditSNChange(Sender: TObject);
    procedure sbtnOKClick(Sender: TObject);
    procedure SBTNCANCELClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    Gtoolingsnid,Gwarehouseid,Glocateid:string;
    PROCEDURE  updatetooling;
    Procedure  getwarehouse;
    Procedure  getlocate;
    procedure  Checktoolingsn;
   function getwarehouseid(warehouse_name:string):string;
   function getlocateid(warehouse_name:string;locate_name:string):string;
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform;


procedure tfmain.getwarehouse;
begin
   with  qrytemp do
   begin
       close;
       Params.Clear;
       Params.CreateParam(ftString,'userid',PtInput);
       commandtext:=' SELECT a.warehouse_NAME from SAJET.SYS_warehouse  a,sajet.sys_emp_warehouse b '+
                    ' WHERE a.ENABLED=''Y'' and a.warehouse_id=b.warehouse_id and a.warehouse_desc =''IN'' '+
                    ' and b.emp_id=:userId and b.enabled=''Y'' order by a.warehouse_name asc ';
       Params.ParamByName('userid').AsString := UpdateUserID;
       open;
       IF ISEMPTY THEN EXIT;
       cmbboxwarehouse.Clear ;
       first;
       WHILE NOT EOF DO
       BEGIN
            cmbboxwarehouse.Items.Add(fieldbyname('warehouse_NAME').AsString );
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
       params.ParamByName('warehouse_name').AsString:=cmbboxwarehouse.Text ;
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

procedure tfmain.Checktoolingsn;
Begin
   with  qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'tooling_sn',ptinput);
       commandtext:='SELECT A.TOOLING_no,A.TOOLING_NAME,A.TOOLING_TYPE,B.TOOLING_SN_ID,B.TOOLING_SN,C.MACHINE_NO,C.ASSET_NO,C.MACHINE_TYPE,C.WAREHOUSE_ID,C.LOCATE_ID,  '
                   +' A.ENABLED AS TOOLING_ENABLED, B.ENABLED AS TOOLING_SN_ENABLED,c.monitor_dept,c.machine_memo '
                   +' FROM SAJET.SYS_TOOLING A, SAJET.sys_tooling_sn B, SAJET.G_TOOLING_MATERIAL C  '
                   +' WHERE A.TOOLING_ID=B.TOOLING_ID '
                   +' AND B.TOOLING_SN_ID=C.TOOLING_SN_ID '
                   +' AND B.TOOLING_SN=:tooling_sn and rownum=1 ';
       params.ParamByName('tooling_sn').AsString:=trim(editsn.Text );
       open;
       IF ISEMPTY THEN
         begin
          lblstatus.Caption :='Not Find The Tooling_sn Of '+Trim(editsn.Text )+' In Stock!' ;
          exit;
         end
       else
         begin
            edittoolingname.Text:=  fieldbyname('tooling_name').AsString;
            edittoolingtype.Text := fieldbyname('tooling_type').AsString;
            editmachineno.Text :=  fieldbyname('machine_no').AsString;
            editassetno.Text :=  fieldbyname('asset_no').AsString;
            editmonitordept.Text :=fieldbyname('monitor_dept').AsString ;
            Gtoolingsnid:= fieldbyname('tooling_sn_id').AsString;
            Gwarehouseid:= fieldbyname('warehouse_id').AsString;
            Glocateid:= fieldbyname('locate_id').AsString;
            memomachine.Text:=fieldbyname('machine_memo').AsString ;
         end;
      if (UPPERCASE(fieldbyname('MACHINE_TYPE').AsString) ='O') OR (UPPERCASE(fieldbyname('MACHINE_TYPE').AsString) ='TL') then
        begin
           lblstatus.Caption :='The Tooling_sn Of '+Trim(editsn.Text )+' Is Out Stock!';
           exit;
        end;
      if  UPPERCASE(fieldbyname('TOOLING_ENABLED').AsString) ='N' then
        begin
           lblstatus.Caption :='The Tooling_no Of '+fieldbyname('TOOLING_no').AsString+' Is Disable!';
           exit;
        end;
      if  UPPERCASE(fieldbyname('TOOLING_SN_ENABLED').AsString) ='N' then
        begin
           lblstatus.Caption :='The Tooling_SN Of '+Trim(editsn.Text )+' Is Disable!';
           exit;
        end;

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

      if sbtnok.Enabled=false then
         sbtnok.Enabled :=true;
   end;
      editsn.SetFocus ;
      editsn.SelectAll ;
end;



function tfmain.getwarehouseid(warehouse_name:string):string;
Begin
   with  qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'warehouse_name',ptinput);
       commandtext:='select * from sajet.sys_warehouse  '
                   +' where warehouse_name=:warehouse_name and enabled=''Y''  and rownum=1 ';
       params.ParamByName('warehouse_name').AsString:= warehouse_name;
       open;
       IF ISEMPTY THEN
          RESULT:='XXX'
       ELSE
          RESULT:=fieldbyname('warehouse_id').AsString ;
   end;
end;

function tfmain.getlocateid(warehouse_name:string;locate_name:string):string;
Begin
   with  qrytemp do
   begin
       close;
       params.Clear ;

       if locate_name<>'' then
         begin
           params.CreateParam(ftstring,'warehouse_name',ptinput);
           params.CreateParam(ftstring,'LOCATE_name',ptinput);
          commandtext:='  SELECT A.LOCATE_ID FROM SAJET.SYS_LOCATE A,SAJET.SYS_WAREHOUSE B '
                   +' WHERE A.WAREHOUSE_ID=b.warehouse_id '
                   +' and b.warehouse_name=:warehouse_name '
                   +' AND A.LOCATE_NAME=:locate_name  '
                   +' and a.enabled=''Y'' and rownum=1 ';
          params.ParamByName('warehouse_name').AsString:= warehouse_name;
          params.ParamByName('locate_name').AsString:= locate_name;
         end
       else
         begin
            params.CreateParam(ftstring,'warehouse_name',ptinput); 
            commandtext:='  SELECT A.LOCATE_ID FROM SAJET.SYS_LOCATE A,SAJET.SYS_WAREHOUSE B '
                   +' WHERE A.WAREHOUSE_ID= b.warehouse_id '
                   +' and b.warehouse_name=:warehouse_name '
                   +' AND A.LOCATE_NAME is null '
                   +' and a.enabled=''Y'' and rownum=1 ';
           params.ParamByName('warehouse_name').AsString:= warehouse_name;
         end;
       open;
       IF ISEMPTY THEN
          RESULT:='XXX'
       ELSE
          RESULT:=fieldbyname('locate_id').AsString ;
   end;
end;


procedure tfmain.cleardata;
begin
   // editsn.Clear;
    //editsn.SetFocus ;
    editmonitordept.Clear ;
    edittoolingname.Clear ;
    edittoolingtype.Clear ;
    editmachineno.Clear ;
    editassetno.Clear ;
    cmbboxwarehouse.Text:='';
    cmbboxlocate.Text:='';
    lblstatus.Caption :='';
    sbtnok.Enabled :=false;
    memomachine.Text :='';
end;

procedure TfMain.updatetooling;
var strwarehouseid,strlocateid: string;
BEGIN

    checktoolingsn;    //check tooling_sn 

    if trim(cmbboxwarehouse.Text )='' then
       begin
          lblstatus.Caption :='Please Input Warehouse!';
          LBLSTATUS.Font.Color :=clRed;
          exit;
       end
    else
      begin
        if getwarehouseid(trim(cmbboxwarehouse.Text))='XXX' then
           begin
              lblstatus.Caption :='Not Find The Warehouse '+trim(cmbboxwarehouse.Text );
              LBLSTATUS.Font.Color :=clRed;
              exit;
          end
        else
          strwarehouseid:=getwarehouseid(trim(cmbboxwarehouse.Text));
      end;


  if getlocateid(trim(cmbboxwarehouse.Text),trim(cmbboxlocate.Text))='XXX' then
      begin
         lblstatus.Caption :='Not Find The locate '+trim(cmbboxlocate.Text );
         LBLSTATUS.Font.Color :=clRed;
         exit;
      end
  else
       strlocateid:=  getlocateid(trim(cmbboxwarehouse.Text),trim(cmbboxlocate.Text));

     if (Gwarehouseid=strwarehouseid) and  (glocateid=strlocateid) then
        begin
            lblstatus.Caption :='Warehouse And Locate Is Not Change!' ;
            LBLSTATUS.Font.Color :=clRed;
            exit;
        end;

   with qrydata do
     begin
         close;
         params.CreateParam(ftstring,'tooling_sn_id',ptinput);
         params.CreateParam(ftstring,'warehouse_id',ptinput);
         params.CreateParam(ftstring,'locate_id',ptinput);
         params.CreateParam(ftstring,'update_userid',ptinput);
         commandtext:='Update SAJET.G_TOOLING_MATERIAL SET warehouse_id=:warehouse_id , '
                     +' locate_id=:locate_id,machine_type=''TS'' ,'
                     +' Update_userid=:update_userid ,update_time=sysdate '
                     +' where tooling_sn_id=:tooling_sn_id and rownum=1';
        params.ParamByName('tooling_sn_id').AsString:= Gtoolingsnid;
        params.ParamByName('warehouse_id').AsString:=strwarehouseid ;
        params.ParamByName('locate_id').AsString := strlocateid ;
        params.ParamByName('Update_UserID').AsString := UpdateUserID ;
        execute;

        close;
        params.CreateParam(ftstring,'tooling_sn_id',ptinput);
        commandtext:=' insert into SAJET.G_HT_TOOLING_MATERIAL '
                     +' select * from SAJET.G_TOOLING_MATERIAL '
                     +' where tooling_sn_id=:tooling_sn_id and rownum=1';
        params.ParamByName('tooling_sn_id').AsString:= Gtoolingsnid ;
        execute;

        lblstatus.Caption :=editsn.Text +' Transfer Stock OK!';
        LBLSTATUS.Font.Color :=clBlue;
        editsn.SelectAll ;
        editsn.SetFocus ;
        sbtnok.Enabled :=false;
     end;
end;

procedure TfMain.sbtnQueryClick(Sender: TObject);
var
  T1:tDate;
begin
  t1:=time;
  labcost.Caption:='The search cost you '+IntToStr(MilliSecondsBetween(Time,T1))+' MilliSeconds.';
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
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
    if gsParam <> '' then
      CommandText := CommandText + 'and fun_param = ''' + gsParam + ''' ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'ToolingTransferStockDLL.dll';
    Open;
  end;

  editsn.Clear ;
  editsn.SetFocus ;
  editsn.SelectAll ;
  cleardata;
  getwarehouse;

end;

procedure TfMain.cmbboxwarehouseChange(Sender: TObject);
begin
   getlocate;
end;

procedure TfMain.EditSNKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if trim(editsn.Text )<>'' then
     if key=13 then
       Checktoolingsn ;
end;

procedure TfMain.EditSNChange(Sender: TObject);
begin
   lblstatus.Caption :='';
   cleardata;
end;

procedure TfMain.sbtnOKClick(Sender: TObject);
begin
   updatetooling;
end;

procedure TfMain.SBTNCANCELClick(Sender: TObject);
begin
  editsn.Clear ;
  editsn.SetFocus ;
  editsn.SelectAll ;
  cleardata;
end;

end.

