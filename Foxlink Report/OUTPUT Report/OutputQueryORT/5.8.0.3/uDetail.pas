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
    DateTimePickerstart: TDateTimePicker;
    DateTimePickerend: TDateTimePicker;
    Label5: TLabel;
    Label7: TLabel;
    Lblrecordcount: TLabel;
    combStartHour: TComboBox;
    Combendhour: TComboBox;
    Label1: TLabel;
    EditPartNO: TEdit;
    ChkboxRework: TCheckBox;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnQueryClick(Sender: TObject);
    procedure strgridDataSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure strgridDataDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }

    //function AddCondition(sField: string; sList: TListBox): string;  
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
    procedure ShowAllData(sTitle,sFieldName,sFieldID:string;ListField:TListBox);
  end;

var
  fDetail: TfDetail;
  icol,irow:integer;
  FcID :string;
  DateRow:integer;
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
           ColWidths[0]:=100;
           cells[0,0]:='PART NO';
           colwidths[1]:=150;
           cells[1,0]:='Target Process Name';
           colwidths[2]:=150;
           CELLS[2,0]:='Target Process Input Qty';
           colwidths[3]:=150;
           CELLS[3,0]:='Compare Process Name';
           colwidths[4]:=150;
           CELLS[4,0]:='Compare Process Input Qty';

  end;
    lblrecordcount.Caption :='';
    DateTimePickerstart.Date:=now;
    DateTimePickerend.Date :=now+1 ;

    DateRow:=1;
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

  My_FileName := ExtractFilePath(Application.ExeName)+'OutputQueryORT.xlt';

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
    strsql,Strsqltarget,strsqlcompare:string;
    i:integer;
