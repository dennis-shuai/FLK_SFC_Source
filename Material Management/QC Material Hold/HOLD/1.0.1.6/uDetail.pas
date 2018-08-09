unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles, IdMessage, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdMessageClient, IdSMTP;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryMaterial: TClientDataSet;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    edtMaterial: TEdit;
    lablType: TLabel;
    lablMsg: TLabel;
    LabQTY: TLabel;
    Image2: TImage;
    sbtnHold: TSpeedButton;
    ImageAll: TImage;
    Label2: TLabel;
    btnNewLot: TSpeedButton;
    mmoReason: TMemo;
    Label3: TLabel;
    Label4: TLabel;
    cmbLot: TComboBox;
    ds1: TDataSource;
    dbgrd1: TDBGrid;
    QryData: TClientDataSet;
    IdSMTP1: TIdSMTP;
    IdMessage1: TIdMessage;
    mmo1: TMemo;
    procedure edtMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure edtLotKeyPress(Sender: TObject; var Key: Char);
    procedure btnNewLotClick(Sender: TObject);
    procedure cmbLotSelect(Sender: TObject);
    procedure sbtnHoldClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID,sLot,sFileName: string;
    function  getMaxLot():string;
    function  AddZero(s:string;HopeLength:Integer):String;
    procedure ListLotNo();
    procedure ShowMateral;
    function  GetSysDate:TDateTime;
    function  GetEmpName:String;
    procedure SendMail(AddressList:TStringList);
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, DllInit;



procedure TfDetail.edtMaterialKeyPress(Sender: TObject; var Key: Char);
var sResult:string;
begin
    if Key <>#13 then exit;
    if cmbLot.ItemIndex<0 then
    begin
        MessageDlg('Please Select Lot No',mtError,[mbOK],0);
        edtMaterial.SetFocus;
        Exit;
    end;

    with SProc do
    begin
       Close;
       DataRequest('SAJET.CCM_MATERIAL_HOLD');
       FetchParams;
       Params.ParamByName('TLotNO').AsString :=sLot;
       Params.ParamByName('tmaterial_no').AsString :=edtMaterial.Text;
       Params.ParamByName('tempid').AsString :=UpdateUserID;
       Params.ParamByName('tremarks').AsString :='';
       execute;

       sResult := Params.ParamByName('tres').AsString;

       if sResult <> 'OK' then begin
          MessageDlg(sResult,mtError,[mbOK],0);
          edtMaterial.SetFocus;
          edtMaterial.SelectAll;
          Exit;
       end;

    end;
    cmbLotSelect(Sender);
    edtMaterial.SetFocus;
    edtMaterial.SelectAll;
end;

procedure TfDetail.ShowMateral;
begin
    with QryMaterial do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'Lot',ptInput);
        CommandText :=' select a.Lot_No,b.part_no,a.material_no,a.material_qty,a.reel_no,a.reel_qty,c.mfger_Name,c.mfger_part_No '+
                      ' from sajet.g_material_holds a,sajet.sys_part b,sajet.G_material_hold_Detail c '+
                      ' where a.Lot_no =:lot and a.part_id=b.part_id and a.part_id=c.part_id and a.material_no=c.material_No '+
                      ' and nvl(a.reel_no,''N/A'')=nvl(c.reel_no,''N/A'') and a.part_id is not null ';
        Params.ParamByName('Lot').AsString := slot;
        Open;

    end;
end;


procedure TfDetail.FormShow(Sender: TObject);
begin
   edtMaterial.SetFocus;
   ListLotNo;
end;

procedure TfDetail.edtLotKeyPress(Sender: TObject; var Key: Char);
begin

//
end;

procedure TfDetail.ListLotNo ;
var i:integer;
begin
   with QryTemp do
   begin
       Close;
       Params.Clear;
       CommandText :=' select distinct Lot_No from sajet.g_material_holds '+
                     ' where Hold_Time is null order by Lot_no';
       Open;

       cmbLot.Items.Clear;
       cmbLot.Style := csDropDownList;
       First;
       for i:=0 to RecordCount-1 do
       begin
           cmbLot.Items.Add(fieldbyName('Lot_No').AsString);
           Next;
       end;

   end;

