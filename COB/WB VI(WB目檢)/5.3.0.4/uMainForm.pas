unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles, ListView1;

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
    editCarrier: TEdit;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    Label2: TLabel;
    ImageAll: TImage;
    cmbPdline: TComboBox;
    Label1: TLabel;
    cmbTerminal: TComboBox;
    lbl1: TLabel;
    cmbSerial: TComboBox;
    btn1: TButton;
    mmo1: TMemo;
    lvData: TListView;
    lbl2: TLabel;
    lbl3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure editCarrierKeyPress(Sender: TObject; var Key: Char);
    procedure cmbPdlineSelect(Sender: TObject);
    procedure cmbTerminalSelect(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure cmbSerialSelect(Sender: TObject);
    procedure Cancel1Click(Sender: TObject);
  private
    //m_SNDefectLevel: String;
    
    function GetTerminalName(sTerminalID:string):string;
    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
    function GetPartID(partno :String) :String;
    procedure ShowData(sCarrier :String);
  
  public
    UpdateUserID,sPartID : String;
    sPdline,sProcess,sProcessID,sTerminal:String;
    Authoritys,AuthorityRole,FunctionName:String;
    sDefectID,sDefectCode,sDefectDesc:String;
    gWO,gCarrierNO:String;
    iCarrierSNCount,iSNCount:Integer;
    IsInputDefect:Boolean;
    IsInputSN:Boolean;
    iTerminal:String;
    snStr:string;
    procedure SetStatusbyAuthority;
    function  GetSysDate:TDatetime;
    function  GetEMPNO:String;
  end;

var
  fMainForm: TfMainForm;


implementation


{$R *.dfm}
function  TfMainForm.GetSysDate:TDatetime;
begin
   with Qrytemp do
   begin
      Close;
      Params.Clear;
      commandText := 'select sysdate iDate from dual';
      open;
   end;

   result :=  Qrytemp.fieldbyName('iDate').asdatetime;
end;

function  TfMainForm.GetEMPNO:string;
begin
   with Qrytemp do
   begin
      Close;
      Params.Clear;
      commandText := 'select emp_no from sajet.sys_emp where emp_ID ='+updateuserid;
      open;
   end;

   result :=  Qrytemp.fieldbyName('emp_no').asstring;
end;

function TfMainForm.GetTerminalName(sTerminalID:string):string;
begin
try
  with Qrytemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'TerminalID',ptInput);
      CommandText :='select a.pdline_name,b.process_name,c.terminal_name,c.terminal_id,b.process_id  ' +
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
         sProcessID := Fieldbyname('process_id').AsString  ;
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
       //Params.CreateParam(ftString,'WO',ptInput);
       Params.CreateParam(ftString,'CarrierNO',ptInput);
       CommandText := 'SELECT A.WORK_ORDER,A.BOX_NO,A.serial_number,a.Customer_SN,A.in_process_time '+
                      '  FROM SAJET.g_sn_status A '+
                      //' WHERE A.WORK_ORDER = :WO '+        //modify by phoenix 2013-5-9
                      ' WHERE A.Box_NO= :CarrierNO '+
                      '   AND A.WORK_FLAG= ''0'' '+          //add by phoenix 2013-05-09
                      '   AND A.CUSTOMER_SN <> ''N/A'' '+    //add by phoenix 2013-05-09
                      ' ORDER BY A.serial_number ';
     //Params.ParamByName('WO').AsString := sWO;
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

  cmbSerial.Style := csDropDownList;

  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;
  IsInputDefect:=false;
  IsInputSN :=false;
  cmbPdline.SetFocus;
  LabTerminal.Caption := LabTerminal.Caption + '    ' + GetTerminalName(iTerminal);

  msgPanel.Caption := '請掃描不良代碼或者Carrier';
  msgpanel.Color :=clGreen;



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



