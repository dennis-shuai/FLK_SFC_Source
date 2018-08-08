unit uOutputCfg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, Db,
  DBClient, MConnect, SConnect, IniFiles, ObjBrkr, uSelect, uSort, uQuery;

type
  TfOutputCfg = class(TForm)
    sbtnClose: TSpeedButton;
    Image1: TImage;
    Label5: TLabel;
    Label9: TLabel;
    Imagemain: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    Label10: TLabel;
    Label2: TLabel;
    cmbFactory: TComboBox;
    Label6: TLabel;
    Label17: TLabel;
    ChkLine: TCheckBox;
    Label21: TLabel;
    ChkWO: TCheckBox;
    Label23: TLabel;
    ChkPart: TCheckBox;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Label1: TLabel;
    ListSort: TListBox;
    sbtnSort: TSpeedButton;
    Image6: TImage;
    Label11: TLabel;
    editName: TEdit;
    Label12: TLabel;
    editFile: TEdit;
    sbtnImport: TSpeedButton;
    sbtnSave: TSpeedButton;
    Image2: TImage;
    OpenDialog1: TOpenDialog;
    TlbReportFile: TClientDataSet;
    cmbDateStyle: TComboBox;
    ChkDate: TCheckBox;
    Label14: TLabel;
    cmbMain: TComboBox;
    Label7: TLabel;
    cmbSecond: TComboBox;
    Label15: TLabel;
    chkForPersonnal: TCheckBox;
    Label8: TLabel;
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
    procedure sbtnLineClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnImportClick(Sender: TObject);
    procedure sbtnModelClick(Sender: TObject);
    procedure sbtnSortClick(Sender: TObject);
    procedure cmbMainDropDown(Sender: TObject);
    procedure cmbSecondDropDown(Sender: TObject);
    procedure ChkDateClick(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    UpdateUserID : String;
    ReportName : String;
    SampleFileName : String;
    RpID : String;
    FcID : String;
    bPersonnalReport : Boolean;
    ReportModify : Boolean;
    procedure SetTheRegion;
    Function  LoadApServer : Boolean;
    Function  GetMaxReportID : String;
    Function  GetReportID : String;
    Function  GetFactoryID : String;
    procedure GetFactoryData;
    procedure GetPdLineData;
    procedure GetPartData;
    Procedure ShowFactory;
    Procedure ShowReportCfgData;
  end;

var
  fOutputCfg: TfOutputCfg;
  StrLstPdLine,StrLstPart,StrLstTemp : TStringList;

implementation

{$R *.DFM}

Function TfOutputCfg.LoadApServer : Boolean;
Var F : TextFile;
    S : String;
begin
{  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  If not FileExists(GetCurrentDir+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,GetCurrentDir+'\ApServer.cfg');
  Reset(F);
  While True do
  begin
    Readln(F, S);
    If S <> '' Then
    begin
      SimpleObjectBroker1.Servers.Add;
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
    end Else
      Break;
  end;
  CloseFile(F);
  Result := True;}
end;

procedure TfOutputCfg.ShowFactory;
begin
  cmbFactory.Items.Clear;
  With QryTemp do
  begin
     Close;
     Params.Clear;
     CommandText := 'Select FACTORY_CODE,FACTORY_NAME '+
                    'From SAJET.SYS_FACTORY '+
                    'Where ENABLED = ''Y'' ';
     Open;
     While Not Eof do
     begin
        cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString);
        Next;
     end;
     Close;
  end;

  If cmbFactory.Items.Count = 1 Then
  begin
    cmbFactory.ItemIndex := 0;
    cmbFactoryChange(Self);
  end;
end;

procedure TfOutputCfg.GetFactoryData;
Var S : String;
begin
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'FACTORY_ID', ptInput);
    CommandText := 'Select FACTORY_CODE,FACTORY_NAME '+
                   'From SAJET.SYS_FACTORY '+
                   'Where FACTORY_ID = :FACTORY_ID ';
    Params.ParamByName('FACTORY_ID').AsString := FcID;
    Open;
    If RecordCount > 0 Then
    begin
      S := Fieldbyname('FACTORY_CODE').AsString +' ' + Fieldbyname('FACTORY_NAME').AsString;
      cmbFactory.ItemIndex := cmbFactory.Items.Indexof(S);
    end;
    Close;
  end;

  If cmbFactory.Items.Count = 1 Then
  begin
    cmbFactory.ItemIndex := 0;
    cmbFactoryChange(Self);
  end;
