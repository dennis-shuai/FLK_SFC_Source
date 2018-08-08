unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, Grids, DBGrids, DBGrid1, ExtCtrls, StdCtrls,
  Buttons,ComObj,Excel2000;

type
  TfDetail = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    DBGrid11: TDBGrid1;
    DataSource1: TDataSource;
    lbl1: TLabel;
    cmbToolingNo: TComboBox;
    lbl2: TLabel;
    lbl3: TLabel;
    cmbDept: TComboBox;
    lbl4: TLabel;
    cmbEmp: TComboBox;
    lbl7: TLabel;
    cmbUsedStatus: TComboBox;
    btnOK: TSpeedButton;
    img1: TImage;
    img2: TImage;
    btn1: TSpeedButton;
    tmr1: TTimer;
    lbl5: TLabel;
    cmbQtyStatus: TComboBox;
    QryTemp: TClientDataSet;
    QryData: TClientDataSet;
    lbl6: TLabel;
    dlgSave1: TSaveDialog;
    procedure btnOKClick(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure DBGrid11DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btn1Click(Sender: TObject);
   
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
       if   cmbToolingNo.Text <>'All' then
          Params.CreateParam(ftString,'Tooling_No',ptInput);
       if cmbDept.Text <> 'All' then
          Params.CreateParam(ftString,'DEPT',ptInput);
       if cmbEmp.Text <> 'All' then
          Params.CreateParam(ftString,'EMP',ptInput);
       if cmbUsedStatus.Text <> 'All' then
          Params.CreateParam(ftString,'Used_STATUS',ptInput);

       if cmbQtyStatus.ItemIndex >= 1 then
            SQLtext := ' select * from (';
       SQLtext :=SQLtext+ ' select a.tooling_no,A.TOOLING_NAME ,b.safty_qty , F.DEPT_NAME ,COunt(*) total_qty  '+
                  ' from sajet.sys_tooling a,sajet.sys_tooling_settings b, sajet.sys_tooling_sn c, '+
                  ' SAJET.G_TOOLING_MATERIAL d,sajet.sys_emp e,sajet.sys_dept f '+
                  ' where a.tooling_id=b.tooling_id and A.TOOLING_ID =C.TOOLING_ID '+
                  ' and C.TOOLING_SN_ID =d.tooling_sn_id and D.KEEPER_USERID =E.EMP_ID '+
                  ' and D.MONITOR_DEPT =F.DEPT_ID  ';

       if cmbToolingNo.Text <> 'All' then
          SQLtext := SQLtext + ' and A.TOOLING_No =:Tooling_No' ;
       if cmbDept.Text <> 'All' then
          SQLtext  := SQLtext +' and f.dept_Name =:DEPT ';
       if cmbEmp.Text <> 'All' then
          SQLtext := SQLtext +' and  e.EMP_NAME =:EMP ';

       if cmbUsedStatus.Text <> 'All' then
          SQLtext := SQLtext +' and d.Machine_Used =:Used_STATUS';

       SQLtext :=SQLtext + ' group by a.tooling_no,A.TOOLING_NAME ,b.safty_qty  , F.DEPT_NAME ';

       if cmbQtyStatus.ItemIndex = 1 then
          SQLtext := SQLtext +' ) where   Safty_Qty >= total_qty '
       else if cmbQtyStatus.ItemIndex = 2 then
          SQLtext := SQLtext +' ) where   Safty_Qty < total_qty ';

       CommandText :=SQLtext;

       if   cmbToolingNo.Text <> 'All' then
          Params.ParamByName('Tooling_No').AsString :=cmbToolingNo.Text;
       if cmbDept.Text <> 'All' then
          Params.ParamByName('DEPT').AsString :=cmbDept.Text;
       if cmbEmp.Text <> 'All' then
          Params.ParamByName('EMP').AsString :=cmbEmp.Text;
       if cmbUsedStatus.Text <> 'All' then
          Params.ParamByName('Used_STATUS').AsString :=cmbUsedStatus.Text;
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
     CommandText := 'Select  distinct(Tooling_No) from '
                 +  ' sajet.sys_tooling '
                 +  ' where   Enabled=''Y'' order by Tooling_No ' ;

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
     //---------
     Close;
     Params.Clear;
     CommandText := 'Select  distinct(b.DEPT_NAME) from sajet.G_TOOLING_Material a ,sajet.SYS_DEPT b '
                 + ' where a.Monitor_DEPT=b.DEPT_ID order by b.dept_name ';
     Open;
     First;
     cmbDept.Clear;
     cmbDept.Items.Clear;
     cmbDept.Items.Add('All');
     for  i:=0 to RecordCount-1 do
     begin
        cmbDept.Items.Add(FieldByName('DEPT_NAME').AsString);
        Next;
     end;
     //
     Close;
     Params.Clear;
     CommandText := ' select distinct EMP_NAME from SAJET.SYS_EMP a ,sajet.g_Tooling_Material b '
                   +' where A.EMP_ID =B.KEEPER_USERID order by EMP_NAME' ;
     Open;
     First;
     cmbEmp.Clear;
     cmbEmp.Items.Clear;
     cmbEmp.Items.Add('All');
     for  i:=0 to RecordCount-1 do
     begin
        cmbEmp.Items.Add(FieldByName('EMP_NAME').AsString);
        Next;
     end;

     Close;
     Params.Clear;
     CommandText := ' select distinct MACHINE_USED from sajet.g_Tooling_Material  '  ;

     Open;
     First;
     cmbUsedStatus.Clear;
     cmbUsedStatus.Items.Clear;
     cmbUsedStatus.Items.Add('All');
     for  i:=0 to RecordCount-1 do
     begin
        cmbUsedStatus.Items.Add(FieldByName('MACHINE_USED').AsString);
        Next;
     end;
   end;

   cmbToolingNo.Style :=csDropDownList;
   cmbDept.Style :=csDropDownList;
   cmbEmp.Style :=csDropDownList;
   cmbUsedStatus.Style :=csDropDownList;
   cmbQtyStatus.Style :=csDropDownList;
   cmbToolingNo.ItemIndex :=0;
   cmbDept.ItemIndex :=0;
   cmbEmp.ItemIndex :=0;
   cmbQtyStatus.ItemIndex :=0;
   cmbUsedStatus.ItemIndex :=0;

   tmr1.enabled :=False;
end;

procedure TfDetail.DBGrid11DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
    if QryData.FieldByName('Safty_qty').AsInteger >= QryData.FieldByName('Total_Qty').AsInteger then
         begin
                DBGrid11.Canvas.Brush.Color:=clRed;
                DBGrid11.DefaultDrawColumnCell(Rect,DataCol,Column,State);
         end
    else
       begin
                DBGrid11.Canvas.Brush.Color:=clGreen;
                DBGrid11.DefaultDrawColumnCell(Rect,DataCol,Column,State);
       end;
end;

procedure TfDetail.btn1Click(Sender: TObject);
var ExcelApp: Variant; i: integer;
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
        ExcelApp.WorkSheets[1].Name := '設備安全庫存查詢' ;
        ExcelApp.Cells[1,1].Value := '設備安全庫存查詢';

        ExcelApp.Cells[2,1].Value := '設備名稱';
        ExcelApp.Cells[2,2].Value := '是否使用';
        ExcelApp.Cells[2,3].Value := '監管部門';
        ExcelApp.Cells[2,4].Value := '安全庫存數量';
        ExcelApp.Cells[2,5].Value := '實際庫存數量';
        ExcelApp.ActiveSheet.Range['A1:E1'].Merge;

        ExcelApp.Columns[1].ColumnWidth :=12;
        ExcelApp.Columns[2].ColumnWidth :=22;
        ExcelApp.Columns[3].ColumnWidth :=22;
        ExcelApp.Columns[4].ColumnWidth :=15;
        ExcelApp.Columns[5].ColumnWidth :=15;
        i:=0;
        if not qryData.IsEmpty then
        begin
            qryData.First;
            for  i:=0 to qryData.RecordCount-1  do
            begin
                  ExcelApp.Cells[i+3,1].Value := qryData.FieldByName('Tooling_No').AsString ;;
                  ExcelApp.Cells[i+3,2].Value := cmbUsedStatus.Text;
                  ExcelApp.Cells[i+3,3].Value := qryData.FieldByName('Dept_Name').AsString ;;
                  ExcelApp.Cells[i+3,4].Value := qryData.FieldByName('Safty_Qty').AsString ;;
                  ExcelApp.Cells[i+3,5].Value := qryData.FieldByName('Total_Qty').AsString ;;

                  QryData.Next;
             end;
        end;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].VerticalAlignment :=2;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[4].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[7].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[8].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[9].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[10].Weight := xlThick;
        ExcelApp.ActiveSheet.SaveAs(dlgSave1.FileName);
        ExcelApp.Quit;
        MessageDlg('Save OK',mtinformation,[mbok],0);
    end;
end;
end.
