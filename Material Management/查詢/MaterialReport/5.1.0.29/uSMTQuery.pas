unit uSMTQuery;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   comobj, Variants,DBClient, StdCtrls, Buttons, DB, Grids, ComCtrls,  ExtCtrls,DateUtils,
  DBGrids,Spin;

type
   TDBGrid = class(DBGrids.TDBGrid)
   public
      function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
                             MousePos: TPoint): Boolean; override;
   end;
   TfMaterial = class(TForm)
    QryTemp: TClientDataSet;
    QryData: TClientDataSet;
    SaveDialog1: TSaveDialog;
    TlbReportFile: TClientDataSet;
    OpenDialog1: TOpenDialog;
    ImageAll: TImage;
    sbtnPrint: TSpeedButton;
    sbtnSave: TSpeedButton;
    sbtnQuery: TSpeedButton;
    Image8: TImage;
    DataSource1: TDataSource;
    Label3: TLabel;
    DataSource2: TDataSource;
    qrydata1: TClientDataSet;
    Bevel1: TBevel;
    Image3: TImage;
    Image1: TImage;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    DBGrid1: TDBGrid;
    TabSheet2: TTabSheet;
    DBGrid2: TDBGrid;
    TabSheet3: TTabSheet;
    sgOnline: TStringGrid;
    Memo1: TMemo;
    StatusBar2: TStatusBar;
    StatusBar3: TStatusBar;
    StatusBar1: TStatusBar;
    TabSheet4: TTabSheet;
    Panel1: TPanel;
    cmbPart: TComboBox;
    editwo: TEdit;
    Label1: TLabel;
    Label5: TLabel;
    labTime: TLabel;
    labProTime: TLabel;
    labProcess: TLabel;
    cmbProcess: TComboBox;
    SpinEdit1: TSpinEdit;
    labUnion: TLabel;
    sbtnpart: TSpeedButton;
    Panel2: TPanel;
    editPart: TEdit;
    editDateCode: TEdit;
    Label4: TLabel;
    Label2: TLabel;
    Panel3: TPanel;
    cmbSide: TComboBox;
    cmbMachine: TComboBox;
    Label8: TLabel;
    Label9: TLabel;
    edtWO: TEdit;
    cmbPdline: TComboBox;
    Label6: TLabel;
    Label7: TLabel;
    TabSheet5: TTabSheet;
    Panel5: TPanel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    editWODIP: TEdit;
    cmbStageDIP: TComboBox;
    cmbProcessDIP: TComboBox;
    cmbPdlineDIP: TComboBox;
    Panel4: TPanel;
    editFeeder: TEdit;
    cmbType: TComboBox;
    sgDIP: TStringGrid;
    StatusBar5: TStatusBar;
    StatusBar4: TStatusBar;
    TabSheet6: TTabSheet;
    sgBetch: TStringGrid;
    Panel6: TPanel;
    Label16: TLabel;
    Label17: TLabel;
    editWOBetch: TEdit;
    cmbPdlineBetch: TComboBox;
    StatusBar6: TStatusBar;
    qrytemp1: TClientDataSet;
    SpinEdit2: TSpinEdit;
    Label14: TLabel;
    Label15: TLabel;
    Image2: TImage;
    sbtnReset: TSpeedButton;
    qryFeeder: TClientDataSet;
    DBGrid3: TDBGrid;
    DataSource3: TDataSource;
    labLocator: TLabel;
    Label18: TLabel;
    cmbpdlineWO: TComboBox;
    cmbPdlineIDWO: TComboBox;
    procedure sbtnSaveClick(Sender: TObject);
    procedure sbtnPrintClick(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DBGrid1TitleClick(Column: TColumn);
    //procedure sbtnpartClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure editwoKeyPress(Sender: TObject; var Key: Char);
    procedure editwoChange(Sender: TObject);
    procedure cmbProcessChange(Sender: TObject);
    procedure sbtnResetClick(Sender: TObject);
    {procedure tsGrid11ClickCell(Sender: TObject; DataColDown, DataRowDown,
      DataColUp, DataRowUp: Integer; DownPos, UpPos: TtsClickPosition);}
    procedure sgOnlineSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure sgOnlineDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure edtWOKeyPress(Sender: TObject; var Key: Char);
    procedure edtWOChange(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure cmbStageDIPChange(Sender: TObject);
    procedure sgBetchDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgBetchSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure cmbpdlineWOChange(Sender: TObject);

  private
    { Private declarations }
    function CheckParam(var tParam:string;var SNFlag:string;var tWo:string):boolean;
    function GetProcessTime(tProcess,tSN:string;tDelay:integer;var tProcessTime:tDateTime):boolean;
    function CheckPart(tpart:string):boolean;
    procedure GetMaterialTime(tPart,tWOSeq:string;tProcessTime:tDateTime;var tTimeStrList:tStringlist);
    procedure SelectByPart(tPart,tDateCode:string);
    procedure SaveToExcel(Grid:TDBGrid;tFile:string);
    procedure SelectOnline;
    procedure selectFeeder;
    Procedure selectDIP;
    Procedure selectBetch;
    function getPdline(pdline_name:string):string;
    procedure cleartsgrids(var stringGrid:TstringGrid);
    function AddPDline(var cmb:TComboBox):boolean;
    function AddPDlineWO(wo:string;var cmb,cmbID:TComboBox):boolean;
    procedure MoveData(WO,Pdline:string);
    function AddMachine(WO:string):boolean;
    FUNCTION ADDSTAGE(var cmb:TComboBox):boolean;
    function addprocess(cmbstage:TComboBox;var cmbpro:TComboBox):boolean;
    function AddPdlineBetch(var cmb:TComboBox):boolean;
    function GetCycleTime(partNo:string;var CyTime:double):boolean;
    function GetWOQty(wo,partno:string;var R_qty,T_qty:integer):boolean;
  public
    { Public declarations }
    UpdateUserID: string;
    StrLstPartNo : TStringList;
    DINTime:tdate;

    DateRow:integer;
    sPart1,sPart2:string;
    SNType:string;
    procedure SaveExcel(MsExcel,MsExcelWorkBook:Variant;Grid:TDBGrid);
    Function DownloadSampleFile(tFile:string) : String;

  end;

var
   fMaterial: TfMaterial;

implementation

uses  uCheckEmp;

{$R *.DFM}
function TfMaterial.GetWOQty(wo,partno:string;var R_qty,T_qty:integer):boolean; //R_qty :wo  request qty ;T_qty : wo Target Qty ;
begin
  result:=false;
  with qrytemp do
  begin
    close;
    params.Clear;
    commandtext:=' select target_qty from sajet.g_wo_base where work_order= '''+wo+'''';
    open;
    if recordcount > 0 then
      T_qty:=fieldbyname('target_qty').AsInteger
    else exit;

    close;
    params.Clear;
    commandtext:=' select a.request_qty from sajet.g_wo_pick_list a,sajet.sys_part b '
                +' where a.part_id = b.part_id '
                +'       and a.work_order='''+wo+''''
                +'       and b.part_no= '''+partno+'''';
    open;
    if recordcount > 0 then
    begin
      R_qty:=fieldbyname('request_qty').AsInteger;
      result:=true;
    end
    else exit;
  end;
end;

function TfMaterial.GetCycleTime(partNo:string; var CyTime:double):boolean;
var sField :string;
    tCytime:string;
begin
  result:=false;
  sField:='';
  cyTime:=0;
  with qrytemp do
  begin
    close;
    params.Clear;
    commandtext:=' select param_value '
                +' from sajet.sys_base '
                +' where param_name=''Cycle Time Field'' ';
    open;
    if recordcount>0 then
      sField:=fieldbyname('param_value').AsString
    else exit;

    close;
    params.Clear;
    commandtext:=' select '+sField
                +' from sajet.sys_part '
                +' where part_no = '''+partno+'''';
    open;
    if recordcount>0 then
       tCytime:=fieldbyname(sField).AsString;
    try
      CyTime:=strtofloat(tCytime);
      result:=true;
    Except
    end;
  end;
end;
Procedure TfMaterial.selectBetch;
var iRow,Target_qty,Request_qty:integer;
    tCycleTime:double;
    T1:tDate;
begin
  T1:= Time;
  cleartsgrids(sgBetch);
  with qrytemp1 do
  begin
    close;
    params.Clear;
    if (trim(editWOBetch.Text)<>'') and (cmbpdlineBetch.ItemIndex<>0) then
    begin
     if cmbpdlineBetch.ItemIndex<>0 then
        params.CreateParam(ftString	,'iPDname', ptInput);
     if trim(editWOBetch.Text)<>'' then
        params.CreateParam(ftString	,'iWO', ptInput);
     commandtext:=' select b1.work_order,d1.part_no,f1.pdline_name,a1.datecode,g1.vendor_name,to_char(a1.qty) qty,to_char(a1.in_time,''YYYY/MM/DD HH24:MI:SS'') in_time ,e1.emp_name,a1.MFGER_NAME,a1.MFGER_PART_NO '
                 +' from smt.g_smt_status a1,smt.g_wo_msl b1,smt.g_wo_msl_detail c1,sajet.sys_part d1,sajet.sys_emp e1 ,sajet.sys_pdline f1,sajet.sys_vendor g1 '
                 +' where a1.wo_sequence =b1.wo_sequence '
                 +'     and b1.wo_sequence=c1.wo_sequence '
					       +'     and a1.item_part_id=d1.part_id  '
					       +'     and a1.emp_id=e1.emp_id   '
					       +'     and a1.pdline_id=f1.pdline_id '
                 +'     and a1.wo_sequence like ''00%'' '
                 +'     and a1.vendor_id=g1.vendor_id(+) ';
     if trim(editWOBetch.Text)<>'' then
       commandtext:=commandtext+'   and b1.work_order =:iWO';
     if cmbPdlineBetch.ItemIndex<>0 then
       commandtext:=commandtext+'   and f1.pdline_name=:iPDname ';
     commandtext:=commandtext
                +' union  '
                +' select b2.work_order,d2.part_no,'''' pdline_name,'''' datecode,'''' vendor_name,'''' qty,'''' in_time,'''' emp_name,'''' MFGER_NAME,'''' MFGER_PART_NO  '
                +' from smt.g_wo_msl b2,smt.g_wo_msl_detail c2,sajet.sys_part d2'
                +' where b2.wo_sequence=c2.wo_sequence '
					      +'       and c2.item_part_id=d2.part_id  '
                +'       and b2.wo_sequence like ''00%'' ';
     if trim(editWOBetch.Text)<>'' then
       commandtext:=commandtext+'   and b2.work_order =:iWO ';
     commandtext:=commandtext+' order by work_order,part_no,pdline_name ,datecode ';
     if trim(editWOBetch.Text)<>'' then
       Params.ParamByName('iWO').AsString :=trim(editWOBetch.Text);
     if cmbPdlineBetch.ItemIndex<>0 then
       Params.ParamByName('iPDname').AsString := trim(cmbPdlineBetch.Text);
     memo1.Text:=commandtext;
    //exit;
     open;
     if recordcount > 0 then
     begin
       iRow:=1;
       while not eof do
       begin
         //if (sgBetch.Cells[3,iRow-1]='') and (sgBetch.Cells[1,iRow-1]=fieldbyname('work_order').AsString) and
         if (sgBetch.Cells[1,iRow-1]<>fieldbyname('work_order').AsString) or (sgBetch.Cells[2,iRow-1]<>fieldbyname('part_no').AsString)
            or (fieldbyname('in_time').AsString<>'') then
         begin
           sgBetch.RowHeights[iRow]:=16;
           sgBetch.Cells[1,iRow]:=fieldbyname('work_order').AsString;
           sgBetch.Cells[2,iRow]:=fieldbyname('part_no').AsString;
           sgBetch.Cells[3,iRow]:=fieldbyname('pdline_name').AsString;
           sgBetch.Cells[4,iRow]:=fieldbyname('datecode').asstring;
           sgBetch.Cells[5,iRow]:=fieldbyname('vendor_name').AsString;
           sgBetch.Cells[6,iRow]:=fieldbyname('qty').asstring;
           sgBetch.Cells[7,iRow]:=fieldbyname('in_time').AsString;
           if fieldbyname('qty').AsString<>'' then
            if  fieldbyname('in_time').AsString<>'' then
             if GetCycleTime(fieldbyname('part_no').AsString,tCycleTime) then
               if GetWOQty(fieldbyname('work_order').AsString,fieldbyname('part_no').AsString,Request_qty,Target_qty) then
               BEGIN
                  sgBetch.Cells[8,iRow]:=formatdatetime('YYYY/MM/DD HH:MM:SS',fieldbyname('in_time').asdatetime+((fieldbyname('qty').AsInteger*Target_qty*tCycleTime)/Request_qty)*1/(60*60*24) );
                  //SHOWMESSAGE(FIELDBYNAME('IN_TIME').ASSTRING);
               END;
           sgBetch.Cells[9,iRow]:=fieldbyname('emp_name').AsString;
           sgBetch.Cells[10,iRow]:=fieldbyname('MFGER_NAME').AsString;
           sgBetch.Cells[11,iRow]:=fieldbyname('MFGER_PART_NO').AsString;
           inc(iRow);
           sgBetch.RowCount:=iRow+1;
         end;
         next;
       end;
     end;
    end
    else begin
     close;
     params.Clear;
     if cmbpdlineBetch.ItemIndex<>0 then
        params.CreateParam(ftString	,'iPDname', ptInput);
     if trim(editWOBetch.Text)<>'' then
        params.CreateParam(ftString	,'iWO', ptInput);
     commandtext:=' select b1.work_order,d1.part_no,f1.pdline_name,a1.datecode,g1.vendor_name,to_char(a1.qty) qty,to_char(a1.in_time,''YYYY/MM/DD HH24:MI:SS'') in_time ,e1.emp_name,a1.MFGER_NAME,a1.MFGER_PART_NO '
                 +' from smt.g_smt_status a1,smt.g_wo_msl b1,smt.g_wo_msl_detail c1,sajet.sys_part d1,sajet.sys_emp e1 ,sajet.sys_pdline f1,sajet.sys_vendor g1 '
                 +' where a1.wo_sequence =b1.wo_sequence '
                 +'     and b1.wo_sequence=c1.wo_sequence '
					       +'     and a1.item_part_id=d1.part_id  '
					       +'     and a1.emp_id=e1.emp_id   '
					       +'     and a1.pdline_id=f1.pdline_id '
                 +'     and a1.wo_sequence like ''00%'' '
                 +'     and a1.vendor_id=g1.vendor_id(+) ';
     if trim(editWOBetch.Text)<>'' then
       commandtext:=commandtext+'   and b1.work_order =:iWO';
     if cmbPdlineBetch.ItemIndex<>0 then
       commandtext:=commandtext+'   and f1.pdline_name=:iPDname ';
       
     if trim(editWOBetch.Text)<>'' then
       Params.ParamByName('iWO').AsString :=trim(editWOBetch.Text);
     if cmbPdlineBetch.ItemIndex<>0 then
       Params.ParamByName('iPDname').AsString := trim(cmbPdlineBetch.Text);
     open;
     if recordcount > 0 then
     begin
       iRow:=1;
       while not eof do
       begin
           sgBetch.RowHeights[iRow]:=16;
           sgBetch.Cells[1,iRow]:=fieldbyname('work_order').AsString;
           sgBetch.Cells[2,iRow]:=fieldbyname('part_no').AsString;
           sgBetch.Cells[3,iRow]:=fieldbyname('pdline_name').AsString;
           sgBetch.Cells[4,iRow]:=fieldbyname('datecode').asstring;
           sgBetch.Cells[5,iRow]:=fieldbyname('vendor_name').AsString;
           sgBetch.Cells[6,iRow]:=fieldbyname('qty').asstring;
           sgBetch.Cells[7,iRow]:=fieldbyname('in_time').AsString;
           if fieldbyname('qty').AsString<>'' then
            if  fieldbyname('in_time').AsString<>'' then
             if GetCycleTime(fieldbyname('part_no').AsString,tCycleTime) then
               if GetWOQty(fieldbyname('work_order').AsString,fieldbyname('part_no').AsString,Request_qty,Target_qty) then
               BEGIN
                  sgBetch.Cells[8,iRow]:=formatdatetime('YYYY/MM/DD HH:MM:SS',fieldbyname('in_time').asdatetime+((fieldbyname('qty').AsInteger*Target_qty*tCycleTime)/Request_qty)*1/(60*60*24) );
                  //SHOWMESSAGE(FIELDBYNAME('IN_TIME').ASSTRING);
               END;
           sgBetch.Cells[9,iRow]:=fieldbyname('emp_name').AsString;
           sgBetch.Cells[10,iRow]:=fieldbyname('MFGER_NAME').AsString;
           sgBetch.Cells[11,iRow]:=fieldbyname('MFGER_PART_NO').AsString;
           inc(iRow);
           sgBetch.RowCount:=iRow+1;
           next;
       end;
     end;
    end;
  end;
  sgBetch.RowCount:=sgBetch.RowCount-1;
  statusbar6.panels[0].Text:='Records: '+inttostr(sgBetch.RowCount-1)+' ';
  statusbar6.Panels[1].Text:='  The search cost you '+IntToStr(MilliSecondsBetween(Time,T1))+' MilliSeconds.'

end;

function TfMaterial.AddPdlineBetch(var cmb:TComboBox):boolean;
begin
  result:=false;
  cmb.Clear;
  with qrytemp do
  begin
    close;
    params.Clear;
    commandtext:=' select distinct b.pdline_name '
                +' from smt.g_smt_status a,sajet.sys_pdline b '
                +' where a.pdline_id = b.pdline_id '
                +'      and wo_sequence like ''00%'' ';
    open;
    if recordcount>0 then
    begin
      cmb.Items.Add('ALL');
      while not eof do
      begin
        cmb.Items.Add(fieldbyname('pdline_name').AsString);
        next;
      end;
    end;
  end;
  cmb.ItemIndex:=0;
end;

function  TfMaterial.addstage(var cmb:TComboBox):boolean;
begin
  result:=false;
  cmb.Clear;
  with qrytemp do
  begin
    close;
    params.Clear;
    commandtext:=' select distinct b.stage_name '
                +' from smt.g_smt_status a,sajet.sys_stage b '
                +' where a.stage_id=b.stage_id ';
    open;
    if recordcount>0 then
    begin
      cmb.Items.Add('ALL');
       while not eof do
       begin
         cmb.Items.Add(fieldbyname('stage_name').AsString);
         next;
       end;
       cmb.ItemIndex:=0;
       result:=true;
    end;
  end;

end;

function TfMaterial.addprocess(cmbstage:TComboBox;var cmbpro:TComboBox):boolean;
begin
  result:=false;
  cmbpro.Clear;
  with qrytemp do
  begin
    close;
    params.Clear;
    commandtext:=' select distinct Process_name '
                +' from smt.g_smt_status a,sajet.sys_stage b,sajet.sys_process c '
                +' where a.stage_id=b.stage_id '
                +'       and a.process_id=c.Process_id '
                +'       and b.stage_name = '''+trim(cmbstageDIP.Text)+''' ';
    open;
    memo1.Text:=commandtext;
    if recordcount>0 then
    begin
       cmbpro.Items.Add('ALL');
       while not eof do
       begin
         cmbpro.Items.Add(fieldbyname('process_name').AsString);
         next;
       end;
       cmbPro.ItemIndex:=0;
       result:=true;
    end;
  end;
end;

Procedure TfMaterial.selectDIP;
var sCondition:string;
    iRow:integer;
    T1:tDate;
begin
  T1:= Time;
  cleartsgrids(sgDIP);
  with qrytemp do
  begin
    close;
    params.Clear;
    commandtext:=' select SUBSTR(wo_sequence,3,length(wo_sequence)) work_order,g.pdline_name,b.stage_name,c.process_name,d.part_no,a.datecode,f.vendor_name,a.qty,to_char(in_time,''YYYY/MM/DD HH24:MI:ss'') in_time '
                +'       ,e.emp_name,a.mfger_name,a.mfger_part_no '
                +' from smt.g_smt_status a,sajet.sys_stage b,sajet.sys_process c,sajet.sys_part d '
                +'          ,sajet.sys_emp e,sajet.sys_vendor f,sajet.sys_pdline g '
                +' where a.stage_id=b.stage_id(+) '
                +'      and a.process_id = c.process_id(+) '
                +'      and a.item_part_id = d.part_id '
                +'      and a.emp_id = e.emp_id '
                +'      and a.station_no is not null '
                +'      and a.vendor_id=f.vendor_id(+) '
                +'      and a.pdline_id = g.pdline_id(+) ';
    if trim(editWODIP.Text)<>'' then
       commandtext:=commandtext+' and a.wo_sequence like ''%'+trim(editWODIP.Text)+'''';
    if (trim(cmbStageDIP.Text)<>'') and (cmbStageDIP.ItemIndex<>0) then
       commandtext:=commandtext+' and b.stage_name = '''+trim(cmbStageDIP.Text)+'''';
    if (trim(cmbProcessDIP.Text)<>'') and (cmbProcessDIP.ItemIndex<>0) then
       commandtext:=commandtext+' and c.process_name = '''+trim(cmbProcessDIP.Text)+'''';
    if (trim(cmbPdlineDIP.Text)<>'') and (cmbpdlineDIP.ItemIndex<>0) then
       commandtext:=commandtext+' and  g.pdline_name = '''+trim(cmbpdlineDIP.Text)+'''';
    memo1.Text:=commandtext;
    open;

    if recordcount>0 then
    begin
      iRow:=1;
      sgDIP.RowCount:=recordcount+1;
      while not eof do
      begin
        sgDIP.RowHeights[iRow]:=16;
        sgDIP.Cells[1,iRow]:= fieldbyname('work_order').AsString;
        sgDIP.Cells[2,iRow]:= fieldbyname('pdline_name').AsString;
        sgDIP.Cells[3,iRow]:= fieldbyname('stage_name').AsString;
        sgDIP.Cells[4,iRow]:= fieldbyname('process_name').AsString;
        sgDIP.Cells[5,iRow]:= fieldbyname('part_no').AsString;
        sgDIP.Cells[6,iRow]:= fieldbyname('datecode').AsString;
        sgDIP.Cells[7,iRow]:= fieldbyname('vendor_name').AsString;
        sgDIP.Cells[8,iRow]:= fieldbyname('QTY').AsString;
        sgDIP.Cells[9,iRow]:= fieldbyname('in_time').AsString;
        sgDIP.Cells[10,iRow]:= fieldbyname('emp_name').AsString;
        sgDIP.Cells[11,iRow]:= fieldbyname('mfger_name').AsString;
        sgDIP.Cells[12,iRow]:= fieldbyname('mfger_part_no').AsString;
        inc(iRow);
        next;
      end;
      //sgDIP.RowCount:=iRow-1;
    end;
  end;
  statusbar5.panels[0].Text:='Records: '+inttostr(qrytemp.recordcount)+' ';
  statusbar5.Panels[1].Text:='  The search cost you '+IntToStr(MilliSecondsBetween(Time,T1))+' MilliSeconds.';
end;

procedure TfMaterial.selectFeeder;
var iRow,i:integer;
    T1:tDate;
begin
  T1:= Time;
  //cleartsgrids(sgFeeder);
 if cmbType.ItemIndex=0 then
 begin
   with qryFeeder do
  begin
    close;
    params.Clear;
    params.CreateParam(ftString	,'iFeeder', ptInput);
    commandtext:=' select a.wo_sequence,b.pdline_name,c.part_no,d.emp_name,to_char(a.in_time,''yyyy/mm/dd hh24:mi:ss'') in_time '
                            +' ,a.feeder_no,a.reel_no,e.vendor_name,a.datecode,a.MFGER_NAME,a.MFGER_PART_NO   '
                   +' from smt.g_smt_status a,sajet.sys_pdline b,sajet.sys_part c,sajet.sys_emp d,sajet.sys_vendor e '
                   +' where a.Feeder_NO=:iFeeder '
                   +'       and a.pdline_id=b.pdline_id(+) '
                   +'       and a.item_part_id=c.part_id '
                   +'       and a.emp_id = d.emp_id(+) '
                   +'       and a.vendor_id=e.vendor_id(+) ' ;
    Params.ParamByName('iFeeder').AsString :=trim(editFeeder.Text);
    open;
    if isEmpty then
    begin
      LabLocator.Caption:='No Feeder';
      LabLocator.Font.Color:=clRed;
    end;
  end;
 end
 else if cmbType.ItemIndex=1 then
 begin
   with qryFeeder do
   begin
     close;
     params.Clear;
     params.CreateParam(ftString	,'iReel', ptInput);
     commandtext:=' select a.wo_sequence,b.pdline_name,c.part_no,d.emp_name,to_char(a.in_time,''yyyy/mm/dd hh24:mi:ss'') in_time '
                            +' ,a.feeder_no,a.reel_no,e.vendor_name,a.datecode,a.MFGER_NAME,a.MFGER_PART_NO   '
                   +' from smt.g_smt_status a,sajet.sys_pdline b,sajet.sys_part c,sajet.sys_emp d,sajet.sys_vendor e '
                   +' where a.Reel_no=:iReel '
                   +'       and a.pdline_id=b.pdline_id(+) '
                   +'       and a.item_part_id=c.part_id '
                   +'       and a.emp_id = d.emp_id(+) '
                   +'       and a.vendor_id=e.vendor_id(+) ' ;
     Params.ParamByName('iReel').AsString :=trim(editFeeder.Text);
     open;
     if IsEmpty then
     begin
      close;
      params.Clear;
      params.CreateParam(ftString	,'iReel', ptInput);
      commandtext:=' select a.wo_sequence,b.pdline_name,c.part_no,d.emp_name,to_char(a.in_time,''yyyy/mm/dd hh24:mi:ss'') in_time '
                            +' ,to_char(a.out_time,''yyyy/mm/dd hh24:mi:ss'') out_time,a.station_no,a.feeder_no,a.reel_no,e.vendor_name,a.datecode,a.MFGER_NAME,a.MFGER_PART_NO   '
                   +' from smt.g_smt_travel a,sajet.sys_pdline b,sajet.sys_part c,sajet.sys_emp d,sajet.sys_vendor e '
                   +' where a.Reel_no=:iReel '
                   +'       and a.pdline_id=b.pdline_id(+) '
                   +'       and a.item_part_id=c.part_id '
                   +'       and a.emp_id = d.emp_id(+) '
                   +'       and a.vendor_id=e.vendor_id(+) ' ;
      Params.ParamByName('iReel').AsString :=trim(editFeeder.Text);
      open;
      if isEmpty then
      begin
       close;
       params.Clear;
       params.CreateParam(ftString	,'iMaterial', ptInput);
       commandtext:=' select a.work_order,a.material_no,b.part_no,a.qty,c.emp_name,a.update_time,a.sequence  '
                   +' from sajet.g_pick_list a,sajet.sys_part b, sajet.sys_emp c '
                   +' where a.part_id=b.part_id '
                   +'      and a.update_userid=c.emp_id '
                   +'      and a.material_no=:iMaterial ';
       Params.ParamByName('iMaterial').AsString :=trim(editFeeder.Text);
       open;
       if isEmpty then
       begin
         close;
         params.Clear;
         params.CreateParam(ftString	,'iMaterial', ptInput);
         commandtext:=' select a.material_no,b.part_no,a.material_qty,a.reel_no,a.reel_qty,a.datecode,d.warehouse_name,e.locate_name,a.update_time,c.emp_no,a.mfger_name,a.mfger_part_no,a.status '
                     +' from sajet.g_material a,sajet.sys_part b,sajet.sys_emp c,sajet.sys_warehouse d,sajet.sys_locate e  '
                     +' where a.part_id=b.part_id '
                     +'   and  a.warehouse_id=d.warehouse_id(+) '
                     +'   and  a.locate_id=e.locate_id(+) '
                     +'   and  a.update_userid=c.emp_id(+) '
                     +'   and  ((a.material_no=:iMaterial) or (a.reel_no=:iMaterial)) '
                     +' order by a.reel_no,a.material_no ';
         Params.ParamByName('iMaterial').AsString :=trim(editFeeder.Text);
         open;
         memo1.Text:=commandtext;
         if not isEmpty then
         begin
           if fieldbyname('status').AsString='1' then
           begin
             LabLocator.Caption:='In Store';
             LabLocator.Font.Color:=clNavy;
           end
           else begin
             LabLocator.Caption:='Not In Store';
             LabLocator.Font.Color:=clFuchsia;
           end;
         end
         else begin
           LabLocator.Caption:='NO Material NO';
           LabLocator.Font.Color:=clRed;
         end;
       end
       else begin
         labLocator.Caption:='Have Picked';
         LabLocator.Font.Color:=clNavy;
       end;
      end
      else begin
         labLocator.Caption:='Have USED';
         LabLocator.Font.Color:=clNavy;
      end;
     end
     else begin
         labLocator.Caption:='In Machine';
         LabLocator.Font.Color:=clNavy;
     end;
   end;
  end;
  for i:=0 to dbgrid3.Columns.Count-1 do
     if dbgrid3.Columns[i].Width>250 then
        dbgrid3.Columns[i].Width:=250;
  statusbar4.panels[0].Text:='Records: '+inttostr(qryFeeder.recordcount)+' ';
  statusbar4.Panels[1].Text:='  The search cost you '+IntToStr(MilliSecondsBetween(Time,T1))+' MilliSeconds.'

end;

function TfMaterial.AddMachine(WO:string):boolean;
begin
  result:=false;
  cmbMachine.Items.Clear;
  with qrytemp do
  begin
    close;
    params.Clear;
    params.CreateParam(ftString	,'iWo', ptInput);
    commandtext:=' select distinct b.machine_code from smt.g_wo_msl a,sajet.sys_machine b '
                +' where a.machine_id=b.machine_id '
                +'       and a.work_order=:iWO ';
    Params.ParamByName('iWO').AsString :=wo;
    open;
    if recordcount>0 then
    begin
      result:=true;
      cmbMachine.Items.Add('ALL');
      while not eof do
      begin
        cmbMachine.Items.Add(fieldbyname('machine_code').AsString);
        next;
      end;
    end;
  end;
end;

procedure TfMaterial.MoveData(WO,pdline:string);
var sWOSeq:tstringlist;
    i:integer;
    PdlineID:string;
    tWOSeq:string;
begin
  sWoSeq:=tstringlist.Create;
  tWOSeq:='00'+wo;
  with qrytemp do
  begin
    close;
    params.Clear;
    params.CreateParam(ftString	,'iWo', ptInput);
    params.CreateParam(ftString	,'iWoSeq', ptInput);
    commandtext:= ' select wo_sequence '
                 +' from smt.g_wo_msl '
                 +' where work_order=:iWO '
                 +'      and wo_sequence=:iWoSeq ';
    Params.ParamByName('iWO').AsString :=wo;
    Params.ParamByName('iWoSeq').AsString :=tWOSeq;
    open;
    while not eof do
    begin
      sWoSeq.Add(fieldbyname('wo_sequence').AsString);
      next;
    end;

    close;
    params.Clear;
    params.CreateParam(ftString	,'iPdline', ptInput);
    commandtext:=' select pdline_id from sajet.sys_pdline where pdline_name=:iPdline ';
    Params.ParamByName('iPdline').AsString := Pdline;
    open;
    PdlineID:=fieldbyname('pdline_id').AsString;
    if sWoseq.Count>0 then
      for i:=0 to sWoseq.Count-1 do
      begin
        close;
        params.Clear;
        params.CreateParam(ftString	,'iWoSeq', ptInput);
       // params.CreateParam(ftString	,'iNow', ptInput);
        params.CreateParam(ftString	,'iPdline', ptInput);
        params.CreateParam(ftString	,'iEMp', ptInput);
       { commandtext:=' UPDATE SMT.G_SMT_STATUS  '
                    +'  SET  OUT_TIME  =:iNow , '
                    +'       out_emp_id = :iEMP '
                    +' WHERE WO_SEQUENCE=:iWOseq  '
                    +'     and PDLINE_ID=:iPdline ';
        Params.ParamByName('iWOseq').AsString := sWOseq.Strings[i];
        Params.ParamByName('iNow').AsDateTime :=  now();
        }
        commandtext:=' UPDATE SMT.G_SMT_STATUS  '
                    +'  SET  OUT_TIME  = sysdate , '
                    +'       out_emp_id = :iEMP '
                    +' WHERE WO_SEQUENCE=:iWOseq  '
                    +'     and PDLINE_ID=:iPdline ';
        Params.ParamByName('iWOseq').AsString := sWOseq.Strings[i];
        //Params.ParamByName('iNow').AsDateTime :=  now();
        Params.ParamByName('iPdline').AsString := PdlineID;
        Params.ParamByName('iEMP').AsString := UpdateUserID;
        execute;

        close;
        params.Clear;
        params.CreateParam(ftString	,'iWoSeq', ptInput);
        params.CreateParam(ftString	,'iPdline', ptInput);
        commandtext:=' INSERT INTO SMT.G_SMT_TRAVEL  '
                    +'   SELECT * FROM SMT.G_SMT_STATUS  '
                    +'  WHERE WO_SEQUENCE=:iWOseq '
                    +'     and PDLINE_ID=:iPdline ';
        Params.ParamByName('iWOseq').AsString := sWOseq.Strings[i];
        Params.ParamByName('iPdline').AsString := PdlineID;
        execute;

        close;
        params.Clear;
        params.CreateParam(ftString	,'iWoSeq', ptInput);
        params.CreateParam(ftString	,'iPdline', ptInput);
        commandtext:='  DELETE SMT.G_SMT_STATUS  '
                    +'  WHERE WO_SEQUENCE=:iWOseq  '
                    +'     and PDLINE_ID=:iPdline ';
        Params.ParamByName('iWOseq').AsString := sWOseq.Strings[i];
        Params.ParamByName('iPdline').AsString := PdlineID;
        execute;
      end;

  end;
  sWoSeq.Free;
end;

function TfMaterial.AddPDline(var cmb:TComboBox):boolean;
begin
  cmb.clear;
  with qrytemp do
  begin
    close;
    params.Clear;
    commandtext:=' select distinct b.pdline_name '
                +' from smt.g_smt_status a,sajet.sys_pdline b '
                +' where a.pdline_id = b.pdline_id ';
    open;
    if Recordcount>0 then
    begin
      cmb.Items.Add('ALL');
      while not eof do
      begin
      cmb.Items.Add(fieldbyname('pdline_name').AsString);
      next;
      end;
      cmb.ItemIndex:=0;
    end;
  end;
end;

procedure TfMaterial.cleartsgrids(var stringgrid:TstringGrid);
var i,j:integer;
begin
  for i:=1 to stringgrid.RowCount-1 do
  begin
    for j:= 1 to stringgrid.ColCount-1 do
      stringgrid.Cells[j,i]:='';
  end;
  stringgrid.rowcount:=3;
end;
function TfMaterial.getPdline(pdline_name:string):string;
begin
  result:='';
  with qrytemp do
  begin
    close;
    params.clear;
    params.CreateParam(ftString	,'iPDname', ptInput);
    commandtext:=' select pdline_id from sajet.sys_pdline '
                +' where pdline_name=:iPDname '
                +'      and rownum=1 ';
    Params.ParamByName('iPDname').AsString :=pdline_name;
    open;
    if recordcount>0 then
      result:=fieldbyname('pdline_id').AsString;
  end;
end;
procedure TfMaterial.SelectOnline;
var pdline_id,sStation:string;
    iRow:integer;
    T1:tDate;
begin
  T1:= Time;
  sStation:='';
  cleartsgrids(sgOnline);
  if cmbpdline.ItemIndex<>0 then
     pdline_id:=getPdline(trim(cmbPdline.Text));
  with qrytemp do
  begin

    IF (CMBPDLINE.ItemIndex<>0) and (trim(edtwo.Text)<>'') THEN
    BEGIN
     close;
     params.Clear;
     if cmbpdline.ItemIndex<>0 then
        params.CreateParam(ftString	,'iPDname', ptInput);
     if trim(edtWO.Text)<>'' then
        params.CreateParam(ftString	,'iWO', ptInput);
     if trim(cmbSide.Text)<>'All' then
        params.CreateParam(ftString	,'iSide', ptInput);
     if cmbMachine.Visible then
        if cmbMachine.ItemIndex<>0 then
          params.CreateParam(ftString	,'iMachine', ptInput);

     commandtext:=' select a1.work_order,decode(to_char(a1.side),''0'',''Top'',''1'',''Bottom'') side,b1.station_no,d1.part_no,f1.pdline_name,c1.datecode,TO_CHAR(c1.qty) QTY,g1.emp_name,To_CHAR(c1.in_time,''YYYY/MM/DD HH24:MI:SS'') IN_TIME,TO_CHAR(c1.item_part_id) flag '
                +' ,c1.reel_no,c1.MFGER_NAME,c1.MFGER_PART_NO,H1.MACHINE_CODE '
                +' from smt.g_wo_msl a1,smt.g_wo_msl_detail b1,smt.g_smt_status  c1,sajet.sys_part d1,sajet.sys_pdline  f1,sajet.sys_emp g1,sajet.sys_machine h1  '
                +' where a1.wo_sequence=b1.wo_sequence '
                +'      and b1.item_part_id=d1.part_id '
                +'      and c1.pdline_id = f1.pdline_id(+) '
                +'      and c1.emp_id = g1.emp_id(+) '
                +'      and b1.wo_sequence=c1.wo_sequence '
                +'      and b1.item_part_id=c1.item_part_id  '
                +'      and b1.station_no=c1.station_no '
                +'      AND A1.MACHINE_ID=H1.MACHINE_ID(+) ';
      if trim(edtWO.Text)<>'' then
      begin
        commandtext:=commandtext+' and a1.work_order=:iWO ';
        if cmbpdline.ItemIndex<>0 then
          commandtext:=commandtext+ ' and c1.pdline_id(+)=:iPDname ';
      end
      else if cmbpdline.ItemIndex<>0 then
        commandtext:=commandtext+ ' and c1.pdline_id=:iPDname ';

      if trim(cmbSide.Text)<>'All' then
        commandtext:=commandtext+' and a1.side=:iSide ';

      if cmbMachine.Visible then
        if cmbMachine.ItemIndex<>0 then
          commandtext:=commandtext+' and h1.machine_code=:iMachine ';
          
      commandtext:=commandtext
                +' union '
                +' select a2.work_order,decode(to_char(a2.side),''0'',''Top'',''1'',''Bottom'') side,b2.station_no,d2.part_no,'''' pdline_name,'''' datecode,'''' qty,'''' emp_name,'''' in_time,'''' flag '
                +'   ,'''' reel_no,'''' MFGER_NAME,'''' MFGER_PART_NO,H2.MACHINE_CODE  '
                +' from smt.g_wo_msl a2,smt.g_wo_msl_detail b2,sajet.sys_part d2,sajet.sys_machine h2 '
                +' where a2.wo_sequence=b2.wo_sequence '
                +'       and b2.item_part_id=d2.part_id '
                +'       and a2.machine_id=h2.machine_id(+) ';
      if trim(edtWO.Text)<>'' then
        commandtext:=commandtext+' and a2.work_order=:iWO ';
      if cmbpdline.ItemIndex<>0 then
        commandtext:=commandtext+ ' and a2.pdline_id(+)=:iPDname ';
      if cmbMachine.Visible then
        if cmbMachine.ItemIndex<>0 then
          commandtext:=commandtext+' and h2.machine_code=:iMachine ';

      if trim(cmbSide.Text)<>'All' then
        commandtext:=commandtext+' and a2.side=:iSide ';
        
      commandtext :=commandtext+' order by PART_NO,machine_code,station_no ';
      if cmbpdline.ItemIndex<>0 then
        Params.ParamByName('iPDname').AsString := pdline_id;
      if trim(edtWO.Text)<>'' then
        Params.ParamByName('iWO').AsString := trim(edtWo.Text);
      if cmbMachine.Visible then
        if cmbMachine.ItemIndex<>0 then
          Params.ParamByName('iMachine').AsString :=trim(cmbMachine.Text);
      if trim(cmbSide.Text)<>'All' then
        Params.ParamByName('iSide').AsInteger := cmbSide.ItemIndex-1;
      memo1.Text:=commandtext;
      open;
      if recordcount>0 then
     begin
      iRow:=1;
      while not eof do
      begin
          if  (sgOnline.Cells[2,iRow-1]<>fieldbyname('part_no').AsString) OR (sStation<>fieldbyname('station_no').AsString)
              OR (fieldbyname('in_time').AsString<>'') OR (SGONLINE.Cells[4,iRow-1]<>fieldbyname('machine_code').AsString)  then
          begin
           sgOnline.RowHeights[iRow]:=16;
           sgOnline.Cells[1,iRow]:=fieldbyname('work_order').AsString;
           sgOnline.Cells[2,iRow]:=fieldbyname('part_no').AsString;
           sgOnline.Cells[3,iRow]:=fieldbyname('pdline_name').AsString;
           sgOnline.Cells[4,iRow]:=fieldbyname('MACHINE_CODE').AsString;
           sgOnline.Cells[5,iRow]:=fieldbyname('side').AsString;
           sgOnline.Cells[6,iRow]:=fieldbyname('STATION_NO').AsString;

           sgOnline.Cells[7,iRow]:=fieldbyname('reel_no').AsString;
           sgOnline.Cells[8,iRow]:=fieldbyname('emp_name').AsString;
           sgOnline.Cells[9,iRow]:=fieldbyname('in_time').AsString;

           sgOnline.Cells[10,iRow]:=fieldbyname('datecode').AsString;
           sgOnline.Cells[11,iRow]:=fieldbyname('qty').AsString;

           sgOnline.Cells[12,iRow]:=fieldbyname('MFGER_NAME').AsString;
           sgOnline.Cells[13,iRow]:=fieldbyname('MFGER_PART_NO').AsString;
           INC(IROW);
           sgOnline.RowCount:=iRow+1;
           sStation:=fieldbyname('station_no').AsString;
          end;
         next;
      end;
     end;
    END
    ELSE BEGIN
     close;
     params.Clear;
     if cmbpdline.ItemIndex<>0 then
        params.CreateParam(ftString	,'iPDname', ptInput);
     if trim(edtWO.Text)<>'' then
        params.CreateParam(ftString	,'iWO', ptInput);
     if cmbMachine.Visible then
        if cmbMachine.ItemIndex<>0 then
          params.CreateParam(ftString	,'iMachine', ptInput);

     if trim(cmbSide.Text)<>'All' then
        params.CreateParam(ftString	,'iSide', ptInput);

     commandtext:=' select a1.work_order,b1.station_no,decode(to_char(a1.side),''0'',''Top'',''1'',''Bottom'') side,d1.part_no,f1.pdline_name,c1.datecode,TO_CHAR(c1.qty) QTY,g1.emp_name,To_CHAR(c1.in_time,''YYYY/MM/DD HH24:MI:SS'') IN_TIME,TO_CHAR(c1.item_part_id) flag '
                +'  ,c1.reel_no,c1.MFGER_NAME,c1.MFGER_PART_NO,H1.MACHINE_CODE '
                +' from smt.g_wo_msl a1,smt.g_wo_msl_detail b1,smt.g_smt_status  c1,sajet.sys_part d1,sajet.sys_pdline  f1,sajet.sys_emp g1,sajet.sys_machine h1  '
                +' where a1.wo_sequence=b1.wo_sequence '
                +'      and b1.item_part_id=d1.part_id '
                +'      and c1.pdline_id = f1.pdline_id(+) '
                +'      and c1.emp_id = g1.emp_id(+) '
                +'      and b1.wo_sequence=c1.wo_sequence '
                +'      and b1.item_part_id=c1.item_part_id  '
                +'      and b1.station_no=c1.station_no '
                +'      AND A1.MACHINE_ID=H1.MACHINE_ID(+) ';
      if trim(edtWO.Text)<>'' then
      begin
        commandtext:=commandtext+' and a1.work_order=:iWO ';
        if cmbpdline.ItemIndex<>0 then
          commandtext:=commandtext+ ' and c1.pdline_id=:iPDname ';
      end
      else if cmbpdline.ItemIndex<>0 then
        commandtext:=commandtext+ ' and c1.pdline_id=:iPDname ';

      if trim(cmbSide.Text)<>'All' then
        commandtext:=commandtext+' and a1.side=:iSide ';

      if cmbMachine.Visible then
        if cmbMachine.ItemIndex<>0 then
          commandtext:=commandtext+' and h1.machine_code=:iMachine ';
      commandtext :=commandtext+' order by PART_NO,machine_code,station_no ';
      if cmbpdline.ItemIndex<>0 then
        Params.ParamByName('iPDname').AsString := pdline_id;
      if trim(edtWO.Text)<>'' then
        Params.ParamByName('iWO').AsString := trim(edtWo.Text);
      if cmbMachine.Visible then
        if cmbMachine.ItemIndex<>0 then
          Params.ParamByName('iMachine').AsString :=trim(cmbMachine.Text);
      if trim(cmbSide.Text)<>'All' then
        Params.ParamByName('iSide').AsInteger := cmbSide.ItemIndex-1;
      MEMO1.Text:=COMMANDTEXT;
      open;

      if recordcount>0 then
      begin
       iRow:=1;
       while not eof do
       begin
           sgOnline.RowHeights[iRow]:=16;
           sgOnline.Cells[1,iRow]:=fieldbyname('work_order').AsString;
           sgOnline.Cells[2,iRow]:=fieldbyname('part_no').AsString;
           sgOnline.Cells[3,iRow]:=fieldbyname('pdline_name').AsString;
           sgOnline.Cells[4,iRow]:=fieldbyname('MACHINE_CODE').AsString;
           sgOnline.Cells[5,iRow]:=fieldbyname('side').AsString;
           sgOnline.Cells[6,iRow]:=fieldbyname('STATION_NO').AsString;

           sgOnline.Cells[7,iRow]:=fieldbyname('reel_no').AsString;
           sgOnline.Cells[8,iRow]:=fieldbyname('emp_name').AsString;
           sgOnline.Cells[9,iRow]:=fieldbyname('in_time').AsString;


           sgOnline.Cells[10,iRow]:=fieldbyname('datecode').AsString;
           sgOnline.Cells[11,iRow]:=fieldbyname('qty').AsString;

           sgOnline.Cells[12,iRow]:=fieldbyname('MFGER_NAME').AsString;
           sgOnline.Cells[13,iRow]:=fieldbyname('MFGER_PART_NO').AsString;
           INC(IROW);
           sgOnline.RowCount:=iRow+1;
           next;
        end;//end while
      end;
    END;

    statusbar3.panels[0].Text:='Records: '+inttostr(sgOnline.RowCount-2)+' ';
    statusbar3.Panels[1].Text:='  The search cost you '+IntToStr(MilliSecondsBetween(Time,T1))+' MilliSeconds.'

  end;
end;

procedure TfMaterial.SaveToExcel(Grid:TDBGrid;tFile:string);
var
  sFileName,My_FileName : String;
  MsExcel, MsExcelWorkBook : Variant;
begin
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'xls';
  SaveDialog1.Filter := 'All Files(*.xls)|*.xls';
  My_FileName:= DownLoadSampleFile(tFile);
  if not FileExists(My_FileName) then
  begin
    showmessage('Error!-The Excel File '+My_FileName+' can''t be found.');
    exit;
  end;
  if SaveDialog1.Execute then
  begin
    try
         sFileName := SaveDialog1.FileName;
         MsExcel := CreateOleObject('Excel.Application');
         MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);
         MsExcel.Worksheets['Sheet1'].select;
         SaveExcel(MsExcel,MsExcelWorkBook,grid);
         MsExcelWorkBook.SaveAs(sFileName);
         showmessage('Save Excel OK!!');
    Except
      ShowMessage('Could not start Microsoft Excel.');
    end;
    MsExcel.Application.Quit;
    MsExcel:=Null;
  end else
    MessageDlg('You did not Save Any Data',mtWarning,[mbok],0);

end;
procedure TfMaterial.SelectByPart(tPart,tDateCode:string);
var T1:tDate;
begin
  T1:= Time;
  if not checkPart(tpart) then
  begin
    MessageDlg('The Part NO Not Exist! ',mtWarning,[mbok],0);
    exit;
  end;
  with qrydata1 do
  begin
    close;
    params.Clear;
    params.CreateParam(ftString	,'iPart', ptInput);
    if tDateCode<>'' then
      params.CreateParam(ftString	,'iDateCode', ptInput);
    commandtext:=' select distinct e1.work_order,b1.Part_no,a1.datecode,nvl(c1.vendor_code,c1.vendor_name) vendor,e1.input_qty,e1.output_qty  '
                +' from smt.g_smt_travel a1, sajet.sys_part b1,sajet.sys_vendor c1,smt.g_wo_msl d1,sajet.g_wo_base e1 '
                +' where a1.item_part_id=b1.part_id '
                +'       and a1.station_no is not null '
                +'       and a1.vendor_id=c1.vendor_id(+) '
                +'       and a1.wo_sequence=d1.wo_sequence '
                +'       and d1.work_order=e1.work_order '
                +'       and b1.part_no=:iPart ' ;
    if tDateCode<>'' then
      commandtext:=commandtext+' and a1.dateCode =:iDateCode ';
    commandtext:=commandtext
                +' union '
                +' select distinct e2.work_order,b2.Part_no,a2.datecode,nvl(c2.vendor_code,c2.vendor_name) vendor,e2.input_qty,e2.output_qty  '
                +' from smt.g_smt_status a2, sajet.sys_part b2,sajet.sys_vendor c2,smt.g_wo_msl d2,sajet.g_wo_base e2 '
                +' where a2.item_part_id=b2.part_id '
                +'       and a2.station_no is not null '
                +'       and a2.vendor_id=c2.vendor_id(+) '
                +'       and a2.wo_sequence=d2.wo_sequence '
                +'       and d2.work_order=e2.work_order '
                +'       and b2.part_no=:iPart ';
    if tDateCode<>'' then
      commandtext:=commandtext+' and a2.dateCode =:iDateCode ';
    Params.ParamByName('iPart').AsString :=tPart;
    if tDateCode<>'' then
      Params.ParamByName('iDateCode').AsString := trim(editDateCode.Text);
    memo1.Text:=commandtext;
    open;
    statusbar2.panels[0].Text:='Records: '+inttostr(qrydata1.RecordCount)+' ';
    statusbar2.Panels[1].Text:='  The search cost you '+IntToStr(MilliSecondsBetween(Time,T1))+' MilliSeconds.'

  end;

end;

procedure TfMaterial.GetMaterialTime(tPart,tWOSeq:string;tProcessTime:tDateTime;var tTimeStrList:tStringlist);
var cnt,i:integer;
begin
   cnt:=0;
   with qrytemp do
   begin
     close;
     params.clear;
     params.CreateParam(ftString	,'iPart', ptInput);
     params.CreateParam(ftString	,'iWOSeq', ptInput);
     commandtext:=' select count(*) cnt from smt.g_wo_msl_detail a,sajet.sys_part b '
                 +' where a.item_part_id = b.part_id   '
                 +'       and b.part_no=:iPart '
                 +'       and a.wo_sequence =:iWOsq ';
     Params.ParamByName('iPart').AsString :=tPart;
     Params.ParamByName('iWOsq').AsString :=tWOseq;
     open;
     if recordcount>0 then
     begin
        cnt:=fieldbyname('cnt').AsInteger;
     end;

     if cnt>0 then begin
       close;
       params.Clear;
       params.CreateParam(ftString	,'iPart', ptInput);
       params.CreateParam(ftString	,'iWOSeq', ptInput);
       params.CreateParam(ftdateTime,'iTime',ptinput);
       commandtext:=' select a1.in_time '
                 +' from smt.g_smt_travel a1,sajet.sys_part b1 '
                 +' where a1.station_no is not null '
                 +'       and a1.item_part_id =b.part_id '
                 +'       and b1.Part_no=:iPart '
                 +'       and a1.wo_sequence =:iWOseq '
                 +'       and  a1.in_time<:iTime '
                 +' union '
                 +' select a2.in_time '
                 +' from smt.g_smt_status a2,sajet.sys_part b2 '
                 +' where a2.station_no is not null '
                 +'       and a2.item_part_id =b2.part_id '
                 +'       and b2.Part_no=:iPart '
                 +'       and a2.wo_sequence =:iWOseq '
                 +'       and  a2.in_time<:iTime '
                 +' order by in_time desc ';
       Params.ParamByName('iPart').AsString :=tPart;
       Params.ParamByName('iWOsq').AsString :=tWOseq;
       Params.ParamByName('iTime').AsDateTime:=tProcessTime;
       open;
       if recordcount>cnt then
         for i:=1 to  cnt do
          tTimeStrList.Add(fieldbyname('in_time').AsString);
     end;
   end;
end;

function TfMaterial.CheckPart(tpart:string):boolean;
begin
  result:=false;
  with qrytemp do
  begin
    close;
    params.Clear;
    params.CreateParam(ftString	,'iPart', ptInput);
    commandtext:=' select * from sajet.sys_part where part_no=:iPart ';
    Params.ParamByName('iPart').AsString :=tPart;
    open;
    if recordcount>0 then
      result:=true;
  end;
end;

function TfMaterial.GetProcessTime(tProcess,tSN:string;tDelay:integer;var tProcessTime:tDateTime) :boolean;
begin
  result:=true;
  with qrytemp do
  begin
    close;
    params.Clear;
    params.CreateParam(ftString	,'iSN', ptInput);
    params.CreateParam(ftString	,'iProcess', ptInput);
    commandtext:=' select out_process_time '
                +' from sajet.g_sn_travel a,sajet.sys_process b '
                +' where a.serial_number=:iSN '
                +'      and a.process_id = b.process_id '
                +'      and b.process_name=:iProcess ' ;
    Params.ParamByName('iSN').AsString :=tSN;
    Params.ParamByName('iProcess').AsString :=tProcess;
    open;
    if recordcount>0 then
       tProcessTime:=fieldbyname('out_process_time').AsDateTime-tDelay/24/60
    else
       result:=false;
  end;
end;

function TfMaterial.CheckParam(var tParam:string;var SNFlag:string;var tWO:string):boolean;
begin
    Result:=true;
    SNFlag:='N';
    with qrytemp do
    begin
      close;
      params.Clear;
      params.CreateParam(ftString	,'iParam', ptInput);
      commandtext:=' select * from sajet.g_wo_base '
                  +' where work_order=:iParam ';
      Params.ParamByName('iParam').AsString :=tParam;
      open;
      if recordcount=0 then
      begin
        close;
        params.Clear;
        params.CreateParam(ftString	,'iParam', ptInput);
        commandtext:=' select * from sajet.g_sn_status '
                    +' where serial_number=:iParam '
                    +'        or customer_sn=:iParam ';
        Params.ParamByName('iParam').AsString :=tParam;
        open;
        if recordcount=0 then
        begin
          MessageBox(Self.Handle, 'Not Find the Data!!', 'ERROR', MB_OK+MB_iconInformation );
          result:=false;
        end
        else begin
          SNFlag:='Y';
          tWO:=fieldbyname('Work_order').AsString;
          tParam:=fieldbyname('serial_number').AsString;
        end;
      end
      else tWO:= tParam;
    end;
end;

//DBGrid實現鼠標滾輪功能
function TDBGrid.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
MousePos: TPoint): Boolean;
begin
  if WheelDelta > 0 then
    datasource.DataSet.Prior;
  if wheelDelta < 0 then
    DataSource.DataSet.Next;
  Result := True;
