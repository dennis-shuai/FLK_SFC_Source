unit UDataGroup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, Buttons, Grids, DBGrids,  Db,
  DBClient, MConnect, ObjBrkr, SConnect,GradPanel,  comobj, Menus;

  {
   StdCtrls, jpeg, ExtCtrls,  DBGrids,  Db,
  DBClient, MConnect, ObjBrkr, SConnect,GradPanel,  comobj, Menus;}

type
  TFDataGroup = class(TForm)
    PageControl1: TPageControl;
    Panel1: TPanel;
    sbtnSave: TSpeedButton;
    Image7: TImage;
    StrGriddatagroup: TStringGrid;
    SaveDialogGroup: TSaveDialog;
    procedure sbtnSaveClick(Sender: TObject);
    procedure StrGriddatagroupDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SaveExcelgroup(MsExcel, MsExcelWorkBook: Variant);
  end;

var
  FDataGroup: TFDataGroup;

implementation

uses uDetail, UDataSN;

{$R *.dfm}

procedure TFDataGroup.SaveExcelgroup(MsExcel, MsExcelWorkBook: Variant);
var i, j,iStartRow,iDiv,iMod: integer;
    vRange1:Variant;
begin
   istartrow:=2 ;
   for i := 0 to strgridDatagroup.RowCount  do
      BEGIN
          for j := 0 to strgridDataGroup.ColCount  do
            MsExcel.Worksheets['Sheet1'].Cells[i+iStartRow,j+1].value := strgridDataGroup.Cells[j,i];
      END ;
end;

procedure TFDataGroup.sbtnSaveClick(Sender: TObject);
var
  sFileName, My_FileName: string;
  MsExcel, MsExcelWorkBook: Variant;
  i: Integer;
begin
  if (not fDetail.QryDataGroup.Active) or (fDetail.QryDataGroup.IsEmpty) then Exit;
  SaveDialogGroup.InitialDir := ExtractFilePath('C:\');
  SaveDialogGroup.DefaultExt := 'xls';
  SaveDialogGroup.Filter := 'All Files(*.xls)|*.xls';

  My_FileName := ExtractFilePath(Application.ExeName)+'DFPYReport.xlt';

  if not FileExists(My_FileName) then
  begin
    showmessage('Error!-The Excel File ' + My_FileName + ' can''t be found.');
    exit;
  end;

  if Sender = sbtnSave then
  begin
    if SaveDialogGroup.Execute then
      sFileName := SaveDialogGroup.FileName
    else
      exit;  
  end;

  try
    MsExcel := CreateOleObject('Excel.Application');
    MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);

    MsExcel.Worksheets['Sheet1'].select;
    SaveExcelGroup(MsExcel, MsExcelWorkBook);
    if Sender = sbtnSave then
    begin
      MsExcelWorkBook.SaveAs(sFileName);
      showmessage('Save Excel OK!!');
    end;
    {if Sender = sbtnPrint then
    begin
      WindowState := wsMinimized;
      MsExcel.Visible := TRUE;
      MsExcel.WorkSheets['Sheet1'].PrintPreview;
      WindowState := wsMaximized;
    end;
    }
  except
    ShowMessage('Could not start Microsoft Excel.');
  end;
  MsExcelWorkBook.close(False);
  MsExcel.Application.Quit;
  MsExcel := Null;
end;

procedure TFDataGroup.StrGriddatagroupDblClick(Sender: TObject);
var iDrow,iDcol:integer;
    irow,icol:integer;
    sStartDate,sEndDate: string;
    sstarttime,sendtime:string;
    i:integer;
    strsql1:string; //First_fail SN
    strsql2:string;//NTF  SN
    Strsql3:string;//first_fail - NTF   SN 
