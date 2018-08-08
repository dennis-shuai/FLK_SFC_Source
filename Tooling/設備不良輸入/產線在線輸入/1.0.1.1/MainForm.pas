unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, MConnect, ObjBrkr, DB, DBClient,
  SConnect,IniFiles;

type
  TuMainForm = class(TForm)
    SimpleObjectBroker1: TSimpleObjectBroker;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SocketConnection1: TSocketConnection;
    Label1: TLabel;
    Panel1: TPanel;
    btnDefect: TButton;
    lbl3: TLabel;
    lbl4: TLabel;
    Panel2: TPanel;
    btnEndRepair: TButton;
    lbl1: TLabel;
    cmbRepair: TComboBox;
    btnStartRepair: TButton;
    lbl5: TLabel;
    cmbEmp: TComboBox;
    lbl6: TLabel;
    lbl7: TLabel;
    lbl8: TLabel;
    Panel3: TPanel;
    lbl9: TLabel;
    cmbMachine: TComboBox;
    lblMachine: TLabel;
    cmbDept: TComboBox;
    lblDept: TLabel;
    lblMfgMsg: TLabel;
    lblSRmsg: TLabel;
    Label2: TLabel;
    cmbType: TComboBox;
    lbl2: TLabel;
    cmbDefect: TComboBox;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure cmbMachineSelect(Sender: TObject);
    procedure cmbDefectSelect(Sender: TObject);
    procedure btnDefectClick(Sender: TObject);
    procedure Label1DblClick(Sender: TObject);
    procedure cmbDeptSelect(Sender: TObject);
    procedure btnStartRepairClick(Sender: TObject);
    procedure cmbEmpSelect(Sender: TObject);
    procedure cmbRepairSelect(Sender: TObject);
    procedure btnEndRepairClick(Sender: TObject);
    procedure cmbTypeSelect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     sToolingID,sToolingSNID,sDept,sDefectId,sReasonId,sEmpId,sType:string;
    function  LoadApServer: Boolean;
    function  GetSysDate:TDateTime;
    procedure CloseApServer;

  end;

var
  uMainForm: TuMainForm;

implementation

{$R *.dfm}


function TuMainForm.LoadApServer: Boolean;
var F: TextFile;
   S: string;
begin
   Result := False;
   SocketConnection1.Connected := False;
   SimpleObjectBroker1.Servers.Clear;
   SocketConnection1.Host:='';
   SocketConnection1.Address:='';
   if  FileExists(GetCurrentDir + '\ApServer.cfg') then
     AssignFile(F, GetCurrentDir + '\ApServer.cfg')
   else
     exit;
   Reset(F);
   while True do
   begin
      Readln(F, S);
      if trim(S) <> '' then
      begin
        SimpleObjectBroker1.Servers.Add;
        SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
        SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
      end else
        Break;
   end;
   CloseFile(F);
   Result := True;
end;

procedure TuMainForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
    if Key = #27  then uMainForm.Close;
end;

