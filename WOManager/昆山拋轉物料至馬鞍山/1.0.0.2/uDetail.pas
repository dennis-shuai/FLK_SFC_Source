unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles, ComCtrls;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    lablType: TLabel;
    Image1: TImage;
    btnTransfer: TSpeedButton;
    lablReel: TLabel;
    Label9: TLabel;
    EditWO: TEdit;
    edtPN: TEdit;
    MainPN: TLabel;
    Image3: TImage;
    edtQty: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    DBGrid1: TDBGrid;
    SProc: TClientDataSet;
    msgpnl: TPanel;
    Label4: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnTransferClick(Sender: TObject);
    procedure EditWOChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    g_wo: string;
    UpdateUserID,sPartID,sPartNo,sQty: string;
    function cleardate:string;

  end;

var
  fDetail: TfDetail;
implementation

{$R *.DFM}
uses uDllform,{ unitDataBase,} DllInit;

function TfDetail.cleardate: string;
begin
  editwo.Clear;
  editwo.SetFocus;
  edtPN.Clear;
  edtQty.Clear;
end;


procedure TfDetail.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  editwo.Clear;
  editwo.SetFocus;
  cleardate;

end;


procedure TfDetail.btnTransferClick(Sender: TObject);
var rbMessage:string;
begin

  with SProc do
  begin
      Close;
      DataRequest('SAJET.CCM_GET_KS_PICKLIST');
      FetchParams;
      Params.ParamByName('TWO').AsString := EditWO.Text;
      Params.ParamByName('TEMPID').AsString :=UpdateUserID;
      Execute;

      rbMessage := Params.ParamByName('TRES').AsString;

       if rbMessage <>'OK' then
           msgpnl.Color :=clRed
       else
           msgpnl.Color :=clGreen;
       msgpnl.Caption :=rbMessage;

       edtPN.Clear;
       edtQty.Clear;
       EditWO.SetFocus;
       exit;


  end;

end;

procedure TfDetail.EditWOChange(Sender: TObject);
begin
    msgpnl.Color :=$00CAE7BC;
    with QryTemp do
    begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
       CommandText := 'select a.model_id,a.target_qty from sajet.G_WO_BASE@mas2ks a  where   A.WORK_ORDER=:WORK_ORDER';
       Params.ParamByName('WORK_ORDER').AsString := EditWO.Text;
       Open;

       if IsEmpty then
       begin
          msgpnl.Color :=clRed;
          msgpnl.Caption :='Not Found WO';
          Exit;
       end;
       sPartID := fieldbyName('model_id').AsString;
       sQty :=   fieldbyName('target_qty').AsString;

       Close;
       Params.Clear;
       Params.CreateParam(ftString, 'part_id', ptInput);
       CommandText := 'select a.part_no,a.part_id from sajet.sys_part@mas2ks a  where a.part_id=:part_id';
       Params.ParamByName('part_id').AsString := sPartID;
       Open;

       sPartNo := fieldbyName('Part_No').AsString;
       edtPN.Text := sPartNo;
       edtQty.Text := sQty;

       Close;
       Params.Clear;
       Params.CreateParam(ftString, 'WO', ptInput);
       CommandText :=  ' select b.work_order,a.part_no,b.request_qty,b.issue_qty,b.SCRAP_QTY,b.AB_ISSUE_QTY,b.AB_RETURN_QTY '+
                       ' from sajet.sys_part@mas2ks a,sajet.g_wo_pick_list@mas2ks b '  +
                       ' where  a.part_id=b.part_id and b.work_order=:WO ';
       Params.ParamByName('WO').AsString := EditWO.Text;
       Open;

       msgpnl.Color :=clYellow;
       msgpnl.Caption :='please continue';

    end;
end;

end.

