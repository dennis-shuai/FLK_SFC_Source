unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, uData, Db, DBClient,
  MConnect, SConnect, FileCtrl, ObjBrkr, Menus;

type
  TfDPPM = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    Image2: TImage;
    Image3: TImage;
    ImgDelete: TImage;
    LabTitle2: TLabel;
    Image7: TImage;
    Image8: TImage;
    sbtnAppend: TSpeedButton;
    sbtnModify: TSpeedButton;
    sbtnDelete: TSpeedButton;
    sbtnExport: TSpeedButton;
    sbtnDisabled: TSpeedButton;
    DBGrid1: TDBGrid;
    LabTitle1: TLabel;
    QryData: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    Label4: TLabel;
    cmbShow: TComboBox;
    SaveDialog1: TSaveDialog;
    PopupMenu1: TPopupMenu;
    Append1: TMenuItem;
    Modify1: TMenuItem;
    Disabled1: TMenuItem;
    Export1: TMenuItem;
    Delete1: TMenuItem;
    ModifyLog1: TMenuItem;
    Sproc: TClientDataSet;
    cmbItem: TComboBox;
    edtData: TEdit;
    procedure sbtnAppendClick(Sender: TObject);
    procedure sbtnModifyClick(Sender: TObject);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure FormShow(Sender: TObject);
    procedure sbtnDeleteClick(Sender: TObject);
    procedure sbtnDisabledClick(Sender: TObject);
    procedure cmbShowChange(Sender: TObject);
    procedure sbtnExportClick(Sender: TObject);
    procedure ModifyLog1Click(Sender: TObject);
    procedure edtDataKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx : String;
    UpdateUserID : String;
    sItemID, sItemCode,sItemName,sItemDesc,sItemValue,sItemDev,sUpperValue,sLowerValue :String;
    Authoritys,AuthorityRole : String;
    function  getmaxid:string;
    Procedure CopyToHistory(sItemId: String);
    procedure showData;
    Procedure SetStatusbyAuthority;
  end;

var
  fDPPM: TfDPPM;

implementation

{$R *.DFM}

uses uHistory;

Procedure TfDPPM.SetStatusbyAuthority;
var iPrivilege:integer;
begin
  // Read Only,Allow To Change,Full Control
  iPrivilege:=0;
  with sproc do
  begin
    try
       Close;
       DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
       FetchParams;
       Params.ParamByName('EMPID').AsString := UpdateUserID;
       Params.ParamByName('PRG').AsString := 'Tooling';
       Params.ParamByName('FUN').AsString :='Machine Calibration Item';
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

  sbtnDisabled.Enabled := (iPrivilege >=1);
  Disabled1.Enabled := sbtnDisabled.Enabled;

  sbtnDelete.Enabled := (iPrivilege >=2);
  Delete1.Enabled := sbtnDelete.Enabled;
end;

function TfDPPM.GetMaxId:string;
begin

   With QryTemp do
   begin
     Close;
     Params.Clear;
     CommandText := ' select nvl(max(item_id)+1,100001)  MAX_ID from  SAJET.SYS_Cal_Item ';
     Open;

     Result := fieldByName('MAX_ID').AsString ;
   end;

end;


Procedure TfDPPM.CopyToHistory(sItemId: String);
begin
  With QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'Item_ID', ptInput);
     CommandText := ' Insert Into SAJET.SYS_HT_Cal_Item '+
                    ' Select * from SAJET.SYS_Cal_Item '+
                    ' Where Item_ID = :Item_ID ';
     Params.ParamByName('Item_ID').AsString := sItemId;
     Execute;
  end;
end;

