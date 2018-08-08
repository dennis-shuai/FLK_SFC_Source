unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, MConnect, ObjBrkr, DB, DBClient,DateUtils,
  SConnect,IniFiles, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdFTP,IdFTPList,ShellAPI;

//---------------------------uMain----------------------------------
type
  TForm1 = class(TForm)
    Panel2: TPanel;
    btnSave: TBitBtn;
    btnUpload: TBitBtn;
    lbl4: TLabel;
    edtModel: TEdit;
    lbl5: TLabel;
    lbl6: TLabel;
    lblMac: TLabel;
    con1: TSocketConnection;
    smplbjctbrkr1: TSimpleObjectBroker;
    Qry1: TClientDataSet;
    mmo1: TMemo;
    dlgOpen1: TOpenDialog;
    Panl1: TLabel;
    Panl2: TLabel;
    Panl4: TLabel;
    cmbProcess: TComboBox;
    lblMsg: TLabel;
    idftp2: TIdFTP;
    lbl7: TLabel;
    edtIP: TEdit;
    lbl1: TLabel;
    edtSourcePath: TEdit;
    cmbLine: TComboBox;
    cmbSeg: TComboBox;
    lbl3: TLabel;
    edtPrefix: TEdit;
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnUploadClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    sEMPID,sModel,sSeg,sLine,sProcess,sSourcePath,sprefix,slogFile,slogFilePath,slogfileName:string;
    IsConnSvr,IsAdminLogin,IsUpload:Boolean;
    sSourceFilter:string;
    Function LoadApServer:Boolean;
    Function LoadSettings:Boolean;
    Function SaveSettings:Boolean;
    procedure CheckResult(b: Boolean);
    function RunDOS(const CommandLine: string): string;
    procedure SaveLogFile(msg:string);
    function UploadToFTP:Boolean;
    procedure CloseApServer;
    function ShellFileOperation(fromFile: string; toFile: string; Flags: Integer):Boolean;
    procedure UploadAFile(expFileName:string);
    procedure UploadLogFile;
    function FtpDirectoryExists(ADir: string): Boolean;
    function FtpReturnDir(ADir: string): Boolean;
    procedure ConnectToFTP;
    //procedure UpdateTerminalStatus;
    //procedure InsertLogData;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


