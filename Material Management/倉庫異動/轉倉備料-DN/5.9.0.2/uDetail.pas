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
    Label4: TLabel;
    DBGrid1: TDBGrid;
    edtISSUEUSER: TEdit;
    Bevel2: TBevel;
    sbtntransfer: TSpeedButton;
    Label8: TLabel;
    edtmaterial: TEdit;
    EditORG: TEdit;
    Label13: TLabel;
    chkPush: TRzCheckBox;
    Label2: TLabel;
    Edtlocate: TEdit;
    Edtstock: TEdit;
    edttransfer: TEdit;
    QryReel: TClientDataSet;
    labmateriallocate: TLabel;
    Image1: TImage;
    Image2: TImage;
    sbtndelete: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure edttransferKeyPress(Sender: TObject; var Key: Char);
    procedure DataSource2DataChange(Sender: TObject; Field: TField);
    procedure sbtntransferClick(Sender: TObject);
    procedure edtmaterialKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnmfgerClick(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edttransferChange(Sender: TObject);
    procedure edtmaterialChange(Sender: TObject);
    procedure sbtndeleteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelField, gsBoxField, gsReelField: string;
    G_FCID,G_FCCODE,G_FCTYPE:string;
    G_sType:string;
    g_tostockid,g_tolocateid:string;
    procedure showData(sLocate: string);
    Function GetFIFOCode(dDate:TDateTime):string;
    Function GetFCTYPE(sFCID:string):string;
    function checkFIFO(MaterailNo:string;VAR NOCHECK:STRING):string;
    function SendMsg:boolean;
    function CheckMaterial: Boolean;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin, uCommData, Udata;

function TfDetail.CheckMaterial: Boolean;
var 
   sStr,sNoCheck,sorgcode:string;
   sPartid,sitemid,sPartNo,sfromlocateid,Sfromstock,sfromlocate,
   sissue_line_id,sRC_transfer_ID,Strmsg,
   sISSUE_HEADER_ID,sISSUE_TYPE,
   sISSUE_TYPE_NAME,sSEQ_NUMBER:string;
   IQTY:integer;
begin
  Result := False;
  g_sType := 'Material';
 
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


  with QryReel do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'material_no', ptInput);
    CommandText := 'select a.part_id, part_no, material_qty, datecode, '
      + ' c.locate_name,c.locate_id, d.warehouse_name, option7, a.version,nvl(reel_no,''N/A'') Reel_No,Fifocode, a.factory_id '
      + ' from sajet.g_material a, sajet.sys_part b, sajet.sys_locate c, sajet.sys_warehouse d '
      + ' where material_no = :material_no and a.part_id = b.part_id '
      + ' and a.locate_id = c.locate_id(+) and a.warehouse_id = d.warehouse_id(+) ';
    Params.ParamByName('material_no').AsString := edtMaterial.Text;
    Open;
    if IsEmpty then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'material_no', ptInput);
      CommandText := 'select a.part_id, part_no, reel_qty material_qty, datecode, '
        + ' c.locate_name,c.locate_id, d.warehouse_name, option7, a.version,Fifocode, a.factory_id '
        + ' from sajet.g_material a, sajet.sys_part b, sajet.sys_locate c, sajet.sys_warehouse d '
        + ' where reel_no = :material_no and a.part_id = b.part_id '
        + ' and a.locate_id = c.locate_id(+) and a.warehouse_id = d.warehouse_id(+) ';
      Params.ParamByName('material_no').AsString := edtMaterial.Text;
      Open;
      if IsEmpty then
      begin
        MessageDlg('ID No: ' + edtMaterial.Text + ' not found!', mtWarning, [mbOK], 0);
        Close;
        edtMaterial.SelectAll;
        edtMaterial.SetFocus;
        Exit;
      end
      else if fieldbyname('Warehouse_name').AsString='' then
      begin
        MessageDlg('ID No: ' + edtMaterial.Text + ' Not InStock.', mtWarning, [mbOK], 0);
        Exit;
      end
      else if fieldbyname('factory_id').AsString<>G_FCID then
      begin
        MessageDlg('ID No: ' + edtMaterial.Text + ' ORG IS NOT '+G_FCCODE, mtWarning, [mbOK], 0);
        Exit;
      end;
      g_sType := 'Reel';
    end
    else if fieldbyname('Reel_no').AsString<>'N/A' then
    begin
      MessageDlg('ID No: ' + edtMaterial.Text + ' have Reel.', mtWarning, [mbOK], 0);
      Exit;
    end
    else if fieldbyname('Warehouse_name').AsString='' then
    begin
      MessageDlg('ID No: ' + edtMaterial.Text + ' Not InStock.', mtWarning, [mbOK], 0);
      Exit;
    end
    else if fieldbyname('factory_id').AsString<>G_fcid then
    begin
      MessageDlg('ID No: ' + edtMaterial.Text + ' ORG IS NOT '+G_FCCODE, mtWarning, [mbOK], 0);
      Exit;
    end;
    // type is material 的material_no相關資料
    Iqty:= fieldbyname('material_qty').AsInteger;
    sPartid:=fieldbyname('part_id').AsString;
    sItemID :=FieldByName('option7').AsString;
    sPartNo:=fieldbyname('part_no').AsString;
    sfromlocateid:=fieldbyname('locate_id').AsString;
    sfromstock:=fieldbyname('warehouse_name').AsString;
    sfromlocate:=fieldbyname('locate_name').AsString;
    labmateriallocate.Caption :=sfromstock+'-'+sfromlocate;

    //check part_no,form locate ,to locate  是否正確 
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
    Params.CreateParam(ftString, 'Part_id', ptInput);
    Params.CreateParam(ftString, 'FROM_LOCATE_ID', ptInput);
    Params.CreateParam(ftString, 'TO_LOCATE_ID', ptInput);
    Params.CreateParam(ftString, 'IQTY', ptInput);
    CommandText := ' SELECT B.RC_TRANSFER_ID,B.ISSUE_HEADER_ID,B.ISSUE_TYPE, B.ISSUE_TYPE_NAME, '
                  +' A.SEQ_NUMBER,A.ISSUE_LINE_ID '
                  +' FROM SAJET.G_ERP_RC_TRANSFER_DETAIL A,SAJET.G_ERP_RC_TRANSFER_MASTER B   '
                  +' WHERE B.DOCUMENT_NUMBER=:DOCUMENT_NUMBER  '
                  +' AND A.PART_ID=:PART_ID '
                  +' AND A.FROM_LOCATE_ID=:FROM_LOCATE_ID  '
                  +' AND A.TO_LOCATE_ID=:TO_LOCATE_ID  '
                  +' AND A.RC_TRANSFER_ID=B.RC_TRANSFER_ID   '
                  +' AND A.ORGANIZATION_ID=B.ORGANIZATION_ID   '
                  +' AND APPLY_QTY - PRINT_QTY >=:IQTY '
                  +' AND A.ENABLED=''Y''  '
                  +' AND B.ENABLED=''Y''  ';
    Params.ParamByName('DOCUMENT_NUMBER').AsString := edttransfer.Text;
    Params.ParamByName('part_id').AsString := spartid;
    Params.ParamByName('FROM_LOCATE_ID').AsString :=sfromlocateid;
    Params.ParamByName('TO_LOCATE_ID').AsString :=G_tolocateid;
    Params.ParamByName('IQTY').AsInteger :=IQTY;
    Open;
    if IsEmpty then
    begin
       MessageDlg('Part: ' + sPartNo + ' - Error ' + #13#13
              +'Or Part: ' + sPartNo + ' - Over Request. ' + #13#13
              +'OR From Locate Error ' + #13#13
              +'OR To Locate Error', mtError, [mbOK], 0);
       Result := False;
       Exit;
    end;
    sISSUE_HEADER_ID:= fieldbyname('ISSUE_HEADER_ID').AsString;
    sissue_line_id:= fieldbyname('ISSUE_LINE_ID').AsString;
    sRC_transfer_ID:= fieldbyname('RC_TRANSFER_ID').AsString;
    sISSUE_TYPE:= fieldbyname('ISSUE_TYPE').AsString;
    sISSUE_TYPE_NAME:= fieldbyname('ISSUE_TYPE_NAME').AsString;
    sSEQ_NUMBER:=  fieldbyname('SEQ_NUMBER').AsString;
  end;

  WITH QryTemp do
    begin
       Close;
       Params.Clear;
       Params.CreateParam(ftInteger, 'FCID', ptInput);
       CommandText := ' select factory_code from sajet.sys_factory '
                     +' where factory_id=:FCID AND  enabled=''Y'' ';
       Params.ParamByName('FCID').AsString := G_FCID;
       open;
       If isempty then
       begin
          MessageDlg('Org: ' + G_FCCODE  + ' Not Find.', mtWarning, [mbOK], 0);
          Exit;
       end;
       sorgcode:=fieldbyname('factory_code').AsString;
       Close;
    end;


  //update material and insert to ht table
    with QryTEMP do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftString, 'userid', ptInput);
        commandtext:=' update sajet.g_material '
                    +'       set type=''O'' '
                    +'      ,update_userid=:userid '
                    +'      ,update_time=sysDate '
                    +' where (material_no=:material_no) or (Reel_no=:material_no) ';
      Params.ParamByName('material_no').AsString := edtmaterial.Text;
      Params.ParamByName('userid').AsString := UpdateUserID;
      Execute;

      close;
      Params.CreateParam(ftString, 'material_no', ptInput);
        commandtext:=' insert into sajet.g_ht_material '
                    +'  select * from sajet.g_material where (material_no=:material_no) or (reel_no=:material_no) ';
      Params.ParamByName('material_no').AsString := edtmaterial.Text;
      Execute;
      close;
    end;

    with Qrytemp do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'source', ptInput);
      Params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftString, 'to_locate', ptInput);
      Params.CreateParam(ftString, 'to_warehouse', ptInput);
      Params.CreateParam(ftString, 'FACTORY_ID', ptInput);
      commandtext:=' insert into sajet.g_transfer_detail '
                  +' select :source, RT_ID, PART_ID,DATECODE,MATERIAL_NO,MATERIAL_QTY,REEL_NO,REEL_QTY, STATUS,locate_id, Warehouse_id '
                  +'  ,:TO_LOCATE,:TO_WAREHOUSE,UPDATE_USERID,UPDATE_TIME,REMARK,RELEASE_QTY,VERSION,MFGER_NAME,MFGER_PART_NO,RT_SEQ,TYPE, FIFOCODE, :FACTORY_ID '
                  +' from sajet.g_material ';
      commandtext:=commandtext+ ' where (Material_no=:Material_no) or (reel_no=:Material_no)';
      Params.ParamByName('source').AsString := edttransfer.Text;
      Params.ParamByName('material_no').AsString :=edtmaterial.Text;
      Params.ParamByName('to_locate').AsString := g_tolocateid;
      Params.ParamByName('to_warehouse').AsString:=g_tostockid;
      Params.ParamByName('FACTORY_ID').AsString:= G_FCID;
      execute;
    end;

    WITH QryTemp do
    begin
       Close;
       Params.Clear;
       Params.CreateParam(ftInteger, 'QTY', ptInput);
       Params.CreateParam(ftString, 'RC_TRANSFER_ID', ptInput);
       Params.CreateParam(ftString, 'issue_line_id', ptInput);
       CommandText := 'update SAJET.G_ERP_RC_TRANSFER_DETAIL '
          + 'set PRINT_QTY = PRINT_QTY + :QTY '
          + 'where RC_TRANSFER_ID = :RC_TRANSFER_ID and issue_line_id = :issue_line_id AND rownum=1 ';
       Params.ParamByName('QTY').AsInteger := iQty;
       Params.ParamByName('RC_TRANSFER_ID').AsString := sRC_TRANSFER_ID;
       Params.ParamByName('issue_line_id').AsString := sissue_line_id;
       Execute;
       Close;
    end;
    //insert into mes_to_erp_rc_transfer
    with sproc do
      begin
      try
        Close;
        DataRequest('SAJET.MES_ERP_RC_TRANSFER');
        FetchParams;
        Params.ParamByName('TDOCUMENT_NUMBER').AsString := edttransfer.Text;
        Params.ParamByName('TISSUE_HEADER_ID').AsString :=sISSUE_HEADER_ID;
        Params.ParamByName('TISSUE_LINE_ID').AsString := sISSUE_LINE_ID;
        Params.ParamByName('TISSUE_TYPE').AsString :=sISSUE_TYPE;
        Params.ParamByName('TISSUE_TYPE_NAME').AsString :=sISSUE_TYPE_NAME ;
        Params.ParamByName('TTYPE_CLASS').AsString:='I';
        Params.ParamByName('TSEQ_NUMBER').AsString :=sSEQ_NUMBER;
        Params.ParamByName('TINVENTORY_ITEM_ID').AsString :=sItemID;
        Params.ParamByName('TFROM_SUBINV').AsString := sfromstock;
        Params.ParamByName('TFROM_LOCATOR').AsString := sfromlocate;
        Params.ParamByName('TTO_SUBINV').AsString := edtstock.Text;
        Params.ParamByName('TTO_LOCATOR').AsString  := edtlocate.Text;
        Params.ParamByName('TMATERIAL_NO').AsString := edtMaterial.Text;
        Params.ParamByName('TQTY').AsInteger  := iQty;
        Params.ParamByName('TORG_ID').AsString := sorgcode;
        Params.ParamByName('TCREATE_USERID').AsString :=UpdateUserID;
        Params.ParamByName('TISSUE_USER').AsString := edtissueuser.Text;
        Params.ParamByName('TPUSH').AsString := 'N';
        Params.ParamByName('TTRXNTYPE').AsString := 'D4';
        Params.ParamByName('TRECORD_STATUS').AsString :='';
        Execute;

        strmsg:=PARAMS.PARAMBYNAME('TRES').AsString;
        if strmsg<>'OK' then
        begin
          MessageDlg('UPDATE SAJET.MES_ERP_RC_TRANSFER ERROR '+#13#13
                  + STRMSG , mtError, [mbOK], 0);
          Result := False;
          Exit;
        end;
      finally
        close;
      end;
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
  sSQL := ' SELECT A.ROWID, A.RC_TRANSFER_ID,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.SEQ_NUMBER,A.PART_ID,  '
         +' A.FROM_LOCATE_ID,A.TO_LOCATE_ID,A.APPLY_QTY,A.PRINT_QTY AS TRANSFER_QTY,A.ORGANIZATION_ID,   '
         +' B.DOCUMENT_NUMBER,B.ISSUE_TYPE,B.ISSUE_TYPE_NAME,A.ORGANIZATION_ID,B.STATUS,  '
         +' C.PART_NO,C.OPTION7,C.OPTION1,  '
         +' D.WAREHOUSE_NAME AS FROM_SUBINV,D.WAREHOUSE_ID AS FROM_WAREHOUSE_ID,E.LOCATE_NAME AS FROM_LOCATOR ,  '
         +' F.FACTORY_CODE,F.FACTORY_NAME ,   '
         +' G.WAREHOUSE_NAME AS TO_SUBINV,G.WAREHOUSE_ID AS TO_WAREHOUSE_ID,H.LOCATE_NAME AS TO_LOCATOR  '
         +' FROM SAJET.G_ERP_RC_TRANSFER_DETAIL A,SAJET.G_ERP_RC_TRANSFER_MASTER B,SAJET.SYS_PART C,  '
         +' SAJET.SYS_WAREHOUSE D,SAJET.SYS_LOCATE E,SAJET.SYS_FACTORY F,  '
         +' SAJET.SYS_WAREHOUSE G,SAJET.SYS_LOCATE H  '
         +' WHERE B.DOCUMENT_NUMBER=:DOCUMENT_NUMBER '
         +' AND  A.RC_TRANSFER_ID=B.RC_TRANSFER_ID  '
         +' AND A.ORGANIZATION_ID=B.ORGANIZATION_ID  '
         +' AND A.PART_ID=C.PART_ID   '
         +' AND E.LOCATE_ID=A.FROM_LOCATE_ID  '
         +' AND E.WAREHOUSE_ID=D.WAREHOUSE_ID  '
         +' AND B.ORGANIZATION_ID=F.FACTORY_ID '
         +' AND H.LOCATE_ID=A.TO_LOCATE_ID   '
         +' AND G.WAREHOUSE_ID=H.WAREHOUSE_ID '
         +' AND A.ENABLED=''Y''  '
         +' AND B.ENABLED=''Y''  '
         +' AND D.ENABLED=''Y''  '
         +' AND E.ENABLED=''Y''   '
         +' AND G.ENABLED=''Y''   '
         +' AND H.ENABLED=''Y''   '
         +' Order By A.SEQ_NUMBER ';
  with QryDetail do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
    CommandText := sSQL;
    Params.ParamByName('DOCUMENT_NUMBER').AsString := edttransfer.Text;
    Open;
    if IsEmpty then begin
      MessageDlg('Transfer No: ' + edttransfer.Text + ' not found.', mtError, [mbOK], 0);
      edttransfer.SelectAll;
      edttransfer.SetFocus;
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
     if FieldByName('APPLY_QTY').AsInteger > FieldByName('Transfer_QTY').AsInteger then
      begin
        bPrinted := False;
        break;
      end;
      Next;
    end;
    
    if sLocate <> '' then
      Locate('RowId', sLocate, []);

    if  FieldByName('status').AsInteger=1 then //had confirm
    begin
       edtmaterial.Enabled :=false;
       sbtndelete.Enabled :=false;
       showmessage('The source had confirm!') ;
       exit;
    end;
    if  FieldByName('status').AsInteger=0 then //NOT confirm
    begin
       edtmaterial.Enabled :=true;
       sbtndelete.Enabled :=true;
    end;
  end;
  If edttransfer.Enabled = true then
     edttransfer.Enabled :=false;
