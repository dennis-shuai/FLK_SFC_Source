unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles;

type
  TfMainForm = class(TForm)
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
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    editCarrier: TEdit;
    editPanel: TEdit;
    DBGrid1: TDBGrid;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    labInputQty: TLabel;
    ImageAll: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    editWO: TEdit;
    Image1: TImage;
    lblTarget: TLabel;
    lblInput: TLabel;
    procedure FormShow(Sender: TObject);
    procedure editCarrierKeyPress(Sender: TObject; var Key: Char);
    procedure editPanelKeyPress(Sender: TObject; var Key: Char);
    procedure Label4DblClick(Sender: TObject);
    procedure editWOKeyPress(Sender: TObject; var Key: Char);
  private
    //m_SNDefectLevel: String;
    procedure clearData;

 
    function GetTerminalName(sTerminalID:string):string;

    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
    procedure RemoveCarrier(sCarrier:string);


    function GetPartID(partno :String) :String;
    procedure ShowData(sCarrier :String);
  public
    UpdateUserID,sPartID : String;
    sPdline,sProcess,sTerminal,sProcessID,swoModel,sPanelModel:string;
    Authoritys,AuthorityRole,FunctionName : String;
    //Language : TLanguage;
    procedure SetStatusbyAuthority;
    Function LoadApServer : Boolean;
  end;

var
  fMainForm: TfMainForm;
  gWO,gCarrierNO:string;
  iCarrierSNCount,iSNCount:Integer;
  iTerminal:string;

implementation


{$R *.dfm}

function TfMainForm.GetTerminalName(sTerminalID:string):string;
begin
try
  with Qrytemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'TerminalID',ptInput);
      CommandText :='select a.pdline_name,b.process_name,c.terminal_name,c.terminal_id ,c.process_id ' +
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
         sProcessID:= Fieldbyname('process_id').AsString  ;
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


 

procedure TfMainForm.ShowMSG(sShowHead,sShowResult,sNextMsg:string);
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

procedure TfMainForm.RemoveCarrier(sCarrier:string);
begin
if editCarrier.Text ='' then exit;
try
  with Qrytemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString,'Carrier',ptInput);
    CommandText :='update SAJET.g_sn_status set box_no = ''N/A'' WHERE box_no= :Carrier ' ;
    Params.ParamByName('Carrier').AsString := sCarrier;
    Execute;
  end;
except on e:Exception do
  begin
    MessageDlg('Remove carrier err: '+e.Message,mtError,[mbOK],0);
  end;

end;
end;

function TfMainForm.GetPartID(partno :String) :String;
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

procedure TfMainForm.ShowData(sCarrier :String);
begin

    With QryData do
    begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'CarrierNO',ptInput);
       CommandText := 'SELECT A.WORK_ORDER,A.BOX_NO,A.serial_number,a.Customer_SN,A.in_process_time '+
                      '  FROM SAJET.g_sn_status A '+
                      //' WHERE A.WORK_ORDER = :WO '+        //modify by phoenix 2013-5-9
                      ' WHERE A.Box_NO= :CarrierNO '+
                      '   AND A.WORK_FLAG= ''0'' '+          //add by phoenix 2013-05-09
                      '   AND A.CUSTOMER_SN <> ''N/A'' '+    //add by phoenix 2013-05-09
                      ' ORDER BY A.serial_number ';

     Params.ParamByName('CarrierNO').AsString := sCarrier;
     Open;

    end;
end;

procedure TfMainForm.FormShow(Sender: TObject);
Var DestRect,SurcRect : TRect; Bmp : TBitmap;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;

  Bmp.Free;

 // LoadApServer;
  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;

  editWO.SetFocus;
  LabTerminal.Caption := LabTerminal.Caption + '    ' + GetTerminalName(iTerminal);

end;

procedure TfMainForm.clearData;
begin
end;
 

