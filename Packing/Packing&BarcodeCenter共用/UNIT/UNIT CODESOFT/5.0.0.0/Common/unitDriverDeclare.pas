unit unitDriverDeclare;

interface

uses unitLog;
const
  cSoundNone = 0;
  cSoundType1 = 1;
  cSoundType2 = 2;
  cSoundType3 = 3;
  cSoundType4 = 4;
  cSoundType5 = 5;
  cSoundOK = 2;
  cSoundError =1 ;
//VALUE的類型
  cValueNormal=0;
  cValueOnce=1;
  cValueMultiple=2;
  cValueLastInput=3;
//VALUE的TRANSFER的類型
  cTransNormal=0;
  cTransUpper=1;
  cTransLower=2;

//Port Type Informaiton
  cPortUnused=0;
  cPortIn=1;
  cPortOut=2;
  cPortIn_Out=3;

//function 回傳代碼
  cResultOK = 0 ;
  cResultError =1;
  cResultCancel=2;
  cResultBuferOverFlow=3;
  cResultUndefined=4;
  cResultNotInitialize=5;
  cResultIllegeal=6;
  cResultSetupValueIllegeal=7;
  cResultDuplicateResource=8;
  cResultGatewayNotExist=9;
  cResultIDNotExist =10;
  cResultDriverLinkFail=11;
  cResultPortIllegeal =12;
  cResultBuzzIllegeal =13;
  cResultPortNotExist =14;
  cResultMsgTypeIllegeal=15;
//DRIVER CALL BCAK FUNCTION的類別
  cMsgStatus =1 ;
  cMsgReceiveData=2;
//DEVICE STATUS
  cDeviceOffLine = 0;
  cDeviceOnLine=1;
//TCS Send Data Type
  cMsgSendEnglish = 1;
  cMsgSendChinese = 2;
  cMsgDestroy =10;

//TGS和DRIVER之間CHECK合法性的字串
  cCheckLegeal='神傑';

type
  TOnTransData=function (f_iMsgType,f_iGID,f_iSubID,f_iPort,f_iBuzz:integer;f_pData:pchar;f_iLen:integer) : integer of object;


//Device Port Information
  TGateway_Information=record
    sGatewayName : pchar;
    iPortCount : integer;
  end;

//Device Information
  TPort_Information=record
    iPortID : integer;
    sPortName : pchar;
    iDataMaxLen : integer;
    iPortType : integer; // 參考const中的Port Type Informaiton
  end;

  //================================================================================================
  { DRIVER 所有被呼叫的FUNCTION }
  TSajet_SetupValue=procedure (f_pcharData : pchar);
  TSajet_Get_Gateway_Info=function(var f_Gateway_Information: TGateway_Information) : integer;
  TSajet_Get_Port_Info=function(f_iOrder:integer;var f_Port_Information:TPort_Information) : integer ;
  TSajet_setup_Gateway=function(f_pSetupValue :pchar;var f_iCount : integer) : integer;
  TSajet_Open_Gateway=function (f_iGID : integer;f_pSetupValue:pchar;f_OnReceiveData : TOnTransData ): integer;
  TSajet_close_Gateway=function (f_iGID : integer) : integer;
  TSajet_Send_Data=function (f_iMsgType,f_iGID,f_iSubID,f_iPort,f_iBuzz:integer;f_pData:pchar;f_iLen:integer) : integer ;
  TSajet_Check_Setup=function(f_pSetupValue,f_pSetupOther :pchar) : integer;

  function G_DriverGetRandomString : string;
  function G_DriverGetFeedBackString(f_sOld : string) : string;
  function G_DriverEncodeDriverCommand(f_iMsgType,f_iGID,f_iSubID,f_iPort,f_iBuzz:integer;f_pData:pchar;f_iLen:integer) : string;
  procedure G_DriverDecodeDriverCommand(f_sEncode:string;var f_iMsgType,f_iGID,f_iSubID,f_iPort,f_iBuzz:integer;var f_sData : string);

implementation
uses classes,sysutils,unitConvert;

procedure G_DriverDecodeDriverCommand(f_sEncode:string;var f_iMsgType,f_iGID,f_iSubID,f_iPort,f_iBuzz:integer;var f_sData : string);
var tsData : tstrings;
begin
  try
    tsdata:=tstringlist.create;
    try
      G_convertEncodeStringToTstrings(f_sEncode,tsData);
      if tsData.Count<>6 then raise Exception.create('Data Count Error');
      f_iMsgType:=strtoint(tsData[0]);
      f_iGID:=strtoint(tsData[1]);
      f_iSubID:=strtoint(tsData[2]);
      f_iPort:=strtoint(tsData[3]);
      f_iBuzz:=strtoint(tsData[4]);
      f_sData:=tsData[5];
    finally
      tsData.free;
    end;
  except
    on E:Exception do raise Exception.create('(G_DriverDecodeDriverCommand)'+e.Message);
  end;
end;

function G_DriverEncodeDriverCommand(f_iMsgType,f_iGID,f_iSubID,f_iPort,f_iBuzz:integer;f_pData:pchar;f_iLen:integer) : string;
var tsData : tstrings;
begin
  result:='';
  try
    tsData:=TStringList.create;
    try
      tsData.Add(inttostr(f_iMsgType));
      tsData.Add(IntToStr(f_iGid));
      tsData.Add(IntToStr(f_iSubID));
      tsData.Add(IntToStr(f_iPort));
      tsData.Add(IntToStr(f_iBuzz));
      tsData.Add(G_convertBufferToStr(f_pData,f_iLen));
      result:=G_convertTstringsToEncodeString(tsData);
    finally
      tsData.free;
    end;
  except
    on E:Exception do raise Exception('(G_EncodeDriverCommand)'+E.Message);
  end;
end;


function G_DriverGetRandomString : string;
var i : integer ;
begin
  try
    setlength(Result,Random(200)+50);
    for i:=1 to length(result) do Result[i]:=char(Random(255));
    Result:=cCheckLegeal+Result;
  except
    on E:Exception do raise Exception.create('()'+E.Message);
  end;
end;


function G_DriverGetFeedBackString(f_sOld : string) : string;
var i : integer;
begin
  result:='';
  try
    if copy(f_sOld,1,length(cCheckLegeal))<>cCheckLegeal then exit;
    Delete(f_sOld,1,length(cCheckLegeal));
    SetLength(Result,length(f_sOld));
    for i:=1 to length(Result) do Result[i]:=char(255-byte(f_sOld[length(f_sOld)-i+1]));
  except
    on E:Exception do raise Exception.create('(G_DriverGetFeedBackString)'+E.Message)
  end;
end;

end.
