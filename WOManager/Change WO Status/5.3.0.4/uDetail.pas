unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles, ComCtrls;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryMaterial: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    lablType: TLabel;
    Label6: TLabel;
    Image1: TImage;
    SBTCONFIRM: TSpeedButton;
    lablReel: TLabel;
    QryReel: TClientDataSet;
    DataSource3: TDataSource;
    QryHT: TClientDataSet;
    Label4: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    EditWO: TEdit;
    EditWORULE: TEdit;
    EditINPUTQTY: TEdit;
    EditOUTPUTQTY: TEdit;
    EditERPQTY: TEdit;
    Memo: TMemo;
    Labeltargetqty: TLabel;
    Edittargetqty: TEdit;
    EditWOstatus: TEdit;
    Label3: TLabel;
    Cmbboxwostatus: TComboBox;
    Editnewtargetqty: TEdit;
    Imagenewtargetqty: TImage;
    sbtnchangetargetqty: TSpeedButton;
    editNewInputQty: TEdit;
    ImageNewInputQty: TImage;
    btnchangeInputqty: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure EditWOChange(Sender: TObject);
    procedure EditWOKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MemoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SBTCONFIRMClick(Sender: TObject);
    procedure LabeltargetqtyClick(Sender: TObject);
    procedure sbtnchangetargetqtyClick(Sender: TObject);
    procedure LabeltargetqtyDblClick(Sender: TObject);
    procedure Label8DblClick(Sender: TObject);
    procedure btnchangeInputqtyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    g_wo: string;
    UpdateUserID, gsLabelField, sCaps, gsReelField: string;
    Function GetWO(WO:string):string;
    Function cleardate:string;
  end;

var
  fDetail: TfDetail;
implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin;

Function TfDetail.Getwo(wo:string):string;
begin
    with QryTemp do
    begin
        close;
        params.Clear;
        params.CreateParam(ftstring,'WO',Ptinput);
        commandtext:=' select work_order,wo_rule,target_qty,input_qty,output_qty,wo_status,erp_qty,  '
                     +' decode(WO_STATUS,''0'',''Initial'',''1'',''Prepare'',''2'',''Release'',''3'',''WIP'',''4'',''Hold'',''5'',''Cancel'',''6'',''Complete'',''9'',''Complete No-Charge'') STATUS   '
                    +' from sajet.g_wo_base where work_order=:wo and rownum=1 ' ;
        params.ParamByName('wo').AsString :=wo;
        open;
        if not isempty then
        begin
           result:=trim(editwo.Text);
           editworule.Text :=fieldbyname('wo_rule').AsString ;
           edittargetqty.Text :=fieldbyname('target_qty').AsString ;
           editinputqty.Text :=fieldbyname('input_qty').AsString ;
           editoutputqty.Text :=fieldbyname('output_qty').AsString ;
           editerpqty.Text :=fieldbyname('erp_qty').AsString ;
           editwostatus.Text :=fieldbyname('status').AsString ;
        end
        else
        begin
            result:='XXX';
            editwo.SelectAll ;
            editwo.SetFocus ;
            cleardate;
        end;

    end;
end;
 
Function TfDetail.cleardate :string;
begin
  //editwo.Clear ;
 // editwo.SetFocus ;
  editworule.Clear ;
  editinputqty.Clear ;
  editoutputqty.Clear ;
  editerpqty.Clear ;
  edittargetqty.Clear ;
  editwostatus.Clear ;
  memo.Clear ;
end;


procedure TfDetail.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  editwo.Clear ;
  editwo.SetFocus ;
  cleardate;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'CHANGEWOSTATUSDLL.DLL';
    Open;

  end;
end;


procedure TfDetail.EditWOChange(Sender: TObject);
begin
   cleardate;
   if editnewtargetqty.Visible =true then
      editnewtargetqty.Visible :=false;
   if sbtnchangetargetqty.Visible =true then
      sbtnchangetargetqty.Visible :=false;
   if imagenewtargetqty.Visible =true then
      imagenewtargetqty.Visible :=false;
end;

