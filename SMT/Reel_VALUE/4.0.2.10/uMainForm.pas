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
    QryTemp1: TClientDataSet;
    msgPanel: TPanel;
    ImageAll: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    EditWo: TEdit;
    EditReelno: TEdit;
    EditValue: TEdit;
    labInputQty: TLabel;
    EditUP: TEdit;
    EditDOWN: TEdit;
    Label1: TLabel;
    Label4: TLabel;
    sbtnSave: TSpeedButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    procedure EditWoKeyPress(Sender: TObject; var Key: Char);
    procedure EditReelnoKeyPress(Sender: TObject; var Key: Char);
    procedure EditUPKeyPress(Sender: TObject; var Key: Char);
    procedure EditDOWNKeyPress(Sender: TObject; var Key: Char);
    procedure EditValueKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnSaveClick(Sender: TObject);
    procedure fromshow(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);


    //procedure editReelnoKeyPress(Sender: TObject; var Key: Char);
  private
    //m_SNDefectLevel: String;
    //procedure clearData;


    //function CheckCustomerRule: string;      //检查Customer字符规则,第一码,长度等
    //function CheckCustomerValue: string;    //检查Customer字符是否在0~Z之间

    //procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
    //procedure RemoveCarrier(sCarrier:string);


    //function GetPartID(partno :String) :String;
    //procedure ShowData(sCarrier :String);
  public
    UpdateUserID,sPartID : String;
    sPdline,sProcess,sTerminal:string;
    Authoritys,AuthorityRole,FunctionName : String;
    //Language : TLanguage;
    //procedure SetStatusbyAuthority;
    //Function LoadApServer : Boolean;
  end;

var
  fMainForm: TfMainForm;
  gWO,gCarrierNO,PARTNO :string;
  iCarrierSNCount,iSNCount:Integer;
  iTerminal:string;

implementation


{$R *.dfm}

procedure TfMainForm.EditWoKeyPress(Sender: TObject; var Key: Char);
begin
    if key <> #13 then exit;

    with Qrytemp do
     begin
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftstring,'Reel',ptInput);
      QryTemp.CommandText:='SELECT WORK_ORDER FROM SAJET.G_PICK_LIST WHERE MATERIAL_NO=:REEL';
      Qrytemp.Params.ParamByName('Reel').AsString :=Editwo.Text;
      QryTemp.open;

      if Qrytemp.IsEmpty then
          EditReelno.ReadOnly :=true;
          editWo.ReadOnly :=false;
          editWo.SetFocus;
          editWo.SelectAll;
          Qrytemp.Open;
     end;
       if not Qrytemp.IsEmpty then
     begin
       Editwo.Text :=Qrytemp.FieldByName('WORK_ORDER').asstring;
     end;

    with Sproc do
    begin
      Sproc.Close;
      Sproc.DataRequest('sajet.SJ_CHK_WO_INPUT');
      Sproc.FetchParams();
      Sproc.Params.ParamByName('TREV').AsString := editWO.Text;
      Sproc.Execute;

      if  Sproc.Params.ParamByName('TRES').AsString <> 'OK' then
      begin
          EditReelno.ReadOnly :=true;
          editWo.ReadOnly :=false;
          editWo.SetFocus;
          editWo.SelectAll;
          msgPanel.Caption := Sproc.Params.ParamByName('TRES').AsString;
          msgPanel.Color :=clRed;
          exit;
      end;
       EditReelno.ReadOnly :=false;
       editWo.ReadOnly :=true;
       editReelno.SetFocus;
       editReelno.Clear;
       msgPanel.Caption := 'WO OK,Please Input Reel NO';
       msgPanel.Color :=clGreen;
