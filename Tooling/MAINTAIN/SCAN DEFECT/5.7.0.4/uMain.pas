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
    Editdefectdesc: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    editdefectcode: TEdit;
    Image2: TImage;
    sbtnOK: TSpeedButton;
    Image1: TImage;
    SBTNCANCEL: TSpeedButton;
    cmbboxstatus: TComboBox;
    LBLSTATUS: TLabel;
    Editmonitordept: TEdit;
    procedure sbtnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cleardata;
    procedure EditSNKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SBTNCANCELClick(Sender: TObject);
    procedure editdefectcodeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sbtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    defectid,toolingsnid  :string;
    usedcount: integer;
    function toolingquery(tooling_sn:string):string;
    PROCEDURE  UPDATEtooling;
    function  DEFECTQUERY(defect_code:string):string;
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
                    +' and a.machine_used=''Y'' '
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
    editdefectcode.Clear ;
    editdefectdesc.Clear ;
    cmbboxstatus.ItemIndex :=0;
    lblstatus.Caption :='';

end;

function TfMain.toolingquery(tooling_sn:string):string;
begin
   with qrydata do
     begin
         close ;
         commandtext:= ' SELECT B.TOOLING_SN_ID,A.USED_COUNT,A.STATUS FROM SAJET.g_tooling_sn_status A,SAJET.sys_tooling_sn B  '
                      +' WHERE B.TOOLING_SN=:TOOLING_SN AND A.TOOLING_SN_ID=B.TOOLING_SN_ID AND B.ENABLED=''Y'' ';
                  params.ParamByName('tooling_sn').AsString :=tooling_sn;
         open;
         if recordcount=0 then
             begin
                 editsn.Clear ;
                 editsn.SetFocus ;
                 Result:='NOT FIND THE TOOLING SN!';
                 EXIT;
             end
         ELSE
             begin
                 IF uppERcase(FIELDBYNAME('STATUS').AsString) <>'Y' then
                    begin
                     result:='THE TOOLING SN IS NOT  正常　status!';
                     cleardata;
                     editsn.SetFocus ;
                     exit;
                    end;
                 toolingsnid:=fieldbyname('tooling_sn_id').AsString  ;
                 usedcount:=fieldbyname('used_count').AsInteger ;
                 result:=tooling_sn ;
             end;

         //導入了庫存部分的tooling 納入部門管控 add by key 2007.12.27
         editmonitordept.Clear ;
         close;
         params.Clear ;
         params.CreateParam(ftstring,'tooling_sn_id',ptinput);
         commandtext:='select monitor_dept from sajet.g_tooling_material where tooling_sn_id=:tooling_sn_id and rownum=1';
         params.ParamByName('tooling_sn_id').AsString :=toolingsnid;
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

function TfMain.DEFECTquery(defect_code:string):string;
begiN
   with qrydata do
     begin
         close ;
         commandtext:= 'SELECT DEFECT_ID,DEFECT_CODE,DEFECT_DESC FROM SAJET.SYS_DEFECT WHERE DEFECT_CODE=:DEFECT_CODE';
                  params.ParamByName('DEFECT_CODE').AsString :=defect_code;
         open;
         if recordcount=0 then
           begin
               editDEFECTCODE.Clear ;
               editdefectcode.SetFocus ;
               result:='NOT FIND THE DEFECT_CODE!';
               EXIT;
           end
           ELSE
             BEGIN
                 result:=defect_code;
                 defectid:=fieldbyname('defect_id').AsString ;
                 editdefectdesc.Text :=fieldbyname('defect_desc').AsString ;
             END ;

     END;
END ;

