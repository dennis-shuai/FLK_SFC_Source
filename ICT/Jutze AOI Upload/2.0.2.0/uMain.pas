unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls,DateUtils,IniFiles, DB, ADODB,
  ComCtrls, xmldom, XMLIntf, msxmldom, XMLDoc, RzCommon, RzSelDir,
  CoolTrayIcon;

type
  TfMain = class(TForm)
    PLRT1: TPanel;
    Timer1: TTimer;
    stat1: TStatusBar;
    xmldc1: TXMLDocument;
    Label1: TLabel;
    edtPath: TEdit;
    btn1: TBitBtn;
    rzsldrdlg1: TRzSelDirDialog;
    msgpnl: TPanel;
    cltrycn1: TCoolTrayIcon;
    SendMsgPnl: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UserName,sSN,sAllResult:string;
    b_TransResult,b_snResult :Boolean;
    Function GetComputer:String;
    procedure ShowMsg(sSendMsg,sRevMsg:string;b_SendResult,b_TestResult:Boolean);
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

uses Login;

procedure TfMain.Timer1Timer(Sender: TObject);
var sr: TSearchRec;
sn,sresult,sFilePath,serrCode,sSeq:string;
i:integer;
sData ,sDataError,sSendData,sStrRow: string;
k,m,iLen,ipos: integer;
CFgIniFile:TIniFile;
rootNode,NNode:IXMLNode;
CNodeList:IXMLNodeList;
b_iResult:Boolean;
begin
     SetWindowPos( Handle,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE);
    if Copy(edtPath.Text,Length(edtPath.Text),1) <>'\' then
        sFilePath :=   edtPath.Text+'\'
    else
        sFilePath :=   edtPath.Text;

    if FindFirst( sFilePath+'*.xml',faAnyFile,sr)=0 then
    begin
        repeat
           Application.ProcessMessages;
           if (sr.Attr and faAnyFile) = sr.Attr then
           begin
               try
                   try
                        xmldc1.Active :=True;
                        xmldc1.LoadFromFile(sFilePath+sr.Name);

                        xmldc1.Version :='1.0';
                        xmldc1.Encoding :='UTF-8';
                        rootNode := xmldc1.ChildNodes.FindNode('AOI');
                        CNodeList:=  rootNode.ChildNodes;
                        sDataError :='FAIL;';
                        //sAllResult :='PASS';
                        b_snResult :=true;
                        for i:=0 to CNodeList.Count-1 do
                        begin
                             NNode := CNodeList[i];
                             sn := NNode.ChildNodes['SN'].Text;
                             sresult := NNode.ChildNodes['RESULT'].Text;
                             serrCode := trim(NNode.ChildNodes['ERROR'].Text);
                             sSeq :=   NNode.ChildNodes['BOARD'].Text;

                             if ((sresult = 'FAIL') or  (sresult = 'SKIP')) and (serrCode <>'') then  begin
                                 sDataError := sDataError +sSeq+'@'+serrCode+'_' ;
                                 //sAllResult :='FAIL';
                                 b_snResult := false ;
                             end ;
                             if i=0 then begin
                                 ssn := sn;
                             end;
                             if ssn <> sn then begin
                                 ShowMsg('',sr.Name+'文件中SN不相同',False,False);
                             end;
                        end;
                        //xmldc1.
                        if sn ='' then begin
                             ShowMsg('','SN 不能為空',False,False);
                             Exit;
                        end;
                        if  not b_snResult then
                        begin
                             sSendData :=UserName +';;'+sn+';'+copy(sDataError,1,Length(sDataError)-1);
                        end else
                        begin
                             sSendData :=UserName +';;'+sn+';PASS';
                        end;

                        iLen:=Length(sSendData);
                        sData :='';

                        if iLen<1000 then SetLength(sData,1000)
                        else SetLength(sData,iLen);

                        for m:=1 to iLen do sData[m]:=sSendData[m];

                        b_iResult := SajetTransData(2,@sdata[1],@iLen);
                        SetLength(sData,iLen);

                        if b_iResult then
                             b_TransResult := (Copy(sData,1,2)= 'OK' )
                        else
                             b_TransResult :=false;
                         ShowMsg(sSendData,sData, b_TransResult,b_snResult);
                   Except
                        on E: Exception do
                        begin
                            b_TransResult :=False;
                            ShowMsg(sSendData,E.Message,false,False);
                        end;
                   end;
               finally
                   if b_TransResult then begin
                      if not DirectoryExists(sFilePath+'backup\')then
                        ForceDirectories(sFilePath+'backup\') ;
                        if FileExists(sFilePath+'backup\'+sr.Name) then
                           DeleteFile(sFilePath+'backup\'+sr.Name) ;
                      MoveFile(  PAnsiChar(sFilePath+sr.Name),PAnsiChar(sFilePath+'backup\'+sr.Name));
                   end else begin
                      if not DirectoryExists(sFilePath+'Error_Backup\')then
                        ForceDirectories(sFilePath+'Error_Backup\') ;
                      if FileExists(sFilePath+'Error_Backup\'+sr.Name) then
                           DeleteFile(sFilePath+'Error_Backup\'+sr.Name) ;
                      MoveFile(PAnsiChar(sFilePath+sr.Name),PAnsiChar(sFilePath+'Error_Backup\'+sr.Name));
                   end;
               end;

           end;
           Sleep(300);
        until FindNext(sr) <>0;
         FindClose(sr);
    end;
end;

procedure TfMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   fLogin.Close;
end;

Function TfMain.GetComputer:String;
   var  Buffer:Pchar;
        BufferLen:DWORD;
        StrName:String;
begin
     BufferLen:=  MAX_COMPUTERNAME_LENGTH+1 ;
     GetMem(Buffer,BufferLen);
     GetComputerName(Buffer,BufferLen);
     StrName:=StrPas(Buffer);
     FreeMem(Buffer,BufferLen);
     Result:=StrName;
end;


procedure TfMain.FormShow(Sender: TObject);
var
iniFile:TIniFile;
begin
   //sUserID :=GetComputer;

   stat1.Panels [0].Text := UserName;
   iniFile :=TIniFile.Create(ExtractFilePath(ParamStr(0))+'Settings.ini');
   edtPath.Text :=iniFile.ReadString('Settings','Path','D:\OUTPUTDATA');
   iniFile.Free;

end;

procedure TfMain.btn1Click(Sender: TObject);
var iniFile:TIniFile;
begin
   if (rzsldrdlg1.Execute)  then  begin
       edtPath.Text := rzsldrdlg1.Directory;
       iniFile :=TIniFile.Create(ExtractFilePath(ParamStr(0))+'Settings.ini');
       iniFile.WriteString('Settings','Path',edtPath.Text);
       iniFile.Free;
   end ;
end;

procedure TfMain.ShowMsg(sSendMsg,sRevMsg:string;b_SendResult,b_TestResult:Boolean);
begin
    SendMsgPnl.Caption := sSendMsg;
    msgpnl.Caption :=sRevMsg;
    if  not b_SendResult then begin
        msgpnl.Color :=clRed;
        msgpnl.Font.Color :=clBlack;
    end else begin
        msgpnl.Color :=clGreen;
        if  b_TestResult  then
            SendMsgPnl.Font.Color :=clBlue
        else
            SendMsgPnl.Font.Color :=clFuchsia;
    end;

    stat1.Panels[1].Text := sSN;
    stat1.Panels[2].Text := FormatDateTime('mm/dd hh:mm:ss',NOW);
end;

end.

