unit unitDeclareATOP;

interface

type
  TCCB = record
    Len:WORD ;                        // length of message
    Port:BYTE;                        // port number of gateway, 60H:port1, 61H:port2
    Dst_Node:BYTE;                    // reserved, no used
    Gateway:BYTE;                     // source gateway ID
    Msg_Type:BYTE;                    // reserved, no used
    Sub_Cmd : Byte;
    Sub_Node : Byte;
    Data : array [0..255] of byte;    // data
  end;

  TCCB_SUB_Status=record
    Reserverd : array [0..2] of Byte;
    Data : array[0..31] of byte;
  end;

  TCCB_SUB_DATA=record
    Sub_Type : Byte;
    Data : array[0..255] of byte;
  end;

  // Initialization
  function  AB_API_Open:Integer;stdcall; external 'dapapi2.dll';
  function  AB_API_Close:Integer;stdcall; external 'dapapi2.dll';
  function  AB_GW_Open(Gateway_ID:WORD):Integer;stdcall; external 'dapapi2.dll';
  function  AB_GW_Close(Gateway_ID:WORD):Integer;stdcall; external 'dapapi2.dll';
  function  AB_GW_Cnt: Integer;stdcall; external 'dapapi2.dll';
  function  AB_GW_Conf( index:WORD; var Gateway_ID:WORD; ip:PChar;
                        var ip_port:integer):Integer;stdcall; external 'dapapi2.dll';
  function  AB_GW_Ndx2ID( index:WORD):Integer;stdcall; external 'dapapi2.dll';
  function  AB_GW_ID2Ndx( Gateway_ID:WORD):Integer;stdcall; external 'dapapi2.dll';
  function  AB_GW_InsConf( Gateway_ID:WORD; ip:PChar;
                        ip_port:integer):Integer;stdcall; external 'dapapi2.dll';
            //Gateway_id:2 bytes, ip:N bytes untill null, ip_port:2 byte
            //ret >=0:OK(index no.), -1:overflow, -2:duplicate ID, -3:duplicate IP & Port
  function  AB_GW_UpdConf( Gateway_ID:WORD; ip:PChar;
                        ip_port:integer):Integer;stdcall; external 'dapapi2.dll';
            //Gateway_id:2 bytes, ip:N bytes untill null, ip_port:2 byte
  function  AB_GW_DelConf( Gateway_ID:WORD):Integer;stdcall; external 'dapapi2.dll';
            //Gateway_id:2 bytes

  // Get/Send message from/to Gateway
  function  AB_GW_RcvMsg(Gateway_ID:WORD;data:PChar):Integer;stdcall; external 'dapapi2.dll';
            //ret=0:no data, >0:data length, <0:error
  function  AB_GW_SndMsg(Gateway_ID:WORD;data:PChar):Integer;stdcall; external 'dapapi2.dll';
  function  AB_GW_RcvReady(Gateway_ID:WORD):Integer;stdcall; external 'dapapi2.dll';
            //ret=0:no data, >0:has data, <0:error
  function  AB_GW_RcvData(Gateway_ID:WORD):Integer;stdcall; external 'dapapi2.dll';
  function  AB_GW_RcvAddr:WORD;stdcall; external 'dapapi2.dll';
  function  AB_GW_RcvPort:WORD;stdcall; external 'dapapi2.dll';
            //ret=0:no data or err, 1:port1, 2:port2
  function  AB_GW_RcvTagNode:SmallInt;stdcall; external 'dapapi2.dll';
            //ret=0:no data or err, else:tag node
  function  AB_GW_RcvTagCmd:WORD;stdcall; external 'dapapi2.dll';
            //ret=0:no data or err, else:tag cmd
  function  AB_GW_RcvTagData(data:PChar):SmallInt;stdcall; external 'dapapi2.dll';
            //ret=0:no data or err, else:data length