end;

procedure TfMaterial.sbtnSaveClick(Sender: TObject);
begin
  if PageControl1.ActivePage= TabSheet1 then
  begin
      if not QryData.Active Then Exit;
      SaveToExcel(dbgrid1,'WOMaterial.xlt');
  end
  else if  PageControl1.ActivePage=TabSheet2 then
  begin
     if not qrydata1.Active then exit;
      SaveToExcel(dbgrid2,'PartMaterial.xlt');
  end;
end;


Function TfMaterial.DownloadSampleFile(tFile:string) : String;
begin
   Result:=ExtractFilePath(Application.ExeName) + ExtractFileName(tFile);
end;
procedure TfMaterial.SaveExcel(MsExcel,MsExcelWorkBook:Variant;Grid:TDBGrid);
Var j,i : Integer;
begin

 for i := 0 to grid.Columns.Count - 1 do
      MsExcel.Worksheets['Sheet1'].Range[Chr(i+65)+'4'].Value:= grid.Columns[i].Title.Caption;

  grid.DataSource.DataSet.First;
  for i:= 0 to grid.DataSource.DataSet.RecordCount - 1 do
  begin
      for j:= 0 to grid.Columns.Count - 1  do
          MsExcel.Worksheets['Sheet1'].Range[Chr(j+65)+IntToStr(i+5)].Value := grid.DataSource.DataSet.Fields.Fields[J].AsString ;
      grid.DataSource.DataSet.Next;
  end;
  //MsExcel.Worksheets['Sheet1'].Range[Chr(68)+IntToStr(i+2+1)].Value:='Unused Count:'+GPQty.Caption;

