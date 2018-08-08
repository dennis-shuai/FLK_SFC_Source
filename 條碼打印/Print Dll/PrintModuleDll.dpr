library PrintModuleDll;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Variants,
  ComObj,
  Windows, ActiveX,
  Classes;
{$R *.res}
var
BarApp,BarDoc,BarVars:variant;
IsInit :integer;

function InitPrint(PrintFile:pointer): Boolean;stdcall;
Var PrintFileName:string;
begin

    result :=false;
    try
          CoInitialize(nil);
          BarApp := CreateOleObject('lppx.Application');
    except
         MessageBoxA(0,'沒有安裝codesoft軟體','錯誤提示',MB_OK+MB_ICONERROR);
         // CoUnInitialize;
         Exit;
    end;
    BarApp.Visible:=false;
    BarDoc:=BarApp.ActiveDocument;
    BarVars:=BarDoc.Variables;
    IsInit:=1;
    PrintFileName :=  PChar(PrintFile);
    if   PrintFileName ='' then begin
       MessageBoxA(0,'Print File is NULL' ,'提示',MB_OK+MB_ICONERROR);
       Exit;
    end ;
    if not FileExists(PrintFileName) then
    begin
       MessageBoxA(0,PChar('缺少打印文件'+PrintFileName),'錯誤提示',MB_OK+MB_ICONERROR);
       //CoUnInitialize;
       Exit;
    end;
    BarDoc.Open(PrintFileName);

    result :=true;
end;

function PrintLabel(ModuleNO:pointer): Boolean;stdcall;
begin
   result :=false;
   if IsInit =1 then begin
     try
       BarDoc.Variables.Item('SN').Value := AnsiString(Pchar(ModuleNO));
     except
       MessageBoxA(0,'打印文件設置錯誤','錯誤提示',MB_OK+MB_ICONERROR);
       Exit;
     end;

     Bardoc.PrintLabel(1);
     Bardoc.FormFeed; // Terminate Print job

     result :=true;
   end else
     result :=false;

end;

function ClosePrint: Boolean;stdcall;
begin
   result :=false;
   if IsInit =1 then begin
     Bardoc.Close;
     BarApp.Quit;
   end;
   BarVars := Unassigned;
   Bardoc := Unassigned;
   BarApp := Unassigned;
   IsInit :=0;
   CoUnInitialize;
   result :=true;
end;

exports
InitPrint,
PrintLabel,
ClosePrint;

begin
end.
