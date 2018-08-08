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
  StdCtrls, DB, clsGlobal, clsDataSet ;

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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Login: TLogin;

implementation

{$R *.DFM}

procedure TLogin.btnDoneClick(Sender: TObject);
var
  lStrID, lStrPW: string;
begin
  ObjGlobal.objUser.uEmpID := '0';
  ObjGlobal.objUser.uEmpNo := '';
  ObjGlobal.objUser.uEmpName := '';
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

  //暫未檢查密碼﹐只要有輸入任何值即可
  lStrID := edtID.text;
  lStrPW := edtPW.Text;

  with ObjDataSet.ObjQryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EMP_NO', ptInput);
    CommandText := 'Select EMP_ID,EMP_NAME,EMP_NO,trim(SAJET.password.decrypt(PASSWD)) PWD '
      + '      ,ENABLED,NVL(TO_CHAR(QUIT_DATE,''yyyy/mm/dd''),''N/A'') QUIT_DATE '
      + '      ,CHANGE_PW_TIME '
      + 'From SAJET.SYS_EMP '
      + 'Where Upper(EMP_NO) = :EMP_NO ';
    Params.ParamByName('EMP_NO').AsString := UpperCase(Trim(edtID.Text));
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
      ObjGlobal.objUser.uEmpID := FieldByName('EMP_ID').AsString;
      ObjGlobal.objUser.uEmpNo := FieldByName('EMP_NO').AsString;
      ObjGlobal.objUser.uEmpName := FieldByName('EMP_NAME').AsString;
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
  end;
  Login.Close ;
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
  if ObjGlobal.objUser.uEmpNo = '' then
    Application.Terminate;
end;

end.

