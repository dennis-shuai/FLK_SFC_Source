unit uFormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ADODB, DB, ExtCtrls, StdCtrls, Buttons, RzStatus, IniFiles,
  clsGlobal, clsDataSet, MidasLib, ShellAPI ;

var
  ModelName,PrintType,LabelType : string;    //,Part_ID,Part_No
  mWO, mPartID, mPartNo : string;  // , gSNWo, gSN
  uEmpID ,uEmpNo ,uEmpName : string ;

const
  VerInfo = '5.3.0.4 (Build 20120703)';

type
  TFormMain = class(TForm)
    Label10: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    EditWorkOrder: TEdit;
    BitBtn1: TBitBtn;
    EditBatch: TEdit;
    chkRetailLabel: TCheckBox;
    chkMinglePack: TCheckBox;
    RzVersionInfo: TRzVersionInfo;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EditWorkOrderKeyPress(Sender: TObject; var Key: Char);
    procedure chkRetailLabelClick(Sender: TObject);
    procedure chkMinglePackClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    //function CheckProgVersion : Boolean ;
    procedure CheckProgVersion(var TRES : string) ;
    //procedure ConnectToDB(out TRES : string );
    procedure ShowActiveWindow(THandle :HWND);
  public
    { Public declarations }
    //ModelName,PrintType,Part_No : string;

    //�A�Ⱦ��s�� �j�w�ܶq
    ServerName,DatabaseName : string;
    ForceUpgrade : Boolean ;   //�O�_�j���s
    TimeInterval : Integer ;   //���ݧ�s�ɶ�
  end;

var
  FormMain: TFormMain;

implementation

uses uFormWeight, uFormPrinterSelect , uFrmUpdate, frmLogin, uFormPrint;

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  if not DirectoryExists('.\ini') then MkDir('.\ini');
  if not FileExists('.\ini\AutoUpgrade.ini') then
  begin
    with TInifile.Create('.\ini\AutoUpgrade.ini') do
    begin
      WriteString('AutoUpgrade','HttpURL','http://localhost/SFCUpdate/BristolSFC/F3/') ;
      WriteBool('AutoUpgrade','ForceUpgrade',True);
      WriteInteger('AutoUpgrade','TimeInterval',200) ;
      Free ;
    end;
  end ;

  //Ū���۰ʧ�s�]�m
  with TInifile.Create('.\ini\AutoUpgrade.ini') do
  begin
    ForceUpgrade := ReadBool('AutoUpgrade','ForceUpgrade',True);
    TimeInterval := ReadInteger('AutoUpgrade','TimeInterval',200) ;
    Free ;
  end;
  objGlobal := TGlobal.Create;
  ObjDataSet := TClDataSet.Create ;

  if Login <> nil then
  begin
    Login.Close ;
    FreeAndNil(Login);
  end;
  Login := TLogin.Create(nil);
  Login.ShowModal ;
  {ShellExecute(Handle,'Open',PChar(ExtractFilePath(Application.ExeName)+
                 'LabelDocApply.exe'),'LabelPrint',nil,SW_HIDE) ;}    
end;

procedure TFormMain.BitBtn1Click(Sender: TObject);
begin
  if EditWorkOrder.Text = '' then
  begin
    MessageDlg('WO Number can not be empty !!',mtError ,[mbOK],0);
    EditWorkOrder.Enabled := true ;
    EditWorkOrder.SetFocus ;
    EditWorkOrder.SelectAll ;
    Exit ;
  end;
  if EditBatch.Text = '' then
  begin
    MessageDlg('WO Number Batch can not be empty !!',mtError ,[mbOK],0);
    EditBatch.Enabled := true ;
    EditBatch.SetFocus ;
    EditBatch.SelectAll ;
    Exit ;
  end;

  if chkRetailLabel.Checked then
  begin
    LabelType := 'RETAIL';
    PrintType := 'Retail_Label'
  end
  else if chkMinglePack.Checked then
  begin
    LabelType := 'MINGLE';
    PrintType := 'Mingle_Pack'
  end
  else
  begin
    LabelType := 'SHIPPER';
    PrintType := 'Shipper_Pack';
  end;

  with TIniFile.Create(ExtractFilePath(Application.ExeName)+'MainForm.ini')  do
  begin
    WriteBool('Print','RetailLabel',chkRetailLabel.Checked);
    Free ;
  end;

  {with TFormPrinterSelect.Create(Self) do
  begin
    Show ;
    Self.Hide ;
  end;}

  FormPrint := TFormPrint.Create(Self);
  FormPrint.Show ;
  if chkMinglePack.Checked then
  begin
    FormPrint.tsErie.Show();
    FormPrint.tsPrint.TabVisible := False ;
    FormPrint.tsRetail.TabVisible := False ;
    if (ModelName <> '') and  (ModelName <> 'N/A') then
      FormPrint.Caption := ModelName +'_Shipper_Package_Print_Shell ' +VerInfo + ' (�V�X�]��)'
    else
      FormPrint.Caption := 'Shipper_Package_Print_Shell ' +VerInfo + ' (�V�X�]��)' ;

  end else if chkRetailLabel.Checked  then
  begin
    FormPrint.tsRetail.Show();
    FormPrint.tsPrint.TabVisible := False ;
    FormPrint.tsErie.TabVisible := False ;
    if (ModelName <> '') and  (ModelName <> 'N/A') then
      FormPrint.Caption := ModelName +'_Retail_Label_Print_Shell ' +VerInfo
    else
      FormPrint.Caption := 'Retail_Label_Print_Shell ' +VerInfo ;
  end else
  begin
    FormPrint.tsPrint.Show();
    FormPrint.tsErie.TabVisible := False ;
    FormPrint.tsRetail.TabVisible := False ;
    if (ModelName <> '') and  (ModelName <> 'N/A') then
      FormPrint.Caption := ModelName +'_Shipper_Package_Print_Shell ' +VerInfo
    else
      FormPrint.Caption := 'Shipper_Package_Print_Shell ' +VerInfo ;
  end;
  Self.Hide ;
