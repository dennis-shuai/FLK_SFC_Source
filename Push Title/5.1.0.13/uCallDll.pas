unit uCallDll;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DB, DBClient, MConnect, SConnect, ObjBrkr;

  type
  TCloseSajetDll = procedure; stdcall;
  TInitSajetWOStatusDll = procedure(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc: string; WOStatus: string); stdcall;
  TResizeWindows = procedure(high,width:integer); stdcall;
  TCallDll = class(TForm)
    SimpleObjectBroker1: TSimpleObjectBroker;
    SocketConnection1: TSocketConnection;
    PanelParent: TPanel;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    MyParentApplication : TApplication;
    FormOwner : TForm;
    FormParent : TPanel;
    m_DLLHandle: THandle;
    m_sDLLName: string;
    m_closeSajetDll: TCloseSajetDll;
    m_initialSajetWOStatusDll : TInitSajetWOStatusDll;
    m_ReSize: TResizeWindows;
  public
    { Public declarations }

    Str_SN : String;
    Str_Type : String;
    function LoadApServer: Boolean;
  end;

var
  CallDll: TCallDll;

implementation


{$R *.dfm}

procedure TCallDll.FormShow(Sender: TObject);
  procedure LoadMDISajetWOStatusDll(f_sDllName,Parameter : string);
  begin
    try
      f_sDllName := uppercase(f_sDllName);
    //如果已LOAD DRIVER，則先釋放
//      if (m_sDLLName <> '') then closeSajetDll;

      m_DLLHandle := LoadLibrary(pchar(ExtractFilePath(Application.exename) + f_sDLLName));
      if m_DLLHandle <= 32 then raise Exception.create('Can Not Find DLL File(' + f_sDllName + ')');
      m_sDLLName := f_sDLLName;

      m_initialSajetWOStatusDll := GetProcAddress(m_DLLHandle, 'InitSajetWOStatusDll');
      if (@m_initialSajetWOStatusDll = nil) then raise Exception.Create('DLL Function Not Match (1)');
      m_closeSajetDll := GetProcAddress(m_DLLHandle, 'CloseSajetDll');
      if (@m_closeSajetDll = nil) then raise Exception.Create('DLL Function Not Match (2)');
      Try
      m_Resize := GetProcAddress(m_DllHandle,'ResizeWindows');
      if (@m_Resize=nil) then raise Exception.create('Dll Function Not Match(3) ');
      Except
      end;
      m_initialSajetWOStatusDll(Self, PanelParent, MyParentApplication,'',SocketConnection1, '', '',Parameter);
    except
      on E: Exception do raise Exception.create('(' + ClassName + '.LoadSajetWOStatusDll)' + E.Message);
    end;
  end;
begin
  LoadApServer;
  LoadMDISajetWOStatusDll(Str_Type,Str_SN);
end;

procedure TCallDll.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  procedure closeSajetDll;
  begin
    m_DLLHandle := LoadLibrary(pchar(ExtractFilePath(Application.exename) + Self.Caption));
    m_closeSajetDll;
    FreeLibrary(m_DLLHandle);
  end;
begin
  closeSajetDll;
end;

function TCallDll.LoadApServer: Boolean;
var F: TextFile;
   S: string;
begin
   Result := False;
   SocketConnection1.Connected := False;
   SimpleObjectBroker1.Servers.Clear;
   SocketConnection1.Host:='';
   SocketConnection1.Address:='';

   if not FileExists(GetCurrentDir + '\ReportServer.cfg') then
      Exit;
   AssignFile(F, GetCurrentDir + '\ReportServer.cfg');
   Reset(F);
   while True do
   begin
      Readln(F, S);
      if trim(S) <> '' then
      begin
        SimpleObjectBroker1.Servers.Add;
        SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
        SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
      end else
        Break;
   end;
   CloseFile(F);
   Result := True;
end;

end.
 