Function TForm1.LoadSettings:Boolean;
var iFile:TiniFile;
begin
     iFile :=TIniFile.Create(ExtractFilePath(ParamStr(0))+'config.ini');
     sModel := iFile.ReadString('702H Upload','Model_Name','702H');
     sLine := iFile.ReadString('702H Upload','Line_Name','');
     sProcess := iFile.ReadString('702H Upload','Process_Name','');
     sPrefix := iFile.ReadString('702H Upload','Prefix','System8-TM-03336-001-');
     sSourcePath := iFile.ReadString('702H Upload','Source_Path','C:\ATPLogs\');
     edtIP.Text := iFile.ReadString('702H Upload','Server_IP','172.16.245.50');
     edtPrefix.Text := sPrefix;
     iFile.Free;
     edtModel.Text :=sModel;
     cmbLine.Text := sLine;
     edtSourcePath.Text := sSourcePath;
     cmbProcess.text :=sProcess;
end;

procedure TForm1.CloseApServer;
begin
    con1.Connected := False;
    smplbjctbrkr1.Servers.Clear;
    con1.Host:='';
    con1.Address:='';
end;

Function TForm1.SaveSettings:Boolean;
var iFile:TiniFile;
begin
    iFile :=TIniFile.Create(ExtractFilePath(ParamStr(0))+'config.ini');
    iFile.WriteString('702H Upload','Model_Name',edtModel.Text);
    iFile.WriteString('702H Upload','Line_Name',cmbLine.Text);
    iFile.WriteString('702H Upload','Process_Name',cmbProcess.text);
    iFile.WriteString('702H Upload','Source_Path',edtSourcePath.Text);
    iFile.WriteString('702H Upload','Prefix',edtPrefix.Text);
    iFile.WriteString('702H Upload','Server_IP',edtIP.Text);
    iFile.Free;
end;

function TForm1.LoadApServer: Boolean;
var F: TextFile;
   S,sfileName: string;
   i:Integer;
begin
   Result := False;
   mmo1.Lines.Add(' begin load file ');
   con1.Connected := False;
   //mmo1.Lines.Add(' Clear servers ');
   for i:=0 to smplbjctbrkr1.Servers.count-1 do
   begin
       smplbjctbrkr1.Servers[i].Enabled :=false;
       smplbjctbrkr1.Servers[i].ComputerName :='';
       smplbjctbrkr1.Servers[i].Free;
   end;
   smplbjctbrkr1.Servers.Clear;
   //mmo1.Lines.Add('End Clear  ');
   con1.Host:='';
   con1.Address:='';
   i:=0;
   sfileName := ExtractFilePath(ParamStr(0))+'ApServer.cfg';
   mmo1.Lines.Add(sfileName);
   if  FileExists(sfileName) then
     AssignFile(F, sfileName)
   else
     exit;

   Reset(F);
   while True do
   begin
      Readln(F, S);
      if trim(S) <> '' then
      begin
          smplbjctbrkr1.Servers.Add;
          //mmo1.Lines.Add('smplbjctbrkr1 begin add ');
          smplbjctbrkr1.Servers[smplbjctbrkr1.Servers.Count-1].ComputerName := Trim(S);
          smplbjctbrkr1.Servers[smplbjctbrkr1.Servers.Count-1].Enabled := True;
          mmo1.Lines.Add(smplbjctbrkr1.Servers[i].ComputerName);
          Inc(i);
      end else
        Break;
   end;
   //mmo1.Lines.Add('i= '+intTostr(i));
   CloseFile(F);
   Result := True;
end;



procedure TForm1.FormShow(Sender: TObject);
var sName:string;
begin
    //SetAutoRun;
    //MakeMeCritical(True);
    LoadSettings;
    slogFilePath :=  ExtractFilePath(ParamStr(0))+'log\';
    if not DirectoryExists(slogFilePath) then
      ForceDirectories(slogFilePath);

    lblMsg.Caption :=RunDOS('net use \\'+edtIp.Text+' "ccmsfc24550" /user:"administrator" ');
    SaveLogFile(lblMsg.Caption);
    lblMsg.Caption :=RunDOS('net time \\'+edtIp.Text+' /set /yes');
    SaveLogFile('Start To Upload File;');



    UploadToFTP;
    UploadLogFile;
    sName :=    ExtractFileName((ParamStr(0) ));
    if sName<> 'Settings.exe' then
       Application.Terminate;

    
end;

procedure TForm1.btnSaveClick(Sender: TObject);
begin
    SaveSettings;
end;


function TForm1.UploadToFTP:Boolean;
var sr: TSearchRec;
i:integer;
sFirstName:string;
begin
   

    idftp2.Host := edtIP.Text;
    i:=0;
    sFirstName :='';
    if FindFirst(sSourcePath+sPrefix+'*.tsum',faAnyfile,sr) = 0 then
    repeat
           Application.ProcessMessages;
           if ((sr.Name = '.') or (sr.Name = '..')) then Continue;
           SaveLogFile('Start Find File');
           if ((sr.Attr and faDirectory) = 0) then
           begin
               SaveLogFile('Find File:'+sr.Name);
               inc(i) ;
               if i=1 then begin
                   sFirstName :=  sr.Name ;
                   SaveLogFile('Find First File  '+sFirstName );
               end else if   sFirstName <  sr.Name then
               begin
                   sFirstName := sr.Name;
                   SaveLogFile('Find First File  '+sFirstName );
               end;

           end;
    until FindNext(sr)<>0;
    FindClose(sr);

    UploadAFile(sFirstName);



end;

procedure TForm1.ConnectToFTP;
var i:Integer;
begin
   idftp2.Host := edtIP.Text;
   i:=0;
   while (not idftp2.Connected) and (i<150) do
   begin
       Application.ProcessMessages;

       try
            idftp2.Connect();
            SaveLogFile('Connect Server: '+edtIP.Text+'  OK') ;

            try
                idftp2.ChangeDir('.\'+edtModel.Text);
                SaveLogFile('Change Server Path:'+edtModel.Text) ;
            except
                SaveLogFile('Can not find Server Path'+edtModel.Text) ;
                Exit;
            end;
       except
           SaveLogFile('Connect Server: '+edtIP.Text+'  Fail') ;
       end;

       inc(i);
   end;
end;

procedure TForm1.UploadAFile(expFileName:string);
var sr: TSearchRec;
sWillUpLoadFile,sTemp:string;
begin

     if FindFirst(sSourcePath+sPrefix+'*.*',faAnyfile,sr) = 0 then
    repeat
           Application.ProcessMessages;
           if ((sr.Name = '.') or (sr.Name = '..')) then Continue;
           SaveLogFile('Start Find File');
           if ((sr.Attr and faDirectory) = 0) then
           begin
               SaveLogFile('Find File:'+sr.Name);
               sTemp := Copy( expFileName,1,Length(expFileName)-5);
               if  Copy(Sr.Name,1,Length(sTemp))<> sTemp then begin
                   sWillUploadFile :=  sSourcePath +  Sr.Name ;
                   SaveLogFile('Start upload '+Sr.Name );
                   if not  idftp2.Connected then  ConnectToFTP;
                   idftp2.Put( sWillUpLoadFile, ExtractFileName(sWillUpLoadFile));
                   SaveLogFile( sWillUpLoadFile+'Upload Ok') ;

                    //if Copy(sr.Name,Length(sr.Name)-3,4) <> '.csv' then begin
                   SaveLogFile('Ready to  delete file:'+sWillUpLoadFile) ;
                   DeleteFile(sWillUpLoadFile);
               end;
           end;
    until FindNext(sr)<>0;
    FindClose(sr);

    if idftp2.Connected then begin
       idftp2.Disconnect;
       SaveLogFile('Close Ftp connection');
    end;
end;

function TForm1.FtpDirectoryExists(ADir: string): Boolean;
var
  index,iCount:Integer;
begin
     Index:=0;
     Result := false;
     try
         idftp2.List(nil);
         if Assigned(IdFtp2.DirectoryListing) then begin
             iCount := IdFtp2.DirectoryListing.Count;

             while Index<IdFtp2.DirectoryListing.Count do
             begin
                 with IdFtp2.DirectoryListing.Items[Index] do
                 begin
                     if (trim(FileName)=trim(ADir)) and (ItemType = ditDirectory)  then
                     begin
                       Result:=true;
                       Exit;
                     end;
                 end;
                 Index:=Index+1;
             end;
         end;
     except
         Result := False;
     end;
end;

function TForm1.FtpReturnDir(ADir: string): Boolean;
var
  i,index,iCount:Integer;
  IsFind:Boolean;
  sfileName:string;
  sDirList:TStringList;
begin
     Result := false;
     IsFind :=false;
     i:=0;
     while (not IsFind) and (i<5) do begin
         try
             idftp2.List(nil);
             Index :=0;
             if Assigned( idftp2.DirectoryListing) then
             begin
                 iCount := idftp2.DirectoryListing.Count;
                 while Index< iCount do
                 begin
                     with IdFtp2.DirectoryListing.Items[Index] do
                     begin
                         sfileName := FileName;
                         if (trim(FileName)=trim(ADir)) and (ItemType = ditDirectory)  then
                         begin
                             Result:=true;
                             IsFind :=True;
                             Exit;
                         end;
                     end;
                     Index:=Index+1;
                 end;
                 //IdFtp2.DirectoryListing.Free;
             end;
             inc(i);
             IdFTP2.ChangeDirUp;
         except
             Result := False;
         end;
     end;
end;


procedure TForm1.btnUploadClick(Sender: TObject);
begin
     UploadToFTP;
     UploadLogFile;
end;

procedure TForm1.SaveLogFile(msg:string);
var slog:TextFile;
i:Integer;
begin
   slogfileName := 'Line'+sLine+ '_'+sModel+'_'+ sProcess+'_'+FormatDateTime('YYYYMMDDHH',Now)+'.log';
   slogFile := slogFilePath +slogfileName;

   if not FileExists(slogFile) then begin
      i :=FileCreate(slogFile);
      FileClose(i);
   end;
   AssignFile(slog,slogFile);
   Append(slog);
   Writeln(slog,FormatDateTime('YYYY/MM/DD HH:MM:SS',Now)+'  '+msg);
   closefile(slog);
end;

procedure TForm1.UploadLogFile;
var  sr: TSearchRec;
begin
     idftp2.Disconnect;

     if FindFirst(ExtractFilePath(ParamStr(0))+'log\*',faAnyfile,sr) = 0 then
     repeat
           Application.ProcessMessages;
           if ((sr.Name = '.') or (sr.Name = '..')) then Continue;

           if ((sr.Attr and faDirectory) = 0) then
           begin

               if not idftp2.Connected then ConnectToFTP;
               idftp2.ChangeDirUp;
               idftp2.ChangeDirUp;
               idftp2.ChangeDir('.\log');
               idftp2.Put(ExtractFilePath(ParamStr(0))+'log\'+sr.Name,sr.Name);
               DeleteFile(ExtractFilePath(ParamStr(0))+'log\'+sr.Name);
           end;
     until FindNext(sr)<>0;
     FindClose(sr);

    if idftp2.Connected then begin
       idftp2.Disconnect;
    end;
end;


function TForm1.ShellFileOperation(fromFile: string; toFile: string; Flags: Integer):Boolean;
var
   shellinfo: TSHFileOpStructA;
begin
   Result :=false;
   with shellinfo do
   begin
     wnd    := Application.Handle;
     wFunc := Flags;
     pFrom := PChar(fromFile);
     pTo    := PChar(toFile);
   end;
   try
       SHFileOperation(shellinfo);
       Result :=True;
   except
       Result :=false;
   end;
end;

procedure TForm1.CheckResult(b: Boolean);
begin
  if not b then
    raise Exception.Create(SysErrorMessage(GetLastError));
end;

function TForm1.RunDOS(const CommandLine: string): string;
var  
  HRead, HWrite: THandle;  
  StartInfo: TStartupInfo;  
  ProceInfo: TProcessInformation;
  b: Boolean;  
  sa: TSecurityAttributes;  
  inS: THandleStream;  
  sRet: TStrings;  
begin  
  Result := '';
  FillChar(sa, sizeof(sa), 0);  
//设置允许继承，否则在NT和2000下无法取得输出结果
  sa.nLength := sizeof(sa);
  sa.bInheritHandle := True;  
  sa.lpSecurityDescriptor := nil;  
  b := CreatePipe(HRead, HWrite, @sa, 0);  
  CheckResult(b);  
   
  FillChar(StartInfo, SizeOf(StartInfo), 0);
  StartInfo.cb := SizeOf(StartInfo);  
  StartInfo.wShowWindow := SW_HIDE;  
//使用指定的句柄作为标准输入输出的文件句柄,使用指定的显示方式  
  StartInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;  
  StartInfo.hStdError := HWrite;  
  StartInfo.hStdInput := GetStdHandle(STD_INPUT_HANDLE); //HRead;  
  StartInfo.hStdOutput := HWrite;  
   
  b := CreateProcess(nil, //lpApplicationName: PChar
    PChar(CommandLine), //lpCommandLine: PChar  
    nil, //lpProcessAttributes: PSecurityAttributes  
    nil, //lpThreadAttributes: PSecurityAttributes  
    True, //bInheritHandles: BOOL
    CREATE_NEW_CONSOLE,
    nil,
    nil,  
    StartInfo,
    ProceInfo);  

  CheckResult(b);
  WaitForSingleObject(ProceInfo.hProcess, INFINITE);
   
  inS := THandleStream.Create(HRead);  
  if inS.Size > 0 then  
  begin  
    sRet := TStringList.Create;  
    sRet.LoadFromStream(inS);  
    Result := sRet.Text;  
    sRet.Free;  
  end;  
  inS.Free;  
   
  CloseHandle(HRead);  
  CloseHandle(HWrite);  
end;



end.
