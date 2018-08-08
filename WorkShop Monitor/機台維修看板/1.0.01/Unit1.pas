unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, ListView1, Grids, DBGrids, DBGrid1,
  DB, MConnect, ObjBrkr, DBClient, SConnect;

type
  TForm1 = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    dbgrd: TDBGrid1;
    dbgrd11: TDBGrid1;
    QryData: TClientDataSet;
    QryData1: TClientDataSet;
    SocketConnection1: TSocketConnection;
    SimpleObjectBroker1: TSimpleObjectBroker;
    ds1: TDataSource;
    ds2: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
    function LoadApServer: Boolean;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


function TuMainForm.LoadApServer: Boolean;
var F: TextFile;
   S: string;
begin
   Result := False;
   SocketConnection1.Connected := False;
   SimpleObjectBroker1.Servers.Clear;
   SocketConnection1.Host:='';
   SocketConnection1.Address:='';
   if  FileExists(GetCurrentDir + '\ApServer.cfg') then
     AssignFile(F, GetCurrentDir + '\ApServer.cfg')
   else
     exit;
   Reset(F);
   while True do
   begin
      Readln(F, S);
      if trim(S) <> '' then
      begin
        SimpleObjectBroker1.Servers.Add;
        SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
        SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
      end else
        Break;
   end;
   CloseFile(F);
   Result := True;
end;

end.
