//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"


void __stdcall(*m_InitDllForm)(void);   //
void __stdcall(*m_CloseSajetDll)(void);    //
void __stdcall(*m_ShowDllForm)(void);
AnsiString __stdcall(*m_ShowWeightFormDll)(double); //

//void (*lpSetMsgHook)(HWND,DWord);
//void (*lpUnMsgHook)(void);

static HINSTANCE DllInst = NULL;
static FARPROC lpInitDllProc;
static FARPROC lpCloseProc;
static FARPROC lpWeightDllroc;

TForm1 *Form1;

//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button1Click(TObject *Sender)
{
        FARPROC P;
        //void (*m_InitialSajetDll)(TApplication ,double,double);
        if (NULL==DllInst) DllInst = ::LoadLibrary("ProdectWeightDll.dll");
        if (DllInst)
        {
                //m_InitDllForm = (void( __stdcall(*)(double,double))::GetProcAddress(DllInst),"InitDllForm");
                lpInitDllProc = ::GetProcAddress(DllInst,"InitDllForm");
                //(FARPROC &)m_ShowWeightFormDll=::GetProcAddress(DllInst,"ShowWeightFormDll");
                lpCloseProc = ::GetProcAddress(DllInst,"CloseSajetDll");
                lpWeightDllroc = ::GetProcAddress(DllInst,"ShowDllForm");       //ShowWeightForm

                if (lpInitDllProc==NULL)
                {
                        ShowMessage("打開函數地址錯誤!") ;
                } else
                {
                        m_InitDllForm = (void(  __stdcall*)(void))lpInitDllProc; //指針類型轉換    _cdecl
                        m_CloseSajetDll = (void(  __stdcall*)(void))lpCloseProc; //指針類型轉換    _cdecl
                        m_ShowDllForm = (void(  __stdcall*)(void))lpWeightDllroc; //指針類型轉換    _cdecl
                        m_InitDllForm;
                }
        }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormClose(TObject *Sender, TCloseAction &Action)
{
    m_CloseSajetDll ;
    if (DllInst) FreeLibrary(DllInst);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button2Click(TObject *Sender)
{
        m_ShowDllForm;
}
//---------------------------------------------------------------------------