procedure TfDPPM.ShowData;
begin
  If cmbShow.ItemIndex <= 0 Then
     cmbShow.ItemIndex := 0;
  With QryData do
  begin
     Close;
     params.Clear;
     Commandtext:=' select Item_Id,Item_Code,Item_Name,Item_desc ,Item_Value,Item_Deviation,Upper_Value,Lower_Value'
                 +' from sajet.sys_Cal_Item  where ';
     if cmbItem.ItemIndex=0 then
        commandtext:=commandtext+'  Item_Code like '+''''+trim(edtData.Text)+'%'+''''
     else if cmbitem.ItemIndex=1 then
        commandtext:=commandtext+' Item_Name  like '+''''+trim(edtData.Text)+'%'+'''';

     If cmbShow.Text = 'Enabled' Then
       CommandText:= CommandText + 'And enabled = ''Y'' ';
     If cmbShow.Text = 'Disabled' Then
        CommandText:= CommandText + 'And enabled = ''N'' ';

     CommandText := CommandText + ' Order By '+Orderidx;
     Open;
  end;
end;

procedure TfDPPM.sbtnAppendClick(Sender: TObject);
begin
  With TfData.Create(Self) do
  begin
     MaintainType := 'Append';
     LabType1.Caption := LabType1.Caption + ' Append';
     LabType2.Caption := LabType2.Caption + ' Append';
     LabID.Caption :=getmaxid;
     If Showmodal = mrOk Then
       ShowData;
     Free;
  end;
end;

procedure TfDPPM.sbtnModifyClick(Sender: TObject);
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  With TfData.Create(Self) do
  begin
     MaintainType := 'Modify';

     sItemID:=QryData.fieldbyname('Item_id').AsString;
     sItemCode:=QryData.fieldbyname('Item_Code').AsString;
     sItemName:=QryData.fieldbyname('Item_Name').AsString;
     sItemDesc:=QryData.fieldbyname('Item_Desc').AsString;
     sItemValue:=QryData.fieldbyname('Item_Value').AsString;
     sItemDev:=QryData.fieldbyname('Item_Deviation').AsString;
     sUpperValue:=QryData.fieldbyname('Upper_Value').AsString;
     sLowerValue:=QryData.fieldbyname('Lower_Value').AsString;
     LabID.Caption := sItemID;
     edtCode.Text := sItemCode;
     edtName.Text := sItemName;
     edtDesc.Text := sItemDesc;
     edtValue.Text := sItemValue;
     edtDeviation.Text :=sItemDev;
     edtUpper.Text := sUpperValue;
     edtLower.Text :=sLowerValue;

     If Showmodal = mrOK Then
       ShowData;
     Free;
  end;
end;

procedure TfDPPM.DBGrid1TitleClick(Column: TColumn);
begin
  OrderIdx:= Column.FieldName;
  ShowData;
end;

procedure TfDPPM.FormShow(Sender: TObject);
begin
  Orderidx := 'Item_Code';
  cmbItem.ItemIndex:=0;
  cmbShowChange(Self);
  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;
end;

procedure TfDPPM.sbtnDeleteClick(Sender: TObject);
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  If MessageDlg('Do you want to delete this data ?' + #13#10+
                'Item ID : ' + QryData.Fieldbyname('Item_Id').AsString +#13#10+
                'Item Code  : ' + QryData.Fieldbyname('Item Code').AsString +#13#10+
                'Item Name  : ' + QryData.Fieldbyname('Item_Name').AsString
                ,mtWarning, mbOKCancel,0) = mrOK Then
  begin
    With QryTemp do
    begin

      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'itemid', ptInput);
      CommandText := 'Delete SAJET.sys_CAL_ITEM '+
                     'Where item_id = :itemid   ';
      Params.ParamByName('itemid').AsString := QryData.Fieldbyname('item_id').AsString;

      Execute;
      QryData.Delete;
    end;
  end;
end;

