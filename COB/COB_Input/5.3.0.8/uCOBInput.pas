unit uCOBInput;
                                           
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles;

type
  TfCOBInput = class(TForm)
    ImageAll: TImage;
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
    QryTemp1: TClientDataSet;
    lbldata: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    editWO: TEdit;
    editTray: TEdit;
    editPanel: TEdit;
    DBGrid1: TDBGrid;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    labSNCount: TLabel;
    labWO: TLabel;
    labTray: TLabel;
    Label1: TLabel;
    labPartNo: TLabel;
    labTargetQty: TLabel;
    labInputQty: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label4: TLabel;
    labPWO: TLabel;
    miScrap: TMenuItem;
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure editDataKeyPress(Sender: TObject; var Key: Char);
    procedure Cancel1Click(Sender: TObject);
    procedure ClearAll1Click(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure editWOKeyPress(Sender: TObject; var Key: Char);
    procedure editTrayKeyPress(Sender: TObject; var Key: Char);
    procedure editPanelKeyPress(Sender: TObject; var Key: Char);
    procedure labWODblClick(Sender: TObject);
    procedure labTrayDblClick(Sender: TObject);
    procedure miScrapClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
  private
    //m_SNDefectLevel: String;
    procedure clearData;
    procedure getWHINNo;
    procedure getWHINDetail(WHINno :String);
    function GetWHID(WHCODE :string) :string;

    function CheckWO(sWO:string):string;
    function CheckTray(sWO,sTray:string;TraySNCount:Integer):string;
    function CheckPanel(sTerminal,sEmp,sWO,sTray,sTraySNCount,sPanel:string):string;

    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);

    function GetTerminalName(sTerminalID:string):string;


    function GetPartID(partno :String) :String;
    procedure ShowData(sWO,sTray :String);
  public
    UpdateUserID : String;
    Authoritys,AuthorityRole,FunctionName : String;
    //Language : TLanguage;
    procedure SetStatusbyAuthority;
    Function LoadApServer : Boolean;
  end;

var
  fCOBInput: TfCOBInput;
  flag:Boolean;
  emess:string;
  gWO,gTrayNO:string;
  iTraySNCount,iSNCount:Integer;
  iTerminal:string;

implementation

uses uformLotMemo;


{$R *.dfm}



function TfCOBInput.GetWHID(WHCODE :string) :string;
begin
   with Qrytemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'WHCODE',ptInput);
      CommandText :='select WH_ID from sajet.sys_wh_warehouse where WH_CODE = :WHCODE  AND ROWNUM=1 ';
      Params.ParamByName('WHCODE').AsString :=WHCODE;
      Open;
      if RecordCount > 0 then
         Result := Fieldbyname('WH_ID').AsString
      else
         Result :='';
   end;
end;

function TfCOBInput.CheckWO(sWO:string):string;
begin
try
  Result := 'Check WO Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.Sj_Chk_Wo_Input');
      FetchParams;
      Params.ParamByName('TREV').AsString := sWO;
      Execute;
      Result := Params.ParamByName('TRES').AsString;
    finally
      Close;
    end;
  end;
except on e:Exception do
  begin
    Result := 'CheckWO error : ' + e.Message;
  end;
end;
end;

function TfCOBInput.CheckTray(sWO,sTray:string;TraySNCount:Integer):string;
begin
try
  Result := 'Check Tray Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.Sj_Chk_Tray');
      FetchParams;
      Params.ParamByName('TWO').AsString := sWO ;
      Params.ParamByName('TREV').AsString := sTray;
      Params.ParamByName('TREVCount').AsString := IntToStr(TraySNCount);
      Execute;
      Result := Params.ParamByName('TRES').AsString;
    finally
      Close;
    end;
  end;
except on e:Exception do
  begin
    Result := 'CheckTray error : ' + e.Message;
  end;
end;
end;

