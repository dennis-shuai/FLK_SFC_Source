unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Menus, StdCtrls, MConnect, ObjBrkr, Db, DBClient, FileCtrl,
  SConnect, ExtCtrls, Grids, DBGrids, PBJustOne, IniFiles, Buttons, ImgList, DBTables,
  CoolTrayIcon, ADODB;
type
  TTransfer = class(TForm)
    Label9: TLabel;
    ListBox1: TListBox;
    editTemp: TEdit;
    editLog: TEdit;
    Menu1: TMainMenu;
    Option1: TMenuItem;
    Exit1: TMenuItem;
    StatusBar: TStatusBar;
    Stop1: TMenuItem;
    Timer1: TTimer;
    N2: TMenuItem;
    PBJustOne1: TPBJustOne;
    sbtnTemp: TSpeedButton;
    sbtnLog: TSpeedButton;
    Label1: TLabel;
    LabCnt: TLabel;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    Label2: TLabel;
    sbtnExcept: TSpeedButton;
    editExcept: TEdit;
    sbtnTimer: TSpeedButton;
    editTimer: TEdit;
    Label3: TLabel;
    Button1: TButton;
    CoolTrayIcon1: TCoolTrayIcon;
    PopupMenu2: TPopupMenu;
    Show1: TMenuItem;
    MenuItem2: TMenuItem;
    AdoCon1: TADOConnection;
    adoQrySelect: TADOQuery;
    adoQryInst: TADOQuery;
    adoQryProc: TADOStoredProc;
    adoQryLog: TADOQuery;
    adoQryUpdate: TADOQuery;
    adoQryTemp: TADOQuery;
    procedure Stop1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure sbtnTimerClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Show1Click(Sender: TObject);
    procedure CoolTrayIcon1DblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    sDot,sSID,sIP,sPort,sUserName,sPwd : String;
    TimeSectionR : Integer;
    procedure ReadINI;
    procedure WriteINI;
    procedure LogException(psTable, psRowID, psMessage : String);
    procedure LogComplete(psTable, psRowID : String);
    procedure RemoveData(psTable, psHTTable : String);
    procedure TransferData;
    procedure TransPartNo;
    procedure TransBOMHeader;
    procedure TransBOMDetail;
    procedure TransWOHeader;
    procedure TransWODetail;
    procedure TransRTHeader;
    procedure TransRTDetail;
    procedure TransDNHeader;
    procedure TransDNDetail;
    procedure TransRcMisHeader;
    procedure TransRcMisDetail;
    procedure TransRcTransferHeader;
    procedure TransRcTransferDetail;
    procedure TransRcWipHeader;
    procedure TransRcWipDetail;
    function  GetMaxPartID : String;
    function  GetMaxBOMID : String;
    function  GetMaxRTID : String;
    function  GetMaxDNID : String;
    function  GetMaxVendorID : String;
    function  GetMaxCustID : String;
    function  GetMaxRcMisID : String;
    function  GetMaxRcTransferID : String;
    function  GetMaxRcWipID : String;
    function  GetSetQty(PartNO:string) :integer;
    function  UpdateErp(psTable,psSID:string):string;
    function  GetRouteID(psRouteName : String) : String;
    function  GetLocateID(psWarehouse, psLocate : String) : String;
    function  CheckPNExist(psPartNo : String; var psPartID : String) : Boolean;
    function  CheckWOExist(psWONo : String; var psWOStatus : String) : Boolean;
    function  CheckWOItemExist(psWONo, psPartID : String) : Boolean;
    function  CheckBOMExist(psPartID, psPartVer : String; var psBOMID : String) : Boolean;
    function  CheckBOMPNExist(psBOMID, psItemID : String) : Boolean;
    function  CheckRTExist(psRTNo : String; var psRTID : String) : Boolean;
    function  CheckRTDetailExist(psRTID, psSeq : String) : Boolean;
    function  CheckDNExist(psDNNo : String; var psDNID : String) : Boolean;
    function  CheckDNDetailExist(psDNID, psDNItem : String) : Boolean;
    function  CheckVendorExist(psVendor : String; var psVendorId : String) : Boolean;
    function  CheckCustomerExist(psCustomer : String; var psCustomerId : String) : Boolean;
    function  CheckRcMisMasterExist(psRcMisDN : String; var psRCMISID : String) : Boolean;
    function  CheckRcMisDetailExist(psRCMISID, psISSUELINEID : String) : Boolean;
    function  CheckRcTransferMasterExist(psRcTransferDN : String; var psRCTransferID : String) : Boolean;
    function  CheckRcTransferDetailExist(psRCTransferID, psISSUELINEID : String) : Boolean;
    function  CheckRcWipMasterExist(psRcWipDN : String; var psRCWipID : String) : Boolean;
    function  CheckRcWipDetailExist(psRCWipID, psISSUELINEID : String) : Boolean;
    function  ConnectDb:Boolean;
  end;

var
  Transfer: TTransfer;

implementation

uses Unit2;

{$R *.DFM}
function  TTransfer.GetSetQty(PartNO:string) :integer;
var sField:string;
    sSql:string;
begin
   with Adoqrytemp do
   begin
     close;
     sql.Clear;
     Parameters.Clear;
     sql.Add(' select Param_value from sajet.sys_base where param_name=''Set Qty Field'' ');
     open;
     first;
     if recordcount>0 then
     begin
       sField:=fieldbyname('Param_value').AsString;
     end
     else begin
       result:=1;
       exit;
     end;

     close;
     sql.Clear;
     Parameters.Clear;
     //sSql:= ' select '+sField+' from sajet.sys_part where part_no= '''+partNO+'''';
     Parameters.CreateParameter('partNO',ftString,pdInput,30,fgUnassigned);
     sSql:= ' select '+sField+' from sajet.sys_part where part_no= :partNO ';
     Parameters.ParamByName('partNO').value := partNO;
     sql.Add(sSql);
     open;
     first;
     if strtointdef(fieldbyname(sField).AsString,1)>1 then
       result:=strtoint(fieldbyname(sField).AsString)
     else
       result:=1;
   end;
end;

procedure TTransfer.ReadINI;
var
  vIniFile : TIniFile;
begin
  vInifile := Tinifile.Create(ExtractFilePath(ParamStr(0))+'MES_Info.CFG');
  TimeSectionR := vIniFile.ReadInteger('MESINT', 'READ TIME SECTION', 30);
  sUserName  :=  vIniFile.ReadString('Database Info', 'User_Name', '');
  sPwd  :=  vIniFile.ReadString('Database Info', 'Password', '');
  sSID :=  vIniFile.ReadString('Database Info', 'SID', '');
  sIP :=  vIniFile.ReadString('Database Info', 'IP', '');
  sPort :=  vIniFile.ReadString('Database Info', 'Port', '');
  editTimer.Text := IntToStr(TimeSectionR);
  vInifile.Free;
end;

procedure TTransfer.WriteINI;
var
  vIniFile : TIniFile;
begin
  vInifile := Tinifile.Create(ExtractFilePath(ParamStr(0))+'MES_Info.CFG');
  vIniFile.WriteInteger('MESINT', 'READ TIME SECTION', TimeSectionR);
  vInifile.Free;
end;

procedure TTransfer.FormCreate(Sender: TObject);
begin
  sDot := '!';
  ReadINI;
  Timer1.Interval := TimeSectionR * 1000 * 60;
  Timer1.Enabled := True;
end;

procedure TTransfer.Stop1Click(Sender: TObject);
begin
  If Timer1.Enabled Then
  begin
    Stop1.Caption := 'Start';
    Timer1.Enabled := False;
  end else
  begin
    Stop1.Caption := 'Stop';
    Timer1.Enabled := True;
  end;
end;

procedure TTransfer.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TTransfer.sbtnTimerClick(Sender: TObject);
begin
  Timer1.Enabled := False;
  Form2.seditTime.Value := TimeSectionR;
  Form2.ShowModal;
  if Form2.ModalResult = mrOK then
  begin
    TimeSectionR := Form2.seditTime.Value;
    editTimer.Text := IntToStr(TimeSectionR);
    WriteINI;
  end;
  Timer1.Interval := TimeSectionR * 1000 * 60;
  Timer1.Enabled := True;
end;

procedure TTransfer.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  CoolTrayIcon1.HideMainForm;
  Application.ProcessMessages;
  ConnectDb ;

  StatusBar.SimpleText := 'Transfer Data !!';
  TransferData;

  AdoCon1.Connected := False;

  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    SetProcessWorkingSetSize(GetCurrentProcess, $FFFFFFFF, $FFFFFFFF) ;
    Sleep(100) ;
  end;

  Timer1.Enabled := True;
  Label2.Caption := DateTimetoStr(now);
end;

procedure TTransfer.LogException(psTable, psRowID, psMessage : String);
begin
  with adoQryLog do
  begin
    Close;
    SQL.Clear;
    //SQL.Add('UPDATE ' + psTable + ' SET EXCEPTION_MSG = ''' + psMessage + ''' ' +
    //        'WHERE ROWID = ''' + psRowID + '''');
    //Parameters.CreateParameter('psMessage',ftstring,pdInput,80,fgUnassigned);
    //Parameters.CreateParameter('psRowID',ftstring,pdinput,length(psRowID),fgUnassigned);
    SQL.Add('UPDATE ' + psTable + ' SET EXCEPTION_MSG = :psMessage ' +
            ' WHERE ROWID = :psRowID ');
    Parameters.ParamByName('psMessage').Value := psMessage;
    Parameters.ParamByName('psRowID').Value := psRowID;
    ExecSQL;
  end;
end;

procedure TTransfer.LogComplete(psTable, psRowID : String);
begin
  with adoQryLog do
  begin
    Close;
    SQL.Clear;
    //SQL.Add('UPDATE ' + psTable + ' SET TRANSFER_FLAG = ''Y'', TRANSFER_TIME = SYSDATE, ' +
    //        'EXCEPTION_MSG = '''' WHERE ROWID = ''' + psRowID + '''');
    //Parameters.CreateParameter('psRowID',ftstring,pdinput,20,fgUnassigned);
    SQL.Add('UPDATE ' + psTable + ' SET TRANSFER_FLAG = ''Y'', TRANSFER_TIME = SYSDATE, ' +
            'EXCEPTION_MSG = '''' WHERE ROWID = :psRowID ');
    Parameters.ParamByName('psRowID').Value := psRowID;
    ExecSQL;
  end;
end;

FUNCTION TTransfer.UpdateErp(psTable,psSID:string):string;
begin
  //result:=false;
  with adoQryProc do
  begin
    close;
    Parameters.Refresh;
    Parameters.ParamByName('TSID').Value :=  psSID;
    Parameters.ParamByName('TTABLE').Value :=  psTable;
    Prepared :=True;
    execproc;
    result:= Parameters.parambyname('TRES').Value;
    {if parambyname('TRES').AsString='OK' then
      result:=true
    else showmessage(parambyname('TRES').AsString);  }
  end;
end;

procedure TTransfer.RemoveData(psTable, psHTTable : String);
begin
  AdoCon1.BeginTrans;
  try
    with adoQryLog do
    begin
      Close;
      SQL.Clear;
      SQL.Add('INSERT INTO ' + psHTTable + ' ' +
              '(SELECT * FROM ' + psTable + ' WHERE TRANSFER_FLAG = ''Y'')');
      ExecSQL;

      Close;
      SQL.Clear;
      SQL.Add('DELETE FROM ' + psTable + ' WHERE TRANSFER_FLAG = ''Y''');
      ExecSQL;
    end;
    AdoCon1.CommitTrans;
  except
    AdoCon1.RollbackTrans;
  end;
end;

procedure TTransfer.TransferData;
begin
  ListBox1.Items.Clear;
  ListBox1.Items.Add('Start tranfer data'+FormatDateTime('HH:MM:SS',Now)) ;
  LabCnt.Caption := '0';
  Application.ProcessMessages;
  TransPartNo;
  TransBOMHeader;
  TransBOMDetail;
  TransWOHeader;
  TransWODetail;
  TransRTHeader;
  TransRTDetail;
  TransDNHeader;
  TransDNDetail;
  TransRcMisHeader;
  TransRcMisDetail;
  TransRcTransferHeader;
  TransRcTransferDetail;
  TransRcWipHeader;
  TransRcWipDetail;
end;

procedure TTransfer.TransPartNo;
var
  mI : Integer;
  sPartNo,        //料號
  sDesc,          //品名規格
  sCategory,      //種類
  sVersion,       //版本
  sVersionFlag,   //版本控管
  sWarehouse,     //預設倉位
  sLocate,        //預設儲位
  sUOM,           //單位
  sERPItemID,     //ERP ITEM ID
  sPartId, sLocateID,sSeqID : String;
  sResult:string;
