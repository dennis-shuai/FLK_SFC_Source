unit umain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, MConnect, SConnect, ObjBrkr, StdCtrls, Buttons,
  ExtCtrls ,ComObj,IniFiles,Tlhelp32;

type
  TfMain = class(TForm)
    QryData: TClientDataSet;
    Label1: TLabel;
    Label3: TLabel;
    edtDrum: TEdit;
    Image1: TImage;
    sbtnPrint: TSpeedButton;
    msgPanel: TPanel;
    edtWO: TEdit;
    Label2: TLabel;
    Label4: TLabel;
    lblFileName: TLabel;
    Label6: TLabel;
    edtGuitar: TEdit;
    Label7: TLabel;
    edtPallet: TEdit;
    sbtnPalletClose: TSpeedButton;
    Image2: TImage;
    lblPartNo: TLabel;
    Label5: TLabel;
    lblStation: TLabel;
    Qrytemp: TClientDataSet;
    Sproc: TClientDataSet;
    lblPalletQty: TLabel;
    lstValue: TListBox;
    lstField: TListBox;
    Label8: TLabel;
    lblPalletCap: TLabel;
    Label9: TLabel;
    lblCartonQty: TLabel;
    Label11: TLabel;
    lblCartonCap: TLabel;
    edtCarton: TEdit;
    Image3: TImage;
    sbtnCartonClose: TSpeedButton;
    Image4: TImage;
    SpeedButton1: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure sbtnPrintClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtDrumKeyPress(Sender: TObject; var Key: Char);
    procedure edtWOKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnPalletCloseClick(Sender: TObject);
    procedure edtGuitarKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnCartonCloseClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID,sFirstWO,sWO ,PART_NO,LAB,sProcess,iTerminal,PalletNo,CartonNo,sPKSpec,gPartID,gsn,gCSN,CSN,sn:string;
    mWo,mPartId,mPartNo,mCode,mCodeNo,mCodeDef,gsCheckSum,mDateCode,Carry16:string;
    SNUdf,CarryM,CarryD,CarryW,CarryK: TStringList;
    BarApp,BarDoc,BarVars:variant;
    i_Count,count:integer;
    isStart,IsOpen:boolean;
    mCarry: string;
    //function LoadApServer: Boolean;
    function GetTerminalName(sTerminalID:string):string;
    function GetUnfinishPallet: Boolean;
    function GetPallet: Boolean;
    function GetNewNo(NoType: string; var NewNo: string): Boolean;
    procedure AppendPalletNo;
    function  KillTask(ExeFileName: string): integer;
    procedure PrintPallet(Pallet_No:string);
    function  GetCarton: Boolean;
    procedure AppendCartonNo;
    function  GetUnfinishCarton: Boolean;
    //function  GetPackCartonQty: Boolean;
  end;

var
  fMain: TfMain;

implementation

uses Login;

{$R *.dfm}


procedure TfMain.FormShow(Sender: TObject);
var i:integer;
    iniFile:TiniFile;
begin
     qrytemp.RemoteServer :=fLogin.SocketConnection1;
     qryData.RemoteServer :=fLogin.SocketConnection1;
     sproc.RemoteServer :=fLogin.SocketConnection1;
     UpdateUserID :=fLogin.sEMPID;
     isStart :=false;
     IsOpen :=false;
     KillTask('lppa.exe');
     try
        BarApp := CreateOleObject('lppx.Application');
        BarApp.Visible:=false;
        BarDoc:=BarApp.ActiveDocument;
        BarVars:=BarDoc.Variables;
        isStart :=true;
     except
        Application.MessageBox('›]¨S¦³¦w¸Ëcodesoft³nÅé','¿ù»~',MB_OK+MB_ICONERROR);
        isStart:=false;
        Exit;
     end;
     
     iniFile :=TIniFile.Create('SAJET.ini');
     iTerminal :=IniFile.ReadString('PACKING','Terminal','');
     iniFile.free;
     lblStation.Caption := GetTerminalName(iTerminal);
     edtWO.SetFocus;
     SNUdf := TStringList.Create;
     CarryM := TStringList.Create;
     CarryD := TStringList.Create;
     CarryW := TStringList.Create;
     CarryK := TStringList.Create;
     Carry16 := '123456789ABCDEF';
     sPkSpec :='501-1*1*12';
     edtDrum.Enabled :=false;
     edtGuitar.Enabled :=false;
end;

function TfMain.GetTerminalName(sTerminalID:string):string;
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

procedure TfMain.sbtnPrintClick(Sender: TObject);
var   PrintFile:string;
begin

   IsOpen :=false;
   PrintFile:= GetCurrentDir+'\\'+LAB;
   If not FileExists( PrintFile) then
   begin
         MessageDlg( 'Label ÀÉ®×¤£¦s¦b',mterror,[mbOK],0);
         IsOpen :=false;
         Exit;
   end;

   if IsStart then begin
      try
       BarApp.Visible:=false;
       BarDoc:=BarApp.ActiveDocument;
       BarVars:=BarDoc.Variables;
       BarDoc.Open(PrintFile);
       IsOpen :=true;
      except
       IsOpen :=false;
      end;
   end;

   if (IsStart) and (IsOpen) then begin
    BarDoc.Variables.Item('D_SN').Value :=  CSN;
    BarDoc.Variables.Item('G_SN').Value :=  GCSN;
    BarDoc.Variables.Item('PART_NO').Value :=  mPartNO;
    Bardoc.PrintLabel(1);
    Bardoc.FormFeed;
   end;
end;


procedure TfMain.FormDestroy(Sender: TObject);
begin
   if IsStart  then Bardoc.Close;
   if IsOpen then  BarApp.Quit;
   KillTask('lppa.exe');
    
end;

