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
    Fields: TTabSheet;
    listbAvail: TListBox;
    listbSelect: TListBox;
    GroupBox1: TGroupBox;
    IncludeBtn: TSpeedButton;
    ExcludeBtn: TSpeedButton;
    GroupBox2: TGroupBox;
    Panel1: TPanel;
    Button3: TSpeedButton;
    Image3: TImage;
    Image1: TImage;
    Button2: TSpeedButton;
    Image2: TImage;
    Button1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    ComboBox1: TComboBox;
    Image4: TImage;
    TabSheet1: TTabSheet;
    Image5: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBGrid1KeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EditSNDblClick(Sender: TObject);
    procedure EditSNKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure IncludeBtnClick(Sender: TObject);
    procedure ExcludeBtnClick(Sender: TObject);
    procedure listbAvailDblClick(Sender: TObject);
    procedure listbSelectDblClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure CombTypeChange(Sender: TObject);
    procedure PageFilterChange(Sender: TObject);

  private
    { Private declarations }
    cost1 : TDateTime;
    sClearFlag : Boolean;
    function  GetFirstSelection(List: TCustomListBox): Integer;
    procedure SetItem(List: TListBox; Index: Integer);
    procedure MoveSelected(List: TCustomListBox; Items: TStrings);
    procedure fClose;
  public
    { Public declarations }      
    Function Condition(S_Str,Condition_Str,sFlag : String) : Boolean;
    Function ADDFilter : Boolean;
    Function ConfirmData(C_Str,T_Str,cStrID,cStrName: String): Boolean;
  end;

var
  fCondition: TfCondition;

implementation

uses
  uMainForm,uFilter;

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
Var i : Integer;
  FilterFlag : Boolean;
begin
  ADDFilter;
  listbAvail.Items.Clear;
  for i:=0 to fMainForm.SfieldsAvail.Count-1 do
    listbAvail.Items.Add(fMainForm.SfieldsAvail.Strings[i]);

  listbSelect.Items.Clear;
  for i:=0 to fMainForm.SfieldsSelect.Count-1 do
    listbSelect.Items.Add(fMainForm.SfieldsSelect.Strings[i]);

  if fMainForm.stIndexType<>'' then
     CombType.ItemIndex:=CombType.Items.IndexOf(fMainForm.stIndexType);
  FilterFlag:=False;
  sClearFlag:=False;
  if fMainForm.stModel<>'' then
     FilterFlag:=True
  else if fMainForm.stCustomer<>'' then
     FilterFlag:=True
  else if fMainForm.stPart<>'' then
     FilterFlag:=True
  else if fMainForm.LstWO<>'' then
     FilterFlag:=True
  else if fMainForm.stSTAGE<>'' then
     FilterFlag:=True
  else if fMainForm.stPdLine<>'' then
     FilterFlag:=True
  else if fMainForm.stProcess<>'' then
     FilterFlag:=True;

  if fMainForm.strClick='2' then
  begin
    Button1.Visible:=False;
    Image2.Visible:=False;
    Button2.Visible:=True;
    Image1.Visible:=True;
    PageFilter.SelectNextPage(True);
  end else
  begin
    Button1.Visible:=True;
    Image2.Visible:=True;
    Button2.Visible:=False;
    Image1.Visible:=False;
    if FilterFlag=False then
      Button1.Enabled:=False;
    EditSN.SetFocus;
  end;
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
  fMainForm.StrLstPdLine.Clear;
  fMainForm.StrLstProcess.Clear;
  fMainForm.StrLstPart.Clear;
  fMainForm.StrLstModel.Clear;
  fMainForm.StrLstCustomer.Clear;
  fMainForm.StrLstWO.Clear;
  fMainForm.StrLstSTAGE.Clear; 
  fMainForm.stPdLine:='';
  fMainForm.stProcess:='';
  fMainForm.stPart:='';
  fMainForm.stModel:='';
  fMainForm.stCustomer:='';
  fMainForm.stSTAGE:='';
  fMainForm.LstWO:='';
  Memo1.Clear;
  sClearFlag:=True;
  with fMainForm.tsGrid1 do
  begin
    Cell[2,1]:= '';
    Cell[2,2]:= '';
    Cell[2,3]:= '';
    Cell[2,4]:= '';
    Cell[2,5]:= '';
    Cell[2,6]:= '';
    Cell[2,7]:= '';
  end;
