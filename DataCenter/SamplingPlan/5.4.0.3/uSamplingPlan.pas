unit uSamplingPlan;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ImgList,
  ComCtrls, Db, DBClient, MConnect, SConnect, Menus, ObjBrkr;

type
  TfSamplingPlan = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    cmbRoute: TComboBox;
    Label4: TLabel;
    ImageList2: TImageList;
    Label1: TLabel;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    LvName: TListView;
    LvDetail: TListView;
    editName: TEdit;
    Image3: TImage;
    Image4: TImage;
    Image7: TImage;
    Image5: TImage;
    LsRowid: TListBox;
    SaveDialog1: TSaveDialog;
    Sproc: TClientDataSet;
    sbtnAppend: TSpeedButton;
    sbtnModify: TSpeedButton;
    sbtnDelete: TSpeedButton;
    sbtnExport: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure LvNameClick(Sender: TObject);
    procedure editNameChange(Sender: TObject);
    procedure sbtnAppendClick(Sender: TObject);
    procedure sbtnModifyClick(Sender: TObject);
    procedure sbtnDeleteClick(Sender: TObject);
    procedure LvDetailClick(Sender: TObject);
    procedure sbtnExportClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
    Authoritys,AuthorityRole : String;
    SelectType : String;   // SamplingName, SamplingDetail
    Procedure ShowSamplingPlan;
    Procedure ShowDetail(PlanName : String);
    Function  GetMaxPlanID : String;
    Function GetSamplingPlanID(PlanName : String) : String;
    Procedure SetStatusbyAuthority;
  end;

var
  fSamplingPlan: TfSamplingPlan;

implementation

{$R *.DFM}
uses uData,uNameData;

Procedure TfSamplingPlan.SetStatusbyAuthority;
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
       Params.ParamByName('FUN').AsString := 'Sampling Plan Define';
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
  sbtnModify.Enabled := (iPrivilege >=1);
  sbtnDelete.Enabled := (iPrivilege >=1);

end;

Procedure TfSamplingPlan.ShowSamplingPlan;
begin
  LvName.Items.Clear;
  With QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select SAMPLING_ID,SAMPLING_TYPE,SAMPLING_DESC '+
                   'From SAJET.SYS_QC_SAMPLING_PLAN '+
                   'Where ENABLED = ''Y'' '+
                   'Group By SAMPLING_ID,SAMPLING_TYPE,SAMPLING_DESC '+
                   'Order By SAMPLING_TYPE';
    Open;
    if RecordCount > 0 then
    begin
       While not Eof do
       begin
          With LvName.Items.Add do
          begin
            Caption := FieldByName('SAMPLING_TYPE').asstring;
            SubItems.Add( FieldByName('SAMPLING_DESC').asstring);
            SubItems.Add( FieldByName('SAMPLING_ID').asstring);
          end;
          Next;
       end;
    end;
    Close;
  end;
end;

Procedure TfSamplingPlan.ShowDetail(PlanName : String);
var mS: string;
begin
  LvDetail.Items.Clear;
  LsRowid.Items.Clear;
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'PLANNAME', ptInput);
    CommandText := 'Select B.MIN_LOT_SIZE,B.MAX_LOT_SIZE,C.SAMPLING_GRADE,B.rowid '
                 + 'From SAJET.SYS_QC_SAMPLING_PLAN A, '
                 + '     SAJET.SYS_QC_SAMPLING_PLAN_DETAIL B, '
                 + '     SAJET.SYS_QC_SAMPLING_GRADE C '
                 + 'Where A.SAMPLING_ID = B.SAMPLING_ID '
                 + 'and A.SAMPLING_TYPE = :PLANNAME '
                 + 'and B.sampling_grade_id = C.sampling_grade_id(+) '
                 + 'group by B.MIN_LOT_SIZE,B.MAX_LOT_SIZE,C.SAMPLING_GRADE,B.rowid '
                 + 'Order By B.MIN_LOT_SIZE ';
    Params.ParamByName('PLANNAME').AsString := PlanName;
    Open;
    While not eof do
    begin
      With LvDetail.Items.Add do
      begin
        Caption := FieldByName('MIN_LOT_SIZE').asstring + ' ~ ' + FieldByName('MAX_LOT_SIZE').asstring;
        SubItems.Add(FieldByName('SAMPLING_GRADE').asstring);
      end;
      LsRowid.Items.Add(FieldByName('ROWID').asstring);
      Next;
    end;
    Close;
  end;
end;

