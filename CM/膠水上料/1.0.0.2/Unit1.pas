unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, ExtCtrls, Grids, StdCtrls, Buttons,ComObj,IniFiles,Winsock;

type
  TForm1 = class(TForm)
    QryTemp: TClientDataSet;
    ImageAll: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label1: TLabel;
    edtSN: TEdit;
    Sproc: TClientDataSet;
    lblMsg: TLabel;
    lblTerminal: TLabel;
    RadioGroup1: TRadioGroup;
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
    iTerminal:string;
    Function GetTerminalID: string;
    function GetIP: string;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.edtSNKeyPress(Sender: TObject; var Key: Char);
var msg,sProcess,sDefect:String;
begin
   if Key <> #13 then exit;
   if edtSN.Text ='' then exit;
   if RadioGroup1.ItemIndex =0 then begin
       qrytemp.Close;
       qrytemp.Params.clear;
       qrytemp.Params.CreateParam(ftstring,'reel_no',ptinput);
       qrytemp.CommandText :='select * from SAJET.g_Pick_List where material_no =:Reel_no';
       qrytemp.Params.ParamByName('reel_no').AsString := edtSN.Text;
       qrytemp.Open;

       if qrytemp.IsEmpty then begin
          lblMsg.Caption :='該膠水還未發料,請聯繫倉庫';
          lblMsg.Color :=clRed;
          edtSN.Text :='';
          edtSN.SetFocus;
          exit;
       end;
       qrytemp.Close;
       qrytemp.Params.clear;
       qrytemp.Params.CreateParam(ftstring,'reel_no',ptinput);
       qrytemp.Params.CreateParam(ftstring,'USER',ptinput);
       qrytemp.Params.CreateParam(ftstring,'TERMINAL',ptinput);
       qrytemp.CommandText :='Insert into sajet.G_PSN_STATUS(TERMINAL_ID,PART_SN,UPDATE_USERID,UPDATE_TIME)  '+
                             ' VALUES(:TERMINAL,:REEL_NO,:USER,sysdate)';
       qrytemp.Params.ParamByName('reel_no').AsString := edtSN.Text;
       qrytemp.Params.ParamByName('TERMINAL').AsString := iTerminal;
       qrytemp.Params.ParamByName('USER').AsString := UpdateUserID;
       qrytemp.execute;
   end;

   if RadioGroup1.ItemIndex =1 then begin
       qrytemp.Close;
       qrytemp.Params.clear;
       qrytemp.Params.CreateParam(ftstring,'reel_no',ptinput);
       qrytemp.CommandText :='select * from SAJET.G_PSN_STATUS where PART_SN =:Reel_no';
       qrytemp.Params.ParamByName('reel_no').AsString := edtSN.Text;
       qrytemp.Open;

       if qrytemp.IsEmpty then begin
          lblMsg.Caption :='該膠水還未上料';
          lblMsg.Color :=clRed;
          edtSN.Text :='';
          edtSN.SetFocus;
          exit;
       end;
       qrytemp.Close;
       qrytemp.Params.clear;
       qrytemp.Params.CreateParam(ftstring,'reel_no',ptinput);
       qrytemp.Params.CreateParam(ftstring,'USER',ptinput);
       qrytemp.Params.CreateParam(ftstring,'TERMINAL',ptinput);
       qrytemp.CommandText :=' Insert into sajet.G_PSN_TRAVEL Select TERMINAL_ID,to_char(''yyyy/mm/dd HH24:mm:ss'',sysdate), ' +
                             ' Part_SN,Update_USERID,UPDATE_TIME FROM SAJET.G_PSN_STATUS';
       qrytemp.Params.ParamByName('reel_no').AsString := edtSN.Text;
       qrytemp.Params.ParamByName('TERMINAL').AsString := iTerminal;
       qrytemp.Params.ParamByName('USER').AsString := UpdateUserID;
       qrytemp.execute;

       qrytemp.Close;
       qrytemp.Params.clear;
       qrytemp.Params.CreateParam(ftstring,'reel_no',ptinput);
       qrytemp.CommandText :='delete from SAJET.G_PSN_STATUS where PART_SN =:Reel_no';
       qrytemp.Params.ParamByName('reel_no').AsString := edtSN.Text;
       qrytemp.Open;
   end;

   lblMsg.Caption :='OK';
   lblMsg.Color :=clRed;
   edtSN.Text :='';
   edtSN.SetFocus;

end;

function TForm1.GetTerminalID : string;
var
  i,SERVER_ID,Gateway_ID,diviceID:Integer;
  ALLIP,LocalIP,Process_ID,TERMINAL_ID:string;
  strs:TStrings;
  IsExists:Boolean;