begin
   sStartDate:='';
   sEndDate:=''  ;
   sStartDate:=FormatDateTime('YYYYMMDD',datetimepickerstart.Date);
   sEndDate:=FormatDateTime('YYYYMMDD',datetimepickerEND.Date);

   sstarttime:=trim(sstartdate)+trim(combstarthour.Text);
   sendtime:=trim(senddate)+trim(combendhour.Text) ;
  for i:= 1 to strgridData.ROWCount do
    strgridData.ROWs[i].Clear;

  strsql:=' SELECT B.PART_NO,A.PART_ID,A.TARGET_PROCESS_ID,A.COMPARE_PROCESS_ID, '
         +' C.PROCESS_NAME AS TARGET_PROCESS_NAME,D.PROCESS_NAME AS COMPARE_PROCESS_NAME '
         +' FROM SAJET.SYS_PART_ORT A,SAJET.SYS_PART B,  '
         +' SAJET.SYS_PROCESS C,SAJET.SYS_PROCESS D '
         +' WHERE A.PART_ID=B.PART_ID AND A.ENABLED=''Y'' '
         +' AND A.TARGET_PROCESS_ID=C.PROCESS_ID  '
         +' AND A.COMPARE_PROCESS_ID=D.PROCESS_ID ';
  if trim(editpartno.Text)<>'' then
       strsql:=strsql+' AND B.PART_NO='''+EDITPARTNO.Text+''' ';
   strsql:=strsql+' ORDER BY B.PART_NO ASC ';

  with QryData do
  begin
    Close;
    commaNDtext:=strsql;
    Open;
    if IsEmpty then
    begin
      lblrecordcount.Caption :='TOTAL:0';
      Showmessage('No Data');
      exit;
    end;

   strgridData.RowCount:=10;
   irow:=0;
   icol:=0;

   while not eof do
    begin
        IROW:=IROW+1;
        strgridData.Cells[0,irow]:=QRYDATA.fieldbyname('part_no').asstring ;
        Strgriddata.Cells[1,irow]:=qrydata.fieldbyname('Target_process_name').AsString   ;
        Strgriddata.Cells[3,irow]:=fieldbyname('Compare_process_name').AsString;
        with QRYTEMP DO
        begin
            // get target process_name input_qty
            strsqltarget:='  select NVL(SUM(PASS_QTY+FAIL_QTY),0) AS Target_INPUT_QTY   '
                        +' from sajet.g_sn_count    '
                        +' where model_id=:part_id '
                        +' and  process_id=:process_id '
                        +' AND WORK_DATE||TRIM(TO_CHAR(WORK_TIME,''00''))>:starttime '
                        +' AND WORK_DATE||TRIM(TO_CHAR(WORK_TIME,''00''))<=:endtime ';
            if not chkboxrework.Checked  then
                 strsqltarget:=strsqltarget+' AND SUBSTR(work_order, 1,1) <> ''R''  '
                                           +' AND SUBSTR(WORK_ORDER,LENGTH(WORK_ORDER)-1,2) NOT IN (''-F'',''-O'',''-L'')  ';
            close;
            params.CreateParam(ftstring,'part_id',ptinput) ;
            params.CreateParam(ftstring,'process_id',ptinput) ;
            params.CreateParam(ftstring,'starttime',ptinput) ;
            params.CreateParam(ftstring,'endtime',ptinput) ;
            commandtext:=strsqltarget;
            params.ParamByName('part_id').AsString :=qrydata.fieldbyname('part_id').AsString;
            params.ParamByName('process_id').AsString :=qrydata.fieldbyname('target_process_id').AsString;
            params.ParamByName('starttime').AsString :=sstarttime;
            params.ParamByName('endtime').AsString := sendtime;
            OPEN;
            Strgriddata.Cells[2,irow]:=fieldbyname('target_input_qty').AsString;

            // get compare process_name input_qty
            Strsqlcompare:='  select NVL(SUM(PASS_QTY+FAIL_QTY),0) AS compare_INPUT_QTY   '
                        +' from sajet.g_sn_count    '
                        +' where model_id=:part_id '
                        +' and  process_id=:process_id '
                        +' AND WORK_DATE||TRIM(TO_CHAR(WORK_TIME,''00''))>:starttime '
                        +' AND WORK_DATE||TRIM(TO_CHAR(WORK_TIME,''00''))<=:endtime ';
            if not chkboxrework.Checked  then
                 Strsqlcompare:=Strsqlcompare+' AND SUBSTR(work_order, 1,1) <> ''R'' '
                                             +' AND SUBSTR(WORK_ORDER,LENGTH(WORK_ORDER)-1,2) NOT IN (''-F'',''-O'',''-L'')  ';
            close;
            params.CreateParam(ftstring,'part_id',ptinput) ;
            params.CreateParam(ftstring,'process_id',ptinput) ;
            params.CreateParam(ftstring,'starttime',ptinput) ;
            params.CreateParam(ftstring,'endtime',ptinput) ;
            commandtext:=strsqlcompare;
            params.ParamByName('part_id').AsString :=qrydata.fieldbyname('part_id').AsString;
            params.ParamByName('process_id').AsString :=qrydata.fieldbyname('compare_process_id').AsString;
            params.ParamByName('starttime').AsString :=sstarttime;
            params.ParamByName('endtime').AsString := sendtime;
            OPEN;
            Strgriddata.Cells[4,irow]:=fieldbyname('Compare_input_qty').AsString;
            close;
        end;

        next;
        Strgriddata.RowCount:=IROW+1;
        lblrecordcount.Caption :='TOTAL:'+ inttostr(irow);
    END;
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


procedure TfDetail.strgridDataSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
    DateRow:=Arow;
end;

procedure TfDetail.strgridDataDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
  var k:integer;
begin
  IF (ACol<0) then exit;
  K:=Strgriddata.RowCount;
  if (ARow=0) and (ACol<k) then exit ;
  if ARow=0 then exit;
  if  (Strgriddata.Cells[2,Arow]=Strgriddata.Cells[4,Arow])
     and (Strgriddata.Cells[2,Arow]='0') AND (Arow<>dateRow) then
  begin
    Strgriddata.Canvas.Brush.Color:=clyellow;
    Strgriddata.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, Strgriddata.Cells[ACol, ARow]);
  end 
  else if  Arow=dateRow then
  begin
      Strgriddata.Canvas.Brush.Color:=CLBLUE;
    Strgriddata.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, Strgriddata.Cells[ACol, ARow]);
  end
  else  if (Strgriddata.Cells[2,Arow] < Strgriddata.Cells[4,Arow])
    and (Strgriddata.Cells[2,Arow]='0') and (Arow<>dateRow) then
  begin
       Strgriddata.Canvas.Brush.Color:=ClRED;
       Strgriddata.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, Strgriddata.Cells[ACol, ARow]);
  end
  else begin
     Strgriddata.Canvas.Brush.Color:=clWINDOW;
     Strgriddata.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, Strgriddata.Cells[ACol, ARow]);
  end;
end;

end.