procedure TfMain.edtDrumKeyPress(Sender: TObject; var Key: Char);
var wo,part,color,sRes:string;
begin
  if Key <>#13 then exit;
  CSN :=UpperCase(Trim(edtDrum.Text));
  if copy(CSN,7,1)<>'D' then begin
      msgpanel.Caption := '¹ª±ø½X½s½X¿ù»~';
      msgpanel.Font.Color :=clRed;
      msgpanel.Color := clYellow;
      edtDrum.SetFocus;
      edtDrum.Clear;
      exit;
  end;
  with Sproc do begin
      close;
      DataRequest('SAJET.SJ_CKRT_SN_PSN');
      fetchParams;
      Params.ParamByName('TREV').AsString :=CSN;
      Execute;
      sRes :=  Params.ParamByName('TRES').AsString ;
      if sRes <>'OK' then begin
         msgpanel.Caption := sRes;
         msgpanel.Font.Color :=clRed;
         msgpanel.Color := clYellow;
         edtDrum.SetFocus;
         edtDrum.Clear;
         exit;
      end;
      sn:= Params.ParamByName('PSN').AsString ;
  end;

  with Sproc do begin
      close;
      DataRequest('SAJET.SJ_CKRT_ROUTE');
      fetchParams;
      Params.ParamByName('TERMINALID').AsString :=iTerminal ;
      Params.ParamByName('TSN').AsString :=sn ;
      Execute;
      sRes :=  Params.ParamByName('TRES').AsString ;
      if sRes <>'OK' then begin
         msgpanel.Caption := sRes;
         msgpanel.Font.Color :=clRed;
         msgpanel.Color := clYellow;
         edtDrum.SetFocus;
         edtDrum.Clear;
         exit;
      end;
  end;
  with sproc do begin
      close;
      DataRequest('SAJET.SJ_CKRT_ROUTE');
      fetchParams;
      Params.ParamByName('TERMINALID').AsString :=iTerminal ;
      Params.ParamByName('TSN').AsString :=sn ;
      Execute;
       sRes :=  Params.ParamByName('TRES').AsString ;
      if sRes <>'OK' then begin
         msgpanel.Caption := sRes;
         msgpanel.Font.Color :=clRed;
         msgpanel.Color := clYellow;
         edtDrum.SetFocus;
         edtDrum.Clear;
         exit;
      end;

  end;


  with qrydata do
  begin
       close;
       params.clear;
       params.CreateParam(ftstring,'SN',ptInput);
       commandtext :='select SUBSTR(b.part_no,11,4) PART,a.work_order  from sajet.g_sn_status a,sajet.sys_part b where  '+
                       ' b.part_id=a.model_id and  serial_number = :sn  ';
       params.ParamByName('SN').AsString := sn;
       Open;
       wo:=  fieldbyname('work_order').AsString;
       part :=fieldbyname('PART').AsString;

       if Isempty then begin
            msgpanel.Caption := 'No SN';
            msgpanel.Font.Color :=clRed;
            msgpanel.Color := clYellow;
            edtDrum.SelectAll;
            exit;
       end;

       if wo<> edtwo.Text  then begin
           msgPanel.Color :=clYellow;
           msgPanel.Font.Color := clRed;
           msgPanel.Caption := '¤u³æ¿ù»~'+ edtwo.Text;

       end;

      if PART='0280' then begin
           msgPanel.Caption:='²£«~§ë¤J¤u³æ¬°'+WO+',¸Ó¤u³æ¬°¶Â¦â²£«~' ;
           msgPanel.Font.Color:=clwhite ;
           msgPanel.Color:=clBlack;
       end else
       if PART='0180' then begin
           msgPanel.Caption:='²£«~§ë¤J¤u³æ¬°'+WO+',¸Ó¤u³æ¬°¥Õ¦â²£«~'  ;
           msgPanel.Font.Color:=clBlack ;
           msgPanel.Color:=clwhite;
      end else
      if PART='0080' then begin
           msgPanel.Caption:='²£«~§ë¤J¤u³æ¬°'+WO+',¸Ó¤u³æ¬°¬õ¦â²£«~';
           msgPanel.Font.Color:=clBlack ;
           msgPanel.Color:=clRed;
      end;

      
      with sproc do begin
           close;
          DataRequest('SAJET.CCM_PACKING_KEYPARTS');
          fetchParams;
          Params.ParamByName('TTERMINALID').AsString :=iTerminal ;
          Params.ParamByName('TSN').AsString :=sn ;
          Params.ParamByName('TPALLET_NO').AsString :=edtPallet.Text ;
          Params.ParamByName('TCARTON_NO').AsString :=edtCarton.Text ;
          Params.ParamByName('TITEM_PART_SN').AsString :=edtGuitar.Text ;
          Params.ParamByName('TEMPID').AsString :=UpdateUserID ;
          Execute;
           sRes :=  Params.ParamByName('TRES').AsString ;
          if sRes <>'OK' then begin
             msgpanel.Caption := sRes;
             msgpanel.Font.Color :=clRed;
             msgpanel.Color := clYellow;
             edtDrum.Clear;
             edtGuitar.Clear;
             edtGuitar.Enabled :=true;
             edtGuitar.SetFocus;
             exit;
          end;
      end;

      
      sbtnPrint.Click;
      edtDrum.Clear;
      edtGuitar.Clear;
      edtGuitar.Enabled:=true;
      edtDrum.Enabled :=false;
      edtGuitar.SetFocus;
      lblPalletQty.Caption := IntToStr(StrToInt(lblPalletQty.Caption)+1);
      lblCartonQty.Caption := IntToStr(StrToInt(lblCartonQty.Caption)+1);
      if StrToInt( lblPalletQty.Caption) >=  StrToInt( lblPalletCap.Caption) then begin
           sbtnPalletClose.Click;
      end;

      if StrToInt( lblCartonQty.Caption) >=  StrToInt( lblCartonCap.Caption) then begin
           sbtnCartonClose.Click;
      end;

   end;
end;

