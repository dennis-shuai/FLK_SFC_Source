unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles, comobj,DateUtils,Excel2000;

type
  TfMainForm = class(TForm)
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    QryTemp1: TClientDataSet;
    ImageAll: TImage;
    Label2: TLabel;
    labInputQty: TLabel;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Query: TSpeedButton;
    Image3: TImage;
    SaveDialog1: TSaveDialog;
    sBtnExport: TSpeedButton;
    Image1: TImage;
    Label1: TLabel;
    cmbMachine: TComboBox;
    cmbMachineNo: TComboBox;
    Label3: TLabel;
    cmbInterval: TComboBox;
    Label4: TLabel;
    dtp1: TDateTimePicker;
    cmb1: TComboBox;
    Label5: TLabel;
    dtp2: TDateTimePicker;
    cmb2: TComboBox;
    procedure QueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure FormShow(Sender: TObject);
    procedure cmbMachineSelect(Sender: TObject);

  public
    UpdateUserID,sPartID : String;
    sPdline,sProcess,sTerminal:string;
    Authoritys,AuthorityRole,FunctionName : String;
    
  end;

var
  fMainForm: TfMainForm;
  gWO,gCarrierNO:string;
  iCarrierSNCount,iSNCount:Integer;
  iTerminal:string;

implementation


{$R *.dfm}



procedure TfMainForm.QueryClick(Sender: TObject);
var SQLStr:string;
sStartTime,sEndTime:string;
begin

   with  QryData do
   begin
       close;
       params.Clear;
       Params.CreateParam(ftString,'start_time',ptInput);
       Params.CreateParam(ftString,'end_time',ptInput);
       SQLStr :=' select a.list_no,a.serial_number,b.model_name,nvl(f.tooling_name,''N/A'') tooling_name ,c.tooling_sn , '+
               ' d.item_name,e.interval_desc,e.interval_value,a.Max_value,a.Min_value,a.cal_value,a.cal_result,a.start_time,a.end_time,'+
               ' g.emp_name, e.warning_hour,((a.start_time+e.interval_value)-sysdate)*24 rest_hour,a.seq  '+
               ' from (select * from sajet.g_cal_Travel union select * from sajet.g_cal_status ) a, sajet.sys_model b,'+
               ' sajet.sys_tooling_SN c ,sajet.sys_cal_item d,sajet.sys_cal_interval e ,sajet.sys_tooling f ,sajet.sys_emp g'+
               ' where a.model_id=b.model_id and a.tooling_sn_id = c.tooling_SN_id and f.tooling_id=c.tooling_id and a.update_userid=g.emp_id '+
               ' and d.item_Id=a.item_id and a.interval_id=e.interval_id  and a.start_time >= to_date(:start_time,''YYYYMMDDHH24'') '+
               ' and a.start_time < to_date(:end_time,''YYYYMMDDHH24'') ';
       if Length(cmb1.Items.Strings[cmb1.ItemIndex])=1 then
           sStartTime := FormatDateTime('YYYYMMDD', dtp1.Date)+'0'+cmb1.Items.Strings[cmb1.ItemIndex]
       else
           sStartTime := FormatDateTime('YYYYMMDD', dtp1.Date)+cmb1.Items.Strings[cmb1.ItemIndex];

       if Length(cmb2.Items.Strings[cmb2.ItemIndex])=1 then
           sEndTime := FormatDateTime('YYYYMMDD', dtp2.Date)+'0'+cmb2.Items.Strings[cmb2.ItemIndex]
       else
           sEndTime := FormatDateTime('YYYYMMDD', dtp2.Date)+cmb2.Items.Strings[cmb2.ItemIndex];
       Params.ParamByName('start_time').AsString := sStartTime;
       Params.ParamByName('end_time').AsString := sEndTime;

       if cmbMachine.ItemIndex > 0   then
       begin
           Params.CreateParam(ftString,'Machine',ptInput);
           SQLStr :=SQLStr +' and f.tooling_Name =:Machine ';
           Params.ParamByName('Machine').AsString := cmbMachine.Items.Strings[cmbMachine.ItemIndex];
       end;

       if cmbMachineNO.ItemIndex > 0   then
       begin
           Params.CreateParam(ftString,'MachineNO',ptInput);
           SQLStr :=SQLStr +' and c.tooling_SN =:MachineNO ';
           Params.ParamByName('MachineNO').AsString := cmbMachineNO.Items.Strings[cmbMachineNO.ItemIndex];
       end;


       if cmbInterval.ItemIndex > 0   then
       begin
           Params.CreateParam(ftString,'Interval',ptInput);
           SQLStr :=SQLStr +' and e.interval_desc =:Interval ';
           Params.ParamByName('Interval').AsString := cmbInterval.Items.Strings[cmbInterval.ItemIndex];
       end;
       CommandText :=SQLStr +' order by a.list_No,a.seq' ;

       Open;

   end;

