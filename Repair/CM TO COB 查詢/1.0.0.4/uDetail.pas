unit uDetail;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids,DateUtils;

type
  TfDetail = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    lblLabTitle1: TLabel;
    lblLabTitle2: TLabel;
    sbtnQuery: TSpeedButton;
    ImageSample: TImage;
    sBtnExport: TSpeedButton;
    Image1: TImage;
    DataSource1: TDataSource;
    SaveDialog1: TSaveDialog;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    Label1: TLabel;
    Label3: TLabel;
    Label6: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Edit1: TEdit;
    StringGrid1: TStringGrid;
    Edt_ErrorDesc: TEdit;
    cbbProcess: TComboBox;
    Image2: TImage;
    SpeedButton1: TSpeedButton;
    Label5: TLabel;
    ComboBox1: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure sbtnQueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    iRow: integer;
    
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);



  end;

var
  fDetail: TfDetail;

implementation

{$R *.dfm}
uses uDllform,DllInit;



procedure TfDetail.FormShow(Sender: TObject);
var
  i,j:Integer;
begin
  for i:=0 to stringgrid1.RowCount   do
       for j:=0 to stringgrid1.ColCount  do
         stringgrid1.Cells[j,i]:='';

     stringgrid1.ColWidths[0]:=20 ;
     stringgrid1.ColWidths[1]:=100 ;
     stringgrid1.ColWidths[2]:=150 ;
     stringgrid1.ColWidths[3]:=100 ;
     stringgrid1.ColWidths[4]:=120 ;
     stringgrid1.ColWidths[5]:=120 ;
     stringgrid1.ColWidths[6]:=120;
     stringgrid1.ColWidths[7]:=80;
     stringgrid1.ColWidths[8]:=80 ;
     stringgrid1.ColWidths[9]:=80 ;

     stringgrid1.Cells[0,0]:=' ';
     stringgrid1.Cells[1,0]:='條碼';
     stringgrid1.Cells[2,0]:='不良現象';
     stringgrid1.Cells[3,0]:='D/B機' ;
     stringgrid1.Cells[4,0]:='日期時間' ;
     stringgrid1.Cells[5,0]:='H/M機' ;
     stringgrid1.Cells[6,0]:='日期時間' ;
     stringgrid1.Cells[7,0]:='人為' ;
     stringgrid1.Cells[8,0]:='線別' ;
     stringgrid1.Cells[9,0]:='站別' ;

     ComboBox1.ItemIndex:=1;
     iRow:=0;
end;

procedure TfDetail.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key<>#13 then Exit;
  sbtnQueryClick(nil);
end;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
var
  Sn,cSn:string;
  i:Integer;
  FpOpen: TextFile;
  S:string;
  FilePath:string;
  mType:string;
  ErrorDesc:string;
  Process_Name:string;
