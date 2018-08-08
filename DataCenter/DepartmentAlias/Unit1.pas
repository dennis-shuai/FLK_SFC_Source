unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Grids, DBGrids, DB, DBClient, Menus,
  MConnect, SConnect, ObjBrkr;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    sbtnAppend: TSpeedButton;
    sbtnDelete: TSpeedButton;
    sbtnDisabled: TSpeedButton;
    sbtnExport: TSpeedButton;
    sbtnModify: TSpeedButton;
    Label4: TLabel;
    cmbShow: TComboBox;
    Image1: TImage;
    Image5: TImage;
    Image6: TImage;
    Image9: TImage;
    Image10: TImage;
    LabTitle1: TLabel;
    DBGrid1: TDBGrid;
    QryData: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    Sproc: TClientDataSet;
    PopupMenu1: TPopupMenu;
    Append1: TMenuItem;
    Modify1: TMenuItem;
    Disabled1: TMenuItem;
    Export1: TMenuItem;
    Delete1: TMenuItem;
    SaveDialog1: TSaveDialog;
    SimpleObjectBroker1: TSimpleObjectBroker;
    SocketConnection1: TSocketConnection;
    procedure sbtnExportClick(Sender: TObject);
    procedure sbtnAppendClick(Sender: TObject);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure cmbShowChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnModifyClick(Sender: TObject);
    procedure sbtnDisabledClick(Sender: TObject);
    procedure Append1Click(Sender: TObject);
    procedure Modify1Click(Sender: TObject);
    procedure sbtnDeleteClick(Sender: TObject);
    procedure Disabled1Click(Sender: TObject);
    procedure Export1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx : String;
    UpdateUserID : string;
    procedure ShowData;
    Procedure SetStatusbyAuthority;
    function LoadApServer : Boolean;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}
uses uData ;

Procedure TMainForm.SetStatusbyAuthority;
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
       Params.ParamByName('FUN').AsString :='EMP DEPT';
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

procedure TMainForm.ShowData;
begin
  If cmbShow.ItemIndex <= 0 Then
     cmbShow.ItemIndex := 0;
  With QryData do
  begin
     Close;
     CommandText := 'Select * '+
                    ' From SAJET.SYS_ALIAS ';
     If cmbShow.Text = 'Enabled' Then
       CommandText:= CommandText + 'WHERE ENABLED = ''Y'' ';
     If cmbShow.Text = 'Disabled' Then
        CommandText:= CommandText + 'WHERE ENABLED = ''N'' ';
     CommandText := CommandText + ' Order By '+Orderidx;
     Open;
  end;
end;

procedure TMainForm.sbtnExportClick(Sender: TObject);
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

procedure TMainForm.sbtnAppendClick(Sender: TObject);
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

procedure TMainForm.DBGrid1TitleClick(Column: TColumn);
begin
  OrderIdx:= Column.FieldName;
  ShowData;
end;

procedure TMainForm.cmbShowChange(Sender: TObject);
begin
  sbtnDisabled.Caption := 'Disabled';
  If cmbShow.Text = 'Disabled' Then
    sbtnDisabled.Caption := 'Enabled';
  Disabled1.Caption := sbtnDisabled.Caption;
  SbtnDelete.Visible := (cmbShow.Text = 'Disabled');
  ShowData;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Self.Left := Round((Screen.Width - Self.Width )/2);
  Self.Top := Round ((Screen.Height - Self.Height)/2);
  if not LoadApServer then MessageDlg('Load AP Server Error!!',mtError ,[mbyes],0) ;
  Orderidx := 'ALIAS_CODE';
  cmbShowChange(Self);
end;

function TMainForm.LoadApServer : Boolean;
var
  F : TextFile;
  S : String;
begin
  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  If not FileExists(GetCurrentDir+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,GetCurrentDir+'\ApServer.cfg');
  Reset(F);
  While not Eof(F) do
  begin
    Readln(F, S);
    If (S <> '') and (Length(S) >6)  Then
    begin
      SimpleObjectBroker1.Servers.Add;
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
    end Else
      Break;
  end;
  CloseFile(F);
  Result := True;
end;

procedure TMainForm.sbtnModifyClick(Sender: TObject);
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  With TfData.Create(Self) do
  begin
     MaintainType := 'Modify';
     editempname.Text :=QryData.Fieldbyname('ALIAS_NAME').aSString;
     cmbmodel.ItemIndex := cmbmodel.Items.IndexOf(QryData.Fieldbyname('ALIAS_CODE').aSString);
     LabType1.Caption := LabType1.Caption + ' Modify';
     LabType2.Caption := LabType2.Caption + ' Modify';
     cmbmodel.Enabled:=False;
     If Showmodal = mrOK Then
       ShowData;
     Free;
  end;
end;

procedure TMainForm.sbtnDisabledClick(Sender: TObject);
Var sStatus : String;
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  If QryData.Fieldbyname('ENABLED').AsString = 'Y' Then
  begin
    If MessageDlg('Do you want to disable this data ?' + #13#10+
                 'Alias Code : ' + QryData.Fieldbyname('ALIAS_CODE').AsString +#13#10+
                 'Alias Name : '+ QryData.Fieldbyname('ALIAS_NAME').AsString +#13#10
                 ,mtWarning, mbOKCancel,0) <> mrOK Then
      Exit;
    sStatus := 'N';
  end Else
  begin
    If MessageDlg('Do you want to enable this data ?' + #13#10+
                 'Alias Code : ' + QryData.Fieldbyname('ALIAS_CODE').AsString +#13#10+
                 'Alias Name : '+ QryData.Fieldbyname('ALIAS_NAME').AsString +#13#10
                 ,mtWarning, mbOKCancel,0) <> mrOK Then
      Exit;
    sStatus := 'Y';
  end;

  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'ENABLED', ptInput);
    Params.CreateParam(ftString	,'ALIAS_CODE', ptInput);
    Params.CreateParam(ftString	,'ALIAS_NAME', ptInput);
    CommandText := 'Update SAJET.SYS_ALIAS '+
                   'Set ENABLED = :ENABLED '+
                   'Where ALIAS_CODE = :ALIAS_CODE '+
                   'and ALIAS_NAME = :ALIAS_NAME ';
    Params.ParamByName('ENABLED').AsString := sStatus;
    Params.ParamByName('ALIAS_CODE').AsString := QryData.Fieldbyname('ALIAS_CODE').AsString;
    Params.ParamByName('ALIAS_NAME').AsString := QryData.Fieldbyname('ALIAS_NAME').AsString;
    Execute;
    QryData.Delete;
  end;
