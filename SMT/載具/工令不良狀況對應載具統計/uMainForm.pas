unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils, ComObj,// shellapi,
  Menus, uLang, IniFiles,DateUtils;

type
  TfMainForm = class(TForm)
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    QryTemp1: TClientDataSet;
    ImageAll: TImage;
    btnQuery: TSpeedButton;
    Image3: TImage;
    Image1: TImage;
    lbl2: TLabel;
    Image2: TImage;
    cmbDefect: TComboBox;
    Image4: TImage;
    btnExport: TSpeedButton;
    dbgrd1: TDBGrid;
    ds1: TDataSource;
    dlgSave1: TSaveDialog;
    lbl1: TLabel;
    edtWO: TEdit;
    dbgrd2: TDBGrid;
    ds2: TDataSource;
    procedure btnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure edtWOChange(Sender: TObject);
    procedure dbgrd1DblClick(Sender: TObject);
    procedure ds1DataChange(Sender: TObject; Field: TField);

    //procedure editReelnoKeyPress(Sender: TObject; var Key: Char);
  private

  public
    UpdateUserID,sPartID : String;
    isStart,IsOpen:boolean;
    sPdline,sProcess,sTerminal:string;
    StartTime,EndTime:string;
    Authoritys,AuthorityRole,FunctionName : String;
    BarApp,BarDoc,BarVars:variant;
    function GETSYSDATE:TDateTime;

  end;

var
  fMainForm: TfMainForm;
  iTerminal:string;

implementation


{$R *.dfm}
function TfMainForm.GetSYSDATE:TDateTime;
begin
   Qrytemp.Close;
   QryTemp.CommandText :=' SELECT SYSDATE iDATE FROM DUAL';
   QryTemp.Open;
   Result :=QryTemp.FieldByName('IDate').AsDateTime;

end;

procedure TfMainForm.btnQueryClick(Sender: TObject);
begin
    cmbDefect.Text := Trim(cmbDefect.Text);

    QryData.Close;
    QryData.Params.Clear;
    if cmbDefect.Text <> '' then
       QryData.Params.CreateParam(ftstring,'Defect',ptInput);
    QryData.Params.CreateParam(ftstring,'WO',ptInput);
    QryData.CommandText:=' select AA.Container,AA.Defect_Desc,AA.Qty,BB.Total_Qty,ROUND(AA.Qty/BB.Total_Qty*100,2) rate  '+
                         ' from (SELECT A.Container,C.Defect_Desc,Count(*) Qty FROM SAJET.G_SN_TRAVEL A,SAJET.G_SN_DEFECT_FIRST B, '+
                         ' SAJET.SYS_DEFECT C WHERE A.SERIAL_NUMBER =B.SERIAL_NUMBER AND A.PROCESS_ID= 100187 and a.WORK_ORDER=:WO '+
                         ' AND B.DEFECT_ID =C.DEFECT_ID  AND A.CONTAINER <>''N/A'' AND B.STAGE_ID =10001   ';

    if cmbDefect.Text <> '' then
    begin
       QryData.CommandText:= QryData.CommandText+ 'AND C.DEFECT_DESC =:Defect ';
       QryData.Params.ParamByName('Defect').AsString :=cmbDefect.Text;
    end;
    QryData.CommandText:= QryData.CommandText+ '  GROUP BY A.Container,C.Defect_Desc) aa, '+
                         '(SELECT A.Container,Count(*) Total_Qty FROM SAJET.G_SN_TRAVEL A WHERE  A.PROCESS_ID= 100187   '+
                         ' and a.WORK_ORDER=:WO  GROUP BY A.Container ) bb     '+
                         ' where aa.Container=bb.Container  order by rate desc,aa.qty desc,BB.Total_Qty desc';
    QryData.Params.ParamByName('WO').AsString :=EdtWO.Text;
    QryData.open;



end;

procedure TfMainForm.FormShow(Sender: TObject);
begin
    cmbDefect.Items.Clear;
    edtWO.SetFocus;
end;

procedure TfMainForm.btnExportClick(Sender: TObject);
 var ExcelApp: Variant; i: integer;
    strCarry,strDefect,strQty,strTotalQty:string;
