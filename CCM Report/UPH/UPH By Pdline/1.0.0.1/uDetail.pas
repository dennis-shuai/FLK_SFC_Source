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
    DateTimePicker1: TDateTimePicker;
    Label1: TLabel;
    sbtnQuery: TSpeedButton;
    ImageSample: TImage;
    sBtnExport: TSpeedButton;
    Image1: TImage;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    SaveDialog1: TSaveDialog;
    Label2: TLabel;
    DateTimePicker2: TDateTimePicker;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    QryDefectDetail: TClientDataSet;
    LabCount: TLabel;
    procedure sbtnQueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID : String;
    Count:Integer;
    UpDate_Time :TDateTime;
    sStartTime, sEndTime, sDStartTime, sDEndTime,sTime1,sTime2 :string;
    function  QueryOutput( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
  end;

var
  fDetail: TfDetail;
  mWO,mPartID,mPartNO,mCustPartNO,sPdlineList:string;


implementation

{$R *.dfm}
uses uDllform,DllInit, UFrmList;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
begin
    if length(ComboBox1.Text)=1  then  sTime1 := '0' + ComboBox1.Text
    else  sTime1 := ComboBox1.Text;

    if length(ComboBox2.Text)=1  then  sTime2 := '0' + ComboBox2.Text
    else  sTime2 := ComboBox2.Text;

    sStartTime  := FormatDateTime('yyyymmdd',DateTimePicker1.Date)+ sTime1  ;
    sEndTime  := FormatDateTime('yyyymmdd',DateTimePicker2.Date)+ sTime2 ;

    //sDStartTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker1.Date)+ ' '+ sTime1+':00:00'  ;
    //sDEndTime  := FormatDateTime('yyyy/mm/dd',DateTimePicker2.Date) + ' ' + sTime2 +':00:00' ;

    QueryOutput(QryData, sStartTime, sEndTime);
    LabCount.Caption := 'Total Qty:'+IntToStr(QryData.RecordCount );
   

end;



function TfDetail.QueryOutput(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.Params.CreateParam(ftstring,'StartTime',ptInput);
    QryTemp1.Params.CreateParam(ftstring,'EndTime',ptInput);
    QryTemp1.CommandText:=' select d.pdline_name,a."8H",a."9H",a."10H",a."11H",a."12H",a."13H",a."14H",a."15H",a."16H",a."17H",a."18H",a."19H",a."20H",a."21H"   '+
                          ' ,a."22H",a."23H",a."0H",a."1H",a."2H",a."3H",a."4H",a."5H",a."6H",a."7H",c.REPAIR_HOUR from (select pdline_id,   '+
                          ' sum(case when  work_time =8 then  output_qty else 0 end) "8H",      '+
                          ' sum(case when  work_time =9 then  output_qty else 0 end) "9H",    '+
                          ' sum(case when  work_time =10 then  output_qty else 0 end) "10H",      '+
                          ' sum(case when  work_time =11 then  output_qty else 0 end) "11H",      '+
                          ' sum(case when  work_time =12 then  output_qty else 0 end) "12H",       '+
                          ' sum(case when  work_time =13 then  output_qty else 0 end) "13H",        '+
                          ' sum(case when  work_time =14 then  output_qty else 0 end) "14H",       '+
                          ' sum(case when  work_time =15 then  output_qty else 0 end) "15H",   '+
                          ' sum(case when  work_time =16 then  output_qty else 0 end) "16H",   '+
                          ' sum(case when  work_time =17 then  output_qty else 0 end) "17H",   '+
                          ' sum(case when  work_time =18 then  output_qty else 0 end) "18H",   '+
                          ' sum(case when  work_time =19 then  output_qty else 0 end) "19H",   '+
                          ' sum(case when  work_time =20 then  output_qty else 0 end) "20H",    '+
                          ' sum(case when  work_time =21 then  output_qty else 0 end) "21H",   '+
                          ' sum(case when  work_time =22 then  output_qty else 0 end) "22H",   '+
                          ' sum(case when  work_time =23 then  output_qty else 0 end) "23H",    '+
                          ' sum(case when  work_time =0 then  output_qty else 0 end) "0H",      '+
                          ' sum(case when  work_time =1 then  output_qty else 0 end) "1H",      '+
                          ' sum(case when  work_time =2 then  output_qty else 0 end) "2H",      '+
                          ' sum(case when  work_time =3 then  output_qty else 0 end) "3H",       '+
                          ' sum(case when  work_time =4 then  output_qty else 0 end) "4H",       '+
                          ' sum(case when  work_time =5 then  output_qty else 0 end) "5H",       '+
                          ' sum(case when  work_time =6 then  output_qty else 0 end) "6H",      '+
                          ' sum(case when  work_time =7 then  output_qty else 0 end) "7H"       '+
                          ' from  sajet.g_sn_count                                              '+
                          ' where stage_id=10022 and to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) >=:startTime  '+
                          '       and to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) <= :endTime    '+
                          '       group by pdline_id) a,(select a1.pdline_id from sajet.sys_terminal a1,SAJET.SYS_TOOLING_TERMINAL b1  where a1.terminal_id =b1.terminal_id ) b,  '+
                           '      (select a1.pdline_id,round(sum(c1.repair_time-c1.defect_time)*24,2) repair_Hour from sajet.sys_terminal a1,SAJET.SYS_TOOLING_TERMINAL b1,sajet.G_tooling_sn_repair c1 '+
                          '       where A1.TERMINAL_ID =B1.TERMINAL_ID and B1.TOOLING_SN_ID=C1.TOOLING_SN_ID  '+
                          '             and c1.defect_time >=to_date(:starttime,''YYYYMMDDHH24'') and c1.defect_time <to_date(:endTime,''YYYYMMDDHH24'') group by a1.pdline_id) c,sajet.sys_pdline d'+
                          '     where a.pdline_id = b.pdline_id and a.pdline_id= c.pdline_id(+)  and a.pdline_id = d.pdline_id order by d.pdline_name ';

    QryTemp1.Params.ParamByName('StartTime').AsString := sStartTime;
    QryTemp1.Params.ParamByName('EndTime').AsString :=   sEndTime;
    QryTemp1.Open;
end;


procedure TfDetail.sBtnExportClick(Sender: TObject);
var
      ExcelApp,vRange: Variant; i,j,iCount: integer;
begin


    if SaveDialog1.Execute then
    begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);

        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Add ;
        ExcelApp.WorkSheets[1].Activate;

        iCount :=  QryData.RecordCount;
        vRange := VarArrayCreate([1,iCount+1,1,26],varVariant);

         if not QryData.IsEmpty then
        begin

            for j:=0 to 25 do
                 VarArrayPut(vRange,DBGrid1.Columns[j].Title.Caption ,[1,j+1]);


            QryData.First;
            for  i:=1 to iCount  do
            begin
                  for j:=0 to 25 do
                      VarArrayPut(vRange,QryData.Fields[j].AsString ,[i+1,j+1]);
                  QryData.Next;
            end;
        end;
        ExcelApp.ActiveSheet.Range['A1:Z'+IntToStr(iCount+1)].Value :=vRange ;

        ExcelApp.ActiveSheet.Range['A1:Z1'].Interior.Color  := clYellow;
        ExcelApp.ActiveSheet.Range['A1:Z'+IntToStr(iCount+1)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:Z'+IntToStr(iCount+1)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:Z'+IntToStr(iCount+1)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:Z'+IntToStr(iCount+1)].Borders[4].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:Z'+IntToStr(iCount+1)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:Z'+IntToStr(iCount+1)].Font.Name :='Tohama';
        ExcelApp.ActiveSheet.Range['A2:Z'+IntToStr(iCount+1)].Font.Size :=9;
        ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
        ExcelApp.Quit;
        vRange := Unassigned;
        ExcelApp :=Unassigned;
        MessageDlg('Save OK',mtConfirmation,[mbyes],0);

    end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var i:integer;
begin


    DateTimePicker1.Date :=  Now-1;
    DateTimePicker2.Date :=  tomorrow-1;
    
end;

end.
