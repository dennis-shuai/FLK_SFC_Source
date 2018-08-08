unit uNoInputReport;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls, Grids, DBGrids, ComCtrls, Db,
  DBClient, MConnect, ObjBrkr, SConnect,Variants, comobj, GradPanel,
  OleCtnrs,Excel97; 

type
  TfNoInputReport = class(TForm)
    Panel1: TPanel;
    SpeedButton5: TSpeedButton;
    Image2: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    QryTemp2: TClientDataSet;
    PageControl1: TPageControl;
    TabData: TTabSheet;
    GradPanel13: TGradPanel;
    Label18: TLabel;
    GPRecords: TGradPanel;
    GradPanel14: TGradPanel;
    Image3: TImage;
    Image7: TImage;
    sbtnSave: TSpeedButton;
    Image8: TImage;
    sbtnPrint: TSpeedButton;
    ImageTitle: TImage;
    Label3: TLabel;
    Label4: TLabel;
    sbtnClose: TSpeedButton;
    Image1: TImage;
    DataSource1: TDataSource;
    SaveDialog1: TSaveDialog;
    LabReportName1: TLabel;
    Image9: TImage;
    cmbFactory: TComboBox;
    Label9: TLabel;
    editWO1: TEdit;
    Label6: TLabel;
    DTStart: TDateTimePicker;
    Label7: TLabel;
    DTEnd: TDateTimePicker;
    Label8: TLabel;
    combLine: TComboBox;
    StringGrid1: TStringGrid;
    panelGressBar: TPanel;
    Label5: TLabel;
    ProgressBar1: TProgressBar;
    cmbWSStart: TComboBox;
    cmbWSEnd: TComboBox;
    sbtnQuery: TSpeedButton;
    sbtnWo: TSpeedButton;
    Label1: TLabel;
    editPart: TEdit;
    sbtnPart: TSpeedButton;
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnQueryClick(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnWoClick(Sender: TObject);
    procedure sbtnPartClick(Sender: TObject);
  private
    { Private declarations }
    saEnglist            :array[0..26] of string ;       //儲存英文字母
  public
    { Public declarations }
    UpdateUserID : String;
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);
    Procedure GetFactoryData;
    procedure proSetStringData;
    procedure proQueryData(sStartDate,sStartHour,sEndDate,sEndHour,sParFactory_ID,sParPdline_ID,sParWO,sPart : String);
  end;

var
  fNoInputReport: TfNoInputReport;
  FcID : String;
  slFactoryID, StrLstPdLine, slTestProgramID, StrLstProcess : TStringList;
  sQueryCon : String;
  
implementation

{$R *.DFM}

uses uCommData;

Procedure TfNoInputReport.GetFactoryData;
var UserFcID: string;
begin
  slFactoryID := TStringList.Create;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EMP_ID', ptInput);
    CommandText := 'Select NVL(FACTORY_ID,0) FACTORY_ID ' +
       'From SAJET.SYS_EMP ' +
       'Where EMP_ID = :EMP_ID '
       + 'and Rownum = 1 ';
    Params.ParamByName('EMP_ID').AsString := UpdateUserID;
    Open;
    if RecordCount = 0 then
    begin
      Close;
      MessageDlg('Account Error !!', mtError, [mbOK], 0);
      Exit;
    end;
    UserFcID := Fieldbyname('FACTORY_ID').AsString;
    Close;
  end;
  cmbFactory.Items.Clear;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
       'From SAJET.SYS_FACTORY ' +
       'Where ENABLED = ''Y'' ';
    Open;
    while not Eof do
    begin
      cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString);
      slFactoryID.Add(Fieldbyname('FACTORY_ID').AsString);
      if Fieldbyname('FACTORY_ID').AsString = UserFcID then
        cmbFactory.ItemIndex := cmbFactory.Items.Count - 1;
      Next;
    end;
    Close;
  end;
  cmbFactory.Enabled := (UserFcID = '0');
  if UserFcID = '0' then
    cmbFactory.ItemIndex := 0;
  cmbFactoryChange(self);
end;