begin
  sSeqID:='';
  Application.ProcessMessages;
  with adoQrySelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT T.*, T.ROWID||'''' iRow FROM SAJET.INTERFACE_PART_MASTER T '+
            ' WHERE T.TRANSFER_FLAG = ''N'' ORDER BY CREATE_TIME ');
    Open;
    First;
    mI := 0;
    while not Eof do
    begin
      sPartNo      := FieldByName('PART_NO').AsString;
      sDesc        := FieldByName('PART_SPEC').AsString;
      sCategory    := FieldByName('CATEGORY').AsString;
      sVersion     := FieldByName('VERSION').AsString;
      sVersionFlag := FieldByName('VERSION_FLAG').AsString;
      sWarehouse   := FieldByName('SUB_WH').AsString;
      sLocate      := FieldByName('SUB_LOCATE').AsString;
      sUOM         := FieldByName('UOM').AsString;
      sERPItemID   := FieldByName('ITEM_ID').AsString;
      sSeqID       := Fieldbyname('seq_id').AsString;

      if Trim(sVersion) = '' then sVersion := 'N/A';
      if Trim(sVersionFlag) = '' then sVersion := 'N';

      try
        sLocateID := GetLocateID(sWarehouse, sLocate);
      except
        sLocateID := '0';
      end;

      try
        if CheckPNExist(sPartNo, sPartId) then
        begin
          with adoQryUpdate do
          begin
            Close;
            SQL.Clear;
            {Parameters.Clear;
            Parameters.CreateParameter('SPEC1',ftString,pdInput,255,fgUnassigned);
            Parameters.CreateParameter('VERSION',ftString,pdInput,10,fgUnassigned);
            Parameters.CreateParameter('MATERIAL_TYPE',ftString,pdInput,240,fgUnassigned);
            Parameters.CreateParameter('OPTION2',ftString,pdInput,25,fgUnassigned);
            Parameters.CreateParameter('UOM',ftString,pdInput,25,fgUnassigned);
            Parameters.CreateParameter('ERP_ITEM_ID',ftString,pdInput,Length(sERPItemID),fgUnassigned);
            Parameters.CreateParameter('VERSION_FLAG',ftString,pdInput,10,fgUnassigned);
            Parameters.CreateParameter('PART_ID',ftInteger,pdInput,4,fgUnassigned); }
            SQL.Add('UPDATE SAJET.SYS_PART '+
                    '   SET SPEC1 = :SPEC1, VERSION = :VERSION, '+
                    '       MATERIAL_TYPE = :MATERIAL_TYPE, UOM = :UOM, '+
                    '       OPTION2 = :OPTION2, OPTION7 = :ERP_ITEM_ID, '+
                    '       OPTION8 = :VERSION_FLAG, UPDATE_TIME = SYSDATE '+
                    ' WHERE PART_ID = :PART_ID ');
            Parameters.ParamByName('SPEC1').Value := sDesc;
            Parameters.ParamByName('VERSION').Value := sVersion;
            Parameters.ParamByName('MATERIAL_TYPE').Value := sCategory;
            Parameters.ParamByName('OPTION2').Value := sLocateID;
            Parameters.ParamByName('UOM').Value := sUOM;
            Parameters.ParamByName('ERP_ITEM_ID').Value := sERPItemID;
            Parameters.ParamByName('VERSION_FLAG').Value := sVersionFlag;
            Parameters.ParamByName('PART_ID').Value := sPartId;
            ExecSQL;
          end;
        end
        else
        begin
          sPartId := GetMaxPartID;
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            {Parameters.Clear;
            Parameters.CreateParameter('PART_ID',ftInteger,pdInput,4,fgUnassigned);
            Parameters.CreateParameter('PART_NO',ftString,pdInput,30,fgUnassigned);
            Parameters.CreateParameter('SPEC1',ftString,pdInput,255,fgUnassigned);
            Parameters.CreateParameter('Update_UserID',ftInteger,pdInput,4,fgUnassigned);
            Parameters.CreateParameter('VERSION',ftString,pdInput,10,fgUnassigned);
            Parameters.CreateParameter('MATERIAL_TYPE',ftString,pdInput,240,fgUnassigned);
            Parameters.CreateParameter('OPTION2',ftString,pdInput,25,fgUnassigned);
            Parameters.CreateParameter('UOM',ftString,pdInput,25,fgUnassigned);
            Parameters.CreateParameter('ERP_ITEM_ID',ftString,pdInput,Length(sERPItemID),fgUnassigned);
            Parameters.CreateParameter('VERSION_FLAG',ftString,pdInput,10,fgUnassigned);}
            SQL.Add('INSERT INTO SAJET.SYS_PART '+
                    '(PART_ID, PART_NO, SPEC1, UPDATE_USERID, VERSION, '+
                    ' MATERIAL_TYPE, OPTION2, UOM, OPTION7, OPTION8) VALUES '+
                    '(:PART_ID, :PART_NO, :SPEC1, :UPDATE_USERID, :VERSION, '+
                    ' :MATERIAL_TYPE, :OPTION2, :UOM, :ERP_ITEM_ID, :VERSION_FLAG) ');
            Parameters.ParamByName('PART_ID').Value := sPartId;
            Parameters.ParamByName('PART_NO').Value := sPartNo;
            Parameters.ParamByName('SPEC1').Value := sDesc;
            Parameters.ParamByName('UPDATE_USERID').Value := 0;
            Parameters.ParamByName('VERSION').Value := sVersion;
            Parameters.ParamByName('MATERIAL_TYPE').Value := sCategory;
            Parameters.ParamByName('OPTION2').Value := sLocateID;
            Parameters.ParamByName('UOM').Value := sUOM;
            Parameters.ParamByName('ERP_ITEM_ID').Value := sERPItemID;
            Parameters.ParamByName('VERSION_FLAG').Value := sVersionFlag;
            ExecSQL;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_PART_MASTER', FieldByName('iRow').AsString, 'Transfer Error');
        Next;
        Continue;
      end;


      if sSeqID<>'' then
      begin
        sResult:=UpdateErp('erp_to_mes_item_master@sfc2erp',sSeqID);
        if sResult<>'OK' then
        begin
           LogException('SAJET.INTERFACE_PART_MASTER', FieldByName('iRow').AsString, sResult);
           next;
           continue;
        end;
      end;
      LogComplete('SAJET.INTERFACE_PART_MASTER', FieldByName('iRow').AsString);

      Inc(mI);
      LabCnt.Caption := InttoStr(mI);
      LabCnt.Refresh;
      Next;
    end;
    Close;
  end;
  ListBox1.Items.Add('Part Master - ' + IntToStr(mI) + ' Counts OK !!'+FormatDateTime('HH:MM:SS',Now));
  RemoveData('SAJET.INTERFACE_PART_MASTER', 'SAJET.INTERFACE_HT_PART_MASTER');
end;

procedure TTransfer.TransBOMHeader;
var
  mI : Integer;
  sPartNo,        //料號
  sPartVer,       //料號版本
  sBOM_ID, sPartId,sSeqID : String;
  sResult:string;
begin
  Application.ProcessMessages;
  sSeqID:='';
  with adoQrySelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT T.*, T.ROWID||'''' iRow FROM SAJET.INTERFACE_BOM_MASTER T '+
            ' WHERE T.TRANSFER_FLAG = ''N'' ORDER BY CREATE_TIME ');
    Open;
    First;
    mI := 0;
    while not Eof do
    begin
      sPartNo  := FieldByName('PART_NO').AsString;
      sPartVer := FieldByName('PART_VERSION').AsString;
      sSeqID   := Fieldbyname('seq_id').AsString;

      if Trim(sPartVer) = '' then sPartVer := 'N/A';

      if not CheckPNExist(sPartNo, sPartId) then
      begin
        LogException('SAJET.INTERFACE_BOM_MASTER', FieldByName('iRow').AsString, 'Invalid Part No');
        Next;
        Continue;
      end;

      if not CheckBOMExist(sPartId, sPartVer, sBOM_ID) then
      begin
        try
          sBOM_ID := GetMaxBOMID;
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            Parameters.Clear;
            SQL.Add('INSERT INTO SAJET.SYS_BOM_INFO '+
                    '(BOM_ID, PART_ID, VERSION, UPDATE_USERID) VALUES '+
                    '(:BOM_ID, :PART_ID, :VERSION, :UPDATE_USERID) ');
            Parameters.ParamByName('BOM_ID').Value := sBOM_ID;
            Parameters.ParamByName('PART_ID').Value := sPartId;
            Parameters.ParamByName('VERSION').Value := sPartVer;
            Parameters.ParamByName('UPDATE_USERID').Value := '0';
            ExecSQL;
          end;
        except
          LogException('SAJET.INTERFACE_BOM_MASTER', FieldByName('iRow').AsString, 'Create BOM Master Error');
          Next;
          Continue;
        end;
      end;

      if sSeqID<>'' then
      begin
        sResult:=UpdateErp('erp_to_mes_Bom_master@sfc2erp',sSeqID);
        if sResult<>'OK' then
        begin
           LogException('SAJET.INTERFACE_BOM_MASTER', FieldByName('iRow').AsString, sResult);
           next;
           continue;
        end;
      end;

      LogComplete('SAJET.INTERFACE_BOM_MASTER', FieldByName('iRow').AsString);
      {if sSeqID<>'' then
        UpdateErp('erp_to_mes_Bom_master@sfc2erp',sSeqID); }
      Inc(mI);
      LabCnt.Caption := InttoStr(mI);
      LabCnt.Refresh;
      Next;
    end;
    Close;
  end;
  ListBox1.Items.Add('BOM Master - ' + IntToStr(mI) + ' Counts OK !!'+FormatDateTime('HH:MM:SS',Now));
  RemoveData('SAJET.INTERFACE_BOM_MASTER', 'SAJET.INTERFACE_HT_BOM_MASTER');
end;

procedure TTransfer.TransBOMDetail;
var
  mI : Integer;
  sPartNo,      //料號
  sPartVer,     //料號版本
  sItemNo,      //零件料號
  sSEQ,         //流水號
  sQty,         //用量
  sBOM_ID, sPartId, sItemId,sSeqID : String;
  sResult:string;
begin
  Application.ProcessMessages;
  sSeqID:='';
  with adoQrySelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT T.*, T.ROWID||'''' iRow FROM SAJET.INTERFACE_BOM_DETAIL T '+
            ' WHERE T.TRANSFER_FLAG = ''N'' ORDER BY CREATE_TIME ');
    Open;
    First;
    mI := 0;
    while not Eof do
    begin
      sPartNo  := FieldByName('PART_NO').AsString;
      sPartVer := FieldByName('PART_VERSION').AsString;
      sItemNo  := FieldByName('ITEM_NO').AsString;
      sSEQ     := FieldByName('SEQ').AsString;
      sQty     := FieldByName('QTY').AsString;
      sSeqID   := Fieldbyname('seq_id').AsString;

      if Trim(sPartVer) = '' then sPartVer := 'N/A';

      if Trim(sQty) = '' then
        sQty := '0';

      if not CheckPNExist(sPartNo, sPartId) then
      begin
        LogException('SAJET.INTERFACE_BOM_DETAIL', FieldByName('iRow').AsString, 'Invalid Part No');
        Next;
        Continue;
      end;

      if not CheckPNExist(sItemNo, sItemId) then
      begin
        LogException('SAJET.INTERFACE_BOM_DETAIL', FieldByName('iRow').AsString, 'Invalid Item No');
        Next;
        Continue;
      end;

      if not CheckBOMExist(sPartId, sPartVer, sBOM_ID) then
      begin
        LogException('SAJET.INTERFACE_BOM_DETAIL', FieldByName('iRow').AsString, 'BOM Header Not Exist');
        Next;
        Continue;
      end;

      try
        if CheckBOMPNExist(sBOM_ID, sItemId) then
        begin
          with adoQryUpdate do
          begin
            Close;
            SQL.Clear;
            SQL.Add('UPDATE SAJET.SYS_BOM '+
                    '   SET ITEM_COUNT = :ITEM_COUNT, '+
                    '       ITEM_GROUP = :ITEM_GROUP, '+
                    '       VERSION = :VERSION, '+
                    '       UPDATE_TIME = SYSDATE '+
                    ' WHERE BOM_ID = :BOM_ID '+
                    '   AND ITEM_PART_ID = :ITEM_PART_ID ');
            Parameters.ParamByName('ITEM_COUNT').Value := sQty;
            Parameters.ParamByName('ITEM_GROUP').Value := sSEQ;
            Parameters.ParamByName('VERSION').Value := sPartVer;
            Parameters.ParamByName('BOM_ID').Value := sBOM_ID;
            Parameters.ParamByName('ITEM_PART_ID').Value := sItemId;
            ExecSQL;
          end;
        end
        else
        begin
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO SAJET.SYS_BOM '+
                    '(BOM_ID, ITEM_PART_ID, ITEM_GROUP, ITEM_COUNT, VERSION, UPDATE_USERID) VALUES '+
                    '(:BOM_ID, :ITEM_PART_ID, :ITEM_GROUP, :ITEM_COUNT, :VERSION, :UPDATE_USERID) ');
            Parameters.ParamByName('BOM_ID').Value := sBOM_ID;
            Parameters.ParamByName('ITEM_PART_ID').Value := sItemId;
            Parameters.ParamByName('ITEM_COUNT').Value := sQty;
            Parameters.ParamByName('ITEM_GROUP').Value := sSEQ;
            Parameters.ParamByName('VERSION').Value := sPartVer;
            Parameters.ParamByName('UPDATE_USERID').Value := '0';
            ExecSQL;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_BOM_DETAIL', FieldByName('iRow').AsString, 'Transfer Error');
        Next;
        Continue;
      end;

      if sSeqID<>'' then
      begin
        sResult:=UpdateErp('erp_to_mes_Bom_detail@sfc2erp',sSeqID);
        if sResult<>'OK' then
        begin
           LogException('SAJET.INTERFACE_BOM_DETAIL', FieldByName('iRow').AsString, sResult);
           next;
           continue;
        end;
      end;

      LogComplete('SAJET.INTERFACE_BOM_DETAIL', FieldByName('iRow').AsString);
      {if sSeqID<>'' then
        UpdateErp('erp_to_mes_Bom_detail@sfc2erp',sSeqID); }
      Inc(mI);
      LabCnt.Caption := InttoStr(mI);
      LabCnt.Refresh;
      Next;
    end;
    Close;
  end;
  ListBox1.Items.Add('BOM Detail - ' + IntToStr(mI) + ' Counts OK !!'+FormatDateTime('HH:MM:SS',Now));
  RemoveData('SAJET.INTERFACE_BOM_DETAIL', 'SAJET.INTERFACE_HT_BOM_DETAIL');
end;

procedure TTransfer.TransRTHeader;
var
  mI : Integer;
  sRTType,      //單號種類
  sRTNo,        //收料單號
  sVendor,      //供應商
  sSite,        //地區名稱
  sFac,sFacID,
  sRTID, sVendorID,sSeqID : String;
  sResult:string;
begin
  Application.ProcessMessages;
  sSeqID:='';
  with adoQrySelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT T.*, T.ROWID||'''' iRow FROM SAJET.INTERFACE_RT_MASTER T '+
            ' WHERE T.TRANSFER_FLAG = ''N'' ORDER BY CREATE_TIME ');
    Open;
    First;
    mI := 0;
    while not Eof do
    begin
      sRTType     := FieldByName('RT_TYPE').AsString;
      sRTNo       := FieldByName('RT_NO').AsString;
      sVendor     := FieldByName('VENDOR_NAME').AsString;
      sSite       := FieldByName('SITE_NAME').AsString;
      sSeqID      := FieldByName('Seq_ID').AsString;
      sFac        := Fieldbyname('org_id').AsString;

      adoQryTemp.Close;
      adoQryTemp.SQL.Clear;
      adoQryTemp.SQL.Add('SELECT FACTORY_ID FROM SAJET.SYS_FACTORY WHERE ENABLED = ''Y'' AND ROWNUM = 1 and factory_code='+''''+sFac+'''');
      adoQryTemp.Open;
      if adoQryTemp.RecordCount>0 then
        sFacID:=adoQryTemp.fieldbyname('factory_id').AsString
      else sFacID:='';
      if trim(sFacID) = '' then
      begin
        LogException('SAJET.INTERFACE_RT_MASTER', FieldByName('iRow').AsString, 'Invalid ORG_ID');
        Next;
        Continue;
      end;


      try
        if not CheckVendorExist(sVendor, sVendorID) then
        begin
          sVendorID := GetMaxVendorID;
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO SAJET.SYS_VENDOR '+
                    '(VENDOR_ID, VENDOR_NAME, UPDATE_USERID) VALUES '+
                    '(:VENDOR_ID, :VENDOR_NAME, :UPDATE_USERID) ');
            Parameters.ParamByName('VENDOR_ID').Value := sVendorID;
            Parameters.ParamByName('VENDOR_NAME').Value := sVendor;
            Parameters.ParamByName('UPDATE_USERID').Value := '0';
            ExecSQL;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_RT_MASTER', FieldByName('iRow').AsString, 'Invalid Vendor');
        Next;
        Continue;
      end;

      try
        if CheckRTExist(sRTNo, sRTID) then
        begin
          with adoQryUpdate do
          begin
            Close;
            SQL.Clear;
            SQL.Add('UPDATE SAJET.G_ERP_RTNO '+
                    '   SET VENDOR_ID = :VENDOR_ID, UPDATE_TIME = SYSDATE, '+
                    '       SITE_NAME = :SITE_NAME, RT_TYPE = :RT_TYPE ,Factory_id = :Fac_ID'+
                    ' WHERE RT_ID = :RT_ID ');
            Parameters.ParamByName('VENDOR_ID').Value := sVendorID;
            Parameters.ParamByName('SITE_NAME').Value := sSite;
            Parameters.ParamByName('RT_TYPE').Value := sRTType;
            Parameters.ParamByName('RT_ID').Value := sRTID;
            Parameters.ParamByName('Fac_ID').Value := sFacID;
            ExecSQL;
          end;
        end
        else
        begin
          sRTID := GetMaxRTID;
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO SAJET.G_ERP_RTNO '+
                    '(RT_ID, RT_NO, VENDOR_ID, UPDATE_USERID, SITE_NAME, RT_TYPE,Factory_id) VALUES '+
                    '(:RT_ID, :RT_NO, :VENDOR_ID, :UPDATE_USERID, :SITE_NAME, :RT_TYPE,:Fac_id) ');
            Parameters.ParamByName('RT_ID').Value := sRTID;
            Parameters.ParamByName('RT_NO').Value := sRTNo;
            Parameters.ParamByName('VENDOR_ID').Value := sVendorID;
            Parameters.ParamByName('UPDATE_USERID').Value := '0';
            Parameters.ParamByName('SITE_NAME').Value := sSite;
            Parameters.ParamByName('RT_TYPE').Value := sRTType;
            Parameters.ParamByName('Fac_ID').Value := sFacID;
            ExecSQL;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_RT_MASTER', FieldByName('iRow').AsString, 'RT Header Transfer Error');
        Next;
        Continue;
      end;


      if sSeqID<>'' then
      begin
        sResult:=UpdateErp('erp_to_mes_RT_MASTER@sfc2erp',sSeqID);
        if sResult<>'OK' then
        begin
           LogException('SAJET.INTERFACE_RT_MASTER', FieldByName('iRow').AsString, sResult);
           next;
           continue;
        end;
      end;

      LogComplete('SAJET.INTERFACE_RT_MASTER', FieldByName('iRow').AsString);
      {
      if sSeqID<>'' then
        UpdateErp('erp_to_mes_RT_MASTER@sfc2erp',sSeqID); }
      Inc(mI);
      LabCnt.Caption := InttoStr(mI);
      LabCnt.Refresh;
      Next;
    end;
    Close;
  end;
  ListBox1.Items.Add('RT Master - ' + IntToStr(mI) + ' Counts OK !!'+FormatDateTime('HH:MM:SS',Now));
  RemoveData('SAJET.INTERFACE_RT_MASTER', 'SAJET.INTERFACE_HT_RT_MASTER');
