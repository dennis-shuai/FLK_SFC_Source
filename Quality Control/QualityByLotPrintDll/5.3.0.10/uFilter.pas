unit uFilter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, Db, DBClient,uformMain,
  DBGrid1;

type
  TfFilter = class(TForm)
    DataSource1: TDataSource;
    qryData: TClientDataSet;
    DBGrid11: TDBGrid1;
    procedure DBGrid11DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fFilter: TfFilter;

implementation


{$R *.DFM}


procedure TfFilter.DBGrid11DblClick(Sender: TObject);
begin
   ModalResult := mrOK;
end;

end.
