unit uSMTReport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin,comobj,Excel97,
  cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, cxDBData, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGrid;

type
  TfSMTReport = class(TForm)                          //  , uVendorLot
    ImageAll: TImage;
    sbtnClose: TSpeedButton;
    Image2: TImage;
    LabelPacking: TLabel;
    SimpleObjectBroker1: TSimpleObjectBroker;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SocketConnection1: TSocketConnection;
    Bevel1: TBevel;
    QryTemp1: TClientDataSet;
    dsDefect: TDataSource;
    Image1: TImage;
    SpeedButton1: TSpeedButton;
    chkbDate: TCheckBox;
    dtPickStart: TDateTimePicker;
    Label1: TLabel;
    dtPickEnd: TDateTimePicker;
    Label2: TLabel;
    Image3: TImage;
    SpeedButton2: TSpeedButton;
    SaveDialog1: TSaveDialog;
    editLotno: TEdit;
    Label3: TLabel;
    Edit1: TEdit;
    Label4: TLabel;
    Edit2: TEdit;
    Label5: TLabel;
    Edit3: TEdit;
    Label6: TLabel;
    Edit4: TEdit;
    Label7: TLabel;
    Label12: TLabel;
    LabCount: TLabel;
    LabLine: TLabel;
    Label13: TLabel;
    QryData1: TClientDataSet;
    DataSourceDef: TDataSource;
    DBGrid2: TDBGrid;
    Label14: TLabel;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    ITEMNAME: TcxGridDBColumn;
    ITEMBC: TcxGridDBColumn;
    STATION_NO: TcxGridDBColumn;
    INTIME: TcxGridDBColumn;
    EMPNAME: TcxGridDBColumn;
    MFGER_NAME: TcxGridDBColumn;
    LINE: TcxGridDBColumn;
    Label15: TLabel;
    LabPN: TLabel;
    Label16: TLabel;
    LabRev: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    cmb_InProc: TComboBox;
    cmb_OutProc: TComboBox;
    FeederNO: TcxGridDBColumn;
    DateCode: TcxGridDBColumn;
    WO_SEQUENCE: TcxGridDBColumn;
    lblWO: TLabel;
    Label11: TLabel;
    LabMoC: TLabel;
    Label17: TLabel;
    Label10: TLabel;
    CmbPDline: TComboBox;
    Label18: TLabel;
    LabRec: TLabel;
    cxGrid1DBTableView1DBColumn1: TcxGridDBColumn;
    SGrid: TStringGrid;
    Bevel2: TBevel;
    QryCOBData: TClientDataSet;
    DataSourceCOB: TDataSource;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure editLotnoChange(Sender: TObject);
    procedure chkbDateClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    Function  GetFirstProcess(var SN:string):string;
    Function  GetFirstRC(var SN:string):Boolean;
    procedure editLotnoKeyPress(Sender: TObject; var Key: Char);
    procedure CheckBox1Click(Sender: TObject);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure FormDestroy(Sender: TObject);
    procedure cmb_InProcChange(Sender: TObject);
    procedure CmbPDlineChange(Sender: TObject);
    procedure sbtnCloseClick(Sender: TObject);

  private
    Procedure BindingProcess();
    Procedure BindingPDline();
    Procedure BindingProcessBySN(sSN:string);
    procedure BindingPDLineBySN(sSN: string);
  public
    UpdateUserID : String;
    LocationList :TstringList;
    VendorList :TstringList;
    Authoritys,AuthorityRole : String;
    RcCount :integer;
    sWO     :string;
    OrderIdx :string;
    sPdLineId,sStart,sEnd,sModelID,MSLWO  :string;
    Procedure Showdata(sModelID,sPDLineID,sStart,sEnd:string);
    procedure ShowCOBData;

  end;

var
  fSMTReport: TfSMTReport;
  strlstProcess,strlstPdline:tstringlist;

implementation

{$R *.dfm}

Procedure TfSMTReport.Showdata(sModelID,sPDLineID,sStart,sEnd:string);
var sSQL,sLocation,ssql1:string;
  sRTNO:string;
  i,j,k:integer;
  sCount :integer;
