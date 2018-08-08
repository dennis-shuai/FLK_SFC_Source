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
    lblMsg: TLabel;
    EditCSN: TEdit;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
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
var   iresult:string;
begin
    if Key <>#13 then exit;
    SCSN:=TRIM(editcsn.Text);

    with Qrytemp do begin
       close;
       params.clear;
       Params.CreateParam(ftstring,'CSN',ptinput);
       commandtext :='SELECT A.ITEM_PART_SN,B.SERIAL_NUMBER FROM SAJET.G_SN_KEYPARTS A,'+
                     'SAJET.G_SN_STATUS B WHERE A.SERIAL_NUMBER=B.SERIAL_NUMBER'
                     +' AND B.CUSTOMER_SN=:CSN AND A.PROCESS_ID=''100215''';
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
              editcSN.clear;
              editcSN.setFocus;
              exit;

         END;

        lblMsg.Color :=clGreen;
        lblMsg.Caption := iResult;
        editCSN.Clear;
        editCSN.setFocus;

   END;

    end;



end.
