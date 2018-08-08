unit uSetStation;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ComCtrls, StdCtrls, Buttons, ExtCtrls, DB, IniFiles;

const
MAX_HOSTNAME_LEN = 128; { from IPTYPES.H }
MAX_DOMAIN_NAME_LEN = 128;
MAX_SCOPE_ID_LEN = 256;
MAX_ADAPTER_NAME_LENGTH = 256;
MAX_ADAPTER_DESCRIPTION_LENGTH = 128;
MAX_ADAPTER_ADDRESS_LENGTH = 8;

type
    TIPAddressString = array[0..4 * 4 - 1] of AnsiChar;
    PIPAddrString = ^TIPAddrString;
    TIPAddrString = record
    Next: PIPAddrString;
    IPAddress: TIPAddressString;
    IPMask: TIPAddressString;
    Context: Integer;
end;

PFixedInfo = ^TFixedInfo;
TFixedInfo = record { FIXED_INFO }
    HostName: array[0..MAX_HOSTNAME_LEN + 3] of AnsiChar;
    DomainName: array[0..MAX_DOMAIN_NAME_LEN + 3] of AnsiChar;
    CurrentDNSServer: PIPAddrString;
    DNSServerList: TIPAddrString;
    NodeType: Integer;
    ScopeId: array[0..MAX_SCOPE_ID_LEN + 3] of AnsiChar;
    EnableRouting: Integer;
    EnableProxy: Integer;
    EnableDNS: Integer;
end;

PIPAdapterInfo = ^TIPAdapterInfo;
TIPAdapterInfo = record { IP_ADAPTER_INFO }
    Next: PIPAdapterInfo;
    ComboIndex: Integer;
    AdapterName: array[0..MAX_ADAPTER_NAME_LENGTH + 3] of AnsiChar;
    Description: array[0..MAX_ADAPTER_DESCRIPTION_LENGTH + 3] of AnsiChar;
    AddressLength: Integer;
    Address: array[1..MAX_ADAPTER_ADDRESS_LENGTH] of Byte;
    Index: Integer;
    _Type: Integer;
    DHCPEnabled: Integer;
    CurrentIPAddress: PIPAddrString;
    IPAddressList: TIPAddrString;
    GatewayList: TIPAddrString;
    DHCPServer: TIPAddrString;
    HaveWINS: Bool;
    PrimaryWINSServer: TIPAddrString;
    SecondaryWINSServer: TIPAddrString;
    LeaseObtained: Integer;
    LeaseExpires: Integer;
end;