procedure TfNoInputReport.SaveExcel(MsExcel,MsExcelWorkBook:Variant);
var i,j,iFirstRow:integer;
    vRange1: variant;
    iTemp1,iTemp2 :integer;
begin
  iFirstRow:=2; //資料起始row
  MsExcel.Worksheets['Data'].select;

  iTemp1 := 0;
  iTemp2 := 0;

  for i:= 0 to StringGrid1.RowCount - 1 do
  begin
      iTemp1 := 0;
      iTemp2 := 0;
      for j:= 0 to StringGrid1.ColCount - 1  do
      begin
          if iTemp2 > 25 then
          begin
              iTemp2 := 1;
              iTemp1 := iTemp1 + 1
          end
          else
          begin
              iTemp2 := iTemp2 + 1;
          end;

          MsExcel.Worksheets['Data'].Range[saEnglist[iTemp1] + saEnglist[iTemp2] + IntToStr(i+iFirstRow)].Value := trim(StringGrid1.Cells[j,i]) ;
          //showmessage(saEnglist[iTemp1] + saEnglist[iTemp2] + IntToStr(i+iFirstRow));
      end;
  end;
  vRange1 := MsExcel.Worksheets['Data'].Range['A'+IntToStr(1)+':'+saEnglist[iTemp1] + saEnglist[iTemp2]+ IntToStr(StringGrid1.RowCount+iFirstRow-1)];
  vRange1.Borders.LineStyle:=$00000001;
  //vRange1.Columns.AutoFit; //最適欄寬

  //MsExcel.Run('RUNModule');

end;

procedure TfNoInputReport.sbtnCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TfNoInputReport.FormShow(Sender: TObject);
var i:integer;
begin
  DTStart.DateTime := now;
  DTEnd.DateTime := now;
  cmbWSStart.ItemIndex := 0;
  cmbWSEnd.ItemIndex := cmbWSEnd.Items.Count - 1;

  GetFactoryData;

  //sbtnQueryClick(Self);
end;

procedure TfNoInputReport.sbtnSaveClick(Sender: TObject);
var
  sFileName,My_FileName : String;
  MsExcel, MsExcelWorkBook : Variant;
  i : Integer;
begin
  //if (StringGrid1.Cells[0,1] = '') Then Exit;

  My_FileName:= ExtractFilePath(Application.EXEName)+'NoInputReport.xlt';

  if not FileExists(My_FileName) then
  begin
     showmessage('Error!-The Excel File '+My_FileName+' can''t be found.');
     exit;
  end;


  IF Sender=sbtnSave THEN
  BEGIN
    SaveDialog1.InitialDir := ExtractFilePath('C:\');
    SaveDialog1.DefaultExt := 'xls';
    SaveDialog1.Filter := 'All Files(*.xls)|*.xls';

    if SaveDialog1.Execute then
    begin
      try
        sFileName := SaveDialog1.FileName;
        MsExcel := CreateOleObject('Excel.Application');
        MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);
        MsExcel.Worksheets['Data'].select;
        SaveExcel(MsExcel,MsExcelWorkBook);
        MsExcelWorkBook.SaveAs(sFileName);
        showmessage('Save Excel OK!!');
      Except
        ShowMessage('Could not start Microsoft Excel.');
      end;
      MsExcel.Application.Quit;
      MsExcel:=Null;
    end else
      MessageDlg('You did not Save Any Data',mtWarning,[mbok],0);
  END;

  IF Sender=sbtnPrint THEN
  BEGIN
    try
      MsExcel := CreateOleObject('Excel.Application');
      MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);
      MsExcel.Worksheets['Data'].select;
      SaveExcel(MsExcel,MsExcelWorkBook);
      WindowState:=wsMinimized;
      MsExcel.Visible:=TRUE;
      MsExcel.Worksheets['Data'].select;
      MsExcel.WorkSheets['Data'].PrintPreview;
      WindowState:=wsMaximized;
    Except
      ShowMessage('Could not start Microsoft Excel.');
    end;
    MsExcelWorkBook.Close(False);
    MsExcel.Application.Quit;
    MsExcel:=Null;
  END;

 { Try
    If FileExists(My_FileName) Then Deletefile(My_FileName);
  except end;  }
