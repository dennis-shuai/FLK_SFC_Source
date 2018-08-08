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
    Editstatus: TEdit;
    Label6: TLabel;
    editdefect: TEdit;
    Image2: TImage;
    Image1: TImage;
    SBTNCANCEL: TSpeedButton;
    LBLSTATUS: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    Editreasondesc: TEdit;
    Label8: TLabel;
    Memo1: TMemo;
    labl: TLabel;
    Image3: TImage;
    sbtnscrap: TSpeedButton;
    sbtnok: TSpeedButton;
    CheckBoxreturnzero: TCheckBox;
    Editmonitordept: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    editDutyDesc: TEdit;
    cmbDuty: TComboBox;
    cmbReason: TComboBox;
    procedure sbtnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cleardata;
    procedure EditSNKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SBTNCANCELClick(Sender: TObject);
    procedure sbtnscrapClick(Sender: TObject);
    procedure sbtnokClick(Sender: TObject);
    procedure EditReasoncodeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cmbReasonSelect(Sender: TObject);
    procedure cmbDutySelect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    defectid,reasonid,ReasonCode,dutyCode,DutyID,toolingsnid: string;
    function toolingquery(tooling_sn:string):string;
    PROCEDURE  UPDATEtooling;
    function  DEFECTQUERY(defect_ID:string):string;
    function  REASONQUERY(reason_code:string):string;
    procedure  scraptooling;
    function   checktoolingsnrevisetime(tooling_sn:string):string;
    function   checktoolingsnfrommaterial(tooling_sn:string):string;
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform;

procedure tfmain.cleardata;
begin
    editmonitordept.Clear ;
    editsn.Clear;
    editsn.SetFocus;
    editdefect.Clear ;
    editstatus.Clear;
   //editreasoncode.Clear ;
    editreasondesc.Clear ;
    editDutyDesc.Clear;
    memo1.Clear ;
    checkboxreturnzero.Checked :=true;
    cmbDuty.Clear;
    cmbReason.Clear;
    lblstatus.Caption :='';

end;

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

function tfmain.checktoolingsnrevisetime(tooling_sn:string):string;
begin
    with qrytemp do
    begin
        //check g_tooling_sn_repair 中 status是否為'C'--校正評估 ;
        close;
        close;
        params.CreateParam(ftstring,'tooling_sn',ptinput);
        commandtext:='select a.tooling_sn_id '
                    +' from sajet.g_tooling_sn_repair a,sajet.sys_tooling_sn b '
                    +' where a.tooling_sn_id=b.tooling_sn_id '
                    +' and b.tooling_sn=:tooling_sn '
                    +' and a.status=''C'' '
                    +' and a.repair_time is null '
                    +' and rownum=1 ';
        params.ParamByName('tooling_sn').AsString :=tooling_sn;
        open;
        if isempty then
        begin
           result:='XXX' ;
           exit;
        end
        else
        begin
          close;
          params.CreateParam(ftstring,'tooling_sn',ptinput);
          commandtext:='select a.tooling_sn_id '
                    +' from sajet.g_tooling_material a,sajet.sys_tooling_sn b '
                    +' where a.tooling_sn_id=b.tooling_sn_id '
                    +' and b.tooling_sn=:tooling_sn '
                    +' and rownum=1 ';
          params.ParamByName('tooling_sn').AsString :=tooling_sn;
          open;
          if isempty then
             result:='XXX'
          ELSE
             result:=fieldbyname('tooling_sn_id').AsString
       end;
    end;
end;


