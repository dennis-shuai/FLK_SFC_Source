unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  MConnect, SConnect, {FileCtrl,} ObjBrkr, Menus,DateUtils,comobj,Variants,
  ComCtrls, ImgList;

type
  TfMain = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryData: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    Label1: TLabel;
    Label10: TLabel;
    SaveDialog2: TSaveDialog;
    Label5: TLabel;
    il1: TImageList;
    btnAdd: TSpeedButton;
    Image1: TImage;
    pm1: TPopupMenu;
    Delete1: TMenuItem;
    QryTemp1: TClientDataSet;
    edtSN: TEdit;
    Label2: TLabel;
    Label6: TLabel;
    cmbMachine: TComboBox;
    Label3: TLabel;
    cmbInterval: TComboBox;
    pnltotal: TPanel;
    pnlItem1: TPanel;
    LabItem1: TLabel;
    Lablmax1: TLabel;
    Lablmin1: TLabel;
    edtItem1: TEdit;
    chkItem1: TCheckBox;
    LabMax1: TLabel;
    LabMin1: TLabel;
    pnlItem2: TPanel;
    LabItem2: TLabel;
    LablMax2: TLabel;
    LablMin2: TLabel;
    LabMax2: TLabel;
    LabMin2: TLabel;
    edtItem2: TEdit;
    chkItem2: TCheckBox;
    pnlItem3: TPanel;
    LabItem3: TLabel;
    LablMax3: TLabel;
    Lablmin3: TLabel;
    LabMax3: TLabel;
    LabMin3: TLabel;
    edtItem3: TEdit;
    chkItem3: TCheckBox;
    pnlItem4: TPanel;
    LabItem4: TLabel;
    LablMax4: TLabel;
    Lablmin4: TLabel;
    LabMax4: TLabel;
    LabMin4: TLabel;
    edtItem4: TEdit;
    chkItem4: TCheckBox;
    pnlItem5: TPanel;
    LabItem5: TLabel;
    LablMax5: TLabel;
    Lablmin5: TLabel;
    LabMax5: TLabel;
    LabMin5: TLabel;
    edtItem5: TEdit;
    chkItem5: TCheckBox;
    pnlItem6: TPanel;
    LabItem6: TLabel;
    LablMax6: TLabel;
    Lablmin6: TLabel;
    LabMax6: TLabel;
    LabMin6: TLabel;
    edtItem6: TEdit;
    chkItem6: TCheckBox;
    pnlItem7: TPanel;
    LabItem7: TLabel;
    LablMax7: TLabel;
    Lablmin7: TLabel;
    LabMax7: TLabel;
    LabMin7: TLabel;
    edtItem7: TEdit;
    chkItem7: TCheckBox;
    pnlItem8: TPanel;
    LabItem8: TLabel;
    LablMax8: TLabel;
    Lablmin8: TLabel;
    LabMax8: TLabel;
    LabMin8: TLabel;
    edtItem8: TEdit;
    chkItem8: TCheckBox;
    pnlItem9: TPanel;
    LabItem9: TLabel;
    LablMax9: TLabel;
    Lablmin9: TLabel;
    LabMax9: TLabel;
    LabMin9: TLabel;
    edtItem9: TEdit;
    chkItem9: TCheckBox;
    pnlItem10: TPanel;
    LabItem10: TLabel;
    LablMax10: TLabel;
    Lablmin10: TLabel;
    LabMax10: TLabel;
    LabMin10: TLabel;
    edtItem10: TEdit;
    chkItem10: TCheckBox;
    edtModel: TEdit;
    Label4: TLabel;
    cmbMachineNo: TComboBox;
    pnlResult1: TPanel;
    pnlResult2: TPanel;
    pnlResult3: TPanel;
    pnlResult4: TPanel;
    pnlResult5: TPanel;
    pnlResult6: TPanel;
    pnlResult7: TPanel;
    pnlResult8: TPanel;
    pnlResult9: TPanel;
    pnlResult10: TPanel;
    Label7: TLabel;
    btnNewLot: TSpeedButton;
    cmbListNo: TComboBox;
    btnSave: TSpeedButton;
    Image2: TImage;
    procedure FormShow(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
    procedure cmbMachineSelect(Sender: TObject);
    procedure edtItem1Change(Sender: TObject);
    procedure cmbMachineNoChange(Sender: TObject);
    procedure btnNewLotClick(Sender: TObject);
    procedure edtItem1KeyPress(Sender: TObject; var Key: Char);
    procedure cmbListNoSelect(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    itemCount:Integer;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    procedure ShowCalItem;
    procedure clearData;
    procedure GetListNo;
    function  GetID(sfieldID,sField,sTable,sCondition:string):integer;
   // function  GetMaxId(modelid,toolingid,intervalid:Integer):Integer;
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform;



procedure TfMain.FormShow(Sender: TObject);
var mNodeItem,mNodeSubItem: TTreeNode;
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;

  GetListNo;

end;

procedure TfMain.GetListNo;
begin
  cmbListNo.Items.Clear;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText :='select distinct list_no list_no from sajet.G_CAL_STATUS where END_TIME IS NULL Order By list_no ';
    Open;

    First;
    while not Eof do begin
       cmbListNo.Items.Add( FieldByName('list_no').AsString );
       Next;
    end;
    cmbListNo.Style := csDropDownList;
  end;
  cmbListNo.Style :=csDropDownList;
  cmbListNo.SetFocus;
end;


procedure TfMain.ShowCalItem;
var i,Count:Integer;
dMax,dMin:Double;
myLabel:TLabel;
sItemName:string;
begin
   With QryTemp do
   begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'serial_number',ptInput);
       CommandText :=' select distinct  f.interval_desc  interval_desc  '+
                     ' from sajet.sys_cal_sn a,sajet.sys_cal_model_type b,sajet.sys_model c,'+
                     ' sajet.sys_tooling d ,sajet.sys_cal_item e,sajet.sys_cal_interval f '+
                     ' where a.model_id=b.model_id and '+
                     ' serial_number=:serial_number and a.model_id=c.model_id and b.tooling_id = d.tooling_id(+) '+
                     ' and b.item_Id=e.item_id and b.interval_id=f.interval_id ';
       Params.ParamByName('serial_number').AsString :=edtSN.Text ;
       Open;

       cmbInterval.Clear;
       cmbInterval.Items.Clear;
       cmbInterval.Style :=csDropDownList;

       First;
       while not Eof do begin
          cmbInterval.Items.Add(fieldbyName('Interval_desc').AsString);
          Next;
       end;

       if cmbInterval.Items.Count=1 then
          cmbInterval.ItemIndex :=0;

       Close;
       Params.Clear;
       Params.CreateParam(ftString,'serial_number',ptInput);
       CommandText :=' select distinct  d.tooling_name  tooling_name '+
                     ' from sajet.sys_cal_sn a,sajet.sys_cal_model_type b,sajet.sys_model c,'+
                     ' sajet.sys_tooling d ,sajet.sys_cal_item e,sajet.sys_cal_interval f '+
                     ' where a.model_id=b.model_id and '+
                     ' serial_number=:serial_number and a.model_id=c.model_id and b.tooling_id = d.tooling_id(+) '+
                     ' and b.item_Id=e.item_id and b.interval_id=f.interval_id ';
       Params.ParamByName('serial_number').AsString :=edtSN.Text ;
       Open;

       cmbMachine.Clear;
       cmbMachine.Items.Clear;
       cmbMachine.Style :=csDropDownList;

       First;
       while not Eof do begin
          if   fieldbyName('tooling_name').AsString <>'' then
            cmbMachine.Items.Add(fieldbyName('tooling_name').AsString);
          Next;
       end;

       if cmbMachine.Items.Count=1 then begin
          cmbMachine.ItemIndex :=0 ;
          cmbMachine.OnSelect(nil);
       end
       else if cmbMachine.Items.Count=0 then
       begin
           Close;
           Params.Clear;
           CommandText :='select distinct tooling_Name from sajet.sys_tooling where enabled=''Y'' and Isrepair_control=''Y'' order by tooling_Name';
           Open;

           First;
           while not Eof do begin
               cmbMachine.Items.Add( FieldByName('tooling_Name').AsString );
               Next;
           end;
           cmbMachine.Style := csDropDownList;
       end;
   end;
   with QryTemp do
   begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'serial_number',ptInput);
        CommandText :=' select a.serial_number,c.model_name,nvl(d.tooling_name,''N/A'') tooling_name ,'+
                     ' e.item_name,f.interval_desc,b.Upper_value,b.lower_value '+
                     ' from sajet.sys_cal_sn a,sajet.sys_cal_model_type b,sajet.sys_model c,'+
                     ' sajet.sys_tooling d ,sajet.sys_cal_item e,sajet.sys_cal_interval f '+
                     ' where a.model_id=b.model_id and '+
                     ' serial_number=:serial_number and a.model_id=c.model_id and b.tooling_id = d.tooling_id(+) '+
                     ' and b.item_Id=e.item_id and b.interval_id=f.interval_id ';
        Params.ParamByName('serial_number').AsString :=edtSN.Text ;
        Open;
   end;

    QryTemp.First;
    itemCount := QryTemp.RecordCount ;
    for i :=1 to itemCount do begin
        sItemName :=QryTemp.FieldByName('item_name').AsString;
        TLabel(FindComponent('LabItem'+IntToStr(i))).Caption :=sItemName;
        dMax := QryTemp.FieldByName('Upper_value').AsFloat;
        dMin := QryTemp.FieldByName('Lower_value').AsFloat;
        TLabel(FindComponent('LabMax'+IntToStr(i))).Caption := FloatToStr(dMax);
        TLabel(FindComponent('LabMin'+IntToStr(i))).Caption := FloatToStr(dMin);
        if (TLabel(FindComponent('LabMax'+IntToStr(i))).Caption ='0') and
           (TLabel(FindComponent('LabMin'+IntToStr(i))).Caption ='0') then
        begin
            TCheckBox(FindComponent('chkItem'+IntToStr(i))).Visible := true;
        end else begin
            TLabel(FindComponent('LabMax'+IntToStr(i))).Visible :=True;
            TLabel(FindComponent('LablMax'+IntToStr(i))).Visible :=True;
            TLabel(FindComponent('LablMin'+IntToStr(i))).Visible :=True;
            TLabel(FindComponent('LabMin'+IntToStr(i))).Visible :=True;
            TEdit(FindComponent('edtItem'+IntToStr(i))).Visible :=True;
        end;
        TPanel(FindComponent('pnlResult'+IntToStr(i))).Color :=clRed;
        TPanel(FindComponent('pnlResult'+IntToStr(i))).Caption :='Fail';
        QryTemp.Next;
    end;