function TfCOBInput.CheckPanel(sTerminal,sEmp,sWO,sTray,sTraySNCount,sPanel:string):string;
begin
  try
  Result := 'Check Panel Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.Sj_Chk_Tray_Panel');
      FetchParams;
      Params.ParamByName('TTERMINAL').AsString := sTerminal;
      Params.ParamByName('TEMP').AsString := sEmp;
      Params.ParamByName('TWO').AsString := sWO ;
      Params.ParamByName('TTRAY').AsString := sTray;
      Params.ParamByName('TTRAYCOUNT').AsString := sTraySNCount;
      Params.ParamByName('TREV').AsString := sPanel;
      Execute;
      Result := Params.ParamByName('TRES').AsString;
    finally
      Close;
    end;
  end;
except on e:Exception do
  begin
    Result := 'CheckPanel error : ' + e.Message;
  end;
end;
end;

function TfCOBInput.GetTerminalName(sTerminalID:string):string;
var sPdline,sProcess,sTerminal:string;
begin
try
  with Qrytemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'TerminalID',ptInput);
      CommandText :='select a.pdline_name,b.process_name,c.terminal_name,c.terminal_id  ' +
                    '  from sajet.sys_pdline a,sajet.sys_process b,sajet.sys_terminal c '+
                    'where c.terminal_id = :TerminalID  '+
                    '  and a.pdline_id=c.pdline_id '+
                    '  and b.process_id=c.process_id';

      Params.ParamByName('TerminalID').AsString :=sTerminalID;
      Open;
      if RecordCount > 0 then
      begin
         sPdline := Fieldbyname('pdline_name').AsString  ;
         sProcess:= Fieldbyname('process_name').AsString  ;
         sTerminal:= Fieldbyname('terminal_name').AsString  ;
         Result := sPdline + ' \ ' + sProcess + ' \ ' + sTerminal ;
      end   
      else
         Result :='No Terminal information!';
   end;
Except   on e:Exception do
   Result := 'Get Terminal : ' + e.Message;

end;
end;

procedure TfCOBInput.ShowMSG(sShowHead,sShowResult,sNextMsg:string);
var sShowData:string;
begin
  if sShowResult = 'OK' then
  begin
    msgPanel.Color := clGreen;
  end
  else
  begin
    msgPanel.Color := clRed;
  end;
  sShowData := sShowHead + ' ' +  sShowResult;
  if sNextMsg <> '' then
  begin
    sShowData := sShowData + '  =>  ' + sNextMsg;
  end;
  msgPanel.Caption := sShowData;
end;

function TfCOBInput.GetPartID(partno :String) :String;
begin
    with Qrytemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'PARTNO',ptInput);
        CommandText :='SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO= :PARTNO AND ENABLED=''Y'' AND ROWNUM=1 ' ;
        Params.ParamByName('PARTNO').AsString := partno;
        Open;
        if Recordcount = 0 then
            Result :=''
        else
            Result := FieldbyName('PART_ID').AsString;
    end;
end;

procedure TfCOBInput.ShowData(sWO,sTray :String);
var iqty : Integer;
begin
    iqty := 0 ;
    With QryData do
    begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'WO',ptInput);
       Params.CreateParam(ftString,'TRAYNO',ptInput);
       CommandText := 'SELECT A.WORK_ORDER,A.BOX_NO,A.serial_number,A.in_process_time '+
                      '  FROM SAJET.g_sn_status A '+
                      ' WHERE A.WORK_ORDER = :WO '+
                      '   AND A.Box_NO= :TRAYNO '+
                      ' AND A.WORK_FLAG=''0'' '+     //只显示正常过站的，报废的不显示  add by phoenix 2013-5-7
                     ' ORDER BY A.in_process_time desc';
     Params.ParamByName('WO').AsString := sWO;
     Params.ParamByName('TRAYNO').AsString := sTray;
     Open;
     iSNCount := RecordCount ;
     labSNCount.Caption := IntToStr(iSNCount) + ' / ' + IntToStr(iTraySNCount);
    end;
end;

procedure TfCOBInput.FormShow(Sender: TObject);
Var DestRect,SurcRect : TRect; Bmp : TBitmap;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;

  Bmp.Free;

  LoadApServer;
  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;

  editWO.SetFocus;
  editWO.Text := '';
  LabTerminal.Caption := LabTerminal.Caption + '    ' + GetTerminalName(iTerminal);
  labWO.Caption := '';
  labTray.Caption := '';
  labSNCount.Caption := '';
  //ShowMessage(IntToStr(iTraySNCount));