function TfMain.toolingquery(tooling_sn:string):string;
var i:Integer;
sdeptId:string;
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
               editsn.SetFocus ;
               result:='NOT FIND THE TOOLING SN!';
               EXIT;
         end ;
         
          begin
               IF uppERcase(FIELDBYNAME('STATUS').AsString) ='Y' then
                  begin
                   result:='THE TOOLING SN IS 正常　status!';
                   cleardata;
                   editsn.SetFocus ;
                   exit;
                  end;
               toolingsnid:=fieldbyname('TOOLING_SN_ID').AsString  ;
                //M:保養,R:維修,C:校正評估,S:報廢,Y:正常
               IF uppercase(fieldbyname('status').AsString)='M' then
                 editstatus.Text :='M:保養';
               IF uppercase(fieldbyname('status').AsString)='R' then
                 editstatus.Text :='R:維修';
               IF uppercase(fieldbyname('status').AsString)='C' then
                 editstatus.Text :='C:校正評估';
               IF uppercase(fieldbyname('status').AsString)='S' then
                 editstatus.Text :='S:報廢,';
          end;

           close;
           commandtext:='select tooling_sn_id,defect_id from sajet.g_tooling_sn_repair where tooling_sn_id=:toolingsnid  and repair_time is null' ;
           params.ParamByName('toolingsnid').AsString  :=toolingsnid;
           open;

           if recordcount=0 then
             begin
                 editsn.Clear ;
                 editsn.SetFocus ;
                 result:='NOT FIND THE TOOLING SN IN REPAIR TABLE !';
                 EXIT;
             end;

           IF recordcount>=2 then
              begin
                  editsn.Clear ;
                  editsn.SetFocus ;
                  result:='THE TOOLING SN double in  REPAIR TABLE !';
                  EXIT;
              end;

           defectid:=fieldbyname('defect_id').AsString  ;
           result:=tooling_sn;

          
         //導入了庫存部分的tooling 納入部門管控 add by key 2007.12.27
         editmonitordept.Clear ;
         close;
         params.Clear ;
         params.CreateParam(ftstring,'tooling_sn_id',ptinput);
         commandtext:=' select b.dept_name,b.dept_id from sajet.g_tooling_material a ,sajet.sys_dept b where '+
                      ' a.tooling_sn_id=:tooling_sn_id and a.monitor_dept = b.dept_id and rownum=1';
         params.ParamByName('tooling_sn_id').AsString :=toolingsnid;
         open;
         if not isempty  then
         begin
              editmonitordept.Text :=fieldbyname('dept_name').AsString ;
              sDeptId :=  fieldbyname('dept_id').AsString ;
              close;
              params.Clear ;
              params.CreateParam(ftstring,'emp_id',ptinput);
              params.CreateParam(ftstring,'dept_id',ptinput);
              commandtext:='select * from sajet.sys_emp_dept where dept_id=:dept_id and emp_id=:emp_id and enabled=''Y'' and rownum=1' ;
              params.ParamByName('emp_id').AsString :=UpdateUserID;
              params.ParamByName('dept_id').AsString :=sDeptId;
              open;
              if isempty then
              begin
                   close;
                   params.Clear ;
                   params.CreateParam(ftstring,'dept_id',ptinput);
                   commandtext:='select * from sajet.sys_dept where dept_id=:dept_id and rownum=1';
                   params.ParamByName('dept_id').AsString:=sDeptId;
                   open;
                   result :='DEPT ERROR:'+fieldbyname('dept_name').AsString ;
                   exit;
              end;
         end;
         Close;
         Params.Clear;
         Params.CreateParam(ftString,'defectid', ptInput);
         CommandText := 'Select * from sajet.sys_defect_reason where defect_id =:defectid ';
         Params.ParamByName('defectid').AsString := defectId ;
         Open;
         if IsEmpty then
         begin
              MessageDlg('不良代碼:'+QryTemp.FieldByName('DEFECT_CODE').AsString + #13#10+
                         '不良現象:'+QryTemp.FieldByName('DEFECT_Desc').AsString + #13#10+
                         '沒有建立對應不不良原因聯繫',mtError,[mbYes],0);
              exit;
         end;

          Close;
          Params.Clear;
          Params.CreateParam(ftString,'defectid', ptInput);
          CommandText := ' Select  distinct b.reason_code,b.reason_desc from Sajet.Sys_Defect_Reason a,sajet.sys_reason b '+
                                 ' where a.reason_id=b.reason_id and defect_id =:defectid order by  b.reason_code ';
          Params.ParamByName('defectid').AsString :=  defectId ;
          Open;


          First;
          for i:=0 to RecordCount-1 do
          begin
              cmbReason.Items.Add(fieldbyName('reason_Code').AsString+'^~^'+fieldbyName('reason_desc').AsString);
              //sReasonList.Add(fieldbyName('reason_Code').AsString+'^~^'+fieldbyName('reason_desc').AsString);
              Next;
          end;


     END;
END ;

function TfMain.DEFECTquery(defect_ID:string):string;
begiN
   if trim(editsn.Text) ='' then
     exit;
   with qrydata do
     begin
         close ;
         commandtext:= 'SELECT DEFECT_ID,DEFECT_CODE,DEFECT_DESC FROM SAJET.SYS_DEFECT WHERE DEFECT_ID=:DEFECT_ID AND enabled=''Y'' ';
         params.ParamByName('DEFECT_ID').AsString   :=DEFECT_ID;
         open;
         if recordcount=0 then
         begin
               result:='NOT FIND THE DEFECT_CODE!';
               EXIT;
         end
         ELSE
         BEGIN
                Editdefect.Text :='['+fieldbyname('defect_code').AsString+']'+fieldbyname('defect_desc').AsString ;
                result:=defect_ID;
         END ;
     END;
