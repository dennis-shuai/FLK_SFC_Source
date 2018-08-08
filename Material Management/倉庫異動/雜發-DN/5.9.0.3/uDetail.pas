unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles, ComCtrls, RzButton, RzRadChk;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryMaterial: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    DBGrid2: TDBGrid;
    QryDetail: TClientDataSet;
    DataSource2: TDataSource;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    edtMISCNO: TEdit;
    Label4: TLabel;
    DBGrid1: TDBGrid;
    edtISSUEUSER: TEdit;
    Bevel2: TBevel;
    sbtnMISC: TSpeedButton;
    Label8: TLabel;
    edtmaterial: TEdit;
    EditORG: TEdit;
    Label13: TLabel;
    Image1: TImage;
    sbtnconfirm: TSpeedButton;
    chkPush: TRzCheckBox;
    lablocate: TLabel;
    lablVersion: TLabel;
    procedure FormShow(Sender: TObject);
    procedure edtMISCNOKeyPress(Sender: TObject; var Key: Char);
    procedure DataSource2DataChange(Sender: TObject; Field: TField);
    procedure sbtnMaterialClick(Sender: TObject);
    procedure sbtnMISCClick(Sender: TObject);
    procedure edtmaterialKeyPress(Sender: TObject; var Key: Char);
    procedure edtMISCNOChange(Sender: TObject);
    procedure sbtnmfgerClick(Sender: TObject);
    procedure sbtnconfirmClick(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtmaterialChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelField, gsBoxField, gsReelField: string;
    G_FCID,G_FCCODE,G_FCTYPE:string;
    procedure showData(sLocate: string);
    Function GetFIFOCode(dDate:TDateTime):string;
    Function GetFCTYPE(sFCID:string):string;
    function checkFIFO(MaterailNo:string;VAR NOCHECK:STRING):string;
    function SendMsg:boolean;
    function CheckMaterial: Boolean;
    procedure GetVersion(S: string);
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin, uCommData, Udata;

function TfDetail.CheckMaterial: Boolean;
var iQty: Integer; iWmQty, iTemp: Real;
  sPartId, sType, sDateCode, OverRequest,
  sPartNo, sVersion, sStock, sLocate, sItemID,
  sISSUE_HEADER_ID,sissue_line_id,sRC_MIS_ID,strmsg,
  sISSUE_TYPE,sISSUE_TYPE_NAME,sSEQ_NUMBER,sINVENTORY_ITEM_ID,
  sSUBINV,sLOCATOR,sORG_ID: string;
begin
  Result := True;
  QryTemp.Close;
  QryTemp.Params.Clear;
  QryTemp.Params.CreateParam(ftString, 'material_no', ptInput);
  QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
  QryTemp.CommandText := 'select a.reel_no, a.material_no, b.part_no, b.VERSION, b.option7, b.part_type,a.factory_id, '
    + ' c.warehouse_name, d.locate_name '
    + ' from sajet.g_material a, sajet.sys_part b,sajet.sys_warehouse c,sajet.sys_locate d '
    + ' where (reel_no = :reel_no or material_no = :material_no)  '
    + ' and a.part_id = b.part_id '
    + ' and a.locate_id = d.locate_id(+) and a.warehouse_id = c.warehouse_id(+) '
    + ' and rownum = 1';
  QryTemp.Params.ParamByName('material_no').AsString := edtMaterial.Text;
  QryTemp.Params.ParamByName('reel_no').AsString := edtMaterial.Text;
  QryTemp.Open;
  if QryTemp.IsEmpty then
  begin
    MessageDlg('ID No: ' + edtMaterial.Text + ' not found.', mtError, [mbOK], 0);
    Result := False;
    Exit;
  end
  else if QryTemp.FieldByName('factory_id').AsString <> G_FCID then
  begin
    MessageDlg('ID No: ' + edtMaterial.Text + ' ORG ID IS NOT '+editorg.Text , mtError, [mbOK], 0);
    Result := False;
    Exit;
  end
  else
  begin
    lablocate.Caption := QryTemp.FieldByName('warehouse_name').AsString+'-'+ QryTemp.FieldByName('locate_name').AsString ;
    sPartNo := QryTemp.FieldByName('part_no').AsString;
    sItemID := QryTemp.FieldByName('option7').AsString;
    sVersion := QryTemp.FieldByName('version').AsString;
    if QryTemp.FieldByName('material_no').AsString = edtMaterial.Text then
      sType := 'Material'
    else
      sType := 'Reel';
  end;
  QryTemp.Close;
  QryTemp.Params.Clear;
  QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
  QryTemp.Params.CreateParam(ftString, 'document_number', ptInput);
  QryTemp.CommandText := ' select a.reel_no, a.reel_qty, a.material_no, a.material_qty, a.status, '
                        +' a.part_id, a.datecode  from   '
                        +' sajet.g_material a ,sajet.g_erp_rc_mis_master b ,sajet.g_erp_rc_mis_detail c  '
                        +' where ' + sType + '_No = :reel_no '
                        +' and a.part_id=c.part_id   '
                        //+' and a.locate_id=c.locate_id   '   //20101102 by xiaobo_yuan 取消儲位檢查
                        +' and b.rc_mis_id=c.rc_mis_id   '
                        +' and b.document_number=:document_number';
  QryTemp.Params.ParamByName('reel_no').AsString := edtMaterial.Text;
  QryTemp.Params.ParamByName('document_number').AsString := edtmiscno.Text;
  QryTemp.Open;
  if QryTemp.IsEmpty then
  begin
    MessageDlg('Part: ' + sPartNo + ' - Error ' + #13#13
             // +'Or Part: ' + sPartNo + ' - Over Request. ' + #13#13
              +'OR Locate Error ', mtError, [mbOK], 0);
    Result := False;
    Exit;
  end;
  if (sType = 'Material') and (QryTemp.FieldByName('reel_qty').AsInteger <> 0) then
  begin
    MessageDlg('ID No: ' + edtMaterial.Text + ' reel_qty >0 ', mtError, [mbOK], 0);
    Result := False;
    Exit;
  end
  else if QryTemp.FieldByName('reel_qty').AsInteger <> 0 then
    iQty := QryTemp.FieldByName('reel_qty').AsInteger
  else
    iQty := QryTemp.FieldByName('material_qty').AsInteger;
  if QryTemp.FieldByName('Status').AsString <> '1' then
  begin
    MessageDlg('ID No: ' + edtMaterial.Text + ' not InStock.', mtError, [mbOK], 0);
    Result := False;
  end
  else
  begin
    sPartId := QryTemp.FieldByName('part_id').AsString;

     //限制超發
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'part_id', ptInput);
    QryTemp.Params.CreateParam(ftString, 'document_number', ptInput);
    QryTemp.Params.CreateParam(ftString, 'qty', ptInput);
    QryTemp.CommandText := 'SELECT A.ROWID, A.RC_MIS_ID,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.SEQ_NUMBER, '
          +' A.PART_ID,A.APPLY_QTY,A.PRINT_QTY,A.LOCATE_ID, '
          +' B.DOCUMENT_NUMBER,B.ISSUE_TYPE,B.ISSUE_TYPE_NAME,A.ORGANIZATION_ID,B.STATUS, '
          +' C.PART_NO,C.OPTION7,C.OPTION1,  '
          +' D.WAREHOUSE_NAME,D.WAREHOUSE_ID,E.LOCATE_NAME,  '
          +' F.FACTORY_CODE,FACTORY_NAME '
          +' FROM SAJET.G_ERP_RC_MIS_DETAIL A,SAJET.G_ERP_RC_MIS_MASTER B,SAJET.SYS_PART C,'
          +' SAJET.SYS_WAREHOUSE D,SAJET.SYS_LOCATE E,SAJET.SYS_FACTORY F  '
          +' WHERE B.DOCUMENT_NUMBER=:DOCUMENT_NUMBER  '
          +' and a.part_id=:part_id '
          +' and a.apply_qty-a.print_qty >=:qty '
          +' AND A.RC_MIS_ID=B.RC_MIS_ID '
          +' AND A.ORGANIZATION_ID=B.ORGANIZATION_ID '
          +' AND A.PART_ID=C.PART_ID '
          +' AND E.LOCATE_ID=A.LOCATE_ID '
          +' AND E.WAREHOUSE_ID=D.WAREHOUSE_ID  '
          +' AND B.ORGANIZATION_ID=F.FACTORY_ID '
          +' AND A.ENABLED=''Y''   '
          +' AND B.ENABLED=''Y''  '
          +' AND D.ENABLED=''Y''  '
          +' AND E.ENABLED=''Y''   '
          +' and rownum=1 ';
    QryTemp.Params.ParamByName('part_id').AsString := sPartId;
    QryTemp.Params.ParamByName('document_number').AsString := edtmiscno.Text;
    QryTemp.Params.ParamByName('qty').AsInteger := iQty;
    QryTemp.Open;
    if QryTemp.isempty then
    begin
          MessageDlg('Part: ' + sPartNo + ' - Over Request. ', mtError, [mbOK], 0);
          Result := False;
          Exit;
    end;
    sRC_MIS_ID := QryTemp.FieldByName('RC_MIS_ID').AsString;
    sissue_line_id := QryTemp.FieldByName('issue_line_id').AsString;
    sISSUE_HEADER_ID := QryTemp.FieldByName('ISSUE_HEADER_ID').AsString;
    sISSUE_TYPE := QryTemp.FieldByName('ISSUE_TYPE').AsString;
    sISSUE_TYPE_NAME := QryTemp.FieldByName('ISSUE_TYPE_NAME').AsString;
    sSEQ_NUMBER := QryTemp.FieldByName('SEQ_NUMBER').AsString;
    sINVENTORY_ITEM_ID := QryTemp.FieldByName('OPTION7').AsString;
    sSUBINV  := QryTemp.FieldByName('WAREHOUSE_NAME').AsString;
    sLOCATOR := QryTemp.FieldByName('LOCATE_NAME').AsString;
    sORG_ID  := QryTemp.FieldByName('FACTORY_CODE').AsString;

     //insert into g_pick_list
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'work_order', ptInput);
    QryTemp.Params.CreateParam(ftString, 'update_userid', ptInput);
    QryTemp.Params.CreateParam(ftInteger, 'sequence', ptInput);
    QryTemp.Params.CreateParam(ftString, 'material_no', ptInput);
    QryTemp.CommandText := 'insert into sajet.g_pick_list '
      + '(work_order, update_userid, material_no, part_id, qty, datecode, MFGER_NAME, MFGER_PART_NO, version) ';
    if sType = 'Material' then
      QryTemp.CommandText := QryTemp.CommandText
        + 'select :work_order, :update_userid, material_no, part_id, material_qty, datecode,  MFGER_NAME, MFGER_PART_NO, version '
    else
      QryTemp.CommandText := QryTemp.CommandText
        + 'select :work_order, :update_userid, reel_no, part_id, reel_qty, datecode,  MFGER_NAME, MFGER_PART_NO, version ';
    QryTemp.CommandText := QryTemp.CommandText + 'from sajet.g_material ';
    if (sType = 'Material') or (sType = 'Material1') then
      QryTemp.CommandText := QryTemp.CommandText + 'where material_no = :material_no'
    else
    QryTemp.CommandText := QryTemp.CommandText + 'where reel_no = :material_no ';
    QryTemp.Params.ParamByName('work_order').AsString := edtmiscno.Text;
    QryTemp.Params.ParamByName('update_userid').AsString := UpdateUserid;
    QryTemp.Params.ParamByName('material_no').AsString := edtMaterial.Text;
    QryTemp.Execute;
    QryTemp.Close;

   //update g_material
    Qrytemp.Close;
    qrytemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
    QryTemp.Params.CreateParam(ftString, 'userid', ptInput);
    if sType = 'Reel' then
      Qrytemp.CommandText:=' update sajet.g_material '
                          +' set type=''O''  '
                          +'    ,update_userid= :userid '
                          +'    ,update_time=sysDate '
                          +' where reel_no=:reel_no '
    else
      Qrytemp.CommandText:=' update sajet.g_material '
                          +' set type=''O''  '
                          +'    ,update_userid= :userid '
                          +'    ,update_time=sysdate '
                          +' where material_no=:reel_no ';
    QryTemp.Params.ParamByName('reel_no').AsString := edtMaterial.Text;
    QryTemp.Params.ParamByName('userid').AsString := UpdateUserid;
    QryTemp.Execute;
    QryTemp.Close;

    //insert into g_ht_material
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
    if sType = 'Reel' then
      QryTemp.CommandText := 'insert into sajet.g_ht_material '
        + 'select * from sajet.g_material where reel_no = :reel_no  '
    else
      QryTemp.CommandText := 'insert into sajet.g_ht_material '
        + 'select * from sajet.g_material where material_no = :reel_no  ';
    QryTemp.Params.ParamByName('reel_no').AsString := edtMaterial.Text;
    QryTemp.Execute;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString, 'reel_no', ptInput);
    if sType = 'Reel' then
      QryTemp.CommandText := 'delete from sajet.g_material '
        + 'where reel_no = :reel_no '
    else
      QryTemp.CommandText := 'delete from sajet.g_material '
        + 'where material_no = :reel_no ';
    QryTemp.Params.ParamByName('reel_no').AsString := edtMaterial.Text;
    QryTemp.Execute;
    QryTemp.Close; 

    //update g_erp_rc_mis_detail
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftInteger, 'QTY', ptInput);
    QryTemp.Params.CreateParam(ftString, 'RC_MIS_ID', ptInput);
    QryTemp.Params.CreateParam(ftString, 'issue_line_id', ptInput);
    QryTemp.CommandText := 'update SAJET.G_ERP_RC_MIS_DETAIL '
      + 'set PRINT_QTY = PRINT_QTY + :QTY '
      + 'where RC_MIS_ID = :RC_MIS_ID and issue_line_id = :issue_line_id AND rownum=1 ';
    QryTemp.Params.ParamByName('QTY').AsInteger := iQty;
    QryTemp.Params.ParamByName('RC_MIS_ID').AsString := sRC_MIS_ID;
    QryTemp.Params.ParamByName('issue_line_id').AsString := sissue_line_id;
    QryTemp.Execute;
    QryTemp.Close;

    //insert into mes_to_erp_rc_mis
    with sproc do
      begin
      try
        Close;
        DataRequest('SAJET.MES_ERP_RC_MIS');
        FetchParams;
        Params.ParamByName('TDOCUMENT_NUMBER').AsString := edtmiscno.Text;
        Params.ParamByName('TISSUE_HEADER_ID').AsString := sISSUE_HEADER_ID;
        Params.ParamByName('TISSUE_LINE_ID').AsString := sissue_line_id;
        Params.ParamByName('TISSUE_TYPE').AsString := sISSUE_TYPE;
        Params.ParamByName('TISSUE_TYPE_NAME').AsString := sISSUE_TYPE_NAME;
        Params.ParamByName('TSEQ_NUMBER').AsString := sSEQ_NUMBER;
        Params.ParamByName('TINVENTORY_ITEM_ID').AsString :=sINVENTORY_ITEM_ID;
        Params.ParamByName('TSUBINV').AsString := sSUBINV;
        Params.ParamByName('TLOCATOR').AsString := sLOCATOR;
        Params.ParamByName('TMATERIAL_NO').AsString := edtMaterial.Text;
        Params.ParamByName('TQTY').AsInteger := iQty;
        Params.ParamByName('TCREATE_USERID').AsString := UpdateUserID;
        Params.ParamByName('TISSUE_USER').AsString :=edtissueuser.Text;
        Params.ParamByName('TORG_ID').AsString := sORG_ID;
        Params.ParamByName('Ttype_class').AsString :='I' ;
        Params.ParamByName('TPUSH').AsString := 'N';
        Params.ParamByName('TTRXNTYPE').AsString := 'D3';
        Params.ParamByName('TRECORD_STATUS').AsString :='';  
        Execute;

        strmsg:=PARAMS.PARAMBYNAME('TRES').AsString;
        if strmsg<>'OK' then
        begin
          MessageDlg('UPDATE SAJET.MES_ERP_RC_MIS ERROR '+#13#13
                  + STRMSG , mtError, [mbOK], 0);
          Result := False;
          Exit;
        end;
      finally
        close;
      end;
     end;


  end;
