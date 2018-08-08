unit uReworkbylot;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls,
  Db, DBClient, MConnect, SConnect, IniFiles, ObjBrkr, uSelect, Spin;

type
  TfReworkbylot = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    Image1: TImage;
    sbtnExecute: TSpeedButton;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    Label11: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    LabReworkNo: TLabel;
    editReworkNO: TEdit;
    Label17: TLabel;
    DBGrid1: TDBGrid;
    Label8: TLabel;
    LabRoute: TLabel;
    cmbRoute: TComboBox;
    LabInProcess: TLabel;
    cmbProcess: TComboBox;
    Bevel2: TBevel;
    DataSource1: TDataSource;
    Bevel1: TBevel;
    Label1: TLabel;
    edtSN: TEdit;
    sbtnSearch: TSpeedButton;
    Image3: TImage;
    edtLot: TEdit;
    Label2: TLabel;
    edtPallet: TEdit;
    Label3: TLabel;
    edtCarton: TEdit;
    Label5: TLabel;
    edtBox: TEdit;
    chkQCLot: TCheckBox;
    chkPallet: TCheckBox;
    chkCarton: TCheckBox;
    chkBox: TCheckBox;
    Label6: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    procedure editReworkNOKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnSearchClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmbRouteChange(Sender: TObject);
    procedure sbtnExecuteClick(Sender: TObject);
    procedure sbtnWOSearchClick(Sender: TObject);
    procedure editWOChange(Sender: TObject);
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
    FCID : String;
    Authoritys,AuthorityRole : String;
    gbRewWO : Boolean;
    G_rModelID, G_rVersion ,sWo,sProcessId: String;
    Function CheckReworkNo : Boolean;
    Function GetRouteID(RouteName : String; var RouteId : String) : Boolean;
    Function GetProcessID(ProcessName : String; var ProcessID : String) : Boolean;
    procedure ShowRoute;
    procedure ShowRouteProcess;
    Procedure SetStatusbyAuthority;
    procedure SetStatusbyAuthority_Configuration;
    procedure ClearData;
    procedure GET_REWORK_NO;
    procedure SearchData(var sSQL:string);
    procedure getReworkQC(var slQCLot:TStringList);
    function  checkQCEmpty(sQCLot:String):Boolean;
    procedure disableQCLot(sQCLotList:String);
  end;

var
  fReworkbylot: TfReworkbylot;
const G_sPrgName = 'Rework';

implementation

uses uWOFilter, uConfirm;


{$R *.DFM}

