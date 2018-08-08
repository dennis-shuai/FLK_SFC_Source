{******************************************************************************}
{  Unit description:                                                           }
{  Developer:                        Date:                                     }
{  Modifier:  CGY                    Date:      2002/3/8                       }
{  Modifier:  Kevin                  Date:      2003/2/26                      }
{         Copyright(C)  SCM , All right reserved                               }
{******************************************************************************}
unit frmLogin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ADODB, clsGlobal ;

type
  TLogin = class(TForm)
    edtID: TEdit;
    edtPW: TEdit;
    btnDone: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure btnDoneClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure edtIDEnter(Sender: TObject);
    procedure edtIDKeyPress(Sender: TObject; var Key: Char);
    procedure edtPWKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    ObjQryTemp: TADOQuery;
  public
    { Public declarations }
    function SetStatusbyAuthority: Boolean;
  end;

var
  Login: TLogin;
  PRG : string = 'BlobFile Upload';
  FUN : string = 'Execute' ;

implementation

{$R *.DFM}
uses uMainForm ;

procedure TLogin.btnDoneClick(Sender: TObject);
{var
  lStrID, lStrPW: string;}
begin
  ObjGlobal.objUser.FID := '0';
  ObjGlobal.objUser.FName := '';
  ObjGlobal.objUser.FDesc := '';
  if Trim(edtID.text) = '' then
  begin
    MessageDlg('請輸入使用者編號!', mtInformation, [mbOK], 0);
    edtID.SetFocus;
    Exit;
  end;
  
  if Trim(edtPW.text) = '' then
  begin
    MessageDlg('請輸入密碼!', mtInformation, [mbOK], 0);
    edtID.SetFocus;
    edtID.SelectAll ;
    Exit;
  end;
  sLogIn := SetStatusbyAuthority ;
  if not sLogIn then
  begin
    Abort ;
  end;
  
  {//暫未檢查密碼﹐只要有輸入任何值即可
  lStrID := edtID.text;
  lStrPW := edtPW.Text;

  with ObjQryTemp do
  begin
    Close;
    Parameters.Clear;
    SQL.Clear ;
    SQL.Text := 'Select EMP_ID,EMP_NAME,EMP_NO,trim(SAJET.password.decrypt(PASSWD)) PWD '
      + '      ,ENABLED,NVL(TO_CHAR(QUIT_DATE,''yyyy/mm/dd''),''N/A'') QUIT_DATE '
      + '      ,CHANGE_PW_TIME '
      + 'From SAJET.SYS_EMP '
      + 'Where Upper(EMP_NO) = :EMP_NO ';
    Parameters.ParamByName('EMP_NO').Value := UpperCase(Trim(edtID.Text));
    Open;
    if not IsEmpty then
    begin
      // 檢查 PWD
      if Trim(edtPW.Text) <> Fieldbyname('PWD').AsString then
      begin
        Close;
        edtPW.Text := '';
        MessageDlg('Invalid Password!!', mtError, [mbOK], 0);
        Exit;
      end;
      // 檢查是否已離職
      if (trim(Fieldbyname('QUIT_DATE').AsString) <> 'N/A') then
      begin
        Close;
        edtPW.Text := '';
        edtID.SetFocus;
        edtID.SelectAll;
        MessageDlg('This User have Terminate!!', mtError, [mbOK], 0);
        Exit;
      end;
      // 檢查是否有效
      if (Copy(Fieldbyname('ENABLED').AsString, 1, 1) <> 'Y') then
      begin
        Close;
        edtPW.Text := '';
        edtID.SetFocus;
        edtID.SelectAll;
        MessageDlg('User invalid !!', mtError, [mbOK], 0);
        Exit;
      end;
      ObjGlobal.objUser.FID := FieldByName('EMP_ID').AsString;
      ObjGlobal.objUser.FName := FieldByName('EMP_NO').AsString;
      ObjGlobal.objUser.FDesc := FieldByName('EMP_NAME').AsString; 
    end
    else
    begin
      edtPW.Text := '';
      edtID.SetFocus;
      edtID.SelectAll;
      MessageDlg('Login User Not Found !!', mtError, [mbOK], 0);
      Exit;
    end;
    Close ;
  end;}
  Login.Close ;
  ModalResult := mrOK;
end;

procedure TLogin.btnCancelClick(Sender: TObject);
begin
  Close ;
end;

procedure TLogin.edtIDEnter(Sender: TObject);
begin
  SelectNext(ActiveControl, true, true);
end;

procedure TLogin.edtIDKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then edtPW.SetFocus;
end;

procedure TLogin.edtPWKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then btnDoneClick(Sender);
end;

