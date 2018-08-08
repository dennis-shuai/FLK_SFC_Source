unit uFormMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, uData, Db, DBClient,
  MConnect, SConnect,  ObjBrkr, Menus, MidasLib ;

type
  TFormMain = class(TForm)
    Panel1: TPanel;
    DBGrid1: TDBGrid;
    QryData: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    PopupMenu1: TPopupMenu;
    Append1: TMenuItem;
    Modify1: TMenuItem;
    Disabled1: TMenuItem;
    Export1: TMenuItem;
    Delete1: TMenuItem;
    ModifyLog1: TMenuItem;
    Sproc: TClientDataSet;
    sbtnModify: TSpeedButton;
    sbtnExport: TSpeedButton;
    sbtnDisabled: TSpeedButton;
    sbtnDelete: TSpeedButton;
    sbtnAppend: TSpeedButton;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    Label4: TLabel;
    ImgDelete: TImage;
    ImageAll: TImage;
    Image8: TImage;
    Image7: TImage;
    Image3: TImage;
    Image2: TImage;
    cmbShow: TComboBox;
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
    UpdateUserID : String;
    Authoritys,AuthorityRole : String;
    Procedure CopyToHistory(sLineID,sProcessID : String);
    procedure showData;
    Procedure SetStatusbyAuthority;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.DFM}

uses uHistory;

Procedure TFormMain.SetStatusbyAuthority;
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
       Params.ParamByName('FUN').AsString :='LCD Monitor Define';
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

Procedure TFormMain.CopyToHistory(sLineID,sProcessID : String);
begin
  With QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'PROCESS_ID', ptInput);
     Params.CreateParam(ftString	,'PDLINE_ID', ptInput);
     CommandText := 'Insert Into SAJET.SYS_HT_PROCESS_RATE '+
                      'Select * from SAJET.SYS_PROCESS_RATE '+
                      'Where PROCESS_ID = :PROCESS_ID '+
                      'and PDLINE_ID = :PDLINE_ID ';
     Params.ParamByName('PROCESS_ID').AsString := sProcessID;
     Params.ParamByName('PDLINE_ID').AsString := sLineID;
     Execute;
  end;
end;

procedure TFormMain.ShowData;
begin
  If cmbShow.ItemIndex <= 0 Then
     cmbShow.ItemIndex := 0;
  With QryData do
  begin
     Close;
     {CommandText := 'Select A.*, '+
                    ' B.PROCESS_NAME,D.PDLINE_NAME '+
                    'From SAJET.SYS_PROCESS_RATE A '+
                    '    ,SAJET.SYS_PROCESS B '+
                    '    ,SAJET.SYS_STAGE C '+
                    '    ,SAJET.SYS_PDLINE D '+
                    'Where A.PROCESS_ID = B.PROCESS_ID '+
                    'and B.STAGE_ID = C.STAGE_ID '+
                    'and A.PDLINE_ID = D.PDLINE_ID '+
                    'and C.ENABLED = ''Y'' '+
                    'and B.ENABLED = ''Y'' '+
                    'and D.ENABLED = ''Y'' ';}
     {CommandText := 'SELECT A.*, '+
                    ' B.PART_NO,NVL(C.MODEL_NAME,B.PART_NO) AS MODEL_NAME,  '+
                    ' D.SHIFT_ID,D.SHIFT_NAME,D.START_TIME,D.END_TIME    ' +
                    ' FROM SAJET.SYS_MODEL_MONITOR_BASE A,  '+
                    '  SAJET.SYS_PART B, SAJET.SYS_MODEL C, SAJET.SYS_SHIFT D  '+
                    ' WHERE  A.MODEL_ID =B.PART_ID  AND  B.MODEL_ID=C.MODEL_ID(+)   '+
                    ' AND A.SHIFT_ID = D.SHIFT_ID  AND D.ENABLED = ''Y''  ' ;}
     CommandText := 'SELECT A.*,C.MODEL_NAME, '+
                    ' D.SHIFT_ID,D.SHIFT_NAME,D.START_TIME,D.END_TIME    ' +
                    ' FROM SAJET.SYS_MODEL_MONITOR_BASE A,  '+
                    '  SAJET.SYS_MODEL C, SAJET.SYS_SHIFT D  '+
                    ' WHERE  A.MODEL_ID =C.MODEL_ID   '+
                    ' AND A.SHIFT_ID = D.SHIFT_ID  AND D.ENABLED = ''Y''  ' ;
     If cmbShow.Text = 'Enabled' Then
       CommandText:= CommandText + 'And A.ENABLED = ''Y'' ';
     If cmbShow.Text = 'Disabled' Then
        CommandText:= CommandText + 'And A.ENABLED = ''N'' ';
     CommandText := CommandText + ' Order By '+Orderidx;
     Open;
  end;
end;

procedure TFormMain.sbtnAppendClick(Sender: TObject);
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

procedure TFormMain.sbtnModifyClick(Sender: TObject);
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  With TfData.Create(Self) do
  begin
     MaintainType := 'Modify';
     editPart.Text := QryData.Fieldbyname('MODEL_NAME').aSString;
     //LabName.Caption := QryData.Fieldbyname('MODEL_NAME').aSString;
     EditTarget.Text := QryData.Fieldbyname('Target_QTY').aSString;
     EditRemark.Text := QryData.Fieldbyname('Remark').aSString;
     ModelID := QryData.Fieldbyname('MODEL_ID').aSString;
     CmbShift.ItemIndex := CmbShift.Items.IndexOf(QryData.Fieldbyname('SHIFT_NAME').aSString) ;
     CmbShiftChange(self);
     LabType1.Caption := LabType1.Caption + ' Modify';
     LabType2.Caption := LabType2.Caption + ' Modify';
     editPart.Enabled:=False;
     //cmbLine.Enabled:=False;
     If Showmodal = mrOK Then
       ShowData;
     Free;
  end;
