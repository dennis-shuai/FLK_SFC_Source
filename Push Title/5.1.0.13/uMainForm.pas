unit uMainForm;

interface

uses
  Forms, Windows,Dialogs,Graphics,IniFiles,SysUtils,Jpeg, Buttons, ComObj,
  Grids, DBGrids, DateUtils, Variants,uExport,
  DB, DBClient, ComCtrls, Controls, ExtCtrls, Classes, StdCtrls,Gauges;

type
  TDBGrid = class(DBGrids.TDBGrid)
   public
      function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
   end;
   TfMainForm = class(TForm)
    QryTemp: TClientDataSet;
   Image2: TImage;
   QryData: TClientDataSet;
   DBGrid1: TDBGrid;
    cmbChoose: TComboBox;
   Label3: TLabel;
   Label4: TLabel;
   sbtnQuery: TSpeedButton;
   Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    sbtnExport: TSpeedButton;
    Image4: TImage;
    sbtnPrint: TSpeedButton;
    Image5: TImage;
    SaveDialog1: TSaveDialog;
    LabQueryTime: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    DTStart: TDateTimePicker;
    ComboError: TComboBox;
    SBDelete: TSpeedButton;
    Image3: TImage;
    DataSource1: TDataSource;
    CheckBox1: TCheckBox;
    MainPanel: TPanel;
    ProgressBar1: TGauge;
    ComboUpload: TComboBox;
    ComboType: TComboBox;
    Memo1: TMemo;
    ComboERP: TComboBox;
   procedure FormShow(Sender: TObject);
   procedure FormClose(Sender: TObject; var Action: TCloseAction);
   procedure Button2Click(Sender: TObject);
   procedure DBGrid1TitleClick(Column: TColumn);
    procedure DBGrid1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure sbtnExportClick(Sender: TObject);
    procedure sbtnPrintClick(Sender: TObject);
    procedure cmbChooseChange(Sender: TObject);
    procedure QryTempAfterOpen(DataSet: TDataSet);
    procedure SBDeleteClick(Sender: TObject);
    procedure ComboTypeChange(Sender: TObject);
    procedure ComboUploadChange(Sender: TObject);
    procedure ComboERPChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID,FromStr,FromHTStr : String;
    G_sSysLang : Integer;
    function  ShowTime( sType :Integer;sTime :Integer): String;
    function  ShowCnt( sType :Integer;sCnt :Integer): String;
    procedure ResizeForm(high,width:Integer);
    procedure ButtonStatus(sBln:Boolean);
  end;

var
   fMainForm: TfMainForm;

implementation


{$R *.DFM}

procedure TfMainForm.FormShow(Sender: TObject);
var pIni: TIniFile; sImage : String;
    LangID: Word;
begin
  pini := TIniFile.Create('.\BackGround.Ini');
  sImage := pIni.ReadString('Query', 'BackGround', 'Background.jpg');
  pIni.Free;
  if FileExists(sImage) then
    Image2.Picture.LoadFromFile(sImage);
  LangID:=GetUserDefaultLangID;
  if (IntToHex(LangID, 4)='0404') or (IntToHex(LangID, 4)='0c04')  then
     G_sSysLang:=0 //TRADITIONAL
  else if (IntToHex(LangID, 4)='0804') or (IntToHex(LangID, 4)='1004') then
     G_sSysLang:=1  //SIMPLIFIED
  else
     G_sSysLang:=2;    //ENGLISH
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(100, 100);
  else
    self.ScaleBy(100, 100);
  end;
  DTStart.Date:=now;
  FromStr:='SAJET.INTERFACE_RT_DETAIL';
  FromHTStr:='SAJET.INTERFACE_HT_RT_DETAIL';
  Button2Click(SELF);
end;

procedure TfMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfMainForm.Button2Click(Sender: TObject);
Var  cost : TDateTime;
     i : Integer;
