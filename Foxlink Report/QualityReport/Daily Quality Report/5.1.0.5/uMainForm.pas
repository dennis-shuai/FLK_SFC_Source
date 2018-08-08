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
    Memo1: TMemo;
    PanelDefect: TPanel;
    EditDefect: TEdit;
    YieldGrid: TStringGrid;
    Label5: TLabel;
    edtYearW: TEdit;
    ComboBox1: TComboBox;
    CheckRetry: TCheckBox;
    Label1: TLabel;
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
    procedure EditDefectDblClick(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
  private
    { Private declarations }
    function AndCondition(sField: String; sList: TStringList): String;
  public
    { Public declarations }
    strpointcount: string;  //ノ癘魁块羆翴计for smt ヘ浪
    UpdateUserID : String;
    FcID : String;
    StrLstModel : TStringList;
    StrLstProcess,StrLstDefect ,slFactoryID,StrLstDefectName,StrLstProcessName,StrLstStageName  : TStringList;
    stModel,stIndexType : String;
    processlst,stagelst,lstprocess:TStringlist;
    G_sSysLang,G_DefectCnt : Integer;
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
  ComboBox1.ItemIndex :=StrToIntDef(FormatDateTime('MM', Date),0)-1;
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

  strpointcount:='1';

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
  StrLstDefect.Free;
  StrLstDefectName.Free;
  processlst.Free;
  lstprocess.Free;
  stagelst.Free;
  Action := caFree;
end;

procedure TfMainForm.FormCreate(Sender: TObject);
begin
  StrLstModel := TStringList.Create;
  StrLstProcess := TStringList.Create;
  StrLstStageName := TStringList.Create;
  StrLstProcessName := TStringList.Create;
  StrLstDefect := TStringList.Create;
  StrLstDefectName := TStringList.Create;
  processlst:=TStringlist.Create;
  lstprocess:=Tstringlist.Create;
  stagelst:=TStringlist.Create;
end;

procedure TfMainForm.Button2Click(Sender: TObject);
Var cost,D1,D2 : TDateTime;
    iRow,iCol,L_DefectCnt : Integer;
    Str,LStrProcess : String;
    RTemp : Real;
    slStrDay,slStrProcess : TStringList;
begin
  cost:=time();
  Labcnt.Caption:='';
  Labcost.Caption:='';
  LabQueryTime.Caption:= 'Query Time: '+FormatDateTime('mm/dd HH:MM:SS',Now);
  LabQueryTime.Visible:=False;
  MainPanel.refresh;
  L_DefectCnt:=1;
  G_DefectCnt:=0;
  lstprocess.Clear;
  for iCol:=0 to sgData.RowCount-1 do
    sgData.Rows[iCol].Clear;
  for iCol:=0 to YieldGrid.RowCount-1 do
    YieldGrid.Rows[iCol].Clear;
  sgData.RowCount:=2;
  sgData.ColCount:=4;
  YieldGrid.RowCount:=2;
  YieldGrid.ColCount:=4;
  D2:=EndOfAMonth(StrToInt(edtYearW.text),StrToInt(ComboBox1.text));
  if ComboBox1.text='01' then
     D1:=EndOfAMonth(StrToInt(edtYearW.text)-1,12)+1
  else
     D1:=EndOfAMonth(StrToInt(edtYearW.text),StrToInt(ComboBox1.text)-1)+1;
  iCol:=0;
  iRow:=0;
  if StrLstModel.Count<=0 then
  begin
    MessageDlg(#13#10+'Please Choose Model Name',mtInformation, [mbOK],0);
    exit;
  end;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'DTStart', ptInput);
    Params.CreateParam(ftString	,'DTEnd', ptInput);
    Params.CreateParam(ftString	,'DTEnd1', ptInput);
    Params.CreateParam(ftString	,'DTEnd2', ptInput);
    if checkretry.Checked =false then
        CommandText := ' SELECT * FROM   '+
                   '   (SELECT WORK_DATE ,STAGE_NAME,PROCESS_NAME ,'' '' DEFECT_CODE,'' '' DEFECT_DESC, ''A'' QTY, DEFECT_CNT, PASS_QTY, FAIL_QTY, POINT_CNT  '+
                   '    FROM (SELECT AA.WORK_DATE,CC.STAGE_NAME,BB.PROCESS_NAME,SUM(DEFECT_CNT) DEFECT_CNT,SUM(PASS_QTY) PASS_QTY, SUM(FAIL_QTY) FAIL_QTY, SUM(POINT_CNT) POINT_CNT '+
                   '          FROM (  '+
                   '                  SELECT A.WORK_DATE, A.STAGE_ID,A.PROCESS_ID , 0 DEFECT_CNT, '+
                   '                       DECODE((SUM(A.FAIL_QTY) + SUM(A.REFAIL_QTY)), NULL, 0, (SUM(A.FAIL_QTY) + SUM(A.REFAIL_QTY))) FAIL_QTY, '+
                   '                       DECODE((SUM(A.PASS_QTY) + SUM(A.REPASS_QTY)), NULL, 0, (SUM(A.PASS_QTY) + SUM(A.REPASS_QTY))) PASS_QTY, 0 POINT_CNT  '+
                   '                  From  SAJET.G_SN_COUNT  A, SAJET.SYS_PART B ,SAJET.G_WO_BASE C '+
                   '                  WHERE A.MODEL_ID=B.PART_ID  AND  '+
                   '                       A.WORK_DATE>=:DTStart AND '+
                   '                       A.WORK_DATE<=:DTEnd AND  '+
                   '                       A.WORK_ORDER=C.WORK_ORDER AND  '+
                   '                       C.FACTORY_ID='''+FCID+''' '+
                                           AndCondition('B.MODEL_ID',StrLstModel)+
                                           AndCondition('A.PROCESS_ID',StrLstProcess)+
                   '                  GROUP BY A.WORK_DATE ,A.STAGE_ID,A.PROCESS_ID '+

                   '                  Union ALL '+

                   '                  SELECT  TO_CHAR(A1.REC_TIME,''YYYYMMDD'') WORK_DATE ,A1.STAGE_ID, A1.PROCESS_ID,COUNT(A1.DEFECT_ID) DEFECT_CNT, '+
                   '                          0 PASS_QTY, 0 FAIL_QTY,  DECODE(SUM(C1.repair_point), NULL, 0, SUM(C1.repair_point))  POINT_CNT  '+
                   '                  From   SAJET.G_SN_DEFECT A1,SAJET.SYS_PART B1,SAJET.G_SN_REPAIR_POINT C1, SAJET.G_WO_BASE D1 '+
                   '                  WHERE A1.MODEL_ID=B1.PART_ID AND   '+
                   '                       A1.RECID=C1.RECID(+) AND   '+
                   '                       :DTEnd1 = TO_CHAR(A1.REC_TIME,''YYYYMM'') AND  '+
                   '                       A1.WORK_ORDER=D1.WORK_ORDER AND '+
                   '                       D1.FACTORY_ID='''+FCID+''' '+
                                           AndCondition('B1.MODEL_ID',StrLstModel)+
                                           AndCondition('A1.PROCESS_ID',StrLstProcess)+
                   '                  GROUP BY TO_CHAR(A1.REC_TIME,''YYYYMMDD'') ,A1.STAGE_ID,A1.PROCESS_ID )  AA,SAJET.SYS_PROCESS BB,SAJET.SYS_STAGE CC '+
                   '          WHERE AA.PROCESS_ID=BB.PROCESS_ID AND AA.STAGE_ID=CC.STAGE_ID  '+
                   '          GROUP BY AA.WORK_DATE,CC.STAGE_NAME,BB.PROCESS_NAME) '+

                   '          UNION ALL '+

                   '          SELECT  WORK_DATE, STAGE_NAME, PROCESS_NAME,DEFECT_CODE,DEFECT_DESC,TO_CHAR(QTY) QTY ,0 DEFECT_CNT,0 PASS_QTY, 0 FAIL_QTY, 0 POINT_CNT '+
                   '          FROM (  '+
                   '                 SELECT  TO_CHAR(A2.REC_TIME,''YYYYMMDD'') WORK_DATE, N2.STAGE_NAME, G2.PROCESS_NAME,B2.DEFECT_CODE,B2.DEFECT_DESC,COUNT(*) QTY '+
                   '                 From   SAJET.G_SN_DEFECT A2, SAJET.SYS_DEFECT B2, '+
                   '                        SAJET.SYS_PROCESS G2,SAJET.SYS_PART M2,SAJET.SYS_STAGE N2, SAJET.G_WO_BASE P2  '+
                   '                 Where A2.PROCESS_ID = G2.PROCESS_ID AND A2.DEFECT_ID = B2.DEFECT_ID AND A2.STAGE_ID=N2.STAGE_ID AND '+
                   '                       A2.MODEL_ID=M2.PART_ID AND   '+
                   '                       :DTEnd2 = TO_CHAR(A2.REC_TIME,''YYYYMM'') AND   '+
                   '                       A2.WORK_ORDER=P2.WORK_ORDER AND '+
                   '                       P2.FACTORY_ID='''+FCID+''' '+
                                           AndCondition('M2.MODEL_ID',StrLstModel)+
                                           AndCondition('A2.PROCESS_ID',StrLstProcess)+
                                           AndCondition('A2.DEFECT_ID',StrLstDefect)+
                   '                 GROUP BY TO_CHAR(A2.REC_TIME,''YYYYMMDD''),N2.STAGE_NAME,G2.PROCESS_NAME,B2.DEFECT_CODE,B2.DEFECT_DESC ) ) '+
                   ' ORDER BY STAGE_NAME,PROCESS_NAME,WORK_DATE ,QTY DESC ';
        //璶Τぃ▆ぃ﹚璶蝴ok,⊿Τ代癘魁
        //POINT_CNT ぃ▆翴计
      if checkretry.Checked = true then
        CommandText := ' SELECT * FROM   '+
                   '   (SELECT WORK_DATE ,STAGE_NAME,PROCESS_NAME ,'' '' DEFECT_CODE,'' '' DEFECT_DESC, ''A'' QTY, DEFECT_CNT, PASS_QTY, FAIL_QTY,POINT_CNT '+
                   '    FROM (SELECT AA.WORK_DATE,CC.STAGE_NAME,BB.PROCESS_NAME,SUM(DEFECT_CNT) DEFECT_CNT,SUM(PASS_QTY) PASS_QTY, SUM(FAIL_QTY) FAIL_QTY ,SUM(POINT_CNT) POINT_CNT  '+
                   '          FROM (  '+
                   '                  SELECT A.WORK_DATE, A.STAGE_ID,A.PROCESS_ID , 0 DEFECT_CNT, '+
                   '                       DECODE((SUM(A.FAIL_QTY) + SUM(A.REFAIL_QTY)), NULL, 0, (SUM(A.FAIL_QTY) + SUM(A.REFAIL_QTY))) FAIL_QTY, '+
                   '                       DECODE((SUM(A.PASS_QTY) + SUM(A.REPASS_QTY)), NULL, 0, (SUM(A.PASS_QTY) + SUM(A.REPASS_QTY))) PASS_QTY ,0 POINT_CNT '+
                   '                  From  SAJET.G_SN_COUNT  A, SAJET.SYS_PART B, SAJET.G_WO_BASE C '+
                   '                  WHERE A.MODEL_ID=B.PART_ID  AND  '+
                   '                       A.WORK_DATE>=:DTStart AND '+
                   '                       A.WORK_DATE<=:DTEnd AND '+
                   '                       A.WORK_ORDER=C.WORK_ORDER AND '+
                   '                       C.FACTORY_ID='''+FCID+'''  '+
                                           AndCondition('B.MODEL_ID',StrLstModel)+
                                           AndCondition('A.PROCESS_ID',StrLstProcess)+
                   '                  GROUP BY A.WORK_DATE ,A.STAGE_ID,A.PROCESS_ID '+

                   '                  Union ALL '+

                   '                  SELECT  TO_CHAR(A1.REC_TIME,''YYYYMMDD'') WORK_DATE ,A1.STAGE_ID, A1.PROCESS_ID,COUNT(A1.DEFECT_ID) DEFECT_CNT, '+
                   '                          0 PASS_QTY, 0 FAIL_QTY,SUM(nvl(substr(repair_remark,instr(repair_remark,''['')+1,instr(repair_remark,'']'')-instr(repair_remark,''['')-1),0)) POINT_CNT  '+
                   '                  From   SAJET.G_SN_DEFECT A1,SAJET.SYS_PART B1,sajet.g_sn_repair C1,sajet.g_sn_repair_remark D1, SAJET.G_WO_BASE E1 '+
                   '                  WHERE A1.MODEL_ID=B1.PART_ID AND   '+
                   '                  A1.RECID=C1.RECID(+) AND  C1.remark is null AND '+
                   '                  A1.RECID=D1.RECID(+) AND   '+
                   '                       :DTEnd1 = TO_CHAR(A1.REC_TIME,''YYYYMM'') AND '+
                   '                  A1.WORK_ORDER=E1.WORK_ORDER AND '+
                   '                  E1.FACTORY_ID='''+FCID+''' '+
                                           AndCondition('B1.MODEL_ID',StrLstModel)+
                                           AndCondition('A1.PROCESS_ID',StrLstProcess)+
                   '                  GROUP BY TO_CHAR(A1.REC_TIME,''YYYYMMDD'') ,A1.STAGE_ID,A1.PROCESS_ID )  AA,SAJET.SYS_PROCESS BB,SAJET.SYS_STAGE CC '+
                   '          WHERE AA.PROCESS_ID=BB.PROCESS_ID AND AA.STAGE_ID=CC.STAGE_ID  '+
                   '          GROUP BY AA.WORK_DATE,CC.STAGE_NAME,BB.PROCESS_NAME) '+
                   

                   '          UNION ALL '+

                   '          SELECT  WORK_DATE, STAGE_NAME, PROCESS_NAME,DEFECT_CODE,DEFECT_DESC,TO_CHAR(QTY) QTY ,0 DEFECT_CNT,0 PASS_QTY, 0 FAIL_QTY,0 POINT_CNT '+
                   '          FROM (  '+
                   '                 SELECT  TO_CHAR(A2.REC_TIME,''YYYYMMDD'') WORK_DATE, N2.STAGE_NAME, G2.PROCESS_NAME,B2.DEFECT_CODE,B2.DEFECT_DESC,COUNT(*) QTY '+
                   '                 From   SAJET.G_SN_DEFECT A2, SAJET.SYS_DEFECT B2, '+
                   '                        SAJET.SYS_PROCESS G2,SAJET.SYS_PART M2,SAJET.SYS_STAGE N2 ,sajet.g_sn_repair C2, SAJET.G_WO_BASE D2 '+
                   '                 Where A2.PROCESS_ID = G2.PROCESS_ID AND A2.DEFECT_ID = B2.DEFECT_ID  AND A2.STAGE_ID=N2.STAGE_ID AND '+
                   '                       A2.MODEL_ID=M2.PART_ID AND   '+
                   '                       A2.RECID=C2.RECID(+) AND  C2.remark is null AND '+
                   '                       :DTEnd2 = TO_CHAR(A2.REC_TIME,''YYYYMM'') AND  '+
                   '                       A2.WORK_ORDER=D2.WORK_ORDER AND '+
                   '                       D2.FACTORY_ID='''+FCID+''' '+
                                           AndCondition('M2.MODEL_ID',StrLstModel)+
                                           AndCondition('A2.PROCESS_ID',StrLstProcess)+
                                           AndCondition('A2.DEFECT_ID',StrLstDefect)+
                   '                 GROUP BY TO_CHAR(A2.REC_TIME,''YYYYMMDD''),N2.STAGE_NAME,G2.PROCESS_NAME,B2.DEFECT_CODE,B2.DEFECT_DESC ) ) '+
                   '  ORDER BY STAGE_NAME,PROCESS_NAME,WORK_DATE ,QTY DESC ';

    Params.ParamByName('DTStart').AsString := FormatDateTime('YYYYMMDD',D1);
    Params.ParamByName('DTEnd').AsString := FormatDateTime('YYYYMMDD',D2);
    Params.ParamByName('DTEnd1').AsString := edtYearW.Text+ComboBox1.Text;
    Params.ParamByName('DTEnd2').AsString := edtYearW.Text+ComboBox1.Text;
    Open;
    //Memo1.Text:=CommandText;
    if RecordCount>0 then
    begin
      slStrProcess:= TStringList.Create;
      slStrDay:= TStringList.Create;
      processlst.Clear;
      stagelst.Clear;
      RTemp:=1;
      ProgressBar1.Progress:=0;
      ProgressBar1.Visible:=True;
      iCol:=0;   
      while D1+iCol<=D2 do
      begin
        Str:=FormatDateTime('YYYYMMDD',D1+iCol);
        slStrDay.Add(Str);
        sgData.Cells[iCol+3,0]:=Copy(Str,1,4)+'/'+ Copy(Str,5,2)+'/'+Copy(Str,7,2);
        YieldGrid.Cells[iCol+3,0]:=Copy(Str,1,4)+'/'+ Copy(Str,5,2)+'/'+Copy(Str,7,2);
        Inc(iCol);
      end;
      QryTemp.First;
      while not eof do
      begin
        Str:=FieldByName('WORK_DATE').asString;
        ProgressBar1.Progress:=Round(RecNo / RecordCount * 100);
        if slStrDay.IndexOf(Str)=-1 then
        begin
          slStrDay.Add(Str);
          sgData.Cells[slStrDay.Count+2,0]:= Copy(FieldByName('WORK_DATE').asString,5,4);
        end;
        Str:=FieldByName('PROCESS_NAME').asString;
        iCol:=slStrDay.IndexOf(FieldByName('WORK_DATE').asString)+3;
        if slStrProcess.IndexOf(Str)=-1 then
        begin
          if processlst.IndexOf(FieldByName('STAGE_NAME').AsString)=-1 then
          begin
            processlst.Add(FieldByName('STAGE_NAME').AsString);
            YieldGrid.Cells[1,processlst.Count+1]:= FieldByName('STAGE_NAME').AsString;
          end;
          stagelst.Add(FieldByName('STAGE_NAME').AsString);
          lstprocess.Add(FieldByName('PROCESS_NAME').AsString);
          slStrProcess.Add(FieldByName('PROCESS_NAME').AsString);
          slStrProcess.Add(FieldByName('PROCESS_NAME').AsString+'1');
          slStrProcess.Add(FieldByName('PROCESS_NAME').AsString+'2');
          slStrProcess.Add(FieldByName('PROCESS_NAME').AsString+'3');
          slStrProcess.Add(FieldByName('PROCESS_NAME').AsString+'4');
          slStrProcess.Add(FieldByName('PROCESS_NAME').AsString+'5');
          //slStrProcess.Add(FieldByName('PROCESS_NAME').AsString+'6');
          Str:=FieldByName('PROCESS_NAME').asString;
          iRow:=slStrProcess.IndexOf(Str)+1;
          sgData.Cells[1,iRow]:= FieldByName('STAGE_NAME').AsString;
          sgData.Cells[2,iRow]:= FieldByName('PROCESS_NAME').AsString;
          sgData.Cells[3,iRow]:= '   ';
          sgData.Cells[2,iRow+1]:= 'Input(pcs)';
          sgData.Cells[2,iRow+2]:= 'Defect(pcs)';
          sgData.Cells[2,iRow+3]:= 'DPPM';
          sgData.Cells[2,iRow+4]:= 'Defect(point)';
          sgData.Cells[2,iRow+5]:= 'Yield(%)';
          sgData.Cells[2,iRow+6]:= 'FPass(pcs)';
        end;
        if FieldByName('DEFECT_CODE').AsString<>' ' then
        begin
          if slStrProcess.IndexOf(FieldByName('PROCESS_NAME').AsString+FieldByName('DEFECT_CODE').AsString)=-1 then
          begin
            slStrProcess.Add(FieldByName('PROCESS_NAME').AsString+FieldByName('DEFECT_CODE').AsString);
            if LStrProcess<>FieldByName('PROCESS_NAME').AsString then
            begin
              if G_DefectCnt<L_DefectCnt then
                G_DefectCnt:= L_DefectCnt;
              L_DefectCnt:=1;
              LStrProcess:=FieldByName('PROCESS_NAME').AsString;
            end else
              Inc(L_DefectCnt);
          end;
          iRow:=slStrProcess.IndexOf(FieldByName('PROCESS_NAME').AsString+FieldByName('DEFECT_CODE').AsString)+1;
          sgData.Cells[iCol,iRow]:= FieldByName('QTY').AsString;
          sgData.Cells[2,iRow]:= FieldByName('DEFECT_CODE').AsString+' '+FieldByName('DEFECT_DESC').AsString;
        end
        else if FieldByName('DEFECT_CODE').AsString=' ' then
        begin
          Str:=FieldByName('PROCESS_NAME').asString;
          iRow:=slStrProcess.IndexOf(Str)+1;
          sgData.Cells[iCol,iRow+1]:= FieldByName('PASS_QTY').asString;
          //埃代癘魁 checkretry =false
          if checkretry.Checked = false then
             begin
                sgData.Cells[iCol,iRow+2]:= FieldByName('FAIL_QTY').asString;
                 //DPPM
                if (FieldByName('PASS_QTY').AsInteger>0) then
                   sgData.Cells[iCol,iRow+3]:= FormatFloat('0',(FieldByName('POINT_CNT').AsInteger * 1000000) / (FieldByName('PASS_QTY').AsInteger * STRTOINT(STRPOINTCOUNT)));
                   sgData.Cells[iCol,iRow+4]:= FieldByName('POINT_CNT').asString;
                // change by key 2008/03/28
               // if (FieldByName('FAIL_QTY').AsInteger+FieldByName('PASS_QTY').AsInteger>0) then
                  // sgData.Cells[iCol,iRow+3]:= FormatFloat('0',(FieldByName('FAIL_QTY').AsInteger * 1000000) / (FieldByName('PASS_QTY').AsInteger+FieldByName('FAIL_QTY').AsInteger));
                  // sgData.Cells[iCol,iRow+4]:= FieldByName('DEFECT_CNT').asString;
                  
                 //Yield
               if (FieldByName('FAIL_QTY').AsInteger>0) then
                 sgData.Cells[iCol,iRow+5]:= FloatToStrf((FieldByName('PASS_QTY').AsInteger)/(FieldByName('PASS_QTY').AsInteger+FieldByName('FAIL_QTY').AsInteger)*100 ,ffFixed, 6, 2)
               else
                 sgData.Cells[iCol,iRow+5]:= '100';
               //FPASS_QTY
              // sgData.Cells[iCol,iRow+6]:= FieldByName('FPASS_QTY').asString;
             end;
          // 埃代癘魁 checkretry =true
          if checkretry.Checked =true then
             begin
                 sgData.Cells[iCol,iRow+2]:= FieldByName('DEFECT_CNT').asString;
                //DPPM
                if (FieldByName('PASS_QTY').AsInteger>0) then
                   sgData.Cells[iCol,iRow+3]:= FormatFloat('0',(FieldByName('POINT_CNT').AsInteger * 1000000) / (FieldByName('PASS_QTY').AsInteger * STRTOINT(STRPOINTCOUNT)));
                   sgData.Cells[iCol,iRow+4]:= FieldByName('POINT_CNT').asString;
                 //Yield
                if (FieldByName('DEFECT_CNT').AsInteger>0) then
                   sgData.Cells[iCol,iRow+5]:= FloatToStrf((FieldByName('PASS_QTY').AsInteger)/(FieldByName('PASS_QTY').AsInteger+FieldByName('DEFECT_CNT').AsInteger)*100 ,ffFixed, 6, 2)
                else
                    sgData.Cells[iCol,iRow+5]:= '100';
              //FPASS_qTY
              // sgData.Cells[iCol,iRow+6]:= FieldByName('FPASS_QTY').asString;
             end;

          RTemp:=StrToFloatDef(YieldGrid.Cells[iCol,processlst.IndexOf(FieldByName('STAGE_NAME').AsString)+2],100);
          YieldGrid.Cells[iCol,processlst.IndexOf(FieldByName('STAGE_NAME').AsString)+2]:=FloatToStrf((RTemp*StrToFloatDef(sgData.Cells[iCol,iRow+5],100)/100),ffFixed, 6, 2);
          RTemp:=StrToFloatDef(YieldGrid.Cells[iCol,1],100);
          YieldGrid.Cells[iCol,1]:=FloatToStrf((RTemp*StrToFloatDef(sgData.Cells[iCol,iRow+5],100)/100),ffFixed, 6, 2);
        end;
        next;
      end;
      sgData.RowCount := slStrProcess.Count+1;
      YieldGrid.RowCount := processlst.Count+2;
      if slStrDay.Count<4 then
        sgData.ColCount:=7
      else
      sgData.ColCount:=slStrDay.Count+3;
      YieldGrid.ColCount := sgData.ColCount;
      slStrProcess.Free;
      slStrDay.Free;
      ProgressBar1.Progress:=0;
      ProgressBar1.Visible:=False;
    end;
    if G_DefectCnt<L_DefectCnt then G_DefectCnt:=L_DefectCnt;
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
  sgData.Height:=high-224;
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
  if sgData.Cells[3, ARow]='   ' then
  begin
    sgData.Canvas.Brush.Color:=clYellow;//改變底色
    sgData.Canvas.TextRect(Rect, Rect.Left+2, Rect.Top+4, sgData.Cells[ACol, ARow]);
  end else
  begin
   sgData.Canvas.Brush.Color:=clWhite;//改變底色
   sgData.Canvas.TextRect(Rect, Rect.Left+2, Rect.Top+4, sgData.Cells[ACol, ARow]);
  end;  
end;

procedure TfMainForm.EditDefectDblClick(Sender: TObject);
begin
   stIndexType:=Trim(PanelDefect.Caption);
   Button1Click(Self);
end;

procedure TfMainForm.Label5Click(Sender: TObject);
begin
   strpointcount:= InputBox('Input Box', 'please input point count!', '1');
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
