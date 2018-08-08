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
    Function  Getcol(ainteger:integer):string;
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
        MsExcelWorkBook := MsExcel.WorkBooks.open(ExtractFilePath(Application.ExeName)+'WeeklyPQualityReport.xlt');
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
    MsExcelWorkBook := MsExcel.WorkBooks.open(ExtractFilePath(Application.ExeName)+'WeeklyPQualityReport.xlt');
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
Var
i,j,k ,l,n,p,q: Integer;
d_count,w_count :integer;
aaa,bbb,ccc:string;
begin
  j:=0;  //process的當前個數；
  k:=0;  //當前process在stringgrid中的行位置；
  q:=0;  //相鄰兩個process在stringgrid中相差的行數；
  Result:=False;
  With fMainForm do
  begin
     d_count:=strtoint(comtoplevel.Text);
     w_count:=sgdata.ColCount-2;
//**(列)
     if w_count>14 then
     for i:=1 to w_count-14 do
       begin
         MsExcel.Worksheets['Sheet1'].columns[14+i].insert;
       end;
   for i:=1 to sgdata.ColCount-2 do
       begin
         MsExcel.Worksheets['Sheet1'].range[getcol(i)+'4'].value:=sgdata.Cells[i+1,0];
       end;
//*************寫入表頭的列值************ ********
 MsExcel.Worksheets['Sheet1'].range['A2'].value:=editmodel.Text+' Quality Weekly Report';
    if sgdata.ColCount-2>5 then
    begin
     for i:=1 to sgdata.ColCount-7 do
      begin
       MsExcel.Worksheets['Sheet1'].Range[getcol(4+i)+'17:'+getcol(5+i)+'21'].Copy;
       MsExcel.Worksheets['Sheet1'].Range[getcol(5+i)+'17'].PasteSpecial;
      end;
    end;
//***(行)
  if processlst.Count<2 then
    begin
     MsExcel.Worksheets['Sheet1'].Rows[19].delete;
     MsExcel.Worksheets['Sheet1'].Range['A18'].value:=processlst.Strings[0];
    end
  else
   BEGIN
     MsExcel.Worksheets['Sheet1'].Range['A18'].value:=processlst.Strings[0];
     for i:=0 to processlst.Count-3 do
       begin
        //MsExcel.Worksheets['Sheet1'].Range['A19'].value:=processlst.Strings[1];
        MsExcel.Worksheets['Sheet1'].Rows[19+i].insert;
        MsExcel.Worksheets['Sheet1'].Range['A'+inttostr(19+i)].value:=processlst.Strings[i+1];
       end;
    MsExcel.Worksheets['Sheet1'].Range['A'+inttostr(17+processlst.Count)].value:=processlst.Strings[processlst.Count-1];
   END;
//****************************************
     //************不良的個數***********************
  if d_count>3 then
        for i:=0 to d_count-4 do
          begin
            MsExcel.Worksheets['Sheet1'].Rows[13+i].insert;
          end
     else
        for i:=0 downto d_count-2 do
            begin
             MsExcel.Worksheets['Sheet1'].Rows[13+i].delete;
            end;
//*********************
for n:=0 to processlst.Count-1 do
      begin
       aaa:=processlst.Strings[n];
        for i:=0 to sgData.RowCount-1 do
         begin
           if trim(sgdata.Cells[1,i])=aaa then
            begin
             k:=i;
             j:=j+1;
             break;
            end;
          end;
             if j>1 then
                begin
                for i:=0 to 7+d_count do
                 begin
                   MsExcel.Worksheets['Sheet1'].Rows[inttostr((j-1)*(8+d_count)+3)].insert;
                 end;
                  if w_count<=12 then
                    MsExcel.Worksheets['Sheet1'].range['A4:P'+inttostr(11+d_count)].copy
                  else
                    MsExcel.Worksheets['Sheet1'].range['A4:'+getcol(w_count+1)+inttostr(11+d_count)].copy;
                 MsExcel.Worksheets['Sheet1'].range['A'+inttostr((j-1)*(8+d_count)+4)].PasteSpecial;
                end;