begin
    if Edit1.Text='' then Exit;
    cSn:=Edit1.Text;

    if Edt_ErrorDesc.Text<>'' then
      ErrorDesc:= Edt_ErrorDesc.Text
    else
      ErrorDesc:='';
      
    if cbbProcess.Text<>'' then
      Process_Name:= cbbProcess.Text
    else
      Process_Name:='';

    if ComboBox1.Text<>'' then
        mType:=ComboBox1.Text;


    for i :=0 to stringgrid1.RowCount -1  do
        if (stringgrid1.Cells[1,i]=cSn) and (cSn<>'') AND (stringgrid1.Cells[1,i]<>'') then  Exit;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'CSN',ptInput);

    QryTemp.CommandText:= 'select serial_Number from Sajet.g_sn_status where Customer_sn=:CSN or Serial_number=:CSN ';

    QryTemp.Params.ParamByName('CSN').AsString := cSn;
    QryTemp.Open;

    IF  NOT QryTemp.Eof then
    begin
       Sn:=QryTemp.FieldByName('Serial_number').AsString;
    end else begin
       Sn:='';
    end;

    if sn='' then Exit;

    iRow:=iRow+1;
    stringgrid1.RowCount:=iRow+1;
    Label3.Caption:= IntToStr(iRow);

    stringgrid1.Cells[0,iRow]:=IntToStr(iRow);
    stringgrid1.Cells[1,iRow]:=cSn;
    stringgrid1.Cells[7,iRow]:=mType;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'SN',ptInput);

    QryTemp.CommandText:= ' SELECT SERIAL_NUMBER,REC_TIME,PDLINE_NAME,PROCESS_NAME,DEFECT_CODE,DEFECT_DESC,TERMINAL_NAME ' +
                          ' FROM ( SELECT A.SERIAL_NUMBER,A.REC_TIME,D.PDLINE_NAME,B.PROCESS_NAME,C.DEFECT_CODE,C.DEFECT_DESC,E.TERMINAL_NAME ' +
                          ' FROM SAJET.G_SN_DEFECT A,sajet.sys_process B,SAJET.SYS_DEFECT C ,SAJET.SYS_PDLINE D ,SAJET.SYS_TERMINAL E' +
                          ' WHERE A.PROCESS_ID=B.PROCESS_ID AND A.DEFECT_ID=C.DEFECT_ID AND A.PDLINE_ID=D.PDLINE_ID AND SERIAL_NUMBER=:SN ' +
                          ' AND A.TERMINAL_ID=E.TERMINAL_ID ORDER BY REC_TIME DESC ) ' +
                          ' WHERE ROWNUM=1 ' ;
    QryTemp.Params.ParamByName('SN').AsString := Sn;
    QryTemp.Open;
    IF  NOT QryTemp.Eof then
    begin
       stringgrid1.Cells[2,iRow]:=QryTemp.FieldByName('DEFECT_DESC').AsString;
       stringgrid1.Cells[8,iRow]:=QryTemp.FieldByName('PDLINE_NAME').AsString;
       stringgrid1.Cells[9,iRow]:=QryTemp.FieldByName('TERMINAL_NAME').AsString;
    end;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'SN',ptInput);

    QryTemp.CommandText:= ' select A.Serial_number,A.PROCESS_ID,A.OUT_PROCESS_TIME,B.TERMINAL_NAME ' +
                          ' from SAJET.G_SN_TRAVEL A,SAJET.SYS_TERMINAL B ' +
                          ' WHERE A.TERMINAL_ID=B.TERMINAL_ID AND A.SERIAL_NUMBER=:SN  AND A.PROCESS_ID=100220 '  ;
    QryTemp.Params.ParamByName('SN').AsString := Sn;
    QryTemp.Open;
    IF  NOT QryTemp.Eof then
    begin
       stringgrid1.Cells[3,iRow]:=QryTemp.FieldByName('TERMINAL_NAME').AsString;
       stringgrid1.Cells[4,iRow]:=QryTemp.FieldByName('OUT_PROCESS_TIME').AsString;
    end;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'SN',ptInput);

    QryTemp.CommandText:= ' select A.Serial_number,A.PROCESS_ID,A.OUT_PROCESS_TIME,B.TERMINAL_NAME ' +
                          ' from SAJET.G_SN_TRAVEL A,SAJET.SYS_TERMINAL B ' +
                          ' WHERE A.TERMINAL_ID=B.TERMINAL_ID AND A.SERIAL_NUMBER=:SN  AND A.PROCESS_ID=100221 '  ;
    QryTemp.Params.ParamByName('SN').AsString := Sn;
    QryTemp.Open;
    IF  NOT QryTemp.Eof then
    begin
       stringgrid1.Cells[5,iRow]:=QryTemp.FieldByName('TERMINAL_NAME').AsString;
       stringgrid1.Cells[6,iRow]:=QryTemp.FieldByName('OUT_PROCESS_TIME').AsString;
    end;

  Edit1.SelectAll;
  Edit1.SetFocus;