end;

procedure TTransfer.TransRTDetail;
var
  mI : Integer;
  sRTNo,        //收料單號
  sSeq,         //流水號
  sPartNo,      //料號
  sQty,         //收料數量
  sNGQty,       //不良數量
  sMFName,      //製造商
  sMFPart,      //製造商料號
  ssubinventory, //PO 倉位
  sRTID, sPartID,sVersion,sSeqID : String;
  sResult:string;
begin
   Application.ProcessMessages;
  sSeqID:='';
  with adoQrySelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT T.*, T.ROWID||'''' iRow FROM SAJET.INTERFACE_RT_DETAIL T '+
            ' WHERE T.TRANSFER_FLAG = ''N'' ORDER BY CREATE_TIME ');
    Open;
    First;
    mI := 0;
    while not Eof do
    begin
      sRTNo       := FieldByName('RT_NO').AsString;
      sSeq        := FieldByName('RT_SEQ').AsString;
      sPartNo     := FieldByName('ITEM_NO').AsString;
      sQty        := FieldByName('GOOD_QTY').AsString;
      sNGQty      := FieldByName('NG_QTY').AsString;
      sMFName     := FieldByName('MFGER_NAME').AsString;
      sMFPart     := FieldByName('MFGER_PART_NO').AsString;
      sVersion    := Fieldbyname('Version').AsString;
      sSeqID      := Fieldbyname('seq_id').AsString;
      ssubinventory := Fieldbyname('SUBINVENTORY').AsString;
      if (Trim(sQty) = '') or (Trim(sQty) = '0') then
      begin
        LogException('SAJET.INTERFACE_RT_DETAIL', FieldByName('iRow').AsString, 'QTY = 0');
        Next;
        Continue;
      end;

      if not CheckPNExist(sPartNo, sPartID) then
      begin
        LogException('SAJET.INTERFACE_RT_DETAIL', FieldByName('iRow').AsString, 'Invalid Part No');
        Next;
        Continue;
      end;

      if not CheckRTExist(sRTNo, sRTID) then
      begin
        LogException('SAJET.INTERFACE_RT_DETAIL', FieldByName('iRow').AsString, 'RT Header Not Exist');
        Next;
        Continue;
      end;

      try
        if CheckRTDetailExist(sRTID, sSeq) then
        begin
          with adoQryUpdate do
          begin
            Close;
            SQL.Clear;
            SQL.Add('UPDATE SAJET.G_ERP_RT_ITEM '+
                    '   SET INCOMING_QTY = :INCOMING_QTY, INCOMING_NG_QTY = :INCOMING_NG_QTY, '+
                    '       PART_ID = :PART_ID, '+
                    '       PART_VERSION = :iVersion, '+
                    '       MFGER_NAME = :MFGER_NAME, MFGER_PART_NO = :MFGER_PART_NO, '+
                    '       SUBINVENTORY = :SUBINVENTORY, '+
                    '       UPDATE_TIME = SYSDATE '+
                    ' WHERE RT_ID = :RT_ID '+
                    '   AND RT_SEQ = :RT_SEQ ');
            Parameters.ParamByName('INCOMING_QTY').Value := sQty;
            Parameters.ParamByName('INCOMING_NG_QTY').Value := sNGQty;
            Parameters.ParamByName('PART_ID').Value := sPartID;
            Parameters.ParamByname('iVersion').Value := sVersion;
            Parameters.ParamByName('MFGER_NAME').Value := sMFName;
            Parameters.ParamByName('MFGER_PART_NO').Value := sMFPart;
            Parameters.ParamByName('SUBINVENTORY').Value := ssubinventory;
            Parameters.ParamByName('RT_ID').Value := sRTID;
            Parameters.ParamByName('RT_SEQ').Value := sSeq;
            ExecSQL;
          end;
        end
        else
        begin
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO SAJET.G_ERP_RT_ITEM '+
                    '(RT_ID, PART_ID, INCOMING_QTY, UPDATE_USERID, MFGER_NAME, '+
                    ' MFGER_PART_NO,SUBINVENTORY, RT_SEQ, INCOMING_NG_QTY,PART_VERSION) VALUES '+
                    '(:RT_ID, :PART_ID, :INCOMING_QTY, :UPDATE_USERID, :MFGER_NAME, '+
                    ' :MFGER_PART_NO, :SUBINVENTORY, :RT_SEQ, :INCOMING_NG_QTY,:iVersion) ');
            Parameters.ParamByName('RT_ID').value := sRTID;
            Parameters.ParamByName('PART_ID').value := sPartID;
            Parameters.ParamByName('INCOMING_QTY').value := sQty;
            Parameters.ParamByName('UPDATE_USERID').value := '0';
            Parameters.ParamByName('MFGER_NAME').value := sMFName;
            Parameters.ParamByName('MFGER_PART_NO').value := sMFPart;
            Parameters.ParamByName('SUBINVENTORY').value := ssubinventory;
            Parameters.ParamByName('RT_SEQ').value := sSeq;
            Parameters.ParamByName('INCOMING_NG_QTY').value := sNGQty;
            Parameters.ParamByname('iVersion').value := sVersion;
            ExecSQL;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_RT_DETAIL', FieldByName('iRow').AsString, 'RT Detail Transfer Error');
        Next;
        Continue;
      end;

      if sSeqID<>'' then
      begin
        sResult:=UpdateErp('erp_to_mes_RT_Detail@sfc2erp',sSeqID);
        if sResult<>'OK' then
        begin
           LogException('SAJET.INTERFACE_RT_DETAIL', FieldByName('iRow').AsString, sResult);
           next;
           continue;
        end;
      end;

      LogComplete('SAJET.INTERFACE_RT_DETAIL', FieldByName('iRow').AsString);
      {
      if sSeqID<>'' then
        UpdateErp('erp_to_mes_RT_Detail@sfc2erp',sSeqID);  }
      Inc(mI);
      LabCnt.Caption := InttoStr(mI);
      LabCnt.Refresh;
      Next;
    end;
    Close;
  end;
  ListBox1.Items.Add('RT Detail - ' + IntToStr(mI) + ' Counts OK !!'+FormatDateTime('HH:MM:SS',Now));
  RemoveData('SAJET.INTERFACE_RT_DETAIL', 'SAJET.INTERFACE_HT_RT_DETAIL');
end;

procedure TTransfer.TransDNHeader;
var
  mI : Integer;
  sDNNo,      //DN號
  sCustomer,  //客戶
  sDNID, sCustID,sSeqID,sFac,sFacID : String;
  sResult:string;
begin
  Application.ProcessMessages;
  sSeqID:='';
  with adoQrySelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT T.*, T.ROWID||'''' iRow FROM SAJET.INTERFACE_DN_MASTER T '+
            ' WHERE T.TRANSFER_FLAG = ''N'' ORDER BY CREATE_TIME ');
    Open;
    First;
    mI := 0;
    while not Eof do
    begin
      sDNNo     := FieldByName('DN_NO').AsString;
      sCustomer := FieldByName('CUSTOMER').AsString;
      sSeqID    := Fieldbyname('seq_id').asstring;
      sFac      := Fieldbyname('org_id').AsString;

      adoQryTemp.Close;
      adoQryTemp.SQL.Clear;
      adoQryTemp.SQL.Add('SELECT FACTORY_ID FROM SAJET.SYS_FACTORY WHERE ENABLED = ''Y'' AND ROWNUM = 1 and factory_code='+''''+sFac+'''');
      adoQryTemp.Open;
      if adoQryTemp.RecordCount>0 then
        sFacID:=adoQryTemp.fieldbyname('factory_id').AsString
      else sFacID:='';
      if trim(sFacID) = '' then
      begin
        LogException('SAJET.INTERFACE_DN_MASTER', FieldByName('iRow').AsString, 'Invalid ORG_ID');
        Next;
        Continue;
      end;

      try
        if not CheckCustomerExist(sCustomer, sCustID) then
        begin
          sCustID := GetMaxCustID;
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO SAJET.SYS_CUSTOMER '+
                    '(CUSTOMER_ID, CUSTOMER_NAME, UPDATE_USERID) VALUES '+
                    '(:CUSTOMER_ID, :CUSTOMER_NAME, :UPDATE_USERID) ');
            Parameters.ParamByName('CUSTOMER_ID').value := sCustID;
            Parameters.ParamByName('CUSTOMER_NAME').value := sCustomer;
            Parameters.ParamByName('UPDATE_USERID').value := '0';
            ExecSQL;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_DN_MASTER', FieldByName('iRow').AsString, 'Invalid Customer');
        Next;
        Continue;
      end;

      try
        if CheckDNExist(sDNNo, sDNID) then
        begin
          with adoQryUpdate do
          begin
            Close;
            SQL.Clear;
            SQL.Add('UPDATE SAJET.G_DN_BASE '+
                    '   SET DN_CUST = :DN_CUST, UPDATE_TIME = SYSDATE '+
                    '       ,factory_id= :Fac_id '+
                    ' WHERE DN_ID = :DN_ID ');
            Parameters.ParamByName('DN_CUST').Value := sCustID;
            Parameters.ParamByName('DN_ID').Value := sDNID;
            Parameters.ParamByName('Fac_ID').Value := sFacID;
            ExecSQL;
          end;
        end
        else
        begin
          sDNID := GetMaxDNID;
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO SAJET.G_DN_BASE '+
                    '(DN_ID, DN_NO, DN_CUST, UPDATE_USERID,Factory_ID) VALUES '+
                    '(:DN_ID, :DN_NO, :DN_CUST, :UPDATE_USERID,:Fac_id) ');
            Parameters.ParamByName('DN_ID').value := sDNID;
            Parameters.ParamByName('DN_NO').value := sDNNo;
            Parameters.ParamByName('DN_CUST').value := sCustID;
            Parameters.ParamByName('UPDATE_USERID').value := '0';
            Parameters.ParamByName('Fac_ID').value := sFacID;
            ExecSQL;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_DN_MASTER', FieldByName('iRow').AsString, 'DN Header Transfer Error');
        Next;
        Continue;
      end;

      if sSeqID<>'' then
      begin
        sResult:=UpdateErp('erp_to_mes_DN_MASTER@sfc2erp',sSeqID);
        if sResult<>'OK' then
        begin
           LogException('SAJET.INTERFACE_DN_MASTER', FieldByName('iRow').AsString, sResult);
           next;
           continue;
        end;
      end;

      LogComplete('SAJET.INTERFACE_DN_MASTER', FieldByName('iRow').AsString);
      {if sSeqID<>'' then
        UpdateErp('erp_to_mes_DN_MASTER@sfc2erp',sSeqID);   }
      Inc(mI);
      LabCnt.Caption := InttoStr(mI);
      LabCnt.Refresh;
      Next;
    end;
    Close;
  end;
  ListBox1.Items.Add('DN Master - ' + IntToStr(mI) + ' Counts OK !!'+FormatDateTime('HH:MM:SS',Now));
  RemoveData('SAJET.INTERFACE_DN_MASTER', 'SAJET.INTERFACE_HT_DN_MASTER');
end;

procedure TTransfer.TransDNDetail;
var
  mI : Integer;
  sDNNo,    //DN
  sDNItem,  //DN項次
  sSO,      //SO
  sSOItem,  //SO項次
  sPart,    //料號
  sQty,     //數量
  sDNID, sPartID,sSeqID : String;
  sUOM,sCustomer,sCustPO,sHUbFlag,sEDIFlag,sSUBInv:string;
  sResult:string;
