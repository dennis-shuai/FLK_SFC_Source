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
    Lblrecordcount: TLabel;
    Label3: TLabel;
    LabPdline: TLabel;
    Listpdline: TListBox;
    Qrydatagroup: TClientDataSet;
    RGFailType: TRadioGroup;
    QryDataSN: TClientDataSet;
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnQueryClick(Sender: TObject);
    procedure LabModelClick(Sender: TObject);
    procedure LblProcessClick(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
    procedure LabPdlineClick(Sender: TObject);
    procedure strgridDataDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    function AddCondition(sField: string; sList: TListBox): string;
    function AddCondition01(sField: string; sList: TListBox): string;
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
    procedure ShowAllData(sTitle,sFieldName,sFieldID:string;ListField:TListBox);
    function getmodelid(model_name: string): boolean;
    function getpdlineid(pdline_name: string): boolean;
    function getprocessid(process_name: string): boolean;
    function getDefectid(Defect_code: string): boolean;
  end;

var
  fDetail: TfDetail;
  icol,irow:integer;
  FcID :string;
  g_modelid,g_processid,g_pdlineid,g_defectid,g_SN:string;
  g_pdlineidofdetail:string;
implementation

uses uCommData, uSelect, UDataGroup;
{$R *.DFM}

function TfDetail.getmodelid(model_name: string): boolean;
begin
    result:=false;
    with qrytemp do
    begin
        close;
        params.CreateParam(ftstring,'model_name',ptinput);
        commandtext:='select model_id from sajet.sys_model where model_name=:model_name and rownum=1 ';
        params.ParamByName('model_name').AsString :=model_name;
        open;
        if not isempty then
        begin
            result:=true;
            g_modelid:=fieldbyname('model_id').asString ;
        end;
    end;
end;

function TfDetail.getpdlineid(pdline_name: string): boolean;
begin
    result:=false;
    with qrytemp do
    begin
        close;
        params.CreateParam(ftstring,'pdline_name',ptinput);
        commandtext:='select pdline_id from sajet.sys_pdline where pdline_name=:pdline_name and rownum=1 ';
        params.ParamByName('pdline_name').AsString :=pdline_name;
        open;
        if not isempty then
        begin
            result:=true;
            g_pdlineid:=fieldbyname('pdline_id').asString ;
        end;
    end;
end;

function TfDetail.getprocessid(process_name: string): boolean;
begin
    result:=false;
    with qrytemp do
    begin
        close;
        params.CreateParam(ftstring,'process_name',ptinput);
        commandtext:='select process_id from sajet.sys_process where process_name=:process_name and rownum=1 ';
        params.ParamByName('process_name').AsString :=process_name;
        open;
        if not isempty then
        begin
            result:=true;
            g_processid:=fieldbyname('process_id').asString ;
        end;
    end;
end;

function TfDetail.getDefectid(Defect_code: string): boolean;
begin
    result:=false;
    with qrytemp do
    begin
        close;
        params.CreateParam(ftstring,'defect_code',ptinput);
        commandtext:='select defect_id from sajet.sys_defect where defect_code=:defect_code and rownum=1 ';
        params.ParamByName('defect_code').AsString :=defect_code;
        open;
        if not isempty then
        begin
            result:=true;
            g_defectid:=fieldbyname('defect_id').asString ;
        end;
    end;
end;

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
           ColCount  :=11;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=80;
           cells[0,0]:='Model';
           colwidths[1]:=90;
           cells[1,0]:='Line';
           colwidths[2]:=90;
           cells[2,0]:='Process';
           CELLS[3,0]:='Input';
           CELLS[4,0]:='First Fail';
           CELLS[5,0]:='First Pass';
           CELLS[6,0]:='NTF';
           CELLS[7,0]:='Fail';
           CELLS[8,0]:='Failure Rate%';
           CELLS[9,0]:='NTF Rate%';
           CELLS[10,0]:='FPY%';
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

  My_FileName := ExtractFilePath(Application.ExeName)+'DFPYReport.xlt';

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
    ifirst_pass,ifirst_fail,intf,i:integer;
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

 { // QUERY NTF...
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
              +' AND A.work_date||trim(to_char(A.work_time,''00'' )) >= :starttime   '
              +' AND A.work_date||trim(to_char(A.work_time,''00'' )) < :endtime  '
              +' GROUP BY C.MODEL_NAME,D.PROCESS_NAME   '
              +' )  '
        +' GROUP BY MODEL_NAME ,PROCESS_NAME  ' ;
  }
  Strsql:=' SELECT C.MODEL_NAME,F.PDLINE_NAME,D.PROCESS_NAME,  '
         +' SUM(A.PASS_QTY) AS PASS_QTY ,SUM(A.FAIL_QTY ) AS FAIL_QTY,SUM(A.NTF_QTY ) AS NTF_QTY '
         +' FROM SAJET.G_SN_COUNT A,SAJET.SYS_PART B,SAJET.SYS_MODEL C,  '
         +' SAJET.SYS_PROCESS D,SAJET.G_WO_BASE E,SAJET.SYS_PDLINE F  '
         +' WHERE A.WORK_ORDER=E.WORK_ORDER '
         +' AND A.MODEL_ID=B.PART_ID  '
         +' AND B.MODEL_ID=C.MODEL_ID '
         +' AND A.PROCESS_ID=D.PROCESS_ID '
         +' AND A.PDLINE_ID=F.PDLINE_ID '
         +' AND E.FACTORY_ID=+'''+FCID+''' '
         + AddCondition( 'C.MODEL_NAME',ListModel)
         + AddCondition('f.pdline_NAME',Listpdline)
         + AddCondition('D.PROCESS_NAME',ListProcess)
         +' AND A.work_date||trim(to_char(A.work_time,''00'' )) >= :starttime   '
         +' AND A.work_date||trim(to_char(A.work_time,''00'' )) < :endtime  '
         +' group by c.model_name,F.PDLINE_NAME,d.process_name ';
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
          Strgriddata.Cells[1,irow]:=fieldbyname('PDLINE_NAME').AsString   ;
          Strgriddata.Cells[2,irow]:=fieldbyname('PROCESS_NAME').AsString   ;
          ifirst_pass:= fieldbyname('pass_qty').AsInteger ;
          ifirst_fail:= fieldbyname('fail_qty').AsInteger;
          intf:= fieldbyname('ntf_qty').AsInteger ;
          Strgriddata.Cells[3,irow]:=inttostr(ifirst_pass+ifirst_fail);
          Strgriddata.Cells[4,irow]:=inttostr(ifirst_fail);
          strgridData.Cells[5,irow]:=inttostr(ifirst_pass);
          Strgriddata.Cells[6,irow]:=inttostr(intf);
          Strgriddata.Cells[7,irow]:=inttostr(ifirst_fail-intf);
          if  ifirst_pass+ifirst_fail >0 then
          begin
              Strgriddata.Cells[8,irow]:=formatfloat('0.00', (ifirst_fail-intf) /(ifirst_pass+ifirst_fail)*100 );
              Strgriddata.Cells[9,irow]:=formatfloat('0.00', intf /(ifirst_pass+ifirst_fail)*100 );
              Strgriddata.Cells[10,irow]:=formatfloat('0.00', ifirst_pass/(ifirst_pass+ifirst_fail)*100 );
          end
          else
          begin
              Strgriddata.Cells[8,irow]:='0.00';
              Strgriddata.Cells[9,irow]:='0.00';
              Strgriddata.Cells[10,irow]:='0.00';
          end;
          next;
          Strgriddata.RowCount:=IROW+1;
      END;
  end;
  {
   // QUERY FIRST FAIL DEFECT_CODE
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
  }
 {
  // QUERY NTF DEFECT_CODE
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
  }
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

procedure TfDetail.LabPdlineClick(Sender: TObject);
begin
  with fDetail.qryTemp do
  begin
    close;
    Params.Clear;
    CommandText := 'Select pdline_name from sajet.sys_pdline order by pdline_Name';
    Open;
  end;

  ShowAllData('Line','','',ListPdline);
end;

procedure TfDetail.strgridDataDblClick(Sender: TObject);
var iDrow,iDcol:integer;
var sStartDate,sEndDate: string;
    sstarttime,sendtime:string;
    i:integer;
    strsql1:string; //First_fail
    strsql2:string;//NTF
    Strsql3:string;//first_fail - NTF 
begin
    iDrow:=strgridData.Row ;
    iDcol:=strgridData.Col;

  with tFDataGroup.create(Self) do
  begin
    try
        with strgridDatagroup do
        begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=10;
           ColCount  :=7;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=100;
           cells[0,0]:='Model';
           ColWidths[1]:=100;
           cells[1,0]:='Production Line';
           colwidths[2]:=90;
           cells[2,0]:='Work Order';
           colwidths[3]:=100;
           cells[3,0]:='Defect Process';
           colwidths[4]:=80;
           CELLS[4,0]:='Defect Code';
           colwidths[5]:=120;
           CELLS[5,0]:='Defect Desc';
           CELLS[6,0]:='QTY';
        end;
        for i:= 1 to strgridDatagroup.ROWCount do
            strgridDatagroup.ROWs[i].Clear;

        sStartDate:='';
        sEndDate:=''  ;
        sStartDate:=FormatDateTime('YYYYMMDD',datetimepickerstart.Date);
        sEndDate:=FormatDateTime('YYYYMMDD',datetimepickerEND.Date);

        sstarttime:=trim(sstartdate)+trim(combstarthour.Text);
        sendtime:=trim(senddate)+trim(combendhour.Text);

        if not getmodelid(strgridData.Cells[0,iDrow])  then
        begin
            showmessage('Not find the Model_Name:'+strgridData.Cells[0,iDrow]);
            exit;
        end;
        if not getpdlineid(strgridData.Cells[1,iDrow])  then
        begin
            showmessage('Not find the Line_Name:'+strgridData.Cells[1,iDrow]);
            exit;
        end
        else
           g_pdlineidofdetail:=g_pdlineid; //for UDataGroup first_fail - ntf 查詢使用

        if not getprocessid(strgridData.Cells[2,iDrow])  then
        begin
            showmessage('Not find the Process_Name:'+strgridData.Cells[2,iDrow]);
            exit;
        end;

        irow:=0;
        // QUERY FIRST FAIL 
        STRSQL1:= ' SELECT C.MODEL_NAME,G.PDLINE_NAME,A.WORK_ORDER,D.PROCESS_NAME, '
           +' F.DEFECT_CODE,F.DEFECT_DESC,   '
           +' COUNT(F.DEFECT_CODE) AS DEFECT_QTY   '
           +' FROM SAJET.G_SN_DEFECT_FIRST A,SAJET.SYS_PART B,SAJET.SYS_MODEL C,  '
           +' SAJET.SYS_PROCESS D,SAJET.G_WO_BASE E,SAJET.SYS_DEFECT F,SAJET.SYS_PDLINE G   '
           +' WHERE A.WORK_ORDER=E.WORK_ORDER   '
           +' AND A.MODEL_ID=B.PART_ID '
           +' AND B.MODEL_ID=C.MODEL_ID  '
           +' AND A.PROCESS_ID=D.PROCESS_ID  '
           +' AND A.DEFECT_ID=F.DEFECT_ID  '
           +' AND A.PDLINE_ID=G.PDLINE_ID '
           +' AND E.FACTORY_ID=+'''+FCID+''' '
           +' AND C.MODEL_id=:model_id '
           +' AND a.pdline_id=:pdline_id '
           +' AND a.PROCESS_id=:process_id '
           +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') >= :starttime  '
           +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') < :endtime '
           +' GROUP BY C.MODEL_NAME,G.PDLINE_NAME,A.WORK_ORDER,D.PROCESS_NAME, F.DEFECT_CODE,F.DEFECT_DESC '
           +' ORDER BY G.PDLINE_NAME,A.WORK_ORDER,D.PROCESS_NAME ' ;
        // QUERY NTF
        STRSQL2:= ' SELECT C.MODEL_NAME,G.PDLINE_NAME,A.WORK_ORDER,D.PROCESS_NAME, '
           +' F.DEFECT_CODE,F.DEFECT_DESC,   '
           +' COUNT(F.DEFECT_CODE) AS DEFECT_QTY   '
           +' FROM SAJET.G_SN_DEFECT_FIRST A,SAJET.SYS_PART B,SAJET.SYS_MODEL C,  '
           +' SAJET.SYS_PROCESS D,SAJET.G_WO_BASE E,SAJET.SYS_DEFECT F,SAJET.SYS_PDLINE G   '
           +' WHERE A.WORK_ORDER=E.WORK_ORDER   '
           +' AND A.MODEL_ID=B.PART_ID '
           +' AND B.MODEL_ID=C.MODEL_ID  '
           +' AND A.PROCESS_ID=D.PROCESS_ID  '
           +' AND A.DEFECT_ID=F.DEFECT_ID  '
           +' AND A.PDLINE_ID=G.PDLINE_ID '
           +' AND E.FACTORY_ID=+'''+FCID+''' '
           +' AND C.MODEL_id=:model_id '
           +' AND a.pdline_id=:pdline_id '
           +' AND a.PROCESS_id=:process_id'
           +' AND A.NTF_TIME IS NOT NULL '
           +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') >= :starttime  '
           +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') < :endtime '
           +' GROUP BY C.MODEL_NAME,G.PDLINE_NAME,A.WORK_ORDER,D.PROCESS_NAME, F.DEFECT_CODE,F.DEFECT_DESC '
           +' ORDER BY G.PDLINE_NAME,A.WORK_ORDER,D.PROCESS_NAME ' ;
       // QUERY First fail - NTF
       STRSQL3:= ' SELECT C.MODEL_NAME,G.PDLINE_NAME,A.WORK_ORDER,D.PROCESS_NAME, '
           +' F.DEFECT_CODE,F.DEFECT_DESC,   '
           +' COUNT(F.DEFECT_CODE) AS DEFECT_QTY   '
           +' FROM SAJET.G_SN_DEFECT_FIRST A,SAJET.SYS_PART B,SAJET.SYS_MODEL C,  '
           +' SAJET.SYS_PROCESS D,SAJET.G_WO_BASE E,SAJET.SYS_DEFECT F, '
           +' SAJET.SYS_PDLINE G,sajet.g_sn_defect H   '
           +' WHERE A.WORK_ORDER=E.WORK_ORDER   '
           +' AND A.MODEL_ID=B.PART_ID '
           +' AND B.MODEL_ID=C.MODEL_ID  '
           +' AND A.PROCESS_ID=D.PROCESS_ID'
           +' AND A.LAST_RECID=H.RECID '
           +' AND A.PDLINE_ID=+'''+g_pdlineidofdetail+''' ' //add by key 2008/12/25 
           +' AND H.DEFECT_ID=F.DEFECT_ID  ' // 取最後的defect code
           +' AND H.PDLINE_ID=G.PDLINE_ID '  //取最後的pdline name
           +' AND E.FACTORY_ID=+'''+FCID+''' '
           +' AND C.MODEL_id=:model_id '
           +' AND a.pdline_id=:pdline_id '   //此處pdline_id 一定要取g_sn_defect_first table中的值
           +' AND a.PROCESS_id=:process_id'
           +' AND A.NTF_TIME IS NULL '      //First fail - ntf
           +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') >= :starttime  '
           +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') < :endtime '
           +' GROUP BY C.MODEL_NAME,G.PDLINE_NAME,A.WORK_ORDER,D.PROCESS_NAME, F.DEFECT_CODE,F.DEFECT_DESC '
           +' ORDER BY G.PDLINE_NAME,A.WORK_ORDER,D.PROCESS_NAME ' ;
       with QryDataGroup do
       begin
            Close;
            if RGFailtype.ItemIndex  =0 then // first fail
            begin
               if strgridData.Cells[4,iDrow]='0' then exit;
               commandtext:=strsql1;
            end;
            if RGFailtype.ItemIndex =1 then // NTF fail
            begin
               if strgridData.Cells[6,iDrow]='0' then exit;
               commandtext:=strsql2;
            end;
            if RGFailtype.ItemIndex =2 then // First_fail - NTF
            begin
               if strgridData.Cells[7,iDrow]='0' then exit;
               commandtext:=strsql3;
            end;

            params.ParamByName('starttime').AsString :=sstarttime;
            params.ParamByName('endtime').AsString :=sendtime;
            params.ParamByName('model_id').AsString :=g_modelid;
            params.ParamByName('pdline_id').AsString :=g_pdlineid;
            params.ParamByName('process_id').AsString :=g_processid;
            Open;
            while not eof do
            begin
               IROW:=IROW+1;
               strgridDatagroup.Cells[0,irow]:=fieldbyname('MODEL_NAME').asstring ;
               Strgriddatagroup.Cells[1,irow]:=fieldbyname('PDLINE_NAME').AsString   ;
               Strgriddatagroup.Cells[2,irow]:=fieldbyname('WORK_ORDER').AsString   ;
               Strgriddatagroup.Cells[3,irow]:=fieldbyname('PROCESS_NAME').AsString;
               strgridDatagroup.Cells[4,irow]:=fieldbyname('DEFECT_CODE').asstring ;
               Strgriddatagroup.Cells[5,irow]:=fieldbyname('DEFECT_DESC').AsString   ;
               Strgriddatagroup.Cells[6,irow]:=fieldbyname('DEFECT_QTY').AsString;
               next;
               Strgriddatagroup.RowCount:=IROW+1;
             END;
        end;




      if ShowModal = mrOK then
      begin
        {ListField.Clear;
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
        end; }
      end;
    finally
      //fDetail.qryTemp.Close;
     // tsFieldName.free;
     // tsFieldID.free;
      free;
    end;
  end;
end;

end.

