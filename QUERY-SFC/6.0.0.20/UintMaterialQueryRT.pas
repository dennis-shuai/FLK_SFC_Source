unit UintMaterialQueryRT;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, DB, DBClient, StdCtrls;

type
  TFormMaterialRT = class(TForm)
    Label1: TLabel;
    edtMaterial: TEdit;
    QryData: TClientDataSet;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    procedure FormShow(Sender: TObject);
    procedure edtMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMaterialRT: TFormMaterialRT;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormMaterialRT.FormShow(Sender: TObject);
begin
    edtMaterial.Text :='';
    qrydata.Close;
    QryData.RemoteServer :=formmain.socketconnection1;
    QryData.ProviderName :=formmain.Clientdataset1.ProviderName ;
end;

procedure TFormMaterialRT.edtMaterialKeyPress(Sender: TObject; var Key: Char);
begin
    if Key<>#13 then exit;
    if edtMaterial.Text ='' then exit;
    with qrydata do begin
        close;
        params.Clear;
        params.CreateParam(ftstring,'Material',ptInput);
        commandtext := ' SELECT c.RT_NO,B.PART_NO,D.INCOMING_QTY,D.PRINT_QTY,D.MFGER_NAME,D.MFGER_PART_NO,A.type,A.DATECODE,C.RECEIVE_TIME '+
                       ' FROM sajet.g_material A,sajet.sys_part b,SAJET.G_ERP_RTNO C,SAJET.G_ERP_RT_ITEM d WHERE A.MATERIAL_NO =:MATERIAL '+
                       ' AND A.PART_ID=b.part_id AND A.RT_ID =C.RT_ID AND C.RT_ID =D.RT_ID ';
        params.ParamByName('Material').AsString :=  edtMaterial.Text;
        open;

        if isempty then begin
              close;
              params.Clear;
              params.CreateParam(ftstring,'Material',ptInput);
              commandtext := ' SELECT c.RT_NO,B.PART_NO,D.INCOMING_QTY,D.PRINT_QTY,D.MFGER_NAME,D.MFGER_PART_NO,A.type,A.DATECODE,C.RECEIVE_TIME '+
                             ' FROM sajet.g_HT_material A,sajet.sys_part b,SAJET.G_ERP_RTNO C,SAJET.G_ERP_RT_ITEM d WHERE A.MATERIAL_NO =:MATERIAL '+
                             ' AND A.PART_ID=b.part_id AND A.RT_ID =C.RT_ID AND C.RT_ID =D.RT_ID AND ROWNUM=1';
              params.ParamByName('Material').AsString :=  edtMaterial.Text;
              open;
        end;


    end;
end;

procedure TFormMaterialRT.FormDestroy(Sender: TObject);
begin
   edtMaterial.Text :='';
   qrydata.Close;
end;

end.
