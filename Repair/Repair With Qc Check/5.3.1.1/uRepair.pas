unit uRepair;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db,
  DBClient, MConnect, SConnect, IniFiles, ImgList, ObjBrkr, Menus, Variants;

type
  TfRepair = class(TForm)
    Panel1: TPanel;
    LabelPacking: TLabel;
    Label1: TLabel;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    AddDefect1: TMenuItem;
    DeleteDfect1: TMenuItem;
    RepairRecord1: TMenuItem;
    N1: TMenuItem;
    Scrap1: TMenuItem;
    Finish1: TMenuItem;
    QryReplace: TClientDataSet;
    QryRepair: TClientDataSet;
    editRepairer: TEdit;
    sbtnRepairer: TSpeedButton;
    labRPName: TLabel;
    Label12: TLabel;
    Label11: TLabel;
    Label14: TLabel;
    ImageAll: TImage;
    lblInputProcess: TLabel;
    lblStatus: TLabel;
    lblPrompt: TLabel;
    pgc1: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    tbc1: TTabControl;
    tbc2: TTabControl;
    Label4: TLabel;
    edtWO: TEdit;
    Label2: TLabel;
    cmbSN: TComboBox;
    chkNewWo: TCheckBox;
    chkWO: TCheckBox;
    Label8: TLabel;
    Label9: TLabel;
    lblErrorProcess: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    lblErrorCode: TLabel;
    Label13: TLabel;
    edtSN: TEdit;
    Label10: TLabel;
    MsgPanel: TPanel;
    MsgPanelOut: TPanel;
    Label6: TLabel;
    LabQty: TLabel;
    Label15: TLabel;
    LabQtyOut: TLabel;
    Label3: TLabel;
    LabTerminalIn: TLabel;
    LabTerminalOut: TLabel;
    Label17: TLabel;
    cmbProcessIn: TComboBox;
    cmbTerminalIn: TComboBox;
    Label16: TLabel;
    Label18: TLabel;
    cmbProcessOut: TComboBox;
    Label19: TLabel;
    cmbTerminalOut: TComboBox;
    Label20: TLabel;
    cmbLineIn: TComboBox;
    Label21: TLabel;
    cmbLineOut: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure edtWOKeyPress(Sender: TObject; var Key: Char);
    procedure edtWOChange(Sender: TObject);
    procedure cmbSNKeyPress(Sender: TObject; var Key: Char);
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
    procedure pgc1Change(Sender: TObject);
    procedure t(Sender: TObject);
    procedure cmbLineInSelect(Sender: TObject);
    procedure cmbLineOutSelect(Sender: TObject);
    procedure cmbProcessOutSelect(Sender: TObject);
    procedure cmbProcessInSelect(Sender: TObject);
    procedure cmbTerminalInSelect(Sender: TObject);
    procedure cmbTerminalOutSelect(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
    UpdateUserID:string;
    gbSN,sWO,sPN,mPartID,sRouteID,sProcessID,sTerminalInID,sTerminalOutID,sFcID:string;
    sProcessIn,sProcessOut,sTerminalIn,sTerminalOut:String;
    sPDLineInId,sPDLineOutId:string;
    dtOutTime:Tdatetime;
    process_code:integer;
    IsChkWO,IsNewWo:Boolean;
    FcID: string;
    iCount,iCountOut :Integer;
    function GetSysTime: TDateTime;
    function GetTerminalID: Boolean;
    function GetEmpNo(psUserID: string): string;
    function GetEmpName(psUserID: string): string;
    function CheckWO(sWO:string):string;

  end;

var
  fRepair: TfRepair;
 
implementation


{$R *.DFM}

function TfRepair.GetSysTime: TDateTime;
begin
   with QryTemp do
   begin
      //gbSN := cmbSN.Text;
      Close;
      Params.Clear;
      CommandText := 'select sysdate datetime from dual';
      open;
      result := fieldbyname('datetime').AsDateTime;

   end;

end;



function TfRepair.GetEmpNo(psUserID: string): string;
begin
  Result := '0';

  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select EMP_NO '
      + '  From SAJET.SYS_EMP '
      + ' Where EMP_ID = ' + psUserID;
    Open;
    Result := FieldByName('Emp_No').AsString;
    Close;
  end;

end;

function TfRepair.GetTerminalID: Boolean;
begin
  Result := False;

  with TIniFile.Create('SAJET.ini') do
  begin
    FcID := ReadString('System', 'Factory', '');
    sTerminalInID := ReadString('Repair', 'Terminal In', '');
    sTerminalOutID := ReadString('Repair', 'Terminal Out', '');
    Free;
  end;

  if sTerminalInID = '' then
  begin
    MessageDlg('Repair In Terminal not be assign !!', mtError, [mbCancel], 0);
    Exit;
  end;

  if sTerminalOutID = '' then
  begin
    MessageDlg('Repair Out Terminal not be assign !!', mtError, [mbCancel], 0);
    Exit;
  end;

  with QryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'Select C.PDLINE_NAME,A.TERMINAL_NAME,B.PROCESS_NAME, a.PROCESS_ID '
      + '     ,A.PDLINE_ID,a.Stage_ID From SAJET.SYS_TERMINAL A,'
      + '     SAJET.SYS_PROCESS B ,SAJET.SYS_PDLINE C '
      + 'Where A.TERMINAL_ID = :TERMINALID AND A.PDLINE_ID=C.PDLINE_ID '
      + 'AND A.PROCESS_ID = B.PROCESS_ID and a.enabled=''Y'' ';
    Params.ParamByName('TERMINALID').AsString := sTerminalInID;
    Open;

    if RecordCount <= 0 then
    begin
      Close;
      MessageDlg('Repair In Terminal data error !!', mtError, [mbCancel], 0);
      Exit;
    end;
    sPDLineInId := Fieldbyname('PDLINE_ID').AsString;
    cmbLineIn.ItemIndex := cmbLineIn.Items.IndexOf( Fieldbyname('PDLINE_NAME').AsString);
    cmbLineIn.OnSelect(nil);
    sProcessIn := Fieldbyname('PROCESS_Name').AsString;
    cmbProcessIn.ItemIndex := cmbProcessIn.Items.IndexOf(sProcessIn);
    cmbProcessIn.OnSelect(nil);
    sTerminalIn := Fieldbyname('Terminal_Name').AsString;
    cmbTerminalIn.ItemIndex := cmbTerminalIn.Items.IndexOf(sTerminalIn);
    LabTerminalIn.Caption := sProcessIn + '\' +sTerminalIn;

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'Select C.PDLINE_NAME,A.TERMINAL_NAME,B.PROCESS_NAME, a.PROCESS_ID '
      + '     ,A.PDLINE_ID,a.Stage_ID From SAJET.SYS_TERMINAL A,'
      + '     SAJET.SYS_PROCESS B ,SAJET.SYS_PDLINE C '
      + 'Where A.TERMINAL_ID = :TERMINALID AND A.PDLINE_ID=C.PDLINE_ID '
      + 'AND A.PROCESS_ID = B.PROCESS_ID and a.enabled=''Y'' ';
    Params.ParamByName('TERMINALID').AsString := sTerminalOutID;
    Open;

    if RecordCount <= 0 then
    begin
      Close;
      MessageDlg('Repair In Terminal data error !!', mtError, [mbCancel], 0);
      Exit;
    end;
    sPDLineOutId := Fieldbyname('PDLINE_ID').AsString;
    cmbLineOut.ItemIndex := cmbLineOut.Items.IndexOf( Fieldbyname('PDLINE_NAME').AsString);
    cmbLineOut.OnSelect(nil);
    sProcessOut := Fieldbyname('PROCESS_Name').AsString;
    cmbProcessOut.ItemIndex := cmbProcessOut.Items.IndexOf(sProcessOut);
    cmbProcessOut.OnSelect(nil);
    sTerminalOut := Fieldbyname('Terminal_Name').AsString;
    cmbTerminalOut.ItemIndex := cmbTerminalOut.Items.IndexOf(sTerminalOut);
    LabTerminalOut.Caption := sProcessOut + '\' +sTerminalOut;
  end;
  Result := True;
end;

procedure TfRepair.FormShow(Sender: TObject);
begin


    gbSN := '';
    if UpdateUserID <> '0' then
    begin
        editRepairer.Text := GetEmpNo(UpdateUserID);
        labRPName.Caption := GetEmpName(UpdateUserID);
    end;

    with Qrytemp do
    begin
        close;
        Params.CreateParam(ftstring,'PNAME',ptinput);
        commandtext :=' select param_Value from  SAJET.sys_base WHERE  Param_Name =:PNAME';
        Params.parambyname('PNAME').AsString := 'Repair In Check WO ';
        Open;
        if FieldByName('param_Value').AsString ='Y' then
            IsChkWo :=True
        else
            IsChkWo :=false;

        close;
        Params.CreateParam(ftstring,'PNAME',ptinput);
        commandtext :=' select param_Value from  SAJET.sys_base WHERE  Param_Name =:PNAME';
        Params.parambyname('PNAME').AsString := 'Repair In New WO ';
        Open;
        if FieldByName('param_Value').AsString ='Y'  then
            IsNewWo :=True
        else
            IsNewWo :=false;

        close;
        commandtext :=' select c.pdline_name from  SAJET.sys_terminal a,sajet.sys_Process b,sajet.sys_pdline c '+
                      ' WHERE b.operate_id=4   AND Upper(b.PROCESS_DESC)=''IN'' and a.process_id=b.process_id '+
                      ' and a.enabled=''Y'' and a.pdline_id=c.pdline_id';
        Open;

        First;
        cmbLineIn.Items.Clear;
        cmbLineIn.Style := csDropDownList;
        while not Eof do begin
            cmbLineIn.Items.Add(fieldByName('pdline_name').AsString );
            Next;
        end;
        
        close;
        commandtext :=' select c.pdline_name from  SAJET.sys_terminal a,sajet.sys_Process b,sajet.sys_pdline c '+
                      ' WHERE b.operate_id=4   AND Upper(b.PROCESS_DESC)=''OUT'' and a.process_id=b.process_id '+
                      ' and a.enabled=''Y'' and a.pdline_id=c.pdline_id';
        Open;

        First;
        cmbLineOut.Items.Clear;
        cmbLineOut.Style := csDropDownList;
        while not Eof do begin
            cmbLineOut.Items.Add(fieldByName('pdline_name').AsString );
            Next;
        end;

    end;

    GetTerminalID;
    iCount:=0;
    iCountOut :=0;
    chkWO.Checked :=IsChkWO;
    chkNewWO.Checked :=IsNewWO;
    if pgc1.ActivePage = ts1 then
    begin
       edtWO.SetFocus;
    end else
    if pgc1.ActivePage = ts2 then  begin
       edtSN.SetFocus;
    end;
end;

function TfRepair.GetEmpName(psUserID: string): string;
begin
  Result := '0';

  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select EMP_Name '
      + '  From SAJET.SYS_EMP '
      + ' Where EMP_ID = ' + psUserID;
    Open;
    Result := FieldByName('EMP_Name').AsString;
    Close;
  end;

end;

function TfRepair.CheckWO(sWO:string):string;
begin
try
  Result := 'Check WO Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.Sj_Chk_Wo_Input');
      FetchParams;
      Params.ParamByName('TREV').AsString := sWO;
      Execute;
      Result := Params.ParamByName('TRES').AsString;
    finally
      Close;
    end;
  end;