procedure TuMainForm.FormShow(Sender: TObject);
var i:Integer;
iFile:TIniFile;
sMachine:String;
begin
    cmbDefect.Style :=csDropDownList;
    cmbRepair.Style :=csDropDownList;
    cmbEmp.Style :=csDropDownList;
    LoadApServer;

    cmbMachine.Items.Clear;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.CommandText :=' SELECT A.TOOLING_Name FROM SAJET.SYS_TOOLING A  '+
                           ' WHERE  A.ENABLED=''Y'' AND A.ISREPAIR_CONTROL =''Y'' '+
                           '   ORDER BY A.TOOLING_Name ';
    QryTemp.Open;
    if QryTemp.IsEmpty then exit;
    QryTemp.First;
    for i:=0 to QryTemp.RecordCount-1 do begin
        cmbType.Items.Add(Qrytemp.fieldbyname('TOOLING_Name').AsString);
        QryTemp.Next;
    end;
    
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Dept_Name',ptInput);
    QryTemp.CommandText :=' SELECT A.emp_no,A.emp_name FROM   SAJET.SYS_EMP A, SAJET.SYS_DEPT B,SAJET.SYS_EMP_DEPT C '+
                          ' WHERE   b.dept_id = c.dept_id and b.dept_Name=:dept_Name and a.emp_id=c.emp_id   '+
                          ' and a.enabled=''Y'' and  b.enabled=''Y'' and  C.enabled=''Y'''+
                          ' and a.emp_no <>''757055'' order by a.emp_no  ';
    QryTemp.Params.ParamByName('Dept_Name').AsString := cmbDept.Text ;
    QryTemp.Open;

    cmbEmp.Items.Clear;
    QryTemp.First;
    for i:=0 to QryTemp.RecordCount-1 do
    begin
        cmbEmp.Items.Add(Qrytemp.fieldbyname('emp_no').AsString+'~~'+Qrytemp.fieldbyname('emp_name').AsString );
        QryTemp.Next;
    end;
    CloseApServer;
    iFile :=TIniFile.Create('SAJET.ini');
    sType := iFile.ReadString('Machine Repair','Machine Type','');
    sMachine := iFile.ReadString('Machine Repair','Machine Name','');
    sToolingSNID :=iFile.ReadString('Machine Repair','Machine ID','');
    sDept :=iFile.ReadString('Machine Repair','Machine Dept','');
    iFile.Free;

     cmbType.ItemIndex := cmbType.Items.IndexOf(sType);
    if  cmbType.ItemIndex >=0 then begin
         cmbType.OnSelect(Self);
    end;

    cmbMachine.ItemIndex := cmbMachine.Items.IndexOf(sMachine);
    if  cmbMachine.ItemIndex >=0 then begin
         lblMachine.Caption := cmbMachine.Text;
         cmbMachine.OnSelect(Self);
    end;

    cmbMachine.Style :=csDropDownList;
    if sDept <> '' then
       cmbDept.ItemIndex :=   cmbDept.Items.IndexOf(sDept);

    if cmbMachine.ItemIndex >=0 then
    begin
       LoadApServer;
       
    end;


    CloseApServer;
end;

function TuMainForm.GetSysDate:TDateTime;
begin
    Qrytemp.Close;
    Qrytemp.CommandText := 'select SysDate from  dual';
    Qrytemp.Open;
    result := Qrytemp.fieldbyname('SYSDate').AsDateTime;
end;