begin
    if dlgSave1.Execute then
    begin
        if FileExists(dlgSave1.FileName) then
           DeleteFile(dlgSave1.FileName);
        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.add;
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.WorkSheets[1].Name := 'ぃ▆更ㄣ癸莱参璸' ;
        ExcelApp.Cells[1,1].Value := 'ぃ▆更ㄣ癸莱参璸';
        ExcelApp.Cells[2,1].Value := '更ㄣ';
        ExcelApp.Cells[2,2].Value := 'ぃ▆瞷禜';
        ExcelApp.Cells[2,3].Value := 'ぃ▆计秖';
        ExcelApp.Cells[2,4].Value := 'ㄏノ羆计';
        ExcelApp.Cells[2,5].Value := 'ゑ瞯(%)';
        if not QryData.IsEmpty then
        begin
            QryData.First;
            for  i:=0 to QryData.RecordCount-1  do
            begin
                  strCarry :=QryData.FieldByName('CONTAINER').AsString ;
                  strDefect :=  QryData.FieldByName('DEFECT_DESC').AsString;
                  strQty :=  QryData.FieldByName('QTY').AsString;
                  strTotalQty := QryData.FieldByName('Total_QTY').AsString;
                  ExcelApp.Cells[i+3,1].Value := strCarry;
                  ExcelApp.Cells[i+3,2].Value := strDefect;
                  ExcelApp.Cells[i+3,3].Value := strQty;
                  ExcelApp.Cells[i+3,4].Value := strTotalQty;
                  ExcelApp.Cells[i+3,5].Value := QryData.FieldByName('rate').AsString;
                  QryData.Next;
             end;
        end;
        ExcelApp.Columns[1].ColumnWidth :=22;
        ExcelApp.Columns[2].ColumnWidth :=22;
        ExcelApp.Columns[3].ColumnWidth :=22;
        ExcelApp.Columns[4].ColumnWidth :=22;
        ExcelApp.Columns[5].ColumnWidth :=22;
        ExcelApp.ActiveSheet.Range['A1:E1'].Merge;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].VerticalAlignment :=2;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[4].Weight := 2;


        ExcelApp.ActiveSheet.SaveAs(dlgSave1.FileName);
        ExcelApp.Quit;

        MessageDlg('Save OK',mtInformation,[mbok],0);
    end;


end;

procedure TfMainForm.edtWOChange(Sender: TObject);
var i:Integer;
begin

    with QryTemp1 do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftstring,'WO',ptInput);


        CommandText :=' SELECT  C.Defect_Desc ,Count(*) qty FROM  SAJET.G_SN_DEFECT_FIRST B,'+
                      ' SAJET.SYS_DEFECT C WHERE   B.WORK_ORDER =:WO AND B.DEFECT_ID =C.DEFECT_ID '+
                      ' AND B.work_order=:WO AND B.STAGE_ID =10001 group by defect_desc order by qty desc ' ;
        Params.ParamByName('WO').AsString :=edtWO.Text;

        Open;

        First;
        for i:=0 to recordCount-1 do
        begin
            cmbDefect.Items.Add(fieldbyname('Defect_desc').AsString);
            next;
        end;


    end;
end;

procedure TfMainForm.dbgrd1DblClick(Sender: TObject);
begin
  //
end;

procedure TfMainForm.ds1DataChange(Sender: TObject; Field: TField);
begin
    QryTemp.Close;
    QryTemp.Params.Clear;

    QryTemp.Params.CreateParam(ftstring,'Defect',ptInput);
    QryTemp.Params.CreateParam(ftstring,'WO',ptInput);
    QryTemp.Params.CreateParam(ftstring,'Carry',ptInput);
    QryTemp.CommandText:='SELECT A.Serial_number ,A.Out_process_time,A.Container,C.Defect_Desc FROM SAJET.G_SN_TRAVEL A,SAJET.G_SN_DEFECT_FIRST B, '+
                         ' SAJET.SYS_DEFECT C WHERE A.SERIAL_NUMBER =B.SERIAL_NUMBER AND A.PROCESS_ID= 100187 and a.WORK_ORDER=:WO '+
                         ' AND B.DEFECT_ID =C.DEFECT_ID  AND A.CONTAINER <>''N/A'' AND B.STAGE_ID =10001   '+
                         ' AND C.DEFECT_DESC =:Defect and A.Container =:carry ';
    QryTemp.Params.ParamByName('WO').AsString :=EdtWO.Text;
    QryTemp.Params.ParamByName('Defect').AsString :=QryData.fieldByName('Defect_Desc').AsString;
    QryTemp.Params.ParamByName('Carry').AsString := QryData.fieldByName('Container').AsString;
    QryTemp.open;
end;

end.