//function  AB_GW_RcvNext(Gateway_ID:Integer):Integer;stdcall; external 'dapapi2.dll';
  function  AB_GW_SetDefault(Gateway_ID:WORD):Integer;stdcall; external 'dapapi2.dll';
  function  AB_GW_GetDefault:WORD;stdcall; external 'dapapi2.dll';

  // Get Gateway status
  function  AB_GW_Status(Gateway_ID:WORD):Integer;stdcall; external 'dapapi2.dll';
            //status[]=0:closed, 6:connecting, 7:connected, 9:error
  function  AB_GW_AllStatus( status:PChar):Integer;stdcall; external 'dapapi2.dll';
  function  AB_GW_TagDiag(Gateway_ID:WORD;Port_ID:Integer):Integer;stdcall; external 'dapapi2.dll';
            //Gateway_ID= 0:for all, PORT_ID=0:for all
  function  AB_GW_SetPollRang(gw_id:WORD; port:integer; poll_range:SmallInt):Integer;stdcall; external 'dapapi2.dll';

  //-----Tag
  function  AB_Tag_RcvMsg( var tag_addr:Longint; var subcmd:Smallint; var msgtype:Smallint;
                          data:PChar; var data_cnt:Word):Integer;stdcall; external 'dapapi2.dll';
  function  AB_Tag_Reset(tag_addr:LongInt):Integer;stdcall; external 'dapapi2.dll';
  function  AB_Tag_ChgAddr(tag_addr:LongInt; new_tag:SmallInt)
                        :Integer;stdcall; external 'dapapi2.dll';
  // Send Message to picking tag
  function  AB_LB_DspNum(tag_addr:LongInt;Disp_Int:Integer;Dot:BYTE;
                         Interval:SmallInt):Integer;stdcall; external 'dapapi2.dll';
                    // interval=0:normal, >0:set blink, -1:blink,
                    // -2:turn off digits, -3:turn off all
  function  AB_LB_DspStr(tag_addr:LongInt;Disp_Str:PCHAR;DOT:BYTE;
                         Interval:SmallInt):Integer;stdcall; external 'dapapi2.dll';
                    // interval=0:normal, >0:set blink, -1:blink,
                    // -2:turn off digits, -3:turn off all
  function  AB_LB_DspStr2(tag_addr:LongInt;Disp_Str:PCHAR;
                         Interval:SmallInt):Integer;stdcall; external 'dapapi2.dll';
                    // interval=0:normal, >0:set blink, -1:blink,
                    // -2:turn off digits, -3:turn off all
  function  AB_LB_DspOff(tag_addr:LongInt):Integer;stdcall; external 'dapapi2.dll';
  function  AB_LB_DspAddr(tag_addr:LongInt):Integer;stdcall; external 'dapapi2.dll';
  function  AB_LB_LedOn(tag_addr:LongInt;Lamp_STA:BYTE;INTERVAL:WORD)
                      :Integer;stdcall; external 'dapapi2.dll';
  function  AB_LB_BuzOn(tag_addr:LongInt;Buzzer_Type:BYTE):Integer;stdcall; external 'dapapi2.dll';
  function  AB_LB_SetMode(tag_addr:LongInt;Pick_Mode:BYTE):Integer;stdcall; external 'dapapi2.dll';
  function  AB_LB_Simulate(tag_addr:LongInt;Simulate_Mode:BYTE):Integer;stdcall; external 'dapapi2.dll';
  function  AB_LB_SetLock(tag_addr:LongInt;Lock_State:BYTE;Lock_key:BYTE)
                        :Integer;stdcall; external 'dapapi2.dll';
                            //lock_key=bit0:confirm, bit1:lack
                            //lock_state=1:lock, 0:unlock
  //-----MMI-19
  function  AB_DCS_InputMode(tag_addr:LongInt;input_mode:BYTE)
                    :Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_BufSize(tag_addr:LongInt;buf_size:BYTE)
                    :Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_SetConf(tag_addr:LongInt;enable_status:BYTE;
                    disable_status:BYTE):Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_ReqConf(tag_addr:LongInt):Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_GetVer(tag_addr:LongInt):Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_Reset(tag_addr:LongInt):Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_SetRows(tag_addr:LongInt; rows:BYTE):Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_SimulateKey(tag_addr:LongInt;key_code:BYTE)
                    :Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_Cls(tag_addr:LongInt):Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_Buzzer(tag_addr:LongInt; alarm_time:BYTE; alarm_cnt:BYTE)
                    :Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_ScrollUp(tag_addr:LongInt;up_rows:BYTE)
                    :Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_ScrollDown(tag_addr:LongInt;down_rows:BYTE)
                    :Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_ScrollHome(tag_addr:LongInt):Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_ScrollEnd(tag_addr:LongInt):Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_SetCursor(tag_addr:LongInt; row:BYTE; col:BYTE)
                    :Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_DspStrE(tag_addr:LongInt;dsp_str:PCHAR; dsp_cnt:SmallInt)
                        :Integer;stdcall; external 'dapapi2.dll';
  function  AB_DCS_DspStrC(tag_addr:LongInt;dsp_str:PCHAR; dsp_cnt:SmallInt)
                        :Integer;stdcall; external 'dapapi2.dll';
