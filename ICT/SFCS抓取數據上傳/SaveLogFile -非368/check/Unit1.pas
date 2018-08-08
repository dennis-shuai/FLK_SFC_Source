unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, MConnect, ObjBrkr, SConnect, StdCtrls, ExtCtrls,
  Buttons, DateUtils, IniFiles, IdGlobal, ComCtrls, IdBaseComponent,IdComponent, Winsock;


type
  TForm1 = class(TForm)
    SocketConnection1: TSocketConnection;
    SimpleObjectBroker1: TSimpleObjectBroker;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    Cmd_Start: TButton;
    Cmd_Exit: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Cmd_ExitClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Cmd_StartClick(Sender: TObject);
  private
    { Private declarations }
    function IsFileInUse(fName: string): boolean;
  public
    { Public declarations }
    function LoadApServer : Boolean;
    function GetTerminalID(sIP:string):string;
    function GetIP:string;

    function CheckSN(sSN,sTerminalID:string):string;
   // function CheckSNandSensorID(sSN,sSensorID,sTerminalID:string):string;

  end;

var
  Form1: TForm1;

  LocalIP:string;
  TERMINAL_ID:string;
  Process_ID:string;
  SERVER_ID,GATEWAY_ID,diviceID:Integer;

  SerialCode:string;
  SensorID:string;
  StatusProgram:integer;      //StatusProgram=1  OK   StatusProgram=2   報錯
  ErrMsg:string;  //記錄出錯信息


implementation

{$R *.dfm}

function TForm1.LoadApServer: Boolean;
var
  F : TextFile;
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

procedure TForm1.FormCreate(Sender: TObject);
begin
    //mProgramS:=FormatDateTime('yyyy-mm-dd hh:nn:ss',now());
    //ShortDateFormat:='yyyy_mm_dd';
    //mDate:=DateTimetostr(Dateof(now()));

    
end;

function GetAppPath :String;
Begin
  Result:=ExtractFilePath(Application.ExeName);
end;

function TForm1.GetTerminalID(sIP: string): string;
var
  i:Integer;
  ALLIP:string;
  strs:TStrings;

  CFgIniFile: TIniFile;
  IsExists:Boolean;
begin
     Result:='';
     // 先從文件中獲取
    CFgIniFile:=nil;
    if  FileExists(GetAppPath+'TerminalID.Ini') then  Begin
        try
            CFgIniFile:=TIniFile.Create(GetAppPath+'TerminalID.Ini');
            TERMINAL_ID:=CFGIniFile.ReadString('TerminalInfo','TerminalID','');
            Process_ID:=CFGIniFile.ReadString('ProcessInfo','Process_ID','')
        Finally
            CFgIniFile.Free;
        end;
    End;
    if TERMINAL_ID<>'' then
    begin
        Result:=TERMINAL_ID;
    end else begin
       //LocalIP:=getip;
       LocalIP:=getip;
       QryTemp.Close;
       QryTemp.Params.Clear;
       QryTemp.CommandText := 'SELECT  a.TERMINAL_ID,a.DEVICE_ID,b.SERVER_ID,b.GATEWAY_ID,CCMSFIS.GET_LONG@SFC2TE(b.rowid) IPADDR '
              +' FROM SAJET.TGS_TERMINAL_LINK A,SAJET.TGS_GATEWAY_BASE B '
              +' WHERE A.SERVER_ID =B.SERVER_ID AND A.GATEWAY_ID=B.GATEWAY_ID '
              +' AND (CCMSFIS.GET_LONG@SFC2TE(b.rowid) LIKE '+''''+'%;' + LocalIP + ',%'+''''
              + ' or CCMSFIS.GET_LONG@SFC2TE(b.rowid) LIKE '+''''+'%,' + LocalIP + ',%'+''''
              + ' or CCMSFIS.GET_LONG@SFC2TE(b.rowid) LIKE '+''''+'%,' + LocalIP + ';%'+''''
              + ')' ;

       QryTemp.Open;

       if not QryTemp.Eof then
       begin
          ALLIP:=QryTemp.FieldByName('IPADDR').AsString;
          SERVER_ID:=QryTemp.FieldByName('SERVER_ID').AsInteger;
          GATEWAY_ID:= QryTemp.FieldByName('GATEWAY_ID').AsInteger;
       end else begin
          SERVER_ID:=-1;
          GATEWAY_ID:=-1;
          Exit;
       end;
       strs:=tstringlist.create;
       strs.delimiter:=';' ;
       strs.delimitedText:=ALLIP ;
       ALLIP:=strs[1];
       strs.delimiter:=',' ;
       strs.delimitedText:=ALLIP ;
       for i:=0 to strs.count-1 do
       begin
          if strs[i]=LocalIP then
              diviceID:=i+1;
       end;

       QryTemp.First;
       for i:=0 to QryTemp.RecordCount-1 do
       begin
          if QryTemp.FieldByName('DEVICE_ID').asinteger=diviceID then
          begin
             TERMINAL_ID:= QryTemp.FieldByName('TERMINAL_ID').asstring;
          end;
          QryTemp.Next;
       end;
       if TERMINAL_ID<>'' then
       begin
           //
           QryTemp.Close;
           QryTemp.Params.Clear;
           QryTemp.CommandText := 'select PROCESS_ID from sajet.SYS_TERMINAL '
                                + ' where TERMINAL_ID='+''''+ TERMINAL_ID +'''';
           QryTemp.Open;
           if not QryTemp.Eof then
               Process_ID:=QryTemp.FieldByName('PROCESS_ID').asstring
           else
               Process_ID:='';
          if Process_ID<>'' then
          begin
          //寫 TerminalID.ini  文件
             CFgIniFile:=nil;
             try
               CFgIniFile:=TIniFile.Create(GetAppPath+'TerminalID.Ini');
               CFGIniFile.WriteString('TerminalInfo','TerminalID',TERMINAL_ID);
               CFGIniFile.WriteString('ProcessInfo','Process_ID',Process_ID);
             Finally
              CFgIniFile.Free;
             end;
             Result:= TERMINAL_ID ;
          end;
       end
       else
          Result:='';

    end;


