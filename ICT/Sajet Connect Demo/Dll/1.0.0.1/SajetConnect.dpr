library SajetConnect;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  StrUtils,
  Classes,
  IniFiles,
  Messages,
  DB,
  DBClient,
  MConnect,
  SConnect,
  ObjBrkr;

{$R *.res}
var
   qrySproc: TClientDataSet;
   smplbjctbrkr1: TSimpleObjectBroker;
   con1: TSocketConnection;
   IsStart,iLen:Integer;
   iMsg:string;
   sLine,sStage,sProcess,sTerminal:string;

function SajetTransStart: Boolean;stdcall;
var
   F,slogFile: TextFile;
   S,sfileName,slogfileName: string;
   i:Integer;
begin
    Result :=False;
    IsStart :=0;
    try
        if IsStart =0 then begin

            con1 := TSocketConnection.Create(nil);
            smplbjctbrkr1 := TSimpleObjectBroker.Create(nil);
            qrySproc := TClientDataSet.Create(nil);

            con1.Connected := False;
            for i:=0 to smplbjctbrkr1.Servers.count-1 do
             begin
               smplbjctbrkr1.Servers[i].Enabled :=false;
               smplbjctbrkr1.Servers[i].ComputerName :='';
               smplbjctbrkr1.Servers[i].Free;
            end;
            smplbjctbrkr1.Servers.Clear;
            con1.Host:='';
            con1.Address:='';
            con1.ObjectBroker :=smplbjctbrkr1;
            con1.ServerName :='SajetApserver.RMDB';

            qrySproc.RemoteServer :=con1;
            qrySproc.ProviderName :='DspStoreproc';
            sfileName := ExtractFilePath(ParamStr(0))+'ApServer.cfg';
            if  FileExists(sfileName) then
                AssignFile(F, sfileName)
            else
                exit;
            i:=0;
            Reset(F);
            while True do
            begin
               Readln(F, S);

               if trim(S) <> '' then
               begin
                  smplbjctbrkr1.Servers.Add;
                  smplbjctbrkr1.Servers[smplbjctbrkr1.Servers.Count-1].ComputerName := Trim(S);
                  smplbjctbrkr1.Servers[smplbjctbrkr1.Servers.Count-1].Enabled := True;

                  Inc(i);
               end else
               Break;
            end;
            CloseFile(F);
            IsStart :=1;
            slogfileName := ExtractFilePath(ParamStr(0))+'Log\SFCS_LOG_'+FormatDateTime('YYYYMMDDHH',Now)+'.log';
            if not DirectoryExists(ExtractFilePath(ParamStr(0))+'Log\') then
            begin
                ForceDirectories(ExtractFilePath(ParamStr(0))+'Log\');
            end;
            if not FileExists(slogfileName) then begin
               i :=FileCreate(slogfileName);
               FileClose(i);
            end;
            AssignFile(slogFile,slogfileName);
            Append(slogFile);
            Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  Start Connect OK');
            Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  Program:'+extractFileName(ParamStr(0)));
            closefile(slogFile);
        end;
    except
        IsStart :=0;
        Result :=False;
        Exit;
    end;


end;

function SajetTransData(f_iCommandNo:Integer;f_pData,f_pLen:pointer): Boolean;stdcall;
    procedure SplitString(src: string ; ch: Char; var stringList: TStringList);
    var
     p: Integer;
     s: string ;
    begin
       try
           stringList.Clear;
              s := src;
              repeat
               p := Pos(ch, s);
                  if p = 0 then begin
                   stringList.Add(s);
                      Break;
                  end ;
                  stringList.Add(LeftStr(s, p - 1));
                  s := RightStr(s, Length(s) - p);
              until False;
       except
           raise ;
       end ;
    end ;

var i,iGetLen:Integer;
   sStringList:TStringList;
   iFile:TIniFile;
   cfgFileName,slogfileName:string;
   slogFile: TextFile;
begin
    result :=False;
    iMsg :='';
    SetLength(iMsg,0);
    if IsStart =0 then
       SajetTransStart;
    if IsStart=1 then
    begin

        cfgFileName := ExtractFilePath(ParamStr(0))+'SajetConnect.ini';
        iFile := TIniFile.Create(cfgFileName);
        sTerminal := iFile.ReadString('Type 1','TerminalID','0');
        iFile.Free;

        if sTerminal ='0' then
        begin
             iMsg :='NG;No Find Terminal in IniFile';
             iLen := Length(iMsg);
             PInteger(f_pLen)^ := iLen;
             StrCopy(f_pData,PChar(iMsg));

             slogfileName := ExtractFilePath(ParamStr(0))+'Log\SFCS_LOG_'+FormatDateTime('YYYYMMDDHH',Now)+'.log';
             if not DirectoryExists(ExtractFilePath(ParamStr(0))+'Log\') then
             begin
                ForceDirectories(ExtractFilePath(ParamStr(0))+'Log\');
             end;
             if not FileExists(slogfileName) then begin
                  i :=FileCreate(slogfileName);
                  FileClose(i);
             end;
             AssignFile(slogFile,slogfileName);
             Append(slogFile);
             Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  No Find Terminal in IniFile');
             closefile(slogFile);

             Exit;

        end else begin

              sStringList := TStringList.Create;
              iMsg := PChar(f_pData);
              iLen := PInteger(f_pLen)^;
              SetLength(iMsg,iLen);
              SplitString(iMsg,';',sStringList);
              for i:=sStringList.Count to 5 do begin
                  sStringList.Add('N/A');
              end;

              try
                  with qrySproc do
                  begin

                      Close;
                      DataRequest('SAJET.sj_get_place');
                      FetchParams;
                      Params.ParamByName('TTERMINALID').AsString := sTerminal ;
                      Execute;

                      sStage :=   Params.ParamByName('pstage').AsString;
                      sProcess := Params.ParamByName('pprocess').AsString;
                      sLine :=    Params.ParamByName('Pline').AsString;
                  end;
                  if  sStage ='0' then begin
                      iMsg :='NG;No TerminalID';
                      iLen := Length(iMsg);
                      PInteger(f_pLen)^ := iLen;
                      StrCopy(f_pData,PChar(iMsg));

                       slogfileName := ExtractFilePath(ParamStr(0))+'Log\SFCS_LOG_'+FormatDateTime('YYYYMMDDHH',Now)+'.log';
                       if not DirectoryExists(ExtractFilePath(ParamStr(0))+'Log\') then
                       begin
                          ForceDirectories(ExtractFilePath(ParamStr(0))+'Log\');
                       end;
                       if not FileExists(slogfileName) then begin
                             i :=FileCreate(slogfileName);
                            FileClose(i);
                       end;
                       AssignFile(slogFile,slogfileName);
                       Append(slogFile);
                       Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  No TerminalID:'+sTerminal);
                       closefile(slogFile);
                       Exit;
                  end;

                  with qrySproc do
                  begin
                      Close;
                      DataRequest('SAJET.CCM_645_TEST_LINK');
                      FetchParams;
                      Params.ParamByName('TSAJET1').AsString := IntToStr(f_iCommandNo) ;
                      Params.ParamByName('TSAJET2').AsString :=  sStringList.Strings[0];
                      Params.ParamByName('TSAJET3').AsString :=  sStringList.Strings[1];
                      Params.ParamByName('TSAJET4').AsString :=  sStringList.Strings[2];
                      Params.ParamByName('TSAJET5').AsString :=  sStringList.Strings[3];
                      Params.ParamByName('TSAJET6').AsString :=  sStringList.Strings[4];
                      Params.ParamByName('TSAJET7').AsString :=  sStringList.Strings[5];
                      Params.ParamByName('TLINEID').AsString := sLine;
                      Params.ParamByName('TSTAGEID').AsString := sStage;
                      Params.ParamByName('TPROCESSID').AsString := sProcess ;
                      Params.ParamByName('TTERMINALID').AsString := sTerminal ;
                      Execute;
                      iMsg := Params.parambyName('TRES').AsString;
                  end;

                   slogfileName := ExtractFilePath(ParamStr(0))+'Log\SFCS_LOG_'+FormatDateTime('YYYYMMDDHH',Now)+'.log';
                   if not DirectoryExists(ExtractFilePath(ParamStr(0))+'Log\') then
                   begin
                       ForceDirectories(ExtractFilePath(ParamStr(0))+'Log\');
                   end;
                   if not FileExists(slogfileName) then begin
                       i :=FileCreate(slogfileName);
                       FileClose(i);
                   end;
                   AssignFile(slogFile,slogfileName);
                   Append(slogFile);
                   Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  Execute procedure:SAJET.CCM_645_TEST_LINK');
                   Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  TSAJET1:'+IntToStr(f_iCommandNo));
                   Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  TSAJET2:'+sStringList.Strings[0]);
                   Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  TSAJET3:'+sStringList.Strings[1]);
                   Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  TSAJET4:'+sStringList.Strings[2]);
                   Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  TSAJET5:'+sStringList.Strings[3]);
                   Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  TSAJET6:'+sStringList.Strings[4]);
                   Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  TSAJET7:'+sStringList.Strings[5]);
                   Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  TLINEID:'+sLine);
                   Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  TSTAGEID:'+sStage);
                   Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  TPROCESSID:'+sProcess);
                   Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  TTERMINALID:'+sTerminal);
                   Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  Execute result:'+iMsg);
                   closefile(slogFile);
                  iLen := Length(iMsg);
                  PInteger(f_pLen)^ := iLen;
                  StrCopy(f_pData,PChar(iMsg));
                  result :=True;
                  Exit;

              except
                  iMsg := 'Execute Error';
                  iLen := Length(iMsg);
                  PInteger(f_pLen)^ := iLen;
                  StrCopy(f_pData,PChar(iMsg));
                  sStringList.free;
                  result :=false;
                  Exit;
              end;
        end;
    end;

end;

function SajetTransClose: Boolean;stdcall;
var slogfileName:string;
slogFile:TextFile;
begin
   result :=false;
   try
        slogfileName := ExtractFilePath(ParamStr(0))+'Log\SFCS_LOG_'+FormatDateTime('YYYYMMDDHH',Now)+'.log';
        if not DirectoryExists(ExtractFilePath(ParamStr(0))+'Log\') then
        begin
                ForceDirectories(ExtractFilePath(ParamStr(0))+'Log\');
        end;
        if not FileExists(slogfileName) then
             FileCreate(slogfileName);
        AssignFile(slogFile,slogfileName);
        Append(slogFile);
        Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  Execute Close Connection');

        if IsStart=1 then begin
             con1.Connected := False;
             smplbjctbrkr1.Servers.Clear;
             con1.Host:='';
             con1.Address:='';
             qrySproc.Free;
             con1.Free;
             IsStart :=0;
             smplbjctbrkr1.Free;
             Writeln(slogFile,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  End Connection OK');

        end;
        closefile(slogFile);
        result :=true;
   except
       result :=false;
   end;

end;

exports
SajetTransStart,
SajetTransData,
SajetTransClose;


begin
end.