end;

procedure TfOutputCfg.GetPdLineData;
begin
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'RPID', ptInput);
    CommandText := 'Select A.PDLINE_ID,A.PDLINE_NAME '+
                     'From SAJET.SYS_PDLINE A, '+
                          'SAJET.SYS_REPORT_PARAM B '+
                     'Where B.RP_ID = :RPID and '+
                           'B.PARAM_TYPE = ''Query Condition'' and '+
                           'B.PARAM_NAME = ''PDLINE_ID'' and ' +
                           'B.PARAM_VALUE = A.PDLINE_ID '+
                     'Order By A.PDLINE_NAME ';
    Params.ParamByName('RPID').AsString := RpID;
    Open;
    StrLstPdLine.Clear;
    While not eof do
    begin
//      ListPdLine.Items.Add(Fieldbyname('PDLINE_NAME').AsString);
      StrLstPDLine.Add(Fieldbyname('PDLINE_ID').AsString);
      Next;
    end;
    Close;
  end;
end;

procedure TfOutputCfg.GetPartData;
begin
{  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'RPID', ptInput);
    CommandText := 'Select A.PART_ID,A.PART_NO '+
                     'From SAJET.SYS_PART A, '+
                          'SAJET.SYS_REPORT_PARAM B '+
                     'Where B.RP_ID = :RPID and '+
                           'B.PARAM_TYPE = ''Query Condition'' and '+
                           'B.PARAM_NAME = ''PART_ID'' and ' +
                           'B.PARAM_VALUE = A.PART_ID '+
                     'Order By A.PART_NO ';
    Params.ParamByName('RPID').AsString := RpID;
    Open;
    StrLstPart.Clear;
    While not eof do
    begin
      ListPart.Items.Add(Fieldbyname('PART_NO').AsString);
      StrLstPart.Add(Fieldbyname('PART_ID').AsString);
      Next;
    end;
    Close;
  end;}
end;

Procedure TfOutputCfg.ShowReportCfgData;
begin
//  editName.Enabled := False;
  FcID := '0';
  editName.Text := ReportName;
//  ListPdLine.Items.Clear;
//  ListPart.Items.Clear;
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'RP_ID', ptInput);
    CommandText := 'Select B.*,A.RP_NAME,A.SAMPLE_NAME '+
                     'From SAJET.SYS_REPORT_NAME A, '+
                          'SAJET.SYS_REPORT_PARAM B '+
                     'Where A.RP_ID = :RP_ID and '+
                           'A.RP_ID = B.RP_ID '+
                     'Order By PARAM_TYPE,PARAM_VALUE '      ;
    Params.ParamByName('RP_ID').AsString := RpID;
    Open;
    IF RecordCount > 0 Then
    begin
      editFile.Text := Fieldbyname('SAMPLE_NAME').AsString;
      editName.Text := Fieldbyname('RP_NAME').AsString;
      If editFile.Text = 'N/A' Then
        editFile.Text := '';
      SampleFileName := editFile.Text;
    end;
    While not eof do
    begin
        If Fieldbyname('PARAM_TYPE').AsString = 'Query Condition' Then
        begin
           If Fieldbyname('PARAM_NAME').AsString = 'FACTORY_ID' Then
             FcID := Fieldbyname('PARAM_VALUE').AsString;
        end;
        If Fieldbyname('PARAM_TYPE').AsString = 'Date Style' Then
          cmbDateStyle.ItemIndex := cmbDateStyle.Items.IndexOf(Fieldbyname('PARAM_VALUE').AsString);
        If Fieldbyname('PARAM_TYPE').AsString = 'Display Information' Then
        begin
          If Fieldbyname('PARAM_NAME').AsString = 'Date' Then
            ChkDate.Checked := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
          If Fieldbyname('PARAM_NAME').AsString = 'Production Line' Then
            ChkLine.Checked := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
          If Fieldbyname('PARAM_NAME').AsString = 'Work Order' Then
            ChkWO.Checked := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
          If Fieldbyname('PARAM_NAME').AsString = 'Part No' Then
            ChkPart.Checked := (Fieldbyname('PARAM_VALUE').AsString = 'Y');
        end;
        If Fieldbyname('PARAM_TYPE').AsString = 'Chart Set' Then
        begin
          If Fieldbyname('PARAM_NAME').AsString = 'Main' Then
            cmbMain.ItemIndex := cmbMain.Items.IndexOf(Fieldbyname('PARAM_VALUE').AsString);
          If Fieldbyname('PARAM_NAME').AsString = 'Second' Then
            cmbSecond.ItemIndex := cmbSecond.Items.IndexOf(Fieldbyname('PARAM_VALUE').AsString);
        end;
        If Fieldbyname('PARAM_TYPE').AsString = 'Sort Condition' Then
           ListSort.Items.Add(Fieldbyname('PARAM_NAME').AsString);
        Next;
    end;

    GetPdLineData;
    GetPartData;
  end;
  IF FcID <> '0' Then
    GetFactoryData;
