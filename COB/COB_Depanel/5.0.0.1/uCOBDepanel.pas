unit uCOBDepanel;
                                           
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles;

type
  TfCOBDepanel = class(TForm)
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
    lbldata: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    editTray: TEdit;
    editPanel: TEdit;
    DBGrid1: TDBGrid;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    labTSNCount: TLabel;
    labTray: TLabel;
    Label1: TLabel;
    labPartNo: TLabel;
    labTargetQty: TLabel;
    Label7: TLabel;
    labWO: TLabel;
    labPRemainQty: TLabel;
    Label4: TLabel;
    cbCheckWO: TCheckBox;
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure editTrayKeyPress(Sender: TObject; var Key: Char);
    procedure editPanelKeyPress(Sender: TObject; var Key: Char);
    procedure labTrayDblClick(Sender: TObject);
  private
    function CheckTray:string;
    function CheckPanel:string;

    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);

    function GetTerminalName(sTerminalID:string):string;

    procedure ShowData;
  public
    UpdateUserID : String;
    Authoritys,AuthorityRole,FunctionName : String;
    
    procedure SetStatusbyAuthority;
    Function LoadApServer : Boolean;
  end;

var
  fCOBDepanel: TfCOBDepanel;
  flag:Boolean;
  emess:string;
  gWO,gTrayNO:string;
  iTraySNCount,iSNCount:Integer;
  iTerminal:string;

implementation

{$R *.dfm}

function TfCOBDepanel.CheckTray:string;
begin
try
  Result := 'Check Tray Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.Sj_Chk_Tray');
      FetchParams;
      //Params.ParamByName('TWO').AsString := sWO ;
      Params.ParamByName('TREV').AsString := Trim(editTray.Text);
      Params.ParamByName('TREVCount').AsString := IntToStr(iTraySNCount);
      Execute;
      Result := Params.ParamByName('TRES').AsString;
    finally
      Close;
    end;
  end;
except on e:Exception do
  begin
    Result := 'CheckTray error : ' + e.Message;
  end;
end;
end;

function TfCOBDepanel.CheckPanel:string;
begin
  try
  Result := 'Check Panel Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.Sj_COB_Tray_Panel');
      FetchParams;
      Params.ParamByName('TTERMINAL').AsString := iTerminal;
      Params.ParamByName('TEMP').AsString := UpdateUserID;
      Params.ParamByName('TTRAY').AsString := Trim(editTray.Text);
      Params.ParamByName('TTRAYCOUNT').AsString := IntToStr(iTraySNCount);
      Params.ParamByName('TREV').AsString := Trim(editPanel.Text);
      if cbCheckWO.Checked then
        Params.ParamByName('TCHECKWO').AsString := '0'
      else
        Params.ParamByName('TCHECKWO').AsString := '1';  
      Execute;

      Result := Params.ParamByName('TRES').AsString;
      labPRemainQty.Caption := Params.ParamByName('TPRemainQty').AsString
    finally
      Close;
    end;
  end;
except on e:Exception do
  begin
    Result := 'CheckPanel error : ' + e.Message;
  end;
end;
end;

function TfCOBDepanel.GetTerminalName(sTerminalID:string):string;
var sPdline,sProcess,sTerminal:string;
begin
try
  with Qrytemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'TerminalID',ptInput);
      CommandText :='select a.pdline_name,b.process_name,c.terminal_name,c.terminal_id  ' +
                    '  from sajet.sys_pdline a,sajet.sys_process b,sajet.sys_terminal c '+
                    'where c.terminal_id = :TerminalID  '+
                    '  and a.pdline_id=c.pdline_id '+
                    '  and b.process_id=c.process_id';

      Params.ParamByName('TerminalID').AsString :=sTerminalID;
      Open;
      if RecordCount > 0 then
      begin
         sPdline := Fieldbyname('pdline_name').AsString  ;
         sProcess:= Fieldbyname('process_name').AsString  ;
         sTerminal:= Fieldbyname('terminal_name').AsString  ;
         Result := sPdline + ' \ ' + sProcess + ' \ ' + sTerminal ;
      end   
      else
         Result :='No Terminal information!';
   end;
Except   on e:Exception do
   Result := 'Get Terminal : ' + e.Message;

end;
end;

procedure TfCOBDepanel.ShowMSG(sShowHead,sShowResult,sNextMsg:string);
var sShowData:string;
begin
  if Copy(sShowResult,1,2) = 'OK' then
  begin
    msgPanel.Color := clGreen;
  end
  else
  begin
    msgPanel.Color := clRed;
  end;
  sShowData := sShowHead + ' ' +  sShowResult;
  if sNextMsg <> '' then
  begin
    sShowData := sShowData + '  =>  ' + sNextMsg;
  end;
  msgPanel.Caption := sShowData;
end;

procedure TfCOBDepanel.ShowData;
var iqty : Integer;
begin
  iqty := 0 ;
  With QryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString,'TRAYNO',ptInput);
    CommandText := 'SELECT A.WORK_ORDER,A.BOX_NO,A.serial_number,A.in_process_time '+
                    '  FROM SAJET.g_sn_status A '+
                    ' WHERE A.Box_NO= :TRAYNO '+
                    ' AND A.CURRENT_STATUS = ''0'' ' + //不显示维修的
                    ' AND A.WORK_FLAG=''0'' '+         //只显示正常过站的，报废的不显示
                    ' ORDER BY A.in_process_time desc';
    Params.ParamByName('TRAYNO').AsString := Trim(editTray.Text);
    Open;
    iSNCount := RecordCount ;
    labTSNCount.Caption := IntToStr(iSNCount) + ' / ' + IntToStr(iTraySNCount);

    {if iSNCount >= iTraySNCount then
    begin
      editPanel.Enabled := False;
      editTray.Enabled := True;
      editTray.SelectAll;
      editTray.SetFocus;
    end
    else
    begin
      editPanel.Enabled := True;
      editPanel.SetFocus;
    end; }
  end;