begin
  Application.ProcessMessages;
  sSeqID:='';
  with adoQrySelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT T.*, T.ROWID||'''' iRow FROM SAJET.INTERFACE_DN_DETAIL T '+
            ' WHERE T.TRANSFER_FLAG = ''N'' ORDER BY CREATE_TIME ');
    Open;
    First;
    mI := 0;
    while not Eof do
    begin
      sDNNo   := FieldByName('DN_NO').AsString;
      sDNItem := FieldByName('DN_ITEM').AsString;
      sSO     := FieldByName('SO_NO').AsString;
      sSOItem := FieldByName('SO_ITEM').AsString;
      sPart   := FieldByName('PART_NO').AsString;
      sQty    := inttostr(strtoint(FieldByName('QTY').AsString)*GetSetQty(fieldbyname('part_no').AsString));
      sSeqID  := Fieldbyname('Seq_id').asstring;
      sUOM    := Fieldbyname('UOM').AsString;
      sCustomer:=Fieldbyname('Customer').AsString;
      sCustPO := Fieldbyname('cust_po').AsString;
      sHubFLag:= Fieldbyname('Hub_flag').AsString;
      sEDIFlag:= Fieldbyname('Edi_Flag').AsString;
      sSUBInv := Fieldbyname('TRANSFER_SUBINV').AsString;

      if not CheckPNExist(sPart, sPartID) then
      begin
        LogException('SAJET.INTERFACE_DN_DETAIL', FieldByName('iRow').AsString, 'Invalid Part No');
        Next;
        Continue;
      end;

      if not CheckDNExist(sDNNo, sDNID) then
      begin
        LogException('SAJET.INTERFACE_DN_DETAIL', FieldByName('iRow').AsString, 'DN Header Not Exist');
        Next;
        Continue;
      end;

      try
        if CheckDNDetailExist(sDNID, sPartID) then
        begin
          with adoQryUpdate do
          begin
            Close;
            SQL.Clear;
            SQL.Add('UPDATE SAJET.G_DN_DETAIL '+
                    '   SET SO_NO = :SO_NO, SO_ITEM = :SO_ITEM, '+
                    '       DN_ITEM = :DN_ITEM, QTY = :QTY, '+
                    '       UPDATE_TIME = SYSDATE, '+
                    '       customer = :customer, '+
                    '       cust_po = :cust_PO, '+
                    '       uom = :uom , '+
                    '       DN_ITEM = :DN_ITEM '+
                    '       hub_flag = :hub_flag, '+
                    '       edi_flag = :edi_flag, '+
                    '       TRANSFER_SUBINV= :TRANSFER_SUBINV '+
                    ' WHERE DN_ID = :DN_ID '+
                    '  and PART_ID =:PART_ID  ');
            Parameters.ParamByName('SO_NO').value := sSO;
            Parameters.ParamByName('SO_ITEM').value := sSOItem;
            Parameters.ParamByName('PART_ID').value := sPartID;
            Parameters.ParamByName('QTY').value := sQty;
            Parameters.ParamByName('DN_ID').value := sDNID;
            Parameters.ParamByName('DN_ITEM').value := sDNItem;
            Parameters.ParamByName('CUSTOMER').value := sCustomer;
            Parameters.ParamByName('cust_po').value := sCustPO;
            Parameters.ParamByName('uom').value := sUom;
            Parameters.ParamByName('HUB_FLAG').value := sHubFlag;
            Parameters.ParamByName('EDI_FLAG').value := sEDIFlag;
            Parameters.ParamByName('TRANSFER_SUBINV').value := sSUBInv;
            ExecSQL;
          end;
        end
        else
        begin
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO SAJET.G_DN_DETAIL '+
                    '(DN_ID, DN_ITEM, SO_NO, SO_ITEM, PART_ID, QTY, UPDATE_USERID,customer,cust_PO,uom ,hub_flag,EDI_FLAG,TRANSFER_SUBINV) VALUES '+
                    '(:DN_ID, :DN_ITEM, :SO_NO, :SO_ITEM, :PART_ID, :QTY, :UPDATE_USERID,:customer,:cust_PO,:uom ,:hub_flag,:EDI_FLAG,:TRANSFER_SUBINV) ');
            Parameters.ParamByName('DN_ID').value := sDNID;
            Parameters.ParamByName('DN_ITEM').value := sDNItem;
            Parameters.ParamByName('SO_NO').value := sSO;
            Parameters.ParamByName('SO_ITEM').value := sSOItem;
            Parameters.ParamByName('PART_ID').value := sPartID;
            Parameters.ParamByName('QTY').value := sQty;
            Parameters.ParamByName('UPDATE_USERID').value := '0';
            Parameters.ParamByName('CUSTOMER').value := sCustomer;
            Parameters.ParamByName('cust_po').value := sCustPO;
            Parameters.ParamByName('uom').value := sUom;
            Parameters.ParamByName('HUB_FLAG').value := sHubFlag;
            Parameters.ParamByName('EDI_FLAG').value := sEDIFlag;
            Parameters.ParamByName('TRANSFER_SUBINV').value := sSUBInv;
            ExecSQL;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_DN_DETAIL', FieldByName('iRow').AsString, 'DN Detail Transfer Error');
        Next;
        Continue;
      end;

      if sSeqID<>'' then
      begin
        sResult:=UpdateErp('erp_to_mes_DN_DETAIL@sfc2erp',sSeqID);
        if sResult<>'OK' then
        begin
           LogException('SAJET.INTERFACE_DN_DETAIL', FieldByName('iRow').AsString, sResult);
           next;
           continue;
        end;
      end;
      LogComplete('SAJET.INTERFACE_DN_DETAIL', FieldByName('iRow').AsString);
      {if sSeqID<>'' then
        UpdateErp('erp_to_mes_DN_DETAIL@sfc2erp',sSeqID);  }
      Inc(mI);
      LabCnt.Caption := InttoStr(mI);
      LabCnt.Refresh;
      Next;
    end;
    Close;
  end;
  ListBox1.Items.Add('DN Detail - ' + IntToStr(mI) + ' Counts OK !!'+FormatDateTime('HH:MM:SS',Now));
  RemoveData('SAJET.INTERFACE_DN_DETAIL', 'SAJET.INTERFACE_HT_DN_DETAIL');
end;

procedure TTransfer.TransWOHeader;
var
  mI : Integer;
  sWONumber,  //工單號碼
  sPartNo,    //成品料號
  sVersion,   //料號版本
  sPlanQty,   //計劃量
  sWOType,    //工單類別
  sModelName, //機種別
  sRouteName, //製程別
  sPartId, sWOStatus, sFacID,sFac, sRouteID,sSeqID,sRowId : String;
  sPlanStart, sPlanEnd : TDatetime;
  sResult:string;
begin
  Application.ProcessMessages;
  sSeqID:='';
  with adoQrySelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT FACTORY_ID FROM SAJET.SYS_FACTORY WHERE ENABLED = ''Y'' AND ROWNUM = 1 ');
    Open;
    if RecordCount = 0 then
    begin
      Close;
      Exit;
    end else
      sFacID := FieldByName('FACTORY_ID').AsString;

    Close;
    SQL.Clear;
    SQL.Add('SELECT T.ROWID||'''' iRow,T.* FROM SAJET.INTERFACE_WO_MASTER T WHERE T.TRANSFER_FLAG = ''N'' ORDER BY CREATE_TIME ');
    Open;
    First;
    mI := 0;
    while not Eof do
    begin
      sWONumber  := FieldByName('WORK_ORDER').AsString;
      sPartNo    := FieldByName('PART_NO').AsString;
      sVersion   := FieldByName('VERSION').AsString;
      sPlanQty   := FieldByName('TARGET_QTY').AsString;
      sPlanStart := FieldByName('SCHEDULE_DATE').AsDateTime;
      sPlanEnd   := FieldByName('DUE_DATE').AsDateTime;
      sWOType    := FieldByName('WO_TYPE').AsString;
      sModelName := FieldByName('MODEL_NAME').AsString;
      sRouteName := FieldByName('ROUTE_NAME').AsString;
      sSeqID     := Fieldbyname('seq_id').asstring;
      sFac       := Fieldbyname('org_id').AsString;
      sRowId     := Fieldbyname('iRow').AsString;
      if Trim(sVersion) = '' then sVersion := 'N/A';
      if (Trim(sPlanQty) = '') or (Trim(sPlanQty) = '0') then
      begin
        LogException('SAJET.INTERFACE_WO_MASTER', sRowId, 'QTY = 0');
        Next;
        Continue;
      end;

      adoqrytemp.Close;
      adoqrytemp.SQL.Clear;
      adoqrytemp.SQL.Add('SELECT FACTORY_ID FROM SAJET.SYS_FACTORY WHERE ENABLED = ''Y'' AND ROWNUM = 1 and factory_code='+''''+sFac+'''');
      adoqrytemp.Open;
      if adoQryTemp.RecordCount>0 then
        sFacID:=adoQryTemp.fieldbyname('factory_id').AsString
      else sFacID:='';
      if trim(sFacID) = '' then
      begin
        LogException('SAJET.INTERFACE_WO_MASTER', FieldByName('iRow').AsString, 'Invalid ORG_ID');
        Next;
        Continue;
      end;

      if not CheckPNExist(sPartNo, sPartId) then
      begin
        LogException('SAJET.INTERFACE_WO_MASTER', FieldByName('iRow').AsString, 'Invalid Part No');
        Next;
        Continue;
      end;

      sRouteID := GetRouteID(sRouteName);

      try
        if not CheckWOExist(sWONumber, sWOStatus) then
        begin
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO SAJET.G_WO_BASE '+
                    '(WORK_ORDER, WO_TYPE, MODEL_ID, VERSION, TARGET_QTY, ROUTE_ID, MODEL_NAME, '+
                    ' WO_SCHEDULE_DATE, WO_DUE_DATE, UPDATE_USERID, WO_STATUS, FACTORY_ID) VALUES '+
                    '(:WORK_ORDER, :WO_TYPE, :MODEL_ID, :VERSION, :TARGET_QTY, :ROUTE_ID, :MODEL_NAME, '+
                    ' :WO_SCHEDULE_DATE, :WO_DUE_DATE, :UPDATE_USERID, :WO_STATUS, :FACTORY_ID) ');
            Parameters.ParamByName('WORK_ORDER').Value := sWONumber;
            Parameters.ParamByName('WO_TYPE').Value := sWOType;
            Parameters.ParamByName('MODEL_ID').Value := sPartId;
            Parameters.ParamByName('VERSION').Value := sVersion;
            Parameters.ParamByName('TARGET_QTY').Value := inttostr(strtoint(sPlanQty)*GetSetQty(sPartNo));
            Parameters.ParamByName('ROUTE_ID').Value := sRouteID;
            Parameters.ParamByName('MODEL_NAME').Value := sModelName;
            Parameters.ParamByName('WO_SCHEDULE_DATE').Value := sPlanStart;
            Parameters.ParamByName('WO_DUE_DATE').Value := sPlanEnd;
            Parameters.ParamByName('UPDATE_USERID').Value := '0';
            Parameters.ParamByName('WO_STATUS').Value := '0';
            Parameters.ParamByName('FACTORY_ID').Value := sFacID;
            ExecSQL;
          end;
        end else
        begin
          if StrToInt(sWOStatus) > 1 then   //已經展開序號
          begin
            with adoQryUpdate do
            begin
              Close;
              SQL.Clear;
              SQL.Add('UPDATE SAJET.G_WO_BASE '+
                      '   SET WO_TYPE = :WO_TYPE, MODEL_NAME = :MODEL_NAME, '+
                      '       WO_SCHEDULE_DATE = :WO_SCHEDULE_DATE, '+
                      '       WO_DUE_DATE = :WO_DUE_DATE, '+
                      '       UPDATE_TIME = SYSDATE, FACTORY_ID = :FACTORY_ID '+
                      ' WHERE WORK_ORDER = :WORK_ORDER ');
              Parameters.ParamByName('WO_TYPE').Value := sWOType;
              Parameters.ParamByName('MODEL_NAME').Value := sModelName;
              Parameters.ParamByName('WO_SCHEDULE_DATE').Value := sPlanStart;
              Parameters.ParamByName('WO_DUE_DATE').Value := sPlanEnd;
              Parameters.ParamByName('FACTORY_ID').Value := sFacID;
              Parameters.ParamByName('WORK_ORDER').Value := sWONumber;
              ExecSQL;
            end;
          end
          else                             //尚未展開序號
          begin
            with adoQryUpdate do
            begin
              Close;
              SQL.Clear;
              SQL.Add('UPDATE SAJET.G_WO_BASE '+
                      '   SET WO_TYPE = :WO_TYPE, MODEL_ID = :MODEL_ID, '+
                      '       VERSION = :VERSION, TARGET_QTY = :TARGET_QTY, '+
                      '       WO_SCHEDULE_DATE = :WO_SCHEDULE_DATE, '+
                      '       WO_DUE_DATE = :WO_DUE_DATE, MODEL_NAME = :MODEL_NAME, '+
                      '       UPDATE_TIME = SYSDATE, FACTORY_ID = :FACTORY_ID '+
                      ' WHERE WORK_ORDER = :WORK_ORDER ');
              Parameters.ParamByName('WO_TYPE').Value := sWOType;
              Parameters.ParamByName('MODEL_ID').Value := sPartId;
              Parameters.ParamByName('VERSION').Value := sVersion;
              Parameters.ParamByName('TARGET_QTY').Value := inttostr(strtoint(sPlanQty)*GetSetQty(sPartNo));
              Parameters.ParamByName('WO_SCHEDULE_DATE').Value := sPlanStart;
              Parameters.ParamByName('WO_DUE_DATE').Value := sPlanEnd;
              Parameters.ParamByName('MODEL_NAME').Value := sModelName;
              Parameters.ParamByName('FACTORY_ID').Value := sFacID;
              Parameters.ParamByName('WORK_ORDER').Value := sWONumber;
              ExecSQL;
            end;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_WO_MASTER', FieldByName('iRow').AsString, 'Transfer Error');
        Next;
        Continue;
      end;

      if sSeqID<>'' then
      begin
        sResult:=UpdateErp('erp_to_mes_WO_MASTER@sfc2erp',sSeqID);
        if sResult<>'OK' then
        begin
           LogException('SAJET.INTERFACE_WO_MASTER', FieldByName('iRow').AsString, sResult);
           next;
           continue;
        end;
      end;
      LogComplete('SAJET.INTERFACE_WO_MASTER', FieldByName('iRow').AsString);
     { if sSeqID<>'' then
        UpdateErp('erp_to_mes_WO_MASTER@sfc2erp',sSeqID); }
      Inc(mI);
      LabCnt.Caption := InttoStr(mI);
      LabCnt.Refresh;
      Next;
    end;
    Close;
  end;
  ListBox1.Items.Add('W/O Master - ' + IntToStr(mI) + ' Counts OK !!'+FormatDateTime('HH:MM:SS',Now));
  RemoveData('SAJET.INTERFACE_WO_MASTER', 'SAJET.INTERFACE_HT_WO_MASTER');
end;

procedure TTransfer.TransWODetail;
var
  mI : Integer;
  sWONumber,  //工單號碼
  sItemNo,    //料號
  sVersion,   //版本
  sQty,       //用量
  sType,      //類型
  sPartId, sWOStatus,sSeqID : String;
  sResult:string;
