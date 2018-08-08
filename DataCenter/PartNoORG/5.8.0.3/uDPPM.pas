unit uDPPM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, uData, Db, DBClient,
  MConnect, SConnect, FileCtrl, ObjBrkr, Menus;

type
  TfDPPM = class(TForm)
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
    Label1: TLabel;
    Editpartno: TEdit;
    procedure sbtnAppendClick(Sender: TObject);
    procedure sbtnModifyClick(Sender: TObject);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure FormShow(Sender: TObject);
    procedure sbtnDeleteClick(Sender: TObject);
    procedure sbtnDisabledClick(Sender: TObject);
    procedure cmbShowChange(Sender: TObject);
    procedure sbtnExportClick(Sender: TObject);
    procedure ModifyLog1Click(Sender: TObject);
    procedure EditpartnoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx : String;
    UpdateUserID : String;
    Authoritys,AuthorityRole : String;
    Procedure CopyToHistory(sFACTORYID,sPARTID : String);
    procedure showData;
    Procedure SetStatusbyAuthority;
  end;

var
  fDPPM: TfDPPM;

implementation

{$R *.DFM}

uses uHistory;

Procedure TfDPPM.SetStatusbyAuthority;
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
       Params.ParamByName('FUN').AsString :='Part ORG Define';
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

Procedure TfDPPM.CopyToHistory(sFACTORYID,sPARTID : String);
begin
  With QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'Part_ID', ptInput);
     Params.CreateParam(ftString	,'factory_ID', ptInput);
     CommandText := 'Insert Into SAJET.SYS_HT_PART_FACTORY '+
                      'Select * from SAJET.SYS_PART_FACTORY '+
                      'Where PART_ID = :PART_ID '+
                      'and FACTORY_ID = :FACTORY_ID ';
     Params.ParamByName('PART_ID').AsString := sPARTID;
     Params.ParamByName('FACTORY_ID').AsString := SFACTORYID;
     Execute;
  end;
end;

procedure TfDPPM.ShowData;
begin
  If cmbShow.ItemIndex <= 0 Then
     cmbShow.ItemIndex := 0;
  With QryData do
  begin
     Close;
     Params.CreateParam(ftString	,'Part_no', ptInput);
     CommandText := 'Select A.*, '+
                    ' B.PART_NO,C.FACTORY_CODE,D.WAREHOUSE_NAME,E.locate_name '+
                    'From SAJET.SYS_PART_FACTORY A '+
                    '    ,SAJET.SYS_PART B '+
                    '    ,SAJET.SYS_FACTORY C '+
                    '    ,SAJET.SYS_WAREHOUSE D '+
                    '    ,SAJET.SYS_LOCATE E '+
                    'Where b.part_no like :part_no '+
                    'and A.PART_ID = B.PART_ID '+
                    'and A.FACTORY_ID = C.FACTORY_ID '+
                    'and A.LOCATE_ID=E.LOCATE_ID(+) '+
                    'and D.WAREHOUSE_ID(+)=E.WAREHOUSE_ID '+
                    'and C.ENABLED = ''Y'' '+
                    'and B.ENABLED = ''Y'' '  ;
     If cmbShow.Text = 'Enabled' Then
       CommandText:= CommandText + 'And A.ENABLED = ''Y'' ';
     If cmbShow.Text = 'Disabled' Then
        CommandText:= CommandText + 'And A.ENABLED = ''N'' ';
     CommandText := CommandText + ' Order By '+Orderidx;
     Params.ParamByName('PART_no').AsString := editpartno.Text; 
     Open;
  end;
end;

procedure TfDPPM.sbtnAppendClick(Sender: TObject);
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

procedure TfDPPM.sbtnModifyClick(Sender: TObject);
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  With TfData.Create(Self) do
  begin
     MaintainType := 'Modify';
     Editpartno.Text := QryData.Fieldbyname('PART_NO').aSString;
     cmborg.ItemIndex := cmborg.Items.IndexOf(QryData.Fieldbyname('FACTORY_CODE').aSString);
     cmbstock.ItemIndex := cmbstock.Items.IndexOf(QryData.Fieldbyname('WAREHOUSE_NAME').aSString);
     cmblocate.ItemIndex := cmblocate.Items.IndexOf(QryData.Fieldbyname('locate_NAME').aSString);
     LabType1.Caption := LabType1.Caption + ' Modify';
     LabType2.Caption := LabType2.Caption + ' Modify';
     PARTID := QryData.Fieldbyname('PART_ID').aSString;
     FACTORYID := QryData.Fieldbyname('FACTORY_ID').aSString;
     editpartno.Enabled:=False;
     cmborg.Enabled:=False;
     If Showmodal = mrOK Then
       ShowData;
     Free;
  end;
