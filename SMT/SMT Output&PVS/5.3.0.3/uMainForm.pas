unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang,DateUtils,excel2000,ComObj;

type
  TfMainForm = class(TForm)
    sbtnClose: TSpeedButton;
    Image2: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SimpleObjectBroker1: TSimpleObjectBroker;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SocketConnection1: TSocketConnection;
    dsData: TDataSource;
    SaveDialog: TSaveDialog;
    QryDetail: TClientDataSet;
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    ImageAll: TImage;
    lbl1: TLabel;
    dtpStart: TDateTimePicker;
    cmbStart: TComboBox;
    lbl2: TLabel;
    dtpEnd: TDateTimePicker;
    cmbEnd: TComboBox;
    lbl3: TLabel;
    cmbLine: TComboBox;
    edtWo: TEdit;
    lbl4: TLabel;
    img1: TImage;
    btnQuery: TSpeedButton;
    imgSample: TImage;
    btnBtnExport: TSpeedButton;
    dbgrd1: TDBGrid;
    dlgSave1: TSaveDialog;
    lblVersion: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure dbgrd1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btnBtnExportClick(Sender: TObject);
    procedure dbgrd1DblClick(Sender: TObject);
    procedure GetVersion(S: string);

  public
    UpdateUserID: String;

  end;

var
  fMainForm: TfMainForm;


implementation




{$R *.dfm}

uses uDataDetail;

procedure TfMainForm.FormShow(Sender: TObject);
var i :integer;
begin
//------

    cmbLine.Style :=csDropDownList;
    dtpStart.Date :=  Now;
    dtpEnd.Date :=  tomorrow;
    GetVersion(ExtractFileDir(Application.ExeName) + '\SMTOutputPVSDll.Dll');

end;