procedure TuMainForm.cmbMachineSelect(Sender: TObject);
var i:Integer;
iFile:TiniFIle;
sEmpno,sempinfo:string;
begin
    lblMachine.Caption := cmbMachine.Text;

    LoadApServer;
    cmbEmp.ItemIndex :=-1;
    cmbRepair.ItemIndex :=-1;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'ToolingSN',ptInput);
    QryTemp.CommandText :=' SELECT   A.tooling_SN_id  FROM  SAJET.SYS_TOOLING_SN A '+
                          ' WHERE  A.ENABLED=''Y'' and  '+
                          ' A.TOOLING_SN = :ToolingSN ' ;
    QryTemp.Params.ParamByName('ToolingSN').AsString := lblMachine.Caption ;
    QryTemp.Open;
    sToolingSNID :=  Qrytemp.fieldbyname('Tooling_SN_ID').AsString ;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'ToolingSN',ptInput);
    QryTemp.CommandText :=' SELECT distinct A.tooling_id, D.Defect_CODE,D.DEFECT_DESC FROM SAJET.SYS_TOOLING A,SAJET.SYS_TOOLING_SN B,'+
                          ' SAJET.SYS_TOOLING_REPAIR_INFO C,SAJET.SYS_DEFECT D '+
                          ' WHERE A.TOOLING_ID=B.TOOLING_ID AND A.ENABLED=''Y'' AND A.ISREPAIR_CONTROL =''Y'' '+
                          ' AND B.ENABLED=''Y'' and B.TOOLING_ID=C.TOOLING_ID AND B.TOOLING_SN = :ToolingSN '+
                          ' AND C.DEFECT_ID=D.DEFECT_ID(+)  order by D.Defect_code' ;
    QryTemp.Params.ParamByName('ToolingSN').AsString := lblMachine.Caption ;
    QryTemp.Open;

    if QryTemp.IsEmpty then exit;
    cmbDefect.Items.Clear;
    QryTemp.First;

    sToolingID :=  Qrytemp.fieldbyname('Tooling_ID').AsString ;
    for i:=0 to QryTemp.RecordCount-1 do
    begin
        cmbDeFect.Items.Add(Qrytemp.fieldbyname('Defect_CODE').AsString+'~~'+Qrytemp.fieldbyname('Defect_DESC').AsString );
        QryTemp.Next;
    end;

    //cmbDefect.ItemIndex := cmbDefect.Items.IndexOf(Qrytemp.fieldbyname('Defect_CODE').AsString+'~~'+Qrytemp.fieldbyname('Defect_DESC').AsString );

    with QryTemp do
    begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString,'toolingSNid',ptInput);
         CommandText :='Select  NVL(b.EMp_no,''N/A'') emp_no , b.Emp_Name,c.defect_code,C.defect_desc, '+
                     '  a.Start_repair_time, a.defect_time  '+
                     ' from sajet.g_tooling_sn_repair a,sajet.sys_emp b,sajet.sys_defect c '+
                     ' where a.tooling_sn_id =:toolingSNid  and a.Repair_memo =''Online Repair'' and '+
                     ' (a.Start_repair_time is null or a.repair_time is Null) and a.defect_time is not null '+
                     ' and a.repair_userid = b.Emp_id(+)  and a.defect_id=c.defect_id(+) ';
         Params.ParamByName('toolingSNid').AsString := sToolingSNID;
         Open;

         if not IsEmpty then
         begin
             sEmpno := FieldByName('emp_no').AsString;
             sempinfo := FieldByName('emp_no').AsString +'~~'+FieldByName('emp_Name').AsString ;

             if  FieldByName('defect_time').AsString <>'' then
             begin
                 btnDefect.Enabled :=false;
             end;

             if  FieldByName('Start_repair_time').AsString <> '' then
             begin
                 btnStartRepair.Enabled :=false;
             end;

             cmbDefect.ItemIndex := cmbDefect.Items.IndexOf(FieldByName('Defect_code').AsString
                      +'~~'+FieldByName('Defect_desc').AsString);

             cmbDefect.OnSelect(Self);


             if sEmpno <> 'N/A' then begin
                 cmbEmp.ItemIndex :=cmbEmp.Items.IndexOf(sempinfo);
                 //cmbEmp.OnSelect(Self);
             end ;



         end;
    end;

    iFile :=TIniFile.Create('SAJET.ini');
    iFile.WriteString('Machine Repair','Machine Type',sType);
    iFile.WriteString('Machine Repair','Machine Name',lblMachine.Caption);
    iFile.WriteString('Machine Repair','Machine ID',sToolingSNID);
    iFile.WriteString('Machine Repair','Machine Dept',cmbDept.Text);
    iFile.Free;

    CloseApServer;
   
end;

procedure TuMainForm.cmbDefectSelect(Sender: TObject);
var i,iPos:Integer;
sDefectCode:string;
begin
    LoadApServer;

    iPos :=AnsiPos('~~',cmbDefect.Text)  ;
    if iPos<=0 then Exit;
    sDefectCode := Copy(cmbDefect.Text,1,iPos-1);


    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'ToolingSN',ptInput);
    QryTemp.Params.CreateParam(ftString,'defect',ptInput);
    QryTemp.CommandText :=' SELECT distinct C.Defect_ID,E.Reason_CODE,E.Reason_DESC FROM SAJET.SYS_TOOLING A,SAJET.SYS_TOOLING_SN B,'+
                          ' SAJET.SYS_TOOLING_REPAIR_INFO C,SAJET.SYS_DEFECT D ,SAJET.SYS_REASON E'+
                          ' WHERE A.TOOLING_ID=B.TOOLING_ID AND A.ENABLED=''Y'' AND A.ISREPAIR_CONTROL =''Y'' '+
                          ' AND B.ENABLED=''Y'' and B.TOOLING_ID=C.TOOLING_ID AND B.TOOLING_SN = :ToolingSN '+
                          ' AND C.DEFECT_ID=D.DEFECT_ID and e.reason_id= c.reason_id and d.defect_Code=:defect ' ;
    QryTemp.Params.ParamByName('ToolingSN').AsString := lblMachine.Caption ;
    QryTemp.Params.ParamByName('defect').AsString := sDefectCode ;
    QryTemp.Open;

    if QryTemp.IsEmpty then exit;
    cmbRepair.Items.Clear;
    QryTemp.First;
    sDefectId :=  Qrytemp.fieldbyname('Defect_id').AsString ;
    for i:=0 to QryTemp.RecordCount-1 do begin
        cmbRepair.Items.Add(Qrytemp.fieldbyname('Reason_CODE').AsString+'~~'+Qrytemp.fieldbyname('Reason_DESC').AsString );
        QryTemp.Next;
    end;
    CloseApServer;
    //btnDefect.Enabled :=True;
   //cmbRepair.Style :=csDropDownList;

