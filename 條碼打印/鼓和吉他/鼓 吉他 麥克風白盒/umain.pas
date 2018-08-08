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
    lblPartNo: TLabel;
    Label5: TLabel;
    lblStation: TLabel;
    Qrytemp: TClientDataSet;
    Sproc: TClientDataSet;
    lstValue: TListBox;
    lstField: TListBox;
    Image4: TImage;
    SpeedButton1: TSpeedButton;
    lbl1: TLabel;
    edtMic: TEdit;
    procedure FormShow(Sender: TObject);
    procedure sbtnPrintClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtDrumKeyPress(Sender: TObject; var Key: Char);
    procedure edtWOKeyPress(Sender: TObject; var Key: Char);
    procedure edtGuitarKeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edtMicKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID,sFirstWO,sWO ,PART_NO,LAB,sProcess,sProcessID,iTerminal,PalletNo,CartonNo,sPKSpec,gPartID,gsn,gCSN,CSN,sn,mCSN:string;
    mWo,mPartId,mPartNo,mCode,mCodeNo,mCodeDef,gsCheckSum,mDateCode,Carry16:string;
    SNUdf,CarryM,CarryD,CarryW,CarryK: TStringList;
    BarApp,BarDoc,BarVars:variant;
    i_Count,count:integer;
    isStart,IsOpen:boolean;
    mCarry: string;
    //function LoadApServer: Boolean;
    function GetTerminalName(sTerminalID:string):string;
    function  KillTask(ExeFileName: string): integer;
   // procedure PrintPallet(Pallet_No:string);
  end;

var
  fMain: TfMain;

implementation

uses Login,uLogin;

{$R *.dfm}


procedure TfMain.FormShow(Sender: TObject);
var i:integer;
    iniFile:TiniFile;
begin
     qrytemp.RemoteServer :=ifLogin.SocketConnection1;
     qryData.RemoteServer :=ifLogin.SocketConnection1;
     sproc.RemoteServer :=ifLogin.SocketConnection1;
     UpdateUserID :=ifLogin.sEMPID;
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
      CommandText :='select a.pdline_name,b.process_name,b.PROCESS_ID,c.terminal_name,c.terminal_id  ' +
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
         sProcessID:= Fieldbyname('process_ID').AsString  ;
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
         MessageDlg('¥´¶}¤åÀÉ¿ù»~',mtError,[mbOK],0) ;
         IsOpen :=false;
         exit;
      end;
   end;

   if (IsStart) and (IsOpen) then begin
     try
        BarDoc.Variables.Item('D_SN').Value :=  CSN;
        BarDoc.Variables.Item('G_SN').Value :=  GCSN;
        BarDoc.Variables.Item('M_SN').Value :=  MCSN;
       // BarDoc.Variables.Item('PART_NO').Value :=  mPartNO;
        Bardoc.PrintLabel(1);
        Bardoc.FormFeed;
     except
        MessageDlg('¥´¦L±ø½X¿ù»~',mtError,[mbOK],0) ;
        Exit;
     end;
   end;
end;


procedure TfMain.FormDestroy(Sender: TObject);
begin

   if IsOpen then Bardoc.Close;
   if IsStart then  BarApp.Quit;

end;

procedure TfMain.edtDrumKeyPress(Sender: TObject; var Key: Char);
var wo,part,color,sRes:string;
    i:Integer;
