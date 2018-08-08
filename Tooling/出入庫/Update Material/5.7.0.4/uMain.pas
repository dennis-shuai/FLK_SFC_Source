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
    editmachineno: TEdit;
    Label5: TLabel;
    Label6: TLabel;
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
    dtpincomingdate: TDateTimePicker;
    Label14: TLabel;
    memomachine: TMemo;
    lbllocate: TLabel;
    lblmonitordept: TLabel;
    lblkeepername: TLabel;
    Lbltoolingname: TLabel;
    lbltoolingtype: TLabel;
    Editmonitordept: TEdit;
    lbl1: TLabel;
    edt1: TEdit;
    lbl2: TLabel;
    mmo1: TMemo;
    lbl3: TLabel;
    edtPriver: TEdit;
    lbl4: TLabel;
    procedure sbtnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cleardata;
    procedure EditSNKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SBTNCANCELClick(Sender: TObject);
    procedure editmachinenoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure editassetnoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditkeeperempnoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditSNChange(Sender: TObject);
    procedure editmachinenoChange(Sender: TObject);
    procedure editassetnoChange(Sender: TObject);
    procedure cmbboxmonitordeptChange(Sender: TObject);
    procedure EditkeeperempnoChange(Sender: TObject);
    procedure dtpincomingdateChange(Sender: TObject);
    procedure cmbboxlocateChange(Sender: TObject);
    procedure memomachineChange(Sender: TObject);
    procedure sbtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    Gtoolingsnid:string;
    PROCEDURE  UPDATEtooling;
   // PROCEDURE  GETDEPT;

   function Gettoolingid(tooling_sn:string):string;   //get tooling_id
   function chkmachineno(machine_no:string):boolean;  // check 機身編號
   function chkassetno(asset_no:string):boolean;    //check 資產編號
   function GETmonitordept(monitor_dept:string):String;  // get 監管單位
   function getkeeper(keeper:string):string;   //get 保管人

  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform;



function tfmain.gettoolingid(tooling_sn:string):String;
Begin
   with  qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'tooling_sn',ptinput);
       commandtext:=' select a.tooling_sn_id,b.tooling_name,b.tooling_type,a.machine_no,a.asset_no,d.dept_name,   '
                   +' e.emp_no as keeper_no,e.emp_name as keeper_name,a.incoming_date,a.provider,a.cust_asset_no, '
                   +' f.warehouse_name||''-''||locate_name AS LOCATE,a.machine_memo,a.monitor_dept,a.backup  '
                   +' from sajet.g_tooling_material a,sajet.sys_tooling b,sajet.sys_tooling_sn c,  '
                   +' sajet.sys_dept d,sajet.sys_emp e,sajet.sys_warehouse f,sajet.sys_locate g   '
                   +' where  c.tooling_sn=:tooling_sn  '
                   +' AND A.tooling_sn_id=c.tooling_sn_id  '
                   +' and b.tooling_id=c.tooling_id  '
                   +' and a.monitor_dept=d.dept_id  '
                   +' and a.keeper_userid=e.emp_id   '
                   +' and a.warehouse_id=f.warehouse_id  '
                   +' and a.locate_id=g.locate_id '
                   +' and rownum=1 ';
       params.ParamByName('tooling_sn').AsString:= tooling_sn;
       open;
       IF ISEMPTY THEN
          begin
            RESULT:='XXX' ;
          end
       else
       begin
           lbltoolingname.Caption :=fieldbyname('tooling_name').AsString ;
           lbltoolingtype.Caption  :=fieldbyname('tooling_type').AsString ;
           editmachineno.Text :=fieldbyname('machine_no').AsString ;
           editassetno.Text :=fieldbyname('asset_no').AsString ;
           edt1.Text :=fieldbyname('cust_asset_no').AsString ;
           lblmonitordept.Caption :=fieldbyname('dept_name').AsString ;
           editkeeperempno.Text :=fieldbyname('keeper_no').AsString ;
           lblkeepername.Caption :=fieldbyname('keeper_name').AsString ;
           dtpincomingdate.DateTime :=fieldbyname('incoming_date').AsDateTime ;
           lbllocate.Caption :=fieldbyname('locate').AsString ;
           memomachine.Text :=fieldbyname('machine_memo').AsString ;
           editmonitordept.Text :=fieldbyname('monitor_dept').AsString ;
           edtPriver.Text :=  fieldbyname('Provider').AsString ;
           mmo1.Text :=  fieldbyname('backup').AsString ;
           result:=fieldbyname('tooling_sn_id').AsString ;

       end;
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
Begin
   with  qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'keeper',ptinput);
       commandtext:='select * from sajet.sys_emp  '
                   +' where emp_no=:keeper and enabled=''Y''  and rownum=1 ';
       params.ParamByName('keeper').AsString:= keeper;
       open;
       IF ISEMPTY THEN
       begin
          RESULT:='XXX';
          EXIT ;
       end
       ELSE
       begin
          RESULT:=fieldbyname('emp_id').AsString ;
          lblkeepername.Caption:=fieldbyname('emp_name').AsString ;
       end;
   end;
