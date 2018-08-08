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
    DBGrid1: TDBGrid;
    Bevel2: TBevel;
    sbtntransfer: TSpeedButton;
    EditORG: TEdit;
    Label13: TLabel;
    chkPush: TRzCheckBox;
    edttransfer: TEdit;
    QryReel: TClientDataSet;
    Image1: TImage;
    Image2: TImage;
    sbtnconfirm: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure edttransferKeyPress(Sender: TObject; var Key: Char);
    procedure DataSource2DataChange(Sender: TObject; Field: TField);
    procedure sbtntransferClick(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sbtnconfirmClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelField, gsBoxField, gsReelField: string;
    G_FCID,G_FCCODE,G_FCTYPE:string;
    G_sType:string;
    g_tostockid,g_tolocateid:string;
    procedure showData(sLocate: string);
    Function GetFCTYPE(sFCID:string):string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin, uCommData, Udata;

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
       showmessage('The source had confirm!') ;
       sbtnconfirm.Enabled :=false;
       exit;
    end;
    if  FieldByName('status').AsInteger=0 then //NOT confirm
    begin
       sbtnconfirm.Enabled :=true;
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
    Params.ParamByName('dll_name').AsString := 'RCTRANSFERCONFIRMDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString;
    LabTitle2.Caption := LabTitle1.Caption;
   
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then begin
      edttransfer.CharCase := ecUpperCase;
    end;

    sbtnconfirm.Enabled :=false;
  end;
end;

procedure TfDetail.edttransferKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
     ShowData('');
     with qrytemp do
     begin
         close;
         params.Clear;
         Params.CreateParam(ftString, 'Source', ptInput);
         commandtext:=' select source '
                +' from sajet.g_transfer_detail '
                +' where (source=:Source) or (material_no=:source) or (reel_no=:source)  '
                +' order by update_time desc ';
         Params.ParamByName('Source').AsString := edttransfer.Text;
         open;
         if isempty then
         begin
            MessageDlg('Not find the source'+#13#13
            +'Or not find the material'+#13#13
            +'or not do transfer ', mtError, [mbOK], 0);
            exit;
         end;
        edttransfer.Text :=fieldbyname('source').AsString;
     end;

   // ShowData('');
  end;
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

procedure TfDetail.sbtnconfirmClick(Sender: TObject);
var i:integer;
var strmsg,strflag:string;
begin
  {if edttransfer.Enabled=false then
    begin
      if sbtnconfirm.Enabled =true then
         sbtnconfirm.Enabled :=false;
      exit;
    end;
    }
  if MessageDlg('Confirm Source: '+edttransfer.Text +' ?' ,
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
     Qrytemp.Close;
     Qrytemp.Params.Clear;
     Qrytemp.Params.CreateParam(ftstring,'DOCUMENT_NUMBER',ptInput);
     Qrytemp.CommandText:=' UPdate SAJET.G_ERP_RC_TRANSFER_MASTER '
                         +' set STATUS=1 '
                         +' where DOCUMENT_NUMBER=:DOCUMENT_NUMBER ';
     Qrytemp.Params.ParamByName('DOCUMENT_NUMBER').AsString := edtTransfer.Text;
     Qrytemp.Execute;

     //如果不做轉倉則送1筆record_status='-1'的資料
      with qrydetail do
      begin
         strflag:='0';
         first;
         while not eof do
         begin
            if  QryDetail.FieldByName('TRANSFER_QTY').AsInteger=0 then
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
     //insert into mes_to_erp_rc_transfer
      with sproc do
      begin
        try
          Close;
          DataRequest('SAJET.MES_ERP_RC_TRANSFER');
          FetchParams;
          Params.ParamByName('TDOCUMENT_NUMBER').AsString := QryDetail.FieldByName('DOCUMENT_NUMBER').AsString;
          Params.ParamByName('TISSUE_HEADER_ID').AsString :=QryDetail.FieldByName('ISSUE_HEADER_ID').AsString;
          Params.ParamByName('TISSUE_LINE_ID').AsString := QryDetail.FieldByName('ISSUE_LINE_ID').AsString;
          Params.ParamByName('TISSUE_TYPE').AsString :=QryDetail.FieldByName('ISSUE_TYPE').AsString;
          Params.ParamByName('TISSUE_TYPE_NAME').AsString :=QryDetail.FieldByName('ISSUE_TYPE_NAME').AsString ;
          Params.ParamByName('TTYPE_CLASS').AsString:='I';
          Params.ParamByName('TSEQ_NUMBER').AsString :=QryDetail.FieldByName('SEQ_NUMBER').AsString;
          Params.ParamByName('TINVENTORY_ITEM_ID').AsString :=QryDetail.FieldByName('OPTION7').AsString;
          Params.ParamByName('TFROM_SUBINV').AsString := QryDetail.FieldByName('FROM_SUBINV').AsString;
          Params.ParamByName('TFROM_LOCATOR').AsString := QryDetail.FieldByName('FROM_LOCATOR').AsString;
          Params.ParamByName('TTO_SUBINV').AsString := QryDetail.FieldByName('TO_SUBINV').AsString;
          Params.ParamByName('TTO_LOCATOR').AsString  := QryDetail.FieldByName('TO_LOCATOR').AsString;
          Params.ParamByName('TMATERIAL_NO').AsString := '';
          Params.ParamByName('TQTY').AsInteger  := 0;
          Params.ParamByName('TORG_ID').AsString := QryDetail.FieldByName('FACTORY_CODE').AsString;
          Params.ParamByName('TCREATE_USERID').AsString :=UpdateUserID;
          Params.ParamByName('TISSUE_USER').AsString :='';
          Params.ParamByName('TPUSH').AsString := 'N';
          Params.ParamByName('TTRXNTYPE').AsString := 'D4';
          Params.ParamByName('TRECORD_STATUS').AsString :='-1';
          Execute;

          strmsg:=PARAMS.PARAMBYNAME('TRES').AsString;
          if strmsg<>'OK' then
          begin
            MessageDlg('UPDATE SAJET.MES_ERP_RC_TRANSFER ERROR '+#13#13
                    + STRMSG , mtError, [mbOK], 0);
            Exit;
          end;
        finally
          close;
        end;
       end;
     end;


     qrytemp.close;
     Qrytemp.Params.Clear;
     Qrytemp.Params.CreateParam(ftString, 'source', ptInput);
     Qrytemp.CommandText:=' select nvl(reel_no,material_no) material_no,to_warehouse,to_locate,remark  from sajet.g_transfer_detail where source=:source ';
     Qrytemp.Params.ParamByName('source').AsString := trim(edttransfer.Text);
     Qrytemp.open;
     while not Qrytemp.eof do
     begin
       QryReel.Close;
       QryReel.Params.Clear;
       QryReel.Params.CreateParam(ftstring,'Material_no1',ptInput);
       QryReel.Params.CreateParam(ftstring,'Material_no2',ptInput);
       QryReel.Params.CreateParam(ftInteger, 'locate_id', ptInput);
       QryReel.Params.CreateParam(ftString, 'warehouse_id', ptInput);
       QryReel.Params.CreateParam(ftstring,'User',ptInput);
       QryReel.Params.CreateParam(ftstring,'Source',ptInput);
       QryReel.CommandText:=' UPdate sajet.g_material '
                           +' set type=''I'' '
                           +'    , warehouse_id=:warehouse_id '
                           +'    , Locate_id=:Locate_id '
                           +'    ,update_time=sysdate '
                           +'    ,update_userid=:userid '
                           +'    ,remark = :Source '
                           +' where (material_no=:Material_no1) or (Reel_no=:material_no2) ';
       QryReel.Params.ParamByName('material_no1').AsString := QryTemp.fieldbyname('Material_no').AsString;
       QryReel.Params.ParamByName('material_no2').AsString := QryTemp.fieldbyname('Material_no').AsString;
       QryReel.Params.ParamByName('warehouse_id').AsString := QryTemp.fieldbyname('to_warehouse').AsString;
       QryReel.Params.ParamByName('locate_id').AsString := QryTemp.fieldbyname('to_locate').AsString;
       QryReel.Params.ParamByName('Userid').AsString :=UpdateUserID ;
       QryReel.Params.ParamByName('Source').AsString :=QryTemp.fieldbyname('remark').AsString;
       //QryData.Params.ParamByName('Source').AsString :=trim(edtSource.Text) ;
       QryReel.execute;

       QryReel.Close;
       QryReel.Params.Clear;
       QryReel.Params.CreateParam(ftstring,'Material_no1',ptInput);
       QryReel.Params.CreateParam(ftstring,'Material_no2',ptInput);
       QryReel.CommandText:=' Insert into sajet.g_ht_material '
                           +' select * from sajet.g_material '
                           +' where (material_no=:Material_no1) or (Reel_no=:material_no2) ';
       QryReel.Params.ParamByName('material_no1').AsString := QryTemp.fieldbyname('Material_no').AsString;
       QryReel.Params.ParamByName('material_no2').AsString := QryTemp.fieldbyname('Material_no').AsString;
       QryReel.execute;
       Qrytemp.next;
     end;

     Qrytemp.Close;
     Qrytemp.Params.Clear;
     Qrytemp.Params.CreateParam(ftstring,'Source',ptInput);
     Qrytemp.CommandText:=' UPdate sajet.g_transfer_detail '
                         +' set type=''T'' '
                         +' where source=:source ';
     Qrytemp.Params.ParamByName('source').AsString := edtTransfer.Text;
     Qrytemp.Execute;

     Qrytemp.Close;
     Qrytemp.Params.Clear;
     Qrytemp.Params.CreateParam(ftstring,'DOCUMENT_NUMBER',ptInput);
     Qrytemp.Params.CreateParam(ftString, 'TO_ERP', ptInput);
     Qrytemp.Params.CreateParam(ftstring,'CONFIRM_USERID',ptInput);
     Qrytemp.CommandText:=' UPdate SAJET.MES_TO_ERP_RC_TRANSFER '
                         +' set CONFIRM_TIME=SYSDATE, '
                         +' TO_ERP = :TO_ERP, '
                         +' CONFIRM_USERID=:CONFIRM_USERID '
                         +' where DOCUMENT_NUMBER=:DOCUMENT_NUMBER AND CONFIRM_TIME IS NULL  ';
     Qrytemp.Params.ParamByName('DOCUMENT_NUMBER').AsString := edtTransfer.Text;
     if chkPush.Checked then
          Qrytemp.Params.ParamByName('TO_ERP').AsString := 'Y'
     else
          Qrytemp.Params.ParamByName('TO_ERP').AsString := 'N';
     Qrytemp.Params.ParamByName('CONFIRM_USERID').AsString := UpdateUserID ;
     Qrytemp.Execute;

     IF sbtnconfirm.Enabled =true then
        sbtnconfirm.Enabled :=false;
     MessageDlg('Transfer Confirm OK.', mtInformation, [mbOk], 0);
  end;

end;

end.

