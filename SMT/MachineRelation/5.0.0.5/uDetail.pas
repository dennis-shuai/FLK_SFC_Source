unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, DB, DBClient;

type
  TfDetail = class(TForm)
    Qrypart: TClientDataSet;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    procedure FormShow(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
      tPartNo:string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.dfm}

procedure TfDetail.FormShow(Sender: TObject);
begin
  //
  with qryPart do
  begin
    close;
    params.Clear;
    commandtext:=' select part_no,part_type,spec1,spec2  '
                +' from  sajet.sys_part '
                +' where part_no like '+''''+tPartNo+'%'+'''';
    open;
  end;
end;

procedure TfDetail.DBGrid1DblClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

end.
