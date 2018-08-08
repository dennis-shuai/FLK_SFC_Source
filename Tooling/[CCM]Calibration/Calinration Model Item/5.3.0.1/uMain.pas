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
    Label6: TLabel;
    cmbMachine: TComboBox;
    Label7: TLabel;
    cmbExp: TComboBox;
    Label2: TLabel;
    il1: TImageList;
    cmbItem: TComboBox;
    edtValue: TEdit;
    edtDiv: TEdit;
    edtUpper: TEdit;
    edtLower: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    btnAdd: TSpeedButton;
    Image1: TImage;
    dbgrd1: TDBGrid;
    pm1: TPopupMenu;
    Delete1: TMenuItem;
    QryTemp1: TClientDataSet;
    procedure FormShow(Sender: TObject);
    procedure cmbModelSelect(Sender: TObject);
    procedure cmbMachineSelect(Sender: TObject);
    procedure cmbItemSelect(Sender: TObject);
    procedure edtValueChange(Sender: TObject);
    procedure edtDivChange(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure cmbExpSelect(Sender: TObject);
    procedure Delete1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    procedure ShowData;
    function  GetID(sfieldID,sField,sTable,sCondition:string):integer;
    function  GetMaxId(modelid,toolingid,intervalid:Integer):Integer;
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
    {Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.AUTHORITYS from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
    if gsParam <> '' then
      CommandText := CommandText + 'and fun_param = ''' + gsParam + ''' ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'CalibrationModelItemDll.DLL';
    Open;

    if FieldByName('AUTHORITYS').AsString = '' or  then begin

    end;}

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

    Close;
    Params.Clear;
    CommandText :='select interval_desc from sajet.sys_CAL_INTERVAL where enabled=''Y''  order by interval_id';
    Open;

    First;
    while not Eof do begin
       cmbExp.Items.Add( FieldByName('interval_desc').AsString );
       Next;
    end;
    cmbExp.Style := csDropDownList;

    Close;
    Params.Clear;
    CommandText :='select ITEM_NAME from sajet.sys_CAL_ITEM where enabled=''Y''  order by ITEM_NAME';
    Open;

    First;
    cmbItem.Items.Clear;
    cmbItem.Style := csDropDownList;
    while not Eof do begin
       cmbItem.Items.Add(FieldByname('ITEM_NAME').AsString);
       Next;
    end;
    
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

procedure TfMain.cmbItemSelect(Sender: TObject);
begin
   // edtValue.SetFocus;
    with QryTemp do begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'Item_Name',ptInput);
        CommandText := 'select * from sajet.sys_cal_item where item_Name =:item_Name';
        Params.ParamByName('Item_Name').AsString :=cmbItem.Text ;
        Open;

        edtValue.Text := FieldByName('Item_value').AsString;
        edtDiv.Text := FieldByName('Item_Deviation').AsString;
        edtUpper.Text := FieldByName('Upper_value').AsString;
        edtLower.Text := FieldByName('Lower_Value').AsString;

    end;
end;

procedure TfMain.edtValueChange(Sender: TObject);
begin
    edtUpper.Text :=  FloatToStr(StrToFloatDef(edtValue.Text,0) + StrToFloatDef(edtDiv.Text,0));
    edtLower.Text :=  FloatToStr(StrToFloatDef(edtValue.Text,0) - StrToFloatDef(edtDiv.Text,0));
end;

procedure TfMain.edtDivChange(Sender: TObject);
begin
    edtUpper.Text :=  FloatToStr(StrToFloatDef(edtValue.Text,0) + StrToFloatDef(edtDiv.Text,0));
    edtLower.Text :=  FloatToStr(StrToFloatDef(edtValue.Text,0) - StrToFloatDef(edtDiv.Text,0));
end;

procedure TfMain.ShowData;
begin
     if cmbModel.ItemIndex<0 then Exit;
     if cmbMachine.ItemIndex <0 then Exit;
     if cmbExp.ItemIndex <0 then Exit;

     with QryData do begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString,'Model_Name',ptInput);
         Params.CreateParam(ftString,'toolingName',ptInput);
         Params.CreateParam(ftString,'interval',ptInput);
         CommandText := ' select b.model_name,a.item_name ,c.tooling_Name Machine_Type,'+
                        ' d.interval_Desc,e.Item_value Mid_value,e.Item_deviation Deviation,e.Upper_value,e.Lower_value,e.seq '+
                        ' from sajet.sys_cal_item a,sajet.sys_model b,'+
                        ' sajet.sys_tooling c,sajet.sys_cal_interval d,sajet.sys_cal_model_type e'+
                        ' where a.item_id=e.item_id and b.model_id = e.model_id and c.tooling_id=e.tooling_id '+
                        ' and d.interval_id=e.interval_id and b.model_name=:model_Name and c.tooling_name=:toolingName '+
                        ' and d.interval_desc=:interval order by e.seq';
         Params.ParamByName('Model_Name').AsString :=cmbModel.Items[cmbModel.itemIndex] ;
         Params.ParamByName('toolingName').AsString :=cmbMachine.Text ;
         Params.ParamByName('interval').AsString := cmbExp.Text ;
         Open;

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

    toolingid:=Getid('tooling_id','tooling_name','sajet.sys_tooling',cmbMachine.Text);
    if toolingid=0 then
    begin
        MessageDlg('Machine Type Error !!',mtError, [mbCancel],0);
        cmbMachine.SelectAll;
        cmbMachine.SetFocus ;
        Exit;
    end;

    intervalid:=Getid('interval_id','interval_Desc','sajet.sys_cal_interval',cmbExp.Text);
    if intervalid=0 then
    begin
        MessageDlg('Interval Type Error !!',mtError, [mbCancel],0);
        cmbExp.SelectAll;
        cmbExp.SetFocus ;
        Exit;
    end;

    itemid:=Getid('item_id','item_name','sajet.sys_cal_item', cmbItem.Text);
    if itemid=0 then
    begin
        MessageDlg('Calibration Item   Error !!',mtError, [mbCancel],0);
        cmbItem.SelectAll;
        cmbItem.SetFocus ;
        Exit;
    end;
    seq := GetMaxId(modelId,toolingid,intervalid);

    with QryTemp do
    begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString,'ModelId',ptInput);
         Params.CreateParam(ftString,'toolingid',ptInput);
         Params.CreateParam(ftString,'intervalid',ptInput);
         Params.CreateParam(ftString,'Itemid',ptInput);
         CommandText :='select * from sajet.sys_cal_model_type where model_id =:ModelId and tooling_Id = :toolingid and interval_id =:intervalid '+
                       ' and item_id =:Itemid ';
         Params.ParamByName('ModelId').AsString :=IntToStr(modelId) ;
         Params.ParamByName('toolingid').AsString :=IntToStr(toolingid) ;
         Params.ParamByName('intervalid').AsString := IntToStr(INTERVALiD) ;
         Execute;

         if IsEmpty then begin
             Close;
             Params.Clear;
             Params.CreateParam(ftString,'ModelId',ptInput);
             Params.CreateParam(ftString,'toolingid',ptInput);
             Params.CreateParam(ftString,'intervalid',ptInput);
             Params.CreateParam(ftString,'Itemid',ptInput);
             Params.CreateParam(ftInteger,'Seq',ptInput);
             Params.CreateParam(ftString,'update_userid',ptInput);
             Params.CreateParam(ftFloat,'Item_value',ptInput);
             Params.CreateParam(ftFloat,'Item_Deviation',ptInput);
             Params.CreateParam(ftFloat,'Upper_Value',ptInput);
             Params.CreateParam(ftFloat,'Lower_Value',ptInput);
             CommandText := ' Insert into  sajet.sys_cal_model_type(model_id,item_id,seq,Item_value,'+
                            ' Item_DEVIATION,UPPER_VALUE,loWER_VALUE,Tooling_ID,INTERVAL_ID,ENABLED,UPDATE_TIME,UPDATE_USERID)  '+
                            ' VALUES(:MODELID,:ITEMID,:SEQ,:Item_value,:Item_DEVIATION,:UPPER_VALUE,:Lower_Value '+
                            ' ,:toolingid,:intervalid,''Y'',sysdate,:UPDATE_USERID )';
             Params.ParamByName('ModelId').AsString :=IntToStr(modelId) ;
             Params.ParamByName('toolingid').AsString :=IntToStr(toolingid) ;
             Params.ParamByName('intervalid').AsString := IntToStr(INTERVALiD) ;
             Params.ParamByName('Itemid').AsString := IntToStr(itemid) ;
             Params.ParamByName('Seq').AsInteger :=  seq  ;
             Params.ParamByName('update_userid').AsString := UpdateUserID ;
             Params.ParamByName('Item_value').AsFloat := StrToFloat(edtValue.Text) ;
             Params.ParamByName('Item_Deviation').AsFloat := StrToFloat(edtDiv.Text) ;
             Params.ParamByName('Upper_Value').AsFloat := StrToFloat(edtUpper.Text) ;
             Params.ParamByName('Lower_Value').AsFloat := StrToFloat(edtLower.Text) ;
             Execute;
         end else begin
             Close;
             Params.Clear;
             Params.CreateParam(ftString,'ModelId',ptInput);
             Params.CreateParam(ftString,'toolingid',ptInput);
             Params.CreateParam(ftString,'intervalid',ptInput);
             Params.CreateParam(ftString,'Itemid',ptInput);
             //Params.CreateParam(ftInteger,'Seq',ptInput);
             Params.CreateParam(ftString,'update_userid',ptInput);
             Params.CreateParam(ftFloat,'Item_value',ptInput);
             Params.CreateParam(ftFloat,'Item_Deviation',ptInput);
             Params.CreateParam(ftFloat,'Upper_Value',ptInput);
             Params.CreateParam(ftFloat,'Lower_Value',ptInput);
             CommandText := ' update sajet.sys_cal_model_type set Item_value =:Item_value ,'+
                            ' Item_DEVIATION =:Item_Deviation,UPPER_VALUE=:Upper_Value,Lower_VALUE=:Lower_Value'+
                            ' UPDATE_TIME = sysdate,Update_userid=:update_userid '+
                            ' where model_id =:ModelId and toolingId = :toolingid and interval_id =:intervalid '+
                            ' and item_id =:Itemid  ';
             Params.ParamByName('ModelId').AsString :=IntToStr(modelId) ;
             Params.ParamByName('toolingid').AsString :=IntToStr(toolingid) ;
             Params.ParamByName('intervalid').AsString := IntToStr(INTERVALiD) ;
             Params.ParamByName('Itemid').AsString := IntToStr(itemid) ;
             //Params.ParamByName('Seq').AsInteger :=  seq  ;
             Params.ParamByName('update_userid').AsString := UpdateUserID ;
             Params.ParamByName('Item_value').AsFloat := StrToFloat(edtValue.Text) ;
             Params.ParamByName('Item_Deviation').AsFloat := StrToFloat(edtDiv.Text) ;
             Params.ParamByName('Upper_Value').AsFloat := StrToFloat(edtUpper.Text) ;
             Params.ParamByName('Lower_Value').AsFloat := StrToFloat(edtLower.Text) ;
             Execute;
         end;
    end;
    ShowData;


end;


function TfMain.GetMaxId(modelid,toolingid,intervalid:Integer):Integer;
begin

     with QryTemp do
     begin
         Close;
         Params.Clear;
         Params.CreateParam(ftInteger,'modelId',ptInput);
         Params.CreateParam(ftInteger,'toolingid',ptInput);
         Params.CreateParam(ftInteger,'intervalid',ptInput);
         CommandText := ' select nvL(max(seq),0)+1 seqid from sajet.sys_cal_MOdel_type  '+
                        ' where  model_id = :modelId and tooling_id=:toolingid '+
                        ' and  interval_id =:intervalid ';
         Params.ParamByName('modelId').AsInteger :=modelid ;
         Params.ParamByName('toolingid').AsInteger :=toolingid ;
         Params.ParamByName('intervalid').AsInteger := intervalid ;
         Open;

         Result :=fieldByName('seqid').AsInteger;

     end;

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
         Params.CreateParam(ftInteger,'modelId',ptInput);
         Params.CreateParam(ftInteger,'toolingid',ptInput);
         Params.CreateParam(ftInteger,'intervalid',ptInput);
         Params.CreateParam(ftInteger,'Itemid',ptInput);
         CommandText := 'delete  from sajet.sys_cal_MOdel_type  '+
                        ' where  model_id = :modelId and tooling_id=:toolingid '+
                        ' and  interval_id =:intervalid and Item_Id=:itemId ';
         Params.ParamByName('modelId').AsInteger :=GetID('Model_id','Model_Name','Sajet.sys_model',QryData.fieldByName('Model_Name').AsString) ;
         Params.ParamByName('toolingid').AsInteger :=GetID('tooling_id','tooling_Name','Sajet.sys_tooling',QryData.fieldByName('Machine_type').AsString) ;
         Params.ParamByName('intervalid').AsInteger := GetID('interval_id','interval_desc','Sajet.sys_cal_interval',QryData.fieldByName('interval_desc').AsString) ;
         Params.ParamByName('ItemId').AsInteger := GetID('item_id','Item_Name','Sajet.sys_cal_item',QryData.fieldByName('item_Name').AsString) ;
         Execute;
     end;
     ShowData;
end;

end.

