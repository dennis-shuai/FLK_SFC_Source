unit uCMInput;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles,Comobj,Tlhelp32;

type
  TfCMInput = class(TForm)
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
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    editWO: TEdit;
    editCustomer: TEdit;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    Label1: TLabel;
    labPartNo: TLabel;
    Label7: TLabel;
    labTargetQty: TLabel;
    Label8: TLabel;
    labInputQty: TLabel;
    lblColor: TLabel;
    lbl1: TLabel;
    editDefect: TEdit;
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure editWOKeyPress(Sender: TObject; var Key: Char);
    procedure editCustomerKeyPress(Sender: TObject; var Key: Char);
    procedure labWODblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure editDefectKeyPress(Sender: TObject; var Key: Char);
  private
    //m_SNDefectLevel: String;
    function CheckWO(sWO:string):string;
    function CheckCarrier(sCarrier:string;var iCarrierCount:Integer):string;
    function CheckCustomer(sTerminal,sEmp,sWO,sCarrier,sCustomer:string):string;

    function GetTerminalName(sTerminalID:string):string;
  public
    UpdateUserID ,sEMP_NO,sPDlineID,sStageID,sProcessID: String;
    PrintFile,iTerminal:string;
    isStart,IsOpen:boolean;
    BarApp,BarDoc,BarVars:variant;
    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
  end;

var
  fCMInput: TfCMInput;



implementation

uses uLogin;


{$R *.dfm}



function KillTask(ExeFileName: string): integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOLean;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
        OpenProcess(PROCESS_TERMINATE,
        BOOL(0),
        FProcessEntry32.th32ProcessID),
        0));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

function TfCMInput.CheckWO(sWO:string):string;
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

function TfCMInput.GetTerminalName(sTerminalID:string):string;
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

function TfCMInput.CheckCarrier(sCarrier:string;var iCarrierCount:Integer):string;
begin
try
  Result := 'Check Carrier Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.Sj_Chk_Carrier');
      FetchParams;
      Params.ParamByName('TREV').AsString := sCarrier;
      Execute;
      iCarrierCount := Params.ParamByName('TCARRIERCOUNT').AsInteger;
      Result := Params.ParamByName('TRES').AsString;
      
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

function TfCMInput.CheckCustomer(sTerminal,sEmp,sWO,sCarrier,sCustomer:string):string;
begin
  try
  Result := 'Check Panel Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.Sj_Chk_Carrier_Customer2');
      FetchParams;
      Params.ParamByName('TTERMINAL').AsString := sTerminal;
      Params.ParamByName('TEMP').AsString := sEmp;
      Params.ParamByName('TWO').AsString := sWO ;
      Params.ParamByName('TCARRIER').AsString := sCarrier;
      Params.ParamByName('TREV').AsString := sCustomer;
      Execute;
      Result := Params.ParamByName('TRES').AsString;
    finally
      Close;
    end;
  end;
except on e:Exception do
  begin
    Result := 'CheckCustomer error : ' + e.Message;
  end;
end;
end;

procedure TfCMInput.ShowMSG(sShowHead,sShowResult,sNextMsg:string);
var sShowData:string;
begin
  if sShowResult = 'OK' then
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



procedure TfCMInput.FormShow(Sender: TObject);
Var DestRect,SurcRect : TRect; Bmp : TBitmap;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;

  Bmp.Free;


  editWO.SetFocus;
  editWO.Text := '';

  labTerminal.Caption :='TERMINAL:    '+ GetTerminalName(iTerminal);

   isStart :=false;
   IsOpen :=false;
   KillTask('lppa.exe');
    try
      BarApp := CreateOleObject('lppx.Application');
    except
      Application.MessageBox('›]¨S¦³¦w¸Ëcodesoft³nÅé','¿ù»~',MB_OK+MB_ICONERROR);
      isStart:=false;
      Exit;
   end;
   IsStart :=true;

   

end;



procedure TfCMInput.Image2Click(Sender: TObject);
begin
   Close;
end;