end;

procedure TuMainForm.CloseApServer;
begin
    SocketConnection1.Connected := False;
    SimpleObjectBroker1.Servers.Clear;
    SocketConnection1.Host:='';
    SocketConnection1.Address:='';
end;

procedure TuMainForm.btnDefectClick(Sender: TObject);
begin

    if cmbMachine.Text ='' then begin
        MessageDlg('請選擇機台名稱',mtError,[mbOK],0);
        cmbMachine.SetFocus;
        Exit;
    end;

   { if sDefectId = '' then begin
        MessageDlg('請選擇不良歸類',mtError,[mbOK],0);
        cmbDefect.SetFocus;
        Exit;
    end;  }

    LoadApServer;
    with QryTemp do begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'toolingsnid',ptInput);
       CommandText := 'select * from sajet.g_tooling_sn_repair where (start_repair_time is null or '+
                      '  repair_time is null) and tooling_sn_id=:toolingsnid  and Repair_memo =''Online Repair'' ';
       Params.ParamByName('toolingsnid').AsString :=sToolingSNID;
       Open;

       if IsEmpty then
       begin
           try
               Close;
               Params.Clear;
               Params.CreateParam(ftString,'toolingsnid',ptInput);
               CommandText := 'insert into sajet.g_tooling_sn_repair(tooling_SN_id,defect_time,status,repair_memo) '+
                             ' values( :toolingsnid,sysdate,''R'',''Online Repair'') ';
               Params.ParamByName('toolingsnid').AsString :=sToolingSNID;
               Execute;
           except
               lblMfgMsg.Caption :='輸入錯誤';
               lblMfgMsg.Color :=clRed;
               CloseApServer;
               exit;
           end;
           lblMfgMsg.Caption :='輸入OK';
           lblMfgMsg.Color :=clGreen;
       end
       else  begin
             lblMfgMsg.Caption :='不要重複輸入';
             lblMfgMsg.Color :=clRed;
       end;

    end;
    btnDefect.Enabled :=false;
    CloseApServer;
end;

procedure TuMainForm.Label1DblClick(Sender: TObject);
begin
   lblDept.Visible :=True;
   cmbDept.Visible :=True;
end;

procedure TuMainForm.cmbDeptSelect(Sender: TObject);
var iFile:TIniFile;
begin
    iFile :=TIniFile.Create('SAJET.ini');
    iFile.WriteString('Machine Repair','Machine Dept',cmbDept.Text);
    iFile.Free;
    lblDept.Visible :=false;
    cmbDept.Visible :=false;
end;

procedure TuMainForm.btnStartRepairClick(Sender: TObject);
begin
    if cmbEmp.Text ='' then begin
        MessageDlg('請選擇維修人員',mtError,[mbOK],0);
        cmbEmp.SetFocus;
        Exit;
    end;

    LoadApServer;
    with qrytemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'toolingSNid',ptInput);
        CommandText := ' select * from sajet.g_tooling_sn_repair '+
                       ' where tooling_sn_id =:toolingSNid  and Repair_memo =''Online Repair'' and '+
                       ' Start_repair_time is null and defect_Time is not null ';
        Params.ParamByName('toolingSNid').AsString := sToolingSNID;
        Open;

        if IsEmpty then
        begin
            lblSRmsg.Caption :='該機台不在損壞狀態';
            lblSRmsg.Color := clRed;
            CloseApServer;
            Exit;
        end;

        Close;
        Params.Clear;
        Params.CreateParam(ftString,'toolingSNid',ptInput);
        Params.CreateParam(ftString,'EmpId',ptInput);
        CommandText := ' Update sajet.g_tooling_sn_repair  set Start_repair_time = sysdate ,Repair_userID= :empid '+
                       ' where tooling_sn_id =:toolingSNid  and Repair_memo =''Online Repair'' and '+
                       ' Start_repair_time is null and defect_time is not null ';
        Params.ParamByName('toolingSNid').AsString := sToolingSNID;
        Params.ParamByName('EmpID').AsString := sEmpId;
        Execute;

    end;
    btnStartRepair.Enabled :=false;
    CloseApServer;