end;

procedure TfCondition.IncludeBtnClick(Sender: TObject);
var
  index : Integer;
begin
  if listbAvail.Focused=False then
     listbAvail.Selected[0]:=True;
  if  listbAvail.Items.Count <> 0 then
  begin
    Index := GetFirstSelection(listbAvail);
    MoveSelected(listbAvail, listbSelect.Items);
    SetItem(listbAvail, index);
  end;
  Button2.Enabled:=True;
end;

function TfCondition.GetFirstSelection(List: TCustomListBox): Integer;
begin
  for Result := 0 to List.Items.Count - 1 do
    if List.Selected[Result] then Exit;
  Result := LB_ERR;
end;

procedure TfCondition.MoveSelected(List: TCustomListBox; Items: TStrings);
var
  I: Integer;
begin
  for I := List.Items.Count - 1 downto 0 do
    if (List.Selected[I]) Then
    begin
      if (Items.IndexOf(List.Items[i])<0) then
        Items.AddObject(List.Items[I], List.Items.Objects[I]);
      List.Items.Delete(I);
    end;
end;

procedure TfCondition.SetItem(List: TListBox; Index: Integer);
var
   MaxIndex: Integer;
begin
   with List do
   begin
      SetFocus;
      MaxIndex := List.Items.Count - 1;
      if Index = -1 then Index := 0
      else if Index > MaxIndex then Index := MaxIndex;
      if List.Count>0 then
        Selected[Index] := True;
   end;
end;

procedure TfCondition.ExcludeBtnClick(Sender: TObject);
var
  index: Integer;
begin
  if listbSelect.Focused=False then
     listbSelect.Selected[0]:=True;
  if listbSelect.Items.Count>1 then
  begin
    Index := GetFirstSelection(listbSelect);
    MoveSelected(listbSelect, listbAvail.Items);
    SetItem(listbSelect, index);
    SetItem(listbSelect, Index);
  end;
  Button2.Enabled:=True;
end;

procedure TfCondition.listbAvailDblClick(Sender: TObject);
begin
  IncludeBtnClick(Self);
end;

procedure TfCondition.listbSelectDblClick(Sender: TObject);
begin
  ExcludeBtnClick(Self);
end;

procedure TfCondition.Button2Click(Sender: TObject);
Var i,iCol,iRow,K : Integer;
    fInI: TIniFile;
    Str,sFlag,sTemp1 : String;
