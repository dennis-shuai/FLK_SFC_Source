unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  MConnect, SConnect, {FileCtrl,} ObjBrkr, Menus,DateUtils,comobj,Variants,
  ComCtrls,Excel2000;

type
  TfMain = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    labCnt: TLabel;
    labcost: TLabel;
    qryReel: TClientDataSet;
    Image2: TImage;
    sbtnQuery: TSpeedButton;
    Label4: TLabel;
    StringGrid1: TStringGrid;
    lblstatus: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Editpartno: TEdit;
    Editwh: TEdit;
    Editlocate: TEdit;
    EditindateC: TEdit;
    GroupBox1: TGroupBox;
    EditColor1: TEdit;
    EditColor2: TEdit;
    EditColor3: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label5: TLabel;
    Cmbboxstatus: TComboBox;
    Sbtnexport: TSpeedButton;
    Image1: TImage;
    SaveDialog1: TSaveDialog;
    procedure FormShow(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure CLEARDATA;
    procedure queryIndate;
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure EditindateCChange(Sender: TObject);
    procedure SbtnexportClick(Sender: TObject);
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);
    Function  DownloadSampleFile : String;

  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    icol,irow:integer;
    DateRow:integer;

  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform;


procedure TfMain.CLEARDATA;
var i,j:integer;
BEGIN
   stringgrid1.FixedRows:=1;
   stringgrid1.FixedCols:=0;
   for i:=0 to stringgrid1.Rowcount  do
     for j:=0 to stringgrid1.ColCount do
       stringgrid1.Cells[j,i]:='';
   stringgrid1.Cells[0,0]:='Part_NO';
   stringgrid1.Cells[1,0]:='Material_No' ;
   stringgrid1.Cells[2,0]:='Reel_No' ;
   stringgrid1.Cells[3,0]:='Warehouse' ;
   stringgrid1.Cells[4,0]:='Locate';
   stringgrid1.Cells[5,0]:='FIFOCODE' ;
   stringgrid1.Cells[6,0]:='IQC DateCode' ;
   stringgrid1.Cells[7,0]:='Indate(W)';
   stringgrid1.Cells[8,0]:='Indate_C1(W)';
   stringgrid1.Cells[9,0]:='Indate_C2(W)';

   stringgrid1.ColWidths[0]:=120;
   stringgrid1.ColWidths[1]:=80;
   stringgrid1.ColWidths[2]:=80;
   stringgrid1.ColWidths[3]:=80;
   stringgrid1.ColWidths[4]:=80;
   stringgrid1.ColWidths[5]:=80;
   stringgrid1.ColWidths[6]:=80;
   stringgrid1.ColWidths[7]:=60;
   stringgrid1.ColWidths[8]:=-1;
   stringgrid1.ColWidths[9]:=-1;
   stringgrid1.RowCount:=2;
   lblstatus.Caption :='';
END;


