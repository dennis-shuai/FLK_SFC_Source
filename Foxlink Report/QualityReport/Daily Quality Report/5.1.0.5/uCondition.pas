unit uCondition;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
IniFiles, DB, DBClient, StdCtrls, Buttons, ComCtrls, ExtCtrls,Dialogs, jpeg;

type
  TfCondition = class(TForm)
    ConditionDataSet: TClientDataSet;
    PageFilter: TPageControl;
    TabSheet2: TTabSheet;
    EditSN: TEdit;
    CombType: TComboBox;
    SpeedButton1: TSpeedButton;
    Memo1: TMemo;
    Panel1: TPanel;
    Button3: TSpeedButton;
    Image3: TImage;
    Image4: TImage;
    Label1: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBGrid1KeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EditSNDblClick(Sender: TObject);
    procedure EditSNKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure CombTypeChange(Sender: TObject);
    procedure PageFilterChange(Sender: TObject);
    procedure Button3Click(Sender: TObject);

  private
    { Private declarations }
    cost1 : TDateTime;
    sClearFlag : Boolean;
    procedure fClose;
  public
    { Public declarations }      
    Function Condition(S_Str,Condition_Str,sFlag : String) : Boolean;
    Function ADDFilter : Boolean;
    Function ConfirmData(C_Str,T_Str,cStrID,cStrName,cStrName2,cDesc: String): Boolean;
  end;

var
  fCondition: TfCondition;

implementation

uses
  uMainForm,uFilter, uFilterProcess;

{$R *.dfm}

procedure TfCondition.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fClose;
  Action := caFree;
end;

procedure TfCondition.DBGrid1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#27 then
    close;
end;

procedure TfCondition.SpeedButton1Click(Sender: TObject);
begin
  cost1:=time();
  Condition(CombType.Text,editSN.Text,'1');
end;

procedure TfCondition.FormShow(Sender: TObject);
begin
  ADDFilter;
  EditSN.SetFocus;
end;

procedure TfCondition.EditSNDblClick(Sender: TObject);
begin
  EditSN.SelectAll;
  EditSN.SetFocus;
end;

procedure TfCondition.EditSNKeyPress(Sender: TObject; var Key: Char);
begin
  if (key <> #13) or (editSN.Text='')  then exit;
  cost1:=time();
  Condition(CombType.Text,editSN.Text,'0');
  EditSN.SelectAll;
  EditSN.SetFocus;
end;

procedure TfCondition.Button1Click(Sender: TObject);
begin
  fMainForm.StrLstModel.Clear;
  fMainForm.StrLstProcess.Clear;
  fMainForm.StrLstDefect.Clear;
  fMainForm.stModel:='';
  Memo1.Clear;
  sClearFlag:=True;
  fMainForm.EditModel.Text:='';
  fMainForm.EditProcess.Text:='';
  fMainForm.EditStage.Text:='';
  fMainForm.EditDefect.Text:='';
end;

Function TfCondition.Condition(S_Str,Condition_Str,sFlag : String): Boolean;
Var sID,sName,sName2,cDesc : String;
    i : Integer;
begin
  sID:='';
  sName:='';
  sName2:='';
  cDesc:='';
  Result:=False;
  if S_Str='Model Name' then
  begin
    with ConditionDataSet do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'MODEL', ptInput);
      CommandText := ' SELECT DISTINCT MODEL_NAME,MODEL_DESC1,MODEL_DESC2,MODEL_ID '+
                     ' FROM SAJET.SYS_MODEL '+
                     ' WHERE ENABLED=''Y'' '+
                     '   AND MODEL_NAME LIKE :MODEL '+
                     ' ORDER BY MODEL_NAME ';
      Params.ParamByName('MODEL').AsString := Condition_Str+'%';
      Open;
      if (RecordCount=1) and (Condition_Str=Fieldbyname('MODEL_NAME').AsString) then
      begin
        sID:=Fieldbyname('MODEL_ID').AsString;
        sName:=Fieldbyname('MODEL_NAME').AsString;
      end;
    end;
  end
  else if S_Str='Defect Code' then
  begin
    with ConditionDataSet do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'MODEL', ptInput);
      CommandText := ' SELECT  DEFECT_CODE,DEFECT_DESC,DEFECT_ID '+
                     ' FROM SAJET.SYS_DEFECT '+
                     ' WHERE ENABLED=''Y'' '+
                     '   AND DEFECT_CODE LIKE :MODEL '+
                     ' ORDER BY DEFECT_CODE ';
      Params.ParamByName('MODEL').AsString := Condition_Str+'%';
      Open;
      if (RecordCount=1) and (Condition_Str=Fieldbyname('DEFECT_CODE').AsString) then
      begin
        sID:=Fieldbyname('DEFECT_ID').AsString;
        sName:=Fieldbyname('DEFECT_CODE').AsString;
        cDesc:=Fieldbyname('DEFECT_DESC').AsString;
      end;
    end;
  end
  else if S_Str='Process Name' then
  begin
    with ConditionDataSet do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PROCESS', ptInput);
      CommandText := ' SELECT DISTINCT A.PROCESS_NAME,A.PROCESS_CODE,B.STAGE_NAME,A.PROCESS_ID '+
                     ' FROM SAJET.SYS_PROCESS A,SAJET.SYS_STAGE B '+
                     ' WHERE A.ENABLED=''Y'' AND B.ENABLED=''Y'' AND A.STAGE_ID=B.STAGE_ID '+
                     '   AND A.PROCESS_NAME LIKE :PROCESS '+
                     ' ORDER BY PROCESS_NAME ';
      Params.ParamByName('PROCESS').AsString := Condition_Str+'%';
      Open;
      if (RecordCount=1) and (Condition_Str=Fieldbyname('PROCESS_NAME').AsString) then
      begin
        sID:=Fieldbyname('PROCESS_ID').AsString;
        sName:=Fieldbyname('PROCESS_NAME').AsString;
        sName2:=Fieldbyname('STAGE_NAME').AsString;
      end;
    end;
  end;
  if (sID<>'') and (sName<>'') and (sFlag='0') then
  begin
     if not ConfirmData(S_Str,'=',sID,sName,sName2,cDesc) then exit;
     ADDFilter;
     sClearFlag:=True;
  end
  else if  (sFlag='1') or ((sFlag='0') and (ConditionDataSet.RecordCount>1)) then
  begin
    with TfFilter.Create(Self) do
    begin
      ClientDataSet1.RemoteServer := ConditionDataSet.RemoteServer;
      ClientDataSet1.ProviderName := 'DspQryData';
      ClientDataSet1.Data:=ConditionDataSet.Data;
      F_Str:=CombType.Text;
      cost2:=cost1;
      R_Str:='=';
      if Showmodal = mrOK then
      begin
        ClientDataSet1.Data:=NULL;
        ClientDataSet1.Close;
        ADDFilter;
        sClearFlag:=True;
      end;
      EditSN.SelectAll;
      EditSN.SetFocus;
    end;
  end
  else if (sFlag='0') and (sID='') and (sName='') then
  begin
    MessageDlg(S_Str+' Error',mtError, [mbCancel],0);
    exit;
  end;
  Result:=True;