begin
  cost:=time();
  Label1.Caption:='';
  Label2.Caption:='';
  LabQueryTime.Caption:= 'Query Time: '+FormatDateTime('mm/dd HH:MM:SS',Now);
  LabQueryTime.Visible:=False;
  MainPanel.Refresh;
 if (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName <> '' then
     (DBGrid1.DataSource.DataSet as TClientDataSet).deleteIndex((DBGrid1.DataSource.DataSet as TClientDataSet).Indexname);

  with QryTemp do
  begin
    Close;
    Params.Clear;
    IF uppercase(comboType.Text)='DOWNLOAD' then
    begin
      CommandText := 'SELECT  * '+
                   ' From  '+FromStr;
      if (CheckBox1.state=cbChecked) and (uppercase(comboType.Text)='DOWNLOAD') then
        CommandText:=CommandText+' WHERE EXCEPTION_MSG<>'' ''  '
             +' AND CREATE_TIME<= to_date('+FormatDateTime('YYYYMMDD',DTStart.Date)+',''YYYYMMDD'') '
             +' Order by  EXCEPTION_MSG ';
      Open;
      QryTemp.First;
      QryTemp.DisableControls;
      for i:=0 to QryTemp.FieldCount-1 do
      begin
        DBGrid1.Columns.Items[i].Width:=100;
         if DBGrid1.Columns.Items[i].Title.Caption='EXCEPTION_MSG' then
           DBGrid1.Columns.Items[i].Index:=0;
      end;
      QryTemp.EnableControls;
    end
    else if uppercase(comboType.Text)='UPLOAD' then
    begin
      commandtext:= ' select a.*,b.emp_name '
                   +' from '+fromstr+' a,sajet.sys_emp b '
                   +' where a.user_id=b.emp_id '
                   +'       and a.RECORD_STATUS =1 '
                   +'       and  a.create_time<= to_date('+FormatDateTime('YYYYMMDD',DTStart.Date)+',''YYYYMMDD'') '
                   +' order by  a.create_time desc ';
      open;
      //showmessage(inttostr(recordcount));
      memo1.Text:=commandtext;
      QryTemp.First;
      QryTemp.DisableControls;
      for i:=0 to QryTemp.FieldCount-1 do
      begin
        DBGrid1.Columns.Items[i].Width:=100;

      end;
      QryTemp.EnableControls;
    end
    else if uppercase(comboType.Text)='ERP' then
    begin
      commandtext:= ' select * '
                   +' from '+fromstr
                   +' where  record_status=''2'' ';
      open;
      memo1.Text:=commandtext;
      QryTemp.First;
      QryTemp.DisableControls;
      for i:=0 to QryTemp.FieldCount-1 do
      begin
        DBGrid1.Columns.Items[i].Width:=100;
        if DBGrid1.Columns.Items[i].Title.Caption='ERROR_MESSAGE' then
           DBGrid1.Columns.Items[i].Width:=300;
      end;
      QryTemp.EnableControls;
    end;
    DBGrid1.Columns.Items[0].Width:=180;
    Label1.Caption:=ShowCnt(G_sSysLang,QryTemp.RecordCount);
  end;
  LabQueryTime.Visible:=True;
  Label2.Caption:=ShowTime(G_sSysLang,MilliSecondsBetween(time(),cost));
end;

procedure TfMainForm.DBGrid1TitleClick(Column: TColumn);
var bAesc: Boolean;
begin
  bAesc := True;
  if DBGrid1.DataSource = nil then Exit;
  if DBGrid1.DataSource.DataSet = nil then Exit;
  if not (DBGrid1.DataSource.DataSet is TClientDataSet) then Exit;
  if (DBGrid1.DataSource.DataSet as TClientDataSet).Active then
  begin
    if (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName <> '' then
    begin
      bAesc := True;
      if (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName = Column.FieldName then
        bAesc := False;
       (DBGrid1.DataSource.DataSet as TClientDataSet).deleteIndex((DBGrid1.DataSource.DataSet as TClientDataSet).Indexname);
    end;
    if bAesc then begin
      (DBGrid1.DataSource.DataSet as TClientDataSet).AddIndex(Column.FieldName, Column.FieldName, [], '', '', 0);
      (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName := Column.FieldName;
    end else begin
      (DBGrid1.DataSource.DataSet as TClientDataSet).AddIndex(Column.FieldName + 'D', Column.FieldName, [ixDescending], '', '', 0);
      (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName := Column.FieldName + 'D';
    end;
    (DBGrid1.DataSource.DataSet as TClientDataSet).IndexDefs.Update;
    (DBGrid1.DataSource.DataSet as TClientDataSet).First;
  end;
end;

function TDBGrid.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  IF not (datasource.DataSet.active) THEN EXIT;
  if WheelDelta > 0 then
    datasource.DataSet.Prior;
  if wheelDelta < 0 then
    DataSource.DataSet.Next;
  Result := True;
end;

function TfMainForm.ShowTime( sType :Integer;sTime :Integer): String;
Var sMin : Integer;
    sSec :Single;
begin
    if sTime > 60000 then  //minutes
    begin
      sSec:=((sTime mod 60000) / 1000);
      sMin:=(sTime div 60000);
      if sType=0 then
        Result := 'ノ'+IntToStr(sMin)+' だ'+FloatToStrF(sSec,ffFixed,4,2)+' '
      else if sType=1 then
        Result := '用时'+IntToStr(sMin)+' 分'+FloatToStrF(sSec,ffFixed,4,2)+' 秒'
      else
        Result := 'Search Time:'+IntToStr(sMin)+' Min'+FloatToStrF(sSec,ffFixed,4,2)+'sec.';
    end else
    begin
      sSec:=(sTime / 1000);
      if sType=0 then
        Result := 'ノ'+FloatToStrF(sSec,ffFixed,4,2)+' '
      else if sType=1 then
        Result := '用时'+FloatToStrF(sSec,ffFixed,4,2)+' 秒'
      else
        Result := 'Search Time:'+FloatToStrF(sSec,ffFixed,4,2)+'sec.';
    end;
end;

function TfMainForm.ShowCnt( sType :Integer;sCnt :Integer): String;
begin
  if sType=0 then
    result := 'т'+inttostr(sCnt)+' 掸  '
  else if sType=1 then
    Result := '找到'+IntToStr(sCnt)+' 笔'
  else
    Result := 'Records: '+IntToStr(sCnt);
end;

procedure TfMainForm.DBGrid1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  lCoord: TGridCoord;
  liOldRecord: Integer;
begin
  IF not (TDBGrid(DBGrid1).DataSource.DataSet.active) THEN EXIT;
  IF QryTemp.Data=null THEN EXIT;
  lCoord := DBGrid1.MouseCoord(X, Y);
  if dgIndicator in DBGrid1.Options then
    Dec(lCoord.X);
  if dgTitles in DBGrid1.Options then
    Dec(lCoord.Y);
  if (lCoord.Y >= 0) and Assigned(TDBGrid(DBGrid1).DataLink) then
  begin
    liOldRecord := TDBGrid(DBGrid1).DataLink.ActiveRecord;
    try
      TDBGrid(DBGrid1).DataLink.ActiveRecord := lCoord.Y;
      if (lCoord.X >= 0) and ( DBGrid1.Columns.Items[lCoord.X].Title.Caption='QTY' ) and (QryTemp.RecordCount>0) then
        DBGrid1.Cursor:=crHandPoint
      else
        DBGrid1.Cursor:=crDefault;
    finally
      TDBGrid(DBGrid1).DataLink.ActiveRecord := liOldRecord;
    end;
  end else
    DBGrid1.Cursor:=crDefault;
end;

procedure TfMainForm.ResizeForm(high,width:Integer);
begin
  fMainForm.Width:=width;
  fMainForm.Height:=high;
  dbgrid1.Height:=high-200;
  dbgrid1.width:=width-40;
  Label1.Top:=7+dbgrid1.Height+dbgrid1.Top;
  Label2.Top:=Label1.Top;
  LabQueryTime.Top:=Label1.Top-1;
  ProgressBar1.Top:=Label1.Top;
  ProgressBar1.Left:=dbgrid1.width-176;
end;
procedure TfMainForm.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var
Canvas: TCanvas;
begin
Canvas := (Sender as TDBGrid).Canvas;
if((Column.Field.DataSet.RecNo mod 2)=0) then
begin
  Canvas.Brush.Color := $00FFF0F0;
  Canvas.Font.Color := Clblack;
end
else
begin
  Canvas.Brush.Color := clWindow;
  Canvas.Font.Color := Clblack;
end;
  Canvas.FillRect(Rect);
  DBGrid1.DefaultDrawDataCell(Rect, Column.Field, State);
end;

procedure TfMainForm.sbtnExportClick(Sender: TObject);
begin
  if DBGrid1.Visible=True then
  begin
    if not QryTemp.Active Then Exit;
    if (QryTemp.RecordCount=0) Then Exit;
  end;
  sbtnExport.Enabled:=False;
  ExpThread:=TExpThread.Create(false);
  ExpThread.FreeOnTerminate := True;
end;

procedure TfMainForm.sbtnPrintClick(Sender: TObject);
begin
  if DBGrid1.Visible=True then
  begin
    if not QryTemp.Active Then Exit;
    if (QryTemp.RecordCount=0) Then Exit;
  end;
  PrtThread:=TPrtThread.Create(false);
  PrtThread.FreeOnTerminate := True;
end;

procedure TfMainForm.ButtonStatus(sBln:Boolean);
begin
  sbtnQuery.enabled:=sBln;
  sbtnExport.enabled:=sBln;
  SbtnPrint.enabled:=sBln;
  SBDelete.enabled:=sBln;
  ProgressBar1.Visible:=not sBln;
end;

procedure TfMainForm.cmbChooseChange(Sender: TObject);
begin
  FromStr:='SAJET.INTERFACE_'+cmbChoose.Text;
  FromHTStr:='SAJET.INTERFACE_HT_'+cmbChoose.Text;
  Button2Click(SELF);
end;

procedure TfMainForm.QryTempAfterOpen(DataSet: TDataSet);
begin
  if uppercase(comboType.Text)<>'DOWNLOAD' then exit;
  DBGrid1.Datasource.Dataset.DisableControls;
  QryTemp.First;
  ComboError.Clear;
  if QryTemp.RecordCount>0 then
  begin
    while not QryTemp.Eof do
    begin
      if ComboError.Items.IndexOf(QryTemp.FieldByName('EXCEPTION_MSG').AsString)=-1 then
         ComboError.Items.Add(QryTemp.FieldByName('EXCEPTION_MSG').AsString);
      QryTemp.Next;
    end;
    ComboError.ItemIndex:=0;
  end;
  QryTemp.First;
  DBGrid1.Datasource.Dataset.EnableControls;
end;

procedure TfMainForm.SBDeleteClick(Sender: TObject);
begin
  if uppercase(comboType.Text)<>'DOWNLOAD' then  exit;

  if ComboError.Items.Count<=0 then exit;
  If MessageDlg('Delete where [ '+ComboError.text+ ' ]'+#13#13+'Are You Sure ?',mtWarning,mbOKCancel,0) = mrOK Then
  begin
    with QryData do
    begin
      Close;
      Params.Clear;
        CommandText := 'INSERT INTO  '+FromHTStr
                   +' SELECT * FROM '+FromStr+' WHERE EXCEPTION_MSG= '''+ComboError.text+ ''''
                   +' AND CREATE_TIME<= to_date('+FormatDateTime('YYYYMMDD',DTStart.Date)+',''YYYYMMDD'') ';
        Execute;
        Close;
        Params.Clear;
        CommandText := 'DELETE FROM  '+FromStr
                   +' WHERE EXCEPTION_MSG= '''+ComboError.text+ ''''
                   +' AND CREATE_TIME<= to_date('+FormatDateTime('YYYYMMDD',DTStart.Date)+',''YYYYMMDD'') ';
       Execute;
    end;
    cmbChooseChange(self);
  end;
end;

procedure TfMainForm.ComboTypeChange(Sender: TObject);
begin
  if uppercase(comBoType.Text)='UPLOAD' THEN
  begin
     ComboUpload.Visible:=true;
     comboupload.ItemIndex:=0;
     CmbChoose.Visible:=false;
     comboErp.Visible:=false;
     comboError.Visible:=false;
     CheckBox1.Visible:=false;
     sbDelete.Visible:=false;
     Image3.Visible:=false;
     ComboUploadchange(self);
  end
  else if uppercase(comboType.Text)='DOWNLOAD' THEN
  BEGIN
     ComboUpload.Visible:=false;
     comboErp.Visible:=false;
     CmbChoose.Visible:=true;
     cmbChoose.ItemIndex:=0;
     comboError.Visible:=true;
     CheckBox1.Visible:=true;
     sbDelete.Visible:=true;
     Image3.Visible:=true;
     CmbChoosechange(self);
  end
  else if uppercase(comboType.Text)='ERP' then
  begin
     ComboUpload.Visible:=false;
     comboErp.Visible:=true;
     comboERP.ItemIndex:=0;
     CmbChoose.Visible:=false;
     comboError.Visible:=false;
     CheckBox1.Visible:=false;
     sbDelete.Visible:=false;
     Image3.Visible:=false;
     comboErpchange(self);
  end;

  label3.Caption:='Query '+uppercase(comboType.Text)+' Error Records';
  label4.Caption:='Query '+uppercase(comboType.Text)+' Error Records';
end;

procedure TfMainForm.ComboUploadChange(Sender: TObject);
begin
  FromStr:='SAJET.MES_TO_ERP_'+ComboUpload.Text;
  FromHTStr:='SAJET.MES_HT_TO_ERP_'+ComboUpload.Text;
  Button2Click(SELF);
end;

procedure TfMainForm.ComboERPChange(Sender: TObject);
begin
  FromStr:='MES_TO_ERP_'+ComboERP.Text+'@sfc2erp';
  FromHTStr:='MES_HT_TO_ERP_'+ComboERP.Text+'@sfc2erp';
  Button2Click(SELF);
end;

end.