begin
    if Key <>#13 then exit;
    CSN :=UpperCase(Trim(edtDrum.Text));
    if copy(CSN,7,1)<>'D' then
    begin
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

    with sproc do
    begin
        close;
        DataRequest('SAJET.SJ_CKRT_ROUTE');
        fetchParams;
        Params.ParamByName('TERMINALID').AsString :=iTerminal ;
        Params.ParamByName('TSN').AsString :=sn ;
        Execute;
    end;
    sRes :=  Sproc.Params.ParamByName('TRES').AsString ;
    if sRes <>'OK' then
    begin
         msgpanel.Caption := sRes;
         msgpanel.Font.Color :=clRed;
         msgpanel.Color := clYellow;
         edtDrum.SetFocus;
         edtDrum.SelectAll;

         with Qrytemp do
         begin
            //////////////////////////////////////////////////////////////////////
            close;
            params.clear;
            params.CreateParam(ftstring,'SN',ptInput);
            commandtext :='select SUBSTR(b.part_no,11,4) PART,a.work_order  from sajet.g_sn_status a,sajet.sys_part b where  '+
                             ' b.part_id=a.model_id and  serial_number = :sn  ';
            params.ParamByName('SN').AsString := sn;
            Open;
            wo:=  fieldbyname('work_order').AsString;
            part :=fieldbyname('PART').AsString;

            if Isempty then
            begin
                msgpanel.Caption := 'No SN';
                msgpanel.Font.Color :=clRed;
                msgpanel.Color := clYellow;
                edtDrum.SelectAll;
                exit;
            end;

            if wo<> edtwo.Text  then
            begin
                 msgPanel.Color :=clYellow;
                 msgPanel.Font.Color := clRed;
                 msgPanel.Caption := '¤u³æ¿ù»~'+ wo;
                 Exit;
            end;

            Close;
            Params.Clear;
            Params.CreateParam(ftString,'SN',ptInput);
            Params.CreateParam(ftString,'PROCESS',ptInput);
            CommandText := 'select ITEM_PART_SN from sajet.g_SN_KEYPARTS WHERE SERIAL_NUMBER = :SN' +
                           ' and ENABLED=''Y'' and PROCESS_ID =:PROCESS ';
            Params.ParamByName('SN').AsString :=SN;
            Params.ParamByName('PROCESS').AsString :=sPROCESSID;
            Open;

            if IsEmpty then Exit;

            if recordCount < 2 then begin
               MessageDlg('KeyParts ¼Æ¶q¤£¨¬',mtError,[mbOK],0);
               Exit;
            end;

            First;
            for i :=0 to  recordCount-1 do
            begin
               if Copy(fieldbyname('ITEM_PART_SN').AsString,1,2)='C1' then  gcsn:=fieldbyname('ITEM_PART_SN').AsString;
               if Copy(fieldbyname('ITEM_PART_SN').AsString,1,2)='T4' then  mcsn:=fieldbyname('ITEM_PART_SN').AsString;
               Next;
            end;
            CSN := edtDrum.Text;
            fLogin := TfLogin.Create(Self);
            if fLogin.ShowModal = mrOK then
            begin
                if (gcsn <>'') and (mCSN <> '') then
                begin
                    sbtnPrint.click;
                    msgPanel.Caption :='­«·s¥´¦LOK' ;
                    edtDrum.clear;
                    edtDrum.setfocus;
                    Exit;
                end;
            end else begin
                msgPanel.Caption :=sRes+',¨S¦³Åv­­­«·s¦C¦L' ;
                edtDrum.clear;
                edtDrum.setfocus;
                Exit;

            end;

            if gcsn = '' then begin
                msgPanel.Caption :='¦N¥L±ø½X¤£¥¿½T' ;
                edtDrum.clear;
                edtDrum.setfocus;
                Exit;
            end;

            if mcsn = '' then begin
                msgPanel.Caption :='³Á§J­·±ø½X¤£¥¿½T' ;
                edtDrum.clear;
                edtDrum.setfocus;
                Exit;
            end;


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

        if Isempty then
        begin
            msgpanel.Caption := 'No SN';
            msgpanel.Font.Color :=clRed;
            msgpanel.Color := clYellow;
            edtDrum.SelectAll;
            exit;
        end;

        if wo<> edtwo.Text  then
        begin
             msgPanel.Color :=clYellow;
             msgPanel.Font.Color := clRed;
             msgPanel.Caption := '¤u³æ¿ù»~'+ wo;
             Exit;
        end;

        if PART='0280' then
        begin
             msgPanel.Caption:='½Ð±½´y¶Â¦â²£«~' ;
             msgPanel.Font.Color:=clwhite ;
             msgPanel.Color:=clBlack;
         end else
         if PART='0180' then
         begin
             msgPanel.Caption:='½Ð±½´y¥Õ¦â²£«~'  ;
             msgPanel.Font.Color:=clBlack ;
             msgPanel.Color:=clwhite;
        end else if PART='0080' then
        begin
             msgPanel.Caption:='½Ð±½´y¬õ¦â²£«~';
             msgPanel.Font.Color:=clBlack ;
             msgPanel.Color:=clRed;
        end;

        edtGuitar.Enabled:=true;
        edtDrum.Enabled :=false;
        edtGuitar.SetFocus;

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
            if not Isempty then  begin
                edtWO.Text := FieldByName('WORK_ORDER').asstring;
            end;
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

        if (FieldByName('WO_STATUS').AsString = '3') or (FieldByName('WO_STATUS').AsString = '2') then
        begin
            mWO := FieldByName('WORK_ORDER').AsString;
            mPartID := FieldByName('MODEL_ID').AsString;
            mPartNO := FieldByName('PART_NO').AsString;
            LAB:='B_'+mPartNO+'.LAB';
            lblPartNo.Caption := mPartNO;
        end ;

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
    if Copy(lblPartNo.Caption,11,4) ='0280' then
    begin
         msgPanel.Caption:='½Ð±½´y¶Â¦â¹ª²£«~' ;
         msgPanel.Font.Color:=clwhite ;
         msgPanel.Color:=clBlack;
     end else
     if Copy(lblPartNo.Caption,11,4) ='0180' then
     begin
         msgPanel.Caption:='½Ð±½´y¥Õ¦â¹ª²£«~'  ;
         msgPanel.Font.Color:=clBlack ;
         msgPanel.Color:=clwhite;
    end else if Copy(lblPartNo.Caption,11,4) ='0080' then
    begin
         msgPanel.Caption:='½Ð±½´y¬õ¦â¹ª²£«~';
         msgPanel.Font.Color:=clBlack ;
         msgPanel.Color:=clRed;
    end;
    edtGuitar.Enabled :=false;
    edtMic.Enabled :=False;
    edtDrum.Enabled :=True;
    edtWO.Enabled :=false;
    edtDrum.SetFocus;
    
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


