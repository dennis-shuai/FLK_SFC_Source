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
sn,sresult,sFilePath,serrCode,strResult,Strconn,StrModel,StrStation:string;
i,iCount:integer;
strs,strsFirst,strsLast,strsbak:TStringList;
sData ,sOrgError,sSendData,sStrRow: string;
k,m,iLen,iResult,ipos: integer;
CFgIniFile:TIniFile;
ItemStr:array[1..150] of string;
begin
    sFilePath :=  ExtractFilePath(Application.ExeName) + 'Inspection_Result\'+SDate;

    if FindFirst( sFilePath+'\*.csv',faAnyFile,sr)=0 then begin
       repeat
         if (sr.Attr and faAnyFile) = sr.Attr then
         begin

            strs := TStringList.Create;
            try
                strs.LoadFromFile(sFilePath+'\'+sr.Name);
                iCount := strs.Count;
                if  iCount>= 2 then   begin

                     PLSN1.Caption :=  '';
                     PLRT1.Caption :=  '';
                     PLRT1.Color :=  clWhite;
                     if not directoryexists( sFilePath+'\BAK\') then
                        forcedirectories( sFilePath+'\BAK\');


                      if trim(strs.Strings[iCount-1])<>'' then begin


                          strsFirst := TStringList.Create;


                           sStrRow :=  strs.Strings[0];
                           K:=0;
                          while  K < 72 do
                          begin

                             iPos := Pos(',',sStrRow);

                             if iPos >=0 then
                             begin
                                  strsFirst.Add(Copy(sStrRow,1,iPos-1) ) ;
                                  sStrRow := Copy( sStrRow,iPos+1, Length(sStrRow)-iPos);
                                  K:=K+1;
                             end;

                          end;

                          strsLast := TStringList.Create;


                           sStrRow :=  strs.Strings[iCount-1];
                          K:=0;
                          while K < 72 do
                          begin
                             iPos := Pos(',',sStrRow);

                             if iPos >=0 then begin
                                  strsLast.Add(Copy(sStrRow,1,iPos-1) ) ;
                                  sStrRow := Copy( sStrRow,iPos+1, Length(sStrRow)-iPos);
                                  K:=K+1;
                             end;

                          end;

                          for k:=0 to  71 do begin

                              ItemStr[k]:= strsFirst[k] + ':'+ strsLast[k];

                          end;

                          //if iAllResult >0 then
                          strResult := strsLast.Strings[67];
                          sn := strsLast.Strings[1];

                          if (Length(sn) =10)   and (Copy(sn,1,2) ='SN')  and ( (strResult = 'OK') or (strResult = 'ALERT') ) then begin

                               if (strResult = 'OK') or (strResult = 'ALERT')   then
                                  sresult:='PASS'
                               else
                               begin
                                  sresult:='FAIL';
                                  serrCode :='FT01';
                               end;

                                if sResult <>'PASS' then sResult := sResult+ ';'+sErrCode;
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

                                          if iResult=1 then
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


                                //Upload Test Data
                                 CFgIniFile:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'SFCS_ConFig.Ini');
                                 Strconn:=CFGIniFile.ReadString('DataServ','StrConnServer','');
                                 StrModel:=CFGIniFile.ReadString('WorkOrder','Model','');
                                 strStation := CFGIniFile.ReadString('WorkOrder','TestStation','');
                                 connFox.Connected:=false;
                                 connFox.ConnectionString:=StrConn;
                                 connFox.Connected:=true;
                                 CFgIniFile.Free;


                                  ADOSPROC1.Parameters.ParamValues['@serialCode']:=SN;
                                  ADOSPROC1.Parameters.ParamValues['@Model']:=strModel;
                                  ADOSPROC1.Parameters.ParamValues['@WorkOrder']:='';
                                  ADOSPROC1.Parameters.ParamValues['@StationName']:=strStation;
                                  ADOSPROC1.Parameters.ParamValues['@UserID']:=sUserID;
                                  ADOSPROC1.Parameters.ParamValues['@Item1']:=ItemStr[1];
                                  ADOSPROC1.Parameters.ParamValues['@Item2']:=ItemStr[2];
                                  ADOSPROC1.Parameters.ParamValues['@Item3']:=ItemStr[3];
                                  ADOSPROC1.Parameters.ParamValues['@Item4']:=ItemStr[4];
                                  ADOSPROC1.Parameters.ParamValues['@Item5']:=ItemStr[5];
                                  ADOSPROC1.Parameters.ParamValues['@Item6']:=ItemStr[6];
                                  ADOSPROC1.Parameters.ParamValues['@Item7']:=ItemStr[7];
                                  ADOSPROC1.Parameters.ParamValues['@Item8']:=ItemStr[8];
                                  ADOSPROC1.Parameters.ParamValues['@Item9']:=ItemStr[9];
                                  ADOSPROC1.Parameters.ParamValues['@Item10']:=ItemStr[10];
                                  ADOSPROC1.Parameters.ParamValues['@Item11']:=ItemStr[11];
                                  ADOSPROC1.Parameters.ParamValues['@Item12']:=ItemStr[12];
                                  ADOSPROC1.Parameters.ParamValues['@Item13']:=ItemStr[13];
                                  ADOSPROC1.Parameters.ParamValues['@Item14']:=ItemStr[14];
                                  ADOSPROC1.Parameters.ParamValues['@Item15']:=ItemStr[15];
                                  ADOSPROC1.Parameters.ParamValues['@Item16']:=ItemStr[16];
                                  ADOSPROC1.Parameters.ParamValues['@Item17']:=ItemStr[17];
                                  ADOSPROC1.Parameters.ParamValues['@Item18']:=ItemStr[18];
                                  ADOSPROC1.Parameters.ParamValues['@Item19']:=ItemStr[19];
                                  ADOSPROC1.Parameters.ParamValues['@Item20']:=ItemStr[20];
                                  ADOSPROC1.Parameters.ParamValues['@Item21']:=ItemStr[21];
                                  ADOSPROC1.Parameters.ParamValues['@Item22']:=ItemStr[22];
                                  ADOSPROC1.Parameters.ParamValues['@Item23']:=ItemStr[23];
                                  ADOSPROC1.Parameters.ParamValues['@Item24']:=ItemStr[24];
                                  ADOSPROC1.Parameters.ParamValues['@Item25']:=ItemStr[25];
                                  ADOSPROC1.Parameters.ParamValues['@Item26']:=ItemStr[26];
                                  ADOSPROC1.Parameters.ParamValues['@Item27']:=ItemStr[27];
                                  ADOSPROC1.Parameters.ParamValues['@Item28']:=ItemStr[28];
                                  ADOSPROC1.Parameters.ParamValues['@Item29']:=ItemStr[29];
                                  ADOSPROC1.Parameters.ParamValues['@Item30']:=ItemStr[30];
                                  ADOSPROC1.Parameters.ParamValues['@Item31']:=ItemStr[31];
                                  ADOSPROC1.Parameters.ParamValues['@Item32']:=ItemStr[32];
                                  ADOSPROC1.Parameters.ParamValues['@Item33']:=ItemStr[33];
                                  ADOSPROC1.Parameters.ParamValues['@Item34']:=ItemStr[34];
                                  ADOSPROC1.Parameters.ParamValues['@Item35']:=ItemStr[35];
                                  ADOSPROC1.Parameters.ParamValues['@Item36']:=ItemStr[36];
                                  ADOSPROC1.Parameters.ParamValues['@Item37']:=ItemStr[37];
                                  ADOSPROC1.Parameters.ParamValues['@Item38']:=ItemStr[38];
                                  ADOSPROC1.Parameters.ParamValues['@Item39']:=ItemStr[39];
                                  ADOSPROC1.Parameters.ParamValues['@Item40']:=ItemStr[40];
                                  ADOSPROC1.Parameters.ParamValues['@Item41']:=ItemStr[41];
                                  ADOSPROC1.Parameters.ParamValues['@Item42']:=ItemStr[42];
                                  ADOSPROC1.Parameters.ParamValues['@Item43']:=ItemStr[43];
                                  ADOSPROC1.Parameters.ParamValues['@Item44']:=ItemStr[44];
                                  ADOSPROC1.Parameters.ParamValues['@Item45']:=ItemStr[45];
                                  ADOSPROC1.Parameters.ParamValues['@Item46']:=ItemStr[46];
                                  ADOSPROC1.Parameters.ParamValues['@Item47']:=ItemStr[47];
                                  ADOSPROC1.Parameters.ParamValues['@Item48']:=ItemStr[48];
                                  ADOSPROC1.Parameters.ParamValues['@Item49']:=ItemStr[49];
                                  ADOSPROC1.Parameters.ParamValues['@Item50']:=ItemStr[50];
                                  ADOSPROC1.Parameters.ParamValues['@Item51']:=ItemStr[51];
                                  ADOSPROC1.Parameters.ParamValues['@Item52']:=ItemStr[52];
                                  ADOSPROC1.Parameters.ParamValues['@Item53']:=ItemStr[53];
                                  ADOSPROC1.Parameters.ParamValues['@Item54']:=ItemStr[54];
                                  ADOSPROC1.Parameters.ParamValues['@Item55']:=ItemStr[55];
                                  ADOSPROC1.Parameters.ParamValues['@Item56']:=ItemStr[56];
                                  ADOSPROC1.Parameters.ParamValues['@Item57']:=ItemStr[57];
                                  ADOSPROC1.Parameters.ParamValues['@Item58']:=ItemStr[58];
                                  ADOSPROC1.Parameters.ParamValues['@Item59']:=ItemStr[59];
                                  ADOSPROC1.Parameters.ParamValues['@Item60']:=ItemStr[60];
                                  ADOSPROC1.Parameters.ParamValues['@Item61']:=ItemStr[61];
                                  ADOSPROC1.Parameters.ParamValues['@Item62']:=ItemStr[62];
                                  ADOSPROC1.Parameters.ParamValues['@Item63']:=ItemStr[63];
                                  ADOSPROC1.Parameters.ParamValues['@Item64']:=ItemStr[64];
                                  ADOSPROC1.Parameters.ParamValues['@Item65']:=ItemStr[65];
                                  ADOSPROC1.Parameters.ParamValues['@Item66']:=ItemStr[66];
                                  ADOSPROC1.Parameters.ParamValues['@Item67']:=ItemStr[67];
                                  ADOSPROC1.Parameters.ParamValues['@Item68']:=ItemStr[68];
                                  ADOSPROC1.Parameters.ParamValues['@Item69']:=ItemStr[69];
                                  ADOSPROC1.Parameters.ParamValues['@Item70']:=ItemStr[70];
                                  ADOSPROC1.Parameters.ParamValues['@Item71']:=ItemStr[71];
                                  ADOSPROC1.Parameters.ParamValues['@Item72']:=ItemStr[72];
                                  ADOSPROC1.Parameters.ParamValues['@Item73']:=ItemStr[73];
                                  ADOSPROC1.Parameters.ParamValues['@Item74']:=ItemStr[74];
                                  ADOSPROC1.Parameters.ParamValues['@Item75']:=ItemStr[75];
                                  ADOSPROC1.Parameters.ParamValues['@Item76']:=ItemStr[76];
                                  ADOSPROC1.Parameters.ParamValues['@Item77']:=ItemStr[77];
                                  ADOSPROC1.Parameters.ParamValues['@Item78']:=ItemStr[78];
                                  ADOSPROC1.Parameters.ParamValues['@Item79']:=ItemStr[79];
                                  ADOSPROC1.Parameters.ParamValues['@Item80']:=ItemStr[80];
                                  ADOSPROC1.Parameters.ParamValues['@Item81']:=ItemStr[81];
                                  ADOSPROC1.Parameters.ParamValues['@Item82']:=ItemStr[82];
                                  ADOSPROC1.Parameters.ParamValues['@Item83']:=ItemStr[83];
                                  ADOSPROC1.Parameters.ParamValues['@Item84']:=ItemStr[84];
                                  ADOSPROC1.Parameters.ParamValues['@Item85']:=ItemStr[85];
                                  ADOSPROC1.Parameters.ParamValues['@Item86']:=ItemStr[86];
                                  ADOSPROC1.Parameters.ParamValues['@Item87']:=ItemStr[87];
                                  ADOSPROC1.Parameters.ParamValues['@Item88']:=ItemStr[88];
                                  ADOSPROC1.Parameters.ParamValues['@Item89']:=ItemStr[89];
                                  ADOSPROC1.Parameters.ParamValues['@Item90']:=ItemStr[90];
                                  ADOSPROC1.Parameters.ParamValues['@Item91']:=ItemStr[91];
                                  ADOSPROC1.Parameters.ParamValues['@Item92']:=ItemStr[92];
                                  ADOSPROC1.Parameters.ParamValues['@Item93']:=ItemStr[93];
                                  ADOSPROC1.Parameters.ParamValues['@Item94']:=ItemStr[94];
                                  ADOSPROC1.Parameters.ParamValues['@Item95']:=ItemStr[95];
                                  ADOSPROC1.Parameters.ParamValues['@Item96']:=ItemStr[96];
                                  ADOSPROC1.Parameters.ParamValues['@Item97']:=ItemStr[97];
                                  ADOSPROC1.Parameters.ParamValues['@Item98']:=ItemStr[98];
                                  ADOSPROC1.Parameters.ParamValues['@Item99']:=ItemStr[99];
                                  ADOSPROC1.Parameters.ParamValues['@Item100']:=ItemStr[100];
                                  ADOSPROC1.Parameters.ParamValues['@Item101']:=ItemStr[101];
                                  ADOSPROC1.Parameters.ParamValues['@Item102']:=ItemStr[102];
                                  ADOSPROC1.Parameters.ParamValues['@Item103']:=ItemStr[103];
                                  ADOSPROC1.Parameters.ParamValues['@Item104']:=ItemStr[104];
                                  ADOSPROC1.Parameters.ParamValues['@Item105']:=ItemStr[105];
                                  ADOSPROC1.Parameters.ParamValues['@Item106']:=ItemStr[106];
                                  ADOSPROC1.Parameters.ParamValues['@Item107']:=ItemStr[107];
                                  ADOSPROC1.Parameters.ParamValues['@Item108']:=ItemStr[108];
                                  ADOSPROC1.Parameters.ParamValues['@Item109']:=ItemStr[109];
                                  ADOSPROC1.Parameters.ParamValues['@Item110']:=ItemStr[110];
                                  ADOSPROC1.Parameters.ParamValues['@Item111']:=ItemStr[111];
                                  ADOSPROC1.Parameters.ParamValues['@Item112']:=ItemStr[112];
                                  ADOSPROC1.Parameters.ParamValues['@Item113']:=ItemStr[113];
                                  ADOSPROC1.Parameters.ParamValues['@Item114']:=ItemStr[114];
                                  ADOSPROC1.Parameters.ParamValues['@Item115']:=ItemStr[115];
                                  ADOSPROC1.Parameters.ParamValues['@Item116']:=ItemStr[116];
                                  ADOSPROC1.Parameters.ParamValues['@Item117']:=ItemStr[117];
                                  ADOSPROC1.Parameters.ParamValues['@Item118']:=ItemStr[118];
                                  ADOSPROC1.Parameters.ParamValues['@Item119']:=ItemStr[119];
                                  ADOSPROC1.Parameters.ParamValues['@Item120']:=ItemStr[120];
                                  ADOSPROC1.Parameters.ParamValues['@Item121']:=ItemStr[121];
                                  ADOSPROC1.Parameters.ParamValues['@Item122']:=ItemStr[122];
                                  ADOSPROC1.Parameters.ParamValues['@Item123']:=ItemStr[123];
                                  ADOSPROC1.Parameters.ParamValues['@Item124']:=ItemStr[124];
                                  ADOSPROC1.Parameters.ParamValues['@Item125']:=ItemStr[125];
                                  ADOSPROC1.Parameters.ParamValues['@Item126']:=ItemStr[126];
                                  ADOSPROC1.Parameters.ParamValues['@Item127']:=ItemStr[127];
                                  ADOSPROC1.Parameters.ParamValues['@Item128']:=ItemStr[128];
                                  ADOSPROC1.Parameters.ParamValues['@Item129']:=ItemStr[129];
                                  ADOSPROC1.Parameters.ParamValues['@Item130']:=ItemStr[130];
                                  ADOSPROC1.Parameters.ParamValues['@Item131']:=ItemStr[131];
                                  ADOSPROC1.Parameters.ParamValues['@Item132']:=ItemStr[132];
                                  ADOSPROC1.Parameters.ParamValues['@Item133']:=ItemStr[133];
                                  ADOSPROC1.Parameters.ParamValues['@Item134']:=ItemStr[134];
                                  ADOSPROC1.Parameters.ParamValues['@Item135']:=ItemStr[135];
                                  ADOSPROC1.Parameters.ParamValues['@Item136']:=ItemStr[136];
                                  ADOSPROC1.Parameters.ParamValues['@Item137']:=ItemStr[137];
                                  ADOSPROC1.Parameters.ParamValues['@Item138']:=ItemStr[138];
                                  ADOSPROC1.Parameters.ParamValues['@Item139']:=ItemStr[139];
                                  ADOSPROC1.Parameters.ParamValues['@Item140']:=ItemStr[140];
                                  ADOSPROC1.Parameters.ParamValues['@Item141']:=ItemStr[141];
                                  ADOSPROC1.Parameters.ParamValues['@Item142']:=ItemStr[142];
                                  ADOSPROC1.Parameters.ParamValues['@Item143']:=ItemStr[143];
                                  ADOSPROC1.Parameters.ParamValues['@Item144']:=ItemStr[144];
                                  ADOSPROC1.Parameters.ParamValues['@Item145']:=ItemStr[145];
                                  ADOSPROC1.Parameters.ParamValues['@Item146']:=ItemStr[146];
                                  ADOSPROC1.Parameters.ParamValues['@Item147']:=ItemStr[147];
                                  ADOSPROC1.Parameters.ParamValues['@Item148']:=ItemStr[148];
                                  ADOSPROC1.Parameters.ParamValues['@Item149']:=ItemStr[149];
                                  ADOSPROC1.Parameters.ParamValues['@Item150']:=ItemStr[150];

                                  ADOSPROC1.ExecProc;
                                  
                                  if ADOSPROC1.Parameters.ParamValues['@outFlag'] =0 then begin
                                     stat1.SimpleText :=ADOSPROC1.Parameters.ParamValues['@Message'];
                                     stat1.Color :=clRed;

                                  end;

                           end;

                          strsFirst.Free;

                      end;

                      strsbak :=TStringList.Create;
                      if fileexists(sFilePath+'\BAK\'+sr.Name) then  begin
                           strsbak .LoadFromFile(sFilePath+'\BAK\'+sr.Name);
                      end;

                      strsbak.Add(strs.Strings[iCOunt-1]);
                      strsbak.SaveToFile(sFilePath+'\BAK\'+sr.Name);
                      strsbak.Free;

                      strs.Delete(iCount-1);
                      strs.SaveToFile(sFilePath+'\'+sr.Name);


                end;
            Except

            end;
            strs.free;
        end;
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
begin
  sUserID :=GetComputer;
  sDate :=FormatDateTime('yyyymmdd',NOW());
end;

end.
