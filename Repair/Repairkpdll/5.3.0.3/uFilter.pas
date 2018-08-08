unit uFilter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, Db, DBClient;

type
  TfFilter = class(TForm)
    DBGrid1: TDBGrid;
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
   if (not QryData.Active) or (QryData.RecordCount=0) then
     exit; 
   ModalResult := mrOK;
end;

end.
