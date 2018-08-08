unit UnitQryRT;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, DB, DBClient, StdCtrls;

type
  TQryRT = class(TForm)
    Label1: TLabel;
    edtRT: TEdit;
    QryData: TClientDataSet;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    procedure FormShow(Sender: TObject);
    procedure edtRTKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  QryRT: TQryRT;

implementation

uses UnitMain;

{$R *.dfm}

procedure TQryRT.FormShow(Sender: TObject);
begin
    edtRT.Text :='';
    QryData.Close;
    QryData.RemoteServer :=formmain.socketconnection1;
    QryData.ProviderName :=formmain.Clientdataset1.ProviderName ;
end;

procedure TQryRT.edtRTKeyPress(Sender: TObject; var Key: Char);
begin
   if Key<>#13 then exit;
    if edtRT.Text ='' then exit;
    with qrydata do begin
        close;
        params.Clear;
        params.CreateParam(ftstring,'RT',ptInput);
        commandtext := ' select b.RT_NO,E.PART_NO,A.DATECODE,A.MATERIAL_NO,A.MATERIAL_QTY,A.REEL_NO,A.REEL_QTY,A.TYPE,A.STATUS, '+
                       ' C.warehouse_name,D.LOCATE_NAME from sajet.g_HT_MATERIAL a,sajet.g_ERP_RTNO b ,SAJET.SYS_WAREHOUSE C, '+
                       ' SAJET.SYS_LOCATE D,sajet.sys_part e where a.RT_ID=b.RT_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID AND '+
                       ' A.LOCATE_ID=d.Locate_ID AND A.PART_ID=E.PART_ID AND C.WAREHOUSE_ID =D.WAREHOUSE_ID AND B.RT_NO=:RT '+
                       ' ORDER BY A.UPDATE_TIME';
        params.ParamByName('RT').AsString :=  edtRT.Text;
        open;

    end;

end;

procedure TQryRT.FormDestroy(Sender: TObject);
begin
   edtRT.Text :='';
   QryData.Close;
end;

end.