end;

procedure TfMain.clearData;
var i:Integer;
begin
    edtSN.Clear;
    cmbMachine.Items.Clear;
    cmbMachineNo.Items.Clear;
    edtModel.Text :='';
    cmbInterval.Items.Clear;
    cmbListNo.ItemIndex :=-1;


    for i:=1 to 10 do begin
        TLabel(FindComponent('LabItem'+IntToStr(i))).Caption := '';
        TCheckBox(FindComponent('chkItem'+IntToStr(i))).Visible := False;
        TLabel(FindComponent('LabMax'+IntToStr(i))).Visible :=False;
        TLabel(FindComponent('LablMax'+IntToStr(i))).Visible :=False;
        TLabel(FindComponent('LablMin'+IntToStr(i))).Visible :=False;
        TLabel(FindComponent('LabMin'+IntToStr(i))).Visible :=False;
        TEdit(FindComponent('edtItem'+IntToStr(i))).Visible :=False;
        TPanel(FindComponent('pnlResult'+IntToStr(i))).Color :=clWhite;
        TPanel(FindComponent('pnlResult'+IntToStr(i))).Caption :='';
    end;
end;


function TfMain.GetID(sfieldID,sField,sTable,sCondition:string):integer;
begin
  result:=0;
  With QryTemp do
  begin
    close;
    params.Clear;
    commandtext:=' select '+sFieldID + ' sID from '+sTable+' where '+sField+' = '+''''+ sCondition+'''';
    open;
    if Not IsEmpty then
      Result:=fieldbyname('sID').AsInteger;
  end;