procedure TfCMInput.editWOKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
  if Key = #13 then
  begin
    if iTerminal = '' then
    begin
      MessageDlg('please input Terminal information!',mtError,[mbOK],0);
      Exit;
    end;

    iResult := CheckWO(Trim(editWO.Text));

    if iResult = 'OK' then
    begin

      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WO',ptInput);
        CommandText := 'Select P.PART_NO,TARGET_QTY,INPUT_QTY FROM  SAJET.G_WO_BASE W'
                     + ' Left outer join SAJET.SYS_PART P ON W.MODEL_ID=P.PART_ID '
                     + ' WHERE W.WORK_ORDER = :WO';
        Params.ParamByName('WO').AsString := Trim(editWO.Text);
        Open;

        labPartNo.Caption := FieldByName('PART_NO').AsString;
        labTargetQty.Caption := FieldByName('TARGET_QTY').AsString;
        labInputQty.Caption := FieldByName('INPUT_QTY').AsString;
      end;

      if QryTemp.FieldByName('INPUT_QTY').AsInteger >= QryTemp.FieldByName('TARGET_QTY').AsInteger then
      begin
        ShowMSG('Work Order input : ','Error','WO InputQty >= TargetQty');
        editWO.SelectAll;
        editWO.SetFocus;
        exit;
      end
      else
      begin
         PrintFile :=GetCurrentDir+'\\'+'S_'+labPartNo.Caption+'.Lab';
         If not FileExists( PrintFile) then
         begin
               msgPanel.Caption := 'Label ÀÉ®×¤£¦s¦b';
               msgPanel.Color :=clRed;
               editWO.SelectAll;
               editWO.SetFocus;
               IsOpen :=false;
               Exit;
          end;
          if IsStart then begin
             try
                BarApp.Visible:=false;
                BarDoc:=BarApp.ActiveDocument;
                BarVars:=BarDoc.Variables;
                BarDoc.Open(PrintFile);
                IsOpen :=true;
              except
                 msgPanel.Caption := '¥´¶}ÀÉ®×¿ù»~';
                 msgPanel.Color :=clRed;
                 IsOpen :=false;
                 exit;
              end;

          end;

          ShowMSG('Work Order input : ',iResult,'½Ð¿é¤J±ø½X!');
          editCustomer.Text := '';
          editCustomer.SetFocus;
          if Copy(labPartNo.Caption,11,4) = '0080' then begin
              lblColor.Color := clRed;
              msgpanel.Caption :='½Ð±½´y¬õ¦â²£«~ ';
              msgPanel.Color :=clGreen;
          end;
          if Copy(labPartNo.Caption,11,4) = '0180' then begin
              lblColor.Color := clWhite;
              msgpanel.Caption :='½Ð±½´y¥Õ¦â²£«~ ';
              msgPanel.Color :=clGreen;
          end;
          if Copy(labPartNo.Caption,11,4) = '0280' then begin
              lblColor.Color := clBlack;
              msgpanel.Caption :='½Ð±½´y¶Â¦â²£«~ ';
              msgPanel.Color :=clGreen;
          end;
          editWO.Enabled := False;

      end;
    end
    else
    begin
      ShowMSG('Work Order input : ',iResult,'Please input Work order again!');
      editWO.SelectAll;
      editWO.SetFocus;
      exit;
    end;
  end;
end;

