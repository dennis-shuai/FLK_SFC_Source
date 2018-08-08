unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, ListView1, Grids, DBGrids, DBGrid1,
  DB, MConnect, ObjBrkr, DBClient, SConnect, GradBtn;

type
  TfMain = class(TForm)
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
    tmr1: TTimer;
    grdbtn1: TGradBtn;
    procedure tmr1Timer(Sender: TObject);
    procedure grdbtn1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function LoadApServer: Boolean;
    procedure  QueryWaitRepair;
    procedure  QueryRepair;
    function  CloseApServer:Boolean;
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}
procedure  TfMain.QueryWaitRepair;
begin
    with QryData1 do
    begin
         Close;
         CommandText :=' select * from (select b.tooling_sn,to_char(a.defect_time,''MM/DD HH24:MI'') '+
                       ' defect_time,c.defect_desc , '+
                       ' round((sysdate-a.defect_time)*24*60,0)||''╓юда'' Wait_min '+
                       ' from sajet.g_Tooling_sn_repair a,sajet.sys_tooling_sn b, '+
                       ' sajet.sys_defect c where a.tooling_sn_id=b.tooling_sn_id and  '+
                       ' a.repair_memo=''Online Repair'' '+
                       ' and a.defect_Time is not null  and a.defect_id=c.defect_id(+)  '+
                       ' and A.START_REPAIR_TIME is null and a.repair_time is null '+
                       ' ) order by Wait_min desc';
         Open;
    end;
end;

procedure  TfMain.QueryRepair;
begin
     with QryData do
     begin
         Close;
         CommandText :='select * from (select b.tooling_sn,to_char(a.defect_time,''MM/DD HH24:MI'') '+
                       ' defect_time , '+
                       ' round((a.start_repair_time-a.defect_time)*24*60,0)||''╓юда'' Wait_min, '+
                       ' round((sysdate-a.start_repair_time)*24*60,0)||''╓юда'' Repair_min , '+
                       ' c.emp_Name,d.defect_desc from sajet.g_Tooling_sn_repair a,sajet.sys_tooling_sn b, '+
                       ' sajet.sys_emp c,sajet.sys_defect d '+
                       ' where a.tooling_sn_id=b.tooling_sn_id and a.REPAIR_USERID=c.emp_id(+) '+
                       ' and a.defect_id=d.defect_id(+) and a.repair_memo=''Online Repair'' '+
                       ' and a.defect_time is not null  '+
                       ' and A.START_REPAIR_TIME is  not null and a.repair_time is null '+
                       ' ) order by Repair_min desc';
         Open;
     end;
end;




function TfMain.CloseApServer:Boolean;
begin

   try
       SocketConnection1.Connected := False;
       SimpleObjectBroker1.Servers.Clear;
       SocketConnection1.Host:='';
       SocketConnection1.Address:='';
       Result := True;
   except
       Result := false;
   end;
end;

function TfMain.LoadApServer: Boolean;
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

procedure TfMain.tmr1Timer(Sender: TObject);
begin
    LoadApServer;
    QueryWaitRepair;
    QueryRepair;
    CloseApServer;
end;

procedure TfMain.grdbtn1Click(Sender: TObject);
begin
   tmr1.OnTimer(Self);
end;

procedure TfMain.FormShow(Sender: TObject);
begin
    tmr1.OnTimer(Self);
end;

end.
