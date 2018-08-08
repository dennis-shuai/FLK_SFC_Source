unit uformMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, Buttons, StdCtrls, DB, DBClient, ExtCtrls,
  ComCtrls, Menus;

type
  TformMain = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    QryData: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    Image2: TImage;
    Image3: TImage;
    ImgDisable: TImage;
    Image7: TImage;
    ImgDelete: TImage;
    Label4: TLabel;
    cmbShow: TComboBox;
    Label1: TLabel;
    sbtnAppend: TSpeedButton;
    sbtnModify: TSpeedButton;
    sbtnDisabled: TSpeedButton;
    sbtnExport: TSpeedButton;
    sbtnDelete: TSpeedButton;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    qryData1: TClientDataSet;
    dsrcData1: TDataSource;
    sproc: TClientDataSet;
    PopupMenu1: TPopupMenu;
    Append1: TMenuItem;
    Modify1: TMenuItem;
    Disabled1: TMenuItem;
    Export1: TMenuItem;
    Delete1: TMenuItem;
    ModifyLog1: TMenuItem;
    SaveDialog1: TSaveDialog;
    procedure FormShow(Sender: TObject);
    procedure sbtnAppendClick(Sender: TObject);
    procedure sbtnModifyClick(Sender: TObject);
    procedure QryDataAfterScroll(DataSet: TDataSet);
    procedure QryDataBeforeOpen(DataSet: TDataSet);
    procedure sbtnDeleteClick(Sender: TObject);
    procedure sbtnDisabledClick(Sender: TObject);
    procedure cmbShowChange(Sender: TObject);
    procedure sbtnExportClick(Sender: TObject);
    procedure ModifyLog1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     UpdateUserID: string;
     Authoritys,AuthorityRole : String;
     Procedure ShowToolingType;
     Procedure CopyToHistory(RecordID : String);
     Procedure SetStatusbyAuthority;
     procedure showData;     
  end;

var
  formMain: TformMain;


implementation

uses uData,uHistory;
{$R *.dfm}
Procedure TformMain.SetStatusbyAuthority;
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
       Params.ParamByName('FUN').AsString :='Tooling SN Define';
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

  sbtnModify.Enabled := (iPrivilege >=2);
  Modify1.Enabled := sbtnModify.Enabled;

  sbtnDisabled.Enabled := (iPrivilege >=2);
  Disabled1.Enabled := sbtnDisabled.Enabled;

  sbtnDelete.Enabled := (iPrivilege >=2);
  Delete1.Enabled := sbtnDelete.Enabled;
end;

procedure TformMain.FormShow(Sender: TObject);
begin
  ShowToolingType;
  SbtnDelete.Visible := (cmbShow.Text = 'Disabled');
  ImgDelete.Visible := SbtnDelete.Visible;
  IF UpdateUserID <> '0' Then
    SetStatusbyAuthority;  

end;
Procedure TformMain.ShowToolingType;
begin
  With qryData do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select *  '+
                   'From SAJET.SYS_TOOLING '+
                   'Where ENABLED = ''Y'' '+
                   'Order By TOOLING_NO ';
    Open;
  end;
end;

procedure TformMain.sbtnAppendClick(Sender: TObject);
begin
  if (not QryData.Active) or (QryData.Eof) then exit;

  With TfData.Create(Self) do
  begin
     MaintainType := 'Append';
     LabType1.Caption := LabType1.Caption + ' Append';
     LabType2.Caption := LabType2.Caption + ' Append';
     LabToolNo.Caption :=QryData.FieldByName('TOOLING_NO').AsString;
     LabToolName.Caption :=QryData.FieldByName('TOOLING_Name').AsString;
     LabToolID.Caption :=QryData.FieldByName('TOOLING_ID').AsString;
     
     If Showmodal = mrOK Then
        ShowData;
     Free;
  end;
end;
procedure TformMain.ShowData;
begin
  If cmbShow.ItemIndex <= 0 Then
     cmbShow.ItemIndex := 0;
  With QryData1 do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'TOOLING_ID', ptInput);
     CommandText := 'Select A.TOOLING_SN_ID,A.TOOLING_SN,A.ENABLED '
                  + ' From SAJET.SYS_TOOLING_SN A '
                  + ' Where A.TOOLING_ID =:TOOLING_ID ';

     If cmbShow.Text = 'Enabled' Then
        CommandText := CommandText+ 'and A.ENABLED = ''Y'' ';
     If cmbShow.Text = 'Disabled' Then
        CommandText := CommandText+'and A.ENABLED = ''N'' ';
     CommandText := CommandText +'  order by A.Tooling_SN ';
                  
     Params.ParamByName('TOOLING_ID').AsString := QryData.FieldByName('Tooling_id').AsString;
     Open;
  end;
end;

Procedure TformMain.CopyToHistory(RecordID : String);
begin
  With QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'TOOLING_SN_ID', ptInput);
     CommandText := 'Insert Into SAJET.SYS_HT_TOOLING_SN '+
                      'Select * from SAJET.SYS_TOOLING_SN '+
                      'Where TOOLING_SN_ID = :TOOLING_SN_ID ';
     Params.ParamByName('TOOLING_SN_ID').AsString := RecordID;
     Execute;
  end;
end;