end;

function   TfDetail.getMaxLot:string;
var stemp,sReulst:string;
sID:Integer;
begin
   with QryTemp do
   begin
       Close;
       Params.Clear;
       CommandText :='select nvl(max(Lot_No ),0) max_lot from sajet.g_material_holds ';
       Open;

       stemp := fieldByName('max_lot').AsString;
       if IsEmpty or (stemp = '0')  then
           sReulst := 'MH00001'
       else begin
           siD := StrToInt(Copy(stemp,3, Length(stemp)-2))+1 ;
           sReulst := 'MH'+AddZero(IntToStr(sid),5) ;
       end;

       Close;
       Params.Clear;
       Params.CreateParam(ftString,'Lot',ptInput);
       CommandText :=' insert into  sajet.g_material_holds(Lot_No) values(:lot) ';
       Params.ParamByName('Lot').AsString := sReulst;
       Execute;

       Result :=sReulst;


   end;

end;

function TfDetail.AddZero(s:string;HopeLength:Integer):String;
begin
   Result:=StringReplace(Format('%'+IntToStr(HopeLength)+'s',[s]),' ','0',[rfIgnoreCase,rfReplaceAll]);
end;


procedure TfDetail.btnNewLotClick(Sender: TObject);
begin
   sLot := getMaxLot;
   ListLotNo;
   cmbLot.ItemIndex  := cmbLot.Items.IndexOf(sLot);
   edtMaterial.SetFocus;
end;

procedure TfDetail.cmbLotSelect(Sender: TObject);
begin

    sLot := cmbLot.Items.Strings[cmbLot.ItemIndex];
    with QryTemp do
    begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'Lot',ptInput);
       CommandText :=' select remarks,nvl(sum(decode(reel_qty,null,material_qty,reel_qty)),0)  '+
                     ' total_Qty from sajet.g_material_holds where Lot_no=:lot group by remarks ';
       Params.ParamByName('Lot').AsString := sLot;
       Open;
       if IsEmpty then begin
           LabQTY.Caption :='0';
       end else  begin
           LabQTY.Caption := fieldByName('total_Qty').AsString+'PCS';
           mmoReason.Text := fieldByName('Remarks').AsString;
       end;

    end;
    ShowMateral;
    edtMaterial.SetFocus;
end;


procedure TfDetail.SendMail(AddressList:TStringList);
var i,LowerCount:integer;
    sMaileMessage:string;
begin

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.CommandText :=' select Host_Name,port,user_Name,trim(sajet.password.decrypt(passwd)) pwd '+
                     ' from sajet.alarm_server_detail where server_id=1 ';
    QryTemp. Open;

    if QryTemp.IsEmpty then exit;

    IdSMTP1.Host :=  QryTemp.fieldByName('Host_Name').AsString;
    IdSMTP1.Port :=  QryTemp.fieldByName('port').AsInteger;
    IdSMTP1.Username := QryTemp.fieldByName('User_Name').AsString;
    IdSMTP1.Password := QryTemp.fieldByName('pwd').AsString;
    IdSMTP1.AuthenticationType := atLogin;


    try
          IdSMTP1.Connect;
          with IdMessage1 do
          begin
              //CharSet := 'UTF-8';//'gb2312'; --UTF-8
              //ContentType := 'text/html';
              Subject:= FormatDateTime('YYYY/MM/DD',GetSysDate)+' 物料Hold提醒';
              From.Address:='MES_Sajet@foxlink.com';

              for i :=0 to  AddressList.Count-1 do begin
                 Recipients.Add;
                 Recipients[i].Address:= AddressList.Strings[i];
              end;
              mmo1.Lines.Add('Dear All:') ;
              mmo1.Lines.Add('  '+   FormatDateTime('YYYY/MM/DD',GetSysDate )+' 物料Hold提醒如下:');
              mmo1.Lines.Add('     總數:'+LabQty.Caption);
              QryMaterial.first;
              for i:=0 to  QryMaterial.RecordCount-1 do   begin
                  if  QryMaterial.fieldByName('Reel_no').AsString='' then
                      mmo1.Lines.Add('     料號:'+QryMaterial.fieldByName('Part_no').AsString +
                                    ' 數量:'+QryMaterial.fieldByName('Material_qty').AsString  +
                                    ' 廠商:'+QryMaterial.fieldByName('Mfger_Name').AsString )
                  else
                      mmo1.Lines.Add( '     料號:'+QryMaterial.fieldByName('Part_no').AsString +
                                    ' 數量:'+QryMaterial.fieldByName('reel_qty').AsString +
                                    ' 廠商:'+QryMaterial.fieldByName('Mfger_Name').AsString );
                  QryMaterial.Next;
              end;
              mmo1.Lines.Add('     原因:'+mmoReason.Text );
              mmo1.Lines.Add(' Hold人員:'+GetEmpName );

              Body.Clear;
              Body.Add(mmo1.Text);
          end;
         { attachmentFilePath:=sFileName;
          if FileExists(attachmentFilePath) then
          begin
              TIdAttachment.Create(IdMessage1.MessageParts,attachmentFilePath);
          end; }

          IdSMTP1.Send(IdMessage1);
    finally
        IdSMTP1.Disconnect;
        //IdSMTP1.Free;
    end;
