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
    cmbModel: TComboBox;
    il1: TImageList;
    btnAdd: TSpeedButton;
    Image1: TImage;
    dbgrd1: TDBGrid;
    pm1: TPopupMenu;
    Delete1: TMenuItem;
    QryTemp1: TClientDataSet;
    edtSN: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    edtwarning: TEdit;
    Label4: TLabel;
    edtLimit: TEdit;
    Label7: TLabel;
    edtUsed: TEdit;
    Label6: TLabel;
    cmbMachine: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure cmbModelSelect(Sender: TObject);
    procedure cmbMachineSelect(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure cmbExpSelect(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);

  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    procedure ShowData;
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

  with QryTemp do
  begin

    Close;
    Params.Clear;
    CommandText :='select distinct Model_Name from sajet.sys_model where enabled=''Y'' order by Model_Name';
    Open;

    First;
    while not Eof do begin
       cmbModel.Items.Add( FieldByName('Model_Name').AsString );
       Next;
    end;
    cmbModel.Style := csDropDownList;

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
    edtSN.SetFocus;
  end;
end;


procedure TfMain.cmbModelSelect(Sender: TObject);
begin
    //cmbMachine.SetFocus;
     ShowData;
end;

procedure TfMain.cmbMachineSelect(Sender: TObject);
begin
    //cmbExp.SetFocus;
    ShowData;
end;

procedure TfMain.ShowData;
begin
     ///if cmbModel.ItemIndex<0 then Exit;

     with QryData do begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString,'serial_number',ptInput);
         if cmbModel.ItemIndex>=0 then
            Params.CreateParam(ftString,'Model',ptInput);
         if cmbMachine.ItemIndex>=0 then
            Params.CreateParam(ftString,'Tooling',ptInput);

         CommandText := ' select * from (select a.serial_number,c.model_name,nvl(d.tooling_Name,''N/A'') tooling_name, f.tooling_name machine_type,h.item_name,'+
                       ' e.interval_desc,b.upper_value,b.lower_value,'+
                       ' a.warning_times,a.limit_times,a.used_times,b.seq ,e.interval_id '+
                       ' from sajet.sys_cal_sn a,sajet.sys_cal_model_type b,sajet.sys_model c,'+
                       ' sajet.sys_tooling d,sajet.sys_cal_interval e,sajet.sys_tooling f '+
                       ' ,sajet.sys_cal_item h where a.serial_number like :serial_number  ';
         if cmbModel.ItemIndex>=0 then
             CommandText := CommandText + ' and  c.Model_name = :model ';

         if cmbMachine.ItemIndex>=0 then
             CommandText := CommandText + ' and  f.Tooling_name = :Tooling ';

         CommandText := CommandText + ' and a.model_id=b.model_id and b.model_id=c.model_Id and a.tooling_id=d.tooling_id(+) ' +
                       ' and e.interval_id =b.interval_id and b.tooling_id=f.tooling_id and '+
                       ' b.item_id=h.item_id ) order by serial_number,model_name,machine_type,interval_id,seq';
         Params.ParamByName('serial_number').AsString :=edtSN.Text+'%' ;
         if cmbModel.ItemIndex >=0 then
             Params.ParamByName('Model').AsString := cmbModel.Items.Strings[cmbModel.ItemIndex] ;
         if cmbMachine.ItemIndex >=0 then
             Params.ParamByName('Tooling').AsString :=cmbMachine.Items.Strings[cmbMachine.ItemIndex] ;;

         Open;

         if not IsEmpty then
         begin

            if edtSN.Text <>'' then begin
                cmbModel.ItemIndex :=cmbModel.Items.IndexOf(fieldbyName('Model_Name').AsString);
                if fieldbyName('tooling_name').AsString <> 'N/A' then begin
                    cmbMachine.ItemIndex :=cmbMachine.Items.IndexOf(fieldbyName('tooling_name').AsString);
                end;

                edtwarning.Text := fieldByName('warning_times').AsString;
                edtLimit.Text := fieldByName('limit_times').AsString;
                edtUsed.Text := fieldByName('used_times').AsString;
            end;
         end;
     end;
end;