end;

    EditWo.Enabled:=False;
    EditReelno.SetFocus;
    Editreelno.SelectAll;

    //QryTemp.Close;
    //QryTemp.Params.Clear;
    //QryTemp.Params.CreateParam(ftstring,'W',ptInput);
    //QryTemp.CommandText:='INSERT INTO SAJET.G_REEL_NO_VALUE (WORK_ORDER) VALUES (:W)';
    //Qrytemp.Params.ParamByName('W').AsString :=EditWo.Text;
    //QryTemp.Execute;
    //EditWo.Enabled:=False;
    //EditReelno.SetFocus;
    //Editreelno.SelectAll;
    end;

procedure TfMainForm.EditReelnoKeyPress(Sender: TObject; var Key: Char);
begin
 if key <> #13 then exit;

 if EditReelno.Text ='' then exit;


    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'Reel',ptInput);
    QryTemp.CommandText:='Select Reel_no from SAJET.G_HT_MATERIAL Where Reel_no=:Reel oR MATERIAL_NO =:REEL';
    Qrytemp.Params.ParamByName('Reel').AsString :=EditReelno.Text;
    QryTemp.open;
    if  Qrytemp.iSemPTY then
       begin
          Editup.ReadOnly :=true;
          editReelno.ReadOnly :=false;
          editReelno.SetFocus;
          editReelno.SelectAll;
          msgPanel.Caption := 'Reel_NO ERR';
          msgPanel.Color :=clRed;

          Exit;
       end;

     QryTemp.Close;
     QryTemp.Params.Clear;
     QryTemp.Params.CreateParam(ftstring,'MATERIAL',ptInput);
     QryTemp.CommandText:='Select WORK_ORDER from SAJET.G_PICK_LIST Where MATERIAL_NO =:MATERIAL';
     Qrytemp.Params.ParamByName('MATERIAL').AsString :=EditReelno.Text;
     QryTemp.open;
    if  (Qrytemp.iSemPTY) OR (Qrytemp.FieldByName('WORK_ORDER').AsString <> EditWo.Text) then

    begin
          Editup.ReadOnly :=true;
          editReelno.ReadOnly :=false;
          editReelno.SetFocus;
          editReelno.SelectAll;
          msgPanel.Caption := 'WORK_ORDER ERR';
          msgPanel.Color :=clRed;

          Exit;
    end;

      qrytemp.Close;
      qrytemp.Params.Clear;
      qrytemp.Params.CreateParam(ftstring, 'REEL',ptinput);
      qrytemp.CommandText:=('SELECT PART_NO FROM SAJET.SYS_PART A, SAJET.G_PICK_LIST B'+
                            ' WHERE B.MATERIAL_NO=:REEL AND  A.PART_ID=B.PART_ID');
      qrytemp.Params.ParamByName('REEL').AsString := EditReelno.Text;
      qrytemp.Open;

    if qrytemp.IsEmpty then exit;
    if not qrytemp.IsEmpty then
      begin
       PARTNO:= qrytemp.FieldByName('PART_NO').AsString ;
      end;


     qrytemp.Close;
     qrytemp.Params.Clear;
     qrytemp.Params.CreateParam(ftstring, 'PARTSN',ptinput);
     qrytemp.CommandText:=('SElECT UP_LIMIT,L_lIMIT,TEST_UNIT FROM SAJET.G_REEL_NO_VALUE'
                         +' WHERE PART_NO=:PARTSN');
     qrytemp.Params.ParamByName('PARTSN').AsString := PARTNO;
     qrytemp.Open;

  if not qrytemp.IsEmpty then
    begin
     Editup.ReadOnly:= false;
     EditDown.ReadOnly:= false;
     EditReelno.ReadOnly :=true;
     EditReelno.Enabled:= false;
     Combobox1.Style:= csDropDown;
     Editup.Text := qrytemp.fieldbyname('UP_LIMIT').AsString;
     EditDOWN.Text :=qrytemp.fieldbyname('L_LIMIT').AsString;
     Combobox1.Text :=qrytemp.fieldbyname('TEST_UNIT').AsString;
     Combobox2.Text :=qrytemp.fieldbyname('TEST_UNIT').AsString;
     combobox1.Enabled:=false;
     combobox2.Enabled:=false;
     Editup.Enabled:= false;
     EditDown.Enabled:= false;
     Editvalue.ReadOnly:=false;
     editvalue.SetFocus;
     msgPanel.Caption := '赣腹魁砏叫块代刚';
     msgpanel.Color :=clgreen;
    end;

  if qrytemp.IsEmpty then
    begin

       EditUP.ReadOnly :=false;
       editReelno.ReadOnly :=true;
       EditReelno.Enabled:=false;
       editup.SetFocus;
       EditUP.SelectAll;
       editup.Clear;
       msgPanel.Caption := 'REEL_NO OK,Please Input UP_Limit';
       msgPanel.Color :=clGreen;
    end;
