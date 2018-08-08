unit uFilter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, Db, DBClient,DBTables,
  StringGrid1;

type
  TfFilter = class(TForm)
    StringGrid11: TStringGrid1;
    procedure StringGrid11DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fFilter: TfFilter;

implementation

{$R *.DFM}

procedure TfFilter.StringGrid11DblClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

end.