end;

procedure TfMain.btnAddClick(Sender: TObject);
var i,toolingsnid,intervalid,itemid,modelid:Integer;
dMax,dMin,dValue:Double;
sResult,sLotNo,sModel,sSN:string;
begin

    toolingsnid:=Getid('tooling_sn_id','tooling_SN','sajet.sys_tooling_sn',cmbMachineNo.Text);
    if toolingsnid=0 then
    begin
        MessageDlg('Machine No Error !!',mtError, [mbCancel],0);
        cmbMachineNo.SelectAll;
        cmbMachineNo.SetFocus ;
        Exit;
    end;

    intervalid :=Getid('interval_id','interval_desc','sajet.sys_cal_interval',cmbInterval.Text);
    if intervalid=0 then
    begin
        MessageDlg('interval Error!!',mtError, [mbCancel],0);
        cmbInterval.SelectAll;
        cmbInterval.SetFocus ;
        Exit;
    end;

    modelid :=Getid('model_id','Model_name','sajet.sys_model',edtModel.Text);
    if intervalid=0 then
    begin
        MessageDlg('interval Error!!',mtError, [mbCancel],0);
        cmbInterval.SelectAll;
        cmbInterval.SetFocus ;
        Exit;
    end;

    with QryTemp do
    begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString,'ListNo',ptInput);
         Params.CreateParam(ftString,'toolingsnid',ptInput);
         Params.CreateParam(ftString,'intervalid',ptInput);
         CommandText :='SELECT * FROM SAJET.G_CAL_STATUS where  List_No <> :ListNo and tooling_sn_id =:toolingsnid and interval_id =:intervalid ';
         Params.ParamByName('ListNo').AsString := sLotNo;
         Params.ParamByName('toolingsnid').AsString := IntToStr(toolingsnid);
         Params.ParamByName('intervalid').AsString := IntToStr(intervalid);
         Open;

         if not IsEmpty then
         begin
             Close;
             Params.Clear;
             Params.CreateParam(ftString,'ListNo',ptInput);
             Params.CreateParam(ftString,'toolingsnid',ptInput);
             Params.CreateParam(ftString,'intervalid',ptInput);
             CommandText :=' insert into sajet.g_cal_travel select * from sajet.G_CAL_STATUS where  List_No <> :ListNo '+
                           ' and tooling_sn_id =:toolingsnid and interval_id = :intervalid ';
             Params.ParamByName('ListNo').AsString := sLotNo;
             Params.ParamByName('toolingsnid').AsString := IntToStr(toolingsnid);
             Params.ParamByName('intervalid').AsString := IntToStr(intervalid);
             Execute;

             Close;
             Params.Clear;
             Params.CreateParam(ftString,'ListNo',ptInput);
             Params.CreateParam(ftString,'toolingsnid',ptInput);
             Params.CreateParam(ftString,'intervalid',ptInput);
             CommandText :='delete from sajet.G_CAL_STATUS where  List_No <> :ListNo and tooling_sn_id =:toolingsnid and interval_id = :intervalid';
             Params.ParamByName('ListNo').AsString := sLotNo;
             Params.ParamByName('toolingsnid').AsString := IntToStr(toolingsnid);
             Params.ParamByName('intervalid').AsString := IntToStr(intervalid);
             Execute;

         end;
    end;

    sLotNo  := cmbListNo.Items.Strings[cmbListNo.Itemindex];
    sModel := edtModel.Text;
    sSN := edtSN.Text;
    for i:=1 to ItemCount do
    begin
        itemid :=Getid('item_id','item_name','sajet.sys_cal_item',TLabel(FindComponent('LabItem'+IntToStr(i))).Caption);
        dMax := StrToFloatDef(TLabel(FindComponent('LabMax'+IntToStr(i))).Caption,0);
        dMin := StrToFloatDef(TLabel(FindComponent('LabMin'+IntToStr(i))).Caption,0);
        dValue :=  StrToFloatDef(TEdit(FindComponent('edtItem'+IntToStr(i))).Text,0);
        if (dValue >= dMin)  and (dValue < dMax) then begin
           TPanel(FindComponent('pnlResult'+IntToStr(i))).Caption :='PASS' ;
           TPanel(FindComponent('pnlResult'+IntToStr(i))).Color :=clGreen;
        end else begin
            TPanel(FindComponent('pnlResult'+IntToStr(i))).Caption :='Fail' ;
            TPanel(FindComponent('pnlResult'+IntToStr(i))).Color :=clRed;
        end;
        sResult := TPanel(FindComponent('pnlResult'+IntToStr(i))).Caption;


        with QryTemp do
        begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString,'ListNo',ptInput);
            Params.CreateParam(ftString,'ItemId',ptInput);
            CommandText :='select * from sajet.G_CAL_STATUS where  List_No=:ListNo and Item_Id =:ItemId';
            Params.ParamByName('ListNo').AsString := sLotNo;
            Params.ParamByName('ItemId').AsString := IntToStr(itemid);
            Open;
            if IsEmpty then
            begin
                Close;
                Params.Clear;
                Params.CreateParam(ftString,'ListNo',ptInput);
                Params.CreateParam(ftString,'ItemId',ptInput);
                Params.CreateParam(ftString,'sn',ptInput);
                Params.CreateParam(ftString,'modelId',ptInput);
                Params.CreateParam(ftString,'intervalid',ptInput);
                Params.CreateParam(ftString,'toolingsnid',ptInput);
                Params.CreateParam(ftString,'maxvalue',ptInput);
                Params.CreateParam(ftString,'minvalue',ptInput);
                Params.CreateParam(ftString,'calValue',ptInput);
                Params.CreateParam(ftString,'calresult',ptInput);
                Params.CreateParam(ftString,'upateuserid',ptInput);
                Params.CreateParam(ftInteger,'seq',ptInput);
                if (Sender as TSpeedButton).Name = 'btnSave' then
                    CommandText :=' insert into  sajet.G_CAL_STATUS(list_no,serial_number,model_id,interval_id,'+
                              ' tooling_sn_id,item_id,max_value,min_value,cal_value,cal_result,start_time,update_userid,seq) '+
                              ' values(:ListNo,:sn,:modelid,:intervalid,:toolingsnid,:ItemId,:maxvalue,:minvalue,:calvalue,:calresult,sysdate,:upateuserid,:seq)'
                else  if (Sender as TSpeedButton).Name = 'btnAdd' then
                    CommandText :=' insert into  sajet.G_CAL_STATUS(list_no,serial_number,model_id,interval_id,'+
                              ' tooling_sn_id,item_id,max_value,min_value,cal_value,cal_result,start_time,end_time,update_userid,seq) '+
                              ' values(:ListNo,:sn,:modelid,:intervalid,:toolingsnid,:ItemId,:maxvalue,:minvalue,:calvalue,:calresult,sysdate,sysdate,:upateuserid,:seq)';
                Params.ParamByName('ListNo').AsString := sLotNo;
                Params.ParamByName('ItemId').AsString := IntToStr(itemid);
                Params.ParamByName('sn').AsString := sSN;
                Params.ParamByName('modelid').AsString := IntToStr(modelid);
                Params.ParamByName('intervalid').AsString := IntToStr(intervalid);
                Params.ParamByName('toolingsnid').AsString := IntToStr(toolingsnid);
                Params.ParamByName('maxvalue').AsString :=  FloatToStr(dMax );
                Params.ParamByName('minvalue').AsString :=  FloatToStr(dMin );
                Params.ParamByName('calvalue').AsString :=  FloatToStr(dValue );
                Params.ParamByName('calresult').AsString := sResult;
                Params.ParamByName('upateuserid').AsString := UpdateUserID;
                Params.ParamByName('seq').AsInteger := i;
                Execute;
            end else begin
                Close;
                Params.Clear;
                Params.CreateParam(ftString,'ListNo',ptInput);
                Params.CreateParam(ftString,'ItemId',ptInput);
                Params.CreateParam(ftString,'sn',ptInput);
                Params.CreateParam(ftString,'intervalid',ptInput);
                Params.CreateParam(ftString,'toolingsnid',ptInput);
                Params.CreateParam(ftString,'calValue',ptInput);
                Params.CreateParam(ftString,'calresult',ptInput);
                Params.CreateParam(ftString,'upateuserid',ptInput);
                if (Sender as TSpeedButton).Name = 'btnSave' then
                    CommandText :=' update sajet.G_CAL_STATUS set serial_number =:sn,'+
                              ' tooling_sn_id =:toolingsnid,'+
                              ' cal_value=:calvalue,cal_result=:calresult,update_userid =:upateuserid '+
                              ' where list_no =:listno and interval_id =:intervalid and item_id =:ItemId'
                else if (Sender as TSpeedButton).Name = 'btnAdd' then
                    CommandText :=' update sajet.G_CAL_STATUS set serial_number =:sn, '+
                              ' tooling_sn_id =:toolingsnid,end_time=sysdate,'+
                              ' cal_value=:calvalue,cal_result=:calresult,update_userid =:upateuserid  '+
                              ' where list_no =:listno and interval_id =:intervalid and item_id =:ItemId ';
                Params.ParamByName('ListNo').AsString := sLotNo;
                Params.ParamByName('ItemId').AsString := IntToStr(itemid);
                Params.ParamByName('sn').AsString := sSN;
                Params.ParamByName('toolingsnid').AsString := IntToStr(toolingsnid);
                Params.ParamByName('intervalid').AsString := IntToStr(intervalid);
                Params.ParamByName('calvalue').AsString :=  FloatToStr(dValue );
                Params.ParamByName('calresult').AsString := sResult;
                Params.ParamByName('upateuserid').AsString := UpdateUserID;
                Execute;
            end;

        end;
    end;

    clearData;
    GetListNo;
    edtSN.Clear;
    cmbListNo.SetFocus;



