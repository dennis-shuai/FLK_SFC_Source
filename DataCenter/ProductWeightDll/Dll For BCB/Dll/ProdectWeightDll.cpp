//---------------------------------------------------------------------------

#include <vcl.h>
#include <windows.h>
#include "uFormWeight.h"
#pragma hdrstop
//---------------------------------------------------------------------------
//   Important note about DLL memory management when your DLL uses the
//   static version of the RunTime Library:
//
//   If your DLL exports any functions that pass String objects (or structs/
//   classes containing nested Strings) as parameter or function results,
//   you will need to add the library MEMMGR.LIB to both the DLL project and
//   any other projects that use the DLL.  You will also need to use MEMMGR.LIB
//   if any other projects which use the DLL will be performing new or delete
//   operations on any non-TObject-derived classes which are exported from the
//   DLL. Adding MEMMGR.LIB to your project will change the DLL and its calling
//   EXE's to use the BORLNDMM.DLL as their memory manager.  In these cases,
//   the file BORLNDMM.DLL should be deployed along with your DLL.
//
//   To avoid using BORLNDMM.DLL, pass string information using "char *" or
//   ShortString parameters.
//
//   If your DLL uses the dynamic version of the RTL, you do not need to
//   explicitly add MEMMGR.LIB as this will be done implicitly for you
//---------------------------------------------------------------------------

#pragma argsused

extern  "C"  __declspec(dllexport) __stdcall void InitDllForm(String cPort,HWND Ahandle );   //導出初始化子函數
extern  "C"  __declspec(dllexport) __stdcall void CloseDllForm(void);   //導出關閉子函數
extern  "C"  __declspec(dllexport) __stdcall void CommPortSet(int cPort,String UartSettings );

extern  "C"  __declspec(dllexport) __stdcall void ShowWeightFormEver(void);
extern  "C"  __declspec(dllexport)  char* __stdcall ShowWeightForm(double DelayTime=500);   //    void

extern  "C"  __declspec(dllexport) __stdcall void ShowDllFormEverAPI(void) ;
extern  "C"  __declspec(dllexport) char* __stdcall ShowDllFormAPI(double DelayTime=500) ;    //   void

extern  "C"  __declspec(dllexport) __stdcall AnsiString GetWeightDllAPI(void);
extern  "C"  __declspec(dllexport) __stdcall AnsiString GetWeightDllMSComm(void) ;

void _stdcall Delay(DWORD  MSecs);
unsigned char WeightCommand[2] = {0x01,0x73} ;
HWND AppHandle ;
bool InitDll = false ;