end;

procedure TfOutputCfg.sbtnCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TfOutputCfg.FormCreate(Sender: TObject);
begin
  Imagemain.Picture := form1.Imagemain.Picture;
  UpdateUserID := form1.UpdateUserID;
  ReportModify := form1.ReportModify;
  RpID := form1.RpID;
  bPersonnalReport := form1.bPersonnalReport;
  SetTheRegion;
  StrLstPdLine := TStringList.Create;
  StrLstPart := TStringList.Create;
  StrLstTemp := TStringList.Create;
  SampleFileName := '';
end;

procedure TfOutputCfg.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.
procedure TfOutputCfg.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
var Brush: TBrush;
begin
  Brush := TBrush.Create;
  Brush.Color := Color;
  FillRect( Msg.DC, ClientRect, Brush.Handle);
  Brush.Free;
  with Imagemain.Picture.Bitmap do
    BitBlt( Msg.DC, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := 1;
end;

// This routine takes care of letting the user move the form
// around on the desktop.
procedure TfOutputCfg.WMNCHitTest( var msg: TWMNCHitTest );
var
  i: integer;
  p: TPoint;
  AControl: TControl;
  MouseOnControl: boolean;
begin
  inherited;
  if msg.result = HTCLIENT then begin
    p.x := msg.XPos;
    p.y := msg.YPos;
    p := ScreenToClient( p);
    MouseOnControl := false;
    for i := 0 to ControlCount-1 do begin
      if not MouseOnControl
      then begin
        AControl := Controls[i];
        if ((AControl is TWinControl) or (AControl is TGraphicControl))
          and (AControl.Visible)
        then MouseOnControl := PtInRect( AControl.BoundsRect, p);
      end
      else
        break;
    end;
    if (not MouseOnControl) then msg.Result := HTCAPTION;
  end;
end;

Function TfOutputCfg.GetReportID : String;
begin
  Result := '';
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'REPORT_NAME', ptInput);
    CommandText := 'Select RP_ID '+
                     'From SAJET.SYS_REPORT_NAME '+
                     'Where RP_NAME = :REPORT_NAME ';
    Params.ParamByName('REPORT_NAME').AsString := ReportName;
    Open;
    If RecordCount > 0 Then
      Result := Fieldbyname('RP_ID').AsString;
    Close;
  end;
end;

Function TfOutputCfg.GetFactoryID : String;
Var S : String;
begin
  Result := '0';
  s := Trim(Copy(cmbFactory.Text,1,POS(' ',cmbFactory.Text)-1));
  If S='' Then Exit;
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'FACTORY_CODE', ptInput);
    CommandText := 'Select FACTORY_ID '+
                     'From SAJET.SYS_FACTORY '+
                     'Where FACTORY_CODE = :FACTORY_CODE ';
    Params.ParamByName('FACTORY_CODE').AsString := S;
    Open;
    If RecordCount > 0 Then
      Result := Fieldbyname('FACTORY_ID').AsString;
    Close;
  end;
