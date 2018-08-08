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
    DateStart: TDateTimePicker;
    DateEnd: TDateTimePicker;
    Label15: TLabel;
    cmbLine: TComboBox;
    Label3: TLabel;
    LstProcess: TListBox;
    LstPallet: TListBox;
    LstCarton: TListBox;
    Label4: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label5: TLabel;
    LabReworkNo: TLabel;
    editReworkNO: TEdit;
    Label17: TLabel;
    Bevel1: TBevel;
    DBGrid1: TDBGrid;
    editWO: TEdit;
    Label8: TLabel;
    LabRoute: TLabel;
    cmbRoute: TComboBox;
    LabInProcess: TLabel;
    cmbProcess: TComboBox;
    Bevel2: TBevel;
    sbtnSearch: TSpeedButton;
    DataSource1: TDataSource;
    SbtnProcess: TSpeedButton;
    SbtnPallet: TSpeedButton;
    SbtnCarton: TSpeedButton;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Label6: TLabel;
    editStartSN: TEdit;
    Label12: TLabel;
    editEndSN: TEdit;
    cmbLot: TComboBox;
    chkbPacking: TCheckBox;
    chkbQC: TCheckBox;
    LabPacking: TLabel;
    LabQC: TLabel;
    editRWWO: TEdit;
    sbtnWOSearch: TSpeedButton;
    LabRWWO: TLabel;
    chkbCSN: TCheckBox;
    LabNewCSN: TLabel;
    chkbPallet: TCheckBox;
    LabPallet: TLabel;
    chkRWWo: TCheckBox;
    ChkbDate: TCheckBox;
    Label1: TLabel;
    chkbBox: TCheckBox;
    Label2: TLabel;
    chkbKeypart: TCheckBox;
    lblKeyPart: TLabel;
    procedure editReworkNOKeyPress(Sender: TObject; var Key: Char);
    procedure editWOKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnSearchClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmbRouteChange(Sender: TObject);
    procedure sbtnExecuteClick(Sender: TObject);
    procedure SbtnProcessClick(Sender: TObject);
    procedure SbtnPalletClick(Sender: TObject);
    procedure SbtnCartonClick(Sender: TObject);
    procedure chkRWWoClick(Sender: TObject);
    procedure editRWWOKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnWOSearchClick(Sender: TObject);
    procedure editRWWOChange(Sender: TObject);
    procedure chkbPackingClick(Sender: TObject);
    procedure chkbPalletClick(Sender: TObject);
    procedure chkbBoxClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
    FCID : String;
    Authoritys,AuthorityRole : String;
    gbRewWO : Boolean;
    G_rModelID, G_rVersion : String;
    procedure ShowQCLot;
    Function CheckReworkNo : Boolean;
    Function CheckWO : Boolean;
    Function GetRouteID(RouteName : String; var RouteId : String) : Boolean;
    Function GetProcessID(ProcessName : String; var ProcessID : String) : Boolean;
    Procedure ShowPDLine;
    procedure ShowRoute;
    procedure ShowRouteProcess;
    Procedure SetStatusbyAuthority;
    procedure SetStatusbyAuthority_Configuration;
    function  checkSN:Boolean;
    procedure SetReworkCondition;
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
      Params.ParamByName('FUN').AsString := 'Execution';
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
         Params.ParamByName('FUN').AsString := 'Rework By Lot Execution';
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
  chkbPacking.Enabled := (iPrivilege>=1);
  chkbPallet.Enabled := chkbPacking.Enabled;
  chkbBox.Enabled := chkbPacking.Enabled;
  chkbQC.Enabled := chkbPacking.Enabled;
  chkbCSN.Enabled := chkbPacking.Enabled;
  LabNewCSN.Enabled := chkbPacking.Enabled;
  LabPacking.Enabled := chkbPacking.Enabled;
  LabQC.Enabled := chkbPacking.Enabled;
  LabPallet.Enabled := chkbPacking.Enabled;