end;

procedure TfDetail.GetVersion(S: string);
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
    lablVersion.Caption := 'Version: ' +
      FloatToStr(hextoint(copy(MVersion, 1, 4))) + '.' +
      FloatToStr(hextoint(copy(MVersion, 5, 4))) + '.' +
      FloatToStr(hextoint(copy(SVersion, 1, 4))) + '.' +
      FloatToStr(hextoint(copy(SVersion, 5, 4)));
  finally
    FreeMem(VersinInfo, VersinInfoSize);
  end;
end;

function TfDetail.SendMsg:boolean;
begin
  with qrytemp do
  begin
    close;
    commandtext:='select param_value from sajet.sys_base where upper(param_name)=''SHOW_FIFO'' ';
    open;
    Result:=(fieldbyname('Param_value').AsString='Y');
  end;
end;

function TfDetail.checkFIFO(MaterailNo:string;VAR NOCHECK:STRING):string;
begin
  with sproc do
  begin
    try
       try
        Close;
        DataRequest('SAJET.SJ_CHECK_FIFO');
        FetchParams;
        Params.ParamByName('MATERIALNO').AsString := MaterailNo;
        Params.ParamByName('empid').AsString := UpdateUserID;
        Execute;
        RESULT:=PARAMS.PARAMBYNAME('TRES').AsString;
        NOCHECK:=PARAMS.PARAMBYNAME('NoCheck').AsString;
       except
        RESULT:='SAJET.SJ_CHECK_FIFO ERROR!-CALL DBA';
       end;
    finally
        close;
    end;
  end;