Function TfSamplingPlan.GetMaxPlanID : String;
Var DBID : String;
begin
  With QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select NVL(Max(SAMPLING_ID),0) + 1 SAMPLING_ID '+
                   'From SAJET.SYS_QC_SAMPLING_PLAN ' ;
    Open;
    If Fieldbyname('SAMPLING_ID').AsString = '1' Then
    begin
       Close;
       CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || ''0001'' SAMPLING_ID '+
                      'From SAJET.SYS_BASE '+
                      'Where PARAM_NAME = ''DBID'' ' ;
       Open;
    end;
    Result := Fieldbyname('SAMPLING_ID').AsString;
    Close;
  end;
end;

procedure TfSamplingPlan.FormShow(Sender: TObject);
begin
  ShowSamplingPlan;
  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;
end;

procedure TfSamplingPlan.LvNameClick(Sender: TObject);
begin
  LvName.Color := $0080FFFF;
  LvDetail.Color := clWindow;

  If LvName.Selected = nil Then Exit;
  editName.Text := LvName.Selected.Caption;
  ShowDetail(LvName.Selected.Caption);
  SelectType := 'SamplingName';
end;

procedure TfSamplingPlan.editNameChange(Sender: TObject);
var mItem : TListItem;
begin
  LvDetail.Items.Clear;
  If LvName.FindCaption(0,editName.Text,True, True, True) <> nil then
    ShowDetail(editName.Text);
end;

procedure TfSamplingPlan.sbtnAppendClick(Sender: TObject);
begin
  If Trim(editName.Text) = '' Then Exit;

  With TfData.Create(Self) do
  begin
    ShowType := 'Append';
    LabName.Caption := editName.Text;
    Showmodal;
    Free;
  end;
  ShowDetail(editName.Text);
  If LvDetail.Items.Count > 0 Then
    ShowSamplingPlan;
end;

procedure TfSamplingPlan.sbtnModifyClick(Sender: TObject);
Var S,sMin,sMax : String;
begin
  If SelectType = 'SamplingName' Then
  begin
    if LVName.selected = nil then
      exit;

    With TfNameData.Create(Self) do
    begin
      SamplingPlanID:= LvName.Selected.subitems[1];
      editSamplingName.Text := LvName.Selected.Caption;
      editSamplingDesc.Text := LvName.Selected.subitems[0];
      if Showmodal = mrOK then
        ShowSamplingPlan;
      Free;
    end;
  end else
  begin
    If Trim(editName.Text) = '' Then Exit;
    If LvDetail.Selected = nil Then Exit;

    With TfData.Create(Self) do
    begin
      ShowType := 'Modi';
      LabName.Caption := editName.Text;
      S := LvDetail.Selected.Caption;
      sMin := Trim(Copy(S,1,Pos('~',S)-1));
      sMax := Trim(Copy(S,Pos('~',S)+1,Length(S)-Pos('~',S)));
      editMin.Text := sMin;
      editMax.Text := sMax;
      combGrade.ItemIndex:= combGrade.Items.IndexOf(LvDetail.Selected.SubItems[0]);
      RowId := LsRowid.Items.Strings[LvDetail.Selected.Index];
      combGradeChange(self);
      Showmodal;
      Free;
    end;
    ShowDetail(editName.Text);
  end;  
end;

Function TfSamplingPlan.GetSamplingPlanID(PlanName : String) : String;
begin
  Result := '0';
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'PLANNAME', ptInput);
    CommandText := 'Select SAMPLING_ID '+
                   'From SAJET.SYS_QC_SAMPLING_PLAN '+
                   'Where SAMPLING_TYPE = :PLANNAME ';
    Params.ParamByName('PLANNAME').AsString := PlanName;
    Open;
    If RecordCount > 0 Then
      Result := Fieldbyname('SAMPLING_ID').AsString;
    Close;
  end;
end;

