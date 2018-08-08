unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls,DateUtils, DB, ADODB,
  ComCtrls;

type
  TfMain = class(TForm)
    PLSN1: TPanel;
    PLRT1: TPanel;
    Timer1: TTimer;
    stat1: TStatusBar;
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    sDate:string ;
    Function SendData(Serial_no,TIDNO,sResult,errorCode:string):String;
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

uses Login;

procedure TfMain.Timer1Timer(Sender: TObject);
var sr: TSearchRec;
sn,tidno,sresult,sFilePath,strDate,sRes:string;
i,j,iCount,iPos:integer;
strs,strsbak:TStringList;
begin
    
    sFilePath := ExtractFilePath(ParamStr(0))+'\logs\';

    strDate :=FormatDateTime('YYYYMMDD',Now());
    if FindFirst( sFilePath +strDate+'.log',faAnyFile,sr)=0 then begin
       repeat
         if (sr.Attr and faAnyFile) = sr.Attr then
         begin

            strs := TStringList.Create;
            try
                strs.LoadFromFile(sFilePath+'\'+sr.Name);
                iCount := strs.Count;
                if  iCount> 16 then
                begin

                     PLSN1.Caption :=  '';
                     PLRT1.Caption :=  '';
                     PLRT1.Color :=  clWhite;
                     if not directoryexists( sFilePath+'\BAK\') then
                        forcedirectories( sFilePath+'\BAK\');
                   

                     for i:=0 to iCount-1 do begin
                        if Trim(strs.Strings[i]) = '*********** Start the Initialize Key Check **********' then
                        begin
                           if Trim(strs.Strings[i+16]) = '*************************************************' then
                           begin
                               ipos :=  Pos('ProductS/N:  ',strs.Strings[i+4]);
                               if ipos >0 then begin
                                  sn :=   trim(Copy(strs.Strings[i+4],ipos+length('ProductS/N:  '),Length( strs.Strings[i+4])- ipos));
                               end;

                               ipos :=  Pos('TID: ',strs.Strings[i+5]);
                               if ipos >0 then
                               begin
                                  tidno :=   trim(Copy(strs.Strings[i+5],ipos+length('TID: '),Length( strs.Strings[i+5])- ipos));
                               end;

                               sResult :='PASS';
                               sRes:=SendData(sn,tidno,sResult,'');

                               if Copy(sRes,1,2) <>'OK' then
                               begin
                                   PLRT1.Color :=  clRed;
                               end else
                                   PLRT1.Color :=  clGreen;

                               PLSN1.Caption :=  sn;
                               PLRT1.Caption :=  sres;
                               strsbak :=TStringList.Create;

                               if fileexists(sFilePath+'\BAK\'+sr.Name) then
                               begin
                                     strsbak .LoadFromFile(sFilePath+'\BAK\'+sr.Name);
                               end;

                               for   j:=i to i+16 do begin
                                   strsbak.Add(strs.Strings[j]);
                                   strsbak.SaveToFile(sFilePath+'\BAK\'+sr.Name);

                               end;

                               for J:=i to i+16 do begin
                                   strs.Delete(i);
                               end;
                                strs.SaveToFile(sFilePath+'\'+sr.Name);
                                strsbak.Free;
                                Exit;

                           end else
                           begin
                               if Trim(strs.Strings[i+6]) = '*************************************************' then
                               begin
                                   strsbak :=TStringList.Create;
                                   if fileexists(sFilePath+'\BAK\'+sr.Name) then
                                   begin
                                         strsbak .LoadFromFile(sFilePath+'\BAK\'+sr.Name);
                                   end;

                                   for   j:=i to i+6 do begin
                                      strsbak.Add(strs.Strings[j]);
                                      strsbak.SaveToFile(sFilePath+'\BAK\'+sr.Name);

                                   end;
                                   for J:=i to i+6 do begin
                                      strs.Delete(i);
                                   end;
                                    strs.SaveToFile(sFilePath+'\'+sr.Name);
                                    strsbak.Free;
                                     Exit;
                               end;
                           end;
                           
                        end;

                     end;

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

Function TfMain.SendData(Serial_no,TIDNO,sResult,errorCode:string):String;
var sRes:string;
begin
    with fLogin.sproc do
    begin
        Close;
        DataRequest('SAJET.CCM_RT3T_PASS_NO_IDLE');
        FetchParams;
        Params.ParamByName('TSAJET1').AsString := '8';
        Params.ParamByName('TSAJET2').AsString := fLogin.edtUser.Text;
        Params.ParamByName('TSAJET3').AsString := '';
        Params.ParamByName('TSAJET4').AsString := Serial_no;
        Params.ParamByName('TSAJET5').AsString := TIDNO;
        Params.ParamByName('TSAJET6').AsString := sResult;
        Params.ParamByName('TSAJET7').AsString := errorCode;
        Params.ParamByName('TLINEID').AsString := fLogin.C_LINEID;
        Params.ParamByName('TSTAGEID').AsString := fLogin.C_STAGEID;
        Params.ParamByName('TPROCESSID').AsString := fLogin.C_PROCESSID;
        Params.ParamByName('TTERMINALID').AsString := fLogin.C_TERMINALID;
        Execute;
        sRes :=   Params.ParamByName('TRES').AsString;

    end;
    result := sRes;

end;


end.