function TfReworkByLot.checkQCEmpty(sQCLot:String):Boolean;
begin
   Result := False;

   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select * From SAJET.G_SN_STATUS '
                   + ' Where QC_NO = ''' + sQCLot + ''' '
                   + '   And Rownum = 1 ';
      Open;
      if Eof then
         Result := True;
      Close;
   end;
end;

procedure TfReworkByLot.disableQCLot(sQCLotList:String);
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Update SAJET.G_QC_LOT '
                   + '   SET ENABLED = ''N'' '
                   + ' Where QC_LOTNO in (' + sQCLotList + ') ';
      Execute;
   end;
end;

procedure TfReworkByLot.getReworkQC(var slQCLot:TStringList);
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select QC_NO '
                   + '  From SAJET.G_SN_STATUS '
                   + ' Where Rework_No = ''' + editReworkNO.Text + ''' '
                   + '   And QC_Result = ''1'' '
                   + ' Group By QC_No ';
      Open;
      while not Eof do
      begin
         slQCLot.Add(FieldByName('QC_NO').AsString);
         Next;
      end;
      Close;
   end;
end;

Procedure TfReworkbylot.SetStatusbyAuthority;
var iPrivilege:integer;
begin
  iPrivilege:=0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := G_sPrgName;
      Params.ParamByName('FUN').AsString := 'QC批退';
      Execute;
      IF Params.ParamByName('TRES').AsString ='OK' Then
      begin
       iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;

      if iPrivilege = 0 then
      begin
         Close;
         DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
         FetchParams;
         Params.ParamByName('EMPID').AsString := UpdateUserID;
         Params.ParamByName('PRG').AsString := G_sPrgName;
         Params.ParamByName('FUN').AsString := 'QC批退';
         Execute;
         IF Params.ParamByName('TRES').AsString ='OK' Then
         begin
            iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
         end;
      end;
    finally
      close;
    end;
  end; 
  sbtnExecute.Enabled := (iPrivilege>=1);
end;

Procedure TfReworkbylot.SetStatusbyAuthority_Configuration;
var iPrivilege:integer;
begin
  iPrivilege:=0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := G_sPrgName;
      Params.ParamByName('FUN').AsString :='Configuration';
      Execute;
      IF Params.ParamByName('TRES').AsString ='OK' Then
      begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;

end;


Function TfReworkbylot.GetRouteID(RouteName : String; var RouteId : String) : Boolean;
begin
  Result := False;
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'ROUTENAME', ptInput);
    CommandText := 'Select ROUTE_ID '+
                   'From SAJET.SYS_ROUTE '+
                   'Where ROUTE_NAME = :ROUTENAME ' ;
    Params.ParamByName('ROUTENAME').AsString := RouteName;
    Open;
    If RecordCount > 0 Then
       RouteId := Fieldbyname('ROUTE_ID').AsString;
    Close;
  end;
  Result := True;
end;

Function TfReworkbylot.GetProcessID(ProcessName : String; var ProcessID : String) : Boolean;
begin
  Result := False;
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'PROCESSNAME', ptInput);
    CommandText := 'Select PROCESS_ID '+
                   'From SAJET.SYS_PROCESS '+
                   'Where PROCESS_NAME = :PROCESSNAME ' ;
    Params.ParamByName('PROCESSNAME').AsString := ProcessName;
    Open;
    If RecordCount > 0 Then
       ProcessID := Fieldbyname('PROCESS_ID').AsString;
    Close;
  end;
  Result := True;
end;

Function TfReworkbylot.CheckReworkNo : Boolean;
begin
  Result := False;  
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'REWORK_NO', ptInput);
    CommandText := 'Select REWORK_NO '+
                   'From SAJET.G_REWORK_NO '+
                   'Where REWORK_NO = :REWORK_NO ';
    Params.ParamByName('REWORK_NO').AsString := editReworkNO.Text;
    Open;
    Result := (RecordCount <= 0);
    Close;
  end;
end;




Procedure TfReworkbylot.ShowRoute;
begin
  cmbRoute.Items.Clear;
  cmbRoute.Items.Add('');
  With QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select ROUTE_NAME '+
                   'From SAJET.SYS_ROUTE '+
                   'Where ENABLED = ''Y'' '+
                   'Order By ROUTE_NAME ';
    Open;
    While not Eof do
    begin
      cmbRoute.Items.Add(Fieldbyname('ROUTE_NAME').AsString);
      Next;
    end;
    Close;
  end;
  If cmbRoute.Items.Count > 0 Then
     cmbRoute.ItemIndex := 0;
  ShowRouteProcess;
end;

Procedure TfReworkbylot.ShowRouteProcess;
var iStep:Integer;
begin
  cmbProcess.Items.Clear;
  If cmbRoute.Items.IndexOf(cmbRoute.Text) < 0 Then Exit;
  With QryTemp do
  begin

    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'ROUTE_NAME', ptInput);
    Params.CreateParam(ftString	,'Process_id', ptInput);
    CommandText := 'Select B.RESULT,B.SEQ '
                 + 'From SAJET.SYS_ROUTE A '
                 +     ',SAJET.SYS_ROUTE_DETAIL B '
                 + 'Where A.ROUTE_NAME = :ROUTE_NAME '
                 + '  and b.next_process_id =:Process_id '
                 +   'and A.ROUTE_ID = B.ROUTE_ID and b.result <>1';
    Params.ParamByName('ROUTE_NAME').AsString := cmbRoute.Text;
    Params.ParamByName('Process_id').AsString := sProcessID;
    Open;
    iStep := FieldByName('SEQ').AsInteger;

    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'ROUTE_NAME', ptInput);
    Params.CreateParam(ftString	,'seq', ptInput);
    CommandText := 'Select C.PROCESS_NAME,B.RESULT,B.SEQ '
                 + 'From SAJET.SYS_ROUTE A '
                 +     ',SAJET.SYS_ROUTE_DETAIL B'
                 +     ',SAJET.SYS_PROCESS C '
                 + 'Where A.ROUTE_NAME = :ROUTE_NAME '
                 +   'and A.ROUTE_ID = B.ROUTE_ID and b.Seq <= :seq '
                 +   'and B.NEXT_PROCESS_ID = C.PROCESS_ID '
                 + 'Order By B.SEQ ';
    Params.ParamByName('ROUTE_NAME').AsString := cmbRoute.Text;
    Params.ParamByName('seq').AsInteger := iStep;
    Open;
    While not Eof do
    begin
      If Fieldbyname('RESULT').AsString = '1' Then
        Break;
      If cmbProcess.Items.IndexOf(Fieldbyname('PROCESS_NAME').AsString) < 0 Then
        cmbProcess.Items.Add(Fieldbyname('PROCESS_NAME').AsString);
      Next;
    end;
    If cmbProcess.Items.Count > 0 Then
      cmbProcess.ItemIndex := 0;
  end;
end;



procedure TfReworkbylot.editReworkNOKeyPress(Sender: TObject;
  var Key: Char);
begin
  If Key = #13 Then
    If not CheckReworkNo Then
    begin
      MessageDlg('Rework No Duplicate !!',mtError, [mbCancel],0);
      Exit;
    end;
end;

procedure TfReworkbylot.sbtnSearchClick(Sender: TObject);
var sSQL:string;
begin
  QryData.Close;

  if edtLot.Text='' then
      edtLot.Text :='N/A';
  if edtPallet.Text='' then
      edtPallet.Text :='N/A';

  if edtCarton.Text='' then
      edtCarton.Text :='N/A';

  if edtBox.Text='' then
      edtBox.Text :='N/A';


  if (edtLot.Text ='N/A') and (edtPallet.Text ='N/A')
    and (edtCarton.Text ='N/A') and  (edtBox.Text ='N/A')  then
  begin
       MessageDlg('Please select a Condition',mtError,[mbOK],0);
       Exit;
  end;


  SearchData(sSQL);
  With QryData do
  begin
    Close;
    Params.Clear;
    CommandText := sSQL;
    CommandText := CommandText + ' Order by A.serial_number,A.Customer_SN';
    Open;
  end;
end;

procedure TfReworkbylot.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80,100);
    800: self.ScaleBy(100,100);
    1024: self.ScaleBy(125,100);
  else
    self.ScaleBy(100,100);
  end;

  With TIniFile.Create('SAJET.ini') do
  begin
     FcID := ReadString('System','Factory','');
     Free;
  end;

  ShowRoute;
  If UpdateUserID <> '0' Then
  begin
    SetStatusbyAuthority;
    SetStatusbyAuthority_Configuration;
  end;

  edtSN.SetFocus;
  //CheckBox透明化 (不要有框框出來)
  {chkRWWo.Brush.style := bsClear;
  SetWindowLong(chkRWWo.Handle, GWL_EXstyle, WS_EX_TRANSPARENT);
  chkbCSN.Brush.style := bsClear;
  SetWindowLong(chkbCSN.Handle, GWL_EXstyle, WS_EX_TRANSPARENT);
  chkbPacking.Brush.style := bsClear;
  SetWindowLong(chkbPacking.Handle, GWL_EXstyle, WS_EX_TRANSPARENT);
  chkbQC.Brush.style := bsClear;
  SetWindowLong(chkbQC.Handle, GWL_EXstyle, WS_EX_TRANSPARENT);
  chkbPallet.Brush.style := bsClear;
  SetWindowLong(chkbPallet.Handle, GWL_EXstyle, WS_EX_TRANSPARENT); }
end;

procedure TfReworkbylot.cmbRouteChange(Sender: TObject);
begin
  ShowRouteProcess;
end;

procedure TfReworkbylot.sbtnExecuteClick(Sender: TObject);
var RouteID,ProcessID,sSQL, sQCLotList : String;
    InputKey :Char;
    slQCLot: TStringList;
    i: Integer;
begin

  InputKey :=#13;
  if not gbRewWO then begin
     edtSNKeyPress(Sender,InputKey);
  end;

  If not QryData.Active Then
  begin
    MessageDlg('Rework Data Search First !!',mtError, [mbCancel],0);
    Exit;
  end;

  sbtnSearchClick(self);
  if not QryData.Active then
    exit;

  IF QryData.RecordCount = 0 then
  begin
    MessageDlg(' No Match S/N to Rework !!',mtError, [mbCancel],0);
    Exit;
  end;
  
  If cmbRoute.Text = '' Then
  begin
    MessageDlg('Rework Way (Route Name) Error !!',mtError, [mbCancel],0);
    Exit;
  end;
  If cmbProcess.Text = '' Then
  begin
    MessageDlg('Rework Way (Input Process) Error !!',mtError, [mbCancel],0);
    Exit;
  end;



  //確認畫面
  fConfirm := TfConfirm.Create(Self);
  With fConfirm do
  begin
    LabReworkNo.Caption := fReworkbylot.editReworkNO.Text;
    LabRoute.Caption := fReworkbylot.cmbRoute.Text;
    LabProcess.Caption := fReworkbylot.cmbProcess.Text;
    LabQty.Caption := IntToStr(fReworkbylot.QryData.RecordCount);
    if ShowModal <> mrOK then
    begin
      free;
      exit;;
    end;
    free;
  end;

  RouteID := '';
  If not GetRouteID(cmbRoute.Text,RouteID) Then Exit;

  ProcessID := '';
  If not GetProcessID(cmbProcess.Text,ProcessID) Then Exit;


  SearchData(sSQL);


  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'REWORK_NO', ptInput);
    CommandText := 'Update SAJET.G_SN_STATUS '
                 + 'Set REWORK_NO = :REWORK_NO '
                 + 'Where SERIAL_NUMBER IN ( '
                 + '  select serial_number from ( '
                 +  sSQL
                 + ' ) '
                 + ')';
    Params.ParamByName('REWORK_NO').AsString := editReworkNO.Text;
    Execute;

    CommandText :=' Insert Into SAJET.G_REWORK_NO '
                 +' (REWORK_NO,EMP_ID,UPDATE_TIME) '
                 +' VALUES '
                 +' (:REWORK_NO,:EMP_ID,SYSDATE) ';
    Params.ParamByName('REWORK_NO').AsString := editReworkNO.Text;
    Params.ParamByName('EMP_ID').AsString := UpdateUserID;
    Execute;    

    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'REWORK_NO', ptInput);
    CommandText := 'Insert Into SAJET.G_REWORK_LOG '+
                   'Select * From SAJET.G_SN_STATUS '+
                   'Where REWORK_NO = :REWORK_NO ';
    Params.ParamByName('REWORK_NO').AsString := editReworkNO.Text;
    Execute;

    slQCLot := TStringList.Create;
    getReworkQC(slQCLot);

    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'ROUTEID', ptInput);
    Params.CreateParam(ftString	,'PROCESSID', ptInput);
    Params.CreateParam(ftString	,'WIPPROCESS', ptInput);
    Params.CreateParam(ftString	,'REWORK_NO', ptInput);
    CommandText := 'Update SAJET.G_SN_STATUS '+
                   'Set ROUTE_ID = :ROUTEID, '+
                       'NEXT_PROCESS = :PROCESSID, '+
                       'WORK_FLAG = Decode(WORK_FLAG,''2'',''0'',WORK_FLAG), '+ //2005/04/26 Add
                       'Current_Status = Decode(Current_Status,''1'',''0'',Current_Status), '+ //2005/12/15 Add
                       'WIP_PROCESS = :WIPPROCESS ';

     CommandText := CommandText + ' ,PALLET_NO =''N/A'',CARTON_NO =''N/A'',Box_No=''N/A'' '+
                                   ' ,QC_NO =''N/A'' ,QC_RESULT =''N/A''';

    CommandText := CommandText +'Where REWORK_NO = :REWORK_NO ';
    Params.ParamByName('ROUTEID').AsString := RouteID;
    Params.ParamByName('PROCESSID').AsString := ProcessID;
    Params.ParamByName('WIPPROCESS').AsString := ProcessID;
    Params.ParamByName('REWORK_NO').AsString := editReworkNO.Text;
    Execute;
    Close;

     if slQCLot.Count <> 0 then
     begin
        for i:=0 to slQCLot.Count-1 do
        begin
           if checkQCEmpty(slQCLot.Strings[i]) then
           begin
              if sQCLotList = '' then
                 sQCLotList := ''''+slQCLot.Strings[i]+''''
              else
                 sQCLotList := sQCLotList+','''+slQCLot.Strings[i]+'''';
           end;
        end;

        if sQCLotList <> '' then
           disableQCLot(sQCLotList);
     end;
     slQCLot.Free;


    ClearData;
  end;

end;
procedure TfReworkByLot.ClearData;
begin
  editReworkNO.Clear;
  edtLot.Clear;
  edtPallet.Clear;
  edtCarton.Clear;
  edtBox.Clear;
  QryData.Close;
  cmbRoute.ItemIndex:=-1;
  cmbProcess.ItemIndex:=-1;
  chkQCLot.Checked :=false;
  chkPallet.Checked :=false;
  chkCarton.Checked :=false;
  chkBox.Checked :=false;
  edtSN.SetFocus;
end;

procedure TfReworkbylot.GET_REWORK_NO;
var sMessage,sReworkNo,sWOStartProcess:string;
begin
  sMessage:='';
  TRY
    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'WORK_ORDER' ,ptInput);

      CommandText := 'Select WORK_ORDER ,WO_STATUS, B.ROUTE_NAME, A.MODEL_ID, A.VERSION '
                   + '      ,C.PROCESS_NAME '
                   + 'From SAJET.G_WO_BASE A '
                   + '    ,SAJET.SYS_ROUTE B '
                   + '    ,SAJET.SYS_PROCESS C '
                   + 'Where WORK_ORDER=:WORK_ORDER '
                   + 'and A.Route_ID = B.Route_ID(+) '
                   + 'and a.START_PROCESS_ID = C.PROCESS_ID ';
      Params.ParamByName('WORK_ORDER').AsString := sWo;
      Open;
      if RecordCount = 0 then
      begin
        sMessage:='WORK ORDER Error';
        exit;
      end;
      case FieldByName('WO_STATUS').AsInteger of
        0: sMessage:='WORK ORDER Initial';
        5: sMessage:='WORK ORDER Cancel';
        6: sMessage:='WORK ORDER Complete';
        7: sMessage:='WORK ORDER Delete';
      end;
      if sMessage <> '' then exit;

      //找Rework WO的Route及Process
      sWOStartProcess := FieldByName('PROCESS_NAME').AsString;
      cmbRoute.ItemIndex := cmbRoute.Items.IndexOf(FieldByName('ROUTE_NAME').AsString);
      ShowRouteProcess;
      //指定到工單的Start Process
      if cmbProcess.Items.IndexOf(sWOStartProcess)<> -1 then
        cmbProcess.ItemIndex:= cmbProcess.Items.IndexOf(sWOStartProcess);

      //找最大Rework No
     
      Close;
      Params.Clear;
      //Params.CreateParam(ftString	,'WORK_ORDER' ,ptInput);
      CommandText := 'Select  NVL(max(REWORK_NO),''0'') RWNO ' +
                     'from SAJET.G_REWORK_NO '+
                     'Where Rework_No like '''+sWo+'%''';
      //Params.ParamByName('WORK_ORDER').AsString := sRWWO;
      Open;
      sReworkNo:= FieldByName('RWNO').asstring;
      if   sReworkNo = '0' then
           sReworkNo := 'NA'
      else begin
          Close;
          Params.Clear;
          //Params.CreateParam(ftString	,'WORK_ORDER' ,ptInput);
          CommandText := 'Select  max( to_number(subStr( REWORK_NO,'+IntToStr(length(sWo)+1)+', length(REWORK_NO)- '+IntTOStr(length(sWO)) +')))  RWNO ' +
                         'from SAJET.G_REWORK_NO '+
                         'Where Rework_No like '''+sWO+'%''';
          //Params.ParamByName('WORK_ORDER').AsString := sRWWO;
          Open;
          sReworkNo:= FieldByName('RWNO').asstring;
      end;
      if sReworkNo = 'NA' then
        editReworkNO.Text := sWo + '001'
      else
        editReworkNO.Text := sWO + FormatFloat('000', StrToInt(sReworkNo)+1);

      sReworkNo :=  editReworkNO.Text;
      gbRewWO:=True;
      
    end;
  FINALLY
    if sMessage <> '' then
    begin
      MessageDlg(sMessage,mtError,[mbCancel],0);
      edtSN.SetFocus;
    end;
  END;