procedure TfMainForm.editCarrierKeyPress(Sender: TObject; var Key: Char);
var iResult,sSN:string;
i:Integer;
begin

    if Key <> #13 then exit;
    if Length(editCarrier.Text) =0 then exit;
    if cmbPdline.ItemIndex < 0 then begin
       cmbPdline.SetFocus;
       msgpanel.Caption :='請選擇纖體';
       msgpanel.Color := clRed;
    end;

    if IsInputDefect then
    begin

        QryTemp.Close;
        QryTemp.Params.Clear;
        QryTemp.Params.CreateParam(ftString,'ErrorCode',ptInput);
        QryTemp.CommandText :='Select Defect_id,Defect_Desc from sajet.SYS_DEFECT where Defect_Code =:ErrorCode ';
        QryTemp.Params.ParamByName('ErrorCode').AsString := editCarrier.Text;
        QryTemp.Open;

        if not QryTemp.IsEmpty then
        begin
            sDefectID := QryTemp.fieldbyName('Defect_id').AsString;
            sDefectCode :=  editCarrier.Text ;
            sDefectDesc :=  QryTemp.fieldbyName('Defect_Desc').AsString;
            editCarrier.Text :='';
            editCarrier.SetFocus;
            msgpanel.Caption := '請掃描不良產品條碼';
            msgpanel.Color := clYellow;
            IsInputDefect :=true;
            exit;

        end;

         with QryTemp do
         begin
             Close;
             Params.Clear;
             Params.CreateParam(ftString,'sn',ptInput);
             CommandText := 'select serial_number,box_no from sajet.g_sn_status where serial_number =:sn or customer_sn =:sn';
             Params.ParamByName('sn').AsString := editCarrier.Text;
             Open;

         end;

         if not QryTemp.IsEmpty then
         begin
             sproc.Close;
             sproc.DataRequest('SAJET.CCM_COB_WB_VI_NOGO');
             sproc.FetchParams;
             sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal;
             sproc.Params.ParamByName('TDEFECT').AsString := sDefectCode;
             sproc.Params.ParamByName('TSN').AsString := editCarrier.Text;
             sproc.Params.ParamByName('TEMPID').AsString := UpdateUserID;
             sproc.Execute;

             iResult := sproc.Params.ParamByName('TRES').AsString ;

             if iResult <> 'OK' then
             begin
                  editCarrier.Text :='';
                  editCarrier.setfocus;
                  msgpanel.Caption :=iResult;
                  msgpanel.Color := clRed;
                  exit;
             end;
             editCarrier.Text :='';
             editCarrier.setfocus;
             msgpanel.Caption :='請將產品取下Carrier';
             msgpanel.Color := clGreen;
             IsInputDefect :=false;
             exit;

         end else begin

             with QryTemp do
             begin
                 Close;
                 Params.Clear;
                 Params.CreateParam(ftString,'sn',ptInput);
                 CommandText := 'select carton_no from sajet.g_sn_status where box_no =:sn and work_Flag=0';
                 Params.ParamByName('sn').AsString := editCarrier.Text;
                 Open;

                 if IsEmpty then
                 begin
                      editCarrier.Text :='';
                      editCarrier.setfocus;
                      msgpanel.Caption :='SN NG';
                      msgpanel.Color := clRed;
                      exit;

                 end;

                 if  FieldByName('carton_no').AsString <> 'N/A' then
                 begin
                     
                      sproc.Close;
                      sproc.DataRequest('SAJET.SJ_CKRT_CARRIER');
                      sproc.FetchParams;
                      sproc.Params.ParamByName('TERMINALID').AsString :=iTerminal;
                      sproc.Params.ParamByName('TREV').AsString := editCarrier.Text;
                      sproc.Execute;

                      iResult := sproc.Params.ParamByName('TRES').AsString ;

                      if Copy(iResult,1,2) <> 'OK' then
                      begin
                          editCarrier.Text :='';
                          editCarrier.setfocus;
                          msgpanel.Caption := iResult ;
                          msgpanel.Color := clRed;
                          exit;
                      end;

                      cmbSerial.Text :='';
                      cmbSerial.Items.Clear;


                      for i:=0 to recordCount-1 do begin
                          cmbSerial.Items.Add(Format('%d',[i+1]));
                      end;

                      msgpanel.Caption :='請選擇序號';
                      msgpanel.Color := clYellow;
                      IsInputSN :=True;
                      Exit;

                 end else begin
                      editCarrier.Text :='';
                      editCarrier.setfocus;
                      msgpanel.Caption :='請掃描不良產品的條碼,并取下Carrier';
                      msgpanel.Color := clRed;
                      exit;
                 end;

             end;
         end;

    end;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'ErrorCode',ptInput);
    QryTemp.CommandText :='Select Defect_id,Defect_Desc from sajet.SYS_DEFECT where Defect_Code =:ErrorCode ';
    QryTemp.Params.ParamByName('ErrorCode').AsString := editCarrier.Text;
    QryTemp.Open;

    if not QryTemp.IsEmpty then
    begin
        sDefectID := QryTemp.fieldbyName('Defect_id').AsString;
        sDefectCode :=  editCarrier.Text ;
        sDefectDesc :=  QryTemp.fieldbyName('Defect_Desc').AsString;
        editCarrier.Text :='';
        editCarrier.SetFocus;
        msgpanel.Caption := '請掃描不良產品條碼';
        msgpanel.Color := clYellow;
        IsInputDefect :=true;
    end else begin

        IsInputDefect :=false;

        sproc.Close;
        sproc.DataRequest('SAJET.SJ_CKRT_CARRIER');
        sproc.FetchParams;
        sproc.Params.ParamByName('TERMINALID').AsString :=iTerminal;
        sproc.Params.ParamByName('TREV').AsString := editCarrier.Text;
        sproc.Execute;

        iResult := sproc.Params.ParamByName('TRES').AsString ;

        if Copy(iResult,1,2) <> 'OK' then
        begin
            if iResult ='COB_REPAIR' then
            begin
               //直接Repiar 過站

                QryTemp.Close;
                QryTemp.Params.Clear;
                QryTemp.Params.CreateParam(ftString,'box',ptInput);
                QryTemp.CommandText :='  Select a.process_id,b.process_name from sajet.g_sn_status a,sajet.sys_Process b'+
                                      '  where a.box_No=:box and a.process_id=b.process_id  and a.work_flag=0';
                QryTemp.Params.ParamByName('box').AsString := editCarrier.Text;
                QryTemp.Open;

                if QryTemp.fieldbyname('process_id').AsString <> sProcessID then
                begin
                     editCarrier.Text :='';
                     editCarrier.SetFocus;
                     msgpanel.Caption := QryTemp.fieldbyname('process_name').AsString;
                     msgpanel.Color := clRed;
                     Exit;
                end;

                with SProc do begin
                    Close;
                    DataRequest('SAJET.CCM_REPAIR_GO_NEXT');
                    FetchParams;
                    Params.ParamByName('trpterminalId').AsString := '10012394'; //COB-REPAIR 02
                    Params.ParamByName('tterminalId').AsString :=iTerminal;
                    Params.ParamByName('tbox').AsString :=editCarrier.Text;
                    Params.ParamByName('temp').AsString :=GetEMPNO;
                    Execute;
                    iResult :=  Params.ParamByName('TRES').AsString;
                end;
                editCarrier.Text :='';
                editCarrier.setfocus;
                msgpanel.Caption :=iResult;
                if Copy(iResult,1,2)='OK' then
                   msgpanel.Color := clGreen
                else
                   msgpanel.Color := clRed;
                exit;
            end;
            editCarrier.Text :='';
            editCarrier.setfocus;
            msgpanel.Caption :=iResult;
            msgpanel.Color := clRed;
            Exit;
        end;

        sproc.Close;
        sproc.DataRequest('SAJET.sj_panel_go2');
        sproc.FetchParams;
        sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal;
        sproc.Params.ParamByName('TREV').AsString := editCarrier.Text;
        sproc.Params.ParamByName('TDEFECT').AsString := 'N/A';
        sproc.Params.ParamByName('TNOW').AsDateTime :=GetSysDate;
        sproc.Params.ParamByName('TEMP').AsString := GetEMPNO;
        sproc.Execute;
        if   sproc.Params.ParamByName('TRES').AsString  <> 'OK' then
        begin
          editCarrier.Text :='';
          editCarrier.setfocus;
          msgpanel.Caption :=iResult;
          msgpanel.Color := clRed;
          exit;
        end;
        ShowData(editCarrier.Text);
        editCarrier.Text :='';
        editCarrier.setfocus;
        msgpanel.Caption :=iResult;
        msgpanel.Color := clGreen;

    end;

