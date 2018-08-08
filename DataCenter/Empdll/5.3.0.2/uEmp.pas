unit uEmp;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, uData, Db, DBClient,
   MConnect, SConnect, FileCtrl, ObjBrkr, Menus, uRole;

type
   TfEmp = class(TForm)
      Panel1: TPanel;
      ImageAll: TImage;
      Image2: TImage;
      Image3: TImage;
      ImgDelete: TImage;
    LabTitle2: TLabel;
      Label11: TLabel;
      Image7: TImage;
      Image8: TImage;
      sbtnAppend: TSpeedButton;
      sbtnModify: TSpeedButton;
      sbtnDelete: TSpeedButton;
      sbtnExport: TSpeedButton;
      sbtnDisabled: TSpeedButton;
      DBGrid1: TDBGrid;
    LabTitle1: TLabel;
      QryData: TClientDataSet;
      DataSource1: TDataSource;
      QryTemp: TClientDataSet;
      Label4: TLabel;
      cmbShow: TComboBox;
      SaveDialog1: TSaveDialog;
      PopupMenu1: TPopupMenu;
      Append1: TMenuItem;
      Modify1: TMenuItem;
      Disabled1: TMenuItem;
      Export1: TMenuItem;
      Delete1: TMenuItem;
      ModifyLog1: TMenuItem;
      sbtnRole: TSpeedButton;
      Image1: TImage;
      Image4: TImage;
      cmbFactory: TComboBox;
      LabDesc: TLabel;
      N1: TMenuItem;
      ResetPassword1: TMenuItem;
      cmbDept: TComboBox;
      Label1: TLabel;
      editSearch: TEdit;
      Label2: TLabel;
      cmbType: TComboBox;
    Image6: TImage;
    sbtnImport: TSpeedButton;
    Label5: TLabel;
    dlgFileImport: TOpenDialog;
    Sproc: TClientDataSet;
      procedure sbtnAppendClick(Sender: TObject);
      procedure sbtnModifyClick(Sender: TObject);
      procedure DBGrid1TitleClick(Column: TColumn);
      procedure FormShow(Sender: TObject);
      procedure sbtnDeleteClick(Sender: TObject);
      procedure sbtnDisabledClick(Sender: TObject);
      procedure cmbShowChange(Sender: TObject);
      procedure sbtnExportClick(Sender: TObject);
      procedure ModifyLog1Click(Sender: TObject);
      procedure sbtnRoleClick(Sender: TObject);
      procedure cmbFactoryChange(Sender: TObject);
      procedure ResetPassword1Click(Sender: TObject);
      procedure cmbTypeChange(Sender: TObject);
      procedure editSearchChange(Sender: TObject);
    procedure sbtnImportClick(Sender: TObject);
   private
    { Private declarations }
   public
    { Public declarations }
      OrderIdx: string;
      UpdateUserID: string;
      UserFcID: string; // User 本身的廠別，若為 0 可選所有廠別
      FcID, gsDefaultPasswd: string; // User 所選的廠別
      Authoritys, AuthorityRole: string;
      procedure showData;
      procedure CopyToHistory(RecordID: string);
      procedure SetStatusbyAuthority;
   end;

var
   fEmp: TfEmp;

implementation

{$R *.DFM}
uses uHistory;

procedure TfEmp.SetStatusbyAuthority;
var iPrivilege:integer;
begin
  // Read Only,Allow To Change,Full Control
  iPrivilege:=0;
  with sproc do
  begin
    try
       Close;
       DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
       FetchParams;
       Params.ParamByName('EMPID').AsString := UpdateUserID;
       Params.ParamByName('PRG').AsString := 'Data Center';
       Params.ParamByName('FUN').AsString :='Employee Define';
       Execute;
       IF Params.ParamByName('TRES').AsString ='OK' Then
       begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
       end;
    finally
      close;
    end;
  end;
  sbtnAppend.Enabled := (iPrivilege >=1);
  Append1.Enabled := sbtnAppend.Enabled ;

  sbtnModify.Enabled := (iPrivilege >=1);
  Modify1.Enabled := sbtnModify.Enabled;

  sbtnDisabled.Enabled := (iPrivilege >=1);
  Disabled1.Enabled := sbtnDisabled.Enabled;

  sbtnDelete.Enabled := (iPrivilege >=2);
  Delete1.Enabled := sbtnDelete.Enabled;

  ResetPassword1.Enabled := (iPrivilege >=2);
  sbtnImport.Enabled :=sbtnAppend.Enabled;//add by rita 2005/12/16


  iPrivilege:=0;
  with sproc do
  begin
    try
       Close;
       DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
       FetchParams;
       Params.ParamByName('EMPID').AsString := UpdateUserID;
       Params.ParamByName('PRG').AsString := 'Data Center';
       Params.ParamByName('FUN').AsString :='Role Assign';
       Execute;
       IF Params.ParamByName('TRES').AsString ='OK' Then
       begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
       end;
    finally
      close;
    end;
  end;
  sbtnRole.Enabled := (iPrivilege >=2);