end;

procedure TfMainForm.EditUPKeyPress(Sender: TObject; var Key: Char);
begin
  
  if key <> #13 then exit;

  if editup.Text =''then exit;

  if (Editup.Text='P') or (Editup.Text='F') Then
    begin
     Editdown.ReadOnly:=false;
     combobox1.Enabled:=true;
     combobox2.Enabled:=true;
     combobox1.Style:=csDropDown;
     combobox1.Text:='礚';
     combobox2.Text:='礚';
     Editup.text:='琌';
     Editdown.Text:='琌';
     Editup.Enabled:=False;
     Editup.ReadOnly:=true;
     Editdown.Enabled:=False;
     EditDOWN.ReadOnly:=true;
     EditValue.ReadOnly:=False;
     EditValue.SetFocus;
     EditValue.SelectAll;
     msgPanel.Caption:= 'Limit OK,Please TEST Value';
     msgPanel.Color:=Clgreen;
     end
     else
     begin
     Editup.Enabled:=False;
     Editup.ReadOnly:=true;
     EditDOWN.ReadOnly:=False;
     combobox1.SetFocus;
     msgPanel.Caption:= 'UP_Limit OK,Please Input L_limit';
     msgPanel.Color:=Clgreen;
     end;

end;

procedure TfMainForm.EditDOWNKeyPress(Sender: TObject; var Key: Char);
begin
  if key <> #13 then exit;

  if EditDOWN.text='' then exit;

  if  StrTofloat(EditDOWN.Text) > StrTofloat(editUP.Text) then

  begin
     Editup.ReadOnly:=false;
     EditDOWN.SetFocus;
     EditDOWN.SelectAll;
     msgPanel.Caption := 'ERR:  >  ';
     msgPanel.Color :=clred;

     exit;
  end;
     EditDown.Enabled:=False;
     EditDown.ReadOnly:=True;
     EditValue.ReadOnly:=False;
     EditValue.SetFocus;
     EditValue.SelectAll;
     msgPanel.Caption:='L_Limit OK,Please Input Value';
     msgPanel.Color:=clgreen;
 end;


procedure TfMainForm.EditValueKeyPress(Sender: TObject; var Key: Char);
begin
  if key <> #13 then exit;

  if EditValue.text='' then exit;

     EditValue.ReadOnly:=true;
     EditValue.Enabled:=false;
     sbtnsave.Click;
end;

procedure TfMainForm.sbtnSaveClick(Sender: TObject);

begin
   if EditValue.text='P' then
   begin
         editvalue.Text:='';
         msgPanel.Caption:='PASS';
         msgPanel.Color:=clgreen;
   end
   else if Editvalue.text='F' then
   begin
         Editvalue.Text:='ぃ';
         msgPanel.Caption:='Fail';
         msgPanel.Color:=clred;
   end

    else if (StrTofloat(EditValue.Text) > StrTofloat(Editup.Text))
     or (StrTofloat(EditValue.Text) < StrTofloat(Editdown.Text)) then
     begin
         msgPanel.Caption:='Fail';
         msgPanel.Color:=clred;
     end
     else if (StrTofloat(EditValue.Text) <= StrTofloat(Editup.Text))
     and (StrTofloat(EditValue.Text) >= StrTofloat(Editdown.Text))then
     begin
         msgPanel.Caption:='PASS';
         msgPanel.Color:=clgreen;
     end;


