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
    Label8: TLabel;
    Label9: TLabel;
    Label11: TLabel;
    editassetno: TEdit;
    Editkeeperempno: TEdit;
    Label12: TLabel;
    Label13: TLabel;
    editkeeperempname: TEdit;
    cmbboxmonitordept: TComboBox;
    dtpincomingdate: TDateTimePicker;
    cmbboxwarehouse: TComboBox;
    cmbboxlocate: TComboBox;
    Label14: TLabel;
    memomachine: TMemo;
    lbl1: TLabel;
    mmoBackup: TMemo;
    lbl2: TLabel;
    edtCustAssetNo: TEdit;
    lbl3: TLabel;
    edtProvider: TEdit;
    lbl4: TLabel;
    procedure sbtnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cleardata;
    procedure EditSNKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sbtnOKClick(Sender: TObject);
    procedure SBTNCANCELClick(Sender: TObject);
    procedure editmachinenoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure editassetnoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditkeeperempnoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cmbboxmonitordeptDropDown(Sender: TObject);
    procedure cmbboxwarehouseDropDown(Sender: TObject);
    procedure cmbboxlocateDropDown(Sender: TObject);
    procedure cmbboxwarehouseChange(Sender: TObject);
    procedure EditSNChange(Sender: TObject);
    procedure editmachinenoChange(Sender: TObject);
    procedure editassetnoChange(Sender: TObject);
    procedure cmbboxmonitordeptChange(Sender: TObject);
    procedure EditkeeperempnoChange(Sender: TObject);
    procedure dtpincomingdateChange(Sender: TObject);
    procedure cmbboxlocateChange(Sender: TObject);
    procedure memomachineChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    PROCEDURE  inserttooling;
    PROCEDURE  GETDEPT;
    Procedure  getwarehouse;
    Procedure  getlocate;

   function Gettoolingid(tooling_sn:string):string;   //get tooling_id
   function chkmachineno(machine_no:string):boolean;  // check 機身編號
   function chkassetno(asset_no:string):boolean;    //check 資產編號
   function GETmonitordept(monitor_dept:string):String;  // get 監管單位
   function getkeeper(keeper:string):string;   //get 保管人
   function getwarehouseid(warehouse_name:string):string;
   function getlocateid(warehouse_name:string;locate_name:string):string;
   function chkCustassetno(asset_no:string):boolean;

  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform;

procedure tfmain.GETDEPT;
begin
   with  qrytemp do
   begin
       close;
       commandtext:=' SELECT DEPT_NAME from SAJET.SYS_DEPT WHERE ENABLED=''Y'' order by dept_name asc ';
       open;
       IF ISEMPTY THEN EXIT;
       cmbboxmonitordept.Clear ;
       first;
       WHILE NOT EOF DO
         BEGIN
            cmbboxmonitordept.Items.Add(fieldbyname('dept_name').AsString );
            next;
         END;

   end;
end;

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

function tfmain.gettoolingid(tooling_sn:string):String;
var strtoolingsnid:string;
Begin
   with  qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'tooling_sn',ptinput);
       commandtext:=' select A.TOOLING_SN_ID,B.TOOLING_NAME,B.TOOLING_TYPE from sajet.sys_tooling_sn A,Sajet.sys_tooling b   '
                   +' where  a.tooling_id=b.tooling_id  '
                   +' and a.enabled=''Y'' '
                   +' AND A.TOOLING_SN=:tooling_sn and rownum=1 ';
       params.ParamByName('tooling_sn').AsString:= tooling_sn;
       open;
       IF ISEMPTY THEN
       begin
          RESULT:='XXX';
          exit;
       end
       ELSE
         begin
            edittoolingname.clear;
            edittoolingname.Text:=fieldbyname('tooling_name').AsString ;
            edittoolingtype.Clear ;
            edittoolingtype.Text:=fieldbyname('tooling_type').AsString;
            result:=fieldbyname('tooling_SN_id').AsString;
         end;

       close;
       params.Clear ;
       params.CreateParam(ftstring,'tooling_sn_ID',ptinput);
       commandtext:=' select * from SAJET.G_TOOLING_MATERIAL where tooling_sn_id=:tooling_sn_id and rownum=1 ';
       params.ParamByName('tooling_sn_id').AsString:= result;
       open;
       if not isempty then
          result:='DUBXXX';
   end;