end;

function TfReworkByLot.checkSN:Boolean;
begin
   Result := False;

   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SN', ptInput);
      commandText := 'SELECT ROWID '
                   + '  FROM SAJET.G_SN_STATUS '
                   + ' WHERE WORK_ORDER = ''' + editWO.Text + ''' '
                   + '   AND SERIAL_NUMBER = :SN ';

      Params.ParamByName('SN').AsString := editStartSN.Text;
      Open;
      if Eof then
      begin
         MessageDlg('The Start SN not found !!',mtError,[mbOK],0);
         editStartSN.SelectAll;
         editStartSN.SetFocus;
         Close;
         Exit;
      end;

      Close;
      Params.ParamByName('SN').AsString := editEndSN.Text;
      Open;
      if Eof then
      begin
         MessageDlg('The End SN not found !!',mtError,[mbOK],0);
         editEndSN.SelectAll;
         editEndSN.SetFocus;
         Close;
         Exit;
      end;
      Close;
   end;

   Result := True;
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

Function TfReworkbylot.CheckWO : Boolean;
begin
  Result := True;
  If Trim(editWO.Text) = '' Then
     Exit;

  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'WORK_ORDER', ptInput);
    CommandText := 'Select WORK_ORDER '+
                   'From SAJET.G_WO_BASE '+
                   'Where WORK_ORDER = :WORK_ORDER '+
                   '  and rownum = 1 ';

    Params.ParamByName('WORK_ORDER').AsString := editWO.Text;
    Open;
    Result := (RecordCount > 0);
    Close;
  end;
end;

procedure TfReworkbylot.ShowQCLot;
begin
  cmbLot.Items.Clear;
  With QryTemp do
  begin
    Close;
    Params.Clear;
    {
    CommandText := 'Select QC_LOTNO '+
                   'From SAJET.G_QC_LOT '+
                   'Where QC_RESULT = ''1'' '+
                   'Order By QC_LOTNO ';
                   }
    CommandText :=' SELECT A.QC_LOTNO FROM SAJET.G_QC_LOT A, '
                 +' (SELECT QC_LOTNO,MAX(NG_CNT) NG_CNT  FROM SAJET.G_QC_LOT '
                 +'  GROUP BY QC_LOTNO) B '
                 +'  WHERE A.QC_RESULT=''1'' '
                 +'    AND A.ENABLED = ''Y'' '        //2006/10/17 add
                 +'    AND A.QC_LOTNO = B.QC_LOTNO '
                 +'    AND A.NG_CNT = B.NG_CNT '
                 +'  ORDER BY A.QC_LOTNO ';

    Open;
    cmbLot.Items.Add('');
    While not Eof do
    begin
      cmbLot.Items.Add(Fieldbyname('QC_LOTNO').AsString);
      Next;
    end;
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
begin
  cmbProcess.Items.Clear;
  If cmbRoute.Items.IndexOf(cmbRoute.Text) < 0 Then Exit;
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'ROUTE_NAME', ptInput);
    CommandText := 'Select C.PROCESS_NAME,B.RESULT,B.SEQ '
                 + 'From SAJET.SYS_ROUTE A '
                 +     ',SAJET.SYS_ROUTE_DETAIL B'
                 +     ',SAJET.SYS_PROCESS C '
                 + 'Where A.ROUTE_NAME = :ROUTE_NAME '
                 +   'and A.ROUTE_ID = B.ROUTE_ID '
                 +   'and B.NEXT_PROCESS_ID = C.PROCESS_ID '
                 + 'Order By B.SEQ ';
    Params.ParamByName('ROUTE_NAME').AsString := cmbRoute.Text;
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


Procedure TfReworkbylot.ShowPDLine;
begin
  cmbLine.Items.Clear;
  With QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select PDLINE_NAME '+
                   'From SAJET.SYS_PDLINE '+
                   'Where ENABLED = ''Y'' ';
    If FCID <> '' Then
       CommandText := CommandText + ' and FACTORY_ID = '''+FCID+''' ';
    CommandText := CommandText + 'Order By PDLINE_NAME ';

    Open;
    cmbLine.Items.Add('');
    While not Eof do
    begin
      cmbLine.Items.Add(Fieldbyname('PDLINE_NAME').AsString);
      Next;
    end;
    Close;
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

procedure TfReworkbylot.editWOKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = #13 Then
     CheckWO;
end;

procedure TfReworkbylot.sbtnSearchClick(Sender: TObject);
var sSQL:string;
begin
  QryData.Close;
  editStartSN.Text := trim(editStartSN.Text);
  editEndSN.Text := trim(editEndSN.Text);
  If (editWO.Text = '') and (cmbLot.Text = '') Then
  begin
    MessageDlg('Please Input Work Order or QC Lot !!',mtError, [mbCancel],0);
    Exit;
  end;
  
  if (editStartSN.Text<>'') then
  begin
    if (editEndSN.Text='') then
    begin
      MessageDlg('Please Input End S/N !!',mtError, [mbCancel],0);
      Exit;
    end;
  end;
  if (editEndSN.Text<>'') then
  begin
    if (editStartSN.Text='') then
    begin
      MessageDlg('Please Input Start S/N !!',mtError, [mbCancel],0);
      Exit;
    end;
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
  DateStart.DateTime := now;
  DateEnd.DateTime := now;
  ShowQCLot;
  ShowPDLine;
  ShowRoute;
  If UpdateUserID <> '0' Then
  begin
    SetStatusbyAuthority;
    SetStatusbyAuthority_Configuration;
  end;
  SetReworkCondition;

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
  if chkRWWo.checked then
  begin
    InputKey := #13;
    If not gbRewWO then
    begin
      editRWWOKeyPress(self,InputKey);
      if not gbRewWO then exit;
    end;
  end;  

  if (cmbLot.Text = '') and (lstProcess.Items.Count=0) and (lstpallet.Items.count=0)
       and (lstCarton.Items.Count =0) and (editStartSn.Text ='') and (editEndSN.Text ='') then

   begin
        MessageDlg('Please Select a condition' ,mtError, [mbCancel],0);
        exit;

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

  editReworkNo.Text := trim(editReworkNo.Text);
  If editReworkNO.Text = '' Then
  begin
    MessageDlg('Rework No Error !!',mtError, [mbCancel],0);
    editReworkNo.SetFocus;
    Exit;
  end;
  If not CheckReworkNo Then
  begin
    MessageDlg('Rework No Duplicate !!',mtError, [mbCancel],0);
    editReworkNo.SelectAll;
    editReworkNo.SetFocus;
    Exit;
  end;

  if (chkRWWo.Checked) and (editRWWO.Text=editWO.Text) then
  begin
    MessageDlg('Work Order = New WO !!',mtError, [mbCancel],0);
    editWO.SelectAll;
    editWO.SetFocus;
    Exit;
  end;

  //確認畫面
  fConfirm := TfConfirm.Create(Self);
  With fConfirm do
  begin
    LabReworkNo.Caption := fReworkbylot.editReworkNO.Text;
    LabWO.Caption := fReworkbylot.editWO.Text;
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

  If (editStartSN.Text <> '') or  (editEndSN.Text <> '') then
     if not checkSN then Exit;

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

    //2006/10/17 ADD 記錄此 Rework No 的所有QC批號 ==========================
    if chkbQC.Checked then
    begin
       slQCLot := TStringList.Create;
       getReworkQC(slQCLot);
    end;
    //===================================================================

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
    if chkRWWo.Checked then
      CommandText := CommandText +' ,WORK_ORDER = '''+editRWWO.Text+''' '
                                 +' ,MODEL_ID = '''+G_rModelID+''' '
                                 +' ,VERSION = '''+G_rVersion+''' '
                                 +' ,IN_PDLINE_TIME = NULL '    //20180315 update
                                 +' ,OUT_PDLINE_TIME = NULL '; //20180315 update

    if chkbCSN.Checked then
      CommandText := CommandText +' ,CUSTOMER_SN =''N/A'' ';
    if chkbBox.Checked then
      CommandText := CommandText + ' ,PALLET_NO =''N/A'',CARTON_NO =''N/A'',Box_No=''N/A'' '
    else if chkbPacking.Checked then
      CommandText := CommandText + ' ,PALLET_NO =''N/A'',CARTON_NO =''N/A'' '
    else if (chkbPallet.Checked) and (not chkbPacking.Checked) then
      CommandText := CommandText +' ,PALLET_NO =''N/A'' ';

    IF chkbQC.Checked then
      CommandText := CommandText +' ,QC_NO =''N/A'' '
                                 +' ,QC_RESULT =''N/A'' ';

    CommandText := CommandText +'Where REWORK_NO = :REWORK_NO ';
    Params.ParamByName('ROUTEID').AsString := RouteID;
    Params.ParamByName('PROCESSID').AsString := ProcessID;
    if chkRWWo.Checked then
      Params.ParamByName('WIPPROCESS').AsString := '0'
    else
      Params.ParamByName('WIPPROCESS').AsString := ProcessID;
    Params.ParamByName('REWORK_NO').AsString := editReworkNO.Text;
    Execute;
    Close;

    //20150714檢查Keyparts，Disabled  Dennis Shuai
    if chkbKeyPart.Checked then begin
       Close;
       Params.Clear;
       CommandText := 'UPDATE SAJET.G_SN_KEYPARTS  ' +
                      'SET ENABLED=''N'' ' +
                      ' Where SERIAL_NUMBER IN ( '+
                      '  select serial_number from ( '+ sSQL+' ))';
       Execute;
     end;

    //2006/10/17 Add 檢查QC No是否為空並Disabled ====================
    if chkbQC.Checked then
    begin
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
    end;
    //===============================================================
    ClearData;
    if chkbPacking.Enabled then
      SetReworkCondition;
  end;
  ShowQCLot; //2006/10/18 ADD
  //Close;
end;
procedure TfReworkByLot.ClearData;
begin
  editReworkNO.Text:='';
  cmbLot.ItemIndex := -1;
  editWO.Text :='';
  LstProcess.Items.Clear;
  LstPallet.Items.Clear;
  lstCarton.Items.clear;
  editStartSN.Text :='';
  editEndSn.Text :='';
  QryData.Close;

  editRWWO.Text:='';

  cmbRoute.ItemIndex:=-1;
  cmbProcess.ItemIndex:=-1;
end;

procedure TfReworkbylot.SbtnProcessClick(Sender: TObject);
Var I : Integer;
begin
  If editWO.Text = '' Then
  begin
    MessageDlg('Work Order Empty !!',mtError, [mbCancel],0);
    Exit;
  end;

  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'WO', ptInput);
    CommandText := 'Select C.PROCESS_NAME,B.RESULT,B.SEQ '+
                   'From SAJET.SYS_ROUTE A,'+
                        'SAJET.SYS_ROUTE_DETAIL B,'+
                        'SAJET.SYS_PROCESS C '+
                   'Where A.ROUTE_ID IN ( Select Route_ID '+
                                         'From SAJET.G_WO_BASE '+
                                         'Where WORK_ORDER = :WO '+
                                         'Group By Route_ID ) and '+
                         'A.ROUTE_ID = B.ROUTE_ID and '+
                         'B.NEXT_PROCESS_ID = C.PROCESS_ID '+
                   'Order By B.SEQ ';
    Params.ParamByName('WO').AsString := editWO.Text;
    Open;
  end;

  With TfSelect.Create(Self) do
  begin
     LvItems.Items.Clear;
     Label1.Caption := 'All Process Name List';
     While not QryTemp.Eof do
     begin
       If QryTemp.Fieldbyname('RESULT').AsString = '1' Then
         Break;
       If LvITems.FindCaption(0,QryTemp.Fieldbyname('PROCESS_NAME').AsString,False,False,False) = nil Then
       begin
         With LvItems.Items.Add do
           Caption := QryTemp.Fieldbyname('PROCESS_NAME').AsString;
       end;
       qryTemp.Next;
     end;
     QryTemp.Close;
     If Showmodal = mrOK Then
     begin
       LstProcess.Items.Clear;
       for I := 0 to LvItems.Items.Count - 1 do
       begin
         If LvITems.Items[I].Selected Then
         begin
           LstProcess.Items.Add(LvITems.Items[I].Caption);
         end;
       end;
     end;
     //IF LvItems.Items.Count = LstProcess.Items.Count Then
       //LstProcess.Items.Clear;
     Free;
  end;

end;

procedure TfReworkbylot.SbtnPalletClick(Sender: TObject);
Var I : Integer;
begin
  If editWO.Text = '' Then
  begin
    MessageDlg('Work Order Empty !!',mtError, [mbCancel],0);
    Exit;
  end;

  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'WO' ,ptInput);
    CommandText := 'Select PALLET_NO '+
                   'From SAJET.G_SN_STATUS '+
                   'Where WORK_ORDER = :WO and '+
                         'PALLET_NO <> ''N/A'' '+
                   'Group By PALLET_NO order by pallet_no';
    Params.ParamByName('WO').AsString := editWO.Text;
    Open;
  end;

  With TfSelect.Create(Self) do
  begin
     LvItems.Items.Clear;
     Label1.Caption := 'All Pallet List';
     While not QryTemp.Eof do
     begin
       With LvItems.Items.Add do
         Caption := QryTemp.Fieldbyname('PALLET_NO').AsString;
       qryTemp.Next;
     end;
     QryTemp.Close;
     If Showmodal = mrOK Then
     begin
       LstPallet.Items.Clear;
       for I := 0 to LvItems.Items.Count - 1 do
       begin
         If LvITems.Items[I].Selected Then
         begin
           LstPallet.Items.Add(LvITems.Items[I].Caption);
         end;
       end;
     end;
     //IF LvItems.Items.Count = LstPallet.Items.Count Then
       //LstPallet.Items.Clear;

     Free;
  end;
end;

procedure TfReworkbylot.SbtnCartonClick(Sender: TObject);
Var I : Integer;
begin
  If editWO.Text = '' Then
  begin
    MessageDlg('Work Order Empty !!',mtError, [mbCancel],0);
    Exit;
  end;

  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'WO' ,ptInput);
    CommandText := 'Select CARTON_NO '+
                   'From SAJET.G_SN_STATUS '+
                   'Where WORK_ORDER = :WO and '+
                         'CARTON_NO <> ''N/A'' '+
                   'Group By CARTON_NO order by CARTON_NO ';
    Params.ParamByName('WO').AsString := editWO.Text;
    Open;
  end;

  With TfSelect.Create(Self) do
  begin
     LvItems.Items.Clear;
     Label1.Caption := 'All Carton List';
     While not QryTemp.Eof do
     begin
       With LvItems.Items.Add do
         Caption := QryTemp.Fieldbyname('CARTON_NO').AsString;
       qryTemp.Next;
     end;
     QryTemp.Close;
     If Showmodal = mrOK Then
     begin
       LstCarton.Items.Clear;
       for I := 0 to LvItems.Items.Count - 1 do
       begin
         If LvITems.Items[I].Selected Then
         begin
           LstCarton.Items.Add(LvITems.Items[I].Caption);
         end;
       end;
     end;
     //IF LvItems.Items.Count = LstCarton.Items.Count Then
       //LstCarton.Items.Clear;
     Free;
  end;
end;

Procedure TfReworkbylot.SetReworkCondition;
begin
  chkbPacking.checked := False;
  chkbQC.Checked := False;
  chkbCSN.Checked := False;
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'PARAM_NAME' ,ptInput);

    CommandText := 'Select PARAM_VALUE '+
                   'From SAJET.SYS_BASE '+
                   'Where PARAM_NAME=:PARAM_NAME ';
    Params.ParamByName('PARAM_NAME').AsString := G_sPrgName;
    Open;
    while not eof do
    begin
      if FieldByName('PARAM_VALUE').AsString ='Remove Carton No'  then
        chkbPacking.checked := True;

      if FieldByName('PARAM_VALUE').AsString ='Remove QCLot'  then
        chkbQC.checked := True;
      if FieldByName('PARAM_VALUE').AsString ='Remove CSN'  then
        chkbCSN.checked := True;
      next;
    end;
  end;
end;

procedure TfReworkbylot.chkRWWoClick(Sender: TObject);
begin
  gbRewWO:=False;
  if chkRWWo.Checked then
  begin
    editRWWO.Color:=$00B0FFFF;
    editRWWO.Enabled:=True;
    LabRWWO.Enabled:=True;
    sbtnWOSearch.Enabled:=True;
    editReworkNO.Enabled:=False;
    LabReworkNO.Enabled:=False;

    cmbRoute.Enabled:=False;
    //LabRoute.Enabled:=False;
    cmbProcess.Enabled:=False;
    //LabInProcess.Enabled:=False;

    chkbPacking.Enabled:=False;
    chkbBox.Enabled:=False;
    chkbQC.Enabled:=False;
    //chkbCSN.Enabled:=False;
    chkbPallet.Enabled:=False;

    chkbPacking.checked:=True;
    chkbQC.checked:=True;
    //chkbCSN.checked:=True;
  end else
  begin
    editRWWO.Color:=clWhite;
    editRWWO.Enabled:=False;
    LabRWWO.Enabled:=False;
    sbtnWOSearch.Enabled:=False;
    editReworkNO.Enabled:=True;
    LabReworkNO.Enabled:=True;

    cmbRoute.Enabled:=True;
    //LabRoute.Enabled:=True;
    cmbProcess.Enabled:=True;
    //LabInProcess.Enabled:=True;
    
    If UpdateUserID <> '0' Then
      SetStatusbyAuthority_Configuration;

    SetReworkCondition;
  end;
end;

procedure TfReworkbylot.editRWWOKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 Then
    GET_REWORK_NO;
end;

procedure TfReworkbylot.GET_REWORK_NO;
var sMessage,sRWWO,sReworkNo,sWOStartProcess:string;
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
      Params.ParamByName('WORK_ORDER').AsString := editRWWO.Text;
      Open;
      if RecordCount = 0 then
      begin
        sMessage:='New WO Error';
        exit;
      end;
      case FieldByName('WO_STATUS').AsInteger of
        0: sMessage:='New WO Initial';
        5: sMessage:='New WO Cancel';
        6: sMessage:='New WO Complete';
        7: sMessage:='New WO Delete';
      else
        sRWWO:= editRWWO.Text;
        G_rModelID := FieldByName('MODEL_ID').AsString;
        G_rVersion := FieldByName('VERSION').AsString;
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
                     'Where Rework_No like '''+editRWWO.Text+'%''';
      //Params.ParamByName('WORK_ORDER').AsString := sRWWO;
      Open;
      sReworkNo:= FieldByName('RWNO').asstring;
      if   sReworkNo = '0' then
           sReworkNo := 'NA'
      else begin
          Close;
          Params.Clear;
          //Params.CreateParam(ftString	,'WORK_ORDER' ,ptInput);
          CommandText := 'Select  max( to_number(subStr( REWORK_NO,'+IntToStr(length(editRWWO.Text)+1)+', length(REWORK_NO)- '+IntTOStr(length(editRWWO.Text)) +')))  RWNO ' +
                         'from SAJET.G_REWORK_NO '+
                         'Where Rework_No like '''+editRWWO.Text+'%''';
          //Params.ParamByName('WORK_ORDER').AsString := sRWWO;
          Open;
          sReworkNo:= FieldByName('RWNO').asstring;
      end;
      if sReworkNo = 'NA' then
        editReworkNO.Text := sRWWO + '001'
      else
        editReworkNO.Text := sRWWO + FormatFloat('000', StrToInt(sReworkNo)+1);

      sReworkNo :=  editReworkNO.Text;
      gbRewWO:=True;
      
    end;
  FINALLY
    if sMessage <> '' then
    begin
      MessageDlg(sMessage,mtError,[mbCancel],0);
      editRWWO.SetFocus;
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

