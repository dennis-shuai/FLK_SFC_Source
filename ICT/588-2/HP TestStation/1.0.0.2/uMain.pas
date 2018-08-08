unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls,DateUtils,IniFiles, DB, ADODB,
  ComCtrls;

type
  TfMain = class(TForm)
    PLSN1: TPanel;
    PLRT1: TPanel;
    Timer1: TTimer;
    connFox: TADOConnection;
    ADOSPROC1: TADOStoredProc;
    stat1: TStatusBar;
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    sUserID,sDate:string;
    Function GetComputer:String;
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

uses Login;

procedure TfMain.Timer1Timer(Sender: TObject);
var sr: TSearchRec;
sn,sresult,sFilePath,serrCode,strResult,Strconn,StrModel,StrStation,strResult1:string;
i,j:integer;
strs,strsFirst,strsLast,strsbak:TStringList;
sData ,sOrgError,sSendData,sStrRow: string;
k,m,iLen,iResult,ipos: integer;
CFgIniFile:TIniFile;
ItemStr:array[1..150] of string;
FpOpen: TextFile;
sTemp:string;
begin
    sFilePath :=  ExtractFilePath(Application.ExeName) + 'SFIS_log\';

    if FindFirst( sFilePath+'*.txt',faAnyFile,sr)=0 then
    begin
       //
      // repeat
          // Application.ProcessMessages;
          // Sleep(1000);
           if (sr.Attr and faAnyFile) = sr.Attr then
           begin
                SN :='';
                sResult :='';
                AssignFile(FpOpen, sFilePath+sr.Name);
                Reset(FpOpen);
                while not EOF(FpOpen)do
                begin
                    Readln(FpOpen,sTemp);
                    if trim(sTemp)<>'' then
                    begin
                        strs := TStringList.Create;
                        strs.Delimiter := ' ';
                        strs.DelimitedText := sTemp;
                        i:=0;
                        j:=1;
                        if Strs[i]='SERIAL(CHAR)'+#9 then
                            sn:=Copy(Trim(Strs[j]),1,14)
                        ELSE if Strs[i]='TESTRESULT(CHAR)' then
                            sresult:=Trim(UpperCase(Strs[j])) ;
                        strs.Free;
                    end;
                end;
                CloseFile(FpOpen);

                if sn ='' then
                begin
                    PLSN1.Caption :=  sn;
                    PLRT1.Caption :=  'SN is null';
                    PLRT1.Color :=  clRed;
                    stat1.SimpleText :='SN is null';
                    stat1.Color :=clRed;
                    Exit;
                end;

                if sresult ='' then
                begin
                    PLSN1.Caption :=  sn;
                    PLRT1.Caption :=  'Test Result is null';
                    PLRT1.Color :=  clRed;
                    stat1.SimpleText :='Test Result is null';
                    stat1.Color :=clRed;
                    Exit;
                end;


                if (sresult <>'PASS') and (sresult <>'FAIL') then begin
                    PLSN1.Caption :=  sn;
                    PLRT1.Caption :=  'Can not read Test Result:'+sresult;
                    PLRT1.Color :=  clRed;
                    stat1.SimpleText :='Can not read Test Result:'+sresult;
                    stat1.Color :=clRed;
                    Exit;
                end;

                if sResult <>'PASS' then sResult := sResult+ ';FT01';
                sSendData :=  fLogin.edtUser.Text+';;'+SN+';'+sResult;

                iLen:=Length(sSendData);
                sData :='';

                if iLen<1000 then SetLength(sData,100)
                else SetLength(sData,iLen);

                for m:=1 to iLen do sData[m]:=sSendData[m];

                iResult := SajetTransData(7,@sdata[1],@iLen);
                SetLength(sData,iLen);

               if iResult = 1 then
               begin
                  PLSN1.Caption :=  sn;
                  PLRT1.Caption :=  sData;
                  PLRT1.Color :=  clGreen;
                  stat1.SimpleText :=sData;
                  stat1.Color :=clGreen;
               end
               else
               begin
                   if sresult ='PASS' then
                   begin

                        SetLength(sData,iLen);
                        sOrgError :=  sData;
                                          
                        sData :='';

                        iLen:=Length(SN);

                        if iLen<1000 then SetLength(sData,100)
                        else SetLength(sData,iLen);

                        for m:=1 to iLen do sData[m]:=SN[m];

                        iResult :=  SajetTransData(9,@sdata[1],@iLen);

                        SetLength(sData,iLen);

                        if (iResult=1) and (Copy(sData,1,2)='OK') then
                        begin

                            if sResult <>'PASS' then sResult := sResult+ ';'+sErrCode;
                            sSendData :=  fLogin.edtUser.Text+';;'+SN+';'+sResult;

                            iLen:=Length(sSendData);
                            sData :='';

                             if iLen<1000 then SetLength(sData,100)
                             else SetLength(sData,iLen);

                            for m:=1 to iLen do sData[m]:=sSendData[m];

                            iResult := SajetTransData(7,@sdata[1],@iLen);
                            SetLength(sData,iLen);
                             if iResult =1 then
                             begin
                                 PLSN1.Caption :=  sn;
                                 PLRT1.Caption :=  sData;
                                 PLRT1.Color :=  clGreen;
                                 stat1.SimpleText :=sData;
                                 stat1.Color :=clGreen;
                             end else begin
                                  SetLength(sData,iLen);
                                  PLSN1.Caption :=  sn;
                                  PLRT1.Caption :=  sData;
                                  PLRT1.Color :=  clRed;
                                  stat1.SimpleText :=sData;
                                  stat1.Color :=clRed;
                             end;

                        end else begin
                             // SetLength(sData,iLen);
                              PLRT1.Color :=  clRed;
                              PLSN1.Caption :=  sn;
                              PLRT1.Caption :=  sOrgError;
                              stat1.SimpleText :=sOrgError;
                              stat1.Color :=clRed;

                        end;
                   end
                   else
                   begin
                       SetLength(sData,iLen);
                       PLSN1.Caption :=  sn;
                       PLRT1.Caption :=  sData;
                       PLRT1.Color :=  clRed;
                       stat1.SimpleText :=sData;
                       stat1.Color :=clRed;
                   end;


               end;
               if not DirectoryExists(sFilePath+'BAK\') then
                 ForceDirectories(sFilePath+'BAK\');
               if FileExists(sFilePath+'BAK\'+sr.Name) then
                  RenameFile(sFilePath+'BAK\'+sr.Name,sFilePath+'BAK\'+FormatDatetime('YYYY_MM_DD_HH_MM_SS',Now)+sr.Name) ;
               MoveFile(PChar(sFilePath+sr.Name),PChar(sFilePath+'BAK\'+sr.Name)) ;

           end;

       //until FindNext(sr) <>0;
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
begin
  sUserID :=GetComputer;
  sDate :=FormatDateTime('yyyymmdd',NOW());
end;

end.
