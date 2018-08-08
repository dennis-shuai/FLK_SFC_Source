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
    edt4: TEdit;
    lbl4: TLabel;
    cmbType: TComboBox;
    ImageAll: TImage;
    procedure EditValueKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnSaveClick(Sender: TObject);
    procedure fromshow(Sender: TObject);
    procedure edt1KeyPress(Sender: TObject; var Key: Char);
    procedure edt2KeyPress(Sender: TObject; var Key: Char);
    procedure edt3KeyPress(Sender: TObject; var Key: Char);
    procedure edt4KeyPress(Sender: TObject; var Key: Char);
    procedure cmbTypeSelect(Sender: TObject);
    procedure edItSNKeyPress(Sender: TObject; var Key: Char);
    procedure edItSNChange(Sender: TObject);

    //procedure editReelnoKeyPress(Sender: TObject; var Key: Char);
  private

  public
    UpdateUserID,sPartID : String;
    isStart,IsOpen:boolean;
    sPdline,sProcess,sTerminal:string;
    Authoritys,AuthorityRole,FunctionName : String;
    BarApp,BarDoc,BarVars:variant;
    machine_Type,machine_Used,sToolingID,sOptype:string;
    warehouse_Name,locate_Name,warehouse_id,locate_id:string;
    procedure clearData;

  end;

var
  fMainForm: TfMainForm;
  iTerminal:string;

implementation


{$R *.dfm}
procedure TfMainForm.EditValueKeyPress(Sender: TObject; var Key: Char);
begin
  if key <> #13 then exit;

  if EditValue.text='' then exit;

  if (strtoint(EditValue.text)<35) or (strtoint(EditValue.Text)>50) then
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
 
     with Qrytemp do
     begin
         QryTemp.Close;
         QryTemp.Params.Clear;
         QryTemp.Params.CreateParam(ftstring,'SN',ptInput);
         QryTemp.CommandText:=' SELECT tooling_SN_ID FROM SAJET.SYS_TOOLING_SN '+
                             ' WHERE TOOLING_SN=:SN ' ;
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
     end;
     
     sToolingID :=   Qrytemp.fieldbyName('Tooling_SN_ID').AsString;
     EditValue.SetFocus;
     EditValue.SelectAll;
     msgPanel.Caption := 'Please Input Test Value';
     msgPanel.Color :=clGreen;
     if cmbType.Text ='' then Exit;

     if (edItSN.Text='') or (EditValue.Text='') or (edt1.Text='') or (edt2.Text='') or (edt3.Text='') or (edt4.Text='')then
     begin
          msgPanel.Caption := '請輸入相關信息';
          msgPanel.Color :=clRed;
          editsn.setfocus;
          exit;
     end;

     value:=EditValue.Text+'-'+edt1.Text+'-'+edt2.Text+'-'+edt3.Text+'-'+ edt4.Text;

 
     if QryData.IsEmpty then begin

          QryTemp.Close;
          QryTemp.Params.Clear;
          QryTemp.Params.CreateParam(ftstring,'SN',ptInput);
          QryTemp.Params.CreateParam(ftstring,'VALUE',ptInput);
          QryTemp.Params.CreateParam(ftstring,'OP_TYPE',ptInput);
          QryTemp.Params.CreateParam(ftstring,'UpdateUserID',ptInput);
          QryTemp.CommandText:=' Insert into  SAJET.G_TOOLING_SN_CLEAN(TOOLING_SN,ENABLED,UPDATE_USERID,'+
                               ' TEST_VALUE,TOOLING_TYPE,REMARKS,Maintain_Time) VALUES(:SN,''Y'',:updateUserid,:value,''SMT Stencil'',:OP_TYPE,sysdate)';
          Qrytemp.Params.ParamByName('SN').AsString := sToolingID;
          Qrytemp.Params.ParamByName('VALUE').AsString := value;
          Qrytemp.Params.ParamByName('OP_TYPE').AsString := 'OUT';
          Qrytemp.Params.ParamByName('UpdateUserID').AsString := UpdateUserID;
          QryTemp.Execute;

          QryTemp.Close;
          QryTemp.Params.Clear;
          QryTemp.Params.CreateParam(ftstring,'SN',ptInput);
          QryTemp.CommandText:=' Insert into  SAJET.G_HT_TOOLING_SN_CLEAN SELECT * FROM SAJET.G_TOOLING_SN_CLEAN WHERE TOOLING_SN =:SN';
          Qrytemp.Params.ParamByName('SN').AsString := sToolingID;
          QryTemp.Execute;
     end else
     begin

          QryTemp.Close;
          QryTemp.Params.Clear;
          QryTemp.Params.CreateParam(ftstring,'SN',ptInput);
          QryTemp.Params.CreateParam(ftstring,'VALUE',ptInput);
          QryTemp.Params.CreateParam(ftstring,'OP_TYPE',ptInput);
          QryTemp.Params.CreateParam(ftstring,'UpdateUserID',ptInput);
          QryTemp.CommandText:='UPDATE SAJET.G_TOOLING_SN_CLEAN SET  UPDATE_TIME=NULL,UPDATE_USERID=:UpdateUserID,work_order=NULL,'+
                               ' TEST_VALUE=:VALUE ,REMARKS =:OP_TYPE,RECID=NULL ,Maintain_Time =sysdate WHERE TOOLING_SN=:SN';
          Qrytemp.Params.ParamByName('SN').AsString :=sToolingID;
          Qrytemp.Params.ParamByName('VALUE').AsString :=value;
          Qrytemp.Params.ParamByName('UpdateUserID').AsString :=UpdateUserID;
          Qrytemp.Params.ParamByName('OP_TYPE').AsString := sOpType;
          QryTemp.Execute;

          QryTemp.Close;
          QryTemp.Params.Clear;
          QryTemp.Params.CreateParam(ftstring,'SN',ptInput);
          QryTemp.CommandText:=' Insert into  SAJET.G_HT_TOOLING_SN_CLEAN SELECT * FROM SAJET.G_TOOLING_SN_CLEAN WHERE TOOLING_SN =:SN';
          Qrytemp.Params.ParamByName('SN').AsString := sToolingID;
          QryTemp.Execute;

     end;
     
     edItSN.Text :='';
     clearData;
     edItSN.SetFocus;
     msgPanel.Caption := 'OK';
     msgPanel.Color :=clGreen;
     sbtnSave.Enabled :=false;     


