unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles;

type
  TfMainForm = class(TForm)
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    QryTemp1: TClientDataSet;
    msgPanel: TPanel;
    ImageAll: TImage;
    Label5: TLabel;
    EdtSN: TEdit;
    labInputQty: TLabel;
    LabTerminal: TLabel;
    lblVersion: TLabel;
    pnl1: TPanel;
    lbl1: TLabel;
    edtDefect: TEdit;
    cmbSerial: TComboBox;
    Label3: TLabel;
    btn1: TButton;
    lvData: TListView;
    Label2: TLabel;
    lblTerminal: TLabel;
    procedure EdtSNKeyPress(Sender: TObject; var Key: Char);
    procedure fromshow(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure cmbSerialSelect(Sender: TObject);
    procedure edtDefectKeyPress(Sender: TObject; var Key: Char);

    //procedure editReelnoKeyPress(Sender: TObject; var Key: Char);

  public
    UpdateUserID,FunctionName,iTerminal,sProcess,sPdline,sTerminal,
       sProcessID,sDefectID,sDefectCode,sDefectDesc: String;
    IsInputDefect,IsInputSN:Boolean;
    function  GetTerminalName(sTerminalID:string):string;
    function  GetSysDate:TDatetime;
    function  GetEMPNO:string;
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
procedure TfMainForm.EdtSNKeyPress(Sender: TObject; var Key: Char);
var sSN,iResult:string;
begin
    if key <> #13 then exit;
    if edtsn.Text = '' then exit;

    Qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Params.CreateParam(ftstring,'SN',ptinput);
    qrytemp.CommandText:=' select *  from sajet.g_sn_status '+
                         ' where serial_number =:sn or customer_SN=:sn ' ;
    qrytemp.Params.ParamByName('SN').AsString :=Edtsn.Text;
    qrytemp.Open;

    if  QryTemp.IsEmpty then
    begin

        Qrytemp.Close;
        qrytemp.Params.Clear;
        qrytemp.Params.CreateParam(ftstring,'SN',ptinput);
        qrytemp.CommandText:=' select *  from sajet.g_sn_status '+
                         ' where BOX_No=:SN' ;
        qrytemp.Params.ParamByName('SN').AsString :=Edtsn.Text;
        qrytemp.Open;

        if  QryTemp.IsEmpty then
        begin
            msgPanel.Color := clRed;
            msgPanel.Caption := '沒有找到該條碼信息';
            EdtSN.Clear;
            EdtSN.SetFocus;
            Exit;
        end;
        if msgPanel.Top <>496 then
        begin
            msgPanel.Top := msgPanel.Top+392;
            lblVersion.Top := lblVersion.Top+392;
            pnl1.Visible :=True;
        end;
        SProc.Close;
        SProc.DataRequest('SAJET.SJ_SMT_CKRT_PANEL');
        SProc.FetchParams;
        SProc.Params.ParamByName('TREV').AsString := Trim(EdtSN.Text);
        SProc.Params.ParamByName('TERMINALID').AsString := iTerminal;
        SProc.Execute;
        iResult :=SProc.Params.ParamByName('TRES').AsString;

        if Copy(iResult,1,2) <>'OK' then
        begin
            msgPanel.Color := clRed;
            msgPanel.Caption := iResult ;
            EdtSN.Clear;
            EdtSN.SetFocus;
            Exit;
        end;
        edtDefect.SetFocus;
        edtDefect.Clear;
        exit;
    end;
    sSN := qrytemp.fieldByName('serial_number').AsString;

    if msgPanel.Top =496 then
    begin
        msgPanel.Top := msgPanel.Top-392;
        lblVersion.Top := lblVersion.Top-392;
        pnl1.Visible :=False;
    end;

    Qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Params.CreateParam(ftstring,'SN',ptinput);
    qrytemp.CommandText:=' delete from  SAJET.G_QC_SN where serial_number =:sn and qc_lotno =(select qc_no from sajet.g_sn_status '+
                         ' where  serial_number =:sn ) ' ;
    qrytemp.Params.ParamByName('SN').AsString :=sSN;
    qrytemp.Execute;


    Qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Params.CreateParam(ftstring,'SN',ptinput);
    qrytemp.CommandText:=' UPDATE SAJET.G_SN_STATUS SET BOX_NO=''N/A'','+
                         ' CARTON_NO=''N/A'',PALLET_NO=''N/A'',QC_RESULT=''N/A'',QC_NO=''N/A'' WHERE '+
                         ' Serial_Number=:SN   ';
    qrytemp.Params.ParamByName('SN').AsString :=sSN;
    qrytemp.Execute;


    Qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Params.CreateParam(ftstring,'SN',ptinput);
    qrytemp.CommandText:=' UPDATE SAJET.G_SN_TEST_TIMES SET FAIL_TIMES=1 WHERE '+
                         ' Serial_Number=:SN   ';
    qrytemp.Params.ParamByName('SN').AsString :=sSN;
    qrytemp.Execute;


    Qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Params.CreateParam(ftstring,'SN',ptinput);
    qrytemp.CommandText:=' select * from  SAJET.G_QC_SN where serial_number =:sn and qc_lotno =(select qc_no from sajet.g_sn_status '+
                         ' where  serial_number =:sn  ) ' ;
    qrytemp.Params.ParamByName('SN').AsString :=sSN;
    qrytemp.Open;

    if not QryTemp.IsEmpty then begin
        msgPanel.Color := clRed;
        msgPanel.Caption := '沒有刪除完成';
        EdtSN.Clear;
        EdtSN.SetFocus;
        Exit;
    end
    else begin
         
        Qrytemp.Close;
        qrytemp.Params.Clear;
        qrytemp.Params.CreateParam(ftstring,'SN',ptinput);
        qrytemp.CommandText:=' select Box_no from sajet.g_sn_status '+
                             ' where  serial_number =:sn   ' ;
        qrytemp.Params.ParamByName('SN').AsString :=sSN;
        qrytemp.Open;

        if QryTemp.FieldByName('BOX_NO').AsString <> 'N/A' then
        begin
             msgPanel.Color := clRed;
             msgPanel.Caption := '狀態沒有更新完成';
             EdtSN.Clear;
             EdtSN.SetFocus;
             Exit;
        end;
        msgPanel.Color := clGreen;
        msgPanel.Caption := '更新完成';
        EdtSN.Clear;
        EdtSN.SetFocus;

    end;
end;

procedure TfMainForm.fromshow(Sender: TObject);
begin
    Edtsn.SetFocus;
    msgPanel.Top := msgPanel.Top-392;
    lblVersion.Top := lblVersion.Top-392;
    lblTerminal.Caption :='Terminal:'+GetTerminalName(iTerminal) ;
end;


procedure TfMainForm.btn1Click(Sender: TObject);
var i:Integer;
sNextProcess,sEmpNO,iResult:string;
iDateTime :TDateTime;
begin
  //
    iDateTime := Getsysdate ;
    sEmpNO :=  GetEMPNO ;
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
         Params.ParamByName('tnow').AsDateTime := iDateTime;
         Params.ParamByName('temp').AsString := sEmpNO ;
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
        Params.ParamByName('box').AsString := EdtSN.Text ;
        Open;

    end;
    sNextProcess := QryTemp.FieldByName('next_process_id').AsString;

    with QryTemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'box',ptInput);
        CommandText := ' update sajet.g_sn_status set wip_process = '+sNextProcess+'  where box_no=:box and work_flag = 0 ';
        Params.ParamByName('box').AsString := EdtSN.Text ;
        execute;
    end;

    SProc.Close;
    SProc.DataRequest('SAJET.CCM_QC_PANEL_SPLIT_LOT');
    SProc.FetchParams;
    SProc.Params.ParamByName('TREV').AsString := Trim(EdtSN.Text);
    SProc.Params.ParamByName('TEMPID').AsString := UpdateUserID;
    SProc.Execute;
    iResult :=SProc.Params.ParamByName('TRES').AsString;
    
    EdtSN.Clear;
    EdtSN.SetFocus;
    if iResult <>'OK' then
    begin
        msgPanel.Color := clRed;
        msgPanel.Caption := iResult ;
        Exit;
    end;
    msgPanel.Color := clGreen;
    msgPanel.Caption := '更新完成';
    edtDefect.Text :='';
    edtDefect.SetFocus;
    lvData.Items.Clear;
    EdtSN.Text :='';
    EdtSN.SetFocus;
    msgPanel.Caption :='OK';
    msgPanel.Color :=clGreen;
    IsInputDefect :=false;