end;


function TForm1.GetIP: string;
type
    TaPInAddr = array[0..10] of PInAddr; 
    PaPInAddr = ^TaPInAddr;
var 
    phe: PHostEnt;
    pptr: PaPInAddr;
    Buffer: array[0..63] of Char;
    i: Integer;
    GInitData: TWSAData;
    sResult:TStringList;
    ipCount:Integer;
begin
    Result:='';
    WSAStartup($101, GInitData);
    sResult := TstringList.Create;
    sResult.Clear;
    GetHostName(Buffer, SizeOf(Buffer));
    phe := GetHostByName(buffer);
    if phe = nil then Exit;
    pPtr := PaPInAddr(phe^.h_addr_list);
    i:= 0;
    while pPtr^[i] <> nil do
    begin 
      sResult.Add(inet_ntoa(pptr^[i]^));
      Inc(i); 
    end;
    WSACleanup;
    ipCount:=i;
    for i:=0 to ipCount-1 do
    begin
      //if Copy(sResult[i],1,11)='192.168.80.' then
      if Copy(sResult[i],1,7)='172.16.' then
          Result:= sResult[i];
    end;


end;

procedure TForm1.Cmd_ExitClick(Sender: TObject);
begin
    Application.Terminate;
end;


procedure TForm1.FormActivate(Sender: TObject);
begin
    
    Cmd_Start.Enabled:=TRUE;
    Cmd_Start.SetFocus;
    Cmd_StartClick(nil);
end;

procedure TForm1.Cmd_StartClick(Sender: TObject);
var
  mPreCheckPath,mtmppath:string;
  IsExists:Boolean;
  FpOpen: TextFile;

  sFirst,sLast:string;
  strs: TStringList;
  strsFirst:TStrings;

  iResult:string;

  Stemp,IDtemp:string;
  