end;

procedure TfCOBInput.clearData;
begin
end;

procedure TfCOBInput.getWHINDetail(WHINno :String);
var sSQL : String;
begin
 sSQL := ' SELECT DISTINCT B.PART_NO  '+
         ' FROM SAJET.G_WH_WHIN_LIST A,'+
         '      SAJET.SYS_PART B '+
         ' WHERE A.ITEM_PART_ID=B.PART_ID '+
         ' AND A.STATUS =''0'' '+
         ' AND A.WHIN_LIST_NO = :WHINNO '+
         ' ORDER BY B.PART_NO ';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString,'WHINNO',ptInput);
    CommandText := sSQL;
    Params.ParamByName('WHINNO').AsString := trim(WHINno);
    Open;
    Close;
  end;
end;

procedure TfCOBInput.getWHINNo;
var sSRtNo:string;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText :=  ' SELECT DISTINCT A.ORDER_NO  '+
                    ' FROM SAJET.G_WH_LIST A  '+
                    ' WHERE A.LIST_TYPE=''WHIN'' '+
                    ' AND A.STATUS <=''1'' '+
                    ' ORDER BY A.ORDER_NO ' ;
    Open;
    while not Eof do
    begin
      Next;
    end;
    Close;
  end;
end;

Procedure TfCOBInput.SetStatusbyAuthority;
begin
  // Read Only,Allow To Change,Full Control
  Authoritys := '';
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'EMP_ID', ptInput);
    Params.CreateParam(ftString	,'PRG', ptInput);
    Params.CreateParam(ftString	,'FUN', ptInput);
    CommandText := 'Select AUTHORITYS '+
                   'From  SAJET.SYS_EMP_PRIVILEGE '+
                   'Where EMP_ID = :EMP_ID and '+
                         'PROGRAM = :PRG and '+
                         'FUNCTION = :FUN ';
    Params.ParamByName('EMP_ID').AsString := UpdateUserID;
    Params.ParamByName('PRG').AsString := 'COB';
    Params.ParamByName('FUN').AsString := 'COB INPUT';
    Open;
    If RecordCount > 0 Then
      Authoritys := Fieldbyname('AUTHORITYS').AsString;
    Close;
  end;

  //sbtnSave.Enabled := ((Authoritys = 'Allow To Execute') or (Authoritys = 'Full Control'));
  miScrap.Enabled := (Authoritys = 'Full Control');
  
  if Authoritys = '' then
  begin
    AuthorityRole := '';
    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'EMP_ID', ptInput);
      Params.CreateParam(ftString	,'PRG', ptInput);
      Params.CreateParam(ftString	,'FUN', ptInput);
      CommandText := 'Select AUTHORITYS '+
                     //'From LOT.SYS_ROLE_PRIVILEGE A, '+
                     'From SAJET.SYS_ROLE_PRIVILEGE A, '+
                          'SAJET.SYS_ROLE_EMP B '+
                     'Where A.ROLE_ID = B.ROLE_ID and '+
                           'EMP_ID = :EMP_ID and '+
                           'PROGRAM = :PRG and '+
                           'FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'COB';//'Quality Control';
      Params.ParamByName('FUN').AsString := 'COB INPUT';
      Open;
      If RecordCount > 0 Then
        AuthorityRole := Fieldbyname('AUTHORITYS').AsString;
      Close;
    end;
    //sbtnSave.Enabled := ((AuthorityRole = 'Allow To Execute') or (AuthorityRole = 'Full Control'));
    miScrap.Enabled := (AuthorityRole = 'Full Control');
    if miScrap.Enabled then
      miScrap.Tag := 0
    else
      miScrap.Tag := 1;
  end;


end;


Function TfCOBInput.LoadApServer : Boolean;
Var F : TextFile;
    S : String;
