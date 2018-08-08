unit uTravel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, SConnect;

type
  TInitSajetParamDll = procedure(SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; UserID: string; parentSocketConnection: TSocketConnection; providerQuery, providerSproc, Param: string); stdcall;
  TCloseSajetDll = procedure; stdcall;
  TfTravelCard = class(TForm)
    PanelParent: TPanel;
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    gsSN: String;
    m_DLLHandle: THandle;
    m_sDLLName: string;
    m_closeSajetDll: TCloseSajetDll;
    m_initialSajetParamDll: TInitSajetParamDll;
  end;

var
  fTravelCard: TfTravelCard;

implementation

uses uDetail, uDataDetail,uDllForm;

{$R *.dfm}

procedure TfTravelCard.FormShow(Sender: TObject);
  procedure LoadMDISajetDll(f_sDllName, f_sParam: string);
  begin
    try
      f_sDllName := uppercase(f_sDllName);
      m_DLLHandle := LoadLibrary(pchar(ExtractFilePath(Application.exename) + f_sDLLName));
      if m_DLLHandle <= 32 then raise Exception.create('Can Not Find DLL File(' + f_sDllName + ')');
      m_sDLLName := f_sDLLName;

      m_initialSajetParamDll := GetProcAddress(m_DLLHandle, 'InitSajetParamDll');
      if (@m_initialSajetParamDll = nil) then raise Exception.Create('DLL Function Not Match (1)');
      m_closeSajetDll := GetProcAddress(m_DLLHandle, 'CloseSajetDll');
      if (@m_closeSajetDll = nil) then raise Exception.Create('DLL Function Not Match (2)');

      m_initialSajetParamDll(self, PanelParent, Application, fDetail.UpdateUserID, fDllForm.G_sockConnection, '', '', f_sParam);
    except
      on E: Exception do raise Exception.create('(' + ClassName + '.LoadSajetDll)' + E.Message);
    end;
  end;
begin
  LoadMDISajetDll('TravelCardDll.dll', gsSN);
end;

procedure TfTravelCard.FormDestroy(Sender: TObject);
begin
  m_closeSajetDll;
  FreeLibrary(m_DLLHandle);
  m_sDLLName := '';
end;

end.
