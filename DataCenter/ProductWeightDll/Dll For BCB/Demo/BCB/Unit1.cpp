//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
#include "ProdectWeightDll.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "MSCommLib_OCX"
#pragma resource "*.dfm"
TForm1 *Form1;

#define uchar unsigned char
#define uint unsigned int

bool Running = false ;
unsigned char Command[2] = {0x01,0x73} ;
unsigned char ReceiverDataBuff[256],RXDataBuff[256];
TCanvas *Cavs ;
//Cavs: TCanvas;

//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
  Cavs = new TCanvas ;
  Cavs->Handle = GetDC(0);
  Application->OnMessage = AppMessage ;
}
//---------------------------------------------------------------------------
char ConvertHexChar(char ch)
{
    if((ch>='0')&&(ch<='9'))
    return ch-0x30;
    else if((ch>='A')&&(ch<='F'))
    return ch-'A'+10;
    else if((ch>='a')&&(ch<='f'))
    return ch-'a'+10;
    else return (16);
}
//---------------------------------------------------------------------------
void __fastcall ReadWeight_MSCom(TMSComm *ComPortStr,String CommandStr)
{
    String Str = "" ;
    //="01 73";//取得發送文本
    OleVariant temp;              //聲明變體變量
    uchar c=0;
    int Len = CommandStr.Length();
    if(!Len)return;//發送緩衝區數據空.自動退出

    if(ComPortStr->PortOpen)
    {
        temp=VarArrayCreate(OPENARRAY(int,(0,(Len-2)/3)),varByte);//創造單個變體int,(0,10))發送11個數據
        //TxBuff=VarArrayCreate(OPENARRAY(int,(0,length)),varByte);
        for(int n=1;n<Len;n++)//讀取數據
        {
            c = CommandStr[n];
            if(!(c==32||47<c<58||64<c<71||96<c<103))
            {
                Application->MessageBox("請輸入合法數字!","輸入錯誤",MB_OK);
                return;
            }
        }
        int hexdata,lowhexdata;
        int hexdatalen=0;

        char* p = CommandStr.c_str();
        for(int i=0;i<Len;)
        {
            char lstr,hstr=*(p+i);
            if(hstr==' ')
            {
                i++;
                continue;
            }
            i++;
            if(i>=Len)
            break;
            lstr=*(p+i);
            hexdata=ConvertHexChar(hstr);
            lowhexdata=ConvertHexChar(lstr);
            if((hexdata==16)||(lowhexdata==16))
            break;
            else
            hexdata=hexdata*16+lowhexdata;
            i++;
            temp.PutElement(hexdata,hexdatalen);
            hexdatalen++;
        }
        //return hexdatalen;
        ComPortStr->Output=temp;
    }
}
//---------------------------------------------------------------------------
void __fastcall SendWeightComand(TMSComm *ComPortStr,unsigned char* CommandStr)
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
                if (!ComPortStr->PortOpen) { ComPortStr->PortOpen = True ;}
                ComPortStr->Output = TxBuff ;
        }
        catch(Exception &exception)
        {
                ShowMessage("Sorry,數據發送過程中出現錯誤!") ;
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
String __fastcall GetMSCommWeight(TMSComm *ComPortStr)
{
        OleVariant RxBuff ;
        int ByteNum, BuffPtr ;
        AnsiString TempStr ;
        unsigned char buff[200];

        if(ComPortStr->CommEvent==comEvReceive)
        {
                if(ComPortStr->InBufferCount>=13)// 是否有字符駐留在接收緩衝區等待被取出
                {
                        Sleep(10);
                        RxBuff = ComPortStr->Input ;
                        //方法1
                        /*ByteNum = RxBuff.ArrayHighBound(1);
                        for (int i = 0;i<ByteNum ;i++)
                                {buff[BuffPtr++]=RxBuff.GetElement(i);} */
                        //ShowMessage(String(buff));
                        //方法二
                        TempStr = WideString(RxBuff);
                        TempStr = TempStr.Trim();
                        //TempStr = TempStr.Format("0.00g") ;
                        //Panel1->Caption = TempStr;
                        return  TempStr ;
                }
        }
        return "";
}

//---------------------------------------------------------------------------
void __fastcall TForm1::Button1Click(TObject *Sender)
{
        try
        {
                OleVariant TxBuff;
                int OutBuff[2] = {0x01,0x73} ;
                int n = 2 ;
                //unsigned char buff[2] = {0x01,0x73};
                TxBuff = VarArrayCreate(OPENARRAY(int,(0,n-1)),varByte);
                for (int i =0 ;i < n;i++)
                        TxBuff.PutElement(OutBuff[i],i) ;    //   buff
                if (!MSComPort->PortOpen) { MSComPort->PortOpen = True ;}
                MSComPort->Output = TxBuff ;
        }
        catch(Exception &exception)
        {
                ShowMessage("Sorry,數據發送過程中出現錯誤!") ;
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
void __fastcall TForm1::MSComPortComm(TObject *Sender)
{
        OleVariant RxBuff ;
        int ByteNum, BuffPtr ;
        AnsiString TempStr ;
        unsigned char buff[200];

        if(MSComPort->CommEvent==comEvReceive)
        {
                if(MSComPort->InBufferCount>=13)// 是否有字符駐留在接收緩衝區等待被取出
                {
                        Sleep(10);
                        //Delay(10);
                        RxBuff = MSComPort->Input ;
                        //方法1
                        //ByteNum = RxBuff.ArrayHighBound(1);
                        //for (int i = 0;i<ByteNum ;i++)
                                //{buff[BuffPtr++]=RxBuff.GetElement(i);}
                        //ShowMessage(String(buff));
                        //方法二
                        TempStr = WideString(RxBuff);
                        TempStr = TempStr.Trim();
                        //TempStr = TempStr.Format("0.00g") ;
                        Panel1->Caption = TempStr;
                }
        }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button2Click(TObject *Sender)
{
        Timer1->Enabled = !Timer1->Enabled ;
        //SendWeightComand(MSComPort,Command);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Timer1Timer(TObject *Sender)
{
        if (!Running)
        {
                Running = true ;
                SendWeightComand(MSComPort ,Command);
                //Panel1->Caption = GetMSCommWeight(MSComPort);
                Running = false ;
        }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button3Click(TObject *Sender)
{
    InitDllForm("COM1",Handle);  
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button4Click(TObject *Sender)
{
    CloseDllForm() ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button6Click(TObject *Sender)
{
        CommPortSet(1,"9600,n,8,1");
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormClose(TObject *Sender, TCloseAction &Action)
{
        CloseDllForm() ;        
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button5Click(TObject *Sender)
{
   DCB dcb;
   AnsiString ComPort = "COM1";
   COMFlag = false;
   hComm=CreateFile(ComPort.c_str(), GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, 0);
   if(hComm == INVALID_HANDLE_VALUE)
      return ;
   GetCommState(hComm, &dcb);
   dcb.BaudRate = 9600;
   dcb.ByteSize = 8;
   dcb.Parity   = NOPARITY;
   dcb.StopBits = ONESTOPBIT;
   if(!SetCommState(hComm, &dcb))
   {
      CloseHandle(hComm);
      return ;
   }
   COMFlag = true;
   PurgeComm(hComm,PURGE_RXCLEAR);//清除RX Buff內的資料
   Timer2->Enabled = True;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button8Click(TObject *Sender)
{
 char   SendData[2]={0x01,0x73}; //格式Start Tx,0x80,PutSingal,Item,Data1,Data,End Tx,CheckSum
 int    ln;
 unsigned long  lrc,BS;
 unsigned int   i;
 char           CheckSum=0x00;

 //SendData[2]= Function;
 //SendData[4]= Data1;
 //SendData[5]= Data2;
 if(COMFlag==false)
    return;
 Sleep(0);
 /*BS = sizeof(SendData)-1;                       //取得傳送的字串數
 CheckSum = 0;
 for(i=0 ; i<BS ; i++)
     CheckSum += SendData[i];
 SendData[i] = CheckSum;*/
 WriteFile(hComm,&SendData,sizeof(SendData),&lrc,NULL);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button9Click(TObject *Sender)
{
 COMSTAT        cs;
 DWORD          nBytesRead,dwEvent,dwError,lpEvtMask;
 OVERLAPPED     o;
 int            ln;
 unsigned int   i,CsCount;
 unsigned long  lrc;
 unsigned char  CheckSum;//ReceiverDataBuff[256];
 unsigned short* Data ;

 if(hComm == INVALID_HANDLE_VALUE)
    return ;
 ClearCommError(hComm,&dwError,&cs);
 if(cs.cbInQue < 0)
    return ;

 do{
    ClearCommError(hComm,&dwError,&cs);         //取得狀態
    CsCount = cs.cbInQue;
    Sleep(10);                                  //等待RX資料全部接收完畢，條件是鮑率的速度
    ClearCommError(hComm,&dwError,&cs);
    }while(CsCount != cs.cbInQue );
 if(cs.cbInQue > sizeof(ReceiverDataBuff)){     //資料是否大於我們所準備的Buffer
    PurgeComm(hComm,PURGE_RXCLEAR);
    return ;
    }
 if(cs.cbInQue){
    AnsiString Temp ;
    ReadFile(hComm,ReceiverDataBuff,cs.cbInQue,&nBytesRead,NULL);//接收COM的資料
    //String str=String(ReceiverDataBuff);
    //strcpy(Temp.c_str(),(char*)ReceiverDataBuff );
    //String Temp((char *)ReceiverDataBuff);
    //Temp = AnsiString(WideString(ReceiverDataBuff));

    //strcpy(s._str(),(char*)str);
      //unsigned char *str = "abc";
      //string s;
      //strcpy(s._str(),(char*)str);
    Temp = (char *)ReceiverDataBuff  ;
    //ShowMessage(Temp) ;
    Form1->Caption = Temp ;
    ZeroMemory(ReceiverDataBuff,sizeof(ReceiverDataBuff));
    //Temp.c_str() = ReceiverDataBuff ;
    /*CheckSum = 0;
    for(i=0 ; i<(cs.cbInQue-1) ; i++)
        CheckSum += ReceiverDataBuff[i];
    if(ReceiverDataBuff[1] == 0x43 && CheckSum == ReceiverDataBuff[cs.cbInQue-1]){
       RXDataBuff[0]= ReceiverDataBuff[4];
       RXDataBuff[1]= ReceiverDataBuff[5];
       RXDataBuff[2]= ReceiverDataBuff[6];
       }*/
    //*Data = (((USHORT)ReceiverDataBuff[4])<<8)|((USHORT)ReceiverDataBuff[5] & 0x00ff);
    PurgeComm(hComm,PURGE_RXCLEAR);             //清除RX Buff內的資料
    
    //PurgeComm(hComm,PURGE_TXCLEAR);
    return ;
    }
 else{
    PurgeComm(hComm,PURGE_RXCLEAR);
    //PurgeComm(hComm,PURGE_TXCLEAR);
    return ;
    }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button10Click(TObject *Sender)
{
 PurgeComm(hComm, PURGE_RXCLEAR);
 FlushFileBuffers(hComm);
 CloseHandle(hComm);
 COMFlag = false;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button11Click(TObject *Sender)
{
  //Button5->Click() ;
  Button8->Click() ;
  Sleep(20);
  Button9->Click() ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Timer2Timer(TObject *Sender)
{
Button11->Click() ;        
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button12Click(TObject *Sender)
{
        //Panel1->Caption = GetWeightDllAPI().Trim() ;
        Panel1->Caption = GetWeightDllMSComm().Trim() ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button14Click(TObject *Sender)
{
        //ShowWeightForm(5000);
        //Panel1->Caption = GetWeightForm(30);
        Panel1->Caption = ShowDllFormAPI(1000) ;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button7Click(TObject *Sender)
{
        //ShowWeightFormEver();
        Panel1->Caption = ShowWeightForm(1000) ;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::uShowStop(String Display)
{
  int intL,intT,intR,intB ;

  intL = Screen->Width/4;
  intT = Screen->Height/4;
  intR = Screen->Width*3/4;
  intB = Screen->Height*2/4;

  Cavs->Font->Color = clRed;
  Cavs->Font->Size = (intR-intL)/4;
  //Cavs->Font->Style = [fsBold];
  Cavs->Pen->Color = clLime;
  Cavs->Pen->Width = 3;
  Cavs->Brush->Style = bsSolid;
  Cavs->Brush->Color = clYellow;
  Cavs->Rectangle(intL,intT,intR,intB);
  //Cavs->Rectangle(intL+(intR-intL)*2/5,intB,intL+(intR-intL)*3/5,intT+(intB-intT)*2);
  Cavs->Brush->Style = bsClear;
  Cavs->TextOut(Screen->Width/5+(intR-intL)/5,Screen->Height/5+(intB-intT)/5,Display);
}

//---------------------------------------------------------------------------
void __fastcall TForm1::FormDestroy(TObject *Sender)
{
        Cavs->Free() ;        
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button13Click(TObject *Sender)
{
        uShowStop(GetWeightDllAPI().Trim());
}
//---------------------------------------------------------------------------
/*void   __fastcall   TForm1::WndProc(TMessage&   Message)
{
    case   WM_TEST   :

        AnsiString   Str=AnsiString((char*)Message.LParam); 
        Memo1-> Lines-> Add(Str);//?任何?? 
        break; 

    default: 
  
        TForm::WndPProc(Message); 
        break;
    if(Message.Msg==WM_COPYDATA)
    {
          COPYDATASTRUCT   *cds;
          char*   DataBuf;

          cds=(COPYDATASTRUCT*)Message.LParam;
          DataBuf=new   char[cds-> cbData];
          CopyMemory(DataBuf,cds-> lpData,cds-> cbData);

          AnsiString   Str=AnsiString(DataBuf);
          //Memo1-> Lines-> Add( "Str= "+Str);
          ShowMessage("Str= "+Str);
          delete[]   DataBuf;
    }
}*/
//---------------------------------------------------------------------------
void   __fastcall   TForm1::AppMessage(tagMSG   &Msg,   bool   &Handled)
{
     /*if ((Msg.message = WM_COPYDATA) && (Msg.wParam == WM_USER + 2012 ))
     {
          COPYDATASTRUCT   *cds;
          char*   DataBuf;

          //if (Msg.wParam != 0) {return ;}
          cds=(COPYDATASTRUCT*)Msg.lParam ;    //.LParam;
          if (cds ==NULL) {return ;}
          DataBuf = new   char[cds->cbData];
          CopyMemory(DataBuf,cds->lpData,cds->cbData);

          AnsiString   Str=AnsiString(DataBuf);
          //Memo1-> Lines-> Add( "Str= "+Str);
          ShowMessage("Str= "+Str);
          delete[]   DataBuf;
     } */
}
//---------------------------------------------------------------------------