begin
  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  If not FileExists(GetCurrentDir+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,GetCurrentDir+'\ApServer.cfg');
  Reset(F);
  While True do
  begin
    Readln(F, S);
    If S <> '' Then
    begin
      SimpleObjectBroker1.Servers.Add;
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
    end Else
      Break;
  end;
  CloseFile(F);
  Result := True;
end;

procedure TfCOBInput.Image2Click(Sender: TObject);
begin
   Close;
end;

procedure TfCOBInput.editDataKeyPress(Sender: TObject; var Key: Char);
var sWHINNO,sPARTNO,stype,sWHID : String;
    iMaxQty,iQty,iallQty :Integer;
begin
    if key =#13 then
    begin

       with QryTemp do
       begin
       try
        //insert
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WHINNO',ptInput);
        Params.CreateParam(ftString,'REELNO',ptInput);
        Params.CreateParam(ftString,'EMPID',ptInput);
        Params.CreateParam(ftString,'WHID',ptInput);
        CommandText := 'INSERT INTO SAJET.G_REEL_WH_IN_TEMP  '+
                       ' (ORDER_NO,PART_ID,REEL_NO,REEL_QTY,WH_ID,PALLET_NO,CARTON_NO,EMP_ID) '+
                       ' SELECT :WHINNO,MODEL_ID,SERIAL_NUMBER,1,:WHID,PALLET_NO,CARTON_NO,:EMPID '+
                       ' FROM SAJET.G_SN_STATUS '+
                       ' WHERE  ';
        if stype = 'Pallet' then
           CommandText := CommandText +' PALLET_NO = :REELNO ';
        if stype = 'Carton' then
           CommandText := CommandText +' CARTON_NO = :REELNO ';
        if stype = 'SN' then
           CommandText := CommandText +' SERIAL_NUMBER = :REELNO ';

        Params.ParamByName('WHINNO').AsString := sWHINNO;
        Params.ParamByName('EMPID').AsString := UpdateUserID;
        Params.ParamByName('WHID').AsString := sWHID;
        Execute;
      Except
       Exit;
     end;
     end;
       ShowData(sWHINNO,sPartNO);
    end;
end;


procedure TfCOBInput.Cancel1Click(Sender: TObject);
var sReelNO : string;
begin
   with QryTemp do
       begin
       try
        //insert
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'REELNO',ptInput);
        CommandText := 'DELETE FROM  SAJET.G_REEL_WH_IN_TEMP  '+
                       ' WHERE REEL_NO = :REELNO ';
        Params.ParamByName('REELNO').AsString := sReelNO;
        Execute;
      Except
       Exit;
     end;
   end;
end;

procedure TfCOBInput.ClearAll1Click(Sender: TObject);
var sPartID :string;
begin
   with QryTemp do
       begin
       try
        //insert
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'RETURNNO',ptInput);
        Params.CreateParam(ftString,'PARTID',ptInput);
        CommandText := 'DELETE FROM  SAJET.G_REEL_WH_IN_TEMP  '+
                       ' WHERE ORDER_NO = :RETURNNO '+
                       ' AND PART_ID = :PARTID ';
        Params.ParamByName('PARTID').AsString :=sPartID;
        Execute;
      Except
       Exit;
     end;
   end;
end;

procedure TfCOBInput.sbtnSaveClick(Sender: TObject);
var smemo : string;
begin

   formLotMemo := TformLotMemo.Create(self);
   with formLotMemo do
   begin
     try
       if showmodal<>mrOK then exit;
            //smemo :=editLotMemo.Text;
     finally
       free;
     end;
   end;
   with SProc do
   begin
      try
        Close;
        DataRequest('SAJET.sj_WHIN_SAVE');
        FetchParams;
        Params.ParamByName('TEMPID').AsString := UpdateUserID;
        Execute;
        if Params.ParamByName('TRES').AsString <>'OK' then
        begin
          //MessageDlg(Language.TranslationTextDef(Params.ParamByName('TRES').AsString),mtError,[mbOK],0);
          exit;
        end;
      finally
        Close;
      end;
    end;
end;

