unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils, ComObj,// shellapi,
  Menus, uLang, IniFiles;

type
  TfMainForm = class(TForm)
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    QryTemp1: TClientDataSet;
    msgPanel: TPanel;
    ImageAll: TImage;
    Label3: TLabel;
    Label5: TLabel;
    edItSN: TEdit;
    labInputQty: TLabel;
    sbtnSave: TSpeedButton;
    Image3: TImage;
    cmbLine: TComboBox;
    Label1: TLabel;
    cmbOperate: TComboBox;
    LabTerminal: TLabel;
    procedure edItSNKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnSaveClick(Sender: TObject);
    procedure fromshow(Sender: TObject);
    procedure cmbLineSelect(Sender: TObject);

    //procedure editReelnoKeyPress(Sender: TObject; var Key: Char);
  private

  public
    UpdateUserID,stoolingsnid,sterminalid,sprocessid:string;
    Authoritys,AuthorityRole,FunctionName : String;
    function GETSYSDATE:TDateTime;

  end;

var
  fMainForm: TfMainForm;
  iTerminal:string;

implementation


{$R *.dfm}
procedure TfMainForm.edItSNKeyPress(Sender: TObject; var Key: Char);
begin
    sbtnSave.Enabled :=False;
    stoolingsnid :='';
    if key <> #13 then exit;

    IF EDITSN.TEXT='' THEN EXIT;

    with Qrytemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftstring,'SN',ptInput);
        CommandText:='select * from SAJET.SYS_TOOLING a,sajet.sys_tooling_SN b where A.TOOLING_ID =B.TOOLING_ID '+
                         ' and A.TOOLING_NAME =''ERASING KNIFE'' and b.TOOLING_SN =:SN';
        Params.ParamByName('SN').AsString :=edItSN.Text;
        open;

        if IsEmpty then
         BEGIN
            editSN.SetFocus;
            editSN.SelectAll;
            edItSN.Clear;
            msgPanel.Caption := 'TOOLING SN ERROR';
            msgPanel.Color :=clRed;
            exit;
         end;
         cmbLine.SetFocus;
         stoolingsnid := fieldByName('tooling_sn_id').AsString;
         msgPanel.Caption := 'Please Select Input Line';
         msgPanel.Color :=clGreen;
         if cmbLine.ItemIndex>=0 then begin
            sbtnSave.Enabled :=True;
         end;
    end;
end;


function TfMainForm.GetSYSDATE:TDateTime;
begin
   Qrytemp.Close;
   QryTemp.CommandText :=' SELECT SYSDATE iDATE FROM DUAL';
   QryTemp.Open;
   Result :=QryTemp.FieldByName('IDate').AsDateTime;

end;

procedure TfMainForm.sbtnSaveClick(Sender: TObject);
var value :string;
    CurrentDate:TDateTime;