type
  TfStation = class(TForm)
    TreePC: TTreeView;
    Image1: TImage;
    sbtnClose: TSpeedButton;
    sbtnSave: TSpeedButton;
    Label4: TLabel;
    Image2: TImage;
    Label3: TLabel;
    Image5: TImage;
    Image3: TImage;
    cmbFactory: TComboBox;
    Label2: TLabel;
    LabPDLine: TLabel;
    Label1: TLabel;
    LabStage: TLabel;
    Label5: TLabel;
    LabProcess: TLabel;
    Label6: TLabel;
    LabTerminal: TLabel;
    ImageList2: TImageList;
    cmbOpType: TComboBox;
    Label7: TLabel;
    cmbOpid: TComboBox;
    Label8: TLabel;
    LabIP: TLabel;
    Label9: TLabel;
    LabMac: TLabel;
    LabMsg: TLabel;
    chkShowAll: TCheckBox;
    Label10: TLabel;
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
    procedure TreePCClick(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure TreePCGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure cmbOpTypeChange(Sender: TObject);
    procedure chkShowAllClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FcID ,sDefaultPdline,sIP,sMac,sIPPrefix: String;
    Procedure ShowTerminal;
    Function  GetPdLineData(PdLineName : String; var PdLineID : String): Boolean;
    Function  GetProcessData(ProcessName : String; var ProcessID : String; var ProcessCode : String; var ProcessDesc : String): Boolean;
    Function  GetTerminalData(TerminalName : String; PdLineID : String; ProcessID : String; var TerminalID : String): Boolean;
    procedure ShowOperateType;
    procedure GetIPAddress;
    function  SaveToDb:Boolean;
   // function  GetComputer:String;
  end;

var
  fStation: TfStation;
  function GetAdaptersInfo(AI: PIPAdapterInfo; var BufLen: Integer): Integer; stdcall; external 'iphlpapi.dll' Name 'GetAdaptersInfo';

implementation

{$R *.DFM}
Uses uData;


{
function TfStation.GetComputer:String;
   var  Buffer:Pchar;
        BufferLen:DWORD;
        StrName:String;
begin
     BufferLen:=  MAX_COMPUTERNAME_LENGTH+1 ;
     GetMem(Buffer,BufferLen);
     GetComputerName(Buffer,BufferLen);
     StrName:=StrPas(Buffer);
     FreeMem(Buffer,BufferLen);
     Result:=StrName;
end;
}

function MACToStr(ByteArr: PByte; Len: Integer): string;
begin
    Result := '';
    while (Len > 0) do
    begin
        Result := Result + IntToHex(ByteArr^, 2) + '-';
        ByteArr := Pointer(Integer(ByteArr) + SizeOf(Byte));
        Dec(Len);
    end;
    SetLength(Result, Length(Result) - 1); { remove last dash }
end;

function GetMaskString(Addr: PIPAddrString): string;
begin
    Result := '';
    while (Addr <> nil) do
    begin
        Result := Result + Addr^.IPMask + #13;
        Addr := Addr^.Next;
    end;
end;

function GetIPString(Addr: PIPAddrString): string;
begin
    Result := '';
    while (Addr <> nil) do
    begin
        Result := Result + Addr^.IPAddress + #13;
        Addr := Addr^.Next;
    end;
end;

function  TfStation.SaveToDb:Boolean;
var sResult:string;
begin
   with fData.Sproc do
   begin
       Close;
       DataRequest('SAJET.CCM_SETUP_TERMINAL_INFO');
       FetchParams;
       Params.ParamByName('TTERMINALID').AsString := fData.TerminalID ;
       Params.ParamByName('TIPADDR').AsString :=sIP ;
       Params.ParamByName('TMACADDR').AsString := sMac;
       Params.ParamByName('TEMPID').AsString := fData.UpdateUserId;
       Execute;
       sResult := Params.ParamByName('TRES').AsString;
       if  sResult <> 'OK' then
       begin
           MessageDlg(sResult,mtError,[mbOK],0);
           Result :=false;
           Exit;
       end else begin
            Result :=true;
       end;

   end;

end;

procedure TfStation.GetIPAddress;
Var
AI,Work : PIPAdapterInfo;
Size : Integer;
Res : Integer;
begin
    Size := 5120;
    GetMem(AI,Size);
    Res := GetAdaptersInfo(AI,Size);
    if (Res <> ERROR_SUCCESS) then
    begin
        SetLastError(Res);
        RaiseLastWin32Error;
    end;
    Work := AI;
    Repeat
        sMac:= MACToStr(@Work^.Address,Work^.AddressLength);
        sIP := Trim(GetIPString(@Work^.IPAddressList)) ;
        if Copy(sIP,1,Length(sIPPrefix))=sIPPrefix then
        begin
           LabIP.Caption := sIP;
           LabMac.Caption := sMac;
           FreeMem(AI);
           Exit;
        end;
        Work := Work^.Next;
    Until (Work = nil);

    FreeMem(AI);
end;



Procedure TfStation.ShowTerminal;
var sLine,sFirstLine,sStage,sFirstStage,sProcess,sFirstProcess : string;
    mNodeLine,mNodeStage,mNodeProcess, mNode, mCurrentNode: TTreeNode;
    i:Integer;
begin

  LabPDLine.Caption := '';
  LabStage.Caption := '';
  LabProcess.Caption := '';
  LabTerminal.Caption := '';

  TreePC.Items.Clear;
  With fData.QryTemp do
  begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'FCID', ptInput);
      Params.CreateParam(ftString	,'OPERATEID1', ptInput);
      CommandText := 'Select PDLINE_NAME,STAGE_CODE,STAGE_NAME,PROCESS_CODE,PROCESS_NAME,TERMINAL_ID,TERMINAL_NAME '+
                     'From SAJET.SYS_TERMINAL A, SAJET.SYS_PDLINE B,SAJET.SYS_STAGE C,SAJET.SYS_PROCESS D '+
                     'Where B.FACTORY_ID = :FCID and A.PDLINE_ID = B.PDLINE_ID and A.STAGE_ID = C.STAGE_ID and '+
                           'A.PROCESS_ID = D.PROCESS_ID and D.OPERATE_ID = :OPERATEID1  AND A.ENABLED = ''Y'' and '+
                           'B.ENABLED = ''Y'' and C.ENABLED = ''Y'' and D.ENABLED = ''Y'' ';
      if (fData.TerminalID <> '0') and ((fData.AuthorityRole <>'Full Control') or (not chkShowAll.Checked)) then
          fData.QryTemp.CommandText :=CommandText+ ' and B.pdline_id ='+fData.sPdlineid ;

      CommandText :=CommandText+' Order By PDLINE_NAME DESC ,STAGE_CODE,STAGE_NAME,PROCESS_CODE,PROCESS_NAME,TERMINAL_NAME ';
      Params.ParamByName('FCID').AsString := FcID;
      Params.ParamByName('OPERATEID1').AsString := trim(cmbOpId.Text);
      Open;

      for i:=0 to RecordCount-1 do
      begin

          sLine := Fieldbyname('PDLINE_NAME').AsString;
          sStage := Fieldbyname('STAGE_NAME').AsString;
          sProcess := Fieldbyname('PROCESS_NAME').AsString;
          if i =0 then begin
             sFirstLine  :=sLine;
             sFirstStage  :=sStage;
             sFirstProcess  :=sProcess;
             mNodeLine := TreePC.Items.AddChildFirst(nil, sLine);
             mNodeLine.ImageIndex := 0;
             mNodeStage := TreePC.Items.AddChildFirst(mNodeLine, sStage);
             mNodeStage.ImageIndex := 1;
             mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, sProcess);
             mNodeProcess.ImageIndex := 2;
          end;

          if sLine <> sFirstLine then
          begin
             mNodeLine := TreePC.Items.AddChildFirst(nil, sLine);
             mNodeLine.ImageIndex := 0;
             mNodeStage := TreePC.Items.AddChildFirst(mNodeLine, sStage);
             mNodeStage.ImageIndex := 1;
             mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, sProcess);
             mNodeProcess.ImageIndex := 2;
             sFirstLine  :=sLine;
             sFirstStage  :=sStage;
             sFirstProcess  :=sProcess;
          end ;
          if sStage <> sFirstStage then
          begin
             mNodeStage := TreePC.Items.AddChildFirst(mNodeLine, sStage);
             mNodeStage.ImageIndex := 1;
             mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, sProcess);
             mNodeProcess.ImageIndex := 2;
             sFirstStage  :=sStage;
             sFirstProcess  :=sProcess;
          end ;
          if sProcess <> sFirstProcess then
          begin
             mNodeProcess := TreePC.Items.AddChildFirst(mNodeStage, sProcess);
             mNodeProcess.ImageIndex := 2;
             sFirstProcess  :=sProcess;
          end;

          With TreePC.Items.AddChild(mNodeProcess, FieldByName('TERMINAL_NAME').asstring) do
          begin
             ImageIndex := 3;
             If FieldByName('TERMINAL_ID').asstring = fData.TerminalID Then
             begin
                LabPDLine.Caption := Parent.Parent.Parent.Text;
                LabStage.Caption := Parent.Parent.Text;
                LabProcess.Caption := Parent.Text;
                LabTerminal.Caption := Text;
             end;
          end;
          next;
      end;


    Close;
    mNodeLine := nil;
    mNodeStage := nil;
    mNodeProcess := nil;
  end;
