unit uFilter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, Db, DBClient, DBTables;

type
  TfFilter = class(TForm)
    DBGrid2: TDBGrid;
    DataSource1: TDataSource;
    QryData: TClientDataSet;
    procedure DBGrid1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fFilter: TfFilter;

implementation

{$R *.DFM}

procedure TfFilter.DBGrid1DblClick(Sender: TObject);
begin
  If qryData.FieldByName('PART_NO').AsSTring = '' then
     Exit;
  ModalResult := mrOK;
end;

end.
