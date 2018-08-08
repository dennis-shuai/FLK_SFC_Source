unit uCOBRank;
                                           
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles;

type
  TfCOBRank = class(TForm)
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
    editWO: TEdit;
    editTray: TEdit;
    editCarrier: TEdit;
    DBGrid1: TDBGrid;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    labSNCount: TLabel;
    labWO: TLabel;
    labTray: TLabel;
    Label1: TLabel;
    labPartNo: TLabel;
    Label8: TLabel;
    Label4: TLabel;
    labPWO: TLabel;
    labCarrierQty: TLabel;
    lblType: TLabel;
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure editTrayKeyPress(Sender: TObject; var Key: Char);
    procedure editCarrierKeyPress(Sender: TObject; var Key: Char);
    procedure labTrayDblClick(Sender: TObject);
  private
    //m_SNDefectLevel: String;

    function CheckTray:string;
    function CheckCarrier:string;

    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);

    function GetTerminalName(sTerminalID:string):string;


    function GetPartID(partno :String) :String;
    procedure ShowData(Show: Boolean);
  public
    UpdateUserID : String;
    Authoritys,AuthorityRole,FunctionName : String;
    //Language : TLanguage;
    procedure SetStatusbyAuthority;
    Function LoadApServer : Boolean;
  end;

var
  fCOBRank: TfCOBRank;
  flag:Boolean;
  emess:string;
  gWO,gTrayNO:string;
  CarrierQty,DeductQty:Integer;
  iTerminal:string;

implementation

{$R *.dfm}

function TfCOBRank.CheckTray:string;
begin
try
  Result := 'Check Tray Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_COB_Ckrt_Tray');
      FetchParams;
      Params.ParamByName('TERMINALID').AsString := iTerminal;
      Params.ParamByName('TREV').AsString := Trim(editTray.Text);
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

function TfCOBRank.CheckCarrier:string;
begin
  try
  Result := 'Check Carrier Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_COB_Carrier_Rank');
      FetchParams;
      Params.ParamByName('TTERMINALID').AsString := iTerminal;
      Params.ParamByName('TEMP').AsString := UpdateUserID;
      Params.ParamByName('TTRAY').AsString := Trim(editTray.Text);
      Params.ParamByName('TREV').AsString := Trim(editCarrier.Text);
      Params.ParamByName('CARRIERQTY').AsString := IntToStr(8);
      Execute;
      Result := Params.ParamByName('TRES').AsString;
      DeductQty := Params.ParamByName('CDEDUCTQTY').AsInteger;
      labCarrierQty.Caption := IntToStr(DeductQty) + ' / ' + IntToStr(CarrierQty);
    finally
      Close;
    end;
  end;
except on e:Exception do
  begin
    Result := 'Check Carrier error : ' + e.Message;
  end;
end;
end;

function TfCOBRank.GetTerminalName(sTerminalID:string):string;
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

procedure TfCOBRank.ShowMSG(sShowHead,sShowResult,sNextMsg:string);
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

function TfCOBRank.GetPartID(partno :String) :String;
begin
    with Qrytemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'PARTNO',ptInput);
        CommandText :='SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO= :PARTNO AND ENABLED=''Y'' AND ROWNUM=1 ' ;
        Params.ParamByName('PARTNO').AsString := partno;
        Open;
        if Recordcount = 0 then
            Result :=''
        else
            Result := FieldbyName('PART_ID').AsString;
    end;
end;

procedure TfCOBRank.ShowData(Show: Boolean);
var
  iqty : Integer;
  sFlag: string;
