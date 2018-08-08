unit uExport;

interface

uses
   Windows, Messages, SysUtils, Classes, ActiveX,comobj,Forms,Dialogs,Variants;

type
  //==========================
  TExpThread=class(TThread)
  private
    { Private declarations }
  public
    { Public declarations }

  protected
    procedure Execute; override;
  end;
  TPrtThread=class(TThread)
  private
    { Private declarations }
  public
    { Public declarations }
    Function  SaveExcel(MsExcel, MsExcelWorkBook: Variant) :Boolean;
    Function  OccurExcept(MsExcel, MsExcelWorkBook: Variant; sBl :Boolean) :Boolean;
  protected
    procedure Execute; override;
  end;
  //==========================
var
   ExpThread:TExpThread;
   PrtThread:TPrtThread;

implementation

uses uMainForm;

procedure TExpThread.Execute;
var
  sFileName : String;
  MsExcel, MsExcelWorkBook : Variant;
begin
  inherited;
  CoInitialize(nil);
  fMainForm.SaveDialog1.InitialDir := ExtractFilePath(Application.ExeName);
  fMainForm.SaveDialog1.DefaultExt := 'xls';
  fMainForm.SaveDialog1.Filter := 'All Files(*.xls)|*.xls';
  if fMainForm.SaveDialog1.Execute then
  begin
    try
      sFileName := fMainForm.SaveDialog1.FileName;
      //Delete First if Exist
      if FileExists(sFileName) then
      begin
        If messagebox(fMainForm.Handle,'File has exist! Replace or Not ?','',mb_OkCancel) = idOK Then
        begin
          if not DeleteFile(sFileName) then
          begin
            CoUninitialize;
            fMainForm.ButtonStatus(True);
            messagebox(fMainForm.Handle,'Delete File Fail.','',mb_ok);
            exit;
          end;
        end else
        begin
          CoUninitialize;
          fMainForm.ButtonStatus(True);
          exit;
        end;
      end;
      fMainForm.ProgressBar1.Progress:=0;
      fMainForm.ButtonStatus(False);
      Try
        MsExcel := CreateOleObject('Excel.Application');
        MsExcelWorkBook := MsExcel.WorkBooks.add;
        MsExcel.Worksheets['Sheet1'].select;
        if not PrtThread.SaveExcel(MsExcel,MsExcelWorkBook) then
        begin
          PrtThread.OccurExcept(MsExcel,MsExcelWorkBook,True);
          CoUninitialize;
          messagebox(fMainForm.Handle,'SaveExcel Fail.','',mb_ok);
          exit;
        end;
      Except
        PrtThread.OccurExcept(MsExcel,MsExcelWorkBook,True);
        CoUninitialize;
        messagebox(fMainForm.Handle,'Initial Excel Fail.','',mb_ok);
        exit;
      end;
      MsExcelWorkBook.SaveAs(sFileName);
      messagebox(fMainForm.Handle,'Save Excel OK!!','',mb_ok);
    Except
      messagebox(fMainForm.Handle,'Could not start Microsoft Excel.','',mb_ok);
    end;
    MsExcelWorkBook.close;
    MsExcelWorkBook:=Null;
    MsExcel.Application.Quit;
    MsExcel:=Null;
  end;
  fMainForm.ButtonStatus(True);
  CoUninitialize;
end;

procedure TPrtThread.Execute;
var
  MsExcel, MsExcelWorkBook : Variant;
begin
  inherited;
  CoInitialize(nil);
  try
    fMainForm.ProgressBar1.Progress:=0;
    fMainForm.ButtonStatus(False);
    MsExcel := CreateOleObject('Excel.Application');
    MsExcelWorkBook := MsExcel.WorkBooks.add;
    MsExcel.Worksheets['Sheet1'].select;
    if not SaveExcel(MsExcel,MsExcelWorkBook) then
    begin
      OccurExcept(MsExcel,MsExcelWorkBook,True);
      CoUninitialize;
      messagebox(fMainForm.Handle,'Print Fail.','',mb_ok);
      exit;
    end;
    MsExcel.Visible:=TRUE;
    Try
      MsExcel.Worksheets['Sheet1'].select;
      MsExcel.WorkSheets['Sheet1'].PrintPreview;
    Except
    End;
    fMainForm.WindowState:=wsMaximized;
  Except
    messagebox(fMainForm.Handle,'Could not start Microsoft Excel.','',mb_ok);
  end;
  MsExcelWorkBook.close;
  MsExcelWorkBook:=Null;
  MsExcel.Application.Quit;
  MsExcel:=Null;
  fMainForm.ButtonStatus(True);
  CoUninitialize;
end;

Function  TPrtThread.SaveExcel(MsExcel, MsExcelWorkBook: Variant) :Boolean;
Var i,j : Integer;
begin
  Result:=False;
  With fMainForm do
  begin
    QryTemp.DisableControls;
    for i := 0 to DBGrid1.Columns.Count - 1 do
      MsExcel.Worksheets['Sheet1'].Range[Chr(i+65)+'1'].Value:= DBGrid1.Columns[i].Title.Caption;
    QryTemp.First;
    for i:= 0 to QryTemp.RecordCount - 1 do
    begin
      for j:= 0 to DBGrid1.Columns.Count - 1  do
         MsExcel.Worksheets['Sheet1'].Range[Chr(j+65)+IntToStr(i+2)].Value := QryTemp.Fields.Fields[J].AsString ;
      QryTemp.Next;
      ProgressBar1.Progress:=Round((i+1) / QryTemp.RecordCount * 100);
    end;
    QryTemp.EnableControls;
  end;
  Result:=True;
end;

Function  TPrtThread.OccurExcept(MsExcel, MsExcelWorkBook: Variant; sBl :Boolean) :Boolean;
begin
  Result:=False;
  fMainForm.ButtonStatus(sBl);
  MsExcelWorkBook.close;
  MsExcelWorkBook:=Null;
  MsExcel.Application.Quit;
  MsExcel:=Null;
  Result:=True;
end;

end.