end;

procedure TMainForm.Append1Click(Sender: TObject);
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

procedure TMainForm.Modify1Click(Sender: TObject);
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  With TfData.Create(Self) do
  begin
     MaintainType := 'Modify';
     editempname.Text :=QryData.Fieldbyname('ALIAS_NAME').aSString;
     cmbmodel.ItemIndex := cmbmodel.Items.IndexOf(QryData.Fieldbyname('ALIAS_CODE').aSString);
     LabType1.Caption := LabType1.Caption + ' Modify';
     LabType2.Caption := LabType2.Caption + ' Modify';
     cmbmodel.Enabled:=False;
     If Showmodal = mrOK Then
       ShowData;
     Free;
  end;
end;

procedure TMainForm.sbtnDeleteClick(Sender: TObject);
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  If MessageDlg('Do you want to delete this data ?' + #13#10+
                'Alias CODE : ' + QryData.Fieldbyname('ALIAS_CODE').AsString +#13#10+
                'Alias Name : ' + QryData.Fieldbyname('ALIAS_NAME').AsString +#13#10
               , mtWarning, mbOKCancel,0) = mrOK Then
  begin
    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'ALIAS_CODE', ptInput);
      Params.CreateParam(ftString	,'ALIAS_NAME', ptInput);
      CommandText := 'Delete SAJET.SYS_ALIAS '+
                     'Where ALIAS_CODE = :ALIAS_CODE '+
                     'and ALIAS_NAME = :ALIAS_NAME ';
      Params.ParamByName('ALIAS_CODE').AsString := QryData.Fieldbyname('ALIAS_CODE').AsString;
      Params.ParamByName('ALIAS_NAME').AsString := QryData.Fieldbyname('ALIAS_NAME').AsString;
      Execute;
      QryData.Delete;
    end;
  end;
end;

procedure TMainForm.Disabled1Click(Sender: TObject);
Var sStatus : String;
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  If QryData.Fieldbyname('ENABLED').AsString = 'Y' Then
  begin
    If MessageDlg('Do you want to disable this data ?' + #13#10+
                 'Alias Code : ' + QryData.Fieldbyname('ALIAS_CODE').AsString +#13#10+
                 'Alias Name : '+ QryData.Fieldbyname('ALIAS_NAME').AsString +#13#10
                 ,mtWarning, mbOKCancel,0) <> mrOK Then
      Exit;
    sStatus := 'N';
  end Else
  begin
    If MessageDlg('Do you want to enable this data ?' + #13#10+
                 'Alias Code : ' + QryData.Fieldbyname('ALIAS_CODE').AsString +#13#10+
                 'Alias Name : '+ QryData.Fieldbyname('ALIAS_NAME').AsString +#13#10
                 ,mtWarning, mbOKCancel,0) <> mrOK Then
      Exit;
    sStatus := 'Y';
  end;

  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'ENABLED', ptInput);
    Params.CreateParam(ftString	,'ALIAS_CODE', ptInput);
    Params.CreateParam(ftString	,'ALIAS_NAME', ptInput);
    CommandText := 'Update SAJET.SYS_ALIAS '+
                   'Set ENABLED = :ENABLED '+
                   'Where ALIAS_CODE = :ALIAS_CODE '+
                   'and ALIAS_NAME = :ALIAS_NAME ';
    Params.ParamByName('ENABLED').AsString := sStatus;
    Params.ParamByName('ALIAS_CODE').AsString := QryData.Fieldbyname('ALIAS_CODE').AsString;
    Params.ParamByName('ALIAS_NAME').AsString := QryData.Fieldbyname('ALIAS_NAME').AsString;
    Execute;
    QryData.Delete;
  end;
end;

procedure TMainForm.Export1Click(Sender: TObject);
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

procedure TMainForm.Delete1Click(Sender: TObject);
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  If MessageDlg('Do you want to delete this data ?' + #13#10+
                'Alias CODE : ' + QryData.Fieldbyname('ALIAS_CODE').AsString +#13#10+
                'Alias Name : ' + QryData.Fieldbyname('ALIAS_NAME').AsString +#13#10
               , mtWarning, mbOKCancel,0) = mrOK Then
  begin
    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'ALIAS_CODE', ptInput);
      Params.CreateParam(ftString	,'ALIAS_NAME', ptInput);
      CommandText := 'Delete SAJET.SYS_ALIAS '+
                     'Where ALIAS_CODE = :ALIAS_CODE '+
                     'and ALIAS_NAME = :ALIAS_NAME ';
      Params.ParamByName('ALIAS_CODE').AsString := QryData.Fieldbyname('ALIAS_CODE').AsString;
      Params.ParamByName('ALIAS_NAME').AsString := QryData.Fieldbyname('ALIAS_NAME').AsString;
      Execute;
      QryData.Delete;
    end;
  end;
end;

end.
