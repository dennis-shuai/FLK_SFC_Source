unit unitHeadSajet;

interface

uses forms,extctrls,SConnect;

type
  { TOnTransDataToApplication�إߦb�D�{�����A���ݥ�client dll�Ǩӭn�B�z�����
    TOnTransData�O��o����ơA�p�G�B�z�����ݭn�^�Ǹ�ƮɡA�ҩI�s���ǰefunction }
  TOnTransData=procedure (f_pData:pchar;f_iLen:integer) of object;
  TOnTransDataToApplication=procedure (f_pData:pchar;f_iLen:integer;f_onTransData : TOnTransData) of object;
  TInitSajetDll=procedure(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection;providerQuery,providerSproc:string);stdcall;
  TInitSajetParamDll=procedure(SenderOwner : TForm; SenderParent : TPanel; ParentApplication : TApplication; UserID : String;parentSocketConnection : TSocketConnection;providerQuery,providerSproc,gsParam:string);stdcall;
  TAssignCBFunction=procedure(f_onTransData: TOnTransDataToApplication);stdcall;
  TCloseSajetDll=procedure ; stdcall;


implementation

end.
