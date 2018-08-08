unit uDPPM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, uData, Db, DBClient,
  MConnect, SConnect, FileCtrl, ObjBrkr, Menus;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    Image2: TImage;
    Image3: TImage;
    ImgDelete: TImage;
    LabTitle2: TLabel;
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
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx : String;
    UpdateUserID: String;
    Authoritys,AuthorityRole : String;
    Procedure CopyToHistory(sdeptid,stoolingid : String);
    procedure showData;
    Procedure SetStatusbyAuthority;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}

uses uHistory;

Procedure TfDetail.SetStatusbyAuthority;
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
       Params.ParamByName('PRG').AsString := 'Tooling';
       Params.ParamByName('FUN').AsString :='設備安全庫存設置';
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
end;

Procedure TfDetail.CopyToHistory(sdeptid,stoolingid : String);
begin
  With QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'dept_id', ptInput);
     Params.CreateParam(ftString	,'tooling_id', ptInput);
     CommandText := 'Insert Into SAJET.SYS_HT_TOOLING_SETTINGS '+
                      'Select * from SAJET.SYS_TOOLING_SETTINGS '+
                      'Where dept_id = :dept_id '+
                      'and tooling_id = :tooling_id ';
     Params.ParamByName('dept_id').AsString := sdeptid;
     Params.ParamByName('tooling_id').AsString := stoolingid;
     Execute;
  end;
end;

procedure TfDetail.ShowData;
begin
  If cmbShow.ItemIndex <= 0 Then
     cmbShow.ItemIndex := 0;
  With QryData do
  begin
     Close;
     CommandText := ' Select  B.dept_id,B.Dept_NAME,c.tooling_id,A.enabled,'+
                    ' C.TOOLING_NO,A.SAFTY_QTY,D.EMP_NAME,A.UPDATE_TIME '+
                    ' FROM SAJET.SYS_TOOLING_SETTINGS A,SAJET.SYS_DEPT B,'+
                    ' SAJET.SYS_TOOLING C,SAJET.SYS_EMP D '+
                    ' Where  A.DEPT_ID=B.DEPT_ID AND B.ENABLED=''Y''  '+
                    ' and A.TOOLING_ID=C.TOOLING_ID AND C.ENABLED=''Y'' '+
                    ' and A.UPDATE_USERID=D.EMP_ID AND  D.ENABLED=''Y''  ';
     If cmbShow.Text = 'Enabled' Then
       CommandText:= CommandText + 'And A.ENABLED = ''Y'' ';
     If cmbShow.Text = 'Disabled' Then
        CommandText:= CommandText + 'And A.ENABLED = ''N'' ';
     CommandText := CommandText + ' Order By '+Orderidx;
     Open;
  end;
end;

procedure TfDetail.sbtnAppendClick(Sender: TObject);
begin
  With TfData.Create(Self) do
  begin
     MaintainType := 'Append';
     LabType1.Caption := LabType1.Caption + ' Append';
     LabType2.Caption := LabType2.Caption + ' Append';
     If Showmodal = mrOk Then
       ShowData;
     Free;
  end;
end;

procedure TfDetail.sbtnModifyClick(Sender: TObject);
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  With TfData.Create(Self) do
  begin
     MaintainType := 'Modify';
     sdeptid :=  QryData.Fieldbyname('dept_id').aSString;
     stoolingId  :=  QryData.Fieldbyname('tooling_id').aSString;
     cmbDept.ItemIndex := cmbDept.Items.IndexOf(QryData.Fieldbyname('dept_name').aSString);
     cmbToolingNo.ItemIndex := cmbToolingNo.Items.IndexOf(QryData.Fieldbyname('tooling_no').aSString);
     edtSaftyNo.Text := QryData.Fieldbyname('Safty_Qty').aSString;
     LabType1.Caption := LabType1.Caption + ' Modify';
     LabType2.Caption := LabType2.Caption + ' Modify';
     cmbDept.Enabled :=false;
     cmbToolingNo.Enabled :=false;
     If Showmodal = mrOK Then
       ShowData;
     Free;
  end;
end;

procedure TfDetail.DBGrid1TitleClick(Column: TColumn);
begin
  OrderIdx:= Column.FieldName;
  ShowData;
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
  Orderidx := 'TOOLING_NO';
  cmbShowChange(Self);
  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;
end;

