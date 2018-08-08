unit uPFilter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, Db;

type
  TfPFilter = class(TForm)
    DBGrid1: TDBGrid;
    dsrcFilter: TDataSource;
    procedure DBGrid1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fPFilter: TfPFilter;

implementation


{$R *.DFM}

procedure TfPFilter.DBGrid1DblClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

end.