end;

procedure TfEmp.CopyToHistory(RecordID: string);
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMPID', ptInput);
      CommandText := 'Insert Into SAJET.SYS_HT_EMP ' +
         'Select * from SAJET.SYS_EMP ' +
         'Where EMP_ID = :EMPID ';
      Params.ParamByName('EMPID').AsString := RecordID;
      Execute;
   end;
end;

procedure TfEmp.ShowData;
begin
   if cmbShow.ItemIndex <= 0 then
      cmbShow.ItemIndex := 0;
   with QryData do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'FCID', ptInput);
      if cmbDept.Text <> 'ALL' then
         Params.CreateParam(ftString, 'DEPT_NAME', ptInput);

      CommandText := 'Select EMP_ID,EMP_NO,EMP_NAME,SHIFT_CODE,DEPT_NAME,QUIT_DATE,A.ENABLED ' +
            'From SAJET.SYS_EMP A,' +
            'SAJET.SYS_DEPT B, ' +
            'SAJET.SYS_SHIFT C '+
            'Where A.FACTORY_ID = :FCID  ' +
            ' and A.DEPT_ID = B.DEPT_ID(+) ' +
            'and A.SHIFT = C.SHIFT_ID(+) ';

      if cmbShow.Text = 'Enabled' then
         CommandText := CommandText +
                        'and A.ENABLED = ''Y'' '+
                        'and A.QUIT_DATE is Null ';
      if cmbShow.Text = 'Disabled' then
         CommandText := CommandText +
                        'and A.ENABLED = ''N'' '+
                        'and A.QUIT_DATE is Null ';
      if cmbShow.Text = 'Quit Employee' then
         CommandText := CommandText +
                        'and A.QUIT_DATE is not Null ';

      if cmbDept.Text <> 'ALL' then
         CommandText := CommandText + ' and B.DEPT_NAME = :DEPT_NAME ';

      Params.ParamByName('FCID').AsString := FcID;
      if cmbDept.Text <> 'ALL' then
         Params.ParamByName('DEPT_NAME').AsString := cmbDept.Text;

      CommandText := CommandText + ' Order By ' + Orderidx;
      Open;
   end;
end;

procedure TfEmp.sbtnAppendClick(Sender: TObject);
var I: Integer;
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select SHIFT_CODE ' +
         'From SAJET.SYS_SHIFT ' +
         'Where ENABLED = ''Y'' ' +
         'Order By SHIFT_CODE ';
      Open;
   end;

   with TfData.Create(Self) do
   begin
      MaintainType := 'Append';
      FcID := Self.FcID;

      while not QryTemp.Eof do
      begin
         cmbShift.Items.Add(QryTemp.Fieldbyname('SHIFT_CODE').AsString);
         QryTemp.Next;
      end;
      QryTemp.Close;

      for I := 0 to Self.cmbFactory.Items.Count - 1 do
         cmbFactory.Items.Add(Self.cmbFactory.Items[I]);
      cmbFactory.ItemIndex := Self.cmbFactory.ItemIndex;

      cmbFactory.Enabled := (UserFcID = '0');
      LabDesc.Caption := Self.LabDesc.Caption;

      for I := 1 to Self.cmbDept.Items.Count - 1 do
         cmbDept.Items.Add(Self.cmbDept.Items[I]);
      if Self.cmbDept.ItemIndex > 0 then
         cmbDept.ItemIndex := Self.cmbDept.ItemIndex - 1;

      LabType1.Caption := LabType1.Caption + ' Append';
      LabType2.Caption := LabType2.Caption + ' Append';
      if Showmodal = mrOK then
         ShowData;
      Free;
   end;
end;

