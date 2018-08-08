unit uLocate;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, uData, Db, DBClient,
  MConnect, SConnect, ObjBrkr, Menus;

type
  TfLocate = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    Image2: TImage;
    Image3: TImage;
    ImgDelete: TImage;
    LabTitle2: TLabel;
    Image7: TImage;
    ImgDisable: TImage;
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
    editSearch: TEdit;
    Label1: TLabel;
    cmbType: TComboBox;
    Sproc: TClientDataSet;
    procedure sbtnAppendClick(Sender: TObject);
    procedure sbtnModifyClick(Sender: TObject);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure FormShow(Sender: TObject);
    procedure sbtnDeleteClick(Sender: TObject);
    procedure sbtnDisabledClick(Sender: TObject);
    procedure cmbShowChange(Sender: TObject);
    procedure sbtnExportClick(Sender: TObject);
    procedure cmbTypeChange(Sender: TObject);
    procedure editSearchChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx : String;
    UpdateUserID : String;
    Authoritys, AuthorityRole : String;
    procedure showData;
    procedure CopyToHistory(RecordID : String);
    procedure SetStatusbyAuthority;
  end;

var
  fLocate: TfLocate;

implementation

{$R *.DFM}

procedure TfLocate.SetStatusbyAuthority;
var
  iPrivilege : Integer;
begin
  iPrivilege := 0;
  with Sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Data Center';
      Params.ParamByName('FUN').AsString := 'Warehouse Define';
      Execute;
      if Params.ParamByName('TRES').AsString = 'OK' Then
      begin
       iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      Close;
    end;
  end;
  sbtnAppend.Enabled := (iPrivilege >=1); //allow change;full control
  Append1.Enabled := sbtnAppend.Enabled;

  sbtnModify.Enabled := (iPrivilege >=1);
  Modify1.Enabled := sbtnModify.Enabled;

  sbtnDisabled.Enabled := (iPrivilege >=1);
  Disabled1.Enabled := sbtnDisabled.Enabled;
  
  sbtnDelete.Enabled := (iPrivilege >=2); //full control
  Delete1.Enabled := sbtnDelete.Enabled;
end;

procedure TfLocate.DBGrid1TitleClick(Column: TColumn);
begin
  OrderIdx := Column.FieldName;
  ShowData;
end;

procedure TfLocate.ShowData;
begin
  if cmbShow.ItemIndex <= 0 then
     cmbShow.ItemIndex := 0;
  with QryData do
  begin
     Close;
     CommandText := 'SELECT WAREHOUSE_ID, WAREHOUSE_NAME, WAREHOUSE_DESC, ENABLED '+
                    '  FROM SAJET.SYS_WAREHOUSE ';
     if cmbShow.Text = 'Enabled' Then
       CommandText:= CommandText + ' WHERE ENABLED = ''Y'' ';
     if cmbShow.Text = 'Disabled' Then
       CommandText:= CommandText + ' WHERE ENABLED = ''N'' ';
     CommandText := CommandText + ' ORDER BY ' + Orderidx;
     Open;
  end;
end;

procedure TfLocate.FormShow(Sender: TObject);
begin
  Orderidx := 'WAREHOUSE_NAME';
  cmbType.ItemIndex := 0;
  cmbShowChange(Self);
  if UpdateUserID <> '0' then
    SetStatusbyAuthority;
end;

procedure TfLocate.cmbShowChange(Sender: TObject);
begin
  sbtnDisabled.Caption := 'Disabled';
  if cmbShow.Text = 'Disabled' Then
    sbtnDisabled.Caption := 'Enabled';
  Disabled1.Caption := sbtnDisabled.Caption;
  SbtnDelete.Visible := (cmbShow.Text = 'Disabled');
  ImgDelete.Visible := SbtnDelete.Visible;
  Delete1.Visible := SbtnDelete.Visible;
  ShowData;
end;

procedure TfLocate.cmbTypeChange(Sender: TObject);
begin
  case cmbType.ItemIndex of
    0 : OrderIdx := 'WAREHOUSE_NAME';
    1 : OrderIdx := 'WAREHOUSE_DESC';
  end;
  ShowData;
end;

procedure TfLocate.editSearchChange(Sender: TObject);
begin
  if not QryData.Active then
    Exit;
  case cmbType.ItemIndex of
    0 : QryData.Locate('WAREHOUSE_NAME', Trim(editSearch.Text), [loCaseInsensitive, loPartialKey]);
    1 : QryData.Locate('WAREHOUSE_DESC', Trim(editSearch.Text), [loCaseInsensitive, loPartialKey]);
  end;
end;

procedure TfLocate.sbtnAppendClick(Sender: TObject);
begin
  with TfData.Create(Self) do
  begin
     MaintainType := 'Append';

     LabType1.Caption := LabType1.Caption + ' Append';
     LabType2.Caption := LabType2.Caption + ' Append';
     if ShowModal = mrOK then
        ShowData;
     Free;
  end;
end;

