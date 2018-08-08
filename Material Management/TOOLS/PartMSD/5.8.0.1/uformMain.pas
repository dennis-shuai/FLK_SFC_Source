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
    Label1: TLabel;
    edtPart: TEdit;
    procedure sbtnAppendClick(Sender: TObject);
    procedure sbtnModifyClick(Sender: TObject);
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnDeleteClick(Sender: TObject);
    procedure edtPartKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx : String;
    UpdateUserID : String;
    Authoritys,AuthorityRole : String;
    procedure showData(PartNo:string);
    Procedure SetStatusbyAuthority;
  end;

var
  formMain: TformMain;

implementation

{$R *.DFM}

Procedure TformMain.SetStatusbyAuthority;
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
      Params.ParamByName('PRG').AsString := 'Material Management';
      Params.ParamByName('FUN').AsString :='Part MSD';
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

  sbtnDelete.Enabled := (iPrivilege >=2);
  Delete1.Enabled := sbtnDelete.Enabled;

end;

procedure TformMain.ShowData(PartNo:string);
begin
  With QryData do
  begin
     Close;
     params.Clear;
     Params.CreateParam(ftString	,'PartNo', ptInput);
     commandtext:= ' select a.part_id,b.part_no,a.check_MSD,a.floor_life,a.update_time,c.emp_name  '
                  +' from sajet.sys_part_MSD a, sajet.sys_part b,sajet.sys_emp c '
                  +' where a.part_id=b.part_id and a.update_userid=c.emp_id(+) '
                  +'   and b.part_NO like :PartNO ';
     Params.ParamByName('PartNo').AsString := PartNo+'%';
     Open;
  end;
end;

procedure TformMain.sbtnAppendClick(Sender: TObject);
begin

  try
    fData := TfData.Create(Self);
    fData.MaintainType := 'Append';
    fData.LabType1.Caption := fData.LabType1.Caption + ' Append';
    fData.LabType2.Caption := fData.LabType2.Caption + ' Append';
    fData.cmbFIFO.ItemIndex:=0;
    If fData.Showmodal = mrOK Then
    begin
       ShowData(trim(edtPart.Text));
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

    fData.edtPart.Text:=qrydata.fieldbyname('Part_no').AsString;
    fData.edtPart.Enabled:=false;
    fData.cmbFIFO.ItemIndex:=fData.cmbFIFO.Items.IndexOf(Qrydata.fieldbyname('check_MSD').AsString);
    fData.LabType1.Caption := fData.LabType1.Caption + ' Modify';
    fData.LabType2.Caption := fData.LabType2.Caption + ' Modify';
    //fData.ItemID := QryData.Fieldbyname('RecID').aSString;

    If fData.Showmodal = mrOK Then
       ShowData(trim(edtPart.Text));
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

  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;
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
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'PartID', ptInput);
      commandtext:=' insert into sajet.sys_ht_part_MSD '
                  +' select * from sajet.sys_part_msd where part_id=:PartID ';
      Params.ParamByName('PartID').AsString := QryData.Fieldbyname('Part_id').AsString;
      execute;

      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'PartID', ptInput);
      CommandText := 'Delete sajet.sys_part_MSD '+
                     'Where Part_id = :PartID and rownum=1  ';
      Params.ParamByName('PartID').AsString := QryData.Fieldbyname('Part_id').AsString;
      Execute;
      Close;

      QryData.Delete;
    end;
  end;
end;


procedure TformMain.edtPartKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then
    ShowData(edtPart.Text);
end;

end.
