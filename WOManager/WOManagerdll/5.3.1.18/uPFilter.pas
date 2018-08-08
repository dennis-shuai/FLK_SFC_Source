unit uPFilter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, Db;

type
  TfPFilter = class(TForm)
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    Panel1: TPanel;
    Label1: TLabel;
    edtPart: TEdit;
    procedure DBGrid1DblClick(Sender: TObject);
    procedure edtPartChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fPFilter: TfPFilter;

implementation

uses uWoManager;

{$R *.DFM}

procedure TfPFilter.DBGrid1DblClick(Sender: TObject);
begin
  If fWOManager.QryTemp.Eof then
    Exit;
  ModalResult := mrOK;
end;

procedure TfPFilter.edtPartChange(Sender: TObject);
begin
  If not fWOManager.QryTemp.Active Then
    Exit;
  fWOManager.QryTemp.Locate('Part_No', edtPart.Text,[loCaseInsensitive, loPartialKey]);
end;

end.
