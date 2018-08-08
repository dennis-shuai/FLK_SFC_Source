unit uMain;

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
    cmbItem: TComboBox;
    edtData: TEdit;
    procedure sbtnAppendClick(Sender: TObject);
    procedure sbtnModifyClick(Sender: TObject);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure FormShow(Sender: TObject);
    procedure sbtnDeleteClick(Sender: TObject);
    procedure sbtnDisabledClick(Sender: TObject);
    procedure cmbShowChange(Sender: TObject);
    procedure sbtnExportClick(Sender: TObject);
    procedure ModifyLog1Click(Sender: TObject);
    procedure edtDataKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx : String;
    UpdateUserID : String;
    Authoritys,AuthorityRole : String;
    Procedure CopyToHistory(sdefectid,sreasonid,sdutyid : String);
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
       Params.ParamByName('FUN').AsString :='Defect Reason Relation';
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

Procedure TfDPPM.CopyToHistory(sdefectid,sreasonid,sdutyid : String);
begin
  With QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'defectid', ptInput);
     Params.CreateParam(ftString	,'reasonid', ptInput);
     Params.CreateParam(ftString ,'dutyid', ptInput);
     CommandText := ' Insert Into SAJET.SYS_HT_defect_reason '+
                    ' Select * from SAJET.SYS_defect_reason '+
                    ' Where defect_ID = :defectid '+
                    ' and reason_ID = :reasonid and duty_id = :dutyid';
     Params.ParamByName('defectid').AsString := sdefectid;
     Params.ParamByName('reasonid').AsString := sreasonid;
     Params.ParamByName('dutyid').AsString := sdutyid;
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
     params.Clear;
     Commandtext:=' select d.emp_no,d.EMP_NAME,a.defect_id,a.defect_code,a.defect_desc,b.reason_id,b.reason_Code,b.reason_desc ,'
                 +' e.duty_id,e.duty_code,e.duty_desc,c.retest_times ,c.enabled ,c.update_time,c.Location '
                 +' from sajet.sys_defect a,sajet.sys_reason b,sajet.sys_defect_reason c,sajet.sys_emp d,sajet.sys_duty e'
                 +' where c.Update_userid=d.emp_id and a.defect_id=c.defect_id and b.reason_id=c.reason_id and c.duty_id = e.duty_id ';
     if cmbItem.ItemIndex=0 then
        commandtext:=commandtext+' and a.defect_code like '+''''+trim(edtData.Text)+'%'+''''
     else if cmbitem.ItemIndex=1 then
        commandtext:=commandtext+' and b.reason_code  like '+''''+trim(edtData.Text)+'%'+''''
     else if cmbitem.ItemIndex=2 then
        commandtext:=commandtext+' and e.duty_Code  like '+''''+trim(edtData.Text)+'%'+'''' ;

     If cmbShow.Text = 'Enabled' Then
       CommandText:= CommandText + 'And C.enabled = ''Y'' ';
     If cmbShow.Text = 'Disabled' Then
        CommandText:= CommandText + 'And C.enabled = ''N'' ';

     CommandText := CommandText + ' Order By '+Orderidx;
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

     sOReasonID:=QryData.fieldbyname('reason_id').AsString;
     sODutyID:=QryData.fieldbyname('Duty_id').AsString;
     edtDefect.Text:=QryData.fieldbyname('Defect_Code').AsString;
     lblDefect.Caption:=QryData.fieldbyname('Defect_Desc').AsString;
     edtReason.Text:=QryData.fieldbyname('Reason_Code').AsString;
     lblReason.Caption:=QryData.fieldbyname('reason_desc').AsString;
     edtduty.Text:=QryData.fieldbyname('Duty_Code').AsString;
     lblDuty.Caption:=QryData.fieldbyname('Duty_desc').AsString;
     edtLocation.Text := QryData.fieldbyname('Location').AsString;
     edtDefect.Enabled:=false;

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
  Orderidx := 'Defect_Code';
  cmbItem.ItemIndex:=0;
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
                'Defect Desc. : ' + QryData.Fieldbyname('Defect_Desc').AsString +#13#10+
                'Reason Desc.  : ' + QryData.Fieldbyname('Reason_Desc').AsString +#13#10+
                'Duty Desc.   : ' + QryData.Fieldbyname('Duty_Desc').AsString
                ,mtWarning, mbOKCancel,0) = mrOK Then
  begin
    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
      Params.CreateParam(ftString	,'Defectid', ptInput);
      Params.CreateParam(ftString	,'ReasonId', ptInput);
      Params.CreateParam(ftString	,'DutyId', ptInput);
      CommandText := 'Update sajet.sys_defect_reason ' +
                     'Set ENABLED = :ENABLED, ' +
                     'UPDATE_USERID = :UPDATE_USERID ,' +
                     'Update_time = sysdate ' +
                     'Where defect_id = :Defectid ' +
                     'and reason_Id = :reasonid  ' +
                     'and duty_id =:dutyid ';
      Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
      Params.ParamByName('Defectid').AsString := QryData.Fieldbyname('defect_id').AsString;
      Params.ParamByName('ReasonId').AsString := QryData.Fieldbyname('reason_Id').AsString;
      Params.ParamByName('DutyId').AsString := QryData.Fieldbyname('duty_id').AsString;
      Execute;
      CopyToHistory(QryData.Fieldbyname('defect_id').AsString,QryData.Fieldbyname('reason_Id').AsString,QryData.Fieldbyname('duty_id').AsString);

      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'Defectid', ptInput);
      Params.CreateParam(ftString	,'ReasonId', ptInput);
      Params.CreateParam(ftString	,'DutyId', ptInput);
      CommandText := 'Delete SAJET.sys_defect_reason '+
                      'Where defect_id = :Defectid '+
                     'and reason_Id = :reasonid '+
                     'and duty_id =:dutyid ';
      Params.ParamByName('Defectid').AsString := QryData.Fieldbyname('defect_id').AsString;
      Params.ParamByName('ReasonId').AsString := QryData.Fieldbyname('reason_Id').AsString;
      Params.ParamByName('DutyId').AsString := QryData.Fieldbyname('duty_id').AsString;
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
                 'Defect Desc.  : ' + QryData.Fieldbyname('Defect_Desc').AsString +#13#10+
                 'Reason Desc. : '+ QryData.Fieldbyname('Reason_Desc').AsString +#13#10+
                 'Duty Desc. : ' + QryData.Fieldbyname('duty_desc').AsString
                 ,mtWarning, mbOKCancel,0) <> mrOK Then
      Exit;
    sStatus := 'N';
  end Else
  begin
    If MessageDlg('Do you want to enable this data ?' + #13#10+
                 'Defect Desc.  : ' + QryData.Fieldbyname('Defect_Desc').AsString +#13#10+
                 'Reason Desc. : '  + QryData.Fieldbyname('Reason_Desc').AsString +#13#10+
                 'Duty Desc. : '    + QryData.Fieldbyname('duty_desc').AsString
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
      Params.CreateParam(ftString	,'DefectID', ptInput);
      Params.CreateParam(ftString	,'ReasonID', ptInput);
      Params.CreateParam(ftString	,'DutyID', ptInput);
      CommandText := 'Update SAJET.sys_Defect_Reason '+
                     'Set ENABLED = :ENABLED, '+
                     'UPDATE_USERID = :UPDATE_USERID '+
                     'Where defect_id = :defectID '+
                     'and reason_id = :reasonId  ' +
                     'and duty_id =:dutyid ';
      Params.ParamByName('ENABLED').AsString := sStatus;
      Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
      Params.ParamByName('DefectID').AsString := QryData.Fieldbyname('defect_id').AsString;
      Params.ParamByName('ReasonID').AsString := QryData.Fieldbyname('reason_id').AsString;
      Params.ParamByName('DutyID').AsString := QryData.Fieldbyname('duty_id').AsString;
      Execute;
      CopyToHistory(QryData.Fieldbyname('defect_id').AsString,QryData.Fieldbyname('reason_id').AsString,QryData.Fieldbyname('duty_id').AsString);
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
  {If (not QryData.Active) or (QryData.IsEmpty) Then
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
  end;  }
end;

procedure TfDPPM.edtDataKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then
    showdata;
end;

end.