end;

procedure tfmain.cleardata;
begin
    editsn.Clear;
    editsn.SetFocus ;
    lbltoolingname.Caption :='';
    lbltoolingtype.Caption :='';
    editmachineno.Clear ;
    editassetno.Clear ;
    editkeeperempno.Clear ;
    lblkeepername.Caption :='' ;
    dtpincomingdate.DateTime:=now();
    lbllocate.Caption:='';
    edt1.Clear;
    mmo1.Clear;
    lblmonitordept.Caption :='';
    memomachine.Text:='';
    lblstatus.Caption :='';

    if sbtnok.Enabled = true then
       sbtnok.Enabled:=false;
end;

procedure TfMain.UPDATEtooling;
var strtoolingsnid,strmonitordeptid,strkeeperempnoid: string;
BEGIN
   if MessageDlg('Your are updating the material date.  are you now?', mtConfirmation, [mbYes, mbNo], 0) = mrNO then
     exit;

   strtoolingsnid:=gtoolingsnid;
   //update machine_no
   if trim(editmachineno.Text)<>''   then
   begin
       with qrytemp do
       begin
           close;
           params.CreateParam(ftstring,'tooling_sn_id',ptinput);
           params.CreateParam(ftstring,'machine_no',ptinput);
           commandtext:='select * from sajet.g_tooling_material '
                       +' where tooling_sn_id=:tooling_sn_id and machine_no=:machine_no and rownum=1 ';
           params.ParamByName('tooling_sn_id').AsString :=strtoolingsnid;
           params.ParamByName('machine_no').AsString :=trim(editmachineno.Text);
           open;

           if  isempty then
           begin
              if not chkmachineno(trim(editmachineno.Text)) then
              begin
                 editmachineno.SetFocus ;
                 editmachineno.SelectAll ;
                 lblstatus.Caption :='Machine_No is DUB';
                 LBLSTATUS.Font.Color :=clRed;
                 sbtnok.Enabled :=false;
                 exit;
              end;
           end;
       end;
   end;

  //update asset_no
   if trim(editassetno.Text)<>''   then
   begin
       with qrytemp do
       begin
           close;
           params.CreateParam(ftstring,'tooling_sn_id',ptinput);
           params.CreateParam(ftstring,'asset_no',ptinput);
           commandtext:='select * from sajet.g_tooling_material '
                       +' where tooling_sn_id=:tooling_sn_id and asset_no=:asset_no and rownum=1 ';
           params.ParamByName('tooling_sn_id').AsString :=strtoolingsnid;
           params.ParamByName('asset_no').AsString :=trim(editassetno.Text);
           open;

           if  isempty then
           begin
              if not chkassetno(trim(editassetno.Text)) then
              begin
                 editassetno.SetFocus ;
                 editassetno.SelectAll ;
                 lblstatus.Caption :='asset_no is DUB';
                 LBLSTATUS.Font.Color :=clRed;
                 sbtnok.Enabled :=false;
                 exit;
              end ;
           end;
       end;
   end;


    if GETmonitordept(trim(lblmonitordept.Caption))='XXX' then
        begin
            lblstatus.Caption :='Not Find The dept_NO '+trim(lblmonitordept.Caption );
            sbtnok.Enabled :=false;
            exit;
        end
    else
        strmonitordeptid:=GETmonitordept(trim(lblmonitordept.Caption));



    if trim(Editkeeperempno.Text )='' then
       begin
          editkeeperempno.SetFocus ;
          lblstatus.Caption :='Please input EMP_NO ';
          LBLSTATUS.Font.Color :=clRed;
          sbtnok.Enabled :=false;
          exit;
       end
    else
    begin
        if getkeeper(trim(Editkeeperempno.Text))='XXX' then
            begin
                Editkeeperempno.SetFocus ;
                Editkeeperempno.SelectAll ;
                lblstatus.Caption :='Not Find The EMP_NO '+trim(Editkeeperempno.Text );
                LBLSTATUS.Font.Color :=clRed;
                sbtnok.Enabled :=false;
                exit;
            end
        else
         strkeeperempnoid:= getkeeper(trim(Editkeeperempno.Text));
    end;

 // 導入了庫存部分的tooling 納入部門管控 add by key 2007.12.27
    with qrytemp do
    begin
        close;
        params.Clear ;
        params.CreateParam(ftstring,'emp_id',ptinput);
        params.CreateParam(ftstring,'dept_id',ptinput);
        commandtext:='select * from sajet.sys_emp_dept where dept_id=:dept_id and emp_id=:emp_id and enabled=''Y'' and rownum=1' ;
        params.ParamByName('emp_id').AsString :=strkeeperempnoid;
        params.ParamByName('dept_id').AsString :=strmonitordeptid;
        open;
        if isempty then
        begin
            close;
            params.Clear ;
            params.CreateParam(ftstring,'dept_id',ptinput);
            commandtext:='select * from sajet.sys_dept where dept_id=:dept_id and rownum=1';
            params.ParamByName('dept_id').AsString:=strmonitordeptid;
            open;
            lblstatus.Caption :='EMP:'+EDITKEEPEREMPNO.Text+' NOT IN THE SYS_EMP_DEPT:'+fieldbyname('dept_name').AsString ;
            LBLSTATUS.Font.Color :=clRed;
            exit;
        end;
    end;

     with qrydata do
     begin
         close;
         params.CreateParam(ftstring,'tooling_sn_id',ptinput);
         params.CreateParam(ftstring,'update_userid',ptinput);
         params.CreateParam(ftstring,'keeper_userid',ptinput);
         params.CreateParam(ftdatetime,'incoming_date',ptinput);
         params.CreateParam(ftstring,'Machine_No',ptinput);
         params.CreateParam(ftstring,'Asset_NO',ptinput);
         params.CreateParam(ftstring,'Cust_Asset_NO',ptinput);
         params.CreateParam(ftstring,'Machine_memo',ptinput);
         params.CreateParam(ftstring,'Provider',ptinput);
         params.CreateParam(ftstring,'Backup',ptinput);
         commandtext:='Update SAJET.G_TOOLING_MATERIAL SET Machine_no =:Machine_no,ASSET_NO=:ASSET_NO,'
                     +' Update_userid=:update_userid ,update_time=sysdate ,Machine_memo =:Machine_memo , '
                     +' keeper_userid=:keeper_userid,incoming_date=:incoming_date,'
                     +' Cust_Asset_NO =:Cust_Asset_NO ,Provider =:Provider,BackUP=:BackUP '
                     +' where tooling_sn_id=:tooling_sn_id and rownum=1';
        params.ParamByName('tooling_sn_id').AsString:= Gtoolingsnid;
        params.ParamByName('Update_UserID').AsString := UpdateUserID ;
        params.ParamByName('incoming_date').AsDateTime := dtpincomingdate.DateTime  ;
        params.ParamByName('keeper_userid').AsString := strkeeperempnoid;
        params.ParamByName('MACHINE_NO').AsString:=editMachineNo.Text ;
        params.ParamByName('Machine_memo').AsString:=memomachine.Text ;
        params.ParamByName('Asset_NO').AsString:=editAssetNO.Text ;
        params.ParamByName('Cust_Asset_NO').AsString:=edt1.Text ;
        params.ParamByName('Provider').AsString := edtPriver.Text ;
        params.ParamByName('Backup').AsString := mmo1.Text ;
        execute;
      
        close;
        params.CreateParam(ftstring,'tooling_sn_id',ptinput);
        commandtext:=' insert into SAJET.G_HT_TOOLING_MATERIAL '
                     +' select * from SAJET.G_TOOLING_MATERIAL '
                     +' where tooling_sn_id=:tooling_sn_id and rownum=1';
        params.ParamByName('tooling_sn_id').AsString:= strtoolingsnid ;
        execute;

        lblstatus.Caption :=editsn.Text +' update OK!';
        LBLSTATUS.Font.Color :=clBlue;
        sbtnok.Enabled :=false;
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
    Params.ParamByName('dll_name').AsString := 'ToolingUpdateMaterialDLL.dll';
    Open;
  end;

  CLEARDATA;



