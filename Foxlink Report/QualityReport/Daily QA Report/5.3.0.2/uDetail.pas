unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db,
  DBClient, MConnect, ObjBrkr, SConnect,GradPanel, Variants, comobj, Menus;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    SpeedButton5: TSpeedButton;
    Image2: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    QryTemp2: TClientDataSet;
    PageControl1: TPageControl;
    TabData: TTabSheet;
    GradPanel14: TGradPanel;
    Image7: TImage;
    sbtnSave: TSpeedButton;
    Image8: TImage;
    sbtnPrint: TSpeedButton;
    ImageTitle: TImage;
    Label4: TLabel;
    SaveDialog1: TSaveDialog;
    strgridData: TStringGrid;
    Image3: TImage;
    sbtnQuery: TSpeedButton;
    ListModel: TListBox;
    LabModel: TLabel;
    LblProcess: TLabel;
    ListProcess: TListBox;
    DateTimePickerstart: TDateTimePicker;
    DateTimePickerend: TDateTimePicker;
    Label5: TLabel;
    Label7: TLabel;
    combStartHour: TComboBox;
    Combendhour: TComboBox;
    cmbFactory: TComboBox;
    LabWotype: TLabel;
    Listwotype: TListBox;
    Lblrecordcount: TLabel;
    Label3: TLabel;
    CheckviewFirstfaildefect: TCheckBox;
    Checkviewntfdefect: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnQueryClick(Sender: TObject);
    procedure LabModelClick(Sender: TObject);
    procedure LblProcessClick(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
    procedure LabWotypeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    function AddCondition(sField: string; sList: TListBox): string;
    function AddCondition01(sField: string; sList: TListBox): string;
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
    procedure ShowAllData(sTitle,sFieldName,sFieldID:string;ListField:TListBox);
  end;

var
  fDetail: TfDetail;
  icol,irow:integer;
  FcID :string;
implementation

uses uCommData, uSelect;
{$R *.DFM}

procedure TfDetail.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var i, j,iStartRow,iDiv,iMod: integer;
    vRange1:Variant;
begin
   istartrow:=2 ;
   for i := 0 to strgridData.RowCount  do
      BEGIN
          for j := 0 to strgridData.ColCount  do
            MsExcel.Worksheets['Sheet1'].Cells[i+iStartRow,j+1].value := strgridData.Cells[j,i];
      END ;
end;



function TfDetail.AddCondition(sField: string; sList: TListBox): string;
var i: Integer;
begin
  Result := '';
  if sList.Count <> 0 then
  begin
    Result := ' AND ( ';
    for i := 0 to sList.Items.Count - 1 do
    begin
      if i = 0 then
        Result := Result + sField + '= ''' + sList.Items.Strings[i] + ''' '
      else
        Result := Result + 'OR ' + sField + '= ''' + sList.Items.Strings[i] + ''' ';
    end;
    Result := Result + ') ';
  end;
end;

function TfDetail.AddCondition01(sField: string; sList: TListBox): string;
var i: Integer;
begin
  Result := '';
  if sList.Count <> 0 then
  begin
    Result := ' AND ( ';
    for i := 0 to sList.Items.Count - 1 do
    begin
      if i = 0 then
        Result := Result + ' substr('+ sField +',1,1)' + '= ''' + copy(sList.Items.Strings[i],1,1) + ''' '
      else
        Result := Result + ' OR substr('+ sField +',1,1)' + '= ''' + copy(sList.Items.Strings[i],1,1) + ''' ';
    end;
    Result := Result + ') ';
  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var sYear:string;
    i:integer;
begin  //GetReportName;
  with strgridData do
  begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=10;
           ColCount  :=10;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=80;
           cells[0,0]:='機種名稱';
           colwidths[1]:=90;
           cells[1,0]:='站別';
           colwidths[2]:=90;
           CELLS[2,0]:='First Pass_Qty';
           CELLS[3,0]:='First Fail_Qty';
           CELLS[4,0]:='Input_Qty';
           CELLS[5,0]:='NTF_Qty';
           CELLS[6,0]:='不良零件個數';
           CELLS[7,0]:='First Pass Yield%';
           CELLS[8,0]:='SPY';
           CELLS[9,0]:='NTF Rate%';

  end;
    lblrecordcount.Caption :='';
    DateTimePickerstart.Date:=now;
    DateTimePickerend.Date :=now+1 ;

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

procedure TfDetail.sbtnSaveClick(Sender: TObject);
var
  sFileName, My_FileName: string;
  MsExcel, MsExcelWorkBook: Variant;
  i: Integer;
begin
  if (not QryData.Active) or (QryData.IsEmpty) then Exit;
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'xls';
  SaveDialog1.Filter := 'All Files(*.xls)|*.xls';

  My_FileName := ExtractFilePath(Application.ExeName)+'DQAReport.xlt';

  if not FileExists(My_FileName) then
  begin
    showmessage('Error!-The Excel File ' + My_FileName + ' can''t be found.');
    exit;
  end;

  if Sender = sbtnSave then
  begin
    if SaveDialog1.Execute then
      sFileName := SaveDialog1.FileName
    else
      exit;  
  end;

  try
    MsExcel := CreateOleObject('Excel.Application');
    MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);

    MsExcel.Worksheets['Sheet1'].select;
    SaveExcel(MsExcel, MsExcelWorkBook);
    if Sender = sbtnSave then
    begin
      MsExcelWorkBook.SaveAs(sFileName);
      showmessage('Save Excel OK!!');
    end;
    if Sender = sbtnPrint then
    begin
      WindowState := wsMinimized;
      MsExcel.Visible := TRUE;
      MsExcel.WorkSheets['Sheet1'].PrintPreview;
      WindowState := wsMaximized;
    end;
  except
    ShowMessage('Could not start Microsoft Excel.');
  end;
  MsExcelWorkBook.close(False);
  MsExcel.Application.Quit;
  MsExcel := Null;

end;

procedure TfDetail.FormClose(Sender: TObject; var Action: TCloseAction);
begin  
  Action := caFree;
end;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
var sStartDate,sEndDate: string;
    sstarttime,sendtime:string;
    i:integer;
    strsql:string;
begin
   if listmodel.Count=0 then
     begin
         for i:= 1 to strgridData.ROWCount do
              strgridData.ROWs[i].Clear;
         lblrecordcount.Caption :='Total:0' ;
         showmessage('please select one or more model!');
         exit;
     end;
   sStartDate:='';
   sEndDate:=''  ;
   sStartDate:=FormatDateTime('YYYYMMDD',datetimepickerstart.Date);
   sEndDate:=FormatDateTime('YYYYMMDD',datetimepickerEND.Date);

   sstarttime:=trim(sstartdate)+trim(combstarthour.Text);
   sendtime:=trim(senddate)+trim(combendhour.Text);

  for i:= 1 to strgridData.ROWCount do
    strgridData.ROWs[i].Clear;
  {
  // QUERY NTF...
  strsql:=' SELECT MODEL_NAME, PROCESS_NAME,SUM(PASS_QTY) AS F_PASS_QTY,SUM(FAIL_QTY) AS F_FAIL_QTY ,   '
          +' SUM(PASS_QTY)+SUM(FAIL_QTY) AS INPUT_QTY,  '
          +' SUM(NTF_QTY) AS NTF_QTY,SUM(POINT_QTY) AS POINT_QTY , '
          +' TO_CHAR(SUM(PASS_QTY)/(SUM(PASS_QTY)+SUM(FAIL_QTY))*100,''990.99'') AS FIRST_PASS_RIELD,  '
          +' TO_CHAR((SUM(PASS_QTY)+SUM(NTF_QTY))/(SUM(PASS_QTY)+SUM(FAIL_QTY))*100,''990.99'') AS SPY,  '
          +' TO_CHAR(SUM(NTF_QTY)/(SUM(PASS_QTY)+SUM(FAIL_QTY))*100,''990.99'') AS NTF_RATE  '
          +' FROM   '
          +' (  '  //PASS_QTY,FAIL_QTY
              +' SELECT C.MODEL_NAME,D.PROCESS_NAME,SUM(A.PASS_QTY) AS PASS_QTY ,SUM(A.FAIL_QTY ) AS FAIL_QTY,   '
              +' 0 NTF_QTY,0 POINT_QTY  '
              +' FROM SAJET.G_SN_COUNT A,SAJET.SYS_PART B,SAJET.SYS_MODEL C,  '
              +' SAJET.SYS_PROCESS D,SAJET.G_WO_BASE E     '
              +' WHERE A.WORK_ORDER=E.WORK_ORDER   '
              +' AND A.MODEL_ID=B.PART_ID  '
              +' AND B.MODEL_ID=C.MODEL_ID  '
              +' AND A.PROCESS_ID=D.PROCESS_ID '
              +' AND E.FACTORY_ID=+'''+FCID+''' '
              + AddCondition( 'C.MODEL_NAME',ListModel)
              + AddCondition('D.PROCESS_NAME',ListProcess)
              + AddCondition01('E.work_order',ListWOTYPE)
              +' AND A.work_date||trim(to_char(A.work_time,''00'' )) >= :starttime   '
              +' AND A.work_date||trim(to_char(A.work_time,''00'' )) < :endtime  '
              +' GROUP BY C.MODEL_NAME,D.PROCESS_NAME   '
              +' UNION ALL '
               //NTF_QTY
              +' SELECT C.MODEL_NAME,D.PROCESS_NAME,0 PASS_QTY ,0 FAIL_QTY ,COUNT(A.SERIAL_NUMBER) AS NTF_QTY,0 POINT_QTY  '
              +' FROM SAJET.G_SN_DEFECT_FIRST A,SAJET.SYS_PART B,SAJET.SYS_MODEL C,    '
              +' SAJET.SYS_PROCESS D,SAJET.G_WO_BASE E   '
              +' WHERE A.WORK_ORDER=E.WORK_ORDER   '
              +' AND A.MODEL_ID=B.PART_ID    '
              +' AND B.MODEL_ID=C.MODEL_ID    '
              +' AND A.PROCESS_ID=D.PROCESS_ID  '
              +' AND E.FACTORY_ID=+'''+FCID+''' '
              + AddCondition( 'C.MODEL_NAME',ListModel)
              + AddCondition('D.PROCESS_NAME',ListProcess)
              + AddCondition01('E.work_order',ListWOTYPE)
              +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') >= :starttime '
              +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') < :endtime '
              +' AND A.NTF_TIME IS NOT NULL  '
              +' GROUP BY C.MODEL_NAME,D.PROCESS_NAME  '
              +' UNION ALL '
               //POINT_QTY
              +' SELECT C.MODEL_NAME,D.PROCESS_NAME,0 PASS_QTY, 0 FAIL_QTY, 0 NTF_QTY, SUM(F.REPAIR_POINT) AS  POINT_QTY   '
              +' FROM SAJET.G_SN_DEFECT A,SAJET.SYS_PART B,SAJET.SYS_MODEL C, '
              +' SAJET.SYS_PROCESS D,SAJET.G_WO_BASE E,SAJET.G_SN_REPAIR_POINT F '
              +' WHERE A.WORK_ORDER=E.WORK_ORDER   '
              +' AND A.MODEL_ID=B.PART_ID  '
              +' AND B.MODEL_ID=C.MODEL_ID '
              +' AND A.PROCESS_ID=D.PROCESS_ID  '
              +' AND E.FACTORY_ID=+'''+FCID+''' '
              + AddCondition( 'C.MODEL_NAME',ListModel)
              + AddCondition('D.PROCESS_NAME',ListProcess)
              + AddCondition01('E.work_order',ListWOTYPE)
              +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') >= :starttime  '
              +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') < :endtime '
              +' AND A.RECID=F.RECID  '
              +' GROUP BY C.MODEL_NAME,D.PROCESS_NAME   '
              +' )  '
        +' GROUP BY MODEL_NAME ,PROCESS_NAME  ' ;
    }

      strsql:=' SELECT MODEL_NAME, PROCESS_NAME,SUM(PASS_QTY) AS F_PASS_QTY,SUM(FAIL_QTY) AS F_FAIL_QTY ,   '
          +' SUM(PASS_QTY)+SUM(FAIL_QTY) AS INPUT_QTY,  '
          +' SUM(NTF_QTY) AS NTF_QTY,SUM(PART_QTY) AS PART_QTY , '
          +' TO_CHAR(SUM(PASS_QTY)/(SUM(PASS_QTY)+SUM(FAIL_QTY))*100,''990.99'') AS FIRST_PASS_RIELD,  '
          +' TO_CHAR((SUM(PASS_QTY)+SUM(NTF_QTY))/(SUM(PASS_QTY)+SUM(FAIL_QTY))*100,''990.99'') AS SPY,  '
          +' TO_CHAR(SUM(NTF_QTY)/(SUM(PASS_QTY)+SUM(FAIL_QTY))*100,''990.99'') AS NTF_RATE  '
          +' FROM   '
          +' (  '  //PASS_QTY,FAIL_QTY,NTF_QTY
              +' SELECT C.MODEL_NAME,D.PROCESS_NAME,SUM(A.PASS_QTY) AS PASS_QTY ,SUM(A.FAIL_QTY ) AS FAIL_QTY,   '
              +' SUM(A.NTF_QTY ) AS NTF_QTY,0 PART_QTY  '
              +' FROM SAJET.G_SN_COUNT A,SAJET.SYS_PART B,SAJET.SYS_MODEL C,  '
              +' SAJET.SYS_PROCESS D,SAJET.G_WO_BASE E     '
              +' WHERE A.WORK_ORDER=E.WORK_ORDER   '
              +' AND A.MODEL_ID=B.PART_ID  '
              +' AND B.MODEL_ID=C.MODEL_ID  '
              +' AND A.PROCESS_ID=D.PROCESS_ID '
              +' AND E.FACTORY_ID=+'''+FCID+''' '
              + AddCondition( 'C.MODEL_NAME',ListModel)
              + AddCondition('D.PROCESS_NAME',ListProcess)
              + AddCondition01('E.work_order',ListWOTYPE)
              +' AND A.work_date||trim(to_char(A.work_time,''00'' )) >= :starttime   '
              +' AND A.work_date||trim(to_char(A.work_time,''00'' )) < :endtime  '
              +' GROUP BY C.MODEL_NAME,D.PROCESS_NAME   '
              +' UNION ALL '
               //POINT_QTY
              +' SELECT C.MODEL_NAME,D.PROCESS_NAME,0 PASS_QTY, 0 FAIL_QTY, 0 NTF_QTY, SUM(F.PART_QTY) AS  PART_QTY   '
              +' FROM SAJET.G_SN_DEFECT A,SAJET.SYS_PART B,SAJET.SYS_MODEL C, '
              +' SAJET.SYS_PROCESS D,SAJET.G_WO_BASE E,SAJET.G_SN_REPAIR_POINT F '
              +' WHERE A.WORK_ORDER=E.WORK_ORDER   '
              +' AND A.MODEL_ID=B.PART_ID  '
              +' AND B.MODEL_ID=C.MODEL_ID '
              +' AND A.PROCESS_ID=D.PROCESS_ID  '
              +' AND E.FACTORY_ID=+'''+FCID+''' '
              + AddCondition( 'C.MODEL_NAME',ListModel)
              + AddCondition('D.PROCESS_NAME',ListProcess)
              + AddCondition01('E.work_order',ListWOTYPE)
              +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') >= :starttime  '
              +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') < :endtime '
              +' AND A.RECID=F.RECID  '
              +' GROUP BY C.MODEL_NAME,D.PROCESS_NAME   '
              +' )  '
        +' GROUP BY MODEL_NAME ,PROCESS_NAME  ' ;

  with QryData do
  begin
    Close;
    commandtext:=strsql;
    params.ParamByName('starttime').AsString :=sstarttime;
    params.ParamByName('endtime').AsString :=sendtime;

    Open;
    if IsEmpty then
    begin
      Showmessage('No Data');
      exit;
    end;

    irow:=0;
      icol:=0;
      while not eof do
      begin
          IROW:=IROW+1;
          strgridData.Cells[0,irow]:=fieldbyname('MODEL_NAME').asstring ;
          Strgriddata.Cells[1,irow]:=fieldbyname('PROCESS_NAME').AsString   ;
          Strgriddata.Cells[2,irow]:=fieldbyname('F_PASS_QTY').AsString   ;
          Strgriddata.Cells[3,irow]:=fieldbyname('F_FAIL_QTY').AsString;
          Strgriddata.Cells[4,irow]:=fieldbyname('INPUT_QTY').AsString ;
          strgridData.Cells[5,irow]:=fieldbyname('NTF_QTY').asstring ;
          Strgriddata.Cells[6,irow]:=fieldbyname('PART_QTY').AsString   ;
          Strgriddata.Cells[7,irow]:=fieldbyname('FIRST_PASS_RIELD').AsString   ;
          Strgriddata.Cells[8,irow]:=fieldbyname('SPY').AsString;
          Strgriddata.Cells[9,irow]:=fieldbyname('NTF_RATE').AsString ;
          next;
          Strgriddata.RowCount:=IROW+1;
      END;
  end;

   // QUERY FIRST FAIL DEFECT_CODE
  if checkviewfirstfaildefect.Checked =true then
  begin
     irow:=irow+2;
     Strgriddata.Cells[2,irow]:='First Fail Defect desc' ;
     irow:=irow+2;
     with strgriddata do
     begin
          cells[0,irow]:='機種名稱';
          cells[1,irow]:='站別';
          CELLS[2,irow]:='First Fail Defect_Code';
          CELLS[3,irow]:='First Fail Defect_Qty';
     end;
     STRSQL:= ' SELECT C.MODEL_NAME,D.PROCESS_NAME, '
           +' F.DEFECT_CODE||''-''||F.DEFECT_DESC AS DEFECT_CODE,  '
           +' COUNT(F.DEFECT_CODE||''-''||F.DEFECT_DESC) AS DEFECT_QTY   '
           +' FROM SAJET.G_SN_DEFECT_FIRST A,SAJET.SYS_PART B,SAJET.SYS_MODEL C,  '
           +' SAJET.SYS_PROCESS D,SAJET.G_WO_BASE E,SAJET.SYS_DEFECT F   '
           +' WHERE A.WORK_ORDER=E.WORK_ORDER   '
           +' AND A.MODEL_ID=B.PART_ID '
           +' AND B.MODEL_ID=C.MODEL_ID  '
           +' AND A.PROCESS_ID=D.PROCESS_ID  '
           +' AND A.DEFECT_ID=F.DEFECT_ID  '
           +' AND E.FACTORY_ID=+'''+FCID+''' '
           + AddCondition( 'C.MODEL_NAME',ListModel)
           + AddCondition('D.PROCESS_NAME',ListProcess)
           + AddCondition01('E.work_order',ListWOTYPE)
           +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') >= :starttime  '
           +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') < :endtime '
           +' GROUP BY C.MODEL_NAME,D.PROCESS_NAME,F.DEFECT_CODE||''-''||F.DEFECT_DESC  ';

      with QryData do
      begin
         Close;
         commandtext:=strsql;
         params.ParamByName('starttime').AsString :=sstarttime;
         params.ParamByName('endtime').AsString :=sendtime;

        Open;
         while not eof do
         begin
              IROW:=IROW+1;
              strgridData.Cells[0,irow]:=fieldbyname('MODEL_NAME').asstring ;
              Strgriddata.Cells[1,irow]:=fieldbyname('PROCESS_NAME').AsString   ;
              Strgriddata.Cells[2,irow]:=fieldbyname('DEFECT_CODE').AsString   ;
              Strgriddata.Cells[3,irow]:=fieldbyname('DEFECT_QTY').AsString;
             next;
             Strgriddata.RowCount:=IROW+1;
         END;
       end;
   end;

  // QUERY NTF DEFECT_CODE
  if checkviewntfdefect.Checked = true then
  begin
       irow:=irow+2;
       Strgriddata.Cells[2,irow]:='NTF Defect desc' ;
       irow:=irow+2;
       with strgriddata do
       begin
           cells[0,irow]:='機種名稱';
           cells[1,irow]:='站別';
           CELLS[2,irow]:='NTF Defect_Code';
           CELLS[3,irow]:='NTF Defect_Qty';
       end;
       STRSQL:= ' SELECT C.MODEL_NAME,D.PROCESS_NAME, '
           +' F.DEFECT_CODE||''-''||F.DEFECT_DESC AS DEFECT_CODE,  '
           +' COUNT(F.DEFECT_CODE||''-''||F.DEFECT_DESC) AS DEFECT_QTY   '
           +' FROM SAJET.G_SN_DEFECT_FIRST A,SAJET.SYS_PART B,SAJET.SYS_MODEL C,  '
           +' SAJET.SYS_PROCESS D,SAJET.G_WO_BASE E,SAJET.SYS_DEFECT F   '
           +' WHERE A.WORK_ORDER=E.WORK_ORDER   '
           +' AND A.MODEL_ID=B.PART_ID '
           +' AND B.MODEL_ID=C.MODEL_ID  '
           +' AND A.PROCESS_ID=D.PROCESS_ID  '
           +' AND A.DEFECT_ID=F.DEFECT_ID  '
           +' AND E.FACTORY_ID=+'''+FCID+''' '
           +' AND A.NTF_TIME IS NOT NULL '   // NTF 
           + AddCondition( 'C.MODEL_NAME',ListModel)
           + AddCondition('D.PROCESS_NAME',ListProcess)
           + AddCondition01('E.work_order',ListWOTYPE)
           +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') >= :starttime  '
           +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') < :endtime '
           +' GROUP BY C.MODEL_NAME,D.PROCESS_NAME,F.DEFECT_CODE||''-''||F.DEFECT_DESC  ';

         with QryData do
         begin
            Close;
            commandtext:=strsql;
            params.ParamByName('starttime').AsString :=sstarttime;
            params.ParamByName('endtime').AsString :=sendtime;

           Open;
           while not eof do
           begin
              IROW:=IROW+1;
              strgridData.Cells[0,irow]:=fieldbyname('MODEL_NAME').asstring ;
              Strgriddata.Cells[1,irow]:=fieldbyname('PROCESS_NAME').AsString   ;
              Strgriddata.Cells[2,irow]:=fieldbyname('DEFECT_CODE').AsString   ;
              Strgriddata.Cells[3,irow]:=fieldbyname('DEFECT_QTY').AsString;
              next;
              Strgriddata.RowCount:=IROW+1;
          END;
       end;
   end;
end;


procedure TfDetail.ShowAllData(sTitle,sFieldName,sFieldID:string;ListField:TListBox);
Var I,iIndex : Integer;
   tsFieldName,tsFieldID:TStringList;
begin
  //fSelect:=TfSelect.create(Self);
  with TfSelect.create(Self) do
  begin
    try
      listbAvail.Clear;
      listbSel.Clear;
      tsFieldName := TStringList.Create;
      tsFieldID := TStringList.Create;

      lablTitle.Caption := sTitle+' List ';
      if ListField.Items.Count <> 0 then begin
        for I := 0 to ListField.Items.Count - 1 do
        begin
           if listbSel.Items.IndexOf(ListField.Items[i])<0 Then
             listbSel.Items.AddObject(ListField.Items[I],
           ListField.Items.Objects[I]);
        end;
      end;

      While not fDetail.qryTemp.Eof do
      begin
        if  listbSel.Items.Indexof(fDetail.qryTemp.Fields[0].AsString)=-1 then
          listbAvail.Items.Add(fDetail.qryTemp.Fields[0].AsString);
        tsFieldName.Add(fDetail.qryTemp.Fields[0].AsString);
        fDetail.qryTemp.Next;
      end;
      if ShowModal = mrOK then
      begin
        ListField.Clear;
        if listbSel.Items.Count <> 0 then
        begin
          for I := 0 to listbSel.Items.Count - 1 do
          begin
            if ListField.Items.IndexOf(listbSel.Items[i])<0 Then
            begin
                ListField.Items.AddObject(listbSel.Items[I],listbSel.Items.Objects[I]);
                iIndex := tsFieldName.Indexof(listbSel.Items[I]);
            end;
          end;
        end;
      end;
    finally
      fDetail.qryTemp.Close;
      tsFieldName.free;
      tsFieldID.free;
      free;
    end;
  end;
end;

procedure TfDetail.LabModelClick(Sender: TObject);
begin
  with fDetail.qryTemp do
  begin
    close;
    Params.Clear;
    CommandText := 'Select model_name from sajet.sys_model order by Model_Name';
    Open;
  end;

  ShowAllData('Model','','',ListModel);
end;

procedure TfDetail.LblProcessClick(Sender: TObject);
begin
  with fDetail.qryTemp do
  begin
    close;
    Params.Clear;
    CommandText := 'select process_name from sajet.sys_process where enabled=''Y'' ORDER BY PROCESS_NAME ';
    Open;
  end;

  ShowAllData('Process','','',ListProcess);
end;

procedure TfDetail.cmbFactoryChange(Sender: TObject);
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

procedure TfDetail.LabWotypeClick(Sender: TObject);
begin
  with fDetail.qryTemp do
  begin
    close;
    Params.Clear;
    CommandText := ' select ''N-工令'' as wo_type from dual  '
                  +' union '
                  +' select ''R-工令'' as wo_type from dual   '
                  +' union '
                  +' select ''S-工令'' as wo_type from dual '
                  +' union '
                  +' select ''C-工令'' as wo_type from dual ';
    Open;
  end;

  ShowAllData('WO_type','','',Listwotype);
end;

end.

