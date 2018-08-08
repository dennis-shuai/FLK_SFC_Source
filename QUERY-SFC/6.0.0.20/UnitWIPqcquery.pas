unit UnitWIPqcquery;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DB, DBClient;

type
  TFormWIPQCQuery = class(TForm)
    Label1: TLabel;
    GroupBox1: TGroupBox;
    CMBTYPE: TComboBox;
    EditTYPE: TEdit;
    Label2: TLabel;
    BTNQUERY: TButton;
    BTNCLOSE: TButton;
    StringgridQC: TStringGrid;
    Label3: TLabel;
    lblrecordcount: TLabel;
    ClientDataSetqc: TClientDataSet;
    labltotal: TLabel;
    EditTotal: TEdit;
    procedure cleardata;
    procedure QUERYQCBYWORKORDER(STRSQL: STRING);
    procedure QUERYQCBYqclotno(STRSQL: STRING);
    procedure QUERYQCBYqctype(STRSQL: STRING);
    procedure BTNCLOSEClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BTNQUERYClick(Sender: TObject);
    procedure EditTYPEKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormWIPQCQuery: TFormWIPQCQuery;
  icol,irow:integer;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormWIPQCQuery.cleardata;
 begin
    edittype.Clear ;
    edittype.SetFocus ;
    with stringgridqc do
       begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=10;
           ColCount  :=9;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           lblrecordcount.Caption :='';
    
      end;
end;

procedure TFormWIPQCQuery.QUERYQCBYWORKORDER(STRSQL: STRING);
begin
   with clientdatasetqc do
      begin
          close;
          commandtext:='select  A.WORK_ORDER, A.QC_LOTNO ,A.START_TIME,A.LOT_SIZE,A.SAMPLING_SIZE,A.PASS_QTY,A.FAIL_QTY ,A.QC_TYPE , '
                     +' B.PDLINE_NAME,C.STAGE_NAME,D.PROCESS_NAME,E.EMP_NAME  '
                     +' from  sajet.g_qc_lot  A,sajet.SYS_PDLINE B,sajet.SYS_STAGE C,sajet.SYS_PROCESS D,sajet.SYS_EMP E   '
                     +' WHERE A.PDLINE_ID=B.PDLINE_ID AND A.STAGE_ID=C.STAGE_ID AND A.PROCESS_ID=D.PROCESS_ID AND A.INSP_EMPID=E.EMP_ID    '
                     +' and work_order=:work_order' ;
          params.parambyname('work_order').AsString :=strsql;
          open;

          lblrecordcount.Caption :=inttostr(recordcount);
          edittotal.Text :='0';

            if recordcount=0 then
               begin
                 cleardata  ;
                 exit;
               end;

           stringgridqc.RowCount :=recordcount+1;
           stringgridqc.ColCount :=fields.Count ;

           for irow:=0 to fieldcount-1 do
             begin
                stringgridqc.Cells[irow,0]:=fields[irow].FieldName ;
             end;

            first;
            for icol:=1 to recordcount do
              begin
                for irow:=1 to fieldcount do
                  begin
                     stringgridqc.Cells[irow-1,icol]:=fields[irow-1].AsString ;
                  end;
               edittotal.Text :=inttostr(strtoint(edittotal.Text)+strtoint(fields[3].asstring)) ;
               next ;
             end;

      end;
end;

procedure TFormWIPQCQuery.QUERYQCBYqclotno(STRSQL: STRING);
begin
   with clientdatasetqc do
      begin
          close;
          commandtext:='select  A.WORK_ORDER, A.QC_LOTNO ,A.START_TIME,A.LOT_SIZE,A.SAMPLING_SIZE,A.PASS_QTY,A.FAIL_QTY ,A.QC_TYPE , '
                     +' B.PDLINE_NAME,C.STAGE_NAME,D.PROCESS_NAME,E.EMP_NAME  '
                     +' from  sajet.g_qc_lot  A,sajet.SYS_PDLINE B,sajet.SYS_STAGE C,sajet.SYS_PROCESS D,sajet.SYS_EMP E   '
                     +' WHERE A.PDLINE_ID=B.PDLINE_ID AND A.STAGE_ID=C.STAGE_ID AND A.PROCESS_ID=D.PROCESS_ID AND A.INSP_EMPID=E.EMP_ID    '
                     +' and a.qc_lotno=:qc_lotno' ;
          params.parambyname('qc_lotno').AsString :=strsql;
          open;

          lblrecordcount.Caption :=inttostr(recordcount);
          edittotal.Text :='0';

          if recordcount=0 then
               begin
                 cleardata  ;
                 exit;
               end;

          stringgridqc.RowCount :=recordcount+1;
          stringgridqc.ColCount :=fields.Count ;

           for irow:=0 to fieldcount-1 do
             begin
                stringgridqc.Cells[irow,0]:=fields[irow].FieldName ;
             end;


            stringgridqc.RowCount :=recordcount+1;
            first;
            for icol:=1 to recordcount do
              begin
                for irow:=1 to fieldcount do
                  begin
                     stringgridqc.Cells[irow-1,icol]:=fields[irow-1].AsString ;
                  end;
               edittotal.Text :=inttostr(strtoint(edittotal.Text)+strtoint(fields[3].asstring)) ;
               next ;
             end;
      end;