except on e:Exception do
  begin
    Result := 'CheckWO error : ' + e.Message;
  end;
end;
end;

procedure TfRepair.edtWOKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
    if Key <>#13 then exit;

    if  not IsNewWo then
        with Qrytemp do
        begin
            close;
            Params.CreateParam(ftstring,'SERIAL_NUMBER',ptinput);
            commandtext :=' select work_order,serial_number from  SAJET.G_SN_STATUS WHERE  SERIAL_NUMBER=:SERIAL_NUMBER or Customer_sn=:SERIAL_NUMBER ';
            Params.parambyname('SERIAL_NUMBER').AsString := edtWO.Text;
            Open;
            if not IsEmpty then
               edtWO.Text :=fieldByName('work_order').AsString;
        end;
     edtWO.Text :=Trim(edtWO.Text);
     // Add RMA 工單
     if IsNewWo then
         if Copy(edtWO.Text,1,2) <>'RM' then
         begin
            MessageDlg('不是RMA工單',mterror,[mbok],0);
            exit;
         end;

     iResult:= CheckWO(Trim(edtWO.Text));
     MsgPanel.Caption :=iResult;
     if iResult = 'OK' then begin
         MsgPanel.Color :=clGreen;
         cmbSN.Enabled :=true;
         cmbSN.SetFocus;
     end else begin
         MsgPanel.Color :=clRed;
         cmbSN.Enabled :=false;
         edtWO.SelectAll;
     end;