begin
  LocationList.Clear;
  VendorList.Clear;

  Screen.Cursor:=crHourGlass;
  sSQL := 'select distinct c.part_no,a.reel_no, a.STATION_NO,a.in_time,a.out_time,b.WO_SEQUENCE,'
           +'     h.Pdline_Name,d.emp_no,a.out_time,d.emp_name,e.DATECODE Date_Code,a.FEEDER_NO,e.MFGER_NAME  '    //    ,g.vendor_name
           +'  from smt.g_smt_travel a,  '
           +'       smt.G_WO_MSL_DETAIL b ,    '
           +'       sajet.sys_Pdline h ,'
           +'       sajet.sys_part c , '
           +'       sajet.sys_emp d , '
           +'       sajet.g_pick_list e,smt.g_wo_msl f '
           +' where a.WO_SEQUENCE=b.WO_SEQUENCE '
           +' AND   b.item_part_id=c.part_id '
           +' AND   a.emp_id=D.emp_id '
           +' AND   a.STATION_NO=b.STATION_NO   '
           +' AND   a.reel_no=e.MATERIAL_NO(+) and b.item_part_id=e.PART_ID' //
           +' and   b.WO_SEQUENCE=f.WO_SEQUENCE '
           +' AND   f.part_id='''+sModelID+''' '
           +' AND   h.PDLINE_ID='''+sPdlineID+''' '
           +' AND   f.WORK_ORDER='''+MSLWO+''' '

           +' AND   a.Pdline_ID=h.Pdline_ID ';

 { ssql1 := 'select distinct c.part_no,a.reel_no, a.STATION_NO,a.in_time,a.out_time,b.WO_SEQUENCE,'
           +'     h.Pdline_Name,d.emp_no,a.out_time,d.emp_name,e.DATECODE Date_Code,a.FEEDER_NO,e.MFGER_NAME  '    //    ,g.vendor_name
           +'  from smt.g_smt_travel a,  '
           +'       smt.G_WO_MSL_DETAIL b ,  smt.g_wo_msl_sub  bb, '
           +'       sajet.sys_Pdline h ,'
           +'       sajet.sys_part c , '
           +'       sajet.sys_emp d , '
           +'       sajet.g_pick_list e,smt.g_wo_msl f '
           +' where a.WO_SEQUENCE=b.WO_SEQUENCE '
           +'  and  a.WO_SEQUENCE=bb.WO_SEQUENCE  and b.item_part_id=bb.item_part_id '
           +' AND   bb.SUB_PART_ID=c.part_id '
           +' AND   a.emp_id=D.emp_id '
           +' AND   a.STATION_NO=b.STATION_NO   '
           +' AND   a.reel_no=e.MATERIAL_NO(+) and bb.item_part_id=e.PART_ID' //
           +' and  b.WO_SEQUENCE=f.WO_SEQUENCE '
           +' AND   f.part_id='''+sModelID+''' '
           +' AND   h.PDLINE_ID='''+sPdlineID+''' '

           +' AND   a.Pdline_ID=h.Pdline_ID ';  }

  with QryData1 do
  begin
    if editlotno.Text ='' then
      begin
         showmessage('Please Input RunCard!');
         exit;
      end;
      Close;
      Params.Clear;
     sSQL :=sSQL +' and (((to_char(a.in_time,''yyyymmddhh24mi'') <='''+sEnd+''') '
                  +' and (to_char(a.out_time,''yyyymmddhh24mi'')>='''+sEnd+''')) '
                  +' or  ((to_char(a.out_time,''yyyymmddhh24mi'')>='''+sStart+''') '
                  +' and (to_char(a.out_time,''yyyymmddhh24mi'')<='''+sEnd+'''))) ';
      sSQL := sSQL + '  order by  a.in_time ' ;
      {sSQL :='select * from ( '  +sSQL+' and (((to_char(a.in_time,''yyyymmddhh24mi'') <='''+sEnd+''') '
                  +' and (to_char(a.out_time,''yyyymmddhh24mi'')>='''+sEnd+''')) '
                  +' or  ((to_char(a.out_time,''yyyymmddhh24mi'')>='''+sStart+''') '
                  +' and (to_char(a.out_time,''yyyymmddhh24mi'')<='''+sEnd+'''))) '
                  +' union ' +ssql1+  ') order by   in_time' }
      CommandText := sSQL;
      OPEN;
      //showmessage(inttostr(recordcount)) ;
  LabCount.Caption:=inttostr(recordcount);
  //LabRec.Caption:= inttostr(recordcount);
  screen.Cursor:=crDefault;
  SGrid.RowCount:=2;
  end;
end;

Function  TfSMTReport.GetFirstRC(var SN:string):Boolean;
var sWO:string;
    MinSN:string;
begin
{result:=false;
 with Qrytemp1 do
   begin
    close;
    params.Clear;
    params.CreateParam(ftstring,'sSN',ptinput);
    CommandText:='select work_order from lot.g_sn_travel where serial_number=:sSN ';
    params.ParamByName('sSN').AsString:=SN;
    open;
    sWO:=fieldByName('work_order').AsString;
    close;
    params.Clear;
    params.CreateParam(ftstring,'sWO',ptinput);
    CommandText:='select Min(serial_number) MinSN from lot.g_sn_travel where work_order=:sWO ';
    params.ParamByName('sWO').AsString:=sWO;
    open;
    MinSN:=FieldByname('MinSN').AsString;
    close;
   end;
 if SN=MinSN then Result:=true
 else Result:=false;  }
end;


Function  TfSMTReport.GetFirstProcess(var SN:string):string;
var routeid:string;
begin
 {With Qrytemp1 do
   begin
     close;
     params.Clear;
     params.CreateParam(ftstring,'SN',ptinput);
     CommandText:='select Route_id from lot.g_sn_status where serial_number=:SN';
     params.ParamByName('SN').AsString:=SN;
     open;
     routeid:=fieldbyname('Route_id').AsString;
     close;
     params.Clear;
     params.CreateParam(ftstring,'Routeid',ptinput);
     CommandText:='select a.Process_name from sajet.sys_process a,lot.sys_route_detail b '+
                  'where a.process_id=b.process_id '+
                  'and b.route_id=:Routeid '+
                  'and b.SEQ=''1'' '+
                  'order by b.SEQ DESC';
     params.ParamByName('Routeid').AsString:=routeid;
     open;
     if recordcount <> 0 then
       result:=fieldbyname('Process_name').AsString;
   end; }
end;
procedure TfSMTReport.SpeedButton1Click(Sender: TObject);
begin
  if (sModelID='') or (sPdLineID='') then
    begin
      Showmessage('Please Key Press First!');
      exit;
    end;
  IF chkbdate.Checked THEN
  BEGIN
    sStart:=formatDateTime('yyyymmdd',dtpickStart.date)+trim(edit1.Text)+trim(edit2.Text );
    sEnd:=formatDateTime('yyyymmdd',dtpickEnd.date)+trim(edit3.Text)+trim(edit4.Text );
  END
  ELSE
  BEGIN
    sPDlineID:='0';
    sPDlineID := strlstpdline.Strings[CmbPDline.Items.IndexOf(CmbPDline.Text)] ;
    WITH QRYTEMP DO
    BEGIN
      CLOSE;
      PARAMS.Clear;
      Params.CreateParam(ftstring,'sSN',ptinput);
      Params.CreateParam(ftstring,'sSPro',ptinput);
      Params.CreateParam(ftstring,'sEPro',ptinput);
      CommandText:='SELECT TO_CHAR(GST.OUT_PROCESS_TIME,''YYYYMMDDHH24MI'') OUT_TIME,GST.OUT_PROCESS_TIME,GST.PDLINE_ID '+
                   '  FROM SAJET.G_SN_TRAVEL GST  '+
                   ' WHERE  GST.SERIAL_NUMBER= :sSN and (GST.PROCESS_ID=:sSPro OR GST.PROCESS_ID=:sEPro ) ' ;
      if sPDlineID<>'0' then
        CommandText :=CommandText + ' and GST.PDLINE_ID =' +sPDlineID+' ' ;

      CommandText :=CommandText + ' ORDER BY OUT_PROCESS_TIME' ;
      
      Params.ParamByName('sSN').AsString:=trim(editlotno.Text);
      Params.ParamByName('sSPro').AsString:=strlstprocess.Strings[cmb_inproc.Items.IndexOf(cmb_inproc.Text)];
      Params.ParamByName('sEPro').AsString:=strlstprocess.Strings[cmb_outproc.Items.IndexOf(cmb_outproc.Text)];
      OPEN;
      IF NOT EOF THEN
      BEGIN
        sStart :=  FIELDBYNAME('OUT_TIME').AsString;
        sEnd :=  FIELDBYNAME('OUT_TIME').AsString;
        dtPickStart.DateTime:= FIELDBYNAME('OUT_PROCESS_TIME').AsDateTime;
        EDIT1.Text:= COPY(sStart,9,2);
        EDIT2.Text:=COPY(sStart,11,2);
        dtPickEnd.DateTime:= FIELDBYNAME('OUT_PROCESS_TIME').AsDateTime;
        EDIT3.Text:=COPY(sEnd,9,2);
        EDIT4.Text:=COPY(sEnd,11,2);
        sPDLineID:=  FIELDBYNAME('PDLINE_ID').AsString;
        Next;
      END;
      WHILE NOT EOF DO
      BEGIN
        sEnd :=  FIELDBYNAME('OUT_TIME').AsString;
        //dtPickStart.DateTime:= FIELDBYNAME('OUT_PROCESS_TIME').AsDateTime;
       // EDIT1.Text:= COPY(sStart,9,2);
        //EDIT2.Text:=COPY(sStart,11,2);
        dtPickEnd.DateTime:= FIELDBYNAME('OUT_PROCESS_TIME').AsDateTime;
        EDIT3.Text:=COPY(sEnd,9,2);
        EDIT4.Text:=COPY(sEnd,11,2);
        Next;
      END;
    END;
  END;
  ShowData(sModelID,sPDLineID,sStart,sEnd);
  ShowCOBData;
end;

procedure TfSMTReport.SpeedButton2Click(Sender: TObject);
Var F : TextFile;
    S : String;
    sh1,sh2:string;
begin
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'csv';
  SaveDialog1.Filter := 'All Files(*.csv)|*.csv';
  If SaveDialog1.Execute Then
  begin
     AssignFile(F,SaveDialog1.FileName);
     Rewrite(F);
     sh1:=' S/N:, '+editLotno.Text;
     Writeln(F,sh1);
     sh2:='Item Name,'+' Reel,'+'Machine,'+'Slot No,'+'Feeder No,'+'In time,'+'Out time,'+'Emp Name,'
          +'Date Code,'+'Vendor LotNo,'+'Line,'+'FeederType';
     Writeln(F,sh2);
     QryData1.First ;
     While not QryData1.Eof do
     begin
        //c.part_no,a.reel_no,m.MACHINE_CODE,a.slot_no,a.in_time,'
        //h.Pdline_Name,d.emp_no,a.out_time,d.emp_name,e.DATECODE Date_Code,a.FEEDER_NO,e.Vendor_LotNo,b.feeder_type '    //    ,g.vendor_name

        S := QryData1.Fieldbyname('part_no').AsString + ',' +
             QryData1.Fieldbyname('reel_no').AsString + ',' +
             QryData1.Fieldbyname('MACHINE_CODE').AsString + ',' +
             QryData1.Fieldbyname('slot_no').AsString + ',' +
             QryData1.Fieldbyname('FEEDER_NO').AsString + ',' +
             QryData1.Fieldbyname('in_time').AsString + ',' +
             QryData1.Fieldbyname('out_time').AsString + ',' +
             QryData1.Fieldbyname('emp_name').AsString+','+
             QryData1.Fieldbyname('Date_Code').AsString+','+
             QryData1.Fieldbyname('Vendor_LotNo').AsString+','+
             QryData1.Fieldbyname('PdLine_name').AsString +','+
             QryData1.Fieldbyname('Feeder_type').AsString;
        Writeln(F,S);
        QryData1.Next;
     end;
     MessageDlg('Export OK !!',mtCustom, [mbOK],0);
     CloseFile(F);
  end;
end;

procedure TfSMTReport.FormCreate(Sender: TObject);
begin
  dtpickStart.date:=now();
  dtpickEnd.Date:=now();

end;

procedure TfSMTReport.editLotnoChange(Sender: TObject);
var
sSQL:string;
FProcess:string;
SN:string;
begin
  sPDlineID:='';
  sModelID:='';
end;

procedure TfSMTReport.chkbDateClick(Sender: TObject);
begin
if chkbDate.Checked then
  begin
    dtPickStart.Enabled:=true;
    edit1.Enabled:=true;
    edit2.Enabled:=true;
    dtPickEnd.Enabled:=true;
    edit3.Enabled:=true;
    edit4.Enabled:=true;
  end
  else begin
         dtPickStart.Enabled:=false;
         edit1.Enabled:=false;
         edit2.Enabled:=false;
         dtPickEnd.Enabled:=false;
         edit3.Enabled:=false;
         edit4.Enabled:=false;
       end;
       
end;

procedure TfSMTReport.FormShow(Sender: TObject);
begin
  RcCount:=0;
  chkbDate.Checked:=false;
  LocationList:=TStringList.Create;
  VendorList:=TStringList.Create;
  strlstProcess:=tstringlist.Create;
  strlstPdline:=tstringlist.Create;
  OrderIdx:='a.in_time ';
  SGrid.Cells[0,0]:='Work Order';
  SGrid.Cells[1,0]:='Location';
  SGrid.Cells[2,0]:='Defect Code';
  SGrid.Cells[3,0]:='Defect Desc';
  SGrid.Cells[4,0]:='Reason Desc';
  SGrid.Cells[5,0]:='Old Item';
  SGrid.Cells[6,0]:='New Item BC';
  SGrid.Cells[7,0]:='Vendor Code';
  SGrid.Cells[8,0]:='Process Name';
  SGrid.Cells[9,0]:='Process Desc';
  SGrid.Cells[10,0]:='Emp Name';

  BindingProcess;
  BindingPdline;
end;

procedure TfSMTReport.editLotnoKeyPress(Sender: TObject; var Key: Char);
  function getSN:String;
  var ss : string;
  begin
    Result := '';
    with QryData do
    begin
       Close;
       Params.Clear;
       ss := 'SELECT SERIAL_NUMBER '
                    + '  FROM SAJET.G_SN_STATUS '
                    + ' WHERE CUSTOMER_SN = ''' + editLotNo.Text + ''''
                   // + '    or MAC_ID = ''' + editLotNo.Text + ''''
                    + '    or SERIAL_NUMBER = ''' + editLotNo.Text + ''' ';
       CommandText := ss;
       Open;
       FIRST;
       if not eof then
       begin
          ss := FieldByName('SERIAL_NUMBER').AsString;
          Result := ss;
       end;
       Close;
    end;
  end;
var sRcNo,sTSQL:string;
begin
if key=#13 then
  begin
    try
    LabMoC.Caption:=editLotNo.Text;
    sRcNo:=getSN;
    editLotNo.Text:=sRcNo;
    BindingProcessBySN(sRcNo);
    BindingPDlineBySN(sRcNo);
    with QryData do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'sSN',ptInput);
      sTSQL:='select c.pdline_id,c.model_id,C.WORK_ORDER,c.in_pdline_time,nvl(c.out_pdline_time,sysdate) out_pdline_time,b.part_no,b.VERSION,'+
            'nvl(c.out_pdline_time,sysdate) date1,substr(to_char(nvl(c.out_pdline_time,sysdate),''hh24mi''),1,2) hour1,'+
            'substr(to_char(nvl(c.out_pdline_time,sysdate),''hh24mi''),3,2) min1,'+
            'c.in_pdline_time date2,substr(to_char(c.in_pdline_time,''hh24mi''),1,2) hour2,'+
            'substr(to_char(c.in_pdline_time,''hh24mi''),3,2) min2' +
            //' from sajet.g_sn_status a,sajet.sys_part b,sajet.g_sn_travel c'+
            ' from sajet.sys_part b,sajet.g_sn_travel c'+
            //' where a.model_id=b.PART_ID and a.serial_number=:sSN and a.serial_number=c.serial_number and c.out_pdline_time is not null '+
            ' where c.serial_number=:sSN  and c.model_id=b.PART_ID  '+ //   and c.out_pdline_time is not null
            ' order by c.out_pdline_time';
      CommandText := sTSQL;
      params.ParamByName('sSN').AsString:=sRcNo;
      Open;
      if not eof then
      begin
        sPDLineID:=FieldByName('PDLINE_ID').AsString;
        sModelID:=FieldByName('MODEL_ID').AsString;
        MSLWO := FieldByName('WORK_ORDER').AsString;
        LabPN.Caption:=FieldByName('Part_No').AsString;
        LabRev.Caption:=FieldByName('Version').AsString;
        LBLWO.Caption:= FieldByName('WORK_ORDER').AsString;
        //dtPickStart.DateTime:=strtoDate(Fieldbyname('date2').AsString);
        dtPickStart.DateTime:=Fieldbyname('date2').AsDateTime;
        Edit1.Text:=fieldbyname('hour2').AsString;
        Edit2.Text:=fieldbyname('min2').AsString;
        //dtPickEnd.Datetime:=strtoDate(Fieldbyname('date1').AsString);
        dtPickEnd.Datetime:=Fieldbyname('date1').AsDateTime;
        Edit3.Text:=fieldbyname('hour1').AsString;
        Edit4.Text:=fieldbyname('min1').AsString;
        LabRec.Caption :='0';
      end
      else
      begin
        Showmessage('Input SN Invalid!');
        editLotNo.Text:='';
        editLotNo.SetFocus;
        exit;
      end;
    end;
    except
    showmessage('Out PDLine Time Null!');
    end;
  end;
end;

procedure TfSMTReport.CheckBox1Click(Sender: TObject);
begin
 if RcCount=0 then
   begin
     Showmessage('Data not assign!');
     exit;
   end;
end;

procedure TfSMTReport.DBGrid1TitleClick(Column: TColumn);
begin
  If Column.Title.Caption = 'ITEM NAME' Then
    OrderIdx:=' c.part_no ';
  If Column.Title.Caption = 'ITEM B/C' Then
    OrderIdx:=' a.reel_no ';
  If Column.Title.Caption = 'SLOT NO' Then
    OrderIdx:=' a.slot_no ';
  If Column.Title.Caption = 'IN TIME' Then
    OrderIdx:=' a.in_time ';
  If Column.Title.Caption = 'EMP NAME' Then
    OrderIdx:=' d.emp_name ';
  If Column.Title.Caption = 'LOCATION' Then
    OrderIdx:=' b.location ';
  If Column.Title.Caption = 'Vendor LotNo' Then
    OrderIdx:=' a.Vendor_lotno ';
  If Column.Title.Caption = 'Vendor Code' Then
    OrderIdx:=' a.Vendor_Code ';
  If Column.Title.Caption = 'PDLINE' Then
    OrderIdx:=' f.pdline_name ';
  sStart:=formatDateTime('yyyymmdd',dtpickStart.date)+trim(edit1.Text)+trim(edit2.Text );
  sEnd:=formatDateTime('yyyymmdd',dtpickEnd.date)+trim(edit3.Text)+trim(edit4.Text );
  ShowData(sModelID,sPDLineID,sStart,sEnd);
end;



//内部方法

//加载Process
Procedure TfSMTReport.BindingProcess();
begin
  with QryTemp do
  begin
    Close;
    CommandText := 'Select * from sajet.sys_process order by process_name';
    Open;
    cmb_InProc.Items.Clear;
    cmb_OutProc.Items.Clear;
    strlstProcess.Clear;
    while not eof do
    begin
      cmb_InProc.Items.Add(FieldByName('process_name').AsString);
      cmb_OutProc.Items.Add(FieldByName('process_name').AsString);
      strlstprocess.Add(FieldByName('PROCESS_ID').AsString);
      Next;
    end;
    if RecordCount >0 then
    begin
      cmb_InProc.ItemIndex := 1;
      cmb_OutProc.ItemIndex :=1;

    end;
  end;
end;

//add by ada 09-09-04
//加载PDLINE
Procedure TfSMTReport.BindingPDline();
begin
  with QryTemp do
  begin
    Close;
    CommandText := 'Select * from sajet.SYS_PDLINE order by PDLINE_NAME';
    Open;
    CmbPDline.Items.Clear;
    CmbPDline.Items.Add('Default');
    strlstPdline.Clear;
    strlstPdline.Add('0') ;
    while not eof do
    begin

      CmbPDline.Items.Add(FieldByName('PDLINE_name').AsString);
      strlstPdline.Add(FieldByName('PDLINE_ID').AsString);
      Next;
    end;
    if RecordCount >0 then
    begin
      CmbPDline.ItemIndex := 0;
    end;
  end;
end;

procedure TfSMTReport.FormDestroy(Sender: TObject);
begin
  strlstprocess.Destroy;
  strlstPdline.Destroy;
end;                                                                                         
procedure TfSMTReport.BindingProcessBySN(sSN: string);
begin
  with QryTemp do
  begin
    Close;
    params.Clear;
    params.CreateParam(ftstring,'sSN',ptinput);
    CommandText := 'SELECT distinct SP.PROCESS_NAME,SP.PROCESS_ID,GST.OUT_PROCESS_TIME '+
                   '  FROM SAJET.G_SN_TRAVEL GST LEFT JOIN SAJET.SYS_PROCESS SP ON GST.PROCESS_ID=SP.PROCESS_ID '+
                   ' WHERE GST.SERIAL_NUMBER= :sSN '+
                   ' ORDER BY GST.OUT_PROCESS_TIME';//SP.PROCESS_ID
    Params.ParamByName('sSN').AsString:=sSN;
    Open;
    cmb_InProc.Items.Clear;
    cmb_OutProc.Items.Clear;
    strlstProcess.Clear;
    while not eof do
    begin
      if strlstprocess.IndexOf(FieldByName('PROCESS_ID').AsString) <0 then
      begin
        cmb_InProc.Items.Add(FieldByName('process_name').AsString);
        cmb_OutProc.Items.Add(FieldByName('process_name').AsString);
        strlstprocess.Add(FieldByName('PROCESS_ID').AsString);
      end;
      Next;
    end;
    if RecordCount >0 then
    begin
      cmb_InProc.ItemIndex := 0;
      cmb_OutProc.ItemIndex :=cmb_OutProc.Items.Count-1;
    end;
  end;
end;

//add by ada 09-09-04
procedure TfSMTReport.BindingPDLineBySN(sSN: string);
begin
  with QryTemp do
  begin
    Close;
    params.Clear;
    params.CreateParam(ftstring,'sSN',ptinput);
    CommandText := 'SELECT distinct SP.PDLINE_NAME,SP.PDLINE_ID,GST.IN_PDLINE_TIME '+
                   '  FROM SAJET.G_SN_TRAVEL GST LEFT JOIN SAJET.SYS_PDLINE SP ON GST.PDLINE_ID=SP.PDLINE_ID '+
                   ' WHERE GST.SERIAL_NUMBER= :sSN '+
                   ' ORDER BY GST.IN_PDLINE_TIME';
    Params.ParamByName('sSN').AsString:=sSN;
    Open;
    CmbPDline.Items.Clear;
    CmbPDline.Items.Add('Default');
    strlstPDLine.Clear;
    strlstPDLine.Add('0') ;
    while not eof do
    begin
      if strlstPDLine.IndexOf(FieldByName('PDLINE_ID').AsString) <0 then
      begin
        CmbPDline.Items.Add(FieldByName('PDLINE_NAME').AsString);
        strlstPDLine.Add(FieldByName('PDLINE_ID').AsString);
      end;
      Next;
    end;
    if RecordCount >0 then
    begin
      CmbPDline.ItemIndex := 0;
    end;
  end;
end;


procedure TfSMTReport.cmb_InProcChange(Sender: TObject);
begin
  if CmbPDline.Items.IndexOf(CmbPDline.Text)<0 then
  begin
    Showmessage('Please select pdline');
    exit;
  end;
  WITH QRYTEMP DO
  BEGIN
    CLOSE;
    PARAMS.Clear;
    Params.CreateParam(ftstring,'sSN',ptinput);
    Params.CreateParam(ftstring,'sSPro',ptinput);
    Params.CreateParam(ftstring,'sEPro',ptinput);
    //CommandText:='SELECT TO_CHAR(GST.OUT_PROCESS_TIME,''YYYYMMDDHH24MI'') OUT_PROCESS_TIME '+
    CommandText:='SELECT GST.OUT_PROCESS_TIME,TO_CHAR(GST.OUT_PROCESS_TIME,''YYYYMMDDHH24MI'') OUT_TIME '+
                 '  FROM SAJET.G_SN_TRAVEL GST  '+
                 ' WHERE  GST.SERIAL_NUMBER= :sSN and (GST.PROCESS_ID=:sSPro OR GST.PROCESS_ID=:sEPro ) '+
                 ' ORDER BY OUT_PROCESS_TIME';
    Params.ParamByName('sSN').AsString:=trim(editlotno.Text);
    Params.ParamByName('sSPro').AsString:=strlstprocess.Strings[cmb_inproc.Items.IndexOf(cmb_inproc.Text)];
    Params.ParamByName('sEPro').AsString:=strlstprocess.Strings[cmb_outproc.Items.IndexOf(cmb_outproc.Text)];
    OPEN;
    if eof then
    begin
      Showmessage('Not found data match process!');
      exit;
    end;
    IF NOT EOF THEN
    BEGIN
      sStart :=  FIELDBYNAME('OUT_TIME').AsString;
      sEnd :=  FIELDBYNAME('OUT_TIME').AsString;
      dtPickStart.DateTime:= FIELDBYNAME('OUT_PROCESS_TIME').AsDateTime;
      EDIT1.Text:= COPY(sStart,9,2);
      EDIT2.Text:=COPY(sStart,11,2);
      dtPickEnd.DateTime:= FIELDBYNAME('OUT_PROCESS_TIME').AsDateTime;
      EDIT3.Text:=COPY(sEnd,9,2);
      EDIT4.Text:=COPY(sEnd,11,2);
      Next;
    END;
    WHILE NOT EOF DO
    BEGIN
      sEnd :=  FIELDBYNAME('OUT_TIME').AsString;
      dtPickEnd.DateTime:= FIELDBYNAME('OUT_PROCESS_TIME').AsDateTime;
      EDIT3.Text:=COPY(sEnd,9,2);
      EDIT4.Text:=COPY(sEnd,11,2);
      Next;
    END;
    {IF SENDER <>CmbPDline THEN
    BEGIN
      CmbPDline.ItemIndex:=0;
      CmbPDline.Text:='Default';
    end; }
  END;
end;

procedure TfSMTReport.CmbPDlineChange(Sender: TObject);
 //var sPDlineID:string;
begin
  if Trim(editLotNo.Text) ='' then
  begin
    Showmessage('Please key in serial number!');
    exit;
  end;

  if CmbPDline.Items.IndexOf(CmbPDline.Text)<0 then
  begin
    Showmessage('Select Pdline name error!');
    exit;
  end;
  sPDlineID:='0';
  sPDlineID := strlstpdline.Strings[ CmbPDline.Items.IndexOf(CmbPDline.Text)] ;
  with QryTemp do
  begin
    Close;
    params.Clear;
    params.CreateParam(ftstring,'sSN',ptinput);
    CommandText := 'SELECT distinct SP.PROCESS_NAME,SP.PROCESS_ID,GST.OUT_PROCESS_TIME '+
                   '  FROM SAJET.G_SN_TRAVEL GST LEFT JOIN SAJET.SYS_PROCESS SP ON GST.PROCESS_ID=SP.PROCESS_ID '+
                   ' WHERE GST.SERIAL_NUMBER= :sSN ';
    if sPDlineID<>'0' then
      CommandText :=CommandText + ' and GST.PDLINE_ID =' +sPDlineID+' ' ;
    CommandText :=CommandText + ' ORDER BY GST.OUT_PROCESS_TIME';//SP.PROCESS_ID
    Params.ParamByName('sSN').AsString:=Trim(editLotNo.Text);
    Open;
    cmb_InProc.Items.Clear;
    cmb_OutProc.Items.Clear;
    strlstProcess.Clear;
    while not eof do
    begin
      if strlstprocess.IndexOf(FieldByName('PROCESS_ID').AsString) <0 then
      begin
        cmb_InProc.Items.Add(FieldByName('process_name').AsString);
        cmb_OutProc.Items.Add(FieldByName('process_name').AsString);
        strlstprocess.Add(FieldByName('PROCESS_ID').AsString);
      end;
      Next;
    end;
    if RecordCount >0 then
    begin
      cmb_InProc.ItemIndex := 0;
      cmb_OutProc.ItemIndex :=cmb_OutProc.Items.Count-1;
      cmb_InProcChange (CmbPDline);
    end;
  end;
  
end;

procedure TfSMTReport.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfSMTReport.ShowCOBData;
var sSQL,sLocation,ssql1:string;
  sRTNO:string;
  i,j,k:integer;
  sCount :integer;
begin
  Screen.Cursor:=crHourGlass;
  sSQL := 'Select ss.work_order,csm.serial_number,(csm.box_no)Carrier,csm.update_time, '
        + '(part_sn)reel_no,(se.emp_name)update_user,sp.process_name, '
        + '(case when csm.location=''N/A'' then ''Whiffied'' else csm.location end)location '
        + 'from sajet.g_cob_sn_map csm '
        + 'left outer join sajet.g_sn_status ss on csm.serial_number=ss.serial_number '
        + 'left outer join sajet.sys_terminal st on csm.terminal_id=st.terminal_id '
        + 'left outer join sajet.sys_process sp on st.process_id=sp.process_id '
        + 'left outer join sajet.sys_emp se on csm.update_userid=se.emp_id '
        + 'where csm.serial_number='''+trim(editLotno.Text)+'''  '
        + 'Order by csm.update_time';

  with QryCOBData do
  begin
    Close;
    Params.Clear;
    CommandText := sSQL;
    OPEN;
    
    LabRec.Caption:= inttostr(recordcount);
    screen.Cursor:=crDefault;
  end;
end;

end.