end;

function tfmain.chkmachineno(machine_no:string):boolean;
Begin
   with  qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'machine_no',ptinput);
       commandtext:='select * from SAJET.G_TOOLING_MATERIAL '
                   +' where machine_no=:machine_no  and rownum=1 ';
       params.ParamByName('machine_no').AsString:= machine_no;
       open;
       IF ISEMPTY THEN
          RESULT:=true
       ELSE
          RESULT:=false;
   end;
end;

function tfmain.chkassetno(asset_no:string):boolean;
Begin
   with  qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'asset_no',ptinput);
       commandtext:='select * from SAJET.G_TOOLING_MATERIAL '
                   +' where asset_no=:asset_no  and rownum=1 ';
       params.ParamByName('asset_no').AsString:= asset_no;
       open;
       IF ISEMPTY THEN
          RESULT:=true
       ELSE
          RESULT:=false;
   end;
end;

function tfmain.chkCustassetno(asset_no:string):boolean;
Begin
   with  qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'asset_no',ptinput);
       commandtext:='select * from SAJET.G_TOOLING_MATERIAL '
                   +' where Cust_asset_no=:asset_no  and rownum=1 ';
       params.ParamByName('asset_no').AsString:= asset_no;
       open;
       IF ISEMPTY THEN
          RESULT:=true
       ELSE
          RESULT:=false;
   end;
end;

function tfmain.getmonitordept(monitor_dept:string):string;
Begin
   with  qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'monitor_dept',ptinput);
       commandtext:='select * from sajet.sys_dept  '
                   +' where dept_name=:monitor_dept and  enabled=''Y'' and rownum=1 ';
       params.ParamByName('monitor_dept').AsString:= monitor_dept;
       open;
       IF ISEMPTY THEN
          RESULT:='XXX'
       ELSE
          RESULT:=fieldbyname('dept_id').AsString ;
   end;
end;

function tfmain.getkeeper(keeper:string):string;
var strdeptid:string;
Begin
   strdeptid:=getmonitordept(cmbboxmonitordept.Text) ;
   with  qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'keeper',ptinput);
       params.Createparam(ftstring,'dept_id',ptinput);
       commandtext:='select * from sajet.sys_emp  '
                   +' where emp_no=:keeper and dept_id=:dept_id and enabled=''Y''  and rownum=1 ';
       params.ParamByName('keeper').AsString:= keeper;
       params.ParamByName('dept_id').AsString :=strdeptid;  
       open;
       IF ISEMPTY THEN
          RESULT:='XXX'
       ELSE
          RESULT:=fieldbyname('emp_id').AsString ;
          editkeeperempname.Text:=fieldbyname('emp_name').AsString ;
   end;
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
    editsn.Clear;
    editsn.SetFocus ;
    edittoolingname.Clear ;
    edittoolingtype.Clear ;
    editmachineno.Clear ;
    editassetno.Clear ;
    cmbboxmonitordept.Text:='';
    editkeeperempno.Clear ;
    editkeeperempname.Clear ;
    dtpincomingdate.DateTime:=now();
    cmbboxwarehouse.Text:='';
    cmbboxlocate.Text:='';
    memomachine.Text:='';
    mmoBackup.Text :='';
    edtProvider.Text :='';
    edtCustAssetNo.Clear;
    lblstatus.Caption :='';
end;