end;

procedure TfRepair.edtWOChange(Sender: TObject);
begin
    cmbSN.Enabled :=false;
end;

procedure TfRepair.cmbSNKeyPress(Sender: TObject; var Key: Char);
var sRes:string;
begin
   if Key <> #13 then exit;


   with sproc do begin
       close;
       datarequest('sajet.CCM_SN_REPAIR_IN');
       fetchparams;
       params.ParamByName('TWO').AsString :=edtWO.Text;
       params.ParamByName('TSN').AsString :=cmbSN.Text;
       if IsNewWo then
          params.ParamByName('TNewWOFlag').AsString := 'Y'
       else  params.ParamByName('TNewWO').AsString := 'N';

       if IsChkWO then
          params.ParamByName('TCHECKWO').AsString :=  'Y'
       else
          params.ParamByName('TCHECKWO').AsString := 'N';
       params.ParamByName('Tterminalid').AsString := sTerminalInID;
       params.ParamByName('tempid').AsString :=updateUserID;
       // params.ParamByName('tdefect').AsString := '';
       execute;
       sRes := params.ParamByName('TRes').AsString ;
       lblErrorProcess.Caption :=Params.parambyName('tprocess').AsString;
       lblErrorCode.Caption := Params.parambyName('TDEFECT').AsString;
       MsgPanel.Caption :=sRes;
       if sRes = 'OK' then begin
           MsgPanel.Color :=clGreen;
           inc(iCount);
           LabQty.Caption := IntToStr(iCount);
       end else begin
           MsgPanel.Color :=clRed;
       end;
       cmbSN.SetFocus;
       cmbSN.SelectAll;

   end;