end;

procedure TuMainForm.cmbEmpSelect(Sender: TObject);
var iPos:Integer;
sEmpNo:string;
begin
//
   LoadApServer;
   iPos := AnsiPos('~~',cmbEmp.Text);
   sEmpId :='';
   sEmpNo := Copy(cmbEmp.Text,1,iPos-1);
   with QryTemp do
   begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'Emp_No',ptInput)  ;
       CommandText :='select emp_id from sajet.sys_emp where emp_no=:emp_No';
       Params.ParamByName('Emp_No').AsString := sEmpno;
       Open;
       sEmpId :=fieldByName('Emp_Id').AsString;
   end;
   btnStartRepair.Enabled :=True;
   CloseApServer;
end;

procedure TuMainForm.cmbRepairSelect(Sender: TObject);
var iPos:Integer;
sDefect:string;
begin

    LoadApServer;
    iPos := AnsiPos('~~',cmbRepair.Text);
    sReasonId :='';
    sDefect := Copy(cmbRepair.Text,1,iPos-1);
    with QryTemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'reason',ptInput)  ;
        CommandText :='select reason_id from sajet.sys_reason where reason_code =:reason';
        Params.ParamByName('reason').AsString := sDefect;
        Open;
        sReasonId :=fieldByName('reason_id').AsString;
    end;
    btnEndRepair.Enabled :=True;
    CloseApServer;
end;

procedure TuMainForm.btnEndRepairClick(Sender: TObject);
begin
    if cmbRepair.Text ='' then begin
        MessageDlg('請選擇維修項目',mtError,[mbOK],0);
        cmbRepair.SetFocus;
        Exit;
    end;

    LoadApServer;
    with qrytemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'toolingSNid',ptInput);
        CommandText := ' select * from sajet.g_tooling_sn_repair '+
                       ' where tooling_sn_id =:toolingSNid  and Repair_memo =''Online Repair'' and '+
                       ' Start_repair_time is not null and defect_time is not null  and Repair_time  is null';
        Params.ParamByName('toolingSNid').AsString := sToolingSNID;
        Open;

        if IsEmpty then
        begin
            lblSRmsg.Caption :='該機台不在維修中';
            lblSRmsg.Color := clRed;
            CloseApServer;
            Exit;
        end;

        Close;
        Params.Clear;
        Params.CreateParam(ftString,'toolingSNid',ptInput);
        Params.CreateParam(ftString,'reason_id',ptInput);
        Params.CreateParam(ftString,'defect_id',ptInput);
        CommandText := ' Update sajet.g_tooling_sn_repair  set repair_time = sysdate ,reason_id = :reason_id ,defect_id=:defect_id '+
                       ' where tooling_sn_id =:toolingSNid  and Repair_memo =''Online Repair'' and '+
                       ' Start_repair_time is not null and defect_time is not null  and repair_time is null ';
        Params.ParamByName('toolingSNid').AsString := sToolingSNID;
        Params.ParamByName('reason_id').AsString := sReasonId;
        Params.ParamByName('defect_id').AsString := sDefectId;
        Execute;

    end;
    btnStartRepair.Enabled :=false;
    btnEndRepair.Enabled :=false;
    btnDefect.Enabled :=True;
    cmbDefect.ItemIndex :=-1;
    cmbRepair.ItemIndex :=-1;
    cmbEmp.ItemIndex :=-1;
    CloseApServer;
end;

procedure TuMainForm.cmbTypeSelect(Sender: TObject);
var i:integer;
begin
    LoadApServer;
    with qrytemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'toolind',ptInput);
        CommandText := ' select b.tooling_sn from sajet.sys_tooling A,sajet.sys_tooling_sn B '+
                       ' where A.tooling_id =b.tooling_id  and  a.Tooling_Name =:toolind and '+
                       ' b.enabled=''Y'' order by b.tooling_sn ';
        Params.ParamByName('toolind').AsString :=  cmbType.Text;
        Open;


        cmbMachine.Items.Clear;
        if IsEmpty then exit;
        First;
        for i:=0 to RecordCount-1 do begin
            cmbMachine.Items.Add(fieldbyname('tooling_sn').AsString);
            Next;
        end;

         sType  := cmbType.Items.Strings[cmbType.ItemIndex];

    end;
    CloseApServer;
end;

end.