procedure TfMain.inserttooling;
var strtoolingsnid,strmonitordeptid,strkeeperempnoid,strwarehouseid,strlocateid: string;
BEGIN
    if trim(editsn.Text)='' then
      begin
         editsn.SetFocus;
         lblstatus.Caption :='Please Input Tooling_sn ';
         exit;
      end;

       if Gettoolingid(trim(editsn.Text))='XXX' then
           begin
              editsn.SetFocus ;
              editsn.SelectAll ;
              lblstatus.Caption :='Not Find The Tooling_sn '+trim(editsn.Text );
              exit;
           end
       else if Gettoolingid(trim(editsn.Text))='DUBXXX' then
           begin
              editsn.SetFocus ;
              editsn.SelectAll ;
              lblstatus.Caption :='tooling_sn '+trim(editsn.Text )+' Had In Stock!';
              exit;
           end
       else
           strtoolingsnid:=Gettoolingid(trim(editsn.Text));


    if trim(editmachineno.Text)<>'' then
       if not chkmachineno(trim(editmachineno.Text)) then
           begin
              editmachineno.SetFocus ;
              editmachineno.SelectAll ;
              lblstatus.Caption :='Machine_No is DUB';
              exit;
           end;

    if trim(editassetno.Text)<>'' then
        if not chkassetno(trim(editassetno.Text)) then
           begin
              editassetno.SetFocus ;
              editassetno.SelectAll ;
              lblstatus.Caption :='Asset_No is DUB';
              exit;
           end;

     if trim(edtCustassetno.Text)<>'' then
        if not chkassetno(trim(edtCustassetno.Text)) then
           begin
              edtCustassetno.SetFocus ;
              edtCustassetno.SelectAll ;
              lblstatus.Caption :='Cust_Asset_No is DUB';
              exit;
           end;

    if trim(cmbboxmonitordept.Text )='' then
      begin
        lblstatus.Caption :='Please Select dept_NO';
        exit;
      end
    else
      begin
        if GETmonitordept(trim(cmbboxmonitordept.Text))='XXX' then
           begin
              lblstatus.Caption :='Not Find The dept_NO '+trim(cmbboxmonitordept.Text );
              exit;
           end
        else
           strmonitordeptid:=GETmonitordept(trim(cmbboxmonitordept.Text));
      end;

    if trim(Editkeeperempno.Text )='' then
       begin
          editkeeperempno.SetFocus ;
          lblstatus.Caption :='Please input EMP_NO ';
          exit;
       end
    else
      begin
        if getkeeper(trim(Editkeeperempno.Text))='XXX' then
           begin
              Editkeeperempno.SetFocus ;
              Editkeeperempno.SelectAll ;
              lblstatus.Caption :='Not Find The EMP_NO '+trim(Editkeeperempno.Text )+' In The Montior DEPT: '+cmbboxmonitordept.Text;
              exit;
           end
        else
           strkeeperempnoid:= getkeeper(trim(Editkeeperempno.Text));
      end;

    if trim(cmbboxwarehouse.Text )='' then
       begin
          lblstatus.Caption :='Please Input Warehouse!';
          exit;
       end
    else
      begin
        if getwarehouseid(trim(cmbboxwarehouse.Text))='XXX' then
           begin
              lblstatus.Caption :='Not Find The Warehouse '+trim(cmbboxwarehouse.Text );
              exit;
           end
        else
          strwarehouseid:=getwarehouseid(trim(cmbboxwarehouse.Text));
      end;


  if getlocateid(trim(cmbboxwarehouse.Text),trim(cmbboxlocate.Text))='XXX' then
      begin
         lblstatus.Caption :='Not Find The locate '+trim(cmbboxlocate.Text );
         exit;
      end
  else
       strlocateid:=  getlocateid(trim(cmbboxwarehouse.Text),trim(cmbboxlocate.Text));

   with qrydata do
     begin
         close;
         params.CreateParam(ftstring,'tooling_sn_id',ptinput);
         params.CreateParam(ftstring,'machine_no',ptinput);
         params.CreateParam(ftstring,'asset_no',ptinput);
         params.CreateParam(ftstring,'cust_asset_no',ptinput);
         params.CreateParam(ftstring,'warehouse_id',ptinput);
         params.CreateParam(ftstring,'locate_id',ptinput);
         params.CreateParam(ftstring,'keeper_userid',ptinput);
         params.CreateParam(ftstring,'monitor_dept',ptinput);
         params.CreateParam(ftdatetime,'incoming_date',ptinput);
         params.CreateParam(ftdatetime,'revise_time',ptinput);
         params.CreateParam(ftstring,'machine_memo',ptinput);
         params.CreateParam(ftstring,'update_userid',ptinput);
         params.CreateParam(ftstring,'Provider',ptinput);
         params.CreateParam(ftstring,'bakup',ptinput);
         commandtext:=' insert into SAJET.G_TOOLING_MATERIAL(tooling_sn_id,machine_no,asset_no,cust_asset_no,warehouse_id,locate_id,  '
                     +'    keeper_userid,monitor_dept,incoming_date,revise_time,machine_memo,update_userid,provider,borrow_userid,backup)  '
	                   +' values(:tooling_sn_id,:machine_no,:asset_no,:cust_asset_no,:warehouse_id,:locate_id,    '
                     +' :keeper_userid,:monitor_dept,:incoming_date,:revise_time,:machine_memo,:update_userid,:provider,:keeper_userid,:bakup)'  ;
        params.ParamByName('tooling_sn_id').AsString:= strtoolingsnid ;
        params.ParamByName('machine_no').AsString :=trim(editmachineno.Text)  ;
        params.ParamByName('asset_no').AsString := trim(editassetno.text);
        params.ParamByName('cust_asset_no').AsString := trim(edtCustAssetNo.text);
        params.ParamByName('warehouse_id').AsString:=strwarehouseid ;
        params.ParamByName('locate_id').AsString := strlocateid ;
        params.ParamByName('keeper_userid').AsString := strkeeperempnoid;
        params.ParamByName('monitor_dept').AsString:=strmonitordeptid ;
        params.ParamByName('incoming_date').AsDateTime := dtpincomingdate.DateTime  ;
        params.ParamByName('revise_time').AsDateTime:= dtpincomingdate.DateTime  ;
        params.ParamByName('machine_memo').AsString:=trim(memomachine.Text) ;
        params.ParamByName('Update_UserID').AsString := UpdateUserID ;
        params.ParamByName('Provider').AsString := edtProvider.Text ;
        params.ParamByName('bakup').AsString := mmoBackup.Text ;
        execute;

        close;
        params.CreateParam(ftstring,'tooling_sn_id',ptinput);
        commandtext:=' insert into SAJET.G_HT_TOOLING_MATERIAL '
                     +' select * from SAJET.G_TOOLING_MATERIAL '
                     +' where tooling_sn_id=:tooling_sn_id and rownum=1';
        params.ParamByName('tooling_sn_id').AsString:= strtoolingsnid ;
        execute;

        lblstatus.Caption :=editsn.Text +' add OK!';
        editsn.SelectAll ;
        editsn.SetFocus ;
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
    Params.ParamByName('dll_name').AsString := 'ToolingFirstInStockDLL.DLL';
    Open;
  end;

  CLEARDATA;
  GETDEPT;
  getwarehouse;