procedure TfMainForm.btnQueryClick(Sender: TObject);
var starttime,endtime:string;
begin
    starttime := FormatDateTime('YYYYMMDD',dtpStart.date)+cmbStart.Text ;
    endtime := FormatDateTime('YYYYMMDD',dtpEnd.date)+cmbEnd.Text;

    QryData.Close;
    QryData.Params.Clear;
    if edtWo.Text = '' then
    begin
        QryData.Params.CreateParam(ftString,'StartTime',ptInput);
        QryData. Params.CreateParam(ftString,'EndTime',ptInput);
    end;
    QryData.CommandText := ' select aaa.work_order,aaa.target_qty,aaa.REQUEST_QTY,aaa.PART_NO ,aaa.SPEC1,aaa.total_output,BOM_QTY ,bbb.PVS_QTY  FROM   '+
           ' ( select a.work_order,a.target_qty,B.REQUEST_QTY ,C.PART_NO,C.SPEC1,sum(pass_qty+fail_qty) total_output,'+
           '  Ceil(sum(pass_qty+fail_qty)/a.target_qty*B.REQUEST_QTY) BOM_QTY '+
           ' from sajet.g_wo_base a,SAJET.G_WO_PICK_LIST b,sajet.sys_part c,SAJET.g_sn_count d ,sajet.sys_pdline e '+
           ' where a.work_order=b.work_order  and b.part_id=c.part_id  and a.work_order=d.work_order and d.pdline_id=e.pdline_id ';
    if edtWo.Text = '' then
         QryData.CommandText :=   QryData.CommandText  + ' and a.work_order in( select distinct work_order from sajet.g_sn_count where  '+
           ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) >=:StartTime  and '+
           ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) < :EndTime and process_id =100187 ) '
   else
         QryData.CommandText :=   QryData.CommandText  + ' and a.work_order like ''' +  edtWo.Text + '%''' ;

   if cmbLine.Text <> 'ALL' then
           QryData.CommandText :=   QryData.CommandText  + ' and e.pdline_name = '''+cmbLine.text+'''';

    QryData.CommandText :=   QryData.CommandText  +      ' and d.process_id =100187 '+
           ' group by a.work_order,a.target_qty,B.REQUEST_QTY,C.PART_NO ,C.Spec1 order by a.work_order,c.part_no )aaa,  '+
           ' ( select work_order,PART_NO,SUM(QTY) PVS_QTY FROM ( '+
            ' Select bb.work_order,AA.part_no, BB.REEL_NO,BB.QTY  from (                                                '+
           ' select A.WORK_ORDER,A.PDLINE_ID,C.PART_NO ,C.PART_ID,B.STATION_NO  '+
           ' from SMT.G_WO_MSL A, SMT.G_WO_MSL_DETAIL B ,sajet.sys_part c   '+
           ' WHERE  A.WO_SEQUENCE=B.WO_SEQUENCE AND b.Item_part_ID =c.part_id UNION '+
           ' select A.WORK_ORDER,A.PDLINE_ID,D.PART_NO ,D.PART_ID,B.STATION_NO   '+
           ' from  SMT.G_WO_MSL A, SMT.G_WO_MSL_DETAIL B,SMT.g_wo_msl_sub C,SAJET.SYS_PART D  '+
           ' where A.WO_SEQUENCE=B.WO_SEQUENCE  AND B.WO_SEQUENCE = C.WO_SEQUENCE  AND B.ITEM_PART_ID = C.ITEM_PART_ID AND D.PART_ID=C.SUB_PART_ID ) aa ,'+
           ' ( Select * from SMT.G_SMT_STATUS    union    select * from SMT.G_SMT_TRAVEL ) bb ,sajet.sys_pdline cc '+
           ' where aa.WORK_ORDER =bb.WORK_ORDER and bb.item_part_id = aa.part_id and bb.pdline_id=cc.pdline_id  and aa.pdline_id =bb.pdline_id  '+
            '  and aa.station_no =bb.station_no  ';
   if edtWo.Text = '' then
         QryData.CommandText :=   QryData.CommandText  + ' and aa.work_order in( select distinct work_order from sajet.g_sn_count where  '+
           ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) >=:StartTime  and '+
           ' to_number(to_char(WORK_DATE)|| TRIM(to_char(WORK_TIME,''00''))) < :EndTime and process_id =100187 ) '
   else
         QryData.CommandText :=   QryData.CommandText  + ' and aa.work_order like ''' +  edtWo.Text + '%''' ;

   if cmbLine.Text <> 'ALL' then
           QryData.CommandText :=   QryData.CommandText  + ' and cc.pdline_name = '''+cmbLine.text+'''' ;
    QryData.CommandText :=   QryData.CommandText  +
           ' GROUP BY bb.work_order,AA.part_no, BB.REEL_NO,BB.QTY )  GROUP BY work_order,part_no ) bbb  '+
           ' where aaa.work_order=bbb.work_order and aaa.part_no=bbb.part_no   '+
           ' order by aaa.work_order,aaa.part_no ';
    if edtWo.Text = '' then
    begin
       QryData.Params.ParamByName('StartTime').AsString := starttime;
       QryData.Params.ParamByName('EndTime').AsString := endtime;
    end;
    QryData.Open;

end;

procedure TfMainForm.dbgrd1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var BOM_QTY,PVS_QTY :integer;
begin
  //
    BOM_QTY :=QryData.fieldByName('BOM_QTY').AsInteger;
    PVS_QTY :=QryData.fieldByName('PVS_QTY').AsInteger;
    if PVS_QTY<BOM_QTY then begin
       dbgrd1.Canvas.Brush.Color:=clRed;
       dbgrd1.DefaultDrawColumnCell(Rect,DataCol,Column,State);
    end;
end;


procedure TfMainForm.btnBtnExportClick(Sender: TObject);
var ExcelApp: Variant; i: integer;
       sWO,sPN,sTarget,sRequest,sOutput,sBOM_Qty,sPVS_QTY,sSpec :STRING;
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
        ExcelApp.WorkSheets[1].Name :=  '在制工單上料產出對比表' ;
        ExcelApp.Cells[1,1].Value := '在制工單上料產出對比表';

        ExcelApp.Cells[2,1].Value := '工單';
        ExcelApp.Cells[2,2].Value := '料號';
        ExcelApp.Cells[2,3].Value := '料號描述';
        ExcelApp.Cells[2,4].Value := '工單總數';
        ExcelApp.Cells[2,5].Value := 'BOM發料數';
        ExcelApp.Cells[2,6].Value := '實際產出數';
        ExcelApp.Cells[2,7].Value := '應上料數';
        ExcelApp.Cells[2,8].Value := '實際上料數';

        ExcelApp.ActiveSheet.Range['A1:H1'].Merge;
        ExcelApp.ActiveSheet.Range['A1:H2'].Font.Size :=12;
        ExcelApp.ActiveSheet.Range['A1:H2'].Font.Bold :=true;
        ExcelApp.ActiveSheet.Range['A1:H2'].Interior.Color :=clYellow;
        for i:=1 to 7 do
          if i<> 3 then
           ExcelApp.Columns[i].ColumnWidth := 15;
        ExcelApp.Columns[3].ColumnWidth := 25;

        i:=0;
        if not QryData.IsEmpty then
        begin
            QryData.First;
            for  i:=0 to QryData.RecordCount-1  do
            begin
                  swo := QryData.FieldByName('WORK_ORDER').AsString ;
                  sPN := QryData.FieldByName('PART_NO').AsString ;
                  sTarget :=  QryData.FieldByName('TARGET_QTY').AsString;
                  sRequest :=  QryData.FieldByName('REQUEST_QTY').AsString;
                  sOutput :=  QryData.FieldByName('total_OUTPUT').AsString;
                  sBOM_Qty :=  QryData.FieldByName('BOM_QTY').AsString;
                  sPVS_QTY :=  QryData.FieldByName('PVS_QTY').AsString;
                  sSpec :=  QryData.FieldByName('SPEC1').AsString;

                  if QryData.FieldByName('PVS_QTY').AsInteger <  QryData.FieldByName('BOM_QTY').AsInteger then
                  begin
                       ExcelApp.ActiveSheet.Range['A'+IntToStr(I+3)+':H'+IntToStr(I+3)].Interior.Color :=clRed;
                  end;

                  ExcelApp.Cells[i+3,1].Value := sWO;
                  ExcelApp.Cells[i+3,2].Value := sPN;
                  ExcelApp.Cells[i+3,3].Value := sSpec;
                  ExcelApp.Cells[i+3,4].Value := sTarget;
                  ExcelApp.Cells[i+3,5].Value := sRequest;
                  ExcelApp.Cells[i+3,6].Value := sOutput;
                  ExcelApp.Cells[i+3,7].Value := sBOM_Qty;
                  ExcelApp.Cells[i+3,8].Value := sPVS_QTY;
                  QryData.Next;
            end;
        end;
        ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].VerticalAlignment :=2;
        ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[4].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[7].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[8].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[9].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:H'+IntToStr(I+2)].Borders[10].Weight := xlThick;
        ExcelApp.ActiveSheet.SaveAs(dlgSave1.FileName);
        ExcelApp.Quit;
    end;



end;

procedure TfMainForm.dbgrd1DblClick(Sender: TObject);
var sWO,sPartNo:string;
begin
   with TfDataDetail.Create(Self) do
   begin
      GradPanel1.Caption := 'Detail Data';
      swo:= QryData.FieldByName('WORK_ORDER').AsString;
      sPartNo:= QryData.FieldByName('Part_No').AsString;
      QuryDataDetail.RemoteServer := QryData.RemoteServer;

      QuryDataDetail.Close;
      QuryDataDetail.Params.Clear;
      QuryDataDetail.Params.CreateParam(ftString,'PART_NO',ptInput);
      QuryDataDetail.Params.CreateParam(ftString,'WO',ptInput);

      QuryDataDetail.CommandText := ' select aaa.work_order,aaa.PART_NO,aaa.target_qty,aaa.REQUEST_QTY ,aaa.total_output,aaa.bom_Need_qty , '+
          ' bbb.station_no,bbb.is_sub_part,bbb.In_time,bbb.out_time,bbb.qty,bbb.reel_no,bbb.emp_name,bbb.pdline_name,'+
          'round((decode(bbb.out_time,null,sysdate,bbb.out_time)-bbb.In_time)*24,2) diff_Time  from    '+
          ' (select a.work_order,a.target_qty,B.REQUEST_QTY ,C.PART_NO,sum(pass_qty+fail_qty) total_output,      '+
          ' ceil(sum(pass_qty+fail_qty)/a.target_qty*B.REQUEST_QTY) BOM_NEED_QTY from sajet.g_wo_base a,SAJET.G_WO_PICK_LIST b, '+
          ' sajet.sys_part c,SAJET.g_sn_count d,sajet.sys_pdline e where a.work_order=b.work_order  and b.part_id=c.part_id  and a.work_order=d.work_order    '+
          ' and a.work_order =:WO  and d.process_id =100187  and e.pdline_id =d.pdline_id ';
       if cmbLine.Text <>'ALL' then
          QuryDataDetail.CommandText :=   QuryDataDetail.CommandText  +  ' and e.pdline_name ='''+cmbline.Text+''' ';
       QuryDataDetail.CommandText :=   QuryDataDetail.CommandText  +
           ' group by a.work_order,a.target_qty,B.REQUEST_QTY,C.PART_NO ) aaa,          '+
          '   ( Select bb.work_order ,aa.station_no,aa.part_no,aa.is_sub_part,  '+
          ' bb.In_time,bb.out_time,bb.status,bb.datecode,bb.qty,bb.reel_no,dd.emp_Name,CC.PDLINE_NAME     '+
          ' from (                                                           '+
          ' select A.WORK_ORDER,A.PDLINE_ID,D.PART_NO,d.part_id,B.STATION_NO, ''0'' IS_SUB_PART      '+
          ' from SMT.G_WO_MSL A, SMT.G_WO_MSL_DETAIL B, sajet.sys_part D               '+
          ' where  A.WO_SEQUENCE =B.WO_SEQUENCE AND  D.PART_ID =B.ITEM_PART_ID                        '+
          ' UNION                                                     '+
          ' select A.WORK_ORDER,A.PDLINE_ID,D.PART_NO,d.part_id,B.STATION_NO  ,''1'' IS_SUB_PART    '+
          ' from SMT.G_WO_MSL A, SMT.G_WO_MSL_DETAIL B,smt.g_wo_msl_sub C ,sajet.sys_part D           '+
          ' where   A.WO_SEQUENCE =B.WO_SEQUENCE AND B.WO_SEQUENCE=C.WO_SEQUENCE  AND '+
          ' B.ITEM_PART_ID = C.ITEM_PART_ID AND  C.SUB_PART_ID =D.PART_ID ) aa,   '+
          ' (select * from SMT.G_SMT_STATUS                            '+
          ' union                                                      '+
          ' select * from SMT.G_SMT_TRAVEL ) bb ,sajet.sys_pdline cc ,sajet.sys_emp dd    '+
          ' where aa.WORK_ORDER =bb.WORK_ORDER and bb.item_part_id = aa.part_id  and   aa.pdline_id =bb.pdline_id and '+
          ' bb.pdline_id=cc.pdline_id and BB.EMP_ID =dd.EMP_ID and aa.part_no =:part_no ' ;
       if cmbLine.Text <>'ALL' then
          QuryDataDetail.CommandText :=   QuryDataDetail.CommandText  +  ' and cc.pdline_name ='''+cmbline.Text+''' ';
       QuryDataDetail.CommandText :=   QuryDataDetail.CommandText  +
          ' and aa.station_no =bb.station_no     ) bbb                              '+
          ' where aaa.work_order = bbb.work_order and aaa.part_no = bbb.part_no     '+
          ' order by work_order,part_no,station_no,in_Time ';
      QuryDataDetail.params.ParamByName('PART_NO').AsString :=sPartNO;
      QuryDataDetail.params.ParamByName('WO').AsString :=sWO;
      //QuryDataDetail.CommandText := 'select user from dual';
      QuryDataDetail.Open;

      GPRecords.Caption := IntToStr(QuryDataDetail.recordCount) ;
      Showmodal;
      Free;
   end;
end;

procedure TfMainForm.GetVersion(S: string);
  function HexToInt(HexNum: string): LongInt;
  begin
    Result := StrToInt('$' + HexNum);
  end;
var VersinInfo: Pchar; //版本資訊
  VersinInfoSize: DWord; //版本資訊size (win32 使用)
  pv_info: PVSFixedFileInfo; //版本格式
  Mversion, Sversion: string; //版本No
begin
  VersinInfoSize := GetFileVersionInfoSize(pchar(S), VersinInfoSize);
  VersinInfo := AllocMem(VersinInfoSize);
  try
    GetFileVersionInfo(pchar(S), 0, VersinInfoSize, Pointer(VersinInfo));
    VerQueryValue(pointer(VersinInfo), '\', pointer(pv_info), VersinInfoSize);
    Mversion := inttohex(pv_info.dwProductVersionMS, 0);
    Mversion := copy('00000000', 1, 8 - length(Mversion)) + Mversion;
    Sversion := inttohex(pv_info.dwProductVersionLS, 0);
    Sversion := copy('00000000', 1, 8 - length(Sversion)) + Sversion;
    lblVersion.Caption := 'Version: ' +
      FloatToStr(hextoint(copy(MVersion, 1, 4))) + '.' +
      FloatToStr(hextoint(copy(MVersion, 5, 4))) + '.' +
      FloatToStr(hextoint(copy(SVersion, 1, 4))) + '.' +
      FloatToStr(hextoint(copy(SVersion, 5, 4)));
  finally
    FreeMem(VersinInfo, VersinInfoSize);
  end;
end;


end.
