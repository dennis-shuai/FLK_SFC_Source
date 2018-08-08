unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles, ComCtrls, RzButton, RzRadChk;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryMaterial: TClientDataSet;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    QryDetail: TClientDataSet;
    DataSource2: TDataSource;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    edtWipscNO: TEdit;
    sbtnMISC: TSpeedButton;
    EditORG: TEdit;
    Label13: TLabel;
    Image1: TImage;
    sbtnConfirm: TSpeedButton;
    chkPush: TRzCheckBox;
    GroupBox1: TGroupBox;
    DBGrid1: TDBGrid;
    GroupBox3: TGroupBox;
    DataSource1: TDataSource;
    DBGrid2: TDBGrid;
    GroupBox4: TGroupBox;
    QryWRReel: TClientDataSet;
    QryWRDetail: TClientDataSet;
    procedure FormShow(Sender: TObject);
    procedure edtWipscNOKeyPress(Sender: TObject; var Key: Char);
    procedure DataSource2DataChange(Sender: TObject; Field: TField);
    procedure sbtnMISCClick(Sender: TObject);
    procedure edtWipscNOChange(Sender: TObject);
    //procedure sbtnmfgerClick(Sender: TObject);
    procedure sbtnConfirmClick(Sender: TObject);
    procedure chkPushMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelField,gsLocateField, gsBoxField, gsReelField,
    gsWO,gsTypeClass,gsIssueType,gsStatus,
    gsOverField,
    G_FCID,G_FCCODE,G_FCTYPE:string;
    gbRTFlag: Boolean;
    procedure showData(sLocate: string);
    function SendMsg:boolean;
    function CheckWipMsterStatus: Boolean;
    Function Getfctype(sFCid:string):string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin, uCommData, Udata;

function TfDetail.CheckWipMsterStatus: Boolean;
begin
    Result := False;
    if  gsStatus='2' then //had confirm
    begin
       showmessage('The source had confirm!') ;
    end;
    if  gsStatus='1' then //had check
    begin
       Result := True;
    end;
    if  gsStatus='0' then //NOT check
    begin
        showmessage('The source Not check!') ;
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

