unit uDetail;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids,DateUtils;

type
  TfDetail = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    lblLabTitle1: TLabel;
    lblLabTitle2: TLabel;
    sbtnQuery: TSpeedButton;
    ImageSample: TImage;
    sBtnExport: TSpeedButton;
    Image1: TImage;
    DataSource1: TDataSource;
    SaveDialog1: TSaveDialog;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    Label1: TLabel;
    edtWO: TEdit;
    DBGrid1: TDBGrid;
    SocketConnection1: TSocketConnection;
    procedure edtWOKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnQueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID:string;

  end;

var
  fDetail: TfDetail;

implementation

{$R *.dfm}
uses uDllform,DllInit,uDataDetail;





procedure TfDetail.edtWOKeyPress(Sender: TObject; var Key: Char);
begin
   if Key <> #13 then exit;
   sbtnQuery.Click;
end;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
begin
   QryData.Close;
   QryData.Params.Clear;
   QryData.Params.CreateParam( ftstring,'WO',ptInput);
   QryData.CommandText :='   SELECT AAA.WORK_ORDER,AAA.PROCESS_NAME,AAA.INPUT_QTY,AAA.OUTPUT_QTY,AAA.REPAIR_PASS,AAA.WIP_QTY FROM (  '  +
                        ' select BB.WORK_ORDER,CC.PROCESS_NAME,BB.INPUT_QTY,BB.OUTPUT_QTY,BB.REPAIR_PASS,NVL(AA.WIP_QTY,0) WIP_QTY from (  '+
                         ' select WORK_ORDER ,WIP_PROCESS,SUM(WIP_QTY) WIP_QTY from sajet.g_SN_STATUS where work_order =:WO  '+
                         ' group by work_order,WIP_PROCESS ) AA,                                                           '+
                         ' (select WORK_ORDER,PROCESS_ID,SUM(PASS_QTY+FAIL_QTY) INPUT_QTY,SUM(PASS_QTY) FIRST_PASS,SUM(OUTPUT_QTY) OUTPUT_QTY,SUM(REPAIR_QTY) REPAIR_PASS '+
                         ' from sajet.G_SN_COUNT where work_order =:WO GROUP BY WORK_ORDER,PROCESS_ID) BB, '+
                         ' sajet.sys_process cc                                                         '+
                         ' where   bb.Process_ID   = cc.PROCESS_ID and aa.WIP_PROCESS(+)  = bb.PROCESS_ID '+
                         ' union                                                                 '+
                         '   Select a1.WORK_ORDER ,a1.process_name,a1.Input_qty,a1.Output_qty,0 OUTPUT_QTY ,NVL(b1.WIP_QTY,0) WIP_QTY from ( '+
                         ' select a.WORK_ORDER ,b.PROCESS_NAME,SUM(TRANS_QTY) INPUT_QTY ,0 OUTPUT_QTY from SAJET.CM_TO_COB_REPAIR_COUNT a,sajet.sys_process b '+
                         ' where a.work_order =:WO and A.REPAIR_PROCESS =B.PROCESS_ID group by a.WORK_ORDER ,b.PROCESS_NAME ) a1, '+
                         ' (select a.WORK_ORDER,B.PROCESS_NAME ,SUM(A.WIP_QTY) WIP_QTY from sajet.g_SN_STATUS a,sajet.sys_process b where a.WIP_PROCESS =b.PROCESS_ID '+
                         ' and a.WORK_ORDER=:WO  group by a.work_order,b.Process_name) B1 where a1.process_name =b1.Process_name(+)  )AAA,'+
                         ' ( '+
                         '  select  a.Process_NAMe,b.Seq from sajet.sys_Process a ,sajet.sys_ROUTE_DETAIL b,sajet.G_WO_BASE C where A.PROCESS_ID =B.PROCESS_ID'+
                         '  and b.RESULT =0 and b.seq=b.step and c.WORK_ORDER=:WO and c.ROUTE_ID=B.ROUTE_ID) BBB '+
                         ' where aaa.Process_NAME =bbb.PROCESS_NAME(+) order by bbb.seq';
   QryData.Params.ParamByName('WO').AsString := edtWO.Text;
   QryData.Open;

end;

procedure TfDetail.sBtnExportClick(Sender: TObject);
var i,j:integer;
pStr:string;
F:TextFile;
begin
   if QryData.IsEmpty then exit;
   if SaveDialog1.Execute then begin
      AssignFile(F,SaveDialog1.FileName+'.csv');
      ReWrite(F);
      QryData.first;

      for j:=0 to QryData.FieldCount-1 do begin
            pstr := pstr+QryData.Fields.Fields[j].FieldName+',';
      end;
      WriteLn(F,pStr);

      for i:=0 to QryData.RecordCount-1 do
      begin
         pstr :='';
         for j:=0 to QryData.FieldCount-1 do begin
            pstr := pstr+QryData.Fields.Fields[j].AsString+',';
         end;
         //pstr :=pStr+#13;
         WriteLn(F,pStr);
         QryData.Next;

      end;
      CloseFile(F);
   end;



end;

procedure TfDetail.DBGrid1DblClick(Sender: TObject);
var smWO,sProcess:string;
begin

   if QryData.Active =false then exit;
   sprocess := QryData.fieldbyname('Process_Name').AsString;
   smWO := QryData.fieldbyname('WORK_ORDER').AsString;
   with TfDataDetail.Create(Self) do
   begin
    GradPanel1.Caption := 'Detail Data';
    GPRecords.Caption := QryData.FieldByName('WIP_Qty').AsString;
    QuryDataDetail.RemoteServer := QryData.RemoteServer;
    QuryDataDetail.Close;
    QuryDataDetail.Params.Clear;
    QuryDataDetail.Params.CreateParam(ftString,'Process',ptInput);
     QuryDataDetail.Params.CreateParam(ftString,'WO',ptInput);
    QuryDataDetail.CommandText := 'SELECT WORK_ORDER ,SERIAL_NUMBER "SERIAL NUMBER",A.CUSTOMER_SN,B.PROCESS_NAME,A.OUT_PROCESS_TIME,'+
                             'A.OUT_PDLINE_TIME ,A.BOX_NO,A.CARTON_NO,A.PALLET_NO,A.QC_NO,A.REWORK_NO,A.WIP_QTY '+
                             'FROM SAJET.G_SN_STATUS A ,SAJET.SYS_PROCESS B ' +
                             ' WHERE  A.WORK_ORDER =:WO AND A.WIP_PROCESS=B.PROCESS_ID AND B.PROCESS_NAME =:PROCESS';
    QuryDataDetail.params.ParamByName('Process').AsString :=sProcess;
    QuryDataDetail.params.ParamByName('WO').AsString :=smWO;
    QuryDataDetail.Open;
    Showmodal;
    Free;
  end;
end;

end.