begin
  Application.ProcessMessages;
  sSeqID:='';
  with adoQrySelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT T.*, T.ROWID||'''' iRow FROM SAJET.INTERFACE_WO_DETAIL T '+
            ' WHERE T.TRANSFER_FLAG = ''N'' ORDER BY CREATE_TIME ');
    Open;
    First;
    mI := 0;
    while not Eof do
    begin
      sWONumber := FieldByName('WORK_ORDER').AsString;
      sItemNo   := FieldByName('ITEM_NO').AsString;
      sVersion  := FieldByName('VERSION').AsString;
      sQty      := FieldByName('TOTAL_QTY').AsString;
      sType     := FieldByName('TYPE').AsString;
      sSeqID    := Fieldbyname('Seq_id').AsString;

      if Trim(sVersion) = '' then sVersion := 'N/A';
      if Trim(sQty) = '' then sQty := '0';

      if not CheckPNExist(sItemNo, sPartId) then
      begin
        LogException('SAJET.INTERFACE_WO_DETAIL', FieldByName('iRow').AsString, 'Invalid Item No');
        Next;
        Continue;
      end;

      if not CheckWOExist(sWONumber, sWOStatus) then
      begin
        LogException('SAJET.INTERFACE_WO_DETAIL', FieldByName('iRow').AsString, 'Invalid Work Order');
        Next;
        Continue;
      end;

      try
        if sQty = '0' then     // Qty = 0 代表 Delete
        begin
          with adoQryUpdate do
          begin
            Close;
            SQL.Clear;
           // SQL.Add('DELETE FROM SAJET.G_WO_PICK_LIST '+
           //         ' WHERE WORK_ORDER = :WORK_ORDER AND PART_ID = :PART_ID ');
           SQL.Add('UPDATE SAJET.G_WO_PICK_LIST SET REQUEST_QTY= 0 '+
                   ' WHERE WORK_ORDER=:WORK_ORDER AND PART_ID = :PART_ID ');
            Parameters.ParamByName('WORK_ORDER').Value := sWONumber;
            Parameters.ParamByName('PART_ID').Value := sPartId;
            ExecSQL;
          end;
        end else
        begin
          if not CheckWOItemExist(sWONumber, sPartId) then
          begin
            with adoQryInst do
            begin
              Close;
              SQL.Clear;
              SQL.Add('INSERT INTO SAJET.G_WO_PICK_LIST '+
                      '(WORK_ORDER, PART_ID, REQUEST_QTY, VERSION) VALUES '+
                      '(:WORK_ORDER, :PART_ID, :REQUEST_QTY, :VERSION) ');
              Parameters.ParamByName('WORK_ORDER').Value := sWONumber;
              Parameters.ParamByName('PART_ID').Value := sPartId;
              Parameters.ParamByName('REQUEST_QTY').Value := sQty;
              Parameters.ParamByName('VERSION').Value := sVersion;
              ExecSQL;
            end;
          end else
          begin
            with adoQryUpdate do
            begin
              Close;
              SQL.Clear;
              SQL.Add('UPDATE SAJET.G_WO_PICK_LIST '+
                      '   SET REQUEST_QTY = :REQUEST_QTY, VERSION = :VERSION '+
                      ' WHERE WORK_ORDER = :WORK_ORDER AND PART_ID = :PART_ID ');
              Parameters.ParamByName('REQUEST_QTY').Value := sQty;
              Parameters.ParamByName('VERSION').Value := sVersion;
              Parameters.ParamByName('WORK_ORDER').Value := sWONumber;
              Parameters.ParamByName('PART_ID').Value := sPartId;
              ExecSQL;
            end;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_WO_DETAIL', FieldByName('iRow').AsString, 'Transfer Error');
        Next;
        Continue;
      end;

      if sSeqID<>'' then
      begin
        sResult:=UpdateErp('erp_to_mes_WO_DETAIL@sfc2erp',sSeqID);
        if sResult<>'OK' then
        begin
           LogException('SAJET.INTERFACE_WO_DETAIL', FieldByName('iRow').AsString, sResult);
           next;
           continue;
        end;
      end;

      LogComplete('SAJET.INTERFACE_WO_DETAIL', FieldByName('iRow').AsString);
      {if sSeqID<>'' then
        UpdateErp('erp_to_mes_WO_DETAIL@sfc2erp',sSeqID);}
      Inc(mI);
      LabCnt.Caption := InttoStr(mI);
      LabCnt.Refresh;
      Next;
    end;
    Close;
  end;
  ListBox1.Items.Add('W/O Detail - ' + IntToStr(mI) + ' Counts OK !!'+FormatDateTime('HH:MM:SS',Now));
  RemoveData('SAJET.INTERFACE_WO_DETAIL', 'SAJET.INTERFACE_HT_WO_DETAIL');
end;

procedure TTransfer.TransRcMisHeader;
var
  mI : Integer;
  SISSUE_HEADER_ID,           //申請單HEADER ID (PK)
  SISSUE_TYPE,                //異動類別代碼
  SISSUE_TYPE_NAME,           //異動類別名稱
  STYPE_CLASS,                  //異動類別領退分類
  SDOCUMENT_NUMBER,           //單據編碼
  //APPLY_TIME ,               //申請時間
  SAPPLY_USER_ID,             //申請人ID
  SAPPLY_USER_NAME,           //申請人名稱
  sFac,sFacID,
  sRCMISID,sSeqID : String;
  sResult:string;
begin
  Application.ProcessMessages;
  sSeqID:='';
  with adoQrySelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT T.*, T.ROWID||'''' iRow FROM SAJET.INTERFACE_RC_MIS_MASTER T '+
            ' WHERE T.TRANSFER_FLAG = ''N'' ORDER BY CREATION_DATE ');
    Open;
    First;
    mI := 0;
    while not Eof do
    begin
      sISSUE_HEADER_ID     := FieldByName('ISSUE_HEADER_ID').AsString;
      sISSUE_TYPE          := FieldByName('ISSUE_TYPE').AsString;
      sISSUE_TYPE_NAME     := FieldByName('ISSUE_TYPE_NAME').AsString;
      STYPE_CLASS          := FieldByName('TYPE_CLASS').AsString;
      sDOCUMENT_NUMBER     := FieldByName('DOCUMENT_NUMBER').AsString;
      //sAPPLY_TIME        := FieldByName('APPLY_TIME').AsString;
      sAPPLY_USER_ID       := FieldByName('APPLY_USER_ID').AsString;
      sAPPLY_USER_NAME     := FieldByName('APPLY_USER_NAME').AsString;
      sSeqID               := Fieldbyname('Seq_id').AsString;
      sFac                 := Fieldbyname('ORGANIZATION_ID').AsString;

      adoQryTemp.Close;
      adoQryTemp.SQL.Clear;
      adoQryTemp.SQL.Add('SELECT FACTORY_ID FROM SAJET.SYS_FACTORY WHERE ENABLED = ''Y'' AND ROWNUM = 1 and factory_code='+''''+sFac+'''');
      adoQryTemp.Open;
      if adoQryTemp.RecordCount>0 then
        sFacID:= adoQryTemp.fieldbyname('factory_id').AsString
      else sFacID:='';
      if trim(sFacID) = '' then
      begin
        LogException('SAJET.INTERFACE_RC_MIS_MASTER', FieldByName('iRow').AsString, 'Invalid ORG_ID');
        Next;
        Continue;
      end;

      try
        if CheckRcMisMasterExist(sDOCUMENT_NUMBER, sRCMISID) then
        begin
            LogException('SAJET.INTERFACE_RC_MIS_MASTER', FieldByName('iRow').AsString, 'DUB DOCUMENT_NUMBER ');
            Next;
            Continue;
        end
        else
        begin
          sRCMISID := GetMaxRCMISID;
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO SAJET.G_ERP_RC_MIS_MASTER '+
                    '(RC_MIS_ID,ISSUE_HEADER_ID,ISSUE_TYPE,ISSUE_TYPE_NAME,TYPE_CLASS,DOCUMENT_NUMBER, '+
                    '     APPLY_USER_ID,APPLY_USER_NAME,ORGANIZATION_ID,UPDATE_USERID) VALUES '+
                    '(:RC_MIS_ID,:ISSUE_HEADER_ID,:ISSUE_TYPE,:ISSUE_TYPE_NAME,:TYPE_CLASS,:DOCUMENT_NUMBER, '+
                    '          :APPLY_USER_ID,:APPLY_USER_NAME,:ORGANIZATION_ID,:UPDATE_USERID) ');
            Parameters.ParamByName('RC_MIS_ID').Value := sRCMISID;
            Parameters.ParamByName('ISSUE_HEADER_ID').Value := sISSUE_HEADER_ID;
            Parameters.ParamByName('ISSUE_TYPE').Value := sISSUE_TYPE;
            Parameters.ParamByName('ISSUE_TYPE_NAME').Value := sISSUE_TYPE_NAME;
            Parameters.ParamByName('TYPE_CLASS').Value := sTYPE_CLASS;
            Parameters.ParamByName('DOCUMENT_NUMBER').Value := sDOCUMENT_NUMBER;
            Parameters.ParamByName('APPLY_USER_ID').Value := sAPPLY_USER_ID;
            Parameters.ParamByName('APPLY_USER_NAME').Value := sAPPLY_USER_NAME;
            Parameters.ParamByName('ORGANIZATION_ID').Value := sFacID;
            Parameters.ParamByName('UPDATE_USERID').Value := '0';
            ExecSQL;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_RC_MIS_MASTER', FieldByName('iRow').AsString, 'RC_MIS Header Transfer Error');
        Next;
        Continue;
      end;


      if sSeqID<>'' then
      begin
        sResult:=UpdateErp('erp_to_mes_RC_MIS_MASTER@sfc2erp',sSeqID);
        if sResult<>'OK' then
        begin
           LogException('SAJET.INTERFACE_RC_MIS_MASTER', FieldByName('iRow').AsString, sResult);
           next;
           continue;
        end;
      end;

      LogComplete('SAJET.INTERFACE_RC_MIS_MASTER', FieldByName('iRow').AsString);
      {
      if sSeqID<>'' then
        UpdateErp('erp_to_mes_RT_MASTER@sfc2erp',sSeqID); }
      Inc(mI);
      LabCnt.Caption := InttoStr(mI);
      LabCnt.Refresh;
      Next;
    end;
    Close;
  end;
  ListBox1.Items.Add('RC_MIS Master - ' + IntToStr(mI) + ' Counts OK !!'+FormatDateTime('HH:MM:SS',Now));
  RemoveData('SAJET.INTERFACE_RC_MIS_MASTER', 'SAJET.INTERFACE_HT_RC_MIS_MASTER');
end;

procedure TTransfer.TransRcMisDetail;
var
  mI : Integer;
  sDOCUMENT_NUMBER,        //單據編碼
  sISSUE_HEADER_ID,        //申請單HEADER ID
  sISSUE_LINE_ID,          //申請單LINE ID (PK)
  sSEQ_NUMBER,             //LINE 序號
  //INVENTORY_ITEM_ID,      //料號ID
  //sITEM_NO,                //料號
  sSUBINVENTORY,           //申請倉庫
  //LOCATOR_ID,             //申請儲位ID
  sLOCATOR,                //申請儲位
  sAPPLY_QTY,              //申請數量
  sCHECK_CODE,             //檢核碼
  //sORGANIZATION_ID,        //組織ID
  sRCMISID,sPartNo, sPartID,sSeqID,sLocateID,sFac,sFacID : String;
  sResult:string;
begin
  Application.ProcessMessages;
  sSeqID:='';
  with adoQrySelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT T.*, T.ROWID||'''' iRow FROM SAJET.INTERFACE_RC_MIS_DETAIL T '+
            ' WHERE T.TRANSFER_FLAG = ''N'' ORDER BY CREATION_DATE ');
    Open;
    First;
    mI := 0;
    while not Eof do
    begin
      sDOCUMENT_NUMBER       := FieldByName('DOCUMENT_NUMBER').AsString;
      sISSUE_HEADER_ID       := FieldByName('ISSUE_HEADER_ID').AsString;
      sISSUE_LINE_ID         := FieldByName('ISSUE_LINE_ID').AsString;
      sSEQ_NUMBER            := FieldByName('SEQ_NUMBER').AsString;
      //sITEM_NO             := FieldByName('ITEM_NO').AsString;
      sPartNo                := FieldByName('ITEM_NO').AsString;
      sSUBINVENTORY          := FieldByName('SUBINVENTORY').AsString;
      sLOCATOR               := Fieldbyname('LOCATOR').AsString;
      sAPPLY_QTY             := FieldByName('APPLY_QTY').AsString;
      sFac                   := FieldByName('ORGANIZATION_ID').AsString;
      sSeqID                 := Fieldbyname('Seq_id').AsString;

      adoqrytemp.Close;
      adoqrytemp.SQL.Clear;
      adoqrytemp.SQL.Add('SELECT FACTORY_ID FROM SAJET.SYS_FACTORY WHERE ENABLED = ''Y'' AND ROWNUM = 1 and factory_code='+''''+sFac+'''');
      adoqrytemp.Open;
      if adoQrytemp.RecordCount>0 then
        sFacID:= adoqrytemp.fieldbyname('factory_id').AsString
      else sFacID:='';
      if trim(sFacID) = '' then
      begin
        LogException('SAJET.INTERFACE_RC_MIS_DETAIL', FieldByName('iRow').AsString, 'Invalid ORG_ID');
        Next;
        Continue;
      end;

      if (Trim(sAPPLY_QTY) = '') or (Trim(sAPPLY_QTY) = '0') then
      begin
        LogException('SAJET.INTERFACE_RC_MIS_DETAIL', FieldByName('iRow').AsString, 'QTY = 0');
        Next;
        Continue;
      end;

      if not CheckPNExist(sPartNo, sPartID) then
      begin
        LogException('SAJET.INTERFACE_RC_MIS_DETAIL', FieldByName('iRow').AsString, 'Invalid Part No');
        Next;
        Continue;
      end;

      if not CheckRCMISMASTERExist(sDOCUMENT_NUMBER, sRCMISID) then
      begin
        LogException('SAJET.INTERFACE_RC_MIS_DETAIL', FieldByName('iRow').AsString, 'RC_MIS Header Not Exist');
        Next;
        Continue;
      end;

      try
        sLocateID := GetLocateID(sSUBINVENTORY, sLOCATOR);
        if  sLocateID = '0'  then
        begin
          LogException('SAJET.INTERFACE_RC_MIS_DETAIL', FieldByName('iRow').AsString, 'Locate Not Exist');
          Next;
          Continue;
        end;
      except
        LogException('SAJET.INTERFACE_RC_MIS_DETAIL', FieldByName('iRow').AsString, 'Locate Not Exist');
        Next;
        Continue;
      end;

      try
        if CheckRCMISDetailExist(sRCMISID, sISSUE_LINE_ID) then
        begin
          LogException('SAJET.INTERFACE_RC_MIS_DETAIL', FieldByName('iRow').AsString, 'DUB ISSUE_LINE_ID ');
          Next;
          Continue;
        end
        else
        begin
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO SAJET.G_ERP_RC_MIS_DETAIL '+
                    '(  RC_MIS_ID,ISSUE_HEADER_ID,ISSUE_LINE_ID,SEQ_NUMBER,PART_ID, '+
                    '  LOCATE_ID,APPLY_QTY,ORGANIZATION_ID,UPDATE_USERID) VALUES '+
                    '( :RC_MIS_ID,:ISSUE_HEADER_ID,:ISSUE_LINE_ID,:SEQ_NUMBER,:PART_ID, '+
                    '  :LOCATE_ID,:APPLY_QTY,:ORGANIZATION_ID,:UPDATE_USERID) ');
            Parameters.ParamByName('RC_MIS_ID').Value := sRCMISID;
            Parameters.ParamByName('ISSUE_HEADER_ID').Value := sISSUE_HEADER_ID;
            Parameters.ParamByName('ISSUE_LINE_ID').Value := sISSUE_LINE_ID;
            Parameters.ParamByName('SEQ_NUMBER').Value := SSEQ_NUMBER;
            Parameters.ParamByName('PART_ID').Value := sPartID;
            Parameters.ParamByName('LOCATE_ID').Value :=sLocateID;
            Parameters.ParamByName('APPLY_QTY').Value := sAPPLY_QTY;
            Parameters.ParamByName('ORGANIZATION_ID').Value := sFacID;
            Parameters.ParamByname('UPDATE_USERID').Value := '0';
            ExecSQL;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_RC_MIS_DETAIL', FieldByName('iRow').AsString, 'RC_MIS Detail Transfer Error');
        Next;
        Continue;
      end;

      if sSeqID<>'' then
      begin
        sResult:=UpdateErp('erp_to_mes_RC_MIS_Detail@sfc2erp',sSeqID);
        if sResult<>'OK' then
        begin
           LogException('SAJET.INTERFACE_RC_MIS_DETAIL', FieldByName('iRow').AsString, sResult);
           next;
           continue;
        end;
      end;

      LogComplete('SAJET.INTERFACE_RC_MIS_DETAIL', FieldByName('iRow').AsString);
      {
      if sSeqID<>'' then
        UpdateErp('erp_to_mes_RT_Detail@sfc2erp',sSeqID);  }
      Inc(mI);
      LabCnt.Caption := InttoStr(mI);
      LabCnt.Refresh;
      Next;
    end;
    Close;
  end;
  ListBox1.Items.Add('RT_MIS Detail - ' + IntToStr(mI) + ' Counts OK !!'+FormatDateTime('HH:MM:SS',Now));
  RemoveData('SAJET.INTERFACE_RC_MIS_DETAIL', 'SAJET.INTERFACE_HT_RC_MIS_DETAIL');
end;

procedure TTransfer.TransRcTransferHeader;
var
  mI : Integer;
  SISSUE_HEADER_ID,           //申請單HEADER ID (PK)
  SISSUE_TYPE,                //異動類別代碼
  SISSUE_TYPE_NAME,           //異動類別名稱
  STYPE_CLASS,                 //異動類別領退分類
  SDOCUMENT_NUMBER,           //單據編碼
  //APPLY_TIME ,               //申請時間
  SAPPLY_USER_ID,             //申請人ID
  SAPPLY_USER_NAME,           //申請人名稱
  sFac,sFacID,
  sRCTRANSFERID,sSeqID : String;
  sResult:string;
begin
  Application.ProcessMessages;
  sSeqID:='';
  with adoQrySelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT T.*, T.ROWID||'''' iRow FROM SAJET.INTERFACE_RC_TRANSFER_MASTER T '+
            ' WHERE T.TRANSFER_FLAG = ''N'' ORDER BY CREATION_DATE ');
    Open;
    First;
    mI := 0;
    while not Eof do
    begin
      sISSUE_HEADER_ID     := FieldByName('ISSUE_HEADER_ID').AsString;
      sISSUE_TYPE          := FieldByName('ISSUE_TYPE').AsString;
      sISSUE_TYPE_NAME     := FieldByName('ISSUE_TYPE_NAME').AsString;
      STYPE_CLASS          := FieldByName('TYPE_CLASS').AsString;
      sDOCUMENT_NUMBER     := FieldByName('DOCUMENT_NUMBER').AsString;
      //sAPPLY_TIME        := FieldByName('APPLY_TIME').AsString;
      sAPPLY_USER_ID       := FieldByName('APPLY_USER_ID').AsString;
      sAPPLY_USER_NAME     := FieldByName('APPLY_USER_NAME').AsString;
      sSeqID               := Fieldbyname('Seq_id').AsString;
      sFac                 := Fieldbyname('ORGANIZATION_ID').AsString;

      adoqrytemp.Close;
      adoqrytemp.SQL.Clear;
      adoqrytemp.SQL.Add('SELECT FACTORY_ID FROM SAJET.SYS_FACTORY WHERE ENABLED = ''Y'' AND ROWNUM = 1 and factory_code='+''''+sFac+'''');
      adoqrytemp.Open;
      if adoQrytemp.RecordCount>0 then
        sFacID:= adoqrytemp.fieldbyname('factory_id').AsString
      else sFacID:='';
      if trim(sFacID) = '' then
      begin
        LogException('SAJET.INTERFACE_RC_TRANSFER_MASTER', FieldByName('iRow').AsString, 'Invalid ORG_ID');
        Next;
        Continue;
      end;

      try
        if CheckRcTRANSFERMasterExist(sDOCUMENT_NUMBER, sRCTRANSFERID) then
        begin
            LogException('SAJET.INTERFACE_RC_TRANSFER_MASTER', FieldByName('iRow').AsString, 'DUB DOCUMENT_NUMBER ');
            Next;
            Continue;
        end
        else
        begin
          sRCTRANSFERID := GetMaxRCTRANSFERID;
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO SAJET.G_ERP_RC_TRANSFER_MASTER '+
                    '(RC_TRANSFER_ID,ISSUE_HEADER_ID,ISSUE_TYPE,ISSUE_TYPE_NAME,TYPE_CLASS,DOCUMENT_NUMBER, '+
                    '     APPLY_USER_ID,APPLY_USER_NAME,ORGANIZATION_ID,UPDATE_USERID) VALUES '+
                    '(:RC_TRANSFER_ID,:ISSUE_HEADER_ID,:ISSUE_TYPE,:ISSUE_TYPE_NAME,:TYPE_CLASS,:DOCUMENT_NUMBER, '+
                    '          :APPLY_USER_ID,:APPLY_USER_NAME,:ORGANIZATION_ID,:UPDATE_USERID) ');
            Parameters.ParamByName('RC_TRANSFER_ID').Value := sRCTRANSFERID;
            Parameters.ParamByName('ISSUE_HEADER_ID').Value := sISSUE_HEADER_ID;
            Parameters.ParamByName('ISSUE_TYPE').Value := sISSUE_TYPE;
            Parameters.ParamByName('ISSUE_TYPE_NAME').Value := sISSUE_TYPE_NAME;
            Parameters.ParamByName('TYPE_CLASS').Value := sTYPE_CLASS;
            Parameters.ParamByName('DOCUMENT_NUMBER').Value := sDOCUMENT_NUMBER;
            Parameters.ParamByName('APPLY_USER_ID').Value := sAPPLY_USER_ID;
            Parameters.ParamByName('APPLY_USER_NAME').Value := sAPPLY_USER_NAME;
            Parameters.ParamByName('ORGANIZATION_ID').Value := sFacID;
            Parameters.ParamByName('UPDATE_USERID').Value := '0';
            ExecSQL;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_RC_TRANSFER_MASTER', FieldByName('iRow').AsString, 'RC_TRANSFER Header Transfer Error');
        Next;
        Continue;
      end;


      if sSeqID<>'' then
      begin
        sResult:=UpdateErp('erp_to_mes_RC_TRANSFER_MASTER@sfc2erp',sSeqID);
        if sResult<>'OK' then
        begin
           LogException('SAJET.INTERFACE_RC_TRANSFER_MASTER', FieldByName('iRow').AsString, sResult);
           next;
           continue;
        end;
      end;

      LogComplete('SAJET.INTERFACE_RC_TRANSFER_MASTER', FieldByName('iRow').AsString);
      {
      if sSeqID<>'' then
        UpdateErp('erp_to_mes_RT_MASTER@sfc2erp',sSeqID); }
      Inc(mI);
      LabCnt.Caption := InttoStr(mI);
      LabCnt.Refresh;
      Next;
    end;
    Close;
  end;
  ListBox1.Items.Add('RC_TRANSFER Master - ' + IntToStr(mI) + ' Counts OK !!'+FormatDateTime('HH:MM:SS',Now));
  RemoveData('SAJET.INTERFACE_RC_TRANSFER_MASTER', 'SAJET.INTERFACE_H_RC_TRANSFER_MASTER');