end;


procedure TfMaterial.sbtnPrintClick(Sender: TObject);
var
  My_FileName : String;
  MsExcel, MsExcelWorkBook : Variant;
begin
 { if not QryData.Active Then Exit;

  My_FileName:= DownLoadSampleFile;

  if not FileExists(My_FileName) then
  begin
     showmessage('Error!-The Excel File '+My_FileName+' can''t be found.');
     exit;
  end;

  try

    MsExcel := CreateOleObject('Excel.Application');
    MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);
    SaveExcel(MsExcel,MsExcelWorkBook);
    WindowState:=wsMinimized;
    MsExcel.Visible:=TRUE;
    MsExcel.Worksheets['Sheet1'].select;
    MsExcel.WorkSheets['Sheet1'].PrintPreview;
    WindowState:=wsMaximized;

  Except
    ShowMessage('Could not start Microsoft Excel.');
  end;
  MsExcel.Application.Quit;
  MsExcel:=Null;

  Try
     If FileExists(My_FileName) Then Deletefile(My_FileName);
  except end;  }
end;

procedure TfMaterial.sbtnQueryClick(Sender: TObject);
var tWO,tSN:string;
    T1:tdate;
    tTime:tDateTime;
    tempKey:char;
begin
  T1:= Time;
  SNType:='N';
  if PageControl1.ActivePage=TabSHEET1 then
  begin
    if trim(editWO.Text)='' then exit;
    statusbar1.panels[0].Text:='';
    statusbar1.panels[1].Text:='';
    tSN:= trim(editWO.Text);
    if not CheckParam(tSN,SNType,tWO) then exit;
    if cmbPart.Items.Count=0 then begin
       with qrytemp do
       begin
         close;
         params.Clear;
         params.CreateParam(ftString	,'iWO', ptInput);
         commandtext:=' select distinct c.Part_no from smt.g_wo_msl a,smt.g_wo_msl_detail b,sajet.sys_part c '
                 +' where a.wo_sequence=b.wo_sequence '
                 +'       and a.work_order =:iWO '
                 +'       and b.item_part_id=c.part_id '
                 +' order by part_no ';
         Params.ParamByName('iWO').AsString :=tWO;
         open;
         cmbPart.Items.Add('ALL');
         while not eof do
         begin
           cmbpart.Items.Add(fieldbyname('Part_no').AsString);
           next;
         end;
       end;
    end;
    if SNType='Y' then
    begin
      labProcess.Visible:=true;
      cmbProcess.Visible:=true;
      sPinedit1.visible:=true;
      labProTime.Visible:=true;
      labTime.Visible:=true;
      labUnion.Visible:=true;
     if cmbProcess.Items.Count =0 then
     begin

      with qrytemp do
      begin
        close;
        params.Clear;
        params.CreateParam(ftString	,'iSN', ptInput);
        commandtext:=' select b.process_name '
                +' from sajet.g_sn_travel a,sajet.sys_process b '
                +' where a.process_id =b.process_id '
                +'        and a.serial_number=:iSN '
                +' order by a.in_process_time desc ';
        Params.ParamByName('iSN').AsString :=tSN;
        open;
        cmbProcess.Items.Add('N/A');
        while not eof do
        begin
          cmbProcess.Items.Add(fieldbyname('process_name').AsString);
          next;
        end;
      end;
     end;
     if (trim(cmbProcess.Text)<>'N/A')and ((cmbProcess.Text)<>'') then
        if not GetProcessTime(trim(cmbProcess.Text),tSN,sPinedit1.Value,tTime) then
        begin
          MessageDlg('NO Pass Process Time ! ',mtWarning,[mbok],0);
          exit;
        end;
    end;

    with qrydata do
    begin
      close;
      params.Clear;
      params.CreateParam(ftString	,'iWO', ptInput);
      if ((SNType ='Y') and (trim(cmbProcess.Text)<>'N/A')and (trim(cmbProcess.Text)<>''))  then
         params.CreateParam(ftDateTime	,'iTime', ptInput);
      if (cmbPdlineWO.ItemIndex<>0)and (cmbPdLineIDWO.ItemIndex<>-1) then
         params.CreateParam(ftDateTime	,'iPdline', ptInput);
      commandtext:=' select  b1.work_order,d1.part_no,g1.pdline_name,a1.datecode,nvl(e1.vendor_code,e1.vendor_name) vendor,nvl(f1.emp_name,f1.emp_no) emp,   '
                 // +' a1.in_time ,a1.out_time,  '
                  +'  to_char(a1.in_time,''YYYY/MM/DD HH24:MI:SS'') in_time , to_char(a1.out_time,''YYYY/MM/DD HH24:MI:SS'') out_time, '
                  +' round((a1.out_time-a1.in_time)*24*60,2) subtime '
                  +'               ,a1.reel_no,a1.MFGER_NAME,a1.MFGER_PART_NO  '
                  +' from smt.g_smt_travel a1,smt.g_wo_msl b1,smt.g_wo_msl_detail c1,sajet.sys_part d1,sajet.sys_vendor e1 ,sajet.sys_emp f1,sajet.sys_pdline g1 '
                  +' where b1.WO_SEQUENCE=c1.wo_sequence   '
                  +'       and a1.wo_sequence=b1.wo_sequence  '
                  +'       and a1.emp_id=f1.emp_id '
	                +'       and a1.station_no is not null   '
                  +'       and a1.item_part_id=d1.part_id '
                  +'       and a1.vendor_id=e1.vendor_id(+) '
                  +'       and b1.work_order = :iWO  '
                  +'       and a1.pdline_id=g1.pdline_id ' ;
      if (trim(cmbPart.Text)<>'ALL') and (trim(cmbPart.Text)<>'')  then
         commandtext:=commandtext+' and d1.part_no = '+''''+trim(cmbPart.Text)+'''';
      if ((SNType ='Y') and (trim(cmbProcess.Text)<>'N/A')) and (trim(cmbProcess.Text)<>'')  then
          commandtext:=commandtext+' and a1.in_time < :iTime ' ;
      if (cmbPdlineWO.ItemIndex<>0)and (cmbPdLineIDWO.ItemIndex<>-1) then
         commandtext:=commandtext+' and a1.pdline_id=:iPdline ';
      commandtext:=commandtext
                 +' union '
                 +'  select  b2.work_order,d2.part_no,g2.pdline_name,a2.datecode,nvl(e2.vendor_code,e2.vendor_name) vendor,nvl(f2.emp_name,f2.emp_no) emp,  '
                // +' a2.in_time ,a2.out_time, '
                 +'  to_char(a2.in_time,''YYYY/MM/DD HH24:MI:SS'') in_time , to_char(a2.out_time,''YYYY/MM/DD HH24:MI:SS'') out_time, '
                 +' round((sysdate-a2.in_time)*24*60,2)  subtime  '
                 +'               ,a2.reel_no,a2.MFGER_NAME,a2.MFGER_PART_NO  '
                 +' from smt.g_smt_status a2,smt.g_wo_msl b2,smt.g_wo_msl_detail c2,sajet.sys_part d2,sajet.sys_vendor e2 ,sajet.sys_emp f2 ,sajet.sys_pdline g2 '
                 +' where b2.WO_SEQUENCE=c2.wo_sequence   '
                 +'       and a2.wo_sequence=b2.wo_sequence  '
                 +'       and a2.emp_id=f2.emp_id '
                 +'       and a2.station_no is not null   '
                 +'       and a2.item_part_id=d2.part_id '
                 +'       and a2.vendor_id=e2.vendor_id(+) '
                 +'       and b2.work_order = :iWO  '
                 +'       and a2.pdline_id=g2.pdline_id ';
      if (SNType ='Y') and (trim(cmbProcess.Text)<>'N/A') and (trim(cmbprocess.Text)<>'')  then
          commandtext:=commandtext+' and a2.in_time < :iTime ' ;
      if (trim(cmbPart.Text)<>'ALL') and (trim(cmbPart.Text)<>'') then
         commandtext:=commandtext+' and d2.part_no = '+''''+trim(cmbPart.Text)+'''';
      if (cmbPdlineWO.ItemIndex<>0)and (cmbPdLineIDWO.ItemIndex<>-1) then
         commandtext:=commandtext+' and a2.pdline_id=:iPdline ';
      commandtext:=commandtext+ ' order by in_time desc ';

      Params.ParamByName('iWO').AsString :=tWO;
      if (SNType ='Y') and (trim(cmbProcess.Text)<>'N/A')and (trim(cmbProcess.Text)<>'')  then
         Params.ParamByName('iTime').AsDateTime :=tTime;
      if (cmbPdlineWO.ItemIndex<>0)and (cmbPdLineIDWO.ItemIndex<>-1) then
         params.ParamByName('iPdline').AsString:=cmbPdlineIDWO.Text;
      memo1.text:=commandtext;
      open;
    end;
    statusbar1.panels[0].Text:='Records: '+inttostr(qrydata.RecordCount)+' ';
    statusbar1.Panels[1].Text:='  The search cost you '+IntToStr(MilliSecondsBetween(Time,T1))+' MilliSeconds.'
  end
  else if  PageControl1.ActivePage=TabSHEET2 then
  begin
      if trim(editPart.Text)='' then exit;
      SelectByPart(trim(editPart.Text),trim(editDateCode.Text));
  end
  else if PageControl1.ActivePage=TabSHEET3 then
  begin
     if (trim(cmbPdline.Text)='') and  (trim(edtWo.Text)='') then exit;
     SelectOnline;
  end
  else if PageControl1.ActivePage=TabSHEET5 then
  begin
     if trim(editFeeder.Text)='' then exit;
     selectFeeder;
  end
  else if pageControl1.ActivePage= TabSHEET4 then
  begin
    selectDIP;
  end
  else if PageControl1.ActivePage=TabSHEET6 then
  begin
    selectBetch;
  end;
