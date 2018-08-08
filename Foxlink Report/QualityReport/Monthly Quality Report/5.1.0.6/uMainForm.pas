unit uMainForm;

interface

uses
  Forms, Windows,Dialogs, DB, DBClient, ComCtrls, StdCtrls, Controls, ExtCtrls, Classes,
  Graphics,IniFiles,SysUtils,Jpeg, Buttons,ComObj,Grids, DBGrids,DateUtils, Variants,uExport,
  uCondition, Gauges;

type
  TfMainForm = class(TForm)
    QryTemp: TClientDataSet;
   Image2: TImage;
   QryData: TClientDataSet;
   Label3: TLabel;
   Label4: TLabel;
   sbtnQuery: TSpeedButton;
   Image1: TImage;
   sbtnFilter: TSpeedButton;
   Image3: TImage;
    sbtnExport: TSpeedButton;
    Image4: TImage;
    sbtnPrint: TSpeedButton;
    Image5: TImage;
    SaveDialog1: TSaveDialog;
    Labcnt: TLabel;
    Labcost: TLabel;
    LabQueryTime: TLabel;
    MainPanel: TPanel;
    Panel5: TPanel;
    PanelModel: TPanel;
    PanelStage: TPanel;
    PanelProcess: TPanel;
    Panel10: TPanel;
    Panel4: TPanel;
    DataSource1: TDataSource;
    EditModel: TEdit;
    EditStage: TEdit;
    EditProcess: TEdit;
    ProgressBar1: TGauge;
    sgData: TStringGrid;
    Label5: TLabel;
    edtYearW: TEdit;
    ComboBox1: TComboBox;
    Label1: TLabel;
    ComboBox2: TComboBox;
    Memo1: TMemo;
    Label14: TLabel;
    comTopLevel: TComboBox;
    CheckRetry: TCheckBox;
    Label2: TLabel;
    cmbFactory: TComboBox;
   procedure FormShow(Sender: TObject);
   procedure Button1Click(Sender: TObject);
   procedure FormClose(Sender: TObject; var Action: TCloseAction);
   procedure FormCreate(Sender: TObject);
   procedure Button2Click(Sender: TObject);
   procedure sbtnExportClick(Sender: TObject);
   procedure sbtnPrintClick(Sender: TObject);
   procedure EditModelDblClick(Sender: TObject);
   procedure EditStageDblClick(Sender: TObject);
   procedure EditProcessDblClick(Sender: TObject);
    procedure sgDataDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure edtYearWKeyPress(Sender: TObject; var Key: Char);
    procedure Label5Click(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
  private
    { Private declarations }
    function AndCondition(sField: String; sList: TStringList): String;
  public
    { Public declarations }
    STRPOINTCOUNT : STRING;
    UpdateUserID : String;
    FcID : String;
    StrLstModel,StrLstProcessName,StrLstStageName : TStringList;
    StrLstProcess ,slFactoryID,processlst  : TStringList;
    stStage,stModel,stProcess,stIndexType : String;
    G_sSysLang : Integer;
    function  ShowTime( sType :Integer;sTime :Integer): String;
    function  ShowInfo( sType :Integer): String;
    function  ShowCnt( sType :Integer;sCnt :Integer): String;
    procedure ClearGrid ;
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
  edtYearW.Text:= FormatDateTime('YYYY', Date);
  ComboBox1.ItemIndex :=0;
  ComboBox2.ItemIndex :=StrToIntDef(FormatDateTime('MM', Date),0)-1;
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
  sgData.ColWidths[0]:=-1;
  sgData.ColWidths[1]:=110;

  STRPOINTCOUNT:='1' ;

  cmbFactory.Items.Clear;
  with QryTemp do
  begin
    Close;
    CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
      'From SAJET.SYS_FACTORY ' +
      'Where ENABLED = ''Y'' ';
    Open;
    while not Eof do
    begin
      cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString);
      Next;
      cmbfactory.ItemIndex:=0;
    end;
    cmbFactoryChange(Self);

    Close;
  end;

end;

