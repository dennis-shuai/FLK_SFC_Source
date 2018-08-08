unit UDmWo;

interface

uses
  SysUtils, Classes, DB, ADODB;

type
  TDmWorkOrder = class(TDataModule)
    ADOConnFoxSystemTest: TADOConnection;
    ADOS_GetServDate: TADOStoredProc;
    Ado_SystemTemp: TADOQuery;
    ADOStored_WorkOrder: TADOStoredProc;
    ADOS_JudgeCurrentSNHistory: TADOStoredProc;
    ADOS_JudgeCurrentSNExists: TADOStoredProc;
    ADOS_WriterSnSerialCode: TADOStoredProc;
    ADOS_InsertLink: TADOStoredProc;
    ADOS_OpenLink: TADOStoredProc;
    ADOStored_PackingOrder: TADOStoredProc;
    ADOS_WriterPacking: TADOStoredProc;
    ADOS_CartonNo: TADOStoredProc;
    ADOS_InsertRepair: TADOStoredProc;
    ADOS_JudgeLinkStatus: TADOStoredProc;
    ADOS_JudgeAllLink: TADOStoredProc;
    ADOS_JudgeStatusSQC: TADOStoredProc;
    ADOS_WriterSnHistorySQC: TADOStoredProc;
    ADOS_RejectCartonNo: TADOStoredProc;
    ADOS_ClosePackingWoSwxk: TADOStoredProc;
    ADOS_CloseWorkOrder: TADOStoredProc;
    ADOS_JudgeSNPack: TADOStoredProc;
    ADOS_JudgeSNStatusRepairSMT: TADOStoredProc;
    ADOS_ReplaceSN: TADOStoredProc;
    ADOS_InsertSQC: TADOStoredProc;
    ADOS_CreatTable: TADOStoredProc;
    ADOS_SetTableRole: TADOStoredProc;
    ADOS_JudgeSNStatusRepairAssy: TADOStoredProc;
    ADOS_InsertSnHistoryPcCam: TADOStoredProc;
    ADOS_JudgeCurrentSNStatus: TADOStoredProc;
    ADOS_WriterSnHistory: TADOStoredProc;
    ADOS_InsertRoom: TADOStoredProc;
    ADOS_WriterSnHistoryPcCam: TADOStoredProc;
    ADOS_InsertRouting: TADOStoredProc;
    ADOS_InsertRoutingAll: TADOStoredProc;
    ADOS_JudgeSnOtherTest: TADOStoredProc;
    ADOS_WriterPackingPcCam: TADOStoredProc;
    ADOS_JudgeRepairPcCam: TADOStoredProc;
    ADOS_InsertRepairPcCam: TADOStoredProc;
    ADOS_ReplaceSNPcCam: TADOStoredProc;
    ADOS_WriterReportPcCam: TADOStoredProc;
    ADOS_WriterReportListPcCam: TADOStoredProc;
    ADOS_WriterReportErrorListPcCam: TADOStoredProc;
    ADOS_InsertRoutingFP: TADOStoredProc;
    ADOS_WriterSnHistoryFP: TADOStoredProc;
    ADOS_InsertRepairIn: TADOStoredProc;
    ADOS_InsertRepairFP: TADOStoredProc;
    ADOS_JudgeAllLinkFP: TADOStoredProc;
    ADOS_OpenLinkFP: TADOStoredProc;
    ADOS_SetToNG: TADOStoredProc;
    ADOS_InsertHistoryFP_QQC: TADOStoredProc;
    ADOS_InsertQA: TADOStoredProc;
    ADOS_LastJudgeQA: TADOStoredProc;
    ADOS_InsertSorting: TADOStoredProc;
    ADOS_UpdateSortingStatus: TADOStoredProc;
    ADOS_JudgeRepairTimes: TADOStoredProc;
    ADOS_WriterSnPrint: TADOStoredProc;
    ADOS_WriterLink: TADOStoredProc;
    ADOS_SaveQNum: TADOStoredProc;
    ADOS_InsertHistoryQA: TADOStoredProc;
    ADOS_ChangeBrokenSN: TADOStoredProc;
    ADOS_JudgeCurrentSNStatusRMA: TADOStoredProc;
    ADOS_InsertRoutingRMA: TADOStoredProc;
    ADOS_RejectCartonNoNew: TADOStoredProc;
    ADOS_InsertSortingNew: TADOStoredProc;
    ADOS_JudgeRepairNew: TADOStoredProc;
    ADOS_InsertRepairFpNew: TADOStoredProc;
    ADOS_LastJudgeQANew: TADOStoredProc;
    ADOS_RejectSnPcs: TADOStoredProc;
    ADOS_RejectQANumberQPass: TADOStoredProc;
    ADOS_SaveTestFileNew108: TADOStoredProc;
    ADOS_SaveTestFile108_2: TADOStoredProc;
    ADOS_JudgeSNStatusOQC: TADOStoredProc;
    ADOS_CheckVer: TADOStoredProc;
    ADOS_WriterSnSerialCodeID: TADOStoredProc;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DmWorkOrder: TDmWorkOrder;
  

implementation

{$R *.dfm}

end.