end;



procedure TfMainForm.sBtnExportClick(Sender: TObject);
var ExcelApp,vRange: Variant; i,j,iCount: integer;
    strListNo,strSN,strMachine,strMachineSN,strItem,strInterval,strIntervalValue,strMax,strMin,strValue
    ,strEMP,strstartTIME,strEndTime,strResult :STRING;
begin
    if SaveDialog1.Execute then
    begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);
        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Add;
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.WorkSheets[1].Name := '機台點檢在線記錄' ;
        ExcelApp.Cells[1,1].Value := '機台點檢在線記錄';
        iCount :=  QryData.RecordCount;
        vRange := VarArrayCreate([1,iCount+1,1,15],varVariant);
        VarArrayPut(vRange,'單號',[1,1]);
        VarArrayPut(vRange,'Golden Sample',[1,2]);
        VarArrayPut(vRange,'機種',[1,3]);
        VarArrayPut(vRange,'機台類型',[1,4]);
        VarArrayPut(vRange,'機台條碼',[1,5]);
        VarArrayPut(vRange,'點檢項目',[1,6]);
        VarArrayPut(vRange,'點檢類型',[1,7]);
        VarArrayPut(vRange,'間隔天數',[1,8]);
        VarArrayPut(vRange,'最大值',[1,9]);
        VarArrayPut(vRange,'最小值',[1,10]);
        VarArrayPut(vRange,'點檢值',[1,11]);
        VarArrayPut(vRange,'點檢結果',[1,12]);
        VarArrayPut(vRange,'開始時間',[1,13]);
        VarArrayPut(vRange,'結束時間',[1,14]);
        VarArrayPut(vRange,'點檢人',[1,15]);
        if not QryData.IsEmpty then
        begin
            QryData.First;
            for  i:=1 to iCount  do
            begin
                  // strListNo,strSN,strMachine,strMachineSN,strItem,strInterval,strIntervalValue,strMax,strMin,strValue
                   //,strEMP,strstartTIME,strEndTime,strResult
                  {strListNo :=  QryData.FieldByName('List_NO').AsString ;
                  strSN :=  QryData.FieldByName('Serial_number').AsString ;
                  strMachine :=  QryData.FieldByName('Tooling_Name').AsString ;
                  strMachineSN :=QryData.FieldByName('TOOLING_SN').AsString ;
                  strItem :=  QryData.FieldByName('Item_Name').AsString;
                  strInterval :=  QryData.FieldByName('Interval_Desc').AsString;
                  strIntervalValue :=  QryData.FieldByName('Interval_Value').AsString;
                  strMax :=  QryData.FieldByName('Max_Value').AsString;
                  strMin :=  QryData.FieldByName('Min_Value').AsString;
                  strValue :=  QryData.FieldByName('Cal_Value').AsString;
                  strstartTIME :=  QryData.FieldByName('Start_Time').AsString;
                  strEndTime :=  QryData.FieldByName('End_Time').AsString;
                  strResult :=  QryData.FieldByName('Cal_Result').AsString; }
                  for j:=0 to 14 do
                      VarArrayPut(vRange,QryData.Fields[j].AsString ,[i+1,j+1]);

                  QryData.Next;
            end;
        end;
        ExcelApp.ActiveSheet.Range['A1:O1'].Interior.Color :=clYellow;
        ExcelApp.ActiveSheet.Range['A:O'].Columns.AutoFit;
        ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(iCount+1)].Value :=vRange ;
        ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(iCount+1)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(iCount+1)].VerticalAlignment :=2;
        ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(iCount+1)].Font.Size :=8;
        ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(iCount+1)].Font.Name :='tahoma';
        ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(iCount+1)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(iCount+1)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(iCount+1)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(iCount+1)].Borders[4].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(iCount+1)].Borders[7].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(iCount+1)].Borders[8].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(iCount+1)].Borders[9].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:O'+IntToStr(iCount+1)].Borders[10].Weight := xlThick;
        ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
        ExcelApp.Quit;
        ExcelApp :=Unassigned;
        vRange :=Unassigned;
        MessageDlg('Save OK',mtInformation,[MBOK],0);
    end;



