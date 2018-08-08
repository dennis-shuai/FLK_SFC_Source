unit uformMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, uData, Db, DBClient,
  MConnect, SConnect, FileCtrl, ObjBrkr, Menus, DBGrid1, ComCtrls,
  ListView1;

type
  TformMain = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabAppend: TLabel;
    Image2: TImage;
    LabModify: TLabel;
    Image3: TImage;
    LabDelete: TLabel;
    ImgDelete: TImage;
    Label9: TLabel;
    sbtnAppend: TSpeedButton;
    sbtnModify: TSpeedButton;
    Label3: TLabel;
    QryData: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    QryData1: TClientDataSet;
    DataSource2: TDataSource;
    PopupMenu1: TPopupMenu;
    Append1: TMenuItem;
    Modify1: TMenuItem;
    Delete1: TMenuItem;
    DBGrid11: TDBGrid1;
    Sproc: TClientDataSet;
    sbtnDelete: TSpeedButton;
    Image1: TImage;
    sbtnDisAble: TSpeedButton;
    Label1: TLabel;
    cmbType: TComboBox;
    QryHT: TClientDataSet;
    procedure sbtnAppendClick(Sender: TObject);
    procedure sbtnModifyClick(Sender: TObject);
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnDeleteClick(Sender: TObject);
    procedure cmbTypeChange(Sender: TObject);
    procedure sbtnDisAbleClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx : String;
    UpdateUserID : String;
    Authoritys,AuthorityRole : String;
    Function LoadApServer : Boolean;
    procedure showData;
    Procedure SetStatusbyAuthority;
    procedure copytoht(machineid,terminalID,pdlineid:string);
  end;

var
  formMain: TformMain;

implementation

{$R *.DFM}
uses uHistory;

procedure TformMain.copytoht(machineid,terminalID,pdlineid:string);
begin
  with QryHT do
  begin
    close;
    params.Clear;
    commandtext:=' insert into sajet.sys_ht_machine_relation '
               +' select * '
               +' from sajet.sys_machine_relation '
               +' where machine_id = '+''''+MachineID+''''
               +'    and terminal_id = '+''''+TerminalID+''''
               +'    and pdline_id = '+''''+pdlineID+''''
               +'    and rownum = 1 ';
    execute;
    close;
  end;
end;

Procedure TformMain.SetStatusbyAuthority;
var iPrivilege:integer;
begin
  // Read Only,Allow To Change,Full Control
  // Read Only,Allow To Change,Full Control
  iPrivilege:=0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Data Center';
      Params.ParamByName('FUN').AsString :='Machine Relation';
      Execute;
      IF Params.ParamByName('TRES').AsString ='OK' Then
      begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;
  sbtnAppend.Enabled := (iPrivilege >=1);
  Append1.Enabled := sbtnAppend.Enabled ;

  sbtnModify.Enabled := (iPrivilege >=1);
  Modify1.Enabled := sbtnModify.Enabled;

  sbtnDisAble.Enabled := (iPrivilege >=2);
  //Delete1.Enabled := sbtnDelete.Enabled;

  sbtnDelete.Enabled := (iPrivilege >=2);
  Delete1.Enabled := sbtnDelete.Enabled;
  LabDelete.Enabled := sbtnDelete.Enabled;

end;

Function TformMain.LoadApServer : Boolean;
Var F : TextFile;
    S : String;
begin
{  Result := False;
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
  Result := True;}
end;

procedure TformMain.ShowData;
begin
  With QryData do
  begin
     Close;
     if cmbtype.ItemIndex<> 2 then
        Params.CreateParam(ftString	,'Enabled', ptInput);
     commandtext:=' select e.pdline_name M_pdline_name, d.machine_code,a.machine_id,c.pdline_name t_pdline_name,b.terminal_name,a.terminal_id ,e.pdline_id,a.update_time '
                 +' from sajet.sys_machine_relation a,sajet.sys_terminal b,sajet.sys_pdline c,sajet.sys_machine d ,sajet.sys_pdline e '
                 +' where a.machine_id=d.machine_id and a.terminal_id=b.terminal_id '
                 +'     and a.pdline_id= e.pdline_id '
                 +'     and b.pdline_ID=c.pdline_id ';
     if cmbType.ItemIndex<> 2 then
       commandtext:=commandtext+' and a.enabled = :Enabled ';

     if cmbtype.ItemIndex = 0 then
       Params.ParamByName('Enabled').AsString := 'Y'
     else if cmbtype.ItemIndex =  1 then
       Params.ParamByName('Enabled').AsString := 'N';
     Open;
  end;