end;

procedure TfMaterial.DBGrid1DblClick(Sender: TObject);
begin
   if not qrydata.Active then exit;
   if qrydata.RecordCount=0 then exit;
   editPart.Text:=qrydata.fieldbyname('part_no').AsString;
   editDateCode.Text:=qrydata.fieldbyname('dateCode').AsString;
   PageControl1.ActivePage:=TabSheet2;
   SelectByPart(trim(editpart.Text),trim(editDateCode.Text));
end;

procedure TfMaterial.DBGrid1TitleClick(Column: TColumn);
var bAesc: Boolean;
begin
  bAesc := True;
  if DBGrid1.DataSource = nil then Exit;
  if DBGrid1.DataSource.DataSet = nil then Exit;
  if not (DBGrid1.DataSource.DataSet is TClientDataSet) then Exit;
  if (DBGrid1.DataSource.DataSet as TClientDataSet).Active then
  begin
    if (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName <> '' then
    begin
      bAesc := True;
      if (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName = Column.FieldName then
        bAesc := False;
       (DBGrid1.DataSource.DataSet as TClientDataSet).deleteIndex((DBGrid1.DataSource.DataSet as TClientDataSet).Indexname);
    end;
    if bAesc then begin
      (DBGrid1.DataSource.DataSet as TClientDataSet).AddIndex(Column.FieldName, Column.FieldName, [], '', '', 0);
      (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName := Column.FieldName;
    end else begin
      (DBGrid1.DataSource.DataSet as TClientDataSet).AddIndex(Column.FieldName + 'D', Column.FieldName, [ixDescending], '', '', 0);
      (DBGrid1.DataSource.DataSet as TClientDataSet).IndexName := Column.FieldName + 'D';
    end;
    (DBGrid1.DataSource.DataSet as TClientDataSet).IndexDefs.Update;
  end;
end;

{procedure TfMaterial.sbtnpartClick(Sender: TObject);
var temp,tWO,tSN:string;
    i:integer;
    FormCondition: TfCondition;
begin
  if trim(editWO.Text)='' then exit;

  tSN:=trim(editwo.Text);
  if not CheckParam(tSN,temp,tWO) then exit;
  FormCondition:=TfCondition.Create(Self);

  with qrytemp do
  begin
     close;
     params.Clear;
     params.CreateParam(ftString	,'iWO', ptInput);
     commandtext:=' select distinct c.Part_no from smt.g_wo_msl a,smt.g_wo_msl_detail b,sajet.sys_part c '
                 +' where a.wo_sequence=b.wo_sequence '
                 +'       and a.work_order =:iWO '
                 +'       and b.item_part_id=c.part_id '
                 +' order by part_no ';
     Params.ParamByName('iWO').AsString :=tWO;
     open;
     if recordcount>0 then
     begin
       while not eof do
       begin
          FormCondition.listbAvail.Items.Add(fieldbyname('part_no').AsString);
          next;
       end;
     end;
  end;
  if FormCondition.ShowModal=mrOK then
  begin
     sPart1:='';
     sPart2:='';
     if FormCondition.listbSelect.Items.Count>0 then
       for i:=0 to  FormCondition.listbSelect.Items.Count-1 do
       begin
         sPart1:= sPart1+' or ' +' d1.part_no='+''''+ FormCondition.listbSelect.Items[i]+'''';
         sPart2:= sPart2+' or ' +' d2.part_no='+''''+ FormCondition.listbSelect.Items[i]+'''';
       end;
  end;
end;
}
procedure TfMaterial.FormShow(Sender: TObject);
begin
  AddPDline(cmbpdline);
  AddPDline(cmbpdlineDIP);
  AddPdlineBetch(cmbPdlineBetch);
  dateRow:= 1;
  PageControl1.ActivePageIndex:=2;
  sgOnline.Cells[1,0]:='WORK ORDER';
  sgOnline.Cells[2,0]:='PART NO';
  sgOnline.Cells[3,0]:='PDLINE';
  sgOnline.Cells[4,0]:='MACHINE';
  sgOnline.Cells[5,0]:='SIDE';
  sgOnline.Cells[6,0]:='STATION';

  sgOnline.Cells[7,0]:='REEL NO';
  sgOnline.Cells[8,0]:='EMP NAME';
  sgOnline.Cells[9,0]:='IN TIME';

  sgOnline.Cells[10,0]:='DATECODE/Lot Code';
  sgOnline.Cells[11,0]:='QTY';

  sgOnline.Cells[12,0]:='MFGER NAME';
  sgOnline.Cells[13,0]:='MFGER PART NO';

  {sgFeeder.Cells[1,0]:='WO_SEQUENCE';
  sgFeeder.Cells[2,0]:='PDLINE';
  sgFeeder.Cells[3,0]:='PART NO';
  sgFeeder.Cells[4,0]:='IN TIME';
  sgFeeder.Cells[5,0]:='FEEDER';
  sgFeeder.Cells[6,0]:='REEL';
  sgFeeder.Cells[7,0]:='DATECODE/Lot Code';
  sgFeeder.Cells[8,0]:='EVendor NAME';
  sgFeeder.Cells[9,0]:='EMP NAME';
  sgFeeder.Cells[10,0]:='MFGER NAME';
  sgFeeder.Cells[11,0]:='MFGER PART NO';     }

  sgDIP.Cells[1,0]:='Work Order';
  sgDIP.Cells[2,0]:='PDLINE';
  sgDIP.Cells[3,0]:='Stage';
  sgDIP.Cells[4,0]:='Process';
  sgDIP.Cells[5,0]:='Part NO';
  sgDIP.Cells[6,0]:='DATECODE/Lot Code';
  sgDIP.Cells[7,0]:='Vendor Name';
  sgDIP.Cells[8,0]:='QTY';
  sgDIP.Cells[9,0]:='In Time';
  sgDIP.Cells[10,0]:='Emp Name';
  sgDIP.Cells[11,0]:='MFGER Name';
  sgDIP.Cells[12,0]:='MFGER Part NO';

  sgBetch.Cells[1,0]:='Work Order';
  sgBetch.Cells[2,0]:='Part NO';
  sgBetch.Cells[3,0]:='PDLINE';
  sgBetch.Cells[4,0]:='DateCode/Lot Code';
  sgBetch.cells[5,0]:='Vendor Name';
  sgBetch.Cells[6,0]:='QTY';
  sgBetch.cells[7,0]:='In Time';
  sgBetch.cells[8,0]:='Project Time';
  sgBetch.cells[9,0]:='Emp Name';
  sgBetch.cells[10,0]:='MFGER Name';
  sgBetch.cells[11,0]:='MFGER Part NO';
end;

procedure TfMaterial.editwoKeyPress(Sender: TObject; var Key: Char);
var  SNFlag,tWO,tSN:string;
begin
  if key<>#13 then exit;
  tSN:=trim(editwo.text);
  cmbPart.Items.Clear;
  cmbProcess.Items.Clear;
  cmbPart.Items.Add('ALL');
  if not CheckParam(tSN,SNFlag,tWO) then exit;

  AddPDlineWO(tWo,cmbPdlineWo,cmbPdlineIDWO);
  // get MSL Part NO
  with qrytemp do
  begin
     close;
     params.Clear;
     params.CreateParam(ftString	,'iWO', ptInput);
     commandtext:=' select distinct c.Part_no from smt.g_wo_msl a,smt.g_wo_msl_detail b,sajet.sys_part c '
                 +' where a.wo_sequence=b.wo_sequence '
                 +'       and a.work_order =:iWO '
                 +'       and b.item_part_id=c.part_id '
                 +' order by part_no ';
     Params.ParamByName('iWO').AsString :=tWO;
     open;
     while not eof do
     begin
       cmbpart.Items.Add(fieldbyname('Part_no').AsString);
       next;
     end;
  end;

  if SNFlag='Y'  then begin
    labProcess.Visible:=true;
    cmbProcess.Visible:=true;
    sPinedit1.visible:=true;
    labProTime.Visible:=true;
    labTime.Visible:=true;
    labUnion.Visible:=true; 

  //  get  SN travelling Process Name
    with qrytemp do
    begin
      close;
      params.Clear;
      params.CreateParam(ftString	,'iSN', ptInput);
      commandtext:=' select b.process_name '
                +' from sajet.g_sn_travel a,sajet.sys_process b '
                +' where a.process_id =b.process_id '
                +'        and a.serial_number=:iSN '
                +' order by a.in_process_time desc ';
      Params.ParamByName('iSN').AsString :=tSN;
      open;
      cmbProcess.Items.Add('N/A');
      while not eof do
      begin
        cmbProcess.Items.Add(fieldbyname('process_name').AsString);
        next;
      end;
    end;
  end;

end;

procedure TfMaterial.editwoChange(Sender: TObject);
begin
  cmbPart.Items.Clear;
  labProcess.Visible:=false;
  cmbProcess.Visible:=false;
  spinedit1.Visible:=false;
  labProTime.Visible:=false;
  labTime.Visible:=false;
  labUnion.Visible:=false;
  cmbProcess.Clear;
  sPinedit1.Value:=0;
  labTime.Caption:='';
end;

procedure TfMaterial.cmbProcessChange(Sender: TObject);
var tProcessTime: tDateTime;
begin
  if cmbProcess.Visible then
  begin
    labtime.Caption:='';
    if (trim(cmbProcess.Text)<>'N/A')and (trim(cmbProcess.Text)<>'') then
      if GetProcessTime(trim(cmbprocess.Text),trim(editwo.Text),spinedit1.Value,tProcessTime) then
        labtime.caption:=datetimetostr(tProcessTime)
      else
        labTime.Caption:='';
  end;
end;

procedure TfMaterial.sbtnResetClick(Sender: TObject);
var two,tPdline:string;
begin
   //if (daterow<0) or (daterow>sgOnline.RowCount) then  exit;
   if trim(editWOBetch.Text)='' then exit;
   if cmbPdlineBetch.ItemIndex=0 then exit;
   with TfCheckEmp.Create(Self) do
   begin
      //tWO:=tsGrid1.Cell[1,dateRow];
      //tWO:=sgBetch.Cells[1,dateRow];
      tWO:=editWOBetch.Text;
      tPdline:=cmbPdlineBetch.text;
      if Showmodal = mrOK then
      begin
       If messagedlg('Reset Work Order: '+tWO+' ? '+#10+#13+#10+' Pdline: '+tPdline,mtConfirmation,mbOKCancel, 0) = mrOK  Then
       begin
        MoveData(two,tPdline);
        sbtnQueryClick(self);
       end;
      end else
        exit;
      Free;
   end;
end;

{procedure TfMaterial.tsGrid11ClickCell(Sender: TObject; DataColDown,
  DataRowDown, DataColUp, DataRowUp: Integer; DownPos,
  UpPos: TtsClickPosition);
begin
    if DataRowUp<> DataRowDown then exit
    else DateRow:=DataRowUp;
end;}

procedure TfMaterial.sgOnlineSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
    DateRow:=Arow;
end;

procedure TfMaterial.sgOnlineDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  Var K : Integer;
begin
  if (ACol<=0) then exit;
  K:=sgOnline.RowCount;
  if (ARow=0) and (ACol<k) then exit ;
  if ARow=0 then exit;
  if (sgOnline.Cells[9,Arow]='') and (Arow<>dateRow) then
  begin
    sgOnline.Canvas.Brush.Color:=clWindow;
    sgOnline.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, sgOnline.Cells[ACol, ARow]);
  end
  else if  Arow=dateRow then
  begin
    sgOnline.Canvas.Brush.Color:=$ED9564;
    sgOnline.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, sgOnline.Cells[ACol, ARow]);
  end
  else begin
    sgOnline.Canvas.Brush.Color:=$578B2E;//$FFF8F0;//clgreen; ED9564
    sgOnline.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, sgOnline.Cells[ACol, ARow]);
  end;
end;

procedure TfMaterial.edtWOKeyPress(Sender: TObject; var Key: Char);
begin
   if key<>#13 then exit;

   if not AddMachine(trim(edtWO.Text)) then
     null//MessageDlg('N0 Machine！',mtWarning,[mbok],0)
   else begin
     cmbMachine.Visible:=true;
     cmbMachine.ItemIndex:=0;
     label8.Visible:=true;
   end;
end;

procedure TfMaterial.edtWOChange(Sender: TObject);
begin
  label8.Visible:=false;
  cmbMachine.Visible:=false;
  cmbMachine.Items.Clear;
end;

procedure TfMaterial.PageControl1Change(Sender: TObject);
begin
  if pagecontrol1.ActivePage=TabSheet4 then
     addstage(cmbstageDIP);
end;

procedure TfMaterial.cmbStageDIPChange(Sender: TObject);
begin
   addprocess(cmbStageDIP,cmbProcessDIP);
end;
procedure TfMaterial.sgBetchDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var k:integer;
begin
  if (ACol<=0) then exit;
  K:=sgBetch.RowCount;
  if (ARow=0) and (ACol<k) then exit ;
  if ARow=0 then exit;
  if (sgBetch.Cells[3,Arow]='')and (Arow<>dateRow) then
  begin
    sgBetch.Canvas.Brush.Color:=clWindow;
    sgBetch.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, sgBetch.Cells[ACol, ARow]);
  end
  else if  Arow=dateRow then
  begin
    sgBetch.Canvas.Brush.Color:=$ED9564;
    sgBetch.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, sgBetch.Cells[ACol, ARow]);
  end
  else  if  (sgBetch.Cells[8,ARow]<>'')and (Arow<>dateRow) then
  begin
     if  ((now()-strtodatetime(sgBetch.Cells[8,ARow]))-(spinedit2.Value/(60*24))>0) then
     begin
       sgBetch.Canvas.Brush.Color:=$B469FF;
       sgBetch.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, sgBetch.Cells[ACol, ARow]);
     end
     else begin
       sgBetch.Canvas.Brush.Color:=$FFF8F0;
       sgBetch.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, sgBetch.Cells[ACol, ARow]);
     end;
  end
  else begin
    sgBetch.Canvas.Brush.Color:=$FFF8F0;
    sgBetch.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, sgBetch.Cells[ACol, ARow]);
  end;
