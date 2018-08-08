unit uReel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Grids, DBGrids, ExtCtrls, Buttons,comobj;

type
  TfDetail = class(TForm)
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    Panel1: TPanel;
    Image3: TImage;
    sbtnexport: TSpeedButton;
    Image1: TImage;
    SpeedButton1: TSpeedButton;
    SaveDialog1: TSaveDialog;
    procedure sbtnexportClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
    Function DownloadSampleFile : String;
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant);
  public
    { Public declarations }
  end;

var
  fDetail: TfDetail;

implementation

uses uMain;

{$R *.dfm}

Function TfDetail.DownloadSampleFile : String;
begin
    Result:=ExtractFilePath(Application.ExeName) + ExtractFileName('PMCDetail.xlt')
end;

procedure TfDetail.sbtnexportClick(Sender: TObject);
var
  sFileName,My_FileName : String;
  MsExcel, MsExcelWorkBook : Variant;
begin
  if not fMain.qryReel.Active Then Exit;
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'xls';
  SaveDialog1.Filter := 'All Files(*.xls)|*.xls';
  My_FileName:= DownLoadSampleFile;
  if not FileExists(My_FileName) then
  begin
    showmessage('Error!-The Excel File '+My_FileName+' can''t be found.');
    exit;
  end;
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

procedure TfDetail.SaveExcel(MsExcel,MsExcelWorkBook:Variant);
var i,row:integer;
begin
   MsExcel.Worksheets[1].select;

   if fmain.qryReel.RecordCount>1 then
   begin
     for i:=1 to fmain.qryReel.RecordCount do
       MsExcel.ActiveSheet.Rows[4].Insert;
   end;
   fmain.qryReel.First;
   MsExcel.ActiveSheet.range['A2']:= 'P/N: '+fmain.qryReel.FieldByName('part_no').asstring;
   row:=1;
   fmain.qryReel.First;
   while not fmain.qryReel.Eof do
   begin
     MsExcel.ActiveSheet.range['A'+inttostr(3+row)]:=inttostr(row);
     MsExcel.ActiveSheet.range['B'+inttostr(3+row)]:=fmain.qryReel.FieldByName('part_no').asstring;
     MsExcel.ActiveSheet.range['C'+inttostr(3+row)]:=fmain.qryReel.FieldByName('material_no').asstring;
     MsExcel.ActiveSheet.range['D'+inttostr(3+row)]:=fmain.qryReel.FieldByName('material_qty').asstring;
     MsExcel.ActiveSheet.range['E'+inttostr(3+row)]:=fmain.qryReel.FieldByName('datecode').asstring;
     MsExcel.ActiveSheet.range['F'+inttostr(3+row)]:=fmain.qryReel.FieldByName('reel_no').asstring;
     MsExcel.ActiveSheet.range['G'+inttostr(3+row)]:=fmain.qryReel.FieldByName('reel_qty').asstring;
     MsExcel.ActiveSheet.range['H'+inttostr(3+row)]:=fmain.qryReel.FieldByName('warehouse_name').asstring;
     MsExcel.ActiveSheet.range['I'+inttostr(3+row)]:=fmain.qryReel.FieldByName('locate_name').asstring;
     MsExcel.ActiveSheet.range['J'+inttostr(3+row)]:=fmain.qryReel.FieldByName('emp_no').asstring;
     MsExcel.ActiveSheet.range['K'+inttostr(3+row)]:=fmain.qryReel.FieldByName('update_time').asstring;
     inc(row);
     fmain.qryReel.Next;
   end;

end;

procedure TfDetail.SpeedButton1Click(Sender: TObject);
begin
  ModalResult:=mrOK;
end;

end.
