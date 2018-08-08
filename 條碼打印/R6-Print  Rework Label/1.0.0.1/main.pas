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
    qrytemp: TClientDataSet;
    procedure FormShow(Sender: TObject);
    procedure sbtnPrintClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtsnKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    sItemSN,sSN,sPartID,sCSN:string;
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
     LoadApServer;
     isStart :=false;
     IsOpen :=false;
     i_Count :=0;
     Count :=0;
   
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
     BarDoc.Open(PrintFile);
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
var sPartNO,sPrefix:string;
begin
  if Key <>#13 then exit;
   if LENGTH(edtSN.Text) <> 15 then begin
      MessageDlg('ªø«×¿ù»~',mterror,[mbok],0);
      edtsn.SelectAll;
      exit;
   end;
  
   with qrydata do begin
       close;
       params.clear;
       params.CreateParam(ftstring,'SN',ptInput);
       commandtext := ' select * from sajet.g_sn_status where serial_number = :sn '+
                      ' or customer_sn =:sn and work_flag=0';
       params.ParamByName('SN').AsString := edtSN.Text;
       Open;

       if Isempty then begin
            MessageDlg('No SN',mterror,[mbok],0);
            edtsn.SelectAll;
            exit;
       end;
       sPartID := fieldbyname('MODEL_ID').AsString;

       with qrytemp do begin
           close;
           params.clear;
           params.CreateParam(ftstring,'MODEL_ID',ptInput);
           commandtext := ' select * from sajet.sys_part where part_id  = :MODEL_ID ';
           params.ParamByName('MODEL_ID').AsString := sPartID ;
           Open;

           sPartNO := fieldbyname('Part_NO').AsString;
           if Copy(sPartNo,11,4)='0080' then
              sPrefix := 'VRW06B11';
           if Copy(sPartNo,11,4)='0180' then
              sPrefix := 'VRW06A01';
       end;

       if recordCOunt>1 then begin
          first;
          while not eof do begin
               sSN := fieldbyname('serial_number').AsString;
               close;
               params.clear;
               params.CreateParam(ftstring,'SN',ptInput);
               commandtext := ' select * from sajet.g_sn_keyparts where serial_number = :sn  and Length(item_part_SN)=7 ';
               params.ParamByName('SN').AsString := sSN ;
               Open;
               next;
               sItemSN := fieldbyname('ITEM_PART_SN').AsString;
               if sItemSN <> Copy(edtsn.text ,9,5) then begin
                   sCSN := sPrefix + sItemSN;
                   close;
                   params.clear;
                   params.CreateParam(ftstring,'SN',ptInput);
                   params.CreateParam(ftstring,'CSN',ptInput);
                   commandtext := ' UPDATE SAJET.G_SN_STATUS SET CUSTOMER_SN =:CSN     where serial_number = :sn  ';
                   params.ParamByName('SN').AsString :=  sSN;
                   params.ParamByName('CSN').AsString := sCSN;
                   Open;
               end;
           end;

       end else begin

           close;
           params.clear;
           params.CreateParam(ftstring,'SN',ptInput);
           commandtext := ' select * from sajet.g_sn_keyparts where serial_number = :sn  and Length(item_part_SN)=7 ';
           params.ParamByName('SN').AsString := sSN;
           Open;

           if Isempty then begin
                MessageDlg('No Item Part SN',mterror,[mbok],0);
                edtsn.SelectAll;
                exit;
           end;

           sItemSN := fieldbyname('ITEM_PART_SN').AsString;
           sCSN := sPrefix + sItemSN;
           close;
           params.clear;
           params.CreateParam(ftstring,'SN',ptInput);
           params.CreateParam(ftstring,'CSN',ptInput);
           commandtext := 'UPDATE sajet.G_SN_STATUS SET CUSTOMER_SN =:CSN where serial_number = :sn ';
           params.ParamByName('SN').AsString := sSN;
           params.ParamByName('CSN').AsString := sCSN;
           Open;
       end;


   end;
   sbtnPrint.Click;
   edtsn.Clear;
end;

end.