procedure TfMain.edtGuitarKeyPress(Sender: TObject; var Key: Char);
var wo,part:string;
begin

    if Key <>#13 then exit;
    gCSN := UpperCase(Trim(edtGuitar.Text));

    if copy(gCSN,1,2)<>'C1' then begin
        msgpanel.Caption := '¦N¥L±ø½X½s½X¿ù»~';
        msgpanel.Font.Color :=clRed;
        msgpanel.Color := clYellow;
        exit;
    end;

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

       part := QryData.fieldbyname('PART').AsString;

       if Copy(part,1,4) ='769A' then begin
            msgpanel.Caption := '¤£¯à¥]¦¨«~';
            msgpanel.Font.Color :=clRed;
            msgpanel.Color := clYellow;
            edtGuitar.SelectAll;
            exit;
       end;


       if Isempty then begin
            msgpanel.Caption := 'No SN';
            msgpanel.Font.Color :=clRed;
            msgpanel.Color := clYellow;
            edtGuitar.SelectAll;
            exit;
       end else
       begin
            gsn := fieldbyname('serial_number').AsString;
           { if PART<> Copy(mPartNo,11,4) then
            begin
               msgPanel.Caption:='¹ª©M¦N¥LÃC¦â¤£¤Ç°t' ;
               msgPanel.Font.Color:=clRed ;
               msgPanel.Color:=clYellow;
               exit;
            end ;
            }
       end;

       with qrytemp do
       begin
          close;
          params.clear;
          params.CreateParam(ftstring,'SN',ptInput);
          params.CreateParam(ftstring,'KeyPart',ptInput);
          commandtext :='select * from sajet.g_sn_keyparts where item_part_sn =:KeyPart and Enabled =''Y'' '+
                        ' and Serial_number <> :SN';
          params.ParamByName('sn').AsString := sn ;
          params.ParamByName('KeyPart').AsString := edtGuitar.Text ;
          Open;

          if not IsEmpty then
          begin
            MessageDlg('¸Ó±ø½X¤w¸g¸j©w',mterror,[mbok],0) ;
            edtGuitar.SelectAll;
            exit;
          end;

       end;
       

       edtDrum.Enabled :=false;
       edtMic.Enabled :=True;
       edtMic.SelectAll;
       edtMic.SetFocus;
       edtGuitar.Enabled :=false;

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
    ifLogin.Close;
