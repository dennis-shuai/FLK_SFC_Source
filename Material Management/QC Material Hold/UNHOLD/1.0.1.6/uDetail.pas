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
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    lablType: TLabel;
    lablMsg: TLabel;
    LabQTY: TLabel;
    Image2: TImage;
    sbtnHold: TSpeedButton;
    ImageAll: TImage;
    Label2: TLabel;
    mmoReason: TMemo;
    Label3: TLabel;
    Label4: TLabel;
    cmbLot: TComboBox;
    ds1: TDataSource;
    dbgrd1: TDBGrid;
    QryData: TClientDataSet;
    IdSMTP1: TIdSMTP;
    IdMessage1: TIdMessage;
    Label5: TLabel;
    mmoRemarks: TMemo;
    edtmaterial: TEdit;
    Label6: TLabel;
    mmo1: TMemo;
    procedure FormShow(Sender: TObject);
    procedure edtLotKeyPress(Sender: TObject; var Key: Char);
    procedure btnNewLotClick(Sender: TObject);
    procedure cmbLotSelect(Sender: TObject);
    procedure sbtnHoldClick(Sender: TObject);
    procedure edtmaterialKeyPress(Sender: TObject; var Key: Char);
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
    procedure SendMail(attachmentFilePath:String;AddressList:TStringList);
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, DllInit;



procedure TfDetail.ShowMateral;
begin
    with QryMaterial do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'Lot',ptInput);
        CommandText :=' select a.Lot_No,b.part_no,a.material_no,a.material_qty,a.reel_no,a.reel_qty,c.mfger_Name,c.mfger_part_No,d.EMp_name,a.Hold_time  '+
                      ' from sajet.g_material_holds a,sajet.sys_part b,sajet.G_material_hold_Detail c,sajet.sys_emp d '+
                      ' where a.Lot_no =:lot and a.part_id=b.part_id and a.part_id=c.part_id and a.material_no=c.material_No '+
                      ' and nvl(a.reel_no,''N/A'')=nvl(c.reel_no,''N/A'') and a.part_id is not null  and a.Hold_userId=d.emp_id';
        Params.ParamByName('Lot').AsString := slot;
        Open;

    end;
end;


procedure TfDetail.FormShow(Sender: TObject);
begin
   mmoRemarks.SetFocus;
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
                     ' where Hold_Time is not null and Unhold_time is null order by Lot_no';
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
   mmoRemarks.SetFocus;
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
    mmoRemarks.SetFocus;
end;


procedure TfDetail.SendMail(attachmentFilePath:String;AddressList:TStringList);
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
              Subject:= FormatDateTime('YYYY/MM/DD',GetSysDate)+' 物料解除Hold提醒';
              From.Address:='MES_Sajet@foxlink.com';

              for i :=0 to  AddressList.Count-1 do begin
                 Recipients.Add;
                 Recipients[i].Address:= AddressList.Strings[i];
              end;
              mmo1.Lines.Add('Dear All:');
              mmo1.Lines.Add(FormatDateTime('    YYYY/MM/DD',GetSysDate )+' 物料解除Hold提醒如下:');
              mmo1.Lines.Add('       總數:'+LabQty.Caption);
              QryMaterial.first;
              for i:=0 to  QryMaterial.RecordCount-1 do   begin
                  if  QryMaterial.fieldByName('Reel_no').AsString='' then
                      mmo1.Lines.Add('       料號:'+QryMaterial.fieldByName('Part_no').AsString +
                                    ' 數量:'+QryMaterial.fieldByName('Material_qty').AsString  +
                                    ' 廠商:'+QryMaterial.fieldByName('Mfger_Name').AsString  )
                  else
                        mmo1.Lines.Add('       料號:'+QryMaterial.fieldByName('Part_no').AsString +
                                    ' 數量:'+QryMaterial.fieldByName('reel_qty').AsString +
                                    ' 廠商:'+QryMaterial.fieldByName('Mfger_Name').AsString);
                  QryMaterial.Next;
              end;
              mmo1.Lines.Add('       Hold時間:'+QryMaterial.fieldByName('Hold_time').AsString );
              mmo1.Lines.Add('       Hold原因:'+mmoReason.Text);
              mmo1.Lines.Add('       Hold人員:'+ QryMaterial.fieldByName('Emp_name').AsString );
              mmo1.Lines.Add('       解除Hold人員:'+GetEmpName);
              mmo1.Lines.Add('       解除Hold說明:'+mmoRemarks.Text );

              Body.Clear;
              Body.Add(mmo1.Text);
          end;
          attachmentFilePath:=sFileName;
          if FileExists(attachmentFilePath) then
          begin
              TIdAttachment.Create(IdMessage1.MessageParts,attachmentFilePath);
          end;
          IdSMTP1.Send(IdMessage1);
    finally
        IdSMTP1.Disconnect;
        //IdSMTP1.Free;
    end;
end;


procedure TfDetail.sbtnHoldClick(Sender: TObject);
var Addresslist:TStringList;
i:Integer;
sResult:string;
begin
   if cmbLot.ItemIndex = -1 then begin
       MessageDlg('Lot No Error',mtError,[mbOK],0);
       Exit;
   end;
   if  mmoRemarks.Text='' then begin
       MessageDlg('remarks Error',mtError,[mbOK],0);
       Exit;
   end;

    with SProc do
    begin
       Close;
       DataRequest('SAJET.CCM_MATERIAL_UNHOLD');
       FetchParams;
       Params.ParamByName('TLotNO').AsString :=sLot;
       Params.ParamByName('tempid').AsString :=UpdateUserID;
       Params.ParamByName('tremarks').AsString :=mmoRemarks.Text;
       execute;

       sResult := Params.ParamByName('tres').AsString;

       if sResult <> 'OK' then begin
          MessageDlg(sResult,mtError,[mbOK],0);
          edtmaterial.SelectAll;
          edtmaterial.SetFocus;
          Exit;
       end;

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
           sFileName :='';
           First;
           for i :=0 to recordcount-1 do begin
               Addresslist.Add(fieldbyName('member_value').AsString);
               Next;
           end;
           SendMail(sFileName,Addresslist);
           Addresslist.Free;
      end;
   end;
   {Addresslist := TStringList.Create;
   Addresslist.Add('Dennis_shuai@Foxlink.com');
   SendMail(sFileName,Addresslist);
   Addresslist.Free; }

   mmoReason.Clear;
   mmoRemarks.Clear;
   //QryMaterial.Close;
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

procedure TfDetail.edtmaterialKeyPress(Sender: TObject; var Key: Char);
begin
   if  Key<>#13 then Exit;
   with QryTemp do
   begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'Material',ptInput);

       CommandText :=' select Lot_no  from sajet.G_material_Holds '+
                     ' where  material_no = :Material or reel_no = :material';
       Params.ParamByName('Material').AsString := edtmaterial.Text;
       Open;
       if IsEmpty then begin
          MessageDlg('No Material',mtError,[mbOK],0);
          edtmaterial.SelectAll;
          edtmaterial.SetFocus;
          Exit;
       end;
       cmbLot.ItemIndex := cmbLot.Items.IndexOf(fieldByName('Lot_no').AsString);
       cmbLot.OnSelect(Sender);

   end;

   
end;

end.