end;

procedure TfNoInputReport.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  slFactoryID.Free;
  Action := caFree;
end;

procedure TfNoInputReport.sbtnQueryClick(Sender: TObject);
var
  sStartDate,sStartHour,sEndDate,sEndHour,sFactory_ID,sPdline_ID,sWO,sPart : String;
begin

    sStartDate := trim(FormatDateTime('yyyymmdd',DTStart.date));
    sStartHour := trim(cmbWSStart.text);
    sEndDate   := trim(FormatDateTime('yyyymmdd',DTEnd.date));
    sEndHour   := trim(cmbWSEnd.text);
    sFactory_ID:= trim(cmbFactory.text);
    sPdline_ID := trim(combLine.text);
    sWO        := trim(editWO1.text);
    sPart      := trim(editPart.text);

    proQueryData(sStartDate,sStartHour,sEndDate,sEndHour,sFactory_ID,sPdline_ID,sWO,sPart);

end;

procedure TfNoInputReport.cmbFactoryChange(Sender: TObject);
begin
  FcID := slFactoryId[cmbFactory.ItemIndex];
  with QryTemp do
  begin
    Params.Clear;
    Params.CreateParam(ftString, 'fcid', ptInput);
    CommandText := 'select pdline_name from sajet.sys_pdline '
      + 'where FACTORY_ID = :fcid and enabled = ''Y'' '
      + 'order by pdline_name ';
    Params.ParamByName('fcid').AsString := FcID;
    Open;
    combLine.Items.Clear;
    combLine.Items.Add('');
    while not Eof do
    begin
      if StrLstPdLine.Count <> 0 then
      begin
        if StrLstPdLine.IndexOf(FieldByName('Pdline_Name').AsString) <> -1 then
          combLine.Items.Add(FieldByName('Pdline_Name').AsString);
      end
      else
        combLine.Items.Add(FieldByName('Pdline_Name').AsString);
      Next;
    end;
    Close;
  end;
end;

procedure TfNoInputReport.FormCreate(Sender: TObject);
begin
  StrLstPdLine := TStringList.Create;

  saEnglist[0] := '';
  saEnglist[1] := 'A';
  saEnglist[2] := 'B';
  saEnglist[3] := 'C';
  saEnglist[4] := 'D';
  saEnglist[5] := 'E';
  saEnglist[6] := 'F';
  saEnglist[7] := 'G';
  saEnglist[8] := 'H';
  saEnglist[9] := 'I';
  saEnglist[10] := 'J';
  saEnglist[11] := 'K';
  saEnglist[12] := 'L';
  saEnglist[13] := 'M';
  saEnglist[14] := 'N';
  saEnglist[15] := 'O';
  saEnglist[16] := 'P';
  saEnglist[17] := 'Q';
  saEnglist[18] := 'R';
  saEnglist[19] := 'S';
  saEnglist[20] := 'T';
  saEnglist[21] := 'U';
  saEnglist[22] := 'V';
  saEnglist[23] := 'W';
  saEnglist[24] := 'X';
  saEnglist[25] := 'Y';
  saEnglist[26] := 'Z';
end;

procedure TfNoInputReport.proSetStringData;
var
    i , j  : integer;
begin
    with StringGrid1 do
    begin
        colcount   := 7;
        rowcount   := 2;
        FixedCols  := 0;
        FixedRows  := 1;
        DefaultRowHeight := 18;

        for i := 0 to (colcount-1) do
        begin
            for j := 0 to 1 do
            begin
                Cells[i,j] := '' ;
            end;
        end;

        ColWidths[0] := 120;
        Cells[0,0] := 'Work Order';
        ColWidths[1] := 120;
        Cells[1,0] := 'Production Line';
        ColWidths[2] := 180;
        Cells[2,0] := 'Part No';
        ColWidths[3] := 90;
        Cells[3,0] := 'Target Qty';
        ColWidths[4] := 90;
        Cells[4,0] := 'Input Qty';
        ColWidths[5] := 90;
        Cells[5,0] := 'Output Qty';
        ColWidths[6] := 120;
        Cells[6,0] := 'Serial Number';
    end;