begin
  fMainForm.strCMD:='';
  fMainForm.strOrderCMD:='';
  fMainForm.strGroupCMD:='';
  fMainForm.QryTemp.Data:=NULL;
  fMainForm.ComboBox1.Clear;
  fMainForm.SfieldsSelect.Clear;
  fMainForm.SfieldsAvail.Clear;
  fInI:=TIniFile.Create('SAJETQuery.ini');
  fInI.EraseSection('WIP Available Fields');
  fInI.EraseSection('WIP Select Fields');
  for iCol:=1 to 2 do
    for iRow:=1 to 5 do
    fMainForm.tsGrid2.Cell[iCol,iRow]:='';

  if listbSelect.Items.Count> 0 then
  begin
    fInI.WriteString('WIP Select Fields', 'Count',IntToStr(listbSelect.Items.Count));
    K:=listbSelect.Items.Count;
    if K<=5 then
      fMainForm.tsGrid2.Cell[1,3] := 'Select Fields'
    else
      fMainForm.tsGrid2.Cell[1,1] := 'Select Fields';
    for i:=0 to listbSelect.Items.Count-1 do
    begin
      Str:=listbSelect.Items.Strings[i];
      fMainForm.SfieldsSelect.Add(Str);
      fMainForm.ComboBox1.Items.Add(Str);
      fInI.WriteString('WIP Select Fields', 'Str_' + IntToStr(i),Str);
      if (K>5) and (i<=(K-6)) then
      begin
         iCol:=1;
         iRow:=i+11-k;
      end
      else if (K>5) and (i>(K-6)) then
      begin
         iCol:=2;
         iRow:=i-(K-6);
      end
      else if K<=5 then
      begin
         iCol:=2;
         iRow:=i+1;
      end;
      if Str='Model Name' then
      begin
         fMainForm.strCMD:=fMainForm.strCMD+',B.MODEL_NAME "Model Name" ';
         fMainForm.strOrderCMD:=fMainForm.strOrderCMD+',"Model Name"';
         fMainForm.strGroupCMD:=fMainForm.strGroupCMD+',B.MODEL_NAME';
         fMainForm.tsGrid2.Cell[iCol,iRow] := 'Model Name';
      end
      else if Str='Customer Name' then
      begin
         fMainForm.strCMD:=fMainForm.strCMD+','+'C.CUSTOMER_NAME "Customer Name" ';
         fMainForm.strOrderCMD:=fMainForm.strOrderCMD+',"Customer Name"';
         fMainForm.strGroupCMD:=fMainForm.strGroupCMD+',C.CUSTOMER_NAME';
         fMainForm.tsGrid2.Cell[iCol,iRow] := 'Customer Name';
      end
      else if Str='Part No' then
      begin
         fMainForm.strCMD:=fMainForm.strCMD+','+'D.PART_NO "Part No" ';
         fMainForm.strOrderCMD:=fMainForm.strOrderCMD+',"Part No"';
         fMainForm.strGroupCMD:=fMainForm.strGroupCMD+',D.PART_NO';
         fMainForm.tsGrid2.Cell[iCol,iRow] := 'Part No';
      end
      else if Str='Work Order' then
      begin
         fMainForm.strCMD:=fMainForm.strCMD+','+'A.WORK_ORDER "Work Order" ';
         fMainForm.strOrderCMD:=fMainForm.strOrderCMD+',"Work Order"';
         fMainForm.strGroupCMD:=fMainForm.strGroupCMD+',A.WORK_ORDER';
         fMainForm.tsGrid2.Cell[iCol,iRow] := 'Work Order';
      end
      else if Str='Stage Name' then
      begin
         fMainForm.strCMD:=fMainForm.strCMD+','+'F.STAGE_NAME "Stage Name" ';
         fMainForm.strOrderCMD:=fMainForm.strOrderCMD+',"Stage Name"';
         fMainForm.strGroupCMD:=fMainForm.strGroupCMD+',F.STAGE_NAME';
         fMainForm.tsGrid2.Cell[iCol,iRow] := 'Stage Name';
      end
      else if Str='PDLine Name' then
      begin
         fMainForm.strCMD:=fMainForm.strCMD+','+'E.PDLINE_NAME "PDLine Name" ';
         fMainForm.strOrderCMD:=fMainForm.strOrderCMD+',"PDLine Name"';
         fMainForm.strGroupCMD:=fMainForm.strGroupCMD+',E.PDLINE_NAME';
         fMainForm.tsGrid2.Cell[iCol,iRow] := 'PDLine Name';
      end
      else if Str='Process Name' then
      begin
        sFlag:='N';
        sTemp1:='';
        for K:=0 to i-1 do
        begin
          if (listbSelect.Items.Strings[K] ='Part No') or
             (listbSelect.Items.Strings[K] ='Work Order') or
             (listbSelect.Items.Strings[K] ='Model Name') then
            sFlag:='Y'
          else if (listbSelect.Items.Strings[K] ='PDLine Name') then
            sTemp1:='CODE';
        end;
        if sFlag='Y' then
        begin
          fMainForm.strCMD:=fMainForm.strCMD+','+'G.PROCESS_NAME "Process Name",DECODE(K.SEQ,NULL,0,K.SEQ) SEQ ';
          fMainForm.strGroupCMD:=fMainForm.strGroupCMD+',G.PROCESS_NAME,DECODE(K.SEQ,NULL,0,K.SEQ) ';
          fMainForm.strOrderCMD:=fMainForm.strOrderCMD+',"SEQ"';
        end
        else if (sTemp1='CODE') and (sFlag='N') then
        begin
          fMainForm.strCMD:=fMainForm.strCMD+','+'G.PROCESS_NAME "Process Name",DECODE(G.PROCESS_CODE,NULL,0,G.PROCESS_CODE) PROCESS_CODE ';
          fMainForm.strGroupCMD:=fMainForm.strGroupCMD+',G.PROCESS_NAME,DECODE(G.PROCESS_CODE,NULL,0,G.PROCESS_CODE) ';
          fMainForm.strOrderCMD:=fMainForm.strOrderCMD+',"PROCESS_CODE"';
        end else
        begin
          fMainForm.strCMD:=fMainForm.strCMD+','+'G.PROCESS_NAME "Process Name" ';
          fMainForm.strGroupCMD:=fMainForm.strGroupCMD+',G.PROCESS_NAME ';
          fMainForm.strOrderCMD:=fMainForm.strOrderCMD+',"Process Name"';
        end;
        fMainForm.tsGrid2.Cell[iCol,iRow] := 'Process Name';
      end;
    end; 
  end;
  if listbAvail.Items.Count> 0 then
  begin
    fInI.WriteString('WIP Available Fields', 'Count' ,IntToStr(listbAvail.Items.Count)); 
    for i:=0 to listbAvail.Items.Count-1 do
    begin
      Str:=listbAvail.Items.Strings[i];
      fMainForm.SfieldsAvail.Add(Str);
      fInI.WriteString('WIP Available Fields', 'Str_' + IntToStr(i),Str);
    end;
  end;
  fInI.WriteString('WIP Report','FieldS-SQL',fMainForm.strCMD);
  fInI.WriteString('WIP Report','Order-SQL',fMainForm.strOrderCMD);
  fInI.WriteString('WIP Report','Group-SQL',fMainForm.strGroupCMD);
  fInI.Free;
  sClearFlag:=True;
  fMainForm.ComboBox1.ItemIndex:=fMainForm.ComboBox1.Items.Count-1;
  fMainForm.strClick:='1';
  Button2.Enabled:=False;
  ModalResult := mrOK;
