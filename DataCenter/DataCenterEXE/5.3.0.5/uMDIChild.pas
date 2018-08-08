unit uMDIChild;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TCloseSajetDll = procedure; stdcall;
  TformMDI = class(TForm)
    PanelParent: TPanel;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
      m_DLLHandle: THandle;
      m_sDLLName: string;
      m_closeSajetDll: TCloseSajetDll;
  public
    { Public declarations }
  end;

var
  formMDI: TformMDI;

implementation

uses uformMain;

{$R *.dfm}

procedure TformMDI.FormShow(Sender: TObject);
  procedure LoadMDISajetDll(f_sDllName: string);
  begin
    try
      f_sDllName := uppercase(f_sDllName);
    //如果已LOAD DRIVER，則先釋放
//      if (m_sDLLName <> '') then closeSajetDll;

      m_DLLHandle := LoadLibrary(pchar(ExtractFilePath(Application.exename) + f_sDLLName));
      if m_DLLHandle <= 32 then raise Exception.create('Can Not Find DLL File(' + f_sDllName + ')');
      m_sDLLName := f_sDLLName;

      formMain.m_initialSajetDll := GetProcAddress(m_DLLHandle, 'InitSajetDll');
      if (@formMain.m_initialSajetDll = nil) then raise Exception.Create('DLL Function Not Match (1)');
      m_closeSajetDll := GetProcAddress(m_DLLHandle, 'CloseSajetDll');
      if (@m_closeSajetDll = nil) then raise Exception.Create('DLL Function Not Match (2)');

      formMain.m_initialSajetDll(self, PanelParent, Application, formMain.LoginUserID, formMain.SocketConnection1, '', '');
    except
      on E: Exception do raise Exception.create('(' + ClassName + '.LoadSajetDll)' + E.Message);
    end;
  end;
begin
  LoadMDISajetDll(formMain.gsTag);
end;

procedure TformMDI.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  procedure closeSajetDll;
  begin
    m_DLLHandle := LoadLibrary(pchar(ExtractFilePath(Application.exename) + Self.Caption));
    m_closeSajetDll;
    FreeLibrary(m_DLLHandle);
  end;
begin
  closeSajetDll;
end;

procedure TformMDI.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TformMDI.FormCreate(Sender: TObject);
begin
  Self.Caption := formMain.gsCaption;
end;

end.