//     if (strtoint(EditValue.Text) < strtoint(Editup.Text))
//     and (strtoint(EditValue.Text) > strtoint(Editdown.Text)) then
//    begin
//         msgPanel.Caption:='PASS';
//         msgPanel.Color:=clgreen;
//     end;

     QryTemp.Close;
     QryTemp.Params.Clear;
     QryTemp.Params.CreateParam(ftstring,'WO',ptInput);
     QryTemp.Params.CreateParam(ftstring,'REEL',ptInput);
     QryTemp.Params.CreateParam(ftstring,'UP',ptInput);
     QryTemp.Params.CreateParam(ftstring,'DOWN',ptInput);
     QryTemp.Params.CreateParam(ftstring,'VALUE',ptInput);
     QryTemp.Params.CreateParam(ftstring,'USERID',ptInput);
     QryTemp.Params.CreateParam(ftstring,'Result',ptInput);
     QryTemp.Params.CreateParam(ftstring,'PARTSN',ptInput);
     QryTemp.Params.CreateParam(ftstring,'TESTUNIT',ptInput);
     QryTemp.CommandText:=
     'INSERT INTO SAJET.G_REEL_NO_VALUE (WORK_ORDER,REEL_NO,TEST_VALUE,UPDATE_USERID,'
                         +'UP_LIMIT,L_LIMIT,TEST_UNIT,PART_NO,Result)'
                      +' VALUES (:WO,:REEL,:VALUE,:USERID,:UP,:DOWN,:TESTUNIT,:PARTSN,:Result)';
     Qrytemp.Params.ParamByName('WO').AsString :=EditWo.Text;
     Qrytemp.Params.ParamByName('REEL').AsString :=EditReelno.Text;
     Qrytemp.Params.ParamByName('UP').AsString :=EditUP.Text;
     Qrytemp.Params.ParamByName('DOWN').AsString :=EditDOWN.Text;
     Qrytemp.Params.ParamByName('TESTUNIT').AsString :=Combobox1.Text;
     Qrytemp.Params.ParamByName('VALUE').AsString :=EditValue.Text;
     Qrytemp.Params.ParamByName('USERID').AsString :=UpdateUserID;
     Qrytemp.Params.ParamByName('Result').AsString :=msgPanel.Caption;
     Qrytemp.Params.ParamByName('PARTSN').AsString :=PARTNO;
     QryTemp.Execute;

     EditWo.readonly:=False;
     EditWo.enabled:=True;
     Editwo.Clear;
     combobox1.Enabled:=true;
     combobox2.Enabled:=true;
     Editwo.SetFocus;
     EditReelno.ReadOnly:=True;
     EditReelno.Enabled:=True;
     EditReelno.clear;
     EditUP.ReadOnly:=True;
     EditUP.Enabled:=True;
     EditUP.clear;
     EditDOWN.ReadOnly:=True;
     EditDOWN.Enabled:=True;
     EditDOWN.clear;
     EditValue.ReadOnly:=True;
     EditValue.Enabled:=True;
     EditValue.clear;
end;

procedure TfMainForm.fromshow(Sender: TObject);
begin
  Editwo.SetFocus;
end;

procedure TfMainForm.ComboBox1Change(Sender: TObject);
begin
   Combobox2.Text:=Combobox1.Text;
   Combobox1.Enabled:=false;
   combobox2.Enabled:=false;
   Editdown.SetFocus;
   Editdown.SelectAll;
end;


end.




 // if (EditValue.Text > Editup.Text) or (EditValue.Text < EditDOWN.Text) then
 // begin
  //   EditValue.ReadOnly:=true;
  //   msgPanel.Caption :='FAIL';
  //   msgPanel.Color :=clred;
 // end;






