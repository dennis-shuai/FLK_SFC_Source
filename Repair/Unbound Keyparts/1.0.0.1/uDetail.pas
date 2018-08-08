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
    procedure FormShow(Sender: TObject);
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID : String;
    Count:Integer;
    UpDate_Time :TDateTime;
    sStartTime, sEndTime, sDStartTime, sDEndTime,sTime1,sTime2 :string;
   
  end;

var
  fDetail: TfDetail;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit;




procedure TfDetail.FormShow(Sender: TObject);
begin
    edtSN.SetFocus;
end;

procedure TfDetail.edtSNKeyPress(Sender: TObject; var Key: Char);
var C_SN:string;
begin
    if Key <>#13 then exit;

    with Qrytemp do begin
       close;
       params.clear;
       Params.CreateParam(ftstring,'SN',ptinput);
       commandtext :=' select * from sajet.g_SN_STATUS where Serial_number=:SN';
       params.ParamByName('SN').AsString := edtSN.Text;
       open;

       if isEmpty then begin
           close;
           params.clear;
           Params.CreateParam(ftstring,'SN',ptinput);
           commandtext :=' select Serial_Number from sajet.g_SN_STATUS where Customer_SN=:SN';
           params.ParamByName('SN').AsString := edtSN.Text;
           open;
           if  isEmpty then begin
                 lblMsg.Color :=clRed;
                 lblMsg.Caption := 'NO SN';
                 edtSN.SelectAll;
                 edtSN.SetFocus;
                 exit;
           end else
               C_SN := fieldbyname('Serial_NUmber').AsString;

       end else
           C_SN:=edtSN.Text;

       close;
       params.clear;
       Params.CreateParam(ftstring,'SN',ptinput);
       commandtext :='update sajet.g_SN_KeyParts set Enabled=''N'' where Serial_number=:SN';
       params.ParamByName('SN').AsString := C_SN;
       Execute;
       
       lblMsg.Color :=clGreen;
       lblMsg.Caption := 'OK';
       edtSN.SelectAll;
       edtSN.SetFocus;
       Label2.Caption := edtSN.text +' Unbond OK';
    end;
end;

end.
