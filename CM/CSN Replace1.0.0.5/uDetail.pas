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
    EditCSN: TEdit;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
    procedure EditCSNKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID : String;
    C_CSN,C_SN:string;
    Count:Integer;
    UpDate_Time :TDateTime;
    sStartTime, sEndTime, sDStartTime, sDEndTime,sTime1,sTime2 :string;
   
  end;

var
  fDetail: TfDetail;
  mWO,mPartID,mPartNO,mCustPartNO,SCSN:string;


implementation

{$R *.dfm}
uses uDllform,DllInit;




procedure TfDetail.FormShow(Sender: TObject);
begin
    editCSN.SetFocus;
end;

procedure TfDetail.EditCSNKeyPress(Sender: TObject; var Key: Char);
var    IsCSN:integer;
begin
    if Key <>#13 then exit;
    SCSN:=TRIM(editcsn.Text);

    with Qrytemp do begin
       close;
       params.clear;
       Params.CreateParam(ftstring,'CSN',ptinput);
       commandtext :='SELECT A.ITEM_PART_SN,B.SERIAL_NUMBER FROM SAJET.G_SN_KEYPARTS A,'+
                     'SAJET.G_SN_STATUS B WHERE A.SERIAL_NUMBER=B.SERIAL_NUMBER'
                     +' AND B.CUSTOMER_SN=:CSN';
       params.ParamByName('CSN').AsString := sCSN;
       open;

       C_CSN:=Qrytemp.fieldbyname('ITEM_PART_SN').AsString ;//自動貼標機-主板條碼
       C_SN:=Qrytemp.fieldbyname('SERIAL_NUMBER').AsString ;//SMT條碼


       if isEmpty then begin
            lblMsg.Color :=clRed;
            lblMsg.Caption := '客戶條碼未綁定';
            editcSN.SelectAll;
            editcSN.SetFocus;
            exit;
       end;

       lblMsg.Color :=clGreen;
       lblMsg.Caption := '客戶條碼OK';
       edtSN.SelectAll;
       edtSN.SetFocus;

    end;
end;

procedure TfDetail.edtSNKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
    ssSN:integer;
begin
    if Length(SCSN)=0 then exit;

    if Key <>#13 then exit;

    with Qrytemp do begin
       close;
       params.clear;
       Params.CreateParam(ftstring,'SN',ptinput);
       commandtext :='SELECT B.CUSTOMER_SN FROM SAJET.G_SN_KEYPARTS A,SAJET.G_SN_STATUS B '+
                     'WHERE B.SERIAL_NUMBER=A.SERIAL_NUMBER AND A.ITEM_PART_SN=:SN';
       params.ParamByName('SN').AsString := edtSN.Text;
       open;

       if isEmpty then begin
            lblMsg.Color :=clRed;
            lblMsg.Caption := '客戶條碼未綁定';
            edtSN.Clear;
            edtSN.SetFocus;
            exit;
       end
       else if Qrytemp.FieldByName('CUSTOMER_SN').AsString <> SCSN then
               lblMsg.Color :=clRed;
               lblMsg.Caption := 'SN條碼與客戶條碼不匹配';
               edtSN.Clear;
               edtSN.SetFocus;
       end;

   Sproc.Close;
   Sproc.DataRequest('SAJET.CCM_ASSY_REPLACE_CSN');
   SPROC.FetchParams;
   Sproc.Params.ParamByName('TNEWSN').AsString := SCSN;
   Sproc.Params.ParamByName('TOLDSN').AsString :=C_SN;
   Sproc.Params.ParamByName('TCSN').AsString := C_CSN;
   SProc.Params.ParamByName('TEMPID').AsString := UpdateUserID;
   Sproc.Execute;
   iResult :=   Sproc.Params.ParamByName('TRES').AsString;
   IF iResult  <> 'OK' THEN BEGIN
        lblMsg.Color :=clRed;
        lblMsg.Caption := iResult;
        edtSN.clear;
        edtSN.setFocus;
        exit;

   END;

    lblMsg.Color :=clGreen;
    lblMsg.Caption := iResult;
    edtSn.Clear;
    editCSN.Clear;
    editCSN.setFocus;

END;


end.
