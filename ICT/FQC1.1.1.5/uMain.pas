unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls,DateUtils,IniFiles, DB, ADODB,
  ComCtrls, DBClient, MConnect, SConnect, ObjBrkr;

type
  TfMain = class(TForm)
    PLRT1: TPanel;
    connFox: TADOConnection;
    ADOSPROC1: TADOStoredProc;
    stat1: TStatusBar;
    edtSN: TEdit;
    edtERRCODE: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    SimpleObjectBroker1: TSimpleObjectBroker;
    SocketConnection1: TSocketConnection;
    SProc: TClientDataSet;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
    procedure edtERRCODEKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure Createparams(var params :TCreateParams);override;
  public
    { Public declarations }
    sUserID,sDate:string;
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

uses Login;


procedure TfMain.edtSNKeyPress(Sender: TObject; var Key: Char);
var
sn,sresult,serrCode,strResult:string;
sData ,sOrgError,sSendData: string;
iLen,iResult,m: integer;
begin
  if edtSN.Text ='' then Exit;

  if Key=#13 then

      begin

      if edtERRCODE.Text ='' then
         sresult:='PASS'
      else begin
         sresult:='FAIL';
         serrCode:=edtERRCODE.Text;
      end;

        if sResult <>'PASS' then sResult :=sResult+';'+edterrcode.Text;
           sSendData :=fLogin.edtUser.Text+';;'+edtsn.Text+';'+sResult;

           iLen:=Length(sSendData);
           sData :='';

        if iLen<1000 then SetLength(sData,100)
        else SetLength(sData,iLen);

         for m:=1 to iLen do sData[m]:=sSendData[m];

           iResult := SajetTransData(7,@sdata[1],@iLen);
           SetLength(sData,iLen);

            if iResult = 1 then
            begin
                PLRT1.Caption :=  edtSN.Text+sData;
                PLRT1.Color :=  clGreen;
                stat1.SimpleText :=sData;
                stat1.Color :=clGreen;
                edtSN.Clear;
                edtSN.SetFocus;
            end
            else
            begin
                                  
                 if sresult ='PASS' then
                 begin

                      SetLength(sData,iLen);
                      sOrgError :=sData;
                                          
                      sData :='';

                      iLen:=Length(SN);

                      if iLen<1000 then SetLength(sData,100)
                      else SetLength(sData,iLen);

                      for m:=1 to iLen do sData[m]:=sSendData[m];


                      iResult :=  SajetTransData(9,@sdata[1],@iLen);

                      SetLength(sData,iLen);

                      if iResult=1 then
                      begin

                          if sResult <>'PASS' then sResult :=sResult+';'+edterrcode.Text;
                          sSendData :=fLogin.edtUser.Text+';;'+edtSN.Text+';'+sResult;

                          iLen:=Length(sSendData);
                          sData :='';

                           if iLen<1000 then SetLength(sData,100)
                           else SetLength(sData,iLen);

                           for m:=1 to iLen do sData[m]:=sSendData[m];

                          iResult := SajetTransData(7,@sdata[1],@iLen);
                          SetLength(sData,iLen);
                           if iResult =1 then
                           begin
                               edtERRCODE.Clear;
                               edtSN.Clear;
                               edtSN.SetFocus;
                               PLRT1.Caption :=  edtSN.Text+sData;
                               PLRT1.Color :=  clGreen;
                               stat1.SimpleText :=sData;
                               stat1.Color :=clGreen;
                           end else begin
                                edtERRCODE.Clear;
                                edtSN.Clear;
                                edtSN.SetFocus;
                                SetLength(sData,iLen);
                                PLRT1.Caption :=  edtSN.Text+sData;
                                PLRT1.Color :=  clRed;
                                stat1.SimpleText :=sData;
                                stat1.Color :=clRed;
                           end;

                      end else begin
                           // SetLength(sData,iLen);
                            edtERRCODE.Clear;
                            edtSN.Clear;
                            edtSN.SetFocus;
                            PLRT1.Color :=  clRed;
                            PLRT1.Caption :=  edtSN.Text+sOrgError;
                            stat1.SimpleText :=sOrgError;
                            stat1.Color :=clRed;

                      end;
                 end
                 else
                 begin
                     edtERRCODE.Clear;
                     edtSN.Clear;
                     edtSN.SelectAll;
                     edtSN.Clear;
                     edtSN.SetFocus;
                     SetLength(sData,iLen);
                     PLRT1.Caption :=  edtSN.Text+';'+sData;
                     PLRT1.Color :=  clRed;
                     stat1.SimpleText :=sData;
                     stat1.Color :=clRed;
                 end;


            end;
  end;

end;


procedure TfMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   fLogin.Close;
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  edtSN.SetFocus;
end;



procedure TfMain.edtERRCODEKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 THEN
  begin
     edtSN.SetFocus;
     edtSN.SelectAll;
  end;
end;

procedure TfMain.Createparams(var params :TCreateParams);
begin
  inherited;
  params.wndparent :=0;
end;



end.
