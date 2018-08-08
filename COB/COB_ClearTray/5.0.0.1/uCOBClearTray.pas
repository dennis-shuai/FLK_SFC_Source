unit uCOBClearTray;
                                           
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles;{, cxRadioGroup;}

type
  TfCOBClearTray = class(TForm)
    ImageAll: TImage;
    sbtnClose: TSpeedButton;
    Image2: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SimpleObjectBroker1: TSimpleObjectBroker;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SocketConnection1: TSocketConnection;
    dsData: TDataSource;
    SaveDialog: TSaveDialog;
    QryTemp1: TClientDataSet;
    Label3: TLabel;
    Label2: TLabel;
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    editTray: TEdit;
    editCarrier: TEdit;
    DBGrid1: TDBGrid;
    msgPanel: TPanel;
    labType: TLabel;
    rbTray: TRadioButton;
    rbCarrier: TRadioButton;
    btnClear: TButton;
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure editTrayKeyPress(Sender: TObject; var Key: Char);
    procedure editCarrierKeyPress(Sender: TObject; var Key: Char);
    procedure btnClearClick(Sender: TObject);
    procedure rbTrayClick(Sender: TObject);
    procedure btnClearKeyPress(Sender: TObject; var Key: Char);
  private
    procedure ShowData;
    procedure ClearData;
  public
    UpdateUserID : String;
    Authoritys,AuthorityRole,FunctionName : String;
    //Language : TLanguage;
    procedure SetStatusbyAuthority;
    Function LoadApServer : Boolean;
  end;

var
  fCOBClearTray: TfCOBClearTray;
  flag:Boolean;
  emess:string;
  gWO,gTrayNO:string;
  iTraySNCount,iSNCount:Integer;
  iTerminal:string;

implementation

{$R *.dfm}

procedure TfCOBClearTray.ShowData;
begin
  With QryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString,'BOX_NO',ptInput);
    CommandText := 'SELECT WORK_ORDER,BOX_NO,serial_number,in_process_time '+
                    '  FROM SAJET.g_sn_status A '+
                    ' WHERE Box_NO= :BOX_NO '+
                    ' ORDER BY in_process_time desc';
    if rbTray.Checked then
      Params.ParamByName('BOX_NO').AsString := Trim(editTray.Text)
    else
      Params.ParamByName('BOX_NO').AsString := Trim(editCarrier.Text);

    Open;
  end;
end;

procedure TfCOBClearTray.FormShow(Sender: TObject);
Var
  Bmp : TBitmap;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;

  Bmp.Free;

  LoadApServer;
  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;

  rbTray.Checked := true;
end;

