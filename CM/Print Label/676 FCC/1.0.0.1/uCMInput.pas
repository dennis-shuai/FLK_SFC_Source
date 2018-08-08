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
    Label3: TLabel;
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    editCustomer: TEdit;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    Label2: TLabel;
    editKP: TEdit;
    procedure FormShow(Sender: TObject);
    procedure editCustomerKeyPress(Sender: TObject; var Key: Char);
    procedure editKPKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
  private
    function GetTerminalName(sTerminalID:string):string;
    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
  public
    UpdateUserID ,sEMP_NO,sPDlineID,sStageID,sProcessID: String;
    iTerminal,gWO:string;
    sPartID ,sPartNo,sMAC,PrintFile: String;
    isStart,IsOpen:boolean;
    BarApp,BarDoc,BarVars:variant;
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
Var DestRect,SurcRect : TRect; Bmp : TBitmap;PrintFile:string;
iniFile:TIniFile;
begin
   Bmp := TBitmap.Create ;
   Bmp.Assign(ImageAll.Picture.Graphic);
   Bmp.PixelFormat := pf32bit;
   ImageAll.Picture.Graphic := Bmp;

   Bmp.Free;

   iniFile :=TIniFile.Create('SAJET.ini');
   iTerminal :=iniFile.ReadString('CM','Terminal','N/A' );
   iniFile.Free;
   LabTerminal.Caption := 'Terminal:'+ GetTerminalName(iTerminal);


   isStart :=false;
   IsOpen :=false;
   KillTask('lppa.exe');
   try
      BarApp := CreateOleObject('lppx.Application');
   except
      isStart:=false;
      msgPanel.Caption := 'No codesoft software';
      msgpanel.Color :=clRed;
      Exit;
   end;
   IsStart :=true;

   msgPanel.Caption := '請掃描條碼';
   msgpanel.Color :=clGreen;
   editCUstomer.Enabled :=True;
   editCustomer.SetFocus;
   editKP.Enabled :=false;



end;

procedure TfCMInput.editCustomerKeyPress(Sender: TObject; var Key: Char);
var iResult,sSN,SWO:string;
begin

    if  Key <>#13 then exit;
    if  editCustomer.Text ='' then exit;

    with QryTemp do
    begin
        Close;
        Params.CreateParam(ftString,'SN',ptInput);
        CommandText :=' Select a.work_order,a.Model_id,b.part_no,a.Serial_number from sajet.g_sn_status a,sajet.sys_part b '+
                      ' where (a.serial_number=:SN or a.customer_sn=:sn) and a.mOdel_id=b.part_id ';
        Params.ParamByName('SN').AsString := editCustomer.Text;
        Open;

        if IsEmpty then
        begin
            msgPanel.Caption :='NO SN';
            msgPanel.Font.Color :=clBlack;
            msgPanel.Color :=clRed;
            editCustomer.Clear;
            editCUstomer.Setfocus;
            exit;
        end;
        gWO:= FieldByName('work_order').AsString;
        sSN :=  FieldByName('Serial_number').AsString;
        sPartNO := FieldByName('PART_NO').AsString;
        PrintFile :=GetCurrentDir +'\\S_'+sPartNO+'_FCC.Lab';
         If not FileExists( PrintFile) then
         begin
               msgPanel.Caption := 'Label 檔案:'+printFile+'不存在';
               msgPanel.Color :=clRed;
               editCustomer.SelectAll;
               editCustomer.SetFocus;
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
               msgPanel.Caption := '打印程式開啟錯誤';
               msgPanel.Color :=clRed;
               IsOpen :=false;
               Exit;
            end;
         end;
    end;

    Sproc.Close;
    Sproc.DataRequest('SAJET.SJ_CKRT_ROUTE');
    Sproc.FetchParams;
    Sproc.Params.ParamByName('TSN').AsString := sSN;
    Sproc.Params.ParamByName('TERMINALID').AsString :=iTerminal ;
    Sproc.Execute;
    iResult := SProc.Params.ParamByName('TRES').AsString;
    if  iResult <> 'OK' then
    begin
         with QryTemp do
         begin
             Close;
             Params.CreateParam(ftString,'SN',ptInput);
             CommandText :=' Select Item_PART_SN from sajet.g_sn_keyparts '+
                          ' where serial_number=:SN  and enabled=''Y''';
             Params.ParamByName('SN').AsString := sSN;
             Open;

             sMAC := FieldByName('Item_PART_SN').AsString;

             if IsEmpty then begin
                 msgPanel.Caption :=iResult;
                 msgPanel.Font.Color :=clBlack;
                 msgPanel.Color :=clRed;
                 editCustomer.Clear;
                 editCUstomer.Setfocus;
                 exit;
             end;



             fLogin := TfLogin.Create(Self);
            if fLogin.ShowModal = mrOK then
            begin
                 if (IsStart) and (IsOpen) then
                 begin
                      try
                          BarDoc.Variables.Item('SN').Value := UpperCase( Trim(editCustomer.Text));
                          BarDoc.Variables.Item('MAC').Value := sMAC;
                          Bardoc.PrintLabel(1);
                          Bardoc.FormFeed;

                          msgpanel.Caption :=iResult+'======>>'+'條碼重新列印成功';
                          msgPanel.Color :=clGreen;
                          editCustomer.Text :='';
                          editCustomer.Setfocus;
                          Exit;
                      except
                         msgpanel.Caption :='條碼重新列印錯誤';
                         msgPanel.Color :=clRed;
                         editCustomer.Text :='';
                         editCustomer.Setfocus;
                         exit;
                      end;
                 end;
            end
            else begin
                 msgPanel.Caption :=iResult+'沒有權限重新列印';
                 msgPanel.Color :=clRed;
                 editCustomer.Text :='';
                 editCustomer.SetFocus ;
            end;
         end;

    end;

    msgPanel.Caption :='OK,請掃描MAC條碼';
    msgPanel.Font.Color :=clBlack;
    msgPanel.Color :=clGreen;
    editCustomer.Enabled :=False;
    editKP.Enabled :=True;
    editKP.Clear;
    editKP.Setfocus;