end;

procedure TfMainForm.cmbSerialSelect(Sender: TObject);
var IsFound :Boolean;
    i:Integer;
    sTemp:string;
begin
 if IsInputDefect  then
   begin
        with QryTemp do
        begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString,'box',ptInput);
            QryTemp.CommandText := ' select serial_number,customer_sn from sajet.g_sn_status where serial_number =:box ';
            Params.ParamByName('box').AsString := EdtSN.Text +cmbSerial.Text;
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

                     if lvdata.Items[i].Caption <> EdtSN.Text then
                     begin
                          EdtSN.Text :='';
                          EdtSN.setfocus;
                          msgpanel.Caption :='ERROR Panel';
                          msgpanel.Color := clRed;
                          Exit;
                     end;
                end;

                if not IsFound then
                begin
                    with lvData.Items.Add do
                    begin
                        Caption :=EdtSN.Text;
                        SubItems.Add(QryTemp.FieldByName('Serial_number').AsString);
                        SubItems.Add(QryTemp.FieldByName('Customer_sn').AsString);
                        SubItems.Add(sDefectCode);
                        SubItems.Add(sDefectDesc);
                        SubItems.Add(cmbSerial.Text);
                    end;
                end;
            end else begin
                msgpanel.Caption :='序號錯誤';
                msgpanel.Color := clRed;
            end;
        end;
   end;
end;

procedure TfMainForm.edtDefectKeyPress(Sender: TObject; var Key: Char);
//var sDefectID,sDefectCode,sDefectDesc :string;
begin
   if Key <> #13 then Exit;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'ErrorCode',ptInput);
    QryTemp.CommandText :='Select Defect_id,Defect_Desc from sajet.SYS_DEFECT where Defect_Code =:ErrorCode ';
    QryTemp.Params.ParamByName('ErrorCode').AsString := edtDefect.Text;
    QryTemp.Open;

    if not QryTemp.IsEmpty then
    begin
        sDefectID := QryTemp.fieldbyName('Defect_id').AsString;
        sDefectCode :=  edtDefect.Text ;
        sDefectDesc :=  QryTemp.fieldbyName('Defect_Desc').AsString;
        IsInputDefect := True;
    end else
    begin
        msgPanel.Color :=clRed;
        msgPanel.Caption :='NO DEFECT CODE';
        edtDefect.SetFocus;
        edtDefect.Clear;
        IsInputDefect :=false;
        Exit;
    end;
end;

end.