end;


procedure TfMain.EditSNKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if trim(editsn.Text )<>'' then
     if key=13 then
     begin
         Gtoolingsnid:=gettoolingid(trim(editsn.Text));
         if (gtoolingsnid<>'XXX') and (sbtnok.Enabled=false) Then
            sbtnok.Enabled :=true ;

         if gtoolingsnid='XXX' Then
         begin
             editsn.SetFocus ;
             editsn.SelectAll ;
             lblstatus.Caption :=editsn.Text +' NOT FIND!' ;
         end;
     end;

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
        if getkeeper(trim(Editkeeperempno.Text))='XXX' then
           begin
              Editkeeperempno.SetFocus ;
              Editkeeperempno.SelectAll ;
              lblstatus.Caption :='Not Find The EMP_NO '+trim(Editkeeperempno.Text );
           end
        else
           begin
             MEMOMACHINE.SetFocus ;
             memomachine.SelectAll ;
           end;
end;

procedure TfMain.EditSNChange(Sender: TObject);
begin
    lbltoolingname.Caption :='';
    lbltoolingtype.Caption :='';
    editmachineno.Clear ;
    editassetno.Clear ;

    editkeeperempno.Clear ;
    lblkeepername.Caption :='' ;
    dtpincomingdate.DateTime:=now();
    lbllocate.Caption:='';
    lblmonitordept.Caption :='';
    memomachine.Text:='';
    lblstatus.Caption :='';
    editmonitordept.Clear ;
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

procedure TfMain.sbtnOKClick(Sender: TObject);
begin
   updatetooling;
end;

end.