begin
  iqty := 0 ;
  if Show then
    sFlag := '1'
  else
    sFlag := '0';
  With QryData do
  begin
     Close;
     Params.Clear;
     //Params.CreateParam(ftString,'WO',ptInput);
     Params.CreateParam(ftString,'TRAYNO',ptInput);
     CommandText := 'SELECT A.WORK_ORDER,P.PART_NO,A.BOX_NO,A.serial_number,A.in_process_time '+
                    '  FROM SAJET.g_sn_status A, SAJET.SYS_PART P'+
                    ' WHERE A.Box_NO = :TRAYNO '+
                    ' AND A.WORK_FLAG =''0'' '+     //ֻ��ʾ������վ�ģ����ϵĲ���ʾ  add by phoenix 2013-5-7
                    ' AND A.CURRENT_STATUS = ''0'' '+
                    ' AND A.MODEL_ID = P.PART_ID '+
                    ' AND 1 ='''+ sFlag+''' '+
                    ' ORDER BY A.in_process_time desc';
   //Params.ParamByName('WO').AsString := trim(editWO.Text);
   Params.ParamByName('TRAYNO').AsString := Trim(editTray.Text);
   Open;
   labWO.Caption := FieldByName('WORK_ORDER').AsString;
   labPartNO.Caption := FieldByName('PART_NO').AsString;

   labSNCount.Caption := InttoStr(RecordCount) ;
  end;
end;

procedure TfCOBRank.FormShow(Sender: TObject);
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
  labPartNo.Caption := '';
  labTray.Caption := '';
  labSNCount.Caption := '';

  CarrierQty := 8;
end;

Procedure TfCOBRank.SetStatusbyAuthority;
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


Function TfCOBRank.LoadApServer : Boolean;
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

procedure TfCOBRank.Image2Click(Sender: TObject);
begin
   Close;
end;

procedure TfCOBRank.editTrayKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
  if trim(editTray.Text) = '' then
    exit;

  if Key = #13 then
  begin
    iResult := CheckTray;

    if Copy(iResult,1,2) = 'OK' then
    begin
      ShowMSG('Tray No input : ',iResult,'Please input Carrier No!');
      editCarrier.Enabled := True;
      editCarrier.SetFocus;
      editCarrier.Text := '';
      gTrayNO := Trim(editTray.Text);
      editTray.Enabled := False;
      ShowData(True);

      labCarrierQty.Caption := '0/' + IntToStr(CarrierQty);
      if labPartNO.Caption ='7681-47J7-0071' then
         lblType.Caption :='Compeq+NMX';
      if labPartNO.Caption ='7681-47J7-0171' then
         lblType.Caption :='Compeq+AO';
      if labPartNO.Caption ='7681-47J7-0271' then
         lblType.Caption :='UMT+NMX';
      if labPartNO.Caption ='7681-47J7-0371' then
         lblType.Caption :='UMT+AO';
    end
    else
    begin
      ShowMSG('Tray No input : ',iResult,'Please input Tray again!');
      editCarrier.Enabled := False;
      editTray.SelectAll;
      editTray.SetFocus;
      gTrayNO := Trim(editTray.Text);
      ShowData(False);
    end;
    labTray.Caption := gTrayNO;
  end;
end;

procedure TfCOBRank.editCarrierKeyPress(Sender: TObject; var Key: Char);
var
  iResult:string;
  PassCount: integer;
begin
  if Trim(editCarrier.Text) = '' then
    exit;

  if Key = #13 then
  begin
    if Trim(editTray.Text) = '' then
    begin
      editTray.Enabled := True;
      editTray.SetFocus;
      editTray.Text := '';
      editCarrier.Text := '';
      Exit;
    end;

    iResult := CheckCarrier;

    if Copy(iResult,1,2) = 'OK' then
    begin
      ShowMSG('Carrier No input : ',iResult,'Please input new Carrier No!');
      ShowData(True);

      if DeductQty < CarrierQty then
      begin
        editCarrier.Enabled := False;
        editTray.Enabled := True;
        editTray.SetFocus;
        editTray.Text := '';
        labTray.Caption := '';
        gTrayNO := '';
        ShowData(True);
        labSNCount.Caption := '';
      end
      else
      begin
        editCarrier.SetFocus;
        editCarrier.Text:='';
        labCarrierQty.Caption := '0/' + IntToStr(CarrierQty);
      end;
    end
    else
    begin
      ShowMSG('Carrier No input : ',iResult,'');
      editCarrier.SetFocus;
      editCarrier.SelectAll;
    end;
  end;
end;

procedure TfCOBRank.labTrayDblClick(Sender: TObject);
begin
  if not editTray.Enabled then
  begin
    editCarrier.Enabled := False;
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