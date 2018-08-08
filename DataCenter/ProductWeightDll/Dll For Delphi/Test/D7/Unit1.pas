unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AppEvnts;
var
  f_sDllName: string = 'ProdectWeightDll.dll';
  Up_Limit : double = 0 ;
  Low_Limit : double = 0;
  
type
  TInitSajetDll = procedure(ParentApplication: TApplication ;uLimit, lLimit : double; WeightModel : string); stdcall;
  TInitDllForm  = procedure ; stdcall;
  TCloseSajetDll = procedure; stdcall;
  TShowWeightForm = function (wTime: double): string ; stdcall;
  TGetProductWeidght = function (wTime: double) : string ; stdcall;
  TShowDllForm = procedure; stdcall;
  
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    m_DLLHandle: THandle;
    m_sDLLName : string ;
    m_InitialSajetDll : TInitSajetDll ;
    m_InitDllForm : TInitDllForm;
    m_CloseSajetDll: TCloseSajetDll;
    m_ShowDllForm :TShowDllForm ;
    
  public
    { Public declarations }
    m_ShowWeightFormDll : TShowWeightForm ;
    m_GetProductWeidghtDll : TGetProductWeidght ;
  end;
var
  Form1: TForm1;

implementation

uses Unit2;

//uses Unit2;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  m_InitialSajetDll(Application ,88,86,'DDT-A1000')
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  TempWeidght, WeightResult, TRES : string ;
  label EndProc;
begin
  //ShowMessage(m_GetProductWeidghtDll(0.5));
  WeightResult := m_ShowWeightFormDll(StrToFloat(Edit1.Text)) ;

  TempWeidght := WeightResult ;
  if Pos('通信失敗',TempWeidght) >0 then
  begin
    TRES := '電子秤通信失敗,請檢查!';
    goto EndProc ;
  end else if Pos('測量失敗',TempWeidght) >0 then
  begin
    TRES := '取得電子秤重量失敗,請檢查!';
    goto EndProc ;
  end;

  TempWeidght := Copy(TempWeidght,1,Length(TempWeidght)-1);
  if (StrToFloat(TempWeidght) >= Low_Limit ) and
     (StrToFloat(TempWeidght) <= Up_Limit) then
  begin
    TRES := 'OK';
  end else
  begin
    TRES := '產品重量不合格!('+WeightResult+')';
  end ;

  EndProc :
  ShowMessage(TRES);
  {if TRES <> 'OK' then
  begin
    ShowMessage(TRES);
  end;}
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  procedure CloseWeightDll;
  begin
    m_DLLHandle := LoadLibrary(pchar(f_sDllName));
    m_CloseSajetDll;
    FreeLibrary(m_DLLHandle);
  end;
begin
  CloseWeightDll;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree ;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  m_ShowDllForm ;
end;

procedure TForm1.FormCreate(Sender: TObject);
  procedure LoadWeightDll(f_sDllName : string) ;
  begin
    try
      f_sDllName := UpperCase(f_sDllName);
      //如果已LOAD DRIVER，則先釋放
      //if (m_sDLLName <> '') then closeSajetDll;

      m_DLLHandle := LoadLibrary(pchar(ExtractFilePath(Application.exename) + f_sDLLName));
      if m_DLLHandle <= 32 then raise Exception.create('Can Not Find DLL File(' + f_sDllName + ')');
      m_sDLLName := f_sDLLName;

      m_InitialSajetDll := GetProcAddress(m_DLLHandle, 'InitSajetDll');
      if (@m_initialSajetDll = nil) then raise Exception.Create('DLL Function Not Match (1)');

      m_CloseSajetDll := GetProcAddress(m_DLLHandle, 'CloseSajetDll');
      if (@m_closeSajetDll = nil) then raise Exception.Create('DLL Function Not Match (2)');

      m_ShowWeightFormDll := GetProcAddress(m_DLLHandle, 'ShowWeightForm');
      if (@m_ShowWeightFormDll = nil) then raise Exception.Create('DLL Function Not Match (3)');

      m_GetProductWeidghtDll := GetProcAddress(m_DLLHandle, 'GetProductWeidght');
      if (@m_GetProductWeidghtDll = nil) then raise Exception.Create('DLL Function Not Match (4)');

      m_ShowDllForm := GetProcAddress(m_DLLHandle, 'ShowDllForm');
      if (@m_ShowDllForm = nil) then raise Exception.Create('DLL Function Not Match (5)');

      m_InitDllForm := GetProcAddress(m_DLLHandle, 'InitDllForm');
      if (@m_InitDllForm = nil) then raise Exception.Create('DLL Function Not Match (InitDllForm)');

    except
      on E: Exception do raise Exception.create('(' + ClassName + '.LoadSajetDll)' + E.Message);
    end;
  end;
begin
  LoadWeightDll(f_sDllName);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  m_InitDllForm;
end;

end.