begin
    Application.ProcessMessages;

    //檢測是否存在SfisFirstCheck.txt，此文件是由測試程式生成
    mPreCheckPath:=ExtractFilePath(Application.ExeName) + 'SfisFirstCheck.txt';
    IsExists:=FileExists(mPreCheckPath);
    if not IsExists then Begin
        MessageBox(handle,Pchar('Error: SfisFirstCheck.txt文件不存在! '),Pchar('System Hint'),MB_OK+MB_ICONEXCLAMATION+MB_SYSTEMMODAL);
        Cmd_ExitClick(nil);
        exit;
    end else begin
        //AssignFile(FpOpen, mPreCheckPath);
        {if isfileinuse(mprecheckpath)=true then
        begin
            sleep(50);
            repeat
                sleep(50);
            until IsFileInUse(mprecheckpath) = false;
        end;
        copyfile(pChar(mPreCheckPath),pChar(ExtractFilePath(Application.ExeName) + 'tmp.txt'),false);   //mike_hua
        mtmppath:=ExtractFilePath(Application.ExeName) + 'tmp.txt';    }
        strs := TStringList.Create;

        strs.LoadFromFile(mprecheckpath);
        if strs.Count>=1 then   begin
              sFirst:=strs[0];
              if trim(sFirst)<>'' then begin
                  strsFirst := TStringList.Create;
                  strsFirst.Delimiter := ' ';
                  strsFirst.DelimitedText :=sFirst;
                  if strsFirst.Count>=2 then
                     IDtemp:=trim(UpperCase(strsFirst[1]));
                  Stemp:=trim(UpperCase(strsFirst[0]));
              end;
        end else begin
             strs.Free;
        end;
        strsFirst.Free;
        strs.free;


        if ((STemp='') and (IDtemp='')) THEN
        BEGIN
              iResult:='條碼和SensorID不能為空';
        end;
        //LocalIP:=getip;
        LoadApServer;
        Terminal_ID:=GetTerminalID(LocalIP);

        
        if STemp<>'' THEN BEGIN
            SerialCode:=STemp;
            SensorID:='';
            iResult := CheckSN(SerialCode,Terminal_ID);
        end;
        if iResult='OK' then
        begin
            StatusProgram:=0;
            ErrMsg:=iResult;
        end else begin
            StatusProgram:=1;
            ErrMsg:=iResult;
        end;
        //保存結果
        AssignFile(FpOpen, mPreCheckPath);
        {if isfileinuse(mprecheckpath)=true then
        begin
              sleep(50);
              repeat
                sleep(50);
              until IsFileInUse(mprecheckpath) = false;
        end;    }
        Rewrite(FpOpen);  //打開文件
        Writeln(FpOpen,StatusProgram,'  ',ErrMsg);
        CloseFile(FpOpen);

    end;
    Cmd_ExitClick(nil);
    //deletefile(ExtractFilePath(Application.ExeName) + 'tmp.txt');
end;

function TForm1.CheckSN(sSN,sTerminalID:string):string;
begin
  try
      Result := 'Error';
      with SProc do
      begin
          Close;
          DataRequest('SAJET.SJ_CKRT_ROUTE');
          FetchParams;
          Params.ParamByName('TERMINALID').AsString := sTerminalID;
          Params.ParamByName('TSN').AsString := sSN;
          Execute;
          Result := Params.ParamByName('TRES').AsString;
      end;
      if Result='KS_REPAIR' then
      begin
         //判斷NG PROCESS_ID  和 當前測試PROCESS_ID是否相同，相同可以重測
         QryTemp.Close;
         QryTemp.Params.Clear;
         QryTemp.CommandText := 'select PROCESS_ID FROM SAJET.G_SN_STATUS '
                              + 'where SERIAL_NUMBER='+''''+ sSN +'''';
         QryTemp.Open;
         if not QryTemp.Eof then
         begin
            if  PROCESS_ID=QryTemp.FieldByName('PROCESS_ID').asstring then
              Result:='OK'
            else
              Result:='KS_REPAIR';
         end;
      end;
  except on e:Exception do
      begin
        Result := 'Check SN Error : ' + e.Message;
      end;
  end;
end;

function TForm1.IsFileInUse(fName: string): boolean;
var
  HFileRes: HFILE;
begin
  Result := false;
  if not FileExists(fName) then exit;
  HFileRes := CreateFile(pchar(fName), GENERIC_READ or GENERIC_WRITE,
    0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  Result := (HFileRes = INVALID_HANDLE_VALUE);
  if not Result then
  CloseHandle(HFileRes);
end;


end.
