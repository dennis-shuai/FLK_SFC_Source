unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MConnect, ObjBrkr, DB, DBClient, SConnect, StdCtrls,IniFiles;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    cmbTerminal: TComboBox;
    Label3: TLabel;
    edtCarrier: TEdit;
    Label4: TLabel;
    procedure edtCarrierKeyPress(Sender: TObject; var Key: Char);
    procedure cmbTerminalSelect(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    sTerminalList:TStringList;
    prefix:String;
    sysDate:TDateTime;

  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
uses uLogin;


procedure TForm1.edtCarrierKeyPress(Sender: TObject; var Key: Char);
var sTerminalID,sCarrier:String;
begin
    if Key <> #13 then exit;
    if cmbTerminal.ItemIndex < 0 then begin
       MessageBox(0,'請選擇機台','提示',MB_ICONERROR);
       exit;
    end;

    Login.QryData.Close;
    Login.QryData.Params.Clear;
    Login.QryData.CommandText :='select sysdate   from dual ';
    Login.QryData.Open;

    sysDate:= Login.QryData.Fields.Fields[0].AsDateTime;

    Login.QryData.Close;
    Login.QryData.Params.Clear;
    Login.QryData.Params.CreateParam(ftstring,'Terminal',ptinput);
    Login.QryData.CommandText :='select TERMINAL_ID from sajet.SYS_TERMINAL where TERMINAL_NAME =:Terminal ';
    Login.QryData.Params.ParamByName('Terminal').AsString :=   Prefix +cmbTerminal.Text;
    Login.QryData.Open;

    sCarrier :=edtCarrier.Text;

    if Login.QryData.IsEmpty then
    begin
         MessageBox(0,'站別資料設置錯誤','錯誤',MB_ICONERROR);
         exit;
    end;
    sTerminalID := Login.QryData.fieldbyName('TERMINAL_ID').AsString;
    {
    if Copy(sCarrier,1,1)='2' then begin
         Login.QryData.Close;
         Login.QryData.Params.Clear;
         Login.QryData.Params.CreateParam(ftstring,'Carrier',ptinput);
         Login.QryData.CommandText :='select BOX_NO  FROM SAJET.G_SN_STATUS where CARTON_NO =:Carrier ';
         Login.QryData.Params.ParamByName('Carrier').AsString :=   edtCarrier.Text;
         Login.QryData.Open;

         if  Login.QryData.Isempty then exit;
         sCarrier :=  Login.QryData.fieldByname('Box_NO').AsString;

    end;
    }
    Login.Sproc.Close;
    Login.Sproc.DataRequest('SAJET.SJ_SMT_CKRT_PANEL');
    Login.SPROC.FetchParams;
    Login.Sproc.Params.ParamByName('TERMINALID').AsString := sTerminalID;
    Login.Sproc.Params.ParamByName('TREV').AsString := sCarrier;
    Login.Sproc.Execute;

    Label4.Caption := Login.Sproc.Params.ParamByName('TRES').AsString;


    if Copy(Login.Sproc.Params.ParamByName('TRES').AsString ,1,2) <> 'OK'  then begin
            Label4.Color :=clRed;
            edtCarrier.Clear;
            edtCarrier.SetFocus;
            exit;
    end else
            Label4.Color :=clGreen;

    Login.Sproc.Close;
    Login.Sproc.DataRequest('SAJET.SJ_PANEL_GO2');
    Login.SPROC.FetchParams;
    Login.Sproc.Params.ParamByName('tterminalid').AsString := sTerminalID;
    Login.Sproc.Params.ParamByName('TREV').AsString := sCarrier;
    Login.Sproc.Params.ParamByName('tdefect').AsString := 'N/A';
    Login.Sproc.Params.ParamByName('tnow').AsDateTime :=sysDate;
    Login.Sproc.Params.ParamByName('temp').AsString :=login.Edit1.Text;
    Login.SPROC.Execute;

    Label4.Caption := Login.Sproc.Params.ParamByName('TRES').AsString;
    if Copy(Login.Sproc.Params.ParamByName('TRES').AsString ,1,2) <> 'OK'  then begin
        Label4.Color :=clRed;
        edtCarrier.Clear;
        edtCarrier.SetFocus;
        exit;
    end else
        Label4.Color :=clGreen;

    edtCarrier.Clear;
    edtCarrier.SetFocus;

end;

procedure TForm1.cmbTerminalSelect(Sender: TObject);
begin
    edtCarrier.SetFocus;
end;

procedure TForm1.FormShow(Sender: TObject);
var iniFile:TIniFile;
     terminalCount,i:integer;
begin

    iniFile := TIniFile.Create('.\HM_bak.ini');
    terminalCount := iniFile.ReadInteger('Settings','Count',0);
    sTerminalList := TStringList.Create;

    for i:=1 to terminalCount  do begin
        sTerminalList.Add(iniFile.ReadString('Settings','Terminal'+IntToStr(i),''));
        cmbTerminal.Items.Add(iniFile.ReadString('Settings','Terminal'+IntToStr(i),'')) ;
    end;
    Label1.Caption :=iniFile.ReadString('Settings' ,'Title','');


    prefix :=  iniFile.ReadString('Settings' ,'prefix','');

    Label2.Caption :=  prefix+' 機台';

    //Form1.Caption :=   prefix +'補掃' ;

    iniFile.Free;



end;



procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     Application.Terminate;
end;

end.
