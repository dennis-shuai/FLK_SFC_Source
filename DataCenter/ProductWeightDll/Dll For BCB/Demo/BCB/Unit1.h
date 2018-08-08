//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "MSCommLib_OCX.h"
#include <OleCtrls.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TButton *Button1;
        TMSComm *MSComPort;
        TTimer *Timer1;
        TButton *Button2;
        TPanel *Panel1;
        TButton *Button3;
        TButton *Button4;
        TButton *Button6;
        TButton *Button5;
        TButton *Button8;
        TButton *Button9;
        TButton *Button10;
        TButton *Button11;
        TTimer *Timer2;
        TButton *Button12;
        TButton *Button14;
        TButton *Button7;
        TButton *Button13;
        void __fastcall Button1Click(TObject *Sender);
        void __fastcall MSComPortComm(TObject *Sender);
        void __fastcall Button2Click(TObject *Sender);
        void __fastcall Timer1Timer(TObject *Sender);
        void __fastcall Button3Click(TObject *Sender);
        void __fastcall Button4Click(TObject *Sender);
        void __fastcall Button6Click(TObject *Sender);
        void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
        void __fastcall Button5Click(TObject *Sender);
        void __fastcall Button8Click(TObject *Sender);
        void __fastcall Button9Click(TObject *Sender);
        void __fastcall Button10Click(TObject *Sender);
        void __fastcall Button11Click(TObject *Sender);
        void __fastcall Timer2Timer(TObject *Sender);
        void __fastcall Button12Click(TObject *Sender);
        void __fastcall Button14Click(TObject *Sender);
        void __fastcall Button7Click(TObject *Sender);
        void __fastcall FormDestroy(TObject *Sender);
        void __fastcall Button13Click(TObject *Sender);
private:	// User declarations
        void __fastcall uShowStop(String Display);
        //void   __fastcall   WndProc(TMessage&   Message) ;
        void   __fastcall   AppMessage(tagMSG   &Msg,   bool   &Handled);
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
        HANDLE          hComm;
        bool            COMFlag;
        
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