end;


procedure TfMainForm.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var i,Waring_Hour,rest_hour:Integer;
      j,sresult,sEndTIme:string;
begin
    if QryData.recordcount>0 then
    begin
       try
          Waring_Hour:= QryData.FieldByName('Warning_Hour').AsInteger;
          rest_hour :=  QryData.FieldByName('Rest_Hour').AsInteger;
          sresult   :=  QryData.FieldByName('Cal_result').AsString;
          sEndTIme :=  QryData.FieldByName('End_Time').AsString;

          if     sresult = 'Fail'   then
          begin
                DBGrid1.Canvas.Brush.Color:=clRed;
                DBGrid1.DefaultDrawColumnCell(Rect,DataCol,Column,State);
          end
          else if  (sresult ='PASS') and  (sEndTIme <> '' )  then
          begin
                DBGrid1.Canvas.Brush.Color:=clGreen;
                DBGrid1.DefaultDrawColumnCell(Rect,DataCol,Column,State);
          end
          else begin
                DBGrid1.Canvas.Brush.Color:=clWhite;
                DBGrid1.DefaultDrawColumnCell(rect,Datacol,column,state);
          end;
       except

       end;
    end;

end;

procedure TfMainForm.FormShow(Sender: TObject);
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText :='select distinct tooling_Name from sajet.sys_tooling where enabled=''Y'' and Isrepair_control=''Y'' order by tooling_Name';
      Open;

      First;
      cmbMachine.Items.Clear;
      cmbMachine.Items.Add('All');
      while not Eof do begin
         cmbMachine.Items.Add( FieldByName('tooling_Name').AsString );
         Next;
      end;
      cmbMachine.Style := csDropDownList;

      Close;
      Params.Clear;
      CommandText :='select interval_desc from sajet.sys_CAL_INTERVAL where enabled=''Y''  order by interval_id';
      Open;

      First;
      cmbInterval.Items.Clear;
      cmbInterval.Items.Add('All');
      while not Eof do begin
         cmbInterval.Items.Add( FieldByName('interval_desc').AsString );
         Next;
      end;
      cmbInterval.Style := csDropDownList;
   end;
   dtp1.Date :=Today;
   dtp2.Date :=Tomorrow;
end;

procedure TfMainForm.cmbMachineSelect(Sender: TObject);
begin
    With QryTemp do
    begin
        close;
        params.Clear;
        Params.CreateParam(ftString,'sn',ptInput);
        commandtext:=' select b.tooling_sn from sajet.sys_tooling a,sajet.sys_tooling_sn b '+
                     ' where a.tooling_id=b.tooling_id and a.tooling_name=:SN and b.enabled=''Y'' '+
                     ' and a.enabled=''Y'' order by b.tooling_SN ';
        Params.ParamByName('sn').AsString :=cmbMachine.Text ;
        open;
        cmbMachineNo.Items.Clear;
        cmbMachineNo.Items.Add('All');
        cmbMachineNo.Style :=csDropDownList;
        First;
         while not Eof do begin
             cmbMachineNo.Items.Add(fieldbyName('tooling_sn').AsString);
             Next;
        end;
    end;
end;

end.











