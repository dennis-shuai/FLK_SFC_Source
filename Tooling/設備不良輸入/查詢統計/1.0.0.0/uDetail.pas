unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, Grids, DBGrids, DBGrid1, ExtCtrls, StdCtrls,
  Buttons,ComObj,Excel2000, ComCtrls,DateUtils;

type
  TfDetail = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    DBGrid11: TDBGrid1;
    DataSource1: TDataSource;
    lbl1: TLabel;
    cmbToolingNo: TComboBox;
    lblTitle2: TLabel;
    btnOK: TSpeedButton;
    img1: TImage;
    img2: TImage;
    btn1: TSpeedButton;
    tmr1: TTimer;
    QryTemp: TClientDataSet;
    QryData: TClientDataSet;
    lblTitle1: TLabel;
    dlgSave1: TSaveDialog;
    dtp1: TDateTimePicker;
    dtp2: TDateTimePicker;
    lbl2: TLabel;
    lbl4: TLabel;
    chkDefect: TCheckBox;
    chkReason: TCheckBox;
    chkRepairer: TCheckBox;
    dtp3: TDateTimePicker;
    dtp4: TDateTimePicker;
    procedure btnOKClick(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure DBGrid11DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btn1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fDetail: TfDetail;

implementation

{$R *.dfm}



procedure TfDetail.btnOKClick(Sender: TObject);
var SQLtext :string;
begin

    with QryData   do
    begin

        Close;
        Params.Clear;
        Params.CreateParam(ftString,'Start_Time',ptInput);
        Params.CreateParam(ftString,'End_Time',ptInput);
        SQLtext := ' select  tooling_no,Tooling_SN, Count(*) Total_Qty ,sum(Repair_interval) repair_Hour   ';

        if  chkDefect.Checked then begin
               SQLtext :=  SQLtext+   ',Defect_desc ';
        end;

        if  chkReason.Checked then begin
               SQLtext :=  SQLtext+   ',Reason_desc ';
        end;

        if  chkRepairer.Checked then begin
               SQLtext :=  SQLtext+   ',EMP_NAME ';
        end;

        SQLtext :=  SQLtext+   '  from (select a.tooling_no,A.TOOLING_NAME, b.Tooling_SN, C.repair_time ,d.emp_name, '+
                  ' e.defect_desc,f.reason_desc ,Round((c.repair_time -c.defect_time)*24*60,0) Repair_interval  '+
                  ' from sajet.sys_tooling a,sajet.sys_tooling_sn  b, sajet.G_tooling_sn_repair c, '+
                  ' SAJET.sys_emp d,sajet.sys_defect e,sajet.sys_reason f '+
                  ' where a.tooling_id=b.tooling_id and B.TOOLING_SN_ID =C.TOOLING_SN_ID '+
                  ' and C.REPAIR_USERID =d.EMP_ID and C.DEFECT_ID =e.DEFECT_ID and c.repair_memo=''Online Repair'' '+
                  ' and C.REASON_ID = f.reason_id and to_char(c.defect_time,''YYYYMMDDHH24:MI:SS'') >=:start_time '+
                  ' and to_char(c.defect_time,''YYYYMMDDHH24:MI:SS'') < :end_Time) ';

        if cmbToolingNo.ItemIndex >0 then
        begin
            Params.CreateParam(ftString,'Tooling_no',ptInput);
            SQLtext :=  SQLtext+   ' where tooling_no=:tooling_no ';
            Params.ParamByName('Tooling_no').AsString :=cmbToolingNo.Text;

        end;

        SQLtext :=SQLtext + ' group by tooling_no  ,Tooling_SN   ';

        if  chkDefect.Checked then begin
               SQLtext :=  SQLtext+   ',Defect_desc ';
        end;

        if  chkReason.Checked then begin
               SQLtext :=  SQLtext+   ',Reason_desc ';
        end;

         if  chkRepairer.Checked then begin
               SQLtext :=  SQLtext+   ',EMP_NAME  ';
        end;
       // SQLtext :=  SQLtext+
        CommandText :=SQLtext;
        Params.ParamByName('Start_Time').AsString := FormatDateTime('YYYYMMDD',dtp1.Date)+FormatDateTime('HH:MM:SS',dtp3.Time);
        Params.ParamByName('End_Time').AsString :=FormatDateTime('YYYYMMDD',dtp2.Date)+FormatDateTime('HH:MM:SS',dtp4.Time);
        Open;



    end;
end;

procedure TfDetail.tmr1Timer(Sender: TObject);
var i:Integer;
begin
   with QryTemp do
   begin
     Close;
     Params.Clear;
     CommandText := ' Select  distinct(Tooling_No) from '
                 +  ' sajet.sys_tooling where   Enabled=''Y'''
                 +  ' and IsRepair_Control =''Y'' order by Tooling_No ' ;

     Open;
     First;
     cmbToolingNo.Clear;
     cmbToolingNo.Items.Clear;
     cmbToolingNo.Items.Add('All');
     for  i:=0 to RecordCount-1 do
     begin
        cmbToolingNo.Items.Add(FieldByName('TOOLING_No').AsString);
        Next;
     end;

   end;

   cmbToolingNo.Style :=csDropDownList;
   cmbToolingNo.ItemIndex :=0;


   tmr1.enabled :=False;
end;

procedure TfDetail.DBGrid11DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
   { if QryData.FieldByName('Safty_qty').AsInteger >= QryData.FieldByName('Total_Qty').AsInteger then
         begin
                DBGrid11.Canvas.Brush.Color:=clRed;
                DBGrid11.DefaultDrawColumnCell(Rect,DataCol,Column,State);
         end
    else
       begin
                DBGrid11.Canvas.Brush.Color:=clGreen;
                DBGrid11.DefaultDrawColumnCell(Rect,DataCol,Column,State);
       end; }
end;

procedure TfDetail.btn1Click(Sender: TObject);
var ExcelApp: Variant; i,j: integer;
begin
    if dlgSave1.Execute then
    begin
        if FileExists(dlgSave1.FileName) then
           DeleteFile(dlgSave1.FileName);
        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Add;
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.WorkSheets[1].Name := '設備維修統計' ;
        ExcelApp.Cells[1,1].Value := '設備維修統計';



        ExcelApp.ActiveSheet.Range['A1:G1'].Merge;

        ExcelApp.Columns[1].ColumnWidth :=12;
        ExcelApp.Columns[2].ColumnWidth :=12;
        ExcelApp.Columns[3].ColumnWidth :=12;
        ExcelApp.Columns[4].ColumnWidth :=22;
        ExcelApp.Columns[5].ColumnWidth :=15;
        ExcelApp.Columns[6].ColumnWidth :=22;
        ExcelApp.Columns[7].ColumnWidth :=15;

        i:=0;
        if not qryData.IsEmpty then
        begin
            qryData.First;

            for i:=1 to QryData.FieldCount do
            begin
                ExcelApp.Cells[2,i].Value := QryData.Fields[i-1].FieldName;
            end;

            for  i:=0 to qryData.RecordCount-1  do
            begin

                for J:=1 to Qrydata.FieldCount do
                begin
                    ExcelApp.Cells[i+3,j].Value :=QryData.Fields[j-1].AsString;
                end;

                QryData.Next;
            end;
        end;

        ExcelApp.ActiveSheet.Range['A1:G'+IntToStr(I+2)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:G'+IntToStr(I+2)].VerticalAlignment :=2;
        ExcelApp.ActiveSheet.Range['A1:G'+IntToStr(I+2)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:G'+IntToStr(I+2)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:G'+IntToStr(I+2)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:G'+IntToStr(I+2)].Borders[4].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:G'+IntToStr(I+2)].Borders[7].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:G'+IntToStr(I+2)].Borders[8].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:G'+IntToStr(I+2)].Borders[9].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:G'+IntToStr(I+2)].Borders[10].Weight := xlThick;

        ExcelApp.WorkSheets[2].Activate;
        ExcelApp.WorkSheets[2].Name := '詳細數據' ;

        with QryTemp do
        begin

            Close;
            Params.Clear;
            Params.CreateParam(ftString,'Start_Time',ptInput);
            Params.CreateParam(ftString,'End_Time',ptInput);
            QryTemp.CommandText := 'Select  a.tooling_no,A.TOOLING_NAME, b.Tooling_SN, C.defect_time,'+
                      ' c.start_repair_time, Round((c.start_repair_time-C.defect_time)*24*60,0) Wait_min,'+
                      ' C.repair_time ,d.emp_name Repairer, '+
                      ' e.defect_desc,f.reason_desc ,Round((c.repair_time -c.defect_time)*24*60,0) Repair_Min  '+
                      ' from sajet.sys_tooling a,sajet.sys_tooling_sn  b, sajet.G_tooling_sn_repair c, '+
                      ' SAJET.sys_emp d,sajet.sys_defect e,sajet.sys_reason f '+
                      ' where a.tooling_id=b.tooling_id and B.TOOLING_SN_ID =C.TOOLING_SN_ID '+
                      ' and C.REPAIR_USERID =d.EMP_ID and C.DEFECT_ID =e.DEFECT_ID and c.repair_memo=''Online Repair'' '+
                      ' and C.REASON_ID = f.reason_id and to_char(c.defect_time,''YYYYMMDDHH24:MI:SS'') >=:start_time '+
                      ' and to_char(c.defect_time,''YYYYMMDDHH24:MI:SS'') < :end_Time ';
            if cmbToolingNo.ItemIndex >0 then
            begin
                Params.CreateParam(ftString,'Tooling_no',ptInput);
                CommandText :=  CommandText+   ' and  a.tooling_no=:tooling_no ';
                Params.ParamByName('Tooling_no').AsString :=cmbToolingNo.Text;
            end;

             Params.ParamByName('Start_Time').AsString := FormatDateTime('YYYYMMDD',dtp1.Date)+FormatDateTime('HH:MM:SS',dtp3.Time);
             Params.ParamByName('End_Time').AsString :=FormatDateTime('YYYYMMDD',dtp2.Date)+FormatDateTime('HH:MM:SS',dtp4.Time);
             Open;

        end;


        if not QryTemp.IsEmpty then
        begin
           {
             for i:=1 to QryTemp.FieldCount do
             begin
                    ExcelApp.Cells[1,i].Value := QryTemp.Fields[i-1].FieldName;
             end;
           }
            ExcelApp.Cells[1,1].Value := '機台名稱';
            ExcelApp.Cells[1,2].Value := '機台類型';
            ExcelApp.Cells[1,3].Value := '機台編號';
            ExcelApp.Cells[1,4].Value := '損壞時間';
            ExcelApp.Cells[1,5].Value := '開始維修時間';
            ExcelApp.Cells[1,6].Value := '等待時間(分鐘)';
            ExcelApp.Cells[1,7].Value := '維修時間';
            ExcelApp.Cells[1,8].Value := '維修人員';
            ExcelApp.Cells[1,9].Value := '不良現象';
            ExcelApp.Cells[1,10].Value := '不良原因';
            ExcelApp.Cells[1,11].Value := '維修時長(分鐘)';

            for i:=1 to 11 do
               ExcelApp.Columns[i].ColumnWidth :=15;
            ExcelApp.Columns[4].ColumnWidth :=22;
            ExcelApp.Columns[5].ColumnWidth :=22;
            ExcelApp.Columns[7].ColumnWidth :=22;
            for  i:=0 to QryTemp.RecordCount-1  do
            begin

                 for J:=1 to QryTemp.FieldCount do
                 begin
                        ExcelApp.Cells[i+2,j].Value :=QryTemp.Fields[j-1].AsString;
                 end;
                 QryTemp.Next;
            end;
        end;
        inc(i);
        ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(I)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(I)].VerticalAlignment :=2;
        ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(I)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(I)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(I)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(I)].Borders[4].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(I)].Borders[7].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(I)].Borders[8].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(I)].Borders[9].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:K'+IntToStr(I)].Borders[10].Weight := xlThick;

        ExcelApp.ActiveSheet.SaveAs(dlgSave1.FileName);
        ExcelApp.Quit;
        MessageDlg('Save OK',mtinformation,[mbok],0);
    end;
end;
procedure TfDetail.FormShow(Sender: TObject);
begin
   dtp1.Date :=today;
   dtp2.Date :=tomorrow;
end;

end.
