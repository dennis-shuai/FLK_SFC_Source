unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles;

type
  TfMainForm = class(TForm)
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    msgPanel: TPanel;
    Label2: TLabel;
    edtToolinglNo: TEdit;
    labInputQty: TLabel;
    sbtnSave: TSpeedButton;
    QryTemp1: TClientDataSet;
    ImageAll: TImage;
    procedure edtToolinglNoKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);

  public
    UpdateUserID,sPartID : String;
    sTerminal:string;

  end;

var
  fMainForm: TfMainForm;
  gWO,gCarrierNO:string;
  iCarrierSNCount,iSNCount:Integer;
  iTerminal:string;

implementation


{$R *.dfm}


procedure TfMainForm.edtToolinglNoKeyPress(Sender: TObject; var Key: Char);
var sdate:TDateTime;
begin
    if key <> #13 then exit;
    if Length(edtToolinglNo.Text)<> 5 then
    begin
        msgpanel.Caption := '條碼長度錯誤';
        msgpanel.Color:=clRed;
        edtToolinglNo.Clear;
        edtToolinglNo.SetFocus;
        Exit;
    end;

    if (Copy(edtToolinglNo.Text,1,1)<> 'T') and
       (Copy(edtToolinglNo.Text,1,1)<> 'C') and
       (Copy(edtToolinglNo.Text,1,1)<> 'M') then
    begin
        msgpanel.Caption := '不是Carry或者Magzine條碼';
        msgpanel.Color:=clRed;
        edtToolinglNo.Clear;
        edtToolinglNo.SetFocus;
        Exit;
    end;

    Qrytemp.Close;
    Qrytemp.Params.Clear;
    Qrytemp.Params.CreateParam(ftstring,'SN',ptinput);
    Qrytemp.CommandText:='SELECT * FROM SAJET.G_TOOLING_SN_CLEAN WHERE TOOLING_SN =:SN';
    Qrytemp.Params.ParamByName('SN').AsString :=edtToolinglNo.Text;
    Qrytemp.Open;

    if Qrytemp.IsEmpty then
    begin
         Qrytemp1.Close;
         Qrytemp1.Params.Clear;
         Qrytemp1.Params.CreateParam(ftstring,'SN',ptinput);
         Qrytemp1.Params.CreateParam(ftstring,'USERID',ptinput);
         Qrytemp1.CommandText:= 'INSERT INTO SAJET.G_TOOLING_SN_CLEAN (TOOLING_SN,Update_Time,UPDATE_USERID,ENABLED)'+
                                   'VALUES(:SN,sysdate,:USERID,''Y'')';
         Qrytemp1.Params.ParamByName('SN').AsString := edtToolinglNo.Text;
         Qrytemp1.Params.ParamByName('USERID').AsString :=UpdateuserID;
         Qrytemp1.Execute;


    end else
    begin
         sdate :=QryTemp.fieldBYname('update_time').AsDateTime;

         Qrytemp1.Close;
         Qrytemp1.Params.Clear;
         Qrytemp1.Params.CreateParam(ftstring,'SN',ptinput);
         Qrytemp1.Params.CreateParam(ftstring,'sTime',ptinput);
         Qrytemp1.CommandText:= ' Update SAJET.G_HT_TOOLING_SN_CLEAN set Used_hour = Round((sysdate-update_time)*24,2) '+
                                ' Where Tooling_sn=:SN and Update_time =:stime ';
         Qrytemp1.Params.ParamByName('SN').AsString := edtToolinglNo.Text;
         Qrytemp1.Params.ParamByName('sTime').AsDateTime := sDate;
         Qrytemp1.Execute;

         Qrytemp1.Close;
         Qrytemp1.Params.Clear;
         Qrytemp1.Params.CreateParam(ftstring,'SN',ptinput);
         Qrytemp1.Params.CreateParam(ftstring,'USERID',ptinput);
         Qrytemp1.CommandText:='UPDATE SAJET.G_TOOLING_SN_CLEAN SET UPDATE_USERID=:USERID,UPDATE_TIME=SYSDATE ,enabled=''Y'',Used_Hour=NULL WHERE TOOLING_SN=:SN';
         Qrytemp1.Params.ParamByName('SN').AsString := edtToolinglNo.Text;
         Qrytemp1.Params.ParamByName('USERID').AsString := UpdateUserID;
         Qrytemp1.Execute;
    end;

    Qrytemp1.Close;
    Qrytemp1.Params.Clear;
    Qrytemp1.Params.CreateParam(ftstring,'SN',ptinput);
    Qrytemp1.CommandText:= 'INSERT INTO SAJET.G_HT_TOOLING_SN_CLEAN  select * from sajet.G_TOOLING_SN_CLEAN where Tooling_sn=:SN';
    Qrytemp1.Params.ParamByName('SN').AsString := edtToolinglNo.Text;
    Qrytemp1.Execute;


    msgpanel.Caption := edtToolinglNo.Text+'    清洗OK';
    msgpanel.Color:=clgreen;
    edtToolinglNo.Clear;
    edtToolinglNo.SetFocus;
end;

procedure TfMainForm.FormShow(Sender: TObject);
begin
   edtToolinglNo.SetFocus;
end;

end.