begin
    iDrow:=strgridDataGroup.Row ;
    iDcol:=strgridDataGroup.Col;

  with TFDataSN.create(Self) do
  begin
    try
        with strgridDataSN do
        begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=10;
           ColCount  :=8;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=100;
           cells[0,0]:='Work Order';
           ColWidths[1]:=100;
           cells[1,0]:='Part No';
           colwidths[2]:=90;
           cells[2,0]:='Serial Number';
           colwidths[3]:=100;
           cells[3,0]:='Production Line';
           colwidths[4]:=80;
           CELLS[4,0]:='Defect Process';
           colwidths[5]:=120;
           CELLS[5,0]:='Defect CODE';
           colwidths[6]:=120;
           CELLS[6,0]:='Defect Desc';
           colwidths[7]:=150;
           CELLS[7,0]:='Defect Time';
        end;
        for i:= 1 to strgridDataSN.ROWCount do
            strgridDataSN.ROWs[i].Clear;

        sStartDate:='';
        sEndDate:=''  ;
        sStartDate:=FormatDateTime('YYYYMMDD',fDetail.datetimepickerstart.Date);
        sEndDate:=FormatDateTime('YYYYMMDD',fDetail.datetimepickerEND.Date);

        sstarttime:=trim(sstartdate)+trim(fDetail.combstarthour.Text);
        sendtime:=trim(senddate)+trim(fDetail.combendhour.Text);

        if not fDetail.getpdlineid(strgridDataGroup.Cells[1,iDrow])  then
        begin
            showmessage('Not find the Line_Name:'+strgridDataGroup.Cells[1,iDrow]);
            exit;
        end;
        if not fDetail.getprocessid(strgridDataGroup.Cells[3,iDrow])  then
        begin
            showmessage('Not find the Process_Name:'+strgridDataGroup.Cells[3,iDrow]);
            exit;
        end;
        if not fDetail.getdefectid(strgridDataGroup.Cells[4,iDrow])  then
        begin
            showmessage('Not find the Defect_code:'+strgridDataGroup.Cells[4,iDrow]);
            exit;
        end;

        irow:=0;
        // ㄌ Work_order,pdline_name,process_name,defect_code 琩高SN戈
        // QUERY FIRST FAIL SN DETAIL 
        STRSQL1:=' select A.WORK_ORDER,B.PART_NO,A.SERIAL_NUMBER,C.PDLINE_NAME, '
                +' D.PROCESS_NAME,E.DEFECT_CODE,E.DEFECT_DESC,A.REC_TIME '
                +' from sajet.g_sn_defect_first A, SAJET.SYS_PART B ,SAJET.SYS_PDLINE C, '
                +' SAJET.SYS_PROCESS D,SAJET.SYS_DEFECT E '
                +' WHERE A.MODEL_ID=B.PART_ID '
                +' AND A.PDLINE_ID=C.PDLINE_ID '
                +' AND A.PROCESS_ID=D.PROCESS_ID '
                +' AND A.DEFECT_ID=E.DEFECT_ID '
                +' AND A.WORK_ORDER=:WORK_ORDER '
                +' AND a.pdline_id=:pdline_id '
                +' AND a.PROCESS_id=:process_id '
                +' AND a.defect_id=:defect_id '
                +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') >= :starttime  '
                +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') < :endtime '
                +' ORDER BY A.WORK_ORDER,C.PDLINE_NAME,D.PROCESS_NAME,A.SERIAL_NUMBER' ;
       // QUERY NTF SN DETAIL
        STRSQL2:=' select A.WORK_ORDER,B.PART_NO,A.SERIAL_NUMBER,C.PDLINE_NAME, '
                +' D.PROCESS_NAME,E.DEFECT_CODE,E.DEFECT_DESC,A.REC_TIME '
                +' from sajet.g_sn_defect_first A, SAJET.SYS_PART B ,SAJET.SYS_PDLINE C, '
                +' SAJET.SYS_PROCESS D,SAJET.SYS_DEFECT E '
                +' WHERE A.MODEL_ID=B.PART_ID '
                +' AND A.PDLINE_ID=C.PDLINE_ID '
                +' AND A.PROCESS_ID=D.PROCESS_ID '
                +' AND A.DEFECT_ID=E.DEFECT_ID '
                +' AND A.WORK_ORDER=:WORK_ORDER '
                +' AND a.pdline_id=:pdline_id '
                +' AND a.PROCESS_id=:process_id '
                +' AND a.defect_id=:defect_id '
                +' AND A.ntf_time is not null ' //NTF
                +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') >= :starttime  '
                +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') < :endtime '
                +' ORDER BY A.WORK_ORDER,C.PDLINE_NAME,D.PROCESS_NAME,A.SERIAL_NUMBER' ;
        // QUERY (FIRST_FAIL - NTF)  SN DETAIL
        // line,defect,rec_time 程Ωscan defect 闽;
        STRSQL3:=' select A.WORK_ORDER,B.PART_NO,A.SERIAL_NUMBER,C.PDLINE_NAME, '
                +' D.PROCESS_NAME,E.DEFECT_CODE,E.DEFECT_DESC,F.REC_TIME '
                +' from sajet.g_sn_defect_first A, SAJET.SYS_PART B ,SAJET.SYS_PDLINE C, '
                +' SAJET.SYS_PROCESS D,SAJET.SYS_DEFECT E ,sajet.g_sn_defect F '
                +' WHERE A.MODEL_ID=B.PART_ID '
                +' AND A.LAST_RECID=F.RECID '
                +' AND F.PDLINE_ID=C.PDLINE_ID '
                +' AND A.PROCESS_ID=D.PROCESS_ID '
                +' AND A.PDLINE_ID=+'''+g_pdlineidofdetail+''' ' //add by key 2008/12/25 
                +' AND F.DEFECT_ID=E.DEFECT_ID '
                +' AND A.WORK_ORDER=:WORK_ORDER '
                +' AND F.pdline_id=:pdline_id '   //程pdline name 秈︽琩高,﹚璶g_sn_defect い
                +' AND a.PROCESS_id=:process_id '
                +' AND F.defect_id=:defect_id '  //程defect code秈︽琩高﹚璶g_sn_defectい
                +' AND A.ntf_time is  null ' // FIRST_FAIL - NTF
                +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') >= :starttime  '
                +' AND TO_CHAR(A.REC_TIME,''YYYYMMDDHH24'') < :endtime '
                +' ORDER BY A.WORK_ORDER,C.PDLINE_NAME,D.PROCESS_NAME,A.SERIAL_NUMBER' ;
       with fDetail.QryDataSN do
       begin
            Close;
            if fDetail.RGFailtype.ItemIndex  =0 then // first fail
            begin
               if strgridDataGroup.Cells[0,iDrow]='0' then exit;
               commandtext:=strsql1;
            end;
            if fDetail.RGFailtype.ItemIndex =1 then // NTF fail
            begin
               if strgridDataGroup.Cells[0,iDrow]='0' then exit;
               commandtext:=strsql2;
            end;
            if fDetail.RGFailtype.ItemIndex =2 then // First_fail - NTF
            begin
               if strgridDataGroup.Cells[0,iDrow]='0' then exit;
               commandtext:=strsql3;
            end;
            params.ParamByName('starttime').AsString :=sstarttime;
            params.ParamByName('endtime').AsString :=sendtime;
            params.ParamByName('work_order').AsString :=strgridDataGroup.Cells[2,iDrow]  ;
            params.ParamByName('pdline_id').AsString :=g_pdlineid;
            params.ParamByName('process_id').AsString :=g_processid;
            params.ParamByName('defect_id').AsString :=g_defectid;
            Open;
            while not eof do
            begin
                IROW:=IROW+1;
                strgridDataSN.Cells[0,irow]:=fieldbyname('WORK_ORDER').asstring ;
                StrgriddataSN.Cells[1,irow]:=fieldbyname('PART_NO').AsString   ;
                StrgriddataSN.Cells[2,irow]:=fieldbyname('SERIAL_NUMBER').AsString   ;
                StrgriddataSN.Cells[3,irow]:=fieldbyname('PDLINE_NAME').AsString;
                strgridDataSN.Cells[4,irow]:=fieldbyname('PROCESS_NAME').asstring ;
                StrgriddataSN.Cells[5,irow]:=fieldbyname('DEFECT_CODE').AsString   ;
                StrgriddataSN.Cells[6,irow]:=fieldbyname('DEFECT_DESC').AsString;
                StrgriddataSN.Cells[7,irow]:=fieldbyname('REC_TIME').AsString;
                next;
                StrgriddataSN.RowCount:=IROW+1;
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