end;

procedure TfReworkbylot.sbtnWOSearchClick(Sender: TObject);
begin
  fSearchWO := TfSearchWO.Create(Self);
  With fSearchWO do
  begin
    QryWO.RemoteServer := fReworkbylot.QryTemp.RemoteServer;
    QryWO.ProviderName := 'DspQryTemp1';

    ShowModal;
    free;
  end;
end;

procedure TfReworkbylot.editWOChange(Sender: TObject);
begin
   gbRewWO:=False;
   editReworkNo.Text:='';
   cmbRoute.ItemIndex := -1;
   cmbProcess.ItemIndex := -1;
end;

procedure TfReworkbylot.SearchData(var sSQL:string);
  Function GetData(LstBox : TListBox) : String;
  Var I : Integer;
  begin
    Result := LstBox.Items.Strings[0];
    for I := 1 to LstBox.Items.Count - 1 do
    begin
      Result := Result + ''',''' + LstBox.Items.Strings[I];
    end;
  end;
begin
    sSQL:= 'Select A.Serial_Number,A.Customer_SN,B.Process_Name '
         + 'From SAJET.G_SN_STATUS A,sajet.sys_process b  '
         +  'where  A.WORK_FLAG <> ''1''  and a.process_id=b.process_id ';
    If ((edtLot.Text <> '') or (edtLot.Text <> 'N/A') ) and chkQCLot.Checked Then
       sSQL := sSQL + ' and A.QC_NO = '''+edtLot.Text+''' ';
    If ((edtPallet.Text <> '') or (edtPallet.Text <> 'N/A') ) and chkPallet.Checked Then
       sSQL := sSQL + ' and A.Pallet_No  = '''+edtPallet.Text+''' ';
    If ((edtCarton.Text <> '') or (edtCarton.Text <> 'N/A') )and chkCarton.Checked Then
       sSQL := sSQL + ' and A.Carton_No  = '''+edtCarton.Text+''' ';
    If ((edtBox.Text <> '') or (edtBox.Text <> 'N/A') )  and chkBox.Checked Then
       sSQL := sSQL + ' and A.box_No  = '''+edtBox.Text+''' ';

end;

procedure TfReworkbylot.edtSNKeyPress(Sender: TObject; var Key: Char);
begin

   if Key<>#13 then Exit;
   with QryTemp do begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'SN',ptInput);
       CommandText :=' select work_order,Qc_no,Pallet_no,Carton_No,Box_no,process_id from sajet.g_sn_status '+
                     ' where serial_number=:SN or customer_sn=:sn ';
       Params.ParamByName('SN').AsString := edtsn.Text;
       Open;
       if IsEmpty then begin
           MessageDlg('NO SN',mtError,[mbOK],0);
           edtSN.SetFocus;
           edtSN.SelectAll;
           Exit;
       end;
       sWo:=fieldbyName('work_order').AsString;
       sProcessId := fieldbyName('process_id').AsString;;
       edtLot.Text :=  fieldByName('Qc_no').AsString;
       edtPallet.Text :=  fieldByName('Pallet_no').AsString;
       edtCarton.Text :=  fieldByName('Carton_no').AsString;
       edtBox.Text :=  fieldByName('Box_no').AsString;
   end;
   GET_REWORK_NO;
   if (edtLot.Text <> '') or (edtLot.Text<>'N/A') then
       chkQCLot.Checked :=True
   else chkQCLot.Checked :=False;
   if (chkQCLot.Checked =False) and (edtPallet.Text <>'') or (edtPallet.Text<>'N/A') then
         chkPallet.Checked :=True ;

end;

end.