end;

procedure TTransfer.TransRcTransferDetail;
var
  mI : Integer;
  sDOCUMENT_NUMBER,       //單據編碼
  sISSUE_HEADER_ID,       //申請單HEADER ID
  sISSUE_LINE_ID,         //申請單LINE ID (PK)
  sSEQ_NUMBER,            //LINE 序號
  //sINVENTORY_ITEM_ID,     //料號ID
  sITEM_NO ,              //料號
  sSUBINVENTORY,          //申請倉庫
  //sLOCATOR_ID,            //申請儲位ID
  sLOCATOR,                //申請儲位
  sTRANSFER_SUBINVENTORY,  //移轉倉庫
  //sTRANSFER_LOCATOR_ID,    //移轉儲位ID
  sTRANSFER_LOCATOR,       //移轉儲位
  sAPPLY_QTY,              //申請數量
  sCHECK_CODE,            //檢核碼
  sORGANIZATION_ID,       //組織ID
  sRCTransferID,sPartNo, sPartID,sSeqID,sfromLocateID,sTolocateid,sFac,sFacID : String;
  sResult:string;
begin
  Application.ProcessMessages;
  sSeqID:='';
  with adoQrySelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT T.*, T.ROWID||'''' iROW FROM SAJET.INTERFACE_RC_TRANSFER_DETAIL T '+
            ' WHERE T.TRANSFER_FLAG = ''N'' ORDER BY CREATION_DATE ');
    Open;
    First;
    mI := 0;
    while not Eof do
    begin
      sDOCUMENT_NUMBER       := FieldByName('DOCUMENT_NUMBER').AsString;
      sISSUE_HEADER_ID       := FieldByName('ISSUE_HEADER_ID').AsString;
      sISSUE_LINE_ID         := FieldByName('ISSUE_LINE_ID').AsString;
      sSEQ_NUMBER            := FieldByName('SEQ_NUMBER').AsString;
      //sITEM_NO             := FieldByName('ITEM_NO').AsString;
      sPartNo                := FieldByName('ITEM_NO').AsString;
      sSUBINVENTORY          := FieldByName('SUBINVENTORY').AsString;
      sLOCATOR               := Fieldbyname('LOCATOR').AsString;
      sTRANSFER_SUBINVENTORY := FieldByName('TRANSFER_SUBINVENTORY').AsString;
      sTRANSFER_LOCATOR      := Fieldbyname('TRANSFER_LOCATOR').AsString;
      sAPPLY_QTY             := FieldByName('APPLY_QTY').AsString;
      sFac                   := FieldByName('ORGANIZATION_ID').AsString;
      sSeqID                 := Fieldbyname('Seq_id').AsString;

      adoqrytemp.Close;
      adoqrytemp.SQL.Clear;
      adoqrytemp.SQL.Add('SELECT FACTORY_ID FROM SAJET.SYS_FACTORY WHERE ENABLED = ''Y'' AND ROWNUM = 1 and factory_code='+''''+sFac+'''');
      adoqrytemp.Open;
      if adoQrytemp.RecordCount>0 then
        sFacID:= adoqrytemp.fieldbyname('factory_id').AsString
      else sFacID:='';
      if trim(sFacID) = '' then
      begin
        LogException('SAJET.INTERFACE_RC_TRANSFER_DETAIL', FieldByName('iRow').AsString, 'Invalid ORG_ID');
        Next;
        Continue;
      end;

      if (Trim(sAPPLY_QTY) = '') or (Trim(sAPPLY_QTY) = '0') then
      begin
        LogException('SAJET.INTERFACE_RC_TRANSFER_DETAIL', FieldByName('iRow').AsString, 'QTY = 0');
        Next;
        Continue;
      end;

      if not CheckPNExist(sPartNo, sPartID) then
      begin
        LogException('SAJET.INTERFACE_RC_TRANSFER_DETAIL', FieldByName('iRow').AsString, 'Invalid Part No');
        Next;
        Continue;
      end;

      if not CheckRCTRANSFERMASTERExist(sDOCUMENT_NUMBER, sRCTRANSFERID) then
      begin
        LogException('SAJET.INTERFACE_RC_TRANSFER_DETAIL', FieldByName('iRow').AsString, 'RC_TRANSFER Header Not Exist');
        Next;
        Continue;
      end;

      try
        sFromLocateID := GetLocateID(sSUBINVENTORY, sLOCATOR);
        if  sFromLocateID = '0'  then
        begin
          LogException('SAJET.INTERFACE_RC_TRANSFER_DETAIL', FieldByName('iRow').AsString, 'From Locate Not Exist');
          Next;
          Continue;
        end;
      except
        LogException('SAJET.INTERFACE_RC_TRANSFER_DETAIL', FieldByName('iRow').AsString, 'From Locate Not Exist');
        Next;
        Continue;
      end;

      try
        sToLocateID := GetLocateID(sTRANSFER_SUBINVENTORY, sTRANSFER_LOCATOR);
        if  sToLocateID = '0'  then
        begin
          LogException('SAJET.INTERFACE_RC_TRANSFER_DETAIL', FieldByName('iRow').AsString, 'TO Locate Not Exist');
          Next;
          Continue;
        end;
      except
        LogException('SAJET.INTERFACE_RC_TRANSFER_DETAIL', FieldByName('iRow').AsString, 'TO Locate Not Exist');
        Next;
        Continue;
      end;

      try
        if CheckRCTRANSFERDetailExist(sRCTRANSFERID, sISSUE_LINE_ID) then
        begin
          LogException('SAJET.INTERFACE_RC_TRANSFER_DETAIL', FieldByName('iRow').AsString, 'DUB ISSUE_LINE_ID ');
          Next;
          Continue;
        end
        else
        begin
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO SAJET.G_ERP_RC_TRANSFER_DETAIL '+
                    '( RC_TRANSFER_ID,ISSUE_HEADER_ID,ISSUE_LINE_ID,SEQ_NUMBER,PART_ID, '+
                    '   FROM_LOCATE_ID,TO_LOCATE_ID,APPLY_QTY,ORGANIZATION_ID,UPDATE_USERID) VALUES '+
                    '(:RC_TRANSFER_ID,:ISSUE_HEADER_ID,:ISSUE_LINE_ID,:SEQ_NUMBER,:PART_ID, '+
                    '   :FROM_LOCATE_ID,:TO_LOCATE_ID,:APPLY_QTY,:ORGANIZATION_ID,:UPDATE_USERID) ');
            Parameters.ParamByName('RC_TRANSFER_ID').Value := sRCTRANSFERID;
            Parameters.ParamByName('ISSUE_HEADER_ID').Value := sISSUE_HEADER_ID;
            Parameters.ParamByName('ISSUE_LINE_ID').Value := sISSUE_LINE_ID;
            Parameters.ParamByName('SEQ_NUMBER').Value := SSEQ_NUMBER;
            Parameters.ParamByName('PART_ID').Value := sPartID;
            Parameters.ParamByName('FROM_LOCATE_ID').Value :=sFromLocateID;
            Parameters.ParamByName('TO_LOCATE_ID').Value :=sToLocateID;
            Parameters.ParamByName('APPLY_QTY').Value := sAPPLY_QTY;
            Parameters.ParamByName('ORGANIZATION_ID').Value := sFacID;
            Parameters.ParamByname('UPDATE_USERID').Value := '0';
            ExecSQL;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_RC_TRANSFER_DETAIL', FieldByName('iRow').AsString, 'RC_TRANSFER Detail Transfer Error');
        Next;
        Continue;
      end;

      if sSeqID<>'' then
      begin
        sResult:=UpdateErp('erp_to_mes_RC_TRANSFER_Detail@sfc2erp',sSeqID);
        if sResult<>'OK' then
        begin
           LogException('SAJET.INTERFACE_RC_TRANSFER_DETAIL', FieldByName('iRow').AsString, sResult);
           next;
           continue;
        end;
      end;

      LogComplete('SAJET.INTERFACE_RC_TRANSFER_DETAIL', FieldByName('iRow').AsString);
      {
      if sSeqID<>'' then
        UpdateErp('erp_to_mes_RT_Detail@sfc2erp',sSeqID);  }
      Inc(mI);
      LabCnt.Caption := InttoStr(mI);
      LabCnt.Refresh;
      Next;
    end;
    Close;
  end;
  ListBox1.Items.Add('RT_TRANSFER Detail - ' + IntToStr(mI) + ' Counts OK !!'+FormatDateTime('HH:MM:SS',Now));
  RemoveData('SAJET.INTERFACE_RC_TRANSFER_DETAIL', 'SAJET.INTERFACE_H_RC_TRANSFER_DETAIL');
end;

procedure TTransfer.TransRcWipHeader;
var
  mI : Integer;
  SISSUE_HEADER_ID,           //申請單HEADER ID (PK)
  SISSUE_TYPE,                //異動類別代碼
  SISSUE_TYPE_NAME,           //異動類別名稱
  STYPE_CLASS,                  //異動類別領退分類
  SDOCUMENT_NUMBER,           //單據編碼
  SWIP_ENTITY_NAME,            //工單名稱
  //APPLY_TIME ,               //申請時間
  SAPPLY_USER_ID,             //申請人ID
  SAPPLY_USER_NAME,           //申請人名稱
  sFac,sFacID,
  sRCWipID,sSeqID : String;
  sResult:string;
begin
  Application.ProcessMessages;
  sSeqID:='';
  with adoQrySelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT T.*, T.ROWID||'''' iRow FROM SAJET.INTERFACE_RC_WIP_MASTER T '+
            ' WHERE T.TRANSFER_FLAG = ''N'' ORDER BY CREATION_DATE ');
    Open;
    First;
    mI := 0;
    while not Eof do
    begin
      sISSUE_HEADER_ID     := FieldByName('ISSUE_HEADER_ID').AsString;
      sISSUE_TYPE          := FieldByName('ISSUE_TYPE').AsString;
      sISSUE_TYPE_NAME     := FieldByName('ISSUE_TYPE_NAME').AsString;
      STYPE_CLASS          := FieldByName('TYPE_CLASS').AsString;
      sDOCUMENT_NUMBER     := FieldByName('DOCUMENT_NUMBER').AsString;
      SWIP_ENTITY_NAME     := FieldByName('WIP_ENTITY_NAME').AsString;
      //sAPPLY_TIME        := FieldByName('APPLY_TIME').AsString;
      sAPPLY_USER_ID       := FieldByName('APPLY_USER_ID').AsString;
      sAPPLY_USER_NAME     := FieldByName('APPLY_USER_NAME').AsString;
      sSeqID               := Fieldbyname('Seq_id').AsString;
      sFac                 := Fieldbyname('ORGANIZATION_ID').AsString;

      adoqrytemp.Close;
      adoqrytemp.SQL.Clear;
      adoqrytemp.SQL.Add('SELECT FACTORY_ID FROM SAJET.SYS_FACTORY WHERE ENABLED = ''Y'' AND ROWNUM = 1 and factory_code='+''''+sFac+'''');
      adoqrytemp.Open;
      if adoQrytemp.RecordCount>0 then
        sFacID:= adoqrytemp.fieldbyname('factory_id').AsString
      else sFacID:='';
      if trim(sFacID) = '' then
      begin
        LogException('SAJET.INTERFACE_RC_WIP_MASTER', FieldByName('iRow').AsString, 'Invalid ORG_ID');
        Next;
        Continue;
      end;

      try
        if CheckRcWipMasterExist(sDOCUMENT_NUMBER, sRCWipID) then
        begin
            LogException('SAJET.INTERFACE_RC_WIP_MASTER', FieldByName('iRow').AsString, 'DUB DOCUMENT_NUMBER ');
            Next;
            Continue;
        end
        else
        begin
          sRCWipID := GetMaxRCWipID;
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO SAJET.G_ERP_RC_WIP_MASTER '+
                    '(RC_WIP_ID,ISSUE_HEADER_ID,ISSUE_TYPE,ISSUE_TYPE_NAME,TYPE_CLASS,DOCUMENT_NUMBER,WIP_ENTITY_NAME, '+
                    '     APPLY_USER_ID,APPLY_USER_NAME,ORGANIZATION_ID,UPDATE_USERID) VALUES '+
                    '(:RC_WIP_ID,:ISSUE_HEADER_ID,:ISSUE_TYPE,:ISSUE_TYPE_NAME,:TYPE_CLASS,:DOCUMENT_NUMBER,:WIP_ENTITY_NAME, '+
                    '          :APPLY_USER_ID,:APPLY_USER_NAME,:ORGANIZATION_ID,:UPDATE_USERID) ');
            Parameters.ParamByName('RC_WIP_ID').Value := sRCWipID;
            Parameters.ParamByName('ISSUE_HEADER_ID').Value := sISSUE_HEADER_ID;
            Parameters.ParamByName('ISSUE_TYPE').Value := sISSUE_TYPE;
            Parameters.ParamByName('ISSUE_TYPE_NAME').Value := sISSUE_TYPE_NAME;
            Parameters.ParamByName('TYPE_CLASS').Value := sTYPE_CLASS;
            Parameters.ParamByName('DOCUMENT_NUMBER').Value := sDOCUMENT_NUMBER;
            Parameters.ParamByName('WIP_ENTITY_NAME').Value := sWIP_ENTITY_NAME;
            Parameters.ParamByName('APPLY_USER_ID').Value := sAPPLY_USER_ID;
            Parameters.ParamByName('APPLY_USER_NAME').Value := sAPPLY_USER_NAME;
            Parameters.ParamByName('ORGANIZATION_ID').Value := sFacID;
            Parameters.ParamByName('UPDATE_USERID').Value := '0';
            ExecSQL;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_RC_WIP_MASTER', FieldByName('iRow').AsString, 'RC_WIP Header Transfer Error');
        Next;
        Continue;

      end;


      if sSeqID<>'' then
      begin
        sResult:=UpdateErp('erp_to_mes_RC_WIP_MASTER@sfc2erp',sSeqID);
        if sResult<>'OK' then
        begin
           LogException('SAJET.INTERFACE_RC_WIP_MASTER', FieldByName('iRow').AsString, sResult);
           next;
           continue;
        end;
      end;

      LogComplete('SAJET.INTERFACE_RC_WIP_MASTER', FieldByName('iRow').AsString);
      {
      if sSeqID<>'' then
        UpdateErp('erp_to_mes_RT_MASTER@sfc2erp',sSeqID); }
      Inc(mI);
      LabCnt.Caption := InttoStr(mI);
      LabCnt.Refresh;
      Next;
    end;
    Close;
  end;
  ListBox1.Items.Add('RC_WIP Master - ' + IntToStr(mI) + ' Counts OK !!'+FormatDateTime('HH:MM:SS',Now));
  RemoveData('SAJET.INTERFACE_RC_WIP_MASTER', 'SAJET.INTERFACE_HT_RC_WIP_MASTER');