end;

procedure TfDetail.sBtnExportClick(Sender: TObject);
var
  sFileName,My_FileName : String;
  MsExcel, MsExcelWorkBook : Variant;
begin
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'xls';
  SaveDialog1.Filter := 'All Files(*.xls)|*.xls';

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
         My_FileName:=ExtractFilePath(Application.ExeName) + ExtractFileName('Query.xlt');
         MsExcel := CreateOleObject('Excel.Application');
         MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);
         SaveExcel(MsExcel,MsExcelWorkBook);
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

procedure TfDetail.SpeedButton1Click(Sender: TObject);
var
  Sn,cSn:string;
  i:Integer;
  FpOpen: TextFile;
  S:string;
  FilePath:string;

begin
  //if Edit1.Text='' then Exit;
 // cSn:=Edit1.Text;
  Application.ProcessMessages;
  for i :=0 to stringgrid1.RowCount -1  do
    if (stringgrid1.Cells[1,i]=cSn) and (cSn<>'') AND (stringgrid1.Cells[1,i]<>'') then  Exit;

  FilePath:=ExtractFilePath(Application.ExeName) + 'SN.TXT';
  AssignFile(FpOpen, FilePath);
    Reset(FpOpen);//打開文件

    while not EOF(FpOpen)do begin
        Readln(FpOpen,S);//讀取一行文本
        if trim(S)<>'' THEN BEGIN
            cSn:=S;

            QryTemp.Close;
            QryTemp.Params.Clear;
            QryTemp.Params.CreateParam(ftstring,'CSN',ptInput);

            QryTemp.CommandText:= 'select serial_Number from Sajet.g_sn_status where Customer_sn=:CSN or Serial_number=:CSN ';

            QryTemp.Params.ParamByName('CSN').AsString := cSn;
            QryTemp.Open;

            IF  NOT QryTemp.Eof then
            begin
               Sn:=QryTemp.FieldByName('Serial_number').AsString;
            end else begin
               Sn:='';
            end;

            if sn='' then Exit;

            QryTemp.Close;
            QryTemp.Params.Clear;
            QryTemp.Params.CreateParam(ftstring,'SN',ptInput);

            QryTemp.CommandText:= ' SELECT SERIAL_NUMBER,REC_TIME,PDLINE_NAME,PROCESS_NAME,DEFECT_CODE,DEFECT_DESC ' +
                                  ' FROM ( SELECT A.SERIAL_NUMBER,A.REC_TIME,D.PDLINE_NAME,B.PROCESS_NAME,C.DEFECT_CODE,C.DEFECT_DESC FROM SAJET.G_SN_DEFECT A,sajet.sys_process B,SAJET.SYS_DEFECT C ,SAJET.SYS_PDLINE D ' +
                                  ' WHERE A.PROCESS_ID=B.PROCESS_ID AND A.DEFECT_ID=C.DEFECT_ID AND A.PDLINE_ID=D.PDLINE_ID AND SERIAL_NUMBER=:SN ' +
                                  ' ORDER BY REC_TIME DESC ) ' +
                                  ' WHERE ROWNUM=1 ' ;
            QryTemp.Params.ParamByName('SN').AsString := Sn;
            QryTemp.Open;
            IF  NOT QryTemp.Eof then
            begin
               iRow:=iRow+1;
               stringgrid1.RowCount:=iRow+1;
               Label3.Caption:= IntToStr(iRow);
               stringgrid1.Cells[0,iRow]:=IntToStr(iRow);
               stringgrid1.Cells[1,iRow]:=cSn;
               stringgrid1.Cells[2,iRow]:=QryTemp.FieldByName('DEFECT_DESC').AsString;
               stringgrid1.Cells[8,iRow]:=QryTemp.FieldByName('PROCESS_NAME').AsString;
            end else BEGIN
               iRow:=iRow+1;
               Label3.Caption:= IntToStr(iRow);
               stringgrid1.Cells[0,iRow]:=IntToStr(iRow);
               stringgrid1.RowCount:=iRow+1;
               stringgrid1.Cells[1,iRow]:=cSn;
            end;

            QryTemp.Close;
            QryTemp.Params.Clear;
            QryTemp.Params.CreateParam(ftstring,'SN',ptInput);

            QryTemp.CommandText:= ' select A.Serial_number,A.PROCESS_ID,A.OUT_PROCESS_TIME,B.TERMINAL_NAME ' +
                                  ' from SAJET.G_SN_TRAVEL A,SAJET.SYS_TERMINAL B ' +
                                  ' WHERE A.TERMINAL_ID=B.TERMINAL_ID AND A.SERIAL_NUMBER=:SN AND A.PROCESS_ID=100220 '  ;
            QryTemp.Params.ParamByName('SN').AsString := Sn;
            QryTemp.Open;
            IF  NOT QryTemp.Eof then
            begin
               stringgrid1.Cells[3,iRow]:=QryTemp.FieldByName('TERMINAL_NAME').AsString;
               stringgrid1.Cells[4,iRow]:=QryTemp.FieldByName('OUT_PROCESS_TIME').AsString;
            end;

            QryTemp.Close;
            QryTemp.Params.Clear;
            QryTemp.Params.CreateParam(ftstring,'SN',ptInput);

            QryTemp.CommandText:= ' select A.Serial_number,A.PROCESS_ID,A.OUT_PROCESS_TIME,B.TERMINAL_NAME ' +
                                  ' from SAJET.G_SN_TRAVEL A,SAJET.SYS_TERMINAL B ' +
                                  ' WHERE A.TERMINAL_ID=B.TERMINAL_ID AND A.SERIAL_NUMBER=:SN AND A.PROCESS_ID=100221 '  ;
            QryTemp.Params.ParamByName('SN').AsString := Sn;
            QryTemp.Open;
            IF  NOT QryTemp.Eof then
            begin
               stringgrid1.Cells[5,iRow]:=QryTemp.FieldByName('TERMINAL_NAME').AsString;
               stringgrid1.Cells[6,iRow]:=QryTemp.FieldByName('OUT_PROCESS_TIME').AsString;
            end;
        end;
    end;
    CloseFile(FpOpen);

  //Edit1.SelectAll;
  //Edit1.SetFocus;