procedure TfMain.UPDATEtooling;
var strtoolingsnid:string;
BEGIN
   IF trim(editsn.Text)='' then
      exit;
   IF TRIM(EDITDEFECTCODE.Text )='' THEN
      Exit;
    with qrydata do
     begin
         close;
         commandtext:='insert into sajet.g_tooling_sn_repair '
                     +' fields(tooling_sn_id,used_count,defect_id,defect_userid,defect_time,status ) '
                     +' values(:tooling_sn_id,:used_count,:defect_id,:defect_userid,sysdate,:status ) ';
         params.ParamByName('tooling_sn_id').AsString  :=toolingsnid;
         params.ParamByName('used_count').AsInteger :=usedcount;
         params.ParamByName('defect_id').AsString   :=defectid;
         params.ParamByName('defect_userid').AsString :=updateuserid;
         params.ParamByName('status').AsString :=COPY(CMBBOXSTATUS.Text,0,1);
         execute;

         CLOSE;
         commandtext:=' UPDATE SAJET.G_TOOLING_SN_STATUS   '
                     +' SET STATUS=:STATUS, UPDATE_USERID = :Update_UserID, UPDATE_TIME = SYSDATE  '
                     +' WHERE TOOLING_SN_ID in (select tooling_SN_id from  sajet.sys_tooling_sn where tooling_sn= :tooling_sn) ';
         params.ParamByName('STATUS').AsString:=COPY(CMBBOXSTATUS.Text,0,1);
         params.ParamByName('Update_UserID').AsString := UpdateUserID ;
         params.ParamByName('tooling_sn').AsString := trim(editsn.Text );
         execute;

         close;
         commandtext:=' INSERT INTO SAJET.G_HT_TOOLING_SN_STATUS '
                     +'  SELECT * FROM SAJET.G_TOOLING_SN_STATUS WHERE TOOLING_SN_ID in (select tooling_SN_id from  sajet.sys_tooling_sn where tooling_sn= :tooling_sn) AND ROWNUM = 1 ';
         params.ParamByName('tooling_sn').AsString := trim(editsn.Text );
         execute;

         strtoolingsnid:=checktoolingsnfrommaterial(trim(editsn.Text ));
         if strtoolingsnid<>'XXX' then
         begin
             close;
             params.CreateParam(ftstring,'tooling_sn_id',ptinput);
             params.CreateParam(ftstring,'update_userid',ptinput);
             commandtext:=' update sajet.g_tooling_material set machine_used=''N'' , '
                         +' UPDATE_USERID=:UPDATE_USERID,UPDATE_TIME=SYSDATE '
                         +' WHERE TOOLING_SN_ID=:TOOLING_SN_ID AND ROWNUM=1  ' ;
             PARAMS.ParamByName('Tooling_sn_id').AsString:=strtoolingsnid;
             params.ParamByName('update_userid').AsString :=UpdateUserID;
             execute;

             close;
             params.CreateParam(ftstring,'tooling_sn_id',ptinput);
             commandtext:='insert into sajet.g_ht_tooling_material '
                         +' select * from sajet.g_tooling_material '
                         +' WHERE TOOLING_SN_ID=:TOOLING_SN_ID AND ROWNUM=1  ' ;
             PARAMS.ParamByName('Tooling_sn_id').AsString:=strtoolingsnid;
             execute;
         end;

         lblstatus.Caption :=editsn.Text+' scan defect_code ' +editdefectcode.Text +' ok! ';
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
    Params.ParamByName('dll_name').AsString := 'SCANDEFECTDLL.DLL';
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
          strtoolingsn:= TOOLINGQUERY(editsn.Text);
          if strtoolingsn<> editsn.Text then
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

procedure TfMain.editdefectcodeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var strdefectcode:string;
begin
    if editdefectcode.Text <>'' then
      if key=13 then
        begin
          strdefectcode:=DEFECTquery(editdefectcode.Text)  ;
          if strdefectcode<>editdefectcode.Text then
          begin
             lblstatus.Caption:=strdefectcode;
             editdefectcode.SetFocus ;
             editdefectcode.SelectAll ;
          end
        end
end;

procedure TfMain.sbtnOKClick(Sender: TObject);
var strtoolingsn,strdefectcode:string;
begin
   strtoolingsn:= TOOLINGQUERY(editsn.Text);
   if strtoolingsn<> editsn.Text then
   begin
      lblstatus.Caption:=strtoolingsn;
      editsn.SetFocus ;
      editsn.SelectAll ;
      exit;
   end;
   strdefectcode:=DEFECTquery(editdefectcode.Text)  ;
   if strdefectcode<>editdefectcode.Text then
   begin
      lblstatus.Caption:=strdefectcode;
      editdefectcode.SetFocus ;
      editdefectcode.SelectAll ;
      exit;
   end;
   UPDATEtooling;
   editsn.SetFocus ;
   editsn.SelectAll ;
end;

end.

