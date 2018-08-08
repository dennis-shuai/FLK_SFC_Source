unit uOption;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ComCtrls, StdCtrls, Buttons, ExtCtrls, DB;

type
  TfOption = class(TForm)
    ImageList1: TImageList;
    Image1: TImage;
    Image5: TImage;
    Image2: TImage;
    sbtnSave: TSpeedButton;
    sbtnClose: TSpeedButton;
    Bevel1: TBevel;
    chkbRejectClear: TCheckBox;
    Label10: TLabel;
    Bevel2: TBevel;
    Label7: TLabel;
    chkbClearOption: TCheckBox;
    chkbChkPart: TCheckBox;
    Bevel3: TBevel;
    Label1: TLabel;
    sbtnProcess: TSpeedButton;
    ListProcess: TListBox;
    chkbLotClear: TCheckBox;
    Label2: TLabel;
    bvl1: TBevel;
    bvl2: TBevel;
    Label3: TLabel;
    cmbQcBase: TComboBox;
    cmbInputType: TComboBox;
    Label4: TLabel;
    procedure sbtnCloseClick(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnProcessClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Function SaveCfgData : Boolean;
    Function ShowOption : Boolean;
  end;

var
  fOption: TfOption;

implementation

{$R *.DFM}
Uses uData,uSelect;

procedure TfOption.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

Function TfOption.ShowOption : Boolean;
Var S : string;
begin
  chkbClearOption.Checked := False;
  chkbRejectClear.Checked := False;
  chkbChkPart.Checked := False;
  cmbQcBase.Style := csDropDownList;
  cmbInputType.Style := csDropDownList;
  ListProcess.Clear;
  With fData.QryTemp do
  begin
    try
       Close;
       Params.Clear;
       Params.CreateParam(ftString	,'MODULE_NAME', ptInput);
       Params.CreateParam(ftString	,'FUNCTION_NAME', ptInput);
       Params.CreateParam(ftString	,'TERMINALID', ptInput);
       CommandText := 'SELECT * '
                    + 'FROM SAJET.SYS_MODULE_PARAM '
                    + 'WHERE MODULE_NAME = :MODULE_NAME '
                    + 'AND FUNCTION_NAME = :FUNCTION_NAME '
                    + 'AND PARAME_NAME = :TERMINALID ';
       Params.ParamByName('MODULE_NAME').AsString := 'Quality Control';
       Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
       Params.ParamByName('TERMINALID').AsString := fData.TerminalID;
       Open;
       While not Eof do
       begin
          If Fieldbyname('PARAME_ITEM').AsString = 'Clear QC Data' Then
             chkbClearOption.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
          If Fieldbyname('PARAME_ITEM').AsString = 'Clear QC Data After Reject' Then
             chkbRejectClear.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
          If Fieldbyname('PARAME_ITEM').AsString = 'Clear QC Data Only LOT NO' Then
             chkbLotClear.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
          If Fieldbyname('PARAME_ITEM').AsString = 'QC Base' Then
             cmbQCBase.ItemIndex := cmbQCBase.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString  );
          If Fieldbyname('PARAME_ITEM').AsString = 'Input Type' Then
             cmbInputType.ItemIndex := cmbInputType.Items.IndexOf(Fieldbyname('PARAME_VALUE').AsString );
          //檢查附件
          If Fieldbyname('PARAME_ITEM').AsString = 'Check Part' Then
             chkbChkPart.Checked := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
          //需要檢查此Process的附件
          If Fieldbyname('PARAME_ITEM').AsString = 'Check Process' Then
          begin
             with fData.QryData do
             begin
               Close;
               Params.Clear;
               Params.CreateParam(ftString	,'PROCESSID', ptInput);
               CommandText := 'SELECT PROCESS_NAME FROM SAJET.SYS_PROCESS '
                            + 'WHERE PROCESS_ID = :PROCESSID ';
               Params.ParamByName('PROCESSID').AsString := fData.QryTemp.Fieldbyname('PARAME_VALUE').AsString;
               Open;
               ListProcess.Items.Add(Fieldbyname('PROCESS_NAME').AsString);
               Close;
             end;
          end;
          Next;
       end;
     finally
       Close;
     end;
  end;
end;


Function TfOption.SaveCfgData : Boolean;
Var S : String;
    i:Integer;
  procedure SavetoDB(ParamName,ParamItem,ParamValue : String);
  begin
     With fData.QryTemp do
     begin
        Params.ParamByName('MODULE_NAME').AsString := 'Quality Control';
        Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
        Params.ParamByName('PARAME_NAME').AsString := ParamName;
        Params.ParamByName('PARAME_ITEM').AsString := ParamItem;
        Params.ParamByName('PARAME_VALUE').AsString := ParamValue;
        Params.ParamByName('UPDATE_USERID').AsString := fData.UpdateUserID;
        Execute;
     end;
  end;