end;

procedure TfRepair.edtSNKeyPress(Sender: TObject; var Key: Char);
var iResult,sWO:String;
Tartget_qty,Qty:Integer;
begin
if Key <> #13 then exit;
   if length(edtsn.Text)=0 then exit;

   QryTemp.Close;
   QryTemp.Params.Clear;
   QryTEmp.Params.CreateParam(ftstring,'SN',ptInput)  ;
   QryTemp.CommandText :='Select * from sajet.g_sn_status where serial_number =:SN or customer_sn =:SN';
   QryTemp.Params.ParamByName('SN').AsString :=edtSN.Text;
   QryTemp.Open;

   if  QryTemp.IsEmpty then
   begin
       MsgPanelOut.Caption :='NO SN';
       MsgPanelOut.Color :=clRed;
       edtSN.Text :='';
       edtSN.SetFocus;
       exit;
   end;

   Sproc.Close;
   Sproc.DataRequest('SAJET.CCM_SN_REPAIR_OUT') ;
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TTERMINALID').AsString :=sTerminalOutID;
   Sproc.Params.ParamByName('TSN').AsString :=edtSN.Text;
   Sproc.Params.ParamByName('TEMPID').AsString :=UpdateUserID;
   Sproc.Execute;
   iResult := Sproc.Params.parambyname('TRES').AsString;

   if iResult ='OK' then begin
      MsgPanelOut.Caption :='OK';
      MsgPanelOut.Color :=clGreen;
      edtSN.SetFocus;
      edtSN.Text :='';
      Inc(iCountOut);
      LabQtyOut.Caption :='掃描數:'+IntToStr(iCountOut);
   end else begin
      MsgPanelOut.Caption :=iResult;
      MsgPanelOut.Color :=clRed;
      edtSN.Text :='';
      edtSN.SetFocus;
   end;

end;

procedure TfRepair.pgc1Change(Sender: TObject);
begin
   if pgc1.ActivePage = ts1 then
   begin
       edtWO.SetFocus;
      
   end else
   if pgc1.ActivePage = ts2 then  begin
       edtSN.SetFocus;
   end;
end;

procedure TfRepair.t(Sender: TObject);
begin
    with QryTemp do begin
        close;
        Params.CreateParam(ftstring,'Process',ptinput);
       // Params.CreateParam(ftstring,'Process',ptinput);
        commandtext :=' select param_Value from  SAJET.sys_base WHERE  Param_Name =:Process';
        Params.parambyname('Process').AsString := 'Repair In New WO ';
       // Params.parambyname('Process').AsString := 'Repair In New WO ';
        Open;
    end;
