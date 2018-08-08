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
    Image2: TImage;
    Image1: TImage;
    SBTNCANCEL: TSpeedButton;
    LBLSTATUS: TLabel;
    labl: TLabel;
    sbtnok: TSpeedButton;
    CheckBoxreturnzero: TCheckBox;
    Label3: TLabel;
    Editreasoncode: TEdit;
    Label4: TLabel;
    Editreasondesc: TEdit;
    Editmonitordept: TEdit;
    procedure sbtnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cleardata;
    procedure EditSNKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SBTNCANCELClick(Sender: TObject);
    procedure sbtnokClick(Sender: TObject);
    procedure EditreasoncodeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    defectid,reasonid,toolingsnid: string;
    function toolingquery(tooling_sn:string):string;
    PROCEDURE  UPDATEtooling;
    function  reasonquery(reason_code:string):string;

    function checktoolingsnfrommaterial(tooling_sn:string):string;
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform;

function tfmain.checktoolingsnfrommaterial(tooling_sn:string):string;
begin
    with qrytemp do
    begin
        close;
        params.CreateParam(ftstring,'tooling_sn',ptinput);
        commandtext:='select a.tooling_sn_id '
                    +' from sajet.g_tooling_material a,sajet.sys_tooling_sn b '
                    +' where a.tooling_sn_id=b.tooling_sn_id '
                    +' and b.tooling_sn=:tooling_sn '
                    +' and a.machine_type in (''O'',''TL'') '
                    +' and a.machine_used=''N'' '
                    +' and rownum=1 ';
        params.ParamByName('tooling_sn').AsString :=tooling_sn;
        open;
        if isempty then
          result:='XXX'
        ELSE
          result:=fieldbyname('tooling_sn_id').AsString
    end;
end;

procedure tfmain.cleardata;
begin
    editmonitordept.Clear ;
    editsn.Clear;
    editsn.SetFocus;
    editreasoncode.Clear ;
    editreasondesc.Clear ;
    checkboxreturnzero.Checked :=true;
   
    lblstatus.Caption :='';

end;

function TfMain.reasonquery(reason_code:string):string;
begiN
   if trim(editsn.Text)='' then
    exit;
   with qrydata do
     begin
         close ;
         commandtext:= 'select reason_id,reason_code,reason_desc from sajet.sys_reason where reason_code=:reason_code and  enabled=''Y'' ';
         params.ParamByName('REASON_CODE').AsString :=reason_code ;
         open;
         if recordcount=0 then
           begin
               result:='NOT FIND THE REASON_CODE!';
               EXIT;
           end
           ELSE
             BEGIN
               reasonid:=fieldbyname('reason_id').AsString ;
               editreasondesc.Text :=fieldbyname('reason_desc').AsString ;
               result:=reason_code;
             END ;
     END;
END ;

function TfMain.toolingquery(tooling_sn:string):string;
begin
   with qrydata do
     begin
         close ;
         commandtext:= ' select B.TOOLING_SN_ID,A.USED_COUNT,A.STATUS from SAJET.g_tooling_sn_status A,SAJET.sys_tooling_sn B  '
                      +' WHERE B.TOOLING_SN=:TOOLING_SN AND A.TOOLING_SN_ID=B.TOOLING_SN_ID AND B.ENABLED=''Y'' ';
         params.ParamByName('tooling_sn').AsString :=tooling_sn;
         open;
         if recordcount=0 then
         begin
            cleardata;
            result:='NOT FIND THE TOOLING SN!';
            EXIT;
         end
         ELSE
         begin
            IF uppERcase(FIELDBYNAME('STATUS').AsString) <>'S' then
            begin
              result:='THE TOOLING SN IS NOT SCRAP status!';
              cleardata;
              exit;
            end;
            result:=tooling_sn;
         end;

             
         //導入了庫存部分的tooling 納入部門管控 add by key 2007.12.27
         editmonitordept.Clear ;
         close;
         params.Clear ;
         params.CreateParam(ftstring,'tooling_sn',ptinput);
         commandtext:='select monitor_dept from sajet.g_tooling_material A,sajet.sys_tooling_sn b where b.tooling_sn=:tooling_sn and '
                    +' a.tooling_sn_id=b.tooling_sn_id and rownum=1';
         params.ParamByName('tooling_sn').AsString :=tooling_sn;
         open;
         if not isempty  then
         begin
            editmonitordept.Text :=fieldbyname('monitor_dept').AsString ;
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
               result :='DEPT ERROR:'+fieldbyname('dept_name').AsString ;
               exit;
             end;
         end;

     END;
END ;

