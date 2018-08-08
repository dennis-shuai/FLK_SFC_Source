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
    EditReelno: TEdit;
    labInputQty: TLabel;
    sbtnSave: TSpeedButton;
    QryTemp1: TClientDataSet;
    ImageAll: TImage;
    lbl1: TLabel;
    cmb1: TComboBox;
    procedure EditReelnoKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure cmb1Select(Sender: TObject);

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


procedure TfMainForm.EditReelnoKeyPress(Sender: TObject; var Key: Char);
begin
   if key <> #13 then exit;
   if cmb1.ItemIndex <0 then begin
      msgPanel.Caption:='請選擇機台';
      msgpanel.Color:=clRed;
      EditReelno.SelectAll;
      Exit;
   end;
   

   Qrytemp.Close;
   Qrytemp.Params.Clear;
   Qrytemp.Params.CreateParam(ftstring,'REEL',ptinput);
   Qrytemp.CommandText:='SELECT PART_SN,OP_TYPE FROM SAJET.G_PSN_STATUS WHERE PART_SN=:REEL ';
   Qrytemp.Params.ParamByName('REEL').AsString :=EditReelno.Text;
   Qrytemp.Open;

   if QryTemp.IsEmpty then
   begin
       msgPanel.Caption:='膠水沒有回溫';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end else if Qrytemp.FieldByName('OP_TYPE').AsString = '回溫' then begin
       msgPanel.Caption:='膠水沒有脫泡';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end else if Qrytemp.FieldByName('OP_TYPE').AsString = 'UPLOAD' then begin
       msgPanel.Caption:='膠水已經上線';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end;
   
   Qrytemp1.Close;
   Qrytemp1.Params.Clear;
   Qrytemp1.Params.CreateParam(ftstring,'REEL',ptinput);
   Qrytemp1.Params.CreateParam(ftstring,'USERID',ptinput);
   Qrytemp1.Params.CreateParam(ftstring,'TERMINAL',ptinput);
   Qrytemp1.CommandText:=' UPDATE SAJET.G_PSN_STATUS SET UPDATE_USERID=:USERID,UPDATE_TIME=SYSDATE,'+
                         ' TERMINAL_ID =:TERMINAL,OP_TYPE =''UPLOAD'' WHERE PART_SN=:REEL ';
   Qrytemp1.Params.ParamByName('REEL').AsString := EditReelno.Text;
   Qrytemp1.Params.ParamByName('TERMINAL').AsString := sTerminal;
   Qrytemp1.Params.ParamByName('USERID').AsString := UpdateUserID;
   Qrytemp1.Execute;

   Qrytemp1.Close;
   Qrytemp1.Params.Clear;
   Qrytemp1.Params.CreateParam(ftstring,'REEL',ptinput);
   Qrytemp1.CommandText:='INSERT INTO SAJET.G_PSN_TRAVEL SELECT * FROM  SAJET.G_PSN_STATUS WHERE PART_SN=:REEL';
   Qrytemp1.Params.ParamByName('REEL').AsString := EditReelno.Text;
   Qrytemp1.Execute;

   msgpanel.Caption := '膠水上線OK';
   msgpanel.Color:=clgreen;
   EditReelno.Clear;
   EditReelno.SetFocus;

end;

procedure TfMainForm.FormShow(Sender: TObject);
begin
   Editreelno.SetFocus;
   cmb1.Style := csDropDownList;
end;

procedure TfMainForm.cmb1Select(Sender: TObject);
begin
   with QryTemp do
   begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'Terminal',ptInput);
       CommandText :='select Terminal_ID from sajet.sys_terminal where terminal_name =:Terminal';
       Params.ParamByName('Terminal').AsString := cmb1.Text ;
       Open;
       if IsEmpty then begin
         MessageDlg('No Terminal',mtError,[mbOK],0);
         EditReelno.Enabled :=false;
         Exit;
       end;
       sTerminal := fieldbyname('Terminal_id').AsString;
   end;
   EditReelno.Enabled :=True;
   EditReelno.SetFocus;
   EditReelno.SelectAll;
end;

end.