procedure TfMain.edtWOKeyPress(Sender: TObject; var Key: Char);
var sRes,sNewPallet:string;
begin
    if Key <> #13 then Exit;

    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
      CommandText := 'SELECT WORK_ORDER ' +
        'FROM   SAJET.G_SN_STATUS ' +
        'WHERE  SERIAL_NUMBER = :SERIAL_NUMBER ' +
        'AND ROWNUM=1';
      Params.ParamByName('SERIAL_NUMBER').AsString := edtWO.Text;
      Open;
      if IsEmpty then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
        CommandText := 'SELECT WORK_ORDER ' +
          'FROM   SAJET.G_SN_STATUS ' +
          'WHERE  CUSTOMER_SN = :SERIAL_NUMBER ' +
          'AND ROWNUM=1';
        Params.ParamByName('SERIAL_NUMBER').AsString := edtWO.Text;
        Open;
      end;
      if not IsEmpty then
      begin
        edtWO.Text := FieldByName('WORK_ORDER').asstring;
      end;
    end;

    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WO_NUMBER', ptInput);
      CommandText := 'SELECT A.*, B.PART_NO, Label_File, CUST_PART_NO ' +
        'FROM   SAJET.G_WO_BASE A, SAJET.SYS_PART B ' +
        'WHERE  A.WORK_ORDER = :WO_NUMBER ' +
        'AND    A.MODEL_ID = B.PART_ID(+) and rownum = 1';
      Params.ParamByName('WO_NUMBER').AsString := edtWO.Text;
      Open;


      if not IsEmpty then
      begin
          if (FieldByName('WO_STATUS').AsString = '3') or (FieldByName('WO_STATUS').AsString = '2') then
          begin
            mWO := FieldByName('WORK_ORDER').AsString;
            mPartID := FieldByName('MODEL_ID').AsString;
            mPartNO := FieldByName('PART_NO').AsString;
            lblPartNo.Caption := mPartNO;
            LAB:='C_'+mPartNO+'.LAB';
          end ;
      end else begin
           msgpanel.Caption := 'NOT FIND WO';
           msgpanel.Font.Color :=clRed;
           msgpanel.Color := clYellow;

      end;

    end;

    with sproc do begin
         Close;
         DataRequest('SAJET.SJ_CHK_WO_INPUT');
         FetchParams;
         Params.ParamByName('TREV').AsString :=edtWO.Text;
         Execute;
         sRes := Params.ParamByName('TRes').AsString;
         if  sRes <> 'OK' then begin
             msgpanel.Caption := sRes;
             msgpanel.Font.Color :=clRed;
             msgpanel.Color := clYellow;
             edtWO.SelectAll;
             exit;
         end;

    end;



     if not GetUnfinishPallet then
        GetPallet ;

     with qrytemp do begin
     
         close;
         params.Clear;
         params.CreateParam(ftstring,'Pallet',ptInput);
         params.CreateParam(ftstring,'WO',ptInput);
         CommandText :='Select COUNT(*) Pallet_COUNT FROM SAJET.G_SN_STATUS WHERE PALLET_NO =:Pallet ' +
                       '  AND WORK_ORDER= :WO';
         Params.ParamByName('Pallet').AsString :=edtPallet.Text ;
         Params.ParamByName('WO').AsString := edtWO.Text ;
         Open;

         if IsEmpty then
            lblPalletQty.Caption :='0'
         else
            lblPalletQty.Caption := fieldByname('Pallet_Count').AsString;

     end;
     if not GetUnfinishCarton then
         GetCarton;

     msgpanel.Caption := '½Ð±½´y¦N¥L²£«~±ø½X';
     msgpanel.Font.Color :=clGreen;
     msgpanel.Color := clWhite;
     edtCarton.Enabled :=false;
     edtGuitar.Enabled :=true;
     edtDrum.Enabled :=false;
     edtPallet.Enabled :=false;
     edtWO.Enabled :=false;
     edtGuitar.SetFocus;
end;

function TfMain.GetUnfinishCarton: Boolean;
begin
  Result := False;
  CartonNo := '';

    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
      Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
      CommandText := 'SELECT CARTON_NO ' +
        'FROM   SAJET.G_PACK_CARTON  WHERE  WORK_ORDER = :WORK_ORDER '+
        'AND    TERMINAL_ID = :TERMINAL_ID ' +
        'AND    CLOSE_FLAG = ''N'' AND PKSPEC_NAME = :PKSPEC_NAME AND ROWNUM=1 ';
      Params.ParamByName('WORK_ORDER').AsString := mWO;
      Params.ParamByName('TERMINAL_ID').AsString := iTerminal;
      Params.ParamByName('PKSPEC_NAME').AsString := sPKSpec;
      Open;
      if not IsEmpty then
        CartonNo := fieldByName('Carton_No').AsString;
        if CartonNo <> '' then
        begin
        Result := True;
        edtCarton.Text := CartonNo;
        end;
      Close;

    end;

end;


function TfMain.GetUnfinishPallet: Boolean;
begin
  Result := False;
  PalletNo := '';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
    //Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
    CommandText := 'SELECT PALLET_NO '
      + 'FROM   SAJET.G_PACK_PALLET '
      + 'WHERE  WORK_ORDER = :WORK_ORDER '
      + 'AND    TERMINAL_ID = :TERMINAL_ID '
      + 'AND    CLOSE_FLAG = ''N'' ';//AND PKSPEC_NAME = :PKSPEC_NAME';
    Params.ParamByName('WORK_ORDER').AsString := mWO ;
    Params.ParamByName('TERMINAL_ID').AsString := iTerminal;
    //Params.ParamByName('PKSPEC_NAME').AsString := sPKSpec;
    Open;
    if not IsEmpty then
    begin
      if RecordCount >= 1 then
        PalletNo := Fieldbyname('PALLET_NO').AsString ;

      //else
       // PalletNo := ShowClose('Pallet');
      Result := True;
    end;
    Close;
    if PalletNo <> '' then
      edtPallet.Text := PalletNo;
  end;
end;

function TfMain.GetPallet: Boolean;
begin
  Result := False;
  PalletNo := '';
  if not GetNewNo('Pallet', PalletNo) then Exit;
  if PalletNo = '' then Exit;
  edtPallet.Text := PalletNo;
  lblPalletQty.Caption := InttoStr(StrToIntDef(lblPalletQty.Caption, 0));
  AppendPalletNo;
  Result := True;
end;

