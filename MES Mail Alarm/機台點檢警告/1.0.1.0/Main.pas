unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DB, DBClient, MConnect, SConnect, ObjBrkr, ComObj,
  IdComponent, IdTCPConnection, IdTCPClient, IdMessageClient, IdSMTP,
  IdBaseComponent, IdMessage,Excel2000, StdCtrls;

type
  TuMainForm = class(TForm)
    SimpleObjectBroker1: TSimpleObjectBroker;
    SocketConnection1: TSocketConnection;
    Qrytemp: TClientDataSet;
    IdMessage1: TIdMessage;
    IdSMTP1: TIdSMTP;
    SaveDialog1: TSaveDialog;
    QryFail: TClientDataSet;
    QryWarning: TClientDataSet;
    QryDate: TClientDataSet;
    mmo1: TMemo;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
      sFileName,sMonth: string;
      IsFound :boolean;
      function LoadApServer : Boolean;
      function GetSysDate:TDatetime;
      procedure SendMail(attachmentFilePath:string;AddressList:TStringList);
      procedure QueryWarning(QryTemp1:TClientDataset);
      procedure QueryOutOfTime(QryTemp1:TClientDataset);
      function  AddZero(s:string;HopeLength:Integer):String;

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
  If not FileExists(ExtractFilePath(Paramstr(0))+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,ExtractFilePath(Paramstr(0))+'\ApServer.cfg');
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
function TuMainForm.GetSysDate:TDateTime;
begin
    QryDate.Close;
    QryDate.CommandText := 'select SysDate from  dual';
    QryDate.Open;
    result := QryDate.fieldbyname('SYSDate').AsDateTime;
end;

procedure TuMainForm.FormShow(Sender: TObject);
var Addresslist:TStringList;
i:Integer;
//MailPath:string;
begin
     LoadApServer;
     Qrytemp.ProviderName := 'DspQryTemp1';
     QryWarning.ProviderName := 'DspQryTemp1';
     QryFail.ProviderName := 'DspQryTemp1';
     QryDate.ProviderName := 'DspQryTemp1';

     with QryTemp do begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString,'group_desc',ptInput);
         CommandText :=' select a.member_value from '+
                      ' sajet.alarm_job_member a,sajet.alarm_job_member_group b,sajet.alarm_job_member_link c'+
                      '  where a.member_id=c.member_id and b.mgroup_id=c.mgroup_id and b.Mgroup_desc=:group_desc and a.enabled=''Y'' ';
         Params.ParamByName('group_desc').AsString :='CM Calibration';
         Open;
         if not IsEmpty then begin
             Addresslist := TStringList.Create;
             sFileName :='';
             First;
             for i :=0 to recordcount-1 do begin
                 Addresslist.Add(fieldbyName('member_value').AsString);
                 Next;
             end;
             SendMail('',Addresslist);
             Addresslist.Free;
         end;
     end;
     {Addresslist := TStringList.Create;
     Addresslist.Add('Dennis_shuai@Foxlink.com');

     SendMail('',Addresslist);
     Addresslist.Free; }
    Close;
     
end;

procedure TuMainForm.QueryWarning(QryTemp1:TClientDataset);
begin

    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.CommandText := ' SELECT TOOLING_NAME,TOOLING_SN,INTERVAL_DESC,CAL_RESULT,START_TIME FROM ( '+
                            ' SELECT   D.TOOLING_NAME,E.TOOLING_SN ,B.INTERVAL_DESC, A.CAL_RESULT,TO_CHAR(A.START_TIME,''YYYY/MM/DD'') START_TIME, '+
                            ' (A.START_TIME+B.INTERVAL_VALUE-SYSDATE)*24 REST_HOUR,B.WARNING_HOUR '+
                            ' FROM  SAJET.G_CAL_STATUS A,SAJET.SYS_CAL_INTERVAL B,SAJET.SYS_CAL_ITEM C,SAJET.SYS_TOOLING D,' +
                            ' SAJET.SYS_TOOLING_SN E,SAJET.SYS_CAL_SN F,SAJET.SYS_MODEL G WHERE A.SERIAL_NUMBER =F.SERIAL_NUMBER AND '+
                            ' A.INTERVAL_ID =B.INTERVAL_ID AND A.ITEM_ID = C.ITEM_ID AND A.MODEL_ID =G.MODEL_ID AND A.TOOLING_SN_ID=E.TOOLING_SN_ID '+
                            ' AND E.TOOLING_ID=D.TOOLING_ID) WHERE REST_HOUR>0 AND REST_HOUR< WARNING_HOUR AND CAL_RESULT=''PASS''  '+
                            ' GROUP BY TOOLING_NAME,TOOLING_SN,INTERVAL_DESC,CAL_RESULT,START_TIME ORDER BY TOOLING_NAME,TOOLING_SN　 ';
    QryTemp1.Open;

end;