end;

procedure TfDetail.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var
    i,row:integer;
    icol,irow :integer;
begin

    i:=0;
    for irow :=0 to stringgrid1.RowCount -1  do
     begin
        if stringgrid1.Cells[1,irow]<>'' then begin
            MsExcel.ActiveSheet.range[char(65)+inttostr(irow+1)]:=stringgrid1.Cells[1,irow];
            MsExcel.ActiveSheet.range[CHAR(66)+inttostr(irow+1)]:=stringgrid1.Cells[2,irow];
            MsExcel.ActiveSheet.range[char(67)+inttostr(irow+1)]:=stringgrid1.Cells[3,irow];
            MsExcel.ActiveSheet.range[char(68)+inttostr(irow+1)]:=stringgrid1.Cells[4,irow];
            MsExcel.ActiveSheet.range[char(69)+inttostr(irow+1)]:=stringgrid1.Cells[5,irow];
            MsExcel.ActiveSheet.range[char(70)+inttostr(irow+1)]:=stringgrid1.Cells[6,irow];
            MsExcel.ActiveSheet.range[char(71)+inttostr(irow+1)]:=stringgrid1.Cells[7,irow];
            MsExcel.ActiveSheet.range[char(72)+inttostr(irow+1)]:=stringgrid1.Cells[8,irow];
            MsExcel.ActiveSheet.range[char(73)+inttostr(irow+1)]:=stringgrid1.Cells[9,irow];
            inc(i);
        end;
     end;

end;

end.