procedure TfCMInput.editCustomerKeyPress(Sender: TObject; var Key: Char);
var iResult,sMatchWO,wo_LOT,sn_LOT,SWO:string;
begin

  if  Key <>#13 then exit;
  if  editCustomer.Text ='' then exit;

  if editDefect.Text = '' then
  begin

       Sproc.Close;
       Sproc.DataRequest('SAJET.CCM_SN_2WO_INPUT');
       Sproc.FetchParams;
       Sproc.Params.ParamByName('TWO').AsString := editWO.Text ;
       Sproc.Params.ParamByName('TREV').AsString := editCustomer.Text;
       Sproc.Params.ParamByName('TEMPID').AsString := UPDATEUSERID;
       Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal ;
       Sproc.Execute;

       iResult := Sproc.Params.ParamByName('TRES').AsString;
   
       if iResult <> 'OK' then begin
          with qrytemp do begin
              Close;
              Params.Clear;
              Params.CreateParam(ftString,'SN',ptInput);
              CommandText := 'SELECT B.PROCESS_CODE FROM SAJET.G_SN_STATUS A,SAJET.SYS_PROCESS B '+
                             ' WHERE (A.Serial_number =:SN or A.CUSTOMER_SN =:SN)'+
                             ' and B.PROCESS_ID = A.PROCESS_ID ';
              Params.ParamByName('SN').AsString :=editCustomer.Text;
              Open;
              if Not IsEmpty then begin

                   fLogin := TfLogin.Create(Self);
                   if fLogin.ShowModal = mrOK then
                   begin
                        if (IsStart) and (IsOpen) then
                        begin
                             try
                                 BarDoc.Variables.Item('SN').Value :=  UpperCase(Trim(editCustomer.Text));
                                 Bardoc.PrintLabel(1);
                                 Bardoc.FormFeed;

                                 editCustomer.Text :='';
                                 editCustomer.Setfocus;
                                 msgpanel.Caption :='±ø½X­«·s¦C¦L§¹²¦';
                                 msgPanel.Color :=clYellow;
                                 exit;
                             except
                                 editCustomer.Text :='';
                                 editCustomer.Setfocus;
                                 msgpanel.Caption :='±ø½X­«·s¦C¦L¿ù»~';
                                 msgPanel.Color :=clRed;
                               exit;
                              end;
                        end;
                   end
                   else begin
                       msgPanel.Caption :=iResult+'¨S¦³Åv­­­«·s¦C¦L';
                       msgPanel.Color :=clRed;
                       editCustomer.Text :='';
                       editCustomer.SetFocus ;

                   end;
              end else begin
                  msgpanel.Caption :='NO SN';
                  editCustomer.Text :='';
                  editCustomer.SetFocus ;
                  msgPanel.Color :=clRed;
                 exit;
              end;
          end;

       end else begin
       
           if (IsStart) and (IsOpen) then
           begin
               try
                   BarDoc.Variables.Item('SN').Value :=editCustomer.Text;
                   Bardoc.PrintLabel(1);
                   Bardoc.FormFeed;

                   msgpanel.Caption :=iResult+'======>>'+'±ø½X¦C¦L§¹²¦';
                   msgPanel.Color :=clGreen;
                   editCustomer.Text :='';
                   editCustomer.Setfocus;
               except
                   msgpanel.Caption :='±ø½X¦C¦L¿ù»~';
                   msgPanel.Color :=clRed;
                   editCustomer.Text :='';
                   editCustomer.Setfocus;
                   exit;
               end;
           end;
       end;
  end else begin
       Sproc.Close;
       Sproc.DataRequest('SAJET.CCM_SN_2WO_INPUT_DEFECT');
       Sproc.FetchParams;
       Sproc.Params.ParamByName('TWO').AsString := editWO.Text ;
       Sproc.Params.ParamByName('TREV').AsString := editCustomer.Text;
       Sproc.Params.ParamByName('TEMPID').AsString := UPDATEUSERID;
       Sproc.Params.ParamByName('TDEFECT').AsString := editDefect.Text;
       Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal ;
       Sproc.Execute;
       iResult := Sproc.Params.ParamByName('TRES').AsString;
       if iResult <> 'OK' then begin
          ShowMSG('°õ¦æ¿ù»~','Error',iResult);
          editDefect.Clear;
          editCustomer.SelectAll;
          editCustomer.SetFocus;
          exit;
       end;

       msgPanel.Color := ClGreen;
       editDefect.Clear;
       editCustomer.Clear;
       editDefect.SetFocus;
  end;

   if    ( Copy(labPartNo.Caption,11,4) = '0080' )
          or ( Copy(labPartNo.Caption,11,4) = '0380' )
          or ( Copy(labPartNo.Caption,11,4) = '0680' ) then begin
          lblColor.Color := clRed;
          msgPanel.Caption := '½Ð±½´y¬õ¦â²£«~!';

   end;
   if    ( Copy(labPartNo.Caption,11,4) = '0180' )
      or ( Copy(labPartNo.Caption,11,4) = '0480' )
      or ( Copy(labPartNo.Caption,11,4) = '0780' ) then begin
          lblColor.Color := clWhite;
          msgPanel.Caption := '½Ð±½´y¥Õ¦â¦â²£«~!';
   end;
   if    ( Copy(labPartNo.Caption,11,4) = '0280' )
      or ( Copy(labPartNo.Caption,11,4) = '0580' )
      or ( Copy(labPartNo.Caption,11,4) = '0880' ) then begin
          lblColor.Color := clBlack;
          msgPanel.Caption := '½Ð±½´y¶Â¦â²£«~!';
   end;

   QryTemp.close;
   QryTemp.Params.Clear;
   QryTemp.Params.CreateParam(ftString,'WO',ptInput);
   QryTemp.CommandText :='Select Input_QTY from sajet.g_WO_BASE where WORK_ORDER =:WO';
   QryTemp.Params.ParamByName('WO').AsString :=editWO.Text;
   QryTemp.Open;

   LabInputQty.Caption :=  QryTemp.fieldbyname('INPUT_QTY').AsString;
   
end;

procedure TfCMInput.labWODblClick(Sender: TObject);
begin
  if not editWO.Enabled then
  begin
    editWO.Enabled := True;
    editWO.SelectAll;
    editWO.SetFocus;
  end
  else
  begin
    editWO.Enabled := False;
  end;
end;

procedure TfCMInput.FormDestroy(Sender: TObject);
begin
  if IsOpen then BarDoc.Close;
  if isStart then BarApp.quit;
  KillTask('lppa.exe');
end;

procedure TfCMInput.editDefectKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
   if Key <>#13 then Exit;
   editDefect.Text := Trim(editDefect.Text ) ;
   if editDefect.Text = '' then exit;
   Sproc.Close;
   Sproc.DataRequest('SAJET.SJ_CKSYS_DEFECT');
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TREV').AsString := editDefect.Text;
   Sproc.Execute;
   iResult := Sproc.Params.ParamByName('TRES').AsString;
   if iResult <> 'OK' then begin
      ShowMSG('¤£¨}¥N½X¿ù»~','Error',iResult);
      editDefect.SelectAll;
      editDefect.SetFocus;
      exit;
   end;
   msgPanel.Color := clGreen;
   msgPanel.Caption := 'EC OK';
   editCustomer.SelectAll;
   editCustomer.SetFocus;
end;

end.