end;

procedure TfMain.edtSNKeyPress(Sender: TObject; var Key: Char);
begin
     itemCount :=0;
     if Key<>#13 then Exit;
     With QryTemp do
     begin
         close;
         params.Clear;
         Params.CreateParam(ftString,'sn',ptInput);
         commandtext:=' select model_name from sajet.sys_model a,sajet.sys_cal_sn b where a.model_id=b.model_id and b.serial_number=:sn ';
         Params.ParamByName('sn').AsString :=edtSN.Text ;
         open;
         if IsEmpty then begin
              MessageDlg('No SN',mtError,[mbOK],0);
              Exit;
         end;
         edtModel.Text := fieldByName('model_name').AsString;
     end;

     ShowCalItem;



end;

procedure TfMain.cmbMachineSelect(Sender: TObject);
begin
    With QryTemp do
    begin
        close;
        params.Clear;
        Params.CreateParam(ftString,'sn',ptInput);
        commandtext:=' select b.tooling_sn from sajet.sys_tooling a,sajet.sys_tooling_sn b '+
                     ' where a.tooling_id=b.tooling_id and a.tooling_name=:SN and b.enabled=''Y'' '+
                     ' and a.enabled=''Y'' order by b.tooling_SN ';
        Params.ParamByName('sn').AsString :=cmbMachine.Text ;
        open;
        cmbMachineNo.Items.Clear;
        cmbMachineNo.Style :=csDropDownList;
        First;
         while not Eof do begin
             cmbMachineNo.Items.Add(fieldbyName('tooling_sn').AsString);
             Next;
        end;
    end;