end;

procedure TFormMain.CheckProgVersion(var TRES : string) ;
var
  MsgInfo : string;
begin
  with ObjDataSet.ObjQryData do
  begin
    Close ;
    Params.Clear ;
    CommandText := 'SELECT PARAM_VALUE FROM SAJET.SYS_BASE WHERE PARAM_NAME =''ProgVersion'' ';
    Open ;
    if not IsEmpty then
    begin
      if FieldValues['PARAM_VALUE'] = RzVersionInfo.FileVersion then
      begin
        TRES := 'OK' ;
        Close ;
      end else
      begin
        MsgInfo := '�{�Ǫ������~!'+#13+'���̵{�Ǫ���:'+FieldValues['PARAM_VALUE']+ #13+
                   '��e�{�Ǫ���:'+RzVersionInfo.FileVersion ;
        Close ;
        TRES := MsgInfo
      end;
    end
    else
    begin
      Close ;
      TRES := '�{�Ǫ�����Ƥ��s�b!' ;
      //MessageBox(GetActiveWindow ,'�{�Ǫ�����Ƥ��s�b!','ProgVision',MB_OK+MB_ICONERROR) ;
    end;
  end;
end;

procedure TFormMain.FormShow(Sender: TObject);
var
  sRes : string ;
begin
  Self.Left := Round((Screen.Width - Self.Width )/2);
  Self.Top := Round((Screen.Height - Self.Height )/2);
  RzVersionInfo.FilePath := Application.ExeName ;
  CheckProgVersion(sRes);
  if sRes <> 'OK'  then
  begin
    MessageDlg(sRes,mtError,[mbNo],0);
    Application.Terminate ;
  end;
  if ForceUpgrade then
  begin
    FormUpdate := TFormUpdate.Create(nil) ;
    FormUpdate.Timer1.Enabled := True ;
    FormUpdate.ShowModal ;
  end;

  with TIniFile.Create(ExtractFilePath(Application.ExeName)+'MainForm.ini') do
  begin
     chkRetailLabel.Checked := ReadBool('Print','RetailLabel',False);
     Free ;
  end;
  if chkRetailLabel.Checked  then
    chkMinglePack.Enabled :=false 
  else
    chkMinglePack.Enabled :=true;
end;

