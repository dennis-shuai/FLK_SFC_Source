#include <Registry.hpp>
#include <DateUtils.hpp>  //這是時間的include
#include <math.h>
//-------------------------------------------------
unsigned char  ReceiverDataBuff[256],RXDataBuff[256];
//---------------------------------------------------------------------------
class TControlBoard
{
private:
protected:
public:
        HANDLE          hComm;
        bool            COMFlag ;

        bool __fastcall Open(AnsiString ComPort);
        void __fastcall Close(void);
        void __fastcall SendRS232Comand(unsigned char Comand1, unsigned char Comand2);
        String __fastcall ReadRS232ValueW(void);
        void __fastcall SendRS232Data(unsigned char Function,unsigned char Data1, unsigned char Data2);
        bool __fastcall ReadRS232Value(unsigned short* Data);
        void __fastcall OpenBOX(void);
        void __fastcall CloseBOX(void);
        void __fastcall FixtureUP(void);
        void __fastcall FixtureDOWN(void);
        void __fastcall ResetBOX(void);
        void __fastcall OpenLight(void);
        void __fastcall CloseLight(void);
        void __fastcall Yellow(bool OnOff);
};
//---------------------------------------------------------------------------
bool __fastcall TControlBoard::Open(AnsiString ComPort)
{
   DCB    dcb;
   //Close () ;//先關閉COMM口
   COMFlag = false;
   hComm = CreateFile(ComPort.c_str(), GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, 0);
   if(hComm == INVALID_HANDLE_VALUE)
      return false;
   GetCommState(hComm, &dcb);
   dcb.BaudRate = 9600;
   dcb.ByteSize = 8;
   dcb.Parity   = NOPARITY;
   dcb.StopBits = ONESTOPBIT;
   if(!SetCommState(hComm, &dcb)){
      CloseHandle(hComm);
      return false;
      }
   COMFlag = true;
   PurgeComm(hComm,PURGE_RXCLEAR);//清除RX Buff內的資料
   ::ZeroMemory(ReceiverDataBuff,sizeof(ReceiverDataBuff));
   return true;
}
//---------------------------------------------------------------------------
void __fastcall TControlBoard::Close(void)
{
   if (COMFlag)
   {
       PurgeComm(hComm, PURGE_RXCLEAR);
       FlushFileBuffers(hComm);
       CloseHandle(hComm);
       COMFlag=false;
   }
}
//---------------------------------------------------------------------------
void __fastcall TControlBoard::SendRS232Comand(unsigned char Comand1, unsigned char Comand2)
{
   char   SendData[2]={0x01,0x73}; //格式Start Tx,0x80,PutSingal,Item,Data1,Data,End Tx,CheckSum
   unsigned long  lrc;

   SendData[0]= Comand1;
   SendData[1]= Comand2;
   if(COMFlag==false)
      return;
   WriteFile(hComm,&SendData,sizeof(SendData),&lrc,NULL);
}
//---------------------------------------------------------------------------
String __fastcall TControlBoard::ReadRS232ValueW(void)
{
   COMSTAT        cs;
   DWORD          nBytesRead,dwEvent,dwError,lpEvtMask;
   unsigned int   CsCount;
   AnsiString     DataBuff ;

   if(hComm == INVALID_HANDLE_VALUE)
      return "0000.00g";//NULL ;
   ClearCommError(hComm,&dwError,&cs);
   if(cs.cbInQue < 0)
      return "0000.00g";//NULL ;
   do
   {
      ClearCommError(hComm,&dwError,&cs);         //取得狀態
      CsCount = cs.cbInQue;
      Sleep(10);                                  //等待RX資料全部接收完畢，條件是鮑率的速度
      ClearCommError(hComm,&dwError,&cs);
   } while (CsCount != cs.cbInQue );

   if(cs.cbInQue > sizeof(ReceiverDataBuff))  //資料是否大於我們所準備的Buffer
   {     
      ::ZeroMemory(ReceiverDataBuff,sizeof(ReceiverDataBuff));
      PurgeComm(hComm,PURGE_RXCLEAR);
      return "0000.00g";//NULL ;
   }

   if (cs.cbInQue)
   {
      ReadFile(hComm,ReceiverDataBuff,cs.cbInQue,&nBytesRead,NULL);//接收COM的資料
      DataBuff =  (char *)ReceiverDataBuff ;
      ::ZeroMemory(ReceiverDataBuff,sizeof(ReceiverDataBuff));
      return DataBuff ;
   }
   else
   {
      ::ZeroMemory(ReceiverDataBuff,sizeof(ReceiverDataBuff));
      PurgeComm(hComm,PURGE_RXCLEAR);
      //PurgeComm(hComm,PURGE_TXCLEAR);
      return "0000.00g";//NULL;
   }
}
//---------------------------------------------------------------------------
void __fastcall TControlBoard::SendRS232Data(unsigned char Function,unsigned char Data1, unsigned char Data2)
{
   char   SendData[8]={0x02,0x01,0x01,0x02,0x00,0x00,0x03,0x00}; //格式Start Tx,0x80,PutSingal,Item,Data1,Data,End Tx,CheckSum
   int    ln;
   unsigned long  lrc,BS;
   unsigned int   i;
   char           CheckSum=0x00;

   SendData[2]= Function;
   SendData[4]= Data1;
   SendData[5]= Data2;
   if(COMFlag==false)
      return;
   Sleep(0);
   BS = sizeof(SendData)-1;                       //取得傳送的字串數
   CheckSum = 0x00;
   for(i=0 ; i<BS ; i++)
       CheckSum += SendData[i];
   SendData[i] = CheckSum;
   WriteFile(hComm,&SendData,sizeof(SendData),&lrc,NULL);
}
//------------------------------------------------------------------------------
bool __fastcall TControlBoard::ReadRS232Value(unsigned short* Data)
{
   COMSTAT        cs;
   DWORD          nBytesRead,dwEvent,dwError,lpEvtMask;
   OVERLAPPED     o;
   int            ln;
   unsigned int   i,CsCount;
   unsigned long  lrc;
   unsigned char  CheckSum;//ReceiverDataBuff[256];

   if(hComm == INVALID_HANDLE_VALUE)
      return false;
   ClearCommError(hComm,&dwError,&cs);
   if(cs.cbInQue < 0)
      return false;

   do{
      ClearCommError(hComm,&dwError,&cs);         //取得狀態
      CsCount = cs.cbInQue;
      Sleep(10);                                  //等待RX資料全部接收完畢，條件是鮑率的速度
      ClearCommError(hComm,&dwError,&cs);
      }while(CsCount != cs.cbInQue );
   if(cs.cbInQue > sizeof(ReceiverDataBuff)){     //資料是否大於我們所準備的Buffer
      PurgeComm(hComm,PURGE_RXCLEAR);
      return false;
      }
   if(cs.cbInQue){
      ReadFile(hComm,ReceiverDataBuff,cs.cbInQue,&nBytesRead,NULL);//接收COM的資料
      CheckSum = 0;
      for(i=0 ; i<(cs.cbInQue-1) ; i++)
          CheckSum += ReceiverDataBuff[i];
      if(ReceiverDataBuff[1] == 0x43 && CheckSum == ReceiverDataBuff[cs.cbInQue-1]){
         RXDataBuff[0]= ReceiverDataBuff[4];
         RXDataBuff[1]= ReceiverDataBuff[5];
         RXDataBuff[2]= ReceiverDataBuff[6];
         }
      *Data = (((USHORT)ReceiverDataBuff[4])<<8)|((USHORT)ReceiverDataBuff[5] & 0x00ff);
      PurgeComm(hComm,PURGE_RXCLEAR);             //清除RX Buff內的資料
      //PurgeComm(hComm,PURGE_TXCLEAR);
      return true;
      }
   else{
      PurgeComm(hComm,PURGE_RXCLEAR);
      //PurgeComm(hComm,PURGE_TXCLEAR);
      return false;
      }
}
//---------------------------------------------------------------------------
void __fastcall TControlBoard::OpenBOX(void)
{
    SendRS232Data(0x01,0x01,0x01);
}
//---------------------------------------------------------------------------
void __fastcall TControlBoard::CloseBOX(void)
{
    SendRS232Data(0x01,0x02,0x01);
}
//---------------------------------------------------------------------------
void __fastcall TControlBoard::FixtureUP(void)
{
    SendRS232Data(0x01,0x05,0x01);
}
//---------------------------------------------------------------------------
void __fastcall TControlBoard::FixtureDOWN(void)
{
    SendRS232Data(0x01,0x06,0x01);
}
//---------------------------------------------------------------------------
void __fastcall TControlBoard::ResetBOX(void)
{
    SendRS232Data(0x01,0x09,0x01);
}
//---------------------------------------------------------------------------
void __fastcall TControlBoard::OpenLight(void)
{
    SendRS232Data(0x01,0x07,0x01);
}
//---------------------------------------------------------------------------
void __fastcall TControlBoard::CloseLight(void)
{
    SendRS232Data(0x01,0x07,0x00);
}
//---------------------------------------------------------------------------
void __fastcall TControlBoard::Yellow(bool OnOff)
{
    if(OnOff)
       SendRS232Data(0x01,0x08,0x01);
    else
       SendRS232Data(0x01,0x08,0x00);
}
//------------------------------------------------------------------------------