end;

procedure TfRepair.cmbLineInSelect(Sender: TObject);
begin
    with QryTemp do begin
        close;
        Params.Clear;
        Params.CreateParam(ftString,'pdline_name',ptInput);
        commandtext :=' select distinct b.process_name from  SAJET.sys_terminal a,sajet.sys_Process b,sajet.sys_pdline c '+
                      ' WHERE b.operate_id=4   AND Upper(b.PROCESS_DESC)=''IN'' and a.process_id=b.process_id '+
                      ' and a.enabled=''Y'' and a.pdline_id=c.pdline_id  and c.pdline_Name=:pdline_Name';
        Params.ParamByName('pdline_name').AsString := cmbLineIn.Items.Strings[cmbLineIn.ItemIndex];
        Open;

        First;
        cmbProcessin.Items.Clear;
        cmbProcessin.Style := csDropDownList;
        while not Eof do begin
            cmbProcessin.Items.Add(fieldByName('process_Name').AsString );
            Next;
        end;

    end;
end;

procedure TfRepair.cmbLineOutSelect(Sender: TObject);
begin
    with QryTemp do begin
        close;
        Params.Clear;
        Params.CreateParam(ftString,'pdline_name',ptInput);
        commandtext :=' select distinct b.process_name from  SAJET.sys_terminal a,sajet.sys_Process b,sajet.sys_pdline c '+
                      ' WHERE b.operate_id=4   AND Upper(b.PROCESS_DESC)=''OUT'' and a.process_id=b.process_id '+
                      ' and a.enabled=''Y'' and a.pdline_id=c.pdline_id  and c.pdline_Name=:pdline_Name';
        Params.ParamByName('pdline_name').AsString := cmbLineOut.Items.Strings[cmbLineOut.ItemIndex];
        Open;

        First;
        cmbProcessOut.Items.Clear;
        cmbProcessOut.Style := csDropDownList;
        while not Eof do begin
            cmbProcessOut.Items.Add(fieldByName('process_Name').AsString );
            Next;
        end;

    end;

end;

procedure TfRepair.cmbProcessOutSelect(Sender: TObject);
begin
    with QryTemp do begin
        close;
        Params.Clear;
        Params.CreateParam(ftString,'pdline_name',ptInput);
        Params.CreateParam(ftString,'process_name',ptInput);
        commandtext :=' select distinct a.terminal_Name from  SAJET.sys_terminal a,sajet.sys_Process b,sajet.sys_pdline c '+
                      ' WHERE b.operate_id=4   AND Upper(b.PROCESS_DESC)=''OUT'' and a.process_id=b.process_id '+
                      ' and a.enabled=''Y'' and a.pdline_id=c.pdline_id  and c.pdline_Name=:pdline_Name'+
                      ' and b.process_name=:process_name ';
        Params.ParamByName('pdline_name').AsString := cmbLineOut.Items.Strings[cmbLineOut.ItemIndex];
        Params.ParamByName('process_name').AsString := cmbProcessOut.Items.Strings[cmbProcessOut.ItemIndex];
        Open;

        First;
        cmbTerminalOut.Items.Clear;
        cmbTerminalOut.Style := csDropDownList;
        while not Eof do begin
            cmbTerminalOut.Items.Add(fieldByName('terminal_Name').AsString );
            Next;
        end;

    end;
end;

procedure TfRepair.cmbProcessInSelect(Sender: TObject);
begin
     with QryTemp do begin
        close;
        Params.Clear;
        Params.CreateParam(ftString,'pdline_name',ptInput);
        Params.CreateParam(ftString,'process_name',ptInput);
        commandtext :=' select distinct a.terminal_Name from  SAJET.sys_terminal a,sajet.sys_Process b,sajet.sys_pdline c '+
                      ' WHERE b.operate_id=4   AND Upper(b.PROCESS_DESC)=''IN'' and a.process_id=b.process_id '+
                      ' and a.enabled=''Y'' and a.pdline_id=c.pdline_id  and c.pdline_Name=:pdline_Name '+
                      ' and b.process_name=:process_name ';
        Params.ParamByName('pdline_name').AsString := cmbLineIn.Items.Strings[cmbLineIn.ItemIndex];
        Params.ParamByName('process_name').AsString := cmbProcessIn.Items.Strings[cmbProcessIn.ItemIndex];
        Open;

        First;
        cmbTerminalIn.Items.Clear;
        cmbTerminalIn.Style := csDropDownList;
        while not Eof do begin
            cmbTerminalIn.Items.Add(fieldByName('terminal_Name').AsString );
            Next;
        end;

    end;
