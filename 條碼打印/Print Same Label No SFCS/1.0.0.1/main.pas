unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, MConnect, SConnect, ObjBrkr, StdCtrls, Buttons,
  ExtCtrls ,ComObj;

type
  TForm1 = class(TForm)
    SimpleObjectBroker1: TSimpleObjectBroker;
    SocketConnection1: TSocketConnection;
    QryData: TClientDataSet;
    Label1: TLabel;
    Label3: TLabel;
    edtsn: TEdit;
    Image1: TImage;
    sbtnPrint: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure sbtnPrintClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtsnKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    sFirstWO,sWO ,sBox,sProcess:string;
    sBox_NO :array [1..4] of string;
    BarApp,BarDoc,BarVars:variant;
    i_Count,count:integer;
    isStart,IsOpen:boolean;
    function LoadApServer: Boolean;

  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
function TForm1.LoadApServer: Boolean;
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

procedure TForm1.FormShow(Sender: TObject);
var i:integer;
    PrintFile:string;
begin
    // LoadApServer;
     isStart :=false;
     IsOpen :=false;
     i_Count :=0;
     Count :=0;
     for i:=0 to 4 do begin
        sBox_NO[i] :='';
     end;
     try
        BarApp := CreateOleObject('lppx.Application');
      except
        Application.MessageBox('›]¨S¦³¦w¸Ëcodesoft³nÅé','¿ù»~',MB_OK+MB_ICONERROR);
        isStart:=false;
        Exit;
     end;
     PrintFile:= GetCurrentDir+'\\SN_DEFAULT.Lab';
     IsStart :=true;

     If not FileExists( PrintFile) then
     begin
         MessageDlg( 'Label ÀÉ®×¤£¦s¦b',mterror,[mbOK],0);
         IsOpen :=false;
         Exit;
     end;

     BarApp.Visible:=false;
     BarDoc:=BarApp.ActiveDocument;
     BarVars:=BarDoc.Variables;
     BarDoc.Open(  PrintFile);
     IsOpen :=true;
end;

procedure TForm1.sbtnPrintClick(Sender: TObject);
begin

   if (IsStart) and (IsOpen) then begin
    BarDoc.Variables.Item('SN').Value :=  edtsn.TEXT;
    Bardoc.PrintLabel(1);
    Bardoc.FormFeed;
   end;

end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
   if IsStart  then  begin
      Bardoc.Close;
      BarApp.Quit;
    end;
end;

procedure TForm1.edtsnKeyPress(Sender: TObject; var Key: Char);
begin

  if Key <>#13 then exit;
  {
   if LENGTH(edtSN.Text) <> 10 then begin
      MessageDlg('ªø«×¿ù»~',mterror,[mbok],0);
      edtsn.SelectAll;
      exit;
   end;
   if Copy(edtSN.Text,1,1) <> 'P' then
   begin
       MessageDlg('½s½X­ì«h¿ù»~',mterror,[mbok],0);
       edtsn.SelectAll;
       exit;
   end;
   with qrydata do begin
       close;
       params.clear;
       params.CreateParam(ftstring,'SN',ptInput);
       commandtext :='select * from sajet.g_sn_status where serial_number = :sn or customer_sn =:sn and work_flag=0';
       params.ParamByName('SN').AsString := edtSN.Text;
       Open;

       if Isempty then begin
            MessageDlg('No SN',mterror,[mbok],0);
            edtsn.SelectAll;
            exit;
       end;
   end;
   }
   sbtnPrint.Click;
   edtsn.Clear;
   edtsn.SetFocus;
end;

end.
