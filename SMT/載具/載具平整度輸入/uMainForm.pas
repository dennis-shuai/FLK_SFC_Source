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
    EditValue: TEdit;
    labInputQty: TLabel;
    sbtnSave: TSpeedButton;
    Image3: TImage;
    procedure edItSNKeyPress(Sender: TObject; var Key: Char);
    procedure EditValueKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnSaveClick(Sender: TObject);
    procedure fromshow(Sender: TObject);

    //procedure editReelnoKeyPress(Sender: TObject; var Key: Char);
  private

  public
    UpdateUserID,sPartID : String;
    isStart,IsOpen:boolean;
    sPdline,sProcess,sTerminal:string;
    Authoritys,AuthorityRole,FunctionName : String;
    BarApp,BarDoc,BarVars:variant;
    function GETSYSDATE:TDateTime;

  end;

var
  fMainForm: TfMainForm;
  iTerminal:string;

implementation


{$R *.dfm}
procedure TfMainForm.edItSNKeyPress(Sender: TObject; var Key: Char);
begin
    if key <> #13 then exit;

    IF EDITSN.TEXT='' THEN EXIT;

    with Qrytemp do
    begin
        QryTemp.Close;
        QryTemp.Params.Clear;
        QryTemp.Params.CreateParam(ftstring,'SN',ptInput);
        QryTemp.CommandText:='select * from SAJET.SYS_TOOLING a,sajet.sys_tooling_SN b where A.TOOLING_ID =B.TOOLING_ID '+
                         ' and A.TOOLING_NAME =''SMT_CARRIER'' and b.TOOLING_SN =:SN';
        Qrytemp.Params.ParamByName('SN').AsString :=edItSN.Text;
        QryTemp.open;

        if Qrytemp.IsEmpty then
         BEGIN
            editSN.SetFocus;
            editSN.SelectAll;
            edItSN.Clear;
            msgPanel.Caption := 'CARRY ERROR';
            msgPanel.Color :=clRed;
            exit;
         end;
            EditValue.SetFocus;
            EditValue.SelectAll;
            msgPanel.Caption := 'Please Input Test Value';
            msgPanel.Color :=clGreen;
    end;
end;


procedure TfMainForm.EditValueKeyPress(Sender: TObject; var Key: Char);
begin
  if key <> #13 then exit;

  if EditValue.text='' then exit;

  sbtnSave.Click;

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
    if (edItSN.Text='') or (EditValue.Text='') then
      begin
          msgPanel.Caption := '請輸入相關信息';
          msgPanel.Color :=clRed;
          editsn.setfocus;
          exit;
      end;

     value:=EditValue.Text;

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



     
     edItSN.Clear;
     EditValue.Clear;
     edItSN.SetFocus;
     msgPanel.Caption := 'OK';
     msgPanel.Color :=clGreen;



end;

procedure TfMainForm.fromshow(Sender: TObject);
begin
  Editsn.SetFocus;
  sbtnSave.Enabled :=False;
end;




end.








