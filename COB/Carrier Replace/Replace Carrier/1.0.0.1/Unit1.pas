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
    edtNewCar: TEdit;
    Label2: TLabel;
    DBGrid1: TDBGrid;
    edtOldCar: TEdit;
    lblMsg: TLabel;
    lblTerminal: TLabel;
    procedure FormShow(Sender: TObject);
    procedure edtOldCarKeyPress(Sender: TObject; var Key: Char);
    procedure edtNewCarKeyPress(Sender: TObject; var Key: Char);
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
    Sproc.DataRequest('SAJET.SJ_CKRT_CARRIER_REPLACE') ;
    Sproc.FetchParams;
    Sproc.Params.ParamByName('TERMINALID').AsString :=G_sTerminalID;
    Sproc.Params.ParamByName('TREV').AsString :=edtOldCar.Text;
    Sproc.Execute;

    msg := Sproc.Params.ParamByName('TRES').AsString  ;

    if msg <> 'OK'  then
    begin
       lblMsg.Caption  := msg;
       edtOldCar.Clear;
       edtNewCar.ReadOnly :=true;
       lblMsg.Color :=clRed;
       exit;
    end;

    Sproc.Close;
    Sproc.DataRequest('SAJET.SJ_CKRT_Carrier ') ;
    Sproc.FetchParams;
    Sproc.Params.ParamByName('TERMINALID').AsString :=G_sTerminalID;
    Sproc.Params.ParamByName('TREV').AsString :=edtOldCar.Text;
    Sproc.Execute;

    msg := Sproc.Params.ParamByName('TRES').AsString  ;
    
    if Copy(msg,1,2) <> 'OK'  then
    begin
       lblMsg.Caption  := msg;
       edtOldCar.Clear;
       edtNewCar.ReadOnly :=true;
       lblMsg.Color :=clRed;
       exit;
    end;

    edtNewCar.ReadOnly :=false;
    edtNewCar.SetFocus;
end;

procedure TForm1.edtNewCarKeyPress(Sender: TObject; var Key: Char);
var msg:string;
begin
    if Key <> #13 then exit;
    if  edtNewCar.Text = '' then exit;
   {
    if Length(edtNewCar.Text) <> 4 then begin
       lblMsg.Caption  := 'Error Carrier Length';
       edtNewCar.Clear;
       edtNewCar.SetFocus ;
       lblMsg.Color :=clRed;
       exit;
    end;
    }
    Sproc.Close;
    Sproc.DataRequest('SAJET.SJ_COB_CKRT_NEW_CARRIER') ;
    Sproc.FetchParams;
    Sproc.Params.ParamByName('TREV').AsString :=edtOldCar.Text;
    Sproc.Execute;

    msg := Sproc.Params.ParamByName('TRES').AsString  ;

    if msg <> 'OK'  then
    begin
       lblMsg.Caption  := msg;
       edtOldCar.Clear;
       edtNewCar.ReadOnly :=true;
       lblMsg.Color :=clRed;
       exit;
    end;

    Sproc.Close;
    Sproc.DataRequest('SAJET.SJ_Carrier_Replace') ;
    Sproc.FetchParams;
    Sproc.Params.ParamByName('TTERMINALID').AsString :=G_sTerminalID ;
    //Sproc.Params.ParamByName('TLINEID').AsString :='';
    Sproc.Params.ParamByName('TEMPID').AsString :=UpdateUserID;
    Sproc.Params.ParamByName('TOLD_CARRIER').AsString :=edtOldCar.Text;
    Sproc.Params.ParamByName('TREV').AsString :=edtNewCar.Text;
    //Sproc.Params.ParamByName('TNOW').AsString :=edtOldCar.Text;
   // Sproc.Params.ParamByName('TEMPID').AsString :='';
    Sproc.Execute;

    msg := Sproc.Params.ParamByName('TRES').AsString  ;

    if msg <> 'OK'  then
    begin
       lblMsg.Caption  := msg;
       edtNewCar.Clear;
       edtNewCar.SetFocus ;
       lblMsg.Color :=clRed;
       exit;
    end;
    {
    Sproc.Close;
    Sproc.DataRequest('SAJET.SJ_PANEL_GO2') ;
    Sproc.FetchParams;
    Sproc.Params.ParamByName('TTERMINALID').AsString :=G_sTerminalID ;  // --trev ,  tdefect, tnow , temp  , tres   , tnextproc
    Sproc.Params.ParamByName('trev').AsString :=edtNewCar.Text ;
    Sproc.Params.ParamByName('tdefect').AsString :='N/A' ;
    Sproc.Params.ParamByName('tnow').AsDateTime  := GetSystemDate ;
    Sproc.Params.ParamByName('temp').AsString  :=UpdateUserID ;
    Sproc.Execute;


    msg := Sproc.Params.ParamByName('TRES').AsString  ;
    }
    if UpperCase(msg) <> 'OK'  then
     begin
       lblMsg.Caption  := msg;
       edtNewCar.Clear;
       edtNewCar.SetFocus ;
       lblMsg.Color :=clRed;
       exit;
    end;


    QryData.Close;
    QryData.Params.Clear;
    QryData.Params.CreateParam(ftString,'BOX_NO',ptInput);
    QryData.CommandText := 'SELECT WORK_ORDER,SERIAL_NUMBER ,BOX_NO FROM SAJET.G_SN_STATUS '
                        +  ' WHERE BOX_NO=:BOX_NO';
    QryData.Params.ParamByName('BOX_NO').AsString := edtNewCar.Text;
    QryData.Open;

    lblMsg.Caption  := 'Carrier Replace OK';
    lblMsg.Color :=clGreen;
    edtOldCar.Clear;
    edtNewCar.Clear;
    edtOldCar.SetFocus;


end;

end.