end;

Function TfCondition.ConfirmData(C_Str,T_Str,cStrID,cStrName,cStrName2,cDesc: String) : Boolean;
begin
  Result:=False;
  if C_Str='Model Name' then
  begin
    if fMainForm.StrLstModel.IndexOf(T_Str+''''+cStrID)=-1 then
    begin
      fMainForm.StrLstModel.Clear;
      fMainForm.stModel:='';
      fMainForm.StrLstModel.Add(T_Str+''''+cStrID);
      if T_Str='=' then T_Str:='';
      fMainForm.stModel:=fMainForm.stModel+' ,'+T_Str+cStrName;
    end else
    begin
      MessageDlg('Duplicate',mtError, [mbCancel],0);
      exit;
    end;
  end
  else if C_Str='Process Name' then
  begin
    if fMainForm.StrLstProcess.IndexOf(T_Str+''''+cStrID)=-1 then
    begin
      fMainForm.StrLstProcess.Add(T_Str+''''+cStrID);
      if T_Str='=' then T_Str:='';
      fMainForm.StrLstProcessName.Add(cStrName);
      fMainForm.StrLstStageName.Add(cStrName2);
    end else
    begin
      MessageDlg('Duplicate ',mtError, [mbCancel],0);
      exit;
    end;
  end
  else if C_Str='Defect Code' then
  begin
    if fMainForm.StrLstDefect.IndexOf(T_Str+''''+cStrID)=-1 then
    begin
      fMainForm.StrLstDefect.Add(T_Str+''''+cStrID);
      fMainForm.StrLstDefectName.Add(cStrName+'  ||  '+cDesc);
    end else
    begin
      MessageDlg('Duplicate ',mtError, [mbCancel],0);
      exit;
    end;
  end;
  Result:=True;
end;

Function TfCondition.ADDFilter : Boolean;
Var sStrTmp : String;
    iTmp : Integer;
begin
  Result:=False;
  sStrTmp:='';
  if CombType.Items.IndexOf(fMainForm.stIndexType)<>-1 then
    CombType.ItemIndex:=CombType.Items.IndexOf(fMainForm.stIndexType)
  else
    CombType.ItemIndex:=0;
  Memo1.Clear;
  if fMainForm.stModel<>'' then
  begin
    sStrTmp:=Copy(fMainForm.stModel,3,Length(fMainForm.stModel));
    Memo1.Lines.Add('Model Name: '+ sStrTmp);
    Memo1.Lines.Add('');
  end;
  if fMainForm.StrLstDefectName.Count>0 then
  begin
    sStrTmp:='';
    for iTmp:=0 to fMainForm.StrLstDefectName.Count-1 do
       sStrTmp:=sStrTmp+','+Copy(fMainForm.StrLstDefectName.Strings[iTmp],1,Pos('  ||  ',fMainForm.StrLstDefectName.Strings[iTmp]));
    sStrTmp:=Copy(sStrTmp,2,Length(sStrTmp));
    Memo1.Lines.Add('Defect Code: '+ sStrTmp);
    Memo1.Lines.Add('');
  end;
  if fMainForm.StrLstProcessName.Count>0 then
  begin  
    sStrTmp:='';
    for iTmp:=0 to fMainForm.StrLstStageName.Count-1 do
      sStrTmp:=sStrTmp+','+fMainForm.StrLstStageName.Strings[iTmp];
    sStrTmp:=Copy(sStrTmp,2,Length(sStrTmp));
    Memo1.Lines.Add('Stage Name: '+ sStrTmp);
    Memo1.Lines.Add('');

    sStrTmp:='';
    for iTmp:=0 to fMainForm.StrLstProcessName.Count-1 do
      sStrTmp:=sStrTmp+','+fMainForm.StrLstProcessName.Strings[iTmp];
    sStrTmp:=Copy(sStrTmp,2,Length(sStrTmp));
    Memo1.Lines.Add('Process Name: '+ sStrTmp);
    Memo1.Lines.Add('');
  end;
  Result:=True;
end;

procedure TfCondition.CombTypeChange(Sender: TObject);
begin
  EditSN.SelectAll;
  EditSN.SetFocus;
end;

procedure TfCondition.PageFilterChange(Sender: TObject);
begin
  if not (PageFilter.ActivePageIndex=1) then
  begin
    EditSN.SelectAll;
    EditSN.SetFocus;
  end;
end;

procedure TfCondition.fClose;
Var sStrTmp : String;
   slCondition : TStringList;
   iTmp : Integer;
begin
  fMainForm.stIndexType:='';
  sStrTmp:='';
  fMainForm.EditProcess.Text:='';
  fMainForm.EditStage.Text:='';
  fMainForm.EditModel.Text:='';
  fMainForm.EditDefect.Text:='';
  if (sClearFlag=True) then
  begin
    if (fMainForm.QryTemp.Data<>null) then
      fMainForm.ClearGrid;
  end;
  slCondition:= TStringList.Create;
  slCondition.AddStrings(CombType.Items);
  if fMainForm.stModel<>'' then
  begin
    sStrTmp:=Copy(fMainForm.stModel,3,Length(fMainForm.stModel));
    fMainForm.EditModel.Text:= sStrTmp;
    slCondition.Delete(slCondition.IndexOf('Model Name'));
  end;
  if fMainForm.StrLstDefectName.Count>0 then
  begin
    sStrTmp:='';
    for iTmp:=0 to fMainForm.StrLstDefectName.Count-1 do
     sStrTmp:=sStrTmp+','+Copy(fMainForm.StrLstDefectName.Strings[iTmp],1,Pos('  ||  ',fMainForm.StrLstDefectName.Strings[iTmp]));
    sStrTmp:=Copy(sStrTmp,2,Length(sStrTmp));
    fMainForm.EditDefect.Text:= sStrTmp;
    slCondition.Delete(slCondition.IndexOf('Defect Code'));
  end;
  if fMainForm.StrLstProcessName.Count>0 then
  begin
    sStrTmp:='';
    for iTmp:=0 to fMainForm.StrLstProcessName.Count-1 do
      sStrTmp:=sStrTmp+','+fMainForm.StrLstProcessName.Strings[iTmp];
    sStrTmp:=Copy(sStrTmp,2,Length(sStrTmp));
    fMainForm.EditProcess.Text:= sStrTmp;
    sStrTmp:='';
    for iTmp:=0 to fMainForm.StrLstStageName.Count-1 do
      sStrTmp:=sStrTmp+','+fMainForm.StrLstStageName.Strings[iTmp];
    sStrTmp:=Copy(sStrTmp,2,Length(sStrTmp));
    fMainForm.EditStage.Text:= sStrTmp;
    slCondition.Delete(slCondition.IndexOf('Process Name'));
  end;
  slCondition.Free;
end;

procedure TfCondition.Button3Click(Sender: TObject);
begin
  fClose;
  ModalResult := mrOK;
end;

end.