end;

procedure TfCOBDepanel.FormShow(Sender: TObject);
Var DestRect,SurcRect : TRect; Bmp : TBitmap;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;

  Bmp.Free;

  LoadApServer;
  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;

  editTray.SetFocus;
  editTray.Text := '';
  LabTerminal.Caption := LabTerminal.Caption + '    ' + GetTerminalName(iTerminal);
  labWO.Caption := '';
  labTray.Caption := '';
  labTSNCount.Caption := '';
  labPRemainQty.Caption := '';
  //ShowMessage(IntToStr(iTraySNCount));
end;

Procedure TfCOBDepanel.SetStatusbyAuthority;
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
    Params.ParamByName('PRG').AsString := 'COB';
    Params.ParamByName('FUN').AsString := 'COB INPUT';
    Open;
    If RecordCount > 0 Then
      Authoritys := Fieldbyname('AUTHORITYS').AsString;
    Close;
  end;

  //sbtnSave.Enabled := ((Authoritys = 'Allow To Execute') or (Authoritys = 'Full Control'));

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
      Params.ParamByName('PRG').AsString := 'COB';//'Quality Control';
      Params.ParamByName('FUN').AsString := 'COB INPUT';
      Open;
      If RecordCount > 0 Then
        AuthorityRole := Fieldbyname('AUTHORITYS').AsString;
      Close;
    end;
    //sbtnSave.Enabled := ((AuthorityRole = 'Allow To Execute') or (AuthorityRole = 'Full Control'));
  end;
end;


Function TfCOBDepanel.LoadApServer : Boolean;
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

procedure TfCOBDepanel.Image2Click(Sender: TObject);
begin
   Close;
end;

procedure TfCOBDepanel.editTrayKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
  if trim(editTray.Text) = '' then
    exit;
    
  if Key = #13 then
  begin
    iResult := CheckTray;

    if Copy(iResult,1,2) = 'OK' then
    begin
      ShowMSG('Tray No input : ',iResult,'Please input Panel No!');
      editPanel.Enabled := True;
      editPanel.SetFocus;
      editPanel.Text := '';
      gTrayNO := Trim(editTray.Text);
      ShowData;

      if iSNCount >= iTraySNCount then
      begin
        ShowMSG('Tray No input : ','Error,Tray Dup','Please input Tray again!');
        editPanel.Enabled := False;
        editTray.SelectAll;
        editTray.SetFocus;
      end
      else
        editTray.Enabled := False;
    end
    else
    begin
      ShowMSG('Tray No input : ',iResult,'Please input Tray again!');
      editPanel.Enabled := False;
      editTray.SelectAll;
      editTray.SetFocus;
      gTrayNO := Trim(editTray.Text);
    end;
    labTray.Caption := gTrayNO;
  end;
end;

procedure TfCOBDepanel.editPanelKeyPress(Sender: TObject; var Key: Char);
var
  iResult:string;
  PassCount: integer;
begin
  if trim(editTray.Text) = '' then
    exit;
    
  if Key = #13 then
  begin
    if trim(editTray.Text) = '' then
    begin
      editTray.Enabled := True;
      editTray.SetFocus;
      editTray.Text := '';
      editPanel.Text := '';
      Exit;
    end;

    if iSNCount >= iTraySNCount then
    begin
      ShowMSG('Panel No input : ','Error,Tray is Full','Please input new Tray!');
      editPanel.Enabled := False;
      editTray.Enabled := True;
      editTray.SetFocus;
      editTray.Text := '';
      Abort;
      //gTrayNO := '';
    end;

    iResult := CheckPanel;  //过站

    if Copy(iResult,1,2) = 'OK' then
    begin
      ShowMSG('Panel No input : ',iResult,'Please input new Panel No!');
      ShowData;

      //从状态表带出Panel的工单
      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'Panel_NO',ptInput);
        CommandText := 'Select G.WORK_ORDER,W.TARGET_QTY,P.PART_NO '
                     + ' FROM SAJET.G_SN_STATUS G,SAJET.SYS_PART P,SAJET.G_WO_BASE W '
                     + 'WHERE G.MODEL_ID = P.PART_ID '
                     + '  AND G.WORK_ORDER = W.WORK_ORDER '
                     + '  AND BOX_NO = :Panel_NO'
                     + '  AND ROWNUM = 1';
        Params.ParamByName('Panel_NO').AsString := Trim(editPanel.Text);
        Open;

        labWO.Caption := FieldByName('WORK_ORDER').AsString;
        labPartNo.Caption := FieldByName('PART_NO').AsString;
        labTargetQty.Caption := FieldByName('TARGET_QTY').AsString;
      end;

      //Panel没有全部入Tray，需要再输入新Tray
      if labPRemainQty.Caption <> '0' then
      begin
        editPanel.Enabled := False;
        editTray.Enabled := True;
        editTray.SelectAll;
        editTray.SetFocus;
      end
      else
      begin
        editPanel.Enabled := True;
        editPanel.SetFocus;
        editPanel.Text:='';
      end;
    end
    else
    begin
      ShowMSG('Panel No input : ',iResult,'');
      editPanel.Enabled := True;
      editPanel.SetFocus;
      editPanel.SelectAll;
    end;
  end;
end;

procedure TfCOBDepanel.labTrayDblClick(Sender: TObject);
begin
  if not editTray.Enabled then
  begin
    editPanel.Enabled := False;
    editTray.Enabled := True;
    editTray.SelectAll;
    editTray.SetFocus;
  end
  else
  begin
    editTray.Enabled := False;
  end;
end;

end.