function TfMain.GetID(sfieldID,sField,sTable,sCondition:string):integer;
begin
  result:=0;
  With fMain.QryTemp do
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
var modelId,toolingid,intervalid,itemid,seq:Integer;
begin
    modelId:=Getid('model_id','model_name','sajet.sys_model',cmbModel.Text);
    if modelId=0 then
    begin
        MessageDlg('Model Name Error !!',mtError, [mbCancel],0);
        cmbModel.SelectAll;
        cmbModel.SetFocus ;
        Exit;
    end;
    toolingid :=0;
    if cmbMachine.ItemIndex >=0 then begin
        toolingid:=Getid('tooling_id','tooling_name','sajet.sys_tooling',cmbMachine.Text);
        if toolingid=0 then
        begin
            MessageDlg('Machine Type Error !!',mtError, [mbCancel],0);
            cmbMachine.SelectAll;
            cmbMachine.SetFocus ;
            Exit;
        end;
    end;

    with QryTemp do
    begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString,'serial_number',ptInput);
         CommandText :='select * from sajet.sys_cal_sn where  serial_number=:serial_number';
         Params.ParamByName('serial_number').AsString :=edtSN.Text ;
         Open;

         if IsEmpty then begin
             Close;
             Params.Clear;
             Params.CreateParam(ftString,'serial_number',ptInput);
             Params.CreateParam(ftString,'ModelId',ptInput);
             Params.CreateParam(ftString,'toolingid',ptInput);
             Params.CreateParam(ftString,'update_userid',ptInput);
             CommandText := ' Insert into sajet.sys_cal_sn(serial_number,model_id,tooling_id ,'+
                            '  ENABLED,UPDATE_TIME,UPDATE_USERID)  '+
                            ' VALUES(:serial_number,:MODELID,:toolingid , ''Y'',sysdate,:UPDATE_USERID )';
             Params.ParamByName('serial_number').AsString :=edtSN.Text ;
             Params.ParamByName('ModelId').AsString :=IntToStr(modelId) ;
             Params.ParamByName('toolingid').AsString :=IntToStr(toolingid) ;
             Params.ParamByName('update_userid').AsString := UpdateUserID ;
             Execute;
         end else begin
             Close;
             Params.Clear;
             Params.CreateParam(ftInteger,'ModelId',ptInput);
             Params.CreateParam(ftInteger,'toolingid',ptInput);
             Params.CreateParam(ftString,'update_userid',ptInput);
             Params.CreateParam(ftInteger,'warning_times',ptInput);
             Params.CreateParam(ftInteger,'Limit_times',ptInput);
             CommandText := ' update sajet.sys_cal_sn set Model_Id=:ModelId,tooling_id=:toolingid,'+
                            ' UPDATE_TIME = sysdate,Update_userid=:update_userid,warning_times=:warning_times,limit_times=:limit_times '+
                            ' where serial_number=:serial_number ';
             Params.ParamByName('ModelId').AsInteger :=modelId ;
             Params.ParamByName('toolingid').AsInteger :=toolingid ;
             Params.ParamByName('update_userid').AsString := UpdateUserID ;
             Params.ParamByName('warning_times').AsInteger := StrToInt(edtwarning.Text) ;
             Params.ParamByName('Limit_times').AsInteger := StrToInt(edtLimit.Text) ;
             Execute;
         end;
    end;
    ShowData;
    edtSN.Clear;
    edtSN.SetFocus;



end;




procedure TfMain.cmbExpSelect(Sender: TObject);
begin
   ShowData;
end;

procedure TfMain.Delete1Click(Sender: TObject);
begin
     if not QryData.Active then Exit;
     with QryTemp1 do begin
         Close;
         Params.Clear;
         Params.CreateParam(ftInteger,'serial_number',ptInput);
         CommandText := 'delete  from sajet.sys_cal_SN  '+
                        ' where serial_number=:serial_number';
         Params.ParamByName('serial_number').AsString :=QryData.fieldByName('serial_number').AsString ;
         Execute;
     end;
     cmbModel.ItemIndex :=-1;
     edtSN.Clear;
     edtSN.SetFocus;
     ShowData;
end;

procedure TfMain.edtSNKeyPress(Sender: TObject; var Key: Char);
begin
    if Key<>#13 then Exit;
    ShowData;
    {
    with QryData do begin
        Close;
        Params.Clear;
        Params.CreateParam(ftInteger,'serial_number',ptInput);
        CommandText := ' select c.model_name,nvl(d.tooling_Name,''N/A'') tooling_Name ,e.interval_desc,b.upper_value,b.lower_value,'+
                       ' a.warning_times,a.limit_times,a.used_times  '+
                       ' from sajet.sys_cal_sn a,sajet.sys_cal_model_type b,sajet.sys_model c,sajet.sys_tooling d,sajet.sys_cal_interval e '+
                       ' where a.serial_number=:serial_number and a.model_id=b.model_id and b.model_id=c.model_Id and b.tooling_id=d.tooling_id(+) ' +
                       ' and e.interval_id =b.interval_id ';
        Params.ParamByName('serial_number').AsString :=edtSN.Text ;
        Open;

        if not IsEmpty then
        begin
            cmbModel.ItemIndex :=cmbModel.Items.IndexOf(fieldbyName('Model_Name').AsString);
            if fieldbyName('tooling_Name').AsString <> 'N/A' then begin
                cmbMachine.ItemIndex :=cmbMachine.Items.IndexOf(fieldbyName('tooling_Name').AsString);
            end;
            edtwarning.Text := fieldByName('warning_times').AsString;
            edtLimit.Text := fieldByName('limit_times').AsString;
            edtUsed.Text := fieldByName('used_times').AsString;

        end;  
    end;  }
end;

end.