procedure TfMainForm.Button1Click(Sender: TObject);
begin
  with TfCondition.Create(Self) do
  begin
    ConditionDataSet.RemoteServer := QryData.RemoteServer;
    ConditionDataSet.ProviderName := 'DspQryData';
    if Showmodal = mrOK then
    begin
      ConditionDataSet.Close;
    end;
  end;
end;

procedure TfMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StrLstModel.Free;
  StrLstProcess.Free;
  StrLstProcessName.Free;
  StrLstStageName.Free;
  processlst.Free;
  Action := caFree;
end;

procedure TfMainForm.FormCreate(Sender: TObject);
begin
  StrLstModel := TStringList.Create;
  processlst := TStringList.Create;
  StrLstStageName := TStringList.Create;
  StrLstProcessName := TStringList.Create;
  StrLstProcess := TStringList.Create;
end;

procedure TfMainForm.Button2Click(Sender: TObject);
Var cost : TDateTime;
    iRow,iCol,iTemp,iTopDefect : Integer;
    Str : String;
    slStrWeek,slStrProcess : TStringList;
begin
  cost:=time();
  ComboBox2.ItemIndex :=StrToIntDef(FormatDateTime('MM', Date),0)-1;
  Labcnt.Caption:='';
  Labcost.Caption:='';
  LabQueryTime.Caption:= 'Query Time: '+FormatDateTime('mm/dd HH:MM:SS',Now);
  LabQueryTime.Visible:=False;
  MainPanel.refresh;
  processlst.Clear;
  for iCol:=0 to sgData.RowCount-1 do
    sgData.Rows[iCol].Clear;
  sgData.RowCount:=2;
  sgData.ColCount:=4;
  iCol:=0;
  iRow:=0;
  iTemp:=1;
  if StrLstModel.Count<=0 then
  begin
    MessageDlg(#13#10+'Please Choose Model Name',mtInformation, [mbOK],0);
    exit;
  end;
  if (Trim(ComboBox1.Text)='') or (Trim(ComboBox2.Text)='') then
  begin
    MessageDlg(#13#10+'Please Choose Month',mtInformation, [mbOK],0);
    exit;
  end;
  if comTopLevel.Text='ALL' then
    iTopDefect:=99999
  else
    iTopDefect:=StrToInt(comTopLevel.Text);
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'DTStart', ptInput);
    Params.CreateParam(ftString	,'DTEnd', ptInput);
    Params.CreateParam(ftString	,'DTStart1', ptInput);
    Params.CreateParam(ftString	,'DTEnd1', ptInput);
    Params.CreateParam(ftString	,'DTEnd2', ptInput);
    //埃代癘魁checkretry=false
    if checkretry.Checked =false then
        CommandText := ' SELECT * FROM   '+
                   '   (SELECT WORK_DATE ,PROCESS_NAME ,'' '' DEFECT_CODE,'' '' DEFECT_DESC,'' '' REASON_CODE,'' '' REASON_DESC,'' '' DUTY_CODE,'' '' Location, ''A'' QTY, DEFECT_CNT, PASS_QTY, FAIL_QTY, POINT_CNT '+
                   '    FROM (SELECT AA.WORK_DATE,BB.PROCESS_NAME,SUM(DEFECT_CNT) DEFECT_CNT,SUM(PASS_QTY) PASS_QTY, SUM(FAIL_QTY) FAIL_QTY, SUM(POINT_CNT) POINT_CNT '+
                   '          FROM (  '+
                   '                  SELECT  SUBSTR(A.WORK_DATE,1,6) WORK_DATE, A.PROCESS_ID , 0 DEFECT_CNT, '+
                   '                       DECODE((SUM(A.FAIL_QTY) + SUM(A.REFAIL_QTY)), NULL, 0, (SUM(A.FAIL_QTY) + SUM(A.REFAIL_QTY))) FAIL_QTY, '+
                   '                       DECODE((SUM(A.PASS_QTY) + SUM(A.REPASS_QTY)), NULL, 0, (SUM(A.PASS_QTY) + SUM(A.REPASS_QTY))) PASS_QTY, 0 POINT_CNT  '+
                   '                  From  SAJET.G_SN_COUNT  A, SAJET.SYS_PART B,SAJET.G_WO_BASE C '+
                   '                  WHERE A.MODEL_ID=B.PART_ID  AND  '+
                   '                       :DTStart <= SUBSTR(A.WORK_DATE,1,6) AND '+
                   '                       :DTEnd >=   SUBSTR(A.WORK_DATE,1,6) AND '+
                   '                       A.WORK_ORDER=C.WORK_ORDER AND  '+
                   '                       C.FACTORY_ID='''+FCID+''' '+
                                           AndCondition('B.MODEL_ID',StrLstModel)+
                                           AndCondition('A.PROCESS_ID',StrLstProcess)+
                   '                  GROUP BY SUBSTR(A.WORK_DATE,1,6) ,A.PROCESS_ID '+

                   '                  Union ALL '+

                   '                  SELECT  TO_CHAR(A1.REC_TIME,''YYYYMM'') WORK_DATE , A1.PROCESS_ID,COUNT(A1.DEFECT_ID) DEFECT_CNT, '+
                   '                          0 PASS_QTY, 0 FAIL_QTY, DECODE(SUM(C1.repair_point), NULL, 0, SUM(C1.repair_point))  POINT_CNT  '+
                   '                  From   SAJET.G_SN_DEFECT A1,SAJET.SYS_PART B1,SAJET.G_SN_REPAIR_POINT C1, SAJET.G_WO_BASE D1  '+
                   '                  WHERE A1.MODEL_ID=B1.PART_ID AND   '+
                   '                        A1.RECID=C1.RECID(+) AND   '+
                   '                       :DTStart1 <= TO_CHAR(A1.REC_TIME,''YYYYMM'') AND '+
                   '                       :DTEnd1 >= TO_CHAR(A1.REC_TIME,''YYYYMM'') AND  '+
                   '                       A1.WORK_ORDER=D1.WORK_ORDER AND '+
                   '                       D1.FACTORY_ID='''+FCID+''' '+
                                           AndCondition('B1.MODEL_ID',StrLstModel)+
                                           AndCondition('A1.PROCESS_ID',StrLstProcess)+
                   '                  GROUP BY TO_CHAR(A1.REC_TIME,''YYYYMM'') ,A1.PROCESS_ID )  AA,SAJET.SYS_PROCESS BB '+
                   '          WHERE AA.PROCESS_ID=BB.PROCESS_ID '+
                   '          GROUP BY AA.WORK_DATE,BB.PROCESS_NAME) '+

                   '          UNION ALL '+

                   '          SELECT WORK_DATE, PROCESS_NAME,DEFECT_CODE,DEFECT_DESC,REASON_CODE,REASON_DESC,DUTY_CODE,Location,TO_CHAR(QTY) QTY ,0 DEFECT_CNT,0 PASS_QTY, 0 FAIL_QTY, 0 POINT_CNT '+
                   '          FROM (  '+
                   '                 SELECT  TO_CHAR(A2.REC_TIME,''YYYYMM'') WORK_DATE,G2.PROCESS_NAME,B2.DEFECT_CODE,B2.DEFECT_DESC,D2.REASON_CODE,D2.REASON_DESC,E2.DUTY_CODE,F2.Location,COUNT(*) QTY '+
                   '                 From   SAJET.G_SN_DEFECT A2, SAJET.SYS_DEFECT B2, '+
                   '                        SAJET.G_SN_REPAIR C2, SAJET.SYS_REASON D2, '+
                   '                        SAJET.SYS_DUTY E2,SAJET.G_SN_REPAIR_LOCATION F2, SAJET.SYS_PROCESS G2,SAJET.SYS_PART M2,SAJET.G_WO_BASE N2  '+
                   '                 Where A2.PROCESS_ID = G2.PROCESS_ID AND A2.DEFECT_ID = B2.DEFECT_ID AND '+
                   '                       A2.RECID = C2.RECID AND C2.REASON_ID = D2.REASON_ID AND  C2.DUTY_ID = E2.DUTY_ID AND '+
                   '                       C2.recId = F2.RecID(+) AND C2.Reason_id = F2.REASON_ID(+) AND '+
                   '                       A2.MODEL_ID=M2.PART_ID AND   '+
                   '                       :DTEnd2 = TO_CHAR(A2.REC_TIME,''YYYYMM'') AND '+
                   '                       A2.WORK_ORDER=N2.WORK_ORDER AND '+
                   '                       N2.FACTORY_ID='''+FCID+''' '+
                                           AndCondition('M2.MODEL_ID',StrLstModel)+
                                           AndCondition('A2.PROCESS_ID',StrLstProcess)+
                   '                 GROUP BY TO_CHAR(A2.REC_TIME,''YYYYMM''),G2.PROCESS_NAME,B2.DEFECT_CODE,B2.DEFECT_DESC,D2.REASON_CODE,D2.REASON_DESC,E2.DUTY_CODE,F2.Location ) ) '+
                   ' ORDER BY PROCESS_NAME,WORK_DATE ,QTY DESC ';
    //埃代癘魁checkretry=true
    //POINT_CNT ぃ▆翴计
    if checkretry.Checked =true then
        CommandText := ' SELECT * FROM   '+
                   '   (SELECT WORK_DATE ,PROCESS_NAME ,'' '' DEFECT_CODE,'' '' DEFECT_DESC,'' '' REASON_CODE,'' '' REASON_DESC,'' '' DUTY_CODE,'' '' Location, ''A'' QTY, DEFECT_CNT, PASS_QTY, FAIL_QTY,POINT_CNT '+
                   '    FROM (SELECT AA.WORK_DATE,BB.PROCESS_NAME,SUM(DEFECT_CNT) DEFECT_CNT,SUM(PASS_QTY) PASS_QTY, SUM(FAIL_QTY) FAIL_QTY, SUM(POINT_CNT) POINT_CNT '+
                   '          FROM (  '+
                   '                  SELECT  SUBSTR(A.WORK_DATE,1,6) WORK_DATE, A.PROCESS_ID , 0 DEFECT_CNT, '+
                   '                       DECODE((SUM(A.FAIL_QTY) + SUM(A.REFAIL_QTY)), NULL, 0, (SUM(A.FAIL_QTY) + SUM(A.REFAIL_QTY))) FAIL_QTY, '+
                   '                       DECODE((SUM(A.PASS_QTY) + SUM(A.REPASS_QTY)), NULL, 0, (SUM(A.PASS_QTY) + SUM(A.REPASS_QTY))) PASS_QTY , 0 POINT_CNT '+
                   '                  From  SAJET.G_SN_COUNT  A, SAJET.SYS_PART B, SAJET.G_WO_BASE C '+
                   '                  WHERE A.MODEL_ID=B.PART_ID  AND  '+
                   '                       :DTStart <= SUBSTR(A.WORK_DATE,1,6) AND '+
                   '                       :DTEnd >=   SUBSTR(A.WORK_DATE,1,6) AND '+
                   '                       A.WORK_ORDER = C.WORK_ORDER AND '+
                   '                       C.FACTORY_ID = '''+FCID+''' '+
                                           AndCondition('B.MODEL_ID',StrLstModel)+
                                           AndCondition('A.PROCESS_ID',StrLstProcess)+
                   '                  GROUP BY SUBSTR(A.WORK_DATE,1,6) ,A.PROCESS_ID '+

                   '                  Union ALL '+

                   '                  SELECT  TO_CHAR(A1.REC_TIME,''YYYYMM'') WORK_DATE , A1.PROCESS_ID,COUNT(A1.DEFECT_ID) DEFECT_CNT, '+
                   '                          0 PASS_QTY, 0 FAIL_QTY ,  SUM(nvl(substr(D1.repair_remark,instr(D1.repair_remark,''['')+1,instr(D1.repair_remark,'']'')-instr(D1.repair_remark,''['')-1),0)) POINT_CNT  '+
                   '                  From   SAJET.G_SN_DEFECT A1,SAJET.SYS_PART B1,SAJET.G_SN_REPAIR C1,SAJET.G_SN_REPAIR_REMARK D1,SAJET.G_WO_BASE E1 '+
                   '                  WHERE A1.MODEL_ID=B1.PART_ID AND   '+
                   '                       :DTStart1 <= TO_CHAR(A1.REC_TIME,''YYYYMM'') AND '+
                   '                       :DTEnd1 >= TO_CHAR(A1.REC_TIME,''YYYYMM'') '+
                   '                       AND A1.RECID=C1.RECID(+) AND C1.REMARK IS NULL '+
                   '                       AND A1.RECID=D1.RECID(+)   '+
                   '                       AND A1.WORK_ORDER = E1.WORK_ORDER  '+
                   '                       AND E1.FACTORY_ID = '''+FCID+''' '+
                                           AndCondition('B1.MODEL_ID',StrLstModel)+
                                           AndCondition('A1.PROCESS_ID',StrLstProcess)+
                   '                  GROUP BY TO_CHAR(A1.REC_TIME,''YYYYMM'') ,A1.PROCESS_ID )  AA,SAJET.SYS_PROCESS BB '+
                   '          WHERE AA.PROCESS_ID=BB.PROCESS_ID '+
                   '          GROUP BY AA.WORK_DATE,BB.PROCESS_NAME) '+

                   '          UNION ALL '+

                   '          SELECT WORK_DATE, PROCESS_NAME,DEFECT_CODE,DEFECT_DESC,REASON_CODE,REASON_DESC,DUTY_CODE,Location,TO_CHAR(QTY) QTY ,0 DEFECT_CNT,0 PASS_QTY, 0 FAIL_QTY,0 DFECT_CNT2 '+
                   '          FROM (  '+
                   '                 SELECT  TO_CHAR(A2.REC_TIME,''YYYYMM'') WORK_DATE,G2.PROCESS_NAME,B2.DEFECT_CODE,B2.DEFECT_DESC,D2.REASON_CODE,D2.REASON_DESC,E2.DUTY_CODE,F2.Location,COUNT(*) QTY '+
                   '                 From   SAJET.G_SN_DEFECT A2, SAJET.SYS_DEFECT B2, '+
                   '                        SAJET.G_SN_REPAIR C2, SAJET.SYS_REASON D2, '+
                   '                        SAJET.SYS_DUTY E2,SAJET.G_SN_REPAIR_LOCATION F2, SAJET.SYS_PROCESS G2,SAJET.SYS_PART M2,SAJET.G_WO_BASE N2  '+
                   '                 Where A2.PROCESS_ID = G2.PROCESS_ID AND A2.DEFECT_ID = B2.DEFECT_ID AND '+
                   '                       A2.RECID = C2.RECID AND C2.REMARK IS NULL AND C2.REASON_ID = D2.REASON_ID AND  C2.DUTY_ID = E2.DUTY_ID AND '+
                   '                       C2.recId = F2.RecID(+) AND C2.Reason_id = F2.REASON_ID(+) AND '+
                   '                       A2.MODEL_ID=M2.PART_ID AND   '+
                   '                       :DTEnd2 = TO_CHAR(A2.REC_TIME,''YYYYMM'') AND '+
                   '                       A2.WORK_ORDER = N2.WORK_ORDER AND '+
                   '                       N2.FACTORY_ID = '''+FCID+''' '+
                                           AndCondition('M2.MODEL_ID',StrLstModel)+
                                           AndCondition('A2.PROCESS_ID',StrLstProcess)+
                   '                 GROUP BY TO_CHAR(A2.REC_TIME,''YYYYMM''),G2.PROCESS_NAME,B2.DEFECT_CODE,B2.DEFECT_DESC,D2.REASON_CODE,D2.REASON_DESC,E2.DUTY_CODE,F2.Location ) ) '+
                   ' ORDER BY PROCESS_NAME,WORK_DATE ,QTY DESC ';

    Params.ParamByName('DTStart').AsString := edtYearW.Text+ComboBox1.Text;
    Params.ParamByName('DTEnd').AsString := edtYearW.Text+ComboBox2.Text;
    Params.ParamByName('DTStart1').AsString := edtYearW.Text+ComboBox1.Text;
    Params.ParamByName('DTEnd1').AsString := edtYearW.Text+ComboBox2.Text;
    Params.ParamByName('DTEnd2').AsString := edtYearW.Text+ComboBox2.Text;
    Open;
    //Memo1.Text:=CommandText;
    if RecordCount>0 then
    begin
      slStrProcess:= TStringList.Create;
      slStrWeek:= TStringList.Create;
      ProgressBar1.Progress:=0;
      ProgressBar1.Visible:=True;
      iCol:=0;
      while 1+iCol<=12 do
      begin
        if Length(IntToStr(1+iCol))=1 then
          Str:=edtYearW.Text+'/0'+IntToStr(1+iCol)
        else
          Str:=edtYearW.Text+'/'+IntToStr(1+iCol);
        sgData.Cells[iCol+2,0]:=Str;
        slStrWeek.Add(Str);
        Inc(iCol);
      end;
      QryTemp.First;
      while not eof do
      begin
        Str:=Copy(FieldByName('WORK_DATE').asString,1,4)+'/'+Copy(FieldByName('WORK_DATE').asString,5,2);
        ProgressBar1.Progress:=Round(RecNo / RecordCount * 100);
        if slStrWeek.IndexOf(Str)=-1 then
        begin
          slStrWeek.Add(Str);
          sgData.Cells[slStrWeek.Count+1,0]:= Str;
        end;
        iCol:=slStrWeek.IndexOf(Str)+1;
        Str:=FieldByName('PROCESS_NAME').asString;

        if slStrProcess.IndexOf(Str)=-1 then
        begin
          processlst.Add(FieldByName('PROCESS_NAME').AsString);
          slStrProcess.Add(FieldByName('PROCESS_NAME').AsString);
          slStrProcess.Add(FieldByName('PROCESS_NAME').AsString+'1');
          slStrProcess.Add(FieldByName('PROCESS_NAME').AsString+'2');
          slStrProcess.Add(FieldByName('PROCESS_NAME').AsString+'3');
          slStrProcess.Add(FieldByName('PROCESS_NAME').AsString+'4');
          slStrProcess.Add(FieldByName('PROCESS_NAME').AsString+'5');
          Str:=FieldByName('PROCESS_NAME').asString;
          iRow:=slStrProcess.IndexOf(Str)+1;
          sgData.Cells[1,iRow]:= FieldByName('PROCESS_NAME').AsString;
          sgData.Cells[2,iRow]:= '   ';
          sgData.Cells[1,iRow+1]:= 'Input(pcs)';
          sgData.Cells[1,iRow+2]:= 'Defect(pcs)';
          sgData.Cells[1,iRow+3]:= 'DPPM';
          sgData.Cells[1,iRow+4]:= 'Defect(point)';
          sgData.Cells[1,iRow+5]:= 'Yield(%)';
          iTemp:=1;
        end;
        if FieldByName('DEFECT_CODE').AsString<>' ' then
        begin
          if (iTemp<=iTopDefect) then
          begin
            slStrProcess.Add(FieldByName('PROCESS_NAME').AsString+IntToStr(iTemp+5));
            iRow:=slStrProcess.IndexOf(FieldByName('PROCESS_NAME').AsString+IntToStr(iTemp+5))+1;
            Inc(iTemp);
            sgData.Cells[1,iRow]:= Copy(FieldByName('WORK_DATE').asString,1,4)+'/'+Copy(FieldByName('WORK_DATE').asString,5,2);
            sgData.Cells[2,iRow]:= FieldByName('QTY').AsString;
            sgData.Cells[3,iRow]:= FieldByName('DEFECT_CODE').AsString+' '+FieldByName('DEFECT_DESC').AsString;
            sgData.Cells[4,iRow]:= FieldByName('REASON_CODE').AsString+' '+FieldByName('REASON_DESC').AsString;
            sgData.Cells[5,iRow]:= FieldByName('DUTY_CODE').AsString;
            sgData.Cells[6,iRow]:= FieldByName('Location').AsString;
          end;
        end
        else if FieldByName('DEFECT_CODE').AsString=' ' then
        begin
          //埃代癘魁checkretry=false
          if checkretry.Checked =false then
            begin
               sgData.Cells[iCol+1,iRow+1]:= IntToStr(FieldByName('PASS_QTY').AsInteger+FieldByName('FAIL_QTY').AsInteger);
               sgData.Cells[iCol+1,iRow+2]:= FieldByName('FAIL_QTY').asString;
               if (FieldByName('FAIL_QTY').AsInteger+FieldByName('PASS_QTY').AsInteger>0) then
                  sgData.Cells[iCol+1,iRow+3]:= FormatFloat('0',(FieldByName('FAIL_QTY').AsInteger * 1000000) / (FieldByName('PASS_QTY').AsInteger+FieldByName('FAIL_QTY').AsInteger));
               //sgData.Cells[iCol+1,iRow+4]:= FieldByName('DEFECT_CNT').asString;
                 sgData.Cells[iCol+1,iRow+4]:= FieldByName('POINT_CNT').asString;
               if (FieldByName('FAIL_QTY').AsInteger>0) then
                  sgData.Cells[iCol+1,iRow+5]:= FloatToStrf((FieldByName('PASS_QTY').AsInteger)/(FieldByName('PASS_QTY').AsInteger+FieldByName('FAIL_QTY').AsInteger)*100 ,ffFixed, 6, 2)
               else
                  sgData.Cells[iCol+1,iRow+5]:= '100';
            end ;
          //埃代癘魁checkretry=true
          if checkretry.Checked =true then
            begin
               sgData.Cells[iCol+1,iRow+1]:= IntToStr(FieldByName('PASS_QTY').AsInteger);
               sgData.Cells[iCol+1,iRow+2]:= FieldByName('DEFECT_CNT').asString;
               //DPPM
               if (FieldByName('PASS_QTY').AsInteger>0) then
                  sgData.Cells[iCol+1,iRow+3]:= FormatFloat('0',(FieldByName('POINT_CNT').AsInteger * 1000000) / (FieldByName('PASS_QTY').AsInteger*STRTOINT(STRPOINTCOUNT)));
              //ぃ▆翴计
               sgData.Cells[iCol+1,iRow+4]:= FieldByName('POINT_CNT').asString;
               if (FieldByName('DEFECT_CNT').AsInteger>0) then
                  sgData.Cells[iCol+1,iRow+5]:= FloatToStrf((FieldByName('PASS_QTY').AsInteger)/(FieldByName('PASS_QTY').AsInteger+FieldByName('DEFECT_CNT').AsInteger)*100 ,ffFixed, 6, 2)
               else
                  sgData.Cells[iCol+1,iRow+5]:= '100';
            end ;
        end;
        next;
      end;
      sgData.RowCount := slStrProcess.Count+1;
      if slStrWeek.Count<=5 then
        sgData.ColCount:=7
      else
        sgData.ColCount:=slStrWeek.Count+2;
      slStrProcess.Free;
      slStrWeek.Free;
      ProgressBar1.Progress:=0;
      ProgressBar1.Visible:=False;
    end;

    Labcnt.Caption:=ShowCnt(G_sSysLang,QryTemp.RecordCount);
    Labcost.Caption:=ShowTime(G_sSysLang,MilliSecondsBetween(time(),cost));
    LabQueryTime.Visible:=True;
  end;
end;

Function TfMainForm.ShowTime( sType :Integer;sTime :Integer): String;
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

procedure TfMainForm.ClearGrid ;
begin
  QryTemp.EmptyDataSet;
  Labcost.Caption:='';
  Labcnt.Caption:='';
  LabQueryTime.Visible:=False;
end;

procedure TfMainForm.ResizeForm(high,width:Integer);
begin
  fMainForm.Width:=width;
  fMainForm.Height:=high;
  sgData.Height:=high-202;
  ProgressBar1.Top:=sgData.Top+sgData.Height+6;
  Labcnt.Top:=ProgressBar1.Top;
  LabQueryTime.Top:=ProgressBar1.Top;
  Labcost.Top:=ProgressBar1.Top;
end;

procedure TfMainForm.sbtnExportClick(Sender: TObject);
begin
  sbtnExport.Enabled:=False;
  ExpThread:=TExpThread.Create(false);
  ExpThread.FreeOnTerminate := True;
end;

procedure TfMainForm.sbtnPrintClick(Sender: TObject);
begin
  PrtThread:=TPrtThread.Create(false);
  PrtThread.FreeOnTerminate := True;
end;

function  TfMainForm.ShowInfo( sType :Integer): String;
begin
  if sType=0 then
    Result := '搭ぶ琩高丁,叫块兵ン琩高.'
  else if sType=1 then
    Result := '为了减少查询时间,请输入条件查询.'
  else
    Result := 'For Search Speed, Please Input Condition';
end;

procedure TfMainForm.ButtonStatus(sBln:Boolean);
begin
  sbtnQuery.enabled:=sBln;
  sbtnExport.enabled:=sBln;
  SbtnPrint.enabled:=sBln;
  sbtnFilter.enabled:=sBln;
  ProgressBar1.Visible:=not sBln;
end;

procedure TfMainForm.EditModelDblClick(Sender: TObject);
begin
   stIndexType:=Trim(PanelModel.Caption);
   Button1Click(Self);
end;

procedure TfMainForm.EditStageDblClick(Sender: TObject);
begin
   stIndexType:=Trim(PanelProcess.Caption);
   Button1Click(Self);
end;

procedure TfMainForm.EditProcessDblClick(Sender: TObject);
begin
   stIndexType:=Trim(PanelProcess.Caption);
   Button1Click(Self);
end;

function TfMainForm.AndCondition(sField: String; sList: TStringList): String;
var i    : Integer;
begin
    Result := '';
    if sList.Count <> 0 then
    begin
        Result := ' AND ( ';
        for i := 0 to sList.Count-1 do
        begin
           if i = 0 then
              Result := Result + sField + sList.Strings[i] + ''' '
           else
              Result := Result + 'OR ' + sField  + sList.Strings[i] + ''' ';
        end;
        Result := Result + ') ';
    end;
end;

procedure TfMainForm.sgDataDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  if sgData.RowCount<3 then exit;
  if (ARow<=0) or (ACol<=0) then exit;
  if sgData.Cells[2, ARow]='   ' then
  begin
    sgData.Canvas.Brush.Color:=clYellow;//改變底色
    sgData.Canvas.TextRect(Rect, Rect.Left+2, Rect.Top+4, sgData.Cells[ACol, ARow]);
  end else
  begin
   sgData.Canvas.Brush.Color:=clWhite;//改變底色
   sgData.Canvas.TextRect(Rect, Rect.Left+2, Rect.Top+4, sgData.Cells[ACol, ARow]);
  end;  
end;

procedure TfMainForm.edtYearWKeyPress(Sender: TObject; var Key: Char);
begin
  if not (KEY in ['0'..'9',#13,#8]) then Key:=#0;
end;

procedure TfMainForm.Label5Click(Sender: TObject);
begin
    STRPOINTCOUNT:=InputBox('Input Box', 'Please input point count!', '1');
end;

procedure TfMainForm.cmbFactoryChange(Sender: TObject);
begin
  FcID := '';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'FACTORYCODE', ptInput);
    CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
      'From SAJET.SYS_FACTORY ' +
      'Where FACTORY_CODE = :FACTORYCODE ';
    Params.ParamByName('FACTORYCODE').AsString := Copy(cmbFactory.Text, 1, POS(' ', cmbFactory.Text) - 1);
    Open;
    if RecordCount > 0 then
      FcID := Fieldbyname('FACTORY_ID').AsString;
    Close;
  end;
end;

end.