procedure TfMain.UPDATEtooling;
var strtoolingsnid:string;
BEGIN
   IF trim(editsn.Text)='' then
      exit;
   IF trim(editreasoncode.Text)='' then
      exit;
    with qrydata do
     begin
         CLOSE;
         commandtext:=' UPDATE SAJET.G_TOOLING_SN_STATUS '
                     +' SET LAST_MAINTAIN_TIME=SYSDATE, STATUS=:STATUS, UPDATE_USERID = :Update_UserID, UPDATE_TIME = SYSDATE,reset_memo=:reset_memo  '
                     +' WHERE TOOLING_SN_ID in (select tooling_SN_id from  sajet.sys_tooling_sn where tooling_sn= :tooling_sn) ';
         params.ParamByName('STATUS').AsString:='Y';
         params.ParamByName('Update_UserID').AsString := UpdateUserID ;
         params.ParamByName('RESET_MEMO').AsString :=editreasoncode.Text+'-'+editreasondesc.Text ; 
         params.ParamByName('tooling_sn').AsString := trim(editsn.Text );
         execute;

         if checkboxreturnzero.Checked=true then
           begin
               close;
               commandtext:=' UPDATE SAJET.G_TOOLING_SN_STATUS '
                     +' set used_count=''0''  '
                     +' WHERE TOOLING_SN_ID in (select tooling_SN_id from  sajet.sys_tooling_sn where tooling_sn= :tooling_sn) ';
              params.ParamByName('tooling_sn').AsString := trim(editsn.Text );
              execute;
           end;

         close;
         commandtext:=' INSERT INTO SAJET.G_HT_TOOLING_SN_STATUS '
                     +'  SELECT * FROM SAJET.G_TOOLING_SN_STATUS WHERE TOOLING_SN_ID in (select tooling_SN_id from  sajet.sys_tooling_sn where tooling_sn= :tooling_sn) AND ROWNUM = 1 ';
         params.ParamByName('tooling_sn').AsString := trim(editsn.Text );
         execute;

         strtoolingsnID:=checktoolingsnfrommaterial( trim(editsn.Text ));
         if strtoolingsnID<>'XXX' then
         begin
             close;
             params.CreateParam(ftstring,'tooling_sn_id',ptinput);
             params.CreateParam(ftstring,'update_userid',ptinput);
             commandtext:='UPDATE SAJET.G_TOOLING_MATERIAL SET machine_used=''Y'', '
                         +' update_userid=:update_userid ,update_time=sysdate '
                         +' WHERE TOOLING_SN_ID=:tooling_sn_id'
                         +' and rownum=1' ;
             params.ParamByName('Update_UserID').AsString := UpdateUserID ;
             params.ParamByName('tooling_sn_id').AsString :=strtoolingsnid;
             execute;

             close;
             params.CreateParam(ftstring,'tooling_sn_id',ptinput);
             commandtext:=' insert into sajet.g_ht_tooling_material '
                         +' select * from sajet.g_tooling_material '
                         +' WHERE TOOLING_SN_ID=:tooling_sn_id'
                         +' and rownum=1' ;
             params.ParamByName('tooling_sn_id').AsString :=strtoolingsnid;
             execute;

         end;

         lblstatus.Caption :=editsn.Text+' maintain ok! ';

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
    Params.ParamByName('dll_name').AsString := 'RETURNTOYLL.dll';
    Open;
  end;

  CLEARDATA;

end;


procedure TfMain.EditSNKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var strtoolingsn:string;
begin
   if trim(editsn.Text )<>'' then
     if key=13 then
        begin
           strtoolingsn:=TOOLINGQUERY(editsn.Text);
           if strtoolingsn<>editsn.Text then
           begin
             lblstatus.Caption:=strtoolingsn;
             editsn.SetFocus ;
             editsn.SelectAll ;
          end;
        end;
end;

procedure TfMain.SBTNCANCELClick(Sender: TObject);
begin
   cleardata;
end;


procedure TfMain.sbtnokClick(Sender: TObject);
var strtoolingsn,strreasoncode:string;
begin
   strtoolingsn:=TOOLINGQUERY(editsn.Text);
   if strtoolingsn<>editsn.Text then
   begin
       lblstatus.Caption:=strtoolingsn;
       editsn.SetFocus ;
       editsn.SelectAll ;
       exit;
   end;
   strreasoncode:=reasonquery(editreasoncode.Text);
   if strreasoncode<>editreasoncode.Text then
   begin
       lblstatus.Caption :=strreasoncode;
       editreasoncode.SelectAll ;
       editreasoncode.SetFocus ;
       exit;
   end;
   updatetooling;
   editsn.SetFocus ;
   editsn.SelectAll ;
end;

procedure TfMain.EditreasoncodeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var strreasoncode:string;
begin
   if trim(editreasoncode.Text) <>'' then
     if key=13 then
       begin
          strreasoncode:=reasonquery(editreasoncode.Text);
          if strreasoncode<>editreasoncode.Text then
          begin
              lblstatus.Caption :=strreasoncode;
              editreasoncode.SelectAll ;
              editreasoncode.SetFocus ;
           end;
       end;
end;

end.