end;

procedure TfDetail.FormShow(Sender: TObject);
var PIni: TIniFile;
begin
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
  edttransfer.SetFocus;
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
    Params.ParamByName('dll_name').AsString := 'RCTRANSFERPREPAREDLL.DLL';
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
      edttransfer.CharCase := ecUpperCase;
      edtissueuser.CharCase :=ecuppercase;
      edtstock.CharCase :=ecuppercase;
      edtlocate.CharCase :=ecuppercase;
      edtmaterial.CharCase :=ecuppercase;
    end;
  end;
end;

procedure TfDetail.edttransferKeyPress(Sender: TObject; var Key: Char);
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
    CommandText := ' select A.DOCUMENT_NUMBER,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.ISSUE_TYPE, '
                  +' A.ISSUE_TYPE_NAME,A.SEQ_NUMBER,A.FROM_SUBINV,   '
                  +' A.FROM_LOCATOR,A.TO_SUBINV,A.TO_LOCATOR,    '
                  +' A.MATERIAL_NO,A.QTY,A.CREATE_TIME,A.CREATE_USERID,   '
                  +' A.ISSUE_USER,A.ORG_ID,    '
                  +' B.PART_NO,C.EMP_NO||''-''||C.EMP_NAME AS CREATE_USER  '
                  +' from SAJET.mes_to_erp_rc_transfer A,SAJET.SYS_PART B,SAJET.SYS_EMP C '
                  +' WHERE A.DOCUMENT_NUMBER=:DOCUMENT_NUMBER  '
                  +' AND A.INVENTORY_ITEM_ID=B.OPTION7   '
                  +' AND A.CREATE_USERID = C.EMP_ID  '
                  +' ORDER BY A.SEQ_NUMBER,B.PART_NO,A.CREATE_TIME  ';
    Params.ParamByName('DOCUMENT_NUMBER').AsString :=QryDetail.FieldByName('DOCUMENT_NUMBER').AsString;
    Open;
  end;