end;

procedure TfDPPM.DBGrid1TitleClick(Column: TColumn);
begin
  OrderIdx:= Column.FieldName;
  ShowData;
end;

procedure TfDPPM.FormShow(Sender: TObject);
begin
  Orderidx := 'PART_NO';
  cmbShowChange(Self);
  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;
end;

procedure TfDPPM.sbtnDeleteClick(Sender: TObject);
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  If MessageDlg('Do you want to delete this data ?' + #13#10+
                'PART NO : ' + QryData.Fieldbyname('PART_NO').AsString +#13#10+
                'FACTORY CODE : ' + QryData.Fieldbyname('FACTORY_CODE').AsString +#13#10
                ,mtWarning, mbOKCancel,0) = mrOK Then
  begin
    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'ENABLED', ptInput);
      Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
      Params.CreateParam(ftString	,'PART_ID', ptInput);
      Params.CreateParam(ftString	,'FACTORY_ID', ptInput);
      CommandText := 'Update SAJET.SYS_PART_FACTORY '+
                     'Set ENABLED = :ENABLED, '+
                         'UPDATE_USERID = :UPDATE_USERID, '+
                         'UPDATE_TIME = SYSDATE '+
                     'Where PART_ID = :PART_ID '+
                     'and FACTORY_ID = :FACTORY_ID ';
      Params.ParamByName('ENABLED').AsString := 'D';
      Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
      Params.ParamByName('PART_ID').AsString := QryData.Fieldbyname('PART_ID').AsString;
      Params.ParamByName('FACTORY_ID').AsString := QryData.Fieldbyname('FACTORY_ID').AsString;
      Execute;
      CopyToHistory(QryData.Fieldbyname('FACTORY_ID').AsString,QryData.Fieldbyname('PART_ID').AsString);

      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'PART_ID', ptInput);
      Params.CreateParam(ftString	,'FACTORY_ID', ptInput);
      CommandText := 'Delete SAJET.SYS_PART_FACTORY '+
                     'Where PART_ID = :PART_ID '+
                     'and FACTORY_ID = :FACTORY_ID ';
      Params.ParamByName('PART_ID').AsString := QryData.Fieldbyname('PART_ID').AsString;
      Params.ParamByName('FACTORY_ID').AsString := QryData.Fieldbyname('FACTORY_ID').AsString;
      Execute;
      QryData.Delete;
    end;
  end;
end;

procedure TfDPPM.sbtnDisabledClick(Sender: TObject);
Var sStatus : String;
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  If QryData.Fieldbyname('ENABLED').AsString = 'Y' Then
  begin
    If MessageDlg('Do you want to disable this data ?' + #13#10+
                 'Part_no : ' + QryData.Fieldbyname('part_no').AsString +#13#10+
                 'ORG : '+ QryData.Fieldbyname('FACTORY_CODE').AsString +#13#10
                 ,mtWarning, mbOKCancel,0) <> mrOK Then
      Exit;
    sStatus := 'N';
  end Else
  begin
    If MessageDlg('Do you want to enable this data ?' + #13#10+
                  'Part_no : ' + QryData.Fieldbyname('part_no').AsString +#13#10+
                  'ORG : '+ QryData.Fieldbyname('FACTORY_CODE').AsString +#13#10
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
    Params.CreateParam(ftString	,'PART_ID', ptInput);
    Params.CreateParam(ftString	,'FACTORY_ID', ptInput);
    CommandText := 'Update SAJET.SYS_PART_FACTORY '+
                   'Set ENABLED = :ENABLED, '+
                       'UPDATE_USERID = :UPDATE_USERID, '+
                       'UPDATE_TIME =SYSDATE '+
                   'Where PART_ID = :PART_ID '+
                   'and FACTORY_ID = :FACTORY_ID ';
    Params.ParamByName('ENABLED').AsString := sStatus;
    Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
    Params.ParamByName('PART_ID').AsString := QryData.Fieldbyname('PART_ID').AsString;
    Params.ParamByName('FACTORY_ID').AsString := QryData.Fieldbyname('FACTORY_ID').AsString;
    Execute;
    CopyToHistory(QryData.Fieldbyname('FACTORY_ID').AsString,QryData.Fieldbyname('PART_ID').AsString);
    QryData.Delete;
  end;
end;

procedure TfDPPM.cmbShowChange(Sender: TObject);
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

procedure TfDPPM.sbtnExportClick(Sender: TObject);
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

procedure TfDPPM.ModifyLog1Click(Sender: TObject);
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

procedure TfDPPM.EditpartnoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if ord(key)=vk_return then
       ShowData;
end;

end.