end;


procedure TfMainForm.cmbPdlineSelect(Sender: TObject);
begin
   if  cmbTerminal.ItemIndex >=0 then begin

       Qrytemp.Close;
       Qrytemp.Params.Clear;
       QryTemp.Params.CreateParam(ftstring,'Pdline',ptInput);
       QryTemp.Params.CreateParam(ftstring,'Terminal',ptInput);
       QryTemp.CommandText :='select a.terminal_id,a.Process_id from sajet.sys_terminal a ,sajet.sys_pdline b '+
                             ' where a.pdline_id =b.pdline_id and B.PDLINE_NAME =:Pdline and '+
                             ' A.TERMINAL_NAME =:Terminal';
       QryTemp.Params.ParamByName('Pdline').AsString :='COB_DB_'+cmbPdline.Text;
       QryTemp.Params.ParamByName('Terminal').AsString :='WB-VI0'+cmbTerminal.Text;
       QryTemp.Open;
       if QryTemp.IsEmpty then begin
           cmbPdline.SetFocus;
           msgpanel.Caption :='請聯繫SFC人員設定纖體和機台';
           msgpanel.Color := clRed;
           exit;
       end else begin
           iTerminal :=  QryTemp.fieldbyname('terminal_id').AsString;
           sProcessID := QryTemp.fieldbyname('Process_id').AsString;
           editCarrier.SetFocus;
           editCarrier.ReadOnly :=false;
           msgpanel.Caption :='請掃描Carrier或不良代碼';
           msgpanel.Color := clGreen;
       end;
       exit;
   end;
   cmbTerminal.SetFocus;