procedure TfSamplingPlan.sbtnDeleteClick(Sender: TObject);
Var PID,S,sMin,sMax : String;
begin
  If SelectType = 'SamplingName' Then
  begin
    If LvName.Selected = nil Then
      Exit;

    If MessageDlg('Delete This Sampling Plan ?' + #13#10 +
                  LvName.Selected.Caption ,mtCustom, mbOKCancel,0) <> mrOK Then
      Exit;

    PID := GetSamplingPlanID(LvName.Selected.Caption);
    If PID = '0' Then
    begin
      MessageDlg('Get Sampling Plan ID Error !!' ,mtCustom, [mbOK] ,0);
      Exit;
    end;

    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'SAMPLING_ID', ptInput);
      CommandText := 'Delete SAJET.SYS_QC_SAMPLING_PLAN_DETAIL '+
                     'Where SAMPLING_ID = :SAMPLING_ID ';
      Params.ParamByName('SAMPLING_ID').AsString := PID;
      Execute;

      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'SAMPLING_ID', ptInput);
      CommandText := 'Delete SAJET.SYS_QC_SAMPLING_PLAN '+
                     'Where SAMPLING_ID = :SAMPLING_ID ';
      Params.ParamByName('SAMPLING_ID').AsString := PID;
      Execute;
      close;
      
      LvDetail.Items.Clear;
      LvName.Selected.Delete ;
      editName.Text := '';
    end;
  end;

  If SelectType = 'SamplingDetail' Then
  begin
    If LvName.Selected = nil Then
      Exit;
    If LvDetail.Selected = nil Then
      Exit;

    S := LvDetail.Selected.Caption;
    sMin := Trim(Copy(S,1,Pos('~',S)-1));
    sMax := Trim(Copy(S,Pos('~',S)+1,Length(S)-Pos('~',S)));

    If MessageDlg('Delete This Record ?' + #13#10 +
                  'Sampling Plan : '+LvName.Selected.Caption+ #13#10 +
                  S ,mtCustom, mbOKCancel,0) <> mrOK Then
      Exit;

    PID := GetSamplingPlanID(LvName.Selected.Caption);
    If PID = '0' Then
    begin
      MessageDlg('Get Sampling Plan ID Error !!' ,mtCustom, [mbOK] ,0);
      Exit;
    end;

    With QryTemp do
    begin
      try
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'SAMPLING_ID', ptInput);
        CommandText := 'Delete SAJET.SYS_QC_SAMPLING_PLAN_DETAIL '
                     + 'Where SAMPLING_ID = :SAMPLING_ID '
                     + 'and MIN_LOT_SIZE = :MIN_LOT_SIZE '
                     + 'and MAX_LOT_SIZE = :MAX_LOT_SIZE ';
        Params.ParamByName('SAMPLING_ID').AsString := PID;
        Params.ParamByName('MIN_LOT_SIZE').AsString := sMin;
        Params.ParamByName('MAX_LOT_SIZE').AsString := sMax;
        Execute;
        LvDetail.Selected.Delete;
        
        //檢查抽驗計畫各等級是否都沒有detail資料了
        close;
        Params.Clear;
        Params.CreateParam(ftString	,'SAMPLING_ID', ptInput);
        CommandText:=' SELECT SAMPLING_ID FROM SAJET.SYS_QC_SAMPLING_PLAN_DETAIL '
                    +'  Where SAMPLING_ID = :SAMPLING_ID  '
                    +'    AND ROWNUM = 1 ';
        Params.ParamByName('SAMPLING_ID').AsString := PID;
        Open;

        If eof Then
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString	,'SAMPLING_ID', ptInput);
          CommandText := 'Delete SAJET.SYS_QC_SAMPLING_PLAN '+
                         'Where SAMPLING_ID = :SAMPLING_ID ';
          Params.ParamByName('SAMPLING_ID').AsString := PID;
          Execute;

          LvName.Selected.Delete ;
          editName.Text := '';
        end;
      finally
        close;
      end;
    end;//with
  end;
end;

procedure TfSamplingPlan.LvDetailClick(Sender: TObject);
begin
  SelectType := 'SamplingDetail';

  LvDetail.Color := $0080FFFF;
  LvName.Color := clWindow;
end;

procedure TfSamplingPlan.sbtnExportClick(Sender: TObject);
Var F : TextFile;
    S : String;
    I : Integer;
begin
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'csv';
  SaveDialog1.Filter := 'All Files(*.csv)|*.csv';
  If SaveDialog1.Execute Then
  begin
     AssignFile(F,SaveDialog1.FileName);
     Rewrite(F);

     S := LvName.Columns[0].Caption
        + ',' + LvDetail.Columns[0].Caption
        + ',' + LvDetail.Columns[1].Caption;
     Writeln(F,S);

     For I := 0 To LvDetail.Items.Count - 1 do
     begin
        S := LvName.Selected.Caption
           + ',' +LvDetail.Items[I].Caption
           + ',' + LvDetail.Items[I].SubItems[0];
        Writeln(F,S);
     end;
     MessageDlg('Export OK !!',mtCustom, [mbOK],0);
     CloseFile(F);
  end;
end;

end.

