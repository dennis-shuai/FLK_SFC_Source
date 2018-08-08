unit unitHeadDCS;

interface

type
  TPortInfo = record
    iNO : Byte;
    aName : Array[0..19] of Byte;
    iNameLen : Byte;
    iMaxLen : Integer;
    iType : Byte; // 0 : Undefined, 1 : In, 2 : Out, 3 : In & Out
  end;

  TDeviceInfo = record
    aName : Array[0..9] of Byte;
    iNameLen : Byte;
    iDeviceNum : Byte;
    iPortNum   : Byte;
    aPortInfo  : Array[1..20] of TPortInfo;
  end;

const
  cPort_Undefined = 0 ;
  cPort_In=1;
  cPort_out=2;
  cPort_In_out=3;

implementation

end.