end;

procedure TfDetail.sbtntransferClick(Sender: TObject);
var Key: Char;
begin
  with TfCommData.Create(Self) do
  begin
    LabType2.Caption := 'Transfer No List';
    LabType1.Caption := LabType2.Caption;
    Label1.Caption := 'Search Transfer No';
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
      CommandText := 'SELECT DOCUMENT_NUMBER,ISSUE_TYPE,ISSUE_TYPE_NAME,RECEIVE_TIME from SAJET.G_ERP_RC_Transfer_MASTER  '
        + 'Where DOCUMENT_NUMBER like :DOCUMENT_NUMBER and ENABLED = ''Y'' and status = 0  '
        + 'Order By DOCUMENT_NUMBER ';
      Params.ParamByName('DOCUMENT_NUMBER').AsString := edttransfer.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      edttransfer.Text := QryTemp.FieldByName('DOCUMENT_NUMBER').AsString;
      QryTemp.Close;
      Key := #13;
      edttransferKeyPress(Self, Key);
    end;
    free;
  end;
end;


procedure TfDetail.edtmaterialKeyPress(Sender: TObject; var Key: Char);
BEGIN
 if Ord(Key) = vk_Return then
  begin
    edtstock.Text :=trim(edtstock.Text);
    edtlocate.Text :=trim(edtlocate.Text);
    if edtstock.Text='' then
    begin
       MessageDlg('Please Input Stock!', mtError, [mbOK], 0);
       exit;
    end;
    // check locate and get to locate_id
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'stock', ptInput);
      Params.CreateParam(ftString, 'locate', ptInput);
      CommandText := ' select a.warehouse_id,b.locate_id  '
                    +' from sajet.sys_warehouse a,sajet.sys_locate b '
                    +' where  a.warehouse_name=:stock '
                    +' and nvl(b.locate_name,''N/A'' )=:locate  '
                    +' and a.warehouse_id=b.WAREHOUSE_ID  '
                    +' and a.enabled=''Y''  '
                    +' AND B.enabled=''Y''  ';
      Params.ParamByName('stock').AsString :=edtstock.Text;
      if  edtlocate.Text='' then
          Params.ParamByName('locate').AsString :='N/A'
      else
          Params.ParamByName('locate').AsString :=edtlocate.Text;
      Open;
      g_tostockid:= FieldByName('warehouse_id').AsString ;
      g_tolocateid:=FieldByName('locate_id').AsString ;
      if isempty then
      begin
           MessageDlg('Locate not find!', mtError, [mbOK], 0);
           edtstock.SelectAll ;
           edtstock.SetFocus ;
           exit;
      end;
    end;

    CheckMaterial;
    ShowData('');
    edtMaterial.SelectAll;
    edtMaterial.SetFocus;
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