procedure TfCOBInput.editWOKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
  if Key = #13 then
  begin
    if iTerminal = '' then
    begin
      MessageDlg('please input Terminal information!',mtError,[mbOK],0);
      Exit;
    end;

    iResult := CheckWO(Trim(editWO.Text));

    if iResult = 'OK' then
    begin
      //从工单带出料号,目标量,投入量等值  add by phoenix    2013-05-02
      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WO',ptInput);
        CommandText := 'Select P.PART_NO,TARGET_QTY,INPUT_QTY FROM  SAJET.G_WO_BASE W'
                     + ' Left outer join SAJET.SYS_PART P ON W.MODEL_ID=P.PART_ID '
                     + ' WHERE W.WORK_ORDER = :WO';
        Params.ParamByName('WO').AsString := Trim(editWO.Text);
        Open;

        labPartNo.Caption := FieldByName('PART_NO').AsString;
        labTargetQty.Caption := FieldByName('TARGET_QTY').AsString;
        labInputQty.Caption := FieldByName('INPUT_QTY').AsString;
      end;

      ShowMSG('Work Order input : ',iResult,'Please input Tray No!');
      editTray.Enabled := True;
      editTray.SetFocus;
      editTray.Text := '';
      editPanel.Text := '';
      gWO := Trim(editWO.Text);
      gTrayNO := '';
      labWO.Caption := gWO;
      labTray.Caption := '';
      ShowData(gWO,gTrayNO);
      editWO.Enabled := False;
    end
    else
    begin
      ShowMSG('Work Order input : ',iResult,'Please input Work order again!');
      editWO.SelectAll;
      editWO.SetFocus;
      
    end;
  end;
end;

procedure TfCOBInput.editTrayKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
  if Key = #13 then
  begin
    if gWO = '' then
    begin
      editWO.Enabled := True;;
      editWO.SetFocus;
      editWO.Text := '';
      editTray.Text := '';
      Exit;
    end;
    iResult := CheckTray(gWO,Trim(editTray.Text),iTraySNCount);

    if iResult = 'OK' then
    begin
      ShowMSG('Tray No input : ',iResult,'Please input Panel No!');
      editPanel.Enabled := True;
      //editPanel.ReadOnly := False;
      editPanel.SetFocus;
      editPanel.Text := '';
      gTrayNO := Trim(editTray.Text);
      editTray.Enabled := False;
    end
    else
    begin
      ShowMSG('Tray No input : ',iResult,'Please input Tray again!');
      editPanel.Enabled := False;
      editTray.SelectAll;
      editTray.SetFocus;
      gTrayNO := Trim(editTray.Text); //'';
    end;
    ShowData(gWO,gTrayNO);
    labTray.Caption := gTrayNO;
  end;
end;

procedure TfCOBInput.editPanelKeyPress(Sender: TObject; var Key: Char);
var
  iResult:string;
  PassCount: integer;