end;

procedure TfMain.edtItem1Change(Sender: TObject);
var i,ipos:integer;
dMax,dMin:Double;
begin
    i :=  StrToInt(Copy((Sender as TEdit).Name,8,Length((Sender as TEdit).Name)-7));
    dMax :=  StrToFloatDef(TLabel(FindComponent('LabMax'+IntToStr(i))).Caption,0);
    dMin :=  StrToFloatDef(TLabel(FindComponent('LabMin'+IntToStr(i))).Caption,0);
    if (StrToFloatDef((Sender as TEdit).Text,0) > dMax) or (StrToFloatDef((Sender as TEdit).Text,0) < dMin)  then
    begin
        TPanel(FindComponent('pnlResult'+IntToStr(i))).Caption :='Fail';
        TPanel(FindComponent('pnlResult'+IntToStr(i))).Color :=clRed;
    end else begin
        TPanel(FindComponent('pnlResult'+IntToStr(i))).Caption :='PASS';
        TPanel(FindComponent('pnlResult'+IntToStr(i))).Color :=clGreen;
    end;
end;

procedure TfMain.cmbMachineNoChange(Sender: TObject);
begin
   if edtItem1.Visible then edtItem1.SetFocus;
end;

procedure TfMain.btnNewLotClick(Sender: TObject);
var stemp,listNo:string;
bFound:Boolean;
i:integer;
begin
    With QryTemp1 do
    begin
        close;
        params.Clear;
        CommandText :='select to_char(sysdate,''YYMMDD'') idate from dual';
        Open;
        stemp := FieldByName('idate').AsString;

        close;
        params.Clear;
        commandtext:=' select list_no  from (select list_no from sajet.g_cal_status where list_no  like ''C'+stemp+'%'' '+
                     ' union select list_no from sajet.g_cal_travel where list_no  like ''C' +stemp+'%'') where rownum=1';
        open;

        if IsEmpty then begin
            close;
            params.Clear;
            commandtext:=' select sequence_name  from all_sequences where sequence_owner=''SAJET'' and Sequence_Name = ''S_CAL_LIST_NO''';
            open;
            if not IsEmpty then
            begin
                close;
                params.Clear;
                commandtext:=' DROP SEQUENCE SAJET.S_CAL_LIST_NO';
                Execute;
            end;
            close;
            params.Clear;
            commandtext:=' CREATE SEQUENCE SAJET.S_CAL_LIST_NO START WITH 1 MAXVALUE 99999 MINVALUE 1 NOCYCLE NOCACHE ORDER';
            Execute;
        end;

        close;
        params.Clear;
        commandtext:='  select ''C''||to_char(sysdate,''YYMMDD'')|| Translate(lpad(SAJET.S_CAL_LIST_NO.NEXTVAL,5),'' '',''0'') listno from dual';
        open;
        listNo :=fieldbyName('listno').AsString;
        bFound:=false;
        for i:=0 to cmbListNo.Items.Count-1 do begin
             if cmbListNo.Items[i] = listNo then
             begin
                bFound :=True;
                Break;
             end;
        end;
        if not bFound then
            cmbListNo.Items.Add(listNo);
        cmbListNo.ItemIndex :=cmbListNo.Items.IndexOf(listNo);

    end;
    edtSN.SetFocus;