end;

Function TfStation.GetTerminalData(TerminalName : String; PdLineID : String; ProcessID : String; var TerminalID : String): Boolean;
Var S : String;
begin
  Result := False;
  With fData.QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'PDLINE_ID', ptInput);
     Params.CreateParam(ftString	,'PROCESS_ID', ptInput);
     Params.CreateParam(ftString	,'TERMINAL_NAME', ptInput);
     CommandText := 'Select TERMINAL_ID '+
                    'From SAJET.SYS_TERMINAL '+
                    'Where PDLINE_ID = :PDLINE_ID and '+
                          'PROCESS_ID = :PROCESS_ID and '+
                          'TERMINAL_NAME = :TERMINAL_NAME ';
     Params.ParamByName('PDLINE_ID').AsString := PdLineID;
     Params.ParamByName('PROCESS_ID').AsString := ProcessID;
     Params.ParamByName('TERMINAL_NAME').AsString := TerminalName;
     Open;
     If RecordCount > 0 Then
        TerminalID := Fieldbyname('TERMINAL_ID').AsString;
     Close;
  end;

  If TerminalID = '' Then
  begin
     S := 'Terminal data Error !! '+#13#10 +
          'Terminal Name : '+ TerminalName;
     MessageDlg(S,mtError, [mbCancel],0);
     Exit;
  end;
  Result := True;