procedure TfDetail.edttransferChange(Sender: TObject);
begin
   editorg.Clear ;
end;

procedure TfDetail.edtmaterialChange(Sender: TObject);
begin
  labmateriallocate.Caption :='';
end;

procedure TfDetail.sbtndeleteClick(Sender: TObject);
var iqty: Integer;
var sResult:string;
var smaterial,sDOCUMENT_NUMBER,SRc_transfer_id,sISSUE_LINE_ID:string;
begin
  if MessageDlg('Delete Material: '+Qrymaterial.fieldbyname('material_no').AsString ,
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
     smaterial:=Qrymaterial.fieldbyname('material_no').AsString;
     iqty:=Qrymaterial.fieldbyname('qty').AsInteger;
     sDOCUMENT_NUMBER:=Qrymaterial.fieldbyname('DOCUMENT_NUMBER').AsString;
     sISSUE_LINE_ID:=Qrymaterial.fieldbyname('ISSUE_LINE_ID').AsString;
     qrytemp.close;
     Qrytemp.Params.Clear;
     Qrytemp.Params.CreateParam(ftString, 'source', ptInput);
     Qrytemp.CommandText:=' select nvl(reel_no,material_no) material_no from sajet.g_transfer_detail where source=:source ';
     Qrytemp.Params.ParamByName('source').AsString := edttransfer.Text;
     Qrytemp.open;
     IF NOT QRYTEMP.ISEMPTY THEN
     begin
       //get rc_transfer_id
       Qrytemp.Close;
       Qrytemp.Params.Clear;
       Qrytemp.Params.CreateParam(ftstring,'DOCUMENT_NUMBER',ptInput);
       Qrytemp.CommandText:=' select rc_transfer_id from sajet.g_erp_rc_transfer_master  '
                           +' where DOCUMENT_NUMBER=:DOCUMENT_NUMBER  ';
       Qrytemp.Params.ParamByName('DOCUMENT_NUMBER').AsString :=sDOCUMENT_NUMBER ;
       Qrytemp.Open ;
       IF Qrytemp.isempty then
       begin
          MessageDlg('Not find The DOCUMENT_NUMBER In '+#13#13
          + ' G_erp_rc_transfer_master Table', mtError, [mbOK], 0);
          exit;
       end;
       src_transfer_id:=Qrytemp.fieldbyname('rc_transfer_id').AsString;
       Qrytemp.close;

       // delete mes_to_erp_rc_transfer
       Qrytemp.Close;
       Qrytemp.Params.Clear;
       Qrytemp.Params.CreateParam(ftstring,'Material_no',ptInput);
       Qrytemp.Params.CreateParam(ftstring,'DOCUMENT_NUMBER',ptInput);
       Qrytemp.CommandText:=' Delete sajet.mes_to_erp_rc_transfer  '
                           +' where DOCUMENT_NUMBER=:DOCUMENT_NUMBER and material_no=:Material_no ';
       Qrytemp.Params.ParamByName('material_no').AsString :=smaterial;
       Qrytemp.Params.ParamByName('DOCUMENT_NUMBER').AsString :=sDOCUMENT_NUMBER ;
       Qrytemp.execute;

       // update g_erp_rc_transfer_detail
       Qrytemp.Close;
       Qrytemp.Params.Clear;
       Qrytemp.Params.CreateParam(ftstring,'rc_transfer_id',ptInput);
       Qrytemp.Params.CreateParam(ftstring,'ISSUE_LINE_ID',ptInput);
       Qrytemp.Params.CreateParam(ftstring,'iqty',ptInput);
       Qrytemp.CommandText:='update sajet.g_erp_rc_transfer_detail '
                     +' set print_qty =print_qty - :iqty  '
                     +' where rc_transfer_id=:rc_transfer_id  '
                     +' and ISSUE_LINE_ID=:ISSUE_LINE_ID  '
                     +' and rownum=1 ';
       Qrytemp.Params.ParamByName('rc_transfer_id').AsString :=src_transfer_id;
       Qrytemp.Params.ParamByName('ISSUE_LINE_ID').AsString :=sISSUE_LINE_ID ;
       Qrytemp.Params.ParamByName('iqty').AsInteger :=iqty ;
       Qrytemp.execute;

       //upate g_material
       Qrytemp.Close;
       Qrytemp.Params.Clear;
       Qrytemp.Params.CreateParam(ftstring,'Material_no',ptInput);
       Qrytemp.Params.CreateParam(ftstring,'User',ptInput);
       Qrytemp.CommandText:=' UPdate sajet.g_material '
                           +' set type=''I'' '
                           +'    ,update_time=sysdate '
                           +'    ,update_userid=:userid '
                           +' where (material_no=:Material_no) or (Reel_no=:material_no) ';
       Qrytemp.Params.ParamByName('material_no').AsString :=smaterial;
       Qrytemp.Params.ParamByName('Userid').AsString :=UpdateUserID ;
       Qrytemp.execute;

       //insert into g_ht_material
       Qrytemp.Close;
       Qrytemp.Params.Clear;
       Qrytemp.Params.CreateParam(ftstring,'Material_no',ptInput);
       Qrytemp.CommandText:=' Insert into sajet.g_ht_material '
                           +' select * from sajet.g_material '
                           +' where (material_no=:Material_no) or (Reel_no=:material_no) ';
       Qrytemp.Params.ParamByName('material_no').AsString :=smaterial;
       Qrytemp.execute;

       //delete g_transfer_detail
       Qrytemp.Close;
       Qrytemp.Params.Clear;
       Qrytemp.Params.CreateParam(ftstring,'Source',ptInput);
       Qrytemp.Params.CreateParam(ftstring,'Material_no',ptInput);
       Qrytemp.CommandText:=' Delete sajet.g_transfer_detail where source=:source '
                        +' AND  (material_no=:Material_no) or (Reel_no=:material_no) ';
       Qrytemp.Params.ParamByName('source').AsString := edttransfer.Text;
       Qrytemp.Params.ParamByName('material_no').AsString :=smaterial;
       Qrytemp.Execute;


       MessageDlg('Delete '+smaterial+' OK', mtInformation,[mbOk], 0);
       ShowData('');
    end
    ELSE
      BEGIN
         MessageDlg('NOT Record To Be Deleted !', mtError, [mbOK], 0);
      END;
  end;

end;

end.

