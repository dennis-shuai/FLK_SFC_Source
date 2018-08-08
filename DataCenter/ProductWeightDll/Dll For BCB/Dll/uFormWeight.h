//---------------------------------------------------------------------------

#ifndef uFormWeightH
#define uFormWeightH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "MSCommLib_OCX.h"
#include <ExtCtrls.hpp>
#include <OleCtrls.hpp>
//---------------------------------------------------------------------------
class TWeightForm : public TForm
{
__published:	// IDE-managed Components
        TLabel *lblReadKG;
        TMSComm *MSComPort;
        TTimer *SendComTime;
        TTimer *MSCommTimer;
        void __fastcall SendComTimeTimer(TObject *Sender);
        void __fastcall FormPaint(TObject *Sender);
        void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
        void __fastcall lblReadKGDblClick(TObject *Sender);
        void __fastcall MSCommTimerTimer(TObject *Sender);
        void __fastcall MSComPortComm(TObject *Sender);
        void __fastcall FormShow(TObject *Sender);
        void __fastcall lblReadKGMouseDown(TObject *Sender,
          TMouseButton Button, TShiftState Shift, int X, int Y);
private:	// User declarations
public:		// User declarations
        __fastcall TWeightForm(TComponent* Owner);
        String cPort ;
        void __fastcall SendWeightComand(unsigned char* CommandStr);
        String __fastcall GetMSCommWeight(void);
        void _stdcall Delay(DWORD  MSecs);
        bool __fastcall OpenPort(AnsiString cPort);
        AnsiString __fastcall GetWeight(void);
};
//---------------------------------------------------------------------------
extern PACKAGE TWeightForm *WeightForm;
//---------------------------------------------------------------------------
#endif