end;


procedure TfMain.EditSNKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if trim(editsn.Text )<>'' then
     if key=13 then
        if Gettoolingid(trim(editsn.Text))='XXX' then
           begin
              editsn.SetFocus ;
              editsn.SelectAll ;
              lblstatus.Caption :='Not Find The Tooling_sn '+trim(editsn.Text );
              exit;
           end
        else if Gettoolingid(trim(editsn.Text))='DUBXXX' then
           begin
              editsn.SetFocus ;
              editsn.SelectAll ;
              lblstatus.Caption :='tooling_sn '+trim(editsn.Text )+' Had In Stock!';
              exit;
           end
        else
           begin
             editmachineno.SetFocus;
             editmachineno.SelectAll ;
           end;
end;

procedure TfMain.sbtnOKClick(Sender: TObject);
begin
   inserttooling;
end;

procedure TfMain.SBTNCANCELClick(Sender: TObject);
begin
   cleardata;
end;

procedure TfMain.editmachinenoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if  trim(editmachineno.Text)<>'' then
     begin
      if key=13 then
        if not chkmachineno(trim(editmachineno.Text)) then
           begin
              editmachineno.SetFocus ;
              editmachineno.SelectAll ;
              lblstatus.Caption :='Machine_No is DUB'
           end
        else
           begin
             editassetno.SetFocus;
             editassetno.SelectAll ;
           end;
     end
   else
      begin
        if key=13 then
          begin
             editassetno.SetFocus;
             editassetno.SelectAll ;
          end;
      end;
end;