begin
  if Key = #13 then
  begin
    if gWO = '' then
    begin
      editWO.Enabled := True;
      editWO.SetFocus;
      editWO.Text := '';
      editTray.Enabled := True;
      editTray.Text := '';
      Exit;
    end;
    if gTrayNO = '' then
    begin
      editTray.Enabled := True;
      editTray.SetFocus;
      editTray.Text := '';
      editPanel.Text := '';
      Exit;
    end;

    //从状态表查出正常过站的Panel的数量  add by phoenix  2013-05-07
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'Panel_NO',ptInput);
      CommandText := 'Select COUNT(WORK_ORDER)PassCount FROM  SAJET.G_SN_STATUS '
                   + ' WHERE BOX_NO = :Panel_NO'
                   + ' AND WORK_FLAG=''0''';
      Params.ParamByName('Panel_NO').AsString := Trim(editPanel.Text);
      Open;

      PassCount := FieldByName('PassCount').AsInteger;
    end;

    //检查工单投入量大于目标量时,不让继续输入Panel号   add by phoenix  2013-5-6
    if StrtoInt(labInputQty.Caption) + PassCount > StrToInt(labTargetQty.Caption) then
    begin
      ShowMSG('Panel No input : ','Error','InputQty + PanelQty > TargetQty!');                       
      editWO.Enabled := True;
      editWO.SetFocus;
      editWO.SelectAll;
      Abort;
    end;

    //从状态表带出Panel的工单  add by phoenix  2013-05-02
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'Panel_NO',ptInput);
      CommandText := 'Select DISTINCT WORK_ORDER FROM  SAJET.G_SN_STATUS '+
                     ' WHERE BOX_NO = :Panel_NO';
      Params.ParamByName('Panel_NO').AsString := Trim(editPanel.Text);
      Open;

      labPWO.Caption := FieldByName('WORK_ORDER').AsString;
    end;

    iResult := CheckPanel(iTerminal,UpdateUserID,gWO,gTrayNO,IntToStr(iTraySNCount),Trim(editPanel.Text));
    if iResult = 'OK' then
    begin
      ShowMSG('Panel No input : ',iResult,'Please input new Panel No!');
      editPanel.SetFocus;
      editPanel.Text:='';
      ShowData(gWO,gTrayNO);

      //重新取得工单的投入量  add by phoenix    2013-05-06
      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WO',ptInput);
        CommandText := 'Select INPUT_QTY FROM  SAJET.G_WO_BASE '
                     + ' WHERE WORK_ORDER = :WO';
        Params.ParamByName('WO').AsString := Trim(editWO.Text);
        Open;

        labInputQty.Caption := FieldByName('INPUT_QTY').AsString;
      end;

      if iSNCount >= iTraySNCount then
      begin
        //Self.editTrayKeyPress(Sender,Key);
        editTray.Enabled := True;
        editTray.SetFocus;
        editTray.Text := '';
        labTray.Caption := '';
        gTrayNO := '';
        ShowData(gWO,gTrayNO);
        labSNCount.Caption := '';
      end;
    end
    else
    begin
      ShowMSG('Panel No input : ',iResult,'');
      editPanel.SetFocus;
      editPanel.SelectAll;
    end;
  end;
end;

procedure TfCOBInput.labWODblClick(Sender: TObject);
begin
  if not editWO.Enabled then
  begin
    editWO.Enabled := True;
    editWO.SelectAll;
    editWO.SetFocus;
  end
  else
  begin
    editWO.Enabled := False;
  end;
end;

procedure TfCOBInput.labTrayDblClick(Sender: TObject);
begin
  if not editTray.Enabled then
  begin
    editTray.Enabled := True;
    editTray.SelectAll;
    editTray.SetFocus;
  end else
  begin
    editTray.Enabled := False;
  end;
end;

procedure TfCOBInput.miScrapClick(Sender: TObject);
var
  ResStr: String;
begin
  //修改G_SN_STATUS.WORK_FLAG及工单InputQty  add by phoenix  2013-05-07
  try
    with SProc do
    begin
      try
        Close;
        DataRequest('SAJET.SJ_COB_SCRAP');
        FetchParams;
        Params.ParamByName('TEMP').AsString := UpdateUserID;
        Params.ParamByName('TWO').AsString := Trim(editWO.Text);
        Params.ParamByName('TSN').AsString := QryData.FieldByName('serial_number').AsString;
        Execute;

        ResStr := Params.ParamByName('TRES').AsString;
      finally
        Close;
      end;
    end;
  except on e:Exception do
    begin
      ResStr := 'COB Scrap Error : ' + e.Message;
    end;
  end;
  if ResStr = 'OK' then
  begin
    ShowMSG('Scrap SN ',ResStr,'');
    //刷新工单InputQty及SN_COUNT
    labInputQty.Caption := IntToStr(StrToInt(labInputQty.Caption)-1);
    ShowData(trim(editwo.Text),trim(edittray.Text));
  end
  else
    ShowMSG('Scrap SN Error: ',ResStr,'')
end;

procedure TfCOBInput.PopupMenu1Popup(Sender: TObject);
begin
  if not QryData.Active then
    miScrap.Enabled := False
  else
  begin         
    if QryData.RecordCount <=0 then
      miScrap.Enabled := False
    else
    begin
      //判断是否有执行权限
      if miScrap.Tag = 0 then
        miScrap.Enabled := True;
    end;
  end;
end;

end.