//---------------------------------------------------------------------------
__declspec(dllexport) __stdcall void InitDllForm(String cPort,HWND Ahandle )//(TApplication  ParentApplication)
{
    CloseDllForm();
    Application->Handle = Ahandle ;
    WeightForm = new TWeightForm(Application);  //ParentApplication
    ::SetWindowPos(WeightForm->Handle ,HWND_TOPMOST ,0 ,0 ,0 ,0 , SWP_NOMOVE | SWP_NOSIZE);
    ::BringWindowToTop(Ahandle);
    AppHandle = Ahandle ;
    WeightForm->cPort = cPort ;
    InitDll = true ;
}
//---------------------------------------------------------------------------
__declspec(dllexport) __stdcall void CloseDllForm(void)
{
    try
    {
        if (WeightForm != NULL)
        {
          WeightForm->MSCommTimer->Enabled = false ;
          WeightForm->SendComTime->Enabled = false ;
          WeightForm->Close() ;
          WeightForm->Free();
          WeightForm = NULL;
        }
    }
    catch(Exception &E)
    {
        Application->ShowException(&E) ;
    }
    catch(...)
    {
        try
        {
            throw Exception("");
        }
        catch (Exception &exception)
        {
            Application->ShowException(&exception) ;
        }
    }
}
//---------------------------------------------------------------------------
__declspec(dllexport) __stdcall void CommPortSet(int cPort,String UartSettings )
{
     if (!InitDll)
     {
         ShowMessage("DLL必須先初始化!");
         return ;
     }
     WeightForm->MSComPort->CommPort = cPort ;
     WeightForm->MSComPort->Settings = UartSettings ;
     /*WeightForm->MSComPort->RThreshold = 1;   //每當串口接收多于或等于1個字符時，將引發一個接收數据的OnComm事
     WeightForm->MSComPort->InputMode = 1;       //以二進制方式讀寫數据
     WeightForm->MSComPort->InputLen = 0;       //設置當前接收區數据長度為0，表示全部讀取 */
     if (!WeightForm->MSComPort->PortOpen) {WeightForm->MSComPort->PortOpen = true; }
}
//---------------------------------------------------------------------------
__declspec(dllexport) __stdcall void ShowWeightFormEver(void)            //MSComm顯示重量
{
     if (!InitDll)
     {
         ShowMessage("DLL必須先初始化!");
         return ;
     }
     WeightForm->Show() ;
     ::BringWindowToTop(AppHandle);
     WeightForm->MSCommTimer->Enabled = true ;
}
//---------------------------------------------------------------------------
__declspec(dllexport) char* __stdcall ShowWeightForm(double DelayTime)     //String  MSComm返回重量  void    AnsiString
{
     AnsiString TempWeight = "";
     static   char   bb[256];
     if (!InitDll)
     {
         TempWeight = "Error,Pls Init Dll";
         StrCopy(bb,TempWeight.c_str());
         return bb ;
     }
     WeightForm->Show() ;
     ::BringWindowToTop(AppHandle);
     WeightForm->MSCommTimer->Enabled = true ;
     if (DelayTime>0)
     {
          Delay(DelayTime);
          WeightForm->MSCommTimer->Enabled = false ;
          TempWeight = WeightForm->lblReadKG->Caption.Trim();
          WeightForm->Hide() ;

          StrCopy(bb,TempWeight.c_str());
          return bb ;
     }
     return bb ;
}
//---------------------------------------------------------------------------
__declspec(dllexport) __stdcall void ShowDllFormEverAPI(void)                 //API顯示重量
{
    if (!InitDll)
    {
        ShowMessage("DLL必須先初始化!");
        return ;
    }
    WeightForm->Show() ;
    ::BringWindowToTop(AppHandle);
    WeightForm->SendComTime->Enabled = true ;
}
//---------------------------------------------------------------------------
__declspec(dllexport) char* __stdcall ShowDllFormAPI(double DelayTime)     // AnsiString
{
    AnsiString TempWeight = "";
    if (!InitDll)
    {
        return "Error,Pls Init Dll";
    }
    WeightForm->Show() ;
    ::BringWindowToTop(AppHandle);
    WeightForm->SendComTime->Enabled = true ;
    if (DelayTime>0)
    {
        Delay(DelayTime);
        WeightForm->MSCommTimer->Enabled = false ;
        TempWeight = WeightForm->lblReadKG->Caption.Trim();
        WeightForm->Hide() ;
        return TempWeight.c_str() ;
    }
    return "" ;
}

//---------------------------------------------------------------------------
__declspec(dllexport) __stdcall AnsiString GetWeightDllMSComm(void)
{
      if (!InitDll)
      {
          //ShowMessage("DLL必須先初始化!");
          return "Error,Pls Init Dll";
      }
      WeightForm->SendWeightComand(WeightCommand);  //(0x01,0x73)
      Delay(40);
      return WeightForm->lblReadKG->Caption.Trim() ;
}
//---------------------------------------------------------------------------
__declspec(dllexport) __stdcall AnsiString GetWeightDllAPI(void)
{
    if (!InitDll)
    {
        //ShowMessage("DLL必須先初始化!");
        return "Error,Pls Init Dll" ;
    }
    return WeightForm->GetWeight() ;
}

//---------------------------------------------------------------------------
void _stdcall Delay(DWORD  MSecs)
{
    DWORD BeginTime;
    BeginTime = GetTickCount();
    do {
       Application->ProcessMessages() ;  //讓系統可以處理別的事件
       } while (GetTickCount() - BeginTime <= MSecs);
}
//---------------------------------------------------------------------------
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void* lpReserved)
{
    CoInitialize(NULL);
    return 1;
}
//---------------------------------------------------------------------------
 