end;

procedure TformMain.sbtnAppendClick(Sender: TObject);
begin

  try
    fData := TfData.Create(Self);
    //fData.cmbVendor.Enabled:=true;
    fData.MaintainType := 'Append';
    fData.LabType1.Caption := fData.LabType1.Caption + ' Append';
    fData.LabType2.Caption := fData.LabType2.Caption + ' Append';
    If fData.Showmodal = mrOK Then
    begin
       ShowData;
    end;
  finally
    fData.Free;
  end;  
end;

procedure TformMain.sbtnModifyClick(Sender: TObject);
begin
  If not QryData.Active Then
    Exit;

  If QryData.RecordCount = 0 Then
  begin
     MessageDlg('Data not assign !!',mtInformation, [mbOK],0);
     Exit;
  end;

  TRY
    fData := TfData.Create(Self);

    fData.MaintainType := 'Modify';

    fData.cmbMachine.ItemIndex:=fData.cmbMachine.Items.IndexOf(QryData.Fieldbyname('machine_code').aSString);
    fData.cmbMachineID.ItemIndex:=fData.cmbMachine.ItemIndex;
    fData.cmbMachine.Enabled:=false;
    fData.cmbMline.ItemIndex:=fData.cmbMline.Items.IndexOf(Qrydata.fieldbyname('M_pdline_name').AsString);
    fData.cmbMlineID.ItemIndex:=fData.cmbMline.ItemIndex;
    fData.cmbMline.Enabled:=false;
    fData.cmbMlineID.Enabled:=false;
    fData.cmbPdline.ItemIndex:=fData.cmbPdline.Items.IndexOf(QryData.fieldbyname('T_pdline_name').AsString);
    //fData.cmbPdlineID.ItemIndex;=fData.cmbPdline.ItemIndex;
    fData.cmbPdlineChange(self);
    fData.cmbTerminal.ItemIndex:=fData.cmbTerminal.Items.IndexOf(QryData.Fieldbyname('terminal_name').aSString);
    fData.cmbterminalID.ItemIndex:=fData.cmbTerminal.ItemIndex;
    fData.g_terminalID:= fData.cmbterminalID.Text;

    fData.LabType1.Caption := fData.LabType1.Caption + ' Modify';
    fData.LabType2.Caption := fData.LabType2.Caption + ' Modify';
    //fData.ItemID := QryData.Fieldbyname('RecID').aSString;

    If fData.Showmodal = mrOK Then
       ShowData;
  finally
    fData.Free;
  end;

end;

procedure TformMain.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TformMain.FormShow(Sender: TObject);
begin
  //Orderidx := 'ITEM_TYPE_NAME';
  LoadApServer;
  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;
  ShowData;
end;

procedure TformMain.sbtnDeleteClick(Sender: TObject);
begin
  If not QryData.Active Then
    Exit;

  If QryData.RecordCount = 0 Then
  begin
     MessageDlg('Data not assign !!',mtInformation, [mbOK],0);
     Exit;
  end;

  If MessageDlg('Do you want to delete this data ?',mtWarning ,mbOKCancel,0) = mrOK Then
  begin
    With QryTemp do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString	,'MachineID', ptInput);
      Params.CreateParam(ftString	,'PdlineID', ptInput);
      Params.CreateParam(ftString	,'TerminalID', ptInput);
      Params.CreateParam(ftString	,'UserID', ptInput);
      commandtext:='update sajet.sys_machine_relation '
                  +' set update_time = sysdate '
                  +'    ,update_user_id = :UserID '
                  +'    ,Enabled = ''Drop'' '
                  +' where machine_id= :MachineID and terminal_id=:TerminalID and pdline_id=:PdlineID  and rownum =1 ' ;
      Params.ParamByName('MachineID').AsString := QryData.Fieldbyname('Machine_id').AsString;
      Params.ParamByName('PdlineID').AsString := QryData.Fieldbyname('Pdline_id').AsString;
      Params.ParamByName('TerminalID').AsString := QryData.Fieldbyname('Terminal_ID').AsString;
      Params.ParamByName('UserID').AsString := UpdateUserID;
      execute;

      copytoht(QryData.Fieldbyname('Machine_id').AsString,QryData.Fieldbyname('Terminal_id').AsString,QryData.Fieldbyname('Pdline_id').AsString);

      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'MachineID', ptInput);
      Params.CreateParam(ftString	,'PdlineID', ptInput);
      Params.CreateParam(ftString	,'TerminalID', ptInput);
      CommandText := 'Delete sajet.sys_machine_relation  '+
                     'Where machine_id = :MachineID and terminal_id = :terminalID and pdline_id = :PdlineID and rownum=1  ';
      Params.ParamByName('MachineID').AsString := QryData.Fieldbyname('Machine_id').AsString;
      Params.ParamByName('PdlineID').AsString := QryData.Fieldbyname('Pdline_id').AsString;
      Params.ParamByName('TerminalID').AsString := QryData.Fieldbyname('Terminal_id').AsString;
      Execute;
      Close;

      QryData.Delete;
    end;
  end;