end;

procedure TfDetail.ShowData(sLocate: string);
var sSQL: string;  bPrinted: Boolean;
begin
  sSQL := 'SELECT A.ROWID, A.RC_MIS_ID,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.SEQ_NUMBER, '
          +' A.PART_ID,A.APPLY_QTY,A.PRINT_QTY,A.LOCATE_ID, '
          +' B.DOCUMENT_NUMBER,B.ISSUE_TYPE,B.ISSUE_TYPE_NAME,A.ORGANIZATION_ID,B.STATUS, '
          +' C.PART_NO,C.OPTION7,C.OPTION1,  '
          +' D.WAREHOUSE_NAME,D.WAREHOUSE_ID,E.LOCATE_NAME,  '
          +' F.FACTORY_CODE,FACTORY_NAME '
          +' FROM SAJET.G_ERP_RC_MIS_DETAIL A,SAJET.G_ERP_RC_MIS_MASTER B,SAJET.SYS_PART C,'
          +' SAJET.SYS_WAREHOUSE D,SAJET.SYS_LOCATE E,SAJET.SYS_FACTORY F  '
          +' WHERE B.DOCUMENT_NUMBER=:DOCUMENT_NUMBER  '
          +' AND  A.RC_MIS_ID=B.RC_MIS_ID '
          +' AND A.ORGANIZATION_ID=B.ORGANIZATION_ID '
          +' AND A.PART_ID=C.PART_ID '
          +' AND E.LOCATE_ID=A.LOCATE_ID '
          +' AND E.WAREHOUSE_ID=D.WAREHOUSE_ID  '
          +' AND B.ORGANIZATION_ID=F.FACTORY_ID '
          +' AND A.ENABLED=''Y''   '
          +' AND B.ENABLED=''Y''  '
          +' AND D.ENABLED=''Y''  '
          +' AND E.ENABLED=''Y''   '
          +' AND B.type_class=''I'' '
          +' Order By A.SEQ_NUMBER ';
  with QryDetail do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
    CommandText := sSQL;
    Params.ParamByName('DOCUMENT_NUMBER').AsString := edtMISCNO.Text;
    Open;
    if IsEmpty then begin
      MessageDlg('MISC No: ' + edtMISCNO.Text + ' not found.', mtError, [mbOK], 0);
      edtMISCNO.SelectAll;
      edtMISCNO.SetFocus;
      Exit;
    end;
    bPrinted := True;

    G_FCID:='';
    G_FCCODE:='';
    G_FCTYPE:='';
    editorg.Clear ;
    G_FCID:=fieldbyname('ORGANIZATION_ID').AsString;
    if Getfctype(G_FCID)<>'OK' then
    begin
        editorg.Clear;
        exit;
    end
    else
       editorg.Text :=G_FCCODE;

    while not Eof do begin
     if FieldByName('APPLY_QTY').AsInteger > FieldByName('PRINT_QTY').AsInteger then
      begin
        bPrinted := False;
        break;
      end;
      Next;
    end;
    
    if sLocate <> '' then
      Locate('RowId', sLocate, []);

    lablocate.Caption:='';
    if  FieldByName('status').AsInteger=1 then //had confirm
    begin
       sbtnconfirm.Enabled :=false;
       edtmaterial.Enabled :=false;
       edtmiscno.Enabled :=true;
       showmessage('The source had confirm!') ;
       exit;
    end;
    if  FieldByName('status').AsInteger=0 then //NOT confirm
    begin
       sbtnconfirm.Enabled :=true;
       edtmaterial.Enabled :=true;
       edtmiscno.Enabled :=false;
    end;
  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var PIni: TIniFile;