end;

Function TfOutputCfg.GetMaxReportID : String;
Var DBID : String;
begin
  With QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select NVL(Max(RP_ID),0) + 1 RPID '+
                   'From SAJET.SYS_REPORT_NAME' ;
    Open;
    If Fieldbyname('RPID').AsString = '1' Then
    begin
       Close;
       CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || ''000001'' RPID '+
                      'From SAJET.SYS_BASE '+
                      'Where PARAM_NAME = ''DBID'' ' ;
       Open;
    end;
    Result := Fieldbyname('RPID').AsString;
    Close;
  end;
end;

procedure TfOutputCfg.FormShow(Sender: TObject);
begin
  LoadApServer;
  ShowFactory;
  chkForPersonnal.Checked := bPersonnalReport;
  sbtnSave.Enabled := ReportModify;
  If RpID <> '' Then
    ShowReportCfgData;
end;

procedure TfOutputCfg.sbtnSaveClick(Sender: TObject);
Var iCnt : Integer; S : String;
  Function GetData(LstBox : TListBox) : String;
  Var I : Integer;
  begin
    Result := LstBox.Items.Strings[0];
    for I := 1 to LstBox.Items.Count - 1 do
    begin
      Result := Result + ',' + LstBox.Items.Strings[I];
    end;
  end;

  Procedure SaveReportParams(RpID, ParamType, ParamName,ParamValue : String );
  begin
    With QryTemp do
    begin
      Close;
      Params.ParamByName('RP_ID').AsString := RpID;
      Params.ParamByName('PARAM_TYPE').AsString := ParamType;
      Params.ParamByName('PARAM_NAME').AsString := ParamName;
      Params.ParamByName('PARAM_VALUE').AsString := ParamValue;
      Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
      Execute;
    end;
  end;

  Function SaveReportNameWithBlob : Boolean;
  var fsSend: TFileStream;
  begin
    Result := False;
    With TlbReportFile do
    begin
      Open;
      Insert;
      FieldByName('RP_ID').AsString := RpID;
      FieldByName('RP_NAME').AsString := editName.Text ;
      FieldByName('RP_TYPE').AsString := 'Output';
      FieldByName('SAMPLE_NAME').AsString := ExtractFilename(editFile.Text);
      TBlobField(FieldByName('SAMPLE_FILE')).LoadFromFile(Trim(editFile.Text));
      FieldByName('UPDATE_USERID').AsString := UpdateUserID;
      ApplyUpdates(0);
    end;
    Result := True;
  end;

  Function InsertReportNameWithNoBlob : Boolean;
  begin
    Result := False;
    Try
      With QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'RP_ID', ptInput);
        Params.CreateParam(ftString	,'RP_NAME', ptInput);
        Params.CreateParam(ftString	,'RP_TYPE', ptInput);
        Params.CreateParam(ftString	,'SAMPLE_NAME', ptInput);
        Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
        Params.CreateParam(ftString	,'EMP_ID', ptInput);
        CommandText := 'Insert Into SAJET.SYS_REPORT_NAME '+
                        ' (RP_ID,RP_NAME,RP_TYPE,SAMPLE_NAME,UPDATE_USERID,EMP_ID) '+
                        'Values (:RP_ID,:RP_NAME,:RP_TYPE,:SAMPLE_NAME,:UPDATE_USERID,:EMP_ID) ';
        Params.ParamByName('RP_ID').AsString := RpID;
        Params.ParamByName('RP_NAME').AsString := editName.Text ;
        Params.ParamByName('RP_TYPE').AsString := 'Output';
        Params.ParamByName('SAMPLE_NAME').AsString := 'N/A';
        Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
        If chkForPersonnal.Checked Then
          Params.ParamByName('EMP_ID').AsString := UpdateUserID
        Else
          Params.ParamByName('EMP_ID').AsString := '0';
        Execute;
      end;
    Except
      QryTemp.Close;
      MessageDlg('Database Error !!'+#13#10 +
                 'could not save to Database !' ,mtError, [mbCancel],0);
      Exit;
    end;
    Result := True;
  end;

  Function AddReportName : Boolean;
  begin
    // 檢查 NAME 是否重複
    Result := False;
    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'REPORT_NAME', ptInput);
      CommandText := 'Select RP_NAME '+
                       'From SAJET.SYS_REPORT_NAME '+
                       'Where RP_NAME = :REPORT_NAME ';
      Params.ParamByName('REPORT_NAME').AsString := UpperCase(Trim(editName.Text));
      Open;
      If RecordCount > 0 Then
      begin
        Close;
        MessageDlg('Report Name Duplicate !! ',mtError, [mbCancel],0);
        Exit;
      end;

      RpId := GetMaxReportID;

      If RpId = '' Then
      begin
        MessageDlg('Database Error !!'+#13#10 +
                   'could not get Report Id !!' ,mtError, [mbCancel],0);
        Exit;
      end;

      Try
        If Trim(editFile.Text) <> '' Then
        begin
          If not SaveReportNameWithBlob Then
            Exit;
        end else
        begin
          If not InsertReportNameWithNoBlob Then
            Exit;
        end;
      Except
        MessageDlg('Database Error !!'+#13#10 +
                   'could not save to Database !!' ,mtError, [mbCancel],0);
        Exit;
      end;
    end;
    Result := True;
  end;

  Function ModiReportName : Boolean;
  begin
    Result := False;
    // 檢查是否重複
    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'REPORT_NAME', ptInput);
      Params.CreateParam(ftString	,'RP_ID', ptInput);
      CommandText := 'Select RP_NAME '+
                       'From SAJET.SYS_REPORT_NAME '+
                       'Where RP_NAME = :REPORT_NAME and '+
                             'RP_ID <> :RP_ID ';
      Params.ParamByName('REPORT_NAME').AsString := ReportName;
      Params.ParamByName('RP_ID').AsString := RpID;
      Open;
      If RecordCount > 0 Then
      begin
        Close;
        MessageDlg('Report Name Duplicate !! ',mtError, [mbCancel],0);
        Exit;
      end;
    end;

    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'RP_ID', ptInput);
      CommandText := 'Delete SAJET.SYS_REPORT_PARAM '+
                     'Where RP_ID = :RP_ID ';
      Params.ParamByName('RP_ID').AsString := RpID;
      Execute;
    end;

    If Trim(editFile.Text) <> SampleFileName Then
    begin
      // 刪除
      With QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'RP_ID', ptInput);
        CommandText := 'Delete SAJET.SYS_REPORT_NAME '+
                       'Where RP_ID = :RP_ID ';
        Params.ParamByName('RP_ID').AsString := RpID;
        Execute;
      end;
      If Trim(editFile.Text) <> '' Then
      begin
        SaveReportNameWithBlob;
        Result := True;
        Exit;
      end else
      begin
        InsertReportNameWithNoBlob;
        Result := True;
        Exit;
      end;
    end;

    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'RP_NAME', ptInput);
      Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
      Params.CreateParam(ftString	,'EMP_ID', ptInput);
      Params.CreateParam(ftString	,'RP_ID', ptInput);
      CommandText := 'Update SAJET.SYS_REPORT_NAME '+
                     'Set RP_NAME = :RP_NAME,'+
                         'UPDATE_USERID = :UPDATE_USERID,'+
                         'EMP_ID = :EMP_ID,'+
                         'UPDATE_TIME = SYSDATE '+
                     'Where RP_ID = :RP_ID ';
      Params.ParamByName('RP_NAME').AsString := editName.Text ;
      Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
      If chkForPersonnal.Checked Then
        Params.ParamByName('EMP_ID').AsString := UpdateUserID
      Else
        Params.ParamByName('EMP_ID').AsString := '0';
      Params.ParamByName('RP_ID').AsString := RpID;
      Execute;
    end;
    Result := True;
  end;

