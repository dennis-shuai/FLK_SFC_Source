unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls,DateUtils, ComCtrls;

type
  TfMain = class(TForm)
    PLSN1: TPanel;
    PLSN2: TPanel;
    PLSN3: TPanel;
    PLSN4: TPanel;
    PLRT1: TPanel;
    PLRT2: TPanel;
    PLRT3: TPanel;
    PLRT4: TPanel;
    PLSN5: TPanel;
    PLSN6: TPanel;
    PLSN7: TPanel;
    PLSN8: TPanel;
    PLRT5: TPanel;
    PLRT6: TPanel;
    PLRT7: TPanel;
    PLRT8: TPanel;
    PLSN9: TPanel;
    PLSN10: TPanel;
    PLSN11: TPanel;
    PLSN12: TPanel;
    PLRT9: TPanel;
    PLRT10: TPanel;
    PLRT11: TPanel;
    PLRT12: TPanel;
    PLSN13: TPanel;
    PLSN14: TPanel;
    PLSN15: TPanel;
    PLSN16: TPanel;
    PLRT13: TPanel;
    PLRT14: TPanel;
    PLRT15: TPanel;
    PLRT16: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Timer1: TTimer;
    stat1: TStatusBar;
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

uses Login;

procedure TfMain.Timer1Timer(Sender: TObject);
var sr: TSearchRec;
sn,sresult,sFilePath,serrCode:string;
i,iCount:integer;
strs,strsFirst,strsbak:TStringList;
sData ,sOrgError,sSendData: string;
k,m,iLen: integer;
begin
    sFilePath :=  ExtractFilePath(Application.ExeName) + 'Result\'+FormatDateTime('yyyymmdd',NOW());

    if FindFirst( sFilePath+'\*.dat',faAnyFile,sr)=0 then begin
       repeat
           if (sr.Attr and faAnyFile) = sr.Attr then
           begin

              strs := TStringList.Create;
              try
                  strs.LoadFromFile(sFilePath+'\'+sr.Name);
                  if  strs.Count>= 3 then   begin
                       if strs.Count>19 then begin
                           k:=   strs.Count - 16 ;
                       end else
                           k :=3;

                       for i:=1 to 16 do begin
                           TPanel(FindComponent( 'PLSN' +IntToStr(i))).Caption :=  '';
                           TPanel(FindComponent( 'PLRT' +IntToStr(i))).Caption :=  '';
                           TPanel(FindComponent( 'PLRT' + IntToStr(i))).Color :=  clWhite;
                       end;

                       if not directoryexists( sFilePath+'\BAK\') then
                          forcedirectories( sFilePath+'\BAK\');

                          //SN,OK,351,0
                       for  i:=strs.Count-1  downto k do begin
                           if trim(strs.Strings[i])<>'' then begin
                              strsFirst := TStringList.Create;
                              strsFirst.Delimiter := ',';
                              strsFirst.DelimitedText :=strs.Strings[i];

                              if (Length(strsFirst.Strings[0]) =10)   and ( (Copy(strsFirst.Strings[0],1,1) ='P')
                                   or ( Copy(strsFirst.Strings[0],1,2) = 'SN')  or ( Copy(strsFirst.Strings[0],1,1) = 'M') ) then begin
                                   sn := strsFirst.Strings[0];
                                   if strsFirst.Strings[1] = 'OK' then
                                     sresult:='PASS'
                                   else begin
                                     sresult:='FAIL';
                                     serrCode :='AT01';
                                   end;

                                   if sResult <>'PASS' then sResult := sResult+ ';'+sErrCode;
                                   sSendData :=  fLogin.edtUser.Text+';;'+SN+';'+sResult;

                                   iLen:=Length(sSendData);
                                   sData :='';
                                    if iLen<1000 then SetLength(sData,100)
                                    else SetLength(sData,iLen);

                                    for m:=1 to iLen do sData[m]:=sSendData[m];
                                    SajetTransData(7,@sdata[1],@iLen);
                                    SetLength(sData,iLen);
                                    iCount :=0;
                                    if Copy(sData,1,2) ='OK' then
                                    begin
                                        TPanel(FindComponent('PLSN' + IntToStr(i-k+1))).Caption :=  sn;
                                        TPanel(FindComponent( 'PLRT' + IntToStr(i-k+1))).Caption :=  'OK';
                                        TPanel(FindComponent( 'PLRT' + IntToStr(i-k+1))).Color :=  clGreen;
                                    end
                                    else
                                    begin
                                         if sresult ='PASS' then
                                         begin
                                       
                                              SetLength(sData,iLen);
                                              sOrgError :=  sData;

                                              SetLength(sData,iLen);
                                              iLen:=Length(SN);

                                              for m:=1 to iLen do sData[m]:=SN[m];

                                              SajetTransData(9,@sdata[1],@iLen);

                                              SetLength(sData,iLen);

                                              if Copy(sData,1,2) ='OK' then
                                              begin
                                                  iLen:=Length(sSendData);
                                                  sData :='';
                                                  if iLen<1000 then SetLength(sData,100)
                                                  else SetLength(sData,iLen);

                                                  for m:=1 to iLen do sData[m]:=sSendData[m];
                                                  SajetTransData(7,@sdata[1],@iLen);
                                                  SetLength(sData,iLen);
                                                   if Copy(sData,1,2) ='OK' then
                                                   begin
                                                       TPanel(FindComponent('PLSN' + IntToStr(i-k+1))).Caption :=  sn;
                                                       TPanel(FindComponent( 'PLRT' + IntToStr(i-k+1))).Caption :=  'OK';
                                                       TPanel(FindComponent( 'PLRT' + IntToStr(i-k+1))).Color :=  clGreen;
                                                   end else begin
                                                       SetLength(sData,iLen);
                                                       TPanel(FindComponent( 'PLRT' + IntToStr(i-k+1))).Color :=  clRed;
                                                       TPanel(FindComponent('PLSN' + IntToStr(i-k+1))).Caption :=  sn;
                                                       TPanel(FindComponent( 'PLRT' + IntToStr(i-k+1))).Caption :=  sData;
                                                   end;
                                              end else begin
                                                   // SetLength(sData,iLen);
                                                    TPanel(FindComponent( 'PLRT' + IntToStr(i-k+1))).Color :=  clRed;
                                                    TPanel(FindComponent('PLSN' + IntToStr(i-k+1))).Caption :=  sn;
                                                    TPanel(FindComponent( 'PLRT' + IntToStr(i-k+1))).Caption :=  sOrgError;

                                              end;
                                         end
                                         else
                                         begin
                                             SetLength(sData,iLen);
                                             TPanel(FindComponent( 'PLRT' + IntToStr(i-k+1))).Color :=  clRed;
                                             TPanel(FindComponent('PLSN' + IntToStr(i-k+1))).Caption :=  sn;
                                             TPanel(FindComponent( 'PLRT' + IntToStr(i-k+1))).Caption :=  sData;
                                         end;
                                    end;

                              end;
                              strsFirst.Free;
                          end;
                          strsbak :=TStringList.Create;
                          if fileexists(sFilePath+'\BAK\'+sr.Name) then  begin
                             strsbak .LoadFromFile(sFilePath+'\BAK\'+sr.Name);
                             strsbak.Add(strs.Strings[i]);
                             strsbak.SaveToFile(sFilePath+'\BAK\'+sr.Name);
                          end;
                          strsbak.Free;
                          strs.Delete(i);
                      end;
                      strs.SaveToFile(sFilePath+'\'+sr.Name);
                  end;
              except
                  stat1.SimpleText :='Data Upload Error';
                  stat1.Color :=clRed;
                  //
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




end.
