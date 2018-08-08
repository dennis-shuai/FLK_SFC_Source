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
    lbl1: TLabel;
    Image3: TImage;
    edt1: TEdit;
    edt2: TEdit;
    edt3: TEdit;
    procedure edItSNKeyPress(Sender: TObject; var Key: Char);
    procedure EditValueKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnSaveClick(Sender: TObject);
    procedure fromshow(Sender: TObject);
    procedure edt1KeyPress(Sender: TObject; var Key: Char);
    procedure edt2KeyPress(Sender: TObject; var Key: Char);
    procedure edt3KeyPress(Sender: TObject; var Key: Char);

    //procedure editReelnoKeyPress(Sender: TObject; var Key: Char);
  private

  public
    UpdateUserID,sPartID : String;
    isStart,IsOpen:boolean;
    sPdline,sProcess,sTerminal:string;
    Authoritys,AuthorityRole,FunctionName : String;
    BarApp,BarDoc,BarVars:variant;

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
      QryTemp.CommandText:=('SELECT * FROM SAJET.G_TOOLING_MATERIAL A,SAJET.SYS_TOOLING_SN B '
                           +' WHERE A.TOOLING_SN_ID=B.TOOLING_SN_ID AND TOOLING_SN=:SN');
      Qrytemp.Params.ParamByName('SN').AsString :=edItSN.Text;
      QryTemp.open;

      if Qrytemp.IsEmpty then
       BEGIN
          editSN.SetFocus;
          editSN.SelectAll;
          edItSN.Clear;
          msgPanel.Caption := 'STENCIL ERROR';
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

  if (strtoint(EditValue.text)<22) or (strtoint(EditValue.Text)>38) then
  begin
      msgPanel.Caption := '張力測試值超出規格,請重新測試確認';
      msgPanel.Color :=clRed;
      sbtnSave.Enabled :=False;
      exit;
  end;

       edt1.SetFocus;
       edt1.Clear;
       msgPanel.Caption := '請繼續輸入鋼網四角其他張力量測值';
       msgPanel.Color :=clGreen;



end;

procedure TfMainForm.sbtnSaveClick(Sender: TObject);
var value :string;

begin

    if (edItSN.Text='') or (EditValue.Text='') or (edt1.Text='') or (edt2.Text='') or (edt2.Text='') then
      begin
          msgPanel.Caption := '請輸入相關信息';
          msgPanel.Color :=clRed;
          editsn.setfocus;
          exit;
      end;

     value:=EditValue.Text+'-'+edt1.Text+'-'+edt2.Text+'-'+edt3.Text;
      
     QryTemp.Close;
     QryTemp.Params.Clear;
     QryTemp.Params.CreateParam(ftstring,'SN',ptInput);
     QryTemp.Params.CreateParam(ftstring,'VALUE',ptInput);
     QryTemp.Params.CreateParam(ftstring,'UpdateUserID',ptInput);
     QryTemp.CommandText:='UPDATE SAJET.G_TOOLING_MATERIAL SET CUST_ASSET_NO=:VALUE,UPDATE_TIME=SYSDATE,'
                           +'UPDATE_USERID=:UpdateUserID WHERE  TOOLING_SN_ID IN (SELECT TOOLING_SN_ID FROM'
                            +'  SAJET.SYS_TOOLING_SN WHERE TOOLING_SN=:SN)';
     Qrytemp.Params.ParamByName('SN').AsString :=EditSN.Text;
     Qrytemp.Params.ParamByName('VALUE').AsString :=value;
     Qrytemp.Params.ParamByName('UpdateUserID').AsString :=UpdateUserID;
     QryTemp.Execute;

     
     edItSN.Clear;
     EditValue.Clear;
     edt1.Clear;
     edt2.Clear;
     edt3.Clear;
     edItSN.SetFocus;
     msgPanel.Caption := 'OK';
     msgPanel.Color :=clGreen;

     sbtnSave.Enabled :=false;


end;

procedure TfMainForm.fromshow(Sender: TObject);
begin
  Editsn.SetFocus;
  sbtnSave.Enabled :=False;
end;




procedure TfMainForm.edt1KeyPress(Sender: TObject; var Key: Char);
begin
  if key <> #13 then exit;

  if edt1.text='' then exit;

  if (strtoint(edt1.text)<22) or (strtoint(edt1.Text)>38) then
  begin
      msgPanel.Caption := '張力測試值超出規格,請重新測試確認';
      msgPanel.Color :=clRed;
      sbtnSave.Enabled :=False;
      exit;
  end;

       edt2.SetFocus;
       edt2.Clear;
       msgPanel.Caption := '請繼續輸入鋼網四角其他張力量測值';
       msgPanel.Color :=clGreen;
end;

procedure TfMainForm.edt2KeyPress(Sender: TObject; var Key: Char);
begin
  if key <> #13 then exit;

  if edt2.text='' then exit;

  if (strtoint(edt2.text)<22) or (strtoint(edt2.Text)>38) then
  begin
      msgPanel.Caption := '張力測試值超出規格,請重新測試確認';
      msgPanel.Color :=clRed;
      sbtnSave.Enabled :=False;
      exit;
  end;

       edt3.SetFocus;
       edt3.Clear;
       msgPanel.Caption := '請繼續輸入鋼網四角其他張力量測值';
       msgPanel.Color :=clGreen;
end;

procedure TfMainForm.edt3KeyPress(Sender: TObject; var Key: Char);
begin
  if key <> #13 then exit;

  if edt3.text='' then exit;

  if (strtoint(edt3.text)<22) or (strtoint(edt3.Text)>38) then
  begin
      msgPanel.Caption := '張力測試值超出規格,請重新測試確認';
      msgPanel.Color :=clRed;
      sbtnSave.Enabled :=False;
      exit;
  end;

       msgPanel.Caption := '張力測試值輸入OK，請確認鋼網是否已清潔';
       msgPanel.Color :=clGreen;
       sbtnSave.Enabled :=True;

end;

end.