end;

procedure TfMainForm.cmbTerminalSelect(Sender: TObject);
begin
  if cmbPdline.ItemIndex < 0 then begin
       cmbPdline.SetFocus;
       msgpanel.Caption :='請選擇纖體';
       msgpanel.Color := clRed;
   end;
   editCarrier.SetFocus;
   editCarrier.ReadOnly :=false;
   Qrytemp.Close;
   Qrytemp.Params.Clear;
   QryTemp.Params.CreateParam(ftstring,'Pdline',ptInput);
   QryTemp.Params.CreateParam(ftstring,'Terminal',ptInput);
   QryTemp.CommandText :='select a.terminal_id,a.Process_id from sajet.sys_terminal a ,sajet.sys_pdline b '+
                         ' where a.pdline_id =b.pdline_id and B.PDLINE_NAME =:Pdline and '+
                         ' A.TERMINAL_NAME =:Terminal';
   QryTemp.Params.ParamByName('Pdline').AsString :='COB_DB_'+cmbPdline.Text;
   QryTemp.Params.ParamByName('Terminal').AsString :='WB-VI0'+cmbTerminal.Text;
   QryTemp.Open;
   if QryTemp.IsEmpty then begin
       cmbPdline.SetFocus;
       msgpanel.Caption :='請聯繫SFC人員設定纖體和機台';
       msgpanel.Color := clRed;
   end else begin
       iTerminal :=  QryTemp.fieldbyname('terminal_id').AsString;
       sProcessID := QryTemp.fieldbyname('Process_id').AsString;
       editCarrier.SetFocus;
       editCarrier.ReadOnly :=false;
       msgpanel.Caption :='請掃描Carrier或不良代碼';
       msgpanel.Color := clGreen;
   end;