procedure TFormMain.EditWorkOrderKeyPress(Sender: TObject; var Key: Char);
begin
  EditBatch.Clear ;
  BitBtn1.Enabled := False;
  if Key = #13 then
  begin
    //if Key <> #13 then Exit;
    if Key = #13 then Key := #0; // 2007.05.23 �������UENTER��|�o�X�n��
    //�i��JSN or CSN�N����JWO 2005/2/15
    with ObjDataSet.ObjQryTemp do
    begin
      Close;
      Params.Clear ;
      CommandText := 'SELECT WORK_ORDER ' +
        ' FROM   SAJET.G_SN_STATUS ' +
        '   WHERE  SERIAL_NUMBER = :SERIAL_NUMBER AND ROWNUM = 1' ;
      Params.ParamByName('SERIAL_NUMBER').Value := EditWorkOrder.Text;
      Open;
      if IsEmpty then
      begin
        Close;
        Params.Clear;
        CommandText := 'SELECT WORK_ORDER ' +
          ' FROM   SAJET.G_SN_STATUS ' +
          '   WHERE  CUSTOMER_SN = :SERIAL_NUMBER AND ROWNUM = 1 ' ;
        Params.ParamByName('SERIAL_NUMBER').Value := EditWorkOrder.Text;
        Open;
      end;
      if not IsEmpty then
      begin
        EditWorkOrder.Text := FieldByName('WORK_ORDER').asstring;
      end ;
      Close ;
    end;

    with ObjDataSet.ObjQryTemp do
    begin
      Close ;
      Params.Clear ;
      Params.CreateParam(ftString, 'WO_NUMBER', ptInput);
      //CommandText := 'SELECT A.*, B.PART_NO, Label_File, CUST_PART_NO,C.MODEL_NAME ' +
      CommandText := 'SELECT WORK_ORDER,TARGET_QTY,WO_STATUS, B.PART_NO, Label_File, CUST_PART_NO,'+
        ' A.MODEL_ID,NVL(C.MODEL_NAME,''N/A'') MODEL_NAME ' +
        '  FROM   SAJET.G_WO_BASE A, SAJET.SYS_PART B ,SAJET.SYS_MODEL C  ' +
        '    WHERE  A.WORK_ORDER = :WO_NUMBER ' +
        '      AND    A.MODEL_ID = B.PART_ID(+)    '  +
        '        AND    B.MODEL_ID=C.MODEL_ID(+)  and rownum = 1';  // rownum 2006.11.13 add
      Params.ParamByName('WO_NUMBER').Value := EditWorkOrder.Text ;
      Open ;
      if not IsEmpty then
      begin
        if (FieldByName('WO_STATUS').AsString = '3') or (FieldByName('WO_STATUS').AsString = '2') then
        begin
          EditBatch.Text := FieldByName('TARGET_QTY').AsString;
          mWO := FieldByName('WORK_ORDER').AsString;
          mPartNO := FieldByName('PART_NO').AsString;
          mPartID := FieldByName('MODEL_ID').AsString;
          ModelName := FieldByName('MODEL_NAME').AsString;
          EditBatch.Enabled := False ;
          BitBtn1.Enabled := true ;
          BitBtn1.SetFocus ;
        end
        else
        begin
          Close;
          MessageDlg('WO Number Not In Work!!',mtError ,[mbOK],0);
          EditWorkOrder.SetFocus ;
          EditWorkOrder.SelectAll ;
          Exit;
        end;
      end else
      begin
        Close;
        MessageDlg('Invalid WO Number !!',mtError ,[mbOK],0);
        EditWorkOrder.SetFocus ;
        EditWorkOrder.SelectAll ;
      end;
      Close ;
    end;
  end;
end;

procedure TFormMain.chkRetailLabelClick(Sender: TObject);
begin
  chkMinglePack.Enabled := not chkRetailLabel.Checked ;
  chkMinglePack.Checked := False ;
end;

procedure TFormMain.chkMinglePackClick(Sender: TObject);
begin
  chkRetailLabel.Enabled := not chkMinglePack.Checked ;
  chkRetailLabel.Checked := False ;
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    objGlobal.objDataConnect.ObjConnection.Close;
    objGlobal.Free;
    ObjDataSet.ObjQryData.Close ;
    ObjDataSet.ObjProc.Close ;
    ObjDataSet.Free ;
  except

  end;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
  function GetTempDirectory : String;
  var
    TempDir : array[0..MAX_PATH] of Char;
  begin
    GetTempPath(MAX_PATH, @TempDir);
    Result := StrPas(TempDir);
  end;
begin
  Formprint.DeleteDirectory(GetTempDirectory) ;   //�R����󧨤U�ҥHlbl���
  Formprint.DeleteDirectory(GetTempDirectory,'*.lvd') ;   //�R����󧨤U�ҥHlvd���
  Formprint.DeleteDirectory(GetTempDirectory,'*.prv') ;   //�R����󧨤U�ҥHprv���
  Formprint.DeleteDirectory(GetTempDirectory,'*.lab') ;   //�R����󧨤U�ҥHlab���
  Formprint.DeleteDirectory(GetTempDirectory,'*.bak') ;   //�R����󧨤U�ҥHlab���
  SetWindowText(FindWindow('TLabelDocApplyForm',nil),'KILL ME');
end;

procedure TFormMain.ShowActiveWindow(THandle :HWND);
var
  OldPt, NewPt: TPoint;
begin
  //�P�_Application�O�_�̤p�ơA�Ӥ��O�D���f��Handle, �ϥ�Restore���٭�
  if IsIconic(Application.Handle) then
    Application.Restore;

  SetWindowPos(THandle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
  SetWindowPos(THandle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);

  // �O�s���Ц�m�A���������I�����f�A�M�Z�A�٭칫�Ц�m www.delphitop.com
  GetCursorPos(OldPt);
  NewPt:=Point(0, 0);
  Windows.ClientToScreen(THandle, NewPt);
  SetCursorPos(NewPt.X, NewPt.Y);
  mouse_event(MOUSEEVENTF_LEFTDOWN, NewPt.X, NewPt.Y, 0, 0);
  mouse_event(MOUSEEVENTF_LEFTUP, NewPt.X, NewPt.Y, 0, 0);
  SetCursorPos(OldPt.X, OldPt.Y);
end;

end.
