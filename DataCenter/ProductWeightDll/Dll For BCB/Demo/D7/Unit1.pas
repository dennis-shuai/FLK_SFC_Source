unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TInitDllForm  = procedure (cPort :String ;Ahandle : THandle );stdcall;
  TCloseDllForm = procedure ; stdcall;
  TCommPortSet = procedure (cPort : integer ; UartSettings : String);stdcall;
  
  TShowWeightFormEver = procedure ;stdcall;
  TShowWeightForm = function (DelayTime :double =500) :PChar  ; stdcall;   //string

  TShowDllFormEverAPI = procedure ;stdcall;
  TShowDllFormAPI =  function(DelayTime :double =500): PChar   ;stdcall ;   //        procedure     string

  TGetWeightDllAPI = function  : string ;stdcall;
  TGetWeightDllMSComm = function  : string ;stdcall;

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
    m_DLLHandle: THandle;  //DLL句柄
    m_sDLLName : string ;  //全局DLL名稱
    
    m_InitDllForm : TInitDllForm;
    m_CloseDllForm : TCloseDllForm ;
    m_CommPortSet : TCommPortSet ;

    m_ShowWeightForm  : TShowWeightForm ;
    m_ShowWeightFormEver : TShowWeightFormEver ;

    m_ShowDllFormAPI : TShowDllFormAPI ;
    m_ShowDllFormEverAPI : TShowDllFormEverAPI ;
    
    m_GetWeightDllAPI : TGetWeightDllAPI ;
    m_GetWeightDllMSComm : TGetWeightDllMSComm ;

    procedure LoadWeightDll(f_sDllName : string) ;
    procedure FreeWeightDll;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  LoadWeightDll('ProdectWeightDll.dll');
  m_InitDllForm('COM1',Handle);
end;

procedure TForm1.LoadWeightDll(f_sDllName : string) ;
begin
  try
    f_sDllName := UpperCase(f_sDllName);
    //如果已LOAD DRIVER，則先釋放
    //if (m_sDLLName <> '') then closeSajetDll;
    m_DLLHandle := LoadLibrary(pchar(ExtractFilePath(Application.exename) + f_sDLLName));
    if m_DLLHandle <= 32 then raise Exception.create('Can Not Find DLL File(' + f_sDllName + ')');
    m_sDLLName := f_sDLLName;

    m_InitDllForm := GetProcAddress(m_DLLHandle, 'InitDllForm');
    if (@m_InitDllForm = nil) then raise Exception.Create('DLL Function Not Match (1)');

    m_CloseDllForm := GetProcAddress(m_DLLHandle, 'CloseDllForm');
    if (@m_CloseDllForm = nil) then raise Exception.Create('DLL Function Not Match (2)');

    m_CommPortSet := GetProcAddress(m_DLLHandle, 'CommPortSet');
    if (@m_CommPortSet = nil) then raise Exception.Create('DLL Function Not Match (3)');

    m_ShowWeightForm := GetProcAddress(m_DLLHandle, 'ShowWeightForm');
    if (@m_ShowWeightForm = nil) then raise Exception.Create('DLL Function Not Match (4)');

    m_ShowWeightFormEver := GetProcAddress(m_DLLHandle, 'ShowWeightFormEver');
    if (@m_ShowWeightFormEver = nil) then raise Exception.Create('DLL Function Not Match (5)');

    m_ShowDllFormAPI := GetProcAddress(m_DLLHandle, 'ShowDllFormAPI');
    if (@m_ShowDllFormAPI = nil) then raise Exception.Create('DLL Function Not Match (6)');

    m_ShowDllFormEverAPI := GetProcAddress(m_DLLHandle, 'ShowDllFormEverAPI');
    if (@m_ShowDllFormEverAPI = nil) then raise Exception.Create('DLL Function Not Match (7)');

    m_GetWeightDllAPI := GetProcAddress(m_DLLHandle, 'GetWeightDllAPI');
    if (@m_GetWeightDllAPI = nil) then raise Exception.Create('DLL Function Not Match (8)');

    m_GetWeightDllMSComm := GetProcAddress(m_DLLHandle, 'GetWeightDllMSComm');
    if (@m_GetWeightDllMSComm = nil) then raise Exception.Create('DLL Function Not Match (9)');

  except
    on E: Exception do raise Exception.create('(' + ClassName + '.LoadWeightDll)' + E.Message);
  end;
end;

procedure TForm1.FreeWeightDll;
begin
  if m_DLLHandle >0 then
  begin
    //m_DLLHandle := LoadLibrary(pchar(f_sDllName));
    m_CloseDllForm;
    FreeLibrary(m_DLLHandle);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeWeightDll ;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if Assigned(m_ShowWeightFormEver) then
    m_ShowWeightFormEver;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if Assigned(m_ShowDllFormEverAPI) then
    m_ShowDllFormEverAPI ; 
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  //m_CloseDllForm ;
  FreeWeightDll ;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  if Assigned(m_ShowWeightForm) then
    ShowMessage(m_ShowWeightForm(500)) ;  //(1000)
    //m_ShowWeightForm ;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  if Assigned(m_ShowDllFormAPI) then
    //ShowMessage(m_ShowDllFormAPI) ;
    ShowMessage(m_ShowDllFormAPI(500)) ;
end;

end.