// DCS-19: Receive System Configuration
//         sub-command = $37
//         data = $32 + Status[2],  (Hex string for 8 bits)
// DCS-19: Receive Keys
//         sub-command = $37
//         data = $30 + Keyin_data[2]*N,  (Receive N Keys)
//                     (Keyin_data[0]:ASCII_Code, Keyin_data[1]:Scan_Code)
// DCS-19: Receive Keyin String
//         sub-command = $37
//         data = $31 + String + $0A
// DCS-19: Receive Startup Message
//         sub-command = $37
//         data = $41 + "MMI-19 Self-Reset OK !!"
// DCS-19: Receive Communication Revival Message
//         sub-command = $37
//         data = $42 + "MMI-19 Interface Refresh !!"
// DCS-19: Receive Version Message
//         sub-command = $37
//         data = $43 + "MMI-19 V80116"

  //-----Convertor
  function  AB_CNV_SendData(tag_addr:LongInt;dsp_str:PCHAR; dsp_cnt:SmallInt)
                        :Integer;stdcall; external 'dapapi2.dll';
  function  AB_CNV_SetTerminator(tag_addr:LongInt;Terminator:SmallInt)
                        :Integer;stdcall; external 'dapapi2.dll';
// Converter: Receive Rs-232 Data:
//         sub-command = $28
//         data = Receive_Data (each byte must be <= $7F)

  //-----AP20A
  function  AB_LB2_DspStr(tag_addr:LongInt;DISP_STR:PCHAR;INTERVAL:SmallInt)
                       :Integer;stdcall; external 'dapapi2.dll';
                    // interval=0:normal, >0:set blink, -1:blink,
                    // -2:turn off digits, -3:turn off all
  function  AB_LB2_SetRows(tag_addr:LongInt; max_rows:SmallInt)
                        :Integer;stdcall; external 'dapapi2.dll';
  function  AB_LB2_Download(tag_addr:LongInt; row:SmallInt; dsp_str:PCHAR)
                        :Integer;stdcall; external 'dapapi2.dll';
//----- Fixed CCD
  function AB_CCD_Rescan(tag_addr:LongInt):Integer;stdcall; external 'dapapi2.dll';
// Fixed CCD: Receive Bar Code String:
//         sub-command = $2D
//         data = $11 + String    :read barcode
//         data = $13             :read error
//         data = $14             :remove

//----- DT200
  function  AB_DT2_DspStr(tag_addr:LongInt;dsp_str:PCHAR; dsp_cnt:SmallInt)
                        :Integer;stdcall; external 'dapapi2.dll';
  function  AB_DT2_EnableCounter(tag_addr:LongInt)
                        :Integer;stdcall; external 'dapapi2.dll';
  function  AB_DT2_DisableCounter(tag_addr:LongInt)
                        :Integer;stdcall; external 'dapapi2.dll';
  function  AB_DT2_ReadCounter(tag_addr:LongInt)
                        :Integer;stdcall; external 'dapapi2.dll';
  function  AB_DT2_SetCounter(tag_addr:LongInt; count:Integer)
                        :Integer;stdcall; external 'dapapi2.dll';

// DT-200: Receive Function Key:
//         sub-command = $40
//         data = $A0 + $00 + Byte[1],    F1-F7=$3B-$41
//
// Receive String from Keypad:
//         sub-command = $40
//         data = $A0 + String + $0D + $0A
//
// Receive String from Wand:
//         sub-command = $40
//         data = $A1 + String + $0D + $0A
//
// Receive Counter Value (after request):
//         sub-command = $40
//         data = $A1 + $00 + Long(4byte)

//-----DIO
  function  AB_DIO_ReadIoStatus(tag_addr:LongInt)
                        :Integer;stdcall; external 'dapapi2.dll';
  function  AB_DIO_SetDO(tag_addr:LongInt; channel: SmallInt; status:SmallInt)
                        :Integer;stdcall; external 'dapapi2.dll';
//channel=1-16:only one channel is updated, 0:all channels are updated
  function  AB_DIO_SetDiRspMode(tag_addr:LongInt; mode: SmallInt)
                        :Integer;stdcall; external 'dapapi2.dll';
