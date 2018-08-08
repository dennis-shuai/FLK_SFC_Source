unit UNewSajetConnet;

interface

uses   IniFiles,SysUtils,Windows;

type
  TNewSajetConnect = class(TObject)
  private
     { Private declarations }
      //FInstance: TNewSajetConnect;

  protected
    { Protected declarations }
  public
     class function NewSajetTransData(f_iCommandNo : integer;f_pData,f_pLen : pointer) : Boolean;
     class function NewSajetTransStart : Boolean;
     class function NewSajetTransClose : Boolean;

  end;


function SajetTransData(f_iCommandNo : integer;f_pData,f_pLen : pointer) : Boolean; stdcall; external 'SajetConnect_Old.dll';
function SajetTransStart : Boolean; stdcall;external 'SajetConnect_Old.dll';
function SajetTransClose : Boolean; stdcall;external 'SajetConnect_Old.dll';
//function GetConnected :Boolean;

//var IsConnect:Boolean;

implementation

class function TNewSajetConnect.NewSajetTransData(f_iCommandNo : integer;f_pData,f_pLen : pointer) : Boolean;
var inifile:TIniFile;
iTerminal:string;
sData:string;
iLen:Integer;
begin
   inifile :=TIniFile.Create('Sajet.ini');
   iTerminal :=inifile.ReadString('TGS Setup','Terminal','0');
   inifile.Free;
   sData := iTerminal+';'+PChar(f_pData);
   iLen := PInteger(f_pLen)^+Length(iTerminal+';');

   if iLen<1000 then SetLength(sData,1000)
   else SetLength(sData,iLen);

   Result :=   SajetTransData(f_iCommandNo,@sData[1],@iLen) ;

   SetLength(sData,iLen);

   PInteger(f_pLen)^ := iLen;
   StrCopy(f_pData,PChar(sData));

end;

 {
function GetConnected :Boolean;
var handle,i :integer;
CThread:Thandle;
Tid:DWord;
begin
   IsConnect :=False;
   i:=0;

   while  (not IsConnect) and ( i<300) do
   begin
       handle :=FindWindow( 'TformConnect','Connect Status ');
       if handle =0 then
           IsConnect :=true;
       Sleep(100);
       inc(i);
       if i>=300 then begin
           SajetTransClose;
       end;
   end;


end;  }


class function TNewSajetConnect.NewSajetTransStart : Boolean;
begin
    //;
    //CreateThread(nil,0,@GetConnected,nil,0,Tid);
    Result :=  SajetTransStart;
end;
class function TNewSajetConnect.NewSajetTransClose : Boolean;
begin
    Result :=   SajetTransClose ;
end;



end.
