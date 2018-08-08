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
    lbl1: TLabel;
    lbl2: TLabel;
    cmbPdline: TComboBox;
    cmbTerminal: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure edtOldCarKeyPress(Sender: TObject; var Key: Char);
    procedure cmbPdlineSelect(Sender: TObject);
    procedure cmbTerminalSelect(Sender: TObject);
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
begin
    edtOldCar.SetFocus;
    cmbPdline.Style := csDropDownList;
    cmbTerminal.Style :=csDropDownList;
    {
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Terminal_ID',ptInput);
    QryTemp.CommandText := 'select pdline_name SAJET.SYS_PDLINE  where  a.Enabled=''Y'' ';
    QryTemp.Params.ParamByName('Terminal_ID').AsString := G_sTerminalID;
    QryTemp.Open;
    }

end;

procedure TForm1.edtOldCarKeyPress(Sender: TObject; var Key: Char);
var Msg:string;
begin
    if Key <> #13 then exit;
    if  cmbPdline.Text = '' then exit;
    if  cmbTerminal.Text = '' then exit;
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
        edtOldCar.SetFocus;
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
        edtOldCar.SetFocus;
        lblMsg.Color :=clRed;
        exit;
    end;

    Sproc.Close;
    Sproc.DataRequest('SAJET.SJ_PANEL_GO2') ;
    Sproc.FetchParams;
    Sproc.Params.ParamByName('TTERMINALID').AsString :=G_sTerminalID ;  // --trev ,  tdefect, tnow , temp  , tres   , tnextproc
    Sproc.Params.ParamByName('trev').AsString :=edtOldCar.Text ;
    Sproc.Params.ParamByName('tdefect').AsString :='N/A' ;
    Sproc.Params.ParamByName('tnow').AsDateTime  := GetSystemDate ;
    Sproc.Params.ParamByName('temp').AsString  :=UpdateUserID ;
    Sproc.Execute;

    msg := Sproc.Params.ParamByName('TRES').AsString  ;

    lblMsg.Caption  := msg;
    edtOldCar.Clear;
    edtOldCar.SetFocus;
    if Copy(msg,1,2) <> 'OK'  then
       lblMsg.Color :=clRed
    else
       lblMsg.Color :=clGreen;

end;

procedure TForm1.cmbPdlineSelect(Sender: TObject);
var i:Integer;
begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'PDLine_Name',ptInput);
    QryTemp.CommandText := 'select a.Terminal_Name  from '+
                           ' SAJET.SYS_TERMINAL a,SAJET.SYS_PDLINE b,sajet.sys_process c where A.PDLINE_ID =B.PDLINE_ID' +
                           '  and b.Pdline_Name =:PDLine_Name  and a.Enabled=''Y'' and b.Enabled=''Y'' '+
                           '  and (a.Terminal_Name like ''%Bake%'' or a.Terminal_Name like ''%Plasma%'' '+
                           '  or a.Terminal_Name like ''%DIE BOND-%''  or a.Terminal_Name like ''%WB%'''+
                           '  or a.Terminal_Name like ''%MOUNT%'') and a.process_id=c.process_id and '+
                           '  c.enabled= ''Y'' order by c.process_code,a.terminal_name ';
    QryTemp.Params.ParamByName('PDLine_Name').AsString := cmbPdline.Text;
    QryTemp.Open;

    cmbTerminal.Clear;
    QryTemp.First;
    for i:=0 to QryTemp.RecordCount-1 do begin
       cmbTerminal.Items.Add(QryTemp.fieldByName('Terminal_Name').AsString);
       QryTemp.Next;
    end;

end;

procedure TForm1.cmbTerminalSelect(Sender: TObject);
begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'PDLine_Name',ptInput);
    QryTemp.Params.CreateParam(ftString,'Terminal_Name',ptInput);
    QryTemp.CommandText := 'select a.Terminal_Name,b.pdline_id,a.terminal_id,a.process_id  from '+
                           ' SAJET.SYS_TERMINAL a,SAJET.SYS_PDLINE b  where A.PDLINE_ID =B.PDLINE_ID' +
                           '  and b.Pdline_Name =:PDLine_Name  and a.Enabled=''Y'' and b.Enabled=''Y'' '+
                           '  and  a.Terminal_Name =:Terminal_Name ';
    QryTemp.Params.ParamByName('PDLine_Name').AsString := cmbPdline.Text;
    QryTemp.Params.ParamByName('Terminal_Name').AsString := cmbTerminal.Text;
    QryTemp.Open;

    if QryTemp.IsEmpty then begin
       MessageDlg('No Station',mtError,[mbOK],0);
       edtOldCar.Enabled :=false;
       Exit;
    end;

    G_sPDLineID :=QryTemp.fieldByName('PDLINE_ID').AsString;
    G_sTerminalID :=QryTemp.fieldByName('TERMINAL_ID').AsString;
    G_sProcessID := QryTemp.fieldByName('Process_ID').AsString;
    edtOldCar.Enabled:=True;
    edtOldCar.SetFocus;
end;

end.