procedure TfMain.queryIndate;
var i,j:integer;
var strsql:string;
begin
   strsql:=' SELECT B.PART_NO,A.MATERIAL_NO,A.REEL_NO,C.WAREHOUSE_NAME,  '
          +' D.LOCATE_NAME,A.FIFOCODE,B.OPTION14 ,A.DateCode,'
          +' TO_CHAR(SYSDATE-B.OPTION14*7,''YYYYMMDD'')  AS  Indata_C1,'
          +' TO_CHAR(SYSDATE-(B.OPTION14-:indatac)*7,''YYYYMMDD'')  AS  Indata_C2 '
          +' FROM sajet.G_MATERIAL A, sajet.SYS_PART  B,sajet.SYS_WAREHOUSE C,sajet.SYS_LOCATE D '
          +' WHERE '
          +' A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID AND A.LOCATE_ID=D.LOCATE_ID(+) '
          +' AND b.option14  IS NOT  NULL AND b.option13 =''Y'' '
          +' and c.warehouse_name='+''''+editwh.Text+'''';

   if trim(editpartno.Text)<>'' then
      strsql:=strsql+' and b.part_no='+''''+trim(editpartno.Text)+'''';
   if trim(editlocate.Text)<>'' then
      strsql:=strsql+' and d.locate_name='+''''+trim(editlocate.Text)+'''';

   {if trim(cmbboxlinename.Text)<>'' then
      strsql:=strsql+' and c.pdline_name='+''''+cmbboxlinename.Text+'''';
   if trim(cmbboxmachine.Text)<>'' then
      strsql:=strsql+' and b.machine_code='+''''+cmbboxmachine.Text+'''';
   }
   
   strsql:=strsql+' order by B.PART_NO,A.MATERIAL_NO,A.REEL_NO ';

   with Qrydata do
   begin
         Qrydata.close;
         Qrydata.Params.Clear;
         Qrydata.Params.CreateParam(ftString,'indatac',ptInput);
         Qrydata. commandtext:=strsql;
         Qrydata.params.ParamByName('indatac').AsInteger:=strtoint(editindatec.Text);
         Qrydata. open;

       first;
       irow:=1;
       while not eof do
       begin
          if (cmbboxstatus.Text='ALL') or (cmbboxstatus.Text ='') then
          begin
             stringgrid1.Cells[0,irow]:= fieldbyname('PART_NO').AsString ;
             stringgrid1.Cells[1,irow]:=fieldbyname('MATERIAL_NO').AsString ;
             stringgrid1.Cells[2,irow]:= fieldbyname('REEL_NO').AsString ;
             stringgrid1.Cells[3,irow]:=fieldbyname('WAREHOUSE_NAME').AsString;
             stringgrid1.Cells[4,irow]:=fieldbyname('LOCATE_NAME').AsString ;
             stringgrid1.Cells[5,irow]:=fieldbyname('FIFOCODE').AsString;
             stringgrid1.Cells[6,irow]:=fieldbyname('DateCode').AsString;
             stringgrid1.Cells[7,irow]:=fieldbyname('OPTION14').AsString ;
             stringgrid1.Cells[8,irow]:=fieldbyname('Indata_C1').AsString;
             stringgrid1.Cells[9,irow]:=fieldbyname('Indata_C2').AsString ;

             inc(irow);
             next;
          end
          else if cmbboxstatus.Text='ERROR' then
          begin
              if   fieldbyname('DateCode').AsString <= fieldbyname('Indata_C1').AsString then
              begin
                   stringgrid1.Cells[0,irow]:= fieldbyname('PART_NO').AsString ;
                   stringgrid1.Cells[1,irow]:=fieldbyname('MATERIAL_NO').AsString ;
                   stringgrid1.Cells[2,irow]:= fieldbyname('REEL_NO').AsString ;
                   stringgrid1.Cells[3,irow]:=fieldbyname('WAREHOUSE_NAME').AsString;
                   stringgrid1.Cells[4,irow]:=fieldbyname('LOCATE_NAME').AsString ;
                   stringgrid1.Cells[5,irow]:=fieldbyname('FIFOCODE').AsString;
                   stringgrid1.Cells[6,irow]:=fieldbyname('DateCode').AsString;
                   stringgrid1.Cells[7,irow]:=fieldbyname('OPTION14').AsString ;
                   stringgrid1.Cells[8,irow]:=fieldbyname('Indata_C1').AsString;
                   stringgrid1.Cells[9,irow]:=fieldbyname('Indata_C2').AsString ;
                   inc(irow);
              end;
              next;
          end
          else if cmbboxstatus.Text='WARRING' then
          begin
              if   (fieldbyname('DateCode').AsString > fieldbyname('Indata_C1').AsString )
                   and (fieldbyname('DateCode').AsString <= fieldbyname('Indata_C2').AsString) then
              begin
                   stringgrid1.Cells[0,irow]:= fieldbyname('PART_NO').AsString ;
                   stringgrid1.Cells[1,irow]:=fieldbyname('MATERIAL_NO').AsString ;
                   stringgrid1.Cells[2,irow]:= fieldbyname('REEL_NO').AsString ;
                   stringgrid1.Cells[3,irow]:=fieldbyname('WAREHOUSE_NAME').AsString;
                   stringgrid1.Cells[4,irow]:=fieldbyname('LOCATE_NAME').AsString ;
                   stringgrid1.Cells[5,irow]:=fieldbyname('FIFOCODE').AsString;
                   stringgrid1.Cells[6,irow]:=fieldbyname('DateCode').AsString;
                   stringgrid1.Cells[7,irow]:=fieldbyname('OPTION14').AsString ;
                   stringgrid1.Cells[8,irow]:=fieldbyname('Indata_C1').AsString;
                   stringgrid1.Cells[9,irow]:=fieldbyname('Indata_C2').AsString ;
                   inc(irow);
              end;
               next;
          end
          else if cmbboxstatus.Text='OK' then
           begin
              if   fieldbyname('DateCode').AsString > fieldbyname('Indata_C2').AsString  then
              begin
                   stringgrid1.Cells[0,irow]:= fieldbyname('PART_NO').AsString ;
                   stringgrid1.Cells[1,irow]:=fieldbyname('MATERIAL_NO').AsString ;
                   stringgrid1.Cells[2,irow]:= fieldbyname('REEL_NO').AsString ;
                   stringgrid1.Cells[3,irow]:=fieldbyname('WAREHOUSE_NAME').AsString;
                   stringgrid1.Cells[4,irow]:=fieldbyname('LOCATE_NAME').AsString ;
                   stringgrid1.Cells[5,irow]:=fieldbyname('FIFOCODE').AsString;
                   stringgrid1.Cells[6,irow]:=fieldbyname('DateCode').AsString;
                   stringgrid1.Cells[7,irow]:=fieldbyname('OPTION14').AsString ;
                   stringgrid1.Cells[8,irow]:=fieldbyname('Indata_C1').AsString;
                   stringgrid1.Cells[9,irow]:=fieldbyname('Indata_C2').AsString ;
                   inc(irow);
               end;
               next;
           end;
       end;
       if (not isempty) and (irow>=2) then
         stringgrid1.Rowcount :=irow;

       lblstatus.Caption :=inttostr(Irow-1) ;
   end;

