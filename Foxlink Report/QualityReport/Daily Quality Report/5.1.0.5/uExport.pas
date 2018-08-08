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
   sslst:Tstrings;
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
    Function  GetCol(ainteger:integer): string;
    Procedure GetArea(ss:Tstringlist;var slt:Tstringlist);
    Function  Getlst(ss:Tstringlist;slt:integer):integer;
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
        MsExcelWorkBook := MsExcel.WorkBooks.open(ExtractFilePath(Application.ExeName)+'DailyPQualityReport.XLT');
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
      MsExcelWorkBook.close(False);
      MsExcelWorkBook:=Null;
      MsExcel.Application.Quit;
      MsExcel:=Null;
      messagebox(fMainForm.Handle,'Save Excel OK!!','',mb_ok);
    Except
      messagebox(fMainForm.Handle,'Could not start Microsoft Excel.','',mb_ok);
    end;  
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
    MsExcelWorkBook := MsExcel.WorkBooks.open(ExtractFilePath(Application.ExeName)+'DailyPQualityReport.XLT');
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
  MsExcelWorkBook.close(False);
  MsExcelWorkBook:=Null;
  MsExcel.Application.Quit;
  MsExcel:=Null;
  fMainForm.ButtonStatus(True);
  CoUninitialize;
end;

Function  TPrtThread.SaveExcel(MsExcel, MsExcelWorkBook: Variant) :Boolean;
Var i,j,n,k,m,p,q,r,s,d_sum : Integer;
   abc:variant;
   stagenum:tstringlist;