procedure TfDetail.sbtnDeleteClick(Sender: TObject);
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  If MessageDlg('Do you want to delete this data ?' + #13#10+
                'Dept Name : ' + QryData.Fieldbyname('Dept_Name').AsString +#13#10+
                'Tooling No : ' + QryData.Fieldbyname('Tooling_No').AsString +#13#10
                ,mtWarning, mbOKCancel,0) = mrOK Then
  begin
    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'ENABLED', ptInput);
      Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
      Params.CreateParam(ftString	,'Tooling_id', ptInput);
      Params.CreateParam(ftString	,'dept_id', ptInput);
      CommandText := 'Update SAJET.SYS_tooling_settings '+
                     'Set ENABLED = :ENABLED, '+
                         'UPDATE_USERID = :UPDATE_USERID, '+
                         'UPDATE_TIME = SYSDATE '+
                     'Where dept_ID = :dept_id '+
                     'and Tooling_id = :Tooling_id ';
      Params.ParamByName('ENABLED').AsString := 'D';
      Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
      Params.ParamByName('dept_id').AsString := QryData.Fieldbyname('Dept_ID').AsString;
      Params.ParamByName('Tooling_id').AsString := QryData.Fieldbyname('Tooling_id').AsString;
      Execute;
      CopyToHistory(QryData.Fieldbyname('dept_id').AsString,QryData.Fieldbyname('Tooling_id').AsString);

      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'dept_id', ptInput);
      Params.CreateParam(ftString	,'Tooling_id', ptInput);
      CommandText := 'Delete SAJET.SYS_tooling_settings '+
                     'Where dept_id = :dept_id '+
                     'and Tooling_id = :Tooling_id ';
      Params.ParamByName('dept_id').AsString := QryData.Fieldbyname('dept_id').AsString;
      Params.ParamByName('Tooling_id').AsString := QryData.Fieldbyname('Tooling_id').AsString;
      Execute;
      QryData.Delete;
    end;
  end;
end;

procedure TfDetail.sbtnDisabledClick(Sender: TObject);
Var sStatus : String;
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  If QryData.Fieldbyname('ENABLED').AsString = 'Y' Then
  begin
    If MessageDlg('Do you want to disable this data ?' + #13#10+
                 'dept_name : ' + QryData.Fieldbyname('dept_name').AsString +#13#10+
                 'tooling_No : '+ QryData.Fieldbyname('tooling_no').AsString +#13#10
                 ,mtWarning, mbOKCancel,0) <> mrOK Then
      Exit;
    sStatus := 'N';
  end Else
  begin
    If MessageDlg('Do you want to enable this data ?' + #13#10+
                  'dept_name : ' + QryData.Fieldbyname('dept_name').AsString +#13#10+
                  'tooling_No : '+ QryData.Fieldbyname('tooling_No').AsString +#13#10
                 ,mtWarning, mbOKCancel,0) <> mrOK Then
      Exit;
    sStatus := 'Y';
  end;

  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'ENABLED', ptInput);
    Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
    Params.CreateParam(ftString	,'tooling_id', ptInput);
    Params.CreateParam(ftString	,'dept_id', ptInput);
    CommandText := 'Update SAJET.sys_tooling_settings '+
                   'Set ENABLED = :ENABLED, '+
                       'UPDATE_USERID = :UPDATE_USERID, '+
                       'UPDATE_TIME =SYSDATE '+
                   'Where tooling_id = :tooling_id '+
                   'and dept_id = :dept_id ';
    Params.ParamByName('ENABLED').AsString := sStatus;
    Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
    Params.ParamByName('tooling_id').AsString := QryData.Fieldbyname('tooling_id').AsString;
    Params.ParamByName('dept_id').AsString := QryData.Fieldbyname('dept_id').AsString;
    Execute;
    CopyToHistory(QryData.Fieldbyname('dept_id').AsString,QryData.Fieldbyname('tooling_id').AsString);
    QryData.Delete;
  end;
end;

procedure TfDetail.cmbShowChange(Sender: TObject);
begin
  sbtnDisabled.Caption := 'Disabled';
  If cmbShow.Text = 'Disabled' Then
    sbtnDisabled.Caption := 'Enabled';
  Disabled1.Caption := sbtnDisabled.Caption;
  SbtnDelete.Visible := (cmbShow.Text = 'Disabled');
  ImgDelete.Visible := SbtnDelete.Visible;
  Delete1.Visible := SbtnDelete.Visible;
  ShowData;
end;

procedure TfDetail.sbtnExportClick(Sender: TObject);
Var F : TextFile;
    S : String;
    i,j : integer;
begin
  if (not QryData.active) or (QryData.IsEmpty) then
    exit;

  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'csv';
  SaveDialog1.Filter := 'All Files(*.csv)|*.csv';
  If SaveDialog1.Execute Then
  begin
     AssignFile(F,SaveDialog1.FileName);
     Rewrite(F);
     for i:= 0 to DBGrid1.Columns.Count-1 do
       if i= 0 then
         S:= DBGrid1.Columns.Items[i].Title.Caption
       else
         S:= S + ','+DBGrid1.Columns.Items[i].Title.Caption;
     Writeln(F,S);

     QryData.First ;
     while not QryData.EOF do
     begin
       for i := 0 to DBGrid1.Columns.Count - 1 do
       begin
         if i= 0 then
           S:= DBGrid1.Fields[i].AsString
         else
           S := S + ','+DBGrid1.Fields[i].AsString;
       end;
       Writeln(F,S);
       QryData.Next;
     end;

     MessageDlg('Export OK !!',mtCustom, [mbOK],0);
     CloseFile(F);
  end;
end;

procedure TfDetail.ModifyLog1Click(Sender: TObject);
Var S,S1 : String;
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;
  
  S := QryData.Fieldbyname('PART_ID').AsString;
  S1 := QryData.Fieldbyname('FACTORY_ID').AsString;
  With TfHistory.Create(Self) do
  begin
    QryData1.RemoteServer := Self.QryData.RemoteServer ;
    QryData1.ProviderName := 'DspQryData1';
    //editCode.Text := S;
    ShowHistory(S,S1) ;
    Showmodal;
    Free;
  end;
end;

end.
