unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Grids, DBGrids;

type
  TfDetail = class(TForm)
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    procedure DBGrid1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fDetail: TfDetail;

implementation

{$R *.dfm}

procedure TfDetail.DBGrid1DblClick(Sender: TObject);
begin
  modalResult:=mrOK;
end;

end.