begin
    CurrentDate :=GETSYSDATE;

    {
     QryTemp.Close;
     QryTemp.Params.Clear;
     QryTemp.Params.CreateParam(ftstring,'SN',ptInput);
     QryTemp.Params.CreateParam(ftstring,'VALUE',ptInput);
     QryTemp.Params.CreateParam(ftstring,'myDate',ptInput);
     QryTemp.Params.CreateParam(ftstring,'UpdateUserID',ptInput);
     QryTemp.CommandText:=' INSERT INTO SAJET.G_TOOLING_TEST_VALUE SELECT TOOLING_SN_ID ,'+
                          '  :VALUE,:UPDATEUSERID,:myDATE FROM SAJET.SYS_TOOLING_SN '+
                          '  WHERE TOOLING_SN= :SN';
     Qrytemp.Params.ParamByName('SN').AsString :=EditSN.Text;
     Qrytemp.Params.ParamByName('VALUE').AsString :=value;
     Qrytemp.Params.ParamByName('myDate').AsDateTime :=CurrentDate;
     Qrytemp.Params.ParamByName('UpdateUserID').AsString :=UpdateUserID;
     QryTemp.Execute;
      }
     QryTemp.Close;
     QryTemp.Params.Clear;
     QryTemp.Params.CreateParam(ftstring,'tooling_Id',ptInput);
     QryTemp.CommandText:=' select a.terminal_id from  SAJET.G_TOOLING_SN_STATUS a where a.tooling_sn_Id =:tooling_Id ' ;
     Qrytemp.Params.ParamByName('tooling_Id').AsString :=stoolingsnid;
     QryTemp.Open;

     if cmbOperate.ItemIndex =0 then
     begin
         if QryTemp.IsEmpty then begin
             QryTemp.Close;
             QryTemp.Params.Clear;
             QryTemp.Params.CreateParam(ftstring,'tooling_Id',ptInput);
             QryTemp.Params.CreateParam(ftstring,'process_id',ptInput);
             QryTemp.Params.CreateParam(ftstring,'terminal_id',ptInput);
             QryTemp.Params.CreateParam(ftstring,'UpdateUserID',ptInput);
             QryTemp.CommandText:=' INSERT INTO SAJET.G_TOOLING_SN_STATUS(tooling_sn_id,used_count,process_id,terminal_id,update_userid,update_time) '+
                                  '  values(:tooling_Id,0,:process_id,:terminal_id,:UpdateUserID,sysdate)';
             Qrytemp.Params.ParamByName('tooling_Id').AsString :=stoolingsnid;
             Qrytemp.Params.ParamByName('process_id').AsString :=sprocessid;
             Qrytemp.Params.ParamByName('terminal_id').AsString := sterminalid;
             Qrytemp.Params.ParamByName('UpdateUserID').AsString :=UpdateUserID;
             QryTemp.Execute;
         end else begin
             QryTemp.Close;
             QryTemp.Params.Clear;
             QryTemp.Params.CreateParam(ftstring,'tooling_Id',ptInput);
             QryTemp.Params.CreateParam(ftstring,'process_id',ptInput);
             QryTemp.Params.CreateParam(ftstring,'terminal_id',ptInput);
             QryTemp.Params.CreateParam(ftstring,'UpdateUserID',ptInput);
             QryTemp.CommandText:=' UPDATE SAJET.G_TOOLING_SN_STATUS set process_id=:process_id,terminal_id=:terminal_id,update_userid=:UpdateUserID,'+
                                  ' update_time=sysdate where terminal_id=:tooling_Id';
             Qrytemp.Params.ParamByName('tooling_Id').AsString :=stoolingsnid;
             Qrytemp.Params.ParamByName('process_id').AsString :=sprocessid;
             Qrytemp.Params.ParamByName('terminal_id').AsString := sterminalid;
             Qrytemp.Params.ParamByName('UpdateUserID').AsString :=UpdateUserID;
             QryTemp.Execute;
         end;
     end else if cmbOperate.ItemIndex =1 then begin
         if QryTemp.IsEmpty then begin
             msgPanel.Caption := 'NOT ONLINE ';
             msgPanel.Color :=clRed;
             Exit;
         end else begin
             QryTemp.Close;
             QryTemp.Params.Clear;
             QryTemp.Params.CreateParam(ftstring,'tooling_Id',ptInput);
             QryTemp.Params.CreateParam(ftstring,'UpdateUserID',ptInput);
             QryTemp.CommandText:=' UPDATE SAJET.G_TOOLING_SN_STATUS set update_userid=:UpdateUserID,'+
                                  ' update_time=sysdate where terminal_id=:tooling_Id';
             Qrytemp.Params.ParamByName('tooling_Id').AsString :=stoolingsnid;
             Qrytemp.Params.ParamByName('UpdateUserID').AsString :=UpdateUserID;
             QryTemp.Execute;

             QryTemp.Close;
             QryTemp.Params.Clear;
             QryTemp.Params.CreateParam(ftstring,'tooling_Id',ptInput);
             QryTemp.CommandText:=' INSERT INTO SAJET.G_HT_TOOLING_SN_STATUS select * from SAJET.G_TOOLING_SN_STATUS  where tooling_sn_id =:tooling_Id ';
             Qrytemp.Params.ParamByName('tooling_Id').AsString :=stoolingsnid;
             QryTemp.Execute;
         end;
     end;
     
     edItSN.Clear;
     cmbLine.ItemIndex :=-1;
     edItSN.SetFocus;
     sbtnSave.Enabled :=false;
     msgPanel.Caption := 'OK';
     msgPanel.Color :=clGreen;



end;

procedure TfMainForm.fromshow(Sender: TObject);
begin
    Editsn.SetFocus;
    sbtnSave.Enabled :=False;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.CommandText:=' select distinct a.pdline_Name from sajet.sys_pdline a,sajet.sys_terminal b,sajet.sys_process c where  a.pdline_id=b.pdline_id and '+
                         ' b.process_id=c.process_id and c.process_name like ''SMT_INPUT%'' and a.enabled=''Y'' and b.enabled=''Y'' and c.enabled=''Y'' order by a.pdline_Name ';
    QryTemp.Open;
    cmbLine.Items.Clear;

    QryTemp.First;
    while not QryTemp.Eof do begin
        cmbLine.Items.Add(QryTemp.fieldByName('pdline_Name').AsString);
        QryTemp.Next;
    end;
    cmbLine.Style :=csDropDownList;
    cmbOperate.Style :=csDropDownList;
end;




procedure TfMainForm.cmbLineSelect(Sender: TObject);
begin
    if stoolingsnid='' then begin
        msgPanel.Caption := ' tooling sn error';
        msgPanel.Color :=clRed;
        sbtnSave.Enabled :=false;
        Exit;
    end;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'pdline',ptInput);
    QryTemp.CommandText:=' select b.pdline_Name,a.process_Name,c.process_id,c.terminal_Name,c.terminal_id '+
                              ' from sajet.sys_process a, sajet.sys_pdline b,'+
                              ' sajet.sys_terminal c where b.pdline_name=:pdline '+
                              ' and a.process_id=c.process_id and a.process_Name  like ''SMT_INPUT%'' '+
                              ' and b.pdline_id=c.pdline_id  order by c.terminal_Name ';
    Qrytemp.Params.ParamByName('pdline').AsString :=cmbLine.Items.Strings[cmbLine.ItemIndex];
    QryTemp.Open;

    if QryTemp.IsEmpty then begin
        msgPanel.Caption := 'no Pdline Terminal';
        msgPanel.Color :=clRed;
        sbtnSave.Enabled :=false;
        Exit;
    end;
    sprocessid :=QryTemp.fieldByName('process_id').AsString;
    sterminalid :=  QryTemp.fieldByName('terminal_id').AsString;
    LabTerminal.Caption :=QryTemp.fieldByName('process_Name').AsString+'\'
                          +QryTemp.fieldByName('terminal_Name').AsString;
   sbtnSave.Enabled :=True;

end;

end.