end;

procedure TFormWIPQCQuery.QUERYQCBYqctype(STRSQL: STRING);
begin
   with clientdatasetqc do
      begin
          close;
          commandtext:='select  A.WORK_ORDER, A.QC_LOTNO ,A.START_TIME,A.LOT_SIZE,A.SAMPLING_SIZE,A.PASS_QTY,A.FAIL_QTY ,A.QC_TYPE , '
                     +' B.PDLINE_NAME,C.STAGE_NAME,D.PROCESS_NAME,E.EMP_NAME  '
                     +' from  sajet.g_qc_lot  A,sajet.SYS_PDLINE B,sajet.SYS_STAGE C,sajet.SYS_PROCESS D,sajet.SYS_EMP E   '
                     +' WHERE A.PDLINE_ID=B.PDLINE_ID AND A.STAGE_ID=C.STAGE_ID AND A.PROCESS_ID=D.PROCESS_ID AND A.INSP_EMPID=E.EMP_ID    '
                     +' and a.qc_type=:qc_type' ;
          params.parambyname('qc_type').AsString :=strsql;
          open;

          lblrecordcount.Caption :=inttostr(recordcount);
          //labltotal.Caption :=inttostr(recordcount);

           if recordcount=0 then
               begin
                 cleardata  ;
                 exit;
               end;

          stringgridqc.RowCount :=recordcount+1;
          stringgridqc.ColCount :=fields.Count ;

           for irow:=0 to fieldcount-1 do
             begin
                stringgridqc.Cells[irow,0]:=fields[irow].FieldName ;
             end;

            stringgridqc.RowCount :=recordcount+1;
            first;
            for icol:=1 to recordcount do
              begin
                for irow:=1 to fieldcount do
                  begin
                     stringgridqc.Cells[irow-1,icol]:=fields[irow-1].AsString ;
                  end;
                  next ;
             end;

      end;
end;

procedure TFormWIPQCQuery.BTNCLOSEClick(Sender: TObject);
begin
   close;
end;

procedure TFormWIPQCQuery.FormShow(Sender: TObject);
begin
   clientdatasetqc.RemoteServer :=formmain.socketconnection1;
   clientdatasetqc.ProviderName :=formmain.Clientdataset1.ProviderName ;

    cleardata;
end;

procedure TFormWIPQCQuery.BTNQUERYClick(Sender: TObject);
begin
    if trim(edittype.Text)<>'' then
      begin
           if cmbtype.Text ='Work_Order' then
              BEGIN
                 QUERYQCBYWORKORDER(TRIM(EDITTYPE.Text));
                 edittype.SetFocus ;
              END;
           IF CMBTYPE.Text ='QC LOT_NO' Then
              begin
                 QUERYQCBYQCLOTNO(TRIM(EDITTYPE.Text));
                 edittype.SetFocus ;
              end;
           if cmbtype.Text ='QC QTY_ID'  THEN
              if copy(trim(edittype.text),0,1)='Q'  then
                 begin
                    QUERYQCBYQCTYPE(TRIM(EDITTYPE.Text)) ;
                    edittype.SetFocus;
                 end
              ELSE
                 CLEARDATA;

      end;

end;

procedure TFormWIPQCQuery.EditTYPEKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if key=13 then
     begin
        if trim(edittype.Text)<>'' then
            begin
                 if cmbtype.Text ='Work_Order' then
                     BEGIN
                           QUERYQCBYWORKORDER(TRIM(EDITTYPE.Text));
                           edittype.SelectAll  ;
                     END;
                 IF CMBTYPE.Text ='QC LOT_NO' Then
                     begin
                           QUERYQCBYQCLOTNO(TRIM(EDITTYPE.Text));
                           edittype.SelectAll  ;
                     end;
                 if cmbtype.Text ='QC QTY_ID'  THEN
                 if copy(trim(edittype.text),0,1)='Q'  then
                      begin
                            QUERYQCBYQCTYPE(TRIM(EDITTYPE.Text)) ;
                            edittype.SelectAll ;
                      end
                      ELSE
                         CLEARDATA;

      end;
     end;
end;

end.