end;

procedure TfStation.sbtnCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TfStation.FormShow(Sender: TObject);
Var S : String;
begin
  cmbFactory.Items.Clear;
  TreePC.Items.Clear;
  LabPDLine.Caption := '';
  LabStage.Caption := '';
  LabProcess.Caption := '';
  LabTerminal.Caption := '';
  sIPPrefix := fData.sIPPrefix;
  S := '';
  With fData.QryTemp do
  begin
     Close;
     Params.Clear;
     CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME '+
                    'From SAJET.SYS_FACTORY '+
                    'Where ENABLED = ''Y'' ';
     Open;
     While Not Eof do
     begin
        cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString);
        If Fieldbyname('FACTORY_ID').AsString = fData.FCID Then
           S := Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString;
        Next;
     end;
     Close;
  end;

  if fData.AuthorityRole <> 'Full Control' then
  begin
      chkShowAll.Enabled :=False;
      if fData.TerminalID ='0' then
      begin
          sbtnSave.Enabled :=False;
          Label3.Enabled :=false;
          LabMsg.Caption :='第一次選擇站別,請聯繫SFCS管理員';
          Exit;
      end;
  end;

  GetIPAddress;

  showOperateType;
  if fData.cmbTypeID <> '' then
  begin
    cmbOpType.ItemIndex := cmbOpid.Items.IndexOf(fData.cmbTypeID);
    cmbOpid.ItemIndex := cmbOpid.Items.IndexOf(fData.cmbTypeID);
  end;

  If S <> '' Then
  begin
     cmbFactory.ItemIndex := cmbFactory.Items.IndexOf(S);
     cmbFactoryChange(Self);
     Exit;
  end;

  If cmbFactory.Items.Count = 1 Then
  begin
     cmbFactory.ItemIndex := 0;
     cmbFactoryChange(Self);
  end;

end;

procedure TfStation.cmbFactoryChange(Sender: TObject);
begin
  FcID := '';
  LabPDLine.Caption := '';
  LabStage.Caption := '';
  LabProcess.Caption := '';
  LabTerminal.Caption := '';

  With fData.QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'FACTORYCODE', ptInput);
     CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC '+
                    'From SAJET.SYS_FACTORY '+
                    'Where FACTORY_CODE = :FACTORYCODE ';
     Params.ParamByName('FACTORYCODE').AsString := Copy(cmbFactory.Text,1,POS(' ',cmbFactory.Text)-1) ;
     Open;
     If RecordCount > 0 Then
        FcID := Fieldbyname('FACTORY_ID').AsString;
     Close;
  end;

  ShowTerminal;

end;

Function TfStation.GetPdLineData(PdLineName : String; var PdLineID : String): Boolean;
Var S : String;
begin
  Result := False;
  With fData.QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'PDLINE_NAME', ptInput);
     CommandText := 'Select PDLINE_ID,PDLINE_NAME '+
                    'From SAJET.SYS_PDLINE '+
                    'Where PDLINE_NAME = :PDLINE_NAME ';
     Params.ParamByName('PDLINE_NAME').AsString := PdLineName;
     Open;
     If RecordCount > 0 Then
     begin
        PdLineID := Fieldbyname('PDLINE_ID').AsString;
     end;
     Close;
  end;

  If PdLineID = '' Then
  begin
     S := 'Production Line data Error !! '+#13#10 +
          'Production Name : '+ PdLineName;
     MessageDlg(S,mtError, [mbCancel],0);
     Exit;
  end;
  Result := True;
end;

