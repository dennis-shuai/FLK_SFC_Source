unit uDetail;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids,DateUtils;

type
  TfDetail = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    lblLabTitle1: TLabel;
    lblLabTitle2: TLabel;
    Label1: TLabel;
    edtSN: TEdit;
    lblMsg: TLabel;
    Label3: TLabel;
    edtNewSN: TEdit;
    procedure FormShow(Sender: TObject);
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
    procedure edtNewSNKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID : String;
    Count:Integer;
    UpDate_Time :TDateTime;
    sStartTime, sEndTime, sDStartTime, sDEndTime,sTime1,sTime2 :string;
    //Authoritys,AuthorityRole : String;
    //gbAuth:Boolean;
    //procedure SetStatusbyAuthority;
  end;

var
  fDetail: TfDetail;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit;

{
procedure TfDetail.SetStatusbyAuthority;
begin
    // Read Only,Allow To Change,Full Control
    Authoritys := '';
    gbAuth := False;
    with QryTemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'EMP_ID', ptInput);
        Params.CreateParam(ftString, 'PRG', ptInput);
        Params.CreateParam(ftString, 'FUN', ptInput);
        CommandText := 'Select AUTHORITYS ' +
          'From SAJET.SYS_EMP_PRIVILEGE ' +
          'Where EMP_ID = :EMP_ID and ' +
          'PROGRAM = :PRG and ' +
          'FUNCTION = :FUN ';
        Params.ParamByName('EMP_ID').AsString := UpdateUserID;
        Params.ParamByName('PRG').AsString := 'Repair';
        Params.ParamByName('FUN').AsString := '´À´«±ø½X';
        Open;

        while not Eof do
        begin
            Authoritys := Fieldbyname('AUTHORITYS').AsString;
            gbAuth := (Authoritys = 'Allow To Execute') or (Authoritys = 'Full Control');

            if gbAuth then
              break;
            Next;
        end;

        Close;
    end;

    // sbtnRelease.Enabled := (Authoritys = 'Allow To Execute') or (Authoritys = 'Full Control');
    if not gbAuth then
    begin
        AuthorityRole := '';
        with QryTemp do
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'EMP_ID', ptInput);
          Params.CreateParam(ftString, 'PRG', ptInput);
          Params.CreateParam(ftString, 'FUN', ptInput);
          CommandText := 'Select AUTHORITYS ' +
            'From SAJET.SYS_ROLE_PRIVILEGE A, ' +
            'SAJET.SYS_ROLE_EMP B ' +
            'Where A.ROLE_ID = B.ROLE_ID and ' +
            'EMP_ID = :EMP_ID and ' +
            'PROGRAM = :PRG and ' +
            'FUNCTION = :FUN ';
          Params.ParamByName('EMP_ID').AsString := UpdateUserID;
          Params.ParamByName('PRG').AsString := 'Repair';
          Params.ParamByName('FUN').AsString := '´À´«±ø½X';
          Open;
          while not Eof do
          begin
            AuthorityRole := Fieldbyname('AUTHORITYS').AsString;
            gbAuth := (AuthorityRole = 'Allow To Execute') or (AuthorityRole = 'Full Control');
            if gbAuth then
              break;
            Next;
          end;
          Close;
        end;
    end;
end;
}

procedure TfDetail.FormShow(Sender: TObject);
begin
    edtSN.SetFocus;
end;

procedure TfDetail.edtSNKeyPress(Sender: TObject; var Key: Char);
var C_SN:string;
    IsSN:integer;
begin
    if Key <>#13 then exit;

    with Qrytemp do
    begin
       close;
       params.clear;
       Params.CreateParam(ftstring,'SN',ptinput);
       commandtext :=' select * from sajet.g_SN_STATUS where Serial_number=:SN';
       params.ParamByName('SN').AsString := edtSN.Text;
       open;

       if isEmpty then begin
           close;
           params.clear;
           Params.CreateParam(ftstring,'SN',ptinput);
           commandtext :=' select Serial_Number from sajet.g_SN_STATUS where Customer_SN=:SN';
           params.ParamByName('SN').AsString := edtSN.Text;
           open;
           if  isEmpty then begin
                 lblMsg.Color :=clRed;
                 lblMsg.Caption := 'NO SN';
                 edtSN.SelectAll;
                 edtSN.SetFocus;
                 exit;
           end ;
       end;

       lblMsg.Color :=clGreen;
       lblMsg.Caption := 'ÂÂ±ø½XOK';
       edtNewSN.SelectAll;
       edtNewSN.SetFocus;
    end;
end;

procedure TfDetail.edtNewSNKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
   if Key<>#13 then exit;
   if Length(EdtNewSN.Text)=0 then exit;
   sproc.Close;
   sproc.DataRequest('SAJET.CCM_ASSY_REPLACE_SN2');
   sproc.FetchParams;
   sproc.Params.ParamByName('TNEWSN').AsString := edtNewSN.Text;
   sproc.Params.ParamByName('TOLDSN').AsString := edtSN.Text;
   sproc.Params.ParamByName('TEMPID').AsString := UpdateUserID;
   sproc.Execute;
   iResult :=   sproc.Params.ParamByName('TRES').AsString;
   IF iResult  <> 'OK' THEN BEGIN
        lblMsg.Color :=clRed;
        lblMsg.Caption := iResult;
        edtNewSN.clear;
        edtNewSN.setFocus;
        exit;

   END;

   lblMsg.Color :=clGreen;
   lblMsg.Caption := iResult;
   edtNewSN.clear;
   edtSn.Clear;
   edtSN.setFocus;


end;

end.