end;

procedure TformMain.cmbTypeChange(Sender: TObject);
begin
   if cmbtype.ItemIndex = 0 then
   begin
     sbtnDisAble.Visible:=true;
     Image1.Visible:= sbtnDisAble.Visible;
     sbtnDisAble.Caption:='Disabled';
     sbtnDelete.Visible:=false;
     LabDelete.Visible:= sbtnDelete.Visible;
     imgDelete.Visible:= sbtnDelete.Visible;
   end
   else if cmbtype.ItemIndex = 1 then
   begin
     sbtnDisAble.Visible:=true;
     Image1.Visible:= sbtnDisAble.Visible;
     sbtnDisAble.Caption:='Enabled';
     sbtnDelete.Visible:=true;
     LabDelete.Visible:= sbtnDelete.Visible;
     imgDelete.Visible:= sbtnDelete.Visible;
   end
   else begin
     sbtnDisAble.Visible:=false;
     Image1.Visible:= sbtnDisAble.Visible;
     sbtnDelete.Visible:=false;
     LabDelete.Visible:= sbtnDelete.Visible;
     imgDelete.Visible:= sbtnDelete.Visible;
   end;
   ShowData;
end;

procedure TformMain.sbtnDisAbleClick(Sender: TObject);
var s:string;
begin
  If not QryData.Active Then
    Exit;

  If QryData.RecordCount = 0 Then
  begin
     MessageDlg('Data not assign !!',mtInformation, [mbOK],0);
     Exit;
  end;

  if cmbtype.ItemIndex=2 then exit;

  if cmbtype.ItemIndex=0 then
    s:= 'Do you want to disable this data ?'
  else s:= 'Do you want to enable this data ?';

  If MessageDlg(s,mtWarning ,mbOKCancel,0) = mrOK Then
  begin
    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'MachineID', ptInput);
      Params.CreateParam(ftString	,'PDlineID', ptInput);
      Params.CreateParam(ftString	,'TerminalID', ptInput);
      Params.CreateParam(ftString	,'Enabled', ptInput);
      Params.CreateParam(ftString	,'userid', ptInput);
      CommandText := 'update  sajet.sys_machine_relation  '+
                     'set enabled= :Enabled '+
                     '   ,update_time = sysdate '+
                     '   ,update_user_id = :userid '+
                     'Where machine_id = :MachineID and terminal_id= :TerminalID and pdline_id = :PdlineID and rownum=1  ';
      Params.ParamByName('MachineID').AsString := QryData.Fieldbyname('Machine_id').AsString;
      Params.ParamByName('PdlineID').AsString := QryData.Fieldbyname('pdline_id').AsString;
      Params.ParamByName('TerminalID').AsString := QryData.Fieldbyname('Terminal_id').AsString;
      if cmbTYpe.ItemIndex = 0 then
         Params.ParamByName('Enabled').AsString :='N'
      else Params.ParamByName('Enabled').AsString :='Y' ;
      Params.ParamByName('UserID').AsString := UpdateUserID;
      Execute;
      Close;

    end;
    copytoht(QryData.Fieldbyname('Machine_id').AsString,QryData.Fieldbyname('Terminal_id').AsString,QryData.Fieldbyname('pdline_id').AsString);
    showdata;
  end;
end;

end.