end;

procedure TfRepair.cmbTerminalInSelect(Sender: TObject);
begin
     LabTerminalIn.Caption := cmbProcessIn.Items.Strings[cmbProcessIn.ItemIndex]+'\'+
                              cmbTerminalIn.Items.Strings[cmbTerminalIn.ItemIndex];
     with QryTemp do begin
         close;
         Params.Clear;
         Params.CreateParam(ftString,'pdline_name',ptInput);
         Params.CreateParam(ftString,'process_name',ptInput);
         Params.CreateParam(ftString,'Terminal_Name',ptInput);
         commandtext :=' select a.terminal_id from  SAJET.sys_terminal a,sajet.sys_Process b,sajet.sys_pdline c '+
                      ' WHERE b.operate_id=4   AND Upper(b.PROCESS_DESC)=''IN'' and a.process_id=b.process_id '+
                      ' and a.enabled=''Y'' and a.pdline_id=c.pdline_id  and c.pdline_Name=:pdline_Name '+
                      ' and b.process_name=:process_name and a.terminal_Name =:terminal_Name';
         Params.ParamByName('pdline_name').AsString := cmbLineIn.Items.Strings[cmbLineIn.ItemIndex];
         Params.ParamByName('process_name').AsString := cmbProcessIn.Items.Strings[cmbProcessIn.ItemIndex];
         Params.ParamByName('terminal_Name').AsString := cmbTerminalIn.Items.Strings[cmbTerminalIn.ItemIndex];
         Open;
         sTerminalInID := FieldByName('terminal_id').AsString;
     end;

     with TIniFile.Create('SAJET.ini') do
     begin
         WriteString('Repair','Terminal In',sTerminalInID);
         Free;
     end;
     edtWO.SetFocus;
end;

procedure TfRepair.cmbTerminalOutSelect(Sender: TObject);
begin
     LabTerminalOut.Caption := cmbProcessOut.Items.Strings[cmbProcessOut.ItemIndex]+'\'+
                              cmbTerminalOut.Items.Strings[cmbTerminalOut.ItemIndex];
     with QryTemp do begin
         close;
         Params.Clear;
         Params.CreateParam(ftString,'pdline_name',ptInput);
         Params.CreateParam(ftString,'process_name',ptInput);
         Params.CreateParam(ftString,'Terminal_Name',ptInput);
         commandtext :=' select a.terminal_id from  SAJET.sys_terminal a,sajet.sys_Process b,sajet.sys_pdline c '+
                      ' WHERE b.operate_id=4   AND Upper(b.PROCESS_DESC)=''OUT'' and a.process_id=b.process_id '+
                      ' and a.enabled=''Y'' and a.pdline_id=c.pdline_id  and c.pdline_Name=:pdline_Name '+
                      ' and b.process_name=:process_name and a.terminal_Name =:terminal_Name';
         Params.ParamByName('pdline_name').AsString := cmbLineOut.Items.Strings[cmbLineOut.ItemIndex];
         Params.ParamByName('process_name').AsString := cmbProcessOut.Items.Strings[cmbProcessOut.ItemIndex];
         Params.ParamByName('terminal_Name').AsString := cmbTerminalOut.Items.Strings[cmbTerminalOut.ItemIndex];
         Open;
         sTerminalOutID := FieldByName('terminal_id').AsString;
     end;
    { with TIniFile.Create('SAJET.ini') do
  begin
    FcID := ReadString('System', 'Factory', '');
    sTerminalInID := ReadString('Repair', 'Terminal In', '');
    sTerminalOutID := ReadString('Repair', 'Terminal Out', '');
    Free;
  end;}
     with TIniFile.Create('SAJET.ini') do
     begin
         WriteString('Repair','Terminal Out',sTerminalOutID);
         Free;
     end;
     edtSN.SetFocus;
end;

end.