procedure TuMainForm.QueryOutOfTime(QryTemp1:TClientDataset);
begin
    QryTemp1.Close;
    QryTemp1.Params.Clear;
    QryTemp1.CommandText := ' SELECT TOOLING_NAME,TOOLING_SN,INTERVAL_DESC,CAL_RESULT,START_TIME FROM ( '+
                            ' SELECT   D.TOOLING_NAME,E.TOOLING_SN ,B.INTERVAL_DESC, A.CAL_RESULT,'+
                            ' TO_CHAR(A.START_TIME,''YYYY/MM/DD'') START_TIME,'+
                            ' (A.START_TIME+B.INTERVAL_VALUE-SYSDATE)*24 REST_HOUR,B.WARNING_HOUR  '+
                            ' FROM  SAJET.G_CAL_STATUS A,SAJET.SYS_CAL_INTERVAL B,SAJET.SYS_CAL_ITEM C,SAJET.SYS_TOOLING D, '+
                            ' SAJET.SYS_TOOLING_SN E,SAJET.SYS_CAL_SN F,SAJET.SYS_MODEL G WHERE A.SERIAL_NUMBER =F.SERIAL_NUMBER AND '+
                            ' A.INTERVAL_ID =B.INTERVAL_ID AND A.ITEM_ID = C.ITEM_ID AND A.MODEL_ID =G.MODEL_ID AND A.TOOLING_SN_ID=E.TOOLING_SN_ID '+
                            ' AND E.TOOLING_ID=D.TOOLING_ID) WHERE REST_HOUR <0 OR UPPER(CAL_RESULT)=''FAIL'' '+
                            ' GROUP BY  TOOLING_NAME,TOOLING_SN ,INTERVAL_DESC, CAL_RESULT,START_TIME ORDER BY TOOLING_NAME,TOOLING_SN　 ';
    QryTemp1.Open;
end;


procedure TuMainForm.SendMail(attachmentFilePath:string;AddressList:TStringList);
var i,j:integer;
    sMaileMessage,sTooling,sToolingSN,sInterval,sCalResult,sTime:string;
begin
    with  QryTemp do
    begin
        Close;
        Params.Clear;
        CommandText :=' select Host_Name,port,user_Name,trim(sajet.password.decrypt(passwd)) pwd '+
                     ' from sajet.alarm_server_detail where server_id=1 ';
        Open;
        if IsEmpty then exit;
    end;

    IdSMTP1.Host :=  QryTemp.fieldByName('Host_Name').AsString;
    IdSMTP1.Port :=  QryTemp.fieldByName('port').AsInteger;
    IdSMTP1.Username := QryTemp.fieldByName('User_Name').AsString;
    IdSMTP1.Password := QryTemp.fieldByName('pwd').AsString;
    IdSMTP1.AuthenticationType := atLogin;

    QueryWarning(QryWarning);
    QueryOutOfTime(QryFail);
    if QryWarning.IsEmpty and QryFail.IsEmpty then Exit;
    try
        IdSMTP1.Connect;
        with IdMessage1 do
        begin

           Subject:= FormatDateTime('YYYY/MM/DD',GetSysDate-1)+' 機台點檢提醒';
           From.Address:='MES_Sajet@foxlink.com';

           for i :=0 to  AddressList.Count-1 do begin
             Recipients.Add;
             Recipients[i].Address:= AddressList.Strings[i];
           end;
           mmo1.Lines.Add('Dear All:');
           if not  QryWarning.IsEmpty then begin
              mmo1.Lines.Add('  '+FormatDateTime('YYYY/MM/DD',GetSysDate-1 )+' 機台點檢提醒如下:');
              QryWarning.First;
              for j:=0 to QryWarning.RecordCount-1 do begin
                  sTooling := QryWarning.FieldByName('Tooling_Name').AsString;
                  sToolingSN := QryWarning.FieldByName('Tooling_SN').AsString;
                  sInterval := QryWarning.FieldByName('Interval_Desc').AsString;
                  sCalResult := QryWarning.FieldByName('cal_result').AsString;
                  sTime :=   QryWarning.FieldByName('Start_time').AsString;
                  mmo1.Lines.Add( '   '+ format('%-30s',['機台類型:'+sTooling])+
                                   format('%-30s',['機台編號:'+sToolingSN])+
                                   format('%-20s',['點檢間隔:'+sInterval])+
                                   format('%-20s',['點檢時間:'+sTime]));

                  QryWarning.Next;

              end;
              mmo1.Lines.Add('');
              mmo1.Lines.Add('');

           end;

           if not  QryFail.IsEmpty then begin
              mmo1.Lines.Add('  '+FormatDateTime('YYYY/MM/DD',GetSysDate-1 )+' 機台點檢過期如下:');
              QryFail.First;
              for j:=0 to QryFail.RecordCount-1 do begin
                  sTooling := QryFail.FieldByName('Tooling_Name').AsString;
                  sToolingSN := QryFail.FieldByName('Tooling_SN').AsString;
                  sInterval := QryFail.FieldByName('Interval_Desc').AsString;
                  sCalResult := QryFail.FieldByName('cal_result').AsString;
                  sTime :=   QryFail.FieldByName('Start_time').AsString;
                  mmo1.Lines.Add( '   '+ format('%-30s',['機台類型:'+sTooling])+
                                   format('%-30s',['機台編號:'+sToolingSN])+
                                   format('%-20s',['點檢間隔:'+sInterval])+
                                   format('%-20s',['點檢結果:'+sCalResult])+
                                   format('%-20s',['點檢時間:'+sTime])) ;

                  QryFail.Next;
              end;
           end;
           //CharSet := 'UTF-8';
           //ContentType := 'text/html';
           Body.Clear;
           Body.Add( mmo1.Text);
        end;
        attachmentFilePath:=sFileName;
        if FileExists(attachmentFilePath) then
        begin
            TIdAttachment.Create(IdMessage1.MessageParts,attachmentFilePath);
        end;
        IdSMTP1.Send(IdMessage1);
    finally
       IdSMTP1.Disconnect;
       IdSMTP1.Free;
    end;
end;

function TuMainForm.AddZero(s:string;HopeLength:Integer):String;
begin
   Result:=StringReplace(Format('%'+IntToStr(HopeLength)+'s',[s]),' ','0',[rfIgnoreCase,rfReplaceAll]);
end;



end.