END ;

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
               reasonid:=fieldbyname('reason_id').AsString  ;
               editreasondesc.Text :=fieldbyname('reason_desc').AsString ;
               result:=reason_code;
             END ;
     END;
END ;

procedure TfMain.UPDATEtooling;
var strtoolingsnid,strtoolingsnid01:string;
BEGIN
   IF trim(editsn.Text)='' then
      exit;
   IF cmbReason.ItemIndex <0 THEN
      exit;
   IF cmbDuty.ItemIndex <0 THEN
      exit;
    with qrydata do
    begin
         strtoolingsnid:=checktoolingsnrevisetime(trim(editsn.Text ));
         if strtoolingsnid<>'XXX' Then
         begin
            close;
            params.CreateParam(ftstring,'tooling_sn_id',ptinput);
            params.CreateParam(ftstring,'update_userid',ptinput);
            commandtext:=' update sajet.g_tooling_material set revise_time=sysdate ,'
                        +' update_userid=:update_userid,update_time=sysdate '
                        +' where tooling_sn_id=:tooling_sn_id and rownum=1 ';
            params.ParamByName('tooling_sn_id').AsString :=strtoolingsnid;
            params.ParamByName('update_userid').AsString := UpdateUserID ;
            execute;

         end;

         strtoolingsnid01:=checktoolingsnfrommaterial(trim(editsn.Text ));
         if strtoolingsnid01<>'XXX' then
         begin
            close;
            params.CreateParam(ftstring,'tooling_sn_id',ptinput);
            params.CreateParam(ftstring,'update_userid',ptinput);
            commandtext:=' update sajet.g_tooling_material set machine_used=''Y'' ,'
                        +' update_userid=:update_userid,update_time=sysdate '
                        +' where tooling_sn_id=:tooling_sn_id and rownum=1 ';
            params.ParamByName('tooling_sn_id').AsString :=strtoolingsnid01;
            params.ParamByName('update_userid').AsString := UpdateUserID ;
            execute;
         end;

         if strtoolingsnid<>'XXX' then
         begin
            close;
            params.CreateParam(ftstring,'tooling_sn_id',ptinput);
            commandtext:=' insert into sajet.g_ht_tooling_material '
                        +' select * from sajet.g_tooling_material '
                        +' where tooling_sn_id=:tooling_sn_id and rownum=1 ';
            params.ParamByName('tooling_sn_id').AsString :=strtoolingsnid;
            execute;
         end
         else
         begin
             if strtoolingsnid01<>'XXX' Then
             begin
                close;
                params.CreateParam(ftstring,'tooling_sn_id',ptinput);
                commandtext:=' insert into sajet.g_ht_tooling_material '
                            +' select * from sajet.g_tooling_material '
                            +' where tooling_sn_id=:tooling_sn_id and rownum=1 ';
                params.ParamByName('tooling_sn_id').AsString :=strtoolingsnid01;
                execute;
              end;
         end;

         close;
         params.Clear;
         params.CreateParam(ftString,'reasonid',ptInput);
         params.CreateParam(ftString,'repairuserid',ptInput);
         params.CreateParam(ftString,'repairmemo',ptInput);
         params.CreateParam(ftString,'toolingsnid',ptInput);
         params.CreateParam(ftString,'DutyId',ptInput);
         commandtext:=' update sajet.g_tooling_sn_repair '
                     +' set reason_id=:reasonid,repair_userid=:repairuserid,repair_time=sysdate, duty_id=:dutyId,repair_memo=:repairmemo '
                     +' where tooling_sn_id=:toolingsnid  and repair_time is null and rownum=1  ';
         params.ParamByName('reasonid').AsString :=reasonid;
         params.ParamByName('repairuserid').AsString := UpdateUserID ;
         params.ParamByName('repairmemo').AsString :=memo1.Text ;
         params.ParamByName('toolingsnid').AsString :=toolingsnid;
         params.ParamByName('DutyId').AsString :=DutyID;
         execute;

         Close;
         commandtext:=' UPDATE SAJET.G_TOOLING_SN_STATUS '
                     +' SET LAST_MAINTAIN_TIME=SYSDATE, STATUS=:STATUS, UPDATE_USERID = :Update_UserID, UPDATE_TIME = SYSDATE  '
                     +' WHERE TOOLING_SN_ID in (select tooling_SN_id from  sajet.sys_tooling_sn where tooling_sn= :tooling_sn) ';
         params.ParamByName('STATUS').AsString:='Y';
         params.ParamByName('Update_UserID').AsString := UpdateUserID ;
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
                     +'  SELECT * FROM SAJET.G_TOOLING_SN_STATUS WHERE TOOLING_SN_ID in'
                     +' (select tooling_SN_id from  sajet.sys_tooling_sn where tooling_sn= :tooling_sn) AND ROWNUM = 1 ';
         params.ParamByName('tooling_sn').AsString := trim(editsn.Text );
         execute;

         lblstatus.Caption :=editsn.Text+' maintain ok! ';

    end;