procedure TfEmp.sbtnModifyClick(Sender: TObject);
var I: Integer;
begin
   if QryData.RecordCount = 0 then
   begin
      MessageDlg('Data not assign !!', mtCustom, [mbOK], 0);
      Exit;
   end;

   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select SHIFT_CODE ' +
         'From SAJET.SYS_SHIFT ' +
         'Where ENABLED = ''Y'' ' +
         'Order By SHIFT_CODE ';
      Open;
   end;

   with TfData.Create(Self) do
   begin
      MaintainType := 'Modify';
      FcID := Self.FcID;

      while not QryTemp.Eof do
      begin
         cmbShift.Items.Add(QryTemp.Fieldbyname('SHIFT_CODE').AsString);
         QryTemp.Next;
      end;
      QryTemp.Close;

      for I := 0 to Self.cmbFactory.Items.Count - 1 do
         cmbFactory.Items.Add(Self.cmbFactory.Items[I]);
      cmbFactory.ItemIndex := Self.cmbFactory.ItemIndex;

      cmbFactory.Enabled := (UserFcID = '0');
      LabDesc.Caption := Self.LabDesc.Caption;

      for I := 1 to Self.cmbDept.Items.Count - 1 do
         cmbDept.Items.Add(Self.cmbDept.Items[I]);
      if Self.cmbDept.ItemIndex > 0 then
         cmbDept.ItemIndex := Self.cmbDept.ItemIndex - 1;

      QryTemp.Close;
      editEmpNo.Text := QryData.Fieldbyname('EMP_NO').aSString;
      editEmpName.Text := QryData.Fieldbyname('EMP_NAME').aSString;
      cmbShift.ItemIndex := cmbShift.Items.IndexOf(QryData.Fieldbyname('SHIFT_CODE').aSString);
      cmbDept.ItemIndex := cmbDept.Items.IndexOf(QryData.Fieldbyname('DEPT_NAME').aSString);
      LabType1.Caption := LabType1.Caption + ' Modify';
      LabType2.Caption := LabType2.Caption + ' Modify';
      EMPID := QryData.Fieldbyname('EMP_ID').aSString;

      if Showmodal = mrOK then
         ShowData;
      Free;
   end;
end;

procedure TfEmp.DBGrid1TitleClick(Column: TColumn);
begin
   OrderIdx := Column.FieldName;
   
   ShowData;
end;

procedure TfEmp.FormShow(Sender: TObject);
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      CommandText := 'Select NVL(FACTORY_ID,0) FACTORY_ID ' +
         'From SAJET.SYS_EMP ' +
         'Where EMP_ID = :EMP_ID ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Open;
      if UpdateUserID <> '0' then
      begin
         if RecordCount = 0 then
         begin
            Close;
            MessageDlg('Account Error !!', mtError, [mbOK], 0);
            Exit;
         end;
         UserFcID := Fieldbyname('FACTORY_ID').AsString;
      end
      else
         UserFcID := '0';
      FcID := UserFcID;
      Close;
   end;

   cmbFactory.Items.Clear;
   cmbFactory.Items.Add('N/A');
   with QryTemp do
   begin
      Close;
      CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
         'From SAJET.SYS_FACTORY ' +
         'Where ENABLED = ''Y'' ';
      Open;
      while not Eof do
      begin
         cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString);
         if Fieldbyname('FACTORY_ID').AsString = UserFcID then
         begin
            cmbFactory.ItemIndex := cmbFactory.Items.Count - 1;
            LabDesc.Caption := Fieldbyname('FACTORY_DESC').AsString;
         end;
         Next;
      end;
      Close;
      CommandText := 'Select sajet.password.decrypt(PARAM_Value) PARAM_Value ' +
         'From SAJET.SYS_BASE ' +
         'Where PARAM_NAME = ''Default Password'' ';
      Open;
      gsDefaultPasswd := Trim(FieldByName('PARAM_Value').AsString);
      Close;
   end;
   cmbFactory.Enabled := (UserFcID = '0');
   if UserFcID = '0' then
      cmbFactory.ItemIndex := 0;

   Orderidx := 'EMP_NO';
   cmbType.ItemIndex := 0;

   cmbFactoryChange(self);
//  cmbShowChange(Self);
   if UpdateUserID <> '0' then
      SetStatusbyAuthority;
 // ShowData;
end;