procedure TfLocate.sbtnModifyClick(Sender: TObject);
begin
  If QryData.RecordCount = 0 Then
  begin
     MessageDlg('Data not assign !!',mtCustom, [mbOK],0);
     Exit;
  end;

  with TfData.Create(Self) do
  begin
     MaintainType := 'Modify';
     
     editWHName.Text := QryData.Fieldbyname('WAREHOUSE_NAME').aSString;
     editWHDesc.Text := QryData.Fieldbyname('WAREHOUSE_DESC').aSString;
     LabType1.Caption := LabType1.Caption + ' Modify';
     LabType2.Caption := LabType2.Caption + ' Modify';
     WHID := QryData.Fieldbyname('WAREHOUSE_ID').aSString;

     if ShowModal = mrOK then
        ShowData;
     Free;
  end;
end;

procedure TfLocate.sbtnDisabledClick(Sender: TObject);
var
  sStatus : String;
begin
  if QryData.RecordCount = 0 then
  begin
     MessageDlg('Data not assign !!',mtCustom, [mbOK],0);
     Exit;
  end;

  if QryData.Fieldbyname('ENABLED').AsString = 'Y' then
  begin
    if MessageDlg('Do you want to disable this data ?' + #13#10 +
                  'Warehouse Name : '+ QryData.Fieldbyname('WAREHOUSE_NAME').AsString + #13#10 +
                  'Warehouse Desc : ' + QryData.Fieldbyname('WAREHOUSE_DESC').AsString, mtWarning, mbOKCancel, 0) <> mrOK then
    Exit;
    sStatus := 'N';
  end else
  begin
    if MessageDlg('Do you want to enable this data ?' + #13#10 +
                  'Warehouse Name : '+ QryData.Fieldbyname('WAREHOUSE_NAME').AsString + #13#10 +
                  'Warehouse Desc : ' + QryData.Fieldbyname('WAREHOUSE_DESC').AsString, mtWarning, mbOKCancel, 0) <> mrOK then
    Exit;
    sStatus := 'Y';
  end;

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'ENABLED', ptInput);
    Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
    Params.CreateParam(ftString	,'WAREHOUSE_ID', ptInput);
    CommandText := 'UPDATE SAJET.SYS_WAREHOUSE '+
                   '   SET ENABLED = :ENABLED, '+
                   '       UPDATE_USERID = :UPDATE_USERID, '+
                   '       UPDATE_TIME = SYSDATE '+
                   ' WHERE WAREHOUSE_ID = :WAREHOUSE_ID ';
    Params.ParamByName('ENABLED').AsString := sStatus;
    Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
    Params.ParamByName('WAREHOUSE_ID').AsString := QryData.Fieldbyname('WAREHOUSE_ID').AsString;
    Execute;
    QryData.Delete;
  end;
end;

procedure TfLocate.sbtnDeleteClick(Sender: TObject);
begin
  if QryData.RecordCount = 0 then
  begin
     MessageDlg('Data not assign !!',mtCustom, [mbOK],0);
     Exit;
  end;

  if MessageDlg('Do you want to delete this data ?' + #13#10+
                'Warehouse Name : '+ QryData.Fieldbyname('WAREHOUSE_NAME').AsString + #13#10 +
                'Warehouse Desc : ' + QryData.Fieldbyname('WAREHOUSE_DESC').AsString, mtWarning, mbOKCancel, 0) = mrOK then

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WAREHOUSE_ID', ptInput);
    CommandText := 'DELETE SAJET.SYS_WAREHOUSE '+
                   ' WHERE WAREHOUSE_ID = :WAREHOUSE_ID ';
    Params.ParamByName('WAREHOUSE_ID').AsString := QryData.Fieldbyname('WAREHOUSE_ID').AsString;
    Execute;
    QryData.Delete;
  end;
end;

procedure TfLocate.sbtnExportClick(Sender: TObject);
var
  F : TextFile;
  S : String;
begin
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'csv';
  SaveDialog1.Filter := 'All Files(*.csv)|*.csv';
  if SaveDialog1.Execute then
  begin
     AssignFile(F,SaveDialog1.FileName);
     Rewrite(F);
     QryData.First ;
     while not QryData.Eof do
     begin
        S := QryData.Fieldbyname('WAREHOUSE_NAME').AsString + ',' +
             QryData.Fieldbyname('WAREHOUSE_DESC').AsString;
        Writeln(F,S);
        QryData.Next;
     end;
     MessageDlg('Export OK !!', mtCustom, [mbOK], 0);
     CloseFile(F);
  end;
end;
     
procedure TfLocate.CopyToHistory(RecordID : String);
begin
  with QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'WAREHOUSE_ID', ptInput);
     CommandText := 'INSERT INTO SAJET.SYS_HT_WAREHOUSE '+
                    'SELECT * from SAJET.SYS_WAREHOUSE '+
                    ' WHERE WAREHOUSE_ID = :WAREHOUSE_ID ';
     Params.ParamByName('WAREHOUSE_ID').AsString := RecordID;
     Execute;
  end;
end;

end.