procedure TfMain.AppendPalletNo;
begin
  if PalletNo = 'N/A' then Exit;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PALLET_NO', ptInput);
    CommandText := 'SELECT PALLET_NO ' +
      'FROM SAJET.G_PACK_PALLET ' +
      'WHERE PALLET_NO = :PALLET_NO and rownum = 1'; // rownum 2006.11.13 add
    Params.ParamByName('PALLET_NO').AsString := PalletNo;
    Open;
    if isEmpty then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'MODEL_ID', ptInput);
      Params.CreateParam(ftString, 'PALLET_NO', ptInput);
      Params.CreateParam(ftString, 'CLOSE_FLAG', ptInput);
      Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
      Params.CreateParam(ftString, 'CREATE_EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
      CommandText := 'INSERT INTO SAJET.G_PACK_PALLET ' +
        ' (WORK_ORDER,MODEL_ID, PALLET_NO, CLOSE_FLAG, TERMINAL_ID, CREATE_EMP_ID, PKSPEC_NAME) ' +
        'VALUES (:WORK_ORDER, :MODEL_ID, :PALLET_NO, :CLOSE_FLAG, :TERMINAL_ID, :CREATE_EMP_ID, :PKSPEC_NAME)';
      Params.ParamByName('WORK_ORDER').AsString := mWO;
      Params.ParamByName('MODEL_ID').AsString := mPartID;
      Params.ParamByName('PALLET_NO').AsString := PalletNo;
      Params.ParamByName('CLOSE_FLAG').AsString := 'N';
      Params.ParamByName('TERMINAL_ID').AsString := iTerminal;
      Params.ParamByName('CREATE_EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PKSPEC_NAME').AsString := sPKSpec;
      Execute;
      Close;
    end;
  end;
end;

function TfMain.GetNewNo(NoType: string; var NewNo: string): Boolean;
  function GetMaxSeq(sSNCode, SNDef: string): string;
  var S: string; i, j: integer; iSeq: Real;
  begin
    S := sSNCode;
    iSeq := 1;
    for I := 1 to Length(S) do
      if S[I] = 'S' then
      begin
        if mCarry = '16' then
          iSeq := iSeq * 16
        else
          iSeq := iSeq * 10
      end
      else
      begin
        for j := 0 to SNUdf.Count - 1 do
          if S[I] = Copy(SNUdf.Strings[J], 1, 1) then
          begin
            iSeq := iSeq * (Length(SNUdf.Strings[j]) - 4);
            break;
          end;
      end;
    Result := FloatToStr(iSeq - 1);
  end;
  procedure CreateSeq(RuleName: string; iLength: Integer; sSNCode, sSNDef: string);
  var sTemp: string;
  begin
    sTemp := GetMaxSeq(sSNCode, sSNDef);
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'CREATE SEQUENCE ' + RuleName + ' INCREMENT BY 1 START WITH 1 MAXVALUE ' + sTemp + ' NOCYCLE NOCACHE ORDER';
      Execute;
      Close;
      Params.Clear;
      CommandText := 'GRANT SELECT ON ' + RuleName + ' TO SYS_USER';
      Execute;
      Close;
    end;
  end;
  procedure SavetoDB(ParamName, ParamItem, ParamValue, sModule, sRuleName: string);
  var sRow: string;
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
      Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
      Params.CreateParam(ftString, 'PARAME_NAME', ptInput);
      CommandText := 'select rowid from sajet.sys_module_param '
        + 'where module_name = :module_name '
        + 'and function_name = :function_name '
        + 'and parame_name = :parame_name ';
      Params.ParamByName('MODULE_NAME').AsString := sModule;
      Params.ParamByName('FUNCTION_NAME').AsString := sRuleName;
      Params.ParamByName('PARAME_NAME').AsString := ParamName;
      Open;
      if IsEmpty then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
        Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
        Params.CreateParam(ftString, 'PARAME_NAME', ptInput);
        Params.CreateParam(ftString, 'PARAME_ITEM', ptInput);
        Params.CreateParam(ftString, 'PARAME_VALUE', ptInput);
        Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
        CommandText := 'Insert Into SAJET.SYS_MODULE_PARAM ' +
          '(MODULE_NAME,FUNCTION_NAME,PARAME_NAME,PARAME_ITEM,PARAME_VALUE,UPDATE_USERID )' +
          'Values (:MODULE_NAME,:FUNCTION_NAME,:PARAME_NAME,:PARAME_ITEM,:PARAME_VALUE,:UPDATE_USERID) ';
        Params.ParamByName('MODULE_NAME').AsString := sModule;
        Params.ParamByName('FUNCTION_NAME').AsString := sRuleName;
        Params.ParamByName('PARAME_NAME').AsString := ParamName;
        Params.ParamByName('PARAME_ITEM').AsString := ParamItem;
        Params.ParamByName('PARAME_VALUE').AsString := ParamValue;
        Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
        Execute;
        Close;
      end
      else
      begin
        sRow := FieldByName('rowid').AsString;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'parame_value', ptInput);
        Params.CreateParam(ftString, 'Data', ptInput);
        CommandText := 'update sajet.sys_module_param '
          + 'set parame_value = :parame_value '
          + 'where rowid = :Data ';
        Params.ParamByName('PARAME_VALUE').AsString := ParamValue;
        Params.ParamByName('Data').AsString := sRow;
        Execute;
        Close;
      end;
    end;
  end;
var mDY, mDM, mDD, mDW, mDK, mcDM, mcDD, mcDW, mDYW, mcDK, sModule: string; mDate: TDateTime;
  sSNCode, sSEQ, sSNDef, sSeqName, S, S1, gsMark, sRuleName: string;
  sType1, sField1, sType2, sField2, sType3, sField3, sValue1, sValue2, sValue3: string;
  I, J, mMod, mDiv, iCycle: Integer; bReset: Boolean;