begin
  GetVersion(ExtractFileDir(Application.ExeName) + '\RCMISCISSUEDLL.Dll');
  sbtnconfirm.Enabled:=false;
  PIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Material.Ini');
  gsBoxField := PIni.ReadString('Material', 'Material Default Qty Field', 'OPTION5');
  gsReelField := PIni.ReadString('Material', 'Reel Default Qty Field', 'OPTION6');
  PIni.Free;
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  edtMISCNO.SetFocus;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'RCMISCISSUEDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
   { Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Label Type'' ';
    Open;
    gsLabelField := FieldByName('param_name').AsString;
    Close;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Qty Field'' ';
    Open;
    gsBoxField := FieldByName('param_value').AsString;
    Close;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Reel Qty Field'' ';
    Open;
    gsReelField := FieldByName('param_value').AsString;
    }
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then begin
      edtMISCNO.CharCase := ecUpperCase;
      edtissueuser.CharCase :=ecuppercase;
      edtmaterial.CharCase :=ecuppercase;
    end;
  end;
end;

procedure TfDetail.edtMISCNOKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
    ShowData('');
end;

procedure TfDetail.DataSource2DataChange(Sender: TObject; Field: TField);
var iTemp: Integer;
begin
  with QryMaterial do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
    CommandText := ' SELECT A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.ISSUE_TYPE,A.ISSUE_TYPE_NAME,A.SEQ_NUMBER,A.INVENTORY_ITEM_ID, '
                  +' A.SUBINV,A.LOCATOR,A.MATERIAL_NO,A.QTY, A.CREATE_TIME,A.CREATE_USERID,A.ORG_ID, '
                  +' B.PART_NO,C.EMP_NO||''-''||C.EMP_NAME AS CREATE_USER,ISSUE_USER  '
                  +' FROM  SAJET.MES_TO_ERP_RC_MIS A,SAJET.SYS_PART B,SAJET.SYS_EMP C '
                  +' WHERE  A.DOCUMENT_NUMBER=:DOCUMENT_NUMBER '
                  +'  AND A.INVENTORY_ITEM_ID = B.OPTION7 '
                  +'  AND A.CREATE_USERID = C.EMP_ID '
                  +'   ORDER BY A.SEQ_NUMBER,B.PART_NO,A.CREATE_TIME ';
    Params.ParamByName('DOCUMENT_NUMBER').AsString :=QryDetail.FieldByName('DOCUMENT_NUMBER').AsString;
    Open;
  end;
