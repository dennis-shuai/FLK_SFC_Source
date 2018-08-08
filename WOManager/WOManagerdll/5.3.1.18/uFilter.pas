unit uFilter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, Db, DBClient;

type
  TfFilter = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
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
uses uData;

procedure TfFilter.DBGrid1DblClick(Sender: TObject);
begin
  If QryData.Eof then
    Exit;

  ModalResult := mrOK;
end;

end.
