unit clsUser;

interface

uses
   classes,SysUtils;

type
  TclsUser=Class(TObject)
  private
    PID:String;
    PName:String;
    PDesc:String;
    PType:integer;
    PExternal:integer;
    PAID:String;
    Pbuilder:string;
    PbDate:string;
    Previser:string;
    PrDate:string;
    PUserGroup:TStringList;
    procedure SetPassword(const Value: String);
    function GetPassword: String;
  protected
    PPassword:String;
  public
    property FID:String read PID write PID;
    property FName:String read PName write PName;
    property FDesc:String read PDesc write PDesc;
    property FType:integer read PType write PType;
    property FExternal:integer read PExternal write PExternal;
    property FPassword:String read GetPassword write  SetPassword;
    property FAID:String read PAID write PAID;
    property Fbuilder:string read Pbuilder write Pbuilder;
    property FbDate:string read PbDate write PbDate;
    property Freviser:string read Previser write Previser;
    property FrDate:string read PrDate write PrDate;
    function DeCrypt(AstrPassword:String):String;
    function EnCrypt(AstrPassword:String):String;
  end;

implementation

{ TclsUser }
function TclsUser.DeCrypt(AstrPassword:String): String;
var
  lStrPas:String;
  i:integer;
begin
  lStrPas:='';        //¸Ñ±K
  for i:=Length(AstrPassword) downto 1 do
  begin
    lStrPas:=lStrPas+chr(ord(AstrPassword[i])-1);
  end;
  result:=lStrPas;
end;

function TclsUser.EnCrypt(AstrPassword: String): String;
var
  lStrPas:String;
  i:integer;
begin
  lStrPas:='';
  for i:=Length(AstrPassword) downto 1 do
  begin
    if ord(AstrPassword[i])>127 then
       raise exception.Create('The Password must be ASCII char!');
    lStrPas:=lStrPas+chr(ord(AstrPassword[i])+1);
  end;
  result := lStrPas;
end;

function TclsUser.GetPassword: String;
begin 
  result:= DeCrypt(PPassword);
end;

procedure TclsUser.SetPassword(const Value: String);
begin
  PPassword :=EnCrypt(value);
end;

end.