end;

procedure TfDetail.sbtnMaterialClick(Sender: TObject);
var sMaterial, sPrintData: string; i, iTemp, iMod: Integer; bOver: Boolean;
begin
  if not QryDetail.Active then Exit;
  if QryDetail.IsEmpty then Exit;
  if trim(editorg.Text)='' then
  begin
    MessageDlg('ORG IS NULL', mtError, [mbOK], 0);
    Exit;
  end;
  {if trim(edtDateCode.Text)='' then
  begin
    MessageDlg('Please Input DateCode', mtError, [mbOK], 0);
    Exit;
  end;
  if trim(edtPN.Text)='' then
  begin
    MessageDlg('Please Input MFGER P/N.', mtError, [mbOK], 0);
    Exit;
  end;
  if trim(edtName.Text)='' then
  begin
    MessageDlg('Please Input MFGER Name.', mtError, [mbOK], 0);
    Exit;
  end;
  }

  ShowData(QryDetail.FieldByName('RowId').AsString);
end;

procedure TfDetail.sbtnMISCClick(Sender: TObject);
var Key: Char;
begin
  with TfCommData.Create(Self) do
  begin
    LabType2.Caption := 'MISC No List';
    LabType1.Caption := LabType2.Caption;
    Label1.Caption := 'Search MISC No';
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
      CommandText := 'SELECT DOCUMENT_NUMBER,ISSUE_TYPE,ISSUE_TYPE_NAME,RECEIVE_TIME from SAJET.G_ERP_RC_MIS_MASTER  '
        + 'Where DOCUMENT_NUMBER like :DOCUMENT_NUMBER and ENABLED = ''Y'' and status = 0 AND type_class=''I''  '
        + 'Order By DOCUMENT_NUMBER ';
      Params.ParamByName('DOCUMENT_NUMBER').AsString := edtMISCNO.Text + '%';
      Open;
      DataSource1.DataSet := QryTemp ;
    end;
    if Showmodal = mrOK then
    begin
      edtMISCNO.Text := QryTemp.FieldByName('DOCUMENT_NUMBER').AsString;
      QryTemp.Close;
      Key := #13;
      edtMISCNOKeyPress(Self, Key);
      //edtMISCNO.SetFocus;
      //edtMISCNO.SelectAll;
    end;
    free;
  end;