Procedure TfMainForm.SetStatusbyAuthority;
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

  //sbtnSave.Enabled := ((Authoritys = 'Allow To Execute') or (Authoritys = 'Full Control'));
  //sbtnFinish.Enabled := (Authoritys = 'Full Control');
  
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
    //sbtnSave.Enabled := ((AuthorityRole = 'Allow To Execute') or (AuthorityRole = 'Full Control'));
    //sbtnFinish.Enabled := (AuthorityRole = 'Full Control');
  end;


end;


Function TfMainForm.LoadApServer : Boolean;
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

procedure TfMainForm.editCarrierKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
   if Key <> #13 then exit;
   if Length(editCarrier.Text) =0 then exit;

   Sproc.Close;
   Sproc.DataRequest('SAJET.SJ_PLCC_COB_RANK');
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TPANEL').AsString :=editPanel.Text;
   Sproc.Params.ParamByName('TREV').AsString :=editCarrier.Text;
   Sproc.Params.ParamByName('TWO').AsString :=editWO.Text;
   Sproc.Params.ParamByName('TEMP').AsString :=updateUserID;
   Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal;
   Sproc.Execute;

   iResult := Sproc.Params.parambyname('TRES').AsString ;

   if  iResult <> 'OK' then begin
       msgPanel.Caption := iResult;
       msgPanel.Color :=clRed;
       editCarrier.Text :='';
       editCarrier.SetFocus;
       exit;
   end;

   with QryTemp do begin
      close;
      Params.Clear;
      params.CreateParam(ftstring,'WO',ptInput);
      CommandText :='select * from sajet.g_wo_base where WORK_ORDER =:WO';
      Params.ParamByName('WO').AsString :=editWO.Text;
      Open;
      lblTarget.Caption :='工單總數:'+FieldByName('Target_qty').AsString;
      lblInput.Caption := '工單投入:'+FieldByName('Input_qty').AsString;
  end;

   msgPanel.Caption := iResult;
   msgPanel.Color :=clGreen;
   editPanel.ReadOnly :=false;
   editCarrier.Text :='';
   editCarrier.ReadOnly :=false;
   editPanel.Text :='';
   editPanel.SetFocus;



end;

procedure TfMainForm.editPanelKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
    iqty:integer;
begin
  if Key <> #13 then exit;
  if editPanel.Text ='' then exit;
  if editWO.Text ='' then exit;

   Sproc.Close;
   Sproc.DataRequest('SAJET.SJ_CKRT_PANEL_ROUTE_END');
   Sproc.FetchParams;

   Sproc.Params.ParamByName('TREV').AsString :=editPanel.Text;
   Sproc.Params.ParamByName('TERMINALID').AsString :=iTerminal;

   Sproc.Execute;
   iResult := Sproc.Params.parambyname('TRES').asstring ;

   if  Copy(iResult,1,2) <> 'OK' then begin
       msgPanel.Caption := iResult;
       msgPanel.Color :=clRed;
       editPanel.Text :='';
       editPanel.SetFocus;
       exit;
   end;

   with QryTemp do begin
        close;
        Params.Clear;
        params.CreateParam(ftstring,'Panel',ptInput);
        CommandText :=' select  c.Model_name ,count(*) box_qty  from  sajet.g_sn_status a,sajet.sys_part b,sajet.sys_model c ' +
                       ' where a.box_no =:Panel and a.Model_id=b.Part_Id and b.Model_id=c.Model_id and current_status =0 and ' +
                       ' work_flag=0 group by c.Model_name  ';
        Params.ParamByName('Panel').AsString :=editPanel.Text;
        Open;
        if IsEmpty then begin
             msgPanel.Caption := '請檢查連板是否設置機種?';
             msgPanel.Color :=clRed;
             editPanel.Text :='';
             editPanel.SetFocus;
             exit;
        end;

        sPanelModel := fieldByName('Model_name').AsString;

        if sWOModel <>sPanelModel then begin
             msgPanel.Caption := '請檢查連板機種和工令機種不匹配';
             msgPanel.Color :=clRed;
             editPanel.Text :='';
             editPanel.SetFocus;
             exit;
        end;

        if fieldbyname('Box_qty').AsInteger +strtoInt(lblInput.Caption) > strToInt(lblTarget.Caption) then
        begin
             msgPanel.Caption := '投入數量大於工單數量';
             msgPanel.Color :=clRed;
             editPanel.Text :='';
             editPanel.SetFocus;
             exit;
        end;
   end;

   msgPanel.Caption := iResult;
   msgPanel.Color :=clGreen;
   editCarrier.Text :='';
   editPanel.ReadOnly :=true;
   editCarrier.ReadOnly :=false;
   editCarrier.SetFocus;
   editCarrier.SelectAll;