end;

procedure TFormMain.DBGrid1TitleClick(Column: TColumn);
begin
  OrderIdx:= Column.FieldName;
  ShowData;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  Orderidx := 'MODEL_NAME';
  cmbShowChange(Self);
  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;
end;

procedure TFormMain.sbtnDeleteClick(Sender: TObject);
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  If MessageDlg('Do you want to delete this data ?' + #13#10+
                'Model Name : ' + QryData.Fieldbyname('MODEL_NAME').AsString +#13#10+
                'Shift : ' + QryData.Fieldbyname('SHIFT_NAME').AsString +#13#10+
                'Target   : ' + QryData.Fieldbyname('TARGET_QTY').AsString +#13#10+
                'Remark: ' + QryData.Fieldbyname('REMARK').AsString
                ,mtWarning, mbOKCancel,0) = mrOK Then
  begin
    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'ENABLED', ptInput);
      Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
      Params.CreateParam(ftString	,'MODEL_ID', ptInput);
      Params.CreateParam(ftString	,'SHIFT_ID', ptInput);
      CommandText := 'Update SAJET.SYS_MODEL_MONITOR_BASE '+
                     'Set ENABLED = :ENABLED, '+
                         'UPDATE_USERID = :UPDATE_USERID '+
                     'Where MODEL_ID = :MODEL_ID '+
                     'and SHIFT_ID = :SHIFT_ID ';
      Params.ParamByName('ENABLED').AsString := 'Drop';
      Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
      Params.ParamByName('MODEL_ID').AsString := QryData.Fieldbyname('MODEL_ID').AsString;
      Params.ParamByName('SHIFT_ID').AsString := QryData.Fieldbyname('SHIFT_ID').AsString;
      Execute;
      //CopyToHistory(QryData.Fieldbyname('PDLINE_ID').AsString,QryData.Fieldbyname('PROCESS_ID').AsString);

      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'MODEL_ID', ptInput);
      Params.CreateParam(ftString	,'SHIFT_ID', ptInput);
      CommandText := 'Delete SAJET.SYS_MODEL_MONITOR_BASE '+
                     'Where MODEL_ID = :MODEL_ID '+
                     'and SHIFT_ID = :SHIFT_ID ';
      Params.ParamByName('MODEL_ID').AsString := QryData.Fieldbyname('MODEL_ID').AsString;
      Params.ParamByName('SHIFT_ID').AsString := QryData.Fieldbyname('SHIFT_ID').AsString;
      Execute;
      QryData.Delete;
    end;
  end;
end;

procedure TFormMain.sbtnDisabledClick(Sender: TObject);
Var sStatus : String;
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  If QryData.Fieldbyname('ENABLED').AsString = 'Y' Then
  begin
    If MessageDlg('Do you want to disable this data ?' + #13#10+
                 'Model Name : ' + QryData.Fieldbyname('MODEL_NAME').AsString +#13#10+
                 'Shift : '+ QryData.Fieldbyname('SHIFT_NAME').AsString +#13#10+
                 'Target : ' + QryData.Fieldbyname('TARGET_QTY').AsString +#13#10+
                 'Remark: ' + QryData.Fieldbyname('REMARK').AsString
                 ,mtWarning, mbOKCancel,0) <> mrOK Then
      Exit;
    sStatus := 'N';
  end Else
  begin
    If MessageDlg('Do you want to enable this data ?' + #13#10+
                 'Model Name : ' + QryData.Fieldbyname('MODEL_NAME').AsString +#13#10+
                 'Shift : '+ QryData.Fieldbyname('SHIFT_NAME').AsString +#13#10+
                 'Target : ' + QryData.Fieldbyname('TARGET_QTY').AsString +#13#10+
                 'Remark: ' + QryData.Fieldbyname('REMARK').AsString
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
    Params.CreateParam(ftString	,'MODEL_ID', ptInput);
    Params.CreateParam(ftString	,'SHIFT_ID', ptInput);
    CommandText := 'Update SAJET.SYS_MODEL_MONITOR_BASE '+
                   'Set ENABLED = :ENABLED, '+
                       'UPDATE_USERID = :UPDATE_USERID '+
                   'Where MODEL_ID = :MODEL_ID '+
                   'and SHIFT_ID = :SHIFT_ID ';
    Params.ParamByName('ENABLED').AsString := sStatus;
    Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
    Params.ParamByName('MODEL_ID').AsString := QryData.Fieldbyname('MODEL_ID').AsString;
    Params.ParamByName('SHIFT_ID').AsString := QryData.Fieldbyname('SHIFT_ID').AsString;
    Execute;
    //CopyToHistory(QryData.Fieldbyname('PDLINE_ID').AsString,QryData.Fieldbyname('PROCESS_ID').AsString);
    QryData.Delete;
  end;
end;

procedure TFormMain.cmbShowChange(Sender: TObject);
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

procedure TFormMain.sbtnExportClick(Sender: TObject);
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

procedure TFormMain.ModifyLog1Click(Sender: TObject);
Var S,S1 : String;
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;
  
  S := QryData.Fieldbyname('PROCESS_ID').AsString;
  S1 := QryData.Fieldbyname('PDLINE_ID').AsString;
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