end;

procedure TfCMInput.editKPKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin

   if  Key <>#13 then exit;
   if  editKP.Text ='' then exit;


   Sproc.Close;
   Sproc.DataRequest('SAJET.CCM_INPUT_CHK_KPSN_FINISHED');
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TKPSN').AsString := editKP.Text;
   Sproc.Params.ParamByName('TWO').AsString := gWO;
   Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal ;
   Sproc.Execute;


   iResult := Sproc.Params.ParamByName('TRES').AsString;
   
   if iResult <> 'OK' then begin

        msgPanel.Caption :=iResult;
        msgPanel.Font.Color :=clBlack;
        msgPanel.Color :=clRed;
        editKP.Clear;
        editKP.Setfocus;
        exit;
   end;


   Sproc.Close;
   Sproc.DataRequest('SAJET.CCM_ASSY_SN_KPSN_GO');
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TSN').AsString := editCustomer.Text;
   Sproc.Params.ParamByName('TKPSN').AsString := editKP.Text;
   Sproc.Params.ParamByName('TWO').AsString := gWO;
   Sproc.Params.ParamByName('TEMPID').AsString := UpdateUserID;
   Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal ;
   Sproc.Execute;

   iResult := Sproc.Params.ParamByName('TRES').AsString;

   if iResult <> 'OK' then begin

          msgPanel.Caption :=iResult;
          msgPanel.Font.Color :=clBlack;
          msgPanel.Color :=clRed;
          editCustomer.Clear;
          editCUstomer.Setfocus;
          exit;
   end;

    sMAC :=editKP.Text;

    if IsStart then begin
        try
           BarApp.Visible:=false;
           BarDoc:=BarApp.ActiveDocument;
           BarVars:=BarDoc.Variables;
           BarDoc.Open(PrintFile);
           IsOpen :=true;
        except
           msgPanel.Caption := '打印程式開啟錯誤';
           msgPanel.Color :=clRed;
           IsOpen :=false;
           Exit;
        end;
    end;
    
    if (IsStart) and (IsOpen) then
    begin
       try
            BarDoc.Variables.Item('SN').Value := UpperCase( Trim(editCustomer.Text));
            BarDoc.Variables.Item('MAC').Value := sMAC;
            Bardoc.PrintLabel(1);
            Bardoc.FormFeed;

            msgpanel.Caption :=iResult+'======>>'+'條碼列印成功';
            msgPanel.Color :=clGreen;
            //editCustomer.Text :='';
           // editCustomer.Setfocus;
       except
           msgpanel.Caption :='條碼列印錯誤';
           msgPanel.Color :=clRed;
           editKP.Clear;
           editKP.Enabled :=false;
           editCustomer.Enabled :=True;
           editCustomer.Text :='';
           editCustomer.Setfocus;
           exit;
       end;
    end;



   msgPanel.Caption :='OK';
   msgPanel.Font.Color :=clBlack;
   msgPanel.Color :=clGreen;
   editKP.Clear;
   editKP.Enabled :=false;
   editCustomer.Enabled :=True;
   editCustomer.Clear;
   editCustomer.Setfocus;

end;



procedure TfCMInput.FormDestroy(Sender: TObject);
begin
   if IsOpen then Bardoc.Close;
   if IsStart then BarApp.Quit;
   KillTask('lppa.exe');

end;


end.