begin
     Result:='';

     LocalIP:=getip;
     if LocalIP ='' Then  exit;
     QryTemp.Close;
     QryTemp.Params.Clear;
     QryTemp.CommandText := 'SELECT  a.TERMINAL_ID,a.DEVICE_ID,b.SERVER_ID,b.GATEWAY_ID,SAJET.GET_LONG(b.rowid) IPADDR '
            +' FROM SAJET.TGS_TERMINAL_LINK A,SAJET.TGS_GATEWAY_BASE B '
            +' WHERE A.SERVER_ID =B.SERVER_ID AND A.GATEWAY_ID=B.GATEWAY_ID '
            +' AND (SAJET.GET_LONG(b.rowid) LIKE '+''''+'%;' + LocalIP + ',%'+''''
            + ' or SAJET.GET_LONG(b.rowid) LIKE '+''''+'%,' + LocalIP + ',%'+''''
            + ' or SAJET.GET_LONG(b.rowid) LIKE '+''''+'%,' + LocalIP + ';%'+''''
            + ')' ;

     QryTemp.Open;

     if not QryTemp.Eof then
     begin
        ALLIP:=QryTemp.FieldByName('IPADDR').AsString;
        SERVER_ID:=QryTemp.FieldByName('SERVER_ID').AsInteger;
        GATEWAY_ID:= QryTemp.FieldByName('GATEWAY_ID').AsInteger;
     end else begin
        SERVER_ID:=-1;
        GATEWAY_ID:=-1;
        Exit;
     end;
     strs:=tstringlist.create;
     strs.delimiter:=';' ;
     strs.delimitedText:=ALLIP ;
     ALLIP:=strs[1];
     strs.delimiter:=',' ;
     strs.delimitedText:=ALLIP ;
     for i:=0 to strs.count-1 do
     begin
        if strs[i]=LocalIP then
            diviceID:=i+1;
     end;

     QryTemp.First;
     for i:=0 to QryTemp.RecordCount-1 do
     begin
        if QryTemp.FieldByName('DEVICE_ID').asinteger=diviceID then
        begin
           TERMINAL_ID:= QryTemp.FieldByName('TERMINAL_ID').asstring;
        end;
        QryTemp.Next;
     end;
     if TERMINAL_ID<>'' then
     begin
         //
         QryTemp.Close;
         QryTemp.Params.Clear;
         QryTemp.CommandText := 'select PROCESS_ID from sajet.SYS_TERMINAL '
                              + ' where TERMINAL_ID='+''''+ TERMINAL_ID +'''';
         QryTemp.Open;
         if not QryTemp.Eof then
             Process_ID:=QryTemp.FieldByName('PROCESS_ID').asstring
         else
             Process_ID:='';
        if Process_ID<>'' then
        begin
           Result:= TERMINAL_ID ;
        end;
     end
     else
        Result:='';
end;

function TForm1.GetIP: string;
type
    TaPInAddr = array[0..10] of PInAddr; 
    PaPInAddr = ^TaPInAddr;
var 
    phe: PHostEnt;
    pptr: PaPInAddr;
    Buffer: array[0..63] of Char;
    i: Integer;
    GInitData: TWSAData;
    sResult:TStringList;
    ipCount:Integer;
begin
    Result:='';
    WSAStartup($101, GInitData);
    sResult := TstringList.Create;
    sResult.Clear;
    GetHostName(Buffer, SizeOf(Buffer));
    phe := GetHostByName(buffer);
    if phe = nil then Exit;
    pPtr := PaPInAddr(phe^.h_addr_list);
    i:= 0;
    while pPtr^[i] <> nil do
    begin 
      sResult.Add(inet_ntoa(pptr^[i]^));
      Inc(i); 
    end;
    WSACleanup;
    ipCount:=i;
    for i:=0 to ipCount-1 do
    begin
      //if Copy(sResult[i],1,11)='192.168.80.' then
      if Copy(sResult[i],1,7)='172.16.' then
          Result:= sResult[i];
    end;


end;

procedure TForm1.FormShow(Sender: TObject);
var process_name,terminal_name,Pdline_name:string;
begin
    //iTerminal:='10012326';
    iTerminal:=GetTerminalID;
    if iTerminal='' then begin
       MessageDlg('找不到IP地址',mterror,[mbok],0);
       edtSN.Enabled :=false;
       exit;
    end;
     edtSN.Enabled :=true;
     edtSN.SetFocus;
     Qrytemp.Close;
     Qrytemp.Params.clear;
     Qrytemp.Params.CreateParam(ftstring,'Terminal',ptinput);
     Qrytemp.CommandText :='select a.terminal_name,c.Process_Name,b.PDLINE_NAME '+
                           ' from sajet.sys_terminal a,sajet.sys_pdline b ,sajet.sys_process c'+
                           ' where a.terminal_ID =:Terminal and a.pdline_ID=b.PDLINE_ID'+
                           ' and a.process_ID =c.Process_ID';
     Qrytemp.Params.ParamByName('Terminal').AsString :=iTerminal;
     Qrytemp.Open;

     if Qrytemp.IsEmpty then begin
        MessageDlg('找不到站別,IP配置錯誤',mterror,[mbok],0);
        edtSN.Enabled :=false;
        exit;
     end;
     terminal_name :=Qrytemp.Fieldbyname('terminal_name').AsString;
     Process_name :=Qrytemp.Fieldbyname('Process_name').AsString;
     Pdline_name := Qrytemp.Fieldbyname('Pdline_name').AsString;
     lblTerminal.Caption :='站別:' +  Pdline_name+'\'+ Process_name+'\'+ terminal_name;
     

end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin
   if edtsn.Enabled then
     edtSN.SetFocus;
end;

end.
