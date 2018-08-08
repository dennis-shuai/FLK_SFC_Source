//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "uFormWeight.h"
#include "ControlBoard.h"

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "MSCommLib_OCX"
#pragma resource "*.dfm"

TWeightForm *WeightForm;

bool Running = false ;
//bool ConnectMSCom = false ;
unsigned char Command[2] = {0x01,0x73} ;
TControlBoard  CB;

//---------------------------------------------------------------------------
__fastcall TWeightForm::TWeightForm(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void _stdcall TWeightForm::Delay(DWORD  MSecs)
{
    DWORD BeginTime;
    BeginTime = GetTickCount();
    do {
       Application->ProcessMessages() ;  //���t�Υi�H�B�z�O���ƥ�
       } while (GetTickCount() - BeginTime <= MSecs);
}
//---------------------------------------------------------------------------
void __fastcall TWeightForm::SendWeightComand(unsigned char* CommandStr)
{
    try
    {
        OleVariant TxBuff;
        int n = 2;
        //int OutBuff[2] = {0x01,0x73} ;
        //unsigned char buff[2] = {0x01,0x73};
        TxBuff = VarArrayCreate(OPENARRAY(int,(0,n-1)),varByte);
        for (int i =0 ;i < n;i++)
                TxBuff.PutElement(CommandStr[i],i) ;
        if (!MSComPort->PortOpen) { MSComPort->PortOpen = True ;}
        MSComPort->Output = TxBuff ;
    }
    catch(Exception &exception)
    {
        SendComTime->Enabled = false ;
        MSCommTimer->Enabled = false ;
        ShowMessage("Sorry,�ƾڵo�e�L�{���X�{���~!") ;
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
String __fastcall TWeightForm::GetMSCommWeight(void)
{
    OleVariant RxBuff ;
    int ByteNum, BuffPtr ;
    AnsiString TempStr ;
    unsigned char buff[200];

    if(MSComPort->CommEvent==comEvReceive)
    {
        if(MSComPort->InBufferCount>=13)// �O�_���r�žn�d�b�����w�İϵ��ݳQ���X
        {
            Sleep(10);
            RxBuff = MSComPort->Input ;
            //��k1
            /*ByteNum = RxBuff.ArrayHighBound(1);
            for (int i = 0;i<ByteNum ;i++)
                    {buff[BuffPtr++]=RxBuff.GetElement(i);} */
            //ShowMessage(String(buff));

            //��k�G
            TempStr = WideString(RxBuff);
            TempStr = TempStr.Trim();
            return  TempStr ;
        }
    }
    return NULL;
}
//---------------------------------------------------------------------------
void __fastcall TWeightForm::SendComTimeTimer(TObject *Sender)
{
    if (!Running)
    {
        Running = true;
        if (!CB.COMFlag ) {CB.Open(cPort); }
        CB.SendRS232Comand(0x01,0x73);
        Delay(25);
        lblReadKG->Caption = CB.ReadRS232ValueW().Trim() ;
        Running = false ;
    }
}
//---------------------------------------------------------------------------

void __fastcall TWeightForm::MSCommTimerTimer(TObject *Sender)
{
    if (!Running)
    {
        Running = true;
        SendWeightComand(Command);  //(0x01,0x73)
        //lblReadKG->Caption = GetMSCommWeight().Trim() ;
        Running = false ;
    }
}
//---------------------------------------------------------------------------

void __fastcall TWeightForm::FormPaint(TObject *Sender)
{
    HDC  DC ;
    HPEN  Pen ;
    HPEN  OldPen ;
    HBRUSH  OldBrush ;

    Canvas->Pen->Color = clBlue ;
    Canvas->Brush->Color = clBlue ;
    DC = ::GetWindowDC(WeightForm->Handle);
    Pen = ::CreatePen(PS_SOLID, 1, clGray);
    OldPen = ::SelectObject(DC, Pen); //���J�۩w�q���e��,�O�s��e��
    OldBrush = ::SelectObject(DC, ::GetStockObject(NULL_BRUSH));//���J�ŵe��,�O�s��e��
    //RoundRect(DC, 0, 0, Width-1, Height-1,21,21); //�e���
    ::RoundRect(DC, 0, 0, Width-1, Height-1,0,0); //�e���
    ::SelectObject(DC,OldBrush);//���J��e��
    ::SelectObject(DC,OldPen); // ���J��e��
    ::DeleteObject(Pen);
    ::ReleaseDC(WeightForm->Handle, DC);
}
//---------------------------------------------------------------------------
bool __fastcall TWeightForm::OpenPort(AnsiString cPort)
{
    return CB.Open(cPort);
}
//---------------------------------------------------------------------------
AnsiString __fastcall TWeightForm::GetWeight(void)
{
    if (!CB.COMFlag) {CB.Open(cPort); }
    CB.SendRS232Comand(0x01,0x73);
    Sleep(30);
    return CB.ReadRS232ValueW().Trim();
}
//---------------------------------------------------------------------------
void __fastcall TWeightForm::FormClose(TObject *Sender,
      TCloseAction &Action)
{
    SendComTime->Enabled = false ;
    MSCommTimer->Enabled = false ;
    if (MSComPort->PortOpen) {MSComPort->PortOpen = false ;}
    CB.Close();
}
//---------------------------------------------------------------------------

void __fastcall TWeightForm::lblReadKGDblClick(TObject *Sender)
{
     SendComTime->Enabled = false ;
     MSCommTimer->Enabled = false ;
     Hide() ;
}

//---------------------------------------------------------------------------

void __fastcall TWeightForm::MSComPortComm(TObject *Sender)
{
    OleVariant RxBuff ;
    int ByteNum, BuffPtr ;
    AnsiString TempStr ;
    unsigned char buff[200];

    if(MSComPort->CommEvent==comEvReceive)
    {
        if(MSComPort->InBufferCount>=13)// �O�_���r�žn�d�b�����w�İϵ��ݳQ���X
        {
                Sleep(10);
                RxBuff = MSComPort->Input ;
                //��k1
                //ByteNum = RxBuff.ArrayHighBound(1);
                //for (int i = 0;i<ByteNum ;i++)
                        //{buff[BuffPtr++]=RxBuff.GetElement(i);} 
                //ShowMessage(String(buff));
                //��k�G
                TempStr = WideString(RxBuff);
                TempStr = TempStr.Trim();
                lblReadKG->Caption = TempStr;
                //ConnectMSCom = true ;
        }
    }
}
//---------------------------------------------------------------------------

void __fastcall TWeightForm::FormShow(TObject *Sender)
{
    WeightForm->Top = (Screen->Height - WeightForm->Height )/2;
    WeightForm->Left = (Screen->Width - WeightForm->Width )/2;
    //ConnectMSCom = false ;
}
//---------------------------------------------------------------------------

void __fastcall TWeightForm::lblReadKGMouseDown(TObject *Sender,
      TMouseButton Button, TShiftState Shift, int X, int Y)
{
    if (Button == 0)
    {
        long ReturnVal ;
        X = ::ReleaseCapture();
        ReturnVal = ::SendMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0) ;
    }
}
//---------------------------------------------------------------------------