end;

procedure TfNoInputReport.proQueryData(sStartDate,sStartHour,sEndDate,sEndHour,sParFactory_ID,sParPdline_ID,sParWO,sPart : String);
var
  sSql,sFactory_ID,sPdline_ID,sWO,sPart_ID : String;
  i , j : integer;
begin
   proSetStringData;

   With QryData do
   begin
     //Factory
     sSQL := ' SELECT FACTORY_ID '
           + ' FROM SAJET.SYS_FACTORY '
           + ' WHERE FACTORY_CODE = ''' + trim(sParFactory_ID) + ''' '
           + ' ORDER BY FACTORY_CODE '
           ;

     Close;
     Params.Clear;
     CommandText := sSQL;
     Open;

     if not eof then
     begin
       sFactory_ID := trim(FieldByName('FACTORY_ID').AsString);
     end
     else
     begin
       sFactory_ID := '';
     end;
     //Factory

     //Line
     if trim(sParPdline_ID) = '' then
     begin
       sPdline_ID := '';
     end
     else
     begin
       sSQL := ' SELECT PDLINE_ID '
             + ' FROM SAJET.SYS_PDLINE '
             + ' WHERE PDLINE_NAME = ''' + trim(sParPdline_ID) + ''' '
             + '   AND FACTORY_ID = ''' + trim(sFactory_ID) + ''' '
             + ' ORDER BY PDLINE_ID '
             ;

       Close;
       Params.Clear;
       CommandText := sSQL;
       Open;

       if not eof then
       begin
         sPdline_ID := trim(FieldByName('PDLINE_ID').AsString);
       end
       else
       begin
         sPdline_ID := '';
       end;
     end;
     //Line

     //WO
     if trim(sParWO) <> '' then
     begin
       sWO := trim(sParWO);
     end
     else
     begin
       sWO := '';
     end;
     //WO

     //Part
     if trim(sPart) = '' then
     begin
       sPart_ID := '';
     end
     else
     begin
       sSQL := ' SELECT PART_ID '
             + ' FROM SAJET.SYS_PART '
             + ' WHERE PART_NO = ''' + trim(sPart) + ''' '
             + ' ORDER BY PART_ID '
             ;

       Close;
       Params.Clear;
       CommandText := sSQL;
       Open;

       if not eof then
       begin
         sPart_ID := trim(FieldByName('PART_ID').AsString);
       end
       else
       begin
         sPart_ID := '';
       end;
     end;
     //Part

     sSQL := 'Select A.WORK_ORDER "Work Order",' +
             ' D.PDLINE_NAME "Production Line",' +
             ' C.PART_NO "Part No",' +
             ' A.TARGET_QTY "Target Qty",' +
             ' A.INPUT_QTY "Input Qty",' +
             ' A.OUTPUT_QTY "Output Qty",' +
             ' B.SERIAL_NUMBER "Serial Number"' +
             ' FROM SAJET.G_WO_BASE A , ' +
             '      SAJET.G_SN_STATUS B , ' +
             '      SAJET.SYS_PART C , ' +
             '      SAJET.SYS_PDLINE D ' +
             ' WHERE A.WORK_ORDER = B.WORK_ORDER ' +
             '   AND A.MODEL_ID = C.PART_ID ' +
             '   AND A.DEFAULT_PDLINE_ID = D.PDLINE_ID ' +
             '   AND TERMINAL_ID = 0 ';

     if (sPdline_ID <> '') then
     begin
         sSQL := sSQL + '   AND A.DEFAULT_PDLINE_ID = ''' + trim(sPdline_ID) + ''' ';
     end;

     if Trim(sParWO) <> '' then
     begin
        if Pos('%', sParWO) <> 0 then
        begin
           sSQL := sSQL + '   AND A.WORK_ORDER Like ''' + Trim(sParWO) + ''' ';
        end
        else
        begin
           sSQL := sSQL + ' AND A.WORK_ORDER = ''' + Trim(sParWO) + ''' ';
        end;
     end;

     if (sPart_ID <> '') then
     begin
         sSQL := sSQL + ' AND C.PART_ID = ''' + trim(sPart_ID) + ''' ';
     end;

     sSQL := sSQL + ' Order by A.DEFAULT_PDLINE_ID , A.WORK_ORDER , B.SERIAL_NUMBER ';

     Close;
     Params.Clear;
     CommandText := sSQL;
     Open;
     GPRecords.Caption := InttoStr(RecordCount);

     if not eof then
     begin
       panelGressBar.Visible := True ;
       Label5.caption := 'Processing.....';
       ProgressBar1.Max := recordcount;
       ProgressBar1.Position :=  0 ;
       Application.ProcessMessages;

       StringGrid1.Rowcount := RecordCount+1;
       for i := 0 to RecordCount do
       begin
         ProgressBar1.Position := ProgressBar1.Position + 1 ;
         Application.ProcessMessages;

         StringGrid1.Cells[0,i+1] := FieldByName('Work Order').AsString;
         StringGrid1.Cells[1,i+1] := FieldByName('Production Line').AsString;
         StringGrid1.Cells[2,i+1] := FieldByName('Part No').AsString;
         StringGrid1.Cells[3,i+1] := FieldByName('Target Qty').AsString;
         StringGrid1.Cells[4,i+1] := FieldByName('Input Qty').AsString;
         StringGrid1.Cells[5,i+1] := FieldByName('Output Qty').AsString;
         StringGrid1.Cells[6,i+1] := FieldByName('Serial Number').AsString;
         next;
       end;
       panelGressBar.Visible := false ;
     end;
   end;   //end with
end;
procedure TfNoInputReport.sbtnWoClick(Sender: TObject);
begin
  with TfCommData.Create(Self) do
  begin
    LabType2.Caption := 'Work Order List';
    LabType1.Caption := LabType2.Caption;
    Label1.Caption := 'Search Work Order';
    with QryTemp do
    begin
      Close;
      Params.Clear;
      if editWO1.Text <> '' then
        Params.CreateParam(ftString, 'work_order', ptInput);
      CommandText := 'select work_order "Work Order", target_qty "Target Qty", '
        + 'part_no "Part No", part_type "Part Type", spec1 "Spec1", spec2 "Spec2" '
        + 'from sajet.g_wo_base a, sajet.sys_part b '
        + 'where wo_status > 0 and wo_status < 5 ';
      if editWO1.Text <> '' then
        CommandText := CommandText + 'and work_order like :work_order ';
      CommandText := CommandText + 'and a.model_id = b.part_id '
        + 'order by work_order ';
      if editWO1.Text <> '' then
        Params.ParamByName('work_order').AsString := editWO1.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      editWO1.Text := QryTemp.FieldByName('work order').AsString;
      QryTemp.Close;
      editWO1.SetFocus;
    end;
    free;
  end;
end;

procedure TfNoInputReport.sbtnPartClick(Sender: TObject);
begin
  with TfCommData.Create(Self) do
  begin
    LabType2.Caption := 'Part No List';
    LabType1.Caption := LabType2.Caption;
    Label1.Caption := 'Search Part No';
    with QryTemp do
    begin
      Close;
      Params.Clear;
      if editPart.Text <> '' then
        Params.CreateParam(ftString, 'part_no', ptInput);
      CommandText := 'select part_no "Part No", part_type "Part Type", spec1 "Spec1", spec2 "Spec2" '
        + 'from sajet.sys_part b ';
      if editPart.Text <> '' then
        CommandText := CommandText + 'where part_no like :part_no ';
      CommandText := CommandText + 'order by part_no ';
      if editPart.Text <> '' then
        Params.ParamByName('part_no').AsString := editPart.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      editPart.Text := QryTemp.FieldByName('part no').AsString;
      QryTemp.Close;
      editPart.SetFocus;
    end;
    free;
  end;
end;

end.