end;

procedure TfMain.edtItem1KeyPress(Sender: TObject; var Key: Char);
var sName:string;
i:Integer;
myEdit:TEdit;
begin
   if Key <>#13 then Exit;
   sName :=(Sender as TEdit).Name;
   i := StrToInt(Copy(sName,8,Length(sName)-7));
   if i<10 then  begin
      myEdit := TEdit(FindComponent('edtItem'+IntToStr(i+1)));
      if myEdit.Visible then
         myEdit.SetFocus ;

   end
end;

procedure TfMain.cmbListNoSelect(Sender: TObject);
var sItemName,scalResult:string;
 dMax,dMin,dValue:Double;
 i:Integer;
 Key:Char;
begin
    With QryData do
    begin
        close;
        params.Clear;
        Params.CreateParam(ftString,'listNo',ptInput);
        CommandText :='select a.serial_number,b.model_name,nvl(f.tooling_name,''N/A'') tooling_name ,c.tooling_sn ,'+
                     ' d.item_name,e.interval_desc,a.Max_value,a.Min_value,a.cal_value,a.cal_result,a.seq '+
                     ' from sajet.g_cal_status a, sajet.sys_model b,'+
                     ' sajet.sys_tooling_SN c ,sajet.sys_cal_item d,sajet.sys_cal_interval e ,sajet.sys_tooling f '+
                     ' where a.model_id=b.model_id and a.tooling_sn_id = c.tooling_SN_id and f.tooling_id=c.tooling_id  '+
                     ' and d.item_Id=a.item_id and a.interval_id=e.interval_id and a.list_no =:listNo  order by a.seq ';
        Params.ParamByName('ListNo').AsString := cmbListNo.Items.Strings[cmbListNo.ItemIndex];
        Open;
    end;

    QryData.First ;
    edtSN.Text := QryData.fieldbyName('serial_number').AsString;
    edtModel.Text := QryData.fieldbyName('model_name').AsString;
    cmbMachine.Items.Add( QryData.fieldbyName('tooling_name').AsString) ;
    cmbMachine.ItemIndex := 0;
    cmbMachine.OnSelect(nil);
    cmbMachineNo.ItemIndex :=  cmbMachineNo.Items.IndexOf( QryData.fieldbyName('tooling_sn').AsString);
    cmbInterval.Items.Add( QryData.fieldbyName('interval_desc').AsString) ;
    cmbInterval.ItemIndex := 0;
    ItemCount := QryData.recordCount;
    for i:=1 to ItemCount  do
    begin
        sItemName :=QryData.FieldByName('item_name').AsString;
        TLabel(FindComponent('LabItem'+IntToStr(i))).Caption :=sItemName;
        dMax := QryData.FieldByName('Max_value').AsFloat;
        dMin := QryData.FieldByName('Min_value').AsFloat;
        dValue :=   QryData.FieldByName('cal_value').AsFloat;
        scalResult :=QryData.FieldByName('cal_Result').AsString;
        TLabel(FindComponent('LabMax'+IntToStr(i))).Caption := FloatToStr(dMax);
        TLabel(FindComponent('LabMin'+IntToStr(i))).Caption := FloatToStr(dMin);
        TEdit(FindComponent('edtItem'+IntToStr(i))).Text := FloatToStr(dValue);
        if (TLabel(FindComponent('LabMax'+IntToStr(i))).Caption ='0') and
           (TLabel(FindComponent('LabMin'+IntToStr(i))).Caption ='0') then
        begin
            TCheckBox(FindComponent('chkItem'+IntToStr(i))).Visible := true;
        end else begin
            TLabel(FindComponent('LabMax'+IntToStr(i))).Visible :=True;
            TLabel(FindComponent('LablMax'+IntToStr(i))).Visible :=True;
            TLabel(FindComponent('LablMin'+IntToStr(i))).Visible :=True;
            TLabel(FindComponent('LabMin'+IntToStr(i))).Visible :=True;
            TEdit(FindComponent('edtItem'+IntToStr(i))).Visible :=True;
        end;

        TPanel(FindComponent('pnlResult'+IntToStr(i))).Caption :=scalResult;
        if scalResult='PASS' then    TPanel(FindComponent('pnlResult'+IntToStr(i))).Color :=clGreen
        else   TPanel(FindComponent('pnlResult'+IntToStr(i))).Color :=clRed;
        QryData.Next;
    end;

end;

end.

