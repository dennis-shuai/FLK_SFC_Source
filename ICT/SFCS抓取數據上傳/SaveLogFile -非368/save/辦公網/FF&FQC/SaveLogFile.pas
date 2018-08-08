unit SaveLogFile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, MConnect, ObjBrkr, SConnect, StdCtrls, ExtCtrls,
  Buttons, DateUtils, IniFiles, IdGlobal, ComCtrls, IdBaseComponent,
  IdComponent, IdIPWatch,Winsock;

type
  TForm1 = class(TForm)
    SocketConnection1: TSocketConnection;
    SimpleObjectBroker1: TSimpleObjectBroker;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    Cmd_Start: TButton;
    Cmd_Exit: TButton;
    SProc: TClientDataSet;
    Button1: TButton;
    IdIPWatch1: TIdIPWatch;
    Edit1: TEdit;
    Edit2: TEdit;
    Button2: TButton;
    Edit3: TEdit;
    Panel1: TPanel;
    procedure Cmd_StartClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Cmd_ExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }

    function LoadApServer : Boolean;
    function InsertTestData(sSN,sTerminalID,sVersion,sStatus,sErrCode:string;ItemStr:array of string):string;
    function GetTerminalID(sIP:string):string;
    function GetIP:string;

  end;

var
  Form1: TForm1;

  mDate:string;
  FilePath:string;     //log���|
  ToSFCPath:string;    //�ഫ��SFC�榡���|
  bSajetSFC:string;    //�O�_�ഫ��SFC���    1:�O    0:�_

  mLine:Integer;
  TestItemAll:string;     //�аO�U���O���Ҧ����ն���

  mProgramS:string;

  SERVER_ID,GATEWAY_ID,diviceID,PDLine_ID,Process_ID:Integer;
  TERMINAL_ID:string;

  ModelName,sIP:string;
  LocalIP:string;



implementation

{$R *.dfm}

{ TForm1 }

function GetAppPath :String;
Begin
  Result:=ExtractFilePath(Application.ExeName);
end;


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

procedure TForm1.Cmd_StartClick(Sender: TObject);
var
   FpOpen,FpSave,FpSaveTime: TextFile;
   S,AllText:string;

   SerialCode,TestItem,mTestDate,mTestTime,TestVersion:string;

   StrStatus,ErrItem:string;

   TestDate:TDateTime;


  N1,N2,N3,N4:Integer;

  IsExists:Boolean;
  nSn,nItem,nVer,nDate,nTime,nErr:Integer;

  TestData:string;

  i :Integer;

  CopyFilePath:string;   //�O���{�ɴ_������|
  mSizeTest:integer;     //���j�p

  mDateNew:string;   //�O���ߤW12�G00���Z������A�P���e������@���

  iResult:string;


  ItemStr:array[1..150] of string;

  sFirst,sLast:string;
  sList:TStringList;
  strs: TStringList;
  parts: TStringList;
  strsFirst,strsLast:TStrings;
  SFCStr:string;
