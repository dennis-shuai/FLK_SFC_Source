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
    Label1: TLabel;
    edtSN: TEdit;
    lblMsg: TLabel;
    Label2: TLabel;
    ds1: TDataSource;
    dbgrd1: TDBGrid;
    edtKP: TEdit;
    lblNewKeyparts: TLabel;
    lbl1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
    procedure edtKPKeyPress(Sender: TObject; var Key: Char);
    procedure ds1DataChange(Sender: TObject; Field: TField);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,sSN,sWO:string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.dfm}
uses uDllform,DllInit;




procedure TfDetail.FormShow(Sender: TObject);
begin
    edtSN.SetFocus;
end;

procedure TfDetail.edtSNKeyPress(Sender: TObject; var Key: Char);
begin
    if Key <>#13 then exit;

    with Qrytemp do
    begin

       close;
       params.clear;
       Params.CreateParam(ftstring,'SN',ptinput);
       commandtext :=' select work_order,serial_number from sajet.g_sn_status where Serial_number=:SN or Customer_sn =:SN';
       params.ParamByName('SN').AsString := edtSN.Text;
       open;

       if IsEmpty then begin
          lblMsg.Caption :='NO SN';
          lblMsg.Color :=clRed;
          Exit;

       end;
       sWO := fieldByName('work_order').AsString;
       sSN := fieldByName('serial_Number').AsString;

    end;

    with QryData do
    begin

       close;
       params.clear;
       Params.CreateParam(ftstring,'SN',ptinput);
       commandtext := ' select b.part_no,a.item_part_sn,b.part_id,c.process_name,b.spec1,c.Process_code, '+
                      ' a.item_group,c.Process_Id,a.enabled from sajet.g_sn_keyparts a, '+
                      ' sajet.sys_part b,sajet.sys_process c where a.item_part_id =b.part_id and  '+
                      ' a.process_id=c.Process_id and a.serial_number =:sn order by  c.process_code,a.item_group ';
       params.ParamByName('SN').AsString := sSN;
       open;
       
    end;
    
end;

procedure TfDetail.edtKPKeyPress(Sender: TObject; var Key: Char);
var sOld_sn,sPartID,sProcessID,sItemGroup,iResult:string;
begin
    if Key <> #13 then Exit;
    if QryData.IsEmpty or (not QryData.Active) then Exit;
    sOld_sn := QryData.fieldByName('ITEM_PART_SN').AsString;
    sPartID := QryData.fieldByName('PART_ID').AsString;
    sProcessID := QryData.fieldByName('Process_ID').AsString;
    sItemGroup :=  QryData.fieldByName('ITEM_GROUP').AsString;

    with SProc do
    begin
        Close;
        DataRequest('SAJET.CCM_REPLACE_KEYPARTS');
        FetchParams;
        Params.ParamByName('TSN').AsString := edtSN.Text;
        Params.ParamByName('TOLDKP').AsString := sOld_sn;
        Params.ParamByName('TNEWKP').AsString := edtKP.Text;
        Params.ParamByName('TPROCESSID').AsString := sProcessID;
        Params.ParamByName('TPARTID').AsString := sPartID;
        Params.ParamByName('TWO').AsString := sWO;
        Params.ParamByName('TITEM_GROUP').AsString := sItemGroup;
        Params.ParamByName('TEMPID').AsString := UpdateUserID;
        Execute;
        iResult := Params.paramByName('TRES').AsString;

        if iResult <>'OK' then
        begin
          lblMsg.Caption := iResult;
          lblMsg.Color:= clRed;
          edtKP.SetFocus;
          edtKP.Clear;
          Exit;
        end;
    end;

     lblMsg.Caption := iResult;
     lblMsg.Color:= clGreen;
     edtSN.SetFocus;
     edtKP.Clear;
     edtSN.Clear;


end;

procedure TfDetail.ds1DataChange(Sender: TObject; Field: TField);
begin
  lbl1.Caption :=' Selected Keyparts:'+QryData.fieldByName('ITEM_PART_SN').AsString;
end;

end.
