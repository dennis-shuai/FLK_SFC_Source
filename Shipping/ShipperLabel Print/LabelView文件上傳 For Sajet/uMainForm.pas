unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, DBClient, MConnect, SConnect, StrUtils, ADODB,
  clsGlobal, ExtCtrls, IniFiles ;

var
  sLogIn : Boolean = False ;
   
type
  TFormMain = class(TForm)
    OpenDialog1: TOpenDialog;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Edit1: TEdit;
    Label3: TLabel;
    EditPassWord: TEdit;
    edtFile: TEdit;
    Label2: TLabel;
    Button7: TButton;
    ButtonUpload: TButton;
    ButtonDel: TButton;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Label6: TLabel;
    edtCorlorN: TEdit;
    edtColorPath: TEdit;
    btnBrowse: TButton;
    btnColorUpload: TButton;
    btnColorDel: TButton;
    cmbType: TComboBox;
    Label8: TLabel;
    Label5: TLabel;
    ComboFileType: TComboBox;
    procedure ButtonDelClick(Sender: TObject);
    procedure ButtonUploadClick(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btnColorDelClick(Sender: TObject);
    procedure btnColorUploadClick(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure ComboFileTypeChange(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    function GetMaxID(DB_Tabel,Column : string): string;
  public
    { Public declarations }
    //專門用於綁定變量，系統優化
    BindVarQuery: TADOQuery;

    qryPulic: TADOQuery;
    //Call Store Porcedure
    CallSP: TADOStoredProc;


  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses Cl_crypt32, frmLogin;

function TFormMain.GetMaxID(DB_Tabel,Column : string): string;
begin
  with qryPulic do
  begin
    try
      Close;
      Parameters.Clear;
      sql.clear;
      SQL.Text := 'Select NVL(Max('+Column+'),0) + 1 MAXID ' +
                 'From '+DB_Tabel;
      Open;
      if Fieldbyname('MAXID').AsString = '1' then
      begin
        Close;
        Parameters.Clear;
        sql.Clear ;
        SQL.Text := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || ''000001'' MAXID ' +
                      'From SAJET.SYS_BASE ' +
                      'Where PARAM_NAME = ''DBID'' ';
        Open;
      end;
      Result := Fieldbyname('MAXID').AsString;
    finally
      Close;
    end;
  end;
end;

procedure TFormMain.ButtonDelClick(Sender: TObject);
begin
  if Edit1.Text ='' then
  begin
    MessageDlg('SKU號碼不能為空,請重新輸入!', mtError, [mbYES], 0);
    Edit1.SetFocus ;
    Edit1.SelectAll ;
    Exit ;
  end;

  if MessageDlg('是否確定要刪除此SKU的Label資料?',
     mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    with BindVarQuery do
    begin
      Close ;
      Parameters.Clear ;
      sql.Clear ;
      sql.Text := 'DELETE FROM SAJET.SYS_PRINT_LABEL_FILE WHERE SKU_NO =:SKU AND ROWNUM = 1 ';
      Parameters.ParamByName('SKU').Value := Edit1.Text ;
      ExecSQL ;
      Close ;
      MessageDlg('此SKU Label資料已經成功刪除!', mtInformation , [mbYES], 0);
      Edit1.Clear ;
      Edit1.SetFocus ;
    end;
  end;
end;

procedure TFormMain.ButtonUploadClick(Sender: TObject);
var FileName : string;
  LABELID : Integer ;
begin
  if Edit1.Text ='' then
  begin
    MessageDlg('SKU號碼不能為空,請重新輸入!', mtError, [mbYES], 0);
    Edit1.SetFocus ;
    Edit1.SelectAll ;
    Exit ;
  end;

  if cmbType.Text ='' then
  begin
    MessageDlg('Label內型不能為空,請重新輸入!', mtError, [mbYES], 0);
    cmbType.SetFocus ;
    cmbType.SelectAll ;
    Exit ;
  end;

  if ComboFileType.ItemIndex = 0 then
  begin
    if EditPassWord.Text ='' then
    begin
      MessageDlg('Label文件密碼不能為空,請重新輸入!', mtError, [mbYES], 0);
      EditPassWord.SetFocus ;
      EditPassWord.SelectAll ;
      Exit ;
    end;
  end else
  begin
    EditPassWord.Color := clWhite ;
    EditPassWord.Clear ;
  end;
  
  with BindVarQuery do
  begin
    try
      Close ;
      Parameters.Clear ;
      sql.Clear ;
      SQL.Text := 'SELECT LABELFILE_ID,LABEL_TYPE,LABEL_PWD FROM  '+
                  '  SAJET.SYS_PRINT_LABEL_FILE WHERE SKU_NO =:SKU_NO ' +
                  '    AND LABEL_TYPE = :LABEL_TYPE ';
      Parameters.ParseSQL(SQL.Text, True); //清除之前的參數，根據SQL生成新的參數
      Parameters.ParamByName('SKU_NO').Value := Edit1.Text;
      Parameters.ParamByName('LABEL_TYPE').Value := cmbType.Text;
      Open ;
      if not IsEmpty then
      begin
        LABELID := fieldByName('LABELFILE_ID').AsInteger ;
        cmbType.Enabled := False ;
        cmbType.Text := FieldByName('LABEL_TYPE').AsString ;
        Close ;

        //MessageDlg('重複的SKU號碼,請重新輸入!', mtError, [mbYES], 0);
        if MessageDlg('重複的SKU號碼,是否確定要更新Label資料?',
           mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
          with BindVarQuery do
          begin
            Close ;
            Parameters.Clear ;
            sql.Clear ;
            if edtFile.Text = '' then
            begin
              sql.Text := 'UPDATE SAJET.SYS_PRINT_LABEL_FILE SET LABEL_PWD=:PWD, '
                        + '  UPDATE_TIME = SYSDATE ,UPDATE_USERID = :USERID, '
                        + '    FILE_TYPE = :FILETYPE WHERE  SKU_NO =:SKU   '
                        + '    AND LABELFILE_ID =:ID AND ROWNUM = 1 ';
              Parameters.ParseSQL(SQL.Text,True );
              Parameters.ParamByName('ID').Value := LABELID ;
              Parameters.ParamByName('SKU').Value := Edit1.Text ;
              Parameters.ParamByName('PWD').Value := EditPassWord.Text ;
              Parameters.ParamByName('FILETYPE').Value := ComboFileType.Text ;
              Parameters.ParamByName('USERID').Value := ObjGlobal.objUser.FID ;
            end else
            begin
              FileName:= ReverseString(edtFile.Text);      //反轉字符串
              FileName := Edit1.Text + ReverseString(Copy(FileName,1,Pos('.',FileName)));

              sql.Text := 'UPDATE SAJET.SYS_PRINT_LABEL_FILE SET LABEL_FILE =:LF,LABEL_PWD=:PWD, '
                        + '  UPDATE_TIME = SYSDATE ,UPDATE_USERID = :USERID, '
                        + '     FILE_TYPE = :FILETYPE, LABEL_NAME = :LN   '
                        + '        WHERE  SKU_NO =:SKU   '
                        + '    AND LABELFILE_ID =:ID AND ROWNUM = 1 ';
              Parameters.ParseSQL(SQL.Text,True );
              Parameters.ParamByName('ID').Value := LABELID ;
              Parameters.ParamByName('SKU').Value := Edit1.Text ;
              Parameters.ParamByName('PWD').Value := EditPassWord.Text ;
              Parameters.ParamByName('FILETYPE').Value := ComboFileType.Text ;
              Parameters.ParamByName('LN').Value := FileName ;
              Parameters.ParamByName('LF').LoadFromFile(edtFile.Text,ftBlob );
              Parameters.ParamByName('USERID').Value := ObjGlobal.objUser.FID ;
            end;
            ExecSQL ;
            Close ;
            MessageDlg('Label資料更新成功!', mtInformation , [mbYES], 0);
            Edit1.Clear ;
            EditPassWord.Clear ;
            edtFile.Clear ;
            Edit1.SetFocus ;
            cmbType.Text := '';
            exit ;
          end;
        end;
        Edit1.SetFocus ;
        Edit1.SelectAll ;
        Exit ;
      end;
    except
      on E: Exception do
      begin
        MessageDlg('上傳文件失敗,錯誤訊息:'+E.Message, mtError, [mbYES], 0);
        Exit ;
      end;
    end;
  end;

  if edtFile.Text ='' then
  begin
    MessageDlg('Label文件不能為空,請重新輸入!', mtError, [mbYES], 0);
    edtFile.SetFocus ;
    edtFile.SelectAll ;
    Exit ;
  end;

  FileName:= ReverseString(edtFile.Text);      //反轉字符串
  FileName := Edit1.Text + ReverseString(Copy(FileName,1,Pos('.',FileName)));

  //用以下SQL的方式寫入不成功,網上說這是DELPHI的一個BUG
  {Close ;
  Params.Clear ;
  Params.CreateParam(ftString,'SKU_NO',ptInput);
  Params.CreateParam(ftString,'Label_Name',ptInput);
  Params.CreateParam(ftString,'LABEL_PWD',ptInput);
  Params.CreateParam(ftBlob,'Label_File',ptInput);
  Params.CreateParam(ftString,'USERID',ptInput);
  CommandText := 'INSERT INTO SAJET.SYS_PRINT_LABEL_FILE(SKU_NO,Label_Name,LABEL_PWD,LABEL_FILE, '      //
               + ' UPDATE_USERID) VALUES (:SKU_NO,:Label_Name,:LABEL_PWD,:Label_File,:USERID ) ';
  //Params.ParseSQL(CommandText, True); //清除之前的參數，根據SQL生成新的參數
  Params.ParamByName('SKU_NO').AsString := Edit1.Text;
  Params.ParamByName('Label_Name').AsString := FileName;
  //Params.ParamByName('Label_File').LoadFromStream(tStream,ftBlob);
  Params.ParamByName('Label_File').LoadFromFile(edtFile.Text,ftBlob);
  Params.ParamByName('LABEL_PWD').AsString := EditPassWord.Text;
  Params.ParamByName('USERID').AsString := '100000001' ;
  Execute ;}

  {//只能用插入的方法了,鬱悶
  Close;
  CommandText:='SELECT * FROM SAJET.SYS_PRINT_LABEL_FILE';
  //Open;
  if   not   Active   then   Open;
  Append ;
  FieldByName('SKU_NO').AsString := Edit1.Text ;
  FieldByName('Label_Name').AsString := FileName ;
  FieldByName('LABEL_PWD').AsString := EditPassWord.Text ;
  TBlobField(FieldByName('LABEL_FILE')).LoadFromFile(edtFile.Text) ;
  FieldByName('UPDATE_USERID').AsString := '100000001' ;
  Post ;
  ApplyUpdates(0);
  MergeChangeLog ;
  Close ;
  First;
  EnableControls ;}
  try
    with BindVarQuery do
    begin
      Close ;
      Parameters.Clear ;
      sql.Clear ;
      sql.Text := 'INSERT INTO SAJET.SYS_PRINT_LABEL_FILE(LABELFILE_ID,SKU_NO,Label_Name, '      //
                   + ' LABEL_PWD,LABEL_FILE,UPDATE_USERID,LABEL_TYPE,FILE_TYPE) VALUES '
                   +'   (:ID,:SKU_NO,:Label_Name, :LABEL_PWD,:Label_File,:USERID, '
                   +'      :LABEL_TYPE,:FILETYPE ) ';
      Parameters.ParseSQL(sql.Text, True); //清除之前的參數，根據SQL生成新的參數
      Parameters.ParamByName('ID').Value := GetMaxID('SAJET.SYS_PRINT_LABEL_FILE','LABELFILE_ID');
      Parameters.ParamByName('SKU_NO').Value := Edit1.Text;
      Parameters.ParamByName('Label_Name').Value := FileName;
      Parameters.ParamByName('Label_File').LoadFromFile(edtFile.Text,ftBlob);
      Parameters.ParamByName('LABEL_PWD').Value := EditPassWord.Text;
      Parameters.ParamByName('USERID').Value := ObjGlobal.objUser.FID ;
      Parameters.ParamByName('LABEL_TYPE').Value := cmbType.Text ;
      Parameters.ParamByName('FILETYPE').Value := ComboFileType.Text ;
      ExecSQL ;
    end;

    ShowMessage('Uploading Successfully!');
    Edit1.Clear ;
    EditPassWord.Clear ;
    edtFile.Clear ;
    cmbType.Text := '';
    Edit1.SetFocus ;
  except
    on E: Exception do
    begin
      MessageDlg('上傳文件失敗,錯誤訊息:'+E.Message, mtError, [mbYES], 0);
    end;
  end;
end;

procedure TFormMain.Button7Click(Sender: TObject);
var
  IniFile : TIniFile ;
  InitialDir : string ;
begin
  IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+'\ini\BD_Option.ini');
  InitialDir :=  IniFile.ReadString('OPTION','InitLabelDir','');
  OpenDialog1.InitialDir := InitialDir ;
  if OpenDialog1.Execute then
  begin
    edtFile.Text := OpenDialog1.FileName ;
    IniFile.WriteString('OPTION', 'InitLabelDir', edtFile.Text);
  end;
  IniFile.free;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  //ShowMessage(cl_encrypt('sajet'));     //加密
  objGlobal := TGlobal.Create;
  qryPulic := TADOQuery.Create(nil);
  CallSP := TADOStoredProc.Create(nil);
  qryPulic.Connection := objGlobal.objDataConnect.ObjConnection;
  CallSP.Connection := objGlobal.objDataConnect.ObjConnection;

  //專門用於綁定變量，系統優化
  BindVarQuery := TADOQuery.Create(nil);
  BindVarQuery.Connection := objGlobal.objDataConnect.ObjConnection;
  BindVarQuery.LockType := ltReadOnly;

 // 找出所有Label類型
  cmbType.Items.Clear;
  with BindVarQuery do
  begin
    Close;
    Parameters.Clear;
    SQL.Clear ;
    //Params.CreateParam(ftString, 'FACTORY_ID', ptInput);
    SQL.Text := 'Select LABEL_TYPE ' +
      'From SAJET.SYS_PRINT_LABEL_FILE ' +
      //'Where FACTORY_ID = :FACTORY_ID ' +
      'Group By LABEL_TYPE ';
    //Params.ParamByName('FACTORY_ID').AsString := fWOManager.FcID;
    Open;
    while not Eof do
    begin
      cmbType.Items.Add(Fieldbyname('LABEL_TYPE').AsString);
      Next;
    end;
    Close;
  end;
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //專門用於綁定變量，系統優化
  BindVarQuery.Close;
  BindVarQuery.Free;

  qryPulic.Close;
  qryPulic.Free;
  CallSP.Close;
  CallSP.Free;
  objGlobal.objDataConnect.ObjConnection.Close;
  objGlobal.Free;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  Self.Left :=Round((Screen.Width -Self.Width)/2);
  Self.Top :=Round((Screen.Height-Self.Height)/2);
  if Login <> nil then
  begin
    Login.Close ;
    FreeAndNil(Login);
  end;
  Login := TLogin.Create(nil);
  Login.ShowModal ;
  if not sLogIn then
  begin
    Edit1.Enabled := False ;
    ButtonDel.Enabled := False ;
    cmbType.Enabled := False ;
    EditPassWord.Enabled := False ;
    ButtonUpload.Enabled := False ;
    edtFile.Enabled := False ;
    Button7.Enabled := False ;
    edtCorlorN.Enabled := False ;
    btnColorDel.Enabled := False ;
    btnColorUpload.Enabled := False ;
    edtColorPath.Enabled := False ;
    btnBrowse.Enabled := False ;
  end;
end;

procedure TFormMain.btnColorDelClick(Sender: TObject);
begin
  if edtCorlorN.Text ='' then
  begin
    MessageDlg('要刪除的顏色資料不能為空,請重新輸入!', mtError, [mbYES], 0);
    edtCorlorN.SetFocus ;
    edtCorlorN.SelectAll ;
    Exit ;
  end;

  if MessageDlg('是否確定要刪除此顏色所對應的圖片資料?',
     mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    with BindVarQuery do
    begin
      Close ;
      Parameters.Clear ;
      sql.Clear ;
      sql.Text := 'DELETE FROM SAJET.SYS_COLOR WHERE COLOR_NAME =:CN AND ROWNUM = 1 ';
      Parameters.ParamByName('CN').Value := edtCorlorN.Text ;
      ExecSQL ;
      Close ;
      MessageDlg('此顏色所對應的圖片資料已經成功刪除!', mtInformation , [mbYES], 0);
      edtCorlorN.Clear ;
      edtCorlorN.SetFocus ;
    end;
  end;
end;

procedure TFormMain.btnColorUploadClick(Sender: TObject);
var FileName : string;
  LABELID : Integer ;
begin
  if edtCorlorN.Text ='' then
  begin
    MessageDlg('要刪除的顏色資料不能為空,請重新輸入!', mtError, [mbYES], 0);
    edtCorlorN.SetFocus ;
    edtCorlorN.SelectAll ;
    Exit ;
  end;

  if edtColorPath.Text ='' then
  begin
    MessageDlg('要上傳的圖片路徑不能為空,請重新輸入!', mtError, [mbYES], 0);
    edtColorPath.SetFocus ;
    edtColorPath.SelectAll ;
    Exit ;
  end;
  
  with BindVarQuery do
  begin
    try
      Close ;
      Parameters.Clear ;
      sql.Clear ;
      SQL.Text := 'SELECT COLOR_ID,COLOR_NAME FROM  '+
                  'SAJET.SYS_COLOR WHERE COLOR_NAME =:CN ' ;
      Parameters.ParseSQL(SQL.Text, True); //清除之前的參數，根據SQL生成新的參數
      Parameters.ParamByName('CN').Value := edtCorlorN.Text;
      Open ;
      if not IsEmpty then
      begin
        LABELID := FieldByName('COLOR_ID').AsInteger ;
        Close ;
        //MessageDlg('重複的SKU號碼,請重新輸入!', mtError, [mbYES], 0);
        if MessageDlg('重複的顏色資料,是否確定要更新此顏色所對應的圖片資料?',
           mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
          with BindVarQuery do
          begin
            Close ;
            Parameters.Clear ;
            sql.Clear ;
            sql.Text := 'UPDATE SAJET.SYS_COLOR SET COLOR_PICTURE =:LF, '
                      + '  UPDATE_TIME = SYSDATE WHERE  COLOR_NAME =:CN  AND COLOR_ID =:ID '
                      + '    AND ROWNUM = 1 ';
            Parameters.ParseSQL(SQL.Text,True );
            Parameters.ParamByName('ID').Value := LABELID ;
            Parameters.ParamByName('CN').Value := edtCorlorN.Text ;
            Parameters.ParamByName('LF').LoadFromFile(edtColorPath.Text,ftBlob );
            ExecSQL ;
            Close ;
            MessageDlg('Label資料更新成功!', mtInformation , [mbYES], 0);
            edtCorlorN.Clear ;
            edtColorPath.Clear ;
            edtCorlorN.SetFocus ;
            exit ;
          end;
        end;
        edtCorlorN.SetFocus ;
        edtCorlorN.SelectAll ;
        Exit ;
      end;
    except
      on E: Exception do
      begin
        MessageDlg('上傳文件失敗,錯誤訊息:'+E.Message, mtError, [mbYES], 0);
        Exit ;
      end;
    end;
  end;

  FileName:= ReverseString(edtColorPath.Text);      //反轉字符串
  FileName := edtCorlorN.Text + ReverseString(Copy(FileName,1,Pos('.',FileName)));

  try
    with BindVarQuery do
    begin
      Close ;
      Parameters.Clear ;
      sql.Clear ;
      sql.Text := 'INSERT INTO SAJET.SYS_COLOR(COLOR_ID,COLOR_NAME,COLOR_PICTURE,UPDATE_USERID) '      //
                   + ' VALUES (:ID,:CN,:CP,:USERID ) ';
      Parameters.ParseSQL(sql.Text, True); //清除之前的參數，根據SQL生成新的參數
      Parameters.ParamByName('ID').Value := GetMaxID('SAJET.SYS_COLOR','COLOR_ID');
      Parameters.ParamByName('CN').Value := edtCorlorN.Text;
      Parameters.ParamByName('CP').LoadFromFile(edtColorPath.Text,ftBlob);
      Parameters.ParamByName('USERID').Value := '0' ;
      ExecSQL ;
    end;

    ShowMessage('Uploading Successfully!');
    edtCorlorN.Clear ;
    edtColorPath.Clear ;
    edtCorlorN.SetFocus ;
  except
    on E: Exception do
    begin
      MessageDlg('上傳文件失敗,錯誤訊息:'+E.Message, mtError, [mbYES], 0);
    end;
  end;
end;

procedure TFormMain.btnBrowseClick(Sender: TObject);
var
  IniFile : TIniFile ;
  InitialDir : string ;
begin
  IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+'\ini\BD_Option.ini');
  InitialDir :=  IniFile.ReadString('OPTION','InitColorDir','');
  OpenDialog1.InitialDir := InitialDir ;
  if OpenDialog1.Execute then
  begin
    edtColorPath.Text := OpenDialog1.FileName ;
    IniFile.WriteString('OPTION', 'InitColorDir', edtColorPath.Text);
  end;
  IniFile.free;
end;

procedure TFormMain.Label1Click(Sender: TObject);
begin
  Edit1.Text := cl_encrypt('SJ');
  edtFile.Text := cl_encrypt('foxsj36335');
end;

procedure TFormMain.Edit1Change(Sender: TObject);
begin
  cmbType.Enabled := true ;
end;

procedure TFormMain.ComboFileTypeChange(Sender: TObject);
begin
  if ComboFileType.ItemIndex = 0 then
  begin
    EditPassWord.Color := clYellow ;
    //EditPassWord.Clear ;
  end else
  begin
    EditPassWord.Color := clWhite ;
    //EditPassWord.Clear ;
  end;
end;

procedure TFormMain.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key =#13 then
  begin
    with BindVarQuery do
    begin
      try
        Close ;
        Parameters.Clear ;
        sql.Clear ;
        SQL.Text := 'SELECT LABELFILE_ID,LABEL_TYPE,LABEL_PWD,FILE_TYPE FROM  '+
                    '  SAJET.SYS_PRINT_LABEL_FILE WHERE SKU_NO =:SKU_NO ' +
                    '    AND LABEL_TYPE = :LABEL_TYPE ';
        Parameters.ParseSQL(SQL.Text, True); //清除之前的參數，根據SQL生成新的參數
        Parameters.ParamByName('SKU_NO').Value := Edit1.Text;
        Parameters.ParamByName('LABEL_TYPE').Value := cmbType.Text;
        Open ;
        if not IsEmpty then
        begin
          ComboFileType.ItemIndex := ComboFileType.Items.IndexOf(LowerCase(FieldByName('FILE_TYPE').AsString));
          EditPassWord.Text := FieldByName('LABEL_PWD').AsString ;
        end;
        Close ;
      except
        on E: Exception do MessageDlg('查詢文件失敗,錯誤訊息:'+E.Message, mtError, [mbYES], 0);
      end;
    end;
  end;
end;

end.
