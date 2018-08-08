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
    cmbSN: TComboBox;
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
    Label2: TLabel;
    LabTerminal: TLabel;
    ImageAll: TImage;
    edtWO: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lblErrorProcess: TLabel;
    Label7: TLabel;
    lblErrorCode: TLabel;
    lblInputProcess: TLabel;
    lblStatus: TLabel;
    lblPrompt: TLabel;
    Label6: TLabel;
    chkWO: TCheckBox;
    chkNewWo: TCheckBox;
    Label8: TLabel;
    Label9: TLabel;
    LabQty: TLabel;
    MsgPanel: TPanel;
    Label10: TLabel;
    procedure FormShow(Sender: TObject);
    procedure edtWOKeyPress(Sender: TObject; var Key: Char);
    procedure edtWOChange(Sender: TObject);
    procedure cmbSNKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }

  public
    { Public declarations }
    UpdateUserID:string;
    gbSN,sWO,sPN,mPartID,sRouteID,sProcessID,sTerminalID,sFcID:string;
    dtOutTime:Tdatetime;
    process_code:integer;
    IsChkWO,IsNewWo:Boolean;
    FcID: string;
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
    sTerminalID := ReadString('Repair', 'Terminal', '');
    Free;
  end;

  if sTerminalID = '' then
  begin
    MessageDlg('Terminal not be assign !!', mtError, [mbCancel], 0);
    Exit;
  end;

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'Select A.TERMINAL_NAME,B.PROCESS_NAME, a.PROCESS_ID '
      + '       ,A.PDLINE_ID,a.Stage_ID '
      + 'From SAJET.SYS_TERMINAL A,'
      + '     SAJET.SYS_PROCESS B '
      + 'Where A.TERMINAL_ID = :TERMINALID '
      + 'AND A.PROCESS_ID = B.PROCESS_ID ';
    Params.ParamByName('TERMINALID').AsString := sTerminalID;
    Open;

    if RecordCount <= 0 then
    begin
      Close;
      MessageDlg('Terminal data error !!', mtError, [mbCancel], 0);
      Exit;
    end;
    //PDLineId := Fieldbyname('PDLINE_ID').AsString;
    //ProcessId := Fieldbyname('PROCESS_ID').AsString;
    //StageID := Fieldbyname('Stage_ID').AsString;
    LabTerminal.Caption := Fieldbyname('PROCESS_NAME').AsString + ' ' +
      Fieldbyname('TERMINAL_NAME').AsString;
    Close;
  end;
  Result := True;
end;

procedure TfRepair.FormShow(Sender: TObject);
begin
    GetTerminalID;

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
    end;

    chkWO.Checked :=IsChkWO;
    chkNewWO.Checked :=IsNewWO;
    edtWO.SetFocus;
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
       params.ParamByName('Tterminalid').AsString :=sTerminalID;
       params.ParamByName('tempid').AsString :=updateUserID;
       // params.ParamByName('tdefect').AsString := '';
       execute;
       sRes := params.ParamByName('TRes').AsString ;
       lblErrorProcess.Caption :=Params.parambyName('tprocess').AsString;
       lblErrorCode.Caption := Params.parambyName('TDEFECT').AsString;
       MsgPanel.Caption :=sRes;
       if sRes = 'OK' then begin
           MsgPanel.Color :=clGreen;
           LabQty.Caption := IntToStr(strToInt(LabQty.Caption)+1);
       end else begin
           MsgPanel.Color :=clRed;
       end;
       cmbSN.SetFocus;
       cmbSN.SelectAll;

   end;

end;

end.