procedure TfDetail.ShowData(sLocate: string);
var sSQL: string;  bPrinted: Boolean;
begin
  //show MES_TO_ERP_RC_WIP
  with QryMaterial do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
    CommandText := ' SELECT A.WIP_ENTITY_NAME,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.ISSUE_TYPE,A.ISSUE_TYPE_NAME,A.SEQ_NUMBER,A.INVENTORY_ITEM_ID, '
                  +' A.SUBINV,A.LOCATOR,A.MATERIAL_NO,A.QTY, A.CREATE_TIME,A.CREATE_USERID,A.ORG_ID, '
                  +' B.PART_NO,C.EMP_NO||''-''||C.EMP_NAME AS CREATE_USER,ISSUE_USER  '
                  +' FROM  SAJET.MES_TO_ERP_rc_wip A,SAJET.SYS_PART B,SAJET.SYS_EMP C '
                  +' WHERE  A.DOCUMENT_NUMBER=:DOCUMENT_NUMBER '
                  +'  AND A.INVENTORY_ITEM_ID = B.OPTION7 '
                  +'  AND A.CREATE_USERID = C.EMP_ID '
                   +'   ORDER BY B.PART_NO ASC,A.MATERIAL_NO ASC ';
                 // +'   ORDER BY A.SEQ_NUMBER,B.PART_NO,A.CREATE_TIME ';
    Params.ParamByName('DOCUMENT_NUMBER').AsString :=edtwipscno.Text;
    Open;
  end;


  //show G_ERP_RC_WIP_MASTER AND G_ERP_RC_WIP_DETAIL 
  sSQL := ' SELECT A.ROWID, A.RC_WIP_ID,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.SEQ_NUMBER,  '
          +' A.PART_ID,A.APPLY_QTY,A.PRINT_QTY,  '
          +' B.DOCUMENT_NUMBER,B.WIP_ENTITY_NAME,B.ISSUE_TYPE,B.ISSUE_TYPE_NAME,A.ORGANIZATION_ID,B.STATUS,B.TYPE_CLASS,  '
          +' C.PART_NO,C.OPTION7,C.OPTION1,    '
          +' E.FACTORY_CODE,E.FACTORY_NAME     '
          +' FROM SAJET.G_ERP_RC_WIP_DETAIL A,SAJET.G_ERP_RC_WIP_MASTER B,SAJET.SYS_PART C,SAJET.SYS_FACTORY E    '
          +' WHERE B.DOCUMENT_NUMBER=:DOCUMENT_NUMBER  '
          +' AND  A.RC_WIP_ID=B.RC_WIP_ID  '
          +' AND A.WIP_ENTITY_NAME = B.WIP_ENTITY_NAME '
          +' AND A.ORGANIZATION_ID=B.ORGANIZATION_ID  '
          +' AND A.PART_ID=C.PART_ID '
          +' AND B.ORGANIZATION_ID=E.FACTORY_ID  '
          +' AND A.ENABLED=''Y''  '
          +' AND B.ENABLED=''Y''  '
          +' ORDER BY C.PART_NO ASC  ';
          //+' ORDER BY A.SEQ_NUMBER  ';
  with QryDetail do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
    CommandText := sSQL;
    Params.ParamByName('DOCUMENT_NUMBER').AsString := edtwipscno.Text;
    Open;
    if IsEmpty then begin
      MessageDlg('WIP No: ' + edtwipscno.Text + ' not found.', mtError, [mbOK], 0);
      edtwipscno.SelectAll;
      edtwipscno.SetFocus;
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
    {
    while not Eof do begin
     if FieldByName('APPLY_QTY').AsInteger > FieldByName('PRINT_QTY').AsInteger then
      begin
        bPrinted := False;
        break;
      end;
      Next;
    end;
    }
    //保持原有rowid locate
    if sLocate <> '' then
     // Locate('RowId', sLocate, []);
      Locate('Part_NO', sLocate, []);

    if  FieldByName('status').AsInteger=2 then //had confirm
    begin
       sbtnConfirm.Enabled :=false;
       edtwipscno.Enabled :=true;
       showmessage('The source had confirm!') ;
       exit;
    end;
    if  FieldByName('status').AsInteger=1 then //had check
    begin
       sbtnConfirm.Enabled :=true;
       edtwipscno.Enabled :=false;
    end;
    if  FieldByName('status').AsInteger=0 then //NOT check or confirm
    begin
       sbtnConfirm.Enabled :=false;
       edtwipscno.Enabled :=true;
       showmessage('The source Not check!') ;
       exit;
    end;

    gsWO:=fieldbyname('WIP_ENTITY_NAME').AsString;
    gsTypeClass:=fieldbyname('TYPE_CLASS').AsString;
    gsIssueType:=fieldbyname('ISSUE_TYPE').AsString;
    gsStatus:=FieldByName('status').AsString;
  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
var PIni: TIniFile;
begin
  sbtnConfirm.Enabled:=false;
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
  edtwipscno.SetFocus;
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
    Params.ParamByName('dll_name').AsString := 'RCWIPCONFIRM.DLL';
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
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Over Request'' ';
    Open;
    gsOverField := FieldByName('param_name').AsString;
    close;
    if not IsEmpty then begin
      edtwipscno.CharCase := ecUpperCase;
    end;
  end;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Locate'' ';
    Open;
    gsLocateField := FieldByName('param_name').AsString;
    Close;
  end;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Label Type'' ';
    Open;
    gsLabelField := FieldByName('param_name').AsString;
    Close;
  end;
end;

procedure TfDetail.edtWipscNOKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
    ShowData('');
end;