end;

procedure TfMain.scraptooling;
BEGIN
    IF trim(editsn.Text)='' then
       exit;
    IF cmbReason.ItemIndex <0 then
       Exit;
    IF cmbDuty.ItemIndex <0 then
       exit;

     with qrydata do
     begin
         close;
         commandtext:=' update sajet.g_tooling_sn_repair '
                     +' set status=:status,reason_id=:reasonid,repair_userid=:repairuserid,repair_time=sysdate,duty_id=:duty_id,repair_memo=:repairmemo '
                     +' where tooling_sn_id=:toolingsnid  and repair_time is null and rownum=1   ';
         //M:保養,R:維修,C:校正評估,S:報廢,Y:正常
         params.ParamByName('status').AsString :='S';
         params.ParamByName('dutyId').AsString :=DutyID;
         params.ParamByName('reasonid').AsString :=reasonid;
         params.ParamByName('repairuserid').AsString := UpdateUserID ;
         params.ParamByName('repairmemo').AsString :=memo1.Text ;
         params.ParamByName('toolingsnid').AsString :=toolingsnid;
         execute;

         CLOSE;
         commandtext:=' UPDATE SAJET.G_TOOLING_SN_STATUS '
                     +' SET LAST_MAINTAIN_TIME=SYSDATE, STATUS=:STATUS, UPDATE_USERID = :Update_UserID, UPDATE_TIME = SYSDATE  '
                     +' WHERE TOOLING_SN_ID in (select tooling_SN_id from  sajet.sys_tooling_sn where tooling_sn= :tooling_sn) ';
         params.ParamByName('STATUS').AsString:='S';
         params.ParamByName('Update_UserID').AsString := UpdateUserID ;
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

         lblstatus.Caption :=editsn.Text+' SCRAP ok! ';

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
    Params.ParamByName('dll_name').AsString := 'MAINTAINDLL.dll';
    Open;
  end;

  CLEARDATA;

end;


procedure TfMain.EditSNKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var strtoolingsn,strdefectid,strreasoncode:string;
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
               exit;
         end;
         strdefectid:=DEFECTQUERY(defectid);
         if strdefectid<>defectid then
         begin
               lblstatus.Caption:=strdefectid;
               editsn.SetFocus ;
               editsn.SelectAll ;
               exit;
         end;
     end;
end;

procedure TfMain.SBTNCANCELClick(Sender: TObject);
begin
   cleardata;
end;


procedure TfMain.sbtnscrapClick(Sender: TObject);
var strtoolingsn,strdefectid,strreasoncode:string;
begin
    strtoolingsn:=TOOLINGQUERY(editsn.Text);
    if strtoolingsn<>editsn.Text then
    begin
        lblstatus.Caption:=strtoolingsn;
        editsn.SetFocus ;
        editsn.SelectAll ;
        exit;
    end;
   { strdefectid:=DEFECTQUERY(defectid);
    if strdefectid<>defectid then
    begin
         lblstatus.Caption:=strdefectid;
         editsn.SetFocus ;
         editsn.SelectAll ;
         exit;
    end;
   strreasoncode:=reasonquery(cmbReason.Text);
   if strreasoncode<>editreasoncode.Text then
   begin
       lblstatus.Caption:=strreasoncode;
       editreasoncode.SelectAll ;
       editreasoncode.SetFocus ;
       exit;
   end ; }
   scraptooling;
   editsn.SetFocus ;
   editsn.SelectAll ;
end;

