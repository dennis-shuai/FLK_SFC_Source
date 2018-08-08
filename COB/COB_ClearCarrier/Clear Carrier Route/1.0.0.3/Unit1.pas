unit Unit1;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids;

type
  TForm1 = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    lblLabTitle1: TLabel;
    lblLabTitle2: TLabel;
    DataSource1: TDataSource;
    SaveDialog1: TSaveDialog;
    Label1: TLabel;
    edtOldCar: TEdit;
    lblMsg: TLabel;
    lblTerminal: TLabel;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure edtOldCarKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID : String;
    Count:Integer;
    function GetSystemDate(): TDateTime;

  end;

var
  Form1: TForm1;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit;

function TForm1.GetSystemDate(): TDateTime;
begin
     QryTemp.Close;
     QryTemp.Params.Clear();
     QryTemp.CommandText := 'Select sysdate tnow from dual' ;
     QryTemp.Open;

    result := QryTemp.FieldByName('tnow').AsDateTime;


end;


procedure TForm1.FormShow(Sender: TObject);
var iniFile :TIniFile   ;
begin
    edtOldCar.SetFocus;
    
    iniFile :=TIniFile.Create('SAJET.ini');
    G_sTerminalID :=iniFile.ReadString('COB','Terminal','N/A' );
    iniFile.Free;

    //G_sTerminalID := '10012762';

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Terminal_ID',ptInput);
    QryTemp.CommandText := 'select  b.PDLINE_NAME||''\''||a.Terminal_Name as Terminal ,a.Process_ID,b.PDLINE_ID ,a.Stage_ID from '+
                           ' SAJET.SYS_TERMINAL a,SAJET.SYS_PDLINE b where A.PDLINE_ID =B.PDLINE_ID' +
                           '  and Terminal_ID=  :Terminal_ID and a.Enabled=''Y'' ';
    QryTemp.Params.ParamByName('Terminal_ID').AsString := G_sTerminalID;
    QryTemp.Open;

    lblTerminal.Caption := QryTemp.fieldByName('Terminal').AsString ;

end;

procedure TForm1.edtOldCarKeyPress(Sender: TObject; var Key: Char);
var Msg:string;
begin

    if Key <> #13 then exit;
    if  edtOldCar.Text = '' then exit;
    Sproc.Close;
    Sproc.DataRequest('SAJET.CCM_CLEAR_CARRIER_GO') ;
    Sproc.FetchParams;
    Sproc.Params.ParamByName('TTERMINALID').AsString :=G_sTerminalID;
    Sproc.Params.ParamByName('TEMPID').AsString :=UpdateUserID;
    Sproc.Params.ParamByName('TCARRIER').AsString :=edtOldCar.Text;
    Sproc.Execute;

    msg := Sproc.Params.ParamByName('TRES').AsString  ;

    if msg <> 'OK'  then
    begin
       lblMsg.Caption  := msg;
       edtOldCar.Clear;
       lblMsg.Color :=clRed;
       exit;
    end;


    lblMsg.Caption  := 'Carrier Clear OK';
    edtOldCar.Clear;
    lblMsg.Color :=clGreen;
    edtOldCar.SetFocus;

    
end;

end.