begin
  If Trim(editName.Text) = '' Then
  begin
    MessageDlg('Report Name Error !!',mtError, [mbCancel],0);
    editName.SetFocus ;
    Exit;
  end;

  IF (editFile.Text <> '') and (editFile.Text <> SampleFileName) Then
    If not FileExists(editFile.Text) Then
    begin
      MessageDlg('Report Sample File not Exists !!' ,mtError, [mbCancel],0);
      Exit;
    end;

  If RpID = '' Then
  begin
    If not AddReportName Then
      Exit;

  end else
  begin
    If not ModiReportName Then
      Exit;
  end;

  FCID := GetFactoryID;

  // 紀錄 Report 參數
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'RP_ID', ptInput);
    Params.CreateParam(ftString	,'PARAM_TYPE', ptInput);
    Params.CreateParam(ftString	,'PARAM_NAME', ptInput);
    Params.CreateParam(ftString	,'PARAM_VALUE', ptInput);
    Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
    CommandText := 'Insert Into SAJET.SYS_REPORT_PARAM '+
                     ' (RP_ID,PARAM_TYPE,PARAM_NAME,PARAM_VALUE,UPDATE_USERID) '+
                   'Values '+
                     ' (:RP_ID,:PARAM_TYPE,:PARAM_NAME,:PARAM_VALUE,:UPDATE_USERID) ';
  end;

  SaveReportParams(RpID, 'Query Condition', 'FACTORY_ID',FcID );
  // Production_Line
  For iCnt := 0 to StrLstPdLine.Count - 1 do
    SaveReportParams(RpID, 'Query Condition', 'PDLINE_ID',StrLstPdLine.Strings[iCnt] );
  // Part No
  For iCnt := 0 to StrLstPart.Count - 1 do
    SaveReportParams(RpID, 'Query Condition', 'PART_ID',StrLstPart.Strings[iCnt] );
  // Date Style
  SaveReportParams(RpID, 'Date Style', 'Date Style',cmbDateStyle.Text );

  S := 'N';
  If ChkDate.Checked Then S := 'Y';
  SaveReportParams(RpID, 'Display Information', 'Date', S );

  S := 'N';
  If ChkLine.Checked Then S := 'Y';
  SaveReportParams(RpID, 'Display Information', 'Production Line', S );

  S := 'N';
  If ChkWO.Checked Then S := 'Y';
  SaveReportParams(RpID, 'Display Information', 'Work Order', S );

  S := 'N';
  If ChkPart.Checked Then S := 'Y';
  SaveReportParams(RpID, 'Display Information', 'Part No', S );

  For iCnt := 0 to ListSort.Items.Count - 1 do
    SaveReportParams(RpID, 'Sort Condition', ListSort.Items[iCnt],IntToStr(iCnt) );

  SaveReportParams(RpID, 'Chart Set', 'Main', cmbMain.Text );
  SaveReportParams(RpID, 'Chart Set', 'Second', cmbSecond.Text );
    
  Close;