procedure TformMain.sbtnModifyClick(Sender: TObject);
begin
{  If QryData1.Eof Then
  begin
     MessageDlg('Data not assign !!',mtWarning, [mbOK],0);
     Exit;
  end;
}

  if (not QryData1.active) or (QryData1.IsEmpty) then
    exit;

  With TfData.Create(Self) do
  begin
     MaintainType := 'Modify';
     LabToolNo.Caption := QryData.Fieldbyname('TOOLING_NO').aSString;
     LabToolName.Caption := QryData.Fieldbyname('TOOLING_NAME').aSString;
     LabToolID.Caption :=QryData.FieldByName('TOOLING_ID').AsString;

     editToolSN.Text := QryData1.Fieldbyname('TOOLING_SN').aSString;

     LabType1.Caption := LabType1.Caption + ' Modify';
     LabType2.Caption := LabType2.Caption + ' Modify'; 

     TOOLID := QryData1.Fieldbyname('TOOLING_SN_ID').aSString;
     If Showmodal = mrOK Then
        ShowData;
     Free;
  end;
end;

procedure TformMain.QryDataAfterScroll(DataSet: TDataSet);
begin
  showData;
end;

procedure TformMain.QryDataBeforeOpen(DataSet: TDataSet);
begin
  qryData1.Close;
end;

procedure TformMain.sbtnDeleteClick(Sender: TObject);
begin
{  If (not QryData1.Active) or (qryData1.Eof) Then
  begin
     MessageDlg('Data not assign !!',mtCustom, [mbOK],0);
     Exit;
  end;
}
  if (not QryData1.active) or (QryData1.IsEmpty) then
    exit;

  If MessageDlg('Do you want to delete this data ?' + #13#10+
                'Tooling SN : ' + QryData1.Fieldbyname('TOOLING_SN').AsString,mtWarning, mbOKCancel,0) = mrOK Then
  begin
     With formMain.SProc do
     begin
       Try
          Close;
          DataRequest('SAJET.SJ_TOOLING_SN_DELETE');
          FetchParams;
          Params.ParamByName('T_TOOLING_SN_ID').AsString := QryData1.Fieldbyname('TOOLING_SN_ID').AsString;
          Params.ParamByName('T_EMP_ID').AsString := formMain.UpdateUserID;
          Execute;

          if Params.ParamByName('TRES').AsString <>'OK' then
          begin
            MessageDlg(Params.ParamByName('TRES').AsString ,mtError, [mbCancel],0);
            Exit;
          end else
            QryData1.Delete;
        finally
         close;
        end;
     end;//end sproc
  end;
end;

procedure TformMain.sbtnDisabledClick(Sender: TObject);
VAR sStatus:String;
begin
{  If (not QryData1.Active) or (qryData1.Eof) Then
  begin
     MessageDlg('Data not assign !!',mtCustom, [mbOK],0);
     Exit;
  end;
}
  if (not QryData1.active) or (QryData1.IsEmpty) then
    exit;

  If QryData1.Fieldbyname('ENABLED').AsString = 'Y' Then
  begin
    If MessageDlg('Do you want to disable this data ?' + #13#10+
                  'Tooling SN : ' + QryData1.Fieldbyname('TOOLING_SN').AsString,mtWarning, mbOKCancel,0) <> mrOK Then
      Exit;
      sStatus := 'N';
  end Else
  begin
    If MessageDlg('Do you want to enable this data ?' + #13#10+
                  'Tooling SN : ' + QryData1.Fieldbyname('TOOLING_SN').AsString,mtWarning, mbOKCancel,0) <> mrOK Then
      Exit;
      sStatus := 'Y';
  end;

  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'ENABLED', ptInput);
    Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
    Params.CreateParam(ftString	,'TOOLING_SN_ID', ptInput);
    CommandText := 'Update SAJET.SYS_TOOLING_SN '+
                   'Set ENABLED = :ENABLED, '+
                       'UPDATE_USERID = :UPDATE_USERID, '+
                       'UPDATE_TIME = SYSDATE '+
                   'Where TOOLING_SN_ID = :TOOLING_SN_ID ';
    Params.ParamByName('ENABLED').AsString := sStatus;
    Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
    Params.ParamByName('TOOLING_SN_ID').AsString := QryData1.Fieldbyname('TOOLING_SN_ID').AsString;
    Execute;
    CopyToHistory(QryData1.Fieldbyname('TOOLING_SN_ID').AsString);
    QryData1.Delete;
  end;

end;

procedure TformMain.cmbShowChange(Sender: TObject);
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

procedure TformMain.sbtnExportClick(Sender: TObject);
Var F : TextFile;
    S : String;
begin
  if (not QryData1.active) or (QryData1.IsEmpty) then
    exit;

  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'csv';
  SaveDialog1.Filter := 'All Files(*.csv)|*.csv';
  If SaveDialog1.Execute Then
  begin
     AssignFile(F,SaveDialog1.FileName);
     Rewrite(F);
     QryData.First ;
     While not QryData.Eof do
     begin
        S := QryData.Fieldbyname('TOOLING_NO').AsString + ',' +
             QryData1.Fieldbyname('TOOLING_SN').AsString ;
        Writeln(F,S);
        QryData.Next;
     end;
     MessageDlg('Export OK !!',mtCustom, [mbOK],0);
     CloseFile(F);
  end;
end;

procedure TformMain.ModifyLog1Click(Sender: TObject);
Var S,S1 : String;
begin
{  If (not QryData1.Active) or (QryData1.Eof) Then
  begin
     MessageDlg('Data not assign !!',mtCustom, [mbOK],0);
     Exit;
  end;
}

  if (not QryData1.active) or (QryData1.IsEmpty) then
    exit;

  S := QryData1.Fieldbyname('Tooling_SN').AsString;
  S1 := QryData1.Fieldbyname('Tooling_SN_ID').AsString;
  With TfHistory.Create(Self) do
  begin
    QryData1.RemoteServer := Self.QryData.RemoteServer ;
    QryData1.ProviderName := 'DspQryData1';
    editCode.Text := S;
    ShowHistory(S) ;
    Showmodal;
    Free;
  end;
end;

end.
