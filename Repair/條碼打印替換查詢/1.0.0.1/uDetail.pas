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
    Label2: TLabel;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    Label3: TLabel;
    Label4: TLabel;
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
           commandtext :=' SELECT A.WORK_ORDER "�u��",A.SERIAL_NUMBER "���X",A.CUSTOMER_SN "�Ȥ���X",A.OLD_SN "�±��X",'+
                         ' A.OLD_CSN "�«Ȥ���X",B.EMP_NO "�u��",B.EMP_NAME "�m�W",A.UPDATE_TIME "�����ɶ�" FROM  SAJET.G_SN_REPLACE A '+
                         ' ,SAJET.SYS_EMP B WHERE (A.SERIAL_NUMBER =:SN OR CUSTOMER_SN =:SN OR OLD_SN=:SN OR OLD_CSN=:SN ) AND A.UPDATE_USER=B.EMP_ID' ;
           params.ParamByName('SN').AsString := edtsn.Text;
           open;
  
    end;

    with QryData do
    begin

       close;
       params.clear;
       Params.CreateParam(ftstring,'SN',ptinput);
       commandtext :='SELECT A.WORK_ORDER "�u��",A.SERIAL_NUMBER "���X" ,B.EMP_NO "�u��" ,B.EMP_NAME "�m�W",A.PRINT_DATE "���L�ɶ�"  FROM '+
                     ' SAJET.G_WO_SN_PRINT A,SAJET.SYS_EMP B WHERE A.SERIAL_NUMBER =:SN AND A.PRINTER=B.EMP_ID' ;
       params.ParamByName('SN').AsString := edtSN.Text;
       open;


    end;

    edtSN.SelectAll;
    edtSN.SetFocus;


end;

end.
