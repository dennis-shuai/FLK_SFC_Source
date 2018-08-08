unit uFrmUpdate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, auHTTP, auAutoUpgrader, IniFiles, StrUtils,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP ;

type
  TFormUpdate = class(TForm)
    Panel1: TPanel;
    ProgressBar1: TProgressBar;
    auAutoUpgrader1: TauAutoUpgrader;
    Timer1: TTimer;
    IdHTTP1: TIdHTTP;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure auAutoUpgrader1Progress(Sender: TObject;
      const FileURL: String; FileSize, BytesRead, ElapsedTime,
      EstimatedTimeLeft: Integer; PercentsDone, TotalPercentsDone: Byte;
      TransferRate: Single);
    procedure auAutoUpgrader1NoUpdateAvailable(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure auAutoUpgrader1EndUpgrade(Sender: TObject;
      var RestartImediately: Boolean);
    procedure auAutoUpgrader1FileDone(Sender: TObject;
      const FileName: String);
    procedure auAutoUpgrader1FileStart(Sender: TObject;
      const FileURL: String; FileSize: Integer; const FileTime: TDateTime;
      var CanUpgrade: Boolean);
    procedure auAutoUpgrader1ConnLost(Sender: TObject);
    procedure auAutoUpgrader1HostUnreachable(Sender: TObject; const URL,
      Hostname: String);
    procedure auAutoUpgrader1NoInfoFile(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function  GetVersion(sFile:string): string;
  end;

var
  FormUpdate: TFormUpdate;
  HttpURL : string ;

implementation

uses uFormMain;

{$R *.dfm}

function TFormUpdate.GetVersion(sFile:string):string;
var
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  szName: array[0..255] of Char;
  Value: Pointer;
  Len: UINT;
  TransString:string;
begin
  InfoSize := GetFileVersionInfoSize(PChar(sFile), Wnd);
  if InfoSize <> 0 then
  begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(sFile), Wnd, InfoSize, VerBuf) then
      begin
        Value :=nil;
        VerQueryValue(VerBuf, '\VarFileInfo\Translation', Value, Len);
        if Value <> nil then
           TransString := IntToHex(MakeLong(HiWord(Longint(Value^)), LoWord(Longint(Value^))), 8);
        Result := '';
        StrPCopy(szName, '\StringFileInfo\'+Transstring+'\FileVersion');

        if VerQueryValue(VerBuf, szName, Value, Len) then
           Result := StrPas(PChar(Value));
      end;
    finally
      FreeMem(VerBuf);
    end;
  end;
end;

procedure TFormUpdate.FormShow(Sender: TObject);
begin
  Self.Left := Round((Screen.Width - Self.Width )/2);
  Self.Top := Round((Screen.Height - Self.Height )/2);
  auAutoUpgrader1.CheckUpdate(False);
end;

procedure TFormUpdate.FormCreate(Sender: TObject);
begin
  //Ū���۰ʧ�s�]�m
  with TInifile.Create('.\ini\AutoUpgrade.ini') do
  begin
    HttpURL := ReadString('AutoUpgrade','HttpURL','http://localhost/SFCUpdate/BristolSFC/F3/') ;
    if RightStr(HttpURL,1)<>'/' then HttpURL := HttpURL+'/';
    auAutoUpgrader1.InfoFileURL := HttpURL+'Update.inf';
    auAutoUpgrader1.VersionNumber := GetVersion(Application.ExeName) ;
    Free ;
  end;
  SetWindowPos(Handle , HWND_TOPMOST ,0 ,0 ,0 ,0 ,
                       SWP_NOSIZE + SWP_NOMOVE + SWP_SHOWWINDOW) ;
end;

procedure TFormUpdate.auAutoUpgrader1Progress(Sender: TObject;
  const FileURL: String; FileSize, BytesRead, ElapsedTime,
  EstimatedTimeLeft: Integer; PercentsDone, TotalPercentsDone: Byte;
  TransferRate: Single);
begin
  Panel1.Caption := '��󥿦b��s��,�еy��...';
  ProgressBar1.Position := PercentsDone;
  Sleep(5);
end;

procedure TFormUpdate.auAutoUpgrader1NoUpdateAvailable(Sender: TObject);
begin
  Self.Close ;
end;

procedure TFormUpdate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := False ;
  ModalResult := mrOK;
  Action := caFree;
  FormUpdate := nil;
end;

procedure TFormUpdate.Timer1Timer(Sender: TObject);
begin
  Sleep(FormMain.TimeInterval);
  auAutoUpgrader1.CheckUpdate(False);
  Timer1.Enabled := False ;
end;

procedure TFormUpdate.auAutoUpgrader1EndUpgrade(Sender: TObject;
  var RestartImediately: Boolean);
var
  MsgStr : string;
  UpdateMsgInfo : string;
begin
  Panel1.Caption := '�{�ǧ�s����!';
  UpdateMsgInfo := IdHTTP1.Get(HttpURL+'readme.txt') ;   //���o��s����
  IdHTTP1.Disconnect ;                                   //�_�}�s��
  MsgStr := '�{�ǧ�s����!'+#13#10+#13#10+
            UpdateMsgInfo +
            #13#10+#13#10+'�I��<�T�w>��{�ǱN���s�}��!';
  MessageBox(0,PChar(MsgStr),'���ɴ���(Kindly Reminder)',MB_SYSTEMMODAL + MB_ICONQUESTION + MB_OK);
end;

procedure TFormUpdate.auAutoUpgrader1FileDone(Sender: TObject;
  const FileName: String);
begin
  Panel1.Caption :='�{�Ƕ}�l��s!';
end;

procedure TFormUpdate.auAutoUpgrader1FileStart(Sender: TObject;
  const FileURL: String; FileSize: Integer; const FileTime: TDateTime;
  var CanUpgrade: Boolean);
begin
  Panel1.Caption := '�˴���s�����ݭn��s!';
end;

procedure TFormUpdate.auAutoUpgrader1ConnLost(Sender: TObject);
begin
  Panel1.Caption :='�{�ǧ�s����,���pôTE�B�z!';
  ShowMessage('�{�ǧ�s����,���pôTE�B�z!');
  Self.Close ;
end;

procedure TFormUpdate.auAutoUpgrader1HostUnreachable(Sender: TObject;
  const URL, Hostname: String);
var
  MsgStr : string;
begin
  Panel1.Caption :='HostUnreachable';
  MsgStr := '�s���A�Ⱦ�'+Hostname+'����!'+
            #13#10#13#10+'���ˬd�]�m�O�_�����T!';
  MessageBox(0,PChar(MsgStr),'�s�����~(Error)',MB_SYSTEMMODAL + MB_ICONERROR + MB_OK);
  Close ;
  Application.Terminate ;
end;

procedure TFormUpdate.auAutoUpgrader1NoInfoFile(Sender: TObject);
begin
  Panel1.Caption :='�L�k�b���A�������ɯŪ�������T!';
  MessageBox(0,PChar('�L�k�b���A�������ɯŪ�������T!'),'���~����',
             MB_SYSTEMMODAL + MB_ICONERROR + MB_OK);
  Close;
  Application.Terminate ;  
end;

end.