procedure TfEmp.sbtnDeleteClick(Sender: TObject);
begin
   if QryData.RecordCount = 0 then
   begin
      MessageDlg('Data not assign!!', mtCustom, [mbOK], 0);
      Exit;
   end;

   if MessageDlg('Do you want to delete this data ?' + #13#10 +
      'Employee No : ' + QryData.Fieldbyname('EMP_NO').AsString + #13#10 +
      'Employee Name : ' + QryData.Fieldbyname('EMP_NAME').AsString, mtWarning, mbOKCancel, 0) = mrOK then
   begin
      with QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'EMP_ID', ptInput);
         CommandText := 'Delete SAJET.SYS_ROLE_EMP ' +
            'Where EMP_ID = :EMP_ID ';
         Params.ParamByName('EMP_ID').AsString := QryData.Fieldbyname('EMP_ID').AsString;
         Execute;
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'EMP_ID', ptInput);
         CommandText := 'Delete SAJET.SYS_EMP_PRIVILEGE ' +
            'Where EMP_ID = :EMP_ID ';
         Params.ParamByName('EMP_ID').AsString := QryData.Fieldbyname('EMP_ID').AsString;
         Execute;
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'ENABLED', ptInput);
         Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
         Params.CreateParam(ftString, 'EMP_ID', ptInput);
         CommandText := 'Update SAJET.SYS_EMP ' +
            'Set ENABLED = :ENABLED, ' +
            'UPDATE_USERID = :UPDATE_USERID, ' +
            'UPDATE_TIME = SYSDATE ' +
            'Where EMP_ID = :EMP_ID ';
         Params.ParamByName('ENABLED').AsString := 'Drop';
         Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
         Params.ParamByName('EMP_ID').AsString := QryData.Fieldbyname('EMP_ID').AsString;
         Execute;
         CopyToHistory(QryData.Fieldbyname('EMP_ID').AsString);

         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'EMP_ID', ptInput);
         CommandText := 'Delete SAJET.SYS_EMP ' +
            'Where EMP_ID = :EMP_ID ';
         Params.ParamByName('EMP_ID').AsString := QryData.Fieldbyname('EMP_ID').AsString;
         Execute;
         QryData.Delete;
      end;
   end;
end;

procedure TfEmp.sbtnDisabledClick(Sender: TObject);
var sStatus: string;
begin
   if QryData.RecordCount = 0 then
   begin
      MessageDlg('Data not assign !!', mtCustom, [mbOK], 0);
      Exit;
   end;

   if QryData.Fieldbyname('ENABLED').AsString = 'Y' then
   begin
      if MessageDlg('Do you want to disable this data ?' + #13#10 +
         'Employee No : ' + QryData.Fieldbyname('EMP_NO').AsString + #13#10 +
         'Employee Name : ' + QryData.Fieldbyname('EMP_NAME').AsString, mtWarning, mbOKCancel, 0) <> mrOK then
         Exit;
      sStatus := 'N';
   end
   else
   begin
      if MessageDlg('Do you want to enable this data ?' + #13#10 +
         'Employee No : ' + QryData.Fieldbyname('EMP_NO').AsString + #13#10 +
         'Employee Name : ' + QryData.Fieldbyname('EMP_NAME').AsString, mtWarning, mbOKCancel, 0) <> mrOK then
         Exit;
      sStatus := 'Y';
   end;

   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'ENABLED', ptInput);
      Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      CommandText := 'Update SAJET.SYS_EMP ' +
         'Set ENABLED = :ENABLED, ' +
         'UPDATE_USERID = :UPDATE_USERID, ' +
         'UPDATE_TIME = SYSDATE ' +
         'Where EMP_ID = :EMP_ID ';
      Params.ParamByName('ENABLED').AsString := sStatus;
      Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
      Params.ParamByName('EMP_ID').AsString := QryData.Fieldbyname('EMP_ID').AsString;
      Execute;
      CopyToHistory(QryData.Fieldbyname('EMP_ID').AsString);
      QryData.Delete;
   end;
end;

procedure TfEmp.cmbShowChange(Sender: TObject);
begin
   sbtnDisabled.Caption := 'Disable';
   if cmbShow.Text = 'Disabled' then
      sbtnDisabled.Caption := 'Enable';
   Disabled1.Caption := sbtnDisabled.Caption;
   SbtnDelete.Visible := (cmbShow.Text = 'Disabled');
   ImgDelete.Visible := SbtnDelete.Visible;
   Delete1.Visible := SbtnDelete.Visible;
   ShowData;
