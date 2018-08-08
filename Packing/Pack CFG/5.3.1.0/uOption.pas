unit uOption;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ComCtrls, StdCtrls, Buttons, ExtCtrls, DB;

type
  TfOption = class(TForm)
    ImageList1: TImageList;
    Image1: TImage;
    sbtnSave: TSpeedButton;
    Image5: TImage;
    Label2: TLabel;
    cnkCSN: TCheckBox;
    Bevel1: TBevel;
    Label7: TLabel;
    cnkCSNLabel: TCheckBox;
    Label13: TLabel;
    Label14: TLabel;
    Label11: TLabel;
    cnkCarton: TCheckBox;
    Label12: TLabel;
    cnkCartonLabel: TCheckBox;
    Label17: TLabel;
    Label18: TLabel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Label1: TLabel;
    cnkPallet: TCheckBox;
    Label5: TLabel;
    cnkPalletLabel: TCheckBox;
    Label6: TLabel;
    Label8: TLabel;
    Label21: TLabel;
    cmbVersion: TComboBox;
    Label22: TLabel;
    cmbPkBase: TComboBox;
    cmbCSNPntMethod: TComboBox;
    cmbCartonPntMethod: TComboBox;
    cmbPalletPntMethod: TComboBox;
    Label9: TLabel;
    editPalletLabQty: TEdit;
    editCartonLabQty: TEdit;
    Label10: TLabel;
    editCSNLabQty: TEdit;
    Label15: TLabel;
    cnkCSN1: TCheckBox;
    Label16: TLabel;
    Label19: TLabel;
    cmbPalletPort: TComboBox;
    Label20: TLabel;
    cmbCSNPort: TComboBox;
    Label23: TLabel;
    cmbCartonPort: TComboBox;
    cmbPkAction: TComboBox;
    Label27: TLabel;
    Bevel4: TBevel;
    chkWeight: TCheckBox;
    Label3: TLabel;
    edtDll: TEdit;
    chkCheckCSN: TCheckBox;
    Label4: TLabel;
    Bevel5: TBevel;
    Label29: TLabel;
    cnkBox: TCheckBox;
    Label30: TLabel;
    cnkBoxLabel: TCheckBox;
    Label31: TLabel;
    Label32: TLabel;
    editBoxLabQty: TEdit;
    cmbBoxPort: TComboBox;
    Label34: TLabel;
    cmbBoxPntMethod: TComboBox;
    Label35: TLabel;
    chkCheckBox: TCheckBox;
    Label36: TLabel;
    chkCapsLock: TCheckBox;
    Label28: TLabel;
    Label37: TLabel;
    cmbRule: TComboBox;
    chkAdditional: TCheckBox;
    Label24: TLabel;
    chkbInputEC: TCheckBox;
    Label25: TLabel;
    EdtAdditionaldll: TEdit;
    Label26: TLabel;
    cnkChkBoxLabel: TCheckBox;
    cnkInputKeyParts: TCheckBox;
    Label33: TLabel;
    cnkBoxFull: TCheckBox;
    Label38: TLabel;
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cnkCSNClick(Sender: TObject);
    procedure cnkCSN1Click(Sender: TObject);
    procedure cmbCSNPntMethodChange(Sender: TObject);
    procedure cmbCartonPntMethodChange(Sender: TObject);
    procedure cmbPalletPntMethodChange(Sender: TObject);
    procedure cmbBoxPntMethodChange(Sender: TObject);
    procedure cnkBoxClick(Sender: TObject);
    procedure chkCheckCSNClick(Sender: TObject);
    procedure chkCheckBoxClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    slPackAction: TStringList;
    function SaveCfgData: Boolean;
    procedure ShowOption;
  end;

var
  fOption: TfOption;

implementation

{$R *.DFM}

uses uData;

