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
    ImageAll: TImage;
    pgc1: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    lbl1: TLabel;
    Label3: TLabel;
    editSN: TEdit;
    cmbBakeLotNo: TComboBox;
    btnNewLot: TSpeedButton;
    lbl2: TLabel;
    lblQty: TLabel;
    lblTerminalIn: TLabel;
    btnOK: TSpeedButton;
    Image1: TImage;
    lblTerminalOut: TLabel;
    lbl4: TLabel;
    Image3: TImage;
    btn1: TSpeedButton;
    lbl5: TLabel;
    edtOutSN: TEdit;
    lbl6: TLabel;
    lblOutQty: TLabel;
    msgPanel: TPanel;
    edtLotNo: TEdit;
    dbgrd1: TDBGrid;
    procedure FormShow(Sender: TObject);
    procedure editSNKeyPress(Sender: TObject; var Key: Char);
    procedure btnNewLotClick(Sender: TObject);
    procedure cmbBakeLotNoSelect(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure edtOutSNKeyPress(Sender: TObject; var Key: Char);
    procedure pgc1Change(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    //m_SNDefectLevel: String;
    
    function GetTerminalName(sTerminalID:string):string;
    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
    function  GetPartID(partno :String) :String;
    procedure ShowData(sCarrier :String;myLabel:Tlabel);
  public
    UpdateUserID,sPartID,sBakeLot : String;
    sPdline,sProcess,sTerminal:string;
    Authoritys,AuthorityRole,FunctionName : String;
    iTerminalin,iTerminalOut:string;
    function  GetSysDate:TDatetime;
    function GetEmpNo:string;
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

procedure TfMainForm.ShowData(sCarrier :String;myLabel:Tlabel);
begin

    with QryData do
   begin

       Close;
       Params.Clear;
       Params.CreateParam(ftString,'Box',ptInput);
       CommandText :='select a.work_order,a.serial_number,a.customer_sn,b.Process_name,a.out_process_time '+
                     ' from sajet.g_sn_status a,sajet.sys_process b where a.box_no =:box'+
                     ' and a.process_id=b.process_id ';
       Params.ParamByName('Box').AsString :=sCarrier;
       Open;
       
   end;
   myLabel.Caption := IntToStr(QryData.RecordCount);
   
end;

procedure TfMainForm.FormShow(Sender: TObject);
var iniFile:TIniFile;
i:Integer;
begin

   if pgc1.ActivePage = ts2 then
         edtOutSN.SetFocus else
    if pgc1.ActivePage = ts1 then
         cmbBakeLotNo.SetFocus;
   cmbBakeLotNo.Style :=csDropDownList;
   iTerminalin :='10013440';
   iTerminalOut :='10013441';
   lblTerminalin.Caption := 'Terminal:'+ GetTerminalName(iTerminalin);
   lblTerminalOut.Caption := 'Terminal:'+ GetTerminalName(iTerminalOut);
   with QryTemp do
   begin
       Close;
       Params.Clear;
       CommandText :=' SELECT  distinct BOX_NO FROM SAJET.G_PACK_BOX WHERE BOX_NO LIKE ''BLOT%'' and CLOSE_FLAG=''N'' ';
       Open;

       cmbBakeLotNo.Items.Clear;
       First;
       for i:=0 to recordcount-1 do
       begin
           cmbBakeLotNo.Items.Add(fieldByName('BOX_NO').AsString);
           Next;
       end;
   end;

end;

procedure TfMainForm.editSNKeyPress(Sender: TObject; var Key: Char);
var iResult,gSN,sBox:String;
begin

   if Key <> #13 then exit;
   if length(editsn.Text)= 0 then exit;

   with QryTemp do
   begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'SN',ptInput);
       CommandText :=' SELECT work_order,serial_number,BOX_NO FROM SAJET.G_SN_STATUS WHERE SERIAL_NUMBER=:SN or Customer_sn=:sn';
       Params.ParamByName('SN').AsString :=editSN.Text;
       Open;
       if IsEmpty then begin
           MessageDlg('NO SN',mtError,[mbOK],0);
           editSN.SetFocus;
           editSN.Clear;
           Exit;
       end;
       gSN := fieldByName('serial_number').AsString;
       sBox:=FieldByName('BOX_NO').AsString ;
       if ( sBox = 'N/A' ) and (cmbBakeLotNo.Text ='') then
       begin
           MessageDlg('NO LOT NO',mtError,[mbOK],0);
           editSN.SetFocus;
           editSN.Clear;
           Exit;
       end;

       if ( Copy(sBox,1,4) ='BLOT' ) and (cmbBakeLotNo.Text <> sBox) then
       begin
           MessageDlg(' LOT No Error',mtError,[mbOK],0);
           editSN.SetFocus;
           editSN.Clear;
           Exit;
       end;

   end;


   Sproc.Close;
   Sproc.DataRequest('SAJET.SJ_CKRT_ROUTE') ;  //---CCM_CHK_GLUE_GO
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TERMINALID').AsString :=iTerminalin;
   SProc.Params.ParamByName('TSN').AsString :=gSN ;
   SProc.Execute;

   iResult := SProc.Params.ParamByName('TRES').AsString;

   if iResult <> 'OK' then
   begin
        MessageDlg(iResult,mtError,[mbOK],0);
        editSN.SetFocus;
        editSN.Clear;
        Exit;
   end;

   with QryTemp do
   begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'Box',ptInput);
       Params.CreateParam(ftString,'SN',ptInput);
       CommandText :=' Update SAJET.G_SN_STATUS Set Box_no=:box  WHERE SERIAL_NUMBER=:SN   ';
       Params.ParamByName('SN').AsString :=gSN;
       Params.ParamByName('Box').AsString :=cmbBakeLotNo.Text;
       Execute;

   end;

   ShowData(cmbBakeLotNo.Text,lblQty);
   editSN.SetFocus;
   editSN.Clear;