begin
  Result := False;
  SNUdf.Clear;
   // Åª¨ú Carton or Pallet or Customer SN½s½X³W«h
  //LabCartonQty.Visible := LabCartonCap.Visible;
  sField1 := ''; sField2 := ''; sField3 := '';
  if NoType = 'Carton' then
    sModule := 'CARTON NO RULE'
  else if NoType = 'Pallet' then
    sModule := 'PALLET NO RULE'
  else if NoType = 'Box' then
    sModule := 'BOX NO RULE'
  else
    sModule := 'CUSTOMER SN RULE';
  with qryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    CommandText := 'SELECT * ' +
      'FROM SAJET.G_WO_PARAM ' +
      'WHERE WORK_ORDER = :WORK_ORDER AND ' +
      'MODULE_NAME = :MODULE_NAME ';
    Params.ParamByName('WORK_ORDER').AsString := mWO;
    Params.ParamByName('MODULE_NAME').AsString := sModule;
    Open;
      //======System Create,¥BµL³]©w½s½X³W«h=======
    if IsEmpty then
    begin
        if  NoType = 'Pallet' then
        begin
          Close;
          Params.Clear;
          CommandText := 'select sajet.packing_label(''' + NoType + ''',''Work Order'',''' + mWO + ''') SNID from dual';
          Open;
          Result := True;
          NewNo := FieldByName('SNID').AsString;
        end;
        exit;
    end
    else
    begin
      sSeqName := Fieldbyname('FUNCTION_NAME').AsString;
      sRuleName := sSeqName;
      if NoType = 'Carton' then
        sSeqName := 'S_CTN_' + sSeqName
      else if NoType = 'Pallet' then
        sSeqName := 'S_PLT_' + sSeqName
      else
        sSeqName := 'S_SSN_' + sSeqName;
    end;
      //===============================================
    while not Eof do
    begin
      if (Fieldbyname('PARAME_NAME').AsString = 'Carton No Code') or
        (Fieldbyname('PARAME_NAME').AsString = 'Pallet No Code') or
        (Fieldbyname('PARAME_NAME').AsString = 'Box No Code') or
        (Fieldbyname('PARAME_NAME').AsString = 'Customer SN Code') then
      begin
        if Fieldbyname('PARAME_ITEM').AsString = 'Code' then
          mCode := Fieldbyname('PARAME_VALUE').AsString;

        if Fieldbyname('PARAME_ITEM').AsString = 'Default' then
          mCodeDef := Fieldbyname('PARAME_VALUE').AsString;

        if Fieldbyname('PARAME_ITEM').AsString = 'Code Type' then
        begin
          mCarry := '0';
          if Fieldbyname('PARAME_VALUE').AsString = '16' then
            mCarry := '16';
        end;
      end
      else if Fieldbyname('PARAME_NAME').AsString = 'Check Sum' then
        gsCheckSum := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_NAME').AsString = 'Month User Define' then
        CarryM.CommaText := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_NAME').AsString = 'Day User Define' then
        CarryD.CommaText := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_NAME').AsString = 'Week User Define' then
        CarryW.CommaText := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_NAME').AsString = 'Day of Week User Define' then
        CarryK.CommaText := Fieldbyname('PARAME_VALUE').AsString
      else if Fieldbyname('PARAME_NAME').AsString = '1-Digit Type & Field' then
      begin
        sType1 := Fieldbyname('PARAME_ITEM').AsString;
        sField1 := Fieldbyname('PARAME_VALUE').AsString;
      end
      else if Fieldbyname('PARAME_NAME').AsString = '2-Digit Type & Field' then
      begin
        sType2 := Fieldbyname('PARAME_ITEM').AsString;
        sField2 := Fieldbyname('PARAME_VALUE').AsString;
      end
      else if Fieldbyname('PARAME_NAME').AsString = '3-Digit Type & Field' then
      begin
        sType3 := Fieldbyname('PARAME_ITEM').AsString;
        sField3 := Fieldbyname('PARAME_VALUE').AsString;
      end
      else if Fieldbyname('PARAME_NAME').AsString = 'Reset Sequence' then
      begin
        bReset := (Fieldbyname('PARAME_ITEM').AsString = '1');
        iCycle := Fieldbyname('PARAME_VALUE').AsInteger;
      end
      else if (Fieldbyname('PARAME_NAME').AsString = 'Carton No User Define') or
        (Fieldbyname('PARAME_NAME').AsString = 'Pallet No User Define') or
        (Fieldbyname('PARAME_NAME').AsString = 'Box No User Define') or
        (Fieldbyname('PARAME_NAME').AsString = 'Customer SN User Define') then
        SNUdf.Add(Fieldbyname('PARAME_ITEM').AsString + ' : ' +
          Fieldbyname('PARAME_VALUE').AsString);
      Next;
    end;
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'PARAME_NAME', ptInput);
    CommandText := 'Select PARAME_VALUE ' +
      'From SAJET.SYS_MODULE_PARAM A ' +
      'Where MODULE_NAME = :MODULE_NAME and ' +
      'A.FUNCTION_NAME = :FUNCTION_NAME and ' +
      'A.PARAME_NAME = :PARAME_NAME ';
    Params.ParamByName('MODULE_NAME').AsString := sModule;
    Params.ParamByName('FUNCTION_NAME').AsString := sRuleName;
    Params.ParamByName('PARAME_NAME').AsString := 'Reset Sequence Mark';
    Open;
    gsMark := Fieldbyname('PARAME_VALUE').AsString;
    Close;
    sSNCode := mCode;
    sSNDef := mCodeDef;
  end;
  if sField1 <> '' then
  begin
    sValue1 := lstValue.Items[lstField.Items.IndexOf(sField1)];
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select ' + sType1 + '(''' + sValue1 + ''') snid from dual ';
      Open;
      sValue1 := FieldByName('snid').AsString;
    end;
  end;
  if sField2 <> '' then
  begin
    sValue2 := lstValue.Items[lstField.Items.IndexOf(sField2)];
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select ' + sType2 + '(''' + sValue2 + ''') snid from dual ';
      Open;
      sValue2 := FieldByName('snid').AsString;
    end;
  end;
  if sField3 <> '' then
  begin
    sValue3 := lstValue.Items[lstField.Items.IndexOf(sField3)];
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select ' + sType1 + '(''' + sValue3 + ''') snid from dual ';
      Open;
      sValue3 := FieldByName('snid').AsString;
    end;
  end;
  with qryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select TO_CHAR(SYSDATE,''YYYYMMDDIWDDD'') YMD, sysdate FROM DUAL ';
    Open;
    mDateCode := Fieldbyname('YMD').AsString;
    mDate := FieldByName('sysdate').AsDateTime;
    Close;
  end;
  // Y M D W A C L S
  mDY := Copy(mDateCode, 1, 4);
  mDM := Copy(mDateCode, 5, 2);
  mDD := Copy(mDateCode, 7, 2);
  mDW := Copy(mDateCode, 9, 2);
  mDYW := Copy(mDateCode, 11, 3);
  mDK := IntToStr(DayofWeek(mDate));
  if CarryM.Count >= StrToInt(mDM) then
    mcDM := CarryM[StrToInt(mDM) - 1];
  if CarryD.Count >= StrToInt(mDD) then
    mcDD := CarryD[StrToInt(mDD) - 1];
  if CarryW.Count >= StrToInt(mDW) then
    mcDW := CarryW[StrToInt(mDW) - 1];
  if CarryK.Count >= StrToInt(mDK) then
    mcDK := CarryK[StrToInt(mDK) - 1];
  for I := Length(sSNCode) downto 1 do
  begin
    if sSNCode[I] = 'Y' then
    begin
      if Length(mDY) > 0 then
      begin
        sSNDef[I] := mDY[Length(mDY)];
        mDY := Copy(mDY, 1, Length(mDY) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'M' then
    begin
      if Length(mDM) > 0 then
      begin
        sSNDef[I] := mDM[Length(mDM)];
        mDM := Copy(mDM, 1, Length(mDM) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'm' then
    begin
      if Length(mcDM) > 0 then
      begin
        sSNDef[I] := mcDM[Length(mcDM)];
        mcDM := Copy(mcDM, 1, Length(mcDM) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'D' then
    begin
      if Length(mDD) > 0 then
      begin
        sSNDef[I] := mDD[Length(mDD)];
        mDD := Copy(mDD, 1, Length(mDD) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'd' then
    begin
      if Length(mcDD) > 0 then
      begin
        sSNDef[I] := mcDD[Length(mcDD)];
        mcDD := Copy(mcDD, 1, Length(mcDD) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'F' then
    begin
      if Length(mDYW) > 0 then
      begin
        sSNDef[I] := mDYW[Length(mDYW)];
        mDYW := Copy(mDYW, 1, Length(mDYW) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'W' then
    begin
      if Length(mDW) > 0 then
      begin
        sSNDef[I] := mDW[Length(mDW)];
        mDW := Copy(mDW, 1, Length(mDW) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'w' then
    begin
      if Length(mcDW) > 0 then
      begin
        sSNDef[I] := mcDW[Length(mcDW)];
        mcDW := Copy(mcDW, 1, Length(mcDW) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'K' then
    begin
      sSNDef[I] := mDK[1];
    end
    else if sSNCode[I] = 'k' then
    begin
      if Length(mcDK) > 0 then
      begin
        sSNDef[I] := mcDK[Length(mcDK)];
        mcDK := Copy(mcDK, 1, Length(mcDK) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'P' then
    begin
      if Length(sValue1) > 0 then
      begin
        sSNDef[I] := sValue1[Length(sValue1)];
        sValue1 := Copy(sValue1, 1, Length(sValue1) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'Q' then
    begin
      if Length(sValue2) > 0 then
      begin
        sSNDef[I] := sValue2[Length(sValue2)];
        sValue2 := Copy(sValue2, 1, Length(sValue2) - 1);
      end
      else
        sSNDef[I] := '0';
    end
    else if sSNCode[I] = 'R' then
    begin
      if Length(sValue3) > 0 then
      begin
        sSNDef[I] := sValue3[Length(sValue3)];
        sValue3 := Copy(sValue3, 1, Length(sValue3) - 1);
      end
      else
        sSNDef[I] := '0';
    end;
  end;
  mCodeNo := sSNDef;

  mDY := Copy(mDateCode, 1, 4);
  mDM := Copy(mDateCode, 5, 2);
  mDD := Copy(mDateCode, 7, 2);
  mDW := Copy(mDateCode, 9, 2);
  mDYW := Copy(mDateCode, 11, 3);
  mDK := IntToStr(DayofWeek(mDate));
  if CarryM.Count >= StrToInt(mDM) then
    mcDM := CarryM[StrToInt(mDM) - 1];
  if CarryD.Count >= StrToInt(mDD) then
    mcDD := CarryD[StrToInt(mDD) - 1];
  if CarryW.Count >= StrToInt(mDW) then
    mcDW := CarryW[StrToInt(mDW) - 1];
  if CarryK.Count >= StrToInt(mDK) then
    mcDK := CarryK[StrToInt(mDK) - 1];
  sSNCode := '';
  sSEQ := '';
  S := mCode;
  for I := 1 to Length(S) do
    if not (S[I] in ['Y', 'M', 'm', 'D', 'd', 'W', 'w', 'A', 'C', 'L', 'R', 'k', 'K', 'P', 'Q', 'F']) then
    begin
      sSNCode := sSNCode + S[I];
      sSEQ := sSEQ + Copy(mCodeNo, I, 1);
    end;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select Last_Number from all_sequences '
      + 'where sequence_name = ''' + UpperCase(sSeqName) + ''' '
      + 'and sequence_owner = user';
    Open;
    if IsEmpty then begin
      CreateSeq(sSeqName, Length(sSEQ) + 1, sSNCode, sSNDef);
      case iCycle of
        0:
          begin
            if Pos('D', mCode) <> 0 then
            begin
              if gsMark = '' then
                gsMark := mDD
              else if mDD <> gsMark then
                gsMark := mDD;
            end
            else if gsMark = '' then
              gsMark := mcDD
            else if mcDD <> gsMark then
              gsMark := mcDD;
          end;
        1:
          begin
            if Pos('W', mCode) <> 0 then
            begin
              if gsMark = '' then
                gsMark := mDW
              else if mDW <> gsMark then
                gsMark := mDW;
            end
            else if gsMark = '' then
              gsMark := mcDW
            else if mcDW <> gsMark then
              gsMark := mcDW;
          end;
        2:
          begin
            if Pos('M', mCode) <> 0 then
            begin
              if gsMark = '' then
                gsMark := mDM
              else if mDM <> gsMark then
                gsMark := mDM;
            end
            else if gsMark = '' then
              gsMark := mcDM
            else if mcDM <> gsMark then
              gsMark := mcDM;
          end;
        3:
          begin
            if gsMark = '' then
              gsMark := mDY
            else if mDY <> gsMark then
              gsMark := mDY;
          end;
      end;
    end else begin
      mDiv := Fieldbyname('Last_Number').AsInteger;
      if bReset then
      begin
        bReset := False;
        case iCycle of
          0:
            begin
              if Pos('D', mCode) <> 0 then
              begin
                if gsMark = '' then
                  gsMark := mDD
                else if mDD <> gsMark then
                begin
                  gsMark := mDD;
                  bReset := True;
                end;
              end else if Pos('K', UpperCase(mCode)) <> 0 then
              begin
                if gsMark = '' then
                  gsMark := mDK
                else if mDK <> gsMark then
                begin
                  gsMark := mDK;
                  bReset := True;
                end;
              end
              else if gsMark = '' then
                gsMark := mcDD
              else if mcDD <> gsMark then
              begin
                gsMark := mcDD;
                bReset := True;
              end;
            end;
          1:
            begin
              if Pos('W', mCode) <> 0 then
              begin
                if gsMark = '' then
                  gsMark := mDW
                else if mDW <> gsMark then
                begin
                  gsMark := mDW;
                  bReset := True;
                end;
              end
              else if gsMark = '' then
                gsMark := mcDW
              else if mcDW <> gsMark then
              begin
                gsMark := mcDW;
                bReset := True;
              end;
            end;
          2:
            begin
              if Pos('M', mCode) <> 0 then
              begin
                if gsMark = '' then
                  gsMark := mDM
                else if mDM <> gsMark then
                begin
                  gsMark := mDM;
                  bReset := True;
                end;
              end
              else if gsMark = '' then
                gsMark := mcDM
              else if mcDM <> gsMark then
              begin
                gsMark := mcDM;
                bReset := True;
              end;
            end;
          3:
            begin
              if gsMark = '' then
                gsMark := mDY
              else if mDY <> gsMark then
              begin
                gsMark := mDY;
                bReset := True;
              end;
            end;
        end;
        if bReset then
        begin
          Close;
          Params.Clear;
          CommandText := ' drop sequence ' + sSeqName;
          Execute;
          Close;
          CreateSeq(sSeqName, Length(sSEQ) + 1, sSNCode, sSNDef);
        end;
      end;
    end;
    Close;
    SaveToDB('Reset Sequence Mark', '', gsMark, sModule, sRuleName);
  end;
  S := '';
  QryTemp.Close;
  QryTemp.Params.Clear;
  QryTemp.CommandText := 'SELECT ' + sSeqName + '.NEXTVAL SNID FROM DUAL ';
  QryTemp.Open;

  mDiv := QryTemp.Fieldbyname('SNID').AsInteger;

  for I := Length(sSNCode) downto 1 do
  begin
    if mDiv <> 0 then
    begin
      if sSNCode[I] = 'S' then
      begin
        if mCarry = '16' then
        begin
          mMod := mDiv mod 16;
          mDiv := mDiv div 16;
          if mMod = 0 then
            sSEQ[I] := '0'
          else
            sSEQ[I] := Carry16[mMod];
        end
        else
        begin
          mMod := mDiv mod 10;
          mDiv := mDiv div 10;
          if mMod = 0 then
            sSEQ[I] := '0'
          else
            sSEQ[I] := Carry16[mMod];
        end;
      end
      else
      begin
        for J := 0 to SNUdf.Count - 1 do
        begin
          if Copy(SNUdf.Strings[J], 1, 1) = sSNCode[I] then
          begin
            S := Trim(Copy(SNUdf.Strings[J], POS(':', SNUdf.Strings[J]) + 1, Length(SNUdf.Strings[J]) - POS(':', SNUdf.Strings[J])));
            mMod := mDiv mod Length(S);
            mDiv := mDiv div Length(S);
            if mMod = 0 then
              sSEQ[I] := S[1]
            else
              sSEQ[I] := S[mMod + 1];
            Break;
          end;
        end;
      end;
    end
    else
      if sSNCode[I] = 'S' then
        sSEQ[I] := '0'
      else begin
        for J := 0 to SNUdf.Count - 1 do
        begin
          if Copy(SNUdf.Strings[J], 1, 1) = sSNCode[I] then
          begin
            S := Trim(Copy(SNUdf.Strings[J], POS(':', SNUdf.Strings[J]) + 1, Length(SNUdf.Strings[J]) - POS(':', SNUdf.Strings[J])));
            sSEQ[I] := S[1];
            Break;
          end;
        end;
      end;
  end;

  S := mCode;
  S1 := mCodeNo;
  J := 1;
  for I := 1 to Length(S) do
    if not (S[I] in ['Y', 'M', 'm', 'D', 'd', 'W', 'w', 'A', 'C', 'L', 'R', 'k', 'K', 'P', 'Q', 'F']) then
    begin
      S1[I] := sSEQ[J];
      Inc(J);
    end;
  if Pos('X', S) <> 0 then
    with QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select ' + gsCheckSum + '(''' + S1 + ''') SNID from dual';
      Open;
      S1 := FieldByName('SNID').AsString;
      Close;
    end;
  Result := True;
  NewNo := S1;
end;


function TfMain.KillTask(ExeFileName: string): integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOLean;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
        OpenProcess(PROCESS_TERMINATE,
        BOOL(0),
        FProcessEntry32.th32ProcessID),
        0));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;


procedure TfMain.sbtnPalletCloseClick(Sender: TObject);
begin
  if edtPallet.Text ='' then exit;
  if lblPalletQty.Caption = '0' then
  begin
      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'PALLET_NO', ptInput);
        CommandText := 'delete from SAJET.G_PACK_PALLET ' +
          'WHERE PALLET_NO = :PALLET_NO ';
        Params.ParamByName('PALLET_NO').AsString := PalletNo;
        Execute;
        Close;
      end;
      msgPanel.Caption :='Delete Pallet [' + PalletNo + '] !';
      msgpanel.Font.Color :=clRed;
      msgpanel.Color := clYellow;
      GetPallet;
    end
    else
    begin
      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'PALLET_NO', ptInput);
        CommandText := 'UPDATE SAJET.G_PACK_PALLET ' +
          'SET CLOSE_FLAG = ''Y'' ' +
          'WHERE PALLET_NO = :PALLET_NO ';
        Params.ParamByName('PALLET_NO').AsString := PalletNo;
        Execute;

        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'PACK_NO', ptInput);
        Params.CreateParam(ftString, 'PACK_TYPE', ptInput);
        Params.CreateParam(ftString, 'EMP_ID', ptInput);
        CommandText := 'INSERT INTO SAJET.G_PACK_FORCECLOSE ' +
          '(PACK_NO, PACK_TYPE, EMP_ID) ' +
          'VALUES (:PACK_NO, :PACK_TYPE, :EMP_ID)';
        Params.ParamByName('PACK_NO').AsString := PalletNo;
        Params.ParamByName('PACK_TYPE').AsString := 'Pallet';
        Params.ParamByName('EMP_ID').AsString := UpdateUserID;
        Execute;
      end;
      // Print Label Here
      PrintPallet(edtPallet.Text);
      lblPalletQty.Caption := '0';
      GetPallet;
   end;
   sbtnCartonClose.Click;
end;
procedure TfMain.PrintPallet(Pallet_No:string);
var   PrintFile:string;
begin

   IsOpen :=false;
   PrintFile:= GetCurrentDir+'\\P_'+mPartNo+'.Lab';
   If not FileExists( PrintFile) then
   begin
         MessageDlg( 'Pallet Label ÀÉ®×¤£¦s¦b',mterror,[mbOK],0);
         IsOpen :=false;
         Exit;
   end;

   if IsStart then begin
      try
           BarApp.Visible:=false;
           BarDoc:=BarApp.ActiveDocument;
           BarVars:=BarDoc.Variables;
           BarDoc.Open(PrintFile);
           IsOpen :=true;
      except
           IsOpen :=false;
      end;

   end;

   if (IsStart) and (IsOpen) then begin
      BarDoc.Variables.Item('Pallet_NO').Value :=  edtPallet.Text;
      Bardoc.PrintLabel(1);
      Bardoc.FormFeed;
   end;

end;



function TfMain.GetCarton: Boolean;
begin
  Result := False;
  CartonNo := '';
  if not GetNewNo('Carton', CartonNo) then Exit;
  edtCarton.Text := CartonNo;
  lblCartonQty.Caption := InttoStr(StrToIntDef(lblCartonQty.Caption, 0));
  if CartonNo <> '' then
    AppendCartonNo;
  Result := True;

end;

procedure TfMain.AppendCartonNo;
begin
  if CartonNo = 'N/A' then Exit;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CARTON_NO', ptInput);
    CommandText := 'SELECT CARTON_NO ' +
      'FROM SAJET.G_PACK_CARTON ' +
      'WHERE CARTON_NO = :CARTON_NO and rownum = 1'; // rownum 2006.11.13 add
    Params.ParamByName('CARTON_NO').AsString := CartonNo;
    Open;
    if isEmpty then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'MODEL_ID', ptInput);
      Params.CreateParam(ftString, 'CARTON_NO', ptInput);
      Params.CreateParam(ftString, 'CLOSE_FLAG', ptInput);
      Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
      Params.CreateParam(ftString, 'CREATE_EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
      CommandText := 'INSERT INTO SAJET.G_PACK_CARTON ' +
        ' (WORK_ORDER, MODEL_ID, CARTON_NO, CLOSE_FLAG, TERMINAL_ID, CREATE_EMP_ID, PKSPEC_NAME) ' +
        'VALUES (:WORK_ORDER, :MODEL_ID, :CARTON_NO, :CLOSE_FLAG, :TERMINAL_ID, :CREATE_EMP_ID, :PKSPEC_NAME)';
      Params.ParamByName('WORK_ORDER').AsString := mWO;
      Params.ParamByName('MODEL_ID').AsString := mPartID;
      Params.ParamByName('CARTON_NO').AsString := CartonNo;
      Params.ParamByName('CLOSE_FLAG').AsString := 'N';
      Params.ParamByName('TERMINAL_ID').AsString := iTerminal;
      Params.ParamByName('CREATE_EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PKSPEC_NAME').AsString := sPKSpec;
      Execute;
      Close;
    end;
  end;
end;



procedure TfMain.edtGuitarKeyPress(Sender: TObject; var Key: Char);
var wo,part:string;
begin

  if Key <>#13 then exit;
  gCSN := UpperCase(Trim(edtGuitar.Text));
  if copy(gCSN,7,1)<>'G' then begin
      msgpanel.Caption := '¦N¥L±ø½X½s½X¿ù»~';
      msgpanel.Font.Color :=clRed;
      msgpanel.Color := clYellow;
      exit;
  end;
   with qrydata do begin
       close;
       params.clear;
       params.CreateParam(ftstring,'SN',ptInput);
       commandtext :='select a.work_order,SUBSTR(b.part_no,11,4) PART,B.PART_NO,b.PART_ID,a.serial_number from sajet.g_sn_status a,sajet.sys_part b where  '+
                       ' b.part_id=a.model_id and (serial_number = :sn or customer_sn =:sn) and work_flag=0';
       params.ParamByName('SN').AsString := gCSN;
       Open;

       PART_NO:= qrydata.fieldbyname('PART_NO').AsString;
       wo:= qrydata.fieldbyname('work_order').AsString;
       part := QryData.fieldbyname('PART').AsString;
       gPartID:= qrydata.fieldbyname('PART_ID').AsString;

       if Isempty then begin
            msgpanel.Caption := 'No SN';
            msgpanel.Font.Color :=clRed;
            msgpanel.Color := clYellow;
            edtGuitar.SelectAll;
            exit;
       end else
       begin
            gsn := fieldbyname('serial_number').AsString;
            if PART='0280' then begin
               msgPanel.Caption:='²£«~§ë¤J¤u³æ¬°'+WO+',¸Ó¤u³æ¬°¶Â¦â²£«~' ;
               msgPanel.Font.Color:=clwhite ;
               msgPanel.Color:=clBlack;
            end else
            if PART='0180' then begin
               msgPanel.Caption:='²£«~§ë¤J¤u³æ¬°'+WO+',¸Ó¤u³æ¬°¥Õ¦â²£«~'  ;
               msgPanel.Font.Color:=clBlack ;
               msgPanel.Color:=clwhite;
           end else
           if PART='0080' then begin
               msgPanel.Caption:='²£«~§ë¤J¤u³æ¬°'+WO+',¸Ó¤u³æ¬°¬õ¦â²£«~';
               msgPanel.Font.Color:=clBlack ;
               msgPanel.Color:=clRed;
           end;
       end;
       with qrytemp do begin
          close;
          params.clear;
          params.CreateParam(ftstring,'SN',ptInput);
          commandtext :='select * from sajet.g_sn_keyparts where item_part_sn =:SN and Enabled =''Y''';
          params.ParamByName('SN').AsString := edtGuitar.Text ;
          Open;
          gCSN :=edtGuitar.Text;
          if not IsEmpty then begin

            //­«·s¥´¦L
            sn :=fieldbyname('serial_number').Asstring;

            close;
            params.clear;
            params.CreateParam(ftstring,'SN',ptInput);
            commandtext :='select * from sajet.g_sn_STATUS where serial_number =:SN ';
            params.ParamByName('SN').AsString := sn ;
            Open;
            if isempty  then begin
                MessageDlg('Error ,NOT FIND CSN',mterror,[mbok],0);
                exit;
            end;
            csn := fieldbyname('CUSTOMER_SN').AsString;
            edtGuitar.SelectAll;


            sbtnPrint.Click;
            msgPanel.Color := clYellow;
            msgPanel.Caption := '­«·s¥´¦LOK';
            exit;
          end;

       end;
       edtDrum.Enabled :=true;
       edtDrum.SelectAll;
       edtDrum.SetFocus;
       edtGuitar.Enabled :=false;


   end;