procedure TfOption.ShowOption;
var S: string;
begin
  cnkCSN.Checked := False;
  cnkCSN1.Checked := False;
  chkCheckCSN.Checked := False;
  cnkCSNLabel.Checked := False;
  cmbCSNPntMethod.ItemIndex := 0;
  editCSNLabQty.Text := '1';
  cmbCSNPort.ItemIndex := 0;
  cnkInputKeyParts.Checked := False;

  cnkBox.Checked := False;
  chkCheckBox.Checked := False;
  cnkBoxLabel.Checked := False;
  cmbBoxPntMethod.ItemIndex := 0;
  editBoxLabQty.Text := '1';
  cmbBoxPort.ItemIndex := 0;

  cnkCarton.Checked := False;
  cnkCartonLabel.Checked := False;
  cmbCartonPntMethod.ItemIndex := 0;
  editCartonLabQty.Text := '1';
  cmbCartonPort.ItemIndex := 0;

  cnkPallet.Checked := False;
  cnkPalletLabel.Checked := False;
  cmbPalletPntMethod.ItemIndex := 0;
  editPalletLabQty.Text := '1';
  cmbPalletPort.ItemIndex := 0;

  cmbPkBase.ItemIndex := 0;
  cmbVersion.ItemIndex := 2;
  cmbPkAction.ItemIndex := 0;
  cmbRule.ItemIndex := 0;
  ChkAdditional.Checked:= False;
  ChkbInputEC.Checked := False;

  with fData.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base where param_name = ''Packing Action''';
    Open;
    cmbPkAction.Items.Clear;
    slPackAction.Clear;
    S := FieldByName('param_value').AsString;
    while Pos(',', S) <> 0 do begin
      cmbPkAction.Items.Add(Copy(S, 2, Pos(',', S) - 2));
      slPackAction.Add(Copy(S, 1, 1));
      S := Copy(S, Pos(',', S) + 1, Length(S));
    end;
    cmbPkAction.Items.Add(Copy(S, 2, Length(S)));
    slPackAction.Add(Copy(S, 1, 1));
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'SELECT * ' +
      'FROM SAJET.SYS_MODULE_PARAM ' +
      'WHERE MODULE_NAME = :MODULE_NAME AND ' +
      'FUNCTION_NAME = :FUNCTION_NAME AND ' +
      'PARAME_NAME = :TERMINALID ';
    Params.ParamByName('MODULE_NAME').AsString := 'PACKING';
    Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
    Params.ParamByName('TERMINALID').AsString := fData.TerminalID;
    Open;
    while not Eof do
    begin
        //Customer SN
      if Fieldbyname('PARAME_ITEM').AsString = 'Customer SN' then
        cnkCSN.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'System Create');
      if Fieldbyname('PARAME_ITEM').AsString = 'Customer SN' then
        cnkCSN1.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Not Change CSN');
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Customer SN Label' then
        cnkCSNLabel.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Customer SN Label Method' then
        cmbCSNPntMethod.ItemIndex := cmbCSNPntMethod.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Customer SN Label Qty' then
        editCSNLabQty.Text := Fieldbyname('PARAME_VALUE').AsString;
      if Fieldbyname('PARAME_ITEM').AsString = 'Customer SN COM Port' then
        cmbCSNPort.ItemIndex := cmbCSNPort.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'Check CSN=SN' then
        chkCheckCSN.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Input KeyParts' then
        cnkInputKeyParts.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');

        //Box
      if Fieldbyname('PARAME_ITEM').AsString = 'Box No' then
        cnkBox.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'System Create');
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Box No Label' then
        cnkBoxLabel.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Box No Label Method' then
        cmbBoxPntMethod.ItemIndex := cmbCSNPntMethod.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Box No Label Qty' then
        editBoxLabQty.Text := Fieldbyname('PARAME_VALUE').AsString;
      if Fieldbyname('PARAME_ITEM').AsString = 'Box No COM Port' then
        cmbBoxPort.ItemIndex := cmbCSNPort.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'Check Box=SN' then
        chkCheckBox.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Check Box Label' then
        cnkChkBoxLabel.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Check Box Full' then
        cnkBoxFull.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');

        //Carton
      if Fieldbyname('PARAME_ITEM').AsString = 'Carton No' then
        cnkCarton.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'System Create');
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Carton No Label' then
        cnkCartonLabel.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Carton No Label Method' then
        cmbCartonPntMethod.ItemIndex := cmbCartonPntMethod.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Carton No Label Qty' then
        editCartonLabQty.Text := Fieldbyname('PARAME_VALUE').AsString;
      if Fieldbyname('PARAME_ITEM').AsString = 'Carton No COM Port' then
        cmbCartonPort.ItemIndex := cmbCartonPort.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);

        //Pallet
      if Fieldbyname('PARAME_ITEM').AsString = 'Pallet No' then
        cnkPallet.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'System Create');
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Pallet No Label' then
        cnkPalletLabel.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Pallet No Label Method' then
        cmbPalletPntMethod.ItemIndex := cmbPalletPntMethod.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'Print Pallet No Label Qty' then
        editPalletLabQty.Text := Fieldbyname('PARAME_VALUE').AsString;
      if Fieldbyname('PARAME_ITEM').AsString = 'Pallet No COM Port' then
        cmbPalletPort.ItemIndex := cmbPalletPort.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);

      if Fieldbyname('PARAME_ITEM').AsString = 'Packing Base' then
        cmbPkBase.ItemIndex := cmbPkBase.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'CodeSoft' then
        cmbVersion.ItemIndex := cmbVersion.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      if Fieldbyname('PARAME_ITEM').AsString = 'Packing Action' then begin
        cmbPkAction.ItemIndex := slPackAction.IndexOf(Fieldbyname('PARAME_VALUE').AsString);
        if cmbPkAction.ItemIndex = -1 then
           cmbPkAction.ItemIndex := cmbPkAction.Items.Indexof(Fieldbyname('PARAME_VALUE').AsString);
      end;     
        //秤重
      if Fieldbyname('PARAME_ITEM').AsString = 'Check Weight' then
        chkWeight.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Weight Dll' then
        edtDll.Text := Fieldbyname('PARAME_VALUE').AsString;
      if Fieldbyname('PARAME_ITEM').AsString = 'Caps Lock' then
        chkCapsLock.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Check Rule by Function' then
        cmbRule.ItemIndex := cmbRule.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString);
      //附件
      if Fieldbyname('PARAME_ITEM').AsString = 'Additional Data' then
        chkAdditional.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      if Fieldbyname('PARAME_ITEM').AsString = 'Additional DLL' then
        edtAdditionaldll.Text := Fieldbyname('PARAME_VALUE').AsString;

      if Fieldbyname('PARAME_ITEM').AsString = 'Input Error Code' then
        chkbInputEC.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
      Next;
    end;
    Close;
  end;
  if cmbPkAction.ItemIndex = -1 then
    cmbPkAction.ItemIndex := 0;
  cmbCSNPntMethod.OnChange(self);
  cmbBoxPntMethod.OnChange(self);
  cmbCartonPntMethod.OnChange(self);
  cmbPalletPntMethod.OnChange(self);
end;


function TfOption.SaveCfgData: Boolean;
var S: string;
  procedure SavetoDB(ParamName, ParamItem, ParamValue: string);
  begin
    with fData.QryTemp do
    begin
      Params.ParamByName('MODULE_NAME').AsString := 'PACKING';
      Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
      Params.ParamByName('PARAME_NAME').AsString := ParamName;
      Params.ParamByName('PARAME_ITEM').AsString := ParamItem;
      Params.ParamByName('PARAME_VALUE').AsString := ParamValue;
      Params.ParamByName('UPDATE_USERID').AsString := fData.UpdateUserID;
      Execute;
    end;
  end;
begin
  with fData.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'Delete SAJET.SYS_MODULE_PARAM ' +
      'Where MODULE_NAME = :MODULE_NAME and ' +
      'FUNCTION_NAME = :FUNCTION_NAME  and ' +
      'PARAME_NAME = :TERMINALID ';
    Params.ParamByName('MODULE_NAME').AsString := 'PACKING';
    Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
    Params.ParamByName('TERMINALID').AsString := fData.TerminalID;
    Execute;
  end;

  with fData.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'PARAME_NAME', ptInput);
    Params.CreateParam(ftString, 'PARAME_ITEM', ptInput);
    Params.CreateParam(ftString, 'PARAME_VALUE', ptInput);
    Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
    CommandText := 'Insert Into SAJET.SYS_MODULE_PARAM ' +
      '(MODULE_NAME,FUNCTION_NAME,PARAME_NAME,PARAME_ITEM,PARAME_VALUE,UPDATE_USERID )' +
      'Values (:MODULE_NAME,:FUNCTION_NAME,:PARAME_NAME,:PARAME_ITEM,:PARAME_VALUE,:UPDATE_USERID) ';
  end;

  //Customer SN
  S := 'Input';
  if cnkCSN.Checked then
    S := 'System Create'
  else if chkCheckCSN.Checked then
    SavetoDB(fData.TerminalID, 'Check CSN=SN', 'Y')
  else
    SavetoDB(fData.TerminalID, 'Check CSN=SN', 'N');
  if cnkCSN1.Checked then S := 'Not Change CSN';
  SavetoDB(fData.TerminalID, 'Customer SN', S);

  if cnkInputKeyParts.Checked then
     SavetoDB(fData.TerminalID, 'Input KeyParts' , 'Y')
  else
     SavetoDB(fData.TerminalID, 'Input KeyParts' , 'N');

  S := 'Y';
  if not cnkCSNLabel.Checked then S := 'N';
  SavetoDB(fData.TerminalID, 'Print Customer SN Label', S);
  if cmbRule.ItemIndex > 0 then
    SavetoDB(fData.TerminalID, 'Check Rule by Function', cmbRule.Text);
  SavetoDB(fData.TerminalID, 'Print Customer SN Label Method', cmbCSNPntMethod.Text);
  SavetoDB(fData.TerminalID, 'Print Customer SN Label Qty', editCSNLabQty.Text);
  SavetoDB(fData.TerminalID, 'Customer SN COM Port', cmbCSNPort.Text);

  //Box
  S := 'Input';
  if cnkBox.Checked then
    S := 'System Create'
  else if chkCheckBox.Checked then
    SavetoDB(fData.TerminalID, 'Check Box=SN', 'Y')
  else
    SavetoDB(fData.TerminalID, 'Check Box=SN', 'N');
  SavetoDB(fData.TerminalID, 'Box No', S);

  S := 'Y';
  if not cnkBoxLabel.Checked then S := 'N';
  SavetoDB(fData.TerminalID, 'Print Box No Label', S);
  SavetoDB(fData.TerminalID, 'Print Box No Label Method', cmbBoxPntMethod.Text);
  SavetoDB(fData.TerminalID, 'Print Box No Label Qty', editBoxLabQty.Text);
  SavetoDB(fData.TerminalID, 'Box No COM Port', cmbBoxPort.Text);
  if chkCapsLock.Checked then
    SavetoDB(fData.TerminalID, 'Caps Lock', 'Y')
  else
    SavetoDB(fData.TerminalID, 'Caps Lock', 'N');

  if  cnkChkBoxLabel.Checked then
   SavetoDB(fData.TerminalID, 'Check Box Label', 'Y')
  else
   SavetoDB(fData.TerminalID, 'Check Box Label', 'N');
  if  cnkBoxFull.Checked then
   SavetoDB(fData.TerminalID, 'Check Box Full', 'Y')
  else
   SavetoDB(fData.TerminalID, 'Check Box Full', 'N');

  //Carton
  S := 'System Create';
  if not cnkCarton.Checked then S := 'Input';
  SavetoDB(fData.TerminalID, 'Carton No', S);

  S := 'Y';
  if not cnkCartonLabel.Checked then S := 'N';
  SavetoDB(fData.TerminalID, 'Print Carton No Label', S);
  SavetoDB(fData.TerminalID, 'Print Carton No Label Method', cmbCartonPntMethod.Text);
  SavetoDB(fData.TerminalID, 'Print Carton No Label Qty', editCartonLabQty.Text);
  SavetoDB(fData.TerminalID, 'Carton No COM Port', cmbCartonPort.Text);

  //Pallet
  S := 'System Create';
  if not cnkPallet.Checked then S := 'Input';
  SavetoDB(fData.TerminalID, 'Pallet No', S);

  S := 'Y';
  if not cnkPalletLabel.Checked then S := 'N';
  SavetoDB(fData.TerminalID, 'Print Pallet No Label', S);
  SavetoDB(fData.TerminalID, 'Print Pallet No Label Method', cmbPalletPntMethod.Text);
  SavetoDB(fData.TerminalID, 'Print Pallet No Label Qty', editPalletLabQty.Text);
  SavetoDB(fData.TerminalID, 'Pallet No COM Port', cmbPalletPort.Text);

  SavetoDB(fData.TerminalID, 'Packing Base', cmbPkBase.Text);
  SavetoDB(fData.TerminalID, 'CodeSoft', cmbVersion.Text);
  SavetoDB(fData.TerminalID, 'Packing Action', slPackAction[cmbPkAction.ItemIndex]);
  //秤重
  S := 'Y';
  if not chkWeight.Checked then S := 'N';
  SavetoDB(fData.TerminalID, 'Check Weight', S);
  SavetoDB(fData.TerminalID, 'Weight Dll', edtDll.Text);

  //附件
  S := 'Y';
  if not chkAdditional.Checked then S := 'N';
  SavetoDB(fData.TerminalID, 'Additional Data', S);
  SavetoDB(fData.TerminalID, 'Additional DLL', edtAdditionaldll.Text);
  //是否可輸入不良代碼
  if chkbInputEC.Checked then
     SavetoDB(fData.TerminalID, 'Input Error Code', 'Y')
  else
     SavetoDB(fData.TerminalID, 'Input Error Code', 'N');

  Result := True;
end;

procedure TfOption.sbtnSaveClick(Sender: TObject);
begin
  if fData.TerminalID = '' then begin
    MessageDlg('Terminal not be assign.', mtError, [mbOK], 0);
    Exit;
  end;
  if SaveCfgData then
    MessageDlg('Save OK!', mtInformation, [mbOK], 0);
//  if not SaveCfgData then Exit;
//  Close;
end;

procedure TfOption.FormShow(Sender: TObject);
var slPort: TStringList;
begin
  slPackAction := TStringList.Create;
  with fData.QryTemp do begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'object_name', ptInput);
    CommandText := 'select owner || ''.'' || object_name object_name from ALL_OBJECTS '
      + 'where object_type = ''FUNCTION'' '
      + 'and substr(object_name, 1, 3) = :object_name ';
    Params.ParamByName('object_name').AsString := Uppercase('PK_');
    Open;
    cmbRule.Items.Clear;
    cmbRule.Items.Add('');
    while not Eof do
    begin
      cmbRule.Items.Add(FieldByName('object_name').AsString);
      Next;
    end;
    Close;
    Params.Clear;
    CommandText := 'select sql_value from sajet.sys_sql '
      + 'where sql_name = ''Packing Print Port'' and rownum = 1';
    Open;
    cmbCSNPort.Items.Clear;
    slPort := TStringList.Create;
    slPort.CommaText := FieldByName('sql_value').AsString;
    cmbCSNPort.Items.AddStrings(slPort);
    slPort.Free;
    cmbBoxPort.Items := cmbCSNPort.Items;
    cmbCartonPort.Items := cmbCSNPort.Items;
    cmbPalletPort.Items := cmbCSNPort.Items;
    Close;
  end;
  ShowOption;
end;

procedure TfOption.cnkCSNClick(Sender: TObject);
begin
  if cnkCSN.Checked then
  begin
    cnkCSN1.Checked := False;
    chkCheckCSN.Checked := False;
  end;
end;

procedure TfOption.cnkCSN1Click(Sender: TObject);
begin
  if cnkCSN1.Checked then
  begin
    cnkCSN.Checked := False;
    chkCheckCSN.Checked := False;
  end;
end;

procedure TfOption.cmbCSNPntMethodChange(Sender: TObject);
begin
  if cmbCSNPntMethod.ItemIndex = 0 then
  begin
    Label20.Visible := False;
    cmbCSNPort.Visible := False;
  end
  else
  begin
    Label20.Visible := True;
    cmbCSNPort.Visible := True;
  end;
end;

procedure TfOption.cmbCartonPntMethodChange(Sender: TObject);
begin
  if cmbCartonPntMethod.ItemIndex = 0 then
  begin
    Label23.Visible := False;
    cmbCartonPort.Visible := False;
  end
  else
  begin
    Label23.Visible := True;
    cmbCartonPort.Visible := True;
  end;
end;

procedure TfOption.cmbPalletPntMethodChange(Sender: TObject);
begin
  if cmbPalletPntMethod.ItemIndex = 0 then
  begin
    Label19.Visible := False;
    cmbPalletPort.Visible := False;
  end
  else
  begin
    Label19.Visible := True;
    cmbPalletPort.Visible := True;
  end;
end;

procedure TfOption.cmbBoxPntMethodChange(Sender: TObject);
begin
  if cmbBoxPntMethod.ItemIndex = 0 then
  begin
    Label34.Visible := False;
    cmbBoxPort.Visible := False;
  end
  else
  begin
    Label34.Visible := True;
    cmbBoxPort.Visible := True;
  end;
end;

procedure TfOption.cnkBoxClick(Sender: TObject);
begin
  if cnkBox.Checked then
    chkCheckBox.Checked := False;
end;

procedure TfOption.chkCheckCSNClick(Sender: TObject);
begin
  if chkCheckCSN.Checked then
  begin
    cnkCSN.Checked := False;
    cnkCSN1.Checked := False;
  end;
end;

procedure TfOption.chkCheckBoxClick(Sender: TObject);
begin
  if chkCheckBox.Checked then
    cnkBox.Checked := False;
end;

procedure TfOption.FormDestroy(Sender: TObject);
begin
  slPackAction.Free;
end;

end.