end;


procedure TfMain.FormShow(Sender: TObject);
begin
  case screen.width of
      640: self.ScaleBy(80, 100);
      800: self.ScaleBy(100, 100);
      1024: self.ScaleBy(125, 100);
  else
      self.ScaleBy(100, 100);
  end;

  DateRow:=1;
  
  with QryTemp do
  begin
      Close;
      Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
      Params.CreateParam(ftString, 'dll_name', ptInput);
      CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
        + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
        + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
      if gsParam <> '' then
        CommandText := CommandText + 'and fun_param = ''' + gsParam + ''' ';
      Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
      Params.ParamByName('dll_name').AsString := 'QueryIndate.dll';
      Open;
  end;

  cleardata;
end;

procedure TfMain.sbtnQueryClick(Sender: TObject);
begin
   if trim(editwh.Text)='' then exit;
   cleardata;
   queryIndate;
end;

procedure TfMain.StringGrid1SelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
      DateRow:=Arow;
end;

procedure TfMain.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var k:integer;
begin
  //if (ACol<=0) then exit;
  if (ACol<0) then exit;
  K:=stringgrid1.RowCount;

  if (ARow=0) and (ACol<k) then exit ;
  if ARow=0 then exit;
  if  (stringgrid1.Cells[6,Arow]>stringgrid1.Cells[8,Arow])
       and (stringgrid1.Cells[6,Arow]<=stringgrid1.Cells[9,Arow]) AND (Arow<>dateRow) then
  begin
      stringgrid1.Canvas.Brush.Color:=clyellow;
      stringgrid1.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, stringgrid1.Cells[ACol, ARow]);
  end 
  else if  Arow=dateRow then
  begin
      stringgrid1.Canvas.Brush.Color:=CLBLUE;
      stringgrid1.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, stringgrid1.Cells[ACol, ARow]);
  end
  else  if (stringgrid1.Cells[6,Arow] <= stringgrid1.Cells[8,Arow]) and (Arow<>dateRow) then
  begin
       stringgrid1.Canvas.Brush.Color:=ClRED;
       stringgrid1.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, stringgrid1.Cells[ACol, ARow]);
  end
  else begin
     stringgrid1.Canvas.Brush.Color:=clWINDOW;
     stringgrid1.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, stringgrid1.Cells[ACol, ARow]);
  end;
  

end;

procedure TfMain.EditindateCChange(Sender: TObject);
begin
   Try
      editindatec.Text:=inttostr(strtoint(editindatec.Text))
    except
      editindatec.Text :='1';
    end;
    if strtoint(editindatec.Text) <1 then
    begin
       editindatec.Text :='1';
    end;
end;

procedure TfMain.SbtnexportClick(Sender: TObject);
var
  sFileName,My_FileName : String;
  MsExcel, MsExcelWorkBook : Variant;
  row:Integer;
begin
  if not QryData.Active Then Exit;
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'xls';
  SaveDialog1.Filter := 'All Files(*.xls)|*.xls';
  My_FileName:= DownLoadSampleFile;
  {
  if not FileExists(My_FileName) then
  begin
       showmessage('Error!-The Excel File '+My_FileName+' can''t be found.');
       exit;
  end;
  }
  if SaveDialog1.Execute then
  begin
      try
            sFileName := SaveDialog1.FileName;

            if FileExists(sFileName) then
            begin
                If MessageDlg('File has exist! Replace or Not ?',mtCustom, mbOKCancel,0) = mrOK Then
                    DeleteFile(sFileName)
                else
                    exit;
            end;
           MsExcel := CreateOleObject('Excel.Application');
           MsExcel.displayAlerts:=False;
           MsExcel.Visible := True;
           MsExcelWorkBook := MsExcel.WorkBooks.Add;
           MsExcel.WorkSheets[1].Activate;
           MSExcel.ActiveSheet.cells[1,1].Value :='Query Indate Information'  ;
           MsExcel.ActiveSheet.Range['A1:H1'].Merge;
           MSExcel.ActiveSheet.cells[1,1].Font.Size :=24;
           MSExcel.ActiveSheet.cells[1,1].Font.Color :=clBlue;
           MsExcel.ActiveSheet.Range['A2:H2'].Interior.Color :=ClYellow;
           MSExcel.ActiveSheet.Columns[1].ColumnWidth :=15;
           MSExcel.ActiveSheet.Columns[2].ColumnWidth :=15;
           MSExcel.ActiveSheet.Columns[3].ColumnWidth :=15;
           MSExcel.ActiveSheet.Columns[4].ColumnWidth :=10;
           MSExcel.ActiveSheet.Columns[5].ColumnWidth :=8;
           MSExcel.ActiveSheet.Columns[7].ColumnWidth :=10;
           for row:=0 to stringgrid1.RowCount do
           begin
                MsExcel.ActiveSheet.Cells[2+row,1].value :=stringgrid1.Cells[0,row];
                MsExcel.ActiveSheet.Cells[2+row,2].value :=stringgrid1.Cells[1,row];
                MsExcel.ActiveSheet.Cells[2+row,3].value :=stringgrid1.Cells[2,row];
                MsExcel.ActiveSheet.Cells[2+row,4].value :=stringgrid1.Cells[3,row];
                MsExcel.ActiveSheet.Cells[2+row,5].value :=stringgrid1.Cells[4,row];
                MsExcel.ActiveSheet.Cells[2+row,6].value :=stringgrid1.Cells[5,row];
                MsExcel.ActiveSheet.Cells[2+row,7].value :=stringgrid1.Cells[6,row];
                MsExcel.ActiveSheet.Cells[2+row,8].value :=stringgrid1.Cells[7,row];
           end;
           MsExcel.ActiveSheet.Range['A1:H'+IntToStr(row+2)].HorizontalAlignment :=3;
           MsExcel.ActiveSheet.Range['A1:H'+IntToStr(row+2)].VerticalAlignment :=2;
           MsExcel.ActiveSheet.Range['A2:H'+IntToStr(row+2)].Font.Size :=8;
           MsExcel.ActiveSheet.Range['A1:H'+IntToStr(row+2)].Font.Name :='tahoma';
           MsExcel.ActiveSheet.Range['A1:H'+IntToStr(row+2)].Borders[1].Weight := 2;
           MsExcel.ActiveSheet.Range['A1:H'+IntToStr(row+2)].Borders[2].Weight := 2;
           MsExcel.ActiveSheet.Range['A1:H'+IntToStr(row+2)].Borders[3].Weight := 2;
           MsExcel.ActiveSheet.Range['A1:H'+IntToStr(row+2)].Borders[4].Weight := 2;
           MsExcel.ActiveSheet.Range['A1:H'+IntToStr(row+2)].Borders[7].Weight := xlThick;
           MsExcel.ActiveSheet.Range['A1:H'+IntToStr(row+2)].Borders[8].Weight := xlThick;
           MsExcel.ActiveSheet.Range['A1:H'+IntToStr(row+2)].Borders[9].Weight := xlThick;
           MsExcel.ActiveSheet.Range['A1:H'+IntToStr(row+2)].Borders[10].Weight := xlThick;

          MsExcelWorkBook.SaveAs(sFileName);
          showmessage('Save Excel OK!!');
      Except
        ShowMessage('Could not start Microsoft Excel.');
      end;

      MsExcel.Application.Quit;
      MsExcel:=Null;
  end
  else
    MessageDlg('You did not Save Any Data',mtWarning,[mbok],0);
end;

procedure TfMain.SaveExcel(MsExcel,MsExcelWorkBook:Variant);
var i,row:integer;
begin

end;

Function TfMain.DownloadSampleFile : String;
begin
    Result:=ExtractFilePath(Application.ExeName) + ExtractFileName('QueryIndate.xltx')
end;

end.




