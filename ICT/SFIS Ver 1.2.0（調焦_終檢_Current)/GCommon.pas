unit GCommon;

interface

Uses
    Windows,SysUtils,Forms,Classes,Menus,Winsock;
   Var
    GprogID,GLine,GStation,GloginUser,GVersion:string;
    GPopeDomTagList:Tstringlist;
    ManageData:integer;
    mWorkFlow:string;

   Function  GetComputer :String;
   Function  GetIP :String;
   Function  GetAppPath :string;
   Procedure CancelAllPopeDom(Frm:TForm);
   Procedure GrantPopeDom(Frm:TForm;Tag:integer);
   Procedure ShowMsg(AText:string);

implementation

Procedure ShowMsg(AText:string);
  begin
      MessageBox(Application.Handle,Pchar(AText),Pchar(Application.Title),MB_OK+MB_ICONEXCLAMATION+MB_SYSTEMMODAL);
  end;

Function GetComputer:String;
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

Function GetAppPath :string;
   begin
     Result:=ExtractFilePath(Application.ExeName);
   end;

Procedure CancelAllPopeDom(Frm:TForm);
  var I:integer;
 Begin
      For I:=0 to Frm.ComponentCount-1 do
         if Frm.Components[i]is TmenuItem then
               if TMenuItem(Frm.Components[i]).Tag=0 then
               TMenuItem(Frm.Components[i]).Visible:=true
               else
               TMenuItem(Frm.Components[i]).Visible:=false;
 end;
Procedure GrantPopeDom(Frm:TForm;Tag:integer);
var  I:integer;
begin
     For I:=0 to Frm.ComponentCount-1 do
         if Frm.Components[i]is TmenuItem then
            if TMenuItem(Frm.Components[i]).Tag=tag then
               TMenuItem(Frm.Components[i]).Visible:=True;

end;

function GetIP: string;
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

end.
 