end;

procedure TfMainForm.btnNewLotClick(Sender: TObject);
begin
   with QryTemp do
   begin

       Close;
       Params.Clear;
       CommandText :='select  ''BLOT''||to_Char(sysdate,''YYMMDD'')||Translate(lpad(sj.CCM_AF_BAKE_LOT.NEXTVAL,5),'' '',''0'')'+
                       '  l_str from dual';
       Open;
       
       sBakeLot :=  fieldbyname('l_str').AsString;
       cmbBakeLotNo.Items.Add(sBakeLot);
       cmbBakeLotNo.ItemIndex :=cmbBakeLotNo.Items.IndexOf(sBakeLot);
       //cmbBakeLotNo.Text := sBakeLot;

       Close;
       Params.Clear;
       Params.CreateParam(ftString,'update_userId',ptInput);
       Params.CreateParam(ftString,'Box',ptInput);
       CommandText :='Insert into sajet.g_pack_box(work_order,Model_id,BOX_NO,CLOSE_FLAG,'+
                     ' TERMINAL_ID,CREATE_EMP_ID,CREATE_TIME,PKSPEC_NAME)  Values(''AF BAKE'',0,:BOX,''N'','+
                     ' 0,:update_userId,sysdate,''N/A'' )';
       Params.ParamByName('update_userId').AsString :=UpdateUserID;
       Params.ParamByName('Box').AsString :=cmbBakeLotNo.Text;
       Execute;

       editSN.SetFocus;
       
   end;

end;

procedure TfMainForm.cmbBakeLotNoSelect(Sender: TObject);
begin
    //
    ShowData(cmbBakeLotNo.Text,lblQty);
    editSN.SetFocus;

end;

procedure TfMainForm.btnOKClick(Sender: TObject);
begin

   Sproc.Close;
   Sproc.DataRequest('SAJET.sj_panel_go2') ;
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminalin;
   Sproc.Params.ParamByName('TDEFECT').AsString :='N/A';
   Sproc.Params.ParamByName('TREV').AsString :=cmbBakeLotNo.Text;
   Sproc.Params.ParamByName('TNOW').AsDateTime :=GetSysDate;
   Sproc.Params.ParamByName('TEMP').AsString :=GetEMPNO;
   Sproc.Execute;
   with QryTemp do
   begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'Box',ptInput);
       CommandText :='update  sajet.g_pack_box  set  CLOSE_FLAG=''Y'' '+
                         ' where box_no=:box ';
       Params.ParamByName('Box').AsString :=cmbBakeLotNo.Text;
       Execute;
   end;

   cmbBakeLotNo.Style := csDropDown;
   cmbBakeLotNo.Text :='';
   cmbBakeLotNo.ItemIndex :=-1;
   //cmbBakeLotNo.OnSelect(Self);
   cmbBakeLotNo.Style := csDropDownList;
   cmbBakeLotNo.Items.Delete(cmbBakeLotNo.Items.IndexOf(cmbBakeLotNo.Text));
   QryData.Active :=false;
   lblQty.Caption :='0';