end;

procedure TTransfer.TransRcWipDetail;
var
  mI : Integer;
  sDOCUMENT_NUMBER,        //單據編碼
  SWIP_ENTITY_NAME,        //工單名稱
  sISSUE_HEADER_ID,        //申請單HEADER ID
  sISSUE_LINE_ID,          //申請單LINE ID (PK)
  sSEQ_NUMBER,             //LINE 序號
  //INVENTORY_ITEM_ID,      //料號ID
  //sITEM_NO,                //料號
  sSUBINVENTORY,           //申請倉庫
  //LOCATOR_ID,             //申請儲位ID
  sLOCATOR,                //申請儲位
  sAPPLY_QTY,              //申請數量
  sCHECK_CODE,             //檢核碼
  //sORGANIZATION_ID,        //組織ID
  sRCWipID,sPartNo, sPartID,sSeqID,sSFCLocateID,sFac,sFacID : String;
  sResult:string;
begin
  Application.ProcessMessages;
  sSeqID:='';
  with adoQrySelect do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT T.*, T.ROWID||'''' iRow FROM SAJET.INTERFACE_RC_WIP_DETAIL T '+
            ' WHERE T.TRANSFER_FLAG = ''N'' ORDER BY CREATION_DATE ');
    Open;
    First;
    mI := 0;
    while not Eof do
    begin
      sDOCUMENT_NUMBER       := FieldByName('DOCUMENT_NUMBER').AsString;
      sWIP_ENTITY_NAME       := FieldByName('WIP_ENTITY_NAME').AsString;
      sISSUE_HEADER_ID       := FieldByName('ISSUE_HEADER_ID').AsString;
      sISSUE_LINE_ID         := FieldByName('ISSUE_LINE_ID').AsString;
      sSEQ_NUMBER            := FieldByName('SEQ_NUMBER').AsString;
      //sITEM_NO             := FieldByName('ITEM_NO').AsString;
      sPartNo                := FieldByName('ITEM_NO').AsString;
      sSUBINVENTORY          := FieldByName('SUBINVENTORY').AsString;
      sLOCATOR               := Fieldbyname('LOCATOR').AsString;
      sAPPLY_QTY             := FieldByName('APPLY_QTY').AsString;
      sFac                   := FieldByName('ORGANIZATION_ID').AsString;
      sSeqID                 := Fieldbyname('Seq_id').AsString;

      adoqrytemp.Close;
      adoqrytemp.SQL.Clear;
      adoqrytemp.SQL.Add('SELECT FACTORY_ID FROM SAJET.SYS_FACTORY WHERE ENABLED = ''Y'' AND ROWNUM = 1 and factory_code='+''''+sFac+'''');
      adoqrytemp.Open;
      if adoQrytemp.RecordCount>0 then
        sFacID:= adoqrytemp.fieldbyname('factory_id').AsString
      else sFacID:='';
      if trim(sFacID) = '' then
      begin
        LogException('SAJET.INTERFACE_RC_WIP_DETAIL', FieldByName('iRow').AsString, 'Invalid ORG_ID');
        Next;
        Continue;
      end;

      if (Trim(sAPPLY_QTY) = '') or (Trim(sAPPLY_QTY) = '0') then
      begin
        LogException('SAJET.INTERFACE_RC_WIP_DETAIL', FieldByName('iRow').AsString, 'QTY = 0');
        Next;
        Continue;
      end;

      if not CheckPNExist(sPartNo, sPartID) then
      begin
        LogException('SAJET.INTERFACE_RC_WIP_DETAIL', FieldByName('iRow').AsString, 'Invalid Part No');
        Next;
        Continue;
      end;

      if not CheckRCWIPMASTERExist(sDOCUMENT_NUMBER, sRCWipID) then
      begin
        LogException('SAJET.INTERFACE_RC_WIP_DETAIL', FieldByName('iRow').AsString, 'RC_WIP Header Not Exist');
        Next;
        Continue;
      end;

      try
        sSFCLocateID := GetLocateID(sSUBINVENTORY, sLOCATOR);
        {
        if  sSFCLocateID = '0'  then
        begin
          LogException('SAJET.INTERFACE_RC_WIP_DETAIL', FieldByName('ROWID').AsString, 'Locate Not Exist');
          Next;
          Continue;
        end;
        }
      except
        LogException('SAJET.INTERFACE_RC_WIP_DETAIL', FieldByName('iRow').AsString, 'Locate Not Exist');
        Next;
        Continue;
      end;

      try
        if CheckRCWipDetailExist(sRCWipID, sISSUE_LINE_ID) then
        begin
          LogException('SAJET.INTERFACE_RC_WIP_DETAIL', FieldByName('iRow').AsString, 'DUB ISSUE_LINE_ID ');
          Next;
          Continue;
        end
        else
        begin
          with adoQryInst do
          begin
            Close;
            SQL.Clear;
            SQL.Add('INSERT INTO SAJET.G_ERP_RC_WIP_DETAIL '+
                    '(  RC_WIP_ID,WIP_ENTITY_NAME,ISSUE_HEADER_ID,ISSUE_LINE_ID,SEQ_NUMBER,PART_ID, '+
                    '  SUBINVENTORY,LOCATOR,SFC_LOCATOR_ID,APPLY_QTY,ORGANIZATION_ID,UPDATE_USERID) VALUES '+
                    '( :RC_WIP_ID,:WIP_ENTITY_NAME,:ISSUE_HEADER_ID,:ISSUE_LINE_ID,:SEQ_NUMBER,:PART_ID, '+
                    '  :SUBINVENTORY,:LOCATOR,:SFC_LOCATOR_ID,:APPLY_QTY,:ORGANIZATION_ID,:UPDATE_USERID) ');
            Parameters.ParamByName('RC_WIP_ID').Value := sRCWipID;
            Parameters.ParamByName('WIP_ENTITY_NAME').Value := sWIP_ENTITY_NAME;
            Parameters.ParamByName('ISSUE_HEADER_ID').Value := sISSUE_HEADER_ID;
            Parameters.ParamByName('ISSUE_LINE_ID').Value := sISSUE_LINE_ID;
            Parameters.ParamByName('SEQ_NUMBER').Value := SSEQ_NUMBER;
            Parameters.ParamByName('PART_ID').Value := sPartID;
            Parameters.ParamByName('SUBINVENTORY').Value := sSUBINVENTORY;
            Parameters.ParamByName('LOCATOR').Value :=sLOCATOR;
            Parameters.ParamByName('SFC_LOCATOR_ID').Value :=sSFCLocateID;
            Parameters.ParamByName('APPLY_QTY').Value := sAPPLY_QTY;
            Parameters.ParamByName('ORGANIZATION_ID').Value := sFacID;
            Parameters.ParamByname('UPDATE_USERID').Value := '0';
            ExecSQL;
          end;
        end;
      except
        LogException('SAJET.INTERFACE_RC_WIP_DETAIL', FieldByName('iRow').AsString, 'RC_WIP Detail Transfer Error');
        Next;
        Continue;
      end;

      if sSeqID<>'' then
      begin
        sResult:=UpdateErp('erp_to_mes_RC_WIP_Detail@sfc2erp',sSeqID);
        if sResult<>'OK' then
        begin
           LogException('SAJET.INTERFACE_RC_WIP_DETAIL', FieldByName('iRow').AsString, sResult);
           next;
           continue;
        end;
      end;

      LogComplete('SAJET.INTERFACE_RC_WIP_DETAIL', FieldByName('iRow').AsString);
      {
      if sSeqID<>'' then
        UpdateErp('erp_to_mes_RT_Detail@sfc2erp',sSeqID);  }
      Inc(mI);
      LabCnt.Caption := InttoStr(mI);
      LabCnt.Refresh;
      Next;
    end;
    Close;
  end;
  ListBox1.Items.Add('RT_WIP Detail - ' + IntToStr(mI) + ' Counts OK !!'+FormatDateTime('HH:MM:SS',Now));
  RemoveData('SAJET.INTERFACE_RC_WIP_DETAIL', 'SAJET.INTERFACE_HT_RC_WIP_DETAIL');
end;

function TTransfer.CheckVendorExist(psVendor : String; var psVendorId : String) : Boolean;
begin
  Result := False;
  psVendorId := '0';
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT VENDOR_ID '+
            'FROM   SAJET.SYS_VENDOR '+
            'WHERE  VENDOR_NAME = :VENDOR_NAME ');
    Parameters.ParamByName('VENDOR_NAME').Value := psVendor;
    Open;
    if RecordCount > 0 Then
    begin
      psVendorId := FieldByName('VENDOR_ID').AsString;
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckCustomerExist(psCustomer : String; var psCustomerId : String) : Boolean;
begin
  Result := False;
  psCustomerId := '0';
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT CUSTOMER_ID '+
            'FROM   SAJET.SYS_CUSTOMER '+
            'WHERE  CUSTOMER_NAME = :CUSTOMER_NAME ');
    Parameters.ParamByName('CUSTOMER_NAME').Value := psCustomer;
    Open;
    if RecordCount > 0 Then
    begin
      psCustomerId := FieldByName('CUSTOMER_ID').AsString;
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckRTExist(psRTNo : String; var psRTID : String) : Boolean;
begin
  Result := False;
  psRTID := '0';
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT RT_ID '+
            'FROM   SAJET.G_ERP_RTNO '+
            'WHERE  RT_NO = :RT_NO ');
    Parameters.ParamByName('RT_NO').Value := psRTNo;
    Open;
    if RecordCount > 0 Then
    begin
      psRTID := FieldByName('RT_ID').AsString;
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckRTDetailExist(psRTID, psSeq : String) : Boolean;
begin
  Result := False;
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT RT_ID '+
            '  FROM SAJET.G_ERP_RT_ITEM  '+
            ' WHERE RT_ID = :RT_ID '+
            '   AND RT_SEQ = :RT_SEQ ');
    Parameters.ParamByName('RT_ID').Value := psRTID;
    Parameters.ParamByName('RT_SEQ').Value := psSeq;
    Open;
    if RecordCount > 0 Then
    begin
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckDNExist(psDNNo : String; var psDNID : String) : Boolean;
begin
  Result := False;
  psDNID := '0';
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT DN_ID '+
            'FROM   SAJET.G_DN_BASE '+
            'WHERE  DN_NO = :DN_NO ');
    Parameters.ParamByName('DN_NO').Value := psDNNo;
    Open;
    if RecordCount > 0 Then
    begin
      psDNID := FieldByName('DN_ID').AsString;
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckDNDetailExist(psDNID, psDNItem : String) : Boolean;
begin
  Result := False;
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT DN_ID '+
            '  FROM SAJET.G_DN_DETAIL '+
            ' WHERE DN_ID = :DN_ID )'+
            '   AND DN_ITEM = :DN_ITEM ');
    Parameters.ParamByName('DN_ID').Value := psDNID;
    Parameters.ParamByName('DN_ITEM').Value := psDNItem;
    Open;
    if RecordCount > 0 Then
    begin
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckPNExist(psPartNo : String; var psPartId : String) : Boolean;
begin
  Result := False;
  psPartId := '0';
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT PART_ID '+
            'FROM   SAJET.SYS_PART '+
            'WHERE  PART_NO = :PART_NO ');
    Parameters.ParamByName('PART_NO').Value := psPartNo;
    Open;
    if RecordCount > 0 Then
    begin
      psPartId := FieldByName('PART_ID').AsString;
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckWOExist(psWONo : String; var psWOStatus : String) : Boolean;
begin
  Result := False;
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT WORK_ORDER, WO_STATUS '+
              'FROM SAJET.G_WO_BASE '+
             'WHERE WORK_ORDER = :WO ');
    Parameters.ParamByName('WO').Value := psWONo;
    Open;
    if RecordCount > 0 then
    begin
      psWOStatus := FieldByName('WO_STATUS').AsString;
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckWOItemExist(psWONo, psPartID : String) : Boolean;
begin
  Result := False;
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT REQUEST_QTY '+
            '  FROM SAJET.G_WO_PICK_LIST '+
            ' WHERE WORK_ORDER = :WORK_ORDER AND PART_ID = :PART_ID ');
    Parameters.ParamByName('WORK_ORDER').Value := psWONo;
    Parameters.ParamByName('PART_ID').Value := psPartID;
    Open;
    if RecordCount > 0 then
    begin
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckBOMPNExist(psBOMID, psItemID : String) : Boolean;
begin
  Result := False;
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT ITEM_GROUP '+
            '  FROM SAJET.SYS_BOM '+
            ' WHERE BOM_ID = :BOM_ID '+
            '   AND ITEM_PART_ID = :ITEM_PART_ID ');
    Parameters.ParamByName('BOM_ID').Value := psBOMID;
    Parameters.ParamByName('ITEM_PART_ID').Value := psItemID;
    Open;
    if RecordCount > 0 then
    begin
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckBOMExist(psPartID, psPartVer : String; var psBOMID : String) : Boolean;
begin
  Result := False;
  psBOMID := '0';
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT BOM_ID '+
            '  FROM SAJET.SYS_BOM_INFO '+
            ' WHERE PART_ID = :PART_ID AND VERSION = :VERSION ');
    Parameters.ParamByName('PART_ID').Value := psPartID;
    Parameters.ParamByName('VERSION').Value := psPartVer;
    Open;
    if RecordCount > 0 Then
    begin
      psBOMID := FieldByName('BOM_ID').AsString;
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckRcMisMasterExist(psRcMisDN : String; var psRCMISID : String) : Boolean;
begin
  Result := False;
  psRCMISID := '0';
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT RC_MIS_ID '+
            'FROM   SAJET.G_ERP_RC_MIS_MASTER '+
            'WHERE  DOCUMENT_NUMBER = :RC_MIS_DN ');
    Parameters.ParamByName('RC_MIS_DN').Value := psRcMisDN;
    Open;
    if RecordCount > 0 Then
    begin
      psRCMISID := FieldByName('RC_MIS_ID').AsString;
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckRcMisDetailExist(psRCMISID, psISSUELINEID : String) : Boolean;
begin
  Result := False;
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT RC_MIS_ID '+
            '  FROM SAJET.G_ERP_RC_MIS_DETAIL  '+
            ' WHERE RC_MIS_ID = :RC_MIS_ID '+
            '   AND ISSUE_LINE_ID = :ISSUE_LINE_ID ');
    Parameters.ParamByName('RC_MIS_ID').Value := psRCMISID;
    Parameters.ParamByName('ISSUE_LINE_ID').Value := psISSUELINEID;
    Open;
    if RecordCount > 0 Then
    begin
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckRcTransferMasterExist(psRcTransferDN : String; var psRCTransferID : String) : Boolean;
begin
  Result := False;
  psRCTransferID := '0';
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT RC_Transfer_ID '+
            'FROM   SAJET.G_ERP_RC_Transfer_MASTER '+
            'WHERE  DOCUMENT_NUMBER = :RC_Transfer_DN ');
    Parameters.ParamByName('RC_Transfer_DN').Value := psRcTransferDN;
    Open;
    if RecordCount > 0 Then
    begin
      psRCTransferID := FieldByName('RC_Transfer_ID').AsString;
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckRcTransferDetailExist(psRCTransferID, psISSUELINEID : String) : Boolean;
begin
  Result := False;
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT RC_Transfer_ID '+
            '  FROM SAJET.G_ERP_RC_Transfer_DETAIL  '+
            ' WHERE RC_Transfer_ID = :RC_Transfer_ID '+
            '   AND ISSUE_LINE_ID = :ISSUE_LINE_ID ');
    Parameters.ParamByName('RC_Transfer_ID').Value := psRCTransferID;
    Parameters.ParamByName('ISSUE_LINE_ID').Value := psISSUELINEID;
    Open;
    if RecordCount > 0 Then
    begin
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckRcWipMasterExist(psRcWipDN : String; var psRCWipID : String) : Boolean;
begin
  Result := False;
  psRCWipID := '0';
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT RC_WIP_ID '+
            'FROM   SAJET.G_ERP_RC_WIP_MASTER '+
            'WHERE  DOCUMENT_NUMBER = :RC_WIP_DN ');
    Parameters.ParamByName('RC_Wip_DN').Value := psRcWipDN;
    Open;
    if RecordCount > 0 Then
    begin
      psRCWipID := FieldByName('RC_Wip_ID').AsString;
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.CheckRcWipDetailExist(psRCWipID, psISSUELINEID : String) : Boolean;
begin
  Result := False;
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT RC_Wip_ID '+
            '  FROM SAJET.G_ERP_RC_Wip_DETAIL  '+
            ' WHERE RC_Wip_ID = :RC_Wip_ID '+
            '   AND ISSUE_LINE_ID = :ISSUE_LINE_ID ');
    Parameters.ParamByName('RC_Wip_ID').Value := psRCWipID;
    Parameters.ParamByName('ISSUE_LINE_ID').Value := psISSUELINEID;
    Open;
    if RecordCount > 0 Then
    begin
      Result := True;
    end;
    Close;
  end;
end;

function TTransfer.GetRouteID(psRouteName : String) : String;
begin
  Result := '0';
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT ROUTE_ID '+
            '  FROM SAJET.SYS_ROUTE '+
            ' WHERE ROUTE_NAME = :ROUTE_NAME ');
    Parameters.ParamByName('ROUTE_NAME').Value := psRouteName;
    Open;
    if RecordCount > 0 Then
    begin
      Result := FieldByName('ROUTE_ID').AsString;
    end;
    Close;
  end;
end;

function TTransfer.GetLocateID(psWarehouse, psLocate : String) : String;
begin
  Result := '0';
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT A.LOCATE_ID '+
            '  FROM SAJET.SYS_LOCATE A, SAJET.SYS_WAREHOUSE B '+
            ' WHERE NVL(A.LOCATE_NAME,''N/A'') = :LOCATE_NAME '+
            '   AND B.WAREHOUSE_NAME = :WAREHOUSE_NAME '+
            '   AND A.WAREHOUSE_ID = B.WAREHOUSE_ID '+
            '   AND A.ENABLED = ''Y'' '+
            '   AND A.ENABLED = ''Y'' ');
    if psLocate <> '' then
       Parameters.ParamByName('LOCATE_NAME').Value := psLocate
    else
       Parameters.ParamByName('LOCATE_NAME').Value := 'N/A';
    Parameters.ParamByName('WAREHOUSE_NAME').Value := psWarehouse;
    Open;
    if RecordCount > 0 Then
    begin
      Result := FieldByName('LOCATE_ID').AsString;
    end;
    Close;
  end;
end;

function TTransfer.GetMaxPartID : String;
begin
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT NVL(MAX(PART_ID), 0) + 1 PARTID '+
              'FROM SAJET.SYS_PART ');
    Open;
    if FieldByName('PARTID').AsString = '1' Then
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT RPAD(NVL(PARAM_VALUE,''1''), 2, ''0'') || ''00000001'' PARTID '+
                'FROM SAJET.SYS_BASE '+
               'WHERE PARAM_NAME = ''DBID'' ' );
      Open;
    end;
    Result := FieldByName('PARTID').AsString;
    Close;
  end;
end;

function TTransfer.GetMaxBOMID : String;
begin
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT NVL(MAX(BOM_ID), 0) + 1 BOMID '+
              'FROM SAJET.SYS_BOM_INFO ');
    Open;
    if FieldByName('BOMID').AsString = '1' Then
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT RPAD(NVL(PARAM_VALUE,''1''), 2, ''0'') || ''00000001'' BOMID '+
                'FROM SAJET.SYS_BASE '+
               'WHERE PARAM_NAME = ''DBID'' ' );
      Open;
    end;
    Result := FieldByName('BOMID').AsString;
    Close;
  end;
end;

function TTransfer.GetMaxRTID : String;
begin
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT NVL(MAX(RT_ID), 0) + 1 RTID '+
              'FROM SAJET.G_ERP_RTNO ');
    Open;
    if FieldByName('RTID').AsString = '1' Then
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT RPAD(NVL(PARAM_VALUE,''1''), 2, ''0'') || ''00000001'' RTID '+
                'FROM SAJET.SYS_BASE '+
               'WHERE PARAM_NAME = ''DBID'' ' );
      Open;
    end;
    Result := FieldByName('RTID').AsString;
    Close;
  end;
end;

function TTransfer.GetMaxDNID : String;
begin
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT NVL(MAX(DN_ID), 0) + 1 DNID '+
              'FROM SAJET.G_DN_BASE ');
    Open;
    if FieldByName('DNID').AsString = '1' Then
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT RPAD(NVL(PARAM_VALUE,''1''), 2, ''0'') || ''00000001'' DNID '+
                'FROM SAJET.SYS_BASE '+
               'WHERE PARAM_NAME = ''DBID'' ' );
      Open;
    end;
    Result := FieldByName('DNID').AsString;
    Close;
  end;
end;

function TTransfer.GetMaxVendorID : String;
begin
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT NVL(MAX(VENDOR_ID), 0) + 1 VENDORID '+
              'FROM SAJET.SYS_VENDOR ');
    Open;
    if FieldByName('VENDORID').AsString = '1' Then
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT RPAD(NVL(PARAM_VALUE,''1''), 2, ''0'') || ''00000001'' VENDORID '+
                'FROM SAJET.SYS_BASE '+
               'WHERE PARAM_NAME = ''DBID'' ' );
      Open;
    end;
    Result := FieldByName('VENDORID').AsString;
    Close;
  end;
end;

function TTransfer.GetMaxCustID : String;
begin
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT NVL(MAX(CUSTOMER_ID), 0) + 1 CUSTOMERID '+
              'FROM SAJET.SYS_CUSTOMER ');
    Open;
    if FieldByName('CUSTOMERID').AsString = '1' Then
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT RPAD(NVL(PARAM_VALUE,''1''), 2, ''0'') || ''00000001'' CUSTOMERID '+
                'FROM SAJET.SYS_BASE '+
               'WHERE PARAM_NAME = ''DBID'' ' );
      Open;
    end;
    Result := FieldByName('CUSTOMERID').AsString;
    Close;
  end;
end;

function TTransfer.GetMaxRcMisID : String;
begin
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT NVL(MAX(RC_MIS_ID), 0) + 1 RCMISID '+
              'FROM SAJET.G_ERP_RC_MIS_MASTER ');
    Open;
    if FieldByName('RCMISID').AsString = '1' Then
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT RPAD(NVL(PARAM_VALUE,''1''), 2, ''0'') || ''00000001'' RCMISID '+
                'FROM SAJET.SYS_BASE '+
               'WHERE PARAM_NAME = ''DBID'' ' );
      Open;
    end;
    Result := FieldByName('RCMISID').AsString;
    Close;
  end;
end;

function TTransfer.GetMaxRcTransferID : String;
begin
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT NVL(MAX(RC_TRANSFER_ID), 0) + 1 RCTRANSFERID '+
              'FROM SAJET.G_ERP_RC_TRANSFER_MASTER ');
    Open;
    if FieldByName('RCTRANSFERID').AsString = '1' Then
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT RPAD(NVL(PARAM_VALUE,''1''), 2, ''0'') || ''00000001'' RCTRANSFERID '+
                'FROM SAJET.SYS_BASE '+
               'WHERE PARAM_NAME = ''DBID'' ' );
      Open;
    end;
    Result := FieldByName('RCTRANSFERID').AsString;
    Close;
  end;
end;

function TTransfer.GetMaxRcWipID : String;
begin
  with adoQryTemp do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT NVL(MAX(RC_WIP_ID), 0) + 1 RCWIPID '+
              'FROM SAJET.G_ERP_RC_WIP_MASTER ');
    Open;
    if FieldByName('RCWIPID').AsString = '1' Then
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT RPAD(NVL(PARAM_VALUE,''1''), 2, ''0'') || ''00000001'' RCWIPID '+
                'FROM SAJET.SYS_BASE '+
               'WHERE PARAM_NAME = ''DBID'' ' );
      Open;
    end;
    Result := FieldByName('RCWIPID').AsString;
    Close;
  end;
end;

function TTransfer.ConnectDb:Boolean;
var sConnStr:string;
begin
   result :=False;
  try
     sConnStr:='(DESCRIPTION = '+
        ' (ADDRESS_LIST =  '+
        ' (ADDRESS = (PROTOCOL = TCP)(HOST = '+sIP+')(PORT = '+sPort+')) '+
        '  )   '+
        ' (CONNECT_DATA = '+
        ' (SERVICE_NAME = '+sSID+')'+
        ' ) '+
        ' )';
     AdoCon1.Close;
     AdoCon1.ConnectionString :='Provider=MSDAORA.1;Password='+sPwd+';User ID='+sUserName+';Persist Security Info=true;Data Source="'+sConnStr+'"';
     AdoCon1.Connected :=True;
     result :=True;
  except
     ShowMessage('Database Can''t Connect !!');
     Application.Terminate;
  end;
end;

procedure TTransfer.Button1Click(Sender: TObject);
begin
{  Timer1.Enabled := False;
  ConnectDb;

  StatusBar.SimpleText := 'Transfer Data !!';
  TransferData;

  AdoCon1.Connected := False;

  // Allen Add
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    SetProcessWorkingSetSize(GetCurrentProcess, $FFFFFFFF, $FFFFFFFF) ;
    Sleep(100) ;
  end;

  Timer1.Enabled := True;
  Label2.Caption := DateTimetoStr(now);
  }
  Timer1Timer(Sender);
end;

procedure TTransfer.Show1Click(Sender: TObject);
begin
  CoolTrayIcon1.ShowMainForm;
end;

procedure TTransfer.CoolTrayIcon1DblClick(Sender: TObject);
begin
  CoolTrayIcon1.ShowMainForm;
end;

procedure TTransfer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   //Action :=caNone;
   //CoolTrayIcon1.HideMainForm;
end;

end.