begin
  Result:=False;
  s:=0;
  stagenum:=tstringlist.Create;
  With fMainForm do
  begin
  MsExcel.Worksheets['Sheet1'].Range['B1'].value:='Module :'+ editmodel.Text+ ' Daily Quality Report';
  //**************確定列的數量********
      if sgdata.ColCount-3>30 then
        begin
         for i:=1 to sgdata.ColCount-33 do
          begin
           MsExcel.Worksheets['Sheet1'].Columns[36].insert;
           //MsExcel.Worksheets['Sheet1'].range['G3:G15'].copy;
           //MsExcel.Worksheets['Sheet1'].range['AJ3'].pastespecial;
          end;
        end
      else
       begin
        for i:=1 to 30-(sgdata.ColCount-3)  do
          begin
           MsExcel.Worksheets['Sheet1'].Columns[7].delete;
          end;
       end;
     for i:=1 to sgdata.ColCount-3 do
        begin
         MsExcel.Worksheets['Sheet1'].Range[getcol(5+i)+'3'].value:=sgdata.Cells[2+i,0];
         //messagebox(handle,pchar(sgdata.Cells[2+i,0]),'',mb_ok);
      end;
  //*****************確定defect行的數量*********
  if  G_DefectCnt= 0 then G_DefectCnt:=1;
    if G_DefectCnt>3 then
      begin
       for i:=1 to G_DefectCnt-3 do
         begin
          MsExcel.Worksheets['Sheet1'].rows[10].insert;
         end;
      end
      else
        begin
          for i:=1 to 3-G_DefectCnt do
           begin
            MsExcel.Worksheets['Sheet1'].rows[10].delete;
           end;
        end;
        MsExcel.Worksheets['Sheet1'].range['B9:B'+inttostr(8+G_DefectCnt)].Merge(abc);
    Getarea(stagelst,stagenum);
   //*******************
    for n:=1 to stagenum.Count do
     begin
        for i:=1 to (5+G_DefectCnt+2) do
          begin
           MsExcel.Worksheets['Sheet1'].Rows[n*(5+G_DefectCnt+2)+4].insert;
          end;
    MsExcel.Worksheets['Sheet1'].range['A4:'+getcol(sgdata.ColCount+2)+inttostr(8+G_DefectCnt+2)].copy;
    MsExcel.Worksheets['Sheet1'].range['A'+inttostr(n*(5+G_DefectCnt+2)+4)].pastespecial;
     end;
     for i:=3 to yieldgrid.ColCount do
        for j:=1 to stagenum.Count do
         begin
           MsExcel.Worksheets['Sheet1'].range[getcol(3+i)+inttostr((j+1)*(5+G_DefectCnt+2)+3)]:=yieldgrid.Cells[i,j+1];
           if yieldgrid.Cells[i,1]<>'' then
            MsExcel.Worksheets['Sheet1'].range[getcol(3+i)+inttostr((stagenum.Count+1)*(5+G_DefectCnt+2)+3+2)]:=Floattostrf(StrToFloatDef(yieldgrid.Cells[i,1],100)/100,ffFixed, 6, 2);
         end;
    //*******************畫表格*****************************
    for n:=stagenum.Count downto 1 do
     begin
            for k:=1 to strtoint(stagenum.Strings[n-1]) do
              begin
                 if k>1 then
                    begin
                      for i:=1 to 5+G_DefectCnt do
                        begin
                        MsExcel.Worksheets['Sheet1'].Rows[(n)*(5+G_DefectCnt+2)+4].insert;
                        end;
                        MsExcel.Worksheets['Sheet1'].range['A4:'+getcol(sgdata.ColCount+2)+inttostr(8+G_DefectCnt)].copy;
                        MsExcel.Worksheets['Sheet1'].range['A'+inttostr((n)*(5+G_DefectCnt+2)+4)].pastespecial;
                    end;
                 r:=0;
                  if s=0 then
                   begin
                   for i:=1 to sgdata.RowCount-1 do
                             begin
                               if sgdata.Cells[2,i]=lstprocess.Strings[lstprocess.Count-1-s] then
                                 begin
                                  p:=i;
                                  break;
                                 end;
                             end;
                     r:=sgdata.RowCount-p
                    end
                    else
                     begin
                        for i:=1 to sgdata.RowCount-1 do
                                 begin
                                   if sgdata.Cells[2,i]=lstprocess.Strings[lstprocess.Count-s] then
                                     begin
                                      q:=i;
                                      break;
                                     end;
                                 end;
                         for i:=1 to sgdata.RowCount-1 do
                           begin
                             if sgdata.Cells[2,i]=lstprocess.Strings[lstprocess.Count-s-1] then
                              begin
                                p:=i;
                                break;
                              end;
                            end;
                           r:=q-p;//相鄰兩process的距離
                    end;
                     //messagebox(handle,pchar(inttostr(r)),'',mb_ok);
                     MsExcel.Worksheets['Sheet1'].range['B'+inttostr((n)*(5+G_DefectCnt+2)+3+1)].value:=sgdata.Cells[2,p];
                     for i:=1 to 5 do
                        begin
                          MsExcel.Worksheets['Sheet1'].range['C'+inttostr((n)*(5+G_DefectCnt+2)+3+i)]:=sgdata.Cells[2,p+i];
                          //messagebox(handle,pchar(sgdata.Cells[2,p+i]),'',mb_ok);
                        end;
                    for i:=1 to 6+G_DefectCnt-r do
                     begin
                         MsExcel.Worksheets['Sheet1'].Rows[(n)*(5+G_DefectCnt+2)+3+6].delete;
                     end;
                     for i:=1 to r-6 do
                        begin
                         MsExcel.Worksheets['Sheet1'].range['C'+inttostr((n)*(5+G_DefectCnt+2)+3+5+i)]:=i;
                         MsExcel.Worksheets['Sheet1'].range['D'+inttostr((n)*(5+G_DefectCnt+2)+3+5+i)]:=sgdata.Cells[2,p+5+i];
                          D_sum:=0;
                          for j:=3 to sgdata.ColCount  do
                           begin 
                             if  sgdata.Cells[j,p+5+i]<>'' then
                              D_sum:=D_sum+strtoint(sgdata.Cells[j,p+5+i]);
                           end;
                         MsExcel.Worksheets['Sheet1'].range['F'+inttostr((n)*(5+G_DefectCnt+2)+3+5+i)]:=D_sum;
                        end;
                       for i:=0 to r-2 do
                         begin
                           for j:=3 to sgdata.ColCount do
                             begin
                                MsExcel.Worksheets['Sheet1'].range[getcol(j+3)+inttostr((n)*(5+G_DefectCnt+2)+3+1+i)]:=sgdata.Cells[j,p+i+1];
                             end;
                         end;
                         inc(s);
                         progressbar1.Progress:=round(s/(lstprocess.Count-1)*100);
          end;
          //MsExcel.Worksheets['Sheet1'].range['A'+inttostr((n-1)*(5+G_DefectCnt+2)+3+1)+':'+getcol(sgdata.ColCount+2)+inttostr((n-1)*(5+G_DefectCnt+2)+8+G_DefectCnt)].delete;
         // break;
          //m:=(n-1)*(5+G_DefectCnt+2)+3+5*strtoint(stagenum.Strings[n-1])+G_DefectCnt+2;
          //MsExcel.Worksheets['Sheet1'].range['A'+inttostr((n-1)*(5+G_DefectCnt+2)+3+1)+':A'+inttostr(m)].merge(abc);
          //MsExcel.Worksheets['Sheet1'].range['A'+inttostr((n-1)*(5+G_DefectCnt+2)+3+1)].value:=processlst.Strings[n-1];
       //**********************
   r:=0;
     if n=stagenum.Count then
      begin
       for i:=1 to sgdata.RowCount-1 do
                begin
                 if sgdata.Cells[1,i]=processlst.Strings[n-1] then
                   begin
                    p:=i;
                    break;
                   end;
                end;
          r:=sgdata.RowCount-p;
       end
      else
      begin
       for i:=1 to sgdata.RowCount-1 do
                begin
                 if sgdata.Cells[1,i]=processlst.Strings[n] then
                   begin
                    q:=i;
                    break;
                   end;
                end;
       for i:=1 to sgdata.RowCount-1 do
         begin
           if sgdata.Cells[1,i]=processlst.Strings[n-1] then
            begin
              p:=i;
              break;
            end;
          end;
         r:=q-p; //相鄰stage的距離
       end;
     m:=0;
     m:=(n)*(5+G_DefectCnt+2)+3+r-strtoint(stagenum.Strings[n-1]);
     MsExcel.Worksheets['Sheet1'].range['A'+inttostr((n)*(5+G_DefectCnt+2)+3+1)+':A'+inttostr(m+2)].merge(abc);
     MsExcel.Worksheets['Sheet1'].range['A'+inttostr((n)*(5+G_DefectCnt+2)+3+1)]:=processlst.Strings[n-1];
    end;
     for i:=1 to 5+G_DefectCnt+2 do
       begin
         MsExcel.Worksheets['Sheet1'].rows[4].delete;
       end;
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

Function  TPrtThread.Getcol(ainteger:integer):string;
var
  s:string;
  i:integer;
begin
   for  i:=1 to (ainteger div 26) do
    begin
     s:=s+'A';
    end;
    if length(s)>0 then
      result:=chr(64+length(s))+chr(65+(ainteger mod 26))
    else
      result:=chr(65+(ainteger mod 26));
end;

Procedure TPrtThread.GetArea(ss:Tstringlist;var slt:Tstringlist);
var
  i,j:integer;
begin
  slt:=tstringlist.Create;
  ss.Add('%%%%%%%%%%');
   for i:=0 to ss.Count-2 do
    begin
     if ss.Strings[i]=ss.Strings[i+1] then
          j:=j+1
     else
      begin
       slt.Add(inttostr(j+1));
        j:=0;
      end;
    end;
 end;
Function TPrtThread.Getlst(ss:Tstringlist;slt:integer):integer;
 var i:integer;
begin
  result:=0;
  for i:= 0 to slt do
   begin
    result:= result+strtoint(ss.strings[i]);
   end;
end;
end.