end;

procedure TfMainForm.edtOutSNKeyPress(Sender: TObject; var Key: Char);
var gsn,sBox,iResult:string;
allBakeMin,iBakeMin:Integer;

begin
   //
   if Key<>#13 then exit;
   with QryTemp do
   begin

       Close;
       Params.Clear;
       CommandText :=' SELECT  PARAM_VALUE  FROM SAJET.SYS_BASE '+
                     ' WHERE  PARAM_NAME =''AF_BAKE_Min'' ';
       Open;
       AllBakeMin := FieldByName('PARAM_VALUE').AsInteger ;

       Close;
       Params.Clear;
       Params.CreateParam(ftString,'SN',ptInput);
       CommandText :=' SELECT work_order,serial_number,BOX_NO , ' +
                     ' ROUND((SYSDATE-Out_PROCESS_TIME)*24*60,0) BAKE_MIN  FROM SAJET.G_SN_STATUS'+
                     ' WHERE SERIAL_NUMBER=:SN or Customer_sn=:sn';
       Params.ParamByName('SN').AsString :=edtOutSN.Text;
       Open;

       if IsEmpty then
       begin
           msgPanel.Color :=clRed;
           msgPanel.Caption := 'NO SN';
           edtOutSN.Clear;
           edtOutSN.SetFocus;
           Exit;
       end;

       gSN := fieldByName('serial_number').AsString;
       sBox:= FieldByName('BOX_NO').AsString ;
       iBakeMin := FieldByName('BAKE_MIN').AsInteger ;


   end;

   Sproc.Close;
   Sproc.DataRequest('SAJET.SJ_CKRT_ROUTE') ;  //---CCM_CHK_GLUE_GO
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TERMINALID').AsString :=iTerminalOut;
   SProc.Params.ParamByName('TSN').AsString :=gSN;
   SProc.Execute;
   iResult := SProc.Params.ParamByName('TRES').AsString;

   if iResult <>'OK' then
   begin
       msgPanel.Color :=clRed;
       msgPanel.Caption := iResult;
       edtOutSN.Clear;
       edtOutSN.SetFocus;
       edtLotNo.Clear;
       Exit;
   end;


   if Copy(sBox,1,4) <> 'BLOT' then
   begin
       msgPanel.Color :=clRed;
       msgPanel.Caption := 'NO LOT NO';
       edtOutSN.Clear;
       edtOutSN.SetFocus;
       Exit;
   end;



   if iBakeMin<allBakeMin then
   begin
       msgPanel.Color :=clRed;
       msgPanel.Caption := '烘烤時間為'+IntToStr(iBakeMin)+'分鐘,不足'+IntToStr(AllBakeMin)+'分鐘' ;
       edtOutSN.Clear;
       edtOutSN.SetFocus;
       edtLotNo.Clear;
       Exit;
   end;

   edtLotNo.Text :=sBox;
   ShowData(edtLotNo.Text,lblOutQty);
    msgPanel.Color :=clGreen;
   msgPanel.Caption := '烘烤完成';

end;

procedure TfMainForm.pgc1Change(Sender: TObject);
begin
    if pgc1.ActivePage = ts2 then
         edtOutSN.SetFocus else
    if pgc1.ActivePage = ts1 then
         cmbBakeLotNo.SetFocus;
end;

procedure TfMainForm.btn1Click(Sender: TObject);
begin
   if edtLotNo.Text ='' then Exit;

   sproc.Close;
   sproc.DataRequest('SAJET.sj_panel_go2') ;
   sproc.FetchParams;
   sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminalOut;
   sproc.Params.ParamByName('TDEFECT').AsString :='N/A';
   sproc.Params.ParamByName('TREV').AsString :=edtLotNo.Text;
   sproc.Params.ParamByName('TNOW').AsDateTime := GetSysDate;
   sproc.Params.ParamByName('TEMP').AsString :=GetEMPNO;
   sproc.Execute;

   with QryTemp do
   begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'Box',ptInput);
       CommandText :='update  sajet.g_sn_status  set  BOX_NO=''N/A'' '+
                         ' where box_no=:box ';
       Params.ParamByName('Box').AsString :=edtLotNo.Text;
       Execute;
   end;
   edtOutSN.Text :='';
   edtLotNo.Text :='';

end;

end.