Function TfStation.GetProcessData(ProcessName : String; var ProcessID : String; var ProcessCode : String; var ProcessDesc : String): Boolean;
Var S : String;
begin
  Result := False;
  With fData.QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'PROCESS_NAME', ptInput);
     CommandText := 'Select PROCESS_ID,PROCESS_CODE,PROCESS_NAME,PROCESS_DESC '+
                    'From SAJET.SYS_PROCESS '+
                    'Where PROCESS_NAME = :PROCESS_NAME ';
     Params.ParamByName('PROCESS_NAME').AsString := ProcessName;
     Open;
     If RecordCount > 0 Then
     begin
        ProcessID := Fieldbyname('PROCESS_ID').AsString;
        ProcessCode := Fieldbyname('PROCESS_CODE').AsString;
        ProcessDesc := Fieldbyname('PROCESS_DESC').AsString;
     end;
     Close;
  end;

  If ProcessID = '' Then
  begin
     S := 'Process data Error !! '+#13#10 +
          'Process Name : '+ ProcessName;
     MessageDlg(S,mtError, [mbCancel],0);
     Exit;
  end;
  Result := True;
end;

procedure TfStation.TreePCClick(Sender: TObject);
begin
  If TreePC.Selected = nil Then Exit;

  LabPDLine.Caption := '';
  LabStage.Caption := '';
  LabProcess.Caption := '';
  LabTerminal.Caption := '';

  If TreePC.Selected.Level <> 3 Then Exit;

  LabPDLine.Caption := TreePC.Selected.Parent.Parent.Parent.Text;
  LabStage.Caption := TreePC.Selected.Parent.Parent.Text;
  LabProcess.Caption := TreePC.Selected.Parent.Text;
  LabTerminal.Caption := TreePC.Selected.Text;
end;

procedure TfStation.sbtnSaveClick(Sender: TObject);
Var sPdLineID,sPdLineName : String;
    sProcessID,sProcessName,sProcessCode,sProcessDesc : String;
    sTerminalID,sTerminalName : String;
    S : String;
begin
  If LabTerminal.Caption = '' Then
  begin
      MessageDlg('Work Terminal Not Assign !! ',mtError, [mbCancel],0);
      Exit;
  end;

  if cmbOpType.ItemIndex = 0 then
  begin
      MessageDlg('Operate Type Not Assign !! ',mtError, [mbCancel],0);
      Exit;
  end;

  sPdLineID := '';
  sPdLineName := LabPdLine.Caption;
  If not GetPdLineData(sPdLineName,sPdLineID) Then
      Exit;

  sProcessID := '';
  sProcessName := LabProcess.Caption;
  If not GetProcessData(sProcessName,sProcessID,sProcessCode,sProcessDesc) Then
      Exit;

  sTerminalID := '';
  sTerminalName := LabTerminal.Caption;
  If not GetTerminalData(sTerminalName, sPdLineID, sProcessID, sTerminalID) Then
      Exit;

  With TIniFile.Create('SAJET.ini') do
  begin
      WriteString('System','Factory', FCID);
      WriteString('TGS Setup','Terminal',sTerminalID);
      WriteString('TGS Setup','PdlineID',sPdLineID);
      WriteString('TGS Setup','TypeID',trim(cmbOpid.Text));
      Free;
  end;
  SaveToDb;

  fData.TerminalID := sTerminalID;
  fData.FcID := FCID;
  Close;

end;

procedure TfStation.TreePCGetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := Node.Level;
end;

procedure TfStation.ShowOperateType;
begin
  cmbOpType.Items.Clear;
  cmbOpId.Items.Clear;
  With fData.QryTemp do
  begin
     Close;
     Params.Clear;
     CommandText := 'Select operate_id,Type_name from sajet.sys_operate_type where Is_TGSControl=''Y'' ';
     Open;
     If RecordCount > 0 Then
     begin
        cmbOpType.Items.Add('Not Assigned ');
        cmbOpid.Items.Add('0');
        while not eof do
        begin
           cmbOpType.Items.Add(Fieldbyname('Type_name').AsString);
           cmbOpid.Items.Add(Fieldbyname('operate_id').AsString);
           next;
        end;
     end;
     Close;
  end;
end;

procedure TfStation.cmbOpTypeChange(Sender: TObject);
begin
  cmbOpID.ItemIndex := cmbOpType.ItemIndex;
  showTerminal;
end;

procedure TfStation.chkShowAllClick(Sender: TObject);
begin
  ShowTerminal;
end;

end.
