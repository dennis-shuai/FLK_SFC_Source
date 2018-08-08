unit GCommon;

interface

Uses
    Windows,SysUtils,Forms,Classes,Menus;
   Var
    GprogID,GLine,GStation,GloginUser,GVersion:string;
    GPopeDomTagList:Tstringlist;
    ManageData:integer;
    mWorkFlow:string;

   Function  GetComputer :String;
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


end.
 