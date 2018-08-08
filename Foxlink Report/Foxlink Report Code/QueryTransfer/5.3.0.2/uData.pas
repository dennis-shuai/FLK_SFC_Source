unit uData;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Grids, DBGrids, ExtCtrls, Buttons, StdCtrls,DBClient,
  ComCtrls;
type
  TfData = class(TForm)
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DBGrid1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fData: TfData;

implementation

{$R *.dfm}

procedure TfData.DBGrid1DblClick(Sender: TObject);
begin
  ModalResult:=mrOK;
end;

procedure TfData.DBGrid1KeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then  ModalResult:=mrOK;
  if key=#27 then close;
end;

end.