procedure TfMain.editassetnoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if trim(editassetno.Text)<>'' then
     begin
      if key=13 then
        if not chkassetno(trim(editassetno.Text)) then
           begin
              editassetno.SetFocus ;
              editassetno.SelectAll ;
              lblstatus.Caption :='Asset_No is DUB'
           end
        else
           begin
             editkeeperempno.SetFocus;
             editkeeperempno.SelectAll ;
           end;
     end
   else
      begin
        if key=13 then
          begin
           editkeeperempno.SetFocus;
           editkeeperempno.SelectAll ;
          end;
      end;
end;

procedure TfMain.EditkeeperempnoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if trim(Editkeeperempno.Text )<>'' then
     if key=13 then
     begin
        if cmbboxmonitordept.Text='' then
        begin
          lblstatus.Caption :='Please select Monitor Dept first!';
          exit;
        end;
        if getkeeper(trim(Editkeeperempno.Text))='XXX' then
           begin
              Editkeeperempno.SetFocus ;
              Editkeeperempno.SelectAll ;
              lblstatus.Caption :='Not Find The EMP_NO '+trim(Editkeeperempno.Text )+' In The Monitor DEPT: '+cmbboxmonitordept.Text;
              exit;
           end
        else
           begin
             MEMOMACHINE.SetFocus ;
             memomachine.SelectAll ;
           end;
     end;
end;

procedure TfMain.cmbboxmonitordeptDropDown(Sender: TObject);
begin
    if trim(cmbboxmonitordept.Text )<>'' then
        if GETmonitordept(trim(cmbboxmonitordept.Text))='XXX' then
           begin
              lblstatus.Caption :='Not Find The dept_NO '+trim(cmbboxmonitordept.Text );
           end;
end;

procedure TfMain.cmbboxwarehouseDropDown(Sender: TObject);
begin
     if trim(cmbboxwarehouse.Text )<>'' then
        if getwarehouseid(trim(cmbboxwarehouse.Text))='XXX' then
           begin
              lblstatus.Caption :='Not Find The Warehouse '+trim(cmbboxwarehouse.Text );
           end;
end;

procedure TfMain.cmbboxlocateDropDown(Sender: TObject);
begin
   if trim(cmbboxwarehouse.Text )<>'' then
     if getlocateid(trim(cmbboxwarehouse.Text),trim(cmbboxlocate.Text))='XXX' then
           begin
              lblstatus.Caption :='Not Find The locate '+trim(cmbboxlocate.Text );
           end;
end;

procedure TfMain.cmbboxwarehouseChange(Sender: TObject);
begin
    getlocate;
    lblstatus.Caption :='';
end;

procedure TfMain.EditSNChange(Sender: TObject);
begin
  lblstatus.Caption :='';
end;

procedure TfMain.editmachinenoChange(Sender: TObject);
begin
  lblstatus.Caption :='';
end;

procedure TfMain.editassetnoChange(Sender: TObject);
begin
    lblstatus.Caption :='';
end;

procedure TfMain.cmbboxmonitordeptChange(Sender: TObject);
begin
    lblstatus.Caption :='';
end;

procedure TfMain.EditkeeperempnoChange(Sender: TObject);
begin
    lblstatus.Caption :='';
    with QryTemp do
    begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString,'EMP_NO',ptInput);
          CommandText := 'select a.emp_name,b.dept_name from sajet.SYS_EMP a,sajet.sys_dept b'
                    +' where a.EMP_NO=:EMP_NO  and a.dept_id = b.dept_id ';
          Params.ParamByName('EMP_NO').AsString :=Editkeeperempno.Text;
          Open;
          if IsEmpty then begin
              editkeeperempname.Text :='';
              cmbboxmonitordept.ItemIndex :=-1;
              Exit;
          end;
          editkeeperempname.Text :=FieldByName('EMP_NAME').AsString;
          cmbboxmonitordept.ItemIndex := cmbboxmonitordept.Items.IndexOf(FieldByName('Dept_name').AsString);
    end;
end;

procedure TfMain.dtpincomingdateChange(Sender: TObject);
begin
    lblstatus.Caption :='';
end;

procedure TfMain.cmbboxlocateChange(Sender: TObject);
begin
   lblstatus.Caption :='';
end;

procedure TfMain.memomachineChange(Sender: TObject);
begin
   lblstatus.Caption :='';
end;

end.