procedure TfDetail.EditWOKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=13 then
 begin
   if trim(editwo.Text)='' then exit;
   g_wo:=getwo(editwo.Text);
   if g_wo='XXX' Then
   begin
       editwo.SelectAll ;
       editwo.SetFocus ;
       cleardate;
       showmessage('No Find WO!');
       EXIT;
   end;
   if uppercase(editwostatus.Text)='HOLD' THEN
   begin
       showmessage('WO is Hold Status!');
       exit;
   end;
   if uppercase(editwostatus.Text)='CANCEL' THEN
   begin
       showmessage('WO is Cancel Status!');
       exit;
   end;
   editwo.Enabled :=false;
   memo.Enabled :=true;
   cmbboxwostatus.Enabled :=true;
 end;
end;

procedure TfDetail.MemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=13 then
 begin
   if trim(memo.Text)='' then
   begin
     memo.SelectAll ;
     memo.SetFocus ;
     exit;
   end;
   if (uppercase(editwostatus.Text)<>'HOLD')  or  (uppercase(editwostatus.Text)<>'CANCEL') then
   begin
       sbtconfirm.Enabled :=true;
   end;
 end;
end;

procedure TfDetail.SBTCONFIRMClick(Sender: TObject);
var strwostatus:string;
begin
   if (Cmbboxwostatus.Text='Initial') or (Cmbboxwostatus.Text='Prepare')
      or (Cmbboxwostatus.Text='Release') or (Cmbboxwostatus.Text='WIP')
      or  (Cmbboxwostatus.Text='Complete')  then
   begin
      if  Cmbboxwostatus.Text='Initial' then strwostatus:='0';
      if  Cmbboxwostatus.Text='Prepare' then strwostatus:='1';
      if  Cmbboxwostatus.Text='Release' then strwostatus:='2';
      if  Cmbboxwostatus.Text='WIP' then strwostatus:='3';
      if  Cmbboxwostatus.Text='Complete' then strwostatus:='6';
   end
   else
   begin
       showmessage('Please select WO_STATUS!');
       EXIT;
   end;

   with qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'work_order',ptinput);
       commandtext:=' select * from sajet.g_wo_Base where work_order=:work_order  ';
       params.ParamByName('work_order').AsString :=g_wo;
       Open;
       if (FieldByName('ROUTE_ID').AsString ='0') and ( (strwostatus='2') or (strwostatus='3') )  then begin
           Showmessage('½Ð¥ýºûÅ@¤u¥O!')  ;
           Exit;
       end;
   end;

   with qrytemp do
   begin
       close;
       params.Clear ;
       params.CreateParam(ftstring,'wo_status',ptinput);
       params.CreateParam(ftstring,'work_order',ptinput);
       params.CreateParam(ftstring,'update_userid',ptinput);
       commandtext:='update sajet.g_wo_base set wo_status=:wo_status ,update_userid=:update_userid,update_time=sysdate '
                   +' where work_order=:work_order and rownum=1 ';
       params.ParamByName('wo_status').AsString :=strwostatus;
       params.ParamByName('work_order').AsString :=g_wo;
       params.ParamByName('update_userid').AsString :=UpdateUserID;
       execute;

       close;
       params.Clear ;
       params.CreateParam(ftstring,'WORK_ORDER',ptinput);
       commandtext:=' insert into sajet.g_ht_wo_base '
                   +' select * from sajet.g_wo_base where work_order=:work_order and rownum=1 ';
       params.ParamByName('work_order').AsString :=g_wo;
       execute;

       close;
       params.Clear;
       params.CreateParam(ftstring,'wo_status',ptinput);
       params.CreateParam(ftstring,'work_order',ptinput);
       params.CreateParam(ftstring,'update_userid',ptinput);
       params.CreateParam(ftstring,'memo',ptinput);
       commandtext:='insert into sajet.g_wo_status(work_order,wo_status,memo,update_userid,update_time) '
                   +' values(:work_order,:wo_status,:memo,:update_userid,sysdate)';
       params.ParamByName('work_order').AsString :=g_wo;
       params.ParamByName('wo_status').AsString :=strwostatus;
       params.ParamByName('memo').AsString :=trim(memo.Text); 
       params.ParamByName('update_userid').AsString :=UpdateUserID;
       execute;

       memo.Enabled :=false;
       cmbboxwostatus.Enabled :=false;
       sbtconfirm.Enabled :=false;
       editwo.Enabled :=true;
       editwo.SelectAll ;
       editwo.SetFocus ;

       Showmessage('Update OK!')  ;

   end;




end;