end;

procedure TfCondition.Button3Click(Sender: TObject);
begin
  fClose;
  ModalResult := mrOK;
end;

procedure TfCondition.SpeedButton2Click(Sender: TObject);
var
  I: Integer;
begin
  if listbSelect.ItemIndex=-1 then
     listbSelect.Selected[0]:=True;
  if listbSelect.Selected[0]=True then exit;
  if listbSelect.Items.Count=1 then exit;  
  for I := listbSelect.Items.Count - 1 downto 0 do
  begin
    if (listbSelect.Selected[I]) Then
    begin
      listbSelect.Items.Move(I,I-1);
      break;
    end;
  end;
  listbSelect.Selected[I-1]:=True;
  Button2.Enabled:=True;
end;

procedure TfCondition.SpeedButton3Click(Sender: TObject);
var
  I: Integer;
begin
  if listbSelect.ItemIndex=-1 then
     listbSelect.Selected[0]:=True;
  if listbSelect.Selected[listbSelect.Items.Count - 1]=True then exit;
  if listbSelect.Items.Count=1 then exit;
  for I := listbSelect.Items.Count - 1 downto 0 do
  begin
    if (listbSelect.Selected[I]) Then
    begin
      listbSelect.Items.Move(I,I+1);
      break;
    end;
  end;
  listbSelect.Selected[I+1]:=True;
  Button2.Enabled:=True;
end;