end;

procedure TfEmp.sbtnExportClick(Sender: TObject);
var F: TextFile;
   S: string;
begin
   SaveDialog1.InitialDir := ExtractFilePath('C:\');
   SaveDialog1.DefaultExt := 'csv';
   SaveDialog1.Filter := 'All Files(*.csv)|*.csv';
   if SaveDialog1.Execute then
   begin
      AssignFile(F, SaveDialog1.FileName);
      Rewrite(F);
      QryData.First;
      while not QryData.Eof do
      begin
         S := QryData.Fieldbyname('EMP_NO').AsString + ',' +
            QryData.Fieldbyname('EMP_NAME').AsString + ',' +
            QryData.Fieldbyname('DEPT_NAME').AsString + ',' +
            QryData.Fieldbyname('SHIFT_CODE').AsString;
         Writeln(F, S);
         QryData.Next;
      end;
      MessageDlg('Export OK !!', mtCustom, [mbOK], 0);
      CloseFile(F);
   end;
end;

procedure TfEmp.ModifyLog1Click(Sender: TObject);
var S: string;
begin
   if QryData.RecordCount = 0 then
   begin
      MessageDlg('Data not assign !!', mtCustom, [mbOK], 0);
      Exit;
   end;
   S := QryData.Fieldbyname('Emp_No').AsString;
   with TfHistory.Create(Self) do
   begin
      QryData1.RemoteServer := Self.QryData.RemoteServer;
      QryData1.ProviderName := 'DspQryData1';
      editCode.Text := S;
      ShowHistory(S);
      Showmodal;
      Free;
   end;
end;

procedure TfEmp.sbtnRoleClick(Sender: TObject);
var S, emp: string;
begin
   if QryData.RecordCount = 0 then
   begin
      MessageDlg('Data not assign !!', mtCustom, [mbOK], 0);
      Exit;
   end;
   S := QryData.Fieldbyname('Emp_No').AsString + '  ' +
      QryData.Fieldbyname('Emp_Name').AsString;
   emp := QryData.Fieldbyname('Emp_Id').AsString;
   with TfRole.Create(Self) do
   begin
      EmpId := emp;
      LabEmp.Caption := S;
      UpdateUserID := Self.UpdateUserID;
      QryData.RemoteServer := Self.QryData.RemoteServer;
      QryData.ProviderName := 'DspQryData';
      QryTemp.RemoteServer := Self.QryData.RemoteServer;
      QryTemp.ProviderName := 'DspQryTemp1';
      ShowAllRole;
      ShowEmpRole;
      Showmodal;
      Free;
   end;
end;

procedure TfEmp.cmbFactoryChange(Sender: TObject);
begin
   FcID := '';
   if cmbFactory.Text = 'N/A' then
   begin
      FcID := '0';
      LabDesc.Caption := '';
   end
   else
   begin
      with QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'FACTORYCODE', ptInput);
         CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
            'From SAJET.SYS_FACTORY ' +
            'Where FACTORY_CODE = :FACTORYCODE ';
         Params.ParamByName('FACTORYCODE').AsString := Copy(cmbFactory.Text, 1, POS(' ', cmbFactory.Text) - 1);
         Open;
         if RecordCount > 0 then
         begin
            FcID := Fieldbyname('FACTORY_ID').AsString;
            LabDesc.Caption := Fieldbyname('FACTORY_DESC').AsString;
         end;
         Close;
      end;
   end;

   cmbDept.Items.Clear;
   cmbDept.Items.Add('ALL');
   with QryTemp do
   begin
      Close;
      Params.Clear;
     // Params.CreateParam(ftString, 'FCID', ptInput);
      CommandText := 'Select DEPT_ID,DEPT_NAME ' +
         'From SAJET.SYS_DEPT ' +
         'Where ENABLED = ''Y''  order by dept_name asc ';
        // ' and FACTORY_ID = :FCID';
     // Params.ParamByName('FCID').AsString := FcID;
      Open;
      while not Eof do
      begin
         cmbDept.Items.Add(Fieldbyname('DEPT_NAME').AsString);
         Next;
      end;
      Close;
   end;
   cmbDept.Itemindex := 0;
   cmbShowChange(Self);
end;

