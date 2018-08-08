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
    sbtnStyle1: TSpeedButton;
    SaveDialog1: TSaveDialog;
    Label6: TLabel;
    Label10: TLabel;
    combMonth: TComboBox;
    strgridData: TStringGrid;
    Label1: TLabel;
    combYear: TComboBox;
    ListModel: TListBox;
    Image3: TImage;
    sbtnQuery: TSpeedButton;
    combHour: TComboBox;
    Label2: TLabel;
    CombMinute: TComboBox;
    lblProcess: TLabel;
    ListProcess: TListBox;
    cmbFactory: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnQueryClick(Sender: TObject);
    procedure sbtnStyle1Click(Sender: TObject);
    procedure Label10Click(Sender: TObject);
    procedure lblProcessClick(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    tsModel:TStringList;
    function AddCondition(sField: string; sList: TListBox): string;
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
    procedure ShowAllData(sTitle,sFieldName,sFieldID:string;ListField:TListBox);
  end;

var
  fDetail: TfDetail;
  FcID :string;

implementation

uses uCommData, uData,uSelect;
{$R *.DFM}

procedure TfDetail.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var i, j,iStartRow,iDiv,iMod: integer;
    vRange1:Variant;
begin
  MsExcel.Worksheets['Sheet1'].Range['A3']:= 'Month:'+combMonth.Text;
  MsExcel.Worksheets['Sheet1'].Range['E4']:= 'Year:'+combYear.Text;

  iStartRow:= 5;
  for i := 0 to strgridData.RowCount - 1 do
  begin
    if (i=7) or (i=11) then continue;
    for j := 2 to strgridData.ColCount - 2 do
    begin
      if (i = 0) and (j>=3) and (strgridData.ColCount>5) and (j<>strgridData.ColCount-2) then
      begin
        MsExcel.Worksheets['sheet1'].Columns[j+1].Copy;
        MsExcel.Worksheets['sheet1'].Columns[j+1].Insert;
      end;
      MsExcel.Worksheets['Sheet1'].Cells[i+iStartRow,j+1].value := strgridData.Cells[j,i];
    end;
  end;

  //礶絬
 { if strgridData.ColCount>=24 then
  begin
    iDiv:=strgridData.ColCount div 26;
    iMod:=strgridData.ColCount mod 26;
    vRange1 := MsExcel.Worksheets['sheet1'].Range['C'+IntToStr(iStartRow)+':'+chr(65+iDiv-1)+chr(65+iMod-1)+IntToStr(strgridData.RowCount+iStartRow)];
  end else
    vRange1 := MsExcel.Worksheets['sheet1'].Range['C'+IntToStr(iStartRow)+':'+chr(65+strgridData.ColCount-1)+IntToStr(strgridData.RowCount+iStartRow)];

  vRange1.Borders.LineStyle:=$00000001;  }
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
  sYear:=FormatDateTime('YYYY',now);
  combYear.Clear;
  for i:= StrToInt(sYear)-5 to StrToInt(sYear) do
    combYear.Items.Add(inttostr(i));
  combYear.ItemIndex:= combYear.Items.IndexOf(sYear);

  combMonth.Clear;
  for i:= 1 to 12 do
    combMonth.Items.Add(FormatFloat('00',i));
  combMonth.ItemIndex:= combMonth.Items.IndexOf(FormatDateTime('mm',now));


  with strgridData do
  begin
    cells[0,0]:='DEFECT';
    cells[1,0]:='Production Model';
    cells[1,1]:='Total Output Qty';
    cells[1,2]:='Total Sample Qty';
    cells[1,3]:='Reject Sample Qty';
    cells[1,4]:='Lots Inspected';
    cells[1,5]:='Lots Accepted';
    cells[1,6]:='Lots Rejected';
    cells[1,7]:='Lots Reject Rate(%)';
    cells[1,8]:='Total Reject Lots Qty';
    cells[1,9]:='No. Of Units Rejected';

    cells[0,10]:='Reject';
    cells[1,10]:='No. Of Units';
    cells[1,11]:='DPPM';
    cells[1,12]:='Actual Output Qty';
    cells[1,13]:='Remark';
  end;

  tsModel:=TStringList.Create;

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

  My_FileName := ExtractFilePath(Application.ExeName)+'FQCMonthlyReport.xlt';

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
  tsModel.Free;
  Action := caFree;
end;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
var sSQL,sStartDate: string;
    i,j,iIndex,iTotal:integer;
begin
  for i:= 2 to strgridData.ColCount do
    strgridData.Cols[i].Clear;
  tsModel.Clear;
  strgridData.ColCount:=3;
  sStartDate:=combYear.Text+combMonth.Text;
    //匡拒
    sSQL:=' select a.*,nvl(c.model_name,''N/A'') model_name '
       +' from sajet.g_qc_lot a '
       +'    ,sajet.sys_part b,sajet.sys_model c,sajet.sys_process d,sajet.g_wo_base e '
       +' where to_char(a.end_time - '+combHour.Text+'/24 - '+combminute.Text+'/24/50,''yyyymm'') = '''+sStartDate+''' '
       +' and a.qc_result <> ''N/A'' '
       +' and a.model_id = b.part_id '
       +' and b.model_id = c.model_id(+) '
       +' and a.process_id=d.process_id '
       +' and a.work_order=e.work_order '
       +' and e.factory_id='''+fcid+''' '
       +  AddCondition('c.model_name',listModel)
       +  AddCondition('d.process_name',listProcess)
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
      iIndex:= tsModel.IndexOf(FieldbyName('Model_Name').asString);
      if iIndex=-1 then
      begin
        tsModel.Add(FieldbyName('Model_Name').asString);
        iIndex:=tsModel.Count-1;
      end;  

      iIndex:=iIndex+2;
      strgridData.Cells[iIndex,0]:=FieldbyName('Model_Name').asString;
      strgridData.Cells[iIndex,1]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,1],0)+FieldbyName('Lot_Size').asinteger);
      strgridData.Cells[iIndex,2]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,2],0)+FieldbyName('sampling_size').asinteger);
      strgridData.Cells[iIndex,4]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,4],0)+1);         //┾喷у
      if FieldbyName('qc_result').asstring='1' then
      begin
        strgridData.Cells[iIndex,3]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,3],0)+FieldbyName('sampling_size').asinteger); //у癶┾喷计
        strgridData.Cells[iIndex,5]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,5],0));
        strgridData.Cells[iIndex,6]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,6],0)+1);
        strgridData.Cells[iIndex,8]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,8],0)+FieldbyName('Lot_Size').asinteger);  //у癶计
        strgridData.Cells[iIndex,9]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,9],0)+FieldbyName('Fail_Qty').asinteger);  //у癶ぃ▆计
        strgridData.Cells[iIndex,12]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,12],0));
        strgridData.Cells[iIndex,13]:=  strgridData.Cells[iIndex,13]+ FieldbyName('lot_memo').AsString +';';    //у癶磞砃
      end else
      begin
        strgridData.Cells[iIndex,3]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,3],0));     
        strgridData.Cells[iIndex,5]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,5],0)+1);       //すΜlot
        strgridData.Cells[iIndex,6]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,6],0));         //у癶lot
        strgridData.Cells[iIndex,8]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,8],0));
        strgridData.Cells[iIndex,9]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,9],0));
        strgridData.Cells[iIndex,12]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,12],0)+FieldbyName('Lot_Size').asinteger);  //pass lot_size
        strgridData.Cells[iIndex,13]:=  strgridData.Cells[iIndex,13];
      end;
      strgridData.Cells[iIndex,7]:= FormatFloat('0.00',StrToInt(strgridData.Cells[iIndex,6])/StrToInt(strgridData.Cells[iIndex,4])*100)+'%';  //у癶瞯
      strgridData.Cells[iIndex,10]:=IntToStr(StrToIntDef(strgridData.Cells[iIndex,10],0)+FieldbyName('Fail_Qty').asinteger);              //totalぃ▆计
      strgridData.Cells[iIndex,11]:=FormatFloat('0',(StrToInt(strgridData.Cells[iIndex,10])/StrToInt(strgridData.Cells[iIndex,2]))*1000000); //DPPM
      Next;
    end;
  end;
  strgridData.ColCount:= tsModel.Count+2;
  
  //Total
  strgridData.Cells[strgridData.ColCount,0]:='TTL';
  for i:=1 to strgridData.RowCount-2 do
  begin
    iTotal:=0;
    if i=7 then
      strgridData.Cells[j,i]:= FormatFloat('0.00',StrToInt(strgridData.Cells[j,6])/StrToInt(strgridData.Cells[j,4])*100)+'%' //у癶瞯
    else
    begin
      for j:=2 to strgridData.ColCount-1 do
        iTotal:=iTotal+StrToIntDef(strgridData.Cells[j,i],0);
      strgridData.Cells[strgridData.ColCount,i]:=inttostr(iTotal);
    end;  
  end;
  strgridData.ColCount:=strgridData.ColCount+1;
  strgridData.Cells[strgridData.ColCount-1,11]:=FormatFloat('0',(StrToInt(strgridData.Cells[strgridData.ColCount-1,10])/StrToInt(strgridData.Cells[strgridData.ColCount-1,2]))*1000000); //Total DPPM
end;

procedure TfDetail.ShowAllData(sTitle,sFieldName,sFieldID:string;ListField:TListBox);
Var I,iIndex : Integer;
   tsFieldName,tsFieldID:TStringList;
begin
//  fSelect:=TfSelect.create(Self);
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

procedure TfDetail.sbtnStyle1Click(Sender: TObject);
begin
  fData:= TfData.Create(Self);
  with fData do
  begin
    ImageTitle1.Picture := fDetail.ImageTitle.Picture;
    QryData1.RemoteServer := fDetail.QryData.RemoteServer;
    QryData1.ProviderName :=fDetail.QryData.ProviderName;
    combYear1.Text:= fDetail.combYear.Text;
    combMonth1.Text:= fDetail.combMonth.Text;
    sStartHour:= fDetail.combHour.Text;
    //editPart.Text:=fDetail.editPart.Text;
    sbtnRefreshClick(self);
    ShowModal;
    Free;
  end;
end;

procedure TfDetail.Label10Click(Sender: TObject);
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

procedure TfDetail.lblProcessClick(Sender: TObject);
begin
  with fDetail.qryTemp do
  begin
    close;
    Params.Clear;
    CommandText := 'select process_name from sajet.sys_process where enabled=''Y'' ORDER BY PROCESS_NAME';
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