end;

procedure TfMainForm.btn1Click(Sender: TObject);
var i:Integer;
sNextProcess:string;
begin
  //
  if lvData.Items.Count =0 then Exit;
  for i:=0 to lvdata.items.count-1 do
  with SProc do
  begin
       Close;
       DataRequest('SAJET.SJ_NOGO');
       FetchParams;
       Params.ParamByName('tterminalid').AsString := iTerminal ;
       Params.ParamByName('tsn').AsString := lvData.Items[i].SubItems[0];
       Params.ParamByName('tdefect').AsString :=lvData.Items[i].SubItems[2] ;
       Params.ParamByName('tnow').AsDateTime := Getsysdate;
       Params.ParamByName('temp').AsString := GetEMPNO ;
       Execute;
  end;

  with QryTemp do
  begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'box',ptInput);
      CommandText := ' select d.next_process_id from  sajet.g_sn_status a,sajet.g_wo_base b,sajet.sys_route c,sajet.sys_route_detail d '+
                     ' where a.box_no=:box and a.work_order=b.work_order and b.route_id =c.route_id and c.route_id =d.route_id and '+
                     ' d.result =1 and d.process_Id =  '+sprocessid;
      Params.ParamByName('box').AsString := editCarrier.Text ;
      Open;

  end;
  sNextProcess := QryTemp.FieldByName('next_process_id').AsString;

  with QryTemp do
  begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'box',ptInput);
      CommandText := ' update sajet.g_sn_status set wip_process = '+sNextProcess+'  where box_no=:box and work_flag = 0';
      Params.ParamByName('box').AsString := editCarrier.Text ;
      execute;

  end;

  lvData.Items.Clear;
  editCarrier.Text :='';
  editCarrier.SetFocus;
  msgPanel.Caption :='OK';
  msgPanel.Color :=clGreen;
  IsInputDefect :=false;
  IsInputSN :=False;


end;

procedure TfMainForm.cmbSerialSelect(Sender: TObject);
var stemp:string;
i:integer;
IsFound:boolean;
begin
   //
   if IsInputDefect and IsInputSN then
   begin
        with QryTemp do
        begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString,'box',ptInput);
            CommandText := ' select serial_number,customer_sn from sajet.g_sn_status where box_no =:box and rownum <='+cmbSerial.Text +
                           ' order by serial_number desc';
            Params.ParamByName('box').AsString := editCarrier.Text ;
            Open;
            if not IsEmpty  then
            begin
                IsFound:=false;
                for i:=0 to lvdata.Items.Count-1 do
                begin
                     stemp :=  lvdata.Items[i].subItems[0];
                     if stemp = QryTemp.FieldByName('Serial_number').AsString then
                     begin
                           IsFound :=true;
                           Break;
                     end;

                     if lvdata.Items[i].Caption <> editCarrier.Text then
                     begin
                          editCarrier.Text :='';
                          editCarrier.setfocus;
                          msgpanel.Caption :='Carrier不同，請掃描同一個Carrier';
                          msgpanel.Color := clRed;
                          Exit;
                     end;
                end;

                if not IsFound then
                begin
                    with lvData.Items.Add do
                    begin
                        Caption :=editCarrier.Text;
                        SubItems.Add(QryTemp.FieldByName('Serial_number').AsString);
                        SubItems.Add(QryTemp.FieldByName('Customer_sn').AsString);
                        SubItems.Add(sDefectCode);
                        SubItems.Add(sDefectDesc);
                        SubItems.Add(cmbSerial.Text);
                    end;
                end;
            end else begin
                  Exit;
            end;
        end;
   end;
end;

procedure TfMainForm.Cancel1Click(Sender: TObject);
begin
    //
    
end;

end.