end;

procedure TfMain.edtMicKeyPress(Sender: TObject; var Key: Char);
var sRes:string;
begin
    if Key <> #13 then Exit;
    if Length(edtMic.Text) <> 11 then
    begin
        MessageDlg('MIC±ø½Xªø«×¿ù»~',mterror,[mbok],0) ;
        edtMic.SelectAll;
        exit;

    end;

   if Copy(edtMic.Text,1,2) <> 'T4' then
    begin
        MessageDlg('MIC±ø½X½s½X­ì«h¿ù»~',mterror,[mbok],0) ;
        edtMic.SelectAll;
        exit;

    end;
    mCSN :=edtMic.Text;
    with qrytemp do
    begin
        close;
        params.clear;
        params.CreateParam(ftstring,'SN',ptInput);
        params.CreateParam(ftstring,'KeyPart',ptInput);
        commandtext := ' select * from sajet.g_sn_keyparts where item_part_sn =:KeyPart and Enabled =''Y'' '+
                       ' and Serial_number <> :SN';
        params.ParamByName('sn').AsString := sn ;
        params.ParamByName('KeyPart').AsString := edtMic.Text ;
        Open;

        if not IsEmpty then
        begin
            MessageDlg('¸Ó±ø½X¤w¸g¸j©w',mterror,[mbok],0) ;
            edtMic.SelectAll;
            exit;
        end;

    end;
    with sproc do begin
        close;
        DataRequest('SAJET.CCM_GO_TWO_KEYPARTS');
        fetchParams;
        Params.ParamByName('TTERMINALID').AsString :=iTerminal ;
        Params.ParamByName('TSN').AsString :=sn ;
       // Params.ParamByName('TPALLET_NO').AsString :=edtPallet.Text ;
       // Params.ParamByName('TCARTON_NO').AsString :=edtCarton.Text ;
        Params.ParamByName('TITEM_PART_SN1').AsString :=edtGuitar.Text ;
        Params.ParamByName('TITEM_PART_SN2').AsString :=edtMic.Text ;
        Params.ParamByName('TEMPID').AsString :=UpdateUserID ;
        Execute;
        sRes :=  Params.ParamByName('TRES').AsString ;

        if sRes <>'OK' then begin
           msgpanel.Caption := sRes;
           msgpanel.Font.Color :=clRed;
           msgpanel.Color := clYellow;
           edtMic.Clear;
           edtMic.SetFocus;
           exit;
        end;

        if Copy(lblPartNo.Caption,11,4) ='0280' then
        begin
             msgPanel.Caption:='½Ð±½´y¶Â¦â²£«~' ;
             msgPanel.Font.Color:=clwhite ;
             msgPanel.Color:=clBlack;
         end else
         if Copy(lblPartNo.Caption,11,4) ='0180' then
         begin
             msgPanel.Caption:='½Ð±½´y¥Õ¦â²£«~'  ;
             msgPanel.Font.Color:=clBlack ;
             msgPanel.Color:=clwhite;
        end else if Copy(lblPartNo.Caption,11,4) ='0080' then
        begin
             msgPanel.Caption:='½Ð±½´y¬õ¦â²£«~';
             msgPanel.Font.Color:=clBlack ;
             msgPanel.Color:=clRed;
        end;
    end;
    
    sbtnPrint.Click;

    edtDrum.Clear;
    edtGuitar.Clear;
    edtMic.Clear;
    edtGuitar.Enabled:=False;
    edtDrum.Enabled :=True;
    edtMic.Enabled:=False;
    edtDrum.SetFocus;
end;

end.