end;


procedure TfDetail.sbtnHoldClick(Sender: TObject);
var Addresslist:TStringList;
i:Integer;
begin
   if cmbLot.ItemIndex = -1 then begin
       MessageDlg('Lot No Error',mtError,[mbOK],0);
       Exit;
   end;
   if  mmoReason.Text='' then begin
       MessageDlg('Reason Error',mtError,[mbOK],0);
       Exit;
   end;

   with QryData do
   begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'Lot',ptInput);
       Params.CreateParam(ftString,'sremark',ptInput);
       Params.CreateParam(ftString,'userid',ptInput);
       Params.CreateParam(ftDateTime,'hold_time',ptInput);
       CommandText :=' Update sajet.g_material_holds set remarks =:sremark,hold_userid=:userid,  '+
                     ' hold_time =:hold_time  where Lot_no=:lot ';
       Params.ParamByName('Lot').AsString := sLot;
       Params.ParamByName('sremark').AsString := mmoReason.Text;
       Params.ParamByName('hold_time').AsDateTime := GetSysDate;
       Params.ParamByName('userid').AsString := UpdateUserID;
       Execute;
   end;
   
   with QryTemp do begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'group_desc',ptInput);
      CommandText :=' select a.member_value from '+
                    ' sajet.alarm_job_member a,sajet.alarm_job_member_group b,sajet.alarm_job_member_link c'+
                    '  where a.member_id=c.member_id and b.mgroup_id=c.mgroup_id and b.Mgroup_desc=:group_desc and a.enabled=''Y'' ';
      Params.ParamByName('group_desc').AsString :='Material';
      Open;
      if not IsEmpty then begin
           Addresslist := TStringList.Create;
           First;
           for i :=0 to recordcount-1 do begin
               Addresslist.Add(fieldbyName('member_value').AsString);
               Next;
           end;
           SendMail(Addresslist);
           Addresslist.Free;
      end;
   end;


   //Addresslist.Add('Dennis_shuai@Foxlink.com');
   mmoReason.Clear;
   edtMaterial.Clear;
   QryMaterial.Close;
   ListLotNo;
   mmo1.Clear;


end;

function TfDetail.GetSysDate:TDateTime;
begin
    with qryTemp do
    begin
       Close;
       Params.Clear;
       CommandText :=' select sysdate idate from dual ';
       Open;
       Result := fieldbyName('iDate').AsDateTime;
    end;
end;

function TfDetail.GetEmpName:string;
begin
    with qryTemp do
    begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'empid',ptInput);

       CommandText :=' select emp_name from sajet.sys_emp where emp_id= :empid';
       Params.ParamByName('empid').AsString := UpdateUserID;
       Open;
       Result := fieldbyName('emp_name').AsString;
    end;
end;

end.

