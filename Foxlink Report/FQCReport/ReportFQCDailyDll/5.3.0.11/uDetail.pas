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
    Label3: TLabel;
    Label4: TLabel;
    SaveDialog1: TSaveDialog;
    Label6: TLabel;
    combMonth: TComboBox;
    strgridData: TStringGrid;
    Label1: TLabel;
    combYear: TComboBox;
    Image3: TImage;
    sbtnQuery: TSpeedButton;
    combHour: TComboBox;
    Label2: TLabel;
    CombMinute: TComboBox;
    ListModel: TListBox;
    LabModel: TLabel;
    LblProcess: TLabel;
    ListProcess: TListBox;
    cmbFactory: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnQueryClick(Sender: TObject);
    procedure LabModelClick(Sender: TObject);
    procedure LblProcessClick(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function AddCondition(sField: string; sList: TListBox): string;
    procedure GetReportName;
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
    procedure ShowAllData(sTitle,sFieldName,sFieldID:string;ListField:TListBox);
  end;

var
  fDetail: TfDetail;
  FcID :string;

implementation

uses uCommData, uSelect;
{$R *.DFM}

procedure TfDetail.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var i, j,iStartRow,iDiv,iMod: integer;
    vRange1:Variant;
begin
  MsExcel.Worksheets['Sheet1'].Range['B3']:= listmodel.Items[0];
  MsExcel.Worksheets['Sheet1'].Range['B4']:= combMonth.Text;

  iStartRow:= 8;
  for i := 0 to strgridData.RowCount - 1 do
  begin
    if (i=8) or (i=12) then continue;
    for j := 0 to strgridData.ColCount - 2 do
    begin
      MsExcel.Worksheets['Sheet1'].Cells[i+iStartRow,j+1].value := strgridData.Cells[j,i];
      //ㄖ纗(WEEK)
      if (i=0) and (j>=2) and (strgridData.Cells[j,i]='') then
      begin
        if j< 26 then
          MsExcel.Worksheets['sheet1'].Range[chr(65+j-1)+IntToStr(i+iStartRow),chr(65+j)+IntToStr(i+iStartRow)].MergeCells:=True;
        if (j= 26) then
          MsExcel.Worksheets['sheet1'].Range['Z'+IntToStr(i+iStartRow),'AA'+IntToStr(i+iStartRow)].MergeCells:=True;
        if (j> 26) then
        begin
          iDiv:=j div 26;
          iMod:=j mod 26;
          MsExcel.Worksheets['sheet1'].Range[chr(65+iDiv-1)+chr(65+iMod-1)+IntToStr(i+iStartRow),chr(65+iDiv-1)+chr(65+iMod)+IntToStr(i+iStartRow)].MergeCells:=True;
        end;
      end; 
    end;
  end;

  //礶絬
{  iDiv:=strgridData.ColCount div 26;
  iMod:=strgridData.ColCount mod 26;
  //vRange1 := MsExcel.Worksheets['sheet1'].Range['A'+IntToStr(iStartRow)+':'+chr(65+iDiv-1)+chr(65+iMod-1)+IntToStr(strgridData.RowCount-1+iStartRow)];
  vRange1 := MsExcel.Worksheets['sheet1'].Range['A'+IntToStr(iStartRow)+':'+chr(65+iDiv-1)+chr(65+iMod-1)+IntToStr(iStartRow)];
  vRange1.Borders.LineStyle:=$00000001; }
end;

procedure TfDetail.GetReportName;
begin
 { LabReportName1.Caption := '';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RP_ID', ptInput);
    CommandText := 'Select RP_NAME ' +
      'From SAJET.SYS_REPORT_NAME ' +
      'Where RP_ID = :RP_ID ';
    Params.ParamByName('RP_ID').AsString := RpID;
    Open;
    if RecordCount > 0 then
    begin
      LabReportName1.Caption := Fieldbyname('RP_NAME').AsString;
    end;
    Close;
  end;   }
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

procedure TfDetail.FormShow(Sender: TObject);
var sYear:string;
    i:integer;
begin
  //GetReportName;

  sYear:=FormatDateTime('YYYY',now);
  combYear.Clear;
  for i:= StrToInt(sYear)-5 to StrToInt(sYear) do
    combYear.Items.Add(inttostr(i));
  combYear.ItemIndex:= combYear.Items.IndexOf(sYear);
  combMonth.ItemIndex:= combMonth.Items.IndexOf(FormatDateTime('MM',now));

  with strgridData do
  begin
    cells[0,1]:='DEFECT';
    cells[1,1]:='Production Date';
    cells[1,2]:='Total Output Qty';
    cells[1,3]:='Total Sample Qty';
    cells[1,4]:='Reject sample Qty';
    cells[1,5]:='Lots Inspected';
    cells[1,6]:='Lots Accepted';
    cells[1,7]:='Lots Rejected';
    cells[1,8]:='Lots Reject Rate(%)';
    cells[1,9]:='Total Reject Lots Qty';
    cells[1,10]:='No. Of Units Rejected';

    cells[0,11]:='Reject';
    cells[1,11]:='No. Of Units';
    cells[1,12]:='DPPM';
    cells[1,13]:='Actual Output Qty';
    cells[1,14]:='Remark' ;
  end;

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

  My_FileName := ExtractFilePath(Application.ExeName)+'FQCDailyReport.xlt';

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
var sSQL,sDate,sStartDate,sEndDate,sPerWeek: string;
    i,j,iIndex,iTotal,iNo:integer;
begin

  if  cmbfactory.Items.Count=0 then
  begin
      Showmessage('NoT Define FACTORY_CODE ');
      exit;
    end;

  for i:= 2 to strgridData.ColCount do
    strgridData.Cols[i].Clear;

  sDate:=combYear.Text+combMonth.Text+'01';
  //セるΤ碭ぱ
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select to_char(last_day(to_date('''+sDate+''',''yyyymmdd'')),''dd'') sday from dual';
    Open;
    iNo:=StrToInt(FieldByName('sday').asstring);
  end;
  //iNo:=31;
  strgridData.ColCount:= iNo+2;

  sPerWeek:='';
  for i:= 1 to iNo do
  begin
    strgridData.Cells[i+1,1]:=combYear.Text+'/'+combMonth.Text+'/'+formatFloat('00',i);
    sDate:=combYear.Text+combMonth.Text+formatFloat('00',i);
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select to_char(to_date('''+sDate+''',''yyyymmdd''),''iw'') sWEEK from dual';
      Open;
      if sPerWeek<>FieldByName('sWEEK').asstring then
        strgridData.Cells[i+1,0]:=FieldByName('sWEEK').asstring+' Week';
      sPerWeek:=FieldByName('sWEEK').asstring;
    end;

  end;

  sStartDate:=combYear.Text+combMonth.Text+'01';
  if combMonth.Text='12' then
    sEndDate:=IntToStr(StrToInt(combYear.Text)+1)+'0101'
  else
    sEndDate:=combYear.Text+combMonth.Items.Strings[combMonth.itemindex+1]+'01';
  {
  sSQL:='select a.*,to_char(a.end_time - '+combHour.Text+'/24 - '+combMinute.Text+'/24/60,''dd'') sdate '
       +'from sajet.g_qc_lot a ';
  sSQL:=sSQL+',sajet.sys_part b,sajet.sys_model c,sajet.sys_process d ';
  sSQL:=sSQL
       +'where to_char(a.end_time - '+combHour.Text+'/24 - '+combMinute.Text+'/24/60,''yyyymmdd'')>= '''+sStartDate+''' '
       +'and   to_char(a.end_time - '+combHour.Text+'/24 - '+combMinute.Text+'/24/60,''yyyymmdd'')< '''+sEndDate+''' '
       +'and a.qc_result <> ''N/A'' ';
  sSQL:=sSQL+' and a.model_id = b.part_id '
              +' and b.model_id = c.model_id(+) '
              +' and a.process_id=d.process_id  '
              +  AddCondition('c.model_name',listModel)
              +  AddCondition('d.process_name',listprocess)
              +' order by c.model_name ';
  }
  sSQL:='select a.*,to_char(a.end_time - '+combHour.Text+'/24 - '+combMinute.Text+'/24/60,''dd'') sdate '
       +'from sajet.g_qc_lot a ';
  sSQL:=sSQL+',sajet.sys_part b,sajet.sys_model c,sajet.sys_process d,sajet.g_wo_base e ';
  sSQL:=sSQL
       +'where to_char(a.end_time - '+combHour.Text+'/24 - '+combMinute.Text+'/24/60,''yyyymmdd'')>= '''+sStartDate+''' '
       +'and   to_char(a.end_time - '+combHour.Text+'/24 - '+combMinute.Text+'/24/60,''yyyymmdd'')< '''+sEndDate+''' '
       +'and a.qc_result <> ''N/A'' '
       +'and a.work_order=e.work_order and e.factory_id='''+fcid+''' ' ;
  sSQL:=sSQL+' and a.model_id = b.part_id '
              +' and b.model_id = c.model_id(+) '
              +' and a.process_id=d.process_id  '
              +  AddCondition('c.model_name',listModel)
              +  AddCondition('d.process_name',listprocess)
              +' order by c.model_name ';
  with QryData do
  begin
    Close;
    Params.Clear;
    CommandText := sSQL;
    Open;
    if IsEmpty then
    begin
      Showmessage('No Data');
      exit;
    end;


   while not eof do
    begin
      //iIndex:=strtoint(FormatDateTime('dd',FieldbyName('sDate').asDateTime))+1;
      iIndex:=strtoint(FieldbyName('sDate').asString)+1;
      strgridData.Cells[iIndex,2]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,2],0)+FieldbyName('Lot_Size').asinteger);
      strgridData.Cells[iIndex,3]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,3],0)+FieldbyName('sampling_size').asinteger);
      strgridData.Cells[iIndex,5]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,5],0)+1);         //┾喷у
      if FieldbyName('qc_result').asstring='1' then
      begin
        strgridData.Cells[iIndex,4]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,4],0)+FieldbyName('sampling_size').asinteger);
        strgridData.Cells[iIndex,6]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,6],0));
        strgridData.Cells[iIndex,7]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,7],0)+1);
        strgridData.Cells[iIndex,9]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,9],0)+FieldbyName('Lot_Size').asinteger);  //у癶计
        strgridData.Cells[iIndex,10]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,10],0)+FieldbyName('Fail_Qty').asinteger);  //у癶ぃ▆计
        strgridData.Cells[iIndex,13]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,13],0));
        strgridData.Cells[iIndex,14]:=strgridData.Cells[iIndex,14]+FieldbyName('lot_memo').AsString+';' ;   //у癶
      end else
      begin
        strgridData.Cells[iIndex,4]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,4],0));    //у癶┾喷计
        strgridData.Cells[iIndex,6]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,6],0)+1);       //すΜlot
        strgridData.Cells[iIndex,7]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,7],0));         //у癶lot
        strgridData.Cells[iIndex,9]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,9],0));
        strgridData.Cells[iIndex,10]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,10],0));
        strgridData.Cells[iIndex,13]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,13],0)+FieldbyName('Lot_Size').asinteger);  //PASS LOT_SIZE
        strgridData.Cells[iIndex,14]:=strgridData.Cells[iIndex,14];
      end;
      strgridData.Cells[iIndex,8]:= FormatFloat('0.00',StrToInt(strgridData.Cells[iIndex,7])/StrToInt(strgridData.Cells[iIndex,5])*100)+'%';  //у癶瞯
      strgridData.Cells[iIndex,11]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,11],0)+FieldbyName('Fail_Qty').asinteger);              //totalぃ▆计
      strgridData.Cells[iIndex,12]:=FormatFloat('0',(StrToInt(strgridData.Cells[iIndex,10])/StrToInt(strgridData.Cells[iIndex,3]))*1000000); //DPPM
      Next;
    end;
  end;

  //Total
  strgridData.Cells[strgridData.ColCount,0]:='TTL';
  for i:=2 to strgridData.RowCount-2 do
  begin
    iTotal:=0;
    if i=8 then
      strgridData.Cells[j,i]:= FormatFloat('0.00',StrToInt(strgridData.Cells[j,7])/StrToInt(strgridData.Cells[j,5])*100)+'%' //у癶瞯
    else
    begin
      for j:=2 to strgridData.ColCount-1 do
        iTotal:=iTotal+StrToIntDef(strgridData.Cells[j,i],0);
      strgridData.Cells[strgridData.ColCount,i]:=inttostr(iTotal);
    end;  
  end;
  strgridData.ColCount:=strgridData.ColCount+1;
  strgridData.Cells[strgridData.ColCount-1,12]:=FormatFloat('0',(StrToInt(strgridData.Cells[strgridData.ColCount-1,11])/StrToInt(strgridData.Cells[strgridData.ColCount-1,3]))*1000000); //Total DPPM
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

end.