Function TfCondition.Condition(S_Str,Condition_Str,sFlag : String): Boolean;
Var sID,sName : String;
begin
  sID:='';
  sName:='';
  Result:=False;
  if S_Str='Model Name' then
  begin
    with ConditionDataSet do
    begin
      Try
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
      except
        Close;
        MessageDlg('SAJET.SYS_MODEL NOT EXIST !!', mtError, [mbOK], 0);
        Exit;
      end;
      if (RecordCount=1) and (Condition_Str=Fieldbyname('MODEL_NAME').AsString) then
      begin
        sID:=Fieldbyname('MODEL_ID').AsString;
        sName:=Fieldbyname('MODEL_NAME').AsString;
      end;
    end;
  end
  else if S_Str='Customer Name' then
  begin
    with ConditionDataSet do
    begin
      Try
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'CUSTOMER', ptInput);
        CommandText := ' SELECT DISTINCT CUSTOMER_CODE,CUSTOMER_NAME, CUSTOMER_PASSWD ,CUSTOMER_ADDR, '+
                       '        CUSTOMER_TEL,CUSTOMER_ID  '+
                       ' FROM SAJET.SYS_CUSTOMER '+
                       ' WHERE ENABLED=''Y'' '+
                       '   AND CUSTOMER_NAME LIKE :CUSTOMER '+
                       ' ORDER BY CUSTOMER_NAME ';
        Params.ParamByName('CUSTOMER').AsString := Condition_Str+'%';
        Open;
      except
        MessageDlg('SAJET.SYS_CUSTOMER NOT EXIST !!', mtError, [mbOK], 0);
        Exit;
      end;
      if (RecordCount=1) and (Condition_Str=Fieldbyname('CUSTOMER_NAME').AsString) then
      begin
        sID:=Fieldbyname('CUSTOMER_ID').AsString;
        sName:=Fieldbyname('CUSTOMER_NAME').AsString;
      end;
    end;
  end
  else if S_Str='Part No' then
  begin
    with ConditionDataSet do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PART', ptInput);
      CommandText := ' SELECT PART_NO,CUST_PART_NO,PART_TYPE,MATERIAL_TYPE , SPEC1,SPEC2, '+
                     '        UPC,EAN,BURNIN_TIME ,VERSION,PART_ID  '+
                     ' FROM SAJET.SYS_PART '+
                     ' WHERE ENABLED=''Y'' '+
                     '   AND PART_NO LIKE :PART '+
                     ' ORDER BY PART_NO ';
      Params.ParamByName('PART').AsString := Condition_Str+'%';
      Open;
      if (RecordCount=1) and (Condition_Str=Fieldbyname('PART_NO').AsString) then
      begin
        sID:=Fieldbyname('PART_ID').AsString;
        sName:=Fieldbyname('PART_NO').AsString;
      end;
    end;
  end
  else if S_Str='Work Order' then
  begin
    with ConditionDataSet do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'MO', ptInput);
      CommandText := ' Select A.WORK_ORDER ,A.WO_TYPE,A.WO_RULE,A.TARGET_QTY,A.INPUT_QTY,A.OUTPUT_QTY, A.SCRAP_QTY,B.PART_NO,B.SPEC1, '+
                     '        B.SPEC2, A.VERSION, ' +
                     '        TO_CHAR(A.WO_CREATE_DATE,''YYYY/MM/DD HH24:MI:SS'') WO_CREATE_DATE, '+
                     '        TO_CHAR(A.WO_SCHEDULE_DATE,''YYYY/MM/DD HH24:MI:SS'') WO_SCHEDULE_DATE, '+
                     '        TO_CHAR(A.WO_START_DATE,''YYYY/MM/DD HH24:MI:SS'') WO_START_DATE, '+
                     '        TO_CHAR(A.WO_CLOSE_DATE,''YYYY/MM/DD HH24:MI:SS'') WO_CLOSE_DATE, '+
                     '        TO_CHAR(A.UPDATE_TIME,''YYYY/MM/DD HH24:MI:SS'') UPDATE_TIME, '+
                     '        TO_CHAR(A.WO_DUE_DATE,''YYYY/MM/DD'') WO_DUE_DATE '+
                     ' From SAJET.G_WO_BASE A,SAJET.SYS_PART B ' +
                     ' Where A.MODEL_ID=B.PART_ID AND B.ENABLED=''Y'' AND (A.WO_STATUS =''3'' or A.WO_STATUS =''4'' or A.WO_STATUS =''7'')  '+
                     //'   AND A.VERSION=B.VERSION  ' +
                     '   AND A.WORK_ORDER LIKE :MO '+
                     '   AND FACTORY_ID = '+fMainForm.FcID +
                     ' Order By WORK_ORDER ';
      Params.ParamByName('MO').AsString := Condition_Str+'%';
      Open;
      if (RecordCount=1) and (Condition_Str=Fieldbyname('WORK_ORDER').AsString) then
      begin
        sID:=Fieldbyname('WORK_ORDER').AsString;
        sName:=sID;
      end;
    end;
  end
  else if S_Str='Stage Name' then
  begin
    with ConditionDataSet do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'STAGE', ptInput);
      CommandText := ' Select STAGE_NAME ,STAGE_CODE,STAGE_DESC,STAGE_ID '+
                     ' From   SAJET.SYS_STAGE  ' +
                     ' Where ENABLED=''Y'' '+
                     '   AND STAGE_NAME LIKE :STAGE '+
                     ' Order By STAGE_NAME ';
      Params.ParamByName('STAGE').AsString := Condition_Str+'%';
      Open;
      if (RecordCount=1) and (Condition_Str=Fieldbyname('STAGE_NAME').AsString) then
      begin
        sID:=Fieldbyname('STAGE_ID').AsString;
        sName:=Fieldbyname('STAGE_NAME').AsString;
      end;
    end;
  end
  else if S_Str='PDLine Name' then
  begin
    with ConditionDataSet do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PDLINE', ptInput);
      CommandText := ' Select PDLINE_NAME,PDLINE_DESC,PDLINE_ID '+
                     ' From   SAJET.SYS_PDLINE  ' +
                     ' Where ENABLED=''Y'' '+
                     '   AND PDLINE_NAME LIKE :PDLINE '+
                     '   AND FACTORY_ID = '+fMainForm.FcID +
                     ' Order By PDLINE_NAME ';
      Params.ParamByName('PDLINE').AsString := Condition_Str+'%';
      Open;
      if (RecordCount=1) and (Condition_Str=Fieldbyname('PDLINE_NAME').AsString) then
      begin
        sID:=Fieldbyname('PDLINE_ID').AsString;
        sName:=Fieldbyname('PDLINE_NAME').AsString;
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
      CommandText := ' Select PROCESS_NAME,PROCESS_CODE,PROCESS_DESC,PROCESS_ID '+
                     ' From   SAJET.SYS_PROCESS  ' +
                     ' Where ENABLED=''Y'' '+
                     '   AND PROCESS_NAME LIKE :PROCESS '+
                     '   AND FACTORY_ID = '+fMainForm.FcID +
                     ' Order By PROCESS_NAME ';
      Params.ParamByName('PROCESS').AsString := Condition_Str+'%';
      Open;
      if (RecordCount=1) and (Condition_Str=Fieldbyname('PROCESS_NAME').AsString) then
      begin
        sID:=Fieldbyname('PROCESS_ID').AsString;
        sName:=Fieldbyname('PROCESS_NAME').AsString;
      end;
    end;
  end;
  if (sID<>'') and (sName<>'') and (sFlag='0') then
  begin
     if not ConfirmData(S_Str,ComboBox1.Text,sID,sName) then exit;
     ADDFilter;
     sClearFlag:=True;
     Button1.Enabled:=True;
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
      R_Str:=ComboBox1.Text;
      if Showmodal = mrOK then
      begin
        ClientDataSet1.Data:=NULL;
        ClientDataSet1.Close;
        ADDFilter;
        sClearFlag:=True;
        Button1.Enabled:=True;
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