procedure TfEmp.ResetPassword1Click(Sender: TObject);
var S: string;
begin
   if QryData.RecordCount = 0 then
   begin
      MessageDlg('Data not assign !!', mtCustom, [mbOK], 0);
      Exit;
   end;

   S := InputBox('New Password', 'Password', '');
   if Trim(S) = '' then
   begin
      MessageDlg('Password Error !!', mtCustom, [mbOK], 0);
      Exit;
   end;

   try
      with QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'PASSWD', ptInput);
         Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
         Params.CreateParam(ftString, 'EMP_ID', ptInput);
         CommandText := 'Update SAJET.SYS_EMP ' +
            'Set PASSWD = SAJET.password.encrypt(:PASSWD), ' +
            'UPDATE_USERID = :UPDATE_USERID ' +
            'Where EMP_ID = :EMP_ID ';
         Params.ParamByName('PASSWD').AsString := S;
         Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
         Params.ParamByName('EMP_ID').AsString := QryData.Fieldbyname('EMP_ID').AsString;
         Execute;
         CopyToHistory(QryData.Fieldbyname('EMP_ID').AsString);
         MessageDlg('Password Update OK!!', mtCustom, [mbOK], 0);
      end;
   except
      MessageDlg('Database Error !!' + #13#10 +
         'could not Update Database !!', mtError, [mbCancel], 0);
      Exit;
   end;

end;

procedure TfEmp.cmbTypeChange(Sender: TObject);
begin
   case cmbType.ItemIndex of
      0: OrderIdx := 'EMP_NO';
      1: OrderIdx := 'EMP_NAME';
      2: OrderIdx := 'DEPT_NAME';
      3: OrderIdx := 'SHIFT';
   end;
   ShowData;
end;

procedure TfEmp.editSearchChange(Sender: TObject);
begin
   if not QryData.Active then
      Exit;
   case cmbType.ItemIndex of
      0: QryData.Locate('EMP_NO', Trim(editSearch.Text), [loCaseInsensitive, loPartialKey]);
      1: QryData.Locate('EMP_NAME', Trim(editSearch.Text), [loCaseInsensitive, loPartialKey]);
      2: QryData.Locate('DEPT_NAME', Trim(editSearch.Text), [loCaseInsensitive, loPartialKey]);
      3: QryData.Locate('SHIFT', Trim(editSearch.Text), [loCaseInsensitive, loPartialKey]);
   end;
end;

procedure TfEmp.sbtnImportClick(Sender: TObject);
   function GetDeptID(sDeptName:String): string;
   begin
     Result := '';
     with QryTemp do
     begin
       try
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'DEPT', ptInput);
         CommandText := 'Select DEPT_ID ' +
                        'From SAJET.SYS_DEPT ' +
                        'Where DEPT_NAME = :DEPT  order by dept_name asc ';
         Params.ParamByName('DEPT').AsString := sDeptName;
         Open;
         if RecordCount > 0 then
            Result := Fieldbyname('DEPT_ID').AsString;
       finally
         Close;
       end;
     end;//with
   end;

   function GetShiftID(sShiftName:String): string;
   begin
     Result := '0';
     with QryTemp do
     begin
       try
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'SHIFT', ptInput);
         CommandText := 'Select SHIFT_ID ' +
            'From SAJET.SYS_SHIFT ' +
            'Where SHIFT_CODE = :SHIFT ';
         Params.ParamByName('SHIFT').AsString := sShiftName;
         Open;
         if RecordCount > 0 then
            Result := Fieldbyname('SHIFT_ID').AsString;
       finally
         Close;
       end;
     end; //with
   end;
   function CheckEmpExist(sEmpNo:String):Boolean;
   begin
     result := False;
     with QryTemp do
     begin
       try
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'EMP_NO', ptInput);
         CommandText := 'Select EMP_NO,EMP_NAME ' +
            'From SAJET.SYS_EMP ' +
            'Where EMP_NO = :EMP_NO ';
         Params.ParamByName('EMP_NO').AsString := sEmpNo;
         Open;
         if RecordCount > 0 then
         begin
           result:=true;
         end;
       finally
         close;
       end;
     end;//with
   end;
   function GetMaxEmpID: string;
   var DBID: string;
   begin
     with QryTemp do
     begin
       try
          Close;
          Params.Clear;
          CommandText := 'Select NVL(Max(EMP_ID),0) + 1 EMPID ' +
                         'From SAJET.SYS_EMP';
          Open;
          if Fieldbyname('EMPID').AsString = '1' then
          begin
             Close;
             CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || ''000001'' EMPID ' +
                            'From SAJET.SYS_BASE ' +
                            'Where PARAM_NAME = ''DBID'' ';
             Open;
          end;
          Result := Fieldbyname('EMPID').AsString;
       finally
          Close;
       end;
     end;//with
   end;