procedure TfDetail.LabeltargetqtyClick(Sender: TObject);
begin
   if editwo.Enabled =false then
   begin
       editnewtargetqty.Visible :=true;
       editnewtargetqty.Clear ;
       editnewtargetqty.SetFocus ;
       sbtnchangetargetqty.Visible :=true;
       imagenewtargetqty.Visible :=true;
   end;
end;

procedure TfDetail.sbtnchangetargetqtyClick(Sender: TObject);
begin
    if (strtoint(editnewtargetqty.Text)>=0) and ( MessageDlg('Change Target_Qty,Do you now?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      with qrytemp do
      begin
          close;
          params.Clear ;
          params.CreateParam(ftstring,'target_qty',ptinput);
          params.CreateParam(ftstring,'work_order',ptinput);
          params.CreateParam(ftstring,'update_userid',ptinput);
          commandtext:='update sajet.g_wo_base set target_qty=:target_qty ,update_userid=:update_userid,update_time=sysdate '
                   +' where work_order=:work_order and rownum=1 ';
          params.ParamByName('target_qty').AsInteger :=strtoint(editnewtargetqty.Text);
          params.ParamByName('work_order').AsString :=g_wo;
          params.ParamByName('update_userid').AsString :=UpdateUserID;
          execute;

          close;
          params.Clear ;
          params.CreateParam(ftstring,'WORK_ORDER',ptinput);
          commandtext:=' insert into sajet.g_ht_wo_base '
                   +' select * from sajet.g_wo_base where work_order=:work_order and rownum=1 ';
          params.ParamByName('work_order').AsString :=g_wo;
          execute;

          editnewtargetqty.Visible :=false;
          sbtnchangetargetqty.Visible :=false;
          imagenewtargetqty.Visible :=false;
          editwo.Enabled :=true;
          showmessage('Target_qty update OK!') ;
       end;
     end
     ELSE
     BEGIN
          editnewtargetqty.Visible :=false;
          sbtnchangetargetqty.Visible :=false;
          imagenewtargetqty.Visible :=false;
          editwo.Enabled :=true;
     END;
end;


procedure TfDetail.LabeltargetqtyDblClick(Sender: TObject);
begin
   if editwo.Enabled =false then
   begin
       editnewtargetqty.Visible :=true;
       editnewtargetqty.Clear ;
       editnewtargetqty.SetFocus ;
       sbtnchangetargetqty.Visible :=true;
       imagenewtargetqty.Visible :=true;
   end;
end;

procedure TfDetail.Label8DblClick(Sender: TObject);
begin
   if editwo.Enabled =false then
   begin
       editnewInputqty.Visible :=true;
       editnewInputqty.Clear ;
       editnewInputqty.SetFocus ;
       btnchangeInputqty.Visible :=true;
       ImageNewInputQty.Visible :=true;
   end;
end;

procedure TfDetail.btnchangeInputqtyClick(Sender: TObject);
begin
  if (strtoint(editNewInputQty.Text)>=0) and ( MessageDlg('Change Target_Qty,Do you now?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      with qrytemp do
      begin
          close;
          params.Clear ;
          params.CreateParam(ftstring,'Input_QTY',ptinput);
          params.CreateParam(ftstring,'work_order',ptinput);
          params.CreateParam(ftstring,'update_userid',ptinput);
          commandtext:='update sajet.g_wo_base set Input_QTY=:Input_QTY ,update_userid=:update_userid,update_time=sysdate '
                   +' where work_order=:work_order and rownum=1 ';
          params.ParamByName('Input_QTY').AsInteger :=strtoint(editNewInputQty.Text);
          params.ParamByName('work_order').AsString :=g_wo;
          params.ParamByName('update_userid').AsString :=UpdateUserID;
          execute;

          close;
          params.Clear ;
          params.CreateParam(ftstring,'WORK_ORDER',ptinput);
          commandtext:=' insert into sajet.g_ht_wo_base '
                   +' select * from sajet.g_wo_base where work_order=:work_order and rownum=1 ';
          params.ParamByName('work_order').AsString :=g_wo;
          execute;

          editNewInputQty.Visible :=false;
          btnchangeInputqty.Visible :=false;
          ImageNewInputQty.Visible :=false;
          editwo.Enabled :=true;
          showmessage('Input_qty update OK!') ;
       end;
    end
  ELSE
  BEGIN
          editNewInputQty.Visible :=false;
          btnchangeInputqty.Visible :=false;
          ImageNewInputQty.Visible :=false;
          editwo.Enabled :=true;
  END;
end;

end.