end;


procedure TfDetail.edtmaterialKeyPress(Sender: TObject; var Key: Char);
var sType,sNoCheck,sStr: string;
    i : Integer;
begin
  if Ord(Key) = vk_Return then
  begin
    sStr:= checkFIFO(TRIM(edtMaterial.Text),sNoCheck);
    if sStr  <>'OK' then
    begin
      MessageDlg(sStr, mtError, [mbOK], 0);
      exit;
    end;
    if (sNoCheck='NG') and SendMsg then
    begin
      MessageDlg('Not Check FIFO!', mtError, [mbOK], 0);
    end;
    if (sNoCheck='NGFIFO') and SendMsg then
    begin
      MessageDlg('Unlimit By Fifo!', mtError, [mbOK], 0);
    end;
    if CheckMaterial then
    begin
       ShowData('');
      edtMaterial.SelectAll;
      edtmaterial.SetFocus ;
    end;
  end;
end;


Function TfDetail.GetFIFOCode(dDate:TDateTime):string;
var strDate:string;
begin
  sTrDate:=formatDateTime('YYYYMMDD',dDate);
  with sproc do
    begin
      try
        Close;
        DataRequest('SAJET.SJ_GET_fifo');
        FetchParams;
        Params.ParamByName('TDATE').AsString := sTrDate;
        Execute;
        IF Params.ParamByName('TRES').AsString='OK' THEN
          RESULT:=Params.ParamByName('FIFOCODE').AsString
        else
          Showmessage(Params.ParamByName('TRES').AsString);
      finally
        close;
      end;
    end;