//mode=0:non-auto, 1:auto
//function  AB_DIO_SetDiOpMode(tag_addr:LongInt; mode: SmallInt)
//                      :Integer;stdcall; external 'dapapi2.dll';
//mode: bit0=0:non-auto, 1:auto
//      bit1=0:Edge trigger, 1:level trigger
//      bit2=0:Normal Low, 1:Normal High
// DIO: Receive IO Status
//         sub-command = $3C
//         data = [0]:Reserved + [1]:I/O Type('0':DI, '1':DO, '3':DO-LED,
//                                            '5':DO-BLINK) +
//                [2-3]:Channel 0-7 Status( Hex Code, 1:on, 0:off)
//                [4-5]:Channel 8-15 Status( Hex Code, 1:on, 0:off)
//         data = [0]:Reserved + [1]:I/O Type('4':DI-AUTO) +
//                [2-3]:Channel 0-7 Now_Status( Hex Code, 1:on, 0:off)
//                [4-5]:Channel 8-15 Now_Status( Hex Code, 1:on, 0:off)
//                [6-7]:Channel 0-7 Previous_Status( Hex Code, 1:on, 0:off)
//                [8-9]:Channel 8-15 Previous_Status( Hex Code, 1:on, 0:off)

  // Send meaasge to mini-KANBAN
  function  AB_KBN_Clear(tag_addr:LongInt):Integer;stdcall; external 'dapapi2.dll';
  function  AB_KBN_DspMsg(tag_addr:LongInt;Msg:PCHAR;dsp_mode:Integer;
                        scroll_mode:Integer):Integer;stdcall; external 'dapapi2.dll';
  function  AB_KBN_SegDownload(tag_addr:LongInt; seg_no:SmallInt; msg:PCHAR;
                        dsp_mode:Integer; scroll_mode:Integer):Integer;stdcall; external 'dapapi2.dll';
  function  AB_KBN_SegDel(tag_addr:LongInt;seg_no:SmallInt)
                        :Integer;stdcall; external 'dapapi2.dll';
  function  AB_KBN_SegDsp(tag_addr:LongInt; seg_no:PChar; seg_cnt:SmallInt)
                        :Integer;stdcall; external 'dapapi2.dll';

Const
//  Offset constants in CCB.data field
    CAPS_COMMAND   =  0;       //  CAPS command code, listed below
    CAPS_NODE      =  1;       //  ID address of CAPS modules
    CAPS_MSD       =  2;       //  offset of first digit

//  CAPS 控制碼的代號及功能
    CAPS_DISPLAY_ON      =   0 ;      //  show digits on display
    CAPS_DISPLAY_OFF     =   1 ;      //  turn off display
    CAPS_LED_ON          =   2 ;      //  turn on LED indicator
    CAPS_LED_OFF         =   3 ;      //  turn off LED indicator
    CAPS_BUZZER_ON       =   4 ;      //  turn on buzzer
    CAPS_BUZZER_OFF      =   5 ;      //  turn off buzzer
    CAPS_SET_RANGE_SIMPLE=   34;
    CAPS_SET_RANGE_DELUX =   8 ;      //  set dta scan range
    CAPS_GET_RANGE       =   9 ;      //  get dta scan range
    CAPS_DISPLAY_BLINK   =   16;      //  make display blink
    CAPS_LED_BLINK       =   17;      //  make LED indicator blink
    CAPS_SET_BLINK_TIME  =   18;      //  set blink time interval of LED
    CAPS_SHOW_ADDRESS    =   19;      //  show address of module on display
    CAPS_RESET           =   20;      //  reset module
    CAPS_LOCK_LACK       =   21;      //  lock the button of LACK
    CAPS_UNLOCK_LACK     =   22;      //  unlock the button of LACK
    CAPS_EMULATE_CONFIRM =   23;      //  simulate CONFIRM button preesed
    CAPS_EMULATE_LACK    =   24;      //  simulate LACK button pressed
    CAPS_PICK_MODE       =   25;      //  switch to ORDER PICKING mode
    CAPS_STOCK_MODE      =   26;      //  switch to STOCK ADJUST mode
    CAPS_LOCK_CONFIRM    =   27;      //  lock the button of LACK
    CAPS_UNLOCK_CONFIRM  =   28;      //  unlock the button of LACK


// 常數定義
   MODE_OFF      =   0 ;      // OFF mode of module
   MODE_ON       =   1 ;      // ON  mode of module
   MODE_BLINK    =   2 ;      // BLINK mode of module
   MODE_DEFAULT  =   3 ;

   MODE_STOCK    =   0 ;      // STOCK ADJUST mode of module
   MODE_PICK     =   1 ;      // ORDER PICKING mode of module
   BTN_CONFIRM   =   0 ;      // CONFIRM button
   BTN_LACK      =   1 ;      // LACK button
   BTN_TWO       =   2 ;      // both two button

   //TCP status
   SCK_CLOSED    =   0 ;
   SCK_CONNECTING=   6 ;
   SCK_CONNECTED =   7 ;
   SCK_ERROR     =   9 ;


implementation




end.
