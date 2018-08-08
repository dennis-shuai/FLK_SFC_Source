unit unitHeadSajet;

interface

uses forms,extctrls,SConnect;

type
  { TOnTransDataToApplication建立在主程式中，等待由client dll傳來要處理的資料
    TOnTransData是當這筆資料，如果處理完有需要回傳資料時，所呼叫的傳送function }
  TOnTransData=procedure (f_pData:pchar;f_iLen:integer) of object;
  TOnTransDataToApplication=procedure (f_pData:pchar;f_iLen:integer;f_onTransData : TOnTransData) of object;
  TInitSajetDll=procedure(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection;providerQuery,providerSproc:string);stdcall;
  TInitSajetParamDll=procedure(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection;providerQuery,providerSproc,gsParam:string);stdcall;
  TAssignCBFunction=procedure(f_onTransData: TOnTransDataToApplication);stdcall;
  TCloseSajetDll=procedure ; stdcall;


implementation

end.
