unit UnitMailSMSTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,ADODB, IdComponent, IdTCPConnection, IdTCPClient,
  IdMessageClient, IdSMTP, IdBaseComponent, IdMessage, DB;

type
  TformMailSMSTest = class(TForm)
    btnSendMail: TButton;
    btnSendSMS: TButton;
    IdSMTP5: TIdSMTP;
    IdMessage6: TIdMessage;
    DBConn: TADOConnection;
    dbCommand: TADOCommand;
    procedure btnSendMailClick(Sender: TObject);
    procedure btnSendSMSClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formMailSMSTest: TformMailSMSTest;

implementation

{$R *.dfm}

procedure TformMailSMSTest.btnSendMailClick(Sender: TObject);
  var sMaileMessage:string;
      attachmentFilePath:string;
begin
  with IdSMTP5 do
    begin
      Host:='192.168.78.201';
      Port:=25;
      //Username:='SFC_KS_CCM_ALERT';
      //Password:='ksccmsfc';
      Username:='Alert';
      Password:='sfcnas';
      AuthenticationType := atLogin;
    end;

     try
      IdSMTP5.Connect;
        with IdMessage6 do
          begin
            Subject:='Alarm Mail (Test)';
            //From.Address:='MES_Sajet@foxlink.com';
            From.Address:='alert@foxlink.com';
             Recipients.Add;
             Recipients[0].Address:='Dennis_Shuai@foxlink.com';
             //Recipients.Add;
             //Recipients[1].Address:='shuaibll03@163.com';
             sMaileMessage:='Alarm Mail Testing(Sample)';
            Body.Clear;
            Body.Add(sMaileMessage);
          end;
        {  attachmentFilePath:='C:\\Documents and Settings\\dennis_shuai\\орн▒\\Maple.xlsx';
          if FileExists(attachmentFilePath) then
            begin
              TIdAttachment.Create(IdMessage6.MessageParts,attachmentFilePath);
            end;
            }
      IdSMTP5.Send(IdMessage6);
    finally
        IdSMTP5.Disconnect;
        IdSMTP5.Free;
    end;
end;

procedure TformMailSMSTest.btnSendSMSClick(Sender: TObject);
  var 
      effectRows:_RecordSet;
      sSQL:string;
begin
   try
    sSQL:='insert into sms_outbox (sismsid, extcode, destaddr, messagecontent, reqdeliveryreport,msgfmt,sendmethod,requesttime,applicationid)'+
          ' VALUES (''64a24682-e267-4564-8e58-6450d74e631e'', ''101'', ''18962661400'', ''test22222222'', 1, 15, 0, now(), ''101'') ' ;
     dbCommand.Connection:= DBConn;
     dbCommand.CommandText:=sSQL;
     effectRows:= dbCommand.Execute;

     if effectRows.MaxRecords=0 then
      begin
        showMessage('Insert Record Sucess.');
      end
      else
        begin
          showMessage('Insert Record Failed.');
        end;
  finally
    dbCommand.Free;
  end;
end;

end.