end;

procedure TfOutputCfg.cmbFactoryChange(Sender: TObject);
begin
 //  FcID := GetFactoryID;
end;

procedure TfOutputCfg.sbtnLineClick(Sender: TObject);
Var I : Integer;
begin
  With QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select PDLINE_ID,PDLINE_NAME '+
                   'From SAJET.SYS_PDLINE '+
                   'Where Enabled = ''Y'' '+
                   'Order By PDLINE_NAME ';
    Open;
  end;

  With TfSelect.Create(Self) do
  begin
     LvItems.Clear;
     StrLstTemp.Clear;
     While not QryTemp.Eof do
     begin
       With LvItems.Items.Add do
         Caption := QryTemp.Fieldbyname('PDLINE_NAME').AsString;
       StrLstTemp.Add(QryTemp.Fieldbyname('PDLINE_ID').AsString);
       qryTemp.Next;
     end;
     QryTemp.Close;
     If Showmodal = mrOK Then
     begin
       StrLstPdLine.Clear;
//       ListPdLine.Items.Clear;
       for I := 0 to LvItems.Items.Count - 1 do
       begin
         If LvITems.Items[I].Selected Then
         begin
//           ListPdLine.Items.Add(LvITems.Items[I].Caption);
           StrLstPdLine.Add(StrLstTemp.Strings[I]);
         end;
       end;
     end;
     Free;
  end;
end;

procedure TfOutputCfg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StrLstPdLine.Free;
  StrLstPart.Free;
  StrLstTemp.Free;
