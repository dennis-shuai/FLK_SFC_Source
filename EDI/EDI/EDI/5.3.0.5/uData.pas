unit uData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Grids, DBGrids;

type
  TfData = class(TForm)
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    procedure DBGrid1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses uDetail;

{$R *.dfm}

procedure TfData.DBGrid1DblClick(Sender: TObject);
begin
   if not dbgrid1.DataSource.DataSet.Active then exit;
   if dbgrid1.DataSource.DataSet.RecordCount=0 then exit;
   modalresult := mrOK;
end;

end.