Procedure TfCOBClearTray.SetStatusbyAuthority;
begin
  // Read Only,Allow To Change,Full Control
  Authoritys := '';
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'EMP_ID', ptInput);
    Params.CreateParam(ftString	,'PRG', ptInput);
    Params.CreateParam(ftString	,'FUN', ptInput);
    CommandText := 'Select AUTHORITYS '+
                   'From  SAJET.SYS_EMP_PRIVILEGE '+
                   'Where EMP_ID = :EMP_ID and '+
                         'PROGRAM = :PRG and '+
                         'FUNCTION = :FUN ';
    Params.ParamByName('EMP_ID').AsString := UpdateUserID;
    Params.ParamByName('PRG').AsString := 'PNWareHouse';
    Params.ParamByName('FUN').AsString := FunctionName;
    Open;
    If RecordCount > 0 Then
      Authoritys := Fieldbyname('AUTHORITYS').AsString;
    Close;
  end;

  if Authoritys = '' then
  begin
    AuthorityRole := '';
    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'EMP_ID', ptInput);
      Params.CreateParam(ftString	,'PRG', ptInput);
      Params.CreateParam(ftString	,'FUN', ptInput);
      CommandText := 'Select AUTHORITYS '+
                     //'From LOT.SYS_ROLE_PRIVILEGE A, '+
                     'From SAJET.SYS_ROLE_PRIVILEGE A, '+
                          'SAJET.SYS_ROLE_EMP B '+
                     'Where A.ROLE_ID = B.ROLE_ID and '+
                           'EMP_ID = :EMP_ID and '+
                           'PROGRAM = :PRG and '+
                           'FUNCTION = :FUN ';
      Params.ParamByName('EMP_ID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'PNWareHouse';//'Quality Control';
      Params.ParamByName('FUN').AsString := FunctionName;//'Execution';
      Open;
      If RecordCount > 0 Then
        AuthorityRole := Fieldbyname('AUTHORITYS').AsString;
      Close;
    end;
  end;
end;


Function TfCOBClearTray.LoadApServer : Boolean;
Var F : TextFile;
    S : String;
begin
  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  If not FileExists(GetCurrentDir+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,GetCurrentDir+'\ApServer.cfg');
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

procedure TfCOBClearTray.Image2Click(Sender: TObject);
begin
   Close;
end;

procedure TfCOBClearTray.editTrayKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    if (Copy(editTray.Text,1,1) <> 'T') or (length(editTray.Text)<>4) then
    begin
      msgPanel.Caption := 'Tray rule is wrong, First word is ''T'' and length is 4';
      msgPanel.Color := clRed;
      editTray.SetFocus;
      editTray.SelectAll;
      Abort;
    end;
    ShowData;

    if QryData.RecordCount > 0 then
    begin
      msgPanel.Caption := '';
      msgPanel.Color := clGreen;
      btnClear.SetFocus;
    end
    else
    begin
      msgPanel.Caption := 'NO Data';
      msgPanel.Color := clRed;
      editTray.SetFocus;
      editTray.SelectAll;
    end;
  end;
end;

procedure TfCOBClearTray.editCarrierKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    ShowData;

    if QryData.RecordCount > 0 then
    begin
      msgPanel.Caption := '';
      msgPanel.Color := clGreen;
      btnClear.SetFocus;
 
    end
    else
    begin
      msgPanel.Caption := 'NO Data';
      msgPanel.Color := clRed;
      editCarrier.SetFocus;
      editCarrier.SelectAll;
    end;
  end;
end;

procedure TfCOBClearTray.btnClearClick(Sender: TObject);
begin
  if MessageDlg('Clear All Data ?',mtWarning,[mbYes,mbNo],0) = mrYes then
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'BOX_NO',ptInput);
      CommandText := 'Update SAJET.G_SN_STATUS Set BOX_NO=''N/A'''+
                     ' WHERE BOX_NO = :BOX_NO';
     if rbTray.Checked then
        Params.ParamByName('BOX_NO').AsString := Trim(editTray.Text)
      else
        Params.ParamByName('BOX_NO').AsString := Trim(editCarrier.Text);

      Execute;
    end;
    ShowData;
    editTray.Text := '';
    editCarrier.Text := '';
    if rbTray.Checked then begin
      editTray.SetFocus;
      editTray.SelectAll;
    end;

    if rbCarrier.Checked then begin
       editCarrier.SetFocus;
        editCarrier.SelectAll;
    end;
  end;
end;

procedure TfCOBClearTray.rbTrayClick(Sender: TObject);
begin
  editTray.Text := '';
  editCarrier.Text := '';
  ClearData;
  if rbTray.Checked then
  begin
    DBGrid1.Columns[1].Title.Caption := 'Tray NO';
    editTray.Enabled := True;
    editCarrier.Enabled := False;
    editTray.SetFocus;
  end
  else
  begin
    DBGrid1.Columns[1].Title.Caption := 'Carrier NO';
    editCarrier.Enabled := True;
    editTray.Enabled := False;
    editCarrier.SetFocus;
  end;
end;

procedure TfCOBClearTray.ClearData;
begin
  With QryData do
  begin
    Close;
    Params.Clear;
    CommandText := 'SELECT WORK_ORDER,BOX_NO,serial_number,in_process_time '
                 + '  FROM SAJET.g_sn_status A '
                 + ' WHERE ROWNUM = 0';
    Open;
  end;
end;

procedure TfCOBClearTray.btnClearKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
    btnClear.Click;
end;

end.