end;

procedure TfOutputCfg.sbtnImportClick(Sender: TObject);
begin
   If OpenDialog1.Execute Then
      editFile.Text := OpenDialog1.FileName;
end;

procedure TfOutputCfg.sbtnModelClick(Sender: TObject);
Var I : Integer;
begin
{  With QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select PART_ID,PART_NO '+
                   'From SAJET.SYS_PART '+
                   'Where Enabled = ''Y'' '+
                   'Order By PART_NO ';
    Open;
  end;

  With TfSelect.Create(Self) do
  begin
     LvItems.Clear;
     StrLstTemp.Clear;
     While not QryTemp.Eof do
     begin
       With LvItems.Items.Add do
         Caption := QryTemp.Fieldbyname('PART_NO').AsString;
       StrLstTemp.Add(QryTemp.Fieldbyname('PART_ID').AsString);
       qryTemp.Next;
     end;
     QryTemp.Close;
     If Showmodal = mrOK Then
     begin
       StrLstPart.Clear;
       ListPart.Items.Clear;
       for I := 0 to LvItems.Items.Count - 1 do
       begin
         If LvITems.Items[I].Selected Then
         begin
           ListPart.Items.Add(LvITems.Items[I].Caption);
           StrLstPart.Add(StrLstTemp.Strings[I]);
         end;
       end;
     end;
     Free;
  end;}
end;

procedure TfOutputCfg.sbtnSortClick(Sender: TObject);
var I : Integer;
begin
   With TfSort.Create(Self) do
   begin
     LvItems.Items.Clear;
     If ChkDate.Checked Then
       With LvItems.Items.Add do
         Caption := 'Date';
     If ChkLine.Checked Then
       With LvItems.Items.Add do
         Caption := 'Production Line';
     If ChkWO.Checked Then
       With LvItems.Items.Add do
         Caption := 'Work Order';
     If ChkPart.Checked Then
       With LvItems.Items.Add do
         Caption := 'Part No';

     If ShowModal = mrOK Then
     begin
       ListSort.Items.Clear;
       For I := 0 To LvSort.Items.Count - 1 do
         ListSort.Items.Add(LvSort.Items[I].Caption);
     end;
     Free;
   end;
end;

procedure TfOutputCfg.cmbMainDropDown(Sender: TObject);
begin
   cmbMain.Clear;
   if ChkDate.Checked then
      cmbMain.Items.Add('Date');
   if ChkLine.Checked then
      cmbMain.Items.Add('Production Line');
   if ChkWO.Checked then
      cmbMain.Items.Add('Work Order');
   if ChkPart.Checked then
      cmbMain.Items.Add('Part No');
end;

procedure TfOutputCfg.cmbSecondDropDown(Sender: TObject);
begin
   {cmbSecond.Clear;
   cmbSecond.Items.Add('');
   if ChkDate.Checked then
      cmbSecond.Items.Add('Date');
   if ChkLine.Checked then
      cmbSecond.Items.Add('Production Line');
   if ChkWO.Checked then
      cmbSecond.Items.Add('Work Order');
   if ChkPart.Checked then
      cmbSecond.Items.Add('Part No');}
end;

procedure TfOutputCfg.ChkDateClick(Sender: TObject);
begin
   if (Sender as TCheckBox).Name = 'ChkLine' then
   begin
      if not ChkLine.Checked then
         if cmbMain.Text = 'Production Line' then
            cmbMain.ItemIndex := -1;
   end
   else if (Sender as TCheckBox).Name = 'ChkPart' then
   begin
      if not ChkPart.Checked then
         if cmbMain.Text = 'Part No' then
            cmbMain.ItemIndex := -1;
   end
   else if (Sender as TCheckBox).Name = 'ChkWO' then
   begin
      if not ChkWO.Checked then
         if cmbMain.Text = 'Work Order' then
            cmbMain.ItemIndex := -1;
   end
   else if (Sender as TCheckBox).Name = 'ChkDate' then
   begin
      if not ChkDate.Checked then
         if cmbMain.Text = 'Date' then
            cmbMain.ItemIndex := -1;
   end;
end;

end.