var sDot,sFileName,sEmpNo,sEmpName,sDeptName,sShift,mS:String;
    sEmpID,sDeptID,sShiftID:String;
    tExpFile: TextFile;
    iRow:integer;
begin
  dlgFileImport.InitialDir := ExtractFilePath(GetCurrentDir);
  dlgFileImport.DefaultExt := 'csv';
  dlgFileImport.Filter := 'All Files(*.csv)|*.csv';
  if not dlgFileImport.Execute then
    exit;
  sFileName := dlgFileImport.FileName;
  sDot := ',';
  try
    AssignFile(tExpFile, sFileName);
    Reset(tExpFile);
    try

      iRow:=0;
      while not Eof(tExpFile) do
      begin

        Readln(tExpFile, mS);
        sEmpNo       := Trim(Copy(mS,1,POS(sDot,mS)-1)); mS := Copy(mS,POS(sDot,mS)+1,Length(mS)-POS(sDot,mS));
        sEmpName    := Trim(Copy(mS,1,POS(sDot,mS)-1)); mS := Copy(mS,POS(sDot,mS)+1,Length(mS)-POS(sDot,mS));
        sDeptName   := Trim(Copy(mS,1,POS(sDot,mS)-1)); mS := Copy(mS,POS(sDot,mS)+1,Length(mS)-POS(sDot,mS));
        sShift      := Trim(mS);
        try

          if (sEmpNo<>'') and ( not CheckEmpExist(sEmpNo)) then
          begin
            inc(iRow);
            sDeptID:= GetDeptID(sDeptName);
            sShiftID:= GetShiftID(sShift);
            sEmpID:= GetMaxEmpID;
            with QryTemp do
            begin
              Close;
              Params.Clear;
              Params.CreateParam(ftString, 'FCID', ptInput);
              Params.CreateParam(ftString, 'EMP_ID', ptInput);
              Params.CreateParam(ftString, 'EMP_NO', ptInput);
              Params.CreateParam(ftString, 'EMP_NAME', ptInput);
              Params.CreateParam(ftString, 'DEPT_ID', ptInput);
              Params.CreateParam(ftString, 'SHIFT', ptInput);
              Params.CreateParam(ftString, 'PASSWD', ptInput);
              Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
              CommandText := 'Insert Into SAJET.SYS_EMP '
                           + ' (FACTORY_ID,EMP_ID,EMP_NO,EMP_NAME,DEPT_ID,SHIFT,PASSWD,UPDATE_USERID) '
                           + 'Values (:FCID,:EMP_ID,:EMP_NO,:EMP_NAME,:DEPT_ID,:SHIFT,sajet.password.encrypt(:PASSWD),:UPDATE_USERID) ';
              Params.ParamByName('FCID').AsString := FcID;
              Params.ParamByName('EMP_ID').AsString := sEmpID;
              Params.ParamByName('EMP_NO').AsString := sEmpNo;
              Params.ParamByName('EMP_NAME').AsString := sEmpName;
              Params.ParamByName('DEPT_ID').AsString := sDeptID;
              Params.ParamByName('SHIFT').AsString := sShiftID;
              if gsDefaultPasswd <> '' then
                 Params.ParamByName('PASSWD').AsString := gsDefaultPasswd
              else
                 Params.ParamByName('PASSWD').AsString := sEmpNo;
              Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
              Execute;
              CopyToHistory(sEmpId);
            end; //with
          end; //if
        except
          on E:EXCEPTION DO
          begin
            MessageDlg(e.Message,mtWarning,[mbOK],0);
            exit;
          end;
        end;
      end;//wihile
    finally
      QryTemp.close;
      Messagedlg('Import  "'+InttoStr(iRow)+'"  Record(s) !',mtInformation,[mbOK],0);
      Closefile(tExpFile);
      if iRow > 0 then
        ShowData;
    end;
  except
    on E:Exception do
      Messagedlg(E.Message,mtWarning,[mbOK],0);
  end;

end;

end.