end;

procedure TfMainForm.fromshow(Sender: TObject);
begin
  Editsn.SetFocus;
  sbtnSave.Enabled :=False;
  cmbType.Style :=csDropDownList;
end;


procedure TfMainForm.edt1KeyPress(Sender: TObject; var Key: Char);
begin
  if key <> #13 then exit;

  if edt1.text='' then exit;

  if (strtoint(edt1.text)<35) or (strtoint(edt1.Text)>50) then
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

    if (strtoint(edt2.text)<35) or (strtoint(edt2.Text)>50) then
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

    if (strtoint(edt3.text)<35) or (strtoint(edt3.Text)>50) then
    begin
      msgPanel.Caption := '張力測試值超出規格,請重新測試確認';
      msgPanel.Color :=clRed;
      sbtnSave.Enabled :=False;
      exit;
    end;

    msgPanel.Caption := '張力測試值輸入OK，請確認鋼網是否已清潔';
    msgPanel.Color :=clGreen;
    edt4.Clear;
    edt4.SetFocus;


end;

procedure TfMainForm.edt4KeyPress(Sender: TObject; var Key: Char);
begin
    if key <> #13 then exit;

    if edt4.text='' then exit;

    //edItSN.OnKeyPress(Sender,Key);

    if (strtoint(edt4.text)<35) or (strtoint(edt4.Text)>50) then
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

procedure TfMainForm.cmbTypeSelect(Sender: TObject);
begin
   if cmbType.Text ='入庫清洗'  then
      sOptype :='IN'
   else  if  cmbType.Text ='出庫清洗'  then
      sOptype :='OUT'
   else  if  cmbType.Text ='在線清洗'  then
      sOptype :='ONLINE';
end;

procedure TfMainForm.clearData;
begin
    edt1.Clear;
    edt2.Clear;
    edt3.Clear;
    edt4.Clear;
    EditValue.Clear;
    cmbType.Items.Clear;
    cmbType.Clear;
end;
procedure TfMainForm.edItSNKeyPress(Sender: TObject; var Key: Char);
begin
    if Key <>#13 then Exit;

    with Qrytemp do
    begin
        QryTemp.Close;
        QryTemp.Params.Clear;
        QryTemp.Params.CreateParam(ftstring,'SN',ptInput);
        QryTemp.CommandText:=' SELECT tooling_SN_ID FROM SAJET.SYS_TOOLING_SN '+
                             ' WHERE TOOLING_SN=:SN ' ;
        Qrytemp.Params.ParamByName('SN').AsString :=edItSN.Text;
        QryTemp.open;

        if Qrytemp.IsEmpty then exit;

         sToolingID :=   Qrytemp.fieldbyName('Tooling_SN_ID').AsString;
         EditValue.SetFocus;
         EditValue.SelectAll;
         msgPanel.Caption := 'Please Input Test Value';
         msgPanel.Color :=clGreen;

    end;

     QryData.Close;
     QryData.Params.Clear;
     QryData.Params.CreateParam(ftstring,'SN',ptInput);
     QryData.CommandText:='select * from sajet.G_Tooling_SN_CLEAN WHERE TOOLING_SN =:SN';
     QryData.Params.ParamByName('SN').AsString :=sToolingID;
     QryData.Open;
     if QryData.IsEmpty then begin
          cmbType.Clear;
          cmbType.Items.Add('出庫清洗');
          cmbType.ItemIndex :=0;
     end else begin
          sOpType := QryData.FieldByName('Remarks').AsString;
          if sOpType ='IN' then
              cmbType.Items.Add('出庫清洗')
          else begin
              cmbType.Items.Add('在線清洗');
              cmbType.Items.Add('入庫清洗');
          end;

          if cmbType.Text ='入庫清洗' then
                sOpType := 'IN'
          else if  cmbType.Text ='在線清洗' then
                 sOpType := 'ONLINE'
          else if  cmbType.Text ='入庫清洗' then
                  sOpType := 'OUT';
     end;
end;

procedure TfMainForm.edItSNChange(Sender: TObject);
begin
  clearData;
end;

end.








