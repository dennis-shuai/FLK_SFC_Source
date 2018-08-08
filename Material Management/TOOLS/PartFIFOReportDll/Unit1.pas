unit Unit1;

interface

uses
   Windows, Messages, SysUtils, Classes, Controls, Forms, StrUtils, ComObj ,
   ExtCtrls, StdCtrls, DB, DBClient, RzStatus, ComCtrls, Graphics, Buttons,
   Grids, DBGrids, Dialogs, MidasLib, Variants ;

type
  TFormMain = class(TForm)
    QryTemp: TClientDataSet;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    Panel1: TPanel;
    cmbWSEnd: TComboBox;
    DTEnd: TDateTimePicker;
    Label7: TLabel;
    cmbWSStart: TComboBox;
    DTStart: TDateTimePicker;
    Label6: TLabel;
    sbtnQuery: TSpeedButton;
    Image7: TImage;
    sbtnExport: TSpeedButton;
    Image1: TImage;
    ImageAll: TImage;
    Panel2: TPanel;
    lblVer1: TLabel;
    ImageAll2: TImage;
    SaveDialog1: TSaveDialog;
    procedure FormShow(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure sbtnExportClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Function Getsystime: TdateTime;
    function GetVersion(sFile:string):string;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}
uses uDllform,DllInit ;

Function TFormMain.Getsystime: TdateTime;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText :=' SELECT SYSDATE FROM DUAL  ';
    Open;
    Result := FieldByName('SYSDATE').asDateTime ;
    Close ;
  end;
end;

function TFormMain.GetVersion(sFile:string):string;
var
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  szName: array[0..255] of Char;
  Value: Pointer;
  Len: UINT;
  TransString:string;
