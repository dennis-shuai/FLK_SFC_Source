unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  //TInitSajetDll = procedure(uLimit, lLimit, wTime: double; WeightModel : string); stdcall;
  TInitSajetDll = procedure (SenderOwner: TForm; SenderParent: TPanel; ParentApplication: TApplication; uLimit, lLimit : double; WeightModel : string) ;
  TCloseSajetDll = procedure; stdcall;
  
  TForm2 = class(TForm)
    PanelParent: TPanel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    m_DLLHandle: THandle;
    m_sDLLName : string ;
    m_CloseSajetDll: TCloseSajetDll;
    m_InitialSajetDll : TInitSajetDll ;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

uses Unit1 ;

procedure TForm2.FormCreate(Sender: TObject);
  procedure LoadMDISajetDll(f_sDllName: string);
  begin
    try
      f_sDllName := uppercase(f_sDllName);
      //如果已LOAD DRIVER，則先釋放
      //if (m_sDLLName <> '') then closeSajetDll;

      m_DLLHandle := LoadLibrary(pchar(ExtractFilePath(Application.exename) + f_sDLLName));
      if m_DLLHandle <= 32 then raise Exception.create('Can Not Find DLL File(' + f_sDllName + ')');
      m_sDLLName := f_sDLLName;

      m_InitialSajetDll := GetProcAddress(m_DLLHandle, 'InitSajetDll');
      if (@m_initialSajetDll = nil) then raise Exception.Create('DLL Function Not Match (1)');
      m_CloseSajetDll := GetProcAddress(m_DLLHandle, 'CloseSajetDll');
      if (@m_closeSajetDll = nil) then raise Exception.Create('DLL Function Not Match (2)');

      Form1.m_ShowWeightFormDll := GetProcAddress(m_DLLHandle, 'ShowWeightForm');
      if (@Form1.m_ShowWeightFormDll = nil) then raise Exception.Create('DLL Function Not Match (3)');

      Form1.m_GetProductWeidghtDll := GetProcAddress(m_DLLHandle, 'GetProductWeidght');
      if (@Form1.m_GetProductWeidghtDll = nil) then raise Exception.Create('DLL Function Not Match (4)');

      m_InitialSajetDll(self, PanelParent, Application, 0.5,0.5,'DDT-A1000')//);
    except
      on E: Exception do raise Exception.create('(' + ClassName + '.LoadSajetDll)' + E.Message);
    end;
  end;
begin
  LoadMDISajetDll('ProdectWeightDll.dll');
end;

procedure TForm2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  procedure CloseSajetDll;
  begin
    //m_DLLHandle := LoadLibrary(pchar(ExtractFilePath(Application.exename) + Self.Caption));
    m_CloseSajetDll;
    FreeLibrary(m_DLLHandle);
  end;
begin
  CloseSajetDll;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