end;

procedure TfMain.sbtnCartonCloseClick(Sender: TObject);
begin
    with qrydata do begin
        if lblCartonQty.Caption <> '0' then
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'CARTON_NO', ptInput);
          CommandText := 'UPDATE SAJET.G_PACK_CARTON ' +
            'SET CLOSE_FLAG = ''Y'' ' +
            'WHERE CARTON_NO = :CARTON_NO and rownum = 1'; // rownum 2006.11.13 add
          Params.ParamByName('CARTON_NO').AsString := CartonNo;
          Execute;

          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'PACK_NO', ptInput);
          Params.CreateParam(ftString, 'PACK_TYPE', ptInput);
          Params.CreateParam(ftString, 'EMP_ID', ptInput);
          CommandText := 'INSERT INTO SAJET.G_PACK_FORCECLOSE ' +
            '(PACK_NO, PACK_TYPE, EMP_ID) ' +
            'VALUES (:PACK_NO, :PACK_TYPE, :EMP_ID)';
          Params.ParamByName('PACK_NO').AsString := CartonNo;
          Params.ParamByName('PACK_TYPE').AsString := 'Carton';
          Params.ParamByName('EMP_ID').AsString := UpdateUserID;
          Execute;

        end else  begin

            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'CARTON_NO', ptInput);
            CommandText := 'delete from SAJET.G_PACK_CARTON ' +
              'WHERE CARTON_NO = :CARTON_NO ';
            Params.ParamByName('CARTON_NO').AsString := CartonNo;
            Execute;
            MessageDlg('Delete Carton [' + CartonNo + '] !', mtinformation,[mbok],0);

        end;

        lblCartonQty.Caption :='0';
        if not GetUnfinishCarton then
            GetCarton;
    end;

end;

procedure TfMain.SpeedButton1Click(Sender: TObject);
begin
   edtWO.Enabled :=true;
   edtwo.SetFocus;
   edtwo.SelectAll;
   edtGuitar.Enabled :=false;
   edtDrum.Enabled :=false;
end;

procedure TfMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    fLogin.Close;
end;

end.