begin
  InfoSize := GetFileVersionInfoSize(PChar(sFile), Wnd);
  if InfoSize <> 0 then
  begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(sFile), Wnd, InfoSize, VerBuf) then
      begin
        Value :=nil;
        VerQueryValue(VerBuf, '\VarFileInfo\Translation', Value, Len);
        if Value <> nil then
           TransString := IntToHex(MakeLong(HiWord(Longint(Value^)), LoWord(Longint(Value^))), 8);
        Result := '';
        StrPCopy(szName, '\StringFileInfo\'+Transstring+'\FileVersion');

        if VerQueryValue(VerBuf, szName, Value, Len) then
           Result := StrPas(PChar(Value));
      end;
    finally
      FreeMem(VerBuf);
    end;
  end;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  //lblVer1.Caption:= 'Version: '+GetVersion(application.ExeName)+'  (20111017)';
  DTStart.DateTime := Now ;
  DTEnd.DateTime := Now ;
end;

procedure TFormMain.sbtnQueryClick(Sender: TObject);
var
  sStartDate ,sEndDate : string;
begin
  sStartDate := FormatDateTime('YYYYMMDD', DTStart.Date);
  sEndDate := FormatDateTime('YYYYMMDD', DTEnd.Date);

  if cmbWSStart.Text <> '' then
    sStartDate := sStartDate + ' ' + cmbWSStart.Text+':00:00'
  else
    sStartDate := sStartDate + ' 00:00:00';

  if cmbWSEnd.Text <> '' then
    sEndDate := sEndDate + ' ' + cmbWSEnd.Text+':00:00'
  else
    sEndDate := sEndDate + ' 23:59:00';

  with QryTemp do
  begin
    Close ;
    Params.Clear ;
    QryTemp.CommandText := 'SELECT A.PART_NO,B.CHECK_FIFO,B.LAST_TIME,C.EMP_NAME,B.UPDATE_TIME  FROM '
                 + 'SAJET.SYS_PART A,SAJET.SYS_PART_FIFO B,SAJET.SYS_EMP C '
                 + 'WHERE B.PART_ID=A.PART_ID AND B.UPDATE_USERID=C.EMP_ID AND '
                 + 'B.UPDATE_TIME between to_date('''+sStartDate+''',''YYYY/MM/DD HH24:MI:SS'')  '
                 + 'AND to_date('''+sEndDate+''',''YYYY/MM/DD HH24:MI:SS'') ORDER BY PART_NO ' ;
    Open ;
  end;
end;

procedure TFormMain.sbtnExportClick(Sender: TObject);
var
  ExcelApp : Variant ;
  i, ii, RowNum : Integer;
  PanleStr : string;
  FilePathName : string;
begin
  if (QryTemp.RecordCount<=0) or (QryTemp.Eof) then
  begin
      MessageBox(Handle ,'警告,沒有可以匯出到Excel的數據或者數據庫為空,請重新搜索!',
                    '數據為空',MB_OK+MB_ICONWARNING+MB_SYSTEMMODAL);
      Exit ;
  end;

  if SaveDialog1.Execute then
  begin
    FilePathName := SaveDialog1.FileName ;
  end else Exit ;

  if UpperCase(RightStr(FilePathName,4)) <> '.XLS' then
     FilePathName := FilePathName + '.xls' ;

  if FileExists(FilePathName) then
    DeleteFile(FilePathName);
    
  RowNum := 2;
  try
    ExcelApp := CreateOleObject('Excel.Application');
  except
    MessageBox(handle,'打開Excel出錯,請确認已經正确安裝了Microsoft Office!','Error',MB_ICONWARNING) ;
    Exit ;
  end;

  ExcelApp.Visible := False ;               //
  ExcelApp.Caption := 'Microsoft Excel';
  ExcelApp.WorkBooks.Add(1);
  ExcelApp.WorkSheets[1].Activate;
  ExcelApp.WorkSheets[1].Name := FormatDateTime('YYYYMMDD',Now);

  ExcelApp.Cells[1,2].Value := '先進先出統計報表';
  ExcelApp.Cells[1,2].Font.Name := 'Calibri';
  ExcelApp.Cells[1,2].Font.Size := 14 ;
  ExcelApp.Cells[1,2].Font.Bold := True ;
  ExcelApp.ActiveSheet.Range['B1:D1'].Merge;                       //合併
  ExcelApp.ActiveSheet.Range['B1:D1'].Font.Bold   := True;         //加粗
  ExcelApp.ActiveSheet.Range['B1:D1'].HorizontalAlignment := 3;     //居中
  ExcelApp.ActiveSheet.Range['B1:D1'].VerticalAlignment   := 3 ;   //居中

  //標題
  ExcelApp.Cells[2,1].Value := 'Part_No';
  ExcelApp.Cells[2,2].Value := 'CHECK_FIFO';
  ExcelApp.Cells[2,3].Value := 'Last_Time';
  ExcelApp.Cells[2,4].Value := 'EMP_Name';
  ExcelApp.Cells[2,5].Value := 'Update_Time';
  QryTemp.First ;
  
  //寫內容
  //while not QryTemp.Eof do
  for ii := 1 to QryTemp.RecordCount do
  begin
    for i:= 1 to DBGrid1.Columns.Count do
    begin
      ExcelApp.Cells[ii+2,i].Value := DBGrid1.Columns.Items[i-1].Field.AsString ;
    end;
    Inc(RowNum);
    QryTemp.Next ;
  end;

  ExcelApp.ActiveSheet.Range['A2:E'+IntToStr(RowNum)].EntireColumn.Autofit ; //設置自動列寬
  ExcelApp.ActiveSheet.Range['A2:E'+IntToStr(RowNum)].HorizontalAlignment := 3;     //居中
  ExcelApp.ActiveSheet.Range['A2:E'+IntToStr(RowNum)].VerticalAlignment   := 3 ;   //居中

  //1-左    2-右   3-頂    4-底   5-斜( \ )  6-斜( / )
  ExcelApp.ActiveSheet.Range['A2:E'+IntToStr(RowNum)].Borders[1].Weight := 2;
  ExcelApp.ActiveSheet.Range['A2:E'+IntToStr(RowNum)].Borders[2].Weight := 2;
  ExcelApp.ActiveSheet.Range['A2:E'+IntToStr(RowNum)].Borders[3].Weight := 2;
  ExcelApp.ActiveSheet.Range['A2:E'+IntToStr(RowNum)].Borders[4].Weight := 2;

  //保存
  ExcelApp.ActiveSheet.SaveAs(FilePathName);            

  ExcelApp.WorkBooks.Close;
  ExcelApp.Quit;
  ExcelApp := Unassigned;

  MessageBox(handle,'匯出到Excel報表成功!','溫馨提示',MB_ICONINFORMATION ) ;
end;

end.