procedure TfMain.sbtnokClick(Sender: TObject);
var strtoolingsn,strdefectid,strreasoncode:string;
begin
     {strtoolingsn:=TOOLINGQUERY(editsn.Text);
     if strtoolingsn<>editsn.Text then
      begin
          lblstatus.Caption:=strtoolingsn;
          editsn.SetFocus ;
          editsn.SelectAll ;
          exit;
      end;

      strdefectid:=DEFECTQUERY(defectid);
      if strdefectid<>defectid then
       begin
           lblstatus.Caption:=strdefectid;
           editsn.SetFocus ;
           editsn.SelectAll ;
           exit;
       end;
       strreasoncode:=reasonquery(editreasoncode.Text);
      if strreasoncode<>editreasoncode.Text then
      begin
       lblstatus.Caption:=strreasoncode;
       editreasoncode.SelectAll ;
       editreasoncode.SetFocus ;
       exit;
       end ;
      }
      updatetooling;
      editsn.SetFocus ;
      editsn.SelectAll ;
      cleardata;
end;



procedure TfMain.EditReasoncodeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var strreasoncode:string ;
begin
    if cmbReason.ItemIndex<0 then
    if key=13 then
    begin
        strreasoncode:=reasonquery(cmbReason.Text);
       { if strreasoncode<>editreasoncode.Text then
        begin
             lblstatus.Caption:=strreasoncode;
             editreasoncode.SelectAll ;
             editreasoncode.SetFocus ;
             exit;
        end ;  }
    end;
end;

procedure TfMain.cmbReasonSelect(Sender: TObject);
var i,ipos:Integer;
begin
   ipos :=  pos('^~^',cmbReason.text);
   if ipos<=0 then Exit;

   ReasonCode :=  Copy(cmbReason.text,1,ipos-1);
   Editreasondesc.Text := Copy(cmbReason.text,ipos+3,Length(cmbReason.text)-ipos-2);
   QryTemp.Close;
   QryTemp.Params.Clear;
   QryTemp.Params.CreateParam(ftstring,'Reason',ptInput) ;
   QryTemp.Params.CreateParam(ftstring,'DefectID',ptInput) ;
   QryTemp.CommandText :=' Select a.reason_id from Sajet.SYS_DEFECT_REASON a,sajet.sys_reason b '+
                         ' WHERE b.REASON_CODE =:REASON AND a.DEFECT_ID =:DefectID and '+
                         ' a.reason_id=b.reason_id ';
   QryTemp.Params.ParamByName('REASON').AsString := ReasonCode;
   QryTemp.Params.ParamByName('DefectID').AsString := DefectId;
   QryTEmp.Open;

   ReasonID :=  QryTemp.fieldByname('reason_id').AsString;

   cmbDuty.Items.Clear;
   QryTemp.Close;
   QryTemp.Params.Clear;
   QryTemp.Params.CreateParam(ftstring,'reason',ptInput) ;
   QryTemp.Params.CreateParam(ftstring,'defectID',ptInput) ;
   QryTemp.CommandText :=' select distinct c.duty_code,C.duty_desc from Sajet.SYS_DEFECT_REASON a,sajet.sys_reason b,sajet.sys_duty c '+
                         ' where b.reason_code =:reason AND a.defect_id =:defectID and '+
                         ' a.reason_id=b.reason_id and a.duty_id=c.duty_id and a.enabled=''Y'' ';
   QryTemp.Params.ParamByName('reason').AsString := ReasonCode;
   QryTemp.Params.ParamByName('defectID').AsString := DefectId;
   QryTemp.Open;


   if  QryTemp.IsEmpty then  exit;
   QryTemp.First;
   for i:=0 to  QryTemp.RecordCount-1 do begin
      cmbDuty.Items.Add(QryTemp.fieldByName('Duty_Code').AsString+'^~^'+QryTemp.fieldByName('Duty_Desc').AsString);
      QryTemp.Next;
   end;
   editDutyDesc.Text :='';

end;

procedure TfMain.cmbDutySelect(Sender: TObject);
var i,ipos:Integer;
begin
   ipos :=  pos('^~^',cmbReason.text);
   if ipos<=0 then Exit;

   DutyCode :=  Copy(cmbDuty.text,1,ipos-1);
   EditDutydesc.Text := Copy(cmbDuty.text,ipos+3,Length(cmbDuty.text)-ipos-2);
   QryTemp.Close;
   QryTemp.Params.Clear;
   QryTemp.Params.CreateParam(ftstring,'Duty',ptInput) ;
   QryTemp.CommandText :=' Select Duty_id from Sajet.sys_duty '+
                         ' WHERE Duty_Code =:Duty and '+
                         ' enabled=''Y'' ';
   QryTemp.Params.ParamByName('Duty').AsString := DutyCode;
   QryTEmp.Open;

   DutyID :=  QryTemp.fieldByname('Duty_id').AsString;

end;

end.