begin
  result := False;
  With fData.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'MODULE_NAME', ptInput);
    Params.CreateParam(ftString	,'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString	,'TERMINALID', ptInput);
    CommandText := 'Delete SAJET.SYS_MODULE_PARAM '+
                   'Where MODULE_NAME = :MODULE_NAME and '+
                         'FUNCTION_NAME = :FUNCTION_NAME  and '+
                         'PARAME_NAME = :TERMINALID ';
    Params.ParamByName('MODULE_NAME').AsString := 'Quality Control';
    Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
    Params.ParamByName('TERMINALID').AsString := fData.TerminalID;
    Execute;
  end;

  With fData.QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'MODULE_NAME', ptInput);
     Params.CreateParam(ftString	,'FUNCTION_NAME', ptInput);
     Params.CreateParam(ftString	,'PARAME_NAME', ptInput);
     Params.CreateParam(ftString	,'PARAME_ITEM', ptInput);
     Params.CreateParam(ftString	,'PARAME_VALUE', ptInput);
     Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
     CommandText := 'Insert Into SAJET.SYS_MODULE_PARAM '+
                    '(MODULE_NAME,FUNCTION_NAME,PARAME_NAME,PARAME_ITEM,PARAME_VALUE,UPDATE_USERID )'+
                    'Values '+
                    '(:MODULE_NAME,:FUNCTION_NAME,:PARAME_NAME,:PARAME_ITEM,:PARAME_VALUE,:UPDATE_USERID) ';
  end;
  S :='N';
  if chkbClearOption.Checked then
    S :='Y';
  SavetoDB(fData.TerminalID,'Clear QC Data',S);

  S :='N';
  if chkbRejectClear.Checked then
    S :='Y';
  SavetoDB(fData.TerminalID,'Clear QC Data After Reject',S);

  S :='N';
  if chkbChkPart.Checked then
    S :='Y';
  SavetoDB(fData.TerminalID,'Check Part',S);

   S :='N';
  if chkbLotClear.Checked then
    S :='Y';
  SavetoDB(fData.TerminalID,'Clear QC Data Only LOT NO',S);

  //---20180130 dennis shuai--------
  SavetoDB(fData.TerminalID,'QC Base',cmbQCBase.Text);
  SavetoDB(fData.TerminalID,'Input Type',cmbInputType.Text);



  for i:= 0 to listProcess.Items.Count-1 do
  begin
    With fData.QryData do
    begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString	,'Process_Name', ptInput);
       CommandText := 'Select Process_ID from sajet.sys_process '
                    + 'Where Process_Name = :Process_Name ';
       Params.ParamByName('Process_Name').AsString:=listProcess.Items.Strings[i];
       open;
       S:= FieldByName('Process_ID').AsString;
       close;
    end; 
    SavetoDB(fData.TerminalID,'Check Process',S);
  end;
  
  result := true;
end;

procedure TfOption.sbtnSaveClick(Sender: TObject);
begin
  if (chkbChkPart.Checked) and (listProcess.Items.Count=0) then
  begin
    MessageDlg('Process Error',mtError,[mbOK],0);
    exit;
  end;

  If not SaveCfgData Then Exit;
  Close;
end;

procedure TfOption.FormShow(Sender: TObject);
begin
  ShowOption;
end;

procedure TfOption.sbtnProcessClick(Sender: TObject);
Var I,iIndex : Integer;
begin
  With fData.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select PROCESS_ID,PROCESS_NAME '+
                   'From SAJET.SYS_PROCESS '+
                   'Where Enabled = ''Y'' '+
                   'Order By PROCESS_NAME ';
    Open;
  end;

  with TfSelect.create(Self) do
  begin
    try
      listbAvail.Clear;
      listbSel.Clear;
      lablTitle.Caption := 'All Process List ';
      if ListProcess.Items.Count <> 0 then
      begin
        for I := 0 to ListProcess.Items.Count - 1 do
        begin
           if listbSel.Items.IndexOf(ListProcess.Items[i])<0 Then
             listbSel.Items.AddObject(ListProcess.Items[I],ListProcess.Items.Objects[I]);
        end;
      end;

      While not fData.qryTemp.Eof do
      begin
        if listbSel.Items.Indexof(fData.qryTemp.FieldByName('PROCESS_NAME').AsString)=-1 then
          listbAvail.Items.Add(fData.qryTemp.FieldByName('PROCESS_NAME').AsString);
        fData.qryTemp.Next;
      end;
      if ShowModal = mrOK then
      begin
        ListProcess.Clear;
        if listbSel.Items.Count <> 0 then
        begin
          for I := 0 to listbSel.Items.Count - 1 do
          begin
            if ListProcess.Items.IndexOf(listbSel.Items[i])<0 Then
            begin
                ListProcess.Items.AddObject(listbSel.Items[I],listbSel.Items.Objects[I]);
            end;
          end;
        end;
      end;
    finally
      fData.qryTemp.Close;
      free;
    end;
  end;
end;

end.
