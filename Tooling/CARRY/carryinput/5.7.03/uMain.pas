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
    EditCarrySN: TEdit;
    Label5: TLabel;
    lblstatus: TLabel;
    Editmonitordept: TEdit;
    Edittoolingsn: TEdit;
    procedure sbtnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cleardata;
    procedure EditCarrySNKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    procedure showcarry;
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform;

procedure tfmain.cleardata;
begin
    editcarrysn.Clear;
    editcarrysn.SetFocus ;
    lblstatus.Caption :='';
end;

procedure TfMain.showcarry;
var INTlimit_used_count: integer ;
begin
   with qrydata do
     begin
         close ;
         commandtext:= 'select nvl(limit_used_count,0) as limit_used_count from  sajet.sys_tooling WHERE  tooling_no=:tooling_no and  TOOLING_TYPE like :tool_type ';
                  params.ParamByName('tooling_NO').AsString :=trim(editcarrysn.Text );
                  params.ParamByName('tool_type').AsString :='%CARRY' ;
         open;
         if recordcount=0 then
           begin
               lblstatus.Caption :='NOT FIND THE CARRY LOT_SN!';
              // cleardata;
               editcarrysn.SelectAll ;
               editcarrysn.SetFocus ;
               EXIT;
           end ;
         INTlimit_used_count:= fieldbyname('limit_used_count').AsInteger ;

         //導入了庫存部分的tooling 納入部門管控 add by key 2007.12.27
         close;
         params.Clear ;
         params.CreateParam(ftstring,'tooling_no',ptinput);
         commandtext:='select B.TOOLING_SN, B.TOOLING_SN_ID from sajet.sys_tooling a,sajet.sys_tooling_sn B '
                     +' where a.tooling_no=:tooling_no and a.tooling_id=b.tooling_id and b.enabled=''Y'' ';
         params.ParamByName('tooling_NO').AsString:=trim(editcarrysn.Text);
         open;
         if not isempty then
         begin
             while not eof do
             begin
                 with qrytemp do
                 begin
                      editmonitordept.Clear ;
                      edittoolingsn.Clear ;
                      edittoolingsn.Text:=qrydata.fieldbyname('tooling_sn').AsString;
                      close;
                      params.Clear ;
                      params.CreateParam(ftstring,'tooling_sn_id',ptinput);
                      commandtext:='select monitor_dept from sajet.g_tooling_material where tooling_sn_id=:tooling_sn_id and rownum=1';
                      params.ParamByName('tooling_sn_id').AsString :=qrydata.fieldbyname('tooling_sn_id').AsString;
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
                                lblstatus.Caption :='DEPT ERROR:'+fieldbyname('dept_name').AsString +'; Carry:'+edittoolingsn.Text;  ;
                                exit;
                            end;
                       end;
                 end;
                 next;
             end;
         end;


         CLOSE;
         COMMANDTEXT:=' SELECT nvl(max(c.used_count),0) as max_count '
                     +' FROM SAJET.SYS_TOOLING A,sajet.SYS_TOOLING_SN B, sajet.G_TOOLING_SN_STATUS C  '
                     +' WHERE  A.TOOLING_NO=:tooling_no AND '
                     +' A.TOOLING_ID=B.TOOLING_ID AND B.TOOLING_SN_ID=C.TOOLING_SN_ID ' ;
         params.ParamByName('tooling_NO').AsString :=trim(editcarrysn.Text );
         OPEN;

         if fieldbyname('max_count').AsInteger   >=INTlimit_used_count then
            begin
               lblstatus.Caption :='THE CARRY LOT_SN LIMIT_COUNT:'+INTTOSTR(INTlimit_used_count) +'<= MAX_COUNT '+ fieldbyname('max_count').AsString  ;
              // cleardata;
               editcarrysn.SelectAll;
               editcarrysn.SetFocus ;
               EXIT;
            end
            else begin
                  CLOSE;
                  commandtext:=' UPDATE SAJET.G_TOOLING_SN_STATUS   '
                              +'  SET USED_COUNT = NVL(USED_COUNT,0) + 1, UPDATE_USERID = :Update_UserID, UPDATE_TIME = SYSDATE  '
                              +' WHERE TOOLING_SN_ID IN '
                              +' (SELECT B.TOOLING_SN_ID  FROM SAJET.SYS_TOOLING A,SAJET.SYS_TOOLING_SN B  '
                              +' WHERE  A.TOOLING_NO=:TOOLING_NO AND A.TOOLING_ID=B.TOOLING_ID )  '
                              +' AND STATUS=''Y'' ' ;
                  params.ParamByName('Update_UserID').AsString := UpdateUserID ;
                  params.ParamByName('tooling_NO').AsString := trim(editcarrysn.Text );
                  execute;

                  close;
                  commandtext:=' INSERT INTO SAJET.G_HT_TOOLING_SN_STATUS '
                              +'  SELECT * FROM SAJET.G_TOOLING_SN_STATUS  '
                              +' WHERE TOOLING_SN_ID IN '
                              +' (SELECT B.TOOLING_SN_ID  FROM SAJET.SYS_TOOLING A,SAJET.SYS_TOOLING_SN B  '
                              +' WHERE  A.TOOLING_NO=:TOOLING_NO AND A.TOOLING_ID=B.TOOLING_ID )  '
                              +' AND STATUS=''Y'' ' ;
                  params.ParamByName('tooling_NO').AsString := trim(editcarrysn.Text );
                  execute;

                  editcarrysn.SelectAll ;
                  lblstatus.Caption :=editcarrysn.Text +' Scan OK!'
                 end;

     end;
end;

procedure TfMain.sbtnQueryClick(Sender: TObject);
var 
  T1:tDate;
begin
  t1:=time;
  showcarry ;
 
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
    Params.ParamByName('dll_name').AsString := 'CARRYINPUTDLL.DLL';
    Open;
  end;

   cleardata;

end;


procedure TfMain.EditCarrySNKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if trim(editcarrysn.Text )<>'' then
     if key=13 then
        showcarry;
end;

end.

