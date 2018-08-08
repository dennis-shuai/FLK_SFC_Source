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
    EditStatus: TEdit;
    Editcount: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    EditADDCOUNT: TEdit;
    Image2: TImage;
    sbtnOK: TSpeedButton;
    Image1: TImage;
    SBTNCANCEL: TSpeedButton;
    LBLSTATUS: TLabel;
    Editmonitordept: TEdit;
    procedure sbtnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cleardata;
    procedure EditSNKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sbtnOKClick(Sender: TObject);
    procedure SBTNCANCELClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    function showSTENCIL(tooling_sn:string):string;
    PROCEDURE  UPDATESTENCIL;
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform;

procedure tfmain.cleardata;
begin
    editsn.Clear;
    editsn.SetFocus ;
    editaddcount.Clear ;
    editstatus.Clear ;
    editcount.Clear;
    lblstatus.Caption :='';
end;

function TfMain.showSTENCIL(tooling_sn:string):string;
begin
   with qrydata do
     begin
         close ;
         commandtext:= ' SELECT nvl(A.USED_COUNT,0) as used_count,A.LAST_MAINTAIN_TIME,A.STATUS,A.UPDATE_TIME,B.TOOLING_SN_ID '
                      +' FROM SAJET.G_TOOLING_SN_STATUS A,SAJET.SYS_TOOLING_SN B  '
                      +' ,SAJET.SYS_TOOLING C   '
                      +' WHERE A.TOOLING_SN_ID=B.TOOLING_SN_ID AND B.tooling_sn=:TOOLING_SN '
                      +'AND B.TOOLING_ID=C.TOOLING_ID  AND C.TOOLING_TYPE like :TOOL_TYPE ';
                  params.ParamByName('tooling_sn').AsString :=trim(editsn.Text );
                  params.ParamByName('tool_type').AsString :='%STENCIL' ;
         open;
         if recordcount=0 then
           begin
               result:='NOT FIND THE STENCIL SN!';
               EXIT;
           end
           ELSE
           BEGIN
                  IF fieldbyname('status').AsString='Y' then
                       editstatus.Text:='Y:正常' ;
                  IF fieldbyname('status').AsString='M' then
                       editstatus.Text:='M:保養';
                  IF fieldbyname('status').AsString='R' then
                       ediTstatus.Text:='R:維修';
                  IF fieldbyname('status').AsString='C' then
                       editstatus.Text:='C:校正評估';
                  IF fieldbyname('status').AsString='S' then
                       editstatus.Text:='S:報廢';

                  editcount.Text :=fieldbyname('used_count').AsString ;
                  IF uppERcase(FIELDBYNAME('STATUS').AsString) <>'Y' then
                     begin
                         result:='THE STENCIL SN IS NOT  正常　status!';
                         exit;
                     end ;
                  result:=tooling_sn;
           END;

         //導入了庫存部分的tooling 納入部門管控 add by key 2007.12.27
         With qrytemp do
         begin
              editmonitordept.Clear ;
              close;
              params.Clear ;
              params.CreateParam(ftstring,'tooling_sn_id',ptinput);
              commandtext:='select monitor_dept from sajet.g_tooling_material where tooling_sn_id=:tooling_sn_id and rownum=1';
              params.ParamByName('tooling_sn_id').AsString :=qrydata.fieldbyname('tooling_sn_id').AsString ;
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
          end;

     END;
END ;

procedure TfMain.UPDATESTENCIL;
BEGIN
    if trim(editaddcount.Text)='' then
       BEGIN
          editaddcount.SetFocus ;
          exit;
       end;

    with qrydata do
     begin
         close;
         commandtext:= ' select nvl(limit_used_count,0) as limit_used_count  from sajet.sys_tooling A,sajet.SYS_TOOLING_SN B WHERE A.TOOLING_ID=B.TOOLING_ID '
                      +' AND B.TOOLING_SN =:tooling_sn ';
         params.ParamByName('tooling_sn').AsString :=trim(editsn.Text );
         open;

         if fieldbyname('limit_used_count').AsInteger  <=STRTOINT(editCOUNT.Text) then
            begin
               showmessage('THE STENCIL SN LIMIT_COUNT:'+ fieldbyname('limit_used_count').AsString +'<= USED_COUNT '+ editCOUNT.Text) ;
               //cleardata;
               editsn.SetFocus ;
               EXIT;
            end
            else begin
                  CLOSE;
                  commandtext:=' UPDATE SAJET.G_TOOLING_SN_STATUS   '
                              +'  SET USED_COUNT = NVL(USED_COUNT,0) + :ADDCOUNT, UPDATE_USERID = :Update_UserID, UPDATE_TIME = SYSDATE  '
                              +'  WHERE TOOLING_SN_ID in (select tooling_SN_id from  sajet.sys_tooling_sn where tooling_sn= :tooling_sn) ';
                  params.ParamByName('addcount').AsString:=editaddcount.Text ; 
                  params.ParamByName('Update_UserID').AsString := UpdateUserID ;
                  params.ParamByName('tooling_sn').AsString := trim(editsn.Text );
                  execute;

                  close;
                  commandtext:=' INSERT INTO SAJET.G_HT_TOOLING_SN_STATUS '
                              +'  SELECT * FROM SAJET.G_TOOLING_SN_STATUS WHERE TOOLING_SN_ID in (select tooling_SN_id from  sajet.sys_tooling_sn where tooling_sn= :tooling_sn) AND ROWNUM = 1 ';
                  params.ParamByName('tooling_sn').AsString := trim(editsn.Text );
                  execute;

                  lblstatus.Caption :=editsn.Text+' ADD COUNT '+EDITADDCOUNT.Text+' OK !';
                 end;

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
    Params.ParamByName('dll_name').AsString := 'STENCILINPUTDLL.DLL';
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
           strtoolingsn:=showstencil(editsn.Text);
           if strtoolingsn<>editsn.Text then
           begin
              lblstatus.Caption :=strtoolingsn;
              editsn.SetFocus ;
              editsn.SelectAll ;
           end;
        end;
end;

procedure TfMain.sbtnOKClick(Sender: TObject);
var strtoolingsn:string;
begin
     strtoolingsn:=showstencil(editsn.Text);
     if strtoolingsn<>editsn.Text then
     begin
         lblstatus.Caption :=strtoolingsn;
         editsn.SetFocus ;
         editsn.SelectAll ;
         exit;
     end;
    UPDATESTENCIL;
    //SHOWSTENCIL;
    editADDcount.Clear ;
    editsn.SetFocus  ;
end;

procedure TfMain.SBTNCANCELClick(Sender: TObject);
begin
   cleardata;
end;

end.

