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
    Label3: TLabel;
    Label4: TLabel;
    SaveDialog1: TSaveDialog;
    strgridData: TStringGrid;
    Image3: TImage;
    sbtnQuery: TSpeedButton;
    LabWO: TLabel;
    Lblrecordcount: TLabel;
    ImageTitle: TImage;
    EditWO: TEdit;
    RadioGroupSNstatus: TRadioGroup;
    RadioGroupRecordType: TRadioGroup;
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnQueryClick(Sender: TObject);
    procedure RadioGroupRecordTypeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
  end;

var
  fDetail: TfDetail;
  icol,irow:integer;
implementation

uses uCommData, uSelect;
{$R *.DFM}

procedure TfDetail.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var i, j,iStartRow,iDiv,iMod: integer;
    vRange1:Variant;
begin
   istartrow:=2 ;
   if  strgridData.RowCount <=5000 then
   begin
      MsExcel.Worksheets['Sheet1'].select;
      for i := 0 to strgridData.RowCount  do
      BEGIN
          for j := 0 to strgridData.ColCount  do
             MsExcel.Worksheets['Sheet1'].Cells[i+iStartRow,j+1].value := strgridData.Cells[j,i];
      END ;
   end;

   if (strgridData.RowCount >5000 ) and (strgridData.RowCount<=10000)  then
   begin
      MsExcel.Worksheets['Sheet1'].select;
      for i:=0 to 5000 do
      BEGIN
          for j := 0 to strgridData.ColCount  do
             MsExcel.Worksheets['Sheet1'].Cells[i+iStartRow,j+1].value := strgridData.Cells[j,i];
      END ;
      MsExcel.Worksheets['Sheet2'].select;
      for i:=5001 to strgridData.RowCount do
      begin
          for j := 0 to strgridData.ColCount  do
             MsExcel.Worksheets['Sheet2'].Cells[i+iStartRow-5001,j+1].value := strgridData.Cells[j,i];
      end;
   end ;

   if strgridData.RowCount >10000  then
   begin
      MsExcel.Worksheets['Sheet1'].select;
      for i:=0 to 5000 do
      BEGIN
          for j := 0 to strgridData.ColCount  do
             MsExcel.Worksheets['Sheet1'].Cells[i+iStartRow,j+1].value := strgridData.Cells[j,i];
      END ;
      MsExcel.Worksheets['Sheet2'].select;
      for i:=5001 to 10000 do
      begin
          for j := 0 to strgridData.ColCount  do
             MsExcel.Worksheets['Sheet2'].Cells[i+iStartRow-5001,j+1].value := strgridData.Cells[j,i];
      end;
      MsExcel.Worksheets['Sheet3'].select;
      for i:=10001 to strgridData.RowCount do
      begin
          for j := 0 to strgridData.ColCount  do
             MsExcel.Worksheets['Sheet3'].Cells[i+iStartRow-10001,j+1].value := strgridData.Cells[j,i];
      end;
   end
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
           ColCount  :=6;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=100;
           cells[0,0]:='WO';
           colwidths[1]:=100;
           cells[1,0]:='SN';
           colwidths[2]:=100;
           cells[2,0]:='CSN';
           colwidths[3]:=100;
           cells[3,0]:='BOX_NO';
           colwidths[4]:=100;
           cells[4,0]:='CARTON_NO';
           colwidths[5]:=100;
           cells[5,0]:='PALLET_NO';
  end;
    lblrecordcount.Caption :='';
    editwo.Clear ;
    RadioGROUPSNSTATUS.ItemIndex:=2;
    radiogrouprecordtype.ItemIndex :=0;
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

  My_FileName := ExtractFilePath(Application.ExeName)+'QuerySNBYWO.xlt';

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
var i:integer;
var sqlstr: string;
begin
   if trim(editwo.Text)='' then exit;

   if radiogrouprecordtype.ItemIndex = 0 then //  by pallet
   begin
       sqlstr:=' select work_order,serial_number,customer_sn,box_no,carton_no,pallet_no from sajet.g_sn_status ' ;
       if radiogroupsnstatus.ItemIndex = 0 then  // by sn release
          sqlstr:=sqlstr + ' where work_order = '''+trim(editwo.Text)+'''  AND PROCESS_ID = 0 AND WIP_PROCESS = 0 ';
       if radiogroupsnstatus.ItemIndex = 1 then  // by sn wip
          sqlstr:=sqlstr + ' where work_order ='''+trim(editwo.Text) + ''' and  in_process_time  is not null and out_pdline_time is null ';
       if radiogroupsnstatus.ItemIndex = 2 then // by sn complete
          sqlstr:=sqlstr + ' where work_order ='''+trim(editwo.Text) + ''' and out_pdline_time is not null ';
       if radiogroupsnstatus.ItemIndex = 3 then // by sn complete
          sqlstr:=sqlstr + ' where work_order ='''+trim(editwo.Text)+''' ';
   end;

   if radiogrouprecordtype.ItemIndex = 1 then // by keyparts
   begin
       sqlstr:=' SELECT WORK_ORDER,SERIAL_NUMBER,ITEM_PART_SN AS KEYPARTS,NVL(ITEM_GROUP,''N/A'') AS ITEM_GROUP  '
              +' FROM SAJET.G_SN_KEYPARTS WHERE WORK_ORDER='''+trim(editwo.Text)+''' ';
   end ;

  with QryData do
  begin
       with  strgridData do
         for icol:=0 to colcount-1 do
             for irow:=1 to rowcount-1 do
                Cells[icol,irow]:='';
       Close;
       commandtext:=SQLSTR;
       Open;
       if IsEmpty then
       begin
            lblrecordcount.Caption :='TOTAL:0';
            Showmessage('No Data');
            exit;
        end;

        if radiogrouprecordtype.ItemIndex = 0 then  // by pallet
        begin
            with  strgridData do
            begin
               for icol:=0 to colcount-1 do
                 for irow:=0 to rowcount-1 do
                     Cells[icol,irow]:='';

                ColCount  :=6;
                ColWidths[0]:=100;
                cells[0,0]:='WO';
                colwidths[1]:=100;
                cells[1,0]:='SN';
                colwidths[2]:=100;
                cells[2,0]:='CSN';
                colwidths[3]:=100;
                cells[3,0]:='BOX_NO';
                colwidths[4]:=100;
                cells[4,0]:='CARTON_NO';
                colwidths[5]:=100;
                cells[5,0]:='PALLET_NO';
           end;

           irow:=0;
           while not eof do
           begin
              IROW:=IROW+1;
              strgridData.Cells[0,irow]:=fieldbyname('work_order').asstring ;
              Strgriddata.Cells[1,irow]:=fieldbyname('serial_number').AsString   ;
              strgridData.Cells[2,irow]:=fieldbyname('customer_sn').asstring ;
              Strgriddata.Cells[3,irow]:=fieldbyname('box_no').AsString   ;
              strgridData.Cells[4,irow]:=fieldbyname('carton_no').asstring ;
              Strgriddata.Cells[5,irow]:=fieldbyname('pallet_no').AsString   ;
              next;
              Strgriddata.RowCount:=IROW+1;
              lblrecordcount.Caption :='TOTAL:'+ inttostr(irow);
           end;
        end;

       if radiogrouprecordtype.ItemIndex = 1 then  // by keyparts
       begin
           with  strgridData do
           BEGIN
               for icol:=0 to colcount-1 do
                  for irow:=0 to rowcount-1 do
                      Cells[icol,irow]:='';

                ColCount  :=4;
                ColWidths[0]:=100;
                cells[0,0]:='WO';
                colwidths[1]:=100;
                cells[1,0]:='SN';
                colwidths[2]:=100;
                cells[2,0]:='KEYPARTS';
                colwidths[3]:=100;
                cells[3,0]:='ITEM_GROUP';
           end;

           irow:=0;
           while not eof do
           begin
              IROW:=IROW+1;
              strgridData.Cells[0,irow]:=fieldbyname('work_order').asstring ;
              Strgriddata.Cells[1,irow]:=fieldbyname('serial_number').AsString   ;
              strgridData.Cells[2,irow]:=fieldbyname('KEYPARTS').asstring ;
              Strgriddata.Cells[3,irow]:=fieldbyname('ITEM_GROUP').AsString   ;
              next;
              Strgriddata.RowCount:=IROW+1;
              lblrecordcount.Caption :='TOTAL:'+ inttostr(irow);
          end;
       end;
   end;
end;

procedure TfDetail.RadioGroupRecordTypeClick(Sender: TObject);
begin
   if radiogrouprecordtype.ItemIndex = 0 then
      radiogroupsnstatus.Enabled :=true;
   if radiogrouprecordtype.ItemIndex = 1 then
      radiogroupsnstatus.Enabled :=false;
end;

end.