begin
    Application.ProcessMessages;

    strs := TStringList.Create;
    try
        strs.LoadFromFile(FilePath);
        if strs.Count>1 then   begin
            mLine:=strs.Count;
            sFirst:=strs[0];                  //�O�Y
            sLast:=strs[strs.Count-1];       //�̦Z�@��
            if trim(sFirst)<>'' then begin
                strsFirst := TStringList.Create;
                strsFirst.Delimiter := ' ';
                strsFirst.DelimitedText :=sFirst;
                for i := 0 to strsFirst.Count-1 do
                  IF i=0 then
                      nSn:=i
                  else if i=1 then begin
                      nItem:=i;
                      TestItemAll:=strsFirst[i]
                  end
                  else if strsFirst[i]='Version' THEN
                      nVer:=i
                  else if strsFirst[i]='Date' THEN
                      nDate:=i
                  else if strsFirst[i]='Time' THEN
                      nTime:=i
                  else if strsFirst[i]='Error_Code' then
                      nErr:=i;

                if trim(sLast)<>'' then begin
                    strsLast := TStringList.Create;
                    strsLast.Delimiter := ' ';
                    strsLast.DelimitedText :=sLast;
                    if strsFirst.Count<>strsLast.Count then begin
                        MessageBox(handle,Pchar('Error: �O�����ؼ�<>���Y���ؼơA�Фu�{�v�B�z! '),Pchar('System Hint'),MB_OK+MB_ICONEXCLAMATION+MB_SYSTEMMODAL);

                        exit;
                    end;
                    SerialCode:=trim(UpperCase(strsLast[nSn]));
                    TestItem:=strsLast[nItem];
                    TestVersion:=strsLast[nVer];
                    mTestDate:=strsLast[nDate];
                    mTestTime:=strsLast[nTime];
                    //TestDate:=StrToDateTime(copy(mTestDate,1,4) + '-' + copy(mTestDate,5,2) + '-' + copy(mTestDate,7,2) + ' ' + mTestTime);
                    if nErr<>0 then
                      strsLast[nErr];
                    For i:=1 to strsLast.Count-1 do
                      //ItemStr[i]:=strsFirst[i]+':'+ strsLast[i];
                      ItemStr[i]:=strsLast[i];

                    if  strsLast.Count<101 then begin
                      for i:=strsLast.Count to 100 do
                          ItemStr[i]:='';
                    end;

                end else begin
                    Cmd_Exit.Enabled:=TRUE;
                    Cmd_ExitClick(nil);
                end;
            end;
        end else begin
           strs.Free;
        end;
        strsFirst.Free;
        strsLast.Free;
    finally
        strs.free;
    end;

    if mLine>1 then begin   //�Ĥ@����D���g�J��Ʈw


        N1:=pos('X',TestItem);
        if N1=0 THEN BEGIN
            ErrItem:='0';
            StrStatus:='PASS';
        END ELSE BEGIN
            StrStatus:='FAIL';
            ErrItem:=Copy(TestItemAll,N1,1);
            //ErrItem:='OT01';
        END;
        if  ErrItem <>'0'  then
        begin
              
              QryTemp.Close;
              QryTemp.Params.Clear;
              QryTemp.CommandText := 'select * '
                     + ' from CCMSFIS.sys_Defect_TE@SFC2TE' ;
              QryTemp.Open;
              if not QryTemp.Eof then
              begin
                  QryTemp.First;
                  for i:=0 to QryTemp.recordcount-1 do begin
                      IF  ErrItem=QryTemp.FieldByName('DEFECT_Code').AsString then
                          ErrItem:=QryTemp.FieldByName('DEFECT_Code_SFC').asstring;
                      QryTemp.Next;
                  end;
              end else begin
                  ErrItem:='OT01';
              end;
        end;  

        //�g�JTE Server
       
       Terminal_ID:=GetTerminalID(LocalIP);
       if  Terminal_ID='' then
       begin
          MessageBox(handle,Pchar('ip:' + LocalIP + '  Error:�L�k���TerminalID'),Pchar('System Hint'),MB_OK+MB_ICONEXCLAMATION+MB_SYSTEMMODAL);
          Cmd_ExitClick(nil);
          Exit;
       end;
       iResult := InsertTestData(SerialCode,Terminal_ID,TestVersion,StrStatus,ErrItem,ItemStr);  //sLas����
       if iResult = 'OK' then
       begin
           if bSajetSFC ='1' then
           begin
               if not directoryexists('D:\SFC File Format') then
                          mkdir(   'D:\SFC File Format');
                SFCStr :='TTime='+FormatDateTime('yyyy/mm/dd_hh:mm:ss',Now)+';SN='+SerialCode+
                                ';Result='+strStatus+';ErrorCode='+ErrItem;

                AssignFile(FpSaveTime,'D:\SFC File Format\'+SerialCode+'.txt' );   //�Ыؤ奻���
                Rewrite(FpSaveTime);
                Writeln(FpSaveTime,SFCStr);
                CloseFile(FpSaveTime);
           end;
       end else begin
          MessageBox(handle,Pchar('Error:' + iResult),Pchar('System Hint'),MB_OK+MB_ICONEXCLAMATION+MB_SYSTEMMODAL);
          Cmd_ExitClick(nil);
          Exit;
       end;


       
      Cmd_Exit.Enabled:=TRUE;
      Cmd_ExitClick(nil);
    end;
end;

function TForm1.InsertTestData(sSN,sTerminalID,sVersion,sStatus,sErrCode:string;ItemStr:array of string):string;
begin
  try
      Result := 'Error';
      with SProc do
      begin

              Close;
              DataRequest('CCMSFIS.INSERT_TEST_DATA@SFC2TE');
              FetchParams;
              Params.ParamByName('TSN').AsString := sSN;
              Params.ParamByName('TTERMINAL_ID').AsString := sTerminalID;
              Params.ParamByName('TVERSION').AsString := sVersion;
              Params.ParamByName('TRESULT').AsString := sStatus;
              Params.ParamByName('TERRORCODE').AsString := sErrCode;
              Params.ParamByName('TVALUE1').AsString := ItemStr[0];
              Params.ParamByName('TVALUE2').AsString := ItemStr[1];
              Params.ParamByName('TVALUE3').AsString := ItemStr[2];
              Params.ParamByName('TVALUE4').AsString := ItemStr[3];
              Params.ParamByName('TVALUE5').AsString := ItemStr[4];
              Params.ParamByName('TVALUE6').AsString := ItemStr[5];
              Params.ParamByName('TVALUE7').AsString := ItemStr[6];
              Params.ParamByName('TVALUE8').AsString := ItemStr[7];
              Params.ParamByName('TVALUE9').AsString := ItemStr[8];
              Params.ParamByName('TVALUE10').AsString := ItemStr[9];
              Params.ParamByName('TVALUE11').AsString := ItemStr[10];
              Params.ParamByName('TVALUE12').AsString := ItemStr[11];
              Params.ParamByName('TVALUE13').AsString := ItemStr[12];
              Params.ParamByName('TVALUE14').AsString := ItemStr[13];
              Params.ParamByName('TVALUE15').AsString := ItemStr[14];
              Params.ParamByName('TVALUE16').AsString := ItemStr[15];
              Params.ParamByName('TVALUE17').AsString := ItemStr[16];
              Params.ParamByName('TVALUE18').AsString := ItemStr[17];
              Params.ParamByName('TVALUE19').AsString := ItemStr[18];
              Params.ParamByName('TVALUE20').AsString := ItemStr[19];
              Params.ParamByName('TVALUE21').AsString := ItemStr[20];
              Params.ParamByName('TVALUE22').AsString := ItemStr[21];
              Params.ParamByName('TVALUE23').AsString := ItemStr[22];
              Params.ParamByName('TVALUE24').AsString := ItemStr[23];
              Params.ParamByName('TVALUE25').AsString := ItemStr[24];
              Params.ParamByName('TVALUE26').AsString := ItemStr[25];
              Params.ParamByName('TVALUE27').AsString := ItemStr[26];
              Params.ParamByName('TVALUE28').AsString := ItemStr[27];
              Params.ParamByName('TVALUE29').AsString := ItemStr[28];
              Params.ParamByName('TVALUE30').AsString := ItemStr[29];
              Params.ParamByName('TVALUE31').AsString := ItemStr[30];
              Params.ParamByName('TVALUE32').AsString := ItemStr[31];
              Params.ParamByName('TVALUE33').AsString := ItemStr[32];
              Params.ParamByName('TVALUE34').AsString := ItemStr[33];
              Params.ParamByName('TVALUE35').AsString := ItemStr[34];
              Params.ParamByName('TVALUE36').AsString := ItemStr[35];
              Params.ParamByName('TVALUE37').AsString := ItemStr[36];
              Params.ParamByName('TVALUE38').AsString := ItemStr[37];
              Params.ParamByName('TVALUE39').AsString := ItemStr[38];
              Params.ParamByName('TVALUE40').AsString := ItemStr[39];
              Params.ParamByName('TVALUE41').AsString := ItemStr[40];
              Params.ParamByName('TVALUE42').AsString := ItemStr[41];
              Params.ParamByName('TVALUE43').AsString := ItemStr[42];
              Params.ParamByName('TVALUE44').AsString := ItemStr[43];
              Params.ParamByName('TVALUE45').AsString := ItemStr[44];
              Params.ParamByName('TVALUE46').AsString := ItemStr[45];
              Params.ParamByName('TVALUE47').AsString := ItemStr[46];
              Params.ParamByName('TVALUE48').AsString := ItemStr[47];
              Params.ParamByName('TVALUE49').AsString := ItemStr[48];
              Params.ParamByName('TVALUE50').AsString := ItemStr[49];
              Params.ParamByName('TVALUE51').AsString := ItemStr[50];
              Params.ParamByName('TVALUE52').AsString := ItemStr[51];
              Params.ParamByName('TVALUE53').AsString := ItemStr[52];
              Params.ParamByName('TVALUE54').AsString := ItemStr[53];
              Params.ParamByName('TVALUE55').AsString := ItemStr[54];
              Params.ParamByName('TVALUE56').AsString := ItemStr[55];
              Params.ParamByName('TVALUE57').AsString := ItemStr[56];
              Params.ParamByName('TVALUE58').AsString := ItemStr[57];
              Params.ParamByName('TVALUE59').AsString := ItemStr[58];
              Params.ParamByName('TVALUE60').AsString := ItemStr[59];
              Params.ParamByName('TVALUE61').AsString := ItemStr[60];
              Params.ParamByName('TVALUE62').AsString := ItemStr[61];
              Params.ParamByName('TVALUE63').AsString := ItemStr[62];
              Params.ParamByName('TVALUE64').AsString := ItemStr[63];
              Params.ParamByName('TVALUE65').AsString := ItemStr[64];
              Params.ParamByName('TVALUE66').AsString := ItemStr[65];
              Params.ParamByName('TVALUE67').AsString := ItemStr[66];
              Params.ParamByName('TVALUE68').AsString := ItemStr[67];
              Params.ParamByName('TVALUE69').AsString := ItemStr[68];
              Params.ParamByName('TVALUE70').AsString := ItemStr[69];
              Params.ParamByName('TVALUE71').AsString := ItemStr[70];
              Params.ParamByName('TVALUE72').AsString := ItemStr[71];
              Params.ParamByName('TVALUE73').AsString := ItemStr[72];
              Params.ParamByName('TVALUE74').AsString := ItemStr[73];
              Params.ParamByName('TVALUE75').AsString := ItemStr[74];
              Params.ParamByName('TVALUE76').AsString := ItemStr[75];
              Params.ParamByName('TVALUE77').AsString := ItemStr[76];
              Params.ParamByName('TVALUE78').AsString := ItemStr[77];
              Params.ParamByName('TVALUE79').AsString := ItemStr[78];
              Params.ParamByName('TVALUE80').AsString := ItemStr[79];
              Params.ParamByName('TVALUE81').AsString := ItemStr[80];
              Params.ParamByName('TVALUE82').AsString := ItemStr[81];
              Params.ParamByName('TVALUE83').AsString := ItemStr[82];
              Params.ParamByName('TVALUE84').AsString := ItemStr[83];
              Params.ParamByName('TVALUE85').AsString := ItemStr[84];
              Params.ParamByName('TVALUE86').AsString := ItemStr[85];
              Params.ParamByName('TVALUE87').AsString := ItemStr[86];
              Params.ParamByName('TVALUE88').AsString := ItemStr[87];
              Params.ParamByName('TVALUE89').AsString := ItemStr[88];
              Params.ParamByName('TVALUE90').AsString := ItemStr[89];
              Params.ParamByName('TVALUE91').AsString := ItemStr[90];
              Params.ParamByName('TVALUE92').AsString := ItemStr[91];
              Params.ParamByName('TVALUE93').AsString := ItemStr[92];
              Params.ParamByName('TVALUE94').AsString := ItemStr[93];
              Params.ParamByName('TVALUE95').AsString := ItemStr[94];
              Params.ParamByName('TVALUE96').AsString := ItemStr[95];
              Params.ParamByName('TVALUE97').AsString := ItemStr[96];
              Params.ParamByName('TVALUE98').AsString := ItemStr[97];
              Params.ParamByName('TVALUE99').AsString := ItemStr[98];
              Params.ParamByName('TVALUE100').AsString :=ItemStr[99];
              Execute;
              Result := Params.ParamByName('TRES').AsString;
      end;
  except on e:Exception do
      begin
        Result := 'Insert TestData Error : ' + e.Message;
      end;
  end;
end;

procedure TForm1.FormActivate(Sender: TObject);
var
    FpOpen: TextFile;
    CFgIniFile: TIniFile;
    IsExists:Boolean;
    FilePathFirst:string;
    FilePathTestConfig:string;  //���յ{��Config.txt
    TestProgVer:string; //���յ{������

    CONF_LIGHTBOX,CONF_FIXTURE,CONF_LIGHTPANEL:string;
    mLine,i,j:Integer;
    S:string;
    strs:TStrings;
    StationCode:string;
begin
    CFgIniFile:=nil;

    if Not FileExists(GetAppPath+'ConFig.Ini') then  Begin
         MessageBox(handle,Pchar('���~ ,ConFig.Ini��󤣦s�b! '),Pchar('System Hint'),MB_OK+MB_ICONEXCLAMATION+MB_SYSTEMMODAL);
         Cmd_ExitClick(nil);
         Exit;
    End;

    try
        CFgIniFile:=TIniFile.Create(GetAppPath+'ConFig.Ini');
        bSajetSFC:=CFGIniFile.ReadString('TestInfo','CONF_SAJET_SFC','');
        FilePathFirst:=CFGIniFile.ReadString('TestLogFile','LogFilePath','');
        FilePathFirst:=GetAppPath+FilePathFirst;

        if Copy( FilePathFirst,  length(FilePathFirst),1) <> '\' then
                  FilePathFirst :=FilePathFirst +'\';
    Finally
        CFgIniFile.Free;
    end;

    FilePathTestConfig:=GetAppPath + 'Config.txt';
    AssignFile(FpOpen, FilePathTestConfig);
    Reset(FpOpen);//���}���
    mLine:=0;
    while not EOF(FpOpen)do begin
        Readln(FpOpen,S);//Ū���@��奻
        if trim(S)<>'' THEN BEGIN
            mLine:=mLine+1;
            strs := TStringList.Create;
            strs.Delimiter := ' ';
            strs.DelimitedText := S;
            i:=0;
            j:=1;
            if strs[i]='CONF_PROJECT_NAME(CHAR)' then
                ModelName:=Strs[j]
            else if Strs[i]='CONF_STATION_SN(CHAR)' then
                CONF_LIGHTBOX:=Strs[j]
            else if Strs[i]='CONF_FIXTURE_SN(CHAR)' then
                CONF_FIXTURE:=Strs[j]
            else if Strs[i]='CONF_LIGHTPANEL_SN(CHAR)' then
                CONF_LIGHTPANEL:=Strs[j]
            else if Strs[i]='CONF_FILE_VERSION(CHAR)' then
                TestProgVer:=Strs[j]
            else if Strs[i]='CONF_CELL_INFO(CHAR)' then
                StationCode:=Strs[j];
            strs.Free;
        end;
    end;
    CloseFile(FpOpen);
    FilePath:=FilePathFirst+ModelName+'_'+mDate+'_'+StationCode+'_'+CONF_LIGHTBOX+'_'+CONF_FIXTURE+'_'+CONF_LIGHTPANEL+'.txt';

    IsExists:=FileExists(FilePath);
    if not IsExists then begin
        MessageBox(Application.Handle,Pchar(FilePath+'��󤣦s�b�I'),Pchar(Application.Title),MB_OK+MB_ICONEXCLAMATION+MB_SYSTEMMODAL);
        Cmd_ExitClick(nil);
    end ELSE begin
        LoadApServer;
        Cmd_Start.Enabled:=TRUE;
        Cmd_Start.SetFocus;
        Cmd_StartClick(nil);
    end;

end;

procedure TForm1.Cmd_ExitClick(Sender: TObject);
begin
Application.Terminate;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    mProgramS:=FormatDateTime('yyyy-mm-dd hh:nn:ss',now());
    ShortDateFormat:='yyyy_mm_dd';
    mDate:=DateTimetostr(Dateof(now()));
    Button2Click(nil);
    //LocalIP:=IdIPWatch1.LocalIP;
    LocalIP:=getip;
    //LocalIP:='172.16.8.253';    //MIC
    //LocalIP:='172.16.4.247';      //AOO

end;

procedure TForm1.Button1Click(Sender: TObject);
var
   Terminal_ID:string;
   sip:string;
begin
    //sip:=IdIPWatch1.LocalIP;

    sip:=getip;
    //Edit1.Text:= sip;
    Terminal_ID:=GetTerminalID(sip);
    Edit2.Text:= Terminal_ID;

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
     // ���q������
    CFgIniFile:=nil;
    if  FileExists(GetAppPath+'TerminalID.Ini') then  Begin
        try
            CFgIniFile:=TIniFile.Create(GetAppPath+'TerminalID.Ini');
            TERMINAL_ID:=CFGIniFile.ReadString('TerminalInfo','TerminalID','');
        Finally
            CFgIniFile.Free;
        end;
    End;
    if TERMINAL_ID<>'' then
    begin
        Result:=TERMINAL_ID;
    end else begin
       QryTemp.Close;
       QryTemp.Params.Clear;
       QryTemp.CommandText := 'SELECT  a.TERMINAL_ID,a.DEVICE_ID,b.SERVER_ID,b.GATEWAY_ID,CCMSFIS.GET_LONG@SFC2TE(b.rowid) IPADDR '
              +' FROM SAJET.TGS_TERMINAL_LINK A,SAJET.TGS_GATEWAY_BASE B '
              +' WHERE A.SERVER_ID =B.SERVER_ID AND A.GATEWAY_ID=B.GATEWAY_ID '
              +' AND (CCMSFIS.GET_LONG@SFC2TE(b.rowid) LIKE '+''''+'%;' + sIP + ',%'+''''
              + ' or CCMSFIS.GET_LONG@SFC2TE(b.rowid) LIKE '+''''+'%,' + sIP + ',%'+''''
              + ' or CCMSFIS.GET_LONG@SFC2TE(b.rowid) LIKE '+''''+'%,' + sIP + ';%'+''''
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
          if strs[i]=sIP then
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
          //�g TerminalID.ini  ���
           CFgIniFile:=nil;
           try
             CFgIniFile:=TIniFile.Create(GetAppPath+'TerminalID.Ini');
             CFGIniFile.WriteString('TerminalInfo','TerminalID',TERMINAL_ID);
           Finally
            CFgIniFile.Free;
           end;

          Result:= TERMINAL_ID ;
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

procedure TForm1.Button2Click(Sender: TObject);
begin
    Edit3.text:=GetIP;
end;

end.