procedure TLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  Login := nil ;
  ObjQryTemp.Close ;
  ObjQryTemp.Destroy ;
  if ObjGlobal.objUser.FName  = '' then
    Application.Terminate;
end;

procedure TLogin.FormCreate(Sender: TObject);
begin
  ObjQryTemp := TADOQuery.Create(nil);
  ObjQryTemp.Connection := objGlobal.objDataConnect.ObjConnection;
end;

function TLogin.SetStatusbyAuthority: Boolean;
var sAuth,UserID : string;
begin
  Result := False;
  with ObjQryTemp do
  begin
    Close;
    Parameters.Clear;
    SQL.Clear ;
    sql.Text := 'Select EMP_ID,EMP_NAME,EMP_NO,trim(SAJET.password.decrypt(PASSWD)) PWD '
      + '      ,ENABLED,NVL(TO_CHAR(QUIT_DATE,''yyyy/mm/dd''),''N/A'') QUIT_DATE '
      + '      ,CHANGE_PW_TIME '
      + 'From SAJET.SYS_EMP '
      + 'Where Upper(EMP_NO) = :EMP_NO ';
    Parameters.ParamByName('EMP_NO').Value := UpperCase(Trim(edtID.Text));
    Open;
    if not IsEmpty then
    begin
      // 檢查 PWD
      if Trim(edtPW.Text) <> Fieldbyname('PWD').AsString then
      begin
        Close;
        edtPw.Text := '';
        MessageDlg('Invalid Password!!', mtError, [mbCancel], 0);
        Exit;
      end;
      // 檢查是否已離職
      if (trim(Fieldbyname('QUIT_DATE').AsString) <> 'N/A') then
      begin
        Close;
        edtPW.Text := '';
        edtID.SetFocus;
        edtID.SelectAll;
        MessageDlg('This User have Terminate!!', mtError, [mbCancel], 0);
        Exit;
      end;
      // 檢查是否有效
      if (Copy(Fieldbyname('ENABLED').AsString, 1, 1) <> 'Y') then
      begin
        Close;
        edtPW.Text := '';
        edtID.SetFocus;
        edtID.SelectAll;
        MessageDlg('User invalid !!', mtError, [mbCancel], 0);
        Exit;
      end;
      ObjGlobal.objUser.FID := FieldByName('EMP_ID').AsString;
      ObjGlobal.objUser.FName := FieldByName('EMP_NO').AsString;
      ObjGlobal.objUser.FDesc := FieldByName('EMP_NAME').AsString; 

      UserID := Fieldbyname('EMP_ID').AsString;
      Close;
      Parameters.Clear;
      SQL.Clear ;
      SQL.Text := 'Select AUTHORITYS '
        + 'From SAJET.SYS_EMP_PRIVILEGE '
        + 'Where EMP_ID = :EMP_ID '
        + 'and PROGRAM = :PRG '
        + 'and FUNCTION = :FUN ';
      Parameters.ParamByName('EMP_ID').Value := UserID;
      Parameters.ParamByName('PRG').Value := PRG ;
      Parameters.ParamByName('FUN').Value := FUN ;
      Open;
      while not Eof do
      begin
        sAuth := Fieldbyname('AUTHORITYS').AsString;
        Result := (sAuth = 'Allow To Execute') or (sAuth = 'Full Control');
        if Result then
          break;
        Next;
      end;
      Close;
      if not Result then
      begin
        with ObjQryTemp do
        begin
          Close;
          Parameters.Clear;
          SQL.Clear ;
          SQL.Text := 'Select AUTHORITYS '
            + 'From SAJET.SYS_ROLE_PRIVILEGE A, '
            + 'SAJET.SYS_ROLE_EMP B '
            + 'Where A.ROLE_ID = B.ROLE_ID '
            + 'and b.EMP_ID = :EMP_ID '
            + 'and PROGRAM = :PRG '
            + 'and FUNCTION = :FUN ';
          Parameters.ParamByName('EMP_ID').Value := UserID;
          Parameters.ParamByName('PRG').Value := PRG ;
          Parameters.ParamByName('FUN').Value := FUN ;
          Open;
          while not Eof do
          begin
            sAuth := Fieldbyname('AUTHORITYS').AsString;
            Result := (sAuth = 'Allow To Execute') or (sAuth = 'Full Control');
            if Result then
              break;
            Next;
          end;
          Close;
        end;
      end;
      if not Result then
      begin
        MessageDlg('Privilege NG!!', mtError, [mbCancel], 0);
        edtPW.Text := '';
        edtID.SetFocus;
        edtID.SelectAll;
      end;
    end else
      MessageDlg('Login User Not Found !!', mtError, [mbCancel], 0);
  end;
end;

end.