end;

procedure TfMaterial.sgBetchSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  DateRow:=Arow;
end;

procedure TfMaterial.cmbpdlineWOChange(Sender: TObject);
begin
  cmbpdlineIDWO.ItemIndex:=cmbpdlineWO.Items.IndexOf(cmbPdlineWO.Text);
end;

function TfMaterial.AddPDlineWO(wo:string;var cmb,cmbID:TComboBox):boolean;
begin
  cmb.Clear;
  cmbID.Clear;
  result:=false;
  with qrytemp do
  begin
    close;
    params.Clear;
    params.CreateParam(ftString	,'iWO', ptInput);
    commandtext:=' select distinct a1.pdline_id,b1.pdline_name from smt.g_smt_status a1,sajet.sys_pdline b1 '
                +' where a1.pdline_id=b1.pdline_id '
                +'       and  SUBSTR(wo_sequence,3,length(wo_sequence))=:iWO ' ;
    Params.ParamByName('iWO').AsString :=wo;
    open;
    if not isEmpty then
    begin
      cmb.Items.Add('ALL');
      cmbID.Items.Add('ALL');
      while not eof do
      begin
        cmb.Items.Add(fieldbyname('pdline_name').AsString);
        cmbID.Items.Add(fieldbyname('pdline_id').AsString);
        next;
      end;
      cmb.ItemIndex:=0;
      cmbID.ItemIndex:=0;
    end;
  end;
end;
end.

