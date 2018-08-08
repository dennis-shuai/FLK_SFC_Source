unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db,
  DBClient, MConnect, ObjBrkr, SConnect,GradPanel, Variants, comobj, Menus,
  TeEngine, Series, TeeProcs, Chart, StatChar;

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
    Editwo: TEdit;
    Editdefectcode: TEdit;
    Editreasoncode: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Editlocate: TEdit;
    Chart1: TChart;
    LineSeries1: TFastLineSeries;
    BarSeries1: THistogramSeries;
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnQueryClick(Sender: TObject);
    procedure LabModelClick(Sender: TObject);
    procedure LblProcessClick(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
    procedure LabPdlineClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    function AddCondition(sField: string; sList: TListBox): string;
    function AddCondition01(sField: string; sList: TListBox): string;
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
    procedure ShowLineSeries;
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
           ColCount  :=13;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=80;
           cells[0,0]:='Model Name';
           colwidths[1]:=90;
           cells[1,0]:='Work Order';
           colwidths[2]:=90;
           cells[2,0]:='Serial number';
           CELLS[3,0]:='Line Name';
           CELLS[4,0]:='Defect Process';
           CELLS[5,0]:='Defect Time';
           CELLS[6,0]:='Defect Code';
           CELLS[7,0]:='Defect Desc';
           CELLS[8,0]:='Reason Code';
           CELLS[9,0]:='Reason Desc';
           CELLS[10,0]:='Locate';
           CELLS[11,0]:='Fail Part Qty';
           CELLS[12,0]:='Remark';
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

  My_FileName := ExtractFilePath(Application.ExeName)+'DProcessReport.xlt';

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

  Strsql:='SELECT F.MODEL_NAME,A.WORK_ORDER,A.SERIAL_NUMBER,H.PDLINE_NAME, '
         +' J.PROCESS_NAME,K.DEFECT_CODE,K.DEFECT_DESC,A.REC_TIME, '
         +' L.REASON_CODE,L.REASON_DESC,D.LOCATION,C.REPAIR_REMARK,E.PART_QTY  '
         +' FROM SAJET.G_SN_DEFECT A,SAJET.G_SN_REPAIR B,SAJET.G_SN_REPAIR_REMARK C, '
         +' SAJET.G_SN_REPAIR_LOCATION D,SAJET.G_SN_REPAIR_POINT E, '
         +' SAJET.SYS_MODEL F, SAJET.SYS_PART G, SAJET.SYS_PDLINE H,  '
         +' SAJET.SYS_PROCESS J,SAJET.SYS_DEFECT K,SAJET.SYS_REASON L,  '
         +' SAJET.G_WO_BASE M,SAJET.SYS_FACTORY N     '
         +' WHERE A.RECID=B.RECID(+)  '
         +' AND A.RECID=C.RECID(+)  '
         +' AND A.RECID=D.RECID(+) '
         +' AND A.RECID=E.RECID(+) '
         +' AND A.work_order=M.WORK_ORDER  '
         +' AND M.MODEL_ID=G.PART_ID '
         +' AND G.MODEL_ID=F.MODEL_ID  '
         +' AND A.PDLINE_ID=H.PDLINE_ID  '
         +' AND A.PROCESS_ID=J.PROCESS_ID  '
         +' AND A.DEFECT_ID=K.DEFECT_ID  '
         +' AND B.REASON_ID=L.REASON_ID(+)  '
         +' AND M.FACTORY_ID=N.FACTORY_ID '
         +' AND N.FACTORY_ID=+'''+FCID+''' '
         + AddCondition( 'F.MODEL_NAME',ListModel)
         + AddCondition('H.pdline_NAME',Listpdline)
         + AddCondition('J.PROCESS_NAME',ListProcess)
         +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') >= :starttime   '
         +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') < :endtime  ' ;
  if Trim(Editwo.Text)<>'' then
      strsql:=strsql+' AND M.WORK_ORDER='''+Editwo.Text+''' ';
  if trim(editDEFECTCODE.Text)<>'' Then
     strsql:=strsql+' AND K.DEFECT_CODE=''' +Editdefectcode.Text + ''' ';
  if trim(editreasoncode.Text)<>'' then
     strsql:=strsql+' AND L.REASON_CODE='''+EDITREASONCODE.Text +''' ';
  if trim(editlocate.Text)<>'' then
     strsql:=strsql+' AND D.LOCATION='''+EDITLOCATE.Text +''' ';
  Strsql:=strsql +' Order by  F.MODEL_NAME,A.WORK_ORDER,A.SERIAL_NUMBER,H.PDLINE_NAME, J.PROCESS_NAME  ';
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
          Strgriddata.Cells[1,irow]:=fieldbyname('WORK_ORDER').AsString   ;
          Strgriddata.Cells[2,irow]:=fieldbyname('SERIAL_NUMBER').AsString   ;
          strgridData.Cells[3,irow]:=fieldbyname('PDLINE_NAME').asstring ;
          Strgriddata.Cells[4,irow]:=fieldbyname('PROCESS_NAME').AsString   ;
          Strgriddata.Cells[5,irow]:=fieldbyname('REC_TIME').AsString   ;
          strgridData.Cells[6,irow]:=fieldbyname('DEFECT_CODE').asstring ;
          Strgriddata.Cells[7,irow]:=fieldbyname('DEFECT_DESC').AsString   ;
          Strgriddata.Cells[8,irow]:=fieldbyname('REASON_CODE').AsString   ;
          strgridData.Cells[9,irow]:=fieldbyname('REASON_DESC').asstring ;
          Strgriddata.Cells[10,irow]:=fieldbyname('LOCATION').AsString   ;
          Strgriddata.Cells[11,irow]:=fieldbyname('PART_QTY').AsString   ;
          strgridData.Cells[12,irow]:=fieldbyname('REPAIR_REMARK').asstring ;
          next;
          Strgriddata.RowCount:=IROW+1;
      END;
     lblrecordcount.Caption:=inttostr(strgriddata.RowCount-1);
     ShowLineSeries ;
  end;
end;

procedure TFdetail.ShowLineSeries;
var sStartDate,sEndDate: string;
    sstarttime,sendtime:string;
    //ifirst_pass,ifirst_fail,intf,i:integer;
    strsql:string;
begin
   sStartDate:='';
   sEndDate:=''  ;
   sStartDate:=FormatDateTime('YYYYMMDD',datetimepickerstart.Date);
   sEndDate:=FormatDateTime('YYYYMMDD',datetimepickerEND.Date);

   sstarttime:=trim(sstartdate)+trim(combstarthour.Text);
   sendtime:=trim(senddate)+trim(combendhour.Text);

  {Strsql:='SELECT F.MODEL_NAME,A.WORK_ORDER,A.SERIAL_NUMBER,H.PDLINE_NAME, '
         +' J.PROCESS_NAME,K.DEFECT_CODE,K.DEFECT_DESC,A.REC_TIME, '
         +' L.REASON_CODE,L.REASON_DESC,D.LOCATION,C.REPAIR_REMARK,E.PART_QTY  '}
   Strsql:='SELECT  DISTINCT count( K.DEFECT_CODE ) AS DEFECT_QTY,K.DEFECT_CODE  '
         +' FROM SAJET.G_SN_DEFECT A,SAJET.G_SN_REPAIR B,SAJET.G_SN_REPAIR_REMARK C, '
         +' SAJET.G_SN_REPAIR_LOCATION D,SAJET.G_SN_REPAIR_POINT E, '
         +' SAJET.SYS_MODEL F, SAJET.SYS_PART G, SAJET.SYS_PDLINE H,  '
         +' SAJET.SYS_PROCESS J,SAJET.SYS_DEFECT K,SAJET.SYS_REASON L,  '
         +' SAJET.G_WO_BASE M,SAJET.SYS_FACTORY N     '
         +' WHERE A.RECID=B.RECID(+)  '
         +' AND A.RECID=C.RECID(+)  '
         +' AND A.RECID=D.RECID(+) '
         +' AND A.RECID=E.RECID(+) '
         +' AND A.work_order=M.WORK_ORDER  '
         +' AND M.MODEL_ID=G.PART_ID '
         +' AND G.MODEL_ID=F.MODEL_ID  '
         +' AND A.PDLINE_ID=H.PDLINE_ID  '
         +' AND A.PROCESS_ID=J.PROCESS_ID  '
         +' AND A.DEFECT_ID=K.DEFECT_ID  '
         +' AND B.REASON_ID=L.REASON_ID(+)  '
         +' AND M.FACTORY_ID=N.FACTORY_ID '
         +' AND N.FACTORY_ID=+'''+FCID+''' '
         + AddCondition( 'F.MODEL_NAME',ListModel)
         + AddCondition('H.pdline_NAME',Listpdline)
         + AddCondition('J.PROCESS_NAME',ListProcess)
         +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') >= :starttime   '
         +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') < :endtime  ' ;
  if Trim(Editwo.Text)<>'' then
      strsql:=strsql+' AND M.WORK_ORDER='''+Editwo.Text+''' ';
  if trim(editDEFECTCODE.Text)<>'' Then
     strsql:=strsql+' AND K.DEFECT_CODE=''' +Editdefectcode.Text + ''' ';
  if trim(editreasoncode.Text)<>'' then
     strsql:=strsql+' AND L.REASON_CODE='''+EDITREASONCODE.Text +''' ';
  if trim(editlocate.Text)<>'' then
     strsql:=strsql+' AND D.LOCATION='''+EDITLOCATE.Text +''' ';
  //Strsql:=strsql +' Order by  F.MODEL_NAME,A.WORK_ORDER,A.SERIAL_NUMBER,H.PDLINE_NAME, J.PROCESS_NAME  ';
  Strsql:=strsql +  'GROUP BY K.DEFECT_CODE ORDER BY DEFECT_QTY DESC ' ;
  with QryData do
  begin
    Close;
    commandtext:=strsql;
    params.ParamByName('starttime').AsString :=sstarttime;
    params.ParamByName('endtime').AsString :=sendtime;

    Open;
    if IsEmpty then
    begin
      Close ;
      Showmessage('No Data');
      exit;
    end;

    while not eof do
    begin
      //LineSeries1.Add(FieldByName('DEFECT_QTY').AsInteger,FieldByName('DEFECT_CODE').AsString);
      BarSeries1.Add(FieldByName('DEFECT_QTY').AsInteger,FieldByName('DEFECT_CODE').AsString);
      next;
    END;
    Close ;
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


end.