Function TfCondition.ConfirmData(C_Str,T_Str,cStrID,cStrName: String) : Boolean;
begin
  Result:=False;
  if C_Str='Model Name' then
  begin
    if fMainForm.StrLstModel.IndexOf(T_Str+''''+cStrID)=-1 then
    begin
      fMainForm.StrLstModel.Add(T_Str+''''+cStrID);
      if T_Str='=' then T_Str:='';
      fMainForm.stModel:=fMainForm.stModel+' ,'+T_Str+cStrName;
    end else
    begin
      MessageDlg('Duplicate',mtError, [mbCancel],0);
      exit;
    end;
  end
  else if C_Str='Customer Name' then
  begin
    if fMainForm.StrLstCustomer.IndexOf(T_Str+''''+cStrID)=-1 then
    begin
      fMainForm.StrLstCustomer.Add(T_Str+''''+cStrID);
      if T_Str='=' then T_Str:='';
      fMainForm.stCustomer:=fMainForm.stCustomer+' ,'+T_Str+cStrName;
    end else
    begin
      MessageDlg('Duplicate ',mtError, [mbCancel],0);
      exit;
    end;
  end
  else if C_Str='Part No' then
  begin
    if fMainForm.StrLstPart.IndexOf(T_Str+''''+cStrID)=-1 then
    begin
      fMainForm.StrLstPart.Add(T_Str+''''+cStrID);
      if T_Str='=' then T_Str:='';
      fMainForm.stPart:=fMainForm.stPart+' ,'+T_Str+cStrName;
    end else
      begin
      MessageDlg('Duplicate ',mtError, [mbCancel],0);
      exit;
    end;
  end
  else if C_Str='Work Order' then
  begin
    if fMainForm.StrLstWO.IndexOf(T_Str+''''+cStrID)=-1 then
    begin
      fMainForm.StrLstWO.Add(T_Str+''''+cStrID);
      if T_Str='=' then T_Str:='';
      fMainForm.LstWO:=fMainForm.LstWO+' ,'+T_Str+cStrName;
    end else
    begin
      MessageDlg('Duplicate ',mtError, [mbCancel],0);
      exit;
    end;
  end
  else if C_Str='Stage Name' then
  begin
    if fMainForm.StrLstSTAGE.IndexOf(T_Str+''''+cStrID)=-1 then
    begin
      fMainForm.StrLstSTAGE.Add(T_Str+''''+cStrID);
      if T_Str='=' then T_Str:='';
      fMainForm.stSTAGE:=fMainForm.stSTAGE+' ,'+T_Str+cStrName;
    end else
    begin
      MessageDlg('Duplicate ',mtError, [mbCancel],0);
      exit;
    end;
  end
  else if C_Str='PDLine Name' then
  begin
    if fMainForm.StrLstPdLine.IndexOf(T_Str+''''+cStrID)=-1 then
    begin
      fMainForm.StrLstPdLine.Add(T_Str+''''+cStrID);
      if T_Str='=' then T_Str:='';
      fMainForm.stPdLine:=fMainForm.stPdLine+' ,'+T_Str+cStrName;
    end else
    begin
      MessageDlg('Duplicate ',mtError, [mbCancel],0);
      exit;
    end;
  end
  else if C_Str='Process Name' then
  begin
    if fMainForm.StrLstProcess.IndexOf(T_Str+''''+cStrID)=-1 then
    begin
      fMainForm.StrLstProcess.Add(T_Str+''''+cStrID);
      if T_Str='=' then T_Str:='';
      fMainForm.stProcess:=fMainForm.stProcess+' ,'+T_Str+cStrName;
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
begin
  Result:=False;
  Memo1.Clear;
  if fMainForm.stModel<>'' then
  begin
    sStrTmp:=Copy(fMainForm.stModel,3,Length(fMainForm.stModel));
    Memo1.Lines.Add('Model Name: '+ sStrTmp);
    Memo1.Lines.Add('');
  end;
  if fMainForm.stCustomer<>'' then
  begin
    sStrTmp:=Copy(fMainForm.stCustomer,3,Length(fMainForm.stCustomer));
    Memo1.Lines.Add('Customer Name: '+ sStrTmp);
    Memo1.Lines.Add('');
  end;
  if fMainForm.stPart<>'' then
  begin
    sStrTmp:=Copy(fMainForm.stPart,3,Length(fMainForm.stPart));
    Memo1.Lines.Add('Part No: '+ sStrTmp);
    Memo1.Lines.Add('');
  end;
  if fMainForm.LstWO<>'' then
  begin
    sStrTmp:=Copy(fMainForm.LstWO,3,Length(fMainForm.LstWO));
    Memo1.Lines.Add('Work Order: '+ sStrTmp);
    Memo1.Lines.Add('');
  end;
  if fMainForm.stSTAGE<>'' then
  begin
    sStrTmp:=Copy(fMainForm.stSTAGE,3,Length(fMainForm.stSTAGE));
    Memo1.Lines.Add('Stage Name: '+ sStrTmp);
    Memo1.Lines.Add('');
  end;
  if fMainForm.stPdLine<>'' then
  begin
    sStrTmp:=Copy(fMainForm.stPdLine,3,Length(fMainForm.stPdLine));
    Memo1.Lines.Add('PDLine Name: '+ sStrTmp);
    Memo1.Lines.Add('');
  end;
  if fMainForm.stProcess<>'' then
  begin
    sStrTmp:=Copy(fMainForm.stProcess,3,Length(fMainForm.stProcess));
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
  if PageFilter.ActivePageIndex=1 then
  begin
    Button1.Visible:=False;
    Image2.Visible:=False;
    Button2.Visible:=True;
    Image1.Visible:=True;
  end
  else if PageFilter.ActivePageIndex=0 then
  begin
    Button1.Visible:=True;
    Image2.Visible:=True;
    Button2.Visible:=False;
    Image1.Visible:=False;
    EditSN.SelectAll;
    EditSN.SetFocus;
  end else
  begin
    Button1.Visible:=False;
    Image2.Visible:=False;
    Button2.Visible:=False;
    Image1.Visible:=False;
  end;
end;

procedure TfCondition.fClose;
Var sStrTmp : String;
   slCondition : TStringList;
   K,iCol,iRow : Integer;
begin
  fMainForm.strClick:='1';
  fMainForm.stIndexType:='';
  if (sClearFlag=True) then
  begin
    if (fMainForm.QryTemp.Data<>null) then
      fMainForm.ClearGrid;
    if fMainForm.sgData.Visible=True then
    begin
      for iRow:=0 to fMainForm.sgData.RowCount-1 do
        fMainForm.sgData.Rows[iRow].Text:='';
      fMainForm.sgData.RowCount := 2;
      fMainForm.sgData.ColCount := 2;
    end;
  end;
  for iCol:=1 to fMainForm.tsGrid1.Cols do
    for iRow:=1 to fMainForm.tsGrid1.Rows do
    fMainForm.tsGrid1.Cell[iCol,iRow]:='';
  slCondition:= TStringList.Create;
  slCondition.AddStrings(CombType.Items);
  K:=0;
  if fMainForm.stModel<>'' then
  begin
    sStrTmp:=Copy(fMainForm.stModel,3,Length(fMainForm.stModel));
    Inc(K);
    fMainForm.tsGrid1.Cell[1,K]:= 'Model Name';
    fMainForm.tsGrid1.Cell[2,K]:= sStrTmp;
    slCondition.Delete(slCondition.IndexOf('Model Name'));
  end;
  if fMainForm.stCustomer<>'' then
  begin
    sStrTmp:=Copy(fMainForm.stCustomer,3,Length(fMainForm.stCustomer));
    Inc(K);
    fMainForm.tsGrid1.Cell[1,k]:= 'Customer Name';
    fMainForm.tsGrid1.Cell[2,k]:= sStrTmp;
    slCondition.Delete(slCondition.IndexOf('Customer Name'));
  end;
  if fMainForm.stPart<>'' then
  begin
    sStrTmp:=Copy(fMainForm.stPart,3,Length(fMainForm.stPart));
    Inc(K);
    fMainForm.tsGrid1.Cell[1,k]:= 'Part No';
    fMainForm.tsGrid1.Cell[2,k]:= sStrTmp;
    slCondition.Delete(slCondition.IndexOf('Part No'));
  end;
  if fMainForm.LstWO<>'' then
  begin
    sStrTmp:=Copy(fMainForm.LstWO,3,Length(fMainForm.LstWO));
    Inc(K);
    fMainForm.tsGrid1.Cell[1,k]:= 'Work Order';
    fMainForm.tsGrid1.Cell[2,k]:= sStrTmp;
    slCondition.Delete(slCondition.IndexOf('Work Order'));
  end;
  if fMainForm.stSTAGE<>'' then
  begin
    sStrTmp:=Copy(fMainForm.stSTAGE,3,Length(fMainForm.stSTAGE));
    Inc(K);
    fMainForm.tsGrid1.Cell[1,k]:= 'Stage Name';
    fMainForm.tsGrid1.Cell[2,k]:= sStrTmp;
    slCondition.Delete(slCondition.IndexOf('Stage Name'));
  end;
  if fMainForm.stPdLine<>'' then
  begin
    sStrTmp:=Copy(fMainForm.stPdLine,3,Length(fMainForm.stPdLine));
    Inc(K);
    if K>=6 then
      fMainForm.tsGrid1.Rows:=6;
    fMainForm.tsGrid1.Cell[1,K]:= 'PDLine Name';
    fMainForm.tsGrid1.Cell[2,K]:= sStrTmp;
    slCondition.Delete(slCondition.IndexOf('PDLine Name'));
  end;
  if fMainForm.stProcess<>'' then
  begin
    Inc(K);
    if K>=6 then
      fMainForm.tsGrid1.Rows:=K;
    sStrTmp:=Copy(fMainForm.stProcess,3,Length(fMainForm.stProcess));
    fMainForm.tsGrid1.Cell[1,K]:= 'Process Name';
    fMainForm.tsGrid1.Cell[2,K]:= sStrTmp;
    slCondition.Delete(slCondition.IndexOf('Process Name'));
  end;
  if K<=5 then
      fMainForm.tsGrid1.Rows:=5;
  iCol:=0;
  for iRow:=K+1 to fMainForm.tsGrid1.Rows do
  begin
    fMainForm.tsGrid1.Cell[1,iRow]:=slCondition.Strings[iCol];
    Inc(iCol);
  end;
  if Memo1.Text<>'' then
    fMainForm.G_Filter:=True
  else
    fMainForm.G_Filter:=False;
  slCondition.Free;
end;

end.