procedure TfDetail.DataSource2DataChange(Sender: TObject; Field: TField);
var iTemp: Integer;
begin
{
  with QryMaterial do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
    CommandText := ' SELECT A.WIP_ENTITY_NAME,A.ISSUE_HEADER_ID,A.ISSUE_LINE_ID,A.ISSUE_TYPE,A.ISSUE_TYPE_NAME,A.SEQ_NUMBER,A.INVENTORY_ITEM_ID, '
                  +' A.SUBINV,A.LOCATOR,A.MATERIAL_NO,A.QTY, A.CREATE_TIME,A.CREATE_USERID,A.ORG_ID, '
                  +' B.PART_NO,C.EMP_NO||''-''||C.EMP_NAME AS CREATE_USER,ISSUE_USER  '
                  +' FROM  SAJET.MES_TO_ERP_rc_wip A,SAJET.SYS_PART B,SAJET.SYS_EMP C '
                  +' WHERE  A.DOCUMENT_NUMBER=:DOCUMENT_NUMBER '
                  +'  AND A.INVENTORY_ITEM_ID = B.OPTION7 '
                  +'  AND A.CREATE_USERID = C.EMP_ID '
                  +'   ORDER BY A.SEQ_NUMBER,B.PART_NO,A.CREATE_TIME ';
    Params.ParamByName('DOCUMENT_NUMBER').AsString :=QryDetail.FieldByName('DOCUMENT_NUMBER').AsString;
    Open;
  end;
  }
end;

{
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

  ShowData(QryDetail.FieldByName('RowId').AsString);
end;
}

procedure TfDetail.sbtnMISCClick(Sender: TObject);
var Key: Char;
begin
  with TfCommData.Create(Self) do
  begin
    LabType2.Caption := 'WIP No List';
    LabType1.Caption := LabType2.Caption;
    Label1.Caption := 'Search WIP No';
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
      CommandText := 'SELECT DOCUMENT_NUMBER,WIP_ENTITY_NAME AS WORK_ORDER,ISSUE_TYPE,ISSUE_TYPE_NAME,RECEIVE_TIME from SAJET.G_ERP_rc_wip_MASTER  '
        + 'Where DOCUMENT_NUMBER like :DOCUMENT_NUMBER and ENABLED = ''Y'' and status = 1 '
        + 'Order By DOCUMENT_NUMBER ';
      Params.ParamByName('DOCUMENT_NUMBER').AsString := edtwipscno.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      edtwipscno.Text := QryTemp.FieldByName('DOCUMENT_NUMBER').AsString;
      QryTemp.Close;
      Key := #13;
      edtwipscnoKeyPress(Self, Key);
      //edtwipscno.SetFocus;
      //edtwipscno.SelectAll;
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

procedure TfDetail.edtWipscNOChange(Sender: TObject);
begin
   editorg.Clear ;
   sbtnConfirm.Enabled:=false;
end;
{
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
}
procedure TfDetail.sbtnConfirmClick(Sender: TObject);
var strflag:string;
begin
    if MessageDlg('Not Confirm The Source of '''+edtwipscno.Text+''',Are you sure ?',
        mtConfirmation, [mbYes, mbNo], 0) = mryes then
    begin
      exit;
    end;

    //check Document Number status //0:正常 ; 1：had check ; 2: had confirm .
    if not CheckWipMsterStatus then exit;

    with qrytemp do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
      commandtext:='update sajet.g_erp_rc_wip_master SET status=''2''   '
                  +' where DOCUMENT_NUMBER=:DOCUMENT_NUMBER and status=''1'' ';
      Params.ParamByName('DOCUMENT_NUMBER').AsString :=edtwipscno.Text;
      Execute;


      close;
      params.Clear;
      Params.CreateParam(ftString, 'DOCUMENT_NUMBER', ptInput);
      Params.CreateParam(ftString, 'TO_ERP', ptInput);
      Params.CreateParam(ftString, 'CONFIRM_USERID', ptInput);
      commandtext:='UPDATE  SAJET.mes_to_erp_rc_wip '
                  +' SET '
                  +' TO_ERP = :TO_ERP, '
                  +' CONFIRM_TIME = SYSDATE, '
                  +' CONFIRM_USERID = :CONFIRM_USERID '
                  +' where document_number=:document_number AND CONFIRM_time IS NULL  ';
      Params.ParamByName('DOCUMENT_NUMBER').AsString :=edtwipscno.Text;

      if chkPush.Checked then
          Params.ParamByName('TO_ERP').AsString := 'Y'
      else
          Params.ParamByName('TO_ERP').AsString := 'N';
      
      Params.ParamByName('CONFIRM_USERID').AsString :=UpdateUserID;
      Execute;
      close;
      sbtnConfirm.Enabled:=false;
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


end.

