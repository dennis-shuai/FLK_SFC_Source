unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, MConnect, ObjBrkr, SConnect;

type
  TuMainForm = class(TForm)
    SocketConnection1: TSocketConnection;
    SimpleObjectBroker1: TSimpleObjectBroker;
    QryTemp: TClientDataSet;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function LoadApServer : Boolean;
  end;

var
  uMainForm: TuMainForm;

implementation

{$R *.dfm}

function TuMainForm.LoadApServer : Boolean;
var
  F : TextFile;
  S : String;
begin
  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  If not FileExists(GetCurrentDir+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,GetCurrentDir+'\ApServer.cfg');
  Reset(F);
  While True do
  begin
    Readln(F, S);
    If S <> '' Then
    begin
      SimpleObjectBroker1.Servers.Add;
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
    end Else
      Break;
  end;
  CloseFile(F);
  Result := True;
end;

procedure TuMainForm.FormShow(Sender: TObject);
var SID,SN:string;
    F: TextFile; S: string;
    ihandle:integer;
begin
    AssignFile(F, GetCurrentDir+'\Module NO.txt');
    If not FileExists(GetCurrentDir+'\Module NO.txt') Then begin
       Rewrite(F);
       WriteLn(F,'沒有產生SID 文件' );
       CloseFile(F);
    end else begin
      LoadApServer;
      Reset(F);
      Readln(F,S);
      SID:=S;
      CloseFile(F);
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftstring,'SID',ptInput);
      QryTemp.CommandText :='Select Serial_Number FROM SAJET.G_SN_KEYPARTS WHERE ITEM_PART_SN =:SID AND ENABLED =''Y'' ';
      QryTemp.Params.ParamByName('SID').AsString := SID ;
      QryTemp.Open;
      IF QryTemp.ISEMPTY  then BEGIN
           Rewrite(F);
           WriteLn(F,'沒有找到Sensor ID('+SID+') ,請重新測試AOO' );
           CloseFile(F);
           QryTemp.Close;

      END else  begin

      SN :=QryTemp.FieldbyName('Serial_Number').AsString;
      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftstring,'SN',ptInput);
      QryTemp.CommandText :='Select DECODE(CUSTOMER_SN,''N/A'',SERIAL_NUMBER,CUSTOMER_SN) SN FROM SAJET.G_SN_STATUS WHERE SERIAL_NUMBER = :SN ';
      QryTemp.Params.ParamByName('SN').AsString := SN ;
      QryTemp.Open;
      SN :=  QryTemp.FieldbyName('SN').AsString;

      Rewrite(F);
      WriteLn(F,'OK;'+SN);
      CloseFile(F);
      QryTemp.Close;
      end;
    end;
    Application.Terminate;
end;

end.