procedure TfReworkbylot.editRWWOChange(Sender: TObject);
begin
  gbRewWO:=False;
  editReworkNo.Text:='';
  cmbRoute.ItemIndex := -1;
  cmbProcess.ItemIndex := -1;
end;

procedure TfReworkbylot.chkbPackingClick(Sender: TObject);
begin
  if chkbPacking.Checked then
  begin
    chkbPallet.Checked := False;
    chkbBox.Checked := False;
    chkbQC.Checked := True;
  end;
  chkbQC.Enabled := not chkbPacking.Checked;
end;

procedure TfReworkbylot.chkbPalletClick(Sender: TObject);
begin
  if chkbPallet.Checked then
  begin
    chkbPacking.Checked := False;
    chkbBox.Checked := False;
    chkbQC.Checked := True;
  end;
  chkbQC.Enabled := not chkbPallet.Checked;
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
         + 'From SAJET.G_SN_STATUS A '
         +     ',SAJET.SYS_PROCESS B '
         +     ',SAJET.SYS_PDLINE C '
         + 'Where A.Process_ID = B.Process_ID(+) '
         +   'and A.PDLINE_ID = C.PDLINE_ID(+) '
         +   'and A.WORK_FLAG <> ''1'' ';
    If cmbLot.Text <> '' Then
       sSQL := sSQL + ' and A.QC_NO = '''+cmbLot.Text+''' ';
    If editWO.Text <> '' Then
       sSQL := sSQL + ' and A.WORK_ORDER = '''+editWO.Text+''' ';
    If cmbLine.Text <> '' Then
       sSQL := sSQL + ' and C.PDLINE_NAME = '''+cmbLine.Text+''' ';
    If LstProcess.Items.Count > 0 Then
       sSQL := sSQL + ' and B.Process_Name IN ( '''+ GetData(LstProcess) +''' )';
    If LstPallet.Items.Count > 0 Then
       sSQL := sSQL + ' and A.Pallet_No IN ( '''+ GetData(LstPallet) +''' )';
    If LstCarton.Items.Count > 0 Then
       sSQL := sSQL + ' and A.Carton_No IN ( '''+ GetData(LstCarton) +''' )';
    If (editStartSN.Text <> '') and (editEndSN.Text <> '') then
       sSQL := sSQL + ' and A.SERIAL_NUMBER BETWEEN ''' + editStartSN.Text + ''' '
                    + '                     AND ''' + editEndSN.Text + ''' ';
    If ChkbDate.Checked Then
       sSQL := sSQL + ' and to_char(OUT_PROCESS_TIME,''yyyymmdd'') between '''+formatDateTime('yyyymmdd',DateStart.date)+''' '
                    + '                                            and '''+formatDateTime('yyyymmdd',DateEnd.date)+''' ';
end;

procedure TfReworkbylot.chkbBoxClick(Sender: TObject);
begin
  if chkbBox.Checked then
  begin
    chkbPacking.Checked := False;
    chkbPallet.Checked := False;
    chkbQC.Checked := True;
  end;
  chkbQC.Enabled := not chkbBox.Checked;
end;

end.