end;

Function TfDetail.Getfctype(sFCid:string):string;
var strDate:string;
begin
  with sproc do
    begin
      try
        Close;
        DataRequest('SAJET.SJ_GET_FACTORY_TYPE');
        FetchParams;
        Params.ParamByName('TFCID').AsString := sFCid;
        Execute;
        IF Params.ParamByName('TRES').AsString='OK' THEN
        begin
           G_FCCODE:=Params.ParamByName('TFCCODE').AsString;
           G_FCTYPE:=Params.ParamByName('TFCTYPE').AsString;
           result:='OK';
        end
        else
        begin
          Showmessage(Params.ParamByName('TRES').AsString);
          result:=Params.ParamByName('TRES').AsString;
        end;
      finally
        close;
      end;
    end;
end;

procedure TfDetail.edtMISCNOChange(Sender: TObject);
begin
   editorg.Clear ;
   sbtnconfirm.Enabled:=false;
end;

procedure TfDetail.sbtnmfgerClick(Sender: TObject);
begin
    if not QryDetail.Active then Exit;
    if QryDetail.IsEmpty then Exit;
    with Tfdata.Create(Self) do
    begin
       MaintainType:='MFGER';
       label1.Caption :='Part_no:'+qrydetail.fieldbyname('part_no').AsString;;
       if Showmodal = mrOK then
       begin
        //
       end;
       Free;
  end;
end;