//******************填寫表中的數據***********************
              MsExcel.Worksheets['Sheet1'].range['A'+inttostr((j-1)*(8+d_count)+4)].value:=aaa;
              for l:=1 to sgdata.ColCount-2 do
                begin
                   //MsExcel.Worksheets['Sheet1'].range['A'+inttostr((j-1)*(8+d_count)+10)]:=sgdata.Cells[l+1,0];
                  //******填寫各個process的良率*****
                    if  sgdata.Cells[l+1,0]<>'' then
                     begin
                      MsExcel.Worksheets['Sheet1'].range[getcol(l)+inttostr((j-1)*(8+d_count)+10+d_count+4)]:=sgdata.Cells[l+1,0];
                      MsExcel.Worksheets['Sheet1'].range[getcol(l)+inttostr((j-1)*(8+d_count)+10+d_count+4+j)]:=sgdata.Cells[l+1,k+5];
                     end;
             for i:=1 to 5 do
                   begin
                      //****填寫input,defect等數據****
                    MsExcel.Worksheets['Sheet1'].range[getcol(l)+inttostr((j-1)*(8+d_count)+4+i)]:=sgdata.Cells[l+1,k+i];
                    //ProgressBar1.Progress:=Round(((l-1)*5+i)/((sgdata.ColCount-2)*(sgdata.RowCount-1-processlst.Count)));
                   end;
                   //******填寫不良現象的相關數據*******
                   for i:=1 to d_count do
                    begin
                            MsExcel.Worksheets['Sheet1'].range['B'+inttostr((j-1)*(8+d_count)+10+i)]:='';
                            MsExcel.Worksheets['Sheet1'].range['C'+inttostr((j-1)*(8+d_count)+10+i)]:='';
                            MsExcel.Worksheets['Sheet1'].range['F'+inttostr((j-1)*(8+d_count)+10+i)]:='';
                            MsExcel.Worksheets['Sheet1'].range['E'+inttostr((j-1)*(8+d_count)+10+i)]:='';
                            MsExcel.Worksheets['Sheet1'].range['D'+inttostr((j-1)*(8+d_count)+10+i)]:='';
                    end;
                   if n<processlst.Count-1 then
                    begin
                       bbb:=processlst.Strings[n+1];
                         for p:=0 to sgData.RowCount-1 do
                       begin
                         if trim(sgdata.Cells[1,p])=bbb then
                          begin
                           q:=p-k;
                           break;
                          end;
                        end;
                     end
                     else
                        q:=sgdata.RowCount-k+1;
                     if q>6 then
                     begin
                        for p:=1 to q-6 do
                          begin
                            MsExcel.Worksheets['Sheet1'].range['A'+inttostr((j-1)*(8+d_count)+10+p)]:=sgdata.Cells[1,k+5+p];
                            MsExcel.Worksheets['Sheet1'].range['B'+inttostr((j-1)*(8+d_count)+10+p)]:=sgdata.Cells[2,k+5+p];
                            MsExcel.Worksheets['Sheet1'].range['C'+inttostr((j-1)*(8+d_count)+10+p)]:=sgdata.Cells[3,k+5+p];
                            MsExcel.Worksheets['Sheet1'].range['F'+inttostr((j-1)*(8+d_count)+10+p)]:=sgdata.Cells[4,k+5+p];
                            MsExcel.Worksheets['Sheet1'].range['E'+inttostr((j-1)*(8+d_count)+10+p)]:=sgdata.Cells[5,k+5+p];
                            MsExcel.Worksheets['Sheet1'].range['D'+inttostr((j-1)*(8+d_count)+10+p)]:=sgdata.Cells[6,k+5+p];
                          end;
                    end;
             ProgressBar1.Progress:=Round((n+1)/processlst.Count*100);
         end;
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
   s:='';
   for  i:=1 to (ainteger div 26) do
    begin
     s:=s+'A';
    end;
    if length(s)>0 then
      result:=chr(64+length(s))+chr(65+(ainteger mod 26))
    else
      result:=chr(65+(ainteger mod 26));
end;

end.

