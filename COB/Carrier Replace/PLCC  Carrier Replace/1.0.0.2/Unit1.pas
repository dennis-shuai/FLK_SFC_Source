unit Unit1;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids;

type
  TForm1 = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    lblLabTitle1: TLabel;
    lblLabTitle2: TLabel;
    DataSource1: TDataSource;
    SaveDialog1: TSaveDialog;
    Label1: TLabel;
    edtPanel: TEdit;
    Label2: TLabel;
    lblMsg: TLabel;
    lblTerminal: TLabel;
    Label3: TLabel;
    edtWO: TEdit;
    Label4: TLabel;
    edtDB: TEdit;
    Label6: TLabel;
    lblQty: TLabel;
    sbtnNewLot: TSpeedButton;
    cmbLotNo: TComboBox;
    sbtnPrint: TSpeedButton;
    ImageReject: TImage;
    Label8: TLabel;
    edtHM: TEdit;
    lblPartNo: TLabel;
    procedure FormShow(Sender: TObject);
    procedure edtOldCarKeyPress(Sender: TObject; var Key: Char);
    procedure edtPanelKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnNewLotClick(Sender: TObject);
    procedure edtWOKeyPress(Sender: TObject; var Key: Char);
    procedure cmbLotNoSelect(Sender: TObject);
    procedure sbtnPrintClick(Sender: TObject);
    procedure cmbLotNoChange(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID : String;
    Count:Integer;
    function GetSystemDate(): TDateTime;

  end;

var
  Form1: TForm1;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit;

function TForm1.GetSystemDate(): TDateTime;
begin
     QryTemp.Close;
     QryTemp.Params.Clear();
     QryTemp.CommandText := 'Select sysdate tnow from dual' ;
     QryTemp.Open;

    result := QryTemp.FieldByName('tnow').AsDateTime;


end;


procedure TForm1.FormShow(Sender: TObject);
var iniFile :TIniFile   ;
begin
    With QryTemp do begin
        Close;
        Params.Clear;
        commandText :='Select Carton_NO FROM SAJET.G_PACK_CARTON WHERE  CLOSE_FLAG=''N'' and CARTON_NO LIKE ''COB%''  ';
        OPEN;
        first;
        while not eof do begin
            cmbLotno.Items.Add(fieldbyname('Carton_no').AsString);
           next;
        end;
    end;

    iniFile :=TIniFile.Create('SAJET.ini');
    G_sTerminalID :=iniFile.ReadString('COB','Terminal','N/A' );
    iniFile.Free;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Terminal_ID',ptInput);
    QryTemp.CommandText := 'select  b.PDLINE_NAME||''\''||a.Terminal_Name as Terminal ,a.Process_ID,b.PDLINE_ID ,a.Stage_ID from '+
                           ' SAJET.SYS_TERMINAL a,SAJET.SYS_PDLINE b where A.PDLINE_ID =B.PDLINE_ID' +
                           '  and Terminal_ID=  :Terminal_ID and a.Enabled=''Y'' ';
    QryTemp.Params.ParamByName('Terminal_ID').AsString := G_sTerminalID;
    QryTemp.Open;

    lblTerminal.Caption := 'TERMINAL:'+QryTemp.fieldByName('Terminal').AsString ;
    edtWO.ReadOnly :=false;
    edtWO.SetFocus;
    
end;

procedure TForm1.edtOldCarKeyPress(Sender: TObject; var Key: Char);
var Msg:string;
begin
    if Key <> #13 then exit;

end;

procedure TForm1.edtPanelKeyPress(Sender: TObject; var Key: Char);
var iResult,sDBInfo,sHMInfo,sCarrier:string;
begin
    if Key <> #13 then exit;
    if edtPanel.Text = '' then exit;


    if edtWO.Text ='' then begin
         lblmsg.Color :=clRed;
         lblMsg.Caption :='Please Input WO';
         edtWO.SetFocus;
         exit;
    end;

    if cmbLotNo.Text='' then begin
           cmbLotNo.SetFocus;
           lblmsg.Color :=clRed;
           lblMsg.Caption :='Please Input Lot No ';
           exit;
    end;
    sCarrier := edtPanel.Text;
    if  Copy(sCarrier,1,1) ='2' then begin
      With QryTemp do begin
           Close;
           Params.clear;
           Params.CreateParam(ftstring,'CARTON',ptInput);
           commandtext :=' SELECT BOX_NO FROM SAJET.G_SN_STATUS WHERE CARTON_NO =:CARTON';

           Params.parambyName('CARTON').Asstring :=  edtPanel.text;
           Open;

           if isEmpty then begin
               lblMsg.Caption := 'NO Panel（連板號錯誤）';
               lblMsg.Color := clRed;
               edtPanel.Text :='';
               edtPanel.SetFocus;
               exit;
           end;
           sCarrier :=FieldByName('BOX_NO').AsString;
       end;
   end;


   Sproc.Close;
   Sproc.DataRequest('SAJET.SJ_SMT_CKRT_PANEL2');
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TERMINALID').AsString :=G_sTerminalID;
   Sproc.Params.ParamByName('TREV').AsString :=sCarrier;
   Sproc.Execute;
   iResult := Sproc.Params.parambyname('TRES').asstring ;

   if Copy(iResult,1,2) <> 'OK' then begin
       lblMsg.Caption := iResult;
       lblMsg.Color := clRed;
       edtPanel.Text :='';
       edtPanel.SetFocus;
       exit;
   end;

     if (edtDB.Text ='') and (edtHM.Text ='') then begin
        With QryTemp do begin
           Close;
           Params.clear;
           Params.CreateParam(ftstring,'box',ptInput);
           commandtext :=' select c.Terminal_name,a.work_order from sajet.g_sn_status a,sajet.g_sn_travel b ,sajet.sys_terminal c where '+
                         '  a.Box_no =:Box and a.serial_number =b.Serial_number and b.terminal_id = '+
                         ' c.terminal_id and B.PROCESS_ID =100220';

           Params.parambyName('Box').Asstring :=  sCarrier;
           Open;

           edtDb.Text := fieldbyname('Terminal_name').AsString;
           if edtDb.Text ='' then begin
                MessageBoxA(0,'沒有DB信息','Error',MB_ICONERROR);
                exit;
           end;

       end;

        With QryTemp do begin
           Close;
           Params.clear;
           Params.CreateParam(ftstring,'Box',ptInput);
           commandtext :=' select c.Terminal_name,a.work_order from sajet.g_sn_status a  ,sajet.g_sn_travel b ,sajet.sys_terminal c where '+
                         ' a.Box_No =:Box and a.serial_number =b.Serial_number   and b.terminal_id = '+
                         ' c.terminal_id and B.PROCESS_ID =100221';
           Params.parambyName('Box').Asstring :=  sCarrier;
           Open;

           edtHM.Text := fieldbyname('Terminal_name').AsString;

           if edtHM.Text ='' then begin
                MessageBoxA(0,'沒有HM信息','Error',MB_ICONERROR);
                exit;
           end;

       end;
   end else begin
       With QryTemp do begin
           Close;
           Params.clear;
           Params.CreateParam(ftstring,'box',ptInput);
           commandtext :=' select c.Terminal_name,a.work_order from sajet.g_sn_status a,sajet.g_sn_travel b ,sajet.sys_terminal c where '+
                         '  a.Box_no =:Box and a.serial_number =b.Serial_number and b.terminal_id = '+
                         ' c.terminal_id and B.PROCESS_ID =100220';
           Params.parambyName('Box').Asstring :=  sCarrier;
           Open;

           sDBInfo := fieldbyname('Terminal_name').AsString;
           if sDBInfo ='' then begin
                MessageBoxA(0,'沒有DB信息','Error',MB_ICONERROR);
                exit;
           end;

           if sDBInfo <> edtDb.Text then begin
                lblMsg.Caption := 'DB 機台不同';
                lblMsg.Color := clRed;
                edtPanel.Text :='';
                edtPanel.SetFocus;
                exit;

           end;

       end;

        With QryTemp do begin
           Close;
           Params.clear;
           Params.CreateParam(ftstring,'Box',ptInput);
           commandtext :=' select c.Terminal_name,a.work_order from sajet.g_sn_status a  ,sajet.g_sn_travel b ,sajet.sys_terminal c where '+
                         ' a.Box_No =:Box and a.serial_number =b.Serial_number   and b.terminal_id = '+
                         ' c.terminal_id and B.PROCESS_ID =100221';
           Params.parambyName('Box').Asstring :=   sCarrier;
           Open;

           sHMInfo := fieldbyname('Terminal_name').AsString;

           if sHMInfo ='' then begin
                MessageBoxA(0,'沒有HM信息','Error',MB_ICONERROR);
                exit;

           end;

           if sHMInfo <> edtHM.Text then begin
                lblMsg.Caption := 'HM 機台不同';
                lblMsg.Color := clRed;
                edtPanel.Text :='';
                edtPanel.SetFocus;
                exit;
           end;
       end;

   end;

   Sproc.Close;
   Sproc.DataRequest('SAJET.CCM_PLCC_REPLACE_CARRIER_GO');
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TTERMINALID').AsString :=G_sTerminalID;
   Sproc.Params.ParamByName('TWO').AsString :=edtWO.Text;
   Sproc.Params.ParamByName('TEMP').AsString :=UpdateUserID;
   Sproc.Params.ParamByName('TCARRIER').AsString :=sCarrier;
   Sproc.Params.ParamByName('TLOTNO').AsString :=cmbLotNo.Text;
   Sproc.Execute;
   iResult := Sproc.Params.parambyname('TRES').asstring ;
   if iResult  <> 'OK' then begin
       lblMsg.Caption := iResult;
       lblMsg.Color := clRed;
       edtPanel.Text :='';
       edtPanel.SetFocus;
       exit;
   end;

   lblMsg.Caption := iResult;
   lblMsg.Color := clGreen;
   edtPanel.Text :='';
   edtPanel.SetFocus;

   With QryTemp do begin
       Close;
       Params.clear;
       Params.CreateParam(ftstring,'wo',ptInput);
       Params.CreateParam(ftstring,'carton',ptInput);
       commandtext :='Select Count(*)  qty from sajet.g_sn_status where work_order =:WO and carton_no =:carton';
       Params.parambyName('wo').Asstring :=  edtWO.text;
       Params.parambyName('carton').Asstring :=  cmbLotNO.text;
       Open;
       lblQty.Caption :=fieldbyname('qty').AsString;
   end;


end;

procedure TForm1.sbtnNewLotClick(Sender: TObject);
var LotNo,iResult:string;
begin

   cmbLotNo.Text :='';
   if edtwo.Text ='' then exit;
   edtDb.Text :='';
   edtHM.Text :='';
   edtPanel.Text :='';


  Sproc.Close;
  Sproc.DataRequest('SAJET.CCM_PLCC_CARRIER_LOT');
  Sproc.FetchParams;
  Sproc.Params.ParamByName('TWO').AsString :=edtWO.Text;
  Sproc.Params.ParamByName('TEMP').AsString :=UpdateUserID;
  Sproc.Params.ParamByName('TTERMINALID').AsString := G_sTerminalID;
  Sproc.Execute;
  iResult := Sproc.Params.parambyname('TRES').asstring ;

  cmbLotNo.Text := Sproc.Params.parambyname('TLOTNO').asstring ;
  if cmbLotNo.Text <>'' THEN
     cmbLotNo.Items.Add(cmbLotNo.Text );
  lblMsg.Caption :=iResult;

  if iResult <> 'OK' then begin

      lblMsg.Color :=clRed;
      cmbLotNo.SetFocus;
      cmbLotNo.SelectAll;
      exit;
  end;
  lblMsg.Color :=clGreen;
  edtPanel.Enabled :=true;
  edtPanel.ReadOnly :=false;
  edtPanel.SetFocus;
  edtPanel.Text :='';


end;

procedure TForm1.edtWOKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
  if Key <>#13 then exit;
  if edtWO.Text ='' then exit;
  cmbLotNO.SetFocus;

  Sproc.Close;
  Sproc.DataRequest('SAJET.SJ_CHK_WO_INPUT');
  Sproc.FetchParams;
  Sproc.Params.ParamByName('TREV').AsString :=edtWO.Text;
  Sproc.Execute;
  iResult := Sproc.Params.parambyname('TRES').asstring ;
  lblMsg.Caption :=iResult;

  if iResult <> 'OK' then begin
      lblMsg.Color :=clRed;
      edtWo.SetFocus;
      edtWO.SelectAll;
      exit;
  end;

   With QryTemp do begin
        Close;
        Params.Clear;
        commandText :='Select Carton_NO FROM SAJET.G_PACK_CARTON WHERE WORK_ORDER ='''+edtWo.Text+''' AND CLOSE_FLAG=''N'' and Carton_no Like ''COB%'' ';
        OPEN;
        first;
        cmbLotno.Items.Clear;
        while not eof do begin
            cmbLotno.Items.Add(fieldbyname('Carton_no').AsString);
           next;
        end;
    end;

    With QryTemp do begin
        Close;
        Params.Clear;
        commandText :='Select B.PART_NO FROM SAJET.G_WO_BASE A,SAJET.SYS_PART B WHERE A.WORK_ORDER ='''+edtWo.Text+''' AND A.MODEL_ID=B.PART_ID ';
        OPEN;
        if QryTemp.IsEmpty then exit;
        lblPartNo.Caption  :=fieldbyname('PART_NO').AsString;

    end;

   cmbLotNo.text :='';
   lblMsg.Color :=clGreen;
   edtWO.Enabled :=false;
   cmbLotNo.SetFocus;
   cmbLotNo.SelectAll;

end;

procedure TForm1.cmbLotNoSelect(Sender: TObject);
var sHMTerminal:string;
key:char;
begin

   With QryTemp do begin
       Close;
       Params.clear;
      // Params.CreateParam(ftstring,'wo',ptInput);
       Params.CreateParam(ftstring,'carton',ptInput);
       commandtext :='Select Count(*)  qty from sajet.g_sn_status where carton_no =:carton';
      // Params.parambyName('wo').Asstring :=  edtWO.text;
       Params.parambyName('carton').Asstring :=   cmbLotNO.text;
       Open;
       lblQty.Caption :=fieldbyname('qty').AsString;
   end;

   With QryTemp do begin
       Close;
       Params.clear;
       Params.CreateParam(ftstring,'carton',ptInput);
       commandtext :='Select * from sajet.g_Pack_CARTON where   carton_no =:carton';
       Params.parambyName('carton').Asstring :=  cmbLotNO.text;
       Open;
       edtWO.Text :=fieldbyname('WORK_ORDER').AsString;
       edtWo.Enabled :=false;
        
   end;

   With QryTemp do begin
        Close;
        Params.Clear;
        commandText :='Select B.PART_NO FROM SAJET.G_WO_BASE A,SAJET.SYS_PART B WHERE A.WORK_ORDER ='''+edtWo.Text+''' AND A.MODEL_ID=B.PART_ID ';
        OPEN;
        if QryTemp.IsEmpty then exit;
        lblPartNo.Caption  :=fieldbyname('PART_NO').AsString;

    end;


    With QryTemp do begin
       Close;
       Params.clear;
       Params.CreateParam(ftstring,'carton',ptInput);
       commandtext :=' select c.Terminal_name,a.work_order from sajet.g_sn_status a,sajet.g_sn_travel b ,sajet.sys_terminal c where '+
                     ' a.Carton_no =:carton and a.serial_number =b.Serial_number and b.terminal_id = '+
                     ' c.terminal_id and B.PROCESS_ID = 100220';
       Params.parambyName('carton').Asstring :=  cmbLOTNO.text;
       Open;
       //edtWO.Text :=fieldbyname('work_order').AsString;
       edtDb.Text := fieldbyname('Terminal_name').AsString;
   end;

    With QryTemp do begin
       Close;
       Params.clear;
       Params.CreateParam(ftstring,'carton',ptInput);
       commandtext :=' select c.Terminal_name,a.work_order from sajet.g_sn_status a ,sajet.g_sn_travel b,sajet.sys_terminal c where '+
                     ' a.Carton_no =:carton and a.serial_number =b.Serial_number and b.terminal_id = '+
                     ' c.terminal_id and B.PROCESS_ID  =100221';
       Params.parambyName('carton').Asstring :=  cmbLOTNO.text;
       Open;

       sHMTerminal := fieldbyname('Terminal_name').AsString;

       edtHM.Text := sHMTerminal;
   end;


   edtPanel.Enabled :=true;
   edtPanel.ReadOnly :=false;
   edtPanel.SetFocus;
   edtPanel.SelectAll;
end;

procedure TForm1.sbtnPrintClick(Sender: TObject);
Var BarApp,BarDoc,BarVars:variant;
PrintFileName:string;
begin
    try
          BarApp := CreateOleObject('lppx.Application');
    except
         MessageBoxA(0,'沒有安裝codesoft軟體','錯誤提示',MB_OK+MB_ICONERROR);
         Exit;
    end;
    BarApp.Visible:=false;
    BarDoc:=BarApp.ActiveDocument;
    BarVars:=BarDoc.Variables;
    PrintFileName := ExtractFilePath(Paramstr(0))+'\COB_LOT.Lab';

    if not FileExists(PrintFileName) then
    begin
       MessageBoxA(0,PChar('缺少打印文件'+PrintFileName),'錯誤提示',MB_OK+MB_ICONERROR);
       Exit;
    end;
    BarDoc.Open(PrintFileName);

    try
       BarDoc.Variables.Item('WO').Value :=edtWO.Text;
       BarDoc.Variables.Item('PART_NO').Value :=lblPartNO.Caption;
       BarDoc.Variables.Item('LOT_NO').Value :=cmbLOTNO.Text;
       BarDoc.Variables.Item('DB').Value :=edtDB.Text;
       BarDoc.Variables.Item('HM').Value :=edtHM.Text;
       BarDoc.Variables.Item('Qty').Value :=lblQty.Caption;
     except
       MessageBoxA(0,'打印文件設置錯誤','錯誤提示',MB_OK+MB_ICONERROR);
       Exit;
     end;

     Bardoc.PrintLabel(1);
     Bardoc.FormFeed;

     Bardoc.Close;
     BarApp.Quit;

     BarVars := Unassigned;
     Bardoc := Unassigned;
     BarApp := Unassigned;

      With QryTemp do begin
       Close;
       Params.clear;
       Params.CreateParam(ftstring,'wo',ptInput);
       Params.CreateParam(ftstring,'carton',ptInput);
       commandtext :=' UPDATE SAJET.G_PACK_CARTON SET CLOSE_FLAG=''Y'' WHERE CARTON_NO = :carton and WORK_ORDER =:WO';
       Params.parambyName('wo').Asstring :=  edtWO.text;
       Params.parambyName('carton').Asstring :=  cmbLOTNO.text;
       execute;

       cmbLOTNO.Text :='';
       edtDB.Text :='';
       edtHM.Text :='';
       edtPanel.Text :='';
       cmbLotNO.SetFocus;

   end;
   cmbLOTNO.Items.Clear;
    With QryTemp do begin
        Close;
        Params.Clear;
        commandText :='Select Carton_NO FROM SAJET.G_PACK_CARTON WHERE CLOSE_FLAG=''N'' and CARTON_NO LIKE ''COB%''  ';
        OPEN;
        first;
        while not eof do begin
            cmbLotno.Items.Add(fieldbyname('Carton_no').AsString);
           next;
        end;
    end;


end;

procedure TForm1.cmbLotNoChange(Sender: TObject);
begin
   if trim(cmbLotNo.Text) ='' then exit;
   cmbLotNo.OnSelect(Sender);

end;

end.