procedure TfDPPM.sbtnDisabledClick(Sender: TObject);
Var sStatus : String;
begin
  If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;

  If QryData.Fieldbyname('ENABLED').AsString = 'Y' Then
  begin
    If MessageDlg('Do you want to disable this data ?' + #13#10+
                  'Item ID : ' + QryData.Fieldbyname('Item_Id').AsString +#13#10+
                  'Item Code  : ' + QryData.Fieldbyname('Item Code').AsString +#13#10+
                  'Item Name  : ' + QryData.Fieldbyname('Item_Name').AsString
                 ,mtWarning, mbOKCancel,0) <> mrOK Then
      Exit;
    sStatus := 'N';
  end Else
  begin
    If MessageDlg('Do you want to enable this data ?' + #13#10+
                  'Item ID : ' + QryData.Fieldbyname('Item_Id').AsString +#13#10+
                  'Item Code  : ' + QryData.Fieldbyname('Item Code').AsString +#13#10+
                  'Item Name  : ' + QryData.Fieldbyname('Item_Name').AsString
                 ,mtWarning, mbOKCancel,0) <> mrOK Then
      Exit;
    sStatus := 'Y';
  end;

  With QryTemp do
  begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'ENABLED', ptInput);
      Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
      Params.CreateParam(ftString	,'item_id', ptInput);
      CommandText := 'Update SAJET.sys_Cal_Item'+
                     'Set ENABLED = :ENABLED, '+
                     'UPDATE_USERID = :UPDATE_USERID '+
                     'Where ITEM_ID = :item_id ' ;
      Params.ParamByName('ENABLED').AsString := sStatus;
      Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
      Params.ParamByName('item_id').AsString := QryData.Fieldbyname('item_id').AsString;
      Execute;
      CopyToHistory(QryData.Fieldbyname('item_id').AsString );
      QryData.Delete;
  end;
end;

procedure TfDPPM.cmbShowChange(Sender: TObject);
begin
  sbtnDisabled.Caption := 'Disabled';
  If cmbShow.Text = 'Disabled' Then
    sbtnDisabled.Caption := 'Enabled';
  Disabled1.Caption := sbtnDisabled.Caption;
  SbtnDelete.Visible := (cmbShow.Text = 'Disabled');
  ImgDelete.Visible := SbtnDelete.Visible;
  Delete1.Visible := SbtnDelete.Visible;
  ShowData;
end;

procedure TfDPPM.sbtnExportClick(Sender: TObject);
Var F : TextFile;
    S : String;
    i,j : integer;
begin
  if (not QryData.active) or (QryData.IsEmpty) then
    exit;

  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'csv';
  SaveDialog1.Filter := 'All Files(*.csv)|*.csv';
  If SaveDialog1.Execute Then
  begin
     AssignFile(F,SaveDialog1.FileName);
     Rewrite(F);
     for i:= 0 to DBGrid1.Columns.Count-1 do
       if i= 0 then
         S:= DBGrid1.Columns.Items[i].Title.Caption
       else
         S:= S + ','+DBGrid1.Columns.Items[i].Title.Caption;
     Writeln(F,S);

     QryData.First ;
     while not QryData.EOF do
     begin
       for i := 0 to DBGrid1.Columns.Count - 1 do
       begin
         if i= 0 then
           S:= DBGrid1.Fields[i].AsString
         else
           S := S + ','+DBGrid1.Fields[i].AsString;
       end;
       Writeln(F,S);
       QryData.Next;
     end;

     MessageDlg('Export OK !!',mtCustom, [mbOK],0);
     CloseFile(F);
  end;
end;

procedure TfDPPM.ModifyLog1Click(Sender: TObject);
Var S,S1 : String;
begin
  {If (not QryData.Active) or (QryData.IsEmpty) Then
  begin
     Exit;
  end;
  
  S := QryData.Fieldbyname('PROCESS_ID').AsString;
  S1 := QryData.Fieldbyname('PDLINE_ID').AsString;
  With TfHistory.Create(Self) do
  begin
    QryData1.RemoteServer := Self.QryData.RemoteServer ;
    QryData1.ProviderName := 'DspQryData1';
    //editCode.Text := S;
    ShowHistory(S,S1) ;
    Showmodal;
    Free;
  end;  }
end;

procedure TfDPPM.edtDataKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then
    showdata;
end;

end.