procedure TfDetail.sbtnconfirmClick(Sender: TObject);
var strflag:string;
begin
    if MessageDlg('Not confirm The Source of '''+edtmiscno.Text+''',Are you sure ?',
        mtConfirmation, [mbYes, mbNo], 0) = mryes then
    begin
      exit;
    end;

    with qrytemp do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
      commandtext:='update sajet.g_erp_rc_mis_master SET status=''1''   '
                  +' where DOCUMENT_NUMBER=:DOCUMENT_NUMBER and status=''0'' ';
      Params.ParamByName('DOCUMENT_NUMBER').AsString :=edtmiscno.Text;
      Execute;

      //如果沒有發料則送1筆record_status='-1'的資料  
      with qrydetail do
      begin
         strflag:='0';
         first;
         while not eof do
         begin
            if  QryDetail.FieldByName('PRINT_QTY').AsInteger=0 then
              next
            else
            begin
              strflag:='1'  ;
              break;
            end;
         end;
      end;

      IF strflag='0' then
      begin
         with sproc do
         begin
           try
               Close;
               DataRequest('SAJET.MES_ERP_RC_MIS');
               FetchParams;
               Params.ParamByName('TDOCUMENT_NUMBER').AsString := QryDetail.FieldByName('DOCUMENT_NUMBER').AsString;
               Params.ParamByName('TISSUE_HEADER_ID').AsString := QryDetail.FieldByName('ISSUE_HEADER_ID').AsString;
               Params.ParamByName('TISSUE_LINE_ID').AsString := QryDetail.FieldByName('ISSUE_LINE_ID').AsString;
               Params.ParamByName('TISSUE_TYPE').AsString := QryDetail.FieldByName('ISSUE_TYPE').AsString;
               Params.ParamByName('TISSUE_TYPE_NAME').AsString := QryDetail.FieldByName('ISSUE_TYPE_NAME').AsString;
               Params.ParamByName('TSEQ_NUMBER').AsString := QryDetail.FieldByName('SEQ_NUMBER').AsString;
               Params.ParamByName('TINVENTORY_ITEM_ID').AsString :=QryDetail.FieldByName('OPTION7').AsString;
               Params.ParamByName('TSUBINV').AsString := QryDetail.FieldByName('WAREHOUSE_NAME').AsString;
               Params.ParamByName('TLOCATOR').AsString := QryDetail.FieldByName('LOCATE_NAME').AsString;
               Params.ParamByName('TMATERIAL_NO').AsString :='';
               Params.ParamByName('TQTY').AsInteger :=0;
               Params.ParamByName('TCREATE_USERID').AsString := UpdateUserID;
               Params.ParamByName('TISSUE_USER').AsString := '';
               Params.ParamByName('TORG_ID').AsString := QryDetail.FieldByName('FACTORY_CODE').AsString;
               Params.ParamByName('Ttype_class').AsString :='I' ;
               Params.ParamByName('TPUSH').AsString := 'N';
               Params.ParamByName('TTRXNTYPE').AsString := 'D3';
               Params.ParamByName('TRECORD_STATUS').AsString :='-1';
               Execute;
             finally
               close;
             end;
           end;
      end;

      close;
      params.Clear;
      Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
      Params.CreateParam(ftString, 'TO_ERP', ptInput);
      Params.CreateParam(ftString, 'CONFIRM_USERID', ptInput);
      commandtext:='UPDATE  SAJET.mes_to_erp_rc_mis '
                  +' SET TO_ERP = :TO_ERP, '
                  +' CONFIRM_TIME = SYSDATE, '
                  +' CONFIRM_USERID = :CONFIRM_USERID '
                  +' where document_number=:document_number AND confirm_time IS NULL  ';
      Params.ParamByName('DOCUMENT_NUMBER').AsString :=edtmiscno.Text;
      if chkPush.Checked then
          Params.ParamByName('TO_ERP').AsString := 'Y'
        else
          Params.ParamByName('TO_ERP').AsString := 'N';
      Params.ParamByName('CONFIRM_USERID').AsString :=UpdateUserID;
      Execute;
      close;
      sbtnconfirm.Enabled:=false;
      edtmaterial.Enabled :=false;
      Showmessage('Confirm OK!');
  end;

end;

procedure TfDetail.chkPushMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  fLogin := TfLogin.Create(Self);
  with fLogin do
  begin
    if ShowModal = mrOK then
    begin
      chkPush.Checked:=not(chkPush.Checked);
      MessageDlg('Push Title Change OK', mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfDetail.edtmaterialChange(Sender: TObject);
begin
 lablocate.Caption:='' ;
end;

end.

