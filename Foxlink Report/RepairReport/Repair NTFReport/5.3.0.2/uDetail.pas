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
    CombstartMinute: TComboBox;
    Combendhour: TComboBox;
    Combendminute: TComboBox;
    cmbFactory: TComboBox;
    LabWotype: TLabel;
    Listwotype: TListBox;
    Lblrecordcount: TLabel;
    RadioGroupFOR: TRadioGroup;
    RadioGroupBY: TRadioGroup;
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
           ColCount  :=5;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=80;
           cells[0,0]:='機種名稱';
           colwidths[1]:=70;
           cells[1,0]:='不良日期';
           colwidths[2]:=90;
           CELLS[2,0]:='測試站別';
           colwidths[3]:=150;
           CELLS[3,0]:='不良描述';
           colwidths[4]:=50;
           CELLS[4,0]:='NTF數量';

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

  My_FileName := ExtractFilePath(Application.ExeName)+'RepairNTFReport.xlt';

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

   sstarttime:=trim(sstartdate)+trim(combstarthour.Text)+trim(combstartminute.Text);
   sendtime:=trim(senddate)+trim(combendhour.Text)+trim(combendminute.Text);

  for i:= 1 to strgridData.ROWCount do
    strgridData.ROWs[i].Clear;

  if radiogroupby.ItemIndex =0 then // goup
  begin
          strsql:=' select model_name,defect_date,process_name,defect,count(*) as qty from  '
                 +' (SELECT a.model_name,to_char(C.rec_time,''YYYY/MM/DD'') as defect_date,  '
                 +' f.process_name,e.defect_code||''-''||defect_desc as defect  '
                 +' FROM sajet.SYS_MODEL A,sajet.SYS_PART B ,sajet.G_SN_DEFECT_first C,  '
                 +' sajet.sys_defect e,sajet.sys_process f,sajet.g_wo_base g  '
                 +' WHERE A.MODEL_ID=B.MODEL_ID  '
                 + AddCondition( 'A.MODEL_NAME',ListModel)
                 +' AND B.PART_ID=C.MODEL_ID  '
                 +' AND to_char(C.rec_time,''YYYYMMDDHH24MI'') >= :starttime   '
                 +' AND to_char(C.rec_time,''YYYYMMDDHH24MI'') < :endtime  '
                 +' and c.defect_id=e.defect_id   '
                 +' and c.process_id=f.process_id    '
                 +' and c.work_order=g.work_order '
                 +' and g.factory_id='''+fcid+''' '
                 + AddCondition('F.PROCESS_NAME',ListProcess)
                 + AddCondition01('g.work_order',ListWOTYPE);

         if radiogroupfor.ItemIndex =0 then  //for ntf
            strsql:=strsql +' and ntf_time is not null   ';

          strsql:=strsql +' ) group by model_name,defect_date,process_name,defect  ';
  end
  else   // for detail
  begin
          strsql:=' SELECT a.model_name,C.work_order,f.process_name,C.serial_number,  '
                 +' C.rec_time as defect_time,e.defect_code||''-''||defect_desc as defect  '
                 +' FROM sajet.SYS_MODEL A,sajet.SYS_PART B ,sajet.G_SN_DEFECT_first C,  '
                 +' sajet.sys_defect e,sajet.sys_process f,sajet.g_wo_base g  '
                 +' WHERE A.MODEL_ID=B.MODEL_ID  '
                 + AddCondition( 'A.MODEL_NAME',ListModel)
                 +' AND B.PART_ID=C.MODEL_ID  '
                 +' AND to_char(C.rec_time,''YYYYMMDDHH24MI'') >= :starttime   '
                 +' AND to_char(C.rec_time,''YYYYMMDDHH24MI'') < :endtime  '
                 +' and c.defect_id=e.defect_id   '
                 +' and c.process_id=f.process_id    '
                 +' and c.work_order=g.work_order '
                 +' and g.factory_id='''+fcid+''' '
                 + AddCondition('F.PROCESS_NAME',ListProcess)
                 + AddCondition01('g.work_order',ListWOTYPE);

         if radiogroupfor.ItemIndex =0 then  //for ntf
            strsql:=strsql +' and ntf_time is not null   ';

         strsql:=strsql + ' order by model_name,work_order,process_name,serial_number,defect_time ';
  end;

  with QryData do
  begin
    Close;
    commandtext:=strsql;
    params.ParamByName('starttime').AsString :=sstarttime;
    params.ParamByName('endtime').AsString :=sendtime;

    Open;
    if IsEmpty then
    begin
      lblrecordcount.Caption :='TOTAL:0';
      Showmessage('No Data');
      exit;
    end;
   if radiogroupby.ItemIndex = 0 then // for group
   begin
      if radiogroupfor.ItemIndex =0 then  //for ntf
      begin
         with strgridData do
         begin
           FixedCols:=0;
           FixedRows :=1;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColCount  :=5;
           ColWidths[0]:=80;
           cells[0,0]:='機種名稱';
           colwidths[1]:=70;
           cells[1,0]:='不良日期';
           colwidths[2]:=90;
           CELLS[2,0]:='測試站別';
           colwidths[3]:=200;
           CELLS[3,0]:='不良描述';
           colwidths[4]:=50;
           CELLS[4,0]:='NTF數量';
         end ;
      end
      else  // for fist fail
      begin
      with strgridData do
         begin
           FixedCols:=0;
           FixedRows :=1;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColCount  :=5;
           ColWidths[0]:=80;
           cells[0,0]:='機種名稱';
           colwidths[1]:=70;
           cells[1,0]:='不良日期';
           colwidths[2]:=90;
           CELLS[2,0]:='測試站別';
           colwidths[3]:=200;
           CELLS[3,0]:='不良描述';
           colwidths[4]:=50;
           CELLS[4,0]:='F_fail數量';
        end;
      end ;

      irow:=0;
      icol:=0;
      while not eof do
      begin
          IROW:=IROW+1;
          strgridData.Cells[0,irow]:=fieldbyname('MODEL_NAME').asstring ;
          Strgriddata.Cells[1,irow]:=fieldbyname('defect_date').AsString   ;
          Strgriddata.Cells[2,irow]:=fieldbyname('PROCESS_name').AsString   ;
          Strgriddata.Cells[3,irow]:=fieldbyname('DEFECT').AsString;
          Strgriddata.Cells[4,irow]:=fieldbyname('qty').AsString ;
          next;
          Strgriddata.RowCount:=IROW+1;
          lblrecordcount.Caption :='TOTAL:'+ inttostr(irow);
      END;

   end
   else // for detail
   begin
      if radiogroupfor.ItemIndex =0 then  //for ntf
      begin
         with strgridData do
         begin
           FixedCols:=0;
           FixedRows :=1;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='' ;
           ColCount  :=6;
           ColWidths[0]:=80;
           cells[0,0]:='機種名稱';
           colwidths[1]:=70;
           cells[1,0]:='工令';
           colwidths[2]:=90;
           CELLS[2,0]:='測試站別';
           colwidths[3]:=80;
           CELLS[3,0]:='SN';
           colwidths[4]:=130;
           CELLS[4,0]:='不良時間';
           colwidths[5]:=200;
           CELLS[5,0]:='NTF不良描述';
         end ;
      end
      else  // for fist fail
      begin
      with strgridData do
         begin
           FixedCols:=0;
           FixedRows :=1;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColCount  :=6;
           ColWidths[0]:=80;
           cells[0,0]:='機種名稱';
           colwidths[1]:=70;
           cells[1,0]:='工令';
           colwidths[2]:=90;
           CELLS[2,0]:='測試站別';
           colwidths[3]:=80;
           CELLS[3,0]:='SN';
           colwidths[4]:=130;
           CELLS[4,0]:='不良時間';
           colwidths[5]:=200;
           CELLS[5,0]:='F_fail不良描述';
        end;
      end ;

      irow:=0;
      icol:=0;
      while not eof do
      begin
         IROW:=IROW+1;
         strgridData.Cells[0,irow]:=fieldbyname('MODEL_NAME').asstring ;
         Strgriddata.Cells[1,irow]:=fieldbyname('work_order').AsString   ;
         Strgriddata.Cells[2,irow]:=fieldbyname('PROCESS_name').AsString   ;
         Strgriddata.Cells[3,irow]:=fieldbyname('serial_number').AsString;
         Strgriddata.Cells[4,irow]:=fieldbyname('defect_time').AsString ;
         Strgriddata.Cells[5,irow]:=fieldbyname('defect').AsString ;
         next;
         Strgriddata.RowCount:=IROW+1;
         lblrecordcount.Caption :='TOTAL:'+ inttostr(irow);
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