end;




procedure TfMainForm.Label4DblClick(Sender: TObject);
begin
    //RemoveCarrier(editCarrier.Text);
    editPanel.Clear;
    editPanel.Enabled :=true;
    editPanel.SetFocus;

end;

procedure TfMainForm.editWOKeyPress(Sender: TObject; var Key: Char);
var iResult :string;
begin
    if Key <> #13 then exit;


    Sproc.Close;
    Sproc.DataRequest('SAJET.SJ_CHK_WO_INPUT');
    Sproc.FetchParams;
    Sproc.Params.ParamByName('TREV').AsString :=editWO.Text;
    Sproc.Execute;
    iResult := Sproc.Params.parambyname('TRES').asstring ;

    if  iResult<> 'OK' then begin
         editCarrier.Text :='';
         editPanel.Text :='';
         editCarrier.ReadOnly :=false;
         editPanel.ReadOnly :=false;
         editWO.SelectAll;
         editWO.SetFocus;
         msgPanel.Caption := iResult;
         msgPanel.Color :=clRed;
         exit;
    end;

    with QryTemp do begin
        close;
        Params.Clear;
        params.CreateParam(ftstring,'WO',ptInput);
        CommandText :=' select a.target_qty,a.Input_qty,c.Model_name,a.ROute_id,a.start_process_id from '+
                       ' sajet.g_wo_base a,sajet.sys_part b,sajet.sys_model c ' +
                       ' where a.WORK_ORDER =:WO and a.Model_id=b.Part_Id and b.Model_id=c.Model_id ';
        Params.ParamByName('WO').AsString :=editWO.Text;
        Open;
        if IsEmpty then begin
            MessageDlg('料號沒有設定機種',mterror,[mbok],0);
            exit;
        end;

        lblTarget.Caption :='工單總數:'+FieldByName('Target_qty').AsString;
        lblInput.Caption := '工單投入:'+FieldByName('Input_qty').AsString;
        swOModel := fieldbyname('Model_Name').AsString;
        
        if fieldbyname('ROUTE_ID').AsString ='0' then
        begin
             editCarrier.Text :='';
             editPanel.Text :='';
             editCarrier.ReadOnly :=false;
             editPanel.ReadOnly :=false;
             editWO.SelectAll;
             editWO.SetFocus;
             msgPanel.Caption := '沒有設置流程';
             msgPanel.Color :=clRed;
             exit;
        end;

        if fieldbyname('START_PROCESS_ID').AsString  <> sProcessID then begin
            editCarrier.Text :='';
            editPanel.Text :='';
            editCarrier.ReadOnly :=false;
            editPanel.ReadOnly :=false;
            editWO.SelectAll;
            editWO.SetFocus;
            msgPanel.Caption := '不是起始站';
            msgPanel.Color :=clRed;
            exit;
        end;

    end;


    editPanel.SetFocus;
    editPanel.SelectAll;
    editPanel.ReadOnly :=false;
    msgPanel.Caption := 'Please Input Panel';
    msgPanel.Color :=clGreen;
    editWO.Enabled :=false;
  

end;

end.
